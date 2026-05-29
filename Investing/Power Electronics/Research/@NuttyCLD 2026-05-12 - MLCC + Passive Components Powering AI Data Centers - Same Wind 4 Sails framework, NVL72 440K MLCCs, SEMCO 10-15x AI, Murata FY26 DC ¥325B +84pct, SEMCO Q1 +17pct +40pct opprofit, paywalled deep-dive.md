---
created: 2026-05-29
published: 2026-05-12
description: NuttyCLD's "Same Wind, Four Sails" framework for AI passive-component investing — 4 families inside the AI server power path (MLCCs + hybrid polymer capacitors + power inductors + 800V magnetics) are all exposed to the same AI server demand wind but the market rewards them differently. NVIDIA NVL72 ~440,000 MLCCs per cabinet; next-gen GB300 estimated tens of thousands per server; SEMCO has said AI servers require 10-15× more MLCCs than general-purpose servers. April 30 2026 disclosures: Murata (6981.T) FY2025 results + FY2026 guidance with newly-visible datacenter-related revenue breakdown of ¥325B for FY2026 (+84% YoY); Samsung Electro-Mechanics (009150.KS, "SEMCO") Q1 2026 +17% revenue / +40% operating profit YoY citing AI servers + power equipment + network equipment demand. NuttyCLD's 3-lens market-reward filter (is the component a real bottleneck / can the economics be seen inside a listed company / has management given investors numbers to model). The "basket can average outcomes but cannot explain why they are so far apart" warning. Per-family deep-dive + per-bottleneck timing analysis behind NuttyCLD substack paywall (user not subscribed).
source: https://x.com/NuttyCLD/status/2054202808954732726
type: research
authors: ["Nutty (@nuttycld)"]
---

# @NuttyCLD 2026-05-12 — MLCC + Passive Components Powering AI Data Centers — "Same Wind, Four Sails" framework — NVL72 440K MLCCs, SEMCO 10-15× AI vs general, Murata FY26 DC ¥325B +84%, SEMCO Q1 +17% rev / +40% op profit; per-family deep-dive paywalled

NuttyCLD publishes the "Same Wind, Four Sails" framework — **4 passive-component families inside the AI server power path** (MLCCs / hybrid polymer capacitors / power inductors / 800V magnetics) all blow with the same AI-demand wind, but **the market does not reward them equally**. The reason: timing differs by family, bottleneck status differs by family, and crucially **disclosure structure differs by listed company**. The X Article preview covers the framework + the April 30 2026 visible-answer moment ([[Murata Manufacturing (6981.T)]] + [[Samsung Electro-Mechanics (009150.KS)]] disclosures) + the 3-lens market-reward filter. The per-family deep-dive (which family is in shortage today vs which is waiting for future architecture) lives in the paywalled Substack body.

## Key Takeaways

- **The MLCC physics that triggered the trade** (preserved verbatim from the preview): an MLCC is smaller than a fingernail. The issue is NOT "more capacitors" — **the real issue is lower impedance**. When a GPU demands a sudden current burst, voltage cannot swing too far. So designers place **thousands of ultra-small caps around the GPU** — they need to respond almost instantly to current-step transients. This is the same physics that underwrites the larger AI power-path thesis.
- **The MLCC density numbers** (the load-bearing data):
  - **NVIDIA NVL72 cabinet ≈ 440,000 MLCCs**
  - **Next-gen GB300 estimated tens of thousands of MLCCs per server**
  - **SEMCO has stated AI servers require 10-15× more MLCCs than general-purpose servers** (the AI per-unit-content multiplier)
- **The April 30 2026 visible-answer moment** — both leading MLCC makers reported same day, giving the market its first clear AI-content disclosure:
  - **Murata (6981.T)** — FY2025 results + FY2026 guidance; made "**Datacenter-related**" revenue breakdown visible for the first time; **FY2026 projection ¥325 billion, +84% YoY**. Cross-link to [[Murata Manufacturing (6981.T)]].
  - **Samsung Electro-Mechanics (009150.KS, SEMCO)** — Q1 2026 **revenue +17% YoY / operating profit +40% YoY**; demand attributed to AI servers + power equipment + network equipment. Cross-link to [[Samsung Electro-Mechanics (009150.KS)]] — NOT to be confused with [[Samsung Electronics (005930.KS)]] (HBM/DRAM/foundry, in Memory sector — entirely separate listed entity).
