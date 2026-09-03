---
created: 2026-09-03
description: Simon Späti's primer on the MotherDuck blog separating three terms that keep collapsing into each other in agentic data work. The operational split is the useful part — a semantic layer is a definition written as logic that compiles to SQL (a metric, a dimension), a context layer holds everything else, "the rules that can't be explained, and everything unrelated to a dedicated query," and an ontology supplies object types, link types, and properties so an agent can relate entities to the world. Names the context-layer paradox — we only need this much context because of agents, and can only manage it because of agents. The strongest section argues sophistication is a cost, not a default: MotherDuck's own Guides show a flat topic tree of curated titles beating embeddings and graph traversal, while an airport/flight ontology genuinely earns a graph, and the deciding question is whether the bottleneck is relating entities or picking one document out of a hundred. Extends that lens to explain why a semantic layer earns a deterministic machine-callable interface and a context layer does not — who is asking, and what it costs to be wrong. Flags Apache Ossie as the vendor-neutral semantic spec, and the missing primitive of a data-quality score for context.
source: https://motherduck.com/blog/context-layer-vs-semantic-layer-ontology/
author: Simon Späti
type: synthesis
tags: [data-agents, semantic-layer, context-layer, ontology, knowledge-graph, context-graph, motherduck, palantir-foundry, graph-rag, data-governance, apache-ossie, text-to-sql]
---

## Key Takeaways

- **The definitional split is the reusable part, and it is sharper than most attempts because it is an operational test rather than a taxonomy.** "**Semantic Layer**: Definition is **written as logic that compiles to SQL**, like a metric or a dimension. **Context layer**: Holds everything else: the rules that can't be explained, and everything that is **unrelated to a dedicated query**." You can apply that to any candidate artifact in seconds. The semantic-layer half leans on Julian Hyde (Looker/LookML, Morel): a layer between business users and the database that lets users "compose queries in the concepts that they understand," governs access, manages transformations, and tunes via materializations. The context-layer half leans on a16z's three parts — accessing the right data, **automated context construction** focused on high-signal sources (query history reveals the most-referenced tables and most common joins; dbt/LookML supply metric definitions), and **human refinement**, because automation "can't create the full picture." That middle piece is already documented in practice: [[OpenAI internal data agent succeeds through six layers of context not model capability alone|OpenAI's internal data agent stacks six context layers including query history and code-level definitions]]. The practical consequence: context layers are aimed at exactly the sources a semantic layer always excluded — Notion, Confluence, free-flow markdown — which is the material [[data agents are useless without a context layer that captures business definitions and tribal knowledge|the living-context-layer argument]] has been pointing at all along.

- **The paradox he names is the genuinely new observation in the piece.** "If we **didn't have agents, we wouldn't need this much context**. But we **need more context because of agents**, and we **can only manage it because we have agents**." The mechanism is concrete: before agents, unstructured markdown was never a real data source because there is no incremental load on markdown — you could not tell what changed or what was high-signal, so it was excluded. Agents made ingestion tractable *and* created the demand, because an agent needs "every bit of human-written information" to decide well. That is a self-reinforcing loop rather than a trend, which is a better explanation for why context layers appeared all at once than any of the market framings. The unexamined premise is that markdown is the right destination at all — [[a file system is not all you need - databases beat markdown for agent context provenance and governance|the counterargument is that markdown looks clean and then collapses under query, maintenance and governance load]], which is precisely the burden his own closing section concedes is the hard part. He pairs it with Jacob's version from the *Analytics Power Hour* episode: "you need some level of conformity to communicate well, but also if you have too much conformity, you have a commodity."

