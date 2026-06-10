---
created: 2026-06-10
published: 2025-12-08
description: TrendForce projects 800G-and-above optical transceiver shipments jumping 2.6x from 24M (2025) to nearly 63M units (2026), while NVIDIA's strategic EML capacity lock-in extends laser lead times beyond 2027 and forces non-NVIDIA players toward CW-laser + silicon-photonics designs.
source: https://www.trendforce.com/presscenter/news/20251208-12823.html
type: research
authors: ["TrendForce"]
---

# TrendForce — 800G+ transceiver shipments jump 2.6x to ~63M units in 2026 as NVIDIA EML lock-in extends laser lead times beyond 2027

## Key Takeaways

- **Figure (b) — 800G+ unit shipments, found VERBATIM**: TrendForce states 800G-and-above optical transceiver shipments "will hit 24 million units in 2025, then jump by 2.6 times to nearly 63 million units in 2026." This is the source of the ~2.6x / ~63M-unit figure circulating in [[MaxLinear (MXL)]] bull theses — the volume backdrop for the DSP/PAM4-to-LPO transition story.
- **Figure (e) — InP/EML lead times beyond 2027, found VERBATIM**: "[[Nvidia (NVDA)]], motivated by strategic reasons, has secured capacity at key electro-absorption modulated laser (EML) suppliers, leading to extended lead times beyond 2027 and a worldwide shortage." NVIDIA pre-allocated EML capacity to secure its own pluggable-module supply because its silicon-photonics/CPO plans "advanced more slowly than anticipated."
- **The EML bottleneck reshapes the supplier map**: EMLs come from a thin bench — [[Lumentum (LITE)]], [[Coherent (COHR)]] (Finisar), [[Mitsubishi Electric (MIELY)]], [[Sumitomo Electric (SMTOY)]], and [[Broadcom (AVGO)]]. With NVIDIA holding much of that capacity, optical-module makers and CSPs are pushed toward CW lasers + silicon photonics as the alternative route.
- **CW + silicon photonics is the escape valve — but it has its own crunch**: CW lasers (simpler, no integrated modulation, more suppliers) are "the main alternative route for CSPs facing EML shortages," yet long equipment lead times and labor-intensive die-cutting/aging tests are pushing the CW ecosystem toward its own capacity crunch.
- **Spillover to Taiwan's InP epitaxy foundries**: high-speed 200G photodiodes (PDs) and lasers both ride InP epitaxial wafers; as laser makers prioritize in-house epitaxy, InP epitaxy is outsourced to foundries like IntelliEPI (iET) and VPEC — a structural win for Taiwan's compound-semi epitaxy sector ([[Win Semi (3105.TWO)]] is the listed peer in this space).

Figures (a) AI optical market $16.5B→$26B, (c) 800G+ share 19.5%→>60%, (d) CPO penetration ~0.5%→~35%, and (f) the LPO/silicon-photonics-roadmap quote do NOT appear in this release.

## Supplier landscape (transcribed from the release's chart image)

