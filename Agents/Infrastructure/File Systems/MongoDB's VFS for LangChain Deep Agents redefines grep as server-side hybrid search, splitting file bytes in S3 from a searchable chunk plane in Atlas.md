---
created: 2026-09-03
description: MongoDB's launch post for langchain-mongodb-deepagents-vfs, a drop-in implementation of LangChain Deep Agents' BackendProtocol that presents an S3 corpus to the agent as an ordinary filesystem. Two-plane architecture — object storage owns file bytes and serves read/write/edit, MongoDB Atlas owns chunks, embeddings and path metadata and serves grep/glob/ls. The load-bearing move is redefining grep as server-side hybrid search (full-text + vector fused via $rankFusion, no client-side rerank round trip), so the agent's tool surface never changes while retrieval gets smarter underneath. Ingestion is 512-token chunks with 64-token overlap, ETag-idempotent sync, Bedrock embeddings by default; chunks retain source path, page number, char offsets and line info so results return in a line-oriented Deep Agents-compatible shape. Search is eventually consistent by design — read is immediately current, grep/glob/ls lag behind the watcher. Structurally the third public instantiation of the Mintlify ChromaFs pattern, after Chroma and Elasticsearch. No benchmarks or latency numbers.
source: https://www.mongodb.com/company/blog/technical/vfs-langchain-deep-agents-searchable-filesystem-agents
authors:
  - Anuj Panchal
  - Nasir Qureshi
type: framework
tags: [agentic-search, hybrid-search, virtual-filesystem, deep-agents, langchain, mongodb, vector-search, rank-fusion, context-engineering, agent-workspace, chunking, s3]
---

## Key Takeaways

