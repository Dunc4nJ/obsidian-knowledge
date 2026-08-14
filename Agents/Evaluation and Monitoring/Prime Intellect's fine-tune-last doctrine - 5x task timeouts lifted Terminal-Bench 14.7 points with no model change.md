---
created: 2026-08-14
description: Hamel Husain's summary of Will Brown and Florian Brand's (Prime Intellect) session — fine-tuning is the LAST resort for improving an eval score. Work the ladder first: read traces → fix the eval and environment → improve retrieval/context/harness. The showstopper example: multiplying task timeouts by 5 on Terminal-Bench 2 lifted GPT-5.2 xhigh from 46.3% to 60.97% with zero model change. Includes the eval-infrastructure footgun list and the two-condition gate for when post-training is actually warranted.
source: https://hamel.dev/notes/llm/ai-product-engineering/systems-post-training.html
author: Hamel Husain (summarizing Will Brown & Florian Brand, Prime Intellect)
type: article
tags: [eval, post-training, fine-tuning, rl, harness, eval-infrastructure, terminal-bench, prime-intellect, ai-product-engineering, hamel]
---

## Key Takeaways

- **The doctrine: fine-tune last. The ladder: traces → eval/environment → retrieval/context/harness → model.** You can usually improve a score without touching the model, and the cheapest fixes are the most overlooked: the eval itself. The showstopper: **multiplying task timeouts by 5 on Terminal-Bench 2 raised GPT-5.2 xhigh from 46.3% to 60.97%** (+14.7pp; high went 52.8% → 60.67%) — no model change, no harness change, just an eval-infrastructure artifact removed. That number belongs beside [[data-eng-bench shows a data-native harness beats generic coding agents on dbt tasks at up to 3.9x lower cost with equal or better quality|data-eng-bench's harness effect]] and [[the harness is everything and agent performance comes from environment design not model capability]] as measured proof that scores are properties of the *system*, not the model.

- **The eval-infrastructure footgun list — each one silently caps scores.** Forcing temperature 0 on models trained to sample at 1 (hurts reproducibility *and* performance); max-token limits or turn caps truncating reasoning mid-flight; underpowered sandboxes (CPU/memory starvation reads as model failure); bloated bespoke-tool harnesses where minimal-harness-plus-bash wins; and concluding "the model can't do it" before adding task-specific skills to context. This is the practitioner checklist behind [[Terminal-Bench leaderboard requires five full runs with raw logs to enforce reproducibility over cherry-picked results|reproducibility-first leaderboards]] — most "model gaps" are environment gaps.

- **The two-condition gate for post-training, and the tooling when you pass it.** Only post-train when (1) correctness is *automatically verifiable* and (2) the model scores strictly between 0 and 100 on your eval (a floor of 0 gives RL no gradient; a ceiling of 100 gives it nothing to learn). Then: Prime Intellect's verifiers library defines task+reward in Python, hosted RL runs from a short config, and ready-made environments exist — the productized end of the [[rl environment creation is becoming a distributed marketplace that could 10x cost efficiency over contracting firms|RL-environment marketplace]] the vault tracks, from the team behind [[Prime Intellect duckdb-qa - RL reward shaping for SQL tool use]]. And the closing warning that frames the whole series: post-training needs an eval that rewards the right behavior, *because RL exploits anything less*.

## External Resources

- Original note: [Turn Eval Results Into a Better Model — Hamel Husain](https://hamel.dev/notes/llm/ai-product-engineering/systems-post-training.html) ([AI Product Engineering series](https://hamel.dev/notes/llm/ai-product-engineering/))
- [Full session](https://maven.com/p/7d699b) · [verifiers repo](https://github.com/PrimeIntellect-ai/verifiers) · [Prime Intellect hosted RL](https://docs.primeintellect.ai/guides/rl-training#hosted-training) · [environments hub](https://app.primeintellect.ai/dashboard/environments)

## Original Content

> [!quote]- Full note — "Turn Eval Results Into a Better Model" (Hamel Husain; session by Will Brown & Florian Brand, Prime Intellect)
> _This note covers Will Brown and Florian Brand’s session in the [AI Product Engineering series](../../../notes/llm/ai-product-engineering/index.html)._
>
> Will and Florian from [Prime Intellect](https://primeintellect.ai/) caution that fine-tuning should be the last approach for improving an eval score, because you can often improve a score without changing the model. They recommend working through the following items first:
>
> 1. Read the traces to understand what is failing.
> 2. Fix the eval and the environment.
> 3. Improve retrieval, context, and the harness.
>
> The second item might seem surprising, but small issues in the eval itself can be material. They show an example where multiplying task timeouts by 5 on Terminal-Bench 2 improved the score from 46.3% to 60.97%.
>
> ![[hamel-post-training-001.png]]
>
> They also shared common footguns toavoid when setting up eval infrastructure:
>
> * Beware of forcing temperature to 0 when the model was trained to sample at 1\. This might affect reproducibility on benchmarks.
> * Look for max token limits or turn caps that cut off reasoning early.
> * Give [the sandbox](../../../notes/llm/ai-product-engineering/systems-agent-sandboxes.html) enough CPU and memory.
> * Swap a bloated harness for a minimal one and let the model run bash instead of bespoke tools.
> * Add task-specific skills to the context before you conclude the model can’t do the task.
>
> Only explore post-training when two things are true: a correct answer can be verified automatically, and the model scores above 0 and below 100 on your eval.
>
> To try it, Prime Intellect’s [verifiers](https://github.com/PrimeIntellect-ai/verifiers) library defines the task and reward in Python, and their [hosted RL](https://docs.primeintellect.ai/guides/rl-training#hosted-training) runs the training from a short config file. Ready-made [environments](https://app.primeintellect.ai/dashboard/environments) are available to start from.
>
> Watch the [full session here](https://maven.com/p/7d699b).
