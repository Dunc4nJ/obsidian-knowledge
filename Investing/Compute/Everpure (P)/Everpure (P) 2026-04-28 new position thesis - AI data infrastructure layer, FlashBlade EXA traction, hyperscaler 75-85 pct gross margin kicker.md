---
created: 2026-05-13
published: 2026-04-28
description: Crux Capital initiates a small position in Everpure (formerly Pure Storage, $P) on the thesis that the AI-era enterprise data infrastructure layer + a high-margin (75-85 pct GM) hyperscaler architecture model offer multi-leg upside on top of a profitable, cash-generative all-flash storage base.
source: https://cruxcapitalgroup.substack.com/p/i-took-a-new-position
type: thesis
authors: ["Crux Capital Group (@cruxcapitalgroup)"]
---

# Everpure (P) 2026-04-28 new position thesis — AI data infrastructure layer, FlashBlade//EXA traction, hyperscaler 75-85% GM kicker

## Key Takeaways

- **Position**: small initiated, target ~5% of portfolio if execution supports thesis. Author wants exposure before story becomes obvious.
- **Re-brand thesis**: Everpure (formerly Pure Storage, ticker $P) re-positioning from enterprise all-flash storage vendor → enterprise AI-era data infrastructure layer (store, move, protect, govern, classify, prepare data).
- **Financials (FY26)**: $3.66B revenue (+16% YoY), $1.92B subscription ARR (+16%), $3.67B RPO (+40% — strongest signal), $635M non-GAAP OI, $616M FCF, $1.55B cash. Q4 was first >$1B quarter (+20% YoY). Non-GAAP OM 21.3%, product revenue +25%, SaaS +28%.
- **FY27 guide**: $4.3–$4.4B revenue (17–20% growth), $780–$820M non-GAAP OI.
- **Franchise deal signal**: deals >$5M grew 80% YoY in Q4. Customer treating Everpure as a strategic platform across many workloads vs single-workload procurement.
- **Hyperscaler kicker = the lever**: management expects "significantly accelerate" in FY27 hyperscaler shipments. Margin structure is key — hyperscalers procure NAND through own supply chains, Everpure provides architecture/software/controllers/integration. Implies **hyperscaler gross margins of 75–85%** vs enterprise product GM of 65–70%. In engineering test with multiple hyperscalers; most FY27 hyperscaler revenue back-half loaded (Q3/Q4).
- **FlashBlade//EXA traction**: first GPU cloud customer tested → ordered within days → reordered. Dozens of advanced-stage discussions. Best near-term AI/HPC storage product signal.
- **Near-term bear case = NAND cost inflation**: ~90-day proposal cycle creates lag — fulfilling orders at old pricing while paying higher NAND. Q1 product GM at lower end of 65–70% range; recovery through year is the test. Hyperscaler model is structural offset since they procure their own NAND.
- **Customer scale**: 14,500+ customers, ~64% Fortune 500 penetration, ~42% Global 2000, NPS 84.
- **1touch acquisition** (announced): adds data discovery, classification, governance, cyber resilience — relevant to AI permissions/context layer.
- **Valuation**: ~$70/share, ~$23B market cap, ~5x FY27 forward sales. Premium vs NetApp/Dell/HPE classic storage comps. Debate = does the market continue to value as classic storage or re-rate to AI-era data infra platform.
- **YE 2027 targets**: Bear $55–60 (3.5–4x sales), Base $90–95 (5.25–5.5x), Bull $120–125 (6.5–7x).

## Why this matters

The investable insight is the **gross-margin asymmetry of the hyperscaler model**: if production hyperscaler revenue ramps in FY27 (currently in engineering test), Everpure collects software/architecture margin (75–85%) while hyperscalers eat the NAND commodity exposure. That structurally re-rates the franchise away from cyclical storage hardware. This is the canonical "high-margin AI data infrastructure platform" thesis vs "NAND-input-cost-exposed storage box vendor" framing.

Author's framing — "test, buy, reorder" with the first GPU cloud customer + "dozens more in advanced-stage discussions" — is the textbook early product-cycle signal worth tracking before the data hardens.

## Product line (per the post)

*Everpure FlashArray, FlashBlade, Evergreen, Fusion, Portworx, and FlashBlade//EXA product family (images below)*

![[cruxcapitalgroup-i-took-a-new-position-001.png]]

