---
created: 2025-07-27
description: Traditional RAG with chunking, embeddings, and reranking was a workaround for small context windows. With 200K-2M token windows and agent-based navigation using grep and filesystem access, direct file loading and reference-following outperforms retrieval pipelines.
source: https://x.com/nicbstme/status/2016251900249964865
type: framework
---

# Agentic search with grep and full-file loading replaces RAG when context windows are large enough

## Key Takeaways

The core thesis is that traditional RAG (chunking → embedding → hybrid search → reranking) was a clever workaround for the context-poor era (GPT-4's 8K tokens), and is being displaced by agentic search — agents that navigate filesystems directly using grep, glob, and full-file loading within large context windows (200K-2M tokens). Claude Code proved this: it outperformed Cursor's embedding-based RAG not because it had better retrieval, but because it had no RAG at all.

The RAG pipeline has a cascading failure problem where each stage compounds errors from the previous one. Chunking destroys document relationships (revenue recognition policies split across 3 chunks, table headers separated from data). Embeddings fail on domain terminology ("revenue recognition" vs "revenue growth" get confused) and numbers ("$45.2M" and "$45,200,000" get different embeddings). Hybrid search requires managing Elasticsearch clusters (128-256GB RAM minimum, 48-72 hour re-indexing on schema changes). Reranking adds 300-2000ms latency per query. Even with sophisticated chunking at Fintool (hierarchical structure preservation, table integrity, cross-reference preservation), the fundamental problem remains: working with fragments instead of complete documents.

The specific failure case is devastating: a litigation exposure query returns $500M from the Legal Proceedings section, but misses $700M in Contingencies, $1B in Subsequent Events, $800M in indemnification obligations, and $2B in footnotes where "probable" appears instead of "litigation." Actual exposure: $5.1B vs RAG's $500M — a 10x miss. This kind of cross-document, cross-section reasoning is exactly what [[OpenAI internal data agent succeeds through six layers of context not model capability alone]] addresses with layered context rather than flat retrieval.

Claude Code's approach is radically simple: ripgrep for regex search (no indexing, instant, $0 infrastructure), glob for file discovery, and task agents for multi-step investigation. New documents are searchable the moment they hit the filesystem. The agent follows references naturally ("See Note 12" → Note 12 → "excluding discontinued operations (Note 23)" → Note 23), building cumulative understanding across documents. A benchmark by @RLanceMartin showed a simple TXT file with URLs and descriptions outperforms complex RAG.

The context window trajectory makes this viable: GPT-4 had 8K tokens (2023), Claude Sonnet 4 has 200K (~700 pages), Gemini 2.5 has 1M (~3,000 pages), Grok 4-fast has 2M (~6,000 pages). At 2M tokens you can fit an entire year of SEC filings. Equally important, attention mechanisms are improving — LLMs maintain coherence across massive windows without getting lost.

The future direction is desktop agents accessing local filesystems directly (like Claude Cowork running in an isolated VM via Apple's Virtualization Framework), not cloud-hosted vector databases. The agent reads files, creates documents, reorganizes based on content — no indexing, chunking, or embedding. This connects to the [[context tax compounds through cache misses bloated tools and unbudgeted output tokens]] insight that storing tool outputs in the filesystem reduced Cursor's agent tokens by 46.9%.

RAG still has a role as one search tool among many for searches across thousands of documents or decades of filings — initial broad search via hybrid retrieval, then agent loads full documents for top results. But agents will always prefer grep and reading whole files when context allows. The [[progressive disclosure filters force agent selectivity over what enters context]] pattern applies: the agent decides what to load based on initial signals, not a retrieval pipeline's similarity scores.

The bitter lesson: grep (invented 1973) outperforms trillion-parameter embedding models when paired with an intelligent navigator. Simplicity wins.

## External Resources

- [Nicolas Bustamante's blog: LLMs Eat Scaffolding for Breakfast](https://www.nicolasbustamante.com/p/llms-eat-scaffolding-for-breakfast) — companion article on LLMs consuming RAG infrastructure
- [Vibe Code Benchmark by @RLanceMartin](https://rlancemartin.github.io/2025/04/03/vibe-code/) — simple TXT files outperforming complex RAG
- [Claude Cowork by Felix Rieseberg](https://x.com/felixrieseberg) — desktop agent running in isolated VM with local filesystem access
- [Fintool](https://fintool.com) — AI financial research platform built by the author, transitioning from RAG to agentic search
- [Nicolas Bustamante on cloud agent sandboxes](https://x.com/nicbstme/status/2015174818497437834) — state of the art: agents running sandboxes with mounted filesystems

## Original Content

> [!quote]- Source Material
> 
> @nicbstme (Nicolas Bustamante):
> Article: The RAG Obituary: Killed by Agents, Buried by Context Windows
> 
> As I wrote in Oct 2025, after three years of building, optimizing, and scaling LLMs with retrieval-augmented generation (RAG) systems, I believe we’re witnessing the twilight of traditional RAG-based architectures especially ones relying on embeddings. As context windows explode and agent-based architectures mature, my controversial opinion is that the current RAG infrastructure we spent so much time building and optimizing is on the decline.
> 
> I’ve been working in AI and search for a decade. First building Doctrine, the largest European legal search engine and now building @fintool an AI-powered financial research platform that helps institutional investors analyze companies, screen stocks, and make investment decisions.
> 
> The Rise of Retrieval-Augmented Generation
> 
> In late 2022, ChatGPT took the world by storm. People started endless conversations, delegating crucial work only to realize that the underlying model, GPT-3.5 could only handle 4,096 tokens... roughly six pages of text!
> 
> The AI world faced a fundamental problem: how do you make an intelligent system work with knowledge bases that are orders of magnitude larger than what it can read at once?
> 
> The answer became Retrieval-Augmented Generation (RAG), an architectural pattern that would dominate AI for the next three years.
> 
> ## The Mathematical Reality of Early LLMs
> 
> GPT-3.5 could handle 4,096 token and the next model GPT-4 doubled it to 8,192 tokens, about twelve pages. This wasn’t just inconvenient; it was architecturally devastating.
> 
> Consider the numbers: A single SEC 10-K filing contains approximately 51,000 tokens (130+ pages).
> 
> With 8,192 tokens, you could see less than 16% of a 10-K filing. It’s like reading a financial report through a keyhole!
> 
> ## The RAG Architecture: A Technical Deep Dive
> 
> RAG emerged as an elegant solution borrowed directly from search engines. Just as Google displays 10 blue links with relevant snippets for your query, RAG retrieves the most pertinent document fragments and feeds them to the LLM for synthesis.
> 
> The core idea is beautifully simple: if you can’t fit everything in context, find the most relevant pieces and use those. It turns LLMs into sophisticated search result summarizers.
> 
> Basically, LLMs can’t read the whole book but they can know who dies at the end; convenient!
> 
> ## The Chunking Challenge
> 
> Long documents need to be chunked into pieces and it’s when problems start. Those digestible pieces are typically 400-1,000 tokens each which is basically 300-750 words.
> 
> The problem? It isn’t as simple as cutting every 500 words.
> 
> Consider chunking a typical SEC 10-K annual report. The document has a complex hierarchical structure:
> 
> - Item 1: Business Overview (10-15 pages)
> 
> - Item 1A: Risk Factors (20-30 pages)
> 
> - Item 7: Management’s Discussion and Analysis (30-40 pages)
> 
> - Item 8: Financial Statements (40-50 pages)
> 
> After naive chunking at 500 tokens, critical information gets scattered:
> 
> - Revenue recognition policies split across 3 chunks
> 
> - A risk factor explanation broken mid-sentence
> 
> - Financial table headers separated from their data
> 
> - MD&A narrative divorced from the numbers it’s discussing
> 
> If you search for “revenue growth drivers,” you might get a chunk mentioning growth but miss the actual numerical data in a different chunk, or the strategic context from MD&A in yet another chunk!
> 
> At Fintool, we’ve developed sophisticated chunking strategies that go beyond naive text splitting:
> 
> - Hierarchical Structure Preservation: We maintain the nested structure from Item 1 (Business) down to sub-sections like geographic segments, creating a tree-like document representation
> 
> - Table Integrity: Financial tables are never split like income statements, balance sheets, and cash flow statements remain atomic units with headers and data together
> 
> - Cross-Reference Preservation: We maintain links between narrative sections and their corresponding financial data, preserving the “See Note X” relationships
> 
> - Temporal Coherence: Year-over-year comparisons and multi-period analyses stay together as single chunks
> 
> - Footnote Association: Footnotes remain connected to their referenced items through metadata linking
> 
> Each chunk at Fintool is enriched with extensive metadata:
> 
> - Filing type (10-K, 10-Q, 8-K)
> 
> - Fiscal period and reporting date
> 
> - Section hierarchy (Item 7 > Liquidity > Cash Position)
> 
> - Table identifiers and types
> 
> - Cross-reference mappings
> 
> - Company identifiers (CIK, ticker)
> 
> - Industry classification codes
> 
> > This allows for more accurate retrieval but even our intelligent chunking can’t solve the fundamental problem: we’re still working with fragments instead of complete documents!
> 
> Once you have the chunks, you need a way to search them. One way is to embed your chunks.
> 
> ## The Embedding and Retrieval Pipeline
> 
> Each chunk is converted into a high‑dimensional vector (typically 1,536 dimensions in most embedding models). These vectors live in a space where, theoretically, similar concepts are close together.
> 
> When a user asks a question, that question also becomes a vector. The system finds the chunks whose vectors are closest to the query vector using cosine similarity.
> 
> > It’s elegant in theory and in practice, it’s a nightmare of edge cases.
> 
> Embedding models are trained on general text and struggle with specific terminologies. They find similarities but they can’t distinguish between “revenue recognition” (accounting policy) and “revenue growth” (business performance).
> 
> Consider that example: Query: “What is the company’s litigation exposure?
> 
> RAG searches for “litigation” and returns 50 chunks:
> 
> - Chunks 1-10: Various mentions of “litigation” in boilerplate risk factors
> 
> - Chunks 11-20: Historical cases from 2019 (already settled)
> 
> - Chunks 21-30: Forward-looking safe harbor statements
> 
> - Chunks 31-40: Duplicate descriptions from different sections
> 
> - Chunks 41-50: Generic “we may face litigation” warnings
> 
> What RAG Reports: $500M in litigation (from Legal Proceedings section)
> 
> What’s Actually There:
> 
> - $500M in Legal Proceedings (Item 3)
> 
> - $700M in Contingencies note (”not material individually”)
> 
> - $1B new class action in Subsequent Events
> 
> - $800M indemnification obligations (different section)
> 
> - $2B probable losses in footnotes (keyword “probable” not “litigation”)
> 
> The actual Exposure is $5.1B. 10x what RAG found. Oupsy! By late 2023, most builders realized pure vector search wasn’t enough.
> 
> ## Hybrid Search: The Complexity That Actually Works
> 
> Enter hybrid search: combine semantic search (embeddings) with the traditional keyword search (BM25). This is where things get interesting.
> 
> BM25 (Best Matching 25) is a probabilistic retrieval model that excels at exact term matching. Unlike embeddings, BM25:
> 
> - Rewards Exact Matches: When you search for “EBITDA,” you get documents with “EBITDA,” not “operating income” or “earnings”
> 
> - Handles Rare Terms Better: Financial jargon like “CECL” (Current Expected Credit Losses) or “ASC 606” gets proper weight
> 
> - Document Length Normalization: Doesn’t penalize longer documents
> 
> - Term Frequency Saturation: Multiple mentions of “revenue” don’t overshadow other important terms
> 
> At Fintool, we’ve built a sophisticated hybrid search system:
> 
> 1. Parallel Processing: We run semantic and keyword searches simultaneously
> 
> 2. Dynamic Weighting: Our system adjusts weights based on query characteristics:
> 
> - Specific financial metrics? BM25 gets 70% weight
> 
> - Conceptual questions? Embeddings get 60% weight
> 
> - Mixed queries? 50/50 split with result analysis
> 
> 3. Score Normalization: Different scoring scales are normalized using:
> 
> - Min-max scaling for BM25 scores
> 
> - Cosine similarity already normalized for embeddings
> 
> - Z-score normalization for outlier handling
> 
> So at the end the embeddings search and the keywords search retrieve chunks and the search engine combines them using Reciprocal Rank Fusion. RRF merges rankings so items that consistently appear near the top across systems float higher, even if no system put them at #1!
> 
> So now you think it’s done right? But hell no!
> 
> ## The Reranking Bottleneck: RAG’s Dirty Secret
> 
> Here’s what nobody talks about: even after all that retrieval work, you’re not done. You need to rerank the chunks one more time to get a good retrieval and it’s not easy. Rerankers are ML models that take the search results and reorder them by relevance to your specific query limiting the number of chunks sent to the LLM.
> 
> Not only LLMs are context poor, they also struggle when dealing with too much information. It’s vital to reduce the number of chunks sent to the LLM for the final answer.
> 
> The Reranking Pipeline:
> 
> 1. Initial search retrieval with embeddings + keywords gets you 100-200 chunks
> 
> 2. Reranker ranks the top 10
> 
> 3. Top 10 are fed to the LLM to answer the question
> 
> Here is the challenge with reranking:
> 
> - Latency Explosion: Rerank adds between 300-2000ms per query. Ouch.
> 
> - Cost Multiplication: it adds significant extra cost to every query. For instance, Cohere Rerank 3.5 costs $2.00 per 1,000 search units, making reranking expensive.
> 
> - Context Limits: Rerankers typically handle few chunks (Cohere Rerank supports only 4096 tokens), so if you need to re-rank more than that, you have to split it into different parallel API calls and merge them!
> 
> - Another Model to Manage: One more API, one more failure point
> 
> Re-rank is one more step in a complex pipeline.
> 
> ## The Infrastructure Burden of Traditional RAG
> 
> What I find difficult with RAG is what I call the “cascading failure problem”.
> 
> 1. Chunking can fail (split tables) or be too slow (especially when you have to ingest and chunk gigabytes of data in real-time)
> 
> 2. Embedding can fail (wrong similarity)
> 
> 3. BM25 can fail (term mismatch)
> 
> 4. Hybrid fusion can fail (bad weights)
> 
> 5. Reranking can fail (wrong priorities)
> 
> Each stage compounds the errors of the previous stage. Beyond the complexity of hybrid search itself, there’s an infrastructure burden that’s rarely discussed.
> 
> Running production Elasticsearch is not easy. You’re looking at maintaining TB+ of indexed data for comprehensive document coverage, which requires 128-256GB RAM minimum just to get decent performance.
> 
> And the real nightmare comes with re-indexing. Every schema change forces a full re-indexing that takes 48-72 hours for large datasets. On top of that, you’re constantly dealing with cluster management, sharding strategies, index optimization, cache tuning, backup and disaster recovery, and version upgrades that regularly include breaking changes.
> 
> ## The Fundamental Limitations of RAG for Complex Documents
> 
> Here are some structural limitations:
> 
> 1. Context Fragmentation
> 
> - Long documents are interconnected webs, not independent paragraphs
> 
> - A single question might require information from 20+ documents
> 
> - Chunking destroys these relationships permanently
> 
> 2. Semantic Search Fails on Numbers
> 
> - “$45.2M” and “$45,200,000” have different embeddings
> 
> - “Revenue increased 10%” and “Revenue grew by a tenth” rank differently
> 
> - Tables full of numbers have poor semantic representations
> 
> 3. No Causal Understanding
> 
> - RAG can’t follow “See Note 12” → Note 12 → Schedule K
> 
> - Can’t understand that discontinued operations affect continuing operations
> 
> - Can’t trace how one financial item impacts another
> 
> 4. The Vocabulary Mismatch Problem
> 
> - Companies use different terms for the same concept
> 
> - “Adjusted EBITDA” vs “Operating Income Before Special Items”
> 
> 5. Temporal Blindness
> 
> - Can’t distinguish Q3 2024 from Q3 2023 reliably
> 
> - Mixes current period with prior period comparisons
> 
> - No understanding of fiscal year boundaries
> 
> These aren’t minor issues. They’re fundamental limitations of the retrieval paradigm.
> 
> Three months ago I stumbled on an innovation on retrievial that blew my mind
> 
> ## The Emergence of Agentic Search - A New Paradigm
> 
> In May 2025, Anthropic released Claude Code, an AI coding agent that works in the terminal. At first, I was surprised by the form factor. A terminal? Are we back in 1980? no UI?
> 
> Back then, I was using Cursor, a product that excelled at traditional RAG especially with embeddings. I gave it access to my codebase to embed my files and Cursor ran a search accross my codebase before answering my query. Life was good. But when testing Claude Code, one thing stood out:
> 
> > It was better and faster and not because their RAG was better but because there was no RAG.
> 
> How Claude Code Search Works
> 
> Instead of a complex pipeline of chunking, embedding, and searching, Claude Code uses direct filesystem tools:
> 
> 1. Grep (Ripgrep)
> 
> - Lightning-fast regex search through file contents
> 
> - No indexing required. It searches live files instantly
> 
> - Full regex support for precise pattern matching
> 
> - Can filter by file type or use glob patterns
> 
> - Returns exact matches with context lines
> 
> 2. Glob
> 
> - Direct file discovery by name patterns
> 
> -
> 
> files like `**/*.py` or `src/**/*.ts` instantly
> 
> - Returns files sorted by modification time (recency bias)
> 
> - Zero overhead—just filesystem traversal
> 
> 3. Task Agents
> 
> - Autonomous multi-step exploration
> 
> - Handle complex queries requiring investigation
> 
> - Combine multiple search strategies adaptively
> 
> - Build understanding incrementally
> 
> - Self-correct based on findings
> 
> By the way, Grep was invented in 1973. It’s so... primitive. And that’s the genius of it!!
> 
> Claude Code doesn’t retrieve. It investigates:
> 
> - Runs multiple searches in parallel (Grep + Glob simultaneously)
> 
> - Starts broad, then narrows based on discoveries
> 
> - Follows references and dependencies naturally
> 
> - No embeddings, no similarity scores, no reranking
> 
> It’s simple, it’s fast and it’s based on a new assumption that LLMs will go from context poor to context rich.
> 
> Claude Code proved that with sufficient context and intelligent navigation, you don’t need RAG at all. The agent can:
> 
> - Load entire files or modules directly
> 
> - Follow cross-references in real-time
> 
> - Understand structure and relationships
> 
> - Maintain complete context throughout investigation
> 
> As you can see in this quick [benchmark](https://rlancemartin.github.io/2025/04/03/vibe-code/) by @RLanceMartin, a simple TXT file with urls+description outperforms complex RAG. Ouch. That’s a paradigm shift; [LLMs eat the RAG scaffolding for breakfast](https://www.nicolasbustamante.com/p/llms-eat-scaffolding-for-breakfast).
> 
> This isn’t just better than RAG. It’s a fundamentally different paradigm. And what works for code can work for any long documents that are not coding files.
> 
> ## The Context Revolution: From Scarcity to Abundance
> 
> The context window explosion made Claude Code possible:
> 
> 2022-2025 Context-Poor Era:
> 
> - GPT-4: 8K tokens (~12 pages)
> 
> - GPT-4-32k: 32K tokens (~50 pages)
> 
> 2025 and beyond Context Revolution:
> 
> - Claude Sonnet 4: 200k tokens (~700 pages)
> 
> - Gemini 2.5: 1M tokens (~3,000 pages)
> 
> - Grok 4-fast: 2M tokens (~6,000 pages)
> 
> At 2M tokens, you can fit an entire year of SEC filings for most companies.
> 
> The trajectory is even more dramatic: we’re likely heading toward 10M+ context windows by 2027, with Sam Altman hinting at billions of context tokens on the horizon. This represents a fundamental shift in how AI systems process information. Equally important, attention mechanisms are rapidly improving.
> 
> > LLMs are becoming far better at maintaining coherence and focus across massive context windows without getting “lost” in the noise.
> 
> ## The Claude Code Insight: Why Context Changes Everything
> 
> Claude Code demonstrated that with enough context, search becomes navigation:
> 
> - No need to retrieve fragments when you can load complete files
> 
> - No need for similarity when you can use exact matches
> 
> - No need for reranking when you follow logical paths
> 
> - No need for embeddings when you have direct access
> 
> It’s mind-blowing. LLMs are getting really good at agentic behaviors meaning they can organize their work into tasks to accomplish an objective.
> 
> Here’s what tools like ripgrep bring to the search table:
> 
> - No Setup: No index. No overhead. Just point and search.
> 
> - Instant Availability: New documents are searchable the moment they hit the filesystem (no indexing latency!)
> 
> - Zero Maintenance: No clusters to manage, no indices to optimize, no RAM to provision
> 
> - Blazing Fast: For a 100K line codebase, Elasticsearch needs minutes to index. Ripgrep searches it in milliseconds with zero prep.
> 
> - Cost: $0 infrastructure cost vs a lot of $$$ for Elasticsearch
> 
> So back to our previous example on SEC filings. An agent can SEC filing structure intrinsically:
> 
> - Hierarchical Awareness: Knows that Item 1A (Risk Factors) relates to Item 7 (MD&A)
> 
> - Cross-Reference Following: Automatically traces “See Note 12” references
> 
> - Multi-Document Coordination: Connects 10-K, 10-Q, 8-K, and proxy statements
> 
> - Temporal Analysis: Compares year-over-year changes systematically
> 
> For searches across thousands of companies or decades of filings, it might still use hybrid search, but now as a tool for agents:
> 
> - Initial broad search using hybrid retrieval
> 
> - Agent loads full documents for top results
> 
> - Deep analysis within full context
> 
> - Iterative refinement based on findings
> 
> My guess is traditional RAG is now a search tool among others and that agents will always prefer grep and reading the whole file because they are context rich and can handle long-running tasks.
> 
> Consider our $6.5B lease obligation question as an example:
> 
> Step 1: Find “lease” in main financial statements
> 
> → Discovers “See Note 12”
> 
> Step 2: Navigate to Note 12
> 
> → Finds “excluding discontinued operations (Note 23)”
> 
> Step 3: Check Note 23
> 
> → Discovers $2B additional obligations
> 
> Step 4: Cross-reference with MD&A
> 
> → Identifies management’s explanation and adjustments
> 
> Step 5: Search for “subsequent events”
> 
> → Finds post-balance sheet $500M lease termination
> 
> Final answer: $5B continuing + $2B discontinued - $500M terminated = $6.5B
> 
> The agent follows references like a human analyst would. No chunks. No embeddings. No reranking. Just intelligent navigation.
> 
> Basically, RAG is like a research assistant with perfect memory but no understanding:
> 
> - “Here are 50 passages that mention debt”
> 
> - Can’t tell you if debt is increasing or why
> 
> - Can’t connect debt to strategic changes
> 
> - Can’t identify hidden obligations
> 
> - Just retrieves text, doesn’t comprehend relationships
> 
> Agentic search is like a forensic accountant:
> 
> - Follows the money systematically
> 
> - Understands accounting relationships (assets = liabilities + equity)
> 
> - Identifies what’s missing or hidden
> 
> - Connects dots across time periods and documents
> 
> - Challenges management assertions with data
> 
> ## Why Agentic Search Represents the Future
> 
> 1. Increasing Document Complexity
> 
> - Documents are becoming longer and more interconnected
> 
> - Cross-references and external links are proliferating
> 
> - Multiple related documents need to be understood together
> 
> - Systems must follow complex trails of information
> 
> 2. Structured Data Integration
> 
> - More documents combine structured and unstructured data
> 
> - Tables, narratives, and metadata must be understood together
> 
> - Relationships matter more than isolated facts
> 
> - Context determines meaning
> 
> 3. Real-Time Requirements
> 
> - Information needs instant processing
> 
> - No time for re-indexing or embedding updates
> 
> - Dynamic document structures require adaptive approaches
> 
> - Live data demands live search
> 
> 4. Cross-Document Understanding
> 
> Modern analysis requires connecting multiple sources:
> 
> - Primary documents
> 
> - Supporting materials
> 
> - Historical versions
> 
> - Related filings
> 
> RAG treats each document independently. Agentic search builds cumulative understanding.
> 
> 5. Precision Over Similarity
> 
> - Exact information matters more than similar content
> 
> - Following references beats finding related text
> 
> - Structure and hierarchy provide crucial context
> 
> - Navigation beats retrieval
> 
> The evidence is becoming clear. While RAG served us well in the context-poor era, agentic search represents a fundamental evolution. The potential benefits of agentic search are compelling:
> 
> - Elimination of hallucinations from missing context
> 
> - Complete answers instead of fragments
> 
> - Faster insights through parallel exploration
> 
> - Higher accuracy through systematic navigation
> 
> - Massive infrastructure cost reduction
> 
> - Zero index maintenance overhead
> 
> The key insight? Complex document analysis (whether code, financial filings, or legal contracts) isn’t about finding similar text. It’s about understanding relationships, following references, and maintaining precision.
> 
> The combination of large context windows and intelligent navigation delivers what retrieval alone never could.
> 
> RAG was a clever workaround for a context-poor era. It helped us bridge the gap between tiny windows and massive documents, but it was always a band-aid. The future won’t be about splitting documents into fragments and juggling embeddings. It will be about agents that can navigate, reason, and hold entire corpora in working memory.
> 
> > The next decade of AI search will belong to systems that read and reason end-to-end. Retrieval isn’t dead but traditional RAG has just been demoted.
> 
> ## The Future: Desktop Agents and the Bitter Lesson of Simplicity
> 
> Today's state of the art is agents running sandboxes in the cloud with a mounted filesystem they can navigate ([see my article on the topic](https://x.com/nicbstme/status/2015174818497437834?s=20)). Manus and Claude ai are good examples of top notch applications in the field.
> 
> Tomorrow's paradigm is software running directly on your desktop that accesses your local filesystem.
> 
> For instance, @felixrieseberg's Claude Cowork runs inside an isolated virtual machine using Apple's Virtualization Framework with a custom Linux filesystem.
> 
> It reads files to understand context, creates new documents when needed, reorganizes existing ones based on content rather than arbitrary naming conventions. As you can see it doesn't index, chunk, or embed documents.
> 
> Some database vendors have obvious commercial interests in keeping the embedding/vector infrastructure relevant, but my guess is that it is not needed for most applications and it's clearly not where desktop app are going (but again, I can be wrong!)
> 
> Also regarding legal and compliance, the simplest approach will win.
> 
> This is the bitter lesson of agents today: simplicity wins. Grep invented in 1973 outperforms trillion-parameter embedding models when paired with an intelligent navigator. A filesystem mount beats a vector database. Direct file access beats similarity search. The most sophisticated RAG pipeline in the world cannot compete with an agent that simply reads the whole document and follows the references.
> 
> We are entering the post-retrieval age. The winners will not be the ones who maintain the biggest vector databases, but the ones who design the smartest agents to traverse abundant context and connect meaning across documents. In hindsight, RAG will look like training wheels. Useful, necessary, but temporary.
> date: Tue Jan 27 20:48:07 +0000 2026
> url: https://x.com/nicbstme/status/2016251900249964865
> ──────────────────────────────────────────────────
> 
> @theandrewsiah (Andrew Siah):
> @nicbstme cool post! curious, OCR takes time no? 
> 
> are you doing inference time OCR (i.e. let the agent decide what to OCR), or you OCR beforehand and let the agents grep the processed files?
> date: Tue Jan 27 21:12:47 +0000 2026
> url: https://x.com/theandrewsiah/status/2016258107320472016
> ──────────────────────────────────────────────────
> 
> @nicbstme (Nicolas Bustamante):
> @theandrewsiah We don’t OCR. We do HTML to markdown for filings. And otherwise LLM APIs can read PDF and images.
> date: Tue Jan 27 21:13:55 +0000 2026
> url: https://x.com/nicbstme/status/2016258390092374291
> ──────────────────────────────────────────────────
> 
> @gautier_md (gamarin):
> @nicbstme Ripgrep for small corpora maybe, for large ones you still need bm25 at least. 
> 
> But I do agree that agentic search is going to change the pipeline significantly.  Not sure that vector databases and rerankers will be worth the overhead anymore.
> date: Tue Jan 27 21:40:25 +0000 2026
> url: https://x.com/gautier_md/status/2016265060444766563
> ──────────────────────────────────────────────────
> 
> @nicbstme (Nicolas Bustamante):
> @gautier_md We do use bm25 for now. I think we might have a way to discard it too.
> date: Tue Jan 27 22:04:33 +0000 2026
> url: https://x.com/nicbstme/status/2016271134220812416
> ──────────────────────────────────────────────────
> 
> @Esteban_Puerta9 (Esteban Puerta):
> @nicbstme another banger
> date: Tue Jan 27 22:46:32 +0000 2026
> url: https://x.com/Esteban_Puerta9/status/2016281698732822879
> ──────────────────────────────────────────────────
> 
> @nicbstme (Nicolas Bustamante):
> @Esteban_Puerta9 Thank you! Be ready I ask my team to write more about what they have been up to for the past few months.
> date: Tue Jan 27 22:52:27 +0000 2026
> url: https://x.com/nicbstme/status/2016283186633048491
> ──────────────────────────────────────────────────
> 
> @peepoop888 (peepoop):
> @nicbstme Holy shit. Lemme go and rip out everything I did in the last 3 months
> date: Tue Jan 27 23:35:48 +0000 2026
> url: https://x.com/peepoop888/status/2016294096105861200
> ──────────────────────────────────────────────────
> 
> @SJMcDermott (Steve McDermott):
> @nicbstme This is awesome, thanks for posting
> date: Wed Jan 28 00:17:38 +0000 2026
> url: https://x.com/SJMcDermott/status/2016304625700205006
> ──────────────────────────────────────────────────
> 
> @matt_ambrogi (Matt Ambrogi):
> Purely grep based search does not work for searching even medium sized sets of documents. Requires semantic search for full recall.
> 
> Very easy to prove with an eval.
> 
> Only true when have lots of text based data, and the search should still be tool in agentic loop.
> https://t.co/RpwTijmDUw
> date: Wed Jan 28 02:10:51 +0000 2026
> url: https://x.com/matt_ambrogi/status/2016333116130918636
> ──────────────────────────────────────────────────
> 
> @theRealDTrain37 (David Trainer):
> @nicbstme Great article. Excellent article. 
> 
> https://t.co/226qo81nEz
> date: Wed Jan 28 03:02:57 +0000 2026
> url: https://x.com/theRealDTrain37/status/2016346230045954369
> ──────────────────────────────────────────────────
> 
> @selcukcemoglu (Selcuk Cemoglu):
> @nicbstme Very well written article. But still needs some challenging. @grok Review and challenge this article. Be critical but fair.
> date: Wed Jan 28 06:54:16 +0000 2026
> url: https://x.com/selcukcemoglu/status/2016404442115928416
> ──────────────────────────────────────────────────
> 
> @ethan_howdy (Ethan H):
> @nicbstme Thanks for your post. Big fan of fintool since earlier last year. Learnt a lot for your sharing, as we are also tackling unstructured financial datas in Vietnam.
> date: Wed Jan 28 07:10:12 +0000 2026
> url: https://x.com/ethan_howdy/status/2016408450033725609
> ──────────────────────────────────────────────────
> 
> @lejooon (Lukas):
> @nicbstme Pure ripgrep doesn’t work for thousands and millions of documents. You need some search still to let the agent be able to find which documents are relevant. I’m working on a graph with BM25 approach, think PageRank lite.
> date: Wed Jan 28 07:43:17 +0000 2026
> url: https://x.com/lejooon/status/2016416778482589983
> ──────────────────────────────────────────────────
> 
> @jeffreyhuber (Jeff Huber):
> @nicbstme are we really still doing this
> date: Wed Jan 28 08:00:31 +0000 2026
> url: https://x.com/jeffreyhuber/status/2016421112545202253
> ──────────────────────────────────────────────────
> 
> @nicoloboschi (Nicolò Boschi):
> Agentic search doesn't scale - it's fundamentally a broken model for large datasets
> https://t.co/gc5wBXLUW5
> 
> Although I agree RAG has evolved a lot to handle Agentic applications and I think it's about building the memory layer for agents (and it's what we're doing with Hindsight)
> >  QT @nicoloboschi:
> > Article: File-based agent memory: great demo, good luck in prod
> >  https://x.com/nicoloboschi/status/2012119323481940119
> date: Wed Jan 28 08:14:52 +0000 2026
> url: https://x.com/nicoloboschi/status/2016424725463937479
> ──────────────────────────────────────────────────
> 
> @GowthamRaj100 (Gowtham Raj):
> @nicbstme This is a fantastic post @nicbstme , any experiences or shortages with graphRAG
> date: Wed Jan 28 09:51:23 +0000 2026
> url: https://x.com/GowthamRaj100/status/2016449015299096783
> ──────────────────────────────────────────────────
> 
> @CSUnerd (CSU Nerd):
> @nicbstme Thanks gawd! Couldn't have come sooner
> date: Wed Jan 28 11:21:29 +0000 2026
> url: https://x.com/CSUnerd/status/2016471690549547319
> ──────────────────────────────────────────────────
> 
> @HugoooDias (Hugo Dias):
> @nicbstme Your post has a fundamental flaw. You start with RAG examples on normal documents and then discuss agentic search for coding. Agentic search for coding with access to glob and grep makes sense, but not for retrieving documents from databases.
> date: Wed Jan 28 11:23:39 +0000 2026
> url: https://x.com/HugoooDias/status/2016472236065010003
> ──────────────────────────────────────────────────
> 
> @ProdFindr (Prodfindr):
> @nicbstme RAG isn’t dead, it just moved up the stack. Agents still need grounded memory, but retrieval now looks more like dynamic tool/browse calls than static vector DBs. Curious which workloads you still see classic RAG winning on?
> date: Wed Jan 28 14:01:15 +0000 2026
> url: https://x.com/ProdFindr/status/2016511893792244111
> ──────────────────────────────────────────────────
> 
> @1ffuzzy (fuzzy):
> @nicbstme There is a sweet spot between agentic search &amp; rag like you allow the agent to search your vector database by its own query agentic rag maybe.
> date: Wed Jan 28 14:04:24 +0000 2026
> url: https://x.com/1ffuzzy/status/2016512688915128685
> ──────────────────────────────────────────────────
> 
> @JasonBeaudreau (Jason Beaudreau):
> @nicbstme Excellent article.
> date: Wed Jan 28 14:23:43 +0000 2026
> url: https://x.com/JasonBeaudreau/status/2016517549018489271
> ──────────────────────────────────────────────────
> 
> @vmiss33 (vmiss):
> @nicbstme Nice post.
> date: Wed Jan 28 14:27:21 +0000 2026
> url: https://x.com/vmiss33/status/2016518463590748187
> ──────────────────────────────────────────────────
> 
> @kidehen (Kingsley Uyi Idehen):
> Question:
> How about an extraction capability, packaged as a skill, that works as follows?
> 
> 1. Ontology-informed extraction — Extraction is guided by terms from an ontology (e.g., https://t.co/bmYm6I1GFh). For example, if the document is a financial report, extraction follows the structure of schema:FinancialReport, with similar adjustments for other document and entity types.
> 
> 2. Knowledge graph manifestation — A knowledge graph is produced in which literal values are placed in context through their associated attributes (via attribute values).
> 
> 3. Conversational interaction via knowledge graph — “Talking to the document” becomes talking to the knowledge graph, using a combination of text search, cosine similarity, and structured queries expressed in SQL, SPARQL, or GraphQL.
> 
> Here’s an example using the basic structure provided by terms from https://t.co/bmYm6I1GFh (note: you can use your preferred ontology or craft one specific to your needs):
> https://t.co/wntc0rCsgk
> 
> And here’s a high-level view derived from a SPARQL query rendered in HTML format:
> https://t.co/WhfjFFisGB — just click on an item of interest to explore.
> PHOTO: https://pbs.twimg.com/media/G_wUWQKWIAAbNhY.jpg
> PHOTO: https://pbs.twimg.com/media/G_wUwgEXMAAFcLp.jpg
> date: Wed Jan 28 14:39:00 +0000 2026
> url: https://x.com/kidehen/status/2016521395325280659
> ──────────────────────────────────────────────────
> 
> @MichaelCWoodle (Michael C Woodle):
> I’ve felt with this at my 9-5. I have 1000+ documents anywhere from 1 to 70+ pages with complex tables, schematics, etc.
> 
> I’ve spent the last 6 months trying to optimize a RAG pipeline.
> 
> It was easy to get it to about 80-90% accuracy but very hard to get it above this. 
> 
> But we recently got approved to use an old version of Codex and I’ve been testing it against my RAG pipeline and it’s doing okay. 
> 
> It’s doing okay and we are stuck using gpt-4o because of security/compliance pipeline.
> 
> gpt-4o is basically a decade old in terms of AI years 
> 
> So I think you are correct.
> 
> Something I’m experimenting with in the mean time for BM25 search is try giving that as a tool the AI can use. 
> 
> Same for the vector search you can just add it to their normal read, glob, grep, etc. 
> 
> I’m not 100% sure this is will increase performance but it’s interesting to play around with.
> date: Wed Jan 28 14:53:22 +0000 2026
> url: https://x.com/MichaelCWoodle/status/2016525010475655578
> ──────────────────────────────────────────────────
> 
> @niteshpant56 (Nitesh | नितेश):
> @nicbstme Very in line with I’ve been seeing. When building v1 of alkemy we tried hybrid search with graph to map relationships between docs. It worked but was rather slow. A better would be relationships and grep and then reading entire files using sub agents
> date: Wed Jan 28 14:53:28 +0000 2026
> url: https://x.com/niteshpant56/status/2016525037294014879
> ──────────────────────────────────────────────────
> 
> @nicbstme (Nicolas Bustamante):
> @jeffreyhuber I need the engagement (also I added new sections to the article + infographics) because I'm launching an onlyfan to prepare for the post AGI.
> date: Wed Jan 28 15:00:58 +0000 2026
> url: https://x.com/nicbstme/status/2016526922134761612
> ──────────────────────────────────────────────────
> 
> @AbaidZainab (Zainab Abaid):
> @nicbstme @nicbstme would you agree that agentic search doesn’t mean that we are moving past vector databases, but that retrieval is (a) not restricted to only a vector db and (b) not one-shot (agent can continue digging deeper). So the agent could have grep, glob AND vector search tools?
> date: Wed Jan 28 15:18:12 +0000 2026
> url: https://x.com/AbaidZainab/status/2016531260353745049
> ──────────────────────────────────────────────────
> 
> @charlesmakesit (Charles Lazaroni):
> @nicbstme the chunking problem is real but "RAG is dead" oversimplifies it. what's actually dying is naive vector search as the primary retrieval method
> date: Wed Jan 28 16:05:03 +0000 2026
> url: https://x.com/charlesmakesit/status/2016543050344927410
> ──────────────────────────────────────────────────
> 
> @thomasunise (Thomas Unise):
> @nicbstme @grok summarize this and tell me if it makes sense for a law firm with 150,000 documents
> date: Wed Jan 28 16:05:09 +0000 2026
> url: https://x.com/thomasunise/status/2016543076781535528
> ──────────────────────────────────────────────────
> 
> @rejojer (Ray):
> @nicbstme That's exactly why we built PageIndex!
> Vectorless, Reasoning-based RAG: no vector DB, no chunking.
> 
> https://t.co/kieXEyoS3z
> date: Wed Jan 28 17:59:09 +0000 2026
> url: https://x.com/rejojer/status/2016571766613954881
> ──────────────────────────────────────────────────
> 
> @Vamzzz93 (Vamz):
> @nicbstme The cost of reasoning through entire PDFs or long documents as context is just impossible at scale. Maybe for small documents, but mine are unstructured, 50-100 pages each.
> date: Wed Jan 28 19:33:28 +0000 2026
> url: https://x.com/Vamzzz93/status/2016595500494180614
> ──────────────────────────────────────────────────
> 
> @laukrik (Lauren Krikorian):
> @nicbstme This is very helpful, thank you!
> date: Thu Jan 29 00:59:55 +0000 2026
> url: https://x.com/laukrik/status/2016677653965623777
> ──────────────────────────────────────────────────
> 
> @CRAMETTEloris (Kairos):
> @nicbstme Fascinating take on Agentic Search vs RAG.
> One question: how do you see the time-to-first-token challenge being solved in agentic systems?
> RAG retrieval is fast and deterministic, but agentic flows may require multiple reasoning/tool steps before any answer can start streaming ?
> date: Thu Jan 29 06:40:14 +0000 2026
> url: https://x.com/CRAMETTEloris/status/2016763296376836415
> ──────────────────────────────────────────────────
> 
> @geoffprr (Geoffrey):
> @nicbstme Thanks for the amazing article !
> 
> It seems like it will not be an easy to implement this in a mid-large size company level.
> 
> All the Fintool employees are already working like this and the synchronisation between everybody works well ?
> date: Thu Jan 29 18:02:19 +0000 2026
> url: https://x.com/geoffprr/status/2016934951166308444
> ──────────────────────────────────────────────────
