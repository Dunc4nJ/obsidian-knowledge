---
created: 2026-01-31
description: Agent infrastructure uses four memory systems — CASS (episodic), CM (procedural), ms (skill), and the vault (declarative) — each serving a different knowledge type from the same session material
source: internal
type: framework
---

# Four memory layers serve different knowledge types

Agent work happens in sessions. Sessions are ephemeral — when a conversation ends, everything discussed evaporates unless it was captured. Four systems extract different knowledge types from that ephemeral work, and each serves a distinct purpose that the others cannot replace.

```
Agent work session (ephemeral)
       │
       ├──→ CASS       (episodic)     what happened
       │       │
       │       ├──→ CM        (procedural)   how to behave
       │       ├──→ ms        (skill)        how to do things
       │       └──→ vault     (declarative)  what's true
       │
       └──→ (session ends, conversation gone)
```

CASS is the raw material. CM, ms, and the vault are three different refinement pipelines that produce three different knowledge types. Understanding when to use which — and how they feed each other — is what makes the full system work.

## CASS — episodic memory

**What it stores**: Raw agent session transcripts. Every conversation between a human and an agent, indexed and full-text searchable.

**Tool**: `cass` CLI (Coding Agent Session Search).

**Key commands**:
- `cass search "query"` — keyword search across all past sessions
- `cass search "query" --days 30` — time-bounded search
- `cass search "query" --workspace /path` — project-scoped search
- `cass view <path> -n <line>` — read surrounding context of a search hit
- `cass index --watch` — background watcher that indexes new sessions as they appear

**What makes it useful**: CASS answers "has anyone done this before?" It finds the exact conversation where a problem was solved, a decision was made, or an approach was tried and failed. The signal-to-noise ratio is low — you're searching through raw conversation fragments — but the coverage is complete. Nothing is lost.

**What it cannot do**: CASS doesn't extract patterns, rules, or insights. It stores everything but understands nothing. It's a haystack with a good search engine.

**Maintenance**: Run `cass index --watch` as a background process so new sessions are indexed automatically. Periodically run `cass index --full` to catch anything the watcher missed.

## CM — procedural memory

**What it stores**: Behavioral rules. Short imperative statements that shape how agents act: "always do X", "never do Y", "when X happens, do Y." The collection of rules is called the playbook.

**Tool**: `cm` CLI (Cass Memory).

**Key commands**:
- `cm context "task description" --json` — get relevant rules for a task (run at session start)
- `cm playbook add "rule" --category X` — add a single rule
- `cm playbook add --file rules.json` — batch-add rules
- `cm mark b-xxx --helpful` — record that a rule helped (feedback loop)
- `cm onboard sample` — get sessions to analyze for rule extraction
- `cm onboard guided` — full agent-native onboarding workflow (no API key needed)
- `cm stats` — playbook health metrics
- `cm top 10` — most effective rules by feedback

**Rule categories**: debugging, testing, architecture, workflow, documentation, integration, collaboration, git, security, performance.

**What makes it useful**: CM rules are the fastest path to consistent agent behavior. When an agent starts a task and runs `cm context`, it gets a ranked list of relevant rules before writing any code. Rules compound — because [[Obsidian as Agentic Memory|the meta feedback loop]] adds rules whenever agent behavior misses expectations, the playbook improves with every session.

**What it cannot do**: Rules are too short to capture complex procedures. "Always validate before pushing" is a rule. The 15-step validation procedure with branching logic is not a rule — that's a skill.

**How it's populated**: Two paths:
1. **Agent-native** (no API key): Agent reads sessions via `cm onboard`, extracts rules, batch-adds them with `cm playbook add --file`
2. **LLM-automated** (needs API key): `cm reflect --days 7` mines recent sessions automatically

**Rule lifecycle**: draft → candidate → proven (through `cm mark` feedback). Rules that accumulate harmful feedback get pruned. Rules without recent feedback are surfaced by `cm stale`.

## ms — skill memory

**What it stores**: Reusable workflows. Structured, multi-step procedures extracted from repeated patterns across sessions. If CM rules are individual instructions, ms skills are complete playbooks for specific scenarios.

**Tool**: `ms` CLI (Meta Skill).

**Key commands**:
- `ms suggest` — context-aware skill suggestions for current work
- `ms search "query"` — find skills by topic
- `ms build --from-cass "query"` — mine CASS sessions into full skills
- `ms build --with-cm` — seed skill builds with CM rules as context
- `ms import <path>` — import skills from unstructured documents (markdown, system prompts)
- `ms cross-project patterns` — find patterns that repeat across different projects
- `ms cross-project gaps` — show where session patterns exist but no skill covers them
- `ms antipatterns mine` — extract what NOT to do from failure sessions
- `ms list` — list all indexed skills
- `ms load <skill>` — load a skill with progressive disclosure

