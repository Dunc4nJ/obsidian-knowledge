---
created: 2026-02-23
description: A comprehensive breakdown of how institutional market makers use Avellaneda-Stoikov reservation pricing, GLFT inventory bounds, Glosten-Milgrom adverse selection models, and VPIN kill switches to dominate Polymarket order books.
source: https://x.com/gemchange_ltd/status/2025908468633268456
type: framework
---

## Key Takeaways

The reservation price formula `r = s - q*gamma*sigma^2*(T-t)` is the single most important number in market making: the fair price at which a market maker is indifferent to trading, shifted linearly by inventory. Long inventory drops reservation price below mid (sell aggressively), short inventory raises it (buy aggressively). Every institutional desk runs some version of this. This is the theoretical backbone behind [[polymarket feb 18 rule change killed taker bots and made market making the new meta|the maker-first meta]] that emerged after Feb 18.

Standard Avellaneda-Stoikov breaks for prediction markets in four critical ways: unbounded prices (fix: logit transformation to keep prices in 0-1), terminal binary settlement (price undergoes phase transition near resolution, not smooth diffusion), event-driven jumps (need jump-diffusion not pure Brownian motion), and no delta-hedging (the "underlying" is an unobservable probability — you can't buy the probability of Trump winning elsewhere to hedge). Dalen (2025) proposed the logit jump-diffusion as the standard pricing kernel for prediction markets.

The GLFT framework (Guéant-Lehalle-Fernandez-Tapia 2013) adds hard inventory bounds — if you can stomach losing $50k on one market and price is $0.50, then Q = 100,000 tokens. Spreads naturally widen as you approach the limit and quotes disappear entirely when you hit it. This is critical because [[mathematical infrastructure not luck extracted 40 million from Polymarket|the top extractors]] manage catastrophic binary risk through position limits, not hedging.

Adverse selection (Glosten-Milgrom) is existentially dangerous in prediction markets: campaign staff know private polls, athletes know injury status. Near resolution, informed trader fraction approaches 1 and market making becomes suicidal. VPIN (Volume-Synchronized Probability of Informed Trading) serves as a real-time kill switch — it spiked 2 hours before the 2010 Flash Crash. DeFi trade toxicity is approximately 3.88x higher than centralized exchange toxicity.

The competitive landscape has undergone a mass extinction: average arbitrage window compressed from 12.3 seconds (2024) to 2.7 seconds (Q1 2026), with 73% of arb profits captured by sub-100ms bots. Jump Trading hired ~20 people for a dedicated prediction markets desk; DRW recruiting at $200K base. Bot accounts at 3.7% of addresses generate 37.4% of volume. The 0.04% of addresses captured 71% of all realized gains while 70% of addresses lost money. The [[polymarket 5-minute market bot latency depends on server region with ireland and stockholm 294ms faster than seoul|latency arms race]] has entered institutional territory.

The production bot stack has four layers: (1) base spread from Avellaneda-Stoikov/GLFT scaled to realized belief volatility across multiple timeframes, (2) inventory-skew shifting midpoint, (3) reward-optimization overlay (~$12M annual liquidity rewards, quadratic spread function, two-sided quoting earns 3x rewards), and (4) toxicity filter widening/withdrawing on VPIN spikes. Plus Dutch Book detection, conditional hedging across correlated markets, and cross-platform arbitrage.

## External Resources

- [Avellaneda & Stoikov, "High-Frequency Trading in a Limit Order Book" (2008)](https://math.nyu.edu/~avellane/HighFrequencyTrading.pdf) — The foundational market-making paper
- [Guéant, Lehalle, Fernandez-Tapia, "Dealing with the Inventory Risk" (2013)](https://arxiv.org/abs/1105.3115) — Bounded inventory market making
- [Glosten & Milgrom, "Bid, Ask, and Transaction Prices" (1985)](https://www.jstor.org/stable/1243269) — Why the spread exists (adverse selection)
- [Easley, López de Prado, O'Hara, "Flow Toxicity and Liquidity" (2012)](https://papers.ssrn.com/sol3/papers.cfm?abstract_id=1695596) — VPIN toxicity detection
- [Dalen, "Toward Black-Scholes for Prediction Markets" (2025)](https://arxiv.org/abs/2510.15205) — Logit jump-diffusion pricing kernel
- [Kyle, "Continuous Auctions and Insider Trading" (1985)](https://www.jstor.org/stable/1913210) — Price impact coefficient lambda
- [Sasha Stoikov IAQF 2023 lecture](https://x.com/gemchange_ltd/status/2025908468633268456) — 80-minute lecture on market making meets microstructure (video in tweet)
- [Lorig, Zhou, Zou, "Optimal Bookmaking" (2021)](https://arxiv.org/abs/2105.01976) — Optimal market making theory
- [Hanson, "Logarithmic Market Scoring Rules" (2003/2007)](https://mason.gmu.edu/~rhanson/mktscore.pdf) — LMSR foundation
- [Account88888 on Polymarket](https://polymarket.com/@Account88888) — Alleged Jane Street India account, $360K in 25 days on 15-min crypto

## Original Content

> @gemchange_ltd — 2026-02-23
>
> Most people trading Polymarket have never heard of Sasha Stoikov. Meanwhile, the bots taking their money are running his math on every single quote.
>
> This is Stoikov at IAQF in 2023 - an 80-minute lecture on where market making meets market microstructure. The actual theory from the person who built it.
>
> He covers what textbooks skip: how optimal quotes degrade under real order flow, why inventory pressure isn't linear in practice, and what happens when your Poisson arrival assumptions meet an actual limit order book.
>
> My full breakdown: Avellaneda-Stoikov adapted for binary settlement, GLFT inventory bounds, Glosten-Milgrom adverse selection, VPIN kill switches - is in the article.
>
> Start with Stoikov's lecture. Then read the thread.
>
> [Original post](https://x.com/gemchange_ltd/status/2025908468633268456)

> [!quote]- Full article by @gemchange_ltd: How Jump Trading, Jane Street, and a Guy With $10K Fight Over the Same Polymarket Order Book
>
> **The Mass Extinction Event**
>
> In early 2024, an anonymous developer (@defiance_cr) built a market-making bot on Polymarket. Starting capital: $10,000. At peak: $700-800/day (~2,700% annualized). He was one of maybe "3-4 serious liquidity providers" on the entire platform. By February 2026, he open-sourced the bot with a note: "this bot is NOT profitable in current market conditions due to increased competition."
>
> Bloomberg reported Jump Trading reached agreements to take equity stakes in both Polymarket and Kalshi. They hired ~20 people for a dedicated prediction-markets desk. DRW started recruiting at $200K base. Susquehanna had been providing institutional liquidity on Kalshi since April 2024.
>
> "JaneStreetIndia" (renamed "Account88888") appeared on Polymarket and extracted $360,000 in 25 days trading 15-minute crypto markets.
>
> Polymarket processed over $9 billion in volume in 2024 (up from $73M in 2023 — 120x increase) and exceeded $13 billion in 2025. Bot accounts at 3.7% of addresses generate 37.4% of transaction volume. The 0.04% of addresses captured 71% of all realized gains; 70% of addresses lost money.
>
> ---
>
> **Part I: The Machine You're Trading Against — How Polymarket's CLOB works**
>
> Polymarket runs a hybrid-decentralized Central Limit Order Book (CLOB). Orders are signed off-chain as EIP-712 messages, matched by Polymarket's centralized operator, and settled atomically on-chain via Polygon. The operator can match crossing orders but cannot set prices, execute unauthorized trades, or censor participants.
>
> Three ways an order fills:
>
> 1. Direct Transfer — YES tokens change hands
> 2. Minting — buyer of YES at $0.70 + buyer of NO at $0.30 → system locks $1.00 USDC, creates YES+NO pair
> 3. Merging (Burning) — seller of YES at $0.60 + seller of NO at $0.40 → tokens destroyed, $1.00 USDC released
>
> The invariant P(YES) + P(NO) = $1.00 is enforced at the smart contract level through minting/merging. Every token pair is backed by exactly $1 of USDC.
>
> Under the hood: Gnosis Conditional Token Framework (CTF). Each binary market creates two ERC-1155 position IDs:
> ```
> conditionId = getConditionId(oracle, questionId, outcomeSlotCount=2)
> positionId_YES = getPositionId(USDC, getCollectionId(0x0, conditionId, 0b01))
> positionId_NO  = getPositionId(USDC, getCollectionId(0x0, conditionId, 0b10))
> ```
>
> For multi-outcome markets, a NegRiskAdapter wraps USDC into WrappedCollateral for NO→YES conversions across outcomes.
>
> Fee structure: most markets 0% for makers and takers. Fee-enabled markets: fee = baseRate × min(price, 1-price) × size. Max ~1.56% at p=0.50, approaching zero at extremes. Taker fees redistributed daily as maker rebates.
>
> Tick sizes: $0.01 or $0.001. Valid prices: $0.01 to $0.99. Rate limits: 3,000 order requests per 10-minute window.
>
> ---
>
> **Part II: The Reservation Price — The Single Most Important Number in Market Making**
>
> Avellaneda & Stoikov (2008) — the Bible of quantitative market making.
>
> Three assumptions: mid-price follows arithmetic Brownian motion; order arrivals are Poisson processes with intensity decreasing exponentially with quote distance from mid (A is baseline arrival rate, κ measures price sensitivity); market maker has CARA risk aversion with parameter γ.
>
> The key result — the reservation price:
>
> r(s,q,t) = s - q × γ × σ² × (T-t)
>
> The fair price is the mid-price shifted linearly by inventory. Long (q>0) → reservation drops below mid (want to sell). Short (q<0) → rises above mid (want to buy). Shift scales with risk aversion (γ), volatility (σ²), and time remaining (T-t).
>
> Optimal spread:
>
> δ = γσ²(T-t) + (2/γ) × ln(1 + γ/κ)
>
> Two terms: inventory risk compensation (wider when volatile) + pure informational profit from market making (persists even if risk-neutral).
>
> When flat (q=0), quotes symmetric around mid. As inventory grows long, ask tightens (aggressive sell), bid widens (less eager to buy more).
>
> **Why prediction markets break this model:**
>
> Problem 1: Unbounded prices. Fix: logistic sigmoid (logit transformation) to keep prices in (0,1).
>
> Problem 2: Terminal binary settlement. Prices must converge to 0 or 1. Volatility undergoes phase transition near resolution — dominated by belief about which barrier, not smooth diffusion.
>
> Problem 3: Event-driven jumps. Need jump-diffusion model, not pure Brownian motion. Dalen (2025) proposed the logit jump-diffusion with four risk factors: delta (directional), gamma (curvature/sensitivity to news), belief-vega (sensitivity to σ_b), cross-event correlation.
>
> Problem 4: No delta-hedging. The "underlying" is an unobservable probability. No replicating portfolio. Must manage inventory entirely through spread adjustment, position limits, and cross-market hedging.
>
> ---
>
> **Part III: The Bounded Inventory Problem (GLFT)**
>
> Guéant, Lehalle, Fernandez-Tapia (2013) solved this by introducing explicit inventory bounds |q| ≤ Q into Avellaneda-Stoikov.
>
> For prediction markets, Q maps directly to maximum tolerable loss from a single binary outcome. If you can stomach losing $50,000 on one market at price $0.50, then Q = 100,000 tokens. Spreads naturally widen approaching the limit; quotes disappear at the limit.
>
> Guéant (2017) extended to multi-asset market making — directly applicable when making markets in multiple correlated outcomes (all state election markets, multiple NFL games, etc.).
>
> ---
>
> **Part IV: The Adverse Selection Nightmare (Glosten-Milgrom)**
>
> Every spread exists primarily for one reason: adverse selection. Some people hitting your quotes know more than you. The spread is the tax you charge to survive trading against informed traders.
>
> At p=0.5, spread = μ (the informed trader fraction). Even a risk-neutral, competitive, frictionless market maker must charge a positive spread — zero spread means guaranteed losses to insiders.
>
> In prediction markets, information asymmetry is extreme: campaign staff know private polls, athletes know injury status, insiders know regulatory decisions. Near resolution, μ approaches 1 and market making becomes suicidal.
>
> Kyle's lambda — price impact coefficient: higher λ = lower liquidity = more adverse selection. In prediction markets, λ spikes near resolution as σ_v increases and σ_u decreases (casual traders exit, remaining flow is predominantly informed).
>
> VPIN (Easley, López de Prado, O'Hara 2012) — real-time toxicity alarm. If buy/sell volume balanced = noise. If imbalanced = informed aggression. Spiked 2+ hours before the 2010 Flash Crash. DeFi trade toxicity ~3.88x higher than CEX toxicity.
>
> VPIN serves as real-time kill switch: when VPIN rises sharply, widen spreads or withdraw quotes entirely.
>
> ---
>
> **Part V: What the Bots Actually Do — The Production Stack**
>
> Four-layer spread-setting:
>
> Layer 1: Base spread from Avellaneda-Stoikov/GLFT, scaled to realized belief volatility across multiple timeframes (3h, 24h, 7d, 30d).
>
> Layer 2: Inventory-skew component shifting midpoint based on current position.
>
> Layer 3: Reward-optimization overlay. ~$12M annual liquidity rewards. Quadratic spread function penalizes orders far from midpoint. Two-sided quoting earns ~3x rewards of single-sided.
>
> Layer 4: Toxicity filter widening/withdrawing on VPIN or volume anomalies.
>
> Plus: Dutch Book detection (buy cheap side when outcome prices deviate from $1.00), conditional hedging (long Pennsylvania → short national election), cross-platform arbitrage.
>
> Kill switch architecture: GTD orders auto-expire before high-impact events. cancelAll() on error/position breach/toxicity. Staged withdrawal near resolution — spreads widen progressively, full withdrawal in final minutes.
>
> Average arbitrage window: 12.3 seconds (2024) → 2.7 seconds (Q1 2026). 73% of arb profits captured by sub-100ms bots.
>
> ---
>
> **Part VI: Technical Infrastructure — Four-Module Bot Architecture**
>
> Data Collector: WebSocket for real-time orderbook. Track sequence numbers for missed messages. Local orderbook copy with incremental updates. Reconnection with exponential backoff.
>
> Strategy Engine: Fair value via Bayesian probability model. Optimal spreads via Avellaneda-Stoikov/GLFT. Inventory skew. Order sizes via Kelly criterion.
>
> Order Manager: Batch placement via postOrders(). Cancel/replace cycles. GTD expiration. PostOnly flag (added Jan 2026).
>
> Risk Manager: Position limits. VPIN monitoring. Kill switch. Real-time P&L. CTF splitting/merging.
>
> Latency: off-chain matching near-instant. On-chain settlement ~2s (Polygon). Gas ~$0.007/tx. Professional target: sub-10ms round-trip on colocated VPS. Critical race is canceling stale quotes before adverse fill.
>
> ---
>
> **Part VII: What This All Means**
>
> Remaining edge requires three simultaneous capabilities:
> 1. Price events more accurately (superior probability models, faster info processing, proprietary data)
> 2. Manage unique binary risk structure (logit transformation, jump-diffusion, terminal settlement, no delta-hedging)
> 3. Execute at institutional quality (sub-10ms latency, kill switches, capital-efficient CTF splitting, cross-market hedging)
>
> The window where $10K and a Python script could compete is closed. The firms that understood this first already have their 20-person desks built.
>
> **References:**
> - Avellaneda & Stoikov (2008) — HFT in a Limit Order Book
> - Guéant, Lehalle, Fernandez-Tapia (2013) — Dealing with Inventory Risk
> - Guéant (2017) — Optimal Market Making
> - Glosten & Milgrom (1985) — Bid, Ask, and Transaction Prices
> - Kyle (1985) — Continuous Auctions and Insider Trading
> - Easley, López de Prado, O'Hara (2012) — Flow Toxicity (VPIN)
> - Dalen (2025) — Toward Black-Scholes for Prediction Markets
> - Hanson (2003/2007) — Logarithmic Market Scoring Rules
> - Chen & Pennock (2007) — Bounded-Loss Market Makers
> - Lorig, Zhou, Zou (2021) — Optimal Bookmaking
>
> [Original post](https://x.com/gemchange_ltd/status/2025313265551651240)

> [!quote]- Thread replies (selected)
> **@sorokx:** the reservation price formula (r = s - qγσ²) is genuinely one of the most underrated concepts in prediction market trading, most people optimizing for win rate completely ignore inventory risk and end up with asymmetric exposure on the wrong side. The adverse selection section is where most retail market makers get destroyed. Glosten-Milgrom is basically the reason the spread exists at all — it's not friction, it's the market maker's compensation for being the liquidity provider of last resort against people who know more than you.
>
> **@MykytaHaida:** So basically PM put out a nice clean order book, retail built bots on it, institutions watched the bots prove the concept was profitable, then came in and ate everyone. Classic crypto circle of life?
>
> **@TradfiBaby:** Pretty good. Notes: Polymarket now have maker rebates (for order filled) and daily rewards (post quote only, doesn't need to fill). Toxic flow modelling based on orderbook imbalance is a good framework tho not the best. Most people on CT will have latency so latency section would be good.
>
> **@austntatiously:** was recently observing that standard volatility modeling for estimating probability is way off when comparing my est. to the market price. makes sense that Brownian motion (which assumes normal dist) is wrong and a logistic sigmoid is a better risk model
>
> **@zerqfer:** From $10K Python scripts to Jump desks with 20 quants. The extinction event already happened.
>
> **@fixnik28:** most traders dont realize they are up against the avellaneda stoikov math every time they hit a quote on polymarket
