---
created: 2026-09-01
description: Roy's (@usr_bin_roygbiv) memory-bandwidth ladder — "matmuls are parallel mem reads", so decode speed is bandwidth divided by bytes per token — DDR5 51.2 GB/s (one channel) · DGX Spark/GB10 273 · M5 Max 614 · M3 Ultra 819 · RTX 3090 936 · RTX 5090/PRO 6000 1.8 TB/s plus NVFP4 · H200 4.8 · B300 8 TB/s — and his real thesis, in the replies, that a $1K used 3090 out-decodes a $5K Mac or DGX Spark, so "if your budget is $1k, 3090; $2k, 2x3090; $4k, 5090; $10k, 6000 pro." Every rung checks out against spec sheets, but the ladder has no capacity column, no prefill column and no utilization term, and it was posted three months before the M5 Ultra (1.2 TB/s) and GLM-5.3-Flash (~200 GB at 4-bit) existed.
source: https://x.com/usr_bin_roygbiv/status/2056097880499224880
author: "@usr_bin_roygbiv (Roy)"
type: post
tags: [local-inference, hardware, memory-bandwidth, decode, roofline, rtx-3090, rtx-5090, rtx-pro-6000, dgx-spark, mac-studio, nvfp4, ddr5, buying-guide, opinion]
---

## Key Takeaways

> [!warning]- Dated context — posted 2026-05-17, captured 2026-09-01
> This ladder predates two things that reshape it. **The M5 Ultra Mac Studio (announced 2026-08-25, 1.2 TB/s, 96/256 GB now, 512 GB in late October)** adds a rung Roy did not have — between his 3090 (936 GB/s) and his 5090/PRO 6000 (1.8 TB/s) — and it is the only rung on the ladder below $30K that ships with more than 96 GB behind it. **GLM-5.3 (2026-08-14) and GLM-5.3-Flash (2026-08-26)** are the current open-weights targets (AA 60 and 57), and they are hybrid-linear-attention MoEs at 3–5% active: Flash reads ~15–19 GB per token but needs ~200 GB resident at 4-bit. That combination — small bytes-per-token, huge resident weights — is exactly the case where a ladder sorted by GB/s alone gives the wrong answer, because none of Roy's sub-$10K rungs can hold the model at all. The framing (decode = bandwidth ÷ bytes/token) is still the right first principle; the ranking it produces is now incomplete. Prices also moved: the 2026 DRAM shortage roughly doubled the top two NVIDIA rungs (RTX 5090 $2K → $4.3–5K; RTX PRO 6000 $8.5K → $14–16K new) while the used 3090 stayed at ~$1K. Evidence: `/data/projects/hardware/research/hw-apple.md` §2.1, `hw-nvidia.md` §2.9, `models-glm53.md`, `00-synthesis.md` §1.

- **The first principle is right and worth memorizing: decode is a parallel memory read, so tokens per second is bandwidth divided by bytes touched per token.** "You are playing Crysis on a Celeron" is Roy's way of saying the bottleneck is the bus, not the ALUs — the same roofline [[Step 01 - Decode is memory-bandwidth-bound (the roofline)|the inference course derives from first principles]]. What the ladder leaves out is the utilization term that sits between spec and reality: measured on this folder's own hardware, dense models on an M5 Max reach **74–85%** of 614 GB/s, an M3 Ultra only **43–65%** (the UltraFusion hop penalizes single-stream decode), sparse MoE on Ultra dies **28–45%**, a DGX Spark ~**73%** (~200 GB/s actual), and 2× RTX PRO 6000 **65–80%**. @CustomWetware asked Grok for exactly this "effective bandwidth" and got every rung shaved by a similar 7–15% — Roy mocked it, and correctly: the real haircut is not uniform, it is platform- and model-shaped, and it is largest on the Apple Ultra parts running the MoE models people buy them for. The rungs themselves are verified below.

