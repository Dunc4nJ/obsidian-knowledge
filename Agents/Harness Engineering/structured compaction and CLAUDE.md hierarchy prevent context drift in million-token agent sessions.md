---
created: 2026-03-15
description: A runbook for running Claude agents at 1M context without performance degradation, covering three failure modes (context saturation, instruction dilution, reasoning loop collapse) and the compaction harness plus CLAUDE.md architecture that addresses them.
source: https://x.com/nyk_builderz/status/2033130168689307719
type: framework
---

# Structured compaction and CLAUDE.md hierarchy prevent context drift in million-token agent sessions

## Key Takeaways

The central thesis is that bigger context windows make agent reliability *worse* unless paired with active context management. A 1M window with 800K tokens of accumulated noise performs worse than a 200K window with 150K of curated signal. This is the same insight behind [[autonomous context compression lets agents choose when to compact rather than hitting fixed token limits]] — the key variable is signal density, not window size.

Three distinct failure modes explain virtually all long-running agent breakdowns. Context saturation (accumulated tool outputs drown signal), instruction dilution (early instructions lose attention weight as context grows), and reasoning loop collapse (contradictory reasoning chains from retry attempts cause circular debugging). The instruction dilution failure is particularly insidious — instructions that were 5% of context at session start become 0.5% at 200K tokens. This connects directly to the [[context files beat MCP schemas for internal agents because they encode how your team actually uses each tool]] principle: persistent context files survive compaction while conversational instructions don't.

The compaction harness configuration is concrete and actionable: trigger at 80K tokens (not the 150K default), use custom compaction instructions that specify what to preserve (task state, active files, recent test output) and what to discard (old reads, abandoned approaches). This mirrors the reduce/isolate/offload pattern documented in [[terminal-native coding agents need scaffolding harness separation and context engineering as first-class concerns]].

