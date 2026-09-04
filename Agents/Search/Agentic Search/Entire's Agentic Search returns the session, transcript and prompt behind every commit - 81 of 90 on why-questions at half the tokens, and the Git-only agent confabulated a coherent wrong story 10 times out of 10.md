---
created: 2026-09-03
description: Entire launches Agentic Search — one API an agent queries across every repo it can access, where each result returns the matching code and commit plus that commit's checkpoint (the session, transcript, and prompt behind the change). The product bet is that "why is our code like this?" is answered in agent sessions rather than in code. Their searchmark benchmark runs nine real engineering-history questions ten times each through two identical headless Claude agents, both with full-history clones, git log, git log -S, git show and the GitHub CLI; the baseline scores 70/90 and the search arm 81/90 at 262K vs 547K tokens, $0.23 vs $0.38, and 7 vs 14 steps per question. On the deepest-history question the Git-only agent went 0/10 by producing a plausible but wrong adjacent story in all ten runs — real commits, real PRs, a coherent narrative, the wrong subject — while the search agent went 10/10 in 35 seconds. Architecture: incremental per-checkpoint transcript indexing at ~700-token chunks with one turn of overlap into turbopuffer, one namespace per repo per region; three-tier ranking (full-phrase, keyword, vector-only) instead of score fusion, then a reranker over ~200 candidates; a separate literal, symbol-aware code index at ~100ms median; and per-region full stacks where the query fans out to the data rather than the corpus moving. Harness published at entireio/searchmark.
source: https://entire.io/blog/introducing-agentic-search-for-code-and-context
author: Evis Drenova
type: article
tags: [agentic-search, code-search, hybrid-retrieval, reranking, incremental-indexing, turbopuffer, agent-transcripts, checkpoints, provenance, benchmark, data-residency, entire]
---

## Key Takeaways

- **The product thesis is a genuine reframe: the expensive questions are "why," and the answers no longer live in the code or the commits — they live in agent sessions.** Each search result returns the matching code *and* the commit *and* that commit's **checkpoint: the session, the transcript, and the prompt behind the change**. This is the natural consequence of agents writing most of the code — the reasoning that used to sit in a developer's head and leak into a PR description now sits in a transcript, and [[agents fail without trace architecture because reasoning evaporates when the context window closes|reasoning evaporates when the context window closes]] unless something makes it a durable, addressable artifact. Read as a follow-on to [[Entire's pgr proves definition-first ranking helps coding agents more than faster ripgrep|the same company's earlier post on ranking]], the scope has moved from *finding code faster* to *making the history that produced it retrievable at all*, which is the more defensible position given [[coding agents are bottlenecked by search not coding ability|search, not coding ability, is the bottleneck]].

