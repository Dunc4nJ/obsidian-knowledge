---
created: 2026-03-12
description: swyx's satirical open letter showing how every attempt to avoid using a proper database inevitably reinvents schemas, transactions, WAL, caching, query planning, and authorization — the exact components of a database.
source: https://dx.tips/oops-database
type: learning
---

## Key Takeaways

The article traces the predictable arc of "simple persistence" growing into a full database reimplementation. You start with JSON files or a KV store, save 30% time on the MVP, then lose 30% per team member per month as consistency bugs, schema drift, and performance issues compound. This is the exact dynamic Kevin Gu references in [[a file system is not all you need - databases beat markdown for agent context provenance and governance]] — the filesystem looks clean at small scale but collapses under real query and maintenance demands.

The progression is instructive: first you need a schema (entities, attributes, value ranges), then a transaction manager (pending states, rollbacks on partial failure), then a write-ahead log (crash recovery), then change data capture (hooks triggered on writes), then a query language (DRY CRUD operations with consistent grammar), then caching and indexing (memoization, precomputation, Dataloader-style batching), then normalization (third normal form for write performance), and finally security/authorization and audit logging for enterprise customers. Each step feels like "just a little more code" but collectively you've rebuilt Postgres in application code — badly.

The essay connects to the broader pattern in [[file-based personal OS gives AI agents persistent identity and judgment across sessions]] and [[PARA and atomic facts give AI agents durable structured memory]]. These file-based agent memory systems work precisely because they stay within the narrow band where files are sufficient — personal agent context, not multi-user collaborative knowledge graphs. The moment you need concurrent writes, consistency guarantees, or cross-entity queries, you've crossed the threshold where you should have used a database from the start.

The "30% faster for 1 month, 30% slower per person per month" framing is a useful heuristic for evaluating when to reach for a proper database vs lightweight persistence. If your data model is stable, single-writer, and query patterns are simple, files work. If any of those constraints will break within 6 months, start with the database.

## External Resources

- [Dear sir, you have built a compiler](https://rachitnigam.com/post/you-have-built-a-compiler/) — the original "oops" pattern essay that inspired this piece
- [Stop Building Databases](https://sqlsync.dev/posts/stop-building-databases/) — related argument against ad-hoc database reimplementations
- [Reddit has two tables](https://news.ycombinator.com/item?id=32407873) — HN discussion on Reddit's famously simple data model
- [Designing Data Intensive Applications](https://www.amazon.com/Designing-Data-Intensive-Applications-Reliable-Maintainable/dp/1449373321) — Martin Kleppmann's canonical reference on data systems
- [Dataloader](https://leebyron.com/dataloader-v2/) — Lee Byron's batching/caching utility for nested data dependencies
- [BASE: An ACID Alternative](https://dl.acm.org/doi/10.1145/1394127.1394128) — Dan Pritchett's paper on eventual consistency tradeoffs
- [HN discussion](https://news.ycombinator.com/item?id=34941650) — Hacker News thread on this article

## Original Content

> [!quote]- Source Material
> Dear Sir,
>
> I am afraid to inform you that you have written a database. I know you just wanted some "simple persistence" and that "a basic key-value store will do". Maybe keep it in memory as an object, or read/write simple JSON files on disk or to a cloud KV store. You said that "Postgres is overkill" and "ORMs create impedance mismatches", and yet, six months later, you have a mountain of application code dedicated to caching, updating, and defensively reading your data — breaking every time you change your data model. You moved 30% faster for your 1 month MVP but it is now slowing you down 30% per team member per month.
>
> Surely, you've read Reddit has two tables and Dan Pritchett's BASE: An ACID Alternative and you don't mind writing some extra migration and defensive code in userland to be web scale. But after working on the app for multiple weeks and hiring more people you are having trouble remembering what goes where, so you start writing down a list of all the important entities and their attributes and the range of their values. Perhaps you manually maintain them, or you pull in something like a tRPC or an Apollo GraphQL to get some extra dev tooling and codegen.
>
> The other problem you soon encountered is that there would be weird Heisenbugs cropping up in your KV stores where a user update would go through and show up in one feed but not be updated in another, especially when multiple users and apps access the same sets of data. Your new team members suggest adding a Pending state to all the fast updates, and then waiting for success on the slow/error-prone updates to then do a second update to Complete. We're moving fast, and we're ensuring consistency in userland while keeping things simple. Maybe you just needed this in like 5 places throughout the app, so you extracted some utility code to wait for confirmation of updates for success, or roll them back on partial failure. Maybe you even had someone split out the Pending updates to a separate "log" since if the app crashes we don't want to lose any user data. Maybe when updates happen, you want other things to happen, so you devise an ingenious "hook" system that triggers more code to run when your not-a-database code ends.
>
> Then you saw that there were bits of data that always get accessed and updated together. They are inconsistently named and it's tiring to always write the same 3 lines of code needed to join them together every time. In the spirit of keeping things DRY, you wrote a class with all these CRUD operations across fields, but also taking care to have intuitive, guessable API naming with a consistent grammar. Maybe it needs to be learnable by others, and maybe you want to expose it to end users (your app's users) for them to make their own queries whether through plain text or autogenerated UI.
>
> Your app launched out of beta, and you got real users! Performance became an issue. There are a myriad of ways to tackle it and your growing team wrote more code to use them all:
>
> - The same queries get asked again and again? Maybe we can just memoize the reads, save the results and return them without rerunning the read, join, and aggregate code.
>
> - We can predict which queries get asked again and again? Maybe we can just pick a few of those queries and precompute all the results. This way, we're faster on initial queries, not just the subsequent ones.
>
> - We can't predict which queries will happen? But we want to make sure we don't request data we don't need? And nested data dependencies mean some queries wait on other queries? Maybe we'll compile a little graph and caching layer to run everything faster. Maybe give it an unassuming name like Dataloader.
>
> - Some writes are slow? When your team's book club read Designing Data Intensive Applications, someone had the bright idea of splitting out some high fan-out writes and pushing some of the load into the third normal form.
>
> In the last leg of your journey to avoid using a database, your new high paying Enterprise customers demand assurance that you have taken the necessary security measures:
>
> - How do you ensure users can't edit documents they don't own?
>
> - How do you ensure that a devious hacker who is snooping around your undocumented but publicly exposed APIs can't read what they shouldn't?
>
> - How do you ensure that people who shouldn't have access to your customer's data, don't?
>
> - How do you reassure them that YOU don't have access to their data? How do you keep their data where they need/want it kept? How do you delete their data when they want but also recover it if they made an oopsie (or worse, you made an oopsie)?
>
> - When something bad happens, how do you go back in time to figure out what's wrong? How do you know who did what and when?
>
> Your engineers sigh, but those enterprise contracts are juicy. You write more and more and more code and have them audited by a fancy security firm to get the thumbs up.
>
> A schema, transaction manager, write ahead log, change data capture/stored procedures, query language, caching, indexing, query planning, security/authorization, recovery, and an audit log.
>
> Dear Sir, you have written a database.
>
> written as a database complement to "Dear sir, you have built a compiler".
>
> Further discussions on [Hacker News](https://news.ycombinator.com/item?id=34941650) and [Twitter](https://twitter.com/DXTipsHQ/status/1629629860175032320).
>
> See also [Stop Building Databases](https://sqlsync.dev/posts/stop-building-databases/).
>
> P.S. more things Are Database than you might think!
>
> [Original article](https://dx.tips/oops-database)
