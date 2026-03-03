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

> [!quote]- Source Material
> 
> @nicbstme (Nicolas Bustamante):
> Article: The LLM Context Tax: Best Tips for Tax Avoidance
> 
> The Context Tax is what you pay when you fill your context window with useless tokens.
> 
> Every token you send to an LLM costs money. Every token increases latency. And past a certain point, every additional token makes your agent dumber. This is the triple penalty of context bloat: higher costs, slower responses, and degraded performance through context rot, where the agent gets lost in its own accumulated noise.
> 
> Context engineering is very important. The difference between a $0.50 query and a $5.00 query is often just how thoughtfully you manage context. Here's what I'll cover:
> 
> 1. Stable Prefixes for KV Cache Hits - The single most important optimization for production agents
> 
> 2. Append-Only Context - Why mutating context destroys your cache hit rate
> 
> 3. Store Tool Outputs in the Filesystem - Cursor's approach to avoiding context bloat
> 
> 4. Design Precise Tools - How smart tool design reduces token consumption by 10x
> 
> 5. Clean Your Data First (Maximize Your Deductions) - Strip the garbage before it enters context
> 
> 6. Delegate to Cheaper Subagents (Offshore to Tax Havens) - Route token-heavy operations to smaller models
> 
> 7. Reusable Templates Over Regeneration (Standard Deductions) - Stop regenerating the same code
> 
> 8. The Lost-in-the-Middle Problem - Strategic placement of critical information
> 
> 9. Server-Side Compaction (Depreciation) - Let the API handle context decay automatically
> 
> 10. Output Token Budgeting (Withholding Tax) - The most expensive tokens are the ones you generate
> 
> 11. The 200K Pricing Cliff (The Tax Bracket) - The tax bracket that doubles your bill overnight
> 
> 12. Parallel Tool Calls (Filing Jointly) - Fewer round trips, less context accumulation
> 
> 13. Application-Level Response Caching (Tax-Exempt Status) - The cheapest token is the one you never send
> 
> ## Why Context Tax Matters
> 
> With Claude Opus 4.6, the math is brutal:
> 
> That's a 10x difference between cached and uncached inputs. Output tokens cost 5x more than uncached inputs. Most agent builders focus on prompt engineering while hemorrhaging money on context inefficiency.
> 
> In most agent workflows, context grows substantially with each step while outputs remain compact. This makes input token optimization critical: a typical agent task might involve 50 tool calls, each accumulating context.
> 
> The performance penalty is equally severe. Research shows that past 32K tokens, most models show sharp performance degradation. Your agent isn't just getting expensive. It's getting confused.
> 
> ## Stable Prefixes for KV Cache Hits
> 
> This is the single most important metric for production agents: KV cache hit rate.
> 
> The [Manus team considers this](https://manus.im/blog/Context-Engineering-for-AI-Agents-Lessons-from-Building-Manus) the most important optimization for their agent infrastructure, and I agree completely. The principle is simple: LLMs process prompts autoregressively, token by token. If your prompt starts identically to a previous request, the model can reuse cached key-value computations for that prefix.
> 
> > The killer of cache hit rates? Timestamps.
> 
> A common mistake is including a timestamp at the beginning of the system prompt. It's a simple mistake but the impact is massive. The key is granularity: including the date is fine. Including the hour is acceptable since cache durations are typically 5 minutes (Anthropic default) to 10 minutes (OpenAI default), with longer options available.
> 
> But never include seconds or milliseconds. A timestamp precise to the second guarantees every single request has a unique prefix. Zero cache hits. Maximum cost.
> 
> Move all dynamic content (including timestamps) to the END of your prompt. System instructions, tool definitions, few-shot examples, all of these should come first and remain identical across requests.
> 
> For distributed systems, ensure consistent request routing. Use session IDs to route requests to the same worker, maximizing the chance of hitting warm caches.
> 
> ## Append-Only Context
> 
> Context should be append-only. Any modification to earlier content invalidates the KV cache from that point forward.
> 
> This seems obvious but the violations are subtle:
> 
> The tool definition problem is particularly insidious. If you dynamically add or remove tools based on context, you invalidate the cache for everything after the tool definitions.
> 
> Manus solved this elegantly: instead of removing tools, they mask token logits during decoding to constrain which actions the model can select. The tool definitions stay constant (cache preserved), but the model is guided toward valid choices through output constraints.
> 
> For simpler implementations, keep your tool definitions static and handle invalid tool calls gracefully in your orchestration layer.
> 
> Deterministic serialization matters too. Python dicts don't guarantee order. If you're serializing tool definitions or context as JSON, use sort_keys=True or a library that guarantees deterministic output. A different key order = different tokens = cache miss.
> 
> ## Store Tool Outputs in the Filesystem
> 
> [Cursor's approach](https://cursor.com/blog/dynamic-context-discovery) to context management changed how I think about agent architecture. Instead of stuffing tool outputs into the conversation, write them to files.
> 
> In their A/B testing, this reduced total agent tokens by 46.9% for runs using MCP tools.
> 
> The insight: agents don't need complete information upfront. They need the ability to access information on demand. Files are the perfect abstraction for this.
> 
> We apply this pattern everywhere:
> 
> - Shell command outputs: Write to files, let agent tail or grep as needed
> 
> - Search results: Return file paths, not full document contents
> 
> - API responses: Store raw responses, let agent extract what matters
> 
> - Intermediate computations: Persist to disk, reference by path
> 
> When context windows fill up, Cursor triggers a summarization step but exposes chat history as files. The agent can search through past conversations to recover details lost in the lossy compression. Clever.
> 
> ## Design Precise Tools
> 
> A vague tool returns everything. A precise tool returns exactly what the agent needs.
> 
> Consider an email search tool:
> 
> The two-phase pattern: search returns metadata, separate tool returns full content. The agent decides which items deserve full retrieval.
> 
> This is exactly how our conversation history tool works at Fintool. It passes date ranges or search terms and returns up to 100-200 results with only user messages and metadata. The agent then reads specific conversations by passing the conversation ID. Filter parameters like has_attachment, time_range, and sender let the agent narrow results before reading anything.
> 
> The same pattern applies everywhere:
> 
> - Document search: Return titles and snippets, not full documents
> 
> - Database queries: Return row counts and sample rows, not full result sets
> 
> - File listings: Return paths and metadata, not contents
> 
> - API integrations: Return summaries, let agent drill down
> 
> Each parameter you add to a tool is a chance to reduce returned tokens by an order of magnitude.
> 
> ## Clean Your Data First (Maximize Your Deductions)
> 
> Garbage tokens are still tokens. Clean your data before it enters context.
> 
> For emails, this means:
> 
> For HTML content, the gains are even larger. A typical webpage might be 100KB of HTML but only 5KB of actual content. CSS selectors that extract semantic regions (article, main, section) and discard navigation, ads, and tracking can reduce token counts by 90%+.
> 
> [Markdown uses significantly fewer tokens than HTML](https://dev.to/rosgluk/html-preprocessing-for-llms-3mk8), making conversion valuable for any web content entering your pipeline.
> 
> For financial data specifically:
> 
> - Strip SEC filing boilerplate (every 10-K has the same legal disclaimers)
> 
> - Collapse repeated table headers across pages
> 
> - Remove watermarks and page numbers from extracted text
> 
> - Normalize whitespace (multiple spaces, tabs, excessive newlines)
> 
> - Convert HTML tables to markdown tables
> 
> The principle: remove noise at the earliest possible stage, not after tokenization. Every preprocessing step that runs before the LLM call saves money and improves quality.
> 
> ## Delegate to Cheaper Subagents (Offshore to Tax Havens)
> 
> Not every task needs your most expensive model.
> 
> The [Claude Code subagent pattern](https://code.claude.com/docs/en/sub-agents) processes 67% fewer tokens overall due to context isolation. Instead of stuffing every intermediate search result into a single global context, workers keep only what's relevant inside their own window and return distilled outputs.
> 
> Tasks perfect for cheaper subagents:
> 
> - Data extraction: Pull specific fields from documents
> 
> - Classification: Categorize emails, documents, or intents
> 
> - Summarization: Compress long documents before main agent sees them
> 
> - Validation: Check outputs against criteria
> 
> - Formatting: Convert between data formats
> 
> The orchestrator sees condensed results, not raw context. This prevents hitting context limits and reduces the risk of the main agent getting confused by irrelevant details.
> 
> Scope subagent tasks tightly. The more iterations a subagent requires, the more context it accumulates and the more tokens it consumes. Design for single-turn completion when possible.
> 
> ## Reusable Templates Over Regeneration (Standard Deductions)
> 
> Every time an agent generates code from scratch, you're paying for output tokens. Output tokens cost 5x input tokens with Claude. Stop regenerating the same patterns.
> 
> Our document generation workflow used to be painfully inefficient:
> 
> > OLD APPROACH:
> User: "Create a DCF model for Apple"
> Agent: *generates 2,000 lines of Excel formulas from scratch*
> Cost: ~$0.50 in output tokens alone
> 
> NEW APPROACH:
> User: "Create a DCF model for Apple"
> Agent: *loads DCF template, fills in Apple-specific values*
> Cost: ~$0.05
> 
> The template approach:
> 
> 1. Skill references template: dcf_template.xlsx in /public/skills/dcf/
> 
> 2. Agent reads template once: Understands structure and placeholders
> 
> 3. Agent fills parameters: Company-specific values, assumptions
> 
> 4. WriteFile with minimal changes: Only modified cells, not full regeneration
> 
> For code generation, the same principle applies. If your agent frequently generates similar Python scripts, data processing pipelines, or analysis frameworks, create reusable functions:
> 
> > # Instead of regenerating this every time:
> def process_earnings_transcript(path):
>     # 50 lines of parsing code...
> 
> # Reference a skill with reusable utilities:
> from skills.earnings import parse_transcript, extract_guidance
> 
> The agent imports and calls rather than regenerates. Fewer output tokens, faster responses, more consistent results.
> 
> ## The Lost-in-the-Middle Problem
> 
> LLMs don't process context uniformly. [Research shows](https://arxiv.org/abs/2307.03172) a consistent U-shaped attention pattern: models attend strongly to the beginning and end of prompts while "losing" information in the middle.
> 
> Strategic placement matters:
> 
> - System instructions: Beginning (highest attention)
> 
> - Current user request: End (recency bias)
> 
> - Critical context: Beginning or end, never middle
> 
> - Lower-priority background: Middle (acceptable loss)
> 
> For retrieval-augmented generation, this means reordering retrieved documents. The most relevant chunks should go at the beginning and end. Lower-ranked chunks fill the middle.
> 
> Manus uses an elegant hack: they maintain a todo.md file that gets updated throughout task execution. This "recites" current objectives at the end of context, combating the lost-in-the-middle effect across their typical 50-tool-call trajectories. We use a similar architecture at Fintool.
> 
> ## Server-Side Compaction (Depreciation)
> 
> As agents run, context grows until it hits the window limit. You used to have two options: build your own summarization pipeline, or implement observation masking (replacing old tool outputs with placeholders). Both require significant engineering.
> 
> Now you can let the API handle it. Anthropic's [server-side compaction](https://platform.claude.com/docs/en/build-with-claude/compaction) automatically summarizes your conversation when it approaches a configurable token threshold. Claude Code uses this internally, and it's the reason you can run 50+ tool call sessions without the agent losing track of what it's doing.
> 
> The key design decisions:
> 
> - Trigger threshold: Default is 150K tokens. Set it lower if you want to stay under the 200K pricing cliff, or higher if you need more raw context before summarizing.
> 
> - Custom instructions: You can replace the default summarization prompt entirely. For financial workflows, something like "Preserve all numerical data, company names, and analytical conclusions" prevents the summary from losing critical details.
> 
> - Pause after compaction: The API can pause after generating the summary, letting you inject additional context (like preserving the last few messages verbatim) before continuing. This gives you control over what survives the compression.
> 
> Compaction also stacks well with prompt caching. Add a cache breakpoint on your system prompt so it stays cached separately. When compaction occurs, only the summary needs to be written as a new cache entry. Your system prompt cache stays warm.
> 
> The beauty of this approach: context depreciates in value over time, and the API handles the depreciation schedule for you.
> 
> ## Output Token Budgeting (Withholding Tax)
> 
> Output tokens are the most expensive tokens. With Claude Sonnet, outputs cost 5x inputs. With Opus, they cost 5x inputs that are already expensive.
> 
> Yet most developers leave max_tokens unlimited and hope for the best.
> 
> > # BAD: Unlimited output
> response = client.messages.create(
>     model="claude-sonnet-4-20250514",
>     max_tokens=8192,  # Model might use all of this
>     messages=[...]
> )
> 
> # GOOD: Task-appropriate limits
> TASK_LIMITS = {
>     "classification": 50,
>     "extraction": 200,
>     "short_answer": 500,
>     "analysis": 2000,
>     "code_generation": 4000,
> }
> 
> Structured outputs reduce verbosity. JSON responses use fewer tokens than natural language explanations of the same information.
> 
> Natural language: "The company's revenue was 94.5 billion dollars,
> which represents a year-over-year increase of 12.3 percent compared
> to the previous fiscal year's revenue of 84.2 billion dollars."
> 
> Structured: {"revenue": 94.5, "unit": "B", "yoy_change": 12.3}
> 
> For agents specifically, consider response chunking. Instead of generating a 10,000-token analysis in one shot, break it into phases:
> 
> 1. Outline phase: Generate structure (500 tokens)
> 
> 2. Section phases: Generate each section on demand (1000 tokens each)
> 
> 3. Review phase: Check and refine (500 tokens)
> 
> This gives you control points to stop early if the user has what they need, rather than always generating the maximum possible output.
> 
> ## The 200K Pricing Cliff (The Tax Bracket)
> 
> With Claude Opus 4.6 and Sonnet 4.5, crossing 200K input tokens triggers premium pricing. Your per-token cost doubles: Opus goes from $5 to $10 per million input tokens, and output jumps from $25 to $37.50. This isn't gradual. It's a cliff.
> 
> This is the LLM equivalent of a tax bracket. And just like tax planning, the right strategy is to stay under the threshold when you can.
> 
> For agent workflows that risk crossing 200K, implement a context budget. Track cumulative input tokens across tool calls. When you approach the cliff, trigger aggressive compression: observation masking, summarization of older turns, or pruning low-value context. The cost of a compression step is far less than doubling your per-token rate for the rest of the conversation.
> 
> ## Parallel Tool Calls (Filing Jointly)
> 
> Every sequential tool call is a round trip. Each round trip re-sends the full conversation context. If your agent makes 20 tool calls sequentially, that's 20 times the context gets transmitted and billed.
> 
> The Anthropic API supports parallel tool calls: the model can request multiple independent tool calls in a single response, and you execute them simultaneously. This means fewer round trips for the same amount of work.
> 
> The savings compound. With fewer round trips, you accumulate less intermediate context, which means each subsequent round trip is also cheaper. Design your tools so that independent operations can be identified and batched by the model.
> 
> ## Application-Level Response Caching (Tax-Exempt Status)
> 
> > The cheapest token is the one you never send to the API.
> 
> Before any LLM call, check if you've already answered this question. At Fintool, we cache aggressively for earnings call summarizations and common queries. When a user asks for Apple's latest earnings summary, we don't regenerate it from scratch for every request. The first request pays the full cost. Every subsequent request is essentially free.
> 
> This operates above the LLM layer entirely. It's not prompt caching or KV cache. It's your application deciding that this query has a valid cached response and short-circuiting the API call.
> 
> Good candidates for application-level caching:
> 
> - Factual lookups: Company financials, earnings summaries, SEC filings
> 
> - Common queries: Questions that many users ask about the same data
> 
> - Deterministic transformations: Data formatting, unit conversions
> 
> - Stable analysis: Any output that won't change until the underlying data changes
> 
> The cache invalidation strategy matters. For financial data, earnings call summaries are stable once generated. Real-time price data obviously isn't. Match your cache TTL to the volatility of the underlying data.
> 
> Even partial caching helps. If an agent task involves five tool calls and you can cache two of them, you've cut 40% of your tool-related token costs without touching the LLM.
> 
> ## The Tax Avoidance Checklist to avoid the IRS of LLMs.
> 
> ## The Meta Lesson
> 
> Context engineering isn't glamorous. It's not the exciting part of building agents. But it's the difference between a demo that impresses and a product that scales with decent gross margin.
> 
> The best teams building sustainable agent products are obsessing over token efficiency the same way database engineers obsess over query optimization. Because at scale, every wasted token is money on fire.
> 
> The context tax is real. But with the right architecture, it's largely avoidable.
> date: Wed Feb 11 18:44:59 +0000 2026
> url: https://x.com/nicbstme/status/2021656728094617652
> ──────────────────────────────────────────────────
> 
> @0xsmeet (Smeet Dhakecha):
> @nicbstme great tips. making small improvements such as the stable prefixes, or cleaning the data adds up for  context optimization. 
> 
> have you tried to make these as skills so
> agents can do some of it automatically?
> date: Wed Feb 11 19:30:57 +0000 2026
> url: https://x.com/0xsmeet/status/2021668298329616485
> ──────────────────────────────────────────────────
> 
> @luckwi (Guillaume Luccisano):
> @nicbstme Love all the tax references you put in there!
> date: Thu Feb 12 03:01:17 +0000 2026
> url: https://x.com/luckwi/status/2021781627299672116
> ──────────────────────────────────────────────────
> 
> @nicbstme (Nicolas Bustamante):
> @luckwi As a Frenchman I know a lot about taxes
> date: Thu Feb 12 06:34:56 +0000 2026
> url: https://x.com/nicbstme/status/2021835394678239347
> ──────────────────────────────────────────────────
> 
> @ydrecords (Yellow Dog Records):
> @nicbstme This is a fantastic walkthrough!
> 
> (Can’t help pointing out that Python dicts have guaranteed order since Python 3.6, though)
> date: Thu Feb 12 08:37:23 +0000 2026
> url: https://x.com/ydrecords/status/2021866211319967838
> ──────────────────────────────────────────────────
> 
> @aekae8888 (AK):
> @nicbstme Can’t wait for RLMs to take off 🙏🏼 but until then thanks for the tips!
> date: Thu Feb 12 10:42:41 +0000 2026
> url: https://x.com/aekae8888/status/2021897743745396923
> ──────────────────────────────────────────────────
> 
> @KBezbailis (Kristaps Bezbailis):
> @nicbstme Won't lie, when I first saw it, I thought it's a post about how to use (or not use) LLMs for tax avoidance 😅
> date: Thu Feb 12 18:46:52 +0000 2026
> url: https://x.com/KBezbailis/status/2022019593011871793
> ──────────────────────────────────────────────────
> 
> @nicbstme (Nicolas Bustamante):
> @KBezbailis When you get your first $100k LLM bill taxes feel like a rounding error.
> date: Thu Feb 12 18:50:20 +0000 2026
> url: https://x.com/nicbstme/status/2022020463199948866
> ──────────────────────────────────────────────────
> 
> @raymondmarkable (Ray Markable):
> @nicbstme Why is context append-only? I get that capturing the full thought process is ideal, but wouldn't having stale context be more likely to lead to hallucinations?
> date: Thu Feb 12 23:02:07 +0000 2026
> url: https://x.com/raymondmarkable/status/2022083828039528934
> ──────────────────────────────────────────────────