- **The 4 families = the 4 sails** (preserved verbatim — these are the structural categories the paywalled body drills into):
  1. **MLCCs** (multilayer ceramic capacitors — Murata + SEMCO direct beneficiaries)
  2. **Hybrid polymer capacitors**
  3. **Power inductors**
  4. **800V magnetics**
  - "All four are exposed to the same wind: AI server demand. But the way that wind turns into revenue, earnings, valuation, and stock-market credit is very different. **Even when components sit inside the same AI server, the market does not reward them equally.**"
- **The 3-lens market-reward filter** (the NuttyCLD framework punchline — applies beyond AI passives):
  1. **Is the component actually a bottleneck?**
  2. **Can the economics be seen inside a listed company?**
  3. **Has the company given investors numbers they can model?**
  - "That lens applies not only to AI passive components. It applies to almost every company wearing the label 'AI beneficiary.' The same AI demand can flow through different public-company structures in very different ways." This is the framework's transferable lens — same logic can be applied to InP lasers, optical interconnects, HBM, etc.
- **The "basket can average / cannot explain" warning** — load-bearing for portfolio construction:
  - "A basket can average those outcomes. **It cannot explain why they are so far apart.**"
  - "**The timing is not the same across these families.** One family may be in shortage today, while another is still waiting for a future architecture. If one part of the basket is re-rating while another is fading, the signal becomes blurred."
  - Frame: "**The same AI server demand does not create one passive-component trade.** Disclosure, bottleneck status, and investor access decide how much of the wind reaches each stock."
- **The "Strange Spread" framing** — references a figure in the paywalled body showing how widely passive-component market expression spreads despite same end-demand source. The figure is described inline ("not meant to say every bar belongs to the same kind of company — that is precisely the point") but the figure itself is paywalled (and likely lives only in the Substack body).

## Body completeness — IMPORTANT

**The X Article free preview ends at "we need to look at the four families separately"** with a `Full paid article:` link to https://open.substack.com/pub/nuttycld/p/the-same-wind-four-different-sails. The preview captures the framework intro + Murata/SEMCO Apr 30 visible-answer + the 3-lens market-reward filter + the "basket cannot explain" warning. The per-family deep-dive (which family is in shortage today vs waiting for future architecture, who the specific listed-company beneficiaries are for each of the 4 families, and the named "strange spread" figure) lives in the paywalled Substack tail.

**Substack fetch attempted via cookie auth — FAILED** (`fetch-substack.sh` returned HTTP 200 with `<div class="paywall">` element present + "this post is for paid subscribers" marker; only 4127 chars preview retrieved; no preview file written). **User's substack cookies authenticate Crux/StockPursuit/BoringInvest but NOT NuttyCLD** — same paywall behavior as the May 26 NuttyCLD 800V capture attempt. Surface this as a future-capture gap: if user subscribes to NuttyCLD publication, the per-family deep-dive can be re-fetched.

**Sections NOT captured (paywalled Substack body)**:
- Per-family deep dive — **MLCC** (where Murata and SEMCO sit relative to which AI sockets they win)
- Per-family deep dive — **Hybrid polymer capacitors** (the AVX/Kemet/Panasonic/Nichicon tier — none of these are scaffolded in vault yet)
- Per-family deep dive — **Power inductors**
- Per-family deep dive — **800V magnetics** (the transformer/inductor side of the 800VDC architecture transition)
- **The strange-spread figure** (a chart visualizing the spread of market outcomes across families)
- The per-family bottleneck/disclosure/investor-access mapping that the 3-lens filter operationalizes

## Original Content

> **Nutty** (@NuttyCLD) — 2026-05-12, 14:11 UTC
>
> **Article: MLCC and the Passive Components Powering AI Data Centers**
>
> MLCCs, polymer capacitors, power inductors, and 800V magnetics each tell a different market story.

---

### Same Wind, Four Sails

> *This is structural analysis, not investment advice. The companies discussed can be volatile, and the author may hold positions in some of the securities discussed. Readers should make their own investment decisions.*

---

> An MLCC, or multilayer ceramic capacitor, is smaller than a fingernail.
>
> In my previous piece, I explained why this tiny component has become part of the AI power bottleneck. The issue was not simply that AI GPUs need "more capacitors." The real issue was lower impedance. When a GPU demands a sudden burst of current, the voltage cannot be allowed to swing too far. The system needs components sitting very close to the GPU that can respond almost instantly.
>
> That is why designers place thousands of ultra-small capacitors around the GPU. A single NVIDIA NVL72 cabinet contains roughly 440,000 MLCCs. Next-generation GB300 systems are estimated to use tens of thousands of MLCCs per server. Samsung Electro-Mechanics (009150.KS, hereafter SEMCO) has said that AI servers require 10 - 15x more MLCCs than general-purpose servers.
>
> The most natural question after that article was simple:
>
> > "Samsung Electro-Mechanics?"
> > "Murata?"
> > In other words: who actually makes these parts?

