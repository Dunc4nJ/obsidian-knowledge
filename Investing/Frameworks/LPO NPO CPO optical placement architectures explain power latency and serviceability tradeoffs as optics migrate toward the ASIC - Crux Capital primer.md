---
created: 2026-05-13
published: 2026-04-05
description: Foundational walk-through of four optical interconnect architectures — traditional pluggable, LPO, NPO, CPO — framed as a single physics-driven progression: move the optics closer to the ASIC to cut power, heat, and latency, accepting worse serviceability as the price.
source: https://cruxcapitalgroup.substack.com/p/education-lpo-npo-cpo
type: framework
authors: ["Crux Capital Group (@cruxcapitalgroup)"]
---

## Key Takeaways

- The four architectures (Traditional Pluggable → LPO → NPO → CPO) are not competing platforms — they're a single ordered progression in one variable: distance between the ASIC and the electrical-to-optical conversion. Every other tradeoff (power, latency, heat, serviceability, vendor mix) is downstream of that one axis. Once you internalize that framing, you don't have to memorize four feature lists — you just ask "how close are the optics, and what breaks at that distance?"
- LPO is the only "free lunch" in the stack — it removes the DSP from inside a pluggable module without changing form factor. Same socket, same servicing model, but module power drops materially (the DSP is among the biggest consumers in a high-speed optical module) and latency improves. The catch: the host system has to be cleaner because the module is no longer compensating for it. That's why LPO is hyperscaler-first — they control the link environment and can meet the cleanliness bar.
- CPO's bull case is overstated by headlines, and Crux says it explicitly: "powerful in theory and increasingly real in practice, while also being harder across almost every dimension." Thermals, manufacturing, test, and repair all get worse. A failed pluggable is a swap; a failed CPO module is a board-level event. The investable read: CPO is a long-duration shift, not a 1-2 year story. NPO is the pragmatic bridge — closer to the ASIC than pluggables, no co-packaging risk.
- The value-migration thesis is the investor-relevant frame. As optics move toward the ASIC: value drains out of the module-only ecosystem (traditional pluggables) and concentrates in silicon photonics, laser sources, advanced packaging, test, and system integration. ELS (external laser source) is called out as a recurring CPO concept — keeping the temperature-sensitive laser outside the hot package while pulling other optical functions inward. This is structurally bullish for laser/light-source IP and packaging/test names tied to optical co-integration (the [[Lumentum (LITE)]], [[Coherent (COHR)]], advanced-packaging house complex), and structurally neutral-to-bearish for module-only commodity vendors as architectures shift.
- The "tail latency" theme repeats from [[Photonics solves AI datacenter bandwidth power heat latency and distance bottlenecks copper cannot - Crux Capital primer|the prior Crux primer]] — synchronous AI training is gated by the slowest link, and DSP cleanup adds latency on every hop. LPO/NPO/CPO are all latency-positive vs traditional pluggables; that compounds with their power story to explain why hyperscalers will subsidize bleeding-edge optical adoption ahead of cost parity.

## External Resources

