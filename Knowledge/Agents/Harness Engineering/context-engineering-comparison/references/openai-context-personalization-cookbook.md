---
created: 2026-03-02
description: OpenAI's cookbook demonstrates state-based long-term memory for agent personalization — using structured profile objects with precedence rules rather than retrieval-based memory search — implemented through the Agents SDK RunContextWrapper.
source: https://cookbook.openai.com/examples/agents_sdk/context_personalization
type: framework
---

## Key Takeaways

The core architectural decision is choosing state-based memory over retrieval-based memory. Retrieval-based systems treat past interactions as documents to search, which is brittle to phrasing and prone to missing overrides. State-based memory encodes user knowledge as structured fields with clear precedence (global vs session), supports belief updates instead of fact accumulation, and enables deterministic decision-making. This is the same distinction [[manus-context-engineering|Manus]] draws between filesystem-as-memory (structured) and vector search (retrieval-based).

The memory lifecycle follows a five-stage pattern: inject state at session start → distill memories during the session via tool calls → preserve memories across context trimming → consolidate session notes into global state post-session → repeat. The precedence order is explicit: latest user input overrides session overrides, which override global defaults. This structured approach to conflict resolution is more principled than the ad-hoc memory systems in most agent frameworks.

OpenAI contrasts this with retrieval-based memory's failure modes — ChatGPT once injected a user's location from memories into an unrelated image request, making users feel the context window "no longer belongs to them." State-based memory with explicit injection avoids this by only surfacing structured fields when the agent needs them, not based on semantic similarity.

## External Resources

- [Agents SDK - RunContextWrapper](https://github.com/openai/openai-agents-python) — State management primitive for cross-session persistence
- [OpenAI Cookbook - Session Memory](https://cookbook.openai.com/examples/agents_sdk/session_memory) — Companion cookbook on short-term memory

## Original Content

> [!quote]- Source Material
> **Context Engineering for Personalization - State Management with Long-Term Memory Notes using OpenAI Agents SDK**
> By Emre Okcular
>
> Modern AI agents are no longer just reactive assistants — they're becoming adaptive collaborators. The leap from "responding" to "remembering" defines the new frontier of context engineering. At its core, context engineering is about shaping what the model knows at any given moment.
>
> The RunContextWrapper in the OpenAI Agents SDK provides the foundation for this. It allows developers to define structured state objects that persist across runs, enabling memory, notes, or even preferences to evolve over time.
>
> This cookbook shows a state-based long-term memory pattern:
> - State object = your local-first memory store (structured profile + notes)
> - Distill memories during a run (tool call → session notes)
> - Consolidate session notes into global notes at the end (dedupe + conflict resolution)
> - Inject a well-crafted state at the start of each run (with precedence rules)
>
> **1. Retrieval-Based vs State-Based Memory**
>
> State-based memory is better suited than retrieval-based memory for agents because decisions depend on continuity, priorities, and evolving preferences — not ad-hoc search. Retrieval-based memory treats past interactions as loosely related documents, making it brittle to phrasing, prone to missing overrides, and unable to reconcile conflicts. State-based memory encodes user knowledge as structured, authoritative fields with clear precedence (global vs session), supports belief updates instead of fact accumulation, and enables deterministic decision-making.
>
> **Memory Lifecycle:**
> 1. Before Session: State object (profile + global notes) stored locally
> 2. Session Start: State injected into system prompt (YAML frontmatter + markdown memory list)
> 3. During Session: Agent captures candidate memories via save_memory_note(...)
> 4. Context Trimming: Session-scoped notes reinjected into system prompt
> 5. Session End: Consolidation job merges session notes into global memory
> 6. Next Run: Updated state object reused
>
> **Precedence Rules:** latest user input → session overrides → global defaults
>
> [Original cookbook](https://cookbook.openai.com/examples/agents_sdk/context_personalization)
