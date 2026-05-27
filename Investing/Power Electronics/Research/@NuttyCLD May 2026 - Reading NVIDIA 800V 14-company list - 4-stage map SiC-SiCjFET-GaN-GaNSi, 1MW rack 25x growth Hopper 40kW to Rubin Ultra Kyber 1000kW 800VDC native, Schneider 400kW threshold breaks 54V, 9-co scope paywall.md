---
created: 2026-05-27
published: 2026-05-26
description: NuttyCLD's structural map of the 14 NVIDIA-disclosed 800VDC silicon partners (Oct 2025 OCP Global Summit) decomposed into 4 functional power-stack positions — Stage 1 grid → 800V DC (SiC), Stage 2 800V protection/hot-swap (SiC JFET), Stage 3 board-level conversion / power delivery board (GaN), Stage 4 VRM → Vcore (GaN + Si). Anchored to the rack-power roadmap (Hopper H100 40kW @ 54V → Blackwell GB200/300 132kW @ 54V → Vera Rubin NVL144 190kW hybrid → Rubin NVL144 CPX 370kW hybrid → Rubin Ultra Kyber 1000kW @ 800VDC native, 2027), with Schneider Electric's Oct 2025 "physically inevitable" white paper marking the 400kW threshold where 54V distribution structurally breaks. Article promises a 9-company investment-thesis scope (8 of the NVIDIA-14 + 1 off-list SiC), Bull/Bear cases per name, and identification of WHICH of the 4 stages is currently being shaken. **Full body paywalled — captured the X Article preview + 4 embedded figures verbatim; flagged subscription gap.**
source: https://x.com/nuttycld/status/2059284961900040199
type: research
authors: ["Nutty (@nuttycld)"]
---

# @NuttyCLD May 2026 — Reading NVIDIA's 800V 14-company partner list

## Key Takeaways

- **The 14 NVIDIA-disclosed 800VDC silicon partners** (Oct 2025 OCP Global Summit): **[[Analog Devices (ADI)]], [[Alpha & Omega Semiconductor (AOSL)]], EPC (Efficient Power Conversion — private), [[Infineon Technologies (IFX.DE)]], [[Innoscience (2577.HK)]], [[Monolithic Power (MPWR)]] (MPS), [[Navitas Semiconductor (NVTS)]], [[Onsemi (ON)]], [[Power Integrations (POWI)]], [[Renesas (6723.T)]], [[Richtek Technology (6286.TW)]], [[ROHM (6963.T)]], [[STMicroelectronics (STM)]], [[Texas Instruments (TXN)]]**. *"A chip company helping define the power-distribution architecture for an AI data center is not a common event."*
- **The framing argument**: *"You don't need 14 companies to buy one kind of chip. Yet the list has 14."* 800V is not a single part — the path from grid kV down to 0.7V Vcore at the GPU die breaks into **4 functional positions, each with its own physical regime, material choice, and supplier map**. The 14 names are spread across those positions.
- **The 4-stage power-stack decomposition** (with materials per stage, exposed by Figure 1):
  1. **Stage 1 — Grid → 800V DC: SiC**. Large solid-state transformer / rectifier modules; medium-voltage power conversion at the rack/row level.
  2. **Stage 2 — 800V Protection / Hot-swap: SiC JFET**. Protection-side switches at the 800V bus level.
  3. **Stage 3 — Power Delivery Board (800V → 12V): GaN**. Board-level intermediate-bus conversion — the densest part of the rack-internal power chain.
  4. **Stage 4 — VRM → Vcore (12V → 0.7V): GaN + Si**. Point-of-load regulation at the GPU die.
