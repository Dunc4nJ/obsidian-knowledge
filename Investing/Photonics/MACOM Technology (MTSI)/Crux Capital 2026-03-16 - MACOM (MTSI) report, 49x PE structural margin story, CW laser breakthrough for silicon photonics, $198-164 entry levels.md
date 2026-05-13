---
created: 2026-05-13
published: 2026-03-16
description: Crux's deep-dive on [[MACOM Technology (MTSI)]] — three businesses (defense 43 pct, data center 30 pct fastest-growing, telecom 27 pct), CW laser breakthrough for silicon photonics in formal qual, 49x forward PE rich but justified by structural margin expansion and dual AI+defense engines; Crux's personal entry levels $198/$180/$164.
source: https://cruxcapitalgroup.substack.com/p/macom-mtsi-report
type: thesis
authors: ["Crux Capital Group (@cruxcapitalgroup)"]
---

# Crux Capital 2026-03-16 — MACOM (MTSI) full report

A comprehensive thesis on [[MACOM Technology (MTSI)]]: the analog-semi layer behind 800G/1.6T optical transceivers, plus a defense GaN backbone and an emerging silicon-photonics laser story. Crux argues it's a genuine compounder but at $217.80 (~49x forward EPS, ~14.6x EV/S, ~46x EV/EBITDA) the base case is roughly fairly valued — author waits for $198/$180/$164 entry levels.

## Key Takeaways

- **MACOM = analog chips between photons and electrons.** TIAs, laser drivers, modulator drivers, photodetectors inside 400G/800G/1.6T transceivers. Plus GaN RF for defense, plus telecom.
- **Three businesses in one:**
  - **Industrial & Defense (~43% of revenue, Q1 FY26 $117.7M record):** GaN-on-SiC power amps to Raytheon/Northrop/Lockheed/L3Harris. DoD Cat 1A Trusted Foundry status at two fabs. Counter-drone identified as new growth driver. HRL T3L 40nm GaN exclusive license (>40GHz capability) + 150nm GaN ALD hermetic coating opens airborne radar. Wolfspeed RF acquisition added NC fab + 1,400 patents + ~$150M annual defense revenue. GaN >50% YoY late 2025.
  - **Data Center (~30%, Q1 FY26 $85.8M record, fastest-growing):** Tier 2 to optical module makers (not direct to NVDA/GOOGL/MSFT). Content per module grows each generation. **CW lasers for silicon photonics = new product category.** Etched Facet Technology (EFT, from BinOptics acq) enables wafer-level InP laser manufacture/test. >100M shipped, two customers confirmed 75mW CW lasers meet electricals, now in formal qualification. 200G/lane photodetectors ramping. **March 12, 2026: industry-first PCIe 7.0 linear equalizers (MAEQ-39964/39966)** — copper extension play hedges optical concentration. Guide: 35-40% YoY FY26, demand visible into CY2027.
  - **Telecom (~27%, Q1 FY26 $68.1M stable):** 5G base stations (GaN), fronthaul EML drivers, cable MSO DOCSIS. **LEO satellite underappreciated** — $55M contract entering production H2 2026, mgmt said "hundreds of millions over time," engaged with almost all major LEO constellations. A competitor exiting 5G RF GaN — MACOM hired their engineering team. Two new IC design centers opening (SoCal + Central Europe).
- **Vertical integration moat is asymmetric.** vs fabless analog rivals ([[Marvell Technology (MRVL)]]/Inphi, [[Semtech (SMTC)]], [[MaxLinear (MXL)]]) MACOM owns compound-semi fabs — manufacturing control, cost edge. vs [[Lumentum (LITE)]] / [[Coherent (COHR)]] (own InP fabs, both customers AND competitors) the integration edge narrows. **CW lasers for SiPh is MACOM's hardest-to-replicate edge.**
- **LPO: founding member of standard, three hyperscalers in active production, LPO customer base tripled in past year.** Customers now evaluating LRO with 200G/lane chips for 1.6T.
- **Structural margin expansion:** 53% (2019) → 57-58% adj GM today, guide 25-50 bps sequential improvement, high 58-59% target by FY26 year-end. 200+ new products launched in FY25, products <3 years old grow faster AND are margin-accretive.
- **Cash flow underappreciated:** $208M deferred tax assets → 3% adj tax rate in Q1 FY26 → minimal cash taxes for years. FY25 FCF $193M vs GAAP net income (depressed by acquisition amortization).
- **Risks:** (1) 49x forward EPS leaves no cushion, (2) data center cycle volatility — mgmt calls it "most volatile end market," (3) Marvell Perseus 5nm monolithic DSP+TIA+driver could shrink TAM, (4) CPO architecture shift — mgmt argues CPO is net positive (more channels → more complexity → more SiPh → more CW lasers), (5) top-10 customers = ~60% of revenue, (6) $345M five-year fab modernization plan = execution risk.

