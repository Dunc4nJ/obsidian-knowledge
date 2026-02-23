---
created: 2026-02-22
description: Polymarket silently removed the 500ms taker delay on Feb 18 2026 and added dynamic taker fees up to 1.56%, making maker-side liquidity provision with zero fees and USDC rebates the only profitable bot strategy.
source: https://x.com/k1rallik/status/2025584761473773878
type: learning
---

## Key Takeaways

Three changes flipped Polymarket's bot meta entirely: the 500ms taker delay was removed (Feb 18), dynamic taker fees hit crypto markets (max ~1.56% at 50% probability via formula `fee = C × 0.25 × (p × (1-p))²`), and maker rebates now pay daily USDC funded by taker fees. The old arb strategy — the bot that made $515K/month exploiting Binance-to-Polymarket price lag — is dead because the fee alone exceeds the arbitrage margin. This is a structural regime change, not a tweak.

The new winning strategy is being a [[polymarket arbitrage trading requires barrier frank-wolfe initialization and adaptive contraction|liquidity provider]], not a taker. Makers pay zero fees, earn rebates, and with the 500ms delay gone, their quotes get filled faster. Top bots now profit from rebates alone without even needing directional edge. As one reply notes: "you're basically getting paid to stand in the middle and hold the door open." This connects to [[mathematical infrastructure not luck extracted 40 million from Polymarket|infrastructure as the moat]] — sub-100ms cancel/replace loops on a colocated VPS are the new table stakes.

For 5-minute BTC markets specifically: at T-10 seconds before window close, BTC direction is ~85% determined but Polymarket odds haven't fully priced it in. Post a maker order on the winning side at 90-95 cents, collect $0.05-0.10/share profit on resolution with zero fees plus rebates. The edge is pricing BTC direction faster than other makers. This is [[polymarket 5-minute market bot latency depends on server region with ireland and stockholm 294ms faster than seoul|latency-dependent]] — home wifi at 150ms+ is dead, you need <5ms on a colocated VPS.

Technical requirements for a 2026-compliant bot: WebSocket (not REST), `feeRateBps` in every signed order (missing it = rejected), cancel/replace loop under 100ms, quote BOTH sides (YES + NO) for rebates. The official Python SDK (`py-clob-client`) works but Rust options are faster: `polyfill-rs` (zero-alloc, SIMD JSON, 21% faster), `polymarket-client-sdk`, and `polymarket-hft`.

Critical thread reply from @PolyIntelHub: without the 500ms cancel window, makers have to price adverse selection upfront, which means spreads widen and thin books get thinner. The risk is that 5-min crypto markets hollow out as passive LPs realize rebates don't cover getting picked off by faster bots. This is the counter-thesis worth monitoring.

## External Resources

