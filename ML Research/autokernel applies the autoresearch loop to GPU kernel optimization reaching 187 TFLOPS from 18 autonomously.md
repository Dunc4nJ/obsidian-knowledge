---
created: 2026-03-11
description: Autokernel profiles a PyTorch model, identifies bottleneck kernels via Amdahl's law, writes Triton replacements, and runs overnight experiments in an edit-benchmark-keep/revert loop — the autoresearch pattern applied to kernel optimization.
source: https://x.com/Akashi203/status/2031533857082646769
type: synthesis
---

## Key Takeaways

Autokernel takes the [[autoresearch lets an AI agent run ML experiments autonomously overnight|autoresearch loop]] — the edit-one-file, benchmark, keep-or-revert cycle from Karpathy — and applies it specifically to GPU kernel optimization. The agent profiles a PyTorch model, uses Amdahl's law to decide which kernel to optimize next, writes a Triton replacement, validates through a 5-stage correctness pipeline, and either keeps or reverts. ~40 experiments/hour, ~320 overnight.

The **5-stage correctness check** is the critical design choice. As one commenter noted, they've seen agents optimize kernels to 3x faster while silently breaking numerical stability — passing unit tests but failing production. Autokernel gates every speedup claim behind correctness verification before it counts.

The **"edit one file" constraint** keeps the search space tractable. Most agent research fails because the agent can change too many things at once. By constraining mutations to a single kernel file per experiment, the feedback signal stays clean.

Covers 9 kernel types: matmul, flash attention, fused MLP, layernorm, RMSnorm, softmax, RoPE, cross entropy, and reduce. Ships with self-contained GPT-2, LLaMA, and BERT model definitions so you can start without the transformers library.

**Caveat:** The headline 18→187 TFLOPS numbers were questioned by Arun Demeure and others — the author acknowledged the benchmarks may have hallucinated and committed to re-running. The methodology (autoresearch loop + correctness gates) is sound even if specific numbers need verification.

This fits into the broader [[distributed research swarms close the feedback loop that single-agent autoresearch leaves open|distributed research swarm]] trend — autonomous experiment loops that run while you sleep.

## External Resources

- [autokernel](https://github.com/RightNow-AI/autokernel) — the open-source repo
- [KernelAgent](https://github.com/TuliMathieu/kernelagent) — related project mentioned in replies

## Original Content

> [!quote]- Source: @Akashi203 — Mar 11, 2026 · 1,428 likes · 146 retweets
>
> i open-sourced autokernel -- autoresearch for GPU kernels
>
> you give it any pytorch model. it profiles the model, finds the bottleneck kernels, writes triton replacements, and runs experiments overnight. edit one file, benchmark, keep or revert, repeat forever.
>
> same loop as @karpathy autoresearch, applied to kernel optimization
>
> 95 experiments. 18 TFLOPS → 187 TFLOPS. 1.31x vs cuBLAS. all autonomous
>
> 9 kernel types (matmul, flash attention, fused mlp, layernorm, rmsnorm, softmax, rope, cross entropy, reduce). amdahl's law decides what to optimize next. 5-stage correctness checks before any speedup counts
>
> the agent reads program.md (the "research org code"), edits the kernel file, runs the benchmark, and either keeps or reverts. ~40 experiments/hour. ~320 overnight
>
> ships with self-contained GPT-2, LLaMA, and BERT definitions so you don't need the transformers library to get started
>
> https://github.com/RightNow-AI/autokernel
>
> *Key image showing experiment progression and TFLOPS scaling:*
> ![[akashi203-646769-001.jpg]]
>
> ---
>
> **Notable replies:**
>
> @karpathy: "very cool, i look forward to trying!"
>
> @ArunDemeure: "This is cool! But I don't get the performance numbers, I think there might be a measurement error or you're CPU limited? Benchmarking is hard! Your graph shows a 4096x4096x4096 matmul climbing up to about 18.6% MFU… but cuBLAS can do way more than that if used correctly?!"
>
> @Akashi203 replying to Arun: "yes i think it hallucinated, i will run more benchmarks tonight and i will share the results tomorrow"
>
> @XunWallace: "This is exactly the kind of workflow that benefits from overnight agent loops. Profile → write Triton replacement → benchmark → keep/revert is a tight feedback cycle that doesn't need human judgment at each step. The 'edit one file' constraint is smart — keeps the search space tractable."
>
> @AiDevCraft: "The 5-stage correctness check is the gotcha nobody mentions. Watched an agent optimize a kernel to 3x faster but silently breaking numerical stability—passed unit tests, failed production."

[Original post](https://x.com/Akashi203/status/2031533857082646769)
