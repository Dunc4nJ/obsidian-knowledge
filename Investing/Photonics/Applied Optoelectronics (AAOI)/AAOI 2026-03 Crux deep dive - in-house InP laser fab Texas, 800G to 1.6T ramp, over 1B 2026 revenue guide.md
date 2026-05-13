---
created: 2026-05-13
published: 2026-03-28
description: Crux Capital's full thesis on AAOI — vertical-integrated InP laser fab in Sugar Land TX, 800G ramp Q2 2026 then 1.6T early Q3, $1B+ 2026 revenue guide and bull/base/bear of $350/$140/$50.
source: https://cruxcapitalgroup.substack.com/p/aaoi-deep-dive
type: thesis
authors: ["Crux Capital Group (@cruxcapitalgroup)"]
subsectors: [Optical components & engines]
---

# AAOI 2026-03 Crux deep dive — in-house InP laser fab Texas, 800G to 1.6T ramp, over 1B 2026 revenue guide

## Key Takeaways

- **Position structure**: Author started in low-$30s, slammed bid in low $60s after earnings call, added at $80s and $90s, trimmed at $100s, and now adds every dip to $85. Continues buying under 7x 2026 revenue projections; not a buyer above $90 today at $98 current.
- **Vertical integration moat**: AAOI manufactures **100% of its laser chips internally** in Sugar Land, Texas, using proprietary **MBE + MOCVD** processes — management claims this dual-process approach is unique in high-volume comms laser production. While [[Coherent (COHR)]] and [[Lumentum (LITE)]] just secured hyperscaler investments to build InP fab capacity, AAOI already has captive supply and will **not sell laser chips externally**.
- **Laser shortage tailwind**: CEO Thompson Lin says external buyers face **>1-year wait times** for the high-power narrow-linewidth lasers needed for 1.6T SiPh and CPO. Next-gen lasers are physically larger dies (more wafer real estate per laser), and China is "artificially restricting" InP substrate exports.
- **Dual-engine revenue**: 2025 split — CATV $245.1M (53.8% of rev, driven by DOCSIS 4.0 / 1.8GHz amp upgrade cycle, management sees >$300M annual) + data center $196M (+32% YoY, with 400G sales +141% YoY). 800G expected to dominate data center revenue **beginning Q2 2026**.
- **Massive 2026 orders already booked**: March 2026 — same hyperscaler placed $200M+ 1.6T order plus $53M+ 800G order. 800G ships Q2-Q3 2026; 1.6T ships Q3-Q4 2026 after qualification. Customer is asking for **>300,000 800G+1.6T units/month** — capacity-limited, not demand-limited.
- **US onshoring is the strategic shield**: $150M expansion in Sugar Land TX (210k sq ft new facility, summer 2026 completion). Automated lines mean US-made costs ~10-15% premium vs Asia, instead of the 30-40-50% premium manual competitors face. Target: **>55% of 800G+1.6T made in US by end of 2027**; <10% of component value sourced from China today.
- **Capacity ramp roadmap**: 90k units/mo 800G at YE 2025 → 138k Q2 2026 → **650k combined units/mo by Q4 2026** (420k 800G + 230k 1.6T) → 930k by Q4 2027 + 400k/mo ELSFP external lasers for CPO.
- **ELSFP for CPO**: External laser modules (300mW/400mW, originally developed for LiDAR) ramp to **400k/mo by end of 2027**. AAOI will keep all internal-fab InP lasers captive — not sold externally. Strategy is to own BOTH the external laser source AND the internal optical engine as architecture shifts CPO.
- **1.6T tech choice = SiPh, not EML/VCSEL**: AAOI's 1.6T OSFP 2xDR4 / 2xFR4 uses **silicon photonics with 3nm DSPs** — CFO Murry says "200G per lane … not based on EMLs or VCSEL technology. It's based on silicon photonics." Future roadmap: 400G/lane via **TFLN and TFLN+SiN modulators**, 3.2T via InP modulators (Alpha samples Q1 2027), 6.4T NPO/OBO+ELSFP Alpha samples Q1 2026 / Beta Q3 2026.
- **Automation milestones**: "Phase #3" automated production — 90%+ labor hour reduction, 35%+ cycle time reduction, <50 DPPM on multi-lane single-mode 800G. 800G and 1.6T share the **same production line** with same process (only final test differs).
- **Capital plan**: $216M cash YE 2025 + $500M ATM (~$250M already done) + $200M potential customer co-investment + CHIPS Act + Texas state funds + projected $150M+ 2026 profit. CFO: "I don't anticipate leaning entirely on equity like we have been."
- **Customer concentration risk**: Top 10 customers = 96.6% of 2025 revenue; Microsoft alone = 28.8%. Management targets **3 hyperscalers >10% each by end of 2026**. Amazon transaction agreement (March 2025) includes purchase warrant tied to up to **$4B in aggregate Amazon purchases over time**.
- **Margin trajectory**: Non-GAAP operating profitability returns in Q2 2026; full-year 2026 guide >$1B revenue with >$120M non-GAAP op profit. Transceiver gross margin target **35-38% by mid-2027** climbing to **>40% by Q4 2027**.
- **12-month valuation framework** (author's own):
  - Bull $350 = 7.5x FY27 rev $3.5B (everything goes right)
  - Base $140 = 5x FY27 rev $2.1B (strong ramp but capacity/demand falls short)
  - Bear $50 = 3x FY27 rev $1.2B (hyperscaler slowdown / geopolitical / qualification miss)
  - Author assumes additional 10-15% dilution layered on top.
- **Comparison flag on CPO disclosure quality**: Author notes [[Lumentum (LITE)]] discloses linewidth and RIN specs that AAOI does not — recommends the *Irrational Analysis* OFC writeup for closing that gap.
- **Industry overbuild risk**: [[Tower Semiconductor (TSEM)]] is increasing SiPh wafer capacity >5x by late 2026 — broader optical commoditization is the medium-term risk; AAOI's automated US lines + captive InP lasers are the defense.

## Original Content

Welcome to one of the most exciting companies in the market today.

[[Applied Optoelectronics (AAOI)|AAOI]] is currently up ~165% YTD.

In this report you are going to get many things.

It will start with an informal dialogue about my experience trading AAOI, my thesis, where I see the stock going, and how I position for it.

Then we will move into the formal report where we will dive into all things AAOI, from their vertical integration, to their business mix, their capacity ramp, their risks etc. This will read more like a presentation of everything the company is demonstrating, rather than my own take.

If you read this report in it's entirety, you will have a really great understanding of this company and you will either build or break your conviction.

SO let's dig in.

---

### Brain Dump

I first starting investing in AAOI back in January.

I posted my first deep dive at that time.

You can read it here if you'd like:

[The AAOI Setup: Domestic Capacity, 800G Ramps, 1.6T Pull — Gaetano, Jan 29 — cruxcapitalgroup.substack.com/p/the-aaoi-setup-domestic-capacity](https://cruxcapitalgroup.substack.com/p/the-aaoi-setup-domestic-capacity)

I really want to focus on one part in that report:

*"I own shares, and I plan to add as ramp proof accumulates. This is a high-volatility name where the scoreboard is operational execution, and I treat it that way"*

It would have been way more lucrative if I went and took a full position in the 30's rather than a starter position. And I could have flaunted it on X and talked about how I knew this company was poised for greatness.

But the reality is that I didn't know that.

And this was very much not the rhetoric around this company at the time.

AAOI largely missed out on the optics run up.

It traded at the same level in July 2025 as it did in January 2026.

*AAOI daily candles on NASDAQ via TradingView — flat through 2025 then near-vertical run from sub-$30 in Jan 2026 to ~$98 at time of writing.*
![[cruxcapitalgroup-aaoi-deep-dive-003.png]]

There was a reason for this.

The data center revenue visibility was much lower compared to companies like [[Lumentum (LITE)|LITE]]  and [[Coherent (COHR)|COHR]]

AAOI has stumbled in the past on execution.

They have a legacy CATV business that made up more than 50% of their revenue in 2025.

But this is what I DID see:

*"$AAOI has been on my radar for a long time. If you follow me, you know I'm drawn to businesses with a "boring" core and upside optionality that can reprice quickly when execution starts showing up in the numbers. For Applied Optoelectronics, that core has been CATV and broadband infrastructure, and the upside I'm underwriting is the AI data center optics stack."*

So I had this vision for what I thought the company COULD be.

But I'm not into sizing big and throwing a bunch of money at a vision and hoping that management executes.

Rather I like to place an initial buy, and then add on signs of things moving in the direction of fulfilling this vision.

And that's exactly what I've done.

I had my initial position in the 30's

While listening to the latest earning calls, as my literal jaw dropped (I swear), I slammed the ask in the low 60's.

I added again in the 80's and 90's.

Trimmed some in the 100's.

And now I add it every time it gets to $85.

As long as this story stays intact, I will continue to be a buyer under 7x 2026 rev projections.

And if they keep executing, getting more orders, qualifying orders, shipping orders, my willingness to pay a higher price will come to life.

*"This stock is up so much already! Why would you buy it at these levels?"*

I get a version of this question often.

To be clear, I am not a buyer above $90 TODAY.

That doesn't mean there won't be a decent R:R there, but for me I am already heavily positioned and can be more conservative on any adds.

To understand why there are buyers at these prices, you need to understand the potential here.

AAOI is currently trading at ~7x 2026 revenue (projected).

If you take management's word for it and they actually hit $387m/month mid 2027, you are looking at a >$3.5billion in total rev for 2027. And management's goal is to hit ~40% gross margins by the end of 2027.

Assume that AAOI still is valued at this 7x multiple on their 2026 guide (which would be low on the lower end if they exit 2026 > $1billion in rev) then when we enter 2027 with a (again, hypothetical) guide of >$3.5billion, are looking at a > $300 share price (not factoring in dilution). Currently at $98.

This is the bull case that gets investors so excited.

Again, I want to state that while this is all very encouraging, there is so much they need to execute correctly to get this right. And that's why this isn't trading at a higher multiple today. This is the BULL case. My base case would be more conservative, but this is just a mental framework on why people are eager on this one.

They still need to prove they can ramp capacity fast enough, qualify product, diversify customers, receive repeat orders, not the dilute shareholders constantly etc.

So this is the bet that anyone invested in this company takes.

If they consistently delay qualification and shipments, are unable to ramp capacity etc. then the market will punish the stock.

I have no predictions for what the price does next in the near term.

I believe it will be heavily influenced by the geopolitical/macro reality.

If the situation in the Middle East gets worse, it will continue to put downside pressure on all optics companies.

If that clears up, I would expect capital to flow back into the strongest in this sector.

Who knows how long that will take. So please plan accordingly.

If you want to see the levels I am interested in for AAOI  and other companies on my watchlist you can view them here:

[My Entire Watchlist — Gaetano, Mar 23 — cruxcapitalgroup.substack.com/p/my-entire-watchlist](https://cruxcapitalgroup.substack.com/p/my-entire-watchlist)

Alright, with all that laid out, let's dive into the report!

*The information provided is for informational purposes only and does not constitute investment advice, a recommendation, or an offer to buy or sell any securities. The author holds positions in securities mentioned. Readers should conduct their own due diligence and consult with a financial advisor before making investment decisions.*

---

Part 1: The Foundation - True Vertical Integration and Internal Lasers   
  
Let's start by looking at how AOI's manufacturing stack is built. They operate a deeply vertically integrated manufacturing model, supported by a global workforce of nearly 4,700 employees spread across facilities in Texas, Georgia, Taiwan and China. Across these locations, AOI controls the entire production lifecycle, explicitly noting that their "manufacturing process encompasses various steps from laser design and fabrication to complete optical system design and assembly".

They start at the very atomic level in Texas, utilizing proprietary Molecular Beam Epitaxy (MBE) and Metal Organic Chemical Vapor Deposition (MOCVD) reactors to execute the "growth of more highly strained crystals".

*If you want to learn more about this, read here:*

[AAOI thoughts on MBE — Gaetano, Mar 26 — cruxcapitalgroup.substack.com/p/aaoi-thoughts-on-mbe](https://cruxcapitalgroup.substack.com/p/aaoi-thoughts-on-mbe)

These raw materials are then processed into finished laser chips, with management confirming that all of their laser chips are manufactured in their facility in Sugar Land, Texas. From there, the bare chips are packaged into subassemblies and integrated into complex light engines, which combine lasers and photodiodes, and in some cases, driver electronics and/or signal amplifiers. Finally, these internal components are sent to their highly automated assembly lines to be built into high-speed data center transceivers and complete turn-key equipment.

*AAOI Global Operations slide — ~4,800 headcount across Houston TX (508 employees, 349,450 sq ft, laser chips + transceivers), Atlanta (64 employees, 36,000 sq ft CATV R&D), Taipei (1,274 employees, 755,690 sq ft, transceivers + CATV), and Ningbo (2,927 employees, 1,205,800 sq ft, transceivers + CATV).*
![[cruxcapitalgroup-aaoi-deep-dive-006.png]]

The technological foundation of this system is their proprietary laser fabrication process. While there are certainly other major players in the industry that manufacture advanced optical lasers, AOI has developed a distinct proficiency by utilizing a proprietary MBE and MOCVD approach. Management specifically notes that they "believe the use of both processes, and our knowledge of how to combine these processes with others to fabricate lasers is unique in our industry". The scientific advantage of MBE includes "a lower process temperature and the use of solid phase materials rather than gaseous sources to grow wafers and the growth of more highly strained crystals". These physical properties directly contribute to "longer operating lives of our lasers, improved laser efficiency and threshold current". However, because MBE has inherent limitations, such as the inability to use certain dopant materials (for example, Iron) and difficulties with crystal regrowth, AOI selectively utilizes MOCVD to ameliorate some of these disadvantages.

While the underlying science is not entirely exclusive to AOI, blending these two techniques requires mastering steps that are very complex, with numerous critical steps requiring highly precise control. To achieve this, AOI had to engineer numerous enhancements and modifications to standard MBE equipment. This steep technical learning curve gives them a distinct and highly reliable manufacturing edge. As management emphasizes, "To our knowledge, we are unique in incorporating MBE processes in the production of communications lasers in high volume, and believe it would be difficult and time-consuming for other vendors to replicate our production technology". This positions AOI with a theoretical advantage against the rest of the industry, who overwhelmingly rely on MOCVD.

*AAOI's Vertically Integrated stack — Design teams in US/Taiwan/China (600 engineers) → 100% in-house Light Engine laser fab in USA → in-house PCBA → in-house Manufacturing with Design-for-Automation → "Accelerating Time to Market From 2 years to 9 months."*
![[cruxcapitalgroup-aaoi-deep-dive-007.png]]

This internal laser capability is a critical asset in the current macroeconomic environment. As hyperscalers aggressively scale their AI data centers, the optical industry is facing a severe bottleneck, which CEO Thompson Lin explicitly described as a huge issue of laser shortage with wait times stretching to a year or longer for external buyers. This shortage is driven by a combination of physical and geopolitical factors. As the industry evolves toward 1.6T Silicon Photonics (SiPh) and Co-Packaged Optics (CPO), these architectures require ultra narrow linewidth high power lasers. Crucially, as CFO Stefan Murry explained, these next-generation lasers are "physically larger in size, significantly larger in size than the earlier generations of devices". This "die size" reality consumes far more wafer real estate, which directly limits how many lasers can be produced per batch and has implications on the amount of capacity that needs to be brought online across the industry. Also, the base material for these lasers, Indium Phosphide (InP), is facing unique supply chain constraints. Murry clarified that while the raw material itself is not rare, the industry is currently navigating a "geopolitical question of China artificially restricting certain exports" of InP substrates

*AAOI's automated production assembly diagram — 17 numbered in-house-developed processes (Eutectic, COS Inspection, W/B, D/B, Lens Coupling, SiPh Chip Assembly, Adhesive dispensing, Baseplate Assembly, FA Coupling, Mechanical Assembly, Housing & Screw, TRX Testing, Packaging Line, L/W, Laser Soldering, AWG Coupling, Box Sealing) — equipment developed in-house between 2016 and 2025.*
![[cruxcapitalgroup-aaoi-deep-dive-008.png]]

This is where AOI's specific market advantage crystallizes. While peers like [[Coherent (COHR)|Coherent]] and [[Lumentum (LITE)|Lumentum]] recently secured massive hyperscaler investments specifically for "indium phosphide fabrication plant capacity to make laser diodes", AOI's advantage lies in its captive internal supply. The company offers a secure, 100% U.S.-based source for what CFO Stefan Murry calls the industry's true "bottleneck", confirming again that all of their laser chips are manufactured in our facility in Sugar Land, Texas. To capitalize on this, AOI is actively upgrading its Texas fabrication lines.

While production is mostly three inch today, and going to four inch, management noted that most of the equipment is capable of doing six inch wafers as well to handle future scale. As AOI executes its plan to triple production of InP-related devices by the middle part of next year, they do not intend to sell these highly coveted components to external competitors. Instead, to guarantee they can fulfill their own massive transceiver ramp amidst acute industry shortages, management's plan is to be 100% in-source.

---

Part 2: The Dual-Engine Growth Story (Data Center AI and CATV Software)

AOI operates a diversified dual-engine business model. During 2025, the Cable Television (CATV) segment generated $245.1 million, representing 53.8% of the company's total revenue. This rapid expansion is driven by the industry-wide DOCSIS 4.0 and 1.8GHz amplifier upgrade cycle. AOI is actively capturing market share across a broadening base of multiple system operators (MSOs), expanding well beyond its primary customer. Driven by this momentum, management expects the CATV segment to exceed $300 million in annual revenue moving forward.

*AAOI Target Market Segments — Data Center (100G/400G/800G/1.6T optics, NPO/OBO/ELSFP), Broadband Access (analog lasers, CATV transceivers, DOCSIS 4.0 HFC OSP), Telecom/FTTH (10G/25G lasers for 5G front-haul, EML/DFB lasers for 10G EPON/XGS-PON OLT and ONU), Sensing (special-wavelength lasers for gas sensing, high-power narrow-linewidth lasers for FMCW LiDAR).*
![[cruxcapitalgroup-aaoi-deep-dive-009.png]]

A crucial element of this CATV expansion involves attaching software to their hardware deployments. AOI offers its QuantumLink and Quantum Bridge software suites, which transform traditional hardware into so-called smart amplifiers, featuring microprocessor controls embedded. Operators use these tools to gain enhanced remote management, visibility, and control over HFC network elements. By utilizing machine learning to analyze telemetry data in real time, MSOs can repair issues remotely or deploy crews proactively before network outages occur, effectively reducing operational costs and improving service quality. Because these tools can save a lot of operating expense, Lin emphasized that the integration of hardware and software and the management system is exactly why AOI is positioned "to become the number one supplier in cable TV". While management has avoided explicitly labeling this as a "recurring, high-margin" stream, they confirmed they anticipate that they will generate some revenue from their software solutions this year, establishing a sticky technological ecosystem that goes well beyond a simple one-time hardware sale.

*Datacenter TAM stacked-bar chart, Omdia High-Speed OC Forecast 2024-30 (Jan 2026) — total high-speed (100G+) TRx revenue rises from ~$22B (2024) to ~$32B (2025), ~$35B (2026), ~$41B (2027), ~$49B (2028), ~$55B (2029), ~$64B (2030); 1.2T/1.6T ramps from negligible in 2024 to the largest band by 2030, with 800G the dominant band through 2026-2028.*
![[cruxcapitalgroup-aaoi-deep-dive-010.png]]

Alongside the CATV business, the internet data center segment serves as the primary engine driving AOI's hyper-growth. This is why we are all here. Propelled by hyperscaler investments, AOI recognizes that the rapid adoption of artificial intelligence is fueling a new wave of investment by hyperscale data center operators, as AI computing is very compute and bandwidth intensive. As a result of this surging demand, data center revenue reached approximately $196 million in 2025, marking a 32% year-over-year increase. Currently, the existing 400G base remains an exceptionally strong foundation. Sales for the 400G product increased 141% year-over-year. While AOI expects continued strength in our 400G business, the impending architectural shift dictates the future. Moving forward, management projects a massive transition, explicitly stating that "800G is expected to dominate our revenue beginning in Q2" of 2026, officially becoming the largest contributor to the data center segment as hyperscalers aggressively expand their AI clusters

Combining a durable CATV business with rapidly scaling data center deployments materially strengthens AOI's financial profile. Management believes the company can generate nearly $300 million of annual CATV revenue if current momentum holds. That diversified base helps fund the bigger objective in AOI's roadmap which is the transition to 1.6T transceivers and, over time, CPO.

On the 1.6T side, management said shipments are expected to begin in early Q3 2026 following product qualification, with the ramp continuing through Q4. As volume builds, AOI has outlined a path toward much higher monthly revenue by mid-2027, including approximately $217 million from 800G, $71 million from 1.6T, and $90 million from legacy 100G and 400G products. At the same time, the company is positioning for future CPO architectures by scaling production of very high-power, very narrow-linewidth continuous-wave lasers, a capability it originally developed for LiDAR and is now adapting for data center applications.

To support this buildout, AOI is using the roughly $500 million raised/being raised through its expanded ATM program to aggressively fund AI optical capacity expansion. That capital directly supports management's broader growth targets and their stated ambition to build toward a $1 billion annual revenue business.

---

Part 3: Automation, Onshoring, and Tariff Shields

AOI derives its most significant operational advantage from its proprietary robotics, noting that its highly-automated production process provides distinct "advantages over many of our competitors in terms of ability to scale production rapidly." The company intentionally utilizes a "Design For Automation" philosophy across its optical platforms, ensuring that products are engineered from the ground up to be assembled by machines rather than humans. Based on their latest OFC presentation, AOI has evolved to what they classify as "Phase #3" automation, featuring a High-Volume (Closed-Loop) modern production line with minimal operator involvement.

This system integrates Automated Guided Vehicles (AGVs) and Autonomous Mobile Robots (AMRs) alongside a standardized magazine and fixture design integrated throughout the production process to achieve reliable automated in-process material transport. AOI elevates this physical robotics platform by embedding artificial intelligence directly into the manufacturing flow, utilizing a huge 9-year dataset for training neural networks to conduct full-process auto-inspection through machine learning and drive true AI-powered quality enhancement.

*AAOI Automated Production Roadmap Since 2016 — four phases. Phase #1 (FY2016): manual load/unload + manual material transport, ~8 human operators. Phase #2: manual load/unload (excluding module assembly), manual material transport, ~6 operators. Phase #3 Lite: automated load/unload via magazine, manual material transport via magazine, ~2 operators. Phase #3 (current): automated load/unload via magazine, automated material transport via magazine, ~1 operator.*
![[cruxcapitalgroup-aaoi-deep-dive-011.png]]

The operational results of this end-to-end automation are highly quantifiable. According to their latest engineering presentations, AOI has successfully decreased labor hours by 90%+ and reduced manufacturing cycle time by more than 35%. This precision process control yields exceptional quality, registering a defect rate of <50 Defective Parts Per Million (DPPM) specifically for its highly complex multi-lane single mode 800G. This automated architecture paves the way for the next-generation transition. Management confirmed that their "800G and 1.6T products can be manufactured on the same production line with the same process". While the 1.6T modules will require a different final testing, the core automated lines have been intentionally developed with an architecture that allows AOI to support future higher-speed products as customer demand materializes and evolves over time without having to completely rebuild their factory floors

*Automation Results slide — claims **"Automated Production is Largely Location-Agnostic, Minimizing Supply-Chain Risks for Customers"** — three KPIs: DPPM <<50 for multi-lane single-mode 800G TRx; reduced manufacturing cycle time by more than 35%; decreased labor hours by 90%+. Three facility photos show automated cells with yellow industrial robotics.*
![[cruxcapitalgroup-aaoi-deep-dive-012.png]]

This automation directly enables AOI's massive domestic onshoring initiative by making their production largely location-agnostic. Relying on conventional manual labor to manufacture complex optics in the United States carries a dramatic cost premium, with management estimating that competitors utilizing manual processes would likely face a "30, 40, 50%" financial penalty to operate domestically. In contrast, AOI leverages its automated lines to onshore production for a highly manageable premium, noting it costs "maybe 10% or 15% more to produce our products in the U.S. than it does in a similar production plant in Asia". Hyperscale customers seem to accept this modest premium with CFO Murry confirmed they have "very well received" this shift because they like the security in the US based supply chain and are willing to pay for that exact assurance.

*Sugar Land TX expansion slide — "October 28, 2025, Applied Optoelectronics, Inc. (AOI) announced a $150 million U.S. expansion in Sugar Land, Texas, including a new 210,000 sq. ft. manufacturing facility focused on AI datacenter optical transceivers, scheduled for completion by summer 2026. Once complete, AOI will have the largest AI-focused datacenter transceiver production capacity in the U.S." Aerial shots of existing Sugar Land HQ and the new 1111 Gillingham facility.*
![[cruxcapitalgroup-aaoi-deep-dive-013.png]]

To physically house this domestic capacity, AOI announced a $150 million U.S. expansion in Sugar Land, Texas, including a new 210,000 sq. ft. manufacturing facility focused on AI datacenter optical transceivers. Construction on this facility officially began in early 2026, targeting a summer 2026 completion. Once fully operational, management expects it will position AOI with "the largest AI-focused datacenter transceiver production capacity in the U.S.".

Bringing production to Texas serves as a profound strategic shield against geopolitical risks and shifting import tariffs. CFO Murry noted that hyperscalers are currently viewing their data center buildouts as an "existential opportunity or crisis," and because any single component shortage can derail a project, there is a "great deal of emphasis on supply chain integrity with our hyperscale customers".

AOI directly answers this demand, projecting that by end of next year more than 55% of 800G & 1.6T will be manufactured in U.S. Manufacturing internally in Texas heavily insulates AOI from external trade turbulence. For their highly sought-after 800G and 1.6T transceiver designs, Murry confirmed that "less than 10% of the value of these components used is currently sourced from China," and as they scale production, they have a path to further reduce that exposure to near zero. This physical transition directly mitigates financial headwinds. While AOI incurred a 3.1 million direct tariff impact on capital equipment in the fourth quarter of 2025, expanding domestic production eliminates these penalties moving forward, as Murry emphasized that "the one place where I'm pretty confident saying it's not gonna be tariffed is product that's made in the US".

---

Part 4: The Product Roadmap and The Order Influx

The immediate catalyst driving AOI's hyper-growth phase is the widespread deployment of 800G optics. During the fourth quarter of 2025, AOI successfully secured its first 800G volume order from one of their major hyperscale customers to support their rapidly expanding AI compute clusters. To ensure seamless interoperability across the customer's diverse network switch platforms, AOI's engineering team expects to finalize the firmware used in these modules in March. With the hardware already fully qualified, management views this software optimization as the final step, noting they have already begun ramping our production of these 800G modules in anticipation of a strong volume ramp starting in Q2.

This anticipated demand is now rapidly converting into verified financial commitments. In March 2026, AOI announced consecutive volume orders from this exact same hyperscale customer: a massive order for 1.6T transceivers totaling more than $200 million, followed shortly by an initial 800G volume order, totaling more than $53 million. Shipments for the 800G order are expected to start in the second quarter, and be completed by middle of the third quarter, 2026, while the 1.6T order is scheduled to begin early in the third quarter of 2026 and should be complete in Q4. Management explicitly noted the 800G commitment is expected to be the "first of more to come" as the customer scales. Meanwhile, the broader pipeline continues to expand aggressively as a new hyperscale customer has begun discussions about qualifying our 800G and 1.6T product just within the last few weeks.

Management characterizes current demand as exceptionally strong, noting that customers have provided "crazy numbers," indicating a desire to purchase "more than 300,000 of 800G plus 1.6T per month". As CEO Thompson Lin emphasized, the overall market demand is "much, much bigger" than current production capabilities, clarifying that the revenue ramp is currently "limited by our capacity and the supply chain. It's not limited by the customer demand".

*AAOI 1.6T Product Strategy slide — pairs 200G/lane 1.6T OSFP 2xDR4 and 2xFR4 modules with **3nm DSPs** on **silicon photonics**; sketch labels "Two high-power CW lasers feed SiPh chip" with arrows from external lasers into SiPh die.*
![[cruxcapitalgroup-aaoi-deep-dive-014.png]]

Advancing to the next generation of speeds requires a fundamental architectural evolution, which AOI details thoroughly in its Product Roadmap for Datacenter and AI Deployment. For the 1.6T generation, the industry is shifting to 200G-per-lane optics. CFO Murry confirmed this trajectory, stating that "200G per lane is certainly a part of our plan for 1.6T specifically," and noted that for AOI, "it's not based on EMLs or VCSEL technology. It's based on silicon photonics". AOI addresses this requirement with its 1.6T OSFP 2xDR4 and 2xFR4 transceiver configurations, which utilize advanced 3nm digital signal processors (DSPs) alongside SiPh.

This specific Silicon Photonics engineering choice yields profound material efficiencies. As CEO Thompson Lin pointed out, "If you're using silicon photonics, you only need two high-power CW lasers. That is a very good reason to use SiPh".

Looking slightly further ahead, AOI is actively developing 400G-per-lane optics to support even higher capacities. According to their roadmap, they are developing 1.6T OSFP DR4 (8:4) modules utilizing Thin-Film Lithium Niobate (TFLN) and TFLN combined with Silicon Nitride (SiN) modulators. They say they have a lot of experience with lithium niobate from other applications in the past. Alongside this, they have Alpha samples of their 3.2T OSFP 2xDR4 utilizing Indium Phosphide (InP) modulators scheduled for the first quarter of 2027. Also, management confirmed that this architectural evolution will not disrupt their automated manufacturing scaling.

AOI is also actively preparing for the industry shift toward 6.4T Co-Packaged Optics (CPO) and On-Board Optics (OBO). Their roadmap slates Alpha samples of their combined 6.4T NPO/OBO + ELSFP modules for the first quarter of 2026, followed by Beta samples in the third quarter.

Future CPO and Silicon Photonics architectures require external light sources because the lasers get very hot locally and have a reliability profile less than some of the other components in the system. AOI is specifically addressing this by producing External Laser Small Form Factor Pluggable (ELSFP) modules operating at 300mW and 400mW, which allows the lasers to be taken outside where they can be swapped out as necessary without disrupting the internal switch fabric. To engineer this critical very high power, very narrow linewidth laser, AOI has repurposed sophisticated technology they actually developed for LiDAR applications some time ago.

According to their latest capacity roadmap, management expects to scale production of these ELSFP modules to a massive 400,000 pieces per month the end of 2027. Crucially, while the broader industry faces severe laser shortages, AOI intends to fabricate the underlying Indium Phosphide lasers for these devices entirely in-house at their Texas facility. Management explicitly stated, "we don't anticipate selling that. We're going to use it pretty much for the in house production," allowing AOI to effectively capture the full value and margin of the industry's most critical AI networking bottleneck

---

Part 5: The Ultimate Capacity Ramp and Financial Projections

*AAOI Capacity Ramp Plan for AI Datacenter Transceivers and CPO — monthly capacity targets by product line:*

| Product | Q2 2026 | Q4 2026 | Q2 2027 | Q4 2027 |
|---|---|---|---|---|
| 100G QSFP28 NRZ Optics | 140K/mo | 140K/mo | 140K/mo | 140K/mo |
| 400G QSFP-DD PAM4 Optics | 140K/mo | 210K/mo | 310K/mo | 310K/mo |
| 400G/200G/100G Active Optic Cable | 35K/mo | 35K/mo | 45K/mo | 70K/mo |
| 800G OSFP PAM4 Optics | 138K/mo | 420K/mo | 550K/mo | 550K/mo |
| 1.6T OSFP PAM4 Optics | 10K/mo | 230K/mo | 230K/mo | 380K/mo |
| ELSFP Module 300mW/400mW | — | 5K/mo | 50K/mo | 400K/mo |

![[cruxcapitalgroup-aaoi-deep-dive-015.png]]

AOI is under taking a massive, meticulously planned manufacturing expansion to meet an environment where demand for 800G modules are projected to exceed their production capacity through mid-2027. To capture this surging demand, the company outlined highly precise production targets in its recent Capacity Ramp Plan. They successfully neared their target of 100,000 units per month of 800G capacity with approximately 90,000 units per month of 800G capacity at year-end in 2025. According to their roadmap, AOI expects to scale its 800G output to 138,000 units per month by the second quarter of 2026. By the fourth quarter of 2026, AOI targets an immense 650,000 combined next-generation units per month, explicitly consisting of 420,000 800G transceivers and 230,000 1.6T transceivers. Looking further ahead to the fourth quarter of 2027, AOI plans to scale this output to an extraordinary 930,000 combined units per month, scaling alongside a targeted 400,000 pieces per month of ELSFP modules dedicated to future CPO.

AOI utilizes a highly strategic geographic phasing strategy to achieve these aggressive milestones. CFO Murry explained that "the initial phase of that is largely gonna be concentrated in our Taiwan facility because it's quicker for us to build capacity in Taiwan than it is in the U.S.". However, as the timeline progresses, the dynamic shifts. As they get through 2026 and into 2027, the bulk of the additional capacity that's coming online is gonna be in the U.S. To physically house this they signed an agreement to lease an additional building in Sugar Land, adding a new 210,000 sq. ft. manufacturing facility that brings their total domestic manufacturing footprint to nearly 350,000 square feet.

To finance this robust industrial buildout, AOI implements a multi-tiered capital allocation plan. Recognizing the sheer scale of customer demand, the company aggressively accelerated its investments. In 2025, they made a total of $209 million in capex which came in well about their initial estimates. To fund the upcoming 2026 expansion, AOI ended the year with $216 million in cash and is in the process of executing $500m in its ATM offering (250m already done)

However, management intends to supplement this equity capital by actively advancing alternative funding channels to structurally de-risk the buildout. Murry said, "I don't anticipate leaning entirely on equity like we have been. We're also looking at our customers for contributions there, whether it be in terms of prepayments on orders or other ways of helping to de risk some of this expansion". Specifically, CEO Thompson Lin revealed the company is in discussions with major customers regarding a potential "$200 million" co-investment to support the U.S. capacity scale-up. AOI is actively collaborating with the state of Texas and pursuing U.S. government CHIPS Act funding, with Lin noting they expect to "get some good money from both Texas State and the U.S. government". Finally, management noted that their anticipated transition to generating more than $150 million in net profits in 2026 means that some of the expansion can be paid by their profit.

This physical capacity expansion translates into a profound financial inflection point. As new equipment comes online and begins fulfilling massive customer commitments, management expects to move towards sustainable profitability, which they currently expect to achieve on a non-GAAP basis beginning in Q2 of this year. For the full year 2026, AOI anticipates total revenue to surge, as they expect to generate over $1 billion in revenue this year with a non-GAAP operating profit of over $120 million.

As their revenue scales and the product mix heavily shifts toward these premium architectures that we have laid out, Lin expects overall transceiver profitability to climb, stating "we believe the overall gross margin will be 35%-38% just for transceiver" by mid-2027, before ultimately expanding to their long-term target as they believe they can achieve more than 40% gross margin for all the transceiver by Q4 2027".

---

Part 6: Stress Testing the Thesis and Execution Checkpoints

While the current demand landscape for AOI is unprecedented, converting that demand into recognized revenue requires precise industrial execution. The immediate checkpoint is the successful completion of 800G firmware optimizations, which management expects to finalize in March to ensure seamless interoperability across diverse network switch platforms. Furthermore, while AOI secured a massive $200 million volume order for 1.6T transceivers, those shipments are explicitly contingent upon successful product qualifications before they commence in early Q3 2026. We must closely monitor whether the newly expanded Texas facility achieves full qualification for these additional high-speed products by mid-year 2026, as this milestone dictates the company's ability to physically fulfill its massive U.S. manufacturing commitments.

Historically, AOI has operated with intense customer concentration, which introduces volatility to the business model. During 2025, the company's top ten customers accounted for 96.6% of total revenue, with Microsoft alone representing 28.8% of the business. However, this risk profile is actively evolving as the customer pipeline expands. Management explicitly targets exiting 2026 with three distinct hyperscale data center customers each contributing more than 10% of total revenue. The strategic relevance of AOI to these top-tier players is validated by a transaction agreement signed with Amazon in March 2025, which included a purchase warrant tied to up to $4 billion in aggregate Amazon purchases over time. Tracking the conversion of these specific hyperscaler relationships into verified, recurring volume orders remains a critical metric for validating the long-term thesis.

Looking toward the medium term, the broader optical industry faces the inherent macroeconomic risk of an eventual supply overbuild. Competitors and foundries are aggressively adding manufacturing infrastructure, highlighted by [[Tower Semiconductor (TSEM)|Tower Semiconductor]]'s plan to increase its silicon photonics wafer capacity more than fivefold by late 2026. AOI's primary defense against this structural industry risk relies heavily on its highly automated assembly architecture and its captive internal laser supply. By deliberately hoarding its self-manufactured Indium Phosphide lasers to guarantee internal module production, AOI works to insulate itself from supply chain bottlenecks. Combining this component control with location-agnostic robotics positions AOI to protect its pricing power and seamlessly march toward its long-term gross margin target of 40%, even if the broader optical market eventually experiences commoditization and aggressive pricing headwinds.

---

Part 7: CPO and the Move Inward

In a few years CPO will be the next chapter of the AOI story, but it is not the current revenue engine. The current revenue engine is still the ramp in plug-in transceivers: 800G first, then 1.6T. Management has said 800G should become the largest contributor within data center revenue beginning in Q2 2026, with 1.6T following later in the year. AOI's own capacity plan shows the same sequencing. By Q4 2026, the company is targeting monthly capacity of 420,000 units for 800G and 230,000 units for 1.6T, versus only 5,000 units for its external laser modules used in future CPO systems. The larger CPO-related ramp does not show up until 2027, when that external-laser capacity rises to 50,000 units per month by Q2 and 400,000 units per month by Q4.

The technical path into CPO is already visible in the roadmap. AOI's 1.6T products are moving onto silicon photonics, which management says is the direction of the future product stack. That matters because silicon photonics needs a separate high-power, narrow-linewidth continuous-wave laser to feed the photonic chip. In other words, AOI's move from 800G to 1.6T is not separate from the CPO story. It is the bridge into it. The roadmap then extends from today's plug-in modules toward 6.4T systems, where AOI shows near-packaged or onboard optics paired with an external laser source. Alpha samples for that 6.4T platform are shown for Q1 2026, with beta samples in Q3 2026.

AOI's specific CPO product is its ELSFP, an external laser module offered in 300mW and 400mW versions. Management describes the underlying device as a very high-power, very narrow-linewidth laser that AOI originally developed for LiDAR and is now repurposing for CPO. The logic for moving that laser outside the switch is straightforward as lasers run hotter and have a weaker reliability profile than much of the rest of the system, so customers prefer them to remain replaceable instead of buried deep inside the switch. Management also made clear that AOI is not trying to participate in this market only as a laser merchant. They said they intend to make both the external laser module and the internal optical engine that sits inside the system.

That is the strategic importance of CPO for AOI. In the traditional model, AOI sells the full plug-in transceiver. In the future CPO model, the optical value moves inward and gets split between the external laser source and the internal optical engine. AOI is trying to hold onto both pieces. What is still missing from the public record is the exact revenue math. Management has disclosed rough pricing for today's plug-in products, with 800G around the $400 range and 1.6T around $700 to $800, but it has not yet disclosed pricing for the ELSFP or the internal 6.4T optics What we do know is that AOI is positioning itself to remain relevant as the architecture changes. The near-term numbers still come from 800G and 1.6T. CPO is what keeps the story alive after that.

It's also important to note that, as with a most of these companies, we are lacking some critical details on the CPO front. While [[Lumentum (LITE)|Lumentum]] is very forthcoming about really strong details regarding line width and RIN, these are absent (as far as I can tell) from AAOI's disclosures. Seeing these details can really give us a picture of just how powerful of a player AAOI can be in this space. If you are curious to learn more about this I recommend reading 'Irrational Analysis' Substack post on OFC.

---

Part 8: Key Risk Factors

While the narrative surrounding AOI's AI optical ramp is highly compelling, the company operates in a capital-intensive, cyclical industry with a heavily concentrated customer base. Management has outlined aggressive expansion targets, but we must closely monitor the formal risks that could derail this trajectory.

Execution of the Massive U.S. CapEx Buildout

To capture the incoming 800G and 1.6T demand, AOI is executing a massive expansion of its Texas facilities. There's a possibility that these significant capital investments in U.S. manufacturing and automation may not achieve expected returns. These projects involve long lead times and complex execution, and a significant portion of these investments is heavily predicated on their expectations regarding the rapid growth of AI-driven demand. If this AI adoption slows, stalls, or follows a trajectory that differs from their planning assumptions, the company could be left with severe overcapacity and negative operating leverage. Because AOI utilizes a deeply vertically integrated model, they carry a high fixed cost base, making it difficult to adjust expenses quickly if market conditions rapidly deteriorate.

Product Qualification Timelines and Firmware Hurdles

In the optical industry, an announced volume order does not immediately translate to recognized revenue. AOI must first successfully navigate complex qualification cycles, which involve stringent product sampling, reliability testing, and firmware interoperability tuning. Management notes that because of the complexity of these next-generation designs, "it may take 18 months or longer before we receive our first order," meaning the company incurs significant research and development expenses long before they recognize any financial benefit. As seen recently with their 800G modules, even after hardware is qualified, firmware optimizations required to ensure interoperability across diverse network switch platforms can delay volume shipments. If AOI is unable to accurately predict these timelines, or fails to qualify new products entirely, their ability to generate revenue could be delayed or the revenue would be lower than expected.

Capital Requirements and Dilution Risk

Building out domestic infrastructure is highly capital intensive. Driven by surging customer forecasts, AOI spent $209 million on CAPEX in 2025, well above their initial estimates. To fund this rapid expansion, the company carries $163.8 million in consolidated indebtedness and heavily utilizes At-The-Market (ATM) equity offerings. In early 2026, they expanded their ATM program to an aggregate $500 million, selling approximately $250 million in shares within days. While management is actively pursuing alternative funding like customer co-investments and CHIPS Act grants, they warn that if they must continue to "raise additional funds through the issuance of our common stock or convertible securities, the ownership interests of our stockholders could be significantly diluted".

Geopolitical Trade Tensions and Tariffs

Despite AOI's aggressive push to onshore manufacturing to Texas, the company remains highly exposed to geopolitical friction. They still maintain massive manufacturing operations and a large workforce in Taiwan and China, making them vulnerable to any escalating military, political, or economic conditions in Asia. Furthermore, shifting U.S. trade policies and tariffs pose a direct threat to margins. In the fourth quarter of 2025 alone, direct tariffs caused a $1.2 million impact on AOI's income statement and a $3.1 million impact on their imported capital equipment. Although management notes that less than 10% of the underlying component value in their 800G and 1.6T transceivers currently originates from China, they caution that unpredictable changes to import/export regulations, tariffs, or trade barriers could "increase our costs, disrupt our supply chain, affect customer demand, reduce our margins, and otherwise adversely affect our business".

---

Part 9: Valuation framework

If you have made it this far, you are rewarded with my valuation framework!

While I loosely described a bull case scenario in 12 months of >$300 share price, I also want to include a base case and bear case.

My 12 month **~$350 bull** case is predicated on a 7.5x FY 2027 revenue estimate of $3.5billion. Everything would have to go right here. Qualifications happen on time, customers are diversified, they continue to take on recurring orders, that successfully bring capacity online, and demand stays outpacing capacity.

My 12 month **base case of $140** is predicated on a 5x FY 2027 revenue estimate of $2.1 billion. This assumes the ramp is going strongly, but either they can't buildout as much capacity as they are projecting or overall market supply comes online and demand isn't as aggressive as it is today.

My 12 month **bear case of $50** is predicated on a 3x FY 2027 revenue estimate of $1.2 billion. This assumes hyperscaler spend has slowed, geopolitical risk is heavily weighing on the market, data center buildout plateaus, or management fails to build capacity, hit qualification markers, and capture the demand.

Keep in mind that none of these factors account for dilution which I would assume to be an additional 10-15% throughout the next 12 months.

*The information provided is for informational purposes only and does not constitute investment advice, a recommendation, or an offer to buy or sell any securities. The author holds positions in securities mentioned. Readers should conduct their own due diligence and consult with a financial advisor before making investment decisions.*
