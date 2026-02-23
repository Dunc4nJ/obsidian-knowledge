---
created: 2026-02-21
description: The Kelly-Thorp criterion uses only probability of winning, probability of losing, and payout odds to calculate the mathematically optimal fraction of bankroll to wager in prediction markets.
source: https://x.com/phosphenq/status/2024771146411823296
type: framework
---

## Key Takeaways

The Kelly Criterion reduces bet sizing to three variables: p (win probability), q (loss probability), and b (payout odds). For a 70% edge at 6:5 odds, the formula outputs 45% of bankroll — a concrete, non-intuitive number that most traders would never arrive at by feel. This mathematical precision is exactly the kind of [[polymarket alpha compounds when traders specialize in one repeatable execution edge|repeatable execution edge]] that separates systematic traders from discretionary ones.

Full Kelly is mathematically optimal for long-run capital growth but brutally volatile in practice. The article tests Half Kelly and Quarter Kelly variants, confirming a well-known tradeoff: fractional Kelly sacrifices some theoretical growth for dramatically smoother equity curves. For prediction market contracts that expire binary (worth $1 or $0), the original Kelly formula applies almost directly, since you lose 100% of stake on a wrong prediction — unlike equities where partial losses are the norm.

The Thorp extension replaces the simple gambling model with expected return (mu), risk-free rate (r), and volatility (sigma), making it applicable beyond binary bets. However, this requires robust estimates of return and volatility, which depend on lookback window selection — an empirical choice with no universal answer. This connects to how [[mathematical infrastructure not luck extracted 40 million from Polymarket]] — the edge comes from better parameter estimation, not from the formula itself.

Combining Kelly with Monte Carlo simulation stress-tests whether a strategy survives across randomized time windows rather than just one historical backtest. The article's Cap 3 variants limit leverage to 300%, using z-score from simulation as a scaled exit signal. This is a practical concession: even with a real edge, [[hedge funds use prediction market data for risk calibration not outcome prediction|risk calibration]] matters more than maximizing theoretical returns.

The core insight for prediction market traders: if you can estimate your true probability more accurately than the market's implied probability, Kelly tells you exactly how much to bet. The hard part was never the formula — it's the probability estimation. Every [[polymarket arbitrage trading requires barrier frank-wolfe initialization and adaptive contraction|arbitrage and trading strategy]] ultimately depends on the quality of that input.

## External Resources

