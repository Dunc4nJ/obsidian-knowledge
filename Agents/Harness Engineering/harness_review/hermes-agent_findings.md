# hermes-agent Findings (Deep Dive)

## Scope and Method

- **What was explored**: The hermes-agent repository at `/data/projects/cubex/hermes-agent`, a Python-based AI agent harness by NousResearch. Three parallel exploration agents were launched with distinct focus areas.
- **Agent A — Core Execution Architecture**: AIAgent class (`run_agent.py`), context compression (`agent/context_compressor.py`), prompt builder (`agent/prompt_builder.py`), subagent delegation (`tools/delegate_tool.py`), batch processing (`batch_runner.py`), toolset distributions (`toolset_distributions.py`), RL training environments (`environments/`), trajectory saving (`agent/trajectory.py`), model metadata, auxiliary client resolution.
- **Agent B — Gateway, Skills, and Memory Layer**: Messaging gateway (`gateway/`), platform adapters (Telegram, Discord, Slack, WhatsApp), session management (`gateway/session.py`), DM pairing (`gateway/pairing.py`), skills system (`tools/skills_tool.py`, `tools/skills_hub.py`, `tools/skills_guard.py`), memory tool (`tools/memory_tool.py`), session search (`tools/session_search_tool.py`), cron scheduler (`cron/`), event hooks (`gateway/hooks.py`).
- **Agent C — Tool System, Security, and Terminal Environments**: Tool registry (`tools/registry.py`), toolsets (`toolsets.py`), dangerous command approval (`tools/approval.py`), terminal orchestration (`tools/terminal_tool.py`), 5 terminal backends (`tools/environments/`), process registry (`tools/process_registry.py`), code execution sandbox (`tools/code_execution_tool.py`), file operations, web tools, vision tools, todo tool, CLI experience.
- **Primary sources reviewed**: README.md (1,500+ lines), AGENTS.md (657 lines), CONTRIBUTING.md (504 lines), plus 40+ source files across `agent/`, `tools/`, `gateway/`, `cron/`, `hermes_cli/`, and `environments/`.
- **Existing research context**: Reviewed summary sections of all 5 existing findings documents (agno, deepagents, letta-code, opencode, pi_agent_rust) to establish differentiation baseline.

## README Alignment: What Is Unique About This Project

**README claims**: "The fully open-source AI agent that grows with you. Install it on a machine, give it your messaging accounts, and it becomes a persistent personal agent — learning your projects, building its own skills, running tasks on a schedule, and reaching you wherever you are."

1. **"Persistent personal agent on your server"** — Verified. The messaging gateway (`gateway/run.py`, ~81KB) connects to Telegram, Discord, Slack, and WhatsApp via platform adapters (`gateway/platforms/`). It runs as a systemd service (`hermes gateway install`), maintaining persistent sessions in SQLite (`hermes_state.py`:517 lines). Session reset policies (daily, idle, both, none) are configurable per platform. Background processes are exempted from idle reset.

2. **"Learning your projects, building its own skills"** — Verified. The memory tool (`tools/memory_tool.py`:500 lines) maintains bounded persistent stores (MEMORY.md and USER.md in `~/.hermes/memories/`). The skills system supports agent-created skills alongside bundled and hub-installed skills. The skill_manage tool allows the agent to write new SKILL.md files during conversation. Session search (`tools/session_search_tool.py`:386 lines) with FTS5 enables recall of past conversations.

3. **"Running tasks on a schedule"** — Verified. The cron system (`cron/scheduler.py`:340 lines, `cron/jobs.py`:383 lines) executes scheduled tasks with file-based distributed locking, spawning fresh AIAgent instances per job. Results are delivered to configurable targets (local file, messaging platforms, specific chat IDs).

4. **"Reaching you wherever you are"** — Verified. The gateway delivers agent outputs across 4 messaging platforms with delivery routing (`gateway/delivery.py`:341 lines). Cron job results can be routed to any connected platform. Tool progress notifications keep users informed during long operations.

5. **"Use any model you want"** — Verified. Provider abstraction supports OpenRouter (200+ models), Nous Portal (OAuth), custom VLLM/SGLang endpoints, and direct OpenAI. Model switching via `hermes model` command. Auxiliary client resolution chain (`agent/auxiliary_client.py`:174 lines) independently resolves cheap models (Gemini Flash) for summarization tasks.

**Genuine identity**: Hermes is a **persistent personal agent** that lives on a server, connects to messaging platforms as its primary interface, and gets smarter over time through memory and skills. It is the only harness in this collection that treats messaging platforms as first-class deployment targets rather than CLI-first with optional integrations.

## Architecture Overview

Hermes is a Python agent harness (~30K+ LOC) built around an OpenAI-compatible API loop with self-registering tools, composable toolsets, and a messaging gateway that turns the agent into a persistent bot on Telegram/Discord/Slack/WhatsApp. The core is the AIAgent class (`run_agent.py`:2,754 lines) which runs a tool-calling loop with automatic context compression, prompt caching, and error recovery. Tools self-register via a central registry (`tools/registry.py`:220 lines) at import time, grouped into composable toolsets for different platforms and scenarios. Terminal execution is abstracted behind 5 interchangeable backends (local, Docker, SSH, Singularity, Modal) with per-backend security hardening.

**Module/directory map**:
- `run_agent.py` — AIAgent class: conversation loop, tool dispatch, session persistence, context compression triggers
- `agent/` — Extracted internals: prompt builder, context compressor, model metadata, trajectory saving, auxiliary client
- `tools/` — Self-registering tool implementations (20+ tools) + `environments/` sub-package (5 backends)
- `gateway/` — Messaging gateway: platform adapters, session management, delivery routing, DM pairing, hooks
- `hermes_cli/` — CLI implementation: entry point, config management, setup wizard, auth, callbacks
- `cli.py` — Interactive TUI (prompt_toolkit-based): fixed input area, KawaiiSpinner, slash commands
- `cron/` — Scheduled task execution: job storage, file-based locking, delivery routing
- `environments/` — RL training environments: Atropos integration, agent loop abstraction
- `skills/` — Bundled skill documents (SKILL.md files organized by category)
- `toolsets.py` — Composable tool groupings for different platforms and scenarios
- `hermes_state.py` — SQLite session database with FTS5 full-text search
- `batch_runner.py` — Parallel batch processing with content-based resume

**Key abstractions**: ToolRegistry (self-registering singleton) → Toolsets (composable groupings) → AIAgent (conversation loop) → Platform Adapters (messaging gateways). Terminal execution is fully abstracted behind BaseEnvironment, allowing the same agent to run commands locally, in Docker, over SSH, in Singularity, or on Modal cloud.

## Feature Analysis

