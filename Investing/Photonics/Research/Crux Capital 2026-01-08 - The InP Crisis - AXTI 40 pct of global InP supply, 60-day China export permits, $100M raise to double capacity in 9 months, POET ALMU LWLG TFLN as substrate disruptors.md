---
created: 2026-05-13
published: 2026-01-08
description: AXT controls ~40% of global Indium Phosphide supply through Beijing-based Tongmei; 60-business-day China export permits, $100M raise (Dec 30, 2025) funds 25% capacity bump in 3 months / doubling in 9 months; POET (Optical Interposer cuts InP 10x), ALMU (InGaAs-on-Si bypass), LWLG (electro-optic polymers), TFLN >110 GHz, and COHR/AVGO GaAs-VCSEL buffer are the disruptor paths around the InP wall.
source: https://cruxcapitalgroup.substack.com/p/the-inp-crisis
type: thesis
authors: ["Crux Capital Group (@cruxcapitalgroup)"]
---

# The InP Crisis

Crux Capital's January 2026 mapping of the Indium Phosphide bottleneck that gates AI optical infrastructure as the industry migrates to 800G, 1.6T and 3.2T transceivers. [[AXT (AXTI)]] is the central protagonist — controls ~40% of global InP supply through Beijing-based Tongmei, navigates a 60-business-day China export permit regime, and closed a $100M offering on December 30, 2025 to fund 25% capacity expansion within 3 months and full doubling within 9 months. Four disruptor paths are mapped — [[POET Technologies (POET)]] (Optical Interposer, ≤90% InP reduction per module), [[Aeluma (ALMU)]] (InGaAs-on-12-inch-silicon, full substrate bypass), [[Lightwave Logic (LWLG)]] (electro-optic polymers replace InP modulators) and TFLN (thin-film lithium niobate >110 GHz). [[Coherent (COHR)]] and [[Advanced Micro Devices (AMD)]]'s competitor Broadcom act as the GaAs/VCSEL safety net for short-reach intra-rack.

## Key Takeaways

- **InP is the AI network bottleneck**: high defect densities, complex crystal growth, and indium-as-byproduct-of-zinc create inelastic supply. China holds ~70% of global indium refinery production (USGS).
- **AXT is the indispensable valve**: ~40% global InP share via Tongmei. Reported a 250% jump in InP sales in late 2025 as it converted record backlog. GPU/CPU makers now bypass intermediates to speak directly with AXT — "every die counts" for 1.6T lasers where defects are catastrophic.
- **Capital + capacity plan**: $100M public offering closed Dec 30, 2025. +25% output within 3 months, capacity doubles within 9 months. CEO Morris Young pegged the capex at ~$10–15M.
- **Tongmei IPO is the strategic hinge**: SSE approved 2022, stuck in CSRC registration. A successful Shanghai STAR listing reclassifies Tongmei as a domestic Chinese champion — hedging it against export restrictions.
- **POET — extreme material efficiency**: Optical Interposer (silicon "motherboard for light") uses tiny InP chiplets instead of bulk wafers, reducing per-module InP up to 90%. $5M production order secured; 800G shipments 2H26, 1.6T ramps 2027.
- **Aeluma — full substrate independence**: heterogeneous integration grows InGaAs/sensing materials directly on up-to-12-inch silicon wafers, bypassing the licensed InP substrate entirely. Currently shipping for NASA + US Navy; data-center foundry qualification scaling through 2027.
- **Lightwave Logic — chemistry not mining**: proprietary electro-optic polymers (Perkinamine family) modulate at 1.6T/3.2T relevant speeds with lower power. Synthesized organically — no refined mineral supply chain. Stage 3 engineering with two Fortune Global 500 partners; commercial deployment late 2026 / 2027.
- **TFLN — speed beyond InP**: Thin-Film Lithium Niobate modulators exceed 110 GHz, beat InP modulator physical limits. Lets manufacturers revert to simpler higher-yield InP CW lasers. Sampling phase for 1.6T switches now.
- **GaAs/VCSEL safety net**: [[Coherent (COHR)]] first to bring up automated 6-inch InP lines (Sherman TX, Jarfalla SE) — 4x capacity, 60% die-cost reduction for 1.6T EMLs — while running mature 6-inch GaAs for 200G/lane VCSELs (~2B devices shipped). Broadcom's 5nm 200G-per-lane DSP with integrated VCSEL drivers cuts 1.6T SR8 power ~20%. Together they keep intra-rack short-reach on GaAs and reserve scarce InP for long-reach.

