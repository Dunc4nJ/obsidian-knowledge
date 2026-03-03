# TOOLS.md - Polygod Local Notes

## Prediction Market Platforms
- Polymarket
- Kalshi
- Metaculus
- Manifold Markets

## Trading Notes
*(Add API keys, market IDs, position tracking notes here)*

## Projects Location
All projects: `/data/projects/`
- `polytrader/` — trading project

---

*Updated: 2026-01-31*

## Web Navigation (agent-browser)

This workspace can use the **agent-browser** CLI for real browser automation on the VPS (click/scroll/type/screenshot).

Quick start:
```bash
agent-browser open <url>
agent-browser snapshot -i      # get interactive elements with refs
agent-browser click @e1
agent-browser fill @e2 "text"
agent-browser scroll down 800
agent-browser screenshot page.png
agent-browser close
```

Note: Some sites may still present CAPTCHAs/2FA.