*FlashArray — block storage (databases, VMs, mission-critical apps)*
![[cruxcapitalgroup-i-took-a-new-position-002.png]]

*FlashBlade — file/object storage (unstructured AI training data)*
![[cruxcapitalgroup-i-took-a-new-position-003.png]]

*Evergreen — non-disruptive lifecycle/subscription model*
![[cruxcapitalgroup-i-took-a-new-position-004.png]]

*Portworx — Kubernetes/container storage layer*
![[cruxcapitalgroup-i-took-a-new-position-005.png]]

*FlashBlade//EXA — new AI/HPC storage product targeting GPU-cluster feed*
![[cruxcapitalgroup-i-took-a-new-position-006.png]]

*FY26 revenue scorecard ($3.66B revenue, $1.92B ARR, $3.67B RPO, $635M non-GAAP OI, $616M FCF)*
![[cruxcapitalgroup-i-took-a-new-position-007.png]]

*Customer footprint: 14,500+ customers, ~64% Fortune 500, ~42% Global 2000, NPS 84*
![[cruxcapitalgroup-i-took-a-new-position-008.png]]

*FlashBlade//EXA targeting the GPU-cluster data-feed bottleneck*
![[cruxcapitalgroup-i-took-a-new-position-009.png]]

## Related

- [[Everpure (P)]] — subject hub
- NAND input-cost exposure → relevant supply-chain reads: [[Micron (MU)]], [[SanDisk (SNDK)]], [[Western Digital (WDC)]], [[SK Hynix (000660.KS)]], [[Samsung Electronics (005930.KS)]], [[Kioxia (285A.T)]] — Memory-sector NAND cycle drives Everpure product GM.
- Hyperscaler buyer demand → [[Alphabet (GOOGL)]], [[Microsoft (MSFT)]], [[Amazon (AMZN)]], [[Meta Platforms (META)]] capex cycle.
- Cloud/data-infra peer: [[Oracle (ORCL)]].
- Networking adjacency for GPU-cluster build-outs: [[Arista Networks (ANET)]].

## Original Content

