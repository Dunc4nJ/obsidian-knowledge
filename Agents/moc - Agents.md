---
created: 2026-02-28
description: Map of Content for the Agents knowledge tree — defines each subfolder's scope and placement criteria.
type: moc
---

# Agents

Knowledge about building, running, and improving AI agents. Each subfolder covers a distinct concern. Notes should land in exactly one subfolder based on the primary topic — if a note spans multiple concerns, place it where the core insight lives.

## Subfolders

### Agentic Memory
How agents store, retrieve, and evolve knowledge across sessions. Memory architectures, vault-as-memory patterns, state persistence, context survival across compaction. If the note is about *what agents remember and how*, it goes here. If it's about *how agents selectively load context into a prompt*, that's Tooling (context engineering).

- [[most agent bottlenecks are actually memory problems not model or orchestration problems]]
- [[multi-agent memory needs computer architecture style hierarchy and consistency models]]
- [[four memory layers serve different knowledge types]]
- [[indexed experience memory compresses LLM agent context without discarding evidence by pairing summaries with a dereferenceable archive]]
- [[Hermes Agent prioritizes prompt caching stability by keeping hot memory tiny and pushing everything else to tool-based retrieval]]
- [[progressive disclosure filters force agent selectivity over what enters context]]
- [[agentic search agents replace vector databases for long-term memory achieving 99 percent on LongMemEval]]
- [[AMA-Bench evaluates long-horizon memory for agentic applications using real and synthetic trajectories]]
- [[Semantica and Cognee solve agent memory differently - Semantica adds accountability while Cognee builds the knowledge engine]]
- [[a file system is not all you need - databases beat markdown for agent context provenance and governance]]
- [[every app that avoids a database ends up rebuilding one badly]]
- [[PARA and atomic facts give AI agents durable structured memory]]
- [[obsidian vaults become memory graphs when agents traverse wikilinked notes with claim-based titles and layered orientation]]
- [[Obsidian as Agentic Memory]]
- [[Obsidian wikilink resolution can be replicated on plain filesystems with an index and atomic rename tool]]
- [[inline annotations beat copy-paste editing by keeping instructions where they belong]]
- [[git hooks as thinking journal let you time-travel through note evolution]]
- [[transcript mining turns meetings into captured decisions and extracted knowledge]]
- [[How Obsidian Graph View Works]]

### Search
Agentic search strategies — code search, semantic retrieval, embedding-based indexing, grep-vs-RAG tradeoffs, long-horizon search behavior, search-vs-reasoning tradeoffs, and tools that help agents find information in codebases or broader environments. The overlap with Tooling is tight — place it here if the core topic is *search strategy or retrieval*, in Tooling if it's about *general agent tool design*.

- [[CodeScout trains small models via RL to outperform 18x larger LLMs at code search using only terminal commands]]
- [[indexing text with sparse n-grams and bloom filters eliminates 15-second ripgrep waits in large monorepos]] — Cursor's Vicent Marti surveys four generations of regex search indexing (trigrams, suffix arrays, bloom-filter trigrams, sparse n-grams) and explains their client-side index architecture for instant agent grep
- [[Context-1 proves agentic search can be 20B-scale and retrieval-dominant without frontier models]] — Chroma Context-1: 20B agentic search model trained via SFT+RL with self-editing context management, synthetic multi-hop tasks, and staged recall-to-precision curriculum
- [[InfoDeepSeek Benchmarking Agentic Information Seeking for Retrieval-Augmented Generation]] — Benchmarks dynamic, multi-turn web information seeking and introduces metrics for evidence utility, compactness, and end-to-end effectiveness in open web settings
- [[hierarchical tree navigation can replace vector embeddings for RAG retrieval]] — PageIndex builds a document tree and uses LLM reasoning to navigate it level-by-level, eliminating embeddings and vector databases entirely
- [[recursive tree retrieval with hierarchical summarization improves multi-hop QA by 20 percent over flat chunk retrieval]] — RAPTOR: recursively cluster and summarize document chunks into a tree, then retrieve across abstraction levels; collapsed tree search with GPT-4 achieves 82.6% on QuALITY (20% over prior SOTA)
- [[MCTS-RAG enables 7B models to match GPT-4o on knowledge-intensive reasoning by interleaving Monte Carlo tree search with adaptive retrieval]] — Interleaves retrieval actions into MCTS reasoning tree at inference time; Llama 3.1-8B outperforms GPT-4o on ComplexWebQA and GPQA with only 2.8x RAG latency
- [[LATTICE uses LLM-guided semantic tree traversal with calibrated scoring to achieve logarithmic-complexity retrieval that outperforms reranking on reasoning-intensive benchmarks]] — LLM navigates a semantic corpus tree at query time with calibrated path relevance scores; zero-shot SOTA on BRIGHT with log-scale search over 420K documents