- **The benchmark table carries more than the prose quotes, and the efficiency numbers are the stronger result.** Nine real engineering-history questions from their own org, ten runs each, two identical headless Claude agents — both with full-history clones, `git log`, `git log -S`, `git show`, and the GitHub CLI; one also got `entire search`. Accuracy 70/90 → **81/90**, but alongside it **547K → 262K tokens**, **$0.38 → $0.23 per question**, and **14 → 7 agent steps**. Roughly the same shape as [[Toast 1 takes over the search loop as a specialized subagent - 3.5x fewer tokens at identical Harvey-bench scores and OfficeQA SOTA at 1.15 dollars per task|Toast 1's 3.5x token reduction at constant score]] and consistent with [[ColBERT-style semantic search beats grep 70 percent of the time for coding agents while using fewer tokens|ColGREP beating grep 70% of the time at lower token cost]] — three independent results now say that good retrieval buys efficiency at least as much as accuracy.

- **The most interesting single finding is a failure mode, not a win: the Git-only agent confabulated a coherent, well-sourced, wrong answer ten times out of ten.** On the deepest-history question (the design history of an autoscaler) it "produced a plausible but wrong adjacent story in all ten runs. It found real commits, real PRs, and a coherent narrative, all about the wrong thing." The search agent went 10/10 in **35 seconds against a 407s median**. That is worth more than the aggregate: an agent reconstructing history from artifacts alone does not fail loudly, it fails *fluently* — and seven of the nine tasks tied at 10/10, so the aggregate gap would have looked like noise if this one question hadn't been in the set. The second-order finding is nearly as good: the agent **reached for search unprompted in 90/90 runs and made it the first tool call in 66**, which suggests the model can tell when a question is a "why" question.

- **Two architectural choices are worth stealing regardless of the vendor.** First, **ranking in tiers rather than fusing scores**: because "BM25 scores and cosine similarities are not comparable numbers," results are bucketed into full-phrase matches, then keyword matches (stemming/tokenizing the natural-language query), then vector-only matches, leaving ~200 candidates for a reranker that orders "by relevance rather than retrieval score." That is a different answer from the RRF-plus-cross-encoder pipeline in [[harness-1-search-infra|Harness-1's search infrastructure]] and from [[Cerebras built an internal knowledge base as a hybrid-retrieval system fusing lexical, vector, IDF, and age-decay over one Postgres embeddings table|Cerebras fusing four scorers via RRF]] — tiering asserts a lexical prior instead of trying to normalize incomparable scales. Second, **incremental transcript indexing keyed to checkpoints**: each checkpoint embeds only the slice new since the previous one, so "a three-hour session doesn't get re-embedded from the top every time the agent commits," chunked at ~700 tokens with one turn of overlap. [[SmithDB builds a byte-budgeted FST inverted index to enable 400ms full-text search over enormous agent traces in object storage|SmithDB solves the same transcript-scale problem]] with an FST inverted index instead of embeddings.

- **The federation design has a clean invariant, and permissions fall out of the data model rather than being bolted on.** Each region runs the full stack — its own indexers, region-pinned vector namespaces, its own embedding, reranking, and code-search engine — and a query fans out in parallel while a thin merge layer combines slices: "**the query goes to the data, not the other way around.**" Mirrored repos still have exactly one *home*, so a broad query never returns duplicates and there's no ambiguity about which copy is authoritative. Degradation is explicit — a slow region yields partial results **flagged incomplete** rather than a hung query or a silently truncated answer, which is the correct behavior and rarer than it should be. On access: "a repo you can't see is a namespace that never gets queried" — permission scoping as a property of the index topology, the same move [[Glean argues enterprise indexing is necessary but not sufficient - the real unit is a unified permission-aware index inside a system of context of indexes, graphs, memory, connectors, and tools|Glean argues for with its permission-aware index]]. The split of literal bytes from a searchable derived plane also mirrors [[MongoDB's VFS for LangChain Deep Agents redefines grep as server-side hybrid search, splitting file bytes in S3 from a searchable chunk plane in Atlas|MongoDB's two-plane VFS]], and keeping a literal, symbol-aware code path beside the semantic one answers [[context agents should navigate heterogeneous sources natively instead of flattening everything into vector search|the objection to flattening everything into one embedding space]].

- **Caveats: the vendor states the main one himself, and the baseline is the part to interrogate.** He flags task-selection bias — the questions target Entire's own org, and their commit messages are unusually detailed "largely because agents write them," which *strengthens* the Git baseline; his read is that "for most teams, the gap may be wider," though the same bias could equally mean the questions were ones search happens to answer well. Held against [[benchmarks are measurement instruments not question collections - regulargio's first-principles guide to claims, graders, coverage, and uncertainty|the measurement-instrument standard]]: nine tasks with 7/9 saturated at 10/10 means one question carries the entire accuracy delta, so the honest claim is the efficiency halving plus one demonstrated deep-history failure, not "+11 correct." To their considerable credit the full harness, tasks, grading methodology and raw per-run results are published at [`entireio/searchmark`](https://github.com/entireio/searchmark), designed to be rerun against your own org — which is exactly what would settle it. Two open questions the post doesn't touch: whether a better-instructed baseline closes the gap ([[agentic search with grep and full-file loading replaces RAG when context windows are large enough|grep plus full-file loading is a strong steelman]]), and the governance question of a vendor holding every session transcript ([[agent trace data should live in your data lake not a 30-day SaaS retention window|traces arguably belong in your own lake]]). Note also that ~100ms median code-search latency is less decisive than it sounds, since [[agents are the perfect slow searchers because LLM inference cost dominates per-query retrieval latency|inference cost dominates per-query retrieval latency]] — the same lesson their own pgr post reached, where a 9x faster search moved wall clock by 4%.

## External Resources

- Source: [Introducing Agentic Search for Code and Context](https://entire.io/blog/introducing-agentic-search-for-code-and-context) — Evis Drenova, Entire blog (Changelog), 3 Sep 2026
- **Benchmark: [entireio/searchmark](https://github.com/entireio/searchmark)** — full harness, tasks, grading methodology, and raw per-run results; designed to be rerun against your own org
- Earlier post already in the vault: [Improving agentic search in coding agents](https://entire.io/blog/improving-agentic-search-in-coding-agents) → [[Entire's pgr proves definition-first ranking helps coding agents more than faster ripgrep]]
- Tooling: [Entire CLI](https://github.com/entireio/cli) (`entire search`, `--code`, `--json`) · [agent skill](https://github.com/entireio/skills) (`/search`) · [CLI install](https://docs.entire.io/cli/installation) · enable with `entire enable --search-skill`
- Infrastructure: [turbopuffer](https://turbopuffer.com/) (one namespace per repo, region-pinned) · [BM25](https://en.wikipedia.org/wiki/Okapi_BM25) · [repo mirrors across regions](https://docs.entire.io/guides/repositories/mirrors)

## Original Content

> [!quote]- Full blog post (Evis Drenova, "Introducing Agentic Search for Code and Context", Entire, 3 Sep 2026)
> For most of software history, code search meant finding a symbol, string, or file. That worked when a developer knew which repository to open and which keywords to try.
>
> Agents changed the requirements. To work effectively, an agent needs to understand how a shared package is used across an organization, which pattern a team settled on, and why a change landed. That context sits in repositories, commits, and past sessions.
>
> Finding it used to mean cloning repositories, grepping files, and reading through matches one at a time. That process is slow, token-intensive, and skips the history that produced the code.
>
> Today we're launching Agentic Search to replace that loop with a single API your agent can query across every repository it can access. Each result returns the matching code and commit, plus that commit's checkpoint: the session, the transcript, and the prompt behind the change.
>
> We benchmarked search against the hardest question an agent can be asked: "Why is our code like this?" Across nine real engineering-history questions, an agent with access to the full Git history and the GitHub CLI answered 70 of 90 runs correctly. The same agent with search answered 81 of 90, using less than half the tokens and half the steps.
>
> ## One API: Two Types of Search
>
> In agentic systems, "search" serves two separate needs, so we built one system to serve both.
>
> Semantic search answers what happened and why. It enables agents to search your sessions, commits, checkpoints, and transcripts, matching meaning and tolerating imprecise words. Search "rate limit retry logic" and it finds the session where an agent wrote it, even if the word "retry" never appears.
>
> Code search answers where an exact line of code lives. It's a literal, symbol-aware search over source, with definitions and references, so a query for a config key returns that config key, every time, or it's broken.
>
> Agents have full control over both search types and can filter to individual repos or search everything they have access to.
>
> ## Under the Hood
>
> ### Indexing: From Push to Searchable
>
> *[Editor's note: an animated eight-step diagram (`01 / PUSH` → `EMBED`) renders here, walking a push through the indexing pipeline. It is a client-side component with no static form; the prose below describes the same sequence in full.]*
>
> The same repo activity stream that powers Entire feeds directly into the search index. Every push emits a ref event onto a durable message stream, and a fleet of indexer workers consume that event and determine what's changed.
>
> Indexing is incremental. A long session produces many checkpoints, and each checkpoint indexes only the slice of transcript that's new since the previous one. A three-hour session doesn't get re-embedded from the top every time the agent commits. The stripped increment is chunked into roughly 700 tokens with one turn of overlap, embedded, and upserted alongside the committed files. A query returns the chunk that matches, not the full transcript.
>
> Documents live in [turbopuffer](https://turbopuffer.com/) with one namespace per repository, stored in the account's native region. A query only ever fans out to the namespaces it can access. A repo you can't see is a namespace that never gets queried.
>
> In a steady state, pushed commits become searchable within seconds.
>
> ### Ranking, Recall, and Relevance
>
> For each repo in scope, two retrieval queries run concurrently: a full-text query ([BM25](https://en.wikipedia.org/wiki/Okapi_BM25), with a weighted formula for titles, metadata, and body text) and a vector query against the embeddings. The union of the two is the candidate set.
>
> Because BM25 scores and cosine similarities are not comparable numbers, we rank results in three tiers:
>
> - **Full-phrase matches:** The exact query phrase appears verbatim. We rank these highest, because if you know what you're searching for, you probably want that exact thing returned.
>
> - **Keyword matches:** Some query words appear in some form. We use stemming and tokenization to pull keywords out of the natural language query. Search "how did we implement jwt auth?" and documents containing "auth" and "jwt" are likely decent matches.
>
> - **Vector-only matches:** No lexical overlap appears at all. The embedding alone, via the cosine similarity score from ANN, thinks it's related. In our testing, the highest scoring cosine matches usually had matching keywords too, so they tend to rank well.
>
> Tiering leaves roughly 200 candidates that scored well on recall. Our reranking model then orders them by relevance rather than retrieval score.
>
> ### Code Search: Exact by Design
>
> A performant indexing pipeline powers code search. On push, it fetches the repo, builds a custom index, and stores it in object storage. It typically updates the index incrementally rather than rebuilding it, and caches hot repos locally for fast reads. Code search supports literal and regex queries plus symbol extraction for jump-to-definition and find-references, within a file and across a repo.
>
> Median query latency is around 100 milliseconds across thousands of indexed repos. When an agent asks, "where is `MAX_QUERY_FANOUT_CONCURRENCY` set?" the answer returns before the model has finished its next token.
>
> ## One Query, Every Region
>
> *Federated search, step 03 of the animation: one query fans out to US-EAST, EU-CENTRAL and AP-SOUTH, each marked "DATA STAYS HERE" and holding different repos — "Each region searches only the repos that it homes."*
> ![[entire-agentic-search-001.png]]
>
> Entire stores your repos in the region you choose, available today in EU, US, India and Australia. You can [mirror](https://docs.entire.io/guides/repositories/mirrors) the same repo across regions so teams and agents work against nearby copies, or keep different repos in different jurisdictions when data residency matters. This keeps access fast without forcing all your code into one global location.
>
> Search inherits that geography completely. Each region runs the full stack: its own indexers, its own vector namespaces on a region-pinned endpoint, its own embedding and reranking, and its own code-search engine. When a repo lives in Frankfurt, everything derived from it lives in Frankfurt too: the transcript chunks, the embeddings, and the code search index. Mirror a repo to three regions and it still has exactly one home, so a broad query never returns the same result twice, and there's never ambiguity about which copy is authoritative for search.
>
> At query time, this globally distributed system still behaves like one search box. A single query fans out in parallel to every region where you have data. Each region resolves which of your repos it homes, searches them locally, and returns the result. A thin merge layer combines the slices into one list. What crosses a regional boundary is the query and the ranked results you're authorized to see; the corpus never moves. The query goes to the data, not the other way around.
>
> If a region is slow or unreachable, you get the other regions' results with the response flagged as incomplete, rather than a hung query or a silently partial answer.
>
> ## Benchmark: “Why Is Our Code Like This?”
>
> The questions that cost engineering teams the most time are questions about why: "why is this config set this way?" and "what incident produced this change?" Those answers live in agent sessions.
>
> We pulled nine real engineering-history questions asked inside our own organization, including "why does the rate limiter count inputs instead of requests?", and ran each one ten times through two identical headless Claude agents. Both agents got full-history clones of every relevant repo, `git log`, `git log -S`, `git show`, and the GitHub CLI for PRs and issues. One also got Entire's agentic search.
>
> *The full searchmark table — note the rows the prose omits: tokens per question, cost per question, agent steps, and time-to-answer on the deepest-history question.*
> ![[entire-agentic-search-002.png]]
>
> | Scenario | No search | Search |
> | --- | --- | --- |
> | **Across all 90 runs** | | |
> | Correct answers (higher is better) | 70/90 | **81/90** |
> | Tokens per question (mean, lower is better) | 547K | **262K** |
> | Cost per question (mean, lower is better) | $0.38 | **$0.23** |
> | Agent steps (mean, lower is better) | 14 | **7** |
> | **Deepest-history question** | | |
> | Correct answers | 0/10 | **10/10** |
> | Time to answer (median) | 407s | **35s** |
> | **Unprompted tool use** | | |
> | Reached for search on its own (of 90 runs) | — | **90/90** |
> | Search as the very first tool call (of 90 runs) | — | **66/90** |
>
> *(Table transcribed from the figure: 9 questions · 10 runs each · 180 runs total.)*
>
> Three things stand out.
>
> First, the gap concentrates where history runs deep. Seven of the nine tasks tie at 10/10. On the hardest question, the design history of an autoscaler, the Git-history agent produced a plausible but wrong adjacent story in all ten runs. It found real commits, real PRs, and a coherent narrative, all about the wrong thing. The search agent found the session where the decision was made and went 10/10 in 35 seconds.
>
> Second, agents reach for search on their own. The search-arm agent used `entire search` unprompted in 90 of 90 runs, and as its first tool call in 66 of them. When the question is "why," the answer lives in sessions and checkpoints rather than in the code, and the agent can tell.
>
> Third, a methodological caveat applies. These questions target our own organization's history, so task-selection bias applies. Our commit messages are detailed, largely because agents write them, which strengthens the Git-history baseline. For most teams, the gap may be wider.
>
> We published the full harness, tasks, grading methodology, and raw per-run results at [entireio/searchmark](https://github.com/entireio/searchmark), and designed the harness so you can rerun it against your own org.
>
> ## Try It
>
> The fastest way to use search is to install the [Entire CLI](https://docs.entire.io/cli/installation) and the search skill. Run `entire enable --search-skill` in your repo.
>
> - [CLI](https://github.com/entireio/cli): `entire search` provides semantic search across your sessions, commits, checkpoints, and transcripts. Add `--code` to include code matches. Use interactive mode for a tabbed view, or `--json` for structured output agents can read. Scope any search to one repo, several repos, or everything you have access to.
>
> - **Web:** [entire.io](https://entire.io) also provides search in the browser. Click **Search** in the left-hand menu. Code search includes definitions and references, both within a file and across the repo.
>
> - [Agent skill](https://github.com/entireio/skills): `/search` teaches your agent when and how to use the CLI, so it reaches for search instead of cloning repos and grepping files.
>
> We are building Entire to be the system of record for agentic coding. In the coming weeks, we'll keep shipping tools that let agents query code, sessions, and commits together, making Entire one API for your code and the work that produced it.
