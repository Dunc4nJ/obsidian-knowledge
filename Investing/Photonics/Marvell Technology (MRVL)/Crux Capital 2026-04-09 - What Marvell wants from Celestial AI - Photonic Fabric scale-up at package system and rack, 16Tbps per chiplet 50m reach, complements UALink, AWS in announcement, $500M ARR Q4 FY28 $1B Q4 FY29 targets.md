---
created: 2026-05-13
published: 2026-04-09
description: Crux Capital's read on the [[Marvell Technology (MRVL)]] / Celestial AI deal — what Marvell actually wants from Photonic Fabric (scale-up optical I/O at package, system, and rack level), the architectural picture (16Tbps per chiplet, 50m reach, hundreds of Tbps per package, deep 3D co-packaged integration with XPUs), why this complements UALink, the memory unlock (free die-edge space for more HBM in XPU package, nanosecond-latency shared memory pools per Samsung), AWS support in announcement, and the price/milestone framework ($3.25B upfront + up to $2.25B earnout, $500M ARR target Q4 FY28 / $1B Q4 FY29).
source: https://cruxcapitalgroup.substack.com/p/marvell-and-celestial-ai
type: analysis
authors: ["Crux Capital Group (@cruxcapitalgroup)"]
subsectors: [Optical components & engines, Networking systems]
---

# Crux Capital 2026-04-09 — What Marvell wants from Celestial AI: Photonic Fabric at package/system/rack, 16Tbps chiplets, complements UALink, AWS in announcement, $500M ARR Q4 FY28 / $1B Q4 FY29 milestones

## Key Takeaways

- **Frame**: Crux reads the [[Marvell Technology (MRVL)]] / Celestial AI deal as an *architectural* move, not a normal optics tuck-in. Marvell wants optics to move much closer to the center of the AI machine — into the links between compute, memory, and switches that shape how large an AI cluster can become.
- **Target layer**: Marvell's announcement language says Celestial's Photonic Fabric enables optical I/O for "package, system, and rack-level connectivity." Most optics work centers on rack-to-rack and building-to-building traffic; **Marvell is aiming one layer in** — into the internal scale-up fabric. The first commercial target is all-optical scale-up interconnects for next-generation rack-scale AI architectures.
- **UALink complementarity**: Marvell explicitly states Celestial *complements* its UALink scale-up switch roadmap. Read: Marvell is owning more of the *internal nervous system* of AI infrastructure.
- **Memory unlock**: Celestial's approach can free die-edge space inside the XPU package, which can be reused for **more HBM**. Samsung said the platform can connect "large pools of shared memory at full HBM speed with nanosecond-level latencies." This is the angle that lets Marvell help system builders keep processor + memory tightly linked as the cluster grows.
- **Thermal stability supports deep 3D co-packaged integration** with XPUs and switches — meaning the photonic link can be made directly into the XPU rather than pushed out into a separate module. Marvell's broad XPU label covers GPUs and custom AI processors.
- **Per-chiplet specs (1st-gen Photonic Fabric chiplet)**:
  - **16 Tbps** bandwidth in a single chiplet
  - **50 m reach** — extends across rack-scale systems
  - **Hundreds of Tbps per package** — several optical engines can surround a compute package and create a thick internal data fabric
  - Very low energy per bit; very low XPU-to-XPU latency
- **Chip-to-chip optical** opens larger multi-die packages, tighter chip-to-chip communication, and more scalable compute+memory connection. Once it works at scale, the *package* itself becomes more flexible — leading directly into the system-level (multi-rack scale-up domain) opportunity.
- **Customer signal**: Celestial said in 2024 that "hyperscaler and semiconductor customers were already designing its optical chiplets into their systems as an initial phase of adoption." AWS support is in the Marvell announcement, with Dave Brown (VP Compute & ML Services) saying Celestial+Marvell should help accelerate optical scale-up innovation for next-generation AI deployments. Not a production-ramp confirm, but real-roadmap proximity.
- **Deal economics**:
  - **Upfront**: ~$3.25B = $1.0B cash + ~27.2M MRVL shares (~$2.25B)
  - **Earnout**: up to ~$2.25B contingent on revenue milestones
  - **Revenue trajectory** (per Marvell): meaningful contributions begin **H2 FY28**, reach **$500M ARR by Q4 FY28**, **$1B ARR by Q4 FY29**

## Why this matters

This is the architectural reframe of why Celestial was worth ~$3.25B + $2.25B earnout to Marvell — not a transceiver acquisition but a *scale-up fabric platform*. The "free die-edge space for more HBM" is the connect-the-dots claim that ties this to memory ([[Micron Technology (MU)]], Samsung, SK Hynix). The Photonic Fabric chiplet specs (16Tbps each, 50m reach, hundreds of Tbps per package) define the technical ceiling for the next 2 years of scale-up fabric competitive dynamics — relevant to the [[Lightwave Logic (LWLG)]] / Polariton / [[POET Technologies (POET)]] / [[Coherent (COHR)]] thread already in the [[Photonics]] folder. The FY28-FY29 ARR ramp targets ($500M → $1B) frame the bar Marvell must clear for this acquisition to pencil and give a clean catalyst calendar. Pairs with [[Marvell Technology (MRVL)]]'s prior Polariton plasmonics acquisition (April 22, 2025) noted in the PhotonCap May 2026 capture.

## Original Content

### What Marvell Wants to Do With Celestial AI

Marvell bought Celestial AI because it wants optics to move much closer to the center of the AI machine. That is the core idea behind the deal. Marvell already had meaningful exposure to connectivity across the data center. Celestial gives it a path deeper into the system itself, where the links between compute, memory, and switches start shaping how large an AI cluster can become.

