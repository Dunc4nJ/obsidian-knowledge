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

> [!quote]- Source
>
> @Vtrivedy10 (Viv):
> 📰 Improving Deep Agents with Harness Engineering
>
> TLDR: Our coding agent went from Top 30 to Top 5 on [Terminal Bench 2.0](https://www.tbench.ai/leaderboard/terminal-bench/2.0).  We only changed the harness. Here’s our approach to harness engineering (teaser: self-verification & tracing help a lot).
>
> # The Goal of Harness Engineering
>
> The goal of a harness is to mold the inherently spiky intelligence of a model for tasks we care about. Harness Engineering is about systems, you’re building tooling around the model to optimize goals like task performance, token efficiency, latency, etc.  Design decisions include the system prompt, tool choice, and execution flow.
>
> But how should you change the harness to improve your agent?
>
> At LangChain, we use [Traces](https://docs.langchain.com/langsmith/observability-quickstart) to understand agent failure modes at scale.  Models today are largely black-boxes, their inner mechanisms are hard to interpret. But we can see their inputs and outputs in text space which we then use in our improvement loops.
>
> We used a simple recipe to iteratively improve [deepagents-cli](https://docs.langchain.com/oss/python/deepagents/cli/overview) (our coding agent) 13.7 points from 52.8 to 66.5 on Terminal Bench 2.0.  We only tweaked the harness and kept the model fixed, gpt-5.2-codex.
>
> ## Experiment Setup & The Knobs on a Harness
>
> We used [Terminal Bench 2.0](https://www.tbench.ai/), a now standard benchmark to evaluate agentic coding.  It has 89 tasks across domains like machine learning, debugging, and biology.  We use [Harbor](https://harborframework.com/) to orchestrate the runs.  It spins up sandboxes ([Daytona](https://www.daytona.io/)), interacts with our agent loop, and runs verification + scoring.
>
> Every agent action is stored in [LangSmith](https://smith.langchain.com/). It also includes metrics like latency, token counts, and costs.
>
> ## The Knobs we can Turn
>
> An agent harness has a lot of knobs: system prompts, tools, hooks/middleware, skills, sub-agent delegation, memory systems, and more. We deliberately compress the optimization space and focus on three: System Prompt, Tools, and [Middleware](https://docs.langchain.com/oss/python/langchain/middleware/overview#the-agent-loop) (our term for hooks around model and tool calls).
>
> We start with a default prompt and standard tools+middleware.  This scores 52.8% with GPT-5.2-Codex.  A solid score, just outside the Top 30 of the leaderboard today, but room to grow.
>
> ## The Trace Analyzer Skill
>
> We wanted trace analysis to be repeatable, so we made it into an Agent Skill.  This became our recipe to analyze errors across runs and make improvements to the harness. The flow is:
>
> 1. Fetch experiment traces from LangSmith
>
> 2. Spawn parallel error analysis agents → main agent synthesizes findings + suggestions
>
> 3. Aggregate feedback and make targeted changes to the harness.
>
> This works similarly to [boosting](https://en.wikipedia.org/wiki/Boosting_(machine_learning)) which focuses on mistakes from previous runs. A human can be pretty helpful in Step 3 (though not required) to verify and discuss proposed changes.  Changes that overfit to a task are bad for generalization and can lead to regressions in other Tasks.
>
> Automated trace analysis saves hours of time and made it easy to quickly try experiments.  We’ll be publishing this skill soon, we’re currently testing it for prompt optimization generally.
>
> # What Actually Improved Agent Performance
>
> Automated Trace analysis allowed us to [debug where agents were going wrong](https://www.langchain.com/conceptual-guides/agent-observability-powers-agent-evaluation).  Issues included reasoning errors, not following task instructions, missing testing and verification, running out of time, etc.  We go into these improvements in more details in the sections below.
>
> ## Build & Self-Verify
>
> Today’s models are exceptional self-improvement machines.
>
> Self-verification allows agents to self-improve via feedback within a run. However, they don’t have a natural tendency to enter this build-verify loop.
>
> The most common failure pattern was that the agent wrote a solution, re-read its own code, confirmed it looks ok, and stopped.  Testing is a key part of autonomous agentic coding.  It helps test for overall correctness and simultaneously gives agents signal to hill-climb against.
>
> We added guidance to the system prompt on how to approach problem solving.
>
> 1. Planning & Discovery: Read the task, scan the codebase, and build an initial plan based on the task specification and how to verify the solution.
>
> 2. Build: Implement the plan with verification in mind.  Build tests, if they don’t exist and test both happy paths and edge cases.
>
> 3. Verify: Run tests, read the full output, compare against what was asked (not against your own code).
>
> 4. Fix: Analyze any errors, revisit the original spec, and fix issues.
>
> We really focus on testing because it powers the changes in every iteration.  We found that alongside prompting, deterministic context injection helps agents verify their work.  We use a PreCompletionChecklistMiddleware that intercepts the agent before it exits and reminds it to run a verification pass against the Task spec.  This is similar to a [Ralph Wiggum Loop](https://ghuntley.com/loop/) where a hook forces the agent to continue executing on exit, we use this for verification.
>
> ## Giving Agents Context about their Environment
>
> Part of harness engineering is building a good delivery mechanism for context engineering. Terminal Bench tasks come with directory structures, built-in tooling, and strict timeouts.
>
> 1. Directory Context & Tooling: A LocalContextMiddleware runs on agent start to map the cwd and other parent+children directories.  We run bash commands to find tools like Python installations. Context discovery and search are error prone, so injecting context reduces this error surface and helps onboard the agent into its environment.
>
> 2. Teaching Agents to Write Testable Code: Agents don’t know how their code needs to be testable. We add prompting say their work will be measured against programatic tests, similar to when committing code.  For example, Task specs that mention file paths should be followed exactly so the solutions works in an automated scoring step.  Prompting that stresses edge-cases helps the agent avoid only checking “happy path” cases.  Forcing models to conform to testing standards is a powerful strategy to avoid “slop buildup” over time.
>
> 3. Time Budgeting: We inject time budget warnings to nudge the agent to finish work and shift to verification.  Agents are famously bad at time estimation so this heuristic helps in this environment.  Real world coding usually doesn’t have strict time limits, but without adding any knowledge of constraints, agents won’t work within time bounds.
>
> The more that agents know about their environment, constraints, and evaluation criteria, the better they can autonomously self-direct their work.
>
> The purpose of the harness engineer: prepare and deliver context so agents can autonomously complete work.
>
> ## Encouraging Agents to Step Back & Reconsider Plans
>
> Agents can be myopic once they’ve decided on a plan which results in “doom loops” that make small variations to the same broken approach (10+ times in some traces).
>
> We use a LoopDetectionMiddleware that tracks per-file edit counts via tool call hooks.  It adds context like “…consider reconsidering your approach” after N edits to the same file.  This can help agents recover from doom loops, though the model can continue down the same path if it thinks it’s correct.
>
> Important note.  This is a design heuristic that engineers around today’s perceived model issues.  As models improve, these guardrails will likely be unnecessary, but today helps agents execute correctly and autonomously.
>
> ## Choosing How Much Compute to Spend on Reasoning
>
> Reasoning models can run autonomously for hours so we have to decide how much compute to spend on every subtask.  You can use the max reasoning budget on every task, but most work can benefit from optimizing reasoning compute spend.
>
> Terminal Bench timeout limits create a tradeoff.  More reasoning helps agents evaluate each step, but can burn over 2x more tokens/time.  gpt-5.2-codex has 4 reasoning modes, low, medium, high, and xhigh.
>
> We found that reasoning helps with planning to fully understand the problem, some Terminal Bench tasks are very difficult.  A good plan helps get to a working solution more quickly.
>
> Later stage verification also benefits from more reasoning to catch mistakes and get a solution submitted. As a heuristic, we choose a xhigh-high-xhigh "reasoning sandwich" as a baseline.
>
> Running only at xhigh scored poorly at 53.9% due to agent timeouts compared to 63.6% at high. There weren’t large differences in trial runs across reasoning budget splits so we stuck with our approach which pushed the score to 66.5%.
>
> The natural approach for models is Adaptive Reasoning, seen with [Claude](https://platform.claude.com/docs/en/build-with-claude/adaptive-thinking) and [Gemini](https://ai.google.dev/gemini-api/docs/thinking) models where the model decides how much compute to spend on reasoning.
>
> In a multi-model harness, balancing reasoning budgets could play out as using a large model for planning and [handing off](https://docs.langchain.com/oss/python/langchain/multi-agent/handoffs) to a smaller model for implementation.
>
> ## Practical Takeaways for Building Agent Harnesses
>
> The design space of agents is big.  Here are some general principles from our experiments and building deepagents overall.
>
> 1. Context Engineering on Behalf of Agents. Context assembly is still difficult for agents today, especially in unseen environments.  Onboarding models with context like directory structures, available tools, coding best practices, and problem solving strategies helps reduce the error surface for poor search and avoidable errors in planning.
>
> 2. Help agents self-verify their work. Models are biased towards their first plausible solution. Prompt them aggressively to verify their work by running tests and refining solutions.  This is especially important in autonomous coding systems that don’t have humans in the loop.
>
> 3. Tracing as a feedback signal. Traces allow agents to self-evaluate and debug themselves.  It’s important to debug tooling and reasoning together (ex: models go down wrong paths because they lack a tool or instructions how to do something).
>
> 4. Detect and fix bad patterns in the short term. Models today aren’t perfect.  The job of the harness designer is to design around today’s shortcomings while planning for smarter models in the future.  Blind retries and not verifying work are good examples.  These guardrails will almost surely dissolve over time, but to build robust agent applications today, they’re useful tools to experiment with.
>
> 5. Tailor Harnesses to Models.  The [Codex](https://developers.openai.com/cookbook/examples/gpt-5/codex_prompting_guide/) and [Claude](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices) prompting guides show that models require different prompting.  A test run with Claude Opus 4.6 scored 59.6% with an earlier harness version, competitive but worse than Codex because we didn’t run the same Improvement Loop with Claude.  Many principles generalize like good context preparation and a focus on verification, but running a few rounds of harness iterations for your task helps maximize agent performance across tasks.
>
> There’s more open research to do in harness design.  Interesting avenues include multi-model systems (Codex, Gemini, and Claude together), memory primitives for continual learning so agents can autonomously improve on tasks, and measuring harness changes across models.
>
> For the outer loop of improving agents, we’re looking at methods like [RLMs](https://alexzhang13.github.io/blog/2025/rlm/) to more efficiently mine traces.  We’ll be continuing work to improve the harness and openly share our research.
>
> We created a [dataset of our Traces](https://smith.langchain.com/public/29393299-8f31-48bb-a949-5a1f5968a744/d?tab=2) to share with the community.
>
> Deep Agents is open source.  [Python](https://github.com/langchain-ai/deepagents) and [Javascript](https://github.com/langchain-ai/deepagentsjs).
>
> To more hill climbing and open research.
> 📅 Tue Feb 17 17:03:45 +0000 2026
> 🔗 https://x.com/Vtrivedy10/status/2023805578561060992
> ──────────────────────────────────────────────────
>
> @inflectivAI (Inflectiv AI ⧉):
> @Vtrivedy10 Damn, jumping from Top 30 to Top 5 just by engineering the harness? That’s seriously impressive work. Self-verification, smart middleware, and trace-driven iteration paying off huge. Love seeing this level of craft in the agent space. Keep crushing it🔥
> 📅 Tue Feb 17 17:50:45 +0000 2026
> 🔗 https://x.com/inflectivAI/status/2023817409313075654
> ──────────────────────────────────────────────────
>
> @tunahorse21 (tuna🍣):
> @Vtrivedy10 wow an article that has actual alfa https://t.co/iK9CP0fTTQ
> ![[HBYNgjIXoAAzZdH.jpg]]
> 📅 Tue Feb 17 18:00:49 +0000 2026
> 🔗 https://x.com/tunahorse21/status/2023819940852359462
> ──────────────────────────────────────────────────
>
> @Vtrivedy10 (Viv):
> @tunahorse21 alpha is all free here 🫡
> 📅 Tue Feb 17 18:08:50 +0000 2026
> 🔗 https://x.com/Vtrivedy10/status/2023821961059828207
> ──────────────────────────────────────────────────
>
> @Vtrivedy10 (Viv):
> @inflectivAI tyty more open research coming 🫡
> 📅 Tue Feb 17 18:11:10 +0000 2026
> 🔗 https://x.com/Vtrivedy10/status/2023822544403578900
> ──────────────────────────────────────────────────
>
> @usespeedread (Speed Read (App in bio!)):
> @Vtrivedy10 https://t.co/HwoxXeC2fe
> ![[b2GysY7j43RINmf8.jpg]]
> 📅 Tue Feb 17 18:13:35 +0000 2026
> 🔗 https://x.com/usespeedread/status/2023823152434790714
> ──────────────────────────────────────────────────
>
> @Vtrivedy10 (Viv):
> @usespeedread woah what this is cool!
> 📅 Tue Feb 17 18:26:28 +0000 2026
> 🔗 https://x.com/Vtrivedy10/status/2023826398100820239
> ──────────────────────────────────────────────────
>
> @mohanp_ai (Mohan Prakash):
> Interesting read  Self-verification loop, context injection, doom loop detection. These are practical patterns that actually work.
> Gaps: 
> |1) Overfitting risk - you optimized on Terminal Bench but does this harness generalize to real-world coding? 2) No ablation study - which change contributed most to the 13.7 point gain? Was it verification? Context injection? Loop detection?
>  3) The 'reasoning sandwich' feels like guesswork without data showing why that split is optimal."
> 📅 Tue Feb 17 19:36:33 +0000 2026
> 🔗 https://x.com/mohanp_ai/status/2023844035027497191
> ──────────────────────────────────────────────────
>
> @Vtrivedy10 (Viv):
> would love for you to try the deepagents-cli and let us know!  We use these methods in our sync coding, they’re probably even more valuable in async settings which is what terminal bench tests for more
>
> there’s things that transfer out of benchmarks like SWE-bench, tb2, etc which are generally problem solving principles and control flow for agents
>
> If you had to pick 2, self verify and inject context, these are good general principles.  Worth testing other changes on your real use cases but would recommend starting there
> 📅 Tue Feb 17 19:42:52 +0000 2026
> 🔗 https://x.com/Vtrivedy10/status/2023845622147690951
> ──────────────────────────────────────────────────
>
> @phinance99 (David Sweet):
> @Vtrivedy10 Suggestion: Add code complexity metrics as feedback. Keeping the code simple makes it easier for the LLM's to extend &amp; maintain it.
>
> Try: cargo install kiss-ai
> 📅 Tue Feb 17 20:04:22 +0000 2026
> 🔗 https://x.com/phinance99/status/2023851035715137807
> ──────────────────────────────────────────────────
>
> @Vtrivedy10 (Viv):
> @phinance99 interesting!  are these like pre-configured prompts and lint rules?
> 📅 Tue Feb 17 20:44:54 +0000 2026
> 🔗 https://x.com/Vtrivedy10/status/2023861234299535819
> ──────────────────────────────────────────────────
>
> @nitishkulki (Nitish Kulkarni):
> Great suggestions! One of the trickiest aspects of this is a forward looking harness design - avoiding over engineering for the limitations of the models today. Self verification loops are probably one of the best approaches in that regard since the number of iterations the models will make will naturally reduce over time.
> 📅 Tue Feb 17 22:15:18 +0000 2026
> 🔗 https://x.com/nitishkulki/status/2023883982627291341
> ──────────────────────────────────────────────────
>
> @richardscheiwe (Richard Scheiwe):
> Great research and work. Open source for the win :)
>
> The LoopDetectionMiddleware is a nice touch. How do you feel about extending middleware to periodically assess token/cost impact? I get nervous about using API keys with long-running agentic experiences due to over-extending the cost.
> 📅 Wed Feb 18 01:42:26 +0000 2026
> 🔗 https://x.com/richardscheiwe/status/2023936109755969875
> ──────────────────────────────────────────────────
>
> @AstasiaMyers (Astasia Myers):
> @Vtrivedy10 Great piece!
> 📅 Wed Feb 18 01:48:43 +0000 2026
> 🔗 https://x.com/AstasiaMyers/status/2023937692367823169
> ──────────────────────────────────────────────────
>
> @Vtrivedy10 (Viv):
> @AstasiaMyers ty!! 
> always fun writing (and chatting) about coding agents &amp; harnesses, added bonus that they’re en vogue :)
> 📅 Wed Feb 18 01:51:35 +0000 2026
> 🔗 https://x.com/Vtrivedy10/status/2023938412739207189
> ──────────────────────────────────────────────────
>
> @Vtrivedy10 (Viv):
> Yeah makes sense
>
> I’m in favor of having that option for users, deepagents makes it pretty easy to build with middleware, we get tokens in/out so a user can cut off the model after a certain spend on a task if they’d like
>
> LangSmith tracing also gives all of this data to review later, we dig into these token and latency metrics often
> 📅 Wed Feb 18 03:01:38 +0000 2026
> 🔗 https://x.com/Vtrivedy10/status/2023956041214353507
> ──────────────────────────────────────────────────
>
> @Vtrivedy10 (Viv):
> @nitishkulki yeah agree, harness design will evolve to help the peculiarities of the next gen model intelligence.  Self verification is a primitive that I’d bet will be pretty timeless
> 📅 Wed Feb 18 03:02:49 +0000 2026
> 🔗 https://x.com/Vtrivedy10/status/2023956341388144855
> ──────────────────────────────────────────────────
>
> @owengretzinger (owen):
> @Vtrivedy10 interested to see that skill :)
> 📅 Wed Feb 18 12:35:58 +0000 2026
> 🔗 https://x.com/owengretzinger/status/2024100579652284821
> ──────────────────────────────────────────────────
>
> @Vtrivedy10 (Viv):
> @owengretzinger dropping soon, DMing you back!
> 📅 Wed Feb 18 14:07:01 +0000 2026
> 🔗 https://x.com/Vtrivedy10/status/2024123493541970163
> ──────────────────────────────────────────────────
>
> @farhanhelmycode (Farhan Helmy):
> @Vtrivedy10 can't wait for RLM integration with Langchain / Deepagents
> 📅 Wed Feb 18 15:11:16 +0000 2026
> 🔗 https://x.com/farhanhelmycode/status/2024139659446747381
> ──────────────────────────────────────────────────
>
> @Vtrivedy10 (Viv):
> @farhanhelmycode very top of mind, will hopefully have some bandwidth across the team in the next weeks to get something worthwhile out
>
> there’s a great use case for us which is mining trace data (which can be massive) via RLMs, but need to test!
> 📅 Wed Feb 18 15:20:36 +0000 2026
> 🔗 https://x.com/Vtrivedy10/status/2024142009787691372
> ──────────────────────────────────────────────────
>
> @xdotli (Xiangyi Li):
> @Vtrivedy10 Do you maybe want to do a hackathon with us on skills?
> 📅 Wed Feb 18 15:24:11 +0000 2026
> 🔗 https://x.com/xdotli/status/2024142909453353173
> ──────────────────────────────────────────────────
>
> @Vtrivedy10 (Viv):
> @xdotli awesome work with SkillsBench!  we’ve taken a quick look at it internally
>
> I’ll DM you!
> 📅 Wed Feb 18 15:39:21 +0000 2026
> 🔗 https://x.com/Vtrivedy10/status/2024146729411444805
> ──────────────────────────────────────────────────
>
> @dhasandev (danialhasan):
> @Vtrivedy10 great writeup! thakns for open sourcing the trace dataset
> 📅 Wed Feb 18 21:23:48 +0000 2026
> 🔗 https://x.com/dhasandev/status/2024233411674534299
> ──────────────────────────────────────────────────
>
> @Vtrivedy10 (Viv):
> @dhasandev tyty! sure thing we’ll prob do this more!
> 📅 Wed Feb 18 21:28:38 +0000 2026
> 🔗 https://x.com/Vtrivedy10/status/2024234630040203511
> ──────────────────────────────────────────────────

