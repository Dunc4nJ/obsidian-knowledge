---
created: 2026-08-13
description: Hamel Husain's summary of Shreya Shankar's AI Product Engineering session on the Data Agent Benchmark (DAB) — a product-builder's reading of the benchmark the vault already holds in full: DAB recreates real warehouse mess (data spread across 2+ database systems, inconsistent join keys, key values buried in free text, ambiguous schemas), and its failure analysis matters for anyone building a data agent — agents fail mostly on plans and implementations, not data selection, and often write a plan first then stick to it even after the data contradicts it.
source: https://hamel.dev/notes/llm/ai-product-engineering/evals-data-agents.html
author: Hamel Husain (summarizing Shreya Shankar's session)
type: article
tags: [data-agent, eval, benchmark, dab, failure-analysis, ai-product-engineering, hamel]
---

## Key Takeaways

- **The product-builder's angle on DAB: even if the benchmark answers a different question than your product evals, its failure analysis transfers.** Hamel's note (from Shreya Shankar's talk in his AI Product Engineering series) frames the [[DAB benchmark exposes frontier data agents at 38 percent pass at 1 with 85 percent of failures in planning or implementation|Data Agent Benchmark]] for practitioners: data agents answer "which cohort had the highest churn?"-style questions that are a huge share of knowledge work, yet good benchmarks are scarce. DAB's realism recipe — every task spreads data across **at least two database systems**, with inconsistent join keys, key values buried in free text, and ambiguous or ill-defined schemas — is what separates it from cleaner text-to-SQL suites (see the comparison table below), the same realism bet as [[data-eng-bench shows a data-native harness beats generic coding agents on dbt tasks at up to 3.9x lower cost with equal or better quality|data-eng-bench's]] persistent 579-table warehouse.

- **The headline failure mode: plan rigidity — agents write a plan and stick to it even when the data contradicts it.** The surprising result Hamel pulls out: agents failed most on **incorrect plans and implementations rather than wrong data selection** — and specifically, they "often wrote a plan first and stuck to it even after the data contradicted it." That's a debugging checklist item for anyone building a data agent, and a sharp counterpoint to plan-first orthodoxy: Bridgewater's PAT treats "the plan is the analysis" as its core strength, but DAB shows the failure mode of exactly that pattern when the plan isn't revised against evidence — plan-commitment needs a data-contradiction escape hatch.

- **DAB is live infrastructure, not a static paper artifact.** The benchmark is open, accepts leaderboard submissions, and the team refreshes it as new models come out — "worth watching" as the ongoing scoreboard for the data-agent capability the vault's Case Studies (Anthropic, LangChain, OpenAI internal) are all building toward.

*DAB vs related benchmark categories on its four properties (multi-system data, inconsistent keys, values in free text, ambiguous schemas):*
![[hamel-evals-data-agents-001.png]]

## External Resources

- Original note: [Evals For Data Agents — Hamel Husain](https://hamel.dev/notes/llm/ai-product-engineering/evals-data-agents.html), part of the [AI Product Engineering series](https://hamel.dev/notes/llm/ai-product-engineering/) (13 sessions on evals, context, and systems)
- [Shreya Shankar's talk (YouTube)](https://youtu.be/ubk57rW_KUo) · [DAB paper (arXiv 2603.20576)](https://arxiv.org/abs/2603.20576) · [DAB leaderboard](https://ucbepic.github.io/DataAgentBench/)

## Original Content

> [!quote]- Full note — "Evals For Data Agents" (Hamel Husain, AI Product Engineering series; session by Shreya Shankar)
> _This note covers Shreya Shankar’s session in the [AI Product Engineering series](../../../notes/llm/ai-product-engineering/index.html)._
>
> Data agents answer business questions like “which cohort had the highest churn?” that a data analyst would normally answer. Even though these questions are a large share of knowledge work, good benchmarks for them are scarce.
>
> [Shreya Shankar’s talk](https://youtu.be/ubk57rW%5FKUo) introduces the [Data Agent Benchmark (DAB)](https://arxiv.org/abs/2603.20576). The authors recreate the mess of a real data warehouse. Each task spreads data across at least two database systems, with inconsistent join keys, key values buried in free text, and ambiguous or ill-defined schemas. The table below shows how DAB compares to related benchmark categories.
>
> ![[hamel-evals-data-agents-001.png]]
>
> DAB compared to related benchmark categories on its four properties.
>
> While this general benchmark answers a different question than product evals, the failure analysis is useful if you are building a data agent.
>
> Surprisingly, data agents failed the most for incorrect plans and implementations rather than wrong data selection. The study found that agents often wrote a plan first and stuck to it even after the data contradicted it. These failure modes are worth keeping in mind while debugging your own data agents.
>
> The benchmark is open and accepts submissions to [its leaderboard](https://ucbepic.github.io/DataAgentBench/). The team refreshes it as new models come out, so it is worth watching.
>
> ---
