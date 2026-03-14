---
created: 2026-03-14
description: Real-time data sync between database and UI remains unsolved because reactivity requires tight coupling between database internals and UI subscriptions, but the ecosystem values composability and decoupling.
source: https://x.com/odysseus0z/status/2032570785341296993
type: learning
---

# Real-time data sync is unsolved because reactivity requires coupling database and UI

## Key Takeaways

The core structural tension is that reactive data sync demands tight coupling between the database query engine and UI subscription system, but the entire web ecosystem is built around decoupling these layers. Every other major web abstraction won by separating concerns — frontends from backends, app code from databases. This problem uniquely requires coupling them back together, which is why it resists standardization.

Google's thirteen-year arc from Firebase Realtime Database (2012) to Firestore (2017) to Data Connect (2025) illustrates this perfectly. Each step added what developers wanted — real data models, then standard Postgres — but each step also lost reactivity because the new layer broke the tight integration that made subscriptions work. Even a company with unlimited engineering resources couldn't deliver relational queries, reactive subscriptions, and standard Postgres in one product. This resonates with the insight that [[every app that avoids a database ends up rebuilding one badly]] — the complexity of databases is irreducible, and so is the complexity of wiring reactivity into them.

The "read path" problem is deeper than most developers realize. It's not just detecting that a row changed — Postgres triggers and WAL can do that. The hard part is reverse query matching: figuring out which of thousands of active client queries would be affected by a given change, which requires understanding filters, joins, and aggregations. Firestore solves this only because it controls storage, indexing, query execution, and subscriptions as a single system.

Products like Linear and Figma have already shifted user expectations. Once you use an app where data feels alive, loading spinners and edit locks feel broken. As AI agents increasingly write data in the background, the set of apps needing real-time sync will expand dramatically. The write path (conflict resolution via CRDTs, operational transform, or transactions) remains equally unsettled, with no consensus winner.

The insight that [[agents need a database because stateless reasoning cores require stateful storage]] becomes even more relevant here — as agents become concurrent writers to shared data, the write-path conflict resolution problem compounds.

## External Resources

