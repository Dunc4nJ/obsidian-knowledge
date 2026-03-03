---
created: 2026-01-31
description: Safety-first automated trading system for Polymarket and Kalshi — data archival, backtesting, and algorithmic execution
source: internal
type: moc
---

# Polytrader

## Status

- **Active work**: Spec-complete (SPEC_UPDATED.md v2.0), awaiting implementation start
- **Blockers**: None — spec is implementation-ready
- **Last updated**: 2026-01-31

## Key Decisions

- Hybrid separate pipelines: Rust ingestion + Python trading with independent WebSocket connections for fault isolation
- Nautilus Trader as the execution engine — supports event-driven and ML signal-based strategies
- Feast feature store (offline-first) over SageMaker — cost-first philosophy
- Single EC2 + S3 medallion architecture targeting ~$50/mo operational cost
- Venue-agnostic `InstrumentKey` format supporting multi-exchange (Polymarket, Kalshi, future)
- Execution modes: `dry_run` → `paper_live` → `canary_live` → `small_live` for safe ramp-up

## Navigation

### Core Notes

- [[mathematical infrastructure not luck extracted 40 million from Polymarket]] — the integer programming, Bregman projection, and Frank-Wolfe optimization frameworks that extracted $40M in prediction market arbitrage — foundational math for Polytrader's execution engine
- [[polymarket arbitrage trading requires barrier frank-wolfe initialization and adaptive contraction]] — practical implementation details: initialization, gradient stability, and profit-guarantee stopping rules
- [[polymarket alpha compounds when traders specialize in one repeatable execution edge]] — edge comes from strategy specialization and execution speed rather than broad prediction generalism
- [[attention markets shift arbitrage from binary constraints to latency correlation and manipulation volatility]] — attention-market microstructure shifts edge to oracle latency, correlation dislocations, and manipulation-linked volatility
- [[polymarket research papers]] — reading list: price misalignment, volatility modeling, and prediction market mechanism design

### Learnings

(none yet)

## Open Questions

- Which component to implement first: Rust ingestion, Python trading, or backtest engine?
- Kalshi integration timeline and priority relative to Polymarket
- ML model selection for signal generation — which models to start with?
- Redis vs. alternative for Nautilus hot state persistence

Code: `/data/projects/polytrader`
