---
created: 2026-06-29
description: Ashutosh Maheshwari (@asmah2107) posts a bookmark-bait study list of sixteen inference optimizations to learn for sub-second LLM responses — KV-caching, speculative decoding, FlashAttention, PagedAttention, batch inference, early-exit and parallel decoding, mixed-precision and quantized kernels, tensor/pipeline/sequence parallelism, graph optimization (ONNX/TensorRT), dynamic batching, memory offloading, and streaming generation — promising to write in depth on each. It's an index, not an argument; its value is as a curriculum that maps onto the deep-dives already in this folder.
source: https://x.com/asmah2107/status/2071196830088777741
type: synthesis
---

Source: [@asmah2107 (Ashutosh Maheshwari) on X](https://x.com/asmah2107/status/2071196830088777741) — "Inference optimizations I'd study if I wanted sub-second LLM responses," June 28, 2026.

## Key Takeaways

- **This is a curriculum, not a thesis.** Maheshwari makes no claim about *which* of the sixteen matters most — he lists the whole surface area of LLM inference optimization and commits to "writing in depth on each moving forward." That makes it the opposite of the contrarian framing in [[Modal argues speculative decoding is the only inference optimization that matters, and custom DFlash speculators turn acceptance length into 2-3x speedups]], where the argument is that fifteen of these buy single-digit-percent gains and only speculative decoding delivers integral-factor speedups. Read the two together: this list is the map, Modal's post is the opinion about where the treasure is buried. The natural orientation note for the territory is [[Joe Barrow reviews Philip Kiely's Inference Engineering as the reference work he wishes he had in 2023, with a curated what-to-read-next list]].

- **The sixteen collapse into ~six bottleneck layers, and latency comes from attacking the right one.** Decode is memory-bandwidth-bound (one token per forward pass, re-reading all weights), so the KV-cache and quantization levers dominate there; prefill is compute-bound, so attention kernels and parallelism dominate there. Grouping the list by *which physical bottleneck it relieves* — memory, attention math, token-economy-per-step, batching/scheduling, numeric precision, model sharding, compiler — is more useful than the flat enumeration, and it's the taxonomy the rest of this folder is already organized around.

- **Several entries are the same lever at different granularity — the list double-counts.** Batch Inference, Dynamic Batching, and the continuous batching from [[Amit Shekhar explains how vLLM packs more LLM users onto one GPU through PagedAttention and continuous batching]] are one idea (keep the GPU saturated by packing concurrent requests) at three resolutions. Mixed-Precision Inference and Quantized Kernels are the precision lever twice — exactly the NVFP4/FP8 stack in [[Philip Kiely details how Baseten built the world's fastest GLM-5.2 API by stacking NVFP4 quantization, KV-aware routing, prefill-decode disaggregation, and MTP speculation]]. KV-Caching and PagedAttention are the same memory object (the cache) and its allocator. A learner should treat them as ~10 distinct concepts, not 16.

- **"Sub-second" is a *interactivity* target, which changes the ranking.** At high concurrency and low latency, the token-economy levers (speculative / parallel / early-exit decoding) and the memory levers (PagedAttention, KV-caching) move the needle most, because they raise tokens-per-second-per-user without buying more hardware — the same regime explored empirically in [[vLLM throughput benchmarking on H100 — tensor-parallel sizing, speculative decoding, and FP8 KV-cache economics]] and pushed to production in DeepSeek's [[DSpark (DeepSeek paper) couples a semi-autoregressive drafter with a hardware-aware confidence scheduler to raise accepted length 16-31% offline and shift DeepSeek-V4's serving Pareto frontier|DSpark]].

## The sixteen optimizations, grouped by bottleneck

The thread lists them flat and numbered. Reorganized by the physical bottleneck each one relieves, with pointers into this folder's deep-dives:

**KV cache & memory (the decode-step memory bottleneck)**
- **1. KV-Caching** — store the per-token key/value tensors so each new token attends to history without recomputing it; the cache, not FLOPs, is what caps concurrent users. See [[Amit Shekhar explains how vLLM packs more LLM users onto one GPU through PagedAttention and continuous batching]] and [[Ramp Labs Latent Briefing compacts KV caches for efficient cross-agent memory sharing]].
- **4. PagedAttention** — manage that cache like OS virtual memory: fixed-size blocks scattered across VRAM via a block table, enabling prefix sharing and near-zero fragmentation. The canonical result is [[paged attention applies OS virtual memory paging to KV cache and unlocks 2-4x LLM serving throughput]].
- **15. Memory Offloading** — spill cold weights or KV blocks to CPU/host RAM (or disk/NVMe) to fit larger models or longer contexts than VRAM allows; the GPU↔CPU offload pattern appears in [[Ramp Labs Latent Briefing compacts KV caches for efficient cross-agent memory sharing]].