### 1. Messaging Gateway Architecture (gateway/)
**What it is**: A production messaging gateway that connects the agent to Telegram, Discord, Slack, and WhatsApp as persistent bots.
**Key files**: `gateway/run.py` (~81KB), `gateway/session.py` (627 lines), `gateway/config.py` (~14KB), `gateway/delivery.py` (341 lines), `gateway/platforms/base.py` (754 lines), `gateway/platforms/telegram.py` (581 lines), `gateway/platforms/discord_adapter.py` (816 lines), `gateway/platforms/slack.py` (381 lines), `gateway/platforms/whatsapp.py` (427 lines)
**How it works**: GatewayRunner manages platform lifecycle — starts adapter connections, routes incoming messages to AIAgent instances, and dispatches responses back. Each platform adapter extends BasePlatformAdapter, normalizing messages into MessageEvent structs (text, type, source, media_urls). Sessions are tracked per (platform, chat_id, user_id) tuple in a SessionStore backed by SQLite + JSONL dual-write. The session system has configurable reset policies (daily/idle/both/none) per platform, and sessions with active background processes are exempt from idle reset. Delivery routing resolves targets from flexible specs ("origin", "local", "telegram:12345") and deduplicates across platforms. Messages exceeding platform limits (4000 chars) are truncated with full output saved to disk.
**Notable details**: The base adapter implements an interrupt-and-requeue pattern — `_active_sessions` tracks active handlers, new messages set an interrupt event causing the current handler to finish cleanly, and the pending message is queued in `_pending_messages` for processing after cleanup. Typing indicators refresh every 2 seconds to prevent expiration. Media (images, audio) is cached locally with UUID filenames to handle ephemeral platform URLs (Telegram URLs expire after ~1 hour). Environment variable bridging from config.yaml ensures terminal settings propagate correctly to gateway-spawned agents.

### 2. DM Pairing Security System (gateway/pairing.py)
**What it is**: Code-based user authentication for messaging bots that replaces static allowlists.
**Key files**: `gateway/pairing.py` (283 lines)
**How it works**: When an unknown user DMs the bot, they receive an 8-character pairing code generated from a 32-character unambiguous alphabet (no 0/O/1/I confusion) using `secrets.choice()` for cryptographic randomness. The code has a 1-hour TTL. The bot owner approves codes via `hermes pairing approve <platform> <code>`, permanently authorizing that user. Data is stored in `~/.hermes/pairing/` with separate files per platform.
**Notable details**: Rate limiting (1 request per user per 10 minutes), lockout after 5 failed attempts (1-hour platform lockout), max 3 pending codes per platform, `chmod 0600` on all data files. This is OWASP-aligned authentication for messaging bots — a solved problem that most agent harnesses ignore entirely.

### 3. Multi-Backend Terminal Execution (tools/environments/)
**What it is**: Five interchangeable terminal execution backends behind a single BaseEnvironment interface.
**Key files**: `tools/environments/base.py` (90 lines), `tools/environments/local.py` (135 lines), `tools/environments/docker.py` (243 lines), `tools/environments/ssh.py` (148 lines), `tools/environments/singularity.py` (~250 lines), `tools/environments/modal.py` (168 lines)
**How it works**: BaseEnvironment defines execute(command, cwd, timeout, stdin_data) → dict and cleanup(). Each backend implements this interface. LocalEnvironment uses `$SHELL -lic` (interactive login shell for full rc file sourcing) with process group management via `os.setsid()` and non-blocking I/O via background reader threads. DockerEnvironment applies aggressive hardening: `--read-only`, `--cap-drop ALL`, `--security-opt no-new-privileges`, `--pids-limit 256`, noexec tmpfs mounts. It supports persistent bind mounts to `~/.hermes/sandboxes/docker/{task_id}/` or ephemeral tmpfs. SSHEnvironment uses ControlMaster for 5-minute connection reuse via Unix domain sockets. SingularityEnvironment supports persistent writable overlays, automatic SIF image building from docker:// URLs with thread-locked caching, and HPC-friendly scratch directory resolution. ModalEnvironment snapshots the filesystem on cleanup and restores from snapshots on next creation, avoiding package reinstallation.
**Notable details**: Docker has clever disk quota probing — `_storage_opt_supported()` tests whether the Docker daemon supports `--storage-opt` by attempting a throw-away `docker create` and caches the result. All backends share interrupt handling via a shared `_interrupt_event` that kills process groups. The factory pattern in terminal_tool.py selects the backend from `TERMINAL_ENV` env var.

### 4. RPC Code Execution Sandbox (tools/code_execution_tool.py)
**What it is**: A sandbox that lets the LLM write Python scripts which call Hermes tools via RPC over Unix domain sockets, collapsing multiple tool calls into a single inference round-trip.
**Key files**: `tools/code_execution_tool.py` (~400 lines)
**How it works**: The parent process generates `hermes_tools.py` containing Python function stubs for 7 whitelisted tools (web_search, web_extract, read_file, write_file, search_files, patch, terminal). Each stub serializes its arguments to JSON and sends them over a Unix domain socket (path passed via `HERMES_RPC_SOCKET` env var) to the parent, which dispatches to the real tool registry and returns results. The child process runs with API keys stripped from environment. Only the child's stdout is captured and returned to the LLM — intermediate tool results are discarded, saving context tokens.
**Notable details**: Resource limits enforced: 300s timeout, max 50 tool calls, 50KB stdout cap, 10KB stderr cap. This is Programmatic Tool Calling (PTC) — instead of the LLM making one tool call per inference, it writes a script that orchestrates multiple tools programmatically. This collapses what would be 5-10 LLM round-trips into one, with only the final output consuming context.

### 5. Dangerous Command Approval System (tools/approval.py)
**What it is**: Multi-level approval system for dangerous shell commands with session-scoped and permanent allowlists.
**Key files**: `tools/approval.py` (299 lines)
**How it works**: 48 regex patterns detect dangerous commands across categories: file destruction (`rm -r`, `mkfs`, `dd`), permissions (`chmod 777`), SQL injection (`DROP`, `DELETE` without WHERE), system operations (`systemctl stop`, `kill -9 -1`), shell tricks (fork bomb `:(){ :|:& };:`), and code execution via pipe (`curl | sh`). When a match is found, the system checks a session-scoped set and permanent allowlist before prompting. The prompt offers four options: once (single execution), session (current session), always (persisted to `~/.hermes/config.yaml`), deny. The state is thread-safe (protected by `threading.Lock`). Container backends (Docker, Singularity, Modal) bypass approval entirely since they're sandboxed.
**Notable details**: Two approval flows: CLI uses prompt_toolkit callbacks with 60-second timeout (default deny on timeout); gateway submits a pending approval and blocks until the user responds via messaging. The callback delegation pattern means tools never import CLI code — the CLI registers callbacks that tools invoke, maintaining loose coupling.