The CLAUDE.md hierarchy — global, project, scoped rules with `paths:` frontmatter — is a context budget strategy. Scoped rules that load on-demand when touching matching files prevent irrelevant instructions from consuming attention. Combined with the auto-memory discipline (keep MEMORY.md under 200 lines, move details to topic files), this forms a structured memory architecture similar to what [[Slate's thread-based episodic memory solves long-horizon agent tasks]] addresses from a different angle.

Adaptive thinking effort levels (low/medium/high/max) serve as a secondary compaction lever: lower effort on routine tool calls produces shorter thinking traces, slowing context accumulation by ~40% and reducing compaction frequency — since every compaction event loses some signal, fewer compactions means better task completion. This is a novel framing not seen in [[prompt caching is the foundational constraint for building long-running agents]] which focuses on the cost side rather than the signal-preservation side.

## External Resources

- [Anthropic Compaction API beta](https://platform.claude.com/docs) — `compact-2026-01-12` header, minimum 50K token trigger
- [MRCR v2 benchmark results](https://platform.claude.com/docs) — Opus 4.6 scores 76% on 8-needle 1M token retrieval vs Sonnet 4.5 at 18.5%

## Original Content

> **@nyk_builderz** (Nyk) — Sun Mar 15 2026 — 65 likes, 8 retweets, 2 replies

*Article header image*
![[nyk_builderz-307719-001.jpg]]

> Article: How I Run Claude Agents on 1M Context Without Drift
>
> Everyone says bigger context windows fix agent reliability. Anthropic made 1M tokens standard on Opus 4.6 and Sonnet 4.6 — zero price premium. Shipped March 13. The default response will be to load everything, hit 800K tokens, and watch agents hallucinate worse than before.
>
> The problem was never the window size. It was context rot — performance degrades as conversations fill, not because the model forgets, but because signal drowns in noise. If you run agents in production, this is the only engineering problem that matters right now.
>
> Here are the 3 failure modes that explain every long-running agent disaster. The compaction harness config that cut our agent failure rate from 40% to under 3%. and the exact CLAUDE.md architecture that makes 1M tokens compound instead of decay. Save this runbook.
>
> ## The Three Failure Modes
>
> Every agent failure I have traced in the last 6 months falls into one of three categories. Nearly everyone only recognizes the first one.
>
> Failure 1: Context Saturation
>
> The agent accumulates tool call results, file contents, and search outputs. and reasoning traces. By 100K tokens, the window is 60% noise — old file reads. Superseded search results. abandoned reasoning paths. The model treats everything in the window with roughly equal weight. It cannot distinguish a file it read 50 tool calls ago from the one it opened 3 seconds ago.
>
> This is the failure everyone recognizes. The fix everyone tries is "use a bigger window." That makes it worse. A 1M window with 800K tokens of accumulated noise performs worse than a 200K window with 150K tokens of curated signal.
>
> The real fix: Structured compaction before the window fills, not after.
>
> Failure 2: Instruction Dilution
>
> Your system prompt says "use pnpm." Your CLAUDE.md says "run tests before committing." The project README says "use npm." by token 200K. These instructions compete with 150K tokens of conversation history. The model starts dropping instructions it saw early in the window.
>
> This is not a hallucination problem. This is an attention problem. Instructions that were 5% of the context at session start become 0.5% at token 200K. The model follows them less reliably because they occupy less of its attention budget.
>
> Anthropic's internal testing found that instruction adherence drops measurably as context fills. Their fix was not better models. It was compaction — re-injecting instructions fresh after summarizing stale context.
>
> Failure 3: Reasoning Loop Collapse
>
> The agent hits a bug, generates a fix, and tests it. gets a new error. generates another fix by the fifth iteration. Every prior attempt and its error trace are in the window. The model starts blending reasoning from attempt 2 with code from attempt 4. It proposes fixes it has already tried. It debugs in circles.
>
> This is the failure that burns the most tokens and produces the least value. The agent is not stuck because it lacks intelligence. It is stuck because its context contains five contradictory reasoning chains, and it cannot determine which one is current.
>
> ## The Compaction Harness
>
> The fix for all three failure modes is the same architecture: structured compaction that preserves signal and discards noise before the window degrades.
>
> API-Level: Server-Side Compaction
>
> Anthropic shipped the Compaction API as a beta feature with Opus 4.6. it triggers automatically when input tokens exceed a threshold, summarizes older context, and continues with a compressed state.
>
> ```
> import anthropic
>
> client = anthropic.Anthropic()
>
> response = client.beta.messages.create(
>  betas=["compact-2026-01-12"],
>  model="claude-opus-4-6",
>  max_tokens=16000,
>  thinking={"type": "adaptive"},
>  messages=messages,
>  context_management={
>  "edits": [
>  {
>  "type": "compact_20260112",
>  "trigger": {
>  "type": "input_tokens",
>  "value": 80000
>  },
>  }
>  ]
>  },
> )
> ```
>
> The key parameters:
>
> - trigger.value: when compaction fires. The default is 150,000 tokens. I set mine to 80,000 — compacting early preserves more signal than compacting late
>
> - Instructions: custom summarization prompt. completely replaces the default. Use this to tell the compactor what to preserve (current task state, file paths, test results) and what to discard (old search results, abandoned approaches)
>
> - pause_after_compaction: pauses after generating the summary, allowing you to inspect or modify it before continuing. Useful during development, disable in production
>
> The minimum trigger is 50,000 tokens. Anything below that and the summary itself consumes too much of the remaining window.
>
> Claude Code: The /compact Discipline
>
> If you use Claude Code, compaction runs automatically when context approaches ~85% capacity. The problem is that 85% is already too late — performance has degraded before compaction fires.
>
> The operator discipline:
>
> 1. manual /compact at 50% context usage (check with cost display)
>
> 2. /clear before switching major topics
>
> 3. /compact after any large file read or search operation that dumps >20K tokens
>
> CLAUDE.md fully survives compaction. After /compact, Claude rereads your CLAUDE.md from disk and re-injects it fresh. This is why instructions in CLAUDE.md persist, but instructions given only in conversation disappear.
>
> Custom Compaction Instructions
>
> The default compactor is generic. For production agents, replace it with domain-specific instructions:
>
> ```
> compaction_instructions = """
> preserve:
> - current task objective and acceptance criteria
> - file paths of all files currently being modified
> - most recent test output (pass/fail, error messages)
> - active branch name and commit context
> - any numbered step sequence the agent is following
>
> discard:
> - file contents from reads older than 5 tool calls
> - search results that were not acted on
> - reasoning traces from abandoned approaches
> - duplicate error messages from retry loops
>
> format the summary as:
> ## Current State
> [task + branch + files]
>
> ## Recent Results
> [last test output + last tool result]
>
> ## Active Constraints
> [CLAUDE.md rules still in effect]
> """
> ```
>
> This cuts the post-compaction failure rate by roughly half compared to default summarization. The model knows what it was doing. What it was working on. and what rules apply — without the noise of everything it tried along the way.
>
> ## The CLAUDE.md Architecture That Makes 1M Tokens Work
>
> A 1M token window without structured memory is a 1M token garbage collector. The CLAUDE.md hierarchy is how you keep signal density high as context grows.
>
> The Memory Hierarchy
>
> ```
> ~/.claude/CLAUDE.md # global: your tools, style, never-break rules
> ./CLAUDE.md # project: stack, test commands, conventions
> ./.claude/rules/api-design.md # scoped: only loads when touching API files
> ./.claude/rules/testing.md # scoped: only loads when touching test files
> ```
>
> The key insight people miss: CLAUDE.md files in subdirectories load on demand. not at startup. A 500-line CLAUDE.md at the project root wastes context. Split it into scoped rules that load only when the agent touches matching files:
>
> ```
> paths:
>  - "src/api/**/*.ts"
> ```
>
> # API Rules
>
> - all endpoints include input validation
> - use standard error response format from src/api/errors.ts
> - include OpenAPI documentation comments
>
> This means an agent working on frontend components never loads API rules into its context. The window stays clean.
>
> Auto Memory: What Claude Learns Itself
>
> Auto memory is the second system. Claude writes notes to~/.claude/projects/<project>/memory/MEMORY.md as it works — build commands that failed, debugging insights, and architecture patterns it discovered.
>
> The first 200 lines of MEMORY.md load at session start. Lines beyond 200 are truncated. After 10 sessions, auto memory accumulates ~30% redundant entries. clean it regularly.
>
> the operating discipline:
>
> - review auto memory after every 10 sessions
>
> - delete entries that duplicate CLAUDE.md instructions
>
> - move detailed notes into topic files (debugging.md, patterns.md) that Claude reads on demand
>
> - keep MEMORY.md as a concise index, not a log
>
> Adaptive Thinking as a Compaction Lever
>
> Opus 4.6 ships adaptive thinking — the model decides when and how much to reason. This interacts with context management in a way few operators have noticed.
>
> ```
> response = client.messages.create(
>  model="claude-opus-4-6",
>  max_tokens=16000,
>  thinking={"type": "adaptive"}, # replaces budget_tokens
>  messages=messages,
> )
> ```
>
> Four effort levels: low, medium, high (default), max.
>
> For long-running agents, use medium effort for routine tool calls (file reads, searches) and high effort for decisions (which fix to apply, whether to continue or escalate). This is a context budget strategy — lower effort means shorter thinking traces, which means slower context accumulation, which in turn means fewer compaction events.
>
> Every compaction event loses some signal. Reducing compaction frequency by 40% through effort management translates directly to better task completion rates.
>
> ## The Operating Checklist
>
> If you take one thing from this: stop treating context as infinite, even when the window is 1M tokens. Context engineering is the discipline of keeping signal density high as total tokens grow.
>
> 1. set compaction trigger to 80K tokens, not the 150K default
>
> 2. write custom compaction instructions that preserve task state and discard noise
>
> 3. split CLAUDE.md into scoped rules using .claude/rules/ with paths frontmatter
>
> 4. keep MEMORY.md under 200 lines — move details into topic files
>
> 5. use adaptive thinking at medium effort for routine operations to slow context accumulation
>
> 6. manual /compact at 50% context in Claude Code sessions
>
> 7. /clear before topic switches — do not let stale context from task A pollute task B
>
> ## Closing
>
> The window got bigger. That does not mean you should fill it.
>
> Every team I have seen fail with long-context agents made the same mistake: they treated 1M tokens as permission to stop managing context. The teams that succeed treat it as more headroom for structured compaction — more room to preserve the right signal. not more room to accumulate noise.
>
> If you could instrument one context bottleneck this week, which one would you pick first?
>
> ## Evidence Snapshot
>
> - MRCR v2 benchmark (8-needle, 1M tokens): Opus 4.6 scores 76%, Sonnet 4.5 scores 18.5% — 4x improvement in multi-needle retrieval
>
> - Compaction API: beta, compact-2026-01-12 header, trigger minimum 50K tokens, default 150K
>
> - 1M context GA: March 13, 2026 — standard pricing, no long-context surcharge
>
> - Opus 4.6 max output: 128K tokens (2x previous limit)
>
> - CLAUDE.md survives compaction — re-injected fresh from disk after every /compact
>
> - Adaptive thinking effort levels: low, medium, high (default), max
>
> - Source: Anthropic official documentation (platform.claude.com/docs), InfoQ March 2026

[Original tweet](https://x.com/nyk_builderz/status/2033130168689307719)
