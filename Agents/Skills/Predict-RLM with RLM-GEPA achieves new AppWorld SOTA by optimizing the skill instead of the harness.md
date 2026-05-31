---
created: 2026-05-31
description: Gabriel Lespérance's Trampoline-AI shows that replacing AppWorld's hand-authored harness with a generic Predict-RLM interface and then applying RLM-GEPA skill optimization yields 94.0% TGC / 91.1% SGC — above both HALO's published optimized-harness results and the current public leaderboard high-water mark — while the unoptimized RLM baseline already beats both.
source: https://x.com/GabLesperance/status/2060754345247863075
type: learning
---

## Key Takeaways

- **The unoptimized RLM baseline already beats the previous SOTA, which suggests most harness complexity is not earning its keep.** PredictRLM(GPT-5.5 low) with no AppWorld-specific tuning reaches 0.917 TGC / 0.839 SGC, above HALO's published optimized result of 0.732 SGC for [[HALO uses an RLM to mine harness-shaped failures from agent execution traces and lift benchmarks 10-16 percentage points|HALO(Sonnet 4.6)]] and the public leaderboard's Qwen3-14B at 0.804 SGC — before any skill optimization has been applied. This aligns with [[The Mismanaged Geniuses Hypothesis argues the next AI leap comes from training LMs to decompose not from scaling|the mismanaged-genius hypothesis]]: planners, routers, and curated prompts are managing the model's genius rather than releasing it.
- **RLM-GEPA optimizes the skill (the SOP), not model weights or harness code.** The [[predict-RLM uses GEPA to recursively optimize agent skills reaching SpreadsheetBench top-5 as open source|RLM-GEPA]] optimizer reads execution traces and evaluator feedback, then rewrites the AppWorld skill instructions for future runs. The optimized artifact is only the skill; the held-out test rows evaluate that skill unchanged with the named executor. GEPA candidate 12 (val avg 0.9702, +7.9% over seed) was selected after 3,182 metric calls — [[GEPA prompt optimizer beats reinforcement learning with 35x fewer rollouts by reflecting on natural-language execution traces|far fewer rollouts than RL-based optimization methods would require]].
- **The tool surface is the key design decision: five generic discovery/caller tools replace thousands of lines of app-specific glue.** `list_appworld_apps`, `show_appworld_api_descriptions`, `show_appworld_api_doc`, `search_appworld_api_docs`, and `call_appworld_api` form the entire model-facing interface. The model discovers apps and APIs through documentation tools and calls a single generic API caller — mirroring [[Recursive Language Models pass context by reference through a Python REPL so subagent outputs return as variables instead of autoregressively regenerated tokens|RLMs' core pattern]] of exposing the environment instead of encoding it.
- **GEPA gains transferred well off the optimization split, which is the stronger signal.** The strongest optimized run reaches 94.0% / 91.1% on test_normal and 91.1% / 84.9% on test_challenge — splits that were held out during optimization. The public leaderboard Qwen3-14B entry drops from 80.4% SGC on test_normal to 50.4% SGC on test_challenge, suggesting overfitting; the RLM-GEPA runs show consistent performance across both splits.
- **RLMs represent a new unit of compute where LMs are the new CPU:** signatures are the IO definitions, tools are the new networking, and skills are the new programs (per author's follow-up reply). [[Quarq Labs frames GEPA and RLM as complementary context layers - GEPA optimizes static prompts before inference while RLM decomposes context at runtime|GEPA and RLM are complementary layers]] — GEPA evolves the static skill SOP offline, RLM executes model-authored control flow at runtime. Same task. Less harness.

## External Resources

- [predict-RLM (GitHub)](https://github.com/Trampoline-AI/predict-rlm) — Trampoline-AI's open-source Predict-RLM implementation; the AppWorld adapter and skill used in this post
- [RLM-GEPA (GitHub)](https://github.com/Trampoline-AI/predict-rlm/tree/main/src/rlm_gepa) — GEPA port over RLMs for skill optimization; runs on train split, selects on dev split
- [GEPA paper (arXiv:2507.19457)](https://arxiv.org/abs/2507.19457) — Agrawal et al.; the underlying reflective Genetic-Pareto prompt evolution algorithm
- [RLMs paper (arXiv:2512.24601)](https://arxiv.org/abs/2512.24601) — Zhang et al.; foundational Recursive Language Models architecture
- [Mismanaged-Genius Hypothesis (blog)](https://alexzhang13.github.io/blog/2026/mgh/) — Alex Zhang; the framing this post aligns with: scaffolds manage rather than release model capability
- [HALO AppWorld chart (GitHub)](https://github.com/context-labs/halo#appworld) — Context Labs; the closest prior conceptual reference, reports optimized HALO(Sonnet 4.6) SGC 0.732 on test_normal
- [Bitter Free Lunch post](https://x.com/lateinteraction/status/2043099113000931398?s=20) — related framing on task specification concentrated in skills

## Original Content

> [!quote]- Source Material
> **Going recursive (part I): Applying RLM-GEPA to AppWorld**
> @GabLesperance (Gabriel Lespérance) — Sat May 30, 2026
>
> > TL;DR Aligned with the [mismanaged-genius hypothesis](https://alexzhang13.github.io/blog/2026/mgh/), and inspired by the work of the people at Context Labs on [harness optimization with RLMs](https://github.com/context-labs/halo#appworld), we set out to test what lift we could get from running AppWorld through a simple generic [Predict-RLM](https://github.com/Trampoline-AI/predict-rlm) interface, and how far [RLM-GEPA](https://github.com/Trampoline-AI/predict-rlm/tree/main/src/rlm_gepa) could push performance on the same setup.
>
> On held-out test_normal, our strongest current unoptimized baseline reaches 0.917 TGC / 0.839 SGC with PredictRLM(GPT-5.5 low), above the current public AppWorld test_normal leaderboard high-water mark of 0.804 SGC;
>
> on test_challenge, the same unoptimized PredictRLM(GPT-5.5 low) run reaches 0.914 TGC / 0.820 SGC.
>
> AppWorld optimized RLM-GEPA lifts the strongest run to 0.940 TGC / 0.911 SGC on test_normal, a +2.3 pp TGC / +7.2 pp SGC gain,
>
> and on test_challenge reaches 0.911 TGC / 0.849 SGC, corresponding to a -0.3 pp TGC and +2.9 pp SGC change relative to the unoptimized baseline.
>
> ## 1. Motivation
>
> AppWorld is a benchmark for agents operating realistic app ecosystems: email, calendar, Spotify, Venmo, shopping, todo lists, etc. Tasks require changing state through a sequence of API calls, then submitting the final answer or completing the task.
>
> This makes AppWorld a natural place to test whether a generic RLM interface can operate against the existing benchmark environment and evaluator. Aligned with the [mismanaged-genius hypothesis](https://alexzhang13.github.io/blog/2026/mgh/), we set out to test what lift we could get from running AppWorld through a simple RLM interface, and how far we could push an optimized RLM on that same task.
>
> AppWorld agents often have exactly the shape the mismanaged-genius hypothesis calls out: planners, routers, API selection, direct function wrappers, recovery logic, and curated prompts. The question here is whether an RLM gives the model a better management interface: expose the environment, preserve the evaluator, let the LM express control flow in code with tools as functions, then optimize the resulting RLM skill with RLM-GEPA.
>
> Our view of RLMs is that they are a natural runtime for user-defined programs (skills) interpreted into model-defined control flow.
>
> Coupled with RLM-GEPA they represent a sort of [bitter free lunch(tm)](https://x.com/lateinteraction/status/2043099113000931398?s=20) where the task specification is concentrated in the skill as a standard operating procedure.
>
> Instead of encoding the agent loop as a pile of example-specific glue, expose a small set of tools, define a skill as a standard operating procedure, and let the model decide how to proceed.
>
> Same task. Less harness.
>
> ## 2. AppWorld as an RLM environment
>
> Our AppWorld adapter keeps AppWorld's task state and evaluator intact. The RLM only supplies the policy.
>
> The model-facing tool surface is intentionally small:
>
> ```python-repl
> list_appworld_apps()
> show_appworld_api_descriptions(app_name)
> show_appworld_api_doc(app_name, api_name)
> search_appworld_api_docs(query)
> call_appworld_api(app_name, api_name, kwargs)
> ```
>
> The model discovers available apps and APIs through documentation tools, then calls a single generic API caller:
>
> ```python-repl
> await call_appworld_api("spotify", "login",
>   {"username": "...", "password": "..."}
> )
> ```
>
> Completion is also adapted to the RLM interface. The model ends with SUBMIT(answer=value) for answer tasks or SUBMIT() for state-change-only tasks. Immediately before scoring, the host maps that into AppWorld's required supervisor.complete_task(...) call.
>
> ## 3. Metrics
>
> AppWorld reports two aggregate metrics:
>
> - TGC: Task Goal Completion, the case-level pass rate.
> - SGC: Scenario Goal Completion, the group-level pass rate.
>
> test_normal has 168 task cases grouped into 56 scenarios, with three cases per scenario. SGC is stricter: a scenario only passes if all of its cases pass.
>
> ```
> group A: 3/3 case passes -> contributes 3 TGC successes, SGC pass
> group B: 2/3 case passes -> contributes 2 TGC successes, SGC fail
> group C: 1/3 case passes -> contributes 1 TGC success,  SGC fail
> group D: 0/3 case passes -> contributes 0 TGC successes, SGC fail
> ```
>
> This matters because the public AppWorld leaderboard reports both TGC and SGC, and SGC is the stricter headline metric for scenario-level success.
>
> ## 4. Our unoptimized baselines
>
> Before optimizing anything with RLM-GEPA, we measured the RLM baseline across several executor families on full test_normal.
>
> The relevant headline is that PredictRLM(GPT-5.5) low already reaches
> 154 / 168 task cases, or 0.917 TGC / 0.839 SGC, before any AppWorld-specific skill tuning.
> PredictRLM(Sonnet 4.6) adaptive reaches 0.786 SGC under the same small documentation-plus-generic-caller interface.
>
> For the comparison that matters most, see the public leaderboard table in Section 6. For the full internal baseline sweep, including cost, errors, and timeouts, see Appendix A.
>
> ## 5. RLM-GEPA / optimization methodology
>
> We use [RLM-GEPA](https://github.com/Trampoline-AI/predict-rlm/tree/main/src/rlm_gepa) our port of [GEPA](https://arxiv.org/abs/2507.19457) (@LakshyAAAgrawal et al.) over [RLMs](https://arxiv.org/abs/2512.24601) (@a1zhang et al.) to optimize the AppWorld [predict-RLM](https://github.com/Trampoline-AI/predict-rlm) skill, not model weights. The optimizer runs on AppWorld's train split and selects candidates on the held-out dev split; test_normal and test_challenge are reserved for reporting. The proposer reads execution traces and evaluator feedback after each attempt, then rewrites the AppWorld skill instructions for future runs.
>
> The main optimized skill in the table was produced with a cheap gpt-5.4-mini proxy executor and sub-LM at low / no explicit reasoning effort, while the proposer was gpt-5.5 high with a gpt-5.5 high sub-LM. That run used minibatches of 30 examples, up to 3,000 metric calls, concurrency 10, task timeout 300s, proposer timeout 900s, merge proposer enabled, and selected candidate 12 with dev score 0.970 after 3,182 metric calls.
>
> We also ran a stronger-proxy optimization pass with gpt-5.4 low as both executor and sub-LM, again using gpt-5.5 high for the proposer and sub-LM. That run used the same minibatch size 30, concurrency 10, 300s task timeout, 900s proposer timeout, merge proposer, and a lower budget of 2,000 metric calls.
>
> In both cases, the optimized artifact is only the skill; the held-out rows below evaluate that skill unchanged with the named executor model.
>
> *GEPA candidate lineage: seed 0.8994 → best candidate 12 at 0.9702 (+7.9% on dev split) after 3,182 metric calls*
> ![[gablesperance-863075-001.jpg]]
>
> *Score vs. rollouts: optimization trajectory showing best-so-far (green) climbing from seed baseline (red dashed)*
> ![[gablesperance-863075-003.jpg]]
>
> ## 6. Public leaderboard comparison
>
> The natural comparison is the official AppWorld leaderboard, with special attention to optimized-harness work.
>
> Outside of the leaderboard, Context Labs' HALO is the closest conceptual reference point for this post: it explicitly studies harness optimization with RLMs on AppWorld, its [public AppWorld chart](https://github.com/context-labs/HALO#appworld) reports peak optimized test_normal SGC of 0.482 for HALO(Gemini 3 Flash) and 0.732 for HALO(Sonnet 4.6); the chart does not report TGC.
>
> The current public test_normal leaderboard high-water mark is Alibaba Cloud ApsaraLab AgentRL with Qwen3-14B at 0.869 TGC / 0.804 SGC. It reports an impressive (for a 14B module) 0.869 TGC / 0.804 SGC on test_normal, but drops to 0.676 TGC / 0.504 SGC on test_challenge, which suggests possible overfitting to the easier split.
>
> Our best unoptimized [predict-RLM](https://github.com/Trampoline-AI/predict-rlm) baseline is 0.917 TGC / 0.839 SGC with PredictRLM(GPT-5.5 low), and the strongest RLM-GEPA run reaches 0.940 TGC / 0.911 SGC.
>
> The unoptimized rows are initial [predict-RLM](https://github.com/Trampoline-AI/predict-rlm) baselines without RLM-GEPA optimization. We were surprised that this baseline already beat HALO's published optimized-harness AppWorld result for Sonnet 4.6 and the current public test_normal high-water mark.
>
> We were also encouraged by how well the RLM-GEPA gains transferred off the optimization split. The strongest current row in this table reaches 94.0% / 91.1% on test_normal and 91.1% / 84.9% on test_challenge with PredictRLMGEPA(GPT-5.5 low).
>
> *Full leaderboard comparison: predict-RLM unoptimized and RLM-GEPA optimized rows vs. prior published results*
> ![[gablesperance-863075-004.png]]
>
> ## 7. Why this matters
>
> A lot of agent work hides intelligence in the harness.
>
> The loop decides what to inspect. The planner decides what counts as a step. The router decides which API should be called. The wrapper shapes every tool call before the model sees it. This can work well, but it makes progress hard to interpret: did the model improve, or did the harness improve?
>
> RLMs push in the opposite direction.
>
> They make the execution trace explicit and let the model write the control flow inside a constrained runtime. The host still owns safety, state, tools, and scoring. But the policy is no longer a hand-authored loop pretending to be general intelligence.
>
> ## 8. What's next?
>
> AppWorld should be a favorable setting for RLMs: at its core, it is a function-calling benchmark. If the task is mostly choosing APIs, inspecting state, composing calls, and recovering from mistakes, an RLM should be a natural fit.
>
> In Part 2, we explore how well RLMs compete with harnesses on tasks that are more harness-friendly & less natural for RLMs: Terminal-Bench 2.1. The question there is whether the same pattern holds when the environment is a terminal and the incumbent baselines are more explicitly harness-engineered.
>
> If you want to try this yourself, check out [predict-RLM](https://github.com/Trampoline-AI/predict-rlm) on GitHub and give us a star
>
> Follow me for Part 2.
>
> with love from MTL
>
> ---
>
> ## Appendix: Full unoptimized baseline sweep
>
> These are our unoptimized [predict-RLM](https://github.com/Trampoline-AI/predict-rlm) AppWorld runs on full test_normal, before any AppWorld-specific RLM-GEPA skill tuning.
>
> *Full unoptimized baseline sweep: run configs, TGC/SGC, errors, timeouts, and cost per model*
> ![[gablesperance-863075-005.png]]
>
> ---
>
> **Thread replies:**
>
> @isaacbmiller1: awesome article!
> @GabLesperance: thank you!
>
> @ekzhu (Eric Zhu): The leaderboard is using Qwen3 14B fine-tuned. Maybe a better baseline is to use something simple harness and switch to GPT 5.5 (or Qwen 3.7-Max). It can probably already give you pretty strong numbers
> @GabLesperance: 100%. i was kinda disappointed the leaderboard didn't have newer models. that's why i'm going for terminal bench 2.1 next and why i thought the comparison to halo made more sense. a finetune from rlm traces would probably do very well
>
> @Markojak (Marko): Are the implications of this that we could consider this a new harness architecture where the static part is the tool registry, typed interfaces among some other things. All dynamic parts move into the outer and inner LM loops. Have you experimented more with model differentials for the inner/outer?
> @GabLesperance: Yeah. I think RLMs represent the inkling of a new unit of compute where LMs are the new CPU. Signatures are the IO definitions, tools are the new networking, and skills the new programs.
>
> [Original post](https://x.com/GabLesperance/status/2060754345247863075)
