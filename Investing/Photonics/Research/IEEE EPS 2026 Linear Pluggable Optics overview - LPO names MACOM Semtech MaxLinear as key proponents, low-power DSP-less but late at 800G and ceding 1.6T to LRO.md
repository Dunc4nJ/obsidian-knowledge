---
created: 2026-06-10
published: 2026-03-05
description: IEEE Electronics Packaging Society overview of Linear Pluggable Optics (LPO) — high-linearity TIA / DSP-less architecture, names MACOM, Semtech and MaxLinear as key industry proponents, but flags late 800G adoption and LRO as the better near-term choice at 1.6T.
source: https://eps.ieee.org/wp-content/uploads/2026/03/Linear-Pluggable-Optics_V2-UPDATED.pdf
type: research
authors: ["Sujit Ramachandra (Celestial AI)", "Farnood Rezaie (Cisco Systems Inc.)"]
---

# IEEE EPS 2026 Linear Pluggable Optics overview

IEEE Electronics Packaging Society (EPS) overview white paper on Linear Pluggable Optics (LPO), authored by Sujit Ramachandra (Celestial AI) and Farnood Rezaie (Cisco Systems Inc.). V2 (updated), hosted on the EPS site March 2026; the PDF's own document metadata is dated 2026-03-05. Captured to verify the figures and quotes circulating in [[MaxLinear (MXL)]] LPO bull theses.

## Key Takeaways

This note exists to fact-check specific claims circulating in MaxLinear bull theses against the paper's actual wording. Each item below quotes the paper verbatim; where a circulating figure does NOT appear in the paper, that is stated explicitly.

- **(a) LPO = high-linearity TIAs, no DSP, advantages are power + latency — CONFIRMED, verbatim.** The paper states: *"LPO systems (Fig. 2) are characterized by high-linearity Transimpedance Amplifiers (TIAs) and the absence of power-hungry Digital Signal Processors (DSPs) / Clock Data Recovery (CDR) in the system."* and *"The main advantages offered by LPO are reduced power consumption and lower system latency due to the absence of the DSP and reducing the operational costs."* So both the high-linearity-TIA characterization and the "power + latency from DSP absence" advantage framing are present exactly as the bull theses claim.

- **(b) MACOM, Semtech, MaxLinear named as key proponents — CONFIRMED, verbatim, one sentence.** *"Some of the key proponents of LPO in the industry are Macom, Semtech and Maxlinear."* Note the spelling in the source: "Macom" and "Maxlinear". This is the exact sentence the [[MACOM Technology (MTSI)]] / [[Semtech (SMTC)]] / [[MaxLinear (MXL)]] theses cite. [[Credo Technology (CRDO)]] is NOT named among the proponents in this paper.

- **(c) DSP ~14-17W vs LPO ~7-8.5W (40-50% reduction) — NOT IN THIS PAPER.** The circulating "14-17W DSP module vs 7-8.5W LPO module, a 40-50% power reduction" figure does **not** appear anywhere in this white paper. The paper makes the qualitative claim that LPO offers "reduced power consumption" vs DSP-based optics but gives **no per-module wattage numbers for the DSP-vs-LPO comparison and no percentage**. The **only** absolute wattage figures in the paper are for **1.6T LRO**: initial 1.6T LRO solutions *"require > 30W of power"* and LRO *"offers the promise of reduction in power below 20W."* Anyone sourcing the 14-17W / 7-8.5W / 40-50% numbers to this IEEE EPS paper is misattributing — those numbers come from elsewhere (the paper's references include Cignal AI's "The Linear Drive Market Opportunity" and fast-photonics.com, which may be the true source).

- **(d) 800G late-adoption / reduced-reach caveat — CONFIRMED, verbatim.** Reduced reach: *"Some of the drawbacks of LPO systems are reduced transmission distances owing to higher BER (due to the lack of a DSP), lack of well-defined industry standards and added complexity to the SerDes, which makes compatibility with 200G SerDes difficult to achieve."* Late at 800G: *"it remains the general opinion that LPO will be a small part of the market, at least at 800G... Cignal AI's post-OFC 2025 summary also states that 100G/lane (800GbE) LPO is likely late to the market and is expected to only capture a small percentage of pluggable share in the long term. This is a consequence of the data center infrastructures that have already been designed to be DSP-compatible."* This is the bear caveat: entrenched DSP-compatible infrastructure pushes 800G LPO to a small, late slice of share.

