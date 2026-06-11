---
created: 2026-06-11
published: 2026-03-11
description: TrendForce forecasts co-packaged optics climb from ~0.5% of AI-datacenter optical modules in 2026 to ~35% by 2030, gated by silicon-photonics/CPO maturity at NVIDIA's Rubin Ultra–Feynman scale-up generations — the exact 0.5%→35% curve circulating bull theses had attributed to TrendForce.
source: https://www.trendforce.com/presscenter/news/20260311-12962.html
type: research
authors: ["TrendForce"]
---

# TrendForce 2026-03-11 — CPO penetration in AI data centers rises from ~0.5% (2026) to ~35% (2030) on NVIDIA scale-up optical interconnects at Rubin Ultra–Feynman

This is the TrendForce release that **resolves a previously-unverified figure**: the "CPO penetration ~0.5% (2026) → ~35% (2030)" curve that circulating bull theses attributed to TrendForce. Three earlier TrendForce captures in this folder ([[TrendForce - AI optical transceiver market hits 26B USD in 2026 (+57 pct from 16.5B) with roadmaps accelerating toward LPO and silicon photonics over DSP]], [[TrendForce - 800G-plus transceiver shipments jump 2.6x to ~63M units in 2026 as NVIDIA EML lock-in extends laser lead times beyond 2027]], [[TrendForce - 800G-plus transceiver shipment share climbs from 19.5 pct (2024) to over 60 pct by 2026 on Google Ironwood Apollo OCS architecture]]) could not source it. This March 11, 2026 release contains it verbatim — closing the open question flagged in [[MXL bull case evaluated claim-by-claim 2026-06 - extended pluggable window real but MXL-specific moats unsourced, 1.6T supplier count is 4 not 3, analog optionality genuine]].

## Key Takeaways

- **The exact figure, sourced at last.** TrendForce states CPOs "will account for only about 0.5% of optical transceiver modules used in AI data centers in 2026" and "could reach approximately 35% penetration of AI data centers by around 2030." The accompanying chart gives the full annual curve: **0.05% (2025), 0.55% (2026F), 2.21% (2027F), 7.23% (2028F), 22.07% (2029F), 35.74% (2030F)** — a sharply back-loaded S-curve, not a linear ramp. The penetration is on transceiver *modules* (800G + 1.6T + 3.2T), so the 35% lands as 1.6T/3.2T volumes inflect. This is the curve that bull theses cited and that the MXL claim-by-claim audit could not previously verify.

- **The inflection is gated by NVIDIA scale-up timing, not 2026 demand.** TrendForce ties the ramp to silicon-photonics/CPO *packaging maturity*: SiP+CPO is "first adopted for scale-out inter-rack data transmission in the NVIDIA Rubin generation," and "scale-up optical interconnects spanning multiple racks could emerge as early as the **Rubin Ultra or Feynman** generations as silicon photonics and CPO packaging technologies mature." So the 22%→35% jump in 2029–2030 is a bet on Rubin Ultra/Feynman scale-up adoption — the same Feynman (~2028) endpoint-injection thesis argued in [[SemiAnalysis CPO book argues co-packaged optics is central to scale-up not scale-out, with Nvidia CPO endpoints injected at Feynman ~2028 not Rubin Ultra]].

- **Copper survives within-rack through ~2028 — bounding the near-term CPO opportunity.** Per Broadcom, copper stays "the dominant option for ultra-short-reach interconnects within racks through at least 2028" on cost/power. CPO only displaces it once scale-up grows cross-rack (e.g. a 576-GPU cluster of eight NVL72 systems), where NVLink 6's 400G SerDes / 3.6 TB/s-per-GPU ceiling makes copper degrade past ~1 meter. This is why penetration stays sub-8% through 2028 in the chart — the extended-pluggable-window logic that underpins the [[MXL bull case evaluated claim-by-claim 2026-06 - extended pluggable window real but MXL-specific moats unsourced, 1.6T supplier count is 4 not 3, analog optionality genuine]] thesis.

- **Mechanism: TSMC COUPE + 200G PAM4 MRMs, plus NVIDIA's $4B laser lock-in.** NVIDIA's CPO/SiP approach uses [[TSMC (TSM)]] COUPE 3D packaging to stack logic + photonics, integrating 200G PAM4 micro-ring modulators (MRMs) on the SiP die — see [[PhotonCap 2026-05 - 7 companies own the 4-stage CPO test stack as TSMC COUPE production ramps, 100 seconds per PIC bottleneck]]. The $4B [[Nvidia (NVDA)]] investment split evenly between [[Lumentum (LITE)]] and [[Coherent (COHR)]], with multi-year priority procurement of laser/optical components, is read as securing the CW-laser supply that CPO/NPO consumes.

