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