### Crux's Personal Entry Levels (NOT financial advice)
- **~$198** = aggressive buy
- **~$180** = moderate risk buy
- **~$164** = conservative risk buy

### Valuation Scenarios (NTM)
- **Bear** $125-$145: DC growth decelerates <20%, book-to-bill <1.0x, margin expansion stalls. Multiple compresses toward defense floor.
- **Base** $200-$240: midpoint of 35-40% DC guide, GM toward high 58-59%, B-to-B holds >1.0x, defense GaN steady, CW laser qual progresses.
- **Bull** $260-$300: DC ahead of 35-40% guide, 200G PD ramp quantified, defense GaN sustains 30%+, GM 60%+, **CW laser revenue starts showing up** in FY27. Stock briefly hit $260 last week before pulling back.

### What to Watch Every Quarter
- **Progress markers:** DC quarterly revenue >$90M, book-to-bill ≥1.2x, adj GM ≥58% and expanding, CEO commentary on 1.6T ramps/named customers, **InP/CW laser called out as material growth driver**, defense GaN sustaining 30%+ YoY.
- **Warning signs:** DC growth <20% YoY, language hinting Perseus traction ("customers evaluating integrated DSP"), book-to-bill <1.0x, flat/declining margin guide, hyperscaler capex cuts from [[Meta Platforms (META)]]/[[Microsoft (MSFT)]]/[[Alphabet (GOOGL)]]/[[Amazon (AMZN)]], single customer approaches 25%+ of revenue.

## Original Content

### THESIS

There's a company sitting inside many of the 800G optical transceiver powering AI datacenters right now. Most investors have never heard of it. I practically never hear about it discussed on X. It makes the tiny analog chips that sit between the light and the electronics, the components that convert optical signals into electrical ones and back again with enough speed and precision to keep massive GPU clusters running at full bandwidth.

That company is MACOM Technology Solutions (Nasdaq: MTSI).

MTSI is a genuinely excellent company doing something very important. It's the analog semiconductor layer that makes high-speed optical networking work, and high-speed optical networking is the foundation of every AI cluster being built today. It combines this growth exposure with a stable defense business and proprietary manufacturing capabilities.

It is also exposed to the world of copper, which I believe is a good hedge in a way to a portfolio comprised largely of pure-play optics companies.

The honest challenge, like most of the companies in this industry, is the valuation. At $217.80 and nearly 50x forward earnings, a lot of this excellence is already priced in. The base case, where management hits its guidance, margins expand as guided, and the 1.6T cycle plays out as expected, implies you're roughly paying fair value today. The bull case is genuinely exciting and would reward current investors well. The bear case is uncomfortably large.

This is a stock that rewards conviction. If you believe AI infrastructure spending is durable into 2027 and beyond, that silicon photonics adoption accelerates MACOM's laser content story, and that the management team continues executing, the current price could look like a reasonable entry in two years. If any of those assumptions prove wrong, the downside from a 49x multiple is significant.

For me personally, I am interested in building a position at a lower price.

~$198 would represent an aggressive buy for my portfolio.

~$180 would represent moderate risk buy for my portfolio.

~$164 would represent conservative risk buy for my portfolio.

These numbers are subject to change of course as new information comes in. But where I stand today, and how unpredictable the macro environment is, this holds true. Also, please keep in mind that just because these are my levels does not mean that I believe the stock WILL hit them. This is just reflective of my own portfolio and how aggressively I am already positioned.

It generated $967 million in its last fiscal year (FY2025) and is now running at close to a $1.1 billion annualized pace, has a market cap of roughly $16.3 billion, and trades at about $217 per share. Its stock has roughly doubled in the last year, which means either the market has recently figured something out, or it has gotten ahead of itself. Probably a little of both.

