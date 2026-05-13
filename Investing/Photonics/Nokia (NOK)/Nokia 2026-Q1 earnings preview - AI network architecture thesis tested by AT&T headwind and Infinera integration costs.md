---
created: 2026-05-13
published: 2026-04-20
description: Crux Capital previews Nokia's Q1 2026 print as a stress test of its AI-infrastructure pivot under a sub-seasonal air pocket, AT&T mobile-contract loss, and €350-400M of Infinera/Shanghai Bell integration costs.
source: https://cruxcapitalgroup.substack.com/p/nokia-earnings-preview-what-to-watch
type: earnings
authors: ["Crux Capital Group (@cruxcapitalgroup)"]
---

# Nokia 2026-Q1 earnings preview - AI network architecture thesis tested by AT&T headwind and Infinera integration costs

Crux Capital's pre-earnings note on [[Nokia (NOK)]] ahead of its 2026-Q1 print, framing the quarter as a checkpoint on the AI-infrastructure architectural pivot under CEO Justin Hotard. Management has guided to a worse-than-seasonal Q1 revenue air pocket, partly from the lost AT&T mobile network contract. Key watch items: book-to-bill >1 in Optical and IP Networks, the €100M opex commitment targeting €1B incremental data-center revenue by 2028, CAPEX step-up to €900M-1B for the California InP fab, free-cash-flow conversion staying in the 55-75% target band, and any customer commitments tied to the 2027 Ontario/Huron/Superior/Pacific optical-chip roadmap. The [[Infinera]] acquisition doubles Nokia's optical footprint and the [[Nvidia (NVDA)]] $1B strategic investment anchors the AI-RAN edge thesis. Bank of America has shifted to sum-of-the-parts valuation, applying 30x to Optical & IP Networks vs 10x to legacy telecom — signaling Wall Street is starting to adopt the framework.

## Key Takeaways

- **Q1 guidance is intentionally weak**: management pre-warned of greater-than-normal sequential decline (Nokia historically does ~24% QoQ Q4→Q1; this quarter is worse due to telecom customers pulling spend forward into late 2025 plus the AT&T loss). Operating margin pressured by upfront product launch costs. Key confirm: target of ≥€1.5B Mobile Infrastructure operating profit despite AT&T headwind.
- **AI/cloud order book is the leading indicator**: 2025 booked €2.4B from AI/cloud customers. Watch book-to-bill ≥1 for both Optical and IP Networks. New €100M annual opex commitment targets €1B incremental data-center revenue by 2028.
- **Manufacturing structural advantage**: $2B annual R&D budget, CHIPS Act-supported California InP fab going from 3-inch to 6-inch wafers = 4x wafer size × tooling = 20x capacity uplift. Allentown PA advanced packaging center. Pre-merger Infinera had only $300M R&D budget — the gap is enormous.
- **Optical hardware roadmap**: 18E switch with 756 high-speed ports for scale-across; new signal booster at 8x density (160 per standard rack); double-sided pluggable combining short-reach + long-reach into one device, saving 70% in cost/space. Next-gen chips (Ontario/Huron/Superior/Pacific) sample summer 2027 — meaningful timeline gap.
- **AI-RAN three-stage frame**: AI for RAN (live; agentic AI cut downtime 96%) → AI and RAN (shared 5G+AI infra via anyRAN + NVIDIA) → AI on RAN (operators rent spare tower compute; SoftBank demo). Hardware-regret-free pitch: current AirScale gear is software-upgradable.
- **Cash burn watch**: 2026 CAPEX €900M-1B for fab outfitting; €350-400M integration costs over 24-36 months (Infinera + Nokia Shanghai Bell buyout); part of €800M-1.2B cost-savings program. FCF conversion 55-75% target is the discipline marker.
- **Portfolio Businesses cleanup**: first report under new simplified operating model. Four non-core units (legacy fixed wireless access, microwave radios) lost €97M in 2025. Any divestitures = immediate margin catalyst the market may be underweighting.
- **Author's add levels post-print**: $10 (would need really good guidance), $9, $8.3.

