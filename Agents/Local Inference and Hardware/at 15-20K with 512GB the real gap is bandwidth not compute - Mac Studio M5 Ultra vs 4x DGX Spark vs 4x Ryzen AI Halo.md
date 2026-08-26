---
created: 2026-08-26
description: Tom Greenwald compares three ~$15-20K / 512GB local-inference builds — Mac Studio M5 Ultra (~$15K, ~135 TFLOPS, 1.2 TB/s, ~270W), 4x DGX Spark ($18.8K, ~300 TFLOPS, 273 GB/s, ~960W), and 4x AMD Ryzen AI Halo ($16K, ~100 TFLOPS, 256 GB/s, ~560W) — across prompt-processing compute, token-generation bandwidth, and power. The conclusion: the real gap is bandwidth, and because multi-box setups split the model and pass tokens through sequentially, four boxes still generate at one box's speed.
source: https://x.com/tomgreenwald/status/2092362375538327762
author: "@tomgreenwald (Tom Greenwald)"
type: post
tags: [local-inference, hardware, memory-bandwidth, mac-studio, dgx-spark, amd-ryzen-ai, interconnect, buying-guide, comparison]
---

## Key Takeaways

- **Same price, same memory, wildly different machines — and the deciding spec is bandwidth.** All three configurations land at ~$15-20K with **512GB** of memory: Mac Studio M5 Ultra (~$15,000, ~135 TFLOPS, **1.2 TB/s**, ~270W), 4x DGX Spark ($18,800, ~300 TFLOPS, **273 GB/s**, ~960W), 4x AMD Ryzen AI Halo ($16,000, ~100 TFLOPS, **256 GB/s**, ~560W). The Mac has **~4.4x the memory bandwidth** of either cluster while drawing less power than a gaming PC. Since [[Step 01 - Decode is memory-bandwidth-bound (the roofline)|decode is memory-bandwidth-bound]], that ratio *is* the token-generation ratio — "the Studio will feel noticeably faster."

- **The non-obvious trap: adding boxes adds memory and compute, but not generation speed.** With a model split across four boxes, "tokens pass through them in sequence, so 4 boxes still generate at 1 box's speed" — pipeline parallelism across machines buys capacity, not throughput per request. This is why the 273 GB/s figure for 4x Spark is *per box* and doesn't compound the way the 512GB pooled memory does. Anyone sizing a multi-box cluster from aggregate specs will be disappointed by single-stream latency; the concurrency caveat in [[a 100K DGX Station pays back in 19 months at 30 percent duty - but only if you can keep 64 requests concurrent|the DGX Station economics]] is the same lesson from the utilization side.

- **Interconnect quality decides whether clustering helps at all — 200GbE works, 10GbE doesn't.** Sparks link over **200GbE**, "fast enough to combine their compute," making them the fastest of the three on prompt processing (helped further by native **FP4** for quantized models). Halos link over **10GbE**, "too slow to share work properly," so four of them end up near the single-chip Mac and somewhat worse. The Mac's advantage is structural rather than fast: one chip, so all compute is always usable, with no interconnect to bottleneck — quick on normal prompts, slower on long ones where the Sparks' combined compute pulls ahead.

- **Power is a real constraint at this tier, not a footnote.** ~270W (Mac, silent) vs ~960W (Sparks, "nearly maxes out a wall circuit, will be hot") vs ~560W (Halos, "somewhat hot"). At 4x Spark you are making a circuit-and-cooling decision, not just a purchase — and the [[a 100K DGX Station pays back in 19 months at 30 percent duty - but only if you can keep 64 requests concurrent|ownership math]] that excludes power gets meaningfully worse when a box pulls a kilowatt continuously.

- **The forward-looking take: next-gen won't change the ranking unless bandwidth does.** "Spark 2 is rumored soon, but it won't matter unless the bandwidth goes way up. Same for AMD, plus better interconnect speeds." The buying rule that falls out: pick by *workload shape* — long-prompt/prompt-processing-heavy work favors the Spark cluster's combined compute and FP4; interactive single-stream generation favors the Mac's single fast bus. And regardless of box, prefill cost is separately attackable with [[LMCache offloads paged KV to system RAM and NVMe, cutting 128K-context time-to-first-token from 68 seconds to 1.4 on 4x DGX Spark|KV offloading]], while VRAM pressure is attackable with [[EXL3 3-bit plus an 18.5 percent expert prune runs DeepSeek-V4-Flash 284B at 47 tok-s on 4.7K of hardware|quantization plus expert pruning]]. Setup reality for the Spark path is in [[two DGX Sparks run a 304B model at 40 TPS - install Tailscale first and every other non-obvious gotcha]].

*Spec comparison at matched price and memory — the bandwidth column is the story:*
![[tomgreenwald-hw-compare-001.jpg]]

## External Resources

- Original post: [@tomgreenwald, 2026-08-25](https://x.com/tomgreenwald/status/2092362375538327762) — comparison table by [magnitude.dev](https://magnitude.dev)

## Original Content

> [!quote]- Full post (@tomgreenwald, 2026-08-25)
> We compared the M5 Ultra Mac Studio 512GB with 4x DGX Spark and 4x AMD Ryzen AI Halo
>
> The prices are relatively the same ($15-20k), but the trade-offs are noticeable
>
> Compute (prompt processing speed)
> - Mac: one chip, all the compute is always usable. Quick on normal prompts, will feel slower on long ones
> - Sparks: boxes link over 200GbE, which is fast enough to combine their compute. Fastest of the three, and native FP4 speeds up quantized models even more
> - Halos: boxes link over 10GbE, too slow to share work properly. Ends up close to the Mac but somewhat worse
>
> Bandwidth (token generation speed)
> - Mac: 512GB on a single bus, faster than a 4090, ~4x the tokens/sec of Spark or Halos
> - Sparks: the model splits across boxes and tokens pass through them in sequence, so 4 boxes still generate at 1 box's speed
> - Halos: same ceiling as Spark, same reason
>
> Power
> - Mac: less than a gaming PC, silent
> - Sparks: nearly maxes out a wall circuit, will be hot
> - Halos: about half the Sparks, but somewhat hot
>
> The real gap is bandwidth. The Studio will feel noticeably faster. Spark 2 is rumored soon, but it won't matter unless the bandwidth goes way up. Same for AMD, plus better interconnect speeds
> *(spec table — embedded above)*
