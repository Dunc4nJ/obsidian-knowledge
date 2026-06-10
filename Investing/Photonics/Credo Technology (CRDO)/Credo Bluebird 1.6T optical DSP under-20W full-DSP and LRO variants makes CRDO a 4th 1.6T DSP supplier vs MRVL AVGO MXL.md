---
created: 2026-06-10
published: 2025-09-09
description: Credo's Bluebird 1.6T optical DSP — 4 or 8 lanes of 224G PAM4, under-20W, full-DSP and LRO variants, available now — adds a fourth merchant supplier of 1.6T optical interconnect DSPs alongside Marvell, Broadcom, and MaxLinear.
source: https://credosemi.com/news/credo-unveils-bluebird-1-6t-optical-dsp-for-low-power-high-bandwidth-and-ultra-low-latency-ai-networks/
type: research
---

# Credo Bluebird 1.6T optical DSP — under-20W, full-DSP and LRO variants, available now

[[Credo Technology (CRDO)]] announced **Bluebird**, a low-power optical DSP for 1.6Tbps transceivers, on September 9, 2025. This note captures the press release verbatim to test the circulating [[MaxLinear (MXL)]] bull claim that "only 3 companies make DSPs for 1.6T optical interconnects" — namely [[Marvell Technology (MRVL)]], [[Broadcom (AVGO)]], and [[MaxLinear (MXL)]]. Bluebird makes Credo a fourth, so on the face of the release **the "only 3 companies" claim does not survive** (with the caveat below on shipping/qualified silicon vs. announced product).

## Key Takeaways

- **(a) Announcement date, node, fab.** Announced **September 9, 2025** (dateline SHENZHEN, China; distributed via Business Wire). On process node the PR is deliberately vague — it cites only **"advanced CMOS process technology and Credo's proprietary design techniques."** No specific node (5nm / 3nm) and **no fab/foundry is named** anywhere in the release. So this capture cannot confirm or refute the separate MXL claim about node-specific fab capacity through 2H27 — Credo does not disclose its node here.

- **(b) Power claims (low-power pitch).** This is the headline pitch. Verbatim: *"Many existing 1.6T transceivers suffer from high levels of power dissipation, constraining deployments due to the challenges with cooling and power delivery."* Bluebird is positioned to *"deliver industry-leading power efficiency, allowing 1.6T transceivers to consume **well under 20W**."* Power features are *"dynamically enabled to maximize link margin in challenging environments or disabled to optimize energy consumption in dense clusters."*

- **(c) Sampling / production timing.** Verbatim: **"The Bluebird DSP is now available."** No separate "sampling" vs. "mass production" milestone is given — the release states availability outright as of 2025-09-09 ("contact your local Credo sales representative"). The "About Credo" boilerplate confirms shipping solutions *"support port speeds up to 1.6Tb."*

- **(d) Target reach / use-cases (LRO vs. full DSP).** Verbatim: *"Bluebird features **four or eight lanes of 224Gbps PAM4** to support high density 800G, or high-capacity 1.6T optical transceivers. It is available in **full DSP and Linear Receive Optics (LRO) variants**"* for *"both scale-up and scale-out use cases."* Latency *"below 40ns in each direction"* for GPU-to-GPU comms / LLM training and inference. Optional IEEE-compliant inner and outer FEC support *"fiber reaches of 500 m, 2 km and beyond."* So Credo is shipping **both** the full retiming DSP and the lower-power LRO flavor — not LRO-only.

- **(e) Positioning vs. MXL Rushmore, MRVL Ara, AVGO Sian.** The PR names no competitors and no competing part numbers (Rushmore, Ara, Sian). Differentiation is framed on flexibility and power: VP Chris Collins says Bluebird *"is engineered to deliver greater flexibility than existing solutions, enabling broader application support."* The strategic read: 1.6T optical DSPs are now a **four-horse merchant race** (MRVL, AVGO, MXL, plus CRDO/Bluebird) rather than three. The MXL bull case rested partly on a "only 3 suppliers" scarcity framing; Bluebird's availability erodes that count. Whether it erodes MXL's *fab-capacity-through-2H27* edge is undetermined here — Credo discloses neither node nor foundry, so the two claims (supplier count vs. fab capacity) are separable and only the first is directly contradicted by this release.

## External Resources

