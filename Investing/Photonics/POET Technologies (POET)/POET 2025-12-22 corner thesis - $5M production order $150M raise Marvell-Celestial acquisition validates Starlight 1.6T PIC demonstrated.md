---
created: 2026-05-13
published: 2025-12-22
description: Crux Capital argues [[POET Technologies (POET)]] is materially de-risked by late-2025 inflections — first $5M 800G Infinity production order (R&D-exit signal), $150M institutional raise lifting cash to ~$300M post-close, [[Marvell Technology (MRVL)]]'s $3.25B (up to $5.5B) Celestial AI acquisition implicitly underwriting POET Starlight light-source supply, the Dec-8 1.6T transmitter PIC announcement validating wafer-scale passive alignment, and partnerships with [[Sivers Semiconductors (SIVE.ST)]], Quantum Computing Inc, Foxconn (FIT), Mitsubishi Electric and Luxshare extending into ELS/CPO and TFLN-enabled 3.2T post-2027.
source: https://cruxcapitalgroup.substack.com/p/poet-technologies-turns-a-corner
type: thesis
authors: ["Crux Capital Group (@cruxcapitalgroup)"]
---

# POET 2025-12-22 corner thesis — $5M production order, $150M raise, Marvell-Celestial acquisition validates Starlight, 1.6T PIC demonstrated, Sivers/Luxshare/Foxconn/Mitsubishi/QCi partnerships

## Key Takeaways

- **R&D exit signal**: [[POET Technologies (POET)]]'s first significant production order — >$5M for 800G Infinity optical engines (Oct 2025) — clears rigorous qualification gates after many years and is structurally more important than the dollar amount; shipments scheduled for 2H 2026 will reveal yields, reliability and margins. Infinity architecture daisy-chains 400G/800G engines for 1.6T and 3.2T, giving customers a modular upgrade path.
- **Balance sheet transformed**: Oct-7 $75M private placement with a single institutional investor was followed by a $150M raise ("all institutional money," no warrants — high demand signal). Pro-forma cash ~$300M, materially reducing near-term financing risk and funding aggressive partnership/order execution.
- **[[Marvell Technology (MRVL)]]–Celestial AI is the most material catalyst**: $3.25B upfront ($1B cash + $2.25B stock) plus earnout up to $2.25B (total up to $5.5B); earnout vests one-third at cumulative C-AI revenue >$500M by Marvell FY29 and full at >$2.0B by same date — implying Marvell expects multi-billion C-AI revenue and proportional component volume. POET disclosed a development/production agreement with Celestial since Feb 2022 (POET Starlight, April 2023) supplying 4- and 8-channel flip-chipped laser configurations that meet C-AI's need for passively aligned, scalable, multi-channel external light. By acquiring C-AI, Marvell "is implicitly underwriting the stack that makes Celestial work."
- **Leadership tie de-risks design-out**: David Lazovsky (Celestial AI founder/CEO; former POET Executive Chairman) has intimate knowledge of POET's Optical Interposer. He publicly called Marvell the "ideal home" for Celestial — author treats this as advocacy inside Marvell and speculatively raises the prospect of deeper integration or a future Marvell acquisition of POET to vertically integrate light source tech.
- **1.6T transmitter PIC (Dec 8 2025)**: Four laser arrays attached directly onto the Optical Interposer with driver chips placed alongside; wavelength-combining (mux) pulled into the same package via integrated multiplexing — reduces delicate manual-style assembly and removes standalone mux parts. Real proof point for high-yield, repeatable placement; keeps the 3.2T roadmap credible.
- **Partnership ecosystem**:
  - [[Sivers Semiconductors (SIVE.ST)]] (Sep-29-2025) — co-develop External Light Sources (ELS) for CPO; Sivers = "bulb" (laser chip), POET = "socket" (interposer packaging). ELS market projected as $1B annual opportunity in AI connectivity. Prototypes targeted 1H 2026, production readiness end-2026.
  - Quantum Computing Inc (Nov-11) — 3.2T optical engines using Thin-Film Lithium Niobate (TFLN). TFLN switches light very fast with very little power but is brittle/hard to package; POET interposer acts as "socket" for the TFLN modulator, creating a hybrid engine combining LN raw speed with silicon manufacturability. Positions POET for the 3.2T era (post-2027).
  - Foxconn (FIT) — co-developing 800G and 1.6T pluggable transceiver modules using POET engines; POET is assembling Infinity engines at its high-volume Malaysia facility.
  - Mitsubishi Electric — co-developing 3.2T engines for AI; Mitsubishi 400G EMLs (notoriously hard to package due to heat/signal integrity) integrated via POET's Optical Interposer into a unified 3.2T chipset. 1.6T engines paired with Mitsubishi 400G EMLs already publicly showcased.
  - Luxshare — production-volume design-in: both transmit and receive POET engines packaged into Luxshare 400G/800G pluggable transceivers sold to hyperscalers.
