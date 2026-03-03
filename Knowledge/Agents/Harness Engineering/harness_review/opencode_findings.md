# opencode Findings (Deep Dive)

## Scope and Method

This document synthesizes a deep exploration of the `opencode` repository at `/data/projects/cubex/opencode/`. The repository is a TypeScript/Bun monorepo implementing a CLI-first coding agent with a client/server architecture, TUI built on SolidJS, and extensive provider/tool support.

Research method:
- Three parallel exploration agents launched with distinct focus areas:
  - **Agent A**: Core execution architecture — agent definition, session management, event bus, provider abstraction, server architecture, permissions, worktrees, question system, sharing, LLM streaming
  - **Agent B**: Tools and intelligence layer — tool system, file operations, shell execution, LSP integration, MCP support, patch/editing system, snapshot/checkpoint, skill system, project detection
  - **Agent C**: Infrastructure and extensibility — configuration system, storage/database, plugin system, CLI/TUI architecture, PTY management, IDE integration, auth, installation, feature flags, ID generation
- Every module directory in `packages/opencode/src/` (40+ directories) was explored with key files read completely
- Cross-referenced against existing `agno_findings.md`, `deepagents_findings.md`, and `letta-code_findings.md` to identify genuinely novel contributions

Primary sources reviewed:
- `README.md`, `AGENTS.md`, `CONTRIBUTING.md`
- `packages/opencode/src/index.ts` (6.4 KB) — CLI entry point
- `packages/opencode/src/session/` — all files (~150 KB total): `index.ts` (26 KB), `message-v2.ts` (27 KB), `prompt.ts` (65 KB), `processor.ts` (16 KB), `compaction.ts` (8.2 KB), `llm.ts` (9 KB)
- `packages/opencode/src/provider/` — all files (~78 KB): `provider.ts` (47 KB), `transform.ts` (31 KB)
- `packages/opencode/src/tool/` — all files (~50 KB): 24 tool implementations
- `packages/opencode/src/server/server.ts` (20 KB)
- `packages/opencode/src/lsp/server.ts` (75.8 KB), `index.ts` (485 lines)
- `packages/opencode/src/mcp/index.ts` (937 lines)
- `packages/opencode/src/config/config.ts` (62.3 KB)
- `packages/opencode/src/storage/db.ts` (6.7 KB)
- `packages/opencode/src/snapshot/index.ts` (298 lines)
- `packages/opencode/src/patch/index.ts` (680 lines)
- `packages/opencode/src/plugin/index.ts` (143 lines)
- `packages/opencode/src/permission/next.ts` (15 KB)
- `packages/opencode/src/pty/index.ts` (324 lines)
- `packages/opencode/src/worktree/index.ts` (19 KB)
- `packages/opencode/src/bus/` (3.6 KB)
- `packages/opencode/src/cli/cmd/tui/app.tsx` (25 KB)
- `packages/plugin/src/index.ts` — plugin SDK

## README Alignment: What Is Unique About This Project

The README positions OpenCode as "the open source AI coding agent" — a provider-agnostic, TUI-focused alternative to Claude Code with a client/server architecture.

1. **"100% open source, not coupled to any provider"** — Verified. `packages/opencode/src/provider/provider.ts` (~47 KB) implements a unified abstraction over 30+ LLM providers via the AI SDK, with per-provider custom loaders, environment variable substitution for API keys, and model resolution from models.dev. The BUNDLED_PROVIDERS map at `provider.ts` registers providers from `@ai-sdk/anthropic`, `@ai-sdk/openai`, `@ai-sdk/google`, `@ai-sdk/azure`, `@ai-sdk/amazon-bedrock`, `@ai-sdk/groq`, `@ai-sdk/mistral`, and 20+ more.

2. **"Out-of-the-box LSP support"** — Verified. `packages/opencode/src/lsp/server.ts` (75.8 KB) implements automatic LSP client management with built-in servers for TypeScript (tsserver), Python (pyright/ty), Deno, Go (gopls), Rust (rust-analyzer), Zig (zls), and support for custom servers via config. The LSP tool (`src/tool/lsp.ts`) exposes goToDefinition, findReferences, hover, documentSymbol, workspaceSymbol, call hierarchy, and diagnostics to the agent.

3. **"A client/server architecture"** — Verified. `packages/opencode/src/server/server.ts` (~20 KB) implements a Hono-based HTTP server with 12 route groups (session, project, PTY, MCP, file, config, permission, question, provider, TUI, global). Clients (CLI, web, desktop, IDE) connect via HTTP/SSE/WebSocket. The server manages all state, LLM calls, and tool execution. Desktop app wraps the web UI via Tauri (`packages/desktop/`).

4. **"Focus on TUI"** — Verified. `packages/opencode/src/cli/cmd/tui/app.tsx` (25 KB) implements the terminal UI using SolidJS + opentui (a custom terminal rendering framework). Components include dialogs for model selection, MCP status, themes, agents, session lists, and commands. Worker-based architecture with RPC communication between UI thread and server.

5. **"Built by neovim users and creators of terminal.shop"** — Reflected in the codebase through deep terminal integration: PTY management (`src/pty/`, 324 lines) with ring buffer streaming over WebSocket, automatic terminal background color detection, Tab-based agent switching, and rich TUI dialog system.

OpenCode's genuine identity is a **server-first, provider-agnostic coding agent** that separates the intelligence layer (server) from the presentation layer (TUI/web/desktop/IDE clients). The client/server split enables remote operation, multi-client attachment, and a clean separation of concerns. The built-in LSP integration and provider breadth (30+ providers) are its strongest technical differentiators.

## Architecture Overview

OpenCode uses a monorepo with 15+ packages, centered on `packages/opencode/` which contains the core agent logic, HTTP server, and CLI/TUI. The architecture is fundamentally server-first: the server manages sessions, runs LLM calls, executes tools, and handles permissions, while clients (TUI, web, desktop) consume events via HTTP/SSE/WebSocket. Sessions are persisted to SQLite via Drizzle ORM, with a rich message model supporting multiple part types (text, reasoning, tool calls, snapshots, patches, files). An event bus provides reactive communication between subsystems.

