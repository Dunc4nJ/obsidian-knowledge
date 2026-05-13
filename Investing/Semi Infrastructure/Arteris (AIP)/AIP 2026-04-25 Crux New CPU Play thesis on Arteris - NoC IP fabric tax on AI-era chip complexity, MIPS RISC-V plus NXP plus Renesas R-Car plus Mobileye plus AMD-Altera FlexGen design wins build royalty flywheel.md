---
created: 2026-05-13
published: 2026-04-25
description: Crux's second-order AI-compute thesis on Arteris (AIP) — semiconductor IP licensor selling network-on-chip fabric (FlexNoC, Ncore, CodaCache, Magillem, FlexGen + Cycuity HW security) that becomes more valuable the more complex chips get. Multi-end-market exposure (CPU, NPU, RISC-V, chiplets, automotive AI, physical AI, hardware security) with 50%+ of 2025 business AI-tied, 275 AI SoC wins, NXP multi-product adoption, MIPS RISC-V win, Renesas R-Car Gen5 FlexNoC deployment, Mobileye multi-EyeQ history, FlexGen at 31 licensed projects with AMD + Altera multi-unit orders. Royalty flywheel runs delayed (years from design-in to royalty). 2026 guide $89-93M revenue / $100-104M ACV+royalties. Stock at $26.72 / $1.21B cap = 13x 2026 sales; Crux target entry $20-21 with $15 attractive — no longer cheap.
source: https://cruxcapitalgroup.substack.com/p/new-cpu-play-momentum-is-building
type: thesis
authors: ["Crux Capital Group (@cruxcapitalgroup)"]
---

# AIP 2026-04-25 — Crux "New CPU Play": Arteris is the NoC fabric tax on AI-era chip complexity — MIPS RISC-V, NXP multi-product, Renesas R-Car Gen5, Mobileye, FlexGen at AMD + Altera build the royalty flywheel

Crux Capital Group introduces a new position-track on [[Arteris (AIP)]] as a second-order beneficiary of the AI compute buildout. The company sells the internal communication fabric (network-on-chip IP) inside complex SoCs — a layer that becomes structurally more valuable as chip designs become more heterogeneous (CPUs + NPUs + accelerators + memory + chiplets + safety + security), and as more end markets (data center, edge, automotive, physical AI, RISC-V) demand custom silicon. The thesis is *architecture-agnostic*: Arteris doesn't need any single compute architecture to win — it gets pulled in wherever chip design complexity rises.

*Arteris (AIP) is the subject*
![[cruxcapitalgroup-new-cpu-play-001.png]]

## Key Takeaways

- **The setup**: small semiconductor IP business sitting behind a very large, under-appreciated change in chip design. AI chips are getting harder to build, integrate, and scale. [[Arteris (AIP)]] sells the internal traffic layer that makes all the pieces work together inside increasingly complex silicon and collects a toll every time a chip goes into production. Multi-theme exposure: CPUs, NPUs, chiplets, automotive AI, physical AI, RISC-V, custom silicon, hardware security.
- **Delayed-payoff structure**: design win today → years to production royalties. That creates near-term frustration *and* long-term opportunity in the same breath — and sets up a royalty flywheel that could become more visible later. Classic "second-order setup worth tracking" pattern.

*The internal-traffic problem inside an SoC*
![[cruxcapitalgroup-new-cpu-play-002.png]]

- **Why now**: every major trend in computing increases the burden on internal data movement — more specialized chips, more custom silicon, AI pushing compute into cars/factories/robots/edge devices/data centers simultaneously, chiplets turning single-chip design into a system-level integration challenge. Arteris is an *option call on chip complexity broadly* rather than a bet on any architectural winner.

*The architectural shift makes internal data movement more critical*
![[cruxcapitalgroup-new-cpu-play-003.png]]