### The visible answer

> On April 30, 2026, part of the answer reached the market.
>
> Murata (6981.T) reported FY2025 results and FY2026 guidance, and made its "Datacenter-related" revenue breakdown clearly visible. The FY2026 projection was ¥325 billion, up 84% year over year. On the same day, Samsung Electro-Mechanics reported Q1 revenue growth of 17% and operating profit growth of 40%, while pointing directly to demand from AI-related servers, power equipment, and network equipment.
>
> At first glance, this sounds like a simple story.
>
> AI servers need more parts.
>
> The companies that make those parts get more attention from the market.
>
> But the actual story is not that simple.
>
> The same AI server does not create one passive-component trade. Across the public names and proxies tied to this map, market outcomes can spread far more widely than the common "AI components" label suggests.
>
> A basket can average those outcomes. It cannot explain why they are so far apart.
>
> **The same AI server demand does not create one passive-component trade. Disclosure, bottleneck status, and investor access decide how much of the wind reaches each stock.**

### The strange spread

> [The figure is not meant to say that every bar belongs to the same kind of company. That is precisely the point. — figure referenced inline; the chart itself is paywalled in the Substack body and not accessible.]
>
> MLCCs, hybrid polymer capacitors, power inductors, and 800V magnetics all sit somewhere inside the AI server power path, but their market expression is not the same.
>
> At a high level, the passive-component map can be divided into four families. All four are exposed to the same wind: AI server demand. But the way that wind turns into revenue, earnings, valuation, and stock-market credit is very different. Even when components sit inside the same AI server, the market does not reward them equally.
>
> Why?
>
> The answer is not just technical importance. The market cares about three things:
>
> 1. **Is the component actually a bottleneck?**
> 2. **Can the economics be seen inside a listed company?**
> 3. **Has the company given investors numbers they can model?**
>
> That lens applies not only to AI passive components. It applies to almost every company wearing the label "AI beneficiary." The same AI demand can flow through different public-company structures in very different ways.
>
> It also explains why buying an "AI components basket" can be dangerous. The timing is not the same across these families. One family may be in shortage today, while another is still waiting for a future architecture. If one part of the basket is re-rating while another is fading, the signal becomes blurred.
>
> To understand why, we need to look at the four families separately.

---

### [PAYWALLED SUBSTACK SECTIONS — NOT CAPTURED]

The X Article body terminates with:

> Full paid article:
> https://open.substack.com/pub/nuttycld/p/the-same-wind-four-different-sails?r=1kajgm&utm_campaign=post&utm_medium=web&showWelcomeOnShare=true

The paywalled body contains: the per-family deep-dive across the 4 sails (MLCC + polymer caps + power inductors + 800V magnetics), the per-family bottleneck-status / disclosure-quality / investor-access mapping that the 3-lens filter operationalizes, and the "strange spread" figure visualizing how widely market expression spreads despite same end-demand source. User's substack cookies hit the paywall (same as the prior May 26 NuttyCLD 800V capture).

No author self-replies or substantive reader replies present in the X Article thread at fetch time.

---

## Related captures (wiki anchors)

### Subject hubs (both newly scaffolded under Industrials)

- **[[Murata Manufacturing (6981.T)]]** (Tokyo Stock Exchange) — #1 global MLCC supplier; FY26 datacenter revenue ¥325B +84% YoY (Apr 30 disclosure)
- **[[Samsung Electro-Mechanics (009150.KS)]]** ("SEMCO", Korea Exchange) — #2 global MLCC alongside FC-BGA substrates + camera modules; Q1 2026 +17% rev / +40% op profit; SEMCO is the source of the 10-15× AI multiplier
- **Disambiguation**: [[Samsung Electronics (005930.KS)]] (Memory sector — HBM/DRAM/foundry) is a separate listed entity from SEMCO; do NOT conflate. Both are Samsung-group affiliates but they're distinct tickers with distinct theses.

### Power Electronics/Research/ siblings (the same-author + same-architecture cluster)