Module/directory map:
```
packages/opencode/src/
├── agent/        — Agent definitions (build, plan, general, explore, compaction)
├── session/      — Session lifecycle, message model, prompt loop, compaction, LLM streaming
├── provider/     — 30+ LLM provider abstraction via AI SDK
├── server/       — Hono HTTP server with 12 route groups
├── tool/         — 24 built-in tools + plugin/MCP tool loading
├── lsp/          — Language Server Protocol client management (7 built-in servers)
├── mcp/          — Model Context Protocol with OAuth support
├── config/       — Hierarchical JSONC config with env/file interpolation
├── storage/      — SQLite/Drizzle ORM persistence
├── permission/   — Rule-based permission system with wildcard patterns
├── snapshot/     — Git-backed workspace snapshots
├── patch/        — Custom patch format with 4-pass line matching
├── plugin/       — Plugin loading (internal, builtin npm, user npm)
├── skill/        — Multi-source skill discovery and loading
├── bus/          — Event pub/sub system
├── cli/          — CLI commands + SolidJS TUI
├── pty/          — PTY management with ring buffer streaming
├── worktree/     — Git worktree creation/management
├── file/         — File operations with safety checks
├── shell/        — Shell detection and process management
├── project/      — Project/instance detection and state management
├── command/      — Slash command system
├── question/     — User interaction dialogs
├── share/        — Real-time session sharing
├── id/           — Monotonic ID generation with prefix scheme
├── flag/         — 90+ feature flags with dynamic evaluation
├── env/          — Per-instance environment isolation
├── global/       — XDG-compliant path management
├── auth/         — OAuth/API key storage (0o600 permissions)
├── ide/          — IDE extension installation
├── installation/ — Multi-method install/update system
├── bun/          — Bun package manager integration
├── format/       — Auto-formatter detection and execution
└── control-plane/ — Enterprise workspace management
```

Key abstractions: `Session` is the central entity with `MessageV2` containing typed `Part`s. `Provider.Model` wraps LLM capabilities with per-token cost tracking. `Tool.define()` creates type-safe tools with Zod validation. `Instance` provides per-directory state with lifecycle management. `Bus` enables reactive event-driven communication across all subsystems.

## Feature Analysis

### 1. Client/Server Architecture (`packages/opencode/src/server/`)

**What it is**: A Hono-based HTTP server that separates the agent intelligence layer from the presentation layer, allowing multiple clients to attach to the same agent process.

**Key files**: `server/server.ts` (~20 KB), 12 route modules

**How it works**: The server starts on `localhost:4096` (configurable) and exposes a REST+SSE+WebSocket API with 12 route groups covering sessions, projects, PTY, MCP, files, config, permissions, questions, providers, TUI, and global state. All LLM calls, tool execution, and state management happen server-side. Clients are stateless and can reconnect at any time. Authentication is via optional HTTP basic auth. CORS supports localhost, Tauri, and opencode.ai origins. mDNS enables zero-config discovery. An OpenAPI spec is auto-generated via hono-openapi.

**Notable details**: The `Instance.provide()` middleware creates per-request context with the working directory and bootstrap configuration. Route handlers return typed Zod schemas for automatic validation. SSE streams push session events (message updates, permission requests, status changes) to connected clients. The server supports proxy middleware for the control plane.

### 2. Session Model and Persistence (`packages/opencode/src/session/`)

**What it is**: A rich session model with typed message parts, SQLite persistence via Drizzle ORM, and streaming delta updates.

**Key files**: `session/index.ts` (26 KB), `session/message-v2.ts` (27 KB), `session/session.sql.ts` (2.8 KB)

**How it works**: Sessions contain messages (user or assistant), each with typed parts: TextPart, ReasoningPart, ToolPart (with state machine: pending→running→completed/error), SnapshotPart, PatchPart, FilePart, CompactionPart, SubtaskPart, and AgentPart. The schema uses three SQL tables (SessionTable, MessageTable, PartTable) with the part content stored as type-discriminated JSON. Part updates support streaming deltas via `updatePartDelta()` which publishes granular bus events for real-time client updates. Sessions support forking (`Session.fork()`), sharing, diff tracking, and revert to snapshots.

**Notable details**: Each assistant message tracks token counts (input, output, reasoning, cache read/write), cost, model/provider IDs, and a finish reason. The `summary` field on sessions tracks aggregate additions/deletions/files with diffs. The `slug` field uses ULID for URL-friendly session identifiers. Legacy JSON storage migrates automatically to SQLite on first boot.

### 3. Provider Abstraction and Model Resolution (`packages/opencode/src/provider/`)

**What it is**: A unified LLM provider interface supporting 30+ providers with per-provider custom loading, model capabilities detection, and cost tracking.

**Key files**: `provider/provider.ts` (47 KB), `provider/transform.ts` (31 KB), `provider/models.ts` (3.8 KB)

**How it works**: The `BUNDLED_PROVIDERS` map registers 27+ AI SDK packages. `CUSTOM_LOADERS` handle provider-specific initialization (e.g., OpenAI uses `.responses()` API, Amazon Bedrock uses regional prefixing, GitHub Copilot requires OAuth). Models are resolved from a bundled `models.dev` dataset with capabilities (images, video, audio, PDF, tools, reasoning, temperature), cost per token, and context/output limits. The `ProviderTransform` namespace handles message normalization (Anthropic empty-message filtering, Claude tool-call ID shortening, Gemini thinking signature injection) and output token capping.

**Notable details**: Environment variable substitution with `${VAR}` syntax in provider config. Model suggestions on `ModelNotFoundError` (fuzzy matching). Dynamic authorization via plugin hooks. Cost tracked with Decimal.js precision. Provider options support OpenTelemetry custom headers. LiteLLM proxy compatibility (injects dummy tool when model requires tools).

### 4. Prompt Loop and Processor (`packages/opencode/src/session/prompt.ts`, `processor.ts`)

**What it is**: The core agent execution loop that orchestrates LLM streaming, tool execution, compaction, and subtask delegation.

**Key files**: `session/prompt.ts` (65 KB), `session/processor.ts` (16 KB)