- **Why the OI matters**: At 1.6T/3.2T, mechanical precision required by traditional active alignment becomes economically unviable; POET's passive-alignment (pre-printed guide rails on the silicon wafer; drop-and-snap component placement) is presented as "the only viable path … at wafer scale" — analogous to LEGO bricks versus fumbling a USB plug in the dark.
- **Distance economics framing**: 0-2m intra-rack stays passive copper indefinitely; 2-5m rack-to-rack belongs to AECs (heavy, power-hungry but cheaper than optics today); 5m+ row-to-row and cluster is the photonics zone — POET's focal point.
- **Author posture**: "Significantly less risky" but still pre-revenue; expect plenty of volatility. Frames the note as expansion of perception, not a buy signal.

## Tickers & Companies

- [[POET Technologies (POET)]] — subject; Optical Interposer (OI), POET Starlight (light source for CPO), Infinity 400G/800G engines (daisy-chain to 1.6T/3.2T)
- [[Marvell Technology (MRVL)]] — $3.25B+ (up to $5.5B) acquisition of Celestial AI; implicit underwriter of POET light-source supply chain
- Celestial AI — private; key POET customer via Starlight; David Lazovsky founder/CEO
- [[Sivers Semiconductors (SIVE.ST)]] — ELS co-development for CPO; prototypes 1H 2026 → production readiness end-2026
- Quantum Computing Inc — TFLN modulator partner for 3.2T
- Foxconn / Foxconn Interconnect Technology (FIT) — pluggable transceiver co-development, Malaysia assembly
- Mitsubishi Electric — 400G EML supply for 3.2T engine collaboration
- Luxshare — pluggable transceiver volume customer (400G/800G)

## Original Content

*Verbatim from <https://cruxcapitalgroup.substack.com/p/poet-technologies-turns-a-corner>*

### Introduction

Late 2025 has been full of pivotal updates for POET technologies. From critical financing to new orders to key partnerships. These last few months are demonstrating that POET is transitioning from an idea to a reality. This report will cover all of the recent relevant updates for POET that I believe have significantly reduced their risk profile. In addition I will also lay down some foundational knowledge on POET for first time readers. Lastly, I will include some one-off bits from user requests that were made on X. If you are invested in POET or you are at least intrigued in the company, you need to read this!

### What IS POET Tech?

POET Tech is a semiconductor company that specializes in photonics integration. They build what is called an 'optical engine' that helps move data using light (photonics) instead of electricity (copper) inside AI and data-center hardware. The core idea is to put multiple photonics parts like lasers, modulators, and detectors all together in a very compact package called the Optical Interposer (OI). Customers can plug these optical engines into transceivers or other modules to get higher bandwidth, lower power, and smaller size than older designs that use more discrete parts and more complex assembly. The theory is that they can solve the cost and scalability bottlenecks that haunt data centers.

### Overview of this quarter

The events over the last few months have moved this thesis from theoretical to empirical. The receipt of an over $5m production order for 800G Infinity engines signifies the official exit from the R&D phase. This signal was fortified with a $150m financing round, which brought pro-forma cash to in excess of ~$300m immediately following closing and materially reduced near-term financing risk. However, what I believe to be the most profound development was Marvell's $3.25B acquisition of Celestial AI. As a disclosed light-source partner to Celestial (via POET Starlight), POET now has real exposure to a roadmap that is moving inside one of the largest data-infrastructure semiconductor platforms in the world. The presence of David Lazovsky (former POET chairman and current C-AI CEO) at the center of this transaction serves as a powerful validation of the tech lineage and strategic fit of the OI and the industries shift towards optics.