- [[@NuttyCLD May 2026 - Reading NVIDIA 800V 14-company list - 4-stage map SiC-SiCjFET-GaN-GaNSi, 1MW rack 25x growth Hopper 40kW to Rubin Ultra Kyber 1000kW 800VDC native, Schneider 400kW threshold breaks 54V, 9-co scope paywall]] — **the explicit sibling NuttyCLD power-stack research** covering the SiC/GaN side of the same 800VDC architecture transition (1MW rack = 25× growth from Hopper 40kW to Rubin Ultra Kyber 1000kW). The 800V magnetics family in this MLCC piece is the magnetics-side of the same 800VDC architecture shift NuttyCLD's prior note maps on the active-semiconductor side. Read together as a NuttyCLD pair.
- [[@insane_analyst 650V class SiC and GaN power device landscape - 15-vendor comparative table at 80C Vds 400V covering Rds-on Coss Eoss Qoss and pkg integrated-driver tradeoffs]] — adjacent active-side power device landscape

### Power Electronics architecture context

- [[@bryzonx POWI 1700V InnoMux-2 thesis for VR200 800V data center - rack scaling 120kW to 600kW makes voltage survival bottleneck, NVTS 650V destroyed, NVIDIA co-design, rack power capex 36K to 398K]] — the BryzonX POWI thesis articulating the same 800V data center architecture transition the 4-sails framework targets

### Power-semi peers (the SiC/GaN active side of the 800V architecture — same demand wind, different sail)

- [[Power Integrations (POWI)]] (controllers + the BryzonX 1700V InnoMux-2 thesis target)
- [[Navitas Semiconductor (NVTS)]] (GaN)
- [[Wolfspeed (WOLF)]] (SiC backbone)
- [[Infineon Technologies (IFX.DE)]] (SiC + IGBT)
- These are the active-power-semi counterparts to the passive-component families NuttyCLD is mapping in this 4-sails piece.

### Connector/passive peers in Industrials (same sector folder as the new Murata + SEMCO hubs)

- [[Amphenol (APH)]] (connectors — the cable side of the AI power + signal path)
- [[TE Connectivity (TEL)]] (connectors)
- Both are AI-server-content beneficiaries on a different layer; same "rising BOM content per device" mechanism as Murata/SEMCO but applied to interconnect rather than passives.

### NVIDIA / Rubin-rack architecture (the demand counterparty)

- [[Nvidia (NVDA)]] — NVL72 (~440K MLCCs) + GB300 (tens of thousands MLCCs/server) + Rubin Ultra Kyber are the named NVDA platforms driving the per-unit-content multiplier

### Cloud-AI structural-thesis cross-link

- [[@PhotonCap 2026-05-28 Third Signal MRVL Q1 FY27 confirms LITE COHR AI optical signal - NVDA $6B supply chain blueprint via 3 $2B commitments, interconnect FY27 +50pct to +70pct, FY28 $15B to $16.5B raise, scale-out scale-up scale-across]] — the optical interconnect side of the same AI cloud server BOM that's driving the MLCC + magnetics demand. Same NVDA-platform alignment thesis viewed through different supplier lenses.

### Author-voice anchor (the matching framework)

The 3-lens market-reward filter (bottleneck status / listed-company economic visibility / investor-modelable numbers) is a **transferable framework** that explains why "AI beneficiary"-labeled baskets behave so differently. Worth applying as a lens to any future structural-supply-chain research the same author publishes. Same "framework + paywall-blocks-the-named-watchlist" pattern as the prior [[@NuttyCLD May 2026 - Reading NVIDIA 800V 14-company list - 4-stage map SiC-SiCjFET-GaN-GaNSi, 1MW rack 25x growth Hopper 40kW to Rubin Ultra Kyber 1000kW 800VDC native, Schneider 400kW threshold breaks 54V, 9-co scope paywall]] capture.

### Plain-text mentions (not in vault as ticker folders)

- NVL72, GB300, Rubin Ultra Kyber (NVIDIA platform names — driving the per-unit-content multiplier)
- AI-related servers / power equipment / network equipment (SEMCO's stated demand breakdown — Q1 2026)
- "Datacenter-related" — Murata's new FY26 disclosure category (the visibility moment)
- Polymer capacitor / power inductor / 800V magnetics tiers — would map to AVX (now Kyocera), Kemet (now Yageo), Panasonic, Nichicon, TDK, etc. once specific names emerge in the paywalled section
- The "strange spread figure" — paywalled chart visualizing market-outcome dispersion across the 4 families

### Future-capture gaps flagged

- The paywalled Substack body — the 4-family deep-dive + strange-spread figure + per-family ticker mapping. If user subscribes to NuttyCLD publication on Substack, re-fetch this URL.
- The "previous piece" NuttyCLD references at the top ("I explained why this tiny component has become part of the AI power bottleneck") — likely a prior MLCC physics teaching post not currently in vault.
