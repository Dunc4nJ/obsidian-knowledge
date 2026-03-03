---
created: 2026-02-06
description: A short reading list of prediction-market research papers shared in a Polymarket context, covering price misalignment, volatility modeling, and mechanism design for prediction.
source: https://x.com/kyledewriter/status/2019421720331907494
type: reading-list
---

# polymarket research papers

## Papers (with what they’re about)

- **The extent of price misalignment in prediction markets** (Rothschild; Pennock, 2014) — https://researchdmr.com/files/PriceMisalignment.pdf
  - Empirical study of how far prediction-market prices can deviate from internally consistent / efficient benchmarks (a lens on measurable market inefficiency).

- **Modeling Volatility in Prediction Markets** (Archak; Ipeirotis, NYU working paper CeDER-08-07) — https://archive.nyu.edu/jspui/bitstream/2451/27716/4/CeDER-08-07.pdf
  - Models prediction-market contract prices as diffusions and derives volatility as a function of price and time-to-expiration; validates on InTrade and compares vs. GARCH.

- **Designing Markets for Prediction** (Chen; Pennock, AI Magazine 2010) — https://bpb-us-e1.wpmucdn.com/sites.harvard.edu/dist/b/845/files/2025/01/aim10.pdf
  - Survey of prediction mechanisms (prediction markets + peer prediction), emphasizing design goals and properties that make prediction mechanisms work.

## Related

- [[mathematical infrastructure not luck extracted 40 million from Polymarket]] — applies the optimization frameworks described in these papers to real Polymarket arbitrage
- [[polymarket arbitrage trading requires barrier frank-wolfe initialization and adaptive contraction]] — implementation details for the Barrier Frank-Wolfe algorithm
- [[attention markets shift arbitrage from binary constraints to latency correlation and manipulation volatility]] — newer market type where mechanism design limits from these papers create new edge classes

## Original content

> **@KyleDeWriter (Kyle the Writer)** — Thu Feb 05 2026
>
> Shared three links as a quick Polymarket-adjacent reading list: price misalignment / inefficiencies, volatility modeling, and a mechanism design survey for prediction markets.
>
> Source: https://x.com/KyleDeWriter/status/2019421720331907494