> [!note]- Verifying the ladder rung by rung (2026-09-01, home-lab research)
> | Roy's rung | Roy's figure | Verified | Tag | Note |
> | --- | --- | --- | --- | --- |
> | DDR5 | 51.2 GB/s | 51.2 GB/s **per 64-bit channel at DDR5-6400** (8 B × 6400 MT/s) | [SPEC] | A desktop is dual-channel = 102.4 GB/s theoretical; 12-channel EPYC Turin = 614.4 theoretical, **~565 measured** (92% efficiency). @foley2k2's correction in the replies is right; Roy's rung is the single-channel number |
> | "dgx/bg10" (DGX Spark, GB10) | 273 GB/s | **273 GB/s** LPDDR5X, 256-bit | [SPEC] | Measured **~200 GB/s actual (73%)**. "bg10" is a typo for GB10 |
> | M5 Max | 614 GB/s | **614 GB/s** — 40-core GPU bin only | [SPEC] | The 32-core GPU bin (locked to 36 GB) is **460 GB/s** |
> | M3 Ultra | 819 GB/s | **819 GB/s** | [SPEC] | Measured decode utilization 43% (Q4) to 65% (F16) on a 7B; MoE 28–45% |
> | RTX 3090 | 936 GB/s | **936 GB/s** GDDR6X, 24 GB | [SPEC] | Used **$820–1,050**, Sept 2026; NVLink bridge in pairs only |
> | RTX 5090 / RTX PRO 6000 | 1.8 TB/s + NVFP4 | **1,792 GB/s** both (GDDR7, 512-bit); PRO 6000 **Server Edition is 1,600** | [SPEC] | 5090 = 32 GB at $4,300–5,000; PRO 6000 = 96 GB at $14–16K new, refurb $9.5–11K. NVFP4 is native on **all** Blackwell, GB10 included (see @Leik0w0) |
> | H200 | 4.8 TB/s | **4,800 GB/s** HBM3e, 141 GB (H200 NVL) | [SPEC] | $31–39K, **passively cooled**, no display out — not homelab hardware |
> | B300 | 8 TB/s | **8 TB/s** HBM3e, 288 GB (B300 GPU spec); the DGX Station GB300 desktop config is listed at 252 GB / **7.1 TB/s** | [SPEC, conflicting] | $85–123K as a desk-side Station; out of scope |
>
> Missing rungs as of Sept 2026: **M5 Ultra 1.2 TB/s** (96/256/512 GB) · RTX PRO 5000 Blackwell 1,344 GB/s (48/72 GB, $4.3–6K) · RTX 4090 1,008 GB/s (24 GB, ~$2.3K used) · Strix Halo 256 GB/s (128 GB) · A100 80 GB 1,935 GB/s (~$8–10K used, passive).
> Evidence: `hw-nvidia.md` §2.1, §2.8, §2.9; `hw-apple.md` §2.1, §2.4; `hw-alternatives.md` (Turin bandwidth, RDIMM pricing); `fundamentals-software.md` §1.5.

- **Roy's actual thesis is in the replies, not the post, and it is a price argument: "I'm specifically targeting the people buying DGXs and Macs at home over a GPU."** "Literally a 3090 is a fifth the price of a Mac or DGX" — true on Sept 2026 prices ($820–1,050 used versus a $4,699 DGX Spark or a $5,099 M5 Max 128 GB), and the 3090's 936 GB/s does beat both on decode. His budget ladder to @tmaiaroto is the durable, quotable part: **"if your budget is $1k, 3090; $2k, 2x3090; $4k, 5090; $10k, 6000 pro — it's that simple."** Marked against today's street prices the bottom rung holds exactly, the middle rung is now $4.3–5K, and the top rung is $14–16K new (only a refurb or the 300 W Max-Q lands near $10K) — the DRAM shortage doubled the two rungs that were already the expensive ones while the used-Ampere rung did not move. That asymmetry is the research's recurring finding that what holds value is memory on a toolchain that stays alive: the 3090 is a 2020 card and still the dollars-per-GB/s champion because CUDA never dropped it, and a pair of them is the only sub-$2.5K configuration with an NVLink bridge.

