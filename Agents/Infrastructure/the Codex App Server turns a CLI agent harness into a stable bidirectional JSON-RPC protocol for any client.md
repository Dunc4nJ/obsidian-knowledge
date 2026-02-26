---
created: 2026-02-26
description: OpenAI's Codex App Server exposes the core agent loop as a bidirectional JSON-RPC protocol over stdio, enabling IDE integrations, web runtimes, and third-party clients to embed the same harness without reimplementing agent logic.
source: https://openai.com/index/unlocking-the-codex-harness/
type: learning
---

## Key Takeaways

The Codex App Server emerged organically from the need to reuse the same agent harness across the TUI, VS Code extension, and desktop app. Rather than maintaining separate agent implementations per surface, OpenAI extracted a [[agents need a database because stateless reasoning cores require stateful storage|stable protocol layer]] that any client can talk to — a pattern directly relevant to how we think about agent infrastructure.

The protocol uses three nested primitives — Items, Turns, and Threads — that map cleanly to the lifecycle of agent work. Items are atomic units (messages, tool calls, diffs) with explicit `started`/`delta`/`completed` events, Turns group items under a single user request, and Threads persist the full conversation. This layered decomposition is what makes streaming UIs possible without custom logic per surface.

The bidirectional nature of the protocol is key: the server can pause a turn and request client approval before executing a tool (e.g., "do you want to run `pnpm test`?"). This keeps the human in the loop at the right moments without blocking the entire agent loop, echoing patterns from [[MCP Best Practices|MCP design]] where tool execution requires explicit consent.

They tried MCP first for the VS Code integration but found it awkward — MCP's request/response semantics didn't map well to the streaming, multi-step nature of an agent loop. The custom JSON-RPC protocol let them model richer interactions (streaming deltas, approval flows, diff artifacts) that MCP's tool-call model couldn't express naturally.

The "Codex core" library (written in Rust) contains all agent logic and can be spun up as a runtime for individual threads. The App Server wraps this with a thread manager and message processor, translating JSON-RPC into core operations and core events back into stable, UI-ready notifications. Client bindings exist in Go, Python, TypeScript, Swift, and Kotlin.

Integration patterns vary by surface: local apps bundle the binary and pin versions, web runtime runs the App Server in containers with HTTP/SSE bridging to the browser, and the TUI is being refactored from a native in-process client to an App Server client — proving the protocol's generality. Third parties like JetBrains and Xcode decouple their release cycles by pointing to newer server binaries without client updates.

Alternative integration methods include [[MCP Best Practices|MCP server mode]] (`codex mcp-server`), exec mode for CI pipelines, and a TypeScript SDK — each with different tradeoffs between richness and simplicity.

## External Resources

- [Codex App Server source (Rust)](https://github.com/openai/codex/blob/main/codex-rs/app-server/README.md) — implementation and protocol docs
- [Codex core library](https://github.com/openai/codex/tree/main/codex-rs/core) — the agent loop and runtime
- [Codex MCP server guide](https://developers.openai.com/codex/guides/agents-sdk/) — using Codex as an MCP tool
- [OpenAI Agents SDK (JS)](https://openai.github.io/openai-agents-js/) — MCP client integration
- [AgentSkills.io](https://agentskills.io/home) — emerging standards for agent capabilities
- [Previous post: Unrolling the Codex agent loop](https://openai.com/index/unrolling-the-codex-agent-loop/) — companion article on the core loop

## Diagrams

*App Server process flow: client → stdio reader → message processor → thread manager → core threads*
![[openai-codex-harness-001.svg]]

*Initialization handshake between client and server*
![[openai-codex-harness-002.svg]]

*Thread and turn lifecycle: creating threads, starting turns, emitting items*
![[openai-codex-harness-003.svg]]

*Tool execution with optional approval flow*
![[openai-codex-harness-004.svg]]

*VS Code permission prompt for tool execution*
![[openai-codex-harness-005.png]]

*Streaming agent message flow with delta events*
![[openai-codex-harness-006.svg]]

*All Codex clients integrated via the App Server*
![[openai-codex-harness-007.svg]]

*Codex integration running in VS Code*
![[openai-codex-harness-008.png]]

*Codex web interface showing code diffs*
![[openai-codex-harness-009.png]]

*Codex CLI terminal interface*
![[openai-codex-harness-010.png]]

## Original Content

> [!quote]- Source Material
> 
> [Unlocking the Codex harness: how we built the App Server](https://openai.com/index/unlocking-the-codex-harness/) — OpenAI, 2026
> 
> The Codex App Server started as a practical reuse mechanism: the VS Code extension needed to drive the same agent loop as the TUI without reimplementing it. After experimenting with MCP (which proved awkward for streaming agent interactions), the team built a JSON-RPC protocol over stdio that mirrored the TUI loop.
> 
> The architecture has four components: stdio reader, Codex message processor, thread manager, and core threads. One client request generates many event updates — this granularity enables rich streaming UIs. The protocol is fully bidirectional: the server can initiate approval requests that pause the turn until the client responds.
> 
> Three conversation primitives define the protocol: Items (atomic I/O units with started/delta/completed lifecycle), Turns (one unit of agent work per user input), and Threads (durable containers for ongoing sessions with persistence and reconnection).
> 
> Transport is JSON-RPC over stdio (JSONL). Client bindings exist in Go, Python, TypeScript, Swift, and Kotlin. Type definitions can be generated from the Rust protocol via `codex app-server generate-ts` or `codex app-server generate-json-schema`.
> 
> Three deployment patterns: (1) Local apps bundle platform-specific binaries pinned to tested versions; (2) Web runtime runs App Server in containers with HTTP/SSE bridge; (3) TUI being refactored from native in-process to App Server client.
> 
> Alternative integration methods: MCP server mode (`codex mcp-server`), portable agent protocols, exec mode for CI, and TypeScript SDK.
