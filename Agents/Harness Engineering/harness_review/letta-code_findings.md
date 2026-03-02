# letta-code Findings (Deep Dive)

## Scope and Method

This document synthesizes a deep exploration of the `letta-code` repository at `/data/projects/cubex/letta-code/`. The repository is a TypeScript/Bun CLI agent harness built on top of the Letta API, using Ink (React) for terminal UI rendering.

Research method:
- Three parallel exploration agents launched with distinct focus areas:
  - **Agent A**: Core execution architecture, memory system, agent creation, turn recovery, approval system, subagents, skills, providers
  - **Agent B**: Tools system, permissions, reminders, queue, ralph mode, hooks, prompts/personas, sleeptime, LSP integration, types/protocol
  - **Agent C**: CLI/TUI architecture, WebSocket layer, web interface, settings, auth, updater, build system, examples
- Every key source file in `src/` was read, covering agent memory (6 files), tools (30+ implementations), permissions (12 files), CLI components (80+), WebSocket protocol (63KB), settings manager (55KB), headless engine (118KB), and the main TUI app (502KB)
- Cross-referenced against existing `agno_findings.md` and `deepagents_findings.md` to identify genuinely novel contributions

Primary sources reviewed:
- `README.md`, `CLAUDE.md`, `CONTRIBUTING.md`
- `src/agent/` — all 35+ files (memory, skills, subagents, approval, turn recovery, prompts)
- `src/tools/` — all tool definitions and 30+ implementations
- `src/permissions/` — all 12 files (checker, analyzer, modes, read-only shell)
- `src/cli/` — App.tsx (502KB), commands, components (80+), helpers (40+)
- `src/websocket/listen-client.ts` (63KB)
- `src/web/` — memory/plan viewer generators
- `src/headless.ts` (118KB), `src/index.ts` (74KB)
- `src/settings-manager.ts` (55KB)
- `src/queue/`, `src/reminders/`, `src/hooks/`, `src/ralph/`, `src/lsp/`, `src/auth/`, `src/telemetry/`

## README Alignment: What Is Unique About This Project

The README positions Letta Code as a "memory-first coding harness" built on the Letta API. Instead of working in independent sessions, users work with a persisted agent that learns over time and is portable across models.

1. **"Memory-first coding harness, built on top of the Letta API"** — Verified. The entire architecture revolves around persistent agents hosted by the Letta API (`@letta-ai/letta-client`). The `src/agent/client.ts` wraps the SDK with OAuth token refresh and HTTP instrumentation. Memory blocks are stored server-side or in a git-backed filesystem at `~/.letta/agents/{id}/memory/` (`src/agent/memoryGit.ts`). This is the defining architectural choice — the CLI is a client to a persistent agent service, not a standalone agent.

2. **"Persisted agent that learns over time"** — Verified. The agent has hierarchical memory initialized via a 31KB structured guide (`src/agent/prompts/init_memory.md`) creating 15-25 files organized as procedures, preferences, and history. A "sleeptime" agent persona (`src/agent/prompts/sleeptime.ts`) actively manages memory between turns. The `/remember` command and `/skill` command enable explicit and trajectory-based learning. Memory persists across sessions and across model changes.

3. **"Portable across models (Claude Sonnet/Opus 4.5, GPT-5.2-Codex, Gemini 3 Pro, GLM-4.7, and more)"** — Verified. The `src/agent/model.ts` (14KB) resolves model identifiers from a 27KB registry (`src/models.json`). Provider-specific system prompts exist for Claude, Codex, and Gemini (`src/agent/prompts/{claude,codex,gemini}.md` plus Letta-enhanced variants). Tools auto-adapt per provider via aliasing in `src/tools/toolDefinitions.ts` (e.g., PascalCase for Claude, snake_case for Codex).

4. **"Same agent across sessions"** — Verified. Settings track `lastSession` with `{agentId, conversationId}` in `src/settings-manager.ts`. Running `letta` resumes the previous agent. `/clear` starts a new conversation but keeps the same agent identity and memory. Agent IDs persist in `~/.letta/settings.json` with per-server tracking (`sessionsByServer`).

Letta Code's genuine identity is a **stateful agent client** — a CLI that connects to a persistent agent service (Letta API) where the agent's memory, skills, and identity survive across sessions and model switches. This is fundamentally different from other harnesses that treat each session as independent. The CLI itself is sophisticated (502KB React/Ink TUI, 118KB headless engine), but the defining architectural insight is that the agent is a long-lived entity hosted by a service, not an ephemeral process.

## Architecture Overview

Letta Code is a TypeScript/Bun CLI that connects to the Letta API to interact with persistent, stateful agents. The CLI handles local tool execution (file ops, shell commands), permission checking, and user interaction, while the Letta API manages agent state, memory blocks, conversations, and LLM orchestration. The architecture splits cleanly: intelligence and state on the server, execution and UX on the client.

Module/directory map:
```
src/
├── index.ts          (74KB) — CLI entry point, TUI orchestrator
├── headless.ts       (118KB) — Headless execution engine
├── agent/            — Agent management: memory, skills, subagents, approval, turn recovery
│   ├── memory*.ts    — Memory block management (standard + git-backed)
│   ├── subagents/    — 7 built-in subagents (explore, recall, reflection, etc.)
│   ├── prompts/      — 30+ prompt files (provider-specific, personas, memory init)
│   └── skills.ts     — Cascading skill discovery (project→agent→global→bundled)
├── tools/            — 30+ tool implementations with provider-specific aliases
│   ├── manager.ts    (44KB) — Tool loading, switching, name resolution
│   └── impl/         — Individual tool implementations
├── permissions/      — 4-mode permission system with dual-engine approval (V1+V2)
├── cli/              — Ink/React TUI (80+ components, 40+ helpers)
│   ├── App.tsx       (502KB) — Main TUI component
│   ├── commands/     — Slash commands (/connect, /model, /init, /remember, /skill)
│   └── components/   — Rich component library (approval dialogs, selectors, viewers)
├── websocket/        — WebSocket listen mode for remote execution
├── web/              — Self-contained HTML viewer generators (memory, plan)
├── queue/            — Message queueing with coalescence and barrier items
├── reminders/        — 9-part system reminder catalog with mode-aware injection
├── hooks/            — 13-event hook system (command + prompt hooks)
├── ralph/            — Iterative completion loop with promise matching
├── lsp/              — Language Server Protocol integration
├── settings-manager.ts (55KB) — Dual-layer settings (global + project-local)
└── auth/             — OAuth flow with PKCE support for multiple providers
```

