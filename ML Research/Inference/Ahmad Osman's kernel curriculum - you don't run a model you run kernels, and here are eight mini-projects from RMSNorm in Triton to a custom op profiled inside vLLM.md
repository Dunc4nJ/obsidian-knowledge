---
created: 2026-09-03
description: Ahmad Osman's two linked X posts — the thesis that "you don't run a model, you run kernels" (the model is a graph, the engine is scheduler/optimizer/executor, the work happens in MatMul, attention, RMSNorm, KV-cache, quantized-linear, sampling and fused kernels), and the learning curriculum that follows from it. Names the four engines by what distinguishes them (vLLM PagedAttention/continuous batching/prefix caching/CUDA graphs; SGLang RadixAttention/spec decoding/MoE; TensorRT-LLM FP8-FP4/Wide-EP/disaggregated serving; FlashInfer as the reusable kernel library beneath them), the kernel reading list (Triton, CUTLASS/CuTe, FlashAttention, PagedAttention, MoE routing and grouped GEMM, Nsight), and an eight-step mini-project sequence from RMSNorm in Triton to integrating one custom op into vLLM or SGLang and profiling end-to-end. Captured with the ASCII-art diagram and two replies — Jonathan Sandhu's step 9 on checkpoints larger than every memory tier, where the objective becomes useful work per weight traversal, and Gregor's correction that prefix caching and RadixAttention are the same optimization.
source: https://x.com/TheAhmadOsman/status/2095632421844828575
author: Ahmad Osman
type: learning
tags: [inference, gpu-kernels, triton, cutlass, vllm, sglang, tensorrt-llm, flashinfer, paged-attention, flash-attention, moe, speculative-decoding, profiling, learning-roadmap]
---

## Key Takeaways

- **The thesis is a reframe worth keeping even at tweet length: the model is a graph, the engine is a scheduler, and the actual work happens in kernels.** "Same model, same GPU, same VRAM / Wildly different performance" — because one stack uses fused kernels that understand the hardware and the other is "playing hot potato with tensors through 47 tiny launches and pretending the GPU is the problem." The kernel taxonomy he lists is the useful part: MatMul, attention, RMSNorm, KV cache, quantized linear, sampling, and "fused 'please don't write this back to memory 9 times'" — that last category being the whole game, since the cost being avoided is memory traffic, not arithmetic. The closing instruction is the transferable one: "Most people benchmark models. The real ones benchmark the Kernels underneath." The vault has the production-side confirmation in [[agentic kernel development ships to production by profiling the whole model first - 42.3 percent latency cut on Qwen-Image|profiling the whole model before writing any kernel, which cut Qwen-Image latency 42.3%]] — same inversion, with a shipped number attached. The "47 tiny launches" claim also has a clean empirical proof from outside LLM serving entirely: [[CUDA game kernels beat JAX RL environments 7x because PyTorch dispatch overhead dominates tiny networks not simulation|a 1,063-line CUDA rewrite of an RL environment ran 7x faster because op-dispatch and launch overhead, not the simulation math, was the bottleneck]] — hot potato with tensors, measured. And the physics underneath the whole thesis is [[Step 01 - Decode is memory-bandwidth-bound (the roofline)|the decode roofline]]: with a ridge point around B*≈295, decode sits far to the memory-bound side, which is exactly why "don't write this back to memory 9 times" is the optimization and arithmetic is not.