- [Photonics 101](https://cruxcapitalgroup.substack.com/p/photonics-101) — companion foundational piece referenced in opening, defines pluggable / optical-engine terminology used throughout this note.
- [[Photonics solves AI datacenter bandwidth power heat latency and distance bottlenecks copper cannot - Crux Capital primer]] — Crux's "why photonics" prerequisite that this architecture primer builds on.

## Original Content

> [!quote]- Source Material
> Crux Capital Group (@cruxcapitalgroup) — 2026-04-05
> "Education: LPO, NPO, CPO"
>
> If you have been following my work then you should have a good idea of why Optics is necessary for continue AI growth.
>
> If you need a good foundational building block, please read this:
>
> [Photonics 101](https://cruxcapitalgroup.substack.com/p/photonics-101) — Gaetano · Mar 23
>
> Today we are focusing on the different architectural possibilities. Optics turn electrical signals into light, send that light through fiber, and convert it back again. Light handles distance and speed far better than copper. The real design question is where the optics should sit.
>
> That is what these four architectures are really about. Traditional pluggables keep the optics farther away from the chip. LPO keeps the pluggable shape but simplifies what is inside it. NPO moves the optics much closer to the chip. CPO brings them into the same package as the chip itself. The optics are getting closer and closer, and everything else follows from that.
>
> Let's learn the foundation of these architectures.
>
> ---
>
> **Traditional pluggable optics**
>
> This is still the dominant architecture today.

*Crux's Traditional Pluggable Optics diagram — ASIC on the board with a long electrical trace running across the PCB to a removable Pluggable Optics module at the front of the Compute/Switch box. The long electrical path is what creates the loss, heat, and signal-quality problems Crux discusses in the surrounding text.*
![[cruxcapitalgroup-education-lpo-npo-cpo-001.png]]

> A traditional pluggable optic is a removable module that slides into the front of a switch. Its job is to take an electrical signal from the switch, turn it into light, and send it over fiber. If something breaks, you pull the module out and replace it. If a faster generation arrives, you can often upgrade the module without rebuilding the full system. That service model is one of the primary reasons pluggables remain so important and the ecosystem behind them is deep, and operational familiarity runs wide. Common module formats like QSFP-DD and OSFP are just the physical shapes and standards the industry has converged around.
>
> The limitation is that the main switching chip, the ASIC, or application-specific integrated circuit that actually handles the traffic sits farther away from the module. The electrical signal has to travel across the board before it ever reaches the optics, and that longer path creates loss, heat, and signal quality problems. To manage that, traditional pluggable modules typically include a DSP, or digital signal processor, which acts as a signal cleanup chip that repairs and retimes the signal before it goes optical. That makes the module easier to deploy across a wide range of environments, but it also adds power, heat, cost, and latency.
>
> The tradeoff is that traditional pluggables are flexible, easy to replace, and supported by a broad ecosystem, with the power efficiency penalty coming from the optics being physically farther from the main chip.
>
> ---
>
> **LPO: linear pluggable optics**
>
> LPO keeps the pluggable module but changes what is inside it.

*Crux's LPO diagram — visually the same outer pluggable-form-factor view as the traditional diagram above (Crux reused the image, byte-identical to image 001). The point being made: LPO keeps the same physical socket, ecosystem, and servicing model; only the internals change.*
![[cruxcapitalgroup-education-lpo-npo-cpo-002.png]]

> In a traditional pluggable, the module carries a significant share of its own signal-processing burden. LPO pulls a lot of that out. The DSP is removed or reduced, and more of the signal handling gets pushed back into the host system which is the switch or server the module plugs into. The signal path becomes simpler, which is where the name comes from.
>
> The easiest way to think about LPO is as a leaner pluggable. The DSP is one of the biggest power consumers inside a high-speed optical module, so removing it can bring module power down substantially. Latency improves too, which has real consequences in AI clusters where thousands of chips need to stay in tight synchronization.
>
> The tradeoff is that because the module is doing less cleanup on its own, the system around it has to be better behaved. The host chip has to be stronger, the link has to be cleaner, and the deployment has to be more controlled. LPO performs best in shorter-reach, tightly managed environments, particularly inside AI data centers where those conditions can be met. Think of it as a practical power-saving step rather than a wholesale replacement for traditional pluggables. You keep the form factor and most of the serviceability, while asking more from the surrounding system.
>
> ---
>
> **NPO: near-packaged optics**
>
> NPO is the next step closer to the chip.

*"LPO Solution (without DSP)" — the internals view Crux placed in the NPO section. Two switches on either side of a fiber link; the optical module retains only Driver+CTLE/TIA+EQ (no DSP). Despite its title labeling it LPO, Crux uses this diagram to introduce the idea of the optical engine moving closer to / simplifying around the ASIC, which is the conceptual bridge into NPO.*
![[cruxcapitalgroup-education-lpo-npo-cpo-003.png]]

> With NPO, the optics move away from the removable front-panel module entirely. The optical engine (the small assembly that handles the electrical-to-light conversion) gets placed much closer to the switch chip, usually onto the same board only a short distance away. Instead of the signal traveling a long way across the board before reaching optics, it covers a much shorter path. That improves power efficiency, helps with signal quality, and increases bandwidth density, meaning more data packed into less physical space.
>
> NPO captures some of the physical benefits of moving closer to the chip without going all the way to full co-packaging. The serviceability picture changes substantially though. A pluggable can be pulled out and replaced in the field, while NPO units are mounted much more tightly into the system and require more involved repair when something fails. Ecosystem maturity is also earlier where pluggables have years of standards, vendors, and operational history behind them, and NPO terminology is still used inconsistently across the industry. But basically NPO places the optics very close to the main chip but on a separate package.
>
> That in-between position is what makes NPO worth understanding. Less straightforward than pluggables, less aggressive than CPO, but occupying a position in the middle.
>
> ---
>
> **CPO: co-packaged optics**
>
> CPO is the most integrated version of this whole trend.

*Crux's "Near-package Optics (NPO)" labelled diagram, placed in the CPO section — shows the NPO physical layout with the optical engine moved adjacent to the ASIC on an HDI Interposer, with a short electrical path before hitting fiber. Used here as the visual stepping-stone Crux uses to describe how CPO goes one step further and brings the optics into the same package as the ASIC.*
![[cruxcapitalgroup-education-lpo-npo-cpo-004.png]]

> With CPO, the optics move into the same package as the main chip. The electrical signal only has to travel a very small distance before being converted into light, and less electrical distance means less wasted power, less signal loss, lower latency, and more headroom to push bandwidth higher. That is why CPO draws so much attention in AI networking as it is designed for a world where moving data between chips becomes one of the primary constraints in the whole system.
>
> One term that comes up in CPO discussions is external laser source, or ELS. That refers to keeping the laser itself outside the hot package while other optical functions move closer to the chip. The reason is straightforward in that lasers and optical components are temperature-sensitive, and co-locating them with very hot compute chips creates real engineering challenges.
>
> Which brings the candid framing for CPO into focus. It is powerful in theory and increasingly real in practice, while also being harder across almost every dimension. Thermals are harder. Manufacturing is harder. Testing is harder. Repair is harder. If a pluggable module fails, you swap it out. Inside a co-packaged optical system, failures carry far more serious consequences. CPO is strategically significant, physically logical, and operationally demanding, and that combination of attributes shapes the timeline in ways the headlines sometimes understate.
>
> ---
>
> **The progression**
>
> The easiest way to picture all of this is to imagine shortening the road between two busy cities.
>
> Traditional pluggables keep the optics farther away, so the electrical signal has a longer road to travel before it becomes light. LPO keeps the same road but makes the vehicle lighter and more efficient. NPO moves the destination much closer. CPO puts it right next door.
>
> The direction of travel is consistent because the underlying physics keeps pushing it that way. As speeds rise, the cost of long electrical paths keeps going up, and every architecture in this progression is a response to that pressure.
>
> ---
>
> **Why you as an investor should care**
>
> This changes the economics of the whole stack.
>
> If optics move closer to the chip, power consumption can fall, heat can fall, and more bandwidth can fit into the same system. Maintenance gets harder though, repair costs can rise, and the winners in the supply chain can shift. Traditional pluggables keep a lot of value in the module ecosystem. LPO can reward companies building lower-power pluggable solutions. NPO and CPO can shift more value toward silicon photonics, lasers, packaging, test, and system-level integration.
>
> The more useful question for us is where the value moves if the architecture changes, rather than which architecture is best in isolation.
>
> ---
>
> **What to watch right now**
>
> Pluggables still carry a lot of weight. They are the easiest thing to deploy, replace, and source at scale, and that advantage erodes slowly. LPO is a real and practical step for certain short-reach, power-sensitive environments and is already somewhat being adopted by hyperscalers. NPO is an important bridge architecture worth following, or at least understanding even if deployment is minimal relative to CPO. CPO carries significant long-run strategic weight, especially for demanding AI systems, though it is earlier and more complex than the headlines sometimes suggest.