This report explains what MACOM actually does, why I am excited about it, what the real risks are, how I view the valuation models, and whether there's anything left on the table at the current price.

*A reminder as always, none of this is financial advice. Nor is it a recommendation. This is solely for educational purposes.*

---

### What Does MACOM Actually Do?

When data travels through a fiber optic cable, it travels as pulses of light. At some point, that light has to be converted into an electrical signal that a computer can process. And before it goes back into the fiber, an electrical signal has to be converted back into light.

That conversion process (light to electricity, electricity to light) requires extraordinarily precise analog chips. These chips have to operate at speeds measured in hundreds of gigabits per second. They have to maintain signal integrity across temperature swings, power fluctuations, and extremely tight noise budgets. Getting them wrong means data errors. Getting them right means the optical link works.

MACOM makes those chips. They're called transimpedance amplifiers (TIAs), laser drivers, modulator drivers, and photodetectors. They go inside optical transceivers which are the pluggable modules that attach to switches and servers and send data down fiber at 400G, 800G, and now 1.6 terabits per second.

But MACOM is more than just an optical company. It also makes gallium nitride (GaN) power amplifiers that go into military radar systems, electronic warfare platforms, and satellite communications. This defense business is actually the company's largest revenue segment today and has been the financial backbone of the company for decades.

So MACOM is really three businesses in one:

1. A defense/RF compounder
2. A datacenter optical supplier
3. A telecom infrastructure supplier

---

### How MACOM Makes Money

MACOM breaks its revenue into three segments. Here's what each one actually is, and how it's performing right now.

---

#### Segment 1: Industrial & Defense (~43% of Revenue)

This is the original MACOM. Seventy-plus years of RF and microwave heritage, supplying amplifiers, chips, and modules to defense primes like Raytheon, Northrop Grumman, Lockheed Martin, and L3Harris.The core products here are GaN-on-SiC power amplifiers which are gallium nitride chips that convert DC power into high-frequency RF power for radar transmitters, electronic warfare jammers, and satellite uplinks. These products operate at power levels ranging from 2 watts all the way to 7,000+ watts, across frequency ranges that go up to and beyond 100 GHz.

Why defense is important:

* Long product lifecycles (often 10–20+ years). When MACOM wins a design in a radar program, it gets revenue from that program for a very long time.
* High switching costs. Defense primes can't easily change chip suppliers mid-program. The qualification process takes years.
* Regulatory moat. MACOM holds a DoD Category 1A Trusted Foundry designation at two of its fabs, meaning the government can send classified chip designs there. Only a handful of U.S. facilities have this certification. It's not easy to get and not easy to replicate.
* GaN components in defense grew more than 50% year-over-year in late 2025.

The new defense driver is Counter-drone systems. The threat from commercial drones (and increasingly armed drones, as we are seeing play out in real time in the Middle East) is driving entirely new platform development across U.S. and allied militaries. CEO Stephen Daly explicitly cited counter-drone as a new growth category in 2026. MACOM's wideband GaN amplifiers are well-positioned for the detection and jamming systems these platforms require.

Two other defense developments worth knowing about:

First, MACOM secured an exclusive license for HRL Laboratories' 40nm GaN-on-SiC process (known as T3L) originally developed with DARPA funding. This gives MACOM an elite manufacturing capability for ultra-high frequencies above 40 GHz, which is precisely where next-generation defense radar, electronic warfare, and satellite programs are heading. Very few companies in the world can make chips at these frequencies.

Second, MACOM upgraded its 150nm GaN process with an ALD (Atomic Layer Deposition) hermetic coating, which allows chips to pass strict moisture resistance tests. This opens up the airborne radar market which is a lucrative application segment that was previously inaccessible due to environmental sealing requirements.

MACOM also recently acquired the RF business of Wolfspeed (the GaN company that subsequently ran into serious financial difficulty in its power electronics division). That acquisition added a manufacturing fab in North Carolina, 1,400+ patents, and roughly $150 million in annualized defense revenue.

Q1 FY2026 I&D revenue: $117.7 million (a new record)

---

#### Segment 2: Data Center (~30% of Revenue, fastest growing)