## Why This Matters

The 2026 AI infrastructure trade is structurally bifurcated: the immediate cycle is dominated by who can supply bulk InP (AXT is the barometer), while the durable long-term winners are those who decouple bandwidth from the InP mineral itself. The 60-day export permit reality has already forced GPU/CPU OEMs to vet substrate capacity personally — a level of vertical engagement that's typically a leading indicator of pricing power and longer-term supply contracts. For positioning, the post stacks the universe four ways: (1) own the choke point ([[AXT (AXTI)]]), (2) own efficiency layers that stretch the choke point ([[POET Technologies (POET)]]), (3) own the substrate replacements ([[Aeluma (ALMU)]], [[Lightwave Logic (LWLG)]]), (4) own the GaAs buffer that reserves InP for the links that need it ([[Coherent (COHR)]] / Broadcom).

Cross-link: builds on the substrate/epi-equipment layer mapped in [[Sancet 2026 - Goldman optical cheat sheet omits substrate epi equipment and laser layers (IQE Soitec Tower Aixtron AEHR LPKF SIVE)]] and the equipment supplier track in [[PhotonCap April 2026 - Six III-V deposition equipment companies behind COHR and LITE (Aixtron Veeco IQE Riber Oxford Instruments AXT) carry the asymmetric edge of the AI optical cycle]]. The Polariton/Perkinamine debate around [[Lightwave Logic (LWLG)]]'s role is detailed in [[PhotonCap May 2026 - Marvell-Polariton acquisition bought the POH slot not the chromophore which leaves LWLG as documented Perkinamine supplier with standalone Tower-GF-AMF foundry track]].

## Original Content

### The Infrastructure Crisis

Artificial Intelligence creates an unprecedented computational demand and we have hit a physical wall. Data center architectures now evolve to support trillion-parameter models like the Nvidia Vera Rubin platform. A primary bottleneck shifted from the processor to the network that facilitates massive parallel processing across thousands of GPUs. At the epicenter of this crisis lies Indium Phosphide (InP). This compound semiconductor material serves as the indispensable medium for generating and detecting the laser light required for high-speed fiber optic communications. This report dives into the InP market as we move through 2026. This sector is defined by a structural supply-demand imbalance, acute geopolitical friction, and a technological renaissance aimed at circumventing material constraints.

---

### The Shortage - Multifaceted Fragility

The shortage is multifaceted and systemic. Physically, the material is difficult to manufacture. It suffers from high defect densities and complex crystal growth requirements that limit yield scaling compared to silicon. Geologically, indium is a byproduct of zinc mining. This creates an inelastic supply curve unresponsive to direct demand signals from the tech sector. Commercially, while the broad market for Indium Phosphide substrates is projected to grow at a CAGR in the low-teens, the high-speed AI and data center interconnect sub-segment is seeing much more aggressive growth driven by the migration to 800G, 1.6T, and 3.2T optical transceivers.

The supply chain is heavily concentrated in China. According to the USGS, China controls a majority share of global indium refining capacity and accounts for approximately 70% of global refinery production. This concentration is weaponized through export control measures. The imposition of export licensing requirements in early 2025 introduced significant volatility. We now see delays of approximately 60 business days for permit processing. This forces Western technology firms to navigate a complex and unpredictable compliance landscape to maintain production.

---

### AXT Inc. ($AXTI)

AXT stands as the central protagonist in this narrative. The market for Indium Phosphide substrates is a functional oligopoly. In recent management commentary, AXT claimed to control approximately 40% of the global Indium Phosphide supply chain through its Beijing-based subsidiary, Tongmei. This massive market share makes AXT an indispensable valve for the global AI buildout. While the company is headquartered in California, its manufacturing heart and raw material access remain firmly in China, creating a unique set of risks and rewards.

