---
created: 2026-02-21
description: Polymarket weather markets are systematically mispriced because retail traders use phone apps while NOAA publishes 94%-accurate 24-48h forecasts for free, creating a repeatable bot-exploitable information asymmetry.
source: https://x.com/xmayeth/status/2025232198526239171
type: learning
---

## Key Takeaways

The core edge is embarrassingly simple: NOAA publishes free temperature forecasts with 94% accuracy at 24-48 hour horizons, while Polymarket weather traders price buckets based on vibes and iPhone apps. A temperature bucket NOAA rates at 94% confidence regularly trades at 11 cents on Polymarket — a 4x return on a near-certain outcome. This is the purest [[hedge funds use prediction market data for risk calibration not outcome prediction|information asymmetry]] you can find in prediction markets.

The timing gap matters as much as the data gap. NOAA publishes at 5am, but most traders don't parse the data until 9am. That 4-hour window is where the real alpha lives — the bot that reads NOAA at 5:01am and places orders before anyone else wakes up captures the fattest spreads. This is exactly the kind of [[polymarket alpha compounds when traders specialize in one repeatable execution edge|specialization edge]] that compounds over time.

Three wallets are cited as proof of concept: automatedAItradingbot (+$72.5k), an anonymous address (+$39.3k/month at 80% win rate), and aboss (+$42.4k). All share the same fingerprint: perfect timing, zero emotional decisions, fully automated. The stack described is OpenClaw + Simmer Markets (by @TheSpartanLabs) + Telegram as command center — no code required.

The strategy has a clear expiry date. As @xmayeth notes: "give it 2-3 weeks once everyone learns about it, the rules will change." The [[kelly criterion determines optimal prediction market bet size from three inputs|Kelly criterion]] applies here — the edge is real but the window is finite, so position sizing should account for declining alpha as more bots enter. Some traders in the replies report losses, suggesting the edge may already be thinning or execution details matter more than the thread implies.

Configuration matters: entry threshold at 15% (only buy buckets priced below 15 cents), exit at 45% (sell on correction for 3x minimum), max $2 per position, scanning 6 US cities every 2 minutes. The conservative sizing prevents blowup on the inevitable bad forecasts in the remaining 6% error rate.

## External Resources

