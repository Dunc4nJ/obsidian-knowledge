---
created: 2025-07-17
description: Plan to integrate boringmarketer's 5 skill architecture patterns into the BananaBank multi-agent content pipeline.
source: internal
type: plan
---

# Integrating Skill Architecture into BananaBank

## Context

@boringmarketer's 5 patterns (persistent memory, scored context loading, schema contracts, learning loops, shared protocol) were designed for a single-user, multi-skill system. BananaBank is a multi-agent, code-driven pipeline backed by a shared Obsidian vault. This plan maps each pattern to our actual architecture.

**Key insight from subagent exploration:** BananaBank is a **TypeScript microservice system** (Prisma, BullMQ, Docker), not an agent swarm. The 7 pipeline stages (Ingest → Ideation → Draft → Compose → Validate → Judge → Finalize) are code workers. BananaBanker operates the system; individual pipeline stages are not separate AI agents. The vault serves as the knowledge layer, not the runtime data store.

## Current State

### What Exists
- **Full pipeline codebase** at `/data/projects/bananabank/` — Prisma schema (50+ models, 14+ enums), Docker Compose (12 services), worker stubs for all stages
- **Three spec documents** (SPEC.md v3.0, SPEC_2.md implementation contract, SPEC_3.md de-scoped MVP)
- **Tag system** fully specified — JSON Schema tag dictionary with all enums, canonical creative tag bundle, filename convention
- **14 Knowledge/Ecommerce notes** covering the complete strategic framework
- **Relevant agents:** BananaBanker (operator), TableClay Manager (brand-level), Delphi (oracle/research), Athena (vault maintenance)

### What's Missing
- No feedback/learning loop from ad performance back to ideation
- No context scoping — agents load everything or nothing
- No shared protocol governing how agents read/write brand data
- Pipeline workers are stubs — no end-to-end flow running yet
- No brand context files (voice, positioning, audience) in structured form

## The 5 Patterns → BananaBank Implementation

### 1. Persistent Memory with Ownership

**What it means for us:** Brand context lives in the vault, with ownership at the brand-manager level, not the pipeline level.

**Implementation:**

```
Projects/Ecommerce/{BrandName}/Brand/
├── voice-profile.md       ← {BrandName} Manager owns (overwrite)
├── positioning.md          ← {BrandName} Manager owns (overwrite)
├── audience.md             ← {BrandName} Manager owns (overwrite)
├── product-catalog.md      ← {BrandName} Manager owns (overwrite)
├── creative-kit.md         ← BananaBanker owns (overwrite)
├── learnings-log.md        ← append-only (Measurement stage + any agent)
└── assets-registry.md      ← append-only (Compose/Finalize stages)
```

**For TableClay specifically:**
```
Projects/Ecommerce/TableClay/Brand/
├── voice-profile.md       ← TableClay Manager owns
├── positioning.md          ← TableClay Manager owns
├── audience.md             ← TableClay Manager owns
├── product-catalog.md      ← TableClay Manager owns
├── creative-kit.md         ← BananaBanker owns
├── learnings-log.md        ← append-only
└── assets-registry.md      ← append-only
```

**Ownership rules (frontmatter):**
```yaml
---
owner: tableclay-manager
write_policy: overwrite  # or "append-only"
last_updated: 2025-07-17
---
```

**Why this differs from boringmarketer:** His skills share one brand. We have multiple brands, each with a manager agent. The brand manager owns brand-specific context; BananaBanker owns cross-brand marketing infrastructure.

### 2. Scored Context Loading

**What it means for us:** Each pipeline stage (code worker) and each agent loads only the context that sharpens its output.

**Context matrix:**

| Pipeline Stage / Agent | Full Load | Summary Only | Exclude |
|---|---|---|---|
| **Ideation worker** | VoC/audience.md, learnings-log.md (last 30 days), creative-kit.md | positioning.md | Raw platform metrics, compliance logs |
| **Draft worker** | Angle brief (from ideation), voice-profile.md, proof cards | audience.md summary | Campaign config, performance data |
| **Compose worker** | Concept card, module clips, proof cards, templates | Historical concept performance | Raw VoC, compliance |
| **Validate/Judge** | Script, all proof cards, brand guardrails | Brand guidelines | Performance metrics, raw assets |
| **BananaBanker** | creative-kit.md, learnings-log.md, performance summaries | All brand files | Raw asset files |
| **TableClay Manager** | All TableClay Brand/ files, product catalog | Learnings-log.md | Other brand data |

**TTL freshness rules (convention, not runtime):**

| Data Type | < 7 days | 7-30 days | 30-90 days | > 90 days |
|---|---|---|---|---|
| VoC / audience | Full | Full | Full | Summary (shifts slowly) |
| Performance data | Full | Full (tactical) | Summary (strategic) | Archive |
| Proof cards | Full (no TTL) | Full | Full | Full (until product changes) |
| Learnings | Full | Full | Summary | Archive |
| Brand voice/positioning | Full | Full | Full | Full (changes rarely) |

**Implementation:** Add a `context-manifest.yaml` to each Brand/ folder that maps which files each consumer should load. Pipeline workers read this manifest before pulling vault context via qmd.

```yaml
# context-manifest.yaml
consumers:
  ideation:
    full: [audience.md, creative-kit.md]
    summary: [positioning.md]
    ttl_override:
      learnings-log.md: 30d
  draft:
    full: [voice-profile.md]
    summary: [audience.md]
  compose:
    full: [creative-kit.md]
    exclude: [audience.md, positioning.md]
```

### 3. Schema Contracts Between Pipeline Stages

