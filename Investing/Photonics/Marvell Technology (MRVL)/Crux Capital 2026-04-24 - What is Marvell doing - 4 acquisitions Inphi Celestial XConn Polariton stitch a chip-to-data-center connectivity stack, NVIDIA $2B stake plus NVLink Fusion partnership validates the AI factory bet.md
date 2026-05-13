---
created: 2026-05-13
published: 2026-04-24
description: Crux Capital's "talking to a buddy" framing of what [[Marvell Technology (MRVL)]] is actually building — four acquisitions (Inphi 2021 for DSP+silicon-photonics on the optical speed cycle; Celestial AI 2025 for scale-up optical fabric; XConn for PCIe/CXL/UALink scale-up switching; Polariton 2026 for plasmonic modulators to 3.2T+) plus the March 31 2026 NVIDIA $2B investment and NVLink Fusion partnership — stitching together a chip-to-memory-to-rack-to-DCI connectivity layer for AI factories; explains why MRVL is up ~100% in a month after sour sentiment. Consolidated with Crux 2026-04-20 Marvell-Google news lens (MPU+TPU two-chip structure puts Marvell on the memory side of inference; XPU-attach $14.6B by 2028 / 90% CAGR thesis validated).
source: https://cruxcapitalgroup.substack.com/p/what-is-marvell-doing
type: analysis
authors: ["Crux Capital Group (@cruxcapitalgroup)"]
subsectors: [Optical components & engines, Networking systems]
---

# Crux Capital 2026-04-24 — What is Marvell doing: 4 acquisitions (Inphi / Celestial / XConn / Polariton) + NVDA $2B + NVLink Fusion stitch a chip-to-DC connectivity stack for the AI factory

## Key Takeaways

- **Setup**: [[Marvell Technology (MRVL)]] up ~100% in a month — sentiment was sour until the [[Nvidia (NVDA)]] stake; Crux argues the breadcrumbs were always there in the acquisition trail.
- **Overarching goal**: Marvell wants exposure to data movement at *every* layer — chips → memory → switches → rack → between data centers — the same "move as much data as fast and efficiently as possible" thesis driving the rest of the [[Photonics]] folder.
- **The five layers of AI data center communication**:
  1. Chip to memory
  2. Chip to chip
  3. Server to server
  4. Rack to rack
  5. Data center to data center

- **Acquisitions stitched together (one-line each, per Crux):**
  - **Inphi** → moves data over fiber (DSP + silicon photonics; the foundation)
  - **Celestial AI** → moves optics closer to AI chips and memory
  - **XConn** → connects many chips and memory systems together (switching/routing)
  - **Polariton** → makes future optical links faster and more power-efficient (modulators)
  - **NVIDIA partnership** → validates Marvell as a strategic AI infrastructure supplier

- **Inphi (closed 2021) — the foundation.** Optical connectivity for cloud data-center networks — 400G DCI modules built around silicon photonics + DSP. AI chips and switches speak electrical signals; fiber carries light; Inphi sits at the translate/clean-up signal layer. **Puts Marvell on the optical speed upgrade cycle: 400G → 800G → 1.6T → 3.2T.**

- **Celestial AI** brings optical interconnect for high-bandwidth, low-latency AI connectivity *closer to compute itself* — AI chips, memory, accelerators, multi-chip systems, large scale-up domains. Crux: *"different from a normal optical transceiver story. This is deeper in the system."* Becomes powerful if AI architectures keep pushing toward scale-up systems where many accelerators behave like one massive machine.

- **XConn** organizes *where* the data goes. Switching layers for PCIe / CXL / UALink:
  - **PCIe** — common connection standard inside servers
  - **CXL** — memory sharing and pooling across multiple processors
  - **UALink** — connecting AI accelerators in scale-up systems

  Sits alongside Celestial: **Celestial = optical fabric, XConn = switching/routing around that fabric.**

- **Polariton** (announced this week, April 2026) — plasmonics-based modulation + silicon photonics expertise to advance optical performance scaling to **3.2T and beyond**. Modulators sit at the electrical-to-optical conversion point; as links get faster, conversion gets harder (heat, complexity, tight engineering). Polariton focuses on very high-speed, low-power modulation. Marvell already had DSP from Inphi; Polariton adds depth at the physical optical device layer.

- **NVIDIA partnership — March 31, 2026.** [[Nvidia (NVDA)]] and Marvell announce strategic partnership around NVLink Fusion. NVIDIA invests **$2 billion** in Marvell; the two collaborate on silicon photonics. Connects Marvell into the NVIDIA AI factory ecosystem.

