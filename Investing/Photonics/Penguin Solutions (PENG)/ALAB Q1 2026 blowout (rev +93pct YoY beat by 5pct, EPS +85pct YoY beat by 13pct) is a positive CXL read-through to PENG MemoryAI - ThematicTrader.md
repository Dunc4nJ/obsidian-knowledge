---
created: 2026-05-06
published: 2026-05-05
description: ThematicTrader one-liner calling Astera Labs' Q1 2026 blowout print (revenue $308.36M +93pct YoY beating by 5pct, EPS $0.61 +85pct YoY beating by 13pct) a positive CXL read-through for PENG, which sells the MemoryAI CXL KV-Cache server using CXL controller silicon ALAB designs.
source: https://x.com/ThematicTrader/status/2051757970455671174
type: thesis
authors: ["ThematicTrader / 9 Ventures (@ThematicTrader)"]
---

# ALAB Q1 2026 blowout is a positive CXL read-through for PENG MemoryAI — ThematicTrader

[ThematicTrader](https://x.com/ThematicTrader) one-line read on [[Astera Labs (ALAB)]]'s Q1 2026 print as a positive demand signal for [[Penguin Solutions (PENG)]]'s MemoryAI CXL KV Cache server franchise. ALAB and PENG both sell into the CXL ecosystem at different layers — ALAB designs the CXL controller silicon (Leo Memory Connectivity Controllers) and PENG ships the integrated 4U server appliance built on top of that silicon — so an ALAB demand blowout cleanly precedes a PENG appliance ramp by 1-2 quarters.

## Key Takeaways

- **ALAB Q1 2026 numbers were a clean blowout**: revenue $308.36M (+93pct YoY, +14pct QoQ, beat consensus by 5pct), Non-GAAP EPS $0.61 (+85pct YoY, +5pct QoQ, beat consensus by 13pct). The +14pct sequential is the more important number than the year-over-year — ALAB's customer base is concentrated in the same hyperscalers PENG sells to via OriginAI / MemoryAI, so QoQ acceleration in ALAB ASIC shipments is a real-time signal that hyperscaler CXL DEPLOYMENT (not just qualification) is moving.
- **The supply-chain logic**: ALAB ships the **silicon** (Aries retimers, Leo CXL Memory Connectivity Controllers, Scorpio Smart Fabric Switches); PENG ships the **system** (4U Altus chassis, ICE ClusterWare orchestration software, integrated DDR5 + CXL expander cards). Hyperscalers and Tier-1 enterprises buy ALAB silicon directly when building their own boxes and buy PENG appliances when they want a turnkey solution. Demand for both should move together — ALAB strength implies PENG-class systems are also being ordered.
- **PENG's 4U MemoryAI KV Cache server is built on Leo-class CXL controllers**: the 22 TB DDR5-per-server ceiling is only reachable via CXL expander cards that present 8-16 DDR5 DIMMs as a flat memory range to the host. Astera Labs' Leo product family is the dominant merchant-silicon answer to this need (Microchip SMC and Samsung CMM-D are the alternatives). Every PENG MemoryAI box likely has multiple ALAB controllers in its bill of materials. ALAB's record sequential = those controllers are clearing the channel.
- **The bear-case wrinkle that ThematicTrader doesn't say out loud**: ALAB beat AND raised on a higher P/S base (~40x vs PENG's 1.25x — see the [[PENG synthesized thesis - facts, business drivers, and dependencies across the five legs (IM cyclical, MemoryAI CXL, PMA photonic, Sovereign AI, Marvell-Celestial earnout)|synthesized PENG thesis]] comp table). Read-through to PENG goes both ways: positive on the demand signal, but ALAB's 75pct gross margin vs PENG's 31pct integrator margin is the structural reason PENG won't ever trade at the ALAB multiple. ALAB captures the "value upstream" risk the @FuruB5134 reply on the [[PENG SK Hynix HBF memory tier plus Celestial photonics at 1x sales 2x memory revenue - ThematicTrader bull thesis|earlier ThematicTrader thread]] flagged: the silicon vendor compounds margin, the integrator compounds revenue. Both can win, but the asymmetry profile differs.
- **Mechanical catalyst for PENG**: with 9 weeks until PENG's Q3 FY26 print (anticipated July 7-8, 2026), the ALAB beat de-risks a key forward-looking line in PENG's Memory segment guide. PENG already raised FY26 IM growth to +65-75pct on the April 1 print citing "majority pricing but demand is also very strong"; an ALAB QoQ +14pct in the same window confirms the demand component is real, not just pricing tailwind. The Q3 print is now the next institutional re-rating moment for PENG specifically because ALAB just gave the read-ahead signal.

## Why this is positive for PENG, plainly

PENG sells two distinct CXL products: (a) **CXL expander cards** (commodity-ish, sold to anyone building DDR5 memory pools, mentioned on the Q2 call as "a recent substantial order for CXL cards from a generative-AI company"), and (b) **MemoryAI CXL KV Cache servers** (the differentiated 4U appliance, Tier-1 financial institution win disclosed on April 1, 2026 call). Both products consume CXL controller silicon — and ALAB is the dominant merchant supplier. ALAB beat and raised on +14pct sequential growth driven by Leo CXL controller shipments. That same demand wave reaches PENG with a 1-2 quarter lag because the system-integrator buys silicon, validates a board design, qualifies it with a customer, then recognizes revenue. **Q3 FY26 (Mar-May 2026 quarter, prints July 7-8) is exactly when that lag would land in PENG's Integrated Memory segment numbers.**

