---
created: 2026-05-13
published: 2026-04-22
description: PhotonCap reads Vicor's Q1 2026 call as the first hard-spec disclosure of 2nd-gen Vertical Power Delivery (3 A/mm², 40x current multiplication, 1.5mm thickness) plus a structural rebuttal of the rival 800V-to-6V bus architecture, framed against capacity sold out into Fab 1's $1B→$1.5B expansion.
source: https://x.com/PhotonCap/status/2046890484900250055
type: earnings
authors: ["PhotonCap (@PhotonCap)"]
---

# PhotonCap — The Last 1.5mm of AI Power: Three Numbers from Vicor's Q1 2026 Earnings Call

## Key Takeaways

- **Three first-time-disclosed VPD specs anchor the technical claim**: 3 A/mm² current density, up to 40x current multiplication, and 1.5mm package thickness. PhotonCap argues the combination matters more than any single number — competitors disclose subsets, but nobody else publicly meets all three axes at once on [[Vicor (VICR)]]'s 2nd-gen Vertical Power Delivery module.
- **40x current multiplication is the architectural differentiator, not voltage conversion**. Most IVR solutions multiply by ~2x; to deliver 2000A to the processor that means a 1000A bus feed (impractical wiring + thermals). At 40x, a 50A feed delivers the same 2000A. This is why Vicor frames VPD as a current multiplier — the rival mental model of "voltage step-down" misses the point.
- **The 800V→6V bus architecture circulating in the industry is "structurally misguided" per Patrizio Vinciarelli**. PhotonCap teases the full unpack as paid content, but the cover diagram frames it as 64x I²R loss in a single cable vs. Vicor's 1.5mm vertical module — the rebuttal is physics, not preference.
- **Capacity is sold-out and the bottleneck is fab, not demand**. Fab 1 (Andover CHiP fab) is being pushed from ~$1B/yr to $1.5B/yr via shorter cycle times + process-step relocation to an adjacent building; second 3Di line lands Q3/Q4 2026; Fab 2 strategy pivoted from new land to an existing building for speed. Q1 backlog of $301M (up 70% sequentially, 2.7x quarterly revenue of $113M) confirms supply-constrained dynamics.
- **Lead customer is wafer-scale (likely [[Cerebras (CBRS)]] though unconfirmed); hyperscalers are plural, unnamed, and driving the backlog surge**. Lead customer's Gen4→Gen5 transition enables 2nd-gen VPD in H2 2026 with ramp before year-end; additional HPC customers follow. PhotonCap reads the analyst-cited APEC chatter about [[Nvidia (NVDA)]] and [[Alphabet (GOOGL)]] asking suppliers for sub-3mm packages as confirmation Vicor's 1.5mm is already half-the-threshold positioned.

## External Resources