### 6. Self-Registering Tool Registry (tools/registry.py)
**What it is**: Singleton tool registry where tools register themselves at module import time, eliminating circular imports and manual tool lists.
**Key files**: `tools/registry.py` (220 lines), `model_tools.py` (orchestration layer)
**How it works**: Each tool file imports `registry` and calls `registry.register()` at module level with name, toolset, schema, handler, optional check_fn, and requires_env list. ToolEntry uses `__slots__` for memory efficiency. `get_definitions()` filters out tools whose `check_fn()` returns False (e.g., missing API key). `dispatch()` routes calls by name, bridges async handlers transparently, and wraps all exceptions in `{"error": "..."}` for consistent LLM parsing. `model_tools.py` triggers discovery by importing all tool modules in its `_modules` list.
**Notable details**: The self-registration pattern means adding a tool requires only: create `tools/my_tool.py` with `registry.register()` at bottom, add to `_modules` in `model_tools.py`, optionally add to a toolset in `toolsets.py`. No modification to dispatch tables, schema collections, or handler maps. This is clean but table-stakes for modern agent frameworks.

### 7. Composable Toolset System (toolsets.py)
**What it is**: Hierarchical tool grouping with composition, cycle detection, and platform-specific presets.
**Key files**: `toolsets.py` (489 lines)
**How it works**: Basic toolsets group individual tools (e.g., `web` = web_search + web_extract). Scenario toolsets compose basic ones (e.g., `debugging` = terminal + process + web + file). Platform toolsets share a `_HERMES_CORE_TOOLS` base list, ensuring all platforms get the same core capabilities. `resolve_toolset()` recursively expands includes with cycle detection via a visited set. `"all"` or `"*"` aliases resolve to every registered tool.
**Notable details**: Named distributions in `toolset_distributions.py` (350+ lines) use independent Bernoulli trials per toolset for probabilistic tool selection during batch training. For example, the `research` distribution enables web at 90%, browser at 70%, and vision at 50%. If no toolsets are selected (rare), the highest-probability toolset is picked as fallback. This creates diverse training data where the model learns to work with varying tool availability.

### 8. RL Training Integration (environments/)
**What it is**: Direct integration with NousResearch's Atropos framework for reinforcement learning on agent behavior.
**Key files**: `environments/agent_loop.py` (~300 lines), `environments/hermes_base_env.py` (672 lines), `tools/rl_training_tool.py` (1,380 lines)
**How it works**: HermesAgentLoop is a reusable multi-turn agent engine with a ThreadPoolExecutor (128 workers) for sync tool calls — tools that call `asyncio.run()` get their own event loop to prevent deadlock. It extracts reasoning from multiple formats (reasoning_content, reasoning field, reasoning_details[].text). HermesAgentBaseEnv is an abstract base for Atropos environments, supporting two modes: Phase 1 (OpenAI server type with OpenRouter/VLLM) and Phase 2 (VLLM ManagedServer with client-side tool call parser). The RL training tool manages the full lifecycle: environment discovery via AST parsing, config management with locked infrastructure settings (tokenizer, learning rate, server URLs) and editable user settings (batch size, steps), subprocess management, and WandB metrics monitoring.
**Notable details**: Trajectory saving (`agent/trajectory.py`:57 lines) converts `<REASONING_SCRATCHPAD>` tags to `<think>` tags for ShareGPT format. `has_incomplete_scratchpad()` validates trajectory integrity. Content-based batch resume in `batch_runner.py` (1,204 lines) checkpoints by prompt content hash, enabling true fault tolerance for large training runs. This is the only harness in the collection designed to generate training data and run RL optimization on agent behavior.

### 9. Context Compression (agent/context_compressor.py)
**What it is**: Automatic conversation summarization when approaching context limits.
**Key files**: `agent/context_compressor.py` (210 lines)
**How it works**: Triggered at 85% of model context length (using actual token usage from API response, not estimates). Protects first N (default 3) and last N (default 4) turns, summarizes the middle via an auxiliary model (Gemini Flash). The summary prompt targets ~500 words, neutral perspective, capturing actions taken, key information, decisions, and data points. Long turns (2000+ chars) are pre-truncated to head + tail before summarization. Falls back to simple truncation when no auxiliary model is available.
**Notable details**: Uses the auxiliary client resolution chain (OpenRouter → Nous Portal → custom endpoint → none). Tool call names are extracted and included in the summary context. The todo list survives compression via `TodoStore.format_for_injection()` which re-injects task state with status markers after compression. This is competent but not novel — several other harnesses (deepagents, opencode) have more sophisticated compression strategies.

### 10. Prompt Injection Detection (agent/prompt_builder.py)
**What it is**: Regex-based scanning of context files (AGENTS.md, SOUL.md, .cursorrules) for injection and exfiltration attempts.
**Key files**: `agent/prompt_builder.py` (327 lines, detection at lines 20-57)
**How it works**: Before injecting context files into the system prompt, scans for: prompt injection patterns ("ignore previous instructions", "system prompt override"), deception ("do not tell the user"), bypass attempts ("act as if you have no restrictions"), exfiltration (`curl` with `$API_KEY`, `cat .env`), HTML comment injection, hidden divs, and invisible unicode (U+200B, U+200C, bidirectional overrides). Malicious files are blocked with a reason string injected into the prompt instead.
**Notable details**: Context files are truncated using a 70/20 head/tail strategy with a marker in the middle for files exceeding 20,000 characters. The memory tool also runs injection scanning on content before writing to MEMORY.md or USER.md. Non-destructive: malicious content is reported but doesn't crash the agent.

### 11. Session State with FTS5 (hermes_state.py)
**What it is**: SQLite-backed session persistence with full-text search for conversation recall.
**Key files**: `hermes_state.py` (517 lines), `tools/session_search_tool.py` (386 lines)
**How it works**: Two tables: `sessions` (id, source, user_id, model, system_prompt, parent_session_id, timestamps, token counts) and `messages` (id, session_id, role, content, tool_call_id, tool_calls, tool_name, timestamp, finish_reason). A `messages_fts` virtual table provides FTS5 full-text indexing with auto-triggers on insert/update/delete. The session search tool queries FTS5, groups results by session, loads conversation context around matches (`_truncate_around_matches()`), and sends to an auxiliary model for summarization.
**Notable details**: Parent-child session chaining via `parent_session_id` links compressed sessions for full history traversal. WAL mode enables concurrent readers + one writer (important for the gateway serving multiple platforms). Dual-mode token tracking at both session and message granularity.

### 12. Skills System with Progressive Disclosure (tools/skills_tool.py, tools/skills_hub.py, tools/skills_guard.py)
**What it is**: Three-tier skills architecture with progressive disclosure, multi-source registry, and security scanning.
**Key files**: `tools/skills_tool.py` (694 lines), `tools/skills_hub.py` (1,177 lines), `tools/skills_guard.py` (1,077 lines)
**How it works**: Progressive disclosure has three tiers: (1) metadata-only listing (name, description, category — ~50 tokens per skill), (2) full SKILL.md content on demand, (3) linked files (references, templates) loaded separately. The Skills Hub supports 4 source adapters (GitHub, ClawHub, Claude Marketplace, LobeHub) with multi-method GitHub auth (PAT, gh CLI, App JWT, unauthenticated). Skills Guard runs 18+ regex patterns across threat categories (exfiltration, injection, destructive commands, persistence, obfuscation) with trust-level-based install policies: builtin=allow-all, trusted=block-dangerous, community=block-caution+dangerous.
**Notable details**: Hub state management includes quarantine staging, audit logs, tap management (custom source repos), and index caching with 1-hour TTL. Lock file (`lock.json`) tracks installed skill provenance for rollback. The guard detects DNS exfiltration via `dig/nslookup` with variable interpolation and base64-encoded command obfuscation.

