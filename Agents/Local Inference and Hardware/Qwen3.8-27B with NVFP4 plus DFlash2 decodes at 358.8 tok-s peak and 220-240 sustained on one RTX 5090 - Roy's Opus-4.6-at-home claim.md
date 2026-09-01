---
created: 2026-09-01
description: Roy's (@usr_bin_roygbiv) 653-like "we have opus 4.6 at 360 tps on a 5090" post is a screenshot reading "Base Qwen3.8-27B + DFlash2 — 358.8 output tok/s"; in the replies he gives the recipe (NVFP4 + DFlash2) and the honest number ("avg 220-240"), and a PRO 6000 owner reports ~265 with the same stack — so the speculative decoder, not the card, is what triples desk-tier decode. "Opus 4.6" is his quality equivalence, not a measurement; no context length or engine config was ever answered in-thread, but the same person's fully-documented localmaxxing run of GLM-5.3-Flash a week later (300.7 tok/s on 2x RTX PRO 6000, SGLang + DFlash2, NVFP4, 8K context) makes the recipe credible.
source: https://x.com/usr_bin_roygbiv/status/2091588364801626526
author: "@usr_bin_roygbiv (Roy)"
type: post
tags: [local-inference, hardware, rtx-5090, qwen, nvfp4, dflash2, speculative-decoding, decode, benchmarks, opinion]
---

## Key Takeaways

> [!warning]- Dated context — posted 2026-08-23, captured 2026-09-01
> Posted two days before the M5 Ultra (2026-08-25) and three days before GLM-5.3-Flash (2026-08-26); Qwen3.8-27B itself was days old (Qwen3.8, August 2026). The RTX 5090 was $4,300–5,000 street at the time (2.1x its $2K launch MSRP after the 2026 DRAM shortage) and NVIDIA had cancelled the RTX 50 Super refresh, so this is the card that exists, not a card that is about to be replaced. On 2026-08-31 Roy posted the follow-up run this note cross-checks against: GLM-5.3-Flash on his two RTX PRO 6000s at 300.7 tok/s end-to-end (373–391 steady-state), submitted to localmaxxing.com with the full SGLang command line. Evidence: `/data/projects/hardware/research/benchmarks-matrix.md` §4.1 (run `cmthnezqy023wp401px1q1f9z`), `hw-nvidia.md` §2.9, `roygbiv-profile.md` §2.1.

- **What was actually measured: a 27B dense model at ~4.5 effective bits with a block-diffusion drafter on one 1.8 TB/s card, 358.8 tok/s best case, 220–240 tok/s average.** The screenshot line is unambiguous ("Base Qwen3.8-27B + DFlash2: 358.8 output tok/s"); the sustained figure comes from Roy's own reply to "360 is peak though": "avg 220-240." Without a drafter the roofline for this model is ~1,792 GB/s x ~0.6 utilization ÷ ~16 GB per token ≈ 65–110 tok/s — the 100–160 tok/s band the home-lab research uses for a 27B on a 5090 — so DFlash2 is worth roughly 2–3x here, in line with the 1.5–3x band [[Step 01 - Decode is memory-bandwidth-bound (the roofline)|the roofline course]] gives for speculative decoding at batch 1. Verifiable: the model, the drafter, the card, the peak. Not verifiable from the thread: context length, engine, quant file, prompt — five people asked, none were answered (his April setup on the same card was "nvfp4 with dflash and 50k context").

- **The card is not the lever; the RTX PRO 6000 in the same thread gets ~265 tok/s with the same stack.** @Conceivable_AI: "'only' getting ~265 on rtx pro 6k (simple code generation output, no tool calls, sglang + nvfp4 + dflash2)"; @loktar00 was "happy with my 161 t/s at BF16" before this. The PRO 6000 has the same 1,792 GB/s as the 5090, so for a model that fits in 32 GB it buys nothing on single-stream speed — it buys 96 GB (context, concurrency, and the next model class), which is exactly the split the research draws between the desk tier and the Flash tier. Roy's reply to a 2x 3080 + 6800 XT owner names the two things that do matter: "no native nvfp4 and half the memory bandwidth."

