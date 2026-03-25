---
created: 2026-06-24
description: Cursor's Vicent Marti surveys four generations of regex search indexing — classic trigram inverted indexes, suffix arrays, bloom-filter-augmented trigrams (GitHub Project Blackbird), and sparse n-grams with frequency-weighted hashing — then explains why Cursor builds and queries these indexes client-side for instant agent grep.
source: https://cursor.com/blog/fast-regex-search
---

# Indexing text with sparse n-grams and bloom filters eliminates 15-second ripgrep waits in large monorepos

## Key Takeaways

Cursor frames regex search as the critical bottleneck for coding agents in large monorepos. Ripgrep is fast but must scan every file — in enterprise monorepos this routinely takes 15+ seconds per invocation, stalling agent workflows. This motivates building a dedicated search index, much like traditional IDEs build syntactic indexes for Go To Definition. The parallel to [[ColBERT-style semantic search beats grep 70 percent of the time for coding agents while using fewer tokens]] is striking — both Cursor and the semantic search approach recognize that raw grep doesn't scale, but they attack it from opposite ends (exact match indexing vs. semantic retrieval).

The article walks through four indexing approaches in chronological order:

1. **Classic trigram inverted index** (Zobel et al. 1993, popularized by Russ Cox 2012) — tokenize documents into overlapping 3-char sequences, build an inverted index, decompose regex queries into trigrams, intersect posting lists. Used by `google/codesearch` and `sourcegraph/zoekt`. Works but posting lists are large and query decomposition forces a tradeoff between few trigrams (too many candidates) and many trigrams (slow lookups).

