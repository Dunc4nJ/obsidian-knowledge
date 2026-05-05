---
created: 2026-05-05
published: 2026-04-29
description: Finn Stockinger institutional briefing on PENG's Q2 FY26 print and MemoryAI CXL KV Cache server (GTC March 16, 2026 unveil, Tier-One financial institution customer signed Q2 FY26, 22 TB Altus 4U), framing the electrical-CXL near-term revenue leg that complements the photonic PMA optionality covered in the prior Pennycheck thesis.
source: https://x.com/finnstockinger/status/2049445259088740656
type: thesis
authors: ["Finn Stockinger (@FinnStockinger)"]
---

# PENG MemoryAI CXL KV Cache server ships with Tier-1 bank win, FY26 guide raised to 1.5-1.6B — Stockinger institutional brief

[Finn Stockinger](https://x.com/FinnStockinger) institutional-style briefing on [[Penguin Solutions (PENG)]] following the Q2 FY26 print (April 1, 2026). The thread documents the electrical-CXL leg of PENG's AI infrastructure pivot — the **MemoryAI™ KV Cache Server** unveiled at GTC March 16, 2026 and already deployed at a Tier-One financial institution. This is a different product from the photonic [[Penguin Solutions (PENG) is the named chassis builder for the Marvell-Celestial AI photonic memory appliance shipping late 2026 - Pennycheck thesis|Photonic Memory Appliance (PMA)]] and a different timeline (shipping today vs late 2026 / early 2027), and turning both into a single picture is the point of the Synthesis section below.

## Key Takeaways

- **PENG has two CXL products on two timelines, and the market is conflating them.** MemoryAI™ is the **electrical** CXL 3.0 KV Cache server — Altus-based 4U chassis, up to 22 TB DDR5 per server via CXL expander cards, shipping today, GTC unveil March 16, 2026. PMA is the **photonic** CXL successor — 2RU chassis with 16 [[Marvell Technology (MRVL)]]-acquired Celestial AI Photonic Fabric Modules, 33 TB unified pool, 115 Tbps all-to-all switching, sampling for late 2026 / early 2027. The Pennycheck thesis covered PMA exclusively; this thread captures the near-term electrical leg that's actually on the income statement now.
- **The Q2 FY26 print is a margin-mix story, not a top-line story.** Net sales $343M (-6% YoY) reflects the planned phase-out of the lower-margin Penguin Edge segment plus divestiture of legacy South American operations. Underneath, **Integrated Memory grew +63% YoY to $172M and is now 50% of revenue**, non-GAAP gross margin expanded 40bps to 31.2%, and non-GAAP EPS of $0.52 beat consensus $0.37 by 40.5%. Management raised FY26 net-sales guidance to $1.5-1.6B. This is the operating leverage signature of a platform business emerging from a hardware integrator chrysalis.
- **The "11 TB vs 22 TB" discrepancy across the two tweets is a real signal worth verifying.** Stockinger's March 22 quoted parent says PENG unveiled an "11 TB CXL-based KV Cache server" at GTC; his April 29 thread says "up to 22 TB of CXL-based memory per server." Both can be true (11 TB likely the GTC reference config, 22 TB the Altus 4U spec ceiling), but neither number should be trusted until cross-checked against PENG's own datasheet. A doubling of capacity in five weeks would be a notable disclosure and is more likely a reframing than a roadmap acceleration.
- **The Tier-One financial institution win is the proof-point that converts MemoryAI from product launch into platform.** Use-case described as "real-time AI parsing of massive datasets" — almost certainly a transformer-based fraud/AML/trading-signals system that needs to keep huge KV caches hot across many concurrent inference requests. Banks are notoriously latency-sensitive and risk-averse; a Tier-One reference customer in the first quarter of GA materially de-risks the pipeline.
- **The investment math: forward P/E ~16.9x with 60%+ Integrated Memory growth and a $27.29 PT consensus is undemanding for a small-cap that prints H2 FY26 operating margins above 10%.** The catalyst path is mechanical: every quarter MemoryAI revenue lands and the PMA photonic optionality (via the [[Marvell Technology (MRVL)]] earnout) compounds without the market modeling either fully. This is what Pennycheck called a "free call option" — but the call option has now started paying time-value via Layer 1 revenue.

## Synthesis

### The two-product story (and why both notes are needed in the folder)

The existing Pennycheck capture in this folder focuses on **PMA** — the photonic, 2RU, late-2026/early-2027 product that rides the Marvell-Celestial deal economics. This Stockinger thread covers **MemoryAI™** — the electrical, 4U, shipping-today CXL KV Cache server. Both are real, both are PENG, and they form a coherent product family but operate on completely different timelines and competitive dynamics. The two-note structure mirrors that:

| | MemoryAI™ (this note) | PMA (Pennycheck note) |
|---|---|---|
| Status | Shipping; GTC March 16, 2026 unveil | Sampling; ships late 2026 / early 2027 |
| Form factor | 4U Altus server | 2RU rack chassis |
| Capacity | Up to 22 TB / server (11 TB at GTC unveil) | 33 TB unified, 16 XPUs |
| Interconnect | Electrical CXL 3.0 over PCIe Gen5 | Silicon photonics (Celestial PFM) |
| Switching scope | Per-server (single-host pool) | 115 Tbps all-to-all across rack |
| Energy class | Standard CXL (~5-10 pJ/bit) | ~6.2 pJ/bit photonic |
| Revenue today | Tier-One financial institution signed Q2 FY26 | $0; preserved earnout optionality |
| Margin profile | Software + systems integration | Higher; appliance with Celestial silicon |

Said differently: **MemoryAI gives you memory pooling within a server; PMA gives you memory pooling across a rack.** Same software stack (ICE ClusterWare, formerly Scyld), same SMART Modular memory expertise, sequential commercial maturity. Shaikh's Q2 call language — "CXL in itself is an advantage. We can take it to the next level with the photonic appliance" — explicitly stacks them.

### Why CXL matters at all (the memory wall, plain)

LLM inference is **memory-bandwidth-bound**, not compute-bound. The arithmetic intensity of decoding a token (matmul against KV cache) is so low that GPUs sit idle 60-80% of the time waiting for HBM reads. Two compounding effects:

- **KV cache explosion.** Every token in context allocates roughly `2 × num_layers × hidden_dim × bytes_per_param` of cache. A 70B model at 128K context burns ~40 GB just for one request's KV. Multi-tenant inference servers run out of HBM long before they run out of FLOPs.
- **HBM is "trapped" memory.** Each GPU has its own HBM and there's no clean way to share it across GPUs except over NVLink (expensive, short-reach, pre-allocated). When one GPU has spare HBM and another is OOM, there's no rebalancing path.

CXL 3.0 fixes the second problem: a CPU/GPU sees a CXL-attached pool as **directly load/store-addressable** at ~150-300 ns extra latency vs local DDR. For sequential, prefetchable KV cache reads this is acceptable; for OLTP it's not. CXL 3.0 also adds multi-host support so the same pool can be partitioned across many compute hosts.

### MemoryAI™ architecture (best inference from public disclosures)

- **Altus** is PENG's AMD EPYC-based hyperscale server brand, originally from the Penguin Computing acquisition.
- The **4U chassis** vs PMA's 2RU is because DDR5 DIMMs at 128 GB each take physical slots — to hit 22 TB you need ~170 DIMMs of density, only practical via **CXL expander cards** (Astera Labs Leo, Microchip SMC, or SMART Modular's own controller class — ASIC + 8-16 DDR5 DIMMs presenting one large flat memory range to the host).
- Compatible with the **NVIDIA Dynamo framework** per PENG's OriginAI press release — this matters because Dynamo is NVIDIA's reference inference orchestrator and explicit Dynamo compatibility means MemoryAI can drop into existing NVIDIA GPU deployments rather than requiring a software rewrite.
- The **"10× faster than NVMe"** marketing line is conservative. CXL load/store latency (~250 ns) vs NVMe block reads (~10 µs) is closer to **40× for the KV-cache-spillover use case** specifically. Stockinger probably under-quoted from PENG's deck.
- **ICE ClusterWare** (formerly Scyld) is the software layer that turns the validated hardware into a fully-tuned AI cluster — health monitoring, auto-remediation, multi-tenant workload isolation. This is the moat-narrative: a CXL appliance is a commodity without the orchestration software on top.

