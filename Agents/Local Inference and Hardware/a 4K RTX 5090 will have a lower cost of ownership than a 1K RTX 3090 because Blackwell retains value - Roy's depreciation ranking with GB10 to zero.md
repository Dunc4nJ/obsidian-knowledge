---
created: 2026-09-01
description: Roy's (@usr_bin_roygbiv) resale-adjusted buying rule from July 2026 — cost of ownership is price minus what you sell it for, and Blackwell (native NVFP4, the MTP/DFlash drafters, and far fewer units in existence) will hold value over three years in a way a six-year-old Ampere card cannot, so a $4K RTX 5090 is cheaper to own than a $1K RTX 3090. His full ranking in the replies: PRO 6000 and 5090 hold, the 3090 "will go up if you hang on to it", and "gb10s to fuckin zero tho, dumpster fire." Half of it is already verified by the 2026 price history; the Spark half is not.
source: https://x.com/usr_bin_roygbiv/status/2073637052973797637
author: "@usr_bin_roygbiv (Roy)"
type: post
tags: [local-inference, hardware, rtx-5090, rtx-3090, rtx-pro-6000, dgx-spark, depreciation, resale, total-cost-of-ownership, buying-guide, opinion]
---

## Key Takeaways

> [!warning]- Dated context — posted 2026-07-05, captured 2026-09-01
> The RTX 5090 was ~$4,000 when this was written and is $4,300–5,000 now; the RTX PRO 6000 had just doubled ($9K in April → $14K by 2026-06-20, per Roy's own price log) and is $14–16K new; the used RTX 3090 was and is ~$820–1,050. The DGX Spark had its list price *raised* to $4,699 in Feb 2026 and shows no used discount as of September — the opposite of "to zero" so far. NVIDIA cancelled the RTX 50 Super refresh at Gamescom 2026 and has no Rubin workstation or consumer part before late 2027, which strengthens the scarcity half of his argument after the fact. Predates the M5 Ultra (2026-08-25) and GLM-5.3-Flash (2026-08-26). Evidence: `/data/projects/hardware/research/hw-nvidia.md` §2.2, §2.9; `pareto-durability.md` §(d)–(e); `roygbiv-profile.md`.

- **The rule is right in form: cost of ownership = purchase price minus resale, and resale tracks two things — memory on a toolchain that stays alive, and scarcity.** The research's durability history says the same: what died (P40, V100, MI50) died of software abandonment, what held value (3090, 4090 at +47–56% over launch MSRP four years on) held it on VRAM per dollar, and the 2026 shortage added a scarcity premium on top (used PRO 6000 within 2% of new; Roy: "there's simply way less of them"). Blackwell is the youngest CUDA architecture, has native FP4 and the drafters (DFlash2, MTP) that the fastest single-stream results in this folder all use, and will be in the toolchain to ~2034 by the Turing precedent. Verifiable so far: the 5090 has appreciated ~2x from MSRP; the 3090 has held ~$1K. His three-year claim is a forecast.

- **The 3090 is not the loser in his own ranking — "they'll go up if you hang on to it."** Asked whether to sell a 3090 after buying a 5090, he says keep it. That matters for the reading: the argument is *not* that Ampere is dead, it is that Blackwell's *speed features* (NVFP4 kernels, the drafters, 1.8 TB/s) plus scarcity give it the better resale curve, while the 3090 stays liquid because 24 GB of CUDA memory at ~$1K has no substitute. The research's counter-case — two used 3090s are the best $/(GB·TB/s) of any configuration and the only sub-$2.5K setup with an NVLink bridge — and Roy's case are both true; they answer different questions (capacity per dollar today vs speed per dollar and dtype longevity). [[matmuls are parallel memory reads - Roy's bandwidth ladder puts a 1K RTX 3090 at 936 GB-s above a 5K Mac or DGX Spark, but it has no capacity or prefill column|His own budget ladder]] still starts at "$1k, 3090."

- **"gb10s to fuckin zero" is the unsupported half.** As of September 2026 the DGX Spark has barely depreciated: NVIDIA raised its MSRP, street is $4,999–5,199, and the used market is dominated by new/open-box listings at or above list. His mechanism for the long run is plausible — a fixed 273 GB/s, a 2-year DGX OS support window, an sm_121 ISA that needs patched day-0 images, and an "RTX Spark"/N1X at ~$2.9K expected this fall that would undercut it — but the evidence today is flat resale, not collapse. Treat it as a prediction with a real mechanism and no data yet; [[two DGX Sparks run a 304B model at 40 TPS - install Tailscale first and every other non-obvious gotcha|the two-Spark field notes]] show what the box is actually good at meanwhile.

