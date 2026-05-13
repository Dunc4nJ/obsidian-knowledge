---
created: 2026-05-13
published: 2026-03-03
description: Foundational PhotonCap thesis arguing AXTI's InP substrate franchise is the irreplaceable physical bottleneck for the 800G/1.6T AI optical interconnect ramp, justifying the ~22.9x P/S re-rating despite a FY25 revenue decline.
source: https://x.com/PhotonCap/status/2028733007981695444
type: thesis
authors: ["Photon Capital (@PhotonCap)"]
subsectors: [Substrates & epi-wafers]
---

# PhotonCap 2026-03-03 — AXTI is the hidden InP substrate bottleneck for AI optical interconnects (foundational thesis)

> Note: this is the **foundational thesis** preceding PhotonCap's later 2026-05-04 AXTI Q1 follow-up. Read this first for the physics/moat case, then the Q1 piece for execution check-in.

## Key Takeaways

- **Stock + fundamentals paradox.** [[AXT (AXTI)]] went from ~$1/share in early 2025 to $37.58 by 2026-03-01 (1Y return +2,268%, market cap $84M → $2.51B), yet FY25 revenue was just **$88.3M, –11.1% YoY** with a widened **GAAP net loss of $21.3M** and Q4 2025 revenue of only $23.0M (missed on China export controls). Market is paying ~**22.9x trailing P/S** for a shrinking business.
- **What the market is actually pricing**: InP as the *only* viable substrate to physically resolve the AI optical interconnect bottleneck above 800G→1.6T transmission speeds. Copper is exhausted on signal integrity + heat at the rack/row scale that [[Nvidia (NVDA)]] H200/B200 clusters and [[Broadcom (AVGO)]] Tomahawk 5 switches require.
- **Why InP is irreplaceable (physics):**
    - Silicon is an **indirect bandgap** material — electron-hole recombination releases energy primarily as heat (phonons), not photons. You cannot build an efficient native laser out of silicon.
    - GaAs (direct bandgap, ~1.42 eV / ~870nm native) supports only **850nm VCSELs**, which suffer severe fiber attenuation/dispersion. Restricted to **<50m intra-rack** short reach.
    - InP is the *only* base substrate that can support defect-free **lattice-matched** epitaxial growth of the InGaAsP/InAlGaAs active layers needed to emit the **1310nm O-band** and **1550nm C-band** — the "magic windows" of near-zero fiber attenuation, enabling **500m mid-reach to 2km+ long-haul** intra-DC links.
    - Same lattice-matching argument holds on the **receiver** side: InGaAs (In0.53Ga0.47As) photodetectors grown on InP achieve low dark current; the same composition grown on GaAs or Si has high threading dislocation density → leakage current → fatal data loss at 1.6T noise floors.
- **The 1.6T forcing function.** As AI models scale to trillions of parameters, GPU clusters scale out (longer physical distances between accelerators). 850nm GaAs VCSEL platforms (where [[IQE (IQE.L)]], [[Sumitomo Electric (SMTOY)]] also play on the substrate side) cannot carry 1.6T over hundreds of meters → the industry is *forced* to transition to EML/DFB lasers built on **InP** platforms.
- **Vertically-integrated moat** is the second pillar of the thesis. AXT's Beijing subsidiary **Tongmei** (Beijing Tongmei Xtal Technology) holds stakes in 10+ Chinese raw-material JVs that internalize gallium refining from 4N (99.99%) all the way to **8N (99.999999%)** purity, plus high-purity indium, germanium dioxide, arsenic, and pBN crucibles. PhotonCap claims this is the **deepest vertical integration of any publicly-traded substrate supplier** — deeper than JX Nippon and structurally cost-advantaged vs. peers buying externally.
- **Geopolitical double-edge.** That same Beijing concentration is the central risk: 100% of manufacturing + most raw sourcing sits in China, fully exposed to escalating US-China export-control cycles (which already cratered Q4 2025 revenue).
- **Implicit read-through for the optics stack** — InP supply scarcity is bullish for substrate names ([[AXT (AXTI)]], [[IQE (IQE.L)]], [[Sumitomo Electric (SMTOY)]]) and pricing-positive for the downstream laser/transceiver layer ([[Lumentum (LITE)]], [[Coherent (COHR)]], [[Applied Optoelectronics (AAOI)]]) that depends on it, and for the MOCVD tool layer ([[Aixtron (AIXA.DE)]], [[Veeco Instruments (VECO)]]) that builds the epi capacity.
- **What the article gates behind paywall**: Section 4 onward ("Market & Moat: Oligopoly and the 6-Inch Paradigm Shift") and beyond — i.e., the actual substrate market share / 6-inch wafer transition / numbers — are PhotonCap-subscriber-only. Public portion is the physics + integration moat case, not the quantitative supply/demand math.