- **Product stack**:
    - **FlexNoC** — the core network-on-chip IP; communication fabric inside an SoC.
    - **Ncore** — coherent interconnect for designs where multiple compute engines need reliable shared data (CPU + accelerator, chiplet-based, complex AI SoCs). Most directly tied to the AI-chip architectural shift.
    - **CodaCache** — last-level cache integration.
    - **Magillem** — automates SoC integration at the system level.
    - **FlexGen** — automation product (see "FlexGen" section below).
    - **Cycuity** (acquired) — adds hardware security assurance; verifies whether sensitive information can leak through the hardware fabric itself. As chips become more connected and embedded in critical systems, that becomes a real engineering concern.

*FlexNoC: the road system inside an SoC*
![[cruxcapitalgroup-new-cpu-play-004.png]]

*The expanding product surface — data movement + integration + security*
![[cruxcapitalgroup-new-cpu-play-005.png]]

- **The CPU/NPU angle is the entry-point**: AI workloads still need general-purpose compute around the accelerators. CPUs stay central. NPUs proliferate across edge/auto/PC/industrial/embedded — creating a growing class of mixed-compute chips with CPUs + NPUs + accelerators + memory in one design. The more heterogeneous the chip, the harder the internal connectivity problem. **[[NXP Semiconductors (NXPI)]]** expanded use of Arteris across AI-enabled silicon for automotive, industrial, and consumer edge spanning SoCs / NPUs / MCUs — *multi-product adoption from a major customer doing serious work at the CPU/NPU intersection.* (NXP is not on the vault watchlist; mentioned-only.)

*Mixed-compute chips: CPU + NPU + accelerator + memory*
![[cruxcapitalgroup-new-cpu-play-006.png]]

- **The RISC-V signal — MIPS / [[GlobalFoundries (GFS)]] partnership**: MIPS (now owned by GlobalFoundries) selected Arteris FlexGen and Magillem for RISC-V platforms targeting automotive, ADAS, robotics, embedded computing. RISC-V's openness creates more custom-chip freedom — which creates more integration complexity, which Arteris is built around. Physical-AI / cars / robots / industrial machines need different local compute (fast reaction time, safety, low power) — none want the same off-the-shelf chip — and once customization rises, the internal-data-movement / integration problem is exactly Arteris's territory.

*MIPS-Arteris RISC-V announcement*
![[cruxcapitalgroup-new-cpu-play-007.png]]

- **Physical AI is already an embedded foothold**: AI moving into machines that operate in the real world — cars, robots, drones, factories, smart cameras, industrial automation. Local compute must be fast, power-efficient, safe, secure, tightly integrated — meaningfully different from cloud-only AI. Arteris already in automotive, robotics, embedded compute, edge AI. MIPS announcement → physical AI. Renesas deployment → automotive AI. ARM + Cadence chiplet ecosystem work → chiplet integration. Same direction.

*Physical AI footprint across automotive, robotics, embedded*
![[cruxcapitalgroup-new-cpu-play-008.png]]

- **Automotive — Renesas R-Car Gen 5 + Mobileye anchor points**:
    - **Renesas R-Car X5H**: next-gen automotive SoC with [[ARM Holdings (ARM)]] CPU clusters + AI engines for perception/decision-making + graphics engines. **Arteris FlexNoC deployed to connect those pieces.** Also supports **UCIe-based chiplet extensions** — chiplet architecture moving beyond data-center processors into automotive AI. (Renesas is 6723.T; not on vault watchlist.)
    - **[[Mobileye (MBLY)]]**: long Arteris relationship across multiple EyeQ generations, including ADAS / autonomous-driving platforms. **Automotive programs have long production tails** — once a design reaches production, royalties can persist for years.

*Renesas R-Car Gen 5 architecture using Arteris FlexNoC*
![[cruxcapitalgroup-new-cpu-play-009.png]]

*Renesas R-Car X5H block-diagram detail*
![[cruxcapitalgroup-new-cpu-play-010.png]]