**How it works**: `SessionPrompt.loop()` runs the main agent loop. Each iteration: (1) loads messages and finds the last user/assistant/finished messages, (2) checks for pending subtasks or compaction requests, (3) resolves the model, (4) creates an assistant message, (5) calls `SessionProcessor.process()` which streams from `LLM.stream()`, capturing reasoning events (reasoning-start/delta/end), text deltas, tool calls (with streaming input), and tool results. Tool execution goes through the permission system, then the tool's `execute()` function. The processor tracks a doom loop counter (>3 retries = block). The loop continues until `end_turn` or explicit stop.

**Notable details**: System prompts are split into two parts for prompt caching efficiency (header + rest). The processor takes filesystem snapshots before tool execution via `Snapshot.track()`. `insertReminders()` injects contextual system reminders mid-loop. Structured output support adds a synthetic `StructuredOutput` tool. Plugin hooks fire at `tool.execute.before` and `tool.execute.after`. Compaction auto-triggers when token usage exceeds the model's input limit minus a 20K buffer.

### 5. Compaction System (`packages/opencode/src/session/compaction.ts`)

**What it is**: A two-phase context management system that prunes old tool outputs and generates continuation summaries when context windows fill up.

**Key files**: `session/compaction.ts` (8.2 KB)

**How it works**: Phase 1 is **pruning**: walks backwards through message parts, protecting the most recent 40K tokens of tool outputs, then marks older tool outputs as "compacted" (erasing their content but keeping metadata). Phase 2 is **summarization**: spawns a dedicated "compaction" agent that reads the full conversation and generates a structured summary following a template (Goal, Instructions, Discoveries, Accomplished, Relevant files/directories). The summary becomes a new assistant message with `summary: true`, and all messages before it are filtered out on subsequent reads via `MessageV2.filterCompacted()`. If auto-triggered, a synthetic "Continue" user message is injected to keep the loop going.

**Notable details**: Overflow detection uses the model's context limit minus a configurable reserved buffer (default 20K or the model's max output tokens, whichever is smaller). The `PRUNE_PROTECT` threshold (40K tokens) ensures recent tool outputs survive pruning. The "skill" tool is protected from pruning (its outputs tend to be needed throughout the session). Plugin hook `experimental.session.compacting` allows custom compaction prompts.

### 6. Tool System (`packages/opencode/src/tool/`)

**What it is**: A type-safe, extensible tool registry with Zod validation, automatic output truncation, permission integration, and plugin/MCP tool loading.

**Key files**: `tool/tool.ts` (core definition), `tool/registry.ts` (173 lines), 22 tool implementation files (~50 KB total)

**How it works**: `Tool.define()` wraps tool initialization in a lazy pattern. Each tool provides a Zod parameter schema, description, and `execute()` function receiving a `Tool.Context` with session/message IDs, abort signal, message history, and `ctx.ask()` for permission requests. Output is auto-truncated to 2000 lines / 50KB. The registry loads tools from three sources: built-in (24 tools), plugin tools (`.opencode/{tool,tools}/*.{js,ts}`), and MCP tools. Model-aware selection serves `apply_patch` to GPT models and `edit` to others.

**Notable details**: The bash tool uses tree-sitter to parse commands and extract file paths for permission checking. The edit tool uses file-time locking to prevent concurrent edits and integrates LSP diagnostics post-edit. The read tool detects 1000+ file types (binary, image, text) and auto-base64-encodes images. Output truncation uses head/tail strategies with file-based overflow that creates a URL for browser viewing.

### 7. Patch/Edit System (`packages/opencode/src/patch/`)

**What it is**: A custom patch format with a 4-pass line matching algorithm that handles Unicode normalization, heredoc stripping, and context-based seeking.

**Key files**: `patch/index.ts` (680 lines)

**How it works**: The patch format supports Add/Update/Delete/Move file operations. For updates, a 4-pass line matching algorithm tries: (1) exact binary match, (2) trailing whitespace normalized, (3) both-ends whitespace normalized, (4) Unicode normalized (curly quotes→ASCII, ellipsis→"...", en/em dashes→hyphens). Context lines anchor the match position. Replacements are sorted by index and applied in reverse order to prevent offset shifting. The system detects heredoc patterns (`cat <<'EOF'...EOF`) and strips them. End-of-file anchoring matches patterns from the file end.

**Notable details**: Unicode normalization handles a specific pain point: LLMs often output "smart" quotes and typographic characters that don't match the source file. The fallback passes prevent edit failures from whitespace and encoding differences. File move/rename is a first-class operation in the patch format.

### 8. LSP Integration (`packages/opencode/src/lsp/`)

**What it is**: Automatic Language Server Protocol client management with built-in support for 7+ language servers, client pooling, and diagnostics aggregation.

**Key files**: `lsp/server.ts` (75.8 KB), `lsp/index.ts` (485 lines), `lsp/client.ts`

**How it works**: Built-in server definitions for TypeScript (tsserver), Python (pyright, experimental ty), Deno, Go (gopls), Rust (rust-analyzer), Zig (zls), and C/C++ (clangd). Each server defines a `root()` function that walks up from the file to find the project root (e.g., nearest `tsconfig.json` for TypeScript, `pyproject.toml` for Python). Clients are pooled per root+server combo and lazily spawned on first file access. The LSP tool exposes 9 operations to the agent: goToDefinition, findReferences, hover, documentSymbol, workspaceSymbol, goToImplementation, prepareCallHierarchy, incomingCalls, outgoingCalls. Diagnostics are aggregated across all clients and published via bus events.

**Notable details**: Root functions support exclusion patterns (Deno excludes TypeScript server if `deno.json` is present). Failed servers are tracked to avoid re-spawning. `LSP.touchFile()` opens files in the language server and waits for diagnostics with a timeout. Custom servers can be added via config with command, env, and initialization options. The system is behind the `OPENCODE_EXPERIMENTAL_LSP` feature flag.

### 9. Snapshot/Checkpoint System (`packages/opencode/src/snapshot/`)

**What it is**: Git-backed workspace snapshots that capture filesystem state without modifying the main repository.

**Key files**: `snapshot/index.ts` (298 lines)

**How it works**: Uses a separate git directory at `.opencode/snapshot/{project-id}` to track workspace state. `track()` runs `git write-tree` to create an immutable tree hash without creating commits (lighter weight). `patch(hash)` shows files changed since a snapshot. `diff(hash)` generates unified diffs. `restore(snapshot)` resets the worktree to a previous state. `diffFull(from, to)` provides structured diffs with additions/deletions/modifications. Respects `.gitignore` and `.ignore` files. An hourly scheduler runs `git gc --prune=7.days` to prevent unbounded growth.

