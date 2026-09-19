---
created: 2026-09-19
description: "Roy (@usr_bin_roygbiv), after four conversations about RTX PRO 6000 price increases, lays out why he expects Max-Q and Workstation RTX PRO 6000 Blackwells to be 'the single largest appreciating asset' of the next two years - 3-4 cards on a 20 A circuit, 3x a 5090's VRAM on the same die, NVFP4 tensor cores, four cards minimum for DeepSeek V4.1, no more being manufactured - and predicts $32-40K by 2027 and $100-120K at auction; verified 2026-09-19 the engineering claims hold (for the Max-Q), the supply/EOL claim has no public evidence, and eBay asks sit at or below the $15-16K retail price."
source: https://x.com/usr_bin_roygbiv/status/2101388935502946354
author: "@usr_bin_roygbiv"
type: post
tags: [local-inference, hardware, rtx-pro-6000, blackwell, pricing, depreciation, supply, roy, opinion-verified]
---

## Key Takeaways

- **The engineering half is right and matches the vault's own findings, with one lumping error.** The RTX PRO 6000 is the most inference throughput you can plug into a North American 120 V circuit: three to four Max-Q cards fit a 20 A circuit, the card carries three times a 5090's VRAM on the same GB202 die at the same 1.79 TB/s, it has NVFP4 tensor cores, and it drops into any machine with a PCIe slot. Four cards are indeed the minimum for DeepSeek V4.1 Flash, whose 307 GB backbone does not fit two ([[DeepSeek-V4.1-Flash runs at 200 tok-s on 4x RTX PRO 6000 Max-Q with only 64GB RAM because its 203GB Engram lives on NVMe - true for a 384GB-VRAM box, not for two cards]]). The error: the 600 W Workstation edition he names alongside the Max-Q needs 240 V at four cards; only the Max-Q fits his 120 V argument.

- **The supply claim is asserted, not evidenced.** "NVIDIA is not manufacturing more of them" and "no more are likely to be manufactured ever" have no public source: there is no NVIDIA end-of-life notice, NVIDIA's AI Enterprise lifecycle page (2026-09-09) still lists RTX PRO 6000 Blackwell as supported, and the press attributes the August price rise to GDDR7 memory costs rather than a production halt. His "10-100x fewer than 5090s" is an estimate. Retail thinning is visible, though: Central Computer slipped from in-stock to a 3-5 day ETA, B&H's PNY listing went temporarily out of stock, while B&H's NVIDIA-OEM Max-Q remained in stock at $15,999.

