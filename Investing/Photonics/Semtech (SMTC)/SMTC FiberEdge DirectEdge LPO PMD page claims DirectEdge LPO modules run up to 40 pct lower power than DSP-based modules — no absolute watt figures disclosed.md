---
created: 2026-06-10
description: Semtech's FiberEdge/DirectEdge technology page — DirectEdge LPO PMDs claim "up to 40% lower power than DSP-based modules"; FiberEdge is the 100G/200G/channel TIA + laser-driver foundation. No absolute module-watt figures are disclosed.
source: https://www.semtech.com/technology/fiberedge-directedge
type: research
---

# SMTC FiberEdge/DirectEdge LPO PMD page claims DirectEdge LPO modules run up to 40% lower power than DSP-based modules — no absolute watt figures disclosed

Semtech's product/technology page for **FiberEdge** and **DirectEdge** — the optical-side (PMD) counterpart to the copper [[SMTC CopperEdge linear-copper ACC portfolio claims sub-2W per cable end 90 pct below DSP AECs and sub-100ps latency for 800G-1.6T|CopperEdge]] family. This is the [[Semtech (SMTC)]] page LPO/MaxLinear bull theses cite for the "40% lower module power" claim. Captured to verify the exact wording and check which figures Semtech actually publishes here. No publication date is shown on the page (evergreen product page), so `published` is omitted.

## Key Takeaways

**(a) DSP-based module ~14-17W vs LPO module ~7-8.5W (40-50% reduction).**
**These absolute watt figures do NOT appear on this page.** Semtech publishes only a *relative* claim — "up to 40% lower power consumption than traditional DSP-based modules" — and never states the 14-17W or 7-8.5W absolute numbers, nor a "40-50%" range. The page says **"up to 40%"**, not "40-50%." The absolute watts and the wider 40-50% band are the bull thesis author's modeling/inference, NOT a Semtech disclosure. Flag accordingly: if a thesis attributes "14-17W vs 7-8.5W" to Semtech, that attribution is unsupported by this page (and by the CopperEdge PR, which makes no module-power claim at all).

**(b) Linear copper equalizer "up to 90% lower power" + sub-100ps latency.**
**Not on this page.** The 90%-lower-power and sub-100ps-latency claims are *copper* (ACC) claims — they live in the CopperEdge PR, not on the FiberEdge/DirectEdge optical page. This page's only quantified power claim is DirectEdge's relative "up to 40% lower power" for LPO modules. Verbatim:
> DirectEdge: PMD portfolio enabling Linear Pluggable Optics (LPO) with up to 40% lower power consumption than traditional DSP-based modules — built on our industry-leading FiberEdge performance foundation.

**(c) Reach / use-case caveats Semtech itself states.**
This page is notably light on explicit reach caveats. DirectEdge is framed around **LPO MSA compliance** ("High performance ensuring margin to LPO MSA (Linear Pluggable Optics Multi-Source Agreement)") rather than a stated maximum reach. The implicit caveat is the well-known LPO constraint — short-reach, no on-board DSP retiming — but Semtech does NOT spell out a reach limit (e.g. "short-reach only," "≤2km," "intra-data-center") in this page's verbatim text. FiberEdge supports both **Single-Mode and Multi-Mode** fiber. If a thesis claims Semtech states a specific LPO reach ceiling here, that is not present.

**(d) Which architectures the parts target.** Two distinct portfolios:
- **FiberEdge** = the foundational **PMD (Physical Media Dependent)** layer: "Complete portfolio of TIAs and Laser Drivers across 100G/channel and 200G/channel," driving 800G and 1.6T (and a 400G/channel roadmap toward 3.2T). These are the analog front-end ICs used inside *any* module type (DSP, LPO, LRO).
- **DirectEdge** = the **LPO (Linear Pluggable Optics)** application of those PMDs — explicitly "enabling Linear Pluggable Optics (LPO)" and built "on our industry-leading FiberEdge performance foundation." Verbatim: "Complete portfolio of 100G/channel TIAs and Laser Drivers."

So the architecture targeting is: **FiberEdge = the TIA/laser-driver building blocks for 100G & 200G/channel** (used across module types), **DirectEdge = the LPO-specific PMD line**. The page does NOT mention LRO (linear receive optics) or half-retimed architectures by name — DirectEdge is positioned as full LPO ("ultra-low power 800G Linear Pluggable Optics"). Roadmap: 200G/channel for 800G/1.6T today, 400G/channel for 3.2T modules in development.

## Investment context

