---
created: 2026-02-17
description: A 742-trade experiment across five server regions shows Ireland and Stockholm achieve 250-280ms Polymarket CLOB latency while Seoul trails at 550ms+, making region selection a core edge in 5-minute up/down markets.
source: https://x.com/probabilitygod/status/2023787704857637032
type: framework
---

# Polymarket 5-minute market bot latency depends on server region with Ireland and Stockholm 294ms faster than Seoul

## Key Takeaways

The experiment deployed identical bots across five regions (Ireland, Stockholm, Mumbai, Tokyo, Seoul) with ~150 trades each, holding strategy, sizing, and logic constant. The only variable was server location. Ireland and Stockholm clustered at 260-280ms mean latency while Seoul exceeded 550ms, producing a 294ms gap between fastest and slowest. This reinforces the thesis in [[polymarket alpha compounds when traders specialize in one repeatable execution edge]] — here the "one edge" is literally geographic proximity to the matching engine.

Median latency matters more than mean in short-duration contracts. Stockholm posted the tightest median (249ms) despite Ireland having the lowest mean, because Ireland benefited from a few ultra-fast outlier fills that skewed the average down. Tail risk separates regions even further: Seoul spiked to 2149ms while Ireland's worst case was 1134ms. In a 5-minute contract where entries happen in the final 30-60 seconds, a single two-second spike can erase an entire position's edge. This connects to the variance and execution quality arguments in [[attention markets shift arbitrage from binary constraints to latency correlation and manipulation volatility]], where continuous-time execution dominates static pricing logic.

The ECDF analysis provides the sharpest view: under 300ms (the threshold that determines queue position in compressed orderbooks), Ireland and Stockholm clearly separate from the pack. Queue position determines whether you get filled or watch the book move without you, and over hundreds of rotations that compounds directly into realized PnL. This is the microstructure argument that [[polymarket arbitrage trading requires barrier frank-wolfe initialization and adaptive contraction]] makes from a different angle — implementation details dominate theoretical edge.

Reliability was not the differentiator. All five regions executed successfully with tightly clustered trade counts (132-147). BUY and SELL latencies mirrored each other across all regions, confirming the pattern is geographic routing rather than directional book asymmetry. The practical ranking is clear: Ireland/Stockholm at the top, Mumbai in the middle, Tokyo next, Seoul last. The author notes that with the Polymarket US client now live, a follow-up US-region comparison is planned.

The broader implication is that 5-minute markets are drifting into microstructure territory where execution infrastructure becomes half the trade. Most traders optimize direction while ignoring the stack that determines whether they capture the move. As the [[Polymarket US retail API launches with 23 REST and 2 WebSocket endpoints for regulated trading]] ecosystem expands, latency optimization becomes table stakes for serious participants, not an afterthought.

## External Resources

- [Polymarket CLOB Client](https://github.com/Polymarket/clob-client) — the createAndPostMarketOrder API used for all 742 executions in the test

## Original Content

> @probabilitygod — 2026-02-17
>
> Article: I Executed 742 Trades to Find the Best Region for deploying Polymarket 5-Minute up/down market bots
>
> Polymarket's 5-minute Up/Down markets went live less than a week ago, and they already behave like a latency game. As expiry approaches, liquidity compresses, spreads tighten, and a single aggressive order can move the contract several cents instantly. In that environment, execution speed directly affects fills. A few hundred milliseconds determines whether you're positioned or chasing. So instead of theorizing about edge, I measured it.
>
> I deployed identical systematic trading bots across five regions (Ireland, Stockholm, Mumbai, Tokyo, and Seoul) and executed roughly 150 trades per region using the CLOB client's createAndPostMarketOrder. The strategy employed basic directional signals derived from microstructure momentum (order book imbalance and short-term price pressure) to ensure each trade expressed a genuine market view. In total: 742 successful BUY and SELL executions. No retries. No failed transactions. Same strategy, same sizing, same logic. The only variable was where the machine lived.
>
> This article focuses on non-US infrastructure. Now that the Polymarket US client is live, I'll run the same experiment across US-based servers and publish a direct comparison.
>
> The structural gap: Ireland and Stockholm cluster around ~260-280ms mean latency, Mumbai in the low 400s, Tokyo in the high 400s, and Seoul above 550ms. The gap between fastest and slowest is roughly 294ms.
>
> Stockholm's median came in at 249ms vs Ireland's 251ms. Seoul hit 2149ms at worst; Ireland topped out at 1134ms. Under 300ms, Ireland and Stockholm clearly separate from the rest in ECDF analysis.
>
> Execution counts were tightly clustered: Ireland 144, Stockholm 147, Mumbai 132, Tokyo 144, Seoul 140. BUY and SELL latencies mirror each other almost perfectly across all regions.
>
> Practical ranking for 5m markets: Ireland/Stockholm at the top, Mumbai middle, Tokyo follows, Seoul trails. Latency does not guarantee profit, but ignoring it quietly transfers edge to whoever cared enough to measure it. Infrastructure is half the trade.
>
> Engagement: 83 likes | 7 retweets | 11 replies
> [Original post](https://x.com/probabilitygod/status/2023787704857637032)
