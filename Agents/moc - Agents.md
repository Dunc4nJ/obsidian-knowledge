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
- [[Letta Context Constitution frames context as the substrate of agent identity memory and continuity beyond model weights]] — Letta's foundational doctrine: context management is the mechanism by which experiential agents build identity, memory, and continuity in token-space; prescribes system prompt learning, progressive disclosure, and index-over-record discipline
- [[agentic search agents replace vector databases for long-term memory achieving 99 percent on LongMemEval]]
- [[AMA-Bench evaluates long-horizon memory for agentic applications using real and synthetic trajectories]]
- [[Semantica and Cognee solve agent memory differently - Semantica adds accountability while Cognee builds the knowledge engine]]
- [[a file system is not all you need - databases beat markdown for agent context provenance and governance]]
- [[every app that avoids a database ends up rebuilding one badly]]
- [[PARA and atomic facts give AI agents durable structured memory]]
- [[obsidian vaults become memory graphs when agents traverse wikilinked notes with claim-based titles and layered orientation]]
- [[Obsidian as Agentic Memory]]
- [[Obsidian wikilink resolution can be replicated on plain filesystems with an index and atomic rename tool]]
- [[Ramp Labs Latent Briefing compacts KV caches for efficient cross-agent memory sharing]]
- [[The Price of Meaning prescribes coupling semantic retrieval with exact episodic grounding as the only escape from interference]] — Sentra's formal no-escape theorem: any semantic memory system forgets as it grows because natural language has only ~10–50 effective dimensions; the only principled exit is pairing semantic retrieval with an exact episodic verification layer
- [[inline annotations beat copy-paste editing by keeping instructions where they belong]]
- [[git hooks as thinking journal let you time-travel through note evolution]]
- [[transcript mining turns meetings into captured decisions and extracted knowledge]]
- [[How Obsidian Graph View Works]]

### Search
Agentic search strategies — code search, semantic retrieval, embedding-based indexing, grep-vs-RAG tradeoffs, long-horizon search behavior, search-vs-reasoning tradeoffs, and tools that help agents find information in codebases or broader environments. The overlap with Tooling is tight — place it here if the core topic is *search strategy or retrieval*, in Tooling if it's about *general agent tool design*.

- [[CodeScout trains small models via RL to outperform 18x larger LLMs at code search using only terminal commands]]
- [[indexing text with sparse n-grams and bloom filters eliminates 15-second ripgrep waits in large monorepos]] — Cursor's Vicent Marti surveys four generations of regex search indexing (trigrams, suffix arrays, bloom-filter trigrams, sparse n-grams) and explains their client-side index architecture for instant agent grep
- [[Context-1 proves agentic search can be 20B-scale and retrieval-dominant without frontier models]] — Chroma Context-1: 20B agentic search model trained via SFT+RL with self-editing context management, synthetic multi-hop tasks, and staged recall-to-precision curriculum
- [[Perplexity post-trains Qwen3.5 search agents with two-stage SFT+RL and gated reward aggregation to prevent hacking]] — Perplexity Research: two-stage SFT→on-policy RL (GRPO) pipeline on Qwen3.5-397B/122B with synthetic multi-hop QA, rubric-based rewards, gated aggregation, and anchored group-relative efficiency penalties; beats GPT-5.4 and Sonnet 4.6 on FRAMES at 4-7x lower cost
- [[InfoDeepSeek Benchmarking Agentic Information Seeking for Retrieval-Augmented Generation]] — Benchmarks dynamic, multi-turn web information seeking and introduces metrics for evidence utility, compactness, and end-to-end effectiveness in open web settings
  - **Agentic Search references** (in `Search/Agentic Search/references/`):
  - [[ScaleRL proves clipped importance sampling prevents entropy collapse in large-scale agentic RL]] — CISPO algorithm for stable RL training of search agents
  - [[WebExplorer trains 8B web agents via SFT and RL to outperform frontier models on deep research tasks]] — 8B web agent trained via explore-and-evolve pipeline
  - [[Search-R1 proves RL-only training teaches multi-turn search without supervised fine-tuning warmup]] — RL-only multi-turn search with binary outcome rewards
  - [[BrowseComp-Plus enables reproducible agentic search evaluation with static corpora and verified distractors]] — reproducible deep research benchmark with static corpora
