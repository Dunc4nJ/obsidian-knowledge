---
created: 2026-02-22
description: 15 market research prompts for Claude that cover sentiment analysis, SEC filings, macro correlation, options Greeks, backtesting, Fed analysis, stress testing, insider trading, revenue quality, crypto liquidity, risk psychology, sector rotation, earnings prediction, and exit strategy design.
source: https://x.com/AIPandaX/status/2025574102464069886
type: framework
---

## Key Takeaways

This is a collection of **15 structured prompts** for financial analysis using LLMs, organized by domain. While the framing is hyperbolic ("institutional-level alpha for free"), several of these map directly to analytical workflows that [[plutus|Plutus]] could formalize — particularly the 10-K comparison, insider trading decoder, revenue quality audit, and sector rotation prompts. The prompts work best when paired with actual data feeds rather than relying on the model's training data alone, as noted in the [[simple financial agents outperform complex ones when tool routing is tight|Dexter architecture]] approach of feeding raw structured data to the LLM.

The prompts span a useful taxonomy of market research tasks: **sentiment** (1, 12), **fundamental** (2, 9, 10, 14), **macro** (3, 7, 13), **technical** (4, 6, 15), **derivatives** (5, 8, 11). This categorization itself is worth borrowing for organizing analytical workflows.

## The 15 Prompts

### 1. The "Inverse Retail" Sentiment Scraper
> "Act as a Contrarian Analyst. Analyze the top 20 trending tickers on WallStreetBets. Cross-reference them with 'Dark Pool' institutional sell orders over $5M. Identify which 'meme stock' is currently a massive bull trap based on liquidity exhaustion."

### 2. The 10-K "BS" Detector
> "Scan [Company]'s latest 10-K filing. Compare the 'Risk Factors' section to last year's. Highlight any new, specific language regarding 'liquidity constraints' or 'regulatory headwinds' that the CEO glossed over in the earnings call."

### 3. The Macro Correlation Matrix
> "Act as a Global Macro Strategist. Calculate the correlation between the Japanese Yen (JPY) carry trade and Nasdaq-100 volatility. Predict the 'tipping point' price for USD/JPY that triggers a forced tech sell-off across institutional desks."

### 4. The Order Block Hunter
> "Analyze the provided ${BTC} 4H candle data. Identify 'Institutional Order Blocks' where price saw a violent rejection with high volume. Mark these as 'High-Probability' entry zones for a mean reversion trade and suggest a 3:1 RR stop-loss."

### 5. The Options Greek Translator
> "I am looking at ${NVDA} $140 Calls expiring in 48 hours. Explain the 'Vanna' and 'Charm' flows for this strike. How will a 2% move in the underlying stock affect the Delta hedging requirements for the Market Makers? Explain like I'm a Quant."

### 6. The Quantitative Backtester
> "Write a Pine Script (TradingView) code for a 'Pairs Trading' strategy between ${KO} and ${PEP}. Use a 2-standard deviation Z-score for entry. Include a logic that halts the strategy if the correlation coefficient drops below 0.7."

### 7. The Fed Whisperer
> "Analyze the latest FOMC minutes. Rank the voting members from 'Most Hawkish' to 'Most Dovish.' Based on their language, what is the implied probability of a 50bps hike versus what the CME FedWatch tool is currently pricing in?"

### 8. The "Black Swan" Stress Test
> "My portfolio is 60% Tech, 20% Crypto, 20% Gold. Simulate a 'Geopolitical Escalation' scenario in the Middle East. Which of my assets will see the highest 'drawdown' and what is the optimal hedge using Out-of-the-Money Put Options?"

### 9. The Insider Trading Decoder
> "Review the Form 4 filings for [Ticker] from the last 90 days. Distinguish between 'Automated Sell Programs' and 'Open Market Purchases.' Is the C-Suite putting their own skin in the game, or are they quietly exiting before earnings?"

### 10. The Revenue Quality Audit
> "Look at [Company]'s Balance Sheet. Calculate the 'Days Sales Outstanding' (DSO). If DSO is rising while Revenue is flat, explain why this suggests the company is 'stuffing the channel' to artificially beat earnings expectations."

### 11. The Crypto Liquidity Map
> "Identify the 'Liquidation Clusters' for ETH/USDT on Binance. At what price point will a 'Short Squeeze' become parabolic due to forced liquidations? Give me the exact price levels where the 'Stop-Loss' hunt is likely to end."

### 12. The Psychological Circuit Breaker
> "I am currently down 8% on a trade and I want to 'double down' to break even. Act as a cold, calculating Risk Manager. Remind me of the 'Gambler's Ruin' theory and provide a mathematical reason to cut the loss now to protect my longevity."

### 13. The Sector Rotation Radar
> "Analyze the 'Relative Strength' of the 11 S&P 500 sectors over the last 3 months. Which sector is transitioning from 'Lagging' to 'Leading' on the RRG (Relative Rotation Graph)? List 3 undervalued stocks with a low PEG ratio in that sector."

### 14. The Earnings "Whisper" Predictor
> "Compare [Ticker]'s historical 'Earnings Per Share' (EPS) beats to its subsequent 3-day price move. If the 'Whisper Number' is 10% higher than the Consensus, what is the statistical probability of a 'Sell the News' event regardless of the beat?"

### 15. The Exit Strategy Architect
> "I am long ${TSLA} from $180. The current price is $250. Design a 'Tiered Exit Plan' using trailing stops and Fibonacci Extension levels. My goal is to lock in 70% of profits while leaving a 'runner' for a potential parabolic breakout."

## External Resources

- [Thread source](https://x.com/AIPandaX/status/2025574102464069886) — original Twitter thread by @AIPandaX

## Original Content

> [!quote]- Thread by @AIPandaX (AI Panda, Feb 22, 2026) — 571 likes, 68 RTs
> 
> "Wallstreet is so cooked.. I spent 100+ hours stress-testing the new Claude Opus 4.6 models on live market data. Here are 15 insane prompts that give you institutional-level Alpha for free."
> 
> "The tools have changed, but the goal is the same: Protect your capital. The 'Pros' aren't smarter than you anymore, they just have better prompts. Now, you do too."
> 
> Source: https://x.com/AIPandaX/status/2025574102464069886
