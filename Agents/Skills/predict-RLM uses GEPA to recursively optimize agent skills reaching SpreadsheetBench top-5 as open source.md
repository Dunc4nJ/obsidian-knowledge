---
created: 2026-04-26
description: Trampoline's predict-RLM uses GEPA prompt optimization so one RLM recursively improves another's skill instructions, achieving SpreadsheetBench Verified top-5 (0.8925 hard) as the only open-source solution in that tier.
source: https://x.com/GabLesperance/status/2048072367876735415
type: framework
---

## Key Takeaways

- The RLM-GEPA loop replaces the standard GEPA proposer with a predict-RLM that reads full execution traces rather than lossy summaries, letting the proposer reason programmatically over millions of tokens of evidence — this is the same architecture optimizing itself recursively, directly extending the [[RLMs inline intelligence into data pipelines by giving LLMs symbolic access to DataFrames in a persistent REPL|predict-RLM framework]] from data pipelines into skill evolution.
- Better operating instructions beat more reasoning effort: higher reasoning tiers (high, xhigh) plateaued or even degraded on SpreadsheetBench because failures were at the tool interface (openpyxl quirks, formula conventions), not reasoning capacity — a concrete validation of [[The Mismanaged Geniuses Hypothesis argues the next AI leap comes from training LMs to decompose not from scaling|the Mismanaged Geniuses Hypothesis]] that models are bottlenecked by elicitation, not capability.
- The evolved skill transfers upward unchanged: optimized by watching gpt-5.4-mini fail, it lifts gpt-5.4-medium from 0.7950 to 0.8500 hard (27% error reduction) and gpt-5.5-medium to 0.8925 hard at flat per-task cost — the skill captures domain/tool knowledge, not weak-model crutches, paralleling [[EvoSkill discovers reusable agent skills through iterative failure analysis outperforming static prompts and transferring zero-shot|EvoSkill's zero-shot transfer finding]] and [[memento-skills turns executable skill folders into evolving non-parametric memory that lets frozen LLMs learn continuously from deployment|memento-skills' weight-free learning]] but with a recursive proposer.
- Skills as first-class optimizable artifacts (instruction bundle + packages + tools) make the optimization loop clean: GEPA reads traces, finds recurring mistakes, rewrites the skill, runs again — the optimization cost is paid once and amortized across all downstream executors, unlike per-inference reasoning scaling.
- The [[praxlab generalizes autoresearch into a multi-task harness that ran 550 experiments with zero intervention|praxlab autoresearch pattern]] and [[CORAL multi-agent co-evolution beats OpenEvolve by 20% on Anthropic's kernel engineering task|CORAL co-evolution]] both use GEPA-style loops; this work narrows the scope to a single RLM-to-RLM channel and shows that even that minimal recursive setup produces top-5 benchmark results on a practical knowledge-worker task.

## External Resources

- [predict-RLM on GitHub](https://github.com/trampoline-ai/predict-rlm) — MIT-licensed production port of Recursive Language Models with integrated predict() sub-tool and DSPy signatures
- [Recursive Language Models paper (arXiv:2512.24601)](https://arxiv.org/abs/2512.24601) — Zhang et al. foundational RLM paper
- [GEPA paper (arXiv:2507.19457)](https://arxiv.org/abs/2507.19457) — Lakshya Agrawal et al. structured reflection for prompt optimization
- [SpreadsheetBench](https://spreadsheetbench.github.io/) — 912-task benchmark of real-world spreadsheet manipulation from Excel forum questions
- [Mismanaged Geniuses Hypothesis](https://alexzhang13.github.io/blog/2026/mgh/) — Zhang's thesis that frontier models are capability-sufficient but elicitation-bottlenecked
- [OpenAI curated spreadsheet skill](https://raw.githubusercontent.com/openai/skills/e6afb0d74cc75d220df2faf3dd6c635c2dc6a108/skills/.curated/spreadsheet/SKILL.md) — seed baseline skill adapted for predict-RLM

## Original Content

> @GabLesperance — 2026-04-25
>
> *X Article: RLM ♥ GEPA: You can use RLMs to improve RLMs with GEPA*
>
> *Cover image*
> ![[gablesperance-735415-001.jpg]]
>
> **TL;DR** We adapt GEPA so a [predict-RLM](https://github.com/trampoline-ai/predict-rlm) improves another predict-RLM. 
>
> On our held-out 400-task [SpreadsheetBench](https://spreadsheetbench.github.io/) Verified eval, *RLM_gpt-5.5-medium* reaches **0.8925 hard**, which would tie the current public #3 under the same protocol; *RLM_gpt-5.4-medium* reaches **0.8500 hard**, which would land at #5. 
>
> That is a 23% and 27% hard-error reduction over their respective unoptimized seed baselines.
>
> That would make our predict-RLM ♥ GEPA optimized skill the **only open-source solution in SpreadsheetBench Verified top-5 territory.** 
>
> The optimized skill is [available on GitHub today](https://github.com/trampoline-ai/predict-rlm).
>
> ---
>
> *Candidate lineage*
> ![[gablesperance-735415-002.jpg]]
>
> [Recursive Language Models](https://arxiv.org/abs/2512.24601) (@a1zhang et al.) traces are large: a single eval batch can easily exceed 10M tokens. [GEPA](https://arxiv.org/abs/2507.19457) (@LakshyAAAgrawal et al.) optimizes prompts through structured reflection: a proposer LM reads execution outcomes, identifies failure patterns, and rewrites the prompt. 
>
> Stock GEPA's proposer sees a compact rendered summary of each task; by wiring a predict-RLM as the proposer, we expose the ***full trace corpus*** and let the proposer read, filter, and distill it programmatically, thereby letting the model ***reason over the full execution evidence rather than a lossy summary***.
>
> Same tool stack, same iteration protocol, applied recursively. 
> *The learner and the learned share both architecture and tool stack.*
>
> We apply this pattern to SpreadsheetBench, using *gpt-5.4-mini* as a cheap RLM executor to keep optimization costs low. The evolved skill transfers upward to frontier executors unchanged. On the verified 400-task test set, it lifts *gpt-5.4-medium* from a seed of *0.8750* soft / *0.7950* hard to *0.9259* / *0.8500* — closing 41% of the remaining soft-score error.
>
> The evolved skill and model capabilities compound: *gpt-5.5-medium* with our optimized skill strictly outperforms *gpt-5.4-medium* with the same optimized skill, suggesting that we capture model-agnostic gains that stack with stronger executors rather than constraining them.
>
> ## 1. Motivation
>
> Our work aligns with @a1zhang's [Mismanaged Geniuses Hypothesis (MGH)](https://alexzhang13.github.io/blog/2026/mgh/): frontier models already contain the capability needed for deep reasoning, but are bottlenecked by how we elicit, structure, and compose that capability.
>
> We test how far this intuition stretches on tasks directly applicable to the day-to-day work of millions of knowledge workers: spreadsheet manipulation.
>
> Our prior work on [predict-RLM](https://github.com/Trampoline-AI/predict-rlm), a production-focused port of RLMs with an integrated *predict()* sub-tool, *DSPy signatures* for *inputs/outputs/tools*, and fully interpretable trajectories, formed the base architecture of this bet. 
>
> Here, we ask the empirical question: ***how far can a simple predict-RLM be pushed against SOTA and specialized agents on SpreadsheetBench purely by managing the model better, rather than swapping the model?***
>
> To answer this, we pair RLMs with GEPA prompt optimization, and replace the standard proposer with an RLM: an RLM proposer reads, filters, and distills another RLM's execution traces, then proposes improved prompts for the next iteration. 
>
> The same architecture optimizes itself: one RLM improves another RLM without updating model weights. We improve an RLM without updating model weights, by using another RLM.
>
> ## 2. SpreadsheetBench
>
> SpreadsheetBench (Ma et al., 2024) is a benchmark of 912 real-world spreadsheet manipulation tasks derived from Excel forum questions. Each task provides a natural-language instruction, spreadsheet files, and golden outputs used for exact-match evaluation.
>
> The benchmark reports two metrics:
> - **Soft score** = partial credit for passing some test cases.
> - **Hard score** = full credit only when all test cases pass.
>
> We use the ***SpreadsheetBench Verified 400-task subset*** as a held-out test set and never expose it to the optimizer. From the remaining 512 tasks, we construct disjoint train and validation splits for RLM-GEPA: train examples generate traces and prompt proposals, while validation examples are used for candidate selection.
>
> Because the optimization pool is the non-Verified remainder of the benchmark, we treat Verified performance as held-out transfer from a noisier, less curated training distribution rather than as in-distribution tuning.
>
> ## 3. Skill as a First-Class Artifact
>
> Predict-RLM instances can optionally be accompanied by a *skill* — a bundle of *(instructions, pypi_packages, tools)* describing a domain. 
>
> When present, skills are merged automatically: instructions are concatenated, packages are loaded, and tools are exposed alongside predict() in the sandbox.
>
> For our seed baseline skill instructions, we adapt OpenAI's [curated spreadsheet skill](https://raw.githubusercontent.com/openai/skills/e6afb0d74cc75d220df2faf3dd6c635c2dc6a108/skills/.curated/spreadsheet/SKILL.md) with minimal changes. 
>
> This skill + RLM combination is our seed baseline. The skill is also the target of GEPA optimization.
>
> ## 4. Baselines
>
> Before optimization, we measured the seed baseline (§3) across reasoning-effort tiers on the full 400-task testset.
>
> *Seed skill + RLM(model) baselines*
> ![[gablesperance-735415-003.jpg]]
>
> We measured higher reasoning tiers (*high*, *xhigh*) but omit them from the main table because they demonstrate a plateau: more thinking does not seem to readily improve performance on this workload. On seed, *gpt-5.4-xhigh* actually scores slightly lower than low, albeit within the noise: 0.8698 soft, with 312 all-pass tasks.
>
> Importantly, the plateau is the signal. Higher reasoning effort did not buy us much. In some settings it even made things worse, because many remaining failures were not about solving the spreadsheet task in the abstract; they were about operating the spreadsheet environment correctly.
>
> This is MGH made concrete. The model had enough reasoning capacity to solve many more of these tasks, but kept losing points at the interface: openpyxl quirks, sandbox behavior, formula-prefix conventions, type coercion rules, workbook mutation semantics, and instruction interpretation.
>
> More thinking is a blunt tool for that. Better operating instructions are sharper.
>
> That is what the skill is. GEPA turns the skill from a hand-written prompt into an optimized artifact: read traces, find recurring mistakes, rewrite the instructions, run again. Same model family, same tools, better management.
>
> ## 5. Results
>
> *Seed skill vs. RLM♥GEPA optimized skill on the held-out 400-task SpreadsheetBench Verified set. Error reduction is measured against remaining error, e.g. hard error = 1 − hard score*
> ![[gablesperance-735415-004.jpg]]
>
> The table is the story: the optimized skill improves every executor setting we measured.
>
> The strongest final result is *RLM_gpt-5.5-medium* + *optimized skill*: **0.9411 soft / 0.8925 hard**, or **357 / 400 all-pass**. Relative to seed, that closes 31% of the remaining soft error and 23% of the remaining hard error.
>
> The largest lift is *RLM_gpt-5.4-medium*: **0.8750 / 0.7950 → 0.9259 / 0.8500**, or **318 → 340** all-pass. That is a 41% soft-error reduction and a 27% hard-error reduction at roughly flat per-task cost.
>
> Two things matter.
>
> First: transfer. The skill was evolved by watching *gpt-5.4-mini* fail, then deployed unchanged on stronger executors. That suggests the traces captured domain/tool knowledge — spreadsheet conventions, openpyxl pitfalls, formula handling, task interpretation — not weak-model crutches.
>
> Second: cost. Per-task cost stays basically flat, from −8% to +7% depending on the executor. The gain is not from simply buying more inference at deployment. It comes from a better skill; the optimization cost is paid once and amortized downstream.
>
> The thinking ceiling persists. Higher reasoning tiers did not reliably beat medium. *gpt-5.5-high*, not shown in the table, scored lower than *gpt-5.5-medium* while costing ~40% more. For this workload, medium was the practical ceiling in our runs. Better operating instructions beat more thinking.
>
> Same model family. Same tools. Same executor architecture. Better management.
>
> ## 6. What's next?
>
> I do not think SpreadsheetBench is unique. My intuition is that we can apply this RLM♥GEPA approach to many more problems and many more benchmarks.
>
> **The loop is simple: cheap executor RLM produces readable traces → proposer RLM distills them into a skill patch → stronger executor RLM runs again.**
>
> [predict-RLM](https://github.com/trampoline-ai/predict-rlm) is on GitHub, MIT licensed. The optimized SpreadsheetBench skill is available now. 
>
> The RLM♥GEPA adapter is next in the coming days.
>
> Like, star, & follow for more ;-)
>
> with ♥ from MTL
>
> Engagement: 225 likes | 21 retweets | 350 bookmarks | 16.4K views
> [Original post](https://x.com/GabLesperance/status/2048072367876735415)
