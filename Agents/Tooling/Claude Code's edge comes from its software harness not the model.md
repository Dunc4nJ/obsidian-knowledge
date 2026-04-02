---
created: 2026-04-02
description: Analysis of the leaked Claude Code source reveals that its coding superiority stems from context management, caching, tooling, and session memory engineering rather than model quality alone.
source: https://x.com/rasbt/status/2038980345316413862
type: synthesis
---

## Key Takeaways

The leaked Claude Code TypeScript source confirms what builders have intuited: the model is necessary but not sufficient. The real differentiator is a carefully designed software harness around it. Raschka argues that dropping in DeepSeek, MiniMax, or Kimi with similar scaffolding would yield comparable coding performance — a strong claim that reframes coding agent competition as an engineering problem, not a model problem.

The live repo context loading (git branch, recent commits, CLAUDE.md) is table stakes, but the aggressive prompt cache reuse is where things get interesting. Claude Code uses boundary markers to separate static and dynamic content so expensive static sections are globally cached — directly implementing what [[six cache-friendly patterns from Claude Code make prompt caching practical for production agents]] describes, and reinforcing why [[prompt caching is the foundational constraint for building long-running agents]].

Context bloat management is where most of the plumbing lives: file-read deduplication skips unchanged files, oversized tool results get written to disk with only a preview in context, and auto-compaction summarizes when needed. This is the practical engineering response to [[context tax compounds through cache misses bloated tools and unbudgeted output tokens]] — every technique directly reduces the tax.

The dedicated Grep and Glob tools (instead of raw bash) and the LSP integration for call hierarchy and references are what elevate it beyond "chat with uploaded files." The LSP connection means the agent sees code as a structured graph, not static text — a meaningful upgrade for navigation-heavy tasks.

The structured session memory (markdown file with Current State, Task spec, Files/Functions, Errors, Learnings, Worklog) is essentially what [[auto-caching with Claude eliminates manual breakpoint management for multi-turn agents]] advocates: persistent working memory that survives context compaction. Combined with fork-based subagents that reuse the parent's cache while isolating mutable state, this creates a multi-agent architecture where background work (summarization, memory extraction) doesn't contaminate the main loop — similar to how [[Symphony turns Linear tickets into merged PRs by orchestrating parallel Codex agents with hot-reloadable prompts]] orchestrates parallel agents.

The implication for anyone building coding agents: invest in the harness. The model gets you 60%; the remaining 40% is caching strategy, context hygiene, structured tools, and session memory.

## External Resources

- [Sebastian Raschka's analysis thread](https://x.com/rasbt/status/2038980345316413862) — original breakdown of Claude Code internals

## Original Content

> [!quote]- Source Material
>
> **@rasbt** (Sebastian Raschka) · Tue Mar 31 2026 · 2,794 likes · 414 retweets · 75 replies
>
> Article: Claude Code's Real Secret Sauce (Probably) Isn't the Model
>
> Turns out Claude Code source code was leaked today. I saw several snapshots of the TypeScript code base on GitHub. I don't want to link here for legal reasons, but there are some interesting educational tidbits that can be learned here.
>
> Of course, it's probably common knowledge that Claude Code works better for coding than the Claude web chat because it is not just a chat interface with a shell added to it but more of a carefully designed tool with some nice prompt and context optimizations.
>
> I should also say that while a lot of the qualitative coding performance comes from the model itself, I believe the reason why Claude Code is so good is this software harness, meaning that if we were to drop in other models (say DeepSeek, MiniMax, or Kimi) and optimize this a bit for these models, we would also have very strong coding performance.
>
> Anyways, below are some interesting tidbits for educational purposes to better understand how coding agents work.
>
> # 1. Claude Code Builds a Live Repo Context
>
> This is maybe most obvious, but when you start prompting, Claude loads the main git branch, current git branch, recent commits, etc. in addition to CLAUDE.md for context.
>
> # 2. Aggressive Prompt Cache Reuse
>
> There seems to be something like a boundary marker that separates static and dynamic content. Meaning the static sections are globally cached for stability so that the expensive parts do not need to be rebuilt and reprocessed every time.
>
> # 3. The Tooling Is Better Than "Chat With Uploaded Files"
>
> The prompt seems to tell the model to uses a dedicated Grep tool instead of invoking grep or rg through Bash, presumably because the dedicated tool has better permission handling and (perhaps?) better result collection.
>
> There is also a dedicated Glob tool for file discovery. And finally it also has a LSP (Language Server Protocol) tool for call hierarchy, finding references etc. That should be a big "power up" compared to the Chat UI, which (I think) sees the code more as static text.
>
> # 4. Minimizing Context Bloat
>
> One of the biggest problems is, of course, the limited context size when working with code repos. This is especially true if we have back-and-forths with the agent and repeated file reads, log files, long shell outputs etc.
>
> There is a lot of plumbing in Claude Code to minimize that. For example, they do have file-read deduplication that checks whether a file is unchanged and then doesn't reprocess these unchanged files.
>
> Also, if tool results do get too large, they are written to disk, and the context only uses a preview plus a file reference.
>
> And, of course, similar to any modern LLM UI, it would automatically truncate long contexts and run autocompaction (/summarization) if needed.
>
> # 5. Structured Session Memory
>
> Claude Code keeps a structured markdown file for the current conversation with sections like:
>
> - Session Title
>
> - Current State
>
> - Task specification
>
> - Files and Functions
>
> - Workflow
>
> - Errors & Corrections
>
> - Codebase and System Documentation
>
> - Learnings
>
> - Key results
>
> - Worklog
>
> It's kind of how we humans code, I'd say, where we keep notes and summaries.
>
> # 6. It Uses Forks and Subagents
>
> This is probably no surprise that Claude Code parallizes work with subagents. That was basically one of the selling points over Codex for a long time (until Codex recently also added subagent support).
>
> Here, forked agents reuse the parent's cache while being aware or mutable states. So, that lets the system do side work such as summarization, memory extraction, or background analysis without contaminating the main agent loop.
>
> # Why This Probably Feels And Works Better Than Coding in the Web UI
>
> All in all, the reason why Claude Code works better than the plain web UI is not prompt engineering or a better model. It's all these little performance and context handling improvement listed above. And there is the convenience, of course, too, in having everything nice and organized on your computer versus uploading files to a Chat UI.

[Source](https://x.com/rasbt/status/2038980345316413862)
