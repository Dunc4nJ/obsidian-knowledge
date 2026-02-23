---
created: 2025-07-27
description: Thirteen concrete techniques for reducing LLM token costs and latency in production agents, from KV cache stability and append-only context to subagent delegation and output budgeting.
source: https://x.com/nicbstme/status/2021656728094617652
type: framework
---

# Context tax compounds through cache misses bloated tools and unbudgeted output tokens

## Key Takeaways

The "context tax" is the triple penalty of filling your context window with useless tokens: higher costs, slower responses, and degraded performance through context rot. The difference between a $0.50 query and a $5.00 query is often just context management. With Claude Opus 4.6, cached inputs cost 10x less than uncached, and output tokens cost 5x more than uncached inputs — making input optimization critical across typical 50-tool-call agent workflows.

The single most important optimization is **stable prefixes for KV cache hits**. If your prompt starts identically to a previous request, the model reuses cached key-value computations. The killer of cache hit rates is timestamps — including seconds or milliseconds guarantees zero cache hits. Move all dynamic content to the END of prompts; keep system instructions, tool definitions, and few-shot examples first and identical across requests. The Manus team considers this their most important production optimization, which connects to the [[progressive disclosure filters force agent selectivity over what enters context]] principle of being deliberate about what enters context and when.

**Append-only context** preserves cache validity — any mutation to earlier content invalidates the KV cache from that point forward. Tool definitions are especially insidious: dynamically adding or removing tools invalidates everything after them. Manus solved this by masking token logits during decoding to constrain actions rather than removing tool definitions. Even Python dict serialization order matters — use `sort_keys=True` or deterministic output, because different key order means different tokens means cache miss.

**Store tool outputs in the filesystem** instead of stuffing them into conversation context. Cursor's A/B testing showed this reduced total agent tokens by 46.9% for MCP tool runs. Agents don't need complete information upfront — they need the ability to access information on demand. Shell outputs, search results, API responses, and intermediate computations all belong on disk, referenced by path. This is the same insight behind [[skill graphs outperform single skill files by letting agents traverse linked domain knowledge on demand]] — lazy loading beats eager loading.

**Design precise tools** using a two-phase pattern: search returns metadata, a separate tool returns full content. The agent decides which items deserve full retrieval. Each filter parameter added to a tool can reduce returned tokens by an order of magnitude. This applies everywhere: document search (titles and snippets, not full docs), database queries (row counts and samples, not full result sets), file listings (paths and metadata, not contents).

**Delegate to cheaper subagents** for data extraction, classification, summarization, validation, and formatting. The Claude Code subagent pattern processes 67% fewer tokens overall due to context isolation — workers keep only what's relevant and return distilled outputs. Scope subagent tasks tightly and design for single-turn completion when possible.

**Reusable templates over regeneration** saves massively on output tokens (the most expensive tokens). The example: generating a DCF model from scratch costs ~$0.50 in output tokens; filling a template costs ~$0.05. Import and call rather than regenerate.

**The lost-in-the-middle problem** means LLMs attend strongly to the beginning and end of prompts while losing information in the middle (U-shaped attention). Place system instructions at the beginning, current requests at the end, and lower-priority background in the middle. Manus maintains a todo.md file updated throughout execution that "recites" current objectives at the end of context, combating this across 50-tool-call trajectories.