- **(e) 1.6T / 3.2T and NPO/CPO interplay — PARTIAL.** At 1.6T the paper explicitly favors LRO over LPO: *"At 200G/lane or 1.6Tbps, LRO is expected to be a better choice since the initial solutions require > 30W of power... LRO offers the promise of reduction in power below 20W, with the use of transmit-DSPs... but simplifies integration density and interoperability. Cignal notes that every company they interacted with during OFC that demonstrated 1.6T LPO also had exhibits of LRO-based solutions."* (Notably, [[Marvell Technology (MRVL)]] — "traditionally known for their DSPs" — markets a 200G/lane TIA + laser-driver chipset for both 800G and 1.6T LPO, hedging across the architectures.) The summary repeats: *"At 1.6T, power and thermal challenges (>30W) make LRO a more viable near-term solution."* On CPO, the paper positions LPO as a lower-risk evolutionary path: *"LPO is seen as a natural evolutionary path for pluggables, offering lower risk compared to CPO, especially in terms of reliability"* while *"CPO delivers improvements in both data rate and power efficiency due to its integrated architecture."* **3.2T is NOT mentioned anywhere in this paper. NPO (near-packaged optics) is NOT mentioned at all** — the paper's architecture taxonomy is LRO, LPO and CPO only. So any thesis invoking this paper for a 3.2T or NPO claim is reaching beyond what it says.

- **Net read for the MXL thesis:** the paper firmly supports the architecture story (DSP-less, high-linearity TIA, power/latency advantage) and the proponent name-drop (MACOM, Semtech, MaxLinear), and it does flag the well-known 800G headwind. On the demo/momentum side it credits [[Eoptolink (300502.SZ)]] (200G/λ LPO at OFC 2024; founding LPO-MSA member with MACOM) and the Alphawave + [[Innolight (300308.SZ)]] PCIe-over-LPO collaborations. But it does **not** supply the specific 14-17W vs 7-8.5W power-savings figure, does **not** mention NPO, and does **not** discuss 3.2T — and at 1.6T it actively prefers LRO over LPO. See the broader architecture map in [[@damnang2 optical investment map v1.0 - 7 layers L1 Materials to L7 Test plus FRO LRO LPO NPO CPO axis with 50 names and 22-company vertical integration matrix]] and the CPO-timing debate in [[2026-06-09 CPO-delay dispute - SemiAnalysis report sinks optical names (AAOI -14pct COHR -11pct LITE -8pct) then NVIDIA Shainer rebuts Spectrum-X switch delays but leaves GPU-endpoint CPO thesis intact]].

## Figures

*Figure 1. Typical packaging scheme (Top) and Block diagram (Bottom) of a Pluggable transceiver module — note the DSP block ("Digital Processor") sitting between the analog front-end and the SerDes on both TX and RX paths.*
![[ieee-eps-lpo-001.png]]

*Figure 2. Typical packaging scheme (Top) and Block diagram (Bottom) for LPO solutions — the DSP is gone; the pluggable contains only "Linear TIA + Equalizer" and "Driver + CTLE", with equalization pushed into the switch ASIC's SerDes.*
![[ieee-eps-lpo-002.png]]

*Figure 3. Typical packaging scheme (Top) and Block diagram (Bottom) for LRO solutions — "DSP (TX Path Only)": the transmit DSP is retained to meet IEEE 802.3 integrity standards while the receive DSP is eliminated.*
![[ieee-eps-lpo-003.png]]

## External Resources

