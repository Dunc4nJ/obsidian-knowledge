---
created: 2026-08-29
description: Brian Li's writeup of an agentic kernel-development framework that closes the gap between winning kernel benchmarks and shipping to production — a two-layer stack (model-level optimization that restructures the execution graph, then per-kernel optimization exploring implementations in parallel) with a self-improving knowledge base of successful and failed attempts. Results on SGLang/B300: 42.3% end-to-end latency cut on Qwen-Image, 15.2% on FLUX.2, and 5.5% tok/s on MiniMax M3, all identified, proposed, and implemented by the agent.
source: https://x.com/BrianLi23/status/2093487934448214351
author: "@BrianLi23 (Brian Li)"
type: article
tags: [inference, kernels, cuda, triton, autoresearch, agentic-optimization, sglang, fp8, nvfp4, diffusion-models, profiling]
---

## Key Takeaways

- **The thesis: winning KernelBench is not shipping to production, and the four reasons why are the real contribution.** (1) **The best kernel config depends on the workload** — tile shapes, warp specialization, and CTA configs respond differently to tensor shape, batch size, and sequence length, "especially visible" for MoE and attention. (2) **A faster microbenchmark ≠ a faster model** — once integrated, CUDA graph capture and multi-stream execution "can wipe out kernel-level gains or even result in a regression." (3) **Per-kernel optimization misses higher-level wins** — traces show only a small subset of kernels have headroom; the cheaper wins come from *restructuring computation around them* (fusion, eliminating redundant work, removing pipeline bubbles). (4) **Integration into a serving engine is nontrivial** — interconnected execution paths, not a standalone torch model. This is the benchmark-vs-production gap that [[benchmarks are measurement instruments not question collections - regulargio's first-principles guide to claims, graders, coverage, and uncertainty|benchmarking science]] warns about and that [[Prime Intellect's fine-tune-last doctrine - 5x task timeouts lifted Terminal-Bench 14.7 points with no model change|the fix-the-environment-first doctrine]] identifies from the eval side, applied to kernels.

- **The architecture: two layers, where the top one exists to widen the search space beyond one-for-one kernel swaps.** *Model-level optimization* profiles the whole workload and proposes graph restructuring — fusion, redundant-work elimination, reduced intermediate materialization. *Per-kernel optimization* then takes the generated and performance-critical kernels from the trace, "explores several implementations in parallel, and iterates on the strongest candidate." Doing model-level first is the design choice that matters: it changes *what kernels exist* before optimizing them, which is why the biggest single win below is a graph-level cache rather than a faster kernel.

*The two-layer optimization stack, and the self-improvement loop retaining passing kernels plus lessons from successes and failures:*
![[agentic-kernels-001.jpg]]
![[agentic-kernels-002.jpg]]

- **The self-improvement loop is the autoresearch pattern applied to kernels.** Kernels passing correctness *and end-to-end* checks are retained as reusable candidates, while "lessons from both successful and failed attempts are added to an evolving knowledge base alongside workload constraints and integration findings" — so each run starts from accumulated experience and converges faster. That's the same failure-mining-into-persistent-memory loop as [[autokernel applies the autoresearch loop to GPU kernel optimization reaching 187 TFLOPS from 18 autonomously|autokernel]] and [[CORAL multi-agent co-evolution beats OpenEvolve by 20% on Anthropic's kernel engineering task|CORAL]] on the generate-and-evaluate side, and [[HALO uses an RLM to mine harness-shaped failures from agent execution traces and lift benchmarks 10-16 percentage points|HALO]]/[[Self-Harness lets a fixed LLM rewrite its own agent harness from clustered failure traces, lifting Terminal-Bench held-out pass rates up to 21 points|Self-Harness]] on the learn-from-traces side — with the distinguishing feature that the reward signal here is *production* end-to-end latency, not a benchmark score.

- **The optimizations themselves are a catalogue of where real headroom hides — mostly in data movement and redundancy, not math.** Shared across both diffusion models: **prepacked FP8 scales** (constant weight scales were being repacked through sequences of small kernel launches every step; move weight-scale packing to load time and have activation producers emit packed scales directly — *bit-identical outputs*, 7.3% / 6.1% end-to-end); **fused QKV projection + epilogue** (three FP8 projections sharing one input merged into one GEMM, with bias, QK-norm, RoPE, and buffer writes fused into a single Triton epilogue — **15.8% on Qwen-Image FP8**; NVFP4 keeps separate GEMMs because each projection has a different scale); **normalization + quantization fusion** (killing a large BF16 intermediate write-and-read round trip). Then Qwen-specific: **bias absorption** (two standalone bias adds were ~11% of FP8 step time → folded into the next fused op, 5.2%) and the standout **CFG modulation cache** — classifier-free guidance runs two denoiser passes per timestep, and the image/text modulation branches depend *only* on the timestep embedding and fixed weights, not the prompt, so they're identical across the conditional and unconditional passes and cacheable via tensor identity (2.1% FP8 / 3.1% NVFP4). Per-kernel passes then delivered `token_cat` **4.6x**, `norm_out` **3.35x**, `qknorm_rope` **2.0x**, `resnorm_quant` **1.65x** — together 7.6% FP8 / 13.4% NVFP4 on Qwen-Image.