### "Hidden gem" verdict — reframe rather than confirm

The user asked whether this is a hidden gem. The honest answer is: it's small-cap with three real legs that aren't yet fully modeled, not truly unknown. With $27 PT consensus and Moderate Buy, this has been written up; the asymmetry is structural-mispricing-of-a-pivot, not lack of awareness.

**Layer 1 — MemoryAI revenue ramp (strong).** Production hardware, customer wins, raised guide, 40% EPS beat. Integrated Memory +63% YoY at 50% of revenue. 31.2% non-GAAP gross margin and rising. Forward P/E ~17x for 60%+ memory growth is genuinely undemanding.

**Layer 2 — PMA / Marvell-Celestial earnout call option (real but contingent).** The $2.25B contingent earnout is pro-rated to PENG's stake, which Pennycheck did not disclose as a percentage. PENG received ~$32M cash from a $5.25B total deal, which back-of-envelope implies low-single-digit % stake — i.e., the realizable value is probably $50-150M, not the full $2.25B. Real, but materially smaller than the headline figure suggests. Ramp depends entirely on Marvell's $500M Q4 FY28 → $1B Q4 FY29 trajectory.

**Layer 3 — SKT/SK Hynix sovereign-AI stack (recurring, durable).** $33.1M six-month related-party revenue from SKT affiliate already in the 10-Q, Haein cluster delivered as a replicable template, SK Hynix HBM relationship as supply hedge for PMA. This is the boring leg nobody talks about and it's already on the tape.

