---
created: 2026-03-02
description: LangChain's taxonomy organizes agent context engineering into four strategies — write, select, compress, and isolate — with examples from Claude Code, Manus, Cursor, and Anthropic's multi-agent researcher.
source: https://blog.langchain.com/context-engineering-for-agents/
type: framework
---

## Key Takeaways

LangChain's main contribution is taxonomic rather than technical — they organize the scattered approaches from [[manus-context-engineering|Manus]], [[anthropic-effective-context-engineering|Anthropic]], [[cursor-dynamic-context-discovery|Cursor]], and others into four clean categories. Write (save context outside the window via scratchpads and memories), Select (pull relevant context in via RAG, tools, and filesystem), Compress (retain only essential tokens via summarization and trimming), and Isolate (split context across agents). This framework makes it easier to compare what different companies are actually doing.

The "no-op tools as context engineering" insight from their Deep Agents analysis is particularly sharp: Claude Code's todo list tool does nothing functionally — it's purely a context strategy that forces the agent to articulate its plan. This reframes tool design from "what does the tool do?" to "what does calling the tool put into context?" This connects to [[manus-context-engineering|Manus's attention manipulation]] via recitation — both use self-generated text to keep the model on track.

The Karpathy analogy (LLM as CPU, context window as RAM) provides the conceptual foundation that multiple companies reference. Context engineering is the operating system that manages what fits in RAM at each step. The challenge cited by Drew Breunig — context poisoning, distraction, confusion, and clash — names the specific failure modes that all [[anthropic-effective-harnesses|context management strategies]] aim to prevent.

## External Resources

- [Context Engineering video](https://youtu.be/4GiqzUHD5AA) — LangChain's video walkthrough of the taxonomy
- [LangGraph](https://github.com/langchain-ai/langgraph) — Framework designed around context engineering control
- [Deep Agents](https://blog.langchain.com/deep-agents/) — Analysis of Claude Code-style long-running agent patterns
- [Drew Breunig - How Contexts Fail](https://www.dbreunig.com/2025/06/22/how-contexts-fail-and-how-to-fix-them.html) — Taxonomy of context failure modes

## Original Content

> [!quote]- Source Material
> **Context Engineering for Agents**
> LangChain Blog — July 2025
>
> Agents need context to perform tasks. Context engineering is the art and science of filling the context window with just the right information at each step of an agent's trajectory. In this post, we break down some common strategies — write, select, compress, and isolate — for context engineering by reviewing various popular agents and papers.
>
> **Context Engineering**
>
> As Andrej Karpathy puts it, LLMs are like a new kind of operating system. The LLM is like the CPU and its context window is like the RAM, serving as the model's working memory.
>
> Karpathy summarizes: "[Context engineering is the] delicate art and science of filling the context window with just the right information for the next step."
>
> Context types: Instructions (prompts, memories, few-shot examples, tool descriptions), Knowledge (facts, memories), Tools (feedback from tool calls).
>
> **Write Context** — saving context outside the window. Scratchpads (note-taking tools, file writes), Memories (cross-session persistence via reflection and generative memories). Products like ChatGPT, Cursor, and Windsurf all auto-generate long-term memories.
>
> **Select Context** — pulling relevant context in. Scratchpads (read via tool calls or state exposure), Memories (semantic search, knowledge graphs — but selection is challenging; Simon Willison shared how ChatGPT unexpectedly injected his location), Tools (RAG on tool descriptions — 3x improvement in selection accuracy), Knowledge (code agent RAG with AST parsing, grep/file search, re-ranking).
>
> **Compress Context** — retaining only essential tokens. Context Summarization (Claude Code auto-compacts at 95% capacity; Cognition uses fine-tuned models for this). LangChain measured reduction from 115K to 60K tokens through end-to-end summarization. Context Trimming (removing older messages, heuristic pruning).
>
> **Isolate Context** — splitting across agents. Multi-agent (OpenAI Swarm for separation of concerns; Anthropic's multi-agent researcher — subagents with isolated contexts outperformed single-agent, but used up to 15x more tokens). Context Isolation with Environments (HuggingFace's CodeAgent runs in sandboxes, isolating tool execution from the LLM context).
>
> **No-op tools as context engineering:** Claude Code's todo list tool does nothing functionally — it is purely a context strategy that forces the agent to articulate its plan, keeping it on track over long trajectories.
>
> [Original post](https://blog.langchain.com/context-engineering-for-agents/)