This is the AI infrastructure story, and what most of my subscribers probably care about.

Every GPU cluster needs optical interconnects. Every optical transceiver needs the type of components that MACOM makes. The more GPUs in a cluster, the more bandwidth is required between them, and the more bandwidth means more optical modules, and more optical modules means more MACOM chips.

MACOM doesn't sell to NVIDIA or Google or Microsoft directly, but rather it sells to optical module manufacturers companies who assemble the actual transceiver modules that plug into datacenter switches. Inside these modules are MACOM's TIAs, laser drivers, lasers, and photodetectors.

Think of it like this: MACOM is the Tier 2 supplier. It sells components to Tier 1 module makers, who sell finished modules to hyperscalers.

The industry is currently in the middle of a transition from 400G modules to 800G modules to 1.6T modules. Each generation requires faster, more sophisticated chips. MACOM's content per module increases with each generation. More chips, higher-performance chips, and now an entirely new product category.

CW lasers for silicon photonics. Silicon photonics (SiPh) is a chip manufacturing approach where optical components are built on standard silicon wafers. The problem, as we discuss often, is that silicon can't generate light. So every SiPh-based optical module needs an external continuous wave (CW) laser to provide the light source. MACOM makes these lasers using its proprietary Etched Facet Technology (EFT) which is a patented process developed from its acquisition of a company called BinOptics that allows InP lasers to be manufactured and tested at the wafer level rather than piece by piece. MACOM has shipped over 100 million of these lasers with extremely high reliability.

As silicon photonics adoption accelerates at 1.6T (and will likely dominate at 3.2T), the demand for CW lasers grows substantially. MACOM is one of very few companies capable of making them at scale. CEO Daly called the cloud customer recognition of MACOM's laser manufacturing capabilities a "breakthrough" in late 2025. As of Q1 FY2026, two customers have confirmed MACOM's 75-milliwatt CW lasers meet their electrical requirements, and those chips are now moving into the formal qualification phase which is the step before production ramp.

On the detector side MACOM is seeing rapidly growing demand for its 200G-per-lane photodetectors to support 800G and 1.6T modules, and is actively adding manufacturing capacity to meet that demand.

And in a brand new development as of March 12, 2026, MACOM announced the industry's first PCIe 7.0–optimized linear equalizers (MAEQ-39964 and MAEQ-39966). These chips extend the reach of passive copper cables at 128 GT/s which is supporting next-generation PCIe 7.0, PCIe 6.0, and CXL connections inside AI servers. The takeaway with this update is that MACOM is helping push copper further and further. So MACOM isn't only an optical play, they are expanding into the copper interconnect layer inside AI server racks with a new product category with its own growing customer base. I like having some exposure to companies extending copper to help hedge against my heavy optical concentration.

Management guidance for Data Center:

* 35–40% year-over-year growth for full fiscal year 2026
* Design wins confirmed at all major optical module manufacturers for 800G and/or 1.6T
* Demand visible into calendar 2027

Q1 FY2026 Data Center revenue: $85.8 million (a new record)

---

#### Segment 3: Telecom (~27% of Revenue)

Telecom is the cyclical one. Carrier infrastructure spending (5G base stations, fiber backhaul, cable MSO upgrades) goes through boom-and-bust cycles tied to carrier capital expenditure budgets, and MACOM feels those cycles directly.

After a painful downturn in 2023–2024 when carriers dramatically cut capex following their initial 5G buildout spending, telecom has been recovering. MACOM supplies GaN amplifiers for 5G base stations, EML drivers for fronthaul fiber, and analog ICs for cable MSO DOCSIS upgrades.

Two emerging telecom stories worth watching closely:

LEO satellite. This is a very underappreciated part of MACOM's story right now. Low Earth Orbit satellite constellations (think Starlink, Amazon's Kuiper, and others) need semiconductors for direct-to-device links, free space optical communications, and on-satellite data centers. MACOM is engaged with almost all major LEO constellations and has a $55 million satellite contract entering production in the second half of 2026. Management has described the LEO satellite market as worth "hundreds of millions of dollars" to MACOM over time. This is a potentially transformational revenue stream that doesn't get nearly enough attention.

