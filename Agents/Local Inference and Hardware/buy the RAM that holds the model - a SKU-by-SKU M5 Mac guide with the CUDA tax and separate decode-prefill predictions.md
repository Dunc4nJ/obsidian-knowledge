---
created: 2026-08-27
description: Yume_X's SKU-by-SKU buying guide for the M5 Mac line as local-AI hardware — the four different upgrades Apple sells under one word ("AI"), the rule that you buy the memory that holds the model (minus 8-12GB macOS eats first), a skip list of chips starved of memory, per-SKU model fit from the 48GB mini to the 512GB Ultra, the used-market comparison (4090/3090/DGX Spark at the same money), the "CUDA tax" of running CUDA-first weights through MLX/Metal ports, and an explicit methodology for predicting decode and prefill separately — including a correction of a widely-shared 120 tok/s figure that misapplied a prompt-processing multiplier to decode.
source: https://x.com/yume_arasaki/status/2092767101039898681
author: "@yume_arasaki (Yume_X)"
type: article
tags: [local-inference, hardware, mac-studio, apple-silicon, memory-bandwidth, buying-guide, mlx, quantization, prefill, moe]
---

## Key Takeaways

> [!warning]- Fact-check (2026-09-01, home-lab research) — two numbers in this guide do not survive verification
> - **"Contra Collective measured 70B Q4 on M5 Ultra at 21.1 tok/s single-die, 27.3 with TP=2" — REFUTED.** Both Contra Collective M5 Ultra articles were fetched in full; the strings `21.1`, `27.3`, `TP=` and `single-die` do not appear. The article is dated 2026-04-08, four months before the chip existed, describes it as "192 GB, ~800 GB/s" (wrong on both), and contradicts its sibling article (1,400 GB/s). Treat Contra Collective as fabricated. As of 2026-09-01 **no measured M5 Ultra LLM benchmark exists anywhere** (it ships 2026-09-22; llama.cpp discussion #4167 lists its rows empty).
> - **"The M3 Ultra 512GB dropped from being worth $20,000 to $3,000 overnight" — REFUTED by 6–8×.** A week after the M5 Ultra launch, M3 Ultra 512 GB units list at $17,000–$28,000 on eBay and Swappa's average *sold* price is $18,136 (4 TB) / $19,311 (8 TB) — versus a $9,499 original price. High-memory Mac Studios are *appreciating* because of the 2026 DRAM shortage (Apple withdrew the 512 GB M3 Ultra option in March 2026).
> - Still holds: M3 Ultra V4-Flash ~35 tok/s (antirez/ds4: 36.9 q2 / 35.5 q4). Note the q2→q4 gap is only 3.7% despite ~2× the routed-expert bytes — MoE decode on Ultra parts is gather/overhead-bound, not bandwidth-bound, which is why utilization sits at ~28–45%.
> Full evidence: `/data/projects/hardware/research/hw-apple.md` §2.4–2.8.

- **The organizing rule, and the disclaimer that comes with it: "buy the memory that holds the model. The chip name only tells you how fast it streams once it fits" — and macOS eats 8-12GB before your model loads.** Every advertised RAM number needs that subtraction (plus whatever your browser is holding), which is what turns a 32GB M6 into ~20GB usable and makes it "slower and smaller than a $1,275 GPU card." The opening warning frames the whole piece: the M3 Ultra 512GB "dropped from being worth $20,000 to being $3,000 overnight" — buy for the models you'll actually run, not for residual value.

- **Apple sells four different upgrades under one word, and they fix different waits.** (1) **Neural Accelerators** — matrix units in every GPU core; all of Apple's 3.9-4.8x claims are **prefill**, not generation. This is the agent-relevant upgrade: the author's 8K system prompt costs ~80 seconds of silence before the first token on an M4 Pro, dropping to ~20s. (2) **Bandwidth** — generation speed, and the increases are modest (+12% Pro/Max, +42% mini) except the **M5 Ultra at 1.2 TB/s (+47%)**, "the only bandwidth jump that changes class." (3) **Capacity** — ceilings *unchanged* at 32/64/128/512GB. (4) Everything else (SSD, TB5 clustering, Wi-Fi 7). The summary line is the best mental model in the piece: *"Neural Accelerators shorten the wait before the first token. Bandwidth shortens the wait after it. RAM decides if the model is even there."* — the prefill/decode split of [[Step 01 - Decode is memory-bandwidth-bound (the roofline)|the roofline]], mapped onto a purchase decision, with [[LMCache offloads paged KV to system RAM and NVMe, cutting 128K-context time-to-first-token from 68 seconds to 1.4 on 4x DGX Spark|KV offloading]] as the software attack on the same prefill wall.

- **The "CUDA tax" is the caveat most Mac buying guides omit.** Frontier open weights are built and optimized CUDA-first; on Apple silicon via MLX or llama.cpp "the kernels are ports, not native." Quantization formats that fly on Blackwell tensor cores (**NVFP4, MXFP4) do not exist on Metal**, and MoE expert routing NVIDIA spent years tuning "hits generic fallback paths." Concretely: *a model at 60 tok/s on a 4090 might run 35 on a Mac with the same bandwidth* — not a hardware deficit but a software one, closing as MLX matures. Practical form: "day-one Mac numbers will be slower than the Twitter receipts."

- **The prediction methodology is the transferable part — decode and prefill scale on different axes, and MoE breaks the decode rule.** *Decode scales with bandwidth*: M3 Ultra ran V4-Flash at 35 tok/s on 819 GB/s, so 1200/819 = **1.47x** → ~40-50 tok/s on the M5 Ultra. *Prefill scales with the compute multiplier*: ~4x → ~1,300-1,800 prefill tok/s, "the Ultra's real new product." The crucial asymmetry: **dense models reach 70-90% of theoretical bandwidth, but MoE hits only ~28%** because routing to scattered experts across 284B of weights defeats memory-controller pipelining — the quad-die's extra controllers are exactly the hardware that might improve this. He also explicitly corrects a viral number: a widely-shared 120+ tok/s figure "is a prompt-processing multiplier misapplied to decode." Keeping those two multipliers separate is the analytical discipline worth stealing.

- **The SKU verdicts: skip anything memory-starved; the class breaks are 64GB, 128GB, and 256GB.** *Skip* — 16/24/32GB M6, 24GB M5 Pro, 36/48GB Max (no 70B), and notably **96GB Ultra ($5,499)** where V4-Flash Q4 doesn't fit and the same money buys Max 128GB. *Buy* — **M5 Pro 64GB ($2,699)** as the cheapest Apple 70B and a good fleet orchestrator; **Max 64GB ($3,499)** as the fastest 70B without going to 128GB; **Max 128GB ($5,099)** lands in the same awkward spot as a single DGX Spark (you're pushed to 2-bit, and "2-bit has too much loss vs the 4-bit versions"); **Ultra 256GB ($9,499)** is the V4-Flash-Q4 machine and the first box holding two frontier MoEs at real quants; **Ultra 512GB (late Oct, est. $15-19K)** is the GLM-5.2-4bit machine — capacity, not speed (K3 at up to 3 tok/s is "a load demo, not a daily model"). Against the used market at the same money: a $2,500 4090 beats every Mac here on raw 27B but can't touch 70B; two $1,275 3090s hold 70B and decode faster than any 64GB Mac; **two DGX Sparks with DSpark hit 61 tok/s on V4-Flash — a $9,400 pair matching a $10,800 Ultra on decode**, with the Ultra winning bandwidth headroom, silence, and one-box simplicity. That last comparison is the direct bridge to [[at 15-20K with 512GB the real gap is bandwidth not compute - Mac Studio M5 Ultra vs 4x DGX Spark vs 4x Ryzen AI Halo|the matched-price Mac-vs-Spark-vs-Halo comparison]] and to [[buy 2x 256GB Mac Studios instead of one 512GB - two boxes give 2x 1.2 TB-s parallel instances and can still be linked, but a 512GB box can never be split|the 2x256GB optionality argument]] — and quantization moves every one of these fit lines, per [[EXL3 3-bit plus an 18.5 percent expert prune runs DeepSeek-V4-Flash 284B at 47 tok-s on 4.7K of hardware|3-bit plus expert pruning]].