**Notable details**: Using `git write-tree` instead of commits is a clever optimization — tree references are immutable and lightweight, avoiding the overhead of commit objects. The separate git directory ensures snapshots don't pollute the main repository's ref log or history. The processor takes snapshots before each tool execution, enabling fine-grained revert.

### 10. MCP Integration with OAuth (`packages/opencode/src/mcp/`)

**What it is**: Full Model Context Protocol support with both remote (HTTP/SSE with OAuth) and local (stdio) transports, including dynamic client registration and PKCE flow.

**Key files**: `mcp/index.ts` (937 lines)

**How it works**: Remote connections support HTTP/SSE transport with custom headers, timeouts, and OAuth. The OAuth implementation includes dynamic client registration (auto-discovery of client ID), PKCE flow with state validation for CSRF protection, and automatic browser opening (with graceful fallback for SSH/headless). MCP tools are converted to AI SDK `dynamicTool` objects with automatic JSON Schema→Zod conversion and tool name sanitization. The system tracks per-server status (connected, disabled, failed, needs_auth, needs_client_registration) and publishes events to the TUI. Tool list change notifications trigger automatic reconnection.

**Notable details**: Supports opencode CLI recursion (the CLI can connect to itself as an MCP server). Pending auth handling pauses tool execution until OAuth completes. Timeout inheritance from config allows per-server tuning.

### 11. Permission System (`packages/opencode/src/permission/`)

**What it is**: A rule-based permission system with wildcard pattern matching for tools and file paths, featuring ask/allow/deny/always semantics.

**Key files**: `permission/next.ts` (15 KB)

**How it works**: Rules specify `{permission, pattern, action}` where permission is a tool name (supports globs), pattern is a file path (supports globs), and action is "allow", "deny", or "ask". Evaluation uses last-match-wins with a default of "ask". `PermissionNext.ask()` publishes an `Event.Asked` bus event and blocks until a client replies with "once", "always", or "reject". "Always" decisions are persisted. Cascade rejections: rejecting one permission request rejects all pending requests for that session. Rules can come from agent config, session overrides, and user config, merged via `PermissionNext.merge()`.

**Notable details**: The `CorrectedError` class allows rejections with feedback messages that are sent back to the LLM (telling the agent why the tool call was denied). The `DeniedError` class handles automatic denials from config rules. `.env` files are always denied by default, but `.env.example` is allowed.

### 12. Event Bus (`packages/opencode/src/bus/`)

**What it is**: A lightweight typed event pub/sub system with Zod schema validation and instance-scoped lifecycle management.

**Key files**: `bus/bus-event.ts`, `bus/index.ts` (3.6 KB total)

**How it works**: Events are defined with `BusEvent.define(name, zodSchema)` which creates typed event definitions. `Bus.publish()` broadcasts events to subscribers. `Bus.subscribe()` registers typed handlers. `Bus.subscribeAll()` receives all events. Subscriptions are instance-scoped via `Instance.state()` and automatically cleaned up on instance disposal. Event types are used across all subsystems: session lifecycle, message updates, file edits, LSP diagnostics, MCP status, permission requests, worktree readiness, PTY lifecycle, and more.

**Notable details**: The bus is the glue between the server and clients — SSE/WebSocket streams are fed by bus subscriptions, so any subsystem change automatically propagates to all connected clients.

### 13. PTY System (`packages/opencode/src/pty/`)

**What it is**: Native pseudo-terminal management with ring buffer streaming over WebSocket, supporting multiple simultaneous clients.

**Key files**: `pty/index.ts` (324 lines)

**How it works**: Uses `bun-pty` for native terminal support. Each PTY session has a 2MB ring buffer with position tracking. WebSocket subscribers receive binary PTY output frames and JSON meta frames (cursor position, preceded by 0x00 byte). New clients receive partial buffer delivery from their read offset. Shell detection is automatic with locale handling. The `shell.env` plugin hook allows environment injection before PTY creation. Sessions go through a lifecycle: Created→Running→Exited→Deleted, with events published at each transition.

**Notable details**: The ring buffer pattern prevents unbounded memory growth while still allowing late-joining clients to see recent output. The binary/meta frame protocol is efficient — only cursor updates need JSON parsing. PTY sessions are exposed via the server API for remote terminal access.

### 14. Hierarchical Configuration (`packages/opencode/src/config/`)

**What it is**: A multi-layered JSONC configuration system with environment variable interpolation, file inclusion, and enterprise override support.

**Key files**: `config/config.ts` (62.3 KB), `config/paths.ts` (5 KB)

**How it works**: Config loads from four layers: system-managed (enterprise) → user global (`~/.config/opencode/`) → project local (`.opencode/`) → environment variable overrides. JSONC parsing supports comments, trailing commas, and multi-line values. Dynamic substitution handles `{env:VAR}` and `{file:path}` interpolation. Schema validation uses Zod with detailed error messages. Config is lazy-loaded and cached per instance.

**Notable details**: Project-level config can be disabled via the `OPENCODE_DISABLE_PROJECT_CONFIG` flag for security. Enterprise config provides a system-managed override layer for organizational policies.

### 15. ID Generation (`packages/opencode/src/id/`)

**What it is**: A monotonic, time-ordered ID generation scheme with type-safe prefixes and configurable sort direction.

**Key files**: `id/id.ts`

**How it works**: IDs follow the format `PREFIX_HHHHHHHHHHHHRRRRRRRRRRRRRR` — 3-char prefix (ses, msg, per, que, usr, prt, pty, tool, wrk), 12-char hex timestamp (6 bytes, big-endian), 14-char random base62. A monotonic counter prevents collisions within the same millisecond. `Identifier.ascending()` and `Identifier.descending()` produce IDs that sort in the desired direction (descending uses bit inversion). Total length: 26 characters.

**Notable details**: The timestamp component enables efficient range queries without secondary indexes. The prefix makes IDs self-documenting in logs and databases. The monotonic counter is critical for high-throughput tool execution where multiple parts are created within the same millisecond.

### 16. Plugin System (`packages/opencode/src/plugin/`, `packages/plugin/`)