### Real risks worth modeling (not the cookie-cutter ones)

- **Customer concentration.** Stockinger flags Meta's 16,000 GPU cluster. If that's >20% of the Advanced Computing segment, a renegotiation or capex pause is binary for that segment.
- **CXL 3.0 controller ecosystem timing.** MemoryAI's capacity ceiling is set by what Astera Labs / Microchip / SMART Modular ship in expander silicon. Any slip in the controller roadmap caps PENG's appliance roadmap.
- **Marvell vertical-integration risk on PMA.** Marvell could decide to vertically integrate the chassis and squeeze Penguin out as a contract integrator. The earnout creates aligned incentive but no exclusivity has been disclosed. The PMA-specific margin economics are unstated and this is the single biggest known unknown for the photonic leg.
- **Advanced Computing lumpiness.** -42% YoY headline is partly intentional (legacy hyperscale wind-down) but the segment is project-based and quarter-to-quarter visibility is poor. Watch H1 FY26 ex-legacy +50% reframe — if that decelerates in H2, the "Sovereign AI demand" narrative weakens.

### Catalysts to watch

- **H2 FY26 MemoryAI revenue prints.** First and only thing that closes the mispricing if the story is real.
- **Operating margins clearing 10% in H2 FY26** — Stockinger's specific call. This validates the platform-business re-rating thesis quantitatively.
- **PMA first-customer disclosure** in late 2026 / early 2027 — converts Layer 2 from option to revenue.
- **Any Marvell exclusivity disclosure** on the chassis-integrator role — would close the single biggest known unknown on PMA economics.

## External Resources

