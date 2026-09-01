---
created: 2026-09-01
description: Ahmad Osman's "Apple might beat NVIDIA in Local AI if the latter doesn't change course," quote-tweeting Mike Bradley's Memory Performance Value per Dollar chart — (fast memory GB x bandwidth GB/s) / system price, normalized to DGX Spark = 1.00x. M5 Ultra 256GB wins at 3.26x, M5 Ultra 96GB 1.94x, M5 Max 128GB 1.29x, RTX PRO 6000 PC 1.23x, RTX 5090 PC 1.01x, DGX Spark 1.00x, Strix Halo 0.94x. The chart's own footer concedes it is "a memory-hosting value metric, not a direct tokens/sec benchmark" — it contains no compute, power, software, or concurrency term, its inputs are pre-launch MSRPs, and because it is a product of two quantities it rewards buying more boxes.
source: https://x.com/TheAhmadOsman/status/2092304330753810443
author: "@TheAhmadOsman (Ahmad), quote-tweeting @MikeBradleyAI (Mike Bradley)"
type: post
tags: [local-inference, hardware, mac-studio, apple-silicon, dgx-spark, strix-halo, rtx-pro-6000, memory-bandwidth, buying-guide, comparison, value-metrics]
---

## Key Takeaways

- **What the chart actually computes, and the numbers in it.** The metric is **(fast memory GB x memory bandwidth GB/s) / system price**, normalized so DGX Spark = 1.00x. Ranked: **M5 Ultra 256GB 3.26x** (256GB, 1,200 GB/s, $10,799), **M5 Ultra 96GB 1.94x** (96GB, 1,200 GB/s, $6,799), **M5 Max 128GB 1.29x** (128GB, 614 GB/s, $6,999), **RTX PRO 6000 PC 1.23x** (96GB, 1,792 GB/s, $16,000), **RTX 5090 PC 1.01x** (32GB, 1,792 GB/s, $6,500), **DGX Spark 1.00x** (128GB, 273 GB/s, $4,000), **Strix Halo 0.94x** (128GB, 256 GB/s, $4,000). "Fast memory only" — unified memory for Apple, Spark and Halo; GPU VRAM for the RTX systems, with system DDR5 excluded. Bradley's own claim is narrower than Osman's: Apple's MSRP "obliterated the value economics" at **2-3x+ the current economics** of Spark and Halo, and he expects the Studios to price *up* rather than the industry down. Osman's escalation to "**Apple might beat NVIDIA in Local AI**" is forecast, not measurement.

- **The chart disclaims itself, and the disclaimer is the whole argument.** Its own footer reads: "This is **a memory-hosting value metric, not a direct tokens/sec benchmark**." There is no compute term (the M5 Ultra's ~135 TFLOPS versus 4x Spark's ~300 in [[at 15-20K with 512GB the real gap is bandwidth not compute - Mac Studio M5 Ultra vs 4x DGX Spark vs 4x Ryzen AI Halo|the matched-price three-way comparison]]), no power term, no software term, and no concurrency term. Eric Hartford's reply is the one-line version — "**Um. What about tokens/sec per dollar**" — and two others land the same hit from the software side: "**MLX and poor concurrency performance is their big problem**" and "2x memory economics can disappear when **MLX lacks optimized kernels for the model**." That is precisely the [[buy the RAM that holds the model - a SKU-by-SKU M5 Mac guide with the CUDA tax and separate decode-prefill predictions|CUDA tax]] this folder already quantifies: NVFP4/MXFP4 have no Metal equivalent and MoE routing falls to slow paths, turning ~60 tok/s on a 4090 into ~35 on equal-bandwidth Apple silicon. A memory-hosting score cannot see any of that.

