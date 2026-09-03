---
created: 2026-09-03
description: Josh Rosen's X Article reads the AI data warehouse as a leading indicator for AI architecture generally — seven patterns emerging as Snowflake, Databricks, ClickHouse, BigQuery and MotherDuck retrofit models and agents into mature systems that predate LLMs. Inference becomes a database operator with its own cost model in the query optimizer; transformations start inferring facts rather than reshaping them; the semantic layer becomes machine-readable infrastructure for agents; agent placement (in-platform vs. MCP tool) becomes an architectural decision; the warehouse becomes an execution environment for agent-written code; agent traffic becomes a distinct workload class; and AI-generated data needs lineage that records model, prompt, and transformation version. Captured with Seth Rosen's framing quote-tweet and the author's own deflationary reply on what Cortex and Genie actually are.
source: https://x.com/JoshARosen/status/2095488762532745712
author: Josh Rosen
type: synthesis
via: https://x.com/sethrosen/status/2095498622791999928
tags: [data-agents, semantic-layer, data-warehouse, snowflake, databricks, clickhouse, motherduck, bigquery, mcp, text-to-sql, lineage, agent-workloads, architecture]
---

## Key Takeaways

- **The framing is the actual contribution: mature systems can't rebuild around AI, so they have to solve AI architecture under constraint — which is what makes them a leading indicator.** Seth Rosen's quote-tweet is the sharper compression: these platforms "are adding models and agents to mature systems that were never designed around LLMs / so they're being forced to solve many of the architectural problems the rest of software has as well but they may be solving them first." Josh's version is that warehouses "already sit inside mature enterprise systems with existing data, governance, permissions, infrastructure, and users," making the data stack "an unusually important testing ground for what production AI actually looks like inside established companies." The reason this beats generic vendor-watching: a greenfield AI product gets to define its own boundaries, while a warehouse has to route AI *through* boundaries that already exist and already have owners — query execution, transformations, compute, semantics, governance, lineage. Read it as the practitioner-side companion to [[Berkeley's EPIC Data Lab argues near-free intelligence makes agents the dominant data-systems workload, needing data systems for, of, and by agents|Berkeley EPIC's "for, of, and by agents" agenda]], which derives the same restructuring from first principles. Caveat up front: this is a landscape synthesis, not research — no benchmarks, no measurements, and the pattern list is assembled from vendor announcements.

- **Inference becomes a database operator — and the tell is the optimizer, not the function call.** Calling an LLM from SQL is the boring part; every major platform now supports filtering, classification, extraction, generation, scoring, and aggregation inside queries. The structural change Josh flags is Snowflake introducing **AI-aware query optimization for AI operators**, because "LLM calls have very different costs from traditional predicates, so the optimizer has to decide where those semantic operations belong in a query plan." At that point the model is a cost node inside a plan rather than an external service you call — the same boundary collapse [[RLMs inline intelligence into data pipelines by giving LLMs symbolic access to DataFrames in a persistent REPL|RLMs perform on DataFrames]], and the thing [[semantic SQL parsing makes data transformations programmatically validatable which is what data agents need underneath them|semantic SQL parsing]] would need to extend to in order to keep such plans checkable. A practitioner reply corroborates the cheap end: Luke Kranz reports using MotherDuck's `prompt()` "a ton," throwing Nano at categorization/embedding with row context inside data pipelines — per-row inference is already economical at small-model prices, which is the [[Prime Intellect duckdb-qa - RL reward shaping for SQL tool use|cost curve]] that makes the operator viable at all. Along with lesson 2, this is the part of the article least covered elsewhere in the vault.