## Tickers & entities

- Subject: [[Nokia (NOK)]]
- Mentioned: [[Nvidia (NVDA)]] (AI-RAN partner, $1B strategic stake), [[Ciena (CIEN)]] (related Crux coverage)
- Non-vault references: Infinera (acquired by Nokia, formerly INFN), AT&T, T-Mobile, SoftBank, Cloudflare, Bank of America

## Original Content

### NOKIA Earnings Preview - What to Watch

#### Testing the AI Network Architecture Thesis

By Gaetano (Crux Capital Group) — Apr 20, 2026

Nokia reports Q1 2026 earnings this Thursday. Management has already prepared the market for somewhat of a rough headline quarter, explicitly telling us to expect a sub-seasonal air pocket in revenue. One messy quarter does not change what is actually being built here.

Nokia still predominantly carries the legacy mobile phone manufacturer label. The reality is considerably different. Under CEO Justin Hotard, who took the helm in early 2025, Nokia has increasingly repositioned itself as a global infrastructure company in the middle of an aggressive pivot toward AI data center and edge infrastructure.

Hotard framed the mission:

> "Nokia changed the world once by connecting people, and will again by connecting intelligence."

Two recent strategic moves give that vision real weight. Nokia closed a $2.3 billion acquisition of Infinera, effectively doubling its optical networking footprint, and deepened its alignment with NVIDIA through a strategic partnership around AI-era networking infrastructure. Thursday's call is a real opportunity to test whether the architectural thesis is holding up under the pressure of an expensive transition.

Wall Street is starting to adopt this framework. A recent Bank of America research update moved to a sum-of-the-parts valuation for Nokia, applying a 30x multiple specifically to its high-growth Optical and IP Networks business while leaving the legacy telecom business at 10x. That framing change tells you something about where the conversation is heading.

If you want to read some of my other coverage on NOKIA, read these:

- [Nokia's Third Act Is Starting to Come Into View](https://cruxcapitalgroup.substack.com/p/nokias-third-act-is-starting-to-come) — Apr 14
- [CIEN and NOK Bullish](https://cruxcapitalgroup.substack.com/p/cien-and-nok-bullish) — Apr 3

*The rest of this post is for paid subscribers. What follows covers the full architectural setup across scale-across, manufacturing, and AI-RAN, the honest stress test of what could break the thesis, and the specific watchlist for Thursday's call.*

---

### Part 1: Some Architectural Setup

The physical map of the internet is fundamentally changing, pulling AI intelligence out of the data center and closer to the physical world.

To understand one reason why, you have to look at how AI changes internet traffic. As Cloudflare's CEO recently noted, AI bot traffic is expected to exceed human traffic online by 2027. When a human shops online, they might visit three or four websites. When an AI agent is given a shopping task, it fans out and scans thousands of sites in seconds. The internet is shifting from a human-browsing model to a highly active machine-to-machine model. This creates a massive traffic problem, moving the bottleneck from inside the data center to the wide-area network connecting data centers together. Nokia sits across the layers of that transition.

**The scale-across supercycle and Jevons Paradox**

To handle this explosive machine-to-machine traffic, tech giants are building scale-across networks, linking multiple data centers together over long distances via high-speed fiber optics so they can act as one giant AI brain. The industry has to go beyond faster cables and dramatically lower the cost, physical space, and power required to send data.

Nokia recently invoked Jevons Paradox to explain the dynamic. Making a resource cheaper does not reduce demand. It explodes it. Dropping the price of data transport by 50% using new pluggable technology enabled tech giants to build massive interconnected networks that were previously too expensive to consider.

To physically support this massive web of interconnected data centers, Nokia is rolling out a wave of new hardware designed to handle extreme traffic while taking up much less physical space. For example, their new 18E switch acts as an ultra-fast traffic intersection for data, packed with 756 high-speed ports specifically built to manage the heavy, continuous flow of AI traffic moving between distant locations. Because data signals naturally fade as they travel long distances over fiber-optic cables, Nokia also created a new signal booster that is so small they can cram 160 of them into a single standard server rack. This represents an 8x improvement in density, which saves tech giants massive amounts of highly expensive data center real estate.

Finally, they introduced a brand new "double-sided" pluggable that acts as a 2-in-1 space saver. Normally, networks need completely separate, bulky equipment boxes to translate short-distance computer signals into long-distance laser signals, but Nokia combined both functions into one tiny device that plugs directly into the network, saving tech giants up to 70% in total costs and physical space.

**The manufacturing strength**

Nokia's President of Network Infrastructure recently captured the urgency inside the buildout when he discussed how customers are buying roadmaps. Tech giants are planning their data centers, power grids, and cooling systems years in advance, reserving factory capacity for products still being built. To meet that demand, Nokia is deploying a $2 billion annual R&D budget and expanding its CHIPS Act-supported semiconductor factory in California, specifically to build indium phosphide optical chips.

InP is a highly coveted material required for building the most complex optical systems, and owning these fabs gives Nokia a massive structural advantage by protecting them from the third-party supply-chain crunches currently choking competitors. Moving from 3-inch to 6-inch InP wafers (4x increase), combined with more advanced manufacturing tools, increases their capacity to build these components by 20x.

Think of it as upgrading to a much larger oven. Nokia has also expanded a dedicated advanced packaging center in Allentown, Pennsylvania to support that scale-up. When Infinera was independent, it competed with a $300 million R&D budget. The gap in manufacturing depth between then and now is enormous.

**AI-RAN: turning the cell tower into a mini data center**

Beyond fiber, Nokia is working to turn the world's cellular towers into distributed AI compute nodes, developing the concept across three distinct stages. This is the core reason NVIDIA recently invested $1 billion in the company: NVIDIA does not want AI compute trapped entirely inside centralized data centers. They want it pushed to the edge of the network to power "physical AI" like industrial robotics, real-time video, and autonomous machines.

The most commercially established today is AI for RAN, where software makes networks run better with less human intervention. Nokia recently introduced an agentic AI tool that reduced network downtime by 96%. The second stage is AI and RAN, where 5G and AI workloads share the same physical equipment using Nokia's anyRAN software integrated with NVIDIA's platform.

The third stage is AI on RAN, where the network becomes a cloud-like service. SoftBank recently demonstrated how operators can identify spare compute capacity on their cell towers and rent it out to third parties to run AI tasks. Importantly, to overcome telecom operators' reluctance to buy hardware that might become obsolete, Nokia guarantees that if they buy current AirScale equipment today, it will be fully upgradable to run these AI-RAN workloads via software updates in the future.

---

### Part 2: The Stress Test

This is an ambitious architectural transition, and tracking it honestly requires looking at where the thesis could break.

**The telecom drag**

Roughly 70% of Nokia's 2025 business base was still tied to traditional telecom operators, down from 78.5% in 2024. The direction is right, but the legacy footprint remains large. Nokia's own management acknowledges a stable but challenging telecom market, and the company recently lost a significant mobile network contract with AT&T, a loss management has explicitly warned will create a severe, multi-year revenue headwind in North America starting heavily in 2026. Even with rapid growth in the AI and cloud segment, the thesis strains if the legacy telecom business contracts faster than the new business can grow to replace it.

**Execution risk on the roadmap**

Selling a roadmap means selling a future promise, and the timeline here is long. Nokia's next-generation optical chips, named Ontario, Huron, Superior, and Pacific, will be available for customer sampling in the summer of 2027. That is a meaningful gap in a fast-moving market. On top of the manufacturing timeline, Nokia is managing the integration of Infinera alongside full ownership of Nokia Shanghai Bell, which carries €350 million to €400 million in integration costs over the next 24 to 36 months. If manufacturing timelines slip or integrations get disruptive, competitors could absorb hyperscaler demand before Nokia's products reach the market.

**AI-RAN stalling at the proof-of-concept phase**

The T-Mobile and SoftBank demonstrations prove the technology works. The real bottleneck is commercial timing. Telecom operators are historically slow to adopt new physical architectures, and many are operating under budget pressure. If operators are unwilling or unable to invest the capital required to upgrade their towers into AI compute nodes, the monetization phase may take far longer than current enthusiasm suggests, leaving AI-RAN as an internal cost-saving tool rather than a new revenue surface.

---

### Part 3: The Q1 Earnings Watchlist

Thursday requires separating structural AI demand from the real costs of a legacy telecom transition. Based on what management has already communicated, here is what to watch.

**The air pocket and the AT&T headwind**

Management has already warned that Q1 net sales will decline more than normal seasonal patterns imply. Historically Nokia sees roughly a 24% sequential revenue decline from Q4 to Q1. The additional pressure comes from telecom customers who aggressively pulled spending forward into late 2025, leaving a void at the start of 2026, compounded by the AT&T loss in North America. Operating margins are also expected to be weak as the company absorbs upfront product launch costs. The key confirmation to listen for is management reiterating that this is a temporary transition and that they can maintain their target of at least €1.5 billion in operating profit from Mobile Infrastructure despite the AT&T headwind.

**The AI order book and the €100 million data center bet**

Last year Nokia booked €2.4 billion in orders from AI and cloud customers. One important datapoint Thursday is whether the book-to-bill ratio remains firmly above 1 for both Optical and IP Networks, confirming hyperscaler demand is holding. Equally important is progress on Nokia's data center network switches, and whether the recent hire of Greg Dorai as Head of IP Networking is accelerating the company's ability to sell into big tech. Nokia has also made a significant new commitment of up to €100 million in additional annual operating expenses specifically to generate €1 billion in incremental data center revenue by 2028. Thursday is an early checkpoint on whether that bet is gaining traction. Any customer commitments around the 2027 optical chip roadmaps and the new double-sided pluggables would add further confidence.

**The fab, integration costs, and cash burn**

Nokia is spending heavily this year to fund its future. CAPEX is stepping up to €900 million to €1 billion to outfit the California factory with 6-inch indium phosphide wafers. Nokia's CFO has confirmed that 2026 will be heavier on the cash outflow side as part of an overarching €800 million to €1.2 billion cost-saving program, with additional integration costs of €350 million to €400 million from the Infinera acquisition and Nokia Shanghai Bell buyout expected over the next two to three years. The metric to track is whether free cash flow conversion stays within the 55-75% target despite that level of structural investment. Staying inside that range signals the investment cycle is being managed well.

**Cleaning up the portfolio businesses**

Thursday is the first time Nokia reports under its new simplified operating model. The new Portfolio Businesses segment isolated four non-core units, including legacy fixed wireless access and microwave radios, that generated an operating loss of €97 million in 2025. Management has stated their 2026 target is to conclude a future direction for each of them. Any divestitures, sales, or shutdowns announced in this segment would be an immediate margin catalyst that the market may be underweighting.

**AI-RAN moving toward commercial timelines**

The demonstrations with T-Mobile and SoftBank moved the AI-RAN conversation from concept to working proof. Thursday the question shifts to timing. Any language moving from validation to commercial deployment would be a meaningful step forward for that part of the thesis, and a reiteration of the zero hardware regret pitch to telecom operators would reinforce the adoption argument.

---

### Closing

As always, I am mostly interested in the details we get in the call. The market should move on the first print. If everything looks good on the call, my levels I will be watching for a potential add are as follows:

$10 (would need to be really good guidance)

$9

$8.3

---

*The information provided is for informational purposes only and does not constitute investment advice, a recommendation, or an offer to buy or sell any securities. The author may hold positions in securities mentioned. Readers should conduct their own due diligence and consult with a financial advisor before making investment decisions.*
