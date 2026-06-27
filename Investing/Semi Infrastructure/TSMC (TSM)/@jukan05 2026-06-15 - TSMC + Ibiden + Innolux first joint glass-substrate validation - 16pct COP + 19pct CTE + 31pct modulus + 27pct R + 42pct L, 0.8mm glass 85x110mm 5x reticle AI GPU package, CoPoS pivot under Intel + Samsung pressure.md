---
created: 2026-06-16
published: 2026-06-15
description: "@jukan05 English translation of TSMC supply-chain reporting on the FIRST public disclosure of joint glass-substrate validation results with [[Ibiden (4062.T)]] + [[Innolux (3481.TW)]] for the CoWoS-to-CoPoS (Chip-on-Panel-on-Substrate) next-generation advanced-packaging transition. Headline test data: package warpage COP +16% improvement, Effective CTE -19% (better silicon match), Effective Modulus +31% (HBM-stack rigidity), Resistance -27%, Inductance -42% (power integrity). Test sample: 0.8mm glass core substrate, 5x reticle CoW, 85×110mm AI GPU-class package. 'No SeWaRe & Delamination' — yield killers avoided. Glass-SBT 'thin but better COP' vs Organic-SBT 'thick but worse COP'. Strategic framing: TSMC's historic 'cautious not aggressive' R&D posture flipping to 'step on the accelerator' under Intel (10+ year glass R&D, Arizona pilot line) + Samsung Electro-Mechanics (2025 pilot + Sumitomo Chemical JV) competitive pressure, with NVIDIA Rubin platform AI-GPU package-size inflation as the demand driver. Ibiden ¥500B Ono plant Gifu Prefecture investment for AI server high-end packaging substrates anchors the supply-chain commitment. Biggest remaining chokepoint: Through Glass Via (TGV) — tens of thousands of vertical conductive paths per substrate, with via forming + copper-fill quality + long-term thermal reliability as the 3 core mass-production hurdles (glass brittle + hard, prone to micro-cracks)."
source: https://x.com/jukan05/status/2066651558784463190
type: research
authors: ["Jukan (@jukan05)"]
---

# @jukan05 2026-06-15 - TSMC + Ibiden + Innolux first joint glass-substrate validation - 16pct COP + 19pct CTE + 31pct modulus

## Key Takeaways

- **The strategic frame: TSMC's CoWoS-to-CoPoS pivot is now visible in the supply chain, and TSMC's R&D culture has flipped from "cautious not aggressive" to "step on the accelerator."** Per the supply-chain reporting [[TSMC (TSM)]] translated by @jukan05: TSMC is *"not only ramping CoWoS advanced packaging capacity but has, for the first time, disclosed progress on its 'glass substrate' technology. The company further signaled that the next-generation advanced packaging battle is gradually shifting from CoWoS to CoPoS (Chip-on-Panel-on-Substrate)."* The cultural pivot framing is itself the news — TSMC has historically advanced R&D *"on a 'cautious, not aggressive' basis,"* and the equipment-side disclosure of the **Glass Substrate Development for CoWoS program** to its supply chain signals the rate-of-change inflection more than any single technical milestone. Trigger: rapidly intensifying customer technical/capacity demands plus mounting Intel + Samsung competitive pressure.

- **The first public joint validation data (TSMC + [[Ibiden (4062.T)]] + [[Innolux (3481.TW)]], 5x reticle CoW + 85×110mm AI GPU-class footprint + 0.8mm glass core substrate)** — this is the load-bearing artifact, every number must be preserved verbatim:
  - **COP (Chip on Package) package warpage indicator: +16% improvement** ← directly addresses the GB200/GB300/Rubin package-size inflation problem; as AI GPU dies grow ever larger, package flatness + warpage control rise sharply in importance, and the 16% gain should lift yield + reliability of large packages
  - **Effective CTE (coefficient of thermal expansion): -19%** ← glass CTE moves materially closer to silicon vs the conventional organic substrate, reducing the thermal-stress / solder-joint-fatigue / cracking failure modes that organic substrates suffer under temperature swings
  - **Effective Modulus: +31%** ← higher overall rigidity / better structural support; critical specifically as HBM stack heights keep increasing, where substrate rigidity becomes a *"critical condition for supporting large packages"*
  - **Power integrity**: Resistance **-27%** and Inductance **-42%** ← significant marginal-power-delivery gains for AI accelerators where IR drop + di/dt are first-order constraints
  - **Qualitative pass**: *"No SeWaRe (severe warpage) & Delamination"* — both yield killers — occurred during testing, proving material-bonding-reliability stability at large package sizes
  - **Glass-SBT vs Organic-SBT comparison**: Glass-SBT achieves *"thin but better COP,"* Organic-SBT shows *"thick but worse COP"* — i.e. glass beats organic on both axes simultaneously (geometry + flatness)