*Cumulative ms/step saved per optimization, per-step denoise time by configuration, and the baseline vs model-level vs kernel-level breakdown:*
![[agentic-kernels-010.jpg]]
![[agentic-kernels-017.jpg]]
![[agentic-kernels-018.jpg]]
![[agentic-kernels-019.jpg]]

- **Where it's headed, and the honest caveat about LLMs: mature kernels leave less room.** The framework is model- and engine-agnostic, and they've begun applying it to LLMs — "where kernel implementations are considerably more mature and leave less headroom" — yielding up to **5.5% tok/s on MiniMax M3 and GLM-5.2 on vLLM**, versus 42.3% on a diffusion model. That asymmetry is the useful signal: agentic kernel work pays most where the ecosystem hasn't already ground the fat out, which is exactly the [[buy the RAM that holds the model - a SKU-by-SKU M5 Mac guide with the CUDA tax and separate decode-prefill predictions|CUDA tax]] observation from the other direction — mature CUDA paths are hard to beat, immature ones are full of free wins. The end-state they describe is per-deployment kernel specialization: "each deployment could continuously evolve toward the implementation best suited to its real traffic" — [[the harness is everything and agent performance comes from environment design not model capability|environment-specific optimization]] pushed down to the kernel layer, and the natural complement to [[NVIDIA's hardware-friendly LLM design guide - near-square tile-aligned dimensions, width over depth, NVFP4, and wide expert parallelism|designing models for the hardware]] and the Blackwell-era kernel craft in [[MLC's Modern GPU Programming for MLSys is a Blackwell-era book that builds from the GPU execution model through TMA, tensor cores, and TMEM to a SOTA GEMM and Flash Attention 4 in the TIRx Python DSL|MLC's GPU programming book]].

## External Resources

