---
created: 2026-02-23
description: Claude Code now dynamically loads MCP tool definitions via search instead of preloading them all, triggered when tool descriptions would consume more than 10% of context — resolving a top GitHub request where users had 7+ servers consuming 67K+ tokens.
source: https://x.com/trq212/status/2011523109871108570
type: learning
---

## Key Takeaways

This is Anthropic's production answer to the same problem their engineering blog described in [[code execution with MCP cuts tool token overhead 98 percent by presenting servers as filesystem APIs instead of upfront definitions|code execution with MCP]]: tool definitions consuming too much context. Rather than the code-execution approach (wrapping tools as filesystem APIs), Tool Search takes a simpler path — dynamically loading tool definitions via search when they'd otherwise exceed 10% of context. Below that threshold, tools load normally as before.

The 10% trigger threshold is a pragmatic choice. Users were documenting setups with 7+ MCP servers consuming 67K+ tokens just in tool definitions — before any actual work. This directly compounds the [[context tax compounds through cache misses bloated tools and unbudgeted output tokens|context tax]] problem: bloated tool definitions push useful context out and break cache prefixes.

The "server instructions" field becomes the key discovery mechanism with Tool Search enabled. It tells Claude when to search for a server's tools, functioning like a [[skill graphs outperform single skill files by letting agents traverse linked domain knowledge on demand|skill graph]] description — a short hint that guides the agent to the right tools without loading everything upfront. This is [[progressive disclosure filters force agent selectivity over what enters context|progressive disclosure]] applied directly to tool definitions.

The team experimented with programmatic tool calling (composing MCP tools via code) but prioritized Tool Search first as the more urgent need. This suggests the code execution approach from the engineering blog is still on the roadmap but hasn't shipped in Claude Code yet — Tool Search is the intermediate step.

## External Resources

- [ToolSearchTool documentation](https://platform.claude.com/docs/en/agents-and-tools/tool-use/tool-search-tool) — implementation docs for MCP client developers
- [GitHub issue #7336](https://github.com/anthropics/claude-code/issues/7336) — the original feature request for lazy loading MCP servers

## Original Content

> @trq212 (Thariq) — 2026-01-14
>
> Tool Search now in Claude Code
>
> Today we're rolling out MCP Tool Search for Claude Code.
>
> As MCP has grown to become a more popular protocol and agents have become more capable, we've found that MCP servers may have up to 50+ tools and take up a large amount of context.
>
> Tool Search allows Claude Code to dynamically load tools into context when MCP tools would otherwise take up a lot of context.
>
> How it works:
> - Claude Code detects when your MCP tool descriptions would use more than 10% of context
> - When triggered, tools are loaded via search instead of preloaded
>
> Otherwise, MCP tools work exactly as before.
>
> This resolves one of our most-requested features on GitHub: lazy loading for MCP servers. Users were documenting setups with 7+ servers consuming 67k+ tokens.
>
> If you're making a MCP server:
> Things are mostly the same, but the "server instructions" field becomes more useful with tool search enabled. It helps Claude know when to search for your tools, similar to skills.
>
> If you're making a MCP client:
> We highly suggest implementing the ToolSearchTool, you can find the docs here. We implemented it with a custom search function to make it work for Claude Code.
>
> What about programmatic tool calling?
> We experimented with doing programmatic tool calling such that MCP tools could be composed with each other via code. While we will continue to explore this in the future, we felt the most important need was to get Tool Search out to reduce context usage.
>
> Engagement: 4788 likes | 474 retweets | 205 replies
> [Original post](https://x.com/trq212/status/2011523109871108570)