- **The reply that tests the claim: "~10% drop on 5090 = 50% drop on 3090."** Roy's answer is "no," with no math. In relative terms the objection has a point — a card that has doubled from MSRP has more room to fall when DRAM normalizes (late 2027–28 on current forecasts) than a card that never moved — and the home-lab research flags exactly this downside for any Blackwell purchase at shortage prices. The resolution is the workload: if the 5090's 2–3x speed (with a drafter) over a 3090 pair is used every day for three years, the resale delta is a rounding error; if the card sits, the 3090 was the safer store of value.

- **What survived into his later advice: buy the scarcer part.** By August he was telling people "6000s over 5090s originally [because] there's simply way less of them," predicting PRO 6000s "going to 40," and on 2026-09-01 "buy 6000s in the next 48 hours if you'd like to ever own one." The July post is where that reasoning starts — resale as a function of scarcity rather than performance — and it is the part of his buying advice the 2026 price history has most consistently rewarded.

## Roy's replies to commenters

- Follow-up to his own post: **"gb10s to fuckin zero tho dumpster fire"**
- To "Doubt. ~10% drop on 5090 = 50% drop on 3090. But who knows ;)": **"no"**
- To "I just bought a 5090 rig and I'm trying to decide what to do with my 3090. Sell it or keep it as a separate node?": **"they'll go up if you hang on to it and find something else to do with it in the mean time"**

## External Resources

- Original post: [@usr_bin_roygbiv, 2026-07-05](https://x.com/usr_bin_roygbiv/status/2073637052973797637)
- Research cross-reference: `/data/projects/hardware/research/pareto-durability.md` §(d) "What died, and why" and the ranked durable attributes; `hw-nvidia.md` §2.2 (Spark resale), §2.9 (Sept 2026 street prices); `roygbiv-profile.md` §3 Purchasing

## Original Content

> [!quote]- Full post (@usr_bin_roygbiv, 2026-07-05)
> Good point came up I hadn't posted about previously.
>
> Blackwell will likely retain value better over the next 3 years so a $4k 5090 will very likely have a lower cost of ownership than a $1k 3090.
>
> Engagement: 49 likes | 6 replies
> [Original post](https://x.com/usr_bin_roygbiv/status/2073637052973797637)

> [!quote]- Replies and Roy's answers (2026-07-05)
> @usr_bin_roygbiv (Roy) — date: Sun Jul 05 05:42:27 +0000 2026 · url: https://x.com/usr_bin_roygbiv/status/2073643651813573060
> gb10s to fuckin zero tho dumpster fire
>
> @AlgoRhythmEng (Algo "Rhythm" Engineer) — date: Sun Jul 05 07:05:08 +0000 2026 · url: https://x.com/AlgoRhythmEng/status/2073664459051000108
> #finance
>
> @gabu3d_pl (Gabu) — date: Sun Jul 05 08:26:42 +0000 2026 · url: https://x.com/gabu3d_pl/status/2073684986851463168
> Doubt.
> ~10% drop on 5090 = 50% drop on 3090
> But who knows ;)
> > @usr_bin_roygbiv (Roy) — date: Sun Jul 05 14:03:49 +0000 2026 · url: https://x.com/usr_bin_roygbiv/status/2073769824493113685
> > no
>
> @ZycieToMichal (ZycieToMichal) — date: Sun Jul 05 15:24:19 +0000 2026 · url: https://x.com/ZycieToMichal/status/2073790081131835410
> Hopefully prices retain, so those fkers with their overpriced rtx pro toys still won't even smell glm 5.2 (which is now running over 30 tps on sparks and seems to not stop there), unless they sell their cars and houses ;)
>
> @ZycieToMichal (ZycieToMichal) — date: Sun Jul 05 15:42:03 +0000 2026 · url: https://x.com/ZycieToMichal/status/2073794543552512381
> That is hilarious.
> 16k crap vs 50k PRO hardware, you must have hard times there, justifying your toys 🤣🤣🤣
>
> But hold tight guys, I'm pretty certain ur stuff won't devaluate ;) https://t.co/jyMOQKTQ8L
> (two screenshots attached, not captured)
>
> @JK99928789839 (JK999) — date: Sun Jul 05 16:31:39 +0000 2026 · url: https://x.com/JK99928789839/status/2073807029614088577
> I just bought a 5090 rig and I'm trying to decide what to do with my 3090. What would you do? Sell it or keep it as a separate node?
> > @usr_bin_roygbiv (Roy) — date: Sun Jul 05 20:55:43 +0000 2026 · url: https://x.com/usr_bin_roygbiv/status/2073873483101073550
> > they'll go up if you hang on to it and find something else to do with it in the mean time