On top of all of this we see POET continuing to keep up pace (or outpace in many instances) the industry standard. The unveiling of the 1.6T transmitter PIC on 12/8 reasserts the company's lead over many traditional silicon photonics. Further, the strategic collaborations with Sivers Semiconductors and Quantum Computing Inc. expands the TAM into ELS and TFLN modulators for 3.2T applications. We will unpack this more later.

All in all, I believe that not only did POET become way less risky these last few months, but their upside also grew significantly. I personally had concerns about their long term future due to increased competition and tech disruption. This has changed in a very meaningful way due to all the updates I will cover in this report.

I want to drop a quick disclaimer. None of this is financial advice and should not be seen as a recommendation. While I will discuss how all of these updates helped REDUCE risk, there is still plenty of risk to be had with a company that still does not have meaningful revenue and has alot to prove. While I am clearly bullish and am positioned accordingly, I have no crystal ball into what happens next with the price. I think we will see plenty of volatility over the next few months with wild price swings. Use this report as a way to expand your perception of POET rather than a signal to buy.

### Foundation

Before diving into all of the recent news I think it's important to set the stage for why POET exists and the need that it fits in the market. When I think about the need for POET it almost always goes back to the transition away from copper to photonics and the need for something better than traditional active alignment.

For decades data centers have relied on copper interconnects to move data between racks and servers. As GPU speeds dramatically increase, the physical limitations of copper are being seen across many distances.

First off is the signal and power loss. At speeds required for training AI (800G, 1.6T and beyond), electrical signals rapidly degrade. To compensate for this, we must pump more power into the signal creating massive heat waste.

The industry has introduced Active Electrical Cables (AEC) which essentially put boosted chips inside the cable to extend copper's reach to roughly 3-4 meters. For distances 0-2 meters (inside the rack) passive copper is cheap, reliable and zero power. This distance will remain copper for the foreseeable future. 2-5 meters (rack-to-rack) is where AEC puts up the fight. Copper needs the boost to survive here. While it is heavy and power-hungry it is currently cheaper than optics. 5+ meters (row-to -row and cluster-wide) is where photonics shines. This is POET's focal point.

Second, is the thermal constraint. Modern AI clusters are power limited and every watt spent on moving data is a watt that won't be spent on computing data. Photons have far lower loss over these distances and generate significantly less heat than pushing the same bandwidth over copper.

Lastly we see the need for a new style of manufacturing. The traditional method of active alignment is slow, capital intensive and results in low throughput. Basically a laser is powered on, a high-precision robots moves a lens of fiber in microscopic increments to find the point of max light transmission, and then the component is glued in place. Imagine trying to plug a USB cable into a port in a pitch-black room. You have to fumble around, wiggle the connector, and maybe turn on a flashlight to see if it's lined up before you push it in.

Compare this to POET's passive alignment strategy. Imaging you are a kid again and you are playing with legos. The bumps and holes on the bricks are so precise that you don't need to look closely or wiggle them. You just snag them together and they fit perfectly every time. This is what POET has done. When POET makes their silicon base (the wafer) they use microscopic printing to create tiny guide rails and slots, if you will. These are the legos. Because these guide rails are perfect, high-speed robots simply pick up a laser component and drop it into the slot. No need for a laser to be on. No need for wiggling. This might sound small, but this allows chips to be mass produced in a method akin to standard computer parts resulting in a lower bill of materials and lower capex.

Ok, now on to the news.

### Financial Inflection

Over the last few months we have witnessed a dramatic restructuring of POET's financial foundation. The company has moved from a position of financial scarcity to one of abundance that allows them to be aggressive on their expansion strategy.