- **TSMC's own caveats**: continued research + validation needed on **(a) glass thickness** and **(b) large-size CoWoS layout**. Full-scale mass production *"remains some distance away."* But this is the FIRST time TSMC has publicly disclosed joint glass-substrate validation results with Ibiden + Innolux — *"signaling that glass substrates have formally entered the industrialization-validation phase."* The phase-transition language is itself the news: industrialization-validation comes after lab R&D and before mass production, and it's the phase that anchors capex commitments + supplier qualification cycles.

- **Ibiden is the load-bearing supply-chain anchor**. Per the translation: *"Ibiden currently sits in the critical substrate supply chain for [[Nvidia (NVDA)]] and [[Advanced Micro Devices (AMD)]] AI chips and is regarded as a key player in industrializing glass substrates."* **Ibiden previously announced a ¥500 billion investment to expand its new Ono plant in Gifu Prefecture, dedicated to high-end packaging substrates for AI servers** — i.e. the capital commitment to AI-substrate volume is already in flight, predating the TSMC joint validation disclosure. This makes the TSMC-Ibiden joint program the natural channel through which Ibiden's ¥500B Ono investment converts into glass-substrate-specific revenue if validation continues to track. Innolux's inclusion is *"likewise seen as an important step toward staking out the next-generation glass-substrate battlefield"* — i.e. a panel maker (display-glass + Gen-N panel-handling heritage) crossing into semi advanced packaging is itself a category convergence signal.

- **The Through Glass Via (TGV) chokepoint = the real story for equipment-stack investors**. Per the translation: *"the biggest challenge for glass substrates is not the glass itself but Through Glass Via (TGV) technology. Because glass is fundamentally an insulator, tens of thousands of TGVs must be formed to create vertical conductive paths before signal and power transmission becomes possible. Glass is also both hard and brittle, making it prone to micro-cracks during processing that can affect reliability and yield. As a result, **via forming, copper-fill quality, and long-term thermal reliability are considered the three core hurdles to mass-producing glass substrates**."* This is the exact framing that anchors the [[PhotonCap 2026-05 - LPKF up 255 pct YTD as LIDE TGV process becomes glass substrate chokepoint for EIC-to-CPO packaging shift]] thesis on [[LPKF Laser (LPK.DE)]]'s LIDE TGV process moat. @jukan05's TSMC-anchored translation is the foundry-side independent corroboration of the equipment-side thesis — when both the foundry (TSMC) and the equipment specialist (LPKF) point at TGV as the chokepoint, the structural call gets a second leg.

