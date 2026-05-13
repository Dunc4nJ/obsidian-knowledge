---
created: 2026-05-13
published: 2026-05-07
description: NVIDIA's fourth 2026 photonics investment is a $500M Corning warrant on the fiber connectivity layer, deliberately different in instrument and layer from the $2B equity/preferred stakes in Coherent, Lumentum, and Marvell on the transceiver/laser/DSP layer.
source: https://x.com/PhotonCap/status/2052291144625869196
type: research
authors: ["PhotonCap (@PhotonCap)"]
---

# PhotonCap - NVIDIA's 4 Photonics Bets and the Path of Light

PhotonCap frames NVIDIA's 2026 photonics investments as a deliberate two-layer construction: $2B each in [[Coherent (COHR)]], [[Lumentum (LITE)]], and [[Marvell Technology (MRVL)]] across the transceiver, laser/EML, and DSP/silicon photonics layers — then a fourth, structurally different bet on [[Corning (GLW)]] via a $500M warrant deal targeting the optical-fiber/connector connectivity layer. The thesis: a 1.6T transceiver is meaningless if the fiber connecting GPU nodes is missing, and GenAI clusters need ~10x more fiber connections than legacy networks.

## Key Takeaways

- **NVIDIA's four 2026 photonics bets occupy two distinct layers, not one.** Coherent ($2B equity, 2026-03-02), [[Lumentum (LITE)]] ($2B Series A convertible preferred at $695.31/share, 2026-03-02), and [[Marvell Technology (MRVL)]] ($2B convertible preferred bundled with NVLink Fusion, 2026-03-31) all sit on the silicon-photonics/transceiver/laser axis. [[Corning (GLW)]]'s $500M warrant deal (2026-05-06) is on the optical-fiber-cable-connector "vascular" layer that physically carries light between GPU nodes. The article positions this layer split as deliberate, not coincidental.
- **The instrument differences signal a different risk profile for the Corning leg.** $2B equity (COHR) versus $2B convertible preferred (LITE, MRVL) versus $500M warrant (GLW) is not a one-size-fits-all photonics basket — the warrant structure is materially lighter capital commitment and carries a different option-like payoff vs the convertible stakes. Transceiver pure-plays and Corning sit in the same AI capex cycle but with very different betas. (Differentiation table itself is paywalled; only the structural framing is visible.)
- **Hyperscalers are locking in fiber supply ahead of transceiver vendor choice.** Meta's January 2026 up-to-$6B multi-year Corning agreement (through 2030, anchoring the Hickory NC plant) plus "two additional hyperscale customers" with similar-size LTAs (disclosed on Corning's Q1 2026 call) is the evidence that the connectivity bottleneck is being priced ahead of the transceiver bottleneck. Meta's Prometheus (Ohio, 1GW) and Hyperion (Louisiana, 5GW) campuses are filed on Corning fiber. The NVIDIA-Corning warrant landing on the same supplier days after these LTAs is the "double lock-in" signal.
- **Corning's GlassWorks AI portfolio is full-stack vascular, not just fiber.** Aorta (Vascade EX2000/EX2500 subsea), artery (RocketRibbon up to 6,912 fibers), capillary (SMF-28 Contour at 190μm diameter / Multicore Fiber at 4x capacity per strand), perfusion interface (MMC connector with PRIZM TMT ferrule = 36x density vs LC, plus Fiber Array Units for CPO-architecture chip coupling), and neural pathway (Hollow Core Fiber via the Microsoft Azure manufacturing collaboration). The argument: hyperscalers prefer single-vendor spec lock-in across all five layers, which is a moat the transceiver vendors cannot replicate.
- **1-year stock returns (as of 2026-05-06) show the cycle has already paid asymmetrically across these names**: LITE +1,326%, COHR +395%, GLW +305%, MRVL +206%. Investors picking the "most conservative AI photonics cycle exposure" already have an answer revealed by hyperscaler LTAs (Corning) — PhotonCap argues this is the layer where the answer "exists" while it is still ambiguous among the transceiver pure-plays.

## External Resources