### 13. Memory Tool (tools/memory_tool.py)
**What it is**: Bounded persistent memory with two stores (agent notes and user profile) and injection scanning.
**Key files**: `tools/memory_tool.py` (500 lines)
**How it works**: MEMORY.md (2,200 char limit, ~550 tokens) stores agent learnings (environment facts, tool quirks, patterns). USER.md (1,375 char limit, ~344 tokens) stores user knowledge (preferences, communication style). Entries delimited by `\n§\n` (section sign). Memory is frozen at session start for prefix-cache stability — mid-session writes are durable to disk but don't modify the system prompt until the next session. Operations: add, replace (substring-based matching), remove, read. Content is scanned for injection patterns before writing.
**Notable details**: Character-based limits (not token-based) make bounds model-independent and predictable. The frozen snapshot pattern ensures the LLM's KV cache remains stable for the entire session. When the store is full, oldest entries are deleted first. This is competent but less sophisticated than letta-code's git-backed memory filesystem or agno's LearningMachine.

### 14. Cron Scheduler with Delivery Routing (cron/)
**What it is**: Scheduled task execution with flexible output delivery and file-based distributed locking.
**Key files**: `cron/scheduler.py` (340 lines), `cron/jobs.py` (383 lines), `tools/cronjob_tools.py` (referenced)
**How it works**: The scheduler uses file-based locking (`~/.hermes/cron/.tick.lock` with `fcntl`/`msvcrt`) to prevent concurrent ticks when multiple processes run (gateway, systemd timer, daemon). Each job creates a fresh AIAgent instance with session env vars injected. Results are delivered to configurable targets: `local` (save to file), `origin` (back to source chat), `<platform>` (home channel), or `<platform>:<chat_id>` (explicit target). Output mirroring writes delivered content to the gateway session for in-chat visibility. Environment variables and config are re-read per job execution, allowing provider/key changes without restart.
**Notable details**: Cron tools include prompt injection scanning to block instruction-override patterns in scheduled prompts. The delivery system truncates oversized output and saves the full version to disk with a link sent to the user. Cross-platform locking support (Unix fcntl + Windows msvcrt).

### 15. Human Delay Mode (gateway/platforms/base.py)
**What it is**: Configurable response pacing that adds random delays between messages to simulate human typing speed.
**Key files**: `gateway/platforms/base.py` (lines within the 754-line file)
**How it works**: Three modes: `off` (instant), `natural` (800-2500ms random jitter between text and media), `custom` (user-defined min/max milliseconds via env vars). Applied between text messages, between text and media attachments, and between sequential media items. Uses `random.uniform()` for jitter.
**Notable details**: Designed for messaging platforms where instant multi-message responses feel robotic. Combined with the continuous typing indicator refresh (every 2 seconds), this creates a natural conversational rhythm.

### 16. Background Process Management (tools/process_registry.py)
**What it is**: Registry for background processes with rolling output buffers, crash recovery, and PTY support.
**Key files**: `tools/process_registry.py` (~700 lines)
**How it works**: ProcessSession tracks each background process with a 200KB rolling output buffer, thread-safe via per-session locks. Actions: spawn (local with optional PTY for interactive CLIs), poll (non-blocking status check), log (full output with pagination), wait (blocking with timeout), kill (SIGTERM then SIGKILL), write/submit (send stdin). Gateway sessions with active background processes are exempt from idle reset. Crash recovery checkpoints active processes to `~/.hermes/processes.json` and restores them as detached (no stdout pipe) on restart.
**Notable details**: PTY mode via `ptyprocess` enables running interactive CLI tools (Codex, Claude Code, Python REPL) as background processes. The wait action blocks the tool call but can be interrupted by new user messages, preventing lock-up during long operations.

### 17. Event Hook System (gateway/hooks.py)
**What it is**: File-based plugin system for firing custom handlers at agent lifecycle points.
**Key files**: `gateway/hooks.py` (151 lines)
**How it works**: Hooks are directories in `~/.hermes/hooks/` containing `HOOK.yaml` (metadata: name, description, events list) and `handler.py` (async `handle(event_type, context)` function). Events: `gateway:startup`, `session:start`, `session:reset`, `agent:start`, `agent:step` (each tool-calling iteration), `agent:end`, `command:*` (wildcard for any slash command). The registry discovers hooks at startup, matches events including wildcards, and fires handlers with error isolation.
**Notable details**: Automatic sync/async handler detection. `agent:step` fires each iteration of the tool-calling loop with tool names and results — useful for logging, metrics, or custom side-effects. Errors are caught and logged, never blocking the pipeline.

### 18. Auxiliary Client Resolution Chain (agent/auxiliary_client.py)
**What it is**: Single resolution point for cheap/fast models used by side-tasks (compression, search summarization, vision).
**Key files**: `agent/auxiliary_client.py` (174 lines)
**How it works**: For text tasks: OpenRouter (OPENROUTER_API_KEY) → Gemini 3 Flash, then Nous Portal (OAuth auth.json) → Gemini 3 Flash, then custom endpoint (OPENAI_BASE_URL), then None. For vision tasks: same chain but excludes custom endpoints. A global flag `auxiliary_is_nous` tracks which provider was resolved for API parameter formatting differences.
**Notable details**: The caller never knows which backend they got — they just get an OpenAI-compatible client. `auxiliary_max_tokens_param()` handles the `max_tokens` vs `max_completion_tokens` naming difference between providers. This avoids coupling side-task models to the main model selection.

### 19. Prompt Caching (run_agent.py + agent/prompt_caching.py)
**What it is**: Anthropic-specific prompt caching with 4-breakpoint strategy for Claude models via OpenRouter.
**Key files**: `run_agent.py` (lines 216-218, 1857-1858), `agent/prompt_caching.py` (referenced)
**How it works**: Auto-detected for Claude models + OpenRouter base URL. Places cache breakpoints on the system prompt and last 3 messages (system_and_3 strategy). TTL is 5 minutes with 1.25x write cost and ~75% read cost reduction. Ephemeral messages (prefill, few-shot priming) are injected at API call time and never cached.
**Notable details**: The frozen memory snapshot pattern (memory loaded at session start, not updated mid-session) directly supports prompt caching by keeping the system prompt stable across turns.

