---
created: 2026-05-13
published: 2026-03-23
description: Crux Capital's beginner primer on photonics covering why light beats copper at high bandwidth, how AI training reshapes data-center networks, the full optical value chain from InP substrates to transceivers, the pluggable-LPO-CPO migration, and where the bottleneck investment positions sit.
source: https://cruxcapitalgroup.substack.com/p/photonics-101
type: framework
authors: ["Crux Capital Group (@cruxcapitalgroup)"]
---

## Key Takeaways

- Bottleneck-vs-commodity is the single analytical lens this primer pushes — the value chain has dramatically different attractiveness by layer, with materials (InP wafers), epitaxy (MOCVD-grown laser structures), EML lasers, and leading-edge PICs sitting at the defensible bottom of the stack while module assembly and standard transceivers face Chinese price competition and hyperscaler tendering pressure. Pure-play companies at bottleneck layers like [[Coherent (COHR)]], [[Lumentum (LITE)]], [[IQE (IQE.L)]], and [[Sumitomo Electric (SMTOY)]] earn long supply agreements; module-only assemblers don't.
- AI training is the structural break — it converts one giant computation into thousands of synchronized chips running AllReduce every few milliseconds, which means the network "becomes almost as important as the chips themselves" and pulls optics inward from long-haul into scale-across (rack-to-rack, already huge) and eventually scale-up (NVLink domains, where copper still rules but power/reach limits are forcing the transition). Every speed step (400G→800G→1.6T) is a revenue event because you can't software-upgrade physical components.
- Power is the second forcing function — traditional pluggables can consume up to 40% of switch+NIC power; LPO cuts that nearly in half by removing the module DSP, and CPO cuts another 50-70% by moving optical engines onto the switch package. At million-GPU/gigawatt scale these efficiency gains are worth hundreds of millions per year, which is why hyperscalers that would otherwise wait for CPO maturity are being pushed to adopt faster. Watch [[Marvell Technology (MRVL)]] and [[Broadcom (AVGO)]] DSP exposure here.
- The InP-vs-silicon-photonics debate is misframed as a handoff — it's a hybrid. Silicon photonics scales in [[TSMC (TSM)]]'s and [[GlobalFoundries (GFS)]] / [[Tower Semiconductor (TSEM)]] fabs but silicon is "terrible at emitting light," so the laser source still comes from InP. The InP bottleneck doesn't go away even as silicon photonics gains share — it just shifts from "InP-everywhere" to "InP-for-lasers-only," which makes [[POET Technologies (POET)]] hybrid-integration plays and [[Soitec (SOI.PA)]] / lithium-niobate substrates strategically important.
- The risk side is rarely articulated cleanly: customer concentration (top-5 hyperscalers buy the majority of transceiver demand; some module makers get >30% from one customer), violent boom-bust cycles (telecom bubble saw 80%+ revenue collapse), Chinese module-layer competition pricing 20-25% below Western incumbents, geopolitical exposure (China controls indium/gallium supply; TSMC silicon photonics concentrated in Taiwan), and CPO timeline slip. Asymmetry favors bottleneck-layer pure-plays over module-assembly pure-plays for that reason.

## External Resources

- [[Lumentum (LITE)]], [[Coherent (COHR)]], [[Applied Optoelectronics (AAOI)]], [[Ciena (CIEN)]], [[POET Technologies (POET)]], [[Marvell Technology (MRVL)]], [[Sumitomo Electric (SMTOY)]], [[Mitsubishi Electric (MIELY)]], [[Furukawa Electric (FUWAY)]], [[IQE (IQE.L)]], [[Soitec (SOI.PA)]], [[Sivers Semiconductors (SIVE.ST)]], [[Tower Semiconductor (TSEM)]], [[Corning (GLW)]] — value-chain ticker hubs referenced by this primer's bottleneck/commodity layer analysis
- [[Arista Networks (ANET)]], [[Nvidia (NVDA)]], [[Broadcom (AVGO)]], [[Amazon (AMZN)]], [[Microsoft (MSFT)]], [[Alphabet (GOOGL)]], [[Meta Platforms (META)]] — hyperscaler / network-systems buyers whose AI CapEx ($416B in 2025, $600-700B guided for 2026) is the demand engine

## Original Content