- [Credo Bluebird product page](https://credosemi.com/products/optical/bluebird/) — official product specs and variant detail.
- [Business Wire original release (2025-09-09)](https://www.businesswire.com/news/home/20250909883490/en/Credo-Unveils-Bluebird-1.6T-Optical-DSP-for-Low-Power-High-Bandwidth-and-Ultra-low-Latency-AI-Networks) — primary distribution.
- [StockTitan coverage](https://www.stocktitan.net/news/CRDO/credo-unveils-bluebird-1-6t-optical-dsp-for-low-power-high-bandwidth-7186eminoele.html) — secondary aggregator (the originally-supplied URL; original Credo newsroom used as `source:`).
- [Downloadable PDF (Credo IR / Q4 CDN)](https://s205.q4cdn.com/511065572/files/doc_news/Credo-Unveils-Bluebird-1-6T-Optical-DSP-for-Low-Power-High-Bandwidth-and-Ultra-low-Latency-AI-Networks-2025.pdf) — PDF of the release.

## Original Content

> [!quote]- Source Material — Credo press release (credosemi.com newsroom), September 9, 2025
>
> ### Credo Unveils Bluebird 1.6T Optical DSP for Low-Power, High-Bandwidth, and Ultra-low Latency AI Networks
>
> September 9, 2025
>
> *Credo Bluebird 1.6T optical DSP announcement banner — headline plus a render of the Bluebird DSP package (mixed text + visual; headline transcribed below)*
> ![[credo-bluebird-001.jpg]]
>
> SHENZHEN, China--(BUSINESS WIRE)-- Credo Technology Group Holding Ltd (Credo) (NASDAQ: CRDO), an innovator in providing secure, high-speed connectivity solutions that deliver improved reliability and energy efficiency for the next generation of AI driven applications, cloud computing, and hyperscale networks, today announced its high-performance, low-power Bluebird Digital Signal Processor (DSP) for 1.6Tbps optical transceivers. This breakthrough technology enables energy-efficient 224Gbps per lane PAM4 data transmission essential to unlocking the advanced computational power of state-of-the-art GPU silicon.
>
> [Image — banner caption text, transcribed verbatim] Next-generation AI networks require high-bandwidth, ultra-low latency, extreme reliability, and exceptional power efficiency. Many existing 1.6T transceivers suffer from high levels of power dissipation, constraining deployments due to the challenges with cooling and power delivery. This places limits on the widespread adoption of 1.6T technology. The Credo Bluebird DSP aims to address these challenges by leveraging advanced CMOS process technology and Credo's proprietary design techniques to deliver industry-leading power efficiency, allowing 1.6T transceivers to consume well under 20W.
>
> Next-generation AI networks require high-bandwidth, ultra-low latency, extreme reliability, and exceptional power efficiency. Many existing 1.6T transceivers suffer from high levels of power dissipation, constraining deployments due to the challenges with cooling and power delivery. This places limits on the widespread adoption of 1.6T technology. The Credo Bluebird DSP aims to address these challenges by leveraging advanced CMOS process technology and Credo's proprietary design techniques to deliver industry-leading power efficiency, allowing 1.6T transceivers to consume well under 20W.
>
> "The 1.6T Bluebird Optical DSP is engineered to deliver greater flexibility than existing solutions, enabling broader application support," said Chris Collins, VP of Optical Sales and Product Marketing at Credo. "This latest milestone exemplifies our commitment to driving innovation in the optical industry — offering unmatched performance and energy efficiency while prioritizing long-term value creation for our optical module partners."
>
> Bluebird features four or eight lanes of 224Gbps PAM4 to support high density 800G, or high-capacity 1.6T optical transceivers. It is available in full DSP and Linear Receive Optics (LRO) variants to address a wide variety of networking architecture options for both scale-up and scale-out use cases.
>
> To reduce bottlenecks in GPU-to-GPU communications, Bluebird has been carefully architected to maintain latency below 40ns in each direction. This ultra-low latency enhances computational efficiency and performance during large language model (LLM) training as well as inference. Bluebird also includes a suite of telemetry features to enable link monitoring and diagnostics, maximizing system uptime and reliability. These same features further assist with failure isolation, debug, and production testing.
>
> For seamless optical transceiver integration, optical component selection and host ASIC interoperability, the Bluebird DSP integrates a strategically tailored suite of performance optimization features for both electrical and optical interfaces. These features can be dynamically enabled to maximize link margin in challenging environments or disabled to optimize energy consumption in dense clusters. Optional IEEE compliant inner and outer Forward Error Correction (FEC) are included to support fiber reaches of 500 m, 2 km and beyond, allowing customers to leverage a common design for different applications.
>
> The Bluebird DSP is now available. For more information, contact your local Credo sales representative.
>
> To learn more about Credo products, go to the product pages linked [here](https://credosemi.com/products/optical/bluebird/?utm_source=businesswire&utm_medium=pr).
>
> **About Credo**
>
> Credo's mission is to advance high-speed connectivity solutions that deliver optimized performance, reliability, energy efficiency, and security for the next generation of AI driven applications, cloud computing, and hyperscale networks. Optimized for both optical and electrical applications, our solutions support port speeds up to 1.6Tb. At the core of our technology is our proprietary Serializer/Deserializer (SerDes) IP. Our diverse solutions portfolio includes system-level products such as Active Electrical Cables (AECs), a range of Integrated Circuits, including Retimers, Optical DSPs, SerDes chipsets, and SerDes IP Licensing.
>
> For more information, please visit [https://www.credosemi.com](https://www.credosemi.com). Follow Credo on LinkedIn.
>
> Credo and the Credo logo are registered trademarks of Credo Technology Group Limited in the United States and other jurisdictions. All other trademarks referenced herein are the property of their respective owners.
>
> **Media Contact:**
> Diane Vanasse
> diane.vanasse@credosemi.com
>
> **Investor Contact:**
> Dan O'Neil
> dan.oneil@credosemi.com
>
> Source: Credo

Original press release: <https://credosemi.com/news/credo-unveils-bluebird-1-6t-optical-dsp-for-low-power-high-bandwidth-and-ultra-low-latency-ai-networks/>