Key abstractions: The `LettaClient` wraps the SDK for API communication. `MemoryPrompt` manages dual memory modes (API blocks vs. git filesystem) with drift detection. `QueueRuntime` serializes user input with coalescence. `SharedReminderEngine` injects contextual system reminders per turn. `TurnRecoveryPolicy` is a pure-function error classifier for retry decisions.

## Feature Analysis

### 1. Git-Backed Memory Filesystem (`src/agent/memoryGit.ts`, `memoryFilesystem.ts`, `memoryScanner.ts`)

**What it is**: A persistent memory system that stores agent knowledge as a git repository, enabling version-controlled memory with server synchronization.

**Key files**: `src/agent/memoryGit.ts` (16KB), `src/agent/memoryFilesystem.ts` (9KB), `src/agent/memoryScanner.ts` (3KB), `src/agent/memoryPrompt.ts` (6KB), `src/agent/memory.ts` (4KB), `src/agent/memoryConstants.ts` (70B)

**How it works**: On first run, the CLI clones a git repository from the Letta API server at `{LETTA_BASE_URL}/v1/git/{agent-id}/state.git` into `~/.letta/agents/{agent-id}/memory/`. On subsequent startups, it runs `git pull` to sync server-side changes. The directory has a two-tier structure: `system/` (files attached to the system prompt — persona, project, human) and `detached/` (user-created blocks accessed on demand via a memory tool). Auth uses HTTP credentials (`letta:{token}`) rather than SSH keys, with `normalizeCredentialBaseUrl()` for consistent credential lookups. The agent itself modifies memory by calling `git commit` and `git push` through the Bash tool during normal operation, making memory updates a natural part of the agent's workflow rather than a separate subsystem.

**Notable details**: The `memoryScanner` recursively traverses the memory directory to generate a tree visualization with depth tracking and `parentIsLast` stacks for proper tree-line rendering. The `memoryPrompt` module implements drift detection between two competing system prompt modes — "standard" (Letta API memory blocks with legacy language about "core memory composed of memory blocks") and "memfs" (git-backed with language about "memory stored in a git repository"). When a mismatch is detected, `reconcileMemoryPrompt()` strips the old addon and injects the correct one. The `MEMFS_CONFLICT_CHECK_INTERVAL` is 5 turns, checking for concurrent modifications.

### 2. Memory Initialization Protocol (`src/agent/prompts/init_memory.md`)

**What it is**: A 31KB structured guide that teaches the agent how to create and organize its hierarchical memory filesystem from scratch.

**Key files**: `src/agent/prompts/init_memory.md` (31KB)

**How it works**: When a user runs `/init`, this prompt is injected to guide the agent through creating 15-25 deeply hierarchical files with 2-3 levels of nesting. The target structure uses mandatory hierarchy (e.g., `project.md` → `project/tooling/bun.md` → `project/tooling/bun/advanced.md`) with a maximum of ~40 lines per file. Content is categorized into three types: procedures (rules and workflows like "always use conventional commits"), preferences (style conventions like "prefer functional components"), and history/context (important decisions like "auth was refactored in v2.0"). The initialization scans the project workspace, reads configuration files, and distills relevant information into the memory hierarchy.

**Notable details**: The file size (~40 lines per file) is intentionally constrained to keep individual memory units digestible for LLMs. The 2-3 level nesting depth balances organization with discoverability. The three content categories (procedures, preferences, history) provide a clear mental model for what should be persisted.

### 3. Sleeptime Compute Agent (`src/agent/prompts/sleeptime.ts`)

**What it is**: A specialized agent persona that runs between main agent turns to actively manage, consolidate, and refine the agent's memory.

**Key files**: `src/agent/prompts/sleeptime.ts` (2.2KB)

**How it works**: The sleeptime agent is a separate persona (49 lines) that observes the user-agent conversation and proactively updates memory blocks in real-time — during the session, not after it ends. Its operating rules are aggressive: if something was discussed, capture it somewhere in memory; every session should produce measurable memory improvements; regularly evaluate and improve its own memory management policies. The persona maintains memory hygiene by enforcing size limits, prioritizing recent/important information, consolidating redundant entries, and refining the hierarchical structure. It can be enabled via the `enableSleeptime` setting in `settings-manager.ts`.

**Notable details**: The term "sleeptime" comes from the Letta research paper concept of doing compute between active conversation turns — analogous to sleep consolidation in biological memory. The agent is designed to be aggressive ("over-manage rather than under-manage") and assumes the primary agent relies entirely on memory for cross-session continuity. Reflection triggers (`reflectionTrigger` setting) can be set to "step-count" or "compaction-event" to automatically launch the sleeptime/reflection agent.

### 4. Dual Memory Modes with Drift Detection (`src/agent/memoryPrompt.ts`)

**What it is**: Two parallel memory systems (API blocks and git filesystem) with automatic detection and reconciliation when the system prompt mismatches the active mode.

**Key files**: `src/agent/memoryPrompt.ts` (6KB)

**How it works**: The system supports two memory paradigms. Standard mode stores memory as Letta API blocks (persona, human, project) with server-side management. Memfs mode uses the git-backed filesystem at `~/.letta/agents/{id}/memory/`. `detectMemoryPromptDrift()` checks the current system prompt for telltale language — legacy markers like "core memory composed of memory blocks" indicate standard mode, while "Memory Filesystem" or "memory stored in a git repository" indicate memfs mode. Orphaned fragments (partial memfs sections without the full addon) are also detected. When drift is found, `reconcileMemoryPrompt()` strips the old addon text and injects the correct one based on the agent's current `memfs` setting.

**Notable details**: Memory blocks have label categories — `GLOBAL_BLOCK_LABELS` (persona, human), `PROJECT_BLOCK_LABELS` (currently empty after LET-7353 refactor), `ISOLATED_BLOCK_LABELS` (currently empty), and `READ_ONLY_BLOCK_LABELS` (memory_filesystem). When memfs is enabled, all server-side memory tools are detached and the client manages memory via the filesystem tools.

