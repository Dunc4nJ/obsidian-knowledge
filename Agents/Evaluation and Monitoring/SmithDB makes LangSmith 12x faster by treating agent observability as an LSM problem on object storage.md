---
created: 2026-05-14
description: LangChain rebuilt the LangSmith data layer as SmithDB — a Rust object-storage LSM with custom DataFusion plans, sticky cluster routing, and time-tiered compaction — because modern agent traces broke every general-purpose observability store they tried.
source: https://www.langchain.com/blog/introducing-smithdb
type: learning
---

## Key Takeaways

- **Agent traces have outgrown general-purpose observability stores, so LangSmith stopped patching and rebuilt the storage layer.** Modern agent traces have hundreds of deeply nested spans, multi-modal payloads, and spans that stay open for minutes or hours between start and end events. That shape kills systems designed around the request/response trace assumption — the same diagnosis [[Brainstore turns AI observability into database-native trace architecture for long-horizon agents|Braintrust reached when they built Brainstore]] and the architectural pressure [[agents fail without trace architecture because reasoning evaporates when the context window closes|trace architecture]] is meant to absorb.
- **The chosen primitive is an object-storage-backed LSM with stateless compute, not a sharded cluster with local disks.** Writes batch into immutable segments in object storage; a small Postgres metastore tracks segment metadata; ingestion, query, and compaction services are stateless and scale by adding compute. This is the same architectural move that lets [[agent trace data should live in your data lake not a 30-day SaaS retention window|trace data live in customer-controlled object stores]] and makes self-host plus multi-cloud deployments tractable instead of nightmarish.
- **The query engine is custom Rust on Apache DataFusion plus Vortex, with execution plans that understand LangSmith semantics — not generic SQL over Parquet.** Progressive querying walks backwards through time to bound "newest N runs" scans; the planner reads hot data directly off the writing ingestion node's SSD/memory before it lands in object storage; and a cluster manager (inspired by Google Slicer and Databricks Dicer) does sticky routing so repeated queries land on nodes that already have the relevant segments cached. Generic columnar warehouses cannot do any of this without giving up the layout.
- **A run is modeled as a sequence of events, not an immutable row, because agent spans stay open for hours.** This forces every layer to fan filters out to specific events and merge at read time, and it reshapes the compaction strategy entirely. Time-tiered compaction defers rewriting recent segments (which are still receiving end events and updates) and aggressively collapses older ones. Combined with deletion vectors on the metastore instead of synchronous file rewrites, this is what makes per-trace retention rules and TTL changes scalable — the design point [[Agno native tracing keeps agent observability data in your own database|own-database tracing systems]] aim for but rarely achieve.
- **Reported P50 latencies — 92ms trace tree load, 82ms run filtering, 400ms full-text search over 1MB+ payloads — make trace tooling fast enough to be part of the agent dev loop.** A custom inverted index laid out for object storage (term row groups with min/max zones, separately chunked postings/positions, prune-before-fetch) is the unsexy enabling work behind the headline numbers. SmithDB now serves 100% of US Cloud ingestion and tracing UI queries; this is the data layer LangChain expects to support all future LangSmith features and self-hosted deployments.

## External Resources

