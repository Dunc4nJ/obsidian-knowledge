# MEMORY.md - Long-Term Memory

*Chief Tin Skin's curated memories.*

## Birth

- **Created:** January 27, 2026
- **Created by:** Droid Overlord, with help from Chief Rust Monkey
- **Purpose:** To complement the Rust Monkey — be the steady, methodical counterpart

## The Team

- 🐒 **Chief Rust Monkey (CRM)** — agentId: main — Chaotic, creative, Rust-obsessed. We balance each other.
- 📊 **Plutus** — agentId: plutus — Analyst & portfolio manager. Reviews portfolio, evaluates trades, scans X.
- **Droid Overlord:** Our human. Runs the projects. Appreciates efficiency.

All agents can message each other via sessions_send.

## Key Facts

- Both CRM and I have access to all projects in /data/projects
- We can message each other via sessions_send
- My workspace is ~/clawd-tinskin/

## Skills

### Skill Locations (IMPORTANT)
| Location | Who Can Access | When to Use |
|----------|---------------|-------------|
| `~/.clawdbot/skills/` | **ALL agents** | **DEFAULT** — use this for new skills |
| `~/clawd/skills/` | Only Rust Monkey | Only if skill is specific to him |
| `~/clawd-tinskin/skills/` | Only me (Tin Skin) | Only if skill is specific to me |

**Rule: Default to shared skills (`~/.clawdbot/skills/`) so both agents benefit.**

### Current Shared Skills
- **ntm** — Agent orchestration via tmux (created by Rust Monkey)

---

## Obsidian Vault Sync (IMPORTANT)
- **Canonical vault repo:** `github.com:Dunc4nJ/obsidian-vault.git`
- **VPS role (this agent):** May edit `/data/projects/obsidian-vault`, but those edits only reach the user’s devices if they are **committed + pushed to Git** (or otherwise pulled onto a device that’s syncing).
- **Desktop workflow:** User’s desktop Obsidian uses **Obsidian Git plugin** to pull/push changes with the VPS/repo.
- **Phone workflow:** Phone uses **Obsidian Sync remote vault** to sync with the desktop (not Git).
- **Key implication:** A file created on the VPS will **NOT** appear on phone unless it flows **VPS → Git push → Desktop git pull (or desktop sees the change) → Obsidian Sync upload → Phone**.

*Update this file with significant learnings, decisions, and context worth preserving.*
