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

## Notes

- [[lessons from building AI agents for financial services — sandbox skills streaming and eval at Fintool]] — Bustamante's full architecture breakdown: sandboxed execution, S3-first storage, markdown skills, Temporal orchestration, domain evals
- [[claude CLI print mode is a full agent runtime accessible via command line]]
- [[designing agent tools is an iterative art shaped by model capabilities not fixed engineering rules]]
- [[harness engineering improved a coding agent 13 points by changing only system prompts tools and middleware]]
- [[llm-tool-api-architecture-optimizing-roundtrips-tokens-and-context-like-gpu-cache-hierarchies|SebAaltonen's LLM Tool API Architecture — optimizing roundtrips, tokens, and context like GPU cache hierarchies]]
- [[code evolution harnesses multiply LLM reasoning performance 2-3x on ARC-AGI-2 without changing the model]]
- [[LLMs can synthesize their own code harness via tree search eliminating illegal actions and outperforming larger models]]
- [[terminal-native coding agents need scaffolding-harness separation and context engineering as first-class concerns]] — OpenDev technical report: compound AI architecture, adaptive context compaction, defense-in-depth safety, five transferable design lessons (81-page paper)
- [[the harness is the product because model capability is commoditizing while accumulated context is not]] — four-pillar harness framework (context architecture, agent specialization, persistent memory, structured execution) with guardrail hierarchy and production checklist
- [[agent harness components can be derived from first principles by working backwards from desired agent behavior]] — LangChain's Viv Trivedy derives harness components (filesystem, bash, sandbox, memory, context management, long-horizon execution) from model limitations, plus model-harness co-evolution dynamics

## Factory Droid

### Architecture & Performance
- [[Factory Code Droid combines multi-model sampling and codebase-aware retrieval to achieve state-of-the-art SWE-bench performance]]
- [[Factory Droid achieves state-of-the-art on Terminal-Bench through agent design not model choice]]
- [[Factory positions Droid as an agent-native platform spanning CLI web Slack Linear and mobile with a community-driven plugin ecosystem]]

### Execution & Configuration
- [[Factory droid exec uses tiered autonomy levels to gate agent permissions from read-only to full system access]]
- [[AGENTS.md is a cross-agent convention for injecting repo-level context via proximity-based file discovery]]
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
