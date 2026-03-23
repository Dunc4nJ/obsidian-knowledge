---
created: 2026-03-23
description: PRISM shows that mid-training with ~27B high-quality tokens densely restructures model weights to build reasoning capability, while RL makes sparse surgical refinements on top — skipping mid-training leaves 3-4x gains on the table.
source: https://x.com/bharatrunwal2/status/2035366328517980195
type: paper
---

## Key Takeaways

The PRISM study systematically answers what mid-training actually does to LLMs at the weight and representation level, not just on benchmarks. Across 7 models, 4 families, and 3B-24B parameters (including dense Transformers and attention-Mamba hybrids), mid-training with ~27B high-quality tokens delivers +15-40 points on math, +5-12 on code, and +6-13 on expert science — without degrading general capabilities. This connects to the broader pattern explored in [[twenty-six papers capture ninety percent of the alpha behind modern LLMs from attention through reasoning and mixture of experts]] where the training pipeline stages each serve distinct mechanistic roles.

The most striking finding is how fundamentally different mid-training and RL are at the weight level. Mid-training changes over 90% of parameters by more than 1% (L2 divergence ~0.175), while RL touches only ~5% of parameters (L2 divergence ~0.0003). CKA similarity between mid-trained and RL'd models exceeds 0.998 in every case — RL is not rewriting the geometry mid-training built, it is making precision refinements within it. This mechanistic view explains why skipping mid-training and going straight to RL yields near-zero AIME scores: RL cannot create reasoning capability, only amplify what already exists.

Data composition at mid-training is the single biggest lever. Including science data during mid-training unlocks +17 to +28 points on GPQA-Diamond when RL is applied later, even though the RL data mix never changes. Changing the RL data mix produces less than 2 points of difference. The capability is seeded during mid-training, not during RL. This resonates with the insight from [[RL environments are the new unit of progress in agentic AI training]] — the quality of the foundation matters more than the optimization signal applied on top.

The long-context trade-off is real but recoverable. Mid-training at 8k context degrades RULER@128k from 59 to 6, but a brief long-context extension phase plus a linear model merge (15% base + 85% mid-trained) recovers it to 42 while preserving reasoning gains. This has practical implications for the [[rl environment creation is becoming a distributed marketplace that could 10x cost efficiency over contracting firms]] vision — environment designers need to account for what context length the model was mid-trained at.

RL is front-loaded and targeted: most weight change happens in the first 200-400 steps then stabilizes, with V and O projections changing most (5.6-8.5%) while Mamba structural parameters (A matrix, dt) stay completely frozen. This surgical precision is consistent with concurrent findings that in-distribution training drives RL sparsity.

## External Resources