5G GaN market share gain. A competitor is exiting the 5G RF power GaN market (CEO Steve Daly called it a "fortunate stroke of serendipity") and MACOM has already hired a team of engineers from that competitor to aggressively capture the available market share. More broadly, to support its expanding AI and defense pipeline, MACOM is opening two new IC design centers (one in Southern California and one in Central Europe) specifically to recruit specialized engineering teams with advanced silicon design expertise.

The global RAN market is expected to be roughly flat in 2026 overall, and carrier spending visibility is limited. But between LEO satellites and the 5G share gain opportunity, the Telecom segment has more growth potential than the headline numbers may suggest.

Q1 FY2026 Telecom revenue: $68.1 million (stable, with growing satellite contribution)

---

### The Core Investment Thesis

Here is a bit more about why I am excited about MACOM.

#### 1. AI infrastructure spending has to go through fiber

There is no AI cluster without optical networking. You cannot connect 100,000 GPUs with copper wire as the bandwidth requirements are too high and the distances too great.

MACOM sits in the critical path of the AI infrastructure supply chain in a way that's hard to route around.

#### 2. MACOM makes both the chips AND the lasers

The competitive landscape in datacenter optical actually splits into two distinct layers, and MACOM's vertical integration argument is different in each one.

In the analog IC layer (TIAs, laser drivers, CDRs) MACOM's main rivals are Marvell (via its Inphi acquisition), Semtech, and MaxLinear. All three are fabless: which means they design chips but depend entirely on outside foundries like TSMC to manufacture them. MACOM owns and operates its own compound semiconductor fabs, which gives it manufacturing control, process flexibility, and cost advantages that pure fabless companies can't replicate.

In the photonic device layer (lasers, photodetectors, CW light sources) the picture is more complicated. Lumentum has its own InP manufacturing and makes EMLs, VCSELs, and pump lasers. Coherent is arguably the most vertically integrated company in the entire optical stack, with InP fabs, internal module manufacturing, and a presence across nearly every layer of the supply chain. Both are simultaneously MACOM customers (they buy MACOM analog ICs for their modules) and competitors (they make their own photonic devices). That's a genuinely messy relationship and it means MACOM's vertical integration advantage is strongest specifically against the analog IC rivals, not across the board.

Where MACOM holds a specific and hard-to-replicate edge is in CW lasers for silicon photonics which is the external light source that every SiPh-based optical module requires because silicon cannot generate light. MACOM's proprietary Etched Facet Technology allows InP lasers to be manufactured and tested at the wafer level, a capability that very few companies have at scale.

#### 3. The competitive position in LPO is genuinely strong

Linear Pluggable Optics (LPO) is a relatively new optical module architecture that eliminates the DSP chip from the transceiver entirely, relying on high-quality analog ICs instead. LPO modules are cheaper, lower power, and lower latency than DSP-based alternatives which make them highly attractive for hyperscaler deployments where cost and power efficiency matter enormously.

MACOM is a founding member of the LPO standard body. The company doesn't disclose specific market share figures (CEO Daly declined to comment on share gains or losses when asked directly) but what they have confirmed is more tangible in that three hyperscalers are now in active production using MACOM's LPO chipsets, and the company has tripled its LPO customer base over the past year. Customers are also now evaluating LRO (Linear Receive Optics) which is a related architecture using MACOM's 200G-per-lane chips for 1.6T applications.

#### 4. The defense business provides genuine stability

Most AI-adjacent semiconductor companies are essentially pure plays on datacenter capex. MACOM is not. The I&D segment contributes 43% of revenue with product lifecycles measured in decades, government-funded R&D contracts, and a qualification moat that takes years to replicate. When the datacenter cycle eventually cools (and it will, at some point) MACOM has a $420M+ revenue base of defense business that won't disappear. This can go both ways though. Companies that are more pure-play in a high growth segment like data center buildout command a high multiple. But if this growth stagnates, that multiple can get compressed quickly.

#### 5. Margin expansion is structural

Adjusted gross margins have expanded from roughly 53% in 2019 to approximately 57–58% today, with management guiding to sequential quarterly improvements of 25–50 basis points through fiscal 2026 which, starting from Q1's 57.6%, points toward the high 58–59% range by year-end. The drivers of this expansion (mix shift toward higher-margin optical and defense products, manufacturing insourcing, volume leverage across fixed fab costs, and the transition to larger wafers) are real and multi-year in nature. An analog semiconductor company in this margin range with 25–30% operating margins deserves a premium multiple.