- **The sharpest structural critique: the metric is a product, so it inflates quadratically and it rewards buying more boxes.** @sdmat123: "Your metric presumptively gives a **quadratic increase in value over time from linear improvements in capacity and bandwidth**. And the assumption that **monoliths are drastically superior doesn't reflect the hardware choices of inference providers**." A reply demonstrates the gaming directly: "If I buy **two DGX Sparks, I get 256GB, 546GB/s, for $8000**... so your math ain't mathing." Run it — 256 x 546 / 8,000 = 17,472 against one Spark's 128 x 273 / 4,000 = 8,736 — and two Sparks score **2.00x**, jumping to second place, purely by doubling the box count. But the aggregation is only real under the conditions [[tensor parallelism aggregates memory controllers so 8x RTX PRO 6000 reaches ~14.3 TB-s where one M5 Ultra has 1.2|tensor parallelism]] requires: layer-sharded weights over an interconnect fast enough for a per-layer all-reduce. Under the pipeline parallelism two linked Sparks actually run, [[at 15-20K with 512GB the real gap is bandwidth not compute - Mac Studio M5 Ultra vs 4x DGX Spark vs 4x Ryzen AI Halo|four boxes still generate at one box's speed]]. So the reply is right that the metric is not scale-invariant and wrong that 546 GB/s is bandwidth you can spend on a single stream — and the chart, which has no interconnect term either, cannot tell the two cases apart.

- **The price inputs are contested, pre-launch, and the ranking is sensitive to them.** No M5 Ultra had been benchmarked when this was posted — "I'm puzzled to see your reaction **before any actual benchmark was run** on these machines"; "are those actual performance tests, **or just marketing comparisons**?" Meanwhile the losing row's price is disputed from both directions: "you can easily get a **strix halo for about $3000**, which changes significantly the table positions" (at $3,000 the Halo scores 1.25x and moves from last to roughly third), and from Europe, "a DGX Spark is about **5600e** and a 128 GB strix halo **2600e**, so you can get two halo for one spark." The MSRP asymmetry cuts the other way too — "recalculate using **original MSRP for nvidia**; these apple chips will sell out fast" and "**IF** Apple stays the price it says it will." Bradley agrees in the replies and forecasts the 512GB Ultra at ~1.25x per GB, "maybe **27.5k MSRP**," and Studios correcting upward 50% rather than the industry correcting down — the same unsourced per-GB price-hike forecast flagged in [[buy 2x 256GB Mac Studios instead of one 512GB - two boxes give 2x 1.2 TB-s parallel instances and can still be linked, but a 512GB box can never be split|his 2x256GB argument]].

- **What survives the objections is narrow but real, and it is a capacity claim.** Nothing in the replies disputes that 256GB of 1,200 GB/s unified memory at $10,799 is an unprecedented GB-x-bandwidth-per-dollar figure, or that no NVIDIA consumer product offers that much fast memory in one box — "Nvidia doesn't sell full blown computers," and the Spark, its nearest answer, "still needs more RAM." The honest reading is the one this folder keeps arriving at: **capacity decides whether a model runs at all, bandwidth decides how fast it decodes, and neither decides prefill, concurrency, or whether the kernels exist.** Osman himself published the counterweight three days later in [[tensor parallelism aggregates memory controllers so 8x RTX PRO 6000 reaches ~14.3 TB-s where one M5 Ultra has 1.2|the tensor-parallelism post]] — "capacity is not everything, utilizing that capacity matters" — and a reply here raises the axis neither post covers: whether the M5 "is capable of **training and fine tuning** models like an RTX PRO 6000 can." A related question also goes unasked in the thread: whether you need 256GB at all, given "Qwen 3.8 27B being a serious contender on a single GPU."

*Memory Performance Value per Dollar — (fast memory GB x bandwidth GB/s) / system price, DGX Spark = 1.00x, with the underlying spec table and the self-disclaiming footer:*
![[theahmadosman-810443-001.jpg]]

## External Resources

