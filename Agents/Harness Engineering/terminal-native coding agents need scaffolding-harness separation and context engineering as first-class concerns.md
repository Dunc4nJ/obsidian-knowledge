---
created: 2026-03-08
description: First comprehensive technical report for an open-source terminal-native coding agent (OpenDev), documenting compound AI architecture with per-workflow LLM routing, scaffolding vs harness separation, adaptive context compaction, defense-in-depth safety, and five transferable design lessons.
source: https://arxiv.org/abs/2603.05344
type: framework
---

## Key Takeaways

This is the first published technical report for an open-source, terminal-native, interactive coding agent — filling a gap where Claude Code is closed-source, Aider/Goose/OpenCode lack published reports, and SWE-Agent/OpenHands target benchmarks or browser UIs rather than interactive terminal use. The paper's value is explicitly not algorithmic novelty but rather documenting [[harness engineering improved a coding agent 13 points by changing only system prompts tools and middleware|the harness engineering decisions]] that make the difference between a demo and a production system.

The **scaffolding vs harness** distinction is the paper's organizing principle: scaffolding is everything that assembles the agent before the first prompt (system prompt compilation, tool schema construction, subagent registration), while the harness is everything after (tool dispatch, context management, safety enforcement, session persistence). Eager construction during scaffolding guarantees every agent is fully initialized before runtime — no lazy prompt assembly, no first-call latency, no race conditions with MCP discovery. This maps directly to the insight that [[designing agent tools is an iterative art shaped by model capabilities not fixed engineering rules|tool design is iterative]] — but here the iteration is on the harness, not the model.

The **compound AI system** architecture assigns five specialized model roles (normal execution, thinking, critique, compaction, VLM) to distinct LLMs, each independently configurable per workflow. This makes the system model-agnostic by construction: switching providers requires only a config change, and techniques like learned model routing can be applied at the workflow level. Every agent in the system is a single parameterized class (`MainAgent`) — behavioral variation comes from construction parameters (allowed tools, system prompt overrides), not class hierarchies. An early class hierarchy was abandoned because it created diamond problems when subagents needed mixed capabilities.

**Context engineering as first-class concern** is the paper's strongest operational lesson. Tool outputs consume 70-80% of context in a typical session, making context utilization the single most important metric for agent longevity. Their **Adaptive Context Compaction** transitions observations through active → faded → archived states, reducing peak context by ~54% and often eliminating emergency summarization. Key tactics: (1) treat context as a budget not a buffer with graduated reduction stages, (2) offload large outputs to filesystem and return only previews, (3) calibrate from API-reported token counts not local estimates (providers inject invisible content that makes local counting systematically wrong), (4) split system prompts into cacheable prefix and dynamic suffix for API caching. This aligns with [[context-engineering-strategies|broader context engineering patterns]] emerging across the field.

The **three-tier behavioral steering** architecture addresses instruction fade-out (agents reliably violate system prompt instructions after 30+ tool calls): (1) static system prompt, (2) dynamic just-in-time reminders injected as `role: user` messages at the point of decision (stronger compliance than `role: system`), (3) long-horizon memory persistence. Critically, separating thinking from action by removing tool schemas from the API call during deliberation phases is more effective than asking the model to "think carefully" with tools available — it's the absence of tool schemas, not an instruction to refrain, that changes behavior.

**Defense-in-depth safety** uses five independent layers: prompt-level guardrails, schema-level tool gating (making unsafe tools invisible rather than blocked), runtime approval with persistent permissions, tool-level validation, and user-defined lifecycle hooks. The key insight: [[putting yourself in the agents shoes is the unifying framework for agentic system design|schema gating]] is fundamentally more robust than runtime permission checks because a model that never sees a dangerous tool in its schema cannot reason about invoking it, argue for exceptions, or probe for bypass conditions. This is "a missing road vs a guard rail."

**Tool design for approximate outputs**: LLMs reliably produce approximately-correct outputs, so tools should absorb imprecision rather than reject it. The edit tool uses a chain of progressively relaxed matchers (exact → whitespace-normalized → fuzzy), short-circuiting on first match. Recovery hints must reference only tools the agent actually has — suggesting unavailable tools causes error loops. Server-like commands are auto-detected via regex and promoted to background execution.

