---
created: 2026-09-08
description: Archil founder Hunter Leath argues every cloud workload -- Neon, PlanetScale, Clickhouse, Vercel webserving, CI/CD, sandboxes -- is the same compute plus SSD plus object-storage shape with different parameters, so one generic write-ahead log over S3 that speaks POSIX out of the box can be the last WAL anyone has to build; includes a five-rung durability-versus-write-latency ladder placing E2B sandboxes at 1-3us and "no ack until S3" at 50-100ms.
source: https://x.com/jhleath/status/2090847398625235198
type: framework
---

## Key Takeaways

- **The reduction is the whole thesis: "actually all infrastructure workloads are exactly the same."** Neon, PlanetScale, Clickhouse, Vercel webserving, CI/CD and sandboxes are all compute + high-performance SSD + low-performance object storage, and what separates them is parameters, not architecture — how many compute nodes point at one storage backend (OLTP: one writer plus lagged read-replicas; OLAP: many, for map-reduce), and how much data must be resident on SSD before the compute can serve. PlanetScale needs 100% resident (that is the replica catch-up time when a node fails or the cluster grows); Neon tiers to S3 and does not; Docker images need full residency, "causing poor cold starts"; sandboxes lazily materialize so the server starts while data streams in, the same lever behind [[Opencomputer reframes harness-vs-sandbox debate as git branches for VMs via hibernation egress proxies and checkpoints|Opencomputer's hibernation-and-checkpoint argument]]. Leath's move is to make those knobs a customer-facing API — "I want X% of the data to tier down to slow object storage" — which is the same collapse-into-one-substrate argument as [[Lakebase puts Postgres on open object storage as a third database generation - O(1) branching, sub-500ms compute start, and 7x space amplification as the price|Lakebase's third database generation]], [[Kimi K2.6 chose TiDB because agent-native databases need constraint completeness over single-point optimality|Kimi's constraint-completeness case for TiDB]], and the broader claim that [[databases are becoming the runtime layer for AI agents as application logic collapses into the data layer|the data layer is becoming the runtime]] — pushed one layer lower, into storage.

- **This is the third independent WAL-on-S3 design the vault has captured, which makes it a pattern rather than a coincidence.** [[Lakebase puts Postgres on open object storage as a third database generation - O(1) branching, sub-500ms compute start, and 7x space amplification as the price|Lakebase]] puts the Postgres WAL in object storage behind Safekeepers and Pageservers; [[Cursor's Continuity replaces GitHub Spokes three-phase commit with an S3 write-ahead log as the source of truth for Git hosting|Cursor's Continuity]] serializes a Git log with atomic CAS on S3 and recovers read correctness with ETag-conditional GETs; Archil is doing it as the storage product itself. Leath names the convergence directly — Neon did it with Postgres, Turbopuffer with FAISS, Cursor Origin with Git — and grants that the log is commodity: "There are millions of people who have written write-ahead logs on S3, and libraries that you can use to format that log and manage compaction." His differentiation claim is that the value is the *rest* of the system: a durable place to acknowledge writes before S3 (hence "millisecond and microsecond commit latencies"), managed caching, and the compute to run beside it.

- **The durability ladder is the post's one quantitative artifact, and it is Leath's estimation of competitors, not a benchmark.** Five rungs, each with a per-write cost: no durability / in-memory at **1-3us** (sandboxes, E2B); local disk durability at **10-100us** (Vercel Drive, Sprite Block Device, exe.dev); replicated zonal SSD at **200-700us** (PlanetScale, Celld); replicated regional SSD at **1.3-2.0ms** (Neon); no ack until S3 at **50-100ms** (Cursor Origin, Turbopuffer). Read the hedges in the prose and the figure together — "only confirmed in E2B code", "[from what they're saying]", and question marks on two of the boxes. His verdict is a claim, not a measurement: the only reason to pick the 50-100ms rung is to avoid running a stateful SSD tier, and "it doesn't seem to be that there's any real benefit to doing this." The self-serving corollary follows immediately — don't "implement raft" yourself, "Use a provider like Archil."

- **POSIX is the interface bet, chosen for reach rather than elegance, and it inverts what the neighbours did.** Two design choices compose: virtualize *the file system itself* (inodes, directory entries) rather than a narrower view, and accept the full POSIX command set rather than the minimal one — "streams only have Append, Cursor Origin only supports 'pushes'." The justification is adoption surface: "the vast majority of software ever written (and that ever will be written) is written for the file system (including SQLite, Postgres, vector storage, even RocksDB)," so skipping POSIX "locks you out of this set of software forever" — the same reach argument [[AgentFS]] makes by mounting its database-backed store over FUSE and NFS. He also claims POSIX is a superset of S3 — "PutObject is just file writes and an atomic rename [+ some directory nonsense]" — which is why an S3-compatible API already ships on top. That is the same wager as [[Bash is the SQL for file systems and Archil proves it with serverless execution that sends instructions not data|Archil's earlier bash-as-SQL post]] and the direction [[Amazon S3 Files ends the object-file split for AI agents|Amazon S3 Files]] moved from the other side; note that the [[MongoDB's VFS for LangChain Deep Agents redefines grep as server-side hybrid search, splitting file bytes in S3 from a searchable chunk plane in Atlas|MongoDB VFS]], [[a virtual filesystem over Chroma replaces sandboxes for agent doc exploration at 100ms instead of 46 seconds|Chroma]] and [[Leonie reimplements Mintlify ChromaFs as a virtual filesystem over Elasticsearch in an open-source POC|Elasticsearch]] VFS designs take the opposite bet, keeping a narrow purpose-built surface. One sentence is genuinely ambiguous — "POSIX is [nearly always] net-negative ROI" appears to invert his own argument, and a reader flagged it in the replies without a correction landing.

- **Total ordering is named as the scalability enemy, with three concrete mitigations and an asymmetry between reads and writes.** A WAL "necessarily implies a total ordering of everything that happens on the system," which means "a single mutex somewhere." The three fixes: split raw data upload (to parts objects in S3) from the log append (a single CAS operation) to shrink the critical section; group-commit more than one operation per critical section; and shard into parallel sub-logs that provide no total ordering among themselves. Reads are the easy direction — add caches, and the problem degrades to invalidation, "which is strictly more tractable." The claim that a generic system must do "all of this simultaneously" is asserted, not demonstrated, and the mutex-under-load failure is exactly the class of thing that bites when [[seven runtime failures emerge when demo agents meet production distributed systems|demo agents meet production distributed systems]].

- **What the post actually commits to shipping, versus what is roadmap.** Present tense: a custom client exposing FUSE, an S3-compatible API, multi-AZ replication by default, configurable write quorum down to acknowledge-without-writing, optional PlanetScale-style local-disk-plus-cross-AZ, synchronous or lazy read materialization, client-side fan-out across servers, and NVMe-only or tier-to-S3 placement — serving CI/CD, agent platforms, model training, OLTP and analytics customers. Future tense: kernel-mode instead of FUSE, `AppendObject` and prefetch primitives. In the replies Leath answers the sharpest objection — S3 p99 PUT latency — with "we write to NVME and only flush to s3," which is exactly the pre-S3 durable ack layer the post argues is the real product, and the same durability-tier question that shapes [[Harvey Spectre makes durable runs the core primitive while workers stay ephemeral and sandboxes enforce explicit boundaries|Harvey Spectre's durable runs]], [[Browser Use stitches stateless Lambdas into multi-hour browser agents via S3 checkpoints and SQS continuations|Browser Use's S3 checkpoints]], and the cold-start economics behind [[Firecracker microVMs became the convergent agent runtime because containers were never a security boundary|Firecracker]] and [[Local-first agent sandboxes converge on libkrun not Firecracker because macOS has no KVM so Hypervisor framework is the only path - ghumare64 iii-sandbox deep dive|libkrun]] sandboxes. Open source is explicitly not planned, though air-gapped deployments are.

## External Resources

- [Storing data yourself is very hard to do safely](https://x.com/jhleath/status/2089754088787644475) — Leath's own earlier post, cited in-article as the reason not to "implement raft and call it a day"
- [Building the last WAL on S3](https://x.com/jhleath/status/2090847398625235198) — the original X Article (21 Aug 2026, 229 likes, 20 retweets, 12 replies)

## Original Content

> [!quote]- Full X Article by @jhleath (Hunter Leath), founder of Archil -- "Building the last WAL on S3", 21 Aug 2026 -- 229 likes, 20 retweets, 12 replies
>
> @jhleath (Hunter Leath):
> Article: Building the last WAL on S3
>
> Nearly two years ago, we started Archil with a simple realization: it was clear that people were spending immense effort to build new, serverless versions of file system software on top of S3. Neon did it with Postgres, Turbopuffer did it with FAISS, and now Cursor Origin is doing it with Git. Why did it take so much effort to build each of these things?
>
> In 2024, in our seed pitch, I repeatedly told investors that @nikitabase needed to fork and rebuild Postgres in order to build Neon, but our goal was that @archildata would make it possible to build Neon with out-of-the-box Postgres -- in an hour.
>
> This is an immense challenge, but it's something that I'm truly delighted to get to work on every day. I wanted to spend some time to talk about how we are achieving this.
>
> What's the shape of cloud workloads
>
> The first thing to realize in accomplishing this vision is that actually all infrastructure workloads are exactly the same. Everything from Neon, to Planetscale, to Clickhouse, to Vercel+webserving, to CI/CD, to sandboxes themselves are all built from the same basic stuff. [I told my friends at Clay that "Clay" would have been a better name for our company if it wasn't already taken.]
>
> There are, of course, many parameters that differentiate the different services which leads to tradeoffs around cost, latencies, and throughput characteristics. If we accomplish our goal, though, then builders can simply specify these parameters and pop out the system that they want.
>
> Every cloud workload is made up of three parts:
>
> *The basic shape of a cloud workload: compute talks POSIX to SSD storage (high-cost, low-latency), which talks S3 REST to object storage (low-cost, high-latency)*
> ![[jhleath-235198-001.png]]
>
> There's the compute for the workload, which is where you might run the Postgres server, the Nextjs server, etc.
>
> There's the high-performance storage for the workload, which is usually SSD-backed (direct-attached or shared) which provides good performance at a very high-cost.
>
> Finally, there's low-performance object storage for the workload, which provides good cost characteristics for systems which have many tenants (and most tenants are inactive).
>
> Each of these pieces can, of course, be scaled:
>
> - OLTP databases like Postgres usually have a single piece of compute pointing at the storage layer, and time-lagged read-replicas.
>
> - OLAP workloads like Clickhouse can have massive amounts of compute pointing at the same storage backend so that they can do map-reduce queries over the data and large amounts of ingestion.
>
> - Sandbox workloads have a single piece of compute attached to an SSD layer, usually with transparent materialization of the data so that you can startup the server quickly.
>
> - Git-like workloads, like Cursor Origin, use a combination of these technologies for different pieces of the stack: S3 for the write-ahead log and SSD for the git storage.
>
> Understanding parameters
>
> Notably also, one of the parameters for the model is whether the service tiers to S3, and how much of that data needs to be resident on the high-performance storage before the compute service can start work.
>
> *Tiering versus residency, plotted: PlanetScale stays on SSD and requires the data to be there to be useful; Neon and sandboxes tier to S3 and can materialize lazily; Docker images tier to S3 but still require full residency*
> ![[jhleath-235198-002.png]]
>
> For example, a database like PlanetScale does not do tiering to S3, and requires that 100% of the data be resident on the local SSD before it can start serving (this is the replica catch-up time that happens when a server fails or you grow your cluster). Databases like Neon do tier to S3, and don't require the data to be resident to move forward. Traditional compute services need the entire Docker image to be resident on the SSD to start, causing poor cold starts. Many sandbox companies are able to lazily materialize the data onto the compute so that the service can start while the data is still coming in.
>
> These are all just different shapes of the same workload, with different pieces of software. If you built a storage solution which allows customers to tell you -- "I want X% of the data to tier down to slow object storage" or "I don't want to serve any traffic until the data is fully local", then you solve for all of these use cases.
>
> If you look on the write side, there's also a parameter that tradeoff durability against the speed at which those writes happen.
>
> *The durability ladder, priced per write: 1-3us in-memory (E2B sandboxes), 10-100us local disk (Vercel Drive, Sprite Block Device, exe.dev), 200-700us zonal replicated SSD (PlanetScale, Celld), 1.3-2.0ms regional replicated SSD (Neon), 50-100ms no-ack-until-S3 (Cursor Origin, Turbopuffer)*
> ![[jhleath-235198-003.png]]
>
> For example, most sandboxes (only confirmed in E2B code), don't actually do anything when you perform a write because they assume that the data you're writing is ephemeral (don't run a database there! lol). The next step up is local disk durability, which [from what they're saying] appears to be what things like Vercel Drive do. The next rung up is actualy replicated storage (where you can actually validate that your data is safe) which is either zonal (I believe with celld's new mode it doesn't care about cross-zone) or regional. Finally, the highest level of durability (and the slowest writes) are if you actually wait for S3 itself to acknowledge the write.
>
> I believe that the only reason that people opt for the "wait for S3" durability mode is that they do not want the hassle of running a stateful SSD storage layer, it doesn't seem to be that there's any real benefit to doing this. That said, you shouldn't just "implement raft" and call it day on data safety because [storing data yourself is very hard to do safely](https://x.com/jhleath/status/2089754088787644475). Use a provider like Archil.
>
> Thinking about the interface
>
> The first choice you need to make when you're building a write-ahead log is what it is that you're write-ahead logging. The log allows you to virtualize a view of data by combining some background view (what other people call "compacted" or "read-optimized" view) with a set of commands on top of that view. To make this generic, the "view" that we want to virtualize is the bucket or the file system itself. This means that the underlying data should actually be stored like a regular file system, like on disk. It should have inodes, directory entries, and more. This is the most generic way to ensure that we can support all workloads, because we know that all workloads will fit this shape.
>
> *What the log virtualizes: combine the on-disk file system tree (right) with a write-ahead log of recent changes -- delete file, write data, create file (left) -- to get the current view of the system*
> ![[jhleath-235198-004.png]]
>
> The second choice you need to make is what set of commands your write-ahead log actually accepts. Many people choose to do a very simple set of commands here: streams only have Append, Cursor Origin only supports "pushes". What we've done (which really irks people) is chose to support the POSIX file system API for our service out of the box. The reason for this is simple: the vast majority of software ever written (and that ever will be written) is written for the file system (including SQLite, Postgres, vector storage, even RocksDB).
>
> Choosing to not support POSIX is a choice that ends up locking you out of this set of software forever, because POSIX is [nearly always] net-negative ROI -- and requires that people purpose-build their software against your stack. We think this is too large of an adoption blocker for a storage system, and we want to meet customers where they are.
>
> *Every interface funnels into one log: POSIX API, S3 API, Streams API and specialized performance APIs all append to the same write-ahead log, which materializes file system data*
> ![[jhleath-235198-005.png]]
>
> The nice part about supporting POSIX is that it's actually a superset of S3 functionality (for example "PutObject" is just file writes and an atomic rename [+ some directory nonsense]). This makes it relatively simple to build additional APIs on top as developers need them. We've already built an S3-compatible API, and we expect to deliver even more APIs for people who are purpose-building high-performance applications (such as AppendObject and other prefetch primitives, more on this later).
>
> What about scale
>
> Write Scaleability: The thing about write ahead logs is that they necessarily imply a total ordering of everything that happens on the system. Ordering is usually the enemy of scaleability because it implies that there's a single mutex somewhere that is responsible for appending things into the order.
>
> There are several things that you can do to improve the scaleability of a log-based storage system, for example:
>
> - You can split up the work where raw data is uploaded (to parts objects in S3) from when it's appended to the log (a single CAS operation), which reduces the "critical section" that the log is locked for
>
> - You can group commits such that you actually commit more than one operation at a time during the "critical section"
>
> - You can split the log up into multiple logs working in parallel which do not provide a total ordering amongst themselves (though, of course, some operations may need to coordinate across these sub-logs).
>
> It's clear that a generic storage system that solves for all cloud workloads needs to solve for all of these properties, by doing all of this simultaneously.
>
> *The three write-scalability moves composed: a journal split fans into parallel Log 1 and Log 2, each of which group-commits batches rather than serializing single operations*
> ![[jhleath-235198-006.png]]
>
> Read Scaleability: Scaling your reads up is actually a much simpler proposition on a storage system, because you just need to store more copies of the data in more caches so that the data can be served from multiple locations. This reduces your problem of "how can I serve more reads" into "how can I invalidate the caches that I have scattered about the system", which is strictly more tractable.
>
> Putting it all together
>
> There are two important things that I want you to take away from this post.
>
> First, I want you to recognize that all storage workloads collapse to a generic set of primitives which can be built into a single system, which can become the default way that storage works in the cloud.
>
> Second is that this system is actually much more than just a "library" that you can add to your application.
>
> There are millions of people who have written write-ahead logs on S3, and libraries that you can use to format that log and manage compaction, etc etc. The real value is building the *entire* system for the user: including a durable space to acknowledge writes before S3 (so that you can do millisecond and microsecond commit latencies), the ability to manage the high-performance caching built in, and the place to run the compute.
>
> This hasn't really been done before, and it's where we think that @archildata will thrive.
>
> The whole solution looks something like this:
>
> *The whole solution: Archil clients on application machines (each with local disk) fan reads and writes out across multiple Archil servers with their own NVMe disks, which in turn tier down to S3*
> ![[jhleath-235198-007.png]]
>
> We give our customers a custom-client which exposes the ability to run FUSE operations (soon to be kernel-mode), but also supports APIs like the S3 API, log-based APIs, and higher-performance specialized APIs like pre-fetch.
>
> The user is able to tell us how they want to form a write quorum. In some cases, they don't care at all, and we acknowledge without doing any writes. By default, we do multi-AZ replication across our servers, but in other cases we have the ability to do PlanetScale-style "local disk + cross-AZ disk".
>
> You tell the client how you want to support reads. You can synchronously pull your data to the local disk with high concurency, enabling you to only serve reads from the local disk. Or, by default, materialize the data that's in the server locally -- useful if you want to avoid cold-start times.
>
> The client has the ability to fan-out both reads and writes to the Archil servers, enabling nearly unlimited throughput for things like model training or data analytics.
>
> Finally, the user can tell us whether or not they want their data to exclusively live in the NVMe devices on our servers. Or, by default, if they want that data to tier down into S3.
>
> This architecture is able to scale and handle all cloud workloads built today, and it shows. We are helping customers who are doing: CI/CD, building agent platforms, run model training, OLTP databases, and do data analytics. All from a single storage system that allows them to specify the right properties for the right job!
>
> Archil is the last WAL that you need to build on top of S3.
> date: Fri Aug 21 17:04:00 +0000 2026
> url: https://x.com/jhleath/status/2090847398625235198
> likes: 229  retweets: 20  replies: 12

## Reply Thread

> [!quote]- Substantive replies from the thread, verbatim
>
> **@nkSaraf98 (Nikhil Saraf)** — 21 Aug 2026 — [link](https://x.com/nkSaraf98/status/2090863211411321062)
>
> @jhleath Any plan to open source some components so we can self host something like this and host in air gapped environments and secure environments
>
> **@jhleath (Hunter Leath)** — 21 Aug 2026 — [link](https://x.com/jhleath/status/2090870707957977141)
>
> we are super happy to work with customers on running Archil in air-gapped environments!
>
> i don't totally know what the future holds for us and open-source, but i think that the value we provide is being hands-on and helping customers run this thing, as opposed to open-source, which requires that they need to learn how to run it without interacting with us!
>
> **@tiptenbrink (Tip ten Brink)** — 21 Aug 2026 — [link](https://x.com/tiptenbrink/status/2090892153920635059)
>
> @jhleath "…forever, because POSIX is [nearly always] net-negative ROI -- and requires that people purpose-build their software against your stack." Do you mean not supporting POSIX requires people to purpose-build or am I reading this wrong?
>
> **@tiptenbrink (Tip ten Brink)** — 21 Aug 2026 — [link](https://x.com/tiptenbrink/status/2090894617361187073)
>
> Every article makes me more excited but also sad I can't use it at work (yet, we need to support on-prem for a while still and also need regions you currently don't offer). Like, the future plans (high-performance prefetch APIs) and recent stuff (appends) all look so good. Keep these posts coming!
>
> **@Dan_The_Goodman (Dan Goodman)** — 21 Aug 2026 — [link](https://x.com/Dan_The_Goodman/status/2090932764963131712)
>
> @jhleath @Standard_Cap You could actually horizontally scale consistent reads too using a CRAQ- like model where mounted replicas query back to the writable mount to see if they need to wait for a refresh or smth
>
> **@VishalPanwarr (Vishal Panwar)** — 22 Aug 2026 — [link](https://x.com/VishalPanwarr/status/2091176147887526243)
>
> @jhleath The hardest part with S3 as a WAL target is p99 PUT latency. You can't do synchronous flushes without tanking throughput, so you end up needing a local bounded buffer to batch segments before pushing.
>
> **@jhleath (Hunter Leath)** — 22 Aug 2026 — [link](https://x.com/jhleath/status/2091177745447629209)
>
> @VishalPanwarr that's why we write to NVME and only flush to s3
>
> **@VishalPanwarr (Vishal Panwar)** — 23 Aug 2026 — [link](https://x.com/VishalPanwarr/status/2091448594545131693)
>
> @jhleath NVMe is fast but the failure modes are brutal. We had a cluster go down hard last year. Now we sync to S3 before any writes. Better safe than sorry.
>
> **@FelipeFumero663 (Felipe Fumero)** — 24 Aug 2026 — [link](https://x.com/FelipeFumero663/status/2092031752277463241)
>
> @jhleath Rebuilding WAL semantics on top of S3's consistency model is genuinely hard to get right. What was the trickiest part, durability guarantees or read latency?
>
> **@simplydt (David T Kramaley)** — 22 Aug 2026 — [link](https://x.com/simplydt/status/2091160887100891296)
>
> @jhleath unifying compute, SSD, and S3 under a POSIX API hits the sweet spot for most services. reduces custom layers, speeds up rollout

Source: [Building the last WAL on S3](https://x.com/jhleath/status/2090847398625235198) by [@jhleath](https://x.com/jhleath) (Hunter Leath), Archil.