- **What the ladder has no column for is capacity, and capacity decides whether the target model runs at all.** A 3090 holds 24 GB, a 5090 32 GB, a PRO 6000 96 GB. GLM-5.3-Flash at 4-bit is ~**200 GB**, GLM-5.3 ~**460 GB**: the cheapest rung that holds Flash is **3× RTX PRO 6000 (288 GB, $42–48K)** or a **256 GB M5 Ultra at $9,499** — the one is above the ladder's top, the other is a rung Roy did not have. This is the axis [[M5 Ultra 256GB scores 3.26x the DGX Spark on memory GB times bandwidth per dollar - the Apple-beats-NVIDIA case rests on a metric with no compute term|the memory-value chart]] gets right and [[buy the RAM that holds the model - a SKU-by-SKU M5 Mac guide with the CUDA tax and separate decode-prefill predictions|the SKU guide]] puts first: "RAM decides if the model is even there." Roy's advice is exactly right for models that fit one card — a dense 27B at ~16.5 GB decodes at roughly 936 × 0.7 ÷ 16.5 ≈ **40 t/s on a $1K 3090**, and a 5090 does 100–160 t/s with ~10K t/s prefill — and it is inapplicable to the Flash-frontier class without a multi-card build that costs more than the Macs he is arguing against. @theodorvaryag's reply that Mac buyers "overestimate what kinds of models will be usable on 4×128 GiB M5 Max" has aged in reverse: the models worth running are 200–460 GB MoEs, which is precisely what unified memory exists for, and [[tensor parallelism aggregates memory controllers so 8x RTX PRO 6000 reaches ~14.3 TB-s where one M5 Ultra has 1.2|multi-card aggregation]] is the NVIDIA answer only when the interconnect and the kernels cooperate. The matched-price comparison in [[at 15-20K with 512GB the real gap is bandwidth not compute - Mac Studio M5 Ultra vs 4x DGX Spark vs 4x Ryzen AI Halo|the 512 GB three-way]] is what Roy's ladder looks like once a capacity floor is imposed.

- **For agentic coding the ladder ranks the wrong axis — and, ironically, the right axis strengthens Roy's "get a card" conclusion for a different reason.** Across every platform the research measured, big-MoE **decode clusters in a 20–80 t/s band**, while effective **prefill spans 37 t/s (M3 Ultra, an 80-second TTFT on a 3K prompt) to ~10,000 t/s (RTX 5090 with vLLM)** — a 270× spread. An agent that re-reads a large codebase context every turn lives in prefill, which is tensor-core compute and CUDA kernels, not GB/s; that is why 2× RTX PRO 6000 prefill DeepSeek-V4-Flash at 6,058 t/s where 2× DGX Spark manage 1,400–1,700, and why [[LMCache offloads paged KV to system RAM and NVMe, cutting 128K-context time-to-first-token from 68 seconds to 1.4 on 4x DGX Spark|KV offload]] matters more than a bandwidth tier for long-context loops. So the NVIDIA card wins the reader's workload, but bandwidth is the weakest of the three reasons. The "**PLUS nvfp4**" flourish is also narrower than it reads: NVFP4 has native tensor cores on *every* Blackwell part, GB10 included — @Leik0w0's correction is right, and Roy's "a fifth the tok/s rather than an eighth" retort is just the 273/1,792 ratio restated (measured PRO 6000 vs Spark decode is ~7×) — and NVFP4 is a **throughput-and-energy feature, not a quality feature**: NVIDIA's own FP8→NVFP4 table on DeepSeek-R1 moves MMLU-Pro 85→84 and GPQA 81→80, so it buys tokens per second per watt, never intelligence per GB. [[GLM-5.3-Flash FP8 really is 306GB and really fits in 512GB - but 60 t-s is 80-90 percent of the roofline on a machine that does not ship until October|The GLM-5.3-Flash roofline note]] runs the same arithmetic on the Mac side.

- **The DDR5 rung is where the thread gets interesting, because the best reply attacks the premise.** Roy's 51.2 GB/s is one channel; a 12-channel EPYC Turin reaches ~565 GB/s measured, and Roy's rejoinder — "even with a $20k 12 channel setup you're looking at slower than a Mac" — is true against an Ultra (819 or 1,200 GB/s), a tie against an M5 Max, and today undercounts the cost (DDR5 RDIMM is ~$32/GB, 8× 2025 pricing, so 768 GB of it is ~$25K before the CPU). But @JakeKAllDay's June follow-up is the sharpest thing in the thread: **partial MoE offload on a 5070 plus DDR5-5600 gets "within 5% of my M4 Max"** because MTP and sparse expert activation shrink the bytes the slow tier has to serve, and "a 5080 + 64 GB 7200 MT/s on a newer CPU… would absolutely outrun an M4 Max and might M5 Max (on decode, probably not prefill). That's easily a <$5K setup." That matches the research's EPYC-plus-one-GPU hybrid band (**15–33 t/s decode** for 200–800B MoEs — e.g. 2,540 t/s prefill / 27.6 t/s decode on 2× EPYC 9355 + one 5090) and its finding that **speculative decoding/MTP is worth more than a hardware tier (2.25–3.8× on the same box)**. In other words: once the model is 3–5% active, the bandwidth of the tier holding the *cold* experts stops being the number that matters, and the ladder's bottom rung is not as damning as it looks — provided the engine has MTP, which mainline MLX still does not. (@shitcoinity's striped-NVMe 60 GB/s is the same idea one tier lower, expert streaming from SSD, and the measured result on a single M5 Max is GLM-5.2 at ~4.8 t/s: it buys capacity, not speed. [[EXL3 3-bit plus an 18.5 percent expert prune runs DeepSeek-V4-Flash 284B at 47 tok-s on 4.7K of hardware|Quantize-and-prune]] is the other way to shrink the bytes.)