*The full M5 preorder map — four upgrades, the skip list of starved chips, per-SKU model fit with usable RAM after macOS, used-market equivalents, and the CUDA tax footer:*
![[yume-mac-guide-001.jpg]]

## External Resources

- Original article: [Should you preorder the new Mac for local AI? — @yume_arasaki, 2026-08-27](https://x.com/yume_arasaki/status/2092767101039898681) (sources in reply)
- Models referenced: DeepSeek-V4-Flash · GLM-5.2 / GLM-5.3-Flash (320B/18B active, MIT) · Qwen 3.8-Flash-Next · Kimi K3 · Orinth 1.5 35B MoE
- Measurements credited: DwarfStar (native Metal kernels; V4-Flash Q2 at 34 short / 26 long), Contra Collective (70B Q4 on M5 Ultra at 21.1 single-die, 27.3 with TP=2), Youssofal (58.7 sustained), Viticci, MacStories (K3 on a single 512GB Studio at up to 3 tok/s)

## Original Content

> [!quote]- Full X Article — "Should you preorder the new Mac for local AI?" (@yume_arasaki, 2026-08-27)
> Should you preorder the new Mac for local AI?
>
> Be careful about hype vs reality, because in one day the Mac Studio M3 Ultra 512GB dropped from being worth $20,000 to being $3,000 overnight.
>
> I researched every tier of the new Mac mini and Mac Studio so you do not have to. Every RAM SKU, what actually loads, predicted speeds with MTP, and what the same money buys used this week. 
>
> I also forward-predicted what you will be able to run once Qwen 3.8 Flash Next and GLM-5.3-Flash land on local stacks, both released today with no Mac benchmarks yet. 
>
> I run the daily 27B on a Mac mini M4 Pro 64GB at 27 tok/s (MTP), so the small boxes are measured against a real desk experience.
>
> Rule of thumb: buy the memory that holds the model. The chip name only tells you how fast it streams once it fits. 
>
> REMEMBER it's called "unified memory" : macOS eats 8-12GB before your model loads, so subtract that from every RAM number. Every userspace, every chrome instance that runs on the computer will EAT your memory.
>
> WHAT APPLE IS ACTUALLY SELLING
>
> Four different upgrades under one word, AI.
>
> 1. Neural Accelerators in every GPU core. Matrix units inside the GPU that speed up prefill (time to first token). Apple's 4.8x (M6 vs M4), 3.9x (M5 Max vs M4 Max), 4.0-4.3x (M5 Ultra vs M3 Ultra) are all prefill, measured in LM Studio prompt processing. My M4 Pro takes ~80 seconds of dead silence before the first token on an 8K system prompt. Neural Accelerators are the fix. If you run agents with real system prompts, this is the upgrade that matters more than the bandwidth number.
>
> 2. Memory bandwidth. Generation speed. M6 Mini 170 GB/s (+42% vs M4). M5 Pro 307 (+12% vs M4 Pro). M5 Max 40-core 614 (+12% vs M4 Max). M5 Ultra 1.2 TB/s (+47% vs M3 Ultra). Not 4x. The Ultra is the only bandwidth jump that changes class.
>
> 3. Unified memory capacity. Apple did not raise these ceilings. M6: 32GB. M5 Pro: 64GB. M5 Max: 128GB. M5 Ultra: 512GB. They restocked high-RAM options after this year's memory cuts.
>
> 4. Everything else. Faster SSD (model load, not tok/s). Thunderbolt 5 clustering (prefill gains, decode can go backwards). M5 Ultra is Apple's first quad-die at 4.4 TB/s inter-die. Wi-Fi 7, Bluetooth 6.
>
> Neural Accelerators shorten the wait before the first token. Bandwidth shortens the wait after it. RAM decides if the model is even there.
>
> USED MARKET
>
> Street prices Aug 25-26. 
>
> Used 4090 ~$2,500 (24GB, 1008 GB/s). Wins raw 27B speed against every Mac here, cannot touch 70B. 
>
> Used 3090 ~$1,275, two at ~$2,550 hold 70B and decode faster than any 64GB Mac. Loud. 
>
> DGX Spark $4,699 list (128GB, 273 GB/s). Two Sparks with DSpark speculative decoding hit 61 tok/s on V4-Flash, competitive with the Ultra 256GB. A year-old $9,400 pair matches a $10,800 Ultra on decode. The Ultra wins on bandwidth headroom.
>
> THE CUDA TAX
>
> Most frontier open-weight models are built and optimized for CUDA first. When they land on Apple silicon via MLX or llama.cpp, the kernels are ports, not native. Quantization formats that fly on Blackwell tensor cores (NVFP4, MXFP4) do not exist on Metal. MoE expert routing that NVIDIA spent years tuning hits generic fallback paths on the Mac.
>
> A model that runs at 60 tok/s on a 4090 might run at 35 on a Mac with the same bandwidth, not because the hardware is worse but because the software was not written for it. MLX is getting better fast, DwarfStar writes native Metal kernels, and the gap is closing. 
>
> SKIP THESE
>
> Overpaying for a chip and starving it of memory.
>
> - 16GB M6 · $899 — 8B only. 27B will not load.
> - 24GB M6 · $1,099 — 27B knife edge, long context will not fit. Pay $200 more.
> - 32GB M6 · $1,299 — ~20GB usable after macOS. A used 3090 has 24GB dedicated VRAM at 936 GB/s, this has 20GB shared at 170 GB/s. Slower and smaller than a $1,275 GPU card. Not a local-model machine.
> - 24GB M5 Pro · $1,699 / $1,899 — same problem, faster pipe that cannot help.
> - 36GB Max Studio · $2,499 — no 70B. Same price as a used 4090, less pipe.
> - 48GB Max Studio · $3,099 — still no 70B. 40-core GPU starved.
> - 96GB Ultra · $5,499 / $6,799 — V4-Flash Q4 does not fit. Same money buys the Max 128GB.
>
> THE REAL AI COMPUTERS
>
> Mac mini M5 Pro 48GB · $2,299 / $2,499
>
> 27B comfortable (~36GB usable). Predicted ~55-65 tok/s with MTP. Buy it if 27B is the forever default and you want a small always-on box. If 70B is on your horizon, spend the next $400.
>
> I'd go with the RTX 3090/4090 second hand here really. The Ampere chips have excellent compute, and CUDA's ecosystem, offload to system ram for video models. You might as well just pay $400 more here to get to 64GB.
>
> Mac mini M5 Pro 64GB · $2,699 / $2,899
>
> 70B Q4 tight (~52GB usable, context eats headroom). Predicted ~30 tok/s on 27B base, ~55-65 with MTP. 70B Q4 ~9-17. 
>
> The honest upgrade from my M4 Pro 64GB: decode will not feel new (+12% bandwidth), but prefill will. My 80-second wall before the first token on 27B dense becomes ~20 seconds with Neural Accelerators. 
>
> A clean pick for a fleet orchestrator, run 1-2 small models at decent speed. Like the Qwen 3.8 27b Dense or the Orinth 1.5 35B Moe
>
> Mac Studio M5 Max 64GB · $3,499
>
> Fastest way to hold 70B without going to 128GB. 
>
> 614 GB/s pipe, way better prefill when you paste. Predicted ~58-70 tok/s on 27B with MTP (Youssofal timed 58.7 sustained on the same chip). 70B Q4 ~9-17. Buy it if 70B is the goal and you will not spend up to 128GB.
>
> Mac Studio M5 Max 128GB · $5,099
>
> If you want frontier level, this machine will just miss it.
>
> 70B with real context. V4-Flash Q2 (80-91GB) fits with room, DwarfStar already measured 34 short / 26 long. Q4 at ~153GB does not fit. Orinth 1.5 35B MOE will run at easy 80 tok/s and massive concurrency.
>
> I think this one lands on the weird space a single DGX Spark lands on. You have to go to 2-bit for the models you really want. (DSV4F, Qwen 3.8 Flash, GLM 5.3 Flash), and
>
> Honestly 2-bit has too much loss vs the 4-bit versions. 
>
> Mac Studio M5 Ultra 256GB · $9,499 / $10,799
>
> The V4-Flash Q4 machine, and MoE is where the quad-die earns its money.
>
> V4-Flash Q4 predicted 40-50 tok/s base, 60-80 with MTP. Base scaled from Viticci's 35 and DwarfStar's 35.5/26.6 on the M3 Ultra, times 1200/819 (1.47x). Not 120. Viticci's 120+ is a prompt-processing multiplier misapplied to decode. 
>
> Two Sparks with DSpark already hit 61 on the same model. If MTP on the Ultra closes that gap, this box pulls ahead to 80 tok/s.
>
> GLM-5.3-Flash (320B/18B active, released today, MIT) should fit here at Q4 with ~244GB usable, making this the first box that holds two frontier MoEs at real quants. No Mac benchmarks yet. GLM-5.2 at 4-bit (~466GB) does not fit. 27B and 70B will fly here but that is not why you spend this. 
>
> Mac Studio M5 Ultra 512GB · late October · predicted $15,000-$19,000 at 36/80 (1TB)
>
> GLM-5.2 4-bit machine (~466GB, fits with ~500GB usable). K3 Q1_0 at 466GB also fits. MacStories confirmed K3 on a single 512GB Studio at up to 3 tok/s. Every K3-on-Mac speed is a load demo, not a daily model.
>
> GLM-5.2 4-bit predicted 18-28 tok/s, scaled from M3 Ultra numbers (12-19 tok/s) times 1.47x. Buy this for the mid 20s. I think when everything else is combined it probably hits 40 tok/s for 4 bit on GLM 5.2
>
> Qwen 3.8-Flash-Next also fits here easily and should be extremely fast with all that headroom.
>
> HOW I PREDICTED THE ULTRA
>
> Decode scales with bandwidth. Prefill scales with the compute multiplier. I predicted them separately.
>
> Decode. M3 Ultra ran V4-Flash at 35 tok/s on 819 GB/s. M5 Ultra runs 1.2 TB/s. 1200/819 = 1.47x, so V4-Flash Q4 lands at ~51 short, ~39 long. Dense models hit 70-90% of theoretical bandwidth (Contra Collective measured 70B Q4 on M5 Ultra at 21.1 single-die, 27.3 with TP=2). MoE is different: V4-Flash routes to scattered experts across 284B of weights, so the memory controller cannot pipeline reads efficiently. M3 Ultra hits ~28% of theoretical on V4-Flash. 
>
> The M5 Ultra's quad-die has more memory controllers across four dies, which is exactly the hardware that helps scattered MoE reads. The 40-50 base prediction uses 28%. If the quad-die improves MoE efficiency, the real number beats 50.
>
> Prefill. Apple's 4x vs M3 Ultra and Viticci's 4.4x on the M5 iPad are the anchors. M3 Ultra V4-Flash prefill was ~449 tok/s. 4x that is ~1,300-1,800 prefill tok/s. That is the Ultra's real new product.
>
> Software caveat. These predictions assume MLX on the M5 Ultra achieves M3 Ultra-level bandwidth utilization. Contra Collective's 70B receipt shows the stack works on the quad-die. But MoE kernels on day one could be less mature. If the launch number is below 40, check back after one MLX update.
>
> Think hard before buying into the hype. You do not want to end up like the people who were told "buy the 512GB M3 Ultra Mac Studio and run Kimi K2.5" and then it ran at 10 tok/s with the CUDA tax on top. 
>
> Buy the RAM that holds the model you will actually use, at the speed you can actually live on.
>
> Do not buy local AI hardware with the expectation that the value will hold, buy it because you thought long and hard about what models you will want to run.
>
> Sources in reply 👇
> *(M5 preorder map — embedded above)*