## Original Content

> @PhotonCap (Photon Capital):
> Article: AXT Inc. ($AXTI): The Hidden Bottleneck in AI Optical Interconnects
>
> # 1. Why Pay Attention to Indium Phosphide (InP) and AXT Inc. Now?
>
> From the second half of 2025 through the first quarter of 2026, one of the most volatile and exceptionally rewarding stocks in the global market has been AXT Inc. (NASDAQ: AXTI), a Silicon Valley-based manufacturer of compound semiconductor substrates. Languishing at around $1 per share in early 2025 (with a 52-week low of $1.13), the stock surged past $37.58 by March 1, 2026, delivering a staggering trailing 12-month return of 2,268% (and over 3,174% from its 52-week low). Along with this, the company's market capitalization, which stood at a mere $84 million a year ago, has miraculously surged to $2.51 billion in just one year, fueled by the explosive demand for AI-driven optical communications.
>
> [KOR] https://x.com/PhotonCap/status/2028732993183867162
>
> Beneath this historic stock price explosion lies a highly paradoxical set of financial metrics. AXT Inc.'s total revenue for fiscal year 2025 was $88.3 million, down 11.1% year-over-year, and its GAAP net loss widened to $21.3 million. Furthermore, Q4 2025 revenue came in at just $23.0 million, missing market expectations due to geopolitical export controls from China. With core fundamentals like revenue growth and profitability clearly impaired, why is the market enthusiastically assigning this company an extreme trailing Price-to-Sales (P/S) multiple of roughly 22.9x (adjusted for the December 2025 new share issuance)?
>
> The answer lies in the most critical bottleneck of AI cluster expansion—Optical Interconnects—and the status of Indium Phosphide (InP) as a virtually irreplaceable material physically capable of resolving this bottleneck.
>
> Next-generation AI data centers powered by NVIDIA's H200/B200 infrastructure and Broadcom's Tomahawk 5 switches are pushing node-to-node data transmission speeds beyond 800G to 1.6T (Terabits per second). For tens of thousands of GPUs to operate as a single massive computer, latency and power consumption must be aggressively minimized. Traditional copper wiring has hit its physical limits regarding signal integrity and heat dissipation. In the optical fiber networks replacing copper, InP is the mandatory substrate for the core components that generate (Lasers) and detect (Photodetectors) light.
>
> # 2. Company Background & Vertically Integrated Business Model
>
> Founded in 1986 and headquartered in Fremont, California, AXT Inc. is a materials science company that develops and manufactures high-performance compound and single-element semiconductor wafer substrates. While traditional silicon (Si) wafers dominate the broader semiconductor industry, they fall short of the extreme high-frequency, high-power, and specific optoelectronic requirements of advanced applications. To fill this gap, AXT supplies critical substrates made of Indium Phosphide (InP), Gallium Arsenide (GaAs), and Germanium (Ge).
>
> The most formidable strategic moat in AXT's business model is its heavily vertically integrated supply chain. While players like JX Nippon internalize some raw materials, AXT is widely recognized as having one of the deepest and most comprehensive vertical integration models among publicly traded substrate suppliers—spanning from raw mineral sourcing and refining to final wafer production. All manufacturing operations are conducted through its Beijing-based subsidiary, Beijing Tongmei Xtal Technology Co., Ltd. (Tongmei).
>
> Through Tongmei, AXT holds strategic stakes in over ten raw material joint ventures (JVs) in China, internalizing the production of mission-critical materials. Crucially, these JVs extract and refine raw minerals into the extreme purity levels required for semiconductor manufacturing. They process standard 4N (99.99%) gallium into ultra-high purity 5N, 6N (99.9999%), 7N, and even 8N (99.999999%) gallium, while also producing high-purity indium, germanium dioxide, arsenic, and pyrolytic boron nitride (pBN) crucibles.
>
> This model provides AXT with industry-leading cost advantages and shorter lead times compared to competitors relying on external suppliers. However, it operates as a double-edged sword. Because both manufacturing and raw material sourcing are overwhelmingly concentrated in China, AXT is highly exposed to severe geopolitical vulnerabilities amid escalating US-China trade tensions.
>
> # 3. Technical Deep Dive: Why InP over GaAs or Silicon?
>
> When discussing semiconductor substrates, 12-inch (300mm) silicon wafers are the first to come to mind, powering over 95% of the global market. However, when entering the realm of "Optoelectronics"—converting electrical signals to photons and vice versa—silicon reveals a fatal physical flaw. This is due to the structural difference in energy bandgaps. Silicon is an Indirect Bandgap material. When an electron drops from the conduction band to the valence band to release energy, a change in momentum is required. Consequently, the energy is mostly dissipated as heat (phonons) rather than light (photons). Simply put, it is physically impossible to build an efficient, native light-emitting laser out of silicon.
>
> > 💡 [Concept Analogy] Indirect vs. Direct Bandgap — A Direct Bandgap material is like someone jumping straight off a cliff into the water, immediately creating a massive splash (light). An Indirect Bandgap material (like Silicon) is like someone jumping, but hitting a protruding rock on the way down; the impact is absorbed by the rock (heat), and they barely make a splash when they hit the water (no light).
>
> ## 3.1. The Physics of Bandwidth and Wavelength: 850nm vs. 1310/1550nm
>
> In optical communication systems, the absolute metric dictating transmission distance and quality is the wavelength of light. When light travels through silica-based optical fibers, signal attenuation (due to Rayleigh scattering and infrared absorption) varies drastically by wavelength. The optimal "magic bands" for minimum signal loss are the O-band (1310nm) and the C-band (1550nm). It is crucial to distinguish between a substrate's native emission wavelength and the telecom wavelengths it can support via epitaxy. The bandgap energy of a semiconductor is inversely proportional to the wavelength of light it emits (λ=1240/Eg).
>
> - **The Limits of Gallium Arsenide (GaAs):** A GaAs substrate has a native bandgap of ~1.42 eV (translating to ~870nm). By growing thin layers like AlGaAs on top, it primarily produces lasers emitting at 850nm. However, the 850nm wavelength suffers from severe signal attenuation and chromatic dispersion in optical fibers. Therefore, GaAs VCSELs are strictly limited to short-reach communications (under 50 meters), such as intra-rack connections.
>
> - **The Dominance of Indium Phosphide (InP):** A pure InP substrate has a bandgap of ~1.34 eV (~920nm). However, InP dominates optical communications not because the substrate itself emits 1550nm light, but because it is the only "base substrate" that can perfectly support the defect-free, lattice-matched growth of active layers (like InGaAsP or InAlGaAs) that precisely generate the golden 1310nm and 1550nm wavelengths. These wavelengths experience near-zero signal loss, perfectly supporting mid-reach (500m) to long-haul (2km to 10km+) data center interconnects.
>
> As AI models scale to trillions of parameters, data centers are forced to scale out, increasing the physical distance between GPUs. To transmit massive 1.6T bandwidths over hundreds of meters without loss, the industry is forced to transition away from 850nm GaAs VCSELs toward high-performance EML and DFB lasers built on InP platforms.
>
> ## 3.2. The Core of the Receiver: Photodetectors (PD) and Lattice Matching
>
> The true value of InP extends beyond the transmitter (Tx) to the receiver (Rx) end, specifically in Photodetectors (PD) that convert light back into electrical signals.
>
> A receiver's performance is dictated by bandwidth (response speed) and dark current (noise). The material that absorbs 1310nm and 1550nm light fastest and most efficiently is the Indium Gallium Arsenide (InGaAs) alloy. The key is the substrate upon which this InGaAs active layer is grown via epitaxy.
>
> When stacking materials atom by atom, if the Lattice Constant (atomic spacing) between the substrate and the top layer differs, the layer warps and cracks, generating massive defects (dislocations). Remarkably, an InP substrate (lattice constant 5.869Å) provides a perfect lattice match for the specific InGaAs composition (In0.53Ga0.47As) required to absorb the 1550nm band.
>
> Conversely, forcing InGaAs growth onto a cheaper GaAs or Si substrate results in a severe lattice mismatch, creating a high Threading Dislocation Density. These micro-defects cause leakage currents, sharply increasing the device's Dark Current. In ultra-high-speed 1.6T communications, where detecting incredibly faint signals is paramount, a raised noise floor from dark current causes fatal data loss.
>
> *[Image — "Optical Telecom Substrate Material Comparison" — referenced in source but not extracted; not embedded.]*
>
> ## 4. Market & Moat: Oligopoly and the 6-Inch Paradigm Shift
>
> ## ...
>
> ## 🔒 The full report and in-depth analysis are exclusive to PhotonCap subscribers.
>
> # Read more:
>
> # https://photoncap.net/p/axt-inc-axti-deep-dive-the-hidden
>
> ---
> date: Tue Mar 03 07:23:35 +0000 2026
> url: https://x.com/PhotonCap/status/2028733007981695444
> likes: 111  retweets: 16  replies: 5