*TrendForce, Dec. 2025 — "Laser Light Sources and PDs: Key Supplier Landscape" (transcribed verbatim from the release's table-as-image)*

**Key EML Suppliers**

| Region | Key EML Suppliers |
|---|---|
| US | Broadcom (Avago) |
| US | Lumentum |
| US | Coherent (Finisar) |
| JP | Mitsubishi |
| JP | Sumitomo |

**Key CW Laser Suppliers**

| Region | Key CW Laser Suppliers |
|---|---|
| US | Broadcom (Avago) |
| US | Lumentum |
| US | Coherent (Finisar) |
| JP | Mitsubishi |
| JP | Sumitomo |
| JP | Furukawa |

| Region | CW Epitaxy Suppliers | CW Chip Foundries |
|---|---|---|
| TW | Landmark | LuxNet, TrueLight |

**Key PD Suppliers**

| Region | Key PD Suppliers |
|---|---|
| US | Broadcom (Avago) |
| JP | Mitsubishi |

| Region | Key PD Suppliers | PD Epitaxy Foundries |
|---|---|---|
| US | Lumentum | iET |
| US | Coherent (Finisar) | iET |
| US | Macom | iET |
| TW | GCS | VPEC |

## External Resources

- [TrendForce Department of Semiconductor Research reports](https://www.trendforce.com/research/dram)

## Original Content

Source: <https://www.trendforce.com/presscenter/news/20251208-12823.html> — published 8 December 2025.

> [!quote]- AI Data Centers Ignite a Laser Shortage Wave; Nvidia's Strategic Lock-In Reshapes the Global Laser Supply Chain, Says TrendForce
>
> TrendForce's recent research indicates that high-speed optical interconnects are now central to performance and scalability, especially as AI data centers grow into large clusters. The report predicts that worldwide shipments of optical transceivers of 800G and higher will hit 24 million units in 2025, then jump by 2.6 times to nearly 63 million units in 2026.
>
> TrendForce reports that the surge in demand has caused a significant upstream bottleneck in laser light sources. Nvidia, motivated by strategic reasons, has secured capacity at key electro-absorption modulated laser (EML) suppliers, leading to extended lead times beyond 2027 and a worldwide shortage. Optical module manufacturers and CSPs are now actively searching for secondary suppliers and alternative designs, changing the competitive landscape within the laser industry.
>
> **Nvidia's strategic monopoly on EMLs**
>
> Beyond VCSELs used in short-reach links, mid- to long-reach optical modules mainly depend on two laser types: EML and continuous wave (CW).
> EMLs combine modulation functions on a single chip, which makes them highly complex and very challenging to produce. Only a few suppliers are available, such as Lumentum, Coherent (Finisar), Mitsubishi, Sumitomo, and Broadcom.
>
> EMLs, known for their excellent reach and signal integrity, have become a critical bottleneck as hyperscale data centers extend their transmission distances. Nvidia's silicon photonics and CPO development plans have advanced more slowly than anticipated, leading to ongoing dependence on pluggable modules for GPU cluster expansions. To ensure supply, NVIDIA pre-allocated a large portion of EML capacity, reducing availability for other regions.
>
> **CW lasers: The new favorite of CSPs—and the next capacity race**
>
> CW lasers offer a steady optical signal and are paired with silicon photonics chips produced at semiconductor foundries used as external modulators. Their simpler design stems from the absence of integrated modulation, which broadens supplier options. Consequently, CW lasers combined with silicon photonics has become the main alternative route for CSPs facing EML shortages.
>
> However, CW production faces increasing constraints due to several factors: long equipment lead times restrict expansion, and strict reliability standards necessitate labor-intensive die-cutting and aging tests. Consequently, many vendors outsource these steps, which adds to downstream bottlenecks. This situation is causing the CW ecosystem to approach a capacity crunch, leading suppliers to hasten their expansion efforts.
>
> **High-speed PD demand surges; Taiwanese epitaxy vendors benefit**
>
> In addition to laser transmitters, optical modules need high-speed photodiodes (PDs) to receive signals. Leading vendors like Coherent, MACOM, Broadcom, and Lumentum are releasing 200G PDs to enable 200G-per-channel data transmission.
>
> PDs are manufactured on indium phosphide (InP) epitaxial wafers, similar to EMLs and CW lasers. As laser manufacturers focus on expanding epitaxy capacity for laser production, many are outsourcing InP epitaxy to specialized foundries like IntelliEPI (iET) and VPEC, which presents a notable spillover opportunity for Taiwan's epitaxy sector.
>
> TrendForce forecasts that AI-driven demand is tightening not only memory supply but also the entire upstream laser ecosystem. Nvidia's aggressive EML lock-in ensures its own supply security, but has inadvertently accelerated the shift toward CW-based and silicon-photonic solutions among non-NVIDIA players. Concurrently, the industry-wide race for capacity is restructuring supply-chain roles and fueling growth across compound-semiconductor epitaxy and processing vendors.
>
> *[Image — chart titled "Laser Light Sources and PDs: Key Supplier Landscape" (TrendForce, Dec. 2025); transcribed verbatim as markdown tables in the "Supplier landscape" section above.]*

_For more information on reports and market data from TrendForce's Department of Semiconductor Research, please click [here](https://www.trendforce.com/research/dram), or email the Sales Department at SR_MI@trendforce.com_
