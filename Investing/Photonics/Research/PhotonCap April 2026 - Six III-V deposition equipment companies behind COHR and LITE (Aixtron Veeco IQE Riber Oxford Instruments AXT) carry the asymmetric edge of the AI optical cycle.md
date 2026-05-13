---
created: 2026-05-13
published: 2026-04-26
description: PhotonCap's foundational thesis on the III-V compound-semi deposition layer behind the AI optical cycle — the InP/GaAs epi + back-end process step that makes the lasers Coherent and Lumentum sell. Six tools companies (Aixtron, Veeco, IQE, Riber, Oxford Instruments, AXT) with 1-year returns ranging from +60% to +5,301% sit at the picks-and-shovels position one layer below the module rerating, where the article argues the asymmetry now lives because the module layer has mostly repriced.
source: https://x.com/PhotonCap/status/2048327935699066945
type: research
authors: ["Photon Capital (@PhotonCap)"]
---

## Key Takeaways

- **The thesis: AI optical's real bottleneck is one layer below the module.** Copper hits a physical limit between GPUs, the industry pivots to light, the light source has to be III-V (InP or GaAs) because silicon is indirect-bandgap and can't generate light efficiently. III-V wafers are grown one atomic layer at a time inside high-vacuum or gas-phase chambers — deposition. The six companies that build the deposition tools have 1-year stock returns of [[AXT (AXTI)]] ~+5,301% (from $2 lows to $70-80 range, market cap ~$4.23B), [[Riber (ALRIB.PA)]] ~+451% ($318M), [[IQE (IQE.L)]] ~+334% ($628M), [[Aixtron (AIXA.DE)]] ~+331% ($6.13B), [[Veeco Instruments (VECO)]] ~+171% ($3.1B), [[Oxford Instruments (OXIG.L)]] ~+60% ($2.15B) (per public data, April 2026).

- **Stock-price sequence: market discovers supply chains in reverse, so the upstream is still catching up.** First the module layer ([[Coherent (COHR)]], [[Lumentum (LITE)]], Innolight) repriced through 2024-2025 on 1.6T demand. Only in late-2025 to 2026 did the market start asking "where is Coherent's InP capacity coming from?" — and worked down to deposition tools. Industrial cycle logic says tools lead modules (the tool has to be installed first), but stock-price logic ran the other way. PhotonCap's claim: the asymmetry now sits **not in modules where the rerating is mostly done, but one layer below in the deposition group that is still catching up**.

- **InP is the photonic-semi industry's "specialty steel."** 1.3/1.55µm datacom EML + CW DFB lasers are mostly built on InP wafers. 850/940nm VCSELs run on GaAs. SiPh externalizes the laser as an external CW source — but the source itself is still III-V. [[Coherent (COHR)]]'s CEO said on FY2025: "We have tripled indium phosphide capacity year over year and expect to continue to expand capacity over the coming quarters to support the strong demand signals from our customers" — and even that wasn't enough, hence the new 6-inch Sherman, Texas line.

- **The InP wafer-size transition is itself a multi-year new-investment cycle.** 4-inch → 6-inch is happening now; 8-inch on the longer roadmap. Pure area math says 4-to-6 is 2.25×, but Coherent's March 2024 6-inch fab announcement framed the combined effect of edge exclusion, automation, usable area, and yield improvement as **"4x the number of devices per wafer" with ">60% reduction in die cost."** Oxford Instruments' November 2025 release describes the same effect as "more than four times." Each wafer-size transition requires a new tool stack matched to larger wafers + full automation — every deposition vendor gets a new-investment cycle each time.

- **[[AXT (AXTI)]]'s InP backlog tells the same story dramatically.** Q3/2025 InP revenue +250% QoQ, InP backlog cleared a record $60M. April 2026: AXT raised $550M specifically to expand capacity. An $88M-revenue company raising $550M is not a temporary supply-hiccup situation — the market is pricing capacity additions on multi-year demand. AXT's InP substrate position covered in detail in a prior PhotonCap piece [10].

