---
created: 2026-09-17
description: Josh Rosen's X Article argues context infrastructure is converging on the data lakehouse pattern — preserve the raw event history, derive memories, graphs and embeddings from it later — because the write path cannot know at storage time what will matter, and "once the underlying information is gone, better retrieval cannot recover it." Names CortexDB, Statewave and Supermemory as instances, states CrewAI's selective-extraction counter-position fairly, proposes a three-tier medallion architecture for context (high-fidelity record / continuously rebuilt interpretations / per-consumer views), and argues the economics now favor materialized views because storage is cheap while interpretation costs inference. Leaves fact currency and inferred-vs-stated provenance explicitly unsolved. No benchmarks, no implementation, and the three products are cited from their own docs.
source: https://x.com/josharosen/status/2099928522521244073
author: Josh Rosen
type: article
tags: [agentic-memory, context-infrastructure, data-lakehouse, medallion-architecture, materialized-views, event-sourcing, cortexdb, statewave, supermemory, crewai, zep, provenance, write-path-compression]
---

## Key Takeaways

- **"Decide later" is the load-bearing claim, and it is falsifiable because it is about epistemics, not storage cost.** Most memory systems make their critical decision on the *write path*: a model picks which facts are important, compresses them into a summary, fact set, embedding, graph node or memory object, and discards the rest — so "whatever gets written becomes the persistent version of history." Rosen's objection is not that this wastes disk. It is that "the system has to know at storage time what might matter later, and that is an unusually hard thing to know," with three concrete failure shapes: a support-conversation detail that explains an escalation three months later, an intermediate artifact another agent needs to challenge a conclusion, and a tool result that only becomes legible once a model gets better at interpreting it. The asymmetry is what turns a preference into a design claim — "once the underlying information is gone, better retrieval cannot recover it." The vault holds a shipped instance of exactly that loss in [[Claude Code memory has a silent 200-line index cap that drops old memories without warning|Claude Code's memory index truncating at 200 lines with no warning]], where the write path discarded on a rule nobody chose and no retrieval improvement can undo it, and a shipped instance of the opposite in [[GPT-6 Astra swaps Codex compaction for notes across context windows plus searchable earlier windows including tool outputs|Astra keeping earlier context windows searchable including raw tool outputs while writing notes forward]] — the same preserve-the-event-derive-the-note split, at harness scale rather than infrastructure scale.

