---
created: 2026-05-13
published: 2026-04-06
description: SEK 304M-revenue Swedish small-cap with two engines — Photonics (Glasgow InP100 multi-wavelength CW DFB laser arrays placed inside Ayar SuperNova, Jabil 1.6T pluggables, POET, O-Net, WIN) and Wireless (mmWave/SATCOM/defense) — credible 2027 CPO laser-ramp story but commercial conversion still unproven.
source: https://cruxcapitalgroup.substack.com/p/sive-deep-dive
type: thesis
authors: ["Crux Capital Group (@cruxcapitalgroup)"]
---

# Sivers (SIVE.ST) deep dive — 290M cap InP laser array supplier inside Ayar SuperNova and Jabil 1.6T pluggables, 2027 timeline to CPO revenue

## Key Takeaways

- **Size and shape.** SEK 304M (~USD 30M) FY2025 revenue, ~USD 290M market cap, two operating units: Sivers Photonics (Glasgow, in-house 4-inch InP fab) and Sivers Wireless (Sweden, fabless on GlobalFoundries 45nm RF-SOI). The market is mostly trading the photonics narrative; the author argues wireless is "more developed than the market may care to acknowledge."
- **Photonics tech anchor.** InP100 platform produces FP/DFB lasers, SOAs, RSOAs, and detector chips. The strategic product is the **multi-wavelength O-band CW DFB laser array** — 8λ today (>50mW/channel, 400GHz spacing around 1300nm, 20-70°C, non-hermetic, GR468 qualified), with 16λ (200±50GHz, >40dB SMSR, ±25GHz tunability at ~15mW) and 32λ in the roadmap.
- **Ecosystem placement is real.** Sivers' 8λ array is in [[Ayar Labs]] SuperNova multi-port light source (ASP per Crux: **USD 50-100/array**). Jabil's 1.6T DR8 LRO pluggable demoed at OFC 2025 on Intel silicon photonics had a sign on the booth identifying Sivers as powering the 1.6T optical transceiver. O-Net (OEM/ODM for ELS modules) and Enablence (star coupler) round out the three-way ELS architecture; POET adds a second ELS route via the Optical Interposer. WIN Semiconductors is the manufacturing scale-out path beyond Glasgow.
- **CW-WDM MSA founder.** Sivers is a founding member of the CW-WDM MSA — standards group for 8/16/32-wavelength CW sources in O-band — alongside Arista, Ayar, imec, Intel, Lumentum, Luminous, Quintessent, Sumitomo Electric, II-VI, and MACOM. Places Sivers *inside* the ecosystem standards rather than outside.
- **Wireless second engine.** mmWave/SATCOM/FWA/defense, spanning 24-71 GHz + Ka-band. Named programs: **ALL.SPACE** (TRL 6 with U.S. Army, also U.S. Navy), Thorium, Tachyon (entering production), Doosan, CHIPS Act electronic-warfare work (year-2 contract ~20% higher than prior year), plus Raytheon/Ericsson defense ties. Cloudchaser (Ka beamforming chipset), Maverick (antenna panel), Daybreak (FR3) are the SKUs. Tier-1 telecom infra customer with Gen-1/Gen-2 products targeted by year-end.
- **Financials.** FY25: SEK 304.1M revenue (product = SEK 85.7M; balance is NRE/development). Q4 adjEBITDA SEK 10.8M positive; full-year adjEBITDA +31% YoY. USD 17M refinancing replaces ~USD 11.5M of loans + USD 12M fixed convertible at significant premium = stronger 3-year bridge.
- **Management framework.** Cash-flow breakeven at USD 50-55M revenue with 65% product mix in ~2 years. Long-term targets: 25-30% growth, 65% GM, R&D ~20% of revenue, EBITDA margin ~30%. Total opportunity pipeline reached **USD 453M** entering 2026; product pipeline grew **90% in 2025**. LiDAR customer ramp begins Q4 2026; **2027 framed as the year CPO laser opportunities can begin contributing revenue**.
- **Scenario framework (FY28 model).** Bear: SEK 425M revenue × 4.5x → SEK 1.9B → ~SEK 6.4/share. Base: SEK 700M × 6.5x → SEK 4.6B → ~SEK 15.3/share. Bull: SEK 950M × 8.5x → SEK 8.1B → ~SEK 27.2/share.
- **Author position.** Does not own (only invests in names accessible via normal US brokerage; SIVE.ST is Stockholm-listed, SIVB is OTC but author doesn't use OTC). Frames piece as deliberately grounding bull narrative — "I do not want to write a piece where the bull case becomes the base case."
- **What's still missing.** Array-by-array commercial readiness data (linewidth, RIN, customer-by-customer qualification status, production-yield numbers, manufacturing-transfer pace from Glasgow to WIN). Conversion of the USD 453M pipeline into recurring product revenue. The transition from one-to-one custom NRE to one-to-many standard products.

## Key visuals

*The Sivers Opportunity overview — 2 secular trends (AI / mmWave) × 2 momentum markets, USD 2B+ SAM by 2028, "$100M+ business in 4 years" framing.*
![[cruxcapitalgroup-sive-deep-dive-001.png]]

*Sivers' positioning in the Ayar Labs SuperNova multi-port multi-wavelength light source, with the Sivers 8λ O-band CW DFB array at ASP USD 50-100. The Ayar TeraPHY CMOS Optical I/O chiplets sit at the GPU/CPU/FPGA socket and route data through 8 wavelengths into a fiber array.*
![[cruxcapitalgroup-sive-deep-dive-012.webp]]

*Jabil booth signage at OFC 2025: "SIVERS POWERING THE 1.6T OPTICAL TRANSCEIVER — 1.6T / DR8 / 70mW CW DFB Laser / LRO."*
![[cruxcapitalgroup-sive-deep-dive-016.webp]]

## Original Content

Sivers Semiconductors ($SIVE) is one of the more interesting smaller names in this part of the market right now. I have received more requests on $SIVE than any other company in this sector.

For a while, it mostly sat on the edge of the conversation. People who followed the optical stack knew the company had real relevance through relationships like Ayar and POET, but it was still viewed as a smaller, earlier-stage player without the same weight as the larger laser and optical names. That changed recently. The stock has picked up a lot of traction on X, the share price has moved sharply, and investor interest has ramped alongside a much louder discussion around what Sivers could become.

I think some of that excitement is justified. This is a company with real technology, partnerships, and optionality. At the same time, I also think parts of the conversation have run too far ahead of the current facts. Comparisons to the largest and most established players in this space can get sloppy very quickly. Sivers may have relevance in the same ecosystem, but relevance and maturity are two very different things. This is still a company doing roughly SEK 304 million, or about USD 30 million, of annual revenue, and even management's own projections are much more measured than some of the outcomes being projected across social media.

That is why I wanted this report to stay grounded in reality. I do not want to write a piece where the bull case becomes the base case. I want to understand what is already real, what is still developmental, what management is actually saying, and what would need to happen from here for the story to justify the current excitement.

I also want to be clear that I do not own a position. That is not because I do not see value in the company. It is because Sivers is listed on the Swedish exchange, and I choose to invest in companies I can access easily through my normal brokerage setup. There is an OTC listing as well, but I do not invest through those either.

The market is always looking for the next optical name that is still small enough to be overlooked and still real enough to matter. I think Sivers could fit that description at the right price if management executes. This report is my attempt to lay out exactly what I am seeing.

*As a reminder, none of this is financial advice and this is solely for educational purposes. Do your own diligence.*

---

### 1. Executive Summary

Sivers Semiconductors is a small semiconductor company with two operating businesses, Sivers Photonics and Sivers Wireless. That combination makes the name interesting. Photonics gives the company exposure to optical interconnects, LiDAR, and sensing. Wireless gives it exposure to mmWave, SATCOM, telecom, and defense. Together, they give Sivers more breadth than the market conversation often gives it credit for.

![[cruxcapitalgroup-sive-deep-dive-001.png]]

The real underwriting question for me is whether the company can convert that platform relevance into broader commercial proof. That is the lens for the whole report.

---

### 2. What Sivers Is

Sivers is listed in Sweden and is best understood as these two different businesses under one ticker. Sivers Photonics and Sivers Wireless share a parent company, but they do not share the same products, customer base, manufacturing model, or commercial timeline. It's important to remember that the stock is really a combination of two different bets.

![[cruxcapitalgroup-sive-deep-dive-002.webp]]

The data center photonics side is the part of the story drawing the most investor attention. Sivers Photonics is based in Glasgow and designs and manufactures indium phosphide laser diodes, laser arrays, semiconductor optical amplifiers, and detector chips. It runs its own 4-inch, or 100 mm, indium phosphide wafer facility, and its core platform is called InP100. This is the part of the company tied to optical interconnects and the broader AI optics discussion.

![[cruxcapitalgroup-sive-deep-dive-003.webp]]

That said, photonics here should not be understood as only a datacenter-optics story. The same underlying III-V platform also reaches into sensing and LiDAR. Sivers has disclosed an established U.S. Fortune 100 customer relationship in advanced optical sensing, with multiple laser-device orders and a development relationship that already spans more than five years and more than USD 17 million of investment. Sivers has also framed the platform around biometric sensing applications. More recently, it said its strategic LiDAR customer has incorporated Sivers technology across platforms and is expected to begin production ramp in Q4 2026 for automotive and industrial programs. So the photonics bucket is really three things at once: datacenter optics, sensing, and LiDAR.

The wireless side is a separate business with a different operating model and different end markets. Sivers Wireless is based in Sweden and focuses on RF beamformer ICs, transceivers, and antenna-related products across millimeter-wave and Ka-band SATCOM applications. Unlike photonics, it is fabless and relies on GlobalFoundries for wafer fabrication. Wireless here is tied to satellite communications, telecom infrastructure, fixed wireless access, and defense modernization rather than to optical interconnects.

![[cruxcapitalgroup-sive-deep-dive-004.webp]]

This side of the company is also more developed than the market may care to acknowledge. Management has pointed to named programs and customers including ALL.SPACE, Thorium, Tachyon, Doosan, and CHIPS Act and defense work tied to players like Raytheon and Ericsson. So while photonics carries the bigger thematic upside in the eyes of the market, wireless gives Sivers a second commercial engine and a broader operating base.

That structure is why the stock can easily be misread. Sivers is not a simple pure-play photonics company, and it is not just a wireless name with some optical optionality on the side. It is a combined company where the two segments matter for different reasons, move on different timelines, and likely deserve different investor expectations.

---

### 3. The Optics Exposure

As more data has to move across chips, boards, racks, and clusters, electrical links run into tougher limits around power, heat, and signal integrity. That creates room for photonic systems, where light carries the data instead. In that world, Sivers is trying to supply the laser layer that helps make those systems work.

![[cruxcapitalgroup-sive-deep-dive-005.webp]]

That is where Sivers Photonics enters the picture. Its indium phosphide devices, especially DFB lasers and laser arrays, fit naturally into silicon-photonics-style architectures. In those systems, the silicon photonics chip typically handles routing and modulation, while a separate laser source supplies the light. That makes the laser a distinct and important layer in the stack, and Sivers is trying to participate in that layer.

![[cruxcapitalgroup-sive-deep-dive-006.webp]]

There are really two optical buckets to think about. The first is the longer-dated optical I/O, external-light-source, and future CPO path. In many of those systems, the photonic engine handles signal transport while a separate laser source provides multiple wavelengths of continuous-wave light. Sivers' 8-wavelength O-band CW DFB array fits directly into that role, and they have already shown that array inside [[Ayar Labs]]' optical I/O light-source setup.

The second bucket is nearer term. On the latest call, management said pluggables have become a very attractive opportunity, that the qualified-opportunity list there is growing, and that Sivers is already sampling its lasers at multiple customers. Management also said that beyond Ayar, O-Net, POET, and the earlier ecosystem, larger household-name companies are now entering discussions around future photonics roadmaps. This broadens the commercial picture. Sivers is still strongly associated with future optical I/O and CPO, but the path to revenue may also run through faster pluggables and other nearer-term optical products that use the same underlying laser capability.

The CW-WDM MSA helps tie this together. Multi-wavelength continuous-wave laser sources need common wavelength grids and system assumptions if they are going to fit into a broader ecosystem. Sivers' role as a founding member places it inside that standards-based environment rather than outside it. Sivers is trying to become a relevant supplier of the multi-wavelength laser layer across a broader optical transition, where the same core technology can matter in pluggables today and in more advanced external-light-source or CPO-style systems over time.

*[Image — Crux's screenshot of the CW-WDM MSA explainer; transcribed verbatim below]*

> The CW-WDM MSA (Continuous-Wave Wavelength Division Multiplexing Multi-Source Agreement) was formed to standardise WDM CW sources in O-band for emerging advanced Silicon Photonics (SiPh) based optics applications that are expected to move to 8, 16, and 32 wavelengths, to support high data rate advanced optical communication and computing applications.
>
> CW lasers are critical to the integrated photonics devices used in next-generation artificial intelligence and data-centre applications and Sivers Photonics is helping to spearhead the standardisation, along with industry leaders and household names, **Arista, [[Ayar Labs]], imec, Intel, [[Lumentum (LITE)]], Luminous Computing, Quintessent, Sumitomo Electric, II-VI and MACOM**.

That said, the photonics story here is still broader than datacenter interconnects alone. The same underlying platform also gives Sivers exposure to LiDAR and advanced optical sensing, which is one reason the business should not be framed as a single-outcome AI optics bet. The datacenter side is what gives the company the most strategic relevance to the current market discussion, but it is not the only place the platform can matter.

---

### 4. Sivers Photonics: Platform and Product Family

Sivers Photonics is built around InP100, a 100 mm, or 4-inch, indium phosphide platform. This is the manufacturing base behind the company's laser and detector products, including FP lasers, DFB lasers, semiconductor optical amplifiers, reflective SOAs, and detector devices. For the AI-optics story, the important point is that this platform is designed to connect III-V lasers into silicon photonics systems.

The platform uses etched facets, alignment features, solder structures, and on-wafer optical coatings to support precise bonding, and it targets passive alignment to silicon and silicon nitride waveguides. Essentially, Sivers is building lasers in a form that can be attached to a photonic chip with high precision and lower packaging complexity.

The product family that matters most for AI interconnects is the multi-wavelength O-band CW DFB laser array. The clearest current product is the 8-wavelength version designed for CW-WDM applications. One component can supply light for several channels at the same time, which is useful in dense optical engines where a system wants several clean wavelengths from one source. O-band operation around 1300 nm places the array in a datacom-relevant wavelength band, and the 400 GHz spacing means the wavelengths sit on a defined grid that fits standardized multi-wavelength system designs.

The other published characteristics are insightful as well. Greater than 50 mW of continuous-wave power per channel means the array is delivering enough optical output to function as a real system light source. The 20°C to 70°C operating range gives it a practical temperature window rather than a narrow lab-only one. Suitability for non-hermetic applications also matters because it points toward packaging approaches that can be simpler and lower cost than fully sealed hermetic designs.

Dense arrays are more demanding than single lasers in ways that matter for real-world use. Every channel has to work at the same time. Each wavelength has to stay accurately placed on the grid, remain spectrally clean enough to stay separated from neighboring channels, hold up as temperature changes, and couple efficiently into the rest of the optical system. As wavelength count rises, yield becomes harder too, because one weak channel can reduce the value of the whole array. That is why Sivers' progress in channel count, spacing, SMSR, tuning, and silicon-photonics integration deserves attention.

![[cruxcapitalgroup-sive-deep-dive-008.webp]]

The family also extends beyond the 8-channel version. Sivers has framed the same architecture around 16-wavelength and 32-wavelength directions, with grid spacings of 400, 200, and 100 GHz. More wavelengths let one source feed more optical channels, while tighter spacing lets those channels sit closer together as optical systems get denser.

![[cruxcapitalgroup-sive-deep-dive-009.webp]]

The 16-element work gives a good picture of where the platform is heading. A 200 ± 50 GHz channel-spacing target points toward higher wavelength density. Greater than 40 dB SMSR per channel suggests each wavelength remains clean and distinct, with limited unwanted spectral leakage into nearby channels. Sivers also describes ±25 GHz of tunability, with about 15 mW of electrical power required for a 25 GHz tuning shift and less than 15% added total power load from that function. Tuning gives the array a way to adjust wavelength placement inside the system without imposing an overwhelming power penalty.

![[cruxcapitalgroup-sive-deep-dive-010.webp]]

There is also a useful integration example with imec and ASM Amicra. In that work, Sivers presented bonded indium phosphide dies, including single DFB lasers around 1550 nm, optical power up to 40 mW coupled into a silicon nitride waveguide, sub-0.3 micron laser-assisted flip-chip bonding precision, and coupling efficiency of 1.5 ± 0.5 dB. It also referenced 4-channel and 8-channel O-band RSOA arrays with 200 GHz spacing moving through flip-chip bonding work. That is a concrete example of the broader goal: combining the performance of III-V lasers with the packaging flow used in silicon photonics systems.

So the technical picture is already meaningful. Sivers has a real platform and a real laser-array family with clear relevance to the optical-interconnect stack. The next questions sit around product maturity, qualification depth, integration status by configuration, and how far the family has advanced toward broader commercial use.

---

### 5. Qualification and Manufacturing Readiness

This is where the Sivers story becomes more demanding. The starting point is fairly clear. Sivers appears to have a real manufacturing base. InP100 is presented as a qualified platform with 100 mm wafer processing, automated test, singulation and inspection, in-house reliability work, and a broader operating history in laser production. That gives them process credibility.

![[cruxcapitalgroup-sive-deep-dive-011.png]]

But platform credibility and product-by-product commercial readiness are not the same thing. That is the main distinction investors need to keep in mind. The public record is much stronger on the former than on the latter.

What is still missing publicly is a cleaner array-by-array picture. We still do not have a full public read on which configurations are still being evaluated, which are qualified with customers, which are in recurring production flow, what current yield looks like for the marketed arrays, and how far manufacturing transfer has progressed as volumes rise. Those are the details that matter once a company moves toward being a real production supplier.

Management still frames 2027 as the year when these laser opportunities can begin contributing meaningful revenue, while making clear that qualification work and product-readiness work are happening now and into year-end. That is a sensible place to put them on the maturity curve. It suggests a business that has moved well beyond concept-stage work and is advancing toward commercial readiness, while still leaving meaningful work ahead before investors can treat the CPO-relevant array story as fully production-proven.

Sivers appears credible as a manufacturing and qualification story, but the public evidence remains stronger on platform readiness than on fully documented, array-specific, large-scale commercial readiness.

---

### 6. Partnerships

Partnerships show where Sivers sits inside the optical stack. A partner announcement can prove technical relevance, system fit, module placement, or manufacturing intent. Commercial scale is a separate question. I think the right way to read the partnership set is as a map of where Sivers' laser technology is being placed inside real architectures.

[[Ayar Labs]] is, in my opinion, the most important relationship in the public record. Sivers' materials place its laser array inside Ayar's SuperNova multi-wavelength optical source, presented as part of Ayar's optical I/O architecture. That gives Sivers direct technical placement inside one of the best-known optical I/O efforts in the market.

![[cruxcapitalgroup-sive-deep-dive-012.webp]]

O-Net and Enablence are best understood as part of the same module pathway. O-Net serves as the OEM and ODM for ELS modules that integrate Sivers' laser arrays. Enablence provides the star coupler used inside the three-way ELS module. Together, they show how Sivers' arrays can sit inside a fuller module architecture rather than remaining only at the stand-alone die level.

*[Image — PR Newswire headline screenshot; transcribed verbatim below]*

> **Sivers Semiconductors, O-Net and Enablence Technologies Announce External Light Sources for AI Datacenters**
> PR Newswire — March 17, 2026 · 3 min read

[[POET Technologies (POET)]] gives Sivers another route into the external-light-source layer. The current framing is that Sivers' DFB lasers can be combined with POET's Optical Interposer platform for ELS modules aimed at both pluggable transceivers and CPO. That is strategically useful because it broadens the number of system configurations where Sivers' lasers could play.

*[Image — Sivers + POET partnership announcement card; transcribed verbatim below]*

> **Sivers Semiconductors Partners With POET Technologies to Deliver Innovative Light-Engines And Strengthen Serviceable Market Offerings in Next-Gen AI Infrastructure**

WIN Semiconductors is the clearest manufacturing-scale partnership in the set. Glasgow gives Sivers a real design and process base. WIN gives it a route toward higher-volume fabrication without requiring Sivers to build a much larger internal fab on its own. The jump from an in-house process platform to a broader commercial supply role usually depends on exactly this kind of partner.

*[Image — Sivers + WIN announcement screenshot; transcribed verbatim below]*

> **Sivers Semiconductors Announces Collaboration with WIN Semiconductors to Scale High-Volume DFB Laser Production**
> March 25, 2025 | Category: Non Regulatory

Jabil is also worth noting as a newer ecosystem datapoint. Jabil officially launched and demoed a 1.6T pluggable transceiver at OFC 2025, built on an Intel silicon photonics engine for AI and intra-data-center connectivity. A sign displayed with that module identified Sivers as powering the 1.6T optical transceiver, which places Sivers' CW DFB laser technology inside a real pluggable-module path as well.

![[cruxcapitalgroup-sive-deep-dive-016.webp]]

So taken together, Ayar gives Sivers its strongest public technical placement in optical I/O. O-Net and Enablence connect it to the module layer. POET adds another external-light-source pathway. WIN provides the manufacturing bridge any serious laser-array supplier eventually needs. Jabil adds a useful pluggables datapoint. Management has also said that beyond these younger ecosystem names, larger established companies are now entering discussions around future photonics roadmaps.

That does not by itself settle the commercial question. But it does show that Sivers is not an isolated lab story. It has real ecosystem placement, real system relevance, and real architecture-level visibility.

---

### 7. How the Business Model Works

At this stage, Sivers earns revenue from several layers at once. They are still monetizing engineering capability while trying to build toward a more scalable product model. Today, that means a mix of customer-funded development, custom work, foundry-style activity, and early product revenue. Over time, management is trying to shift that mix toward more recurring and durable product sales.

On the photonics side, the model has three economic layers. The first is platform monetization through InP100 foundry work and development programs, where customers use Sivers' indium phosphide process base for custom devices and engineering work. The second is single-device or bare-die sales, which fit more naturally into telecom, sensing, and pluggable-type applications. The third is the multi-wavelength array opportunity, which is the most strategically interesting layer for AI interconnects. In that setup, Sivers is effectively trying to sell the laser-array layer to other companies that build the rest of the optical system around it.

That distinction becomes clearer when compared with [[Lumentum (LITE)]]. Lumentum is pursuing a more complete external-light-source path. Its UHP, SHP, and ELSFP-350 products show a company moving from the laser chip into the packaged light source that can be used more directly inside a CPO system. Sivers looks different. Its center of gravity is the InP platform plus the multi-wavelength array family, which points to a company trying to win the array layer inside broader partner ecosystems.

That has economic implications. A more complete module path can support higher content per socket because the supplier is capturing more of the finished product. An array-supplier path can carry lower content per unit, but it can also fit into more than one architecture and sell into a broader set of partners. So the Sivers growth case is not really "become Lumentum." It is "become an important supplier of the multi-wavelength laser arrays that other optical systems depend on."

That also helps explain why a customer might choose Sivers even if more vertically complete alternatives exist. A company building its own optical engine or module may prefer to source the laser array and integrate the rest itself. In that setup, Sivers becomes useful because it is supplying the array layer rather than the whole finished light-source package.

Management's own pipeline framework helps explain how this model is supposed to scale from here. Opportunities move through four broad stages: qualified opportunities, evaluation or development work, design-win or plan-for-production status, and then production. The timeline can be long. Management described roughly 3 to 9 months to qualify an opportunity, 18 to 36 months for custom-product development, and another 9 to 12 months for qualification runs and field trials before full production. That is why the business can look commercially early for a long time even when the underlying opportunity is real.

That timing is also why the shift toward standard products matters so much. Management now says it is becoming much more selective about one-off custom projects and is increasingly trying to move toward products that can serve more than one customer. That is a move from one-to-one development work toward one-to-many product sales. If it works, it should shorten the path to production, widen the customer base, and improve scalability.

The pipeline gives some evidence that this transition is real at the intent level. Total opportunity pipeline reached USD 453 million entering 2026, while product pipeline grew 90% during 2025. That is one of the clearest signs that management is trying to shift the company away from pure engineering revenue and toward repeatable product revenue.

There is also some directional pricing color. One slide tied to the Ayar optical I/O setup points to an ASP of USD 50 to USD 100 per array. That should be treated as directional rather than as a full company-wide pricing framework, but it helps show why investors should care more about multi-wavelength arrays than about lower-content single-device sales.

So the business model today is still transitional. The present-tense version is a mix of development work, platform monetization, and early product revenue. The future version management is aiming for is much more product-led, with standard products, recurring shipments, and broader customer adoption carrying more of the model.

---

### 8. The Wireless Business

Sivers Wireless gives the company a second engine, and it deserves more attention than it usually gets. This business spans mmWave, SATCOM, telecom infrastructure, fixed wireless access, and defense-related connectivity, with products covering 24 GHz to 71 GHz plus Ka-band SATCOM. The operating model is also different from photonics. Wireless is fabless, with production handled through GlobalFoundries on 45nm RF-SOI, which gives Sivers a separate path to scale and a different commercialization timeline.

![[cruxcapitalgroup-sive-deep-dive-017.webp]]

The product set is broad. Sivers sells RFICs, beamforming ICs, integrated RF modules, software, and evaluation kits. Cloudchaser and Maverick are the clearest near-term anchors in SATCOM. Cloudchaser is the Ka-band beamforming chipset, while Maverick is the antenna-array panel built around it. Daybreak adds another layer through the newer FR3 beamforming work tied to the CHIPS Act program.

There is also real customer and program traction here. ALL.SPACE reached TRL 6 with the U.S. Army, which moves that platform closer to broader deployment. Tachyon is entering production. Thorium gives Sivers another SATCOM path, while Doosan adds a Korea-focused antenna-panel development route. Management also said the year-two CHIPS Act contract for electronic warfare is expected to come in about 20% higher than the prior year. Beyond those named programs, the company has also pointed to a Tier-1 telecom infrastructure vendor working on Gen 1 and Gen 2 products it wants to bring out by year-end, plus a growing set of opportunities across SATCOM, fixed wireless, and defense.

That forward path is what makes the wireless side more interesting than a simple second business label suggests. SATCOM looks like the clearest growth vector. Fixed wireless access gives the company another route into higher-volume infrastructure opportunities. Defense adds a different kind of growth path, where product cycles can be longer but customer relationships and program funding can run deeper once platforms are selected. Management has also suggested wireless is further along in pipeline movement than photonics, and that more production deals are starting to come through.

The harder issue is revenue quality. Wireless is the larger contributor today, though much of that activity still leans on NRE, development contracts, and engineering-heavy work rather than mature recurring product revenue. Tachyon stands out because it looks more like a real production signal. The broader opportunity set still needs to convert from funded development and design activity into repeatable product shipments.

So wireless helps the Sivers story in a meaningful way. It broadens the revenue base, widens the end-market exposure, and gives the company more ways to win across SATCOM, telecom, fixed wireless, and defense. If it converts more cleanly into product revenue, it can become much more than supporting optionality. It can become a real growth pillar alongside photonics.

---

### 9. Financial Profile, Burn, Dilution, and Valuation

The financial profile helps explain why Sivers still carries both meaningful upside and meaningful funding sensitivity. In FY2025, revenue reached SEK 304.1 million, with product revenue at SEK 85.7 million and the balance still largely tied to NRE and development work. That mix shows a business that is growing but has not yet fully crossed into a self-sustaining product-led model.

The operating picture is improving, though it remains early. Q4 delivered positive adjusted EBITDA of SEK 10.8 million, and management said full-year adjusted EBITDA improved 31% year over year. Product revenue also grew sequentially in Q4 despite disruption from the U.S. government shutdown, which management described as a timing issue rather than a demand issue.

Even with that progress, Sivers is still in a capital-dependent phase. The latest refinancing is therefore a major development. Management announced a USD 17 million refinancing that replaced roughly USD 11.5 million of existing loans, secured a committed three-year facility, and included a USD 12 million fixed convertible priced at a significant premium to the then-current share price. The practical effect is that Sivers now has a stronger financing bridge and more flexibility to push through the next set of commercial milestones.

Management also gave a more explicit framework for what the model needs to look like from here. Cash flow breakeven is targeted at annual revenue of roughly USD 50 million to USD 55 million, with 65% of revenue coming from products, in roughly two years. Beyond that, management laid out a longer-term ambition of 25% to 30% annual revenue growth, gross margin around 65%, R&D around 20% of revenue, and EBITDA margin around 30%. These are targets, not outcomes, but they are still useful because they show how much mix improvement and scale the business still needs before it starts to look like a stronger self-funding semiconductor model.

Dilution remains part of the underwriting as well. Sivers has relied on external capital over the last several years, including equity issuance tied to the MixComm acquisition and later directed raises. That history is important. The refinancing strengthens the bridge from here, but it does not erase the fact that Sivers has needed outside capital to support the transition so far.

Valuation is where the tension comes together. The market is no longer debating whether Sivers has relevant technology. The harder question is whether they can turn that technical relevance into a much stronger mix of recurring product revenue before financing needs absorb too much of the upside. That is the financial hinge point for the whole story.

---

### 10. Scenario Framework

At roughly SEK 2.9 billion, or about USD 290 million, of market value today, Sivers is already being valued as a company moving toward an inflection, not as a business that will simply drift along at its current run rate. The question is how much of that inflection actually shows up.

The anchors are clear. FY2025 revenue was SEK 304.1 million, or about USD 30.4 million. Management has said cash-flow breakeven comes around USD 50 million to USD 55 million of annual revenue, and in a recent Q&A pointed to a broader path toward roughly 3x to 4x revenue over three to four years if execution goes well. Management has also laid out the main bridges: the LiDAR customer is expected to begin production ramp in Q4 2026, pluggables opportunities are growing, lasers are already being sampled at multiple customers, total opportunity pipeline reached USD 453 million, and product pipeline grew 90%. Management still frames 2027 as the year when CPO-laser opportunities can begin contributing revenue.

For target prices, I am using a FY2028 model.

Bear case

Sivers reaches roughly SEK 425 million, or about USD 42.5 million, of revenue.

That would mean the technology remains relevant, but commercial conversion stays too slow. LiDAR ramps more gradually, pluggables stay in qualification and sampling longer, and the broader photonics story still feels more promising than proven. In that setup, I think around 4.5x sales is fair, implying a valuation of about SEK 1.9 billion, or about USD 190 million, and a target price of roughly SEK 6.4 per share.

Base case

Sivers reaches roughly SEK 700 million, or about USD 70 million, of revenue.

This is already a good execution outcome. It puts the company comfortably above management's breakeven framework and would suggest that LiDAR is ramping, pluggables are becoming real, and the broader shift toward product revenue is working. CPO would not need to be a major revenue driver yet, though the market would likely begin paying more for that future optionality. In that setup, I think around 6.5x sales is fair, implying a valuation of about SEK 4.6 billion, or about USD 460 million, and a target price of roughly SEK 15.3 per share.

Bull case

Sivers reaches roughly SEK 950 million, or about USD 95 million, of revenue.

That would mean several things are working at once: LiDAR is ramping strongly, pluggables are converting well, and the photonics business is beginning to look like a real growth engine rather than a long-dated option. In that outcome, the market would likely start valuing Sivers as a genuine optical-growth story with credible relevance to future ELS and CPO demand. In that setup, I think around 8.5x sales is fair, implying a valuation of about SEK 8.1 billion, or about USD 810 million, and a target price of roughly SEK 27.2 per share.

---

### 11. What Is Publicly Proven, What Is Suggested, and What Is Missing

At this point, I think a clean way to frame Sivers is to separate what is already established from what still needs proof.

What is publicly proven

Sivers Photonics operates a real indium phosphide platform with in-house design and manufacturing capability on 100 mm wafers. They has shown real O-band CW-WDM laser-array work, including an 8-wavelength CW DFB array relevant to optical I/O and external-light-source architectures. The platform is also built around hybrid silicon photonics integration, with public material showing flip-chip alignment, etched-facet processing, and waveguide-coupling work.

Sivers also sits inside a real ecosystem. Ayar gives the company direct placement in optical I/O. O-Net, Enablence, and POET show module and external-light-source pathways. WIN provides a route toward larger-scale manufacturing beyond Glasgow. More broadly, this is clearly a combined photonics and wireless story rather than a one-product speculation.

What is suggested

Everything I have seen suggests that Sivers can become relevant in future optical I/O and external-light-source architectures if multi-wavelength arrays become an important supply layer in AI interconnect systems. The same is true for pluggables, where management says qualified opportunities are growing and lasers are already being sampled at multiple customers.

The evidence also suggests that the company is moving through qualification and manufacturing-readiness work rather than sitting at the concept stage. Platform-level qualification language, reliability framing, automated test capacity, and the WIN scale-up path all support that. The broader 2027 timing framework points in the same direction.

What is still missing

The missing pieces sit at the point where technical relevance turns into commercial proof. The public record still leaves gaps around full product-by-product commercial specs for the CPO-relevant arrays, especially linewidth, RIN, and a fuller picture of operating behavior by configuration.

The manufacturing side also remains incomplete at the array-specific level. Investors still need clearer evidence on customer qualification milestones, production-yield performance for the marketed arrays, manufacturing-transfer progress at larger scale, and the pace at which development programs are turning into recurring product revenue.

Management is also talking more openly about pluggables, larger roadmap discussions, and future product scaling, but that still falls short of named supply agreements, scaled photonics revenue, or fully proven CPO economics. That commercial conversion remains the hinge point for the whole story.

---

### 12. Key Milestones to Watch

The next stage of the Sivers story comes down to a small number of milestones that matter much more than daily price action.

The first is clearer photonics conversion from opportunity to product revenue. Management now describes a pipeline that moves from qualified opportunity to evaluation or development work, then to design-win or plan-for-production status, and finally into production. That makes pipeline progression one of the most important things to watch. Sivers already has a large opportunity pipeline, but the more important question is how much of that pipeline starts turning into recurring product revenue rather than staying in development for too long.

The second milestone is the shift from custom projects toward standard products. Management is now clearly trying to move from one-to-one development work toward one-to-many product sales. That matters because it can shorten the path to production, widen the customer base, and improve scalability. If that transition works, it should gradually make the business easier to model and less dependent on custom engineering activity.

The third milestone is photonics customer progression, especially in pluggables and future optical roadmaps. Management said qualified opportunities in pluggables are growing, lasers are already being sampled at multiple customers, and larger established companies are now entering roadmap discussions. We should look for movement from sampling and roadmap engagement into named design wins, production programs, and recurring shipments.

The fourth milestone is manufacturing transfer and scale-up. Glasgow gives Sivers a real in-house indium phosphide base, while WIN provides a path toward larger-volume production. That makes process transfer, yield, and repeatability critical. A strong outcome here would make the array story much easier to underwrite. A weaker outcome would slow the move from technical relevance to commercial scale.

The fifth milestone is revenue mix. Product pipeline grew faster than the total opportunity pipeline in 2025, which supports management's push toward a more scalable business model. The important thing to watch now is whether that begins to show up more clearly in reported results. Over time, a larger share of product revenue and a lower dependence on NRE would materially improve the quality of the story.

The sixth milestone is funding discipline. The refinancing has improved the near-term bridge and gives the company more flexibility than a simple year-end cash snapshot would suggest. Even so, the capital structure still matters because the business has not yet reached self-funded scale. Investors should keep watching cash balance, operating cash flow, and any signs that product conversion is or is not arriving fast enough to reduce future financing pressure.

Taken together, these milestones give a practical framework for following the story from here. The most important developments will come from pipeline conversion, standard-product adoption, photonics customer progression, manufacturing transfer, revenue-mix improvement, and funding discipline. Those are the areas most likely to change the underwriting in a meaningful way over the next 12 to 24 months.

---

### 13. Bottom-Line Conclusion

Sivers has a real indium phosphide platform, a real multi-wavelength laser-array story, and real placement inside the emerging optical ecosystem. That is enough to take the company seriously as a relevant part of the AI optical stack. They are also beginning to broaden the photonics story beyond a single future CPO outcome, with management now pointing to pluggables, customer sampling, and growing product pipeline as part of the path forward.

The harder part is commercial conversion. That is where the remaining diligence lives. I still need clearer evidence on product qualification, array-level manufacturing readiness, customer progression into production, and a cleaner shift toward recurring product revenue. Wireless helps by giving the company a broader commercial base and a second operating engine, but it does not remove the fact that the market is still waiting for more tangible proof on the photonics side.

So this is how I would frame it. Sivers is no longer a story that can be dismissed. There is enough substance here for the company to matter. But it is also not yet a story where technical relevance alone is enough. The company still has to earn the next stage. That makes this a name with real upside, real optionality, and real execution risk, which is usually exactly what smaller, earlier-stage optical names look like before the market gets full clarity.

---

*The information provided is for informational purposes only and does not constitute investment advice, a recommendation, or an offer to buy or sell any securities. The author may hold positions in securities mentioned. Readers should conduct their own due diligence and consult with a financial advisor before making investment decisions.*
