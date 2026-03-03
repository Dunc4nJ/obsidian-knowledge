---
created: 2026-01-31
description: Daemon + CLI managing a pool of Chrome instances to run oracle (GPT 5.2 Pro) queries in parallel
source: internal
type: moc
---

# Oracle-Pool

## Status

- **Active work**: Feature-complete (~2,900 LOC), improving test coverage
- **Blockers**: None
- **Last updated**: 2026-01-31

## Key Decisions

- Python async (aiohttp + aiosqlite) for concurrent job dispatch and persistent FIFO queue
- Multi-slot Chrome pool with health monitoring, cookie lifecycle management, and auth flagging
- Xvfb virtual display for headless Chrome operation
- Notification system via Telegram and Clawdbot for job completion alerts
- systemd daemon for production deployment
- Unix domain sockets for CLI ↔ daemon IPC

## Navigation

### Core Notes

(none yet)

### Learnings

(none yet)

## Open Questions

- Test coverage gaps: failure handling, concurrency edge cases, auth failure patterns, graceful shutdown (~35-40% current coverage)
- Production hardening priorities
- Scaling strategy if job volume increases beyond single-machine capacity

Code: `/data/projects/oracle-pool`
