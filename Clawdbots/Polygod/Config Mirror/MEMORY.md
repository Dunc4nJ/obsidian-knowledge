# MEMORY.md - Polygod Long-Term Memory

## Genesis
- Created 2026-01-31 by Droid Overlord
- Purpose: Prediction market analysis and automated trading
- Running on GPT 5.2

## Projects

### oracle-pool (2026-01-31 → 2026-02-01)
- **Location:** `/data/projects/oracle-pool/`
- **What:** Chrome pool daemon for parallel GPT 5.2 Pro browser-mode queries
- **Status:** v1.0.0 — fully implemented, all 25 review bugs fixed, 60+ tests passing
- **Spec:** `/data/projects/oracle-pool/SPEC.md`
- **Key features:** 3 parallel Chrome slots, persistent FIFO queue (SQLite), auto-cookie cloning on startup, health monitoring, Clawdbot/Delphi notifications
- **Successfully tested:** 3 parallel prompts to GPT 5.2 Pro completed (3m47s, 7m21s, 13m37s)
- **Daemon:** `oracle-pool start --foreground` (systemd service file exists but not yet installed)
- **Bug fix rounds:** 2 full review cycles (core + runtime + CLI/client/notify + tests + cross-cutting), all findings resolved

### Delphi Agent (2026-01-31)
- **Location:** `/home/ubuntu/clawd-delphi/`
- **What:** Clawdbot agent for oracle-pool management & notifications
- **Status:** Workspace files created (SOUL.md, AGENTS.md, etc.), not yet registered with Clawdbot gateway

### polytrader (pre-existing)
- **Location:** `/data/projects/polytrader/`
- **What:** Polymarket trading project
- **Status:** Research phase

### prediction-market-analysis (2026-02-12)
- **Location:** `/home/ubuntu/clawd-polygod/prediction-market-analysis/`
- **Source:** `https://github.com/Jon-Becker/prediction-market-analysis`
- **What:** Python research framework + dataset tooling for prediction market microstructure analysis across **Polymarket** and **Kalshi**.
- **Purpose:**
  - Index market metadata and trade history (API + Polygon chain backfill) into Parquet files.
  - Run reusable analysis scripts that output charts/data (`png`, `pdf`, `csv`, `json`, optional `gif`).
  - Support reproducible research workflows using DuckDB/Pandas/Matplotlib and documented schemas.
- **Notable details:**
  - Includes a large pre-collected dataset workflow (`make setup`, ~36GiB compressed).
  - CLI entrypoints in `main.py`: `index`, `analyze`, `package` (interactive menu via `simple-term-menu`).
  - Core architecture: `src/indexers/*` (data ingestion), `src/analysis/*` (research analyses), `src/common/*` (framework primitives).

## Market Insights
*(To be populated as we trade)*

## Lessons Learned
- Oracle CLI requires slugs to be 3-5 words — single-word slugs like "test-math" are rejected
- Chrome profiles need cookie cloning from base profile — empty slot profiles hit ChatGPT login page
- Auto-clone on startup prevents auth failures: compare mtime of Default/Cookies between base and slot profiles
- VNC detection: `vncserver -list` can miss sessions started via Xtigervnc directly; check `/tmp/.X{display}-lock` as primary method
- Daemon launched via backgrounded shell (`&`) dies when the shell session ends — use `nohup` or systemd for production
- When sending citations/URLs in Telegram, ensure no trailing bracket/Unicode characters are appended (e.g., avoid accidental `】` after links); send clean copy-paste URLs
- Polymarket US Retail API docs entrypoint: https://docs.polymarket.us/api/introduction
- For `prediction-market-analysis` dataset setup (`make setup`), install `aria2c` first; otherwise download throughput is much slower and setup can take significantly longer.