[New Ideas](https://cruxcapitalgroup.substack.com/s/one-to-watch/?utm_source=substack&utm_medium=menu)

# I Took A New Position

### A Profitable AI Infrastructure Company

[Gaetano](https://substack.com/@cruxcapitalgroup)

Apr 28, 2026

∙ Paid

17

4

Share

I have been spending a lot of time thinking about the next phase of AI infrastructure.

As AI moves from training into inference, especially inside the enterprise, one challenge becomes more about getting the right data to the right model at the right time. Training is concentrated in large GPU clusters. Inference spreads everywhere, into chatbots, document assistants, coding tools, fraud models, cybersecurity workflows, customer-service agents, and internal analytics. Every one of those workloads needs access to company data.

In this setup, the model is only as useful as the data it can access. A company can have the best AI model in the world, but if its enterprise data is fragmented, slow, duplicated, poorly governed, or locked inside old infrastructure, the AI system may be constrained.

The company I am discussing today sits directly in that layer. It is already profitable, growing, cash-generative, and guiding to high-teens revenue growth. It has a new AI-specific product gaining real early traction, a hyperscaler opportunity with a margin structure that could change how investors value the business, and a broader push from storage infrastructure toward AI-era data management.

I initiated a small position. The valuation already reflects some optimism, and I want more proof on hyperscale conversion, adoption, and gross-margin recovery. But the setup is strong enough that I want exposure before the story becomes obvious.

The timing is interesting because the company is crossing $1 billion in quarterly revenue, guiding to high-teens growth, and trying to re-rate from enterprise storage into AI data infrastructure at the same time hyperscaler storage demand is accelerating.

*Below, I'll break down the company, the AI data-layer thesis, the hyperscaler upside, the risks, the valuation, and how I am thinking about position sizing in my own portfolio.*

---

### The Company: Everpure ($P)

The company is Everpure, formerly Pure Storage, ticker $P.

I think the strategic message behind the re-brand is that management wants investors and customers to view this as more than a storage hardware vendor. The old version of the story was an enterprise storage company selling all-flash systems to replace older disk-based infrastructure. That business still exists and still provides the foundation.

But the new version is broader. Everpure wants to become the enterprise data infrastructure layer for the AI era, helping customers store, move, protect, govern, classify, and prepare data across modern enterprise environments. Storage is where data sits. Data infrastructure is how that data becomes useful. As AI moves deeper into enterprise workflows, the second part becomes more valuable.

---

### What Everpure Builds

Everpure takes NAND flash memory and turns it into enterprise-grade storage systems with proprietary hardware, software, reliability, security, data reduction, upgradeability, and management tools layered on top. The customer is buying the finished system, the software layer, and the operating model.

![[cruxcapitalgroup-i-took-a-new-position-001.png]]

The core products:

**FlashArray** handles block storage, the high-performance format used for databases, virtual machines, and mission-critical applications.

![[cruxcapitalgroup-i-took-a-new-position-002.png]]

**FlashBlade** handles file and object storage, which is increasingly important for AI because a lot of useful enterprise data lives outside clean databases in the form of documents, logs, images, contracts, and unstructured files.

![[cruxcapitalgroup-i-took-a-new-position-003.png]]

**Evergreen** is the lifecycle and subscription model. Traditional enterprise storage involved painful refresh cycles where customers had to rip out old systems and replace them entirely. Evergreen lets customers upgrade over time with less disruption, supporting longer relationships, recurring revenue, and a more software-like business model.

![[cruxcapitalgroup-i-took-a-new-position-004.png]]

**Fusion** is the control plane, the management layer that lets customers control many storage systems through one interface, applying policies, automating workflows, and coordinating resources across environments.

**Portworx** gives Everpure exposure to Kubernetes and container storage, bridging the company into modern cloud-native application infrastructure.

![[cruxcapitalgroup-i-took-a-new-position-005.png]]

**FlashBlade//EXA** is the newest AI and high-performance computing storage product, designed for environments where storage has to feed very fast GPU clusters without becoming the bottleneck.

![[cruxcapitalgroup-i-took-a-new-position-006.png]]

Everpure also recently announced a definitive agreement to acquire 1touch, which would add data discovery, classification, governance, cyber resilience, and context capabilities. Essentially, 1touch helps customers understand what data they have, where it lives, what type it is, who can access it, and how it is governed. That is directly relevant to AI, where models need the right data with the right permissions rather than free access to everything.

---

### The Business

Everpure generated $3.66 billion of revenue in fiscal 2026, up 16% year over year.

![[cruxcapitalgroup-i-took-a-new-position-007.png]]

Subscription annual recurring revenue reached $1.92 billion, up 16%.

Remaining performance obligations (RPO) reached $3.67 billion, up 40%.

Generated $635 million of non-GAAP operating income, $616 million of free cash flow, and ended the year with $1.55 billion of cash and marketable securities.

Let's talk more about the RPO figure. RPO represents contracted revenue that has been booked but not yet recognized. When RPO grows 40%, it signals customers are committing to future spend at an accelerating rate. That is one of the strongest financial signals in the story.

Q4 was also their first quarter above $1 billion of revenue. Revenue was $1.06 billion, up 20% year over year. Non-GAAP operating margin was 21.3%. Product revenue grew 25%. Subscription revenue grew 14%. Storage-as-a-service grew 28%.

Customer scale is there as well with more than 14,500 customers, roughly 64% penetration of the Fortune 500, roughly 42% penetration of the Global 2000, and an audited Net Promoter Score of 84. I mention the NPS because in enterprise infrastructure, a high NPS matters as storage systems are mission-critical. Customers rarely praise storage vendors unless the product is reliable, easy to manage, and well supported.

![[cruxcapitalgroup-i-took-a-new-position-008.png]]

Management guided fiscal 2027 revenue to $4.3 billion to $4.4 billion, implying 17% to 20% growth.

---

### The Franchise Deal

One of the strongest signals from the most recent call was the discussion of franchise deals.

A normal storage deal is tied to a specific workload. A franchise deal means the customer is considering Everpure as one of its strategic storage partners across a broad part of its infrastructure, rather than winning a single workload. Management said these enterprise-scale conversations are increasing. Deals over $5 million grew 80% year over year in Q4.

Platform standardization creates larger deals, deeper customer relationships, and higher switching costs. They appear to be scaling up the quality and size of their enterprise relationships at exactly the moment AI is making the data layer more important.

---

### FlashBlade//EXA

A GPU cluster needs to be fed constantly. It needs training data, model checkpoints, embeddings, logs, metadata, files, code, simulations, and inference data. If the storage system cannot supply data fast enough, expensive compute sits idle.

![[cruxcapitalgroup-i-took-a-new-position-009.png]]

FlashBlade//EXA is aimed directly at that problem. The best detail from the call was the first GPU cloud customer story. The customer had initially selected another vendor, then tested EXA, was impressed by the performance, placed an order within days, deployed it, and followed with additional orders. Management said it is in advanced-stage discussions with dozens more.

That is the type of early product signal worth paying attention to. It shows the product is solving a pain point customers can recognize quickly. One win does not prove a broad AI storage cycle, but the pattern of test, buy, and reorder is encouraging.

---

### Why Inference Makes This More Interesting

Inference may become the broader long-term infrastructure problem.

Inference happens every time a model is used. As AI gets embedded into enterprise software, customer service, search, cybersecurity, coding, analytics, document processing, and internal workflows, inference spreads across many different environments. Some will run on GPUs, some on accelerators, some on CPUs. As smaller models, retrieval systems, AI agents, and enterprise applications scale, CPU-heavy inference environments could grow alongside GPU-heavy ones.

Everpure is a second-order beneficiary here. More inference means more pressure on the systems that store, retrieve, govern, and move enterprise data. An enterprise AI assistant may need access to customer records, internal documents, logs, contracts, product manuals, and security policies simultaneously. That data is scattered. The model needs context and permissions. Fast storage alone is insufficient. The data has to be accessible and governed.

That is the bridge to Everpure.

---

### The Hyperscaler Kicker

The hyperscaler opportunity may be the most important upside lever in the entire thesis.

Everpure is still primarily an enterprise storage company today, but management is pointing clearly toward a larger hyperscale opportunity. Hyperscale grew beyond expectations in fiscal 2026, and management expects hyperscaler shipments and revenues to significantly accelerate in fiscal 2027. The company is in engineering test environments with multiple hyperscalers.

Engineering test environments are important because hyperscalers buy infrastructure carefully. They test, validate, and certify technologies before deploying at scale. Everpure is still in the conversion phase with some of these prospects. The upside comes if those tests turn into production deployments.

The more important point is the margin structure. In normal enterprise storage, Everpure has direct NAND cost exposure because NAND is a key input. In hyperscale, the structure is different. Hyperscalers procure the NAND through their own supply chains while Everpure provides the architecture, software, controllers, integration, and support layer. Management said this structure should produce hyperscaler gross margins of 75% to 85%, which would be materially accretive to the company's overall margin profile.

So the base case is that hyperscale becomes a helpful growth contributor. The bull case is that Everpure becomes a multi-customer architecture supplier for AI data-center storage, collecting high-margin software and architecture revenue while hyperscalers absorb the commodity NAND exposure.

The risk is timing. Management expects most fiscal 2027 hyperscaler revenue in Q3 and Q4. That creates execution risk if deployments slip. The key proof point is another hyperscaler moving from engineering test into production.

---

### The NAND Headwind

The near-term bear case is NAND and component inflation.

AI-driven infrastructure demand has pushed up NAND, memory, CPU, and other component pricing. Everpure raised prices in February and expects Q1 product gross margins to be at the lower end of the normal 65% to 70% range before recovering through the year.

Timing is the problem. Customer proposals often stay in market for around 90 days, which means the company can be fulfilling orders at older pricing while paying newer, higher component costs. If NAND costs continue rising faster than Everpure can reprice, product gross margins could stay under pressure. Customers could also push back after price increases, delay projects, or stretch refresh cycles.

The hyperscaler model helps to offset this because hyperscalers procure their own NAND. But the core enterprise product business still carries that exposure. The near-term test is whether product gross margins recover after Q1 while revenue growth remains strong.

---

### Competition

Everpure competes with legacy enterprise storage vendors like Dell, HPE, NetApp, and IBM, cloud-native and hyperscaler storage from AWS, Azure, and Google, and AI and HPC storage specialists like VAST Data, Weka, and DDN.

The legacy vendors have enormous sales channels and broad infrastructure portfolios. Specialized AI storage players can be sharper in some GPU-cluster environments. Hyperscalers can build internally. Large incumbents can bundle and discount through existing procurement relationships.

Everpure's edge is that it is more focused on modern storage than Dell or HPE, has a stronger growth profile than classic storage comps, built a flash-native architecture from the beginning, and has a strong subscription and lifecycle model. The franchise deal signal suggests it is winning more strategic relationships rather than just point-product bids.

So I think the question ins, can Everpure keep winning strategic platform deals while AI storage attracts more capital, more specialists, and more aggressive bundling from incumbents?

---

### Valuation

At roughly $70 per share and a market cap around $23 billion, this is around 5x forward sales using fiscal 2027 guidance of $4.3 billion to $4.4 billion. The company is guiding to $780 million to $820 million of non-GAAP operating income in fiscal 2027.

That is expensive compared with traditional storage peers. NetApp is the cleanest public comp, larger, more mature, and more profitable, but growing more slowly. Dell and HPE are cheaper on sales but are broader infrastructure companies with less direct AI data-infrastructure purity.

The valuation debate is that if the market keeps valuing Everpure as classic storage, the multiple is demanding. If the company proves that EXA, hyperscale, Fusion, Evergreen, Portworx, and 1touch turn it into a broader AI-era data infrastructure platform, the premium can hold or grow. I think the truth today is somewhere in between. The base business is still enterprise storage. The growth vectors are increasingly tied to AI data infrastructure, subscription models, hyperscaler architecture, and data intelligence.

That is the debate I want exposure to.

---

### What Needs to Go Right

Product gross-margin recovery after Q1 is the first test. Management already flagged that Q1 will be pressured by component inflation. If margins recover through the year, it shows that price increases, data reduction, and supply-chain management are working. If they stay depressed, the bear case gets louder.

EXA customer conversion is the second test. The first GPU cloud win is encouraging, but the real signal is repeatability. Dozens of advanced-stage discussions need to turn into actual deployments, and the pattern of test, buy, and reorder needs to show up more than once.

A second hyperscaler moving from engineering test into production would be the biggest single catalyst the stock could get. Engineering test environments are a positive signal. Production ramps are what count, and another hyperscaler deploying at scale would shift how the market thinks about the durability of that revenue stream.

Continued RPO growth matters because 40% RPO growth signals customers locking in longer-term commitments. If that holds, the market can underwrite more durable growth with more confidence. And real 1touch integration needs to show up as product capability and customer adoption. The acquisition makes strategic sense but of course execution still has to prove it.

---

### My Positioning

I initiated a small position.

*This is a disclosure only. Everyone has to make their own decision based on portfolio size, risk tolerance, time horizon, and existing exposure.*

I am treating this as a position that needs to earn a larger allocation through execution. My rough long-term target, if execution supports the thesis, would be around 5% of my portfolio (which is low-mid size). I may add gradually if proof points arrive, valuation stays reasonable, and the facts keep improving, rather than sizing up all at once on day one.

The reason I want exposure is straightforward. Everpure is profitable, growing, and cash-generative. It has downside support from the base enterprise storage business, nearly $2 billion of subscription ARR, strong customer satisfaction, and consistent free cash flow. It has upside from hyperscale architecture revenue, AI/HPC storage through EXA, inference-driven enterprise data demand, and the longer-term data management push through Fusion and 1touch.

---

### CY YE 2027 Bear / Base / Bull Targets

Bear case: $55–$60
The AI data-layer thesis stalls. Hyperscale stays lumpy, EXA remains early, NAND pressure lasts longer, and the market values $P closer to a storage peer. This assumes roughly 3.5x–4x forward sales and low-teens growth.

Base case: $90–$95
The company executes mostly in line. FY27 growth stays high teens, gross margins recover, EXA adoption broadens, and hyperscale becomes a visible but still developing growth driver. This assumes roughly 5.25x–5.5x forward sales, which is close to a premium infrastructure compounder valuation.

Bull case: $120–$125
Hyperscale becomes the unlock. Another hyperscaler moves from testing into production, EXA turns into a repeatable AI/HPC product cycle, and the market starts treating $P as an AI data-layer platform rather than classic storage. This assumes roughly 6.5x–7x forward sales and sustained 20%+ growth expectations.

---

*Disclosure: I currently own shares of $P / Everpure. I may buy, sell, trim, or add to this position at any time without prior notice. This report reflects my personal research and opinion. It is general information, not individualized investment advice. Nothing in this post should be treated as a recommendation to buy, sell, or hold any security. Position size, risk tolerance, time horizon, cash needs, and overall portfolio context should drive every investment decision. Readers should do their own research and consult a licensed financial adviser if they need personalized advice.*