### 5. WebSocket Listen Mode (`src/websocket/listen-client.ts`)

**What it is**: A full-duplex WebSocket protocol enabling remote agent execution where a cloud control plane can send commands and receive state updates from a locally-running agent.

**Key files**: `src/websocket/listen-client.ts` (63KB)

**How it works**: The `ListenerRuntime` establishes a persistent WebSocket connection to the Letta Cloud. The protocol supports bidirectional messages: the server sends `IncomingMessage` (new user messages to execute), `ModeChangeMessage` (permission mode changes), `ControlRequest` (tool approval requests), `GetStatusMessage`/`GetStateMessage` (state queries), `RecoverPendingApprovalsMessage`, and `CancelRunMessage`. The client responds with `ResultMessage` (turn result with stop reason), `RunStartedMessage`, `ModeChangedMessage`, `StatusResponseMessage`, `StateResponseMessage` (full state snapshot with `schema_version: 1`), and `ControlResponse`. Messages are serialized through a `messageQueue` (Promise chain) to prevent concurrent processing. Approval batching is handled via `pendingApprovalResolvers` Map.

The reconnection strategy uses exponential backoff: initial delay 1 second, max delay 30 seconds, max total duration 5 minutes. A `hasSuccessfulConnection` latch distinguishes first-time failures from intermittent disconnects. Queue lifecycle events (`queue_item_enqueued`, `queue_batch_dequeued`, `queue_blocked/cleared/dropped`) are emitted with `session_id` and monotonic `event_seq` counters. The state machine tracks: active agent/conversation/run IDs, an `AbortController` for run cancellation, and a `pendingTurns` atomic counter to prevent race conditions.

**Notable details**: The `StateResponseMessage` includes a complete snapshot with schema version for forward compatibility. Run cancellation sends `CancelRunMessage` which sets `cancelRequested` flag and aborts the active controller. The heartbeat interval keeps the connection alive. The monotonic `eventSeqCounter` ensures event ordering across reconnections.

### 6. Turn Recovery Policy (`src/agent/turn-recovery-policy.ts`)

**What it is**: A pure-function error classification layer that determines retry strategy without performing any I/O, cleanly separating retry policy from execution logic.

**Key files**: `src/agent/turn-recovery-policy.ts` (12KB), `src/agent/approval-recovery.ts` (2KB)

**How it works**: The module exports pure functions that classify errors into actionable categories. `isApprovalPendingError()` detects "waiting for approval" in error details. `isConversationBusyError()` detects concurrent request conflicts. `isEmptyResponseRetryable()` handles empty LLM responses (Opus 4.6 pattern). `isRetryableProviderErrorDetail()` pattern-matches transient errors (network, rate limit, upstream). `isNonRetryableProviderErrorDetail()` catches auth/validation errors. `shouldRetryRunMetadataError()` centralizes the retry decision with quota checks.

The classification flow for 409 conflicts: `extractConflictDetail()` → `classifyPreStreamConflict()` → one of: `resolve_approval_pending` (retry with approvals), `retry_conversation_busy` (exponential backoff), `retry_transient` (honor Retry-After header), or `rethrow` (unknown). `rebuildInputWithFreshDenials()` strips stale approval data and prepends the server's actual pending list before retry.

**Notable details**: All functions are pure (no HTTP calls, no state mutation), making them trivially testable. The "empty response" handler specifically addresses a pattern seen with Claude Opus 4.6 (called "SAD" in comments). Retry quotas are tracked by the caller, not the policy layer.

### 7. Parallel Tool Approval Execution (`src/agent/approval-execution.ts`)

**What it is**: A tool execution strategy that safely parallelizes independent tool calls while serializing conflicting ones.

**Key files**: `src/agent/approval-execution.ts` (14KB), `src/agent/check-approval.ts` (20KB)

**How it works**: Tools are classified into parallel-safe (Read, Glob, Grep, ViewImage, conversation_search, web_search, fetch_webpage, Task, TaskOutput, EnterPlanMode, ExitPlanMode) and non-parallel. For a batch of approved tool calls: (1) split by file path for file-modifying tools, (2) group non-conflicting edits together, (3) execute parallel-safe tools concurrently, (4) sequential retry for failures with fresh IDs.

The `check-approval.ts` module implements `ResumeData` pattern — fetching pending approvals from the conversation's latest message. Message backfill uses configurable limits: `BACKFILL_PRIMARY_MESSAGE_LIMIT = 12` (user/assistant only), `BACKFILL_MAX_RENDERABLE_MESSAGES = 80` (safety cap), `BACKFILL_ANCHOR_MESSAGE_LIMIT = 6` (conversational anchors), `BACKFILL_PAGE_LIMIT = 200` (per-request). It extracts ALL tool calls from the approval request message, not just the first, enabling true parallel approval.

**Notable details**: File-path conflict detection prevents parallel execution of edits to the same file while allowing edits to different files to proceed concurrently. Failed tool calls are retried with fresh IDs to prevent duplicate execution detection on the server.

### 8. Queue-Based Turn Management with Coalescence (`src/queue/queueRuntime.ts`)

**What it is**: A priority queue that batches compatible user inputs into single API submissions while respecting barrier items that must execute alone.

**Key files**: `src/queue/queueRuntime.ts` (12KB), `src/queue/turnQueueRuntime.ts` (1.5KB)

**How it works**: Four item types: `MessageQueueItem` (user messages, coalescable), `TaskNotificationQueueItem` (background task events, coalescable), `ApprovalResultQueueItem` (barrier — blocks queue until processed), `OverlayActionQueueItem` (barrier — blocks queue until processed). Coalescable items are merged into single submissions. Soft limit (100 items) drops oldest coalescable item; hard ceiling (250 items) rejects incoming coalescable items entirely.

Queue lifecycle events: `onEnqueued(item, queueLen)`, `onDequeued(batch, metadata)`, `onBlocked(reason, queueLen)`, `onCleared(reason, clearedCount)`, `onDropped(item, reason, queueLen)`. The `turnQueueRuntime` handles merging multimodal content (text + images + artifacts) from multiple queued messages into single turn input.

**Notable details**: Barrier items prevent message coalescence — an approval result must be processed before any subsequent messages. This ensures approval decisions are never accidentally merged with user messages. The drop strategy (oldest coalescable first) prevents stale messages from blocking the queue indefinitely.