## Roy's replies to commenters

The high-value half of this capture. All dates UTC.

- **To @theodorvaryag (2026-05-17)** — "literally a 3090 is a fifth the price of a mac or dgx I do not understand." *Verified on Sept 2026 street prices (used 3090 $820–1,050 vs DGX Spark $4,699 / M5 Max 128 GB $5,099); omits that it is also a fifth to a sixth of the memory.*
- **To @foley2k2 (2026-05-17)** — on 12-channel DDR5 servers: "you're still looking at a $20k 2u server vs a $5k mac or $1k 3090," and, when pressed on chassis size, the thesis statement: **"i'm specifically targeting the people buying dgxs and macs at home over a gpu with this post."** *Opinion; the $20K figure is now low given DDR5 RDIMM at ~$32/GB.*
- **To @JakeKAllDay (2026-05-18)** — on faster DDR5 kits: "even with a $20k 12 channel setup you're looking at slower than a mac." *Verified against an Ultra (~565 GB/s measured Turin vs 819/1,200); a tie against the M5 Max's 614. Jake's June counter (MoE offload plus MTP within 5% of an M4 Max for under $5K) went unanswered.*
- **To @Leik0w0 (2026-05-17)** — told GB10 also supports NVFP4: "oh great now it runs at only a fifth the tok/s rather than an eighth." *Léo is right that NVFP4 is not a 5090/PRO 6000 differentiator versus the Spark (all are Blackwell); Roy's ratio is right anyway — 273/1,792 = 0.15, and measured PRO 6000 vs Spark decode is ~7×.*
- **To @tmaiaroto (2026-05-18)** — a 3090 owner with a dual-Xeon workstation that trips breakers, wanting agents, ComfyUI and Flux/Z-Image LoRA training plus more memory for parallel jobs, asking 3090-vs-GB10: "i'd get a 5090," then **"if your budget is $1k, 3090, $2k, 2x3090, $4k, 5090, $10k, 6000 pro its that simple."** *Opinion, and a good one for image generation and LoRA training (CUDA, compute); it ignores the two things the asker actually raised — a 5090 draws 575 W against the Spark's ~200 W measured, and 32 GB is less room to "run a few things in parallel" than 128 GB. The research's reconciliation is the split build: a big-memory box plus one CUDA card.*
- **To @DJLougen (2026-05-17)** — "So can I play Crysis on Ultra in NVFP4?" → "on high at 60fps you're ballin out on b300s for 144fps ultra." *Joke.*
- **To @codecovenant (2026-05-18)** — "Can I borrow your B300?" → "I wish I had one." *Roy does not own the top two rungs.*
- **To @CustomWetware (2026-05-18)** — who posted Grok's "effective bandwidth" ranges (3090 800–900, 5090 1.5–1.7 TB/s, B300 7.0–7.6, and so on): "how much did you have to argue and be pedantic with it to get it to admit the advertised numbers are slightly higher than reality in order to be right on a twitter reply?" ("Just that one prompt.") *Roy is right to dismiss it: Grok shaved every rung by a similar 7–15%, whereas measured utilization ranges from 85% (M5 Max, dense) down to 28% (MoE on an Ultra).*
- Not answered by Roy: @per_arneng's bar chart of the ladder (2026-05-18, embedded below), @neilquinn's "you need the rest of the machine too (another 800–1k or so), plus far less efficient" (2026-05-18), @shitcoinity's channels-and-SSDs point (2026-05-19), @_sunnymind's "bought 3090 for gaming and mining… happy to see it's still useful" (2026-06-21).

## External Resources