- **The 1MW rack roadmap** (exposed by Figure 2 — "The Climb to a Megawatt", 25× growth in 3 years): Hopper H100 (2023) **40kW @ 54V DC** → Blackwell GB200/300 (2024-25) **132kW @ 54V DC** → Vera Rubin NVL144 (~2026) **190kW @ 54V/800V hybrid** → Rubin NVL144 CPX (2026-27) **370kW @ 54V/800V hybrid** → **Rubin Ultra Kyber (2027) 1000kW @ 800VDC native**. Schneider Electric's 800VDC threshold marker sits at **400kW** — *"where 54V distribution structurally breaks."*
- **Why 54V no longer works**: Vcore is 0.7V; grid is thousands of volts. At <100kW racks the 54V intermediate bus is manageable, but at hundreds-of-kW → MW scale **current becomes the architecture** — *"a 7,400A-class current path inside the rack is no longer a packaging detail. So the rack-level voltage moves up to 800V."*
- **Inevitability anchors (3 independent confirmations)**: (1) Schneider Electric's Oct 2025 white paper labels the 800VDC transition *"physically inevitable"* (Schneider sells its own SST so the claim is interested, but); (2) **OCP Diablo specification** points the same direction; (3) **NVIDIA Rubin Ultra Kyber roadmap** points the same direction. *"To pack the electricity of a small building (1MW) into a single row of computers, there is no path other than raising the voltage."*
- **The thesis-driving question** (paywalled section): *"In one of the four positions, the default answer is currently being shaken."* The author claims to identify **which stage** is being shaken, **which company** is doing the shaking, and **what proof will be required for that shake to harden into fact**. The X Article preview does NOT reveal the answer.
- **9-company investment scope**: 8 from the NVIDIA-14 list + 1 off-list SiC company included for context (likely [[Wolfspeed (WOLF)]] given material-specialist positioning per Figure 3, but unconfirmed). Screen criteria: **market cap ≥$3B, direct 800V/AI DC engagement, revenue visibility**. The 9-company stage map (Figure 3) anonymizes the players A-J across the 4 stages, tagged with 5 categorical labels — **Diversified IDM (blue), Hybrid/Strategic (yellow/olive), 800V Pure-play (orange), Material Specialist (purple/red), Neutral (gray)** — and 3 exposure tiers: **LOW EXPOSURE (no separate AI DC disclosure), MID EXPOSURE (disclosed AI DC line item ~3-10%), HIGH EXPOSURE (pure-play / core revenue)**. Figure 3 shows Stage 3 (board-level conversion) is the most-populated stage in the matrix.
- **The valuation dispersion** (Figure 4 — "Same List, Different Prices"): plotting 1Y stock return × EV/TTM revenue (log scale) for the 9-name cohort shows **one orange "800V Pure-play" outlier at ~+600% 1Y / ~150x EV/TTM revenue**, **one purple/red "Material Specialist" at ~+80% 1Y / ~50x EV/TTM revenue**, and a **cluster of 6-7 diversified IDM / hybrid names at +100-300% 1Y / 3-10x EV/TTM revenue**. The same NVIDIA partner list is being priced very differently — the author's argument is that the 4-stage decomposition explains why.

## Why this matters

