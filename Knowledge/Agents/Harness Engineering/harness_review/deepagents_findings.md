# deepagents Findings (Deep Dive)

## Scope and Method

This document synthesizes a deep exploration of the `deepagents` repository at `/data/projects/cubex/deepagents/`. The repository is a LangChain/LangGraph-based Python monorepo implementing an agent harness with a middleware composition architecture and pluggable backend protocol.

Research method:
- Three parallel exploration agents launched with distinct focus areas:
  - **Agent A**: Core SDK architecture — middleware composition, backend protocol, graph creation, state management, and summarization
  - **Agent B**: CLI and infrastructure — TUI application, skills system, sandbox integrations, ACP protocol, sessions, non-interactive mode, evaluation framework
  - **Agent C**: Examples and patterns — all examples (content-builder, deep-research, ralph-mode, text-to-sql), eval test suite, skill specifications, integration tests
- Every source file in the core SDK (`libs/deepagents/deepagents/`) was read completely
- Every source file in the CLI package (`libs/cli/deepagents_cli/`) was read completely
- All example projects and eval tests were read completely
- Cross-referenced against the existing `agno_findings.md` to identify genuinely novel contributions

Primary sources reviewed:
- `README.md`, `AGENTS.md` (monorepo-level)
- `libs/deepagents/deepagents/` — all 20 source files (graph.py, middleware/*, backends/*)
- `libs/cli/deepagents_cli/` — all 30+ source files (main.py, agent.py, app.py, config.py, sessions.py, non_interactive.py, subagents.py, local_context.py, skills/*, integrations/*, widgets/*)
- `libs/acp/deepagents_acp/` — server.py, utils.py
- `libs/harbor/deepagents_harbor/` — backend.py, deepagents_wrapper.py
- `examples/` — all 4 example projects with full source
- `tests/` — all eval tests, unit tests, integration tests

## README Alignment: What Is Unique About This Project

The README positions Deep Agents as "the batteries-included agent harness" — an opinionated, ready-to-run agent that ships with planning, filesystem access, shell execution, sub-agents, and context management out of the box. It is built on LangGraph and returns a compiled LangGraph graph.

1. **"An opinionated, ready-to-run agent out of the box"** — Verified. `create_deep_agent()` in `libs/deepagents/deepagents/graph.py` (~325 lines) produces a fully-configured agent with a 10-layer middleware stack, filesystem tools (ls, read_file, write_file, edit_file, glob, grep, execute), a todo tool, sub-agent delegation, context summarization, and a base system prompt — all with zero configuration. The `system_prompt`, `tools`, `middleware`, `subagents`, `skills`, `memory`, `backend`, and `interrupt_on` parameters allow incremental customization.

2. **"Built on LangGraph — Production-ready runtime"** — Verified. `create_deep_agent()` returns a `CompiledStateGraph` with `recursion_limit=1000`. Uses LangGraph's `Command` type for atomic state updates, `MemorySaver`/`AsyncSqliteSaver` checkpointers for session persistence, `BaseStore` for cross-session storage, and `interrupt()` for human-in-the-loop flows.

3. **"Provider agnostic"** — Verified. Uses `langchain.chat_models.init_chat_model()` which accepts any `provider:model` string. OpenAI models get automatic `use_responses_api=True`. Summarization defaults auto-calibrate based on model profile's `max_input_tokens`.

4. **"Batteries included — Planning, file access, sub-agents, and context management work out of the box"** — Verified. The middleware stack always includes `TodoListMiddleware`, `FilesystemMiddleware`, `SubAgentMiddleware` (with a built-in general-purpose sub-agent), `SummarizationMiddleware`, and `PatchToolCallsMiddleware`. Optional `MemoryMiddleware` and `SkillsMiddleware` activate when `memory` or `skills` parameters are provided.

Deep Agents' genuine identity is a **middleware-oriented agent framework** where agent behavior is composed by stacking interceptors (middleware) on top of a pluggable storage/execution layer (backends). It prioritizes composability and progressive customization — users start with batteries-included defaults and incrementally override what they need. The separation of "what the agent can do" (middleware) from "where it does it" (backends) is the core architectural insight.

## Architecture Overview

Deep Agents uses a two-layer architecture: **middleware** (behavior composition) and **backends** (storage/execution abstraction). The middleware stack intercepts the agent loop at defined hook points (`before_agent`, `wrap_model_call`) to inject tools, modify system prompts, manage context, and coordinate sub-agents. Backends implement a unified `BackendProtocol` for file operations and optionally `SandboxBackendProtocol` for shell execution, enabling the same agent code to run against in-memory state, local filesystem, persistent stores, or remote sandboxes.

Module/directory map:
```
libs/deepagents/deepagents/
├── __init__.py          — Public API surface (6 exports)
├── graph.py             — create_deep_agent() factory, middleware stack assembly
├── middleware/
│   ├── filesystem.py    — File/shell tools, tool result eviction (~1200 lines)
│   ├── memory.py        — AGENTS.md loading into system prompt (~355 lines)
│   ├── skills.py        — Agent Skills spec, progressive disclosure (~839 lines)
│   ├── subagents.py     — Task tool, sub-agent spawning/state isolation (~693 lines)
│   ├── summarization.py — Context compaction with history archival (~1100 lines)
│   ├── patch_tool_calls.py — Dangling tool call repair (45 lines)
│   └── _utils.py        — System prompt composition helper (24 lines)
└── backends/
    ├── protocol.py      — BackendProtocol, SandboxBackendProtocol ABCs (~518 lines)
    ├── state.py         — Ephemeral in-LangGraph-state storage (~233 lines)
    ├── store.py         — Persistent cross-session LangGraph Store (~628 lines)
    ├── filesystem.py    — Local filesystem with virtual mode (~725 lines)
    ├── local_shell.py   — Local shell execution (~360 lines)
    ├── sandbox.py       — Abstract remote sandbox, shell-as-filesystem (~446 lines)
    ├── composite.py     — Path-prefix routing across backends (~706 lines)
    └── utils.py         — Shared helpers, grep, glob, path validation (~560 lines)

libs/cli/deepagents_cli/
├── main.py              — Entry point, arg parsing, deferred imports (36 KB)
├── agent.py             — CLI agent factory, HITL config, system prompt (22 KB)
├── app.py               — Textual TUI application (97 KB)
├── config.py            — Settings, themes, LangSmith isolation (50 KB)
├── sessions.py          — SQLite-backed thread persistence (14 KB)
├── non_interactive.py   — Headless mode, tiered security (25 KB)
├── subagents.py         — YAML-based subagent loading (4.9 KB)
├── local_context.py     — Runtime context detection via shell script (16 KB)
├── skills/              — Skill discovery, CRUD, validation
├── integrations/        — Sandbox providers (Modal, Daytona, Runloop)
├── widgets/             — Textual TUI widgets (approval, messages, diffs)
└── built_in_skills/     — Shipped skills (skill-creator)

libs/acp/                — Agent Client Protocol server for editor integration
libs/harbor/             — Harbor evaluation/benchmark framework adapter
libs/partners/           — Sandbox SDK wrappers (Modal, Daytona, Runloop)
```

Key abstractions and relationships:
- `AgentMiddleware[StateT, ContextT, ResponseT]` — base class for all middleware; provides `before_agent` (one-time state setup), `wrap_model_call` (per-LLM-call interception), and `state_schema` (state extension)
- `BackendProtocol` — abstract interface for file operations (ls, read, write, edit, grep, glob, upload, download) with standardized error types
- `SandboxBackendProtocol` extends `BackendProtocol` with `execute()` for shell commands
- `BackendFactory = Callable[[ToolRuntime], BackendProtocol]` — deferred backend construction; the class `StateBackend` itself serves as its own factory
- `CompositeBackend` routes operations to different backends based on path prefixes, enabling hybrid storage topologies
- `create_deep_agent()` assembles middleware + backend into a `CompiledStateGraph` (LangGraph)

## Feature Analysis

### 1. Middleware Composition System (`libs/deepagents/deepagents/middleware/`)

**What it is**: A composable pipeline architecture where agent behaviors are implemented as stackable middleware interceptors, each with defined hook points into the agent loop.

**Key files**: `middleware/__init__.py` (19 lines), `middleware/_utils.py` (24 lines), `graph.py` (~325 lines)

**How it works**: Each middleware subclasses `AgentMiddleware[StateT, ContextT, ResponseT]` from LangChain and can implement three hooks. `before_agent(state, runtime, config)` is called once before the agent loop starts and used for one-time state initialization (loading memory, skills). It returns a state update dict or `None` and is idempotent — middleware checks if its state key already exists to avoid redundant loading. `wrap_model_call(request, handler)` is called on every LLM invocation; it can modify messages, system prompt, and tool list via `request.override(...)`, then calls `handler(modified_request)` to proceed. `state_schema` is a class variable declaring extra state keys the middleware needs, merged into the agent's state schema at graph compilation time.

The `create_deep_agent()` factory assembles middleware in a fixed order: TodoList → Memory → Skills → Filesystem → SubAgents → Summarization → PromptCaching → PatchToolCalls → [user middleware] → HITL. Each middleware's `wrap_model_call` additively injects into the system message via `append_to_system_message()`. Sub-agents receive their own middleware stack (same base layers minus Memory), ensuring consistent behavior with isolated state.

**Notable details**: Middleware ordering matters — `SummarizationMiddleware` runs last in the wrap chain to measure full token count including all injected context. The `_EXCLUDED_STATE_KEYS` set (`messages`, `todos`, `structured_response`, `skills_metadata`, `memory_contents`) prevents private state from leaking between parent and sub-agent contexts. Private state uses `PrivateStateAttr` annotation so it's not included in checkpoints or propagated to sub-agents.

### 2. Backend Protocol and Abstraction (`libs/deepagents/deepagents/backends/`)

**What it is**: A unified interface for file operations and shell execution that enables the same agent code to run against in-memory state, local filesystem, persistent stores, or remote sandboxes.

**Key files**: `backends/protocol.py` (~518 lines), `backends/state.py` (~233 lines), `backends/store.py` (~628 lines), `backends/filesystem.py` (~725 lines), `backends/local_shell.py` (~360 lines), `backends/sandbox.py` (~446 lines), `backends/composite.py` (~706 lines)

**How it works**: `BackendProtocol` defines: `ls_info`, `read` (paginated with offset/limit), `write`, `edit` (exact string replacement), `grep_raw` (literal string search), `glob_info`, `upload_files`, `download_files`, plus async variants defaulting to `asyncio.to_thread()`. All methods use standardized error types: `FileOperationError = Literal["file_not_found", "permission_denied", "is_directory", "invalid_path"]`.

Write/edit operations return result structs with a `files_update` field: `None` for externally-persisted backends (filesystem, store), or a dict for state-backed storage. The calling tool wraps non-None updates in a LangGraph `Command(update={"files": files_update, "messages": [...]})` for atomic state updates.

Six concrete backends: `StateBackend` (ephemeral per LangGraph thread), `StoreBackend` (cross-session via LangGraph BaseStore with namespace isolation), `FilesystemBackend` (local disk with optional `virtual_mode` for path confinement), `LocalShellBackend` (extends FilesystemBackend with `subprocess.run(shell=True)`), `BaseSandbox` (abstract — implements all file ops as shell commands via `execute()`), `CompositeBackend` (path-prefix routing across backends).

**Notable details**: `BackendFactory = Callable[[ToolRuntime], BackendProtocol]` allows deferred construction. `StateBackend` class itself serves as its factory since `StateBackend(runtime)` is a valid constructor. `execute_accepts_timeout()` uses `@lru_cache` on `inspect.signature()` to detect whether a backend's `execute()` method accepts `timeout`, handling backward compatibility. `FilesystemBackend` uses `O_NOFOLLOW` to prevent symlink following.

### 3. Summarization with History Archival (`libs/deepagents/deepagents/middleware/summarization.py`)

**What it is**: Context window management that compacts conversation history via LLM summarization while archiving full evicted history to a recoverable file.

**Key files**: `middleware/summarization.py` (~1100 lines)

**How it works**: Extends LangChain's base `SummarizationMiddleware` with backend-aware history offloading. On each LLM call: (1) reconstruct effective messages from prior `_summarization_event` in state, (2) optionally truncate large tool arguments in old messages (`TruncateArgsSettings` for write_file/edit_file payloads), (3) count tokens and check trigger, (4) if triggered, partition into summarize/preserve sets, (5) offload evicted messages as timestamped markdown to `/conversation_history/{thread_id}.md` via backend, (6) generate LLM summary, (7) build summary `HumanMessage` referencing archive path, (8) return `ExtendedModelResponse` with `_summarization_event` state update.

Trigger/keep uses `ContextSize` union: `("fraction", 0.85)`, `("tokens", 170000)`, or `("messages", 6)`. `compute_summarization_defaults(model)` auto-calibrates: models with a profile use fraction-based (85% trigger, 10% keep), others use fixed counts. The `SummarizationToolMiddleware` adds a `compact_conversation` tool for agent-initiated compaction.

**Notable details**: Chained summarization handled via `_is_summary_message` checking `lc_source='summarization'` in `additional_kwargs`. Archive is append-only (each event adds a timestamped section). Archive failure is non-fatal. `_compute_state_cutoff` adjusts absolute indices for synthetic summary messages from prior events.

### 4. Tool Result Eviction (`libs/deepagents/deepagents/middleware/filesystem.py`)

**What it is**: Automatic large-result management that writes oversized tool outputs to files and returns truncated previews with reference paths.

**Key files**: `middleware/filesystem.py` (~1200 lines)

**How it works**: In `wrap_model_call`, after the model call returns, scans tool results. When a non-filesystem tool returns a result larger than `tool_token_limit_before_evict * 4` characters (default 20k tokens = 80k chars), writes the full result to `/large_tool_results/{sanitized_tool_call_id}` and replaces with truncated preview plus reference path. Tools `ls`, `glob`, `grep`, `read_file`, `edit_file`, `write_file` are excluded from eviction.

**Notable details**: Tool call ID is sanitized to prevent path traversal. The eviction path routes to a temp directory via CompositeBackend in CLI mode. The agent can `read_file` the eviction path to access the full output.

### 5. Shell-as-Filesystem for Remote Sandboxes (`libs/deepagents/deepagents/backends/sandbox.py`)

**What it is**: An abstract sandbox base implementing all filesystem operations as self-contained shell commands, so any sandbox needs only `execute()`, `upload_files()`, and `download_files()`.

**Key files**: `backends/sandbox.py` (~446 lines)

**How it works**: `BaseSandbox` implements every `BackendProtocol` method by generating a shell command and calling `self.execute()`. For write/edit operations, uses heredoc-fed Python one-liners with base64-encoded JSON payloads (`<<'__DEEPAGENTS_EOF__'`) to bypass ARG_MAX limits and safely transport arbitrary content. Command templates include: `_WRITE_COMMAND_TEMPLATE` (check existence, create dirs, write), `_EDIT_COMMAND_TEMPLATE` (read, count occurrences, replace — with distinct exit codes: 2=file not found, 3=string not found, 4=ambiguous match), `_GLOB_COMMAND_TEMPLATE` (Python `glob.glob()` with JSON output), `_READ_COMMAND_TEMPLATE` (paginated with line numbers). `grep_raw()` uses `grep -rHnF` (fixed-string, not regex).

**Notable details**: Single-quoted heredoc delimiter prevents shell expansion of payload. Concrete implementations (Modal, Daytona, Runloop) only need ~200-300 lines each.

### 6. Composite Backend Path Routing (`libs/deepagents/deepagents/backends/composite.py`)

**What it is**: A filesystem router dispatching operations to different backends based on path prefixes.

**Key files**: `backends/composite.py` (~706 lines)

**How it works**: `CompositeBackend` accepts a `default` backend and `routes` dict mapping prefixes to backends. Routes sorted by prefix length (longest first) for correct specificity. For each operation: check longest-prefix match, strip prefix, forward to routed backend; no match uses default. Root `ls_info("/")` aggregates default listing plus virtual directory entries for each route. Root `grep_raw()` searches ALL backends and restores prefixes in results. Batch operations group by backend, make one call per backend, merge results.

**Notable details**: `execute()` is not path-routable — always delegates to default. The CLI routes `/large_tool_results/` and `/conversation_history/` to temp directories via CompositeBackend, keeping internal files out of the user's working directory.

### 7. Progressive Disclosure Skills System (`libs/deepagents/deepagents/middleware/skills.py`)

**What it is**: A skill discovery and loading system with three-tier progressive disclosure: metadata always in context, body on trigger, bundled resources on demand.

**Key files**: `middleware/skills.py` (~839 lines), `cli/deepagents_cli/skills/load.py` (~200 lines), `cli/deepagents_cli/skills/commands.py` (~300 lines), `built_in_skills/skill-creator/SKILL.md` (~19 KB)

**How it works**: Skills are directories with a `SKILL.md` file containing YAML frontmatter (name, description, optional license/compatibility/metadata/allowed-tools) and markdown body. Three tiers: (1) metadata always injected into system prompt (~100 words per skill), system prompt tells agent to `read_file` SKILL.md for details; (2) body loaded via `read_file` when agent triggers; (3) bundled resources (`scripts/`, `references/`, `assets/`) loaded on demand.

Five-level source layering (last wins): built-in → `~/.deepagents/<agent>/skills/` → `~/.agents/skills/` → `.deepagents/skills/` → `.agents/skills/`. Validation enforces spec: 1-64 chars, unicode lowercase alphanumeric + hyphens, no leading/trailing/double hyphens, name matches directory.

**Notable details**: State uses `PrivateStateAttr` to prevent sub-agent propagation. Loading is idempotent via state key check. `allowed-tools` in frontmatter supports comma-separated values. `MAX_SKILL_FILE_SIZE = 10MB` for DoS protection.

### 8. Memory via AGENTS.md (`libs/deepagents/deepagents/middleware/memory.py`)

**What it is**: Persistent memory loaded from AGENTS.md files into the system prompt, with self-update guidelines.

**Key files**: `middleware/memory.py` (~355 lines)

**How it works**: `MemoryMiddleware` batch-downloads sources via `backend.download_files()`. Missing files silently skipped. Content injected as `<agent_memory>` XML block with `<memory_guidelines>` instructing when to update (corrections, preferences) and not update (transient info, credentials — explicitly prohibited). Agent updates memory by calling `edit_file` on the memory paths. Loaded once per session via state key check.

**Notable details**: Uses `PrivateStateAttr`. Simpler than agno's `LearningMachine` (LLM-extracted key-value pairs) but more transparent — agent directly reads/writes human-readable markdown.

### 9. Sub-Agent Spawning with State Isolation (`libs/deepagents/deepagents/middleware/subagents.py`)

**What it is**: A `task` tool delegating work to named sub-agents with isolated context and controlled state propagation.

**Key files**: `middleware/subagents.py` (~693 lines)

**How it works**: `SubAgentMiddleware` builds a `task(description, subagent_type)` tool. On invocation: validate subagent_type, build sub-agent state excluding private keys, replace messages with single `HumanMessage(description)`, invoke sub-agent, return `Command` with final message and non-excluded state updates. Sub-agents specified as `SubAgent` TypedDicts or `CompiledSubAgent` with pre-built runnables. A `GENERAL_PURPOSE_SUBAGENT` is always prepended. Sub-agents can use different/cheaper models.

**Notable details**: The `description` field serves double duty — tells the orchestrating LLM when to delegate AND is injected into the task tool's system prompt. YAML-based subagent config (`subagents.yaml`) is a CLI convenience, not core SDK. Sub-agent `interrupt_on` can override parent's HITL config.

### 10. Dangling Tool Call Repair (`libs/deepagents/deepagents/middleware/patch_tool_calls.py`)

**What it is**: Automatic detection and repair of AI messages referencing tool calls with no corresponding response.

**Key files**: `middleware/patch_tool_calls.py` (45 lines)

**How it works**: In `before_agent`, scans message history for `AIMessage` objects with `tool_calls`. For each, checks if a corresponding `ToolMessage` exists downstream. If not, injects synthetic `ToolMessage` explaining cancellation. Returns `{"messages": Overwrite(patched)}` to replace entire message list.

**Notable details**: Without this, LLMs produce confused outputs when seeing tool calls without responses. Essential for reliable session resume after interruption.

### 11. Non-Interactive Mode with Tiered Security (`libs/cli/deepagents_cli/non_interactive.py`)

**What it is**: Headless execution with two-tier security — shell fail-closed unless allow-listed, non-shell tools auto-approved.

**Key files**: `non_interactive.py` (~25 KB)

**How it works**: `_make_hitl_decision()`: shell tools rejected if no allow-list, checked against list if present; non-shell tools always approved. Main loop streams with `stream_mode=["messages", "updates"]`, processes interrupts, resumes with `Command(resume=hitl_response)`. Capped at 50 HITL iterations. Quiet mode routes diagnostics to stderr.

**Notable details**: `StreamState` tracks tool call chunks by index/ID, pending interrupts, decisions. `HITLIterationLimitError` raised at cap.

### 12. Local Context Detection (`libs/cli/deepagents_cli/local_context.py`)

**What it is**: Middleware running a shell detection script for runtime context (language, package managers, git state, file listing), re-running after summarization events.

**Key files**: `local_context.py` (~16 KB)

**How it works**: `DETECT_CONTEXT_SCRIPT` is a modular bash script detecting: CWD, git info (branch, uncommitted changes), project type, package managers (uv/poetry/pipenv/bun/pnpm/yarn/npm), runtimes (python3/node), filtered file listing (cap 20), `tree -L 3`, Makefile excerpt. `LocalContextMiddleware` runs detection in `before_agent`, injects into system prompt via `wrap_model_call`, tracks `_local_context_refreshed_at_cutoff` to re-run after summarization. Works identically for local and sandbox backends via `backend.execute()`.

**Notable details**: `_ExecutableBackend` Protocol check gates whether middleware is added. Refresh is triggered by new `_summarization_event` in state.

### 13. Agent Client Protocol Integration (`libs/acp/deepagents_acp/`)

**What it is**: ACP server bridging Deep Agents with editors (VS Code, Zed).

**Key files**: `server.py` (~36 KB), `utils.py` (~8 KB)

**How it works**: `AgentServerACP(ACPAgent)` implements `new_session`, `set_session_mode`, and `prompt()` — the core streaming handler converting ACP content blocks to LangChain format, streaming with `subgraphs=True`, accumulating tool call chunks, emitting `session_update` events, handling HITL. Tool kind mapping: `read_file→"read"`, `edit_file/write_file→"edit"`, `ls/glob/grep→"search"`, `execute→"execute"`. `_handle_todo_update()` converts todos to ACP `AgentPlanUpdate` with `PlanEntry` objects for editor plan panels.

**Notable details**: Free-form `LangGraph.interrupt()` calls explicitly rejected with `RequestError(-32600)` — enforces structured HITL compliance.

### 14. Harbor Evaluation Framework (`libs/harbor/deepagents_harbor/`)

**What it is**: Adapter plugging Deep Agents into Harbor benchmarks with trajectory tracking.

**Key files**: `backend.py` (~16 KB), `deepagents_wrapper.py` (~15 KB)

**How it works**: `HarborSandbox` is async-only `SandboxBackendProtocol` using `BaseEnvironment.exec()`. All sync methods raise `NotImplementedError`. File ops via shell with base64 heredocs; `aedit()` uses `perl -i -pe` with `\Q...\E` escaping. `DeepAgentsWrapper(BaseAgent)` supports CLI or SDK agent modes with auto-approve. `_save_trajectory()` converts to Harbor ATIF-v1.2 format with token tracking. LangSmith experiment integration via `trace()` context managers.

**Notable details**: Filters bash TTY artifacts from output. Default 300-second command timeout.

### 15. Trajectory-Based Eval Framework (`libs/deepagents/tests/evals/`)

**What it is**: Behavioral testing verifying exact tool call sequences, step counts, parallelism, and efficiency — not just final output.

**Key files**: `tests/evals/utils.py` (~11 KB), `tests/evals/test_file_operations.py` (~16 KB), `tests/evals/test_hitl.py` (~7.8 KB), `tests/evals/test_memory.py` (~7.1 KB), `tests/evals/test_skills.py` (~9.1 KB), `tests/evals/test_subagents.py` (~2.2 KB), `tests/evals/test_summarization.py` (~10 KB)

**How it works**: `TrajectoryExpectations` is a frozen dataclass with chainable builder: `num_agent_steps`, `num_tool_call_requests`, `require_tool_call(step, name, args_contains/args_equals)`, `require_final_text_contains(text, case_insensitive)`. `run_agent()` executes with optional seed messages and initial filesystem, captures trajectory as `AgentStep` objects, logs to LangSmith. `conftest.py` adds `--model` flag parametrizing all tests across models.

**Notable details**: Tests enforce efficiency — parallel writes expect 2 calls in step 1 (not 2 steps), simple math expects 0 tool calls, error recovery expects specific sequence (read wrong → ls → read correct). Summarization tests use artificially low `max_input_tokens` and seed conversations from LangSmith runs for reproducibility.

### 16. Ralph Mode (`examples/ralph_mode/`)

**What it is**: Autonomous looping with fresh context per iteration, using filesystem as persistent memory.

**Key files**: `ralph_mode.py` (~8.6 KB)

**How it works**: `ralph()` coroutine runs a while loop (configurable max or unlimited). Each iteration constructs prompt: "Your previous work is in the filesystem. Check what exists and keep building. TASK: {task}. Make progress. You'll be called again." Calls `run_non_interactive()` with `assistant_id="ralph"` (fresh thread, shared filesystem). Exit 130 = KeyboardInterrupt stops; other errors continue. Supports all CLI features: sandboxes, allow-list, model params.

**Notable details**: Originated from Geoff Huntley's `while :; do cat PROMPT.md | agent ; done`. Sidesteps context limits and conversation drift by design.

### 17. HITL Approval System (`libs/cli/deepagents_cli/widgets/approval.py` + `agent.py`)

**What it is**: Per-tool interrupt configuration with rich approval UI, diff rendering, and focus-trapped menus.

**Key files**: `widgets/approval.py` (~13 KB), `widgets/tool_renderers.py` (~3.8 KB), `widgets/tool_widgets.py` (~8.4 KB), `agent.py` (~22 KB)

**How it works**: `interrupt_on` dict maps tool names to `True` (default), `False` (never), or `InterruptOnConfig` with `allowed_decisions`. Per-tool description formatters generate approval prompts (write_file: path + action + line count; execute: command + CWD; task: subagent type + truncated instruction). `ApprovalMenu` traps focus (`on_blur` re-focuses), supports vim keys (j/k), offers Approve/Reject/Auto-approve-for-thread. Tool renderers: `EditFileRenderer` shows colored unified diff (green/red backgrounds), `WriteFileRenderer` shows syntax-highlighted content.

**Notable details**: Shell commands get minimal display; non-shell get panel with tool-specific widgets. Long commands expandable via `e` key. `can_focus_children = False` prevents child widgets stealing focus.

### 18. Session Persistence (`libs/cli/deepagents_cli/sessions.py`)

**What it is**: SQLite-backed thread persistence with fuzzy matching for resume.

**Key files**: `sessions.py` (~14 KB)

**How it works**: Sessions in `~/.deepagents/sessions.db` via LangGraph `AsyncSqliteSaver`. Thread IDs are 8-char hex. `list_threads()` queries checkpoint table's JSON metadata. `find_similar_threads()` uses SQL `LIKE` prefix matching for "did you mean?" suggestions. Message counts require deserializing checkpoint blobs via `JsonPlusSerializer`.

**Notable details**: Includes `_patch_aiosqlite()` for `langgraph-checkpoint >= 2.1.0` compatibility.

### 19. LangSmith Project Isolation (`libs/cli/deepagents_cli/config.py`)

**What it is**: Automatic separation of agent traces and user code traces in LangSmith.

**Key files**: `config.py` (~50 KB)

**How it works**: At module load, `LANGSMITH_PROJECT` overridden to `DEEPAGENTS_LANGSMITH_PROJECT`. Original value preserved in `Settings.user_langchain_project` and injected into shell subprocess env via `LocalShellBackend` env patching.

**Notable details**: Prevents agent internals from polluting user telemetry.

### 20. Stdin Pipe + TTY Restoration (`libs/cli/deepagents_cli/main.py`)

**What it is**: Handling piped stdin while preserving interactive terminal capability.

**Key files**: `main.py` (~36 KB)

**How it works**: `apply_stdin_pipe()` reads up to 10 MiB from piped stdin, prepends to prompt, then restores fd 0 from `/dev/tty` via `os.dup2()` so Textual can still read keyboard input.

**Notable details**: Solves non-trivial Unix fd management for pipe-then-interactive workflows.

## What Our Harness Should Adopt From deepagents

These are deepagents' distinctive contributions — features that represent genuine innovations or unusually strong implementations that Cubex should adopt. Ranked by impact.

### 1. Middleware Composition Architecture (HIGHEST)

**The idea**: Agent behaviors are stackable interceptors with defined hook points (`before_agent`, `wrap_model_call`, `state_schema`), enabling composable agent construction where each concern is an independent, testable layer.

**Why this matters for Cubex**: This is the highest-impact architectural pattern in the codebase. Instead of a monolithic agent with configuration flags, behaviors compose by stacking middleware — memory is a middleware, skills is a middleware, summarization is a middleware, sub-agents is a middleware. New behaviors can be added without modifying core agent logic. Users can replace or extend any layer independently. Each middleware is testable in isolation. The ordering is explicit and meaningful. Sub-agents automatically get a consistent middleware stack.

Without this, Cubex would need a monolithic agent class with dozens of interleaved parameters.

**How it works** (language-agnostic pseudocode/pattern description):

The middleware trait has three hooks:
- `state_schema()` → optional additional state keys merged into agent state at compile time
- `before_agent(state, runtime, config)` → called once before agent loop; returns optional state update; must be idempotent (check if state key exists before loading)
- `wrap_model_call(request, handler)` → called per LLM invocation; can modify messages/system_prompt/tools via `request.override()`; must call `handler(modified_request)` to proceed

Assembly in `create_agent()` follows fixed ordering: TodoList → Memory (if configured) → Skills (if configured) → Filesystem → SubAgents → Summarization → PromptCaching → PatchToolCalls → [user middleware] → HITL (if configured).

System prompt composition is additive: each middleware appends to the system message via a shared `append_to_system_message()` helper, producing: `[user_prompt] + [base_prompt] + [memory_block] + [skills_block] + [filesystem_block] + [subagents_block] + [summarization_block]`.

Private state isolation: keys annotated with `PrivateStateAttr` are excluded from checkpoints and sub-agent propagation. An explicit exclusion set (`_EXCLUDED_STATE_KEYS = {messages, todos, structured_response, skills_metadata, memory_contents}`) strips these when passing state to/from sub-agents.

Idempotent loading: each middleware gates its `before_agent` with `if state.contains_key("my_key") { return None; }`, so loading happens exactly once per thread even across resumed sessions.

**Source**: `libs/deepagents/deepagents/graph.py` (~325 lines), `libs/deepagents/deepagents/middleware/` (~4200 lines total)

### 2. Backend Protocol with Composite Path Routing (HIGHEST)

**The idea**: A unified interface for file operations and shell execution with a composite router dispatching by path prefix, enabling hybrid storage topologies transparently addressable by file path.

**Why this matters for Cubex**: Cubex needs to support multiple execution environments (local, Docker, cloud VMs, WASM sandboxes). The backend protocol means the same agent code runs identically against any target. The composite router is the key insight — different subsystems (memory in persistent store, working files in state, conversation history on disk) use different backends transparently. The agent just uses file paths; routing is invisible.

Without this, Cubex would need separate APIs for each storage location with different error handling.

**How it works** (language-agnostic pseudocode/pattern description):

Core protocol defines: `ls_info(path)`, `read(path, offset, limit)`, `write(path, content) → WriteResult`, `edit(path, old, new, replace_all) → EditResult`, `grep_raw(pattern, path, glob)`, `glob_info(pattern, path)`, `upload_files(files)`, `download_files(paths)`. All with async variants defaulting to thread-wrapped sync. Standardized errors: `FileNotFound`, `PermissionDenied`, `IsDirectory`, `InvalidPath`.

The `WriteResult.files_update` signal pattern: `None` = write already persisted externally (caller returns simple string); `Some(data)` = caller must issue `Command(update={files: data, messages: [...]})` to update LangGraph state atomically.

`SandboxBackendProtocol` extends with `execute(command, timeout) → ExecuteResponse` and an `id` property.

`BackendFactory = Callable[[ToolRuntime], BackendProtocol]` allows deferred construction — the class `StateBackend` itself serves as factory since `StateBackend(runtime)` works as a constructor.

`CompositeBackend` takes `default` backend + `routes: Map<prefix, backend>`, sorted by key length descending. Operations: find longest matching prefix → strip prefix → forward to routed backend. No match → use default. Root `ls("/")` aggregates default listing + virtual dirs for routes. Root `grep(None)` searches ALL backends and restores prefixes. `execute()` always delegates to default (not path-routable). Batch operations group by backend, one call per backend, merge results.

**Source**: `libs/deepagents/deepagents/backends/` (~3600 lines total)

### 3. Summarization with Recoverable History Archival (VERY HIGH)

**The idea**: Context compaction archives full evicted history to a timestamped file before summarizing — "lossy compression with a recovery path."

**Why this matters for Cubex**: Most harnesses simply discard evicted messages. This approach preserves full fidelity for the rare cases when the agent needs to refer back. The archive path is embedded in the summary message, making recovery discoverable. It's the difference between "I lost the details" and "details are in /conversation_history/abc123.md."

**How it works** (language-agnostic pseudocode/pattern description):

Configuration uses `ContextSize` union: `Fraction(0.85)` | `Tokens(170000)` | `Messages(6)`. Auto-calibration from model profile: with profile → `(Fraction(0.85), Fraction(0.10))`; without → `(Tokens(170000), Messages(6))`.

Per LLM call: (1) reconstruct effective messages from prior `SummarizationEvent` if any; (2) optionally truncate large tool args (write_file/edit_file payloads in old messages → placeholder); (3) count tokens, check trigger; (4) if triggered, partition into evict/keep sets; (5) offload evicted messages to `/conversation_history/{thread_id}.md` as markdown with `## Summarized at {timestamp}` header, appending to existing file; (6) generate LLM summary; (7) build summary message with archive path reference; (8) return response with `SummarizationEvent` state update containing `cutoff_index`, `summary_message`, `file_path`.

Chained summarization: check `lc_source='summarization'` to avoid re-archiving prior summaries. Archive failure is non-fatal (proceeds with `file_path=None`). State cutoff adjusted for synthetic summary messages from prior events.

`SummarizationToolMiddleware` wraps and adds a `compact_conversation` tool the agent can call proactively (e.g., when switching tasks).

**Source**: `libs/deepagents/deepagents/middleware/summarization.py` (~1100 lines)

### 4. Tool Result Eviction to Files (HIGH)

**The idea**: Automatically write oversized tool outputs to files, returning truncated previews with reference paths.

**Why this matters for Cubex**: A single large API response or web page can consume a massive fraction of the context window. Eviction preserves the full result (accessible via read_file) while keeping context compact. Without this, Cubex would face unpredictable context overflow from any tool returning large output.

**How it works** (language-agnostic pseudocode/pattern description):

After each model call, scan tool results in the response. For each non-filesystem tool result exceeding `threshold * 4` characters (default 20k tokens = 80k chars): sanitize tool_call_id for path safety, write full result to `/large_tool_results/{safe_id}`, replace with truncated preview + reference message. Excluded tools: `{ls, glob, grep, read_file, edit_file, write_file}` (already managed by filesystem middleware). The eviction path routes to a temp directory via CompositeBackend in practice.

**Source**: `libs/deepagents/deepagents/middleware/filesystem.py` (~1200 lines)

### 5. Shell-as-Filesystem for Remote Sandboxes (HIGH)

**The idea**: Implement all file operations as self-contained shell commands so any sandbox only needs `execute()` + `upload/download` to get full filesystem support.

**Why this matters for Cubex**: Reduces sandbox integration from O(n*m) (n operations * m sandbox types) to O(m). Each new sandbox provider is ~200-300 lines instead of thousands. Cubex will support multiple remote environments, so this multiplicative savings matters.

**How it works** (language-agnostic pseudocode/pattern description):

`BaseSandbox` subclasses implement only: `execute(cmd, timeout)`, `upload_files(files)`, `download_files(paths)`, `id`. All `BackendProtocol` methods are implemented as shell commands via `self.execute()`:

- `read()` → Python one-liner doing paginated read with line numbers
- `write()` → base64-encode JSON payload `{path, content}`, pipe via heredoc (`<<'__EOF__'`) to Python script that checks existence, creates dirs, writes file
- `edit()` → base64-encode JSON payload `{path, old, new, replace_all}`, Python script that reads, counts occurrences, replaces, writes; distinct exit codes for error types (2=not found, 3=string absent, 4=ambiguous)
- `grep_raw()` → `grep -rHnF pattern path` (fixed-string, recursive, with filename + line number)
- `glob_info()` → Python `glob.glob()` with JSON output

Single-quoted heredoc delimiter prevents shell expansion. Base64 encoding handles arbitrary content safely.

**Source**: `libs/deepagents/deepagents/backends/sandbox.py` (~446 lines)

### 6. Progressive Disclosure Skills System (HIGH)

**The idea**: Three-tier skill loading — metadata always in context (~100 words per skill), body on trigger, resources on demand — minimizing context pollution while keeping capabilities discoverable.

**Why this matters for Cubex**: An agent with 20+ skills can't fit all instructions simultaneously. Progressive disclosure means the agent always knows WHAT's available (tier 1) but only loads HOW when it decides to act (tier 2), and supporting resources only when referenced (tier 3). This is context-aware capability management.

**How it works** (language-agnostic pseudocode/pattern description):

Skill directory structure: `skill-name/SKILL.md` (required, YAML frontmatter + markdown body) plus optional `scripts/`, `references/`, `assets/` directories.

SKILL.md frontmatter: `name` (1-64 chars, lowercase alphanumeric + hyphens), `description` (trigger condition, ~100 words), optional `license`, `compatibility`, `allowed-tools`, `metadata`.

Source layering (last wins): built-in → user home → user shared → project local → project shared.

Tier 1 (always): `SkillsMiddleware.wrap_model_call()` injects skill list with names and descriptions into system prompt. Prompt tells agent: "Read SKILL.md for full details."

Tier 2 (on trigger): Agent calls `read_file(skill_path + "/SKILL.md")` to load full instructions.

Tier 3 (on demand): Skill body references `scripts/run.py` or `references/api.md`; agent reads those as needed.

Validation: name must match directory, 1-64 chars, no double/leading/trailing hyphens. `MAX_SKILL_FILE_SIZE = 10MB` for DoS protection.

**Source**: `libs/deepagents/deepagents/middleware/skills.py` (~839 lines), `libs/cli/deepagents_cli/skills/` (~500 lines)

### 7. Dangling Tool Call Repair (MEDIUM-HIGH)

**The idea**: Detect AI messages with tool calls lacking responses and inject synthetic cancellation messages, making session resume reliable.

**Why this matters for Cubex**: Sessions get interrupted. Without this, resumed sessions produce confused LLM outputs or errors from the orphaned tool call pattern. This is a small middleware (45 lines) with outsized reliability impact.

**How it works** (language-agnostic pseudocode/pattern description):

In `before_agent`: iterate messages. For each `AIMessage` with `tool_calls`, check if any subsequent message is a `ToolMessage` with matching `tool_call_id`. If not, insert synthetic `ToolMessage("Tool call was cancelled or interrupted.")` after the AI message. If any repairs made, return `Overwrite(patched_messages)` to replace entire message list. If no repairs needed, return `None`.

**Source**: `libs/deepagents/deepagents/middleware/patch_tool_calls.py` (45 lines)

### 8. Trajectory-Based Behavioral Eval Framework (MEDIUM-HIGH)

**The idea**: Test agent behavior by asserting on exact tool call sequences, step counts, parallelism, and efficiency — not just final output.

**Why this matters for Cubex**: Correctness testing is necessary but insufficient. An agent that gets the right answer in 10 sequential calls when 2 parallel calls would suffice is inefficient. Trajectory testing catches behavioral regressions and efficiency degradation. It's the difference between "works" and "works well."

**How it works** (language-agnostic pseudocode/pattern description):

`TrajectoryExpectations` frozen dataclass with chainable builder:
- `num_agent_steps: Option<usize>` — exact step count
- `num_tool_call_requests: Option<usize>` — exact total tool calls
- `require_tool_call(step, name, args_match)` — tool call at specific step with arg matching
- `require_final_text_contains(text, case_insensitive)` — final response assertion

`run_agent(query, initial_files, model)` → creates agent with StateBackend, seeded files, invokes, captures `AgentTrajectory` (list of `AgentStep` with AIMessage actions + ToolMessage observations), logs to LangSmith, returns for assertion.

Test categories: parallel efficiency (2 writes in 1 step), error recovery (specific retry sequence), unnecessary tool avoidance (0 calls for simple math), memory effectiveness (0 calls when answer in context), skill discovery (reads correct SKILL.md), summarization correctness (continues task after compaction, recovers pre-summarization info from archive file).

Cross-model: `conftest.py` adds `--model` flag parametrizing all tests.

**Source**: `libs/deepagents/tests/evals/` (~50 KB total across 7 files)

### 9. Ralph Mode: Autonomous Looping with Fresh Context (MEDIUM)

**The idea**: Run repeated iterations with fresh context windows using filesystem as persistent memory. Sidesteps context limits and conversation drift by design.

**Why this matters for Cubex**: Complementary to conversation-based execution. For long-running autonomous tasks, conversation agents hit limits even with summarization. Ralph mode avoids this entirely — each iteration is a fresh start, filesystem is the only continuity. Simple, robust, scales indefinitely.

**How it works** (language-agnostic pseudocode/pattern description):

```
loop (max_iterations or unlimited):
    prompt = "Your previous work is in the filesystem. Check what exists and keep building.\n\nTASK: {task}\n\nMake progress. You'll be called again."
    result = run_non_interactive(prompt, fresh_thread_id, shared_filesystem)
    if result.exit == SIGINT: break
    if result.exit != 0: log_error, continue
```

The filesystem IS the memory. No conversation history management needed. Each iteration's `assistant_id="ralph"` creates a fresh thread but shares the filesystem backend.

**Source**: `examples/ralph_mode/ralph_mode.py` (~8.6 KB)

### 10. Non-Interactive Tiered Security Model (MEDIUM)

**The idea**: In headless/CI mode, shell fail-closed by default (disabled unless allow-listed), non-shell tools auto-approved.

**Why this matters for Cubex**: Cubex needs headless mode for CI/CD. Shell is the highest-risk capability, so defaulting to disabled is correct. File writes are lower risk within working directory constraints. Tiered defaults provide safe automation without per-tool configuration.

**How it works** (language-agnostic pseudocode/pattern description):

Decision function: if shell tool → check allow_list: None = reject ("disabled"), Some(list) = check command prefix against list → approve/reject. If non-shell tool → always approve.

Main loop: stream agent output, process interrupts, resume with decisions, cap at 50 iterations. Quiet mode: diagnostics to stderr, agent text to stdout only.

**Source**: `libs/cli/deepagents_cli/non_interactive.py` (~25 KB)

## Summary

deepagents' gifts to Cubex, in order of impact:

1. **Middleware Composition Architecture** — Stackable behavior interceptors with `before_agent`/`wrap_model_call` hooks; each concern (memory, skills, summarization, sub-agents) is an independent, testable, replaceable layer
2. **Backend Protocol with Composite Path Routing** — Unified file/execution interface with path-prefix routing enabling hybrid storage topologies transparently addressable by file path
3. **Summarization with Recoverable History Archival** — Context compaction that archives full evicted history to timestamped files before summarizing, with auto-calibrating triggers based on model context window size
4. **Tool Result Eviction to Files** — Automatic large-result offloading that writes oversized tool outputs to files and returns truncated previews with reference paths
5. **Shell-as-Filesystem for Remote Sandboxes** — Abstract base implementing all file operations as shell commands, reducing sandbox integration from O(n*m) to O(m)
6. **Progressive Disclosure Skills System** — Three-tier loading (metadata always, body on trigger, resources on demand) minimizing context pollution while keeping capabilities discoverable
7. **Dangling Tool Call Repair** — 45-line middleware with outsized reliability impact, ensuring well-formed message history for session resume
8. **Trajectory-Based Behavioral Eval Framework** — Testing exact tool call sequences, parallelism patterns, and efficiency, not just correctness
9. **Ralph Mode** — Fresh context + persistent filesystem for indefinite autonomous loops
10. **Non-Interactive Tiered Security** — Shell fail-closed by default, non-shell auto-approved, with configurable allow-list for CI/headless use