*TrendForce CPO penetration in AI data centers 2025–2030F: shipment of transceivers (800G+1.6T+3.2T) vs CPO units, with CPO penetration rate rising 0.05% → 35.74%*
![[trendforce-20260311-001.jpg]]

## External Resources

- [TrendForce Semiconductor Research / DRAM reports](https://www.trendforce.com/research/dram) — source department for this forecast
- [TrendForce news index](https://www.trendforce.com/news/)

## Original Content

> [!quote]- Source Material — TrendForce press release, 11 March 2026
> # NVIDIA Compute Architecture Paves the Way for Scale-Up Optical Interconnects; CPO Penetration in AI Data Centers Expected to Rise Steadily, Says TrendForce
>
> 11 March 2026 — Semiconductors — TrendForce
>
> NVIDIA’s next-generation AI compute rack architecture indicates that future GPU designs will increasingly prioritize higher chip-to-chip interconnect density and faster data transmission, according to TrendForce’s latest research on the high-speed interconnect market. Intra-rack chip interconnects (scale-up) and large-scale interconnects across racks (scale-out) will become central considerations in data center design as AI clusters continue to scale.
>
> Traditional electrical transmission using copper cables faces physical limitations and will struggle to support the massive data movement required by next-generation AI infrastructure. As a result, optical transmission technologies are gaining greater importance.
>
> TrendForce forecasts that co-packaged optics (CPOs) will steadily increase their share of optical communication modules in AI data centers, with penetration potentially reaching 35% by 2030.
>
> NVIDIA’s NVLink 6 communication protocol defines 400G SerDes per lane as the peak transmission rate, with a bandwidth ceiling of 3.6 TB/s per GPU. At such extreme transmission speeds, electrical signals over copper degrade rapidly with distance, effectively limiting copper interconnects to distances of less than one meter.
>
> Nevertheless, Broadcom believes ongoing advances in SerDes technology will continue to push physical limits. Copper-based solutions are expected to remain the dominant option for ultra-short-reach interconnects within racks through at least 2028, thanks to their cost advantages and relatively low power consumption.
>
> However, as chip interconnect scales expand and the scale-up configuration grows from a single rack to cross-rack deployments (e.g., a 576-GPU cluster composed of eight NVIDIA NVL72 systems), copper-based interconnects will no longer be able to meet the required performance and bandwidth demands.
>
> Optical transmission offers a clear advantage through wavelength-division multiplexing (WDM), which enables multiple wavelengths to be carried over a single fiber. This dramatically increases transmission density—an advantage that copper-based transmission cannot match.
>
> Consequently, major CSPs are collaborating with emerging startups to develop new optical interconnect solutions, preparing for the next wave of bandwidth demand while laying the groundwork for the broader adoption of CPO technology.
>
> **Industry leaders deepen investments as AI infrastructure becomes more dependent on optical technologies**
>
> NVIDIA’s recent approach to CPO and silicon photonics involves utilizing TSMC’s COUPE 3D packaging technology to stack logic and photonics chips. By integrating 200G PAM4 micro-ring modulators (MRMs) onto the silicon photonics die, they enhance optical engine bandwidth density while keeping the size small and reducing power use.
>
> NVIDIA has also recently announced a US$4 billion investment, split evenly between Lumentum and Coherent, alongside multi-year procurement agreements securing priority access to advanced laser and optical components. These moves indicate that NVIDIA is strategically securing critical components for future scale-up optical interconnects while taking a more active role in the development of next-generation laser and photonic technologies. It also signals that future AI compute infrastructure will rely increasingly on optical technologies.
>
> TrendForce expects optical interconnect technologies based on silicon photonics and CPO to be first adopted for scale-out inter-rack data transmission in the NVIDIA Rubin generation. These technologies are also planned to be integrated into future scale-up interconnect architectures to enable higher bandwidth density. It is estimated that CPOs will account for only about 0.5% of optical transceiver modules used in AI data centers in 2026.
>
> Scale-up optical interconnects spanning multiple racks could emerge as early as the Rubin Ultra or Feynman generations as silicon photonics and CPO packaging technologies mature. As data transmission bandwidth continues to increase, TrendForce forecasts that silicon-photonics-based CPO solutions could reach approximately 35% penetration of AI data centers by around 2030. Meanwhile, new optical technologies, including advanced optical interconnect architectures and optical I/O, are also likely to emerge.
>
> *CPO Penetration in AI Data Centers, 2025–2030F (Source: TrendForce, Mar. 2026). Bars: Transceiver (800G+1.6T+3.2T) shipment and CPO (800G+1.6T+3.2T) shipment in M pcs; line: CPO penetration rate — 0.05% (2025), 0.55% (2026F), 2.21% (2027F), 7.23% (2028F), 22.07% (2029F), 35.74% (2030F).*
> ![[trendforce-20260311-001.jpg]]

[Original press release →](https://www.trendforce.com/presscenter/news/20260311-12962.html)
