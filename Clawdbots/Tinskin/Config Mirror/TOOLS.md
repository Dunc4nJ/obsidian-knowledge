# TOOLS.md - Local Notes

Skills define *how* tools work. This file is for *your* specifics — the stuff that's unique to your setup.

---

## Obsidian Vault (qmd-indexed)

**Location:** `/data/projects/obsidian-vault`
**Git repo:** `github.com:Dunc4nJ/obsidian-vault.git`
**Sync:** Git-based via Obsidian Git plugin (Droid Overlord's Mac)

### Structure
```
obsidian-vault/
├── Daily Notes/    # Daily journal entries
├── Projects/       # Project-specific notes
├── Archive/        # Old/completed stuff
└── Templates/      # Note templates
```

### qmd Search (use instead of reading files!)

**Why:** 96% token savings — get snippets instead of full files.

```bash
# Text search (BM25) - fast, keyword-based
qmd search "query" -c obsidian

# Vector search (semantic) - understands meaning
qmd vsearch "query" -c obsidian

# List all notes
qmd ls obsidian

# Get a specific file
qmd get qmd://obsidian/path/to/note.md

# Update index after changes
qmd update
```

### Creating/Editing Notes

```bash
# Create note (direct file write)
cat > /data/projects/obsidian-vault/Folder/note.md << 'EOF'
# Title
Content here
EOF

# Commit and push for sync
cd /data/projects/obsidian-vault && git add -A && git commit -m "msg" && git push
```

### When to Use What
- **Finding info in notes** → `qmd search` (not grep/cat)
- **Creating/editing notes** → Direct file write + git push
- **Full note content** → `qmd get qmd://obsidian/path.md`

---

## Twitter/X (bird CLI)

**Account:** @entropycoder
**Auth:** Environment variables in ~/.bashrc (AUTH_TOKEN, CT0)

### Common Commands
```bash
source ~/.bashrc  # load credentials

# Read
bird home -n 5                    # Home timeline
bird mentions -n 10               # Mentions
bird read <url>                   # Read specific tweet
bird thread <url>                 # Full thread
bird replies <url>                # Replies to tweet

# Search
bird search "query" -n 10

# User
bird user-tweets @handle -n 10    # Someone's tweets
bird following -n 20              # Who you follow

# Post (with caution!)
bird tweet "message"
bird reply <url> "response"
```

### Safety Rules
- ✅ Reading/searching: do freely
- ⚠️ Posting: confirm with Overlord first
- ❌ Never post without explicit approval

---

## RSS/Blog Monitoring (blogwatcher)

### Commands
```bash
# Add a feed
blogwatcher add "Name" "https://site.com" --feed-url "https://site.com/feed.xml"

# List tracked feeds
blogwatcher blogs

# Check for new articles
blogwatcher scan

# View unread articles
blogwatcher articles

# Mark as read
blogwatcher read 1
blogwatcher read-all
```

### Note on Latency
RSS feeds update every 5-60 minutes. For real-time news, use Twitter/X instead.

---

## qmd (Markdown Search Engine)

**Index location:** `~/.cache/qmd/index.sqlite`
**Models:** `~/.cache/qmd/models/`

### Collections
```bash
# List collections
qmd collection list

# Add new collection
qmd collection add /path/to/folder --name myname --mask "**/*.md"

# Remove collection
echo "y" | qmd collection remove "name"

# Re-index everything
qmd update

# Re-embed after index update
qmd embed
```

### Search Modes
| Command | Type | Use for |
|---------|------|---------|
| `qmd search "x"` | BM25 (keyword) | Exact terms, fast |
| `qmd vsearch "x"` | Vector (semantic) | Meaning-based |
| `qmd query "x"` | Hybrid + rerank | Best quality (slower) |

### Output Options
- `-n 10` — number of results
- `--full` — full document instead of snippet
- `--json` — JSON output
- `-c collection` — filter to specific collection

---

## Projects Location

All projects live in `/data/projects/`:
- `obsidian-vault/` — shared notes (qmd indexed)
- `tableclay/` — TableClay e-commerce
- `polytrader/` — trading project
- `clawdbotproject/` — Clawdbot related
- `acip/` — ACIP security prompts
- etc.

---

*Updated: 2026-01-27*

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