- **"Opus 4.6" is a quality equivalence Roy asserts, not something the post shows — separate it from the speed number.** Asked "Is it actually Opus 4.6 equivalent?" he answers "better"; his tier lists put Qwen3.8-27B as an honorable mention behind the Flash-class open models, and Artificial Analysis scores Qwen3.8-27B at 52 against Opus 4.8's 57 (v4.1.1). The speed claim is MEASURED\*; the intelligence claim is OPINION from someone who runs his own Terminal Bench 2.1 leaderboard (roybench.org) but did not post a row for this configuration.

- **Why it is credible anyway: the same recipe, fully documented, a week later.** Roy's 2026-08-31 localmaxxing submission — GLM-5.3-Flash, 2x RTX PRO 6000 Blackwell, `sglang --tp-size 2 --quantization modelopt_fp4 --attention-backend dsa --speculative-algorithm DFLASH --speculative-num-draft-tokens 8 --speculative-draft-window-size 2048 --max-total-tokens 65536`, 182.2 GB VRAM, 624.5 W measured, 300.7 tok/s end-to-end and "373–391 tok/s steady-state at acceptance ceiling" — is the best measured GLM-5.3-Flash number in the research dataset, and it is his host (a Ryzen 9 7950X with 128 GB, not a Threadripper). The 5090 post is the desk-tier version of the same NVFP4 + DFlash2 story; [[GLM-5.3-Flash FP8 really is 306GB and really fits in 512GB - but 60 t-s is 80-90 percent of the roofline on a machine that does not ship until October|the Mac-side roofline note]] is what the same model class looks like without a CUDA drafter.