- Original article: [Agentic Kernels in Production — @BrianLi23, 2026-08-28](https://x.com/BrianLi23/status/2093487934448214351)
- Referenced: [KernelBench](https://github.com/ScalingIntelligence/KernelBench) · SGLang on B300 GPUs (diffusion) · vLLM (LLM experiments) · DeepGEMM · Triton
- Models optimized: Qwen-Image (42.3%), FLUX.2 (15.2%), MiniMax M3 / GLM-5.2 (up to 5.5% tok/s)

## Original Content

> [!quote]- Full X Article — "Agentic Kernels in Production" (@BrianLi23, 2026-08-28)
> Article: Agentic Kernels in Production
>
> > TL;DR: We’ve built an agentic kernel development framework that identifies model-level optimization opportunities, generates improved kernels, and validates them in our serving stack. On our current models, we’ve improved end-to-end latency by 42.3% on Qwen-Image, 15.2% on FLUX.2 and 5.5% increase in tok/s on MiniMax M3.
>
> ---
>
> We’ve seen in recent years that agents have become surprisingly capable at kernel development, from ideation to generating kernels from scratch. Existing benchmarks such as [KernelBench](https://github.com/ScalingIntelligence/KernelBench) have made it easier to evaluate how well agents can optimize kernels on isolated general-purpose problems.
>
> However, there’s a gap between winning a kernel benchmark and shipping optimizations into production.
>
> A few reasons why:
>
> 1. The best kernel configuration depends on the production workload. The kernel that wins on a general benchmark may lose on a specific deployment. Optimizations such as tile shapes, warp-specialization strategy and CTA configurations respond differently to changes in tensor shape, batch size, sequence length, etc. Kernels like MoE and Attention make this especially visible.
>
> 2. A faster microbenchmark doesn’t necessarily translate to a faster model. Once your changes are integrated, interactions with downstream dependencies like CUDA graph capture and multi-stream execution can wipe out kernel-level gains or even result in a regression.
>
> 3. Optimizing kernels individually can miss higher-level opportunities. End-to-end traces often show that only a small subset of kernels have headroom for improvement. The lower-effort wins may come from restructuring the computation around them: fusing operations, eliminating redundant work, or removing pipeline bubbles.
>
> 4. Integrating a new kernel into a production serving engine is nontrivial. Unlike modifying a standalone torch model, serving engines have interconnected execution paths and dependencies. New kernels must be wired into the correct path, replace existing computation cleanly, and remain compatible with the surrounding runtime.
>
> With this in mind, we’ve created a solution that bridges the gap between benchmarks and production. Given a model and serving engine, our framework is able to profile the full workload, reason about the best optimizations, then generate and ship those kernels straight to production.
>
> ---
>
> # The stack
>
> The optimization stack divides into two layers:
>
> 1. Model-Level Optimization:  Understands the full model workload, profiles where time is spent, and proposes changes such as fusion and redundant work elimination.
>
> 2. Per-Kernel Optimization: Takes generated and other performance-critical kernels identified in the trace, explores several implementations in parallel, and iterates on the strongest candidate.
>
> The first layer helps expand the search space beyond one-for-one kernel improvements. Rather than only optimizing kernels in isolation, the framework can restructure the execution graph by removing redundant work, reducing intermediate materialization, or combining operations before generating and improving the underlying kernels.
>
> ## Learning across optimization runs
>
> Our framework also has a self-improving mechanism: kernels that pass correctness and end-to-end performance checks are retained as reusable candidates., while lessons from both successful and failed attempts are added to an evolving knowledge base alongside workload constraints and integration findings.
>
> This creates a self-improvement loop where each optimization iteration starts from accumulated experience, enabling the agent to generate stronger candidates and converge faster over time.
>
> # Results + case studies
>
> Our initial experiment targeted diffusion models, namely Qwen-Image and FLUX.2 served with SGLang on B300 GPUs. The optimizations highlighted below were identified, proposed, and implemented entirely by our agentic framework.
>
> ## Optimizations on both models
>
> Optimization #1 - Prepacked FP8 Scales
>
> The FP8 paths in Qwen-Image and FLUX.2 were wasting launches converting scale metadata into DeepGEMM’s required format before matrix multiplications. Constant weight scales were repeatedly repacked through sequences of small kernel launches.
>
> We eliminate this overhead by changing the main FP8 activation producers to emit packed scales directly while also moving weight-scale packing to model load time. The numerical computation is unchanged, so outputs remain bit-identical.
>
> For example, at FLUX.2 attention projections:
>
> *Profiler trace — FLUX.2 attention projections before/after prepacked FP8 scales:*
> ![[agentic-kernels-003.jpg]]
> ![[agentic-kernels-004.jpg]]
>
> Another example at Qwen-Image feed-forward layer:
>
> *Qwen-Image feed-forward layer:*
> ![[agentic-kernels-005.jpg]]
> ![[agentic-kernels-006.jpg]]
>
> The optimization reduced end-to-end latency by 7.3% on Qwen-Image and 6.1% on FLUX.2, with these gains persisting throughout the subsequent FP8 optimizations.
>
> Optimization #2 - Fused QKV projection and epilogue
>
> Both models’ original attention paths compute the image query, key, and value projections independently, despite them all using the same input. This resulted in repeated activation quantization and GEMM setup throughout every attention block.
>
> The optimization merges the three FP8 projections into one GEMM, then fuses bias addition, QK normalization, RoPE, and writes to the joint image-text attention buffers in a single Triton epilogue. NVFP4 still uses separate Q, K, and V GEMMs as each projection uses a different scale.
>
> *Fused QKV projection + Triton epilogue, traced:*
> ![[agentic-kernels-007.jpg]]
> ![[agentic-kernels-008.jpg]]
>
> | Model | FP8 latency | NVFP4 latency |
> | --- | --- | --- |
> | Qwen-Image | **15.8%** lower | **1.3%** lower |
> |FLUX.2 | **1.3%** lower | **1.1%** lower |
>
> Optimization #3 - Normalization + quantization kernel fusion
>
> In both models, normalization previously produced a large BF16 tensor that the following quantization kernel immediately reads back. Thus, the fix was to simply fuse these together, eliminating the intermediate BF16 write-and-read round trip.
>
> On Qwen-Image, the fused kernel emits both the original BF16 result and pre-quantized FP8 activations for the QKV and feed-forward GEMMs. This reduces latency by 4.3%, and creates the producer path used by the packed-scale optimization.
>
> On FLUX.2’s residual path, the fused kernel emits the normalized output, updated residual, packed E2M1 values, and swizzled E4M3 scales in one pass. This improves end-to-end latency by 0.7%.
>
> *Normalization + quantization fusion, removing the BF16 round trip:*
> ![[agentic-kernels-009.jpg]]
>
> ## Qwen-Image
>
> Optimization #1 - Bias absorption
>
> After the previous optimization, there are two standalone bias additions remaining after the attention and feed-forward output projections which account for roughly 11% of Qwen-Image's FP8 step time. To account for this, we fold each bias into the next fused operation (residual normalization scale and residual update) reducing latency by 5.2%.
>
> *Bias absorption into the following fused operation:*
> ![[agentic-kernels-011.jpg]]
> ![[agentic-kernels-012.jpg]]
>
> Optimization #2 - CFG modulation cache
>
> Classifier-free guidance runs two denoiser passes at the same timestep. Each pass uses different conditioning (one receives the prompt, while the other receives an empty or negative prompt $\varnothing$) The previous implementation recomputed the same timestep-only image and text modulation branches in both passes:
>
> *The duplicated timestep-only modulation branches across both CFG passes:*
> ![[agentic-kernels-013.jpg]]
>
> The noisy latent and timestep are shared by both passes. The image and text modulation branches are functions only of the timestep embedding and fixed model parameters, not the prompt:
>
> *Why the branches are cacheable — they depend only on the timestep embedding and fixed weights:*
> ![[agentic-kernels-014.jpg]]
> ![[agentic-kernels-015.jpg]]
> ![[agentic-kernels-016.jpg]]
>
> and so:
>
> Because these modulation branches depend only on $e_t$ and fixed weights, their outputs are identical across the conditional and unconditional passes at the same timestep, making it cacheable. Prompt-dependent outputs like hidden states and attention are computed separately.
>
> Create cache key at DiT entry (the same timestep object is passed to both CFG branches):
>
> ```python
> def _cfg_cache_optimization_enabled(active) -> bool:
>     return active
>
> # QwenImageTransformer2DModel.forward
> if _cfg_cache_optimization_enabled() and isinstance(timestep, torch.Tensor):
>     # Both CFG branches receive the same timestep tensor.
>     # Keep a reference to it so tensor identity can be used safely.
>     cache_key = {
>         "timestep": timestep,
>         "version": version_if_available(timestep), 
>     }
> ```
>
> Cache the image and text modulation outputs in each block
>
> ```python
> # QwenImageTransformerBlock.forward
> cached = getattr(self, "modulation_cache", None)
>
> cache_hit = (
>     cache_key is not None
>     and cached is not None
>     and cached["timestep"] is cache_key["timestep"]
>     and cached["version"] == cache_key["version"]
> )
>
> if cache_hit:
>     # Second CFG pass: reuse the cached outputs.
>     image_modulation = cached["image_modulation"]
>     text_modulation = cached["text_modulation"]
>
> else:
>     # First CFG pass: compute the modulation outputs.
>     image_modulation = image_modulation_GEMM(timestep_embedding)
>     text_modulation = text_modulation_GEMM(timestep_embedding)
>
>     # Cache them for the second CFG pass.
>     if cache_key is not None:
>         self.modulation_cache = {
>             "timestep": cache_key["timestep"],
>             "version": cache_key["version"],
>             "image_modulation": image_modulation,
>             "text_modulation": text_modulation,
>         }
> ```
>
> This contributes to a reduction in latency of 2.1% for FP8 and 3.1% for NVFP4.
>
> Optimization #3 - Per-kernel optimization
>
> We then run an optimization pass on performance-critical and previously fused kernels, producing the following improvements:
>
> | Original Kernel | What it does | New Kernel |
> | --- | --- | --- |
> | `swiglu_fp4_quant` | Fuses SwiGLU with NVFP4 quantization for production-aligned shapes *— optimization #2 kernel* | **1.43× / 1.41×** |
> | `resnorm_quant` | Fuses residual normalization with quantization and accelerates the FP8 residual-normalization chain *— optimization #3 kernel* | **1.65×** |
> | `qknorm_rope` | Fuses double-block QK normalization and RoPE *— optimization #1 kernel* | **2.0×** |
> | `token_cat` | Accelerates the remaining image-text concatenations *— optimization #2 kernel* | **4.6×** |
> | `norm_out` | Fuses boundary layer normalization, scale multiplication, and residual addition *— optimization #3 kernel* | **3.35×** |
> | `swiglu` | Optimizes the remaining unquantized SwiGLU sites *— optimization #2 kernel* | **1.24×** |
> | `gate_res_norm` | Optimizes the remaining gated residual-normalization path *— optimization #3 kernel* | **1.27×** |
>
> Together, these per-kernel optimizations have a latency improvement of 7.6% for FP8 and 13.4% for NVFP4.
>
> ## FLUX.2
>
> Optimization #1 - Single-Block QK normalization + RoPE
>
> FLUX.2’s single-stream transformer block didn’t use the production fused QK-normalization and RoPE kernel because of a Python contiguity guard that rejected the merged-GEMM views. The fallback ran QK RMSNorm and interleaved RoPE as separate passes which repeatedly concatenated the cosine and sine caches.
>
> The new replacement is a per-token-CTA kernel that loads each contiguous 12 KB Q/K head tile, performs RMSNorm in FP32, rounds the result to BF16, and applies interleaved RoPE in the same pass. It reads the cosine and sine tensors directly, eliminating 48 of 60 cache concatenations per step.
>
> *FLUX.2 single-block QK normalization + RoPE, fused per-token-CTA kernel:*
> ![[agentic-kernels-020.jpg]]
>
> The fused kernel offers a 2× speedup, resulting in end-to-end latency improvements of 2.3% for FP8 and 4.0% for NVFP4.
>
> Optimization #2 - Fused SwiGLU + FP8/NVFP4 quantization
>
> Each invocation of SwiGLU previously produced a large BF16 intermediate that a separate FP8 or NVFP4 quantization kernel read for the output projection. Some single blocks also launched another operation to join attention features with the SwiGLU output.
>
> This optimization replaces those multi-stage paths with a single fused kernel that performs the aforementioned steps in one pass:
>
> For FP8, matching production exactly requires preserving the original operation order: compute SiLU using division, round to BF16, multiply in BF16, and derive the FP8 scale from the stored BF16 result.
>
> For NVFP4, the same fused path directly emits the packed E2M1 values and swizzled E4M3 scales required by the downstream FP4 GEMM. This eliminates the intermediate BF16 write-and-read round trip, contiguous copy, and multiple standalone kernel launches.
>
> The fused kernel reduces latency by 2.3% for FP8 and 3.8% for NVFP4.
>
> Optimization #3 - Gated Residual Normalization
>
> FLUX.2’s residual path previously ran the gated residual update and layer normalization as two separate operations. The previous production stack didn’t support FLUX.2’s gate, leaving the model on the unfused path.
>
> The new kernel fuses the gate multiplication, residual update, normalization, and scale/shift into one operation, reducing latency by 1.2% for FP8 and 2.3% for NVFP4.
>
> Optimization #4 - Per-Kernel Optimization
>
> Similar to Qwen-Image, we run another per-kernel optimization loop that identifies the following improvements:
>
> | Original Kernel | What it does | New Kernel |
> | --- | --- | --- |
> | `swiglu_fp4_quant` | Fuses SwiGLU with NVFP4 quantization for production-aligned shapes *— optimization #2 kernel* | **1.43× / 1.41×** |
> | `resnorm_quant` | Fuses residual normalization with quantization and accelerates the FP8 residual-normalization chain *— optimization #3 kernel* | **1.65×** |
> | `qknorm_rope` | Fuses double-block QK normalization and RoPE *— optimization #1 kernel* | **2.0×** |
> | `token_cat` | Accelerates the remaining image-text concatenations *— optimization #2 kernel* | **4.6×** |
> | `norm_out` | Fuses boundary layer normalization, scale multiplication, and residual addition *— optimization #3 kernel* | **3.35×** |
> | `swiglu` | Optimizes the remaining unquantized SwiGLU sites *— optimization #2 kernel* | **1.24×** |
> | `gate_res_norm` | Optimizes the remaining gated residual-normalization path *— optimization #3 kernel* | **1.27×** |
>
> Together, these kernels reduced NVFP4 latency by 2.8% and FP8 latency by 1.9%.
>
> # Future Direction
>
> The framework is designed to be model and engine-agnostic, allowing the same optimization loop to be applied across various serving stacks. We have already begun expanding into LLM optimization, where kernel implementations are considerably more mature and leave less headroom for improvement. Despite this, early results show up to 5.5% tok/s improvements on models such as MiniMax M3 and GLM-5.2 on VLLM (Stay tuned!)
>
> As the harness and production integration continue to improve, we see a path toward automatically generating kernels that are specialized for the workloads that actually matter given a specific model, hardware platform, tensor shapes, and serving patterns. Rather than relying solely on generic kernels, each deployment could continuously evolve toward the implementation best suited to its real traffic.
