---
created: 2026-03-06
description: Databricks' KARL agent uses custom reinforcement learning to match frontier model performance on grounded reasoning tasks while dramatically reducing inference cost and latency, using only synthetic data and a few thousand GPU hours.
source: https://www.databricks.com/blog/meet-karl-faster-agent-enterprise-knowledge-powered-custom-rl
type: learning
---

# Custom RL on enterprise agents matches frontier models at a fraction of cost and latency

## Key Takeaways

Databricks built KARL (Knowledge Agent via Reinforcement Learning) to handle **grounded reasoning** — searching documents, cross-referencing information, and reasoning over dozens or hundreds of steps. This is the same class of hard-to-verify tasks that make [[stable agentic RL requires sequence-level clipping and environment-aware advantages to prevent training collapse|agentic RL notoriously unstable]], yet KARL matches frontier proprietary models on quality while strictly dominating on cost and latency. The training used only synthetic data and a few thousand GPU hours — a remarkably small investment for the claimed performance parity.

The key architectural insight is that grounded reasoning tasks are **hard-to-verify** — unlike math or coding, there's rarely a single correct answer. This makes reward shaping for RL significantly harder, connecting directly to the challenges explored in [[prime intellect duckdb-qa RL reward shaping for SQL tool use|reward shaping environments]] where verification is more tractable. KARL's success on hard-to-verify tasks suggests the RL techniques have matured beyond domains with clean reward signals.

Databricks is now offering the same RL pipeline to customers as a private preview backed by Serverless GPU Compute. This positions custom RL as a production optimization layer for high-volume agentic workloads — train a smaller, faster, domain-specific model that replaces expensive frontier inference. The pattern mirrors what Cursor did with their Composer model, where RL-based customization drastically improved both speed and quality. This is directly relevant to [[async RL from real conversations lets agents continuously improve without blocking inference|continual learning pipelines]] — the logical next step is closing the loop so these RL models improve from production conversations rather than requiring periodic retraining.

The practical implication: if you have a high-volume enterprise agent use case, custom RL fine-tuning is now a proven path to 3-axis improvement (cost, latency, quality) over using frontier models directly.

## External Resources

- [KARL Tech Report (PDF)](https://www.databricks.com/karl.pdf) — full technical details on training pipeline and evaluation
- [Custom RL Preview Sign-up](https://forms.gle/YR171eqRupM43tVW9) — Databricks customer access to the RL pipeline
- [RL technique paper 1](https://arxiv.org/abs/2505.17373) — referenced RL method
- [RL technique paper 2](https://arxiv.org/abs/2602.19362) — referenced RL method
- [Cursor Composer model blog](https://cursor.com/blog/composer) — cited as parallel industry result
- [Instructed Retriever blog](https://www.databricks.com/blog/instructed-retriever-unlocking-system-level-reasoning-search-agents) — related Databricks work on search agents
- [OfficeQA benchmark](https://www.databricks.com/blog/introducing-officeqa-benchmark-end-to-end-grounded-reasoning) — Databricks grounded reasoning benchmark

## Original Content

> [!quote]- Source Material
>
> **Reinforcement Learning for Enterprise Agents**
>
> *For the full tech report, [click here](https://www.databricks.com/karl.pdf). Interested in trying Databricks custom RL on your enterprise agent? [Click here](https://forms.gle/YR171eqRupM43tVW9).*
>
> The improved reasoning abilities of current models has led to an explosion of agents deployed for knowledge work, such as writing code, asking questions about enterprise data, and automating common workflows. While models used in enterprise tasks are very powerful, they are also extremely expensive, and inference costs have begun to grow unsustainably for many use cases. In this post and the [corresponding tech report](https://www.databricks.com/karl.pdf), we describe our experience using reinforcement learning (RL) to build custom models to power use cases that are a key part of our Agent Bricks product. This example demonstrates that, for relatively low costs, it is possible to build custom models that strictly dominate frontier models on all three critical dimensions: inference cost, latency, and quality. Our findings are consistent with other industry observations, such as Cursor's [Composer model](https://cursor.com/blog/composer), where RL-based customization was able to drastically improve both speed and quality compared to alternatives.
>
> **KARL: A Faster, Stronger, Cheaper Knowledge Agent for Databricks Users**
>
> *KARL performance comparison chart*
> ![[databricks-karl-001.png]]
>
> The model we trained, which we call KARL, addresses a critical enterprise capability, _grounded reasoning_: answering questions by searching for documents, fact-finding, cross-referencing information, and reasoning over dozens or hundreds of steps. Grounded reasoning is required for several Databricks products, such as Agent Bricks Knowledge Assistant. Unlike math and coding, grounded reasoning tasks are _hard-to-verify_ – there's often no single correct answer. In situations like this, guiding reinforcement learning to a good solution is especially hard.
>
> Using [RL techniques](https://arxiv.org/abs/2505.17373) [and infrastructure](https://arxiv.org/abs/2602.19362) developed at Databricks, KARL matches the performance of the world's most powerful proprietary models at a fraction of the serving cost and latency, including on new grounded reasoning tasks it had never seen. ([See the tech report for full details.](https://www.databricks.com/karl.pdf)) We did this with just a few thousand GPU hours of training and entirely synthetic data.
>
> In internal testing with human users, KARL provided better and more comprehensive responses than our existing products and the latest frontier models. This research is making its way into the Databricks agents you use today, like Agent Bricks, grounding answers in your unstructured and structured data in the Databricks Lakehouse.
>
> **A reusable RL pipeline for Databricks customers**
>
> We are excited to share that the same RL pipelines and infrastructure we used to create KARL (and other agents we'll talk about soon) **are now available to Databricks customers seeking to improve model performance and reduce costs** for their high-volume agentic workloads. Nearly all real-world enterprise tasks are hard-to-verify, so KARL paves the way – not just for a better experience for Databricks users – but for our customers to create their own custom RL models for their popular agents. Our Custom RL private preview, backed by [Serverless GPU Compute](https://docs.databricks.com/aws/en/compute/serverless/gpu), enables you to use the KARL infrastructure to build a more efficient, domain-specific version of your agent. If you have an AI agent that's scaling fast and are interested in optimizing it with RL, [sign up here to express your interest in this preview](https://forms.gle/YR171eqRupM43tVW9).

Source: <https://www.databricks.com/blog/meet-karl-faster-agent-enterprise-knowledge-powered-custom-rl>
