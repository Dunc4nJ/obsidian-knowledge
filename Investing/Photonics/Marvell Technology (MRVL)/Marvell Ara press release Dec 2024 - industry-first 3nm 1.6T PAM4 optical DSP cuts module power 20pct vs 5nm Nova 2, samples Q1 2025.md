---
created: 2026-06-10
published: 2024-12-03
description: Marvell's Dec 2024 launch of Ara, the industry's first 3nm 1.6 Tbps PAM4 optical DSP — 8x 200G electrical + 8x 200G optical lanes, integrated laser driver, >20% lower 1.6T module power than the 5nm Nova 2, sampling to select customers Q1 2025.
source: https://www.marvell.com/company/newsroom/marvell-unveils-industrys-first-3nm-1-6tbps-pam4-interconnect-platform.html
type: research
---

# Marvell Ara press release Dec 2024 — industry-first 3nm 1.6T PAM4 optical DSP cuts module power 20pct vs 5nm Nova 2, samples Q1 2025

[[Marvell Technology (MRVL)]] press release announcing **Ara**, positioned as "the industry's first 3nm 1.6 Tbps PAM4 interconnect platform." Captured to fact-check the circulating MaxLinear bull claim that "MXL is the ONLY 1.6T DSP vendor with guaranteed fab capacity through 2H27" and that "only 3 companies make 1.6T DSPs" — and to time-stamp where Marvell's 1.6T DSP roadmap actually sits versus [[MaxLinear (MXL)]]'s Rushmore.

## Key Takeaways

The five points below quote the release **verbatim** where it speaks, and explicitly flag where it is silent — that silence is itself the answer to several parts of the MXL framing.

**(a) Announcement date + node (and whose fab).** Dateline: **"SANTA CLARA, Calif. — Dec. 3, 2024"** (the page's JSON-LD metadata lists `datePublished: 2024-12-02` / `dateModified: 2025-01-23` — a one-day discrepancy with the human-facing dateline; the body date governs). Node, verbatim: "the industry's **first 3nm** 1.6 Tbps PAM4 interconnect platform … Ara leverages the comprehensive **Marvell 3nm platform** with industry-leading 200 Gbps SerDes and integrated optical modulator drivers." **The release names NO foundry.** "3nm" + "Marvell 3nm platform" is the only node language; TSMC is the universally-presumed 3nm source for Marvell but **is not stated anywhere in this release** (linked context: Marvell's earlier "first 3nm data infrastructure silicon" demo). Do not cite this release as evidence Ara is on TSMC 3nm — it does not say so.

**(b) Sampling / production / availability timing.** Verbatim under "Availability": **"Marvell Ara will sample to select customers in Q1 2025."** That is the ONLY timing the release gives — sampling, not production. No mass-production date, no volume-ramp quarter, no 2026/2027 availability is stated.

**(c) Power figures claimed.** Verbatim: Ara "reduce[s] 1.6 Tbps optical module power by **over 20%**" — explicitly benchmarked against the prior-gen **5nm Nova 2** ("Building on the success of the Nova 2 DSP, the industry's first 5nm 1.6 Tbps PAM4 DSP"). The subhead restates: "New Ara PAM4 DSP **Reduces Optical Module Power by 20%**." The release gives a *relative* (>20% vs 5nm Nova 2) figure only — **no absolute watt/module power number** is disclosed. Mechanism cited: integrated, high-swing laser driver + 200G SerDes on 3nm.

**(d) Customer / ecosystem traction language.** Two named ecosystem partners are quoted: **InnoLight** ([[Innolight (300308.SZ)]]) — CMO Osa Mok: "The Ara platform combined with InnoLight's advanced high-speed optical transceiver design and manufacturing expertise, offers the industry a state-of-the-art pluggable module" — and **LightCounting** analyst Bob Wheeler endorsing PAM4 unit growth ("more than triple from 2024 to 2029 to nearly 127 million units a year"). No hyperscaler design wins, no XPU/switch customers, and no revenue figures are named; customers are referenced only generically as "select customers" and target sockets ("switches, network interface cards (NICs) and XPUs").

**(e) Timing vs MaxLinear's Rushmore.** Per the MXL framing supplied with this capture, Rushmore (MaxLinear's 1.6T PAM4 DSP) sampled **March 2025** on **Samsung leading-edge CMOS (no node disclosed)**. This Ara release predates that: Marvell announced Ara **Dec 3, 2024** with sampling in **Q1 2025 (Jan–Mar 2025)** — i.e., Marvell's 1.6T DSP was announced ~3 months earlier and slated to sample in the same window as, or slightly ahead of, Rushmore. On **node**, Ara discloses 3nm explicitly while Rushmore discloses no node; so the "only MXL has a node story" comparison is asymmetric — and Marvell additionally already had a **5nm 1.6T part (Nova 2) shipping** as the predecessor Ara improves on. This materially undercuts any "MXL is uniquely early / uniquely advanced at 1.6T" reading; Marvell is at least one full node generation (5nm → 3nm) into 1.6T PAM4 by this announcement.

