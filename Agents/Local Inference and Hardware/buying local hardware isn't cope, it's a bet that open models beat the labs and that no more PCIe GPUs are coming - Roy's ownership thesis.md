---
created: 2026-09-01
description: Roy's (@usr_bin_roygbiv) one-sentence case for owning GPUs at home, posted three days after GLM-5.3-Flash — not "the API is expensive" (he explicitly says models are getting cheaper and faster to serve) but a two-legged bet that open-weights models will overtake what an API sells you "in the near future" and that consumer/workstation PCIe GPUs are a shrinking supply. His follow-up is the sharper half: "Parameter count is no longer scaling performance, it's all kernel dev and efficiency. People serving at scale have no incentive to optimize for single user performance" — which is the one thing a home rig with idle compute can do that a provider will not. Same thread: "mac studio is good."
source: https://x.com/usr_bin_roygbiv/status/2093750600131375529
author: "@usr_bin_roygbiv (Roy)"
type: post
tags: [local-inference, hardware, buy-vs-rent, ownership, open-weights, gpu-supply, rtx-pro-6000, kernels, speculative-decoding, opinion]
---

## Key Takeaways

> [!warning]- Dated context — posted 2026-08-29, captured 2026-09-01
> Written in the week GLM-5.3-Flash (2026-08-26, AA 57 — Opus 4.8's score — in ~200 GB at 4-bit) and Qwen3.8-Flash-Next shipped, after the M5 Ultra announcement (2026-08-25) and after the mid-2026 doubling of RTX 5090 and RTX PRO 6000 street prices; two days later Roy posted "I recommend you buy 6000s in the next 48 hours if you'd like to ever own one." The quoted post (@teortaxesTex, "Subscription chads winning…") is the position he is answering. "They aren't making any more PCIe GPUs" is his reading of the cancelled RTX 50 Super refresh and the absence of any Rubin workstation part before late 2027 — both verified in the home-lab research. Evidence: `/data/projects/hardware/research/00-synthesis.md` §1.4–1.5, `pareto-durability.md` §(e), `hw-nvidia.md` §2.9, `roygbiv-profile.md`.

- **The thesis is an option, not an arbitrage — and he says so when pushed.** Local hardware pays off if (a) open models get "better/faster than what is available on an api" for a single user and (b) the hardware to run them stops being purchasable. When a replier argued "we are in the honeymoon period of subs and api costs, they will only go up," Roy disagreed: "models are getting significantly cheaper and faster to serve, hardware will go up though." That aligns with the research's breakeven (a $10K box needs ~273M GLM-5.3 tokens a month against the API; the GLM Coding Plan starts at $18) — the economics do not justify the box, and Roy is not claiming they do. What justifies it is the same list the research uses — privacy ("ASI running unobstructed on a VPN locally," in his 08-12 phrasing), unmetered loops, uncensored weights, ownership — plus the two legs of this bet.

- **Leg (a) has a measurable gap and a measurable rate.** Verifiable: on Artificial Analysis v4.1.1 the best open weights (GLM-5.3, Kimi K3) sit at 60 against Claude Opus 5 at 63, and Roy's own 08-26 observation is that "mid size models are 2 months behind, full size 1 month, smol models (27b, 30b) 4 months behind pretty consistently now." Opinion: that "a bunch of autistic and/or chinese people will beat the western labs." The research's version is Curve C — the memory needed to reproduce a fixed intelligence level halves every ~2.5–4 months — which is the same claim from the hardware side: buy for today's target and the frontier comes to you. [[GLM-5.3-Flash hits 57 on the AA intelligence index at 4.5 cents per task - but that Pareto point is a discounted launch price|The Flash Pareto note]] is the current data point.

- **Leg (b) is verified today and is the actual reason his timing calls exist.** RTX 50 Super cancelled (Gamescom 2026, 3 GB GDDR7 reserved for AI parts); no Rubin workstation or consumer part before late 2027; RTX PRO 6000 $8.5K → $13–16K and RTX 5090 $2K → $4.3–5K in the 2026 DRAM shortage; used PRO 6000s selling within 2% of new. Roy dated the spike in real time (04-22 "the smartest people I know are texting me to buy gpus" → 06-20 "6000 pros are up to $14k from $9k two months ago") and has called PRO 6000s "going to 40." The research's durability history says the same thing more cautiously: what held value was memory on a toolchain that stayed alive, and CUDA/Blackwell will stay alive to ~2034. [[a 4K RTX 5090 will have a lower cost of ownership than a 1K RTX 3090 because Blackwell retains value - Roy's depreciation ranking with GB10 to zero|His depreciation ranking]] is the same bet applied per SKU.

- **The follow-up sentence is the best single argument in his whole account for a kernel-and-inference engineer.** "Parameter count is no longer scaling performance it's all kernel dev and efficiency. People serving at scale have no incentive to optimize for single user performance." Providers batch dozens of streams per GPU; a home user is the only stream, so speculative decoding, DFlash2 drafters and custom kernels convert idle compute into single-stream speed nobody will sell you — his own 2x RTX PRO 6000 decode GLM-5.3-Flash at 300+ tok/s against 50–100 on hosted routes, and he thinks the card's ceiling is ~650. The research's measured utilization for big MoE on discrete GPUs (20–45% of bandwidth) is the size of that headroom. If the owner intends to do that work, the box is also the workbench; if not, the argument does not apply.

