---
created: 2026-05-18
description: Evokoa's pgGraph compiles Postgres relationships into a memory-mapped Compressed Sparse Row graph layer so AI agents can run 10-plus-hop traversals in microseconds, after Apache AGE's recursive-SQL emulation chokes on the Postgres planner past 3 hops.
source: https://x.com/daleverett/status/2056049481096061311
type: framework
---

## Key Takeaways

- pgGraph's central claim is that **for AI agents the bottleneck is no longer the model — it is data access**, specifically deep multi-hop graph traversal that recursive SQL cannot serve in real time. Apache AGE emulates edges as relational rows or JSONB and asks the Postgres planner to walk them via recursive joins; that works at 2-3 hops but blows up the working set and times out at 10-15 hops over multi-million-edge graphs, the regime agent reasoning and enterprise operational intelligence actually need. This reframes the "graph DB vs RAG" debate raised in [[Neo4j's Stephen Chin on agentic graph RAG - vector search finds entry points and graph traversal supplies grounded context]] as fundamentally an execution-engine problem, not a query-language one.
- The architectural move is **compiling edges out of tables and into a Compressed Sparse Row (CSR) memory-mapped array** — the same data structure HPC and GPU graph algorithms use — so finding a node's neighbors collapses to a single array-offset calculation in a tight CPU loop, with no B-tree lookups, no joins, and no recursive planner. Postgres remains the source of truth and SQL surface; pgGraph is a virtual layer alongside it. This is the same "discard the heavy abstractions, build a primitive sized to the hot loop" pattern that [[How to Make Knowledge Graphs Fast - query optimization combines triple indexing, adjacency compression, and partitioning to tame exponential traversal fan-out]] documents at the algorithmic level — pgGraph just pushes it down to memory layout.
- The published benchmarks (Hot Run, persistent psycopg backend) on LDBC's 3.1M-node / 34.5M-edge social graph show **Friend Traversal Depth 1 at 34.1 ms, Post-to-Tag Path at 6.5 ms, Tag-to-Tagclass at 7.0 ms**, with Cold Run figures 30-100x slower. AGE is deliberately not plotted because deep traversals on these datasets simply timed out under recursive SQL. Treat these as vendor numbers — the qualitative point holds (CSR walks demolish recursive joins at depth) but the absolute milliseconds are best taken as an upper bound on what an open-source CSR layer over Postgres can deliver before independent replication.
- pgGraph's design thesis is that **agents do not need the feature surface of a traditional graph database** — no sprawling Cypher, no heavy transactional abstractions, no multi-tenant ACL machinery — they need raw real-time structural context. Author Dale Everett frames this as the Unreal-Engine-vs-offline-CGI inflection: feature-rich graph DBs are CGI, AI agents need a real-time engine. This aligns with the broader infrastructure shift toward [[databases are becoming the runtime layer for AI agents as application logic collapses into the data layer]] and the related point in [[Kimi K2.6 chose TiDB because agent-native databases need constraint completeness over single-point optimality]] that agent workloads invert the conventional database optimization targets.
- The strategic bet is that **the next layer of knowledge infrastructure has to be open** so it can be built into existing Postgres stacks the moment data is created, not after six-month integrations — Apache OSS license, Rust implementation, no openCypher (yet), specialized SQL-backed search patterns instead. The honest tradeoff: pgGraph is not a drop-in AGE replacement and trades query-language portability for memory-model specialization. Useful sibling lens: [[most agent bottlenecks are actually memory problems not model or orchestration problems]] argues memory is the durable moat for agents; pgGraph is the same argument projected onto the read-path of structured relationship data, not onto LLM context windows.

## External Resources

