---
created: 2026-06-18
published: 2026-06-18
description: Ming-Chi Kuo's authoritative breakdown of TSMC's leaked Glass Substrate Development for CoWoS slide (slide 27) from the 40-slide "Advanced Packaging Technology Essential to the Evolution of AI" presentation given June 11 at JPCA Show 2026 in Japan. Critical clarifications - COP on slide = Coplanarity NOT Chip-on-Package; within CoPoS the "oS" (substrate) matters more than the "CoP" because oS is must-have for chip viability while CoP is nice-to-have cost optimization; the "real gold" is PI improvement (thin glass → short TGV vertical conduction → R+L drop → freed power headroom → more AI compute that customers actually pay for). Glass core substrate is 3-layer (glass core sandwiched between 2 ABF build-up layers). Costs SEVERAL TIMES more per unit than ABF but substrate = low-single-digit % of AI chip BOM while packaging yield losses run 5-10x substrate cost. Innolux glass is single most critical material. Besides NVIDIA, two US-based customers expressed strong interest. Slide validates 250x250mm glass; 510x515mm pre-mass-production simulation 2H27; Ibiden currently cuts but may hand to Innolux. ABF spec = Ajinomoto GL107 + ABF-GCP 24-28 layers (mainstream 2027-2028). TGV is the key technology - TSMC declined Q&A details (know-how at TSMC + Innolux only). MP target 4Q28-1Q29 to match Nvidia AI chip cadence. Ibiden earnings slide CY30 timeline more conservative with reticle/Rubin Ultra inconsistencies vs TSMC's public claims - Kuo cross-check warning.
source: https://x.com/mingchikuo/status/2067438616188739960
type: research
authors: ["Ming-Chi Kuo (@mingchikuo)"]
---

# @mingchikuo 2026-06-18 — Ming-Chi Kuo TSMC Glass Core Substrate slide breakdown — COP = Coplanarity (not Chip-on-Package), oS > CoP within CoPoS, PI improvement is "the real gold", MP target 4Q28–1Q29 to match Nvidia cadence, 2 US customers beyond NVDA, Ajinomoto GL107 ABF spec

Ming-Chi Kuo (郭明錤) — the most-followed Apple/tech supply chain analyst — does the authoritative deep read on TSMC's leaked "Glass Substrate Development for CoWoS" slide from the 40-slide *Advanced Packaging Technology Essential to the Evolution of AI* presentation (AIの進化に不可欠な先端パッケージング技術) delivered June 11 at JPCA Show 2026 in Japan.

This piece completes the **3-piece June 2026 CoPoS cluster** alongside:
- [[@jukan05 2026-06-15 - TSMC + Ibiden + Innolux first joint glass-substrate validation - 16pct COP + 19pct CTE + 31pct modulus + 27pct R + 42pct L, 0.8mm glass 85x110mm 5x reticle AI GPU package, CoPoS pivot under Intel + Samsung pressure]] — supply-side news translation
- [[@damnang2 2026-06-16 - If CoPoS Arrives Who Makes Money First - 2-axis stock map CoPoS purity x path survival, 3-path uncertainty CoWoS-CoPoS-CoWoP, inspection at top of vertical axis, TSMC VisEra 2026 pilot, NVIDIA first customer, stock map paywalled]] — investment map framework

Kuo's read is the **authoritative voice** on the leaked slide and recalibrates several industry misreads.

## Key Takeaways

