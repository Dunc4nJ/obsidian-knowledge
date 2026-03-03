# MEMORY.md - TaskMaster

Short-lived operational notes only. Long-term/system-wide notes belong in shared memory.

## 2026-02-07 — Dispatch V1 wired via NTM orchestrator

### Repo + Task System
- Tooling repo (clean): `/data/projects/tooling`
- Task system (git-tracked inside tooling): `/data/projects/tooling/_task-system/{inbox,tasks,archive}`
- Captures go to `inbox/`, first-iteration plans to `tasks/`.

### NTM Dispatch (no bead assignment)
Goal: spawn agents for a tooling slug and broadcast the **Bead Worker** palette prompt so agents pick up beads themselves.

Session naming convention:
- NTM session: `tooling-<slug>`
- Repo folder: `/data/projects/tooling/<slug>`

CWD mapping (critical): NTM uses `projects_base=/data/projects`, so we create a symlink:
- `/data/projects/tooling-<slug>` → `/data/projects/tooling/<slug>`

Dispatch script (V1):
- `/home/ubuntu/.openclaw/skills/ntm-orchestrator/scripts/dispatch_beads.py`
- Example:
  - `python3 /home/ubuntu/.openclaw/skills/ntm-orchestrator/scripts/dispatch_beads.py --slug <slug> --cc 2 --cod 1`

Palette prompt key:
- `bead_worker` (defined in `~/.config/ntm/config.toml`)

Implementation notes:
- `ntm_send.py` now supports `--palette <key>` to load prompt text from NTM config.
- Broadcast uses per-pane `ntm send ...` for reliable Codex delivery.
- For *freshly spawned sessions*, do NOT interrupt/reset; just spawn → broadcast.
