---
created: 2026-02-28
description: Navigation hub for harness engineering — system prompts, tool descriptions, middleware, and agent scaffolding design.
type: moc
---

# Harness Engineering

Designing the scaffolding around agents — system prompts, AGENTS.md patterns, soul files, tool descriptions, prompt engineering, and middleware between the model and the world.

## Deep Dives

- [[agent harness is the real product]] — synthesis of how Claude Code, Cursor, Manus, Devin, and SWE-Agent converge on the same architecture, with 17 reference notes
- [[how top ai companies handle context engineering]] — compendium of six-company context-engineering strategies, tradeoffs, and technique matrix

## Dynamic Workflows

- [[Claude Code dynamic Workflows synthesize a per-task agent harness at runtime opening a third scaling axis]] — (@necmttn) the model writes the orchestration program on the fly using agent(), parallel(), pipeline(), and typed JSON schema output; adds generated-harness compute as a third scaling axis
- [[Claude Code dynamic workflows write a custom JS harness per task to structurally prevent agentic laziness self-preferential bias and goal drift]] — (Thariq Shihipar, Anthropic) canonical launch post: six patterns, three failure modes, quarantine for untrusted input, workflows-as-skills
- [[Claude Code Dynamic Workflows practical mastery maps failure modes to pattern compositions — fan-out for drift, adversarial for self-preference, tournament for taste, loop for open-ended work]] — (@0xCodez) 14-step practitioner guide: explicit failure-mode → pattern mapping, composition matrix per use case, /goal + token budget cost controls, eight anti-patterns
- [[samueljmcd argues Claude Code Dynamic Workflows earn their cost only when tasks are wide, independently verifiable, and have clear validation criteria — everything else is expensive theatre]] — (Samuel McDonnell) production AI engineer's honest accounting: adversarial clean-context verification layer is the real innovation; token costs compound to 50-100x at ultracode scale; decision rule is wide+independent+checkable; versioned JS orchestration scripts are infrastructure not chat history

## Notes

- [[PostHog learned your agent harness is not your moat and switched to the Claude Agent SDK after three iterations]] — PostHog's three harness iterations (coordinator → single loop with 44 tools → Claude Agent SDK + MCP + sandbox), plus lessons on MCP-first architecture, context engineering, observability, and user-centric priorities

