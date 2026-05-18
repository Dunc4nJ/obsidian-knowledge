---
created: 2026-05-18
description: Ankush Gola pairs LangChain's SmithDB announcement (12x faster agent observability, purpose-built distributed database) with explicit public credit to Apache DataFusion (Rust query engine) and Vortex (extensible file format) — framing the headline result as built on top of, not instead of, the modern OSS columnar data stack.
source: https://x.com/ankush_gola11/status/2054681251513254260
type: learning
---

## Key Takeaways

- **The headline "12x faster agent observability" was achieved by building custom execution plans and storage layouts on top of two OSS primitives, not by writing a database from scratch.** Ankush Gola — SmithDB's co-author at LangChain — explicitly credits Apache DataFusion (extensible Rust query engine) for the query plumbing and Vortex (extensible file format) for the columnar layout. The novelty is what they built *on* the OSS stack: custom DataFusion execution plans tuned for agent-trace access patterns, and Vortex layouts that pick per-column encoding/chunking strategies. The same "engineering tax is the layout, not the engine" pattern that shows up across [[SmithDB makes LangSmith 12x faster by treating agent observability as an LSM problem on object storage|the SmithDB engineering deep-dive]] — generic columnar warehouses can't do this *without giving up the layout*, which is exactly what Vortex's extensibility unlocks.
- **The data shape that broke traditional infra is named directly in the announcement: "tens of thousands of intermediate spans and large, unbounded payloads."** Ankush attributes both characteristics to two structural forces — agents running for longer time horizons, and LLM context window sizes growing — which converts agent observability into a workload qualitatively different from request/response APM. This is the same diagnosis [[Brainstore turns AI observability into database-native trace architecture for long-horizon agents|Braintrust reached when they built Brainstore]] and the workload pressure behind [[agent trace data should live in your data lake not a 30-day SaaS retention window|moving trace data to customer-controlled storage]] — when intermediate spans count in the tens of thousands and payloads are unbounded, you can't bolt a database on later.
- **The OSS-credit framing is the operational lesson for "modern data systems" teams: pick extensible primitives, not opinionated systems, when your workload is non-standard.** The reason DataFusion + Vortex were the right pick is that *both* are extensibility-first — DataFusion lets you write custom execution plans for your specific access patterns, and Vortex lets you pick layouts (encoding, chunking) per column. A purpose-built database for an underserved workload (agent observability) is feasible *because* the OSS stack has reached the point where the hard parts — query planning, columnar IO — are reusable libraries. Ankush's closing recommendation ("highly recommend checking out both of these projects if you're interested in modern data systems") names the pattern.

The thread sits inside a three-tweet quote chain that escalates from announcement to engineering claim to OSS credit. LangChain's official account announces SmithDB with a 67-second product video; Ankush quote-tweets it with the engineering story (12x, agent trace data shape, hiring); he then quote-tweets *himself* to attach the open-source-foundation credit. The OSS credit being its own tweet — not a footnote in the blog post or the parent thread — is the deliberate signal: this is what Ankush wants developer Twitter to remember.

## External Resources

- [Apache DataFusion](https://datafusion.apache.org/) — the extensible Rust-based query engine SmithDB built custom execution plans on.
- [Vortex](https://vortex.dev/) — the extensible file format used for SmithDB's columnar storage layer, supporting custom per-column encoding and chunking strategies.
- [Introducing SmithDB (LangChain blog)](https://www.langchain.com/blog/introducing-smithdb) — Ankush Gola's longer-form announcement of SmithDB; full engineering deep-dive captured at [[SmithDB makes LangSmith 12x faster by treating agent observability as an LSM problem on object storage]].
- [LangSmith](https://smith.langchain.com/) — the observability product now backed by SmithDB.
- [LangChain Careers](https://www.langchain.com/careers) — Ankush's open call for systems engineers to work on agent observability infrastructure.
- [Interrupt conference](https://interrupt.langchain.com/) — where SmithDB was first announced.

## Original Content

> [!quote]- Conversation chain — root announcement → engineering story → OSS credit
>
> ### Root tweet — @LangChain (2026-05-13 20:22 UTC)
>
> Just announced at Interrupt! SmithDB.
>
> Agent traces have outgrown the databases built to hold them.
>
> That's why we built SmithDB, a purpose-built distributed database for agent observability.
>
> Read the announcement from Co-Founder @ankush_gola11 → https://www.langchain.com/blog/introducing-smithdb
>
> *SmithDB announcement video — 67s product clip (1920×1080)*
> ![[langchain-244936-001.jpg]]
> ![[langchain-244936-001.mp4]]
>
> Engagement: 151 likes | 38 retweets | 15 replies
> [Original post](https://x.com/LangChain/status/2054658661776244936)
>
> ---
>
> ### Parent tweet — @ankush_gola11 (Ankush Gola, 2026-05-13 20:35 UTC)
>
> We built SmithDB: the database purpose built for agent observability workloads that now powers many parts of LangSmith.
>
> Agent observability presents a challenging data problem. Agent traces can contain tens of thousands of intermediate spans and large, unbounded payloads. These characteristics are a direct result of agents running for longer time horizons and LLM context window sizes growing.
>
> Traditional data infrastructure was not built to handle the complexities associated with storing and querying this data.
>
> SmithDB brings LangSmith up to 12x performance improvements across access patterns most important for agent observability. I've been working on SmithDB directly with an amazing team over the past few months, and I'm incredibly proud of the results we're seeing.
>
> I wrote a bit more about the story and engineering challenges behind SmithDB in this blog.
>
> Additionally, if you're a systems engineer interested in building the future of agent observability, please reach out!
>
> *(quote-tweets @LangChain's root announcement above)*
>
> Engagement: 99 likes | 18 retweets | 7 replies
> [Original post](https://x.com/ankush_gola11/status/2054661816249360553)
>
> ---
>
> ### Reply — @ankush_gola11 (Ankush Gola, 2026-05-13 21:52 UTC)
>
> We leveraged two amazing open source projects when building SmithDB.
>
> One is @ApacheDataFusio: an extensible Rust based query engine. We built custom execution plans specifically tuned for our workloads and storage backend, and DataFusion made it straightforward to plumb everything together.
>
> The other is @vortexdotdev: an extensible file format that allows you to build custom layouts with specific encoding and chunking strategies for different columns.
>
> I would highly recommend checking out both of these projects if you're interested in modern data systems.
>
> *(quote-tweets Ankush's own parent tweet above)*
>
> Engagement: 100 likes | 19 retweets | 2 replies
> [Original post](https://x.com/ankush_gola11/status/2054681251513254260)