### 20. Subagent Delegation (tools/delegate_tool.py)
**What it is**: Thread-based parallel subagent execution with context isolation and interrupt propagation.
**Key files**: `tools/delegate_tool.py` (458 lines)
**How it works**: Child agents get fresh conversations, own task IDs (isolated terminal sessions), restricted toolsets (recursive delegation, clarify, memory, send_message, and execute_code are blocked), and focused system prompts without context files (no SOUL.md/AGENTS.md pollution). Supports single-task and batch modes, with batch mode using ThreadPoolExecutor (max 3 concurrent workers). Parent registers children in `_active_children` list; interrupts cascade from parent to all children.
**Notable details**: No recursive delegation (depth limit = 2: parent → child only). Child stdout/stderr redirected to StringIO to prevent interleaved output. Results include status, summary, API call count, and duration. This is functional but less sophisticated than agno's team modes or letta-code's WebSocket-based remote execution.

## What Our Harness Should Adopt From hermes-agent

These are hermes-agent's distinctive contributions — features that represent genuine innovations or unusually strong implementations that Cubex should adopt. Ranked by impact.

### 1. Messaging Gateway as First-Class Deployment Target (HIGHEST)

**The idea**: The agent runs as a persistent bot on Telegram, Discord, Slack, and WhatsApp, not just as a CLI tool.

**Why this matters for Cubex**: No other harness in the collection treats messaging platforms as first-class deployment targets. Most are CLI-only or have HTTP API servers. A messaging gateway transforms the agent from a tool you run into a persistent assistant that lives on your server and reaches you wherever you are. Without this, Cubex is limited to terminal sessions that end when you close the window.

**How it works** (language-agnostic pseudocode/pattern description):

The architecture has four layers:

1. **Platform Adapters** (one per platform, implementing a base trait):
   - `start()` → connect to platform API, register event handlers
   - `on_message(raw)` → normalize to `MessageEvent { text, source, media_urls, msg_type }`
   - `send_text(chat_id, text)` → format for platform (Markdown escaping, length limits)
   - `send_media(chat_id, path, mime)` → upload to platform
   - `send_typing(chat_id)` → platform-specific typing indicator
   - Each adapter handles platform-specific concerns: Telegram Markdown V2 escaping, Discord thread support, Slack Socket Mode, WhatsApp Cloud API

2. **Session Management** (per `{platform, chat_id, user_id}` tuple):
   - Session store backed by SQLite + JSONL dual-write
   - Session entry: messages list, last_active timestamp, reset policy, background process list
   - Reset policies: `daily` (midnight), `idle` (configurable timeout), `both`, `none`
   - Sessions with active background processes are exempt from idle reset
   - Parent-child chaining for compressed sessions

3. **Interrupt-and-Requeue** pattern for handling messages during active processing:
   ```
   active_sessions: Map<session_key, CancellationToken>
   pending_messages: Map<session_key, MessageEvent>

   on_message(event):
     key = (event.platform, event.chat_id, event.user_id)
     if active_sessions.contains(key):
       active_sessions[key].cancel()  // interrupt current handler
       pending_messages[key] = event  // queue for after cleanup
       return

     active_sessions[key] = new CancellationToken()
     spawn_background:
       result = agent.chat(event.text, cancel_token=active_sessions[key])
       send_response(event.source, result)
       active_sessions.remove(key)
       if pending_messages.contains(key):
         queued = pending_messages.remove(key)
         on_message(queued)  // process queued message
   ```

4. **Delivery Routing** for flexible output targeting:
   - Delivery spec: `"origin"` | `"local"` | `"telegram"` | `"telegram:12345"`
   - Resolver maps specs to concrete (platform, chat_id) pairs
   - Deduplication across targets
   - Message size guarding: truncate at platform limit (4000 chars), save full to disk, send link

Configuration model: Platform configs per platform (API tokens, allowed users, home channel), gateway config wrapping all platform configs, session reset policy per platform. Deployed as systemd service via `install` command.

**Source**: `gateway/run.py` (~81KB), `gateway/session.py` (627 lines), `gateway/platforms/base.py` (754 lines), `gateway/platforms/telegram.py` (581 lines), `gateway/platforms/discord_adapter.py` (816 lines), `gateway/delivery.py` (341 lines)

### 2. Multi-Backend Terminal Execution with Per-Backend Security (VERY HIGH)

**The idea**: Five interchangeable execution backends (local, Docker, SSH, Singularity, Modal) behind one interface, with security hardening tuned per backend.

**Why this matters for Cubex**: A Rust agent harness needs sandboxed execution from day one. But "sandboxed" means different things in different contexts — local development wants speed and full env access, CI wants container isolation, HPC wants Singularity overlays, cloud wants Modal snapshots. A single interface with pluggable backends means the agent code doesn't care where commands run, and security policies can be tuned per backend (e.g., skip dangerous command approval in Docker because the container IS the sandbox).

**How it works** (language-agnostic pseudocode/pattern description):

```
trait ExecutionBackend:
  fn execute(command: str, cwd: str, timeout: Duration, stdin: Option<bytes>) -> ExecutionResult
  fn cleanup()

struct ExecutionResult:
  stdout: String
  stderr: String
  exit_code: i32
  timed_out: bool
```

Backend implementations:

1. **Local**: Spawns `$SHELL -lic command` in a new session (`setsid`). Background reader thread drains stdout. Interrupt via process group kill. Shell noise filtering (removes "bash: no job control").

2. **Docker**: Starts container once with hardening flags: `--read-only`, `--cap-drop ALL`, `--security-opt no-new-privileges`, `--pids-limit 256`, noexec tmpfs for `/tmp` and `/var/tmp`. Runs commands via `docker exec`. Two persistence modes: bind mounts to host directory (persistent) or tmpfs (ephemeral). Probes `--storage-opt` support at init and caches result.

3. **SSH**: Uses ControlMaster for 5-minute connection reuse via Unix sockets. `ControlPath=~/.hermes/ssh/{user}@{host}:{port}.sock`, `ControlMaster=auto`, `ControlPersist=300`. First command establishes connection; subsequent commands reuse socket (sub-100ms). Cleanup closes master connection.

4. **Singularity/Apptainer**: Persistent writable overlays. Automatic SIF image building from docker:// URLs with thread-locked caching. HPC-friendly scratch directory resolution (TERMINAL_SCRATCH_DIR → /scratch → ~/.hermes/sandboxes). `--containall --no-home` for isolation.

5. **Modal**: Cloud execution with filesystem snapshots. On cleanup: `sandbox.snapshot_filesystem()` → returns Image ID stored in `~/.hermes/modal_snapshots.json`. On next creation: restores from snapshot. Eliminates package reinstallation across sessions.

Factory pattern selects backend from config:
```
fn create_backend(config) -> Box<dyn ExecutionBackend>:
  match config.terminal_backend:
    "local" → LocalBackend::new(config)
    "docker" → DockerBackend::new(config)
    "ssh" → SSHBackend::new(config)
    "singularity" → SingularityBackend::new(config)
    "modal" → ModalBackend::new(config)
```