**What it is**: A three-tier plugin loading system with hook-based extensibility for auth, tools, commands, permissions, environment, and experimental features.

**Key files**: `plugin/index.ts` (143 lines), `packages/plugin/src/index.ts`

**How it works**: Plugins load from three tiers: (1) internal (Codex, Copilot, GitLab auth), (2) builtin npm packages with version pinning, (3) user-specified npm packages or `file://` paths. Plugins implement hooks including: `auth` (authentication methods), `tool` (custom tools), `chat.message/params/headers` (LLM parameter modification), `shell.env` (environment injection), `permission.ask` (permission policy), and `experimental.session.compacting` (custom compaction). Missing npm plugins are auto-installed. Deduplication prevents double initialization of named/default exports.

**Notable details**: The plugin hook for `experimental.session.compacting` allows plugins to completely replace the compaction strategy. The `shell.env` hook enables plugins to inject environment variables into all shell executions. The `chat.headers` hook allows custom headers per LLM request.

### 17. Worktree Management (`packages/opencode/src/worktree/`)

**What it is**: Git worktree creation and lifecycle management with creative name generation and event-driven readiness signaling.

**Key files**: `worktree/index.ts` (19 KB)

**How it works**: `Worktree.create()` creates a new git worktree inside `.claude/worktrees/` (or configured location) with a new branch. Names are generated from adjective+noun combinations (24×24+ = 576+ possibilities) with collision retry. `Worktree.remove()` and `Worktree.reset()` handle cleanup. Bus events `Worktree.Event.Ready` and `Worktree.Event.Failed` signal lifecycle transitions.

**Notable details**: Supports an optional `startCommand` for post-creation setup (e.g., installing dependencies). Worktrees are used for isolation when running subtasks or experimental changes.

### 18. Skill System (`packages/opencode/src/skill/`)

**What it is**: Multi-source skill discovery and loading from local directories, project hierarchies, and remote URLs.

**Key files**: `skill/skill.ts` (189 lines), `skill/discovery.ts` (99 lines), `tool/skill.ts` (124 lines)

**How it works**: Skills load from multiple sources: global directories (`.claude/skills/`, `.agents/skills/`), project-level `.opencode/skill/` directories, config-driven `skills.paths` (absolute or `~/` relative), and remote URLs (`skills.urls` pointing to `index.json` files that list downloadable skills). Skills are SKILL.md files with frontmatter (name, description) and markdown content that becomes instructions. The skill tool is permission-aware and lists up to 10 bundled files. Skills are invokable as slash commands.

**Notable details**: Remote skill support with on-demand downloading and caching in `~/.opencode/cache/skills/` enables shared skill libraries. Project-level skills override global ones for customization.

### 19. File Operations with Safety (`packages/opencode/src/file/`)

**What it is**: Comprehensive file operations with path boundary checks, binary/image detection, git-aware diffing, and `.gitignore` respect.

**Key files**: `file/index.ts` (647 lines)

**How it works**: Pre-categorizes 1000+ file types by extension (binary, image, text, script). `File.read()` performs lexical path boundary checks to prevent symlink escapes. Images are automatically base64-encoded with MIME type detection. Text files include unified diffs from git showing uncommitted changes. `File.list()` respects `.gitignore` and `.ignore` files via ripgrep integration. `File.search()` provides fuzzy-sorted file search with preference for non-hidden files. File time locking prevents race conditions on concurrent edits.

**Notable details**: The `patch` field on read results automatically includes uncommitted changes from `git diff`, giving the agent immediate context about what's been modified without a separate tool call.

### 20. Session Sharing (`packages/opencode/src/share/`)

**What it is**: Real-time session sharing with debounced sync, secret-based authentication, and event-driven updates.

**Key files**: `share/share-next.ts` (6 KB)

**How it works**: `ShareNext.create()` posts to `/api/share` and stores the returned `{id, url, secret}` in the database. The system subscribes to bus events (Session.Updated, MessageV2.*, Session.Diff) and queues updates into a debounced (1-second) batch. `ShareNext.sync()` posts batched data types (session, message, part, session_diff, model) to `/api/share/{id}/sync`. `ShareNext.fullSync()` sends the entire session history on share creation.

**Notable details**: The debounced batch pattern is efficient for real-time sharing without overwhelming the endpoint. Secret-based auth means share URLs can be distributed without exposing the full API.

## What Our Harness Should Adopt From opencode

These are opencode's distinctive contributions — features that represent genuine innovations or unusually strong implementations that Cubex should adopt. Ranked by impact.

### 1. Client/Server Architecture with Multi-Client Support (HIGHEST)

**The idea**: Separate the agent's intelligence layer (session management, LLM calls, tool execution, permissions) from the presentation layer (TUI, web, desktop, IDE) via an HTTP/SSE/WebSocket API.

**Why this matters for Cubex**: This is the single most impactful architectural decision in opencode. A Rust CLI-first agent with a server mode enables: (1) remote operation — run the agent on a powerful machine, drive it from a phone or tablet, (2) multi-client attachment — TUI and web UI can view the same session simultaneously, (3) IDE integration without embedding — VS Code extension connects to the running server, (4) headless/CI mode — API calls drive the agent without a TUI, (5) state persistence across disconnects — the server keeps running even if the client drops. Without this, Cubex is limited to a single-process CLI that dies when the terminal closes.

**How it works** (language-agnostic pattern):

- **Server**: An HTTP framework (Hono in opencode, Axum for Rust) serves a REST+SSE API. Route groups cover: session CRUD, message streaming, tool execution, permission request/reply, PTY management, file operations, provider/model management, MCP coordination, config read/update, and global state. All LLM calls and tool execution happen server-side. Sessions are persisted to SQLite.

- **Event streaming**: The server maintains an event bus. Every subsystem (sessions, tools, permissions, LSP, MCP) publishes typed events. SSE endpoints stream filtered events to clients. Clients subscribe to session-scoped or global event streams.

- **Client pattern**: Clients are stateless HTTP consumers. They POST to create messages, GET to read state, and subscribe to SSE for real-time updates. Permission requests arrive as SSE events; clients POST replies. This means any client (TUI, web, mobile, IDE) implements the same thin protocol.