- **COP ≠ Chip-on-Package — COP = Coplanarity** (the leaked slide labels "COP -16%" and the entire industry-Twitter cycle was misreading this as Chip-on-Package improvement; Kuo's clarification is the single most-cited piece of analyst plumbing in this cluster).
- **Within CoPoS, the "oS" matters more than the "CoP"** — and that's exactly why TSMC tested the glass core substrate paired with existing **CoW** rather than with CoP. The CoP solves cutting economics / production efficiency (cost + price). The **oS solves warpage and durability — determines whether the chip can be made at all and whether it can work**. CoP = very-nice-to-have optimization; **oS = must-have**.
- **3-layer glass core substrate design**: glass core sandwiched between **two ABF build-up layers** using **Ajinomoto's GL107 mixed with ABF-GCP at 24–28 layers** — the mainstream ABF spec for AI chips 2027–2028. The glass processed by [[Innolux (3481.TW)]] is "**the single most critical material**". The glass core substrate costs **several times more per unit than existing ABF substrates**.
- **PI (Power Integrity) improvement is "the real gold"**: thin glass → short TGV (Through-Glass Via) vertical conduction path → conduction-path resistance **R drops -27%** + loop inductance **L drops -42%** → PI improves → more stable power delivery → **frees up power headroom** → room for more transistors or higher clock speeds → **more AI compute**. Customers pay for AI compute (their competitive advantage), not for TSMC's production efficiency (which they consider TSMC's basic responsibility). This is **why NVIDIA is so positive on glass core substrate, and why two unnamed US-based customers beyond NVIDIA have also expressed strong interest**.
- **The BOM math underwriting cost insensitivity**: substrate cost is currently a **low-single-digit % of AI chip BOM**, while **losses from packaging yield run roughly 5–10× the substrate cost**. So even a glass core substrate that costs several times more than today's ABF still has a small BOM share AND cuts packaging-yield losses. The high unit price will NOT dampen customer adoption willingness. For TSMC, glass core substrate is simultaneously **a cost-cutting tool AND a pricing lever** — raises yield + lowers cost + boosts compute + boosts ASP.
- **Mass production target: 4Q28–1Q29 to match Nvidia's AI chip iteration cadence** per industry checks. The Ibiden earnings presentation circulating recently lists glass core substrate at **CY30** — Kuo's read: Ibiden, conservative-and-cautious in public, formally putting glass core substrate on its roadmap further **confirms the long-term trend**, but the timeline gap reveals **Ibiden's reticle timeline is off from TSMC's public claims by ~1 generation** and **Ibiden's CY26–27 Rubin Ultra substrate size 90×90mm is clearly smaller than what TSMC has publicly claimed**. Kuo's cross-check warning: "always cross-check across multiple sources when forecasting the future."
- **TGV is the un-disclosed crown jewel**: in the Q&A after the presentation, an audience member asked about TGV details for the glass core substrate and **TSMC declined to answer on the spot** because TGV is the key technology behind the glass core substrate and the **core know-how currently sits with TSMC and [[Innolux (3481.TW)]]**. By contrast, when another attendee asked about integrating IVR + eDTC + LSI, TSMC answered at length. The differential disclosure is the signal.
- **The Ibiden → Innolux cutting handoff is the supply-chain micro-signal to watch**: [[Ibiden (4062.T)]] currently handles cutting the **250×250mm** glass core substrate. When the **510×515mm format** is used for pre-mass-production simulation in **2H27**, if Ibiden still wants to reduce production complexity to protect its ultra-high gross margins, it may **hand the cutting over to [[Innolux (3481.TW)]]**, which is more familiar with the properties of glass. (Watch for this transition as a leading indicator of who captures the glass-cutting revenue downstream.)
- **The leaked slide is page 27 of 40** — full presentation is titled *AIの進化に不可欠な先端パッケージング技術* (Advanced Packaging Technology Essential to the Evolution of AI) given by [[TSMC (TSM)]] at JPCA Show 2026 on June 11. The single leaked slide is "Glass Substrate Development for CoWoS" and the validation numbers (COP -16% / CTE -19% / Modulus +31% / R -27% / L -42% / 0.8mm glass / 5× reticle CoW / 85×110mm package size / "No SeWaRe & Delamination") match the @jukan05 supply-chain translation precisely — this is the same artifact viewed through two different authoritative lenses.

## TSMC's Leaked Slide