- [2024 United States Data Center Energy Usage Report (LBNL)](https://eta-publications.lbl.gov/sites/default/files/2024-12/lbnl-2024-united-states-data-center-energy-usage-report.pdf) — Dec 2024; source for the data-center electricity-consumption figures cited in the intro.
- [Linear Pluggable Optics (LPO) & Linear Receive Optics (LRO): a Practical Comparison — fast-photonics.com](https://fast-photonics.com/linear-pluggable-optics-and-linear-receive-optics/) — John Jonson; the paper's LPO reference [3].
- [Eoptolink — Industry 1st 200G per lane LPO 800G Optical Transceivers](https://www.eoptolink.com/news/13-new-products/348-eoptolink-demonstrates-industry-1st-200g-lane-lpos-with-100g-lane-800g-lpos-entering-mass-production) — March 2024 demo.
- [MACOM to Showcase 200G per Lane Products at OFC](https://ir.macom.com/news-releases/news-release-details/macom-showcase-200g-lane-products-optical-fiber-communication) — March 2024; PURE DRIVE 200 Gbps LPO.
- [LPO-MSA](https://www.lpo-msa.org/home.html) — Multi-Source Agreement (MACOM and Eoptolink founding members).
- [Marvell Introduces 1.6 Tbps LPO Chipset](https://www.marvell.com/company/newsroom/marvell-introduces-1-6-tbps-lpo-chipset.html) — Dec 2024; 200G/lane TIA + laser driver for 800G/1.6T LPO.
- [Alphawave Semi + InnoLight low-latency LPO with PCIe 6.0 subsystem at OFC 2024](https://awavesemi.com/press-release/alphawave-semi-and-innolight-collaborate-to-demonstrate-low-latency-linear-pluggable-optics-with-pcie-6-0-subsystem-solution-for-high-performance-ai-infrastructure-at-ofc-2024/) — March 2024.
- [Cignal AI — The Linear Drive Market Opportunity](https://cignal.ai/2023/08/linear-drive-market-opportunity/) — Aug 2023; the report behind the "LPO small at 800G" view.

Original PDF: <https://eps.ieee.org/wp-content/uploads/2026/03/Linear-Pluggable-Optics_V2-UPDATED.pdf>

## Original Content

> [!quote]- Source Material — "Linear Pluggable Optics – An Overview" (IEEE EPS, V2 updated)
>
> # Linear Pluggable Optics – An Overview
>
> Sujit Ramachandra (Celestial AI), Farnood Rezaie (Cisco Systems Inc.)
>
> **Introduction:**
>
> With the advent of Artificial intelligence (AI) and the push to increase domestic manufacturing, the data center workloads and associated power consumption is growing, having tripled in the past decade. According to the 2024 Report on U.S Data Center Energy Use [1], published by the Lawrence Berkeley National Laboratory, data centers account for 4.4% of total electricity consumption in the U.S. in 2023, and are projected to increase to 6.7 to 12% by 2028. The total data center electricity usage grew from 58 TWh in 2014 to 176 TWh in 2023 and is expected to reach around 325 to 580 TWh by 2028. A significant portion of the energy consumption at data centers is attributed to the interconnects in the data centers, with their push to attain higher speeds [2].
>
> **Comparison of proposed solutions:**
>
> In response, several solutions such as Linear Receive Optics (LRO), Linear Pluggable Optics (LPO) [3] and Co-Packaged Optics (CPO) [4] have been proposed. Fig. 1 shows the typical block diagram of a pluggable transceiver consisting of on-board lasers, optics, a Photonics die housing the modulator, the photodetector, and associated photonic components required for the optical path, an Electrical IC with the Modulator driver and the Transimpedance Amplifier (TIA), and a Digital Signal Processor (DSP) for equalization on the Transmit (TX) and Receive (RX) paths. The switch ASIC contains SerDes for data transfer to/from the transceiver module and the digital circuit for data processing.
>
> *Figure 1. Typical packaging scheme (Top) and Block diagram (Bottom) of a Pluggable transceiver module*
>
> ![[ieee-eps-lpo-001.png]]
>
> LPO systems (Fig. 2) are characterized by high-linearity Transimpedance Amplifiers (TIAs) and the absence of power-hungry Digital Signal Processors (DSPs) / Clock Data Recovery (CDR) in the system. Instead, the signal regeneration and signal equalization that are typically performed by the DSP are split between the switch ASIC, the driver IC and the TIA. Some of the key proponents of LPO in the industry are Macom, Semtech and Maxlinear. The main advantages offered by LPO are reduced power consumption and lower system latency due to the absence of the DSP and reducing the operational costs. The system retains a pluggable form factor allowing for easy servicing, interoperability and hot swapping of modules. Some of the drawbacks of LPO systems are reduced transmission distances owing to higher BER (due to the lack of a DSP), lack of well-defined industry standards and added complexity to the SerDes, which makes compatibility with 200G SerDes difficult to achieve.
>
> *Figure 2. Typical packaging scheme (Top) and Block diagram (Bottom) for LPO solutions*
>
> ![[ieee-eps-lpo-002.png]]
>
> Similar to LPO, LRO systems (Fig. 3) eliminate the DSP on the receiver but retain it in the transmit path to meet integrity standards (IEEE 802.3). Hence, this solution trades off power-efficiency for performance. This extends the data transmission distances due to lower system BER and allows interoperability as the transmitter is designed to be compliant with existing standards.
>
> *Figure 3. Typical packaging scheme (Top) and Block diagram (Bottom) for LRO solutions*
>
> ![[ieee-eps-lpo-003.png]]
>
> **Comparison to CPO**
>
> By design, LPO offers a scalable path to reconciling high data rates with low power consumption for pluggable modules, while CPO enables direct integration of photonics onto the switch IC, thereby eliminating the need for a standalone module. Although CPO is becoming increasingly popular, LPO is seen as a natural evolutionary path for pluggables, offering lower risk compared to CPO, especially in terms of reliability.
>
> From a serviceability standpoint, LPO enables the use of pluggable modules that can be hot swapped, whereas CPO introduces challenges due to its tighter integration. This increased integration in CPO also brings more demanding reliability requirements, driven by greater temperature excursions, added system complexity, and higher overall solution costs compared to LPO-based solutions. Despite these drawbacks, CPO delivers improvements in both data rate and power efficiency due to its integrated architecture. LPO, on the other hand, leverages each segment of the link to create a power, cost, and latency-optimized connection while preserving the flexibility offered by pluggable optics.
>
> **Industry Trends**
>
> LPO as technology has seen considerable traction in the industry with several designs and solutions proposed over the years.
>
> Eoptolink Technology Inc. demonstrated a 200G/λ LPO solution at OFC 2024 with 4 parallel channels. The system, as is characteristic to LPO, does not use any DSP or (Clock and Data Recovery) CDRs. In addition, they also launched the 2nd generation of their 100G/lane 800G and 400G LPO products for single mode applications in OSFP, QSFP-DD and QSFP112 form-factors that claim to achieve full TP2 compliance at the transmit interface. Both the Gen1 and Gen 2 solutions are offered at high volume [5].
>
> OFC 2024 also saw demonstrations from MACOM, exhibiting their PURE DRIVE TM 200 Gbps LPO solution [6]. This extends the system to support up to 212 Gbps per lane and enable the development of a 1.6T LPO module. The main highlight of this exhibit was their TIA and Driver design, key elements of a successful LPO system (especially since the DSP is absent).
>
> Both MACOM and Eoptolink are founding members of the LPO Multi-Source Agreement (MSA) [7] that includes key industry players that are collectively developing specifications for networking equipment and optical modules to enable an ecosystem of interoperable LPO solutions. The main aim of these specifications remains the reduction of power and cost while improving the data rate.
>
> Marvell Inc., traditionally known for their DSPs have also announced the availability of a 200G/lane TIA and laser driver chipset that enable 800 Gbps and 1.6 Tbps LPO solutions, aimed at addressing next generation XPU compute fabric networks [8]. Alphawave and Innolight also made a series of announcements in 2024, starting with the live demonstration of a 64 Gbps/lane PCIe 6.0 subsystem (Controller + PHY) leveraging Innolight's LPO OSFP optical platform during OFC 2024 [9]. This was followed by an update in September 2024, showcasing a 128 Gbps/lane LPO platform, featuring Alphawave's PCIe 7.0 – ready SerDes PHY and Innolight's LPO OSFP optics. Both the above solutions aim to cater to the increasing demands for larger and faster AI network nodes, which in turn are increasing the demand for higher PCIe speeds.
>
> OFC 2025 also featured several prominent LPO demos, with the OIF showing multiple 100G/lane and 200G/lane interoperability. Regardless, it remains the general opinion that LPO will be a small part of the market, at least at 800G, as put forward in Cignal AI's 2023 report titled "The Linear Drive Market Opportunity" [10]. Cignal AI's post-OFC 2025 summary also states that 100G/lane (800GbE) LPO is likely late to the market and is expected to only capture a small percentage of pluggable share in the long term. This is a consequence of the data center infrastructures that have already been designed to be DSP-compatible. However, Juniper's Broadcom based QFX switches support LPO optics without requiring modifications to the hardware and Arista's demonstrations of Broadcom TH5 compatibility for over 2 years show some continued effort in LPO deployment.
>
> At 200G/lane or 1.6Tbps, LRO is expected to be a better choice since the initial solutions require > 30W of power, presenting challenges to efficiently managing the thermals. LRO offers the promise of reduction in power below 20W, with the use of transmit-DSPs with the caveat of higher power consumption compared to LPO, but simplifies integration density and interoperability. Cignal notes that every company they interacted with during OFC that demonstrated 1.6T LPO also had exhibits of LRO-based solutions.
>
> **Summary**
>
> LPO technology is gaining traction as a low-power, cost-effective alternative to DSP-based optics, with key demonstrations at OFC 2024 and 2025 by Eoptolink, MACOM, Marvell, Alphawave, and Innolight. These systems, spanning 100G to 200G per lane, highlight advances in analog components and signal integrity without the need for DSPs or CDRs. The LPO MSA aims to standardize interoperability, but adoption remains limited, especially at 800G due to entrenched DSP-based infrastructure. While platforms from Juniper and Arista support LPO optics, deployment is still emerging.
>
> At 1.6T, power and thermal challenges (>30W) make LRO a more viable near-term solution. LRO reintroduces a transmit DSP, trading some efficiency for better integration and thermal management. LPO architecture holds promise for AI and PCIe connectivity where power efficiency is critical but broader adoption will depend on ecosystem alignment, performance scaling, and standardization.
>
> **References**
>
> [1]. "2024 United States Data Center Energy Usage Report", Arman Shehabi, et. al., https://eta-publications.lbl.gov/sites/default/files/2024-12/lbnl-2024-united-states-data-center-energy-usage-report.pdf, December 2024.
>
> [2]. "OFC 2025 Show Report", OFC 2025 Show Report - Cignal AI, 2025
>
> [3]. John Jonson, "Linear Pluggable Optics (LPO) & Linear Receive Optics (LRO): a Practical Comparison", fast-photonics.com, https://fast-photonics.com/linear-pluggable-optics-and-linear-receive-optics/ (accessed: Jul. 5, 2024)
>
> [4]. S Razdan, M Traverso, et. al., "Co-packaged Optics Integration for Hyperscale Networking", IEEE EPS eNews, August 2023.
>
> [5]. "Eoptolink Demonstrates Industry 1st 200G per lane LPO 800G Optical Transceivers", https://www.eoptolink.com/news/13-new-products/348-eoptolink-demonstrates-industry-1st-200g-lane-lpos-with-100g-lane-800g-lpos-entering-mass-production, Chengdu, China and San Diego, California, March 22, 2024
>
> [6]. "MACOM to Showcase 200G per Lane Products at Optical Fiber Communication Conference and Exhibition (OFC)", https://ir.macom.com/news-releases/news-release-details/macom-showcase-200g-lane-products-optical-fiber-communication, March 2024.
>
> [7]. "LPO-MSA", https://www.lpo-msa.org/home.html, (accessed: 05/2025)
>
> [8]. "Marvell Introduces 1.6 Tbps LPO Chipset to Enable Optical Short-reach, Scale-up Compute Fabric Interconnects", https://www.marvell.com/company/newsroom/marvell-introduces-1-6-tbps-lpo-chipset.html, December 2024
>
> [9]. "Collaboration extends Alphawave Semi and InnoLight's leadership in optical connectivity with proven readiness for scaling AI infrastructure", https://awavesemi.com/press-release/alphawave-semi-and-innolight-collaborate-to-demonstrate-low-latency-linear-pluggable-optics-with-pcie-6-0-subsystem-solution-for-high-performance-ai-infrastructure-at-ofc-2024/, March 2024
>
> [10]. "The Linear Drive Market Opportunity", https://cignal.ai/2023/08/linear-drive-market-opportunity/, August 2023.
