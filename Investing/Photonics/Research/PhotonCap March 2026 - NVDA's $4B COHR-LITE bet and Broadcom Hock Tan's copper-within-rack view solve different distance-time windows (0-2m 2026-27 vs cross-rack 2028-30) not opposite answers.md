---
created: 2026-05-13
published: 2026-03-06
description: PhotonCap's foundational thesis piece on NVIDIA's March 2026 $4B partnership ($2B each to Coherent and Lumentum) — argues the market mistakenly framed it as a battle against Broadcom Hock Tan's copper-defense view, when both are correct on different axes of distance and time. Hock Tan's copper-runs-2-to-3-meters-in-rack-at-400G claim is right for 2026-2027 within-rack interconnect; Jensen's optics-required call is right for 10-100m cross-rack distances at Rubin Ultra NVL576 scale in 2028-2030. The "copper cliff" is a physical inevitability, not a market opinion.
source: https://x.com/PhotonCap/status/2029850433011994764
type: research
authors: ["Photon Capital (@PhotonCap)"]
---

## Key Takeaways

- **The market misframed the Broadcom-vs-NVIDIA debate as a contradiction.** In early March 2026 [[Nvidia (NVDA)]] announced a $4B strategic partnership — **$2B each** in [[Coherent (COHR)]] and [[Lumentum (LITE)]] — that funds R&D, domestic US manufacturing expansion, and multi-year purchase commitments for optical components at scale. On the same week's [[Broadcom (AVGO)]] earnings call, CEO Hock Tan defended copper at 200G/400G SerDes within rack distances. PhotonCap's argument: **both are correct, just solving different problems on different axes (distance × time)** — and the market mistook them as giving opposite answers to the same question.

- **What Hock Tan actually said is 100% correct for 2026-2027 within-rack distances.** "We can do it with copper, and we can push the envelope from 100G to 200G to even 400... We have SerDes now running 400G that can drive distance on a rack to run copper. What all I'm trying to say is you don't need to go run into some bright shiny objects called CPOs, even as we are the lead in CPOs. CPOs will come in its time, not this year, maybe not next year, but in its time." Inside the rack (0-2m), 400G SerDes over copper is cheaper, simpler, and works — CPO is still complex, expensive, and unproven at volume in that window.

- **Jensen's $4B is solving a different problem.** Connecting 576 GPUs in a Rubin Ultra cluster requires linking hundreds of racks together. At 10m / 50m / 100m, copper is physically out of the picture — skin effect and dielectric loss collapse the effective transmission distance as speeds rise. Within the 2028-2030 timeframe at cross-cluster distance, optics is a **physical inevitability, not a market choice**. The bigger the cluster, the more optics dominates.

- **The "copper cliff" is physics, not opinion.** Pushing electrical signals through copper degrades as distance and frequency increase (skin effect + dielectric loss). Amplification fights this but burns power exponentially. AI rack budgets at 120-130 kW make a communications layer eating 10%+ of that unacceptable. Fiber: no distance constraint (10km+), immune to EMI, minimal power. PhotonCap cites [[Marvell Technology (MRVL)]]'s data on copper's collapsing effective transmission distance as speeds increase. In an AI factory, **optics is not a choice — it is a physical inevitability**.

- **Two different conversations on two different axes.** Hock Tan: within-rack distances (0-2 m), 2026-2027 timeframe. Jensen: cross-cluster distances (10-100+ m), 2028-2030 timeframe. Both right on their own axis. The market collapsed both into "who wins" when the right framing is a **distance × time matrix** where copper holds inside the rack near-term and optics dominates cross-rack long-term.

- **Why NVIDIA wrote $4B *right now*.** The piece poses but doesn't fully answer in the free portion. PhotonCap's framing implies it is a forward-bookings move to secure manufacturing capacity for the Rubin Ultra and beyond timeframe, given the multi-year purchase commitments and domestic-US manufacturing expansion attached to the deal — i.e. preemptively locking InP laser + transceiver capacity now to ramp into 2028-2030 cross-rack optical demand. The detailed answer is behind the paywall.

