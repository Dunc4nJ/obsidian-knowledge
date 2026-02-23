---
created: 2026-02-23
description: Anthropic demonstrates that wrapping MCP servers as TypeScript files on a filesystem lets agents load tool definitions on demand and filter results in code, reducing context overhead from 150K tokens to 2K — a 98.7% reduction.
source: https://www.anthropic.com/engineering/code-execution-with-mcp
type: framework
---

## Key Takeaways

The core problem is that standard MCP clients load all tool definitions upfront into context. With hundreds of tools across dozens of servers, this means processing 150,000+ tokens before the agent even reads the user's request. The fix is generating a filesystem tree where each MCP tool becomes a TypeScript file with typed interfaces. The agent discovers tools by listing directories and reading only what it needs — the same [[progressive disclosure filters force agent selectivity over what enters context|progressive disclosure]] pattern that works for agent memory, now applied to tool discovery.

Intermediate results are the second token drain. In a standard tool-calling loop, every result passes through the model context. A two-hour meeting transcript gets loaded into context from Google Drive, then the model writes it back out to push it into Salesforce — doubling the token cost for a pure data-transfer operation. With code execution, the transcript flows through the execution environment as a variable: `const transcript = await gdrive.getDocument(...)` then `await salesforce.updateRecord({data: {Notes: transcript}})`. The model never sees the content. This directly addresses the [[context tax compounds through cache misses bloated tools and unbudgeted output tokens|context tax]] problem at the architectural level rather than through optimization tweaks.

The privacy benefit is underappreciated. When data flows through code execution rather than the model context, intermediate results stay in the sandbox by default. The MCP client can also tokenize PII automatically — replacing emails with `[EMAIL_1]` before the model sees them, then untokenizing on the way back out to the destination tool. This makes privacy a property of the architecture, not a prompt instruction.

State persistence through filesystem access enables agents to save intermediate results and resume work across executions. More interestingly, agents can save their own working code as reusable functions — essentially building [[skill workflows|skills]] from experience. The article explicitly connects this to Claude's Skills concept: adding a SKILL.md to saved functions creates a structured skill the agent can reference later. This is the same pattern as [[skill graphs outperform single skill files by letting agents traverse linked domain knowledge on demand|skill graphs]] but emerging organically from the agent's own work rather than being pre-authored.

Control flow in code is dramatically more efficient than chaining tool calls through the model. A polling loop that checks Slack every 5 seconds for a deployment notification becomes a simple `while` loop in TypeScript instead of repeated model invocations. Each iteration that would normally require a full model round-trip (time to first token, reasoning, tool call generation) becomes a millisecond-level code execution. This compounds: complex workflows with conditionals, loops, and error handling that might take 20+ model turns collapse into a single code block.

Cloudflare independently reached the same conclusion, calling this pattern "Code Mode." The convergence suggests this is becoming the standard architecture for production MCP deployments — code execution as the default, direct tool calling as the fallback for simple single-tool operations.

The tradeoff is real: code execution requires a secure sandbox with resource limits and monitoring. The article explicitly notes this operational overhead should be weighed against the token savings. For agents that only use a few tools, direct calling is simpler. The break-even point is somewhere around the complexity where intermediate results start flowing between tools.

## External Resources

- [Model Context Protocol](https://modelcontextprotocol.io/) — open standard for connecting AI agents to external systems
- [MCP Community](https://modelcontextprotocol.io/community/communication) — community hub for sharing MCP implementations
- [MCP SDKs](https://modelcontextprotocol.io/docs/sdk) — official SDKs for all major programming languages
- [Claude Code Sandboxing](https://www.anthropic.com/engineering/claude-code-sandboxing) — Anthropic's approach to secure code execution environments
- [Claude Skills](https://docs.claude.com/en/docs/agents-and-tools/agent-skills/overview) — reusable instruction/script/resource folders for specialized agent tasks
- [Cloudflare Code Mode](https://blog.cloudflare.com/code-mode/) — Cloudflare's independent findings on code execution with MCP

## Original Content

*How the MCP client orchestrates tool calls and results through the model context window*
![[anthropic-mcp-code-001.png]]

> [!quote]- Source Material
> **Code execution with MCP: building more efficient AI agents** — Anthropic Engineering, by Adam Jones and Conor Kelly
>
> The Model Context Protocol (MCP) is an open standard for connecting AI agents to external systems. Since launching in November 2024, the community has built thousands of MCP servers, SDKs are available for all major languages, and the industry has adopted MCP as the de-facto standard for connecting agents to tools and data.
>
> Today developers routinely build agents with access to hundreds or thousands of tools across dozens of MCP servers. However, as the number of connected tools grows, loading all tool definitions upfront and passing intermediate results through the context window slows down agents and increases costs.
>
> **Excessive token consumption from tools makes agents less efficient**
>
> As MCP usage scales, two common patterns increase agent cost and latency:
>
> 1. Tool definitions overload the context window — Most MCP clients load all tool definitions upfront directly into context. These definitions occupy substantial space, increasing response time and costs. With thousands of tools, agents process hundreds of thousands of tokens before reading a request.
>
> 2. Intermediate tool results consume additional tokens — Every intermediate result must pass through the model. A meeting transcript flows through twice: once retrieved from Google Drive, once written to Salesforce. For a 2-hour meeting, that could mean 50,000 extra tokens. Larger documents may exceed context window limits entirely.
>
> **Code execution with MCP improves context efficiency**
>
> The solution: present MCP servers as code APIs rather than direct tool calls. Generate a file tree of all available tools from connected MCP servers:
>
> ```
> servers/
> ├── google-drive/
> │   ├── getDocument.ts
> │   └── index.ts
> ├── salesforce/
> │   ├── updateRecord.ts
> │   └── index.ts
> └── ...
> ```
>
> Each tool becomes a TypeScript file with typed interfaces. The agent discovers tools by exploring the filesystem: listing the `./servers/` directory, then reading specific tool files to understand each interface. This reduces token usage from 150,000 tokens to 2,000 tokens — a 98.7% saving.
>
> **Benefits of code execution with MCP:**
>
> - Progressive disclosure: Models navigate the filesystem to load tool definitions on-demand. A `search_tools` tool with detail-level parameters helps agents find and load only what's needed.
>
> - Context efficient tool results: Agents filter and transform results in code before returning them. Fetching 10,000 rows? Filter to 5 pending orders in the execution environment instead of loading all rows through context.
>
> - More powerful control flow: Loops, conditionals, and error handling use familiar code patterns rather than chaining individual tool calls. A Slack deployment notification poll becomes a simple while loop instead of repeated model invocations.
>
> - Privacy-preserving operations: Intermediate results stay in the execution environment by default. The MCP client can tokenize PII automatically — emails become `[EMAIL_1]` before reaching the model, then untokenize when flowing to destination tools.
>
> - State persistence and skills: Filesystem access lets agents save intermediate results and resume work. Agents can also persist working code as reusable functions, building a toolbox of higher-level capabilities over time. Adding a SKILL.md to saved functions creates structured skills that models can reference.
>
> Note that code execution introduces its own complexity. Running agent-generated code requires a secure execution environment with appropriate sandboxing, resource limits, and monitoring. The benefits should be weighed against these implementation costs.
>
> **Summary**
>
> MCP provides a foundational protocol for agents to connect to many tools and systems. However, once too many servers are connected, tool definitions and results can consume excessive tokens. Code execution applies established software engineering patterns to agents, letting them use familiar programming constructs to interact with MCP servers more efficiently.
>
> [Original article](https://www.anthropic.com/engineering/code-execution-with-mcp)
