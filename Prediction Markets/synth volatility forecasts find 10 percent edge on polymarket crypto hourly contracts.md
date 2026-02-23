---
created: 2026-02-21
description: SynthData's 24-hour crypto volatility forecasts identify 10%+ probability mispricings on Polymarket hourly up/down contracts, enabling automated Kelly-sized trading via OpenClaw.
source: https://x.com/SynthdataCo/status/2021658564109234501
type: learning
---

## Key Takeaways

The strategy targets Polymarket's hourly up/down contracts on crypto assets — binary bets on whether BTC/ETH/SOL will be higher or lower at the end of the hour. With 20 minutes remaining, many contracts trade at high probabilities (85 cents) but haven't fully converged. The question is whether an 85-cent contract is actually worth 92 cents — and SynthData's probability estimates regularly show 10%+ divergence from market prices. This is a different flavor of the same [[weather markets on polymarket print money because most traders ignore NOAA forecasts|information asymmetry pattern]] seen in weather markets: superior probabilistic data vs. retail guessing.

SynthData provides 24-hour volatility forecasts for crypto assets, generating probability distributions over outcomes in 5-minute intervals, refreshed every hour. The edge comes from comparing Synth's probability estimate against the current Polymarket contract price — anything where Synth exceeds market price by a meaningful threshold is a signal. Part of the edge may be a risk-premium effect: traders unwilling to risk 90 cents to make 10 cents even when slightly favorable, leaving free money on the table.

The article explicitly uses [[kelly criterion determines optimal prediction market bet size from three inputs|Kelly sizing]] based on the calculated edge. If Synth says 92% and the market says 85%, Kelly determines what fraction of bankroll to allocate. This is the Kelly criterion applied in the wild — not as theory but as live trade sizing on real-money prediction markets.

The thesis-to-production pipeline took only a few hours: give an OpenClaw agent a Synth API key, the Synth skill from ClawHub, describe the trading logic, and let it execute. Whether the strategy holds up over a meaningful sample is explicitly flagged as an open question. Thread replies are mixed — some excited, one user reports API failures (HTTP 500s), another notes Polymarket geo-restrictions (Michigan waitlist at 887k), and one user flags the ClawHub skill link as broken. The speed of deployment is the real story, not the guaranteed profitability.

The late-hour convergence window (trading with 20 minutes left) is a deliberate design choice to reduce trade frequency and thus costs. This is [[polymarket alpha compounds when traders specialize in one repeatable execution edge|edge specialization]] — picking one narrow time window where the signal-to-noise ratio is highest rather than trading every contract all day.

## External Resources

- [SynthData API dashboard](https://dashboard.synthdata.co/) — Sign up for crypto volatility forecasts and probability estimates
- [Synth OpenClaw skill on ClawHub](https://clawhub.ai/emsin44/synth-data) — Pre-built skill for integrating Synth forecasts into OpenClaw agents (reported broken by some users)
- [SynthData docs](https://docs.synthdata.co/) — API documentation for volatility forecast endpoints

## Original Content

> @SynthdataCo — 2026-02-11
>
> Article: Launch a Polymarket Trading Bot Using Synth and Openclaw in Under an Hour
>
> It took a few hours to go from a trading thesis to a live bot placing real-money bets on Polymarket. We gave an AI agent a Synth API key, the Synth skill and a brief overview of the strategy we wanted, and it started finding edges via the Synth forecasts and executing.
>
> Whether a simple strategy like this holds up over a meaningful sample is an open question, but the speed in which we were able to get an idea into production for testing, is a major benefit.
>
> Polymarket offers hourly up/down contracts on crypto assets - binary bets on whether a market will be higher or lower at the end of the hour. These are essentially volatility bets, which is why Synth matters here.
>
> With 20 minutes left, many of these contracts are often trading at high probabilities, but haven't fully converged to one side. The remaining upside is small (you're buying at 85 cents for a $1 payout). I chose this window because it meant I would be trading less, so incurring less costs.
>
> The question is whether you can identify which 85-cent contracts are actually worth 92 cents. I got the Openclaw bot to check the Synth probabilities against Polymarket and often found over 10% edge.
>
> Synth provides 24-hour volatility forecasts for crypto assets, generating probability distributions over outcomes in 5-minute intervals, with forecasts refreshed every hour.
>
> A small portion of the edge may come from a risk-premium effect. Because these contracts are short-dated and the remaining upside is often limited, some participants may be unwilling to risk, for example, 90 cents to make 10 cents, even when the trade is slightly favorable. However, this is not the main source of returns. The strategy is driven primarily by Synth's probabilistic forecasts, which systematically identify when market prices diverge from estimated probabilities.
>
> Continuously compare SynthData's probability estimate to the current Polymarket contract price. Anything where SynthData's probability exceeds the market price by a meaningful threshold is a signal.
>
> We chose to use Kelly sizing based on the edge. If SynthData says 92% and the market says 85%, Kelly criterion determines what fraction of the bankroll to allocate. You could just go for a fixed $ amount or % of bankroll if it's easier.
>
> If you want to try something similar, you'll need a Synth API key for volatility forecasts and probability estimates, and an Openclaw agent.
>
> Engagement: 331k+ views
> [Original post](https://x.com/SynthdataCo/status/2021658564109234501)

> [!quote]- Thread replies (selected)
> **@ledger_eth:** Operator move: run this like a tiny trade desk—thesis doc → data audit → $/day cap + kill switch (e.g., -$50 or 3 bad fills). The edge isn't the prompt; it's the scorecard + postmortem loop.
>
> **@brandontan:** skill flagged as "cautionary"
>
> **@Steve_too:** I get the following after signing up for PRO subscription: BTC: timeout, ETH: HTTP 500, SOL: HTTP 500. So key rotation worked, but it did not fix it. This strongly points to a Synth API/backend issue.
>
> **@SpoogemanGhost:** I just tried this but got fucked because Polymarket is not available in parts of America without going on a waitlist. I am number 887,352 on the wait list!
>
> **@BisnassNoneya:** I did this for weather and found the edge is well below 8%.
>
> **@bittybitbit86:** Yeh those api prices are highway robbery
>
> **@Crypt0Bizzi:** Using ai to predict short term $BTC moves on Polymarket feels like the most 2025 way to either get rich or lose everything
