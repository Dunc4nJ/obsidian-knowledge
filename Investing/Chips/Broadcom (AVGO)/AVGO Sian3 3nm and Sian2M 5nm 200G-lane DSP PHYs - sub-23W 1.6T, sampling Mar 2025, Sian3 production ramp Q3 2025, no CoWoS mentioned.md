---
created: 2026-06-10
published: 2025-03-25
description: Broadcom's March 2025 Sian-family launch — Sian3 (3nm SMF DSP, sub-13W 800G / sub-23W 1.6T, >20% power cut vs Sian2) and Sian2M (5nm MMF DSP with integrated VCSEL drivers) — sampling at launch with Sian3 production ramping Q3 2025; the release never mentions CoWoS or advanced packaging.
source: https://investors.broadcom.com/news-releases/news-release-details/broadcom-extends-200glane-dsp-phy-leadership-next-generation-ai
type: research
---

# AVGO Sian3 (3nm) and Sian2M (5nm) 200G/lane DSP PHYs — sub-23W 1.6T, sampling Mar 2025, Sian3 production ramp Q3 2025, no CoWoS mentioned

This is the primary-source [[Broadcom (AVGO)]] press release (March 25, 2025) for the Sian3 and Sian2M 200G/lane PAM4 DSP PHYs. It is captured specifically as a reality-check against bull claims circulating around [[MaxLinear (MXL)]] — namely that MXL is the "ONLY 1.6T DSP vendor with guaranteed fab capacity through 2H27" and that Broadcom's DSPs "require CoWoS which is even more backlogged." Read against the [[MaxLinear (MXL)]] briefing note, which states the AVGO/[[Marvell Technology (MRVL)]] DSPs "sit in the TSMC/CoWoS queue."

## Key Takeaways

Verbatim claims from the release, mapped to the five questions the capture was meant to resolve. **Statements of absence are flagged explicitly** where the release is silent.

**(a) Products / node / fab.** Two products. Verbatim:
- Sian3: *"a state-of-the-art 3nm 200G/lane PAM4 DSP PHY"* — *"Low power 3nm 200G/lane DSP for sub-13W 800G and sub-23W 1.6T transceivers"*, for **single-mode fiber (SMF)**. Carries part numbers *"1.6T retimer PHY (BCM83628) and 800G gearbox PHY (BCM83820)."* It *"builds upon the success of Broadcom's Sian2 DSP, enabling over 20% power reduction for both EML and SiP based 1.6T modules."*
- Sian2M: *"Low power 5nm 200G/lane DSP for sub-25W 1.6T SR8 transceivers"* with *"Integrated VCSEL driver"*, for short-reach **multi-mode fiber (MMF)**; part number *"800G retimer PHY (BCM85834)."* Described as *"Industry's first 200G/lane DSP with integrated VCSEL drivers."*
- **FAB: not stated.** The release names the nodes (3nm for Sian3, 5nm for Sian2M) but **names no foundry** — there is no mention of TSMC, Samsung, or any fab. (The [[MaxLinear (MXL)]] briefing infers AVGO is on the TSMC supply chain; that inference is NOT corroborated by this primary source.) This release is also where the "3nm" Broadcom figure originates — relevant to the bull-thread "4nm vs 3nm GAA" confusion documented on the MXL side, which concerns MXL's own Rushmore node, not Sian3.

**(b) Sampling / production / availability timing.** Verbatim: *"Broadcom is sampling Sian3 (BCM83628 and BCM83820) and Sian2M (BCM85834) to early access customers and partners, with **Sian3 production ramping in Q3 2025**."* Note the release gives **no production-ramp date for Sian2M** — only Sian3 has a stated ramp. Separately, supporting components are already in volume: *"Broadcom's 200G EML and PD are already shipping in volume"* and *"200G EML in production, with millions of units shipped."*

**(c) Power-per-bit / power claims.** No per-bit figure; power is stated as per-module envelopes and a relative reduction. Verbatim:
- *"delivers the industry's lowest power consumption for 800G and 1.6T optical transceivers utilizing SMF"*
- *"enabling over 20% power reduction for both EML and SiP based 1.6T modules"* (Sian3 vs Sian2)
- Sian3 envelopes: *"sub-13W 800G and sub-23W 1.6T transceivers"*; *"Sub-75ns roundtrip latency for AI/ML."*
- Sian2M envelope: *"sub-25W 1.6T SR8 transceivers."*

