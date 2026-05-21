---
created: 2026-05-21
description: dltHub Pro launches as a Claude/Codex/Cursor-native platform built around an agent-readable context layer — schemas, metadata, traces, runtime logs — rather than a chat surface, backed by data showing agents now write 91% of dlt pipelines at 81,000 per month.
source: https://x.com/matthausk/status/2057102844382023723
type: framework
---

# dltHub Pro delivers a context graph for data engineering because agent-readable schemas and traces outcompete chat-box overlays when 91% of pipelines are agent-written

## Key Takeaways

- Chat boxes on top of legacy data tooling failed to make Claude/Codex/Cursor measurably better at building pipelines — what matters is whether the platform sits in the execution path and produces a continuous stream of schemas, decision traces, source semantics, and runtime logs that agents can read and write. This is the same thesis as [[data agents are useless without a context layer that captures business definitions and tribal knowledge]]: context infrastructure beats model capability as the competitive moat. The "everything is context" framing extends to data engineering exactly as [[Everything is Context - Agentic File System Abstraction for Context Engineering]] argues at the filesystem level — persistent, governed, traceable context artefacts as the primary substrate.

- dltHub Pro operationalizes this as a "context graph" — every dlt pipeline run is itself the trace, capturing schema decisions, source semantics, transformations, and runtime logs in a single queryable store. The "runtime logs" piece is precisely where [[learning - OTel GenAI semantic conventions are becoming the standard wire format for LLM agent observability]] converges: dlt's execution-path traces are the data-engineering analogue of OTel spans for agent tool calls. Foundation Capital's @JayaGup10 framed the architecture: systems that sit in the execution path (where context gets captured as decisions are made) become the system of record for decision lineage; warehouses that only see the read path cannot. This parallels [[OpenAI internal data agent succeeds through six layers of context not model capability alone]], which stacks six context layers over 600PB — both converge on the execution path as the only place where context can be captured faithfully.

*Agent-assisted schema-to-concept mapping: CountryArtistChart, ArtistTag, ArtistSimilarity resolved from source tables*
![[matthausk-023723-001.jpg]]

- The pipeline growth data is the sharpest evidence: in January 2025, agents wrote 5% of dlt pipelines (2,400/month); by January 2026 they write 91% (81,000/month) — 10× more than humans, with unique DuckDB devices loading via dlt growing 15× (3,923 → 58,306). [[Prime Intellect duckdb-qa - RL reward shaping for SQL tool use]] represents early RL work in this DuckDB-native data agent space; dltHub Pro is the production runtime that absorbs the output of that work at scale.

*dltHub pipeline authorship: 5% agent-written in Jan 2025 → 91% in Jan 2026, 81,000 pipelines/month*
![[matthausk-023723-002.jpg]]

- Python-first, declarative, code-first architecture was right for humans for inspection and trust reasons — and it turns out those same properties (atomicity, composability, no monolith) are exactly what lets an agent reason about a pipeline end-to-end. @jlowin's "PyStack" framing at PyData SF names this: atomic, composable Python primitives that LLMs can reason about. This is the same rationale behind [[RLMs inline intelligence into data pipelines by giving LLMs symbolic access to DataFrames in a persistent REPL]] — agents need symbolic handles into data structures, not black-box ETL.

- a16z's @seema_amble makes the parallel from the market side: as software goes headless, defensibility moves into data, context, and action layers underneath — not UI. dltHub didn't change dlt; they changed the runtime around it. The three design principles (transparent + declarative + context-aware; modular + composable; human-in-the-loop guardrails) mirror [[context management replaces the semantic layer for data agents because it adapts from corrections]]: agents propose, humans validate, deterministic tooling enforces.

## External Resources

