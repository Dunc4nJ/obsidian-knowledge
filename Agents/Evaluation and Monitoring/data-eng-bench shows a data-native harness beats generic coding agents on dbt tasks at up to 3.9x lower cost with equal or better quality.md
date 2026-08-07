---
created: 2026-08-07
description: Snowflake AI Research + Bespoke Labs open-source data-eng-bench, a repository-level data engineering benchmark (103 dbt tasks over one 579-table warehouse, graded by hidden 10-50 assertion verifier suites). Headline finding — the harness matters as much as the model: the data-native Snowflake CoCo harness matches or beats generic Claude Code/Codex on Pass@1 while costing up to 3.9x less, via a plan-then-execute strategy that skips the explore-and-refine overhead (and needless DuckDB cross-validation) generic harnesses default to.
source: https://www.snowflake.com/en/blog/engineering/data-eng-bench-data-engineering-agent-benchmark/
author: Snowflake AI Research (with Bespoke Labs)
type: article
published: 2026-08-06
tags: [eval, benchmark, data-agent, data-engineering, dbt, sql, harness, agent-cost, pass-at-k, snowflake]
---

## Key Takeaways

- **data-eng-bench is a repository-level data-engineering benchmark graded on what the pipeline *does*, not what it looks like.** 103 tasks (84 build — greenfield scaffolds + brownfield additions to multi-layer projects — and 19 fix-a-subtly-broken-model), each handing an agent a live dbt project wired to a single persistent retail warehouse (579 source tables, 19 schemas, ~8,000 columns) and real dbt mechanics (source declarations, macros, staging→intermediate→mart materializations; gold DAGs median 4 models, up to 42). Each task ships a **hidden verifier suite of 10-50 assertions** that materializes the models and interrogates the output tables (grain/column contracts, formula correctness, edge cases, idempotency; hardest tasks recompute the answer in Python). Scoring is strict — partial credit per assertion, but a task resolves **only if every assertion passes** — the same bespoke-per-task grading philosophy as [[deep agent evals need bespoke per-datapoint test logic not uniform evaluators]] and the deterministic-grader emphasis of [[anthropic recommends combining deterministic graders model judges and human review for agent evals|combining deterministic graders, judges, and human review]]. It's bigger and harder than dbt Labs' ADE-Bench (103 vs 63 tasks, invariant-checking tests). It's also a first-party sibling to [[DAB benchmark exposes frontier data agents at 38 percent pass at 1 with 85 percent of failures in planning or implementation|UC Berkeley/Hasura's DAB]] and [[Prime Intellect duckdb-qa - RL reward shaping for SQL tool use|Prime Intellect's duckdb-qa]].

- **The headline: the harness matters as much as the model — and a data-native harness wins on quality *and* cost.** Isolating scaffold from model across CoCo / Claude Code / Codex × Opus 5 / Sonnet 5 / GPT 5.6 Sol, the data-native **Snowflake CoCo** harness consistently sits up-and-left on the cost-quality frontier: with **Opus 5, +4pp Pass@1 at 3.9x lower cost** than Claude Code ($0.76 vs $2.96/trial); with Sonnet 5, *same* Pass@1 at 2.3x lower cost; with GPT 5.6 Sol, +3.6pp at 1.5x lower cost than Codex. This is the strongest clean measurement yet of [[the harness is everything and agent performance comes from environment design not model capability|the harness-is-everything thesis]] and [[agent harnesses are the product not the model]] — a benchmark, not an assertion.

*Pass@1 vs cost per trial — CoCo (penguin) is up-and-left of the same models under Claude Code / Codex; Claude Code + Opus 5 lands far to the right at ~$3/trial for slightly lower quality:*
![[data-eng-bench-001.png]]

- **But the harness effect is model-dependent — there is no universally best scaffold.** Holding the harness at CoCo, Pass@1 spans a 17-point range by model (Opus 5 73.8% > GPT 5.6 Sol 64.1% > Sonnet 5 56.6%). And the *quality* delta from switching harness depends on the model: Opus 5 does best on CoCo (drops ~4pp on Claude Code), GPT 5.6 Sol does best on CoCo (drops 3.6pp on Codex), but **Sonnet 5 scores identically on CoCo and Claude Code** — the win there is purely cost. That model-conditioned harness sensitivity is exactly [[Model-Harness-Fit means tool surfaces and citation tags are post-trained into the model, not interchangeable|Model-Harness-Fit]]: tool surfaces interact with what each model was post-trained on, so "best harness" is not model-invariant.

- **Why CoCo is cheaper: plan-then-execute beats explore-and-refine.** With Opus 5, CoCo uses **1.5x fewer tool operations and 2.2x fewer agent steps** (34.3 vs 52.5 ops/trial), 1.7x fewer SQL queries, and 1.9x fewer file writes. The strategies diverge by phase: CoCo *front-loads* schema exploration and source profiling (2x fewer exploration SQL queries because it profiles once), then writes dbt models "without look-back," verifies once, and stops; Claude Code interleaves reading with writing mid-draft, wraps each phase in extra verification passes (1.5x more SQL to re-verify builds, 3x more shell setup), and — tellingly — runs **DuckDB cross-dialect validation in 2.25x more trials even though the backend is specified as Snowflake**, i.e. it fails to stay on scope and does unnecessary work the task never asked for.

*Tool operations per trial by phase (Opus 5): the biggest generic-harness waste is the build/validate loop (1.7x) and needless DuckDB cross-validation (3.4x):*
![[data-eng-bench-003.png]]

- **Frontier agents are real at data engineering but nowhere near saturated — and Pass^3 exposes the consistency gap.** The best config (CoCo + Opus 5) solves **73.8% Pass@1** but only **64.1% Pass^3** (all three runs pass); Sonnet 5 collapses to 40.8% Pass^3, GPT 5.6 Sol <56%. Reporting both metrics separates the capability ceiling (Pass@1) from run-to-run reliability (Pass^3) — the dimension that actually matters for autonomous production pipelines, and the reason vibes-based single-run demos mislead, per [[coding agent skills need dedicated evaluation benchmarks not vibes to measure real performance]]. The exploration/validation phases dominate agent effort, echoing that [[the hard problem in text-to-SQL is discovery not generation and hybrid search over existing metadata solves it|the hard part of data work is discovery, not generation]]; a data-native harness helps precisely because it understands the platform (schema, `ref` DAGs, dbt primitives — cf. [[semantic SQL parsing makes data transformations programmatically validatable which is what data agents need underneath them|semantic SQL parsing as the substrate data agents need]]) and doesn't re-derive it every run. Benchmark is open source (Snowflake-Labs/data-eng-bench).

## External Resources

- Original post: [Introducing Data-eng-bench: Why You Need "Data-Native" Harnesses for Data Engineering — Snowflake AI Research (2026-08-06)](https://www.snowflake.com/en/blog/engineering/data-eng-bench-data-engineering-agent-benchmark/)
- Benchmark: [Snowflake-Labs/data-eng-bench (GitHub)](https://github.com/Snowflake-Labs/data-eng-bench) · built with [Bespoke Labs](https://bespokelabs.ai/)
- Compared against: [dbt Labs ADE-Bench](https://github.com/dbt-labs/ade-bench) (63 tasks) · harnesses: [Snowflake CoCo / Cortex Code](https://docs.snowflake.com/en/user-guide/cortex-code/cortex-code) (recommend `cortex --mode code`), Claude Code, OpenAI Codex

## Original Content

> [!quote]- Full article — "Introducing Data-eng-bench: Why You Need 'Data-Native' Harnesses for Data Engineering" (Snowflake AI Research, 2026-08-06)
> # Introducing Data-eng-bench: Why You Need "Data-Native" Harnesses for Data Engineering
>
> [![Snowflake AI Research](https://www.snowflake.com/adobe/dynamicmedia/deliver/dm-aid--249da901-4810-48b7-ab40-99208c5e3b73/default-author-image.png?preferwebp=true&quality=85)Snowflake AI Research](/en/blog/authors/snowflake-ai-research/)
>
> As AI agents move from writing individual functions to owning end-to-end workflows, data teams face a harsh reality: general-purpose coding agents, regardless of their proficiency in Python or SQL, can struggle with production-grade data engineering. They often fail to complete tasks or incur high costs. This is a demanding test of an agent's ability to navigate a large warehouse, reason about business logic and handle edge cases. This is precisely the kind of work that has historically been difficult to measure.
>
> To measure this capability, we're open sourcing data-eng-bench, a benchmark for repository-level data engineering created in joint work with [Bespoke Labs](https://bespokelabs.ai/). Tasks in data-eng-bench hand an agent a live dbt project connected to an enterprise-scale data warehouse and ask it to build and fix real data pipelines. Resulting dbt models are then evaluated against the business rules and edge cases a working pipeline must satisfy. Relative to [ADE-Bench](https://github.com/dbt-labs/ade-bench), one of few other open benchmarks in this domain, data-eng-bench offers higher scale (103 tasks versus 63 tasks), robust tests that check invariants of the output data pipeline, and more complex task specifications.
>
> Our testing on data-eng-bench reveals a clear divide between generic agent harnesses, including Claude Code and OpenAI Codex, and the data-native agent harness [Snowflake CoCo](https://docs.snowflake.com/en/user-guide/cortex-code/cortex-code). Specifically, CoCo leverages its understanding of the data platform to consistently offer higher quality (that is, task completion rate) while incurring significantly lower cost. In more detail:
>
> * **The harness matters for quality; the effect varies by model:** Holding the harness fixed at CoCo, Pass@1 varies drastically across models: from 73.8% with Opus 5 to 64.1% with GPT 5.6 Sol to 56.6% with Sonnet 5, a 17-point spread. _The impact of the harness on quality depends on the model:_ Opus 5 performs the best with CoCo, dropping by \~4pp in Pass@1 with Claude Code; Sonnet 5 performs equally well with both CoCo and Claude Code; GPT 5.6 Sol performs the best with CoCo, dropping by 3.6pp with Codex.
> * **The harness matters significantly for cost efficiency:** CoCo achieves higher quality at lower cost than other harnesses: With Opus 5, CoCo reports a 4pp higher Pass@1 at 3.9x lower cost than Claude Code. With Sonnet 5, CoCo reports the same Pass@1 at 2.3x lower cost than Claude Code. With GPT 5.6 Sol, CoCo reports a 3.6pp higher Pass@1 than Codex with Codex incurring 1.5x the cost of CoCo. CoCo completes tasks with 1.5x fewer tool operations and 2.2x fewer agent steps than Claude Code. Task solving patterns show that CoCo adopts a more efficient exploration and validation strategy, requiring 1.7x fewer SQL queries and 1.2x fewer file reads during these phases. CoCo also stays on scope in 2.2x more instances, skipping unnecessary DuckDB cross-validation that Claude Code performs by default.
>
> While these results indicate that frontier agents have made big strides in tackling data engineering tasks, there is still headroom for further improvement. The strongest configuration we benchmarked, Snowflake CoCo with Opus 5, successfully solves 73.8% of tasks on the first attempt (average Pass@1 across 3 trials), but only 64.1% of tasks pass on all three runs (Pass^3). Sonnet 5 reports Pass^3 at 40.8% and GPT 5.6 Sol reports Pass^3 at <56% across harnesses.
>
> ![[data-eng-bench-001.png]]
>
> Figure 1\. Quality (calculated as the mean Pass@1 rate across 3 independent trials for each task) versus cost per trial by harness and model on data-eng-bench; up-and-left is better.
>
> In the rest of this blog, we provide an overview of the data-eng-bench benchmark, report how frontier agents perform on it in terms of quality, token and cost efficiency, and what it means for teams adopting coding agents for data engineering tasks.
>
> [_Get the benchmark_](https://github.com/Snowflake-Labs/data-eng-bench).
>
> ## The data-eng-bench benchmark
>
> We designed data-eng-bench to mirror how enterprise data engineering teams actually operate: many source systems, layered staging-to-mart development and a shared project that must be maintained by many users. Here is a breakdown:
>
> **One shared data warehouse:** Every task runs against a single, persistent retail data warehouse — 579 source tables across 19 schemas, roughly 8,000 columns in total — spanning orders, finance, procurement, marketing, inventory and more. That's broader than prior data engineering benchmarks, and each task requires navigating the same schema with different requirements.
>
> **103 tasks of two variants:** Each task gives the agent an instruction in natural language, a starting dbt project, and the data warehouse, then asks it to produce or correct models that materialize the right tables. The two variants are as follows:
>
> * **Build (84 tasks):** Author new models and keep the existing pipeline running. Build tasks can be further divided into (a) **Greenfield: Scaffold a brand new dbt project** from an empty state; and (b) **Brownfield: Add new models into an existing multi-layer project** while reusing and preserving dozens of production models.
> * **Fix (19 tasks):** Diagnose and repair a subtly broken production model.
>
> **Real dbt mechanics, not free-form SQL:** Agents work through dbt primitives: source declarations (45 tasks), reusable macros (13 tasks) and per-model materializations across staging, intermediate and mart layers. And 82% of gold solutions wire models together through explicit `ref` dependencies, averaging roughly nine `ref` calls each, which the agent must resolve into a coherent, compilable DAG. Those DAGs are meaningfully large: a median of four models per solution, and up to 42 for the biggest pipelines.
>
> **Diverse, high-difficulty business rules:** The tasks live in domains where data engineering is proven difficult — finance (ledger reconciliation, revenue recognition, multi-currency settlement), inventory (LIFO/FIFO costing, turnover, stockout risk), marketing (multi-touch attribution, campaign ROI) and customer analytics (RFM segmentation, churn, lifetime value). The business rules depend on the order and timing of events, accumulated or allocated values across many interdependent tables, and edge cases that should be handled exactly as defined.
>
> **Graded by what the pipeline does, not what it looks like:** Each task ships with a hidden verifier suite of 10–50 assertions that materializes the agent's models and interrogates the resulting tables directly. Those assertions encode the invariants a correct solution must satisfy (for example, output grain and column contracts, formula-level correctness, edge-case handling, idempotency across re-runs) and for the hardest tasks, independently recompute the expected result in Python.
>
> **Scoring is two-fold:** At the test level, assertions provide partial credit (the fraction that pass). At the task level, a task counts as resolved _only if every assertion passes_ — so a pipeline that's directionally right but wrong at the edges earns no task-level credit. This lets us separate "can generate a plausible model" from "got the whole pipeline correct" and pinpoint exactly where solutions fail.
>
> ## Measuring agent quality and cost
>
> We evaluate a combination of harnesses and models on data-eng-bench, isolating how much of an agent's performance comes from the scaffold versus the underlying model.
>
> We test three models spanning proprietary families — Opus 5 (Anthropic), Sonnet 5 (Anthropic) and GPT 5.6 Sol (OpenAI), run with several harnesses that differ in context management, planning and tool interfaces: Snowflake CoCo, Claude Code and Codex. We recommend Code mode (cortex --mode code via CLI) while using CoCo on dbt tasks for quality/cost balance. For every combination, we report two quality metrics: Pass@1 and Pass^3 rates. Pass@1 and Pass^3 capture complementary dimensions of quality, measuring the capability ceiling and consistency across runs respectively. We also report the average cost per trial (in $) and the average number of total tokens (across input, cache and output) per trial.
>
> | Harness               | Model       | Pass@1    | Pass^3    | Cost per trial ($) | Cost multiplier | Total tokens per trial |
> | --------------------- | ----------- | --------- | --------- | ------------------ | --------------- | ---------------------- |
> | Snowflake CoCo (Code) | Opus 5      | **73.8%** | **64.1%** | 0.756              | 1               | 1,070,515              |
> |                       | Sonnet 5    | 56.6%     | 40.8%     | 0.660              | 1               | 2,879,678              |
> |                       | GPT 5.6 Sol | 64.1%     | 55.3%     | 0.358              | 1               | 436,236                |
> | Claude Code           | Opus 5      | 69.6%     | 60.2%     | 2.959              | 3.914           | 4,810,868              |
> |                       | Sonnet 5    | 56.6%     | 40.8%     | 1.530              | 2.318           | 7,914,293              |
> | Codex                 | GPT 5.6 Sol | 60.5%     | 49.5%     | 0.538              | 1.503           | 812,306                |
>
> _**Tab 1.** Strict, task-level resolve rates (%). Pass@1 = mean single-attempt pass rate (averaged across three attempts); Pass^3 = resolved if all three attempts succeed. Cost multipliers are set to 1 for each combination of CoCo with the 3 models (Opus 5, Sonnet 5, GPT 5.6 Sol); the cost multiplier for other harnesses in conjunction with the corresponding model is compared against this baseline. For example, Claude Code with Opus 5 is 3.9x more costly than CoCo with Opus 5._
>
> A key takeaway is that the harness matters significantly for quality and cost efficiency. On data-eng-bench, CoCo consistently achieves higher quality at lower cost than other harnesses:
>
> * With Opus 5, CoCo reports a 4pp higher Pass@1 at 3.9x lower cost than Claude Code.
> * With Sonnet 5, CoCo reports the same Pass@1 at 3x lower cost than Claude Code.
> * With GPT 5.6 Sol, CoCo reports a 3.6pp higher Pass@1 at 1.5x lower cost than Codex.
>
> We now delve into why CoCo is more cost efficient than Claude Code.
>
> ![[data-eng-bench-002.png]]
>
> Figure 2\. Avg. number of steps taken by the Opus 5 agent under CoCo and Claude Code per trial.
>
> ![[data-eng-bench-003.png]]
>
> Figure 3\. Avg. number of tool operations by Opus 5 under CoCo and Claude Code across various phases of solving a task from data-eng-bench.
>
> With Opus 5, CoCo requires 1.5x fewer tool operations and 2.2x fewer agent steps than Claude Code to solve a task on average. The agent spends most of its time on the predevelopment exploration and postdevelopment validation phases, under both harnesses. Overall, CoCo issues 1.7x fewer SQL queries, concentrates file reads to the exploration phase and produces 1.9x fewer file writes. The tool call patterns in different phases on task execution reveal the strategies adopted by Opus 5 under the two harnesses:
>
> 1. **Phase 1 — Predevelopment setup and exploration:** CoCo requires 1.3x fewer tool operations before writing or editing the first SQL file. Both agents spend similar effort reading existing models and project config (6.6 vs 7.1 file reads). The divergence is in SQL: CoCo uses 2x fewer queries for schema exploration and source data profiling before writing.
> 2. **Phase 2 — dbt model development:** Both agents primarily write SQL files (4.4 vs 5.6 file writes). Claude Code additionally reads more files during this phase — consulting existing staging models and macros mid-draft — while CoCo completes all reading in Phase 1 and writes without look-back.
> 3. **Phase 3 — Build, validate and iterate on Snowflake:** CoCo requires 1.7x fewer tool operations, with the gap driven primarily by Claude Code issuing 1.5x more SQL queries to verify the built models and 3x more shell setup commands around each build iteration.
> 4. **Phase 4 — Cross-validation with DuckDB:** Interestingly, Claude Code performs DuckDB cross-dialect validation in **2.25x** more trials than CoCo. This step is unnecessary given the backend is specified as Snowflake and evaluates the agent's ability to avoid irrelevant details in the task instructions.
>
> These differences reflect two distinct strategies. CoCo follows a plan-then-execute approach — it front-loads exploration, writes directly, verifies once and stops. Claude Code follows an explore-and-refine approach — it interleaves reading with writing throughout development, wraps each phase with additional verification passes and treats cross-dialect validation as a default rather than an optional step.
>
> **Get started**
>
> Data-eng-bench is open source. Whether you build agents, harnesses or the models underneath them, it's a realistic, hard-to-saturate testbed for measuring autonomous data engineering.
>
> * **Explore the benchmark:** [here](https://github.com/Snowflake-Labs/data-eng-bench)
> * **Contribute:** add tasks, harnesses or model results and tell us what you find.
>
> We're excited to see how far agents can go on the work that quietly powers every analytics stack. Try data-eng-bench, run your own model–harness combinations and share your results!