*TSMC slide 27 of 40 from the "Advanced Packaging Technology Essential to the Evolution of AI" presentation at JPCA Show 2026 (June 11, Japan). Title: "Glass Substrate Development for CoWoS". Top callout: "Benefit validated with simulation aid cross TSMC/Ibiden/Innolux collaboration". Bullet-1 = "PKG improvement: COP -16%; SBT effective CTE -19%; effective modulus +31%". Bullet-2 = "PI enhancement (simulation): R(mohm) -27%; L(nH) -42%". Bullet-3 = "Continuous investigation required such as glass thickness, layout for large size CoWoS". Lower-left visual = "CoWoS with Glass substrate" with cutaway diagram callouts "0.8mm glass core substrate / 5x reticle CoW / PKG size 85x110mm" and "No SeWaRe & Delamination". Center visual = "CoWoS PKG" cross-section showing SoC/SoIC die + HBM die stack on glass core substrate with annotations "COP, CTE, warpage improvement by glass core application" and "SIPI improvement by thinner glass thickness". Bottom-center = side-by-side comparison "Glass-SBT — Thin but better COP" vs "Organic-SBT — Thick but worse COP". Right = two curves vs CoW Size — top "PKG Stress" and bottom "PKG Coplanarity" — both showing glass-SBT plot below the organic-SBT plot as CoW size grows. © 2026 TSMC, Ltd. TSMC Property.*

![[mingchikuo-739960-001.jpg]]

## Original Content

**@mingchikuo (郭明錤｜Ming-Chi Kuo) — 2026-06-18 02:45:51 GMT — <https://x.com/mingchikuo/status/2067438616188739960>**

> Breaking down TSMC's glass core substrate slide
>
> On June 11, at JPCA Show 2026 in Japan, TSMC gave a roughly 40-slide presentation titled "Advanced Packaging Technology Essential to the Evolution of AI" (AIの進化に不可欠な先端パッケージング技術). One slide from the deck, titled "Glass Substrate Development for CoWoS," has since leaked online and widespread attention.
>
> Here's a closer read of that slide (see attached image). I'll skip the technical background that is already widely available. **One thing to flag: the "COP" on the slide does not stand for Chip-on-Package. It means Coplanarity.**

### ▌ Key conclusions

1. **TSMC has officially announced a partnership with Ibiden and Innolux to develop a glass core substrate.** The structure is a three-layer design, a glass core sandwiched between two ABF build-up layers. This is the "oS" in CoPoS.

2. **The market underestimates how important the glass core substrate is. It's a must-have capability for TSMC.** In other words, within CoPoS the "oS" matters more than the "CoP", which is also why, when it was tested, it was paired with the existing CoW rather than with CoP.

3. **The glass core substrate costs several times more per unit than existing ABF substrates.** The glass processed by Innolux is very expensive per unit and is the single most critical material. **Besides Nvidia, two US-based customers have also expressed strong interest.**

### ▌ Industry checks tied to this slide

1. The glass core substrate shown on the slide is cut from a **full-size 250×250mm** one. The ABF build-up layers mainly use **Ajinomoto's GL107, mixed with ABF-GCP, and were tested at 24–28 layers, which is the mainstream ABF spec for AI chips in 2027–2028**.

2. The CoW used in TSMC's experiment is a test vehicle. It is sufficient to validate the most challenging mechanical-structure issues that arise when working with composite materials. **Good results mean TSMC, Ibiden, and Innolux have together broken through the critical technical bottleneck.**

3. **Ibiden currently handles cutting the 250×250mm glass core substrate. When the 510×515mm format is used for pre-mass-production simulation in 2H27, if Ibiden still wants to reduce production complexity to protect its ultra-high gross margins, it may hand the cutting over to Innolux, which is more familiar with the properties of glass.**

### ▌ The leaked slide shows the validation results

The leaked slide shows the validation results of pairing CoW with the "oS" in CoPoS, i.e., the glass core substrate (labeled "**glass-SBT**" on the slide). This addresses the "**Substrate mechanical and electrical Dilemma**" raised on the previous slide, and it strongly underscores how important the "oS" is within CoPoS.

