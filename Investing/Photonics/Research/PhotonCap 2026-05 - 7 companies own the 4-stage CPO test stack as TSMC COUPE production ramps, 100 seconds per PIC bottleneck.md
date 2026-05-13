---
created: 2026-05-13
published: 2026-05-08
description: CPO production-stage testing has emerged as the next supply-chain choke point — 100 seconds per PIC vs sub-second for conventional die — and seven specialized equipment companies dominate the four test insertions plus burn-in as TSMC COUPE enters production in 2026.
source: https://x.com/PhotonCap/status/2052650600001880174
type: research
authors: ["Photon Capital (@PhotonCap)"]
---

# PhotonCap 2026-05 — 7 companies own the 4-stage CPO test stack as TSMC COUPE production ramps, 100 seconds per PIC bottleneck

## Key Takeaways

- **The CPO bottleneck has moved from fabrication to test.** Per TrendForce, full 100% optical inspection of a single PIC takes **>100 seconds on average** — roughly 100x longer than conventional electrical wafer test, because SiPh requires simultaneous electrical-plus-optical probing with tens-of-nanometer alignment tolerance, six-or-more-axis positioning, and (for TSMC's COUPE 3D hybrid-bonded stack) double-sided access since the optical coupler ends up on the back side. Throughput, not yield, defines the equipment market: the company that compresses 100s → 50s → 25s wins on floor-space and capex per PIC.

- **Seven companies own the 4-stage test stack plus burn-in.** Insertion 1 (PIC wafer test, OWAT — IL/PDL/crosstalk/coupler/DC), Insertion 2 (EIC+PIC combined wafer — modulation, eye diagram, driver/TIA), Insertion 3 (optical engine KGOE — full-link BER, thermal cycling, calibration), Insertion 4 (module/system SLT — data-path integrity, power, thermal, protocol), plus burn-in on the InP laser wafer upstream of Insertion 1. The named seven: [[FormFactor (FORM)]], [[Teradyne (TER)]], [[Keysight (KEYS)]], [[Aehr Test Systems (AEHR)]], [[Advantest (6857.T)]], [[Chroma ATE (2360.TW)]], and ficonTEC (private; subsidiary of China's Robo Technik — the structural-risk wrinkle PhotonCap flags as potentially the most underpriced variable).

- **One-year returns are violent and market caps span two orders of magnitude.** 1Y price returns as of 2026-05-06: [[Aehr Test Systems (AEHR)]] +1,033%, [[Chroma ATE (2360.TW)]] +757%, [[FormFactor (FORM)]] +468%, [[Advantest (6857.T)]] +389%, [[Teradyne (TER)]] +389%, [[Keysight (KEYS)]] +150%. Market caps: [[Advantest (6857.T)]] $128B, [[Keysight (KEYS)]] $62B, [[Teradyne (TER)]] $56B, [[Chroma ATE (2360.TW)]] ~$30B, [[FormFactor (FORM)]] $11.6B, [[Aehr Test Systems (AEHR)]] $2.9B. Against front-end equipment large caps (AMAT $327B, LAM $372B, KLA $236B), pure-play [[FormFactor (FORM)]] and [[Aehr Test Systems (AEHR)]] are 1-2 orders of magnitude smaller — a gap that could compress if CPO test grows into a multi-billion-dollar annual market, or persist if production slips. Q1 2026 datapoints that did not exist a quarter ago: FORM +32% YoY beat with raised $10-20M CPO revenue guide to high end, TER +87% YoY (~70% AI-related), AEHR record $41M hyperscale order for AI-ASIC package-level burn-in (April 2026).

- **NVIDIA put $6B into the connectivity supply chain to secure capacity.** $2B into [[Lumentum (LITE)]] for lasers and optical networking, $2B into [[Coherent (COHR)]] for the same, and a separate $2B strategic stake in [[Marvell Technology (MRVL)]] covering NVLink Fusion, custom XPU, and silicon-photonics/optical-interconnect. Every component touched by those investments has to pass through one or more of the seven companies' equipment before it ships. The conversion rate of NVIDIA's $6B into actual production volume is the variable that defines the next 12 months for the test names.

- **Test-time math sets the equipment demand floor.** 1M PICs/month at 100s per PIC = ~27,778 equipment-hours/month. At 24/7 operation and 85% uptime, a single test cell processes ~22,000 PICs/month — so 1M/month requires ~45 cells before retest, multi-insertion, and multi-engine multipliers. This is why FormFactor's CM300xi-SiPh push for sub-5-second per-die alignment-plus-basic-parameter and ficonTEC's multi-site parallel testing are the right competitive levers. (Caveat: TrendForce's "100s" and FormFactor's "sub-5s" describe different test scopes — full optical inspection vs alignment + specific recipe — so don't compare them directly.)

- **The article is paywalled past the framework setup.** This X preview maps the four insertions and names the seven companies but does not break down which axis owns which insertion, the Bull/Gap/Optionality scoring per axis, the Chinese-ownership-structure analysis on ficonTEC, or the scenario analysis. Subscribers get those at <https://photoncap.net/p/the-100-second-bottleneck-behind>. The free preview is itself useful as the canonical 7-name, 4-insertion framing.

## External Resources

- [PhotonCap full article](https://photoncap.net/p/the-100-second-bottleneck-behind) — paywalled continuation; contains the per-insertion test-station breakdown, two-axis Bull/Gap/Optionality mapping, ficonTEC ownership-structure analysis, and scenario tables that the X preview only teases.
- [The Three Pillars of SiPh Wafer Test](https://photoncap.net/p/the-three-pillars-of-siph-wafer-test) — prior PhotonCap piece on how AEHR, FORM, and KEYS each cover a different layer of SiPh wafer test.
- [FormFactor Q1 2026: SK hynix 29.5%, NVIDIA 10.2%, and the First CPO Test Revenue Signal](https://photoncap.net/p/formfactor-q1-2026-sk-hynix-295-nvidia) — three signals from FORM's Q1 print: SK hynix concentration, first NVIDIA 10% disclosure, raised CPO revenue guide; TRITON production entry, Keystone acquisition, Teradyne Photon 100 competition.
- [PC101 Lecture 4 Part 2: The Last Millimeter — CPO Packaging Value Chain and Next-Gen Applications](https://photoncap.net/p/pc101-lecture-4-the-last-millimeter) — F2C assembly companies in CPO optical packaging.
- [7 Bonding Equipment Companies Behind HBM4 and CPO](https://photoncap.net/p/7-bonding-equipment-companies-behind) — companion piece on the bonding-equipment side of the CPO supply chain.
- [Damnang — Why You Should Be Watching Optical Test Right Now](https://damnang2.substack.com/p/why-you-should-be-watching-optical) — referenced Substack with overlapping optical-test thesis.

## Original Content

> [!quote]- Source: @PhotonCap X Article — 2026-05-08
>
> > @PhotonCap — 2026-05-08
> >
> > The bottleneck in CPO is no longer just "can you build the optical engine." The bottleneck has shifted from fabrication to testing the PIC and optical engine at production speed. Per TrendForce, a full 100% optical inspection of a single CPO PIC takes over 100 seconds on average. With TSMC COUPE moving into production in 2026, the test equipment stack is emerging as a new supply chain choke point. This article breaks CPO testing into four insertions plus burn-in, and maps how FormFactor ($FORM), Teradyne ($TER), Keysight ($KEYS), Aehr ($AEHR), Advantest (6857.T), Chroma (2360.TW), and ficonTEC (private) each occupy their respective layers.
> >
> > Contents
> >
> > 1. 100 Seconds per PIC: Why CPO Test Is the Bottleneck
> >
> > 2. Background: The Physics of Why CPO Testing Is Hard
> >
> > 3. The 4 Insertion Framework and the Key Questions (paywall hook)
> >
> > 4. Insertion 1: PIC Wafer-Level Test
> >
> > 5. Insertion 2: EIC-PIC Combined Wafer-Level Test
> >
> > 6. Insertion 3: Optical Engine-Level Test, ficonTEC vs Chroma
> >
> > 7. Insertion 4: Module/System-Level Test
> >
> > 8. Burn-In: The Mandatory Step Outside the 4 Insertions
> >
> > 9. Two Competing Axes: Bull, Gap, Optionality
> >
> > 10. Scenario Analysis
> >
> > 11. Monitoring Points
> >
> > 12. Summary Table + Closing
> >
> > 13. References & Sources
> >
> > *PhotonCap cover graphic: the CPO test stack as 5 stacked layers — Burn-In (InP laser wafer) at the top, then Insertions 1-4 (PIC Wafer, EIC+PIC Combined, Optical Engine, Module/System) descending to the final switch ASIC*
> > ![[photoncap-880174-003.jpg]]
> >
> > ## 1. 100 Seconds per PIC: Why CPO Test Is the Bottleneck
> >
> > Per a recent TrendForce report, a full 100% optical inspection of a single PIC (photonic integrated circuit) going into a CPO module takes over 100 seconds on average.[1]
> >
> > 100 seconds. That is an order of magnitude longer than conventional semiconductor test. Over the past year, as this bottleneck became visible to the market, the equipment companies behind it moved at the opposite speed. One-year stock returns:
> >
> > $AEHR +1,033%, Chroma (2360.TW) +757%, Advantest (6857.T) +389%, $FORM +468%, $TER +389%, $KEYS +150%. (as of 2026-05-06 close, price return basis, Yahoo Finance/Google Finance/Investing.com)
> >
> > Market cap scales vary wildly. Advantest $128B, Keysight $62B, Teradyne $56B. These three are large-cap semiconductor equipment names. FormFactor sits at $11.6B, Aehr at $2.9B. ficonTEC is private (Germany-based, subsidiary of China's Robo Technik). Chroma is listed in Taiwan at roughly TWD 979B (approximately $30B). Within the same CPO test ecosystem, market caps span orders of magnitude.
> >
> > TSMC's COUPE platform is entering CPO chip production in 2026.[1] NVIDIA invested $2B in Lumentum[2] and $2B in Coherent[3] to secure laser and optical networking capacity. A separate $2B strategic investment in Marvell covers NVLink Fusion, custom XPU, and silicon photonics/optical interconnect.[4] Across these three deals, $6B in AI connectivity and optics supply chain investment. Every one of these optical components needs to pass testing before it hits a production line.
> >
> > Testing is becoming the single largest bottleneck in CPO mass production, and a competitive landscape is forming rapidly among equipment companies racing to solve it.
> >
> > For context, consider the front-end equipment large caps. AMAT $327B, LAM $372B, KLA $236B (as of 2026-05-06). Against this group, CPO test companies sit at a distinctly different scale. Keysight ($62B), Teradyne ($56B), and Chroma (~$30B) are large test and measurement companies, but still 5 to 12 times smaller than front-end equipment leaders. FormFactor ($11.6B) and Aehr ($2.9B) are one to two orders of magnitude smaller. If CPO test grows into a multi-billion-dollar annual market comparable to front-end equipment, the market cap gap for pure-play smaller names like FormFactor and Aehr could be due for reassessment. The opposite is also possible. If CPO production gets delayed, test equipment capex gets deferred with it.
> >
> > FormFactor reported Q1 2026 revenue of $226.1M (+32% YoY), beating guidance, and raised its 2026 CPO revenue guide to the high end of the $10-20M range on its earnings call.[5][6] Teradyne reported Q1 2026 revenue of $1.282B (+87% YoY), with AI-related revenue accounting for roughly 70% of the total.[7] Aehr disclosed a record $41M order from a hyperscale AI customer in April 2026 (for custom AI processor ASIC package-level burn-in).[8] None of these data points existed a quarter ago.
> >
> > > Bottom line: 1Y returns for the 7 CPO test equipment companies range from +150% to +1,033%. Market caps range from $2.9B to $128B. Compared to front-end equipment large caps (AMAT/LAM/KLA at $236B to $372B), pure-play names like FormFactor ($11.6B) and Aehr ($2.9B) are one to two orders of magnitude smaller. The speed at which NVIDIA's $6B AI connectivity investment converts to actual production volume will define the next 12 months for these companies.
> >
> > ## 2. Background: The Physics of Why CPO Testing Is Hard
> >
> > Start with why it takes 100 seconds.
> >
> > A single-mode fiber core has a cross-sectional area of roughly 78.5 square micrometers. A silicon photonic strip waveguide is roughly 0.099 square micrometers. That is an 800x difference. Bridging this gap requires nanometer-precision alignment to couple light in and out of the device under test. Much of this process is still partially manual. There is no unified industry standard.
> >
> > Conventional semiconductor test only deals with electrical signals. Touch the probe card to the pads and you are done. SiPh/CPO test requires simultaneous electrical and optical probing. You drive the modulator with electrical signals while simultaneously coupling light through an optical coupler, then receive the modulated optical signal on the output side. This requires six or more axes of precision positioning, with alignment tolerances in the tens of nanometers.
> >
> > Add 3D hybrid bonding (the TSMC COUPE architecture) and it gets worse. When PIC and EIC are bonded face-to-face, the optical coupler ends up on the bottom side of the wafer. Electrical contacts are on top. You need to probe from both sides simultaneously. Existing semiconductor test equipment cannot do this.
> >
> > From the perspective of established equipment companies, this is a completely different technology stack from the deposition, etch, and metrology tools that AMAT, LAM Research, and KLA ($200B to $370B market caps) dominate. In conventional wafer test, probe card pin placement accuracy at the micrometer level is sufficient. SiPh optical coupler alignment tolerance is in the tens of nanometers, roughly 100 times more stringent. Factor in thermal expansion from temperature changes (silicon CTE is roughly 2.6 ppm/K) and you cannot simply bolt an optical module onto an existing probe station. You need equipment designed from scratch for optical alignment.
> >
> > *Figure 1: Electrical vs Optical Probing Comparison, Mode Size Mismatch — left panel shows conventional electrical test (probe card → bond pads, ~µm alignment, sub-second per die); right panel shows SiPh/CPO optical+electrical test (probe card + microlens / fiber ferrule / 6-axis hexapod positioning stage, ~tens-of-nm alignment, ~100s per die). Callouts highlight the SMF-core (~78.5 µm²) vs SiPh-waveguide (~0.1 µm²) ~800× area gap and the 100× precision gap that translates into a 100× time gap.*
> > ![[photoncap-880174-001.jpg]]
> >
> > There is another issue. Conventional electrical test has high repeatability. Align the probe card once and you can automatically test the entire wafer. In optical test, coupling conditions change from die to die. Waveguide position, edge coupler angle, and grating coupler pitch all carry process variation at the die level, so optical alignment must be independently optimized for each die. This accounts for a significant portion of the 100 seconds. FormFactor's claim of sub-5-second per-die test time on the CM300xi-SiPh is a data point showing progress in alignment automation.[9] That said, TrendForce's "100 seconds" and FormFactor's "sub-5 seconds" likely refer to different test content scopes. The 100 seconds appears to cover full optical inspection, while the 5 seconds likely refers to alignment plus basic parameter measurement for a specific recipe. Direct comparison requires caution.
> >
> > This is why the CPO test market is being driven not by the existing equipment large caps, but by these seven companies with specialized capabilities in photonic probing, optical alignment, and burn-in.
> >
> > Previous PhotonCap and [Damnang](https://open.substack.com/users/329991097-damnang?utm_source=mentions) articles covered this technical background in detail:
> >
> > - Why SiPh wafer test is hard, and how AEHR, FormFactor, and Keysight each cover a different layer: ["The Three Pillars of SiPh Wafer Test"](https://photoncap.net/p/the-three-pillars-of-siph-wafer-test)[9][The Three Pillars of SiPh Wafer Test: What AEHR, FORM, and KEYS Actually Do](https://photoncap.net/p/the-three-pillars-of-siph-wafer-test)
> >
> > - Three signals from FormFactor's Q1 2026 earnings (SK hynix 29.5%, NVIDIA 10.2% first 10% disclosure, CPO revenue high-end guide), plus TRITON production entry, Keystone acquisition, Teradyne Photon 100 competition: ["FormFactor Q1 2026"](https://photoncap.net/p/formfactor-q1-2026-sk-hynix-295-nvidia)[5][FormFactor Q1 2026: SK hynix 29.5%, NVIDIA 10.2%, and the First CPO Test Revenue Signal](https://photoncap.net/p/formfactor-q1-2026-sk-hynix-295-nvidia)
> >
> > - F2C assembly companies in CPO optical packaging: [PC101 Lecture 4 Part 2](https://photoncap.net/p/pc101-lecture-4-the-last-millimeter)[10][[PC101] Lecture 4: The Last Millimeter: Who Builds It. CPO Packaging Value Chain and Next-Gen Applications (Part 2)](https://photoncap.net/p/pc101-lecture-4-the-last-millimeter)
> >
> > - Seven bonding equipment companies accelerating across HBM4 and CPO cycles: ["Seven Bonding Equipment Companies"](https://photoncap.net/p/7-bonding-equipment-companies-behind)[11][7 Bonding Equipment Companies Behind HBM4 and CPO: AI's Real Bottleneck Lives in Assembly](https://photoncap.net/p/7-bonding-equipment-companies-behind)
> >
> > - Damnang's Substack [Why You Should Be Watching Optical Test Right Now](https://damnang2.substack.com/p/why-you-should-be-watching-optical?utm_source=substack&utm_campaign=post_embed&utm_medium=web)
> >
> > This article builds on that technical foundation. The scope here is mapping the 4-stage CPO test insertion structure and identifying which companies occupy which roles at each stage.
> >
> > One more piece of context. CPO test market growth is not simply proportional to CPO chip shipments. Longer test times mean more equipment is needed. Testing 1 million PICs at 100 seconds each requires 100 million seconds, roughly 27,778 equipment-hours. At 24-hour operation and 85% uptime, a single test cell processes roughly 734 PICs per day, or about 22,000 per month. 100,000 per month requires roughly 5 single-site test cells. 1 million per month requires roughly 45. Add retesting, multiple insertions, and multi-engine architectures, and actual equipment demand exceeds these figures. The equipment competition is a test time compression competition. The company that cuts 100 seconds to 50, then to 25, can serve the same customer volume with less floor space and capex. This is why FormFactor emphasizes per-die test time reduction and ficonTEC pushes multi-site parallel testing. Throughput competition is the equipment market competition.
> >
> > > Bottom line: The fundamental reasons CPO test is hard are simultaneous electrical plus optical probing, nanometer alignment, and double-sided access. 100 seconds of test time per PIC directly determines how many production test cells are needed. These technical requirements open the market to specialized companies rather than the existing equipment large caps.
> >
> > ## 3. The 4 Insertion Framework and the Key Questions
> >
> > CPO testing is divided into four test insertions, from wafer to system.[12]
> >
> > *Figure 2: CPO Test 4 Insertion Flow Diagram — Burn-In (InP laser wafer, upstream process step screening for infant mortality) feeds into Insertion 1 PIC Wafer Test (OWAT — IL, PDL, crosstalk, coupler, DC electrical) → Insertion 2 EIC+PIC Combined Wafer (modulation, eye diagram, driver/TIA) → Insertion 3 Optical Engine (KGOE — full-link BER, thermal cycling, calibration) → Insertion 4 Module/System (SLT — data-path integrity, power, thermal, protocol). Cost of failure increases left-to-right. Data source: TrendForce CPO Testing Revolution report.*
> > ![[photoncap-880174-002.jpg]]
> >
> > Outside this four-stage framework, there is one more step. Burn-in. This is the process step that screens for infant mortality in InP lasers, performed before Insertion 1.
> >
> > Everything up to this point is visible from public data and the TrendForce report. Four insertions, plus burn-in as a separate step. You can figure this out from industry conference slides and equipment company press releases.
> >
> > The real differentiation starts here.
> >
> > These seven companies form two distinct competing axes within the four insertion stages, with the remaining companies classified as cross-axis layer players that are not tied to either axis. The technical strengths and weaknesses of each axis are precisely inverted.
> >
> > As a subscriber asked, are ficonTEC and Chroma competitors or coexisting at Insertion 3? The answer becomes clear once you understand the two-axis structure.
> >
> > One more thing. One of these seven companies has a Chinese ownership structure. With CPO test becoming a choke point in production, how this structural risk could influence customer vendor selection is covered in the paid section below.
> >
> > The paid section below breaks down the test station structure for each insertion and maps Bull/Gap/Optionality for each axis. How each axis's technical strength can flip into a weakness under specific conditions, and why cross-axis layer players remain relatively stable regardless of scenario, with quantitative data.
> >
> > Do the order-of-magnitude differences in market cap among these seven companies reflect their actual positioning in the CPO test market, or is the market still mispricing them? The answer requires understanding the insertion-by-insertion landscape first.
> >
> > One preview: the most interesting point of competition between the two axes is not technology. It is corporate structure. How one axis's key partner's ownership structure could distort customer vendor selection may be the most underpriced variable in the investment equation. Especially in the current environment where US-China technology competition is extending into the semiconductor equipment supply chain.
> >
> > ## Read the full article:
> >
> > ## [The 100-Second Bottleneck Behind NVIDIA CPO: 7 Companies That Own the 4-Stage Test Stack](https://photoncap.net/p/the-100-second-bottleneck-behind)
> >
> > Engagement: 140 likes | 23 retweets | 0 replies
> > [Original post](https://x.com/PhotonCap/status/2052650600001880174)
