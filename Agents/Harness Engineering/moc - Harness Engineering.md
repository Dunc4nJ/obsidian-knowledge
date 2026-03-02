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

- [[claude CLI print mode is a full agent runtime accessible via command line]]
- [[designing agent tools is an iterative art shaped by model capabilities not fixed engineering rules]]
- [[harness engineering improved a coding agent 13 points by changing only system prompts tools and middleware]]
- [[llm-tool-api-architecture-optimizing-roundtrips-tokens-and-context-like-gpu-cache-hierarchies|SebAaltonen's LLM Tool API Architecture — optimizing roundtrips, tokens, and context like GPU cache hierarchies]]
- [[code evolution harnesses multiply LLM reasoning performance 2-3x on ARC-AGI-2 without changing the model]]

## Factory Droid

- [[Factory Code Droid combines multi-model sampling and codebase-aware retrieval to achieve state-of-the-art SWE-bench performance]]
- [[Factory Droid achieves state-of-the-art on Terminal-Bench through agent design not model choice]]
- [[Factory droid-action wraps agent execution into a GitHub Actions contract with structured inputs MCP tools and STRIDE security skills]]

## Context Engineering Strategies

- [[langchain-filesystem-context|Filesystems give agents a single interface for storing, retrieving, and updating unlimited context]]
- [[langchain-rise-of-context-engineering|Context engineering supersedes prompt engineering as the core skill for AI engineers]]
- [[openai-session-memory|OpenAI Agents SDK Session object enables trimming and summarization for multi-turn context management]]
- [[openai-context-personalization|State-based memory with distillation and consolidation enables persistent agent personalization]]
- [[anthropic-mcp-code-execution|Agents that write code to call MCP tools reduce context overhead by 98.7 percent]]