Dangerous command approval is skipped for Docker/Singularity/Modal (container IS the sandbox).

**Source**: `tools/environments/base.py` (90 lines), `tools/environments/local.py` (135 lines), `tools/environments/docker.py` (243 lines), `tools/environments/ssh.py` (148 lines), `tools/environments/singularity.py` (~250 lines), `tools/environments/modal.py` (168 lines), `tools/terminal_tool.py` (~1,200 lines)

### 3. RPC Code Execution Sandbox — Programmatic Tool Calling (HIGH)

**The idea**: Let the LLM write a Python script that calls agent tools via RPC, collapsing multiple tool-calling round-trips into a single inference call.

**Why this matters for Cubex**: Each LLM inference round-trip has latency (500ms-5s) and cost. When the agent needs to do 5 sequential operations (search, read, search, read, write), that's 5 round-trips where the LLM mostly just formats the next tool call. PTC lets it write a script that does all 5 in one shot. Only the final stdout enters the context — intermediate results are discarded, saving tokens. This is genuinely novel: no other harness in the collection has this pattern.

**How it works** (language-agnostic pseudocode/pattern description):

```
// Parent side (agent process)
fn execute_code(script: str) -> str:
  // 1. Generate tool stub module
  stubs = generate_tool_stubs(ALLOWED_TOOLS)  // 7 whitelisted tools

  // 2. Create Unix domain socket for RPC
  socket_path = temp_dir / "rpc.sock"
  listener = bind_unix_socket(socket_path)

  // 3. Spawn child process
  child = spawn(["python", "-c", script],
    env = strip_api_keys(current_env) + {"RPC_SOCKET": socket_path},
    inject_files = {"hermes_tools.py": stubs})

  // 4. RPC loop: handle tool calls from child
  tool_call_count = 0
  while child.is_running() and tool_call_count < MAX_CALLS:
    conn = listener.accept(timeout=TIMEOUT)
    request = json.decode(conn.read())  // {"tool": "read_file", "args": {"path": "..."}}
    result = tool_registry.dispatch(request.tool, request.args)
    conn.write(json.encode(result))
    tool_call_count += 1

  // 5. Return ONLY child stdout (not tool results)
  return child.stdout[:MAX_STDOUT]

// Child side (generated stubs)
fn web_search(query: str, limit: int = 5) -> dict:
  sock = connect(env["RPC_SOCKET"])
  sock.send(json.encode({"tool": "web_search", "args": {"query": query, "limit": limit}}))
  return json.decode(sock.recv())
```

Key constraints: 7-tool whitelist (web_search, web_extract, read_file, write_file, search_files, patch, terminal). 300s timeout. 50 max tool calls. 50KB stdout cap. API keys stripped from child environment. Linux/macOS only (UDS).

**Source**: `tools/code_execution_tool.py` (~400 lines)

### 4. Dangerous Command Approval with Container Exemption (HIGH)

**The idea**: Pattern-based dangerous command detection with four approval levels (once/session/always/deny) and automatic exemption for containerized backends.

**Why this matters for Cubex**: An agent that runs shell commands needs safety guardrails, but those guardrails shouldn't be the same in every context. `rm -rf /` in a local shell is catastrophic; in a Docker container with `--read-only` and tmpfs, it's harmless. The container exemption pattern — "if the execution environment IS a sandbox, skip approval" — is the right abstraction. The four-level approval (ephemeral once, session-scoped, permanent, deny) with timeout-to-deny default is also well-designed.

**How it works** (language-agnostic pseudocode/pattern description):

```
struct ApprovalState:
  pending: Map<SessionKey, ApprovalRequest>        // thread-safe
  session_approved: Map<SessionKey, Set<PatternKey>> // session-scoped
  permanent_approved: Set<PatternKey>               // persisted to config
  lock: Mutex

const DANGEROUS_PATTERNS: [(Regex, &str, &str)] = [
  (r"rm\s+(-[a-zA-Z]*[rR]|--recursive)", "rm_recursive", "recursive delete"),
  (r"chmod\s+777", "chmod_777", "world-writable permissions"),
  (r"DROP\s+(TABLE|DATABASE)", "sql_drop", "SQL drop"),
  (r":\(\)\{\s*:\|:&\s*\};:", "fork_bomb", "fork bomb"),
  (r"curl.*\|\s*(ba)?sh", "pipe_to_shell", "pipe to shell"),
  // ... 48 total patterns
]

fn check_dangerous(command, backend_type, session_key) -> ApprovalResult:
  // 1. Container bypass
  if backend_type in [Docker, Singularity, Modal]:
    return Approved

  // 2. Pattern matching (case-insensitive)
  match = find_first_match(command, DANGEROUS_PATTERNS)
  if match.is_none():
    return Approved

  // 3. Check cached approvals
  if session_approved[session_key].contains(match.pattern_key):
    return Approved
  if permanent_approved.contains(match.pattern_key):
    return Approved

  // 4. Prompt user (with 60s timeout, default deny)
  response = prompt_approval(command, match.description, timeout=60s)
  match response:
    Once → return Approved  // one-time only
    Session → session_approved[session_key].insert(match.pattern_key); return Approved
    Always → permanent_approved.insert(match.pattern_key); save_to_config(); return Approved
    Deny | Timeout → return Denied(match.description)
```

**Source**: `tools/approval.py` (299 lines), `tools/terminal_tool.py` (~1,200 lines)

### 5. Cron Scheduler with Multi-Target Delivery (MEDIUM-HIGH)

**The idea**: Scheduled task execution with flexible delivery routing (local file, messaging platform, specific chat) and file-based distributed locking.

**Why this matters for Cubex**: An agent that only works when you're talking to it is limited. Cron enables autonomous operation — daily reports, monitoring checks, scheduled data processing — with results delivered wherever the user is. The delivery routing abstraction means the agent can report results to Telegram, Discord, a local file, or a specific chat channel. No other harness in the collection has this capability.

**How it works** (language-agnostic pseudocode/pattern description):

```
struct CronJob:
  id: String
  schedule: CronExpression  // Standard Unix cron format
  prompt: String            // The task to execute
  delivery: Vec<DeliverySpec>  // Where to send results
  model: Option<String>    // Override default model
  toolsets: Option<Vec<String>>

fn tick():
  // 1. Acquire distributed lock (file-based, non-blocking)
  lock = try_acquire_file_lock("~/.hermes/cron/.tick.lock")
  if lock.is_none():
    return  // Another process is running tick

  // 2. Find due jobs
  due_jobs = jobs.filter(|j| j.schedule.is_due(now()))

  // 3. Execute each job in isolation
  for job in due_jobs:
    // Fresh config + env reload (supports runtime changes)
    config = reload_config()
    env = reload_env()

    // Fresh agent instance per job (no shared state)
    agent = AIAgent::new(model=job.model, toolsets=job.toolsets)
    result = agent.chat(job.prompt)

    // 4. Deliver to all targets
    for spec in job.delivery:
      match spec:
        "local" → save_to_file("~/.hermes/cron/output/{job.id}/{timestamp}")
        "origin" → send_to_original_chat(result)
        platform → send_to_home_channel(platform, result)
        "platform:chat_id" → send_to_specific_chat(platform, chat_id, result)

    // 5. Mirror to gateway session (if gateway running)
    gateway.mirror_to_session(job.source_session, result)

// File-based distributed lock (Unix: fcntl, Windows: msvcrt)
fn try_acquire_file_lock(path) -> Option<Lock>:
  fd = open(path, O_CREAT | O_WRONLY)
  if fcntl.flock(fd, LOCK_EX | LOCK_NB) == Ok:
    return Some(Lock(fd))
  return None  // Another process holds the lock
```

