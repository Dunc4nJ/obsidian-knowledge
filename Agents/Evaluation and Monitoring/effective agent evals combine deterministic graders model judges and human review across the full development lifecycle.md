---
created: 2026-03-04
description: Anthropic's comprehensive guide to building evaluations for AI agents, covering grader types, eval-driven development, non-determinism handling, and how evals fit alongside production monitoring and A/B testing.
source: https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents
author: Mikaela Grace, Jeremy Hadfield, Rodrigo Olivares, Jiri De Jonghe
type: framework
---

## Key Takeaways

Agent evals differ fundamentally from single-turn LLM evals because agents modify state across many turns, and mistakes compound — a failed tool call early in a trajectory can cascade through all subsequent steps. The article builds on Anthropic's earlier agent design principles and extends them into the evaluation domain.

Three grader types form the evaluation toolkit: **code-based** (unit tests, static analysis, state checks — fast, cheap, reproducible), **model-based** (LLM-as-judge with rubrics — flexible, handles nuance, but non-deterministic), and **human** (expert review — gold standard but expensive). The key insight is to grade **outcomes rather than trajectories** — agents regularly find valid approaches that eval designers didn't anticipate, so checking the path taken produces brittle tests.

The distinction between **capability evals** (hill to climb, start at low pass rate) and **regression evals** (must stay near 100%) is operationally critical. Capability evals that reach high pass rates "graduate" into regression suites. This lifecycle mirrors how [[agents need a harness not a framework because durable event-driven infrastructure already solves retry routing and state|agent harness engineering]] treats infrastructure: start simple, formalize what works.

Non-determinism demands statistical thinking: **pass@k** (at least one success in k trials) suits tools where any correct answer works, while **pass^k** (all k trials succeed) suits customer-facing agents where consistency matters. A 75% per-trial rate yields only 42% pass^3.

The practical roadmap — start with 20-50 tasks from real failures, write unambiguous specs with reference solutions, build balanced problem sets testing both positive and negative cases — echoes [[designing agent tools is an iterative art shaped by model capabilities not fixed engineering rules|iterative tool design]] philosophy. Eval-driven development means defining capability evals before the agent can pass them, then iterating.

Evals are one layer in a Swiss-cheese model alongside production monitoring, A/B testing, user feedback, manual transcript review, and systematic human studies. No single layer catches everything — the most effective teams combine automated evals for fast iteration, production monitoring for ground truth, and periodic human review for calibration.

## External Resources

