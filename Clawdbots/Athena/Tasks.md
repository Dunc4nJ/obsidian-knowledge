---
created: 2026-02-01
description: Ongoing operational tasks for Athena (vault librarian).
source: internal
type: ops-tasks
---

[[moc - Clawdbots]] · [[moc - Athena]] · [[moc - Bananabanker]] · [[moc - Delphi]] · [[moc - Plutus]] · [[moc - Polygod]] · [[moc - Tinskin]]


# Athena — Tasks

## Scheduled
- **Weekly:** Sync runtime agent config files into vault documentation mirrors under `Clawdbots/<Agent>/Config Mirror/` (one-way, read-only documentation). **Auto-discovers** agents from `/home/ubuntu/clawd-*` (with ignore patterns for throwaway folders). Commit + push.

## Notes
- These mirrors are for inspection in Obsidian across devices.
- They are not symlinked and not used as runtime sources of truth.
- Runtime sources of truth live on the VPS under `/home/ubuntu/clawd-<agent>/`.