2. **Suffix arrays** (Nelson Elhage's `livegrep`, 2015) — sorted array of all suffixes enables binary search for any literal. Elegant and compact (just offsets) but requires concatenating all source into one string, making dynamic updates very expensive. Hard to scale.

3. **Bloom-filter-augmented trigrams** (GitHub Project Blackbird) — the "3.5-gram" insight. Use trigrams as keys but augment each posting with two 8-bit bloom filters: a `nextMask` encoding which characters follow the trigram (enabling quadgram-like specificity), and a `locMask` encoding positions (enabling adjacency checking). Extremely efficient storage but bloom filters saturate with updates, degrading to full-scan performance.

4. **Sparse n-grams** (ClickHouse, GitHub Code Search) — instead of extracting every trigram, assign deterministic weights to character pairs and extract variable-length n-grams at weight boundaries. At index time, extract all sparse n-grams (expensive upfront). At query time, use a covering algorithm that extracts only minimal n-grams needed. The killer optimization: use character-pair frequency from real source code as the weight function, so rare pairs get high weights, resulting in even fewer lookups with higher specificity.

Cursor builds these indexes **client-side** rather than server-side. The reasoning connects to latency sensitivity in [[the harness is everything and agent performance comes from environment design not model capability]] — agents invoke grep constantly and in parallel, so network roundtrips would compound. Client-side also avoids synchronizing all files to a server and sidesteps security/privacy concerns. The index is based on a git commit with user/agent changes as a layer on top, making updates fast.

The on-disk format is elegant: posting lists flushed sequentially to one file, a sorted lookup table of n-gram hashes + offsets in another file. Only the lookup table is `mmap`'d into the editor process. Queries do a binary search on the lookup table, then read directly from the postings file at the returned offset. Storing hashes instead of full n-grams keeps the lookup table tight — hash collisions only broaden posting lists (safe, since final matching is deterministic).

The benchmarks show dramatic improvement: investigation workflows in Chromium-scale repos go from 240s to under 60s when grep latency is eliminated. This connects to [[searching more and thinking less improves agentic efficiency and generalization]] — faster search means agents can search more aggressively rather than reasoning about where things might be.

## External Resources

- [Zobel, Moffat, Sacks-Davis (1993) — "Searching Large Lexicons for Partially Specified Terms using Compressed Inverted Files"](https://www.vldb.org/conf/1993/P290.PDF) — the original paper on trigram inverted indexes for regex
- [Russ Cox (2012) — "Regular Expression Matching with a Trigram Index"](https://swtch.com/~rsc/regexp/regexp4.html) — the blog post that popularized the approach after Google Code Search shutdown
- [Nelson Elhage — livegrep](https://livegrep.com/search/linux) — suffix array search over the Linux kernel
- [Nelson Elhage (2015) — "Regular Expression Search with Suffix Arrays"](https://blog.nelhage.com/2015/02/regular-expression-search-with-suffix-arrays/)
- [ripgrep](https://github.com/BurntSushi/ripgrep) — Andrew Gallant's fast grep alternative used by most agent harnesses
- [google/codesearch](https://github.com/google/codesearch) — classic trigram-based code search
- [sourcegraph/zoekt](https://github.com/sourcegraph/zoekt) — trigram-based code search used by Sourcegraph
- [ClickHouse text indexes](https://clickhouse.com/docs/engines/table-engines/mergetree-family/textindexes) — sparse n-gram implementation
- [GitHub Code Search](https://github.com/features/code-search) — ships sparse n-grams for regex support
- [Cursor secure codebase indexing](https://cursor.com/blog/secure-codebase-indexing) — their semantic index approach (complementary to this)
- [Cursor Composer 2](https://cursor.com/blog/composer-2) — the fast model that benefits most from instant grep

## Original Content

> **Vicent Marti** · Cursor Blog · Mar 23, 2026
> *Note: This article contains extensive interactive visualizations (inverted index explorers, trigram decomposition, suffix array search, bloom filter walkthroughs, sparse n-gram steppers, and benchmark timelines) that cannot be reproduced in markdown. Visit the [original article](https://cursor.com/blog/fast-regex-search) to interact with them.*

> [!quote]- Source Material
>
> Time is a flat circle. When the first version of `grep` was released in 1973, it was a basic utility for matching regular expressions over text files in a filesystem. Over the years, as developer tools became more advanced, it was gradually superseded by more specialized tools. First, by roughly syntactic indexes such as `ctags`. Later on, many developers moved to specialized IDEs for specific programming languages that allowed them to navigate codebases very efficiently by parsing and building syntactical indexes, often augmented with type-level information. Eventually this was standardized in the Language Server Protocol (LSP), which brought these indexes to all text editors, new and old. Then, just when LSP was becoming a standard, Agentic coding arrived, and what do you know: the agents just _love_ to use `grep`.
>
> There are other state-of-the art techniques to gather context for Agents. We've [talked in the past](https://cursor.com/blog/secure-codebase-indexing) about how much you can improve Agent performance by using semantic indexes for many tasks, but there are specific queries which the model can only resolve by searching with regular expressions. This means going back to 1973, even though the field has advanced a little bit since then.
>
> Most Agent harnesses, including ours, default to using [ripgrep](https://github.com/BurntSushi/ripgrep) when providing a search tool. It's a standalone executable developed by Andrew Gallant which provides an alternative to the classic `grep` but with more sensible defaults (e.g. when it comes to ignoring files), and with much better performance. `ripgrep` is notoriously fast because Andrew has [spent a lot of time thinking about speed](https://burntsushi.net/ripgrep/) when matching regular expressions.
>
> No matter how fast `ripgrep` can match on the contents of a file, it has one serious limitation: it needs to match on the contents of _all_ files. This is fine when working in a small project, but many of Cursor's users, particularly large Enterprise customers, work out of very large monorepos. Painstakingly large. We routinely see `rg` invocations that take more than 15 seconds, and that really stalls the workflow of anybody who's actively interacting with the Agent to guide it as it writes code.
>
> Matching regular expressions is now a critical part of Agentic development, and we believe it's crucial to target it explicitly: much like a traditional IDE creates syntactic indexes locally for operations like Go To Definition, we're creating indexes for the core operation that modern Agents perform when looking up text.
>
> ## The classic algorithm
>
> The idea of indexing textual data for speeding up regular expression matches is far from new. It was first published in 1993 by Zobel, Moffat and Sacks-Davis in a paper called [_"Searching Large Lexicons for Partially Specified Terms using Compressed Inverted Files"_](https://www.vldb.org/conf/1993/P290.PDF). They present an approach using n-grams (segments of a string with a width of _n_ characters) for creating an inverted index, and heuristics for decomposing regular expressions into a tree of n-grams that can be looked up in the index.
>
> If you've heard of this concept before, it's probably not from that paper, but from [a blog post](https://swtch.com/~rsc/regexp/regexp4.html) that Russ Cox published in 2012, shortly after the shutdown of Google Code Search. Let's do a quick refresher of the building blocks for these indexes, because they apply to basically every other approach to indexing that has been developed since.
>
> ### Inverted Indexes
>
> An inverted index is the fundamental data structure behind a search engine. Working off a set of documents to be indexed, you construct an inverted index by splitting each document into tokens. This is called tokenization, and there are many different ways to do it — for this example, we'll use the simplest possible approach, individual words as tokens. The tokens then become the keys on a dictionary-like data structure, while the values are, for each token, the list of all documents where it appears. This list is commonly known as a _posting list_, because each document is uniquely identified by a numeric value or "posting". When you search for one or more tokens, we load their posting lists; if there is more than one posting list, we intersect them to find the documents that appear in _all of them_.
>
> This design (with a lot of complexity bolted-on on top of it) is the basis for most search engines available today. But these are search engines for _natural language_, and we're trying to search for regular expressions, and we're trying to match them over source code. This doesn't quite work.
>
> You can try to build something useful here by thinking very hard about tokenization — being aware of the syntax of each programming language, breaking up the identifiers in source code, and so on. This is very hard to get right. Back in the early days of GitHub, their Code Search feature worked like that: with a very complex tokenizer for programming languages, and a very large ElasticSearch cluster. The results were not good, and people had very poor opinions of the feature. You could search for identifiers (kind of), but not match regular expressions. You need a better way to tokenize in order to do that.
>
> ### Trigram Decomposition
>
> Naive tokenization on source code is not useful for matching regular expressions. We need to split the documents into more fundamental chunks. The classic algorithm chooses trigrams: a token is every overlapping segment of three characters in the input string.
>
> Why three? We're going to store these trigrams as the keys in our inverted index. If we were to choose bigrams (chunks of 2), we would have very few keys in our index, up to 64k, but the posting lists on each key would be massive — too large to work with efficiently. If we went with quadgrams (chunks of 4), the posting lists would be tiny, which is a very good thing, but we would have billions of keys in our inverted index, and that's also hard to work with.
>
> Trigrams are hence a pretty good middle ground. This makes tokenization when indexing documents very simple: extract every overlapping sequence of 3 characters from the document being indexed and use that as your tokens in the inverted index.
>
> The actual complexity comes when tokenizing a regular expression so that it can be matched against the index. Regular expressions have _syntax_, so you need to parse them and use heuristics to figure out what trigrams can be extracted from the segments of the expression that actually represent text.
>
> Decomposing a literal string into trigrams is straightforward, as it is the same algorithm as when you index a document. Extract every overlapping trigram contained in the string; a document that contains _all_ these trigrams will probably contain the literal (but not necessarily!). Alternations are decomposed separately, resulting in two branches where _either_ must be contained in a document for it to match. We query this on the inverted index by _joining_ the posting lists instead of intersecting them. Character classes can be decomposed into many trigrams. Small classes like `[rbc]at` result in one trigram for each element of the class. When using broader character classes, we simply skip extracting those trigrams across those boundaries.
>
> ### Putting it all together
>
> We know that trigrams are the right way to tokenize these documents, we know how to tokenize documents when building the index, and how to tokenize queries when searching. We can put all this together into an actual search index that can match regular expressions _very efficiently_. By decomposing any regular expression into a set of trigrams and loading all the relevant posting lists from the inverted index, we end up with a list of documents that can _potentially_ match our regular expression. This is important! The final result set will only be obtained by actually loading all the potential documents and matching the regular expression "the old fashioned way". But having this sub-set of documents is always faster than having to scan and match the whole codebase, file by file.
>
> This design is, by all means, fully functional. Projects like [google/codesearch](https://github.com/google/codesearch) and [sourcegraph/zoekt](https://github.com/sourcegraph/zoekt) provide good performance for large indexes using an inverted index of trigrams (and like all search engines, they bolt-on a lot more complexity on top). But there are clear shortcomings here: the index sizes are _not_ small, and decomposition at query time must make a trade-off. If you use simple heuristics, you'll decompose queries into a few trigrams, and that will result in a lot of potential documents to match. If you use complex heuristics, you may end up with dozens —perhaps hundreds— of trigrams, and loading all those from the inverted index may become as slow as simply searching everything from scratch.
>
> We can do better than that.
>
> ## Suffix Arrays: a detour
>
> Since we're covering the history of indexing textual data for regular expression searches, I'd like to take a detour and discuss [this implementation](https://blog.nelhage.com/2015/02/regular-expression-search-with-suffix-arrays/) that Nelson Elhage developed in 2015 for his [livegrep](https://livegrep.com/search/linux) web service. Compared to other large industry efforts, `livegrep` is tiny —it only indexes the most recent version of the Linux Kernel— but because of its reduced scope, its implementation is very much unlike anything else out there, and that makes it very interesting and worth talking about.
>
> Nelson attacked the problem from first principles: there's no inverted index powering this search engine. Instead, all the source code is indexed inside a _suffix array_.
>
> The concept of a suffix array is self-descriptive: a sorted array of all the suffixes of a string. If you try constructing an array for a larger string, you'll see that the data structure grows quickly. It may seem a particularly expensive index, and in many ways it is, but its storage can be compressed very well if you have access to the original string: you can just store the offsets of the start of every suffix.
>
> Once we have constructed a suffix array for the corpus to be searched, regular expression searches can be performed efficiently by de-composing the regular expression into literals. Every potential match position for a regular expression can then be found by performing a binary search over the suffix array.
>
> What are the shortcomings here? A suffix array must be constructed out of an input string. That is a big limitation. If you're trying to index a large codebase (or perhaps many different codebases), you'll first need to concatenate all the content into a single string, and construct the suffix array out of that. When matching inside the suffix array, you'll also need an auxiliary data structure to map the match position to the original file that contains it. It is not insurmountable complexity, but it makes dynamically updating the index very expensive. This is a solution that is very hard to scale.
>
> ## Trigram Queries with Probabilistic Masks
>
> Jumping back to some more traditional designs: here's an approach that was originally developed at GitHub for _Project Blackbird_. This was a research project aiming to replace the old Code Search feature. As we've discussed earlier, the old search was implemented by tokenizing source code and couldn't match regular expressions. The goal for this new implementation was developing something that could.
>
> The first iterations attempted to use the classic inverted index with trigrams as keys, but it quickly ran into capacity issues. There is a lot of code in GitHub, and using trigrams to index it resulted in posting lists that were just too large to search.
>
> As trigrams were not quite working out, the next step was finding a better size for the n-grams that would be indexed. We've seen that bigrams are too broad, because their posting lists become unmanageably large, and that quadgrams are too specific, because we end up with too many keys in our index. Trigrams are _a_ sweet spot between the two, but in practice, the ideal size is more like... 3.5-grams. Yet we can't split a character in two, can we?
>
> We can, in fact, do something quite close to that: this design proposes using trigrams as the key for the inverted index, and augmenting the posting lists with extra information about the "fourth character" that would follow the trigram in that specific document. To do that, we could simply store that fourth character as an extra byte, but that turns our index into a quadgram index, and we've seen those are just too large to store. What we store instead is a bloom filter that contains all the characters that follow that specific trigram.
>
> You may think of a bloom filter as a very large and complex data structure, but it needn't be so. You can squeeze a bloom filter into very few bits. A lot of information can fit in 8 bits if you're careful when encoding it. With just two bytes per posting, we can work around the two biggest issues in a classic trigram index.
>
> By having a mask that contains the characters following each trigram, our inverted index can be constructed using trigram keys, but we can query it using quadgrams! This already scopes down the potential documents much more than a simple trigram index could.
>
> A second augmented mask, containing the offsets where the trigram appears in the document, solves the trigram ambiguity issue: just because a document contains two trigrams doesn't mean that they're actually _next to each other_, which is what we need to match our query. By shifting the position mask of our second trigram one bit to the left and comparing it with the mask for the first trigram, we can ensure that they are indeed adjacent. With particularly common trigrams, this is invaluable for scoping down even further the list of candidate documents.
>
> All this information is, of course, probabilistic: like anything stored in a bloom filter, it can yield false positives. But false positives are always acceptable here, because the final matching is performed deterministically on the text itself. The goal is using our index to minimize the amount of potential documents we need to scan.
>
> The resulting indexes are _extremely efficient_, but they have a major shortcoming. Bloom filters can become saturated. That is an unfortunate property of bloom filters; they can be updated, but if you add too much data to them, eventually all the bits in the filter are set. And once the bloom filter is saturated, it matches everything, so we're back to the performance of the very first index we talked about.
>
> This is an index that minimizes storage, but it becomes painful when you need to update it in-place.
>
> ## Sparse N-grams: Smarter Trigram Selection
>
> Here's another very smart idea. You may have seen it used in ClickHouse for [their regular expression operator](https://clickhouse.com/docs/engines/table-engines/mergetree-family/textindexes), and also at GitHub, in the [new Code Search feature](https://github.com/features/code-search) that shipped a couple years ago and which does allow matching regular expressions. It's called Sparse N-grams, and it is the sweetest of the middle grounds.
>
> A traditional trigram index extracts _every_ consecutive 3-character sequence, but you can see how this creates _a lot of redundancy_. The characters in every trigram are duplicated in the adjacent ones! In this algorithm, we extract a random amount of n-grams, with each n-gram having a random length.
>
> Of course _random_ here cannot be truly random, because then the index couldn't be queried. We are assigning a "weight" to every pair of characters in the document. This weight could be anything, as long as it's deterministic (ClickHouse uses the `crc32` hash of the two characters). Then, our sparse n-grams are all substrings where the weights at both ends are strictly greater than all the weights contained inside.
>
> Crucially, this means that sparse n-grams can have _any length_. They are not consistent. It also means that we can end up generating a lot of them — more than if we were simply extracting trigrams. But because the n-grams are being generated deterministically, we can do some very important optimizations at query time. Let's see how.
>
> So what's the deal here? Are we simply doing something silly? Not quite. We're paying a high upfront cost when indexing so that we can have _very fast queries_ at query time. The `build_all` algorithm is what we use when indexing documents. It extracts _all_ the possible sparse n-grams from the input. Note, however, that we don't have to do that when querying. Because the weights are random but deterministic, at query time we can use a covering algorithm that only generates the minimal amount of n-grams required to match in the index.
>
> We know that the n-grams are minimal because at index time, we only generate them when all the weights _contained inside_ are smaller than the ones at the edges. Hence, we only need to extract the sparse n-grams _at the edges_ —way fewer than if we were to extract all trigrams— and we'll be able to select our potential documents with very high specificity.
>
> Can we do better than this? Yes! Much better, in fact. We've been using `crc32` as our weight function in the algorithm as an example. However, any hash function would work here, as long as it's deterministic. Let's pick something very smart: a hash function that gives a high weight to every pair of characters that is actually _very rare_, and a low weight to every pair that is _very frequent_.
>
> This hash function is easy to compute. Since we're going to be indexing source code, we can pick up a couple terabytes of Open-Source code from the internet and build a frequency table for all the character pairs we find in it. That frequency table is our hash function. When we apply it to our algorithm: the highest weights now appear under the least frequent pairs of characters, and because of this, the covering mode results in _even fewer_ n-grams to lookup, and fewer documents that can possibly match.
>
> This approach that minimizes the amount of posting lookups will serve as the perfect starting point to construct indexes that can be efficiently queried on the users' machines.
>
> ## All this, in your machine
>
> Indexes for speeding up regular expression search need to live _somewhere_. All the designs we've seen so far have been deployed on the server side, and the semantic indexes we've talked about are also managed and queried on the server. And yet, we're choosing to go in a different direction here: we're building and querying the indexes in the users' machines.
>
> There are several reasons why keeping these indexes locally makes sense. First, the indexes are just _one_ part of what it is required to match a regular expression. They provide a scoped down subset of documents where the regular expressions could match, but you still need to individually scan each file. Doing that on the server would mean either synchronizing all the files, or performing expensive roundtrips back and forth to the client. Doing this on the client is trivial, and also sidesteps a lot of security and privacy concerns around data storage.
>
> Latency also matters a lot for this functionality. Our Composer model has one of the fastest tokens per second (TPS) in the industry, and we're working hard to make it both smarter _and_ faster. Adding network roundtrips for such a critical operation that the model uses _constantly_ (oftentimes in parallel) just adds friction, stalls, and takes us in the opposite direction of what our goal is for interacting with Agents.
>
> *Instant grep benchmark comparison — light mode*
> ![[cursor-regex-search-001.png]]
>
> *Instant grep benchmark comparison — dark mode*
> ![[cursor-regex-search-002.png]]
>
> Unlike with semantic indexes, an index for regular expression search also needs to be _very fresh_, particularly when it comes to the model reading its own writes. We don't have to continuously update our semantic index because re-computing the embeddings for a file after it is modified does not cause the new embedding to significantly displace itself in the multi-dimensional space. The nearest-neighbor search we perform will still send the Agent in the right direction. However, if the agent is searching for specific text and it does not find it, it'll often go into a wild goose chase, waste tokens, and defeat the purpose of our performance optimization in the first place.
>
> Bringing these indexes to the client does come with its own set of challenges. Synchronizing disk data can be complex and expensive, but we make it very efficient in practice: we control the state of the index by basing it off a commit in the underlying Git repository. User and agent changes are stored as a layer on top of it. This makes it very quick to update, and very fast to load and synchronize on startup.
>
> To ensure that memory usage in the editor remains minimal, we store our indexes in two separate files. The first file contains all the posting lists for the index, one after the other — we flush this directly to disk during construction. The other file contains a sorted table with the hashes for all n-grams and the offset for their corresponding posting list in the postings file. Storing hashes here without storing the full n-grams is always safe: it can cause a posting list to become more broad when two hashes collide (extremely unlikely in practice), but it cannot give incorrect results. It also gives us a very tight layout for the lookup table. We then `mmap` this table, and only this table, in the editor process, and use it to serve queries with a binary search. The search returns an offset, and we read directly at that offset on the postings file.
>
> ## Conclusions
>
> We've found that providing text search indexes to fast models, such as our own [Composer 2](https://cursor.com/blog/composer-2), creates a qualitative difference for Agentic workflows. The impact is much more pronounced in larger Enterprise repositories, because `grep` is one of the few Agent operations whose latency scales with the size and complexity of the code being worked on. Take a look at these example workflows running with Composer 2: removing altogether the time spent searching the codebase provides meaningful time savings —particularly when the Agent investigates bugs— and allows for much more effective iteration.
>
> As for what's next, who knows! There are many exciting developments around providing context for Agents, and a lot of researchers working in the space — including ours. We're going to continue optimizing the performance of current approaches, including [semantic indexes](https://cursor.com/blog/secure-codebase-indexing), and we're hoping to bring forward brand new ways of improving the performance of Agents even further, whilst always ensuring that they're operable where they really matter: in the largest repositories of the world, where the future of Agentic development is really gaining traction.

[Original article](https://cursor.com/blog/fast-regex-search)