- **The price prediction is a position, and today's market does not price it.** Roy owns two of these cards. On the day of the post, eBay Buy-It-Now asks for the Max-Q ran $14,900 to $16,000 for new and open-box units, at or below retail, which is the opposite of a scarcity premium; a price tracker shows the Workstation edition up about 37% since mid-July (low $12,380, high $19,999). His $32-40K by 2027 and $100-120K at auction extend a real trend far beyond anything observed, and they assume no Rubin workstation card and no supply for two years. The vault's durability stance holds: resale above 50% is upside, not the plan, as argued in [[a 4K RTX 5090 will have a lower cost of ownership than a 1K RTX 3090 because Blackwell retains value - Roy's depreciation ranking with GB10 to zero]].

- **What the post does establish is direction and timing risk for a buyer.** Prices have only moved up since July, retail stock is thinning, and the cheapest boxed price rose $700 in nine days in September. For someone about to buy, that argues for buying both cards now rather than one now and one later, and against waiting weeks for a startup discount. The same conclusion Alex Ellis reached from watching his own card go from £8,500 to £16,000 in [[OpenFaaS bought 4x DGX Sparks as the explorer for privacy-first red-teaming with GLM-5.3 Flash at 30-75 tok-s and kept an RTX 6000 Pro as the attack dog - Alex Ellis on why unified memory wins capacity and GPUs win speed]].

- **His comparisons restate the CUDA-engine case.** Against the M5 Ultra: 49% more bandwidth, dedicated VRAM, NVFP4 and tensor-core ALU layout, so "never the same speed" even with perfect MLX kernels; against AMD: ROCm is behind MLX; against B300/DGX Station: NVIDIA's production is going to datacenter parts and the Station is priced off a pulled B300; against the RTX PRO 5000/5500: lower bandwidth. These are the same arguments as [[matmuls are parallel memory reads - Roy's bandwidth ladder puts a 1K RTX 3090 at 936 GB-s above a 5K Mac or DGX Spark, but it has no capacity or prefill column]] and [[buying local hardware isn't cope, it's a bet that open models beat the labs and that no more PCIe GPUs are coming - Roy's ownership thesis]], now with a price target attached.

## External Resources

- [NVIDIA AI Enterprise lifecycle: end-of-life notices](https://docs.nvidia.com/ai-enterprise/lifecycle/latest/eol-notices.html) - lists RTX PRO 6000 Blackwell as supported on the LTSB branch (2026-09-09); no product EOL.
- [TechSpot: Nvidia raises RTX Pro 6000 Blackwell price to $16,000](https://www.techspot.com/news/113460-nvidia-raises-rtx-pro-6000-blackwell-price-staggering.html) - the August 2026 list-price increase.
- [videocardprices.com RTX PRO 6000 tracker](https://videocardprices.com/card/nvidia-rtx-pro-6000-blackwell/) - daily price history since July 2026 and eBay used prices.
- [B&H: NVIDIA RTX PRO 6000 Blackwell Max-Q (OEM)](https://www.bhphotovideo.com/c/search?q=RTX%20PRO%206000%20Blackwell%20Max-Q) - $15,999, in stock on 2026-09-19.

## Original Content

> @usr_bin_roygbiv (Roy) - 2026-09-19
>
> I'm having 4 separate conversations with people today about rtx 6000 price increases so I wanted to make a post explaining my original reasoning and general ideas on pricing for 6000s in particular.
>
> I believe max q and workstation rtx pro 6000 blackwells will be the SINGLE LARGEST appreciating asset period the next two years.
>
> I have many reasons for this coming from years of buying used pc parts and laptops as well as following previous cycles personally, and using a lot of different inference hardware myself the last year or so.
>
> - They are the single most powerful gpu for inference aggregate tok/s you can run on north american 120v besides the dgx station which uses a whole circuit. You can run 3-4 on a 20A circuit.
> - They have triple the vram of 5090s with a binned version of the same chip, and the highest memory bandwidth for matmuls
> - nvfp4 and 4 bit precision tensor cores means highest flops of any silicon generally available on 6000 and 5090
> - You can slap them in any existing machine with an open pcie slot
>
> Why 6000s over 5090s then?
>
> Supply is way way lower, far fewer were manufactured somewhere on the order of 10-100x, they also have triple the vram on the same wattage. This means many models aren't runnable locally without them, and that unlock requires 4-8 of them for 750B models. 4 minimum for stuff like dsv4.1. New huawei chips china is targeting models for are 144-288gb, essentially reverse engineered h200s. Which is 3 6000s and the 6000s will be 2x faster than whats available in China while being more power efficient.
>
> Why 6000s over m5 ultra studios?
>
> Cuda and the tensor cores, also designated memory (not shared with os) and nvfp4 means higher speed and precision even if its the same memory on paper for a spec sheet. Even with perfect mlx kernels and if it was the same bandwidth (it's 50% higher than max spec m5 ultra) the gpus will never be the same speed for flops needed for inference because of the way the ALU is laid out on 5090/6000s.
>
> Why 6000s over h200/b200/b300 or dgx station?
>
> Nvidia is still manufacturing b300s, enterprise demand is all going to b300s and rubin which is what nvidia will focus 100% of their production on for likely the next 2 years minimum due to demand and economies of scale. Consumers are a tiny fraction of the market its not worth their time to serve. DGX stations will be tied to the price of ripping a b300 out of a node and rigging it up which is already cheaper when you look at the price of an 8x node compared to a dgx station.
>
> Why not AMD?
>
> CUDA and ALU layouts. Same as MLX but ROCm is in even worse shape. Even with perfect kernels on both compared with the same model and vram/bandwidth it won't be as fast for aggregate tps.
>
> Why not 5000 or 5500s?
> Lower memory bandwidth than 5090s and 6000s.
>
> Due to all of these unique comparisons and attributes, combined with the extremely limited supply, nvidia is not manufacturing more of them, has no incentive to manufacture more of them, while demand will continue to increase, and the general market of buyers able to utilize them, of which many have no other option for many models such as dsv4.1 to even run them locally (maybe h200s with fans or h170x which are also limited supply, but again significantly lower tps (1/2 most likely). They are 2x the speed for most of the options and have the perfect tax on second hand markets like ebay on top of the limited supply and the power efficiency and speed for actual real world usecases.
>
> I had originally modeled these to go to $32-40k by next year based on potential users and supply in north america, but I think this will happen far sooner now as supply is out at retailers in the next few weeks and no more are likely to be manufactured ever. I do not believe it is unreasonable to see them go to auction on ebay etc for $100-$120k late next year-early 2027 with current demand curves given the limited supply. This would be a 15x from their price in april.
>
> Because of the relative *perceived* niche of the topend prosumer market for manufacturing planning, contrasted against the real world market allowing basically all SMBs to run models a few weeks behind frontier locally with them on regular 120v power on any machine with a pcie slot at 2x the speed and half the power draw of any other option, (besides maybe m5 ultra which is still 33% slower) these have truly unique characteristics compared to any other card. Extremely high utility, extremely high TAM, and extremely high potential demand for what they're actually able to run twice as fast as any alternative for far more people. At the same time as all of this, they have the lowest or tied for lowest supply of any blackwell gpu.
>
> Do with this information what you want.
>
> Engagement: 6 likes | 0 retweets | 0 replies (at capture, 2026-09-19)
> [Original post](https://x.com/usr_bin_roygbiv/status/2101388935502946354)