A further sign that this is structural rather than cyclical is that MACOM launched a record 200+ new products in FY2025. Management has noted that products less than three years old are growing faster than overall company revenue and are accretive to gross marginsm meaning the newest products are both the fastest-growing and the highest-margin part of the portfolio. That combination is what compounders look like.

---

### The Honest Risks

Any stock that's up roughly double in a year deserves serious skepticism. Here are the genuine risks with MACOM.

#### Risk 1: The stock already prices in a lot of good news

At $217.80 and a $16.3 billion market cap, MACOM trades at approximately 49x this year's earnings estimate (roughly $4.40 in adjusted EPS for fiscal 2026). That's a rich multiple for a company approaching a $1.1 billion annualized revenue run rate. This is why even though I really like this company and believe in their growth, I am not rushing in to build my position. Reference the initial section of this report to see my personal levels.

For context, that multiple implies the market expects sustained strong growth and further margin expansion for years. If anything disrupts that narrative (a datacenter slowdown, competitive pressure, execution issues) the stock could fall substantially even if the underlying business continues doing reasonably well.

#### Risk 2: The datacenter cycle is exactly that. A cycle

Hyperscaler capex has been running at extraordinary levels driven by AI infrastructure investment. This will not continue indefinitely at the current pace. When it slows, whether due to macro conditions, AI commercialization challenges, or simply a pause after aggressive front-loading, optical component demand will soften. MACOM management explicitly warns that Data Center is their "most volatile end market" with "fast-moving ramp ups and ramp downs."

I have significant exposure to the data center buildout. This is one of the risks that I am tracking the closest.

#### Risk 3: Marvell is not standing still

Marvell's Perseus chip is a monolithic design that integrates DSP, TIA, and laser driver on a single 5nm die which is the all-in-one alternative to MACOM's unbundled approach. If Perseus gains widespread adoption, it could shrink MACOM's addressable market in optical transceivers.

#### Risk 4: Co-packaged optics could eventually change the architecture

Co-packaged optics (CPO) involves integrating the optical components directly onto the switch chip package, rather than using pluggable modules. If CPO becomes dominant (and the timeline is debated, with most estimates suggesting meaningful adoption is still 3–5+ years away for scale-up) it could alter how and where MACOM's components are used.

Management's counter-argument is worth understanding. CEO Daly stated on the Q1 FY2026 call that CPO and NPO (Near-Packaged Optics) are actually a net positive for MACOM. Because co-packaged architectures require many optical channels squeezed into a smaller form factor, the component requirements become significantly more complex, which plays into MACOM's system design expertise. More importantly, CPO relies heavily on silicon photonics which drives substantial demand for exactly the external CW lasers and photodetectors that MACOM manufactures. The risk and the opportunity are two sides of the same architectural shift. Whether CPO becomes a headwind or a tailwind for MACOM ultimately depends on execution and timing.

#### Risk 5: Customer concentration

MACOM's top 10 customers represent approximately 60% of revenue. The company doesn't disclose which customers they are. If one or two significant datacenter customers shift to a competitor's chipset, it would show up quickly in the numbers with limited warning.

#### Risk 6: Manufacturing execution

MACOM is in the middle of a $345 million, five-year investment plan to expand and modernize its fabs, including installing 150mm GaN-on-SiC production lines and expanding cleanroom capacity. Large manufacturing capital projects have a long history of cost overruns, delays, and integration headaches. The company is managing multiple fab transitions simultaneously.

---

### Valuation: What's the Stock Worth?

At $217.80 per share, MACOM is not cheap by any traditional metric.

Here's the current picture:

Metric Value Share price $217.80

Market cap ~$16.3B

Enterprise value ~$16.1B (net cash positive)

FY2026E adjusted EPS (base case) ~$4.40

Current NTM P/E ~49x

NTM EV/Sales (base ~$1.1B revenue) ~14.6x

NTM EV/EBITDA (base ~$351M EBITDA) ~46x