This is the **structural decoder** for the NVIDIA October 2025 800VDC partner list — the document that turns *"14 names with no apparent ordering"* into *"each name occupies a specific stage of a 4-position physical chain, and the stages are not interchangeable."* The framing matters because **the same NVIDIA partner list is being priced very differently in the market** (Figure 4 makes the dispersion visible — the 800V pure-play sits ~10-30x richer than the diversified IDMs on EV/TTM revenue despite all being on the same "validated" list). The author's claim that **one of the four stages is being shaken** by a specific company is the load-bearing thesis behind the paywall — without that name, the framework is structural but not actionable; with the name, it becomes a directional view on which of the 14 should rerate. The framework hooks naturally to the existing [[@bryzonx POWI 1700V InnoMux-2 thesis for VR200 800V data center - rack scaling 120kW to 600kW makes voltage survival bottleneck, NVTS 650V destroyed, NVIDIA co-design, rack power capex 36K to 398K]] — which argues POWI's 1700V InnoMux-2 reset the Stage 3 board-level conversion architecture in a way that *"destroyed NVTS 650V"* and made POWI the co-design partner for VR200 — i.e., @bryzonx is making exactly the *"which company is shaking which stage"* call that this article promises behind the paywall, but for Stage 3 specifically. Read the two together: NuttyCLD provides the 4-stage map; @bryzonx names POWI as the Stage 3 shaker. The @insane_analyst SiC-and-GaN device landscape ([[@insane_analyst 650V class SiC and GaN power device landscape - 15-vendor comparative table at 80C Vds 400V covering Rds-on Coss Eoss Qoss and pkg integrated-driver tradeoffs]]) sits beneath this — it's the device-physics layer at the 650V class that Figure 1 places in Stage 3 (GaN) and Stage 4 (GaN+Si). On Stage 1 specifically, the SiC material specialist Figure 3 includes (off-list) is most plausibly [[Wolfspeed (WOLF)]], since SiC substrate + crystal-growth IP at 10kV is the Stage 1 solid-state-transformer-grade qualification gate; the +80% 1Y / ~50x EV/TTM revenue position in Figure 4 also fits WOLF's post-Ch11 recovery profile. Useful 800V adjacency cross-reads in vault: [[Jasons Chips Bloom Energy (BE) thesis - fuel cells displace gas turbines for AI data centers via native 800V DC, modularity, 90-day deployment, and unconstrained TAM]] (the upstream power generation side); [[NVIDIA (NVDA)]] (the architecture's author); [[Vertiv (VRT)]] (the rack-level infrastructure integrator). Falsification clocks: (a) does NVIDIA's Rubin Ultra Kyber 2027 actually land on 800VDC native, or slip / hybridize?; (b) does the *"shaken stage"* identified in the paid section see the named challenger displace the named incumbent in actual VR200 / Rubin Ultra design wins inside 18 months?; (c) does Schneider Electric's 400kW threshold model hold up under real deployment data, or does 54V get pushed further than predicted?

## Original Content

### X Article preview — @NuttyCLD (Nutty), 2026-05-26 14:46 UTC

**Article: Everyone Saw NVIDIA's 800V List. Few Read It Correctly.**

A four-stage map of GaN, SiC, and the new AI data center power stack.

---

> This is structural analysis, not investment advice. The companies discussed can be volatile, and the author may hold positions in some of the securities discussed. Readers should make their own investment decisions.

#### The 14 Companies NVIDIA Announced: Same List, Different Positions

At the October 2025 OCP Global Summit, NVIDIA disclosed 14 silicon partners supporting its 800VDC AI factory architecture: ADI, AOS, EPC, Infineon, Innoscience, MPS, Navitas, onsemi, Power Integrations, Renesas, Richtek, ROHM, STMicroelectronics, and Texas Instruments. A chip company helping define the power-distribution architecture for an AI data center is not a common event.

What stands out even more is the length of the list. You don't need 14 companies to buy one kind of chip. Yet the list has 14.

The reason is simple. 800V is not a single part. From the thousands of volts coming out of the grid down to the 0.7V at a GPU die, the power path breaks into four functional positions: front-end conversion, 800V protection, board-level conversion, and point-of-load regulation. Not every position is a voltage step-down, but each position has its own physical regime, material choice, and supplier map. The 14 companies are spread across those positions. Some sit near the grid-facing conversion layer. Some sit right next to the GPU die.

But which position each of the 14 occupies, and whether all four positions are stable, are separate questions. In one of the four positions, the default answer is currently being shaken. This article is about where that shaken position is. Which of Stage 1, 2, 3, or 4 it is, which company is shaking it, and what proof will be required for that shake to harden into fact.

The article uses a 9-company scope: eight names from NVIDIA's 14-company silicon partner list, plus one off-list SiC company included for context. The screen was market cap (≥$3B), direct 800V / AI DC engagement, and revenue visibility. Companies that fail the cap or visibility screen do not appear in the player tables.

---

#### The 1MW Rack Era: Why 54V No Longer Works

The Vcore inside one GPU is 0.7V. The electricity coming out of a power plant is thousands of volts. The gap cannot be crossed in a single step. It has to be brought down in stages.

The familiar approach has been to drop the voltage to 54V through a few large conversions, then carry that lower-voltage bus through the rack. At 5kW, 15kW, or even 100kW racks, 54V was manageable. But as rack power moves toward hundreds of kilowatts and eventually megawatt scale, current becomes the architecture. The burden shifts to cables, connectors, busbars, copper area, and cooling. A 7,400A-class current path inside the rack is no longer a packaging detail.

So the rack-level voltage moves up to 800V.

The timing of the 800V transition is not far off. Schneider Electric called it "physically inevitable" in an October 2025 white paper. That is the claim of a company that sells its own SST, but the OCP Diablo specification and the NVIDIA Rubin Ultra Kyber roadmap point in the same direction. To pack the electricity of a small building (1MW) into a single row of computers, there is no path other than raising the voltage.

The problem is that 800V does not arrive as a single part. Once power enters the rack-level 800V path, it still has to pass through protection, board-level conversion, and final point-of-load regulation before reaching the 0.7V Vcore. Each position requires a different physical regime, material choice, and supplier map. That is why NVIDIA's list has 14 names.

---

#### What this article covers (rest is paid-subscriber only)

That is the reason 800V has to happen. From here on, the article works through who handles that 800V, in which position, with which technology, and which of those positions is being shaken.

- A one-line conclusion for each of the four positions. A 10-company stage map, with the article body focused on the 9-company thesis. Which position is shaking, and who stands where, disclosed up front.

- Why GaN and SiC are not the same material. Why silicon hits a ceiling (bandgap, 2DEG, BFOM).

- Stage 1–4 deep-dive. For each stage, the player structure (lead, workhorse, challenger).

- The 9 companies grouped by investment thesis. Current earnings / option value / scenario bets, plus Bull/Bear cases.

- Conclusion, reader lenses, and appendix. A 1Y price, operating-margin, and EV multiple snapshot of the 9 companies (Appendix A pricing, Appendix B credibility ladder).

---

**Full-paid article:** https://nuttycld.substack.com/p/reading-nvidias-800v-partner-list

### Embedded figures (preserved from X Article — paywall-bypass since they were hotlinked into the X post)

*Figure 1 — "Everyone Saw NVIDIA's 800V List. Few Read It Correctly." Author's 4-stage map of the AI data center power stack as a sequence of 4 physical modules. **Stage 1: Grid (kV) → 800V DC, material SiC** (large power module with multiple discrete dies). **Stage 2: 800V DC → "Protection / Hot-swap", material SiC JFET** (smaller protection module). **Stage 3: 800V DC → "Power Delivery Board", material GaN** (green board-level converter). **Stage 4: "VRM → Vcore" 12V → 0.7V, material GaN + Si** (point-of-load regulator next to GPU die). The arrows trace 800V DC across Stages 1→2→3, then 12V into Stage 4, then 0.7V to GPU. **This is the load-bearing material map for the entire thesis.***
![[nuttycld-040199-001.jpg]]

*Figure 2 — "The Climb to a Megawatt: AI rack power · three GPU generations · 25× growth". Bar chart of NVIDIA rack power roadmap: **Hopper H100 (2023) 40kW @ 54V DC** (small green bar), **Blackwell GB200/300 (2024-25) 132kW @ 54V DC** (green), **Vera Rubin NVL144 (~2026) 190kW @ 54V/800V hybrid** (olive/transition), **Rubin NVL144 CPX (2026-27) 370kW @ 54V/800V hybrid** (orange/transition), **Rubin Ultra Kyber (2027) 1000kW @ 800VDC native** (full red, ~25× Hopper). Red dashed vertical at **400kW = "800VDC threshold"** — Schneider Electric's marker where 54V distribution structurally breaks. Caption: "25× growth in three years. The red dashed line marks Schneider Electric's 800VDC threshold, where 54V distribution structurally breaks." Signed @NuttyCLD.*
![[nuttycld-040199-002.png]]

*Figure 3 — "Who Plays in Which Stage: 10 companies across 4 conversion stages". Anonymized scatter matrix with 4 rows (Stage 1, Stage 2, Stage 3, Stage 4) and 10 columns (Companies A through J). Dot color encodes 5 categorical positions: **Diversified IDM (blue)**, **Hybrid/Strategic (yellow/olive)**, **800V Pure-play (orange)**, **Material Specialist (purple/red)**, **Neutral (gray)**. X-axis groups columns by 3 exposure tiers: **LOW EXPOSURE (Companies A-E) = no separate AI DC disclosure**, **MID EXPOSURE (Companies F-I) = disclosed AI DC line item (~3-10%)**, **HIGH EXPOSURE (Company J) = pure-play / core revenue**. Observed placements: Stage 1 has dots at Companies A (Material Specialist purple), B (Hybrid yellow), F (Diversified IDM blue), H (Diversified IDM blue), J (800V Pure-play orange — high exposure). Stage 2 has dots at Companies C (800V Pure-play orange), G (Diversified IDM blue), H (Diversified IDM blue). **Stage 3 is the most-populated stage** — dots at Companies B (Hybrid yellow), C (orange), D (Neutral gray), F (blue), G (blue), H (blue), I (Material Specialist purple), J (orange). Stage 4 has dots at Companies E (Hybrid yellow), G (blue), I (Material Specialist purple). Company J (the 800V pure-play / high-exposure name) appears in Stages 1, 2, 3 but NOT Stage 4. The single Material Specialist (purple) appears in Stages 1, 3, 4 as Company A and Company I respectively — i.e., 2 distinct Material Specialist names.*
![[nuttycld-040199-003.jpg]]

*Figure 4 — "Same List, Different Prices: 1-year stock return × EV / TTM revenue (log)". Scatter of ~9-10 names; X = 1Y stock return (range 0% to +800%), Y = EV/TTM revenue on log scale (2× to 200×). **Top-right outlier**: orange dot ~+600% 1Y / ~150× EV/TTM revenue (the 800V Pure-play / Company J equivalent). **Top-left flier**: purple/red dot ~+80% 1Y / ~50× EV/TTM revenue (Material Specialist). **Bottom-middle cluster** (6-7 dots): blue (Diversified IDM) + yellow (Hybrid) + 1 orange (lower-exposure 800V) at +100-300% 1Y / 3-10× EV/TTM revenue. **The takeaway**: the same NVIDIA partner list is priced over a ~50× spread on EV/TTM revenue — the 4-stage decomposition is the author's framework for explaining why that dispersion is rational (or not).*
![[nuttycld-040199-004.jpg]]

### Thread replies

*(Bird thread fetch returned no replies — the X Article appears to be either too new for substantial engagement or the bird CLI did not surface reply nodes. The post timestamp is May 26 14:46 UTC and was fetched on May 27 ~02:14 UTC, ~11.5h later. Worth re-fetching in 24-48h for any added discussion.)*

## Paywall status

**The full Substack body is paid-subscriber-only and the cookies at `~/.config/substack-cookies.env` do NOT authenticate to NuttyCLD's paid tier.** `fetch-substack.sh` returned exit 4 (paid + subscription gap). The X Article preview captured above is the only accessible textual content. **The 4 embedded figures (Figure 1-4) were extracted from the X Article via `extract-tweet-images.sh` and DO contain substantial structural content** — including the materials-per-stage map, the rack-power roadmap with explicit data points, the anonymized 10-company stage matrix with exposure tiers, and the valuation-dispersion scatter. These figures are the highest-density artifacts the article exposes outside the paywall.

**Sections behind the paywall that this note CANNOT capture verbatim**:

1. **One-line conclusion per stage** (the author's distilled verdict on Stages 1, 2, 3, 4)
2. **The 10-company stage map de-anonymized** (Companies A-J → actual ticker names)
3. **Which stage is being shaken + which company is doing the shaking** (the load-bearing thesis)
4. **GaN-vs-SiC physics deep-dive** (bandgap, 2DEG, BFOM mechanics)
5. **Stage 1-4 player structure** (lead / workhorse / challenger per stage)
6. **9-company investment-thesis groupings** (current earnings vs option value vs scenario bets)
7. **Bull/Bear cases per name**
8. **Appendix A — pricing snapshot of the 9 companies**
9. **Appendix B — credibility ladder**

## Ticker scaffolding decisions

**Scaffolded in this run (3 new)**:
- **[[Analog Devices (ADI)]]** — Nasdaq. Placed in **Chips** sector per CLAUDE.md primary-thesis rule — ADI's dominant valuation driver is general-purpose analog/mixed-signal IC, with 800V AI DC partnership as one new growth vector among many. Sits alongside [[Texas Instruments (TXN)]] (peer analog leader).
- **[[Alpha & Omega Semiconductor (AOSL)]]** — Nasdaq. Placed in **Power Electronics** — power MOSFET/IGBT designer, dominant thesis is power semi.
- **[[Richtek Technology (6286.TW)]]** — Taiwan Stock Exchange. Placed in **Power Electronics** — power management IC designer (subsidiary of MediaTek). Could argue Chips per parent-company sector, but Richtek's own product line is exclusively power management, so Power Electronics matches CLAUDE.md primary-thesis rule.

**NOT scaffolded** (deliberate):
- **EPC (Efficient Power Conversion Corp)** — verified private (no public listing). Mention as plain text only. If EPC ever IPOs / SPACs, promote then.

**Already in vault — wiki-linked**:
- [[Infineon Technologies (IFX.DE)]] (Power Electronics)
- [[Innoscience (2577.HK)]] (Power Electronics)
- [[Monolithic Power (MPWR)]] (Compute — MPS = Monolithic Power Systems)
- [[Navitas Semiconductor (NVTS)]] (Power Electronics)
- [[Onsemi (ON)]] (Power Electronics)
- [[Power Integrations (POWI)]] (Power Electronics)
- [[Renesas (6723.T)]] (Chips)
- [[ROHM (6963.T)]] (Power Electronics)
- [[STMicroelectronics (STM)]] (Power Electronics)
- [[Texas Instruments (TXN)]] (Chips)

## Open questions / things to dig into

- **Get the paid Substack body**: this is the load-bearing artifact. Either upgrade the NuttyCLD subscription, or check `bird thread` again in 48-72h to see if the author posts the de-anonymized stage map in a follow-up free thread.
- **Identify the 1 off-list SiC company in the 9-company scope.** Material-specialist positioning (purple/red Figure 3 dots at Stages 1, 3, 4) + ~50× EV/TTM revenue + +80% 1Y return strongly suggests [[Wolfspeed (WOLF)]] (the only Western full-stack SiC name with 10kV MOSFET first commercial in March 2026, post-Ch11 recovery profile). But the article paywalls the confirmation. Watch the follow-up.
- **Identify Company J** (the high-exposure 800V Pure-play at ~+600% 1Y / ~150× EV/TTM revenue, visible in Figure 4 top-right). The candidates from the NVIDIA-14 list with pure-play 800V exposure are [[Navitas Semiconductor (NVTS)]] and [[Power Integrations (POWI)]]. NVTS is the front-runner based on multi-thread vault context (the @bryzonx note flags "NVTS 650V destroyed" by POWI's 1700V InnoMux-2 — but NVTS's 1Y return profile and rerate magnitude better matches the orange top-right outlier in Figure 4 if NVTS rallied even higher on the broader AI 800V thesis before any displacement). Re-check when paid body accessible.
- **The "shaken stage" hypothesis test**: if [[@bryzonx POWI 1700V InnoMux-2 thesis for VR200 800V data center - rack scaling 120kW to 600kW makes voltage survival bottleneck, NVTS 650V destroyed, NVIDIA co-design, rack power capex 36K to 398K]]'s framing is correct, the **shaken stage is Stage 3** (board-level conversion / power delivery board) and the **shaker is [[Power Integrations (POWI)]]** with its 1700V InnoMux-2 architecture displacing the GaN-based 650V incumbents (notably NVTS). This is testable — pull NVIDIA's actual VR200 / Rubin Ultra design-win disclosures over the next 12-18 months.
- **Schneider Electric ticker** — not yet scaffolded. SU.PA on Euronext Paris (~€220B+ cap). Worth scaffolding if more 800V-thesis content from Schneider lands in vault; not done in this capture (single mention).
- **OCP Diablo specification** — public document? Worth pulling the spec text into Frameworks/ for primary-source reference behind the 800V transition claims.
- **Schneider Oct 2025 white paper** — find and capture as standalone Power Electronics/Research note. Anchors the "physically inevitable" claim that's load-bearing for the entire 800V thesis stack.
- **NVIDIA Rubin Ultra Kyber roadmap** — verify the 2027 1000kW @ 800VDC native date against NVIDIA's actual disclosed roadmap (Computex / GTC announcements). The 25× rack-power growth in 3 years number is the marketing-grade claim; check the engineering substantiation.
- **The 7,400A current-path number**: where does it come from? Derive from 400kW / 54V = 7,407A — implied threshold. Worth verifying the Schneider 400kW threshold model since this number drives the entire transition timing claim.
- **Re-fetch the X Article thread in 24-48h** for any added reader replies — bird returned 0 replies at capture time which is unusual for a NuttyCLD post.
- **Author-voice triangulation**: this is the 2nd capture from @nuttycld in vault — but the prior NuttyCLD LEO RF map note flagged in the brief is NOT in the current vault state. Worth checking if it was captured under a different filename or never landed.
- **Compare framework to @aleabitoreddit (Serenity) photonics 4-claim nuance lens**: both authors use structural decomposition + identify-the-shaken-position framings on technical hardware stacks; useful tonal calibration once the paywall lifts.