- [[most popular CLAUDE.md files add noise not signal with a 556 to 1 copy-to-contribution ratio]] — Augment Code's analysis: ETH Zurich found context files reduce success rates, 556:1 copy ratio on agent rules repos, pruning rubric for failure-driven instructions
- [[lessons from building AI agents for financial services — sandbox skills streaming and eval at Fintool]] — Bustamante's full architecture breakdown: sandboxed execution, S3-first storage, markdown skills, Temporal orchestration, domain evals
- [[claude CLI print mode is a full agent runtime accessible via command line]]
- [[designing agent tools is an iterative art shaped by model capabilities not fixed engineering rules]]
- [[harness engineering improved a coding agent 13 points by changing only system prompts tools and middleware]]
- [[Cursor strips guardrails and adds dynamic context as models improve, inverting the harness's job]] — Stefan Heule & Jediah Katz (Apr 2026): Cursor's late-2024 guardrails (lint surfacing, file-read rewriting, tool-call caps, static context dumps) are mostly gone, replaced with dynamic context the agent fetches itself; introduces Keep Rate and stack-trace-paste as zero-instrumentation quality signals; per-tool/per-model anomaly baselines; provisions each model with the tool format from its training distribution; mid-chat switch handling
- [[LangChain's Better-Harness uses eval-driven hill-climbing for agent harness improvement]]
- [[Deep Agents v0.6 splits the agent harness into five composable primitives - code interpreter, per-model profiles, typed streaming, delta channels, and ContextHub backend]] — Sydney Runkle's v0.6 release: model-agnostic PTC via QuickJS interpreter middleware, harness profiles as a versionable per-model bundle (Terminal-Bench 2.0 +13.7pts from harness changes alone), v3 typed streaming, delta-channel checkpoints (200-turn coding session: 5.27 GB → 129 MB, 41.7× reduction), and ContextHubBackend Git-versioned filesystem for prompts/skills/memories
- [[Deep Agents interpreter middleware gives agents a programmable middle lane between serial tool loops and full sandboxes through explicit host-runtime bridges]] — Hunter Lovell's "Give your agents an interpreter": the QuickJS interpreter as narrow-by-default harness middleware (no FS/network/shell by default), explicit-bridge capability grants for PTC/subagents, interpreter state as a third context surface (join message history + filesystem), and up to 35% token reduction on OOLONG trec-coarse tasks via model-agnostic PTC
- [[interpreter skills package deterministic agent routines as versioned TypeScript modules that the model invokes but cannot rewrite]] — Hunter Lovell's follow-up: interpreter skills extend SKILL.md with an index.ts module the agent imports inside the interpreter, turning "best known routines" into reviewable/testable code APIs (model decides when to call, code defines how); canonical use case: repo triage fanning out to hundreds of subagents with typed result objects; evaluation shifts from fuzzy instruction-following to binary function-call verification
- [[agent middleware hooks decouple business logic from the core agent loop enabling composable customization]]
- [[llm-tool-api-architecture-optimizing-roundtrips-tokens-and-context-like-gpu-cache-hierarchies|SebAaltonen's LLM Tool API Architecture — optimizing roundtrips, tokens, and context like GPU cache hierarchies]]
- [[code evolution harnesses multiply LLM reasoning performance 2-3x on ARC-AGI-2 without changing the model]]
- [[LLMs can synthesize their own code harness via tree search eliminating illegal actions and outperforming larger models]]
- [[terminal-native coding agents need scaffolding-harness separation and context engineering as first-class concerns]] — OpenDev technical report: compound AI architecture, adaptive context compaction, defense-in-depth safety, five transferable design lessons (81-page paper)
- [[the harness is the product because model capability is commoditizing while accumulated context is not]] — four-pillar harness framework (context architecture, agent specialization, persistent memory, structured execution) with guardrail hierarchy and production checklist
- [[agent harness components can be derived from first principles by working backwards from desired agent behavior]] — LangChain's Viv Trivedy derives harness components (filesystem, bash, sandbox, memory, context management, long-horizon execution) from model limitations, plus model-harness co-evolution dynamics
- [[the agent harness is the RL training environment not deployment infrastructure bolted on after]] — comprehensive survey of how Cursor, Cognition, OpenAI, and Windsurf train inside production harnesses, with six research papers confirming environment quality sets the ceiling on model capability
- [[Harness-1 offloads search bookkeeping into a stateful harness so a 20B RL policy beats frontier searchers on curated recall]] — Chroma/Illinois (arXiv 2606.02373): retrieval-agent RL reframed as harness design; the harness owns candidate pool, importance-tagged curated set, evidence graph, verification cache, sentence-BM25 compression, MinHash dedup, budget renderer — the policy keeps only semantic decisions. Same-LLM harness ablation: +4.2 pts recall for GPT-5.4 just from switching Context-1 harness → Harness-1 harness. Note lives in Agentic Search
- [[Open SWE distills enterprise coding agent patterns into a composable open-source framework]] — LangChain's open-source framework capturing converging patterns from Stripe Minions, Ramp Inspect, and Coinbase Cloudbot: pluggable sandboxes, curated tools, subagent orchestration, middleware hooks, Slack-first invocation

- [[build vs buy for coding agent orchestration depends on stack complexity and appetite for maintenance]] — Zach Lloyd (Warp) on build-vs-buy for cloud agent orchestration: 12 infrastructure primitives, MVP trap, and when to own vs. buy the stack
- [[GAN-inspired generator-evaluator harness improves long-running coding agents]] — Anthropic Labs: GAN-inspired planner/generator/evaluator architecture produces full-stack apps over multi-hour autonomous sessions, with sprint contracts and Playwright-based QA

## Factory Droid

### Architecture & Performance
- [[Factory Code Droid combines multi-model sampling and codebase-aware retrieval to achieve state-of-the-art SWE-bench performance]]
- [[Factory Droid achieves state-of-the-art on Terminal-Bench through agent design not model choice]]
- [[Factory positions Droid as an agent-native platform spanning CLI web Slack Linear and mobile with a community-driven plugin ecosystem]]

### Execution & Configuration
- [[Factory droid exec uses tiered autonomy levels to gate agent permissions from read-only to full system access]]
- [[AGENTS.md is a cross-agent convention for injecting repo-level context via proximity-based file discovery]]
- [[model + System outlasts Harness, production agents need database-backed memory, RBAC, and isolation]]
- [[Factory Droid plugins bundle skills commands hooks and MCP servers into distributable packages with marketplace-based discovery]]
- [[Factory plugins marketplace uses a git-native catalog with SKILL.md files as the primary distribution unit for agent capabilities]]

### CI & Review Integration
- [[Factory droid-action wraps agent execution into a GitHub Actions contract with structured inputs MCP tools and STRIDE security skills]]
- [[Factory droid-code-review reveals how prompt-driven agents map LLM outputs to GitHub-native review primitives through position-based inline commenting and stateful deduplication]]
- [[Terminal-Bench leaderboard requires five full runs with raw logs to enforce reproducibility over cherry-picked results]]

### Context & Compaction
- [[Factory treats context as a scarce resource that must be budgeted and curated across layered scaffolding]]
- [[factory uses incremental anchored summaries to compress agent context]]
- [[structured summarization preserves more agent context than opaque compression]]

## Context Engineering Strategies

- [[langchain-filesystem-context|Filesystems give agents a single interface for storing, retrieving, and updating unlimited context]]
- [[langchain-rise-of-context-engineering|Context engineering supersedes prompt engineering as the core skill for AI engineers]]
- [[openai-session-memory|OpenAI Agents SDK Session object enables trimming and summarization for multi-turn context management]]
- [[openai-context-personalization|State-based memory with distillation and consolidation enables persistent agent personalization]]
- [[anthropic-mcp-code-execution|Agents that write code to call MCP tools reduce context overhead by 98.7 percent]]
- [[CLAUDE.md is the highest-leverage harness config but hits a 150-200 instruction ceiling before compliance decays linearly]]
  - [[agent harnesses are the product not the model]]
  - [[Claude Code's edge comes from its software harness not the model]]
  - [[Databricks coSTAR closes the agent testing gap with coupled judge-alignment and agent-refinement loops]]
  - [[Open models now match closed frontier models on core agent harness tasks at a fraction of the cost]]
