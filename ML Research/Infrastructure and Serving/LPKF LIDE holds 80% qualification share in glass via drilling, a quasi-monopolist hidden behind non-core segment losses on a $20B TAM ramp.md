---
created: 2026-05-25
description: LPKF's LIDE process dominates >80% of glass substrate qualification at every major foundry, but the market prices it as an industrial restructuring story because LIDE revenue is buried in a loss-making segment beside a collapsing Solar division.
source: https://x.com/snmart/status/2047641706401538443
type: learning
---

## Key Takeaways

- Glass substrates solve the "warpage wall" that blocks AI accelerators above 55mm packages — 5-10x better dimensional stability, sub-5 ppm/°C CTE, 40% higher interconnect density — and every major foundry (Intel Q1 2026 HVM, Samsung H2 2026, TSMC CoPoS pilot, Rapidus 2028) now has a committed glass roadmap driven by NVIDIA's Rubin architecture mandate, making the substrate transition structurally inevitable rather than speculative. [[PhotonCap May 2026 - 15-company glass substrate cycle map frames 2026 as pilot-qualification phase with 2027-2030 volume ramp across AI accelerators HBM4 interposer and CPO]] maps 15 companies across this ramp and calls TGV the cycle's narrowest bottleneck.
- LPKF's LIDE (Laser Induced Deep Etching) is the single hardest-to-replicate step in the glass packaging chain: a two-step laser-then-etch process producing >15:1 aspect ratio through-glass vias with smooth sidewalls, protected by actively-litigated patents in Europe, Korea, and China — the moat is real and being defended, with Chinese equivalents explicitly ring-fenced to China-for-China production while Western fabs qualify only on LPKF. See [[PhotonCap 2026-05 - LPKF up 255 pct YTD as LIDE TGV process becomes glass substrate chokepoint for EIC-to-CPO packaging shift]] for the three-layer value chain (TGV equipment → integrated platform → glass material) and LPKF's Layer A position.
- The market is misreading the numbers: LIDE revenue (~€10-15M in 2025) is embedded in a loss-making Electronics segment that absorbs qualification capex and R&D for next-gen LIDE, while a simultaneous 31% Solar revenue collapse and 96% EBIT guidance miss have painted the stock as a restructuring story at just 3x EV/Sales on a €350M cap — the filings show a different picture. [[Crux 2026-04-24 thesis - LPK (LPKF) starter on LIDE glass-substrate process for AI advanced packaging optionality]] frames the timeline as 2026 first production starts → 2027-2028 ramp → 2029-2030 high-volume.
- The conversion catalyst is date-specific: the Q1 2026 earnings report (April 30) is when CEO Klaus Fiedler committed to releasing "tangible numbers" on LIDE order entry; €5-10M of Q1 LIDE orders implies a €20-40M run-rate visible to the market, and the existing 2026 guidance explicitly excludes Advanced Packaging volume orders — any materializing POs are pure upside to the stated guide.
- Fiedler's own moat erosion model is the clearest risk framework: he targets 70% production market share (vs. 80%+ qualification), explicitly accepting ~10ppt erosion from Schmid/Philoptics dual-sourcing pressure; the thesis holds as long as LPKF retains the dominant share in Western fab orders, and the non-China patent enforcement strategy is the mechanism keeping that floor intact. [[PhotonCap May 2026 addendum - glass substrate thesis extends from EIC-only to EPIC electronic-photonic integration with conceptual TGV+PIC+ASIC+HBM package diagram from Haifeng Xuan LinkedIn]] extends the TAM further if EPIC packaging arrives 2027-2030, adding CPO/photonic integration volume to the same packaging houses LPKF serves.

## External Resources

