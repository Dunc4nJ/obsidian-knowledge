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

> [!quote]- Source
>
> @trq212 (Thariq):
> 📰 Lessons from Building Claude Code: Prompt Caching Is Everything
>
> It is often said in engineering that "Cache Rules Everything Around Me", and the same rule holds for agents.
>
> Long running agentic products like Claude Code are made feasible by prompt caching which allows us to reuse computation from previous roundtrips and significantly decrease latency and cost.
>
> What is prompt caching, how does it work and how do you implement it technically? [Read more in @RLanceMartin's piece on prompt caching and our new auto-caching launch.](https://x.com/RLanceMartin/status/2024573404888911886)
>
> At Claude Code, we build our entire harness around prompt caching. A high prompt cache hit rate decreases costs and helps us create more generous rate limits for our subscription plans, so we run alerts on our prompt cache hit rate and declare SEVs if they're too low.
>
> These are the (often unintuitive) lessons we've learned from optimizing prompt caching at scale.
>
> ## Lay Out Your Prompt for Caching
>
> Prompt caching works by prefix matching — the API caches everything from the start of the request up to each cache_control breakpoint. This means the order you put things in matters enormously, you want as many of your requests to share a prefix as possible.
>
> The best way to do this is static content first, dynamic content last. For Claude Code this looks like:
>
> 1. Static system prompt & Tools (globally cached)
>
> 2. Claude.MD (cached within a project)
>
> 3. Session context (cached within a session)
>
> 4. Conversation messages
>
> This way we maximize how many sessions share cache hits.
>
> But this can be surprisingly fragile! Examples of reasons we’ve broken this ordering before include: putting an in-depth timestamp in the static system prompt, shuffling tool order definitions non-deterministically, updating parameters of tools (e.g. what agents the AgentTool can call), etc.
>
> ## Use Messages for Updates
>
> There may be times when the information you put in your prompt becomes out of date, for example if you have the time or if the user changes a file. It may be tempting to update the prompt, but that would result in a cache miss and could end up being quite expensive for the user.
>
> Consider if you can pass in this information via messages in the next turn instead. In Claude Code, we add a <system-reminder> tag in the next user message or tool result with the updated information for the model (e.g. it is now Wednesday), which helps preserve the cache.
>
> ## Don't change Models Mid-Session
>
> Prompt caches are unique to models and this can make the math of prompt caching quite unintuitive.
>
> If you're 100k tokens into a conversation with Opus and want to ask a question that is fairly easy to answer, it would actually be more expensive to switch to Haiku than to have Opus answer, because we would need to rebuild the prompt cache for Haiku.
>
> If you need to switch models, the best way to do it is with subagents, where Opus would prepare a "handoff" message to another model on the task that it needs done. We do this often with the Explore agents in Claude Code which use Haiku.
>
> ## Never Add or Remove Tools Mid-Session
>
> Changing the tool set in the middle of a conversation is one of the most common ways people break prompt caching. It seems intuitive — you should only give the model tools you think it needs right now. But because tools are part of the cached prefix, adding or removing a tool invalidates the cache for the entire conversation.
>
> Plan Mode — Design Around the Cache
>
> Plan mode is a great example of designing features around caching constraints. The intuitive approach would be: when the user enters plan mode, swap out the tool set to only include read-only tools. But that would break the cache.
>
> Instead, we keep all tools in the request at all times and use EnterPlanMode and ExitPlanMode as tools themselves. When the user toggles plan mode on, the agent gets a system message explaining that it's in plan mode and what the instructions are — explore the codebase, don't edit files, call ExitPlanMode when the plan is complete. The tool definitions never change.
>
> This has a bonus benefit: because EnterPlanMode is a tool the model can call itself, it can autonomously enter plan mode when it detects a hard problem, without any cache break.
>
> Tool Search — Defer Instead of Remove
>
> The same principle applies to our tool search feature. Claude Code can have dozens of MCP tools loaded, and including all of them in every request would be expensive. But removing them mid-conversation would break the cache.
>
> Our solution: defer_loading. Instead of removing tools, we send lightweight stubs — just the tool name, with defer_loading: true — that the model can "discover" via a ToolSearch tool when needed. The full tool schemas are only loaded when the model selects them. This keeps the cached prefix stable: the same stubs are always present in the same order.
>
> Luckily you can use the [tool search](https://platform.claude.com/docs/en/agents-and-tools/tool-use/tool-search-tool) tool through our API to simplify this.
>
> ## Forking Context — Compaction
>
> Compaction is what happens when you run out of the context window. We summarize the conversation so far and continue a new session with that summary.
>
> Surprisingly, compaction has many edge cases with prompt caching that can be unintuitive.
>
> In particular, when we compact we need to send the entire conversation to the model to generate a summary. If this is a separate API call with a different system prompt and no tools (which is the simple implementation), the cached prefix from the main conversation doesn't match at all. You pay full price for all those input tokens, drastically increasing the cost for the user.
>
> The Solution — Cache-Safe Forking
>
> When we run compaction, we use the exact same system prompt, user context, system context, and tool definitions as the parent conversation. We prepend the parent's conversation messages, then append the compaction prompt as a new user message at the end.
>
> From the API's perspective, this request looks nearly identical to the parent's last request — same prefix, same tools, same history — so the cached prefix is reused. The only new tokens are the compaction prompt itself.
>
> This does mean however that we need to save a "compaction buffer" so that we have enough room in the context window to include the compact message and the summary output tokens.
>
> Compaction is tricky but luckily, you don't need to learn these lessons yourself — based on our learnings from Claude Code we built[ compaction](https://platform.claude.com/docs/en/build-with-claude/compaction#prompt-caching) directly into the API, so you can apply these patterns in your own applications.
>
> ## Lessons Learned
>
> 1. Prompt caching is a prefix match. Any change anywhere in the prefix invalidates everything after it. Design your entire system around this constraint. Get the ordering right and most of the caching works for free.
>
> 2. Use messages instead of system prompt changes. You may be tempted to edit the system prompt to do things like entering plan mode, changing the date, etc. but it would actually be better to insert these into messages during the conversation.
>
> 3. Don't change tools or models mid-conversation. Use tools to model state transitions (like plan mode) rather than changing the tool set. Defer tool loading instead of removing tools.
>
> 4. Monitor your cache hit rate like you monitor uptime. We alert on cache breaks and treat them as incidents. A few percentage points of cache miss rate can dramatically affect cost and latency.
>
> 5. Fork operations need to share the parent's prefix. If you need to run a side computation (compaction, summarization, skill execution), use identical cache-safe parameters so you get cache hits on the parent's prefix.
>
> Claude Code is built around prompt caching from day one, you should do the same if you’re building an agent.
> 📅 Thu Feb 19 19:57:42 +0000 2026
> 🔗 https://x.com/trq212/status/2024574133011673516
> ──────────────────────────────────────────────────
>
> @EricBuess (Eric Buess):
> @trq212 This is very helpful! I’m going to audit my system to make sure I’m maximizing for cache in these ways which were a bit unclear before. Thank you!
> 📅 Thu Feb 19 19:59:25 +0000 2026
> 🔗 https://x.com/EricBuess/status/2024574563510538438
> ──────────────────────────────────────────────────
>
> @trq212 (Thariq):
> @EricBuess yes definitely! you can probably just point Claude at this article :)
> 📅 Thu Feb 19 20:03:49 +0000 2026
> 🔗 https://x.com/trq212/status/2024575673059463552
> ──────────────────────────────────────────────────
>
> @Andrey__HQ (Andrey):
> @trq212 @bcherny feeding this article into Claude to get it to self improve
> 📅 Thu Feb 19 20:08:49 +0000 2026
> 🔗 https://x.com/Andrey__HQ/status/2024576927886168479
> ──────────────────────────────────────────────────
>
> @Dan_The_Goodman (Dan Goodman 🍊):
> @trq212 @bcherny How do you send an updated system message? Anthropic api doesn’t allow them after the first user/assistant message
> 📅 Thu Feb 19 20:09:48 +0000 2026
> 🔗 https://x.com/Dan_The_Goodman/status/2024577177342398560
> ──────────────────────────────────────────────────
>
> @neslyio (Nesly):
> @trq212 does the claude agent sdk also use all this cache logic out of the box?
> 📅 Thu Feb 19 20:12:00 +0000 2026
> 🔗 https://x.com/neslyio/status/2024577731963580715
> ──────────────────────────────────────────────────
>
> @trq212 (Thariq):
> @neslyio yup
> 📅 Thu Feb 19 20:12:21 +0000 2026
> 🔗 https://x.com/trq212/status/2024577818135580800
> ──────────────────────────────────────────────────
>
> @trq212 (Thariq):
> @Dan_The_Goodman @bcherny Ah apologies, it’s system reminders in user messages. I’ll update.
> 📅 Thu Feb 19 20:17:32 +0000 2026
> 🔗 https://x.com/trq212/status/2024579125319811141
> ──────────────────────────────────────────────────
>
> @Truunik (Truu🐻‍❄️):
> @trq212 Is it ok to use OpenClaw with Claude code ?
>
> Thinking about using our business plan to test how it would work as an assistant .
>
> Would appreciate a clear answer, I don’t want to set our subscription at danger😅
> 📅 Thu Feb 19 20:38:09 +0000 2026
> 🔗 https://x.com/Truunik/status/2024584312381755705
> ──────────────────────────────────────────────────
>
> @flowpow123 (Alec Flowers):
> @trq212 Great Article! Definitely important its all built into the system so the user needs to not think so much about it. Would you ever warn a user to not do something if it will invalidate a lot of cache?
> 📅 Thu Feb 19 20:45:18 +0000 2026
> 🔗 https://x.com/flowpow123/status/2024586112258437564
> ──────────────────────────────────────────────────
>
> @hnshah (Hiten Shah):
> @trq212 Thank you for sharing!
> 📅 Thu Feb 19 20:47:51 +0000 2026
> 🔗 https://x.com/hnshah/status/2024586751025828210
> ──────────────────────────────────────────────────
>
> @trq212 (Thariq):
> @flowpow123 ideally users cannot easily invalidate cache themselves, but for example if they choose to switch model that's an easy case of cache invalidation and probably worth warning about
> 📅 Thu Feb 19 21:03:43 +0000 2026
> 🔗 https://x.com/trq212/status/2024590745051726105
> ──────────────────────────────────────────────────
>
> @sawinyh (Nick Sawinyh):
> @trq212 prompt caching is one of those things that sounds like optimization theater until you see the bills. the jump is wild
> 📅 Thu Feb 19 21:05:14 +0000 2026
> 🔗 https://x.com/sawinyh/status/2024591126791934053
> ──────────────────────────────────────────────────
>
> @0xCaptainLevi (Levi 💎⚡️):
> The hidden lesson here is that agentic systems are fundamentally constrained by their economic structure, not just their capabilities. Cache optimization forces architectural decisions that sacrifice flexibility for cost efficiency. The defer_loading pattern is elegant but it also means your agent cant dynamically discover what it needs on the fly. This creates an interesting tension: as inference costs drop following Wrights Law, some of these optimizations become unnecessary. But as agents run longer sessions with more context, cache efficiency becomes MORE critical, not less. The winners will be systems that can adapt their caching strategy based on the cost-capability frontier at any given moment.
> 📅 Thu Feb 19 21:06:39 +0000 2026
> 🔗 https://x.com/0xCaptainLevi/status/2024591483119296767
> ──────────────────────────────────────────────────
>
> @0xishand (ishan):
> Great writeup. Something I've noticed is that the https://t.co/LbTNYz4nln is re-read from disk and is written into msg[0] on every turn. This means if a user edits it mid-session, the entire conversation prefix is invalidated for that next turn (until the cache breakpoints kick back in for the next turn). 
>
> Is this intentional? Would it not be better to follow a similar pattern that you've described here and instead send a content block stating that the https://t.co/LbTNYz4nln has been updated with a diff? 
>
> I might be missing something here. Please correct me if I'm wrong 😁
> 📅 Thu Feb 19 21:15:49 +0000 2026
> 🔗 https://x.com/0xishand/status/2024593791542567397
> ──────────────────────────────────────────────────
>
> @mert (mert):
> @trq212 what's the solution for claude code routinely forgetting what you specified in claude md
> 📅 Thu Feb 19 22:03:15 +0000 2026
> 🔗 https://x.com/mert/status/2024605727394799831
> ──────────────────────────────────────────────────
>
> @divya_venn (divya venn):
> @trq212 I’m so excited to read this
> 📅 Thu Feb 19 22:28:02 +0000 2026
> 🔗 https://x.com/divya_venn/status/2024611964291600436
> ──────────────────────────────────────────────────
>
> @shteremberg (Daniel Shteremberg):
> For those of us building on the Claude Agents SDK, is there anything special we need to be doing to maximize our use of caching, aside from the points you brought up here? Will the SDK mostly handle caching optimally for us, as long as we follow these rules? Or are there further optimizations we can make on top of what the SDK already does for us?
> 📅 Thu Feb 19 23:35:49 +0000 2026
> 🔗 https://x.com/shteremberg/status/2024629022680928567
> ──────────────────────────────────────────────────
>
> @heymitch (Mitch Harris):
> @trq212 Why not Cache is king?
> 📅 Thu Feb 19 23:36:29 +0000 2026
> 🔗 https://x.com/heymitch/status/2024629191896096967
> ──────────────────────────────────────────────────
>
> @trq212 (Thariq):
> @heymitch ughhhh should have done this
> 📅 Thu Feb 19 23:47:38 +0000 2026
> 🔗 https://x.com/trq212/status/2024631995679318286
> ──────────────────────────────────────────────────
>
> @jvr0x (Javier ⚛ priv/acc):
> @trq212 This is great, glad to know the ins and outs of token caching with claude code, thanks!
> 📅 Thu Feb 19 23:53:42 +0000 2026
> 🔗 https://x.com/jvr0x/status/2024633522850238650
> ──────────────────────────────────────────────────
>
> @trq212 (Thariq):
> @divya_venn lmk what you think!
> 📅 Fri Feb 20 00:09:18 +0000 2026
> 🔗 https://x.com/trq212/status/2024637449478295748
> ──────────────────────────────────────────────────
>
> @trq212 (Thariq):
> @shteremberg nope, caching should just work!
> 📅 Fri Feb 20 00:09:52 +0000 2026
> 🔗 https://x.com/trq212/status/2024637592306930055
> ──────────────────────────────────────────────────
>
> @herbiebradley (Herbie Bradley):
> @trq212 why do you describe Memory as per-project? shouldn't it be cross-Project or global?
> 📅 Fri Feb 20 00:37:52 +0000 2026
> 🔗 https://x.com/herbiebradley/status/2024644637106065410
> ──────────────────────────────────────────────────
>
> @umang (Umang Jaipuria):
> @trq212 Is the system-reminder message supported in the regular messages api too? Or is it only for CC / agents sdk?
> 📅 Fri Feb 20 00:45:44 +0000 2026
> 🔗 https://x.com/umang/status/2024646619581599810
> ──────────────────────────────────────────────────
>
> @AccBalanced (b/acc, context platform engineer):
> @trq212 👌 Echoes of the cool @ManusAI engineering blog about KV Cache vitality in context engineering.
> We’ve also focused on delivering abundance for KV Cache at scale, via 1000x more shared DRAM capacity, via a Context Platform:
>
> https://t.co/e4cuqMkIZZ
> 📅 Fri Feb 20 01:24:39 +0000 2026
> 🔗 https://x.com/AccBalanced/status/2024656413327577161
> ──────────────────────────────────────────────────
>
> @ctjlewis (Lewis 🇺🇸):
> @trq212 "Compaction is what happens when you run out of the context window. We summarize the conversation so far and continue a new session with that summary."
>
> No good.
> 📅 Fri Feb 20 03:26:03 +0000 2026
> 🔗 https://x.com/ctjlewis/status/2024686962452427176
> ──────────────────────────────────────────────────
>
> @JohnMuchow (John Muchow, MSCS):
> @trq212 &gt; You pay full price for all those input tokens, drastically increasing the cost for the user.
>
> Are there suggestions for long conversations that are recommended to limit or avoid compaction?
> 📅 Fri Feb 20 03:39:34 +0000 2026
> 🔗 https://x.com/JohnMuchow/status/2024690364464906355
> ──────────────────────────────────────────────────
>
> @JiquanNgiam (Jiquan Ngiam):
> I think this is why using the OAuth token with other agent harnesses isn't great - they do not do the same optimizations that Anthropic is doing (like figuring out all the compaction edge cases).
>
> My hunch is that those unoptimized harnesses cause cache misses, which end up costing the user much more in rate limits - so net net a worse user experience.
> 📅 Fri Feb 20 05:21:45 +0000 2026
> 🔗 https://x.com/JiquanNgiam/status/2024716078300168702
> ──────────────────────────────────────────────────
>
> @bittybitbit86 (LiτBro):
> @trq212 Nice article. Will be adding your defer_loading for tool stubs to my already cache friendly stack. https://t.co/rbt4kjEAkp
> ![[HBlymbgWEAA0UxQ.jpg]]
> 📅 Fri Feb 20 09:17:59 +0000 2026
> 🔗 https://x.com/bittybitbit86/status/2024775529438581081
> ──────────────────────────────────────────────────
>
> @samwhoo (Sam Rose):
> @trq212 And if you read this and are interested in what’s actually getting cached under the hood, i wrote this last year just for you 🙏
>
> https://t.co/vw8LAIuIss
> 📅 Sat Feb 21 00:46:54 +0000 2026
> 🔗 https://x.com/samwhoo/status/2025009297709560150
> ──────────────────────────────────────────────────