- [SWE-bench Verified](https://www.swebench.com/SWE-bench/) — coding agent benchmark using real GitHub issues
- [Terminal-Bench](https://www.tbench.ai/) — end-to-end technical task benchmark
- [τ2-Bench](https://github.com/sierra-research/tau2-bench) — multi-turn conversational agent benchmark
- [BrowseComp](http://arxiv.org/abs/2504.12516) — web research agent benchmark
- [Harbor](https://harborframework.com/) — containerized agent eval framework
- [Promptfoo](https://www.promptfoo.dev/) — declarative YAML-based prompt testing
- [Braintrust](https://www.braintrust.dev/) — offline eval + production observability
- [LangSmith](https://docs.langchain.com/langsmith/evaluation) — tracing + evals (LangChain ecosystem)
- [[Langfuse]] — self-hosted open-source alternative

## Original Content

> [!quote]- Source Material

> Mikaela Grace, Jeremy Hadfield, Rodrigo Olivares, Jiri De Jonghe — Anthropic Engineering Blog — January 9, 2026
>
> # Demystifying evals for AI agents
>
> The capabilities that make agents useful also make them difficult to evaluate. The strategies that work across deployments combine techniques to match the complexity of the systems they measure.
>
> ## Introduction
>
> Good evaluations help teams ship AI agents more confidently. Without them, it's easy to get stuck in reactive loops—catching issues only in production, where fixing one failure creates others. Evals make problems and behavioral changes visible before they affect users, and their value compounds over the lifecycle of an agent.
>
> As we described in [Building effective agents](https://www.anthropic.com/engineering/building-effective-agents), agents operate over many turns: calling tools, modifying state, and adapting based on intermediate results. These same capabilities that make AI agents useful—autonomy, intelligence, and flexibility—also make them harder to evaluate.
>
> Through our internal work and with customers at the frontier of agent development, we've learned how to design more rigorous and useful evals for agents. Here's what's worked across a range of agent architectures and use cases in real-world deployment.
>
> ## The structure of an evaluation
>
> An **evaluation** ("eval") is a test for an AI system: give an AI an input, then apply grading logic to its output to measure success. In this post, we focus on **automated evals** that can be run during development without real users.
>
> **Single-turn evaluations** are straightforward: a prompt, a response, and grading logic. For earlier LLMs, single-turn, non-agentic evals were the main evaluation method. As AI capabilities have advanced, **multi-turn evaluations** have become increasingly common.
>
> *Single-turn vs multi-turn evaluation comparison*
> ![[anthropic-evals-agents-001.png]]
>
> In a simple eval, an agent processes a prompt, and a grader checks if the output matches expectations. For a more complex multi-turn eval, a coding agent receives tools, a task (building an MCP server in this case), and an environment, executes an "agent loop" (tool calls and reasoning), and updates the environment with the implementation. Grading then uses unit tests to verify the working MCP server.
>
> **Agent evaluations** are even more complex. Agents use tools across many turns, modifying state in the environment and adapting as they go—which means mistakes can propagate and compound. Frontier models can also find creative solutions that surpass the limits of static evals. For instance, Opus 4.5 solved a [τ2-bench](https://github.com/sierra-research/tau2-bench) problem about booking a flight by [discovering](https://www.anthropic.com/news/claude-opus-4-5) a loophole in the policy. It "failed" the evaluation as written, but actually came up with a better solution for the user.
>
> When building agent evaluations, we use the following definitions:
>
> - A **task** (a.k.a **problem** or **test case**) is a single test with defined inputs and success criteria.
> - Each attempt at a task is a **trial**. Because model outputs vary between runs, we run multiple trials to produce more consistent results.
> - A **grader** is logic that scores some aspect of the agent's performance. A task can have multiple graders, each containing multiple assertions (sometimes called **checks**).
> - A **transcript** (also called a **trace** or **trajectory**) is the complete record of a trial, including outputs, tool calls, reasoning, intermediate results, and any other interactions.
> - The **outcome** is the final state in the environment at the end of the trial.
> - An **evaluation harness** is the infrastructure that runs evals end-to-end.
> - An **agent harness** (or **scaffold**) is the system that enables a model to act as an agent.
> - An **evaluation suite** is a collection of tasks designed to measure specific capabilities or behaviors.
>
> *Components of evaluations for agents*
> ![[anthropic-evals-agents-002.png]]
>
> ## Why build evaluations?
>
> When teams first start building agents, they can get surprisingly far through a combination of manual testing, [dogfooding](https://en.wikipedia.org/wiki/Eating%5Fyour%5Fown%5Fdog%5Ffood), and intuition. More rigorous evaluation may even seem like overhead that slows down shipping. But after the early prototyping stages, once an agent is in production and has started scaling, building without evals starts to break down.
>
> The breaking point often comes when users report the agent feels worse after changes, and the team is "flying blind" with no way to verify except to guess and check. Absent evals, debugging is reactive: wait for complaints, reproduce manually, fix the bug, and hope nothing else regressed.
>
> We've seen this progression play out many times. For instance, Claude Code started with fast iteration based on feedback from Anthropic employees and external users. Later, we added evals—first for narrow areas like concision and file edits, and then for more complex behaviors like over-engineering. These evals helped identify issues, guide improvements, and focus research-product collaborations.
>
> Writing evals is useful at any stage in the agent lifecycle. Early on, evals force product teams to specify what success means for the agent, while later they help uphold a consistent quality bar.
>
> [Descript](https://www.descript.com/)'s agent helps users edit videos, so they built evals around three dimensions of a successful editing workflow: don't break things, do what I asked, and do it well. The [Bolt](https://bolt.new/) AI team started building evals later, after they already had a widely used agent. In 3 months, they built an eval system that runs their agent and grades outputs with static analysis, uses browser agents to test apps, and employs LLM judges for behaviors like instruction following.
>
> Evals also shape how quickly you can adopt new models. When more powerful models come out, teams without evals face weeks of testing while competitors with evals can quickly determine the model's strengths, tune their prompts, and upgrade in days.
>
> ## How to evaluate AI agents
>
> ### Types of graders for agents
>
> Agent evaluations typically combine three types of graders: code-based, model-based, and human.
>
> **Code-based graders:** String match checks, binary tests (fail-to-pass), static analysis (lint, type, security), outcome verification, tool calls verification, transcript analysis. Strengths: fast, cheap, objective, reproducible. Weaknesses: brittle to valid variations, lacking nuance.
>
> **Model-based graders:** Rubric-based scoring, natural language assertions, pairwise comparison, reference-based evaluation, multi-judge consensus. Strengths: flexible, scalable, captures nuance, handles open-ended tasks. Weaknesses: non-deterministic, more expensive, requires calibration.
>
> **Human graders:** SME review, crowdsourced judgment, spot-check sampling, A/B testing, inter-annotator agreement. Strengths: gold standard quality, matches expert judgment, calibrates model graders. Weaknesses: expensive, slow, requires experts at scale.
>
> ### Capability vs. regression evals
>
> **Capability or "quality" evals** ask, "What can this agent do well?" They should start at a low pass rate, targeting tasks the agent struggles with and giving teams a hill to climb.
>
> **Regression evals** ask, "Does the agent still handle all the tasks it used to?" and should have a nearly 100% pass rate. They protect against backsliding.
>
> After an agent is launched and optimized, capability evals with high pass rates can "graduate" to become a regression suite that is run continuously to catch any drift.
>
> ### Evaluating coding agents
>
> Deterministic graders are natural for coding agents because software is generally straightforward to evaluate: does the code run and do the tests pass? SWE-bench Verified and Terminal-Bench follow this approach. LLMs have progressed from 40% to >80% on SWE-bench in just one year.
>
> ### Evaluating conversational agents
>
> Success for conversational agents can be multidimensional: is the ticket resolved (state check), did it finish in <10 turns (transcript constraint), and was the tone appropriate (LLM rubric)? They often require a second LLM to simulate the user.
>
> ### Evaluating research agents
>
> Research quality can only be judged relative to the task. Combine groundedness checks (claims supported by sources), coverage checks (key facts included), and source quality checks (authoritative sources).
>
> ### Computer use agents
>
> Evaluation requires running the agent in a real or sandboxed environment and checking whether it achieved the intended outcome. WebArena tests browser-based tasks; OSWorld extends to full OS control.
>
> ### How to think about non-determinism
>
> *pass@k and pass^k diverge as trials increase*
> ![[anthropic-evals-agents-003.png]]
>
> pass@k and pass^k diverge as trials increase. At k=1, they're identical (both equal the per-trial success rate). By k=10, they tell opposite stories: pass@k approaches 100% while pass^k falls to 0%.
>
> ## Going from zero to one: a roadmap to great evals
>
> **Step 0. Start early** — 20-50 simple tasks drawn from real failures is a great start.
>
> **Step 1. Start with what you already test manually** — Convert user-reported failures into test cases.
>
> **Step 2: Write unambiguous tasks with reference solutions** — A good task is one where two domain experts would independently reach the same pass/fail verdict. A 0% pass rate across many trials (pass@100) is most often a signal of a broken task, not an incapable agent.
>
> **Step 3: Build balanced problem sets** — Test both cases where a behavior should occur and where it shouldn't. One-sided evals create one-sided optimization.
>
> **Step 4: Build a robust eval harness with a stable environment** — Each trial should start from a clean environment. Shared state between runs causes correlated failures.
>
> **Step 5: Design graders thoughtfully** — Grade what the agent produced, not the path it took. Build in partial credit for multi-component tasks.
>
> **Step 6: Check the transcripts** — When scores don't climb, you need confidence it's due to agent performance and not the eval.
>
> **Step 7: Monitor for capability eval saturation** — An eval at 100% tracks regressions but provides no signal for improvement.
>
> **Step 8: Keep evaluation suites healthy long-term** — Practice eval-driven development: build evals to define planned capabilities before agents can fulfill them, then iterate until the agent performs well.
>
> *The process of creating an effective evaluation*
> ![[anthropic-evals-agents-004.png]]
>
> ## How evals fit with other methods
>
> *Swiss cheese model for agent evaluation*
> ![[anthropic-evals-agents-005.png]]
>
> Like the Swiss Cheese Model from safety engineering, no single evaluation layer catches every issue. With multiple methods combined, failures that slip through one layer are caught by another.
>
> The most effective teams combine automated evals for fast iteration, production monitoring for ground truth, and periodic human review for calibration.
>
> ## Appendix: Eval frameworks
>
> - [Harbor](https://harborframework.com/) — containerized agent eval, standardized task/grader format, cloud-provider support
> - [Promptfoo](https://www.promptfoo.dev/) — lightweight declarative YAML config for prompt testing (used internally at Anthropic)
> - [Braintrust](https://www.braintrust.dev/) — offline eval + production observability + experiment tracking
> - [LangSmith](https://docs.langchain.com/langsmith/evaluation) — tracing + evals, tight LangChain integration
> - [Langfuse](https://langfuse.com/) — self-hosted open-source alternative for data residency requirements

[Original post](https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents)