1. **Within CoPoS, what CoP solves is production efficiency / cutting economics, which ties to cost and price. What the oS solves is warpage and durability, which determines whether the chip can be made at all, and whether it can work.**

2. CoP and oS complement each other well when integrated, but looking out over the next few years their technical roles still differ. **CoP is a very-nice-to-have optimization, and going without it simply means a more expensive chip. But the oS is a must-have. Without it, even being able to make a usable chip is in doubt.**

3. Comparing their roles isn't about elevating oS at the expense of CoP. It comes down to the practical question of which technical piece customers are willing to pay for. Details below.

### ▌ The real gold here is the power integrity (PI) improvement

The PI improvement shown on the slide matters a great deal to customers, and **once glass core substrate production stabilizes, TSMC's profitability and competitive edge should rise in tandem**.

1. **How it works**: the glass core substrate is thin → the vertical conduction path through TGV (through-glass vias) is short → conduction-path resistance (R) and loop inductance (L) both drop → PI improves.

2. **Why it matters to customers**: better PI → more stable power delivery → frees up power headroom → room to integrate more transistors, or to push clock speeds higher → **more AI compute**.

3. **For customers, production efficiency is TSMC's basic responsibility, so they won't pay extra for it. But gains in AI compute translate directly into the customer's own competitiveness and profit, so customers are willing to pay for that. This is why Nvidia is so positive on the glass core substrate.**

4. **For TSMC, the glass core substrate raises yield and lowers cost while also boosting both the compute and the selling price of AI chips.** It's both a cost-cutting tool and a pricing lever, a plus for profitability and competitiveness alike.

5. **Substrate cost currently accounts for a low single-digit percentage of an AI chip's BOM, while losses from packaging yield run roughly 5–10× the substrate cost.** So even if the glass core substrate ends up costing several times more than today's, its share of the BOM stays low, and it can cut the losses from packaging yield. **The high unit price is therefore not expected to dampen customers' willingness to adopt it.**

### ▌ Q&A — what TSMC would and would not answer

In the Q&A after the presentation, an audience member asked about TGV details for the glass core substrate. **TSMC declined to answer on the spot, because TGV is the key technology behind the glass core substrate, and the core know-how currently sits with TSMC and Innolux.** By contrast, when another attendee asked about integrating IVR, eDTC, and LSI, TSMC answered at length.

### ▌ Mass production timeline

According to industry checks, if all goes well, **TSMC is aiming to start mass production of the glass core substrate in 4Q28–1Q29, to match the cadence of Nvidia's AI chip iterations**.

As a side note: the **Ibiden earnings presentation slide** that many people have been circulating lists the glass core substrate timeline as **CY30**. My read is this: Ibiden, which has always been conservative and cautious in public, has now formally put the glass core substrate on its roadmap, which further confirms the long-term trend for this technology.

That said, some other details on Ibiden's slide don't fully line up with what's known in the market. For example, its **reticle timeline is off from TSMC's public claims by about a generation**, and the **Rubin Ultra substrate size is clearly larger than the 90×90 it marked for CY26–27**. **It's a reminder to always cross-check across multiple sources when forecasting the future.**

---

## Substantive Reader Replies

**@7998l201 (Ryan) — 2026-06-18 03:38 GMT (translated from Chinese):**

> I'd frame this as AI packaging bottleneck spillover from CoWoS capacity to substrate materials and processes. What customers are willing to pay for isn't "new materials" but the compute density that comes from PI, yield, and usable package area. If the 2028–2029 cadence holds, worth tracking [[TSMC (TSM)]], [[Ibiden (4062.T)]], [[Innolux (3481.TW)]], ABF materials ([[Ajinomoto (2802.T)]]), and inspection equipment ([[KLA Corporation (KLAC)]], [[Lasertec (6920.T)]], [[Onto Innovation (ONTO)]]).

