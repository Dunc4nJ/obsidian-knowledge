---
created: 2026-02-20
type: learning
description: JSON state files let agents reconstruct task context instantly after compaction, unlike narrative logs that require re-reading
source: session-digest
---
# Structured state files beat append-only logs for agent task persistence across compaction

When an agent manages multi-step work (decompose plan → spawn subagents → validate → close), it needs to survive compaction and session restarts without losing track.

**Append-only logs** force the agent to re-read everything and reconstruct state mentally. This is slow, token-expensive, and error-prone.

**Structured state files** (one JSON per active task) let the agent parse its current position in ~10 lines:

```json
{
  "taskId": "deploy-new-checkout",
  "status": "in_progress",
  "beads": {
    "completed": ["bd-a1"],
    "in_progress": {"bd-a2": {"subagent": "session-key-xyz"}},
    "remaining": ["bd-a3", "bd-a4"]
  },
  "lastAction": "Validated bd-a1, spawned subagent for bd-a2",
  "blockers": []
}
```

This pattern emerged from designing the [[CRM task orchestration architecture]] — the key insight is that agents need *queryable state*, not *narrative history*.

Related: [[progressive disclosure filters force agent selectivity over what enters context]]
