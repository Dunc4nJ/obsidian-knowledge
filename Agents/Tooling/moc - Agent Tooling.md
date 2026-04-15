---
created: 2026-02-27
description: Navigation hub for agent tooling — tool design, search strategies, prompt caching, skill architecture, and context management for AI agents.
source: internal
type: moc
---

# Agent Tooling

How to design, describe, and orchestrate tools that agents actually use well.

## Notes

- [[agent-first engineering replaces coding with environment design scaffolding and feedback loops]] — shifting from writing code to designing agent environments
- [[agentic image generation loop]] — iterative image generation with agent-in-the-loop
- [[agentic search with grep and full-file loading replaces RAG when context windows are large enough]] — grep+load vs RAG tradeoffs at scale
- [[capturing internal APIs can replace most agent browser automation]] — API capture as a faster alternative to browser agents
- [[context tax compounds through cache misses bloated tools and unbudgeted output tokens]] — hidden costs of poor context management
- [[prompt caching is the foundational constraint for building long-running agents]] — caching as the key architectural constraint
- [[six cache-friendly patterns from Claude Code make prompt caching practical for production agents]] — static-first ordering, frozen tools, subagent isolation, cache-safe compaction
- [[auto-caching with Claude eliminates manual breakpoint management for multi-turn agents]] — auto-caching API mechanics and the economic case for cached tokens
- [[rewriting tool descriptions with curriculum learning improves agent tool use without execution traces]] — curriculum-based tool description optimization
- [[skill graphs outperform single skill files by letting agents traverse linked domain knowledge on demand]] — graph-structured skills vs flat skill files
- [[skill workflows]] — workflow patterns for agent skills
- [[dev-browser lets agents write Playwright code in a sandboxed QuickJS VM for fast browser automation]]
- [[one tmux session per project with directory-named sessions eliminates session management friction]] — directory-named tmux sessions with shell helpers and vim keybindings

## OCR

Document OCR models, benchmarks, and large-scale processing pipelines.

- [[LightOnOCR-2 outscores proprietary models at table extraction with 1B parameters]] — 1B open-source model beats GPT-5 mini, Claude Sonnet 4.6, and Mathpix on independent table extraction benchmark
- [[HuggingFace OCRed 30K arXiv papers with Chandra-OCR 2 on parallel L40S GPU jobs for 850 dollars]] — end-to-end playbook: Chandra-OCR 2 via vLLM on 16 parallel L40S jobs, orchestrated by Codex, ~$850 for 27K papers
