---
created: 2026-05-13
published: 2026-04-16
description: Crux Capital paid thesis post on [[Viavi (VIAV)]] as the overlooked AI-infrastructure validation layer — TestCenter D2 1.6T appliance for hyperscaler workload emulation, DCX 700 multifiber loss test (data-center now ~1/3 of field-instrument demand), hollow-core fiber test solution already in trials with three hyperscalers, business mix shifted to ~60% data center + A&D / <40% service provider, NSE Q2 +45.8% YoY to $291.5M, Spirent acquisition tracking to ~$200M ARR (now central to high-speed Ethernet test), tech-node cycle compressed from 6 years (100G→400G) to 2 years (1.6T→3.2T), management has 3-quarter forward visibility.
source: https://cruxcapitalgroup.substack.com/p/viavi-an-overlooked-layer
type: thesis
authors: ["Crux Capital Group (@cruxcapitalgroup)"]
subsectors: [Equipment & test, Networking systems]
---

# Crux Capital 2026-04-16 — VIAVI overlooked validation layer: 1.6T testbeds, fiber field instruments to ~1/3 of demand, hollow-core trials with 3 hyperscalers, Spirent to $200M ARR, tech-node cycle compressed to 2 years

## Key Takeaways

- **The frame** — Crux pitches [[Viavi (VIAV)]] as the test/validation layer that gets pulled in *after* the transceiver, switch, and fiber are deployed but *before* network confidence exists. As 800G → 1.6T → 3.2T compresses the technology-node cadence, validation burden rises faster than hardware.
- **Mix has flipped**: management says only ~40% (and slipping under) is service-provider — **~60% is now data-center ecosystem + aerospace & defense**. VIAV is no longer a "telco test gear" company.
- **TestCenter D2 1.6T Appliance** — high-speed Ethernet platform for hyperscaler/neocloud/network-equipment AI-workload emulation at 1.6T. Direct pitch: AI workloads, multi-vendor environments, validation at scale.
- **Fiber field instruments**: a year ago, data center was a small piece of field-instrument demand; by the January call, **data center is ~1/3**. Management: *"emerging strong demand for our fiber field instruments by hyperscalers and service providers to build, operate, and optimize the next generation of fiber networks."*
- **DCX 700** — optical-loss test set, up to 24 fibers simultaneously — sized for dense data-center fiber plant certification.
- **Hollow-core fiber test (January 2026 launch)** — bidirectional medium/long-range hollow-core test & certification *already in trials with three leading hyperscalers* for AI campus-to-campus data-center interconnect. *"VIAVI showing up around infrastructure that still feels early is usually where stronger positioning starts getting established."*
- **Q2 numbers (NSE-led)**:
  - Revenue $369.3M (+36.4% YoY, high end of guide)
  - **NSE $291.5M (+45.8% YoY) — 78.9% of total revenue**
  - Non-GAAP operating margin 19.3%
  - Adj EPS $0.22
  - FCF $36.9M