- [Log-structured merge tree (Wikipedia)](https://en.wikipedia.org/wiki/Log-structured_merge-tree) — the core write-buffer-then-compact storage pattern SmithDB is built around.
- [Slicer (Google research)](https://research.google/pubs/slicer-auto-sharding-for-datacenter-applications/) — auto-sharding system that inspired SmithDB's cluster manager for sticky routing.
- [Dicer (Databricks)](https://www.databricks.com/blog/open-sourcing-dicer-databricks-auto-sharder) — open-source auto-sharder Databricks built on the same ideas; the second named influence on SmithDB's cluster layer.
- [In software the code documents the app, in AI the traces do (LangChain blog)](https://www.langchain.com/blog/in-software-the-code-documents-the-app-in-ai-the-traces-do) — the linked framing post for why traces are the canonical agent behavioral record.
- [LangChain Careers](https://www.langchain.com/careers) — hiring page; LangChain is recruiting systems and database engineers for the SmithDB team.
- [Try LangSmith](https://smith.langchain.com/) — the LangSmith product surface now backed by SmithDB.

## Original Content

> [!quote]- Source Material — "We built SmithDB, the data layer for agent observability" by Ankush Gola, LangChain blog, 2026-05-13
>
> # We built SmithDB, the data layer for agent observability
>
> *Ankush Gola — May 13, 2026 — 11 min read*
>
> *SmithDB Announcement card*
>
> ## Key Takeaways
>
> - **Agent traces have outgrown traditional observability stores** — modern agent traces contain hundreds of nested spans, multi-modal content, and spans that stay open for hours, creating data volumes and query patterns that general-purpose databases were never designed to handle.
> - **SmithDB delivers industry-leading performance across every key observability workload** — with P50 latencies of 92ms for trace tree loads, 400ms for full-text search, and 82ms for run filtering, it makes core LangSmith experiences up to 12x faster than before.
> - **A portable, scalable architecture built for enterprise needs** — backed by object storage with stateless ingestion and query services, SmithDB scales by adding compute rather than managing local disks, making it straightforward to deploy in self-hosted and multi-cloud environments.
>
> We're launching SmithDB, our purpose-built distributed database for agent observability that now backs core LangSmith workloads.
>
> SmithDB gives LangSmith industry-leading performance across key observability workloads, the portability to run wherever customers need their data to live, and the flexibility to support agent-native query patterns that traditional observability stores were not designed for.
>
> ## Agents present a new data problem
>
> In agent observability, traces serve as the agent's [core behavioral record](https://www.langchain.com/blog/in-software-the-code-documents-the-app-in-ai-the-traces-do).
>
> When LangSmith first launched in 2023, AI applications were relatively simple: teams were building RAG pipelines, prompt chains, and very early agents.
>
> Since then, agents have become more ubiquitous and longer running, LLM context window sizes have increased dramatically, and workloads increasingly contain more multi-modal content, such as images and audio.
>
> As a result, the trace data associated with modern agents has exploded in both volume (number of traces) and size (individual payload size). A modern agent trace can have hundreds of deeply nested spans.
>
> *Agent trace payload size trends over time*
> ![[langchain-smithdb-001.png]]
>
> *Example: a single chatOpenAI run in LangSmith*
> ![[langchain-smithdb-002.png]]
>
> In addition to being large and nested, agent traces also arrive in pieces: a start event for an agent span can arrive minutes, maybe even hours before an end event.
>
> The query patterns needed to analyze this data have also gotten increasingly complex. Agent observability needs to support:
>
> - **Random access:** instantly load an individual run or trace
> - **Interactive filtering:** slice large trace datasets by metadata, feedback, latency, errors, tags, and time
> - **Full-text search:** find phrases and patterns inside agent run inputs and outputs
> - **JSON filtering:** query arbitrary user-defined metadata and structured tool outputs
> - **Tree-aware queries:** filter based on root runs, child runs, or any node in a trace
> - **Thread reconstruction:** rebuild long-running conversations across many agent traces instantly
> - **Aggregations:** compute cost, latency, token usage, evaluator scores for different filters
>
> Supporting all of them, at low latency, over large agent traces, with self-hosting and multi-cloud requirements, requires a fundamentally new architecture.
>
> That is the motivation behind SmithDB.
>
> ## Introducing SmithDB
>
> SmithDB is LangSmith's data layer purpose-built for agent observability and evaluation workloads.
>
> It is built in Rust and leverages the Apache DataFusion query engine and Vortex file toolkit, with heavy customizations for LangSmith's unique workloads.
>
> At a high level, SmithDB is made of three components:
>
> 1. **Object storage** for durable trace data
> 2. **A small Postgres metastore** for segment metadata
> 3. **Stateless ingestion, query, and compaction services**
>
> *SmithDB architecture diagram*
> ![[langchain-smithdb-003.png]]
>
> ### Performance
>
> Performance is not just a nice-to-have for observability. For both humans and agents, slow observability tools become a bottleneck in the agent development loop. SmithDB delivers leading performance across the key workloads that matter for agent observability and makes core LangSmith experiences up to 15x faster than before.
>
> | Workload          | SmithDB latency       |
> | ----------------- | --------------------- |
> | Trace tree load   | P50 92ms / P99 595ms  |
> | Single run load   | P50 71ms / P99 358ms  |
> | Runs filtering    | P50 82ms / P99 434ms  |
> | Trace ingestion   | P50 630ms / P99 1.47s |
> | Full-text search  | P50 400ms / P99 870ms |
> | Threads filtering | P50 131ms / P95 268ms |
>
> ### Portability
>
> Because SmithDB is backed by object storage, there are no local disks to manage. Query and ingestion services are stateless. The system scales by adding compute, while durable data lives in object storage.
>
> This makes SmithDB much easier to deploy in self-hosted and multi-cloud environments than traditional database clusters that require local disks and complex sharding.
>
> ## SmithDB is now serving production traffic
>
> Today:
>
> - **100% of US Cloud ingestion** goes to SmithDB
> - **100% of tracing UI query traffic** goes to SmithDB, including threads
> - **All major filters** are backed by SmithDB, including metadata, feedback, text search, tree filters, and trace filters
> - Product integrations like run rules, bulk export, and experiments are nearing completion
>
> Soon:
>
> - All relevant product surface will be ported over to SmithDB and SmithDB will be available for self-hosted deployments of LangSmith
>
> ## Early feedback
>
> We've been migrating customer workloads to SmithDB over the past few months. Here's what teams at Clay, Vanta, Unify, and Cogent are saying:
>
> > *We log hundreds of millions of agent observability events to LangSmith every day. SmithDB has made it possible for our team to search, debug, and analyze that data at the speed we need to improve our agents in production. The performance improvements are immediately noticeable and impressive, especially on large projects where trace exploration used to be a bottleneck.*
> >
> > — Jeff Barg, Head of AI at Clay
>
> > *Since moving to SmithDB, the performance improvements have been immediately noticeable. Our UX feels significantly snappier, and it's made digging into our data faster and more intuitive than ever. It's been a great experience.*
> >
> > — Andy Almonte, Senior Engineering Manager, AI at Vanta
>
> > *We have a lot of traces with large tool calls and after migrating to SmithDB, querying for and reading through traces across our projects has been much easier to do. This has helped us pinpoint edge cases, build eval datasets, and iterate on our traces much faster than before.*
> >
> > — Kunal Rai, Software Engineer, AI at Unify
>
> > *At Cogent, our background agents can produce a huge volume of traces all at once. We need live observability into those systems, and SmithDB has been able to deliver that experience: seeing traces in seconds instead of minutes, which is what we experienced when testing other providers.*
> >
> > — Larsen Weigle, Member of Technical Staff at Cogent Security
>
> ## Key engineering challenges
>
> There was an insane amount of engineering effort that went into making SmithDB an extremely performant database for agent observability workloads.
>
> At a high level, SmithDB is built as an object-storage backed [log-structured merge tree](https://en.wikipedia.org/wiki/Log-structured_merge-tree) (LSM). An LSM buffers writes in memory, flushes them to durable storage as immutable sorted batches, and periodically compacts those segments together. At query time, multiple segments are read and merged together as a single ordered stream.
>
> SmithDB has five main components:
>
> - **Ingestion service:** accepts trace writes, batches them per partition and time bucket, and writes immutable files
> - **Metastore:** records segment metadata, including location, time bounds, row counts, and update/delete vectors
> - **Query service:** exposes a query interface, with custom execution plans that understand LangSmith run semantics and object storage. SSD and memory caching are leveraged heavily.
> - **Compaction service:** rewrites write-optimized segments into query-optimized segments while applying deletes, upgrades, TTL expiry and index merging
> - **Cluster manager:** assigns live service nodes to key ranges. This matters because SmithDB is not only trying to distribute load; it is also trying to make repeated queries land on nodes that are likely to have the right data cached.
>
> Here are details on some of the key engineering challenges, which we'll expand on in future blog posts:
>
> ### Progressive querying over object storage
>
> Many LangSmith queries ask for the newest runs for a particular tenant and tracing project. A naive object-store plan would discover all candidate files, open many of them, sort-merge and deduplicate the data, and only then apply the limit.
>
> SmithDB walks backward through time and builds a bounded time window over the newest candidate segments. This turns "sort everything, then limit" into "read the newest bounded slice, stream, merge and dedupe rows, and stop as soon as correctness allows" which significantly cuts down on the data scanned to fulfill "Top K" style queries.
>
> *Progressive querying — bounded backward time-window scan over the newest segments*
> ![[langchain-smithdb-004.png]]
>
> ### Reading fresh data from ingestion nodes
>
> Object storage is the durable source of truth, but the freshest data often still exists on the ingestion node that wrote it.
>
> Each file segment records the server identifier of the node that produced it. If that writer is still online, the query planner can use a custom plan to scan those files directly from the ingestion node's local SSD and memory cache instead of immediately reading them back from object storage. This prevents us from having to read dozens of small files from object storage to fulfill leading-edge queries.
>
> *Query planner reading fresh data straight off the originating ingestion node*
> ![[langchain-smithdb-005.png]]
>
> ### Multiple events per run
>
> Agent observability is built around long-running spans.
>
> In a traditional request/response application, a span may start and finish within milliseconds. But agent spans can stay open much longer. A single run may involve model completion, tool calls, retries, background work, or handoffs to other agents. Waiting until the span finishes before writing anything would be less than ideal.
>
> In SmithDB, a run is a sequence of events, not a single immutable row. This sounds simple, but it affects the entire query engine. Extra care is taken to fanout filters to target specific events and merge events at query time in an efficient manner. Handling these multiple events per run also affects our compaction strategy.
>
> *A run modeled as a sequence of events rather than a single immutable row*
> ![[langchain-smithdb-006.png]]
>
> ### Time-tiered compaction
>
> Ingestion optimizes for write latency, which produces many small immutable segments. Querying those forever would create too much file-open overhead and deduplication work.
>
> Compaction turns those write-optimized segments into query-optimized segments. SmithDB uses a time-tiered strategy. Time-tiering decides how aggressively SmithDB should do this work. Recent data is more likely to receive end events, so compacting it into huge files too early would create unnecessary write amplification. Older data is more stable and more likely to be scanned repeatedly, so it is worth collapsing into larger files.
>
> This keeps ingestion fast while gradually making older data cheaper to query.
>
> ### Deletes, TTL, and Retention changes
>
> Mutations like deletes and upgrades are often difficult in observability systems because the data files are immutable. By default, SmithDB does not rewrite a data file synchronously for every delete. Instead, the metastore attaches deletion and upgrade vectors to segment entries. Query and compaction paths use those vectors to interpret the immutable file correctly. File rewrites occur during compaction.
>
> This strategy makes mutations highly scalable in SmithDB. This matters especially for agent observability because retention is rarely uniform. Most traces are useful for recent debugging, monitoring, and evaluation, but only a small subset need to be retained for a long time based on the content of the particular trace.
>
> ### Late materialization of large fields
>
> Agent traces often contain large, unbounded payloads. SmithDB keeps common list and filter queries fast by separating core run fields from large fields. Core rows carry pointers to large-field files, and the query engine only fetches those large payloads when the query actually projects them.
>
> This means loading a run list or applying filters does not require reading megabytes of JSON unless the user actually opens the run or asks for those fields.
>
> ### Full-Text Search and JSON Filtering
>
> Supporting sub-second full-text search and JSON key-path filtering on 1MB + payloads is a challenging engineering problem.
>
> SmithDB handles these queries efficiently through a custom inverted index layout optimized for object storage. On local disk, an index can rely on cheap seeks and many small reads. On object storage, that pattern falls apart: every unnecessary request adds latency, and fetching large postings or positions lists too early can dominate the query.
>
> SmithDB's index layout is built to avoid that. Terms are sorted into row groups, and every row group records min/max term zones. Exact and prefix term queries can therefore prune index row groups before SmithDB fetches postings bytes. The postings and positions are chunked separately from the term dictionary, so common terms do not force one huge in-memory allocation or one huge object-store range read. Row-group and chunk thresholds bound both builder memory and query-time I/O.
>
> ### Cluster management and sticky routing
>
> SmithDB includes a lightweight cluster manager that controls which service nodes own which traffic. This matters because SmithDB is not only trying to distribute load. It is also trying to make repeated queries land on nodes that are likely to have the right data cached.
>
> The cluster manager, inspired by [Google's Slicer](https://research.google/pubs/slicer-auto-sharding-for-datacenter-applications/) and [Databrick's Dicer](https://www.databricks.com/blog/open-sourcing-dicer-databricks-auto-sharder) project, avoids that by dividing the keyspace into slices and assigning each slice to a stable set of service nodes. Routers use those assignments to send related requests to the same node or small replica set.
>
> That gives SmithDB two important properties:
>
> - **Sticky routing:** related requests have a higher chance of landing on a node that already has the right cached metadata or segment bytes.
> - **Adaptive balancing:** when nodes join, leave, or become overloaded, the cluster manager can move slices without changing durable segment metadata.
>
> ## What's next
>
> In addition to migrating more of the LangSmith UI to be backed by SmithDB, we're super excited about the new product experiences this data layer unlocks.
>
> The next phase of LangSmith is not just faster trace loading. It is making trace data more useful: easier to search, easier to analyze, and easier to feed back into the agent development loop. SmithDB will serve as the foundational layer to make that possible.
>
> We're also looking for talented systems and database engineers to [join us!](https://www.langchain.com/careers)
>
> [Try SmithDB](https://smith.langchain.com/)

---

Source: <https://www.langchain.com/blog/introducing-smithdb>