- [pgGraph on GitHub (Evokoa/pgGraph)](https://github.com/Evokoa/pgGraph) — Apache-licensed Rust implementation of the in-memory CSR virtual graph layer over Postgres, linked from the post.
- [Apache AGE](https://age.apache.org) — the recursive-SQL Cypher-on-Postgres extension that pgGraph benchmarks against and positions as complementary, not competitive.
- [LDBC Social Network Benchmark](https://ldbcouncil.org/benchmarks/snb/) — the 3.1M-node / 34.5M-edge benchmark dataset used for the deep-traversal numbers in chart 3.
- [Evokoa Discord](https://discord.com) — community/support channel posted as a t.co shortlink in the follow-up tweet.

## Original Content

> @daleverett — 2026-05-17
>
> Article: Why pgGraph unlocks a new future for AI that wasn't possible before.
>
> pgGraph (Apache OSS) is a new breakthrough architecture that is the missing primitive for deep AI reasoning. It solves the catastrophic breakdown of AGE when doing deep queries.
>
> You can view pgGraph's Github repo [here.](https://github.com/Evokoa/pgGraph)
>
> *Title card: Evokoa pgGraph vs. Apache AGE — performance and architectural comparison*
> ![[daleverett-061311-001.jpg]]
>
> **How they both work**
>
> AGE converts Cypher queries into recursive SQL calls inside Postgres. This works well for simple queries, but breaks down as paths get deeper.
>
> In contrast, pgGraph creates a highly optimized virtual graph layer completely in-memory.
>
> Postgres remains your single source of truth and primary query interface, while pgGraph handles the deep relationship traversals (including 10+ hop paths) at bare-metal speeds.
>
> **Different Execution Models**
>
> To understand why this architectural divergence matters, we need to look at how traversals are executed. Apache AGE translates Cypher queries into recursive work inside the Postgres execution planner. It stores graph topology using standard relational rows or JSONB columns.
>
> When you execute a traversal, the database has to perform complex recursive SQL joins, chasing pointers across B-tree indexes. For simple, 2-hop or 3-hop queries, this relational emulation works fine.
>
> But AI agent workloads and enterprise operational intelligence do not stop at 3 hops. When you push AGE-style recursive calls to 10 or 15 hops across a multi-million edge dataset, the Postgres execution planner chokes. The recursive joins explode the working memory set. Latency degrades from milliseconds to seconds, and eventually, the queries simply timeout.
>
> **Built for Deep Traversal**
>
> When we built Evokoa, we realized that to get microsecond latency at 20-hop depth, we could not rely on the Postgres query planner to walk edges. Emulation was not enough. We needed a data structure built specifically for traversal.
>
> Instead of emulating edges in tables, pgGraph compiles your Postgres relationships into a highly compact, memory-mapped virtual graph layer. We use a Compressed Sparse Row (CSR) array format (the same structure used in high-performance scientific computing and GPU algorithms)
>
> In this in-memory virtual layer, finding a node's neighbors does not require an index lookup or a table join. It requires a single array offset calculation. There are no pointers to chase. There are no recursive SQL statements. The CPU simply walks contiguous blocks of memory in a hot loop.
>
> **pgGraph Performance at Scale**
>
> To demonstrate the power of the in-memory virtual graph layer, we ran extensive benchmarks on pgGraph using two distinct datasets: the PANAMA dataset (2M+ nodes) and the massive LDBC Social Network Benchmark (3.1M+ nodes, 34.5M+ edges).
>
> Note: These benchmarks measure pgGraph's performance in isolation. We do not plot Apache AGE here, as deep traversals (10+ hops) on datasets of this size resulted in query timeouts under the recursive SQL model.
>
> *PANAMA dataset (2,016,523 nodes / 5,802,586 edges) — Hot Run vs Cold Run latencies across Status, Entity Search, Traverse Depth 2, Shortest Path, Component Stats, and Largest Component*
> ![[daleverett-061311-002.jpg]]
>
> **Methodology**
>
> - Cold Run: Docker container restart before each cold query; excludes graph.build(); OS cache may remain warm depending on host.
>
> - Hot Run: one unrecorded warm-up pass, then repeated measured SQL in one persistent psycopg PostgreSQL backend.
>
> *LDBC Social Network Benchmark (3,181,724 nodes / 34,512,076 edges) — Hot Run holds Friend Traversal Depth 1 at 34.1 ms, Post-to-Tag Path at 6.5 ms, Tag-to-Tagclass at 7.0 ms; Cold Run figures sit 30-100x higher*
> ![[daleverett-061311-003.jpg]]
>
> **Reflection and Analysis**
>
> The numbers speak for themselves.
>
> In the "Hot Run" execution path, where the in-memory graph layer is fully warmed up and served by a persistent psycopg PostgreSQL backend, pgGraph delivers microsecond and low-millisecond latencies across complex pathfinding and deep traversal queries.
>
> Even for the massive 34.5 million edge LDBC dataset, a deep "Friend Traversal" executes in just 34.1 milliseconds, and "Post To Tag Path" queries complete in under 7 milliseconds.
>
> **Why We still love AGE**
>
> We didn't write this to hate on AGE. pgGraph is not a drop-in replacement for AGE. We do not support openCypher (yet hehe), opting instead for specialized SQL-backed search patterns optimized for our memory model.
>
> But our ongoing conversations with engineers have crystallized a core thesis: for AI workloads, you can strip away almost all of the bloated features of a traditional graph database.
>
> Agents don't need sprawling query languages or heavy transactional abstractions. They need raw, real-time structural context.
>
> **History is repeating itself**
>
> The evolution here mirrors the history of computer graphics. Traditional graph databases are like offline CGI rendering, incredibly feature-rich, capable of modeling anything, but fundamentally too slow for real-time interaction.
>
> What AI agents actually need is an Unreal Engine. They need a system designed from the ground up for a real-time hot loop, stripping away everything that doesn't serve the immediate traversal.
>
> pgGraph applies that exact mindset to Postgres data. By discarding the heavy abstractions of relational emulation and compiling edges into a bare-metal CSR array, we achieve graph traversals at speeds that standard Postgres query planners physically cannot match.
>
> If you are hitting performance ceilings because your application requires deep structural context, 10+ hop paths, and real-time reasoning loops, recursive SQL will not scale.
>
> You don't need a heavier database; you need a dedicated, hyper-optimized virtual graph layer.
>
> **Everything will be AI-native within a decade.**
>
> The bottleneck is not models. It is data access. The communities that win will be the ones whose data is traversable by agents the moment it is created, not after a six-month integration project.
>
> We believe pgGraph belongs to the same long arc as the technologies that made knowledge legible to more minds: writing, libraries, the web, and now agents. Human civilization advanced when ideas could be read, linked, and passed forward. AI will advance when data can be understood in motion: not locked away in systems, but connected, queryable, and alive from the moment it is made.
>
> That is why we built pgGraph. And that is why we are open-sourcing it: so the next layer of knowledge infrastructure is not owned by a few, but built in the open by the communities it will serve.
>
> Docs & repo linked below.
>
> #postgres #apache #rust
>
> Engagement: 30 likes | 5 retweets | 3 replies
> [Original post](https://x.com/daleverett/status/2056049481096061311)

---

Follow-up from the same author, four minutes later:

> @daleverett — 2026-05-17
>
> Repo: https://github.com/Evokoa/pgGraph
> Discord: (Evokoa community Discord, posted as t.co/rOlImTVheJ)
>
> [Original post](https://x.com/daleverett/status/2056050566309294245)

Reply chain — a community member asks about use cases and the author responds with a concrete example:

> @NevvDevv — 2026-05-17
>
> @daleverett 🔥
>
> [Original post](https://x.com/NevvDevv/status/2056057583031497119)

> @mc_ees — 2026-05-17
>
> @daleverett What are some cool use cases?
>
> [Original post](https://x.com/mc_ees/status/2056076147042222472)

> @daleverett — 2026-05-17
>
> @mc_ees Real-time fraud detection! Experimenting with ingesting crypto blockchains right now to map movements from whales wallets (the multi-hop should allow us to track all these small transactions in microseconds)
>
> [Original post](https://x.com/daleverett/status/2056079808115978723)