- **"Sophistication Is a Cost, Not a Default" is the best section, and it adjudicates a contradiction the vault has been carrying unresolved.** He puts two of his own claims side by side and refuses to smooth them: interconnected knowledge argues for a graph, yet **MotherDuck's own Guides have the agent browse a flat topic tree of curated titles with no keyword or vector search at all, and per their evals a graph "picked worse."** Both are right because they answer different questions — the airport/flight ontology earns a graph because the value is in traversing relations, while guide selection does not, because "the actual bottleneck isn't relating entities to each other, it's picking the one right document out of a hundred, and an agent does that more reliably by scanning titles than by ranking similarity scores." That is the missing decision rule for the vault's split evidence on retrieval sophistication: [[Neo4j's Stephen Chin on agentic graph RAG - vector search finds entry points and graph traversal supplies grounded context|vector-then-graph as the starter graph-RAG pattern]] versus [[hierarchical tree navigation can replace vector embeddings for RAG retrieval|PageIndex eliminating embeddings in favor of LLM tree navigation]] — neither is generally right; the question is what the retrieval bottleneck actually is. The cost side is not hypothetical — [[How to Make Knowledge Graphs Fast - query optimization combines triple indexing, adjacency compression, and partitioning to tame exponential traversal fan-out|taming exponential traversal fan-out takes triple indexing, adjacency compression and partitioning]] — and the same deflationary instinct drives [[agentic search with grep and full-file loading replaces RAG when context windows are large enough|the argument that retrieval pipelines were a small-context workaround]]. The most useful reframe of the whole debate is [[every representation is an IR - the append-only semantic ledger is memory and vectors, graphs, and context windows are views compiled from it|treating vectors, graphs and context windows as compiled views over one provenanced ledger]]: then graph-vs-flat is a choice of compilation target, not a choice of truth. Caveat worth keeping: the Guides-beat-graph result is MotherDuck's own eval on MotherDuck's own product, with no numbers published.

- **The deterministic-interface argument is the sharpest reasoning here and it generalizes well past data tooling.** Why does a semantic layer earn a machine-callable interface (SQL, REST, GraphQL) that a context layer does not? "It comes down to who's actually asking, and what it costs to be wrong." A semantic layer's numbers "get called directly by a dashboard or a scheduled job, with no human and no LLM in the loop, so it has to be right every time," which justifies the cost of building and maintaining that guarantee. A context layer feeds an agent that is still reasoning and still capable of misreading a guide, so a checkpoint remains between the context and the number that ships. The forward-looking half is the part to remember: "As more agent-mediated work goes straight to a dashboard with nobody reviewing it, the case for giving context layers their own consistency guarantees only gets stronger." Read as a general rule — pay for determinism in proportion to how little review stands between the artifact and the decision — it applies to any agent-produced output, not just metrics. [[Google's data-agent study finds semantic metadata (schema.org, FAIR) still beats open-web search for actionable data retrieval|Google's finding that structured semantic metadata beats open-web search for *actionable* retrieval]] is the empirical version of the same point: the more a result must be acted on without review, the more it needs a machine-readable contract.

- **On the vault's live semantic-layer dispute, this is the first source arguing division of labor rather than replacement.** [[Snowflake, Databricks and ClickHouse preview AI architecture by turning inference into a database operator, the semantic layer into agent infrastructure, and agents into a new database workload|Josh Rosen has the semantic layer becoming agent infrastructure]]; [[context management replaces the semantic layer for data agents because it adapts from corrections|Jamie Quint has it dead, replaced by context computed on demand from the dbt DAG plus corrections]]. Späti's answer is that they are "two different answers to that gap and are not mutually exclusive," partitioned by the compiles-to-SQL test. His best evidence is [[Anthropic's self-service analytics stack achieves 95% accuracy by treating the bottleneck as context and entity mapping not SQL generation|Anthropic's self-service analytics setup]], where the skill file makes the semantic layer the **mandatory default path for every data question**, with raw SQL as a fallback used only once the semantic-layer path is shown not to cover the ask — authored and derived coexisting, with an explicit routing rule between them. [[LangChain's agent-first data stack scales self-service analytics 40x by making context explicit across dbt models, a semantic layer, workspace guides, and endorsements|LangChain's stack independently lands in the same place]], keeping a semantic model alongside correction-driven context and workspace guides. He is also candid that MotherDuck's own product sequencing differs: it "ships the context layer first and treats a dedicated semantic layer as a separate, later question."

- **Ontology gets the clearest short definition I've seen, and the two gaps he names are the honest ones.** Palantir Foundry's framing — object types (the schema of a real-world entity), link types (relationships), properties, with the ontology being "the whole schema (all five tables/datasets plus how they join together)" and, in Palantir's words, "the digital twin of an organization." He notes he used this in 2017 on Airbus Skywise, built on Foundry, which is the same substrate argument as [[Palantir Ontology gives enterprise agents a decision-centric substrate by surfacing data logic and action as tools governed by one security model|Palantir's decision-centric Ontology]], and reproduces Ananth Packkildurai's stacking of ontology-as-schema-layer over knowledge-graph-as-instance-layer into a *context graph* — the same schema/instance division as [[Everything Is Connected - knowledge graphs encode entities as directed-labeled triples that support multi-hop traversal and ontology-driven inference|directed-labeled triples governed by an ontology]], and the coinage [[context graphs let agents build verifiable, cross-agent memory instead of isolated notes|context graphs as verifiable cross-agent memory]] already uses. The crispest statement of why both are needed is Sentra's: [[Company Brain Part 7 - Claude Made Agent Memory Real but Semantics and Ontology Are Still Missing|semantics says what something is, ontology says why it matters from a perspective]]. The two admissions: **there is no data-quality metric for context** — he wants something NPS-like aggregating `last updated date, creator (agent/human), ratings` so you could mass-ingest without inspecting each item, and "right now, we do not have it." Partial precedents exist: [[Cerebras built an internal knowledge base as a hybrid-retrieval system fusing lexical, vector, IDF, and age-decay over one Postgres embeddings table|Cerebras makes age-decay a first-class scorer]], and LangChain uses endorsements as an explicit trust signal — neither is the single aggregate score he wants, but both score exactly the axes he lists. Second — **maintenance, not construction, is the real problem**: "the hard part in data is never building semantics or the context once, it's how and who keeps it *correct* and *maintained*." Amdahl's Law is the closing frame: as long as a human must decide what's true, that decision is the speed ceiling. [Apache Ossie](https://github.com/apache/ossie) (formerly Open Semantic Interchange) is offered as the vendor-neutral spec that would stop the LookML/Cube/dbt/Snowflake YAML fragmentation. Note the genre: this is a primer on the vendor's own blog, useful for its definitions and its one decision rule rather than for evidence.

## External Resources

- Source: [Context, Semantics, and Ontology: A Primer for the Agentic Era](https://motherduck.com/blog/context-layer-vs-semantic-layer-ontology/) — Simon Späti, MotherDuck blog, 2 Sep 2026
- Author's own prior pieces: [Beyond the Semantic Layer / Building a Context Layer for the Agentic Era](https://www.kaelio.com/blog/building-a-context-layer-for-the-agentic-era) · [Rise of the Semantic Layer](https://www.ssp.sh/blog/rise-of-semantic-layer-metrics/)
- [Your Data Agents Need Context](https://a16z.com/your-data-agents-need-context/) — a16z's three-part "modern context layer" (Späti footnotes that "modern" is premature — "to me it's the first version of a context layer")
- **[Apache Ossie](https://github.com/apache/ossie)** — the Open Semantic Interchange standard, renamed; vendor-agnostic spec for describing and exchanging semantic models
- Counter-position from the same blog: [Context belongs in the warehouse](https://motherduck.com/blog/context-belongs-in-the-warehouse/) — Hamilton, Till, Jacob and Garret arguing against sophisticated retrieval; [MotherDuck Guides docs](https://motherduck.com/docs/key-tasks/guides/)
- Ontology / context-graph sources: [Palantir Foundry ontology core concepts](https://www.palantir.com/docs/foundry/ontology/core-concepts#ontology) · [What an Ontology for AI Agents Actually Needs](https://www.dataengineeringweekly.com/p/an-ontology-for-ai-agents-is-a-system) (Ananth Packkildurai) · [Ontologies, Context Graphs, and Semantic Layers](https://contextandchaos.substack.com/p/ontologies-context-graphs-and-semantic) (Jessica Talisman) · [What is an Ontology? (2018)](https://arxiv.org/pdf/1810.09171)
- [Are Semantic Layers Really Necessary?](https://analyticshour.io/2026/06/23/300-are-semantic-layers-really-necessary/) — Analytics Power Hour #300, source of the conformity/commodity paradox
- Context-layer tooling named: [ktx](https://github.com/Kaelio/ktx) · [OmniGraph](https://github.com/ModernRelay/omnigraph) · [Nao](https://github.com/getnao/nao) · [Marmot](https://github.com/marmotdata/marmot) · [OpenMetadata](https://github.com/open-metadata/OpenMetadata) · [DataHub](https://github.com/datahub-project/datahub)

## Original Content

> [!quote]- Full blog post (Simon Späti, "Context, Semantics, and Ontology: A Primer for the Agentic Era", MotherDuck, 2 Sep 2026)
> # Context, Semantics, and Ontology: A Primer for the Agentic Era
>
> There's so much talk about new ways of working with agent engineering supported workflows. New models are independently creating new metrics and transformations, finding gaps in the business data, reviewing the SQL they write, and verifying everything works with your data platform.
>
> All of it is autonomous, so one might say, why do we still need BI tools, or therefore a semantic layer, or even a context layer? It's hard to predict the future, but as someone working with newer models as well as older ones, I could see that Fable for example is one-shotting work in minutes that previously took me many iterations with Opus 4.8 (below you see my recent Claude and Codex use (roborev only)). With the right workflows to brainstorm first a spec, then an implementation plan, it's really amazing how fast and precisely one can build with the right amount of inputs we give, and [taste](https://substack.com/home/post/p-189793289).
>
> So what then is left for us humans to do in the data work context? Many are defaulting to adding or curating context, ergo the **rise of a context layer**. I see even more talks about added Ontologies. Maybe you ask yourself, what is that even? Do we need all of it?
>
> This article is a primer about the context layer, the difference between a classical semantic layer contained in every BI tool, and an external semantic layer.
>
> **[Note — The other Surface level]**
> Besides context, I'd add that the other big surface level where a lot is currently happening, with human in the loop vs autonomous agents working, is verification, especially verification in data engineering work.
>
> ## What is Context, and Its Context Layer?
>
> But we can't talk about the new shiny context layer tools, ontologies or any other, before we define context, and how much context we need. If we go by the definition of the word context, [Cambridge Dictionary](https://dictionary.cambridge.org/dictionary/english/context) says:
>
> > The situation within which something exists or happens, and that can help explain it
>
> [Jessica Talisman](https://jessicatalisman.substack.com/), who writes about semantics, the vocabulary and the intersections of ontologies, [defines](https://jessicatalisman.substack.com/p/the-context-problem) context in information science as:
>
> > Describes the **relational structure that holds meaning in place**.
>
> This sounds very much like metadata, the data about the data we collect in logs, orchestration runs, table information, index information. But let's go one step further, what's a Context Layer?
>
> ### What's a Context Layer?
>
> There are multiple definitions out there, and bear in mind, this term is less than a year old, but Andreessen Horowitz [describes a "Modern Context Layer" to contain](https://a16z.com/your-data-agents-need-context/)[^1] three pieces:
>
> > 1) **Accessing the right data**. [...] we'd want to ensure the agent has access to all the data it needs [...] captured in internal systems, GDrive/Slack, etc.
> >
> > 2) **Automated context construction** [...] emphasis of **focus should be on high signal context** – for example, looking through past query history can be high signal in determining the most referenced tables and most common joins, and data modeling solutions like dbt or LookML can provide clear definitions for business metrics.
> >
> > 3) **Human refinement** – Automated context construction may be able to form a large portion of the context corpus, but it can't create the full picture. [...]
>
> I defined it in [Beyond the Semantic Layer](https://www.kaelio.com/blog/building-a-context-layer-for-the-agentic-era) in a similar fashion:
>
> > The context layer primarily **supports the accuracy of SQL queries, continuous updates to the business context**, and governance. Additionally, with a newer context layer, we can **include more relevant business insights** that are stored internally, usually in **unstructured form**, in tools like Notion as business documentation.
>
> So it seems clear, we focus on less "classical" data sources from databases, or structured tables, but more free-flow text that humans wrote in docs, Confluence, Notion.
>
> ### Comparison to a Semantic Layer, and how They Work together
>
> Now that we defined context and its layer, it begs the question, what's the difference to a semantic layer (which, to some, might be another rather vague definition)? I know, I have [written about](https://www.ssp.sh/blog/rise-of-semantic-layer-metrics/) past BI integrated ones, and more modern ones like Cube, Malloy, dbt one, but it still seems everyone has a different definition.
>
> The definition of a semantic layer, as we discussed in [Why Semantic Layers Matter](https://motherduck.com/blog/semantic-layer-duckdb-tutorial/#what-is-a-semantic-layer-why-use-one) (including an example of how to build one), is defined by Julian Hyde, creator of Morel Language, and an early employee of Looker and LookML:
>
> > A semantic layer, also known as a metrics layer, lies between business users and the database, and lets those users compose queries in the concepts that they understand. It also governs access to the data, manages data transformations, and can tune the database by defining materializations.
> > Like many new ideas, the semantic layer is a distillation and evolution of many old ideas, such as query languages, multidimensional OLAP, and query federation.
>
> So that means, a **semantic layer understands the semantics, the metrics and governance access** and data transformation, and has a link to (multi-dimensional) OLAP and query languages, while the **context layer is more focused on gathering context and refinement between humans and agents**.
>
> I see the two, a semantic layer and a context layer, working for distinct fields, and working hand in hand:
> - **Semantic Layer**: Definition is **written as logic that compiles to SQL**, like a metric or a dimension
> - **Context layer**: Holds everything else: the rules that can't be explained, and everything that is **unrelated to a dedicated query**.
>
> ## The Context Layer and Agents Paradox
>
> In a semantic layer, Notion Docs, Confluence pages, and other unstructured text didn't count as real data sources. There's no incremental load on Markdown, so we didn't include them.
>
> There is also another angle in play. Before agents, it was hard to keep track of free flow Markdown text, finding out what has changed in the incremental load, and what's useful, what has the biggest signal as a16z said above. But with the help of agents, we can now integrate more. Agents can do the bulk of the work, and that's why context layers popped up in the first place.
>
> It's a **paradox**: if we **didn't have agents, we wouldn't need this much context**. But we **need more context because of agents**, and we **can only manage it because we have agents**.
>
> We can load more data than ever now **_because_ agents do the integration work** that wasn't feasible before, but we also need to load more data than ever because agents need to be smarter to use it well. The agent needs every bit of human-written information to increase its context and make better decisions, but that's only possible because of agents in the first place.
>
> Jacob saw a similar paradox in [Are Semantic Layers Really Necessary?](https://analyticshour.io/2026/06/23/300-are-semantic-layers-really-necessary/) and says:
>
> > **there's a little bit of a paradox**:  you need some level of conformity to communicate well, but also if you have too much conformity, you have a commodity. You need space to have some differentiation.
>
> **[Note — The crucial part of how to include more unstructured "Context" is how the integration is updated continuously]**
> As with the above definition, I'd 100% agree that the crucial part, and also the challenge, is the combination of agents with human inputs, as [data warehouse projects are all messy](https://motherduck.com/blog/figma-for-agents-airflow-creator-maxime-beauchemin/#balancing-quality-with-quantity-messy-dwhs) as we recently discussed in the Maxime Beauchemin interview.
>
> ### How much Context Do We Need? And what Kind?
>
> That begs the question: How much context do we need, and what kind? Should we gather all Markdown files we find, or use the JIRA tickets where we defined our tasks?
>
> And what's the quality of these JIRA tickets? They might be super up-to-date, but missing a whole lot of information, so what kind of "context" do we get from them, or do we want?
>
> With agents, we could probably say the more context, the better, and hopefully the agent identifies the high-signal and valuable data out of empty Jira tickets 😉. But assuming we gathered all of the above context, how do we actually manage it? How do we update it, how do we make sure it's correct?
>
> This is actually where we always land at the same fundamental questions of *Data Engineering Lifecycle* and *data governance*, especially in an enterprise setting with multiple actors and people. Because it's easy to build up context initially, once. But the hard part is updating it, maintaining it, having rules, having a governance strategy.
>
> So the Context Layer integration, as well as the semantic layer, becomes a data governance and enterprise process definition problem.
>
> ## Open Standards for Metrics and Data Quality
>
> What helps us here are open standards. Luckily we just recently got the **Open Semantic Interchange (OSI)** standard, recently renamed to [Apache Ossie](https://github.com/apache/ossie). They standardise the syntax around semantic layer declarative configuration. The goal is to have an **open-source, vendor-agnostic specification for describing and exchanging semantic models**.
>
> Not that we end up with many different proprietary YAML definitions for LookML, Cube, dbt Semantic Layer, Snowflake's internal one, etc. as we have it today. If you write in the standard, it can be easily mapped to any semantic layer definition.
>
> ### Metrics to Measure the Data Quality of Context
>
> Another part of the puzzle and how good context layers will be, is the data quality. The outcome, the **context itself, strongly depends on the quality** and how up-to-date and *correct* the data is.
>
> One thing I was pondering for a long time: how do we measure that? In my previous job we had a single test score to represent data quality, something like an [Net Performance Score (NPS)](https://www.rohde-schwarz.com/us/knowledge-center/videos/interview-nps-the-single-qoe-centric-network-score-from-rs_251220-621634.html) we used to represented the mobile network and network quality as a **single metric that characterizes the overall performance**. So as a network provider, I won't need to check every number on each phone call. I can aggregate it up to an NPS score as part of a region, commune, or country. This is a common approach in network profiling, but in data we don't have that luxury yet. Maybe we should?
>
> Why am I saying all of this? Because to be able to massively ingest context, and documentation autonomously, without checking it, we need a measure. And that needs an open standard on data quality. Measures such as `last updated date, creator (agent/human), ratings, etc.` would be needed to condense a full score. If we have this, we can add a load more context, faster.
>
> But right now, we do not have it, unless we use a [data catalog](https://www.ssp.sh/brain/open-table-format-catalogs), where catalogs scan metadata and humans rate data sets etc. But with faster agents and everything autonomous, this model needs some improvements.
>
> ## And what the Heck is an Ontology?
>
> Another term I see more frequently used and talked about, is an Ontology. I include it here, because if we talk about context, and the newly created context layer, I believe it's a good vehicle to explain the world for agents that need to understand not only the data our business holds, but also need to link it to common sense and how the world functions in real life. And that is what ontologies are really good at.
>
> ### Ontology: Broader Context to Explain World Models
>
> These are not something new. I used them back in 2017, when Airbus (where I was working at the time) [announced Skywise](https://www.airbus.com/en/newsroom/press-releases/2017-06-airbus-launches-skywise-aviations-open-data-platform), an open data platform for airplane parts. And do you know what it was built on? On [Palantir Foundry](https://www.palantir.com/docs/foundry), a data lake with a deep foundation in Ontologies.
>
> If we go to Wikipedia, it [defines](https://en.wikipedia.org/wiki/Ontology_(information_science)) an Ontology as follows:
>
> > In information science, an ontology **encompasses a representation, formal naming, and definitions** of the **categories, properties, and relations** between the **concepts, data, or entities** that pertain to one, many, or all domains of discourse.
>
> In simpler words, usually existing objects in the world can be described through an ontology. For example, an ontology is seen as the whole below:
>
> ![[motherduck-context-layer-001.webp]]
> *Source: [Core concepts for Palantir - Docs](https://www.palantir.com/docs/foundry/ontology/core-concepts#ontology)*
>
> Palantir [defines](https://www.palantir.com/docs/foundry/ontology/core-concepts#ontology) it inside their tool called Foundry as:
>
> > Ontology is a categorization of the world, **it's the digital twin of an organization**, integrating the organization's data and models into a coherent whole by mapping them to object types, properties, link types, and action types.
>
> The `Airport, Flight, Delay, Airline, Aircraft` each result in an object type, which is the **schema definition** of a real-world entity or event, not an ontology in itself.
>
> Arrows (Departed From, Operated By, Hub For, etc.) are **link types** and the schema definition of a relationship between two object types, similar to how we model connections in the relational model in an Entity Relationship Diagram (ERD).
>
> Things like `Duration, Founding Date, Range` are **properties**, which are the schema definition of a characteristic of a real-world entity or event. So the ontology is the whole schema (all five tables/datasets plus how they join together).
>
> **[Tip — Onto goes back to the Greek and 4th century BC]**
> If you want to get philosophical, the term onto describes efforts to understand what it means for something to exist, constructed from the Greek root "ontos," meaning being, and the idea originated with Aristotle in his work on metaphysics.
>
> But in terms of computer/information science, the term was first used in information systems in 1967 by Mealy, though the more significant early work came from McCarthy and Hayes in 1969, who argued that intelligent machines need metaphysically adequate representations of the world. Hayes' 1978 paper "Naive Physics I: Ontology for Liquids" appears to be the first computer science paper with "ontology" in the title. Find more in [What is an Ontology? (2018)](https://arxiv.org/pdf/1810.09171)
>
> ### Compare Semantic with Context Layer, and Knowledge Graph and Ontologies
>
> Others such as Ananth Packkildurai [share](https://www.dataengineeringweekly.com/p/an-ontology-for-ai-agents-is-a-system) it combined into a simple diagram where taxonomy and knowledge graph get added to showcase the technical semantic architecture leading to the context graph:
>
> ![[motherduck-context-layer-002.webp]]
> Source: [What an Ontology for AI Agents Actually Needs](https://www.dataengineeringweekly.com/p/an-ontology-for-ai-agents-is-a-system)
>
> So another term, "**Knowledge Graph**", simply explained, means information stored in a graph database and visualized as a graph structure, prompting the term knowledge "graph". But it helps us see the semantics as the start (the definitions -> can be independent of database or tooling if you have an external layer), and then external elements of the world outside of my company's business are described as an ontology, what Ananth calls the "schema layer," since it defines the classes, properties, and rules everything else has to conform to, which, combined with a graph (the "instance layer," holding the actual data), leads to the "context graph".
>
> **[Note — Other Opinions]**
> Jessica Talisman [illustrates and says](https://www.linkedin.com/posts/jmtalisman_context-is-still-a-nebulous-concept-that-share-7493443496671010816-rCJC/?utm_source=share&utm_medium=member_desktop&rcm=ACoAABkA2pgBYM4xDO0z2ChYuxFhBfu4h7jp4Lo) it well too, that semantics is an umbrella for the vocabulary, metadata and ontology. She elaborates in great detail in [Ontologies, Context Graphs, and Semantic Layers](https://contextandchaos.substack.com/p/ontologies-context-graphs-and-semantic).
>
> Mehdi calls the difference between a [semantic and context](https://motherduckdb.github.io/analytics-agent-duckdb-workshop/context/) (page 5): "'Semantic' is just a fancy word meaning there's a **specific meaning** for certain concepts and metrics in a company. Some are easy and stable; others live in people's heads and shift over time." And says that the good news is that **LLMs are very good at pulling data from many sources**, so we can use the full semantic context and not just a separate layer.
>
> ## What's the Take Away? Graphs and AI Agent Integration?
>
> I know that was a lot, with a lot of definitions and potentially new terms brought together.
>
> What got clearer to me, is that data **gets more interconnected**. When you follow the data news, as I do, many call for the context layer and connect it **with a graph**, because the graph is the best representation of complex interconnected knowledge, internal, external or models for describing the world, as the airport/flight example above shows.
>
> Hamilton, Till, Jacob and Garret though make a counter argument in [Context belongs in the warehouse](https://motherduck.com/blog/context-belongs-in-the-warehouse/), saying not to overcomplicate with sophisticated retrievals (embeddings, graphs). They showcase MotherDuck's new Guides work by having the agent browse a topic tree of curated guide titles and pick the right one without any keyword or vector search. This suggests that sometimes a simple index is enough.
>
> **[Example — How do Guides work and simplify my life?]**
> Check out [Using MotherDuck's Guides to improve AI query accuracy and personalize agents](https://motherduck.com/docs/key-tasks/guides/) to help you with that, and learn more about how it works.
>
> ### Sophistication Is a Cost, Not a Default
>
> Put those two paragraphs side by side and you get a contradiction: interconnected knowledge argues for a graph, and MotherDuck's own Guides argue that a flat index of titles beats embeddings and graph traversal. Both are right, they're just answering different questions.
>
> Sophistication is a cost you should only pay if the outcome is worth much more than that cost. The airport/flight ontology earns a graph because the domain genuinely is cross-domain and interconnected: an aircraft links to a flight, a flight to an airline, an airline to a hub, and the value is in traversing those relationships. MotherDuck's guide index doesn't need that, because the actual bottleneck isn't relating entities to each other, it's picking the one right document out of a hundred, and an agent does that more reliably by scanning titles than by ranking similarity scores. A graph would have added retrieval overhead and, per MotherDuck's own evals, picked worse.
>
> The same lens explains why a semantic layer earns a deterministic, machine-callable interface (SQL, REST, GraphQL) that a context layer doesn't get. It comes down to who's actually asking, and what it costs to be wrong. A semantic layer's numbers get called directly by a dashboard or a scheduled job, with no human and no LLM in the loop, so it has to be right every time, and that guarantee is worth the cost of building and maintaining it. A context layer feeds an agent that's still reasoning, still capable of misreading a guide or picking the wrong table, so there's still a checkpoint between the context and the number that ships. A context layer doesn't carry that weight, at least not yet: it depends entirely on your setup and your data governance. As more agent-mediated work goes straight to a dashboard with nobody reviewing it, the case for giving context layers their own consistency guarantees only gets stronger.
>
> So before reaching for a graph, an ontology, or a deterministic interface, ask what the retrieval or consistency problem actually is, who consumes the result, and what a wrong answer costs. Match the tool to that answer, not to what's trendy this quarter.
>
> ### The Way Forward: Tools and AI Agent Integration
>
> You might also ask, if agents like Fable are one-shotting work that used to take many iterations, what's actually left for humans to do?
>
> There's already a handful of context layer tool that build a Context Layer. I have written about [ktx](https://github.com/Kaelio/ktx), and am checking out [OmniGraph](https://github.com/ModernRelay/omnigraph), but there are many more with [Nao](https://github.com/getnao/nao) or more data catalog flavored [Marmot](https://github.com/marmotdata/marmot), [OpenMetadata](https://github.com/open-metadata/OpenMetadata) or [DataHub](https://github.com/datahub-project/datahub) just to name a few, and all working closely with AI agents to ease governance and management.
>
> Another integration is through the ORM (Object-Relational Mapping). I once read: "an ORM to a database is what a semantic layer is to a domain knowledge", so maybe we just need ORMs for agents?
>
> So what's the way forward then?
>
> ### AI Agents Read the Business Knowledge
>
> When we give an AI agent the business knowledge it needs through a context layer, or semantics with SQL queries and joins, it can query a warehouse correctly.
>
> An agent can read a table's schema, but the schema won't reveal the inside knowledge of how "revenue" is defined, which tables join to which, or which columns are unreliable. A semantic layer and a context layer are two different answers to that gap and are not mutually exclusive.
>
> We can see a real-world illustration of how the two layers of semantic and context can cooperate in Anthropic's [self-service data analytics with Claude](https://claude.com/blog/how-anthropic-enables-self-service-data-analytics-with-claude). They write about how their agents are using skill instructions to leverage the semantic layer first for self-service data analytics. The skill file itself states plainly that the semantic layer is the mandatory default path for every data question, with raw SQL as the fallback used only once the semantic-layer path is shown not to cover the ask. MotherDuck Guides play a related role as curated knowledge for the agent, though MotherDuck ships the context layer first and treats a dedicated semantic layer as a separate, later question, so the routing is not the same.
>
> ## In the end?
>
> So, back to where I started: if a model like Fable can one-shot in minutes what used to take me many rounds with Opus, what's actually left for us in the data work context? Looking back at the initial semantic layer, the evolution to a context layer, and combining it with an ontology, these are not really competing tools or methodologies. They are all interconnected and work in a net. **The definitions for the metrics in SQL/YAML in a semantic layer, ingestion pipeline of unstructured text and keeping it up-to-date with context layers, and making sense of the world for the agents with ontologies**.
>
> And most of what we have evolved to, is mostly due to the sheer power and advancement of agentic work, that agents can autonomously keep up with metadata and data we want to convert into context. But at the same time, it always **defaults back to the fundamental question of what my data governance** looks like, and what my overall data architecture is to achieve the goal at hand.
>
> And as a16z's three-part context layer implied, as well as Anthropic's semantic-layer-first skill: **someone still has to decide what's true**. We still need the human in the loop, especially with data. And that's the whole crux of Amdahls Law, as long as a person or a team needs to decide or gets involved, we lose the overall speed, but I think that's the price we still pay, if we want good, verified data quality in our enterprise data warehouse or analytics platforms.
>
> And as I raised with the metric to measure data quality, which we do not have, it confirms another true statement, that the hard part in data is never building semantics or the context once, it's how and who keeps it *correct* and *maintained*. That's the answer to my opening question: not a tool, but judgment, the same judgment behind the "human refinement" step a16z pointed to, and the same one behind deciding whether a problem is worth a graph or is better served by a flat index.
>
> Large language models are getting exceptionally good at writing the SQL with the right context, and at maintaining just that. But most often, deciding what "revenue" means still requires deep company-specific knowledge (for now).
>
> ---
>
> Listen more on these very related discussed topics with the already teased Jacob's podcast about [Are Semantic Layers Really Necessary?](https://analyticshour.io/2026/06/23/300-are-semantic-layers-really-necessary/). Or check out the great example of how AI agents can help with creating a semantic layer using the open source semantic layer Malloy at [AI Writes the Semantic Layer \| MotherDuck](https://motherduck.com/blog/AI-writes-the-semanrites-the-semantic-layer/).
>
> [^1]: They call it a "modern" context layer. I'm not sure we already went through the evolution of context layers, so calling it modern does not add much value. To me it's the first version of a context layer.
