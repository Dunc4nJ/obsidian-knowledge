---
created: 2026-05-13
published: 2026-03-17
description: Lumentum slide at Nokia Optical Fiber Communication Conference confirms a new multi-year multi-billion OCS agreement and $400M+ backlog shipping in 2H CY26, with OCS ramping to a >$1B 2027 run rate — Hurlston now sees roughly $400M across the last two quarters of CY26 vs the prior aspirational $100M-quarter target. Marvell co-demoed the connectivity silicon and software around the optical fabric, signaling spine-switch replacement, optical scale-up, network protection, and scale-across as the four OCS use cases — three customers, two driving most of the volume.
source: https://cruxcapitalgroup.substack.com/p/lumentumbig-ocs-deal
type: catalyst
authors: ["Crux Capital Group (@cruxcapitalgroup)"]
---

# Lumentum...big OCS deal?

Crux Capital's same-week reaction to a Lumentum slide deck that surfaced at the Nokia Optical Fiber Communication Conference confirming a March 2026 multi-year, multi-billion-dollar OCS agreement, $400M+ backlog targeted for 2H CY26 fulfillment, and a >$1B 2027 OCS run-rate trajectory. The post pairs the Lumentum disclosure with the Lumentum–Marvell OCS demo, framing OCS as moving [[Lumentum (LITE)]] up the stack from optical-component vendor into system-level optical-network products — and [[Marvell Technology (MRVL)]] as the connectivity-silicon and software complement that benefits whenever AI networks become more optical, more complex, and more software-controlled.

## Key Takeaways

- **The slide confirms the deal**: Lumentum slide titled "OCS Ramping to >$1B 2027 Run Rate" carries a March 2026 update — "New multi-year, multi-billion-dollar OCS agreement reached." Backlog $400M+ to be fulfilled in 2H CY26. Field-proven reliability, high-volume manufacturing, wavelength-agnostic, native high-radix scalability are the architecture pitches.
- **Hurlston math beats prior guidance**: at Morgan Stanley conference, Hurlston revised the aspirational "$100M OCS quarter late CY26" upward to "closer to $400M across the last two quarters of CY26." Q1 was the first $10M quarter — three months earlier than planned.
- **Four OCS use cases**: (1) spine-switch replacement, (2) optical scale-up across very large compute systems, (3) network protection / redundancy / failover, (4) scale-across and data-center interconnect. Spine replacement is highest-leverage — keeps more of the network in optics and offsets the power burden of scaling giant AI fabrics.
- **OCS architecture**: optical circuit switching opens a direct light path between two network points rather than continually round-tripping electrical↔optical conversions. MEMS-based platforms — R300 for large-scale deployments, R64 for smaller AI-DC applications. Pitched as lower latency, better signal integrity, lower power.
- **Customer concentration**: three customers driving OCS demand, two of them taking most of the volume.
- **Marvell's role in the demo**: [[Marvell Technology (MRVL)]] supplied the connectivity silicon, longer-reach optical-link technology, and management/telemetry software around the OCS fabric. Marvell management on its last call said 1.6T entered production in fiscal Q4 2026 with very strong bookings from multiple Tier 1 customers, and called out a broad connectivity portfolio spanning scale-out, scale-across, scale-up.
- **Asymmetric benefit**: Lumentum is selling the switch (benefits if OCS itself becomes a real network layer). Marvell benefits from the broader trend — every step the AI network takes toward "more optical, more complex, more software" expands its DSP / pluggable / telemetry surface area.

## Why This Matters

The OCS thesis on [[Lumentum (LITE)]] has been the most-debated growth-engine call across the [[PhotonCap 2026-05-07 - LITE Q3 FY26 $808M +90 pct YoY transmits asymmetrically across InP supply chain 8 names AIXA VECO IQE AXTI ALRIB OXIG COHR]] and prior Crux readouts. The slide moves the conversation from "OCS could be material" to "OCS is contracted multi-year multi-billion." It also re-anchors the [[Crux Capital 2025-12-30 - Lumentum supply-constrained AI photonics thesis, InP 25-30 pct demand-supply gap, 40 pct unit capacity lift, OCS $100M target Dec 2026]] OCS framework upward: the December "$100M quarter end-of-CY26" target is now positioned as the *low* end vs Hurlston's $400M-across-last-two-quarters revision. For thesis-tracking purposes, this slide is the highest-quality disclosure to date on the size, fulfillment timing, and architecture of LITE's OCS pipeline — and the Marvell co-demo establishes [[Marvell Technology (MRVL)]] as the connectivity-silicon counterparty riding the same OCS-as-spine-switch shift.

## Original Content

EDIT/UPDATE:

*Lumentum slide presented at the Nokia Optical Fiber Communication Conference — "OCS Ramping to >$1B 2027 Run Rate"; key bullets: March 2026 update: New multi-year, multi-billion-dollar OCS agreement reached; Order backlog of $400M+ to be fulfilled in 2H CY26; Field-proven reliability; Elegant design lends itself to high-volume manufacturing; Future-proofed via wavelength-agnostic architecture and native high-radix scalability*
![[cruxcapitalgroup-lumentum-big-ocs-deal-001.jpeg]]