- **Chiplets make the story bigger**: traditional chip design puts everything on one die. Chiplet-based designs break the system into multiple packaged pieces — better cost / yield / power scaling / process-node mixing. But chiplets create a new integration problem: separate pieces must behave like a single coherent system (efficient communication, correct data sharing, traffic + latency management across die boundaries). Arteris's natural expansion. Modern SoCs can contain several NoC instances, each requiring design iterations as architecture evolves — **content opportunity per customer expands** with chiplet adoption.

*Chiplet-based design = new integration problem*
![[cruxcapitalgroup-new-cpu-play-011.png]]

- **FlexGen could change the perception**: as chips get more complex, engineers face a harder routing problem — how data moves, how blocks connect, how wires lay out, balancing power / latency / silicon area. FlexGen automates more of that work — claims improved NoC productivity, shorter wire length, lower latency, lower power. If chip-design complexity is genuinely outpacing what engineering teams can manage manually, automation becomes structurally valuable. **FlexGen reached 31 licensed projects in 2025, with multi-unit orders from [[Advanced Micro Devices (AMD)]] and Altera.** Real number. If FlexGen adoption continues, the market could start viewing Arteris as an automation platform for AI-era chip design.

*FlexGen — automating NoC design across more complex chips*
![[cruxcapitalgroup-new-cpu-play-012.png]]

- **The royalty flywheel mechanics**: company gets paid first via license + support fees during design phase. Production royalties come *later* — sometimes years later, after customers finish designing / qualifying / ramping chips. Design win today → royalty revenue 2-3 years out. Arteris says its technology has shipped in **>4B chips and chiplets**, **>925 SoC design starts**, **>90% customer retention**, **usage by 9 of the top 10 semiconductor companies**. Implies the company is more deeply embedded in the semiconductor design ecosystem than its revenue base implies. Central question: do royalties become more visible as more AI / auto / edge / chiplet designs move into production? If yes, Arteris starts looking like a *meaningful royalty platform tied to AI-era chip complexity*.

*Royalty flywheel: license now → royalty in 2-3 years*
![[cruxcapitalgroup-new-cpu-play-013.png]]

*Embedded-base proof points: >4B chips, >925 SoC starts, >90% retention*
![[cruxcapitalgroup-new-cpu-play-014.png]]

- **AI exposure already meaningful**: >50% of 2025 business AI-tied. **>275 AI SoC design wins** across data-center training, inference, and edge inference. Disclosed customer breadth: AMD, Altera, [[Meta Platforms (META)]], Tenstorrent, [[Blaize (BZAI)]], Hailo, [[Mobileye (MBLY)]], NXP, Renesas, [[Samsung Electronics (005930.KS)]], Bosch, Honda, BMW. Hyperscalers + AI chip startups + Auto Tier 1s + OEMs — pattern confirms Arteris being pulled into the parts of the market where chip-design complexity is rising fastest. Caveat: logos alone tell us nothing about revenue size, production timing, or IP content per design.

*AI SoC design-win breadth across customer types*
![[cruxcapitalgroup-new-cpu-play-015.png]]

- **Financials**: FY2025 revenue $70.6M (+22% YoY). ACV+royalties $83.6M (+28%). **RPO $117M (+32%) — contracted future revenue yet to be recognized**. Free cash flow positive at $5.3M. Q4 2025 revenue $20.1M (+30% YoY). **2026 guide: $89-93M revenue, $100-104M ACV+royalties, $5-9M FCF.** RPO growth is the key signal — revenue runway better than headline income statement suggests. Company often paid cash before revenue recognition, so FCF can look better than operating income.

*FY25 / Q4 2025 / 2026 guide financials*
![[cruxcapitalgroup-new-cpu-play-016.png]]

*Management long-term model: high-teens to low-20s license + faster royalty*
![[cruxcapitalgroup-new-cpu-play-017.png]]