### Continual Learning

- [[Letta Code agents can move across machines without losing memory]]
- [[stable agentic RL requires sequence-level clipping and environment-aware advantages to prevent training collapse]]
- [[the autoresearch loop generalizes beyond ML training into a universal pattern for autonomous agent research]]
- [[LangChain's Harrison Chase argues continual learning for AI agents extends beyond model fine-tuning to harness engineering and context updates]] — Three-layer framework (model/harness/context) with comparison table showing context is cheapest lever; traces as shared substrate
Agents that improve over time — RL from conversations, self-improvement loops, memory systems that compound knowledge across sessions, skill acquisition. The key test: *does the agent get better at its job over time?* If yes, it belongs here. If it just has good static context architecture, that's Tooling.

### CLI
Patterns for designing command-line interfaces that AI agents can use effectively — non-interactive flags, progressive help discovery, idempotency, structured output, and the CLI-as-agent-interface thesis.

- [[agent-friendly CLIs need flags not prompts and examples not descriptions]]

### Data Agent
AI agents that query databases, write SQL, answer data questions, and do data analysis. Text-to-SQL, discovery and context layers over warehouses, data assistant architectures, RL for SQL tool use. If the note is about *agents interacting with structured data to answer questions*, it goes here.

- [[OpenAI internal data agent succeeds through six layers of context not model capability alone]]
- [[context management replaces the semantic layer for data agents because it adapts from corrections]]
- [[the hard problem in text-to-SQL is discovery not generation and hybrid search over existing metadata solves it]]
- [[Prime Intellect duckdb-qa - RL reward shaping for SQL tool use]]
- [[multi-task RL on heterogeneous search behaviors produces knowledge agents that generalize across grounded reasoning tasks]]
- [[RLMs inline intelligence into data pipelines by giving LLMs symbolic access to DataFrames in a persistent REPL]]

### Evaluation and Monitoring
Measuring agent quality, observability, regression testing, LLM-as-judge, eval pipelines, drift detection, production monitoring. If the note is about *knowing whether the agent is doing well*, it goes here.

- [[Agno native tracing keeps agent observability data in your own database]]
- [[sandboxed CI is the missing infrastructure for agent evals at scale]]
- [[Offload parallelizes agent CI test suites across Modal sandboxes removing the integration testing bottleneck]]

### Extra
Roundups, digests, survey notes, and multi-topic captures that don't fit cleanly into one subfolder. Use sparingly — prefer placing notes in a specific subfolder when possible.

### Harness Engineering
Designing the scaffolding around agents — system prompts, AGENTS.md patterns, soul files, tool descriptions, prompt engineering techniques, middleware between the model and the world. If the note is about *shaping agent behavior through its harness*, it goes here.

- [[agents need a harness not a framework because durable event-driven infrastructure already solves retry routing and state]]
- [[OpenAI built a million-line product with zero manually-written code by making the repo legible to agents]]
- [[LLM agents need a typed execution layer beyond bash]]
- [[autonomous context compression lets agents choose when to compact rather than hitting fixed token limits]]
- [[the harness layer is the next hundred billion dollar AI infrastructure market not the model]]
- [[Slate's thread-based episodic memory solves long-horizon agent tasks]]
- [[context files beat MCP schemas for internal agents because they encode how your team actually uses each tool]]
- [[structured compaction and CLAUDE.md hierarchy prevent context drift in million-token agent sessions]]
- [[training beats prompting so use runtime guards not instructions]]
- [[repository-level context files reduce coding agent task success and increase inference costs by over 20 percent]]
- [[memory-first agents should dispatch stateless subagents for focused task execution]]
- [[the harness is everything and agent performance comes from environment design not model capability]]
- [[hashline edit format improves LLM coding accuracy more than model upgrades at zero training cost]]
- [[training compaction into the model through RL produces better summaries than prompted compaction at one-fifth the tokens]]

### Infrastructure
Production engineering for agents — security, reliability, sandboxing, deployment, distributed systems patterns, authentication, cost management. If the note is about *keeping agents running safely in production*, it goes here.

- [[sandboxing ai agents can be 100x faster with dynamic workers]]

### MCP
Model Context Protocol — servers, tool definitions, transport patterns, and the MCP ecosystem specifically. If it's about MCP as a protocol or MCP-based tools, it goes here. General tool design goes in Tooling.

### OpenClaw
Notes specific to the OpenClaw platform — architecture, features, configuration, skills, and resources related to OpenClaw itself.

### Optimization
How agents become better over time: self-play, self-challenge, curriculum, judge-and-oversight, and co-evolutionary training regimes.

- [[moc - Adversarial Agent Optimization]]

### Pi
Notes about the Pi coding agent by @badlogicgames — its extension system, theming engine, community ecosystem, and what it reveals about personalizable agent architectures.

- [[coding agents should be personal canvases not uniform tools]]

### Orchestration
Multi-agent coordination — delegation patterns, lead/worker ratios, communication between agents, state machines, planning-based orchestration, squad architectures. If the note is about *how multiple agents work together*, it goes here. Single-agent architecture decisions usually belong in Harness Engineering or Infrastructure.

- [[separating cognitive blueprints from runtime engines enables portable auditable agent systems]]
- [[peer-to-peer world models create collective intelligence that scales superlinearly with network size]]

### Skills
Agent skill design, authoring, testing, and lifecycle management. SKILL.md patterns, eval frameworks for skills, skill triggering and description optimization, capability uplift vs. encoded preference, and the skill-as-specification thesis. If the note is about *how skills are built, tested, or managed*, it goes here.

- [[skill-creator now brings software testing rigor to agent skill authoring without requiring code]]
- [[static agent skills rot silently because the codebase model and task distribution change around them]]
- [[agent skills need eval harnesses not vibe checks to ship reliably]]
- [[repo-local skills and AGENTS.md turn recurring engineering work into repeatable agent workflows]]
- [[dual-stream experience and skill accumulation enables multimodal agents to continually improve tool use without parameter updates]]
- [[LLMs can discover and reuse compositional tool skills via MCP primitives reducing token usage up to 80 percent]]
- [[agent skills should self-improve through observed failures not stay as static prompt files]]
- [[memento-skills turns executable skill folders into evolving non-parametric memory that lets frozen LLMs learn continuously from deployment]]
- [[EvoSkill discovers reusable agent skills through iterative failure analysis outperforming static prompts and transferring zero-shot]]
- [[systematic mining of open-source repos can automate agent skill acquisition at scale]]
- [[the best agent skills fit one category and grow from gotchas not upfront design]]
- [[skills are living folders not markdown files and building them is the new developer setup]]
- [[agent skills should be contextual actions not static prompts and chaining them requires forking as a primitive]]

### Tooling
Agent tool design, context engineering, prompt caching, skill architectures, search strategies, progressive disclosure, and general patterns for how agents interact with tools and manage context. The broadest subfolder — if a note is about *how agents use tools or manage their context window*, it goes here.

- [[Everything is Context: Agentic File System Abstraction for Context Engineering]]
- [[Slate's terminal UX solves multi-agent observability by separating orchestration search and execution into visible parallel threads]]

## Placement Rules

1. Read the note's Key Takeaways, not just the title. Titles can mislead.
2. Ask: "What is the **primary insight**?" Place based on that, even if the note touches other areas.
3. When genuinely ambiguous between two subfolders, prefer the more specific one.
4. One note, one subfolder. No duplicates. Use `[[wiki links]]` to connect across subfolders.
5. If nothing fits, use **Extra** temporarily and revisit when the vault grows.