**Source**: `cron/scheduler.py` (340 lines), `cron/jobs.py` (383 lines), `tools/cronjob_tools.py` (referenced), `gateway/delivery.py` (341 lines)

### 6. RL Training Data Pipeline (MEDIUM-HIGH)

**The idea**: Integrated pipeline for generating agent training data with probabilistic toolset distributions, trajectory saving in ShareGPT format, and direct Atropos RL integration.

**Why this matters for Cubex**: Most agent harnesses consume LLM capabilities but never improve them. Hermes closes the loop — it can generate diverse training trajectories (by randomizing available tools per prompt), validate trajectory quality (scratchpad integrity checks), and feed them into RL training. A Rust harness with this capability could generate training data orders of magnitude faster than Python. Even without RL ambitions, the toolset distribution system creates useful training data diversity.

**How it works** (language-agnostic pseudocode/pattern description):

```
// Toolset probability distributions
struct ToolsetDistribution:
  name: String  // e.g., "research", "development", "science"
  toolsets: Map<String, f64>  // toolset_name → probability (0-100)

fn sample_toolsets(distribution: &ToolsetDistribution) -> Vec<String>:
  selected = []
  for (toolset, probability) in distribution.toolsets:
    if random() * 100.0 < probability:
      selected.push(toolset)
  if selected.is_empty():
    selected.push(highest_probability_toolset(distribution))
  return selected

// Batch processing with content-based resume
fn run_batch(dataset: &[Prompt], distribution: &ToolsetDistribution):
  checkpoint = load_checkpoint()  // Set<ContentHash>

  for prompt in dataset:
    hash = hash_content(prompt.text)
    if checkpoint.contains(hash):
      continue  // Already processed

    toolsets = sample_toolsets(distribution)
    agent = AIAgent::new(toolsets=toolsets, save_trajectories=true)
    result = agent.chat(prompt.text)

    // Save trajectory in ShareGPT format
    trajectory = convert_to_sharegpt(agent.messages)
    // Convert <REASONING_SCRATCHPAD> → <think> tags
    trajectory = convert_scratchpad_to_think(trajectory)

    if !has_incomplete_scratchpad(trajectory):
      append_jsonl("trajectory_samples.jsonl", trajectory)
    else:
      append_jsonl("failed_trajectories.jsonl", trajectory)

    checkpoint.insert(hash)
    save_checkpoint(checkpoint)

// Tool statistics extraction
fn extract_tool_stats(trajectory) -> Map<String, ToolStats>:
  stats = initialize_all_tools()  // Zero counts for schema consistency
  for message in trajectory:
    if message.role == "assistant" && message.tool_calls:
      for call in message.tool_calls:
        stats[call.name].count += 1
        if is_success(call.result):
          stats[call.name].success += 1
        else:
          stats[call.name].failure += 1
  return stats
```

**Source**: `batch_runner.py` (1,204 lines), `toolset_distributions.py` (350+ lines), `agent/trajectory.py` (57 lines), `environments/agent_loop.py` (~300 lines), `environments/hermes_base_env.py` (672 lines), `tools/rl_training_tool.py` (1,380 lines)

### 7. DM Pairing Authentication (MEDIUM-HIGH)

**The idea**: Cryptographic code-based user authentication for messaging bots, replacing static allowlists.

**Why this matters for Cubex**: If Cubex adds a messaging gateway, it needs secure user authentication that doesn't require editing config files. DM pairing is elegant: unknown user sends a message → receives a code → owner approves the code via CLI → user is permanently authorized. This is how consumer messaging bots should work, with proper security engineering (rate limiting, lockout, cryptographic randomness).

**How it works** (language-agnostic pseudocode/pattern description):

```
const ALPHABET: &str = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"  // No 0/O/1/I
const CODE_LEN: usize = 8
const CODE_TTL: Duration = 1 hour
const RATE_LIMIT: Duration = 10 minutes  // Per user
const MAX_ATTEMPTS: u32 = 5
const LOCKOUT_DURATION: Duration = 1 hour
const MAX_PENDING: usize = 3  // Per platform

struct PairingStore:
  pending: Map<Platform, Vec<PendingCode>>
  approved: Map<Platform, Set<UserId>>
  rate_limits: Map<(Platform, UserId), RateLimitState>

fn request_pairing(platform, user_id) -> Result<String, Error>:
  // Check lockout
  if is_locked_out(platform, user_id):
    return Err("Account locked")

  // Check rate limit
  if last_request_within(platform, user_id, RATE_LIMIT):
    return Err("Rate limited")

  // Check pending count
  if pending[platform].len() >= MAX_PENDING:
    evict_expired()
    if pending[platform].len() >= MAX_PENDING:
      return Err("Too many pending")

  // Generate code (cryptographic)
  code = (0..CODE_LEN).map(|_| ALPHABET[secrets_randint(0, ALPHABET.len())]).collect()

  pending[platform].push(PendingCode { code, user_id, expires: now() + CODE_TTL })
  update_rate_limit(platform, user_id)
  save_with_permissions(0o600)  // File permissions
  return Ok(code)

fn approve_pairing(platform, code) -> Result<UserId, Error>:
  entry = pending[platform].find(|p| p.code == code && !p.expired())
  if entry.is_none():
    increment_failed_attempts(platform, ...)
    return Err("Invalid or expired code")

  approved[platform].insert(entry.user_id)
  pending[platform].remove(entry)
  save_with_permissions(0o600)
  return Ok(entry.user_id)
```

**Source**: `gateway/pairing.py` (283 lines)

### 8. Human Delay Mode for Messaging (MEDIUM)

**The idea**: Configurable response pacing with random jitter between messages to simulate natural human conversation rhythm.

**Why this matters for Cubex**: Instant multi-message bot responses on messaging platforms feel robotic and can trigger platform rate limits or spam detection. Adding 800-2500ms of random delay between text messages and media attachments creates a natural conversational feel. Combined with continuous typing indicators, this makes the agent feel like it's "thinking and typing" rather than dumping output instantly. No other harness considers this.

**How it works** (language-agnostic pseudocode/pattern description):