- **The debate**: does revenue growth convert into meaningful operating leverage over time? Arteris is still investing heavily in R&D, field engineering, product expansion, integration. Rational if the opportunity is as large as management believes, but still must demonstrate that growth and profitability move together. Long-term model points to high-teens to low-20s organic license revenue growth and faster royalty growth. If royalties accelerate → genuinely attractive. If royalties stay small and inconsistent → premium valuation harder to defend.
- **Bear/Base/Bull 2027 framing** (entry at $26.72, ~$1.21B mkt cap, ~13x 2026 sales):
    - **Bear**: 2027 revenue $105-110M, growth decelerates, royalties stay small, multiple compresses to 8-10x sales → **$19-24**.
    - **Base**: 2027 revenue $120-130M, royalties become more visible, FlexGen adoption supports platform story → 12-14x → **$32-40**.
    - **Bull**: 2027 revenue $145-160M, royalties accelerate, market re-rates as scarce AI-era chip-design platform → 16-18x → **$52-64**.
- **Crux's strategy**: "$AIP is no longer cheap. At this price, the risk is valuation compression even if the company keeps growing. I personally would target $20-21 for an initial entry, with $15 as a much more attractive entry. This represents my conservative strategy right now with so much cash deployed."

## Tickers / entities mentioned

- [[Arteris (AIP)]] — subject (NASDAQ; auto-created folder in Semi Infrastructure for cohort-3 capture).
- [[Advanced Micro Devices (AMD)]] — FlexGen multi-unit-order customer.
- Altera — FlexGen multi-unit-order customer. Now an [[Intel (INTC)]] business unit being separated. Not on vault watchlist; mentioned-only.
- [[GlobalFoundries (GFS)]] — owns MIPS, which selected Arteris FlexGen + Magillem for RISC-V platforms.
- [[Mobileye (MBLY)]] — multi-EyeQ-generation Arteris customer.
- [[Blaize (BZAI)]] — disclosed AI-chip-startup customer.
- [[Meta Platforms (META)]] — disclosed customer (likely custom AI silicon).
- [[Samsung Electronics (005930.KS)]] — disclosed customer.
- NXP Semiconductors (NXPI) — multi-product adoption across automotive / industrial / consumer edge SoCs+NPUs+MCUs. Not on vault watchlist; mentioned-only.
- Renesas (6723.T) — R-Car Gen 5 (X5H) automotive SoC deploying Arteris FlexNoC + UCIe chiplet extensions. Not on vault watchlist; mentioned-only.
- Tenstorrent — private AI chip startup; Arteris customer.
- Hailo — private AI chip startup; Arteris customer.
- Bosch, Honda, BMW — auto OEMs / Tier-1s; disclosed customers. Not on vault watchlist; mentioned-only.
- ARM Holdings (ARM) — CPU cluster IP inside Renesas R-Car X5H alongside Arteris FlexNoC. Not on vault watchlist; mentioned-only.
- Cadence (CDNS) — chiplet-ecosystem-work alignment with Arteris on the integration layer. Not on vault watchlist; mentioned-only.

## Why this matters (Investing angle)

Arteris is the first pure-play NoC IP licensor on the vault watchlist — and a horizontal semiconductor-infrastructure name whose value scales with chip-complexity rather than with any specific architectural winner. The piece is useful for two reasons. First, it's a structural read on where the AI-chip complexity tax accrues: not at the compute layer (where every architecture races to win) but at the *integration fabric* layer, where multi-engine SoCs and chiplets are creating durable IP demand. Second, it's a methodology piece on second-order beneficiaries: Crux frames the delayed-royalty business model explicitly as a "near-term frustration / long-term opportunity in the same breath" — a structure that resembles the long-tail royalty stream of [[Adeia (ADEA)]] in Semi Infrastructure. Pair with future Arteris quarterly captures to track three KPIs: (1) FlexGen licensed-project count growth past 31; (2) RPO growth vs. revenue (the "contracted-revenue runway" signal); (3) any disclosure on royalty mix turning more material — the "platform re-rate" trigger.

