---
created: 2026-02-26
description: Fractional Kelly Criterion applied to Polymarket 5-minute BTC up/down markets controls drawdowns while preserving edge-based growth
source: https://x.com/RDX_arXS/status/2026704279122169917
type: framework
---

## Key Takeaways

The core argument is that [[kelly criterion determines optimal prediction market bet size from three inputs|Kelly Criterion]] works especially well for Polymarket's 5-minute Bitcoin up/down markets because the formula forces discipline in a context designed to exploit emotion. The simplified prediction market formula `f = (p - m) / (1 - m)` where `p` is your probability estimate and `m` is market-implied probability makes the sizing calculation trivial — you can do it on a phone between rounds.

Full Kelly is dangerously aggressive in practice. Even with a genuine edge, a string of 10 losses can wipe 30-50% of your bankroll. The psychological damage from watching $1,000 drop to $590 in an hour causes most traders to abandon the system — which is worse than never using it. This connects to the broader insight in [[becoming a prediction market quant requires five phases from Bayesian thinking through live deployment]] that production systems must account for human psychology, not just math.

Fractional Kelly at k=0.25 to k=0.5 is the practical answer. At quarter-Kelly, the same trade that full Kelly sizes at 8.2% becomes 2%. Five consecutive losses take your bank from $1,000 to $900 instead of $590. Growth is slower but the odds of emotional breakdown and system violations drop dramatically. In high-frequency 5-minute markets, there's only repetition and survival.

The weakest link is always your probability estimate `p`. The market says 51%, you say 55% — but why? Without charts, volume analysis, or some quantifiable signal, you're just adding noise. Polymarket's 1.56% taker fee makes this worse: small perceived edges get eaten by fees. The practical threshold is a 2-5% edge over market pricing before a trade is worth taking.

The step-by-step execution loop is mechanical: check market → estimate p from price action/RSI → run formula → bet only if fractional f exceeds 2% → update bankroll → stop if down 20% for the day. No discretion, no feel. The system is the edge.

## External Resources

- [Original Kelly for BTC markets article by @Gustafssonkotte](https://x.com/Gustafssonkotte/status/2026559436093870228) — full walkthrough with worked examples of Kelly sizing for Polymarket 5-minute Bitcoin contracts

## Original Content

> @RDX_arXS — 2026-02-25
>
> DISCIPLINE OVER EMOTION
>
> I generally agree with the take on using Kelly for 5-minute BTC markets on Polymarket. Its one of the few tools that actually brings structure.
>
> The real strength of Kelly is that it limits stupidity and emotions. When the market prices "up" at 0.51 and you think its closer to 0.55, the formula helps answer: how confident are we?
>
> Small edge → small position. No edge → no trade.
>
> But the key variable is your p. Your probability estimate is the weakest link in the entire setup.
>
> Its also important to acknowledge how aggressive full Kelly really is. Even with a real edge, you can run into uncomfortable losing streaks, and the drawdowns will be significant. Not everyone is psychologically built to handle that.
>
> That is why fractional Kelly makes far more sense in practice. Growth is slower, but the odds of emotional breakdown and system violations drop dramatically.
>
> In 5-minute markets this matters even more. There is only repetition and survival.
>
> Engagement: 51 likes | 3 retweets | 10 replies
> [Original post](https://x.com/RDX_arXS/status/2026704279122169917)

> [!quote]- Source Article: Using the Kelly Criterion for Bitcoin Up or Down Markets on Polymarket (@Gustafssonkotte)
>
> The basic Kelly formula for prediction markets: `f = (p - m) / (1 - m)` where f = fraction of bankroll, p = your probability estimate, m = market's implied probability.
>
> **Example 1 (Good Edge):** Market "Up" at 0.42, you estimate 0.58. Kelly says 27.6%. With $1,000, bet $276. Win payout ~$657, profit $381.
>
> **Example 2 (Small Edge):** "Up" at 0.51, you estimate 0.55. Kelly says 8.2%. Bet $82 on $1,000 bank. Win pays $161, profit ~$79.
>
> **Why Kelly works:** Adjusts to edge size automatically. Small edges = small bets. Large edges = controlled risk. Over dozens of 5-minute rounds, bankroll grows faster than fixed sizing. Emotion-free.
>
> **Downsides:** Hardest part is nailing your p estimate. Full Kelly is aggressive — 10 losses can wipe 30-50% of bank. Polymarket's 1.56% fee eats bad estimates. Must recalculate after every trade.
>
> **Fractional Kelly:** Multiply full f by 0.25 or 0.5. Example 2 at quarter-Kelly: 8.2% becomes 2%. Five losses = down $100 (vs $410 at full Kelly). Much smoother, still grows.
>
> **Step by step:** Check live market → estimate p from price action/RSI → run formula → bet if fractional f > 2% → update bankroll → stop if down 20% for the day.
>
> Engagement: 66 likes | 5 retweets | 13 replies
> [Original article](https://x.com/Gustafssonkotte/status/2026559436093870228)
