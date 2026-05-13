---
created: 2026-05-13
published: 2026-04-29
description: PhotonCap argues the POET -47% selloff and total PO cancellation by Marvell are not retaliation for an NDA breach but a layer-cleanup signal — Marvell pulled modulator IP in-house (Celestial Ge EAM + Polariton POH) and erased the external optical-engine slot POET occupied.
source: https://x.com/PhotonCap/status/2049385883611414533
type: analysis
authors: ["PhotonCap (@PhotonCap)"]
subsectors: [Optical components & engines]
---

# PhotonCap 2026 — POET -47% selloff explained by Marvell erasing optical engine slot one day after Polariton acquisition

## Key Takeaways

- The headline POET -47.35% selloff on April 27 2026 is officially attributed to an NDA breach by CFO Thomas Mika, but the timing (one day after the [[Marvell Technology (MRVL)]] Polariton acquisition announcement) and the scope (every PO since the April 2023 initial production order, not just recent batches) read more naturally as **layer cleanup** than retaliation — Marvell appears to have erased the external optical-engine slot [[POET Technologies (POET)]] occupied between Marvell and Celestial AI customers.

- The technical anchor of the argument is **device length scale**. POH (Plasmonic-Organic Hybrid) modulators from the Polariton/ETH Leuthold lineage have an active section of 4 × 25 μm × 3 μm with ~3 fF device capacitance, producing sub-fJ/bit and >1 THz bandwidth — values that **collapse if chiplet-bonded** because bond-pad capacitance, RF interconnect parasitics, electrode transition, and organic-chromophore reliability all dominate at the package level. POH naturally forces monolithic / BEOL SiPh integration, which is exactly the layer POET's pick-and-place + passive-alignment paradigm cannot serve.

- Marvell's modulator-IP stack now has **two non-overlapping layers**: GeSi EAM from [Celestial AI](https://en.wikipedia.org/wiki/Celestial_AI) (closed Feb 2026, intra-package Photonic Fabric — see [[Celestial Photonic Fabric Platform for AI Accelerators - arXiv 2507.14000 specs 33TB unified memory and 115Tbps all-to-all switching across 16 XPUs (Ding Diep 2025)]]) and POH from Polariton (announced April 22 2026, transceiver/coherent). Two modulators, two layers, paid for separately within 8 months — followed in 24 hours by clearing POET as the external optical-engine vendor.

- The mm-scale optical components ecosystem ([[Sivers Semiconductors (SIVE.ST)]] DFB lasers, [[Lumentum (LITE)]] InP, [[Coherent (COHR)]] EMLs) is **structurally protected** from this squeeze because chiplet bonding remains viable at mm scale — bonding parasitics are tolerable relative to device length. The 7-ticker positioning matrix splits names by photonic-packaging-layer × Marvell-stack proximity: MRVL/Polariton inside the vertical stack, SIVE/LITE/COHR/NOK/LWLG preserved as external suppliers, POET in the "squeeze zone".

- LWLG (Lightwave Logic) holds an asymmetric position via Polariton's Perkinamine chromophore series. Polariton's POH integration recipe is ten years of Leuthold-group work at ETH Zurich; the March 2025 LWLG-Polariton partnership expansion targeted a 200 mm foundry PDK. If the chromophore inside Marvell's productized POH is Perkinamine-family, LWLG becomes an **indirect material-layer supplier** into the Marvell stack — the kind of optionality PhotonCap argues the cumulative event most strongly validates.

## External Resources