### 9. System Reminder Architecture (`src/reminders/`)

**What it is**: A 9-part contextual injection system that manages per-turn system reminders with mode-aware enabling and stateful deduplication.

**Key files**: `src/reminders/engine.ts` (13KB), `src/reminders/state.ts` (2.4KB), `src/reminders/catalog.ts` (2.5KB)

**How it works**: The `SharedReminderCatalog` defines 9 reminder types: session-context (device/git/cwd info), agent-info (agent identity), skills (available skills list), permission-mode (current restriction state), plan-mode (read-only behavior), reflection-step-count (memory reflection triggers), reflection-compaction (git-compaction triggers), command-io (recent slash command results), and toolset-change (client-side tool modifications).

Each reminder has a mode filter (interactive, headless-one-shot, headless-bidirectional, subagent) determining when it's applicable. `buildSharedReminderParts()` iterates the catalog, checks mode applicability, calls the async provider function, and collects text parts. State tracking (`SharedReminderState`) prevents re-injection: `hasSentAgentInfo`, `hasSentSessionContext`, `cachedSkillsReminder`, `lastNotifiedPermissionMode`, `turnCount`, and trigger flags for skills reinjection and reflection.

Skills reinjection is triggered when the context tracker detects filesystem changes in skill directories. The flag propagates through `syncReminderStateFromContextTracker()` and causes re-injection on the next turn.

**Notable details**: The reminder system is the single source of truth for what contextual information the agent receives each turn. The stateful tracking ensures expensive operations (skill discovery, context detection) only run when changes are detected, not every turn. The mode-aware filtering means subagents get different reminders than interactive sessions.

### 10. Ralph Mode — Iterative Completion Loop (`src/ralph/mode.ts`)

**What it is**: An autonomous execution loop that repeats agent turns until a completion promise is detected in the output.

**Key files**: `src/ralph/mode.ts` (162 lines)

**How it works**: `activate(prompt, completionPromise, maxIterations, isYolo)` starts the loop. Each turn, the agent's output is scanned for `<promise>...</promise>` tags. The content inside is whitespace-normalized and compared against the expected `completionPromise` string. If matched, the loop exits. If not, another turn begins. A `maxIterations` cap prevents infinite loops. The default completion promise is "The task is complete. All requirements have been implemented and verified working..."

State is managed via a singleton (`globalThis[Symbol.for("@letta/ralph")]`) tracking: `isActive`, `isYolo` (bypass permissions), `originalPrompt`, `completionPromise`, `maxIterations`, `currentIteration`.

**Notable details**: Uses the same globalThis Symbol pattern as the permissions system for bundle-safe state sharing. The `isYolo` flag enables fully autonomous operation by bypassing all permission checks. Named after "Ralph Wiggum Mode" — a humorous reference to autonomous, unguided operation.

### 11. Provider-Specific Tool Adaptation (`src/tools/toolDefinitions.ts`, `manager.ts`, `toolset.ts`)

**What it is**: A tool system that automatically adapts tool names, schemas, and implementations based on the active LLM provider.

**Key files**: `src/tools/toolDefinitions.ts` (396 lines), `src/tools/manager.ts` (44KB), `src/tools/toolset.ts` (varies)

**How it works**: The tool definition layer uses a 3-tuple structure: `{ schema, description, impl }`. Tools have provider-specific variants: Anthropic/Claude uses PascalCase names (Read, Write, Edit), OpenAI/Codex uses snake_case with PascalCase aliases (ReadFileCodex, ListDirCodex), Google Gemini gets specialized versions. Memory tool switching happens automatically — `memory` tool for Claude/Gemini swaps to `memory_apply_patch` for OpenAI. When memfs mode is enabled, all server-side memory tools are detached and replaced with filesystem-based memory management.

The manager resolves server-facing tool names to internal names (e.g., `write_file_gemini` → `write_file`), enabling model-agnostic tool call routing. Toolset derivation uses the model ID to determine which tool variant set to load.

**Notable details**: Streaming shell tools (Bash, BashOutput, ShellCommand, TaskOutput) emit output progressively rather than waiting for completion. The tool execution contract returns `{ toolReturn, status, stdout?, stderr? }` with optional `AbortSignal` for clean cancellation. LSP-aware Read tool (`ReadLSP.ts`) includes type diagnostics from language servers.

### 12. Permission System with Dual-Engine Approval (`src/permissions/`)

**What it is**: A 4-mode permission system with both pattern-matching (V1) and symbolic reasoning (V2) approval engines, plus sophisticated shell command analysis.

**Key files**: `src/permissions/checker.ts` (21KB), `src/permissions/analyzer.ts` (25KB), `src/permissions/readOnlyShell.ts` (16KB), `src/permissions/mode.ts` (13KB), `src/permissions/matcher.ts` (10KB), `src/permissions/loader.ts` (varies)

**How it works**: Four permission modes: `default` (ask user), `acceptEdits` (auto-approve file edits), `plan` (read-only with plan file resolution), `bypassPermissions` (auto-approve all). The V1 engine uses pattern matching against tool/file/bash rules. The V2 engine uses symbolic reasoning. Shadow-comparison mode runs both engines and logs discrepancies for debugging.

The `readOnlyShell.ts` module (16KB) performs sophisticated shell command parsing to distinguish safe commands (ls, grep, git status, cat) from write operations. `ApplyPatch` path extraction uses regex to determine which files a patch touches for approval routing. Plan mode reads `.letta/plan.md` and auto-resolves relative paths for file-level approval scoping.

**Notable details**: Permission rules are loaded from both global (`~/.letta/settings.json`) and project-local (`.letta/settings.local.json`) files. The dual-engine approach allows gradual migration from heuristic to symbolic approval without breaking existing behavior. Custom hook integration extends the approval pipeline with user-defined logic.

### 13. Skill System with Cascading Discovery (`src/agent/skills.ts`, `skillSources.ts`)

**What it is**: A 4-tier skill discovery system with filesystem-based change detection and automatic re-injection.

**Key files**: `src/agent/skills.ts` (12KB), `src/agent/skillSources.ts` (2KB)

