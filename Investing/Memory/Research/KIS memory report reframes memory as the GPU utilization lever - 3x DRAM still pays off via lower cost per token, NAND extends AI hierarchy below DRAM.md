---
created: 2026-05-05
published: 2026-04-30
description: Korea Investment & Securities (KIS) reframes the AI memory thesis from cost-line to utilization-lever — paying 3x for DRAM still lowers system-wide cost per token if the extra capacity unlocks idle GPU cycles, and NAND at sub-$0.12/GB is being absorbed below DRAM in the memory hierarchy rather than cannibalizing it.
source: https://x.com/jukan05/status/2049847048690938030
type: research
authors: ["Jukan (@jukan05)"]
---

# KIS memory report reframes memory as the GPU utilization lever - 3x DRAM still pays off via lower cost per token, NAND extends AI hierarchy below DRAM

Jukan (@jukan05, considered one of the more credible Korean memory-cycle commentators on X) shares an excerpt from a Korea Investment & Securities (KIS) memory note, arguing that the market is mispricing the recent ~3x DRAM YoY spike because it analyzes memory as a standalone cost line rather than a system-level utilization lever. The same logic, applied to NAND at $0.10–0.12/GB versus DRAM at >$6/GB, says the AI memory hierarchy is now extending downward into NAND — additive, not zero-sum.

## Key Takeaways