- [Kelly + Monte Carlo article thread by @mikita_crypto](https://x.com/mikita_crypto/status/2024492068647600546) — Full breakdown of six Kelly-Monte Carlo strategy variants applied to prediction markets
- [John Kelly's original paper](https://en.wikipedia.org/wiki/Kelly_criterion) — The foundational 1956 paper on optimal bet sizing
- [Edward O. Thorp - The Kelly Criterion in Blackjack, Sports Betting, and the Stock Market](https://www.edwardothorp.com/) — Thorp's generalization of Kelly to financial markets

## Original Content

> @phosphenq — 2026-02-20
>
> the bet size in prediction markets has already been calculated
>
> The Kelly-Thorp strategies provide the answer to the main question of all traders
>
> three criteria:
>
> p → probability of winning
> q = 1 − p → probability of losing
> b → payout odds
>
> this is all you need to determine the optimal fraction of your bankroll to bet in order to maximize capital growth in the long run
>
> example:
>
> if the probability of winning is 50% and the payout odds are 6:5
> bankroll $100 = bet ≈ $8.33
>
> combination of the Kelly criterion and Monte Carlo simulation can be successful
>
> answer found
>
> QT @mikita_crypto: Article: Kelly + Monte Carlo: The Formula for a Perfect Strategy
>
> Engagement: 311 likes | 27 retweets | 14 replies
> [Original post](https://x.com/phosphenq/status/2024771146411823296)

> [!quote]- Full Quoted Article by @mikita_crypto
> Article: Kelly + Monte Carlo: The Formula for a Perfect Strategy
>
> Have you ever looked at a contract in a prediction market, felt confident that the probability was mispriced, but had no idea how much to stake? Or spotted a market that seemed obviously wrong - yet hesitated between allocating 5% of your bankroll, 20%, or going all in?
>
> If only there were a rigorous way to determine that optimal bet size...
>
> Enter the Kelly Criterion.
>
> **The OG**
>
> In John Kelly's original paper, he derived a formula used for bet sizing in gambling. The formula depended on three factors:
>
> - p: the probability of a win,
> - q = 1-p: the probability of a loss
> - b: the odds or payout (ratio you stand to win over the amount you stand to lose).
>
> Let's try an example... What percent would the Kelly formula tell us to bet if we have a 70% chance with 6:5 odds? You have 5 seconds to figure it out. 5.4.3.2.1. 45%! So, if we have $100 bankroll the Kelly Criteria is telling us we should be betting $45 from our stack.
>
> To apply this approach in prediction markets, a small adjustment is required, but the core logic remains the same - especially for contracts where you lose 100% of your stake if your prediction is wrong. Thus, the formula is perfectly suited for binary markets: elections, court rulings, economic events, or sports outcomes, where a contract either pays out $1 or expires worthless. Below, we will compare this approach with fixed position sizing or equal-stake strategies...
>
> The picture above has 2 simulations of betting at 20%, 50%, and 75% and 4 at the Kelly Criterion amount. There is a 60% chance of a winning a coin flip. This graph is important because it shows while the Kelly Criterion may give you the optimal allocation to generate the greatest amount of wealth in the long run, it does not mean it will always be successful.
>
> **Betting the Market**
>
> The most straightforward way to adapt the Kelly Criterion to markets is to use the same core formula, but replace the standard assumption of total loss with the actual amount you are willing to risk. This allows you to calculate a revised fraction of capital that is optimal for a specific trade or contract.
>
> There is also an alternative way to apply the Kelly Criterion. It was described in detail by Edward O. Thorp in his paper The Kelly Criterion in Blackjack, Sports Betting, and the Stock Market. In that work, Thorp derives a more general formulation, which leads to the following equation:
>
> In this formulation, μ denotes the expected return, r represents the risk-free rate, and σ reflects volatility, measured as the standard deviation of returns.
>
> However, when applying Thorp's model in practice, several nuances should be considered. First, you still need robust estimates of both the expected return and the asset's volatility. These parameters depend directly on the historical lookback window you choose. There is no universally optimal timeframe - the appropriate horizon must be determined empirically within the context of your own strategy.
>
> **A Practical Guide to Using the Kelly Criterion and Monte Carlo Simulation in Prediction Markets**
>
> We will apply the Thorp-Kelly criterion to prediction market trading in six different ways to illustrate its strengths and weaknesses. In all six strategies, we will take and hold positions in prediction market contracts (e.g., YES or NO shares).
>
> Each day, we will use the Kelly criterion to determine the optimal fraction of our portfolio to allocate to contracts where we have a positive expected value based on our probability estimates relative to the market's implied probability. The remaining portion of the portfolio will be held as unallocated cash to manage risk and preserve optionality for future opportunities.
>
> At any point in time, the total value of our portfolio will be equal to the mark-to-market value of our open contract positions plus our remaining cash balance.
>
> 1. Full Kelly [we allocate exactly how much the equation tells us to]
> 2. Half Kelly [we allocate half of the specified percentage]
> 3. Quarter Kelly [we allocate a quarter of the specified percentage]
> 4. Monte Carlo Cap 3 Full Kelly [a Full Kelly, limited to a maximum leverage of 3.0 (300%), using z-score from Monte Carlo simulation as a scaled exit]
> 5. Monte Carlo Cap 3 Half Kelly [a Half Kelly, limited to a maximum leverage of 3.0 (300%), using z-score from Monte Carlo simulation as a scaled exit]
> 6. Monte Carlo Cap 3 Quarter Kelly [a Quarter Kelly, limited to a maximum leverage of 3.0 (300%), using z-score from Monte Carlo simulation as a scaled exit]
>
> Below is the probability distribution of outcomes generated by the Monte Carlo simulation.
>
> "The best way to know if a strategy will work in real life is not to test it over one long continuous timeframe, but rather to chunk up that long timeframe into smaller random samples. By testing the performance of your strategy on many smaller timeframes, you'll be able to obtain more accurate statistics of its potential future performance."
>
> **Conclusion**
>
> When you identify a strategy that appears profitable, your first priority should be to invalidate it, not confirm it. While this mindset can be psychologically difficult in the short term, it prevents overconfidence and hidden risks. In the long run, this habit is essential for preserving capital and building a resilient, profitable portfolio.
>
> P.S. The combination of the Kelly criterion and Monte Carlo simulation can be successful over certain time horizons and unsuccessful over others. I would be happy to hear your feedback, and see you in the next article!
>
> Engagement: 432 likes | 34 retweets | 17 replies
> [Original post](https://x.com/mikita_crypto/status/2024492068647600546)