**(d) CoWoS / advanced packaging — what the release actually says: NOTHING.** The words "CoWoS," "advanced packaging," "2.5D," "interposer," "co-packaged," and "CPO" **do not appear anywhere in this release.** Sian3 and Sian2M are described as standalone DSP PHY / retimer / gearbox chips with part numbers, integrated laser/VCSEL drivers, and SERDES — i.e., monolithic mixed-signal silicon, not chiplet/interposer assemblies. This is direct evidence that the circulating "Broadcom's DSPs require CoWoS" claim is, at minimum, **not supported by Broadcom's own DSP launch material**. The most likely confusion: CoWoS is associated with Broadcom's *switch ASICs / custom AI accelerators / co-packaged-optics (CPO) switches* (Tomahawk-class, see the [[Broadcom (AVGO)]] hub) — large logic dies that genuinely use [[TSMC (TSM)]] CoWoS — **not** these pluggable-transceiver DSP PHYs. Conflating a pluggable PAM4 DSP with a CPO switch ASIC appears to be the source of the error. (Caveat: silence is not the same as a denial — the release does not affirmatively state Sian3 is monolithic or CoWoS-free; it simply never raises packaging at all.)

**(e) Timing vs MaxLinear Rushmore and Marvell Ara.** This release is dated **March 25, 2025** — sampling at that date, Sian3 production ramp Q3 2025.
- **vs MaxLinear Rushmore (sampled ~March 2025):** essentially **contemporaneous sampling.** Sian3 is contention to the idea that MXL is uniquely early or uniquely supplied at 1.6T — AVGO was sampling its own 1.6T-class 200G/lane DSP the same month. Note the *node* differs (Sian3 = 3nm per this release; Rushmore = Samsung 4nm per company materials, with some bull threads claiming 3nm GAA — see [[MaxLinear (MXL)]] open questions).
- **vs Marvell Ara:** **the release is silent.** It makes no reference to [[Marvell Technology (MRVL)]], Ara, or any competitor by name. Any Sian3-vs-Ara timing comparison must be sourced elsewhere; this primary source supports only the AVGO sampling/ramp dates above.

**Third-party market framing in the release:** LightCounting's Bob Wheeler is quoted — *"By 2028, we expect 1.6T optical transceivers will consume more than $1 billion worth of PAM4 DSPs, as next-generation 102T switch systems transition to 200G serdes."* Customer endorsement from Eoptolink (Richard Huang, CEO) confirms design-in intent. Neither addresses fab capacity or packaging.

## External Resources