- [@_dominatos full article](https://x.com/_dominatos/status/2024871493809680410) — Complete technical guide to building a post-Feb-18 Polymarket bot (1.8k likes)
- [py-clob-client](https://pypi.org/project/py-clob-client/) — Official Polymarket Python SDK
- [polyfill-rs](https://github.com/polyfill-rs) — Zero-alloc Rust client with SIMD JSON parsing
- [polymarket-hft](https://github.com/polymarket-hft) — Full HFT framework with CLOB + WebSocket
- [PolyBackTest](https://x.com/polybacktest) — Backtesting platform with 1+ month of historical Polymarket data

## Original Content

> @k1rallik — 2026-02-22
>
> Feb 18 changed Polymarket FOREVER
>
> Here's the full breakdown of what changed, why it matters, and how to build a bot that actually works in 2026.
>
> 500ms taker delay: GONE (Feb 18). Taker orders execute instantly now. Makers have zero time to cancel stale quotes.
>
> Dynamic taker fees on 5-min & 15-min crypto markets. Max fee: ~1.56% at 50% probability.
>
> THE NEW META: Stop being a taker. Start being a maker. Makers → ZERO fees + daily USDC rebates. Takers → need >1.56% edge just to break even. Top bots in 2026 profit from rebates alone.
>
> WHAT YOUR BOT NEEDS NOW: WebSocket not REST. feeRateBps in every signed order. Cancel/replace loop under 100ms on a VPS. Quote BOTH sides (YES + NO) for rebates.
>
> The bots that win aren't the fastest takers. They're the best liquidity providers.
>
> QT @_dominatos: Article: How to build a Polymarket bot (after new rules edition)
>
> [Original post](https://x.com/k1rallik/status/2025584761473773878)

> [!quote]- Thread replies (selected)
> **@0xhashlol:** the maker rebate flip is the real play here. most people still chasing oracle lag when the actual edge is in providing liquidity. sub-100ms quote refresh on a VPS is the new moat
>
> **@MykytaHaida:** Profiting from rebates alone without even needing edge on direction is wild. You're basically getting paid to stand in the middle and hold the door open
>
> **@PolyIntelHub:** Without the 500ms cancel window makers have to price adverse selection upfront. Spreads widen, thin books get thinner. I'd watch whether 5-min crypto markets hollow out as passive LPs realize rebates don't cover getting picked off by faster bots.
>
> **@PolyCopy_trade:** post-delay world is exactly why we built polycopy at the mempool layer instead of relying on the 500ms window. now that it's gone, copy traders who were using the delay as a crutch are dead — but if your infra reads txs before they confirm, nothing changed
>
> **@k1rallik:** Makers who adapt in the next 2 weeks will own the book. Everyone else exits
>
> **@k1rallik:** Most people read "maker" and think slow. Sub-100ms flips that assumption entirely

> [!quote]- Full quoted article by @_dominatos: How to build a Polymarket bot (after new rules edition)
> 2 days ago Polymarket removed the 500ms taker price delay on crypto markets. No announcement. No warning. Half the bots on the platform broke overnight.
>
> But it also opened up the biggest opportunity for new bots since Polymarket launched.
>
> **What changed**
>
> Three things happened in the last 2 months:
>
> 1. The 500ms taker delay was removed (Feb 18, 2026). Every taker order used to wait 500ms before executing. Market makers relied on this buffer to cancel stale quotes — it was basically free insurance. Now taker orders execute instantly. There's no time to cancel.
>
> 2. Dynamic taker fees on crypto markets (Jan 2026). 15-minute and 5-minute crypto markets now have taker fees. The formula: fee = C × 0.25 × (p × (1-p))². Max fee: ~1.56% at 50% probability. Drops to nearly zero at the extremes.
>
> Remember the bot that made $515K in one month with a 99% win rate just exploiting price feed lag between Binance and Polymarket? That strategy is dead. The fee alone exceeds the arbitrage margin.
>
> **The new meta**
>
> Be a maker, not a taker. Makers pay ZERO fees. Makers earn daily USDC rebates (funded by taker fees). With 500ms delay gone, maker quotes get filled faster. Top bots now profit from rebates alone, not even from the spread.
>
> If you're still building a taker bot, you're fighting the fee curve. At 50% probability you need >1.56% edge just to break even.
>
> **How to actually build this**
>
> 1. WebSocket, not REST. REST polling is dead. By the time your HTTP request round-trips, the opportunity is gone.
>
> 2. Fee-aware order signing. You MUST include feeRateBps in your signed order payload now. If you miss this field, your orders get rejected on fee-enabled markets.
>
> 3. Fast cancel/replace loop. Without the 500ms buffer, if your cancel loop takes >200ms, you will get adversely selected. Someone will take your stale quote before you can update it.
>
> **Setting it up**
>
> 1. Get your private key (same key you use to log into Polymarket).
>
> 2. Set approvals (one-time) — approve exchange contracts for USDC and conditional tokens.
>
> 3. Connect to the CLOB. Python: `pip install py-clob-client`. Rust options: polyfill-rs (zero-alloc, SIMD JSON, 21% faster), polymarket-client-sdk (official Rust SDK), polymarket-hft (full HFT framework).
>
> 4. Query fee rates before every order: `GET /fee-rate?tokenID={token_id}`. Never hardcode fees.
>
> 5. Sign orders with the fee field:
> ```json
> {
>   "salt": "...",
>   "maker": "0x...",
>   "signer": "0x...",
>   "taker": "0x...",
>   "tokenId": "...",
>   "makerAmount": "50000000",
>   "takerAmount": "100000000",
>   "feeRateBps": "150"
> }
> ```
>
> 6. Post maker orders on both sides — BUY and SELL on both YES and NO tokens. This earns rebates.
>
> 7. Run the cancel/replace loop — monitor Binance WS and your current quotes. When price moves, cancel stale orders and replace. Target <100ms for the full cycle.
>
> **For 5-minute markets specifically**
>
> 288 markets per day. Each one is a fresh opportunity.
>
> Strategy: At T-10 seconds before window close, BTC direction is ~85% determined. But Polymarket odds haven't fully priced it in. Post a maker order on the winning side at 90-95¢. If filled: $0.05-0.10/share profit on resolution, zero fees, plus rebates.
>
> The edge is pricing BTC direction faster than other makers and getting your order posted first.
>
> **The mistakes that will kill you**
>
> - Using REST instead of WebSocket
> - Not including feeRateBps in order signing
> - Running from home wifi (150ms+ latency vs <5ms on a colocated VPS)
> - Market making near 50% without accounting for adverse selection
> - Hardcoding fee rates
> - Not merging YES/NO positions (capital gets locked)
> - Trying to taker-arb like it's 2025
>
> **The correct way to use AI here**
>
> You define the stack, the infrastructure, and the constraints. AI generates the strategy logic on top:
>
> "Here's the Polymarket SDK. Write me a maker bot for 5-minute BTC markets. It should monitor Binance WS for price, post maker orders on both sides, include feeRateBps in signing, and run a cancel/replace loop under 100ms. Use WebSocket for orderbook data."
>
> Even if you describe the bot logic perfectly, you still have to test it first. Backtesting against the fee curve is mandatory before you go live.
>
> The bots that win in 2026 aren't the fastest takers. They're the best liquidity providers. Build accordingly.
>
> Engagement: 1,866 likes | 140 retweets | 59 replies
> [Original post](https://x.com/_dominatos/status/2024871493809680410)
