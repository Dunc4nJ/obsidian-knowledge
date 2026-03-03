---
created: 2025-07-17
description: Shared protocol governing how all agents and pipeline workers interact with brand data in the vault.
source: internal
type: protocol
---

# BananaBank Protocol v1

> This document implements the **Shared Protocol Layer** pattern from [[skill architecture beats skill writing when memory contracts and learning loops connect the system]]. One document. All agents. System-wide coherence.

## 1. File Ownership

Every brand context file has an `owner` in frontmatter.

- **Overwrite files** (`write_policy: overwrite`): Only the owning agent can modify. Before overwriting, show a diff of changes and get confirmation (or log the diff in the commit message).
- **Append-only files** (`write_policy: append-only`): Any authorized agent or pipeline worker can append. Never edit, reorder, or truncate existing entries.
- **If no owner is set:** Treat as read-only. Ask before modifying.

### Default Ownership

| File | Owner | Policy |
|---|---|---|
| voice-profile.md | {brand}-manager | overwrite |
| positioning.md | {brand}-manager | overwrite |
| audience.md | {brand}-manager | overwrite |
| product-catalog.md | {brand}-manager | overwrite |
| creative-kit.md | bananabanker | overwrite |
| learnings-log.md | all | append-only |
| assets-registry.md | all | append-only |

## 2. Context Loading

> Pattern: [[skill architecture beats skill writing when memory contracts and learning loops connect the system|Scored Context Loading]]

Before loading brand context, check the brand's `context-manifest.yaml`.

- **Load only what your role needs.** Full, summary, or exclude — as specified.
- **Apply TTL rules** from the manifest. Defaults:
  - < 7 days → pass as-is
  - 7-30 days → flag the age ("Note: audience data is 12 days old")
  - 30-90 days → load summary only, regardless of manifest
  - > 90 days → exclude, regardless of manifest
- **If context-manifest.yaml doesn't exist:** Fall back to loading all brand files (legacy behavior). Flag this as a gap.

## 3. Schema Compliance

> Pattern: [[skill architecture beats skill writing when memory contracts and learning loops connect the system|Schema Contracts]]

- All creative assets must conform to the [[Table Clay Tag Dictionary v2 (JSON)|tag dictionary schema]].
- Concept cards, proof cards, and assets must validate against schemas in the codebase (`/data/projects/bananabank/`).
- The vault `schemas/` folder (when created) mirrors the canonical code schemas for agent readability.
- **If a new tag value is needed:** Propose it in the learnings-log with rationale. Don't use free text in tag fields.
- Tags are the language of the pipeline — see [[ads become searchable and remixable when structured as concept-module-asset-variant objects with enum tags]].

## 4. Learning Loops

> Pattern: [[skill architecture beats skill writing when memory contracts and learning loops connect the system|Learning Loops]]

After every campaign outcome, creative test, or operational lesson:

1. **Append to `learnings-log.md`** in the relevant brand's `Brand/` folder
2. Use the standard format:
   ```
   ## YYYY-MM-DD | Category | Short Title
   - Stage: (pipeline stage or activity)
   - Result: a (shipped as-is) / b (minor edits) / c (rewrote significantly)
   - Outcome: (metrics if available)
   - Lesson: (what to repeat or avoid)
   - Tags: (relevant enum tags)
   ```
3. **Never edit or truncate** existing entries
4. **Weekly synthesis:** BananaBanker reads raw learnings and updates `creative-kit.md` with durable patterns. Raw log stays; creative-kit gets curated.

## 5. Degradation Rules

- **Missing brand file:** Proceed with reduced context. Don't fail. Note what's missing in output.
- **Missing learnings-log:** Create it with the standard header.
- **Missing context-manifest:** Load all brand files. Log a warning.
- **Stale data (> TTL):** Flag in output: "Note: [file] is [N] days old — may be outdated."
- **Schema validation failure:** Don't publish. Flag the issue. Fix before proceeding.

## 6. Agent Boundaries

- **Brand managers** (e.g., tableclay-manager) own brand-specific context (voice, positioning, audience, products).
- **BananaBanker** owns cross-brand marketing infrastructure (creative-kit, pipeline config, protocol).
- **Athena** maintains vault structure and MOCs but doesn't modify brand content.
- **Delphi** provides deep research on request — reads brand context, doesn't write to it.
- **No agent posts externally** (ads, social, email) without explicit human approval.

## 7. Brand Directory Structure

Every brand follows this structure:
```
Projects/Ecommerce/Business/{Brand}/Brand/
├── voice-profile.md        ← brand manager owns
├── positioning.md           ← brand manager owns
├── audience.md              ← brand manager owns
├── product-catalog.md       ← brand manager owns
├── creative-kit.md          ← bananabanker owns
├── learnings-log.md         ← append-only (all)
├── assets-registry.md       ← append-only (all)
└── context-manifest.yaml    ← bananabanker owns
```

New brands copy this structure. The protocol applies to all brands equally.

## Related

- [[skill architecture beats skill writing when memory contracts and learning loops connect the system]] — the source framework
- [[advertising works when a content farm feeds modular assets into an agent-driven assembly line]] — the 7-agent pipeline this protocol governs
- [[content systems beat content calendars when assets are modular tagged and agent-operable]] — modular asset philosophy
- [[recursive skill loops improve marketing outputs by generating scoring diagnosing and iterating until thresholds are met]] — the evaluate→iterate loop pattern
