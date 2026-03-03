---
created: 2026-02-16
description: Polymarket launches its official US-regulated retail API with Ed25519 auth, 23 REST endpoints, 2 WebSocket streams, and Python/TypeScript SDKs
source: https://x.com/mustafap0ly/status/2023460622869090329
---

## Key Takeaways

Polymarket's US arm has gone live with a fully documented public API, marking a major shift from the crypto-native international CLOB to a clean, CFTC-regulated REST+WebSocket surface. The API uses Ed25519 key-based auth instead of Ethereum wallet signing, which dramatically simplifies integration compared to the [[polymarket CLOB API requires EIP-712 signing and conditional token framework for order placement|international CLOB's CTF complexity]].

The endpoint surface is well-structured: 6 market endpoints (including BBO for lightweight polling and full book depth), 6 order management endpoints with preview and modify support, and 2 WebSocket streams — one for market data (up to 10 instruments) and one for private order/position/balance updates. This maps cleanly to [[NautilusTrader adapter architecture separates data and execution into independent client components|NautilusTrader's data+execution adapter pattern]].

Authentication requires downloading the iOS app, completing KYC, then generating Ed25519 keys from the developer portal at `polymarket.us/developer`. This is a one-time setup — much simpler than managing Polygon wallets and CLOB API keys.

The documentation is thorough with an LLM-friendly index at `docs.polymarket.us/llms.txt`, covering everything from market structure to trading hours, limits, and settlement mechanics. Fully collateralized contracts mean no margin risk.

## External Resources

- [Developer Portal](https://polymarket.us/developer) — generate Ed25519 API keys
- [API Introduction](https://docs.polymarket.us/api/introduction) — overview and capabilities
- [Authentication Guide](https://docs.polymarket.us/api/authentication) — Ed25519 signing details
- [Full Documentation Index](https://docs.polymarket.us/llms.txt) — all endpoints listed
- [Markets WebSocket](https://docs.polymarket.us/api-reference/websocket/markets) — real-time market data
- [Private WebSocket](https://docs.polymarket.us/api-reference/websocket/private) — order/position updates
- [Create Order](https://docs.polymarket.us/api-reference/orders/create-order) — order placement
- [Data Structures](https://docs.polymarket.us/polymarket-learn/data/reference-data) — asset master and instrument hierarchy

## Original Content

> @mustafap0ly (Mustafa):
> public Polymarket US apis + sdks are live 😛
> access here - https://polymarket.us/developer
> docs, python, and typescript sdks - https://docs.polymarket.us/api/introduction
> — Mon Feb 16, 2026 | 731 likes, 53 retweets, 74 replies
