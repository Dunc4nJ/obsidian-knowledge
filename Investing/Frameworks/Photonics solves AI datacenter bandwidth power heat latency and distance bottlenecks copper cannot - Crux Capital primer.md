---
created: 2026-05-13
published: 2026-02-17
description: Foundational primer arguing photonics is the only viable solution to six concurrent AI data center constraints — bandwidth, power, heat, latency, distance, and reliability — that copper cannot scale through.
source: https://cruxcapitalgroup.substack.com/p/what-problems-does-photonics-solve
type: framework
authors: ["Crux Capital Group (@cruxcapitalgroup)"]
---

## Key Takeaways

- Photonics is forced — not chosen — by six simultaneous AI data center constraints that copper cannot meet at the required speed/distance: bandwidth ceiling (copper tops out near 10 Gbps over reasonable distance vs. AI's 800G–1.6T need today, 3.2T by 2030), power (interconnect/networking already ~30% of total facility power), heat (600 kW/rack systems already force liquid cooling), latency (copper requires retimer/cleanup silicon that adds delay), distance (advanced retimed copper only reaches 2.5–9 m at 800G–1.6T), and reliability (copper is EMI-vulnerable; fiber immune). Read together these aren't five separate optimization arguments — they're a single thesis that interconnect must be optical.
- The bandwidth-distance tradeoff is the cleanest investable wedge. 800G/1.6T-capable copper exists but only over 2.5–9 m; modern AI fabrics need to span racks tens to hundreds of meters apart. There is no copper roadmap that closes this gap — the math (skin effect, ISI, retimer power burn) doesn't bend with iteration. Every rack-to-rack hop above ~10 m at next-gen speeds becomes a forced optical SKU.
- Energy is the single biggest unlock and the loudest CFO-level argument. A 1.6T copper link burns ~30 W; co-packaged-style photonic designs run ~3.5× lower. Multiplied by thousands of links per facility this is "millions per year" savings, which is the dollar number that pulls forward photonic adoption regardless of the technical merits. Co-packaged optics (CPO) is the architecture this favors — see [[Education LPO NPO CPO - what optical placement and signal handoff means for power and latency tradeoffs - Crux Capital primer]].
- "Tail latency" framing is the operational vocabulary: in synchronous training across thousands of accelerators, the slowest link gates the whole step. Copper's mandatory retimer silicon adds processing latency on every link; photonics drops most of it. This recasts photonics as latency-saving compute infrastructure, not just network plumbing — relevant for thinking about why hyperscalers buy ahead of strict cost-equivalence with copper.
- The 30% interconnect-power statistic is the headline number to remember for sizing the addressable market. If networking is already a third of data center wattage and AI capex is what it is, the entire interconnect stack is being re-architected around power-per-bit. That sets up the bull case for any name in the photonic transceiver, CPO, optical-component, or fiber stack — [[Lumentum (LITE)]], [[Coherent (COHR)]], [[Applied Optoelectronics (AAOI)]], [[Ciena (CIEN)]], [[POET Technologies (POET)]], etc.

## External Resources

- [The Photonics Landscape](https://cruxcapitalgroup.substack.com/p/the-photonics-landscape) — companion piece referenced at the end; this primer is "part 1" of a longer build-out.

## Original Content

> [!quote]- Source Material
> Crux Capital Group (@cruxcapitalgroup) — 2026-02-17
> "What Problems Does Photonics Solve? — An Introduction to the Photonics Landscape"
>
> The broad definition of photonics is the physical science and application behind detecting, generating, and manipulating light particles and waves. When we focus on AI data center infrastructure, which is the framework of this report, we understand Photonics as using pulses of light instead of electrical signals to move data between computers.
>
> Photonics addresses several critical challenges that have become major obstacles to building modern data centers, especially those designed for artificial intelligence.
>
> **Speed and Bandwidth:** Traditional copper cables simply can't keep up with the data speeds needed today. Think of it like trying to fit a river through a garden hose. Copper cables were designed for a different era. They can handle about 10 gigabits per second over reasonable distances, but today's AI systems need 800 gigabits to 1.6 terabits per second (that's 80 to 160 times faster). Looking ahead, most connections will need to run at 3.2 terabits per second by 2030. While advanced copper technologies using retimers can technically achieve these speeds, they only work over extremely short distances, typically 2 to 9 meters. Photonics handles these ultra-high speeds easily across much longer distances. Light-based systems are already shipping at 800G and 1.6T speeds and continuing to scale up.
>
> **Energy Consumption:** This might be the biggest problem of all. Data center operators recently reported that the cables and networking equipment connecting their servers were eating up nearly 30% of their total power consumption. That's an enormous amount of wasted energy. A single high-speed connection at 1.6 terabits per second can consume around 30 watts of power using traditional copper-based transceivers, and when you multiply that by thousands of connections in a facility, the electricity bills become staggering. Photonics-based connections, particularly newer designs where the optical components sit right next to the computing chips, use about 3.5 times less power. At large scale, this can save millions per year in electricity costs and significantly reduce carbon emissions.
>
> **Heat Management:** Copper cables generate a lot of heat when pushing data at high speeds, especially over distances longer than a couple meters. Modern AI server racks already produce enormous amounts of heat. Some newer systems generate as much as 600 kilowatts per rack, which is more than enough to power several homes. Adding heat from copper cables to this mix has forced companies to install expensive liquid cooling systems. Photonics produces far less heat because light doesn't create the same friction that electricity does in wires.
>
> **Speed of Response:** AI training requires thousands of processors to work together in perfect synchronization. Any delay in communication between them can create what's called tail latency, where the slowest response holds up the entire job, wasting expensive computing time. Traditional copper-based systems add delays because they need extra processing chips to clean up corrupted signals. Photonics eliminates much of this extra processing, making communication faster and reducing these bottlenecks.
>
> **Distance and Space Constraints:** Copper cables face a fundamental tradeoff between speed and distance. At 10 gigabits per second, copper works up to 100 meters. But at the speeds AI requires, this drops dramatically where advanced copper with retimers can only reach 7-9 meters at 800 gigabits per second, and just 2.5-7 meters at 1.6 terabits. For data centers where equipment might be tens or hundreds of meters apart, this is severely limiting. Making matters worse, high-speed copper cables are thick and bulky, creating space problems when routing thousands of connections through racks and cable trays. Fiber optic cables solve both issues: they're incredibly thin (about the width of a human hair) and can transmit data across several kilometers within a data center facility without signal loss. For connections between data centers, single-mode fiber can reach 40-80 kilometers without needing signal amplification, and with amplifiers can extend to hundreds or even thousands of kilometers.
>
> **Reliability:** Copper cables are sensitive to electromagnetic interference from all the electronic equipment packed into data centers. This interference causes errors and data loss. Fiber optic cables are immune to this interference, providing much more reliable connections.
>
> ---
>
> If you haven't read this most recent post about my new project, read it here:
>
> [The Photonics Landscape](https://cruxcapitalgroup.substack.com/p/the-photonics-landscape) — Gaetano · Feb 17
>
> My goal is to drop some sections of the report as I build it out so you can all be part of the process!
>
> This is part 1
