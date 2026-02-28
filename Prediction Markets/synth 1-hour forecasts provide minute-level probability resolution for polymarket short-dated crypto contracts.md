---
created: 2026-03-01
description: Synthdata's new 1-hour forecast endpoint returns minute-by-minute percentile distributions for BTC, ETH, and SOL, giving traders 61 timesteps of probability data to exploit mispricing on Polymarket's 15-minute and hourly crypto contracts.
source: https://x.com/SynthdataCo/status/2027483844027552098
type: learning
---

## Key Takeaways

The core product difference between Synth's 24-hour and 1-hour forecasts is granularity within the contract window, not band width at expiry. At 60 minutes both endpoints agree on roughly the same band width (~$1,037 vs ~$1,092), but the 1-hour endpoint gives 61 timesteps versus only 12 from the 24-hour product. This means a bot tracking how probability evolves at minute 20, 30, 40 has 20 data points instead of 4 — a meaningful edge for dynamic position management. This directly extends the analysis in [[synth volatility forecasts find 10 percent edge on polymarket crypto hourly contracts]] by providing the infrastructure to actually exploit those edges at higher resolution.

The 1-hour forecast is not just a zoomed-in version of the 24-hour one. Different time horizons reward different mining approaches on Bittensor's subnet, so the meta-forecasts at 1 hour and 24 hours can actively disagree — and those disagreements carry tradable information. This is a practical example of how [[prediction markets are the purest test of quantitative finance because every position resolves to truth]] plays out: you can construct multi-horizon signals from the same data pipeline.

For 15-minute contracts specifically, the upgrade is dramatic: from 3 data points (minute 5, 10, 15 via the 24-hour endpoint) to a probability estimate at every minute of the contract's life. Combined with [[fractional kelly turns 5-minute polymarket bitcoin markets from gambling into a system]], the percentile spacing data could be used to dynamically size positions based on tail risk estimates rather than static kelly fractions.

The API also exposes ready-made comparison endpoints (`polymarket/up-down/15min` and `polymarket/up-down/hourly`) that return Synth's probability alongside Polymarket's pricing, making edge detection trivial. At the time of writing, the model showed BTC at 18% chance of finishing up on the hourly contract while Polymarket priced it at 14.5% — a 3.5 percentage point gap.

Synth has paid out over $2.8M to Bittensor miners, creating real economic incentives for forecast quality. The competitive mining structure means the meta-forecast improves as miners optimize for the specific time horizon being scored, unlike traditional ensemble models where all components target the same objective.

## External Resources