## Original Content

I have been spending more time hunting for second-order beneficiaries of the AI compute buildout, focused on CPU/NPU/Inference.

There are many obvious names like AMD and ARM.

But there is opportunity is finding smaller companies sitting inside the architecture shift before the revenue pull-through becomes legible to the market. Today's name fits that setup almost perfectly.

This is a small semiconductor IP business sitting behind a very large, very underappreciated change in chip design. AI chips are getting harder to build, harder to integrate, and harder to scale. This company is focused on how efficiently data moves *inside* the chip.

This company sells the internal traffic layer that makes all the pieces work together inside increasingly complex silicon, and it collects a toll every time a chip goes into production.

That gives it exposure to several major themes simultaneously: CPUs, NPUs, chiplets, automotive AI, physical AI, RISC-V, custom silicon, and hardware security.

The setup also has a delayed-payoff structure that creates near-term frustration and long-term opportunity in the same breath. A design win today can take years to show up in production royalties, which keeps the stock in the down low and sets up a royalty flywheel that could become more visible later.

That is exactly the kind of second-order setup worth tracking.

You're going to want to read this.

---

*The full report covers the complete thesis: the product architecture, the customer proof points across automotive and AI, the royalty flywheel mechanics, the financial setup, the specific metrics worth tracking over the next several quarters, and what my investment strategy will be. None of this is financial advice. This is solely for educational purposes.*

### Arteris

The company is Arteris. Ticker: $AIP.

*[Embedded above as image 001 — Arteris brand mark.]*

AI-era chips are becoming more complex, and that complexity makes internal data movement more critical. Arteris sells the technology that solves that problem.

Small company. Strategically important position. No need to win the accelerator race. No need for one specific architecture to dominate. It benefits simply because more companies are building complex chips, and that trend is accelerating.

---

### The Thesis

Let's think about traffic in a city.

You can build the most impressive skyscrapers in the world, but if the roads connecting them are poorly designed, commerce grinds to a halt. A chip works the same way. You can pack it full of powerful compute, but if data cannot move efficiently to where it needs to go, from memory to the compute engine, from one block to another, across multiple chiplets in the same package, that expensive silicon gets wasted waiting.

*[Embedded above as image 002 — internal-traffic visual.]*

Arteris provides network-on-chip IP. The internal road system of a chip. As chips add more compute blocks, more memory interfaces, more specialized engines, and more chiplets, the road design problem gets harder. Bottlenecks cost performance. Bad routing wastes power. Poor coherency breaks complex multi-engine workloads.

The problem Arteris solves becomes more valuable the more complex chips become.

---

### Why This Is Interesting To Me Now

The underlying architecture of computing is changing in a way that makes its core problem dramatically more important.

*[Embedded above as image 003 — architectural-shift visual.]*

Chips are getting more specialized and more companies are building custom silicon. AI is pushing compute into cars, factories, robots, edge devices, and data centers simultaneously. Chiplets are turning single-chip design into a system-level integration challenge. Every one of these trends increases the burden on internal data movement.

The key insight is that Arteris requires no single architecture to win. RISC-V gains traction? Arteris is relevant. Custom AI chips proliferate? Arteris is relevant. Chiplets move from data-center processors into automotive and industrial? Arteris is relevant. The company sells the fabric *around* the compute rather than the compute itself, which means it holds an option call on chip complexity broadly rather than betting on any single winner.

---

### What Arteris Sells

The core product is FlexNoC, its network-on-chip IP. This is the communication fabric that moves data around inside a system-on-chip and determines how efficiently compute blocks, memory, and I/O can interact.

*[Embedded above as image 004 — FlexNoC visual.]*