**What it means for us:** This is already the core BananaBank design. The tag system IS the schema contract.

**What exists:**
- ConceptCard → ProofCard → ModuleClip → Asset → VariantSet (4-entity object model)
- JSON Schema tag dictionary with enum enforcement
- Prisma models encoding all entities
- Filename convention as parseable encoding

**What's missing (the gap):**
- The vault knowledge notes describe the schema but the vault itself doesn't contain live schema artifacts. The schemas live in code (Prisma) and specs.
- No contract between vault knowledge and code schemas — if the tag dictionary updates in code, the vault note gets stale.

**Integration action:**
1. The vault tag dictionary note should be auto-generated from the canonical source (the JSON schema in the codebase), not manually maintained
2. Add a `schemas/` directory to the BananaBank project in the vault that mirrors the canonical schemas:
```
Projects/Ecommerce/BananaBank/schemas/
├── concept-card.schema.json   (symlink or copy from codebase)
├── proof-card.schema.json
├── tag-dictionary.json
└── pipeline-contracts.md       (human-readable summary of stage inputs/outputs)
```
3. The `pipeline-contracts.md` is the human-readable version that agents read; the JSON schemas are what code validates against.

### 4. Learning Loops

**What it means for us:** Performance outcomes feed back to ideation. The system compounds.

**Implementation — two levels:**

**Level 1: Append-only learnings log (vault, immediate)**
```
Projects/Ecommerce/{Brand}/Brand/learnings-log.md
```

Format:
```markdown
## 2025-07-17 | Ad Creative | Hook test - ASMR vs Direct
- Stage: Finalize → Performance
- Result: b (minor edits needed)
- Outcome: ASMR hook 2.3x CTR vs direct hook on TOF
- Lesson: ASMR hooks outperform for TOF awareness; direct hooks better for BOF retargeting
- Tags: hook_style:asmr, funnel:tof, product:mini-wheel
```

**Level 2: Performance-to-ideation feedback loop (code, later)**
- The Measurement worker (performance-backfill) already exists as a stub
- Wire it to: (a) update asset performance in Prisma, (b) append to vault learnings-log.md
- The Ideation worker reads learnings-log.md at the start of every run
- Over time: winning angles, hooks, proof types accumulate as structured data

**Level 3: Periodic synthesis (agent, periodic)**
- BananaBanker periodically (weekly heartbeat or cron) reads the raw learnings-log and synthesizes patterns into the creative-kit.md
- "ASMR hooks consistently outperform for TOF across all products" becomes a durable creative-kit entry
- Raw log stays append-only; creative-kit gets curated updates

### 5. Shared Protocol Layer

**What it means for us:** One document governing how all agents and workers interact with brand data in the vault.

**Implementation: `Projects/Ecommerce/BananaBank/PROTOCOL.md`**

Contents:
```markdown
# BananaBank Protocol v1

## File Ownership
- Files with `owner: <agent>` frontmatter can only be overwritten by that agent
- Files with `write_policy: append-only` can be appended to by any authorized agent/worker
- Before overwriting an owned file, show diff and get confirmation

## Context Loading
- Read context-manifest.yaml for your role before loading brand files
- Apply TTL rules from the manifest (default: 30 days full, 90 days summary, >90 archive)
- Never load excluded files — they add noise, not signal

## Schema Compliance
- All creative assets must conform to the tag dictionary schema
- Concept cards, proof cards, and assets must validate against JSON schemas in schemas/
- If a new tag value is needed, propose it — don't use free text

## Learning Loops
- After every campaign/creative outcome, append to learnings-log.md
- Format: date | category | description, then Result/Outcome/Lesson/Tags
- Never edit or truncate learnings — append only

## Degradation
- If a brand file is missing, proceed with reduced context (don't fail)
- If learnings-log doesn't exist, create it
- If context-manifest doesn't exist, load all brand files (legacy behavior)
- Flag stale data (> TTL) in output: "Note: audience data is 45 days old"

## Agent Boundaries
- Brand managers own brand-specific files
- BananaBanker owns cross-brand infrastructure (creative-kit, pipeline config)
- Athena maintains vault structure but doesn't modify brand content
- No agent posts externally without human approval
```

## Implementation Phases

### Phase 1: Brand Context Scaffolding (now, 1-2 hours)
1. Create `Projects/Ecommerce/TableClay/Brand/` directory with skeleton files
2. TableClay Manager fills in voice-profile, positioning, audience, product-catalog
3. BananaBanker creates creative-kit.md from existing Knowledge/Ecommerce notes
4. Create empty learnings-log.md and assets-registry.md
5. Write context-manifest.yaml
6. Write PROTOCOL.md

### Phase 2: Wire Learning Loops (next session)
1. Set up learnings-log.md format and start manually logging
2. Add a BananaBanker cron/heartbeat task to synthesize learnings weekly
3. Ensure ideation stage reads learnings on every run

### Phase 3: Context Scoping in Pipeline (when pipeline runs E2E)
1. Workers read context-manifest.yaml before querying vault
2. TTL checking on vault reads
3. Per-stage context budgets enforced

### Phase 4: Schema Sync (when tag dictionary changes)
1. Auto-generate vault schema notes from codebase canonical source
2. CI check that vault schemas match code schemas

## Open Questions
- Should context-manifest.yaml live in the vault or the codebase? (Vault = agents edit it; codebase = versioned with code)
- Do we need a formal schema registry beyond the vault + Prisma, or is that over-engineering?
- How does Delphi (oracle/research) fit into the learning loop? Can it run deep analysis on accumulated learnings?