- [Broadcom IR — original press release](https://investors.broadcom.com/news-releases/news-release-details/broadcom-extends-200glane-dsp-phy-leadership-next-generation-ai)
- LightCounting report referenced: *"Markets for PAM4 and Coherent DSPs"* (analyst: Bob Wheeler, Analyst at Large, LightCounting)
- Named launch customer: Eoptolink Technology (transceiver module maker)

## Original Content

> [!quote]- Source Material — Broadcom Inc. press release, March 25, 2025 (GlobeNewswire)
> **Broadcom Extends 200G/lane DSP PHY Leadership for Next-Generation AI Infrastructure**
>
> _Sian3: State-of-the-art 3nm DSP PHY delivers industry's lowest power consumption with enhanced performance for 800G and 1.6T optical transceivers over SMF_
>
> _Sian2M: Industry's first 200G/lane DSP with integrated VCSEL drivers enables low-power short-reach MMF links in AI clusters_
>
> PALO ALTO, Calif., March 25, 2025 (GLOBE NEWSWIRE) -- Broadcom Inc. (NASDAQ: AVGO) today announced the expansion of its industry-leading 200G/lane DSP PHY portfolio with the introduction of Sian3 and Sian2M, purpose-built for the demanding connectivity requirements of AI/ML clusters. These innovations address the critical need for optimized power across both single-mode fiber (SMF) and short-reach multi-mode fiber (MMF) links in 800G and 1.6T optical transceiver applications.
>
> The rapid growth of AI workloads is driving demand for increased bandwidth and interconnect density in AI clusters. Optical interconnect power is a major factor limiting cluster scalability. Broadcom's new Sian3 and Sian2M DSPs, along with its comprehensive portfolio of 200G/lane lasers, provide unprecedented levels of power efficiency and cost optimization for next-generation AI infrastructure.
>
> Sian3, a state-of-the-art 3nm 200G/lane PAM4 DSP PHY, delivers the industry's lowest power consumption for 800G and 1.6T optical transceivers utilizing SMF. Sian3 builds upon the success of Broadcom's Sian2 DSP, enabling over 20% power reduction for both EML and SiP based 1.6T modules.
>
> Sian2M offers a specialized, optimized solution for 800G and 1.6T short-reach MMF links within AI clusters. By integrating VCSEL drivers and leveraging Broadcom's market-proven 200G VCSEL technology, Sian2M unlocks new levels of performance and efficiency for short-reach connectivity. This technology builds on Broadcom's established track record in optical interconnects, having successfully deployed over 50 million channels of 100G VCSELs in AI networks.
>
> Broadcom's Sian3 and Sian2M DSP PHYs, developed in conjunction with its portfolio of 200G/lane EML and CWL lasers and its market-proven VCSELs, empower module developers to rapidly address the growing demand for 200G optics in AI. Broadcom's 200G EML and PD are already shipping in volume, delivering the quality, reliability, and performance required for AI optical interconnects.
>
> "Broadcom's Sian family of DSP PHYs is foundational to the low-power, high-bandwidth optical connectivity needed for AI/ML clusters," said Vijay Janapaty, vice president and general manager of the Physical Layer Products Division at Broadcom. "Our new 3nm Sian3 delivers over 20% power reduction for 1.6T optical modules, while Sian2M with integrated VCSEL drivers and 200G VCSELs brings cost and power efficiency to short-reach links. These innovations enable our customers to scale AI clusters to meet the demands of growing AI workloads."
>
> "According to our recent report Markets for PAM4 and Coherent DSPs, AI-infrastructure build outs are driving massive growth in PAM4 DSP shipments," said Bob Wheeler, Analyst at Large, LightCounting. "By 2028, we expect 1.6T optical transceivers will consume more than $1 billion worth of PAM4 DSPs, as next-generation 102T switch systems transition to 200G serdes."
>
> **Solution Highlights**
>
> Sian3 DSP
>
> * Low power 3nm 200G/lane DSP for sub-13W 800G and sub-23W 1.6T transceivers
> * 1.6T retimer PHY (BCM83628) and 800G gearbox PHY (BCM83820) options available
> * Supports 212.5-Gb/s and 226.875-Gb/s data rates for InfiniBand and Ethernet
> * Multiple FEC options, including Bypass, Segmented, and Concatenated FEC
> * IEEE 802.3dj D1.3 compliant
> * Integrated low-swing and high-swing laser drivers for SiP and EML modules
> * Sub-75ns roundtrip latency for AI/ML
> * Client-side SERDES supporting long-reach (LR) applications
> * Crossbar support on client and line side
>
> Sian2M DSP
>
> * Low power 5nm 200G/lane DSP for sub-25W 1.6T SR8 transceivers
> * 800G retimer PHY (BCM85834) supporting both 800G and 1.6T pluggable modules
> * Multiple FEC options, including Bypass and Segmented FEC
> * Integrated VCSEL driver
> * Crossbar support
>
> 200G/lane Lasers
>
> * Industry's first 200G VCSEL, supporting the planned IEEE 802.3dj standards
> * Broadcom VCSEL technology with >5 trillion field device hours and <1 FIT failure rate
> * 200G EML in production, with millions of units shipped
>
> "As the demand for high-speed, energy-efficient connectivity continues to rise, integrating Broadcom's Sian3 and Sian2M into our transceivers allows us to deliver industry-leading performance with significant cost and power savings," said Richard Huang, CEO, Eoptolink Technology. "By combining these advanced DSPs with our own engineering expertise, we are driving innovation across the ecosystem—enabling scalable, high-density optical connectivity that meets the evolving demands of next-generation AI infrastructure while lowering total cost of ownership."
>
> **Availability**
>
> Broadcom is sampling Sian3 (BCM83628 and BCM83820) and Sian2M (BCM85834) to early access customers and partners, with Sian3 production ramping in Q3 2025. Contact your local Broadcom sales representative for samples and pricing.
>
> **About Broadcom**
>
> Broadcom Inc. (NASDAQ: AVGO) is a global technology leader that designs, develops, and supplies a broad range of semiconductor, enterprise software and security solutions. Broadcom's category-leading product portfolio serves critical markets including cloud, data center, networking, broadband, wireless, storage, industrial, and enterprise software. Our solutions include service provider and enterprise networking and storage, mobile device and broadband connectivity, mainframe, cybersecurity, and private and hybrid cloud infrastructure. Broadcom is a Delaware corporation headquartered in Palo Alto, CA. For more information, go to www.broadcom.com.
>
> Broadcom, the pulse logo, and Connecting everything are among the trademarks of Broadcom. The term "Broadcom" refers to Broadcom Inc., and/or its subsidiaries. Other trademarks are the property of their respective owners.
>
> Press Contact:
> Khanh Lam
> Global Communications
> press.relations@broadcom.com
> Telephone: +1 408 433 8649
>
> Source: Broadcom Inc.

Original URL: https://investors.broadcom.com/news-releases/news-release-details/broadcom-extends-200glane-dsp-phy-leadership-next-generation-ai
