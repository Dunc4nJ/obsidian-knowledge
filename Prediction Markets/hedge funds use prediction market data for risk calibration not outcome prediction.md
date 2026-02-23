---
created: 2025-07-27
description: A complete roadmap showing how hedge funds extract alpha from prediction market data through empirical Kelly sizing, calibration surface analysis, and maker-taker order flow decomposition rather than superior forecasting.
source: https://x.com/RohOnChain/status/2023781142663754049
type: framework
---

# Hedge funds use prediction market data for risk calibration not outcome prediction

## Key Takeaways

The core thesis is that institutional edge in prediction markets comes from process, not information. Hedge funds do not use prediction market data to predict outcomes better than retail. They use it as a laboratory for three specific methods: empirical risk calibration, systematic bias detection, and order flow analysis. This reframes the entire value proposition of the newly released 400M+ trade dataset from [[polymarket research papers]] and related Kalshi data.

The first method, Empirical Kelly with Monte Carlo uncertainty quantification, addresses a fundamental flaw in textbook position sizing. Standard Kelly assumes you know your edge with certainty, but real edge estimates are distributions. By filtering 400 million historical trades for exact pattern matches, constructing empirical return distributions (which are almost never normal), and running 10,000 Monte Carlo path simulations, institutions size for the 95th percentile drawdown rather than the median. This typically haircuts position sizes by 50% or more compared to naive Kelly, which is the difference between steady compounding and ruin. This connects directly to the execution discipline documented in [[mathematical infrastructure not luck extracted 40 million from Polymarket]], where position sizing and slippage management proved critical.

The second method extends calibration analysis from one dimension (price) to a calibration surface across both price and time. Analysis of 72.1 million Kalshi trades confirms the longshot bias is real: at 1-cent contracts, takers win only 0.43% of the time against a 1% implied probability, a -57% mispricing. The institutional hypothesis is that this bias varies temporally: strongest far from resolution (when retail sentiment and hope dominate), compressing as information accumulates mid-period, with potential reversal near resolution as obvious outcomes become undeniable.

