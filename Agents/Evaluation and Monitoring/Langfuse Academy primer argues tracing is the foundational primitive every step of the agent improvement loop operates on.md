---
created: 2026-05-16
description: Langfuse's Academy primer on LLM tracing frames it as the central observation primitive — reviewing, datasets, experiments, and evaluation all operate on traces — and lays out a minimal anatomy (hierarchical observations with input/output/timing/metadata, plus cost/latency/tokens) and a sessions-vs-traces boundary anchored on one system invocation.
source: https://x.com/lotte_verheyden/status/2055309852973715943
type: framework
---

## Key Takeaways

- The primer's anchor claim is that **tracing is not one tool among several but the substrate the entire improvement loop runs on** — every downstream activity (reviewing runs, building datasets, running experiments, evaluating) operates on traces. This is the same thesis as [[the agent improvement loop is traces enriched with evals and human feedback converted into validated fixes]] reached from the Langfuse side rather than the LangChain side, suggesting the major observability vendors have converged on the same mental model: traces are documentation, not just telemetry.

- Verheyden defines the **anatomy of a trace as a hierarchical tree of observations**, where each observation carries input, output, start/end time, and metadata, and an observation can be typed (LLM call, tool call, retrieval, etc.) to make filtering and reading 20-observation runs tractable. This is a lighter-weight phrasing of what the [[learning - OTel GenAI semantic conventions are becoming the standard wire format for LLM agent observability|OpenTelemetry GenAI conventions]] formalize as `create_agent` / `execute_tool` / `invoke_agent` spans — Langfuse's primer is the user-level abstraction that maps cleanly onto OTel semantics underneath.

- Cost, latency, and token usage are called out as **table-stakes attributes recorded per observation and aggregated up to the trace level** — the implication for any LLM observability stack is that if these three roll-ups aren't free, you've under-specified your trace schema. This matches the per-observation cost/token discipline in the [[resources/Langfuse|Langfuse]] resource note and the broader argument in [[agent trace data should live in your data lake not a 30-day SaaS retention window]] that these aggregates are the unit of business reporting.

- The traces-vs-sessions boundary is given a simple, durable rule: **one trace = one invocation of the system (an API call or a single agent execution); a session groups traces from a multi-turn lifecycle** (e.g. all turns in one conversation). This is worth memorizing — it dissolves a lot of trace-architecture debate by anchoring trace boundaries on the system's *invocation surface* rather than on user intent or task completion.

- The "where to start" advice is a deliberate **anti-completionist nudge**: instrument one real workflow end-to-end, make sure observations carry useful input/output/metadata, then eyeball a handful of real traces manually before scaling. This is the same posture as [[agent eval readiness starts with error analysis and simple end-to-end tests not sophisticated infrastructure]] — start with the one path that actually pays you, not with full coverage.

## External Resources