- **The engine list is good because it names each one by its distinguishing mechanism rather than its popularity — and the fourth entry is the tell.** vLLM ([[Amit Shekhar explains how vLLM packs more LLM users onto one GPU through PagedAttention and continuous batching|PagedAttention and continuous batching]], prefix caching, CUDA graphs); SGLang (RadixAttention/prefix reuse, [[Modal argues speculative decoding is the only inference optimization that matters, and custom DFlash speculators turn acceptance length into 2-3x speedups|speculative decoding]], MoE, structured/agent workloads); TensorRT-LLM ([[NVIDIA's hardware-friendly LLM design guide - near-square tile-aligned dimensions, width over depth, NVFP4, and wide expert parallelism|FP8/FP4 and Wide-EP]], disaggregated serving). **FlashInfer is the non-obvious inclusion and the one that proves the thesis** — it isn't an engine at all but "a reusable kernel/operator library for attention/GEMM/MoE/sampling," i.e. the layer the other three consume. Putting it in the same list is the argument: engines differentiate on scheduling, but they increasingly share the kernels underneath. The theory reading list is short and correct — Triton tutorials, CUTLASS/CuTe for Tensor Core GEMM and Blackwell/Hopper, FlashAttention, [[paged attention applies OS virtual memory paging to KV cache and unlocks 2-4x LLM serving throughput|the PagedAttention paper]], MoE routing/grouped GEMM/all-to-all, and Nsight profiling with the best three words in the post: "**stop guessing**." [[Red Hat frames prefill-decode disaggregation, KV-cache tiering, and speculative decoding as the three llm-d deployment levers for distributed AI inference|Red Hat's llm-d framing]] is the vault's one treatment of RadixAttention beside PagedAttention, and [[Philip Kiely details how Baseten built the world's fastest GLM-5.2 API by stacking NVFP4 quantization, KV-aware routing, prefill-decode disaggregation, and MTP speculation|Baseten's GLM-5.2 stack]] is the production form of the TensorRT-LLM bullet.

- **The eight-step mini-project sequence is the actual artifact, and it is ordered by dependency rather than difficulty.** RMSNorm in Triton vs PyTorch → fused SiLU × gate → FP16 matmul vs cuBLAS → paged KV lookup for decode attention → FP8 KV cache with per-block scales → toy top-k sampling on GPU → tiny MoE dispatch + grouped GEMM → **integrate one custom op into vLLM or SGLang and profile end-to-end**. Read as a curriculum, steps 1–3 test "can you write a kernel at all," 4–7 test "can you write the kernels that actually matter for LLM serving," and step 8 is the only one that tests the thesis — because it is the only step where a kernel meets a real scheduler, a real batch, and a real memory hierarchy. That step is also precisely where the vault's production evidence starts, which is a good sign the list ends in the right place rather than at a benchmark. Worked examples for the middle of the ladder: [[vLLM throughput benchmarking on H100 — tensor-parallel sizing, speculative decoding, and FP8 KV-cache economics|benchmarking FlashAttention against FlashInfer as vLLM backends and pricing FP8 KV cache on H100]] is steps 5 and 8 done for real — literally "benchmark the kernels underneath"; [[camelAI self-hosts DeepSeek V4 Flash on 4x RTX PRO 6000 Blackwell for a fixed-cost free tier, with KV cache as the real bottleneck|camelAI capping, quantizing and offloading KV cache on an MXFP4 MoE]] is steps 5–7 in a live deployment; and [[Ramp Labs Latent Briefing compacts KV caches for efficient cross-agent memory sharing|Ramp's batched CUDA kernels for shared-head token selection]] is a fused op written for a real serving path. The automated counterpart to the whole ladder is [[autokernel applies the autoresearch loop to GPU kernel optimization reaching 187 TFLOPS from 18 autonomously|autokernel, which profiles a model, picks bottleneck kernels by Amdahl's law, and writes Triton replacements in an edit-benchmark-keep/revert loop]] — the same sequence, run by an agent.

- **A reply supplies the step the list is missing, and it changes the objective function.** Jonathan Sandhu's proposed #9: make the checkpoint larger than every resident memory tier — "stream weights layer-outer, run candidates position-inner, preserve continuation state across weight eviction, and profile the width knee," with Kimi K3 as the ugly case (~1.5 TB checkpoint against 48 GB of 3090 HBM). The payoff is the reframe: "the optimization target is no longer just kernel latency or tok/s. **It is useful work per weight traversal.**" Every one of the eight steps optimizes time per operation; this optimizes value extracted per pass over the weights, which is the correct metric once weights no longer fit and transport dominates — the regime the vault already has measured in [[LMCache offloads paged KV to system RAM and NVMe, cutting 128K-context time-to-first-token from 68 seconds to 1.4 on 4x DGX Spark|LMCache cutting 128K-context TTFT from 68 seconds to 1.4 by offloading paged KV to system RAM and NVMe]], and adjacent to [[tensor parallelism aggregates memory controllers so 8x RTX PRO 6000 reaches ~14.3 TB-s where one M5 Ultra has 1.2|the bandwidth-aggregation argument]]. [[matmuls are parallel memory reads - Roy's bandwidth ladder puts a 1K RTX 3090 at 936 GB-s above a 5K Mac or DGX Spark, but it has no capacity or prefill column|The bandwidth ladder]] is the axis that metric is defined against, and [[From GPT-2 to Kimi K3 - a visual worklog on how attention architecture evolved to fix the KV cache with linear attention, DeltaNet, gating, and hybrid retrieval|the attention-architecture worklog]] covers the Kimi K3 he cites. Gregor adds a smaller correction worth carrying: **prefix caching and RadixAttention are the same optimization** — the post lists them as separate distinguishing features of vLLM and SGLang, which overstates the gap, since RadixAttention is a radix-tree implementation of prefix reuse rather than a different idea.

- **Positioning: this is a compression, not a syllabus, and the vault holds the fuller versions of every branch of it.** There are no time estimates, no ordering rationale beyond the implicit one, and no prerequisites stated — its value is that it fits on one screen and ends in a project rather than a paper. For depth on each branch: [[MLC's Modern GPU Programming for MLSys is a Blackwell-era book that builds from the GPU execution model through TMA, tensor cores, and TMEM to a SOTA GEMM and Flash Attention 4 in the TIRx Python DSL|MLC's Blackwell-era book]] is the full kernel curriculum this list gestures at, [[Modal's GPU Glossary is a browsable reference that maps the GPU stack from device hardware through the CUDA software layers to performance concepts in ~80 linked terms|Modal's GPU Glossary]] is the reference to keep open beside it, [[Joe Barrow reviews Philip Kiely's Inference Engineering as the reference work he wishes he had in 2023, with a curated what-to-read-next list|Kiely's Inference Engineering]] covers the serving layer, and [[Ashutosh Maheshwari's sub-second LLM study list catalogs sixteen inference optimizations from KV-caching and speculative decoding to tensor parallelism and memory offloading|Maheshwari's sixteen-optimization study list]] is the closest sibling — broader on techniques, weaker on the hands-on sequence, which is where this one wins. [[LLM optimization interview prep maps Flash Attention, ZeRO, speculative decoding, and MoE across training and inference|Gauri Gupta's four-axis survey]] is the other curriculum peer and actually covers FlashAttention and MoE where Osman only names them. The practitioner restatement of Post A's "same model, same GPU, wildly different performance" is [[know the difference between the harness, the model, and serving inference - Roy's longpost on why Qwen 27B flies on a 5090 in pi but feels awful in OpenCode on a MacBook or DGX|Roy's separation of harness, weights, and serving stack]].

## External Resources

- Source: [the curriculum post](https://x.com/TheAhmadOsman/status/2095632421844828575) quote-tweeting [the thesis post](https://x.com/TheAhmadOsman/status/2095335508477894996) — Ahmad Osman (@TheAhmadOsman), 3 Sep 2026
- Engines: [vLLM](https://github.com/vllm-project/vllm) · [SGLang](https://github.com/sgl-project/sglang) · [TensorRT-LLM](https://github.com/NVIDIA/TensorRT-LLM) · [FlashInfer](https://github.com/flashinfer-ai/flashinfer)
- Kernels: [Triton tutorials](https://triton-lang.org/main/getting-started/tutorials/index.html) · [CUTLASS/CuTe](https://github.com/NVIDIA/cutlass) · [FlashAttention](https://arxiv.org/abs/2205.14135) · [PagedAttention / vLLM paper](https://arxiv.org/abs/2309.06180) · [Nsight Systems](https://developer.nvidia.com/nsight-systems)
- Replies: [Jonathan Sandhu's step 9](https://x.com/SandhuJonathan/status/2095640922528817261) · [Gregor on prefix caching vs RadixAttention](https://x.com/bygregorr/status/2095648025582416066)

## Original Content

> [!quote]- Both posts in full, the diagram, and the high-signal replies (Ahmad Osman, 3 Sep 2026)
> ### Post 1 — the thesis (@TheAhmadOsman, 3 Sep 2026, 02:18 UTC · 931 likes)
>
> You don’t “run a model”
> - You run Kernels
>
> The model is just a graph
>
> The Inference Engine is scheduler / optimizer / executor
>
> But the actual work? That happens in the Kernels
>
> - MatMul Kernels
> - Attention Kernels
> - RMSNorm Kernels
> - KV cache Kernels
> - Quantized linear Kernels
> - Sampling Kernels
> - Fused “please don’t write this back to memory 9 times” Kernels
>
> Same model, same GPU, same VRAM
> Wildly different performance
>
> Because one stack is using optimized fused Kernels that understand your hardware
>
> And the other stack is playing hot potato with tensors through 47 tiny launches and pretending the GPU is the problem
>
> Bad Kernels make people say:
> “this model is slow”
>
> Good Kernels make people say:
> “wait how is this running locally?”
>
> This is why Inference Engines and the Kernels implemented within them matter
>
> The model is the recipe
> The hardware is the kitchen
> The Kernels are the knives, pans, burners, and the chef not cutting onions with a spoon
>
> Most people benchmark models
> The real ones benchmark the Kernels underneath
>
> *The accompanying diagram: the recipe / kitchen / chef metaphor rendered as ASCII art, contrasting "47 tiny launches playing hot potato with tensors" against one fused launch — "this model is slow" vs "wait how is this local?"*
> ![[theahmadosman-828575-001.jpg]]
>
> ---
>
> ### Post 2 — the curriculum (@TheAhmadOsman, 3 Sep 2026, 21:57 UTC), quote-tweeting Post 1
>
> Some ideas about how to get started learning about all of this
>
> Inference Engines & Topics
>
> - vLLM: PagedAttention, continuous batching, prefix caching, CUDA graphs
>
> - SGLang: RadixAttention/prefix reuse, speculative decoding, MoE, structured/agent workloads
>
> - TensorRT-LLM: NVIDIA peak stack, FP8/FP4, Wide-EP, disaggregated serving
>
> - FlashInfer: reusable kernel/operator library for attention/GEMM/MoE/sampling
>
> Kernels
>
> - Triton tutorials → custom fused kernels
>
> - CUTLASS/CuTe → Tensor Core GEMM and Blackwell/Hopper details
>
> - FlashAttention papers → attention algorithm/kernel co-design
>
> - PagedAttention paper → KV-cache memory management
>
> - MoE docs → routing + grouped GEMM + all-to-all
>
> - Nsight profiling → stop guessing
>
> Do this mini-project sequence
>
> 1. Implement RMSNorm in Triton; compare to PyTorch
>
> 2. Implement fused SiLU × gate
>
> 3. Implement simple FP16 matmul; compare to cuBLAS/rocBLAS
>
> 4. Implement paged KV lookup for decode attention
>
> 5. Add FP8 KV cache with per-block scales
>
> 6. Implement toy top-k sampling on GPU
>
> 7. Implement tiny MoE dispatch + grouped GEMM
>
> 8. Integrate one custom op into vLLM or SGLang and profile end-to-end
>
> ---
>
> ### High-signal replies
>
> @SandhuJonathan (Jonathan Sandhu):
> Add #9: make the checkpoint larger than every resident memory tier.
>
> Stream weights layer-outer, run candidates position-inner, preserve continuation state across weight eviction, and profile the width knee.
>
> Kimi K3 gave us the ugly case: ~1.5 TB checkpoint, 48 GB 3090 HBM. Once the state survives, transport becomes schedulable rather than fatal.
>
> At that point the optimization target is no longer just kernel latency or tok/s. It is useful work per weight traversal.
>
> Kernels still matter. So does deciding what gets to ride each load.
>
> @bygregorr (Gregor):
> Prefix caching and RadixAttention are the same optimization.
>