**How it works**: Skills are discovered in priority order (first match wins): project skills (`.skills/` in CWD), agent skills (`~/.letta/agents/{agent-id}/skills/`), global skills (`~/.letta/skills/`), bundled skills (embedded in package). Each skill has an ID, name, description, optional category/tags, source path, and content. Discovery returns both skills and errors (for debugging invalid skill files).

Skills are injected as system reminders via `buildSkillsReminder()`. When the context tracker detects filesystem changes in skill directories, `pendingSkillsReinject` is set to true, causing re-discovery and re-injection on the next turn. The `/skill` command enables trajectory-based skill learning — the agent can learn a new skill from its current work session and save it for future use.

**Notable details**: The agent-specific skill tier (`~/.letta/agents/{id}/skills/`) is unique — skills can be per-agent, not just per-project or global. This enables different agents to have different capabilities. The skill creator mode prompt (`skill_creator_mode.md`, 5.5KB) guides the agent through authoring well-structured skill files.

### 14. Session Message Backfill (`src/agent/check-approval.ts`)

**What it is**: Intelligent message history reconstruction for session resumption that filters tool-heavy turns to surface conversational context.

**Key files**: `src/agent/check-approval.ts` (20KB)

**How it works**: On session resume, the system fetches recent message history but applies filtering to avoid tool-heavy turns crowding out conversational anchors. Constants control the behavior: `BACKFILL_PRIMARY_MESSAGE_LIMIT = 12` (only user/assistant messages count toward limit), `BACKFILL_MAX_RENDERABLE_MESSAGES = 80` (safety cap on total messages), `BACKFILL_ANCHOR_MESSAGE_LIMIT = 6` (stop when enough conversational anchors found), `BACKFILL_PAGE_LIMIT = 200` (per-request pagination limit). The algorithm prioritizes human/assistant messages as "conversational anchors" and includes surrounding tool messages for context, but stops backfilling once enough anchors are found.

**Notable details**: Configurable via `LETTA_BACKFILL` environment variable. The filtering distinguishes between "primary" message types (user, assistant, reasoning, event, summary) and "tool chatter" to ensure the resumed context gives the agent a good understanding of where the conversation left off.

### 15. Self-Contained Memory Viewer (`src/web/generate-memory-viewer.ts`)

**What it is**: A generator that creates standalone HTML files for visually inspecting the agent's git-backed memory with full commit history and diff visualization.

**Key files**: `src/web/generate-memory-viewer.ts` (14KB), `src/web/memory-viewer-template.txt` (95KB), `src/web/generate-plan-viewer.ts` (2KB), `src/web/plan-viewer-template.txt` (53KB)

**How it works**: The generator collects the current memory filesystem state, extracts git commit history (max 500 commits, recent 50 diffs), packages everything into a self-contained HTML file with embedded data, and writes it to `~/.letta/viewers/`. Payload caps prevent excessive file sizes: 100KB per diff, 5MB total. The generated HTML includes a complete UI for browsing memory files, viewing diffs between commits, and understanding how memory has evolved over time. A separate plan viewer generates similar standalone HTML for plan visualization.

**Notable details**: The memory viewer template alone is 95KB, indicating a sophisticated single-file web application. Being self-contained means viewers can be shared, archived, or opened without a running server. The cap system ensures generated viewers remain usable even for agents with extensive memory history.

### 16. Hooks System (`src/hooks/`)

**What it is**: An event-driven extensibility system supporting both shell commands and LLM-based prompt hooks across 13 event types.

**Key files**: `src/hooks/types.ts` (80 lines), `src/hooks/executor.ts` (12KB), `src/hooks/loader.ts` (11KB), `src/hooks/index.ts` (12KB), `src/hooks/prompt-executor.ts` (8KB), `src/hooks/writer.ts` (12KB)

**How it works**: Two hook types: `CommandHookConfig` (`{ type: "command", command, timeout? }`) runs shell commands, `PromptHookConfig` (`{ type: "prompt", prompt, model?, timeout? }`) uses an LLM to evaluate conditions using `$ARGUMENTS` placeholder substitution. Hooks attach to 13 event types across two categories: tool-specific (PreToolUse, PostToolUse, PostToolUseFailure, PermissionRequest) and lifecycle (UserPromptSubmit, Notification, Stop, SubagentStop, PreCompact, SessionStart, SessionEnd). Hooks are loaded from settings files and can be scoped to specific tools or events.

**Notable details**: Prompt hooks enable dynamic, LLM-evaluated policies — e.g., a hook could use an LLM to evaluate whether a proposed file edit meets code quality standards before allowing it. This is more flexible than pure pattern matching for approval decisions.

### 17. Headless Bidirectional Protocol (`src/headless.ts`)

**What it is**: A 118KB execution engine supporting three modes: one-shot (single prompt → result), bidirectional (streaming JSON protocol for programmatic interaction), and subagent (IPC-based child process).

**Key files**: `src/headless.ts` (118KB)

**How it works**: The headless engine invoked via `-p "prompt"` supports multiple output formats: `json` (structured result), `stream-json` (streaming events), and `text` (plain text). In bidirectional mode (`--input-format stream-json`), it implements a full message protocol with queue lifecycle events, approval handling, and error recovery. The execution flow: `handleHeadlessCommand()` → `resolveAgent()` → `setupReflectionSettings()` → `buildSharedReminderParts()` → `sendMessageStream()` → `processStream()` → `executeApprovals()` → `recordSessionEnd()`.

Retry policies: LLM API errors get max 3 retries, empty responses (Opus 4.6 SADs) get max 2 retries with a system reminder nudge, 409 "conversation busy" gets max 1 retry with 2.5s delay.

**Notable details**: The bidirectional mode effectively turns the CLI into a programmable agent runtime that can be driven by external systems. Combined with the listen mode WebSocket, this enables a fully remote-controlled agent.

### 18. Subagent System (`src/agent/subagents/`)

**What it is**: A system supporting 7 built-in subagents plus user-defined agents, with separate model selection and permission modes.

**Key files**: `src/agent/subagents/index.ts` (varies), `src/agent/subagents/manager.ts` (varies)

**How it works**: Built-in subagents: explore (code exploration), recall (memory/history retrieval), history-analyzer (conversation analysis), reflection (memory learning), general-purpose (multi-tool fallback), memory (memory management), init (onboarding). Each has a config: `{ name, description, systemPrompt, allowedTools, recommendedModel, skills, memoryBlocks, permissionMode }`. Subagents spawn as child processes via `spawn("letta", ["--subagent", name, ...args])` with IPC communication. Execution state tracks agent/conversation IDs, final result/error, statistics, and tool call display state.