Five transferable lessons from Section 3: (1) Context is a budget, not a buffer — design graduated reduction stages. (2) Inject reminders at the point of decision, not upfront — but cap frequency or they become noise. (3) Make unsafe tools invisible, not blocked. (4) Design tools to absorb LLM imprecision. (5) Bound every resource that grows with session length.

## External Resources

- [Paper (arXiv)](https://arxiv.org/abs/2603.05344) — full 81-page technical report
- [OpenDev GitHub](https://github.com/opendev-to/opendev) — open-source implementation
- Author: Nghi D. Q. Bui (bdqnghi@gmail.com)

## Original Content

> [!quote]- Full Paper: Building AI Coding Agents for the Terminal (Bui, 2026) — 81 pages
>
> ### Abstract
>
> The landscape of AI coding assistance is undergoing a fundamental shift from complex IDE plugins to versatile, terminal-native agents. Operating directly where developers manage source control, execute builds, and deploy environments, CLI-based agents offer unprecedented autonomy for long-horizon development tasks. In this paper, we present OPENDEV, an open-source, command-line coding agent engineered specifically for this new paradigm. Effective autonomous assistance requires strict safety controls and highly efficient context management to prevent context bloat and reasoning degradation. OPENDEV overcomes these challenges through a compound AI system architecture with workload-specialized model routing, a dual-agent architecture separating planning from execution, lazy tool discovery, and adaptive context compaction that progressively reduces older observations. Furthermore, it employs an automated memory system to accumulate project-specific knowledge across sessions and counteracts instruction fade-out through event-driven system reminders. By enforcing explicit reasoning phases and prioritizing context efficiency, OPENDEV provides a secure, extensible foundation for terminal-first AI assistance, offering a blueprint for robust autonomous software engineering.
>
> *Figure 1: Overview of OpenDev — four-level hierarchy: session → agent → workflow → LLM*
> ![[opendev-2603-_page_0_Figure_9.jpeg]]
>
> ### 1 Introduction
>
> Three fundamental engineering challenges any long-running terminal agent must solve: managing finite context windows over sessions that routinely exceed the model's token budget, preventing destructive operations when the agent can execute arbitrary shell commands, and extending capabilities without overwhelming the agent's prompt budget. The paper organizes the architectural response around two phases: scaffolding (assembles the agent before the first prompt) and the harness (orchestrates tool dispatch, context management, and safety enforcement at runtime).
>
> Five contributions: (1) Per-workflow LLM configurability via compound architecture, (2) Extended ReAct execution pipeline with thinking/critique phases, (3) Behavioral steering over long horizons via event-driven reminders, (4) Token-efficient extensibility and defense-in-depth safety, (5) Context engineering as first-class concern.
>
> *Figure 2: System architecture — four layers: Entry & UI, Agent, Tool & Context, Persistence*
> ![[opendev-2603-_page_3_Figure_0.jpeg]]
>
> ### 2 System Architecture
>
> #### 2.1 Overview
>
> Entry & UI Layer: CLI entry point parses arguments, bootstraps four shared managers. Two frontends: TUI (Textual) and Web UI (FastAPI/WebSockets), both implementing shared UICallback contract.
>
> Agent Layer: Five specialized model roles to distinct LLMs, lazily initialized. Two modes: Normal Mode (full read-write) and Plan Mode (read-only). Extended ReAct Loop runs four phases per turn: compaction, thinking, self-critique, action.
>
> Tool & Context Layers: ToolRegistry dispatches to typed handlers, with MCP tools discovered lazily. Skills system lazily injects domain-specific prompt templates from three-tier hierarchy. Context Engineering Layer manages through four subsystems: System Reminders, Prompt Composer, Memory, Compaction.
>
> Persistence Layer: Config Manager, Session Manager, Provider Cache, operation log for rollback.
>
> **Safety Architecture — Five Independent Layers:**
> - Layer 1: Prompt-Level Guardrails (security policy, action safety, read-before-edit, git workflow, error recovery)
> - Layer 2: Schema-Level Tool Restrictions (plan-mode whitelist, per-subagent allowed_tools, MCP discovery gating)
> - Layer 3: Runtime Approval System (Manual / Semi-Auto / Auto levels, pattern/command/prefix/danger rules, persistent permissions)
> - Layer 4: Tool-Level Validation (DANGEROUS_PATTERNS blocklist, stale-read detection, output truncation, timeouts)
> - Layer 5: Lifecycle Hooks (pre-tool blocking, argument mutation, JSON stdin protocol)
>
> #### 2.2 Agent Core Layer
>
> **Scaffolding**: All agents inherit from BaseAgent. Eager construction — build_system_prompt() and build_tool_schemas() called before constructor returns. Single concrete class MainAgent — behavioral variation from construction parameters only. Factory assembly in three phases: Skills → Subagents → Main agent.
>
> **Runtime Architecture**: ReAct loop executes six phases per iteration: pre-check/compaction, thinking, self-critique, action, tool execution, post-processing.
>
> *Figure 4: Agent harness architecture — ReAct loop surrounded by seven supporting subsystems*
> ![[opendev-2603-_page_7_Figure_0.jpeg]]
>
> *Figure 5: Conversation lifecycle — session initialization through message processing*
> ![[opendev-2603-_page_8_Figure_0.jpeg]]
>
> *Figure 6: REPL command dispatch — deterministic vs agent-routed commands*
> ![[opendev-2603-_page_9_Picture_4.jpeg]]
>
> **Workload-Optimized Multi-Model Architecture**: Five model roles — main (execution), thinking (deliberation), critique (self-review), compaction (summarization), VLM (vision). Each independently configurable. Thinking phase removes tool schemas from the API call entirely — the absence of tools, not an instruction to avoid them, changes model behavior.
>
> *Figure 7: Multi-model architecture — five specialized workflows bound to independent LLMs*
> ![[opendev-2603-_page_11_Figure_0.jpeg]]
>
> **Extended ReAct Execution Loop**: Pre-check drains injected messages and compacts under memory pressure. Optional thinking phase (6 depth levels from brief to exhaustive). Optional self-critique phase. Standard Reason-Act-Execute-Observe phase. Post-processing decides iterate or return.
>
> *Figure 8: Extended ReAct loop — six phases per iteration*
> ![[opendev-2603-_page_13_Figure_0.jpeg]]
>
> **Subagent Orchestration**: Each subagent is an instance of MainAgent with filtered tool schemas. Runtime isolation from schema filtering at build time + fresh context at execution time.
>
> #### 2.3 Context Engineering Layer
>
> **Dynamic System Prompt Construction**: Conditional prompt composition — 9 sections assembled by priority, each loading only when contextually relevant. Split into cacheable (identity, safety, tools, workflow) and non-cacheable (dynamic context, git status, file lists) segments.
>
> *Figure 10: Modular prompt composition pipeline*
> ![[opendev-2603-_page_17_Figure_0.jpeg]]
>
> *Figure 11: Token budget allocation across prompt sections*
> ![[opendev-2603-_page_18_Picture_0.jpeg]]
>
> **Tool Result Optimization**: Large outputs written to scratch files, only short preview + file reference returned to context. Transforms context-consumption problem into retrieval problem (one tool call vs paid on every subsequent LLM invocation).
>
> **Dual-Memory Architecture for Bounded Thinking**: Compressed long-range context (LLM summary) + detailed short-range context (last several exchanges verbatim). Periodically regenerate summary from full history to correct iterative-summarization distortion.
>
> **Context-Aware System Reminders**: 24-template reminder catalog. Injected as role: user messages (stronger compliance than role: system). Capped at 3 nudge attempts per type to prevent background noise.
>
> *Figure 13: System reminder injection — event-driven at attention-critical positions*
> ![[opendev-2603-_page_21_Figure_3.jpeg]]
>
> *Figure 14: System reminder catalog and injection timing*
> ![[opendev-2603-_page_22_Figure_3.jpeg]]
>
> **Adaptive Context Compaction**: Five-stage progressive pipeline: (1) fast tool-output pruning, (2) message masking, (3) LLM summarization, (4) aggressive pruning, (5) emergency truncation. 70% utilization threshold triggers compaction. Observations transition through active → faded → archived states. Reduced peak context by ~54%.
>
> *Figure 15: Adaptive context compaction — five-stage progressive pipeline*
> ![[opendev-2603-_page_24_Figure_5.jpeg]]
>
> *Figure 16: Context retrieval and assembly pipeline*
> ![[opendev-2603-_page_25_Figure_4.jpeg]]
>
> #### 2.4 Tool System
>
> **Registry Architecture**: Dispatches to typed handlers — file operations, shell execution, web access, LSP semantic analysis, user interaction, MCP discovery. Batch parallel execution supported.
>
> *Figure 17: Tool registry architecture*
> ![[opendev-2603-_page_26_Figure_2.jpeg]]
>
> **File Operations — Edit Tool Fuzzy Matching**: Chain of progressively relaxed matchers: exact → whitespace-normalized → indent-tolerant → line-prefix → fuzzy. Short-circuits on first match, preserving original formatting.
>
> **Shell Execution**: Six-stage pipeline — parse, classify, validate, execute, capture, post-process. Server-like commands auto-detected via regex and promoted to background execution.
>
> **Multi-Language Semantic Code Analysis via LSP**: Language Server Protocol integration for go-to-definition, find-references, hover info, symbol search. Supports 16 languages via auto-detected servers.
>
> **Token-Efficient External Tool Discovery via MCP**: Lazy discovery reduces startup context cost from 40% to under 5%. Agent receives compact server summary; full schemas loaded only when selected.
>
> *Figure 20: MCP lazy discovery architecture*
> ![[opendev-2603-_page_29_Figure_0.jpeg]]
>
> #### 2.5 Persistence Layer
>
> Session storage with self-healing indexes. Per-step undo via shadow git snapshots. Four-tier configuration hierarchy. Provider capability caching with stale-while-revalidate strategy.
>
> *Figure 22: Session storage and undo architecture*
> ![[opendev-2603-_page_32_Figure_0.jpeg]]
>
> ### 3 Discussion — Five Cross-Cutting Design Tensions
>
> **3.1 Context Pressure as the Central Design Constraint**: Tool outputs consume 70-80% of context. Lesson: Treat context as a budget, not a buffer — design graduated reduction stages. Lesson: Offload large outputs to filesystem. Lesson: Calibrate from API-reported token counts, not local estimates.
>
> **3.2 Steering Behavior Over Long Horizons**: System prompt influence decays after 30+ tool calls. Lesson: Inject reminders at the point of decision as role: user messages. Lesson: Separate thinking from action by removing tool schemas. Lesson: Separate agent construction from execution.
>
> **3.3 Safety Through Architectural Constraints**: Schema gating > runtime permission checks. Make unsafe tools invisible, not blocked. Approval persistence prevents fatigue.
>
> **3.4 Designing for Approximate Outputs**: Tools should absorb LLM imprecision. Edit tool fuzzy matching chain. Recovery hints must reference only available tools. Auto-promote server-like commands. Auto-install missing dependencies.
>
> **3.5 Lazy Loading and Bounded Growth**: Eager loading failed — MCP schemas consumed 40% of context at startup. Lazy discovery reduced to under 5%. Lesson: Bound every resource that grows with session length. Lesson: Prefer empirical threshold tuning over first-principles calculation.
>
> *Figure 23: Design tension summary*
> ![[opendev-2603-_page_34_Figure_0.jpeg]]
>
> ### 4 Related Work
>
> Surveys code generation and code LLMs, autonomous issue resolution (SWE-bench ecosystem), code as core medium for generalist agents, agentic software engineering workflows, agent tool systems, context engineering for long-horizon agents (citing Mei et al.'s CE taxonomy and Hua et al.'s four eras), benchmarks, evaluation methodology, and human-agent collaboration.
>
> *Figure 24: Related work landscape*
> ![[opendev-2603-_page_37_Figure_0.jpeg]]
>
> ### 5 Conclusion and Future Directions
>
> Central architectural insight: per-workflow LLM binding yields model-agnosticity. Schema-level safety enforcement proved more robust than runtime checks. Adaptive Context Compaction reduced peak context by ~54%. Three-tier behavioral steering addressed attention decay.
>
> Future directions: quantitative evaluation on SWE-bench/Terminal-Bench, adaptive resource allocation (dynamic thresholds vs fixed), scaling the memory pipeline across projects, structured code representations for memory, multi-agent coordination beyond hierarchical delegation, learned system reminder optimization, hybrid CLI-IDE integration.
>
> ### Appendices
>
> The paper includes extensive appendices (A through J) covering: complete tool catalog, LSP language server matrix, modular system prompt composition mechanics, edit tool fuzzy matching chain, shell execution pipeline details, full system reminder catalog (24 templates with injection timing), subagent capability matrix, configuration schema, implementation constants, and CLI command reference.
>
> *Figure A1: Appendix figures — implementation details*
> ![[opendev-2603-_page_63_Figure_10.jpeg]]