NICE! So I will leave the next section in as transparency, but we officially have a slide from Lumentum's presentation.

---

There is speculation going around about Lumentum securing a multi-year, multi-billion dollar OCS order. I have not seen official confirmation of that, so I am treating it as speculation for now.

What is confirmed is that Lumentum's OCS business is already ramping much faster than management originally expected, and that Marvell is now showing how its connectivity silicon and software can fit around a more optical AI network. That is the real significance of the Lumentum/Marvell demo we saw this week.

[Image — gurufocus headline screenshot; transcribed verbatim below]

> During the Nokia Optical Fiber Communication Conference, Lumentum (LITE) executives shared positive progress in both engineering and manufacturing operations. The company is experiencing improved execution, resulting in better margins, deliveries, and increased revenue from its cloud transceiver business.
>
> Moreover, Lumentum announced a significant update, having recently secured a new multi-year, multibillion-dollar contract with a major OCS consumer. This agreement is expected to significantly boost revenue and drive growth over the coming years for their OCS product line.

https://www.gurufocus.com/news/8719833/lumentum-lite-eyes-growth-with-new-multiyear-ocs-deal

---

So let's dig in to the important bits.

Moving data around the system is becoming one of the main limits on performance. Marvell has been saying that connectivity is now a primary bottleneck in AI infrastructure, and Lumentum is pushing OCS as one answer to that problem.

Optical circuit switching, or OCS, creates a direct light path from one point in the network to another.

Instead of constantly pushing traffic through multiple layers of electronic switching and repeated optical-to-electrical conversions, the network can open a direct optical path and let the data travel more cleanly. Lumentum says this can reduce latency, improve signal integrity, and lower power consumption across large AI clusters. Its OCS platforms are built around MEMS-based switching, with the R300 aimed at large-scale deployments and the R64 aimed at smaller applications inside AI data centers.

So essentially traditional networking keeps handing the data off from point to point, while OCS opens a dedicated lane and lets the data move more directly.

As more of the data center moves into optics, companies have started asking a simple question. Why keep bouncing back and forth between electrical and optical domains if more of the traffic can stay optical? That is exactly how Lumentum has been framing the opportunity. Michael Hurlston said one of the most interesting OCS use cases is spine switch replacement, because it lets operators leave more of the network in the optical domain and potentially improve both power and total cost of ownership.

Lumentum is selling the actual optical circuit switch.

This gives them a more system-level role in the AI network. It's easy to look at Lumentum as a laser and optical component company. OCS moves it higher up the stack. Now it has a product that can shape how traffic is routed across the cluster itself.

On Lumentum's most recent earnings call management said OCS demand had exceeded internal expectations, backlog had moved well beyond $400 million, and most of that backlog was expected to ship in the second half of calendar 2026. Management also said the business reached its first $10 million quarter three months earlier than planned. Then, at the Morgan Stanley conference, Hurlston said Lumentum had previously talked about an aspirational $100 million OCS quarter late in calendar 2026, but now sees something closer to $400 million across the last two quarters of calendar 2026. So if this news about a multi-year, multi-billion dollar order is true, this is far exceeding management's expectations. But again, speculation.

Let's talk a bit more about where Lumentum sees OCS being used. There is demand across four main use cases. The first is spine switch replacement, where OCS can take over part of the job that traditional electrical switching layers do today. The second is optical scale-up, where OCS helps connect very large compute systems more directly. The third is network protection and redundancy, where OCS can be used as a failover layer. The fourth is scale-across and data-center interconnect applications. Management has also said current demand is coming from three customers, with two of them driving most of the volume.

That spine-replacement angle is especially important. If operators can keep more of the network in optics, that can help offset some of the power burden that comes with scaling giant AI fabrics. That is one reason OCS has moved so quickly from niche idea to serious product category.

Now let's talk about where Marvell comes in. In the recent OCS demonstration with Lumentum, Marvell contributed the connectivity silicon and software around the fabric. Marvell is supplying the chip brains inside the optical links, the technology for longer-reach optical connections, and the software that monitors and manages the network.

That fits exactly with how Marvell has been positioning itself. On the last earnings call, Marvell said it has a broad high-speed connectivity portfolio that covers scale-out, scale-across, and scale-up networking. Management said demand remains strong for 800G products, that 1.6T solutions entered production in fiscal Q4 2026, and that bookings from multiple Tier 1 customers for 1.6T were very strong.

So Marvell benefits from OCS in a different way than Lumentum does. Lumentum benefits if OCS itself becomes a real new layer in AI networking. Marvell benefits if AI networks keep becoming more optical, more complex, and more software-controlled, because that creates more need for the chips, DSPs, pluggables, and telemetry that sit around the optical fabric.

Hope you enjoyed the read! I wanted to get this posted asap so sorry if its a bit jumbled.