- **Deposition splits into two camps: MOCVD (volume) vs MBE (precision).** **MOCVD** (Metal-Organic Chemical Vapor Deposition) flows precursor gases over the wafer; high throughput, multi-wafer runs, the default for volume manufacturing. Almost all AI optical InP lasers are MOCVD-grown. Market: essentially [[Aixtron (AIXA.DE)]] + [[Veeco Instruments (VECO)]], with **Aixtron's share of advanced photonic MOCVD running in the 70-90% range**. **MBE** (Molecular Beam Epitaxy) grows films one atomic layer at a time under ultra-high vacuum; lower throughput, higher precision; workhorse for quantum-dot lasers, qubit stacks, and oxide ferroelectric films (BTO/STO). Global production-scale MBE leader is [[Riber (ALRIB.PA)]], with [[Veeco Instruments (VECO)]] present via the GEN platform.

- **The traditional MOCVD-vs-MBE split is breaking down in 2026.** Veeco delivered the first unit of a 300mm silicon-compatible BTO MBE cluster system co-developed with imec. What used to be Riber's territory (oxide MBE) now has Veeco entering with an imec partnership and an explicit volume-manufacturing target for next-gen datacom modulators. PhotonCap reads this as a meaningful stock signal — direct head-to-head competition between Veeco-imec's BTO 300mm platform and Riber's ROSIE — and one of the **two biggest variables for the next 12-18 months**.

- **Back-end processing rides the same cycle: [[Oxford Instruments (OXIG.L)]] is the supplier of record.** An epi wafer isn't a chip — sub-100nm waveguide patterning, passivation, laser facet mirror coating all required. OIPT (Oxford Instruments Plasma Technology) covers the stack: PlasmaPro 100 Cobra ICP-RIE for waveguide/ridge etch, ICPCVD for low-temperature SiN/SiO₂ passivation, OpAL/FlexAL ALD for atomic-layer dielectrics, Ionfab IBE for laser facet mirror coating. **Each step is near-monopoly.** A photonic-semi production line is the full stack (MOCVD/MBE + ICP-RIE + ICPCVD + ALD + IBE); when AI optical capacity scales, the whole stack scales. OIPT is ramping into [[Coherent (COHR)]]'s Sherman and Järfälla 6-inch InP fabs.

- **The next-gen material hook: BTO (BaTiO₃) oxide modulators on SiPh-compatible 300mm platforms.** BTO has a strong electro-optic effect silicon lacks. Veeco-imec built a hybrid MBE system to grow BTO at production-relevant cost on a 300mm SiPh-compatible platform. imec's TAM framing: datacom transceiver market $2.9B (2024) → $13.1B (2030), with BTO modulators among the largest beneficiaries. Riber is in the same area with the ROSIE platform — head-to-head with Veeco-imec for first orders + SiPh foundry adoption credit.

- **Hidden second variable PhotonCap holds for the paid section: which commercial MBE platform maps onto Microsoft's Majorana 1 quantum chip?** The topological-qubit quantum processor unveiled February 2025 uses an InAs+Al hybrid stack. Whoever's tool grew the qubit stack is the quantum-computing hybrid-materials angle — option-value on top of the AI optical cycle.

- **The six split into four positioning groups (paid).** "Already converted into backlog" / "still trading on option value alone" / "ran ahead of the fundamentals" / "tied to an M&A outcome." PhotonCap separates the cleanest beneficiary from the riskiest name on a 12-month watch. Comparison group: [[Applied Materials (AMAT)]] and [[Lam Research (LRCX)]] — generalist WFE benchmarks — generate an **order-of-magnitude smaller beta** vs. the six pure-play deposition names because compound-semi photonics is a small slice of their revenue base.

- **NVIDIA's GTC 2025 InfiniBand + Ethernet Photonics announce makes deposition the revenue-visibility variable.** Quantum-X Photonics InfiniBand switch (late 2025) + Spectrum-X Photonics Ethernet (2026) make the MOCVD that grows the InP CW laser inside those switches the binding constraint on [[Nvidia (NVDA)]]'s scale-out roadmap. The optical transceiver market exceeded $23B in 2025 with ~+50% YoY growth per LightCounting (cited via Veeco) — broader than AI-only, but AI capex is the single biggest driver behind that number.

## Cross-references