- [PhotonCap full article on Substack](https://photoncap.net/p/the-real-question-behind-poet-47) — paywalled paid section covers §5-§10: Franz-Keldysh vs Pockels mechanism, Nokia ECOC 2023 multi-vendor POH paper, Aref Chowdhury (Nokia → LWLG CTO) and Karin Raj (Nokia CTO Europe ↔ Sivers board) personnel links, 3-scenario benefit/loss matrix, 256 GBd PAM trade-off, Polariton price estimate.
- [Heni et al., Nature Communications 10:1694 (2019)](https://doi.org/10.1038/s41467-019-09724-7) — "Plasmonic IQ modulators with attojoule per bit electrical energy consumption". Foundational POH paper, source of the 4 × 25 × 3 μm active section + 0.07-2 fJ/bit numbers.
- [Mohamed et al., JLT 2023](https://ieeexplore.ieee.org/) — POET passive-alignment statistics (post-bond X 0.09 μm, Y 0.39 μm, θ 0.0002° at 3σ on a 100-sample basis).
- [ASMPT AMICRA NANO die bonder](https://www.amicra.com/en/) — ±0.2 μm placement accuracy, part of POET's pick-and-place equipment stack.
- Prior PhotonCap pieces (embedded in original): [POET deep-dive](https://x.com/PhotonCap/status/2045942106414612778), [Polariton acquisition piece](https://x.com/PhotonCap/status/2047077702168133900).

## Original Content

> [!quote]- Source Material (PhotonCap, @PhotonCap, 2026-04-29 · 50 likes · 13 retweets)

*Cover illustration — title plus calendar/handshake/PO-cancellation metaphor*
![[photoncap-414533-001.jpg]]

**Article: The Real Question Behind POET -47%: Why Did Marvell Erase the Optical Engine Slot**

$MRVL $POET $SIVE $LITE $COHR $LWLG $NOK: which optical layers Marvell pulled inside, and which it left outside

### Abstract

POET dropped 47.35 percent on April 27. The surface reason is an NDA breach, but the real question this piece raises is different. Why did Marvell, the day after announcing the Polariton acquisition, claw back every purchase order POET had received from Celestial AI in a single stroke? And why did the cancellation reach all the way back to the initial production order first disclosed on April 25, 2023? Pure retaliation would only have required cutting the recent batch. The 24-hour gap and the three-year-deep PO recall together look closer to a layer-cleanup signature.

This piece breaks the event apart through the lens of optical-stack realignment. The free section unpacks the following:

- §1 7 days in April: the timeline from the Polariton acquisition announcement (4/22) to the written notice to POET (4/23) to the -47.35% move (4/27). Combined with the Celestial AI acquisition close (2/2), the sequence shows modulator IP being pulled inside Marvell's stack.

- §2 Why μm is the key: the POH (Plasmonic-Organic Hybrid) modulator has an active section of 4 × 25 μm × 3 μm. A device capacitance of about 3 fF is what produces the sub-fJ/bit and 1 THz bandwidth values. This is a fundamentally different length scale from the sub-mm to mm-scale InP DFB light source.

- §3 Why μm devices cannot be chiplet-bonded: bond-pad capacitance, RF interconnect parasitics, electrode transition, and organic-chromophore reliability are four reasons monolithic or BEOL integration is the natural fit. POET's pick-and-place + passive-alignment paradigm has little obvious room here.

- §4 Same polymer family, different integration schemes: the chromophore linkage between LWLG and Polariton, and the structural reason POET, being modulator-material agnostic, never locked in to any one camp.

Core thesis: this event is not a simple customer dispute. It is the first signal of a cycle where Marvell aligns which layers it pulls inside and which layers it leaves outside.

That is the surface of the event. The real divide starts in the paid section. The mechanism-level reason Ge EAM and POH do not collide inside the same stack (Franz-Keldysh vs Pockels), the multi-vendor POH ecosystem confirmed in the Nokia ECOC 2023 paper as a primary source (the Polariton-LWLG-Nokia link plus the Aref Chowdhury Nokia → LWLG CTO move plus the Karin Raj Nokia CTO Europe <--> Sivers board concurrent seats), why SIVE escapes the same pressure, POET's path forward and the cumulative disclosure-pattern risk, a 7-ticker + Polariton-internal positioning map, and a 3-scenario benefit/loss matrix are all unpacked in the paid section.

### Table of Contents

1. Timeline: 7 days in April
2. Plasmonic-Organic Hybrid modulators: why μm is the key
3. Why μm devices cannot be chiplet-bonded
4. Same polymer family, different integration schemes
5. Why SIVE is not in the same layer
6. Celestial Ge EAM and Polariton POH: two modulators, two layers in the same stack
7. Nokia ECOC 2023 and the multi-vendor POH ecosystem
8. POET's light-source integration was a strength. Why did it fail to land at Marvell?
9. POET's path forward
10. Closing

POET dropped 47.35 percent on April 27, closing at $7.95.[1][2] The surface reason is an NDA breach. POET CFO Thomas Mika went on Stocktwits TV and publicly disclosed both the Marvell purchase order and the state of Foxconn/Luxshare negotiations, and Marvell labeled this a violation of confidentiality obligations regarding the purchase orders and shipping information, then issued written notice on April 23 canceling every purchase order POET had received from Celestial AI.[1][3][4]

That is the official explanation.

But the question investors should be asking is different.

[Image — screenshot of POET Technologies April 27 2026 press release "POET Technologies Provides Purchase Order Update"; transcribed verbatim below, with PhotonCap's green-highlighted passages in **bold**]

> April 27, 2026 · 4 min read
>
> # POET Technologies Provides Purchase Order Update
>
> Print / Save as PDF
>
> SAN JOSE, CA, April 27, 2026 —— POET Technologies Inc. ("POET" or the "Company") (NASDAQ: POET), a leader in the design and implementation of highly-integrated optical engines and light sources for artificial intelligence networks, today **announced the cancellation of all purchase orders received by the Company from Celestial AI, including the ones for initial production units first disclosed** (the "Purchase Orders") by the Company in a press release on April 25, 2023. Marvell Semiconductor Inc., which acquired Celestial AI, **provided written notice of the cancellation to the Company on April 23, 2026.** As the basis for the cancellation, Marvell indicated that the Company had made **disclosures of information related to the Purchase Order and shipping information in contravention of its confidentiality obligations.**
>
> The Company remains focused on executing its strategic priorities and advancing product development within the AI and optical networking markets to meet increasing demand. This effort also involves fulfilling product deliveries for other customers, including a recently disclosed purchase order with another technology company with a value of approximately $5 million.

Why was every PO canceled, all the way back to the initial production order first disclosed on April 25, 2023, instead of just the recent batch? Pure retaliation would only have required cutting recent orders. Marvell reached back three years to wipe the entire history. Stranger still is the timing. Marvell announced the Polariton Technologies acquisition on April 22. Marvell issued written notice to POET on April 23. One day apart.[1][11]

The core hypothesis of this piece starts here. POET cancellation is hard to read as just an NDA breach. It looks more naturally as an external optical-engine slot being cleared right after Marvell brought modulator-and-system stack in-house through Celestial AI (closed 2026.2) and Polariton (announced 2026.4.22).

> The official cause is the NDA breach. The reading below is PhotonCap's inference based on the timing, scope, and technology layer in public materials. We have not seen Marvell's internal decision memo.

So this piece narrows to two questions.

One, Celestial AI already had Ge EAM, so why did Marvell pay for another modulator? Aren't they overlapping? Two, is this POH platform really Marvell-only, or was it already in the Nokia ECOC 2023 paper?

Once those are answered, the LWLG and SIVE optionality expands one notch beyond the prior PhotonCap take. And the real alpha here is not a single PO cancellation. It is which layers of the optical stack Marvell pulls in-house and which it leaves outside. The 12-month winner-and-loser line will fall along that boundary.

> Summary: The official reason is an NDA breach. The timing (one day after Polariton) and the scope (entire history including the 2023 PO) are hard to read as simple retaliation. The framing of this piece is which layers Marvell is erasing from its optical stack.

### 1. Timeline

Marvell's optical asset acquisition timeline, laid out in order:

- 2021: Inphi $10B (coherent DSP plus SiPh full stack) [5]
- 2021: Innovium $1.1B (Ethernet switch silicon) [6]
- 2024.10: Celestial AI absorbs Rockley Photonics IP, including over 200 patents on EAMs and optical switching [7]
- 2025.08: Celestial AI publicly discloses Photonic Fabric Module Gen1 with OMIB packaging at Hot Chips 2025, naming GeSi EAM as its chosen modulator [8][9]
- 2025.12 announce / 2026.2 close: Celestial AI $3.25B plus $2.25B milestone (Photonic Fabric, scale-up optical interconnect) [10]
- 2026.4.22: Polariton Technologies (undisclosed terms, Swiss POH modulator, ETH Leuthold spin-off) [11][12]
- 2026.4.23: Marvell sends written notice canceling every purchase order POET had received from Celestial AI [1]
- 2026.4.27: POET 6-K disclosure, stock down 47.35 percent, closes at $7.95 [1][2]

The interval between the Polariton acquisition announcement on April 22 and the PO cancellation written notice on April 23 is exactly one day. Two modulator IP acquisitions in eight months, on two different layers, paid for separately, followed immediately by clearing an external optical engine vendor. The sequencing is too clean to read as random.

> Summary: Across eight months, Celestial (Ge EAM, intra-package) and Polariton (POH, transceiver/coherent) were absorbed as two separate modulator-IP layers, and POET's entire PO history was canceled in the 24-hour window between them. The surface is NDA breach. The sequencing reads more like layer cleanup.

### 2. Plasmonic-Organic Hybrid Modulators: Why μm Is the Whole Point

This is the technical anchor. The plasmonic-organic hybrid (POH) modulator developed by the Polariton / ETH Leuthold lineage has an active region measured in micrometers. The numbers:

[Image — mixed: screenshot of Heni et al. Nature Communications 2019 paper page with the plasmonic IQ modulator MOM-figure inset. Text portion transcribed verbatim below; PhotonCap's green-highlighted passage in **bold**. Visual figure (4-panel plasmonic-slot SEM + driving/optical E-field plots) embedded as image.]

> nature COMMUNICATIONS
>
> ARTICLE
>
> https://doi.org/10.1038/s41467-019-09724-7 · OPEN
>
> ## Plasmonic IQ modulators with attojoule per bit electrical energy consumption
>
> Wolfgang Heni, Yuriy Fedoryshyn, Benedikt Baeuerle, Arne Josten, Claudia B. Hoessbacher, Andreas Messner, Christian Haffner, Tatsuhiko Watanabe, Yannick Salamin, Ueli Koch, Delwin L. Elder, Larry R. Dalton & **Juerg Leuthold**
>
> Coherent optical communications provides the largest data transmission capacity with the highest spectral efficiency and therefore has a remarkable potential to satisfy today's ever-growing bandwidth demands. To this end, the so-called in-phase/quadrature (IQ) electro-optic modulators that encode information on both the amplitude and the phase of light. Ideally, such IQ modulators should offer energy-efficient operation and a most compact footprint, which would allow high-density integration and high spatial parallelism. Here, we present compact IQ modulators with an **active section occupying a footprint of 4 × 25 μm × 3 μm**, fabricated on the silicon platform and operated with sub-1V driving electronics. The devices exhibit low electrical energy consumptions of only 0.07 fJ bit⁻¹ at 50 Gbit s⁻¹, 0.3 fJ bit⁻¹ at 200 Gbit s⁻¹, and 2 fJ bit⁻¹ at 400 Gbit s⁻¹. Such IQ modulators may pave the way for application of IQ modulators in long-haul and short-haul communications alike.
>
> **Fig. 1** Plasmonic IQ modulator on the silicon platform. **a** Colorized scanning electron microscope picture of a Plasmonic IQ modulator consisting of two Mach-Zehnder modulators (MZMs). **b** Zoom into the active section of the modulator, a plasmonic slot waveguide. Light from silicon (Si) feeding waveguide is coupled to the gold (Au) slot waveguide by tapered mode converters. The slot is filled with an organic electro-optic (OEO) material (not depicted). **c**, **d** Cross section of the plasmonic slot waveguide with simulated **c** electrical driving field and **d** optical field

![[photoncap-414533-003.jpg]]

Heni et al., Nature Communications 10:1694 (2019)[13]

- Active section 4 × 25 μm × 3 μm
- Sub-1V driving electronics
- 0.07 fJ/bit at 50 Gbit/s
- 0.3 fJ/bit at 200 Gbit/s
- 2 fJ/bit at 400 Gbit/s
- Device capacitance about 3 fF

Melikyan et al., Nature Photonics (2014)[14]

- 29 μm long plasmonic phase modulator
- 65 GHz bandwidth
- Foundational POH paper

Haffner et al., Nature Photonics (2015)[15]

- 10 μm long all-plasmonic Mach-Zehnder
- Microscale optical communication demonstration

Burla et al. / Ummethala et al., 500 GHz and THz plasmonic series[16]

- Plasmonic modulation pushed into the sub-THz / THz domain

Horst et al., Optica (2025), Polariton + ETH joint[17]

- 3-dB EO bandwidth 997 GHz
- 6-dB EO bandwidth above 1 THz
- Frequency response measured up to 1.1 THz

Wiley Advanced Materials Technologies (2025), silicon MRM comparison[18]

- Conventional silicon micro-ring modulators bottleneck around 42.5 to 54 GHz EO bandwidth. Order-of-magnitude gap to POH.

*Figure 1: POH μm active region vs InP DFB sub-mm/mm-scale light source, RF parasitic contrast*
![[photoncap-414533-004.jpg]]

The point is not the headline numbers. The point is that the active region is in the micrometer scale. Conventional silicon Mach-Zehnder modulators need millimeter-scale length. Thin-film LiNbO3 also needs millimeter scale. POH puts an EO chromophore inside a metal slot. The electromagnetic field is squeezed into a slot tens of nanometers wide, and the EO efficiency rises sharply. The same input produces a much larger output.

This architecture is the result of fifteen years of continuous work in the Leuthold group: plasmonic absorption modulator at KIT in 2011 (Optics Express), the 2014 Nature Photonics phase modulator at ETH, the 2015 Nature Photonics all-plasmonic MZM, the 2018 Nature low-loss plasmon-assisted modulator, the 2019 Nature Communications IQ modulator, and the 2025 Optica 1 THz result.[13][14][15][17][19]

> Summary: The core POH value is sub-fJ/bit and 100 GHz plus bandwidth from a 4 × 25 μm active region. The device length scale is fundamentally different from mm-scale silicon and TFLN, and that fact dictates the integration scheme.

### 3. Why μm Devices Cannot Be Chiplet-Bonded

POET's core IP is the combination of Optical Interposer, elastic averaging passive alignment, and Laser-Assisted Bonding (LAB). Mohamed et al. in JLT 2023 reported, on a 100-sample basis, post-bond X 0.09 μm, Y 0.39 μm, θ 0.0002° at 3σ using a triangle slide-stop geometry.[20] At ECOC 2025, POET demonstrated a 1.6T 2xFR4 PIC with S_sd21 of 53.7 GHz, 8 dBm per channel at 100 mA, 4 dB ER, and 2 dB TDECQ at 106 Gbaud PAM4 SSPRQ.[21] The equipment stack is ASMPT AMICRA NANO (±0.2 μm), Vanguard FaML (Mycronic), and SMBI wafer-level burn-in.[22]

[Image — mixed: ASMPT website screenshot of NANO Die Bonder / Flip Chip Bonder product page. Photo of the machine plus text bullets transcribed below.]

> ASMPT — enabling the digital world · ASMPT AMICRA | English
>
> [Machine photograph: AMICRA NANO die bonder, viewed through equipment access door]
>
> ## NANO - Die Bonder and Flip Chip Bonder
>
> ASMPT AMICRA's ultra-precision die bonder / flip chip bonder which supports ± 0.2μm @ 3s placement accuracy, offering the highest placement accuracy in its class!
>
> ISO Certificate English · ISO Certificate German
>
> ### The NANO Die Bonder / Flip Chip Bonder has a wide range of features including the following:
>
> - Supports ± 0.2μm @ 3s placement accuracy
> - Supports all Die Attach and Flip Chip applications
> - High precision alignment optics
> - Vibration Damping System
> - Automatic Placement Offset Tuning System
> - High resolution 300mm Bonding Station
> - Dynamic Alignment System
> - Quantitative Parallelism Calibration
> - In-situ Eutectic Bonding Capability
> - 3x Different Heated Options Incl. Laser Soldering System
> - Epoxy Stamping and Dispensing capability
> - UV Curing capability at the Bond Station

![[photoncap-414533-005.jpg]]

This paradigm fits mm-scale devices very well. Sivers DFB lasers and Mitsubishi dual-facet EMLs are millimeter-scale, so the interface loss from bonding is small relative to device loss itself. The full equipment-and-paper analysis was covered in the prior PhotonCap POET deep-dive piece.[22]

[Embedded Tweet: https://x.com/i/status/2045942106414612778]

The same paradigm becomes much less natural for μm-scale POH. There are four reasons.

1. Bond-pad capacitance can easily overwhelm device capacitance. The Heni 2019 POH device capacitance is around 3 fF. Once the device is attached as a discrete chiplet, the bond pad, solder bump, wire, redistribution metal, and package trace can add tens to hundreds of fF of parasitic capacitance. The driver is no longer charging a 3 fF modulator. It is charging the package interface as well. That erodes the sub-fJ/bit value proposition at the interface.

2. RF interconnect parasitics can become larger than the device parasitics. A μm-scale modulator only preserves its advantage if the RF path stays extremely short and well controlled. Chiplet bonding introduces pads, bumps, short traces, vias, and package transitions. Their impedance discontinuities, reflections, and losses can dominate the high-speed signal. Even a device with THz-class EO bandwidth loses much of its system-level value if the package transition becomes the bandwidth bottleneck.

3. RF launch and electrode transition enter the same length scale as the active device. When the POH active section is roughly 25 μm long, the bond pad, electrode taper, and nearby signal-line transition are no longer remote packaging details. At that length scale, the modulator response is no longer determined by the active slot alone. The RF launch and electrode geometry must be co-designed with the device. That makes monolithic or BEOL co-design much more natural than a discrete chiplet path.

4. Organic chromophore reliability requires package-level co-design. EO chromophores can be sensitive to humidity, UV exposure, thermal cycling, and long-term poling stability. BEOL-level integration lets passivation, encapsulation, and thermal path be designed together with the device process. Chiplet bonding adds underfill, edge sealing, and CTE-mismatch failure modes. This is one reason the Polariton/ETH lineage repeatedly emphasizes CMOS-compatible BEOL integration.[23]

[Embedded Tweet: https://x.com/i/status/2047077702168133900]

The implication: when Marvell acquired Polariton, the modulator IP at minimum will be processed inside monolithic SiPh, not through an external packaging house. POET's pick-and-place plus passive-alignment paradigm therefore has little obvious entry point at the device level for this specific asset.

> Summary: A 25 μm device routed through a millimeter-scale bonding infrastructure loses its value proposition to bonding parasitics. Monolithic or BEOL-level SiPh integration is the structurally natural fit, far more than an external packaging-house path.

### 4. Same Polymer Family, Different Integration Schemes

This is where the [[Lightwave Logic (LWLG)]] bet and the Polariton bet diverge.

[Image — table of modulator families with length scale, integration approach, and representative companies. Transcribed verbatim as markdown table below.]

| Modulator family | Length | Integration | Representative |
|---|---|---|---|
| Plasmonic-Organic Hybrid | μm-scale (~25 μm) | Monolithic/BEOL strongly preferred | Polariton / ETH Leuthold |
| Thin-film EO Polymer | mm-scale | Chiplet OK | LWLG Perkinamine + TSEM PH18 PDK |
| Thin-film LiNbO3 (TFLN) | mm-scale | Chiplet OK | HyperLight |
| Silicon MZ / MRM | mm-scale | Monolithic | Intel, Marvell SiPh |
| InP DFB / EML | sub-mm to mm-scale | Chiplet OK | Sivers, Lumentum, Coherent |
| Ge / GeSi EAM | μm-scale | Monolithic (BEOL) | Celestial Photonic Fabric, Intel |

When the modulator is millimeter scale, the bonding interface loss is tolerable. LWLG and TFLN families have die-level heterogeneous integration as a viable production path. POET should have aimed at the thin-film EO polymer slot, but its InP DBR plus interposer model is modulator material agnostic, so it never locked into any single material camp.

EO polymer chemistry exists at multiple suppliers, including Lightwave Logic, NLM, and others. POH does not differentiate at the polymer molecule. It differentiates at how that polymer is placed into the slot. Polariton's integration recipe with Perkinamine series 3 is ten years of accumulated work from the Leuthold group at ETH Zurich. The March 2025 expansion of the LWLG-Polariton partnership was specifically about taking that recipe into a 200 mm foundry PDK.[24]

The Polariton acquisition created Marvell's indirect exposure to LWLG. That topic was covered in the prior Polariton acquisition piece.[23] If the chromophore inside POH is the Perkinamine family, LWLG holds an indirect supplier position into the Marvell stack as the modulator material vendor. (This hypothesis is then confirmed at primary-source level in §7 via the Nokia paper.)

> Summary: Device length determines whether chiplet bonding is viable. POH naturally favors monolithic or BEOL integration. EO polymer thin films and TFLN allow chiplet. InP DFB at mm scale also allows chiplet. The integration architecture is dictated by device length, not material chemistry alone.

This is where the surface of the event ends.

*Figure 2: 7-company positioning matrix, photonic packaging layer × device material layer — $MRVL and Polariton inside the Marvell vertical stack, $SIVE / $SIVEF, $LITE, $COHR, [[Nokia (NOK)]], $LWLG preserved as external suppliers, $POET in the "squeeze zone"*
![[photoncap-414533-007.jpg]]

What we have unpacked so far:

- Marvell canceled every POET PO the day after announcing Polariton (timing + scope)
- POH's μm device + sub-fF capacitance value is preserved by monolithic/BEOL integration (chiplet is possible but RF parasitics erode the value)
- POET, being modulator-material agnostic, did not lock in to any one camp

The real divide starts here. The seven tickers ([[POET Technologies (POET)]], [[Sivers Semiconductors (SIVE.ST)]], [[Lumentum (LITE)]], [[Coherent (COHR)]], [[Marvell Technology (MRVL)]], [[Nokia (NOK)]], [[Lightwave Logic (LWLG)]]), plus Polariton as a Marvell-internal asset, all sit on the same event, but they split into four distinct groups: the company already pushed out of the packaging layer, the company on a different layer that escapes the pressure, the company carrying multi-OEM material optionality, and the company that sits on both ends of the two acquisitions. Their risk/reward profiles diverge sharply.

Two Hidden Cards live in this cycle. One is the mechanism-level reason Ge EAM and POH do not collide inside the same stack. The other is the multi-vendor POH ecosystem confirmed in the Nokia ECOC 2023 paper as a primary source. These two are the asymmetry-position variables for the next 12 months.

The whole question reduces to one line.

Which layers is Marvell pulling inside, and which layers is it leaving outside?

🔒 — PAID SECTION begins —

The paid section unpacks that question into a layer-realignment map across the seven companies.

What the paid section covers:

- §5 Why SIVE is not in the same layer: what it means that Marvell absorbed modulator IP while leaving light-source IP outside
- §6 Celestial Ge EAM and Polariton POH mechanism split: the mechanism-level reason the two modulators do not collide inside the same stack (Franz-Keldysh vs Pockels)
- §7 Nokia ECOC 2023 + multi-vendor POH ecosystem: primary-source confirmation of the LWLG-Nokia-Polariton link, plus the Aref Chowdhury personnel move
- §8-§9 The nature of POET's layer pressure and its path forward: why POET's strength in light-source integration did not land at Marvell, and the MSA pluggable + module-vendor pivot
- Additional analysis: 7-ticker identification table plus Polariton-internal mapping, 5-group classification, Ge EAM vs POH wavelength mapping, 3-scenario benefit/loss matrix (Polariton in-house success / TSMC COUPE fallback / integration delay), Hidden Card events (256 GBd PAM trade-off, Polariton price estimate + LWLG royalty scenarios, Nokia next-gen coherent POH adoption odds), quarterly monitoring points
- §10 Closing: thesis wrap-up

### The full article is available on Substack

[https://photoncap.net/p/the-real-question-behind-poet-47](https://photoncap.net/p/the-real-question-behind-poet-47)

---

*Source: [PhotonCap on X (2026-04-29)](https://x.com/PhotonCap/status/2049385883611414533) · 50 likes · 13 retweets · 1 reply*
