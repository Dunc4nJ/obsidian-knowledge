---
created: 2026-06-30
description: A free, browsable glossary from Modal that defines ~80 GPU terms across four layers — device hardware (SMs, tensor cores, TMA, memory), device software (the CUDA programming/thread model), host software (the CUDA driver/runtime/library stack and tooling), and performance (the roofline vocabulary for diagnosing bottlenecks). A high-quality on-demand lookup resource for GPU terminology, not a synthesis — keep it bookmarked as the reference an agent or human consults when a term in any other note in this folder needs grounding.
source: https://modal.com/gpu-glossary
topic: gpu-hardware, cuda, gpu-glossary, reference, performance
type: reference
---

Source: **GPU Glossary** by [Modal](https://modal.com) — "A glossary of terms related to GPUs." Read it at [modal.com/gpu-glossary](https://modal.com/gpu-glossary). It is an open, hyperlinked reference (the terminal-styled site cross-links every entry to the others it depends on), so it reads either top-to-bottom as a short course or term-by-term as a lookup.

> [!tip] Why this note exists — a signpost, not a synthesis
> This is a **reference resource worth keeping bookmarked**, not a teardown. When a note in this folder — or an agent working in it — hits a GPU term it can't ground (what *is* a warp scheduler? compute- vs memory-bound? arithmetic intensity? what does `nvidia-smi` actually talk to?), this glossary is the place to look it up. It is concise, accurate, and well-organized by layer, and each entry links to the related ones, so you can poke around a neighborhood of concepts rather than reading a wall of text. The map below is just so you (or an agent) know **what's in there and when to reach for it** — go to the source for the actual definitions.

## Key Takeaways

- **It's a layered map of the whole GPU stack, not a flat term dump.** The glossary sorts ~80 terms into four sections that mirror how you actually descend into a GPU: **Device Hardware** (the silicon) → **Device Software** (the CUDA execution model that runs on it) → **Host Software** (the CPU-side drivers, runtime, and libraries that drive it) → **Performance** (the vocabulary for reasoning about whether you're using any of it well). That ordering is itself the lesson: it tells you which layer a given term lives at.

- **It is the natural lookup companion to [[MLC's Modern GPU Programming for MLSys is a Blackwell-era book that builds from the GPU execution model through TMA, tensor cores, and TMEM to a SOTA GEMM and Flash Attention 4 in the TIRx Python DSL|MLC's Modern GPU Programming for MLSys]].** Where the MLC book *teaches you to write* Blackwell-era kernels (TMA, `tcgen05` tensor cores, TMEM, warpgroups, clusters) as a progressive course, this glossary *defines those same terms* in a sentence or two each. Read the book to learn; consult the glossary to look one term back up. Both cover the same hardware layer beneath everything else in this folder.

- **The Performance section is the most reusable for an inference reader.** Terms like roofline model, compute-bound vs memory-bound, arithmetic intensity, occupancy, latency hiding, memory coalescing, and bank conflicts are exactly the language the deep-dives in this folder lean on — e.g. the roofline reasoning in [[Modal argues speculative decoding is the only inference optimization that matters, and custom DFlash speculators turn acceptance length into 2-3x speedups|Modal's speculative-decoding case]] and the bottleneck-layer framing in [[Ashutosh Maheshwari's sub-second LLM study list catalogs sixteen inference optimizations from KV-caching and speculative decoding to tensor parallelism and memory offloading|Maheshwari's sub-second study list]]. If a serving note says "this kernel is memory-bound," this is where that phrase is defined precisely.

- **The Host Software section demystifies the CUDA toolchain itself.** It maps the often-confusing pile of CUDA artifacts — driver vs runtime API, `nvidia.ko`, `libcuda.so`, `libcudart.so`, `nvcc`, NVRTC, NVML / `nvidia-smi`, CUDA Graphs, CUPTI, Nsight — plus the kernel libraries (cuBLAS, cuDNN, CUTLASS, CuTe, CuTe DSL). Useful whenever a serving or profiling note name-drops one of these and you need to know which layer it belongs to.

## What's in it — the four sections

A rough map so you know the territory before you go look something up. (Counts are approximate; the source is the authority.)

| Section | What it covers | Representative terms |
|---|---|---|
| **Device Hardware** (~17) | The physical GPU: the compute units inside a streaming multiprocessor and the on-chip/off-chip memory hierarchy | CUDA (device architecture), Streaming Multiprocessor (SM), CUDA Core, Tensor Core, Tensor Memory Accelerator (TMA), Warp Scheduler, SFU, LSU, Register File, L1 Data Cache, Tensor Memory (TMEM), GPU RAM, TPC, GPC |
| **Device Software** (~19) | The CUDA programming and execution model that runs on that hardware | CUDA (programming model), SASS, PTX, Compute Capability, Thread, Warp, Warpgroup, Cooperative Thread Array, Kernel, Thread Block (+ Grid, Hierarchy), Memory Hierarchy, Registers, Shared Memory, Global Memory, CUDA Tile Programming Model |
| **Host Software** (~22) | The CPU-side stack that compiles, launches, and manages GPU work, plus the kernel libraries | CUDA (software platform), CUDA C++, NVIDIA GPU Drivers, `nvidia.ko`, CUDA Driver API / `libcuda.so`, CUDA Runtime API / `libcudart.so`, NVML / `libnvml.so` / `nvidia-smi`, CUDA Graphs, `nvcc`, NVRTC, CUPTI, Nsight Systems, CUDA Binary Utilities, cuBLAS, cuDNN, CUTLASS, CuTe, CuTe DSL |
| **Performance** (~23) | The vocabulary for diagnosing and reasoning about GPU efficiency | Performance Bottleneck, Roofline Model, Compute-bound, Memory-bound, Arithmetic Intensity, Overhead, Little's Law, Memory/Arithmetic Bandwidth, Latency Hiding, Occupancy, Pipe Utilization, Peak Rate, Issue Efficiency, SM Utilization, Warp Divergence, Scoreboard Stall, Branch Efficiency, Memory Coalescing, Bank Conflict, Register Pressure |

Plus a [README](https://modal.com/gpu-glossary/readme) (intro + how to read it) and a [Contributors](https://modal.com/gpu-glossary/contributors) page.

## When to reach for it

- You hit a GPU term in another note and want a precise, one-paragraph definition without leaving the conceptual neighborhood.
- You're reasoning about an inference bottleneck and need the exact meaning of compute-bound / memory-bound / arithmetic intensity / occupancy.
- You're untangling the CUDA host-side stack (which `.so` is which, runtime vs driver API, what `nvidia-smi` reports).
- You want a fast orientation to Blackwell-era hardware terms (TMA, tensor cores, TMEM) before — or alongside — the deeper [[MLC's Modern GPU Programming for MLSys is a Blackwell-era book that builds from the GPU execution model through TMA, tensor cores, and TMEM to a SOTA GEMM and Flash Attention 4 in the TIRx Python DSL|MLC GPU programming book]].

## External Resources

- [GPU Glossary home](https://modal.com/gpu-glossary) — the glossary itself.
- [README](https://modal.com/gpu-glossary/readme) — orientation and reading guidance.
- [Modal](https://modal.com) — the serverless-GPU platform that publishes it (the same source as [[Modal argues speculative decoding is the only inference optimization that matters, and custom DFlash speculators turn acceptance length into 2-3x speedups|Modal's speculative-decoding writeup]]).