## Related Notes

**Compound-semiconductor substrate / epi peers** — direct comparables in the InP/GaAs substrate stack:

- [[IQE (IQE.L)]] — UK epi-wafer peer; GaAs/InP epitaxial wafers (vs. AXT's bulk substrates).
- [[Sumitomo Electric (SMTOY)]] — Japanese InP substrate competitor; one of the few non-China-dependent sources.
- [[Soitec (SOI.PA)]] — engineered-substrate peer (SOI / specialty substrates); adjacent competitive set.
- [[Win Semi (3105.TWO)]] — GaAs/InP foundry (downstream customer for compound substrates).

**MOCVD / epi-tool layer** — capex-cycle beneficiaries when substrate names ramp:

- [[Aixtron (AIXA.DE)]] — MOCVD tool leader for InP/GaAs epi growth.
- [[Veeco Instruments (VECO)]] — MOCVD/MBE tool peer.
- [[Riber (ALRIB.PA)]] — MBE tool maker for compound-semi epi.
- [[Aehr Test Systems (AEHR)]] — wafer-level test for compound-semi devices.

**Optical transceiver / laser layer** — the demand-pull on top of InP substrates:

- [[Lumentum (LITE)]] — InP-based DFB/EML lasers for 800G/1.6T transceivers.
- [[Coherent (COHR)]] — vertically-integrated InP laser + transceiver supplier.
- [[Applied Optoelectronics (AAOI)]] — DFB lasers + transceivers, hyperscaler customer base.
- [[POET Technologies (POET)]] — silicon-photonics interposer integrator (alternative path).
- [[Lightwave Logic (LWLG)]] — electro-optic polymer (long-shot alternative to InP modulators).
- [[Ciena (CIEN)]] — system-level optical networking customer.
- [[Marvell Technology (MRVL)]] — DSP/PAM4 silicon paired with InP optics in transceivers.

**System-level demand drivers** — the AI infrastructure layers cited in the thesis:

- [[Nvidia (NVDA)]] — H200/B200 GPU clusters driving 800G→1.6T link demand.
- [[Broadcom (AVGO)]] — Tomahawk 5 switches setting the 1.6T pace.