## Quick CXL primer for context

**CXL = Compute Express Link.** A coherent, load/store-addressable memory protocol that runs on top of PCIe Gen5/Gen6 physical layer, ratified in three generations:

- **CXL 1.1** — point-to-point CPU-to-device memory expansion. CPU sees attached DRAM as part of its physical memory map at ~150-300 ns extra latency vs local DDR.
- **CXL 2.0** — adds a switch layer so multiple CPUs can share a memory pool. This is what's shipping today; ALAB's Leo controller class is CXL 2.0.
- **CXL 3.0/3.1** — adds fabric (multi-host), peer-to-peer GPU-to-CXL-device traffic, and memory pooling across racks. Sampling now, production volumes 2H 2026.

**The problem CXL solves**: HBM (the high-bandwidth memory soldered onto GPUs) is "trapped" — it cannot be shared between GPUs, and you can only buy more by buying another GPU. CXL lets a server attach a large external DRAM pool that any CPU/GPU on the bus can read/write at near-DRAM latency. For LLM inference specifically, this matters because **KV cache** (the per-request memory that stores the partial computation as the model generates tokens) grows linearly with context length and batch size. A 70B model at 128K context burns ~40 GB of KV cache per request. Multi-tenant inference servers run out of HBM long before they run out of compute. CXL gives them a place to spill the KV cache to without going to NVMe (which is ~40x slower).

**Why ALAB and PENG both win on the same secular wave**:
- ALAB sells the **silicon brain** of the CXL device (the controller ASIC that translates between PCIe protocol and DDR5/DDR4 commands).
- PENG sells the **system** — chassis, multiple CXL expander cards using ALAB-class silicon, NVIDIA GPUs, ICE ClusterWare orchestration software — as a turnkey 4U inference-optimization box.

When Microsoft Azure adds CXL pooling to M-series VMs, that's a hyperscaler buying ALAB-class silicon at scale. When a Tier-1 bank deploys an on-premise inference factory, that's PENG selling a complete MemoryAI box (which itself contains ALAB-class silicon). Both demand vectors are downstream of the same cause: LLM inference becoming memory-bound rather than compute-bound. **The ALAB blowout is direct evidence that the hyperscaler/enterprise demand wave PENG is positioning for is, in fact, here.**

The ONE caveat: ALAB's 40x P/S vs PENG's 1.25x P/S means the market has already priced ALAB's exposure to this wave aggressively while pricing PENG's much more cautiously. The asymmetric trade is in PENG only if PENG's MemoryAI/CXL revenue ramps fast enough to force a re-rating from "integrator multiple" toward "AI infrastructure platform multiple." Q3 FY26 print is the first measurable check on that.

## External Resources

- [Astera Labs (ALAB) — official IR](https://www.investors.asteralabs.com) — for the actual Q1 2026 press release and earnings deck (the screenshot in this note is third-party).
- [@earnings_guy quoted parent — ALAB Q1 2026 earnings card](https://x.com/earnings_guy/status/2051755193327390857) — the QT'd source image (78 likes, 18 RTs).
- [[PENG MemoryAI CXL KV Cache server ships with Tier-1 bank win, FY26 guide raised to 1.5-1.6B - Stockinger institutional brief]] — covers the PENG MemoryAI product that this read-through targets.
- [[PENG Q2 FY26 transcript - Shaikh confirms PMA development partnership with Celestial-now-Marvell, $32M disposition proceeds (mostly Marvell stock), $27.5M GAAP gain (April 1 2026)]] — primary source for PENG management's CXL strategy commentary.
- [[PENG synthesized thesis - facts, business drivers, and dependencies across the five legs (IM cyclical, MemoryAI CXL, PMA photonic, Sovereign AI, Marvell-Celestial earnout)]] — comp table including ALAB at 40.5x P/S vs PENG at 1.22x P/S.
- [[PENG SK Hynix HBF memory tier plus Celestial photonics at 1x sales 2x memory revenue - ThematicTrader bull thesis]] — the companion ThematicTrader thread on PENG's broader memory architecture.

## Original Content

*ALAB Q1 2026 earnings card (from the QT'd @earnings_guy tweet) — EPS $0.61 vs $0.54 expected (beat 13pct), Revenue $308.361M vs $292.32M expected (beat 5pct); EPS up 85pct YoY / 5pct QoQ; Revenue up 93pct YoY / 14pct QoQ*
![[thematictrader-671174-001.jpg]]

> [@ThematicTrader (9 Ventures)](https://x.com/ThematicTrader/status/2051757970455671174) — May 5, 2026 20:16 UTC — 7 likes, 0 RTs, 1 reply
>
> Strong print by $ALAB is good for $PENG as a CXL read through.

The tweet quote-tweets [@earnings_guy (The Earnings Correspondent)](https://x.com/earnings_guy/status/2051755193327390857) — May 5, 2026 20:05 UTC — 78 likes, 18 RTs, 1 reply:

> $ALAB (Astera Labs) #earnings are out:

The reply chain on the ThematicTrader tweet:

> [@TheKey2Life (9 Vnetruas)](https://x.com/TheKey2Life/status/2051758211917848621) — May 5, 2026 20:17 UTC
>
> My Transactions !
>
> $ALAB
>
> $PENG
>
> ⬇️

Original tweet: <https://x.com/ThematicTrader/status/2051757970455671174>