- [Stockinger main thread — PENG Q2 FY26 institutional briefing](https://x.com/finnstockinger/status/2049445259088740656) (Apr 29, 2026) — primary source for this note.
- [Stockinger quoted parent — "5 Under-the-Radar Rockets / Memory Wall"](https://x.com/FinnStockinger/status/2035700315027095958) (Mar 22, 2026) — broader memory-wall thesis listing $CRSR, $PENG, $NLST, $RMBS, $SANM; contains the 11 TB GTC figure.
- [PENG Q2 FY26 8-K and earnings release (Apr 1, 2026)](https://investor.penguinsolutions.com) — official "Raises Full Year Net Sales and EPS Outlook" press release with Shaikh quote on Tier-One financial institution win.
- [PENG Q2 FY26 transcript (April 2, 2026)](https://www.fool.com/earnings/call-transcripts/2026/04/02/penguin-solutions-peng-earnings-transcript) — Kash Shaikh's CXL + photonic stack-up commentary.
- [[Penguin Solutions (PENG) is the named chassis builder for the Marvell-Celestial AI photonic memory appliance shipping late 2026 - Pennycheck thesis]] — companion note covering the photonic PMA leg.

## Original Content

The thread leads with three official PENG investor / press images:

*Stockinger lead image — PENG FY 2026 Outlook investor slide (GAAP vs Non-GAAP, 12% YoY net sales growth ±5%, 28% non-GAAP gross margin, $2.15 non-GAAP diluted EPS, 53M diluted shares)*
![[finnstockinger-740656-001.jpg]]

*PENG Q2 FY26 press release excerpt — Shaikh quote on Tier-One financial institution deploying MemoryAI™ CXL-based KV cache server, raised full-year guidance*
![[finnstockinger-740656-002.png]]

*PENG OriginAI press release excerpt — MemoryAI KV Cache Server matched with NVIDIA GPUs (RTX PRO 6000 + B300), NVIDIA Dynamo framework compatibility, ICE ClusterWare management software*
![[finnstockinger-740656-003.png]]

> [@FinnStockinger (Finn Stockinger)](https://x.com/finnstockinger/status/2049445259088740656) — April 29, 2026 — 22 likes, 5 RTs, 3 replies
>
> $PENG Penguin Solutions: Institutional Briefing 2026
>
> Strategic Focus: The Transition to High-Margin AI Infrastructure
>
> As of late April 2026, Penguin Solutions has confirmed its status as a pure-play AI infrastructure provider.
>
> The Q2 fiscal 2026 results (reported April 1, 2026) demonstrate a significant shift in revenue quality and technical differentiation.
>
> **1️⃣ Verified Financial Performance (Q2 2026)**
>
> Data sourced from the official SEC Form 8-K filing (April 1, 2026):
>
> ➡️ Net Sales: $343 Million (Down 6% YoY).
>
> Analysis: This decrease is strategic, resulting from the planned phase-out of the lower-margin Penguin Edge segment and the divestiture of legacy South American operations.
>
> ➡️ Non-GAAP EPS: $0.52. The company beat analyst consensus ($0.37) by 40.5%.
>
> ➡️ Non-GAAP Gross Margin: 31.2% (Up 40 basis points YoY). This confirms the shift toward higher-value services and software-integrated systems.
>
> ➡️ Updated FY2026 Guidance: Management raised the full-year outlook, now projecting net sales between $1.5 billion and $1.6 billion.
>
> **2️⃣ Technical Deep-Dive: MemoryAI™ CXL Architecture**
>
> The core of the "Hyper-growth" thesis lies in PENG's dominance of the Compute Express Link (CXL) standard.
>
> AI inference is currently "memory-bound," and PENG's new hardware is designed to break this bottleneck.
>
> The CXL "Memory Wall" Solution
>
> On March 16, 2026, PENG introduced the industry's first production-ready MemoryAI™ KV Cache Server.
>
> ➡️ Massive Scaling:
>
> An Altus-based 4U server capable of hosting up to 22 TB of CXL-based memory per server.
>
> ➡️ Performance Benchmark:
>
> Delivers data access speeds 10x faster than traditional NVMe-based storage.
>
> ➡️ Memory Pooling:
>
> Unlike standard GPU memory (HBM) which is "trapped" within a card, PENG's CXL fabric allows for disaggregated memory pooling.
>
> This enables klastry to dynamically share memory resources across multiple GPU nodes, preventing expensive GPU idle time.
>
> ➡️ Market Adoption:
>
> In Q2 2026, PENG secured a Tier-One Financial Institution as a customer specifically for this CXL-based KV cache technology to handle real-time AI parsing of massive datasets.
>
> **3️⃣ Segment Analysis (Where the Revenue Flows)**
>
> ➡️ Integrated Memory (50% of Revenue):
>
> Reported $172 Million (up 63% YoY).
>
> This is the company's financial engine, benefiting from the global transition to DDR5 and high-bandwidth CXL modules.
>
> ➡️ Advanced Computing (34% of Revenue): Reported $116 Million (down 42% YoY).
>
> Note: This segment is project-based and "lumpy."
>
> However, for the first half of 2026, this segment grew 50% when excluding legacy hyperscale hardware, indicating strong demand from the "Sovereign AI" and Enterprise sectors.
>
> ➡️ Optimized LED (16% of Revenue): Reported $56 Million (down 7% YoY). This remains a stable "cash cow" used to fund R&D in AI infrastructure.
>
> **4️⃣ Risk Assessment & Investment Verdict**
>
> Critical Risks:
>
> ➡️ Customer Concentration:
>
> Major contracts (e.g., Meta's 16,000 GPU klastry) represent a significant revenue weight.
>
> Any shift in capital expenditure from these "Big Tech" players poses a risk.
>
> ➡️ Supply Chain:
>
> As an integrator, PENG is dependent on third-party GPU availability (e.g., Nvidia Blackwell/B300).
>
> Delays in chip deliveries directly delay PENG's project recognition.
>
> ⬇️ Summary:
>
> Penguin Solutions is no longer a commodity memory player.
>
> It is one of the few companies with a validated CXL Memory Appliance in a market where memory bandwidth is the primary constraint for AI agents.
>
> ➡️ Investment Thesis:
>
> With a Forward P/E of approximately 16.9x (as of late April 2026) and a Moderate Buy consensus with a price target of $27.29, the stock remains attractive relative to pure AI infrastructure peers.
>
> If operating margins exceed 10% in H2 2026, it will confirm the transition to a high-margin platform business, likely triggering a significant valuation re-rating.

The thread quotes Stockinger's earlier broader memory-wall thesis (March 22, 2026), which carries the original "11 TB" GTC figure for PENG's MemoryAI unveil:

*Quoted parent cover image — "5 Under-the-Radar Rockets Poised to Ride the AI Memory Wall" (Data Locality / CXL 3.0 stylized graphic)*
![[finnstockinger-740656-004.jpg]]

> [@FinnStockinger (Finn Stockinger)](https://x.com/FinnStockinger/status/2035700315027095958) — March 22, 2026 — 38 likes, 2 RTs, 3 replies (quoted parent)
>
> 5 Under-the-Radar Rockets Poised to Ride the AI "Memory Wall"
>
> The market is obsessed with "Compute," but it's ignoring the fact that the smartest AI on Earth is currently starving to death.
>
> While everyone is chasing the same crowded trades, I've identified 5 "under-the-radar" rockets that are solving the ultimate bottleneck.
>
> Here is why the "Memory Wall" is where the real Alpha is hiding in March 2026.
>
> We need to realize that the current Von Neumann architecture is surrendering to LLMs. If the processor is a Formula 1 engine, memory is currently the tiny straw we're trying to refuel it through while driving at 300 km/h.
>
> Here are 3 deep-dives shaping the market right now:
>
> **1️⃣ Data Locality is the New Currency:**
>
> In AI model training, 90% of energy is wasted just... moving data between chips.
>
> Not on the actual computation.
>
> This is why any company shortening the physical distance between the byte and the transistor (HBM, CXL, Chiplets) basically has a license to print money.
>
> **2️⃣ HBM Cannibalization is Real:**
>
> According to the latest Q1 2026 reports, DRAM and NAND spot prices have surged by 80-90%.
>
> Producing one HBM4 die consumes 3x more wafer capacity than standard DDR5.
>
> The result?
>
> Giants like Samsung and Hynix are "abandoning" the PC and Auto markets.
>
> Whoever has physical inventory on the shelf now dictates the margin.
>
> **3️⃣ CXL 3.0 as a Game Changer:**
>
> Instead of buying ultra-expensive RAM for every individual server, we are entering the era of Memory Pooling.
>
> This allows servers to "borrow" memory dynamically. The companies controlling this protocol are the new Gatekeepers of the data center.
>
> Where to find Alpha when the market is already "heated"?
>
> Here are the 5 tickers I've shortlisted for deep analysis: 👇
>
> **1️⃣ $CRSR (Corsair Gaming) – Inventory Arbitrage**
>
> A classic play on supply-side "short squeeze." Corsair entered 2026 with a massive stockpile of DRAM contracted at 2025 prices. With current spot prices up nearly 90%, their margins on DDR5 modules are pure arbitrage. Their recent $50M buyback and record Q4 margins (up to 35% in components) suggest management sees the windfall coming.
>
> **2️⃣ $PENG (Penguin Solutions) – The CXL Architects**
>
> A pivotal player in breaking the "Memory Wall." At GTC last week (March 2026), they unveiled MemoryAI™ an 11TB CXL-based KV Cache server.
>
> They are solving the bottleneck at the systems level, not just the component level.
>
> Still trading at an attractive forward P/E (~10-12x) despite near 100% EPS growth projections.
>
> **3️⃣ $NLST (Netlist) – The Legal Bottleneck**
>
> DDR5 and HBM cannot scale without LRDIMM technology, which Netlist patented years ago.
>
> On Feb 23, 2026, the CAFC (Appeals Court) upheld their key '314 patent against Micron for the third time.
>
> With a massive trial against Samsung scheduled for April, we are approaching a "Binary Event" that could trigger billion-dollar licensing settlements.
>
> **4️⃣ $RMBS (Rambus) – IP Monopoly**
>
> They don't build fabs; they design the data superhighways.
>
> They just announced the industry-first HBM4E controllers (4.1 TB/s!).
>
> With 80%+ gross margins, Rambus profits from every increase in transfer speed without risking a single dollar on physical manufacturing or inventory.
>
> **5️⃣ $SANM (Sanmina / Viking Tech) – Edge AI Defense**
>
> Owner of the Viking Technology brand.
>
> Their new Viking Edge series is exactly what the industry needs: ultra-dense, custom memory produced locally in the US.
>
> In an era of deglobalization and Asian supply chain fragility, their "Made in USA" specialty memory is a massive strategic moat.
>
> Bottom Line:
>
> The memory wall isn't a one-quarter blip — it's a structural shift that is only beginning to be priced in.
>
> I wanted to ask — what are your thoughts on these? Perhaps some of you are deeper into these names and can save me a few hours of due diligence?

Reply chain on the main thread:

> [@bullfornow1960 (BullForNow1960)](https://x.com/bullfornow1960/status/2049448949384200286) — April 29, 2026
>
> Interesting potential... curious what level of confidence you have in managements ability to execute against the high margin / growth segments?

> [@FinnStockinger (Finn Stockinger)](https://x.com/FinnStockinger/status/2049473909649502609) — April 29, 2026 (reply to @bullfornow1960)
>
> The PENG crew isn't just talking a big game; they're actually delivering.
>
> They've spent the last few months aggressively trimming the fat -> selling off low-margin side businesses to focus entirely on being the 'memory powerhouse' for AI.
>
> By raising their 2026 financial targets in April, the management basically put their money where their mouth is, proving they've got the chips and the customers to back up the hype.

Original tweet: <https://x.com/finnstockinger/status/2049445259088740656>