- [LPKF: The Glass Picks-and-Shovels Play (Substack)](https://open.substack.com/pub/snmart/p/lpkf-the-glass-picks-and-shovels?r=lnv10&utm_campaign=post&utm_medium=web&showWelcomeOnShare=true) — full article including valuation multiples, reverse DCF, peer comparison, scenario analysis, risks, and catalysts
- [Yole Intelligence: Status of the Advanced IC Substrate Industry report, 2023](https://www.yolegroup.com) — source for glass core substrate market adoption trend data (ceramic → organic → glass substrate generational S-curves)

## Original Content

> [!quote]- Source Material
> @snmart (Nicolas) — Fri Apr 24 2026
>
> Article: $LPKF: The Glass Picks-and-Shovels Play
>
> LPKF Laser & Electronics: A €350M market cap German micro-cap with >80% qualification share in a tool every glass-substrate fab will need by 2027.
>
> Table of Contents
>
> 1. The Setup
> 2. The Business
> 3. Moat
> 4. Numbers
> 5. Valuation (Multiples, reverse DFC, peer comparison and scenario analysis)
> 6. Risks
> 7. Catalysts & Timeline
> 8. Conclusion
>
> ---
>
> *Article cover: LPKF's laser system drilling micro-vias into glass substrate for advanced semiconductor packaging*
> ![[snmart-538443-001.jpg]]
>
> *LIDE enables high-density microvias in glass core substrates for chiplet and 2.5D/3D integration at industrial scale*
> ![[snmart-538443-002.jpg]]
>
> # 1. The setup
>
> LPKF Laser & Electronics SE ($LPKF / $LPK / $LPKFF) is a German laser equipment maker that has spent the last decade quietly building the dominant industrial process for drilling micro-holes in glass, a step every major foundry now needs as the semiconductor industry pivots from organic substrates to glass core substrates for AI accelerators.
>
> Intel reached high-volume manufacturing of glass substrates at its Chandler facility in Q1 2026. Samsung is targeting full mass production by H2 2026 at Sejong. TSMC is building a CoPoS pilot at AP7 Chiayi to serve NVIDIA's Rubin architecture. Rapidus targets 2028. Absolics is already producing prototypes in Georgia.
>
> Over 80% of these customers are qualifying with LPKF's LIDE equipment. Yet LPKF trades at €14/share with €350M market cap, 3x trailing EV/Sales, after a brutal 2025 in which Solar revenue collapsed 31% and the company missed its original guidance by 13% on revenue and 96% on EBIT margin.
>
> The market is treating LPKF as a struggling industrial restructuring story. The filings show something different: a quasi-monopolist on a $20B TAM ramp-up, hiding behind two non-core segments that are stabilizing, an activist shareholder who entered in September 2025, and a CEO who hinted at "tangible numbers" on LIDE order entry coming in the Q1 2026 report on April 30. This is the analytical setup.
>
> ## Macro context: why glass and why now
>
> The semiconductor packaging industry is at an inflection point that has nothing to do with the front-end node race and everything to do with physics. As AI accelerators push past 1,000 watts of power per package, integrate more chiplets, and demand higher I/O counts, the organic substrates that have served the industry for two decades are hitting hard physical limits. Warpage above 55mm package size, dielectric loss at high frequencies, thermal expansion mismatch with silicon, and signal integrity degradation are all converging into what packaging engineers call the "warpage wall."
>
> Glass solves this. Glass core substrates offer 5-10x better dimensional stability than organic alternatives, ultra-low coefficient of thermal expansion (sub-5 ppm/°C), exceptional flatness (sub-20μm warpage across 100mm packages), and 40% higher interconnect density. They enable 60-80mm packages that integrate 8-16 chiplets with HBM stacks, architectures that simply cannot be built reliably on organic substrates. This is why Intel started developing glass substrates over a decade ago, and why every major player has now committed to glass roadmaps in the 2026-2030 window.
>
> Every leading foundry has a glass roadmap, NVIDIA has dictated glass for Rubin, and Broadcom/Marvell have integrated CPO platforms. If glass captures 10-15% of the advanced packaging substrate market by 2030 (the IDTechEx and Future Markets Inc projections suggest this is the conservative scenario, with 20-30% by 2036), the laser equipment TAM scales 4-6x faster than the numbers implies.
>
> *Glass core substrate market adoption S-curves: ceramic (1960s peak) → organic (1990s peak) → glass core substrate (2030s ramp)*
> ![[snmart-538443-003.jpg]]
>
> LPKF is not the entire story of glass packaging. It is one specific tool in a longer process chain. But it is the dominant tool for the most patent-protected, hardest-to-replicate step: drilling thousands of high-aspect-ratio micro-vias through glass without cracks, with sub-micron precision, at industrial throughput. This is what LIDE does.
>
> ## 2. The business: what LPKF actually sells
>
> LPKF operates in four reporting segments:
>
> 1) The Electronics segment is where LIDE lives. CEO Klaus Fiedler said on the Q4 2025 earnings call that the advanced packaging semicon portion of Electronics was "still in the low 8 figures" in 2025, meaning roughly €10-15M of revenue.
>
> The rest of Electronics is the legacy PCB stencil cutting, depaneling, and flexible PCB processing business. The negative segment EBIT in 2025 reflects a combination of LIDE qualification line costs, R&D for new LIDE generations, and weak utilization in core PCB tools because of US tariff disruption to SMT customer ramp plans.
>
> 2) Solar produces laser scribers for thin-film solar cell structuring. The 2025 revenue collapse to €28.3M (from €41.2M) reflects two things: the loss of a planned major project in China, and customer investment paralysis as the industry transitions from established silicon thin-film to perovskites, where volume production is not yet ready. Management expects 2026 to be similarly weak. Importantly, Solar is still profitable at the segment level, just structurally smaller.
>
> 3) Development supplies in-house PCB prototyping equipment to research institutions, universities, and corporate R&D labs. This is a steady, defensive business with North America as the dominant market. The US government shutdown from early October to mid-November 2025 dampened Q4 order entry but did not change the structural trajectory. With defense R&D budgets growing, this segment is positioned for low-to-mid single digit growth.
>
> 4) Welding produces laser systems for plastic welding, used in consumer electronics, medical devices, and automotive supply. The 2025 turnaround in this segment, from -€4.8M EBIT to +€0.5M, on +30% revenue growth, was driven by a single large consumer order out of China. Importantly, LPKF also won a substantial smart robotics customer in 2025 with continuing orders into 2026, which Fiedler described in the call as having "8 figures" of opportunity if the customer scales.
>
> *LPKF segment financials 2024 vs 2025: Electronics (incl. LIDE) revenue fell slightly; Solar collapsed; Welding turned EBIT-positive*
> ![[snmart-538443-004.png]]
>
> ## What the market is missing: insights from the filings
>
> 1. The sharp decline in backlog is the main bearish signal, but it also helps explain why 2026 guidance appears conservative. The midpoint of guidance can be reached with a normal level of 2026 book-and-bill orders even without large LIDE volume orders. The company also stated that potential Advanced Packaging volume orders are not included in the forecast, which implies that the current guidance does not capture upside if those orders arrive.
>
> 2. The Welding segment improved materially in 2025, moving from a loss to positive EBIT. In addition to the turnaround, management pointed to a potentially meaningful opportunity in smart robotics, suggesting that Welding may have more growth potential than a typical legacy industrial segment.
>
> 3. LIDE's economics are not disclosed separately because they are embedded inside the Electronics segment, which reported a loss in 2025. That makes the segment look weaker than it may actually be, because LIDE is still absorbing qualification, R&D, and ramp-related costs. If LIDE moves from qualification into volume production, incremental revenue could carry much stronger margins than the current segment figures imply.
>
> 4. LPKF also has about €50 million of unrecognized tax loss carryforwards and temporary differences. If profitability improves, these could reduce cash taxes for several years and potentially increase future free cash flow and equity value.
>
> ## 3. MOAT
>
> LIDE (Laser Induced Deep Etching) is a two-step process. A pulsed laser modifies a precise zone within the glass without ablating material, creating a chemically reactive damage line. A subsequent selective wet etch removes only the modified zone, leaving micrometer-scale through-glass vias with smooth sidewalls and high aspect ratios (>15:1 demonstrated). This is fundamentally different from direct laser ablation (which leaves rough sidewalls and microcracks) or photosensitive glass methods (which require special glass formulations).
>
> *Glass substrate with LIDE-drilled micro-via array — the patterned wafer showing thousands of precision through-glass vias*
> ![[snmart-538443-005.jpg]]
>
> The IP position is real. Fiedler stated in the Letter that LPKF has "successfully confirmed our protective rights in Europe and Korea, [and] are currently actively pursuing patent infringement in China and have initiated proceedings there against a patent infringer. Our goal is to consistently prevent the unauthorized use of our technology and ensure that products manufactured with such imitation technologies cannot access markets outside China." This is a defensive posture but it is being executed actively.
>
> The competitive landscape Fiedler discussed on the Q4 call:
>
> - Schmid Group (Germany): traditional wet processing player, complementary to LIDE in some flows but competitive in others. Mentioned as a credible alternative.
>
> - Philoptics (Korea): laser equipment supplier, named by an analyst on the call as a competition concern. Fiedler's response: "If they go in with their own technology they developed, fair, that's good. It cannot be a single source market. If it's competitors copying us, there, we will be very active in avoiding it."
>
> - Chinese copycats: explicitly mentioned, with active patent litigation. Fiedler's framing: "We need to make sure that products manufactured with such imitation technologies cannot access markets outside China", implicit acceptance that China will have local-for-local equivalents, but defense of the rest of the world.
>
> - Other Western players: "I don't see any viable competitor in the Western countries who is close to our offering."
>
> Fiedler's stated personal target is 70% market share in production ramp-up orders, against a current >80% qualification share. The 10-percentage-point compression assumed in his target is the realistic erosion the market should price in. Anything better than 70% is upside.
>
> The non-IP elements of the moat are also meaningful:
>
> - +5 year customer relationships in development stage (Fiedler: "we sometimes work with them for more than 5 years")
>
> - Customer-pull product expansions (ABF singulation was customer-requested, not LPKF-pushed)
>
> - Vertical integration: LPKF also produces glass components in-house using its own LIDE equipment, generating qualification data and process knowledge that pure equipment vendors lack
>
> - Adjacent process expansion: glass bonding, ABF singulation, CPO research already in motion
>
> The big risk to the moat: yield curves on customer LIDE machines. If Schmid or Philoptics ships a competitive tool with similar throughput at 20-30% lower price, customers might split purchase orders to maintain dual sourcing. This is the realistic erosion vector, not technology displacement.
>
> ## 4. The numbers
>
> This table shows a business that looks much weaker on the surface than it likely is underneath. Revenue grew sharply in 2022, stayed broadly flat in 2023 and 2024, and then fell 6.2% in 2025 to €115.3M. That 2025 decline matters, but it was not a collapse across the entire company. The biggest drag came from Solar, while Development held up well and Welding rebounded strongly. In other words, the weak top line reflects a mix issue and delayed customer spending more than a breakdown of the whole franchise.
>
> *LPKF historical financials 2021–2025: revenue, EBIT margin, FCF, net cash — the 2025 weakness is top-line mix, not franchise deterioration*
> ![[snmart-538443-006.png]]
>
> What to watch in the Q1 2026 report (April 30)
>
> This is the single highest-information-density event for LPKF in 2026. Klaus Fiedler signaled explicitly on the Q4 call that he will share "tangible numbers" on LIDE order entry. The market will be looking for:
>
> 1. LIDE order intake quantification: did the "handful of customers" Klaus mentioned actually issue POs in Q1? Magnitude matters, €5-10M of Q1 LIDE orders signals a potential €20-40M run-rate; €1-2M signals continued slow ramp.
>
> 2. Number of LIDE customers ordering for production: Klaus said "more than one or two." Confirmation of 3-5 named customers (or quantified range) materially derisks the bull case.
>
> 3. Total order intake: if Q1 order intake is €25-30M, the full-year guidance becomes very achievable. Below €20M is a yellow flag.
>
> 4. Solar order pipeline commentary: any update on perovskite project timing or large customer recovery
>
> 5. Welding order entry from smart robotics customer: any quantification of run-rate
>
> 6. North Star cost savings realization: how much of the structural cost reduction has flowed through
>
> 7. Q1 cash position and any drawdown of credit lines: confirms whether the financing runway is comfortable
>
> A guidance raise at the H1 2026 report (likely late August) is plausible if Q1 trends positive. The AGM on 4 June 2026 in Hannover is also a venue for narrative updates.
>
> Up to this point, the qualitative case is clear: LPKF is not just a weak Solar story or a messy restructuring case. It is a company with a strong position in a critical glass-packaging step, a cleaner cost base, and meaningful upside if LIDE converts from qualification into real production orders.
>
> The next step is where the thesis becomes investable: valuation, the specific risks that can break the story, and the concrete catalysts that will tell us whether the ramp is actually starting. That is also where the asymmetry becomes much easier to see.
>
> ## The full article is available on Substack.
>
> Please refer to the link below:
>
> https://open.substack.com/pub/snmart/p/lpkf-the-glass-picks-and-shovels?r=lnv10&utm_campaign=post&utm_medium=web&showWelcomeOnShare=true
>
> ---
>
> Thread replies:
>
> @miraclemaster07 (Jay) — Fri Apr 24 12:40 UTC 2026:
> @snmart What's the biggest risk in your opinion. Upcoming earnings are going to be crucial.
>
> @snmart (Nicolas) — Fri Apr 24 12:48 UTC 2026:
> @miraclemaster07 Delayed glass substrate adoption and execution risk in converting qualifications into production orders
>
> ---
>
> Engagement: 56 likes | 8 retweets | 3 replies
> [Original post](https://x.com/snmart/status/2047641706401538443)
