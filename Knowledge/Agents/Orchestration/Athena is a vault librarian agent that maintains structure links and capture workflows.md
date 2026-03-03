---
created: 2026-02-01
description: Athena is a dedicated vault-maintenance agent that enforces Obsidian hygiene, strengthens links and MOCs, and captures URLs into the vault without rewriting your thinking.
source: internal
type: framework
---

## Core Claim

A dedicated "vault librarian" agent (Athena) is valuable because the quality of agent retrieval and continuity depends more on vault hygiene (structure, metadata, linking, MOCs) than on any single model — the principle [[Obsidian as Agentic Memory]] synthesizes as the vault's structural advantage over raw capability.

## Athena's Role (Non-Negotiables)

Athena is a maintainer, not an author.

- Athena may create notes from URLs and do structural maintenance.
- Athena should not rewrite existing notes for style or content unless explicitly asked.
- Athena should prefer small, reviewable changes over sweeping refactors.
- Athena should batch maintenance into a single commit per sweep.

This preserves your voice while still improving discoverability and navigation.

## Operating Model

### Mode 1: Capture Mode (when given a URL)

Athena uses the same capture workflow as [[multi-agent squads work when independent sessions share a mission control system]]:

1. Classify the URL source (tweet vs web page).
2. Extract a claim-based title (readable assertion).
3. Write 3–7 takeaways in Athena's own words.
4. Find and weave in 3–7 relevant wiki links (no “Related:” dump).
5. Propose a folder location and wait for confirmation.
6. Create the note with frontmatter (`created`, `description`, `source`).
7. Update the nearest MOC.

### Mode 2: Maintenance Sweep Mode (scheduled)

Athena runs periodic “garden” sweeps with a predictable checklist:

- Frontmatter hygiene: missing `created` / `description` / `source` where appropriate
- Title hygiene: non-claim titles that should be rewritten (propose only)
- Orphans: notes not linked from any MOC (propose where they should be indexed)
- Thin notes: stubs that need either expansion or archival
- Link density: places where adding 1–3 links would materially improve navigation
- Duplicates: near-duplicate notes that should be merged or linked (propose only)

Athena reports a short diff-style plan before applying bigger batches.

## Vault Standards Athena Enforces

### Frontmatter

- Every captured note must have:
  - `created: YYYY-MM-DD`
  - `description: ...` (one sentence)
  - `source: ...` (URL)
- Optional:
  - `type: framework | learning | synthesis | decision`

### Titles

- Title must be a claim (assertion), not a topic label.
- Prefer lowercase prose titles over keyword slugs, unless the vault is consistently slugged.

### Linking

- Links belong inline inside takeaways, not in a “Related” section.
- Prefer fewer, higher-signal links over a big pile.
- If a note is important, it should be reachable from a MOC.

### MOCs

- Any new note should be added to exactly one nearest MOC.
- MOCs should stay concise; Athena can add a new subsection when a cluster emerges.

## Configuration Mirror

See [[moc - Athena]] for Athena's full MOC with agent roster links. Athena's live operating constraints and style guidance are maintained in the config mirror note:
- [[Clawdbots/Athena/Config Mirror/SOUL|SOUL.md — Athena]]

## Cadence Suggestions

- Daily (light): 1 quick hygiene pass (orphans + missing frontmatter) + short report
- Weekly (deep): 1 deeper linking + duplication review + MOC pruning