**Attention kernels (the prefill compute bottleneck)**
- **3. FlashAttention** — a fused, IO-aware attention kernel that tiles the computation in SRAM to avoid materializing the full N×N attention matrix in HBM, turning attention from memory-bound to compute-bound. Catalogued alongside the other core techniques in [[LLM optimization interview prep maps Flash Attention, ZeRO, speculative decoding, and MoE across training and inference]].

**Token economy per step (more useful tokens per forward pass)**
- **2. Speculative Decoding** — a cheap draft model proposes several tokens, the target model verifies them in one batched pass; speedup is roughly linear in acceptance length. The folder's richest cluster: [[Modal argues speculative decoding is the only inference optimization that matters, and custom DFlash speculators turn acceptance length into 2-3x speedups]], [[Rachel Rapp explains how Baseten trains speculative-decoding draft models live from inference hidden states, raising accept rates 20%+ with no offline data storage]], [[elie breaks down DeepSeek's DSpark, a semi-parallel speculative decoder that fuses DFlash's parallel head with an Eagle-style Markov step for +50% throughput and up to 80% lower latency in DeepSeek-V4 production]], and the full paper [[DSpark (DeepSeek paper) couples a semi-autoregressive drafter with a hardware-aware confidence scheduler to raise accepted length 16-31% offline and shift DeepSeek-V4's serving Pareto frontier]].
- **6. Early Exit Decoding** — let "easy" tokens leave the network at an intermediate layer instead of running all layers, trading a small quality risk for fewer FLOPs per token; conceptually a cousin of speculative decoding (skip compute the model doesn't need).
- **7. Parallel Decoding** — break the strictly-sequential autoregressive dependency to emit multiple tokens per step (semi-autoregressive / multi-token-prediction drafting). This is exactly the semi-parallel mechanism in [[DSpark (DeepSeek paper) couples a semi-autoregressive drafter with a hardware-aware confidence scheduler to raise accepted length 16-31% offline and shift DeepSeek-V4's serving Pareto frontier]].

**Batching & scheduling (keep the GPU saturated)**
- **5. Batch Inference** — process many requests in one forward pass to amortize the weight-reads; the foundational throughput lever.
- **14. Dynamic Batching** — form batches on the fly from whatever requests have arrived (and, with *continuous* batching, swap finished sequences out and new ones in mid-flight) so no slot idles. Both are the engine behavior in [[Amit Shekhar explains how vLLM packs more LLM users onto one GPU through PagedAttention and continuous batching]].
- **16. Streaming Generation** — emit tokens to the client as they're produced rather than waiting for the full completion; doesn't lower total latency but collapses *time-to-first-token*, which is what "feels" sub-second to a user.

**Numeric precision (cheaper math, smaller footprint)**
- **8. Mixed-Precision Inference** — run in FP16/BF16 (or FP8) instead of FP32 for ~2x memory and bandwidth savings at negligible quality cost.
- **9. Quantized Kernels** — INT8/INT4/FP4 weights (and sometimes activations/KV cache) with custom kernels that compute directly in low precision. The production stack — NVFP4 weights, FP8 KV cache — is dissected in [[Philip Kiely details how Baseten built the world's fastest GLM-5.2 API by stacking NVFP4 quantization, KV-aware routing, prefill-decode disaggregation, and MTP speculation]] and swept empirically in [[vLLM throughput benchmarking on H100 — tensor-parallel sizing, speculative decoding, and FP8 KV-cache economics]].

**Model sharding / parallelism (split a model too big for one GPU)**
- **10. Tensor Parallelism** — split individual weight matrices across GPUs (intra-layer); the `tp` knob whose payoff vs. speculative decoding is measured in [[vLLM throughput benchmarking on H100 — tensor-parallel sizing, speculative decoding, and FP8 KV-cache economics]].
- **11. Pipeline Parallelism** — assign different layers to different GPUs and stream micro-batches through the stages (inter-layer).
- **12. Sequence Parallelism** — partition along the sequence/context dimension to fit long contexts and reduce activation memory. Pipeline and sequence parallelism, plus ZeRO, are the parallelism reading-list spine pointed to in [[Joe Barrow reviews Philip Kiely's Inference Engineering as the reference work he wishes he had in 2023, with a curated what-to-read-next list]] and mapped in [[LLM optimization interview prep maps Flash Attention, ZeRO, speculative decoding, and MoE across training and inference]].

**Compiler / graph (lower the dispatch overhead)**
- **13. Graph Optimization (ONNX, TensorRT)** — ahead-of-time compile the model graph: operator fusion, constant folding, kernel autotuning, CUDA-graph capture to kill per-op launch overhead. TensorRT-LLM is one of the three engines (with vLLM and SGLang) that the orientation note in [[Joe Barrow reviews Philip Kiely's Inference Engineering as the reference work he wishes he had in 2023, with a curated what-to-read-next list]] frames the "which engine?" decision around.

*The thread's diagram, showing six of the sixteen levers — KV-Caching, Speculative Decoding, FlashAttention, PagedAttention, Batch Inference, Early Exit Decoding — funneling toward sub-second LLM responses:*
![[asmah2107-777741-001.png]]

## Original Content

> [!quote]- Full thread (@asmah2107, June 28, 2026)
>
> **@asmah2107 (Ashutosh Maheshwari):**
> Inference optimizations I'd study if I wanted sub-second LLM responses:
>
> Bookmark this.
>
> 1. KV-Caching
> 2. Speculative Decoding
> 3. FlashAttention
> 4. PagedAttention
> 5. Batch Inference
> 6. Early Exit Decoding
> 7. Parallel Decoding
> 8. Mixed Precision Inference
> 9. Quantized Kernels
> 10. Tensor Parallelism
> 11. Pipeline Parallelism
> 12. Sequence Parallelism
> 13. Graph Optimization (ONNX, TensorRT)
> 14. Dynamic Batching
> 15. Memory Offloading
> 16. Streaming Generation
>
> ![[asmah2107-777741-001.png]]
>
> *Sun Jun 28 11:39:39 +0000 2026 — [link](https://x.com/asmah2107/status/2071196830088777741)*
>
> ---
>
> **@slobkebap (mahir):** @asmah2107 recommendation for any article or reading list for this?
> *Sun Jun 28 12:41:44 +0000 2026 — [link](https://x.com/slobkebap/status/2071212452415516804)*
>
> ---
>
> **@asmah2107 (Ashutosh Maheshwari):** Follow @asmah2107 to upskill your AI engineering game.
> *Sun Jun 28 13:13:50 +0000 2026 — [link](https://x.com/asmah2107/status/2071220529395360104)*
>
> ---
>
> **@asmah2107 (Ashutosh Maheshwari):** @slobkebap will be writing in depth on each moving forward..
> *Sun Jun 28 13:21:23 +0000 2026 — [link](https://x.com/asmah2107/status/2071222432187523431)*
>
> ---
>
> **@byanujpatel (Anuj Patel):** @asmah2107 any resource u follow to learn and read about this !
> *Sun Jun 28 13:23:00 +0000 2026 — [link](https://x.com/byanujpatel/status/2071222838934339989)*
>
> ---
>
> **@asmah2107 (Ashutosh Maheshwari):** @byanujpatel will be writing in depth on each moving forward..
> *Sun Jun 28 13:26:41 +0000 2026 — [link](https://x.com/asmah2107/status/2071223762570400125)*
>
> ---
>
> **@adelbucetta (Adel Bucetta):** @asmah2107 kv-caching is the one i still don't get, sounds like voodoo for memory access
> *Sun Jun 28 15:45:46 +0000 2026 — [link](https://x.com/adelbucetta/status/2071258766218309758)*
>
> ---
>
> **@ronakdedhiya (Ronak Dedhiya):** @asmah2107 Very informative
> *Sun Jun 28 16:05:19 +0000 2026 — [link](https://x.com/ronakdedhiya/status/2071263686409494992)*
>
> ---
>
> **@hshekh (Dr. H. Shekh):** @asmah2107 https://t.co/6YxH6NNa45
> *Sun Jun 28 18:33:49 +0000 2026 — [link](https://x.com/hshekh/status/2071301056701620493)*
>
> ---
>
> **@Gugu81069808 (Gugu8):** @asmah2107 And whatever deepseek does😂
> *Sun Jun 28 19:29:22 +0000 2026 — [link](https://x.com/Gugu81069808/status/2071315038112194644)*
>
> ---
>
> **@Argona0x (Argona):** @asmah2107 that's an interesting list, should go through it today deeper
> *Sun Jun 28 20:36:28 +0000 2026 — [link](https://x.com/Argona0x/status/2071331920797979064)*
>
> ---
>
> **@aiseomastery (AI Mastery Guide):** @asmah2107 Speculative decoding is the one most people overlook on lists like this, even though it gives some of the easiest latency wins.
> *Sun Jun 28 23:44:44 +0000 2026 — [link](https://x.com/aiseomastery/status/2071379302843908385)*