- **"Mac Studio is good" — his answer to "people would buy local hardware if there was any."** Same thread, same day: when the objection is supply, the anti-Mac-for-LLM voice points at the M5 Ultra ([[the anti-Mac guy calls the M5 Ultra an insane deal - 5x the bandwidth and 2x the RAM of a DGX Spark for 2x the price, as an agent host not a fast decoder|captured separately]]). Read together with "buy 6000s in the next 48 hours," his September position is a two-unit shape — Apple capacity plus a CUDA card — which is where the home-lab research's shortlist also landed.

## Roy's replies to commenters

- Follow-up to his own post: **"Parameter count is no longer scaling performance it's all kernel dev and efficiency. People serving at scale have no incentive to optimize for single user performance."**
- To "I think a lot more people would be buying local hardware, IF THERE WAS ANY": **"mac studio is good."**
- To "We are also in the honeymoon period of subs and api costs. They will only go up. Hardware costs go up hard over next 2 years too": **"disagree models are getting significantly cheaper and faster to serve, hardware will go up though."**

## External Resources

- Original post: [@usr_bin_roygbiv, 2026-08-29](https://x.com/usr_bin_roygbiv/status/2093750600131375529)
- Quoted post: [@teortaxesTex, 2026-08-28 — "This all was, of course, foretold. Subscription chads winning…"](https://x.com/teortaxesTex/status/2093410564227657884)
- [Roy's GLM-5.3-Flash run on localmaxxing](https://www.localmaxxing.com/en/runs/cmthnezqy023wp401px1q1f9z) — the single-user optimization he is talking about, with the full SGLang + DFlash2 command line
- Research cross-reference: `/data/projects/hardware/research/roygbiv-profile.md` §4 (agreements/disagreements with the synthesis), `hw-alternatives.md` §2.7 (breakeven math)

## Original Content

> [!quote]- Full post (@usr_bin_roygbiv, 2026-08-29)
> Buying local hardware isn't cope, it's betting that a bunch of autistic and/or chinese people will beat the western labs in the near future to such a degree models will be better/faster than what is available on an api in the near future, and they aren't making any more pcie gpus
>
> > Quoting @teortaxesTex (2026-08-28): This all was, of course, foretold
> > Subscription chads winning… https://t.co/9Td9Sh7iZm
> > [quoted post](https://x.com/teortaxesTex/status/2093410564227657884)
>
> Engagement: 85 likes | 6 replies
> [Original post](https://x.com/usr_bin_roygbiv/status/2093750600131375529)

> [!quote]- Replies and Roy's answers (2026-08-29)
> @usr_bin_roygbiv (Roy) — date: Sat Aug 29 17:21:30 +0000 2026 · url: https://x.com/usr_bin_roygbiv/status/2093750906550432011
> Parameter count is no longer scaling performance it's all kernel dev and efficiency. People serving at scale have no incentive to optimize for single user performance.
>
> @Hunters_laptp (Systems Pimp) — date: Sat Aug 29 17:27:23 +0000 2026 · url: https://x.com/Hunters_laptp/status/2093752386376368626
> I have learned so much working constrained.
>
> @cljack (Charlotte Lee) — date: Sat Aug 29 17:59:41 +0000 2026 · url: https://x.com/cljack/status/2093760514140565845
> I think a lot more people would be buying local hardware, IF THERE WAS ANY
> > @usr_bin_roygbiv (Roy) — date: Sat Aug 29 18:04:12 +0000 2026 · url: https://x.com/usr_bin_roygbiv/status/2093761649505186192
> > mac studio is good
>
> @ekremcetinkaya_ (Ekrem) — date: Sat Aug 29 18:29:26 +0000 2026 · url: https://x.com/ekremcetinkaya_/status/2093767999375200322
> A few months more, and we will see the costs into getting local intelligence even lower.
>
> GLM 5.3 Flash level in a single DGX spark for personal use; and  serving over 20 users in a single RTX Pro 6000 for small-scale companies
>
> @mysticflounder (Adam McKenna) — date: Sat Aug 29 19:14:51 +0000 2026 · url: https://x.com/mysticflounder/status/2093779431047442923
> It's not going to be the autists, we may be smarter but we have way less compute
>
> @GPTWare (GPTware) — date: Sat Aug 29 20:38:39 +0000 2026 · url: https://x.com/GPTWare/status/2093800518229410059
> We are also in the honeymoon period of subs and api costs. They will only go up. Hardware costs go up hard over next 2 years too.
>
> It's also just for us freaks interested in optimizing models.
> > @usr_bin_roygbiv (Roy) — date: Sat Aug 29 20:42:44 +0000 2026 · url: https://x.com/usr_bin_roygbiv/status/2093801545305293167
> > disagree models are getting significantly cheaper and faster to serve, hardware will go up though
