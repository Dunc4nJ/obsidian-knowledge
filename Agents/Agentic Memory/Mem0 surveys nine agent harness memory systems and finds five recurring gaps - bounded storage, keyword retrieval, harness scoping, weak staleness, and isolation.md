---
created: 2026-06-03
description: In Context #11 audits memory implementations across Claude Code, Managed Agents, Codex, Copilot, OpenClaw, Hermes, Bedrock AgentCore, Windsurf, and Devin and argues every harness reproduces the same five constraints that force memory to become cross-harness infrastructure.
source: https://x.com/mem0ai/status/2061822612398014782
type: synthesis
---

## Key Takeaways

- Mem0 separates *working / external / parametric* memory and observes that as of 2026 zero production harnesses ship parametric memory — every system audited lives in the external tier (markdown + filesystem + optional index). This concretizes the architectural framing in [[multi-agent memory needs computer architecture style hierarchy and consistency models]]: the three-tier split is not theoretical, it's what the bug-reports cluster around.
- GitHub Copilot's *just-in-time citation verification* is the only deployed staleness mechanism with published A/B outcomes — PR merge rate moved from 83% to 90% (p<0.00001) when memory was on, the only real-world production lift in the entire space, while everyone else reports benchmark numbers. This is the empirical complement to the verification-on-read discipline catalogued in [[Hermes, Codex, and Claude Code converge on markdown plus filesystem tools because memory is a judgment problem not a data structure problem]] — Copilot proves the staleness check pays for itself.
- The benchmarks the field uses to measure memory are themselves the weak link: LoCoMo's ten conversations let a trivial grep baseline score ~74% by pattern-matching, LongMemEval caps near 1.5M tokens while production agents hit 10M+, and BEAM is the only benchmark built for that range — and the one most systems do not publish. This reframes the optimistic LongMemEval saturations in [[agentic search agents replace vector databases for long-term memory achieving 99 percent on LongMemEval]] and [[AMA-Bench evaluates long-horizon memory for agentic applications using real and synthetic trajectories]] as ceiling effects, not capability claims.
- The same five gaps recur across all nine harnesses — bounded local storage (Claude Code 25KB, Hermes 2.2K chars, Codex's 5K-token load), keyword-only retrieval (filename for Claude Code, grep for Codex, FTS5 for Hermes), harness scoping (Claude Code's memory means nothing to Codex), absent staleness handling (Copilot aside), and isolation gaps that measure 57–71% cross-user contamination in normal usage. The "different judgment, same architecture" story in [[Claude Code memory has a silent 200-line index cap that drops old memories without warning]] and [[Hermes Agent prioritizes prompt caching stability by keeping hot memory tiny and pushing everything else to tool-based retrieval]] is the symptom; this post names the systemic cause.
- Mem0's v3 algorithm (April 2026) folds the previous external graph DB into the vector store via inline entity linking and single-pass ADD-only extraction, reporting ~6,900 tokens at 1.44s per query against ~26,000 tokens at 17.12s for full-context retrieval — a 4x token reduction and 12x latency improvement that's the operational argument for treating memory as infrastructure rather than per-harness feature. This is the cross-cutting story behind the MCP-based knowledge graph approach in [[mem0-knowledge-graph]] and the no-escape coupling argument in [[The Price of Meaning prescribes coupling semantic retrieval with exact episodic grounding as the only escape from interference]].

## External Resources

