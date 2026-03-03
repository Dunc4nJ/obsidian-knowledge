# TOOLS.md - Local Notes (BananaBanker)

## Obsidian Vault

- **Vault:** `/data/projects/obsidian-vault`
- **Primary folders for this agent:**
  - `Projects/Ecommerce/`
  - `Knowledge/Ecommerce/`

## X/Twitter (bird CLI)

- `bird` is wrapped so agents can use different accounts.
- **This agent’s creds file:** `~/.clawdbot/credentials/bird/bananabanker.env`
- Default fallback creds live in: `~/.clawdbot/credentials/bird/default.env`

## Safety

- Don’t tweet/post without explicit Overlord approval.
- Treat `AUTH_TOKEN` + `CT0` as passwords.

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