- Original post: [@TheAhmadOsman, 2026-08-25](https://x.com/TheAhmadOsman/status/2092304330753810443)
- Quoted source: [@MikeBradleyAI, 2026-08-25](https://x.com/MikeBradleyAI/status/2092303647589728504) — the chart and the value-economics argument
- Best counterpoint: [@sdmat123 on the metric's quadratic bias](https://x.com/sdmat123/status/2092738162095526303)
- Counter-thread: [@rise_raise_ai, "Apple's new M6 and M5 Ultra are excellent chips. They are not, however, the beginning of the end for NVIDIA."](https://x.com/rise_raise_ai/status/2092265291111641206)
- Systems in the chart: Apple Mac Studio M5 Ultra / M5 Max · NVIDIA DGX Spark, RTX PRO 6000 (96GB, 1,792 GB/s), RTX 5090 (32GB, 1,792 GB/s) · AMD Strix Halo (Ryzen AI Max, 128GB)

## Original Content

> [!quote]- Full post (@TheAhmadOsman, 2026-08-25)
> In other words, Apple might beat NVIDIA in Local AI if the later doesn't change course
>
> *Memory Performance Value per Dollar — the chart Osman re-attached from the quoted post:*
> ![[theahmadosman-810443-001.jpg]]
>
> QT @MikeBradleyAI:
> > The MSRP of the new M5 Ultra Studios from Apple have completely obliterated the value economics for most consumer AI systems when measured as:
> >
> > (model hosting memory)x(memory speed)/(cost of system)
> >
> > Memory size and speed per dollar is off the charts (2-3x+ the current economics of the DGX Spark and Strix Halo) and I'd feel very confident assuming these 1.5x from MSRP very quickly.
> >
> > The other systems won't get cheaper so the only path for these studios is to price up into their market value. Much like the M5 laptops did.
> >
> > There's PLENTY to debate on what hardware works for you. But the economics of this initial offering are quite wonderfully broken ATM.
>
> [Original post](https://x.com/TheAhmadOsman/status/2092304330753810443) · [quoted post](https://x.com/MikeBradleyAI/status/2092303647589728504)

> [!quote]- Chart contents, transcribed
> **Memory Performance Value per Dollar** — Fast memory capacity x memory bandwidth / system price. Normalized to DGX Spark = 1.00x.
>
> | System | Fast Memory | Bandwidth | Price | GB x GB/s | DGX = 1.0x |
> | --- | --- | --- | --- | --- | --- |
> | M5 Ultra 256GB | 256GB | 1,200 GB/s | $10,799 | 307,200 | 3.26x |
> | M5 Ultra 96GB | 96GB | 1,200 GB/s | $6,799 | 115,200 | 1.94x |
> | M5 Max 128GB | 128GB | 614 GB/s | $6,999 | 78,592 | 1.29x |
> | RTX PRO 6000 PC | 96GB | 1,792 GB/s | $16,000 | 172,032 | 1.23x |
> | RTX 5090 PC | 32GB | 1,792 GB/s | $6,500 | 57,344 | 1.01x |
> | DGX Spark | 128GB | 273 GB/s | $4,000 | 34,944 | 1.00x |
> | Strix Halo | 128GB | 256 GB/s | $4,000 | 32,768 | 0.94x |
>
> Value metric = (Fast Memory GB x Bandwidth GB/s) / System Price
>
> Footer: "Fast memory only. Unified memory is used for Apple, DGX Spark, and Strix Halo. GPU VRAM is used for RTX systems. System DDR5 is excluded for discrete GPU PCs. This is a memory-hosting value metric, not a direct tokens/sec benchmark."

> [!quote]- Substantive replies on Osman's post
> @mugenflying (FlyingMugen) — 2026-08-25:
> If I buy two DGX Sparks, I get 256GB, 546GB/s, for $8000... - so, your math ain't mathing...
>
> @Authentic1ty (Scott Jordan) — 2026-08-26:
> MLX and poor concurrency performance is their big problem.
>
> @JFPuget — 2026-08-26:
> I'm puzzled to see your reaction before any actual benchmark was run on these machines.
>
> @PeasantSmith (Peasant Smith) — 2026-08-29:
> That value table is fundamentally wrong, you can easily get a strix halo for about $3000 which changes significantly the table positions
>
> @petruspennanen (Petrus Pennanen) — 2026-08-25:
> Weird prices though. Here in Europe a DGX Spark is about 5600e and a 128 GB strix halo 2600e. So you can get two halo for one spark instead of same price as in your list.
>
> @lucidpaths33 (lucid) — 2026-08-25:
> I got my strix halo 128gb for €3.3k. And isnt dgx spark $4.5k by now?
>
> @PhilaSzn (Liam) — 2026-08-25:
> recalculate using original MSRP for nvidia. these apple chips will sell out fast
>
> @jani_lupo (jani) — 2026-08-26:
> IF apple stays the price it says it will.
>
> @robertreed_ai (Robert Reed) — 2026-08-26:
> Cuda
>
> @KyleHessling1 (Kyle Hessling) — 2026-08-25:
> V100??
> > QT: With Qwen 3.8 27B being a serious contender on a single GPU, I am weighing whether the new Apple hardware with massive allocations of high-bandwidth memory is even necessary for most local AI users over a much more affordable GPU rig. Don't get me wrong, the New M5 Ultra looks [...]
>
> @rise_raise_ai (Rise-Raise) — 2026-08-25:
> Don't disturb the king!
> > QT: Apple's new M6 and M5 Ultra are excellent chips. They are not, however, the beginning of the end for NVIDIA.
>
> @99Oatz (Xar) — 2026-08-25:
> I think the dg sparks were thier answer? Still needs more ram
>
> @john14612115712 (João) — 2026-08-25:
> Besides Nvidia doesn't sell full blown computers
>
> @iamshadmantaqi (Shadman Taqi) — 2026-08-25:
> but you have to factor in, for that price, you are getting only 1 tb of space
>
> @WorldStrategist (Eric X) — 2026-08-25:
> No, it's just a matter of cost. Nvidia is charging so much. But Apple too. Everybody is using the rampocalypse as excuse to charge Galactic amounts of money. Let's wait for a couple of years for these new RAM factories to get up to speed. Then we can buy solid equipment for a decent price again.
>
> @Ydf_189 (ask_know) — 2026-08-25:
> Xiaomi is entering the race, too, by a Mini-PC with 128GB RAM & up to 1,22TB/s Bandwidth.

> [!quote]- Substantive replies on Bradley's quoted post
> @sdmat123 (sdmat) — 2026-08-26:
> You metric presumptively gives a quadratic increase in value over time from linear improvements in capacity and bandwidth. And the assumption that monoliths are drastically superior doesn't reflect the hardware choices of inference providers.
>
> @QuixiAI (Eric Hartford) — 2026-08-26:
> Um. What about tokens/sec per dollar
>
> @sebuzdugan (Sebastian Buzdugan) — 2026-08-26:
> 2x memory economics can disappear when mlx lacks optimized kernels for the model
>
> @b_o_f_h_ (beencoerced) — 2026-08-26:
> are those actual performance tests, or just marketing comparisons?
>
> @UrbanAstroFella (AstroFella) — 2026-08-25:
> It also heavily depends on when one bought into local. For latecomers, M5 makes a whole lot of sense and MLX is catching up to CUDA. My 2X RTX6KQ system on WRX80/DDR4/5955 cost about $17.5k net, very under current market price. The upcoming 512GB M5 is really appealing to me. The big question is whether M5 is capable of training and fine tuning models like an RT6K can? Economics of everything is super broken and jagged lol
>
> @MikeBradleyAI, replying about the 512GB SKU — 2026-08-25:
> My bet is, they'll be like 1.25x as much per GB by then. Maybe 27.5k MSRP?
>
> @MikeBradleyAI, on a market correction — 2026-08-25:
> Yes. I fear more likely is the Mac Studios correct upwards by 50% than the rest of the industry being pushed down. But I'd love to be surprised. I think Apple knows exactly what they are doing pricing this first tranche / release this way.
>
> @MikeBradleyAI, on which models to run — 2026-08-25:
> Dawson gave you a great answer. At 1.2TB/s anything that fits should be fine.
>
> @joaosump (Vieirowski) — 2026-08-25:
> And power consumption is not even in the equation. No brainer
>
> @kostasbotonakis (Konstantinos) — 2026-08-25:
> And those apple prices are also priced up already recently
