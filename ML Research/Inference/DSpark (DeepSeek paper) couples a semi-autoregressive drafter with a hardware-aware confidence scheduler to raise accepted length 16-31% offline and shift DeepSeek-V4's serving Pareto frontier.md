---
created: 2026-06-28
description: The DSpark paper from DeepSeek-AI and Peking University (Xin Cheng, Xingkai Yu, Chenze Shao, Jiashi Li, Yunfan Xiong et al.). DSpark is a speculative-decoding framework with two contributions. (1) Semi-autoregressive generation — a heavy parallel backbone (DFlash) produces all γ draft logits in one pass, then a lightweight sequential head (a low-rank first-order Markov head, default; or an RNN head) adds a prefix-dependent transition bias so each draft position conditions on the previously-sampled token, mitigating the "suffix decay" of independent parallel drafters. (2) Confidence-scheduled verification — a confidence head predicts per-position prefix-survival probabilities (calibrated post-hoc via Sequential Temperature Scaling), and a hardware-aware prefix scheduler casts verification-length selection as a global throughput-maximization problem (greedy admission over a profiled steps-per-second cost table), pruning low-confidence suffix tokens under load while preserving the exact target distribution (non-anticipating property enforced via early-stopping / two-step-stale async scheduling for ZOS). Trained with frozen target, three losses (CE, total-variation/L1, confidence BCE), position-weighted. Offline: +16–18% accepted length over DFlash and +27–31% over Eagle3 across Qwen3-4B/8B/14B and Gemma4-12B. Production (DeepSeek-V4-Flash/Pro vs MTP-1 baseline): +60–85% / +57–78% per-user generation speed at matched throughput, shifting the throughput–interactivity Pareto frontier. Checkpoints + DeepSpec training repo open-sourced.
source: https://github.com/deepseek-ai/DeepSpec/blob/main/DSpark_paper.pdf
topic: speculative-decoding
type: paper
authors: Xin Cheng, Xingkai Yu, Chenze Shao, Jiashi Li, Yunfan Xiong, et al. (Peking University & DeepSeek-AI)
---

