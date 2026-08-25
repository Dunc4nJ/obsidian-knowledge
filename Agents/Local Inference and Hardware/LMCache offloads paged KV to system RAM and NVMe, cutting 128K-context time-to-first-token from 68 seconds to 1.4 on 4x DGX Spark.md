---
created: 2026-08-26
description: 0xSero on using LMCache to store paged KV cache outside the GPU — in system memory and NVMe — so long prompts reload their KV instead of recomputing it. His benchmark (DeepSeek-V4-Flash on 4x DGX Spark, same prompt and model, only difference being recompute vs reload) cuts time-to-first-token at 128K context from 68.1s to 1.4s, and at 64K from 38.3s to 0.69s. The motivating pain: with a large system prompt you reprocess ~24k tokens on every prompt, which can take a minute.
source: https://x.com/0xSero/status/2092373910054470016
author: "@0xSero"
type: post
tags: [local-inference, hardware, kv-cache, lmcache, ttft, prefill, nvme, offloading, dgx-spark, deepseek]
---

## Key Takeaways

- **The technique: page KV cache out to system RAM and NVMe so long contexts are *reloaded*, not *recomputed*.** [LMCache](https://github.com/lmcache/lmcache) stores paged KV outside the GPU for efficient retrieval — spending cheap, plentiful host memory and disk to buy back the expensive prefill compute you'd otherwise repeat on every request. It's the local-hardware instance of the KV-cache tiering that [[Red Hat frames prefill-decode disaggregation, KV-cache tiering, and speculative decoding as the three llm-d deployment levers for distributed AI inference|Red Hat frames as a cluster-wide levers]] (HBM → DRAM → NVMe), built on the same paged-KV abstraction as [[paged attention applies OS virtual memory paging to KV cache and unlocks 2-4x LLM serving throughput|PagedAttention]].

- **The numbers are the point: 68.1s → 1.4s TTFT at 128K context.** Same prompt, same model (DeepSeek-V4-Flash on 4x DGX Spark), the only variable being whether the document's KV is recomputed or reloaded. Across the sweep: 8K 5.2s → 0.09s, 16K 17.3s → 0.17s, 32K 15.6s → 0.34s, 64K 38.3s → 0.69s, 128K **68.1s → 1.4s**. Note the shapes — recompute climbs steeply and unevenly with context length, while reload stays near-flat and roughly linear at ~0.01s per 1K tokens. Long-context local inference is dominated by prefill, and this removes it.

- **Why it matters for agent workloads specifically: the fixed prefix tax.** 0xSero's framing — "every time you prompt with OMP you'll have to process 24k tokens, that could take 1m" — is the local-hardware version of the problem [[auto-caching with Claude eliminates manual breakpoint management for multi-turn agents|prompt caching]] solves for API users: agents re-send a large, stable prefix (system prompt, skills, loaded documents) on every turn, and without caching you pay full prefill each time. Owning the box doesn't exempt you from that tax; it just means you have to install the cache yourself.

- **Where it sits among KV strategies: keep everything, move it — rather than shrink it.** LMCache is the *offload* answer, complementary to the *compress* answer of [[Baseten's STILL perceiver amortizes KV cache compaction into one forward pass, compressing 8x at 85%+ factual retention|learned KV compaction]] and the *architectural* answer of [[From GPT-2 to Kimi K3 - a visual worklog on how attention architecture evolved to fix the KV cache with linear attention, DeltaNet, gating, and hybrid retrieval|constant-state attention]]. For a homelab it's the most attractive of the three: no quality loss, no model change, just spare RAM and an SSD — which pairs naturally with the [[EXL3 3-bit plus an 18.5 percent expert prune runs DeepSeek-V4-Flash 284B at 47 tok-s on 4.7K of hardware|quantize-and-prune-to-fit]] approach where VRAM is already the binding constraint.

*Time to first token with and without LMCache — DeepSeek-V4-Flash on 4x DGX Spark, same prompt and model, recompute vs reload:*
![[0xsero-lmcache-001.jpg]]

## External Resources

- Original post: [@0xSero, 2026-08-25](https://x.com/0xSero/status/2092373910054470016)
- [LMCache (GitHub)](https://github.com/lmcache/lmcache) — KV cache layer storing paged KV in CPU RAM / local disk / remote storage for vLLM and other engines

## Original Content

> [!quote]- Full post (@0xSero, 2026-08-25)
> If you have system memory/nvme you can significantly speed up your local inference with https://t.co/utkjfYNOS6 
>
> You can store paged cache outside of the GPU, for efficient retrieval. 
>
> Every time you prompt with OMP you'll have to process 24k tokens, that could take 1m https://t.co/Z2cGMjdVCu
> *(TTFT chart — embedded above)*