- **He states the counter-position by name, and the vault holds the measured evidence his essay does not.** [[context graphs let agents build verifiable, cross-agent memory instead of isolated notes|CrewAI]] "explicitly argues against naïve 'store everything' memory because stale and contradictory information eventually overwhelms retrieval," using selective extraction, contradiction resolution and intentional forgetting; Rosen concedes this keeps the system "relatively clean and coherent," and [[memory is a compiler not a database - Ashwin Gopinath argues admission and action utility functions are the moat, and silence is the evidence they work|the memory-as-compiler position goes further, making forgetting constitutive rather than regrettable]]. That side has numbers: [[Auto-Dreamer learns offline region rewriting to shrink language-agent memory 12x while improving task success|Auto-Dreamer's learned region rewriting shrinks memory banks 6-12x while raising success]] across ALFWorld, ScienceWorld and WebArena, and [[Harvey's Tenet post-trains Kimi K3 with GSPO in rubric-graded legal environments, doubling LAB hold-out completions while co-optimizing cost via reward shaping|Engram's studied 27B]] takes closed-book firm knowledge from 4.7% to 72.6% by compiling a corpus into weights. The strongest measured point nonetheless lands on Rosen's side, and it is a hybrid rather than a purist: [[indexed experience memory compresses LLM agent context without discarding evidence by pairing summaries with a dereferenceable archive|Memex keeps a pointer-heavy indexed summary in context while archiving full-fidelity artifacts externally]], reaching 24% → 86% on a hardened ALFWorld with 43% less working context. Read together, preserve-vs-compress is a false binary at the altitude Rosen argues it: what Memex and Auto-Dreamer both retain is *dereferenceability* — a pointer or a provenance link back to the artifact — and that, rather than raw volume, is what "decide later" actually requires.

- **The medallion mapping is the reusable artifact, and the vault's own semantic-layer dispute shows its middle tier is one box too few.** Bronze is a high-fidelity record of what happened — conversations and documents alongside tool calls, executions, changes, events and intermediate work. Silver is "continuously rebuilt interpretations": entities, facts, memories, relationships, summaries, embeddings, temporal states. Gold is per-consumer projection, and the per-consumer framing is the genuinely useful part because it makes the top layer plural by construction instead of positing one canonical "memory" — "a support agent might need customer context, while a coding agent might need project history. A judge might need an evidence bundle, while an orchestrator might need current state," which is the same scoping [[LangChain Deep Agents specifies long-term memory as files routed to a store namespace, making user, agent, and org scope a lambda over runtime identity|Deep Agents implements as a store namespace resolved from runtime identity]]. But Silver stays undifferentiated, and [[MotherDuck's Simon Spati splits semantic layer from context layer by what compiles to SQL, and argues sophistication is a cost not a default|Späti's compiles-to-SQL test splits exactly that tier in two]] — definitions written as logic that compile to a query versus everything that cannot be — with different authoring, different maintenance owners, and different claims on a deterministic interface. Rosen's own earlier piece, [[Snowflake, Databricks and ClickHouse preview AI architecture by turning inference into a database operator, the semantic layer into agent infrastructure, and agents into a new database workload|which this vault already holds]], put the semantic layer *into* agent infrastructure; here it is folded into an unlabeled interpretation layer without reconciling the two. His own warning is the reason the boundary matters — "without structure around the storage layer for context, it can and will produce a context swamp" — and it needs metadata management, lineage, quality checks and access controls to avoid, which is the argument that [[every app that avoids a database ends up rebuilding one badly|every system that avoids a database ends up rebuilding one badly]].

- **The economic argument for materialized views is the sharpest idea here, and it collides head-on with the vault's best-measured resistance.** Storage is getting cheap while "the expensive operation may increasingly be interpretation. Extracting memories costs inference and building relationships costs inference. Reconciling contradictions costs inference too, as does re-running transformations every time the underlying data changes." The prescription follows: compute frequently-useful interpretations once and maintain them, generate rare ones on demand, cache expensive transformations — and CortexDB "explicitly describes its graphs, embeddings and indexes as materialized views over the immutable event stream." Now read it against [[Sentra matches Engram's studied 27B on Harvey's LAB benchmark with zero weight changes, arguing a materialized view is a stored answer and a weight has no address|Sentra]], which agrees with Rosen completely about Bronze — an append-only ledger of provenanced fact chunks is the source of truth — and disagrees completely about whether the derived layer should persist at all. Gopinath's objection is that "a materialized view is a stored answer," so Sentra compiles the relationship graph "fresh for each question, for the specific asker, at a specific moment, and then releases it." His reason is governance rather than cost: same firm, same question, two lawyers, one walled off from the matter — a persisted view has already committed to an answer that cannot be per-asker. And he has the number that makes the refusal affordable, 70.7% / 36.0% on Harvey's LAB at $0.15 per query with nothing cached. So Rosen's cost case for materialization is simultaneously his strongest reasoning and the claim with the most credible measured pushback. The shared premise is stated best by [[every representation is an IR - the append-only semantic ledger is memory and vectors, graphs, and context windows are views compiled from it|the same author's IR framing]]: if it can be deleted and faithfully rebuilt, it is a view — only evidence and semantic history are irrecoverable.

- **Two problems he raises without solving are the ones the whole architecture rests on, and the best reply in the thread names a third.** Fact currency: "if an agent remembers five versions of the same fact, the system needs to know which one is current." Provenance kind: "if a fact was inferred by a model rather than stated by a user, the system needs to preserve that distinction." Both are Silver-layer obligations asserted without a mechanism; Statewave's compiled memories carrying confidence, provenance and temporal validity is the closest thing he cites, and the vault's [[Semantica and Cognee solve agent memory differently - Semantica adds accountability while Cognee builds the knowledge engine|Semantica as an accountability layer over a knowledge engine]] is the same instinct given a product shape, as is the case for [[a file system is not all you need - databases beat markdown for agent context provenance and governance|databases over markdown when provenance and governance are the load]]. @synorb's reply supplies the mechanism Rosen skipped: "databricks can trace a gold row to bronze, but most memories can't name the event they came from. that's likely where confident-and-wrong gets its confidence." The one clean operational rule he does give survives independent of the whole lakehouse framing — "storing everything and sending everything to the model are completely different things," so optimize the write side for preservation and the read side for usefulness, with Zep's Context Lake assembling token-efficient context on demand from a much larger persistent store. That is [[The Price of Meaning prescribes coupling semantic retrieval with exact episodic grounding as the only escape from interference|the same instinct as coupling semantic retrieval to exact episodic grounding]], and the reason million-token windows do not retire the problem.

- **Take the framework, discount the evidence: there are no benchmarks, no implementation of his own, and no measured claim anywhere in 1,670 words.** The three systems are cited from their own documentation rather than evaluated — CortexDB (immutable events with replaceable summaries, embeddings and knowledge graphs, arguing that repeatedly rewriting history through LLM summaries loses information), Statewave (immutable episodes compiled into typed memories carrying confidence, provenance and temporal validity), Supermemory (source material preserved while facts and relationships are derived) — and none of them carries a number. CortexDB and Statewave are new to this vault; Supermemory appears only as a name on [[Sam Z Liu's context gold rush map - why everyone is building the same org-level company brain|the company-brain market map]]. None overlaps [[Mem0 surveys nine agent harness memory systems and finds five recurring gaps - bounded storage, keyword retrieval, harness scoping, weak staleness, and isolation|Mem0's nine]], which surveys agent *harnesses* — Claude Code, Hermes and peers — rather than memory products, so the two taxonomies are complementary and Rosen's three slot in underneath as infrastructure the harnesses would sit on. He closes without overclaiming: "context management is still early... some of the patterns apply, while others may need to be adapted to the primary consumer being an agent." The right use of this essay is as a checklist for interrogating a memory vendor — where is your Bronze, can you rebuild Silver, which facts are current, which were inferred — not as evidence that the lakehouse shape wins.

## External Resources

- Source: [Context Infrastructure: Architectural Lessons From the Data Lakehouse](https://x.com/josharosen/status/2099928522521244073) — Josh Rosen (@JoshARosen), X Article, 15 Sep 2026. ~1,670 words, 8 sections, 169 likes / 7 replies
- [CortexDB event sourcing docs](https://cortexdb.ai/docs/concepts/event-sourcing) — immutable event log as source of truth; summaries, embeddings and knowledge graphs as replaceable materialized views over it. New to this vault
- [Statewave](https://www.statewave.ai/) — raw immutable episodes compiled into typed memories carrying confidence, provenance and temporal validity. New to this vault
- [Supermemory](https://supermemory.ai/) — preserves source material while deriving facts and relationships from it
- [CrewAI: How we built cognitive memory for agentic systems](https://crewai.com/blog/how-we-built-cognitive-memory-for-agentic-systems) — the named counter-position: selective extraction, contradiction resolution, intentional forgetting
- [Zep Context Lake](https://www.getzep.com/platform/context-lake/) — ingests chat, JSON, documents, application events and business data into temporal context graphs, then assembles token-efficient context on demand
- [Databricks medallion architecture](https://docs.databricks.com/gcp/en/lakehouse/medallion) — the Bronze/Silver/Gold source of the analogy; Bronze explicitly recommends maintaining source fidelity and history so downstream layers can be rebuilt
- [Databricks: what is a data lakehouse](https://www.databricks.com/glossary/data-lakehouse) — the glossary definition Rosen anchors to

## Original Content

> [!quote]- Full X Article (Josh Rosen, "Context Infrastructure: Architectural Lessons From the Data Lakehouse", 15 Sep 2026)
>
> @JoshARosen (Josh Rosen):
> Article: Context Infrastructure: Architectural Lessons From the Data Lakehouse
>
> *Article cover: a rod propped on a rock labelled MODEL, fishing a card labelled CONTEXT out of the lake — the essay's own joke about where context now comes from.*
> ![[josharosen-244073-001.jpg]]
>
> A new pattern is showing up in context infrastructure: store as much of the underlying history as possible, then build the useful representations of it later. The idea is that you don’t have to know upfront what will matter or what future agents and applications will need from it.
>
> If this approach sounds familiar, it’s because it mirrors a common data architecture. [Data lakehouses](https://www.databricks.com/glossary/data-lakehouse) are built around preserving raw data first, then letting different models and views be built over it later.
>
> You can see versions of this architecture in several new products. [CortexDB](https://cortexdb.ai/docs/concepts/event-sourcing) stores interactions as immutable events and builds replaceable summaries, embeddings and knowledge graphs over them. [Statewave](https://www.statewave.ai/) stores raw episodes before compiling them into typed memories. [Supermemory](https://supermemory.ai/) preserves source material while deriving facts and relationships from it.
>
> Instead of deciding at ingestion time what should become a memory, fact or relationship, these systems preserve what actually happened. Conversations, tool calls, documents, events and agent work accumulate as data underneath. Then, memories, graphs and other structured views are derived from that history and rebuilt as the system changes.
>
> To be clear, this is different from storing a lot of data and querying it later. Instead, the underlying history becomes the source for semantic models and views that are carefully curated and rebuilt over time.
>
> We know from decades of experience with data lakehouses that this architecture can be powerful, but it also comes with challenges. These lessons give us a useful framework for thinking about where context infrastructure is headed.
>
> ## Decide Later
>
> Most memory systems make their critical decisions on the write path. A conversation happens, an agent does some work, and a model decides which facts are important enough to remember. It compresses them into some representation and discards most of what happened.
>
> That stored representation might be a summary, a set of facts, an embedding, a graph node or a memory object. Whatever gets written becomes the persistent version of history.
>
> There is an obvious advantage to doing this. You store dramatically less data and keep the memory system relatively clean and coherent. [CrewAI](https://crewai.com/blog/how-we-built-cognitive-memory-for-agentic-systems?utm_source=chatgpt.com), for example, explicitly argues against naïve “store everything” memory because stale and contradictory information eventually overwhelms retrieval. Its architecture selectively extracts memories, resolves contradictions and intentionally forgets information.
>
> But there is an obvious tradeoff to throwing raw data away. The system has to know at storage time what might matter later, and that is an unusually hard thing to know.
>
> A detail that looks irrelevant during a support conversation might explain an escalation three months later. An intermediate artifact discarded after an agent finishes a task might contain the evidence another agent needs to challenge its conclusion. A tool result omitted from a summary might become important when a model gets better at interpreting it.
>
> Once the underlying information is gone, better retrieval cannot recover it. Instead of asking the write path to determine the permanent meaning of an event, these systems preserve the event and let future systems reinterpret it.
>
> ## Memory Becomes a View
>
> Once you preserve the underlying history, memory and context can become a view over it rather than the only record you keep. You can change that view over time without losing what it was built from.
>
> The same conversation might produce one set of facts today and another set next year. You can build a knowledge graph over years of history without treating that graph as the permanent version of what happened. Better embedding models can re-index old information, while new agents can use the same history in ways that weren’t anticipated when it was captured.
>
> [CortexDB](https://cortexdb.ai/docs/concepts/event-sourcing) makes this explicit. Its event log remains the source of truth, while summaries, embeddings and knowledge graphs are artifacts built on top of it and can be replaced. The argument is that repeatedly rewriting history through LLM summaries loses information. Keeping the original events gives you something to go back to when you want to build a better representation.
>
> [Statewave](https://www.statewave.ai/) takes a similar approach with immutable episodes and compiled memories. The episodes preserve what happened, while the memories add things like confidence, provenance and temporal validity.
>
> In this model, the memory you use today is just one representation of the history you have stored. As models improve or requirements change, you can go back to that history and build another one.
>
> ## The Data Industry Already Solved Part of This
>
> Data infrastructure went through a closely related architectural shift.
>
> Traditional data warehouses wanted data modeled before it arrived. Organizations defined schemas, transformed source data into the expected representation and loaded the resulting structure into the warehouse.
>
> Data lakes enabled you to land the data first, preserve it close to its original form, and apply structure later. Lakehouses built on that approach by bringing more of the management and reliability of warehouses to data stored in lakes.
>
> Modern lakehouse architectures refined the idea further by separating raw data from cleaned, standardized and application-ready representations. [Databricks’ medallion architecture](https://docs.databricks.com/gcp/en/lakehouse/medallion?utm_source=chatgpt.com) starts with a Bronze layer containing raw data and explicitly recommends maintaining source fidelity and historical data so downstream layers can be rebuilt. Silver layers clean and standardize that data while Gold layers serve particular business and application needs.
>
> The mapping to context infrastructure is surprisingly direct. The raw event history could be Bronze. Compiled memories and extracted entities look like Silver. The carefully assembled context handed to a model for one particular task looks like Gold.
>
> In other words, the model does not need the entire history. It needs a highly specific projection of the history.
>
> ## Optimize for Usefulness
>
> As context windows get much larger, it may become tempting to not only store more raw data but also provide more of it directly in the context window. After all, if models can consume millions of tokens, why not simply give the model everything?
>
> But storing everything and sending everything to the model are completely different things. The persistent layer can be enormous while the inference-time context should focus on what might be most useful to the model at any given time.
>
> [Zep](https://www.getzep.com/platform/context-lake/) illustrates that separation well. It ingests chat, JSON, documents and application events along with business data. It structures those signals into temporal context graphs and then assembles token-efficient context on demand. The persistent context can be much larger than the context consumed during any particular inference.
>
> One possible strategy for context is to optimize the write side for preservation while optimizing the read side for usefulness.
>
> ## Preventing Context Swamps
>
> If you've heard of data lakes, you might have also heard of data swamps, the term for when data lakes get out of control. That's the downside of trying to store all raw data without the right controls in place. Without structure around the storage layer for context, it can and will produce a context swamp.
>
> Modern data platforms needed metadata management, semantic consistency and access controls. They also needed lineage, quality checks and mechanisms for discovering what was actually inside them. Databricks’ own medallion guidance progressively introduces validation and schema enforcement as data moves from its raw Bronze representation into more curated layers.
>
> Context infrastructure will face the same problem, probably with several additional dimensions. If an agent remembers five versions of the same fact, the system needs to know which one is current. If a fact was inferred by a model rather than stated by a user, the system needs to preserve that distinction.
>
> ## Context Needs Its Own Medallion Architecture
>
> If this approach wins, context infrastructure may end up developing layers that look familiar to anyone who has built a modern data platform.
>
> At the bottom is a high-fidelity record of what actually happened. That might include conversations and documents alongside tool calls, executions and changes. It can also include events and intermediate work.
>
> Above that are continuously rebuilt interpretations. We get to decide how we model these context layers in the best way for our agents. These might be entities, facts, memories and relationships. Other representations could include summaries, embeddings and temporal states.
>
> Above those are application-specific views of context. A support agent might need customer context, while a coding agent might need project history. A judge might need an evidence bundle, while an orchestrator might need current state.
>
> If we built this for context, we'd be building something close to a data pipeline with multiple representations optimized for different consumers.
>
> ## Next Up: Materialized Context Views
>
> Data lakes and lakehouses became viable partly because storing enormous amounts of raw information became cheap. AI systems may experience the same shift, especially when text, traces and structured events are inexpensive compared with repeatedly running frontier models over them.
>
> The expensive operation may increasingly be interpretation. Extracting memories costs inference and building relationships costs inference. Reconciling contradictions costs inference too, as does re-running transformations every time the underlying data changes.
>
> That could push context infrastructure toward another familiar data pattern: materialized views. Frequently useful interpretations are computed once and maintained. Less common interpretations are generated when needed, while expensive transformations are cached.
>
> CortexDB explicitly describes its graphs, embeddings and indexes as materialized views over the immutable event stream.
>
> ## Context is Data After All
>
> Context management is still early. We are only starting to figure out what should be stored and what should be modeled. There is also the question of what context representations are even best for agents.
>
> As the space matures, it will be interesting to see how much context infrastructure borrows from familiar data lakehouse architectures. Some of the patterns apply, while others may need to be adapted to the primary consumer being an agent.
>
> Context management will likely grow into a much bigger infrastructure problem than retrieval alone. Whether it ultimately resembles a data lakehouse or develops its own architecture, we are starting to see familiar questions about how raw information gets turned into useful context.
> date: Tue Sep 15 18:29:09 +0000 2026
> url: https://x.com/JoshARosen/status/2099928522521244073
> likes: 169  retweets: 26  replies: 7

> [!quote]- Reply thread (6 replies, incl. two short author acknowledgements)
> @synorb (Synorb):
> the medallion mapping is brilliant. bronze events, silver memories, gold context.
>
> the lakehouse lesson i'd dig into next is lineage.
>
> databricks can trace a gold row to bronze, but most memories can't name the event they came from. that's likely where confident-and-wrong gets its confidence.
> date: Tue Sep 15 19:42:57 +0000 2026
> url: https://x.com/synorb/status/2099947095985987754
> ──────────────────────────────────────────────────
>
> @amigus (Adam Migus):
> @JoshARosen I love your content because you're always telling me I'm right! 😆
> date: Tue Sep 15 21:42:07 +0000 2026
> url: https://x.com/amigus/status/2099977085351571797
> ──────────────────────────────────────────────────
>
> @JoshARosen (Josh Rosen):
> @amigus Haha! Glad to hear it!
> date: Tue Sep 15 21:51:42 +0000 2026
> url: https://x.com/JoshARosen/status/2099979498284322940
> ──────────────────────────────────────────────────
>
> @alex_vivek_ (Vivek👨‍💻):
> started @opencortyx wanting to store everything. Then it became clear we aren’t mature enough to decide, at ingest, what knowledge should persist. Agent memory is only one kind. Anything can be knowledge.
> The write path shouldn’t compress history into one permanent representation. Keep what happened. Let memories, graphs, and embeddings be views you can rebuild.
> It’s good read
> date: Tue Sep 15 21:58:35 +0000 2026
> url: https://x.com/alex_vivek_/status/2099981229814890900
> ──────────────────────────────────────────────────
>
> @JoshARosen (Josh Rosen):
> @alex_vivek_ @opencortyx That’s interesting. Yeah it’s a hard problem at scale.
> date: Tue Sep 15 22:01:11 +0000 2026
> url: https://x.com/JoshARosen/status/2099981882238652685
> ──────────────────────────────────────────────────
>
> @joyrexus_jv (J Voigt):
> @JoshARosen Something I haven’t seen much explored is statechart representations of key biz flows and how snapshots of their executions can serve as precedential context, esp if the transition guards capture decisions with embedded reasoning.
> date: Tue Sep 15 22:45:58 +0000 2026
> url: https://x.com/joyrexus_jv/status/2099993154166427684
> ──────────────────────────────────────────────────