- **Transformations that infer facts create a new epistemic category in the warehouse — and lesson 7 is the bill for lesson 2.** The genuinely new capability: "This unlocks a whole new set of data sources where the data can only be found through inference" — a contract becomes a collection of obligations, a sales call becomes a set of objections. Josh immediately notes the consequence: some columns come from source systems, some are deterministically calculated, and "others may now represent model judgments produced during the pipeline. Downstream, using SQL, they all look like data." His seventh lesson is the invoice for the second — "it will become more difficult to distinguish a fact that came from a source system from a judgment that originally came from an LLM," so lineage must now carry *which model, which prompt, which transformation version*. The data stack is unusually well-equipped here, having already built lineage systems — [[semantic SQL parsing makes data transformations programmatically validatable which is what data agents need underneath them|column-level lineage from SQL ASTs]] and [[dltHub Pro delivers a context graph for data engineering because agent-readable schemas and traces outcompete chat-box overlays when 91% of pipelines are agent-written|dltHub's agent-readable schemas and traces]] are the deterministic counterpart — and the requirement generalizes to any system that persists model output beside ground truth, which is exactly the problem [[every representation is an IR - the append-only semantic ledger is memory and vectors, graphs, and context windows are views compiled from it|the append-only ledger of typed, provenanced facts]] attacks on the agent-memory side.

- **The semantic-layer claim is the one the vault actively disputes — and the disagreement is about authoring, not necessity.** "The schema is not the business model" is right and well put: knowing a column is called `revenue` doesn't tell an agent how the company defines revenue, which table is authoritative, or which filters normally apply. But the conclusion — that Snowflake semantic views, Databricks Genie + Unity Catalog, and Fabric's Data Agent turn the semantic layer into agent infrastructure — runs against [[context management replaces the semantic layer for data agents because it adapts from corrections|Jamie Quint's argument that the static semantic layer is dead]], replaced by context computed on demand from the dbt DAG plus corrections accumulating as retrievable "quirks." Both sides agree agents need a machine-readable model of what the data *means*; they split on whether it is authored up front or derived from usage, and the vault has evidence for each. For derived: [[Anthropic's self-service analytics stack achieves 95% accuracy by treating the bottleneck as context and entity mapping not SQL generation|Anthropic's 95% stack]] (pairwise skills, not raw SQL retrieval, drove 21%→95%) and [[the hard problem in text-to-SQL is discovery not generation and hybrid search over existing metadata solves it|discovery-not-generation]]. For authored: [[DAB benchmark exposes frontier data agents at 38 percent pass at 1 with 85 percent of failures in planning or implementation|DAB measures PromptQL's semantic layer adding 7pp over ReAct]], [[LangChain's agent-first data stack scales self-service analytics 40x by making context explicit across dbt models, a semantic layer, workspace guides, and endorsements|LangChain keeps a semantic model alongside correction-driven context]], and [[Palantir Ontology gives enterprise agents a decision-centric substrate by surfacing data logic and action as tools governed by one security model|Palantir's Ontology]] is the most mature version of exactly what Josh describes. His own thread reply is the most useful thing he wrote and quietly concedes the deflationary read: asked what Cortex and Genie actually solve, he answers they "are basically natural language interfaces over semantic layers. A lot of the value comes from the semantic layer more so than the natural language translation of it," with the interesting part being proximity — "how close it's happening to your data and the native hooks into your data."

- **Agent placement and agent *execution* are two separable decisions, and MotherDuck Flights is the aggressive one.** Placement is the visible split: agents inside the platform ([[Databricks Genie pushes data agents past coding-agent baselines via specialized knowledge search, parallel thinking, and multi-LLM design|Genie]], Snowflake Cortex, ClickHouse Agents) versus agents outside with the warehouse exposed as an MCP tool (MotherDuck, Databricks, AWS Agent Toolkit) — and Josh expects both to coexist, a warehouse-native agent for analytics alongside Claude Code or an enterprise agent treating the platform as one tool among many. He treats this as a taste question; the vault has a measurement — [[data-eng-bench shows a data-native harness beats generic coding agents on dbt tasks at up to 3.9x lower cost with equal or better quality|Snowflake's own data-native harness beats Claude Code and Codex on dbt tasks at up to 3.9x lower cost]] — while [[Stripe's Kai is a coding agent for non-engineers - one engineer shipped it on Deep Agents in a week and federated skills carried it to 83 percent weekly adoption|Stripe deliberately kept Kai outside the warehouse]] and exposed the sandbox as a tool. The bigger move is lesson 5, where the warehouse stops being queryable and becomes *runnable*: MotherDuck's Flights runtime executes Python next to the data, so an external coding agent can inspect data over MCP, write an ingestion or transformation program, deploy it as a Flight, schedule it, and then query what its own program produces — collapsing warehouse, orchestrator, and application into one surface. That is the data-stack instance of [[code execution with MCP cuts tool token overhead 98 percent by presenting servers as filesystem APIs instead of upfront definitions|writing code against a data surface instead of calling tools over it]], and a shipping version of Berkeley's "systems *by* agents" axis.

- **"Agents are a new database workload" is the load-bearing claim, and the vault holds both the general form and the quantified version.** ClickHouse's argument as Josh relays it: analytical databases were shaped by their dominant consumers — dashboards, scheduled transformations, human analysts — and agents are simply a different consumer. One human request fans out into dozens of database operations as the agent inspects metadata, queries, examines results, hits errors, re-inspects the schema, retries, and compares alternatives in seconds, producing traffic that is "iterative, bursty, concurrent, and latency-sensitive." Vendor responses: low latency plus high concurrency (ClickHouse), and per-agent compute isolation (MotherDuck hypertenancy giving each user or agent its own DuckDB rather than shared compute) — the same isolation pressure that drove [[Kimi K2.6 chose TiDB because agent-native databases need constraint completeness over single-point optimality|Kimi to TiDB for hundreds of thousands of agent-minted tenants, 99% idle while 1% spikes]], and the specific case of [[databases are becoming the runtime layer for AI agents as application logic collapses into the data layer|application logic collapsing into the data layer as Human→App→DB becomes Human→Agent→DB]]. What the article stops short of is the *structure* inside that traffic, which [[Berkeley's EPIC Data Lab argues near-free intelligence makes agents the dominant data-systems workload, needing data systems for, of, and by agents|EPIC measures directly]]: on a text-to-SQL benchmark only **10–20% of an agent's sub-plans are distinct**, so 80–90% is duplicate work — and the redundancy *raises* task success. That reframes the response entirely: the win isn't only serving more queries faster, it's exploiting the speculation by reusing results across overlapping sub-plans and satisficing with approximate or streamed answers. Vendors are optimizing throughput for the workload; the research says the workload itself is compressible.