- [Linear](https://linear.app/) — project management tool known for instant-feeling UI
- [Figma](https://figma.com/) — collaborative design tool using CRDTs for real-time sync
- [TanStack Query](https://tanstack.com/query) — smart caching library for data fetching (not reactive subscriptions)
- [Firebase Realtime Database](https://firebase.google.com/docs/database) — Google's original reactive JSON store (2012)
- [Firestore](https://firebase.google.com/docs/firestore) — Google's reactive document database with reverse query matching
- [Firebase Data Connect](https://firebase.google.com/products/data-connect) — Google's Postgres-backed Firebase offering (2025, no reactivity)
- [Kubernetes](https://kubernetes.io/) — container orchestration (cited as example of thin-interface standardization)

## Original Content

> **@odysseus0z (George)** — Fri Mar 13, 2026
> 6 likes · 0 retweets · 0 replies
> [Original tweet](https://x.com/odysseus0z/status/2032570785341296993)

*Article header image*
![[odysseus0z-296993-001.jpg]]

> **Article: Why Real-Time Data Sync Is Still Unsolved**
>
> A row changes in your database. Another user updates a shared record. A background job finishes processing. Somewhere, a user is staring at numbers that are already wrong. Somewhere else, two users just edited the same record — and one change is about to silently disappear.
>
> In 2026, making data stay in sync across every user and every screen — without stale reads, lost writes, or hand-wired cache invalidation — still means adopting an entirely different backend or stitching together libraries that weren't designed for each other.
>
> This is strange. Many of the hardest problems in web development have found settled answers. The component model won for UI rendering. Relational databases won for storage. These aren't specific product victories. They're patterns that entire communities converged on. But the integration between database and UI has no equivalent default. Not because nobody's built solutions (several work well) but because none have converged into a settled pattern that everyone reaches for.
>
> Most apps don't need this. Smart caching (fetch data, store it locally, refetch when something might have changed) handles the majority of cases well enough. But the apps that solve this, [Linear](https://linear.app/) and [Figma](https://figma.com/), are resetting what users expect software to feel like. After using Linear, every loading spinner in every other app starts to feel like a bug. After using Figma, every "someone else is editing this" lock feels like a relic. The gap between "apps that feel alive" and "apps that feel like web pages" is becoming visible. And as AI agents increasingly write data in the background, the set of apps that need this is about to get much larger.
>
> The problem has two halves — a read path and a write path — and neither has a consensus default. This piece starts with the read path.
>
> ## Why the read path is technically hard
>
> After data changes on the server, every affected UI should update automatically. That's the read path. [TanStack Query](https://tanstack.com/query) handles the simple case: your app decides when to check for new data. True reactive subscriptions are different. The server tells your app the instant something changes. No polling interval. No manual invalidation. The data arrives because the server knows you're watching. You're not checking for changes, you're receiving them.
>
> Databases don't track who's watching what. When you query Postgres, it runs your query, returns results, and forgets about you. There's no registry of "Client A is currently looking at the results of this query." When a row changes five minutes later, Postgres has no idea that anyone cares. No read-set tracking, no dependency graph, nothing.
>
> Even detecting changes isn't enough. You can set up triggers or watch the write-ahead log to detect that a row changed. A new post was inserted. Great. But which of a thousand active clients care about that specific post? Only the ones whose queries would include it — the ones whose filters match, whose joins connect, whose aggregation windows contain it. Figuring that out means understanding what each query is looking for, not just what changed. The hard part isn't detecting the change. It's figuring out which queries are affected, which clients have those queries active, and which components need to re-render — then pushing the update through that entire chain.
>
> Solvable — if you co-design the whole stack. Google's [Firestore](https://firebase.google.com/docs/firestore) does exactly this. When data changes, Firestore's [reverse query matcher](https://firebase.google.com/docs/firestore/real-time_queries_at_scale) finds which registered queries are affected. It works — at scale, for millions of developers. But only because Firestore controls storage, indexing, query execution, and subscriptions as a single system. The query matcher can find affected subscriptions because Firestore built the indexes those subscriptions depend on.
>
> But it can't be generalized. When Google shipped [Firebase Data Connect](https://firebase.google.com/products/data-connect) in 2025 — finally offering standard Postgres as Firebase's relational database option — the reactivity didn't come with it. Data Connect's [React SDK](https://firebase.google.com/docs/data-connect/web-sdk) is built on TanStack Query. Smart caching, not reactive subscriptions. You can't bolt reactive invalidation onto an existing database without rebuilding the parts that make it a database.
>
> ## So why hasn't any solution become the default?
>
> The solution requires tight coupling between database and UI. The ecosystem values the opposite. That's the structural trap.
>
> [Kubernetes](https://kubernetes.io/) crossed ecosystem boundaries because it has a thin interface — it doesn't care what's inside a container. A reactive data layer has to understand the query engine, all the way from database internals to the components that display the results. There's no thin interface to standardize against.
>
> But developers want composability — pick your database, pick your framework, wire them together. Database engineers don't build UI subscription systems. Frontend developers don't build query engines. Nobody owns the full stack, and nobody wants to be locked into someone who does.
>
> Google tried to thread this needle for thirteen years.
>
> [Firebase Realtime Database](https://firebase.google.com/docs/database), circa 2012, gave developers reactive subscriptions with a dead-simple API:
>
> ```javascript
> onValue(ref(db, 'posts'), (snapshot) => {
>   // fires every time any post changes
> })
> ```
>
> Subscribe to a path, get live updates. Reactivity was straightforward — the JSON tree was simple enough to build subscriptions directly into. No relations, no joins, no aggregations. As apps grew complex, developers needed a real data model.
>
> Firestore, launched in 2017, delivered one. Collections, documents, subcollections — and it kept reactive subscriptions, making them work at scale. Google could pull this off because they still controlled the entire stack. Firestore still wasn't truly relational, though — no joins across collections, limited aggregation — and its read-based pricing made costs hard to predict. Developers wanted standard Postgres.
>
> Data Connect (2025) finally gave them Postgres — but without control over the query engine, there was nothing to wire the subscription system into. The reactivity didn't survive the transition.
>
> Reactivity can't be added after the fact — it has to be designed in. The company with essentially unlimited engineering resources and thirteen years of iteration still can't deliver all three in a single product.
>
> ---
>
> The problem is structural — and that's just the read path. The write path is just as unsettled: when multiple users or agents change the same data, how do you propagate those changes without conflicts silently winning? Google Docs solved collaborative text editing with operational transform. Figma solved collaborative design with CRDTs. But there's no general-purpose equivalent — and CRDTs, operational transform, and transactions all make different tradeoffs with no consensus winner.
>
> Every other abstraction in web development won by decoupling layers — frontends from backends, application code from databases. This problem can only be solved by coupling them back together. That's what makes it structurally unusual, and why the path forward isn't a standard that bridges existing tools — it's a series of bets, from very different directions. Build the database and subscription layer as one system. Bridge a purpose-built store with the Postgres developers already use. Move the source of truth to the client entirely. That's what I want to look at next.

*Article footer/preview image*
![[odysseus0z-296993-002.jpg]]
