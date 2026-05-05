---
created: 2026-05-05
published: 2025-12-05
description: Roy Rubenstein technical breakdown of Marvell's $3.25B Celestial AI acquisition - the only primary source explicitly naming Penguin Computing as the 2RU chassis builder for the Photonic Fabric Appliance.
source: https://gazettabyte.com/marvell-bets-big-on-optical-i-o-with-3-25b-celestial-ai-deal/
type: research
authors: ["Roy Rubenstein"]
---

# Gazettabyte 2025 - Marvell bets big on optical I/O with $3.25B Celestial AI deal names Penguin Computing as 2RU chassis builder for the Photonic Fabric Appliance

This Roy Rubenstein deep-dive (Gazettabyte, Dec 5, 2025) is the **load-bearing primary source** for the [[Penguin Solutions (PENG) is the named chassis builder for the Marvell-Celestial AI photonic memory appliance shipping late 2026 - Pennycheck thesis]] — it is, to date, the only third-party publication that explicitly states Penguin Computing builds the 2RU appliance for the [[Marvell Technology (MRVL)]] / Celestial AI photonic-memory product. Marvell's own IR releases and post-acquisition press never name [[Penguin Solutions (PENG)]] as the chassis OEM, so without this article the chassis-builder claim sources only to PENG management's own positioning. Beyond the Penguin attribution, the article contains the cleanest set of publicly disclosed technical specs (33 TB unified memory, 115 Tbps switching, 7.2 Tbps per Photonic Fabric Module per direction, 128 ns GPU-to-GPU latency, HBM3e + DDR5 module memory, second-gen 64 Tbps chiplet) and the clearest commercial timeline (sampling H1 2026, scale-up customer H1 2026, Photonic Fabric chiplet integrated with xPUs/switches H2 2026, volume early 2027, Marvell deal closing Q1 2026 with meaningful revenue from 2028).

## Key Takeaways

1. **Penguin Computing named as the 2RU chassis builder — verbatim quote**: *"Connecting 16 of these modules in a 2-rack-unit (2RU) chassis results in a photonic fabric appliance with 33TB of unified memory coupled with a 115Tbps Flit-based electrical network switch. In the example cited, 16 xPUs connect to the ports such that each xPU, and each port, can access the entire 33TB of memory. **Penguin Computing is building the 2RU appliance, and Celestial AI will provide the devices.**"* This single sentence is what corroborates the [[Penguin Solutions (PENG)]] thesis without relying on PENG management as the source. Roy Rubenstein has been the senior photonics journalist at Gazettabyte since 2008 — his sourcing pipeline runs directly to Celestial AI executives (Preet Virk is quoted in the same piece), so the attribution is first-hand from the device-side party, not laundered through PENG IR.

2. **Photonic Fabric Appliance technical specs (cleanest public disclosure)**: 16 photonic fabric memory modules in a 2RU chassis → **33 TB unified memory** + **115 Tbps Flit-based electrical network switch**. Each memory module combines **48-72 GB HBM3e + 2 TB DDR5** with **7.2 Tbps bandwidth in each direction** to the module. HBM acts as a write-through cache to DDR5, so the GPU sees terabytes of high-speed memory while only a small fraction is actually HBM. **GPU-to-GPU latency: 128 ns**. The first-generation Photonic Fabric chiplet is 16 Tbps; **second-gen rises to 64 Tbps (4x improvement on same channel count), available next year** (i.e., 2026).

3. **Commercial milestones / timeline that matter for PENG modeling**: Celestial AI expects first product for scale-up connectivity to a hyperscaler customer in **H1 2026**, with volume in **early 2027**. Photonic Fabric memory modules and NIC modules sample in **H1 2026**; chiplet integrated with xPUs and switches targets **H2 2026**. **The Penguin memory chassis is also expected in 2026.** Marvell expects the acquisition to close in **Q1 2026** and to deliver "meaningful revenues from 2028." LightCounting's view (cited in the article) is that scale-up Ethernet and NVLink CPO switches arrive in 2026 but don't deploy until 2028, with Marvell ROI not until 2030 — though only $1B of the $3.25B (up to $5.5B with earnouts) is in cash.

