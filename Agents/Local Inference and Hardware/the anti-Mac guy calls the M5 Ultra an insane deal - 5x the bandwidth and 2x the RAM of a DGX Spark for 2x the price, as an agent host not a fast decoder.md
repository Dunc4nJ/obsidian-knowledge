---
created: 2026-09-01
description: On M5 Ultra launch day, Roy (@usr_bin_roygbiv) — who had spent April to August telling everyone "do not buy a Mac (for LLM hosting) or DGX" — posted "m5 ultra is an insane deal if you can get one." His arithmetic, in replies elsewhere the same day, is the spec sheet against a DGX Spark: ~5x the memory bandwidth (1.2 TB/s vs 273 GB/s) and double the RAM (256 vs 128 GB) for 2x the price ($9,499 vs $4,699); his use case is explicitly not decode speed but hosting many agents ("you aren't going to be able to get the ram and disk size and speeds necessary to run all those agents for that price anywhere else"). The next day: "512 Mac Studio will do the same thing [as a DGX Station], albeit slower, for a tenth the cost." No M5 Ultra had been measured when any of this was written.
source: https://x.com/usr_bin_roygbiv/status/2092263371672289773
author: "@usr_bin_roygbiv (Roy)"
type: post
tags: [local-inference, hardware, mac-studio, m5-ultra, apple-silicon, dgx-spark, memory-bandwidth, capacity, buying-guide, opinion]
---

## Key Takeaways

> [!warning]- Dated context — posted 2026-08-25 (M5 Ultra announcement day), captured 2026-09-01
> The M5 Ultra Mac Studio was announced 2026-08-25 (quad-die UltraFusion, 1.2 TB/s, 96/256 GB at $5,499/$9,499; 512 GB "late October", unpriced) and ships 2026-09-22 — as of capture **zero measured LLM numbers exist for it**; llama.cpp's Apple table has the row blank. GLM-5.3-Flash (2026-08-26, ~200 GB at 4-bit) landed the next day and is the model a 256 GB box is now sized against. The DGX Spark Roy is implicitly comparing to has been $4,699 since the Feb 2026 price rise; RTX PRO 6000 was $13–16K. Roy's prior Mac posts (2026-04-16 "$8,500 depreciating pile of poop", 2026-04-20 "don't fall for the mac studio meme", 2026-06-26 "daily reminder: do not buy a mac (for llm hosting) or dgx") were all written about the M3 Ultra / M5 Max generation. Evidence: `/data/projects/hardware/research/hw-apple.md` §2.1, §2.4, §2.8; `00-synthesis.md` §4A–C; `roygbiv-profile.md`.

- **What changed his mind is the price of capacity, not a speed number — and he never claims speed.** The 256 GB M5 Ultra at $9,499 is $37/GB of 1.2 TB/s memory; a DGX Spark is $37/GB of 273 GB/s memory; an RTX PRO 6000 is ~$156/GB of 1.8 TB/s. On the research's capacity-per-dollar axis the Mac leads the CUDA card by ~2.5x, and against the Spark it is the same $/GB at 4.4x the bandwidth ("5x" is his rounding). That is the whole content of "insane deal": it is [[M5 Ultra 256GB scores 3.26x the DGX Spark on memory GB times bandwidth per dollar - the Apple-beats-NVIDIA case rests on a metric with no compute term|the memory-value chart's]] conclusion reached by someone who spent four months saying the metric was the wrong one. Verifiable: the specs and prices. Not verifiable yet: how much of 1.2 TB/s a quad-die Ultra delivers on a sparse MoE — measured M3 Ultra utilization on big MoE is 28–45%, and M5 Ultra has more die hops, not fewer.

- **His stated use case is agent hosting, which is a RAM-and-disk problem, not a tokens-per-second problem.** "Even ignoring inference you aren't going to be able to get the ram and disk size and speeds necessary to run all those agents for that price anywhere else any time soon." Roy runs dozens of concurrent agent sessions on subscriptions from a k8s cluster of used EPYC/DDR4 boxes; a 256 GB Mac is, to him, a quiet, 150–250 W node with 256 GB of fast memory and Apple-priced NVMe — a role the home-lab research does not price the Mac for at all (its candidates A–C treat the Mac purely as an inference box). For an "always-on capacity plus a CUDA compute box" shape, this reading strengthens the Mac half for reasons unrelated to MLX.

- **Read the sarcasm correctly: "No the m5 ultra SUCKS don't buy it. DGX spark is much better" (08-26) is mockery of a Spark booster, not a reversal.** His straight statements that week: "512 Mac Studio will do the same thing [as a DGX Station], albeit slower, for a tenth the cost" (08-26); "if you want quality buy a studio, also 1/10th the price" (08-27); "mac studio is good" (08-29) — and, the same week, "buy 6000s in the next 48 hours" (09-01). Taken together his September position is a two-unit shape — Apple capacity plus a Blackwell card for speed — which is the hybrid the research's shortlist converged on. The 512 GB remark also implies the flagship seat: GLM-5.3 at 4-bit (~460 GB) fits nothing else under $40K, which is [[buy 2x 256GB Mac Studios instead of one 512GB - two boxes give 2x 1.2 TB-s parallel instances and can still be linked, but a 512GB box can never be split|the one-512-vs-two-256 question]].

