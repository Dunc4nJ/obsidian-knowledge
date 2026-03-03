---
created: 2025-07-17
description: Five architectural patterns that turn isolated AI marketing skills into a compounding system — persistent memory, scored context loading, schema contracts, learning loops, and a shared protocol layer.
source: https://x.com/boringmarketer/status/2024265175575015599
type: framework
---

@boringmarketer built 11 marketing skills (32,000 lines) and found the skills themselves were the easy part. The architecture around them — how they share memory, pass data, and learn — is what moved the needle. Five patterns that turned isolated skills into a compounding marketing system.

## Key Takeaways

- **Persistent memory with ownership rules** solves the "re-explain everything every session" problem. A shared brand directory where each file has one owner skill (voice-profile.md owned by /brand-voice, positioning.md by /positioning, etc.) plus append-only files (assets.md, learnings.md) that never truncate. This maps directly to how [[content systems beat content calendars when assets are modular tagged and agent-operable|modular content systems]] should work — durable state across sessions.
- **Scored context loading** is counterintuitive but critical: giving a skill *all* available context produces worse output than giving it *only relevant* context. A context matrix scores what each skill receives vs. withholds. Plus TTL-based freshness rules: <7 days = pass as-is, 7-30 days = flag age, 30-90 days = summary only, >90 days = don't load. Attention is finite — treat it that way.
- **Schema contracts between skills** (6 JSON Schemas) turn skills from isolated tools into pipeline nodes. /keyword-research outputs a typed keyword plan that /seo-content consumes directly. No copy-pasting between sessions. This is the [[advertising works when a content farm feeds modular assets into an agent-driven assembly line|content assembly line]] principle applied to the skill layer.
- **Learning loops** with a dead-simple feedback mechanism: after every deliverable, ask "how did this perform?" (shipped as-is / minor edits / rewrote significantly). Logged, date-stamped, skill-tagged. Next session reads past learnings. Session 1 teaches session 5. The system compounds.
- **One shared protocol layer** (single doc) governs how all 11 skills read/write brand files, handle staleness, collect feedback, and degrade gracefully when files are missing. No runtime enforcement — skills just follow the spec "like HTTP." System-wide coherence from one document.
- The compounding curve is the key insight: Day 1 = useful output with zero context. Day 7 = better (voice, positioning loaded). Day 14 = fully personalized (learnings, full brand kit). Each layer adds quality, none is required. Graceful degradation by design.

## The 5 Architectural Patterns

### 1. Persistent Memory

Shared brand directory with ownership rules:

- `voice-profile.md` ← /brand-voice owns
- `positioning.md` ← /positioning owns
- `audience.md` ← /audience-research owns
- `keyword-plan.md` ← /keyword-research owns
- `assets.md` ← all skills append
- `learnings.md` ← all skills append

Profile files have one owner — only that skill can overwrite (with diff and confirmation). Append files never truncate, only grow.

### 2. Scored Context Loading

Context matrix that scores what each skill receives vs. what's withheld. Plus TTLs on freshness:

- < 7 days → pass as-is
- 7-30 days → flag the age
- 30-90 days → summary only
- \> 90 days → don't load (stale)

### 3. Schema Contracts Between Skills

6 JSON Schema contracts. Skills output structured artifacts that other skills consume. /keyword-research outputs a keyword plan → /seo-content reads that plan as input. No re-explaining, no copy-pasting.

### 4. Learning Loops

After every major deliverable:

> How did this perform?
> a) shipped as-is
> b) minor edits
> c) rewrote significantly

Answers logged with date stamp and skill tag. Next session reads learnings. Mistakes made once, wins repeat forever.

### 5. Shared Protocol Layer

One protocol document all 11 skills follow. Defines:
- How to read/write brand files
- When context is too stale to use
- How to collect feedback
- How to degrade when files are missing

No runtime enforcement — skills follow the spec like HTTP.

## External Resources

- @boringmarketer's marketing skills (v2) — mentioned 700+ copies sold of v1, v2 adds orchestration layer
- Also built an OpenClaw version

## Original Content

> [!quote]- Full post by @boringmarketer (Feb 18, 2026)
> **@boringmarketer** — i stopped writing better skills and started building skill architecture. most people think an ai skill is a well-written instruction file... the skill file is the starting point. the architecture around it is what makes it actually perform over time.
>
> Notable reply from @houstongolden: "Skill Architecture is key. They have to be self-learning and evolving and tied to the memory and decision trees. shit is moving so fast, skills can't be static files."
>
> [Full post →](https://x.com/boringmarketer/status/2024265175575015599)
