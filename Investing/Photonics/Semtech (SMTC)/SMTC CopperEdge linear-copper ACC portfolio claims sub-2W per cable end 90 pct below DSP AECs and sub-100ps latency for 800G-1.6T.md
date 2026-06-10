---
created: 2026-06-10
published: 2025-04-02
description: Semtech's CopperEdge launch PR claims its GN8214/GN8224/GN8234 linear equalizer ICs deliver <2W per cable end (90% below DSP-based AECs) and sub-100ps latency for 800G/1.6T active copper cables.
source: https://www.semtech.com/company/press/copperedge-portfolio-low-power-800g-ai-data-centers
type: research
---

# SMTC CopperEdge linear-copper ACC portfolio claims sub-2W per cable end (90% below DSP AECs) and sub-100ps latency for 800G/1.6T

Semtech press release (OFC 2025, April 2, 2025) launching the [[Semtech (SMTC)]] **CopperEdge** family of linear equalizer/redriver ICs (GN8214, GN8224, GN8234) for active copper cables (ACC) and on-board equalization. This is the primary-source PR behind the power/latency figures circulating in MaxLinear/LPO bull theses (e.g. the Temple 8 newsletter). Captured to pin down what Semtech *actually* claims, in what units and configs.

## Key Takeaways

These are the figures the bull theses lean on. The CopperEdge PR is the *copper* (ACC/AEC/DAC) side of the story; the LPO module-power numbers belong to the separate [[SMTC FiberEdge DirectEdge LPO PMD page claims DirectEdge LPO modules run up to 40 pct lower power than DSP-based modules — no absolute watt figures disclosed]] page (see cross-reference below).

**(a) DSP-based module ~14-17W vs LPO module ~7-8.5W (40-50% reduction).**
**This figure does NOT appear in the CopperEdge PR.** The CopperEdge PR is about copper cables (ACC), not optical modules — so it makes no module-watt claim at all. The only module-power claim Semtech publishes is the relative "up to 40% lower power" on the FiberEdge/DirectEdge tech page (captured separately). The absolute 14-17W-vs-7-8.5W figures are NOT a Semtech disclosure on either page — they are the bull thesis author's own modeling/attribution. Flag as un-sourced to Semtech.

**(b) Linear copper equalizer "up to 90% lower power than DSP-based active electrical cables" with latency under 100 picoseconds.** Semtech's verbatim claim, under "Breakthrough Technical Innovations":
> **Ultra-low power:** Less than 2W per cable end power consumption—90% lower than DSP-based AECs—enabling denser AI/ML deployments within existing data power envelopes.
> **Ultra-low latency:** Sub-100ps latency delivers over 100x improvement compared to higher latency DSP-based retimers, critical for distributed AI training.

Nuance the circulating phrasing flattens:
- The power claim is an **absolute "Less than 2W per cable end"** plus the relative "90% lower than DSP-based AECs" (AEC = Active Electrical Cable). Both are Semtech's words. The "up to 90%" framing in the bull thesis is faithful, though Semtech states it as a flat "90% lower," not "up to 90%."
- "DSP-based active electrical cables" in the thesis = Semtech's "DSP-based AECs." Match.
- Sub-100ps latency is benchmarked vs **DSP-based retimers** (over 100x improvement), not vs DAC. Semtech's words.

**(c) Reach / use-case caveats Semtech itself states.** Verbatim, under "Extended reach performance":
> 800G copper cables to 5m.
> 1.6T copper cables to 3m.
> Enhanced PCB trace length for both 112G/channel and 224G/channel designs.

So this is explicitly **short-reach copper** (3-5m), positioned as "significantly longer-reach copper infrastructure than direct attach copper (DAC) cables" while staying within copper's intra-rack/adjacent-rack envelope. It is NOT an optical-reach replacement. Other stated positioning caveats: "Reduced cable diameter improves airflow/cooling in dense compute clusters," "Seamless compatibility with existing 100G/channel and 200G/channel infrastructure," "Simplified deployment versus DSP-based retimers."

**(d) Which architectures the parts target.** These are **linear equalizer/redriver** ICs for **active copper cables (ACC) and on-board (PCB) equalization** — the copper analog to LPO/LRO on the optical side. Verbatim part-by-part:
> GN8214: 4-channel 112G/channel PAM4 linear equalizer supporting 800G ACC and onboard applications.
> GN8224 / GN8234: Advanced 4-channel 224G/channel PAM4 cable equalizers supporting 1.6T ACC and on-board applications.

And: "the GN8214 optimized for 112G/channel PAM4 applications (enabling 800G connectivity), while the GN8224 and GN8234 target next-generation 224G/channel PAM4 deployments (supporting 1.6T connectivity)." No "retimer" or "half-retimed" architecture here — the whole point is **linear (DSP-free) equalization**, contrasted against DSP-based AECs and DSP-based retimers.

## Investment context

CopperEdge is Semtech's competitive answer in linear copper, going head-to-head with [[Credo Technology (CRDO)]]'s DSP-based AEC franchise and [[MACOM Technology (MTSI)]] / [[MaxLinear (MXL)]] signal-integrity portfolios. The thesis hook: as AI clusters push 800G→1.6T inside the rack, linear (DSP-free) copper at <2W/end and sub-100ps latency undercuts DSP AECs on both power and latency while extending DAC reach (to 5m at 800G / 3m at 1.6T). The "90% lower power than DSP AECs" line is the headline the bull case quotes — and it checks out verbatim here. The optical-module-power figures (14-17W vs 7-8.5W) do not come from this PR; see the [[SMTC FiberEdge DirectEdge LPO PMD page claims DirectEdge LPO modules run up to 40 pct lower power than DSP-based modules — no absolute watt figures disclosed]] capture for what Semtech actually says on LPO.