- [Langfuse Academy](https://langfuse.com/academy) — the series this post is part of; walks through the full AI engineering lifecycle.
- [The AI Engineering Loop](https://langfuse.com/academy/ai-engineering-loop) — recommended starting point that frames the loop these primers populate (verbatim summary captured below).
- [Observability overview](https://langfuse.com/docs/observability/overview) — Langfuse's docs entry point for traces.
- [Data model](https://langfuse.com/docs/observability/data-model) — observation schema reference.
- [Observation types](https://langfuse.com/docs/observability/features/observation-types) — full list of typed observation kinds.
- [Token and cost tracking](https://langfuse.com/docs/observability/features/token-and-cost-tracking) — per-observation cost/token recording.
- [Sessions](https://langfuse.com/docs/observability/features/sessions) — grouping traces into multi-turn lifecycles.
- [Get started with tracing](https://langfuse.com/docs/observability/get-started) — SDK setup for the "instrument one workflow first" path.
- [Monitoring](https://langfuse.com/academy/monitoring) — the next Academy module after tracing.

## Original Content

> @lotte_verheyden — 2026-05-15
>
> **Article: A primer on tracing for LLM applications**
>
> This is one piece of a series we're publishing as part of the [Langfuse Academy](https://langfuse.com/academy), where we walk through the full AI engineering lifecycle. If you're new to the series, [The AI Engineering Loop](https://langfuse.com/academy/ai-engineering-loop) is the best place to start.
>
> ## A short recap of the AI Engineering Loop
>
> The AI Engineering Loop is how teams continuously improve AI systems. It connects what's happening in production (tracing, monitoring) to structured iteration during development (datasets, experiments, evaluation). Each shipped improvement produces new data, and teams loop through this process continuously.
>
> You can read more on this [here](https://langfuse.com/academy/ai-engineering-loop).
>
> ## How tracing fits into the loop
>
> Traditional software is largely deterministic, executions follow a pre-defined format. For LLM applications that's not the case. Agent executions can be messy, we are dealing with emergent behaviour with rich and unexpected inputs and outputs, and execution order. You need something else to follow your agent's behavior: [traces](https://langfuse.com/docs/observability/overview).
>
> Tracing is central to the entire improvement loop. Every other step (reviewing, building datasets, running experiments, evaluating) operates on traces.
>
> If you're already familiar with traditional observability concepts, some of what follows may feel repetitive. Feel free to skim or skip ahead.
>
> ## The anatomy of a trace
>
> A trace can be as complex or as simple as your application requires, but all traces share the same basic structure. It's composed of a set of [observations](https://langfuse.com/docs/observability/data-model) that map out the path your agent took.
>
> An observation is a single step in the process. It has an input, an output, start/end time, and metadata about what happened during that step.
>
> ### Hierarchy
>
> A trace has a hierarchical tree structure. Nested inside are observations that can contain other observations, forming a parent-child structure that mirrors the actual execution of your AI application.
>
> You can see what happened in what order, and which steps were part of which larger step.
>
> ### Observation data
>
> Input and output. Every observation can have an input and an output. Most of the time it will have both; in some specific cases it might only have one of the two. It's important for interpretability that you set an input and/or output that makes sense for the type of action happening in that observation.
>
> Observation types. In order to make it easy to differentiate between operations, you'll see different [types of observations](https://langfuse.com/docs/observability/features/observation-types). Each type of observation is used to capture different kinds of interactions of an agent.
>
> Observation types make it easier to read traces and to filter. In a trace with 20 observations, being able to quickly spot the LLM calls saves time.
>
> ### Cost, latency, token usage
>
> Beyond input and output, there are a few attributes on observations that are table stakes in any LLM application: cost, latency, and [token usage](https://langfuse.com/docs/observability/features/token-and-cost-tracking). These are recorded per observation and aggregated at the trace level.
>
> ## Traces vs sessions
>
> Most of the time you would not see an entire agent's lifecycle execution in one trace. Traces can be grouped into [sessions](https://langfuse.com/docs/observability/features/sessions). But where do you draw the line between a trace and a session?
>
> A general rule of thumb is: one trace corresponds to one invocation of your system, typically one API call or one agent execution. A session then groups multiple traces together, for example all the turns in a multi-turn conversation.
>
> ## Where to start
>
> If you're just getting started, focus on instrumenting one real workflow end to end before trying to cover every possible path.
>
> 1. [Set up tracing](https://langfuse.com/docs/observability/get-started) for one important request path in your application.
>
> 2. Make sure each observation captures useful input, output, and metadata for the step it represents.
>
> 3. Review a handful of real traces manually to confirm that the structure is easy to follow and useful for debugging.
>
> ## What comes next
>
> Once you see traces, you can move on to the next step: [monitoring](https://langfuse.com/academy/monitoring). Monitoring is what connects traces to the loop of improving and iterating on your agent.
>
> Engagement: 42 likes | 5 retweets | 2 replies
> [Original post](https://x.com/lotte_verheyden/status/2055309852973715943)

### Linked artifact: The AI Engineering Loop (Langfuse Academy)

The post links to [The AI Engineering Loop](https://langfuse.com/academy/ai-engineering-loop) twice as the recommended entry point. Captured inline below as a near-verbatim summary so this note remains usable without the URL.

> [!quote]- Linked: The AI Engineering Loop — langfuse.com/academy/ai-engineering-loop
> # The AI Engineering Loop
>
> The AI Engineering Loop is how teams approach the continuous evolution and improvement of their AI-powered systems. It connects what happens in production directly to the work of improving quality, cost, latency, and reliability during development.
>
> Many of the underlying concepts mirror traditional software engineering, but a key differentiator is the probabilistic nature of LLM outputs and the sheer number of paths a system can take. You cannot unit-test your way to confidence. You need a systematic way to observe, learn, and improve via experiments.
>
> The loop clusters into two areas of work.
>
> ## 1. Understanding what's happening in production
>
> The first part is about visibility. What is your system actually doing in the real world? Which requests are going well, and which are failing in ways that matter?
>
> ### Trace
>
> Capture the full path of a request, including prompts, retrieved context, tool calls, outputs, latency, and cost. Tracing is the raw record of what your system actually did. [→ Read more](https://langfuse.com/academy/tracing)
>
> ### Monitor
>
> Track how the system behaves over time and surface the traces that deserve attention. Monitoring turns a stream of raw data into an ongoing understanding of how the system evolves. Evaluation methods help you surface quality over time and draw attention to interesting events in your application. Implicit and explicit user feedback, along with cost or latency anomalies, help you surface interesting traces. [→ Read more](https://langfuse.com/academy/monitoring)
>
> ## 2. Improving systematically during development
>
> The second part is about turning what you have observed into improvements you can trust — without degrading the parts of the system that are already working. If your application is not in production, datasets, experiments, and evaluation are a great starting point for gaining confidence in your system before deploying to production.
>
> ### Build datasets
>
> Turn real scenarios surfaced through monitoring and expected scenarios you design during development into repeatable test cases. Instead of testing against a handful of hand-picked examples, you build a set that reflects how the system actually gets used. A dataset can contain examples from production as well as hypothetical examples that define the surface area your system will face. [→ Read more](https://langfuse.com/academy/datasets)
>
> ### Experiment
>
> Change variables systematically — a prompt, a model, a retrieval strategy — and compare each change against a stable baseline or other experimental setups. That way you know what actually improved instead of guessing. [→ Read more](https://langfuse.com/academy/experiments)
>
> ### Evaluate
>
> Decide whether results are good enough to ship using manual review, code-based checks, or LLM-as-a-judge. Evaluation is how you turn a comparison into a decision. [→ Read more](https://langfuse.com/academy/evaluate)
>
> Once you ship a change, the cycle starts again. The updated system produces new traces, new monitoring signals, and new opportunities to improve.
>
> ## You don't have to close the full loop on day one
>
> Most teams don't start with all five steps in place. That is fine.
>
> The value of the loop is cumulative. Each step you add gives you better signal, more systematic coverage, and more confidence in what you are shipping. The goal is not to implement everything at once — it is to understand where you are and take the next step toward closing the loop. Many teams start with tracing or by building early datasets.
>
> ### Start with tracing
>
> One natural place to begin is tracing. You cannot monitor what you cannot see, and you cannot improve what you cannot measure. Tracing is the foundation everything else builds on. Let's assume your starting point is an application that has been running live for some months. You now want to better understand what the system actually does step by step, as a foundation for evaluating and improving your system. Adding tracing will be a great starting point to gain those insights.
>
> [→ Start with Tracing](https://langfuse.com/academy/tracing)
>
> ### Start with building datasets
>
> Some teams prefer to start with building datasets to scope the surface area they expect their system to deal with. While this is a great way to build up repeatable cases early on, teams benefit from adding tracing to these early executions to deeply understand how the system behaves. Let's assume you have been working on your system for some time but you want to gain confidence in the quality before shipping to production. Your customers might even require this because they are in regulated environments with high quality bars. Building datasets, experimenting and systematically evaluating the outcomes will help you build the necessary trust and confidence.
>
> [→ Start with Datasets](https://langfuse.com/academy/datasets)