> [!quote]- Source Material
> Crux Capital Group (Gaetano @cruxcapitalgroup) — 2026-03-23 — Photonics 101: Your beginner's guide to this sector
>
> If you're new here, start with this piece. Everything else we publish will build on what you learn in the next hour. Bookmark it. Come back to it. This is the foundation.
>
> ---
>
> ## What Is Photonics?
>
> ### Light vs. electricity
>
> Most data inside a data center moves in one of two ways: as electrical signals through copper wires, or as light signals through fiber optic cables or silicon waveguides. Photonics is the science and industry focused on using light to transmit, process, and detect information. In modern systems, photonics and electronics work together where electricity moves data over very short distances, and light moves data efficiently over longer distances and higher bandwidth links.
>
> Passive copper is like sending everyone by car down a crowded highway. It works, but as traffic increases, the roads get congested, movement slows, and you burn a lot more fuel. Photonics is like putting that traffic onto a high-speed rail line. The trains move faster, carry far more people at once, and do it with much less wasted energy.
>
> That, in a nutshell, is why photonics is increasingly replacing copper where data needs to move at faster and faster speeds and in larger volumes.
>
> ---
>
> ### What is a photon?
>
> A photon is the smallest unit of light. When you flip a light switch, billions of photons are emitted every second. In optical communications, we generate photons very precisely using lasers, encode information into the light signal, send that light through a glass fiber thinner than a human hair, and detect it at the other end. That's how data moves through much of the modern internet and data center infrastructure.
>
> The faster we can change or modulate the light signal, the more data we can send. Over time, optical systems have gone from sending millions of bits per second (megabits), to billions (gigabits), to hundreds of billions per second. When you hear "400G" or "800G," the G stands for gigabits per second, which is roughly how much data that connection can carry every second.
>
> ---
>
> ### Why light is (usually) better than copper for moving data
>
> Copper has been the backbone of communications for a long time. It is cheap, easy to work with, and still works very well for short distances. But as data rates rise, copper runs into physical limits that become much harder to manage.
>
> First, copper links consume more power as speeds climb, and that extra power often shows up as heat. In a dense data center, heat is expensive because it has to be removed with cooling systems.
>
> Second, electrical signals degrade over distance. The faster the signal, the harder it is to preserve cleanly over copper. At 800G, passive copper cables are generally limited to very short reaches, often around 1 to 3 meters depending on the design.
>
> Third, copper is more vulnerable to signal integrity problems such as noise and interference, especially as link speeds and cable density increase.
>
> Optical fiber behaves much better on all three fronts. Light traveling through fiber loses much less signal over distance, generates very little heat in the fiber itself, and can carry data over much longer reaches than copper. Fiber also supports wavelength division multiplexing, or WDM, which means multiple wavelengths of light can travel through the same strand of fiber at the same time, with each wavelength acting like its own lane of traffic.
>
> That does not mean fiber is perfect. Light still weakens over long distances, which is why long-haul networks need amplifiers. Fiber is also more fragile than copper, harder to handle in the field, and more sensitive to dirt and damage at the connector. Optical transceivers are precision components and can be more expensive than simple copper cables. That is why copper DACs are still common for the very shortest links. But once you need to move more data, over longer distances, with better power efficiency, optics usually wins.
>
> ---
>
> ### What the industry is doing to push copper further
>
> Copper is not going away quietly. Because optical transceivers are more expensive, data center operators want to use copper anywhere the physics still works, and engineers have developed several ways to extend copper's reach as speeds increase.
>
> Passive DAC (Direct Attach Copper) is the simplest option where a copper cable with connectors is attached at both ends and no active electronics in the cable itself. At 800G, these links are generally limited to very short reaches, often around 1 to 3 meters.
>
> ACC (Active Copper Cable) adds analog equalization in the cable assembly to improve signal integrity and extend reach. At 800G, ACC can often stretch copper into the roughly 3 to 5 meter range.
>
> AEC (Active Electrical Cable) goes further by adding retimer-based electronics in the cable ends. These devices recover and retransmit a cleaner signal, which can extend copper reach to roughly 5 to 7 meters at 800G while improving reliability and compatibility. The tradeoff is added cost, some extra power, and a bit more complexity.
>
> At the same time, switch and NIC chips are getting better at signal conditioning. More advanced SerDes and equalization on the host side allow systems to tolerate noisier electrical links than before. That is part of why newer linear architectures, including LPO, have become more practical.
>
> The broader point is that copper and optics are not simply winner-take-all technologies. They coexist across a distance and power spectrum. Copper still dominates the shortest links because it is cheaper and simpler. But as speeds rise, the distance over which copper remains practical shrinks, and more links move into the optical category. That is one of the structural reasons demand for optical interconnects keeps rising.
>
> ---
>
> ### What "optical" means
>
> You'll see the word "optical" constantly. It simply means "uses light." An optical transceiver is a device that converts electrical signals from a chip into light signals for transmission, and then converts those light signals back into electrical signals at the other end. An optical cable carries data using light rather than electrical current through copper. An optical network moves data primarily using light across its links. So photonics is the broader field, while optical usually refers to the specific components and systems built from it.
>
> ---
>
> ## Why Does This Matter Right Now?
>
> Optical fiber has been used in long-distance communications for decades. The cables connecting continents are fiber. The backbone of the internet is fiber. None of that is new.
>
> What changed is where the bottleneck now sits. For much of the internet's history, the hardest communication problem was moving data over long distances like between cities, continents, and buildings. Inside a building or data center, shorter copper connections were often good enough.
>
> That is changing. The amount of data moving inside a modern AI data center has become so large, and the required speeds so high, that short-reach electrical links are running into growing power, reach, and signal-integrity limits. The bottleneck has not disappeared outside the building, but it has increasingly moved inside the data center itself.
>
> ### The data explosion
>
> For decades, internet traffic kept growing as more of life moved online. Streaming video, cloud computing, social media, and mobile apps all pushed more and more data through networks every year.
>
> But AI changes the problem again.
>
> Traditional internet growth mostly meant more data moving across networks. AI also means far more data moving inside the data center itself, between chips, servers, racks, and clusters. And it has to move with much lower latency and much higher bandwidth than older workloads required.
>
> That is why photonics matters so much right now. The challenge is no longer just sending data across the world. It is sending enormous amounts of data efficiently across the inside of a machine, a rack, and a data center.
>
> ### The power problem is the other wall copper runs into
>
> We just covered how copper struggles with distance at high speeds. But even where active copper cables and retimers can keep up, the range where AECs can still do the job reasonably well, a second problem remains in power.
>
> Active copper does not extend reach for free. The electronics inside AECs draw real power on every link. That may not sound like much in isolation, but multiplied across a large AI cluster, it becomes meaningful. In effect, the industry is spending more power to keep copper viable for another generation.
>
> Meanwhile, power has become one of the central constraints on AI infrastructure more broadly. Amazon, Microsoft, Alphabet, and Meta collectively spent more than $400 billion on capital expenditures in 2025, much of it tied directly or indirectly to AI infrastructure and the power, cooling, and facility buildout needed to support it.
>
> Networking is not the largest line item on the power bill, but it does matter. At hyperscale, even relatively small increases in watts per link add up quickly when you are deploying thousands or hundreds of thousands of high-speed connections. That is one reason power efficiency matters so much in interconnect design as every extra watt has to be generated, delivered, and cooled.
>
> ---
>
> ## How AI Is Turbocharging Photonics Demand
>
> AI training is unlike most computing workloads that came before.
>
> Many traditional computing tasks like serving web pages, handling database queries, or streaming video can be spread across large numbers of servers that work relatively independently. One server can handle one request without needing to stay in constant lockstep with thousands of others.
>
> AI training is different. When you train a large model, one enormous calculation is split across thousands of chips working at the same time. Every few milliseconds, those chips need to synchronize, exchange updates, and stay aligned as they train the same model together.
>
> A useful way to think about it is like 1,000 people working on the same shared document at once. Every so often, everyone has to send in their latest edits, combine them into one updated master copy, and then give that updated version back to every participant. In AI systems, one of the key communication steps that does this is called AllReduce.
>
> This has a huge consequence where the network between chips becomes almost as important as the chips themselves. If the network is slow, congested, or power-inefficient, expensive processors sit idle waiting for data. In AI training, the system only moves as fast as its ability to keep all of those chips synchronized.
>
> ### What a GPU cluster looks like, and why it needs so many optical connections
>
> A modern AI training cluster is built in layers.
>
> At the bottom is the GPU, the main compute engine. GPUs are specialized processors built to handle the large matrix calculations that power modern AI.
>
> Those GPUs sit inside servers, which often contain several GPUs connected by very high-speed electrical links such as NVLink. You can think of each server as a tightly connected compute node.
>
> Servers are grouped into racks. Racks are then connected into larger network domains, often called pods or clusters, using multiple layers of switches.
>
> As these systems scale, more and more of the connections between servers, racks, and pods need to move data over optical links rather than copper. And every optical link needs a transceiver at both ends.
>
> That is why optical component counts rise so quickly. In very large AI systems, the number of optical transceivers can reach into the hundreds of thousands or even millions.
>
> ### Scale-up vs. scale-across vs. scale-out
>
> There is an important distinction worth understanding: scale-up, scale-across, and scale-out describe three different ways AI systems expand, and each creates optical demand in a different part of the network.
>
> Scale-up means making a single compute domain bigger by connecting more GPUs so tightly that they behave almost like one giant processor. Today, this is the world of NVLink and other very high-bandwidth, low-latency interconnects inside a server or within a tightly integrated rack-scale system. Right now, that connectivity is still electrical. But as scale-up domains grow from dozens of GPUs toward hundreds or more, the physical limits of copper become harder to manage, which is why more people expect optics to eventually move into this layer as well.
>
> Scale-across means connecting nearby compute units to each other across the data center fabric, such as server-to-switch, rack-to-rack, and pod-level connections. This is where a huge amount of optical demand already sits today. These links need to move massive amounts of data at high speed, but over distances where copper quickly becomes impractical. This is the core market for pluggable optical transceivers today.
>
> Scale-out means connecting larger clusters, pods, or entire data centers together so the total system can keep expanding. This includes the broader network layer that ties together many compute domains into one much larger AI system. These links are often longer reach, and they also rely heavily on optical fiber.
>
> The key point is that optics is being pulled in from both directions at once. Scale-out continues to grow as AI clusters become larger and more distributed. At the same time, optics is moving inward toward the scale-up domain as bandwidth rises and copper runs into power, reach, and signal-integrity limits. Scale-across sits in the middle and is already one of the biggest engines of optical demand today.
>
> ### Speed upgrades are major revenue events
>
> The optical industry moves through repeated speed upgrades. As new generations such as 400G, 800G, and now 1.6T are adopted, new clusters and network expansions require a fresh round of higher-performance hardware. Unlike software, you cannot unlock these speed gains with a simple update. You need new physical components.
>
> The current transition is from 400G to 800G, with 1.6T beginning to ramp. In general, each step up in speed increases the value of the optical module, because the performance requirements, component count, and technical complexity all rise. That means speed migrations are not just bandwidth events. They are revenue events for the optical supply chain.
>
> Every time a hyperscaler builds a new AI cluster at a higher speed, expands an existing one, or shifts to a denser network architecture, the optical industry benefits. With AI systems now being built at extraordinary scale, those upgrade waves can drive very large demand even without assuming every installed port is replaced all at once.
>
> ---
>
> ## How a Data Center Gets Built
>
> A hyperscale data center is not just a big building full of servers. It is a hierarchy of interconnected systems, with each layer designed for a specific job.
>
> The campus is the overall site. It may contain multiple data center buildings along with substations, backup generation, cooling infrastructure, and other power equipment.
>
> The building is one data center structure within that campus. Large campuses often contain multiple buildings, each housing compute and networking equipment.
>
> Inside the building are one or more data halls, which are the large rooms where the computing equipment actually sits.
>
> Inside each data hall are rows of racks.
>
> A rack is the tall metal cabinet that holds the equipment. It contains servers, power distribution, cabling, and often nearby switching equipment.
>
> A server is the individual compute unit installed in the rack. In traditional data centers, servers may be CPU-heavy. In AI data centers, they are increasingly built around multiple accelerators and very high-speed networking.
>
> The GPU is the main AI compute engine inside those systems. GPUs are specialized processors built for the matrix math that powers deep learning. In many modern AI servers, several GPUs are tied together with very high-speed links such as NVLink. Current data center GPUs can consume hundreds of watts each, and the newest systems are pushing even higher.
>
> The NIC is the server's network interface. It connects the server to the broader network so data can move between servers, racks, and clusters.
>
> ### Where optical interconnects actually live
>
> Not every connection in a data center uses optics. The choice between copper and optical links depends mostly on distance, speed, and power.
>
> For the shortest links, especially inside a rack, copper still plays a major role. As distances get longer and bandwidth requirements rise, optics becomes more attractive and eventually dominant.
>
> A simple way to think about it is:
>
> Within a rack: copper dominates the shortest links, though this can vary by system design.
>
> Rack to rack: this is a transition zone where both advanced copper and short-reach optics can be used.
>
> Switch to switch across rows, pods, or data halls: optics becomes increasingly dominant.
>
> Building to building, campus, metro, long-haul, and subsea: these are overwhelmingly optical domains.
>
> The broad trend is that AI is pulling optics deeper into the data center. What used to be mainly a long-haul and metro technology is now moving into the campus, the data hall, and eventually closer to the rack and compute fabric itself.
>
> ### How a spine-leaf network works
>
> Inside modern AI data centers, the network is often built in a leaf-spine architecture. You do not need to memorize the details, but the concept matters because it explains why transceiver counts get so large.
>
> Leaf switches sit closer to the servers. Spine switches sit above them and interconnect the leaf layer. The design is meant to keep paths short, predictable, and scalable as the cluster grows.
>
> Each optical link between a leaf and a spine needs a transceiver at both ends. So when you multiply uplinks across many switches, transceiver counts rise very quickly.
>
> For AI clusters, operators often try to build these fabrics with little or no oversubscription, meaning the network is designed so that bandwidth does not collapse when many GPUs communicate at once. That is expensive, but it is one of the reasons optical demand scales so quickly in AI infrastructure.
>
> ---
>
> ## The Full Photonics Value Chain
>
> Imagine a supply chain that starts with raw materials in the ground, passes through a dozen specialized manufacturing steps, and ends with a transceiver module the size of your thumb generating light signals that carry your AI prompt across a data center in nanoseconds.
>
> Each step in that chain requires highly specialized knowledge, equipment, and facilities. Some steps are bottlenecks where only a handful of companies in the world can do them. Others are commoditized with dozens of manufacturers compete on price. In my opinion, the most valuable positions in any supply chain are the bottlenecks.
>
> Let's walk through each layer.
>
> ---
>
> ### a. Materials & Substrates
>
> Everything in photonics starts with a wafer which is a thin, circular disk of semiconductor material, typically 2–6 inches in diameter, from which hundreds or thousands of chips are carved.
>
> For traditional electronics the wafer material is silicon, which is the most abundant semiconductor in the Earth's crust and the foundation of the entire semiconductor industry.
>
> For the light-generating components in optical systems, silicon has a fundamental problem in that it's terrible at emitting light. This is why the laser components at the heart of optical systems are built from a different material.
>
> Indium Phosphide (InP) is the material of choice for high-performance lasers and photodetectors. It can emit and detect light efficiently, operates at the precise wavelengths used in fiber optic communications (around 1,310 and 1,550 nanometers), and can handle the high speeds required for modern transceivers.
>
> The challenge is that InP is expensive, brittle, and difficult to manufacture. Only a handful of companies in the world have the capability to produce high-quality InP wafers at scale. This scarcity is a core constraint on optical component production.
>
> Silicon photonics is an attempt to get around InP's limitations by building most of an optical chip in silicon (cheap, scalable, manufacturable in the same fabs as conventional chips) while bringing in light from an external InP-based laser. This hybrid approach has been enormously successful for moderate-performance transceivers and is gaining share rapidly, but it still depends on InP for the laser source, meaning the InP bottleneck doesn't go away.
>
> Lithium Niobate is an emerging substrate material with exceptional electro-optical properties (meaning it can change how it interacts with light very quickly when voltage is applied). It's used in specialized modulators and is increasingly relevant for next-generation CPO applications.
>
> ---
>
> ### b. Epitaxy
>
> Epitaxy is the process of growing extremely thin, precisely structured layers of semiconductor material onto a wafer, one atomic layer at a time.
>
> You must have exactly the right thickness, made of a specific material, with precisely controlled impurity levels, and the tolerances are measured in individual atoms. The layers being grown are often only a few nanometers thick (a nanometer is one billionth of a meter, roughly 3–4 atoms).
>
> The optical and electrical properties of a laser chip are heavily determined by its epitaxial structure. Get the layers wrong, even by a few atoms, and the laser doesn't emit at the right wavelength, doesn't have the right efficiency, or doesn't work at all.
>
> Epitaxial growth for InP-based laser structures is performed in specialized reactors called MOCVD machines (Metal-Organic Chemical Vapor Deposition). These machines cost in the ~$5 million range, require highly controlled environments, and take years of process development to master. This makes epitaxy a significant barrier to entry and a key bottleneck in laser chip production.
>
> ---
>
> ### c. Lasers & Light Sources
>
> Optical links start with a laser. The laser converts an electrical signal into light, which then travels through fiber or a waveguide to a detector at the other end, where it is converted back into an electrical signal.
>
> Not all lasers are the same. Different optical systems use different types depending on speed, distance, cost, and power requirements.
>
> DFB Lasers (Distributed Feedback Lasers) emit a single, very precise wavelength of light. You can think of them like a perfectly tuned musical instrument playing one note. They are commonly used in high-speed optical transmitters where wavelength stability and signal quality matter.
>
> VCSELs (Vertical-Cavity Surface-Emitting Lasers) emit light vertically from the surface of the chip rather than from the edge. They are cheaper to manufacture, easier to test in large arrays, and are widely used for shorter-distance links, especially inside data centers. They are generally lower cost but also lower performance and shorter reach than edge-emitting laser types.
>
> EMLs (Electro-Absorption Modulated Lasers) combine a laser and a very fast modulator in one device. The modulator changes the light signal extremely quickly to encode data. EMLs are widely used in higher-speed optical transceivers, especially for longer reach and high-performance applications like 400G, 800G, and emerging 1.6T links.
>
> CW Lasers (Continuous Wave Lasers) are commonly used in silicon photonics systems. The laser produces a steady beam of light, and a separate silicon-based modulator encodes the data onto that light. This separates the "generate light" function from the "encode data" function and allows more of the system to be manufactured using silicon processes.
>
> One of the key constraints in the optical industry is laser supply, particularly high-performance lasers used in advanced transceivers. As data center speeds increase and AI clusters grow larger, demand for these laser components has risen significantly, which is one reason silicon photonics and new optical architectures are receiving so much attention.
>
> ---
>
> ### d. Photonic Integrated Circuits (PICs)
>
> A Photonic Integrated Circuit, or PIC, is the optical version of a microchip. But instead of moving electrons through metal wires, it moves light through tiny structures called waveguides that are built into the chip. A PIC can combine many optical functions onto one platform, including waveguides, splitters, multiplexers, modulators, and photodetectors.
>
> The advantage is the same basic logic that drove progress in electronics where integration reduces size, reduces the number of separate parts and connections, improves reliability, and can lower cost as manufacturing scales.
>
> Silicon photonics PICs are built using silicon-based manufacturing processes, which lets them benefit from the scale and discipline of semiconductor fabs. Think of silicon photonics as combining optical communication with high-volume silicon manufacturing, and TSMC now offers a silicon photonics foundry platform as part of its broader AI and HPC stack.
>
> InP PICs are built on indium phosphide, a material that is especially well suited for active optical functions. One of their biggest strengths is that lasers, amplifiers, modulators, and detectors can all be integrated on the same material platform. That makes InP very powerful for high-performance optical systems, though it also relies on a more specialized manufacturing base than silicon.
>
> The industry is not moving from InP to silicon in a clean, one-way handoff. What is really happening is a hybrid model. Silicon photonics is gaining share because it scales well in large manufacturing flows, while InP remains essential for many of the laser and other active optical functions that silicon does not do as naturally. In practice, many of the most important systems combine both.
>
> ## e. Electronic ICs & DSPs
>
> When light reaches the receiver, the signal is not perfectly clean. It may have been weakened or distorted by the link, the components, and the electrical path around it. A DSP, or Digital Signal Processor, is the electronic chip that helps recover that signal and turn it into something the system can reliably use.
>
> You can think of the DSP as the signal-cleanup engine inside the transceiver. It helps with equalization, error correction, clock recovery, and the handoff between the optical components and the host switch or server. That extra processing improves link robustness, but it also adds cost, complexity, and power.
>
> This is why LPO (Linear Pluggable Optics) has attracted so much attention. In an LPO design, the module removes the traditional DSP from the transceiver and relies more heavily on the host system to handle retiming and signal recovery. The benefit is lower module power and lower cost. The tradeoff is that the electrical channel has to be cleaner and the overall system design has to be tighter.
>
> That makes LPO most attractive for shorter-reach, high-volume links inside AI clusters, where operators care deeply about saving watts on every port. It is one of the clearest examples of how the optical industry is trying to lower power per bit as cluster sizes continue to grow.
>
> ### f. Optical Packaging and Co-Packaged Optics
>
> Even after you have a laser, a photonic chip, and the electronics, one of the hardest problems is packaging. Packaging means taking tiny optical chips, aligning them precisely with fiber, protecting them from contamination, managing heat, and making sure they operate reliably for many years.
>
> Optical packaging is difficult because light is very sensitive to alignment. If a fiber is misaligned by only a few microns, a large portion of the signal can be lost. The components also run hot, materials expand and contract, and the assembly process must be extremely precise while still being economical at large production volumes.
>
> Most optical links today use pluggable transceivers. These are small, self-contained modules that slide into a port on a switch or server. The pluggable model is convenient because modules can be replaced, upgraded, or swapped for different reaches and speeds. This flexibility is one reason pluggable optics has been the dominant form factor for decades.
>
> Co-Packaged Optics (CPO) is a different approach. Instead of placing the optical module at the front panel of a switch, the optical engines are placed very close to the switch chip, typically on the same board or package. The goal is to shorten the electrical distance between the switch ASIC and the optics.
>
> Long electrical traces between the switch chip and a pluggable module consume power and degrade signal quality at very high speeds. Moving the optics closer to the switch can reduce power per bit and improve signal integrity.
>
> The tradeoff is serviceability and reliability. With pluggable optics, a failed module can be replaced easily. With co-packaged optics, the optical engines are tied more closely to the switch system, which makes replacement and repair more complicated. The industry is working on solutions such as external laser sources, redundant optical engines, and serviceable optical modules.
>
> Co-packaged optics is not replacing pluggables immediately. Most industry roadmaps suggest that pluggable optics will remain dominant for several more years, with co-packaged optics potentially becoming more important later in the decade as speeds and power constraints continue to rise.
>
> ---
>
> ### g. Test & Measurement
>
> Optical components are notoriously difficult to test. A laser emitting slightly off-wavelength, a modulator with slightly degraded extinction ratio (the contrast between "light on" and "light off"), a fiber interface with slightly too much insertion loss. These defects might not be obvious until the component is installed and running, potentially causing intermittent failures that are very hard to diagnose.
>
> Automated Test Equipment (ATE) for optical components is expensive, slow compared to electronic testing, and requires specialized engineering. Testing a high-speed optical transceiver might require expensive reference light sources, precise optical power meters, high-bandwidth oscilloscopes, and controlled temperature environments.
>
> Yield, which is the percentage of chips or modules that pass testing, is a critical economic variable. If 80% of your EML chips pass final test, you're generating 20% waste from every wafer you grow. Improving yield by 5 percentage points can mean the difference between profitability and loss at high volumes. Optical component makers with better yield have a structural cost advantage that compounds over time.
>
> ---
>
> ### h. Transceivers & Optical Modules
>
> A transceiver (short for transmitter + receiver) is a complete packaged module that plugs into a switch or server and handles both sending and receiving optical signals. It contains the laser, the modulator, the photodetector, the DSP, the power management, the monitoring circuits, and the mechanical housing, all in a package roughly the size of a thumb drive.
>
> Transceivers are the ammunition that the data center industry buys in enormous quantities. When hyperscalers build AI clusters, they're buying transceivers by the hundreds of thousands.
>
> Form factors are the physical shapes transceivers come in. You'll encounter these names frequently:
>
> - QSFP-DD (Quad Small Form-Factor Pluggable Double Density): The standard for 400G, now also used for 800G. QSFP has been the industry workhorse for a decade. DD added more density.
> - OSFP (Octal Small Form-Factor Pluggable): A slightly larger form factor designed for 800G and 1.6T, with better thermal management. Most large AI cluster operators (including the hyperscalers) prefer OSFP for new deployments.
>
> Don't get bogged down by these terms. This is just here as a reference point if you do encounter them.
>
> The MSA (Multi-Source Agreement) is how the industry ensures that a transceiver from Vendor A works in a switch from Vendor B. Representatives from dozens of companies agree on the physical dimensions, electrical interfaces, and software management protocols, then any compliant product interoperates with any other compliant product. This industry self-standardization is crucial for the ecosystem to function.
>
> ---
>
> ### i. Systems & Network Equipment
>
> At the top of the stack, all these components get assembled into the switches, routers, and line cards that network operators actually buy and install.
>
> A network switch is like a highway interchange where it receives data arriving on many incoming links, figures out where each piece of data needs to go, and routes it to the correct outgoing link. A modern data center switch might have 128 or 256 ports, each operating at 800G, requiring a transceiver (and its associated fiber) at each port.
>
> The switch ASIC (Application-Specific Integrated Circuit) is the custom chip inside the switch that performs routing at wire speed. The largest switch ASICs handle over 100 terabits per second.
>
> Companies like Cisco, Arista, and Juniper have traditionally dominated the network equipment market, buying their optical components and assembling them into complete systems. But as AI has made networking a competitive differentiator, the largest hyperscalers have started designing their own custom ASICs and even developing their own optical systems, reducing their dependence on traditional equipment vendors and taking more of the value chain in-house.
>
> The supply chain has layers of dramatically different attractiveness. Bottleneck layers (materials, EML lasers, leading-edge PICs) command high margins and are defensible. Assembly and module layers are increasingly competitive. Understanding which layer a company occupies, and whether that layer is bottleneck or commodity, is the first analytical step in evaluating any photonics investment.
>
> ---
>
> ## Section 6: Key Industry Standards & Roadmaps
>
> ### Why standards matter
>
> Standards bodies are the unsexy but critical machinery that makes the optical industry function. When IEEE 802.3 publishes a new standard defining the electrical interface for 1.6 terabit links, it sets off a global wave of investment and product development. Every transceiver maker, switch maker, and cable maker must align to that specification.
>
> The takeaway for us is that standard publication dates function like scheduled revenue events. Once a standard is ratified:
>
> - Hyperscalers issue RFPs (requests for proposals) from suppliers
> - Suppliers ramp manufacturing
> - Deployments begin 12–18 months after ratification
> - The revenue wave peaks 2–3 years after ratification
>
> The key bodies are:
>
> IEEE (Institute of Electrical and Electronics Engineers): Sets the Ethernet standards, including the physical layer specifications that define each speed generation. "802.3" is the Ethernet standard family.
>
> OIF (Optical Internetworking Forum): Sets the electrical interface specifications between chips and optical components. OIF standards are what allow a DSP chip from Broadcom to work with a PIC from Coherent in a module assembled by Innolight, even though each company designed their component independently.
>
> MSA groups: Industry consortia that set physical form factor standards for transceiver modules. The OSFP MSA, QSFP-DD MSA, and others ensure that modules from different vendors fit in the same cages.
>
> ### The speed roadmap
>
> The progression of optical speeds follows a remarkably consistent doubling pattern, driven by improvements in laser technology, modulation techniques, and signal processing:
>
> 100G (100 gigabits per second): Deployed 2010–2016. The standard for many years, now being retired in AI clusters but still widely deployed in enterprise and older cloud infrastructure.
>
> 400G: The current mainstream. Deployed at scale from 2020 onward. Now the "legacy" option for AI clusters. IEEE 802.3bs standardized it in 2017 and mass adoption came 2020–2023.
>
> 800G: The current leading edge for AI. IEEE 802.3df ratified in early 2024. Mass deployment began in 2024–2025. This is where the biggest revenue action is happening right now.
>
> 1.6T (1.6 terabits per second): Early commercial shipments began in late 2025. IEEE 802.3dj expected to ratify around 2026–2027. Mass deployment expected 2026–2028.
>
> 3.2T: In R&D. Early technical specifications being developed. Commercial deployment likely 2028–2030 and beyond.
>
> The speed doubling is not free. Each new generation requires:
>
> - Higher-performance lasers with tighter wavelength control
> - Faster modulators (200G per lane for 1.6T vs. 100G per lane for 800G)
> - More sophisticated signal processing
> - Better packaging with improved thermal management
>
> This is why each speed transition creates a real technology barrier and why incumbents with established manufacturing processes have meaningful advantages over new entrants.
>
> ### The Pluggable → LPO → CPO Transition
>
> One of the most important structural changes in the industry right now is the migration away from traditional pluggable transceivers toward more power-efficient and more integrated approaches. This is worth understanding clearly.
>
> Traditional pluggable: A standalone module with its own optics and signal-processing electronics that plugs into the front panel of a switch or server. Convenient, swappable, proven, and still the dominant form factor today. The downside is power because as speeds rise, the electrical path from the switch ASIC to the front-panel module becomes more expensive in watts and harder to manage.
>
> Linear Pluggable Optics (LPO): Still a pluggable module, but without the traditional DSP inside the transceiver. More of the signal-conditioning burden is pushed into the host system. This can materially reduce module power and latency while preserving the familiar pluggable form factor. OIF says LPO can reduce module power by up to 50% versus traditional retimed pluggables. It works best in shorter, tightly controlled links inside AI clusters.
>
> Co-Packaged Optics (CPO): The optical engines are placed much closer to the switch chip, typically on the same package or tightly coupled substrate. The electrical path is measured in millimeters instead of centimeters. That reduces power and improves signal integrity at very high speeds. Broadcom says its CPO platform delivers more than 3.5x power-consumption savings, and one production system example cited more than 30% system-level power savings versus traditional pluggables.
>
> LPO is more deployable than CPO because it keeps the pluggable operational model. But it is not just a software update. The host system still needs the right electrical interface and enough signal-processing capability to support it. CPO, by contrast, requires a much bigger architecture shift: new packaging, new thermal design, new service models, and often new laser architectures as well.
>
> The transition timeline is likely to look something like this:
>
> Now–2027: Traditional pluggables remain the volume baseline, while LPO begins gaining share in selected short-reach AI links.
>
> 2026–2028: Early CPO deployments begin appearing in leading-edge AI systems, especially where power density and bandwidth are becoming the central constraint.
>
> 2028–2030: CPO becomes more meaningful in hyperscale AI buildouts, but pluggables still remain important across large parts of the market.
>
> 2030+: The likely outcome is not total replacement, but coexistence. Traditional pluggables, LPO, and CPO will each remain relevant in different parts of the network depending on reach, serviceability, cost, and power.
>
> The LPO vs. CPO debate has real stakes. LPO can pressure the value of standalone module DSPs on the shortest links. CPO can shift value toward switch ASIC vendors, silicon photonics, advanced packaging, and external laser ecosystems. The transition will create winners and losers, but it is unlikely to happen as one clean step-change where a single architecture instantly replaces everything else.
>
> ---
>
> ## Section 7: The Tailwinds
>
> ### 1. AI infrastructure spending that shows no signs of slowing
>
> The four largest technology companies collectively spent $416 billion on infrastructure in 2025, up 66% from the prior year. All four are guiding for even higher spending in 2026 (often cited around $600-$700 billion). The commitments extend years into the future with multi-year contracts with chip manufacturers, long-term power purchase agreements, land acquisition for new campuses.
>
> This is not discretionary spending that gets cut when the economy wobbles. It is existential competitive investment. A hyperscaler that falls two generations behind in AI infrastructure loses customers who need the latest AI capabilities, and those customers are sticky and high-value.
>
> The optical component industry is a direct beneficiary. Every GPU added to a cluster requires optical transceivers. Every new switch requires optical transceivers. Every new building added to a campus requires fiber and optical interconnects. The capex spending number is the leading indicator; optical revenue follows.
>
> ### 2. Power constraints accelerating the optical migration
>
> As data centers push against the limits of what the electrical grid can supply, the energy efficiency of every component becomes a competitive variable.
>
> Traditional pluggable transceivers can consume up to 40% of total switch and NIC power in an AI cluster. Migrating to LPO cuts that nearly in half. Moving to CPO cuts it by another 50–70%. At the scale of a million-GPU facility drawing gigawatts of power, these efficiency gains are worth hundreds of millions of dollars per year in electricity costs.
>
> Power constraints are therefore a forcing function for faster optical migration. Companies that would otherwise wait for CPO technology to mature are being pushed to adopt it faster by the simple math of electricity bills.
>
> ### 3. Sovereign AI buildouts outside the United States
>
> The United States is not the only country building AI infrastructure at scale. The European Union, Japan, Saudi Arabia, the UAE, India, and Australia are all investing in domestic AI compute capacity, partly for economic competitiveness, partly for national security reasons.
>
> These buildouts create demand for optical components independent of the US hyperscaler cycle. They also create demand for local supply chains, potentially benefiting optical component manufacturers with global manufacturing footprints.
>
> ### 4. 5G and 6G wireless backhaul
>
> Every cell tower connects back to the internet through a wired connection, typically fiber with optical transceivers at both ends. As 5G networks are deployed and eventually upgraded to 6G, the bandwidth requirements for backhaul increase substantially. This creates an optical demand tailwind that's separate from the data center story.
>
> ### 5. The custom ASIC wave reducing switch-silicon competition
>
> Hyperscalers are increasingly designing their own custom chips instead of buying them from third parties. This reduces dependence on a single switch ASIC vendor but doesn't reduce demand for optical components. In fact, custom designs often incorporate optical interfaces more aggressively.
>
> ### 6. Enterprise digitization catching up
>
> Enterprise data centers like hospitals, banks, manufacturers, retailers are several generations behind hyperscalers in networking technology. As they upgrade from 10G and 25G to 100G and 400G infrastructure, they represent a long-duration secondary demand wave for optical components.
>
> ---
>
> ## Section 8: The Risks
>
> ### 1. CPO timelines could slip
>
> Co-packaged optics is technically hard. Aligning optical fibers to a photonic chip to within a few microns at manufacturing scale, at low cost, with high yield, is an unsolved production problem. Early CPO deployments have shown promising results in controlled settings, but volume manufacturing at the quality levels required for data centers has not yet been proven.
>
> If CPO deployment is delayed by 2–3 years, the companies that made large bets on CPO-specific technologies could face revenue shortfalls and balance sheet pressure.
>
> ### 2. Customer concentration is extreme
>
> The top five hyperscalers like Amazon, Microsoft, Google, Meta, and increasingly NVIDIA (as a buyer rather than cloud provider), account for the majority of optical transceiver demand. Some transceiver companies get more than 30% of their revenue from a single customer.
>
> If one hyperscaler decides to pause its buildout, delays a purchase cycle, or shifts supply to a competitor, the impact on its suppliers can be severe. The optical component industry has experienced violent boom-bust cycles historically and companies that grew 80% in one year shrank 40% the next.
>
> ### 3. Inventory cycles are inherent to the business
>
> Because optical components are bought in large quantities tied to specific project deployments, the industry is prone to inventory cycles. When hyperscalers are building aggressively, they order ahead of need, building buffer stock. When a project completes or is delayed, orders dry up suddenly and that buffer stock sits in warehouse, depressing new orders for quarters.
>
> This dynamic has repeated multiple times in the industry's history. Even in a secular growth environment, individual companies can experience sharp cyclical downturns that temporarily impair their financial results.
>
> ### 4. Chinese competition at the module layer
>
> Chinese transceiver manufacturers have become formidable competitors, especially at the 400G level. They benefit from lower manufacturing costs, Chinese government support for domestic technology development, and decades of experience building lower-end modules. They typically price 20–25% below Western incumbents.
>
> At higher speeds (800G and 1.6T), Western companies currently maintain a technology lead as Chinese manufacturers are dependent on US-designed DSP chips for advanced transceivers. But this lead is narrowing, and if US export controls tighten to include the DSP chips that Chinese module makers depend on, the resulting supply disruption could be significant in either direction.
>
> ### 5. Geopolitical risk in the supply chain
>
> Indium and gallium: China controls the majority of global supply of key raw materials used in compound semiconductors. Export restrictions could constrain production of lasers and InP wafers with very little short-term substitute.
>
> Taiwan: TSMC's advanced silicon photonics processes are concentrated in Taiwan. A disruption to Taiwan's semiconductor industry for any reason would be felt acutely in the CPO deployment timeline.
>
> US-China relations: Several leading Chinese transceiver manufacturers have been flagged for potential addition to US military-linked entity lists. Formal designation could restrict US companies from purchasing from these suppliers, requiring rapid and disruptive supply chain shifts.
>
> ### 6. AI investment sentiment could shift
>
> The current optical boom is predicated on continued and accelerating AI infrastructure investment. If it becomes clear that AI capabilities have plateaued, that AI applications are not generating adequate returns on infrastructure investment, or that a geopolitical event causes hyperscalers to pull back capex, demand for optical components would drop sharply.
>
> The optical industry's history includes the telecom bubble of 1999–2001, when optical transceiver revenue collapsed over 80% in two years after speculative overinvestment. While today's demand is more fundamental and better-grounded, the risk of an overshoot followed by a correction is real.
>
> So the takeaway is this. This is a high-growth, high-cyclicality, high-geopolitical-risk industry. The structural growth is real and durable. The path to that growth is not smooth. Position sizing, entry timing, and company selection (preferring bottleneck-layer businesses over commodity-layer ones) are how we can manage these risks.
>
> ---
>
> ## Where to Invest in the Photonics Stack
>
> The most valuable position in any supply chain is the bottleneck which is the layer where supply is constrained and cannot easily be replaced or replicated. Bottleneck layers command high margins, long customer relationships, and strong pricing power. Commodity layers compete primarily on price, face margin compression, and are susceptible to disruption.
>
> In photonics, the bottleneck layers are generally at the bottom of the stack with materials, epitaxy, lasers, and leading-edge PICs. The commodity layers tend to be in the middle with module assembly and standard transceiver manufacturing.
>
> ### The investment landscape by layer
>
> The companies that produce InP wafers, provide epitaxial growth services, or develop novel substrate materials occupy one of the most defensible positions in the value chain. The barrier to entry is enormous with specialized equipment, decades of process knowledge, and relationships with a small number of critical customers. Growth here is directly tied to laser chip production growth, which is directly tied to transceiver volume.
>
> The risk is that it's a small market in absolute revenue terms, limiting how large any individual company can grow. Geographic concentration of supply is a geopolitical risk.
>
> ## Lasers
>
> EML lasers are in severe shortage today and will likely remain supply-constrained through 2027. Companies with EML manufacturing capacity are effectively selling into a demand environment where customers are willing to pay premiums and sign long-term supply agreements.
>
> The risk is that silicon photonics, which reduces dependence on EML chips, is gaining share at each speed generation. The long-term EML market share could shrink even as the total optical market grows.
>
> Most of the laser companies we discuss have exposure to many different types of lasers.
>
> ## PICs and photonic chips
>
> The transition to silicon photonics and CPO architectures will reward companies with proprietary photonic chip technology. This is where the most venture capital is flowing and where the most interesting startups are building.
>
> The risk here is that the technology is still evolving, manufacturing yield is challenging, and the CPO deployment timeline is uncertain.
>
> ## Transceiver modules
>
> This is the largest revenue layer of the value chain today and the most directly tied to AI capex spending. Companies here benefit enormously from the current boom. But the module business is increasingly competitive as Chinese manufacturers are formidable, and hyperscalers are actively reducing prices through competitive tendering.
>
> Companies that can differentiate, through proprietary optical chip technology, manufacturing excellence, or unique customer relationships, maintain better margins. Pure assembly businesses face commoditization pressure.
>
> ## Contract manufacturing
>
> Companies that manufacture optical products for others, assembling components into finished modules, participate in the volume growth without taking technology risk. Margins are lower (typically mid-single-digit to low-double-digit) but more predictable.
>
> ## Network systems
>
> The Ciscos, Aristas, and Junipers of the world buy optical components as inputs to their switch products. They're indirect beneficiaries of optical technology advancement but don't have the same leverage to the photonics growth story. They do benefit from AI infrastructure spending broadly.
>
> ### Pure-plays vs. diversified exposure
>
> Pure-play photonics companies offer the most direct exposure to industry growth, but come with the most volatility. When the optical cycle turns up, pure-plays can double or triple. When it turns down, they can fall by 50–70%. These are not "set and forget" investments.
>
> Diversified companies with significant photonics exposure give investors participation in the growth story with some buffer from other business lines. The tradeoff is that strong performance in photonics may be offset by weakness in other segments.
>
> Hyperscalers are indirect beneficiaries as they're the buyers, not the sellers. Their stock performance reflects AI demand broadly, not optical technology specifically.
>
> Private companies and startups in CPO, silicon photonics, and next-generation laser technologies represent the highest risk and highest reward. These are for sophisticated investors who can handle illiquidity and binary technology risks. We will not be discussing these as investments on my page.
>
> ### What financial metrics matter most
>
> Revenue growth rate is the primary indicator in a hyper-growth phase. Companies growing 40–60%+ annually are capturing share in a rapidly expanding market.
>
> Gross margin by segment reveals where value is being captured. A company that shows optical component gross margins of 45%+ versus module assembly margins of 15% is telling you a lot about its competitive position.
>
> Design win pipeline is the leading indicator for future revenue. When a hyperscaler qualifies a new supplier's product for deployment in their next cluster generation, that's a design win and it typically translates into 18–36 months of forward revenue visibility.
>
> ASP (Average Selling Price) trends tell you whether a company is moving up to higher-speed products (ASPs rising) or getting stuck in commodity segments (ASPs declining). In the optical industry, the ideal is a company whose product mix is constantly shifting toward the latest generation.
>
> Inventory levels (days of inventory) are the early warning system for a cyclical downturn. When customers stop ordering and inventory builds, a correction is usually 1–2 quarters away.
>
> The photonics opportunity is real, durable, and large. But it requires actively managing cyclicality, being selective about which layers of the stack you're exposed to, and maintaining conviction through the inevitable corrections. The investors who will do best are those who understand the technology well enough to know whether a stock selloff reflects a temporary cycle or a structural deterioration and act accordingly. My goal on this page is to stay dynamic and try to stay ahead of the curve.
>
> ---
>
> ## Section 10: Essential Glossary
>
> Here are the key terms you'll encounter reading photonics research, earnings calls, and technical coverage. Learn these and you'll follow any industry conversation. This section was generated with ChatGPT, but then I verified and edited.
>
> ---
>
> AllReduce — A communication step used in distributed AI training. Each processor contributes its local data, the network combines that data using an operation like a sum, and the final combined result is sent back to every processor. This is why AI clusters need very fast, low-latency networks.
>
> ASIC (Application-Specific Integrated Circuit) — A custom chip designed for a specific job. In networking, switch ASICs move data through a switch at very high speeds. Many hyperscalers now design some of their own ASICs rather than buying only standard merchant silicon.
>
> ASP (Average Selling Price) — The average revenue a company receives per unit sold. Rising ASPs usually mean a company is selling faster, more capable, or more valuable products. Falling ASPs can signal pricing pressure or commoditization.
>
> Bandwidth — The maximum amount of data that can move across a link in a given time, usually measured in Gbps or Tbps. Higher bandwidth means more data can be transmitted at once.
>
> Baud rate — The number of signal changes per second on a physical link. With modern signaling such as PAM4, each signal change can carry more than one bit, so the bit rate can be higher than the baud rate.
>
> Co-Packaged Optics (CPO) — An approach where optical engines are placed extremely close to the switch chip, typically on the same package or substrate. The goal is to shorten the electrical path, reduce power, improve signal quality, and support higher bandwidth.
>
> Coherent (in optics) — A type of optical transmission that uses more advanced modulation to encode more information into a light signal. It is widely used in long-haul, submarine, and data center interconnect networks where capacity and reach matter more than lowest cost.
>
> DAC (Direct Attach Copper) — A short copper cable used for very short connections, usually inside a rack. It is typically the lowest-cost and lowest-power option for short distances, but it does not scale well over longer links where optics are needed.
>
> Design win — When a customer selects and qualifies a supplier's product for use in its system. A design win usually turns into revenue later, often once the customer moves from development into production.
>
> DFB Laser (Distributed Feedback Laser) — A laser designed to emit a single, precise wavelength of light. It is commonly used in optical transmitters where wavelength control matters.
>
> Direct Detect — A simpler optical detection method where the receiver measures only the intensity of the incoming light. It is cheaper and simpler than coherent optics and works well for shorter and medium-reach links.
>
> DSP (Digital Signal Processor) — A chip that cleans up, equalizes, and processes high-speed signals. In optical modules, DSPs improve performance and reach, but they also add cost, latency, and power consumption.
>
> DWDM (Dense Wavelength Division Multiplexing) — A method of sending multiple optical signals over one fiber by assigning each signal a different wavelength. This allows a single fiber to carry much more total capacity.
>
> EML (Electro-absorption Modulated Laser) — A high-performance laser technology that combines a laser and a fast modulator in a compact design. EMLs are widely used in higher-speed optical transceivers, especially for longer reach and more demanding applications.
>
> Epitaxy / Epitaxial growth — The process of growing very thin, highly controlled semiconductor layers on top of a wafer. It is a critical manufacturing step for many lasers, photodetectors, and other compound semiconductor devices.
>
> Extinction Ratio — The difference between the "light on" and "light off" states in a digital optical signal. Higher extinction ratio generally means a cleaner signal and better link performance.
>
> Fab — Short for fabrication facility. A semiconductor manufacturing plant where chips are made.
>
> Fabless — A business model where a company designs chips but does not manufacture them in its own fab. Instead, it outsources production to foundries.
>
> Form factor — The physical size and shape standard of a transceiver module. In AI networking today, QSFP-DD and OSFP are two of the most important form factors.
>
> Foundry — A manufacturing company that makes chips designed by other companies. In electronics, TSMC is the largest foundry. In photonics, companies such as Tower Semiconductor and GlobalFoundries offer optical and silicon photonics processes.
>
> GPU interconnect — The technology that links GPUs to one another and to the broader network. Some interconnects connect GPUs inside a server or rack, while others connect racks across a cluster.
>
> GPU (Graphics Processing Unit) — A highly parallel processor originally developed for graphics, now widely used for AI training and inference because it is very good at matrix math and other parallel workloads.
>
> Hyperscaler — One of the largest cloud and internet infrastructure companies, such as Amazon, Microsoft, Google, or Meta. These companies build data centers at enormous scale and are major buyers of networking and optical hardware.
>
> InP (Indium Phosphide) — A compound semiconductor material used to make many high-performance lasers and photodetectors. It is important in optical communications because it performs well at the wavelengths commonly used in fiber networks.
>
> Insertion Loss — The amount of optical power lost as light passes through a component or connection. Lower insertion loss is generally better.
>
> Lane rate — The data rate carried on one electrical or optical lane. A higher total module speed can be achieved either by increasing the speed of each lane or by using more lanes.
>
> Latency — The delay between sending data and receiving it. In AI clusters, low latency matters because delays in communication can leave expensive processors waiting for each other.
>
> LPO (Linear Pluggable Optics) — A pluggable optical transceiver designed to use less power by removing the DSP from the module and relying more on the host system for signal conditioning. Compared with traditional retimed pluggables, LPO can materially reduce module power, but it also places tighter demands on overall system design.
>
> MSA (Multi-Source Agreement) — An industry agreement that defines standards so products from different vendors can work in the same ports and systems. MSAs help create interoperability and reduce vendor lock-in.
>
> NIC (Network Interface Card) — The component in a server that handles network traffic and connects the server to the network. In AI systems, NICs often connect CPUs and GPUs to very high-speed Ethernet or InfiniBand links.
>
> OIF (Optical Internetworking Forum) — An industry group that develops standards and implementation agreements for high-speed optical and electrical interfaces used in networking equipment.
>
> OSFP (Octal Small Form-Factor Pluggable) — A transceiver form factor designed for high-speed modules with higher power and stronger cooling needs. It is widely used in advanced AI and data center networking.
>
> PAM4 (4-level Pulse Amplitude Modulation) — A signaling method that uses four voltage levels instead of two, allowing each signal change to carry 2 bits instead of 1. PAM4 became important because it increased data rates without requiring the signal frequency to double.
>
> Photon — The basic particle of light. In optical communications, photons are generated by lasers, travel through fiber, and are detected by photodiodes.
>
> PIC (Photonic Integrated Circuit) — A chip that processes light rather than, or alongside, electrical signals. A PIC can integrate functions such as guiding, splitting, modulating, or detecting light on one chip.
>
> Pluggable — A transceiver module that slides into a switch or server port, making it easy to replace, upgrade, and service. This is still the dominant form factor today. LPO is a lower-power version of pluggable optics, while CPO is a different architecture that moves optics much closer to the switch chip.
>
> QSFP-DD (Quad Small Form-Factor Pluggable Double Density) — A widely used pluggable form factor with eight electrical lanes. It has been especially common in 400G and 800G deployments.
>
> Reach — The maximum distance an optical link can travel while still meeting performance requirements. Common shorthand includes:
>
> VSR (Very Short Reach): very short links, often inside equipment or over very short connections
>
> SR (Short Reach): usually up to about 100 meters
>
> DR (Data Center Reach): typically about 500 meters
>
> FR (Fiber Reach): typically about 2 kilometers
>
> LR (Long Reach): typically about 10 kilometers
>
> The exact reach depends on the standard, fiber type, and module design.
>
> Silicon Photonics — A way of building optical components on silicon wafers using semiconductor manufacturing techniques. It is attractive because it can scale in high-volume fabs, but silicon itself is not an efficient laser material, so these systems often still rely on III-V laser sources.
>
> Spine-leaf architecture — A common data center network design in which leaf switches connect to servers and spine switches connect the leaf switches to each other. This design allows traffic to move across the network with predictable performance and limited bottlenecks.
>
> Transceiver — A device that both transmits and receives signals. In optical networking, a transceiver usually contains a laser, a photodetector, and supporting electronics, and it converts electrical signals into optical signals and back again.
>
> VCSEL (Vertical-Cavity Surface-Emitting Laser) — A type of laser that emits light vertically from the wafer surface. VCSELs are often used for shorter-distance links because they can be manufactured in dense arrays and at relatively low cost.
>
> Wafer — A thin slice of semiconductor material, such as silicon or InP, on which many chips are built at the same time. Larger wafers can lower cost by producing more chips per manufacturing run.
>
> Wavelength — The "color" of light, measured in nanometers. Different optical systems use different wavelength ranges depending on the application, fiber type, and distance.
>
> WDM (Wavelength Division Multiplexing) — A way of sending multiple optical signals over one fiber by putting each signal on a different wavelength. CWDM uses wider spacing between wavelengths, while DWDM packs them more tightly for higher capacity.
>
> Yield — The percentage of manufactured chips or components that pass testing and meet quality standards. Higher yield means less waste and lower cost per good unit.
>
> ---
>
> That's the foundation. Everything you'll read in our analysis builds on what you've learned here. If you encounter a term or concept that isn't in this guide, reply to any issue and we'll add it. This document will be updated as the industry evolves.
>
> ---
>
> © This newsletter and its content are for informational purposes only and do not constitute investment advice.

Source: <https://cruxcapitalgroup.substack.com/p/photonics-101>
