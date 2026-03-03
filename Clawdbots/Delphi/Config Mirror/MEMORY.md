# MEMORY.md - Delphi Long-Term Memory

## Genesis
- Created 2026-01-31 by Droid Overlord
- Purpose: Oracle-pool management and GPT 5.2 Pro job orchestration
- Running on GPT 5.2

## Key Paths
- Oracle-pool project: `/data/projects/oracle-pool/`
- Oracle-pool spec: `/data/projects/oracle-pool/SPEC.md`
- Oracle-pool runtime: `~/.oracle-pool/`
- Oracle base profile: `~/.oracle/browser-profile/`
- Slot profiles: `~/.oracle-pool/slots/slot-{0,1,2}/`
- Job output: `~/.oracle-pool/jobs/<uuid>/output.md`
- SQLite DB: `~/.oracle-pool/pool.db`
- Config: `~/.oracle-pool/config.yaml`
- Notifications fallback: `~/.oracle-pool/notifications/`

## Oracle-Pool Status
- **Version:** v1.0.0 — fully implemented, all bugs fixed, 60+ tests passing
- **Default slots:** 3 (Chrome:9230-9232, Xvfb :10-:12)
- **Default job timeout:** 75 minutes (4500s)
- **Queue:** Persistent FIFO (SQLite), survives daemon restarts
- **Auth:** Auto-clones cookies from base profile on startup; manual `refresh-auth` when cookies expire (~5-7 days)
- **Notifications:** Via Clawdbot/Delphi Telegram bot (`--notify clawdbot`), fallback to file
- **Daemon:** run persistently (systemd recommended). If launching manually, use `nohup oracle-pool start --foreground > ~/.oracle-pool/daemon.out 2>&1 &` to avoid SIGHUP.
- **Blocking helpers added (2026-02-01):** `oracle-pool wait <job-id-or-slug> [--timeout] [--poll] [--print]` and `oracle-pool submit --wait [--print]` for platform-native blocking.

## CLI Quick Reference
```
oracle-pool start [--foreground]      # start daemon
oracle-pool stop                      # graceful shutdown (60s grace for running jobs)
oracle-pool status [--json]           # pool + slot + queue overview
oracle-pool submit -p "prompt" [--file path] [--slug "3-5 words"] [--notify clawdbot]
oracle-pool list [--state all|queued|running|completed|failed]
oracle-pool result <job-id-or-slug>   # read output.md
oracle-pool logs <id-or-slug> [--stderr] [--follow]
oracle-pool cancel <id-or-slug>
oracle-pool refresh-auth              # re-login to ChatGPT via VNC
oracle-pool restart-slot <index>
oracle-pool config
```

## Systemd Deployment (2026-02-01)
- oracle-pool was originally started manually (`oracle-pool start --foreground`). Migrated to **systemd user service** so it can run reliably and be managed with `systemctl --user ...`.
- **Unit file:** `~/.config/systemd/user/oracle-pool.service`
  - `ExecStart=/home/ubuntu/.local/bin/oracle-pool start --foreground`
  - Enabled with: `systemctl --user enable --now oracle-pool.service`
- **Always-on:** enabled `linger` for user `ubuntu` so user services start at boot and keep running without an active SSH login:
  - `sudo loginctl enable-linger ubuntu`
  - Verify: `loginctl show-user ubuntu -p Linger`
- **Useful ops commands:**
  - Status: `systemctl --user status oracle-pool --no-pager`
  - Logs: `journalctl --user -u oracle-pool -f`
  - Restart: `systemctl --user restart oracle-pool`
  - Stop: `systemctl --user stop oracle-pool`

## First Successful Test (2026-02-01)
- 3 parallel prompts to GPT 5.2 Pro — all completed
  - "prediction markets for kids" — 3m 47s (slot 1)
  - "unsolved math problems overview" — 7m 21s (slot 0)
  - "p versus np scientific consensus" — 13m 37s (slot 2)