- **This piece predates and frames PhotonCap's later substack writing.** Published March 6, 2026 — the earliest of the captured PhotonCap pieces. The thesis that follows in [[PhotonCap April 2026 - Six III-V deposition equipment companies behind COHR and LITE (Aixtron Veeco IQE Riber Oxford Instruments AXT) carry the asymmetric edge of the AI optical cycle]] takes this $4B bet as the demand-side anchor and digs one layer below the modules into the deposition tools. The Veeco Q1 update and the Marvell-Polariton-LWLG piece both inherit this distance-time framing without re-arguing it.

## Cross-references

- The deposition layer below the COHR / LITE module rerating funded here: [[PhotonCap April 2026 - Six III-V deposition equipment companies behind COHR and LITE (Aixtron Veeco IQE Riber Oxford Instruments AXT) carry the asymmetric edge of the AI optical cycle]] — same demand thesis dug one layer deeper.
- The Veeco Q1 update explicitly cites the AI-optical 1.6T / 3.2T cross-rack ramp that this $4B partnership funds: [[PhotonCap May 2026 - VECO Q1 reframes SiPh thesis from MOCVD to Spector IBD facet coating with $250M+ InP laser orders and 10x IBD capacity expansion by early 2027]].
- Module-side demand context from the receiving end of the $2B: [[Crux Capital LITE Q2 FY26 readout - EML 25-30 pct supply gap, all capacity locked under LTAs through CY2027, OCS backlog past $400M, CPO and UHP into 1H 2027]] and [[LITE CEO Q2 FY26 - scale-up CPO is largest single growth driver still in infancy, massive supply demand imbalance, $2B quarterly target on track]].

## External Resources