- [Mem0 GitHub](https://github.com/mem0ai/mem0) — open source memory layer with 21 framework integrations and 20 vector stores.
- [Mem0: Token-Efficient Memory Algorithm](https://mem0.ai/blog/mem0-the-token-efficient-memory-algorithm) — v3 architecture details (April 2026).
- [Mem0: BEAM Benchmark](https://mem0.ai/blog/what-is-beam-memory-benchmark-the-paper-that-shows-1m-context-window-isnt-enough) — production-scale memory benchmark, 10M+ tokens.
- [Mem0: OpenClaw Memory System](https://mem0.ai/blog/openclaw-memory-management-live-data-compaction-and-best-practices) — live data compaction and the Mem0 plugin Auto-Recall/Auto-Capture story.
- [Mem0: How Memory Works in Claude Code](https://mem0.ai/blog/how-memory-works-in-claude-code)
- [Mem0: Codex CLI Memory](https://mem0.ai/blog/how-memory-works-in-codex-cli)
- [Mem0: How Memory Works in Hermes Agent](https://mem0.ai/blog/how-memory-works-in-hermes-agent-(and-how-to-improve-it))
- [AWS and Mem0 Partner — Strands Integration](https://mem0.ai/blog/aws-and-mem0-partner-to-bring-persistent-memory-to-next-gen-ai-agents-with-strands)
- [Anthropic Engineering: Scaling Managed Agents](https://anthropic.com/engineering/managed-agents)
- [OpenAI: Codex memories documentation](https://developers.openai.com/codex/memories)
- [AWS: Amazon Bedrock AgentCore Memory](https://aws.amazon.com/blogs/machine-learning/amazon-bedrock-agentcore-memory-building-context-aware-agents)
- [NousResearch: Hermes Agent](https://github.com/NousResearch/hermes-agent)
- [Contextual Agentic Memory is a Memo, Not True Memory (arXiv:2604.27707)](https://arxiv.org/abs/2604.27707)
- [MemoryArena (arXiv:2602.16313)](https://arxiv.org/abs/2602.16313) — Stanford/UCSD/Princeton; memory that must guide action.
- [Anatomy of Agentic Memory (arXiv:2602.19320)](https://arxiv.org/abs/2602.19320)
- [When Continual Learning Moves to Memory (arXiv:2604.27003)](https://arxiv.org/abs/2604.27003)
- [MemoryAgentBench (arXiv:2507.05257)](https://arxiv.org/abs/2507.05257) — ICLR 2026.
- [No Attacker Needed: Cross-User Contamination (arXiv:2604.01350)](https://arxiv.org/abs/2604.01350)
- [Memory Poisoning Attack and Defense (arXiv:2601.05504)](https://arxiv.org/abs/2601.05504)

## Original Content

> @mem0ai — 2026-06-02
>
> *Cover slide: In Context #11 — State of memory in Agent Harness*
> ![[mem0ai-014782-001.jpg]]
>
> Article: State of Memory in Agent Harness
>
> Agent harnesses are where AI software actually runs. Cursor, Devin, Claude Code, Codex: these environments handle context, orchestrate tools, coordinate agents, and increasingly, manage memory. The harness, not the model, is increasingly the product that ships software.
>
> Memory is where harness design gets hard.
>
> Where does it sit? What persists when a session ends? It is a largely unsolved problem, and every major harness is solving it differently.
>
> This post covers what each shipped, where each falls short, and what that gap says about what memory infrastructure has to do.
>
> ---
>
> **What Agent Memory Actually Is**
>
> Three different things get called memory, and the distinction matters because each has different failure modes.
>
> 1. Working memory is what lives in the context window during a session. It resets on session end; the compaction problem (what survives when the window fills) belongs here.
>
> 2. External memory is anything persisted outside the weights: vector stores, knowledge graphs, files. It survives sessions; the weights don't change. This is where essentially all production memory lives in 2026.
>
> 3. Parametric memory is knowledge encoded into weights via gradient descent, shaped by the training loop the harness feeds. It generalizes by applying rules rather than retrieving examples. Zero production deployments in 2026.
>
> (The cognitive-science split, semantic / episodic / procedural, describes what kind of information is stored; the three tiers above describe where it lives.)
>
> The paper "Contextual Agentic Memory is a Memo, Not True Memory" (arXiv:2604.27707) formalizes the ceiling: retrieval needs Ω(k²) stored examples to match what parametric memory does with O(d) weight updates. Every system below operates within it.
>
> ---
>
> **What Major Harnesses Shipped [Overview]**
>
> *Side-by-side comparison: storage substrate, retrieval method, and published metrics across nine harnesses*
> ![[mem0ai-014782-002.jpg]]
>
> ---
>
> **1. @AnthropicAI: Claude Code**
>
> Two tracks. [CLAUDE.md](http://claude.md/) is human-authored config (conventions, instructions), read at session start. Auto-memory is Claude-written notes from a background extraction agent, stored under `~/.claude/projects/<repo>/memory/` around a MEMORY.md index capped at 200 lines / 25KB, in four categories: user, feedback, project, reference.
>
> Retrieval shapes the limits: each turn Claude Code makes a separate call to a smaller model with a manifest of filenames and descriptions, and the model picks which files load. No embeddings, max five files per turn, and silent truncation past the cap (a dropped file gets no warning because it never loads).
>
> *Claude Code memory architecture: two tracks of markdown, smaller model picks files by filename each turn, Mem0 plugin adds semantic search and lifecycle capture*
> ![[mem0ai-014782-003.jpg]]
>
> Shortcoming. Selection is by filename, not semantic search, so a relevantly-named file wins over a relevant one. Team sharing exists behind a TEAMMEM flag, but underneath it's local, repo-scoped markdown with no semantic index.
>
> Read more here:
>
> *Embedded tweet cover: How Claude Code Remember (In Context #4)*
> ![[mem0ai-014782-004.jpg]]
>
> [Embedded Tweet: https://x.com/i/status/2039041449854124229]
>
> ---
>
> **2. @AnthropicAI: Managed Agents**
>
> Managed Agents is Anthropic's hosted agent runtime, not a local product like Claude Code. A session is an append-only event log that is never mutated, so rollback and audit are architectural, not bolted on. Memory stores mount at `/mnt/memory/` as a filesystem (up to 8 per workspace, ~100KB each); every write is an immutable version, and multiple agents can share one store concurrently with an auditable history rather than conflicts.
>
> Shortcoming. It's built for multi-agent coordination at workspace scale, not long-term personal memory. The 100KB-per-store ceiling and workspace scoping mean cross-session personal context needs a pattern built on top.
>
> ---
>
> **3. @OpenAI Codex**
>
> Codex's memory is one directory of markdown, `~/.codex/memories/` (no SQLite, no embeddings): memory_summary.md read first, MEMORY.md grepped on demand, plus raw_memories.md, skills/, and rollout_summaries/. It's off by default behind a `features.memories` flag.
>
> The write path is two-phase. Phase 1, per-rollout: after a session is idle six hours, Codex extracts against a strict schema, redacts secrets, and writes to a local state DB (not the memory dir yet). Phase 2, global: under a lock, a consolidation sub-agent merges, patches, or drops and writes the diff. It's bounded (256 rollouts), age-pruned (30 days), and rate-limit aware. The read path is non-semantic: the summary is truncated to a fixed 5,000-token budget, and anything else is found by grep over MEMORY.md.
>
> *OpenAI Codex memory architecture: two-phase write to local markdown, session-start summary plus on-demand grep, Mem0 replaces the local pipeline with hosted semantic cross-tool memory*
> ![[mem0ai-014782-005.jpg]]
>
> Shortcoming. The 5,000-token summary truncates silently; grep is substring-only, so paraphrased facts are invisible; the six-hour idle gate means back-to-back sessions may never consolidate; state is local-only; and at launch the feature was unavailable in the EEA, UK, and Switzerland.
>
> Read more here:
>
> *Embedded tweet cover: How Memory Works In Codex CLI (In Context #9)*
> ![[mem0ai-014782-006.jpg]]
>
> [Embedded Tweet: https://x.com/i/status/2054580022049198513]
>
> ---
>
> **4. @github Copilot**
>
> Copilot's distinctive move is just-in-time citation verification. Memory items are structured objects (subject, factual content, a file-and-line citation, reasoning), and before use the agent validates citations against the current branch, rewriting a memory that the code now contradicts. Memories also auto-expire after 28 days.
>
> This is the only deployed staleness mechanism with published outcome data: A/B tested (p<0.00001), PR merge rate rose from 83% to 90% with memory on, with code-review precision +3% and recall +4%. That 7-point lift is the only published real-world production metric on memory in a coding agent; everyone else reports benchmarks.
>
> Shortcoming. The citation schema can't cleanly hold ungroundable or preference-based facts ("prefers minimal abstraction"), and it's strictly repo-scoped.
>
> ---
>
> **5. @openclaw**
>
> OpenClaw's native memory is more capable than it looks: markdown in `~/.openclaw/workspace` (a curated MEMORY.md plus dated daily logs) backed by a per-agent SQLite index with embeddings and hybrid retrieval (70% vector, 30% BM25). So it has semantic search natively.
>
> *OpenClaw memory architecture: markdown plus per-agent SQLite, hybrid retrieval, silent turn before compaction; Mem0 plugin runs cloud or self-hosted with triage / recall / dream*
> ![[mem0ai-014782-007.jpg]]
>
> The problem is what survives. When the window fills, OpenClaw fires a "silent internal turn" that asks the model to write important content to disk before clearing. What gets written is whatever the model decides in that one turn, so long-term memory is selective and inconsistent. The Mem0 plugin (@mem0/openclaw-mem0) removes that dependency: Auto-Recall injects relevant memories before each turn and Auto-Capture persists each exchange after it (new facts stored, stale ones updated, duplicates merged), scoped by session run_id and long-term userId. The 247,000-star adoption was driven substantially by this gap.
>
> Read more here: [https://mem0.ai/blog/openclaw-memory-management-live-data-compaction-and-best-practices](https://mem0.ai/blog/openclaw-memory-management-live-data-compaction-and-best-practices)
>
> ---
>
> **6. @NousResearch: Hermes Agent**
>
> Hermes (135,000 stars, 200+ models) ships three built-in layers plus eight pluggable providers. Layer 1, working memory: MEMORY.md (2,200 chars) and USER.md (1,375 chars), ~1,300 tokens combined, §-delimited with a utilization gauge and consolidation at 80% capacity. Writes land on disk but the system prompt holds a frozen snapshot until next session, to preserve the prefix cache. Layer 2, skills: procedural docs written after 5+ tool-call tasks, curated on a schedule. Layer 3, session search: SQLite FTS5 over all sessions, summarized on demand.
>
> *Hermes Agent memory architecture: three built-in layers, frozen working memory pinned for cache stability, FTS5 for older sessions, Mem0 plugs into the provider slot and removes the cap*
> ![[mem0ai-014782-008.jpg]]
>
> Shortcoming. The cap is tiny (~800 tokens of durable memory), FTS5 is keyword-only ("429 errors" won't match "rate limiting"), and it's local. Which is why Hermes ships a provider slot: with Mem0 the cap is gone, retrieval is semantic, extraction runs server-side, writes are scoped by MEM0_USER_ID, and a circuit breaker keeps the built-in layers working if the service is down.
>
> Read more here:
>
> *Embedded tweet cover: Memory in Hermes-Agent (In Context #5)*
> ![[mem0ai-014782-009.jpg]]
>
> [Embedded Tweet: https://x.com/i/status/2040149098364580026]
>
> ---
>
> **7. @awscloud Bedrock AgentCore**
>
> AgentCore is AWS's hosted agent platform: its Runtime is the harness layer (AWS's analog to Managed Agents) and Memory is its managed service. Memory runs three async extraction strategies (semantic facts, preferences, narrative summary), ~20–40s to extract and ~200ms to retrieve; changed facts are marked INVALID rather than deleted, preserving lineage. Published: LoCoMo 70.58, PrefEval 79, PolyBench-QA 83.02.
>
> Shortcoming. It's AWS-specific (ecosystem lock-in), and its published LoCoMo sits well below leading memory systems.
>
> ---
>
> **8. @windsurf**
>
> Windsurf's memory is generated and managed by its engine, Cascade, with no developer workflow: local, workspace-scoped files at `~/.codeium/windsurf/memories/` capturing codebase patterns and conventions.
>
> Shortcoming. What's captured is Cascade's call, not the developer's; memory is workspace-scoped (invisible across projects) and local (no cross-device or team sharing).
>
> ---
>
> **9. Cognition Devin**
>
> Devin splits memory in two. Knowledge is human-curated trigger-content facts (no auto-capture); DeepWiki is reference docs (30 pages, 100 notes, 10,000 chars each). Devin suggests Knowledge after sessions, but a human approves before anything is stored.
>
> Shortcoming. The approval gate keeps quality high but is friction: teams that don't review accumulate nothing. Limits are modest, and Knowledge is curated for Devin, so it doesn't transfer to other tools.
>
> ---
>
> **Memory Benchmarks Are the Weak Link**
>
> The benchmarks the field uses to measure memory are mostly bad. They test recall of facts from past conversations, they're near-saturated, and a high score doesn't predict better decisions.
>
> LoCoMo is the worst of the common ones. Ten conversations make comparisons unreliable, many questions don't require memory (a trivial grep baseline scores ~74%), and adversarial questions share surface similarity with their targets, so models win by pattern-matching. LongMemEval is still okay: 500 curated questions across five abilities (information extraction, multi-session reasoning, temporal reasoning, knowledge updates, abstention), scaling toward 1.5M tokens; still recall-centric but a real test.
>
> The deeper problem is what none of them measure. MemoryArena (arXiv:2602.16313) tests memory that must guide action, and systems that near-saturate LoCoMo and LongMemEval fail at it; Anatomy of Agentic Memory (arXiv:2602.19320) makes the critique formal (near-saturated, measuring similarity not task utility).
>
> And none test at production scale: standard benchmarks cap near 1.5M tokens while production agents hit 10M+. BEAM (ICLR 2026) is the only one built for that range. The honest conclusion: the field needs a new memory benchmark, and leaderboard scores should be read skeptically, including the ones below.
>
> ---
>
> **What Research Shows Is Still Broken**
>
> The stability-plasticity dilemma relocated. Moving to external memory didn't end catastrophic forgetting. "When Continual Learning Moves to Memory" (arXiv:2604.27003) shows new and old memories compete for retrieval slots exactly as they once competed for weights; raw trajectories from easy tasks hurt harder ones (forward transfer −9.5%).
>
> Selective forgetting is unsolved. MemoryAgentBench (arXiv:2507.05257) names four competencies; systems handle retrieval but not selective forgetting (unlearning a stale fact while keeping the structure around it).
>
> Memory is an attack surface. "No Attacker Needed" (arXiv:2604.01350) measured 57–71% cross-user contamination under normal usage; poisoning attacks succeed at 6–38% (arXiv:2601.05504).
>
> ---
>
> **The Pattern in the Shortcomings**
>
> The same gaps recur. Storage is bounded and local (Claude Code 25KB, Hermes 2,200 chars, Codex's 5,000-token load). Retrieval is mostly keyword (Claude Code by filename, Codex by grep, Hermes by FTS5); the two that search semantically are local-and-compaction-limited (OpenClaw) or cloud-locked (AgentCore). Memory is harness-scoped, so Claude Code's memory means nothing to Codex. Staleness handling barely exists (Copilot aside). And isolation is an afterthought, hence the contamination numbers. These are the limits of the harness boundary.
>
> ---
>
> **Mem0**
>
> Mem0 is built for the case where the harness boundary isn't the end of the problem. Its architecture is a hybrid: a vector store for semantic retrieval, a knowledge graph for relational reasoning, and key-value for fast metadata.
>
> The v3 algorithm (April 2026) moved to single-pass ADD-only extraction, multi-signal retrieval (semantic + BM25 + entity linking in one pass), and entity linking inside the vector store, dropping v2's external graph DB.
>
> It does this at ~6,900 tokens and 1.44s per query, against ~26,000 tokens and 17.12s for full-context retrieval.
>
> *Mem0 across the benchmarks the field actually uses — LoCoMo 92.5, LongMemEval 94.4, BEAM 1M 64.1, BEAM 10M 48.6, vs full-context baseline 72.9% at 26K tokens / 17.12s*
> ![[mem0ai-014782-010.jpg]]
>
> Against the gaps: an external store with no cap; multi-signal retrieval that finds last month's auth-endpoint discussion even when the phrasing differs; identity-scoped memory that one user's namespace can't leak across, targeting the 57–71% contamination rate. And it isn't theoretical: Mem0 ships for every harness above, a Claude Code plugin, a Codex MCP server, first-class Hermes and OpenClaw providers, native AWS Strands integration, across 21 frameworks and 20 vector stores. Memory becomes infrastructure, not a per-harness feature.
>
> ---
>
> **Where Things Stand**
>
> Memory is now infrastructure: every major harness shipped it, because an agent that's capable within a session but amnesiac across them is fundamentally limited.
>
> The harness-native implementations made real progress, but they break at the same boundary, bounded local storage, keyword retrieval, harness scoping, weak staleness handling, and isolation gaps.
>
> The benchmarks meant to measure all this are themselves weak, and the one that tests production scale (BEAM) is the one most systems don't report.
>
> Overall, these are the gaps Mem0 is working hard to fill: memory that is portable, semantically searchable, cross-agent, and scaled to the token volumes production agents accumulate.
>
> ---
>
> **In Context #11**
>
> This blog is part of In Context, a [@mem0ai](https://x.com/@mem0ai) blog series covering AI Agent memory and context engineering.
>
> Mem0 is an intelligent, open-source memory layer designed for LLMs and AI agents to provide long-term, personalized, and context-aware interactions across sessions.
>
> - Get your free API Key here: [app.mem0.ai](https://app.mem0.ai/?utm_source=x_article_mem0&utm_medium=x_article&utm_campaign=agent_harness_memory&utm_content=agent_harness_memory)
>
> - or self-host mem0 from our [open source github repository](https://github.com/mem0ai/mem0)
>
> ---
>
> **References**
>
> - [Contextual Agentic Memory is a Memo, Not True Memory (April 2026)](https://arxiv.org/abs/2604.27707)
> - [MemoryArena (February 2026, Stanford/UCSD/Princeton)](https://arxiv.org/abs/2602.16313)
> - [Anatomy of Agentic Memory (February 2026)](https://arxiv.org/abs/2602.19320)
> - [When Continual Learning Moves to Memory (April 2026)](https://arxiv.org/abs/2604.27003)
> - [MemoryAgentBench, ICLR 2026](https://arxiv.org/abs/2507.05257)
> - [No Attacker Needed: Cross-User Contamination (April 2026)](https://arxiv.org/abs/2604.01350)
> - [Memory Poisoning Attack and Defense (January 2025)](https://arxiv.org/abs/2601.05504)
> - [Anthropic Engineering: Scaling Managed Agents (April 2026)](https://anthropic.com/engineering/managed-agents)
> - [OpenAI: Codex memories documentation](https://developers.openai.com/codex/memories)
> - [AWS: Amazon Bedrock AgentCore Memory](https://aws.amazon.com/blogs/machine-learning/amazon-bedrock-agentcore-memory-building-context-aware-agents)
> - [NousResearch: Hermes Agent](https://github.com/NousResearch/hermes-agent)
> - [Mem0: Token-Efficient Memory Algorithm (April 2026)](https://mem0.ai/blog/mem0-the-token-efficient-memory-algorithm)
> - [Mem0: BEAM Benchmark](https://mem0.ai/blog/what-is-beam-memory-benchmark-the-paper-that-shows-1m-context-window-isnt-enough)
> - [Mem0: How Memory Works in Claude Code](https://mem0.ai/blog/how-memory-works-in-claude-code)
> - [Mem0: Codex CLI Memory](https://mem0.ai/blog/how-memory-works-in-codex-cli)
> - [Mem0: How Memory Works in Hermes Agent](https://mem0.ai/blog/how-memory-works-in-hermes-agent-(and-how-to-improve-it))
> - [Mem0: OpenClaw Memory System](https://mem0.ai/blog/openclaw-memory-system-how-it-works-and-how-to-set-it-up)
> - [AWS and Mem0 Partner to Bring Persistent Memory to Strands](https://mem0.ai/blog/aws-and-mem0-partner-to-bring-persistent-memory-to-next-gen-ai-agents-with-strands)
>
> Engagement: 326 likes | 35 retweets | 14 replies
> [Original post](https://x.com/mem0ai/status/2061822612398014782)

### Author self-replies (in thread)

> @mem0ai — 2026-06-02 (reply to @ClaudioDrews25)
>
> looks good!
>
> can see the ideation is drawn from hermes memory architecture
>
> curious though onto what are the extra layers for? how are they improvising onto the existing hermes memory architecture
>
> [Reply](https://x.com/mem0ai/status/2061837658952024153)

> @mem0ai — 2026-06-02 (reply to @rameswar08)
>
> checkout the articles section, you might find new things to learn!
>
> and feel free to add through if you need any explanations in memory/context space
>
> [Reply](https://x.com/mem0ai/status/2061850660921041043)
