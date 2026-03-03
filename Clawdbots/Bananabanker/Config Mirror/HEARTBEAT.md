# HEARTBEAT.md

## Bead Supervisor: bananabank

Run the bead supervisor check cycle. Follow `~/.openclaw/skills/ntm-orchestrator/bead-supervisor.md` for the full procedure.

State file: `/tmp/bead-supervisor-bananabank.json`
Session: `bananabank`
Palette key: `bead_worker`

### Quick reference:
1. Read state file — if stopped, do nothing
2. Check bead progress: `cd /data/projects/bananabank && br list --json --all`
3. Detect pane states: `python3 ~/.openclaw/skills/ntm-orchestrator/scripts/pane-detect.py bananabank --panes=2,3,4`
4. Act: re-send work to idle panes, answer questions, rotate auth on errors
5. Update state file
6. Report only on stops/escalations
