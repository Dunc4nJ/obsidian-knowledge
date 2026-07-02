---
created: 2026-07-02
description: "Johnson Shi's X long-form article reads the Dr-DCI paper (arXiv:2606.14885) as a systems argument: retrieval is exposed to the agent as a pull(query, k) action that runs BM25 over the full corpus and hard-links the top candidate whole-documents into a small scratch workspace (~1,000-1,400 files), which the agent then greps/cats/reads directly. BM25 bounds the search scope; DCI (direct shell tools) does the precise, stateful, cross-document verification once the working set is local. This keeps ~20x wall-time and ~3x cost wins while lifting a GPT-5.4-nano agent above frontier reasoning models on BrowseComp-Plus — and Shi extends it with five patterns (shard locality, content-addressable caching, fast sandbox setup, prefetch-on-rank, hot-query precompute) for the case the paper never handles: a corpus too big to fit on one disk, where the free hard link becomes a real network fetch. The framing thesis: the harness — how it exposes tools, bounds state, and moves bytes — is now the inference-provider differentiator, not the model weights."
source: "https://x.com/johnsonshi86/status/2072112215097024961"
author: "@johnsonshi86 (Johnson Shi)"
paper: "https://arxiv.org/abs/2606.14885"
type: post
tags: [agentic-search, retrieval, harness-engineering, bm25, rag, dci, inference-providers, caching, distributed-systems]
---

## Thesis

Johnson Shi's article takes the **Dr-DCI** paper (*Scaling Direct Corpus Interaction via Dynamic Workspace Expansion*, [arXiv:2606.14885](https://arxiv.org/abs/2606.14885), surfaced by [Jo Kristian Bergum's AI Engineer World's Fair 2026 talk on BM25](https://x.com/jobergum/status/2072048159342440627)) and reads it not as a retrieval-quality result but as a **harness-engineering** result. The claim that carries the whole piece: *the harness around a model — how it exposes tools, manages state, and bounds what the model can touch — is what increasingly separates one agent stack from another, not the model weights.* Dr-DCI is the concrete demonstration, and its mechanism is a caching pattern any systems engineer will recognize.

The core move is one sentence: **use BM25 as a cache-population step in front of `grep`.** A `pull(query, k)` tool runs a BM25 first pass over the full corpus, hard-links the top-k *whole documents* into a small scratch workspace, and the agent then runs real `grep`/`rg`/`cat`/`find` against that bounded workspace instead of the whole corpus. BM25 narrows scope; DCI (Direct Corpus Interaction — giving the agent a shell) does the precise, stateful, cross-document verification once the working set fits on local disk.

![[johnsonshi86-024961-001.png]]
*Figure 1 — Dr-DCI overview. Retrieval is an agent-callable action (`pull`) that expands a local workspace; the agent dynamically pulls ranked whole-documents in, then uses DCI shell tools to investigate and verify the materialized evidence. The retriever sits behind `pull`; the massive corpus is never scanned wholesale.*

This is the same lineage as [[agents are the perfect slow searchers because LLM inference cost dominates per-query retrieval latency]] (which cites the **original** DCI paper, arXiv:2605.05242, as the "spend LLM tokens to match retrieval quality" baseline) — Dr-DCI is DCI made cheap by bounding the workspace, so it gets DCI's precision *without* DCI's full-corpus-`grep` cost. It sits in the same 20B-scale-agentic-search cluster as [[Context-1 proves agentic search can be 20B-scale and retrieval-dominant without frontier models|Context-1]] and [[Harness-1 offloads search bookkeeping into a stateful harness so a 20B RL policy beats frontier searchers on curated recall|Harness-1]], and generalizes the point from [[agentic search with grep and full-file loading replaces RAG when context windows are large enough|grep + full-file loading replaces RAG]] to corpora far too large to `grep -r` directly.

## The constraint: an LLM has fixed-size RAM, not a disk

The framing device: an LLM reads a fixed number of tokens per call — the context window is **RAM**: fast, small, bounded. A corpus is billions of documents — **disk**. You cannot load disk into RAM wholesale, so you need an index and a way to fetch only the relevant slice. Every strategy below is a different way of doing that fetch ("retrieval").

