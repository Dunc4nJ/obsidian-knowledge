---
created: 2026-03-06
description: A practitioner's guide to building a modern AI data agent that replaces the static semantic layer with dynamic context management — a sub-agent reads dbt models at query time, corrections accumulate as durable quirks via hybrid retrieval, and self-scoring with targeted retries closes quality gaps.
source: https://x.com/jamiequint/status/2029705203457609785
type: framework
---

## Key Takeaways

The core thesis is that the semantic layer — the static, hand-maintained mapping between business concepts and SQL — is dead, replaced by dynamic context management. Instead of pre-defining every metric and dimension, a "context agent" reads the actual dbt transformation logic, traces `ref()` dependencies through the DAG, and builds a brief per-question: tables, columns, join paths, filters, dedup rules, caveats. This is the semantic layer computed on-demand rather than pre-computed. The shift was enabled by Opus 4.6 specifically outperforming Codex 5.3 on data analysis despite losing on coding tasks — model capability made the static layer unnecessary.

The continual learning loop is the most interesting part. When a user corrects the agent ("that metric needs this filter"), the correction gets extracted into a durable "quirk" — a short reusable piece of knowledge stored with embeddings for semantic retrieval. On each new question, hybrid retrieval (pgvector for similarity + pg_textsearch for BM25) pulls relevant quirks into context. This is [[OpenAI internal data agent succeeds through six layers of context not model capability alone|the same pattern OpenAI's internal data agent uses]] — institutional knowledge that used to live in one analyst's head gets externalized into a growing knowledge base. It's the semantic layer rebuilding itself from usage, which connects to the broader theme of [[agent continual learning impl|agent continual learning implementations]] where corrections compound over time.

The self-scoring mechanism is pragmatic: after every SQL query, evaluate on structural correctness (0.45), execution reliability (0.35), and context alignment (0.20, assessed by Haiku). From scores, build a deterministic "context-gap brief" — break the question into subquestions, check which have strong evidence, identify what's missing. Confidence is derived from coverage analysis, not vibes. The brief drives surgical retries: targeted prompts that include the original question, previous draft, weak signals, and specific directives per gap. Not "try again" but "resolve this entity, add this time constraint."

The retrieval tuning details are practical: collection weights to balance metrics vs quirks, a reviewed-item multiplier so human-approved knowledge ranks higher than agent-learned knowledge, reciprocal-rank fusion to blend vector and BM25 candidates, and a fixed context budget to avoid stuffing. This is production retrieval engineering, not toy RAG.

The business impact claim: reduced a planned hiring of 4-5 data analysts to 1, with Customer Success, Sales, and Product self-serving data in Slack. Built in ~3 weeks end-to-end including Slack/Notion integrations and admin dashboard.

## External Resources

- [Claude Agent SDK](https://docs.anthropic.com/en/docs/agents-and-tools/agent-sdk) — recommended framework for the agentic loop
- [DBT MetricFlow](https://docs.getdbt.com/docs/build/about-metricflow) — the semantic layer this approach replaces
- [pgvector](https://github.com/pgvector/pgvector) — used for vector similarity in the quirk store
- [OpenAI text-embedding-3-small](https://platform.openai.com/docs/guides/embeddings) — embedding model used for quirks

## Original Content

> @jamiequint — 2026-03-05
>
> **How to Build a Data Agent in 2026**
>
> I built the initial data stack at Notion in 2020 when the "Modern Data Stack" was first becoming a thing, and have spent some time over the last year consulting or helping friends' companies solve the next revolution, or the "AI Data Stack". Here is a how-to guide for building a modern AI data agent that can 5x+ your data team bandwidth. This particular build took me about 3 weeks end-to-end, including the third party integrations (Slack/Notion) and the internal admin dashboard to manage it.
>
> **From the Modern Data Stack to the AI Data Stack**
>
> The "modern data stack" was about making your data accessible (Fivetran/Airbyte/etc), organized (DBT), queryable (Snowflake/Bigquery), and available anywhere (Census/Hightouch). The modern data stack made data accessible to analysts. The AI data stack makes data accessible to everyone, by replacing the human translation layer (write SQL, build dashboard, schedule report, interpret results) with agents that go from question to answer automatically.
>
> Advanced companies were doing automated reporting with AI starting in late-2024/early-2025 with models like GPT-4o layered on top of DBT MetricFlow or Cube.dev, but it took a lot of handholding and careful semantic-layer management. With the release of Opus 4.6, and specifically Opus 4.6, even though Opus 4.6 loses pitifully on coding tasks vs Codex 5.3 xhigh, it crushes Codex 5.3 xhigh in side-by-side testing for data analysis, the need for an advanced semantic layer has completely collapsed (which is great, because it was a pain in the ass to begin with), and can now be entirely replaced with context management.
>
> **Killing the Semantic Layer with Context Management**
>
> The semantic layer is a static, hand-maintained mapping between business concepts and SQL (metrics, dimensions, relationships). It is a pain in the ass to build and a pain in the ass to maintain. Context management is the inverse: instead of pre-defining everything the agent might need, you give it access to the raw source of truth (your DBT models, your app code) and let it investigate on demand, per-question.
>
> Before writing any SQL, you just dispatch a sub-agent (I call it a context agent) to read the actual transformation logic in the dbt models and trace ref() dependencies upstream through the DAG. If you annotate your DBT files with metadata links into application code (highly recommended, and easy to automate) it will also validate business rules. It builds a brief for itself: relevant tables, column definitions, join paths, filters, dedup logic, caveats. This is the work a semantic layer was supposed to pre-compute, but now it happens dynamically at query time.
>
> The other great part about context management compared to the semantic layer is that it's adaptive. When a user corrects the agent ("no, that metric needs this filter" or "that table has duplicate rows, you need to dedup on X"), you can extract those corrections into durable, reusable knowledge that gets retrieved on future questions. This is the semantic layer rebuilding itself from usage, rather than requiring an analyst to maintain it.
>
> Semantic layers were brittle, they required constant maintenance, they couldn't cover edge cases, and they created a bottleneck where the data team had to anticipate every question. Context management scales with the codebase (because it reads the codebase) and scales with usage (because it learns from corrections and input from the team).
>
> **Basic Set Up**
>
> 1. Set up an agentic loop on your host machine. I recommend the Claude Agent SDK since Opus 4.6 > Codex 5.3 xhigh when it comes to data.
>
> 2. Ensure your dbt repo and codebase or codebases are accessible from the agentic loop.
>
> 3. Annotate your dbt base models (usually stg_) with links to application code and a high-level description of their functionality. This can mostly be done automatically.
>
> 4. Build out a context sub-agent that runs before SQL generation. When a question comes in, before your main agent writes any SQL, dispatch a sub-agent whose only job is to investigate the data landscape. It reads the relevant model files (the full transformation logic, not just headers), traces upstream dependencies, checks application code if annotations exist, and returns a structured brief: tables, columns, join paths, filters, dedup rules, caveats. This brief gets injected into the main agent's context. The sub-agent is cheap (it's mostly reading files) and it's what keeps the main agent from hallucinating table structures.
>
> 5. Build a knowledge store for learned corrections, or "quirks." When a user corrects the agent, extract the correction into a durable "quirk," a short, reusable piece of knowledge like "the orders table has duplicate rows per order when there are multiple shipments; always dedup on order_id." Store these with embeddings for semantic search. On each new question, run hybrid retrieval (vector similarity + keyword search) against your quirk store and inject the top matches alongside the context agent's brief. Over time this becomes your institutional knowledge base, the stuff that used to live in one analyst's head. I use Postgres with pgvector for vector similarity, OpenAI text-embedding-3-small for embeddings, and pg_textsearch for BM25 keyword search. It works fine.
>
> 6. Add human-authored metric definitions for your core KPIs, the metrics that get asked about constantly and have precise definitions. Let your data team author structured definitions with inference guidance (how to calculate it, what filters apply, etc). These go into the same knowledge store and get retrieved the same way as quirks. Think of this as the 20% of the semantic layer that was actually useful, maintained by humans when they feel like it rather than required for the system to function.
>
> 7. Connect this all to Slack (ensuring you set up multi-threading for the agents) and build a basic admin UI dashboard to monitor ongoing usage/results and enable editing of the knowledge store.
>
> **Advanced Tuning**
>
> Once the basic loop is working (context agent investigates, main agent writes SQL, answers come back) you're going to notice that sometimes the SQL is wrong in ways the agent doesn't catch. It'll run a query that executes fine but answers a slightly different question than what was asked, or it'll miss a filter, or it'll join on the wrong key and silently double-count. The agent doesn't know it got it wrong, so it confidently delivers a bad answer. A naive way to improve this would be to brute force adding more metrics definitions and quirks, or to add more documentation to your DBT files, but there's an elegant solution that's actually much simpler.
>
> The fix is to make the agent score its own work. After every SQL query, evaluate the result on three weighted axes: structural correctness (0.45, basic lint, is this valid SQL, not usually necessary but good to check), execution reliability (0.35, did this actually run without errors), and context alignment (0.20, does this query actually answer what was asked). Context alignment is the hard one. I use Haiku to assess it, including per-subquestion coverage scoring, with a deterministic heuristic fallback if Haiku is unavailable. Hard failures (query didn't execute, structural disaster) cap the score regardless of the weights.
>
> As part of every run, not just bad ones, I build what I call a context-gap brief. This is a deterministic aggregation from the scored query reviews, no extra model call, just crunching the scores you already have. Break the original question into subquestions, check which ones have strong evidence from high-confidence queries, and figure out what's still missing: missing dimensions, unresolved entities, wrong time windows, business logic that wasn't applied. Answer-level confidence is then computed from the brief via another deterministic formula with coverage caps. The brief feeds into confidence, not the other way around. Confidence is derived from actual coverage analysis, not vibes about whether the SQL looked right.
>
> The brief is also what drives the recovery loop. If there are real coverage gaps and enough SQL signals to work with, fire a retry. The decision comes from the brief, not from the confidence score directly. Build a targeted retry prompt that includes the original question, the previous draft answer, the weak signals, and specific directives for each gap ("resolve this entity," "add this time constraint," "validate this business logic"). If the gaps suggest the agent misunderstood the schema, force the context agent to re-run. The retries are surgical, not "try again and hope."
>
> For retrieval tuning, your hybrid search needs a few knobs. Collection weights let you balance how much to favor metrics vs. quirks in results. A reviewed-item multiplier ensures human-approved knowledge ranks higher than stuff the agent learned on its own (which may or may not be right). Use reciprocal-rank fusion to blend your vector and BM25 candidates into a single ranked list. Set a fixed context budget so you're not stuffing the entire knowledge store into every prompt, which can also be performance destroying.
>
> **Feel the AGI**
>
> This setup reduced what we thought was going to be an internal hiring plan for 4-5 data analysts at a friend's company to only hiring one. Customer Success and Sales can self-serves data in Slack now even for complex questions. Product/Growth can self-serve data in Slack now and instantly save it to Notion. Welcome to the future.
>
> Engagement: 150 likes | 11 retweets | 5 replies
> [Original post](https://x.com/jamiequint/status/2029705203457609785)