- Original post: [@usr_bin_roygbiv, 2026-05-17](https://x.com/usr_bin_roygbiv/status/2056097880499224880) — 143 likes, 7 reposts, 11 replies
- Roy's budget ladder: [@usr_bin_roygbiv, 2026-05-18](https://x.com/usr_bin_roygbiv/status/2056228364571090963)
- Roy's thesis statement: [@usr_bin_roygbiv, 2026-05-17](https://x.com/usr_bin_roygbiv/status/2056138364386996516)
- Best counter-reply: [@JakeKAllDay, 2026-06-26](https://x.com/JakeKAllDay/status/2070564289786581337) — MoE offload plus MTP within 5% of an M4 Max on a 5070
- [@JakeKAllDay, "A Beginner Primer on Using MoE Models on Consumer Hardware"](https://x.com/JakeKAllDay/status/2059310445798797748) — the X Article Jake links as proof of the offload claim
- [@per_arneng's chart of the ladder](https://x.com/per_arneng/status/2056403227424198661)
- [Grok share](https://grok.com/share/c2hhcmQtMi1jb3B5_73af4b34-e302-4299-9167-d0f5065cd05c) — the "effective bandwidth" conversation @CustomWetware posted
- Hardware in the ladder: NVIDIA DGX Spark (GB10) · RTX 3090 · RTX 5090 · RTX PRO 6000 Blackwell · H200 · B300 · Apple M5 Max · M3 Ultra

## Original Content

> [!quote]- Full post (@usr_bin_roygbiv, 2026-05-17)
> Had 4 people ask now so I feel required to make a post
> You are playing crysis on a celeron
> Matmuls are parallel mem reads
>
> DDR5 - 51.2 GB/s
> dgx/bg10 - 273 gb/s
> m5 max - 614 gb/s
> m3 ultra - 819 gb/s
> 3090 - 936 gb/s
> 5090/pro 6000 - 1.8 tb/s PLUS nvfp4
> h200 - 4.8 tb/s
> b300 - 8 tb/s
>
> Engagement: 143 likes | 7 retweets | 11 replies
> [Original post](https://x.com/usr_bin_roygbiv/status/2056097880499224880)

> [!quote]- Replies and Roy's answers (2026-05-17 to 2026-06-26)
> @theodorvaryag (Chris Allen) — 2026-05-17:
> I keep telling people not to bother with the rinky-dink boxes for LLMs and just get a card or multiple
> > @usr_bin_roygbiv (Roy) — 2026-05-17:
> > literally a 3090 is a fifth the price of a mac or dgx I do not understand
> > > @theodorvaryag (Chris Allen) — 2026-05-17:
> > > I don't know for sure but I think they're overestimating what kinds of models will be usable on 4x128 GiB M5 Max and/or they're afraid of building a desktop or server.
> > >
> > > @neilquinn (Neil Quinn) — 2026-05-18:
> > > You need the rest of the machine too. (Another 800-1k or so) Plus far less efficient.
>
> @DJLougen (Daniel Lougen) — 2026-05-17:
> So can i play crysis on ultra in nvfp4
> > @usr_bin_roygbiv (Roy) — 2026-05-17:
> > on high at 60fps you're ballin out on b300s for 144fps ultra
>
> @foley2k2 (Jason - looking for work) — 2026-05-17:
> DDR5 is that amount per channel. Up to a 12 channel config is possible on servers.
> > @usr_bin_roygbiv (Roy) — 2026-05-17:
> > you're still looking at a $20k 2u server vs a $5k mac or $1k 3090
> > > @foley2k2 (Jason - looking for work) — 2026-05-17:
> > > 5-10u for a GPU server to have enough space. 4u can be used for maybe 4 GPUs, 2u would have them turned on their side and that'd need a support bracket.
> > > > @usr_bin_roygbiv (Roy) — 2026-05-17:
> > > > i'm specifically targeting the people buying dgxs and macs at home over a gpu with this post
>
> @JakeKAllDay (Jake) — 2026-05-17:
> It obviously doesn't change the important numbers but you can get way higher GB/s for DDR5 at 6000/7200 MT/s. Which can pull average up meaningfully for offload.
> > @usr_bin_roygbiv (Roy) — 2026-05-18:
> > even with a $20k 12 channel setup you're looking at slower than a mac
> > > @JakeKAllDay (Jake) — 2026-06-26:
> > > (Someone liked a comment just now and brought this back up for me)
> > > Not necessarily.
> > >
> > > I get within 5% of my M4 Max running partial Moe offload on a 5070 + 5600 MT/s because MTP and sparse RAM activation limits the RAM/CPU (2024 ryzen) bottleneck. A 5080 + 64 Gb 7200 mt/s on a newer CPU with more layers kept in GPU would absolutely outrun a m4 max and might m5 max (on decode, probably not prefill). MTP lets you deflect some CPU based slowdown too. Thats easily a <5k setup.
> > >
> > > The hidden state is tiny, partial RAM offload is really not punitive anymore with MTP.
> > >
> > > If you don't believe me you can try it for yourself:
> > >
> > > QT @JakeKAllDay: Article: A Beginner Primer on Using MoE Models on Consumer Hardware — [x.com/JakeKAllDay/status/2059310445798797748](https://x.com/JakeKAllDay/status/2059310445798797748)
>
> @Leik0w0 (Léo) — 2026-05-17:
> gb10 supports nvfp4 just like gb202 does
> > @usr_bin_roygbiv (Roy) — 2026-05-17:
> > oh great now it runs at only a fifth the tok/s rather than an eighth
> > > @Leik0w0 (Léo) — 2026-05-18:
> > > not sure that's how it works sir
>
> @codecovenant (Code and Covenant) — 2026-05-18:
> Can i borrow your b300 please?
> > @usr_bin_roygbiv (Roy) — 2026-05-18:
> > I wish I had one
>
> @tmaiaroto (Tom Maiaroto) — 2026-05-18:
> ok, so i have a 3090 in my main machine. I have a 3060 in one workstation with dual xeons and only 64gb of system ram. So for me I'm thinking about a GB10 for a few reasons.
>
> First. I had to move a workstation to another room because circuit breakers kept tripping. So power draw is a concern.
>
> Second, the convenience of a small machine is attractive.
>
> Third, I want to run a few things in parallel and so having more memory is enticing.
>
> I want to run agents and also comfyui and train LoRAs for flux or z-image. I train on runpod and use various providers for inference. I want to be free of those cloud dependencies.
>
> Would you get a single 3090 to replace (or run alongside) the 3060 in that workstation? Workstation has like 1100w PSU or larger. Or ... A nice small little box?
> > @usr_bin_roygbiv (Roy) — 2026-05-18:
> > i'd get a 5090
> >
> > @usr_bin_roygbiv (Roy) — 2026-05-18:
> > if your budget is $1k, 3090, $2k, 2x3090, $4k, 5090, $10k, 6000 pro its that simple
>
> @per_arneng (Per Arneng) — 2026-05-18:
> Made a chart, thanks for the numbers.
>
> *Memory Bandwidth Comparison — Roy's eight rungs as a bar chart, DDR5 51.2 GB/s through B300 8.0 TB/s:*
> ![[usr_bin_roygbiv-224880-001.jpg]]
>
> @CustomWetware (Custom Wetware) — 2026-05-18:
> @grok What's the effective read bandwidth available for the tensor cores on each of those platforms?
>
> @CustomWetware (Custom Wetware) — 2026-05-18:
> DDR5 - [depends on number of channels, refresh rate, cpu and motherboard]
> dgx/bg10 - 250-270 GB/s
> m5 max - 520-580 GB/s
> m3 ultra - 700-780 GB/s
> 3090 - 800-900 GB/s
> 5090/pro 6000 - 1.5-1.7 TB/s
> h200 - 4.3-4.6 TB/s
> b300 - 7.0-7.6 TB/s
>
> [grok.com share](https://grok.com/share/c2hhcmQtMi1jb3B5_73af4b34-e302-4299-9167-d0f5065cd05c)
> > @usr_bin_roygbiv (Roy) — 2026-05-18:
> > how much did you have to argue and be pedantic with it to get it to admit the advertised numbers are slightly higher than reality in order to be right on a twitter reply?
> > > @CustomWetware (Custom Wetware) — 2026-05-18:
> > > Just that one prompt.
> > >
> > > @shitcoinity (Shitcoinity) — 2026-05-19:
> > > The point about ddr5 being mostly a factor of channels is fair tho, bro. Serious workstation/server workloads are heavily multichannel and a 12 channel 1tb mem pool is nothing to laugh about (also insanely expensive at current prices)... and you forgot to ass SSDs
> > >
> > > My 4x wd dc sn681 striped pool has almost 60gb/s read bandwith
>
> @_sunnymind (Sunny) — 2026-06-21:
> bought 3090 for gamining and mining, gave me 15$ per day back then... now happy to see its still useful for something...
>
> [Original post](https://x.com/usr_bin_roygbiv/status/2056097880499224880)