- **Q3 guide**: $386-400M revenue / NSE $304-316M / OM ~19.7% / EPS $0.22-0.24 — continuation, not a one-quarter pop.
- **Balance sheet cleanup**: $772.1M cash + ST investments; converted ~$103.5M of converts to shares; **prepaid $100M of Term Loan B** in January; buybacks paused to prioritize debt management.
- **Spirent acquisition** — high-speed Ethernet + network-security testing assets. Initial $180M NSE-revenue 12-mo guide later tightened to a **~$200M annual run rate**; Q2 contribution $43M (slightly under earlier expectations on timing); Q3 includes full 13 weeks vs 10 in Q2. **Restructuring**: ~5% of global workforce, ~$30M annual savings by end-2026 (~$16M tied to Spirent synergies). CEO quote: *"costs coming out of the slower or stagnant product segments… free up resources… put more wood behind the arrow on data center ecosystem, aerospace and defense."* Crux: portfolio reshaping, not generic cost-cutting.
- **Ecosystem partners**: at MWC 2026, collaborations with 20+ partners incl AWS, [[Nvidia (NVDA)]], [[Nokia (NOK)]], Ericsson, Amphenol, Calnex, Infosys, GlobalLogic, Rohde & Schwarz. At OFC 2026, demos with Ethernet Alliance, Fiber Optic Center, Amphenol, Celestica. The thesis: VIAV is becoming embedded as the **trusted validation + interoperability layer** as hyperscalers vertically integrate into their stacks.
- **Second engine — aerospace & defense**: resilient Position, Navigation, and Timing (PNT) as a major near-term defense driver (drones, autonomous systems). Timing also tightens *into the rack* as data-center synchronization requirements rise — connecting A&D back into the AI infrastructure story.
- **Two CEO quotes that frame the forward picture**:
  - *"We now see the new each technology nodes turning over every two years. So you no longer, let's say, between 100 gig and 400 gig, you had 6 years. You really now have 2 years between 1.6 and 3.2."* — node-cycle compression
  - *"We have a pretty good view, at least on the base demand from these type of activities, up to three quarters ahead."* — forward visibility
- **Crux's conclusion**: faster tech cycles + better-than-typical forward visibility in the same business is a strong combination. As AI clusters get more optical, more distributed, more demanding to qualify, the validation layer compounds in value.

## Why this matters

The "overlooked layer" framing is the cross-section Crux wants — VIAV isn't a transceiver/laser bet, it's the *tax on the entire physical layer transition*. Two-year node-cycle compression (1.6T → 3.2T) is a structural tailwind that increases test cycles per year. The hollow-core fiber test product in trials with 3 hyperscalers ties this into the Corning/AAOI/[[Lumentum (LITE)]] DCI thread. Spirent push to ~$200M ARR adds NSE mass at the high-speed Ethernet / network-security node, complementary to fiber/optical test. Sits next to the VIAV Q3 earnings recap (Crux 2026-04-30) — that note covers the *result* of this build-out thesis, this one is the underlying positioning argument. Worth comparing to the [[POET Technologies (POET)]] / [[Coherent (COHR)]] / [[Applied Optoelectronics (AAOI)]] capacity-buildout reads — VIAV captures economics regardless of which hardware vendor wins.

## Original Content

Let's start with a very simple idea.

Building the optical hardware is only part of the job. After the transceiver, the switch, and the fiber are in place, someone still has to prove the network actually works the way it should.

The links have to be validated, the transceivers have to be tested, the fiber has to be certified and the system has to be checked across vendors and across real workloads before deployment.

That is where VIAVI sits. And as speeds move from 800G toward 1.6T and AI clusters become denser and more complicated, the burden around validation keeps rising.

> "Testing is shifting from components to validating and optimizing behavior, trust and resilience at scale."

That is the VIAVI story.

---

### What VIAVI does

*VIAVI portfolio map — validation/certification/monitoring across the optical infrastructure (image 1 of 9)*
![[cruxcapitalgroup-viavi-an-overlooked-layer-001.png]]

VIAVI sits after the optical hardware and before full network confidence. It sells the tools and workflows that help customers validate, certify, monitor, and optimize the infrastructure around the transceiver, the connectivity, and the fabric itself. That includes lab and production test, fiber certification in dense environments, optical manufacturing workflows, and system-level testing as speeds rise and architectures get more complex.

---

### Why this is becoming more important now

Let's look at the TestCenter D2 1.6T Appliance.

*TestCenter D2 1.6T Appliance — high-speed Ethernet test platform (image 2 of 9)*
![[cruxcapitalgroup-viavi-an-overlooked-layer-002.png]]

This is a high-speed Ethernet network test platform built to generate traffic, emulate workloads, and help customers validate performance, scale, reliability, and interoperability in 1.6T environments. VIAVI aimed it directly at cloud providers, hyperscalers, neoclouds, and network equipment manufacturers, with the pitch centered on AI workloads, multi-vendor environments, and validation at scale.

