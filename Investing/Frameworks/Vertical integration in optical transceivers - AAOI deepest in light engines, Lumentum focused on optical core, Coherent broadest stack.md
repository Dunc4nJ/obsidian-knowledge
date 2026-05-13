---
created: 2026-05-13
published: 2026-03-27
description: Side-by-side map of AAOI, Lumentum, and Coherent vertical integration shows three distinct models — AAOI deepest inside the transceiver, Lumentum selective on the high-value optical core, Coherent broadest across the optical stack.
source: https://cruxcapitalgroup.substack.com/p/vertical-integration
type: framework
authors: ["Crux Capital Group (@cruxcapitalgroup)"]
---

## Key Takeaways

- **Three distinct vertical-integration models, not a single "deepest wins" ranking.** [[Applied Optoelectronics (AAOI)]] is deepest inside the transceiver bill of materials (laser chip → light engine → finished module), [[Lumentum (LITE)]] is selective on the highest-value optical layers using a hybrid manufacturing model, and [[Coherent (COHR)]] has the broadest optical stack — spanning lasers, detectors, passive optics, thermal, wafer fabs, and system-level optical products.
- **The laser chip / InP fab layer is the real choke point.** Both LITE (four InP fabs, internal EML capacity, internal EPI reactors) and COHR (four InP wafer fabs in Fremont/Sherman/Järfälla/Zurich, first 6-inch InP line in volume) describe InP capacity as the most defended layer. AAOI's MBE/MOCVD laser fab in Sugar Land plays the equivalent role. None of the three outsource this.
- **"Light engine" is AAOI's organizing concept and the key BOM-capture mechanism.** AAOI explicitly says "the majority of the data center optical transceivers it sells use its own lasers and subassemblies, which it calls light engines" — and that internal content flows from Sugar Land lasers → Taiwan optical components/transceivers → China subassemblies/transceivers/equipment. The model captures margin across laser chip, subassembly, light engine, and finished module rather than just final assembly.
- **DSPs are the universal outsource layer.** COHR explicitly outsources DSPs to focus internal R&D on photonics; the same logic applies industry-wide. This is the "selective where it counts" pattern — vertical integration concentrates where photonics differentiation lives, not where merchant silicon is best-in-class.
- **High fixed cost is the structural risk for the deepest-integrated model.** AAOI itself calls out that "its vertically integrated structure carries high fixed costs, which means the model becomes more powerful as volume rises" — implying the AAOI thesis breaks in a slow-demand year and amplifies in a strong one. The asymmetry is operating-leverage at the laser-chip level.
- **COHR is moving from broad component supplier to one-stop-shop for CPO/MPO supply chains.** Jim Anderson's framing — "for CPO or MPO systems, customers want a supplier that brings the whole portfolio because otherwise the customer has to do the integration and assemble the supply chain itself" — is the strategic logic behind owning isolators, micro lens arrays, PM fiber, and thermoelectric coolers alongside the active optics.

## Vertical integration matrix (Crux summary)

The post anchors on the comparison chart below — internal manufacturing coverage by stack layer for the three companies. `Internal` = in-house design & manufacture. `Hybrid` = partial outsource. `Selective` = partial coverage. `—` = not clearly disclosed.

*Vertical integration coverage across the optical stack — AAOI vs LITE vs COHR (Crux Capital Group, 2026-03-27)*
![[cruxcapitalgroup-vertical-integration-002.png]]

| Stack layer | AAOI (Depth first) | LITE (Selective hybrid) | COHR (Broadest stack) |
|---|---|---|---|
| Epitaxy (InP) | Internal | Internal | Internal |
| Wafer / device fabrication (internal fabs / device processing) | Internal | Internal | Internal |
| Laser chips (EML, DML, CW lasers) | Internal | Internal | Internal |
| VCSELs (Vertical-cavity lasers) | — | — | Internal |
| Photodetectors (Receive-side optics) | Internal | Internal | Internal |
| Passive optical components (isolators, lens arrays, PM fiber) | Selective | — | Internal |
| Thermal control (TECs / integrated thermal management) | Selective | — | Internal |
| Subassemblies / optical engines (pre-finished optical units) | Internal | Hybrid | Internal |
| Transceivers & modules (finished pluggables) | Internal | Hybrid | Internal |
| System-level products (OCS, transport gear, turnkey systems) | Internal | Selective | Selective |