Let's first talk about the $5m production order from October. This was POET's first significant production order and it was for 800G Infinity optical engines. While the dollar amount seems financially insignificant for a company of POET's size, its structural significance is immense. This order represents real customers and real revenue. POET has been around for a long time. Taking a product like the OI from idea to deployable takes many many years. There are rigorous qualification gates associated with this process. Another interesting piece of this order is the 'Infinity' architecture. This design allows customers to 'daisy-chain' 400G and 800G engines to achieve 1.6T and 3.2T speed. This provides a modular upgrade path. These orders are scheduled for shipment in the second half of 2026. Once this happens we will get crucial information on yields, reliability, margins etc. and see whether or not POET is as important and cost-effective as I believe it to be.

Next let's talk about the Balance Sheet. The financial transformation began on October 7, when POET closed a $75 million private placement with a single institutional investor. A critical vote of confidence that set the stage. This was immediately followed by a $150 million financing round. The offering was characterized by 'all institutional money', implying that sophisticated investors conducted deep DD on the tech and order book. The absence of warrants from this raise indicated high demand. Post-raise POET had roughly $300m in cash. This gives them funding to aggressively pursue partnerships and fulfill orders.

### The Marvell Acquisition of Celestial AI

The most significant industry event of the last few months for POET was the acquisition of Celestial AI for $3.25B. I view that as a meaningful de-risking signal for Celestial's key enabling components, including the light-source side where POET participates. While the vast majority of details of the deal are mostly irrelevant for POET investors, I will discuss the relevant bits and where we should pay attention. $3.25b upfront ($1B cash, $2.25B stock) and a potential earnout of up to $2.25B. Total value up to $5.5B. The earnout is tied to revenue milestones, with one-third earned if Celestial's cumulative revenue by the end of Marvell's fiscal 2029 exceeds $500m, and the full earnout earned if cumulative revenue exceeds $2.0b by that same deadline. This structure implies that Marvell expects C-AI to generate billions in revenue over the next 3-4 years. For suppliers to C-AI (like POET) this signals a massive ramp in component volume.

The critical insight for us as POET investors is the supply chain relationship. Celestial needs external light sources to drive its platform, and POET has disclosed a development/production relationship tied to POET Starlight. POET disclosed an agreement with Celestial in February 2022, and then in April 2023 it introduced POET Starlight and disclosed an agreement for development/production plus an advanced purchase order for initial production units. Celestial needed a light source that was passively aligned, scalable, and capable of providing multiple channels of light in a small form factor. Poet's platform was the unique enabler for this, allowing 4-channel and 8-channel configuration with flip-chipped lasers.

So by acquiring C-AI, Marvell is implicitly underwriting the stack that makes Celestial work. I view that as a meaningful de-risking signal for Celestial's key enabling components, including the light-source side where POET participates.

This connection is reinforced by deep leadership ties. David Lazovsky, the Founder and CEO of Celestial AI, served as the Executive Chairman of POET Tech prior to founding Celestial. Lazovsky possess intimate knowledge of POET's OI capabilities. His decision to select POET as a supplier for Celestial was based on a deep understanding that POET offers the most viable path to cost-effective, wafer-scale light sources. Lazovsky has publicly stated that Marvell is the ''ideal home' for Celestial. For me it is probable that he has advocated for the robustness of the POET solution within Marvell's ecosystem.

To finish this section I believe that this relationship with Lazovsky significantly reduces the risk of Celestial ''designing out' POET. Instead, it seems to me like it would increase the likelihood of deeper integration or even a potential future acquisition of POET by Marvell to vertically integrate the light source tech. Purely speculative, but my brain could connect those dots.

### The 1.6T Inflection

On December 8, 2025, POET announced its hybrid-integrated 1.6T transmitter PIC. This is POET showing it can build the kind of high-speed optical core that next-gen AI clusters will need.

They took four laser arrays and attached them directly onto the Optical Interposer, then placed the driver chips right next to them. That matters because it reduces the amount of delicate, manual-style assembly that usually makes these products expensive and hard to scale. They also pulled the wavelength-combining step into the same package using integrated multiplexing, instead of relying on extra standalone parts.

The takeaway is scalability. Laser arrays at these speeds are usually a manufacturing nightmare because everything has to line up perfectly across multiple lanes. POET's whole platform is built to make that placement repeatable, fast, and high-yield. This is why I view the 1.6T update as a real proof point, and why it keeps the 3.2T roadmap credible as bandwidth steps up.

