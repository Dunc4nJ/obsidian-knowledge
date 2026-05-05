---
created: 2026-05-05
published: 2026-05-03
description: BryzonX PENG photonic-memory thesis built on Q2 FY26 earnings call language (Shaikh confirming PMA / formerly OMA), with a custom infographic showing the three-stage architecture (Current CXL over copper at 11TB/cluster → Marvell Photonic Fabric → Optical Memory Appliance at 1000+TB petabyte scale), 70pct agentic-AI cost-per-query reduction claim, and explicit AWS Trainium/Inferentia targeting beyond the Meta concentration already in the file.
source: https://x.com/bryzonx/status/2050987380493226000
type: thesis
authors: ["BryzonX (@BryzonX)"]
---

# PENG Optical Memory Appliance unlocks 1000TB cluster pool vs 11TB copper KV cache, 70pct cost-per-query reduction — BryzonX thesis

[@BryzonX](https://x.com/BryzonX) thread (May 3, 2026) building a photonic-memory thesis on [[Penguin Solutions (PENG)]] from the Q2 FY26 earnings call. Carries a custom infographic mapping the three-stage memory architecture (current CXL over copper → Marvell Photonic Fabric → Optical Memory Appliance) and a screenshot of the actual Shaikh transcript proving the photonic commentary is on-mic. Companion to the [[Penguin Solutions (PENG) is the named chassis builder for the Marvell-Celestial AI photonic memory appliance shipping late 2026 - Pennycheck thesis|Pennycheck PMA thesis]], the [[PENG MemoryAI CXL KV Cache server ships with Tier-1 bank win, FY26 guide raised to 1.5-1.6B - Stockinger institutional brief|Stockinger MemoryAI brief]], and the [[PENG SK Hynix HBF memory tier plus Celestial photonics at 1x sales 2x memory revenue - ThematicTrader bull thesis|ThematicTrader HBF thesis]].

## Key Takeaways

- **The "1000+TB per cluster" photonic memory figure is the new datum.** Pennycheck disclosed 33 TB unified memory per single PFA chassis (16 PFMs at ~2 TB each); Bryan's infographic claims the OMA scales to 1000+TB per cluster ("petabyte scale"). The math implies ~30+ appliances aggregated — i.e., this is a multi-rack cluster pool, not a single-chassis spec. Worth flagging before quoting: it's a roadmap-scale figure for the architectural ceiling, not what one box does at GA.
- **70pct cost-per-query reduction for agentic AI inference is the previously unstated efficiency claim.** The infographic carries this as the headline metric. None of the prior three PENG notes had a per-query cost figure — if real, this is the number that justifies the "premium pricing" management language and the moat narrative. Anything close to 70pct cost reduction at hyperscaler inference scale is the kind of number that drives pull-through, not push.
- **AWS Trainium / Inferentia is now explicitly named as a target customer.** The Stockinger brief flagged Meta concentration as a top risk; this infographic broadens the named hyperscaler list to AWS specifically (Trainium training + Inferentia inference). Bryan's body text speculates "$META and $AMZN" as the sampling customers. AWS context is material — Trainium2 has known KV-cache memory pressure that PMA-class appliances directly address.
- **Bryan still uses the old "OMA" nomenclature** — the [[Pennycheck PMA thesis]] already documented the rename PMA = formerly OMA. Both refer to the same product. Worth noting because future searches should hit both names; the infographic is a useful Rosetta stone showing the legacy branding.
- **The Lightelligence reply (@Philip_pan2008) is the bear-case fragment worth preserving** — *"Lightelligence already gone ahead, and products adoption, but PENG and celestial are still in developing stage?"* Bryan didn't answer it. Lightelligence is a real silicon-photonics competitor with shipped products (PACE, Hummingbird) — worth its own ticker folder if pursuing the photonic AI memory thesis seriously, since it's the strongest competitive risk to the Celestial-via-Marvell-via-PENG stack.

## External Resources

- [BryzonX main tweet — PENG photonic-memory infographic + thesis](https://x.com/bryzonx/status/2050987380493226000) (May 3, 2026) — primary source.
- [BryzonX reply with PENG Q2 FY26 transcript screenshot](https://x.com/BryzonX/status/2051008986472935827) (May 3, 2026) — proof-image of Shaikh's PMA / OMA / Celestial / Marvell commentary.
- [[Penguin Solutions (PENG) is the named chassis builder for the Marvell-Celestial AI photonic memory appliance shipping late 2026 - Pennycheck thesis]] — primary-source-grounded PMA thesis (33 TB single-chassis spec).
- [[PENG MemoryAI CXL KV Cache server ships with Tier-1 bank win, FY26 guide raised to 1.5-1.6B - Stockinger institutional brief]] — electrical CXL KV cache leg.
- [[PENG SK Hynix HBF memory tier plus Celestial photonics at 1x sales 2x memory revenue - ThematicTrader bull thesis]] — HBF + valuation framing.

## Original Content

*BryzonX custom infographic — three-stage PENG memory architecture: Current CXL over copper (11 TB/cluster) → Marvell Photonic Fabric (24-month engineering lead) → Optical Memory Appliance (1000+ TB petabyte scale, AWS Trainium/Inferentia callout, 70pct cost-per-query reduction headline)*
![[bryzonx-226000-001.jpg]]

> [@BryzonX (bryan)](https://x.com/bryzonx/status/2050987380493226000) — May 3, 2026
>
> Some of you may have missed this nugget from the $PENG recent earnings call 🚨
>
> Penguin is now working on PHOTONIC MEMORY
>
> Their current KV cache currently uses high speed copper, which gets the job done now however copper can't handle the bandwidth needed for "Agentic AI" without melting or slowing down
>
> But as we move towards the agentic ai era, this requires more data, more compute, and more power
>
> The only way to scale memory in data centers is with the speed of light
>
> If you didn't know, PENG was an early investor and engineering partner with celestial who are the pioneers in photonic fabric
>
> Penguin has been working with Celestial since its early startup days, meaning they have a 24 month head start on understanding how to cool, power, and manage photonic signals
>
> One of my fav underrated dynamics of this is Penguin will not need to dilute shareholders to fund this because since Celestial was acquired by $MRVL, Penguin has a war chest of cash from their investment to fund this
>
> So what is Penguins role in all of this?
>
> Penguin is the one building the Optical Memory Appliance (OMA) the actual physical rack that houses this photonic tech
>
> According to their April 2026 roadmap, they are moving toward a commercial launch that will redefine what "memory capacity" means
>
> Their current KV cache offers 11TB of memory per cluster, but with their photonic cache they will immediately unlock up to 1000+TB of memory
>
> Completely solving the memory problem in data centers (!)
>
> $PENG is currently sampling these with "key hyperscalers" ( likely $META and $AMZN ) with final specifications expected by early 2027
>
> If Marvell's Photonic Fabric becomes the industry standard (which the acquisition suggests it will), every AI data center in the world will need a Penguin built appliance to run it
>
> Management noted that their Integrated Memory segment is seeing "favorable pricing dynamics."
>
> This is a polite way of saying they are charging a premium for their early photonic and CXL expertise
>
> Penguin is leading the way to take the memory wall head on
>
> You don't own enough $PENG

Reply chain:

> [@chrisbeeSA (chris bee)](https://x.com/chrisbeeSA/status/2050999833339576340) — May 3, 2026
>
> Still seems nothing concrete was said ?

> [@BryzonX (bryan)](https://x.com/BryzonX/status/2051008986472935827) — May 3, 2026 (reply to @chrisbeeSA)

*PENG Q2 FY26 earnings call transcript excerpt — Shaikh confirming PMA (formerly OMA), Celestial early-investor relationship, Marvell acquisition proceeds, Tier-1 financial institution CXL KV cache win*
![[bryzonx-226000-002.jpg]]

Verbatim transcription of the highlighted transcript text:

> For example, we sold our CXL-powered KV Cache servers to a Tier 1 financial institution for their on-premise AI factory. In parallel, we continue to advance development of our Photonic memory appliance or PMA, formerly referred to as OMA, which is designed to extend memory capacity and bandwidth for large-scale AI environments. We were an early investor in a photonic memory company, Celestial AI, reflecting our long-standing focus in memory architecture innovation and our early conviction in the importance of optical interconnects for next-generation AI systems. Celestial AI was recently acquired by Marvell in a multibillion-dollar deal. Beyond the portion of proceeds we received from the acquisition as an investor, we are positioning ourselves for future growth in this market.

> [@AtlasShrug1 (John Galt)](https://x.com/AtlasShrug1/status/2051050184562352336) — May 3, 2026
>
> This stock is so undervalued it's obscene!

> [@BryzonX (bryan)](https://x.com/BryzonX/status/2051050554198220832) — May 3, 2026 (reply to @AtlasShrug1)
>
> 1x sales is nuts!

> [@jskerner (Jordan Kerner)](https://x.com/jskerner/status/2051115009678114820) — May 4, 2026
>
> More things to like about Peng. In since under $20

> [@Philip_pan2008 (Philipp2008)](https://x.com/Philip_pan2008/status/2051178934314889643) — May 4, 2026
>
> Great analysis! But seems Lightelligence already gone ahead, and products adoption, but PENG and celestial are still in developing stage?

> [@christianoboria (christiano boria)](https://x.com/christianoboria/status/2051195808876253568) — May 4, 2026
>
> DM me, want to chat about this one if you're game

> [@christianoboria (christiano boria)](https://x.com/christianoboria/status/2051196164674867617) — May 4, 2026
>
> what % of revenue or future revenue is tied to AI workloads?

> [@BryzonX (bryan)](https://x.com/BryzonX/status/2051198618036769135) — May 4, 2026 (reply to @christianoboria)
>
> As of the last quarter, 50% of total revenue is now coming from integrated memory
>
> Management is expecting this to grow 65%-76% by the end of the year

> [@LuTebow (Lu Feng)](https://x.com/LuTebow/status/2051420122875883597) — May 4, 2026
>
> How does Peng compare with the MU/other memory plays?

> [@BryzonX (bryan)](https://x.com/BryzonX/status/2051422466778837342) — May 4, 2026 (reply to @LuTebow)
>
> They aren't competing with them, they're enabling them
>
> Peng gets their memory from Hynix

Original tweet: <https://x.com/bryzonx/status/2050987380493226000>