- [PRISM Paper](https://arxiv.org/abs/2503.xxxxx) — full paper on mid-training retention and interaction analysis
- [PRISM Website](https://t.co/cZKor1qqKA) — project page with models and datasets (coming soon)
- [HuggingFace Models](https://t.co/XrtHX450Mw) — open-source mid-trained models and datasets

## Original Content

> @bharatrunwal2 (Bharat) — 2026-03-21
>
> Introducing PRISM: Demystifying Retention and Interaction in Mid-Training
>
> The modern LLM training pipeline has evolved beyond just pre-training + alignment. State-of-the-art models now insert a critical middle stage  "mid-training"  where targeted, high-quality data mixtures build reasoning foundations before RL. Yet despite its growing adoption, the field lacks a principled understanding of what actually drives its effectiveness.
>
> — What data should you use?
> — When in the pipeline should you mid-train?
> — How does it interact with downstream RL?
> — Does it generalize across architectures and scales?
> — And beyond benchmarks: what do these stages actually do to the model at the weight and representation level?
>
> These questions don't have clear answers in the literature at scale : and the cost of getting them wrong is significant.
>
> PRISM is our systematic attempt to answer all of these. Using ~27B high-quality tokens, we run controlled experiments across 7 models · 4 families · 3B–24B parameters, spanning both dense Transformers and attention-Mamba hybrids, measuring what mid-training actually does: to performance, to weights, to representations, and to downstream RL.
>
> *PRISM overview*
> ![[bharatrunwal2-980195-001.jpg]]
>
> ---
>
> Mid-training works. Across every model we tested.
>
> Using only ~27B high-quality tokens:
>
> +15–40 pts on math (all 7 models)
> +5–12 pts on code (all 7 models)
> +6–13 pts on expert science/GPQA-Diamond
>
> General performance is preserved across the board. We explicitly track MMLU, ARC, HellaSwag. These are additive gains, not trade-offs.
>
> And this holds for both dense Transformers and attention-Mamba hybrids. Architecture doesn't change the story.
>
> *Mid-training performance gains across all 7 models*
> ![[bharatrunwal2-980195-002.png]]
>
> ---
>
> The single biggest lever in mid-training design is Data Composition.
>
> We ablated math-only, math+code, and math+code+science mixtures across models. The pattern is consistent:
>
> Math only → large math gains, science stays near base
> Math+Code → math and code gains, science still near base
> Math+Code+Science → best overall, and the one that transforms GPQA-Diamond during RL
>
> Including science at mid-training unlocks +17 to +28 points on GPQA-Diamond when you add RL later, even if the RL data mix never changes. The capability is seeded at mid-training, not at RL.
>
> Changing the RL mix? Less than 2 point difference. The Data composition decisions belong at mid-training.
>
> *Data composition ablation results*
> ![[bharatrunwal2-980195-003.jpg]]
>
> ---
>
> What happens when you skip mid-training and go straight to RL?
>
> AIME scores stay near zero for most base models. GPQA-Diamond can regress (Llama/Mistral 7B).
>
> PRISM → RL: macro-avg across 6 benchmarks goes from under 12 to 29–42. A 3–4× improvement.
> Base → RL: ~37 pts lower on math, ~14 pts lower on code.
>
> RL does not create reasoning capability. It amplifies what is already there. Mid-training builds that foundation.
>
> *PRISM+RL vs Base+RL comparison*
> ![[bharatrunwal2-980195-004.jpg]]
>
> ---
>
> When should you mid-train?
>
> We tested this on Granite-4 Micro: before vs. after long-context pretraining.
>
> Mid-training after long-context pretraining gives the largest gains in math, code, and science while preserving general reasoning. Mid-training at 8k context degrades long-context ability, but this can be largely restored via a brief extension phase combined with model merging.
>
> This also points to a broader principle: reasoning data for math, code, and especially long-CoT traces or agentic workflows tends to be long. A model needs sufficient context representation before it can fully absorb this data during mid-training. We did not test agentic traces in this work, but the same logic applies.
>
> We only tested the timing question on Granite-4 Micro, so we are careful not to over-generalize. But practically: most open-source base models today are already released after long-context extension, so if you are starting from LLaMA-3.1, Mistral, Granite-3.3, or Nemotron-H, you are likely already at the right entry point.
>
> *Mid-training timing: before vs after long-context pretraining*
> ![[bharatrunwal2-980195-005.png]]
>
> ---
>
> The long-context trade-off and how to fix it
>
> Mid-training at 8k context has a real cost: it degrades long-context abilities.
>
> For Granite-3.3, RULER@128k drops sharply from 59.09 (base) to just 6.46 after mid-training. Short-context reasoning improves significantly, but long-context retrieval takes a hit.
>
> The good news: this is largely recoverable.
>
> A brief long-context extension phase after mid-training raises RULER@128k back to 38.41. Adding a linear model merge first (15% base + 85% mid-trained) before extension recovers it further to 42.16  while preserving the downstream reasoning gains.
>
> *Long-context recovery via extension and model merging*
> ![[bharatrunwal2-980195-006.jpg]]
>
> ---
>
> The mechanism behind the pipeline (MT restructure while RL refines)
>
> We did not just measure what the pipeline does. We analyzed how it works at the weight level.
>
> Mid-training densely restructures the model. For Granite-3.3, over 90% of all parameters change by more than 1%. For Nemotron-H hybrid, over 95%. L2 divergence from base is 0.175, a full reshaping of the weight space.
>
> Importantly, data composition determines the capabilities encoded, not the amount of change, MC and MCS mid-training produce nearly identical weight magnitudes but steer the model in different directions (cosine similarity 0.52–0.62).
>
> RL does something completely different. Only ~5% of parameters change. L2 divergence is 0.0003. Consistent with concurrent findings by Mukherjee et al., who show that in-distribution training drives RL sparsity while out-of-distribution RL produces dense updates, we extend this across architectures and jointly with mid-training.
>
> Crucially, RL's weight footprint is independent of the starting point. Whether RL starts from a mid-trained model or directly from base, the magnitude and sparsity of its updates are nearly identical,  what changes is the quality of the outcome.
>
> Mid-training sculpts the full weight landscape. RL makes precision refinements within it.
>
> *Weight-level analysis: mid-training vs RL parameter changes*
> ![[bharatrunwal2-980195-007.jpg]]
>
> ---
>
> Does RL overwrite what mid-training built?
>
> We measured CKA (representational similarity) layer by layer across Granite-3.3, LLaMA-3.1, and Nemotron-H on three input types: Wikipedia, C4 web text, and GSM8K math problems.
>
> MT vs RL similarity: above 0.998 in every single case. Dense and hybrid. General text and math.
>
> Concurrent work finds that mid-trained models require smaller representational shifts during fine-tuning, consistent with the view that mid-training creates a stable foundation for downstream adaptation. We show the same holds for RL, where even the final layer, the most restructured by mid-training, is preserved almost completely (CKA >0.998).
>
> RL is not rewriting mid-training's geometry. It is operating within it, making surgical behavioral refinements on top. This is why the ordering is not arbitrary,  it reflects how the two operations mechanistically relate to each other.
>
> *CKA similarity across layers: MT vs RL*
> ![[bharatrunwal2-980195-008.jpg]]
>
> ---
>
> RL is front-loaded and targeted
>
> Two things stand out when you watch RL train step by step:
>
> - It is front-loaded. Most weight change happens in the first 200–400 steps, then stabilizes.
>
> - It is targeted. V and O projections change most (5.6–8.5%). Mamba's structural parameters (A matrix, dt) stay completely frozen throughout. The active parameter set : parameters changing by more than 1% , starts at just 1.5% at step 20 and grows to ~5% as training progresses, then locks in.
>
> RL is not a uniform update. It progressively identifies the specific components it needs, converges on them fast, and leaves everything else untouched.
>
> *RL weight change dynamics over training steps*
> ![[bharatrunwal2-980195-009.jpg]]
>
> ---
>
> Mid-training changes how the model reasons
>
> Mid-training changes more than benchmark numbers. It changes how the model reasons.
>
> Base models: short outputs, low confidence.
>
> Mid-trained models: extended reasoning chains, qualitatively different confidence profiles.
>
> RL: sharpens this toward the correct answer.
>
> *Reasoning chain comparison: base vs mid-trained vs RL*
> ![[bharatrunwal2-980195-010.png]]
>
> ---
>
> Practical Takeaway from PRISM:
>
> Building a reasoning model? Here is what the evidence says:
>
> - Start from a long-context base model : this is where mid-training is most effective
> - Mid-train at 16k context if compute allows : it is the sweet spot; gains saturate beyond that
> - If using 8k context, a brief long-context extension + model merging largely restores long-context abilities
> - Do not skip mid-training and jump straight to RL. You leave 3–4× gains on the table
> - Focus more on mid-training data composition, not RL: the decisions that matter most already happened at mid-training
> - Expect RL to be 3–4× more effective with mid-training than without.
>
> Mid-training and RL are not interchangeable stages. They operate through fundamentally different mechanisms and each does something the other cannot.
>
> ---
>
> This project has been one of the most educational experiences for me personally:  spanning pretraining, mid-training, and RL, and trying to understand what each stage actually does to a model rather than just what it achieves on benchmarks.
>
> We covered a lot of ground, but several open questions remain that I am genuinely excited about:
>
> — What role does SFT play when inserted between mid-training and RL? Does it help shape the model landscape for RL or constrain it?
> — Can we take a base model, apply RL first, then mid-train, then RL again? How does this interleaving affect what each phase can do?
>
> These are the questions we are thinking about next.
>
> Special thanks to my collaborators: @AshishSunilAgr1, Anurag Roy, and @rpanda89 at @IBMResearch / @MITIBMLab. Grateful to have worked on this with such a great team.
>
> [Original thread](https://x.com/bharatrunwal2/status/2035366328517980195)

---

## Original Content (source: https://arxiv.org/pdf/2603.17074)

# PRISM: Demystifying Retention and Interaction in Mid-Training

Bharat Runwal, Ashish Agrawal, Anurag Roy, Rameswar Panda

IBM Research, MIT-IBM Watson AI Lab

We present PRISM, a comprehensive empirical study of mid-training design choices for large language models (LLMs). Through controlled experiments across seven base models spanning four families (Granite, LLaMA, Mistral, Nemotron-H), two architecture types (dense Transformer and attention-Mamba hybrid), and scales from 3B to 24B parameters, we show that a mid-training phase of ∼27B high-quality tokens yields consistent gains of +15 to +40 points on math, +5 to +12 points on code, and +6 to +13 points on science (GPQA-Diamond) benchmarks while preserving general performance. The full PRISM → RL pipeline improves the macro-average (domain-weighted) across six reasoning benchmarks from under 12 to 29–42 (a 3–4× improvement), whereas RL applied directly to most of the base models remains substantially less effective, with AIME scores near zero. Data composition choices matter most at mid-training, not at RL: including science data during mid-training unlocks +17 to +28 point GPQA-Diamond gains during RL, while changing the RL mix produces <2 point differences. Mechanistically, mid-training densely restructures >90% of model weights, while RL makes sparse, front-loaded refinements to ∼5% of parameters. Representation analysis (CKA) across three models and three input distributions confirms that RL consistently preserves mid-training's representational geometry (>0.998 CKA) across both dense Transformers and hybrid architectures. Crucially, RL applies identical weight changes regardless of starting point, yet only succeeds on mid-trained models, consistent with mid-training placing the model in a weight configuration from which RL can effectively improve performance. Our results demonstrate that retention-aware mid-training is a highly effective intermediate step for reliable reasoning enhancement and provide practical guidance for designing robust mid-training pipelines.

Correspondence: Bharat Runwal at [bharatrunwal@gmail.com](mailto:bharatrunwal@gmail.com)

 Project Page: [Website](https://bharat-runwal.github.io/PRISM/) Models & Data: [HuggingFace](https://huggingface.co/PRISM-Midtraining)

# 1 Introduction

The training pipeline for Large Language Models (LLMs) has evolved beyond the traditional two-stage recipe of pre-training followed by alignment. State-of-the-art models now incorporate an additional intermediate stage, mid-training, in which higher-quality, domain-focused data mixtures are used to imbue reasoning capabilities before downstream fine-tuning and reinforcement learning (RL) [\(Team et al.,](#page-32-0) [2025;](#page-32-0) [Olmo et al.,](#page-32-1) [2025\)](#page-32-1). Yet despite its growing adoption, mid-training remains poorly understood: the field lacks systematic guidance on what data to use, when to apply it, how it interacts with RL, and whether it generalizes across architectures.

We present PRISM (Demystifying Retention and Interaction in Mid-Training), shown in Fig. [1,](#page-1-0) a comprehensive empirical study that addresses these questions through controlled experiments across seven open-source base models spanning four families (Granite, LLaMA, Mistral, Nemotron-H), two architecture types (dense Transformer and attention-Mamba hybrid), and scales from 3B to 24B parameters. Using targeted mid-training mixtures of only ∼27B high-quality tokens, we produce the following key findings:

• Mid-training substantially improves reasoning performance. Across all tested models, PRISM yields +15 to +40 point gains on math benchmarks and +5 to +12 points on code, with science gains of +6 to +13 points on Granite and hybrid models, while preserving general-purpose performance.

<span id="page-1-0"></span>Figure 1 PRISM overview. Mid-training decisions are decomposed into their principal design axes, including retention of general and long-context abilities, domain interaction (math, code, science), benchmark selection, reinforcement learning compatibility, and scaling behavior. PRISM enables holistic evaluation of mid-training choices across model families at scale.

- Mid-training significantly enhances RL effectiveness. The full PRISM → RL pipeline improves the macro-average (domain-weighted) across six reasoning benchmarks (AIME'24, AIME'25, MATH500, LiveCodeBench, Codeforces, GPQA-Diamond) from under 12 to 29–42, a 3–4× improvement. RL applied directly to base models is substantially less effective, with AIME scores remaining near zero.
- Data composition matters most at mid-training, not at RL. Changing the mid-training mix from Math+Code to Math+Code+Science shifts AVG[1](#page-1-1) by +3 to +6 points, while changing the RL mix produces <2 point differences. Science data at mid-training unlocks +17 to +28 point GPQA-Diamond gains during RL.
- Benefits generalize across architectures and scales. Both dense Transformers and attention-Mamba hybrids benefit consistently from PRISM, from 3B to 24B parameters.
- RL expands the solvability frontier. For Granite-3.3, RL on PRISM-mid-trained models progressively solves prompts that were initially unsolvable, with training curves that remain non-saturating across hundreds of steps.
- Mid-training and RL operate through fundamentally different mechanisms. Weight-level analysis reveals that mid-training densely restructures >90% of parameters, while RL sparsely refines ∼5%, with identical weight footprints regardless of whether mid-training preceded it. Representation analysis (CKA) across three models and three input distributions confirms that RL consistently preserves mid-training's representational geometry (>0.998 CKA) across both dense Transformers and hybrid architectures, while mid-training's representational impact is model-specific. RL optimization is front-loaded, with most weight changes in the first ∼200–400 steps. Behaviorally, mid-training produces extended reasoning chains in model outputs. On held-out MATH500 problems, the full pipeline improves pass rates from 2.6–66.6% (base) to 64.6–83.0% across three model families.

The term mid-training has been used inconsistently in the literature. Some works treat it as a long-context extension phase [\(Abdin et al.,](#page-28-0) [2024\)](#page-28-0), others as a higher-quality annealing stage for domain knowledge [\(OLMo](#page-32-2) [et al.,](#page-32-2) [2025\)](#page-32-2), and recent work investigates mid-training choices that prepare models for RL by incorporating instruction-following data and chain-of-thought traces [\(Wang et al.,](#page-33-0) [2025\)](#page-33-0). These different usages have converged in practice, but the field lacks a holistic study that systematically quantifies the trade-offs induced by mid-training design choices across data mixtures, evaluation strategies, and downstream RL. PRISM fills this gap.

<span id="page-1-1"></span><sup>1</sup>AVG is computed as the mean of three domain scores: Code Avg (mean of LiveCodeBench and Codeforces), Math Avg (mean of AIME'24, AIME'25, and MATH500), and GPQA-Diamond.

The rest of the paper is organized as follows. We first discuss limitations of prior mid-training approaches, then describe our data mixtures and benchmark selection. We study when to mid-train, followed by domain-wise and cross-model-family analyses. We then present ablation studies on long-context restoration, context length, and token budget. We provide a detailed analysis of how reinforcement learning interacts with mid-trained models, including balanced vs. unbalanced RL mixes, base-model comparisons, solvability analysis, and a comprehensive pipeline-level evaluation. Finally, we present mechanistic analyses of the PRISM pipeline through weight divergence, representation similarity (CKA), prediction entropy, correctness studies, and RL weight trajectory dynamics across four model families and two architectures.

## 2 Limitations of Prior Mid-Training Approaches

Takeaway. Prior mid-training work often delivers domain-specific gains at the cost of generalization and holistic evaluation, and is rarely coupled with broad benchmark analysis or controlled studies of downstream RL behavior.

Recent mid-training strategies for LLMs have demonstrated notable improvements in targeted capabilities such as coding and mathematical reasoning by introducing higher-quality or domain-focused data between pre-training and downstream fine-tuning or RL [\(Olmo et al.,](#page-32-1) [2025;](#page-32-1) [Wang et al.,](#page-33-0) [2025\)](#page-33-0). However, the term mid-training has been used inconsistently in the literature, referring to long-context extension, data annealing, and domain-specific capability refinement, without a unified framework or standardized evaluation.

Narrow evaluation hides regressions. Many studies report gains on a limited set of domain-specific benchmarks (e.g., math or code) without assessing whether these improvements preserve general-purpose capabilities or interact with other reasoning dimensions [\(Wang et al.,](#page-33-0) [2025\)](#page-33-0). Long-context extension work primarily evaluates context-window scaling and retrieval-style tasks, with limited analysis of its impact on general reasoning [\(Abdin](#page-28-0) [et al.,](#page-28-0) [2024\)](#page-28-0). Similarly, domain-focused mid-training recipes often emphasize improvements on math or code benchmarks while omitting broad generalization and cross-domain robustness evaluations [\(OLMo et al.,](#page-32-2) [2025;](#page-32-2) [Wang et al.,](#page-33-0) [2025\)](#page-33-0).

Interaction with RL remains underexplored. A further shortcoming is the lack of controlled investigation into how mid-training interacts with downstream optimization, particularly reinforcement learning. While prior work suggests that certain mid-training strategies can facilitate RL by better aligning representations with downstream objectives, these claims are typically evaluated within narrow experimental settings and lack systematic comparison across model families, domains, and benchmark suites [\(Wang et al.,](#page-33-0) [2025;](#page-33-0) [Zhang et al.,](#page-33-1) [2025\)](#page-33-1).

Concurrent work. Recent studies have begun to address parts of these gaps. [Liu et al.](#page-31-0) [\(2025\)](#page-31-0) show that mid-training can serve as a distributional bridge between pre-training and post-training, reducing distributional mismatch while preserving general capabilities. [Zhang et al.](#page-33-1) [\(2025\)](#page-33-1) develop controlled experimental frameworks that isolate the contributions of pre-training, mid-training, and RL to reasoning generalization, highlighting mid-training as a critical yet underexplored stage. Small-scale controlled experiments provide valuable mechanistic insights with high ablation density. PRISM complements this line of work by examining midtraining design choices at 3B-24B scale across four model families, two architecture types, and multi-stage pipelines including RL, providing empirical coverage at a scale not addressed by prior work.

<span id="page-2-0"></span>Taken together, these limitations motivate PRISM: a retention-aware empirical framework that evaluates mid-training choices across multiple domains, benchmark axes, and downstream RL behavior across model families to uncover trade-offs overlooked by prior work.

<span id="page-3-0"></span>

| Dataset                                                                                                                                                | Type                                                     | Tokens (B)                       |
|--------------------------------------------------------------------------------------------------------------------------------------------------------|----------------------------------------------------------|----------------------------------|
| DCLM-EDU (Allal et al., 2025)                                                                                                                          | General web data                                         | 111.46                           |
| Open-R1 (MoT) (Lozhkov et al., 2025)<br>Nemotron Post-Training v1 (Nathawani et al., 2025) Math<br>Megamath-Web-Pro (Zhou et al., 2025)                | Math reasoning<br>Math web                               | 0.60<br>35.93<br>14.73           |
| Open-R1 (MoT) (Penedo et al., 2025)<br>OpenCodeReasoning-2 (Ahmad et al., 2025)<br>RefinCode (Huang et al., 2025)<br>StarCoder2 (Lozhkov et al., 2024) | Code reasoning<br>Code reasoning<br>Code web<br>Code web | 1.18<br>1.12<br>186.44<br>432.73 |
| Open-R1 (MoT) (Bercovich et al., 2025)<br>OpenThoughts3 (Guha et al., 2025)                                                                            | Science reasoning<br>Science reasoning                   | 0.42<br>0.73                     |
| WildChat-1M (Zhao et al., 2024)<br>Tulu-3 SFT Personas (Lambert et al., 2025)<br>UltraChat-200k (Ding et al., 2023)                                    | Chat<br>Chat<br>Chat                                     | 0.91                             |

Table 1 Datasets used in mid-training mixtures. Token counts are reported in billions (Granite 3.3, 8B).

## 3 Data Mixtures for Mid-Training

Takeaway. Mid-training performance is highly sensitive to data composition; carefully tuned mixtures that balance general web and instruction data with domain-specific reasoning sources yield robust retention and consistent gains, and we adopt these empirically validated splits across all experiments.

Table [1](#page-3-0) summarizes the datasets used for mid-training. For the Math and Code domains, we use two data types: general web documents to retain knowledge from pretraining, and domain-specific reasoning datasets to imbue problem-solving ability. For Science, we include only reasoning-focused datasets. Prior work such as OctoThinker [\(Wang et al.,](#page-33-0) [2025\)](#page-33-0) shows that incorporating a small amount of general instruction data can stabilize reinforcement learning; accordingly, we include chat and instruction-following datasets. However, unlike OctoThinker which focuses primarily on math, our goal is to support reasoning across diverse domains while retaining broad pretraining knowledge. To this end, we include general web data (DCLM-EDU) alongside domain-specific sources.

#### 3.1 Dataset Preprocessing

We apply lightweight, deterministic preprocessing to all datasets to ensure data quality and evaluation integrity.

Web data filtering. For general web data, we use the DCLM-EDU corpus and retain documents with a quality score greater than or equal to 3, following the dataset's recommended filtering guidelines. This removes low-quality or noisy documents while preserving broad coverage of general knowledge.

Reasoning datasets. For OpenCodeReasoning-2, we retain only samples whose judgment is marked as right by the QwQ evaluator model and for which sufficient test coverage is available (i.e., pass\_rate ̸= −1). From this filtered pool, we randomly sample 60k Python examples and 60k C++ examples. Other reasoning datasets are used as provided, without additional filtering beyond standard deduplication.

Chat and instruction-following data. For chat-style datasets, all conversations are normalized by explicitly prefixing utterances with speaker roles ("User:" and "Assistant:"). For WildChat-1M, we further restrict the data to high-quality conversations generated by GPT-4, following prior evidence that such filtering improves stability in downstream reinforcement learning. For all reasoning datasets and chat data, we concatenate the question and answer with a single line break between them, following [\(Wang et al.,](#page-33-0) [2025\)](#page-33-0).

Fig. [2](#page-4-0) reports the final per-source sampling weights for three progressively richer configurations: Math-only, Math+Code, and Math+Code+Science. After experimenting with various weightings across domains, we

<span id="page-4-0"></span><span id="page-4-1"></span>Figure 2 Mid-training data mixture configurations and per-source sampling percentages. The outer ring shows individual data sources; the inner ring groups them by domain category.

| Category     | Benchmarks                                                                                                                                                                       | What it measures                               | Why it matters                                                                   |
|--------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|------------------------------------------------|----------------------------------------------------------------------------------|
|              | General ability Leaderboard-V1 (LB-V1)<br>(ARC, HellaSwag, MMLU,<br>TruthfulQA, Winogrande,<br>GSM8K), Leaderboard<br>V2 (LB-V2) (IFEval, BBH,<br>MATH, GPQA, MUSR,<br>MMLU-Pro) | Broad multitask knowledge<br>and robustness    | Detects generalization regressions<br>hidden by domain-specific gains.           |
| Long-context | RULER                                                                                                                                                                            | Long-context retrieval                         | Ensures mid-training does not<br>degrade long-context retrieval<br>capabilities. |
| Code         | LiveCodeBench (Jain et al.,<br>2024), Codeforces (Penedo<br>et al., 2025)                                                                                                        | Executable program synthe<br>sis and reasoning | Captures real-world coding abil<br>ity.                                          |
| Math         | AIME (AIME),<br>MATH500 (Lightman et al.,<br>2023)                                                                                                                               | Mathematical reasoning                         | Highly sensitive to data quality<br>and mid-training composition.                |
| Science      | GPQA-Diamond (Rein et al.,<br>2023)                                                                                                                                              | Expert-level scientific reason<br>ing          | Probes scientific reasoning capa<br>bilities                                     |

Table 2 Benchmark categories recommended for evaluating mid-training design choices.

found these configurations to provide the best balance between retaining broad pretraining knowledge and inducing targeted domain improvements; consequently, we adopt these splits as the default sampling policy for all experiments reported in this paper.

# 4 What to Evaluate: Benchmark Selection

Takeaway. Evaluate mid-training with a balanced suite that measures (i) general LLM ability, (ii) long-context behaviour, and (iii) domain-specific reasoning; otherwise, domain gains may mask regressions.

In PRISM we adopt a deliberately broad evaluation setup to surface both gains and regressions introduced by mid-training. Concretely, we combine general leaderboards (LB-V1 and LB-V2) with focused long-context, code, math, and science evaluations so that improvements in a single domain cannot hide capability loss elsewhere. Table [2](#page-4-1) summarizes the benchmark categories and their roles.

Practical guidance for benchmark selection. As summarized in Table [2,](#page-4-1) effective evaluation of mid-training decisions requires both breadth and depth:

- Mix breadth and depth: combine general-purpose leaderboards (LB-V1 [\(Beeching et al.,](#page-28-6) [2023\)](#page-28-6) and LB-V2 [\(Fourrier et al.,](#page-29-0) [2024\)](#page-29-0)) with targeted domain benchmarks to expose global regressions while accurately measuring domain-specific gains.
- Measure long-context retention explicitly: evaluate long-context reasoning separately (e.g., RULER [\(Hsieh](#page-30-4) [et al.,](#page-30-4) [2024\)](#page-30-4)), as mid-training dominated by short-context data can degrade long-context capabilities, often necessitating an additional lightweight fine-tuning stage to recover performance (see Section [8.1\)](#page-8-0).

# 5 When to Mid-Train

Takeaway. On Granite-4 Micro (3B), mid-training is most effective when applied after longcontext pretraining, yielding the largest gains in math, code, and science while preserving general reasoning. Whether this ordering generalizes across larger models or different architectures remains an open question. Conveniently, most open-source base models are released after long-context extension, making this the natural starting point in practice.

Mid-training is typically applied after pretraining, but the optimal timing within the pretraining pipeline remains unclear. Using Granite-4 Micro (3B), we apply the same mid-training recipe (Math+Code+Science, 8k context) at three different points: (i) after Phase 3 of pretraining, (ii) after Phase 4 (the final dense pretraining stage before long-context extension), and (iii) starting from the base model after long-context pretraining (Table [3\)](#page-5-0).

<span id="page-5-0"></span>

|                                 | Leaderbds. |             |      | Code |                              | Math |                         |             |  |
|---------------------------------|------------|-------------|------|------|------------------------------|------|-------------------------|-------------|--|
| Stage                           | V1         | V2          | LCB  | CF   | GPQA                         | AI24 | AI25                    | M500        |  |
| Phase 3                         |            | 63.30 19.44 | 7.05 |      | 8.61 19.53                   | 9.38 |                         | 16.09 65.88 |  |
| Phase 4                         |            | 62.84 20.85 | 7.89 |      | 7.95 17.85 10.00 14.06 61.70 |      |                         |             |  |
| After LC 62.91 20.53 10.39 6.18 |            |             |      |      |                              |      | 25.93 23.59 20.94 77.44 |             |  |

Table 3 Effect of when mid-training is applied on Granite-4 Micro (3B). Phase 3/4 = intermediate/late pretraining; After LC = after long-context extension.

Earlier phases yield gains, but later is better. Mid-training at earlier phases already produces meaningful improvements, but later stages consistently translate the mid-training signal into stronger downstream performance. Compared to Phase 3, Phase 4 mid-training modestly improves Leaderboard V2 (from 19.44 to 20.85) while maintaining similar code performance. However, both Phase 3 and Phase 4 underperform the final base model on math and science benchmarks.

After long-context extension produces the strongest results. Applying mid-training after long-context extension yields the best overall performance. Math performance improves substantially, with AIME24 increasing from 9.38 (Phase 3) and 10.00 (Phase 4) to 23.59, and MATH500 rising to 77.44. Code performance also improves, with LiveCodeBench reaching 10.39, while GPQA-Diamond reaches 25.93, exceeding both earlier phases.

General capabilities remain stable across timing choices. General-purpose leaderboards remain relatively stable across stages, indicating that later mid-training does not introduce large regressions in broad capabilities. Overall, these results suggest that while mid-training can be effective at multiple stages, applying it after long-context capabilities are established yields the most consistent gains across math, code, and science. We note that this is a preliminary finding based on a single model (Granite-4 Micro, 3B), and whether the same ordering holds across larger models or different architectures remains an open question. Additionally, post-long-context base models may be stronger starting points in absolute terms, confounding the timing effect with base model quality. The practical implication is limited to: given a choice of when to apply mid-training, post-LC is a reasonable default, and it is also the natural starting point for our broader PRISM study since most publicly released base models (e.g., LLaMA, Mistral) have already undergone long-context extension.

<span id="page-6-1"></span>

| Leaderboard V1        |       |           |       |            |            |       |                |        | Le    | aderboard | V2   |       |          |                |
|-----------------------|-------|-----------|-------|------------|------------|-------|----------------|--------|-------|-----------|------|-------|----------|----------------|
| Mixture               | ARC   | HellaSwag | MMLU  | TruthfulQA | Winogrande | GSM8K | OpenLLM V1 Avg | IFEval | BBH   | MATH      | GPQA | MUSR  | MMLU-Pro | OpenLLM V2 Avg |
| Base                  | 61.95 | 83.46     | 62.56 | 52.24      | 80.35      | 56.33 | 66.15          | 46.62  | 24.68 | 10.20     | 6.38 | 8.88  | 23.82    | 20.10          |
| Math only             | 62.54 | 78.72     | 64.29 | 46.04      | 75.30      | 71.95 | 66.47          | 46.46  | 25.57 | 17.75     | 5.59 | 9.08  | 29.86    | 22.39          |
| Math + Code           | 61.01 | 78.09     | 62.65 | 47.36      | 74.74      | 73.46 | 66.22          | 45.56  | 26.87 | 18.43     | 5.93 | 10.60 | 28.40    | 22.63          |
| Math + Code + Science | 61.69 | 78.12     | 62.98 | 46.96      | 74.90      | 74.22 | 66.48          | 46.44  | 26.32 | 20.02     | 7.27 | 8.60  | 29.55    | 23.03          |

Table 4 Leaderboard V1 and V2 results for Granite-3.3-8B mid-trained with the mixtures in Fig. 2.

### 6 Domain-wise Effects of Mid-Training Data

**Takeaway.** Mid-training performance is driven by data composition. Domain-specific data delivers large gains in its corresponding benchmarks, while balanced mixtures across math, code, and science achieve the best overall trade-off, improving domain reasoning while preserving general capabilities.

Having established the data sources and empirically validated mixture configurations in Section 3, we now examine how domain-specific data affects downstream performance. We mid-train the Granite-3.3 (8B) base model using three progressively richer data mixtures: Math-only, Math+Code, and Math+Code+Science, following the configurations in Fig. 2. All experiments use a fixed budget of  $\sim$ 27B tokens at a context length of 8192; additional hyperparameters are in Appendix Section A. We evaluate on both general-purpose leaderboards (LB-V1 and LB-V2) and domain-specific benchmarks, allowing us to isolate the effect of each domain and analyze the trade-offs between specialization and retention.

Math data drives the largest single-domain gains. Introducing math-specific data during mid-training leads to substantial improvements in mathematical reasoning. Compared to the baseline model, the Math-only mixture increases the Math average from 8.95 to 36.43, a gain of +27.48 points (Table 5). These gains demonstrate that high-quality math reasoning data is the primary driver of mathematical capability during mid-training.

<span id="page-6-0"></span>

| Mixture                          | Code  | Math  | GPQA  |
|----------------------------------|-------|-------|-------|
| Base                             | 2.07  | 8.95  | 22.56 |
| Math                             | 2.81  | 36.43 | 17.34 |
| $_{\mathrm{Math}+\mathrm{Code}}$ | 10.71 | 44.99 | 19.02 |
| $_{\rm Math+Code+Sci}$           | 10.58 | 48.75 | 29.12 |

**Table 5 Domain-specific results** for Granite-3.3 (8B). Code/Math are averages; full results in Appendix Table 19.

#### Code data is essential for programming benchmarks. Adding

code-specific data produces large improvements on programming benchmarks. While Math-only mid-training yields only marginal code gains over the baseline, increasing the Code average from 2.07 to 2.81 (+0.74), the Math+Code mixture raises the Code average to 10.71, corresponding to a +8.64 point improvement relative to the baseline (Table 5). Incorporating science data on top of code does not substantially alter code performance, with the Math+Code+Science mixture maintaining a similar Code average of 10.58.

Science data improves GPQA without sacrificing other domains. Including science data during mid-training improves performance on GPQA-Diamond without deteriorating code or math performance. Compared to the Math+Code mixture, the Math+Code+Science mixture increases GPQA-Diamond from 19.02 to 29.12 (+10.10 points). At the same time, the Code average remains stable (10.71 to 10.58), and the Math average further improves from 44.99 to 48.75 (Table 5). These results show that science-focused data can be added without sacrificing gains in other reasoning domains.

General performance is broadly maintained but with individual regressions. Mid-training introduces measurable trade-offs on general-purpose benchmarks. On Leaderboard V1, the Math-only mixture improves the overall average from 66.15 to 66.47 (+0.32), driven primarily by gains on GSM8K, while exhibiting regressions on individual benchmarks such as HellaSwag (~5 points across all mixtures) and TruthfulQA (Table 4). Leaderboard V2 averages increase monotonically with broader domain coverage, rising from 20.10 for the baseline to 22.39 for Math-only, 22.63 for Math+Code, and 23.03 for Math+Code+Science. Overall Leaderboard V1 averages remain near the baseline across mixtures, which we attribute in part to the consistent inclusion of general web data from DCLM-EDU; however, individual benchmarks such as HellaSwag

<span id="page-7-0"></span>

|                             |               |                | Leaderboards   |                           | Code         |               | Science        |                |                | Math                                              |                |
|-----------------------------|---------------|----------------|----------------|---------------------------|--------------|---------------|----------------|----------------|----------------|---------------------------------------------------|----------------|
| Model                       | Variant       |                | LB V1 LB V2    | LCB                       |              |               |                |                |                | CF Code Avg GPQA-D AIME24 AIME25 MATH500 Math Avg |                |
| Granite-3.3 (8B)            | Base<br>PRISM | 66.15<br>66.48 | 20.10          | 2.15<br>23.03 10.63 10.52 | 1.99         | 2.07<br>10.58 | 22.56<br>29.12 | 0.46<br>37.18  | 0.31<br>27.96  | 26.09<br>81.11                                    | 8.95<br>48.75  |
| Granite-4 Micro (3B)        | Base<br>PRISM | 66.01<br>62.91 | 21.82          | 0.24<br>20.53 10.87       | 2.28<br>6.25 | 1.26<br>8.56  | 21.55<br>34.34 | 16.09<br>27.19 | 12.34<br>22.29 | 50.42<br>79.40                                    | 26.28<br>42.96 |
| Granite-4-H Micro (3B) Base | PRISM         | 64.49<br>64.21 | 18.99          | 0.60<br>18.75 15.53       | 0.88<br>8.02 | 0.74<br>11.78 | 20.88<br>32.66 | 7.08<br>33.69  | 2.70<br>23.49  | 30.17<br>82.73                                    | 13.32<br>46.64 |
| Nemotron-H-8k (8B)          | Base<br>PRISM | 71.35<br>68.84 | 23.84          | 1.19<br>26.08 13.02 10.52 | 3.60         | 2.39<br>11.77 | 4.21<br>31.98  | 2.13<br>19.21  | 2.29<br>22.76  | 49.46<br>76.63                                    | 17.96<br>39.53 |
| Mistral-7B                  | Base<br>PRISM | 60.88<br>59.99 | 14.89          | 0.00<br>19.68 10.16       | 0.15<br>9.42 | 0.07<br>9.79  | 26.94<br>24.07 | 0.00<br>28.85  | 0.10<br>24.27  | 1.68<br>70.71                                     | 0.59<br>41.28  |
| LLaMA-3.1 (8B)              | Base<br>PRISM | 62.76<br>65.21 | 14.09<br>21.46 | 0.00<br>6.09              | 0.07<br>5.45 | 0.04<br>5.77  | 20.20<br>21.04 | 0.05<br>16.45  | 0.15<br>19.32  | 6.51<br>73.47                                     | 2.24<br>36.41  |
| Mistral-Small (24B)         | Base<br>PRISM | 74.98<br>69.52 | 27.29          | 0.00<br>27.42 10.03 10.08 | 0.29         | 0.15<br>10.06 | 22.55<br>22.05 | 0.78<br>32.91  | 0.73<br>27.34  | 26.92<br>80.80                                    | 9.48<br>47.02  |

Table 6 Base versus PRISM (Math+Code+Science) mid-training results across model families. Code Avg is the mean of LiveCodeBench (LCB) and Codeforces (CF). Math Avg is the mean of AIME24, AIME25, and MATH500. All values are reported to two decimal places.

show regressions of approximately 5 points, suggesting that domain-specific mid-training introduces some interference with general benchmarks.

# 7 PRISM Effects Across Model Families

Takeaway. Across model families, architectures, and scales, PRISM mid-training consistently improves reasoning performance. We observe gains of +15 to +40 points on math benchmarks and +5 to +12 points on coding benchmarks across all models. Science gains (GPQA-Diamond) are +6 to +13 points on Granite and hybrid models; for other families, science improvements primarily emerge after RL when science data is included at midtraining.

We evaluate PRISM mid-training across a diverse set of model families, architectures, and scales. Our experiments include dense Transformer models: Granite-3.3 (8B) [\(Granite Team, IBM,](#page-29-1) [2025\)](#page-29-1), LLaMA-3.1 (8B) [\(Grattafiori et al.,](#page-29-2) [2024\)](#page-29-2), Mistral-7B [\(Jiang et al.,](#page-30-5) [2023\)](#page-30-5), Mistral-Small-24B [\(Mistral AI Team,](#page-31-5) [2025\)](#page-31-5), and Granite-4 Micro (3B). We additionally consider hybrid architectures within the Granite-4 family [\(IBM](#page-30-6) [Granite Team,](#page-30-6) [2025\)](#page-30-6): Granite-4-H Micro (3B) and Nemotron-H (8B) [\(NVIDIA et al.,](#page-31-6) [2025\)](#page-31-6), which combine attention and Mamba layers. Additional architectural and training details are in Appendix Section [A.](#page-34-0) For most experiments, we perform PRISM mid-training at an 8k context length, which offers a favorable trade-off between computational cost and downstream performance (Section [8.2\)](#page-9-0).

Table [6](#page-7-0) summarizes the impact of PRISM mid-training across this diverse set of models. Across all families, PRISM consistently improves mathematical, coding, and scientific reasoning, while changes to general-purpose leaderboards are smaller and more model dependent.

Mid-training benefits generalize across all model families. PRISM yields strong improvements regardless of the underlying model family. Mistral-7B shows some of the largest gains, with MATH500 improving from 1.68 to 70.71 and Codeforces from 0.15 to 9.42. Mistral-Small (24B) similarly improves MATH500 from 26.92 to 80.80. LLaMA-3.1 (8B) benefits as well, improving AIME24 from 0.05 to 16.45 and LiveCodeBench from 0.00 to 6.09. These trends demonstrate that PRISM is effective across distinct model families and training recipes.

<span id="page-8-1"></span>

|                                                                              | RULER<br>Code / Science |                                                                                                                   |     | Math |      |                  |      |                         |                         |                         |                         |                                                   |                         |
|------------------------------------------------------------------------------|-------------------------|-------------------------------------------------------------------------------------------------------------------|-----|------|------|------------------|------|-------------------------|-------------------------|-------------------------|-------------------------|---------------------------------------------------|-------------------------|
| Model Variant                                                                | 8k                      | 16k                                                                                                               | 32k | 64k  | 128k | LCB              |      |                         |                         |                         |                         | CF Code Avg GPQA-D AIME24 AIME25 MATH500 Math Avg |                         |
| Granite-3.3 Base                                                             |                         | 85.81 82.40 75.53 64.91 59.09                                                                                     |     |      |      | 2.15             | 1.99 | 2.07                    | 22.56                   | 0.46                    | 0.31                    | 26.09                                             | 8.95                    |
| Mid-Train (Math+Code)<br>Mid-Train + LC (Attention)<br>Mid-Train + LC (Full) |                         | 89.02 60.44 21.52 11.71<br>90.04 82.56 71.47 54.63 36.32 23.78 15.53<br>89.29 80.74 70.86 56.02 38.41 29.99 21.04 |     |      |      | 6.46 11.11 10.30 |      | 10.71<br>19.65<br>25.52 | 19.02<br>17.85<br>14.48 | 32.44<br>36.56<br>35.21 | 28.33<br>32.55<br>30.36 | 74.22<br>67.20<br>62.30                           | 44.99<br>45.44<br>42.62 |
| Merge (15% Base + 85% Mid<br>Train)                                          |                         | 89.12 69.76 32.63 15.44 11.32 10.75 10.96                                                                         |     |      |      |                  |      | 10.86                   | 22.22                   | 28.39                   | 24.90                   | 72.97                                             | 42.09                   |
| Merge + LC (Attention)<br>Merge + LC (Full)                                  |                         | 90.00 84.27 73.31 57.27 37.75 26.16 17.29<br>89.83 84.08 73.89 60.06 42.16 29.51 21.56                            |     |      |      |                  |      | 21.73<br>25.54          | 17.51<br>15.82          | 33.85<br>33.75          | 28.75<br>30.78          | 71.28<br>68.91                                    | 44.63<br>44.48          |

Table 7 Restoring long-context capability after mid-training for Granite-3.3 (8B). RULER is evaluated from 8k to 128k input lengths. Downstream performance includes Code (LiveCodeBench, Codeforces), Science (GPQA-Diamond), and Math (AIME24, AIME25, MATH500).

Hybrid architectures benefit as much as dense models. Within the Granite-4 family, we observe that hybrid variants respond strongly to PRISM mid-training. The dense Granite-4 Micro (3B) shows substantial gains, improving MATH500 from 50.42 to 79.40 and LiveCodeBench from 0.24 to 10.87. Hybrid models, including Granite-4-H Micro (3B) and Nemotron-H (8B), also exhibit large improvements. For example, Nemotron-H (8B) increases AIME24 from 2.13 to 19.21, AIME25 from 2.29 to 22.76, and MATH500 from 49.46 to 76.63. While these results suggest that hybrid architectures can effectively leverage mid-training signal, differences in pretraining data and model scale prevent a direct attribution of these gains to architecture alone.

Larger models achieve higher absolute scores, but gains are universal. Although larger models achieve higher absolute scores, PRISM delivers meaningful gains at all scales. Smaller models often exhibit larger relative improvements, while larger models realize strong absolute gains without severe degradation on leaderboards. For instance, Mistral-Small (24B) improves MATH500 by more than +50 points while maintaining Leaderboard V2 performance, whereas LLaMA-3.1 (8B) improves Leaderboard V2 from 14.09 to 21.46. Overall, these results suggest that retention-aware, multi-domain mid-training provides consistent benefits across parameter scales.

## 8 Ablation Studies

Beyond data composition and model family, several practical design choices shape mid-training outcomes: how to restore long-context ability lost during short-context mid-training, how much context length to use during mid-training itself, and how many tokens are sufficient before gains saturate. We study each of these in controlled ablations on Granite models.

#### <span id="page-8-0"></span>8.1 Restoring Long-Context Ability After Mid-Training

Mid-training is performed at an 8k context length, which naturally degrades long-context capabilities inherited from pretraining. In this section, we study practical strategies to restore long-context performance after mid-training using Granite-3.3 (8B). We evaluate two approaches: (i) directly performing a short long-context extension phase on the mid-trained checkpoint, and (ii) linearly merging the mid-trained model with the base model prior to long-context extension. For both approaches, we further compare training all parameters versus training only attention modules during the long-context phase.

Details of the data construction and preprocessing used for long-context restoration are provided in Appendix Section [A.3.](#page-34-1) In particular, we augment the training data with code examples containing longer chains of thought, apply filtering to remove short-context samples, and use best-fit packing to efficiently construct long-context training sequences.

Mid-training severely degrades long-context ability. While the Granite-3.3 (8B) base model achieves a RULER score of 59.09 at 128k context, the Math+Code mid-trained model drops sharply to 6.46, despite strong performance at short context lengths (89.02 at 8k). This confirms that mid-training with short-context data alone disrupts long-context behaviors learned during pretraining, motivating the need for explicit restoration strategies. Figure [3](#page-9-1) illustrates the two restoration pipelines we evaluate.

<span id="page-9-1"></span>Figure 3 Long-context restoration pipeline. After PRISM mid-training degrades RULER@128k from 59.09 to 6.46, a linear merge (15% base + 85% mid-trained) followed by long-context extension recovers performance to 42.16 (full params) or 37.75 (attention-only).

A brief long-context extension phase largely restores performance. Applying 1k steps of long-context training directly on the mid-trained model raises RULER at 128k from 6.46 to 36.32 when training attention modules only, and to 38.41 when training all parameters. These improvements are consistent across intermediate context lengths, with RULER at 64k improving from 11.71 to over 54.63. At the same time, downstream reasoning performance is preserved or improved: Code Avg increases from 10.71 to 19.65 (attention-only) and 25.52 (full), while Math Avg remains above 42 across both variants (Table [7\)](#page-8-1).

Merging with the base model yields the strongest recovery. Merging the mid-trained model with the base model prior to long-context extension yields the strongest recovery at long context lengths. With a 15% base and 85% mid-trained linear merge followed by long-context training, RULER at 128k improves further to 42.16, narrowing much of the gap to the base model. Importantly, this approach maintains strong downstream reasoning performance, achieving a Code Avg of 25.54 and a Math Avg of 44.48. Across strategies, full-parameter long-context training yields the strongest recovery, while attention-only training still provides meaningful RULER improvements with competitive downstream performance, offering a practical efficiency/performance trade-off.

### <span id="page-9-0"></span>8.2 Effect of Mid-Training Context Length

We study the effect of increasing the mid-training context length while keeping the data mixture fixed to Math+Code+Science and maintaining a comparable token budget (Table [8\)](#page-9-2). All ablations use the Granite-4 Micro (3B) dense model.

Increasing context from 8k to 16k yields the largest gains: MATH500 improves from 79.40 to 82.47, AIME24 from 27.19 to 31.82, Codeforces from 6.25 to 8.90, and GPQA-Diamond from

<span id="page-9-2"></span>

| Context LB-V1 LB-V2 |                         |       | LCB                                                      |           |                         | CF GPQA AIME24 AIME25 M500 |                                           |
|---------------------|-------------------------|-------|----------------------------------------------------------|-----------|-------------------------|----------------------------|-------------------------------------------|
| Base                | 66.01                   | 21.82 |                                                          | 0.24 2.28 | 21.55                   | 16.09                      | 12.34 50.42                               |
| 8k<br>16k<br>32k    | 62.91<br>64.23<br>64.41 |       | 20.53 10.87 6.25<br>20.37 12.19 8.90<br>20.35 12.54 9.79 |           | 34.34<br>38.89<br>24.24 | 27.19<br>31.82<br>32.08    | 22.29 79.40<br>25.26 82.47<br>20.72 81.34 |

Table 8 Mid-training context length ablation on Granite-4 Micro (3B) with Math+Code+Science mix. V1/V2 = Leaderboard V1/V2.

34.34 to 38.89. These results indicate that moderate long-context mid-training strengthens the model's ability to leverage multi-step reasoning signals present in math, code, and science data.

However, gains largely saturate beyond 16k. Extending to 32k yields small additional improvements on Codeforces (8.90 → 9.79) and AIME24 (31.82 → 32.08), but MATH500 regresses slightly (82.47 → 81.34) and GPQA-Diamond drops substantially (38.89 → 24.24). One plausible explanation is data distribution shift: the science component of the training mixture may be less suited to the document lengths sampled at 32k, causing the model to be trained on fewer high-quality science examples in practice. We leave a systematic investigation to future work. General-purpose performance remains stable, with Leaderboard V1 partially recovering from 62.91 at 8k to 64.41 at 32k. Overall, 16k provides the most favorable balance between reasoning gains and training efficiency.

### 8.3 Effect of Mid-Training Token Budget

We study the effect of increasing the mid-training token budget while keeping the context length fixed at 8k and using a Math+Code data mixture (Table [9\)](#page-10-0). All experiments use the Granite-4 Micro (3B) dense model.

Relative to the base model, mid-training yields large gains in both math and code with modest budgets. At 10.49B tokens, Math Avg increases from 26.28 to 40.21 (+13.93), while Code Avg improves from 1.26 to 9.59. Increasing the budget to 15.73B further improves Math Avg to 42.07 while maintaining a strong Code Avg of 9.02.

<span id="page-10-0"></span>

| Tok. (B) LB-V1 LB-V2 Code GPQA |       |       |      |       | Math        |
|--------------------------------|-------|-------|------|-------|-------------|
| Base                           | 66.01 | 21.82 | 1.26 |       | 21.55 26.28 |
| 10.49                          | 63.45 | 19.50 | 9.59 |       | 19.19 40.21 |
| 15.73                          | 63.24 | 19.79 | 9.02 | 23.06 | 42.07       |
| 26.21                          | 63.28 | 19.63 | 8.69 |       | 19.19 42.22 |
| 31.46                          | 63.16 | 20.05 | 7.62 | 21.38 | 42.42       |

Table 9 Token budget ablation on Granite-4 Micro (3B), Math+Code mix. Full table in Appendix [20.](#page-36-1)

Beyond 26.21B tokens, gains largely saturate. Math Avg remains nearly constant (42.22 to 42.42), while Code Avg declines from 8.69 to 7.62 as the budget increases to 31.46B. General-purpose leaderboard scores (LB V1 and V2) remain stable across budgets, and GPQA-Diamond shows no consistent trend. These results indicate that most benefits of Math+Code mid-training are realized within approximately 15B to 27B tokens for this model.

## 9 Effects of Reinforcement Learning on Mid-Trained Models

Takeaway. The PRISM → RL pipeline improves the six-benchmark macro-average from under 12 to 29–42, a 3–4× improvement. Mid-training contributes the dominant gains (+14 to +18 points), RL adds a consistent second stage (+8 to +12 points), and RL on base models without mid-training is substantially less effective, with AIME scores remaining near zero for most models (Nemotron-H being an exception, showing moderate AIME progress from base). Science data at mid-training unlocks large GPQA-Diamond gains during RL (+17 to +28 points over MC-only), and RL progressively solves prompts that were initially unsolvable (shown for Granite-3.3).

A central question for PRISM is whether mid-trained models provide a better foundation for reinforcement learning than base models, and if so, how the mid-training and RL data compositions interact. In this section we address both questions through controlled experiments across six model families, two RL data mixes (balanced and unbalanced), and direct comparisons with RL applied to base models.

#### 9.1 RL Setup: Data, Filtering, and Mixes

Table [10](#page-11-0) summarizes the datasets used for RL across math, science, and code domains. We construct two RL data mixes, each subdivided into MC (math + code) and MCS (math + code + science) variants:

Unbalanced mix. We use the Granite-3.3-8B mid-trained model to filter prompts by difficulty. For each prompt, we sample 16 responses (temperature 1.0, top\_p 1.0). For math, we select prompts with exactly one correct sample out of 16, yielding a hard subset of 19k prompts. For code and science, where most prompts are unsolvable, we retain all prompts with at least one correct sample, resulting in 7k code and 17k science prompts. Despite the domain imbalance, this mix produces strong improvements across all reasoning benchmarks.

Balanced mix. We equalize all domains to 19k prompts by augmenting code and science with a random subset of prompts having zero correct samples (out of 16) for the Granite-3.3-8B mid-trained model. We additionally apply randomized instruction-format templates to science prompts to increase format diversity. Note that some zero-score prompts may be solvable by other mid-trained models.

Training hyperparameters are consistent across model families. Algorithm details are provided in Appendix D.

<span id="page-11-0"></span>

| Domain  | Sources                                                              | Count |
|---------|----------------------------------------------------------------------|-------|
| Math    | DeepScaleR-<br>Preview<br>INTELLECT-2-RL<br>Skywork-OR1-RL-<br>Data  | 294K  |
| Science | Nemotron-PT-v1-<br>stem                                              | 100K  |
| Code    | DeepCoder-<br>Preview<br>Skywork-OR1-RL-<br>Data<br>OpenCodeInstruct | 142K  |

**Table 10** RL datasets and prompt counts.

# 9.2 RL on PRISM: Consistent Gains Across Models

We apply RL with the unbalanced MCS mix on top of PRISM-mid-trained models. Learning curves for Granite-3.3-8B, Mistral-Small 24B, and Nemotron-H (8B) are shown in Figs. 4–6; additional results for Mistral-7B, LLaMA-3.1-8B, and Granite-4 Micro (Dense, 3B) are provided in Appendix Figs. 18, 19, and 20.

<span id="page-11-1"></span>(b) AIME24, AIME25, and MATH500 over RL steps.

Figure 4 PRISM  $\rightarrow$  RL: Granite-3.3-8B. RL training curves on the PRISM-mid-trained checkpoint using the unbalanced MCS mix. All benchmarks show consistent, monotonic improvements.

#### 9.2.1 Gains across benchmarks.

RL on top of PRISM yields consistent, positive gains across nearly all benchmarks and model families. GPQA-Diamond shows the largest absolute improvements (e.g., Mistral-24B: **+27.95**, Granite-3.3: **+22.39**, Mistral-7B: **+19.19**, LLaMA: **+18.35**, Nemotron-H: **+9.26**). LiveCodeBench gains are substantial too (Granite-3.3: **+8.96**, Mistral-24B: **+6.94**, LLaMA: **+8.96**, Granite-4 Micro: **+5.62**, Mistral-7B: **+6.21**, Nemotron-H: **+6.57**), indicating improved code generation after PRISM  $\rightarrow$  RL (see also Appendix K.8). Codeforces improvements are more variable (**+2.65 to +10.30**), with Granite-3.3 showing the largest gain (**+10.30**). Math

<span id="page-12-0"></span>Figure 5 PRISM  $\rightarrow$  RL: Mistral-Small 24B. The largest model tested shows the strongest GPQA-Diamond gains (+27.95) and non-saturating code improvements.

benchmark gains (AIME24/AIME25) are typically in the **3-10.74** point range across models. Granite-4 Micro (3B) shows consistent but smaller absolute gains compared with the larger 8B models.

#### 9.2.2 Non-saturating training curves.

Across both code and math benchmarks, many RL curves continue to trend upward or exhibit oscillations around an improving mean rather than clean saturation. This is visible in LiveCodeBench, Codeforces, AIME24/25, and MATH500, where scores often keep improving late into training, suggesting that the PRISM  $\rightarrow$  RL pipeline has not yet exhausted the available performance gains. Several models show noticeable improvements well after hundreds of RL steps (e.g., Granite-3.3 on Codeforces and LiveCodeBench; Mistral-24B on Codeforces and MATH500). This strengthens the case for viewing PRISM not as a final training stage, but as a launch point for deeper RL or multi-stage RL pipelines.

Generalization to recently released held-out benchmark. To further validate generalization, we evaluate Granite-3.3 (8B) and Mistral-Small (24B) on AIME 2026 (Mathematical Association of America, 2026), which was published after the completion of all training runs. Both models show consistent improvement over RL training steps on this fully held-out benchmark (Appendix J), confirming that the gains from the PRISM  $\rightarrow$  RL pipeline transfer to unseen mathematical reasoning challenges.

#### 9.3 PRISM vs Base Models: Mid-Training is Essential for RL

To quantify the value of mid-training as an initialization for RL, we apply RL directly to four base models: Granite-3.3 (8B), LLaMA-3.1 (8B), Mistral-7B, and Nemotron-H (8B), using the same unbalanced mix. Learning curves for Granite-3.3 and Nemotron-H are shown in Figs. 7 and 8; LLaMA and Mistral-7B base RL curves are in Appendix Figs. 21 and 22.

<span id="page-13-0"></span>Figure 6 PRISM  $\rightarrow$  RL: Nemotron-H 8B (Hybrid). RL yields stable gains on the hybrid attention-Mamba architecture, confirming that mid-training benefits extend beyond dense Transformers.

**Granite-3.3 (8B).** Figure 7 shows that RL on the base model produces noticeable gains on MATH500, coding, and science tasks, but fails to consistently improve on AIME24 and AIME25. Overall, RL on the base model underperforms RL on PRISM by a large margin, with final scores lower by  $\sim$ 37 points in math,  $\sim$ 14 points in code, and  $\sim$ 5 points in science.

**LLaMA-3.1 (8B) and Mistral-7B.** Both models exhibit a similar pattern when RL is applied directly to their base checkpoints (Figs. 21 and 22 in Appendix): MATH500 and Coding benchmarks show modest gains, but AIME24 and AIME25 remain near zero throughout training, indicating that base models lack the foundational reasoning representations needed for RL to make progress on harder tasks. We see a regression in GPQA-Diamond performance, where RL on top of the base model leads to lower performance than the base model itself. In contrast, RL on the corresponding PRISM-mid-trained checkpoints achieves substantially higher scores across all benchmarks (Figs. 19 and 18).

Nemotron-H (8B). Nemotron-H base (Fig. 8) shows a slightly different pattern: RL produces some gains on MATH500 and moderate AIME24/25 progress from base, unlike most other models where AIME scores remain near zero. This may be attributed to stronger mathematical knowledge in Nemotron-H's pretraining data, which provides a better initialization for RL even without mid-training. Nonetheless, the gap compared to the PRISM RL results (Fig. 6) remains substantial, confirming that mid-training is critical even for hybrid architectures.

Across all four model families, a consistent conclusion emerges: RL on base models produces limited and often unstable improvements, particularly on harder benchmarks like AIME24/25, while RL on PRISM-mid-trained models yields large, stable, and monotonic gains. These results are consistent with prior findings (Wang et al., 2025; Zhang et al., 2025) and highlight that PRISM provides a substantially stronger initialization for RL-driven reasoning expansion.

<span id="page-14-0"></span>Figure 7 RL on Granite-3.3-8B base (no mid-training). AIME24/25 remain near zero throughout training, and overall gains are substantially smaller than the PRISM  $\rightarrow$  RL pipeline (Fig. 4).

#### 9.4 Balanced vs Unbalanced RL Mix

We next study whether equalizing prompt counts across domains affects RL outcomes. We apply RL with the balanced mix on top of PRISM for Mistral-Small 24B, Granite-4 Micro (Hybrid and Dense, 3B), and Granite-3.3 (8B). Learning curves for Granite-3.3 are shown in Fig. 9; results for the remaining models are in Appendix Figs. 23–25.

Across all four models, RL with the balanced mix produces consistent improvements over PRISM on both math and code benchmarks. On the dense Granite-4 Micro (3B), the balanced mix yields gains of **+4.63** on AIME24, **+3.07** on AIME25, and **+3.38** on MATH500, with code improvements of **+4.30** on LiveCodeBench and **+6.06** on GPQA-Diamond (Fig. 24). The hybrid Granite-4-H Micro (3B) shows even larger gains, particularly on Codeforces (**+8.09**) and GPQA-Diamond (**+11.95**), with math improvements of **+5.58** on AIME24 and **+6.41** on AIME25 (Fig. 25).

Mistral-Small 24B also shows steady improvements on math and code benchmarks under the balanced mix (Fig. 23), though its GPQA-Diamond gain (**+25.93**) is slightly lower than that achieved by the unbalanced mix (**+27.95**, Fig. 5). Granite-3.3 (8B) benefits consistently from the balanced mix (Fig. 9), with improvements across all benchmarks.

Comparing with the unbalanced mix results (Figs. 4–20), we observe that math and code gains are broadly comparable across both mixes: for instance, the unbalanced mix on Granite-3.3 yields LiveCodeBench +8.96 and GPQA-Diamond +22.39 (Fig. 4), while the balanced mix on the same model produces similar trajectories (Fig. 9), showing that the balanced mix achieves comparable math and code gains to the unbalanced mix. For science, the effect of the balanced mix is model-dependent: the Granite-4 Micro variants show stronger GPQA-Diamond gains under the balanced mix, while Mistral-Small 24B performs slightly better with the unbalanced mix. We attribute the science improvements observed with the balanced mix primarily to the use of randomized instruction-format templates applied to science prompts, which expose the model to diverse

<span id="page-15-0"></span>Figure 8 RL on Nemotron-H 8B base (no mid-training). Even for hybrid architectures, RL on the base model shows limited progress on harder benchmarks compared to  $PRISM \rightarrow RL$  (Fig. 6).

question phrasings during RL and improve robustness to prompt formatting on GPQA-Diamond. Across all models, training curves under the balanced mix remain stable and monotonically improving, with no training instabilities observed.

#### 9.5 RL Expands the Solvability Frontier

A natural question is whether RL merely refines performance on already-solvable problems or actively expands the frontier of what the model can solve. Recall that the balanced mix includes prompts with zero correct samples out of 16 (score = 0) for code, and prompts with exactly one correct sample (score = 1) for math, representing the hardest tier of each domain. We track the pass rate of these prompts throughout RL training on Granite-3.3 (8B).

Figure 10 shows that the model progressively learns to solve prompts it could not handle at the start of

<span id="page-15-1"></span>Figure 10 Pass rates on initially unsolved (code, score = 0) and hardest (math, score = 1) prompts during RL training of Granite-3.3 (8B) with the balanced mix.

RL. For code prompts that had a pass rate of zero under the mid-trained checkpoint, the pass rate steadily increases over training, indicating that RL enables the model to acquire new problem-solving strategies beyond what mid-training alone provides. Similarly, for the hardest math prompts (score = 1), the pass rate improves consistently, showing that RL amplifies the model's ability to solve problems at the boundary of its initial competence.

These results, combined with the non-saturating training curves observed above, provide evidence that the PRISM  $\rightarrow$  RL pipeline actively pushes the solvability boundary rather than merely polishing existing capabilities. This is consistent with recent findings by Sun et al. (2025), who show that RL can unlock

#### Granite-3.3 8B Balanced (Base → PRISM → RL)

<span id="page-16-0"></span>(a) LiveCodeBench, Codeforces, and GPQA-Diamond over RL steps.

#### Granite-3.3 8B Balanced (Base → PRISM → RL)

(b) AIME24, AIME25, and MATH500 over RL steps.

Figure 9 PRISM  $\rightarrow$  RL with balanced mix: Granite-3.3-8B. Domain-equalized RL produces comparable math and code gains to the unbalanced mix (Fig. 4), with stable training throughout.

genuinely new algorithmic strategies in LLMs for previously unsolvable problem families. Mid-training produces a representation that is well-suited for RL-driven capability expansion.

### 9.6 The Full Pipeline: Broader RL Analysis

Table 11 presents a comprehensive view of the full Base  $\rightarrow$  Mid-training  $\rightarrow$  RL pipeline across three model families, two mid-training mixes (MC and MCS), and two RL mixes (MC and MCS). Each row reports the best-step checkpoint for the corresponding configuration.

#### 9.6.1 A clear hierarchy: mid-training dominates, RL amplifies.

The most striking pattern in Table 11 is the consistent hierarchy of effect sizes across all three model families. Mid-training produces the largest single-stage jump: the six-benchmark macro-average (AVG) increases by +13.84 for LLaMA (7.49  $\rightarrow$  21.33), +18.29 for Granite-3.3 (11.19  $\rightarrow$  29.48), and +15.85 for Mistral (9.20  $\rightarrow$  25.05). RL then adds a consistent second-stage boost on top of these already-strong checkpoints: +8.36 for LLaMA (21.33  $\rightarrow$  29.69), +12.28 for Granite-3.3 (29.48  $\rightarrow$  41.76), and +10.09 for Mistral (25.05  $\rightarrow$  35.14). The combined PRISM  $\rightarrow$  RL pipeline improves AVG from under 12 to 29-42, a 3-4× improvement.

#### 9.6.2 Science data at mid-training unlocks large RL gains on GPQA.

One of the most impactful findings is that including science data during mid-training (MCS) dramatically amplifies GPQA-Diamond gains during RL. For Granite-3.3, MCS mid-training followed by MC RL achieves GPQA **52.86** (vs. 35.52 with MC mid-training + MC RL). The pattern is consistent: for LLaMA, MCS+MCS reaches GPQA **36.03** (vs. 23.06 for MC+MC), and for Mistral, MCS+MCS reaches **41.75** (vs. 29.12 for MC+MC). This suggests that science data during mid-training provides foundational representations that RL can leverage for scientific reasoning, even when the RL mix itself is not science-heavy.

<span id="page-17-0"></span>

| Model       | MT  | RL  | LCB   | CF    | Code Avg | AIME24 | AIME25 | MATH500 | Math Avg | GPQA  | AVG   |
|-------------|-----|-----|-------|-------|----------|--------|--------|---------|----------|-------|-------|
|             | –   | –   | 0.00  | 0.07  | 0.04     | 0.05   | 0.15   | 6.51    | 2.24     | 20.20 | 7.49  |
|             | MC  | –   | 6.93  | 6.03  | 6.48     | 20.67  | 19.58  | 73.70   | 37.98    | 19.53 | 21.33 |
|             | MCS | –   | 6.09  | 5.45  | 5.77     | 16.45  | 19.32  | 73.47   | 36.41    | 21.04 | 21.07 |
| LLaMA-3.1   | MC  | MC  | 12.31 | 11.85 | 12.08    | 25.47  | 23.23  | 78.99   | 42.56    | 23.06 | 25.90 |
|             | MC  | MCS | 11.83 | 12.80 | 12.32    | 24.43  | 23.12  | 78.62   | 42.06    | 24.75 | 26.38 |
|             | MCS | MC  | 13.62 | 11.41 | 12.51    | 20.47  | 21.67  | 77.10   | 39.75    | 34.01 | 28.76 |
|             | MCS | MCS | 14.34 | 12.07 | 13.20    | 20.42  | 22.08  | 77.03   | 39.84    | 36.03 | 29.69 |
|             | –   | –   | 2.15  | 1.99  | 2.07     | 0.46   | 0.31   | 26.09   | 8.95     | 22.56 | 11.19 |
|             | MC  | –   | 11.11 | 10.30 | 10.71    | 32.44  | 28.33  | 74.22   | 44.99    | 19.02 | 24.91 |
|             | MCS | –   | 10.63 | 10.52 | 10.58    | 37.18  | 27.96  | 81.11   | 48.75    | 29.12 | 29.48 |
| Granite-3.3 | MC  | MC  | 20.79 | 18.76 | 19.78    | 40.36  | 33.33  | 85.88   | 53.19    | 35.52 | 36.16 |
|             | MC  | MCS | 20.43 | 19.57 | 20.00    | 40.10  | 30.89  | 85.51   | 52.17    | 35.69 | 35.95 |
|             | MCS | MC  | 20.31 | 20.46 | 20.38    | 40.62  | 30.89  | 84.62   | 52.04    | 52.86 | 41.76 |
|             | MCS | MCS | 17.20 | 18.03 | 17.62    | 40.42  | 29.58  | 83.99   | 51.33    | 51.52 | 40.16 |
|             | –   | –   | 0.00  | 0.15  | 0.07     | 0.00   | 0.10   | 1.68    | 0.59     | 26.94 | 9.20  |
|             | MC  | –   | 11.11 | 9.27  | 10.19    | 24.63  | 15.52  | 47.70   | 29.28    | 15.99 | 18.49 |
|             | MCS | –   | 10.16 | 9.42  | 9.79     | 28.85  | 24.27  | 70.71   | 41.28    | 24.07 | 25.05 |
| Mistral-7B  | MC  | MC  | 17.08 | 16.34 | 16.71    | 34.11  | 27.50  | 84.18   | 48.60    | 29.12 | 31.48 |
|             | MC  | MCS | 16.61 | 15.60 | 16.10    | 33.02  | 26.93  | 83.80   | 47.92    | 28.28 | 30.77 |
|             | MCS | MC  | 16.61 | 15.31 | 15.96    | 33.75  | 26.93  | 84.15   | 48.28    | 40.91 | 35.05 |
|             | MCS | MCS | 16.01 | 15.16 | 15.58    | 32.86  | 27.03  | 84.37   | 48.09    | 41.75 | 35.14 |

Table 11 Full Base → Mid-training → RL pipeline results across LLaMA-3.1-8B, Granite-3.3-8B, and Mistral-7B. MC = math + code mix; MCS = math + code + science mix. MT = mid-training mix; RL = RL mix. Highlighted rows show the best configuration per model.

#### 9.6.3 RL data mix matters less than mid-training mix.

Changing the RL mix from MC to MCS produces comparatively small differences (typically <2 AVG points), whereas changing the mid-training mix from MC to MCS can shift AVG by +3 to +6 points. For example, for Granite-3.3 with MC mid-training, switching RL from MC to MCS changes AVG only from 36.16 to 35.95 (−0.21), while switching mid-training from MC to MCS (with MC RL) jumps AVG from 36.16 to 41.76 (+5.60). This confirms that data composition choices have their greatest impact during mid-training, and RL primarily serves to amplify whatever capabilities mid-training has established.

#### 9.6.4 Best configurations per model.

The highlighted rows in Table [11](#page-17-0) show the best overall configuration for each family: MCS mid-training + MCS RL for LLaMA (AVG 29.69) and Mistral (AVG 35.14), and MCS mid-training + MC RL for Granite-3.3 (AVG 41.76). Granite-3.3 achieves the highest absolute scores across the board, with Code Avg of 20.38, Math Avg of 52.04, and GPQA of 52.86, demonstrating that the PRISM → RL pipeline is most effective when built on a strong base model with broad mid-training coverage.

<span id="page-18-1"></span>

| Model                          | MT  | Transition                                              | Attn  | MLP                    | Mamba                     | Total                     | Sparsity               |
|--------------------------------|-----|---------------------------------------------------------|-------|------------------------|---------------------------|---------------------------|------------------------|
| Granite-3.3<br>(8B)            | MCS | Base → MT<br>MT → RL<br>Base → RL (no MT) 0.0004 0.0007 | 0.175 | 0.329<br>0.0003 0.0006 | –<br>–<br>–               | 0.175<br>0.0003<br>0.0004 | 9.3%<br>95.9%<br>96.0% |
|                                | MC  | Base → MT<br>MT → RL                                    | 0.177 | 0.333<br>0.0003 0.0006 | –<br>–                    | 0.177<br>0.0003           | 9.3%<br>95.8%          |
| Nemotron-H<br>(8B, Hybrid) MCS |     | Base → MT<br>MT → RL<br>Base → RL (no MT) 0.0006 0.0006 | 0.230 | 0.289<br>0.0007 0.0007 | 0.138<br>0.0003<br>0.0003 | 0.112<br>0.0003<br>0.0002 | 2.7%<br>93.5%<br>94.2% |

Table 12 Weight divergence summary acrossmodels and architectures. Normalized L2 = ∥wnew −wold∥2/∥wold∥2. Nemotron-H reports all three component types (Attention, MLP, Mamba). Sparsity = fraction of parameters with <1% relative change. The dense/sparse asymmetry is consistent across all component types and architectures.

# 10 Understanding the PRISM Pipeline: Weight and Behavioral Analysis

Takeaway. Mid-training makes broad weight changes and reshapes model behavior; RL makes targeted refinements while preserving representational structure.

- Weights: Mid-training densely restructures >90% of parameters; RL sparsely refines ∼5%, with 370–580× smaller magnitude. This dense/sparse asymmetry holds at any threshold from 0.1% to 10%.
- Representations: RL consistently preserves mid-training's representational geometry (CKA > 0.998) across 3 models and 3 input distributions. Mid-training's representational impact is model-specific and cannot be universally characterized.
- Starting-point invariance: RL targets the same sub-components in identical proportions whether or not mid-training preceded it, yet only succeeds on mid-trained models.
- Behavior: Mid-training produces extended reasoning chains in model outputs. On heldout MATH500 problems, the full pipeline improves pass rates from 2.6–66.6% (base) to 64.6–83.0% (PRISM→RL) across three model families.
- RL dynamics: Optimization is front-loaded (∼200–400 steps), with the active parameter set growing progressively from ∼1.5% to ∼5%.

The preceding sections establish what mid-training and RL achieve in terms of benchmark performance. In this section, we investigate how these stages differ mechanistically, through four complementary lenses: (i) weight-level divergence and sparsity, (ii) representation similarity via CKA, (iii) prediction entropy and correctness, and (iv) RL weight trajectory dynamics. Weight and trajectory analyses use Granite-3.3 (dense) and Nemotron-H (attention-Mamba hybrid); CKA analysis additionally includes LLaMA-3.1 across three input distributions; and behavioral analyses include LLaMA-3.1.

#### <span id="page-18-2"></span>10.1 Weight-Level Analysis: Dense Restructuring vs. Sparse Refinement

We compute per-layer normalized L2 divergence and update sparsity across pipeline transitions. The normalized L2 divergence for a weight matrix W is:

<span id="page-18-0"></span>
$$\delta(W) = \frac{\|W_{\text{new}} - W_{\text{old}}\|_2}{\|W_{\text{old}}\|_2} \tag{1}$$

Update sparsity is the fraction of parameters with δ < 1% (Eq. [1\)](#page-18-0); this threshold is illustrative and the dense/sparse asymmetry holds at any threshold from 0.1% to 10% (see Appendix [G\)](#page-38-1). For Granite-3.3, we additionally compare MC and MCS mid-training mixtures. Results are shown in Figure [11](#page-19-0) and Table [12.](#page-18-1)

Mid-training is a dense, global restructuring. Mid-training modifies the vast majority of parameters across all component types. For Granite-3.3, 90.7% of attention and 98.1% of MLP parameters change significantly

<span id="page-19-0"></span>Figure 11 Mid-training densely restructures the network; RL makes sparse, surgical refinements. Top row: layer-wise normalized L2 divergence for Granite-3.3 (8B, left) and Nemotron-H (8B, right). Mid-training (blue) changes weights  $370{-}580\times$  more than RL (red, orange), broadly across all layers with some layer-wise variation. For Nemotron-H, the repeating pattern reflects its hybrid architecture where Mamba-2, self-attention and FFN are separate sequential layers with independent residual connections (NVIDIA et al., 2025). Bottom row: update sparsity by component type. Mid-training modifies >90% of all parameters (attention, MLP, and Mamba alike), while RL leaves >93% unchanged.

during mid-training. For Nemotron-H, all three component types undergo dense updates: attention (97.3%), MLP (95.9%), and Mamba (97.8%), with MLP showing the largest L2 divergence (0.289) followed by attention (0.230) and Mamba (0.138) (Table 12). Changes are broadly distributed across all layers with some layer-wise variation (Figure 11, top row), with the hybrid model showing a characteristic alternating pattern reflecting its architecture of separate Mamba-2, FFN, and attention layers (52 layers total:  $\sim$ 24 Mamba,  $\sim$ 24 FFN, 4 attention).

RL is a sparse, surgical refinement. In contrast, RL modifies only  $\sim$ 5% of parameters across all architectures. L2 divergence is  $580 \times$  smaller for Granite-3.3 (0.0003 vs. 0.175) and  $370 \times$  smaller for Nemotron-H (0.0003 vs. 0.112). Over 93% of all weights remain within 1% of their mid-trained values (Figure 11, bottom row). Crucially, all three component types in the hybrid model show nearly identical sparsity during RL: attention (93.5%), MLP (94.5%), and Mamba (93.9%), confirming that the sparse RL update pattern is consistent across component types within the hybrid architecture. This sparsity is consistent with concurrent findings by Mukherjee et al. (2025), who identify in-distribution training as a key driver of update sparsity. We extend their analysis by demonstrating this asymmetry across two architectures and jointly with mid-training. We leave exploration of RL on domains not seen during mid-training to future work. At the sub-component level, value (V) and output (O) projections are consistently the most modified during RL (5.6–8.5%), while SSM parameters (A, dt) remain completely frozen; see Appendix H for the full breakdown.

Data composition determines the capabilities encoded, not the amount of change. Table 13 shows that MC and MCS mid-training produce nearly identical weight divergence profiles for both models: total L2 of 0.177 vs. 0.175 for Granite-3.3, and 0.113 vs. 0.112 for Nemotron-H, with matching per-component breakdowns. Yet the downstream GPQA-Diamond capabilities differ dramatically: for Granite-3.3, MCS+RL achieves 52.86 vs.

| Model              | Mix | Attn            | MLP         | Mamba          | Total          |
|--------------------|-----|-----------------|-------------|----------------|----------------|
| Granite-3.3 (8B)   | MC  | MCS 0.175 0.329 | 0.177 0.333 | –<br>–         | 0.177<br>0.175 |
| Nemotron-H (8B) MC |     | MCS 0.230 0.289 | 0.232 0.292 | 0.140<br>0.138 | 0.113<br>0.112 |

<span id="page-20-0"></span>Table 13 MC vs. MCS weight divergence (Base→MT normalized L2). Both models show nearly identical per-component L2 norms across data compositions, confirming that the training intensity is matched between MC and MCS despite their different downstream capabilities.

#### **Cosine Similarity Between MC and MCS Weight Update Vectors**

<span id="page-20-1"></span>Figure 12 Data composition redirects weight updates across all sub-components. Cosine similarity between MC and MCS weight update vectors (∆W = WMT − Wbase) for Granite-3.3 (left) and Nemotron-H (right). Overall cosine similarity of 0.52 and 0.62 respectively confirms that different data compositions steer weights in substantially different directions despite nearly identical magnitudes. The embedding/LM-head layers are most aligned (0.82–0.88), while attention, MLP, and Mamba layers all show low directional similarity (0.48–0.64).

35.52 for MC+RL (Table [11\)](#page-17-0). To directly measure what differs, we compute the cosine similarity between the MC and MCS weight update vectors per component (Figure [12\)](#page-20-1):

<span id="page-20-2"></span>
$$\cos(\Delta W_{MC}, \Delta W_{MCS}) = \frac{(W_{MC} - W_{\text{base}}) \cdot (W_{MCS} - W_{\text{base}})}{\|W_{MC} - W_{\text{base}}\|_2 \cdot \|W_{MCS} - W_{\text{base}}\|_2}$$
(2)

The overall cosine similarity (Eq. [2\)](#page-20-2) is only 0.521 for Granite-3.3 and 0.623 for Nemotron-H, indicating that despite traveling nearly identical distances in weight space (L2: 0.177 vs. 0.175 for G33; 0.113 vs. 0.112 for Nemotron-H), the two data compositions reach substantially different weight configurations. All sub-components (attention, MLP, Mamba) show similarly low directional alignment (0.48–0.64), with only the embedding layers remaining closer (0.82–0.88). These results are consistent with the view that data composition primarily affects what configuration the weights converge to, rather than the magnitude of the weight change (as measured by normalized L2).

RL's weight footprint is independent of the starting point. RL applied directly to base models (without midtraining) produces nearly identical weight changes to RL on mid-trained models, at both Granite-3.3 (0.0004 vs. 0.0003) and Nemotron-H (0.0002 vs. 0.0003). Yet the downstream outcomes differ drastically. A finergrained sub-component analysis (Table [23,](#page-45-0) Appendix [H\)](#page-40-1) confirms that this invariance extends to individual weight matrices: RL targets the same sub-components in nearly identical proportions regardless of whether mid-training preceded it. For Granite-3.3, value projections change 5.7% (MT→RL) vs. 7.5% (Base→RL), output projections 5.6% vs. 6.7%, and MLP gate projections 5.4% vs. 6.1%. Nemotron-H shows the same pattern, with Mamba parameters (A, dt) remaining completely frozen in both cases. This reveals that RL's sub-component targeting is an intrinsic property of the optimization process, not a consequence of mid-training. The large difference in outcomes despite similar weight change patterns suggests that mid-training appears to create model configurations from which RL can effectively improve performance, though the causal mechanism

<span id="page-21-0"></span>Figure 13 Pass rate landscape on held-out MATH500 problems. (a) Math pass rate at linearly interpolated weight checkpoints along the Base $\rightarrow$ MT $\rightarrow$ RL path for Granite-3.3 and LLaMA-3.1, evaluated on 200 held-out MATH500 problems (7680 generation tokens). Pass rate increases monotonically from Base to MT (16.9% $\rightarrow$ 75.5% for G33, 2.6% $\rightarrow$ 43.1% for LLaMA) and continues increasing through RL. (b) 2D pass rate landscape for Granite-3.3 centered at MT, with axes toward RL ( $\alpha$ ) and toward Base ( $\beta$ ). The RL direction consistently improves performance while moving toward Base degrades it.

remains to be established, while base models do not benefit to the same degree despite receiving similar gradient-driven updates.

Pass rate landscape is consistent with mid-training creating a favorable configuration for RL. To directly visualize this effect, we construct a pass rate landscape by linearly interpolating model weights along the training path and evaluating math pass rate at each interpolated checkpoint. We use 200 held-out MATH500 problems (not included in the RL training pool) with temperature 0.6, top-p 0.95, and 7680 max generation tokens, scored with the same verifier as RL training. We evaluate Granite-3.3 and LLaMA-3.1 (Figure 13). The interpolated weights are:

<span id="page-21-1"></span>
$$W(\alpha, \beta) = W_{\text{base}} + \alpha(W_{MT} - W_{\text{base}}) + \beta(W_{RL} - W_{MT})$$
(3)

where  $\alpha = 0, \beta = 0$  recovers Base;  $\alpha = 1, \beta = 0$  recovers MT; and  $\alpha = 1, \beta = 1$  recovers RL (Eq. 3). The 1D path sets  $\beta = 0$  and varies  $\alpha$  from 0 to 1, then fixes  $\alpha = 1$  and varies  $\beta$  from 0 to 1. The 2D landscape evaluates pass rate on a  $5 \times 5$  grid over  $(\alpha, \beta)$ .

For Granite-3.3, pass rate increases from Base (17%) to MT (76%) as  $\alpha$  increases from 0 to 1, then continues to RL (80%) along the  $\beta$  axis. LLaMA shows a similar trend: Base (3%) to MT (44%) to RL (66%). The 2D landscape shows the RL direction consistently yields higher performance, while moving toward Base degrades it. No sharp barriers are apparent near the training path.

The next section examines this further at the representation level: while RL's weight changes are consistent regardless of starting point, the resulting representations are dramatically more capable when built on top of mid-training.

#### <span id="page-21-3"></span>10.2 Representation Similarity Across Pipeline Stages

To complement the weight-level analysis, we measure how mid-training and RL reshape the model's internal representations using linear Centered Kernel Alignment (CKA) (Kornblith et al., 2019):

<span id="page-21-2"></span>
$$CKA(X,Y) = \frac{\|Y^{\top}X\|_F^2}{\|X^{\top}X\|_F \cdot \|Y^{\top}Y\|_F}$$
(4)

where  $X, Y \in \mathbb{R}^{n \times d}$  are mean-pooled hidden states from two checkpoints across n inputs (Eq. 4). CKA= 1 indicates identical representational geometry; lower values indicate greater divergence. We feed identical text through the Base, MT, and RL checkpoints, extracting mean-pooled hidden states at each layer. To ensure robustness, we evaluate on three input distributions: Wikipedia (general text), C4 (web text), and GSM8K (math prompts), across three models (Granite-3.3, LLaMA-3.1, Nemotron-H). To validate statistical

<span id="page-22-0"></span>Figure 14 RL preserves representational geometry; mid-training reshapes it in model-specific ways. Layer-wise linear CKA (Kornblith et al., 2019) on Wikipedia (top) and GSM8K math prompts (bottom) for Granite-3.3 (left) and Nemotron-H (right), evaluated on 200 prompts per input type with batch-size-1 encoding. MT vs. RL (green) is  $\approx 1.0$  at every layer across both models and both input types, confirming RL preserves mid-training's representational geometry. Base vs. MT and Base vs. RL (blue, pink) are nearly identical, confirming all representational change comes from mid-training. The magnitude and layer pattern of mid-training's representational shift is model- and input-specific. See Table 14 for the full summary.

stability, we perform bootstrap resampling (20 resamples of 100 from 200 inputs) and find that all MT vs. RL CKA estimates have standard deviations of at most 0.0001, confirming that the results are stable and not sensitive to the choice of input subset. Figure 14 reports layer-wise linear CKA on Wikipedia and GSM8K for Granite-3.3 and Nemotron-H; additional models and input types are in Appendix I.

RL preserves the representational geometry that mid-training creates. Table 14 shows MT vs. RL >0.998 for all three models across all three input types. This holds for dense Transformers (Granite-3.3, LLaMA-3.1) and the hybrid attention-Mamba architecture (Nemotron-H) alike. Furthermore, Base vs. MT and Base vs. RL curves are nearly identical at every layer, confirming that all representational geometry change is attributable to mid-training; RL achieves its gains through modifications within this established structure. RL achieves its benchmark gains through adjustments within the representational space that mid-training established, suggesting a division of roles between the two training stages.

The output layer shows the largest mid-training shift. For Granite-3.3, the sharpest Base vs. MT CKA divergence consistently occurs at the final transformer layer (layer 40) across all three inputs, but its depth is input-dependent:  $CKA \approx 0.63$  on GSM8K math prompts versus  $\approx 0.89$  on Wikipedia and C4. This input-specificity suggests the output layer restructuring is most pronounced for math reasoning content, consistent with the behavioral shift observed in Section 10.3: base models produce short, direct answers (median 124 tokens), while mid-trained models produce extended reasoning chains (2,196 tokens).

| Model                                                            | Arch. | Wiki | C4                                        | GSM8K |
|------------------------------------------------------------------|-------|------|-------------------------------------------|-------|
| Granite-3.3 (8B)                                                 | Dense |      | 0.9999±0.0000 0.9999±0.0000 0.9997±0.0000 |       |
| LLaMA-3.1 (8B)                                                   | Dense |      | 0.9999±0.0000 0.9999±0.0000 0.9996±0.0001 |       |
| Nemotron-H (8B) Hybrid 0.9999±0.0000 0.9998±0.0000 0.9993±0.0001 |       |      |                                           |       |

<span id="page-23-2"></span><span id="page-23-0"></span>Table 14 MT vs. RL representational similarity (minimum linear CKA ± bootstrap std) across input distributions. Values are the minimum layer-wise CKA across 20 bootstrap resamples of 100 from 200 inputs. RL consistently preserves mid-training's representational geometry (>0.998) across all three models and all three input types, spanning both dense Transformers and hybrid attention-Mamba architectures.

| Model                      | Stage            | Pass                    | Med. Len Neg-LP       |                         | Corr.                   | Incorr.                 |
|----------------------------|------------------|-------------------------|-----------------------|-------------------------|-------------------------|-------------------------|
| Granite-3.3<br>(8B)        | Base<br>MT<br>RL | 16.9%<br>75.5%<br>79.5% | 120<br>2,254<br>1,700 | 0.382<br>0.138<br>0.141 | –<br>0.128<br>0.135     | 0.383<br>0.153<br>0.160 |
| LLaMA-3.1<br>(8B)          | Base<br>MT<br>RL | 2.6%<br>43.1%<br>64.6%  | 158<br>1,052<br>1,188 | 0.758<br>0.377<br>0.267 | –<br>0.146<br>0.149     | 0.780<br>0.469<br>0.320 |
| Nemotron-H<br>(8B, Hybrid) | Base<br>MT<br>RL | 66.6%<br>61.6%<br>83.0% | 452<br>1,928<br>1,780 | 0.167<br>0.150<br>0.127 | 0.040<br>0.116<br>0.112 | 0.258<br>0.156<br>0.137 |

Table 15 Correctness, response length, and prediction confidence across pipeline stages on 200 held-out MATH500 problems (8 samples/prompt, 7680 max generation tokens, step-by-step reasoning prompt). Pass = mean pass rate across 8 samples per prompt (%). Med. Len = median response length (tokens). Neg-LP = mean negative log-probability. Corr./Incorr. = mean neg-LP for correct/incorrect responses; – indicates too few correct samples. The PRISM → RL pipeline consistently achieves the highest pass rates across all three model families.

Mid-training's representational impact is model- and input-specific. Unlike the RL finding (which is consistent across all models), the Base vs. MT divergence pattern varies considerably across models and input types. For Granite-3.3, the largest divergence is at the final output layer across all inputs (CKA ≈0.63 on GSM8K, ≈0.89 on Wikipedia and C4). Nemotron-H shows the most pronounced divergence on GSM8K, with a deep dip in later layers (CKA ≈0.41 at layer 48) while recovering to ≈0.75 at the final layer; on Wikipedia the final layer CKA is ≈0.93, indicating the restructuring is heavily math-targeted. LLaMA-3.1 shows its deepest divergence on C4 web text (CKA ≈0.71 at layer 29) rather than GSM8K (≈0.78), with the final layer recovering to ≈0.90. Each model was pretrained on a different data distribution, which is consistent with differences in how mid-training reshapes their representations, though we do not have access to the pretraining corpus compositions and cannot verify this hypothesis directly. Rather than making universal claims about where mid-training acts, we simply observe that its effect is model-dependent, whereas RL's preservation of representational geometry is consistent across all four models.

#### <span id="page-23-1"></span>10.3 Prediction Confidence and Correctness Across Pipeline Stages

We sample 200 held-out MATH500 problems [\(Lightman et al.,](#page-31-4) [2023\)](#page-31-4) and generate 8 responses per prompt at each pipeline stage using vLLM with temperature 0.6, top-p 0.95, 7680 max generation tokens, and a step-by-step reasoning prompt suffix. Pass rate is averaged across all 8 samples per prompt and then across 200 prompts. We collect per-token log-probabilities during generation and score correctness using the same math verifier employed during RL training. We report mean negative log-probability as a proxy for prediction confidence; note that this differs from predictive entropy, which would require marginalizing over the full output distribution. Results are in Table [15](#page-23-2) and Figure [15.](#page-24-0)

Mid-training teaches models to reason, not just answer. The most striking behavioral change is in response length. LLaMA base generates a median of just 158 tokens on MATH500 problems, Granite-3.3 base produces 120, and Nemotron-H base 452. After mid-training, all three produce extended reasoning chains: LLaMA increases to 1,052 tokens, Granite-3.3 extends to 2,254, and Nemotron-H to 1,928 (Table [15\)](#page-23-2). This is consistent

<span id="page-24-0"></span>Figure 15 Mid-training transforms prediction behavior: models learn to reason longer with calibrated confidence. Evaluated on 200 held-out MATH500 problems. Top row: response length distributions shift from short outputs (Base, gray) to extended reasoning chains (MT, blue), with RL (red) adjusting length. Bottom row: mean negative log-probability at each stage.

with mid-training's primary behavioral effect being the acquisition of multi-step problem decomposition.

The full pipeline dramatically improves correctness. Granite-3.3 improves from 16.9% to **79.5%** pass rate, LLaMA from 2.6% to **64.6%**, and Nemotron-H from 66.6% to **83.0%**. Nemotron-H is a notable case: the base model already achieves 66.6% on MATH500, generating 452-token responses that often reach direct correct answers. Mid-training introduces chain-of-thought reasoning patterns (extending to 1,928 tokens), but these extended generation strategies may conflict with the base model's existing direct-solution approaches, leading to a regression at the MT stage (61.6%). This tension is resolved by RL, which optimizes for correctness and recovers well above the base level (83.0%). This pattern of brief MT regression followed by strong RL recovery is consistent with the hypothesis that mid-training reshapes generation behavior in ways that require RL to fully unlock the capability gains. RL consistently improves over MT alone for all three models. Correct responses tend to have *lower* negative log-probability than incorrect ones across all stages and models (Table 15, Corr. vs. Incorr. columns), suggesting that higher model confidence is on average associated with correctness. This effect is most pronounced for LLaMA-3.1 (e.g., 0.149 correct vs. 0.320 incorrect at RL) and smallest for Nemotron-H at the RL stage (0.112 vs. 0.137).

Mid-training calibrates prediction confidence. Mid-training substantially reduces mean negative log-probability across all models, indicating increased overall confidence: Granite-3.3 from 0.382 to 0.138, LLaMA from 0.758 to 0.377, and Nemotron-H from 0.167 to 0.150. For LLaMA, the gap between correct and incorrect response confidence widens after mid-training (e.g., correct: 0.146 vs. incorrect: 0.469 at MT), indicating better calibration. Nemotron-H behaves differently: the base model is already highly confident on correct answers (neg-LP = 0.040) but very uncertain on incorrect ones (0.258); after mid-training and RL, confidence converges to a narrower range (correct: 0.112, incorrect: 0.137 at RL), making predictions more uniformly confident while still maintaining a separation between correct and incorrect responses.

RL refines toward efficient, correct reasoning. RL adjusts response length in a model-dependent direction: shortening for Granite-3.3  $(2,254\rightarrow1,700)$ , while Nemotron-H  $(1,928\rightarrow1,780)$  and LLaMA  $(1,052\rightarrow1,188)$  show modest changes. In all cases, RL maintains or improves the confidence gap between correct and incorrect answers while substantially increasing pass rates, demonstrating that it optimizes both the quality and efficiency of the reasoning process that mid-training established.

<span id="page-25-0"></span>Figure 16 RL optimization is front-loaded and starting-point-invariant. Top row: cumulative L2 divergence from the initial checkpoint over RL steps for Granite-3.3 (left) and Nemotron-H (right). Solid lines:  $MT \rightarrow RL$ ; dashed lines: Base $\rightarrow RL$ . Most weight change occurs in the first  $\sim 200-400$  steps, then plateaus.  $MT \rightarrow RL$  and Base $\rightarrow RL$  produce nearly identical divergence profiles, confirming that RL's weight footprint is independent of the starting point. Bottom row: sparsity evolution showing the fraction of parameters within 1% of their initial values. The active parameter set grows progressively from  $\sim 1.5\%$  at step 20 to  $\sim 5-6\%$  by step 960, with all component types following the same trajectory.

### 10.4 RL Weight Trajectory: Front-Loaded Optimization

We track weight evolution across RL training steps (20 to 960) for both Granite-3.3 and Nemotron-H, comparing MT→RL and Base→RL trajectories. Results are shown in Figure 16.

RL weight changes are front-loaded. Across both architectures, the majority of RL's cumulative weight divergence accumulates in the first  $\sim$ 200–400 steps, with the L2 curve plateauing thereafter (Figure 16, top row). For Nemotron-H, attention divergence reaches 80% of its final value by step 400; for Granite-3.3, the pattern is similar. This front-loading is consistent with the benchmark learning curves, which show the steepest performance gains in early RL steps. The component hierarchy is also consistent across all runs: attention layers change most, followed by MLP, then Mamba (in hybrid models).

The active parameter set is emergent, not predetermined. RL does not modify a fixed subset of parameters from the outset. Instead, the fraction of changed parameters grows progressively: at step 20, only  $\sim 1.5\%$  of parameters have moved beyond the 1% relative threshold, expanding to  $\sim 5-6\%$  by step 960 (Figure 16, bottom row). This gradual activation pattern, combined with the front-loaded divergence, shows that RL's sparse update set is not fixed from the outset but expands progressively over the course of training.

Starting point does not affect RL's weight trajectory. Comparing MT $\rightarrow$ RL (solid) with Base $\rightarrow$ RL (dashed) on the same axes reveals nearly identical L2 and sparsity trajectories for both Granite-3.3 and Nemotron-H. The final L2 divergence differs by less than 20% between starting points, and sparsity converges to within 1 percentage point. This provides additional evidence, beyond the single-checkpoint analysis in Section 10.1,

that RL applies a similarly scaled and sparse update pattern regardless of the starting point. The difference in downstream performance is thus consistent with arising from where in weight space the updates land, rather than from differences in the magnitude or sparsity of how RL modifies weights.

# 11 Conclusion and Future Work

We presented PRISM, a comprehensive empirical study of mid-training design choices for LLMs. Through controlled experiments across seven base models from four families (Granite, LLaMA, Mistral, Nemotron-H), two architecture types (dense Transformer and attention-Mamba hybrid), and scales from 3B to 24B parameters, we established several findings that we believe are valuable for practitioners designing mid-training pipelines:

- A relatively small mid-training phase (∼27B tokens) yields +15 to +40 point math gains and +5 to +12 point code gains across all tested models, with science gains of +6 to +13 points on Granite and hybrid models, while preserving general performance.
- Data composition choices matter most at mid-training, not at RL. Including science data during midtraining unlocks +17 to +28 point GPQA-Diamond gains during RL, while changing the RL mix produces <2 point differences.
- The full PRISM → RL pipeline improves the six-benchmark macro-average from under 12 to 29–42, a 3–4× improvement. RL applied directly to base models is substantially less effective.
- For Granite-3.3, mid-training at 8k context degrades long-context ability, but this can be largely restored via a brief extension phase combined with model merging. Note that all models in our study were pretrained with long-context phases, so the interaction between long-context pretraining and mid-training effectiveness may vary in other settings.
- For Granite-3.3, RL on mid-trained models progressively solves initially unsolvable prompts, with non-saturating training curves suggesting further gains are achievable.
- At the weight level, mid-training densely restructures >90% of parameters (370–580× larger than RL), while RL sparsely refines ∼5%, with identical footprints regardless of whether mid-training preceded it. Representation analysis (CKA) across three models and three input distributions confirms that RL consistently preserves mid-training's representational geometry (>0.998) across both dense Transformers and hybrid architectures, while mid-training's representational impact is model-specific. RL optimization is front-loaded, with most weight changes in the first ∼200–400 steps. Behaviorally, mid-training produces extended reasoning chains in model outputs.

Limitations and future directions. Our study has several limitations that point to productive future work.

Model-specific RL data selection. For consistency across model families, we filtered RL prompts using a single model (Granite-3.3-8B mid-trained) and applied the same mix to all models. In practice, different mid-trained models have different difficulty profiles, and model-specific prompt selection would likely yield stronger per-model results. Our goal was not to produce optimal per-model recipes but to enable controlled cross-model comparisons. Investigating adaptive, model-aware RL data curation is a natural next step.

Broader domain coverage. Our mid-training mixtures focus on math, code, and science. Extending PRISM to additional domains such as multilingual reasoning, agentic tasks, and tool use would test whether the patterns we observe (e.g., domain synergies, retention via general web data) hold more broadly.

Scaling beyond 24B. Our largest model is Mistral-Small (24B). Verifying that PRISM's findings extend to models at the 70B+ scale, where mid-training compute budgets and data requirements may differ qualitatively, remains an open question.

Long-context mid-training. Our primary experiments use 8k context during mid-training. While our ablations show that 16k yields additional gains, we did not explore mid-training at 32k+ with proportionally larger token budgets. Jointly optimizing context length and token budget during mid-training could further improve the reasoning/retention trade-off.

Overall, PRISM demonstrates that retention-aware mid-training is a highly effective intermediate step for reliable reasoning enhancement and RL scaling. We hope that the practical guidelines and comprehensive analyses provided in this work will help the community design more effective mid-training pipelines for modern LLMs.

# References

<span id="page-28-0"></span>Marah Abdin, Jyoti Aneja, Hany Awadalla, Ahmed Awadallah, Ammar Ahmad Awan, Nguyen Bach, Amit Bahree, Arash Bakhtiari, Jianmin Bao, Harkirat Behl, Alon Benhaim, Misha Bilenko, Johan Bjorck, Sébastien Bubeck, Martin Cai, Qin Cai, Vishrav Chaudhary, Dong Chen, Dongdong Chen, Weizhu Chen, Yen-Chun Chen, Yi-Ling Chen, Hao Cheng, Parul Chopra, Xiyang Dai, Matthew Dixon, Ronen Eldan, Victor Fragoso, Jianfeng Gao, Mei Gao, Min Gao, Amit Garg, Allie Del Giorno, Abhishek Goswami, Suriya Gunasekar, Emman Haider, Junheng Hao, Russell J. Hewett, Wenxiang Hu, Jamie Huynh, Dan Iter, Sam Ade Jacobs, Mojan Javaheripi, Xin Jin, Nikos Karampatziakis, Piero Kauffmann, Mahoud Khademi, Dongwoo Kim, Young Jin Kim, Lev Kurilenko, James R. Lee, Yin Tat Lee, Yuanzhi Li, Yunsheng Li, Chen Liang, Lars Liden, Xihui Lin, Zeqi Lin, Ce Liu, Liyuan Liu, Mengchen Liu, Weishung Liu, Xiaodong Liu, Chong Luo, Piyush Madan, Ali Mahmoudzadeh, David Majercak, Matt Mazzola, Caio César Teodoro Mendes, Arindam Mitra, Hardik Modi, Anh Nguyen, Brandon Norick, Barun Patra, Daniel Perez-Becker, Thomas Portet, Reid Pryzant, Heyang Qin, Marko Radmilac, Liliang Ren, Gustavo de Rosa, Corby Rosset, Sambudha Roy, Olatunji Ruwase, Olli Saarikivi, Amin Saied, Adil Salim, Michael Santacroce, Shital Shah, Ning Shang, Hiteshi Sharma, Yelong Shen, Swadheen Shukla, Xia Song, Masahiro Tanaka, Andrea Tupini, Praneetha Vaddamanu, Chunyu Wang, Guanhua Wang, Lijuan Wang, Shuohang Wang, Xin Wang, Yu Wang, Rachel Ward, Wen Wen, Philipp Witte, Haiping Wu, Xiaoxia Wu, Michael Wyatt, Bin Xiao, Can Xu, Jiahang Xu, Weijian Xu, Jilong Xue, Sonali Yadav, Fan Yang, Jianwei Yang, Yifan Yang, Ziyi Yang, Donghan Yu, Lu Yuan, Chenruidong Zhang, Cyril Zhang, Jianwen Zhang, Li Lyna Zhang, Yi Zhang, Yue Zhang, Yunan Zhang, and Xiren Zhou. Phi-3 technical report: A highly capable language model locally on your phone, 2024. <https://arxiv.org/abs/2404.14219>.

<span id="page-28-2"></span>Wasi Uddin Ahmad, Somshubra Majumdar, Aleksander Ficek, Sean Narenthiran, Mehrzad Samadi, Jocelyn Huang, Siddhartha Jain, Vahid Noroozi, and Boris Ginsburg. Opencodereasoning-ii: A simple test time scaling approach via self-critique, 2025. <https://arxiv.org/abs/2507.09075>.

<span id="page-28-5"></span>AIME. Aime problems and solutions. [https://artofproblemsolving.com/wiki/index.php/AIME\\_](https://artofproblemsolving.com/wiki/index.php/AIME_Problems_and_Solutions) [Problems\\_and\\_Solutions](https://artofproblemsolving.com/wiki/index.php/AIME_Problems_and_Solutions).

<span id="page-28-1"></span>Loubna Ben Allal, Anton Lozhkov, Elie Bakouch, Gabriel Martín Blázquez, Guilherme Penedo, Lewis Tunstall, Andrés Marafioti, Hynek Kydlíček, Agustín Piqueres Lajarín, Vaibhav Srivastav, Joshua Lochner, Caleb Fahlgren, Xuan-Son Nguyen, Clémentine Fourrier, Ben Burtenshaw, Hugo Larcher, Haojun Zhao, Cyril Zakka, Mathieu Morlon, Colin Raffel, Leandro von Werra, and Thomas Wolf. Smollm2: When smol goes big – data-centric training of a small language model, 2025. <https://arxiv.org/abs/2502.02737>.

<span id="page-28-6"></span>Edward Beeching, Clémentine Fourrier, Nathan Habib, Sheon Han, Nathan Lambert, Nazneen Rajani, Omar Sanseviero, Lewis Tunstall, and Thomas Wolf. Open llm leaderboard (2023-2024). [https://huggingface.co/spaces/](https://huggingface.co/spaces/open-llm-leaderboard-old/open_llm_leaderboard) [open-llm-leaderboard-old/open\\_llm\\_leaderboard](https://huggingface.co/spaces/open-llm-leaderboard-old/open_llm_leaderboard), 2023.

<span id="page-28-3"></span>Akhiad Bercovich, Itay Levy, Izik Golan, Mohammad Dabbah, Ran El-Yaniv, Omri Puny, Ido Galil, Zach Moshe, Tomer Ronen, Najeeb Nabwani, Ido Shahaf, Oren Tropp, Ehud Karpas, Ran Zilberstein, Jiaqi Zeng, Soumye Singhal, Alexander Bukharin, Yian Zhang, Tugrul Konuk, Gerald Shen, Ameya Sunil Mahabaleshwarkar, Bilal Kartal, Yoshi Suhara, Olivier Delalleau, Zijia Chen, Zhilin Wang, David Mosallanezhad, Adi Renduchintala, Haifeng Qian, Dima Rekesh, Fei Jia, Somshubra Majumdar, Vahid Noroozi, Wasi Uddin Ahmad, Sean Narenthiran, Aleksander Ficek, Mehrzad Samadi, Jocelyn Huang, Siddhartha Jain, Igor Gitman, Ivan Moshkov, Wei Du, Shubham Toshniwal, George Armstrong, Branislav Kisacanin, Matvei Novikov, Daria Gitman, Evelina Bakhturina, Jane Polak Scowcroft, John Kamalu, Dan Su, Kezhi Kong, Markus Kliegl, Rabeeh Karimi, Ying Lin, Sanjeev Satheesh, Jupinder Parmar, Pritam Gundecha, Brandon Norick, Joseph Jennings, Shrimai Prabhumoye, Syeda Nahida Akter, Mostofa Patwary, Abhinav Khattar, Deepak Narayanan, Roger Waleffe, Jimmy Zhang, Bor-Yiing Su, Guyue Huang, Terry Kong, Parth Chadha, Sahil Jain, Christine Harvey, Elad Segal, Jining Huang, Sergey Kashirsky, Robert McQueen, Izzy Putterman, George Lam, Arun Venkatesan, Sherry Wu, Vinh Nguyen, Manoj Kilaru, Andrew Wang, Anna Warno, Abhilash Somasamudramath, Sandip Bhaskar, Maka Dong, Nave Assaf, Shahar Mor, Omer Ullman Argov, Scot Junkin, Oleksandr Romanenko, Pedro Larroy, Monika Katariya, Marco Rovinelli, Viji Balas, Nicholas Edelman, Anahita Bhiwandiwalla, Muthu Subramaniam, Smita Ithape, Karthik Ramamoorthy, Yuting Wu, Suguna Varshini Velury, Omri Almog, Joyjit Daw, Denys Fridman, Erick Galinkin, Michael Evans, Katherine Luna, Leon Derczynski, Nikki Pope, Eileen Long, Seth Schneider, Guillermo Siman, Tomasz Grzegorzek, Pablo Ribalta, Monika Katariya, Joey Conway, Trisha Saar, Ann Guan, Krzysztof Pawelec, Shyamala Prayaga, Oleksii Kuchaiev, Boris Ginsburg, Oluwatobi Olabiyi, Kari Briski, Jonathan Cohen, Bryan Catanzaro, Jonah Alben, Yonatan Geifman, Eric Chung, and Chris Alexiuk. Llama-nemotron: Efficient reasoning models, 2025. <https://arxiv.org/abs/2505.00949>.

<span id="page-28-4"></span>Ning Ding, Yulin Chen, Bokai Xu, Yujia Qin, Zhi Zheng, Shengding Hu, Zhiyuan Liu, Maosong Sun, and Bowen Zhou. Enhancing chat language models by scaling high-quality instructional conversations, 2023.

<span id="page-29-0"></span>Clémentine Fourrier, Nathan Habib, Alina Lozovskaya, Konrad Szafer, and Thomas Wolf. Open llm leaderboard v2. [https://huggingface.co/spaces/open-llm-leaderboard/open\\_llm\\_leaderboard](https://huggingface.co/spaces/open-llm-leaderboard/open_llm_leaderboard), 2024.

<span id="page-29-3"></span>Alexey Gorbatovski, Boris Shaposhnikov, Alexey Malakhov, Nikita Surnachev, Yaroslav Aksenov, Ian Maksimov, Nikita Balagansky, and Daniil Gavrilov. Learn your reference model for real good alignment, 2025. [https:](https://arxiv.org/abs/2404.09656) [//arxiv.org/abs/2404.09656](https://arxiv.org/abs/2404.09656).

<span id="page-29-1"></span>Granite Team, IBM. Granite-3.3-8b-base. Hugging Face, 2025. [https://huggingface.co/ibm-granite/](https://huggingface.co/ibm-granite/granite-3.3-8b-base) [granite-3.3-8b-base](https://huggingface.co/ibm-granite/granite-3.3-8b-base).

<span id="page-29-2"></span>Aaron Grattafiori, Abhimanyu Dubey, Abhinav Jauhri, Abhinav Pandey, Abhishek Kadian, Ahmad Al-Dahle, Aiesha Letman, Akhil Mathur, Alan Schelten, Alex Vaughan, Amy Yang, Angela Fan, Anirudh Goyal, Anthony Hartshorn, Aobo Yang, Archi Mitra, Archie Sravankumar, Artem Korenev, Arthur Hinsvark, Arun Rao, Aston Zhang, Aurelien Rodriguez, Austen Gregerson, Ava Spataru, Baptiste Roziere, Bethany Biron, Binh Tang, Bobbie Chern, Charlotte Caucheteux, Chaya Nayak, Chloe Bi, Chris Marra, Chris McConnell, Christian Keller, Christophe Touret, Chunyang Wu, Corinne Wong, Cristian Canton Ferrer, Cyrus Nikolaidis, Damien Allonsius, Daniel Song, Danielle Pintz, Danny Livshits, Danny Wyatt, David Esiobu, Dhruv Choudhary, Dhruv Mahajan, Diego Garcia-Olano, Diego Perino, Dieuwke Hupkes, Egor Lakomkin, Ehab AlBadawy, Elina Lobanova, Emily Dinan, Eric Michael Smith, Filip Radenovic, Francisco Guzmán, Frank Zhang, Gabriel Synnaeve, Gabrielle Lee, Georgia Lewis Anderson, Govind Thattai, Graeme Nail, Gregoire Mialon, Guan Pang, Guillem Cucurell, Hailey Nguyen, Hannah Korevaar, Hu Xu, Hugo Touvron, Iliyan Zarov, Imanol Arrieta Ibarra, Isabel Kloumann, Ishan Misra, Ivan Evtimov, Jack Zhang, Jade Copet, Jaewon Lee, Jan Geffert, Jana Vranes, Jason Park, Jay Mahadeokar, Jeet Shah, Jelmer van der Linde, Jennifer Billock, Jenny Hong, Jenya Lee, Jeremy Fu, Jianfeng Chi, Jianyu Huang, Jiawen Liu, Jie Wang, Jiecao Yu, Joanna Bitton, Joe Spisak, Jongsoo Park, Joseph Rocca, Joshua Johnstun, Joshua Saxe, Junteng Jia, Kalyan Vasuden Alwala, Karthik Prasad, Kartikeya Upasani, Kate Plawiak, Ke Li, Kenneth Heafield, Kevin Stone, Khalid El-Arini, Krithika Iyer, Kshitiz Malik, Kuenley Chiu, Kunal Bhalla, Kushal Lakhotia, Lauren Rantala-Yeary, Laurens van der Maaten, Lawrence Chen, Liang Tan, Liz Jenkins, Louis Martin, Lovish Madaan, Lubo Malo, Lukas Blecher, Lukas Landzaat, Luke de Oliveira, Madeline Muzzi, Mahesh Pasupuleti, Mannat Singh, Manohar Paluri, Marcin Kardas, Maria Tsimpoukelli, Mathew Oldham, Mathieu Rita, Maya Pavlova, Melanie Kambadur, Mike Lewis, Min Si, Mitesh Kumar Singh, Mona Hassan, Naman Goyal, Narjes Torabi, Nikolay Bashlykov, Nikolay Bogoychev, Niladri Chatterji, Ning Zhang, Olivier Duchenne, Onur Çelebi, Patrick Alrassy, Pengchuan Zhang, Pengwei Li, Petar Vasic, Peter Weng, Prajjwal Bhargava, Pratik Dubal, Praveen Krishnan, Punit Singh Koura, Puxin Xu, Qing He, Qingxiao Dong, Ragavan Srinivasan, Raj Ganapathy, Ramon Calderer, Ricardo Silveira Cabral, Robert Stojnic, Roberta Raileanu, Rohan Maheswari, Rohit Girdhar, Rohit Patel, Romain Sauvestre, Ronnie Polidoro, Roshan Sumbaly, Ross Taylor, Ruan Silva, Rui Hou, Rui Wang, Saghar Hosseini, Sahana Chennabasappa, Sanjay Singh, Sean Bell, Seohyun Sonia Kim, Sergey Edunov, Shaoliang Nie, Sharan Narang, Sharath Raparthy, Sheng Shen, Shengye Wan, Shruti Bhosale, Shun Zhang, Simon Vandenhende, Soumya Batra, Spencer Whitman, Sten Sootla, Stephane Collot, Suchin Gururangan, Sydney Borodinsky, Tamar Herman, Tara Fowler, Tarek Sheasha, Thomas Georgiou, Thomas Scialom, Tobias Speckbacher, Todor Mihaylov, Tong Xiao, Ujjwal Karn, Vedanuj Goswami, Vibhor Gupta, Vignesh Ramanathan, Viktor Kerkez, Vincent Gonguet, Virginie Do, Vish Vogeti, Vítor Albiero, Vladan Petrovic, Weiwei Chu, Wenhan Xiong, Wenyin Fu, Whitney Meers, Xavier Martinet, Xiaodong Wang, Xiaofang Wang, Xiaoqing Ellen Tan, Xide Xia, Xinfeng Xie, Xuchao Jia, Xuewei Wang, Yaelle Goldschlag, Yashesh Gaur, Yasmine Babaei, Yi Wen, Yiwen Song, Yuchen Zhang, Yue Li, Yuning Mao, Zacharie Delpierre Coudert, Zheng Yan, Zhengxing Chen, Zoe Papakipos, Aaditya Singh, Aayushi Srivastava, Abha Jain, Adam Kelsey, Adam Shajnfeld, Adithya Gangidi, Adolfo Victoria, Ahuva Goldstand, Ajay Menon, Ajay Sharma, Alex Boesenberg, Alexei Baevski, Allie Feinstein, Amanda Kallet, Amit Sangani, Amos Teo, Anam Yunus, Andrei Lupu, Andres Alvarado, Andrew Caples, Andrew Gu, Andrew Ho, Andrew Poulton, Andrew Ryan, Ankit Ramchandani, Annie Dong, Annie Franco, Anuj Goyal, Aparajita Saraf, Arkabandhu Chowdhury, Ashley Gabriel, Ashwin Bharambe, Assaf Eisenman, Azadeh Yazdan, Beau James, Ben Maurer, Benjamin Leonhardi, Bernie Huang, Beth Loyd, Beto De Paola, Bhargavi Paranjape, Bing Liu, Bo Wu, Boyu Ni, Braden Hancock, Bram Wasti, Brandon Spence, Brani Stojkovic, Brian Gamido, Britt Montalvo, Carl Parker, Carly Burton, Catalina Mejia, Ce Liu, Changhan Wang, Changkyu Kim, Chao Zhou, Chester Hu, Ching-Hsiang Chu, Chris Cai, Chris Tindal, Christoph Feichtenhofer, Cynthia Gao, Damon Civin, Dana Beaty, Daniel Kreymer, Daniel Li, David Adkins, David Xu, Davide Testuggine, Delia David, Devi Parikh, Diana Liskovich, Didem Foss, Dingkang Wang, Duc Le, Dustin Holland, Edward Dowling, Eissa Jamil, Elaine Montgomery, Eleonora Presani, Emily Hahn, Emily Wood, Eric-Tuan Le, Erik Brinkman, Esteban Arcaute, Evan Dunbar, Evan Smothers, Fei Sun, Felix Kreuk, Feng Tian, Filippos Kokkinos, Firat Ozgenel, Francesco Caggioni, Frank Kanayet, Frank Seide, Gabriela Medina Florez, Gabriella Schwarz, Gada Badeer, Georgia Swee, Gil Halpern, Grant Herman, Grigory Sizov, Guangyi, Zhang, Guna Lakshminarayanan, Hakan Inan, Hamid Shojanazeri, Han Zou, Hannah Wang, Hanwen Zha, Haroun Habeeb, Harrison Rudolph, Helen Suk, Henry Aspegren, Hunter Goldman, Hongyuan Zhan, Ibrahim Damlaj, Igor Molybog, Igor Tufanov, Ilias Leontiadis, Irina-Elena Veliche, Itai Gat, Jake Weissman, James Geboski, James Kohli, Janice Lam, Japhet Asher, Jean-Baptiste Gaya, Jeff Marcus, Jeff Tang, Jennifer Chan, Jenny Zhen, Jeremy Reizenstein, Jeremy Teboul, Jessica Zhong, Jian Jin, Jingyi Yang, Joe Cummings, Jon Carvill, Jon Shepard, Jonathan McPhie, Jonathan Torres, Josh Ginsburg, Junjie Wang, Kai Wu, Kam Hou U, Karan Saxena, Kartikay Khandelwal, Katayoun Zand, Kathy Matosich, Kaushik Veeraraghavan, Kelly Michelena, Keqian Li, Kiran Jagadeesh, Kun Huang, Kunal Chawla, Kyle Huang, Lailin Chen, Lakshya Garg, Lavender A, Leandro Silva, Lee Bell, Lei Zhang, Liangpeng Guo, Licheng Yu, Liron Moshkovich, Luca Wehrstedt, Madian Khabsa, Manav Avalani, Manish Bhatt, Martynas Mankus, Matan Hasson, Matthew Lennie, Matthias Reso, Maxim Groshev, Maxim Naumov, Maya Lathi, Meghan Keneally, Miao Liu, Michael L. Seltzer, Michal Valko, Michelle Restrepo, Mihir Patel, Mik Vyatskov, Mikayel Samvelyan, Mike Clark, Mike Macey, Mike Wang, Miquel Jubert Hermoso, Mo Metanat, Mohammad Rastegari, Munish Bansal, Nandhini Santhanam, Natascha Parks, Natasha White, Navyata Bawa, Nayan Singhal, Nick Egebo, Nicolas Usunier, Nikhil Mehta, Nikolay Pavlovich Laptev, Ning Dong, Norman Cheng, Oleg Chernoguz, Olivia Hart, Omkar Salpekar, Ozlem Kalinli, Parkin Kent, Parth Parekh, Paul Saab, Pavan Balaji, Pedro Rittner, Philip Bontrager, Pierre Roux, Piotr Dollar, Polina Zvyagina, Prashant Ratanchandani, Pritish Yuvraj, Qian Liang, Rachad Alao, Rachel Rodriguez, Rafi Ayub, Raghotham Murthy, Raghu Nayani, Rahul Mitra, Rangaprabhu Parthasarathy, Raymond Li, Rebekkah Hogan, Robin Battey, Rocky Wang, Russ Howes, Ruty Rinott, Sachin Mehta, Sachin Siby, Sai Jayesh Bondu, Samyak Datta, Sara Chugh, Sara Hunt, Sargun Dhillon, Sasha Sidorov, Satadru Pan, Saurabh Mahajan, Saurabh Verma, Seiji Yamamoto, Sharadh Ramaswamy, Shaun Lindsay, Shaun Lindsay, Sheng Feng, Shenghao Lin, Shengxin Cindy Zha, Shishir Patil, Shiva Shankar, Shuqiang Zhang, Shuqiang Zhang, Sinong Wang, Sneha Agarwal, Soji Sajuyigbe, Soumith Chintala, Stephanie Max, Stephen Chen, Steve Kehoe, Steve Satterfield, Sudarshan Govindaprasad, Sumit Gupta, Summer Deng, Sungmin Cho, Sunny Virk, Suraj Subramanian, Sy Choudhury, Sydney Goldman, Tal Remez, Tamar Glaser, Tamara Best, Thilo Koehler, Thomas Robinson, Tianhe Li, Tianjun Zhang, Tim Matthews, Timothy Chou, Tzook Shaked, Varun Vontimitta, Victoria Ajayi, Victoria Montanez, Vijai Mohan, Vinay Satish Kumar, Vishal Mangla, Vlad Ionescu, Vlad Poenaru, Vlad Tiberiu Mihailescu, Vladimir Ivanov, Wei Li, Wenchen Wang, Wenwen Jiang, Wes Bouaziz, Will Constable, Xiaocheng Tang, Xiaojian Wu, Xiaolan Wang, Xilun Wu, Xinbo Gao, Yaniv Kleinman, Yanjun Chen, Ye Hu, Ye Jia, Ye Qi, Yenda Li, Yilin Zhang, Ying Zhang, Yossi Adi, Youngjin Nam, Yu, Wang, Yu Zhao, Yuchen Hao, Yundi Qian, Yunlu Li, Yuzi He, Zach Rait, Zachary DeVito, Zef Rosnbrick, Zhaoduo Wen, Zhenyu Yang, Zhiwei Zhao, and Zhiyu Ma. The llama 3 herd of models, 2024. <https://arxiv.org/abs/2407.21783>.

<span id="page-30-1"></span>Etash Guha, Ryan Marten, Sedrick Keh, Negin Raoof, Georgios Smyrnis, Hritik Bansal, Marianna Nezhurina, Jean Mercat, Trung Vu, Zayne Sprague, Ashima Suvarna, Benjamin Feuer, Liangyu Chen, Zaid Khan, Eric Frankel, Sachin Grover, Caroline Choi, Niklas Muennighoff, Shiye Su, Wanjia Zhao, John Yang, Shreyas Pimpalgaonkar, Kartik Sharma, Charlie Cheng-Jie Ji, Yichuan Deng, Sarah Pratt, Vivek Ramanujan, Jon Saad-Falcon, Jeffrey Li, Achal Dave, Alon Albalak, Kushal Arora, Blake Wulfe, Chinmay Hegde, Greg Durrett, Sewoong Oh, Mohit Bansal, Saadia Gabriel, Aditya Grover, Kai-Wei Chang, Vaishaal Shankar, Aaron Gokaslan, Mike A. Merrill, Tatsunori Hashimoto, Yejin Choi, Jenia Jitsev, Reinhard Heckel, Maheswaran Sathiamoorthy, Alexandros G. Dimakis, and Ludwig Schmidt. Openthoughts: Data recipes for reasoning models, 2025. <https://arxiv.org/abs/2506.04178>.

<span id="page-30-4"></span>Cheng-Ping Hsieh, Simeng Sun, Samuel Kriman, Shantanu Acharya, Dima Rekesh, Fei Jia, Yang Zhang, and Boris Ginsburg. Ruler: What's the real context size of your long-context language models?, 2024. [https:](https://arxiv.org/abs/2404.06654) [//arxiv.org/abs/2404.06654](https://arxiv.org/abs/2404.06654).

<span id="page-30-0"></span>Siming Huang, Tianhao Cheng, J. K. Liu, Jiaran Hao, Liuyihan Song, Yang Xu, J. Yang, Jiaheng Liu, Chenchen Zhang, Linzheng Chai, Ruifeng Yuan, Zhaoxiang Zhang, Jie Fu, Qian Liu, Ge Zhang, Zili Wang, Yuan Qi, Yinghui Xu, and Wei Chu. Opencoder: The open cookbook for top-tier code large language models, 2025. <https://arxiv.org/abs/2411.04905>.

<span id="page-30-6"></span>IBM Granite Team. Granite 4.0 language models. Hugging Face Collection, nov 2025. [https://huggingface.co/](https://huggingface.co/collections/ibm-granite/granite-40-language-models) [collections/ibm-granite/granite-40-language-models](https://huggingface.co/collections/ibm-granite/granite-40-language-models). Accessed: 2026-02-05.

<span id="page-30-3"></span>Naman Jain, King Han, Alex Gu, Wen-Ding Li, Fanjia Yan, Tianjun Zhang, Sida Wang, Armando Solar-Lezama, Koushik Sen, and Ion Stoica. Livecodebench: Holistic and contamination free evaluation of large language models for code, 2024. <https://arxiv.org/abs/2403.07974>.

<span id="page-30-5"></span>Albert Q. Jiang, Alexandre Sablayrolles, Arthur Mensch, Chris Bamford, Devendra Singh Chaplot, Diego de las Casas, Florian Bressand, Gianna Lengyel, Guillaume Lample, Lucile Saulnier, Lélio Renard Lavaud, Marie-Anne Lachaux, Pierre Stock, Teven Le Scao, Thibaut Lavril, Thomas Wang, Timothée Lacroix, and William El Sayed. Mistral 7b, 2023. <https://arxiv.org/abs/2310.06825>.

<span id="page-30-7"></span>Simon Kornblith, Mohammad Norouzi, Honglak Lee, and Geoffrey Hinton. Similarity of neural network representations revisited, 2019. <https://arxiv.org/abs/1905.00414>.

<span id="page-30-2"></span>Nathan Lambert, Jacob Morrison, Valentina Pyatkin, Shengyi Huang, Hamish Ivison, Faeze Brahman, Lester James V. Miranda, Alisa Liu, Nouha Dziri, Shane Lyu, Yuling Gu, Saumya Malik, Victoria Graf, Jena D. Hwang, Jiangjiang Yang, Ronan Le Bras, Oyvind Tafjord, Chris Wilhelm, Luca Soldaini, Noah A. Smith, Yizhong Wang, Pradeep Dasigi, and Hannaneh Hajishirzi. Tulu 3: Pushing frontiers in open language model post-training, 2025. <https://arxiv.org/abs/2411.15124>.

<span id="page-31-4"></span>Hunter Lightman, Vineet Kosaraju, Yura Burda, Harri Edwards, Bowen Baker, Teddy Lee, Jan Leike, John Schulman, Ilya Sutskever, and Karl Cobbe. Let's verify step by step. arXiv preprint arXiv:2305.20050, 2023.

<span id="page-31-0"></span>Emmy Liu, Graham Neubig, and Chenyan Xiong. Midtraining bridges pretraining and posttraining distributions, 2025. <https://arxiv.org/abs/2510.14865>.

<span id="page-31-3"></span>Anton Lozhkov, Raymond Li, Loubna Ben Allal, Federico Cassano, Joel Lamy-Poirier, Nouamane Tazi, Ao Tang, Dmytro Pykhtar, Jiawei Liu, Yuxiang Wei, Tianyang Liu, Max Tian, Denis Kocetkov, Arthur Zucker, Younes Belkada, Zijian Wang, Qian Liu, Dmitry Abulkhanov, Indraneil Paul, Zhuang Li, Wen-Ding Li, Megan Risdal, Jia Li, Jian Zhu, Terry Yue Zhuo, Evgenii Zheltonozhskii, Nii Osae Osae Dade, Wenhao Yu, Lucas Krauß, Naman Jain, Yixuan Su, Xuanli He, Manan Dey, Edoardo Abati, Yekun Chai, Niklas Muennighoff, Xiangru Tang, Muhtasham Oblokulov, Christopher Akiki, Marc Marone, Chenghao Mou, Mayank Mishra, Alex Gu, Binyuan Hui, Tri Dao, Armel Zebaze, Olivier Dehaene, Nicolas Patry, Canwen Xu, Julian McAuley, Han Hu, Torsten Scholak, Sebastien Paquet, Jennifer Robinson, Carolyn Jane Anderson, Nicolas Chapados, Mostofa Patwary, Nima Tajbakhsh, Yacine Jernite, Carlos Muñoz Ferrandis, Lingming Zhang, Sean Hughes, Thomas Wolf, Arjun Guha, Leandro von Werra, and Harm de Vries. Starcoder 2 and the stack v2: The next generation, 2024. <https://arxiv.org/abs/2402.19173>.

<span id="page-31-1"></span>Anton Lozhkov, Hynek Kydlíček, Loubna Ben Allal, Guilherme Penedo, Edward Beeching, Quentin Gallouédec, Nathan Habib, Lewis Tunstall, and Leandro von Werra. Openr1-math-220k. [https://huggingface.co/datasets/](https://huggingface.co/datasets/open-r1/OpenR1-Math-220k) [open-r1/OpenR1-Math-220k](https://huggingface.co/datasets/open-r1/OpenR1-Math-220k), 2025.

<span id="page-31-7"></span>Mathematical Association of America. 2026 american invitational mathematics examination (aime) i & ii, 2026. <https://maa.org/maa-invitational-competitions/>.

<span id="page-31-5"></span>Mistral AI Team. Mistral small 3. Mistral AI Blog, jan 2025. <https://mistral.ai/news/mistral-small-3/>.

<span id="page-31-8"></span>Sagnik Mukherjee, Lifan Yuan, Dilek Hakkani-Tur, and Hao Peng. Reinforcement learning finetunes small subnetworks in large language models, 2025. <https://arxiv.org/abs/2505.11711>.

<span id="page-31-2"></span>Dhruv Nathawani, Igor Gitman, Somshubra Majumdar, Evelina Bakhturina, Ameya Sunil Mahabaleshwarkar, Jian Zhang, and Jane Polak Scowcroft. Nemotron-Post-Training-Dataset-v1, July 2025. [https://huggingface.co/](https://huggingface.co/datasets/nvidia/Nemotron-Post-Training-Dataset-v1) [datasets/nvidia/Nemotron-Post-Training-Dataset-v1](https://huggingface.co/datasets/nvidia/Nemotron-Post-Training-Dataset-v1).

<span id="page-31-6"></span>NVIDIA, :, Aaron Blakeman, Aarti Basant, Abhinav Khattar, Adithya Renduchintala, Akhiad Bercovich, Aleksander Ficek, Alexis Bjorlin, Ali Taghibakhshi, Amala Sanjay Deshmukh, Ameya Sunil Mahabaleshwarkar, Andrew Tao, Anna Shors, Ashwath Aithal, Ashwin Poojary, Ayush Dattagupta, Balaram Buddharaju, Bobby Chen, Boris Ginsburg, Boxin Wang, Brandon Norick, Brian Butterfield, Bryan Catanzaro, Carlo del Mundo, Chengyu Dong, Christine Harvey, Christopher Parisien, Dan Su, Daniel Korzekwa, Danny Yin, Daria Gitman, David Mosallanezhad, Deepak Narayanan, Denys Fridman, Dima Rekesh, Ding Ma, Dmytro Pykhtar, Dong Ahn, Duncan Riach, Dusan Stosic, Eileen Long, Elad Segal, Ellie Evans, Eric Chung, Erick Galinkin, Evelina Bakhturina, Ewa Dobrowolska, Fei Jia, Fuxiao Liu, Gargi Prasad, Gerald Shen, Guilin Liu, Guo Chen, Haifeng Qian, Helen Ngo, Hongbin Liu, Hui Li, Igor Gitman, Ilia Karmanov, Ivan Moshkov, Izik Golan, Jan Kautz, Jane Polak Scowcroft, Jared Casper, Jarno Seppanen, Jason Lu, Jason Sewall, Jiaqi Zeng, Jiaxuan You, Jimmy Zhang, Jing Zhang, Jining Huang, Jinze Xue, Jocelyn Huang, Joey Conway, John Kamalu, Jon Barker, Jonathan Cohen, Joseph Jennings, Jupinder Parmar, Karan Sapra, Kari Briski, Kateryna Chumachenko, Katherine Luna, Keshav Santhanam, Kezhi Kong, Kirthi Sivamani, Krzysztof Pawelec, Kumar Anik, Kunlun Li, Lawrence McAfee, Leon Derczynski, Lindsey Pavao, Luis Vega, Lukas Voegtle, Maciej Bala, Maer Rodrigues de Melo, Makesh Narsimhan Sreedhar, Marcin Chochowski, Markus Kliegl, Marta Stepniewska-Dziubinska, Matthieu Le, Matvei Novikov, Mehrzad Samadi, Michael Andersch, Michael Evans, Miguel Martinez, Mike Chrzanowski, Mike Ranzinger, Mikolaj Blaz, Misha Smelyanskiy, Mohamed Fawzy, Mohammad Shoeybi, Mostofa Patwary, Nayeon Lee, Nima Tajbakhsh, Ning Xu, Oleg Rybakov, Oleksii Kuchaiev, Olivier Delalleau, Osvald Nitski, Parth Chadha, Pasha Shamis, Paulius Micikevicius, Pavlo Molchanov, Peter Dykas, Philipp Fischer, Pierre-Yves Aquilanti, Piotr Bialecki, Prasoon Varshney, Pritam Gundecha, Przemek Tredak, Rabeeh Karimi, Rahul Kandu, Ran El-Yaniv, Raviraj Joshi, Roger Waleffe, Ruoxi Zhang, Sabrina Kavanaugh, Sahil Jain, Samuel Kriman, Sangkug Lym, Sanjeev Satheesh, Saurav Muralidharan, Sean Narenthiran, Selvaraj Anandaraj, Seonmyeong Bak, Sergey Kashirsky, Seungju Han, Shantanu Acharya, Shaona Ghosh, Sharath Turuvekere Sreenivas, Sharon Clay, Shelby Thomas, Shrimai Prabhumoye, Shubham Pachori, Shubham Toshniwal, Shyamala Prayaga, Siddhartha Jain, Sirshak Das, Slawek Kierat, Somshubra Majumdar, Song Han, Soumye Singhal, Sriharsha Niverty, Stefania Alborghetti, Suseella Panguluri, Swetha Bhendigeri, Syeda Nahida Akter, Szymon Migacz, Tal Shiri, Terry Kong, Timo Roman, Tomer Ronen, Trisha Saar, Tugrul Konuk, Tuomas Rintamaki, Tyler Poon, Ushnish De, Vahid Noroozi, Varun Singh, Vijay Korthikanti, Vitaly Kurin, Wasi Uddin Ahmad, Wei Du, Wei Ping, Wenliang Dai,

Wonmin Byeon, Xiaowei Ren, Yao Xu, Yejin Choi, Yian Zhang, Ying Lin, Yoshi Suhara, Zhiding Yu, Zhiqi Li, Zhiyu Li, Zhongbo Zhu, Zhuolin Yang, and Zijia Chen. Nemotron-h: A family of accurate and efficient hybrid mamba-transformer models, 2025. <https://arxiv.org/abs/2504.03624>.

<span id="page-32-1"></span>Team Olmo, :, Allyson Ettinger, Amanda Bertsch, Bailey Kuehl, David Graham, David Heineman, Dirk Groeneveld, Faeze Brahman, Finbarr Timbers, Hamish Ivison, Jacob Morrison, Jake Poznanski, Kyle Lo, Luca Soldaini, Matt Jordan, Mayee Chen, Michael Noukhovitch, Nathan Lambert, Pete Walsh, Pradeep Dasigi, Robert Berry, Saumya Malik, Saurabh Shah, Scott Geng, Shane Arora, Shashank Gupta, Taira Anderson, Teng Xiao, Tyler Murray, Tyler Romero, Victoria Graf, Akari Asai, Akshita Bhagia, Alexander Wettig, Alisa Liu, Aman Rangapur, Chloe Anastasiades, Costa Huang, Dustin Schwenk, Harsh Trivedi, Ian Magnusson, Jaron Lochner, Jiacheng Liu, Lester James V. Miranda, Maarten Sap, Malia Morgan, Michael Schmitz, Michal Guerquin, Michael Wilson, Regan Huff, Ronan Le Bras, Rui Xin, Rulin Shao, Sam Skjonsberg, Shannon Zejiang Shen, Shuyue Stella Li, Tucker Wilde, Valentina Pyatkin, Will Merrill, Yapei Chang, Yuling Gu, Zhiyuan Zeng, Ashish Sabharwal, Luke Zettlemoyer, Pang Wei Koh, Ali Farhadi, Noah A. Smith, and Hannaneh Hajishirzi. Olmo 3, 2025. [https:](https://arxiv.org/abs/2512.13961) [//arxiv.org/abs/2512.13961](https://arxiv.org/abs/2512.13961).

<span id="page-32-2"></span>Team OLMo, Pete Walsh, Luca Soldaini, Dirk Groeneveld, Kyle Lo, Shane Arora, Akshita Bhagia, Yuling Gu, Shengyi Huang, Matt Jordan, Nathan Lambert, Dustin Schwenk, Oyvind Tafjord, Taira Anderson, David Atkinson, Faeze Brahman, Christopher Clark, Pradeep Dasigi, Nouha Dziri, Allyson Ettinger, Michal Guerquin, David Heineman, Hamish Ivison, Pang Wei Koh, Jiacheng Liu, Saumya Malik, William Merrill, Lester James V. Miranda, Jacob Morrison, Tyler Murray, Crystal Nam, Jake Poznanski, Valentina Pyatkin, Aman Rangapur, Michael Schmitz, Sam Skjonsberg, David Wadden, Christopher Wilhelm, Michael Wilson, Luke Zettlemoyer, Ali Farhadi, Noah A. Smith, and Hannaneh Hajishirzi. 2 olmo 2 furious, 2025. <https://arxiv.org/abs/2501.00656>.

<span id="page-32-3"></span>Guilherme Penedo, Anton Lozhkov, Hynek Kydlíček, Loubna Ben Allal, Edward Beeching, Agustín Piqueres Lajarín, Quentin Gallouédec, Nathan Habib, Lewis Tunstall, and Leandro von Werra. Codeforces cots. [https:](https://huggingface.co/datasets/open-r1/codeforces-cots) [//huggingface.co/datasets/open-r1/codeforces-cots](https://huggingface.co/datasets/open-r1/codeforces-cots), 2025.

<span id="page-32-6"></span>Negin Raoof, Etash Kumar Guha, Ryan Marten, Jean Mercat, Eric Frankel, Sedrick Keh, Hritik Bansal, Georgios Smyrnis, Marianna Nezhurina, Trung Vu, Zayne Rea Sprague, Mike A Merrill, Liangyu Chen, Caroline Choi, Zaid Khan, Sachin Grover, Benjamin Feuer, Ashima Suvarna, Shiye Su, Wanjia Zhao, Kartik Sharma, Charlie Cheng-Jie Ji, Kushal Arora, Jeffrey Li, Aaron Gokaslan, Sarah M Pratt, Niklas Muennighoff, Jon Saad-Falcon, John Yang, Asad Aali, Shreyas Pimpalgaonkar, Alon Albalak, Achal Dave, Hadi Pouransari, Greg Durrett, Sewoong Oh, Tatsunori Hashimoto, Vaishaal Shankar, Yejin Choi, Mohit Bansal, Chinmay Hegde, Reinhard Heckel, Jenia Jitsev, Maheswaran Sathiamoorthy, Alex Dimakis, and Ludwig Schmidt. Evalchemy, June 2025.

<span id="page-32-4"></span>David Rein, Betty Li Hou, Asa Cooper Stickland, Jackson Petty, Richard Yuanzhe Pang, Julien Dirani, Julian Michael, and Samuel R. Bowman. Gpqa: A graduate-level google-proof q&a benchmark, 2023. [https://arxiv.org/abs/](https://arxiv.org/abs/2311.12022) [2311.12022](https://arxiv.org/abs/2311.12022).

<span id="page-32-7"></span>Zhihong Shao, Peiyi Wang, Qihao Zhu, Runxin Xu, Junxiao Song, Xiao Bi, Haowei Zhang, Mingchuan Zhang, Y. K. Li, Y. Wu, and Daya Guo. Deepseekmath: Pushing the limits of mathematical reasoning in open language models, 2024. <https://arxiv.org/abs/2402.03300>.

<span id="page-32-5"></span>Yiyou Sun, Yuhan Cao, Pohao Huang, Haoyue Bai, Hannaneh Hajishirzi, Nouha Dziri, and Dawn Song. Rl grokking recipe: How does rl unlock and transfer new algorithms in llms?, 2025. <https://arxiv.org/abs/2509.21016>.

<span id="page-32-0"></span>5 Team, Aohan Zeng, Xin Lv, Qinkai Zheng, Zhenyu Hou, Bin Chen, Chengxing Xie, Cunxiang Wang, Da Yin, Hao Zeng, Jiajie Zhang, Kedong Wang, Lucen Zhong, Mingdao Liu, Rui Lu, Shulin Cao, Xiaohan Zhang, Xuancheng Huang, Yao Wei, Yean Cheng, Yifan An, Yilin Niu, Yuanhao Wen, Yushi Bai, Zhengxiao Du, Zihan Wang, Zilin Zhu, Bohan Zhang, Bosi Wen, Bowen Wu, Bowen Xu, Can Huang, Casey Zhao, Changpeng Cai, Chao Yu, Chen Li, Chendi Ge, Chenghua Huang, Chenhui Zhang, Chenxi Xu, Chenzheng Zhu, Chuang Li, Congfeng Yin, Daoyan Lin, Dayong Yang, Dazhi Jiang, Ding Ai, Erle Zhu, Fei Wang, Gengzheng Pan, Guo Wang, Hailong Sun, Haitao Li, Haiyang Li, Haiyi Hu, Hanyu Zhang, Hao Peng, Hao Tai, Haoke Zhang, Haoran Wang, Haoyu Yang, He Liu, He Zhao, Hongwei Liu, Hongxi Yan, Huan Liu, Huilong Chen, Ji Li, Jiajing Zhao, Jiamin Ren, Jian Jiao, Jiani Zhao, Jianyang Yan, Jiaqi Wang, Jiayi Gui, Jiayue Zhao, Jie Liu, Jijie Li, Jing Li, Jing Lu, Jingsen Wang, Jingwei Yuan, Jingxuan Li, Jingzhao Du, Jinhua Du, Jinxin Liu, Junkai Zhi, Junli Gao, Ke Wang, Lekang Yang, Liang Xu, Lin Fan, Lindong Wu, Lintao Ding, Lu Wang, Man Zhang, Minghao Li, Minghuan Xu, Mingming Zhao, Mingshu Zhai, Pengfan Du, Qian Dong, Shangde Lei, Shangqing Tu, Shangtong Yang, Shaoyou Lu, Shijie Li, Shuang Li, Shuang-Li, Shuxun Yang, Sibo Yi, Tianshu Yu, Wei Tian, Weihan Wang, Wenbo Yu, Weng Lam Tam, Wenjie Liang, Wentao Liu, Xiao Wang, Xiaohan Jia, Xiaotao Gu, Xiaoying Ling, Xin Wang, Xing Fan, Xingru Pan, Xinyuan Zhang, Xinze Zhang, Xiuqing Fu, Xunkai Zhang, Yabo Xu, Yandong Wu, Yida Lu, Yidong Wang, Yilin Zhou, Yiming Pan, Ying Zhang, Yingli Wang, Yingru Li, Yinpei Su, Yipeng Geng, Yitong Zhu, Yongkun Yang, Yuhang Li,

- Yuhao Wu, Yujiang Li, Yunan Liu, Yunqing Wang, Yuntao Li, Yuxuan Zhang, Zezhen Liu, Zhen Yang, Zhengda Zhou, Zhongpei Qiao, Zhuoer Feng, Zhuorui Liu, Zichen Zhang, Zihan Wang, Zijun Yao, Zikang Wang, Ziqiang Liu, Ziwei Chai, Zixuan Li, Zuodong Zhao, Wenguang Chen, Jidong Zhai, Bin Xu, Minlie Huang, Hongning Wang, Juanzi Li, Yuxiao Dong, and Jie Tang. Glm-4.5: Agentic, reasoning, and coding (arc) foundation models, 2025. <https://arxiv.org/abs/2508.06471>.
- <span id="page-33-0"></span>Zengzhi Wang, Fan Zhou, Xuefeng Li, and Pengfei Liu. Octothinker: Mid-training incentivizes reinforcement learning scaling, 2025. <https://arxiv.org/abs/2506.20512>.
- <span id="page-33-4"></span>An Yang, Baosong Yang, Binyuan Hui, Bo Zheng, Bowen Yu, Chang Zhou, Chengpeng Li, Chengyuan Li, Dayiheng Liu, Fei Huang, et al. Qwen2 technical report. arXiv preprint arXiv:2407.10671, 2024.
- <span id="page-33-6"></span>Feng Yao, Liyuan Liu, Dinghuai Zhang, Chengyu Dong, Jingbo Shang, and Jianfeng Gao. Your efficient rl framework secretly brings you off-policy rl training, August 2025. <https://fengyao.notion.site/off-policy-rl>.
- <span id="page-33-5"></span>Howard Yen, Tianyu Gao, Minmin Hou, Ke Ding, Daniel Fleischer, Peter Izsak, Moshe Wasserblat, and Danqi Chen. Helmet: How to evaluate long-context language models effectively and thoroughly. In International Conference on Learning Representations (ICLR), 2025.
- <span id="page-33-1"></span>Charlie Zhang, Graham Neubig, and Xiang Yue. On the interplay of pre-training, mid-training, and rl on reasoning language models, 2025. <https://arxiv.org/abs/2512.07783>.
- <span id="page-33-3"></span>Wenting Zhao, Xiang Ren, Jack Hessel, Claire Cardie, Yejin Choi, and Yuntian Deng. Wildchat: 1m chatGPT interaction logs in the wild. In The Twelfth International Conference on Learning Representations, 2024. [https:](https://openreview.net/forum?id=Bl8u7ZRlbM) [//openreview.net/forum?id=Bl8u7ZRlbM](https://openreview.net/forum?id=Bl8u7ZRlbM).
- <span id="page-33-2"></span>Fan Zhou, Zengzhi Wang, Nikhil Ranjan, Zhoujun Cheng, Liping Tang, Guowei He, Zhengzhong Liu, and Eric P. Xing. Megamath: Pushing the limits of open math corpora, 2025. <https://arxiv.org/abs/2504.02807>.

<span id="page-34-2"></span>

| Category                    | Setting         |
|-----------------------------|-----------------|
| Training steps              | 25,000          |
| Micro batch size            | 1               |
| Gradient accumulation steps | 1               |
| Effective batch size        | 1               |
| Optimizer                   | AdamW           |
| Learning rate               | 5 × 10−5        |
| Weight decay                | 0.1             |
| Adam β1, β2                 | (0.9, 0.95)     |
| Adam ϵ                      | 1 × 10−10       |
| Learning rate schedule      | Cosine decay    |
| Warmup steps                | 500             |
| Decay steps                 | 24,500          |
| Final LR factor             | 0.1             |
| Precision                   | bfloat16 (bf16) |
| FSDP algorithm              | 2               |
| Data parallel sharding      | 8               |
| Data parallel replication   | 16              |

Table 16 PRISM mid-training hyperparameters.

| Category                    | Setting           |
|-----------------------------|-------------------|
| Training steps              | 1,000             |
| Micro batch size            | 1                 |
| Gradient accumulation steps | 1                 |
| Effective batch size        | 1                 |
| Evaluation during training  | Disabled          |
| Evaluation interval         | 109<br>steps      |
| Optimizer                   | AdamW             |
| Learning rate               | 5 × 10−5          |
| Weight decay                | 0.1               |
| Adam β1, β2                 | (0.9, 0.95)       |
| Adam ϵ                      | 1 × 10−10         |
| Learning rate schedule      | Exponential decay |
| Warmup steps                | 100               |
| Constant steps              | 0                 |
| Final LR factor             | 0                 |
| Precision                   | bfloat16 (bf16)   |
| FSDP algorithm              | 2                 |
| Context parallelism         | 4                 |
| Data parallel sharding      | 4                 |
| Data parallel replication   | 9                 |
| Gradient checkpointing      | Enabled           |

Table 17 Long-context restoration hyperparameters.

# Appendix

This appendix provides supplementary details for the main paper. We begin with model specifications and training hyperparameters for PRISM mid-training, long-context restoration, and RL (Appendix [A\)](#page-34-0). We then describe our evaluation benchmarks and settings (Appendix [B\)](#page-35-1), followed by extended results tables referenced from the main text (Appendix [C\)](#page-35-2). We present RL training details including the GRPO algorithm and hyperparameters (Appendix [D\)](#page-35-0), RL training curves for Granite-4 Micro Dense (Appendix [E\)](#page-36-2), and additional RL learning curves (Appendix [F\)](#page-37-0). We provide extended mechanistic analyses: RL sub-component weight analysis (Appendix [H\)](#page-40-1), extended CKA representation analysis across four models and three input distributions (Appendix [I\)](#page-41-2), and AIME 2026 evaluation (Appendix [J\)](#page-41-0). Finally, we present qualitative model generations (Appendix [K\)](#page-42-1).

# <span id="page-34-0"></span>A Model and Training Details

#### A.1 Model Specifications

To evaluate the cross-architecture robustness of PRISM, we select a diverse set of LLMs ranging from 3B to 24B parameters, including dense Transformers and attention-Mamba hybrids.

Dense Transformer Models: We utilize LLaMA-3.1 8B [\(Grattafiori et al.,](#page-29-2) [2024\)](#page-29-2) and Mistral-7B-v0.1 [\(Jiang et al.,](#page-30-5) [2023\)](#page-30-5) as primary baselines. For enterprise-focused evaluation, we include Granite-3.3 8B [\(Granite Team,](#page-29-1) [IBM,](#page-29-1) [2025\)](#page-29-1) and the lightweight Granite-4.0 Micro 3B [\(IBM Granite Team,](#page-30-6) [2025\)](#page-30-6), alongside the larger Mistral-Small-24B [\(Mistral AI Team,](#page-31-5) [2025\)](#page-31-5).

Hybrid Attention-Mamba Architectures: We include Granite-4.0-H Micro 3B and Nemotron-H 8B, which alternate between standard attention layers and Mamba2 layers, representing the hybrid paradigm.

#### A.2 PRISM Training Details

<span id="page-34-1"></span>Table [16](#page-34-2) summarizes the training hyperparameters used for PRISM mid-training across all models unless otherwise specified.

<span id="page-35-3"></span>

| Dataset                   | Type                | Tokens (B) |
|---------------------------|---------------------|------------|
| DCLM-EDU                  | General Web Data    | 2.51       |
| Nemotron Post-Training v1 | Math (QA/Reasoning) | 5.08       |
| Megamath-Web-Pro          | Math (web)          | 4.33       |
| StarCoder2                | Code (web)          | 37.52      |
| xenArcAI-codex            | Code (QA/Reasoning) | 3.860      |

Table 18 Datasets used in the long-context extension phase. Token counts in billions (Granite 3.3, 8B).

### A.3 Long-Context Extension Phase

Table [17](#page-34-2) summarizes the hyperparameters used for the long-context extension phase applied after mid-training, and Table [18](#page-35-3) lists the datasets used.

Long-context sequence packing via Best-Fit Decreasing (BFD). To efficiently construct fixed-length long-context training sequences while minimizing truncation and wasted capacity, we employ a Best-Fit Decreasing (BFD) packing strategy. Documents are optionally split into overlapping chunks if they exceed the target context length L, then sorted in decreasing order of length. Each chunk is greedily assigned to an existing sequence buffer whose remaining capacity is sufficient and minimal among all feasible buffers; if no such buffer exists, a new buffer is created. Compared to naive concatenation or first-fit strategies, BFD packing significantly reduces unnecessary document truncation and improves token utilization while preserving document-level coherence.

# <span id="page-35-1"></span>B Evaluation Details

Benchmark details. General ability is assessed via LB-V1 (ARC, HellaSwag, MMLU, TruthfulQA, Wino-Grande, GSM8K) and LB-V2 (IFEval, BBH, MATH, GPQA, MuSR, MMLU-Pro), which detect generalization regressions. Long-context capabilities are validated by RULER [\(Hsieh et al.,](#page-30-4) [2024\)](#page-30-4), which measures effective reasoning across massive token windows. LiveCodeBench [\(Jain et al.,](#page-30-3) [2024\)](#page-30-3) and Codeforces [\(Penedo](#page-32-3) [et al.,](#page-32-3) [2025\)](#page-32-3) provide contamination-free code evaluation using time-stratified problems and elite algorithmic challenges. AIME [\(AIME\)](#page-28-5) and MATH500 [\(Lightman et al.,](#page-31-4) [2023\)](#page-31-4) track mathematical proficiency, highly sensitive to data mixture quality. GPQA-Diamond [\(Rein et al.,](#page-32-4) [2023\)](#page-32-4) offers "Google-proof" PhD-level science challenges.

Evaluation settings. For math benchmarks (MATH500, AIME24/25), we use 32k max generation tokens, temperature 0.6, top-p 0.95, and 64 samples per prompt. For code benchmarks (Codeforces, LiveCodeBench), we use 32k max generation tokens, temperature 0.7, and 3 samples per prompt. Math benchmarks are evaluated using Qwen-eval [\(Yang et al.,](#page-33-4) [2024\)](#page-33-4), code benchmarks using Evalchemy [\(Raoof et al.,](#page-32-6) [2025\)](#page-32-6), and RULER using HELMET [\(Yen et al.,](#page-33-5) [2025\)](#page-33-5).

## <span id="page-35-2"></span>C Extended Results Tables

This section presents the full benchmark breakdowns referenced in the main text. Table [19](#page-36-0) provides the perbenchmark results for the Granite-3.3-8B domain ablation (Math only, Math+Code, Math+Code+Science), complementing the summary in Section 5. Table [20](#page-36-1) reports the token-budget scaling experiment on Granite-4 Micro (3B), showing how performance evolves as the mid-training budget increases from 10.5B to 31.5B tokens.

# <span id="page-35-0"></span>D RL Training Details

We use Group Relative Policy Optimization (GRPO) [\(Shao et al.,](#page-32-7) [2024\)](#page-32-7) as our RL algorithm for all models. The objective and advantage computation are:

<span id="page-36-0"></span>

|                       |               | Code       |          | Science      |         |         | Math     |          |
|-----------------------|---------------|------------|----------|--------------|---------|---------|----------|----------|
| Model / Mixture       | LiveCodeBench | Codeforces | Code Avg | GPQA-Diamond | AIME 24 | AIME 25 | MATH 500 | Math Avg |
| Base                  | 2.15          | 1.99       | 2.07     | 22.56        | 0.46    | 0.31    | 26.09    | 8.95     |
| Math only             | 2.15          | 3.46       | 2.81     | 17.34        | 26.72   | 22.08   | 60.50    | 36.43    |
| Math + Code           | 11.11         | 10.30      | 10.71    | 19.02        | 32.44   | 28.33   | 74.22    | 44.33    |
| Math + Code + Science | 10.63         | 10.52      | 10.58    | 29.12        | 37.18   | 27.96   | 81.11    | 48.75    |

Table 19 Domain-specific evaluation results for Granite-3.3-8B (full breakdown). Code Avg is the mean of LiveCodeBench and Codeforces; Math Avg is the mean of AIME 24, AIME 25, and MATH 500.

<span id="page-36-1"></span>

| Token Budget (B) | LB V1 | LB V2 | LCB   | CF   | Code Avg | GPQA-D | AIME24 | AIME25 | MATH500 | Math Avg |
|------------------|-------|-------|-------|------|----------|--------|--------|--------|---------|----------|
| Base             | 66.01 | 21.82 | 0.24  | 2.28 | 1.26     | 21.55  | 16.09  | 12.34  | 50.42   | 26.28    |
| 10.49            | 63.45 | 19.50 | 10.51 | 8.68 | 9.59     | 19.19  | 23.95  | 19.17  | 77.52   | 40.21    |
| 15.73            | 63.24 | 19.79 | 10.75 | 7.28 | 9.02     | 23.06  | 26.14  | 21.30  | 78.76   | 42.07    |
| 26.21            | 63.28 | 19.63 | 9.80  | 7.58 | 8.69     | 19.19  | 28.49  | 20.10  | 78.08   | 42.22    |
| 31.46            | 63.16 | 20.05 | 8.24  | 6.99 | 7.62     | 21.38  | 28.02  | 22.08  | 77.15   | 42.42    |

Table 20 Effect of increasing mid-training token budget on Granite-4 Micro (3B) using the Math+Code mixture with fixed 8k context length. LCB denotes LiveCodeBench, CF denotes Codeforces, and GPQA-D denotes GPQA-Diamond. Code Avg averages LCB and CF, while Math Avg averages AIME24, AIME25, and MATH500.

$$\mathcal{J}_{GRPO}(\theta) = \mathbb{E}_{q \sim P(Q), \{o_i\}_{i=1}^G \sim \pi_{\thetagen}} \left[ \frac{1}{\sum_{j=1}^G |o_j|} \sum_{i=1}^G \sum_{t=1}^{|o_i|} \right]$$

$$\min\left(\frac{\pi_{\theta_{old}}(o_{i,t}|q)}{\pi_{\theta_{gen}}(o_{i,t}|q)}, C\right) \times$$

$$\min\left(\frac{\pi_{\theta}(o_{i,t}|q)}{\pi_{\theta_{old}}(o_{i,t}|q)} \hat{A}_i, \right)$$

$$\operatorname{clip}\left(\frac{\pi_{\theta}(o_{i,t}|q)}{\pi_{\theta_{old}}(o_{i,t}|q)}, 1 - \epsilon_{\text{low}}, 1 + \epsilon_{\text{high}}\right) \hat{A}_i$$

$$-\beta \mathbb{D}_{KL}[\pi_{\theta}||\pi_{ref}]$$
(5)

$$\hat{A}_i = \frac{r_i - \text{mean}(r_1, \dots, r_G)}{\text{std}(r_1, \dots, r_G) + \eta}$$
(6)

Table [21](#page-37-1) provides the full RL training configuration. We use on-policy model updates (train\_batch\_size = inference\_batch\_size). Following [\(Gorbatovski et al.,](#page-29-3) [2025\)](#page-29-3), we soft-update the reference policy for better convergence. Since our mid-training data teaches the model to think, we apply a thinking format reward: the model's response is evaluated for correctness only if it adheres to the format <think> thoughts </think> response, otherwise it receives a reward of 0.0. We also apply stop-token and repetition penalties. We apply the Truncated Importance Sampling ratio [\(Yao et al.,](#page-33-6) [2025\)](#page-33-6) to control for training-inference mismatch. All experiments use the open-instruct codebase.[2](#page-36-3)

# <span id="page-36-2"></span>E RL Training Curves for Granite-4 Micro Dense

Figure [17](#page-37-2) shows the RL training dynamics for Granite-4 Micro Dense (3B) after PRISM mid-training with the Math+Code+Science mixture. Despite being the smallest model in our study, RL training is stable across all domains. The overall verifiable correctness rate rises steadily from ∼0.48 to ∼0.72 over 2k steps (Figure [17a\)](#page-37-2). Domain-specific curves show consistent trends: math correctness climbs from ∼0.52 to ∼0.70 (Figure [17b\)](#page-37-2),

<span id="page-36-3"></span><sup>2</sup>https://github.com/allenai/open-instruct/tree/main

<span id="page-37-1"></span>Table 21 RL training hyperparameters and configuration.

| Hyperparameter            | Value                  |
|---------------------------|------------------------|
| Sampling Parameters       |                        |
| Responses per Prompt      | 16                     |
| Temperature               | 1.0                    |
| Top-p                     | 1.0                    |
| Training Dynamics         |                        |
| Total Batch Size          | 1024                   |
| Unique Prompts per Batch  | 64                     |
| Training Steps            | 1,000                  |
| Context Length            | 16,384                 |
| Learning Rate             | 5 × 10−7               |
| LR Schedule               | Linear Decay           |
| KL-loss Beta (β)          | 0.05                   |
| RL Environment & Rewards  |                        |
| Importance Sampling Ratio | 1.0 (On-policy)        |
| Truncated IS Constant (C) | 2.0                    |
| Format Reward             | <think><br/></think>   |
| Penalties                 | Stop token, Repetition |
| Reference Policy Update   | Soft-update            |
| Infrastructure            |                        |
| Optimizer                 | AdamW                  |
| Parallelism Strategy      | DeepSpeed Stage 3      |
| Packing Length            | 16,384                 |

<span id="page-37-2"></span>Figure 17 RL training correctness curves for Granite-4 Micro Dense (3B) after PRISM mid-training. All four domains show stable, monotonically improving training dynamics over 2k steps.

science correctness from ∼0.45 to ∼0.78 (Figure [17c\)](#page-37-2), and code correctness from ∼0.35 to ∼0.65 (Figure [17d\)](#page-37-2). These results confirm that the PRISM mid-training recipe produces a stable foundation for RL even at the 3B scale.

# <span id="page-37-0"></span>F Additional RL Learning Curves

This section provides RL learning curves for models not shown in the main text, including PRISM RL results (Figs. [18–](#page-38-0)[20\)](#page-39-1), base model RL results (Figs. [21–](#page-40-0)[22\)](#page-41-1), and balanced mix RL results (Figs. [23–](#page-42-0)[25\)](#page-44-0).

### F.1 PRISM RL: Additional Models

Figures [18–](#page-38-0)[20](#page-39-1) present the RL learning curves for models not featured in the main text: Mistral-7B, LLaMA-3.1-8B, and Granite-4 Micro Dense (3B). All three models follow the same pattern observed for Granite-3.3-8B in the main paper: monotonically increasing correctness rates across math, code, and science benchmarks

with non-saturating trajectories, confirming that the benefits of the  $PRISM \to RL$  pipeline generalize across model families and scales.

<span id="page-38-0"></span>Figure 18 PRISM  $\rightarrow$  RL: Mistral-7B. Consistent improvements across code and math benchmarks using the unbalanced MCS mix.

#### F.2 RL on Base Models (No Mid-Training)

Figures 21–22 show what happens when RL is applied directly to base models without any mid-training. In both LLaMA-3.1-8B and Mistral-7B, AIME24 and AIME25 scores remain near zero throughout training, and GPQA-Diamond either stagnates or regresses below the base model's level. These results stand in stark contrast to the large, sustained gains observed when RL follows PRISM mid-training (Figures 18–20), reinforcing the finding from Section 7 that mid-training provides the reasoning substrate necessary for RL to be effective.

#### F.3 Balanced Mix RL: Additional Models

Figures 23–25 present RL learning curves when using the balanced RL data mix (equal math, code, and science sampling) for models not shown in the main text. The balanced mix produces comparable overall gains to the unbalanced mix across most models, with modest differences in domain-specific performance. Notably, Granite-4-H Micro (Figure 25) achieves the largest balanced-mix improvements among small models, with +8.09 on Codeforces and +11.95 on GPQA-Diamond, suggesting that hybrid architectures respond well to domain-balanced RL training.

### <span id="page-38-1"></span>G Sparsity Threshold Sensitivity

Table 22 shows that the dense/sparse asymmetry between mid-training and RL holds at every threshold from 0.1% to 10%. At the 1% threshold used in the main text, RL leaves 95.0% of Granite-3.3 parameters

<span id="page-39-0"></span><span id="page-39-1"></span>Figure 19 PRISM  $\rightarrow$  RL: LLaMA-3.1-8B. Stable, monotonic gains across all reasoning benchmarks.

Figure 20 PRISM  $\rightarrow$  RL: Granite-4 Micro Dense (3B). Consistent but smaller absolute gains compared to 8B models.

<span id="page-40-0"></span>Figure 21 RL on LLaMA-3.1-8B base (no mid-training). AIME24/25 remain near zero; GPQA-Diamond regresses below the base model.

<span id="page-40-2"></span>unchanged; even at 0.1%, 82.3% remain unchanged. Conversely, mid-training changes the vast majority of parameters at all thresholds. The conclusions in Section 10.1 are robust to the choice of threshold.

| Threshold (%) | Base→MT unchanged | MT→RL unchanged |
|---------------|-------------------|-----------------|
| 0.1           | 2.1%              | 82.3%           |
| 0.5           | 2.4%              | 87.3%           |
| 1.0           | 3.5%              | 95.0%           |
| 2.0           | 5.3%              | 97.5%           |
| 5.0           | 11.1%             | 99.0%           |
| 10.0          | 20.1%             | 99.5%           |

Table 22 Per-element sparsity at different relative change thresholds (Granite-3.3, 8B). The dense/sparse asymmetry between mid-training and RL is robust across all tested thresholds. Bold row shows the 1% threshold used in the main text.

# <span id="page-40-1"></span>H RL Sub-component Weight Analysis

We decompose the weight divergence analysis from Section 10.1 at a finer granularity, breaking each component into individual weight matrices: Q, K, V, O projections for attention; gate, up, down projections for MLP; and in\_proj, out\_proj, conv1d, A, dt for Mamba layers. Table 23 reports the fraction of parameters changed (>1% relative change) for each sub-component across four conditions:  $MT \rightarrow RL$  and  $Base \rightarrow RL$  (no mid-training) for both Granite-3.3 and Nemotron-H.

Figure 26 visualizes the MT $\rightarrow$ RL and Base $\rightarrow$ RL distributions side by side. Three findings emerge. First, RL's sub-component targeting is *identical* regardless of whether mid-training preceded it: the  $\Delta$  column shows differences of at most 1.8 percentage points, with most below 1 point. Second, value (V) and output

<span id="page-41-1"></span>Figure 22 RL on Mistral-7B base (no mid-training). Limited and unstable gains; AIME24/25 remain near zero throughout.

(O) projections are consistently the most affected sub-components during RL, in both Granite-3.3 (5.7%, 5.6%) and Nemotron-H (8.5%, 7.2%), suggesting that RL preferentially adjusts how models read from and write to the residual stream. Third, Mamba parameters (A, dt) are completely frozen during RL (<0.1% changed), while the learned projection matrices (in\_proj, out\_proj) change at rates comparable to attention projections, indicating that RL respects the architectural priors encoded in the SSM state dynamics.

### <span id="page-41-2"></span>I Extended CKA Representation Analysis

This section provides the full CKA representation similarity analysis across three models (Granite-3.3, LLaMA-3.1, Nemotron-H) and three input distributions (Wikipedia, C4, GSM8K), complementing the main-text results in Section 10.2. All experiments use 200 prompts per input type and batch-size-1 encoding. Each figure contains three panels corresponding to the three input types. In each panel, the x-axis is the layer index and the y-axis is the linear CKA score (Kornblith et al., 2019) between the mean-pooled hidden representations. Three pairwise comparisons are shown: Base vs. MT (blue), Base vs. RL (pink), and MT vs. RL (green). CKA=1.0 indicates identical representational geometry; lower values indicate greater divergence.

<span id="page-41-0"></span>All models (Figures 27, 28, 29). The one consistent finding across all three models is that MT vs. RL remains >0.998 at every layer across all three input distributions, for both dense Transformers and hybrid attention-Mamba architectures. The Base vs. MT divergence pattern, however, is model-specific: Granite-3.3 shows its deepest dip at the output layer on GSM8K; LLaMA-3.1 shows its deepest dip on C4 web text rather than math prompts; and Nemotron-H shows broader divergence across later middle layers. Since each model has a different pretraining distribution, the representational effects of mid-training cannot be universally characterized, they depend on what the base model already learned. Base vs. MT and Base vs. RL are nearly identical in all cases, confirming that RL contributes no additional representational shift.

<span id="page-42-0"></span>Figure 23 PRISM  $\rightarrow$  RL with balanced mix: Mistral-Small 24B. GPQA-Diamond gain (+25.93) slightly lower than unbalanced mix.

### J AIME 2026 Evaluation

To test generalization to a recently released benchmark, we evaluate two PRISM mid-trained models on AIME 2026 (Mathematical Association of America, 2026), which was published after the completion of all our training runs. Figure 30 shows AIME26 accuracy across RL training steps for Granite-3.3 (8B) and Mistral-Small (24B). Both models show consistent improvement over RL training: Granite-3.3 improves from  $\sim 33\%$  to  $\sim 37\%$ , and Mistral-Small from  $\sim 30\%$  to  $\sim 38\%$ . These results confirm that the gains from the PRISM  $\rightarrow$  RL pipeline transfer to held-out math benchmarks unseen during training.

### <span id="page-42-1"></span>**K** Model Generations

This section provides qualitative examples of model outputs at each stage of the PRISM pipeline: base model, after mid-training, and after RL. We show generations from Granite-3.3-8B on representative math, code, and science prompts. These examples illustrate how mid-training introduces structured reasoning (e.g., step-by-step problem decomposition) that is absent in the base model, and how RL further refines the reasoning chains with more accurate and complete solutions.

Note on failure modes. Some base model and mid-trained model generations exhibit repetitive or looping outputs. We distinguish three qualitatively different failure modes observed in these examples: (1) Base model loops: the base model lacks instruction fine-tuning and may produce repetitive token sequences when it lacks a clear completion signal; (2) Mid-trained model loops: the mid-trained model has learned chain-of-thought formatting but may enter repetitive patterns on out-of-distribution prompt structures where the reasoning format does not terminate cleanly; (3) RL model: RL applies stop-token and repetition penalties during training, so the RL-trained model consistently terminates outputs correctly. These failure modes are expected and illustrate why formatting rewards and repetition penalties are important components of the RL training

<span id="page-43-0"></span>(a) LiveCodeBench, Codeforces, and GPQA-Diamond over RL steps.

(b) AIME24, AIME25, and MATH500 over RL steps.

Figure 24 PRISM  $\rightarrow$  RL with balanced mix: Granite-4 Micro Dense (3B). Code and GPQA-Diamond gains are notable (+4.30 LCB, +6.06 GPQA).

recipe.

#### K.1 Math Prompt

In a car dealership with some cars, 60% of the cars are hybrids, and 40% of the hybrids contain only one headlight. There are 216 hybrids with full headlights. How many cars are there in the dealership?

Please put your final answer in \boxed{} format.

### K.2 Granite 3.3 8b base math generation

The correct answer for the above problem is 600; however, the base model gets it wrong probably because it rushes to the final answer (using **192 tokens**) without reasoning about the possible steps.

```
Let's solve this problem using Python's sympy library.
'''python\nimport sympy as sp

# let's denote the number of cars as x
x = sp.symbols('x')
```

#### Granite-4 Micro-H 3B (Base → PRISM → RL)

<span id="page-44-0"></span>(a) LiveCodeBench, Codeforces, and GPQA-Diamond over RL steps.

(b) AIME24, AIME25, and MATH500 over RL steps.

Figure 25 PRISM  $\rightarrow$  RL with balanced mix: Granite-4-H Micro (Hybrid, 3B). Largest balanced-mix gains among small models, with +8.09 on Codeforces and +11.95 on GPQA-Diamond.

<span id="page-44-1"></span>Figure 26 RL targets the same sub-components regardless of starting point. Fraction of parameters changed (>1% relative change) during RL for Granite-3.3 (left) and Nemotron-H (right), comparing MT $\rightarrow$ RL (blue) vs. Base $\rightarrow$ RL (pink). The near-identical distributions confirm that RL's sub-component targeting is intrinsic to the optimization, not a consequence of mid-training.

```
# 60% of the cars are hybrids
hybrids = 0.6 * x

# 40% of the hybrids contain only one headlight
hybrids_with_one_headlight = 0.4 * hybrids
```

<span id="page-45-0"></span>

|                 |         | Granite-3. | 3 (8B)  |      | Nemotron-H (8B) |       |         |      |
|-----------------|---------|------------|---------|------|-----------------|-------|---------|------|
| Sub-component   | Base→MT | MT→RL      | Base→RL | Δ    | Base→MT         | MT→RL | Base→RL | Δ    |
| Attn: Q         | 83.5%   | 4.4%       | 5.2%    | +0.8 | 97.5%           | 5.5%  | 4.9%    | -0.6 |
| Attn: K         | 83.2%   | 4.6%       | 5.2%    | +0.6 | 96.9%           | 5.5%  | 4.8%    | -0.7 |
| Attn: V         | 97.9%   | 5.7%       | 7.5%    | +1.8 | 97.1%           | 8.5%  | 7.6%    | -0.9 |
| Attn: O         | 98.0%   | 5.6%       | 6.7%    | +1.1 | 97.2%           | 7.2%  | 6.4%    | -0.8 |
| MLP: gate       | 98.3%   | 5.4%       | 6.1%    | +0.7 | _               | _     | _       | _    |
| MLP: up         | 97.9%   | 4.9%       | 5.5%    | +0.6 | _               | _     | _       | _    |
| MLP: down       | 98.0%   | 5.0%       | 5.6%    | +0.6 | _               | _     | _       | _    |
| Mamba: in proj  | _       | _          | -       | _    | 97.8%           | 5.9%  | 5.5%    | -0.4 |
| Mamba: out proj |         | _          | _       | _    | 97.8%           | 6.5%  | 5.9%    | -0.6 |
| Mamba: conv1d   |         | _          | _       | _    | 91.7%           | 17.4% | 17.7%   | +0.3 |
| Mamba: A/dt     | _       | _          | _       | _    | 97.5%           | 0.0%  | 0.0%    | 0.0  |
| Embed/LM-head   | 97.5%   | 2.4%       | 2.6%    | +0.2 | 97.9%           | 7.3%  | 6.7%    | -0.6 |
| Norm            | 11.9%   | 1.2%       | 0.1%    | -1.1 | 61.3%           | 0.1%  | 0.1%    | 0.0  |

Table 23 Sub-component weight analysis: % of parameters changed (>1% relative change) across pipeline transitions.  $\Delta = \text{difference}$  between Base $\rightarrow$ RL and MT $\rightarrow$ RL. The near-zero  $\Delta$  values confirm that RL targets the same sub-components in the same proportions regardless of starting point. Value and output projections are consistently the most affected by RL across both architectures, while Mamba parameters (A, dt) and norms remain frozen.

<span id="page-45-1"></span>Figure 27 CKA across input distributions: Granite-3.3 (8B). MT vs. RL (green) remains  $\approx 1.0$  on all three inputs. Base vs. MT divergence is input-dependent: strongest on GSM8K math prompts (min 0.55), weakest on C4 general text (min 0.94).

```
# there are 216 hybrids with full headlights\neq = sp.Eq(hybrids - hybrids_with_one_headlight, 216)

# solving for x to get the number of cars
sp.solve(eq, x)[0]

Thus there are \boxed{360} cars in the dealership.
```

#### K.3 Granite 3.3 8b midtrain math generation

Owing to mid-training, the base model learns to reason before coming to a final answer, and it gives the right answer using a total of **933 tokens.** 

#### CKA: LLaMA-3.1 (8B)

<span id="page-46-0"></span>Figure 28 CKA across input distributions: LLaMA-3.1 (8B). Same pattern as Granite-3.3: MT vs.  $RL \approx 1.0$  everywhere, confirming the finding generalizes across dense Transformer families.

#### CKA: Nemotron-H (8B, Hybrid)

<span id="page-46-1"></span>Figure 29 CKA across input distributions: Nemotron-H (8B, Hybrid). MT vs. RL >0.998 on all three inputs, consistent with all other models. Base vs. MT divergence is most pronounced on GSM8K math prompts (min  $\approx$ 0.41), reflecting mid-training's targeted restructuring of reasoning-relevant representations.

<think>

Okay, let's see. I need to find the total number of cars in the dealership. The problem says that 60% of the cars are hybrids, and 40% of the hybrids have only one headlight. There are 216 hybrids with full headlights. Hmm, so I need to relate these percentages to the total number of cars.

First, let me break down the information. Let's denote the total number of cars as T. Then, the number of hybrids would be 60% of T, which is 0.6T. Out of these hybrids, 40% have only one headlight. So, the number of hybrids with one headlight is 40% of 0.6T. Let me write that out:

Number of hybrids with one headlight = 40% of hybrids = 0.4 \* 0.6T = 0.24T.

But wait, the problem states that there are 216 hybrids with full headlights. So, the number of hybrids with full headlights is 100% - 40% = 60% of the hybrids. That would be  $0.6 \times 0.6T = 0.36T$ . But they told us that this number is 216. So, 0.36T = 216.

<span id="page-47-0"></span>Figure 30 AIME 2026 accuracy over RL training steps. Both Granite-3.3 (8B) and Mistral-Small (24B) show steady gains on this recently released benchmark, confirming generalization of the PRISM → RL pipeline.

```
To find T, I can set up the equation:
0.36T = 216
Then, divide both sides by 0.36:
T = 216 / 0.36
Let me compute that. 216 divided by 0.36. Hmm, 0.36 goes into 216 how many times?
Well, 0.36 * 600 = 216, because 0.36 * 100 = 36, so 36 * 6 = 216. So, 0.36 * 600
= 216. Therefore, T = 600.
Wait, so the total number of cars is 600? Let me check that again to make sure I
didn't make a mistake.
Total cars: 600.
Number of hybrids: 60% of 600 = 0.6 * 600 = 360.
Number of hybrids with one headlight: 40% of 360 = 0.4 * 360 = 144.
Therefore, number of hybrids with full headlights: 360 - 144 = 216. Which matches
 the given information. So that checks out.
Therefore, the total number of cars in the dealership is 600.
**Final Answer**
The total number of cars in the dealership is \boxed{600}.
</think>
Let \( T \) be the total number of cars in the dealership.
```

```
60% of the cars are hybrids, so the number of hybrids is \( 0.6T \).
40% of the hybrids have only one headlight, so the number of hybrids with one
headlight is \( 0.4 \times 0.6T = 0.24T \).
The number of hybrids with full headlights is 60% of the hybrids, which is \( 0.6
 \times 0.6T = 0.36T \).
We are given that there are 216 hybrids with full headlights. Therefore, we set
up the equation:
\[
0.36T = 216
\]
Solving for \( T \):
\[
T = \frac{216}{0.36} = 600
\]
Thus, the total number of cars in the dealership is \(\boxed{600}\).
```

### K.4 Granite 3.3 8b P RISM− > RL math generation

The RL-trained model gives the right answer too using a total of 917 tokens.

```
<think>
Okay, let's see. So the problem is about a car dealership where 60% of the cars
are hybrids. Then, 40% of those hybrids have only one headlight. And we know
there are 216 hybrids with full headlights. The question is asking how many cars
are in the dealership in total. Hmm, okay.
First, let me parse this step by step. Let's denote the total number of cars in
the dealership as, let's say, T. Out of these T cars, 60% are hybrids. So the
number of hybrid cars would be 0.6T. Then, among these hybrids, 40% have only one
 headlight. That means 60% of the hybrids have full headlights. Wait, but the
problem says 40% of the hybrids contain only one headlight. So that would mean
60% have full headlights. But they mention that there are 216 hybrids with full
headlights. So that 60% of the hybrids equals 216.
So, if I set up an equation here: 0.6 * (number of hybrids) = 216. But the number
 of hybrids is 0.6T. So substituting that in, we get 0.6 * 0.6T = 216. Let me
write that out:
0.6 * 0.6T = 216
Calculating 0.6 times 0.6 is 0.36. So:
0.36T = 216
To find T, we divide both sides by 0.36:
T = 216 / 0.36
```

```
Hmm, let me compute that. 216 divided by 0.36. Well, 0.36 is 36/100, so dividing
by 36/100 is the same as multiplying by 100/36. So 216 * (100/36). Let's compute
that.
First, 216 divided by 36 is 6. Then, 6 times 100 is 600. So T = 600.
Wait, so the total number of cars is 600? Let me check that again to make sure I
didn't make a mistake.
So, 60% of the cars are hybrids. If there are 600 cars total, then 0.6 * 600 =
360 hybrids. Then, 40% of the hybrids have one headlight, so 60% have full
headlights. 60% of 360 is 0.6 * 360 = 216. Which matches the given number. So
that seems correct.
Therefore, the total number of cars in the dealership is 600.
**Final Answer**
The total number of cars in the dealership is \boxed{600}.
</think>
Let \( T \) be the total number of cars in the dealership.
60% of the cars are hybrids, so the number of hybrid cars is \( 0.6T \).
40% of the hybrids have only one headlight, which means 60% of the hybrids have
full headlights. We are given that there are 216 hybrids with full headlights.
We set up the equation:
\[
0.6 \times 0.6T = 216
\]
Simplifying this, we get:
\[
0.36T = 216
\]
Solving for \( T \):
\[
T = \frac{216}{0.36} = 600
\]
Thus, the total number of cars in the dealership is \(\boxed{600}\).
```

### K.5 Code Prompt

Solve the following coding problem using the programming language python:

A convex polygon consisting of N vertices is given. The coordinates of each vertex are represented counterclockwise by (X1, Y1), (X2, Y2), ..., (XN, YN). No matter what straight line passes through the point P, find the coordinates of the point P so that the areas of the two convex polygons obtained after cutting are equal.

```
Constraints
* All inputs are integers
* 3 <= N <= 50
* 0 <= | Xi |, | Yi | <= 1000000
* The input polygon is a simple convex polygon.
* The output must satisfy max (| X-cX |, | Y-cY |) <= 0.0001 when the output
coordinates are (X, Y) and the exact solution is (cX, cY).
Input
The input is given in the following format.
> N
> X1 Y1
> X2 Y2
> ...
> XN YN
>
Output
If there is a point that satisfies the condition of the problem statement, the
coordinates of that point
> X Y
>
Output in the format of. If the point does not exist, output "NA" on one line.
Examples
Input
4
100 100
0 100
0 0
100 0
Output
50.00000 50.00000
Input
3
100 100
0 100
0 0
Output
NA
```

```
The input will be stdin and you should print your solution to stdout
Now solve the problem and return the code.
```

### K.6 Granite 3.3 8b base code generation

Similar to the math question, the base model jumps to the final answer without reasoning about it, using a total of 246 tokens.

```
'''python
import sys
def solve():
    N = int(sys.stdin.readline())
    x = [0] * N
    y = [0] * N
    for i in range(N):
        xi, yi = map(int, sys.stdin.readline().split())
        x[i] = xi
        y[i] = yi
    if N % 2 == 1:
        print('NA')
        return
    x_sum = sum(x)
    y_sum = sum(y)
    x_avg = x_sum / N
    y_avg = y_sum / N
    x_diff = 0
    y_diff = 0
    for i in range(N):
        x_diff += (x[i] - x_avg) ** 2
        y_diff += (y[i] - y_avg) ** 2
    if x_diff == y_diff:
        print('%.8f %.8f' % (x_avg, y_avg))
    else:
        print('NA')
if __name__ == '__main__':
    solve()
'''
```

#### K.7 Granite 3.3 8b midtrain code generation

Here, the mid-trained model is also not able to solve this coding problem and ends up exhausting its 8k context limit. We have truncated its response for brevity using dashed lines since it entered a repeating loop

```
Assistant: To solve this problem, we need to find a point P inside the convex
polygon such that any line passing through P divides the polygon into two regions
 of equal area. This point is known as the centroid of the polygon.
The centroid of a polygon can be found by calculating the average of the x-
coordinates and the average of the y-coordinates of all the vertices.
Here's the Python code to solve the problem:
'''python
def main():
    import sys
    input = sys.stdin.read().split()
    idx = 0
    N = int(input[idx])
    idx += 1
    points = []
    for _ in range(N):
        x = int(input[idx])
        y = int(input[idx+1])
        points.append((x, y))
        idx += 2
    # Calculate the centroid
    cx = sum(x for x, y in points) / N
    cy = sum(y for x, y in points) / N
    # Check if the centroid is inside the polygon
    # (This step is optional and can be omitted for convex polygons)
    # ...
    # Output the centroid
    print("{0:.5f} {1:.5f}".format(cx, cy))
if __name__ == "__main__":
    main()
'''
This code reads the input, calculates the centroid of the polygon, and outputs
the coordinates of the centroid. The centroid is guaranteed to be inside the
convex polygon, so we don't need to check if it's inside.
The output is formatted to 5 decimal places, which satisfies the condition of the
 problem statement.
User: The code is not correct.
Assistant: I apologize for the confusion. The centroid of a polygon is indeed the
 point that divides the polygon into two regions of equal area when any line
passes through it. However, the centroid is not always inside the polygon,
especially for concave polygons. For convex polygons, the centroid is always
inside.
Here's the corrected code that calculates the centroid of the convex polygon:
'''python
def main():
    import sys
```

```
input = sys.stdin.read().split()
    idx = 0
    N = int(input[idx])
    idx += 1
    points = []
    for _ in range(N):
        x = int(input[idx])
        y = int(input[idx+1])
        points.append((x, y))
        idx += 2
    # Calculate the centroid
    cx = sum(x for x, y in points) / N
    cy = sum(y for x, y in points) / N
    # Output the centroid
    print("{0:.5f} {1:.5f}".format(cx, cy))
if __name__ == "__main__":
    main()
'''
---------------------------------
```

### <span id="page-53-0"></span>K.8 Granite 3.3 8b P RISM− > RL code generation

The RL trained model does well on this prompt and produces the correct solution using a total of 7864 tokens. For ease of reading, we have truncated its thought process using dashed lines.

```
<think>
Okay, let's see. The problem is to find a point P inside a convex polygon such
that any line through P divides the polygon into two regions of equal area. Hmm.
Wait, that's a bit tricky. Because the condition has to hold for any line passing
 through P. So P must be such that every line through it splits the area equally.
Wait, but how is that possible? For example, in a square, the center is the point
 where any line through it divides the area into two equal parts. So the center
is the solution. So the problem is to find the centroid of the polygon. Because
the centroid has the property that any line through it divides the area into two
equal parts. But wait, is that true? Or is that only for certain shapes?
Wait, no. The centroid (or geometric center) of a shape is the average of all the
 points. But does that mean that any line through the centroid splits the area
into two equal parts? I think that's only true for certain symmetric shapes. For
example, in a rectangle, the centroid is the center, and any line through the
center divides it into two equal areas. But for a triangle, the centroid is the
intersection of the medians, and any line through the centroid divides the
triangle into two regions of equal area. Wait, is that correct?
Wait, no. For a triangle, the centroid divides each median into a 2:1 ratio. But
if you take a line through the centroid that's not a median, does it split the
area equally? Let's think. Suppose you have a triangle with vertices (0,0), (2,0),
 (0,2). The centroid is at (2/3, 2/3). If I draw a line from (2/3, 2/3) to (1,0),
 which is a point on the base. The area on one side would be a triangle and a
quadrilateral. Wait, maybe not. Let me calculate. The line from centroid to (1,0)
```

would split the triangle into two parts. The area of the part below the line would be a trapezoid. Let's compute. The original area is 2. The line from (2/3, 2/3) to (1,0). The area below the line would be a trapezoid with vertices (0,0), (2,0), (1,0), (2/3, 2/3). Wait, maybe not. Alternatively, perhaps the area is a triangle and a quadrilateral. Hmm, maybe I should compute it.

Alternatively, perhaps the centroid is the only point where any line through it divides the area into two equal parts. But I'm not sure. Wait, according to some geometric properties, the centroid (or the center of mass) has the property that any line through it divides the shape into two regions with equal moments. But moments are related to the area times the distance from the line. So if the line passes through the centroid, then the moments on either side are equal. But the actual area on each side depends on the line's orientation. So maybe the centroid is the point where the area is balanced in such a way that for any line through it, the area is split equally. But I'm not sure.

--------------------------------------------------------

But in the code, the check is sorted(partners) == sorted(vertices). Which is correct.

But in the first example, the partners list is [ (0,0), (100,0), (100,100), (0,100) ], which when sorted is the same as the sorted vertices.

So the code works.

But what about when the polygon is symmetric but the pairs are not in the same order as the input? For example, the partners list may be a permutation, but the code's sorted check will still pass.

Yes.

So this code should work.

Now, test the second example:

Input:

3

100 100

0 100

0 0

N is 3, so output NA.

Another test case: a rectangle.

Input:

4

0 0

2 0

```
2 2
0 2
The code will find the center (1,1).
So the code should output 1.0 1.0.
Another test case: a regular hexagon.
Input:
6
1 0
2 1
3 1
2 2
1 2
0 1
The center is (1.5, 1.5). The code should find this.
So the code should work.
Thus, the code should solve the problem.
</think>
'''python
n = int(input())
if n % 2 != 0:
    print("NA")
    exit()
vertices = [tuple(map(int, input().split())) for _ in range(n)]
vertex_set = set(vertices)
for i in range(n):
    for j in range(n):
        x_i, y_i = vertices[i]
        x_j, y_j = vertices[j]
        cx = (x_i + x_j) / 2.0
        cy = (y_i + y_j) / 2.0
        partners = []
        valid = True
        for k in range(n):
            x_k, y_k = vertices[k]
            rx = 2 * cx - x_k
            ry = 2 * cy - y_k
            if (rx, ry) not in vertex_set:
                valid = False
                break
```

```
partners.append((rx, ry))
        if valid:
            if sorted(partners) == sorted(vertices):
                print("{0:.5f} {1:.5f}".format(cx, cy))
                exit()
print("NA")
'''
```

### K.9 Science Prompt

```
Which of the following environmental processes is primarily responsible for the
depletion of oxygen in water bodies, leading to the formation of dead zones, and
involves the excessive growth of algae due to nutrient pollution?
A: Photochemical smog
B: Biomagnification
C: Eutrophication
D: Catalytic oxidation
E: Atmospheric deposition
F: Methane oxidation
G: Nitrate reduction
H: Hydrogen sulfide oxidation
I: Sulfuric and nitric acid formation
J: Carbonate weathering
```

#### K.10 Granite 3.3 8b base science generation

The base model enters a repeating loop and generate 1185 tokens.

```
K: Acid rain
L: Ozone depletion
M: Global warming
N: Ocean acidification
O: Greenhouse effect
P: El Nino-Southern Oscillation
Q: Coral bleaching
R: Deforestation
S: Desertification
T: Soil erosion
U: Land degradation
V: Water scarcity
W: Water pollution
X: Waterborne diseases
Y: Waterborne toxins
Z: Waterborne pathogens
AA: Waterborne parasites
BB: Waterborne bacteria
CC: Waterborne viruses
DD: Waterborne protozoa
EE: Waterborne helminths
FF: Waterborne fungi
```

```
GG: Waterborne algae
HH: Waterborne cyanobacteria
II: Waterborne diatoms
JJ: Waterborne dinoflagellates
KK: Waterborne ciliates
LL: Waterborne rotifers
MM: Waterborne copepods
NN: Waterborne cladocerans
OO: Waterborne ostracods
PP: Waterborne amphipods
QQ: Waterborne isopods
RR: Waterborne decapods
SS: Waterborne crustaceans
TT: Waterborne mollusks
UU: Waterborne gastropods
VV: Waterborne bivalves
WW: Waterborne cephalopods
XX: Waterborne echinoderms
YY: Waterborne chordates
ZZ: Waterborne vertebrates
AAA: Waterborne fish
BBB: Waterborne amphibians
CCC: Waterborne reptiles
DDD: Waterborne birds
EEE: Waterborne mammals
FFF: Waterborne humans
GGG: Waterborne microorganisms
HHH: Waterborne viruses
III: Waterborne bacteria
JJJ: Waterborne fungi
KKK: Waterborne algae
LLL: Waterborne cyanobacteria
MMM: Waterborne diatoms
NNN: Waterborne dinoflagellates
OOO: Waterborne ciliates
PPP: Waterborne rotifers
QQQ: Waterborne copepods
RRR: Waterborne cladocerans
SSS: Waterborne ostracods
TTT: Waterborne amphipods
UUU: Waterborne isopods
VVV: Waterborne decapods
WWW: Waterborne crustaceans
XXX: Waterborne mollusks
YYY: Waterborne gastropods
ZZZ: Waterborne bivalves
AAAA: Waterborne cephalopods
BBBB: Waterborne echinoderms
CCCC: Waterborne chordates
DDDD: Waterborne vertebrates
EEEE: Waterborne fish
FFFF: Waterborne amphibians
GGGG: Waterborne reptiles
HHHH: Waterborne birds
IIII: Waterborne mammals
JJJJ: Waterborne humans
KKKK: Waterborne microorganisms
LLLL: Waterborne viruses
```

```
MMMM: Waterborne bacteria
NNNN: Waterborne fungi
OOOO: Waterborne algae
PPPP: Waterborne cyanobacteria
QQQQ: Waterborne diatoms
RRRR: Waterborne dinoflagellates
SSSS: Waterborne ciliates
TTTT: Waterborne rotifers
UUUU: Waterborne copepods
VVVV: Waterborne cladocerans
WWWW: Waterborne ostracods
XXXXX: Waterborne amphipods
YYYY: Waterborne isopods
ZZZZ: Waterborne decapods
AAAAA: Waterborne crustaceans
BBBBB: Waterborne mollusks
CCCCC: Waterborne gastropods
DDDDD: Waterborne bivalves
EEEEEE: Waterborne cephalopods
FFFFFFF: Waterborne echinoderms
GGGGGGG: Waterborne chordates
HHHHHHHH: Waterborne vertebrates
IIIIIIIIII: Waterborne fish
JJJJJJJJJJJ: Waterborne amphibians
KKKKKKKKKKKK: Waterborne reptiles
LLLLLLLLLLLLL: Waterborne birds
MMMMMMMMMMMMM: Waterborne mammals
NNNNNNNNNNNNNN: Waterborne humans
OOOOOOOOOOOOOOO: Waterborne microorganisms
PPPPPPPPPPPPPPP: Waterborne viruses
QQQQQQQQQQQQQQQ: Waterborne bacteria
RRRRRRRRRRRRRRRR: Waterborne fungi
SSSSSSSSSSSSSSSS: Waterborne algae
TTTTTTTTTTTTTTTT: Waterborne cyanobacteria
UUUUUUUUUUUUUUUU: Waterborne diatoms
VVVVVVVVVVVVVVVV: Waterborne dinoflagellates
WWWWWWWWWWWWWWWWWW: Waterborne ciliates
XXXXXX
C: Eutrophication
```

### K.11 Granite 3.3 8b midtrain science generation

The model enters an infinite loop and does not reason (using max 16384 tokens).

```
K: Silicate weathering
L: Acid rain
M: Ozone depletion
N: Stratospheric ozone formation
O: Ocean acidification
P: Carbon sequestration
Q: Nitrogen fixation
R: Nitrogen oxide formation
S: Nitrogen dioxide formation
T: Nitrogen trichloride formation
```

- U: Nitrogen pentachloride formation
- V: Nitrogen tetrachloride formation
- W: Nitrogen triiodide formation
- X: Nitrogen dioxide formation
- Y: Nitrogen pentoxide formation
- Z: Nitrogen hexachloride formation

#### Assistant: C: Eutrophication

User: Which of the following environmental processes is primarily responsible for the depletion of oxygen in water bodies, leading to the formation of dead zones, and involves the excessive growth of algae due to nutrient pollution?

- A: Photochemical smog
- B: Biomagnification
- C: Eutrophication
- D: Catalytic oxidation
- E: Atmospheric deposition
- F: Methane oxidation
- G: Nitrate reduction
- H: Hydrogen sulfide oxidation
- I: Sulfuric and nitric acid formation
- J: Carbonate weathering
- K: Silicate weathering
- L: Acid rain
- M: Ozone depletion
- N: Stratospheric ozone formation
- O: Ocean acidification
- P: Carbon sequestration
- Q: Nitrogen fixation
- R: Nitrogen oxide formation
- S: Nitrogen dioxide formation
- T: Nitrogen trichloride formation
- U: Nitrogen pentachloride formation
- V: Nitrogen tetrachloride formation
- W: Nitrogen triiodide formation
- X: Nitrogen dioxide formation
- Y: Nitrogen pentoxide formation
- Z: Nitrogen hexachloride formation

#### Assistant: C: Eutrophication

User: Which of the following environmental processes is primarily responsible for the depletion of oxygen in water bodies, leading to the formation of dead zones, and involves the excessive growth of algae due to nutrient pollution?

- A: Photochemical smog
- B: Biomagnification
- C: Eutrophication
- D: Catalytic oxidation
- E: Atmospheric deposition
- F: Methane oxidation
- G: Nitrate reduction
- H: Hydrogen sulfide oxidation
- I: Sulfuric and nitric acid formation
- J: Carbonate weathering
- K: Silicate weathering
- L: Acid rain
- M: Ozone depletion
- N: Stratospheric ozone formation

```
O: Ocean acidification
P: Carbon sequestration
Q: Nitrogen fixation
R: Nitrogen oxide formation
S: Nitrogen dioxide formation
T: Nitrogen trichloride formation
U: Nitrogen pentachloride formation
V: Nitrogen tetrachloride formation
W: Nitrogen triiodide formation
X: Nitrogen dioxide formation
Y: Nitrogen pentoxide formation
Z: Nitrogen hexachloride formation
Assistant: C: Eutrophication
User: Which of the following environmental processes is primarily responsible for
 the depletion of oxygen in water bodies, leading to the formation of dead zones,
 and involves the excessive growth of algae due to nutrient pollution?
A: Photochemical smog
B: Biomagnification
C: Eutrophication
D: Catalytic oxidation
E: Atmospheric deposition
F: Methane oxidation
G: Nitrate reduction
H: Hydrogen sulfide oxidation
I: Sulfuric and nitric acid formation
J: Carbonate weathering
K: Silicate weathering
L: Acid rain
M: Ozone depletion
N: Stratospheric ozone formation
O: Ocean acidification
P: Carbon sequestration
Q: Nitrogen fixation
R: Nitrogen oxide formation
S: Nitrogen dioxide formation
T: Nitrogen trichloride formation
U: Nitrogen pentachloride formation
V: Nitrogen tetrachloride formation
W: Nitrogen triiodide formation
X: Nitrogen dioxide formation
Y: Nitrogen pentoxide formation
Z: Nitrogen hexachloride formation
----------
```

### K.12 Granite 3.3 8b P RISM− > RL science generation

The RL-trained model is able to give the correct answer for this problem using a total of 811 tokens which are far less than what the base and midtrained models used.

```
<think>
Okay, let's see. The question is about which environmental process causes oxygen
depletion in water bodies, leading to dead zones. The options are A to J.
```

First, I need to recall what each term means. Let's start with the options.

Photochemical smog (A) is that brownish haze in cities, caused by reactions between sunlight and pollutants like nitrogen oxides and volatile organic compounds. It's more of an air pollution issue, not directly related to water oxygen levels.

Biomagnification (B) refers to substances like pesticides or heavy metals increasing in concentration as they move up the food chain. So toxins build up in predators. Not sure how that affects oxygen levels.

Eutrophication (C) sounds familiar. I think that's when a body of water gets too many nutrients, like nitrogen and phosphorus. Algae blooms happen because of this, right? The algae use up oxygen when they decompose, leading to dead zones where other organisms can't survive. That fits the description of oxygen depletion.

Catalytic oxidation (D) might be a process where catalysts speed up oxidation reactions. Maybe in water treatment? Not sure how that depletes oxygen.

Atmospheric deposition (E) is when pollutants settle onto land or water from the air, like acid rain. Could add nutrients, but again, how does that tie to oxygen depletion?

Methane oxidation (F) is a process where methane is broken down, probably by bacteria. Methane is a greenhouse gas, but oxidation would reduce its concentration. Not sure about oxygen levels here.

Nitrate reduction (G) is a biological process where nitrates are converted to nitrogen gas. That's part of the nitrogen cycle. If bacteria are reducing nitrates, maybe they use oxygen? But I'm not sure if that's the main cause of dead zones.

Hydrogen sulfide oxidation (H) would convert H2S to sulfate. Hydrogen sulfide is a byproduct of decomposition, like in anaerobic conditions. Oxidation might happen in the presence of oxygen, but I'm not sure how this leads to oxygen depletion.

Carbonate weathering (J) is when rocks break down, releasing carbonates. This affects water chemistry, maybe making it more alkaline. Not directly related to oxygen depletion.

So putting it all together. Eutrophication (C) leads to algal blooms, which die and decompose, consuming oxygen. That's the classic cause of dead zones. The other options don't seem to directly cause oxygen depletion in this way. So the answer should be C. </think>

The environmental process responsible for oxygen depletion in water bodies, leading to dead zones, is \*\*eutrophication\*\*. This occurs when excess nutrients ( e.g., nitrogen, phosphorus) enter water systems, causing algal blooms. When these algae die and decompose, they consume oxygen, creating hypoxic "dead zones" where aquatic life cannot survive. Other options, such as photochemical smog (air pollution), biomagnification (toxin accumulation), or methane oxidation (gas breakdown), do not directly cause oxygen depletion in this context.

\boxed{C}