---
created: 2026-03-01
description: Six concrete patterns extracted from Claude Code's architecture that maximize prompt cache hit rates — static-first ordering, message injection over system prompt mutation, model-isolated subagents, frozen tool sets, cache hit rate as a production metric, and cache-safe compaction.
source: https://x.com/koylanai/status/2027819266972782633
type: learning
---

## Key Takeaways

This thread distills the practical engineering patterns behind Claude Code's cache optimization into six actionable rules, building on the foundational insight that [[prompt caching is the foundational constraint for building long-running agents]]. Where that note covers the "why," this one covers the "how" — the specific architectural choices that keep cache prefixes stable across turns.

The ordering principle — static system prompt and tools first, then session context, then messages — is the same progressive disclosure pattern applied to inference cost. This directly mirrors several of the thirteen techniques in [[context tax compounds through cache misses bloated tools and unbudgeted output tokens]], particularly the append-only context and KV cache stability patterns. The key insight is that any dynamic content placed before static content forces a full-price cache miss.

The subagent pattern for model switching is especially valuable: if you're 100K tokens deep with a warm Opus cache, switching to Haiku for a simple question is actually more expensive because the cold cache on Haiku means full prefill on the entire new context. This validates the model-isolation approach where each agent maintains its own context and the orchestrator passes structured handoff messages between them rather than switching models within a single thread.

The tool stability pattern is clever — Claude Code's Plan Mode doesn't swap tool sets at all. Instead of removing tools, it uses `EnterPlanMode`/`ExitPlanMode` as tools themselves with instructions delivered via messages. Unused tools get lightweight stubs with `defer_loading` that the model discovers on demand. The tool definitions in the prefix never change.

Cache hit rate as a production metric (alongside latency and error rate) is the pattern most teams miss. One reply in the thread noted that tracking cache hits on their agent pipeline revealed they were invalidating on almost every turn due to a dynamic tool list — fixing that alone cut costs 40%.

## External Resources

- [Prompt auto-caching with Claude (Lance Martin)](https://x.com/RLanceMartin/status/2024573404888911886) — companion article covering auto-caching API mechanics, cache_control breakpoints, and the case for caching in agentic loops
- [Claude Code prompt caching deep dive (trq212)](https://x.com/trq212/status/2024574133011673516) — the original source thread detailing Claude Code's caching architecture
- [Manus context engineering blog post](https://manus.im/blog/Context-Engineering-for-AI-Agents-Lessons-from-Building-Manus) — Manus team calling cache hit rate the single most important metric for production agents

## Original Content

> @koylanai — 2026-02-28
>
> Finally had some time to read @trq212 and @RLanceMartin prompt-caching articles. They are dense and include important insights into context engineering.
>
> 1. Static-First Ordering
> Claude Code's entire prompt is ordered for cache hits:
> Static system prompt & tools -> CLAUDE.md -> Session context -> Messages
>
> This is the same principle behind progressive disclosure architectures, but applied to inference cost. Static, per-session instructions should come before dynamic data.
>
> Every time dynamic content appears before static content, you're paying full price on cache misses, which also increases latency.
>
> *Static-first ordering diagram*
> ![[koylanai-782633-001.jpg]]
>
> 2. Messages Over System Prompt Mutations
> Instead of updating the system prompt (which breaks cache), inject updates via tags in user messages.
>
> For multi-turn sessions, if context changes mid-conversation, appending that as a message preserves the cache prefix. Mutating the system prompt to include updated context would be expensive.
>
> *Message injection vs system prompt mutation*
> ![[koylanai-782633-002.jpg]]
>
> 3. Subagents for Model Switching
> Switching models mid-session destroys the cache because caches are model-specific. Claude Code uses subagents with handoff messages instead.
>
> If you're 100K tokens into a conversation with Opus, it's actually more expensive to switch to Haiku for a simple question than to just let Opus answer it. A warm cache on an expensive model beats a cold cache on a cheap model.
>
> If your multi-agent system uses different models for different tasks, isolate each agent's context. The orchestrator passes structured handoff messages between agents rather than switching models within a single conversation thread.
>
> *Subagent model isolation*
> ![[koylanai-782633-003.jpg]]
>
> 4. Never Change Tools Mid-Session
> Tools are part of the cached prefix. Adding or removing one invalidates the entire cache. Claude Code's Plan Mode doesn't swap tool sets, it uses EnterPlanMode / ExitPlanMode as tools themselves, with instructions delivered via messages. The tool definitions never change.
>
> Instead of removing tools, they send lightweight stubs with defer_loading that the model can discover on demand in tool search. Full schemas load only when selected. The prefix stays stable.
>
> *Tool stability pattern*
> ![[koylanai-782633-004.jpg]]
>
> 5. Cache Hit Rate Is a Production Metric
> Claude Code monitors prompt cache hit rate the same way most teams monitor uptime, they set alerts and treat drops as production incidents.
>
> If you're building agents and not tracking cache_creation_input_tokens vs cache_read_input_tokens from API responses, you're missing a major cost and latency lever. Put it on your dashboard next to latency and error rate.
>
> *Cache hit rate monitoring*
> ![[koylanai-782633-005.png]]
>
> 6. Cache-Safe Compaction
> When the context window fills up, Claude Code summarizes but uses the exact same system prompt, tools, and conversation prefix so the compaction request reuses the parent's cache.
>
> The right approach is to append the compaction instruction as a new user message.
>
> Same prefix = cache hit on the entire history.
>
> *Cache-safe compaction flow*
> ![[koylanai-782633-006.png]]
>
> QT @RLanceMartin: Article: Prompt auto-caching with Claude
>
> ![[koylanai-782633-007.jpg]]
>
> [Original post](https://x.com/koylanai/status/2027819266972782633)
