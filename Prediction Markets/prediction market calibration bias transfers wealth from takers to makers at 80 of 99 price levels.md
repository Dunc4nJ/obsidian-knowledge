---
created: 2026-02-24
description: Institutional prediction market analysis using calibration functions C(p,t) reveals systematic mispricing where takers underperform at 80 of 99 price levels, with contracts at 1 cent resolving for buyers only 0.43% of the time versus the implied 1%.
source: https://x.com/AIexey_Stark/status/2026247129715343787
type: learning
---

# Prediction market calibration bias transfers wealth from takers to makers at 80 of 99 price levels

## Key Takeaways

This tweet by @AIexey_Stark distills the calibration analysis from [[hedge funds use prediction market data for risk calibration not outcome prediction]] into a clean institutional framework built around one function: C(p, t), where p is contract price and t is time remaining.

The core finding is brutal: takers are on the wrong side of the trade at 80 out of 99 price levels. Even at 50 cents — the "fairest" price — buyers who cross the spread underperform by 2.65%, while makers on the same contracts earn +2.66%. This is not random noise; it is a persistent, measurable wealth transfer that confirms why [[polymarket alpha compounds when traders specialize in one repeatable execution edge]] — and that edge is overwhelmingly on the making side.

The extreme tail is where the bias is most exploitable: contracts at 1 cent imply 1% probability but resolve for buyers only 0.43% of the time. That is 57% of implied value evaporating — retail optimism systematically inflating low-probability contracts beyond any fundamental basis. This connects to the entropy insight in [[becoming a prediction market quant requires five phases from bayesian thinking through live deployment]] — low-price contracts have low entropy but paradoxically the highest mispricing.

The mispricing function M(p, t) = C(p, t) − p/100 formalizes the entry rules: buy NO when M exceeds a threshold (market overpriced), buy YES when M is below negative threshold (underpriced), skip when the gap is too small to clear transaction costs. The threshold itself is not fixed — it is calibrated to transaction costs and required risk-adjusted returns, moving with market conditions.

The time dimension matters as much as the price dimension. Early in a market's life, retail optimism inflates prices — this is the most reliable window. Mid-period tends to be most efficient as real data emerges and experienced participants enter. Near resolution, edge exists but requires much higher precision to capture due to adverse selection, which aligns with the VPIN withdrawal logic from [[polymarket market making requires avellaneda-stoikov reservation pricing adapted for binary settlement]].

## External Resources

- @RohOnChain, "How To Use Prediction Market Data Like Hedge Funds" — the full article this tweet synthesizes: [original thread](https://x.com/RohOnChain/status/2023781142663754049)

## Original Content

### Tweet by @AIexey_Stark (Feb 24, 2026)
Likes: 80 | Retweets: 6 | Replies: 6

> How institutions actually read prediction market bias
>
> A contract sitting at 30 cents should theoretically resolve in your favor 30% of the time. If it does, the market is efficient. If it doesn't, there's an edge somewhere.
>
> What separates institutional thinking from retail thinking is the addition of a second variable: time. Not just "is the price accurate," but "is the price accurate at this specific moment in the market's lifecycle?"
>
> Institutions formalize this through a calibration function C(p, t) where p represents the contract price and t represents time remaining until resolution. In a perfectly efficient market, C(p, t) = p at all price levels and all points in time. In reality, it doesn't.
>
> Contracts priced at 1 cent imply a 1-in-100 chance. But when you track what actually happens, buyers win less than half a percent of the time. The market says 1% — reality says 0.43%. That gap — 57% of implied value simply evaporating — isn't a rounding error. It's a persistent, measurable wealth transfer happening in plain sight.
>
> Even at 50 cents, buyers who cross the spread still underperform by over 2.65%. Makers on the same contracts earn +2.66%. Across the entire probability spectrum, takers are on the wrong side of the trade at 80 out of every 99 price levels.
>
> The mispricing function: M(p, t) = C(p, t) − p/100
>
> Entry rules:
> - Buy NO when M(p, t) > threshold → market is overpriced
> - Buy YES when M(p, t) < threshold → market is underpriced
> - Skip when |M(p, t)| < threshold → gap too small to clear transaction costs
>
> The most reliable window is early in a market's life, targeting low-probability contracts where retail optimism has inflated prices. Mid-period is most efficient. Near resolution, selectivity is everything.

*Calibration bias data visualization*
![[aiexey-343787-001.jpg]]

*Maker vs taker performance across price levels*
![[aiexey-343787-002.jpg]]

Quote tweet of @RohOnChain: [How To Use Prediction Market Data Like Hedge Funds](https://x.com/RohOnChain/status/2023781142663754049)

Source: [Original tweet](https://x.com/AIexey_Stark/status/2026247129715343787)