Ncore is the coherent interconnect product. Coherency matters when multiple compute engines need to share data reliably, which is exactly what happens in CPU/accelerator combinations, chiplet-based designs, and complex AI SoCs. This is the product most directly tied to the architectural shift happening in AI chips.

CodaCache handles last-level cache integration, and Magillem automates SoC integration at the system level. These might be less headline-grabbing, but they address the same root problem which is modern chip design has become too complex to stitch together manually without better software and reusable IP blocks.

The newest layer is Cycuity, an acquisition that adds hardware security assurance, helping chip designers verify whether sensitive information can leak through the hardware fabric itself. As chips become more connected and more embedded in critical systems, that is a real engineering concern.

*[Embedded above as image 005 — expanding product surface.]*

Taken together, Arteris is assembling a broader platform around data movement, system integration, and security, all inside the same design problem.

---

### The CPU/NPU Angle

This is the piece that first made me pay closer attention.

AI workloads still need general-purpose compute around the accelerators. That keeps CPUs central. At the same time, NPUs are proliferating across edge devices, cars, PCs, industrial systems, and embedded platforms. The result is a growing class of mixed-compute chips, silicon that has to coordinate CPUs, NPUs, accelerators, and memory in a single design.

The more heterogeneous the chip, the harder the internal connectivity problem.

*[Embedded above as image 006 — mixed-compute chip visual.]*

Source: Arteris Q4 2025 Investor Presentation. NXP's expanded adoption is the cleanest proof point that Arteris is being used across mixed-compute edge AI designs, including SoCs, NPUs, and MCUs.

Then there is NXP, who is one of the largest automotive and embedded semiconductor companies in the world. NXP expanded its use of Arteris across AI-enabled silicon for automotive, industrial, and consumer edge, spanning SoCs, neural processing units, and microcontrollers. NXP is using multiple Arteris products in these designs.

Multi-product adoption from a major customer doing serious work at the CPU/NPU intersection is exactly what the thesis needs to see. It confirms that Arteris is getting pulled in wherever compute is becoming more heterogeneous and harder to integrate.

---

### The RISC-V Signal

The recent MIPS partnership is another piece worth understanding carefully.

*[Embedded above as image 007 — MIPS-Arteris announcement.]*

MIPS, now owned by GlobalFoundries, selected Arteris FlexGen and Magillem for RISC-V platforms targeting automotive, ADAS, robotics, and embedded computing.

RISC-V is an open processor architecture. It gives companies more freedom to build customized chips instead of designing everything around a closed processor ecosystem.

So for physical AI, cars, robots, and industrial machines all need different kinds of local compute. A robot may need fast reaction time. A vehicle platform may need safety and reliability. An industrial system may need low power and long operating life. These markets do not all want the same off-the-shelf chip.

But customization creates complexity.

Once a chip becomes more purpose-built, the processor, memory, accelerators, safety logic, sensors, and I/O still need to work together. That is the internal data-movement and integration problem Arteris is built around.

That is why this MIPS announcement is great for context. MIPS is using Arteris FlexGen and Magillem to help build RISC-V platforms for markets where chips are becoming more specialized and harder to integrate.

---

### Physical AI

Physical AI means AI moving into machines that operate in the real world like cars, robots, drones, factories, smart cameras, industrial automation. These markets need local compute that is fast, power-efficient, safe, secure, and tightly integrated, which is a meaningfully different design challenge than cloud-only AI workloads.

*[Embedded above as image 008 — physical-AI footprint.]*

Arteris is already embedded in this world. Automotive. Robotics. Embedded compute. Edge AI. The MIPS announcement points directly at physical AI platforms. The Renesas deployment points directly at automotive AI. The Arm and Cadence chiplet ecosystem work points in the same direction.

Physical AI environments are exactly where chip design complexity, safety requirements, power constraints, and security concerns converge.

---

### Automotive

