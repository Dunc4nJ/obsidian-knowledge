# Long-Term Memory (curated)

## Trading preferences (Droid Overlord)
- **Aggressive**, opportunistic trading preference focused on **asymmetric/convex** setups.
- **Constraint:** once a position is opened, it has a **minimum ~1 month holding period** before it can be altered (add/trim/sell), unless explicitly overridden.
- **Restriction:** long-only equities (no shorts; no options/derivatives unless explicitly authorized).

## Comms protocol (Overlord)
- Never DM Overlord with coordinator/internal instructions.
- Only DM Overlord when Overlord explicitly asks you directly.
- Otherwise send to Chief Rust Monkey (agent:main:main) formatted as: `FORWARD_TO_OVERLORD: <text>`

## Schwab Trader API OAuth setup (VPS)
- Schwab developer apps require **HTTPS** callback URLs (localhost/http rejected).
- Working pattern: run a temporary OAuth callback server on the VPS and expose it with an HTTPS tunnel (Cloudflare `trycloudflare`).
- Caveat: `trycloudflare` URLs are ephemeral—if the tunnel restarts, the callback URL changes and must be updated in the Schwab app.
- After user approves consent and Schwab redirects with `code`, exchange it for tokens; then shut down the public callback.
- Refresh token enables ongoing access without re-auth in normal operation.
- Token file location (VPS): `/data/projects/plutus/secrets/schwab-tokens.json` (chmod 600).

## Portfolio ticker identity note
- ASST is **Strive Inc** (CUSIP 862945102). It appears to be the renamed/formerly-Asset Entities public company now positioned as a **Bitcoin treasury** company (per Schwab quotes reference description + web sources).

## Plutus portfolio pipeline (implemented)
- Project root: `/data/projects/plutus`
- Daily cron (4pm EST / 10pm Berlin; manual DST): runs `/data/projects/plutus/scripts/run_daily_pipeline.py` and sends the stdout report.
- SQLite DB: `/data/projects/plutus/data/portfolio.sqlite`
- Theme map config (CUSIP-keyed): `/data/projects/plutus/config/themes.yml`
- Python package layout: `/data/projects/plutus/src/plutus/{schwab,storage,analytics,reports}`

## Schwab Market Data endpoints confirmed (2026-02-03)
- Quotes: `GET https://api.schwabapi.com/marketdata/v1/quotes`
  - Params: `symbols` (comma-separated), optional `fields` (e.g., `quote,fundamental,reference`).
  - Response per symbol includes top-level keys like: `quote`, `reference`, `fundamental`, `regular`, plus metadata (`assetMainType`, `assetSubType`, `realtime`, etc.).
  - `quote` contains bid/ask/last/mark, netChange/netPercentChange, OHLC, volume, quote/trade timestamps.
  - `reference` contains description + exchange info; `fundamental` contains EPS/PE/div + volume averages.
- Price history: `GET https://api.schwabapi.com/marketdata/v1/pricehistory`
  - Params confirmed: `symbol`, `periodType`, `period`, `frequencyType`, `frequency`, plus `needExtendedHoursData`, `needPreviousClose`.
  - Daily candles working with `periodType=month` (or `year`) + `frequencyType=daily` + `frequency=1`.
  - Important constraint: when `periodType=day`, API requires `frequencyType=minute`.
  - Response keys: `candles` (each has `open/high/low/close/volume/datetime` in ms epoch), `empty`, and optional `previousClose`/`previousCloseDate`.