- **For a buying decision: if the 27B tier is the workload, one 5090 with a drafter already exceeds reading speed by 10x, and the money saved versus a PRO 6000 (~$10K) is better spent on the capacity tier.** The drafter is model-specific (DFlash2 heads are published per target model by incoai, under a non-commercial license) and acceptance can drop with quantization — in the GLM-5.3 thread a week later, an 8x PRO 6000 owner reported "acceptance lower with dflash2 vs 5.2 and MTP … quant may have pushed logit distribution" — so treat 2–3x as the ceiling for a well-matched pair and 1.5x as the floor. [[matmuls are parallel memory reads - Roy's bandwidth ladder puts a 1K RTX 3090 at 936 GB-s above a 5K Mac or DGX Spark, but it has no capacity or prefill column|His bandwidth ladder]] is the spec side of this; this post is what the top consumer rung does with the idle compute.

## Roy's replies to commenters

- To "wtf magic quant is that? I was happy with my 161 t/s at BF16": **"nvfp4 + dflash2."**
- To "360 is peak though, not sustained in non-toy scenarios": **"avg 220-240."**
- To "Is it actually Opus 4.6 equivalent?": **"better."**
- To "I have 2x3080s + a 6800xt, will this work somehow?": **"no native nvfp4 and half the memory bandwidth."**
- Unanswered: "Context length?" (x3), "Share specs. What LM server, config, quant etc?", "Share the cookbook."

## External Resources

- Original post: [@usr_bin_roygbiv, 2026-08-23](https://x.com/usr_bin_roygbiv/status/2091588364801626526)
- [localmaxxing run cmthnezqy023wp401px1q1f9z](https://www.localmaxxing.com/en/runs/cmthnezqy023wp401px1q1f9z) — Roy's documented 2026-08-31 GLM-5.3-Flash run on 2x RTX PRO 6000 (SGLang + DFlash2, NVFP4, 300.7 tok/s), the methodology this note borrows
- [incoai/GLM-5.3-Flash-DFlash2](https://huggingface.co/incoai/GLM-5.3-Flash-DFlash2) — the DFlash2 drafter family (CC BY-NC-ND 4.0); the Qwen3.8-27B drafter used here is the same method
- [roybench.org](https://roybench.org/) — Roy's Terminal Bench 2.1 Full88 leaderboard (149 configurations across 88 tasks as of 2026-09-01)
- Research cross-reference: `/data/projects/hardware/research/roygbiv-profile.md` §2.1, `benchmarks-matrix.md` §4.1, `fundamentals-software.md` §1.9

## Original Content

> [!quote]- Full post (@usr_bin_roygbiv, 2026-08-23)
> we have opus 4.6 at 360 tps on a 5090 and you're blackpilling https://t.co/aiBQBBGDR7
>
> *Roy's screenshot — the line that carries the whole post: "Best so far: — Base Qwen3.8-27B + DFlash2: 358.8 output tok/s":*
> ![[usr_bin_roygbiv-626526-001.png]]
>
> Engagement: 653 likes | 25 replies
> [Original post](https://x.com/usr_bin_roygbiv/status/2091588364801626526)

> [!quote]- Replies and Roy's answers (2026-08-23 to 2026-08-24)
> @loktar00 (Loktar) — date: Sun Aug 23 18:09:35 +0000 2026 · url: https://x.com/loktar00/status/2091588678644584539
> wtf magic quant is that? I was happy with my 161 t/s at BF16
> > @usr_bin_roygbiv (Roy) — date: Sun Aug 23 18:34:56 +0000 2026 · url: https://x.com/usr_bin_roygbiv/status/2091595059929985062
> > nvfp4 + dflash2
>
> @marcusquest (marcus) — date: Sun Aug 23 18:16:06 +0000 2026 · url: https://x.com/marcusquest/status/2091590320295202929
> I'm going to try running that on my 48gb ram m5 pro
> Is it really That good
>
> @ortegajorge (Jorge Ortega) — date: Sun Aug 23 18:31:55 +0000 2026 · url: https://x.com/ortegajorge/status/2091594301159448684
> my 9x t/s on a dula 3090 is crying
>
> @MrSage (Sage Byte) — date: Sun Aug 23 18:43:44 +0000 2026 · url: https://x.com/MrSage/status/2091597272081449266
> 350 is insane! my 5090 incoming cant wait to test this
>
> @Skiipy88 (Skiipy) — date: Sun Aug 23 18:47:22 +0000 2026 · url: https://x.com/Skiipy88/status/2091598186586476640
> 5090s to 10k
>
> @VolksVuur (Volks Vuur) — date: Sun Aug 23 19:08:18 +0000 2026 · url: https://x.com/VolksVuur/status/2091603456029028360
> Son is that a single 5090? I have 2x3080s + a 6800xt, will this work somehow?
> > @usr_bin_roygbiv (Roy) — date: Sun Aug 23 19:10:57 +0000 2026 · url: https://x.com/usr_bin_roygbiv/status/2091604123258855696
> > no native nvfp4 and half the memory bandwidth
>
> @napenforcer (scott) — date: Sun Aug 23 19:37:42 +0000 2026 · url: https://x.com/napenforcer/status/2091610853678481906
> what a time to be alive
>
> @carlcayton (Carl Cayton) — date: Sun Aug 23 20:02:37 +0000 2026 · url: https://x.com/carlcayton/status/2091617123613507865
> Share the cookbook to us plebs sir
>
> @BulbIndustry (Tulip Bulb Oligarch) — date: Sun Aug 23 20:29:00 +0000 2026 · url: https://x.com/BulbIndustry/status/2091623765142573116
> 360? I saw sglang getting 200+ on launch day, didn't realize things had already improved that fast though
>
> @skibidiblazor (tidux) — date: Sun Aug 23 20:38:34 +0000 2026 · url: https://x.com/skibidiblazor/status/2091626171486351661
> Is it actually Opus 4.6 equivalent?
> > @usr_bin_roygbiv (Roy) — date: Sun Aug 23 21:19:21 +0000 2026 · url: https://x.com/usr_bin_roygbiv/status/2091636433039626341
> > better
>
> @CK2084 (Chuck 208) — date: Sun Aug 23 20:40:55 +0000 2026 · url: https://x.com/CK2084/status/2091626763243938302
> Context limit 2 tokens
>
> @Conceivable_AI (Conceivable AI) — date: Sun Aug 23 20:41:14 +0000 2026 · url: https://x.com/Conceivable_AI/status/2091626844735058007
> "only" getting ~265 on rtx pro 6k...
> (simple code generation output, no tool calls, sglang + nvfp4 + dflash2) https://t.co/MGGeOnL84b
>
> @_thomasip (Thomas Ip) — date: Sun Aug 23 21:03:53 +0000 2026 · url: https://x.com/_thomasip/status/2091632544697524445
> 360 is peak though, not sustained in non-toy scenarios.
> > @usr_bin_roygbiv (Roy) — date: Sun Aug 23 21:09:02 +0000 2026 · url: https://x.com/usr_bin_roygbiv/status/2091633837377802335
> > avg 220-240
>
> @Osantobi (Obiwan Santobi) — date: Sun Aug 23 21:13:59 +0000 2026 · url: https://x.com/Osantobi/status/2091635082960208043
> Do benchmarks hold?
>
> @toddymyworld (toddy AI笔记) — date: Sun Aug 23 22:20:15 +0000 2026 · url: https://x.com/toddymyworld/status/2091651760930922887
> Context length?
>
> @alamin_ai_ (al'amin ai) — date: Sun Aug 23 23:16:29 +0000 2026 · url: https://x.com/alamin_ai_/status/2091665914378748053
> https://t.co/TyNQJr5pnm (quoting their own "more compute" GIF)
>
> @andripeetso (Andri) — date: Mon Aug 24 00:43:01 +0000 2026 · url: https://x.com/andripeetso/status/2091687687480566048
> How well would it do on a 4080 SUPER via thunderbolt dock? (I have the 4080 collecting dust)
>
> @DmitriiDunin (Dmitriy Dunin) — date: Mon Aug 24 00:51:23 +0000 2026 · url: https://x.com/DmitriiDunin/status/2091689795072454719
> Man I can also type very fast, it does not mean it will be meaningful text
>
> @sgam_rs (sgam) — date: Mon Aug 24 04:36:11 +0000 2026 · url: https://x.com/sgam_rs/status/2091746367077339173
> i like where this is going, i remember Opus 4.6
>
> @Aizkmusic (aizk) — date: Mon Aug 24 04:39:17 +0000 2026 · url: https://x.com/Aizkmusic/status/2091747149230887230
> How much context
>
> @md_argv (mud) — date: Mon Aug 24 07:07:40 +0000 2026 · url: https://x.com/md_argv/status/2091784487747375180
> What
>
> @eneesgur (Enes Gür) — date: Mon Aug 24 07:45:12 +0000 2026 · url: https://x.com/eneesgur/status/2091793935874101452
> Context size?
>
> @xhuydang (Huy X. Dang) — date: Mon Aug 24 11:03:18 +0000 2026 · url: https://x.com/xhuydang/status/2091843789115818410
> i've seen this word so many times, but wth is "blackpilling"
>
> @MacFruitjuice (Mac Fruitjuice) — date: Mon Aug 24 11:24:14 +0000 2026 · url: https://x.com/MacFruitjuice/status/2091849056091832479
> must be real life use case situation
>
> @almostanhour (Rick) — date: Mon Aug 24 15:48:21 +0000 2026 · url: https://x.com/almostanhour/status/2091915523051143365
> Share specs. What LM server, config, quant etc?