- [[hierarchical tree navigation can replace vector embeddings for RAG retrieval]] — PageIndex builds a document tree and uses LLM reasoning to navigate it level-by-level, eliminating embeddings and vector databases entirely
- [[recursive tree retrieval with hierarchical summarization improves multi-hop QA by 20 percent over flat chunk retrieval]] — RAPTOR: recursively cluster and summarize document chunks into a tree, then retrieve across abstraction levels; collapsed tree search with GPT-4 achieves 82.6% on QuALITY (20% over prior SOTA)
- [[MCTS-RAG enables 7B models to match GPT-4o on knowledge-intensive reasoning by interleaving Monte Carlo tree search with adaptive retrieval]] — Interleaves retrieval actions into MCTS reasoning tree at inference time; Llama 3.1-8B outperforms GPT-4o on ComplexWebQA and GPQA with only 2.8x RAG latency
- [[LATTICE uses LLM-guided semantic tree traversal with calibrated scoring to achieve logarithmic-complexity retrieval that outperforms reranking on reasoning-intensive benchmarks]] — LLM navigates a semantic corpus tree at query time with calibrated path relevance scores; zero-shot SOTA on BRIGHT with log-scale search over 420K documents
- [[Neo4j's Stephen Chin on agentic graph RAG - vector search finds entry points and graph traversal supplies grounded context]] — recommends vector-then-graph as the starter graph RAG pattern (not text-to-Cypher); embeddings live as properties on graph nodes so chunks and nodes are the same object; CLA replaced their internal SaaS stack with this pattern

### Continual Learning

- [[Letta Code agents can move across machines without losing memory]]
- [[stable agentic RL requires sequence-level clipping and environment-aware advantages to prevent training collapse]]
- [[the autoresearch loop generalizes beyond ML training into a universal pattern for autonomous agent research]]
- [[LangChain's Harrison Chase argues continual learning for AI agents extends beyond model fine-tuning to harness engineering and context updates]] — Three-layer framework (model/harness/context) with comparison table showing context is cheapest lever; traces as shared substrate
- [[Grey Haven autocontext runs five-role recursive improvement loops with persistent playbooks and traces that next runs inherit]] — autocontext 0.5.0: Competitor/Analyst/Coach/Architect/Curator pipeline; tournament+curator gating; versioned `playbook.md` + SQLite snapshots restored by scenario name; per-role provider/model env knobs; Pi via `pi --print` subprocess, Hermes skill export, MCP server
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
- [[Databricks Genie pushes data agents past coding-agent baselines via specialized knowledge search, parallel thinking, and multi-LLM design]]

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
- [[Cursor strips guardrails and adds dynamic context as models improve, inverting the harness's job]] — Stefan Heule & Jediah Katz: Cursor's harness work in 2026 is mostly *removing* the lint/file-read/tool-cap guardrails and static-context dumps it shipped in 2024, replacing them with dynamic context the model pulls itself; introduces Keep Rate and stack-trace-paste as durable quality signals, per-tool/per-model error baselines, and per-model tool-format provisioning
- [[OpenAI built a million-line product with zero manually-written code by making the repo legible to agents]]
- [[Basis built an agent-native monorepo by separating canonical from non-canonical context across a six-layer instruction architecture]] — Basis Atlas team (Michael Crabtree, Ryan Moffat, Bhavdeep Sethi): five principles (canonicality, localization, verifiability, interoperability, default-no), explicit canon (root + 100 nested AGENTS.md, skills, docs/, comments) vs non-canon (.specs/, Linear, .notes/) Authority Map, six-layer architecture (root AGENTS.md → nested → skills → sub-agent roles like verifier/standards-enforcer → unified MCP → tests), five AGENTS.md authoring rules, daily scanner+worker agents that maintain the instruction layer, owner-field CI; reported 5x token usage per developer and 2.5x weekly commit velocity over three months, 100% of engineering on multiple worktrees
- [[Joseph Viviano frames agentic research workflows as a continuum of markdown files at different mutation rates from paper.tex to notes.md]] — Mila researcher's 15-month workflow synthesis: research codebases differ from production code (no users, just developers and post-paper static-artifact consumers); stabilized via a continuum of markdown files at different mutation rates (paper.tex/design_doc.md/plan.md/TODO.md/notes.md/handoff.md), short AGENT.md with universal rules, per-TODO context, git commits as savegames, independent test/code agents, and periodic paper-to-code reconciliation
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
- [[LangChain Deep Agents Deploy offers open harness to avoid Claude Managed Agents memory lock-in]] — the product launch, paired with Chase's thesis below
- [[Memory ownership follows harness ownership - Harrison Chase argues picking a closed harness is picking a permanent owner for your agent's data flywheel]] — Chase's strategic manifesto formalizing the three-tier memory lock-in taxonomy (stateful API → closed harness → closed harness with server-side long-term memory), the thesis that underwrites the Deep Agents Deploy launch
- [[LangChain Deep Agents adds per-model harness profiles because each provider's prompting guide demands different tools and middleware]] — Viv Trivedi: HarnessProfile becomes a registerable declarative override layer (system prompt, tools/aliases, middleware, subagents, skills); ships defaults for OpenAI/Anthropic/Google yielding 10-20 point tau2-bench gains; generalizes the prior Terminal-Bench harness-engineering result into a permanent primitive
- [[Model-Harness-Fit means tool surfaces and citation tags are post-trained into the model, not interchangeable]] — Nicolas Bustamante: same model on three harnesses behaves like three different models because tool names, schema shapes, citation tags (`<oai-mem-citation>`), and the ten-section system-prompt skeleton are baked into post-training; Cursor's "Top 30 → Top 5 by changing only the harness" and the 4.5pt Opus 4.6 spread between ForgeCode and Capy are the empirical anchor; Copilot CLI's per-model tool inclusion is the only honest router pattern; mid-chat model switching is the cleanest concrete failure mode (transcript OOD, cache miss, tool-shape change at once)
- [[LangChain HITL gives agents four typed interrupt decision types so the harness can pause without breaking the loop]] — the consumer-facing API contract for the HITL primitive: four typed decisions (approve, edit, reject, respond) that humans return on a paused tool call, with per-tool `allowed_decisions` allowlists; sits on top of the durable-checkpoint runtime documented in the runtime guide above
- [[Anthropic Managed Agents virtualizes agent components into OS-style interfaces that decouple the brain from the hands]]
- [[The Mismanaged Geniuses Hypothesis argues the next AI leap comes from training LMs to decompose not from scaling]] — Alex Zhang, Zhening Li, Omar Khattab: frontier LMs are capable enough; the bottleneck is hand-engineered scaffolds, and training models to decompose (with RLMs as the more expressive scaffold) beats further scaling — a 4B RLM trained on 32k/1-needle RL hits 100% on MRCRv2 1M/8-needle
- [[HALO uses an RLM to mine harness-shaped failures from agent execution traces and lift benchmarks 10-16 percentage points]] — Sam Hogan (Context Labs): HALO is an RLM-powered agent that mines hundreds of thousands of execution traces for recurring failure patterns, then recommends prompt/config/tool-definition fixes; harness-only changes lifted Sonnet 4.6 AppWorld 73.7→89.5%, Opus 4.7 Finance-Agent 56→72%, Gemini 3 Flash Terminal-Bench 46→57.14% (matching Claude Code on Opus 4.6); also triages harness-slack vs missing-model-capability (tau3-Bench banking_knowledge capped near 10% across all variants)
- [[Recursive Language Models pass context by reference through a Python REPL so subagent outputs return as variables instead of autoregressively regenerated tokens]] — Avishek Biswas's TDS deep dive: walks a fruit-counting case study from Direct Generation → ReAct → CodeAct → CodeAct+Subagents → +Filesystem → RLM, identifying pass-by-reference (parking the prompt as a Python `context` variable, returning subagent results as REPL symbols via `llm_query`/`FINAL`) as the missing primitive; eight reasons RLMs win long-context benchmarks (focused attention, robustness to noise, composable variables, arbitrarily long outputs unbounded by context length, KV-cache-friendly subagents, planner/executor separation); ships open-source `fast-rlm` plus the full author-recommended system prompt
- [[Browserbase's bb agent generalizes knowledge work through four building blocks - sandbox, credential-brokering proxy, loadable skills, and Slack]] — Kyle Jeong's full architecture writeup: one OpenCode loop, ephemeral sandbox with pre-warmed snapshot, serverless integration proxy that holds real credentials and enforces scoped RBAC+ABAC, `.opencode/skills/*.md` as loadable playbooks, Slack thread as persistent workspace; webhooks carry intent and get hard-scoped permissions at dispatch
- [[Harrison Chase frames agent development as a Build-Test-Deploy-Monitor lifecycle wrapped by iteration and governance]] — Chase's operational manifesto: four ordered phases (test before deploy), four build layers (frameworks/runtimes/harnesses/no-code), datasets-from-hard-cases as the eval substrate, deployment as runtime+sandbox+vfs+context-hub, traces as the unit of monitoring, and Govern (cost/tool access/discoverability) wrapping the entire loop as shared infrastructure across teams
- [[DSPy frames AI engineering as five components and adapters are the most underappreciated lever]] — Maxime Rivest: DSPy's Optimizers/Signatures/LMs/Modules/Adapters map onto the general AI-engineering axes Evals/Interface/Inference/Call Graph/Rendering; adapters (rendering) are the under-noticed lever because structured output, reasoning, and tool calls are all rendering choices, not task decisions; empirical anchor is a 100M-publications/week classifier that ran at $50/wk on Llama 8B + vLLM + Qwen embeddings vs $400K/wk on ChatGPT

- [[Systems Engineering Makes Agentic Software Work - The Five-Layer Pattern]]
- [[Claude Code's source reveals agent systems need infrastructure as a fourth layer beyond weights context and harness]] — Rohit's 331-module teardown: async-generator loops, streaming tool executor, cache-boundary prompts, cost-ordered compaction, seven-stage permissions, 823-line retry state machine; argues infrastructure (multi-tenancy/RBAC/isolation/coordination) is a distinct fourth layer where production agents die

### Infrastructure
Production engineering for agents — security, reliability, sandboxing, deployment, distributed systems patterns, authentication, cost management. If the note is about *keeping agents running safely in production*, it goes here. The **File Systems** sub-area covers file systems as agent infrastructure: virtual filesystems, storage-as-compute, and embedding compute into the storage layer.

- [[sandboxing ai agents can be 100x faster with dynamic workers]]
- [[Harvey Spectre makes durable runs the core primitive while workers stay ephemeral and sandboxes enforce explicit boundaries]] — Harvey's internal cloud coding agent platform: durable runs as the stable object, disposable sandboxed workers, explicit capability injection at run start, Slack/web/CLI as unified surfaces over one run record
- [[LangChain Deep Agents runtime builds ten production capabilities on one primitive - durable super-step checkpointing to PostgreSQL]] — comprehensive runtime architecture guide: harness/runtime split, checkpointed super-steps as the single foundation for memory, HITL, time travel, streaming, cron, sandboxes, and open protocol integration (MCP/A2A)
- [[Bash is the SQL for file systems and Archil proves it with serverless execution that sends instructions not data]] — Archil embeds bash execution into file systems so clients send instructions not bytes, eliminating egress and making file systems queryable like databases
- [[Palantir Ontology gives enterprise agents a decision-centric substrate by surfacing data logic and action as tools governed by one security model]] — Palantir's platform thesis: enterprise agents need a decision-centric (not data-centric) substrate that fuses Data, Logic, Action, and Security into one Ontology; agents call ML models/optimizers/business logic as Ontology-surfaced tools, stage multi-system writebacks as sandboxed scenarios for human review, and the captured decision lineage feeds fine-tuning and procedural memory
- [[Opencomputer reframes harness-vs-sandbox debate as git branches for VMs via hibernation egress proxies and checkpoints]] — Utpal Nadiger (Opencomputer) rebuts Mendral's harness-outside-sandbox thesis: egress-proxy credential tokenization is a 15-year-old solved primitive, 25ms VM hibernation invalidates the cost argument, and checkpoint-fork durability creates a third option beyond cattle-vs-pets — surfaces the real fault line between runtime-level (Inngest super-steps) and VM-level (hibernation + checkpoints) durability
- [[pgGraph compiles Postgres edges into a CSR in-memory graph layer for microsecond deep agent traversals where Apache AGE recursive SQL times out]] — Evokoa's Dale Everett: AI agents need 10-20 hop graph traversals that recursive SQL cannot serve; pgGraph (Apache OSS, Rust) compiles Postgres relationships into a memory-mapped Compressed Sparse Row array so neighbor lookups collapse to a single array offset; LDBC 34.5M-edge Friend Traversal at 34.1ms Hot Run while AGE simply times out at depth; argues the data-access layer, not the model, is the agent bottleneck
- [[LangSmith Auth Proxy keeps credentials outside agent runtimes by intercepting sandbox egress at the network layer]] — Harrison Chase: TLS MITM + iptables forces all LangSmith sandbox egress through an auth proxy that injects credentials at the network layer, so agents get API access without ever possessing the keys; blast radius stays O(1) regardless of fleet size; dynamic callbacks support OAuth and per-user token delegation

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
- [[Cognition finds multi-agent systems work only when writes stay single-threaded and additional agents contribute intelligence not actions]]

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
- [[The bitter lesson of agent harnesses is your helpers are abstractions too - Browser-Use ships a 600-line CDP + SKILL.md harness]] — Gregor Zunic: delete even the `click()/type()/scroll()` wrappers; a 600-line harness of raw CDP + `SKILL.md` that the agent edits at runtime is enough, because RL-tuned models were trained on millions of tokens of `Page.navigate`/`DOM.querySelector`/`Runtime.evaluate`
- [[predict-RLM uses GEPA to recursively optimize agent skills reaching SpreadsheetBench top-5 as open source]]
- [[GEPA prompt optimizer beats reinforcement learning with 35x fewer rollouts by reflecting on natural-language execution traces]] — Agrawal/Khattab et al. (arXiv:2507.19457): reflective Genetic-Pareto prompt evolution; outperforms GRPO by up to 20% with up to 35× fewer rollouts and beats MIPROv2 by 10pp; Pareto-front candidate sampling, cross-model prompt transfer, instruction-only optimization beating few-shot
- [[dspy-agent-skills shows GEPA only improves when there is failure signal - 1.2B models gain 25 points where 8B+ no-op]] — Bryan Young's three free-tier example runs (RAG QA, math, typed invoice extraction) surface GEPA's saturation behavior: the optimizer correctly no-ops when the baseline leaves nothing to improve, so demos and production runs both need task difficulty matched to model capability or the budget is wasted; also documents the metric-as-lever pattern (`dspy.Prediction(score, feedback)` where feedback names the failing axis is what the reflection LM acts on)

### Tooling
Agent tool design, context engineering, prompt caching, skill architectures, search strategies, progressive disclosure, and general patterns for how agents interact with tools and manage context. The broadest subfolder — if a note is about *how agents use tools or manage their context window*, it goes here.

- [[Everything is Context: Agentic File System Abstraction for Context Engineering]]
- [[Slate's terminal UX solves multi-agent observability by separating orchestration search and execution into visible parallel threads]]
- [[Agno Context Providers collapse the multi-source tool surface to 2N tools by hiding each source behind a query and update sub-agent]] — Ashpreet Bedi: each source (Slack, Drive, GitHub) gets wrapped in a sub-agent exposing only `query_<source>` and `update_<source>`; main agent's tool surface stays linear at 2N regardless of how many tools each source has, source-specific quirks live in the sub-agent
- [[Quarq Labs frames GEPA and RLM as complementary context layers - GEPA optimizes static prompts before inference while RLM decomposes context at runtime]] — synthesis from Quarq Labs (personal-agent harness builder): GEPA optimizes the static prompt ahead of inference, RLM decomposes context dynamically at runtime, together replacing the "longer windows" paradigm with active curation; shared diagnosis is that LLMs are passive consumers of context

## Placement Rules

1. Read the note's Key Takeaways, not just the title. Titles can mislead.
2. Ask: "What is the **primary insight**?" Place based on that, even if the note touches other areas.
3. When genuinely ambiguous between two subfolders, prefer the more specific one.
4. One note, one subfolder. No duplicates. Use `[[wiki links]]` to connect across subfolders.
5. If nothing fits, use **Extra** temporarily and revisit when the vault grows.