> "Current validation technologies are struggling to keep pace with the unprecedented performance and scale requirements of AI and next-generation cloud architectures."

Management gave another strong signal on the call when it described the business mix.

> "...we're now only about 40%, a little bit under 40%, exposed to service provider. And I'd say 60% is driven by the data center ecosystem and the aerospace and defense."

VIAVI used to be easier to view through a traditional service-provider lens. A much larger share of the business is now being pulled by data-center ecosystem demand and aerospace and defense.

---

### Fiber expands the story

The story gets more interesting once you move beyond high-speed Ethernet test and look at the physical fiber plant. Hyperscale AI infrastructure is about faster boxes and denser connectivity at the same time, and that pulls fiber certification directly into the buildout.

The DCX 700 is a good example.

*DCX 700 multifiber optical loss test set, up to 24 fibers simultaneously (image 3 of 9)*
![[cruxcapitalgroup-viavi-an-overlooked-layer-003.png]]

It is an optical loss test set used to certify multifiber links in dense environments, up to 24 fibers simultaneously, with the pitch centered on faster certification, lower error rates, and better workflows for dense data-center fiber infrastructure. A year ago, data center represented only a small piece of field-instrument demand. By the January call, management said that figure had moved to about a third.

> "...we are now also seeing emerging strong demand for our fiber field instruments by hyperscalers and service providers to build, operate, and optimize the next generation of fiber networks to interconnect the data centers."

There is also the hollow-core fiber angle.

*Hollow-core fiber bidirectional medium/long-range test & certification solution, January 2026 launch (image 4 of 9)*
![[cruxcapitalgroup-viavi-an-overlooked-layer-004.png]]

In January, VIAVI announced an all-in-one medium and long-range hollow-core fiber bidirectional testing and certification solution. Hollow-core fiber is an emerging architecture designed to move data with lower latency and lower signal distortion over longer distances, and the offering had already been used in trials with three leading hyperscalers tied directly to data-center interconnect between hyperscale campuses for AI. VIAVI showing up around infrastructure that still feels early is usually where stronger positioning starts getting established.

Management described the fiber value chain as firing at full speed, with lab demand tied to 1.6T and PCIe 6.0 development, and production demand tied to module vendors, optical switches, and fiber test. Hyperscalers are also becoming much heavier users of field instrumentation because they want tighter monitoring over incoming wavelengths and tighter control over fiber performance across every strand. That is a very different standard from the old telecom mindset, and it is pulling VIAVI deeper into the physical layer that supports the AI network.

---

*The rest of this post is for paid subscribers. What follows covers the financial picture, what Spirent changed, and why the forward visibility comments on the call stood out.*

---

### The numbers are starting to reflect the shift

Q2 revenue came in at $369.3 million, up 36.4% year over year and at the high end of guidance. Network and Service Enablement reached $291.5 million, up 45.8% year over year, and represented 78.9% of total revenue. Non-GAAP operating margin reached 19.3%, EPS came in at $0.22, and free cash flow reached $36.9 million. The strategic shift is showing up in real financial performance.

*Q2 financial summary — revenue, segments, operating leverage (image 5 of 9)*
![[cruxcapitalgroup-viavi-an-overlooked-layer-005.png]]

The mix is the key. NSE is the engine carrying the current momentum, tied directly to data-center ecosystem demand, lab and production tools, field products, and the broader validation and assurance layer. Optical Security and Performance Products reached $77.8 million in Q2, up 9.7%, though the strength there came more from anti-counterfeiting than from the optical buildout story.

*NSE vs OSP segment breakout (image 6 of 9)*
![[cruxcapitalgroup-viavi-an-overlooked-layer-006.png]]

On the balance sheet, VIAVI ended the quarter with $772.1 million of cash and short-term investments, exchanged about $103.5 million of converts for shares, and prepaid $100 million of its Term Loan B in January. Buybacks were paused to prioritize debt management. This is a business growing, cleaning up the balance sheet, and redirecting resources into faster parts of the portfolio simultaneously.