**What makes it useful**: ms bridges the gap between CM's short rules and full documentation. A CM rule says "check both backend and frontend builds." An ms skill is the complete monorepo build verification procedure with exact commands, common failure modes, and recovery steps. Skills are also the mechanism for cross-project learning — patterns that work in one project get generalized into skills any project can use.

**What it cannot do**: Skills are procedural — they tell you how to do things. They don't explain why decisions were made, what the tradeoffs are, or how concepts relate to each other. That understanding lives in the vault.

**How it's populated**: Three paths:
1. **Build from CASS**: `ms build --from-cass "query"` mines sessions matching a pattern and composes a skill
2. **Import from documents**: `ms import <path>` converts existing documentation into skill format
3. **Manual creation**: Write SKILL.md files directly (what we do with the obsidian and obsidian-reflect skills in `~/.agent/skills/`)

**Integration with CM**: `ms cm context` pulls CM rules as context. `ms build --with-cm` uses rules to inform skill construction. They're complementary — rules provide the constraints, skills provide the procedures.

## Vault — declarative memory

**What it stores**: Structured knowledge about what is true. Project status, architectural decisions, frameworks, conceptual relationships, learnings. The vault is a knowledge graph — markdown files (nodes) connected by wiki links (edges) with YAML metadata.

**Tool**: `obsidian` skill + `qmd` CLI for search. The [[PARA and atomic facts give AI agents durable structured memory|PARA + atomic facts framework]] provides a concrete implementation architecture showing how vault-style declarative memory maps to PARA directories with tiered retrieval (summary.md for quick context, items.json for granular facts) and memory decay across hot/warm/cold tiers.

**Key commands**:
- `qmd search "query" -c obsidian` — keyword search
- `qmd vsearch "query" -c obsidian` — semantic search
- `qmd query "query" -c obsidian` — hybrid search with reranking
- Read `moc - Vault.md` for vault-wide orientation
- Read project MOCs for project-specific context

**What makes it useful**: The vault is the only layer that explains WHY. CASS records what happened, CM tells agents what to do, ms tells agents how to do it, but the vault holds the reasoning behind decisions. Because [[Obsidian as Agentic Memory|notes use claim-based titles woven inline as wiki links]], the vault is a semantic network an agent can traverse to build understanding, not just follow instructions.

**What it cannot do**: The vault doesn't shape agent behavior directly. An agent needs the `obsidian` skill to access it, and vault notes don't execute — they inform. An agent that only reads the vault knows a lot but has no procedural guidance. An agent that only reads CM rules acts consistently but lacks context for edge cases.

**How it's populated**: The `obsidian-reflect` skill extracts learnings from agent work as standalone notes, densely linked and filed in the appropriate project folder or Knowledge/ area. Learnings are the primary way knowledge flows from sessions into the vault.

## How they feed each other

The four layers aren't independent — they form a knowledge lifecycle:

1. **CASS captures everything**. Every session is indexed automatically.
2. **CM extracts behavioral rules** from sessions. Rules are short, fast, and shape immediate agent behavior.
3. **ms extracts reusable workflows** from sessions. Skills are compound procedures that codify how repeated tasks should be done.
4. **The vault extracts understanding**. Learning notes capture why things work, how concepts relate, and what decisions were made with what reasoning.

The feedback loops:
- CM rules that prove consistently helpful might indicate a pattern worth formalizing as an ms skill
- ms skills that keep getting modified suggest the underlying understanding needs a vault note explaining the reasoning
- Vault learning notes that describe procedures should be checked against ms — if no skill covers the procedure, one should be built
- `ms cross-project gaps` reveals where sessions contain patterns that no skill covers — those are candidates for both new skills and new vault learning notes

## When to use which

| Question | System |
|----------|--------|
| "Has anyone solved this before?" | CASS (`cass search`) |
| "What rules apply to this task?" | CM (`cm context`) |
| "How do I do this step by step?" | ms (`ms suggest`, `ms search`) |
| "Why was this decision made?" | Vault (`qmd search`, read MOC) |
| "What's the current project status?" | Vault (project MOC) |
| "What patterns repeat across projects?" | ms (`ms cross-project`) |
| "What should I avoid?" | CM (anti-patterns) + ms (`ms antipatterns`) |
| "What did we learn from this work?" | Vault (`obsidian-reflect` skill) |