**Server-side compaction** (Anthropic's API feature) automatically summarizes conversations approaching a configurable token threshold. Custom summarization prompts like "Preserve all numerical data, company names, and analytical conclusions" prevent losing critical details. Compaction stacks with prompt caching — add a cache breakpoint on your system prompt so it stays warm independently.

**The 200K pricing cliff**: crossing 200K input tokens with Claude Opus/Sonnet doubles per-token cost overnight. Implement a context budget that triggers aggressive compression (observation masking, summarization, pruning) before crossing the threshold.

**Parallel tool calls** reduce round trips, and fewer round trips means less accumulated intermediate context — the savings compound. **Application-level response caching** short-circuits the API call entirely for repeated queries. **Output token budgeting** with task-appropriate limits and structured JSON outputs (versus natural language) can dramatically cut the most expensive token category.

## External Resources

- [Manus Context Engineering Blog Post](https://manus.im/blog/Context-Engineering-for-AI-Agents-Lessons-from-Building-Manus) — lessons from building Manus agent infrastructure, including KV cache and tool masking strategies
- [Cursor Dynamic Context Discovery](https://cursor.com/blog/dynamic-context-discovery) — filesystem-based context management that reduced agent tokens by 46.9%
- [Anthropic Server-Side Compaction](https://platform.claude.com/docs/en/build-with-claude/compaction) — automatic conversation summarization at configurable thresholds
- [Lost-in-the-Middle Research (Liu et al.)](https://arxiv.org/abs/2307.03172) — U-shaped attention pattern in LLM context processing
- [Claude Code Subagent Pattern](https://code.claude.com/docs/en/sub-agents) — 67% token reduction through context isolation
- [HTML Preprocessing for LLMs](https://dev.to/rosgluk/html-preprocessing-for-llms-3mk8) — markdown uses significantly fewer tokens than HTML

## Original Content

> [!quote]- Full Article by @nicbstme (Nicolas Bustamante) — Feb 11, 2026
>
> **The LLM Context Tax: Best Tips for Tax Avoidance**
>
> The Context Tax is what you pay when you fill your context window with useless tokens.
>
> Every token you send to an LLM costs money. Every token increases latency. And past a certain point, every additional token makes your agent dumber. This is the triple penalty of context bloat: higher costs, slower responses, and degraded performance through context rot, where the agent gets lost in its own accumulated noise.
>
> Context engineering is very important. The difference between a $0.50 query and a $5.00 query is often just how thoughtfully you manage context. Here's what I'll cover:
>
> 1. Stable Prefixes for KV Cache Hits
> 2. Append-Only Context
> 3. Store Tool Outputs in the Filesystem
> 4. Design Precise Tools
> 5. Clean Your Data First (Maximize Your Deductions)
> 6. Delegate to Cheaper Subagents (Offshore to Tax Havens)
> 7. Reusable Templates Over Regeneration (Standard Deductions)
> 8. The Lost-in-the-Middle Problem
> 9. Server-Side Compaction (Depreciation)
> 10. Output Token Budgeting (Withholding Tax)
> 11. The 200K Pricing Cliff (The Tax Bracket)
> 12. Parallel Tool Calls (Filing Jointly)
> 13. Application-Level Response Caching (Tax-Exempt Status)
>
> ---
>
> **Why Context Tax Matters**
>
> With Claude Opus 4.6, the math is brutal: that's a 10x difference between cached and uncached inputs. Output tokens cost 5x more than uncached inputs. Most agent builders focus on prompt engineering while hemorrhaging money on context inefficiency.
>
> In most agent workflows, context grows substantially with each step while outputs remain compact. This makes input token optimization critical: a typical agent task might involve 50 tool calls, each accumulating context.
>
> The performance penalty is equally severe. Research shows that past 32K tokens, most models show sharp performance degradation. Your agent isn't just getting expensive. It's getting confused.
>
> ---
>
> **Stable Prefixes for KV Cache Hits**
>
> This is the single most important metric for production agents: KV cache hit rate.
>
> The Manus team considers this the most important optimization for their agent infrastructure. The principle is simple: LLMs process prompts autoregressively, token by token. If your prompt starts identically to a previous request, the model can reuse cached key-value computations for that prefix.
>
> The killer of cache hit rates? Timestamps.
>
> A common mistake is including a timestamp at the beginning of the system prompt. The key is granularity: including the date is fine. Including the hour is acceptable since cache durations are typically 5 minutes (Anthropic default) to 10 minutes (OpenAI default). But never include seconds or milliseconds. A timestamp precise to the second guarantees every single request has a unique prefix. Zero cache hits. Maximum cost.
>
> Move all dynamic content (including timestamps) to the END of your prompt. System instructions, tool definitions, few-shot examples — all of these should come first and remain identical across requests.
>
> ---
>
> **Append-Only Context**
>
> Context should be append-only. Any modification to earlier content invalidates the KV cache from that point forward.
>
> The tool definition problem is particularly insidious. If you dynamically add or remove tools based on context, you invalidate the cache for everything after the tool definitions.
>
> Manus solved this elegantly: instead of removing tools, they mask token logits during decoding to constrain which actions the model can select. The tool definitions stay constant (cache preserved), but the model is guided toward valid choices through output constraints.
>
> Deterministic serialization matters too. Python dicts don't guarantee order. If you're serializing tool definitions or context as JSON, use sort_keys=True. A different key order = different tokens = cache miss.
>
> ---
>
> **Store Tool Outputs in the Filesystem**
>
> Cursor's approach to context management: instead of stuffing tool outputs into the conversation, write them to files.
>
> In their A/B testing, this reduced total agent tokens by 46.9% for runs using MCP tools.
>
> The insight: agents don't need complete information upfront. They need the ability to access information on demand. Files are the perfect abstraction.
>
> - Shell command outputs: Write to files, let agent tail or grep as needed
> - Search results: Return file paths, not full document contents
> - API responses: Store raw responses, let agent extract what matters
> - Intermediate computations: Persist to disk, reference by path
>
> ---
>
> **Design Precise Tools**
>
> A vague tool returns everything. A precise tool returns exactly what the agent needs.
>
> The two-phase pattern: search returns metadata, separate tool returns full content. The agent decides which items deserve full retrieval.
>
> Each parameter you add to a tool is a chance to reduce returned tokens by an order of magnitude.
>
> ---
>
> **Clean Your Data First (Maximize Your Deductions)**
>
> A typical webpage might be 100KB of HTML but only 5KB of actual content. CSS selectors that extract semantic regions and discard navigation, ads, and tracking can reduce token counts by 90%+. Markdown uses significantly fewer tokens than HTML.
>
> The principle: remove noise at the earliest possible stage, not after tokenization.
>
> ---
>
> **Delegate to Cheaper Subagents (Offshore to Tax Havens)**
>
> The Claude Code subagent pattern processes 67% fewer tokens overall due to context isolation. Instead of stuffing every intermediate search result into a single global context, workers keep only what's relevant and return distilled outputs.
>
> Scope subagent tasks tightly. Design for single-turn completion when possible.
>
> ---
>
> **Reusable Templates Over Regeneration (Standard Deductions)**
>
> Output tokens cost 5x input tokens with Claude. Stop regenerating the same patterns.
>
> OLD: "Create a DCF model for Apple" → generates 2,000 lines from scratch → ~$0.50
> NEW: loads DCF template, fills Apple-specific values → ~$0.05
>
> The agent imports and calls rather than regenerates. Fewer output tokens, faster responses, more consistent results.
>
> ---
>
> **The Lost-in-the-Middle Problem**
>
> LLMs show a consistent U-shaped attention pattern: strong attention to beginning and end, "losing" information in the middle. Place system instructions at beginning, current request at end, critical context at beginning or end (never middle), lower-priority background in middle.
>
> Manus maintains a todo.md file updated throughout execution that "recites" current objectives at the end of context, combating this across 50-tool-call trajectories.
>
> ---
>
> **Server-Side Compaction (Depreciation)**
>
> Anthropic's server-side compaction automatically summarizes conversation approaching configurable token threshold. Custom instructions like "Preserve all numerical data, company names, and analytical conclusions" prevent losing critical details. Compaction stacks with prompt caching — system prompt cache stays warm independently.
>
> ---
>
> **Output Token Budgeting (Withholding Tax)**
>
> Task-appropriate limits: classification (50 tokens), extraction (200), short answer (500), analysis (2000), code generation (4000). Structured JSON uses fewer tokens than natural language for the same information.
>
> ---
>
> **The 200K Pricing Cliff (The Tax Bracket)**
>
> Crossing 200K input tokens with Claude Opus/Sonnet doubles per-token cost. Opus goes from $5 to $10 per million input tokens, output jumps from $25 to $37.50. Implement a context budget that triggers aggressive compression before crossing.
>
> ---
>
> **Parallel Tool Calls (Filing Jointly)**
>
> Fewer round trips, less context accumulation. The savings compound.
>
> ---
>
> **Application-Level Response Caching (Tax-Exempt Status)**
>
> The cheapest token is the one you never send to the API. Check if you've already answered this question before any LLM call. Match cache TTL to the volatility of underlying data.
>
> ---
>
> **The Meta Lesson**
>
> Context engineering isn't glamorous. But it's the difference between a demo that impresses and a product that scales with decent gross margin. The best teams building sustainable agent products are obsessing over token efficiency the same way database engineers obsess over query optimization.
>
> *92 likes · 4 retweets · 6 replies*

[Original thread](https://x.com/nicbstme/status/2021656728094617652)