A modern vehicle is becoming a compute platform. It has to process sensor inputs, run driver assistance functions, manage safety systems, and coordinate increasingly sophisticated software-defined features. That creates a dense data-movement challenge inside the main automotive compute chips, with multiple CPU clusters, AI engines, graphics processors, and safety systems all needing to share data reliably and efficiently.

*[Embedded above as image 009 — R-Car Gen 5 / FlexNoC.]*

Renesas's next-generation R-Car Gen 5 SoC series is a strong example. Renesas is a major automotive semiconductor supplier, and its R-Car platform is used for advanced vehicle compute, including driver assistance and automated-driving workloads.

The R-Car X5H is designed to handle a lot of different jobs inside the car at once. It has Arm CPU clusters for general compute, AI engines for perception and decision-making, and graphics engines for visual processing. Arteris FlexNoC is deployed to connect those pieces so data can move between them efficiently.

That is the key point for the thesis. As vehicle chips add more compute engines, the internal communication layer becomes more important.

The chip also supports UCIe-based chiplet extensions to scale AI performance. That suggests chiplet architecture is moving beyond data-center processors and into automotive AI, where future vehicle platforms may need more modular ways to add compute.

Mobileye is the other anchor point. Arteris has a long relationship across multiple EyeQ generations, including platforms tied to advanced driver assistance and autonomous-driving workloads. Automotive programs have long production tails, and once a design reaches production, royalties can persist for years.

*[Embedded above as image 010 — R-Car X5H block diagram.]*

---

### Chiplets Make the Story Bigger

Traditional chip design puts everything on one piece of silicon. Chiplet-based designs break the system into multiple pieces that are packaged together, which helps with cost, yield, power scaling, and mixing different process nodes for different functions. The architectural benefits are great, but chiplets create a new integration problem in that those separate pieces still have to behave like a single coherent system, communicating efficiently, sharing data correctly, managing traffic and latency across die boundaries.

*[Embedded above as image 011 — chiplet integration problem.]*

That is a natural expansion of the Arteris problem set.

The company has noted that modern SoCs can contain several NoC instances, and each instance requires design iterations as the architecture evolves. If customers use Arteris across more chiplets, more SoCs, and more design programs, the content opportunity per customer expands. The chiplet trend effectively increases the surface area Arteris can address inside any given customer design.

---

### FlexGen Could Change the Perception

FlexGen is the product to watch most closely, because it is the one that could change how the market categorizes the company.

*[Embedded above as image 012 — FlexGen automation.]*

As chips get more complex, engineers face a harder routing problem. They have to determine how data moves through the chip, how blocks connect, how wires are laid out, and how the design balances power, latency, and silicon area. That process becomes significantly harder as chips add more compute, more memory interfaces, more chiplets, and more safety and security constraints.

FlexGen automates more of that work. Arteris claims it improves NoC productivity, shortens wire length, reduces latency, and lowers power. If chip design complexity is genuinely outpacing what engineering teams can manage manually, automation becomes structurally valuable, and the direction of FlexGen is intuitive.

The traction looks meaningful too. Arteris reported that FlexGen reached 31 licensed projects in 2025, with multi-unit orders from AMD and Altera. That is a real number.

If FlexGen continues gaining adoption, the market could start viewing Arteris as an automation platform for AI-era chip design.

---

### The Royalty Flywheel

The Arteris business model has a structure that may create near-term frustration and long-term potential in the same breath.

*[Embedded above as image 013 — royalty flywheel mechanics.]*

The company typically gets paid first through licenses and support fees during the design phase. Production royalties come later, sometimes years later, after customers finish designing, qualifying, and ramping their chips. A design win today may show up in meaningful royalty revenue two or three years from now.

*[Embedded above as image 014 — embedded base proof points.]*

Arteris says its technology has shipped in more than 4 billion chips and chiplets. Over 925 SoC design starts. Over 90% customer retention. Usage by 9 of the top 10 semiconductor companies. Those numbers suggest a company more deeply embedded in the semiconductor design ecosystem than its revenue base implies.

