---
created: 2026-03-01
description: Claude's auto-caching API feature automatically moves the cache breakpoint to the last cacheable block in each request, eliminating the need to manually manage cache_control placement across conversation turns.
source: https://x.com/RLanceMartin/status/2024573404888911886
type: learning
---

## Key Takeaways

The core problem auto-caching solves is mechanical: in turn-based agents, the cache breakpoint must move to the latest block as the conversation grows. Previously this required explicit `cache_control` placement on specific blocks. Auto-caching moves the breakpoint automatically to the last cacheable block, which is exactly what [[prompt caching is the foundational constraint for building long-running agents]] describes as the ideal behavior for agentic loops.

The economic case is stark — cached input tokens cost 10% of non-cached tokens. For agents that [[context tax compounds through cache misses bloated tools and unbudgeted output tokens|accumulate context across many turns]], this means the difference between viable and prohibitively expensive. Manus's engineering team independently arrived at the same conclusion, calling cache hit rate the single most important metric for production agents.

The cache matching mechanism uses cryptographic hashing of content blocks — one character difference produces a different hash and a cache miss. This is why the [[six cache-friendly patterns from Claude Code make prompt caching practical for production agents|six patterns from Claude Code]] emphasize prefix stability so aggressively: any edit to history or tool definitions upstream of the current turn invalidates the entire cached prefix.

Auto-caching and block-level caching compose together — you can still set explicit breakpoints on system prompts or tool definitions while letting auto-caching handle the conversation tail. This layered approach gives you stable caching on the static prefix and automatic caching on the growing conversation.

## External Resources

- [Claude Prompt Caching docs](https://platform.claude.com/docs/en/build-with-claude/prompt-caching) — official API documentation for cache_control and auto-caching
- [Claude Pricing](https://platform.claude.com/docs/en/about-claude/pricing) — cached vs non-cached token pricing
- [trq212 deep dive on cache-friendly prompt design](https://x.com/trq212/status/2024574133011673516) — companion thread on Claude Code's caching architecture
- [How prompt caching works (dejavucoder)](https://sankalp.bearblog.dev/how-prompt-caching-works/) — technical explanation of KV cache mechanics
- [Transformer inference arithmetic (kipply)](https://kipp.ly/transformer-inference-arithmetic/) — foundational reference on prefill vs decode phases
- [Manus context engineering lessons](https://manus.im/blog/Context-Engineering-for-AI-Agents-Lessons-from-Building-Manus) — cache hit rate as the key production metric
- [vLLM paper](https://arxiv.org/pdf/2309.06180) — inference framework with caching optimizations
- [SGLang blog](https://lmsys.org/blog/2024-01-17-sglang/) — alternative inference framework approach

## Original Content

> [!quote]- Source Material
> **@RLanceMartin — 2026-02-19**
>
> Article: Prompt auto-caching with Claude
>
> TL;DR: Prompt caching is a great way to save cost + latency when using Claude. Input tokens that use the prompt cache are 10% the cost of non-cached tokens. Auto-caching was just added to the API, which makes it easier to cache your prompt with a single cache_control parameter in the API request. Also, check out @trq212's deep dive on Claude Code's use of prompt caching and useful tips for cache-friendly prompt design.
>
> ```json
> {
>   "cache_control": {"type": "ephemeral"},
>   "messages": [
>     { "role": "user", "content": "A" },
>     { "role": "assistant", "content": "B" },
>     { "role": "user", "content": "C" }
>   ]
> }
> ```
>
> ## The case for caching
>
> Many AI applications ingest the same context across turns. For example, agents perform actions in a loop. Each action produces new context. Claude's messages API is stateless, which means it doesn't remember past actions. The agent harness needs to package new context with past actions, tool descriptions, and general instructions at each turn.
>
> This means most of the context is the same across turns. But, without caching, you pay for the entire context window every turn. Why not just re-use the shared context? That's what prompt caching does. You can see on the pricing page that cached tokens are 10% the cost of base input tokens. With caching, you only pay in full for each new context block once.
>
> @peakji from Manus called out the cache hit rate as the single most important metric for a production AI agent. @trq212 has noted that prompt caching is critical for long running / token-heavy agents like Claude Code.
>
> ## How it works
>
> There are some great resources (e.g., from @dejavucoder or from @kipply) on the details of LLM inference and caching. In general, LLM inference pipelines typically use a prefill phase that processes the prompt and a decode phase that generates output tokens.
>
> The intuition behind caching is that the prefill computation can be performed once, saved (e.g., cached), and then re-used if (part of) a future prompt is identical. Inference libraries / frameworks like vLLM and SGLang use different approaches to achieve this central idea.
>
> ## Usage with Claude
>
> Caching with the Claude messages API uses a cache_control breakpoint, which can be placed at any block in your prompt. This tells Claude two things.
>
> First, it is a "write point" telling Claude to cache all blocks up to and including this one. This creates a cryptographic hash of all the content blocks up to that breakpoint. This is scoped to your workspace.
>
> ```json
> "messages": [
>   { "role": "user", "content": "A" },
>   { "role": "assistant", "content": "B" },
>   {
>     "role": "user",
>     "content": "C",
>     "cache_control": {"type": "ephemeral"}
>   }
> ]
> ```
>
> Second, it tells Claude to search backward at most 20 blocks from the breakpoint to find any prior cache write matches ("hits"). The hash requires identical content. One character difference will produce a different hash and a cache miss. If there's a match, the cache is used in prefill.
>
> Still, there are challenges with caching. For turn-based apps (e.g., agents), you have to move the breakpoint to the latest block as the conversation progresses. The API now addresses this with auto-caching. You can place a single cache_control parameter in your request to the Claude messages API.
>
> ```json
> {
>   "cache_control": {"type": "ephemeral"},
>   "messages": [
>     { "role": "user", "content": "A" },
>     { "role": "assistant", "content": "B" },
>     { "role": "user", "content": "C" }
>   ]
> }
> ```
>
> With auto-caching, the cache breakpoint moves to the last cacheable block in your request. As your conversation grows, the breakpoint moves with it automatically. This still works with block-level caching if you want to set breakpoints (e.g., on your system prompt or other context blocks).
>
> Another challenge is designing your prompt to maximize cache hits. For example, if you edit the history you risk breaking the cache.
>
> This is a problem that we've tackled with Claude Code! @trq212 just shared a number of useful insights on prompt design with caching in mind.
>
> Engagement: 1072 likes | 94 retweets | 25 replies
> [Original post](https://x.com/RLanceMartin/status/2024573404888911886)