**Notable details**: The `memoryBlocks` field controls which memory blocks a subagent can access ("all", "none", or specific labels). The `permissionMode` can differ from the parent — e.g., a read-only explore subagent vs. a fully-permissioned general-purpose agent. Subagents are separate processes, providing natural isolation.

### 19. Agent Export/Import Portability (`src/agent/export.ts`, `import.ts`)

**What it is**: A system for serializing and deserializing agent state, enabling agent migration between servers or backup/restore workflows.

**Key files**: `src/agent/export.ts` (5KB), `src/agent/import.ts` (14KB)

**How it works**: Export captures the agent's state (memory blocks, configuration, skills) into a portable format. Import reconstructs an agent on a different server or restores from backup. The import flow handles block provenance tracking and base tool recovery.

**Notable details**: This directly supports the "portable across models" claim — an agent's learned knowledge and preferences can be migrated between Letta instances.

### 20. CLI TUI Architecture (`src/cli/`)

**What it is**: A React/Ink-based terminal UI with 80+ components, rich approval dialogs, and multi-modal content rendering.

**Key files**: `src/cli/App.tsx` (502KB), `src/cli/components/InputRich.tsx` (50KB), `src/cli/helpers/accumulator.ts` (40KB), `src/cli/helpers/stream.ts` (21KB), `src/cli/helpers/errorFormatter.ts` (26KB), `src/cli/helpers/contextChart.ts` (15KB)

**How it works**: The TUI uses Ink's React-for-terminal framework. The main `App.tsx` manages the entire conversation lifecycle including streaming, approvals, and multi-modal rendering. `InputRich` provides multi-line input with OSC 8 hyperlink parsing, token estimation, paste-aware handling, and a configurable status line. The accumulator pattern buffers streaming chunks into typed message structures before rendering. Components include: inline approval dialogs (bash, file edit, generic), selectors (agent, conversation, model, provider, MCP), memory viewers (tab viewer, diff renderer), and animations (shimmer text, compacting animation).

**Notable details**: The 502KB App.tsx is one of the largest single-component files in any agent harness. The status line is fully configurable via `StatusLineConfig` — users can pipe a shell command that receives JSON stdin and returns display text, with configurable padding, timeout, debounce, and polling interval.

## What Our Harness Should Adopt From letta-code

These are letta-code's distinctive contributions — features that represent genuine innovations or unusually strong implementations that Cubex should adopt. Ranked by impact.

### 1. Git-Backed Memory Filesystem (HIGHEST)

**The idea**: Store agent memory as a version-controlled git repository with hierarchical file structure, enabling history tracking, branching, and server synchronization of learned knowledge.

**Why this matters for Cubex**: Cross-session learning is one of Cubex's day-one priorities. Most harnesses use flat key-value memory or append-only logs. A git-backed filesystem gives: version history of all memory changes, natural diff/merge semantics, offline inspection and manual editing, server sync via standard git protocols, and the agent can use familiar file tools (read/write/edit) to manage its own memory. Without this, memory management requires a separate tool/API and lacks change tracking.

**How it works** (language-agnostic pseudocode/pattern description):

```
Memory Directory Structure:
  ~/.cubex/agents/{agent-id}/memory/
  ├── system/              (attached to system prompt every turn)
  │   ├── persona.md       (agent identity and behavior)
  │   ├── human.md         (user preferences and context)
  │   └── project/         (project-specific knowledge, hierarchical)
  │       ├── tooling/
  │       └── architecture/
  └── detached/            (on-demand access via memory tool, not in prompt)

Initialization Flow:
  1. Clone: git clone {server_url}/v1/git/{agent-id}/state.git → memory dir
  2. Auth: HTTP credentials (agent-token-based, not SSH)
  3. On startup: git pull (sync server changes)
  4. Agent writes: uses standard file tools → git commit → git push

Memory File Constraints:
  - Max ~40 lines per file (LLM-digestible units)
  - 2-3 levels of directory nesting
  - 15-25 files total for a well-initialized agent
  - Three content types: procedures, preferences, history

System Prompt Integration:
  - Files under system/ are concatenated into system prompt
  - Files under detached/ are listed (name only) with a tool to read on demand
  - Tree visualization shows full hierarchy with depth indicators

Drift Detection:
  - On each session start, scan system prompt for memory mode markers
  - Standard mode: look for "memory blocks" language
  - Memfs mode: look for "memory stored in a git repository" language
  - If mismatch: strip old addon, inject correct one
  - Conflict check every N turns for concurrent modifications
```

**Source**: `src/agent/memoryGit.ts` (16KB), `src/agent/memoryFilesystem.ts` (9KB), `src/agent/memoryScanner.ts` (3KB), `src/agent/memoryPrompt.ts` (6KB), `src/agent/prompts/init_memory.md` (31KB)

### 2. Sleeptime Memory Consolidation Agent (VERY HIGH)

**The idea**: Run a specialized memory-management agent between active conversation turns that proactively consolidates, refines, and organizes the agent's persistent memory.

**Why this matters for Cubex**: Learning/memory across sessions is a Cubex day-one priority. Simply accumulating memories leads to bloat and noise. An active consolidation process — analogous to memory consolidation during sleep in biological systems — keeps memory high-quality, well-organized, and appropriately sized. Without this, memory quality degrades over time as entries accumulate without curation.

**How it works** (language-agnostic pseudocode/pattern description):

```
Sleeptime Agent Configuration:
  - Separate persona from main agent (memory management specialist)
  - Observes the just-completed user-agent conversation
  - Has full read/write access to memory filesystem

Trigger Mechanisms:
  - Step-count trigger: After N tool execution steps, launch reflection
  - Compaction-event trigger: When context is compacted, launch reflection
  - Manual trigger: User runs /remember command

Operating Rules (from persona):
  1. If something was discussed → capture in memory
  2. Update memory during session, not after
  3. Be aggressive with edits (over-manage > under-manage)
  4. Assume primary agent relies entirely on memory
  5. Every session → measurable memory improvements
  6. Regularly evaluate own memory management policies

Consolidation Actions:
  - Merge redundant entries across files
  - Promote important temporary notes to permanent memory
  - Archive outdated information
  - Restructure hierarchy when categories grow too large
  - Update preference/procedure files with newly observed patterns
  - Enforce per-file size limits (~40 lines)

Integration:
  - reflectionTrigger setting: "off" | "step-count" | "compaction-event"
  - reflectionBehavior setting: "reminder" (suggest) | "auto-launch" (automatic)
  - reflectionStepCount setting: number of steps between automatic reflections
```