- The thesis update one quarter later: [[PhotonCap May 2026 - VECO Q1 reframes SiPh thesis from MOCVD to Spector IBD facet coating with $250M+ InP laser orders and 10x IBD capacity expansion by early 2027]] — Veeco's $250M+ Q1 orders made clear the bigger lever is one process step downstream of MOCVD (Spector IBD facet coating), revising the framing in this piece.
- Substrate-and-equipment layer Goldman omits: [[Sancet 2026 - Goldman optical cheat sheet omits substrate epi equipment and laser layers (IQE Soitec Tower Aixtron AEHR LPKF SIVE)]] — same deposition/substrate edge framed against Goldman's CPO map.
- Module-side demand context: [[Crux Capital LITE Q2 FY26 readout - EML 25-30 pct supply gap, all capacity locked under LTAs through CY2027, OCS backlog past $400M, CPO and UHP into 1H 2027]] and [[LITE CEO Q2 FY26 - scale-up CPO is largest single growth driver still in infancy, massive supply demand imbalance, $2B quarterly target on track]].

## External Resources

- [Original tweet](https://x.com/PhotonCap/status/2048327935699066945) — PhotonCap's free tease (April 26, 2026)
- [Full paywalled article](https://photoncap.net/p/the-6-companies-behind-coherent-and) — sections 4 (Big-WFE comparison), 5 (Company-by-Company), 6 (Scenarios + Monitoring) plus the Majorana-1 quantum hybrid-materials angle behind the paywall
- [AXT-prior PhotonCap piece](https://x.com/PhotonCap/status/2028733007981695444) — InP substrate deep-dive referenced inline
- Coherent FY2025 earnings call — InP-tripled commentary [6]
- Coherent March 2024 6-inch InP fab announcement — "4x devices, >60% die cost reduction" [7]
- Oxford Instruments November 2025 release — same "more than four times" framing [8]
- NVIDIA GTC 2025 Quantum-X / Spectrum-X Photonics switch announcements [4]
- LightCounting 2025 optical transceiver market figures (via Veeco) [5]
- Microsoft Majorana 1 quantum chip (February 2025) — InAs+Al topological-qubit hybrid stack reference

## Original Content

> [!quote]- Source Material
> @PhotonCap (Photon Capital) — Sun Apr 26 09:06:50 +0000 2026
>
> Article: The 6 Companies Behind Coherent and Lumentum: The Real Leading Edge of the AI Optical Cycle
>
> Aixtron, Veeco, IQE, Riber, Oxford Instruments, AXT: A Look at the III-V Compound-Semi Deposition Names
>
> Abstract
>
> The real bottleneck of the AI data center isn't visible at the GPU. The copper cables that move data between GPUs have hit a physical limit, so the industry is moving to light. But that light isn't made in silicon. It's made on III-V compound semiconductors (InP, GaAs), grown one atomic layer at a time inside what amounts to a chamber furnace. That layer-stacking job is called deposition, and the stocks of the six companies that build the deposition tools have separated by anywhere from +60% to over +5,300% over the past year. AXT roughly +5,301% (from the $2 lows to the $70-80 range), Riber about +451%, IQE about +334%, Aixtron about +331%, Veeco about +171%, Oxford Instruments about +60% (all per public market data, as of April 2026). This article walks through why this slot is the leading edge of the cycle, how the six companies differ, and where they sit relative to the large WFE (wafer fab equipment) names like AMAT and LAM. Tickers covered: $VECO, $AIXA.DE, $IQE.L, $ALRIB.PA, $OXIG.L, $AXTI. Comparison group: $AMAT, $LRCX.
>
> ### Contents
>
> 1. Intro: Every Computing Cycle Showed Up First in "Materials"
> 2. Photonic Semiconductor Deposition, the Things You Need to Know
> 3. The 6-Company Map
> 4. Order-of-Magnitude Comparison with the Big WFE Names (paid)
> 5. Who's Actually Making Money: Company-by-Company (paid)
> 6. Scenarios, Monitoring, and Closing (paid)
> 7. References & Sources
>
> ### 1. Intro: Every Computing Cycle Showed Up First in "Materials"
>
> Step back from the noise and computing history shows the same pattern repeating. Every time a chip generation hits a physical wall, a new material steps in, and the equipment company that grows that material is the first to move and the biggest gainer in the cycle.
>
> - 1990s: PC memory capacity hit a wall, DRAM jumped to new materials and processes, and the memory equipment cycle followed.
> - 2010s: Mobile communications hit a wall, 5G needed GaAs and GaN RF, and the compound-semi RF equipment cycle followed.
> - Early 2020s: EVs hit a power-electronics wall, SiC and GaN stepped in, and the power compound-semi cycle followed.
>
> Right now, in 2025-2026, the same pattern is playing out inside the AI data center. The wall this time isn't the chip itself. It's data movement between GPUs. NVIDIA is doubling and tripling GPU performance per generation, but for tens of thousands of GPUs to behave like one system, the cables between them have to keep up. Copper can't. So the entire industry is shifting from electrical to optical signaling, and the parts that make light (lasers, modulators, detectors) cannot be made in silicon. They have to be grown on III-V compound semiconductors (indium phosphide InP, gallium arsenide GaAs), one atomic layer at a time, inside high-vacuum or gas-phase chambers. That layer-stacking job is called deposition.
>
> That said, the stock-price sequence in this cycle has run in two distinct stages. The first layer to get repriced was the module companies. Coherent, Lumentum, and Innolight ramped in 2024 on 1.6T demand. Only after that did the market dig one layer deeper, asking "where is Coherent's InP capacity coming from?", and the question worked its way down to the deposition tool layer. AXT, Aixtron, Riber, and Veeco started getting serious re-rating only in late 2025 and into 2026. From an industrial-cycle standpoint, deposition tool orders do lead module revenue recognition (the tool has to be installed before the chip can be made). But from a stock-price standpoint, the market discovers supply chains in reverse: the most visible layer (modules) first, then digs deeper as the cycle proves out. So the asymmetry now sits not in the modules, where the rerating is mostly done, but one layer below in the deposition tool group that is still catching up.
>
> The 1-year stock returns reflect that. Aixtron[1], the largest of the six by market cap, is up about +331% over 1 year. Riber[2], the smallest, ran roughly +451%. And the outlier, AXT[3], ran approximately +5,301% over the same window. Sorted (all per public market data, April 2026):
>
> - AXT: roughly +5,301% over 1 year (from the $2 lows to the $70-80 range). Market cap ~$4.23B
> - Riber: about +451%. Market cap ~$318M
> - IQE: about +334%. Market cap ~$628M
> - Aixtron: about +331%. Market cap ~$6.13B (largest of the six)
> - Veeco: about +171%. Market cap ~$3.1B
> - Oxford Instruments: about +60%. Market cap ~$2.15B
>
> When NVIDIA announced at GTC 2025 that the Quantum-X Photonics InfiniBand switch would land later in 2025 and Spectrum-X Photonics Ethernet in 2026[4], the question of who supplies the MOCVD that grows the InP CW laser inside that switch became the question that determines these companies' revenue visibility. The optical transceiver market itself, per LightCounting figures cited by Veeco, exceeded $23B in 2025 and grew about +50% YoY (this is the broader optical transceiver market, not an AI-only number).[5] AI capex is the single biggest driver behind that growth.
>
> One caveat to set up. The deposition and epi tools these six companies make aren't only mapped to AI optical. They also serve quantum computing, AR/VR display, and GaN power. The main angle of this piece is AI optical, but quantum and oxide-modulator optionality show up in places.
>
> > Core thesis: The leading slot of the AI optical cycle isn't the module vendor at the surface, it's the InP wafer and the III-V deposition process that grows it. The six companies that own that step are taking the most asymmetric piece of the cycle. Next-generation oxide modulators show up as a side optionality.
>
> This article walks through Veeco, Aixtron, IQE, Riber, Oxford Instruments, and AXT, their photonic exposure, the technical edge each one carries, and how they sit relative to large WFE names like AMAT and LAM.
>
> ### 2. Photonic Semiconductor Deposition, the Things You Need to Know
>
> Deposition sounds abstract, so here's the everyday picture. Every part that emits, captures, or steers light (the laser, the modulator, the detector) is built by stacking crystalline thin films a few nanometers thick, one on top of another, with extreme precision. It's like painting a surface one atom at a time. If a layer is off by 1nm, the laser wavelength shifts. If wafer-scale uniformity drifts by 0.5%, manufacturing yield can drop in half.
>
> This section keeps it short on four things: (1) why InP is the core material, (2) why deposition splits into two camps (MOCVD vs MBE), (3) how back-end processing rides the same cycle, and (4) where the next generation of materials is being teed up.
>
> **2.1 Light Only Gets Made on III-V**
>
> The 1.3 and 1.55µm datacom EML (electro-absorption modulated laser) and CW DFB (continuous-wave distributed feedback) lasers that go into transceivers are mostly built on InP wafers. Silicon is an indirect-bandgap semiconductor, so it can't generate light efficiently. 850 and 940nm VCSELs run on GaAs, and some SiPh designs use external CW lasers married to a silicon modulator, but the light source itself is still III-V.
>
> InP is the photonic-semi industry's specialty steel. It's hard to grow, has a small set of substrate suppliers, and scaling wafer size is painful. Coherent's CEO said on the FY2025 earnings call that the company tripled InP capacity year over year, and even that wasn't enough, so they brought up a new 6-inch line in Sherman, Texas.[6]
>
> > "We have tripled indium phosphide capacity year over year and expect to continue to expand capacity over the coming quarters to support the strong demand signals from our customers."[6]
>
> On top of the capacity story, there's a wafer-size transition happening. InP wafers are transitioning from 4-inch to 6-inch in earnest, with 8-inch on the longer-term roadmap. The core of the current cycle is the 6-inch ramp. Pure area math says 4-to-6-inch is about 2.25x, but Coherent's March 2024 announcement of its 6-inch InP fab framed the combined effect of edge exclusion, automation, usable area, and yield improvement as "4x the number of devices per wafer" with a "greater than 60% reduction in die cost"[7]. Oxford Instruments' November 2025 release describes the same effect as "more than four times"[8]. Each time the industry transitions to a larger wafer size, the existing 4-inch-centric process toolset isn't enough on its own, and new investment in tools matched to the larger wafer size and full automation is required. That sizing transition is itself a multi-year new-investment cycle for the deposition vendors.
>
> AXT's InP backlog has cleared a record $60m, and Q3/2025 InP revenue ran +250% QoQ.[9] In April 2026 the company raised $550m specifically to expand capacity.[3] An $88m revenue company raising $550m more isn't being treated by the market as a temporary supply hiccup. AXT's InP substrate business and its position in the AI optical supply chain were covered in detail in a prior PhotonCap piece.[10]
>
> Related Articles about InP:
> - [Embedded Tweet: https://x.com/i/status/2028733007981695444]
> - [Embedded Tweet: https://x.com/i/status/2046858059474239694]
> - [Embedded Tweet: https://x.com/i/status/2020665357082788337]
>
> **2.2 Two Branches of Deposition: MOCVD and MBE**
>
> Two pieces of equipment dominate InP epi wafer production. The names are jargon, so here's the quick mental model.
>
> MOCVD (Metal-Organic Chemical Vapor Deposition) flows precursor gases over the wafer in a chamber to grow thin films. It has high throughput and can process several wafers in a single run, which makes it the default for volume manufacturing. Almost all AI optical InP lasers are grown on MOCVD. The market is essentially Aixtron and Veeco, with Aixtron's share of advanced photonic MOCVD running in the 70-90% range.[11]
>
> MBE (Molecular Beam Epitaxy) grows films one atomic layer at a time inside an ultra-high-vacuum chamber. Throughput is lower than MOCVD, but precision is much higher, which makes it the workhorse for quantum dot lasers, quantum-computing qubit stacks, and oxide ferroelectric films like BTO and STO. The global leader in production-scale MBE is Riber, with Veeco present through the GEN platform.
>
> [Figure 1: MOCVD vs MBE chamber comparison]
>
> Here's the important part. The traditional split (MOCVD for volume, MBE for precision niche) is breaking down in 2026. Veeco delivered the first unit of a 300mm silicon-compatible BTO MBE cluster system, co-developed with imec.[12] What used to be Riber's territory (oxide MBE) now has Veeco entering it through an imec partnership, with the explicit goal of volume manufacturing for next-generation datacom modulators. From a stock perspective this is a meaningful signal, and the paid section unpacks it.
>
> **2.3 Back-End Processing Rides the Same Cycle**
>
> An epi wafer alone isn't a chip. Sub-100nm features have to be patterned for waveguides and gratings, passivation has to be deposited, and laser facets have to be mirror-coated. The dominant player in this back-end stack for InP and GaAs is Oxford Instruments. OIPT (Oxford Instruments Plasma Technology) is the supplier of the core plasma processing equipment ramping in Coherent's Sherman and Järfälla 6-inch InP fabs.[8]
>
> OIPT's photonic-semi product family runs across PlasmaPro 100 Cobra (ICP-RIE for waveguide and ridge etching), ICPCVD (low-temperature SiN/SiO2 passivation), OpAL/FlexAL ALD (atomic-layer dielectrics), and Ionfab IBE (ion-beam etching for laser facet mirror coating). A photonic-semi production line isn't a single MOCVD tool, it's a multi-step stack: MOCVD/MBE (deposition) + ICP-RIE (etch) + ICPCVD (passivation) + ALD (dielectric) + IBE (mirror coating). Each step has a near-monopoly supplier, and when AI optical capacity scales, the whole stack scales with it.
>
> **2.4 The Next-Gen Material Is the Hook**
>
> Everything above is the current cycle. The next generation gets more interesting. Oxide ferroelectric thin films like BTO (BaTiO3, barium titanate) are emerging as the leading candidate for the next-gen modulator inside SiPh transceivers. BTO has a strong electro-optic effect that silicon doesn't, and Veeco's imec partnership built a hybrid MBE system that can grow it on a 300mm SiPh-compatible platform at production-relevant cost.[12] imec's framing of the opportunity has the datacom transceiver market growing from $2.9B in 2024 to $13.1B in 2030, with BTO modulators among the largest beneficiaries.[12]
>
> Riber is in the same area with the ROSIE platform, which sets up a head-to-head competition between the two companies. That dynamic is one of the biggest stock variables for the next 12-18 months. So who's locked in the first orders, and who's getting credit for the second variable, the quantum-computing hybrid materials angle? That's what the paid section walks through.
>
> > Section takeaway: AI optical looks like a transceiver story on the surface, but the real bottleneck is the InP laser chip inside, and that chip is built by the full deposition-plus-etch stack: MOCVD/MBE, ICP-RIE, ALD, IBE. Next-generation BTO oxide modulators are an R&D-stage push toward volume, with Veeco-imec and Riber on a direct collision course over SiPh foundry adoption.
>
> ### 3. The 6-Company Map
>
> **3.1 Six Photonic-Semi Deposition Companies**
>
> [Figure 2: AI optical supply chain layers and the 6 companies]
>
> **3.2 Where the Real Differences Start: Past the Paywall**
>
> What's covered up to this point is everything that public sources will give you. The real difference starts past this line. The six companies are all riding the same cycle, but they split cleanly into "already converted into backlog," "still trading on option value alone," "ran ahead of the fundamentals," and "tied to an M&A outcome." And there's one more hidden card sitting inside the cycle: Veeco-imec's BTO 300mm move into what was Riber's standalone territory, and the question of which commercial MBE platform actually maps onto Microsoft's Majorana 1 quantum chip (the topological-qubit quantum processor unveiled in February 2025) and its InAs+Al hybrid stack. Those two are the core variables for the most asymmetric positions over the next 12 months. Below, we walk through why the six companies generate an order-of-magnitude different beta versus the big WFE names like AMAT and LAM, then go company by company on what to watch over the next 12 months, separating the riskiest name from the cleanest beneficiary.
>
> > Section takeaway: Six companies are riding the same cycle, but the technical weapons and business models are different. That difference splits them into four distinct groups, and two hidden variables drive the next 12 months of positioning.
>
> ### 4. Order-of-Magnitude Comparison with the Big WFE Names
>
> The natural follow-up question. Are Applied Materials, LAM Research, and ASMI plugged into SiPh?
>
> ### The full article is available on Substack: <https://photoncap.net/p/the-6-companies-behind-coherent-and>
>
> [Original tweet](https://x.com/PhotonCap/status/2048327935699066945)