- **The replies are the market reacting: "glad I didn't buy a 6000 pro at this point," "Sparks got bandwidth mogged," "waiting comfy with my m4 128 until [the 512 hits in] Oct."** For capacity buyers the M5 Ultra changed the calculus overnight; for speed buyers nothing changed (the PRO 6000 still has 1.5x the bandwidth, native NVFP4, the drafters, and 5–10x the prefill). Roy's own 06-26 answer to "why not mac or dgx" was [[matmuls are parallel memory reads - Roy's bandwidth ladder puts a 1K RTX 3090 at 936 GB-s above a 5K Mac or DGX Spark, but it has no capacity or prefill column|the bandwidth ladder]]; the M5 Ultra is the rung that ladder did not have, and it is the only rung under $30K with more than 96 GB behind it.

- **What to hold him to: the number he did not give.** Nothing here says what GLM-5.3-Flash decodes at on an M5 Ultra; the research's own estimate is 30–50 tok/s at 4-bit with prefill of ~1–1.5K tok/s (a cold 128K prompt in ~90–130 s) — usable for single-stream work, not for agent swarms, and 5–10x slower than his own 2x PRO 6000 on both axes. "Insane deal" is a capacity verdict; [[GLM-5.3-Flash FP8 really is 306GB and really fits in 512GB - but 60 t-s is 80-90 percent of the roofline on a machine that does not ship until October|the roofline note]] is where the speed claims for this machine get checked when units ship on 2026-09-22.

## Roy's related replies the same week (other conversations)

- 2026-08-25, to @napenforcer ([permalink](https://x.com/usr_bin_roygbiv/status/2092284022051238323)): **"5x the memory bandwidth and double the ram for 2x the price what"** — the comparison object is not named in the reply; the numbers match the DGX Spark (273 GB/s, 128 GB, $4,699) against the 256 GB M5 Ultra ($9,499).
- 2026-08-25, to @Tibbzzee ([permalink](https://x.com/usr_bin_roygbiv/status/2092325792109768724)): **"even ignoring inference you aren't going to be able to get the ram and disk size and speeds necessary to run all those agents for that price anywhere else any time soon"**
- 2026-08-26, to @lyc_aon ([permalink](https://x.com/usr_bin_roygbiv/status/2092641839962538010)): "Unironically, stuff like this makes the DGX station significantly more attractive" → **"That being said, 512 Mac Studio will do the same thing, albeit slower, for a tenth the cost."**
- 2026-08-26, to @TechMDAI ([permalink](https://x.com/usr_bin_roygbiv/status/2092452682938118419)): "No the m5 ultra SUCKS don't buy it. DGX spark is much better" — sarcasm; followed by "spark has what plants crave."
- 2026-08-27, to @TechMDAI ([permalink](https://x.com/usr_bin_roygbiv/status/2092778689733751168)): **"if you want quality buy a studio also 1/10th the price"**
- 2026-08-29 ([permalink](https://x.com/usr_bin_roygbiv/status/2093761649505186192)): **"mac studio is good"**

## External Resources

- Original post: [@usr_bin_roygbiv, 2026-08-25](https://x.com/usr_bin_roygbiv/status/2092263371672289773)
- Apple Mac Studio M5 Ultra configurator pricing and specs: `/data/projects/hardware/research/hw-apple.md` §3.3 (verified 2026-09-01)
- Research cross-reference: `/data/projects/hardware/research/roygbiv-profile.md` §2 (digest rows for 2026-08-25 to 08-29), `00-synthesis.md` §4A–C and §4G

## Original Content

> [!quote]- Full post (@usr_bin_roygbiv, 2026-08-25)
> m5 ultra is an insane deal if you can get one
>
> Engagement: 91 likes | 6 replies
> [Original post](https://x.com/usr_bin_roygbiv/status/2092263371672289773)

> [!quote]- Replies (2026-08-25; Roy did not reply in this thread)
> @lonnyk (lonny) — date: Tue Aug 25 15:19:30 +0000 2026 · url: https://x.com/lonnyk/status/2092270652623388899
> I no longer think apple is behind. Possibly one of the most perfectly timed and executed products of all time.
>
> @angelkestin (Angel Kestin) — date: Tue Aug 25 17:19:07 +0000 2026 · url: https://x.com/angelkestin/status/2092300753503129837
> "Just put 2 gpus in it"
>
> Nvidia SLI lives on in the mac studio
>
> @basedbillionair (Certified Cummer Boy) — date: Tue Aug 25 17:41:46 +0000 2026 · url: https://x.com/basedbillionair/status/2092306455982665736
> that's what i've taken it as
>
> @unl__cky (Unl_cky) — date: Tue Aug 25 18:01:51 +0000 2026 · url: https://x.com/unl__cky/status/2092311507866689992
> I'm salivating, but the 512 version hits Oct. Waiting comfy with my m4 128 until then.
>
> @nlevnaut (nlev) — date: Tue Aug 25 20:46:43 +0000 2026 · url: https://x.com/nlevnaut/status/2092353000383611268
> yeah honestly glad I didn't buy a 6000 pro at this point
>
> @vvsbks (vvsbks) — date: Tue Aug 25 22:07:05 +0000 2026 · url: https://x.com/vvsbks/status/2092373222134050982
> Sparks got bandwidth mogged
