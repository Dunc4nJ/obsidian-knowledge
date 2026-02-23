---
created: 2026-02-01
description: OpenAI built a bespoke internal data agent that reasons over 600PB across 70k datasets by stacking six context layers - metadata, query history, code-level definitions, institutional docs, persistent memory, and runtime inspection - rather than relying on model intelligence alone
source: https://openai.com/index/inside-our-in-house-data-agent/
type: framework
---

## Key Takeaways

The central architectural insight is that model capability is necessary but insufficient for reliable data analysis at scale. OpenAI's agent organizes context into six explicit layers - schema metadata, historical query inference, Codex-derived code-level table definitions, institutional knowledge from Slack/Docs/Notion, a persistent memory system, and live runtime queries - each compensating for blind spots in the others. This mirrors the principle in [[four memory layers serve different knowledge types]] that different knowledge types require different storage and retrieval strategies; OpenAI arrived at the same conclusion for data context specifically.

The code-level definition layer is the most novel contribution. By using Codex to crawl the pipelines that produce each table, the agent understands not just what columns exist but how data is derived, what freshness guarantees apply, and what business assumptions are baked in. This is the kind of context that never surfaces in schemas or query logs alone, and it solves the table disambiguation problem that plagues large data platforms (3.5k users across 70k datasets where many tables look superficially identical).

The memory layer operates as a self-improving correction system: when the agent receives a correction or discovers a non-obvious filter (like matching against a specific experiment gate string), it prompts the user to save that learning. Future queries start from a more accurate baseline. This resembles [[Obsidian as Agentic Memory]] where progressive disclosure through structured layers prevents agents from drowning in raw context. Both systems force selective retrieval rather than dumping everything into the prompt.

On tooling, the team found that exposing the full tool set created confusion from overlapping functionality. Consolidating and restricting tool calls improved reliability - a practical lesson that contradicts the instinct to give agents maximum flexibility. Similarly, highly prescriptive prompting degraded results; shifting to higher-level guidance and letting GPT-5's reasoning choose execution paths produced better outcomes. This tension between structure and autonomy connects to [[progressive disclosure filters force agent selectivity over what enters context]] where the 4-layer progressive disclosure pattern balances giving agents enough context without overwhelming their decision-making.

The eval system deserves attention: curated question-answer pairs with manually authored "golden" SQL, compared not by string matching but by feeding both generated and expected SQL results into an Evals grader that scores correctness while allowing acceptable variation. These run continuously during development as regression canaries - essentially unit tests for analytical reasoning. This is a concrete implementation pattern for anyone building agents that produce structured outputs.

Security follows a pass-through model where the agent inherits existing data permissions rather than maintaining its own access layer. When access is missing, it flags the gap or falls back to authorized alternatives. Combined with exposed reasoning (assumptions, execution steps, links to raw results), this builds trust through transparency rather than restricting capability.

