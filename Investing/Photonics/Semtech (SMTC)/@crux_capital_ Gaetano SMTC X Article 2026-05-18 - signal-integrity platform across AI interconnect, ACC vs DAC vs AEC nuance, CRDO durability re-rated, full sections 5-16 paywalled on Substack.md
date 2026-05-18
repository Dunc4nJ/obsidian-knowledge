---
created: 2026-05-18
published: 2026-05-18
description: Gaetano (Crux Capital) frames [[Semtech (SMTC)]] as a high-speed analog signal-integrity platform across the AI interconnect layer — TIAs / Drivers / CopperEdge / HieFo — with a nuanced copper-vs-optics framing where both win at different distances. Sections 1–4 captured verbatim from the X post; sections 5–16 (ACC, copper durability, optical modules, LPO, XPO/NPO/CPO, HieFo/InP, product map, competitive positioning, FY27 ramp, financial transformation, valuation, risks) live behind the Substack paywall and require auth refresh.
source: https://x.com/crux_capital_/status/2056187354352939244
type: thesis
authors: ["Gaetano (@crux_capital_)"]
---

# @crux_capital_ Gaetano — Semtech $SMTC: My Preferred Investment for Copper & Optics (X Article preview)

> **Note on completeness**: this is an X post-form preview that ends at section 4. The author explicitly redirects to the Substack post (<https://cruxcapitalgroup.substack.com/p/is-this-the-best-way-to-invest-in?r=6so16n>) for sections 5–16 (ACC, copper durability, optical modules, LPO, XPO/NPO/CPO, HieFo/InP, product map, competitive positioning, FY27 ramp/supply planning, financial transformation, valuation framework, risks). That Substack post is paywalled; capture attempted, but local Substack cookies are expired (see footer). **Capture this note's content as a verbatim X-post snapshot; refresh Substack cookies + re-capture for the full deep-dive.**
>
> **Related notes in [[Semtech (SMTC)]] folder:**
> - [[SMTC 2026-04 Crux thesis - HieFo InP acquisition expands content from high-single-digit dollars to 80 in 3.2T module, 50 pct DC growth FY26, ACC vs AEC bake-off won]] (the "first wrote about Semtech in March" reference Gaetano mentions in the opening)
> - [[SMTC 2026-Q4 earnings - record $1.05B sales, data center +58 pct, HieFo InP laser acquisition expands TAM toward 1.6T LPO and 3.2T NPO]] (the "most recent report" referenced)
>
> **Adjacent frameworks**: [[The Photonics Stack - layered map of where laser substrate transceiver DSP and switch companies sit and which layers are bottleneck vs commodity]]

## Key Takeaways

- **One-sentence framing**: "Semtech helps high-speed signals survive inside AI infrastructure." Gaetano argues the more useful descriptor than "analog and mixed-signal semiconductor" is **high-speed analog signal-integrity platform across the AI interconnect layer**.
- **Four product buckets**: (1) **TIAs** (transimpedance amplifiers, optical module receive side — convert photodiode current to electrical signal); (2) **drivers** (transmit side — push electrical signal into modulator or laser); (3) **CopperEdge** (linear equalizers + redrivers — preserve high-speed electrical signals through copper cables / PCB traces / board-level connections); (4) **HieFo** (InP gain chips + CW lasers — light-generating building blocks). Acronym surface area: ACC, AEC, DAC, LPO, XPO, NPO, CPO, InP.
- **Bandwidth-step driver**: 400G → 800G → 1.6T → 3.2T are signal-integrity steps as much as bandwidth steps. Each generation forces the physical layer to work harder. CEO quote: *"As hyperscalers measure data center capacity in megawatts, the ability to move data faster while consuming less power at the networking layer is no longer just a differentiator, it's an enabler."*
- **Copper-vs-optics framing is nuanced, not zero-sum.** Gaetano explicitly pushes back on the LLM-default narrative that optics will fully kill copper. Copper still owns short-reach, dense, low-latency intra-rack links; optics dominates rack-to-rack / row / building / campus DCI. SMTC plays in both — CopperEdge on the copper side, TIAs/drivers/HieFo on the optical side.
- **CRDO as the copper-narrative case study**: from Dec to Apr CRDO got bid down on the "optics replaces copper" narrative; once the market started respecting AEC durability + optics exposure, the multiple snapped back. Gaetano admits he "fell into this too, up to a certain point" before re-rating.
- **Position-sizing reveal**: Gaetano's stated watchlist entries were **CRDO at $95** and **SMTC at $71** — both hit, both held since. Increasing exposure to copper+optics dual-platform names (CRDO, SMTC, some MACOM) has been an explicit strategy.
- **Distance map (from image 006)**: Copper / Semtech CopperEdge + ACC owns 0–3m (intra-rack) and the 3–10m transition zone; Optics / Semtech TIAs + drivers + HieFo lasers owns 10m–100m (rack-to-rack / row), 100m–2km (building / data hall), and 2km+ (campus / DCI).
- **Author reply-chain signal**: @BozRiverGuides flagged that on Tower Semiconductor's recent call, the TSEM call-out was basically "SMTC is ramping ACC." Gaetano replied with 😉😉 (acknowledgment without confirmation — a tell).
- **Sections 5–16 not in this note**: ACC mechanics, copper durability case, optical-module content dollars, LPO content uplift, XPO/NPO/CPO attach math, HieFo/InP supply scarcity, full product maturity map, competitive comp vs MACOM/Credo/Marvell/Broadcom/Coherent/Lumentum/AAOI, FY27 ramp + supply planning, free cash flow / cellular module divestiture transformation, 12/24/36-month base/bull/downside valuation, risks/watchlist — all live in the linked Substack post; refresh Substack cookies + re-capture as a separate note when needed.

---

## Original Content

### X post (long-form, by @crux_capital_ / Gaetano) — 2026-05-18 01:37 UTC

**Article: Semtech $SMTC - My Preferred Investment for Copper & Optics**

Semtech is one of my best performing stocks over the last month.

And I think there is plenty of gas left in the tank.

I first wrote about Semtech in March because I thought the market was underestimating the number of product ramps that were about to hit.

While I believe the most recent report did a good job of explaining the investment case for Semtech, I wanted to take a step back and build some more education around the company.

There is so much that they do, and to fully understand that value I believe it's helpful to actually break things down fully. So that is what this report aims to do.

*Cover image — four product cards summarizing Semtech's interconnect platform: TIAs (receive-side optical analog), Drivers (transmit-side optical analog), CopperEdge (copper signal integrity), HieFo (InP light-source layer)*
![[cruxcapital-x-939244-001.jpg]]

---

If I were to distill Semtech down to one sentence, it would be this:

Semtech helps high-speed signals survive inside AI infrastructure.

AI data centers are giant data movement machines. GPUs, custom ASICs, CPUs, memory, switches, cables, optical modules, and racks all need to communicate constantly. The more AI clusters scale, the more painful that communication becomes. Data has to move faster and farther. It has to use less power and has to create less heat. It has to maintain signal quality across boards, connectors, cables, and optical links.

So when you think about what needs to happen, and what solutions makes it possible, I want you to think about that as being where Semtech lives.

Semtech is traditionally described as an analog and mixed-signal semiconductor business. But like I said, I think the more useful description is that Semtech is becoming a high-speed analog signal-integrity platform across the AI interconnect layer.

This shows up in many places like active copper cables, PCBs, onboard equalization, active backplanes, traditional optical transceivers, InP, LPO, XPO, NPO and some CPO.

I know that is an acronymn soup. But that why I wanted to write this report. We will unpack all of that.

My goal is that by the end of this article you will fully grasp what Semtech does, why it's in a position of strength, why I believe they are still under appreciated (even if their stock has gone up), and what their potential future could look like.

---

## Table of Contents:

1. The data movement problem

Why AI racks are becoming harder to connect as bandwidth moves from 400G to 800G, 1.6T, and eventually 3.2T.

2. Where Semtech enters the rack

A simple map of where Semtech's TIAs, drivers, CopperEdge products, and HieFo lasers fit inside the signal path.

3. Copper versus optics

Why copper and optics both have a place, and why the debate is more nuanced than "one replaces the other."

4. CopperEdge

Why CopperEdge is more than an active copper cable product and should be viewed as a rack-level signal-integrity platform.

5. ACC

How active copper cables sit between passive DAC and DSP-based AEC, and why Semtech sees this as the first visible CopperEdge revenue lane.

6. Copper durability

Why copper can remain valuable in short-reach, low-latency links even as optics moves closer to the chip.

7. Optical modules

How Semtech's TIAs and drivers sit inside the transmit and receive paths of optical modules.

8. LPO

Why removing the DSP from the module can increase the value of Semtech's analog content.

9. XPO, NPO, and CPO

How moving optics closer to the ASIC changes the content map, and where Semtech can still attach.

10. HieFo and InP

Why the HieFo acquisition moves Semtech closer to the light-source layer and expands its potential optical content.

11. Product map

A full maturity view of what Semtech has today, what is ramping now, and what could become future optionality.

12. Competitive positioning

How Semtech compares with [[MACOM Technology (MTSI)|MACOM]], [[Credo Technology (CRDO)|Credo]], [[Marvell Technology (MRVL)|Marvell]], Broadcom, [[Coherent (COHR)|Coherent]], [[Lumentum (LITE)|Lumentum]], and [[Applied Optoelectronics (AAOI)|AAOI]].

13. FY27 ramp and supply planning

Why the next several quarters are important for CopperEdge, 1.6T optical, LPO, HieFo, and onboard equalizers.

14. Financial transformation

How free cash flow, lower interest expense, the cellular module divestiture, and mix shift can change the model.

15. Valuation framework

A 12, 24, and 36-month view of what SMTC could be worth under base, bull, and downside scenarios.

16. Risks and watchlist

The key things that could prove or break the thesis from here.

I use a lot of visuals here as this is a really dense article. I hope you like them! If not, you can just bypass them and the text will do it justice.

None of this is financial advice or a recommendation. Do your own research. This is educational information.

---

## What's the problem?

Most of my coverage of AI infra stocks has to do primarily with data movement.

When we think about GPUs and clusters and huge AI campuses etc. one crucial angle is how effectively and efficiently data can be moved.

At low speeds and short distances, data can move across copper traces and cables with relatively manageable loss. At higher speeds and longer distances, the signal starts to degrade. We're talking about the signal getting weaker and noisier. The waveform gets distorted. Heat creates rough thermal conditions etc. All of this hurts performance and makes copper less viable.

The faster you push the signal, the harder it becomes to keep clean.

That is why the move from 800G to 1.6T to 3.2T is so important. These are bandwidth steps. They are also signal-integrity steps. Each generation forces the physical layer to work harder. Taking it even a step back, think of these moves up in speed/bandwidth as the progression that AI models need. All of the hyperscalers and LLM's are competing and they all want the highest speed, greatest bandwidth, and best reliability. That is what's driving this step up from 400G to 800G to 1.6T etc.

Let's think of the AI rack as a city. The GPUs and ASICs are the buildings. The interconnects are the roads, bridges, tunnels, and traffic lights. You can build taller buildings all day, but if the roads fail, the city slows down and the people living in the buildings get bogged down.

Now tying it back, Semtech sells pieces of the road system.

*"Why data movement gets harder" — physical-layer problem diagram showing GPU/ASIC → PCB trace → copper cable → optical module → fiber signal flow, with loss/noise/jitter/heat callouts; bandwidth climb 400G→800G (HARDER)→1.6T (MUCH HARDER)→3.2T (EXTREMELY HARD); AI infrastructure stress callouts (more bandwidth demand, more thermal stress, cleaner links required)*
![[cruxcapital-x-939244-002.jpg]]

Let's look at what their CEO said regarding the problem we are facing:

> "As hyperscalers measure data center capacity in megawatts, the ability to move data faster while consuming less power at the networking layer is no longer just a differentiator, it's an enabler."

So that's the setup, and I believe that's what the CEO's vision for Semtech is.

To be the enabler.

---

## Where Semtech enters the rack

To understand Semtech, picture a signal moving through an AI rack.

- Let's say the signal starts in a GPU in this instance

- It exits that chip through electrical lanes

- It moves across a PCB trace (a thin, flat copper path that connects electronic components)

- It passes through connectors

- It may move through a copper cable inside the rack or an optical module at the front panel

- It may get converted into light and sent through fiber.

- At the other end, that light gets converted back into an electrical signal and enters the next device.

*"Where Semtech enters the rack" — signal-path diagram with GPU/ASIC → PCB trace branching to (copper path) Copper cable → CopperEdge (Linear EQ / redriver / ACC) and (optical path) Optical module TX → Fiber → Optical module RX → Driver/laser path (HieFo adds laser content) + TIA (receive side); footer: "Semtech content appears where the signal is conditioned, converted, amplified, or turned into light."*
![[cruxcapital-x-939244-003.jpg]]

Every handoff creates a problem. Look at all the handoffs that exist there.

- A PCB trace can weaken the signal.

- A connector can introduce loss.

- A cable can distort the waveform.

- A photodiode produces a tiny current that has to be amplified.

Etc. etc.

Semtech sells products that help this chain function.

At the highest level, there are four buckets to understand.

1. Semtech sells TIAs, or transimpedance amplifiers. These sit on the receive side of an optical module. What happens is that light hits a photodiode, the photodiode creates a tiny current, and the TIA converts that tiny current into a usable electrical signal.

2. Semtech sells drivers. These sit on the transmit side. They help push the electrical signal into a modulator or laser so the outgoing optical signal can be formed properly.

3. Semtech sells CopperEdge, a family of linear equalizers and redrivers. These preserve and restore high-speed electrical signals moving through copper cables, PCB traces, and board-level connections.

4. Semtech now owns HieFo, which adds indium phosphide gain chips and CW lasers. These are light-generating building blocks used in optical interconnects.

*"Semtech product family map — The four product buckets that define the AI interconnect thesis" — the titled version of the cover card, with footer: "Semtech is building content where a high-speed signal gets amplified, restored, or turns into light."*
![[cruxcapital-x-939244-004.jpg]]

So Semtech is many things.

---

## Quick glossary before we go deeper

Before getting too far into the weeds, I want to define the terms that are being used and you can trace back to this as you read. You can also plug this article into chatGPT or your favorite LLM and have some conversation around it.

A TIA is the receive-side chip that turns a tiny photodiode current into a usable electrical signal.

A driver is the transmit-side chip that pushes an electrical signal into a modulator or laser.

A redriver cleans up and boosts a degraded high-speed electrical signal so it can keep traveling.

A linear equalizer compensates for signal loss across a channel while keeping the signal in the analog domain.

A DAC, or direct attach copper cable, is a passive copper cable. It is low power and cheap, but reach gets very short as speeds rise.

An AEC, or active electrical cable, uses active electronics such as DSPs or retimers to extend reach. It can go farther, but it burns more power and adds latency.

An ACC, or active copper cable, is Semtech's favored middle ground. It uses linear equalization and redriving to extend copper reach while using much less power than a DSP-heavy AEC.

LPO, or linear pluggable optics, removes or reduces the DSP inside the optical module and shifts more burden to the host system and analog front end.

XPO is a higher-density front-panel optical approach intended to pack more bandwidth into a smaller physical footprint.

NPO, or near-package optics, moves optics closer to the switch or compute ASIC while keeping more modularity than full co-packaged optics.

CPO, or co-packaged optics, brings optics very close to or inside the same package environment as the switching ASIC.

InP, or indium phosphide, is a compound semiconductor material used for many high-performance lasers because silicon is a poor light emitter.

I believe that is enough vocabulary to help get through this!

---

## I'm not a fan of the copper vs. optics debate

A lot of investors talk about copper and optics like one has to kill the other.

I have actually seen a lot less of this lately, which is interesting. When I first started writing about the Optics trade, a good amount of my content covered how optics is killing copper and that's where the opportunity is. And it's a zero sum game and all that. I think the reason for this is because when you engage with an LLM about optics, it's default is to discuss why copper is bad and all the ways optics is going to replace copper. And yes I believe this is a big part of the trade obviously, and it is also the physical reality. But it is WAY more nuanced than that.

And another point that is interesting is that companies that we're viewed as being heavily copper concentrated were being bid down (or not being bid up the same way as optical interconnect names).

[[Credo Technology (CRDO)|$CRDO]] -3.35%↓ for example.

*[[Credo Technology (CRDO)|CRDO]] TradingView 1D chart May 2025 → May 2026: spot $172.17 (–6.70%), 5.53M volume; the chart shows the Dec → Apr drawdown (from ~$210 ATH back to ~$90 lows in Mar/Apr) and the snap-back rally to ~$210 in May before the current pullback*
![[cruxcapital-x-939244-005.jpg]]

(Most) of the narrative from Dec to Apr was that copper was done for and that a company like this (while still crushing it financially) is steadily losing it's share to optics and therefore the multiple it deserves, contracted. And I fell into this too, up to a certain point. Then, when they started getting more respect for the durability of their products like AEC's, and also their optics exposure, they got bid up again in a way that I never imagined.

So all this to say, I believe the debate is very nuanced and it is not right to assume that one wins and the other doesn't.

Right now copper and optics solve problems at different distances. Copper is usually best for short, dense, cheap, low-latency links. Optics is usually best for longer reach and higher bandwidth over distance. Inside an AI system, both can be valuable.

*"Where copper and optics fit — Different distances, different jobs inside AI infrastructure": distance bands shown as Inside rack 0–3m (GPUs/switches/ASICs in same rack), Short reach/transition 3–10m, Row/rack-to-rack 10–100m, Building/data hall 100m–2km, Campus/DCI 2km+; bottom split — Copper (Semtech CopperEdge + ACC): excels at short distances (0–3m), lowest latency / lower power / lower cost, signal integrity is the challenge. Optics (Semtech TIAs + drivers + HieFo lasers): excels at longer distances (10m+), higher bandwidth over distance, enables scale across racks/buildings/campuses. Footer: "Copper dominates the shortest intra-rack links. Optics becomes essential as distance grows."*
![[cruxcapital-x-939244-006.jpg]]

The main question is where each one belongs.

Inside the rack, copper still is the major role. The links are short, latency is extremely important, power is limited, cost is very relevant. Passive copper works until reach collapses. DSP-based AEC can stretch reach, but that comes with power and latency tradeoffs. ACC tries to sit in the middle.

When we go across racks, rows, buildings, and campuses, optics becomes essential.

Semtech is interesting because it plays in both worlds. An investment strategy of mine (which I have also shared with you all, has been to increase my exposure to these companies that do it both, mainly Credo and Semtech and some MACOM. The timing on both was pretty remarkable too looking back. I'm not the best at 'timing' my entries because I'm more interested in just buying companies that I believe in, at prices that I can justify. But these 2 hit my price targets I had on my watchlist at $95 and $71 respectively and haven't looked back since!)

On the copper side, it uses CopperEdge to keep electrical signals usable across cables, boards, and backplanes. On the optical side, it uses TIAs, drivers, and now HieFo lasers to capture more value inside the optical path.

---

The rest of the report is live on Substack.

That's where I break down the rest of this company.

CopperEdge, ACC, LPO, XPO/NPO/CPO, HieFo, InP scarcity, the FY27 ramp, competitive positioning, and what I think SMTC could be worth over 12, 24, and 36 months.

This is the full map of why I think Semtech is becoming one of the more interesting AI interconnect names in the market.

<https://cruxcapitalgroup.substack.com/p/is-this-the-best-way-to-invest-in?r=6so16n>

Check it out!

*Posted: 2026-05-18 01:37 UTC — <https://x.com/crux_capital_/status/2056187354352939244>*

---

### Reply chain (verbatim)

**@BozRiverGuides (BRG)** — 2026-05-18 01:39 UTC — <https://x.com/BozRiverGuides/status/2056187888904110180>

> @crux_capital_ The [[Tower Semiconductor (TSEM)|TSEM]] call out last week on their call was basically "SMTC is ramping ACC."

**@crux_capital_ (Gaetano)** — 2026-05-18 01:49 UTC — <https://x.com/crux_capital_/status/2056190316219445678>

> @BozRiverGuides 😉😉

**@SPavelski31976 ("Gaetano- Assistante")** — 2026-05-18 04:28 UTC — <https://x.com/SPavelski31976/status/2056230430773277087>

> @crux_capital_ My trading strategy !
>
> 🔻

> *Note: this reply is from an account impersonating Gaetano ("Assistante" handle). Not an authentic signal — preserved here only because the standing capture rule is "all author self-replies + substantive reader pushback verbatim." Treat as noise.*

---

## Section 5–16: Substack-paywalled (not captured here)

The author redirects to <https://cruxcapitalgroup.substack.com/p/is-this-the-best-way-to-invest-in?r=6so16n> for sections 5–16 listed in the Table of Contents above. Capture attempted via `fetch-substack.sh`; **local Substack cookies are expired** ("ERROR: substack auth check failed (sign-in link present after cookie inject)"). Refresh procedure: `~/.agent/skills/url-to-obsidian/references/substack.md` (DevTools → Application → Cookies → substack.sid + substack.lli → paste into `~/.config/url-to-obsidian/substack-cookies.env`).

WebFetch confirmed the post is **partially paywalled** (paywall starts at the same "I'm not a fan of the copper vs. optics debate" section that ends this X-preview). After cookie refresh, the paid-subscriber section will load — that's where sections 5–16 will become capturable.

When that capture lands, it should be a separate note (the Substack post has a distinct slug and likely additional images), wiki-linked back to this one.

---

## Source

- **X post (this capture):** Gaetano (@crux_capital_) — 2026-05-18 01:37 UTC — <https://x.com/crux_capital_/status/2056187354352939244>
- **Linked Substack post (paywalled, not captured):** Gaetano (Crux Capital Group) — 2026-05-18 — <https://cruxcapitalgroup.substack.com/p/is-this-the-best-way-to-invest-in?r=6so16n>