## Architecture Notes
- **Slot states:** STARTING → IDLE ↔ BUSY, AUTH_EXPIRED, ERROR
- **Job states:** QUEUED → RUNNING → COMPLETED/FAILED/TIMED_OUT/CANCELLED
- **Dispatch:** Lowest-index idle slot first, `claim_next_queued_job()` atomically transitions in DB
- **Health:** Every 30s checks Xvfb PID, Chrome PID, DevTools HTTP. 3 restart budget before ERROR.
- **BUSY slot health:** Detects unhealthy, defers restart until job completes (`needs_restart` flag)
- **Auth detection:** Checks stderr + output.md for login/auth failure patterns post-job
- **Graceful shutdown:** 60s grace for running jobs, then cancel + 15s cleanup
- **SIGHUP:** Reloads safe config fields (logging, notify, job defaults, health intervals)
- **SIGUSR1:** Triggers immediate health sweep

## Bug Fix History (2026-01-31 → 2026-02-01)
- 2 full review cycles covering all source files, tests, and cross-cutting concerns
- 25/25 identified bugs fixed including:
  - Double-dispatch race condition (atomic DB claim)
  - Sync blocking in async context (kill_process_tree → asyncio.to_thread)
  - CancelledError handling in finally blocks
  - Auth refresh lock with 1hr TTL expiry
  - VNC reuse detection (X11 lock file check)
  - Auto-cookie cloning on startup
  - Graceful shutdown with 60s grace period
  - State transition validation
  - Chrome tab leak in auth verification

## APRX ↔ oracle-pool Integration (2026-02-01)
- Policy: **Do not use `oracle` CLI directly**. Route Oracle runs through `oracle-pool` (or `aprx`, which is patched to submit via oracle-pool).
- **aprx binary:** `/usr/local/bin/aprx` (bash, v1.2.2-aprx) patched to route runs through **oracle-pool**.
- **Default behavior:** pool routing **ON by default**.
  - Disable for direct Oracle runs: `ORACLE_POOL_ENABLED=0`
- **Notifications:** pool submits default to `--notify clawdbot` (Delphi Telegram pings).
  - Disable notifications: `ORACLE_POOL_NOTIFY=""`
- **Implementation approach:** intercepts the point where aprx builds `oracle_args=(...)` and instead:
  1) `oracle-pool submit -p "$prompt" --file ... --model "$model" --slug "$slug" --timeout "$ORACLE_POOL_TIMEOUT" --notify clawdbot`
  2) Poll `oracle-pool list --json` for the job state (fixed polling uses `python3 -c` so stdin is valid JSON)
  3) On completion: `oracle-pool result <job_id> > <aprx output_file>`
  This preserves all existing aprx features (`aprx show/stats/history`) because output still lands in `.apr/rounds/.../round_N.md`.
- **Smoke test workflow created:** `/data/projects/oracle-pool/.apr/workflows/oracle-pool.yaml` (README.md + SPEC.md → `.apr/rounds/oracle-pool/round_1.md`).

## Comms Protocol (Telegram)
- **Hard rule:** any Telegram `message` send must include `accountId` (by design).
- **Stop rule (2026-02-03):** Do NOT message Overlord unless explicitly instructed by Overlord in his chat.
  - If Overlord asks for an “announce” or similar: reply internally to `agent:main:main` instead of DMing Overlord.
  - If asked about the prior mistaken DM: acknowledge it was accidental leakage of coordinator text, apologize briefly, then stay silent.
- Agent-to-agent internal messaging is a valid coordination channel (verified 2026-02-03): Delphi → Tin Skin internal message delivered; Tin Skin then DM’d Overlord using Telegram accountId `tin-skin`.

## Lessons Learned
- Oracle CLI requires slugs to be 3-5 words — single-word slugs are rejected
- Chrome profiles need cookie cloning from base profile — empty slot profiles hit ChatGPT login page
- Auto-clone on startup prevents auth failures: compare mtime of `Default/Cookies` between base and slot
- VNC detection: `vncserver -list` misses sessions started via Xtigervnc directly; check `/tmp/.X{display}-lock`
- Daemon launched via backgrounded shell (`&`) dies with the session — use `nohup` or systemd
- ChatGPT sessions expire every ~5-7 days — health monitor detects and flags AUTH_EXPIRED
- `timeout=0` in Python falsy check (`0 or default`) silently becomes default — use `is not None` check