- **This is the third public instantiation of one pattern, which is the most useful thing about it — the pattern is stable and the backend is an implementation detail.** [[a virtual filesystem over Chroma replaces sandboxes for agent doc exploration at 100ms instead of 46 seconds|Mintlify's ChromaFs did it over Chroma]], [[Leonie reimplements Mintlify ChromaFs as a virtual filesystem over Elasticsearch in an open-source POC|Leonie ported it to Elasticsearch]] to show the backend was swappable, and MongoDB now ships it over Atlas as a `BackendProtocol` implementation — the same four-layer split of agent → filesystem tools → backend contract → search index, three vendors deep. The article's thesis line is the reusable part and is not about MongoDB at all: "The virtual filesystem is therefore more than a storage abstraction. It is a context-management interface for agentic work." The justification is that navigation is *incremental* — "instead of loading an entire corpus into the prompt, an agent can first list a directory, narrow the search with a filename pattern, search for a concept, read the relevant file, and then write its findings back as an artifact." ChromaFs also supplies the quantity this post lacks: session creation dropping from ~46s to ~100ms at zero marginal compute. Generalized in the vault as [[Everything is Context - Agentic File System Abstraction for Context Engineering|the agentic filesystem abstraction]], and it is also the neatest answer to [[a file system is not all you need - databases beat markdown for agent context provenance and governance|the argument that databases beat markdown for agent context]] — keep the file interface the agent likes, put the database behind it.

- **But `grep` here means something materially different from ChromaFs's `grep`, and the post never flags the difference.** ChromaFs intercepts `grep -r`, translates the pattern into a coarse `$contains`/`$regex` filter, prefetches matches into Redis, and does in-memory fine filtering — so literal regex semantics survive. MongoDB's `grep` is full-text plus vector retrieval fused server-side by the `$rankFusion` aggregation stage, explicitly to avoid "a separate client-side reranking layer, which would add an extra round trip." That buys a genuinely nice property — one tool call serves both a literal token like `MAX_RETRIES` and a conceptual question like "where is retry behavior configured?" — but what comes back is *ranked top-k relevance, not an exhaustive match set*. An agent reasoning the way agents actually reason about grep ("no hits, therefore it isn't in the corpus") can be silently wrong. [[SMFS makes grep itself a vector query so agents get RAG without learning a new tool|SMFS, which makes the same UX move on a mountable local filesystem]], at least kept `grep -F` literal as an escape hatch; no equivalent is described here. Worth pairing with [[ColBERT-style semantic search beats grep 70 percent of the time for coding agents while using fewer tokens|ColGREP's finding that semantic search beats grep 70% of the time at 15.7% fewer tokens]] — the tradeoff is real and favorable on average, which is exactly why the failure mode is easy to miss.

- **The two-plane split is the architectural claim, and the vault holds both alternatives MongoDB argues against.** Object storage is the data plane owning bytes and serving `read`; Atlas is the search plane owning chunks, embeddings and path metadata and serving `grep`/`glob`/`ls`. Asked why not an S3-compatible platform that also does search, the post answers "the two-plane split isn't a limitation; it's the point," since object storage "isn't built to maintain live indexes, rank hybrid queries, or serve low-latency structured metadata queries simultaneously." Both counter-positions already exist: [[Amazon S3 Files ends the object-file split for AI agents|Amazon S3 Files collapses the object/file divide outright]], making the canonical bucket the working substrate; and [[Cerebras built an internal knowledge base as a hybrid-retrieval system fusing lexical, vector, IDF, and age-decay over one Postgres embeddings table|Cerebras fuses lexical, vector, IDF and age-decay via RRF inside a single Postgres table]], which is a live counterexample to the claim that hybrid ranking needs a dedicated engine. The reasoning is sound but it is also the conclusion MongoDB needs. What survives the vendor framing entirely is the read/search asymmetry: `read` deliberately bypasses the index and goes to the object store, because "search results are optimized for discovery, while reads return the source document" — that separation is right no matter how many planes you run.

- **Eventual consistency is the honest cost, and they publish the operating rule instead of hiding it.** Writes reach S3 first; a watcher (polling, or SQS for lower latency) then re-chunks and re-embeds, so "`read` reflects the S3 state immediately, while `grep`, `glob`, and `ls` may lag." The guidance that follows is the most transferable operational content in the post: **direct reads for hot shared state, `edit` for optimistic concurrency on shared files, search for discovery across a settled corpus**, plus namespacing agent outputs (`shared/outputs/…`) to reduce collisions between parallel workers. The multi-agent implication they stop short of stating: a subagent cannot assume a sibling's just-written artifact is findable by search yet, so a coordinator fanning work across a shared corpus must pass paths explicitly rather than expect discovery to close the loop — the concrete instance of why [[multi-agent memory needs computer architecture style hierarchy and consistency models|multi-agent memory needs explicit consistency models rather than assumed coherence]].

- **The non-obvious engineering detail is positional metadata — it is what lets ranked retrieval masquerade as a filesystem tool at all.** Chunks are 512 tokens with 64-token overlap and "retain positional metadata such as source path, page number, character offsets, and line information, so results can be returned in a Deep Agents-compatible, line-oriented shape." Without that, hybrid retrieval hands back passages and the filesystem illusion collapses the moment the agent tries to act on a result. Supporting details worth keeping: ETags make initial sync and watcher ingestion idempotent so unchanged objects are skipped rather than re-embedded; parsers cover txt/Markdown, PDF, DOCX, XLSX, XLS, PPTX, PPT; embeddings default to Amazon Bedrock with an OpenAI extra or an injected LangChain-compatible implementation; and initialization — index provisioning, first sync, watcher startup — runs on a background daemon thread, so pass-through file operations work immediately while search operations block until first sync completes.

- **Read it as a well-reasoned design, not a validated one — there is no evaluation of any kind.** No benchmarks, no latency numbers, no retrieval-quality comparison against plain `grep`, the default local backend, or a vector-only baseline. It slots cleanly into the harness as a swappable primitive — the same role [[Deep Agents v0.6 splits the agent harness into five composable primitives - code interpreter, per-model profiles, typed streaming, delta channels, and ContextHub backend|Deep Agents v0.6 gives the ContextHub backend]], with [[LangChain deep agents require persistent memory scoped sandboxes and guardrails to move from prototype to production|memory scoping and guardrails]] left to the application, as the post concedes for access control, tenant isolation, residency, retention and audit. For the numbers it lacks: [[Dr-DCI caches BM25 hits into a bounded grep-able workspace, making fast corpus retrieval a harness-engineering differentiator for inference providers|DR-DCI reaches the same "cheap retrieval in front of grep" conclusion from the opposite direction]] by hard-linking BM25 top-k into a bounded *local* workspace (~20x wall-time, ~3x cheaper), [[indexing text with sparse n-grams and bloom filters eliminates 15-second ripgrep waits in large monorepos|Cursor's sparse n-gram index]] sets the latency budget agent grep is actually judged against, and [[agentic search with grep and full-file loading replaces RAG when context windows are large enough|the counter-thesis that large context windows make chunk-embed-rerank unnecessary]] is the position this whole package bets against. Against [[agents are the perfect slow searchers because LLM inference cost dominates per-query retrieval latency|the slow-searcher argument that inference cost dominates per-query retrieval latency]] the Atlas round trip is probably affordable — but that inference comes from the vault, not from anything the post establishes.

## External Resources

- Source: [MongoDB VFS for LangChain Deep Agents: A Searchable Filesystem for Agents](https://www.mongodb.com/company/blog/technical/vfs-langchain-deep-agents-searchable-filesystem-agents) — Anuj Panchal (Partner Solutions Architect) & Nasir Qureshi (Senior PMM), MongoDB, 3 Sep 2026
- **Package: [`langchain-mongodb-deepagents-vfs`](https://github.com/langchain-ai/langchain-mongodb/tree/main/libs/langchain-mongodb-deepagents-vfs)** — in the [langchain-mongodb](https://github.com/langchain-ai/langchain-mongodb) monorepo; contributions invited for additional object-store backends (Azure Blob, GCS), embedding providers, parsers, watcher reliability, and benchmarks
- [LangChain Deep Agents overview](https://docs.langchain.com/oss/python/deepagents/overview) · [virtual filesystem access](https://docs.langchain.com/oss/javascript/deepagents/overview#virtual-filesystem-access)
- [`$rankFusion` aggregation stage](https://www.mongodb.com/docs/manual/reference/operator/aggregation/rankfusion/) — the server-side hybrid ranking primitive the package relies on
- [MongoDB Search](https://www.mongodb.com/products/platform/atlas-search) · [Vector Search](https://www.mongodb.com/products/platform/atlas-vector-search) · [hybrid search](https://www.mongodb.com/resources/products/capabilities/hybrid-search) · [Integrate MongoDB with LangChain](https://www.mongodb.com/docs/atlas/ai-integrations/langchain/)
- [Amazon Bedrock](https://aws.amazon.com/bedrock/) (default embeddings) · [Amazon SQS](https://aws.amazon.com/sqs/) (low-latency watcher mode)

## Original Content

> [!quote]- Full blog post (MongoDB, "MongoDB VFS for LangChain Deep Agents: A Searchable Filesystem for Agents", 3 Sep 2026)
> # MongoDB VFS for LangChain Deep Agents: A Searchable Filesystem for Agents
>
> September 3, 2026 ・ 7 min read
>
> Modern AI agents are no longer expected to answer a question alone. They're expected to complete real work: plan a multi-step task, inspect source material, produce intermediate artifacts, and hand off pieces of the problem to other agents, compressing work that used to take days into hours. That shift raises the bar on what an agent needs underneath it. An agent can only plan and execute at that speed if it can reliably navigate, search, read, and update the filesystem it's working with along the way.
>
> The MongoDB virtual filesystem (VFS) for LangChain Deep Agents connects that filesystem experience to [MongoDB Atlas](https://www.mongodb.com/products/platform/atlas-database) and your underlying object store (e.g., S3 bucket). It gives Deep Agents a familiar virtual filesystem, providing agents with a searchable workspace that persists across sessions, deployments, and sub-agents. Developers building on Deep Agents can now use MongoDB Atlas as the data platform for their agents, including [MongoDB Search](https://www.mongodb.com/products/platform/atlas-search), [Vector Search](https://www.mongodb.com/products/platform/atlas-vector-search), and [hybrid search](https://www.mongodb.com/resources/products/capabilities/hybrid-search), without changing how their agent code reads or writes files. This architecture lets an agent plan, inspect source material, create intermediate artifacts, and return to work that may span hours or days without loading an entire corpus into its context window.
>
> This post explains what Deep Agents and a virtual filesystem are, how the MongoDB backend integration works in an agentic application, and where the pattern can be useful in enterprise agent systems.
>
> ## How LangChain Deep Agents use a virtual filesystem
>
> ### What are LangChain Deep Agents?
>
> [LangChain Deep Agents](https://docs.langchain.com/oss/python/deepagents/overview) are an agent harness built on LangChain and LangGraph for complex, multi-step work. They add capabilities such as planning, subagents, and filesystem-oriented tools, so an agent can break a large task into smaller actions rather than trying to solve everything in a single context window.
>
> A Deep Agent can work with operations such as:
>
> * _Is_ to understand the directory structure
> * _glob_ to find files by path pattern
> * _grep_ to search file content
> * _read_ to retrieve a file
> * write and edit to create or modify artifacts
> * _upload\_files_ and _download\_files_ for bulk file movement
>
> These tools are exposed through a backend contract. The agent does not need to know whether the files live on a local filesystem, in a LangGraph store, in an object storage, or behind another persistence layer. It calls the same filesystem interface, and the configured backend supplies the data.
>
> For MongoDB-specific LangChain integrations, see the [Integrate MongoDB with LangChain - Atlas](https://www.mongodb.com/docs/atlas/ai-integrations/langchain/) documentation.
>
> ### What is a virtual filesystem?
>
> A [virtual filesystem](https://docs.langchain.com/oss/javascript/deepagents/overview#virtual-filesystem-access) is a logical, path-based view of data whose physical storage is abstracted away. An agent may see paths such as _docs/_, _reports/_, or _projects/customer-a/_, even when the underlying bytes reside in an object store and the searchable representation is stored in a database.
>
> This abstraction matters for agents because filesystem navigation is naturally incremental. Instead of loading an entire corpus into the prompt, an agent can first list a directory, narrow the search with a filename pattern, search for a concept, read the relevant file, and then write its findings back as an artifact. This helps agents stay within context limits and reduce costs, since each step pulls in only the slice of the corpus it actually needs rather than the entire corpus.
>
> The virtual filesystem is therefore more than a storage abstraction. It is a context-management interface for agentic work.
>
> ## What is the MongoDB virtual filesystem for LangChain Deep Agents?
>
> The _langchain-mongodb-deepagents-vfs_ [package](https://github.com/langchain-ai/langchain-mongodb/tree/main/libs/langchain-mongodb-deepagents-vfs#langchain-mongodb-deepagents-vfs) is a drop-in implementation of Deep Agents’ _BackendProtocol_. It presents an object store-backed corpus as a filesystem to the agent and routes operations to the system that is best suited for them:
>
> * Search-oriented operations: _grep_, _glob_, and _ls_ run with MongoDB Atlas.
> * File-byte operations: _read_, _write_, _edit_, _upload\_files_, and _download\_files_ go directly to your object store.
> * A background synchronization layer keeps the MongoDB Search representation aligned with your object store.
>
> The result is a clean separation between the source of truth and the search index. Your object store owns the original documents. MongoDB Atlas stores the searchable chunks, embeddings, and path metadata needed to make the corpus discoverable.
>
> It's worth asking why the search plane should be a separate system like Atlas rather than an S3-compatible platform that also offers search, vector search, and hybrid search on the same data. The two-plane split isn't a limitation; it's the point. Object storage is optimized for durable, low-cost, long-term storage of file bytes; it isn't built to maintain live indexes, rank hybrid queries, or serve low-latency structured metadata queries simultaneously. Atlas is built as an operational database with Search, Vector Search, and hybrid ranking as first-class, indexed capabilities, so the search plane runs on a system designed for exactly that job, while the object store keeps doing what it's already good at.
>
> ### Hybrid search for agent queries
>
> The package uses MongoDB Search and MongoDB Vector Search together for grep. Full-text search is good at exact terms, identifiers, filenames, and rare strings. Vector search is good at paraphrases and natural-language questions. Combining both signals lets an agent search for a literal token, such as _MAX\_RETRIES_, or a conceptual question, such as "where is retry behavior configured?", through the same interface.
>
> The package combines the full-text and vector results with MongoDB’s [_$rankFusion_](https://www.mongodb.com/docs/manual/reference/operator/aggregation/rankfusion/) aggregation stage. This keeps ranking on the database side and avoids a separate client-side reranking layer, which would add an extra round trip between the agent and a separate reranking step. This also reflects a broader tradeoff in how the search plane is built. Getting full-text, vector, and hybrid ranking on an S3-compatible platform usually means wiring together separate specialized systems, a search engine for full-text, a vector database for embeddings, and a reranking layer to merge the two, each with its own indexing pipeline to keep in sync with the source data. Atlas runs all three in one engine, so $rankFusion can combine full-text and vector results natively in a single query instead of coordinating results across systems that don't know about each other.
>
> The current implementation uses a token-aware chunking pipeline. Supported document formats include plain text and Markdown, PDFs, DOCX, XLSX, XLS, PPTX, and PPT. Chunks retain positional metadata such as source path, page number, character offsets, and line information, so results can be returned in a Deep Agents-compatible, line-oriented shape.
>
> The default embedding path uses [Amazon Bedrock](https://aws.amazon.com/bedrock/) embeddings, with an OpenAI option available through the package extras. Applications can also inject a LangChain-compatible embedding implementation directly.
>
> A typical integration looks like this:
>
> ```python
> from deepagents import create_deep_agent
> from langchain_mongodb_deepagents_vfs import MongoFilesystemBackend
>
> backend = MongoFilesystemBackend(
>     s3_bucket_name="acme-docs",
>     mongodb_connection_string="mongodb+srv://<user>:<password>@<cluster>/",
> )
>
> agent = create_deep_agent(
>     tools=[],
>     instructions="You are a research assistant over the ACME documents corpus.",
>     backend=backend,
> )
> ```
>
> The agent can now use its normal filesystem tools without custom MongoDB or S3 tools in its reasoning loop.
>
> ## How the MongoDB VFS Backend separates storage and search
>
> The architecture can be understood as a two-plane system: object storage is the data plane for file bytes, while MongoDB Atlas is the control and search plane for metadata, chunks, and retrieval indexes.
>
> **Figure 1.** How the LangChain Deep Agents VFS backend routes file bytes through object storage and search operations through MongoDB Atlas.
>
> ![[mongodb-vfs-deepagents-001.png]]
>
> ### How the backend ingests files into MongoDB Atlas
>
> When _MongoFilesystemBackend_ is constructed, initialization begins in the background. Index provisioning, the initial synchronization, and watcher startup run on a daemon thread. Pass-through file operations can be used immediately, while search operations wait until the initial synchronization is ready.
>
> The ingestion path is:
>
> 1. List objects in the configured S3 bucket and prefix.
> 2. Download each eligible object.
> 3. Extract text using the format-specific parser.
> 4. Split the text into chunks with positional metadata.
> 5. Generate embeddings.
> 6. Upsert chunks and metadata into MongoDB Atlas.
> 7. Provision or verify the MongoDB Search and Vector Search indexes.
>
> The current chunking strategy uses 512-token chunks with a 64-token overlap. ETags make initial sync and watcher ingestion idempotent: unchanged objects can be skipped rather than re-downloaded and re-embedded.
>
> ### How the backend routes file and search operations
>
> When the agent calls _ls_, the backend queries Atlas for path metadata and groups the results as directory entries. When it calls _glob_, the backend applies standard path-pattern semantics to find matching files. When it calls _grep_, Atlas combines full-text and vector retrieval over the chunk corpus and returns ranked matches.
>
> When the agent calls _read_, the backend retrieves the current bytes from the object store rather than from the search index. That distinction is important: search results are optimized for discovery, while reads return the source document.
>
> ### How watchers keep the MongoDB Search Index current
>
> The package supports two watcher modes:
>
> * Polling watcher: periodically checks the object store and requires no additional AWS event infrastructure.
> * SQS watcher: consumes S3 event notifications through [Amazon SQS](https://aws.amazon.com/sqs/) and is intended for lower-latency production synchronization.
>
> The architecture is intentionally eventually consistent for search. A successful write reaches S3 first; the watcher then detects the change, re-chunks and re-embeds the object, and updates search indexes. As a result, _read_ reflects the S3 state immediately, while _grep_, _glob_, and _ls_ may lag until synchronization and search indexes are completed.
>
> For collaborative workflows, this suggests a practical rule: use direct reads for hot shared state, use _edit_ for optimistic concurrency on shared files, and use search for discovery across a settled corpus. Namespacing agent outputs, for example, _shared/outputs//_ can also reduce collisions between parallel workers.
>
> ## Enterprise use cases for a virtual filesystem backend
>
> ### Codebase-aware coding agents
>
> A coding agent can explore a large repository progressively rather than receive a massive code dump. It can list the project structure, locate files with _glob_, search for a concept or identifier with hybrid _grep_, read the exact file, and apply an ETag-protected edit.
>
> This pattern is useful for:
>
> * Repository onboarding and code navigation
> * Incident investigation
> * Dependency and configuration analysis
> * Test discovery and targeted remediation
> * Documentation generation from source code
>
> ### Private document intelligence
>
> Organizations often have large collections of policies, contracts, procedures, runbooks, product documents, and customer artifacts sitting in object storage. The backend provides an agent with a filesystem-like interface to that corpus.
>
> For example, a document agent can search for "refund policy for enterprise customers," locate the relevant passages even when the wording differs, read the source PDF or DOCX, and write a citation-ready summary or review artifact to a separate path.
>
> This is a natural fit for [retrieval-augmented generation](https://www.mongodb.com/docs/vector-search/tutorials/rag/#std-label-avs-rag) (RAG), where the agent needs to navigate rather than perform only one retrieval step.
>
> ### Multi-agent research and analysis
>
> A coordinator can delegate focused work to specialized subagents that share a common corpus:
>
> * A security agent searches for dangerous code patterns.
> * A documentation agent finds deployment steps and configuration references.
> * A test agent locates relevant test files and produces coverage notes.
> * A synthesis agent reads the outputs and writes a consolidated report.
>
> The shared filesystem provides each subagent with a consistent namespace, while MongoDB provides an intelligent discovery layer over the corpus.
>
> ### Long-running monitoring over changing data
>
> Enterprise document stores are not static. New reports arrive, policies change, and operational artifacts are updated. The watcher keeps the MongoDB Search representation aligned with the underlying object store, so an agent invoked later can search the current corpus without rebuilding an index for every run.
>
> This can support:
>
> * Operational runbook assistants
> * Compliance and policy monitoring
> * Research assistants over continuously refreshed datasets
> * Support agents over product and troubleshooting documentation
> * Partner solution assistants over shared implementation artifacts
>
> ### Durable workspaces for agent applications
>
> Deep Agents can create plans, intermediate notes, summaries, and generated deliverables as files. Persisting those artifacts in the object store while indexing them in Atlas gives an application a durable workspace that can survive process restarts and be inspected by people or other agents.
>
> For production systems, access control, tenant isolation, data residency, retention, and audit requirements should be enforced through the application, storage configuration, and the metadata model. The current package’s core responsibilities are the Deep Agents-compatible filesystem contract and the Object Store-to-Atlas search path.
>
> ## How to contribute to the LangChain MongoDB integration
>
> The package lives in the [_langchain-mongodb_](https://github.com/langchain-ai/langchain-mongodb) repository, and contributions are welcome. Start with the repository contribution guidelines, then explore the package tests and the existing backend boundaries.
>
> Potential contribution areas include:
>
> * Additional object-store backends, such as Azure Blob Storage or Google Cloud Storage
> * New embedding providers and configurable embedding strategies
> * Additional document parsers and ingestion optimizations
> * Watcher reliability, backfill, and freshness improvements
> * Search quality, filtering, ranking, and metadata enhancements
> * Better examples, documentation, benchmarks, and deployment guidance
>
> A useful design principle is to keep storage-specific behavior behind the object-store interface. That allows the chunker, embedder, synchronization logic, and search router to remain focused on paths, bytes, metadata, and search rather than a particular cloud storage API.
>
> ## Key takeaways: A persistent virtual filesystem for LangChain Deep Agents
>
> LangChain Deep Agents provide an agent-native way to plan, delegate, navigate files, and produce durable work. The MongoDB virtual filesystem for LangChain Deep Agents connects that experience to an enterprise-friendly storage pattern: your object store remains the source of truth for file bytes, while MongoDB Atlas provides the metadata, full-text search, vector search, and hybrid ranking that agents need to find the right context.
>
> The most important idea is the separation of concerns. Agents see one simple virtual filesystem. Applications can store large, heterogeneous documents in object storage. Atlas turns those documents into a searchable knowledge surface, and the synchronization layer keeps discovery aligned with the live corpus.
>
> ###### Next Steps
>
> Explore the implementation, examples, and contribution path in the [LangChain Deep Agents VFS Backend for MongoDB package](https://github.com/langchain-ai/langchain-mongodb/tree/main/libs/langchain-mongodb-deepagents-vfs).  
>
> Ready to start building? [Register for Atlas](https://www.mongodb.com/products/platform/atlas-database) and get started for free today. 
