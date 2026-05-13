---
created: 2026-05-13
published: 2026-04-01
description: Crux Capital primer on optical circuit switching (OCS) — why hyperscalers want it (fewer O-E-O conversions, lower power, software-defined topology), how MEMS-mirror (Lumentum) and digital liquid crystal (Coherent) approaches differ, Google's Jupiter/TPU validation (~30% lower capex, ~41% lower power), and what still needs to be proven before the merchant category de-risks.
source: https://cruxcapitalgroup.substack.com/p/ocs-a-must-learn-topic
type: framework
authors: ["Crux Capital Group (@cruxcapitalgroup)"]
---

## Key Takeaways

- **OCS is an architectural change, not a switch upgrade.** Per Coherent's framing, OCS is a "new capability in the data center" — it does NOT inspect packets. Its job is to physically re-route traffic across direct optical paths, keeping data in the optical domain longer and avoiding repeated optical-electrical-optical conversions through stacks of packet switches. AI training traffic ("elephant flows" — large, sustained, structured) is unusually well-suited to dedicated optical paths, which is why OCS is being pulled forward now rather than 10 years from now.
- **Google's Jupiter + TPU deployments are the architectural proof.** Live production traffic (not lab) — Jupiter used OCS + WDM to move from a Clos design to direct-connect topology with roughly 30% lower capex and 41% lower power. OCS also runs in Google's TPU infrastructure for scaling/resiliency (route around interruptions, support much larger clusters). That validates the architecture. It does NOT validate that merchant suppliers ([[Lumentum (LITE)]], [[Coherent (COHR)]]) will capture that value — product maturity, software integration, manufacturing scale, and repeat commercial adoption are still open. See [[Alphabet (GOOGL)]] hub for the Google side.
- **The two technical approaches map cleanly to two pitches.** [[Lumentum (LITE)]] = MEMS micro-mirrors → low insertion loss (R300 = 300×300 with <1.5 dB), wavelength-agnostic, high-radix scalability, "decades of WSS MEMS expertise applied to OCS." [[Coherent (COHR)]] = digital liquid crystal → no moving parts, <10 V drive (vs. higher voltage MEMS), telecom/subsea heritage, reliability-first pitch. Per Coherent CEO Jim Anderson: "if I have the choice between using a system that uses mechanical moving parts or using a system that doesn't… you're always gonna wanna use the system that has no moving parts in a data center." Open question is which tradeoff hyperscalers actually value — lower loss MEMS or reliability-first liquid crystal.
- **Lumentum is ahead commercially right now.** Disclosed backlog above $400M (most shipping 2H CY2026), a new multi-year multi-billion-dollar OCS agreement, path to a >$1B 2027 run rate. OCS is one of Lumentum's four declared growth engines. They're also pushing OCS as a broad fabric layer (spine replacement/scale-out, optical scale-up, protection/redundancy, scale-across/DCI) — not a niche product — backed by a SONiC-based control software stack and gNMI APIs. Hardware alone doesn't close the sale; the software layer makes the box deployable. See [[Lumentum (LITE)]] hub.
- **Coherent is positioning OCS as a "growth engine" with revenue timing "now."** OFC 2026 materials describe 64×64 and 320×320 systems shipping to multiple customers (originally introduced as 300×300), with 512×512 in development. >10 customer engagements; some still evaluating, some in production deployment. Underappreciated angle: Coherent OCS also pulls through more advanced optics, because the switch adds insertion loss — they introduced OCS-optimized transceivers that absorb an extra 3 dB while still supporting 2 km and 6 km reaches. SAM framing raised from ~$2B to ~$4B by 2030 as use cases broaden into scale-out, DCI, and scale-up. See [[Coherent (COHR)]] hub.
- **Six open risks before "OCS merchant category" can be called de-risked**: (1) backlog converting to durable revenue, not just headline demand; (2) customer base broadening beyond a handful of hyperscalers; (3) use cases spreading beyond spine replacement into repeat deployments across scale-up/failover/DCI/scale-across; (4) the software & orchestration layer being clean enough that customers don't treat each rollout as a custom integration project; (5) the market deciding which tradeoff matters more — low-loss MEMS vs. reliability-first LC; (6) merchant capture of the architectural value (Google proves the architecture works; doesn't prove suppliers get paid for it).

