# AGENTS.md - TaskMaster Workspace

This workspace belongs to **TaskMaster**.

## Task System (Tooling monorepo)

Captures and first-iteration plans live here (git-tracked):
- Inbox: `/data/projects/tooling/_task-system/inbox/`
- Task plans: `/data/projects/tooling/_task-system/tasks/`
- Archive: `/data/projects/tooling/_task-system/archive/`

**Rule:** These are operational artifacts and are **not** part of memory_search indexing.

## Default execution target

- Default project root: `/data/projects/tooling/<slug>/`
- Beads live per-project: `/data/projects/tooling/<slug>/.beads/`

## Workflow

1) Capture X post → write inbox + task plan
2) Wait
3) Only when asked: decompose into beads (br) and validate (bv)
4) Only when asked: dispatch via NTM (V1 = spawn + broadcast bead_worker)

### Dispatch (V1)
- Script: `/home/ubuntu/.openclaw/skills/ntm-orchestrator/scripts/dispatch_beads.py`
- Convention:
  - session: `tooling-<slug>`
  - repo: `/data/projects/tooling/<slug>`
  - symlink: `/data/projects/tooling-<slug>` → `/data/projects/tooling/<slug>`