- **Intel's 10+ year glass-substrate R&D moat + Arizona pilot line is the competitive forcing function on TSMC.** Per the translation: *"[[Intel (INTC)]] began investing in glass-substrate R&D more than a decade ago and is regarded as the earliest and deepest player globally. Its glass-substrate pilot line in Arizona is gradually moving toward commercialization, and Intel is aiming to win AI GPU and ASIC customer orders through glass substrates and ultra-large chiplet packaging."* Intel's positioning here is dual-purpose: (a) IFS (Intel Foundry Services) competition for TSMC's AI GPU + ASIC orders, and (b) glass + ultra-large chiplet as the architecturally-differentiated value proposition vs TSMC's CoWoS+CoPoS roadmap. The 10+ year R&D lead is not necessarily transferable to volume manufacturing (TSMC's catch-up speed is well-precedented), but the competitive pressure is asymmetric — Intel doesn't need to *win* the AI-foundry war, just credibly threaten enough orders to force TSMC's accelerated cadence.

- **Samsung Electro-Mechanics (SEMCO) 2025 pilot + Sumitomo Chemical JV is the second-front competitive pressure.** Per the translation: *"[[Samsung Electro-Mechanics (009150.KS)]] established a glass-substrate pilot line in 2025 and has set up a joint venture with Japan's Sumitomo Chemical group to build out a glass-substrate supply chain ahead of the market."* The Sumitomo Chemical JV is the materials-supply leg — Sumitomo's glass / specialty-materials heritage gives SEMCO a supply-chain depth that pure-play substrate makers can't easily replicate. Samsung's parallel pressure on TSMC (foundry-side + substrate-side simultaneously) is what closes the strategic logic on TSMC's *"step on the accelerator"* shift.

- **Demand-side: NVIDIA Rubin platform package-size inflation is the explicit driver.** Per the translation: *"As AI GPU dies grow ever larger—with [[Nvidia (NVDA)]]'s GB200, GB300, and the now-ramping Rubin platform all expanding in package size—the importance of package flatness and warpage control has risen sharply."* Rubin is the rate-limiting demand signal: the GB200 + GB300 packages are already at the edge of what conventional organic substrates can support at acceptable yield, and Rubin extends that further. The 85×110mm AI-GPU-class footprint in the test sample is the explicit calibration to Rubin-era package dimensions. This is the same Rubin-platform anchor that drives the [[@PhotonCap 2026-05-28 Third Signal MRVL Q1 FY27 confirms LITE COHR AI optical signal - NVDA $6B supply chain blueprint via 3 $2B commitments, interconnect FY27 +50pct to +70pct, FY28 $15B to $16.5B raise, scale-out scale-up scale-across]] supply-chain blueprint — glass substrates + LITE/COHR optics + advanced packaging are all rate-limited by the same NVIDIA-rack volume curve.

- **The author-voice continuity matters: this is the second @jukan05 TSMC translation in 18 days**, following [[@jukan05 2026-05-28 - TSMC CEO internal Q&A translation - 10pct profit share no floor guarantee, dividend increase considered, AI automation to cut headcount, 95pct world AI chips mgmt interject TSMC severely undervalued, Musk 2x poaching dismissed]]. The pattern signal: @jukan05 has now bracketed TSMC from both ends — the internal-employee CEO Q&A (revealing the *"95% of world AI chips"* + *"severely undervalued"* mgmt voice) and the supply-chain technical disclosure (revealing the cadence shift on advanced packaging). Together they support a triangulated read on TSMC: structurally undervalued per management AND structurally pivoting per the engineering organization, with both moves dated within a 3-week window.

## Wiki-link Sweep

**Subject hubs (3 named tickers + 2 competitor hubs)**:
- [[TSMC (TSM)]] (subject hub — note placed in this folder per CLAUDE.md sibling-to-prior-jukan05-translation rule)
- [[Ibiden (4062.T)]] (existing hub — ¥500B Ono Gifu plant investment is the load-bearing supply-chain commitment)
- [[Innolux (3481.TW)]] (newly scaffolded — panel maker crossing into semi advanced packaging)
- [[Intel (INTC)]] (competitor — 10+ year glass R&D lead, Arizona pilot line)
- [[Samsung Electro-Mechanics (009150.KS)]] (competitor — 2025 pilot + Sumitomo JV)

**Demand-side AI customer hubs**:
- [[Nvidia (NVDA)]] (Rubin / GB200 / GB300 package-size inflation = demand driver)
- [[Advanced Micro Devices (AMD)]] (Ibiden substrate customer alongside NVIDIA)
- [[Broadcom (AVGO)]] (ASIC TAM that Intel is targeting via "glass + ultra-large chiplet")

**REQUIRED sibling (prior @jukan05 TSMC translation in same folder)**:
- [[@jukan05 2026-05-28 - TSMC CEO internal Q&A translation - 10pct profit share no floor guarantee, dividend increase considered, AI automation to cut headcount, 95pct world AI chips mgmt interject TSMC severely undervalued, Musk 2x poaching dismissed]] — establishes the author-voice continuity + the 3-week bracketing pattern (CEO-side + engineering-side TSMC reads from same author)

**REQUIRED PhotonCap glass-substrate cluster cross-links (same topic, different author voice — independent corroboration)**:
- [[PhotonCap 2026-05 - LPKF up 255 pct YTD as LIDE TGV process becomes glass substrate chokepoint for EIC-to-CPO packaging shift]] — TGV as chokepoint, equipment-side thesis on [[LPKF Laser (LPK.DE)]] that this @jukan05 translation directly corroborates via the *"via forming + copper-fill quality + long-term thermal reliability = 3 core hurdles"* framing
- [[PhotonCap May 2026 - 15-company glass substrate cycle map frames 2026 as pilot-qualification phase with 2027-2030 volume ramp across AI accelerators HBM4 interposer and CPO]] — landscape map of the 15 companies whose timing the @jukan05 *"industrialization-validation phase"* framing now anchors
- [[PhotonCap May 2026 addendum - glass substrate thesis extends from EIC-only to EPIC electronic-photonic integration with conceptual TGV+PIC+ASIC+HBM package diagram from Haifeng Xuan LinkedIn]] — the EIC-to-EPIC extension that makes the TSMC-Ibiden-Innolux validation broader than just AI-GPU substrates

**TGV equipment chokepoint**:
- [[LPKF Laser (LPK.DE)]] (LIDE TGV process specialist — directly corroborated by the *"3 core hurdles"* framing above)

**Adjacent AI-infrastructure supply-chain context (the broader Rubin-platform rate-limiter cluster)**:
- [[@PhotonCap 2026-05-28 Third Signal MRVL Q1 FY27 confirms LITE COHR AI optical signal - NVDA $6B supply chain blueprint via 3 $2B commitments, interconnect FY27 +50pct to +70pct, FY28 $15B to $16.5B raise, scale-out scale-up scale-across]] — the broader NVDA $6B optical supply-chain blueprint that this glass-substrate validation rides parallel to

**Materials supply (mentioned in source, not in vault)**:
- Sumitomo Chemical (Tokyo: 4005.T) — Samsung Electro-Mechanics JV partner for glass-substrate supply chain. **NOT scaffolded** (single mention, materials-chemicals adjacency outside Semi Infrastructure scope without a stronger anchor). Flagged for future capture if a Sumitomo-direct thesis lands.

**Reader-signal flag (NOT scaffolded — flagged for future)**:
- Taimide (TLC, 6274.TW) — per @qiushao87's Chinese-language reply: *"tsm为何不找台光合作 / 台光也在做abf载板 并拿到了谷歌订单"* = *"Why doesn't TSMC partner with Taimide (TLC, 6274.TW)? Taimide also makes ABF substrates and won [[Alphabet (GOOGL)]] orders."* Reader-only reference, brief explicitly says do NOT auto-scaffold. Flag for future capture if a Taimide-direct thesis or substantive Google-substrate-order disclosure lands.

## Original Content (verbatim)

### Main Post — @jukan05 2026-06-15 22:38 UTC

> TSMC Teams Up with Ibiden and Innolux to Push CoPoS — Reportedly Flooring the Accelerator in Glass Substrates
>
> To meet robust AI chip demand, TSMC is not only ramping CoWoS advanced packaging capacity but has, for the first time, disclosed progress on its "glass substrate" technology. The company further signaled that the next-generation advanced packaging battle is gradually shifting from CoWoS to CoPoS (Chip-on-Panel-on-Substrate), as it moves to build out a complete ecosystem ahead of the curve.
>
> According to equipment-side sources, TSMC recently shared a "Glass Substrate Development for CoWoS" program with its supply chain. It has confirmed a partnership with ABF substrate giant Ibiden and panel maker Innolux to jointly validate the feasibility of introducing glass substrates into next-generation CoWoS advanced packaging. The aim is to address the warpage, thermal management, signal transmission, and power delivery challenges that loom over future large-die AI chip packaging.
>
> At the same time, the move reflects rapidly intensifying customer demands around technical specifications and capacity, as well as mounting competitive pressure from Intel and Samsung Electronics. That pressure has finally pushed TSMC—long known for advancing R&D on a "cautious, not aggressive" basis—to step on the accelerator.
>
> Glass substrates are viewed as a key technology for the "post-CoWoS era" thanks to their low warpage, low thermal expansion, high rigidity, and excellent signal and power-delivery characteristics. Supply chain sources say the three-way collaboration among TSMC, Ibiden, and Innolux, together with simulation validation, has shown that glass substrates can improve the package-warpage indicator COP (Chip on Package) by 16%, lower the effective coefficient of thermal expansion (Effective CTE) by 19%, and raise the effective modulus (Effective Modulus) by 31%.
>
> On power integrity, resistance fell by 27% and inductance by 42%. Overall, introducing glass substrates can deliver a marked improvement in package performance (PKG Improvement).
>
> TSMC nonetheless stressed that continued research and validation are still needed on glass thickness (Glass Thickness) and large-size CoWoS layout (Large-size CoWoS Layout). While full-scale mass production remains some distance away, this marks the first time TSMC has publicly disclosed joint glass-substrate validation results with Ibiden and Innolux—signaling that glass substrates have formally entered the industrialization-validation phase.
>
> Industry observers added that the 16% COP improvement indicates package warpage is being effectively controlled. As AI GPU dies grow ever larger—with NVIDIA's GB200, GB300, and the now-ramping Rubin platform all expanding in package size—the importance of package flatness and warpage control has risen sharply. The performance glass substrates show in reducing warpage should help lift the yield and reliability of large packages.
>
> In addition, the 19% reduction in SBT effective CTE shows improved matching between the glass material and the silicon die.
>
> Today, silicon's CTE differs substantially from that of conventional organic substrates, making it prone to stress under temperature swings that can compromise package reliability. By contrast, glass has a CTE closer to that of silicon, which helps reduce thermal stress and mitigate cracking and solder-joint fatigue. The 31% gain in effective modulus means higher overall rigidity, providing better structural support. In particular, as HBM stack heights keep increasing, substrate rigidity is becoming a critical condition for supporting large packages.
>
> The test sample TSMC used this time featured a 0.8mm glass core substrate, a package spec of 5x reticle CoW, and an overall package size of 85×110mm—an AI GPU package-class footprint. TSMC specifically emphasized "No SeWaRe (severe warpage) & Delamination," meaning no severe warpage or delamination/peeling—both yield killers—occurred during testing.
>
> For glass substrates, material bonding reliability has always been a key challenge, so maintaining a stable structure at large package sizes demonstrates considerable progress in technical maturity.
>
> Another focus of the program was the comparison between Glass-SBT and Organic-SBT. TSMC noted that Glass-SBT achieves "thin but better COP," whereas Organic-SBT shows "thick but worse COP"—glass substrates can stay thinner while simultaneously improving package flatness and reliability.
>
> The partner roster also hints at the direction of the future supply chain.
>
> Ibiden currently sits in the critical substrate supply chain for NVIDIA and AMD AI chips and is regarded as a key player in industrializing glass substrates. It previously announced a ¥500 billion investment to expand its new Ono plant in Gifu Prefecture, dedicated to high-end packaging substrates for AI servers—underscoring its strong ambitions in the AI advanced-packaging market. Innolux's inclusion on the partner list is likewise seen as an important step toward staking out the next-generation glass-substrate battlefield.
>
> Industry sources say the biggest challenge for glass substrates is not the glass itself but Through Glass Via (TGV) technology. Because glass is fundamentally an insulator, tens of thousands of TGVs must be formed to create vertical conductive paths before signal and power transmission becomes possible.
>
> Glass is also both hard and brittle, making it prone to micro-cracks during processing that can affect reliability and yield. As a result, via forming, copper-fill quality, and long-term thermal reliability are considered the three core hurdles to mass-producing glass substrates.
>
> Separately, Intel began investing in glass-substrate R&D more than a decade ago and is regarded as the earliest and deepest player globally. Its glass-substrate pilot line in Arizona is gradually moving toward commercialization, and Intel is aiming to win AI GPU and ASIC customer orders through glass substrates and ultra-large chiplet packaging.
>
> Samsung Electro-Mechanics (Semco) established a glass-substrate pilot line in 2025 and has set up a joint venture with Japan's Sumitomo Chemical group to build out a glass-substrate supply chain ahead of the market.
>
> $TSM

### Image (TSMC booth display)

*Trade-show booth display photograph (low-resolution) showing the TSMC CoPoS exhibit. Visible text fragments include "#CoPoS", "Max. Production Capability", "Easy" and "Resistance" labels, plus a glass-panel rendering. The image is part of @jukan05's translation post — likely sourced from the same TSMC supply-chain-program disclosure event that anchors the validation data above. The booth display is the visual confirmation that TSMC has formally moved CoPoS into externally-presented status, consistent with the source's "first public disclosure" framing.*
![[jukan-463190-001.png]]

### Author self-reply — @jukan05 2026-06-15 22:38 UTC

> https://t.co/pMqFk3nEnm

*(self-reply contains only a t.co source link — preserved verbatim above; no body content)*

### Substantive reader replies (verbatim)

**@Colosteve2000 (Steven Martin) — 2026-06-15 22:51 UTC** *(English-language synthesis tying TSMC's posture shift to Intel + Samsung + NVIDIA pressure and identifying TGV as the remaining hurdle)*

> Obviously, TSMC is feeling pressure from Intel and Samsung,
>
> TSMC's caution-to-acceleration shift makes sense, pressure from Nvidia pressure from Intel/Samsung breathing down their neck.
>
> Intel has been at this for over a decade and has a pilot line in Arizona;
>
> Samsung Electro-Mechanics is moving fast with a 2025 pilot also Sumitomo JV.
>
> TSMC partnering with Ibiden (already critical for NVIDIA/AMD substrates) and Innolux shows they're building the ecosystem aggressively.
>
> Biggest remaining hurdles as indicated :Through-Glass Vias (TGV) — forming, copper fill quality, and reliability at scale.
> Brittleness and micro-cracks during processing.
>
> Proving it at volume and competitive cost. If anyone has the engineering department and money to catch up quick its TSMC!!

**@qiushao87 (QiuShao) — 2026-06-15 23:31 UTC** *(Chinese-language reader signal flagging Taimide / TLC as a missed partnership candidate)*

> tsm为何不找台光合作
> 台光也在做abf载板 并拿到了谷歌订单

*English translation: "Why doesn't TSMC partner with Taimide (TLC, 6274.TW)? Taimide also makes ABF substrates and won Google orders."*

**@Hamburgerai (蛋黄堡) — 2026-06-16 00:22 UTC** *(Chinese-language emphasis on the CTE + modulus data as the key signal)*

> 玻璃基板在降低CTE失配和提高刚性上的数据很亮眼，19% CTE降低+31%模量提升，直接解决大尺寸AI GPU的翘曲和可靠性痛点，TSMC这次加速验证是明智之举。

*English translation: "Glass substrate data on CTE mismatch reduction and rigidity improvement is impressive — the 19% CTE reduction + 31% modulus improvement directly solve the warpage and reliability pain points of large-size AI GPUs. TSMC's accelerated validation this time is a wise move."*

**@AI4Azure (Azure | 数据分析万物) — 2026-06-16 02:45 UTC** *(Chinese-language investment-thesis frame on tracking top-tier foundry roadmaps)*

> 跟紧头部大厂的技术路线图投资，他们绝对知道些什么

*English translation: "Invest by tracking the technology roadmaps of top-tier large manufacturers closely — they definitely know something."*

### Filtered (impersonation/spam)

- @JeanBlanco86 ("Jnkeu"), 2026-06-16 03:01 UTC — *"My internal plan is as follows ⬇️"* — impersonation/bot account targeting the @jukan05 thread audience. Filtered per CLAUDE.md spam-filtering rule; existence noted, content not transcribed.

---

*Captured 2026-06-16 from <https://x.com/jukan05/status/2066651558784463190>. Source published 2026-06-15 22:38 UTC. Full thread retrieved via `bird thread --plain` (96 lines / 9.4KB) — complete, no agent-browser fallback needed. 1 PHOTO extracted (slug `jukan-463190`): TSMC booth display showing CoPoS exhibit, saved + embedded in `Semi Infrastructure/_media/` with caption noting visible text fragments + provenance framing. Innolux (3481.TW) hub scaffolded in Semi Infrastructure via `invest add-ticker`. Ibiden + TSMC + Intel + Samsung Electro-Mechanics hubs already existed; wiki-linked. Taimide (TLC, 6274.TW) flagged as potential future scaffold from @qiushao87's reader-only reference. Sumitomo Chemical (4005.T) flagged as potential future scaffold from materials-supply leg of Samsung Electro-Mechanics JV.*