The operational reality is defined by the Chinese Ministry of Commerce permitting process. CEO Morris Young confirmed that Indium Phosphide export permits currently take approximately 60 business days to be processed. This introduces a structural latency into the supply chain and requires customers to abandon just-in-time ordering in favor of placing longer-term orders that provide AXT with greater visibility. Recent results indicate that the valve is open. AXT reported a 250% jump in Indium Phosphide sales in late 2025 as it converted a record backlog into revenue.

Perhaps the most significant strategic shift is the vertical collapse of the supply chain. Management confirmed that leading GPU and CPU makers are now bypassing intermediate suppliers to speak directly with AXT. They are terrified that their multi-billion dollar hardware roadmaps will hit a material wall, and they are now personally vetting AXT's manufacturing capacity. CEO Morris Young noted that these customers are increasingly sensitive to material quality. As lasers get larger for 1.6T applications, material defects become catastrophic. Customers are reporting that "every die counts," and they are willing to pay a premium for AXT's high-quality, low-EPD substrates because they deliver superior die yields.

To capitalize on this momentum, AXT successfully closed an underwritten public offering on December 30, 2025, with gross proceeds of approximately 100 million dollars. This capital is intended to fund a massive manufacturing expansion in Beijing. The company plans to increase its output by 25% within three months and double its total capacity within nine months. Morris Young noted that this doubling of capacity requires approximately 10-15 million in capital expenditure.

The pending IPO of Tongmei on the Shanghai STAR Market remains the most critical strategic hurdle. To understand this IPO, you have to distinguish between approval and registration. The Shanghai Stock Exchange approved the listing in 2022, but it has remained stuck in the registration phase with the China Securities Regulatory Commission (CSRC) for years. Registration is the final bureaucratic hurdle where the national regulator gives a terminal green light. A successful listing would allow Tongmei to tap into domestic Chinese capital and achieve the status of a local champion. In the current geopolitical climate, being regarded as a domestic company provides a hedge against export restrictions and eases regulatory friction. It transforms Tongmei from a subsidiary of a U.S. firm into a domestic leader in China's drive for semiconductor self-sufficiency.

---

### Disruptors and Relevant Players

Four primary technological paths are emerging to break the total reliance on bulk Indium Phosphide substrates. Each offers a different engineering solution to the supply constraint with varying timelines for commercial impact.

POET Technologies ($POET): POET addresses the crisis through extreme material efficiency. In a traditional transceiver, the Indium Phosphide wafer is the substrate, meaning the entire chip is made of the scarce material. POET uses an Optical Interposer made of silicon to act as a motherboard for light. This allows them to use tiny InP chiplets instead of large, bulk wafers. According to company technical claims, this architecture reduces the total Indium Phosphide required per module by up to 90%. By turning the scarce material into a tiny component rather than the foundation of the chip, POET enables the global supply of InP to support ten times as many optical engines. The company has secured a $5M production order and expects to begin shipments of its 800G engines in the second half of 2026, with 1.6T ramps targeted for 2027.

Aeluma ($ALMU): Aeluma provides a direct challenge to the legacy InP substrate monopoly. Instead of buying blank InP substrates from China, Aeluma utilizes a heterogeneous integration platform to grow high-performance InGaAs and sensing materials directly on large-diameter silicon wafers (up to 12-inch). By bypassing the requirement for finished InP substrates—the specific component subject to China's export licensing—Aeluma positions itself as a sovereign Western source for AI infrastructure. Aeluma is currently fulfilling mission-critical contracts for NASA and the U.S. Navy and is in the foundry qualification phase for industrial data center components, with a planned scale-up throughout 2027.