- **Crux's full stack synthesis**:
  - **Celestial** → optical scale-up
  - **XConn** → scale-up switching
  - **Polariton** → future optical modulation
  - **NVIDIA** → invests $2B and partners on NVLink Fusion + silicon photonics
  - **Conclusion**: *"Marvell wants to be one of the companies building the connectivity layer around future AI factories."*

## Why this matters

This is the *Marvell strategy in one page* — useful as a fast briefing for anyone trying to reason about MRVL's expected revenue from the AI infrastructure stack independently of Inphi's transceiver cycle. Pairs directly with the longer "What Marvell wants from Celestial AI" deep dive (Crux 2026-04-09, captured in the same folder) and the Polariton plasmonics acquisition note in [[Photonics]]/Research (PhotonCap 2026-04-22). The $2B NVDA stake plus the NVLink Fusion partnership is what flipped the market, and Crux's framing — "the breadcrumbs were there all along" — is the bull narrative the rally is now pricing. Useful counterweight to fear about MRVL being "just" a transceiver / DSP cyclical: the four-acquisition + NVDA partnership map argues for a *connectivity platform* re-rating instead.

## Marvell-Google news context (per Crux 2026-04-20 — preserved here after consolidation)

*Provenance: this section absorbs Crux Capital's 2026-04-20 post "Marvell/Google news: what's going on?" (https://cruxcapitalgroup.substack.com/p/marvell-google-news-is-it-time, authored by Crux Capital Group / @cruxcapitalgroup). That standalone note has been consolidated into this hub to keep the MRVL thesis in one place. The Google-news angle provides a **different analytical lens** than the 4-acquisitions framing above — where the 4-acquisitions view treats MRVL as a connectivity-stack assembler, the Crux Google-news view treats MRVL as the **memory-side-of-inference** play and uses the Reuters MPU+TPU report as architectural validation of the XPU-attach TAM thesis. Both lenses point at the same stock; preserve both.*

### Crux's "memory side of inference" positioning lens (per Crux 2026-04-20)

