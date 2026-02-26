---
created: 2026-02-25
description: LangChain's deepagents-cli went from Top 30 to Top 5 on Terminal Bench 2.0 by iterating only on the harness — system prompt, tools, and middleware — while keeping the model (GPT-5.2-Codex) fixed.
source: https://x.com/Vtrivedy10/status/2023805578561060992
type: framework
---

# Harness engineering improved a coding agent 13 points by changing only system prompts tools and middleware

LangChain's deepagents-cli scored 52.8% on Terminal Bench 2.0 with default settings, then reached 66.5% — a 13.7-point improvement — by iterating exclusively on the harness. The model (GPT-5.2-Codex) stayed fixed throughout. This is a concrete demonstration of the same thesis behind [[agent-first engineering replaces coding with environment design scaffolding and feedback loops]]: the engineering work is in the environment, not the model.

## Key Takeaways

The harness has three optimization knobs: system prompt, tools, and middleware (hooks around model and tool calls). Compressing the design space to just these three made iteration tractable while covering the most impactful levers. This mirrors the broader shift from "make the model smarter" to "make the environment better" that's emerging across the agent ecosystem.

Self-verification is the single biggest improvement lever. The most common failure pattern was agents writing a solution, re-reading their own code, confirming it "looks ok," and stopping — without actually running tests. Adding a `PreCompletionChecklistMiddleware` that intercepts the agent before exit and forces a verification pass against the task spec dramatically improved outcomes. This is essentially a [[prompt caching is the foundational constraint for building long-running agents|Ralph Wiggum Loop]] — a hook that forces the agent to continue executing on exit for verification purposes.

Automated trace analysis creates a repeatable improvement loop analogous to boosting in ML. The recipe: (1) fetch experiment traces from LangSmith, (2) spawn parallel error analysis agents to synthesize findings, (3) aggregate feedback and make targeted harness changes. This focuses each iteration on mistakes from previous runs. A human in step 3 helps catch changes that overfit to specific tasks at the expense of generalization.

Context injection at startup reduces the error surface for agent onboarding. A `LocalContextMiddleware` runs on agent start to map the working directory, discover available tools (Python installations, etc.), and inject environment details. Agents are bad at context discovery and search in unseen environments — giving them this for free eliminates a class of avoidable errors.

Loop detection middleware tracks per-file edit counts and nudges agents to reconsider after N edits to the same file. Agents can be myopic once committed to a plan, making 10+ small variations to the same broken approach. The middleware injects "consider reconsidering your approach" — a design heuristic that works around current model limitations and will likely become unnecessary as models improve.

Reasoning budget allocation matters: a "reasoning sandwich" of xhigh-high-xhigh (heavy reasoning for planning and final verification, lighter for implementation) outperformed running at maximum reasoning throughout, which caused timeouts. Running only at xhigh scored 53.9% vs 63.6% at high, because agents ran out of time. The optimal split balances reasoning depth against time constraints.

Harnesses must be tailored per model. A test run with Claude Opus 4.6 scored 59.6% with the same harness optimized for Codex — competitive but lower, because the improvement loop hadn't been run for Claude. Many principles generalize (context preparation, verification focus), but per-model iteration yields the best results.

## External Resources

- [deepagents Python repo](https://github.com/langchain-ai/deepagents) — open-source coding agent
- [deepagents JavaScript repo](https://github.com/langchain-ai/deepagentsjs) — JS version
- [Terminal Bench 2.0 leaderboard](https://www.tbench.ai/leaderboard/terminal-bench/2.0) — the benchmark used
- [Harbor](https://harborframework.com/) — orchestration framework for benchmark runs
- [LangSmith trace dataset](https://smith.langchain.com/public/29393299-8f31-48bb-a949-5a1f5968a744/d?tab=2) — public traces from the experiments
- [Codex prompting guide](https://developers.openai.com/cookbook/examples/gpt-5/codex_prompting_guide/) — model-specific harness guidance
- [Agent observability powers evaluation (LangChain)](https://www.langchain.com/conceptual-guides/agent-observability-powers-agent-evaluation) — trace-based debugging methodology
- [RLMs for trace mining](https://alexzhang13.github.io/blog/2025/rlm/) — future direction for automated harness improvement

## Original Content

> [!quote]- Full thread from @Vtrivedy10 (Feb 17, 2026 — 1,170 likes, 113 RTs)
>
> **Improving Deep Agents with Harness Engineering**
>
> Our coding agent went from Top 30 to Top 5 on Terminal Bench 2.0. We only changed the harness. The goal of a harness is to mold the inherently spiky intelligence of a model for tasks we care about.
>
> **Recipe:** Use traces to understand failure modes at scale → spawn parallel error analysis agents → aggregate feedback → make targeted harness changes. Like boosting — focus on mistakes from previous runs.
>
> **Three knobs:** System prompt, tools, and middleware (hooks around model and tool calls).
>
> **Key improvements:**
> - Self-verification via PreCompletionChecklistMiddleware (Ralph Wiggum Loop)
> - LocalContextMiddleware for environment onboarding
> - LoopDetectionMiddleware for doom loop recovery
> - Reasoning budget sandwich: xhigh → high → xhigh
> - Time budget warnings for deadline-aware behavior
>
> **Results:** 52.8% → 66.5% on Terminal Bench 2.0 with GPT-5.2-Codex, model held fixed.
>
> Source: [Original tweet](https://x.com/Vtrivedy10/status/2023805578561060992)
