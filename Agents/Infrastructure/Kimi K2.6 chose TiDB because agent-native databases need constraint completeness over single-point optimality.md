---
created: 2026-05-13
description: A TiDB founder argues that Kimi K2.6's website-generation agent picked TiDB Cloud not for any single best-of-breed benchmark but because every agent-database constraint must hold simultaneously — multi-tenancy in the bones, real scale-to-zero, unified SQL+vector+JSON+HTAP, per-RU billing, and Agent-session observability.
source: https://x.com/siddontang/status/2054381563065028926
type: synthesis
---

# Kimi K2.6 chose TiDB because agent-native databases need constraint completeness over single-point optimality

When the user of a database stops being a human developer and starts being an LLM agent that can mint hundreds of thousands of independent tenants in a week, every decades-old database assumption — stable schema, precomputed plans, warmed-up caches, predictable tenant growth — collapses at once. Siddontang (Co-founder, PingCAP / TiDB) uses TiDB Cloud's selection by Kimi K2.6's website-deployment agent to argue that the right framing is no longer "which database is fastest at X" but "which database makes none of the constraints fail at once."

## Key Takeaways

- **Agent workloads invert every database growth assumption.** Tenant count goes from sales-driven hundreds-per-year to viral-driven hundreds-of-thousands-per-week, the control plane stops serving humans and starts serving Agent API calls, and 99% of tenants sit at zero QPS while 1% spike — making both average-load and peak-load provisioning wrong. This is the same multi-tenancy isolation/persistence/scaling pressure described in [[seven runtime failures emerge when demo agents meet production distributed systems]], pushed simultaneously to the limit.

- **LLM-generated schema invalidates the precomputed-plan / warm-cache contract.** Schema is now mutated mid-conversation when the user asks "one more question," so the database can no longer rely on schema stability, prepared plans, or cache warmup. This dovetails with [[databases are becoming the runtime layer for AI agents as application logic collapses into the data layer]] — when application logic collapses into the data layer, schema must be re-treated as a first-class evolving artifact rather than a static contract.

- **Real scale-to-zero requires compute/storage decoupling, not scheduled shutdown.** "Scale-to-zero" where the instance is asleep but still billable is "a batch job wearing a cloud-native hat." Storage must stay resident on object storage while compute drops to zero on idle, with cold start kept inside a user-acceptable window — the same separation principle [[LangChain Deep Agents runtime builds ten production capabilities on one primitive - durable super-step checkpointing to PostgreSQL]] applies to durable execution state.

- **Unified SQL+vector+JSON+HTAP is a reliability question, not a performance question.** For an Agent, every additional system boundary (Pinecone + Postgres + MongoDB) is another class of cross-system errors it cannot debug. One SQL surface area means one fewer abstraction layer and one fewer class of bugs — reinforcing why [[agents need a database because stateless reasoning cores require stateful storage]] favors fewer, more capable substrates over polyglot stacks.

- **Constraint completeness beats single-point optimality.** Kimi did not pick TiDB because one benchmark was fastest; it picked TiDB because multi-tenancy-in-the-bones + real scale-to-zero + pre-warmed instance pool + unified stack + RU-based per-statement billing + Agent-session observability all line up at once. Wrapping an old system with an Agent-friendly API is "painkiller, not new architecture" — the same first-principles redesign argument behind [[a file system is not all you need - databases beat markdown for agent context provenance and governance]].

- **Observability must aggregate by Agent session, not by SQL or user.** When >90% of DDL/DML originates from Agents, auditing by human, application, or SQL text loses the chain of intent. The new primitive is "which database actions happened during one Agent conversation, which succeeded, which failed, where did cost go" — closer to the agent-architecture-as-computer-system framing in [[multi-agent memory needs computer architecture style hierarchy and consistency models]].

## External Resources