- **Reuters report (per Crux 2026-04-20 Marvell-Google news reframed)**: [[Alphabet (GOOGL)]] is in talks with [[Marvell Technology (MRVL)]] to develop **two new AI chips** — (1) a new TPU built for inference efficiency, and (2) an MPU (memory processing unit) designed to work with Google's TPU.
- **Two-chip structure is the key technical detail (per Crux 2026-04-20)**: one chip handles the core AI processing job (next-gen TPU); the second chip is the MPU aimed at the **memory side of the system**. Reuters: Google aims to finalize the memory-chip design **as soon as next year** before handing off for test production.
- **Crux's unique framing — "memory side of inference"** (per Crux 2026-04-20 Marvell-Google news reframed) — preserve verbatim: *"Google appears willing to invest serious engineering effort on the memory side of inference, and Marvell has already positioned itself around that exact pressure point."*
- **Alpha angle (per Crux 2026-04-20)**: most coverage will frame this as "Google working with Marvell on a chip program." Crux's deeper read: Google may be evaluating Marvell for a **larger role in the architecture AROUND the chip** — memory, pooling, packaging, data movement. Opportunity sits in a **broader system layer than markets currently assign to MRVL**. *"Signal is architectural before revenue shows up."*
- **Inference, not training (per Crux 2026-04-20)**: project targets AI **"inferencing"** — processing workloads, not training models like Gemini. Google's **Ironwood TPU** (April 2025, gen-7) was already framed as the **first TPU designed specifically for inference** and as Google's **most powerful, capable, and energy-efficient TPU yet**, scaling to **9,216 chips**, with explicit emphasis on HBM capacity, HBM bandwidth, and pod-scale system design. (Per Crux 2026-04-20, Google has been pushing TPUs as an alternative to Nvidia GPUs and Reuters noted TPU sales have become a key driver of Google Cloud growth.)
- **Why memory becomes first-order in inference (per Crux 2026-04-20)**: training draws attention to raw compute; inference still needs compute but turns **memory and data movement into first-order constraints**. **KV-cache** (the model's stored working context during a conversation) grows with longer context windows and richer conversations — Marvell has highlighted exploding model sizes, expanding context windows, and growing KV-cache as major memory-demand drivers across AI infrastructure.

### XPU-attach TAM thesis — Crux's valuation anchor (per Crux 2026-04-20)

- **XPU vs XPU attach framing** (Marvell 2025 Custom AI event, per Crux 2026-04-20): **XPU = main AI processor**; **XPU attach = memory-related hardware, scale-up fabric, networking, host-management functions, memory poolers, expanders**. Accelerated custom compute = XPU + XPU attach.
- **Custom silicon to 25% share** of the accelerated compute market by 2028 (per Crux 2026-04-20).
- **Custom XPU attach TAM: $0.6B (2023) → $14.6B (2028), 90% CAGR** (per Crux 2026-04-20 Marvell-Google news reframed). This is the headline valuation anchor for the memory-side thesis.
- **Data center TAM: $21B (2023) → $94B (2028)** (per Crux 2026-04-20); accelerated custom compute = fastest-growing category.

### Marvell product proof-points cited by Crux (per Crux 2026-04-20)

- **Custom HBM compute architecture** (December 2024 Marvell announcement, per Crux 2026-04-20): up to **25% more compute, 33% more memory, up to 70% lower memory-interface power** via redesigned HBM subsystem, interfaces, and packaging. Available to custom silicon customers to improve performance, efficiency, and TCO.
- **Next-generation CXL switch** (March 2026 Marvell launch, per Crux 2026-04-20) — entire announcement built around the **AI memory wall**. CXL (Compute Express Link) allows processors and accelerators to access **pooled memory resources across the rack** rather than relying only on memory physically attached to a single server. Marvell's CXL switch enables true memory pooling across the rack, raising memory utilization, improving data-flow efficiency, lowering TCO. *(Note: this CXL-switch product complements the [[XConn]] acquisition's CXL switching work — Crux's Google-news note frames CXL as Marvell-organic; the 4-acquisitions note above frames XConn as adding additional PCIe/CXL/UALink scale-up switching.)*

### Google multi-vendor custom-silicon strategy (per Crux 2026-04-20)

- **Broadcom (AVGO) — Google long-term agreement through 2031** (signed earlier in April 2026, per Crux 2026-04-20): co-develop and supply future generations of custom AI chips for Google's next-generation AI racks.
- **Pattern (per Crux 2026-04-20)**: one supplier on main accelerator path, another on memory-side bottlenecks, others elsewhere in rack. Multi-vendor, distributed custom silicon landscape — NOT a one-winner narrative. This Marvell/Google report fits neatly into that picture.

### Supply-chain read-through (per Crux 2026-04-20)

- Positive movement in MRVL can drive action in supply-chain names — though justification depends on the actual news. Crux flagged:
  - **POET Technologies (POET)** — see Crux POET Tech Deep Dive (Apr 12, 2026): https://cruxcapitalgroup.substack.com/p/poet-tech-deep-dive
  - **Sivers Semiconductors (SIVE.ST)** — see Crux $SIVE Deep Dive (Apr 6, 2026): https://cruxcapitalgroup.substack.com/p/sive-deep-dive

### Reuters / Funda AI news clip — verbatim transcription (preserved from screenshot in source note, per Crux 2026-04-20)

> Google-parent **Alphabet** (**GOOGL**) is in talks with **Marvell Technologies** (**MRVL**) to produce new versions of its artificial intelligence chips, according to reports. Wall Street analysts view sales of AI accelerator chips as a fast-growing business for Google stock.
>
> According to the **Information** and Funda AI, the Google/Marvell partnership would target AI "inferencing" — processing workloads, not training AI models such as Gemini. Also, Marvell would reportedly produce an AI memory chip designed to work with Google processors.

### Key Crux quote — preserve verbatim (per Crux 2026-04-20)

> "Reuters is describing a Google project centered on inference efficiency and memory architecture. Marvell has spent months telling us that a growing share of AI value will come from solving exactly that class of problem."

## Original Content

Marvell is on an absolute tear lately.

Stock is up ~100% in a month.

The sentiment around Marvell up until recently was pretty sour.

But something changed when NVIDIA took a stake. The market started to look at Marvell differently.

But the breadcrumbs were there all along.

Marvell has many a handfull of acquisitions over the years to increase their exposure to data movement.

Today we are going to unpack them and understand the goal and the importance.

This post is going to read a bit different than typical and be more like I'm talking to a buddy!

---

**The Overarching Goal**

Marvell is trying to become one of the main companies that helps AI systems move data.

When we talk about all our photonics companies, that really is the goal as well. How can we move as much data, as quickly as possible, as efficiently as possible.

What Marvell wants to do is to have exposure to data communication from chips to memory to switches to rack and between data centers.

So Marvell is buying companies that help solve different parts of the data movement problem.

---

**Layers of Communication**

An AI data center has several layers of communication

1. **Chip to memory** - Chips need to pull data from memory very quickly
2. **Chip to chip** - GPUs or custom chips need to communicate with eachother
3. **Server to server** - Many servers work together as one cluster
4. **Rack to rack** - Large clusters stretch across multiple racks
5. **Data center to data center** - AI workloads may run across multiple facilities in the same region

---

**Acquisition Overview**

**Inphi =** helps Marvell move data over fiber.

**Celestial AI =** helps Marvell move optics closer to AI chips and memory.

**XConn =** helps Marvell connect many chips and memory systems together.

**Polariton =** helps Marvell make future optical links faster and more power efficient.

**NVIDIA partnership =** validates Marvell as a strategic AI infrastructure supplier.

---

**Inphi**

The foundation.

Marvell completed the Inphi acquisition in 2021. The point of that deal was optical connectivity. Marvell said Inphi brought technology used in cloud data-center networks, including 400G data-center interconnect modules built around silicon photonics and DSP technology.

AI chips and switches speak in **electrical signals**.

Fiber carries data as **light**.

So when data moves from a chip into fiber, something has to help translate and clean up that signal and that is wher Inphi sits.

At high speeds, the data signal gets messy. The faster the link, the harder the signal becomes to read cleanly. A DSP helps process that signal so the receiver can understand it.

This gives Marvell exposure to the optical speed upgrade cycle:

400G
800G
1.6T
3.2T over time

As AI data centers need more bandwidth, the optical links need faster signal-processing chips. Inphi put Marvell directly in that path.

---

**Celestial AI**

Marvell said Celestial brings optical interconnect technology for high-bandwidth, low-latency AI connectivity.

Celestial is about bringing optics closer to the compute layer itself.

That means closer to AI chips, memory, accelerators, multi-chip systems and large scale-up domains.

Marvell already sells chips for custom AI infrastructure. Celestial potentially gives Marvell a way to connect those chips and memory systems using optical fabric technology.

That is different from a normal optical transceiver story. This is deeper in the system.

This is the part that could become very powerful if AI architectures keep pushing toward larger scale-up systems where many accelerators need to behave like one massive machine.

---

**XConn**

If Celestial helps move data with light, XConn helps organize where that data goes.

Large AI systems need switching layers that connect accelerators, CPUs, memory, storage, networking cards, multiple hosts, racks of compute etc.

The technical terms are PCIe, CXL, and UALink.

You can think of them this way:

**PCIe** is a common connection standard inside servers. It helps chips and devices talk to each other.

**CXL** is aimed at memory sharing and pooling. It can help multiple processors access memory resources more flexibly.

**UALink** is aimed at connecting AI accelerators together in scale-up systems.

So XConn gives Marvell more control over the inside-the-system connectivity layer.

This sits alongside Celestial nicely.

Celestial: optical fabric.
XConn: switching and routing around that fabric.

If the future AI system has many chips, many memory pools, and many racks behaving like one larger machine, Marvell needs both the fast links and the traffic-control chips.

---

**Polariton**

Marvell announced the Polariton acquisition this week. Polariton brings plasmonics-based modulation technology and silicon photonics expertise, which Marvell says will help advance optical performance scaling to 3.2T and beyond.

The key word here is **modulator**.

A modulator helps put data onto light.

A chip creates an electrical signal.
That signal needs to become an optical signal.
A modulator helps turn the electrical information into light-based information.

So the modulator is one of the key conversion points between electronics and optics.

As optical links get faster, this conversion step gets harder. More speed usually means more heat, more complexity, and tighter engineering requirements. Polariton is focused on very high-speed, low-power modulation.

That makes the acquisition interesting because Marvell already had the DSP side from Inphi.

Now Polariton gives Marvell more depth around the physical optical device layer.

---

**NVIDIA partnership**

On March 31, 2026, NVIDIA and Marvell announced a strategic partnership around NVLink Fusion. NVIDIA also invested $2 billion in Marvell, and the companies said they would collaborate on silicon photonics technology.

This connects Marvell to NVIDIA's AI factory ecosystem.

NVIDIA has the dominant AI platform.
Marvell has custom silicon, connectivity, and optical technology.
Together, they can support customers building custom AI infrastructure around NVIDIA's ecosystem.

This helps explain why the acquisitions are connected.

Marvell bought Celestial for optical scale-up.
Marvell bought XConn for scale-up switching.
Marvell bought Polariton for future optical modulation.
NVIDIA then invests in Marvell and partners around NVLink Fusion and silicon photonics.

So to sum it up…

Marvell wants to be one of the companies building the connectivity layer around future AI factories.
