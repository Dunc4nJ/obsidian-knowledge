---
created: 2026-03-02
description: Production AI agents (Claude Code, Cursor, Manus, Devin, SWE-Agent) all converge on the same architecture — a simple loop, primitive tools, and progressive disclosure of context — making the harness, not the model, the real product.
source: https://x.com/Hxlfed14/status/2028116431876116660
type: synthesis
---

# Agent Harness is the Real Product

## Key Takeaways

The harness — everything around the model (loop, tools, error recovery, context management) — matters more than the model itself. Claude Opus 4.5 scores 42% with one scaffold and 78% with another on CORE-Bench; LangChain's deepagents-cli gained 13.7 points on TerminalBench by changing only the harness ([[langchain-harness-engineering]]). This is the central thesis of the piece.

Every production agent converges on a single flat `while(tool_call)` loop. No DAG orchestration, no competing agent personas. Anthropic calls it "the model controls the loop" ([[anthropic-effective-harnesses]]). Cursor, Manus, and SWE-Agent all arrive at the same pattern independently.

Progressive disclosure — showing only what's needed now, revealing complexity on demand — is the architectural pattern that separates working agents from demos. Claude Code's SKILL.md files load on demand rather than being injected into every conversation. Cursor's lazy MCP tool loading cuts tokens by 46.9%. Manus offloads state to the filesystem. All are implementations of the same principle borrowed from UI/UX design ([[honra-progressive-disclosure]]).

The "lost in the middle" problem ([[arxiv-lost-in-the-middle]]) provides the theoretical backing: LLM performance follows a U-shaped curve with relevant information at beginning or end scoring highest. Progressive disclosure keeps inputs small (less distortion) and places fresh information at the end (high-attention zone).

Fake planning tools are a convergent pattern. Claude Code's TodoWrite is a no-op that forces the agent to articulate its plan ([[langchain-deep-agents]]). Manus rewrites todo.md each step. These keep agents coherent over long trajectories.

The teams shipping the best agents keep simplifying. Manus did five rewrites, each removing things. Vercel deleted 80% of tools and their agent went from failing to succeeding ([[phil-schmid-context-engineering-pt2]]). The 12 Factor Agents methodology puts the threshold at 40% of model input capacity before entering the "dumb zone" ([[horthy-12-factor-agents]]).

Active disagreement remains on tool overload strategy: Manus uses logit masking (all tools loaded, constrain outputs) while Cursor uses lazy loading (fetch definitions on demand) ([[manus-context-engineering]], [[cursor-dynamic-context-discovery]]). Both work — the right answer may depend on token economics.

