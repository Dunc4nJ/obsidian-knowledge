---
name: bird
description: X/Twitter CLI for reading, searching, posting, and engagement. Use when user asks about Twitter, tweets, timelines, posting to X, or social media engagement.
user_invocable: true
tools:
  - Bash
  - Read
---

# bird - X/Twitter CLI

Fast X/Twitter CLI using GraphQL + cookie auth. Authenticated as `@entropycoder`.

**Important**: Always source `~/.bashrc` before running bird commands to load auth tokens.

## Authentication

```bash
source ~/.bashrc && bird whoami
```

## Quick Reference

### Reading

```bash
source ~/.bashrc && bird read <url-or-id>          # Read a single tweet
source ~/.bashrc && bird thread <url-or-id>        # Full conversation thread
source ~/.bashrc && bird replies <url-or-id>       # List replies
```

### Timelines

```bash
source ~/.bashrc && bird home -n 10                # Home timeline (For You)
source ~/.bashrc && bird home --following -n 10    # Following timeline
source ~/.bashrc && bird user-tweets @handle -n 20 # User's tweets
source ~/.bashrc && bird mentions                  # Mentions of you
```

### Search

```bash
source ~/.bashrc && bird search "query" -n 10
source ~/.bashrc && bird search "from:username" --all --max-pages 3
```

### News & Trending

```bash
source ~/.bashrc && bird news -n 10                # AI-curated from Explore
source ~/.bashrc && bird trending                  # Alias for news
```

### Bookmarks & Likes

```bash
source ~/.bashrc && bird bookmarks -n 10
source ~/.bashrc && bird likes -n 10
```

### Social Graph

```bash
source ~/.bashrc && bird following -n 20           # Users you follow
source ~/.bashrc && bird followers -n 20           # Your followers
source ~/.bashrc && bird about @handle             # Account info
```

### Engagement

```bash
source ~/.bashrc && bird follow @handle
source ~/.bashrc && bird unfollow @handle
```

### Posting

```bash
source ~/.bashrc && bird tweet "hello world"
source ~/.bashrc && bird reply <url-or-id> "nice thread!"
source ~/.bashrc && bird tweet "check this" --media image.png --alt "description"
```

**Warning**: Posting is more likely to be rate limited. If blocked, use browser instead.

## Output Options

| Flag | Description |
|------|-------------|
| `--json` | JSON output |
| `--plain` | No emoji, no color |
| `-n <num>` | Limit results |

## Troubleshooting

If you get 404 errors:
```bash
source ~/.bashrc && bird query-ids --fresh
```