*Verbatim Chinese original: "我会把它看成 AI 封装瓶颈从 CoWoS 产能继续外溢到基板材料和工艺。客户愿意付费的不是"新材料"，而是 PI、良率和可用封装面积带来的算力密度。若 2028-2029 节奏成立，值得跟踪 TSMC、Ibiden、Innolux、ABF 材料和检测设备。"*

**@ValentinMoeller (Valentin Möller) — 2026-06-18 03:58 GMT (German):** "@grok kannst du das bitte in etwas einfacheres Englisch übersetzen? So viele Abkürzungen…ich würde gern verstehen, was der Kern der Innovation ist" → English translation: "Can you please translate that to simpler English? So many abbreviations… I'd like to understand what the core of the innovation is." (Acknowledgement that Kuo's piece is technically dense for non-supply-chain-native readers.)

## Cross-Links

### Direct CoPoS cluster siblings (June 2026, REQUIRED)
- [[@jukan05 2026-06-15 - TSMC + Ibiden + Innolux first joint glass-substrate validation - 16pct COP + 19pct CTE + 31pct modulus + 27pct R + 42pct L, 0.8mm glass 85x110mm 5x reticle AI GPU package, CoPoS pivot under Intel + Samsung pressure]] — the supply-side news translation Kuo is responding to
- [[@damnang2 2026-06-16 - If CoPoS Arrives Who Makes Money First - 2-axis stock map CoPoS purity x path survival, 3-path uncertainty CoWoS-CoPoS-CoWoP, inspection at top of vertical axis, TSMC VisEra 2026 pilot, NVIDIA first customer, stock map paywalled]] — the investment-map framework

### PhotonCap glass substrate cluster
- [[PhotonCap May 2026 - 15-company glass substrate cycle map frames 2026 as pilot-qualification phase with 2027-2030 volume ramp across AI accelerators HBM4 interposer and CPO]]
- [[PhotonCap May 2026 addendum - glass substrate thesis extends from EIC-only to EPIC electronic-photonic integration with conceptual TGV+PIC+ASIC+HBM package diagram from Haifeng Xuan LinkedIn]]
- [[PhotonCap 2026-05 - LPKF up 255 pct YTD as LIDE TGV process becomes glass substrate chokepoint for EIC-to-CPO packaging shift]] — LPKF LIDE TGV equipment chokepoint (Kuo's TGV know-how moat applies here)

### Ticker hubs named in body
- [[TSMC (TSM)]] (the slide owner; AP7 Chiayi MP site)
- [[Ibiden (4062.T)]] (250×250mm cutting + ¥500B Ono investment)
- [[Innolux (3481.TW)]] (glass processing + likely 510×515mm cutting handoff 2H27)
- [[Ajinomoto (2802.T)]] (ABF GL107 + ABF-GCP at 24–28 layers — NEWLY SCAFFOLDED in this capture)
- [[NVIDIA (NVDA)]] (first customer; cadence anchor)

### Inspection equipment (the damnang2 "top of vertical axis" thesis)
- [[KLA Corporation (KLAC)]]
- [[Lasertec (6920.T)]]
- [[Onto Innovation (ONTO)]]
- [[Applied Materials (AMAT)]]
- [[Cohu (COHU)]] — HBM 100% inspection (BlackPantherCap dual chokepoint)

### Adeia hybrid bonding adjacency
- [[Adeia (ADEA)]] — the IP toll booth on hybrid bonding (CBA / DBI), adjacent advanced-packaging IP layer

### Companion @jukan05 + author-voice
- [[@jukan05 2026-05-28 - TSMC CEO internal Q&A translation - 10pct profit share no floor guarantee, dividend increase considered, AI automation to cut headcount, 95pct world AI chips mgmt interject TSMC severely undervalued, Musk 2x poaching dismissed]]
- [[@jukan05 memory-wall optical HBM-GPU interconnect - shoreline limit + OSAT sequence]]