## The retrieval spectrum

| Strategy | Mechanism | Failure mode |
|---|---|---|
| **RAG** | Offline: chunk (~500 tok) → embed → vector DB. Query time: embed question → ANN search → top-k chunks (5–20) pasted into context. | One retrieval pass, no recourse. If a chunk boundary split the fact, or embedding similarity missed a paraphrase, the agent can't look further — single request, no retry informed by the first answer. |
| **BM25** | Statistical scoring over an inverted index (term → doc list, rare terms weighted up, length-normalized). No model, no GPU, built once from the corpus. | Exact for names, IDs, error codes, code symbols; worse than embeddings at synonymy — `car` and `automobile` share no token. Snippet-limited like RAG. |
| **DCI** | Give the agent a shell: `rg`, `grep`, `find`, `cat`. It issues its own commands against the raw corpus, follows references A→B, verifies exact strings. | `grep -r` over billions of docs is a full scan with no index — slow, then times out. Worse as the corpus spreads across machines. |
| **Dr-DCI** | BM25 first pass populates a small working set (whole docs, hard-linked into a scratch dir); the agent `grep`s that bounded workspace; misses trigger another `pull` that *adds* to the same workspace. | Bounds all three failure modes above — the workspace stays ~1,000–1,400 files even against a 10M-doc corpus. |

BM25 is one of the two most typical RAG retrievers (alongside dense embeddings); Shi spends a full section on it because it's the load-bearing first stage and because Bergum's talk was specifically a defense of BM25. Its inverted index *is* the corpus tokenized once — a query token that never appeared has an empty postings list (no match, not an error).

## The Dr-DCI loop

1. Agent calls `pull(query, k)` → BM25 over the full corpus returns `k` **whole documents** (not chunks).
2. Those docs are materialized as real files in the workspace via **hard links** (a new directory entry pointing at the same inode — no content copy, no write).
3. Agent runs `grep`/`rg`/`cat`/`read` against that small directory.
4. Miss? Call `pull` again with a different query; new results are **deduped** against the workspace and added; already-pulled files aren't re-fetched.

Crucially the `pull` query isn't a raw user query — it's whatever search string the agent *writes*. The agent is already an LLM reasoning about the task, so query formulation is a free side effect of reasoning (no separate query-rewriting step, unlike a traditional search box that needs one).

## Why it is both faster and more accurate

Three separate failure modes, one fix. The paper's controlled result on **BrowseComp-Plus** (the benchmark documented in [[BrowseComp-Plus enables reproducible agentic search evaluation with static corpora and verified distractors|BrowseComp-Plus]]) is the headline: with the *same precision tools and same benchmark, only the access pattern changed*, Dr-DCI turns a **GPT-5.4-nano** agent into something that outranks frontier reasoning models.

![[johnsonshi86-024961-002.png]]
*Figure 2 — Accuracy vs estimated total cost on BrowseComp-Plus (cost log-scale). GPT-5.4-nano + Dr-DCI hits **71.2%** at **\$34.9**; adding the optional workspace-preserving Context Reset (CR) reaches **73.2%** — a **+28.3 pt** lift over the bare nano baseline (44.9%) at **~3.0x cheaper** (\$34.9 vs \$105). Dr-DCI beats Claude Sonnet 4.6 (69.0), o3 (66.0), and the un-bounded Raw-DCI trajectory (62.9, \$88.1). "Retriever Mediated" reference models trail far right at \$740–\$1300.*

The scaling ablation is where the harness argument really lands: hold the questions fixed and inflate the corpus from 100K to 10M docs with FineWeb distractors. **Raw-DCI collapses** — full-corpus terminal search times out; the paper's recovered single-tool durations run p50/p90/p95/p99 = 12.4s / 97.0s / 167.2s / 310.2s with a **max of 24,418s**. Dr-DCI stays flat because it always operates over ~1,000 files.