Lightwave Logic ($LWLG): Lightwave Logic seeks to remove Indium Phosphide from the signal modulation process. The company utilizes proprietary electro-optic polymers that switch light at speeds relevant to 1.6T and 3.2T links with significantly lower power consumption than traditional semiconductors. Since these polymers are synthesized in a laboratory through organic chemistry, the company bypasses the refined mineral supply chain. Lightwave Logic has recently moved into a Stage 3 engineering program with two Fortune Global 500 partners. The first half of 2026 is dedicated to finalizing chip designs and reliability testing, with commercial deployment targeted for late 2026 or 2027.

TFLN: Thin-Film Lithium Niobate has emerged as a superior material for the high-bandwidth requirements of 1.6T and 3.2T networking. TFLN modulators offer speeds exceeding 110 GHz, surpassing the physical limits of traditional Indium Phosphide modulators. By using TFLN for switching, manufacturers can revert to using simpler, higher-yield InP continuous wave lasers. This architectural shift reduces the reliance on complex, monolithic InP chips. TFLN components are currently entering the sampling phase for next-generation 1.6T switches, with meaningful market participation expected as a key roadmap milestone throughout 2026 and 2027.

---

### The Safety Net - GaAs and the VCSEL Buffer

The industry utilizes a secondary material platform to prevent the Indium Phosphide shortage from collapsing the AI buildout. Vertical Cavity Surface Emitting Lasers (VCSELs) are the workhorses of short-reach networking (racks within 50-100 meters). Most VCSELs are manufactured using Gallium Arsenide (GaAs), a material that is significantly more mature and higher-yield than Indium Phosphide. While GaAs supply chains also face concentration in China, the global capacity for these wafers is vastly more distributed, making VCSELs the primary relief valve for the data center market.

Coherent ($COHR) stands as the vertical champion of the 1.6T era. Unlike competitors who rely on external foundries, Coherent owns its own internal 6-inch fabrication lines for both essential material platforms. In late 2025, the company achieved full production on the industry's first automated 6-inch Indium Phosphide (InP) lines in Sherman, Texas, and Jarfalla, Sweden. This transition delivers 4x the capacity and a 60% reduction in die cost for the EML lasers required for 1.6T links. Simultaneously, Coherent is leveraging its mature 6-inch Gallium Arsenide (GaAs) platform—with nearly two billion devices shipped—to ramp 200G per lane VCSELs. These next-gen devices allow for 1.6T speeds over short distances without consuming a single grain of Indium Phosphide, while their internal 6-inch InP capacity protects them from the merchant substrate shortage.

Broadcom ($AVGO) is also a primary beneficiary of this GaAs shift. The company recently introduced the industry's first 5nm 200G-per-lane DSP with integrated VCSEL drivers. This allows for 1.6T Short Reach (SR8) transceivers that are roughly 20% more power-efficient than traditional solutions. By pushing VCSELs to their physical limits, Broadcom and Coherent provide a critical buffer. They keep the internal networking of AI clusters running on GaAs, reserving the scarce Indium Phosphide supply for the long-reach links where it is absolutely required.

---

### 2026 Outlook

The physical limitations of crystal growth and the reality of approximately 60 business days for export permit processing have forced a permanent paradigm shift. Success in the 2026 AI infrastructure trade depends on identifying the companies that decouple bandwidth from material dependency. AXT remains the essential barometer for the immediate cycle. As long as the AI buildout requires bulk InP, AXT will extract a premium from the market. The company is using its 100 million dollar cash cushion to satisfy a record backlog and double its manufacturing capacity to meet the coming tsunami.

The long-term potential winners in this context are the innovators who successfully remove the single point of failure. Aeluma ($ALMU) provides the ultimate hedge by achieving total substrate independence on silicon. POET Technologies provides the platform that makes the scarce material go ten times further. Lightwave Logic ($LWLG) seeks to eliminate Indium Phosphide from the modulation process entirely using rare-earth-free polymers that bypass Chinese mineral refining. Meanwhile, Broadcom ($AVGO) and Coherent ($COHR) provide a critical buffer by pushing GaAs-based VCSELs to their physical limits, keeping internal short-reach networking on a mature material and reserving the scarce Indium Phosphide supply for the long-reach links where it is absolutely required.