**On the "Marvell stuck in TSMC backlog" / "MXL is the ONLY vendor with guaranteed fab capacity" framing:** the release says **NOTHING about fab capacity, allocation, backlog, supply constraints, or wafer commitments — and does not mention TSMC at all.** That absence cuts both ways: it neither confirms nor refutes a Marvell capacity constraint. What it DOES establish against the "only 3 companies make 1.6T DSPs" + "MXL uniquely positioned" narrative is that Marvell is a clear, named, two-generation-deep 1.6T PAM4 DSP vendor (5nm Nova 2 → 3nm Ara) with a module-partner ecosystem ([[Innolight (300308.SZ)]]) and a sampling date that brackets Rushmore's. [[Broadcom (AVGO)]] is the third common name in the "three 1.6T DSP vendors" set. No claim in this release supports the idea that Marvell's 1.6T roadmap is capacity-gated; the framing is simply not addressed here. (Note: the related-links footer separately surfaces a Marvell coherent-pluggables headline — "Demand is way outstripping supply" — but that is an external article link, NOT a statement in this Ara release.)

## External Resources

- [Marvell demonstrates industry's first 3nm data infrastructure silicon](https://www.marvell.com/company/newsroom/marvell-demonstrates-industrys-first-3nm-data-infrastructure-silicon.html) — the linked "Marvell 3nm platform" foundation Ara builds on.
- [Ara 3nm 1.6T PAM4 DSP press kit](https://www.marvell.com/company/media-kit/ara-3nm-1-6tbps-pam4-dsp-press-kit.html) — additional specs/images (returned HTTP 403 / Akamai access-denied from this capture host; not retrievable here).
- Related links surfaced in the release footer (external articles, not part of the Ara announcement): [NVIDIA Invests $2B in Marvell to Extend NVLink Fusion](https://convergedigest.com/nvidia-invests-2b-in-marvell-to-extend-nvlink-fusion-ai-ecosystem/), [FT: Nvidia invests $2bn in Marvell](https://www.ft.com/content/e23bc33e-757e-46bc-acad-e89647351324?syn-25a6b1a6=1), [Marvell on coherent pluggables: "Demand is way outstripping supply"](https://gazettabyte.com/marvell-on-coherent-pluggables-demand-is-way-outstripping-supply/), [Marvell: 1.6T Silicon Photonics Light Engine](https://www.lightwaveonline.com/home/product/55355487/marvell-16t-silicon-photonics-light-engine), [Marvell completes acquisition of XConn](https://convergedigest.com/marvell-completes-acquisition-of-xconn-expanding-pcie-and-cxl/).

## Original Content

Source: <https://www.marvell.com/company/newsroom/marvell-unveils-industrys-first-3nm-1-6tbps-pam4-interconnect-platform.html>

> [!quote]- Source Material (Marvell press release, Dec. 3, 2024)
> ## Newsroom
>
> # Marvell Unveils Industry's First 3nm 1.6 Tbps PAM4 Interconnect Platform to Scale Accelerated Infrastructure
>
> New Ara PAM4 DSP Reduces Optical Module Power by 20%, Enabling Mass Adoption of 200 Gbps per Lane and 1.6 Tbps Network Infrastructure to Meet Rising AI Bandwidth Demands
>
> **SANTA CLARA, Calif. — Dec. 3, 2024 –** [Marvell Technology, Inc.](https://www.marvell.com) (NASDAQ: MRVL), a leader in data infrastructure semiconductor solutions, today introduced Marvell® Ara, the industry's first 3nm 1.6 Tbps PAM4 interconnect platform featuring 200 Gbps electrical and optical interfaces. Building on the success of the Nova 2 DSP, the industry's first 5nm 1.6 Tbps PAM4 DSP with 200 Gbps electrical and optical interfaces, Ara leverages the comprehensive [Marvell 3nm platform](https://www.marvell.com/company/newsroom/marvell-demonstrates-industrys-first-3nm-data-infrastructure-silicon.html) with industry-leading 200 Gbps SerDes and integrated optical modulator drivers, to reduce 1.6 Tbps optical module power by over 20%. The energy efficiency improvement reduces operational costs and enables new AI server and networking architectures to address the need for higher bandwidth and performance for AI workloads, within the significant power constraints of the data center.
>
> Ara, the industry's first 3nm PAM4 optical DSP, builds on six generations of Marvell leadership in PAM4 optical DSP technology. It integrates eight 200 Gbps electrical lanes to the host and eight 200 Gbps optical lanes, enabling 1.6 Tbps in a compact, standardized module form factor. Leveraging 3nm technology and laser driver integration, Ara reduces module design complexity, power consumption and cost, setting a new benchmark for next-generation AI and cloud infrastructure.
>
> "Ara sets a new industry standard by leveraging advanced 3nm technology to deliver significant power reduction, driving the volume adoption of 1.6 Tbps connectivity for AI infrastructure," said Xi Wang, Vice President of Product Marketing for Optical Connectivity at Marvell. "With a co-optimized companion TIA, our next-generation PAM4 optical DSP platform empowers customers to scale generative AI and large-scale compute applications with best-in-class performance and unmatched energy efficiency."
>
> "Ara is another Marvell optical connectivity industry-first solution, delivering the power efficiency required for the most demanding AI workloads," said Osa Mok, chief marketing officer, InnoLight Technology. "The Ara platform combined with InnoLight's advanced high-speed optical transceiver design and manufacturing expertise, offers the industry a state-of-the-art pluggable module optimized for next-generation AI and cloud infrastructure."
>
> "We anticipate unit shipments of PAM4 DSPs will more than triple from 2024 to 2029 to nearly 127 million units a year and remain the primary optical technology for connecting assets inside data centers for the foreseeable future," said Bob Wheeler, Analyst at Large, LightCounting. "Ara marks another first for Marvell and demonstrates that PAM4 technology continues to evolve to meet the challenges of AI infrastructure."
>
> Optimized for next-generation AI and cloud infrastructure, Ara is designed to support high-density 200 Gbps I/O interfaces across switches, network interface cards (NICs) and XPUs, while ensuring backward compatibility with prior generations. With best-in-class power efficiency and integration, Ara addresses the growing requirements of hyperscale data centers, to deliver high-performance accelerated infrastructure with best-in-class total cost of ownership (TCO).
>
> **Ara Platform Key Features**
>
> * 200 Gbps per channel support, providing high bandwidth for next-generation AI-driven applications.
> * 200 Gbps per lane line-side receiver with companion Marvell TIA CB11269TA, providing best-in-class linearity and low noise for AI applications.
> * PAM4 modulation for efficient high-speed data transmission – critical for AI and cloud applications.
> * Integrated, high-swing laser driver to improve performance while reducing overall transceiver module design complexity, power consumption, and TCO.
> * Enhanced crossbar switching capabilities within a streamlined architecture, improving routing flexibility across channels.
> * InfiniBand and Ethernet support for versatile interconnect flexibility across diverse network topologies, enhancing adaptability for accelerated infrastructure.
>
> **Availability**
>
> Marvell Ara will sample to select customers in Q1 2025.
>
> **About Marvell**
>
> To deliver the data infrastructure technology that connects the world, we're building solutions on the most powerful foundation: our partnerships with our customers. Trusted by the world's leading technology companies for over 25 years, we move, store, process and secure the world's data with semiconductor solutions designed for our customers' current needs and future ambitions. Through a process of deep collaboration and transparency, we're ultimately changing the way tomorrow's enterprise, cloud, automotive, and carrier architectures transform—for the better.
>
> \###
>
> Marvell and the M logo are trademarks of Marvell or its affiliates. Please visit www.marvell.com for a complete list of Marvell trademarks. Other names and brands may be claimed as the property of others.
>
> This press release contains forward-looking statements within the meaning of the federal securities laws that involve risks and uncertainties. Forward-looking statements include, without limitation, any statement that may predict, forecast, indicate or imply future events, results or achievements. Actual events, results or achievements may differ materially from those contemplated in this press release. Forward-looking statements are only predictions and are subject to risks, uncertainties and assumptions that are difficult to predict, including those described in the "Risk Factors" section of our Annual Reports on Form 10-K, Quarterly Reports on Form 10-Q and other documents filed by us from time to time with the SEC. Forward-looking statements speak only as of the date they are made. Readers are cautioned not to put undue reliance on forward-looking statements, and no person assumes any obligation to update or revise any such forward-looking statements, whether as a result of new information, future events or otherwise.
>
> **For further information, contact:**
> Kim Markle
> [pr@marvell.com](mailto:pr@marvell.com)