- [Original tweet](https://x.com/PhotonCap/status/2029850433011994764) — PhotonCap's free tease (March 6, 2026)
- [Coherent-NVIDIA strategic partnership press release](https://www.coherent.com/news/press-releases/nvidia-and-coherent-announce-strategic-partnership) — $2B in COHR
- [Lumentum-NVIDIA strategic partnership press release](https://investor.nvidia.com/news/press-release-details/2026/NVIDIA-Announces-Strategic-Partnership-With-Lumentum-to-Develop-State-of-the-Art-Optics-Technology/default.aspx) — $2B in LITE
- [Broadcom AVGO Q1 2026 earnings call transcript](https://www.fool.com/earnings/call-transcripts/2026/03/04/broadcom-avgo-q1-2026-earnings-call-transcript/) — Hock Tan copper-within-rack statement
- [NVIDIA Rubin platform supercomputer](https://nvidianews.nvidia.com/news/rubin-platform-ai-supercomputer) — Rubin Ultra NVL576 cluster scale referenced
- [Marvell copper-and-optical-interconnects-in-AI-cluster blog](https://www.marvell.com/blogs/copper-and-optical-interconnects-in-ai-cluster.html) — primary source for copper's distance-vs-speed collapse curve

## Original Content

> [!quote]- Source Material
> @PhotonCap (Photon Capital) — Fri Mar 06 09:23:50 +0000 2026
>
> Article: NVIDIA's $4 Billion Bet on Light: Broadcom Isn't the Problem
>
> ### 1. Introduction: The Announcement and the Market's Reaction
>
> In early March 2026, NVIDIA announced a strategic partnership involving a combined $4 billion investment — $2 billion each — in two global leaders in photonics: [Coherent Corp.](https://www.coherent.com/news/press-releases/nvidia-and-coherent-announce-strategic-partnership) and [Lumentum Holdings](https://investor.nvidia.com/news/press-release-details/2026/NVIDIA-Announces-Strategic-Partnership-With-Lumentum-to-Develop-State-of-the-Art-Optics-Technology/default.aspx). This was far more than a passive equity stake. The deal directly funds R&D and domestic U.S. manufacturing expansion at both companies, and includes multi-year commitments to purchase optical components at scale.
>
> The Market's Immediate Reaction
>
> On the [Broadcom earnings call](https://www.fool.com/earnings/call-transcripts/2026/03/04/broadcom-avgo-q1-2026-earnings-call-transcript/), CEO Hock Tan said:
>
> > "We can do it with copper, and we can push the envelope from 100G to 200G to even 400," Tan added. "We have SerDes now running 400G that can drive distance on a rack to run copper. What all I'm trying to say is you don't need to go run into some bright shiny objects called CPOs, even as we are the lead in CPOs. CPOs will come in its time, not this year, maybe not next year, but in its time."
>
> The market immediately framed this as a battle: who's right? Is the age of optics here, or can copper hold on longer? But that framing was completely wrong. Both companies were right — they were just solving different problems. The market missed this crucial distinction entirely.
>
> ### 2. Start with the Physics: Why the "Copper Cliff" Is Real
>
> For decades, copper cables handled communication inside data centers. They were cheap, simple, and perfectly adequate at smaller scales. But the AI era broke that equation. Physics stepped in and said no.
>
> When you push electrical signals through copper, the signal degrades as distance and frequency increase — a consequence of the skin effect and dielectric loss. Combating this degradation requires amplification, and amplification burns power exponentially.
>
> According to [Marvell's data](https://www.marvell.com/blogs/copper-and-optical-interconnects-in-ai-cluster.html), the effective transmission distance of copper wire collapses as speeds increase:
>
> In an environment where AI racks consume 120-130 kW of power, a communications layer that alone eats through 10% or more of that budget is simply not acceptable. Fiber, by contrast, has almost no distance constraints. It supports 10 km+ transmission, is immune to electromagnetic interference, and draws minimal power.
>
> In an AI factory, optics are not a choice — they are a physical inevitability.
>
> ### 3. Broadcom vs. NVIDIA: Both Are Right. The Market Was Wrong.
>
> What Hock Tan Actually Said
>
> Hock Tan was not wrong. He said copper would continue to handle the 2-3 meter connections inside the rack. At that range, 400G SerDes is impressive technology — cheaper and simpler than optics. CPO is still complex, expensive, and unproven at volume. Within the 2026-2027 timeframe, Hock Tan is 100% correct.
>
> What Jensen Huang Is Looking At
>
> Jensen wasn't wrong either. He's just solving a different problem. Connecting 576 GPUs in a [Rubin Ultra](https://nvidianews.nvidia.com/news/rubin-platform-ai-supercomputer) cluster requires linking hundreds of racks together. At 10 meters, 50 meters, or 100 meters, copper is physically out of the picture. Within the 2028-2030 timeframe, Jensen's direction is 100% correct.
>
> > Key Insight: The market mistook Broadcom and NVIDIA as giving opposite answers to the same question. Hock Tan was talking about within-rack distances (0-2 m) in 2026-2027. Jensen was looking at cross-cluster distances (10-100 m+) in 2028-2030. This isn't a contradiction — it's two different conversations on two different axes of time and distance.
>
> The Distance × Time Matrix
>
> The Larger the Cluster, the More Optics Dominates
>
> ### 4. Why Is NVIDIA Betting $4 Billion Right Now?
>
> ### ...
>
> ### 🔒 The full report and in-depth analysis are exclusive to PhotonCap subscribers.
>
> Disclaimer: This article is an independent, engineering-driven technical analysis published by PhotonCap. All content is based on publicly available information and is intended for educational and informational purposes only. Nothing herein constitutes a recommendation to buy, sell, or hold any security. The author may hold positions in securities discussed and may transact at any time without notice. Readers should conduct their own due diligence before making any investment decisions. #NotFinancialAdvice
>
> [Original tweet](https://x.com/PhotonCap/status/2029850433011994764)