- [Full article (paywalled sections) on Substack](https://photoncap.net/p/the-last-15mm-of-ai-power-three-numbers) — sections 4-6 cover the 800V→6V debate teardown, Vicor's business model structurally read, and scenario analysis.
- [Author's prior P=I²R framing piece](https://x.com/i/status/2046520284409442776) — referenced as the foundation for why power-delivery loss reshapes AI infrastructure economics.

## Original Content

> [!quote]- Source Material — PhotonCap X-Article, 2026-04-22 (37 likes, 8 RTs, 2 replies)
>
> **@PhotonCap (Photon Capital):**
> **Article: The Last 1.5mm of AI Power: Three Numbers from Vicor's Q1 2026 Earnings Call**
>
> 3 A/mm², 40x current multiplication, 1.5mm. Three numbers disclosed for the first time on Vicor's Q1 2026 call that mark the inflection point in AI power architecture.
>
> *Cover diagram: 800V→6V cable shown with "64x loss" annotation contrasted against the Vicor VPD vertical power module at 1.5mm thickness with current flow visualized*
> ![[photoncap-250055-001.jpg]]
>
> **Abstract**
>
> On April 21, 2026, Vicor Corporation (NASDAQ: $VICR) held its Q1 2026 earnings call, where CEO Patrizio Vinciarelli made two explicit technical claims. First, the company put hard numbers on its second-generation Vertical Power Delivery (VPD) solution for the first time: 3 A/mm² current density, up to 40x current multiplication, 1.5mm package thickness. Second, Patrizio directly rebutted a proposed 800V-to-6V bus architecture now circulating in the industry, calling it structurally misguided. This piece unpacks why those two claims showed up on the same call and what they imply for AI data center power architecture.
>
> **Contents**
>
> 1. Intro
> 2. Background: why capacity expansion is part of the thesis
> 3. 2nd-gen VPD specs, what each number actually means
> 4. The 800V→6V debate: solving the wrong problem (paid)
> 5. Vicor's business model, structurally read (paid)
> 6. Scenario analysis (paid)
> 7. Closing
> 8. References & Sources
>
> ### 1. Intro
>
> A state-of-the-art AI rack now draws around 100kW. NVIDIA's GB200 NVL72, for instance, lands at roughly 120kW at the rack level. [1]
>
> Not many people track what happens in the last few millimeters before that power reaches the processor surface. The 48 volts arriving at the server rack has to be stepped down to the ~0.7 volts the processor actually uses. If that conversion is handled poorly, and specifically if the heat and losses it generates aren't managed, **the GPU underperforms** regardless of how good the silicon is. The one-line physics behind this, P = I²R, which says power loss scales with the square of current, is the equation I covered in detail in my prior piece on why it reshapes AI infrastructure. [4]
>
> [Embedded Tweet: https://x.com/i/status/2046520284409442776]
>
> The next bottleneck in AI data centers isn't the semiconductor process. It's how power gets delivered. Vicor used this call to forcefully assert that it is the only company with a commercialized solution combining all the conditions that bottleneck demands.
>
> This piece walks through the technical statements from Vicor's Q1 2026 earnings call on April 21, 2026, and lays out the power architecture constraints they imply. It isn't a stock pick. It's a breakdown of the technical landscape and the business consequences that came out of the call.
>
> ### 2. Background: why capacity expansion is part of the thesis
>
> Good technology with constrained supply tells a different story. That's why capacity expansion took up more airtime on this call than anything else.
>
> Vicor's VPD modules are produced at one site today: the CHiP fab in Andover, Massachusetts. That fab had been mapped to roughly $1B/year in revenue capacity. On this call, Patrizio said they can push it to $1.5B/year. [3]
>
> There are two mechanisms. One, shorter cycle times at bottleneck process steps inside the existing fab. Two, relocating some process steps to a nearby building to lift effective throughput at Fab 1. His phrase was that they'd found "significant elasticity," and the capacity step-up could be as much as 50% above what had been planned. [3]
>
> A second 3Di (3D interconnect) line is set to go in during Q3/Q4. [3]
>
> What about Fab 2? The prior plan contemplated securing new land. On this call, the approach shifted to an existing building. The reason is simple: speed. An existing building lets them add capacity much faster than ground-up construction.
>
> The key quote: "We see ourselves being essentially sold out in terms of capacity for the foreseeable future." [3] Demand stays ahead of supply for a while, which is also why Vicor is being selective about which customers it onboards.
>
> The customer mix currently disclosed:
>
> - Lead computing customer: Maker of a wafer-scale-engine-based AI accelerator. Given the direct reference to wafer-scale engines on the call, this is likely Cerebras, though Vicor did not confirm the name.
> - Hyperscalers: Referenced in plural. No names disclosed, but flagged as a major driver of the Q1 backlog surge.
> - Industrial and defense: ATE (semiconductor test equipment), aerospace, and defense continued to place strong orders.
>
> *Figure 1: Vicor capacity expansion roadmap — Fab 1 (Andover) from current ~$1B capacity through 3Di Line 2 installation and process-step relocation to a $1.5B capacity target; Fab 2 timeline shifts from new-land to existing-building strategy with site search ongoing across Q1/Q2–Q3/Q4 2026, targeting 2027 and beyond*
> ![[photoncap-250055-002.jpg]]
>
> Q1 backlog hit $301M, up 70% sequentially. That's 2.7x the quarterly revenue of $113M. [2]
>
> > One-line takeaway: The bottleneck that turns technical lead into actual revenue today is fab capacity. Vicor is working the bottleneck, and demand is already ahead of supply.
>
> ### 3. 2nd-gen VPD specs, what each number actually means
>
> Phil Davies put concrete numbers on 2nd-gen VPD for the first time on this call. Three of them:
>
> - Current density: 3 A/mm²
> - Current multiplication: up to 40x
> - Package thickness: 1.5mm, with thinner on the roadmap [3]
>
> The point is the combination of all three.
>
> **Why current density matters**
>
> Here's the simple version. Low current density means you can only deliver so much current per unit area. To get more, you stack modules. The problem with stacking is that heat gets trapped inside. The bottom modules heat the ones above them, efficiency drops, and the package gets thicker on top of that.
>
> Vicor management, on this call, directly called out competitor solutions as having "inadequate" current density, with stacked packages suffering from thermal and mechanical issues. [3] Management's position is that their 3 A/mm² is the most aggressive number currently on the table. A quantitative head-to-head comparison with specific competitors wasn't presented on the call, so this remains Vicor's view, not a third-party benchmark.
>
> **Why current multiplication is the real differentiator**
>
> This is the core point.
>
> Most IVR (Integrated Voltage Regulator) solutions multiply current by about 2x. To deliver 2000A to the processor, that means feeding 1000A on the bus. A 1000A feed needs extremely thick wiring, and thermal management at that current level is impractical.
>
> 40x multiplication completely changes the arithmetic. 2000A to the processor needs only a 50A feed. That's why Vicor positions VPD as a current multiplier rather than a voltage converter.
>
> **How 1.5mm stacks up**
>
> On this call, one analyst cited recent APEC (Applied Power Electronics Conference) discussions suggesting that NVIDIA, Google, and similar buyers are asking suppliers for packages under 3mm. Vicor pushed back with the fact that its 1.5mm is half that threshold. [3]
>
> And it doesn't stop there. Patrizio: "we're not stopping at 1.5 millimeter, we're going thinner." [3] Next-generation chiplet-based packaging (like CoWoS) will demand thinner modules still.
>
> *Figure 2: Three key specs of 2nd-gen VPD — left card "3 A/mm² Current Density (per 2nd-gen VPD module)"; middle card "40x Current Multiplication (up to, per Vicor Q1 2026 call)"; right card "1.5mm Package Thickness (going thinner, per management)"*
> ![[photoncap-250055-003.jpg]]
>
> The lead customer's Gen4 → Gen5 transition is slated to be enabled in H2 2026, with ramp beginning before year-end. Additional HPC customers follow on second-gen VPD after that transition. [3]
>
> > One-line takeaway: 3 A/mm², 40x multiplication, 1.5mm. Meeting all three at once is Vicor's claim, and no other company has publicly disclosed a spec combination on this set of axes.
>
> Here's the natural question.
>
> The specs are impressive. So why aren't competitors going this route? Actually, more precisely: a part of the industry is trying to solve the problem with a different architecture altogether. Stepping directly from 800 volts down to 6 volts.
>
> What that debate actually means, and who ends up making money in that setup, is what I unpack below.
>
> ### 🔒 For the full in-depth analysis, subscribe on Substack. A condensed summary will be shared on X.
>
> [https://photoncap.net/p/the-last-15mm-of-ai-power-three-numbers](https://photoncap.net/p/the-last-15mm-of-ai-power-three-numbers)
>
> ---
> Original URL: https://x.com/PhotonCap/status/2046890484900250055
> Posted: Wed Apr 22 09:54:55 +0000 2026 · 37 likes · 8 RTs · 2 replies