## External Resources

- [[Lumentum (LITE)]] — MEMS-mirror OCS, R300 300×300 with <1.5 dB insertion loss, $400M+ backlog, $1B+ 2027 run rate target
- [[Coherent (COHR)]] — Digital liquid crystal OCS, 64×64 and 320×320 shipping, 512×512 in development, OCS-optimized transceivers absorb 3 dB extra loss
- [[Alphabet (GOOGL)]] — Jupiter (OCS + WDM, ~30% capex / ~41% power savings on production traffic) and TPU infrastructure as the architectural proof point

## Original Content

> [!quote]- Source Material
> Crux Capital Group (Gaetano @cruxcapitalgroup) — 2026-04-01 — OCS: A Must-Learn Topic
>
> ## **Why you should care about OCS**
>
> If you invest in infrastructure for AI, you should care about OCS because it is one of the clearest ways the network is being pushed toward higher efficiency and lower power. OCS is an attempt to make parts of the fabric more direct, more flexible, and less burdened by layers of electrical switching. If you invest in Lumentum and Coherent then OCS is one of the main growth segments over the next few years that could bring in significant revenue.
>
> *OCS title/banner graphic — wide header introducing the topic*
> ![[cruxcapitalgroup-ocs-a-must-learn-topic-002.png]]
>
> Hyperscalers are wanting to implement OCS because it addresses several pressures at once. It can reduce how much traffic has to pass through layers of electrical packet switching, keep data optical for more of its journey, and give operators more control over how the fabric is configured around specific workloads, failures, and cluster designs. In an AI environment, where traffic is unusually large, sustained, and structured, those benefits become much more attractive than they would in a more conventional networking environment.
>
> *Conceptual illustration — OCS positioned within the AI data center fabric*
> ![[cruxcapitalgroup-ocs-a-must-learn-topic-003.jpeg]]
>
> Simply put, OCS creates direct optical paths across the network instead of repeatedly forcing traffic through optical-electrical-optical conversions and packet-processing layers. Fewer conversions can mean lower power, lower latency, less switching overhead, and more flexibility in how the fabric is configured.
>
> Lumentum management has described AI traffic as "elephant flows," meaning very large, sustained streams of data moving across the network. That label is useful because it captures why OCS is getting pulled forward now. AI training traffic is unusually well suited to dedicated optical paths.
>
> Google is the clearest proof point for the architecture. It shows that OCS can work at real scale inside a hyperscale AI environment. Google validates the architectural value of OCS, while companies like Coherent and Lumentum still have to prove product maturity, commercial traction, and execution in the merchant market. Coherent's own framing is useful here when they say that OCS is a "new capability in the data center," and not just another optical component dropped into an existing system.
>
> ---
>
> ## **How OCS actually works**
>
> OCS is a way to create direct optical connections across the network. Instead of sending data through several layers of electronic switches, it can set up a more direct light-based path between two points. The simplest way to think about it is that the network gets a way to physically re-route where traffic travels, rather than always forcing that traffic through the same stack of intermediate switching layers.
>
> *OCS architecture diagram — direct optical path vs. layered electrical switching*
> ![[cruxcapitalgroup-ocs-a-must-learn-topic-004.png]]
>
> Traditional networking often involves repeated handoffs. Light comes in, gets converted into an electrical signal, gets processed by a switch, and then gets turned back into light again so it can keep moving. OCS tries to reduce how often that has to happen. In parts of the network where direct optical paths make sense, it can let traffic stay in the optical domain for longer and pass through fewer electrical layers in the middle.
>
> It is also important to be clear about what OCS is not. As Coherent management put it, it is "not a replacement for an electrical switch because we're not switching packets." OCS does not inspect and forward packets the way a traditional packet switch does. Its role is to change the route the traffic takes, not to process the traffic itself. That is why it is better understood as a new network capability rather than just a faster version of a normal switch.
>
> ---
>
> ## **The two main technical approaches**
>
> Lumentum uses MEMS mirrors which are tiny mirrors that tilt to direct beams of light. Their pitch centers on low loss, high radix, and strong manufacturability. Its R300 is a 300×300 switch with less than 1.5 dB insertion loss.
>
> *MEMS micro-mirror approach — Lumentum's tilting-mirror beam-steering*
> ![[cruxcapitalgroup-ocs-a-must-learn-topic-005.webp]]
>
> Coherent uses digital liquid crystal instead of moving mirrors, steering light through liquid-crystal cells that change how they interact with incoming beams. Its pitch is built around reliability where there are no moving parts, no high-voltage components, and a foundation in telecom heritage that gives the technology a long track record before it ever entered the data-center market.
>
> *Digital liquid crystal approach — Coherent's no-moving-parts beam-steering*
> ![[cruxcapitalgroup-ocs-a-must-learn-topic-006.png]]
>
> ---
>
> ## We have to talk about Google
>
> At this point, the natural question is whether OCS is just an elegant idea or something that has already worked inside a real AI environment. That is where Google becomes the most important reference point. In Jupiter, OCS and WDM were used to move the network away from a traditional Clos design toward a direct-connect topology, with the result described as higher speed and capacity alongside roughly 30% lower capex and 41% lower power. Just as important, this was tied to live production traffic rather than a narrow lab exercise.
>
> *Google Jupiter — production reference architecture using OCS + WDM*
> ![[cruxcapitalgroup-ocs-a-must-learn-topic-007.jpeg]]
>
> Google also carried OCS into its TPU infrastructure, where the technology shows up as part of the scaling and resiliency story. The role here is not simply lower-latency optics in the abstract. It is the ability to route around interruptions, maintain large systems more gracefully, and support much larger AI clusters than a more rigid topology would allow. That is what makes Google such a strong proof point for the architecture itself.
>
> That still does not make the merchant story fully proven. What Google establishes is that OCS can solve a real problem at hyperscale. What Coherent and Lumentum still need to establish is product maturity, software integration, manufacturing scale, and repeatable commercial adoption across the merchant market. It is more accurate to think of OCS today as an architecture with real validation and a merchant category that is still taking shape.
>
> The merchant picture remains open. Coherent points to customer engagements, shipping systems, and use cases expanding across scale-out, DCI, and even scale-up. Lumentum is making the more aggressive commercial case, with backlog above $400 million, a multi-year multi-billion-dollar agreement, and a path to a greater than $1 billion 2027 run rate. Those are real demand signals, but they still need to convert into sustained revenue and broader deployment before the category can be called commercially de-risked.
>
> So let's dig in to the company specifics…
>
> ---
>
> ## Coherent
>
> Coherent's OCS story is built around digital liquid crystal, and they are positioning that as a reliability-first alternative to MEMS. The commercial framing has also become more advanced. Coherent originally introduced a 300x300 OCS, but its latest OFC 2026 materials describe 64x64 and 320x320 systems shipping to multiple customers, with 512x512 in development. Coherent also now treats OCS as one of its "new growth engines," with revenue timing labeled "now" and has said it has more than 10 customer engagements, with some customers still evaluating the product and others already in production deployments.
>
> *Coherent OCS product/strategy slide — growth-engine framing and customer engagements*
> ![[cruxcapitalgroup-ocs-a-must-learn-topic-008.png]]
>
> The core of Coherent's pitch is reliability. Its OCS uses liquid crystal rather than moving mirrors, and management has been explicit about why they think that matters. As Jim Anderson put it, "if I have the choice between using a system that uses mechanical moving parts or using a system that doesn't… you're always gonna wanna use the system that has no moving parts in a data center." Coherent also emphasizes that its liquid-crystal cells operate at less than 10 volts, versus much higher voltage in some MEMS-based approaches. They then tie that reliability argument back to telecom and subsea heritage, saying the platform comes out of wavelength-selective switch technology that has already been used in demanding optical environments.
>
> *Coherent reliability pitch — liquid-crystal cell architecture and low-voltage operation*
> ![[cruxcapitalgroup-ocs-a-must-learn-topic-009.png]]
>
> Coherent is also presenting OCS as a broader platform than it was initially. Management has talked about software-defined topology changes to improve GPU and XPU utilization, failover and hot-swap redundancy, and use cases extending beyond the spine into scale-out, DCI, and even scale-up exploration. That broadening use-case set helps explain why Coherent raised its OCS SAM framing from roughly $2 billion to $4 billion by 2030. Their argument is that once customers start working with the capability, they find more places in the network where it can be useful.
>
> One underappreciated part of the Coherent story is that OCS can also pull through more advanced optics. Because the switch adds loss, the network needs stronger link budgets around it. That is why Coherent introduced OCS-optimized transceivers that can absorb an extra 3 dB of insertion loss while still supporting reaches like 2 km and 6 km. So Coherent is not just selling a switch, it is also building the surrounding optical system needed to make that switch practical in real deployments.
>
> ---
>
> ## Lumentum
>
> Lumentum's OCS story is built around MEMS mirrors, low insertion loss, and an aggressive commercial ramp. Its flagship product is the R300, a 300×300 high-radix optical circuit switch, alongside a smaller R64 platform for lower-dimension applications. In its OFC 2026 deck, Lumentum lists OCS as one of its four growth engines and frames it as ramping toward a greater than $1 billion 2027 run rate.
>
> *Lumentum OFC 2026 — OCS as one of four growth engines, >$1B 2027 run rate framing*
> ![[cruxcapitalgroup-ocs-a-must-learn-topic-010.png]]
>
> Lumentum's pitch centers on low loss, high radix, strong MEMS and WSS heritage, real software integration, and early commercial momentum. Management keeps coming back to its telecom history, describing OCS as an extension of decades of WSS MEMS expertise. The OFC deck makes that point directly, calling out "Optical Switching Leadership" built on "Decades of WSS MEMS expertise applied to OCS optical engine." The message is that this is not speculative manufacturing. Lumentum is arguing it has already built and scaled related MEMS optical systems, and that OCS is a natural continuation of that capability.
>
> *Lumentum WSS MEMS heritage — decades of optical-switching expertise applied to OCS*
> ![[cruxcapitalgroup-ocs-a-must-learn-topic-011.png]]
>
> Technically, Lumentum's framing rests on a few core claims: insertion loss below 1.5 dB for the 300×300 switch, a wavelength-agnostic architecture, native high-radix scalability, fixed ultra-low propagation latency, and power consumption well below traditional packet switches. The broader idea is that OCS keeps data optical for longer and reduces some of the power and congestion costs that come with repeated packet switching.
>
> *Lumentum R300 technical claims — <1.5 dB loss, wavelength-agnostic, high-radix, low-power*
> ![[cruxcapitalgroup-ocs-a-must-learn-topic-012.png]]
>
> Lumentum is also presenting OCS as a broader fabric layer rather than a narrow product for one part of the network. Management has described four main use cases: spine replacement and scale-out, optical scale-up, protection and redundancy, and scale-across or DCI. That breadth is important because it shows that they are not pitching OCS as a one-box niche. They are pitching it as a more general optical networking layer for AI infrastructure.
>
> *Lumentum four OCS use cases — spine replacement / scale-out, optical scale-up, protection & redundancy, scale-across / DCI*
> ![[cruxcapitalgroup-ocs-a-must-learn-topic-013.png]]
>
> Commercially, this is where Lumentum stands out most. Lumentum is pointing to backlog above $400 million, with most of that expected to ship in the second half of calendar 2026, alongside a new multi-year multi-billion-dollar OCS agreement and an expected ramp to a greater than $1 billion 2027 run rate. That does not mean the full merchant opportunity is already de-risked, because those claims still need to convert into sustained revenue and broader deployment. But it does mean Lumentum is presenting OCS as a real revenue engine rather than a future option on the roadmap.
>
> *Lumentum OCS commercial slide — $400M+ backlog, multi-year multi-billion agreement, >$1B 2027 run rate*
> ![[cruxcapitalgroup-ocs-a-must-learn-topic-014.png]]
>
> An important part of the Lumentum story is that it is not just selling optics. It is also trying to show that OCS can integrate into real network environments. Management has emphasized a SONiC-based control software stack, gNMI APIs, and interoperability with broader ecosystem tools and controllers. This is important because an optical circuit switch only becomes useful once the network can actually control it, schedule it, and coordinate it with how workloads move across the fabric. Hardware performance alone does not close the sale. The software layer is what makes the hardware deployable.
>
> ---
>
> ## Lumentum vs. Coherent
>
> Lumentum currently looks further along commercially. It has the stronger disclosed backlog, the more aggressive revenue ramp language, and the cleaner public case around low insertion loss and high-radix scale. Coherent still has a credible position, but its argument is different. It is leaning more heavily on reliability, low-voltage liquid-crystal control, software integration, and broader system fit. So Lumentum looks ahead on current merchant traction, while Coherent looks competitive on architecture and reliability. The open question is which tradeoff hyperscalers end up valuing more: the lower-loss MEMS path, or the reliability-first liquid-crystal path.
>
> ---
>
> ## What still needs proving
>
> The OCS story is real, but it is still early, and several things need to go right before the merchant opportunity can be called fully proven.
>
> First is whether backlog turns into durable revenue. Lumentum is making large commercial claims, including backlog above $400 million, a multi-year multi-billion-dollar agreement, and a path to a greater than $1 billion 2027 run rate. Those are meaningful signals, but the real test is sustained shipment conversion over time, and not just strong headline demand at a single point in time.
>
> Second is how broad the customer base becomes. Both stories still look somewhat concentrated. Lumentum's current volume appears to be driven by a small number of major customers, while Coherent is earlier in the ramp even as it points to more than ten engagements and production deployments. The open question is whether OCS becomes a broad merchant category or remains concentrated among a handful of hyperscalers.
>
> Third is whether the use cases actually spread. Both companies now describe OCS as broader than spine replacement alone, extending into scale-up, failover, redundancy, DCI, and scale-across. That expansion is a major part of the bull case. It still has to show up in repeat deployments across different parts of the network, not just in presentations and conference commentary.
>
> Fourth is whether the software and orchestration layer works cleanly in real environments. The hardware is only part of the story. Coherent talks about its software integrating into customer network-management stacks, and Lumentum points to SONiC and gNMI APIs. The real test is whether OCS becomes easy enough to deploy and operate that customers scale it confidently rather than treating each rollout as a custom integration project.
>
> Fifth is which tradeoffs customers end up valuing most. Coherent is betting that reliability and a no-moving-parts architecture carry the most weight. Lumentum is betting that lower loss, high radix, and stronger merchant traction matter more. The market has not finished deciding which of those advantages is more important in practice.
>
> And finally, there is the question of how much of the architecture's value merchants actually capture. Google proves that OCS can work at scale, but that does not automatically mean merchant suppliers capture the same value. The winners still have to prove manufacturability, deployment ease, support, and staying power across multiple customer generations.
>
> ---
>
> *The information provided is for informational purposes only and does not constitute investment advice, a recommendation, or an offer to buy or sell any securities. The author holds positions in securities mentioned. Readers should conduct their own due diligence and consult with a financial advisor before making investment decisions.*