Most optics discussions focus on the traffic moving around the outside of the data center: rack to rack, row to row, or building to building. Marvell is aiming at the next layer in. In its acquisition announcement, they said Celestial's Photonic Fabric enables optical I/O for package, system, and rack-level connectivity. That tells you exactly where Marvell wants this technology to live.

The key term here is **scale-up**. This is the fabric that ties many AI accelerators together so they can act like one much larger compute engine. Marvell says future accelerated systems are moving toward multi-rack configurations with high-bandwidth, ultra-low-latency scale-up fabrics, and it says Celestial was built for that transition. UALink matters here too, because Marvell explicitly says Celestial complements its UALink scale-up switch roadmap.

*Marvell scale-up fabric diagram (image 1 of 4 from source)*
![[cruxcapitalgroup-marvell-and-celestial-ai-001.png]]

That distinction is what makes Celestial different. This is about the internal fabric of the AI system itself. Celestial said back in 2024 that hyperscaler and semiconductor customers were already designing its optical chiplets into their systems as an initial phase of adoption. Marvell then took that idea further by saying the first commercial target will be all-optical scale-up interconnects for next-generation rack-scale AI architectures.

The second big piece is memory. AI chips rely on HBM, or high-bandwidth memory, which is the very fast memory placed close to the processor. That closeness helps the chip move huge amounts of data quickly, though it also turns packaging, heat, and system design into a much bigger challenge. Celestial built its story around easing that pressure. Celestial says Photonic Fabric is designed for compute and memory fabrics, and Samsung said the platform has the potential to connect large pools of shared memory at full HBM speed with nanosecond-level latencies. Marvell adds another important point that Celestial's approach can free die-edge space that can be reused for more HBM inside the XPU package.

That is important because Marvell is trying to help AI system builders create a machine where the processor and the memory can stay tightly linked even as the system grows larger. Basically Celestial gives Marvell a path toward more memory flexibility, more bandwidth between system elements, and a larger pool of AI chips working together efficiently. That is why the deal reads to me like an architectural move instead of a normal optics tuck-in.

The third big piece is where the optical connection physically sits. Marvell says Celestial's Photonic Fabric has the thermal stability to support deeper 3D co-packaged integration with XPUs and switches. An XPU is Marvell's broad label for an AI accelerator, such as a GPU or a custom AI processor. Co-packaged integration means the optical engine sits much closer to the compute silicon instead of being pushed farther out into a separate module. Marvell says this allows the photonic connection to be made directly into the XPU. That is a major shift in where optics show up inside the machine.

*Co-packaged photonic-XPU integration concept (image 2 of 4)*
![[cruxcapitalgroup-marvell-and-celestial-ai-002.png]]

This is where the technical numbers need some light. Marvell says Celestial's first-generation Photonic Fabric chiplet delivers 16 terabits per second of bandwidth in a single chiplet. The useful takeaway is that one optical engine can carry an enormous amount of internal AI traffic. Marvell's materials also show 50 meters of reach, which means the connection can extend across far more of a rack-scale system. They show hundreds of terabits per package, which means several of these optical engines can surround a compute package and create a much thicker internal data fabric. They show very low energy per bit, which means less power gets burned simply moving information around, and very low XPU-to-XPU latency, which means the chips can still communicate quickly enough to operate as one tightly coordinated system. That is why Marvell sees Celestial as core AI system infrastructure.

Another reason this fits Marvell so well is that they already had important pieces of the connectivity stack. Celestial gives Marvell a way to tie those pieces together into a broader chip-to-package-to-rack story. Marvell says the acquisition expands Marvell's connectivity portfolio, complements the UALink roadmap, and positions it to capitalize on a large optical scale-up opportunity for multi-rack AI systems. Basically Marvell is trying to own more of the internal nervous system of AI infrastructure.

The chip-to-chip angle is key as well. Celestial's Photonic Fabric is built to create optical links between compute elements inside and around the package. That opens the door to larger multi-die packages, tighter chip-to-chip communication, and a more scalable way to connect compute with memory. Once that starts working at meaningful scale, the package itself becomes more flexible.

*Package-level architectural view (image 3 of 4)*
![[cruxcapitalgroup-marvell-and-celestial-ai-003.png]]

That package-level flexibility leads directly to the bigger system-level opportunity. Celestial is not only a way to connect one chip to one neighboring chip. Marvell is buying a platform that it believes can support larger packages, larger clusters inside the rack, and larger scale-up domains that stretch across multiple racks. Marvell says future AI architectures are evolving beyond a single rack, and that is exactly where Celestial's longer reach and lower-power optical fabric become strategic.

*System-level scale-up domain across multiple racks (image 4 of 4)*
![[cruxcapitalgroup-marvell-and-celestial-ai-004.png]]

The price tag shows how seriously Marvell views that opportunity. The upfront deal value was about $3.25 billion, made up of $1.0 billion in cash and roughly 27.2 million Marvell shares valued at about $2.25 billion. The agreement also includes up to roughly $2.25 billion of additional contingent consideration tied to revenue milestones. Marvell said it expects meaningful Celestial revenue contributions to begin in the second half of fiscal 2028, reaching a $500 million annualized run rate in the fourth quarter of fiscal 2028 and a $1 billion annualized run rate by the fourth quarter of fiscal 2029. Those are ambitious targets, and they show how large Marvell believes this category could become.

There is also a useful market signal in the deal language itself. Marvell included AWS support in the announcement, and Dave Brown, AWS's Vice President of Compute and Machine Learning Services, said Celestial's combination with Marvell should help accelerate optical scale-up innovation for next-generation AI deployments. That does not prove a full production ramp by itself, though it does show this technology sits close to real hyperscaler roadmaps.