The third method, order flow decomposition, reveals that makers systematically profit not through superior forecasting but through structural arbitrage. Makers buying YES earned +0.77% excess returns; makers buying NO earned +1.25%. The near-symmetry (Cohen's d approximately 0.02) proves makers are not picking winners. They are exploiting a documented "costly preference for affirmative, longshot outcomes" in the taker population. Takers exhibit negative excess returns at 80 of 99 price levels. This structural dynamic echoes the latency and execution advantages explored in [[attention markets shift arbitrage from binary constraints to latency correlation and manipulation volatility]], where speed and positioning matter more than directional conviction.

The dataset underpinning all of this is from Jon Becker (@beckerrjon): 400M+ trades from Polymarket and Kalshi going back to 2020, stored as Parquet files with tick-level granularity (timestamp, price, volume, taker direction). The setup requires Python 3.9+, 40GB disk space, and is available at `github.com/Jon-Becker/prediction-market-analysis`. This is the same granularity institutional data vendors charge $100K+ annually for in traditional markets, now open source.

The practical implication for the [[moc - Polytrader]] project is clear: any systematic strategy should incorporate Monte Carlo-adjusted Kelly sizing, time-varying calibration filters, and a maker-side execution bias rather than relying on directional prediction alone.

## External Resources

- [Prediction Market Analysis Dataset (Jon Becker)](https://github.com/Jon-Becker/prediction-market-analysis) — 400M+ trades from Polymarket and Kalshi, Parquet format, open source
- [uv dependency manager](https://astral.sh/uv/install.sh) — used for environment setup in the analysis workflow
- [Original embedded tweet about dataset release](https://x.com/i/status/2021280975318040917) — @beckerrjon's announcement of the dataset

## Original Content

> [!quote]- Full Thread by @RohOnChain (Roan) — Feb 17, 2026
>
> **How To Use Prediction Market Data Like Hedge Funds (Complete Roadmap)**
>
> I'm going to break down exactly how hedge funds use prediction market data to build trading strategies and extract alpha that retail misses. I'll also share dataset of 400m+ trades going back to 2020.
>
> Let's get straight to it.
>
> ---
>
> **The Dataset That Just Went Public**
>
> @beckerrjon released the largest publicly available prediction market dataset: 400 million+ trades from Polymarket and Kalshi going back to 2020. Complete market metadata, granular trade data, resolution outcomes, stored as Parquet files.
>
> This is tick level data. Every trade has timestamp, price, volume, taker direction. The same granularity institutional data vendors charge $100K+ annually for in traditional markets.
>
> Now it's open source. This is massive.
>
> Before I break down what hedge funds are doing with this data, let me show you how to actually get it set up. Because unlike most articles that just talk theory, I'm giving you the exact steps to access institutional grade data yourself.
>
> ---
>
> **How to Set Up the Dataset (Step by Step)**
>
> Prerequisites:
> - Python 3.9 or higher installed
> - 40GB free disk space
> - Command line access (Terminal on Mac/Linux, PowerShell on Windows)
>
> Step 1: Install uv (Dependency Manager)
> ```bash
> # On Mac/Linux
> curl -LsSf https://astral.sh/uv/install.sh | sh
> # On Windows (PowerShell)
> irm https://astral.sh/uv/install.ps1 | iex
> ```
>
> Step 2: Clone the Repository
> ```bash
> git clone https://github.com/Jon-Becker/prediction-market-analysis
> cd prediction-market-analysis
> ```
>
> Step 3: Install Dependencies
> ```bash
> uv sync
> ```
>
> This installs DuckDB, Pandas, Matplotlib and other analysis tools.
>
> Step 4: Download the Dataset
> ```bash
> make setup
> ```
>
> This downloads data.tar.zst (36GB compressed) from Cloudflare R2 and extracts it to the data/ directory. Extraction takes 5 to 30 minutes depending on your system.
>
> Step 5: Verify the Data
> ```bash
> ls data/polymarket/trades/
> ls data/kalshi/trades/
> ```
>
> You should see hundreds of Parquet files containing trade data.
>
> The data is organized like this:
> ```
> data/
> ├── polymarket/
> │   ├── markets/               # Market metadata (titles, outcomes, status)
> │   └── trades/                # Every trade (price, volume, timestamp)
> └── kalshi/
>     ├── markets/               # Same structure for Kalshi
>     └── trades/
> ```
>
> ---
>
> **Method 1: Empirical Kelly Criterion with Monte Carlo Uncertainty Quantification**
>
> The Kelly Criterion is the foundation of quantitative position sizing. Every institutional trader knows the formula:
>
> f* = (p × b - q) / b
>
> The problem with textbook Kelly: it assumes you know your edge with certainty. Reality breaks this assumption immediately.
>
> Empirical Kelly solves this by incorporating uncertainty directly into the sizing calculation.
>
> Phase 1: Historical Trade Extraction — Filter 400M trades for exact pattern matches. Phase 2: Return Distribution Construction — Build empirical (non-normal) return distributions from known outcomes. Phase 3: Monte Carlo Resampling — Generate 10,000 alternative paths by randomly reordering returns to capture path dependency. Phase 4: Drawdown Distribution Analysis — Calculate max drawdown distributions across all paths, sizing for 95th percentile not median. Phase 5: Uncertainty Adjusted Position Sizing using f_empirical = f_kelly × (1 - CV_edge).
>
> Illustrative example: Standard Kelly might suggest 20%+ sizing → after Monte Carlo uncertainty adjustment: 10-15% → conservative deployment: 8-12%. The difference between ignoring uncertainty and incorporating it is the difference between probable ruin and steady compounding.
>
> ---
>
> **Method 2: Calibration Surface Analysis Across Price and Time Dimensions**
>
> Define C(p, t) as the calibration function where p = contract price, t = time remaining. In perfectly calibrated markets, C(p, t) = p for all p and t.
>
> Analysis of 72.1 million Kalshi trades reveals:
> - At 1-cent contracts: Takers win only 0.43% of the time (implied: 1%). Mispricing: -57%
> - At 50-cent contracts: Taker mispricing: -2.65%, Maker mispricing: +2.66%
> - Takers exhibit negative excess returns at 80 of 99 price levels
>
> The institutional hypothesis on time dimension: longshot bias should be strongest far from resolution (hope-driven retail), compress mid-period (information accumulation), with potential reversal near resolution.
>
> Mispricing function: M(p, t) = C(p, t) - p/100. Enter short when M > threshold, long when M < -threshold, flat otherwise.
>
> ---
>
> **Method 3: Order Flow Decomposition and Maker Versus Taker Profitability**
>
> Every trade has a maker (posted limit order, waited) and a taker (crossed the spread, paid for immediacy).
>
> From 72.1M Kalshi trades:
> - At 1-cent contracts: Taker mispricing -57%, Maker mispricing +57%
> - Makers buying YES: +0.77% excess return
> - Makers buying NO: +1.25% excess return
> - Cohen's d ≈ 0.02 — makers don't predict better, they structure better
>
> Why takers lose: information asymmetry misperception, affirmative bias ("costly preference for affirmative, longshot outcomes"), and urgency that correlates with behavioral bias.
>
> Expected maker profit: E[Profit_maker] = spread_capture + edge_vs_takers. Risks: inventory risk, adverse selection from sophisticated takers, volume evolution effects.
>
> ---
>
> **The Institutional Edge is Not Information**
>
> 1. Risk management: Sizing for the distribution, not the point estimate
> 2. Time-varying strategies: Exploiting calibration patterns that change as resolution approaches
> 3. Structural positioning: Being the maker, not the taker
>
> None of these require better prediction. They require better process.
>
> *1,555 likes · 186 retweets · 22 replies*

[Original thread](https://x.com/RohOnChain/status/2023781142663754049)
