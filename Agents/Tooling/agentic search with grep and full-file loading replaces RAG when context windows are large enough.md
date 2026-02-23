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

> [!quote]- Full Article by @nicbstme (Nicolas Bustamante) — Jan 27, 2026
>
> **The RAG Obituary: Killed by Agents, Buried by Context Windows**
>
> As I wrote in Oct 2025, after three years of building, optimizing, and scaling LLMs with retrieval-augmented generation (RAG) systems, I believe we're witnessing the twilight of traditional RAG-based architectures especially ones relying on embeddings. As context windows explode and agent-based architectures mature, my controversial opinion is that the current RAG infrastructure we spent so much time building and optimizing is on the decline.
>
> I've been working in AI and search for a decade. First building Doctrine, the largest European legal search engine and now building @fintool an AI-powered financial research platform that helps institutional investors analyze companies, screen stocks, and make investment decisions.
>
> ---
>
> **The Rise of Retrieval-Augmented Generation**
>
> In late 2022, ChatGPT took the world by storm. People started endless conversations, delegating crucial work only to realize that the underlying model, GPT-3.5 could only handle 4,096 tokens... roughly six pages of text!
>
> The AI world faced a fundamental problem: how do you make an intelligent system work with knowledge bases that are orders of magnitude larger than what it can read at once?
>
> The answer became Retrieval-Augmented Generation (RAG), an architectural pattern that would dominate AI for the next three years.
>
> ---
>
> **The Mathematical Reality of Early LLMs**
>
> GPT-3.5 could handle 4,096 tokens and GPT-4 doubled it to 8,192 tokens, about twelve pages. This wasn't just inconvenient; it was architecturally devastating.
>
> A single SEC 10-K filing contains approximately 51,000 tokens (130+ pages). With 8,192 tokens, you could see less than 16% of a 10-K filing. It's like reading a financial report through a keyhole!
>
> ---
>
> **The RAG Architecture: A Technical Deep Dive**
>
> RAG emerged as an elegant solution borrowed directly from search engines. Just as Google displays 10 blue links with relevant snippets for your query, RAG retrieves the most pertinent document fragments and feeds them to the LLM for synthesis.
>
> The core idea is beautifully simple: if you can't fit everything in context, find the most relevant pieces and use those. It turns LLMs into sophisticated search result summarizers.
>
> ---
>
> **The Chunking Challenge**
>
> Long documents need to be chunked into pieces and it's when problems start. Those digestible pieces are typically 400-1,000 tokens each (300-750 words).
>
> Consider chunking a typical SEC 10-K annual report. The document has a complex hierarchical structure:
> - Item 1: Business Overview (10-15 pages)
> - Item 1A: Risk Factors (20-30 pages)
> - Item 7: Management's Discussion and Analysis (30-40 pages)
> - Item 8: Financial Statements (40-50 pages)
>
> After naive chunking at 500 tokens, critical information gets scattered:
> - Revenue recognition policies split across 3 chunks
> - A risk factor explanation broken mid-sentence
> - Financial table headers separated from their data
> - MD&A narrative divorced from the numbers it's discussing
>
> At Fintool, sophisticated chunking strategies include hierarchical structure preservation, table integrity (financial tables never split), cross-reference preservation, temporal coherence, and footnote association. Each chunk enriched with metadata: filing type, fiscal period, section hierarchy, table identifiers, cross-reference mappings, company identifiers, industry codes.
>
> Even intelligent chunking can't solve the fundamental problem: working with fragments instead of complete documents.
>
> ---
>
> **The Embedding and Retrieval Pipeline**
>
> Each chunk converted into a high-dimensional vector (typically 1,536 dimensions). Query becomes a vector. System finds closest chunks via cosine similarity.
>
> Elegant in theory, nightmare of edge cases in practice. Embedding models trained on general text struggle with specific terminologies. Can't distinguish "revenue recognition" (accounting policy) from "revenue growth" (business performance).
>
> Example: Query "What is the company's litigation exposure?"
> - RAG reports: $500M (from Legal Proceedings section)
> - Actual exposure: $5.1B (scattered across Legal Proceedings $500M, Contingencies $700M, Subsequent Events $1B, Indemnification $800M, Footnotes $2B using "probable" not "litigation")
> - 10x miss.
>
> ---
>
> **Hybrid Search: The Complexity That Actually Works**
>
> Combine semantic search (embeddings) with traditional keyword search (BM25). BM25 rewards exact matches, handles rare terms better, normalizes document length, saturates term frequency.
>
> At Fintool: parallel processing, dynamic weighting (specific metrics → BM25 70%, conceptual → embeddings 60%, mixed → 50/50), score normalization (min-max for BM25, cosine for embeddings, z-score for outliers), Reciprocal Rank Fusion to merge rankings.
>
> ---
>
> **The Reranking Bottleneck: RAG's Dirty Secret**
>
> Even after retrieval, you need reranking. Rerankers are ML models that reorder results by relevance.
> - Latency: adds 300-2000ms per query
> - Cost: Cohere Rerank 3.5 costs $2.00 per 1,000 search units
> - Context limits: Cohere Rerank supports only 4096 tokens, requiring parallel API calls and merging
> - One more API, one more failure point
>
> ---
>
> **The Infrastructure Burden**
>
> The cascading failure problem: chunking can fail → embedding can fail → BM25 can fail → hybrid fusion can fail → reranking can fail. Each stage compounds errors.
>
> Production Elasticsearch: TB+ indexed data, 128-256GB RAM minimum, 48-72 hour re-indexing on schema changes, cluster management, sharding strategies, backup and disaster recovery, breaking version upgrades.
>
> ---
>
> **Fundamental Limitations of RAG for Complex Documents**
>
> 1. Context fragmentation: long documents are interconnected webs, not independent paragraphs
> 2. Semantic search fails on numbers: "$45.2M" and "$45,200,000" get different embeddings
> 3. No causal understanding: can't follow "See Note 12" references
> 4. Vocabulary mismatch: "Adjusted EBITDA" vs "Operating Income Before Special Items"
> 5. Temporal blindness: can't distinguish Q3 2024 from Q3 2023
>
> ---
>
> **The Emergence of Agentic Search**
>
> Claude Code demonstrated that with enough context, search becomes navigation. It uses:
> 1. Grep (Ripgrep): lightning-fast regex search, no indexing, full regex support, filters by file type
> 2. Glob: direct file discovery by name patterns, sorted by modification time, zero overhead
> 3. Task Agents: autonomous multi-step exploration, combine strategies adaptively, self-correct
>
> Grep was invented in 1973. It's primitive. And that's the genius.
>
> Claude Code doesn't retrieve. It investigates: runs multiple searches in parallel, starts broad then narrows, follows references naturally. No embeddings, no similarity scores, no reranking.
>
> A benchmark by @RLanceMartin showed a simple TXT file with URLs+descriptions outperforms complex RAG.
>
> ---
>
> **The Context Revolution: From Scarcity to Abundance**
>
> - GPT-4: 8K tokens (~12 pages)
> - GPT-4-32k: 32K tokens (~50 pages)
> - Claude Sonnet 4: 200K tokens (~700 pages)
> - Gemini 2.5: 1M tokens (~3,000 pages)
> - Grok 4-fast: 2M tokens (~6,000 pages)
>
> At 2M tokens, you can fit an entire year of SEC filings. Heading toward 10M+ by 2027.
>
> ---
>
> **Why Agentic Search Represents the Future**
>
> Agent following SEC filing references step by step:
> Step 1: Find "lease" in main financial statements → discovers "See Note 12"
> Step 2: Navigate to Note 12 → finds "excluding discontinued operations (Note 23)"
> Step 3: Check Note 23 → discovers $2B additional obligations
> Step 4: Cross-reference with MD&A → identifies management's explanation
> Step 5: Search for "subsequent events" → finds $500M lease termination
> Final: $5B continuing + $2B discontinued - $500M terminated = $6.5B
>
> No chunks. No embeddings. No reranking. Just intelligent navigation.
>
> RAG is like a research assistant with perfect memory but no understanding. Agentic search is like a forensic accountant: follows the money systematically, understands accounting relationships, identifies what's missing, connects dots across time periods and documents.
>
> ---
>
> **The Future: Desktop Agents and the Bitter Lesson of Simplicity**
>
> Today: agents running sandboxes in the cloud with mounted filesystems (Manus, Claude.ai).
> Tomorrow: software running directly on your desktop accessing local filesystem.
>
> Claude Cowork by @felixrieseberg runs inside an isolated VM using Apple's Virtualization Framework. Reads files, creates documents, reorganizes — no indexing, chunking, or embedding.
>
> The bitter lesson: grep invented in 1973 outperforms trillion-parameter embedding models when paired with an intelligent navigator. A filesystem mount beats a vector database. Direct file access beats similarity search.
>
> We are entering the post-retrieval age. The winners will not be the ones who maintain the biggest vector databases, but the ones who design the smartest agents to traverse abundant context. In hindsight, RAG will look like training wheels. Useful, necessary, but temporary.
>
> *656 likes · 64 retweets · 46 replies*

[Original thread](https://x.com/nicbstme/status/2016251900249964865)