- [Synth Dashboard - 1H Insights](https://dashboard.synthdata.co/insights/1h/polymarket/) — Live view of 1-hour forecast vs Polymarket pricing
- [Synth API Login](https://dashboard.synthdata.co/login/) — API key signup for the prediction-percentiles endpoint

## Original Content

> @SynthdataCo — 2026-02-27
>
> Article: Unlocking Minute-Level Edge with Synth's 1H Forecast
>
> Polymarket's 15-minute and hourly crypto contracts have been growing fast. Short-dated contracts are binary, so either you get paid $1 or $0. The edge comes from having a better estimate of the probability than the market price implies.
>
> Building forecasts at those timeframes is different from forecasting over 24 hours, and the model needs to output predictions at minute-level resolution to be useful. That's significant and complex work. Now our users can access it with a single API call, or at dashboard.synthdata.co/insights/1h/polymarket/.
>
> Miners on Bittensor submit competing price prediction models, scored on accuracy. Synth has paid out over $2.8M to miners so far. The top-performing models are combined into a meta-forecast and served as an API: minute-by-minute probability distributions for BTC, ETH, and SOL, updated every 5 minutes. As a live example, the forecast currently puts BTC's probability of finishing up on the hourly contract at 18%. Polymarket is pricing it at 14.5%.
>
> Synth's 24-hour forecast returns a price distribution at 5-minute intervals. That works well for daily contracts, but for 15-minute markets it gives you exactly three data points: minute 5, minute 10, minute 15. The band width is reasonable (about $517 at the 15-minute mark right now). But between those checkpoints, the only thing a bot has to update on is raw price.
>
> What the 1-hour endpoint changes
>
> The 1-hour forecast runs a 1,000-path simulation where miners are scored on 1-hour accuracy rather than 24-hour accuracy. Different time horizons reward different approaches, so the meta-forecast at 1 hour isn't just a zoomed-in version of the 24-hour one. The 1-hour endpoint returns a percentile distribution at every minute from 0 to 60, so 61 timesteps.
>
> For 15-minute contracts, that's a probability estimate at every minute of the contract's life.
>
> Here's what the distribution looks like right now for BTC at $66,013:
>
> Minute  |  5th pctile  |  Median      |  95th pctile  |  90% band
>
> 1    |  $65,942     |  $66,012     |  $66,087      |  $144
>
> 5    |  $65,859     |  $66,008     |  $66,162      |  $303
>
> 10    |  $65,797     |  $66,003     |  $66,217      |  $419
>
> 15    |  $65,746     |  $65,997     |  $66,257      |  $511
>
> 30    |  $65,625     |  $65,986     |  $66,359      |  $734
>
> 60    |  $65,445     |  $65,960     |  $66,482      |  $1,037
>
> The median drifts slightly below current price at every timestep. The model puts the probability of "up" at 46% for 15 minutes and 43% for 60 minutes..
>
> On the live Polymarket hourly contract, Synth says 18% chance of up, Polymarket is pricing 14.5%. That's a 3.5 percentage point gap between the model and the market.
>
> Ways to use it
>
> Read the percentile distribution at the contract's resolution timestep (timestep 15 for a 15-minute contract, timestep 60 for hourly), derive a probability, compare it to the market price. The polymarket/up-down/hourly endpoint does this comparison for you on hourly contracts, and polymarket/up-down/15min does it for 15-minute contracts, returning Synth's probability and Polymarket's pricing side by side.
>
> The full distribution across all 61 timesteps also describes the expected path of the price, not just where it ends up. A bot could track how the distribution shifts as the contract gets closer to expiry. An agent framework could use the evolving shape to reason about confidence.
>
> There are a lot of possible implementations here. You could combine both horizons, using the 1-hour forecast for near-term resolution and the 24-hour for broader context. The two forecasts are scored on different time horizons so they can disagree, and those disagreements carry information. You could use the band widths to size positions, or the percentile spacing to estimate tail risk.
>
> For hourly contracts
>
> The band width at 60 minutes is similar between the two endpoints: about $1,037 from the 1h forecast vs $1,092 from the 24h. They largely agree on how much BTC can move in an hour.
>
> Where the 1-hour forecast helps is granularity within the hour. The 24-hour forecast gives readings every 5 minutes. The 1-hour forecast gives them every minute. If you're tracking how a probability is evolving at minute 20, 30, 40, that's the difference between 4 data points and 20.
>
> The bands are similar but the miners are competing on different time horizons, and we think that matters for probability estimates even when the band widths converge.
>
> Getting started
>
> 1-hour forecast (61 timesteps, minute-by-minute)
>
> curl "https://api.synthdata.co/insights/prediction-percentiles?asset=BTC&horizon=1h" \
> -H "Authorization: Apikey YOUR_API_KEY"
>
> 24-hour forecast (289 timesteps, 5-minute intervals)
>
> curl "https://api.synthdata.co/insights/prediction-percentiles?asset=BTC" \
> -H "Authorization: Apikey YOUR_API_KEY"
>
> Polymarket 15-minute up/down comparison
>
> curl "https://api.synthdata.co/insights/polymarket/up-down/15min?asset=BTC" \
> -H "Authorization: Apikey YOUR_API_KEY"
>
> Polymarket hourly up/down comparison
>
> curl "https://api.synthdata.co/insights/polymarket/up-down/hourly?asset=BTC" \
> -H "Authorization: Apikey YOUR_API_KEY"
>
> Same API key, same response format as before. The 1-hour endpoint adds &horizon=1h. Response includes 9 percentile bands (0.5th through 99.5th) at each timestep.
>
> Sign in to start: https://dashboard.synthdata.co/login/
>
> Engagement: 31 likes | 1 retweets | 2 replies
> [Original post](https://x.com/SynthdataCo/status/2027483844027552098)