- [PhotonCap full article on photoncap.net](https://photoncap.net/p/coherent-lumentum-marvell-and-now) — primary source; sections 4-7 (identification tables, differentiation matrix, Corning deep dive, scenarios) are paid-tier.
- [PhotonCap — NVIDIA's $4 Billion Photonics Bet: Broadcom Wasn't Wrong](https://photoncap.net/p/nvidias-4-billion-photonics-bet-broadcom) — Internal Reference 1, covers the March 2 COHR + LITE deals.
- [PhotonCap — NVIDIA's $2B Marvell Bet and Celestial AI's "25x Bandwidth" Claim](https://photoncap.net/p/the-ai-infrastructure-interconnect) — Internal Reference 2, covers the March 31 MRVL deal.
- [Original X post](https://x.com/PhotonCap/status/2052291144625869196)

## Original Content

> **PhotonCap (@PhotonCap)** — 2026-05-07 · 60 likes · 8 retweets · 0 replies
>
> Article: Coherent, Lumentum, Marvell, and Now Corning: NVIDIA's 4 Photonics Bets and the Path of Light

*Cover image — NVIDIA's 4 Photonics Bets (COHR, LITE, MRVL, GLW) — four layers of the optical path: laser source (EML diode), optical transceiver, silicon DSP, optical fiber bundle, with the tagline "Light needs roads."*
![[photoncap-869196-001.jpg]]

### $COHR, $LITE, $MRVL, $GLW + AI Infrastructure Connectivity Layer Analysis

NVIDIA made four direct investments into photonics companies in 2026. Coherent and Lumentum got $2B each on March 2, Marvell got $2B on March 31, and on May 6 Corning got a $500M warrant deal plus a multi-year commercial partnership. The first three sit in the transceiver, laser, and DSP layers, the companies that generate, control, and interface with light. The fourth one, Corning, makes the medium that light actually travels through: optical fiber, cable, and connectors. This article walks through why NVIDIA's fourth bet went to a different layer, and why the connectivity layer matters as much as the transceiver layer.

### Contents

1. Intro: NVIDIA's fourth photonics bet
2. Technical context: the path of light in AI infrastructure
3. What looks the same when you group the four, and what splits them apart
4. NVIDIA's four photonics bets: identification + order-of-magnitude comparison
5. Four-group classification + differentiation + Corning deep dive
6. Scenarios + monitoring + closing
7. References & Sources

### 1. Intro: NVIDIA's fourth photonics bet

NVIDIA's fourth photonics bet was not a laser. It was a road.

Coherent, Lumentum, and Marvell are companies that generate, process, and interface light with electrical signals. Corning is the company that locks in the physical road that light actually travels on. If the next bottleneck in AI clusters is not just transceivers but also fiber, connectors, and FAUs, then GLW is not just a glass company. It becomes the connectivity toll road of AI infrastructure.

NVIDIA made four direct investments into photonics companies in 2026. In chronological order:

- 2026-03-02: Coherent ($COHR) $2B equity, Lumentum ($LITE) $2B Series A Convertible Preferred. PhotonCap covered both [Internal Reference 1].
- 2026-03-31: Marvell ($MRVL) $2B Series A Convertible Preferred + NVLink Fusion integration. Also covered by PhotonCap [Internal Reference 2].
- 2026-05-06: Corning ($GLW) $500M warrant deal + multi-year commercial partnership.

1-year stock total returns (as of 2026-05-06, market data):

- $LITE: roughly +1,326%
- $COHR: roughly +395%
- $GLW: roughly +305%
- $MRVL: roughly +206%

Here is what stands out. The first three are in the photonics layer that either generates light (Lumentum's EML and lasers), processes and transmits it (Coherent's advanced optics and optical networking products), or bridges electrical signals and the optical interconnect (Marvell's DSP / custom silicon + silicon photonics). The fourth one, Corning, makes the physical layer that the light actually flows through. Optical fiber, cable, and connectors.

The thesis in one line: **the connectivity layer is as critical as the transceiver layer in AI infrastructure. NVIDIA's fourth bet landing on that layer is not a coincidence.**

This article looks at how NVIDIA's four photonics investments occupy different layers, and why Corning sits in the same cycle as the transceiver pure-plays.

### 2. Technical context: Corning is the vascular system of AI data centers

**How data moves inside a GPU cluster**

If you trace how data moves inside a GPU cluster, you can see exactly where each of the photonics companies that NVIDIA invested in sits.

Electrical signals from the GPU pass through SerDes, DSP, and electrical-to-optical interconnect (Marvell's territory: custom silicon + silicon photonics platform). Then a laser or EML converts them to light (Lumentum and Coherent territory). Light is modulated through a silicon photonics modulator, loaded onto the transceiver, and travels along optical fiber (Corning territory). On the other GPU, the path runs in reverse, back to electrical signals.

*Figure 1: AI data center optical signal path diagram, with the 4 NVIDIA-invested companies positioned on each stage — GPU → DSP/Custom Silicon (Marvell) → Laser/EML (Lumentum, Coherent) → Modulator → Transceiver → optical fiber (Corning, the connectivity layer) → Transceiver → Modulator → Laser/EML → DSP/Custom Silicon → GPU.*
![[photoncap-869196-002.jpg]]

The four companies NVIDIA directly invested in each occupy one of these stages. The transceiver/silicon layer (Coherent, Lumentum, Marvell) generates, controls, and interfaces with light. The connectivity layer (Corning) carries it.

**The metaphor: Corning is the vascular system**

Map an AI data center to the human body and the layers line up like this:

- **GPU**: brain (computation)
- **Transceiver / Laser / DSP**: heart (pumps electrical signals onto the optical medium)
- **Optical fiber + cable + connector**: blood vessels (the conduit that carries light)

A great heart is meaningless if the vessels are blocked or insufficient. A 1.6T transceiver is meaningless if the fiber connecting it to another GPU node is missing. The cluster simply stops. And the number of fiber connections an AI data center needs is roughly 10x what a typical cloud data center needs. Corning's own materials state that GenAI data centers require at least 10x more fiber connections than legacy networks.

**Why connectivity matters, in numbers**

A 16,384 GPU cluster (the standard hyperscale base size now) needs 16,384 cables just between compute nodes and leaf switches. Add leaf-to-spine and spine-to-core, and the fiber and connector counts grow by an order of magnitude. Hyperscale inter-campus links typically run cables with 3,000+ fiber strands (Corning official data).

Going back to the body analogy: as the GPU brain gets smarter, it consumes more oxygen. So fiber count and connector density have to go up, while cable outer diameter per fiber and attenuation budget have to come down. You need more fibers in the same conduit space, with lower loss. Upgrading transceivers alone does not solve this.

**Why Meta committed up to $6B to Corning**

On January 27, 2026, Meta signed a multi-year, up-to-$6B (through 2030) agreement with Corning. Meta became the anchor customer of the Hickory, North Carolina fiber cable plant, which Corning CEO Wendell Weeks said will become the largest fiber cable plant in the world once complete.

The signal here: hyperscalers are now worrying about locking in fiber supply before they worry about which transceiver vendor to use. Meta's Prometheus campus (Ohio, 1GW) and Hyperion campus (Louisiana, 5GW) are both filed to use Corning fiber.

In the Q1 2026 earnings call Corning announced that "two additional hyperscale customers have signed agreements of similar size and duration to Meta's." So this is not one hyperscaler, it is multiple hyperscalers behaving the same way.

**What Corning actually makes (the vessels)**

Corning invented low-loss optical fiber in 1970. For more than 50 years it has held a long-standing supplier position in fiber and cable, and today it sells the entire vessel system, not just the fiber. Mapping the product portfolio to the vascular metaphor:

**Aorta (subsea backbone)**

- **Vascade EX2000 / EX2500**: ultra-low-loss, large-effective-area subsea fibers, 200μm options available. The thickest vessels carrying intercontinental data flows.

**Artery (high-fiber-count trunk)**

- **RocketRibbon**: stacked 12-fiber ribbons packed into a single cable, 432 to 864 fibers, FastAccess jacket for fast splicing.
- **RocketRibbon Extreme-Density**: up to 6,912 fibers in a single cable. The standard for hyperscale inter-campus DCI.
- **RocketRibbon 200**: SMF-28 Ultra 200 (200μm) fiber base, 15% smaller diameter at the same fiber count. 1,728 / 3,456 fiber options.

**Veins and capillaries (inside data center)**

- **SMF-28 ULL**: G.652-compliant ultra-low-loss fiber, terrestrial long-haul standard.
- **SMF-28 Contour fiber**: 190μm outer diameter, 40% smaller than standard, doubling fibers per conduit. Capillary-density for AI data centers.
- **Multicore Fiber (MCF)**: multiple cores in a single fiber strand, 4x capacity per fiber inside the same 125μm cladding.
- **Contour Flow micro cable**: high-density mini-cable for intra-city and intra-campus interconnect.

**Perfusion interface (fiber-to-chip)**

- **MMC connector with PRIZM TMT ferrule**: expanded-beam connector. 36x fiber connection density vs legacy LC, or 3x vs MTP, in the same housing.
- **Fiber Array Unit (FAU)**: ultra-compact fiber-to-chip coupling. The interface for switches and silicon photonics chips. A core component of CPO architectures.
- **EDGE / EDGE8 Distribution System**: pre-engineered structured cabling, cuts server row cabling installation time by 70%.

**Neural pathway (latency-critical)**

- **Hollow Core Fiber (HCF)**: a structure designed for lower latency than conventional solid-core SMF. Corning is in a manufacturing collaboration with Microsoft to scale HCF production for Azure deployment, using the North Carolina production base.

This is bundled as the GlassWorks AI portfolio. The point is that Corning sells the full stack of fiber + cable + connectivity + CPO interface from one vendor. From a hyperscaler's perspective, locking in one vendor means matching fiber count, cable diameter, connector density, and fiber-to-chip interface to a single spec.

*Figure 2: Corning's GlassWorks AI Portfolio mapped to the vascular system — Aorta (subsea backbone: Vascade EX2000, EX2500), Artery (high-fiber-count trunk: RocketRibbon family up to 6,912 fibers), Capillary (inside data center: SMF-28 ULL, SMF-28 Contour 190μm, Multicore Fiber 4x cores in 125μm cladding, Contour Flow micro cable), Perfusion Interface (fiber-to-chip: MMC connector with PRIZM TMT ferrule, Fiber Array Unit FAU, EDGE/EDGE8 Distribution System), Neural (latency-critical: Hollow Core Fiber HCF, Microsoft Azure collaboration).*
![[photoncap-869196-003.jpg]]

> **Summary**: the fiber and connector layer matters as much as the transceiver layer in AI infrastructure. Corning has held a long-standing supplier position in the vascular layer for over 50 years, and today the portfolio runs full-stack from aorta (Vascade) to artery (RocketRibbon) to capillary (Contour fiber) to perfusion interface (MMC, FAU) to neural pathway (HCF). NVIDIA's fourth bet landing on this layer is a continuation of the same trend.

### 3. What looks the same when you group the four, and what splits them apart

What public sources let you see is that NVIDIA invested in photonics 4 times, and the last one was in connectivity rather than the transceiver layer.

From here on, this is no longer just a "list of NVIDIA investments." It is the point where the beta and risk of each layer split apart.

NVIDIA's four bets all get grouped as "photonics investments," but the instruments are not identical:

- Coherent: $2B equity
- Lumentum: $2B Series A Convertible Preferred ($695.31/share)
- Marvell: $2B Series A Convertible Preferred (bundled with NVLink Fusion)
- Corning: $500M warrant deal (Traditional Warrant + Pre-Funded Warrant)

**There is a reason a $500M warrant carries different meaning than a $2B equity stake, and a reason this structure was applied to Corning.**

If you just lump the four together as "companies NVIDIA invested in," you also miss the way market cap, revenue mix, and AI exposure differ by an order of magnitude across them. Transceiver pure-plays and Corning are in the same cycle, but their betas are completely different.

And among the four, which one is the "most conservative way to get exposure to the AI photonics cycle" already has an answer that hyperscalers are showing through their LTAs. There is a layer where the answer exists, and a layer where it does not.

The next sections cover:

- Identification table for the 4 companies (instrument / market cap / 1Y / positioning)
- Order-of-magnitude comparison: transceiver layer vs connectivity layer
- Differentiation table (each company's core weapon + key catalyst + one-line character)
- Corning deep dive (Optical Communications dynamics + the meaning of the Meta-NVIDIA double lock-in)
- Scenarios (Base / Alternative / Downside) + monitoring points

*Figure 3: NVIDIA's 4 Photonics Bets — Layer Position vs Market Cap (log scale, $B, as of 2026-05-06 intraday). Silicon side: LITE ~$60B (transceiver/laser layer), COHR ~$60B (transceiver layer), MRVL ~$150B (DSP/silicon layer). Connectivity side: GLW ~$150B (fiber connectivity layer, labelled "NVIDIA's bet 5/6/2026"). Dashed vertical line separates Silicon Side from Connectivity Side at layer position ~67/100.*
![[photoncap-869196-004.jpg]]

### 4-7. (Paywalled)

The rest of the article (full identification table, order-of-magnitude comparison, differentiation table, Corning deep dive on Optical Communications dynamics + the Meta-NVIDIA double-lock-in framing, scenario analysis, monitoring framework, and references) is behind PhotonCap's paid tier. Two teaser table images preview the Differentiation table (rows for COHR / LITE / MRVL / GLW × columns "Core Tech Weapon", "Key Catalyst", "One-Line Character") and the Base Case Scenario per-company expected impact table (rows for Lumentum Group A / Coherent Group B / Marvell Group C / Corning Group D × columns "Expected Impact", "Beta Profile", "Key Driver"), but the cell contents are intentionally blurred in the preview. Section 7 References & Sources is also gated.

---

[Read the full article on photoncap.net](https://photoncap.net/p/coherent-lumentum-marvell-and-now) | [Original X post](https://x.com/PhotonCap/status/2052291144625869196)