For comparison, as of March 15, 2026: Marvell, MACOM's closest datacenter optical competitor, trades at roughly 24–25x forward earnings. The stock has fallen/stayed in a tight range over the past year as its earnings base rebuilds after heavy acquisition costs, so its multiple has compressed significantly from historical peaks. Analog Devices, the best analog compounder comparison for MACOM's defense and RF business, trades at approximately 30–32x forward earnings. Against these two, MACOM at ~49x forward earnings is trading at roughly 2x Marvell's multiple and 1.5x ADI's multiple. That premium reflects the market's view that MACOM's growth rate, driven by 1.6T datacenter optical ramps and GaN defense expansion simultaneously, justifies a structurally higher multiple than either a more mature analog compounder like ADI or a larger but currently slower-growing Marvell. Whether a 2x premium to your closest optical competitor is warranted is ultimately the central question for anyone evaluating the stock at this price.

One underappreciated financial tailwind is that MACOM has $208 million in deferred tax assets, which allowed them to record an exceptionally low 3% adjusted tax rate in Q1 FY2026. This will keep cash tax payments minimal for the next several years, meaningfully boosting free cash flow relative to what the income statement alone would suggest. The cash flow generation is already substantial, MACOM produced $193 million in free cash flow in FY2025, a figure that reflects the underlying earnings power of the business more accurately than GAAP net income, which is depressed by acquisition-related amortization.

The company is also building out advanced chip-scale packaging capabilities, HUT VIA, flip chip, and copper pillar bump technologies, which could become a new source of differentiation and margin as the industry moves toward more integrated package architectures.

---

The way I want to model MACOM is by tracking the three numbers that will tell you, every quarter, which scenario is actually unfolding.

Data Center revenue growth rate is the primary signal. Management guided 35–40% year-over-year growth for FY2026. This number tells you directly whether the AI optical buildout is flowing through to MACOM's order book. Watch the year-over-year rate and not just the absolute dollar figure.

Adjusted gross margin trajectory is the compounding signal. Management guided 25–50 basis points of sequential improvement every quarter. At $1B+ in revenue, every 100 basis points of expansion is roughly $10 million in additional operating income. This tracks whether the insourcing thesis, mix shift toward optical and photonic products, and fab volume leverage are materializing as described.

Book-to-bill ratio is the leading indicator for both. The current reading is 1.3x. A sustained reading above 1.0x means demand is running ahead of supply. A dip below 1.0x typically appears one to two quarters before a revenue miss becomes visible in reported numbers.

---

#### Bear Case

Data Center growth decelerates toward 20% or below as hyperscaler capex moderates or competitive pressure from integrated DSP solutions begins displacing MACOM's discrete chipsets at key module makers. Book-to-bill drops below 1.0x. Gross margin expansion stalls or reverses as RTP fab integration costs weigh more than guided.

At 49x forward earnings, there is no cushion for this outcome. A premium-multiple stock that misses its growth trajectory does not re-rate modestly. It re-rates in the direction of the floor implied by its most stable business. In MACOM's case that floor is the defense segment, which is a good business, but not one the market would value at 49x. The downside in this scenario is severe and asymmetric, not because the underlying business becomes impaired, but because the current price leaves no room for disappointment.

I see NTM bear case in the $125–$145 range.

---

#### Base Case

Data Center grows at the midpoint of the 35–40% guidance. Gross margins expand steadily toward the high 58–59% range by fiscal year-end. Book-to-bill holds above 1.0x. Defense GaN continues its current trajectory. CW laser qualification progresses without setbacks, positioning FY2027 as the year that product category begins contributing revenue.

In this scenario the business performs well, but the stock at $217.80 is roughly fairly valued, not obviously cheap. Meaningful upside from the current price requires either the bull case to materialize or the market to maintain a multiple well above 40x on a sustained basis. That is possible as the stock demonstrated it when it touched $260 last week, but it is not guaranteed and should not be assumed as a baseline.

I see the NTM base case in the $200–$240 range.

---

#### Bull Case

Data Center growth runs ahead of the 35–40% guide as 1.6T module deployments broaden across more hyperscalers and module makers. The 200G photodetector ramp becomes a quantified revenue contributor as manufacturing capacity expands to meet demand. Defense GaN sustains 30%+ growth from counter-drone and radar program wins. Gross margins reach 60%+ as insourcing benefits arrive earlier than guided.