## External Resources

- Source article: [AI-Powered Data Warehouses: Architectural Lessons for Every AI Product](https://x.com/JoshARosen/status/2095488762532745712) — Josh Rosen, X Article, 3 Sep 2026
- Discovery / framing quote-tweet: [@sethrosen](https://x.com/sethrosen/status/2095498622791999928)
- Author's reply on what Cortex and Genie actually solve: [@JoshARosen](https://x.com/JoshARosen/status/2095540539735048531)
- Platforms discussed: [Snowflake](https://www.snowflake.com/en/) (Cortex Agents, semantic views) · [Databricks](https://www.databricks.com/) (Genie, Unity Catalog, Lakeflow, Agent Bricks, MLflow) · [ClickHouse](https://clickhouse.com/) (ClickHouse Agents) · [BigQuery](https://cloud.google.com/bigquery) · [MotherDuck](https://motherduck.com/) (`prompt()`, Flights, hypertenancy) · [Redshift](https://aws.amazon.com/redshift/) · Microsoft Fabric Data Agent · Agent Toolkit for AWS

## Original Content

> [!quote]- Full X Article + framing quote-tweet + author reply (Josh Rosen, "AI-Powered Data Warehouses: Architectural Lessons for Every AI Product", 3 Sep 2026)
> ### Seth Rosen's quote-tweet (@sethrosen, 3 Sep 2026)
>
> Snowflake, Databricks, ClickHouse, BigQuery, MotherDuck, etc are adding models and agents to mature systems that were never designed around LLMs
>
> so they’re being forced to solve many of the architectural problems the rest of software has as well but they may be solving them first
> >  QT @JoshARosen:
> > Article: AI-Powered Data Warehouses: Architectural Lessons for Every AI Product
> >  https://x.com/JoshARosen/status/2095488762532745712
>
> ---
>
> ### The article (@JoshARosen, 3 Sep 2026)
>
> *Article cover art: a data warehouse under renovation — the article's thesis in one drawing.*
> ![[josharosen-745712-001.jpg]]
>
> Article: AI-Powered Data Warehouses: Architectural Lessons for Every AI Product
>
> Some of the most interesting AI architecture work is happening inside the data stack. [Snowflake](https://www.snowflake.com/en/), [Databricks](https://www.databricks.com/), [ClickHouse](https://clickhouse.com/), [BigQuery](https://cloud.google.com/bigquery), [MotherDuck](https://motherduck.com/), [Redshift](https://aws.amazon.com/redshift/), and others are adding models and agents to systems that were built well before LLMs.
>
> That is forcing them to work through architectural problems that every AI builder is starting to face. Where should inference run? What should remain deterministic? How should model output be represented as data? Where should agents live? And how should all of this fit into existing systems without rebuilding the entire stack around AI?
>
> Data warehouses are a particularly interesting place to watch this happen. These are mature systems with well-established boundaries around query execution, transformations, compute, semantics, governance, and lineage. AI is now pushing on almost every one of those boundaries. The architectural patterns emerging here may offer an early look at how the rest of the software stack will adapt to AI.
>
> Here are seven architectural lessons we can take from how data platforms are adapting to AI.
>
> ## 1. Inference is turning into a database operator
>
> One of the clearest patterns is the movement of inference directly into the query layer. Snowflake, BigQuery, Databricks, and others now let developers use models for filtering, classification, extraction, generation, scoring, and aggregation inside data queries.
>
> Calling an LLM from a query is only the beginning. Once inference can be composed with ordinary database operations, the model is effectively participating in query execution. A query can scan rows, ask a model to determine what they mean, filter based on that judgment, and feed the result into a deterministic aggregation.
>
> Snowflake is already pushing this one step further by introducing AI-aware query optimization for AI operators. LLM calls have very different costs from traditional predicates, so the optimizer has to decide where those semantic operations belong in a query plan. At that point, inference is less like an external service you call and more like a new class of database operator.
>
> ## 2. Transformations can infer facts, not just reshape data
>
> The transformation layer inside warehouses is also changing. Traditional transformations parse, join, normalize, and aggregate using deterministic operations. LLM transformations can go further and actually infer something about the source and then materialize that inference as new data.
>
> This unlocks a whole new set of data sources where the data can only be found through inference. For example, a contract can turn into a collection of obligations. Or a sales call can turn into a set of objections.
>
> Databricks can combine document parsing and AI extraction inside data pipelines, while MotherDuck can apply inference across rows and return structured values that behave like ordinary warehouse data.
>
> Some columns come directly from source systems, some are deterministically calculated, and others may now represent model judgments produced during the pipeline. Downstream, using SQL, they all look like data.
>
> ## 3. The semantic layer is turning into infrastructure for agents
>
> Text-to-SQL exposed the fact that the schema is not the business model. Knowing that a column is called “revenue” doesn’t tell an agent how the company defines revenue, which table is authoritative, which filters normally apply, or how an analyst would answer a particular question.
>
> Snowflake’s semantic views provide Cortex Agents with that understanding by exposing metrics and relationships along with filters, instructions, and verified queries. Databricks Genie similarly combines Unity Catalog data with example queries, business semantics, and natural-language instructions. Microsoft Fabric’s Data Agent combines schema information with data-source instructions and example queries when generating answers.
>
> The semantic layer was largely built as an interface between warehouse data and analytics tools. Agents give it another job, providing additional context that teaches models how the organization expects its data to be used.
>
> This pattern has uses outside of data warehouses. Agents need access to the data, but they also need a machine-readable model of what that data means.
>
> ## 4. The location of the agent is an architectural decision
>
> The platforms are taking noticeably different approaches to where agents should live. Snowflake Cortex Agents, Databricks Genie Agents, and ClickHouse Agents put the agent inside the data platform, where it can sit close to the execution layer.
>
> Other platforms expect the agent to live outside the warehouse and expose the data platform as a tool. Databricks and MotherDuck provide MCP interfaces for external agents, while ClickHouse also supports MCP-based connectivity across its agent and data products. Similarly, Agent Toolkit for AWS allows external coding agents to interact with warehouse infrastructure.
>
> Several vendors are pursuing both approaches, and that may become ubiquitous eventually. A company might use a warehouse-native agent for analytics while also allowing Claude Code, Codex, or a higher-level enterprise agent to use the same data platform as one tool among many.
>
> ## 5. The warehouse is now an execution environment for agent work
>
> Giving an agent query access naturally leads to a larger question: can the agent create and operate the machinery that produces the data as well?
>
> MotherDuck provides a particularly clean example. Its Flights runtime executes Python next to the data on demand or on a schedule. An external coding agent can inspect warehouse data through MCP, write an ingestion or transformation program, deploy it as a Flight, schedule it, and then query what the program produces.
>
> Databricks approaches the same problem with a much broader platform. Unity Catalog, SQL, Python, Lakeflow, Model Serving, Agent Bricks, Apps, and MLflow increasingly provide one environment in which data pipelines and AI systems can be created, executed, governed, and evaluated.
>
> The old boundaries start to get blurry here. Previously, the warehouse held the data, an orchestration system managed pipelines, and applications lived somewhere else. Now, an agent that can inspect data, create transformations, and execute them crosses all three.
>
> ## 6. Agents are a new database workload
>
> ClickHouse has been particularly explicit about this. They believe agents behave differently from human users, and traditional analytical databases have been designed around humans, not agents.
>
> A human analyst might write a handful of queries while investigating a problem. An agent can inspect metadata, generate a query, execute it, examine the result, form another hypothesis, query another table, encounter an error, inspect the schema, retry, and compare several possibilities in seconds. One human request can therefore produce dozens of database operations.
>
> Agent traffic, on the other hand, can be highly iterative, bursty, concurrent, and latency-sensitive. ClickHouse has emphasized low query latency and high concurrency for this reason, while MotherDuck’s hypertenancy model gives individual users or agents isolated DuckDB compute rather than putting all of their activity onto the same shared compute.
>
> The modern analytical stack was heavily shaped by its dominant consumers: BI dashboards, scheduled transformations, data applications, and human analysts. With agents becoming another major consumer, databases need to be designed around their access patterns too.
>
> ## 7. AI-generated data needs its own lineage
>
> Once LLMs become part of the transformation layer, their outputs start showing up in the warehouse alongside every other kind of data. But AI-generated data has a different history from traditional derived data. For example, if a model decides that a customer interaction represents a billing complaint, we may also need to know which model made that decision, which prompt it received, and which version of the transformation was running at the time.
>
> The key problem is that it will become more difficult to distinguish a fact that came from a source system from a judgment that originally came from an LLM.
>
> Data platforms already have rich systems for tracking where data came from and how it was transformed. As inference moves into those transformations, that lineage may need to include the models and prompts that helped produce the data too.
>
> ## The data stack is a preview of AI architecture
>
> The patterns these data warehouse companies are adopting are likely to matter and be applicable well beyond the data warehouse.
>
> Data warehouses may be one of the first places where large companies figure out how to deploy AI-enabled software at real production scale. They already sit inside mature enterprise systems with existing data, governance, permissions, infrastructure, and users.
>
> That makes the data stack an unusually important testing ground for what production AI actually looks like inside established companies. The architectural patterns that emerge here could end up shaping how much of the enterprise software stack adopts AI.
>
> ---
>
> ### Author reply in the thread (@JoshARosen, 3 Sep 2026)
>
> > @DeepInsightLabs: Interesting topic. Can you elaborate more on what problems Snowflake's Cortex and Databrick's Genie really solve? I don't feel like it's as revolutionary as it sounds here based on my limited hands on experience.
>
> They are basically natural language interfaces over semantic layers. A lot of the value comes from the semantic layer more so than the natural language translation of it. I think a lot of what Snowflake and Databricks are doing is interesting mainly because of how close it’s happening to your data and the native hooks into your data.
>
> ---
>
> ### Other replies worth keeping
>
> @lkkrnz (Luke Kranz), replying to @sethrosen:
> great article. I've been using MD prompt() a ton recently, just throwing Nano at a categorization/embedding with the row context has been extremely helpful especially in data pipelines.
>
> @ethansteininger (ethan steininger), replying to @sethrosen:
> bingo - the models are integrated into everywhere, we build inference tightly coupled into our query language @mixpeek so you can reason about your unstructured data (video, image, audio, etc.)
>