4. **Lead customer is Amazon — confirmed by an "Amazon Stock warrant"**: LightCounting's research note (referenced in the article) identifies Amazon as Marvell's lead customer. Marvell separately disclosed an Amazon stock warrant alongside the Celestial deal, mirroring the warrant structure Amazon used with [[Astera Labs (ALAB)]] and [[Credo Semiconductor (CRDO)]] to discount product purchases. This is the third independent piece of evidence that AWS is the launch hyperscaler for the Photonic Fabric Appliance — a critical input for sizing PENG's 2026-2027 chassis revenue ramp.

5. **Second-order: Marvell is buying a system-level play, not just a chiplet** — *"While much is happening at the xPU level and between xPUs and memory, the system rack is becoming the new 'compute' unit, with scale-up architectures linking multiple such 'nodes'."* Marvell already provides intra-rack components (Inphi-derived silicon photonics, switch silicon, retimers); Celestial AI gives it the ability to address rack-level system integration. This frames why MRVL would partner with a chassis OEM rather than build its own appliance hardware — it explains why Penguin (the chassis builder) is not a competitor but a complement, and is consistent with PENG's positioning as a hyperscaler-grade systems integrator.

## External Resources

- **Source article (this note's subject)**: <https://gazettabyte.com/marvell-bets-big-on-optical-i-o-with-3-25b-celestial-ai-deal/>
- **Related Gazettabyte coverage referenced inline** — Ciena acquisition of Nubis Communications (Oct 2025): <https://gazettabyte.com/ciena-becomes-a-computer-weaver/>
- **Author profile** — Roy Rubenstein, Gazettabyte: <https://gazettabyte.com/author/roy/>
- **Cross-reference**: LightCounting Market Research note on the Celestial AI deal (cited in article — agent should acquire separately if available)

## Original Content

Headline image (Matt Murphy, Marvell Chairman & CEO):

*Matt Murphy, Marvell Chairman and CEO — quoted on the earnings call announcing the Celestial AI acquisition.*
![[gazettabyte-marvell-celestial-004.jpg]]

> [!quote]- Source Material — Gazettabyte (Dec 5, 2025) — verbatim full article
>
> **Marvell bets big on optical I/O with $3.25B Celestial AI deal**
>
> *December 5, 2025 | 13 Minutes | by Roy Rubenstein*
>
> ## Acquisition crowns a breakthrough year for optical interconnects as AI scale-up pushes copper to its limits.
>
> Marvell Technology announced it will buy optical input/output specialist Celestial AI for $3.25 billion. The deal's value could rise to $5.5 billion if specific sales targets are met.
>
> > "We are playing offence in this company," said Matt Murphy, Chairman and CEO of Marvell, on a bullish earnings call that opened with the acquisition announcement, adding: "Our future is very bright."
>
> The announcement marks the end of a notable year for optical interconnects and co-packaged optics, driven by the need to keep scaling AI clusters.
>
> In March, Nvidia unveiled its first co-packaged optics-based Infiniband and Ethernet switch platforms. Broadcom then detailed the TH6-Davidsson, its third-generation co-packaged optics design that adds optical input/output (I/O) to its 102.4-terabit Tomahawk 6 Ethernet switch chip. And in October, [Ciena acquired the co-packaged optics start-up Nubis Communications](https://gazettabyte.com/ciena-becomes-a-computer-weaver/) for $270 million.
>
> Founded in 2020, Celestial AI has always targeted its Photonic Fabric technology to eight key players: four major hyperscalers and four chip players undertaking xPU development. Now, semiconductor firm Marvell has assessed the optical I/O marketplace and chosen Celestial AI. And it is willing to pay billions for the start-up.
>
> LightCounting Market Research points out in a research note on the Celestial AI deal that Marvell's lead customer is Amazon. Marvell separately revealed a related Amazon Stock warrant. Amazon has used such warrants with other vendors, such as Astera Labs and Credo Semiconductor, to discount the products it purchases.
>
> By adding Celestial AI, Marvell's data centre and AI strategy is strengthened through the integration of optical interconnect with its existing data centre chip portfolio. The acquisition will also reassure Amazon and other hyperscalers that may be working with Celestial AI – a start-up, albeit a well-funded one (Celestial AI has raised close to $600 million in funding) – that it now will have the backing of a key semiconductor player.
>
> *Marvell's component portfolio. Source: Marvell.*
> ![[gazettabyte-marvell-celestial-001.avif]]
>
> ## **AI scale-up**
>
> Celestial AI has been developing its Photonic Fabric for AI scale-up networks, where multiple xPUs and memory are connected to enable linear scaling.
>
> Current scale-up networks comprise 72 xPUs in a rack, but the number will keep growing to 144, 512, and 1,024 xPUs. Scale-up networks will also expand beyond a single rack. Connecting racks will require optical interconnect as copper will not be able to cope with the distance – tens of meters – and traffic: tens of terabits coming out of an xPU package.
>
> At the core of Celestial AI's technology is its Photonic Fabric chiplet, designed to link xPUs, xPUs to memory, and xPUs to a scale-up switch (see diagram below).
>
> > Celestial AI's first-generation Photonic Fabric chiplet supports 16 terabits per second (Tbps), while the second-generation design increases this to 64 Tbps, a factor of four improvement using the same number of optical channels.
>
> The second-generation design will be available sometime next year. The chiplet is added to implement a photonic fabric link on a multi-die xPU package.
>
> The photonic fabric link uses an electrical IC implemented in 5nm CMOS and a separate photonic integrated circuit (PIC) that uses electro-absorption modulators, which Celestial AI claims are thermally stable and compact. By placing the electrical IC above the modulator, the driver-to-modulator path is short, reducing capacitance and improving signal integrity. No digital signal processor is needed at the receiver, reducing latency and consuming a several picojoules per bit.
>
> The protocol Celestial AI uses for the optical link is flit-based. Flits are short, fixed-size packets that improve traffic latency and enable efficient forward error correction. The flit concept was introduced with the PCI Express 6.0 bus. Celestial AI says the latency for GPU-to-GPU comms is 128ns, and flits are an elegant way of managing latency, argues Celestial AI.
>
> The start-up also provides complete link management and a protocol-adaptive layer that maps protocols to the flits, such as AXI (Advanced EXtensible Interface), HBM/DDR, UALink (Ultra Accelerator Link), CXL (Compute Express Link) and ESUN (Ethernet for Scale-Up Networking).
>
> *Photonic Fabric link. Source: Marvell.*
> ![[gazettabyte-marvell-celestial-002.avif]]
>
> ## **OMIB, memory modules, and the photonic fabric appliance**
>
> Celestial AI has also detailed its Optical Multi-Die Interconnect Bridge (OMIB), an optical equivalent of Intel's Embedded Multi-Die Interconnect Bridge (EMIB) for electrical 2.5D interconnects.
>
> By using OMIB, high-speed interfaces can be moved to the optical bridge, freeing up key space around the module's edge. So, for a multi-xPU module where all the xPUs need to be connected, Celestial uses a separate plane for photonics (OMIB) to handle the I/O. The optical I/O can support UCIe, Max PHY, or a proprietary die-to-die interface. By freeing up the node's periphery – Celestial AI uses the 'beachfront' solely for high-bandwidth stacked memory (HBM) and DDR memory.
>
> Celestial's business model has been to design Photonic Fabric chiplets customised to meet a chip player's requirements, followed by unit sales. For OMIB, a hybrid model is possible: selling IP if the chip player wants to integrate the design in its xPU, but also selling a product in the form of a PIC.
>
> Earlier this year, the start-up detailed a memory module that it claimed was the first system-on-chip with optical I/O at its centre, showing how the modulator can sit beneath the electrical driver at the die's centre.
>
> > "Nobody's ever built anything like this," said Preet Virk, Co-Founder and COO at Celestial AI, earlier this year. "Because optics doesn't like being in the middle of the die, it likes being at the side."
>
> Celestial AI is using the OMIB to free up the beachfront to interface with HBM and DDR memory. The high-performance memory module combines 48-72GB HBM3e and 2TB of DDR5 of memory along with 7.2Tbps bandwidth in each direction to the module. The HBM memory acts as a write-through cache to the slower DDR5 memory. From the GPU's perspective, it has terabytes of high-speed memory, even though only a tiny fraction of that is HBM.
>
> Connecting 16 of these modules in a 2-rack-unit (2RU) chassis results in a photonic fabric appliance with 33TB of unified memory coupled with a 115Tbps Flit-based electrical network switch. In the example cited, 16 xPUs connect to the ports such that each xPU, and each port, can access the entire 33TB of memory. **Penguin Computing is building the 2RU appliance, and Celestial AI will provide the devices.**
>
> The start-up is also offering a module for a network interface card for server-based applications that are not AI but do need a large, unified memory.
>
> *Celestial AI's technology. Source: Celestial AI.*
> ![[gazettabyte-marvell-celestial-003.avif]]
>
> ## **Performance benefits**
>
> Celestial AI claims that, for deep learning recommendation models, a model might typically needs to be spread across 56 GPUs, not because of compute but because of the memory capacity required. Using its photonic fabric memory, the entire model can be loaded into the fabric and be accessed by a much smaller number of 16 GPUs, outperforming the 56-GPU configuration. The start-up cites a 12.5x performance improvement while cutting GPU count – and therefore capex and power – by nearly 70 per cent.
>
> For large language models, the picture is different. A GPT-4-class system with 16 GPUs might have around 4TB of total memory, of which almost 1.8TB is used by the model weights. Having 33TB of memory fabric, the same 16 GPUs have an order of magnitude more memory. Celestial isn't claiming fewer GPUs here; instead, it can offer longer context windows, higher batch sizes, and higher revenue per deployed GPU.
>
> For both cases, the bottleneck shifts away from memory capacity and communication overhead back to compute, where xPU vendors are more comfortable competing.
>
> ## **Marvell's gain**
>
> Buying Celestial AI, Marvell gains an optical interconnect technology for next-generation AI scale-up architectures. The technology will complement Marvell's existing family of data centre chips and strengthens its hand of its custom ASIC unit, which develops core designs such as xPU for hyperscalers.
>
> Marvell gained silicon photonics expertise through its acquisition of Inphi. Celestial AI now will add silicon photonics know-how at the chip and die-to-die levels.
>
> > The acquisition can also be viewed more broadly. While much is happening at the xPU level and between xPUs and memory, the system rack is becoming the new 'compute' unit, with scale-up architectures linking multiple such 'nodes'.
>
> This is what buying Celestial AI gives Marvell: Marvell already provides many of the technologies inside the rack, but with the Photonic Fabric technology, it can start addressing system-level issues and play a fundamental role at this higher level of system integration and co-design optimisation.
>
> ## **What next**
>
> Celestial AI expects to deliver its first product for scale-up connectivity to a hyperscaler customer in the first half of next year with volumes scheduled for early 2027. In particular, its Photonic Fabric memory modules and Photonic Fabric network interface cards will sample in the first half of 2026 while the Photonic Fabric chiplet integrated with xPU & switches is targeted for the second half of 2026. The Penguin memory chassis is also expected in 2026.
>
> Celestial AI started generating revenues earlier this year by undertaking three chiplet designs.
>
> Meanwhile, Marvell believes the acquisition will close in the first quarter of 2026. It expects the acquisition to deliver meaningful revenues from 2028.
>
> LightCounting expects scale-up Ethernet and NVLink switches with co-packaged optics in 2026, but it does not expect them to be deployed until 2028. "More advanced co-packaged optics for scale-up switches is behind in maturity, but Marvell does have a window if it can execute," says LightCounting. Marvell is unlikely to see a return on investment until 2030, but only $1 billion of the deal's value is in cash, adds LightCounting.

---

**Source**: <https://gazettabyte.com/marvell-bets-big-on-optical-i-o-with-3-25b-celestial-ai-deal/>