See also the companion tweet thread: [Himanshu on agent harness patterns](https://x.com/Hxlfed14/status/2022984467380682856).

## External Resources

- [[anthropic-effective-context-engineering]] — Anthropic's guide to context engineering for AI agents
- [[anthropic-effective-harnesses]] — Anthropic's post on harness design for long-running agents
- [[cursor-dynamic-context-discovery]] — Cursor's dynamic context discovery architecture
- [[cursor-semantic-search]] — Cursor's custom semantic search trained on agent session traces
- [[cursor-codex-model-harness]] — Cursor's per-model harness tuning for OpenAI Codex
- [[manus-context-engineering]] — Manus's context engineering lessons from five framework rewrites
- [[langchain-deep-agents]] — LangChain's analysis of deep agent architectures
- [[langchain-harness-engineering]] — LangChain's harness engineering improvements on TerminalBench
- [[swe-agent-neurips-2024]] — Princeton's SWE-Agent and the Agent-Computer Interface concept
- [[arxiv-lost-in-the-middle]] — Liu et al. on how LLMs use long contexts (U-shaped attention curve)
- [[phil-schmid-context-engineering-pt2]] — Phil Schmid's quantitative analysis of context engineering
- [[cognition-devin-performance-review]] — Devin's 2025 performance review (67% PR merge rate)
- [[horthy-12-factor-agents]] — 12 Factor Agents methodology and the 40% threshold
- [[promptlayer-claude-code-loop]] — PromptLayer's reverse-engineering of Claude Code's agent loop
- [[vrungta-claude-code-reverse-engineered]] — Vrungta's reverse-engineering of Claude Code's architecture
- [[honra-progressive-disclosure]] — Progressive disclosure applied to AI agent design
- [[karpathy-2025-year-in-review]] — Karpathy's 2025 LLM year in review
- [[jannesklaas-agent-design-claude-code]] — Agent design lessons from Claude Code

## Original Content

> [!quote]- Original tweet article by @Hxlfed14 (Himanshu) — Sun Mar 01, 2026 | 459 likes, 49 retweets, 15 replies
>
> *Article header image*
> ![[harness-real-product-001.jpg]]
>
> **Agent Harness is the Real Product**
>
> Everyone talks about models. Nobody talks about the scaffolding.
>
> The companies shipping the best AI agents today- Claude Code, Cursor, Manus, Devin, SWE-Agent all converge on the same architecture: a deliberately simple loop wraps the model, a handful of primitive tools give it hands, and the scaffolding decides what information reaches the model and when.
>
> The model is interchangeable. The harness is the product.
>
> Here is the evidence:
>
> > Claude Opus 4.5 scores 42% on CORE-Bench with one scaffold and 78% with another.
>
> > Cursor's lazy tool loading cuts token usage by 46.9%.
>
> > Vercel deleted 80% of their agent's tools and watched it go from failing tasks to completing them.
>
> Same model. Same benchmark. The only variable is the harness.
> And the single most underrated pattern inside these harnesses?
>
> Progressive disclosure- agents discovering context incrementally instead of drowning in everything upfront.
>
> This article breaks down what a harness actually is, how each company builds theirs, and why progressive disclosure is the pattern that separates working agents from impressive demos.
>
> Sources analyzed (all listed at the end).
>
> ---
>
> ### What Is an Agent Harness?
>
> Harrison Chase (LangChain) draws the sharpest distinction: "A framework is abstractions... pretty unopinionated. Harnesses are batteries included."
>
> Source: [[langchain-harness-engineering]]
>
> An agent harness is everything around the model that makes it useful: the execution loop, tool definitions, error recovery, state management, and information flow. The model decides what to do. The harness decides what the model can see, what tools it can use, and what happens when it fails.
>
> Every production agent converges on this core loop:
>
> > while (model returns tool calls):
>  execute tool → capture result → append to context → call model again
>
> *The core agent loop: harness assembles input, LLM decides, tools execute, harness checks*
> ![[harness-real-product-002.png]]
>
> That is it. The entire architecture of Claude Code, Cursor's agent, and Manus fits inside that loop. The engineering is in what surrounds it.
>
> ---
>
> ### How Each Company Builds Its Harness
>
> **Claude Code: "The Model Controls the Loop"**
>
> Context: Claude Code's architecture has been reverse-engineered extensively and Anthropic has published detailed posts on their harness design. The core is a single flat message list with ~18 primitive tools.
>
> Source: [[anthropic-effective-harnesses]]
>
> The loop. Internally codenamed nO, it is a while(tool_call) loop. No DAG orchestration, no competing agent personas. The model receives messages and tools, returns text (loop ends) or tool calls (loop continues). Anthropic explicitly calls this "the model controls the loop" rather than "code controls the model."
>
> The tools. ~18 primitives in four categories: command-line discovery (Bash, Glob, Grep, LS), file interaction (Read, Write, Edit, MultiEdit), web access (WebSearch, WebFetch), and orchestration (TodoWrite, Task). The philosophy is primitives over integrations. Notably, Anthropic chose regex (ripgrep) over vector databases for code search, reasoning that Claude's code understanding enables sophisticated regex crafting without search indices.
>
> Source: [[promptlayer-claude-code-loop]]
>
> The information layering. Six layers loaded at session start: organization policies, project-level CLAUDE.md, user settings, auto-learned MEMORY.md, session history, and git state. The system prompt comprises ~110+ conditional strings (~2,896 token core). A critical but underappreciated harness pattern: tool results carry injected system reminders fixed text appended after every tool execution. This achieves higher behavioral adherence than system-prompt-only instructions because it repeats with every call.
>
> Source: [[vrungta-claude-code-reverse-engineered]]
>
> Error recovery. Primarily model-driven. Failed tool executions return error messages as tool results, and the model decides what to do. The TodoWrite tool serves as a "progress anchor" after errors, the model consults its TODO list to know where it was.
>
> The insight that matters: Claude Code's TodoWrite tool does nothing functionally. It is purely a harness-level trick- a no-op tool that forces the agent to articulate and track its plan, keeping it on course over long trajectories. LangChain's "Deep Agents" analysis calls it out explicitly.
>
> Source: [[langchain-deep-agents]]
>
> ---
>
> **Cursor: "Files as the Fundamental Primitive"**
>
> Context: Cursor published "Dynamic Context Discovery" (Jan 2026) and a separate post on model-specific harness tuning. Their architecture has five components: Router, LLM, 10+ tools, context retrieval, and a ReAct-style orchestrator.
>
> Source: [[cursor-dynamic-context-discovery]]
>
> The key decision. Cursor tunes its harness specifically for every frontier model based on internal evals. Different models get different tool names, prompt instructions, and behavioral guidance. OpenAI Codex models get shell-oriented tool names like rg; Claude models get different reasoning summary formats.
>
> Source: [[cursor-codex-model-harness]]
>
> Files as context primitive. Everything in Cursor's architecture maps to files. Why? Because files enable powerful searching (ripgrep, jq, grep, semantic search), are naturally groupable (one folder per MCP server), and are versionable. Their exact words: "Files have been a simple and powerful primitive to use, and a safer choice than yet another abstraction."
>
> Custom semantic search. Their embedding model is trained using agent session traces as training data- when an agent works through a task, Cursor analyzes which files should have been retrieved earlier, then trains the embedding model to match those patterns. Result: 12.5% higher search accuracy on average and 2.6% higher code retention on large codebases (1,000+ files).
>
> Source: [[cursor-semantic-search]]
>
> ---
>
> **Manus: "KV-Cache Above All Else"**
>
> Context: Manus has rewritten their framework five times since launch. Their average input-to-output token ratio is ~100:1. They call the iterative process "Stochastic Gradient Descent."
>
> Source: [[manus-context-engineering]]
>
> *Manus: mask tools via logit constraints instead of removing them to preserve KV-cache*
> ![[harness-real-product-003.jpg]]
>
> Logit masking over tool removal. Manus tried adding and removing tools dynamically and rejected it- any change to tool definitions near the front of the context invalidates the KV-cache for all subsequent tokens. Instead, all ~29 tools remain permanently loaded. Availability per step is controlled by constraining output token probabilities during decoding. Tool naming uses consistent prefixes (browser_*, shell_*, file_*) for group-level masking.
>
> Hierarchical action space. Three levels: Level 1 (~20 atomic function-call tools), Level 2 (sandbox utilities invoked via Bash- grep, ffmpeg, MCP tools via mcp-cli), Level 3 (dynamic scripts using pre-installed libraries). This keeps tool definitions out of the context window while preserving full capability.
>
> The biggest lesson. Their biggest performance gains came from removing things; complex tool definitions replaced by shell execution, "management agents" replaced by simple handoffs. If your agent harness is getting more complex while models get better, something is wrong.
>
> ---
>
> **SWE-Agent: "The Agent-Computer Interface"**
>
> Context: Princeton's SWE-Agent introduced the ACI (Agent-Computer Interface) concept at NeurIPS 2024, purpose-built interfaces designed specifically for LLM agents rather than humans.
>
> Source: [[swe-agent-neurips-2024]]
>
> Linter-gated edits. When the agent issues an edit command, a linter runs automatically. If the code isn't syntactically correct, the edit is rejected and the agent must retry. Without this single harness-level guardrail, performance drops 3%.
>
> Observation compression. All observations except the last 5 are collapsed to a single line each. The agent sees full detail for recent actions and summaries for older ones, a form of progressive disclosure baked into the loop.
>
> ---
>
> **The Others: Devin, Windsurf, Aider, Replit**
>
> Devin runs in isolated cloud VMs with a Playbook system for repeated tasks and a Knowledge Management System where feedback is codified for future reference. 67% PR merge rate, up from 34% a year ago.
>
> Source: [[cognition-devin-performance-review]]
>
> Windsurf uses a two-agent architecture: a planning agent runs continuously in the background refining a long-term plan while the primary model handles short-term actions. Their "Memories" system generates observations about codebase patterns across sessions.
>
> Aider has the most technically novel context strategy: a PageRank-based repository map built using tree-sitter. It parses code to extract definitions, builds a graph where files are nodes and dependencies are edges, applies PageRank to rank symbols by importance, and uses binary search to fit the most critical content within a token budget.
>
> Replit Agent evolved from a single agent to a three-agent architecture (Manager, Editor, Verifier) after finding that single-agent error rates were too high. Self-healing loop: generate → execute → test with Playwright → fix → rerun.
>
> ---
>
> ### Progressive Disclosure: The Pattern Nobody Has Named
>
> Progressive disclosure is borrowed from UI/UX design, originated by John Carroll at IBM Research in the 1980s, popularized by Jakob Nielsen in the 1990s. The principle: show only what is needed now, reveal complexity on demand.
>
> The mapping to agent design is direct. Just as collapsible menus reduce cognitive load for humans, layered context loading reduces attention fragmentation for LLMs.
>
> Source: [[honra-progressive-disclosure]]
>
> ---
>
> ### How production systems implement it
>
> Claude Code's SKILL.md pattern. Skills are stored as .claude/skills/ files and are NOT preloaded into every conversation. Unlike CLAUDE.md (loaded every session), skills load only when Claude detects relevance. The system prompt describes it as "on-demand loading" — Claude reads slide-decks.md only when creating presentations. This prevents context bloat when a project has dozens of skills.
>
> Source: [[anthropic-effective-context-engineering]]
>
> Cursor's lazy MCP tool loading. MCP servers include many tools with long descriptions; most go unused. Cursor syncs tool descriptions to a folder structure and gives the agent only tool names as static context. Full definitions are fetched on-demand. In A/B testing: 46.9% token reduction (statistically significant).
>
> Manus's filesystem offloading. The agent writes to and reads from files on demand. Compression is designed to be reversible: drop a web page's content if the URL is preserved; omit a document if its file path remains. The todo.md rewriting pattern pushes the global plan into the model's recent attention span  directly counteracting "lost in the middle."
>
> **The quantitative case**
>
> The numbers across multiple independent sources are consistent:
>
> Token efficiency.
>
> - Claude-Mem documentation shows static loading injects 25,000 tokens at 0.8% efficiency (one relevant observation in noise). Progressive disclosure: 955 tokens at 100% efficiency. ~26x improvement.
>
> - Cursor's lazy loading: 46.9% reduction.
>
> - Vercel's case study: removing 80% of tools dropped tokens from 145,463 to 67,483, steps from 100 to 19, latency from 724 to 141 seconds and the agent went from failing to succeeding.
>
> Source: [[phil-schmid-context-engineering-pt2]]
>
> The scaffold matters more than the model.
>
> - CORE-Bench: Claude Opus 4.5 scored 42% with one scaffold, 78% with another.
>
> - Sonnet 4: 33% vs 47%. Sonnet 4.5: 44% vs 62%.
>
> - LangChain's deepagents-cli went from 52.8% to 66.5% on TerminalBench 2.0 (13.7 points) by changing only the harness.
>
> Source: [[langchain-harness-engineering]]
>
> Why harnesses need this. Liu et al. (TACL 2024) demonstrated that LLM performance follows a U-shaped curve-  highest when relevant information is at the beginning or end of the input, degraded in the middle. Even long-context models. This is why the harness matters: progressive disclosure keeps inputs small (less curve distortion) and places freshly-retrieved information at the end (the high-attention zone).
>
> Source: [[arxiv-lost-in-the-middle]]
>
> ---
>
> ### The Technique Matrix
>
> Quick-reference mapping harness techniques to agent systems based on public documentation.
>
> Legend: 
> [C] = Core differentiator 
> [Y] = Uses/advocates  
> [--] = Not discussed publicly  
> [alt] = Different approach
>
> *Technique matrix: Loop Architecture*
> ![[harness-real-product-004.png]]
>
> *Technique matrix: Progressive Disclosure*
> ![[harness-real-product-005.png]]
>
> *Technique matrix: Error Handling and Robustness*
> ![[harness-real-product-006.png]]
>
> ---
>
> ### Where The Industry Agrees (and Where It Doesn't)
>
> Near-consensus: The single flat loop wins over complex orchestration. File system as extended memory. Errors preserved, not cleaned. Fake planning tools (TodoWrite, todo.md) for coherence. Primitives (bash, grep, filesystem) over custom integrations.
>
> Active disagreement: How to handle tool overload. Manus uses logit masking (all tools loaded, constrain outputs). Cursor uses lazy loading (load tool definitions on demand). Opposite strategies. Both work. The right answer might depend on your token economics.
>
> Active disagreement: How much should the harness manage for the model? Google's bet is "give the model everything, let it figure it out" (2M token windows). Everyone else builds harnesses that actively filter and stage information. Research still shows 15-47% performance drops as input grows. The harness-heavy approach is winning in practice.
>
> Unsolved: How to evaluate harness quality. Cursor's 46.9% token reduction is one of very few published numbers. No standard benchmarks exist for comparing harness designs head-to-head. When to share sub-agent state vs isolate it is still purely empirical.
>
> The pattern worth noting: The teams shipping the best agents keep simplifying. Manus: five rewrites, each one removed things. Anthropic designs Claude Code's scaffold to shrink as models improve. Replit went from one agent to three but each individual agent got simpler. Over-engineering is the default failure mode.
>
> ---
>
> ### What This Means If You Are Building Agents
>
> Three things this research makes clear:
>
> 1. Spend your engineering cycles on the harness, not on model shopping.
>
> 2. Progressive disclosure is not optional, it is architectural.
>
> 3. Plan for your harness to get simpler, not more complex.
>
> Dex Horthy (creator of the "12 Factor Agents" methodology) puts the threshold at 40% of the model's input capacity: push past that and you enter what he calls the "dumb zone" - signal-to-noise degrades, attention fragments, and agents start making mistakes that look like reasoning failures but are actually information overload from a poorly designed harness.
>
> Source: [[horthy-12-factor-agents]]
>
> The model is the engine. The harness is the car. Nobody buys an engine.
>
> ---
>
> ### References
>
> 1. [[anthropic-effective-context-engineering]] — Anthropic - "Effective Context Engineering for AI Agents" (Sep 2025)
>
> 2. [[anthropic-effective-harnesses]] — Anthropic - "Effective Harnesses for Long-Running Agents" (Jan 2026)
>
> 3. [[cursor-dynamic-context-discovery]] — Cursor - "Dynamic Context Discovery" (Jan 2026)
>
> 4. [[cursor-semantic-search]] — Cursor - "Improving Agent with Semantic Search" (2026)
>
> 5. [[cursor-codex-model-harness]] — Cursor - "Improving Cursor's Agent for OpenAI Codex Models" (2026)
>
> 6. [[manus-context-engineering]] — Manus - "Context Engineering for AI Agents: Lessons from Building Manus" (Jul 2025)
>
> 7. [[langchain-deep-agents]] — LangChain - "Deep Agents" (Jul 2025)
>
> 8. [[langchain-harness-engineering]] — LangChain - "Improving Deep Agents with Harness Engineering" (Feb 2026)
>
> 9. [[swe-agent-neurips-2024]] — Yang et al. - "SWE-agent: Agent-Computer Interfaces Enable Automated Software Engineering" (NeurIPS 2024)
>
> 10. [[arxiv-lost-in-the-middle]] — Liu et al. - "Lost in the Middle: How Language Models Use Long Contexts" (TACL 2024)
>
> 11. [[phil-schmid-context-engineering-pt2]] — Phil Schmid - "Context Engineering for AI Agents: Part 2" (Dec 2025)
>
> 12. [[cognition-devin-performance-review]] — Cognition - "Devin's 2025 Performance Review" (2025)
>
> 13. [[horthy-12-factor-agents]] — Horthy - "12 Factor Agents"
>
> 14. [[promptlayer-claude-code-loop]] — PromptLayer - "Claude Code: Behind-the-Scenes of the Master Agent Loop"
>
> 15. [[vrungta-claude-code-reverse-engineered]] — Vrungta - "Claude Code Architecture (Reverse Engineered)"
>
> 16. [[honra-progressive-disclosure]] — Honra - "Why AI Agents Need Progressive Disclosure, Not More Data"
>
> 17. [[karpathy-2025-year-in-review]] — Karpathy - "2025 LLM Year in Review"
>
> 18. [[jannesklaas-agent-design-claude-code]] — Jannesklaas - "Agent Design Lessons from Claude Code"
>
> [Original tweet](https://x.com/Hxlfed14/status/2028116431876116660)