The additional layer that distinguishes the bull case from the base case is the CW laser business. MACOM's CW laser arrays serve silicon photonics-based optical modules that require an external light source because silicon cannot generate light natively. This is an architectural requirement in 1.6T pluggable transceivers shipping today, not a dependency on future co-packaged optics adoption. As of Q1 FY2026, two customers have confirmed the chips meet their electrical specifications and the lasers are entering formal qualification. Production ramp realistically follows 6–12 months after qualification completes, placing meaningful CW laser revenue in FY2027. When management begins describing this product line in terms of revenue contribution rather than qualification milestones, that is the clearest signal the bull case is materializing.

The stock briefly traded at approximately $260 last week, implying the market has already attempted to price an early version of this scenario before pulling back to current levels. A sustained move through that level requires the quarterly data to confirm the thesis consistently.

I see the NTM bull case in the $260–$300 range.

---

### What to Watch Every Quarter

#### Progress Markers

#### Watch for these as they mean the thesis is on track:

* Data Center quarterly revenue above $90M and growing. Management guided 35–40% annual growth. That math implies averaging roughly $88–93M per quarter through FY2026. A quarter above $90M with continued momentum is confirmation the 1.6T ramp is real.
* Book-to-bill at or above 1.2x. MACOM reported a 1.3x book-to-bill in Q1 FY2026 which is the highest since Q3 2021. Sustained above 1.0x means backlog is building and demand is outpacing supply. A dip below 1.0x is the first warning signal.
* Adjusted gross margin at or above 58% and expanding. Management is guiding for 25–50 basis points of sequential improvement each quarter. They've delivered on this guidance consistently. Each quarter that continues validates the mix shift story and the insourcing thesis.
* CEO commentary on 1.6T ramp strength, new module maker design wins, or named customer progress. Any specificity about which hyperscalers or module makers are ramping would be genuinely incremental information. The more specific, the more confident.
* InP photonics / CW laser revenue specifically called out as a material growth driver. CEO Daly used the word "breakthrough" when describing cloud customers recognizing MACOM's laser capabilities. When "breakthrough" starts appearing in actual revenue numbers, it's a multiple-expansion event.
* Defense GaN revenue sustaining 30%+ annual growth rate. The Wolfspeed acquisition and HRL license are investments that should compound. Sustained defense GaN growth validates the thesis that MACOM isn't just riding the AI wave but it has a durable second growth engine.

---

#### Warning signs

Watch for these as they mean the thesis might be breaking:

* Data Center growth decelerating below 20% YoY. Given that 35–40% is the current guidance and the stock prices in sustained high growth, even decelerating to 20% would be a significant disappointment and likely trigger multiple compression.
* Management language that sounds like competitive pressure in optical. Phrases like "customers evaluating integrated DSP solutions," "design review at key accounts," or "extended qualification timelines" are code for Marvell's Perseus gaining traction. Listen carefully.
* Book-to-bill dropping below 1.0x. This is the leading indicator. Revenue lags orders by several months. A book-to-bill below 1.0x means customers are pulling back before it shows up in quarterly revenue.
* Gross margin guidance going flat or declining. The margin expansion story is central to the valuation. If management guides to flat or declining margins (whether from pricing pressure, mix shift, or fab integration overruns) the multiple will compress.
* Hyperscaler capex guidance cuts in any of the major cloud earnings calls (Meta, Microsoft, Google, Amazon). MACOM's Data Center revenue is indirectly tied to hyperscaler capital spending. When Microsoft or Google reduce capex guidance, optical component orders eventually follow. Monitor these four earnings calls closely.
* Any indication of customer concentration worsening. If a single customer approaches 25%+ of revenue, MACOM's investment case becomes uncomfortably dependent on that customer's architecture decisions. The 10-K customer disclosure section is worth reading carefully each year.

---

*This is not investment advice. It's analysis intended to help you think through a stock more clearly. Do your own research. Consult a licensed advisor if you need personalized guidance. The author holds no position in MTSI at the time of writing.*

*Key sources: MACOM SEC filings (10-K FY2025, 10-Q Q1 FY2026), Q4 FY2025 and Q1 FY2026 earnings call transcripts, MACOM product documentation and press releases, and publicly available industry research.*