The central question is whether royalties become more visible as more AI, automotive, edge, and chiplet designs move into production. If that happens, Arteris starts looking like a meaningful royalty platform tied to AI-era chip complexity.

---

### AI Exposure Is Already Meaningful

Arteris says more than 50% of its business in 2025 was tied to AI applications, with over 275 AI SoC design wins across data-center training, inference, and edge inference.

*[Embedded above as image 015 — AI SoC design-win breadth.]*

Take the logo drops with a grain of salt. Customer names alone tell us nothing about revenue size, production timing, or how much IP content Arteris has in each design. But the breadth of the disclosed customer list is notable: AMD, Altera, Meta, Tenstorrent, Blaize, Hailo, Mobileye, NXP, Renesas, Samsung, Bosch, Honda, BMW.

Hyperscalers. AI chip startups. Automotive Tier 1s. OEMs. The pattern confirms what the thesis predicts. That Arteris is being pulled into the parts of the market where chip design complexity is rising fastest.

---

### Financial Setup

For full-year 2025, Arteris reported revenue of $70.6 million, up 22% year over year. ACV plus royalties reached $83.6 million, up 28%. Remaining performance obligations hit $117 million, up 32%. Free cash flow turned positive at $5.3 million.

*[Embedded above as image 016 — FY25 / Q4 25 / 2026 guide.]*

Q4 2025 alone showed revenue of $20.1 million, up 30% year over year.

The 2026 guide calls for revenue of $89 to $93 million and ACV plus royalties of $100 to $104 million, with free cash flow of $5 to $9 million.

For a company of this size, that is a solid profile. The RPO growth is particularly important. It represents contracted future revenue yet to be recognized, which means the revenue runway is better than the headline income statement suggests. The company often gets paid in cash before revenue is recognized, so free cash flow can look better than operating income in certain periods.

*[Embedded above as image 017 — management long-term model.]*

The main financial debate is whether revenue growth converts into meaningful operating leverage over time. Arteris is still investing heavily in R&D, field engineering, product expansion, and integration. That is rational if the opportunity is as large as management believes, but the company still has to demonstrate that growth and profitability can move together. Management's long-term model points to high-teens to low-20s organic license revenue growth and faster royalty growth. If royalties accelerate, the model becomes genuinely attractive. If they stay small and inconsistent, the premium valuation is harder to defend.

---

### Bear, Base, and Bull Case for 2027

At $26.72, Arteris is already getting credit for the story. The market cap is roughly $1.21B, which puts the stock around 13x 2026 revenue guidance of $89M–$93M.

Bear case for the stock: Revenue reaches $105M–$110M in 2027, but growth decelerates, royalties remain too small to change the model, and the multiple compresses to 8x–10x revenue. That would imply roughly $19–$24.

Base case: Revenue reaches $120M–$130M, royalties become more visible, and FlexGen adoption supports the platform story. At 12x–14x revenue, that implies roughly $32–$40.

Bull case: Revenue reaches $145M–$160M, royalties accelerate, and the market starts treating Arteris as a scarce AI-era chip-design platform. At 16x–18x revenue, that implies roughly $52–$64.

My take: $AIP is no longer cheap. At this price, the risk is valuation compression even if the company keeps growing. I personally would target $20–$21 for an initial entry, with $15 as a much more attractive entry. This represents my conservative strategy right now with so much cash deployed.

---

***Disclaimer:** This report is for research and educational purposes only and is not financial advice. I am not a financial advisor. Please do your own due diligence and consider your own risk tolerance, time horizon, and financial situation before making any investment decisions. Small-cap stocks can be volatile, and valuation assumptions, revenue estimates, and price targets can change quickly as new information comes out. I may own, buy, or sell shares of companies discussed in this report at any time.*