Source: **DSpark: Confidence-Scheduled Speculative Decoding with Semi-Autoregressive Generation** — Xin Cheng, Xingkai Yu, Chenze Shao, Jiashi Li, Yunfan Xiong (equal contribution) et al., Peking University & **DeepSeek-AI**. Paper PDF: [deepseek-ai/DeepSpec/DSpark_paper.pdf](https://github.com/deepseek-ai/DeepSpec/blob/main/DSpark_paper.pdf). Repo: [deepseek-ai/DeepSpec](https://github.com/deepseek-ai/DeepSpec).

> This is the **full paper** behind [[elie breaks down DeepSeek's DSpark, a semi-parallel speculative decoder that fuses DFlash's parallel head with an Eagle-style Markov step for +50% throughput and up to 80% lower latency in DeepSeek-V4 production]] — read that companion note for Elie Bakouch's plain-words X-thread summary (and his caveat about the MTP-1 baseline). This note is the paper-faithful version: the actual factorization, the scheduler algorithm, the calibration, the training objective, and the real numbers.

## Core contribution in one paragraph

Speculative decoding's per-token latency is `L = (T_draft + T_verify) / τ`, where `τ` is the accepted length per round. Autoregressive drafters (Eagle) get high `τ` but pay `T_draft ∝ γ`; parallel drafters (DFlash) collapse `T_draft` to a single pass but lose `τ` because each draft position is predicted independently and suffers **suffix decay** (acceptance collapses at later positions). Meanwhile, **fixed-length verification** wastes `T_verify` on low-confidence suffix tokens that are nearly certain to be rejected — and under high concurrency that wasted verification steals batch capacity from other active requests. **DSpark attacks both at once:** a *semi-autoregressive* drafter recovers `τ` cheaply (parallel backbone + a tiny serial correction head), and a *confidence-scheduled, hardware-aware verifier* spends `T_verify` only where expected return is positive. The result keeps DFlash's drafting speed, recovers Eagle's suffix coherence, and makes verification length **load-adaptive** in production.

## The two bottlenecks DSpark targets

1. **Generation quality — multi-modal collision / suffix decay.** A parallel drafter predicts every position independently, marginalizing over all possible predecessors instead of conditioning on the one actually sampled. Given context that admits "of course" vs "no problem", it can emit incoherent mixes like "of problem". Acceptance therefore decays rapidly along the block.
2. **System efficiency — indiscriminate verification.** The ideal verification length varies on **two axes**: (a) *data* — structured tasks like code/math sustain high acceptance, open-ended chat much lower; (b) *system* — verifying an extra token is nearly free under light load but, under heavy load, occupies target-model batch capacity that could serve other requests. A static block length is wrong on both axes.

## Contribution 1 — Semi-Autoregressive Generation

Split drafting into two stages (see Figure 1):

- **Parallel stage (the heavy backbone).** DSpark instantiates this as **DFlash** — a 5-layer parallel drafter that runs one forward pass over the whole block, producing hidden states `h₁…h_γ` and base logits `U₁…U_γ`. DFlash conditions on rich target context via **KV injection**: hidden states from a set of target layers are concatenated, RMSNorm-projected into the draft space, and prepended to every draft layer's keys/values; all block positions attend bidirectionally. It shares the target's (frozen) embedding + LM head. DSpark makes one tweak to DFlash — it treats the **anchor token itself as the first prediction position** (anchor + γ−1 masks → γ logits), reducing draft compute at similar quality.
- **Sequential stage (the cheap correction).** A lightweight serial head adds a **prefix-dependent transition bias** `B_k(x₀, x_<k, x_k)` to the base logits, inducing a *causal* block distribution via autoregressive factorization:

  `p_k(v | x₀, x_<k) = softmax_v( U_k(v) + B_k(x₀, x_<k, v) )`, with the block probability `P(X|x₀) = ∏_k p_k`.

  Crucially this is a **locally normalized** softmax (not a globally normalized energy model / CRF), so per-token probabilities remain *exact* — which is what the speculative rejection-sampling rule requires. Two instantiations:
  - **Markov head (default).** `B` depends only on the immediately preceding token `x_{k−1}` — a first-order `V×V` transition matrix, **low-rank factorized** `B = W₁W₂` with `W₁ ∈ ℝ^{V×r}`, `W₂ ∈ ℝ^{r×V}`, `r = 256`. `W₁` is an embedding lookup, `W₂` a logit projection; cheap even at large vocab. Once position 1 samples "of", the Markov head boosts "course" and suppresses "problem" at position 2 — killing the cross-mode collision.
  - **RNN head.** Maintains a recurrent state `s_k` accumulating the full in-block prefix (one gated GRU-style update from `[s_{k−1}; W₁[x_{k−1}]; h_k]`). Strictly more expressive than Markov, but the paper finds it buys **only marginal gains** (mostly at long blocks) for more implementation/deployment cost — so **Markov is the default**.

Because the sequential loop is inherently serial, it must satisfy `T_sequential ≪ T_parallel`; the design keeps overall draft latency dominated by the single parallel pass.

**Why "a little autoregression goes a long way" (the key empirical insight).** Position-wise conditional acceptance (Figure 2) shows the mechanism: parallel DFlash starts *higher* than Eagle at **position 1** (deeper net → e.g. 0.88 vs 0.81 on Math; 0.72 vs 0.53 on Chat), because `O(1)` parallel drafters can afford depth while `O(γ)` autoregressive drafters are forced shallow. Since spec-dec is strict prefix matching, position-1 accuracy has the **highest leverage** (a position-1 rejection kills the whole block) — so parallel drafters can beat autoregressive ones *globally* despite decaying tails. But DFlash's tail decays (e.g. Code 0.87→0.78, Chat 0.72→0.63), while Eagle's conditional acceptance is flat-or-rising. DSpark's semi-autoregressive design **inherits the high parallel position-1 capacity and bolts on Eagle-style tail coherence** (e.g. starts 0.93 on Math and stays high). Ablations: a **2-layer DSpark beats a 5-layer DFlash** (sequential modeling is more parameter-efficient than stacking parallel depth); the DSpark-over-DFlash gap *widens* with block size (at γ=7: +16/15/18% math/code/chat; at γ=15: +30/26/22%); and the sequential loop adds only **0.2–1.3%** to full-round latency at batch 128.

## Contribution 2 — Confidence-Scheduled Verification

**Confidence head.** A lightweight linear+sigmoid head outputs `c_k ∈ (0,1)` — the conditional probability that draft token `k` survives verification *given all preceding tokens are accepted*: `c_k = σ(wᵀ[h_k ; W₁[x_{k−1}]])`. It's supervised against the analytic per-step acceptance rate `c*_k = 1 − ½‖p_k^d − p_k^t‖₁` (total-variation distance between draft and target).

**Post-hoc calibration — Sequential Temperature Scaling (STS).** The scheduler needs *absolute* cumulative survival magnitudes, not just rankings, to estimate expected accepted length — but neural confidence is overconfident (raw ECE 3–8%, ROC-AUC 0.81–0.90). Because the joint prefix-survival probability factorizes as the cumulative product `∏_{i≤k} c_i`, STS calibrates left-to-right: at each position a 1-D grid search picks the temperature minimizing the cumulative product's Expected Calibration Error, freezing earlier positions. Temperature scaling is order-preserving, so it fixes magnitudes without disturying rankings; STS cuts average ECE to ~1%.

**Hardware-aware prefix scheduler (Algorithm 1).** Verification-length selection is framed as **global throughput maximization** across a batch of `R` active requests. Survival of token `j` in request `r` is the cumulative product `a_{r,j} = ∏_{i≤j} c_{r,i}`. With per-step verification batch `B = Σ(1 + ℓ_r)` and expected accepts `τ = Σ(1 + Σ_{j≤ℓ_r} a_{r,j})`, the objective is `Θ = τ · SPS(B)`, where **`SPS(B)` (steps-per-second for batch `B`) is profiled once at engine init and stored as an O(1) cost table**. Because `a_{r,j}` is monotonically non-increasing in `j`, the marginal gain of extending request `r` by one token is exactly `a_{r,j}` — so **globally sorting all candidate `(r,j)` by survival probability and greedily admitting** respects intra-block prefix order automatically. The scheduler admits tokens in sorted order, recomputing `Θ` via the cost-table lookup, and **breaks the moment throughput drops**.

**Correctness — the non-anticipating property.** Lossless spec-dec requires admission decisions not depend on future candidate tokens. Because the confidence head uses the previous sampled token's Markov feature, a *retrospective* global search would leak the realized token `x_{r,k}` into step `k`'s admission decision (Appendix A gives a concrete selection-bias counterexample). The **early-stopping break** keeps each truncation dependent only on the prefix up to that step, preserving exact target-distribution recovery — *provided* `Θ` is unimodal (a smoothly decaying capacity curve).

## Training

Target model **frozen** throughout; the draft shares the frozen embedding + LM head and updates only the backbone, sequential block, and confidence head. Training data: **Open-PerfectBlend** (1.3M samples: 39% math, 39% code, 18% chat, 4% IF) — prompts only, responses **regenerated by each target model**; 10 epochs, non-thinking mode. Multiple anchor positions are sampled per sequence to form γ-token training blocks. Loss = weighted sum of three terms, all **position-weighted** by `w_k = exp(−(k−1)/γ)` (early positions matter more under prefix verification):

- `L_ce` — cross-entropy to the ground-truth next token (small weight, `α=0.1`).
- `L_tv` — **total-variation / L1 distance** between draft and target distributions (`α=0.9`). Since per-step acceptance `= 1 − ½‖p^d − p^t‖₁`, minimizing TV directly maximizes acceptance. *(This is the "L1 not KL" choice Elie flagged — the same TV/L1 objective [[Cursor Composer 2]] used for its MTP heads.)*
- `L_conf` — binary cross-entropy training the confidence head to predict the soft acceptance label `c*_k` (`α=1.0`).

## Offline results

With the scheduler disabled (fixed block) to isolate raw draft quality, **accepted length `τ` per round** (Table 1, higher = better), macro-averaged across math/code/chat:

| Target | vs Eagle3 (autoregressive) | vs DFlash (parallel) |
|---|---|---|
| Qwen3-4B | **+30.9%** | **+16.3%** |
| Qwen3-8B | **+26.7%** | **+18.4%** |
| Qwen3-14B | **+30.0%** | **+18.3%** |
| Gemma4-12B | consistent gains (cross-family) | consistent gains |

Representative absolute `τ` (Qwen3-8B): math GSM8K 6.17 / MATH 5.78 / AIME25 5.01; code MBPP 5.16 / HumanEval 5.52 / LCB 5.17; chat MT-Bench 3.72 / Alpaca 3.58 / Arena-Hard 3.21 — clearly higher on structured tasks than open-ended chat, which is exactly what motivates **dynamic** verification length.

**Confidence-head diagnostic (static threshold sweep, Qwen3-4B).** Raising the confidence threshold prunes doomed suffix tokens and lifts acceptance rate — most dramatically on **chat (45.7% → 95.7%)**, mildly on math (76.9% → 92.5%) and code (67.6% → 92.0%). Chat's higher-entropy distribution is where fixed-length verification wastes the most compute, validating the head as a pruning signal before the full scheduler is even deployed.

## Production deployment (DeepSeek-V4)

DSpark draft models are co-deployed with preview **DeepSeek-V4-Flash** and **DeepSeek-V4-Pro** (the broader V4 line is covered in [[Arjun Kocher's RL algorithm Q&A traces PPO, GRPO, DAPO, and the DeepSeek R1-to-V4 training arc]]). The production backbone: 3 MoE layers with mHC + sliding-window attention 128, max block **γ = 5**, Markov head, STS-calibrated confidence. Baseline is **MTP-1** (single-token Multi-Token-Prediction) — historically kept because static multi-token drafters (MTP-3/5) *degrade* aggregate throughput under high concurrency.

- **Pareto frontier (Figure 7).** At matched aggregate throughput, DSpark accelerates **per-user generation speed by 60–85% (V4-Flash)** and **57–78% (V4-Pro)**. At moderate SLAs it lifts throughput ~51–52%. At *strict* interactivity SLAs (120 tok/s/user Flash, 50 tok/s/user Pro) the single-token MTP-1 baseline collapses to tiny batches — DSpark's nominal advantage balloons (661% / 406%), which the authors honestly frame as evidence it **extends the feasible frontier into tiers MTP-1 can't serve at all**, not a representative multiplicative speedup.
- **Load-adaptive verification (Figure 8).** Below saturation (~<200 concurrent Flash / <150 Pro) the scheduler spends idle compute, expanding verification from MTP-1's static 2 tokens to ~4–6. As concurrency saturates target capacity, it **smoothly shrinks the per-request budget**, pruning low-confidence tokens before they steal batch capacity. This load-awareness is what makes large draft blocks *safe* in production.

**Systems engineering required to ship it:**
- *Training (HAI-LLM):* **hidden-state communication** — cache target activations and ship only the pre-LM-head hidden states (O(d), not O(V≈10⁵)), running the LM-head projection locally on draft workers; **anchor-bounded sequence packing** — pack isolated prediction blocks via token-level attention indices (not 2D masks) to decouple draft cost from target context length.
- *Inference:* the ideal Algorithm 1 conflicts with real hardware (jagged, step-wise `SPS(B)` curves) and with **CUDA-graph replay + Zero-Overhead Scheduling (ZOS)**, which need next-step batch size *before* the current step finishes. DSpark goes **asynchronous**: it approximates capacity `K` using confidence outputs from **two steps prior** (casting admission as dynamic top-K), while still sorting by up-to-date cumulative confidence. The two-step staleness forms a **causal barrier** that lets them *remove* early-stopping for an unconstrained global search across hardware cliffs **without** leaking the current token — preserving losslessness. Variable-length verified prefixes are handled by flattening all tokens across requests and conveying intra-sequence structure via a marker tensor in the sparse-attention kernels (only V4's index-attention and compress kernels needed changes).

## Limitations

Even with perfect scheduling, DSpark still pays a **fixed draft-side cost** to generate the initial γ-token block via the parallel backbone. For inherently low-acceptance queries that upfront compute is unrecoverable; the authors suggest future **difficulty-aware early-exit** in the drafter so hard requests can skip full-block generation.

## Why this matters / how it fits the cluster

DSpark is the production-grade convergence point of this folder's speculative-decoding thread. [[Modal argues speculative decoding is the only inference optimization that matters, and custom DFlash speculators turn acceptance length into 2-3x speedups]] makes the case that spec-dec (and acceptance length specifically) is *the* integral-factor lever and that **DFlash** is the speculator to ship — DSpark takes that exact DFlash backbone and fixes its suffix decay. [[Rachel Rapp explains how Baseten trains speculative-decoding draft models live from inference hidden states, raising accept rates 20%+ with no offline data storage]] is the *training-side* complement (how to keep drafters aligned); DSpark contributes the drafter *architecture* and a *verification scheduler*. The MTP-1 baseline and MTP speculation tie to [[Philip Kiely details how Baseten built the world's fastest GLM-5.2 API by stacking NVFP4 quantization, KV-aware routing, prefill-decode disaggregation, and MTP speculation]]. The load-aware, batch-capacity framing of verification connects directly to KV-cache and batching mechanics in [[Amit Shekhar explains how vLLM packs more LLM users onto one GPU through PagedAttention and continuous batching]], [[paged attention applies OS virtual memory paging to KV cache and unlocks 2-4x LLM serving throughput]], and the throughput economics in [[vLLM throughput benchmarking on H100 — tensor-parallel sizing, speculative decoding, and FP8 KV-cache economics]]. For orientation across all of these, see [[Joe Barrow reviews Philip Kiely's Inference Engineering as the reference work he wishes he had in 2023, with a curated what-to-read-next list]].

## Figures

**Figure 1 — DSpark architecture and decoding cycle.** Step ①: the target model turns prompt `ABC` into anchor `D`. Step ②: the heavy **Parallel Block** (DFlash, fed `D` + masks) emits per-position logits; the lightweight **Sequential Block** adds the prefix-dependent bias to produce draft tokens `E F G H` plus confidence scores `c₁…c₄`; the **Hardware-Aware Prefix Scheduler** keeps `EFG` and drops the low-confidence `H`. Step ③: the target model verifies the scheduled prefix — `E`, `F` accepted, `G` rejected → emits corrected `G*`.

![[dspark-paper-001.png]]

**Figure 7 — Throughput vs. TPS under live traffic.** Aggregate token throughput (per GPU) against per-user generation speed for DeepSeek-V4-Flash and V4-Pro; DSpark (green) shifts the throughput–interactivity frontier outward versus MTP-1 (blue), with the annotated SLA-anchor gains.

![[dspark-paper-002.png]]

## External resources

- [DSpark paper PDF — deepseek-ai/DeepSpec](https://github.com/deepseek-ai/DeepSpec/blob/main/DSpark_paper.pdf)
- [DeepSpec — algorithm-driven training/eval repo (Eagle3, DFlash, DSpark)](https://github.com/deepseek-ai/DeepSpec)
- [DeepSeek-V4-Pro-DSpark draft model (Hugging Face)](https://huggingface.co/deepseek-ai/DeepSeek-V4-Pro-DSpark)
- [DFlash (Z-Lab)](https://z-lab.ai/projects/dflash/) — the parallel backbone DSpark builds on
- [EAGLE / EAGLE-3 (SafeAILab)](https://github.com/SafeAILab/EAGLE) — the autoregressive baseline
- [Fast Inference from Transformers via Speculative Decoding (Leviathan et al., 2023)](https://arxiv.org/abs/2211.17192) — the draft-and-verify foundation
