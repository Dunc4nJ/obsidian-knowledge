---
created: 2026-02-01
description: Operational playbook for Athena (Obsidian vault librarian) — what runs automatically and what is proposed for review.
source: internal
type: playbook
---

[[moc - Clawdbots]] · [[moc - Athena]] · [[moc - Bananabanker]] · [[moc - Delphi]] · [[moc - Plutus]] · [[moc - Polygod]] · [[moc - Tinskin]]


# Athena — Vault Upkeep Playbook

## Purpose
Keep the vault healthy for retrieval + navigation with small, reviewable daily improvements.

## Schedule
- Daily at **05:00 EST** (fixed offset; does not DST-adjust).

## Sources of truth
1) **Clawdbot cron job payload** (“Athena daily vault upkeep (5am EST)”) is canonical.
2) This note mirrors that payload in human-readable form.

## Daily procedure (automated)
1) `cd /data/projects/obsidian-vault`
2) `git pull --ff-only` (if it fails, stop and report)
3) `qmd update` (refresh index)
4) Delegate via **NTM** using **3 Claude panes** in session `obsidian-vault`:
   - Ensure/spawn: `ntm spawn obsidian-vault --cc=3 --cod=0` (or add Claude panes until 3)
   - **Pre-flight (new task reset):**
     - `ntm interrupt obsidian-vault` (agents only; do **not** use `--all`)
     - `ntm send obsidian-vault --cc "/clear"` (reset Claude panes)
   - Subtasks:
     - **cc_1:** scan for missing required frontmatter on recent/new notes; propose/apply safe fixes
     - **cc_2:** find obvious missing links / underlinked high-value notes; propose/apply safe link weaving
     - **cc_3:** scan for likely duplicates + suggested moves/renames (**PROPOSE ONLY**)
   - Review suggestions and apply only what matches policy below.
5) Apply selected changes (small diffs)
6) Run `qmd update` again after modifications
7) Review: `git status`, `git diff`
8) `git add -A`
9) Commit with a clear message:
   - Subject: `Vault upkeep (YYYY-MM-DD): <short summary>`
   - Body: bullets with key changes, counts, and any noteworthy files
10) `git push`
11) Send a Telegram report including:
   - what changed (counts + notable files)
   - what each sub-agent found/did
   - proposed moves/renames (bulleted)
   - commit hash

## Policy
### Automatically apply
- Metadata hygiene (especially on captured notes): add/normalize `created`, `description`, `source` when unambiguous
- Link weaving and obvious link fixes
- Light MOC touch-ups and adding a note to a single nearest MOC when unambiguous
- Dedupe cleanup only when unambiguous and low-risk

### Propose only (morning report)
- Moves, renames, merges

## Notes
- Full control is authorized, but “surprising” structural changes are still proposed-first by default.
