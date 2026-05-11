---
created: 2026-05-11
description: Series index for Ashwin Gopinath's 8-part Company Brain thesis (Sentra) — a layered architecture for organizational memory where factual + interaction + action memory share one semantic substrate and ontologies sit above as lenses, positioned as the next AI infrastructure layer beneath every app and agent.
type: moc
---

# Company Brain — Ashwin Gopinath series (Sentra)

An 8-part series by [Ashwin Gopinath](https://x.com/ashwingop), founder of [Sentra](https://www.sentra.app/), arguing that the next AI infrastructure layer is not a smarter assistant but a **Company Brain** — a living, permissioned model of how an organization remembers, reasons, and acts.

The thesis arc is sequential: Part 1 defines the four-way intersection (factual + interaction + action + human communication), Parts 2-4 decompose the three memory layers, Part 5 collapses them into one shared semantic substrate, Part 6 gives the founder retrospective, Part 7 separates substrate from ontological lens, and the capstone positions the whole stack against Claude Managed Agents, MCP, and the markdown-brain prototypes.

## Series in order

1. **[[Company Brain Part 1 - Why Most Companies Have Data But No Memory]]** *(2026-04-30)* — Defines Company Brain as a four-way intersection of factual memory + human communication + context graph + governed action. Companies accumulate fragments faster than they turn them into memory; young companies that grow up with memory + reasoning + action as primitives will have a structural advantage over established companies retrofitting AI onto scattered context.

2. **[[Company Brain Part 2 - Factual Memory]]** *(2026-04-30)* — Factual memory is not a wiki, shared drive, or RAG-over-enterprise-data layer — it's a semantic file system whose primitives are relationships, not blobs, built from the individual outward through emergence. A knowledge base waits; memory participates.

3. **[[Company Brain Part 3 - Interaction Memory]]** *(2026-05-03)* — Interaction memory is "the chain of thought of the organization" — the trace of how a group moves from partial information to judgment, captured *before* artifacts exist. Ontology is "perspective": the same sentence means different things to product, legal, sales, and a CEO; a static note archive can't carry that.

4. **[[Company Brain Part 4 - Action Memory]]** *(2026-05-04)* — Action memory decomposes "workflow" into procedural / trigger / execution / outcome memory. The most important thing the action layer can do is *deliberately do nothing* — if it cannot stay still on purpose, it cannot be trusted to act on purpose. This is the agentic layer, where agents attach naturally.

5. **[[Company Brain Part 5 - Memory Is State, Not a Service]]** *(2026-05-05)* — The architectural center: memory must be shared state, not a feature inside individual tools. Primitives are entities, facts, state changes, and typed relationships. Ontologies sit *above* as lenses, not *below* as schemas — the bet is that the substrate generalizes across verticals while the lenses do not.

6. **[[Company Brain Part 6 - Lessons From Building a Company Brain]]** *(2026-05-06)* — Year-one retrospective. The failed first idea ("agent polls everyone") taught Sentra that company truth is created in the work itself, not reported. Ontology became central not by design but because the same conversation kept meaning different things. The surprising operational lesson was *latency* — pace, not automation, is what changes.

7. **[[Company Brain Part 7 - Claude Made Agent Memory Real but Semantics and Ontology Are Still Missing]]** *(2026-05-07)* — Claude Managed Agents memory is the right substrate primitive but a place to remember ≠ memory that understands. Semantics says what something is; ontology says why it matters from a perspective. Custom ontologies per function — not one assistant per company — are the real path to adoption. The falsifiable 18-month bet: the metric to watch is decision-to-action conversion, not AI usage.

8. **[[Company Brain Capstone - Claude Managed Agents Point to the Next AI Infra Layer]]** *(2026-05-08)* — Apps sit on top; Company Brain is the infra layer beneath. The AWS lesson: companies should own ontology + policy + judgment but not the substrate. Markdown brains (GBrain, Karpathy's LLM Wiki) are personal-scale prototypes that hit a wall at organizational scale because of permissions, ontology, and concurrency. Tool access (MCP) is necessary but is query-time context, not maintained state.

## The thesis in one paragraph

Companies don't fail at AI because they lack data — they fail because they lack memory of *why* the data means what it means. A Company Brain is the substrate that holds factual memory (what happened), interaction memory (what people meant), and action memory (what was done) as three views of one shared state, with ontologies sitting above as per-role lenses. It is infrastructure, not an app. The companies that win the next 18 months will be the ones that close the loop between meetings and work, commitments and follow-through, strategy and execution — the metric is *how often the company successfully does the thing it decided to do*, not how much AI it uses.

## Related vault notes

The Company Brain thesis sits at the intersection of several threads already represented in this vault:

- [[Obsidian as Agentic Memory]] — the personal-scale prelude to organizational memory substrates
- [[four memory layers serve different knowledge types]] — agent-level analog to the factual/interaction/action layered split
- [[a file system is not all you need - databases beat markdown for agent context provenance and governance]] — the same scaling wall Gopinath describes for markdown brains
- [[every app that avoids a database ends up rebuilding one badly]] — why files alone aren't enough at scale
- [[multi-agent memory needs computer architecture style hierarchy and consistency models]] — the multi-writer concurrency problem at agent scale
- [[The Price of Meaning prescribes coupling semantic retrieval with exact episodic grounding as the only escape from interference]] — Sentra's earlier no-escape theorem, the formal proof underneath the substrate argument
- [[Letta Context Constitution frames context as the substrate of agent identity memory and continuity beyond model weights]] — the parallel "one substrate, many surfaces" bet at the agent level
- [[Hermes, Codex, and Claude Code converge on markdown plus filesystem tools because memory is a judgment problem not a data structure problem]] — the agent-tool convergence Gopinath builds organizational memory on top of
- [[Karpathy and Omarsar converge on Obsidian-backed LLM knowledge bases as the critical layer for agent effectiveness]] — the markdown-wiki school the capstone positions as personal-scale prototype
- [[context graphs let agents build verifiable, cross-agent memory instead of isolated notes]] — the context-graph thesis at agent scale
- [[most agent bottlenecks are actually memory problems not model or orchestration problems]] — the agent-side mirror of the Part 1 organizational claim

## Source thread

Capstone tweet thread (parent of the series): https://x.com/ashwingop/status/2052777467732283817