### Ecosystem and Partnerships

POET has transitioned from a vertically integrated R&D shop to the hub of a diverse ecosystem. By partnering with best-in-class material and component suppliers, POET creates complete solutions that are greater than the sum of their own parts. Let's look at Sivers Semiconductors, Quantum Computing Inc, Foxxconn and Luxshare

On September 29, 2025, POET solidified a partnership with Sivers Semiconductors to co-develop External Light Sources (ELS) for Co-Packaged Optics (CPO). Without getting into all the highly technical details, Sivers provides the 'bulb' (laser chip) and POET provides the 'socket' (the interposer packaging). Together they create a compact, pluggable light engine that aims to solve the thermal management issues of CPO. The ELS market is projected to be a $1B annual opportunity within the broader AI connectivity market. Through this partnership they expect to demonstrate prototypes in the first half of 2026, with production readiness by the end of 2026. This partnership demonstrates one major way that POET intends to capture market share in the CPO world.

Next up we have the announcement with Quantum Computing Inc. on November 11th. This partnership aims at developing 3.2T optical engines using a material called Thin-Film Lithium Niobate (TFLN). TFLN allows us to switch light on and off at incredible speeds with very little power, which is exactly what you need as data rates hit 200G and 400G per lane. The problem is that TFLN is notoriously difficult to handle; it is brittle and hard to package. This partnership aims to solve that. QCi brings the TFLN modulator capability, and POET's interposer acts as the 'socket' to package it safely and integrate it into an engine that can scale. By bonding the TFLN chip to the POET interposer, they create a hybrid engine that combines the raw speed of Lithium Niobate with the manufacturability of silicon. This puts POET at the bleeding edge of physics. POET is laying the groundwork for the 3.2T era (post-2027). This partnership was significant for me because it's a sign that no matter where the market goes - from pluggables to CPO - POET is going to adapt and stay relevant in a meaningful way beyond just providing lasers.

The partnership with Foxconn (FIT) is about co-developing 800G and 1.6T pluggable optical transceiver modules that use POET's optical engines. At the same time, POET has been assembling Infinity engines at its high-volume production facility in Malaysia, which strengthens the narrative around scale and a resilient supply chain.

Then we have Mitsubishi Electric, a heavyweight in laser technology. This collaboration is massive because they are co-developing 3.2T optical engines for the AI market. Mitsubishi brings their top-tier 400G EMLs (Electro-absorption Modulated Lasers) to the table. These are components that are notoriously difficult to package due to heat and signal integrity issues. POET integrates these lasers using the Optical Interposer to create a unified 3.2T chipset. POET and Mitsubishi originally said they aimed to complete the 1.6T and 3.2T optical engine chipsets in early 2025 and jointly support major-customer demonstrations, and since then POET has publicly showcased 1.6T engines partnered with Mitsubishi's 400G EML lasers as a tangible step on that roadmap.

Finally, there's Luxshare. As a major global manufacturer of optical modules, Luxshare's involvement is a strong commercial signal. This partnership has expanded to include both POET's transmit and receive optical engines for Luxshare's 400G and 800G pluggable transceivers. Luxshare is using these engines to build 800G transceivers for data centers. This partnership is all about volume and design-in status where Luxshare takes POET's engine and packages it into a finished pluggable module that they then sell directly to the world's largest cloud providers.

### Conclusion

For years, the bear case on POET was that it was a lab experiment that would never achieve manufacturing scale. I believe that all the updates spoken through on this report help to challenge that bear case.

Furthermore, the strategic landscape has shifted in POET's favor. The acquisition of Celestial AI by Marvell is a $5.5 billion endorsement of the exact architecture POET enables. As a disclosed light-source partner to Celestial, POET is no longer just a science project narrative; it is tied into a high-value architecture that is now being scaled inside Marvell.

Technologically, the Optical Interposer remains the only viable path to passive alignment at wafer scale. As the industry moves to 1.6T and 3.2T, the mechanical precision required renders traditional active alignment economically unviable.

We still need to see if POET's tech is commercially viable. We will know way more about this at the end of 2026. But the more the news stacks up, the more partnerships announced, and the bigger the TAM, the more upside we see if POET is successful.