See also: [[SMTC 2026-04 Crux thesis - HieFo InP acquisition expands content from high-single-digit dollars to 80 in 3.2T module, 50 pct DC growth FY26, ACC vs AEC bake-off won]] and [[Crux Capital 2026-05-27 - SMTC Now what post-earnings - PT 175 to 225, FY27 base 1.38-1.42B, Q2 guide 328M +27pct, DC framework shifts from 50pct floor to 90-100pct, CopperEdge shipping, HieFo demand 3x supply]].

## Original Content

> Semtech's CopperEdge™: Low-Power 800G/1.6T Copper Solutions for AI Datacenters
>
> *Next-generation active copper technology delivers breakthrough power efficiency and latency optimization for AI/ML infrastructure*
>
> **SAN FRANCISCO and CAMARILLO, Calif., April 2nd, 2025** - Semtech Corporation (Nasdaq: SMTC), a high-performance semiconductor, IoT systems and cloud connectivity service provider, today announced availability of its CopperEdge family of active copper cable (ACC) and on-board equalization technology. This portfolio of linear equalizer/redriver solutions—featuring the GN8214, GN8224, and GN8234—transforms data center connectivity for AI/ML data center deployments at a fraction of the power consumption of Digital Signal Processing (DSP)-based Active Electrical Cables (AECs) while achieving significantly longer-reach copper infrastructure than direct attach copper (DAC) cables. As an industry-leading equalizer IC solution for 1.6T ACCs, this breakthrough technology enables unprecedented bandwidth density for AI/ML data centers while reducing interconnect power consumption and maximizing data throughput under strict thermal constraints.
>
> "As AI workloads drive exponential growth in data center bandwidth requirements, the industry faces critical power and thermal challenges," said Brian Bentham, data center market manager at Semtech. "CopperEdge represents a paradigm shift in connectivity, delivering the signal integrity and reach extension needed for next-generation AI clusters while dramatically reducing power consumption and implementation complexity compared to DSP-based options. With our proven production capabilities, Semtech continues to lead the market in delivering high-performance connectivity solutions for today's most advanced data centers."
>
> Semtech's comprehensive ecosystem approach brings together multiple cable OEM partners, ensuring robust supply chain resilience and consistent product quality at scale. This established partner network enables rapid adoption of CopperEdge technology across diverse AI/ML more deployments while maintaining the rigorous performance and reliability standards demanded by hyperscale data centers.
>
> **CopperEdge: Enabling the Future of AI Infrastructure**
>
> The CopperEdge portfolio supports both current and emerging connectivity standards, with the GN8214 optimized for 112G/channel PAM4 applications (enabling 800G connectivity), while the GN8224 and GN8234 target next-generation 224G/channel PAM4 deployments (supporting 1.6T connectivity).
>
> **Breakthrough Technical Innovations**
>
> * **Ultra-low power:** Less than 2W per cable end power consumption—90% lower than DSP-based AECs—enabling denser AI/ML deployments within existing data power envelopes.
> * **Ultra-low latency:** Sub-100ps latency delivers over 100x improvement compared to higher latency DSP-based retimers, critical for distributed AI training.
> * **Extended reach performance**
>    * 800G copper cables to 5m.
>    * 1.6T copper cables to 3m.
>    * Enhanced PCB trace length for both 112G/channel and 224G/channel designs.
> * **Optimized for AI/ML deployments**
>    * Reduced cable diameter improves airflow/cooling in dense compute clusters.
>    * Seamless compatibility with existing 100G/channel and 200G/channel infrastructure in data centers.
>    * Simplified deployment versus DSP-based retimers.
>
> **The CopperEdge family includes:**
>
> * GN8214: 4-channel 112G/channel PAM4 linear equalizer supporting 800G ACC and onboard applications.
> * GN8224 / GN8234: Advanced 4-channel 224G/channel PAM4 cable equalizers supporting 1.6T ACC and on-board applications.
>
> Learn more about Semtech's high-performance optical, analog and mixed-signal IC signal integrity solutions at www.semtech.com/optical.
>
> **Meet Semtech's Optical Experts at OFC 2025**
>
> Visit Semtech at the 2025 Optical Fiber Communications Conference and Exhibition (OFC) in San Francisco, April 1-3, Corporate Village #1028. Our technical experts will provide personalized consultations on how our comprehensive portfolio can address your specific optical networking challenges. Experience live demonstrations of our latest technologies for data center interconnects, next generation 800G/1.6T optical connectivity, and high-performance analog solutions designed to meet your optical communications needs.
>
> **About Semtech**
>
> Semtech Corporation (Nasdaq: SMTC) is a high-performance semiconductor, IoT systems, and cloud connectivity service provider dedicated to delivering high-quality technology solutions that enable a smarter, more connected, and sustainable planet. Our global teams are committed to empowering solution architects and application developers to develop breakthrough products for the infrastructure, industrial and consumer markets. To learn more about Semtech technology, visit us at Semtech.com or follow us on LinkedIn or X.
>
> Semtech and the Semtech logo, are registered trademarks or service marks of Semtech Corporation or its subsidiaries, and CopperEdge is a trademark or service mark of Semtech Corporation or its subsidiaries. All other trademarks and trade names mentioned may be marks and names of their respective companies.
>
> SMTC-P

*[Image — Semtech-branded decorative OG/press banner (logo + stylized fiber-strand graphic), no data content; not saved per media-triage rules.]*
