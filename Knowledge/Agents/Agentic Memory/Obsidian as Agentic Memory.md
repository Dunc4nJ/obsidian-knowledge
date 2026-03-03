---
created: 2026-01-31
description: Philosophy reference synthesizing vault architecture pillars — why conventions exist and how they interact
source: internal
type: synthesis
---

The vault is external knowledge infrastructure for AI agents. Agents do not run inside it — they access it via the `obsidian` skill when they need to read context, write learnings, or navigate project knowledge. What makes this work is a simple structural fact: a folder of markdown files with wiki links is already a knowledge graph an LLM can traverse. The same patterns that make codebases navigable — consistent naming, clear hierarchy, explicit conventions — apply directly to knowledge bases. The vault gives agents persistent memory that compounds across sessions, projects, and domains.

This note synthesizes [[progressive disclosure filters force agent selectivity over what enters context]], [[inline annotations beat copy-paste editing by keeping instructions where they belong]], [[transcript mining turns meetings into captured decisions and extracted knowledge]], and [[git hooks as thinking journal let you time-travel through note evolution]], with additional patterns from ltOgt/mono and earlier source material on vibe note-taking and tools-for-thought lineage.

## 1. The vault as knowledge graph

Markdown files are nodes. Wiki links are edges. YAML frontmatter is queryable metadata. This gives you a graph database that any LLM can move through natively, no special tooling required. The [[PARA and atomic facts give AI agents durable structured memory|PARA + atomic facts architecture]] takes this further by organizing entities into PARA directories with structured JSON fact stores that support memory decay and tiered retrieval.

The key structural decision is how you write links. Weaving `[[quality is the hard part]]` into a sentence forces the link to carry argumentative weight, not just reference weight. Titles written as claims rather than topics make the graph readable before any file is opened, because the link text itself is an assertion the agent can reason about. `[[quality is the hard part]]` tells you something; `[[quality-notes]]` tells you nothing.

Notes must be composable: each one stands alone so any link destination makes sense without requiring three other notes first. Think lego blocks, not chapters.

The vault uses a three-layer navigation system, and each layer serves a different purpose:

**Hierarchical folders** provide physical organization visible in file explorers and tree hooks. Projects nest by domain — `Projects/Ecommerce/Business 1/`, `Projects/Ecommerce/Business 2/` — so the folder structure itself communicates relationships. An agent looking at the tree immediately sees scope and grouping.

**MOCs (Maps of Content)** at each level provide conceptual navigation. A project MOC tells an agent what matters: current status, key decisions, links to important notes, open questions. MOCs are the first thing an agent reads when entering a new area. They are orientation hubs, not exhaustive indexes.

**Wiki links woven inline** form the semantic web connecting everything across folder boundaries. Because links sit inside sentences carrying argumentative weight, they encode reasoning relationships — not just "these are related" but "this matters because of that." The link network is how knowledge crosses project boundaries.

These three layers — folders for structure, MOCs for orientation, inline links for meaning — give agents two independent navigation paths (folder traversal and link traversal) plus a conceptual map at every level.

## 2. Progressive disclosure for context curation

Agents should not read everything. [[progressive disclosure filters force agent selectivity over what enters context]] defines a four-layer filter that forces selectivity:

1. **File tree** injected at session start via hook, giving the agent a map before it explores
2. **YAML descriptions** scanned with ripgrep to decide relevance without opening files
3. **Outline** via heading grep to identify which sections matter
4. **Full content** loaded only for notes that passed all three prior filters

This mirrors MCP tool discovery: tool list, tool search, tool references, full definitions. Most decisions can be made at the description level. When the agent has to justify each read, it curates better.

## 3. Skill-delivered conventions

Agents don't run in the vault, so the vault's CLAUDE.md is never auto-loaded during their sessions. Instead, conventions travel via the `obsidian` skill. The skill carries the essentials: vault structure, navigation protocol, note-writing rules, search commands. Depth lives in vault notes — this synthesis note explains the reasoning behind conventions, so agents that need to exercise judgment can read it.

This layering is deliberate. The skill handles mechanics (how to search, where to write, what frontmatter to include). Vault notes handle philosophy (why claim-based titles, why composability matters, why progressive disclosure). An agent following the skill's rules will produce correct notes. An agent that also reads this note will produce better ones, because it understands the intent behind the rules.