![[johnsonshi86-024961-003.png]]
*Figure 3 — Corpus-scaling ablation (BCP-100, 100K→10M docs). Dr-DCI accuracy holds ~72–80% while Raw-DCI decays toward ~4% (projected); Raw-DCI's tool-timeout rate climbs to ~68% while Dr-DCI stays ~0; Dr-DCI cost is flat ~\$5/100q vs Raw-DCI's ~\$19; Dr-DCI wall time is flat ~0.3×10³ s/q vs Raw-DCI's ~2.3×10³ s/q. The article summarizes the local-machine win as **~20x faster wall time** because the agent works over ~1,000 files instead of the whole corpus.*

The behavioral fingerprint of the fix: Dr-DCI *shifts corpus discovery out of repeated `bash` search and into `pull`*, then does more local reading once documents are materialized.

![[johnsonshi86-024961-004.png]]
*Figure 4 — Tool-call composition. Top: Dr-DCI's high-level mix is 64.3% bash / 23.3% read / 12.4% pull-filter, vs Raw-DCI's 89.7% bash / 10.3% read / 0% pull. Bottom: among bash calls Dr-DCI leans on `search+limit` (56.0%) rather than Raw-DCI's blunt repeated `search+limit` (71.8%) — retrieval replaces brute-force corpus probing.*

## The hidden single-machine assumption

Shi's sharpest observation is what the paper *doesn't* say. A **hard link only works because corpus, index, and workspace share one disk** — a hard link cannot point across machines. The paper never states this; it's an inference from the mechanism. The cheapness of workspace materialization (free hard link, dedup on pull, root-flat namespace, bounded/truncated reads with continuation hints) is entirely a single-machine property. The **root-flat namespace** detail is itself a finding echoing [[Entire's pgr proves definition-first ranking helps coding agents more than faster ripgrep|pgr]]-style harness ergonomics: rank-aware subfolders were tested and *reduced accuracy* because brittle paths confused the agent's terminal navigation — rank gets reported in tool-call text, not the file path.

Split the corpus across machines and the free hard link becomes a real network fetch. That's the gap Shi's extension addresses.

## Closing the gap: five patterns for a distributed corpus

Once corpus, index, and compute aren't colocated, there are **two** costs, not one: (1) **distributed BM25 search** (solved the normal sharded-search-engine way — fan out to N shards, score locally, merge centrally), and (2) **workspace materialization** — moving the retrieved bytes to where the agent's tools run. The second cost is bounded the same way the local case is: ~1,000 small docs per query, ~50KB each ≈ **50MB fetched in parallel**, not the corpus.

