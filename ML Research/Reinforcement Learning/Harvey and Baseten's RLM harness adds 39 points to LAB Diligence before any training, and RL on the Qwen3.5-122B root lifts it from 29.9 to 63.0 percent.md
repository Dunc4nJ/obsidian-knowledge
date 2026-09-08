---
created: 2026-09-09
description: Harvey + Baseten (Grupen, J. Pereyra, G. Pereyra, O'Neill, Jayasekara, Ellis-Bloor, Liu, Blau) post a full update to the Tenet research preview's M&A diligence track. A recursive-language-model harness — dataroom in a Python REPL, root agent delegating bounded slices to sub-agents — lifts mean LAB Diligence rubric pass rate from 23.3% to 62.4% across seven models with no weight changes (+39.1 pp). RL on a Qwen3.5-122B-A10B root inside that harness takes 29.9% to 63.0% on 50 held-out datarooms; GLM-5.3 is scaling up now. Claude Code (Opus-5) at 24.6% and Codex (GPT-5.6 Sol) at 12.0% score below the same models in the plain tool loop.
source: https://x.com/nikogrupen/status/2097369705791307952
author: "Harvey and Baseten (Niko Grupen, Julio Pereyra, Gabe Pereyra, Charlie O'Neill, Mudith Jayasekara, Aaron Ellis-Bloor, Jonathon Liu, Matthew Blau)"
type: article
tags: [rl, post-training, rlm, harness-engineering, legal-agents, long-context, grpo, subagents, harvey, baseten, model-harness-fit, open-weights]
---

## Key Takeaways

- **The harness is worth 39 points before anyone touches a weight — the cleanest measurement of that claim the vault holds.** Swapping the standard tool-loop harness for an RLM harness raises mean rubric pass rate across **seven models from 23.3% to 62.4%**, a **+39.1 pp** gain with identical models and identical prompts. Per model (Figure 6): Claude Opus 5 42.5 → 77.6, Grok 4.5 22.8 → 68.4, GPT-5.6 Sol 16.6 → 67.7, GLM-5.2 15.1 → 65.4, Kimi K3 23.7 → 59.0, Muse Spark 1.1 27.0 → 56.5, DeepSeek V4 Flash 15.6 → 42.3. Every model gains, and the *smallest* gain (+26.7) still dwarfs most post-training results. This is [[harness engineering improved a coding agent 13 points by changing only system prompts tools and middleware|harness engineering]] and [[Prime Intellect's fine-tune-last doctrine - 5x task timeouts lifted Terminal-Bench 14.7 points with no model change|the fine-tune-last doctrine]] taken to their limit — and it is the ladder [[Mercor's SkyRL recipe post-trains a 397B on 1928 expert tasks for 70 percent relative Pass@1 - and spends Steps 1-3 de-risking before any real compute|SkyRL climbs in the same order]], harness fixes first, gradients last. The mechanism is [[Recursive Language Models pass context by reference through a Python REPL so subagent outputs return as variables instead of autoregressively regenerated tokens|passing context by reference]] (arXiv 2512.24601), the same construction the vault has as [[RLMs inline intelligence into data pipelines by giving LLMs symbolic access to DataFrames in a persistent REPL|symbolic access to data via a persistent REPL]].

- **Two frontier coding agents score *below* the plain tool loop on the same task — a general harness can be actively negative.** With web tools disabled and the same minimal instruction, **Claude Code with Opus-5 passes 24.6%** and **Codex with GPT-5.6 Sol passes 12.0%**, which is **17.9 and 4.6 points below the same models in the tool-loop harness**. Harvey read the traces: both "stop reading early and write shorter memos, and neither spawns sub-agents despite having the ability to." That is a measured, mechanism-level demonstration of [[Model-Harness-Fit means tool surfaces and citation tags are post-trained into the model, not interchangeable|Model-Harness-Fit]] — the delegation reflexes a coding agent was post-trained into do not fire on a 5,000-document dataroom, and having the *capability* to spawn sub-agents is not the same as having the *disposition* to. Contrast [[Anthropic's multi-agent Research system - orchestrator-worker subagents scale token spend past one context window for a 90 percent lift over single-agent Opus|Anthropic's orchestrator-worker result]], where explicit delegation prompting is what unlocked the gain.

- **Coordination is the scarce skill, and it is almost free in tokens — which is exactly why it is the right thing to train.** With Opus 5 orchestrating, the root consumes **3.8% of input tokens and 1.1% of output tokens**; the sub-agents do essentially all the reading. Yet swapping the **root** model moves mean room score by **~38 points**, while swapping the **sub-agent** model moves it **~8 points** (Figure 9). Post-training therefore targets the 1-4% of tokens that carry ~80% of the variance — the same bounded-worker-plus-orchestrator shape as [[Slate's thread-based episodic memory solves long-horizon agent tasks|Slate's thread-based episodic memory]] and [[Toast 1 takes over the search loop as a specialized subagent - 3.5x fewer tokens at identical Harvey-bench scores and OfficeQA SOTA at 1.15 dollars per task|Toast 1's specialized search subagent]], and it makes small fast sub-agents an infrastructure *advantage* rather than a compromise.

- **RL discovers dataroom coverage without being told to, and coverage is the variable that mediates the score.** GRPO on a **Qwen3.5-122B-A10B** root with rubric pass rate as the sole reward and fixed Qwen3.6-35B-A3B sub-agents: rollout pass rate **~23% → ~56% over 40 steps**, and the final checkpoint scores **63.0% against 29.9%** for the base on 50 held-out rooms. Mean coverage rises **62% → 96% even though coverage is not a reward term**; sub-agent calls per room go 842 → 1,379, and calls per delegating turn 57 → 109 (Table 2). For scale: in the tool-loop harness **no run reads more than 1% of the dataroom**. The outcome reward found exhaustive delegation on its own, which is the strongest available evidence for [[Daniel Ching's On Data II makes environment quality a verification problem - prompt-verifier bijectivity, realism, and ex post trace analysis|Ching's argument that a well-posed verifier does the design work]] — and the task's genuinely long horizon is the setting [[Charlie O'Neill's LONG REAL YOURS thesis - horizon length is the only thing RL generalises, and what you distil from matters more than how well you distil|O'Neill claims is the only thing RL generalises]], now tested by a team he is a co-author on. See also [[Daniel Ching's On Data I argues the post-training datapoint has become an executable environment not a corpus row|the environment-as-datapoint framing]].

- **This supersedes and materially corrects the M&A track in the Tenet preview — read the two together.** [[Harvey's Tenet post-trains Kimi K3 with GSPO in rubric-graded legal environments, doubling LAB hold-out completions while co-optimizing cost via reward shaping|The August preview]] reported "no baseline passing more than 43.8%", RLM+GLM-5.2 at 46.1%, and SFT at 60.1%. Three corrections land here: **43.8% was the best single baseline, not the norm** — the seven-model *mean* is 23.3% and Opus 5's tool-loop score is 42.5%; the **46.1% → 60.1% pair is a different, harder 20-room hold-out**, and the same GLM-5.2 base scores **65.4%** on the 50-room set used everywhere else; and the headline result is now **RL, not SFT**. Behaviorally, SFT mostly stabilized a policy already in the model (sub-agent-call-volume-vs-room-size correlation **0.17 → 0.84**, delegation volume +29%), while RL changed delegation volume more (**+64%**) and taught the root to write the memo incrementally instead of in one shot after all sub-agents return. **GLM-5.3 is training now** as root with the same GRPO config (LoRA on the root, group size 8, batch size 24), starting near 51% and reaching ~59% over 20 steps — training scores, not held-out.

- **Cost, depth, and the limits: more coverage usually costs more, deeper recursion hurts, and none of this is independently checkable.** RLM raises generation cost for **six of seven** models; **Claude Opus 5 is the exception — ~$18 per dataroom in the tool loop versus ~$7 as an RLM root, scoring 35 points higher**, because reading everything itself is more expensive than directing cheap sub-agents. Recursion depth-2 *lost* 19 pp across 14 rooms (improving 4, regressing 10; in four regressions the agent read the dataroom but never wrote the report), so all post-training used depth-1. The standing caveat: **this is Harvey evaluating Harvey's harness on Harvey's own synthetic benchmark, scored by an LLM judge against rubrics Harvey wrote.** LAB Diligence datarooms are not public, the judge is not disclosed here, and "criteria pass rate" is only as meaningful as the rubric — an outside reader cannot check the 571 criteria for Aravon Bridge Bank, cannot verify the judge's calibration (Harvey's own [[LangChain and Harvey show DeepSeek batch verifiers reduce legal agent evaluation costs by three orders of magnitude at acceptable accuracy|cheap-batch-verifier work]] is what makes judging hundreds of criteria affordable, and it trades accuracy for cost), and cannot separate harness gains from rubric-shaped gains. The coding-agent comparison is also run *by* the party whose harness wins. Note too the opposite architectural bet on the same benchmark family: [[Sentra matches Engram's studied 27B on Harvey's LAB benchmark with zero weight changes, arguing a materialized view is a stored answer and a weight has no address|Sentra matches a studied 27B on LAB with zero weight changes]]. And per [[vertical model advantage may not survive the next frontier release]], a 63.0% trained Qwen root sits below an *untrained* Opus 5 root at 77.6%.

## External Resources

- Original post: [Post-training RLM agents for end-to-end M&A Diligence — @nikogrupen (Harvey), 8 Sep 2026](https://x.com/nikogrupen/status/2097369705791307952) (X Article) · also at [harvey.ai/blog](https://www.harvey.ai/blog/post-training-rlm-agents-for-m-and-a-diligence)
- Direct predecessor: [Harvey Tenet research preview](https://www.harvey.ai/blog/post-training-update-harvey-tenet) — the post this one updates
- Method: [Recursive Language Models (arXiv 2512.24601)](https://arxiv.org/abs/2512.24601) — the RLM formulation, built with [Baseten](https://www.baseten.co/)
- Benchmarks: [LAB Diligence](https://www.harvey.ai/blog/legal-agent-bench-m-and-a-due-diligence) · [LAB (Legal Agent Bench)](https://www.harvey.ai/blog/introducing-harveys-legal-agent-benchmark) · [harvey-labs tool-loop harness (GitHub)](https://github.com/harveyai/harvey-labs)
- Compared harnesses: [Claude Code](https://claude.com/product/claude-code) (Opus-5) · [Codex](https://chatgpt.com/codex/) (GPT-5.6 Sol), both with web tools disabled

## Original Content

> [!quote]- Full X Article by @nikogrupen (Harvey), 8 Sep 2026 — "Post-training RLM agents for end-to-end M&A Diligence", with all 14 figures, 2 appendix figures and 2 tables
>
> @nikogrupen (Niko):
> Article: Post-training RLM agents for end-to-end M&A Diligence
>
> Article link: https://www.harvey.ai/blog/post-training-rlm-agents-for-m-and-a-diligence
>
> In our recent [research preview for Harvey Tenet](https://www.harvey.ai/blog/post-training-update-harvey-tenet), we highlighted the importance of model-harness co-optimization for solving complex, end-to-end legal tasks, and previewed initial results on M&A Diligence, where a single task requires traversing up to 80M tokens of document context. Today, we are sharing updated results from our continued experimentation.
>
> Together with Baseten, we built a [recursive language model ](https://arxiv.org/abs/2512.24601)(RLM) harness for M&A Diligence. In our RLM formulation, a complete dataroom is loaded into a Python REPL and a root agent delegates bounded review and analysis to sub-agents that work within their own context windows. On [LAB Diligence](https://www.harvey.ai/blog/legal-agent-bench-m-and-a-due-diligence) tasks, this harness improves rubric criteria pass rate by 39.1 percentage points on average across seven models that we evaluated.
>
> We find that post-training within the RLM harness yields further performance gains and options for navigating quality-efficiency trade-offs. We post-trained a Qwen3.5-122B-A10B orchestrator via reinforcement learning and found that post-training increased rubric criteria pass rate from 29.9% to 63.0% on 50 held-out LAB Diligence datarooms.
>
> *Figure 1: Mean criteria pass rate on LAB Diligence for base models in the standard tool-loop harness, coding agents in their own harnesses, and models in our RLM harness. Asterisks mark the matched GLM-5.2 results before and after SFT, evaluated on a separate 20-room hold-out set. All other results use the 50-room hold-out set.*
> ![[nikogrupen-307952-001.jpg]]
>
> These results suggest that post-training within a task-specific harness is a practical route for document-intensive legal work, like M&A Diligence, and that scaling RL within the RLM harness is a promising direction for future work. For this reason, we are also training GLM-5.3, a large frontier open weight model, as the root model in an ongoing scale-up run.
>
> In the rest of this post, we describe the LAB Diligence environments that we evaluated, our methodology, and post-training experiments in more detail.
>
> ## Environments for M&A Diligence
>
> We recently introduced [LAB Diligence](https://www.harvey.ai/blog/introducing-harveys-legal-agent-benchmark), an extension of [LAB](https://www.harvey.ai/blog/introducing-harveys-legal-agent-benchmark) that includes synthetic environments for M&A Diligence. A single data room in LAB Diligence contains up to 5,000 documents, organized across dozens of folders by category, and up to 80M tokens of total context.
>
> *Figure 2: An example LAB Diligence dataroom. Aravon Bridge Bank contains 2,270 documents in 82 folders across 14 categories, 31M tokens in total. The agent's diligence memo for this task is graded against 571 rubric criteria.*
> ![[nikogrupen-307952-002.jpg]]
>
> Working within this dataroom, the agent is tasked with producing a complete diligence memo, including its findings with document citations, quantified exposure where relevant, and recommended next steps for the transaction. An LLM judge scores the diligence memo against an expert rubric with hundreds of pass or fail criteria. The Aravon Bridge Bank example has 571 rubric criteria in total.
>
> *Figure 3: Rubric examples for the Aravon Bridge Bank task in LAB Diligence, with one verbatim criterion of each type.*
> ![[nikogrupen-307952-003.jpg]]
>
> The evidence needed for diligence is spread across the dataroom. Some findings require combining several documents, while others require checking whether supporting evidence is missing. In our baseline runs, agents searched and read selectively, leaving much of the dataroom unexamined. These tasks call for a harness that can distribute review across many bounded contexts and bring the findings together.
>
> ## An RLM Harness for M&A Diligence
>
> To establish a baseline, we started with the standard tool-loop harness from[ Legal Agent Bench](https://github.com/harveyai/harvey-labs). In this harness, base models pass 23.3% of rubric criteria on average across the 50 held-out datarooms, and no model passes every criterion on any dataroom.
>
> *Figure 4: Mean criteria pass rate in the standard tool-loop harness on the 50 held-out diligence datarooms.*
> ![[nikogrupen-307952-004.jpg]]
>
> These results suggest a mismatch between task and harness. A LAB Diligence dataroom is too large to fit within a single model context, but much of the initial review can be divided by category. The root can then combine findings across categories to produce the memo. Deal teams within law firms divide diligence work in a similar way.
>
> *Figure 5: The RLM harness at depth-1. The dataroom is loaded into a Python REPL as queryable variables. The root agent operates on it in code and delegates bounded reading tasks to subagents, which return their findings as REPL variables. Only the output the root agent prints enters its context window, so the root never holds the full dataroom.*
> ![[nikogrupen-307952-005.jpg]]
>
> This led us to explore RLMs as a harness for M&A Diligence. In an RLM harness, a root agent is given a Python REPL with the dataroom loaded as queryable variables, which lets it search the corpus programmatically. The root agent plans and scopes the review and dispatches sub-tasks to sub-agents. Each sub-agent receives a bounded slice of the corpus and instructions from the root agent, works within its own context window, and returns its findings as REPL variables. The experiments below use a single layer of sub-agents unless noted, and in practice the root dispatches many calls in parallel.
>
> *Figure 6: Mean criteria pass rate for seven models in the standard tool-loop harness and as the root of the RLM harness (depth-1, Qwen3.6-35B-A3B sub-agents), on the 50-room hold-out set.*
> ![[nikogrupen-307952-006.jpg]]
>
> | Model | Standard tool-loop harness | RLM harness |
> |---|---|---|
> | Claude Opus 5 | 42.5 | 77.6 |
> | Grok 4.5 | 22.8 | 68.4 |
> | GPT-5.6 Sol | 16.6 | 67.7 |
> | GLM-5.2 | 15.1 | 65.4 |
> | Kimi K3 | 23.7 | 59.0 |
> | Muse Spark 1.1 | 27.0 | 56.5 |
> | DeepSeek V4 Flash | 15.6 | 42.3 |
>
> (Values transcribed from Figure 6; criteria pass rate, %.)
>
> Across seven models, the RLM harness raises mean pass rate from 23.3% to 62.4%, a gain of 39.1 percentage points. We also ran two general-purpose coding agents with web tools disabled, [Claude Code](https://claude.com/product/claude-code) with Opus-5 and [Codex](https://chatgpt.com/codex/) with GPT-5.6 Sol, using the same minimal instruction as the tool-loop harness. Claude Code passes 24.6% of criteria and Codex 12.0%, below the same models in the tool-loop harness by 17.9 and 4.6 points, respectively. In the traces, both agents stop reading early and write shorter memos, and neither spawns sub-agents despite having the ability to.
>
> Coverage and Cost
>
> The RLM harness substantially increases the amount of useful content that becomes agent context. We estimate coverage with probes that measure the share of dataroom content reaching any model in the harness, root or sub-agent. In the standard tool-loop harness, no run reads more than 1% of the dataroom, and most read between 0.1% and 0.5%. In the RLM harness, nearly every run reads more than 10% of the dataroom and most read close to all of it. Higher coverage is associated with higher rubric criteria pass rates across this range.
>
> *Figure 7: Rubric criteria pass rate versus probe-based coverage, one point per run, for seven models in each harness on the 50 held-out data rooms from LAB Diligence. Coverage is on a log scale.*
> ![[nikogrupen-307952-007.jpg]]
>
> Moving to the RLM harness raises generation cost per dataroom for six of the seven baseline models, as shown in Figure 8. Claude Opus 5 is the exception. In the tool-loop harness it spends ~$18 per data room reading on its own; as an RLM root it spends ~$7 and scores 35 points higher.
>
> *Figure 8: Mean criteria pass rate versus generation cost per data room for seven models in each harness, averaged over 50 held-out data rooms. Dotted lines connect the same model across harnesses. Costs are cache-aware estimates at list prices, log scale.*
> ![[nikogrupen-307952-008.jpg]]
>
> Division of Labor
>
> To examine how much performance depends on the root agent vs. the sub-agents, we paired four root models with three Qwen sub-agent models on 30 held-out data rooms (see Figure 9). Across the configurations tested, changing the root had a larger effect. Holding the sub-agent model fixed while varying the root model, the gap between the highest- and lowest-scoring roots averaged about 38 percentage points. Holding the root fixed while varying the sub-agents, the corresponding gap between sub-agent models averaged about 8 points (Figure 9b).
>
> *Figure 9: Division of labor in the RLM harness, aggregated over four root models and three sub-agent models on 30 held-out datarooms. (a) Root share of input and output tokens, averaged over sub-agent choices. (b) The gap between the highest- and lowest-scoring roots, averaged over sub-agent choices, and the corresponding gap between sub-agents, averaged over roots.*
> ![[nikogrupen-307952-009.jpg]]
>
> | Root model | Root share of input tokens (%) | Root share of output tokens (%) |
> |---|---|---|
> | Opus 5 | 3.8 | 1.1 |
> | GLM-5.2 | 7.6 | 1.6 |
> | Kimi K3 | 12.5 | 2.1 |
> | Qwen3.5-122B-A10B | 37.0 | 37.8 |
>
> (Figure 9a transcribed. Figure 9b: swapping the root moves ~38 pts of mean room score; swapping the sub-agent ~8 pts.)
>
> This difference is notable because, in the RLM harness, we observe the root accounting for a minority of the agent’s total token usage. With Opus 5 orchestrating, for example, the root accounts for 3.8% of input tokens and 1.1% of output tokens (see Figure 9a). The sub-agents process most of the text, while the root decides how to divide the review and assemble the findings.
>
> *Figure 10: Mean criteria pass rate for four root models paired with three sub-agent models, on 30 held-out data rooms.*
> ![[nikogrupen-307952-010.jpg]]
>
> | Root | Qwen3.6-35B-A3B sub-agents | Qwen3.5-122B-A10B sub-agents | Qwen3.5-397B-A17B sub-agents |
> |---|---|---|---|
> | Opus 5 | ~78.0 | ~82.5 | ~81.5 |
> | GLM-5.2 | ~61.5 | ~75.0 | ~71.0 |
> | Kimi K3 | ~60.0 | ~66.0 | ~64.5 |
> | Qwen3.5-122B-A10B | ~39.0 | ~47.0 | ~43.5 |
>
> (Values read off Figure 10; mean criteria pass rate, %. Approximate — the figure is unlabelled.)
>
> These results suggest that improving coordination is an important opportunity in this setup, so we focused our initial post-training experiments on the root.
>
> ## Post-Training in the RLM Harness
>
> The results above point to the root agent as a target for post-training. In this section, we report results from post-training open-weight root models inside the RLM harness.
>
> Self-Distillation SFT
>
> First, we post-trained a GLM-5.2 root using rejection-sampling self-distillation SFT. This experiment uses a different 20-room hold-out evaluation set from the 50-room evaluations reported elsewhere. Its matched base-model score on this hold-out is 46.1%, below the 65.4% GLM-5.2 result reported in Figure 6 over the larger hold-out set.
>
> Base GLM-5.2 does not stably execute a high-scoring policy out of the box – there are frequent performance collapses where the base model, acting as root agent, gives up early, under-delegates, or fails to convert the subagent outputs into a strong deliverable. Given that a strong policy is already within the model’s distribution but needs to be made more robust, we use rejection-sampling self-distillation to sharpen GLM-5.2’s distribution onto the desired mode. We selected successful GLM-5.2 runs with high dataroom coverage and fine-tuned the root on those trajectories.
>
> *Figure 11: GLM-5.2 as the RLM root before and after rejection-sampling self-distillation SFT, evaluated on a separate 20-room hold-out set. These are matched results within the SFT experiment, not the 50-room evaluation used in Figure 6.*
> ![[nikogrupen-307952-011.png]]
>
> On this 20-dataroom hold-out set, the SFT-trained root scores 60.1% against 46.1% for the base model (see Figure 11). A review of the post-trained agent’s traces suggests that training helps the root agent comprehensively review the dataroom and carry a larger percentage of sub-agent findings into the final memo.
>
> Table 1 summarizes other behavioral changes we observe after post-training. Most notably, the correlation between sub-agent call volume and dataroom size rises from 0.17 to 0.84, indicating that the trained root agent scales its delegation to the size of the dataroom. The trained root also learns to begin writing the memo while sub-agents are still reading, similar to what we found in our RL runs.
>
> *Table 1: Behavior of the GLM-5.2 root before and after SFT, averaged over the separate 20-room hold-out set. Coverage is a percentage; the final row is a correlation coefficient.*
> ![[nikogrupen-307952-012.jpg]]
>
> | | GLM-5.2 (base) | GLM-5.2 (SFT) |
> |---|---|---|
> | Mean document coverage | 89 | **93** |
> | Mean sub-agent-call volume per room | 708 | **914** |
> | Sub-agent-call volume vs. room size (corr.) | 0.17 | **0.84** |
>
> The behaviors that make a strong root diligence agent, like exhaustive delegation, are learnable from a relatively small number of on-policy traces, with no privileged information and no labeled legal knowledge. Here, self-distillation is effective because good behavior already exists in the model’s distribution and training stabilizes it.
>
> This experiment motivated us to explore RL-based post-training as an attempt to push the model beyond what is within its distribution, eliciting new behavior directly through the task’s reward.
>
> Reinforcement learning
>
> For reinforcement learning we started with a smaller root model, Qwen3.5-122B-A10B, to keep the initial RL experiment loop tractable.
>
> We trained the RLM root with GRPO, using the judged rubric criteria pass rate as the reward and holding the sub-agent models fixed (sub-agents were each Qwen3.6-35B-A3B model). Over 40 training steps, we found that the mean rollout pass rate rose from about 23% to about 56%. On the 50-room hold-out set, the final checkpoint scores 63.0% against 29.9% for the base model.
>
> *Figure 12: Reinforcement learning on the Qwen3.5-122B-A10B root with fixed Qwen3.6-35B-A3B sub-agents. (a) Mean rollout criteria pass rate at each of 40 training steps. (b) Base model and final checkpoint on the 50-room hold-out set.*
> ![[nikogrupen-307952-013.jpg]]
>
> After RL, mean data room coverage rises from 62% to 96%, even though coverage is not an explicit reward term. Base runs are spread across the full coverage range, with a cluster below 20% that scores near zero. Every RL-trained run reads more than 60% of the data room and most read all of it.
>
> *Figure 13: Criteria pass rate versus probe-based coverage, one point per run, for the Qwen3.5-122B-A10B root before and after RL on the 50-room hold-out set.*
> ![[nikogrupen-307952-014.jpg]]
>
> The post-trained root makes 64% more sub-agent calls per dataroom. RL also changed delegation volume more than SFT did, 64% against 29%.
>
> *Table 2: Behavior of the Qwen3.5-122B-A10B root before and after RL, averaged over the 50-room hold-out set.*
> ![[nikogrupen-307952-015.jpg]]
>
> | | Qwen3.5-122B-A10B (base) | Qwen3.5-122B-A10B (RL) |
> |---|---|---|
> | Mean document coverage | 62 | **96** |
> | Mean sub-agent-call volume per room | 842 | **1,379** |
> | Sub-agent calls per delegating turn | 57 | **109** |
>
> Before post-training, the Qwen root agent attempted to write its diligence memo in a single shot and only after all of the sub-agents return. During RL post-training, it learns a more efficient approach, writing the memo incrementally and interleaving section writing with the review of sub-agent work.
>
> Scaling RL with GLM-5.3
>
> To test our RL recipe at scale, we are now training GLM-5.3 as the RLM root with the same GRPO-style configuration: judged criteria pass rate as the reward, Qwen3.6-35B-A3B sub-agents held fixed, LoRA on the root, group size 8 and batch size 24. GLM-5.3 rollouts start well above where the Qwen root started, so there is less headroom. Over steps 0 to 20 (Figure 14), mean rollout pass rate rises from about 51% to about 59%, averaged over the first and last eight steps shown, with the step-to-step noise expected at this batch size.
>
> *Figure 14: Early training progress for the ongoing GLM-5.3 RL run, with Qwen3.6-35B-A3B sub-agents held fixed. Mean rollout criteria pass rate is shown over the course of 20 training steps. Grey shows raw per-step values; black shows an exponential moving average. This figure reports training scores, not held-out performance.*
> ![[nikogrupen-307952-016.jpg]]
>
> ## What’s Next
>
> The RLM harness improves performance across the models we tested, and RL produces further gains for the Qwen root within that harness. There is still a substantial gap between these scores and the near-perfect pass rates we are working toward.
>
> The training experiments detailed above are initial explorations. In addition to completing the scaled up GLM-5.3 training run, we will also explore combinations of SFT and RL, and trained sub-agents. The RLM harness separates the root's orchestration from the sub-agents' reading, so each can be trained on its own or jointly, including setups in which sub-agents are trained to delegate in turn.
>
> Finally, the core finding here, that model-harness co-optimization can meaningfully improve agent performance in long-horizon environments, is not specific to diligence. We are exploring ways to map the same harness structure and training approach to other long-context legal work.
>
> ## Appendix
>
> RLM Recursion Depth
>
> We also tested whether adding another layer of delegation improves performance. At depth-1, sub-agents return plain LLM completions, with no tools or delegation of their own. At depth-2, sub-agents receive a Python REPL and can delegate further. Within each experiment, we used the same model for the root and every sub-agent.
>
> We evaluated both GLM-5.2 and Qwen3.5-122B-A10B. Many GLM-5.2 depth-2 runs did not finish within the time limit, so we report the Qwen results below. Across 14 datarooms, depth-2 improved scores on four and reduced them on ten, lowering mean criteria pass rate by 19 percentage points (Figure A2). In four of the ten regressions, the depth-2 agent read dataroom content but never produced a report.
>
> *Figure A1: Per-room criteria pass rate at depth-1 and depth-2 for 14 datarooms. We held the model fixed and compared plain-completion sub-agents with sub-agents that could use a REPL and delegate.. In four of the ten regressions, the depth-2 run reads the dataroom but never writes the report.*
> ![[nikogrupen-307952-017.jpg]]
>
> These results motivated our use of depth-1 for the initial post-training experiments. Whether training agents specifically for deeper delegation can make additional layers useful remains an open question.
>
> RL Infrastructure
>
> RL, especially with such long episode lengths, is as much an infrastructure problem as a training signal problem. For this task, single-episode rollouts could take on the order of an hour or more of wall-clock to complete. To optimize the training wall-clock time, we applied methods like asynchronous off-policy inference, continuous inference batching, oversampling, and in-flight weight updates. Selective token masking and async-related caps were applied to control the effect of off-policyness. Given that in the RLM harness most of the wall-clock is spent waiting for subagents to complete, the ability to use small fast subagents helped to greatly speed up the RL training process.
>
> We plot step wall-clock time below. It is dominated by rollout time which grows over the course of RL as the agent becomes more thorough and sends out larger waves of subagents.
>
> *Figure A2: Wall-clock minutes per RL training step for the 40-step run, with a 5-step rolling mean. Steps 2–10 average 48 minutes and steps 31–40 average 74 minutes; the increase comes from the trained model dispatching more sub-agents per rollout.*
> ![[nikogrupen-307952-018.jpg]]
> date: Tue Sep 08 17:01:19 +0000 2026
> url: https://x.com/nikogrupen/status/2097369705791307952
> likes: 96  retweets: 11  replies: 8
>

*Capture note: in the X Article the Figure 9 and Figure 10 images are attached in swapped order relative to their own captions (the harvey.ai version pairs them correctly). Above, each image is placed with the caption that matches its actual content. Figure 6, Figure 9a, Figure 10, Table 1 and Table 2 are images in the source; their values are transcribed into markdown tables alongside each embed. The X Article's body text is identical to the harvey.ai post except that X writes "dataroom" where the blog writes "data room" in several places, and the X plain text omits the figure captions.*

### Substantive reply

> **@Overfit_Dicta (Overfitting Dicta)** — 8 Sep 2026 ([link](https://x.com/Overfit_Dicta/status/2097379942199967833))
>
> This is a cool approach!
>
> Instead of embedding a multimillion-token dataroom and relying on vector retrieval, running a swarm of specialized agents over the original documents feels significantly more scalable... especially if the dataroom isn't static.
>
> Are RL-trained agent swarms the death of RAG? The catch is that RL training requires institutional amounts of compute.