## Original Content

> [!quote]- Source Material
> Crux Capital Group (@cruxcapitalgroup) — 2026-03-27 — paid subscriber post
>
> # Vertical Integration...
> ### This is really important
>
> Just how vertically integrated are AAOI, LITE, and COHR?
>
> Vertical integration matters a lot in transceivers.
>
> The company that controls more of the optical stack could have better supply visibility, tighter cost control, faster product iteration, and more ways to protect margin.
>
> But not all vertical integration looks the same.
>
> Some companies are deepest inside the transceiver itself. Others control a broader set of optical components across the stack. Others focus on the most valuable layers and use outside partners for scale.
>
> There has been a lot of uncertainty on X around just how vertically integrated these companies really are. That is fair. LLM's get this wrong all the time.
>
> So I dug through the transcripts, presentations, and filings to map out what each company actually keeps in-house.
>
> The cleanest way to frame these three is this:
>
> AAOI appears to be among the deepest integrated inside the transceiver stack.
> Lumentum is highly integrated in the optical core and uses a hybrid model to scale.
> Coherent appears to have the broadest optical stack of the three.
>
> Let's unpack this..
>
> *[Image — vertical integration matrix across the optical stack for AAOI, LITE, COHR; embedded above as `cruxcapitalgroup-vertical-integration-002.png` and transcribed as the matrix table above.]*
>
> ---
>
> ## Lumentum
>
> Lumentum's strategy is built around controlling the parts of the optical stack where performance is hardest to replicate and where the value is highest. That starts with lasers. Management has described its laser chips as the gold standard, highlighted a four-fab InP footprint, and pointed to growing internal EML capacity. Lumentum also has internal epitaxy capability and has discussed bringing in its own EPI reactors for InP production. That gives Lumentum meaningful control over one of the most important layers in the transceiver stack.
>
> Lumentum then pairs that internal optical strength with a hybrid manufacturing model. Management's framework is clear in that they want to keep short-lifecycle, IP-sensitive, and laser-chip products in-house, while outsourcing more standardized and IP-insensitive steps. Lumentum has also said it is working with more than seven contract manufacturers. This gives them a combination of control and flexibility, where it keeps the most valuable optical content close while using external partners to scale faster.
>
> That internal content is moving deeper into Lumentum's own products. Management said vertical integration of CW lasers into 1.6T transceivers was expected in calendar Q3 and tied that effort to improved gross margin. Management also said some of the silicon photonics used in those modules is internal. In addition, Lumentum has said it manufactures photodiodes in-house as part of its receive technology. So Lumentum is not only selling components into the ecosystem. It is also pulling more of that internal content into its own finished modules.
>
> The main strength of Lumentum's model is focus. It concentrates on the optical layers where it has the strongest technology, manufacturing depth, and margin opportunity, then uses a hybrid structure to support fast ramps. That makes Lumentum look less like a company trying to own every step and more like one trying to own the most important ones.
>
> ---
>
> ## Applied Optoelectronics
>
> AAOI runs a very deep vertical integration model. They say that they design and manufacture products across multiple levels of integration, from components, subassemblies, and modules all the way to complete turn-key equipment. It also says its manufacturing process spans from laser design and fabrication through complete optical system design and assembly. That is a broad internal chain.
>
> The foundation of that chain is Sugar Land, Texas. AAOI says it designs, manufactures, and integrates its own analog and digital lasers using proprietary MBE and MOCVD processes, and that all of its laser chips are manufactured there. It also says it manufactures the majority of the laser chips and optical components used in its products. This gives AAOI direct control over one of the most critical and supply-sensitive parts of the optical stack.
>
> From there, AAOI carries that internal content up the stack. Sugar Land produces laser chips, subassemblies, and components. Taiwan manufactures optical components that incorporate Texas-built content and also manufactures transceivers. China produces more labor-intensive optical subassemblies, transceivers, and equipment systems. This creates a clear internal flow from laser fabrication to finished product.
>
> The most important concept in AAOI's model is the light engine. AAOI says the majority of the data center optical transceivers it sells use its own lasers and subassemblies, which it calls light engines. It also says it generally uses its own optical component products in semi-finished and finished goods and incorporates its own components into transceivers, subsystems, and equipment wherever possible. That means AAOI is capturing value across several layers of the same product and not just at final assembly.
>
> AAOI also pairs this with automation. Management has emphasized that automated production is largely location-agnostic and has highlighted operating leverage as more automated lines are brought into production. At the same time, the company explicitly says its vertically integrated structure carries high fixed costs, which means the model becomes more powerful as volume rises. In a strong demand environment, that gives AAOI the potential to capture margin across the laser chip, optical subassembly, light engine, and finished module.
>
> The main strength of AAOI's model is depth inside the transceiver bill of materials. It owns the laser chip, uses that internal content in its own light engines, and then carries those light engines into the finished transceiver. That gives AAOI strong control over supply, cost, quality, and product timing.
>
> ---
>
> ## Coherent
>
> Coherent's integration appears to span the widest range of optical building blocks in the group. Management describes the company as having a deep vertical technology stack, and CTO Julie Sheridan Eng said that every critical optical component in a pluggable transceiver is designed and manufactured by Coherent. That is the clearest summary of its position.
>
> That internal footprint covers both sides of the optical link. Management said Coherent makes high-speed InP EML and DML lasers, high-volume CW lasers, and VCSELs, and also has internally developed photodetector technologies in both InP and GaAs. It also highlighted more than 1 billion InP and GaAs photodetectors shipped. So Coherent is active across the transmit and receive layers, not just one side of the link.
>
> Coherent's integration also extends into passive optics and thermal components. Management said the company designs and manufactures a significant fraction of the world's isolators, prism micro lens arrays, polarization-maintaining fiber, and thermoelectric coolers. That gives Coherent a much broader internal component base than a company focused mainly on lasers and transceiver assembly.
>
> Underneath that component stack is real manufacturing depth. Management said Coherent is running four separate InP wafer fabs in Fremont, Sherman, Järfälla, and Zurich. It also said there is nobody else in the industry in volune production on 6-inch indium phosphide and highlighted its first 6-inch InP line in volume production. That points to meaningful internal depth in one of the most important choke points in optical networking.
>
> Coherent also reaches into system-level products. Management has discussed building optical circuit switch (OCS) systems, transport equipment, and the related software stack in-house. This shows Coherent is not only a broad component supplier. It is also using that internal optical base to move upward into higher-level optical systems.
>
> The strategic logic of this model is straightforward. Management said this deep technology stack gives Coherent advantages in time to market, innovation, cost, and supply-chain resiliency when those technologies are integrated into CPO and transceiver products. Jim Anderson also said that for CPO or MPO systems, customers want a supplier that brings the whole portfolio because otherwise the customer has to do the integration and assemble the supply chain itself. His phrasing was simple when he said that Coherent can be a one-stop shop for that supply chain.
>
> But, Coherent does not try to own every layer. Management said it outsources DSPs and uses external DSPs in ZR and ZR+ products so it can focus internal R&D on photonics, where it believes its differentiation is strongest. That makes Coherent broad, but still selective where it counts.
>
> ---
>
> ## The easiest way to compare them
>
> AAOI appears to be the deepest inside the transceiver itself. It starts with internal laser chips, moves through subassemblies and light engines, and then carries that content into finished modules and equipment.
>
> Lumentum is the most selective. It concentrates on the optical core, especially lasers and other high-value photonic content, and uses a hybrid model to scale around those layers.
>
> Coherent appears to have the broadest optical stack. It spans lasers, detectors, passive optics, thermal components, wafer fabs, and system-level optical products.
>
> ---
>
> ## Final takeaway
>
> All three are vertically integrated. They just express it differently.