**Externalization as design principle.** Everything meaningful must persist to files. Conversations are ephemeral — when a session ends, everything discussed evaporates unless it was written down. The vault is canonical state. Files are the record. This is not just a preference but a structural requirement: agents have no memory between sessions except what the vault holds. Biasing toward capture ensures the knowledge graph grows. Capture first; curate later. The vault is one of [[four memory layers serve different knowledge types]] — it holds declarative knowledge (what's true and why), while CASS holds episodic memory (raw sessions), CM holds procedural rules (behavioral constraints), and ms holds reusable skills (compound workflows). Each layer extracts a different knowledge type from the same session material.

**Capture vs. curation spectrum.** Different vault purposes demand different positions on this spectrum. Thinking vaults optimize for depth — fewer notes, higher quality, extensive cross-linking. Operational vaults optimize for coverage — capture decisions, status changes, learnings quickly, even if the prose is rough. This vault uses a hybrid approach: capture aggressively into project folders (decisions, status, raw learnings), then curate when an insight is significant enough to become a standalone learning note with dense linking. The hybrid gives both capture speed and curation quality downstream.

**Three-tier rule cascade.** Agent behavior is shaped by three layers of rules, each more specific:

1. **Skill** — global conventions that apply everywhere (frontmatter requirements, naming rules, navigation protocol)
2. **Knowledge notes** — cross-cutting patterns shared across projects (this synthesis note, methodology notes)
3. **Project MOC** — project-specific decisions, status, and context that override general patterns where needed

An agent reads the skill first, then navigates to the relevant project MOC. The cascade means general rules don't need to be repeated in every project, but project-specific needs can override them.

**Meta feedback loop.** When agent behavior misses expectations — a note gets filed in the wrong place, a MOC isn't updated, frontmatter is missing — the response is not just to fix the instance but to identify the missing or unclear rule and add it. This compounds: every correction improves the system for all future sessions across all projects. A vault with six months of feedback-driven corrections behaves fundamentally differently from one designed only at inception. The system's conventions evolve through observed failures, not just upfront design.

## 4. Self-engineering and tools-for-thought lineage

The tools-for-thought lineage connects agentic memory to centuries of human knowledge systems: Llull's combinatorial wheels, Bruno's memory palaces, Luhmann's zettelkasten, evergreen notes, MOCs. All were tools to think WITH, not just store IN. The difference now is that the operator is itself an agent that can extend the system it operates.

The self-engineering loop: feed the system research on tools for thought, let it extract claims as notes, then apply those claims to how agents work. Observations persist in learning files. The system reflects on its own methodology and adjusts its instructions. Every rule starts as a hypothesis.

Claude adapted the Cornell Notes 5Rs into a 6-phase agent pipeline: `/reduce` (extract claims), `/reflect` (find connections), `/reweave` (update old notes), `/recite` (verify descriptions enable retrieval), `/review` (health checks), `/rethink` (challenge assumptions against evidence).

Structured reflection is the concrete extraction mechanism that makes this loop operational. The `obsidian-reflect` skill extracts key learnings from agent work as standalone notes — each densely linked to source material and related concepts, filed in the relevant project folder or in Knowledge/ for cross-cutting insights. This is the primary way knowledge flows INTO the vault from agent work. Raw session transcripts are not persisted; instead, the reflect skill produces the useful artifacts directly: claims as notes, linked and filed, ready to compound.

## 5. Transcript mining as knowledge capture

[[transcript mining turns meetings into captured decisions and extracted knowledge]] reframes meetings from overhead into primary knowledge capture. The core distinction is mining versus summarizing: a one-hour meeting can yield 10+ feature ideas, multiple frameworks, project state changes, and philosophy extractions. A 3-bullet summary leaves most of this on the floor.

The processing pipeline hunts for explicit and implicit content: feature ideas, decisions, philosophies, status changes, blockers, and frameworks. Implicit content matters most, like ideas embedded in problem discussions or decisions made by NOT deciding.

The vault state synchronization step is critical: after processing, read each project hub, identify discrepancies between hub state and meeting discussion, then update the vault to match post-meeting reality. The vault should reflect what is true now, not what was true before the meeting.

This also addresses tacit knowledge. When people talk through problems they naturally include reasoning paths, uncertainties, and alternatives they considered. Transcripts externalize what you cannot write down because you do not know you are doing it.

## 6. Spatial editing with inline annotations

[[inline annotations beat copy-paste editing by keeping instructions where they belong]] inverts the standard editing flow. Instead of copying text to the agent with instructions, you leave `{edit instructions}` inline where they belong. Position is context: the annotation knows what it refers to because of where it lives.

The `/edit` command processes these annotations in place, resolving each one against its surrounding text. This works across multiple files and eliminates the back-and-forth of pointing the agent at specific paragraphs. When no file is specified, ripgrep finds all `{annotations}` across the vault.

## 7. Git as thinking journal

[[git hooks as thinking journal let you time-travel through note evolution]] adds a temporal dimension. Async hooks auto-commit after every edit without blocking the agent. The raw git history captures every version of every note, but diffs alone are useless without interpretation.

The `/note-history` skill reads the commit log for a note, diffs each version, and interprets what changed conceptually. It identifies evolution patterns: a note that started as research extraction, developed practical implications, connected to related concepts, and added epistemic caveats. The history becomes a journal of how thinking developed, written automatically.

This turns the vault into a timeline you can reconstruct at any point, node by node.

## 8. Note metadata and naming

The vault uses a minimal prefix system. Only three types benefit from filename-level identification:

- `meta -` for system and workflow files
- `moc -` for maps of content (navigation hubs)
- `learning -` for extracted insights from agent work

All other notes use clean, claim-based titles. The title IS the argument: `quality is the hard part.md` tells you something before you open the file. `quality-notes.md` tells you nothing. Readable prose titles make the link network self-documenting — when you see `[[quality is the hard part]]` woven into a sentence, both the link destination and the argumentative claim are immediately clear.

Every note carries YAML frontmatter with at minimum:

```yaml
---
created: YYYY-MM-DD
description: One sentence that enables progressive disclosure without opening the file
---
```

Optional fields include `type` (decision, question, framework, learning) and `source` (where the content originated). The `description` field is essential for the progressive disclosure pipeline — it's what an agent reads at layer 2 to decide whether to open the full note. A good description makes most full-file reads unnecessary.

## 9. Drift detection via review

Documented intent drifts from reality over time. MOCs stop reflecting what actually exists. Project statuses go stale. Decisions get contradicted by new notes without anyone noticing. Periodic review catches this semantic drift through three checks:

**MOC currency** — Do MOCs reference notes that actually exist? Are there notes in a folder that no MOC links to? Missing links mean the navigation layer has gaps; dead links mean the structure has changed without updating the map.

**Status currency** — Do project status sections reflect current reality? A project MOC that says "Active work: implementing auth" when auth shipped two weeks ago misleads every agent that reads it. Statuses must match the actual state of work.

**Decision adherence** — Are documented decisions being followed? If a project MOC records "chose JWT for auth" but recent notes discuss session-based auth without acknowledging the change, there is unresolved drift. Either the decision changed (update the MOC) or the notes are wrong (correct them).

This is different from structural health checks (broken links, orphan notes). Drift detection checks semantic consistency — whether the vault's claims about itself are true. Review accepts a folder path argument to scope the check to a specific area rather than requiring a full vault sweep.

## 10. The operating model

These pillars combine into a specific way of working:

- The human role is editor and curator. Direct the system, provide judgment, decide what matters. The shift is from writer to director — you shape what the agents produce rather than producing it yourself.
- The agent infers which project it is working on from the task at hand, reads that project's MOC for context, and follows conventions delivered by the skill. No explicit project-switching commands needed — the task naturally implies which project is relevant.
- MOCs accumulate navigation links as the vault grows. New notes get linked from their project MOC. New learnings get linked from both the project MOC and the root MOC if they are cross-cutting. The vault's map evolves with its content.
- Everything is plain text. The vault survives any app disappearing. Obsidian, VS Code, grep, or a future tool none of us have heard of — the data remains accessible. Full data ownership, zero lock-in.
- Knowledge bases and codebases are structurally similar. They are both folders of text files with relationships between them, both have conventions and patterns, and both benefit from agents that can navigate and operate them systematically.
