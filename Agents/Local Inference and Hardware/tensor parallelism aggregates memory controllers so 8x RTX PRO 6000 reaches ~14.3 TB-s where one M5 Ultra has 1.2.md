---
created: 2026-08-28
description: Ahmad Osman's counterpoint to M5 Ultra hype — the Mac's 1.2 TB/s is impressive for one box, but each RTX PRO 6000 has 1.792 TB/s and tensor parallelism across 2^n GPUs shards the model so every GPU's memory controller works in parallel: 8x RTX PRO 6000 gives ~14.3 TB/s of aggregate local bandwidth (theoretical, before TP communication and PCIe overhead). The framing that matters: capacity is not everything — utilizing that capacity matters, especially for parallel agentic workflows and sub-agents.
source: https://x.com/TheAhmadOsman/status/2093428313884921991
author: "@TheAhmadOsman (Ahmad)"
type: post
tags: [local-inference, hardware, tensor-parallelism, memory-bandwidth, rtx-pro-6000, mac-studio, multi-gpu, agentic-workloads]
---

## Key Takeaways

> [!warning]- Fact-check (2026-09-01, home-lab research)
> The "vault's own datapoint" below — *Contra Collective: 70B Q4 on M5 Ultra 21.1 tok/s single-die, 27.3 with TP=2* — is **not real**: the numbers do not appear in the cited articles, which predate the M5 Ultra by four months. The sublinear-TP point still stands on better data: **PCIe TP=2 measures +38–47%** on 2× RTX 4090 (DatabaseMart, vLLM), NVLink TP=2 1.7–1.9×, and TP=4 on RTX PRO 6000 reaches cost-parity with H100 while **TP=8 loses ~3×** (CloudRift). On Macs, 4× M3 Ultra over TB5 RDMA gives decode **1.5–1.65×** for 4× the hardware (exo/MLX). So 14.3 TB/s remains a theoretical upper bound; real 8-card aggregation is far lower, and the honest planning multiplier for TP=2 is ~1.4–1.5×.
> Evidence: `/data/projects/hardware/research/hw-nvidia.md` §2.10, `hw-apple.md` §2.3, §2.5.

- **The correction: a single fast bus loses to many buses working in parallel.** One M5 Ultra Mac Studio's **1.2 TB/s** is a genuine class change among single boxes — but each **RTX PRO 6000 has 1.792 TB/s on its own**, and tensor parallelism across 2^n GPUs shards the model so all memory controllers read concurrently. Eight cards → **~14.3 TB/s aggregate local bandwidth**, roughly 12x a single Ultra. Osman flags the caveat himself: full end-to-end 14.3 is theoretical, reduced by TP communication and PCIe overhead.

- **The distinction that resolves an apparent contradiction in this folder: tensor parallelism ≠ pipeline parallelism.** [[at 15-20K with 512GB the real gap is bandwidth not compute - Mac Studio M5 Ultra vs 4x DGX Spark vs 4x Ryzen AI Halo|The matched-price comparison]] found that four linked boxes "still generate at one box's speed" — that's **pipeline** parallelism, where the model is cut into sequential stages and tokens pass through boxes one after another, so only one stage's memory is being read at a time. **Tensor** parallelism shards *each layer* across GPUs, so every device reads its slice of the same weights simultaneously and bandwidth genuinely adds. Same word ("parallelism"), opposite bandwidth outcomes — and the deciding factor is interconnect: sharding a layer requires an all-reduce every layer, which needs NVLink/fast PCIe inside a chassis and dies over 10GbE between boxes.

- **But measure the real multiplier, not the theoretical one — TP scaling is sublinear.** The vault's own datapoint: [[buy the RAM that holds the model - a SKU-by-SKU M5 Mac guide with the CUDA tax and separate decode-prefill predictions|Contra Collective measured 70B Q4 on M5 Ultra at 21.1 tok/s single-die and 27.3 with TP=2]] — a **~29% gain from doubling the devices**, not 100%, because per-layer communication eats the rest. Expect the 8x figure to land well under 14.3 TB/s effective; the direction of the argument is right, the magnitude is an upper bound. (This is also why the same guide's separate decode/prefill treatment matters: TP overhead hits decode's per-token all-reduce far harder than prefill's batched compute.)

- **The strategic point is about workload shape, not peak specs: "capacity is not everything — utilizing that capacity matters."** Osman ties it specifically to **parallel agentic workflows and sub-agents** — the regime where you're running many concurrent requests rather than one interactive stream. That's the same variable that decides everything else in this folder: [[a 100K DGX Station pays back in 19 months at 30 percent duty - but only if you can keep 64 requests concurrent|the DGX Station's payback math collapses without 64-way concurrency]], and [[buy 2x 256GB Mac Studios instead of one 512GB - two boxes give 2x 1.2 TB-s parallel instances and can still be linked, but a 512GB box can never be split|two 256GB Studios beat one 512GB]] precisely because two whole models running concurrently beat one model split across a slow link. Multi-GPU TP is the third answer to the same question — and the honest tradeoffs against the Mac remain cost, power, noise, and the [[buy the RAM that holds the model - a SKU-by-SKU M5 Mac guide with the CUDA tax and separate decode-prefill predictions|inverse of the CUDA tax]]: this hardware is what the frontier kernels are written for.

## External Resources

- Original post: [@TheAhmadOsman, 2026-08-28](https://x.com/TheAhmadOsman/status/2093428313884921991)
- Hardware: NVIDIA RTX PRO 6000 (1.792 TB/s memory bandwidth per card) · Apple M5 Ultra Mac Studio (1.2 TB/s unified)

## Original Content

> [!quote]- Full post (@TheAhmadOsman, 2026-08-28)
> M5 Ultra Studio vs RTX PRO 6000
>
> 1.2 TB/s in a single M5 Ultra Mac Studio is impressive, however, it is still NOWHERE near 2x/4x/8x RTX PRO 6000 setups
>
> - Each RTX PRO 6000 has 1.792 TB/s of memory bandwidth
> - Tensor Parallelism across 2^n GPUs shards the model
>
> So, for 8x RTX PRO 6000s, we have 8 memory controllers processing things in parallel, which is about ~14.3 TB/s* of aggregate local memory bandwidth
>
> Capacity is not everything
> > Utilizing that capacity matters
> > Especially for parallel agentic workflows and sub-agents
>
> *Full 14.3 TB/s end to end is theoretical due to TP communication and PCIe overhead