**Source**: `src/agent/prompts/sleeptime.ts` (2.2KB), `src/reminders/engine.ts` (13KB — reflection trigger logic), `src/settings-manager.ts` (reflection settings)

### 3. Turn Recovery as Pure Policy (HIGH)

**The idea**: Implement error classification and retry decisions as pure functions with no I/O, completely decoupled from the execution layer that acts on those decisions.

**Why this matters for Cubex**: Agent harnesses must handle many error types (rate limits, auth failures, empty responses, concurrent conflicts, pending approvals). Mixing retry logic with I/O makes it hard to test, reason about, or extend. A pure policy layer is trivially unit-testable, composable, and can be swapped or extended without touching the execution code. This is especially important for Cubex's multi-provider support where different providers have different error patterns.

**How it works** (language-agnostic pseudocode/pattern description):

```
Policy Functions (all pure, no I/O):

classify_pre_stream_conflict(status_code, error_detail) → Action:
  extract_conflict_detail(response) → structured error info
  match:
    approval_pending → Action::ResolveApprovalPending
    conversation_busy → Action::RetryConversationBusy
    transient_provider → Action::RetryTransient(retry_after_header)
    unknown → Action::Rethrow

is_retryable_provider_error(detail: str) → bool:
  pattern match against: network errors, rate limits,
  upstream failures, timeout, overloaded, gateway errors

is_non_retryable_provider_error(detail: str) → bool:
  pattern match against: auth errors, validation errors,
  invalid model, content policy violations

should_retry(error, retry_count, max_retries) → RetryDecision:
  match error_type:
    empty_response → Retry with nudge reminder (max 2)
    provider_error → check retryable patterns (max 3)
    conversation_busy → exponential backoff (max 1, 2.5s delay)
    approval_pending → rebuild input with fresh denials
    non_retryable → NoRetry(reason)

rebuild_input_with_fresh_denials(original_input, server_pending) → input:
  strip stale approval data from original input
  prepend server's actual pending approval list
  return modified input

RetryDecision =
  | Retry { delay_ms, modified_input?, nudge_reminder? }
  | NoRetry { reason, error }
```

**Source**: `src/agent/turn-recovery-policy.ts` (12KB), `src/agent/approval-recovery.ts` (2KB)

### 4. Queue-Based Input Coalescence (HIGH)

**The idea**: Batch multiple user inputs into single API submissions using a priority queue with coalescable (mergeable) and barrier (blocking) item types.

**Why this matters for Cubex**: In interactive mode, users may type multiple messages before the agent finishes processing, or background tasks may generate notifications while an approval is pending. Without coalescence, each input becomes a separate turn, wasting context and creating fragmented conversations. A queue with smart batching makes the agent's processing more efficient and the conversation more coherent.

**How it works** (language-agnostic pseudocode/pattern description):

```
Queue Item Types:
  MessageItem      — user text/images (coalescable)
  TaskNotification — background task events (coalescable)
  ApprovalResult   — tool approval decision (barrier)
  OverlayAction    — UI overlay trigger (barrier)

Coalescence Rules:
  - Coalescable items merge into a single submission
  - Barrier items execute alone (block queue until processed)
  - A barrier always splits the queue into before/after batches

Capacity Management:
  soft_limit = 100  — drop oldest coalescable item to make room
  hard_limit = 250  — reject incoming coalescable item entirely

Dequeue Logic:
  1. If first item is barrier → dequeue just that item
  2. Otherwise → dequeue all coalescable items until barrier or empty
  3. Merge coalescable items into single multimodal input
  4. Emit lifecycle event with batch metadata (merged_count, post_queue_len)

Lifecycle Events:
  - enqueued(item, queue_length)
  - dequeued(batch, metadata)
  - blocked(reason, queue_length)  // approval pending, turn executing
  - cleared(reason, cleared_count) // user interrupt
  - dropped(item, reason, queue_length) // capacity management

Turn Input Merging:
  - Multiple text messages → concatenated with separators
  - Text + images → multimodal content array
  - Task notifications → XML-wrapped notification strings
```

**Source**: `src/queue/queueRuntime.ts` (12KB), `src/queue/turnQueueRuntime.ts` (1.5KB)

### 5. Parallel Tool Call Safety Classification (MEDIUM-HIGH)

**The idea**: Classify tools by side-effect profile to enable safe parallel execution of read-only tools while serializing write operations, with file-path conflict detection for concurrent file edits.

**Why this matters for Cubex**: LLMs often request multiple tool calls per turn. Executing them sequentially wastes time. But executing write operations in parallel can cause conflicts (two edits to the same file). A classification system that identifies safe parallelism while preventing conflicts gives significant speedups without correctness risks.

**How it works** (language-agnostic pseudocode/pattern description):

```
Tool Safety Classification:
  PARALLEL_SAFE = {Read, Glob, Grep, ViewImage,
                   conversation_search, web_search, fetch_webpage,
                   Task, TaskOutput, EnterPlanMode, ExitPlanMode}

  // Everything else is potentially side-effecting

Execution Strategy for a batch of approved tool calls:
  1. Partition into parallel_safe and non_parallel groups
  2. For non_parallel: extract target file paths from arguments
  3. Group non_parallel by file path:
     - Same file → must execute sequentially
     - Different files → can execute in parallel
  4. Execute plan:
     a. All parallel_safe tools → concurrent
     b. Non-conflicting file edits → concurrent
     c. Same-file edits → sequential within group
  5. On failure: retry with fresh tool call IDs
     (prevents duplicate execution detection on server)
```

**Source**: `src/agent/approval-execution.ts` (14KB)

### 6. System Reminder Catalog with Mode-Aware Injection (MEDIUM-HIGH)

**The idea**: A centralized catalog of contextual system reminders with per-mode enabling (interactive/headless/subagent), stateful deduplication, and change-triggered re-injection.