```
enum DelayMode:
  Off         // Instant delivery
  Natural     // 800-2500ms random jitter
  Custom(min_ms: u64, max_ms: u64)

fn send_response(platform, chat_id, response):
  let delay = match config.delay_mode:
    Off → Duration::ZERO
    Natural → Duration::from_millis(random_uniform(800, 2500))
    Custom(min, max) → Duration::from_millis(random_uniform(min, max))

  // Send text first
  platform.send_text(chat_id, response.text)

  // Delay between text and media
  if response.has_media():
    sleep(delay)
    for media in response.media:
      platform.send_media(chat_id, media)
      sleep(delay)  // Delay between media items too

// Typing indicator runs concurrently (refreshes every 2s)
async fn keep_typing(platform, chat_id):
  loop:
    platform.send_typing(chat_id)
    sleep(2s)  // Platform typing expires after ~5s
```

**Source**: `gateway/platforms/base.py` (754 lines, human delay + typing indicator implementation)

### 9. Interrupt-and-Requeue Message Handling (MEDIUM)

**The idea**: When a user sends a new message while the agent is processing, interrupt the current operation and queue the new message for immediate processing after cleanup.

**Why this matters for Cubex**: Long tool-calling sequences (compiling code, running tests, browsing) can take minutes. If the user sends "stop, do something else instead", the agent needs to respond. Without interrupt-and-requeue, either the new message is lost or the user has to wait. This pattern ensures zero message loss while enabling responsive user interruption.

**How it works** (language-agnostic pseudocode/pattern description):

```
struct SessionManager:
  active: Map<SessionKey, CancellationToken>
  pending: Map<SessionKey, MessageEvent>

fn handle_incoming(event: MessageEvent):
  key = session_key(event)

  if active.contains(key):
    // Interrupt current processing
    active[key].cancel()
    // Queue new message
    pending[key] = event
    return

  // Start processing
  let token = CancellationToken::new()
  active[key] = token

  spawn_async:
    result = process_with_cancellation(event, token)
    if !token.is_cancelled():
      send_response(event.source, result)

    active.remove(key)

    // Process any queued message
    if let Some(queued) = pending.remove(key):
      handle_incoming(queued)  // Recursive, handles chains of interrupts
```

The cancellation token is checked at each tool-calling iteration in the agent loop, at sleep intervals during retries, and propagated to child subagents.

**Source**: `gateway/platforms/base.py` (754 lines), `run_agent.py` (interrupt mechanism at lines 191-196, 1798-1802)

### 10. Skills Guard with Trust-Level Policy Matrix (MEDIUM)

**The idea**: Security scanning for skill installation with different policies based on source trust level.

**Why this matters for Cubex**: An extension system that allows community contributions needs graduated security policies. Builtin skills ship with the product and need no scanning. Trusted sources (known orgs) can tolerate minor warnings. Community skills must be strict. The trust-level matrix is the right abstraction — it encodes security policy as data rather than hard-coded logic.

**How it works** (language-agnostic pseudocode/pattern description):

```
enum TrustLevel: Builtin, Trusted, Community, AgentCreated

enum Verdict: Safe, Caution, Dangerous

// Policy matrix: (trust_level, verdict) → action
const INSTALL_POLICY: Map<(TrustLevel, Verdict), Action> = {
  (Builtin, Safe)     → Allow,    (Builtin, Caution)     → Allow,    (Builtin, Dangerous)  → Allow,
  (Trusted, Safe)     → Allow,    (Trusted, Caution)     → Allow,    (Trusted, Dangerous)  → Block,
  (Community, Safe)   → Allow,    (Community, Caution)   → Block,    (Community, Dangerous) → Block,
  (AgentCreated, Safe)→ Allow,    (AgentCreated, Caution)→ Block,    (AgentCreated, Dangerous)→ Block,
}

// 18+ threat categories with regex patterns
const THREAT_PATTERNS: [(Category, Regex, Severity)] = [
  // Exfiltration (10 patterns)
  (Exfil, r"curl.*\$\{?(SECRET|TOKEN|KEY)", Critical),
  (Exfil, r"base64.*\|\s*env", Critical),
  (Exfil, r"dig.*\$\{?\w+\}", High),  // DNS exfil
  (Exfil, r"printenv|os\.environ|process\.env", Medium),
  // Injection (5 patterns)
  (Injection, r"ignore previous instructions", High),
  (Injection, r"you are now", Medium),
  // Destructive (3 patterns)
  (Destructive, r"rm\s+-rf\s+/", Critical),
  // Persistence (3 patterns)
  (Persistence, r"\.ssh/authorized_keys", Critical),
  // Obfuscation (2 patterns)
  (Obfuscation, r"base64\s+-d.*\|\s*(ba)?sh", High),
]

fn scan_skill(content: &str, trust: TrustLevel) -> InstallDecision:
  findings = []
  for (category, pattern, severity) in THREAT_PATTERNS:
    for match in pattern.find_all(content):
      findings.push(Finding { category, severity, match, line })

  verdict = if findings.any(|f| f.severity == Critical): Dangerous
            elif findings.any(|f| f.severity >= Medium): Caution
            else: Safe

  return INSTALL_POLICY[(trust, verdict)]
```

**Source**: `tools/skills_guard.py` (1,077 lines), `tools/skills_hub.py` (1,177 lines)

## Summary

hermes-agent's gifts to Cubex, in order of impact:

1. **Messaging Gateway Architecture** — The only harness that treats messaging platforms (Telegram, Discord, Slack, WhatsApp) as first-class deployment targets with session management, interrupt handling, and delivery routing
2. **Multi-Backend Terminal Execution** — Five interchangeable backends (Local, Docker, SSH, Singularity, Modal) with per-backend security hardening and the key insight that containerized backends should bypass command approval
3. **RPC Code Execution (Programmatic Tool Calling)** — Let the LLM write scripts that call tools via Unix domain socket RPC, collapsing multiple inference round-trips into one and keeping intermediate results out of context
4. **Dangerous Command Approval with Container Exemption** — 48-pattern detection with four approval levels, thread-safe session state, and automatic exemption for sandboxed backends
5. **Cron Scheduler with Multi-Target Delivery** — Scheduled autonomous task execution with flexible delivery routing to any connected messaging platform
6. **RL Training Data Pipeline** — Probabilistic toolset distributions for training data diversity, ShareGPT trajectory saving, content-based batch resume, and direct Atropos RL integration
7. **DM Pairing Authentication** — Cryptographic code-based user auth for messaging bots with rate limiting, lockout, and OWASP-aligned security
8. **Human Delay Mode** — Configurable response pacing (800-2500ms jitter) with continuous typing indicators for natural conversational rhythm on messaging platforms
9. **Interrupt-and-Requeue** — Zero-loss message handling that interrupts current processing and queues new messages for immediate follow-up
10. **Skills Guard Trust-Level Policy Matrix** — Graduated security scanning with different policies for builtin, trusted, and community skill sources