- [@LunarResearcher step-by-step guide](https://x.com/LunarResearcher/status/2025131164348932533) — Full tutorial for building a weather trading bot with OpenClaw + Simmer Markets
- [Simmer Markets by @TheSpartanLabs](https://simmer.markets) — Pre-built Polymarket trading skills including weather trader module
- [automatedAItradingbot Polymarket profile](https://polymarket.com/@automatedAItradingbot) — Example wallet: +$72.5k from weather-only trading
- [Horizon SDK weather integration](https://x.com/justfckingamble/status/2025266693505769491) — Connect weather data in two lines of code

## Original Content

> @xmayeth — 2026-02-21
>
> There's a free exploit on Polymarket that nobody is talking about.
>
> You can turn $24 into $6146. 26014% ROI - weather markets print these numbers if you know the edge.
>
> The data it used? Free. Published every day by the US government. Available to anyone.
>
> Here's what nobody on Polymarket figured out yet.
>
> NOAA predicts temperature 24-48 hours out with 94% accuracy. People on Polymarket are pricing weather markets based on their iPhone weather app. Or nothing at all.
>
> Think about that for a second. One side has supercomputer models built on decades of satellite data. The other side is guessing.
>
> The bot reads NOAA, checks Polymarket, and buys every time they disagree. Every 2 minutes. 6 cities. Runs by itself.
>
> The setup is OpenClaw + Simmer by @TheSpartanLabs + Telegram as command center.
>
> QT @LunarResearcher: Article: How Building a Weather Polymarket Bot with OpenClaw and turn 100$ → 8000$ (Step-by-Step Guide)
>
> Engagement: 311 likes (main thread replies include confirmation from traders and some reporting losses)
> [Original post](https://x.com/xmayeth/status/2025232198526239171)

> [!quote]- Thread replies (selected)
> **@voi_bet:** Weather markets are fascinating because they're pure information efficiency tests. NOAA publishes at 5am, but most traders don't parse it until 9am. That 4-hour gap is the real edge.
>
> **@xmayeth:** Yes, you added something very important to the strategy I described in my post
>
> **@0xwhrrari:** 2600 percent roi sounds crazy but whats the base liquidity per city
>
> **@xmayeth:** There's enough liquidity to make money on it. U.S. cities are the main meta for weather markets
>
> **@papa_couch:** Do you think this is really possible?
>
> **@xmayeth:** Sure, I don't see any reason this wouldn't work. But give it 2–3 weeks once everyone learns about it, the rules will change
>
> **@justfckingamble:** In Horizon SDK you can directly connect weather data in two lines of code
>
> **@_degen_dude_:** I've tried this method with no luck. I have pivoted to all prediction markets and teaching my agent some basics on odds, betting and money management and it seems to be doing a lot better.
>
> **@Gordon6Levinson:** I tried it with $100 usd, after a day, lost $100

> [!quote]- Full quoted article by @LunarResearcher: Step-by-Step Weather Bot Guide
> **How Building a Weather Polymarket Bot with OpenClaw and turn $100 → $8000**
>
> No code. No finance degree. No trading experience. Just a bot that reads weather forecasts better than the market does - and quietly prints money 24/7.
>
> **The Bot That Started It All**
>
> - automatedAItradingbot: +$72.5k only on weather trading
> - 0x594e...1C11: +$39.3k for month, 80% win rate, pure weather strategy, never sleeps
> - aboss: +$42.4k only from automated bot
>
> All three had the same fingerprint: Perfect timing. Zero emotional decisions. Fully automated.
>
> **The Information Asymmetry**
>
> Most people pricing weather markets have no idea what NOAA says. NOAA publishes hyper-accurate 24-48 hour forecasts for free. Their models are built on decades of satellite data and supercomputer simulations. Their short-range accuracy is genuinely impressive.
>
> Meanwhile, Polymarket temperature bucket markets — things like "Will NYC hit above 72°F on Saturday?" — are often priced by retail users guessing based on vibes, the weather app on their phone, or nothing at all.
>
> Example: NOAA says 94% confidence NYC will hit 74–76°F Saturday. Polymarket has that bucket priced at 11¢. A bot that catches that discrepancy, buys at 11¢, and sells when the market corrects to 45-60¢ just made a 4x return on a near-certain outcome.
>
> **The Stack**
>
> Three tools:
> - OpenClaw — free, open-source AI agent that runs on your computer
> - Simmer Markets (by @TheSpartanLabs) — pre-built trading skills for Polymarket (weather, copy trading, arbitrage)
> - Telegram — command center
>
> **Configuration**
>
> - Entry threshold: 15% (only buy buckets priced below this)
> - Exit threshold: 45% (sell when market corrects here)
> - Max position size: $2.00
> - Locations: NYC, Chicago, Seattle, Atlanta, Dallas, Miami
> - Max trades per scan: 5
> - Safeguards: Enabled
> - Trend detection: Enabled
> - Scan frequency: every 2 minutes
>
> The bot only buys a temperature bucket if it's priced below 15¢. If NOAA disagrees and gives it high confidence, the bot buys. It sells when the price corrects above 45¢ — that's a 3x minimum return per trade. It never bets more than $2 per position, keeping risk capped.
>
> Once configured, the bot starts immediately. Every 2 minutes it pulls fresh NOAA forecast data, scans all 6 cities, checks current Polymarket prices across every available temperature bucket, and buys anything where the forecast and the price don't agree.
>
> **Warning:** "The people making $24k, $65k, $84k on weather markets didn't have some secret edge - they just set this up before everyone else did. That window is still open. Not for long."
>
> Engagement: 241 likes | 20 retweets | 33 replies
> [Original post](https://x.com/LunarResearcher/status/2025131164348932533)