1. **Shard locality.** Colocate each BM25 shard's inverted index with its partition's document files on the same host. A query needing only that shard never leaves the host; crossing a shard boundary is the real cost (not anything as coarse as a datacenter).
2. **Content-addressable caching, scoped to mutability.** Immutable content (archived articles, completed filings): key by content hash, cache forever — same shape as a pull-through OCI registry cache (Harbor/Zot), no invalidation possible because the key can't change; multi-tier (local → regional mirror → origin) writes back through whichever tiers missed. Mutable content (wiki page, live ticket): a content hash isn't a stable key, so you need invalidation — L1 per-node in-memory / L2 shared Redis (write-through) / L3 source of truth, with either short L1 TTLs (bounded self-healing staleness) or pub/sub keyspace-notification invalidation (precise, but a dependency every node must handle). Real corpora need both paths at once. This is the same tiered-KV-cache thinking as [[Red Hat frames prefill/decode disaggregation, KV-cache tiering, and speculative decoding as the three llm-d deployment levers for distributed AI inference|Red Hat's llm-d KV-cache tiering]], applied to corpus documents instead of attention state.
3. **Fast sandbox setup/teardown.** If each `pull` materializes a sandboxed microVM/container rather than just a shared-disk directory, create/destroy cost matters as much as data movement — a base image with corpus-access tooling pre-staged plus a thin copy-on-write layer per query keeps setup near-instant with no teardown cleanup (the same problem agent code-execution sandboxes already solve).
4. **Prefetch on rank.** `pull` returns a ranked list before the agent decides what to inspect — fetch the full top-k in parallel with the agent reading the ranked preview, hiding fetch latency behind the model's own reasoning step.
5. **Precompute hot query results.** Query patterns aren't uniform in production — track the most-pulled documents and pre-stage them into the shared cache, and cache the ranked BM25 result list for the most common queries so a repeat skips scoring entirely. Warms the pattern-2 cache proactively instead of reactively.

The first four are architectural; the fifth is operational. Together they make Shi's meta-point concrete: *fast corpus retrieval is a harness-engineering differentiator inference providers should benchmark against each other*, exactly the retrieval-dominant-harness thesis running through [[Context-1 proves agentic search can be 20B-scale and retrieval-dominant without frontier models|Context-1]], [[Harness-1 offloads search bookkeeping into a stateful harness so a 20B RL policy beats frontier searchers on curated recall|Harness-1]], and the [[Perplexity post-trains Qwen3.5 search agents with two-stage SFT+RL and gated reward aggregation to prevent hacking|Perplexity search-agent post-training]] work.

## Where this sits in the vault

- **Same "harness > weights" cluster:** [[Harness-1 offloads search bookkeeping into a stateful harness so a 20B RL policy beats frontier searchers on curated recall|Harness-1]] offloads *bookkeeping* into the harness so an RL policy specializes; Dr-DCI offloads *scope-bounding* into the harness so even an off-the-shelf nano model beats frontier reasoners. Two flavors of the same bet.
- **DCI lineage:** [[agents are the perfect slow searchers because LLM inference cost dominates per-query retrieval latency]] frames the original DCI as "spend LLM tokens to match retrieval quality"; Dr-DCI is the answer — keep DCI's precision, delete its full-corpus cost.
- **grep-vs-RAG:** [[agentic search with grep and full-file loading replaces RAG when context windows are large enough|grep + full-file loading replaces RAG]] holds only while the corpus fits in a grep-able tree; Dr-DCI is the recipe for when it doesn't.
- **Retriever quality:** the paper's own retriever ablation finds dense retrieval beats BM25 as the backend, connecting to [[Agent-ModernColBERT trains late interaction on reasoning traces to reach GPT-5 retrieval accuracy with 149M parameters|Agent-ModernColBERT]] and [[Reason-ModernColBERT|Reason-ModernColBERT]] — a better `pull` retriever should compound Dr-DCI's gains.

---

**Source:** [Johnson Shi (@johnsonshi86) on X](https://x.com/johnsonshi86/status/2072112215097024961) (long-form article, 2026-07-01) · paper [Dr-DCI: Scaling Direct Corpus Interaction via Dynamic Workspace Expansion, arXiv:2606.14885](https://arxiv.org/abs/2606.14885) · surfaced via [Jo Kristian Bergum on X](https://x.com/jobergum/status/2072048159342440627) (AI Engineer World's Fair 2026). Credits to @zhuofengli96475 (and co-authors) and @jobergum.

---

## Appendix — full article text (verbatim)

> 📰 **DR-DCI: Fast Corpus Retrieval as a Harness Engineering Differentiator for Inference Providers**
>
> DR-DCI is an optimization built on top of RAG for letting agents run precise, verifiable search across large document collections without scanning the whole corpus on every query. It keeps a RAG-style first pass, an index lookup such as BM25, to narrow a huge corpus down to a manageable set of candidate documents. Then it adds a second layer: those candidate documents get materialized into a virtual file system, a sandboxed workspace the agent can operate on directly. The agent then runs real bash commands, grep, rg, cat, find, directly against that workspace to search, cross-reference, and verify evidence.
>
> This matters most for inference providers and harness builders. The harness around a model, how it exposes tools, manages state, and bounds what the model can touch, is what increasingly separates one agent stack from another, not the model weights themselves. Harness design shows up directly in tool-calling benchmark scores and in how an agent performs on real work.
>
> The material below translates the Dr-DCI paper (https://arxiv.org/abs/2606.14885) (surfaced via Jo Kristian Bergum's X post at the AI Engineer World's Fair 2026) into systems terms for a Kubernetes and distributed-systems audience, then extends it: what it takes to run this pattern once the corpus isn't on one machine. That gap is what makes this pattern production-ready at scale, and it's something worth exploring and benchmarking among inference providers.
>
> **The constraint: an LLM has a fixed-size RAM, not a disk**
>
> An LLM reads a fixed number of tokens per call, the context window. Think of it as RAM: fast, but small and bounded. A document collection (a "corpus") can be billions of documents. That's disk-sized data. You cannot load disk into RAM wholesale. You need an index and a way to fetch only the relevant slice.
>
> That fetching step is what the AI field calls "retrieval." Everything below is different strategies for doing it.
>
> **RAG: query an index, get back chunks, done**
>
> RAG (Retrieval-Augmented Generation) is the standard approach:
>
> 1. Offline indexing. Split every document into chunks (commonly 500 tokens). Run each chunk through an embedding model, which outputs a vector (a few hundred floats representing meaning, not exact words). Store all vectors in a vector database.
> 2. Query time. Embed the user's question into the same vector space. Run an approximate-nearest-neighbor search against the vector DB. Get back the top-k closest chunks, typically 5-20.
> 3. Generation. Paste those chunks into the LLM's context window. The LLM answers using only what it was handed.
>
> The LLM never touches the rest of the corpus. It gets one retrieval pass, then it's on its own.
>
> The failure mode: if the top-k result set misses the actual answer, because a chunk boundary split a fact in half, or the embedding similarity didn't catch a paraphrase, the LLM has no recourse. It can't look further. It's a single request to a single backend with no retry, no fallback, no second query informed by the first response.
>
> **BM25: a common retriever, the alternative to embeddings**
>
> BM25 is one of the most typical retrievers used in RAG, alongside embedding-based dense retrieval. It predates neural embeddings by decades. No model, no GPU, no training step. It's a statistical scoring function: rank documents by how often the query's terms appear, weighted so rare terms count more than common ones, normalized for document length. Build an inverted index once (term to document list, like the index behind any full-text search engine: Lucene, Elasticsearch's default), then query it directly.
>
> The index comes directly from the corpus itself. Tokenize every document at indexing time (split into words, lowercase, strip filler words, sometimes reduce to a root form), and every distinct token that survives becomes a term in the index. A query gets tokenized the same way at query time. If a query token never appeared in any document, its postings list is simply empty, no match, not an error.
>
> BM25 is fast and exact for names, IDs, error codes, code symbols. It's worse than embeddings at matching a query to text that means the same thing but uses different words, since it needs the same token in both the query and the document, "car" and "automobile" share no tokens even though a human reads them as the same thing.
>
> **DCI: skip the index, give the agent a shell**
>
> Direct Corpus Interaction (DCI) is the opposite extreme from RAG. Instead of pre-indexing and ranking, give the LLM agent actual shell tools: rg, grep, find, cat, read. The agent runs its own commands against the raw corpus, the way you'd grep -r a codebase you don't have indexed.
>
> This buys precision RAG doesn't have. The agent can issue a second search based on what the first one returned, cross-reference two documents, verify an exact string exists, follow a reference from doc A to doc B. A single retrieval-then-answer pass can't do any of that.
>
> The failure mode: grep -r over billions of documents is a full scan with no index. Same problem as querying an unindexed table at scale: it gets slow, then it times out.
>
> **Dr-DCI: BM25 as a cache-population step in front of grep**
>
> This is the part that should click immediately if you've built caching layers. Dr-DCI uses BM25 as a fast first pass that populates a small working set. The agent then greps that working set directly, the DCI part.
>
> The loop:
>
> 1. The agent calls a pull(query, k) tool. This runs a BM25 search over the full corpus and returns k candidate documents, whole documents, not chunks.
> 2. Those documents get materialized as real files in a scratch directory (the "workspace"), via hard links, so there's no copy cost.
> 3. The agent runs grep/rg/cat/read against that small directory, not the full corpus.
> 4. If it doesn't find what it needs, it calls pull again with a different query. New results get added to the same workspace. Already-pulled files aren't re-fetched.
>
> The workspace stays small, roughly 1,000-1,400 files, even when the underlying corpus is 10 million documents. BM25 is doing index lookup. DCI is doing the precise, stateful operations once the working set is small enough to fit on local disk.
>
> **Why this is faster and more accurate**
>
> Three separate failure modes, one fix:
>
> - RAG. Chunking splits facts across boundaries, and the agent only ever sees the top-k snippets it gets handed once. If the chunk that mattered wasn't in that top-k, there's no way to look further.
> - BM25 alone. Same snippet limit as RAG: the agent sees a ranked list of snippets, not full documents, and can't cross-reference across results.
> - DCI alone. Full-corpus grep is expensive, and gets more expensive the more the corpus is spread across machines, every search touches a distributed set instead of a local one.
>
> Dr-DCI avoids all three: BM25 narrows the corpus to a small candidate set, then DCI runs full-precision search against that bounded set instead of the whole corpus.
>
> The paper's numbers, on the same benchmark, same tools, only the access pattern changed:
>
> Same precision tools. ~20x faster wall time. Because the agent is operating over roughly 1,000 files instead of the entire corpus.
>
> **How the workspace gets populated cheap**
>
> The wall-time drop comes mostly from bounding the search scope, not from a provisioning trick. The workspace stays around 1,000-1,400 files regardless of corpus size, so every grep call scans a few thousand files instead of the entire corpus.
>
> Populating that bounded workspace still needs to be cheap. The paper's mechanism for that is specific to a single machine:
>
> - Hard links, not copies. Materializing a pulled document creates a new directory entry pointing at the same inode. No file content gets duplicated, no write happens.
> - Dedup on pull. The harness filters out documents already in the workspace before adding new ones from a pull call, so overlapping retrieval results don't redo work.
> - Root-flat namespace. No folders by rank or query. Rank-aware subfolders were tested and reduced accuracy, brittle paths confused the agent's terminal navigation. Rank gets reported in the tool-call text instead of the file path.
> - Bounded reads. Read and search tool outputs are truncated with continuation hints, so one grep across the workspace can't flood the model's context window.
>
> A hard link only works because the corpus, the index, and the workspace are all on the same disk. The paper never states this as an assumption. It's an inference from the mechanism: a hard link cannot point across machines, so this design only works when corpus, index, and workspace share a disk. Split the corpus across machines and the mechanism breaks.
>
> **Applying this to distributed systems**
>
> The paper runs everything on one machine. Turning the workspace-bounding idea into something that holds up across a distributed corpus is mostly unexplored, and it's the part worth digging into next.
>
> The paper measures one cost directly: search cost across the corpus. Raw DCI's full-corpus terminal search times out in their results, recovered tool-result durations show p50/p90/p95/p99 single-tool times of 12.4s/97.0s/167.2s/310.2s, with a max of 24,418s. Dr-DCI's workspace-bounding fixes that cost.
>
> A second cost surfaces once the corpus, index, and compute aren't on the same machine: workspace creation and materialization, moving the retrieved document bytes from wherever they live to wherever the agent's tools run. On one machine that cost is a hard link, free. Across machines, it's a real network fetch.
>
> These are two separate costs:
>
> 1. Distributed search cost. Running BM25 across a sharded corpus. Solved the normal way, the same shape as any sharded search engine: a query fans out to N shards, each shard scores locally, results merge centrally.
> 2. Workspace creation and materialization cost. After BM25 ranks the relevant files, those files have to be moved onto a sandboxed workspace where the agent's bash tools can operate. The cost of that gathering and provisioning is a separate cost, and it's in scope once the corpus isn't local.
>
> That second cost is bounded the same way the local case is bounded: roughly 1,000 small documents per query, not the corpus. At 50KB per document, about 50MB, fetched in parallel.
>
> **Closing the gap: five patterns**
>
> The first four patterns are architectural. The fifth is operational.
>
> **1. Shard locality**
>
> A BM25 shard is a partition of the corpus: split the corpus into N pieces, and each piece gets its own inverted index, a lookup from term to the list of documents containing it, with term frequency and document length for scoring, built over just that piece's documents. That index is built once, offline, before any query runs, and written to disk as standing files, the same way a database builds and persists an index rather than recomputing it per query. A query is scored against each shard separately, then the per-shard scores merge and re-rank centrally.
>
> Colocating a shard means storing that shard's inverted index and the actual document files for its partition on the same host. A query that only needs one shard never leaves that host, no network hop to materialize the result. A query that needs a different shard crosses a host boundary, and that's the real cost, not anything as coarse as a datacenter.
>
> Worth noting where the query string itself comes from: in Dr-DCI, pull(query, k) isn't handed a raw user query, it's handed whatever search string the agent decides to write. The agent is already an LLM reasoning about the task, so query formulation happens as a side effect of that reasoning, no separate query-rewriting step needed. Systems that don't already have an LLM generating the query, a traditional search box, for instance, usually add a cheap rewriting or expansion step in front of BM25 for the same reason: raw user text often misses the exact tokens the index needs.
>
> **2. Content-addressable caching, scoped to what doesn't change**
>
> The paper's dedup only applies within one agent trajectory. A shared cache keyed by content hash turns a second reference to the same document into a cache hit instead of a second fetch. The strategy splits depending on whether the corpus changes.
>
> Immutable content (archived news articles, completed filings): key by content hash, cache forever. This is the same shape as a pull-through registry cache (Harbor, Zot, any OCI-compliant mirror), content addressed by digest, with no invalidation logic possible because the key can't change. A multi-tier version, local node cache, then a regional mirror, then origin storage, works the same way: a miss at one tier checks the next before going to origin, and the result gets written back down through whichever tiers missed.
>
> Mutable content (a wiki page, a ticket, a document under active edit): a hash of current content isn't a stable key, since the key changes the moment the content does. A stale entry can silently serve outdated data. Needs cache invalidation.
>
> A tiered cache for mutable content: a per-node in-memory cache (L1, fastest, smallest), a shared cache like Redis (L2, shared across nodes), and the source of truth behind it (L3). L2 is easy to keep correct: a write-through updates Redis and the source together. L1 is the risk, each node's local copy can go stale silently if nothing tells it the data changed. Two fixes: short TTLs on L1, so staleness is bounded and self-healing, or pub/sub invalidation, where a "this key changed" event (Redis keyspace notifications, for example) gets broadcast to every node so L1 evicts the key on receipt. TTL is simpler and eventually consistent. Pub/sub is more precise but adds a dependency every node has to handle correctly.
>
> In practice, most real corpora need both paths at once: a long-lived content-addressable cache for the immutable majority, a versioned or write-through path for whatever subset changes.
>
> **3. Fast sandbox setup and teardown**
>
> Each pull() call materializes a workspace for one query, then discards it. If that workspace is a sandboxed environment, a microVM or lightweight container, rather than just a directory on shared disk, the create and destroy cost matters as much as the data-movement cost.
>
> A base image with the corpus-access tooling pre-staged, plus a thin copy-on-write layer per query, keeps setup close to instant and removes any cleanup cost on teardown. This is the same problem agent sandbox runtimes already solve for code execution, applied here to corpus-search workspaces instead.
>
> **4. Prefetch on rank**
>
> pull() already returns a ranked list before the agent decides what to inspect. Fetching the full top-k in parallel with the agent reading that ranked preview hides fetch latency behind the model's own reasoning step.
>
> **5. Precompute hot query results**
>
> Once this runs in production, query patterns aren't uniform. Some documents get pulled far more often than others. Track which documents come back most frequently across queries, and pre-stage those into the shared cache ahead of time, instead of waiting for the first miss to populate it.
>
> For BM25 specifically, also cache the ranked result list for the most common queries or query terms, so a repeat query skips the scoring step entirely and goes straight to a cache hit. This makes the content-addressable cache from pattern 2 warm before the first real query lands, instead of only filling up reactively.
>
> Source paper: Dr-DCI: Scaling Direct Corpus Interaction via Dynamic Workspace Expansion, arXiv:2606.14885 (June 2026).
>
> Original post: Jo Kristian Bergum on X, AI Engineer World's Fair 2026.
>
> Credits to @zhuofengli96475 (and other paper authors) and @jobergum for the presentation.