**Why this matters for Cubex**: Agent behavior depends on injected context (permissions, available skills, session info). Injecting everything every turn wastes tokens. Never re-injecting means stale context. A catalog-based approach with mode filtering and change detection injects the right context at the right time without waste.

**How it works** (language-agnostic pseudocode/pattern description):

```
Reminder Catalog Entry:
  id: string
  provider: async fn(context) → Option<text>
  enabled_modes: Set<interactive | headless_oneshot | headless_bidir | subagent>

Standard Catalog:
  session-context  → device/git/cwd (first turn only)
  agent-info       → agent identity (first turn only)
  skills           → available skills (first turn + on change)
  permission-mode  → restrictions (on mode change)
  plan-mode        → read-only guidance (when in plan mode)
  reflection-step  → memory reflection trigger (at step threshold)
  reflection-compact → compaction trigger (on compaction event)
  command-io       → slash command results (after command)
  toolset-change   → tool modifications (after tool change)

Injection State:
  has_sent_agent_info: bool
  has_sent_session_context: bool
  cached_skills_reminder: Option<string>
  last_notified_permission_mode: Option<mode>
  turn_count: u32
  pending_skills_reinject: bool
  pending_reflection_trigger: bool
  pending_command_io: Vec<reminder>
  pending_toolset_changes: Vec<reminder>

Build Process (per turn):
  for each reminder in catalog:
    if not enabled for current mode → skip
    if already sent and no change detected → skip
    result = await provider(context)
    if result.is_some() → collect
  return collected parts
```

**Source**: `src/reminders/catalog.ts` (2.5KB), `src/reminders/engine.ts` (13KB), `src/reminders/state.ts` (2.4KB)

### 7. WebSocket Remote Execution Protocol (MEDIUM)

**The idea**: A bidirectional WebSocket protocol enabling a cloud control plane to remotely drive a locally-running agent, with state synchronization, approval delegation, and resilient reconnection.

**Why this matters for Cubex**: Cubex is CLI-first, but remote execution enables IDE integrations, web UIs, and team-based agent management without requiring a separate server deployment. The listen mode pattern — local execution with remote control — preserves security (local filesystem access, local permissions) while enabling remote interaction.

**How it works** (language-agnostic pseudocode/pattern description):

```
ListenerRuntime State:
  socket: WebSocket
  heartbeat_interval: Timer
  event_seq_counter: u64  // monotonic across reconnections
  session_id: string      // stable for message envelope
  message_queue: SerializedPromiseChain  // prevents concurrent processing
  pending_approval_resolvers: Map<request_id, Resolver>
  active_run: Option<{agent_id, conversation_id, run_id, abort_controller}>
  cancel_requested: bool
  queue_runtime: QueueRuntime

Server → Client Messages:
  IncomingMessage(content)          — execute this prompt
  ModeChangeMessage(mode)           — change permission mode
  ControlRequest(tool_call_details) — approve/deny this tool
  GetStatusMessage                  — report current status
  GetStateMessage                   — report full state snapshot
  CancelRunMessage                  — abort current execution

Client → Server Messages:
  ResultMessage(stop_reason, stats)     — turn completed
  RunStartedMessage(run_id)             — execution began
  StatusResponseMessage(status_data)    — status report
  StateResponseMessage(state, schema_v) — full state snapshot
  ControlResponse(decision)             — approval decision

Reconnection Strategy:
  initial_delay: 1s
  max_delay: 30s
  max_total_duration: 5min
  strategy: exponential backoff with jitter
  successful_connection_latch: bool  // distinguishes first failure
```

**Source**: `src/websocket/listen-client.ts` (63KB)

### 8. Self-Contained Memory Viewer Generation (MEDIUM)

**The idea**: Generate standalone HTML files that visualize the agent's memory state with full git history and diff visualization, viewable without any running server.

**Why this matters for Cubex**: Memory inspection is critical for debugging agent behavior and understanding what the agent has learned. A self-contained viewer (vs. a live dashboard) works offline, can be shared with team members, and can be archived for reproducibility. The git history visualization shows how memory evolved over time, which is invaluable for understanding learning trajectories.

**How it works** (language-agnostic pseudocode/pattern description):

```
Generation Flow:
  1. Scan memory directory for all files
  2. Extract git log (max 500 commits)
  3. Generate diffs for recent 50 commits
  4. Apply caps: 100KB per diff, 5MB total payload
  5. Embed all data as JSON in HTML template
  6. Write self-contained HTML to ~/.cubex/viewers/
  7. Open in default browser

Viewer Data Structure:
  {
    context: { agent_id, agent_name, timestamp },
    memory_files: [{ path, content, last_modified }],
    recent_diffs: [{ path, html_diff }],
    commits: [{ hash, message, author, date, files_changed }]
  }

Template Features:
  - File browser with syntax highlighting
  - Commit history timeline
  - Side-by-side diff viewer
  - Search across memory content
  - All self-contained (no external dependencies)
```

**Source**: `src/web/generate-memory-viewer.ts` (14KB), `src/web/memory-viewer-template.txt` (95KB)

## Summary

letta-code's gifts to Cubex, in order of impact:

1. **Git-backed memory filesystem** — Version-controlled persistent memory with hierarchical file structure, server sync, and natural integration with file tools. Transforms agent memory from opaque blobs into inspectable, editable, versionable files.
2. **Sleeptime memory consolidation agent** — Active between-turns memory management that prevents memory quality degradation through proactive consolidation, inspired by biological sleep memory consolidation.
3. **Turn recovery as pure policy** — Clean separation of error classification from execution, enabling trivially testable retry logic across multiple providers.
4. **Queue-based input coalescence** — Smart batching of user inputs with coalescable/barrier item semantics, preventing fragmented conversations from rapid user input.
5. **Parallel tool call safety classification** — File-path-aware parallelism that speeds up multi-tool turns without risking write conflicts.
6. **System reminder catalog with mode-aware injection** — Centralized, stateful, change-driven context injection that avoids both stale context and wasted tokens.
7. **WebSocket remote execution protocol** — Local execution with remote control, enabling IDE/web integrations while preserving local security properties.
8. **Self-contained memory viewer generation** — Standalone HTML visualization of memory state and evolution, shareable without infrastructure.