- **Memory is a GPU-utilization lever, not a cost line item** — KIS's central reframe: when HBM/DRAM capacity is short, GPUs sit underutilized and cost-per-token rises; expanding memory raises GPU utilization, which lowers cost-per-token, which pulls in more inference demand. This is why hyperscalers locked in the AI arms race propose long-term supply agreements to [[Micron (MU)]], [[SK Hynix (000660.KS)]], and [[Samsung Electronics (005930.KS)]] even as ASPs rip — paying up still improves system-level economics.
- **The 3x-DRAM bear case is anchored to a standalone-cost view that doesn't survive Jensen's full-system framing** — Huang's argument that single-chip specs in isolation are meaningless (cost-per-token and performance-per-watt are the decisive metrics) extends directly to memory: if buying memory at a premium still pays off at the system level, hyperscaler purchases continue. Implication: theses predicting demand collapse from sticker shock misread how AI buyers evaluate memory ROI.
- **NAND is being absorbed into the AI memory hierarchy below DRAM, not displacing it** — at ~$0.10–0.12/GB versus DRAM >$6/GB even in the cheapest mobile segment, NAND is an order of magnitude cheaper per unit of capacity. The upper tiers (HBM, DRAM) alone can no longer accommodate AI workload growth, so NAND extends the hierarchy. Implication: pure-play NAND names — [[SanDisk (SNDK)]], [[Kioxia (285A.T)]], plus integrated [[Western Digital (WDC)]] — get a structural demand leg from AI inference, not the zero-sum cannibalization the bear case implies.
- **Even 2–3x NAND repricing keeps it the cheap tier — extreme pricing power latent** — KIS's math: NAND could double or triple and still sit far below DRAM per GB. So the system-level pressure to push more capacity *into* NAND persists across a wide ASP band. Implication: NAND ASPs may run further than a standalone-cycle view would suggest, because the gating constraint is system-wide cost per token, not flash supply-demand alone. (Reply from @vin_sachi articulates the extreme version: "could 20x and remain competitive.")
- **Top-down validation for the bottom-up memory-tier infrastructure builds already in the vault** — the same hierarchy-extension argument is what physically gets implemented in [[PENG SK Hynix HBF memory tier plus Celestial photonics at 1x sales 2x memory revenue - ThematicTrader bull thesis|Penguin Solutions' SK Hynix HBF (high-bandwidth flash) tier]] and the [[PENG MemoryAI CXL KV Cache server ships with Tier-1 bank win, FY26 guide raised to 1.5-1.6B - Stockinger institutional brief|MemoryAI CXL KV-cache appliance]]. KIS provides the macro logic; [[Penguin Solutions (PENG)]] is one of the picks-and-shovels expressions of it.

## External Resources

_(none — KIS report not linked publicly; this note captures the excerpt Jukan shared)_

## Original Content

> [!quote]- Source thread (verbatim from `bird thread`)
>
> **@jukan05 (Jukan):**
> KIS, which I consider one of the top three Korean sell-side firms, published a memory report, and there's a comment from it that I wanted to share with you all:
>
> Memory is the critical variable that determines GPU utilization. In particular, when HBM and DRAM capacity is insufficient, memory bottlenecks prevent GPUs from being fully utilized, leading to a decline in overall system efficiency. Conversely, expanding memory capacity raises GPU utilization, allowing the same GPU resources to process a greater number of tokens. This translates directly into a lower cost per token. As cost per token falls, more users are drawn in, ultimately driving a larger expansion in inference demand. This is precisely why hyperscalers, despite rising memory ASPs, are willing to go as far as proposing long-term supply agreements in order to secure greater memory allocation. The cost of purchasing memory rises, but at the same time, that purchase improves GPU utilization—lifting overall system efficiency and lowering cost per unit of performance.
>
> With DRAM prices having spiked roughly 3x year-over-year in a short span, the market is now bracing for a subsequent decline in demand or prices. But this view stems from looking at memory purely as a standalone cost line item. Even if DRAM is purchased at 3x the price, if that spending allows more GPUs to run and more tokens to be processed, system-wide profitability can actually improve. The fate of the chips that once tried to challenge NVIDIA GPUs by leaning on MLPerf benchmarks—touting per-chip performance-per-watt and price-performance comparisons—illustrates this well. As Jensen Huang has repeatedly emphasized, comparing single-chip specs in isolation is meaningless. Huang has stated that NVIDIA GPUs deliver the lowest cost per token in the world, adding that the lowest cost per token and the highest performance per watt are the decisive metrics of AI economics. In other words, his consistent argument is that competition should not be waged on GPU hardware specs alone, but rather on cost per token at the full-system level. The same logic extends to memory. If "buying memory at a premium still pays off at the system level," then memory purchases by hyperscalers locked in the AI arms race will continue.
>
> The same logic applies to NAND. Active efforts are underway to integrate NAND into AI infrastructure systems. Some argue that wider NAND adoption will eat into DRAM demand, but this too misreads the memory market as a zero-sum game with a fixed pie. As AI workloads have grown, the upper tiers of the memory hierarchy—HBM and DRAM—alone can no longer accommodate the demand, and NAND has emerged as a key element in extending that hierarchy. NAND, in particular, offers an overwhelmingly lower cost per unit of capacity than DRAM. As of Q1 2026, NAND prices stand at roughly $0.10–$0.12 per GB, whereas DRAM—even mobile DRAM, the lowest-priced application segment—has already surpassed $6 per GB on a contract basis. Even if NAND prices were to double or triple, they would still remain far below DRAM. If even a portion of AI workloads can be offloaded to NAND, it can directly contribute to lowering system-wide cost per token.
>
> $DRAM $MU $SNDK
> _Thu Apr 30 13:43:15 +0000 2026_
> [https://x.com/jukan05/status/2049847048690938030](https://x.com/jukan05/status/2049847048690938030)
>
> ---
>
> **@CaseyCavender34 (Jnkau--Assistant):**
> @jukan05 next Strategy!!
>
> ⬇️
> _Thu Apr 30 13:43:58 +0000 2026_
>
> ---
>
> **@VVTLD (VVTLD | Money Signal):**
> @jukan05 The market may still be treating memory as a cost cycle. AI is starting to treat it as a utilization lever.
> _Thu Apr 30 13:44:15 +0000 2026_
>
> ---
>
> **@michael_lu_03 (Michael Lu):**
> @jukan05 Memory has become new bottleneck.
> _Thu Apr 30 13:46:31 +0000 2026_
>
> ---
>
> **@ZhuoAshton (Ashton Z):**
> @jukan05 Thank you very much for sharing, the author's point of view complete my understanding.
> _Thu Apr 30 13:54:27 +0000 2026_
>
> ---
>
> **@CifrBunny (🐰):**
> @jukan05 This is actually so informative thanks as always man $MU $SNDK
> _Thu Apr 30 14:03:18 +0000 2026_
>
> ---
>
> **@AlmaCap114204 (AlmaCap):**
> @jukan05 🕺
> _Thu Apr 30 14:06:10 +0000 2026_
>
> ---
>
> **@Hopehope_G_hope (Participant in a complex world):**
> @jukan05 https://t.co/WXufVnSyHD
> PHOTO: https://pbs.twimg.com/media/HHKLHGnaoAAo63L.jpg
> _Thu Apr 30 14:09:50 +0000 2026_
>
> ---
>
> **@1991Wolfpack (Jeff Wright):**
> @jukan05 Excellent note and thank you for sharing.
> $MU, $SNDK & $WDC all look to be long term beneficiaries.
> _Thu Apr 30 14:33:12 +0000 2026_
>
> ---
>
> **@KislayParashar1 (Kislay Parashar):**
> @jukan05 People still treat memory like a cost line, not a throughput lever. If more DRAM/HBM lets GPUs actually stay busy, paying up makes sense. Utilization drives economics, not just chip specs.
> _Thu Apr 30 14:55:00 +0000 2026_
>
> ---
>
> **@kathirBabu2000 (Jnkeu consultant):**
> @jukan05 My internal plan is as follows
> ⬇️ $DRAM $MU $SNDK
> _Thu Apr 30 15:00:39 +0000 2026_
>
> ---
>
> **@AnalysisOp (Alex A.C.):**
> @jukan05 Conclusion: higher for longer 😌
>
> Memory & Storage stocks, you deserve a re-rating and higher prices! $MU SK hynix $SNDK
> _Thu Apr 30 15:14:09 +0000 2026_
>
> ---
>
> **@_junhoyeo (JUNØ):**
> @jukan05 Fadu
> _Thu Apr 30 15:22:47 +0000 2026_
>
> ---
>
> **@Alweerb (黎文杰):**
> @jukan05 But wall street doesn't care
> _Thu Apr 30 15:35:33 +0000 2026_
>
> ---
>
> **@vin_sachi (Vin Sachidananda):**
> @jukan05 So much pricing power for NAND, could 20x and remain competitive
> _Thu Apr 30 15:57:47 +0000 2026_
>
> ---
>
> **@getsumm2 (getsumm):**
> @jukan05 +$kioxia
> _Thu Apr 30 16:37:39 +0000 2026_
>
> ---
>
> **@zhaoxiongding (Ding):**
> @jukan05 What's a sell side firm?
> _Thu Apr 30 18:57:17 +0000 2026_
>
> ---
>
> **@drakeondigital (Drake on Digital):**
> @jukan05 why is it that nand > dram?
> _Thu Apr 30 20:38:57 +0000 2026_
>
> ---
>
> **@SHREDDER2013 (SHREDDER):**
> @jukan05 My next upgrade WILL BE CPU RAM MOTHERBOARD AND PSU because ihave the cpu ram and motherboard since 2017 and psu since 2016 but i will keep the graphics card and ssd becuase i got the ssd in 2020 and changed graphics card i n 2021.
> MINE MONSTER PC IS RYZEN 7 1700 RX 6700XT
> _Thu Apr 30 20:58:29 +0000 2026_
>
> ---
>
> **@SHREDDER2013 (SHREDDER):**
> @jukan05 12 GB RED DEVIL 16 GB DDR4 3200MHZZCL15 MP 600 2TB WRITE:4950MB/S READ:4250MB/S DELLP2416D 24'' 2560X1440 60 HZ IPS
> I think to get 270k 32 GB DDR5 720MMHZ and Z890 AORUS elite WIFI 7 or nova lake if nova lake releses thsi year.
> i WILL WAIT until december to see if the
> _Thu Apr 30 20:58:52 +0000 2026_
>
> ---
>
> **@SHREDDER2013 (SHREDDER):**
> @jukan05 i WILL WAIT until december to see if the prices of ram reduced .
> _Thu Apr 30 20:59:20 +0000 2026_
>
> ---
>
> **@haruko_ai_jp (はる子／AI運用):**
> KIS のこのロジック、米ハイパースケーラーがメモリ長期契約に走る動機と完全整合します。$MU $005930.KS $000660.KS の単価3倍でも、トークン単価低下→推論需要爆発→さらにメモリ需要拡大というループが続く限り買い続ける。逆に推論需要の頭打ちが唯一のリスク。このループが折れる条件、何だと思いますか？
> _Thu Apr 30 22:06:38 +0000 2026_
>
> ---
>
> **@pawpawinthepow (Cccccccq):**
> @jukan05 Do you think this is true, or it is a working theory? @jukan05
> _Thu Apr 30 23:31:02 +0000 2026_
>
> ---
>
> **@cacomoneta (cacomoneta):**
> @jukan05 I would frame it differently. Since memory bandwidth is the limiting factor and memory is the most expensive and most supply constrained component for AI, compute is the critical factor that allows full utilization of the memory.
> _Thu Apr 30 23:36:02 +0000 2026_
>
> ---
>
> **@Cyber_lover2077 (Cyber):**
> @jukan05 Well, this can't go on forever, at one point the demand has to slow down
> _Fri May 01 00:29:33 +0000 2026_
>
> ---
>
> **@jamal7300 (jamal):**
> @jukan05 This is just an excuse to make more profits .I do not believe there is an actyt memory shortage anywhere .both mobile phone companies and RAM and memory manufacturers have invented this lie and excuse to generate extra profits.thats the crux of matter.
> _Fri May 01 11:22:29 +0000 2026_
>
> ---
>
> **@jamal7300 (jamal):**
> @jukan05 PC's and phones were becoming cheaper and they had to invent some lie to keep prices high and generate extra profits
> _Fri May 01 11:22:53 +0000 2026_

Source: [https://x.com/jukan05/status/2049847048690938030](https://x.com/jukan05/status/2049847048690938030)
