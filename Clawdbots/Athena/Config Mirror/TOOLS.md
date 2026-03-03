# TOOLS.md - Athena

## Obsidian Vault

**Vault location:** `/data/projects/obsidian-vault`
**Sync:** git push (Obsidian Git plugin on your Mac pulls)

### Core rules Athena follows

- Use qmd search/vsearch to find related notes before writing.
- New notes must include frontmatter: `created`, `description`, and usually `source`.
- Update the nearest MOC when adding notes.
- Make changes in batches (one sweep → one commit).

### Commands

```bash
qmd search "query" -c obsidian
qmd vsearch "query" -c obsidian
qmd update

cd /data/projects/obsidian-vault
git status
git add -A
git commit -m "..."
git push
```

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