- [JayaGup10 on context graphs](https://x.com/JayaGup10/status/2003525933534179480) — Foundation Capital's Jaya Gupta on context graphs as living records of decision traces, schemas, and rationale stitched across systems
- [PyData SF — jlowin on PyStack](https://www.youtube.com/watch?v=lwy10m-gnDM) — atomic, composable Python primitives LLMs can reason about
- [seema_amble at a16z on headless software](https://x.com/seema_amble/status/2054583700302729464) — as software goes headless, defensibility moves into data, context, and action layers
- [dltHub](https://dlthub.com/) — open-source dlt library and dltHub Pro runtime
- [continuedev](https://continue.dev/) — AI coding IDE extension mentioned in user demo
- [OuterboundsHQ](https://outerbounds.com/) — ML platform mentioned in user demo

## Original Content

> [!quote]- Source Material
> **@matthausk (Matthäus Krzykowski) — Wed May 20 14:15:11 +0000 2026**
> Engagement: 51 likes | 9 retweets | 3 replies
>
> Article: Claude/Codex/Cursor don't need a chatbot. They need a context layer.
>
> In the last year, most data tools added a chat box. Few of them made Claude, Codex, or Cursor measurably better at building pipelines. What agents need isn't a chat surface on top of legacy tooling - it's a layer of schemas, metadata, traces, runtime logs, and semantic annotations they can read from and write to, end-to-end, from extract & load through transformations to deployment.
>
> A year ago, 5% of new dlt pipelines were written by agents. Today it's 91%, on 81,000 pipelines a month - 10× more than humans write. Where these pipelines get built, the developer's local laptop, grew with them. Unique DuckDB devices loading via dlt grew 15×, from 3,923 to 58,306 last month.
>
> ![[matthausk-023723-002.jpg]]
>
> This is why we are launching dltHub Pro, a Claude/Codex/Cursor-native platform that makes data engineering accessible to any Python developer, pairing agents that build dlt pipelines with the runtime that ships them to production.
>
> As agents become the primary builder of data pipelines, the surface a user sees matters less than what flows underneath. The platform that wins for agents is the one that continuously produces the highest-quality context - schemas, metadata, traces, runtime logs, semantic annotations - and lets agents compose against it from extract & load through transformations to deployment.
>
> That's what makes a platform Claude/Codex/Cursor-native. Not the UI. Not the buttons. Not the chat box. An agent-readable context layer that every workflow reads from and writes to.
>
> The data is the context now.
>
> ## Context graphs for data engineering
>
> Foundation Capital's @JayaGup10 named this in December. She called it a context graph: a living record of decision traces, schemas, metadata, and rationale, stitched across systems and time, queryable as precedent. Her core argument: the platforms that build context graphs sit in the execution path - where context gets captured as decisions are made. Warehouses see only the read path, after the fact. A system that only sees reads can't be the system of record for decision lineage.
>
> dltHub Pro is a context graph for data engineering. Every pipeline run captures the schema decisions, the source semantics, the transformations, the runtime logs - in the same store, queryable, agent-readable. dlt is in the execution path. The pipeline itself is the trace. Context allows for "magical" data engineering moments such as agents figuring out joins and schemas of two dlt pipelines as demonstrated above.
>
> ![[matthausk-023723-001.jpg]]
>
> ## Python-first was right twice
>
> Five years ago, agents weren't writing pipelines. We @dltHub made dlt Python-first, declarative, modular, and code-first because that was what humans needed to trust a library: code-first semantics, easy inspection, no monolith. It turns out those same properties are exactly what lets an agent reason about a pipeline end-to-end - and what lets a context graph get produced as a side-effect of every run. The shape generalizes. @jlowin called the architecture beneath it "PyStack" at PyData SF in March: atomic, composable Python primitives LLMs can reason about. @seema_amble at a16z made the parallel case from the market side last week - as software goes headless, defensibility moves into the data, context, and action layers underneath. The library humans wanted is the library agents need. We didn't change dlt. We changed the runtime around it.
>
> ## What dltHub Pro is
>
> The production runtime paired with an ever increasing set of agent-facing toolkits - REST API and database ingestion, exploration, transformation, deployment - built on dlt's open-source primitives. Built for the smallest team that can run an end-to-end data stack: one agentic coder and a handful of stakeholders. The engineer doing the analyst's job. The analyst doing the engineer's job. Anyone fluent in AI plus a little Python.
>
> Three principles codify how we build it: transparent, declarative, context-aware (everything is code, semantics flow as metadata); modular and composable (@duckdb, @marimo_io, Ibis, not a monolith); human-in-the-loop guardrails (agents propose, humans validate, deterministic tooling enforces).
>
> Try it
>
> ```
> $ uvx dlthub-start
> ```
>
> ![[matthausk-023723-003.jpg]]
>
> This installs your local dltHub workspace with agent configs for Claude, Cursor, and Codex ready to go. Two weeks on us with $30 in credits on us, no card. Upgrade anytime.
>
> User quotes below ↓
>
> ---
>
> **@matthausk — Wed May 20 14:20:12 +0000 2026**
> @NateSesti - @continuedev [VIDEO]
> https://x.com/matthausk/status/2057104105164673280
>
> **@matthausk — Wed May 20 14:20:58 +0000 2026**
> @NateSesti @continuedev @matsonj - @motherduck [VIDEO]
> https://x.com/matthausk/status/2057104300237537454
>
> **@matthausk — Wed May 20 14:22:02 +0000 2026**
> @NateSesti @continuedev @matsonj @motherduck @surajrajan - Snowflake [VIDEO]
> https://x.com/matthausk/status/2057104565086924893
>
> **@matthausk — Wed May 20 14:24:53 +0000 2026**
> @NateSesti @continuedev @matsonj @motherduck @surajrajan Simon Rosenberger [VIDEO]
> https://x.com/matthausk/status/2057105282501644771
>
> **@matthausk — Wed May 20 14:25:31 +0000 2026**
> @NateSesti @continuedev @matsonj @motherduck @surajrajan @josh_wills - Datalogy [VIDEO]
> https://x.com/matthausk/status/2057105442325561657
>
> **@matthausk — Wed May 20 14:26:22 +0000 2026**
> @NateSesti @continuedev @matsonj @motherduck @surajrajan @josh_wills Martin Seifert - Pro Juventute [VIDEO]
> https://x.com/matthausk/status/2057105658021826706
>
> **@matthausk — Wed May 20 14:27:39 +0000 2026**
> @NateSesti @continuedev @matsonj @motherduck @surajrajan @josh_wills @SavinGoyal - @OuterboundsHQ [VIDEO]
> https://x.com/matthausk/status/2057105978877784299
>
> **@matthausk — Wed May 20 14:28:35 +0000 2026**
> @NateSesti @continuedev @matsonj @motherduck @surajrajan @josh_wills @SavinGoyal @OuterboundsHQ Hans Ritschl - Consultant [VIDEO]
> https://x.com/matthausk/status/2057106216325669354
>
> **@matthausk — Wed May 20 14:29:13 +0000 2026**
> @NateSesti @continuedev @matsonj @motherduck @surajrajan @josh_wills @SavinGoyal @OuterboundsHQ Euan Johnston - Dentolo [VIDEO]
> https://x.com/matthausk/status/2057106372425142653
>
> **@matthausk — Wed May 20 14:30:40 +0000 2026**
> @NateSesti @continuedev @matsonj @motherduck @surajrajan @josh_wills @SavinGoyal @OuterboundsHQ Stefan Szegeny - Hiveapp [VIDEO]
> https://x.com/matthausk/status/2057106740391387332
>
> ---
>
> **@Blum_OG (Blum) — Wed May 20 17:10:17 +0000 2026**
> @matthausk super useful, most folks don't actually understand this
>
> **@corelumen (Nicholas Blanchard) — Wed May 20 18:38:11 +0000 2026**
> @matthausk Working on it. This is what I have released so far:
> https://t.co/d7DFZI3e6D
> Currently building a new type of data structure for agents.
>
> [Original post](https://x.com/matthausk/status/2057102844382023723)