The separation of cheap filtering from expensive LLM analysis echoes the architecture in [[background agents shift alerting from reactive keyword matching to proactive semantic discovery|Fintool's background alerting system]] - both avoid running AI on everything by using structured filters first, reserving LLM reasoning for content that passes initial gates. Both also demonstrate that enterprise agents succeed through context architecture rather than model capability alone.

## External Resources

- [Codex](https://openai.com/index/introducing-codex/) - OpenAI's cloud software engineering agent, used here to derive code-level table definitions from pipeline code
- [GPT-5](https://openai.com/index/introducing-gpt-5-2/) - the flagship model powering the agent's reasoning and query generation
- [Evals API](https://platform.openai.com/docs/guides/evals) - OpenAI's evaluation framework used for continuous regression testing of agent outputs
- [Embeddings API](https://platform.openai.com/docs/guides/embeddings) - used to convert enriched table context into embeddings for RAG retrieval
- [Retrieval-Augmented Generation (RAG)](https://en.wikipedia.org/wiki/Retrieval-augmented_generation) - the retrieval pattern used to pull relevant context at query time

## Original Content

> [!quote]- Source Material
> Data powers how systems learn, products evolve, and how companies make choices. But getting answers quickly, correctly, and with the right context is often harder than it should be. To make this easier as OpenAI scales, we built **our own bespoke in-house AI data agent** that explores and reasons over our own platform**.**
>
> Our agent is a custom internal-only tool (not an external offering), built specifically around OpenAI's data, permissions, and workflows. We're showing how we built and use it to help surface examples of the real, impactful ways AI can support day-to-day work across our teams. The OpenAI tools we used to build and run it ([Codex](https://openai.com/index/introducing-codex/), [our GPT-5 flagship model](https://openai.com/index/introducing-gpt-5-2/), the [Evals API⁠(opens in a new window)](https://platform.openai.com/docs/guides/evals), and the [Embeddings API⁠(opens in a new window)](https://platform.openai.com/docs/guides/embeddings)) are the same tools we make available to developers everywhere.
>
> Our data agent lets employees go from question to insight in minutes, not days. This lowers the bar to pulling data and nuanced analysis across all functions, not just by our data team. Today, teams across Engineering, Data Science, Go-To-Market, Finance, and Research at OpenAI lean on the agent to answer **high-impact data questions.** For example, it can help answer how to evaluate launches and understand business health, all through the intuitive format of natural language. The agent combines Codex-powered table-level knowledge with product and organizational context. Its continuously learning memory system means it also improves with every turn.
>
> In this post, we'll break down why we needed a bespoke AI data agent, what makes its code-enriched data context and self-learning so useful, and lessons we learned along the way.
>
> ## Why we needed a custom tool
>
> OpenAI's data platform serves more than **3.5k internal users** working across Engineering, Product, and Research, spanning over **600 petabytes** of data across **70k datasets.** At that size, simply finding the right table can be one of the most time-consuming parts of doing analysis.
>
> As one internal user put it:
>
> *"We have a lot of tables that are fairly similar, and I spend tons of time trying to figure out how they're different and which to use. Some include logged-out users, some don't. Some have overlapping fields; it's hard to tell what is what."*
>
> Even with the correct tables selected, producing correct results can be challenging. Analysts must reason about table data and table relationships to ensure transformations and filters are applied correctly. Common failure modes-many-to-many joins, filter pushdown errors, and unhandled nulls-can silently invalidate results. At OpenAI's scale, analysts should not have to sink time into debugging SQL semantics or query performance: their focus should be on defining metrics, validating assumptions, and making data-driven decisions.
>
> ## How it works
>
> *Agent workflow overview*
> ![[openai-dataagent-001-how-it-works.svg]]
>
> Let's walk through what our agent is, how it curates context, and how it keeps self-improving.
>
> Users can ask complex, open-ended questions which would typically require multiple rounds of manual exploration. Take this example prompt, which uses a test data set: *"For NYC taxi trips, which pickup-to-dropoff ZIP pairs are the most unreliable, with the largest gap between typical and worst-case travel times, and when does that variability occur?"*
>
> *NYC taxi pickup-dropoff analysis example output*
> ![[openai-dataagent-006-nyc-pickup-dropoff.png]]
>
> **The agent handles the analysis end-to-end**, from understanding the question to exploring the data, running queries, and synthesizing findings.
>
> One of the agent's superpowers is how it reasons through problems. Rather than following a fixed script, the agent evaluates its own progress. If an intermediate result looks wrong (e.g., if it has zero rows due to an incorrect join or filter), the agent investigates what went wrong, adjusts its approach, and tries again. Throughout this process, it retains full context, and carries learnings forward between steps. This **closed-loop, self-learning process** shifts iteration from the user into the agent itself, enabling faster results and consistently higher-quality analyses than manual workflows.
>
> The agent covers the full analytics workflow: discovering data, running SQL, and publishing notebooks and reports. It understands internal company knowledge, can web search for external information, and improves over time through learned usage and memory.
>
> ## Context is everything
>
> High-quality answers depend on **rich, accurate context**. Without context, even strong models can produce wrong results, such as vastly misestimating user counts or misinterpreting internal terminology.
>
> *Before: agent without memory, unable to query effectively*
> ![[openai-dataagent-007-queries-before.png]]
>
> *After: agent's memory enables faster queries by locating the correct tables*
> ![[openai-dataagent-008-queries-after.png]]
>
> To avoid these failure modes, the agent is built around **multiple layers of context that ground it in OpenAI's data and institutional knowledge.**
>
> *The six layers of context*
> ![[openai-dataagent-002-layers-of-context.svg]]
>
> -   **Metadata grounding:** The agent relies on schema metadata (column names and data types) to inform SQL writing and uses table lineage (e.g., upstream and downstream table relationships) to provide context on how different tables relate.
> -   **Query inference:** Ingesting historical queries helps the agent understand how to write its own queries and which tables are typically joined together.
>
> -   **Curated descriptions** of tables and columns provided by domain experts, capturing intent, semantics, business meaning, and known caveats that are not easily inferred from schemas or past queries.
>
> *Codex-enriched knowledge pipeline*
> ![[openai-dataagent-003-codex-enriched-pipeline.svg]]
>
> Metadata alone isn't enough. To really tell tables apart, you need to understand how they were created and where they originate.
>
> -   By deriving a code-level definition of a table, the agent builds a deeper understanding of what the data actually contains.
>     -   Nuances on what is stored in the table and how it is derived from an analytics event provides extra information. For example, it can give context on the uniqueness of values, how often the table data is updated, the scope of the data (e.g., if the table excludes certain fields, it has this level of granularity), etc.
> -   This provides enhanced usage context by showing how the table is used beyond SQL in Spark, Python, and other data systems.
> -   This means that the agent can distinguish between tables that look similar but differ in critical ways. For example, it can tell whether a table only includes first-party ChatGPT traffic. This context is also refreshed automatically, so it stays up to date without manual maintenance.
>
> -   The agent can access Slack, Google Docs, and Notion, which capture critical company context such as launches, reliability incidents, internal codenames and tools, and the canonical definitions and computation logic for key metrics.
> -   These documents are ingested, embedded, and stored with metadata and permissions. A retrieval service handles access control and caching at runtime, enabling the agent to efficiently and safely pull in this information.
>
> -   When the agent is given corrections or discovers nuances about certain data questions, it's able to save these learnings for next time, allowing it to constantly improve with its users.
>     -   As a result, future answers begin from a more accurate baseline rather than repeatedly encountering the same issues.
>     -   The goal of memory is to retain and reuse non-obvious corrections, filters, and constraints that are critical for data correctness but difficult to infer from the other layers alone.
>     -   For example, in one case, the agent didn't know how to filter for a particular analytics experiment (it relied on matching against a specific string defined in an experiment gate). Memory was crucially important here to ensure it was able to filter correctly, instead of fuzzily trying to string match.
> -   When you give the agent a correction or when it finds a learning from your conversation, it will prompt you to save that memory for next time.
>     -   Memories can also be manually created and edited by users.
>     -   Memories are scoped at the global and personal level, and the agent's tooling makes it easy to edit them.
>
> #### Layer #6: Runtime Context
>
> -   When no prior context exists for a table or when existing information is stale, the agent can issue live queries to the data warehouse to inspect and query the table directly. This allows it to validate schemas, understand the data in real-time, and respond accordingly.
> -   The agent is also able to talk to other Data Platform systems (metadata service, Airflow, Spark) as needed to get broader data context that exists outside the warehouse.
>
> *Context retrieval architecture*
> ![[openai-dataagent-004-context-retrieval.svg]]
>
> We run a daily offline pipeline that aggregates table usage, human annotations, and Codex-derived enrichment into a single, normalized representation. This enriched context is then converted into embeddings using the [OpenAI embeddings API⁠(opens in a new window)](https://platform.openai.com/docs/api-reference/embeddings) and stored for retrieval. At query time, the agent pulls only the most relevant embedded context via [retrieval-augmented generation⁠(opens in a new window)](https://en.wikipedia.org/wiki/Retrieval-augmented_generation) (RAG) instead of scanning raw metadata or logs. This makes table understanding fast and scalable, even across tens of thousands of tables, while keeping runtime latency predictable and low. Runtime queries are issued to our data warehouse live as needed.
>
> Together, these layers ensure the agent's reasoning is grounded in OpenAI's data, code, and institutional knowledge, dramatically reducing errors and improving answer quality.
>
> ## Built to think and work like a teammate
>
> One-shot answers work when the problem is clear, but most questions aren't. More often, arriving at the correct result requires back-and-forth refinement and some course correction.
>
> The agent is built to behave like a teammate you can reason with. It's a conversational, always-on and handles both quick answers and iterative exploration.
>
> It carries over complete context across turns, so users can ask follow-up questions, adjust their intent, or change direction without restating everything. If the agent starts heading down the wrong path, users can interrupt mid-analysis and redirect it, just like working with a human collaborator who listens instead of plowing ahead.
>
> When instructions are unclear or incomplete, the agent proactively asks clarifying questions. If no response is provided, it applies sensible defaults to make progress. For example, if a user asks about business growth with no date range specified, it may assume the last seven or 30 days. These priors allow it to stay responsive and non-blocking while still converging on the right outcome.
>
> The result is an agent that works well both when you know **exactly what you want** (e.g., "Tell me about this table") and **just as strong when you're exploring** (e.g., "I'm seeing a dip here, can we break this down by customer type and timeframe?").
>
> After rollout, we observed that users frequently ran the same analyses for routine repetitive work. To expedite this, the agent's workflows package recurring analyses into reusable instruction sets. Examples include workflows for weekly business reports and table validations. By encoding context and best practices once, workflows streamline repeat analyses and ensure consistent results across users.
>
> ## Moving fast without breaking trust
>
> Building an always-on, evolving agent means quality can drift just as easily as it can improve. Without a tight feedback loop, regressions are inevitable and invisible. The only way to scale capability without breaking trust is through systematic evaluation.
>
> *Eval pipeline architecture*
> ![[openai-dataagent-005-eval-pipeline.svg]]
>
> Its Evals are built on curated sets of question-answer pairs. Each question targets an important metric or analytical pattern we care deeply about getting right, paired with a manually authored "golden" SQL query that produces the expected result. For each eval, we send the natural language question to its query-generation endpoint, execute the generated SQL, and compare the output against the result of the expected SQL.
>
> Evaluation doesn't rely on naive string matching. Generated SQL can differ syntactically while still being correct, and result sets may include extra columns that don't materially affect the answer. To account for this, we compare both the SQL and the resulting data, and feed these signals into OpenAI's Evals grader. The grader produces a final score along with an explanation, capturing both correctness and acceptable variation.
>
> These evals are like unit tests that run continuously during development to identify regressions as canaries in production; this allows us to catch issues early and confidently iterate as the agent's capabilities expand.
>
> ## Agent security
>
> Our agent plugs directly into OpenAI's existing security and access-control model. It operates purely as an interface layer, inheriting and enforcing the same permissions and guardrails that govern OpenAI's data.
>
> **All of the agent's access is strictly** **pass-through**, meaning users can only query tables they already have permission to access. When access is missing, it flags this or falls back to alternative datasets the user is authorized to use.
>
> Finally, it's built for transparency. Like any system, it can make mistakes. It **exposes its reasoning process** by summarizing assumptions and execution steps alongside each answer. When queries are executed, it links directly to the underlying results, allowing users to inspect raw data and verify every step of the analysis.
>
> ## Lessons learned
>
> Building our agent from scratch surfaced practical lessons about how agents behave, where they struggle, and what actually makes them reliable at scale.
>
> Early on, we exposed our full tool set to the agent, and quickly ran into problems with overlapping functionality. While this redundancy can be helpful for specific custom cases and is more obvious to a human when manually invoking, it's confusing to agents. To reduce ambiguity and improve reliability, we restricted and consolidated certain tool calls.
>
> We also discovered that highly prescriptive prompting degraded results. While many questions share a general analytical shape, the details vary enough that rigid instructions often pushed the agent down incorrect paths. By shifting to higher-level guidance and relying on GPT-5's reasoning to choose the appropriate execution path, the agent became more robust and produced better results.
>
> Schemas and query history describe a table's shape and usage, but its true meaning lives in the code that produces it. Pipeline logic captures assumptions, freshness guarantees, and business intent that never surface in SQL or metadata. By crawling the codebase with Codex, our agent understands how datasets are actually constructed and is able to better reason about what each table actually contains. It can answer "what's in here" and "when can I use it" far more accurately than from warehouse signals alone.
>
> ## Same vision, new tools
>
> We're constantly working to improve our agent by increasing its ability to handle ambiguous questions, improving its reliability and accuracy with stronger validations, and integrating it more deeply into workflows. We believe it should blend naturally into how people already work, instead of functioning like a separate tool.
>
> While our tooling will keep benefiting from underlying improvements in agent reasoning, validation, and self-correction, our team's mission remains the same: seamlessly deliver fast, trustworthy data analysis across OpenAI's data ecosystem.
>
> [Original page](https://openai.com/index/inside-our-in-house-data-agent/)