- **Auth**: Optional HTTP basic auth for the server. CORS whitelist for web clients. mDNS for zero-config local discovery (find running opencode instances on the network).

- **PTY forwarding**: Terminal sessions are managed server-side with ring buffers. Clients receive PTY output via WebSocket binary frames + JSON meta frames (cursor position). New clients receive buffered recent output.

- **API surface**: The server generates an OpenAPI spec from route definitions, enabling auto-generated SDKs for any language.

**Source**: `packages/opencode/src/server/server.ts` (~20 KB), route modules in `server/`, PTY in `pty/index.ts` (324 lines)

### 2. Built-in LSP Integration (VERY HIGH)

**The idea**: Automatically manage Language Server Protocol clients for 7+ languages, giving the agent access to go-to-definition, find-references, hover info, diagnostics, and call hierarchy — all without user configuration.

**Why this matters for Cubex**: LSP integration transforms the agent from "text manipulator that hopes edits are correct" to "IDE-aware developer that can verify edits, navigate code semantically, and understand project structure." After every edit, the agent can check diagnostics to catch errors immediately. When exploring unfamiliar code, it can use go-to-definition instead of grepping. No other agent harness in the research collection has this built-in. Without LSP, Cubex is limited to text-level understanding of code.

**How it works** (language-agnostic pattern):

- **Server registry**: A static registry maps language IDs to server configurations. Each entry specifies: `id` (server name), `extensions` (file extensions this server handles), `root()` function (finds project root by walking up from file looking for markers like `tsconfig.json`, `pyproject.toml`, `Cargo.toml`), and `spawn(root)` function (starts the server process with appropriate arguments).

- **Built-in servers**: TypeScript (tsserver with node_modules resolution), Python (pyright with experimental ty variant), Deno (auto-detected by presence of `deno.json`), Go (gopls), Rust (rust-analyzer), Zig (zls), C/C++ (clangd). Custom servers addable via config.

- **Client pooling**: Clients are spawned lazily per root+server combo. When a file is accessed, the system finds the appropriate server based on extension, determines the root via the `root()` function, and reuses or spawns a client. Failed clients are tracked to prevent re-spawning broken servers.

- **Root exclusion**: Root functions support exclusion patterns — e.g., TypeScript server excludes directories containing `deno.json` to avoid conflicts with the Deno server.

- **Operations exposed to agent**: goToDefinition, findReferences, hover, documentSymbol, workspaceSymbol, goToImplementation, prepareCallHierarchy, incomingCalls, outgoingCalls, diagnostics.

- **Diagnostics integration**: After file edits, `LSP.touchFile()` opens the file in the appropriate language server and waits for diagnostics with a configurable timeout. Diagnostics are aggregated across all clients, formatted as `ERROR [line:col] message`, and published via bus events.

- **Implementation for Rust**: Use `tower-lsp` or direct `lsp-types` with stdio transport. The server registry is a `Vec<ServerDef>` with trait-based root finding. Client pooling uses a `HashMap<(PathBuf, String), Client>`. Diagnostic aggregation uses channels.

**Source**: `packages/opencode/src/lsp/server.ts` (75.8 KB), `lsp/index.ts` (485 lines), `tool/lsp.ts` (97 lines)

### 3. Git-Backed Workspace Snapshots (HIGH)

