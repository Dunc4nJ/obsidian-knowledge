---
created: 2026-06-28
description: Elie Bakouch (@eliebakouch) breaks down DeepSeek's DSpark, a new speculative-decoding method shipped with a detailed paper, an open draft model, and a training/eval framework. DSpark is "semi-parallel" — it fuses the parallel DFlash drafter (fast, but acceptance collapses as you draft more tokens because there's no dependency on the previous token) with the sequential Eagle drafter (slower but holds acceptance at long draft lengths via the autoregressive dependency). The construction is a heavy parallel head run once, then a cheap sequential Markov head (conditioned only on t-1) that biases the logit distribution with previous-token information. A confidence score from the sequential head adaptively sets the verification budget, doing GPU-workload-aware load balancing so verification doesn't blow up when GPUs are already saturated. The objective being optimized is per-token time = (draft + verify) / tokens accepted. Production results on DeepSeek-V4 (dsv4): +50% throughput and latency, up to ~80% latency. Training details (from a follow-up): tiny cross-entropy coefficient for the drafter, L1 distance instead of KL divergence (vs Composer 2's MTP heads), position-weighted loss (early tokens weighted more), extensive ablations. Paper, draft model, and framework all released open by DeepSeek.
source: https://x.com/eliebakouch/status/2070762049362370602
topic: speculative-decoding
type: learning
---