FiberEdge is Semtech's existing optical-IC franchise (TIAs, laser drivers) — the analog front-end content inside transceiver modules. DirectEdge extends it into LPO, where removing the module DSP is the power-saving lever the whole LPO thesis rests on. The "up to 40% lower power" is the verbatim hook the LPO bull case (incl. MaxLinear-comparison theses) quotes; the larger absolute-watt and 40-50% claims circulating are not sourced to this page. DirectEdge competes for LPO PMD sockets against [[MACOM Technology (MTSI)]] and [[MaxLinear (MXL)]] (Keystone LPO), with [[Credo Technology (CRDO)]] more on the copper/AEC and retimer side. Semtech's HieFo InP laser acquisition (see [[SMTC 2026-Q4 earnings - record $1.05B sales, data center +58 pct, HieFo InP laser acquisition expands TAM toward 1.6T LPO and 3.2T NPO]]) is what lets it move up-stack from PMD content toward lasers in the same modules.

See also the copper counterpart: [[SMTC CopperEdge linear-copper ACC portfolio claims sub-2W per cable end 90 pct below DSP AECs and sub-100ps latency for 800G-1.6T]].

## Original Content

> **FiberEdge® and DirectEdge™ — Powering the Future of Optical Network Connectivity**
>
> ### High-Performance, Power-Efficient Optical Solutions for Next-Generation AI Infrastructure
>
> In today's high-performance computing landscape, driving ever higher Gbps with minimal latency at the most efficient power envelope (measured in pico-joules/bit) has become the critical bottleneck for AI data centers. Semtech's FiberEdge and DirectEdge technologies delivers breakthrough performance, offering a comprehensive portfolio engineered for tomorrow's bandwidth demands.
>
> ### The Semtech Advantage: Exceptional Performance
>
> Our innovative optical components are designed to maximize performance while minimizing power consumption:
>
> * FiberEdge: Industry leading 100G/channel and 200G/channel Physical Media Dependent (PMD) portfolio to drive 800G and 1.6T optical networks
> * DirectEdge: PMD portfolio enabling Linear Pluggable Optics (LPO) with up to 40% lower power consumption than traditional DSP-based modules — built on our industry-leading FiberEdge performance foundation.
>
> Addressing the industry shift toward higher bandwidth density, Semtech's 200G per channel FiberEdge and DirectEdge PMDs deliver exceptional performance to enable future 800G and 1.6T modules while meeting critical power efficiency and space constraints. Semtech is also pioneering 400G per channel technology to enable next-generation 3.2T modules.
>
> ### Find The Best Fit For Your Application
>
> **FiberEdge Technology**
> Powering today's data center bandwidth needs (800G, 1.6T) and the future (3.2T) with the industry's highest performance PMDs. **High performance** ensuring margin to electrical and optical link budgets. **Low power consumption** to optimize pj/bit. **Complete portfolio** of TIAs and Laser Drivers across 100G/channel and 200G/channel. Support for **Single-Mode and Multi-Mode** optical fiber deployments.
>
> **DirectEdge Technology**
> Revolutionizing data center connectivity with ultra-low power 800G Linear Pluggable Optics (LPO). **High performance** ensuring margin to LPO MSA (Linear Pluggable Optics Multi-Source Agreement). **Low power consumption** to optimize pj/bit. **Complete portfolio** of 100G/channel TIAs and Laser Drivers. Support for **Single-Mode and Multi-Mode** optical fiber deployments.
>
> ### Accessing Critical Industry Challenges
>
> As artificial intelligence workloads drive unprecedented demand for bandwidth and data centers transition to higher data rates, networks face critical power, thermal and latency constraints. Semtech's technologies directly address these challenges by enabling optical modules that deliver exceptional performance while lowering power consumption and latency, essential for scaling AI infrastructure.
>
> ### Future-Proof Your Data Center Infrastructure
>
> With Semtech's FiberEdge® and DirectEdge™ portfolios™, module manufacturers can deploy high-bandwidth connectivity solutions into current and next-generation data centers that scale efficiently within strict power envelopes. This breakthrough technology ensures that connectivity doesn't become the limiting factor in AI infrastructure deployment.
>
> Contact Semtech today to learn how our technologies can transform your connectivity strategy with industry-leading power efficiency, reduced latency, and exceptional signal integrity.

*[Page images were all decorative stock/marketing graphics (data-centre heat photo, iStock generic, LoRa marketing cards, Semtech logo) carrying no data content; not saved per media-triage rules.]*
