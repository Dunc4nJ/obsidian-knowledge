---
created: 2026-06-29
description: A free online book/course from the MLC (Machine Learning Compilation) community that teaches modern GPU kernel programming as a progression — understand the Blackwell-class GPU (execution/memory model, data layout, TMA, tensor cores, Tensor Memory, async barriers, cluster launch control), learn to program it in the TIRx Python DSL, then build state-of-the-art kernels (a tiled→pipelined→warp-specialized GEMM and a complete Flash Attention 4). This is the note that opens the black box every other note in this folder treats as a given — it is where FlashAttention, quantized kernels, and tensor parallelism actually get written.
source:
  - https://mlc.ai/modern-gpu-programming-for-mlsys/
  - https://github.com/mlc-ai/modern-gpu-programming-for-mlsys
topic: gpu-kernels, gpu-programming, tensor-cores, blackwell, tirx
type: synthesis
---

Source: **Modern GPU Programming For MLSys** — a free online book by the **MLC (Machine Learning Compilation) community** (© 2026), grown out of the Machine Learning Systems course series at Carnegie Mellon. Read online at [mlc.ai/modern-gpu-programming-for-mlsys](https://mlc.ai/modern-gpu-programming-for-mlsys/) (Chinese: [/zh/](https://mlc.ai/modern-gpu-programming-for-mlsys/zh/)); source, code, and `.bib` at [github.com/mlc-ai/modern-gpu-programming-for-mlsys](https://github.com/mlc-ai/modern-gpu-programming-for-mlsys) (a Sphinx/MyST site, auto-deployed on every push to `main`).

## Key Takeaways

- **This is the note that opens the black box.** Almost everything else in this folder treats the GPU kernel as a given: [[paged attention applies OS virtual memory paging to KV cache and unlocks 2-4x LLM serving throughput|FlashAttention and PagedAttention]] "just work," quantized kernels exist, tensor parallelism is a config flag. This book is where those kernels actually get *written* — for the Blackwell generation, at the IR level. If [[Ashutosh Maheshwari's sub-second LLM study list catalogs sixteen inference optimizations from KV-caching and speculative decoding to tensor parallelism and memory offloading|Maheshwari's sixteen-optimization study list]] is the map of *what* to tune in inference, this is the manual for *how* the lowest, hottest layer is built.

- **The thesis: modern GPUs are no longer variations on one old design.** The book's framing is that recent architectures (Hopper, and now Blackwell) introduce *richer memory spaces, new access patterns, and increasingly specialized execution units* — so a correct mental model of the hardware is now a prerequisite, not a nicety. It treats the Blackwell-class GPU itself — its memory hierarchy and **Tensor Memory (TMEM)**, its **tensor-core** and **asynchronous data-movement (TMA)** engines, **warpgroups** and **clusters** — as the real subject, and a kernel as the thing you build once you understand it.

- **Three-act structure: understand → program → build SOTA.** Part I is the hardware mental model; Part II introduces the programming vehicle (TIRx); Parts III–IV build two real, state-of-the-art kernels (a GEMM and Flash Attention 4) step by step from the Part I primitives. The pedagogy is explicitly *progressive*: each GEMM chapter adds one optimization (tiling → async pipelining → warp specialization + clusters), so you see exactly which technique buys which speedup.

- **The vehicle is TIRx, not raw CUDA C++/PTX.** Examples are written in **TIRx (Tensor IR next)**, a Python DSL for authoring GPU kernels at the IR level. It ships as the `tvm.tirx` module of the Apache TVM wheel (`pip install apache-tvm`). This keeps the code close to the hardware (you still reason about TMA, mbarriers, tensor-core operand layouts) while staying in Python — and it ties the book to the broader [Apache TVM / MLC](https://mlc.ai) compiler lineage rather than to a single vendor's C++ toolchain.

- **It targets real Blackwell silicon.** Kernels compile for `sm_100a` and need an actual Blackwell GPU (e.g. a B200) plus a CUDA build of PyTorch to run. The reference GEMM and Flash Attention 4 kernels live in a companion `tirx-kernels` package; you can read and follow the whole book on any machine, but *running* the kernels is hardware-gated. This makes the book unusually current — it teaches the `tcgen05` tensor-core path and TMEM, which are Blackwell-generation features, not the Ampere/Hopper status quo most tutorials stop at.

## Curriculum — what each part teaches

### Part I — Understanding the GPU
The hardware mental model. Introduces the overall organization of the GPU, general recipes for fast kernels, and the key concepts (data layout, asynchronous memory ops, coordination) that the rest of the book leans on.

| Chapter | Teaches |
|---|---|
| **GPU Execution Model** (`chapter_background`) | How the GPU is organized — threads, warps, warpgroups, CTAs, clusters; the execution and memory model |
| **What Makes a Kernel Fast** (`chapter_performance`) | The performance model: roofline, compute- vs memory-bound regimes, overlap |
| **Data Layout and Its Notation** (`chapter_data_layout`) | A deep dive into data layout in memory and the notation used to describe it |
| **Tensor Core Operand Layouts Across GPU Generations** (`chapter_layout_generations`) | How the required operand layouts for tensor cores have changed across GPU generations |
| **Async Data Movement: TMA** (`chapter_tma`) | The Tensor Memory Accelerator — asynchronous bulk copies between global and shared memory |
| **Tensor Cores: `tcgen05`** (`chapter_tensor_cores`) | The Blackwell-generation tensor-core MMA path and how to feed it |
| **Special Memory: TMEM** (`chapter_tmem`) | Tensor Memory — Blackwell's dedicated accumulator memory space |
| **Async Coordination: mbarriers** (`chapter_async_barriers`) | Memory barriers for coordinating asynchronous producers and consumers |
| **Advanced: Cluster Launch Control** (`chapter_clc`) | CLC — advanced scheduling across thread-block clusters |

### Part II — Programming a GPU with TIRx
The programming model. Introduces the key elements of TIRx that serve as the foundation for every later example.

- **Introduction to TIRx** (`chapter_intro_tirx`) — TIRx taught through one runnable single-MMA GEMM: scope, layout, dispatch, and how compilation works.
- **TIRx Layout API** (`chapter_tirx_layout_api`) — the tensor layout model: `TileLayout`, named axes, swizzle.

### Part III — GEMM: Tiled to SOTA
A complete guide to optimizing a tiled matrix-multiply (GEMM), built up one optimization at a time.

- **Building a Tiled GEMM** (`chapter_gemm_basics`) — single-tile sequential GEMM → K-loop accumulation → multi-CTA spatial tiling.
- **Pipelining GEMM with TMA** (`chapter_gemm_async`) — async loads, software pipelining, persistent kernels.
- **Scaling GEMM with Warp Specialization and Clusters** (`chapter_gemm_advanced`) — warp specialization, 2-CTA clusters, multi-consumer patterns.

### Part IV — Flash Attention 4
- **Flash Attention 4** (`chapter_flash_attention`) — a complete attention kernel assembled from the Part III techniques: two MMAs with softmax between them, online-softmax rescaling, causal masking, and **GQA (grouped-query attention)**. This is the kernel that the serving-layer notes ([[Amit Shekhar explains how vLLM packs more LLM users onto one GPU through PagedAttention and continuous batching|vLLM]], [[vLLM throughput benchmarking on H100 — tensor-parallel sizing, speculative decoding, and FP8 KV-cache economics|H100 throughput tuning]]) consume as a black box — here you build it.

### Reference
- **Debugging Warp-Specialized Kernels** (`appendix/debugging_warp_specialized`)
- **Compiler Internals** — the TIRx lowering pipeline (`tirx_guide/arch`)
- **TIRx Language Reference** — data types, buffers, control flow, intrinsics (`tirx_guide/language_reference`)

## Prerequisites & who it's for

The book assumes comfort with GPU programming generally (it does not re-teach C-level CUDA from zero) and is aimed at practitioners and systems students who build the high-performance kernels under ML systems — attention, GEMM, fused layers. To *run* the code you need: a Blackwell GPU (`sm_100a`, e.g. B200), the TIRx compiler (`pip install apache-tvm`, verify with `import tvm.tirx`), and a CUDA build of PyTorch for example inputs and reference checks. To *read* it you need nothing but a browser.

## Why it sits in this folder

This folder is mostly about the **serving layer** — engines, KV-cache management, speculative decoding, batching, quantization economics. This resource is one layer down: the **kernel layer** those optimizations are implemented on top of. The connections are direct:

- **FlashAttention** is a named technique in [[LLM optimization interview prep maps Flash Attention, ZeRO, speculative decoding, and MoE across training and inference]] and in Maheshwari's list — Part IV *implements* it for Blackwell.
- **Quantized / mixed-precision kernels** (NVFP4/FP8) are the lever in [[Philip Kiely details how Baseten built the world's fastest GLM-5.2 API by stacking NVFP4 quantization, KV-aware routing, prefill-decode disaggregation, and MTP speculation]] — the tensor-core and operand-layout chapters here are where those low-precision MMAs live.
- **Tensor parallelism** is a config knob in [[vLLM throughput benchmarking on H100 — tensor-parallel sizing, speculative decoding, and FP8 KV-cache economics]] — the cluster / multi-CTA material here is the hardware substrate it rides on.
- The natural orientation note for the whole territory remains [[Joe Barrow reviews Philip Kiely's Inference Engineering as the reference work he wishes he had in 2023, with a curated what-to-read-next list]], and the folder map is [[moc - Inference]].

A reader who has internalized *what* to optimize from the rest of this folder comes here to learn *how the metal actually executes it.*
