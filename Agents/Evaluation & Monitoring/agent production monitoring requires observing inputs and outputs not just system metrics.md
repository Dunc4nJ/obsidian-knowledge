---
created: 2026-02-27
description: Traditional APM tools track latency and error rates but miss what matters for agents — the actual conversations, reasoning chains, and tool selections that determine quality.
source: https://x.com/hwchase17/status/2027094058330656814
type: synthesis
---

## Key Takeaways

Agent observability is fundamentally different from traditional software monitoring because the signal lives in the natural language conversations themselves, not in status codes and response times. Harrison Chase argues that agents have an infinite input space (users can phrase anything any way) and LLMs are sensitive to subtle prompt variations, so the behavior you see in development won't match production. This connects to the broader challenge of [[multi-agent squads work when independent sessions share a mission control system|orchestrating agents at scale]] — you can't just ship and forget.

The practical framework he lays out has three layers: **annotation queues** for structured human review of specific traces (experts review 50-100/hour, so you need to route the right ones), **LLM-as-judge evaluators** running continuously on sampled production traffic (10-20%) for quality/safety/topic classification, and **automated pattern discovery** that clusters similar traces to surface usage patterns and failure modes without you specifying what to look for upfront.

The insight about why general-purpose APM tools fall short comes down to three gaps: payloads (full conversation threads need semantic search, not keyword matching), connectivity (production traces need to flow into eval datasets and back into development), and users (agent observability is cross-functional — AI engineers, PMs, domain experts, data scientists — not just SREs).

An important nuance: RL and evaluation research shows that LLM evaluators aren't perfect and can drift as production traffic shifts. The recommendation is to combine automated evaluation with periodic human review rather than trusting either alone. This resonates with the [[async RL from real conversations lets agents continuously improve without blocking inference|OpenClaw-RL approach]] of using process reward models that also need continuous calibration.

## External Resources

- [LangSmith Observability](https://www.langchain.com/langsmith) — LangChain's agent monitoring platform
- [LangSmith Docs: Online Evaluations](https://docs.langchain.com/langsmith/evaluation-concepts#online-evaluations)
- [Align Evals](https://blog.langchain.com/introducing-align-evals/) — tool for validating custom LLM evaluators against human labels

## Original Content

> @hwchase17 — 2026-02-26
>
> Article: You don't know what your agent will do until it's in production
>
> When you ship traditional software to production, you have a good sense of what to expect. Users click buttons, fill out forms, navigate through predetermined paths. Your test suite might cover 80-90% of code paths, and monitoring tools track the usual suspects: error rates, response times, database queries. When something breaks, you look at stack traces and logs.
>
> Agents operate differently. They accept natural language input, where the space of possible queries is unbounded. They're powered by large language models that are sensitive to subtle variations in prompts and can produce different outputs for the same input. And they make decisions through multi-step reasoning chains, tool calls, and retrieval operations that are difficult to fully anticipate during development.
>
> Key points:
> - Agents have an infinite input space vs traditional software's finite, constrained inputs
> - LLMs exhibit prompt sensitivity and non-deterministic behavior — dev ≠ production
> - Production monitoring must capture complete prompt-response pairs, multi-turn context, and full agent trajectories
> - Three approaches to scale: annotation queues (structured human review), LLM-as-judge online evaluators (10-20% sampling), and automated pattern discovery (clustering similar traces)
> - General APM tools fail on payloads (need semantic search over conversations), connectivity (need tight eval→dataset→experiment loop), and users (cross-functional teams, not just SREs)
>
> Engagement: 170 likes | 24 retweets | 10 replies
> [Original post](https://x.com/hwchase17/status/2027094058330656814)
