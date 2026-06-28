---
created: 2026-06-28
description: Distilled serving/throughput-tuning reference from HuggingFace's FinePhrase work — vLLM on H100, a two-tier parameter sweep across 18 models, when tensor parallelism vs speculative decoding actually pays off, and the $/H100-hour math.
source: "[[prompt design is the single biggest lever for synthetic pretraining data]]"
type: reference
topic: serving-economics
---

# vLLM throughput benchmarking on H100 — tensor-parallel sizing, speculative decoding, and FP8 KV-cache economics

> [!info] Extracted reference
> This is a standalone serving reference distilled from the *Infrastructure → Throughput Benchmarking* section of [[prompt design is the single biggest lever for synthetic pretraining data]] (HuggingFace FinePhrase). The parent note keeps the full verbatim article; this note isolates the reusable inference-tuning recipe. See also [[paged attention applies OS virtual memory paging to KV cache and unlocks 2-4x LLM serving throughput]] and [[Joe Barrow reviews Philip Kiely's Inference Engineering as the reference work he wishes he had in 2023, with a curated what-to-read-next list]].

## Key Takeaways

- **The serving config, not the engine, is the lever.** With vLLM/SGLang the raw kernel speed is no longer the bottleneck; picking the right serving parameters moved gpt-oss-120b from 3,138 → 6,117 tokens/sec/GPU — a 10B-token run dropping from **885 → 454 GPU-hours ($2,656 → $1,362 at $3/H100-hour), ~49% saved from configuration alone.** Across 90 experiments that compounds to >100,000 USD.
- **Tune in two tiers.** *Tier 0* (prerequisite, biggest impact): `tp` (tensor parallel), `mns` (max-num-seqs), `mnbt` (max-num-batched-tokens). *Tier 1* (refinement): `gmu` (gpu-memory-utilization, 0.9/0.95) and speculative decoding. Benchmarked **18 models** across 4 size tiers on **H100 80GB (8/node)**, 801 configurations.
- **Backend matters on Hopper:** the FlashAttention vLLM backend was **>50% faster than FlashInfer** on Ampere/Hopper (SM 8.x–9.x); FlashInfer only takes priority on Blackwell (SM 10.x).
- **Tensor parallelism is about KV-cache headroom, not compute, for large MoE.** gpt-oss-120b (120B total / ~5B active) fits at tp=1 but logs only **~45,520 tokens of KV capacity (~5 concurrent seqs at 8k context)**; tp=2 jumps it to **~810,000 tokens (~99 concurrent seqs)** → 1.95x. Same story for Qwen3-30B-A3B (1.78x). Cross-GPU comms cost is minimal because only active experts participate.
- **Speculative decoding helps small + compute-bound + predictable-output, hurts everything else.** SmolLM2 gained **1.34–1.75x** (best: suffix-32 / ngram-6); but for **8 of 18 models tier-1 was *worse* than tier-0** — at high QPS the extra verification compute competes with an already-saturated GPU (vLLM has measured 1.4–1.8x *slowdowns*). Model-free methods (ngram, suffix) need no draft weights and win when outputs echo the input (rewriting/summarization → high acceptance ~0.7).
- **Gemma 3 is architecturally hostile to speculation at all sizes.** vLLM's rejection sampler does a full-vocabulary `logits.sort()` during warmup; Gemma 3's ~256k vocab needs ~12 GiB for that sort alone → CUDA OOM (gemma-3-1b crashes); its 5:1 local/global sliding-window attention also interacts poorly with draft-and-verify.
- **Exotic knobs didn't help here:** non-16 block sizes, **FP8 KV-cache quantization, and 4-bit (BitsAndBytes) gave no consistent throughput gains** and sometimes degraded small models into repetition loops.
- **Memory-bound vs compute-bound decides which lever to pull.** Prefill = compute-bound; decode = memory-bandwidth-bound. Large models / long sequences → memory-bound → raise `tp` (frees KV space, enables bigger batches). Small models at high batch → compute-bound → speculative decoding amortizes per-token compute.

## The decision rule (from the full 18-model sweep)

- **Raise `mns`/`mnbt`** when the KV cache has room for more sequences; useless once KV is saturated.
- **Raise `gmu`** when the KV cache is the bottleneck; useless when model weights already dominate memory.
- **Speculative decoding** when the model is compute-bound (small) *and* outputs are predictable; harmful when memory-bound or outputs unpredictable.
- **Right-size `tp` first** — for large MoE it is a fit/headroom necessity, not an optimization.

## Per-model throughput → fleet sizing (to hit ~10B tokens/experiment)

| Model | tps/GPU (optimized) | H100s for the run |
|---|---|---|
| SmolLM2-135M | 45,540 | 7 (1 node) |
| Qwen3-4B | 8,086 | ~35 (~5 nodes) |
| Qwen3-8B | 6,443 | ~44 (~6 nodes) |
| GPT-OSS-120B | 6,117 | ~46 (~6 nodes) |
| Gemma-3-27B | 1,724 | ~162 (~20 nodes) |

## Source

Distilled from [[prompt design is the single biggest lever for synthetic pretraining data]] (HuggingFace FinePhrase write-up; infrastructure open-sourced via [DataTrove](https://github.com/huggingface/datatrove)). Underlying engine: [vLLM](https://github.com/vllm-project/vllm) ([Kwon et al., 2023](https://arxiv.org/abs/2309.06180)); speculative decoding per [Leviathan et al., 2023](https://arxiv.org/abs/2211.17192).