Source: [@eliebakouch (elie)](https://x.com/eliebakouch) — X thread, Jun 27 2026. Two tweets, one author: [head / DSpark explanation](https://x.com/eliebakouch/status/2070762049362370602) and [resources reply](https://x.com/eliebakouch/status/2070762584735981616). Subject: DeepSeek's **DSpark** speculative-decoding method.

## Key Takeaways

- **DSpark is a new DeepSeek speculative-decoding method shipped as a full package — paper, draft model, and a training/eval framework.** Elie's headline number: in production for DeepSeek-V4 (`dsv4`), DSpark gives roughly **+50% on both throughput and latency, with latency improvements reaching ~80%**. He frames it as a method he expects "to see widely adopted." This sits in the same speculative-decoding lineage as [[Modal argues speculative decoding is the only inference optimization that matters, and custom DFlash speculators turn acceptance length into 2-3x speedups]] and [[Rachel Rapp explains how Baseten trains speculative-decoding draft models live from inference hidden states, raising accept rates 20%+ with no offline data storage]] — speculative decoding being the 2-3x integral-factor lever those notes argue is the optimization that matters most.

- **The objective is the standard spec-dec cost equation: per-token time = (time to draft + time to verify) / tokens accepted.** Every design choice in DSpark is a move on this fraction — push acceptance up (the numerator's divisor), keep draft and verify cheap (the numerator). This is the same acceptance-rate / acceptance-length objective at the center of the Modal and Rachel Rapp notes; DSpark's contribution is a drafter *architecture* that trades against it well, rather than a new way to train the drafter.

- **The core insight is a parallel-vs-sequential tradeoff, and DSpark is a "semi-parallel" middle path.** The two existing drafter families pull in opposite directions:
  - **DFlash (fully parallel):** fast, but because the draft tokens have **no dependency on the previous token**, acceptance rate **drops quickly as you draft more tokens**. (DFlash is the same Z-Lab speculator architecture Modal ships for the Qwen series.)
  - **Eagle (fully sequential / autoregressive):** the opposite failure mode — it's slower (you need a much smaller draft head to hit the same speed), but the **autoregressive dependency lets it hold a good acceptance rate at many tokens**. Because the draft head is so small, its **first-token acceptance rate is often quite low**.
  DSpark keeps the advantages of both.

- **The construction: one heavy parallel head, then a cheap sequential Markov correction.** DSpark runs a **"heavy" parallel head once**, then applies **a small sequential step that biases the logit distribution with information about the previous token**. That biasing is done by **a small Markov head that depends only on `t-1`** — a minimal autoregressive correction grafted onto the parallel draft, recovering Eagle's previous-token dependency without paying for a fully sequential drafter. This is the architectural complement to the *training-side* draft-model work in the Baseten notes (live hidden-state training, MTP acceptance boosting).

- **A confidence score makes the verification budget adaptive and GPU-workload-aware.** The sequential head also emits a **confidence score**, which DSpark uses to **adjust how many tokens to verify**. The motivation is concrete: **verification gets expensive when GPUs are already at maximum utilization**, so DSpark does **load balancing** — predicting the right number of tokens to draft/verify **as a function of current GPU workload**. This couples the speculator to serving-time GPU pressure, a system-level concern that connects to KV-cache and batching mechanics in [[paged attention applies OS virtual memory paging to KV cache and unlocks 2-4x LLM serving throughput]] and the throughput-economics tradeoffs in [[vLLM throughput benchmarking on H100 — tensor-parallel sizing, speculative decoding, and FP8 KV-cache economics]].

- **Training details (from elie's follow-up): low cross-entropy coefficient, L1 distance over KL divergence, position-weighted loss, heavy ablation.** The paper does notable work on the **training objective**: turning the **cross-entropy loss coefficient very low** for the drafter, and using an **L1 distance rather than KL divergence** — which elie notes is what **Composer 2 used for training its MTP heads** (see [[Cursor Composer 2]]). They also **weight the loss by token position (early tokens weighted more)** and run **a lot of ablations**. The MTP-head comparison ties directly to [[Philip Kiely details how Baseten built the world's fastest GLM-5.2 API by stacking NVFP4 quantization, KV-aware routing, prefill-decode disaggregation, and MTP speculation]], where MTP speculation is one of the four stacked serving optimizations.

- **Elie's one caveat and one open question.** Caveat: he would have liked **production numbers comparing against DFlash or Eagle instead of MTP-1** as the baseline. Open question (in reply to "could this be the main model design?"): the **Markov head is very low-dimensional, so he's unsure pre-training it would buy much**, and is uncertain about the parallel part. He also flagged that the "full explanation" framing was tongue-in-cheek — it's his own plain-words understanding of the method, not the authors'.

- **Everything is open.** DeepSeek released the paper, the draft model, and the framework to train and evaluate speculators (links below). The second tweet also shares a **full scheme diagram generated by Claude** summarizing the method.

## Figures

DSpark method overview (tweet 1):

![[eliebakouch-370602-001.jpg]]

Full scheme, diagrammed by Claude (tweet 2):

![[eliebakouch-370602-002.jpg]]

Training-details screenshot from the follow-up (low CE coefficient, L1 vs KL, position weighting):

![[eliebakouch-370602-003.png]]

## External Resources

- [DSpark paper (PDF) — deepseek-ai/DeepSpec](https://github.com/deepseek-ai/DeepSpec/blob/main/DSpark_paper.pdf) — the detailed paper elie is summarizing
- [DeepSeek-V4-Pro-DSpark draft model (Hugging Face)](https://huggingface.co/deepseek-ai/DeepSeek-V4-Pro-DSpark) — the released speculator
- [DeepSpec — framework to train and evaluate (GitHub)](https://github.com/deepseek-ai/DeepSpec/tree/main) — training/eval framework for the drafters
- [DFlash (Z Lab)](https://z-lab.ai/projects/dflash/) — the fully-parallel drafter architecture DSpark builds on (also the speculator Modal ships for Qwen)
- [EAGLE / EAGLE-3 (SafeAILab)](https://github.com/SafeAILab/EAGLE) — the fully-sequential / autoregressive drafter family DSpark borrows the previous-token dependency from
- [MTP — Multi-Token Prediction (arXiv 2404.19737)](https://arxiv.org/abs/2404.19737) — the MTP-1 baseline elie wishes were compared against DFlash/Eagle
- [Fast Inference from Transformers via Speculative Decoding (Leviathan et al., 2023)](https://arxiv.org/abs/2211.17192) — foundational draft-and-verify scheme the (draft + verify) / accepted equation comes from

## Original Content

> [!quote]- Source Material — @eliebakouch (elie), X thread, Jun 27 2026 (both target tweets + author self-replies, verbatim)
>
> **Tweet 1 — [head, id 2070762049362370602](https://x.com/eliebakouch/status/2070762049362370602) (919 likes, 129 RT):**
>
> new inference optimization method by @deepseek_ai with an extremely detailed paper, draft model and framework to train them. results in production for dsv4 lead to +50% for throughput and latency (can go to ~80% for latency, crazy).
>
> full explanation of DSpark:
>
> it's about speculative decoding and the idea builds upon DFlash (fully parallel) and Eagle (fully sequential) to create a "semi-parallel" method that keeps the advantages of both
>
> the core equation you want to optimize is the "time to generate each token" which is:
> (time to draft + time to verify) / how many tokens are accepted
>
> the advantage of the parallel variant (DFlash) is that it's fast, but when you increase the number of tokens you draft, acceptance rate drops pretty fast (makes sense since there is no dependency on the previous token).
>
> fully sequential is nice but opposite issue: it's slower (you need a much smaller draft to get the same speed) but the autoregressive dependency means you can maintain good acceptance rate at a lot of tokens. since you have a much smaller draft head, the first token acceptance rate is often quite low
>
> idea of DSpark is to combine both: a "heavy" parallel head (you only do it once) and then a small sequential step to bias the logit distribution with information about the previous token. this biasing is done with a small markov head (only depends on t-1)
>
> they also get a confidence score out of the sequential head that allows them to adjust how many tokens they want to verify. verification can get expensive if the gpus are already at maximum utilization, so they use this confidence score to do some load balancing and predict the right number of tokens depending on gpu workload
>
> one small detail: i would have liked to see production numbers if they used DFlash or Eagle instead of MTP-1, but as always, huge work by deepseek and i'm expecting to see this method widely adopted
>
> *[attached: DSpark method-overview figure — see ![[eliebakouch-370602-001.jpg]]]*
>
> ---
>
> **Tweet 2 — [reply, id 2070762584735981616](https://x.com/eliebakouch/status/2070762584735981616) (46 likes):**
>
> @deepseek_ai here is the full scheme by claude
>
> paper: https://github.com/deepseek-ai/DeepSpec/blob/main/DSpark_paper.pdf
> draft model: https://huggingface.co/deepseek-ai/DeepSeek-V4-Pro-DSpark
> framework to train and evaluate: https://github.com/deepseek-ai/DeepSpec/tree/main
>
> *[attached: full-scheme diagram by Claude — see ![[eliebakouch-370602-002.jpg]]]*
>
> ---
>
> **Author self-reply — [id 2070763537736360179](https://x.com/eliebakouch/status/2070763537736360179) (11 likes):**
>
> @deepseek_ai * full explanation of DSpark:
>
> realizing that's a bit pretentious lol, i just tried to put my understanding of the method in "simple" words 🫡
>
> ---
>
> **Author self-reply — [id 2070767367735693599](https://x.com/eliebakouch/status/2070767367735693599) (12 likes), extra paper details:**
>
> lot of cool stuff in the paper btw that i didn't mention above like working on training objective by turning the coef of the cross entropy loss very low for training the drafter, and use a L1 distance and not KL divergence which is what composer 2 used for training MTP heads for instance iirc. do some weighting depending of the position of the token (early token have more weight), they also have a lot of ablation
>
> *[attached: training-details screenshot — see ![[eliebakouch-370602-003.png]]]*
>
> ---
>
> **Author self-reply — [id 2070774130019119109](https://x.com/eliebakouch/status/2070774130019119109) (6 likes), reply to "I wonder if you can turn this into the main model design":**
>
> hmm interesting question, this markov head thing seems very low dimension so not sure you get much by pre-training it, and honestly for the parallel part idk
