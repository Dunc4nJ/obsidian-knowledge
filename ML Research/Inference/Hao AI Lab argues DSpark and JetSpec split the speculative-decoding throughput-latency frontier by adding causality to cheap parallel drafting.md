---
created: 2026-07-07
description: Once block-parallel drafting is cheap, causality (conditioning later draft tokens on earlier ones) becomes the lever, and DSpark and JetSpec apply it to opposite ends of the throughput–latency frontier as complementary systems.
source: https://x.com/haoailab/status/2072472882014486610
type: synthesis
topic: speculative-decoding
---

## Key Takeaways

- **Cheap drafting moves the bottleneck from draft cost to verification survival, and causality is the fix.** [[Modal argues speculative decoding is the only inference optimization that matters, and custom DFlash speculators turn acceptance length into 2-3x speedups|DFlash]]-style block-parallel heads predict many future positions in one pass, so drafting stops being the constraint — but when those positions are only weakly conditioned on earlier draft tokens they look plausible individually yet break as a sequence and fail verification. Hao AI Lab's read is that DSpark and JetSpec converging on causal conditioning (from opposite directions) signals causality is *the* central lever for next-gen speculative decoding, not just one trick among many.
- **The two systems partition the throughput–latency Pareto frontier.** [[DSpark (DeepSeek paper) couples a semi-autoregressive drafter with a hardware-aware confidence scheduler to raise accepted length 16-31% offline and shift DeepSeek-V4's serving Pareto frontier|DSpark]] owns the high-concurrency, budget-constrained regime: a lightweight Markov/RNN correction head plus a confidence head schedule only the longest confident prefix under a compute budget (accepted length 4.07 → 5.01 at budget 7 on Qwen3-8B / AIME25). JetSpec owns the low-concurrency, FLOPs-rich latency regime: a causal parallel draft head builds a path-conditioned draft *tree* where deeper nodes condition on earlier tokens along the same branch (accepted length 7.23 → 9.82 as the budget scales 16 → 128, beating DFlash's 7.34 and DDTree's 8.66 at budget 128).
- **In the FLOPs-rich regime acceptance rate is everything — a few points of α swing speedup by multiples.** JetSpec reaches ~93% *effective* per-token acceptance on AIME25 (near-perfect q₁ ≈ 99% at depth 1, still ~50% at depth 8). The chart Charles Frye told people to "grok" makes the payoff concrete: at ultra-low draft cost (c = 0.0005), pushing α from 0.85 to 0.95 lifts expected speedup from ~6× to ~19× at long draft lengths — the same lever [[Step 04 - Draft models and the acceptance-rate lever (α = distributional overlap)|α = distributional overlap]] formalizes and [[Rachel Rapp explains how Baseten trains speculative-decoding draft models live from inference hidden states, raising accept rates 20%+ with no offline data storage|Baseten's live-trained drafters]] chase from the data side.
- **DSpark and JetSpec are complementary, not competing.** The natural next step is a dynamic serving framework that uses JetSpec's causal parallel backbone for low-latency budget scaling and DSpark's confidence-scheduled budget control for high-concurrency serving — pushing both ends of the frontier at once rather than picking a point on it. Both build on the same [[Step 03 - Speculative decoding core (guess-then-verify, why it's lossless)|guess-then-verify]] foundation and inherit its losslessness.

## External Resources

- [DSpark paper (DeepSeek / DeepSpec)](https://github.com/deepseek-ai/DeepSpec/blob/main/DSpark_paper.pdf) — the high-concurrency system: parallel drafting backbone + Markov/confidence correction head + budget-scheduled verification.
- [JetSpec project page](https://jetspec-project.github.io/jetspec-web/) and [JetSpec paper](https://arxiv.org/pdf/2606.18394) — the latency-oriented system: causal parallel draft head producing a path-conditioned draft tree.
- [DFlash](https://arxiv.org/pdf/2602.06036) — the lightweight block-parallel drafter that made draft cost cheap and set up the causality bottleneck both systems attack.
- [EAGLE series](https://github.com/SafeAILab/EAGLE) — the autoregressive-drafter baseline whose sequential steps grow with draft length.

## Original Content

Charles Frye's quote-tweet pointing to the article and its key chart:

> @charles_irl (Charles 🎉 Frye @ ICML) — 2026-07-07
>
> If you're interested in speculative decoding, take some time to grok this chart! And read the article from @haoailab.
>
> QT @haoailab: Article: DSpark vs. JetSpec, which is better? — https://x.com/haoailab/status/2072472882014486610
>
> Engagement: 81 likes | 6 retweets | 2 replies
> [Original post](https://x.com/charles_irl/status/2074288166576742510)

*The chart Charles highlighted — Figure 4 from the article: at ultra-low per-token draft cost (c = 0.0005), expected speedup scales with draft length γ, but the acceptance rate α gates the ceiling — α = 0.95 reaches ~19× while α = 0.85 tops out near ~6×.*
![[charles-742510-001.webp]]

---

The full Hao AI Lab article:

> [!quote]- Source Material — "Causality Meets Parallel Drafting: Pushing the Throughput–Latency Frontier of Speculative Decoding"
>
> ![[haoailab-486610-001.png]]
>
> **Article: DSpark vs. JetSpec, which is better?**
>
> Authors: [@Lanxiang_Hu](https://x.com/@Lanxiang_Hu) [@aaronzhfeng](https://x.com/@aaronzhfeng) [@YuYangQian_ai](https://x.com/@YuYangQian_ai) [@Jensen_Yuan](https://x.com/@Jensen_Yuan) [@haozhangml](https://x.com/@haozhangml)
>
> Speculative decoding (SD) techniques have proliferated recently. SD accelerates autoregressive generation by letting a lightweight draft model propose future tokens, while the target model verifies them in parallel. This naturally raises the question: which one is better? Or, more interestingly, are they actually complementary?
>
> **TL;DR:**
>
> Among recent speculative decoding efforts, [DSpark](https://github.com/deepseek-ai/DeepSpec/blob/main/DSpark_paper.pdf) and [JetSpec](https://jetspec-project.github.io/jetspec-web/) emerged almost concurrently targeting the same bottleneck: once drafting becomes cheap, how do we preserve enough causal consistency for parallel proposals to survive verification.
>
> The fact that both works converge in this direction suggests that causality is becoming a central lever for next-generation speculative decoding. They approach it from complementary sides of the throughput–latency frontier. DSpark targets high-concurrency serving: on Qwen3-8B and AIME25, DSpark improves accepted length from 4.07 (DFlash) to 5.01 at budget 7 with causal recurrent state for confidence-scheduled verification; JetSpec targets the latency-oriented, compute-budget-rich regime: by building causality directly into the parallel draft head, it turns larger draft budgets into longer accepted prefixes, on the same settings, scaling accepted length from 7.23 at budget 16 to 9.82 at budget 128, up from DFlash's 7.34 (DDTree's 8.66) at budget 128, for low latency generation.
>
> **1. Causality in DSpark and JetSpec**
>
> Traditional drafters like [the EAGLE series](https://github.com/SafeAILab/EAGLE) often preserve draft quality through autoregressive generation, but this makes longer drafts require more sequential draft steps. [DFlash](https://arxiv.org/pdf/2602.06036) changes the cost structure: by using a lightweight block-parallel drafter to predict many future positions in one pass, it opens the door to making draft cost cheap.
>
> But cheap drafting is not enough. Once the draft cost drops, the bottleneck shifts to whether parallel proposals can survive verification. When future positions are weakly conditioned on earlier draft tokens, they may appear plausible in isolation but become inconsistent as a sequence. Here is where causality becomes important.
>
> [DSpark](https://github.com/deepseek-ai/DeepSpec/blob/main/DSpark_paper.pdf) keeps the parallel drafting backbone cheap, while adding a lightweight sequential head and confidence estimation to better decide which proposals should be sent for verification, thereby controlling the per-request compute budget. As a result, DSpark consistently improves throughput over MTP-style pure autoregressive drafting, where longer drafts require more sequential draft steps (Figure 1).
>
> On the other hand, under a latency-oriented Service Level Objective (SLO) with low concurrency, the system is more FLOPs-rich, so the goal shifts toward maximizing accepted rate per verification step. In this regime, we can afford to spend more on draft compute to raise the acceptance rate and maintain high acceptance at deeper positions. This is where causal parallel drafting, as in [JetSpec](https://arxiv.org/pdf/2606.18394), becomes especially important: the draft budget is used for generating path-conditioned tree, making it more likely to produce long accepted prefixes.
>
> **2. How Causality Helps**
>
> Once drafting becomes cheap, the next question is how to spend limited compute intensity: should we squeeze more throughput under high concurrency, or push lower latency when more FLOPs are available per request? This is where causality becomes the key lever.
>
> *Pushing the Throughput Limit: DSpark for Budget-Aware Correction*
>
> [DSpark](https://github.com/deepseek-ai/DeepSpec/blob/main/DSpark_paper.pdf) targets the high-concurrency, budget-constrained regime. It uses a lightweight Markov-style correction head and confidence head (or an RNN-head variant that carry recurrent prefix state across positions). For each draft position i, the parallel drafter first produces base logits z_i^0, and a corresponding draft hidden state h_i. the confidence head estimates prefix-dependent confidence scores c_i:
>
> where the Markov head B then injects a small causal correction from the previous draft token to generate . The verification budget is then scheduled by keeping only the longest confident prefix under budget B and threshold rho:
>
> This makes it suitable for budget-aware serving: the draft backbone stays parallel, while the correction path improves local or prefix-dependent consistency.
>
> *Pushing the Latency Limit: JetSpec Turns Draft Budget into Higher Acceptance*
>
> With low concurrency, modern AI accelerators come with more spare FLOPs, so the key question becomes: how to translate higher compute budget into more accepted tokens per draft-verification step? This is where JetSpec takes a different path. JetSpec uses a causal parallel draft head to produce a path-conditioned draft tree, where deeper nodes are conditioned on earlier tokens along the same branch.
>
> The effect shows up clearly in the depth-wise acceptance profile (Figure 4). JetSpec consistently maintains higher acceptance than DFlash on both coding and math reasoning workloads.
>
> On AIME25, JetSpec starts with a near-perfect per-position acceptance rate of (q_1 at around 99%) at draft depth 1 and still maintains roughly (q_8 at 50%) acceptance at depth 8. Here q_i denotes the survival probability that at least the first i draft tokens are accepted. The empirical acceptance length is
>
> Under the constant per-token acceptance rate assumption used in the original speculative decoding analysis,
>
> We define alpha_eff by fitting the theoretical and empirical acceptance lengths:
>
> *Figure 4: Expected SD speedup scales as a function of draft length, under different per-token drafting costs and acceptance rates. The results highlight that even at ultra low per-token drafting cost regime, per-token acceptance rate at 0.85 vs. 0.95 makes a big difference.*
> ![[charles-742510-001.webp]]
>
> This corresponds to an estimated effective per-token acceptance rate of about 93%, substantially higher than DFlash. In this low-cost, high-acceptance regime, even a 5% gain in per-token acceptance can have an outsized impact on speculative decoding: it significantly increases the maximum theoretical acceptance length (Figure 4), which in turn directly reduces generation latency.
>
> **Up Next: Enabling Both Throughput- and Latency-Oriented Parallel Drafting**
>
> A foreseeable next step is to build a dynamic serving framework that can push both ends of the throughput–latency Pareto frontier: low-concurrency settings that demand higher per-user TPS, and high-concurrency settings that require higher aggregate throughput under tight verification budgets.
>
> In this direction, JetSpec and DSpark are naturally complementary: JetSpec strengthens the parallel drafting backbone for low-latency budget scaling, while DSpark adds lightweight sequential confidence checking and budget control for high-concurrency serving.
>
> Engagement: 56 likes | 13 retweets | 0 replies
> [Original post](https://x.com/haoailab/status/2072472882014486610)