- [TiDB Cloud free trial signup](https://tidbcloud.com/free-trial/?utm_source=sales_bdm&utm_medium=sales&utm_content=Siddon) — the post's closing ad; entry point to the TiDB Cloud Serverless tier described
- [Kimi K2.6](https://www.kimi.com/) — Moonshot AI's frontier model with Agent Mode that triggers the dynamic Agent Database provisioning workflow this article analyzes

## Original Content

> [!quote] @siddontang (Co-founder, PingCAP) — May 13, 2026
>
> Article: Why Kimi K2.6 Chose TiDB: The Story Behind Millions of AI Agent Databases
>
> ## 1. Why I Wanted to Write This
>
> Recently, TiDB Cloud officially became a provider for Kimi K2.6, supporting dynamic, large-scale Agent Database provisioning for Kimi Agent's website deployment service.
>
> As someone who has spent more than ten years building databases, I want to talk about what this kind of scenario really demands from a database — especially the parts that look counterintuitive at first.
>
> Let me be clear first: this is not meant to be a TiDB advertorial. What I care about more is the engineering tradeoff. If you read this and think there is a better answer, please come and challenge it. This problem is much harder than it looks.
>
> ## 2. What Exactly Did Kimi K2.6 Change?
>
> Start with a simple example.
>
> A user tells Kimi K2.6 Agent Mode: "Build me a reading-notes website."
>
> A few minutes later, a web application is live: login, database, search, and external access included.
>
> What the user sees is: "cool."
>
> But as a database engineer, my first reaction is not "cool." It is: the backend is now doing something database systems have rarely had to handle systematically before.
>
> Several annoying things happen at the same time.
>
> First, the number of tenants explodes.
>
> In the old SaaS world, tenant growth was driven by sales: a few hundred customers a year, with a slow and mostly predictable curve. In an Agent website-building scenario, one viral product can create hundreds of thousands of independent tenants in a week.
>
> The database control plane is no longer handling human operations requests. It is handling API calls from Agents. QPS can jump by several orders of magnitude.
>
> Second, schema becomes uncontrollable.
>
> In the past, schema was designed by humans. Once designed, it rarely changed. Now schema is generated by an LLM inside a conversation. If the user asks one more question, the Agent may alter the table structure again.
>
> Many assumptions databases have relied on for decades — stable schema, precomputed plans, warmed-up caches — are quietly removed.
>
> Third, the workload distribution becomes absurd.
>
> 99% of tenants sit at zero QPS for long periods. 1% of tenants may suddenly jump to extremely high traffic.
>
> You cannot provision by average load, because peaks will kill you. You cannot provision by peak load either, because cost will kill you.
>
> This is the most annoying kind of obvious in system design: both simple answers are wrong.
>
> Finally, and most subtly, the database user changes from a human to an Agent.
>
> When human developers hit an error, they read docs, check logs, and debug. When Agents hit an error, they often retry, route around it, or simply give up. Worse, their errors can be amplified to thousands or even millions of end users.
>
> Individually, none of these problems is entirely new. But a scenario like Kimi K2.6 pushes all of them to the limit at the same time.
>
> ## 3. If I Were Designing This from Scratch
>
> Let's put TiDB aside for a moment.
>
> If I were designing a database for Agents from scratch today, I would start with a few basic questions.
>
> The first question is multi-tenancy.
>
> But this is not multi-tenancy in the old sense of "put every tenant into one large database and isolate them logically." Once this scales to tens or hundreds of thousands of tenants, metadata, connections, permissions, lifecycle management, and isolation all become bottlenecks.
>
> My instinct is that the system should assume from day one that it consists of N lightweight logical instances.
>
> Each instance should have independent scheduling, metering, and lifecycle management at the control-plane layer. At the data-plane layer, resources should be pooled and allocated on demand.
>
> In other words, this is not about patching a single-tenant system into a multi-tenant one. If the direction is wrong on day one, most future work becomes hole-patching.
>
> The second question is scale-to-zero.
>
> And I mean real zero, not fake zero where the instance is "asleep" but you are still paying for it.
>
> There is one critical architectural judgment here: compute and storage must be fully decoupled.
>
> Storage stays resident. Data is always there. Compute starts on demand, and when idle, resources go to zero.
>
> Without this decoupling, "scale-to-zero" is at best a scheduled shutdown. That is not scale-to-zero. That is a batch job wearing a cloud-native hat.
>
> The third question is a unified stack.
>
> This point is often underestimated.
>
> If you ask an Agent to operate Pinecone + Postgres + MongoDB at the same time, it can probably generate the code. But the error rate will clearly be higher than with one database and one SQL interface.
>
> For an LLM, the logic is simple: one fewer abstraction layer means one fewer class of bugs.
>
> So putting vector search, relational queries, JSON, and AP analytics behind the same SQL interface is not only a performance question. It is also a reliability question.
>
> What Agents fear most is not being slightly slower. It is too many system boundaries, with errors happening at the boundaries and becoming hard to debug.
>
> The fourth question is billing.
>
> Queries written by Agents vary wildly. Some are cheap point lookups. Others are analytic scans across an entire table.
>
> If billing is based on "instance × time," it becomes hard to allocate cost to the actual end users generating that cost.
>
> A more reasonable model is per-statement, per-request, or per-RU metering. Every Agent action should map to a cost. Otherwise the business model can easily become: users are happy, platform is bleeding.
>
> Once you follow these requirements through, the outline of an Agent-oriented database becomes fairly clear.
>
> ## 4. How Kimi Chose
>
> With the outline above, Kimi's technical selection becomes a matching problem:
>
> Who in the market can satisfy all these constraints at the same time?
>
> In the end, the answer landed on TiDB Cloud for roughly three reasons.
>
> First, multi-tenancy is built into the bones, not bolted on later.
>
> Each cluster is an independent logical instance. At the control-plane layer, there is lifecycle management, quota, and metering. At the data-plane layer, resources are pooled and scheduled.
>
> Tens of thousands of clusters are not a special project for the system. They are the normal operating mode.
>
> Second, scale-to-zero is real, not just marketing language.
>
> With compute-storage separation and an object-storage-based storage architecture, idle tenants can have compute resources reduced to zero while data remains available and storage cost stays low enough.
>
> Cold start can be kept within a user-acceptable range. This is crucial for Agent scenarios.
>
> Third, the Agent can quickly get a ready-to-use database.
>
> TiDB Cloud maintains a pool of pre-warmed instances. When Kimi needs a new instance, it does not have to go through the full creation path. It can directly allocate a prepared instance from the pool.
>
> Combined with scale-to-zero, idle cost can also be controlled.
>
> This matters because the Agent should not have to write its own retry, polling, and waiting logic. That burden should not be pushed onto the Agent in the first place.
>
> Add TiDB's unified stack — SQL + vector + JSON + HTAP — and RU-based billing, and the earlier constraints mostly line up.
>
> So I do not think Kimi chose TiDB because one benchmark number was the fastest.
>
> It chose TiDB because in this scenario, none of the constraints can fail, and TiDB Cloud has an executable answer for each one.
>
> Single-point optimality matters less here. Constraint completeness matters more.
>
> *TiDB Cloud × Kimi K2.6 — the official partnership announcement card attached to the post*
> ![[siddontang-028926-001.jpg]]
>
> ## 5. A Few Interesting Engineering Details
>
> Detail 1: Metadata pressure from per-tenant clusters
>
> Many people's first reaction is: "Tens of thousands of clusters — can the control-plane metadata handle that?"
>
> This is absolutely the right question.
>
> The answer is also interesting: we have a lot of experience handling large-scale metadata and lifecycle management inside TiDB itself, so scaling the control plane is not a completely new problem for us.
>
> This is a form of dogfooding. Our Serverless control plane is itself running a large-scale, multi-tenant, high-frequency lifecycle-management workload.
>
> Using your own product to support your own product sounds natural. Actually doing it still means stepping on quite a few landmines.
>
> Detail 2: Isolation between vector indexes and TP workloads
>
> In Agent scenarios, vector retrieval and TP transactions often appear inside the same SQL statement.
>
> TiDB's approach is to store vector indexes as special column indexes, colocated with row data on the same replica. During query execution, a dedicated operator pipeline is used to avoid letting ANN search slow down the TP path.
>
> This may not be the most academically pure design, but it is practical.
>
> Engineering often works like this: architectural purity is less important than making sure the Agent can write one SQL statement and have it run correctly.
>
> Detail 3: Observability for Agent-initiated calls
>
> When more than 90% of DDL and DML are initiated by Agents, traditional auditing by human, application, or SQL text is no longer enough.
>
> Kimi and TiDB built an observability view aggregated by Agent session.
>
> In other words, we do not only ask what a person did. We ask what database actions happened during one Agent conversation, which ones succeeded, which ones failed, and where the cost went.
>
> I think this will become a standard capability for Agent-native databases.
>
> Otherwise, when something goes wrong, all you see is a pile of SQL, with no visibility into the chain of intent behind it.
>
> ## 6. Some Problems Are Still Unsolved
>
> To be honest, Agent-native databases still have many unresolved problems.
>
> For example, cross-tenant resource competition.
>
> When one viral tenant suddenly spikes, how do you control its impact on other tenants in the same region?
>
> Hard quotas provide a safety net. But if they are too strict, they hurt elasticity. If they are too loose, they cannot prevent cascading failure.
>
> There are still many engineering details to refine here.
>
> Another issue is how to unify structured and unstructured data.
>
> Right now, we mostly solve structured and semi-structured data: SQL, JSON, and vectors.
>
> But Agents increasingly need to process documents, images, audio, and video. They also need to query across structured records, vectors, and files together.
>
> Unified storage and query semantics for this, in my view, is one of the next problems that must be answered.
>
> The larger point is this:
>
> Many traditional database designs were built around the assumption that "human developers write code."
>
> Now the caller is becoming an Agent.
>
> Error handling, permission models, observability, billing, schema evolution — all of them need to be re-examined.
>
> This is not a question TiDB alone needs to answer. Databases, Agent frameworks, and cloud platforms will all be pushed forward by this change.
>
> ## 7. Final Thoughts
>
> I have been building databases for more than ten years.
>
> Over those years, the basic design logic of databases has not changed that many times: OLTP, OLAP, HTAP, Cloud Native. Each wave extended the previous one.
>
> But Agent-native feels different.
>
> It is not simply asking: how do we make databases faster and cheaper? We have been answering those questions for years.
>
> The real question is:
>
> When the primary users of databases are no longer humans, but Agents, do the old design assumptions still hold?
>
> I do not have a complete answer yet.
>
> But the Kimi case makes me more certain of one thing: the answer will not come from wrapping an old system with an Agent-friendly API.
>
> That is painkiller, not new architecture.
>
> We need to rethink from first principles.
>
> If you are working on a similar database selection problem, or if you think I missed something important above, I would be happy to discuss.
>
> And finally, as usual, a small ad: you can sign up for TiDB Cloud for free at [tidbcloud.com](https://tidbcloud.com/free-trial/?utm_source=sales_bdm&utm_medium=sales&utm_content=Siddon).
>
> — Posted Wed May 13, 2026 02:01 UTC · 19 likes · 2 retweets · [original](https://x.com/siddontang/status/2054381563065028926)
