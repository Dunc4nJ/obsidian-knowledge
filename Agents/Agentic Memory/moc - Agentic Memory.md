---
created: 2026-02-28
description: Navigation hub for agentic memory — how agents store, retrieve, and evolve knowledge across sessions.
type: moc
---

# Agentic Memory

How agents store, retrieve, and evolve knowledge across sessions. Memory architectures, vault-as-memory patterns, state persistence, context survival across compaction.

## Notes

- [[Obsidian as Agentic Memory]]
- [[Obsidian wikilink resolution can be replicated on plain filesystems with an index and atomic rename tool]]
- [[PARA and atomic facts give AI agents durable structured memory]]
- [[four memory layers serve different knowledge types]]
- [[git hooks as thinking journal let you time-travel through note evolution]]
- [[inline annotations beat copy-paste editing by keeping instructions where they belong]]
- [[obsidian vaults become memory graphs when agents traverse wikilinked notes with claim-based titles and layered orientation]]
- [[progressive disclosure filters force agent selectivity over what enters context]]
- [[transcript mining turns meetings into captured decisions and extracted knowledge]]
- [[AMA-Bench evaluates long-horizon memory for agentic applications using real and synthetic trajectories]]
- [[indexed experience memory compresses LLM agent context without discarding evidence by pairing summaries with a dereferenceable archive]]
- [[a file system is not all you need - databases beat markdown for agent context provenance and governance]]
- [[every app that avoids a database ends up rebuilding one badly]]
- [[multi-agent memory needs computer architecture style hierarchy and consistency models]]
- [[most agent bottlenecks are actually memory problems not model or orchestration problems]]
- [[Hermes Agent prioritizes prompt caching stability by keeping hot memory tiny and pushing everything else to tool-based retrieval]]
- [[Claude Code memory has a silent 200-line index cap that drops old memories without warning]]
- [[Karpathy and Omarsar converge on Obsidian-backed LLM knowledge bases as the critical layer for agent effectiveness]]
- [[context graphs let agents build verifiable, cross-agent memory instead of isolated notes]]
- [[Everything Is Connected - knowledge graphs encode entities as directed-labeled triples that support multi-hop traversal and ontology-driven inference]]
- [[How to Make Knowledge Graphs Fast - query optimization combines triple indexing, adjacency compression, and partitioning to tame exponential traversal fan-out]]
- [[Hermes, Codex, and Claude Code converge on markdown plus filesystem tools because memory is a judgment problem not a data structure problem]]
- [[Auto-Dreamer learns offline region rewriting to shrink language-agent memory 12x while improving task success]]
- [[Mem0 surveys nine agent harness memory systems and finds five recurring gaps - bounded storage, keyword retrieval, harness scoping, weak staleness, and isolation]]

## Series

- [[Company Brain (Ashwin Gopinath series)]] — 8-part Sentra thesis: layered organizational memory (factual + interaction + action) on one semantic substrate with ontologies as per-role lenses, positioned as the next AI infra layer beneath every app and agent
  
- [[memory is a compiler not a database - Ashwin Gopinath argues admission and action utility functions are the moat, and silence is the evidence they work]] — Ashwin Gopinath (Reflexion co-author, Sentra CEO) on why Instinct feels magical: the agentic loop commoditized, so **memory is the moat**. Memory as a *compiler*, not a database or graph — Borges' Funes as the argument that thinking is forgetting. Two utility functions do the work: **admission utility** (does this observation's future value justify its maintenance cost?) and **action utility / the interruption gate** (weighing risk, irreversibility, and authority → act silently / ask / stay silent). A four-tier state model (ephemeral ingestion → append-only semantic ledger → mutable belief & preference map → procedural commitment scratchpad) where **provenance on every belief makes forgetting real** — revoking a source invalidates a whole dependency branch, versus RAG's ghost hallucinations surviving in summaries. Proactivity emerges from state differentials, not cron jobs, and *silence is the deepest evidence the utility function works*. Ships three falsifiable predictions and a privacy corollary: aggressive compilation means less of your life needs keeping; 3 original diagrams