**The idea**: Use a separate git directory (not the project's own `.git`) to create lightweight, immutable filesystem snapshots via `git write-tree`, enabling per-tool-call revert without polluting the project's git history.

**Why this matters for Cubex**: Agents make mistakes. The ability to snapshot the workspace before each tool execution and revert if something goes wrong is critical for safety. Other harnesses either don't snapshot or use commit-based approaches that modify the main git history. OpenCode's approach is zero-impact on the project (separate git dir, no commits, uses tree hashes) and lightweight (write-tree is faster than commit). Without this, reverting agent mistakes requires manual `git stash` or `git checkout` by the user.

**How it works** (language-agnostic pattern):

- **Setup**: Initialize a bare git directory at `.opencode/snapshot/{project-id}`. The working tree points to the project directory but the git database lives separately.

- **Snapshot**: Run `git write-tree` against the project directory using the snapshot git directory. This returns a tree hash — an immutable reference to the exact filesystem state. No commit object is created. The hash is stored as a `SnapshotPart` in the session message.

- **Diff**: `git diff-tree` between two tree hashes (or a tree hash and the current worktree) produces the list of changed files and their unified diffs.

- **Restore**: `git read-tree` + `git checkout-index` from the snapshot git directory resets specific files or the entire worktree to the snapshotted state.

- **Revert**: Fine-grained revert of individual files to a previous snapshot state using `git checkout-index` for specific paths.

- **Cleanup**: Hourly scheduler runs `git gc --prune=7.days` to prevent unbounded growth. Tree objects with no references are garbage collected.

- **Ignore respect**: Uses the project's `.gitignore` and `.ignore` files to exclude tracked-but-ignored files from snapshots.

- **Implementation for Rust**: Use `git2` crate with separate `Repository` pointing to the snapshot directory. `write_tree()` returns `Oid`. `diff_tree_to_tree()` for diffs. `checkout_tree()` for restore.

**Source**: `packages/opencode/src/snapshot/index.ts` (298 lines)

### 4. Patch Format with 4-Pass Unicode-Aware Line Matching (HIGH)

**The idea**: A custom patch format that handles the specific failure modes of LLM-generated code edits: Unicode character substitution (smart quotes, em dashes), whitespace differences, and heredoc formatting.

**Why this matters for Cubex**: LLMs frequently generate code with typographic characters that don't match the source file — curly quotes instead of straight quotes, em dashes instead of hyphens, Unicode ellipsis instead of "...". Standard diff/patch tools fail on these. OpenCode's 4-pass matching degrades gracefully: try exact match, then whitespace-normalized, then Unicode-normalized, preventing edit failures that frustrate users. This is a solved problem specific to agent harnesses that no general-purpose tool addresses.

**How it works** (language-agnostic pattern):

- **Patch format**: Operations include `Add File`, `Update File`, `Delete File`, `Move to` (rename). Updates use `@@ context @@` blocks with `-` (remove) and `+` (add) prefixes.

- **4-pass line matching**: For each context line:
  1. **Exact**: Binary equal comparison
  2. **Rstrip**: Trailing whitespace stripped before comparison
  3. **Trim**: Both leading and trailing whitespace stripped
  4. **Unicode normalized**: Replace curly quotes (U+2018/2019/201C/201D) with ASCII quotes, ellipsis (U+2026) with "...", en/em dashes (U+2013/2014) with "-"

- **Context-based seeking**: When a line match is ambiguous (appears multiple times), surrounding context lines disambiguate. Matches are scored by consecutive context agreement.

- **Heredoc stripping**: Detects `cat <<'EOF'...EOF` patterns (common in LLM output) and strips the heredoc wrapper, extracting only the content.

- **EOF anchoring**: If the pattern matches the end of the file, anchors from the bottom rather than searching from the top.

- **Application**: Replacements are sorted by file position and applied in reverse order (bottom-to-top) to prevent offset shifting.

- **Implementation for Rust**: The matching passes are trivial string operations. Unicode normalization uses a lookup table. The parser is a simple state machine over lines. Total implementation effort: ~400 lines of Rust.

**Source**: `packages/opencode/src/patch/index.ts` (680 lines)

### 5. Two-Phase Compaction with Tool Output Pruning (HIGH)

**The idea**: A two-phase context management strategy: first prune old tool outputs (cheap, no LLM call), then summarize the conversation (expensive, uses LLM) only when pruning isn't sufficient.

**Why this matters for Cubex**: Context window management is a day-one priority. OpenCode's approach is smarter than a single summarization pass because tool outputs are the largest context consumers and pruning them is free. The 40K protected window ensures recent tool results survive while old ones are evicted. The structured summary template (Goal/Instructions/Discoveries/Accomplished/Files) produces better continuation quality than free-form summaries. Without this two-phase approach, Cubex either burns tokens on premature summarization or hits context limits with stale tool outputs.

**How it works** (language-agnostic pattern):

- **Phase 1 — Prune**: Walk backwards through message parts. Skip the two most recent user turns (always fresh). Count tokens in completed tool outputs. Once past the 40K "protect" threshold, mark remaining tool outputs as "compacted" (erase output content, keep metadata with `time.compacted` timestamp). Skip "skill" tool outputs (they're needed throughout). Stop if total pruned exceeds 20K tokens (minimum pruning threshold) or if a previous summary boundary is hit.

- **Phase 2 — Summarize**: Triggered when token usage exceeds `model.limit.input - reserved_buffer`. Creates a "compaction" agent message. Sends all messages to the LLM with a structured summary prompt. The summary becomes an assistant message with `summary: true`. On subsequent reads, `filterCompacted()` skips all messages before the most recent summary, prepending the summary as context.

- **Overflow detection**: Uses the model's input token limit (not context limit) minus a configurable reserved buffer (default 20K or max output tokens, whichever is smaller). Considers total tokens from the last assistant response (input + output + cache read/write).

- **Summary template**: Goal → Instructions → Discoveries → Accomplished → Relevant files/directories. This structured format ensures the continuation agent has actionable context rather than a narrative summary.

- **Auto-continue**: After auto-triggered compaction, injects a synthetic "Continue if you have next steps" user message to keep the agent loop running without user intervention.

**Source**: `packages/opencode/src/session/compaction.ts` (8.2 KB)

### 6. Typed Event Bus with Instance-Scoped Lifecycle (MEDIUM-HIGH)

**The idea**: A lightweight event bus where events are defined with Zod schemas (ensuring type safety), subscriptions are automatically scoped to instance lifecycle (preventing leaks), and wildcard subscriptions enable cross-cutting concerns like logging and SSE streaming.

**Why this matters for Cubex**: Every subsystem in an agent harness needs to communicate: sessions need to notify the UI, tool execution needs to trigger snapshots, permission requests need to reach clients, LSP diagnostics need to update displays. A typed event bus with instance lifecycle management prevents both the boilerplate of manual wiring and the bugs of leaked subscriptions. The pattern is particularly valuable for the client/server architecture where SSE streams need to forward all events to connected clients.

**How it works** (language-agnostic pattern):

- **Event definition**: `BusEvent.define("event.name", ZodSchema)` creates a typed event definition. The Zod schema validates payloads at publish time.

- **Publish/subscribe**: `Bus.publish(EventDef, payload)` broadcasts to all subscribers of that event type. `Bus.subscribe(EventDef, handler)` registers a typed handler. `Bus.subscribeAll(handler)` receives all events (for SSE forwarding, logging).

- **Instance scoping**: Subscriptions are stored in `Instance.state()`. When an instance is disposed (server shutdown, session end), all subscriptions are automatically cleaned up.

- **Event types in use**: Session created/updated/deleted/error, message created/updated (with delta support), part created/updated/delta, file edited, LSP diagnostics updated, MCP tools changed, permission asked/replied, worktree ready/failed, PTY created/updated/exited/deleted, compaction completed, share synced.

- **Implementation for Rust**: Use `tokio::sync::broadcast` or a custom `HashMap<TypeId, Vec<Sender>>`. Instance scoping via `Arc<Mutex<HashMap>>` with `Drop` cleanup. Zod validation becomes `serde` deserialization.

**Source**: `packages/opencode/src/bus/` (3.6 KB)

### 7. PTY Ring Buffer with WebSocket Streaming (MEDIUM-HIGH)

**The idea**: Manage pseudo-terminals server-side with a fixed-size ring buffer, streaming output to multiple clients via WebSocket with a binary/meta frame protocol and late-join buffer catch-up.

**Why this matters for Cubex**: A coding agent needs to run shell commands and show their output in real-time. The ring buffer prevents unbounded memory growth for long-running commands. The WebSocket protocol enables remote terminal access (key for the client/server architecture). Late-join catch-up means a client that reconnects or a second client that attaches sees recent output without replaying the entire history. Without PTY management, Cubex is limited to capturing stdout/stderr as text, losing interactive terminal features (colors, cursor movement, progress bars).

**How it works** (language-agnostic pattern):

- **Session management**: PTY sessions track a process handle, 2MB ring buffer, read cursor positions per subscriber, and lifecycle state (Running→Exited→Deleted).

- **Ring buffer**: A circular byte buffer with write position tracking. New data overwrites oldest data when full. Each subscriber maintains an independent read cursor.

- **WebSocket protocol**: Two frame types — binary frames contain raw PTY output, meta frames start with 0x00 byte followed by JSON cursor position data. Subscribers receive only data newer than their read cursor.

- **Late-join**: When a new client subscribes, the ring buffer delivers all data from position 0 (or the oldest available position if the buffer has wrapped), allowing the client to reconstruct the current terminal state.

- **Shell detection**: Auto-detects the user's shell from `$SHELL` with blacklist (fish, nu — known compatibility issues), Git Bash fallback on Windows.

- **Environment injection**: The `shell.env` plugin hook allows plugins to inject environment variables (e.g., API keys, PATH modifications) before PTY creation.

- **Implementation for Rust**: Use `portable-pty` crate for PTY management. Ring buffer is a `Vec<u8>` with modular indexing. WebSocket via `tokio-tungstenite`. The 2MB fixed size is a good default for terminal output.

**Source**: `packages/opencode/src/pty/index.ts` (324 lines)

### 8. Permission System with Cascade Rejection and Corrective Feedback (MEDIUM)

**The idea**: When a user rejects a permission request, reject all pending requests for that session (cascade) and optionally send a text message back to the LLM explaining why the action was denied (corrective feedback).

**Why this matters for Cubex**: Without cascade rejection, the user faces a "whack-a-mole" experience when the agent issues multiple related tool calls — rejecting one still shows dialogs for the others. Without corrective feedback, the agent doesn't learn from rejections and may retry the same action. The `CorrectedError` pattern is particularly valuable: the user can reject an edit AND tell the agent "use the other file instead", which the agent receives as a tool error with a human message. This turns permission denial into a steering mechanism.

**How it works** (language-agnostic pattern):

- **Rule evaluation**: Rules are `{permission: glob, pattern: glob, action: allow|deny|ask}`. Evaluation tests the tool name against permission patterns and file paths against pattern globs. Last-match-wins among all rulesets (agent config → session → user config).

- **Ask flow**: `PermissionNext.ask()` stores a pending request, publishes `Event.Asked` to the bus, and returns a Promise that blocks tool execution.

- **Reply flow**: `PermissionNext.reply(requestID, reply, message?)` resolves the pending Promise. Reply types: "once" (allow this time), "always" (persist as an "allow" rule), "reject" (throw RejectedError or CorrectedError with optional message).

- **Cascade rejection**: When "reject" is received, iterate all pending requests for the same session and reject them too.

- **Corrective feedback**: If the reply includes a message, throw a `CorrectedError` instead of `RejectedError`. The tool execution framework catches `CorrectedError` and sends the message back to the LLM as a tool error, effectively telling the agent what went wrong and what to do differently.

- **Rule persistence**: "Always" replies are stored in the database as permanent rules for the session/project.

**Source**: `packages/opencode/src/permission/next.ts` (15 KB)

### 9. Monotonic Time-Ordered ID Generation with Type Prefixes (MEDIUM)

**The idea**: A custom ID scheme that combines a time-ordered component (for efficient sorting and range queries), a random component (for uniqueness), a monotonic counter (for same-millisecond ordering), and a type prefix (for self-documenting IDs).

**Why this matters for Cubex**: Sessions, messages, and parts need IDs that sort correctly by creation time (for efficient pagination and streaming), are globally unique (for concurrent operations), and are human-readable in logs and debuggers. UUIDs don't sort by time. ULIDs are close but lack type prefixes. OpenCode's scheme combines the benefits: `ses_0193a4b2c1d4rAnD0mBaSe62` is immediately recognizable as a session ID, sorts correctly, and is unique. The ascending/descending variants enable both chronological and reverse-chronological ordering in the same database.

**How it works** (language-agnostic pattern):

- **Format**: `{prefix}_{timestamp_hex}{random_base62}` — 3-char prefix, underscore, 12-char hex timestamp (6 bytes big-endian ms since epoch), 14-char random base62.

- **Prefixes**: `ses` (session), `msg` (message), `prt` (part), `per` (permission), `que` (question), `usr` (user), `pty` (terminal), `tool` (tool), `wrk` (worktree).

- **Monotonic counter**: If two IDs are generated in the same millisecond, the counter increments to ensure strict ordering.

- **Ascending/Descending**: `Identifier.ascending()` produces normal order. `Identifier.descending()` inverts the timestamp bits, producing IDs that sort in reverse chronological order (useful for "latest first" queries without ORDER BY DESC).

- **Implementation for Rust**: Trivial — `SystemTime`, hex encoding, base62 with `rand`, and an `AtomicU32` counter. ~50 lines of Rust.

**Source**: `packages/opencode/src/id/id.ts`

## Summary

opencode's gifts to Cubex, in order of impact:

1. **Client/Server Architecture** — Separating intelligence from presentation via HTTP/SSE/WebSocket enables remote operation, multi-client attachment, IDE integration, and headless CI mode without rebuilding the core
2. **Built-in LSP Integration** — Automatic language server management for 7+ languages gives the agent IDE-level code understanding (go-to-definition, diagnostics, call hierarchy) that no other harness in the collection provides
3. **Git-Backed Workspace Snapshots** — Lightweight, zero-impact filesystem checkpoints using `git write-tree` in a separate git directory enable per-tool-call revert without polluting project history
4. **4-Pass Unicode-Aware Patch Matching** — Graceful degradation through exact→whitespace→Unicode normalization passes prevents edit failures from LLM-generated typographic characters
5. **Two-Phase Compaction** — Prune old tool outputs for free before expensive LLM summarization, with a structured summary template for better continuation quality
6. **Typed Event Bus with Instance Lifecycle** — Zod-typed events with automatic subscription cleanup enable reactive cross-subsystem communication without leak risks
7. **PTY Ring Buffer Streaming** — Server-side terminal management with fixed-size ring buffers, binary WebSocket protocol, and late-join catch-up enables remote terminal access
8. **Permission Cascade and Corrective Feedback** — Rejecting one permission rejects all pending, and `CorrectedError` turns denial into a steering mechanism by sending feedback to the LLM
9. **Monotonic Time-Ordered ID Generation** — Type-prefixed, time-sortable, unique IDs with ascending/descending variants eliminate the need for secondary indexes on creation time