*Balance sheet / capital structure summary (image 7 of 9)*
![[cruxcapitalgroup-viavi-an-overlooked-layer-007.png]]

For Q3, revenue is guided at $386 million to $400 million, with NSE at $304 million to $316 million, operating margin around 19.7%, and EPS at $0.22 to $0.24. That guide lines up with management's commentary that data-center ecosystem momentum is continuing through calendar 2026 rather than fading after one strong quarter.

*Q3 FY26 guidance table (image 8 of 9)*
![[cruxcapitalgroup-viavi-an-overlooked-layer-008.png]]

---

### Spirent

The acquisition of Spirent's high-speed Ethernet and network security testing assets gives VIAVI more direct exposure to high-speed Ethernet, security validation, and channel emulation.

*Spirent integration & positioning (image 9 of 9)*
![[cruxcapitalgroup-viavi-an-overlooked-layer-009.png]]

Management previously said the acquired business would add roughly $180 million of NSE revenue in the first twelve months, and later suggested it was tracking closer to a $200 million annual run rate. In Q2, Spirent contributed $43 million, a little below earlier expectations because of timing, while Q3 guidance includes a full 13 weeks versus 10 weeks in Q2.

That does two useful things. It gives the AI data-center test story more weight in actual revenue terms, and it pushes VIAVI closer to the center of validation at the network and fabric level. The restructuring running alongside the integration points in the same direction. The plan affects about 5% of the global workforce and is expected to deliver about $30 million of annual savings by end of 2026, with about $16 million tied to Spirent synergies.

> "...if we look at where most of the cost is coming out, it's coming out of the slower or stagnant product segments. So it's really point here is to free up resources and put more wood behind the arrow on things like data center ecosystem, aerospace and defense..."

Portfolio reshaping around where the demand is actually moving, rather than generic cost cutting. I like that.

---

### The ecosystem angle strengthens the case

At MWC 2026, VIAVI highlighted collaborations with more than 20 partner organizations including AWS, NVIDIA, Nokia, Ericsson, Amphenol, Calnex, Infosys, GlobalLogic, and Rohde & Schwarz. At OFC 2026, it highlighted demonstrations with the Ethernet Alliance and Fiber Optic Center, plus interoperability work with Amphenol, Celestica, and other partners.

The role here goes beyond shipping stand-alone tools. VIAVI is trying to become embedded as a trusted validation and interoperability layer, especially in places where multiple vendors and multiple interfaces have to work together. Management described how hyperscaler behavior is changing around that dynamic.

> "...the hyperscalers are no longer content, just pay you the money, and you deliver the services and products. They are vertically integrating all the way back into their supply chain through either partnerships or strategic alliances..."

Hyperscalers getting more active in shaping the stack around them raises the value of companies that help validate that stack.

There is also a second growth lane in aerospace, defense, and resilient timing infrastructure. Management described resilient PNT as a major near-term defense driver, with strong demand around drones and autonomous systems, and connected timing back into the data-center story directly, describing scenarios where timing gets delivered closer to the rack itself as network speeds rise and synchronization requirements tighten. That linkage gives VIAVI a second growth engine running alongside the data-center ecosystem.

---

### The bottom line

Two comments from the call frame the forward picture well.

> "We now see the new each technology nodes turning over every two years. So you no longer, let's say, between 100 gig and 400 gig, you had 6 years. You really now have 2 years between 1.6 and 3.2."
>
> "We have a pretty good view, at least on the base demand from these type of activities, up to three quarters ahead."

Faster technology cycles and better-than-typical forward visibility in the same business is a strong combination. VIAVI is broader than a single-product bottleneck story. The deeper you go, though, the more coherent the direction looks. As AI clusters become more optical, more distributed, and more demanding to qualify, the layer that helps prove the network works becomes more valuable.

---

*The information provided is for informational purposes only and does not constitute investment advice, a recommendation, or an offer to buy or sell any securities. The author may hold a position in the securities mentioned. Readers should conduct their own due diligence and consult with a financial advisor before making investment decisions.*
