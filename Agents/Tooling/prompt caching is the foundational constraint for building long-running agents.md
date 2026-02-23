---
created: 2026-02-19
description: Claude Code's engineering team reveals that prompt caching via prefix matching is the single most important architectural constraint — every feature from plan mode to compaction to tool search is designed around preserving cache hits.
source: https://x.com/trq212/status/2024574133011673516
type: learning
---

## Key Takeaways

Prompt caching is prefix-based: the API caches computation from the start of the request up to cache breakpoints, so **ordering is everything**. Static system prompt and tools first, then project context (CLAUDE.md), then session context, then conversation messages. This mirrors the [[context tax compounds through cache misses bloated tools and unbudgeted output tokens|context tax]] principle — stable prefixes are the single most impactful optimization, and timestamps or tool shuffling silently destroy cache hit rates.

Claude Code treats cache hit rate like uptime — they **alert on drops and declare SEVs** when cache breaks occur. A few percentage points of cache miss dramatically affect both cost and latency. This operational rigor is what makes generous subscription rate limits feasible.

Key design patterns that preserve the cache:

- **Use messages, not prompt edits** for dynamic updates. When the time changes or a file updates, inject a `<system-reminder>` tag in the next user message rather than modifying the system prompt. This preserves the prefix.

- **Never add or remove tools mid-session.** Plan mode works by using `EnterPlanMode`/`ExitPlanMode` as *tools themselves* rather than swapping toolsets. The model can even autonomously enter plan mode when it detects a hard problem — a bonus from designing around the cache constraint.

- **Defer tool loading instead of removing.** Send lightweight stubs with `defer_loading: true` and let the model discover full schemas via a ToolSearch tool. The stub set stays stable in the prefix. This connects to the [[agentic search with grep and full-file loading replaces RAG when context windows are large enough|no-RAG philosophy]] — keep things simple and stable, let the agent pull what it needs.

- **Don't switch models mid-conversation.** Even switching from Opus to Haiku for a "simple" question costs more because it rebuilds the entire cache. Use subagents for model transitions — Opus prepares a handoff message to the cheaper model.

- **Cache-safe compaction.** When compacting, use the *exact same* system prompt, tools, and conversation prefix as the parent, then append the compaction prompt as a new user message. This reuses the parent's cached prefix instead of paying full price for all input tokens. They save a "compaction buffer" of context window space for this.

The meta-lesson: prompt caching isn't a feature you bolt on — it's an **architectural constraint you design every feature around from day one**. Plan mode, tool search, compaction, model switching — all of these were shaped by the prefix-matching constraint.

## External Resources

- [Prompt caching and auto-caching launch (Lance Martin)](https://x.com/RLanceMartin/status/2024573404888911886) — technical deep-dive on the caching API
- [Compaction API docs](https://platform.claude.com/docs/en/build-with-claude/compaction#prompt-caching) — built-in compaction based on Claude Code learnings
- [Tool Search API docs](https://platform.claude.com/docs/en/agents-and-tools/tool-use/tool-search-tool) — defer_loading and tool discovery

## Original Content

> [!quote]- Full tweet by @trq212 / Thariq (Feb 19, 2026) — 4,428 likes, 396 RTs
>
> **Lessons from Building Claude Code: Prompt Caching Is Everything**
>
> Long running agentic products like Claude Code are made feasible by prompt caching which allows us to reuse computation from previous roundtrips and significantly decrease latency and cost. Claude Code builds its entire harness around prompt caching — they alert on cache hit rate and declare SEVs when it drops.
>
> Key lessons: (1) Static content first, dynamic last — system prompt → tools → project context → session → messages. (2) Use messages for updates instead of editing prompts. (3) Never change tools or models mid-session — use tools to model state transitions. (4) Fork operations (compaction) must share the parent's prefix. (5) Monitor cache hit rate like uptime.
>
> Plan mode uses EnterPlanMode/ExitPlanMode as tools rather than swapping toolsets. Tool search uses defer_loading stubs. Compaction reuses the parent's exact prefix. All designed around the prefix-matching constraint.
>
> [Original tweet](https://x.com/trq212/status/2024574133011673516)
