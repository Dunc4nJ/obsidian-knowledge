# codex Findings (Deep Dive)

## Scope and Method

This document synthesizes a deep exploration of the `codex` repository at `/data/projects/cubex/codex/`. Three parallel exploration agents analyzed the ~420K LOC Rust codebase (67 workspace crates):

- **Agent A (Core Execution Architecture)**: Analyzed the main agent loop (`core/src/codex.rs`), protocol wire format (`protocol/`), session state persistence (`state/`), context management and compaction (`core/src/compact.rs`), app server with v2 JSON-RPC (`app-server/`, `app-server-protocol/`), headless execution (`exec/`), TUI rendering (`tui/`), and backend client (`backend-client/`).

- **Agent B (Security and Sandboxing)**: Analyzed the execution policy engine (`execpolicy/`), command safety classification (`shell-command/`), Linux sandbox with seccomp+Landlock+bubblewrap (`linux-sandbox/`), Windows sandbox with restricted tokens+ACLs (`windows-sandbox-rs/`), process hardening (`process-hardening/`), network proxy with policy enforcement (`network-proxy/`), secret management (`secrets/`), and shell escalation protocol (`shell-escalation/`).

- **Agent C (Extensions and Infrastructure)**: Analyzed the skills system (`skills/`), hooks system (`hooks/`), MCP server+client (`mcp-server/`, `rmcp-client/`), config system (`config/`), file search (`file-search/`), patch application (`apply-patch/`), OpenTelemetry observability (`otel/`), login/auth (`login/`, `keyring-store/`), cloud tasks (`cloud-tasks/`), local model support (`ollama/`, `lmstudio/`), and Responses API proxy (`responses-api-proxy/`).

Primary sources reviewed: `README.md`, `AGENTS.md`, `codex-rs/README.md`, `codex-rs/Cargo.toml`, and ~80 source files across all major crates.

## README Alignment: What Is Unique About This Project

The README claims Codex CLI is "a coding agent from OpenAI that runs locally on your computer" with CLI-first design, multi-mode sandboxing, and integration with ChatGPT plans.

1. **"Runs locally"**: Verified. The entire agent loop runs in-process (`core/src/codex.rs:4681-5044`), with all tool execution happening on the local machine. The only network calls are to LLM APIs.

2. **"CLI-first with native executable"**: Verified. The Rust workspace produces a standalone binary (`cli/`, `tui/`, `exec/` crates) with zero runtime dependencies. MUSL-linked for Linux portability (`Cargo.toml:354-359`).

3. **"Multi-mode sandboxing"**: Verified and understated. The sandboxing is extraordinarily thorough: 6 dedicated security crates spanning seccomp BPF, Landlock, bubblewrap, restricted Windows tokens, ACL manipulation, macOS Seatbelt, process hardening, network proxy enforcement, and shell escalation interception. This is the deepest sandbox implementation of any open-source agent harness.

4. **"ChatGPT plan integration"**: Verified. `codex-rs/login/` implements device code and PKCE OAuth flows, `backend-client/` talks to ChatGPT/Codex backend APIs, and `chatgpt/` handles ChatGPT-specific routing.

Codex's genuine identity is a **production-hardened CLI coding agent with industry-leading security sandboxing**, built as a Rust library-first architecture that supports multiple frontends (TUI, headless exec, app server, IDE extension) via a clean submission/event queue abstraction.

## Architecture Overview

Codex is a Rust workspace of 67 crates built around a core library (`codex-core`) that implements the full agent loop. Clients interact through a Submission Queue / Event Queue (SQ/EQ) pattern: they push `Op` submissions and receive `EventMsg` events asynchronously. The core manages session state, context compaction, tool execution, MCP connections, and security policy enforcement. Multiple frontends consume the same core: an interactive TUI (`codex-tui`), a headless executor (`codex-exec`), a WebSocket/HTTP app server (`codex-app-server`), and an MCP server mode (`codex-mcp-server`).

**Module/directory map**:
- `core/` - Agent loop, session, context management, tool orchestration (~45K LOC)
- `protocol/` - Wire format: Op submissions, EventMsg events (~3.5K LOC)
- `tui/` - Ratatui terminal UI (~42K LOC)
- `exec/` - Headless non-interactive mode (~3.2K LOC)
- `app-server/` + `app-server-protocol/` - JSON-RPC v2 WebSocket server (~22K LOC)
- `execpolicy/` - Command classification engine (~1.8K LOC)
- `shell-command/` - Command safety analysis with tree-sitter (~5.5K LOC)
- `linux-sandbox/` - Seccomp + Landlock + bubblewrap (~2.3K LOC)
- `windows-sandbox-rs/` - Restricted tokens + ACLs (~7K LOC)
- `network-proxy/` - Network policy proxy (~7.9K LOC)
- `process-hardening/` - Pre-main hardening (~190 LOC)
- `shell-escalation/` - Exec interception protocol (~1.6K LOC)
- `config/` - Layered TOML config system
- `state/` - SQLite session metadata mirror
- `skills/`, `hooks/`, `mcp-server/`, `rmcp-client/` - Extension systems
- `login/`, `keyring-store/`, `secrets/` - Auth and credential management
- `ollama/`, `lmstudio/` - Local model support
- `otel/` - OpenTelemetry observability

Key abstractions: `Session` holds all mutable state behind `Arc<Mutex<SessionState>>`. `TurnContext` freezes per-turn configuration as an immutable `Arc`. `Policy` in `execpolicy` classifies commands via indexed prefix rules. `SandboxPolicy` controls filesystem/network restrictions. The SQ/EQ channels decouple any number of clients from the core engine.

## Feature Analysis

### 1. Cross-Platform Multi-Layer Sandbox (`linux-sandbox/`, `windows-sandbox-rs/`, `process-hardening/`)

**What it is**: A defense-in-depth sandboxing system that uses platform-native kernel mechanisms to restrict agent-spawned processes across Linux, Windows, and macOS.

**Key files**: `linux-sandbox/src/landlock.rs` (~160 LOC), `linux-sandbox/src/linux_run_main.rs` (~2K LOC), `windows-sandbox-rs/src/token.rs`, `windows-sandbox-rs/src/acl.rs`, `windows-sandbox-rs/src/cap.rs` (total ~7K LOC), `process-hardening/src/lib.rs` (~190 LOC)

**How it works**: On Linux, commands run inside bubblewrap (vendored) with a read-only root filesystem overlay. Writable paths are computed from `SandboxPolicy::get_writable_roots_with_cwd()` and mounted with write access. Before exec, the parent thread installs a seccomp BPF filter that intercepts socket/connect/sendto syscalls at the kernel level, and sets `PR_SET_NO_NEW_PRIVS` to prevent setuid escalation. Two seccomp modes exist: `Restricted` (block all network except AF_UNIX) and `ProxyRouted` (only allow AF_INET/AF_INET6 for the proxy bridge, block AF_UNIX). On Windows, a restricted token is created from the current process token with dangerous privileges and groups removed, deny-write ACEs are applied to all paths except writable roots, and capability SIDs provide per-workspace isolation. Processes are spawned via `CreateProcessAsUserW()` with the restricted token. On macOS, Seatbelt profiles restrict filesystem and network access. Process hardening runs before `main()` via `#[ctor::ctor]`: `PR_SET_DUMPABLE(0)` on Linux, `ptrace(PT_DENY_ATTACH)` on macOS, `setrlimit(RLIMIT_CORE, 0)` everywhere, and LD_*/DYLD_* environment variable clearing.

**Notable details**: Three sandbox modes map to different restriction levels: `ReadOnly` (full FS read-only, no network), `WorkspaceWrite` (CWD + temp writable, network proxied), `DangerFullAccess` (no restrictions). The seccomp filter specifically allows `recvfrom` even in restricted mode because tools like `cargo clippy` use socketpair + child processes internally. Managed-network sessions enforce seccomp even for `DangerFullAccess` mode (`landlock.rs:96-100`). The Windows sandbox uses capability SIDs for workspace-level isolation, preventing sandbox escape to other project directories.

### 2. Tree-Sitter-Based Bash Command Safety Analysis (`shell-command/`)

**What it is**: A command safety classifier that parses bash scripts into ASTs using tree-sitter to determine if compound shell expressions are safe to auto-execute.

**Key files**: `shell-command/src/command_safety/is_safe_command.rs` (~600 LOC), `shell-command/src/bash.rs` (~600 LOC), `shell-command/src/command_safety/is_dangerous_command.rs` (~135 LOC)

**How it works**: For simple commands, a whitelist check identifies known-safe programs (cat, echo, grep, ls, etc.) with per-command option validation. For compound shell expressions like `bash -lc "git status && ls -1"`, tree-sitter-bash parses the script into an AST. The parser extracts individual commands joined by safe operators (`&&`, `||`, `;`, `|`). Any syntactic construct that could hide side effects is rejected: parentheses (subshells), redirections (`>`, `<`, `>>`), command/variable substitution (`$(...)`, backticks, `$VAR`), and control flow (if/while/for). If every individual command in the decomposed sequence is itself a known-safe command, the entire expression is approved. Git commands receive special handling: the parser identifies global options that appear before subcommands (`-C`, `-c`, `--git-dir`) and skips them to find the true subcommand. Dangerous git options like `-c core.pager=<script>`, `--exec`, and `--textconv` are blocked even when the subcommand is safe.

**Notable details**: `find` is conditionally safe but blocks `-exec`, `-delete`, `-fls`, `-fprint`, `-ok`, `-okdir`. `base64` blocks `-o`/`--output` (file writing). `sed` is only safe for the exact pattern `sed -n {N,M}p` (line printing). `sudo` recursively classifies the subcommand. Windows-specific safe commands are handled separately. Zsh is aliased to bash for classification purposes.

### 3. Execution Policy Engine (`execpolicy/`)

**What it is**: A rules-based command classification system with indexed prefix matching, pattern alternatives, and multi-rule aggregation for determining if commands can auto-run, need user approval, or are forbidden.

**Key files**: `execpolicy/src/policy.rs` (~200 LOC), `execpolicy/src/rule.rs` (~300 LOC), `execpolicy/src/decision.rs` (~50 LOC), `execpolicy/src/parser.rs` (~200 LOC) (total ~1.8K LOC)

**How it works**: Rules are indexed in a `MultiMap<String, RuleRef>` keyed by the first token of the command (e.g., "git", "python3"). Each `PrefixRule` contains a `PrefixPattern` with a fixed first token and a `rest` sequence of `PatternToken`s that can be literal strings or alternatives (e.g., `["git", "[status|log|diff]"]`). When evaluating a command, the engine looks up all rules matching the first token, then checks if the command's remaining tokens match each rule's pattern. Multiple matching rules are aggregated by taking the maximum decision: `Forbidden > Prompt > Allow`. If no explicit rule matches, a configurable heuristics fallback function provides default classification. Network rules operate separately, specifying allow/deny per protocol (http, https, socks5_tcp, socks5_udp) and normalized host.

**Notable details**: Rules support host executable resolution via `HashMap<String, Arc<[AbsolutePathBuf]>>` to handle commands invoked by full path. The parser loads rules from `.rules` files as a DSL. The `Evaluation` return type includes both the aggregate decision and the list of matched rules with details, enabling explainable decisions.

### 4. Network Proxy with Policy Enforcement (`network-proxy/`)

**What it is**: A centralized network access control system that forces all agent-spawned network traffic through an HTTP/SOCKS5 proxy with domain-level policy enforcement.

**Key files**: `network-proxy/src/network_policy.rs`, `network-proxy/src/http_proxy.rs`, `network-proxy/src/socks5.rs`, `network-proxy/src/mitm.rs`, `network-proxy/src/state.rs` (total ~7.9K LOC)

**How it works**: When network restrictions are active, seccomp blocks direct socket access at the kernel level. All network traffic is forced through a local proxy. The `NetworkPolicyDecider` evaluates each connection request against execution policy network rules, sandbox mode, and session-accumulated allowances. Each request carries protocol, normalized host, port, originating command, and exec policy hints. Decisions are: `Deny` (block), `Ask` (prompt user). The proxy supports HTTP/HTTPS (with MITM certificate generation for inspection) and SOCKS5 (TCP and UDP). Already-allowed hosts during a session are tracked in `NetworkProxyState` to avoid repeated prompts.

**Notable details**: The two seccomp modes create different network surfaces: `Restricted` blocks all sockets except AF_UNIX (for local IPC), while `ProxyRouted` allows AF_INET/AF_INET6 (to reach the proxy bridge) but blocks AF_UNIX (preventing bypass). MITM certificate generation enables HTTPS traffic inspection when policy requires domain-level decisions.

### 5. Shell Escalation Protocol (`shell-escalation/`)

**What it is**: A Unix socket-based protocol for intercepting `exec()` calls in child shells, allowing the parent Codex process to approve, deny, or re-sandbox commands at execution time.

**Key files**: `shell-escalation/src/lib.rs` (~30 LOC), `shell-escalation/src/unix/` (~1.6K LOC)

**How it works**: The parent Codex process starts an `EscalateServer` listening on a Unix socket. Child shells inherit the `CODEX_ESCALATE_SOCKET` environment variable pointing to this socket. An exec wrapper in the child process intercepts `exec()` calls and sends an `EscalateRequest` (file path, argv, workdir, env) to the server. The server evaluates the request against execution policy and sandbox policy, then responds with `Run` (continue exec directly), `Escalate` (re-execute under sandbox with specified permissions: `Unsandboxed`, `TurnDefault`, or explicit `Permissions`), or `Deny` (block with reason). Each escalation request gets its own response socket, allowing concurrent requests from multiple shells without race conditions.

**Notable details**: The escalation system provides a fourth security layer beyond execution policy, sandbox, and network proxy. It intercepts the actual `exec()` syscall rather than relying on command-line parsing, catching commands that would bypass shell-level analysis. The `EscalationExecution` type carries the full execution context (sandbox permissions, turn configuration) enabling precise per-command sandboxing decisions.

### 6. SQ/EQ Architecture (Submission Queue / Event Queue) (`core/`, `protocol/`)

**What it is**: An async decoupling pattern where any number of clients push `Op` submissions through a bounded channel and receive `EventMsg` events through an unbounded channel, enabling multiple frontends to share a single agent core.

**Key files**: `core/src/codex.rs:294-300` (Codex struct), `protocol/src/protocol.rs` (~3.5K LOC)

**How it works**: The `Codex` struct exposes `tx_sub: Sender<Op>` (bounded, capacity 512) and `rx_event: Receiver<EventMsg>` (unbounded). Clients (TUI, exec, app server, IDE extension) submit operations like `UserTurn`, `ExecApproval`, `PatchApproval`, `Interrupt`, or `OverrideTurnContext`. The core processes submissions sequentially and emits events: `TurnStarted`, `AgentMessageDelta` (streaming), `ExecApprovalRequest`, `ApplyPatchApprovalRequest`, `ContextCompacted`, `TurnComplete`, `Error`, and ~30 other event types. An `agent_status` watch channel broadcasts `AgentStatus` (Idle, Active, Transitioning, Error) for UI state synchronization. The bounded submission queue provides backpressure (capacity 512 prevents runaway buffering). The unbounded event queue assumes downstream consumers are fast enough.

**Notable details**: `Op::UserTurn` carries the complete turn context: CWD, approval/sandbox policies, model, reasoning effort, collaboration mode. This means every turn can have different security policies, enabling per-turn sandbox escalation/de-escalation. `Op::OverrideTurnContext` changes defaults (model, CWD, effort, personality) without starting a turn. The protocol includes realtime audio streaming ops (`RealtimeConversation*`) and MCP elicitation responses (`ResolveElicitation`), showing the breadth of the event model.

### 7. Mid-Turn Inline Auto-Compaction (`core/src/compact.rs`)

**What it is**: A context compaction system with three modes (pre-turn, mid-turn, manual) where mid-turn compaction happens during an active turn and injects the summary at a model-trained injection point.

**Key files**: `core/src/compact.rs` (~1K LOC), `core/templates/compact/prompt.md`, `core/templates/compact/summary_prefix.md`

**How it works**: Three compaction modes serve different scenarios. Pre-turn compaction runs before the model sees new input, proactively summarizing if the estimated context (including pending updates like git diffs) would exceed the threshold. Mid-turn compaction triggers when token count exceeds `auto_compact_token_limit` (typically 75% of context window) AND the model needs a follow-up turn. It uses `InitialContextInjection::BeforeLastUserMessage` to inject the summary just above the last real user message in the replacement history — the model is trained to expect this exact layout. Manual compaction (via `/compact` command) uses `DoNotInject`, clearing reference context so the next turn fully reinjects initial context. All modes send history to the model with a summarization prompt, capped at `COMPACT_USER_MESSAGE_MAX_TOKENS = 20,000`. Retries use exponential backoff for stream errors. If context still exceeds the window after summarization, oldest history items are removed sequentially.

**Notable details**: The `InitialContextInjection` enum (`BeforeLastUserMessage` vs `DoNotInject`) controls whether compaction replacement includes initial context (git info, environment). Mid-turn compaction must inject because the model is mid-conversation; pre-turn/manual can defer because the next turn will inject anyway. Reference context (git state, environment) is cached to avoid recomputation since git state changes rarely. Token counting uses `approx_token_count()` which estimates based on the model's truncation policy.

### 8. App Server with v2 JSON-RPC Protocol (`app-server/`, `app-server-protocol/`)

**What it is**: A full production server layer over the core library providing WebSocket/HTTP JSON-RPC transport, thread lifecycle management, and a typed protocol with v1/v2 compatibility.

**Key files**: `app-server/src/transport.rs` (~1.2K LOC), `app-server/src/codex_message_processor.rs` (~8.5K LOC), `app-server/src/thread_state.rs` (~460 LOC), `app-server-protocol/src/protocol/v2.rs` (~4.6K LOC) (total ~22K LOC)

**How it works**: The server exposes both REST endpoints (`/api/codex/tasks/*`, `/wham/tasks/*`) and WebSocket JSON-RPC for streaming. `codex_message_processor.rs` translates between the v2 wire format and core `Op`/`EventMsg` types. Thread state tracks per-conversation `CodexThread` instances with queued events. The v2 protocol uses `v2_enum_from_core!()` macros for bidirectional type conversion between camelCase wire format and snake_case core types. RPC methods follow `<resource>/<method>` naming (e.g., `thread/read`, `app/list`). The protocol supports thread creation, resume, fork, deletion, configuration read/write/list, and experimental API gating via `#[experimental("method/or/field")]` attributes. Client-to-server payloads use `*Params` suffix with `#[ts(optional = nullable)]` for optional fields. Responses use `*Response` suffix. TypeScript types are auto-generated via `ts-rs` with `#[ts(export_to = "v2/")]`.

**Notable details**: Config RPC payloads intentionally use snake_case (mirroring config.toml keys) rather than the default camelCase. Experimental API surface uses derive macros for field-level gating. List methods implement cursor pagination by default. The server handles realtime audio, tool approvals, and MCP elicitation — the full breadth of the core protocol, not just text chat.

### 9. Layered Config System (`config/`)

**What it is**: A multi-source TOML configuration system with recursive merge, fingerprinting for change detection, and managed/MDM config support.

**Key files**: `config/src/lib.rs`, `config/src/state.rs`, `config/src/merge.rs`, `config/src/cloud_requirements.rs`

**How it works**: Configuration is loaded from a stack of sources in precedence order: CLI overrides (`-c`), environment variables, project-level (`.codex/config.toml`), user home (`~/.codex/config.toml`), system config, and managed Desktop/MDM config. Each layer is a `ConfigLayerEntry` with source name, TOML value, raw TOML string, version hash, and optional disabled reason. Merge uses recursive table merging where overlays take precedence. Each layer is fingerprinted with SHA256 for change detection. Cloud requirements can inject sandbox/network constraints from managed environments.

**Notable details**: The config schema is auto-generated (`just write-config-schema`) from Rust types. Requirements from cloud/MDM can enforce minimum sandbox levels, overriding local config. Config changes are validated before application.

### 10. Hooks System (`hooks/`)

**What it is**: An async event-driven hook system with abort semantics for integrating external tools with the agent lifecycle.

**Key files**: `hooks/src/lib.rs`, `hooks/src/types.rs` (~285 LOC total)

**How it works**: Two hook events exist: `AfterAgent` (triggered after turns, carries thread_id, turn_id, messages) and `AfterToolUse` (triggered after tool execution, carries tool name, kind, input, success, duration, whether mutating, sandbox info). Hooks are registered as `Arc`-wrapped async closures. Dispatch is deterministic (ordered). `HookResult` has three variants: `Success`, `FailedContinue` (continue to next hook), and `FailedAbort` (stop subsequent hooks). Payloads are serialized as structured JSON with RFC3339 timestamps. Legacy `notify_argv` format is translated to the new hook system.

**Notable details**: The `AfterToolUse` hook receives tool execution metadata including whether the tool was mutating and what sandbox was applied, enabling external security audit tools.

### 11. MCP Server and Client (`mcp-server/`, `rmcp-client/`)

**What it is**: Bidirectional MCP support — Codex can both connect to external MCP servers as a client and expose itself as an MCP server for other agents to use.

**Key files**: `mcp-server/src/lib.rs` (~227 LOC), `mcp-server/src/message_processor.rs`, `mcp-server/src/codex_tool_runner.rs`, `rmcp-client/src/rmcp_client.rs`, `rmcp-client/src/oauth.rs`

**How it works**: As MCP server, Codex exposes `codex_tool_call` and `codex_tool_call_reply` tools over stdio JSON-RPC. Tool calls create full Codex threads, streaming all protocol events as notifications, with the final result including a `threadId` for state tracking. As MCP client, three transport types are supported: `ChildProcess` (stdio), `StreamableHttp` (HTTP), and `StreamableHttpWithOAuth` (HTTP+OAuth2 with token persistence). The client manages process group lifecycle on Unix for cleanup.

**Notable details**: The MCP server maps request IDs to Codex thread IDs bidirectionally, enabling client-side state management across tool calls. OAuth token persistence enables reconnection without re-authentication.

### 12. File Search with Nucleo Fuzzy Matching (`file-search/`)

**What it is**: A multi-threaded real-time file search using Nucleo fuzzy matching with gitignore-aware walking and debounced streaming updates.

**Key files**: `file-search/src/lib.rs` (~970 LOC)

**How it works**: Uses the `ignore` crate for gitignore-aware file walking and `nucleo` (from the Helix editor project) for fuzzy matching. Crossbeam channels handle concurrent I/O. A `SessionReporter` trait receives debounced `FileSearchSnapshot` updates and completion events. Match results include Nucleo relevance scores and character match position indices for highlighting.

**Notable details**: Uses Nucleo (the fuzzy matcher from the Helix editor) rather than BM25, optimizing for interactive speed over search relevance. Path exclusion patterns are configurable.

### 13. Secret Detection and Sanitization (`secrets/`)

**What it is**: Regex-based secret detection and redaction for output streams, with encrypted storage and OS keyring integration.

**Key files**: `secrets/src/` (~300 LOC)

**How it works**: A sanitizer scans output for patterns: OpenAI keys (`sk-[A-Za-z0-9]{20,}`), AWS access keys (`AKIA[0-9A-Z]{16}`), bearer tokens, and generic key/token/secret/password assignments. Matched patterns are replaced with `[REDACTED_SECRET]`. Secrets are stored encrypted in `~/.codex/secrets/` with OS keyring integration (macOS Keychain, Windows Credential Manager, Linux Secret Service). Secrets are scoped by environment (per-repo or per-cwd hash).

**Notable details**: Environment-scoped secrets use SHA256 of `codex_home` path for bucketing, enabling multiple projects with isolated credentials.

### 14. Responses API Proxy (`responses-api-proxy/`)

**What it is**: A minimal credential-isolating HTTP proxy for the OpenAI Responses API that reads auth from stdin and binds to an ephemeral port.

**Key files**: `responses-api-proxy/src/` (~500 LOC)

**How it works**: Auth headers are read from stdin (never exposed on CLI), ephemeral port binding avoids conflicts, and server info (port, PID) is written as JSON for discovery by other tools. No timeout on upstream to preserve streaming. Built with `tiny_http` + `reqwest` + `zeroize` (for credential memory clearing).

**Notable details**: The separate process architecture means credentials are never in the main agent's address space. The `zeroize` dependency ensures auth tokens are cleared from memory after use.

### 15. Apply Patch with Fuzzy Matching (`apply-patch/`)

**What it is**: A unified diff parser with fuzzy context matching using the `similar` crate for robust patch application.

**Key files**: `apply-patch/src/lib.rs` (~1K LOC), `apply-patch/src/parser.rs`, `apply-patch/src/seek_sequence.rs`

**How it works**: Parses unified diff format, extracting hunks with line numbers. Uses `similar` (textdiff) for context-aware matching when exact line numbers don't match. A seek sequence algorithm handles line offset drift gracefully. Supports heredoc-wrapped patches. Can run as a standalone binary (`codex-apply-patch`).

**Notable details**: The seek sequence matching allows patches to apply even when files have been modified since the diff was generated, increasing reliability of agent-generated patches.

### 16. Process Hardening (`process-hardening/`)

**What it is**: Pre-main process hardening applied via `#[ctor::ctor]` before any application code runs.

**Key files**: `process-hardening/src/lib.rs` (~190 LOC)

**How it works**: On Linux: `prctl(PR_SET_DUMPABLE, 0)` to disable ptrace attach, `setrlimit(RLIMIT_CORE, 0)` to disable core dumps, clear all `LD_*` environment variables. On macOS: `ptrace(PT_DENY_ATTACH)` to prevent debugger attachment, core dump disable, clear all `DYLD_*` variables. On BSD: core dump disable and LD_* clearing. Process exits with specific error codes if hardening fails (5=prctl, 6=ptrace, 7=setrlimit).

**Notable details**: Even though official Codex releases are MUSL-linked (which ignores LD_PRELOAD), the variables are still cleared as defense-in-depth. Non-UTF-8 environment variable keys are properly handled in the filtering.

### 17. OpenTelemetry Observability (`otel/`)

**What it is**: Structured observability with metrics, distributed tracing, and per-model/per-conversation tracking.

**Key files**: `otel/src/lib.rs` (~250 LOC), `otel/src/metrics/`, `otel/src/traces/`, `otel/src/config.rs`

**How it works**: OtelManager coordinates tracing and metrics. Event metadata carries conversation_id, auth_mode, account_id, originator, model, slug. Metrics include timing, runtime stats, and model-specific tracking. Trace spans carry distributed context for cross-service correlation.

**Notable details**: User prompt logging is selectively sampled (`log_user_prompts` flag). Service names are sanitized for metric tag validity. Terminal type detection is included in metadata.

## What Our Harness Should Adopt From codex

These are codex's distinctive contributions — features that represent genuine innovations or unusually strong implementations that Cubex should adopt. Ranked by impact.

### 1. Cross-Platform Kernel-Level Sandbox Architecture (HIGHEST)

**The idea**: A defense-in-depth sandboxing system that uses platform-native kernel mechanisms (seccomp BPF, Landlock, bubblewrap, Windows restricted tokens, macOS Seatbelt) to enforce filesystem and network restrictions on agent-spawned processes.

**Why this matters for Cubex**: Cubex's #1 priority is security/safety. Most agent harnesses either have no sandboxing or rely on OS-level containers. Codex demonstrates that in-process, per-command sandboxing is achievable across all three major platforms without requiring Docker or VMs. Without this, any agent that runs shell commands is fundamentally unsafe — a single malicious or misguided command can exfiltrate data, modify system files, or establish network connections. This is the single most impactful security feature in any harness we've studied.

**How it works** (language-agnostic pattern):

```
Data model:
  SandboxMode = ReadOnly | WorkspaceWrite | DangerFullAccess
  SandboxPolicy = {
    mode: SandboxMode,
    writable_roots: Vec<{root: Path, read_only_subpaths: Vec<Path>}>,
    // .git, .agents, .codex are always read-only subpaths
  }

  NetworkSeccompMode = Restricted | ProxyRouted

Linux sandbox algorithm:
  1. Compute writable_roots from policy + CWD
  2. Fork a thread for the child process
  3. On the child thread (before exec):
     a. Set PR_SET_NO_NEW_PRIVS (blocks setuid escalation)
     b. Install seccomp BPF filter:
        - Restricted mode: block connect/accept/bind/listen/sendto/sendmmsg/
          recvmmsg/getsockopt/setsockopt; allow socket() only for AF_UNIX;
          block io_uring_* and ptrace
        - ProxyRouted mode: allow socket() only for AF_INET/AF_INET6 (to
          reach proxy bridge); block AF_UNIX socketpair (prevent bypass);
          block io_uring_* and ptrace
        - Default action: Allow (allowlist approach inverted — specific
          dangerous syscalls are blocked, everything else passes)
        - On match: return EPERM
     c. Optionally install Landlock FS rules:
        - Full filesystem: read-only
        - /dev/null: read-write
        - Writable roots: read-write
  4. Exec command via bubblewrap (bwrap):
     - Mount root filesystem read-only (overlayfs)
     - Mount writable_roots with write access
     - Optional network namespace isolation
     - Vendored bwrap binary for zero-dependency deployment

Windows sandbox algorithm:
  1. Load or create capability SID per workspace (hash-based isolation)
  2. Create restricted token from current process token:
     - Remove dangerous privileges (e.g., SeDebugPrivilege)
     - Remove dangerous groups (e.g., Administrators)
  3. Scan workspace for current ACLs
  4. Apply deny-write ACEs to all paths except writable_roots
     - FILE_WRITE_DATA, FILE_WRITE_ATTRIBUTES, DELETE blocked
     - Inheritance flags set so children inherit deny rules
  5. Spawn process via CreateProcessAsUserW() with restricted token

macOS sandbox:
  - Seatbelt profiles restrict FS and network
  - ptrace(PT_DENY_ATTACH) prevents debugging

Process hardening (all platforms, runs before main()):
  - Disable core dumps (setrlimit RLIMIT_CORE = 0)
  - Disable ptrace attach (PR_SET_DUMPABLE=0 on Linux, PT_DENY_ATTACH on macOS)
  - Clear LD_*/DYLD_* environment variables
  - Exit with specific error codes if hardening fails
```

**Source**: `linux-sandbox/src/landlock.rs` (~160 LOC), `linux-sandbox/src/linux_run_main.rs` (~2K LOC), `linux-sandbox/src/bwrap.rs`, `windows-sandbox-rs/src/` (~7K LOC), `process-hardening/src/lib.rs` (~190 LOC)

### 2. Tree-Sitter-Based Compound Command Safety Analysis (HIGHEST)

**The idea**: Parse shell scripts into ASTs using tree-sitter to decompose compound expressions (`bash -lc "cmd1 && cmd2 | cmd3"`) and classify each component, approving the whole only if every part is safe.

**Why this matters for Cubex**: LLMs frequently generate compound shell commands. Simple allowlists can only check the first command name. Without AST-level analysis, you either reject all compound commands (poor UX, frequent approval interrupts) or approve them blindly (security hole). This lets agents auto-run most compound commands while catching dangerous constructs that shell-level analysis would miss. No other harness in our collection does this.

**How it works** (language-agnostic pattern):

```
Input: ["bash", "-lc", "git status && ls -1 | wc -l"]

Algorithm:
  1. Detect shell invocation pattern: cmd[0] ∈ {bash, zsh, sh}
     with -c or -lc flag, extract script string

  2. Parse script with tree-sitter-bash into AST

  3. Walk AST and decompose into individual commands, but REJECT if
     script contains ANY of:
     - Parentheses (subshells: could hide arbitrary code)
     - Redirections (>, <, >>: could write files)
     - Command substitution ($(...) or `...`: could execute hidden commands)
     - Variable expansion ($VAR: could inject arbitrary values)
     - Control flow (if/while/for: could create conditional execution)
     - Process substitution (<(...), >(...))

  4. Extract commands joined by safe operators: && || ; |
     Result: [["git", "status"], ["ls", "-1"], ["wc", "-l"]]

  5. For EACH extracted command, check individual safety:
     a. Strip path prefix from cmd[0] (e.g., /usr/bin/cat → cat)
     b. Match against safe command allowlist with per-command option
        validation:
        - Always safe: cat, echo, grep, ls, pwd, tail, head, wc, stat,
          id, whoami, uname, cd, cut, nl, paste, rev, seq, tr, true,
          false, uniq, which
        - Conditionally safe with option checking:
          * find: block -exec, -delete, -fls, -fprint, -ok, -okdir
          * base64: block -o/--output
          * sed: only allow `sed -n {N,M}p` pattern
          * git: only allow status/log/diff/show/branch subcommands,
            skip global opts (-C, -c, --git-dir) to find true subcommand,
            block -c config overrides, --exec, --textconv
          * sudo: recursively classify the subcommand
     c. Platform-specific: Linux allows numfmt, tac

  6. Return: safe if ALL individual commands pass; unsafe otherwise

  7. Separate dangerous command detection (parallel check):
     - rm -f, rm -rf → forbidden
     - Known destructive patterns → elevated warning
```

**Source**: `shell-command/src/command_safety/is_safe_command.rs` (~600 LOC), `shell-command/src/bash.rs` (~600 LOC), `shell-command/src/command_safety/is_dangerous_command.rs` (~135 LOC)

### 3. Network Proxy with Kernel-Level Enforcement (VERY HIGH)

**The idea**: Force all network traffic from agent-spawned processes through a controllable HTTP/SOCKS5 proxy, enforced at the kernel level via seccomp BPF, with domain-level allow/deny policy.

**Why this matters for Cubex**: Data exfiltration is the highest-risk attack vector for coding agents. An LLM could generate a `curl` command that sends source code to an external server. Without kernel-level network control, any domain-level policy can be bypassed by the executed process. This makes network policy unbypassable: the seccomp filter blocks direct socket creation, forcing all traffic through the policy-enforcing proxy.

**How it works** (language-agnostic pattern):

```
Architecture:
  ┌──────────────────┐        ┌──────────────────┐
  │ Agent Process    │        │ Network Proxy    │
  │ (seccomp blocks  │───────>│ (HTTP + SOCKS5)  │
  │  direct sockets) │        │                  │
  └──────────────────┘        │ Policy Engine:   │
                              │ ├─ ExecPolicy    │
                              │ │  network rules │
                              │ ├─ SandboxMode   │
                              │ │  guard          │
                              │ ├─ Session state  │
                              │ │  (already-     │
                              │ │   approved)     │
                              │ └─ User prompt   │
                              │    (Ask decision) │
                              └──────────────────┘

Network policy decision flow:
  Input: {protocol, host, port, command, exec_policy_hint}

  1. Normalize host (lowercase, no wildcards, IPv6 support)
  2. Check execution policy network rules:
     - Rules indexed by protocol + host
     - Allow/Deny/Prompt per domain
  3. Check sandbox mode guard:
     - ReadOnly: deny all network
     - WorkspaceWrite: proxy-routed only
     - DangerFullAccess: allow (but still enforce if managed)
  4. Check session state for already-approved hosts
  5. If no rule matches: Ask (prompt user)

  Seccomp integration:
  - Restricted mode: block connect/accept/bind/listen/sendto/sendmmsg
    for all socket families except AF_UNIX
  - ProxyRouted mode: block AF_UNIX (prevent bypass), allow only
    AF_INET/AF_INET6 (to reach local proxy bridge)
  - Default action: Allow (other syscalls pass through)

  MITM support:
  - For HTTPS, proxy can generate certificates for domain inspection
  - Enables domain-level policy on encrypted connections
```

**Source**: `network-proxy/src/` (~7.9K LOC), `linux-sandbox/src/landlock.rs:162-262` (seccomp filter)

### 4. SQ/EQ Multi-Client Architecture (VERY HIGH)

**The idea**: Decouple agent clients from the core engine using bounded submission channels and unbounded event channels, enabling any number of frontends (TUI, headless, server, IDE) to share a single agent core.

**Why this matters for Cubex**: Cubex aims to be "CLI-first with framework-quality internals." The SQ/EQ pattern is how Codex achieves this: the core is a library that any frontend can embed. Without this pattern, you either build monolithic CLI-only agents or create ad-hoc IPC mechanisms. This gives Cubex a clean integration story for IDE extensions, web UIs, and programmatic access from day one.

**How it works** (language-agnostic pattern):

```
Architecture:
  Client A (TUI)      ───┐
  Client B (exec)     ───┤──> tx_sub (bounded, cap 512) ──> Core Engine
  Client C (server)   ───┤                                      │
  Client D (IDE ext)  ───┘                                      │
                                                                ▼
  Client A  <──┐                                         Processing:
  Client B  <──┤<── rx_event (unbounded) <─── Event Emitter │
  Client C  <──┤                                            │
  Client D  <──┘                                            │
                                                            │
  All Clients <── agent_status (watch channel) <────────────┘

Data model:
  Op (submission types):
    UserTurn { cwd, approval_policy, sandbox_policy, model,
               reasoning_effort, collaboration_mode, messages }
    ExecApproval { approved, command_id }
    PatchApproval { approved, patch_id }
    Interrupt
    OverrideTurnContext { model?, cwd?, effort?, personality? }
    ResolveElicitation { mcp_approval_response }
    // ~15 more operation types

  EventMsg (event types):
    TurnStarted, TurnComplete, TokenCount
    AgentMessage, AgentMessageDelta (streaming)
    AgentReasoning, AgentReasoningDelta
    ExecCommandBegin/OutputDelta/End
    ExecApprovalRequest, ApplyPatchApprovalRequest
    ContextCompacted, ThreadRolledBack
    McpStartupUpdate, McpToolCall*
    WebSearchBegin/End
    Error, Warning, StreamError
    ModelReroute, SessionConfigured
    // ~30+ total event types

  AgentStatus: Idle | Active | Transitioning | Error

Design decisions:
  - Submission channel bounded (512): prevents runaway buffering,
    provides backpressure
  - Event channel unbounded: assumes downstream fast enough (TUI
    rendering, JSON streaming)
  - Watch channel for status: enables multiple observers without
    queuing
  - Per-turn context override: each submission can carry different
    security policies, enabling dynamic escalation/de-escalation
```

**Source**: `core/src/codex.rs:294-300` (Codex struct), `protocol/src/protocol.rs` (~3.5K LOC)

### 5. Shell Escalation Interception Protocol (HIGH)

**The idea**: An exec()-level interception system where child shells communicate with the parent agent via Unix sockets, allowing server-side approval of every binary execution — not just the initial command, but any subsequent exec() calls within scripts.

**Why this matters for Cubex**: Command-line parsing can only classify the top-level command. A script might internally execute dangerous binaries. Shell escalation catches these at the actual exec() boundary, providing a security layer that no amount of command parsing can achieve. This completes the defense-in-depth chain: execution policy classifies the command, sandbox restricts the environment, network proxy controls connectivity, and escalation intercepts actual binary execution.

**How it works** (language-agnostic pattern):

```
Architecture:
  Parent (Codex agent)
    └─ EscalateServer (listening on Unix socket)
        ├─ Receives: EscalateRequest { file, argv, workdir, env }
        ├─ Evaluates: ExecPolicy + SandboxPolicy + EscalationPolicy
        └─ Responds: EscalateResponse { action }

  Child (spawned shell, inherits CODEX_ESCALATE_SOCKET env var)
    └─ Exec wrapper (patches exec() in shell)
        ├─ Intercepts exec(file, argv) calls
        ├─ Sends EscalateRequest to parent over socket
        ├─ Receives EscalateResponse
        └─ Acts: Run (continue), Escalate (re-sandbox), Deny (abort)

  EscalateAction:
    Run        → child continues exec() directly
    Escalate   → parent re-executes with different sandbox:
                  Unsandboxed | TurnDefault | Permissions(explicit_config)
    Deny{reason} → block execution, return error

Protocol:
  - Each request gets its own response socket (no reuse)
  - Enables concurrent escalation from multiple child shells
  - No race conditions between parallel requests
  - Socket FD inherited through process tree
```

**Source**: `shell-escalation/src/` (~1.6K LOC)

### 6. Mid-Turn Context Compaction with Model-Trained Injection (HIGH)

**The idea**: Three-mode compaction (pre-turn, mid-turn, manual) where mid-turn compaction happens during an active conversation turn, injecting the summary at a specific point that the model is trained to recognize.

**Why this matters for Cubex**: Long-running agent sessions inevitably hit context limits. Most harnesses either fail, truncate blindly, or require the user to manually compact. Mid-turn compaction keeps the agent productive without interrupting its workflow. The model-trained injection point means compaction doesn't confuse the model's understanding of conversation state. Other harnesses have basic compaction, but none implement mid-turn injection.

**How it works** (language-agnostic pattern):

```
Three compaction modes:

1. PRE-TURN compaction:
   - Triggered: before model sees new user input
   - Condition: estimated context + pending updates > threshold
   - Injection: DoNotInject (next turn will reinject full context)
   - Effect: proactive space-making

2. MID-TURN compaction:
   - Triggered: during turn when token_count > auto_compact_limit
     AND model needs follow-up (tool call returned)
   - Injection: BeforeLastUserMessage
     (summary placed just above last real user message in history)
   - Effect: model continues without losing current task context
   - Key insight: model trained to expect summary at this position

3. MANUAL compaction (/compact command):
   - Triggered: user request
   - Injection: DoNotInject
   - Effect: fresh start with summary

Compaction algorithm:
  1. Build summarization prompt from template
  2. Collect current history items
  3. Send to model with COMPACT_USER_MESSAGE_MAX_TOKENS = 20,000
  4. Stream response with retry + exponential backoff
  5. Build replacement history:
     a. Summary as first item
     b. If BeforeLastUserMessage: inject reference context
        (git state, environment) just above last user message
     c. If DoNotInject: clear reference_context_item
  6. If still over context window: remove oldest items sequentially
  7. Emit ContextCompacted event

Token estimation:
  threshold = model.context_window * effective_context_window_percent / 100
  auto_compact_limit ≈ 75% of context_window (model-specific)

Context caching:
  Reference context (git info, env) cached across turns
  Recomputed only when git state changes
```

**Source**: `core/src/compact.rs` (~1K LOC), `core/templates/compact/prompt.md`

### 7. Execution Policy DSL with Indexed Prefix Matching (HIGH)

**The idea**: A rules engine for command classification that indexes rules by first token in a MultiMap, supports pattern alternatives, aggregates multiple matching rules by priority, and integrates network domain rules.

**Why this matters for Cubex**: Cubex needs configurable command approval policies. Hardcoded allowlists don't scale — users need to define per-project policies. This provides the configuration layer above the safety classifier: users define which commands auto-run, which need approval, and which are forbidden, with per-domain network rules. The indexed lookup ensures O(1) rule matching regardless of rule count.

**How it works** (language-agnostic pattern):

```
Data model:
  Decision = Allow | Prompt | Forbidden

  PrefixPattern = {
    first: String,           // indexed lookup key
    rest: Vec<PatternToken>  // remaining tokens to match
  }

  PatternToken = Literal(String) | Alternatives(Vec<String>)
  // ["git", "[status|log|diff]"] → first="git", rest=[Alt(["status","log","diff"])]

  PrefixRule = { pattern: PrefixPattern, decision: Decision, justification? }
  NetworkRule = { protocol, host, decision }

  Policy = {
    rules_by_program: MultiMap<String, RuleRef>,  // indexed by first token
    network_rules: Vec<NetworkRule>,
    host_executables: HashMap<String, Vec<AbsolutePath>>,
  }

Evaluation algorithm:
  fn check(command: &[String], heuristics_fallback) -> Evaluation:
    1. key = executable_path_lookup_key(command[0])
       // Handles /usr/bin/git → "git", resolves symlinks
    2. candidate_rules = rules_by_program.get_vec(key)
    3. For each rule in candidate_rules:
       - Match command[1..] against rule.pattern.rest:
         * Literal: exact match required
         * Alternatives: command token must be in alternatives list
       - If match: collect (rule, decision)
    4. If host_executables enabled: also try full path lookup
    5. Aggregate: decision = MAX(all matched decisions)
       // Forbidden > Prompt > Allow
    6. If no matches AND heuristics_fallback provided:
       decision = heuristics_fallback(command)
    7. Return Evaluation { decision, matched_rules }

Network rule evaluation:
  fn check_network(protocol, host, port) -> Decision:
    1. normalized = normalize_host(host)  // lowercase, IPv6 handling
    2. Match against network_rules by protocol + host
    3. Return first matching rule's decision
```

**Source**: `execpolicy/src/policy.rs` (~200 LOC), `execpolicy/src/rule.rs` (~300 LOC), `execpolicy/src/parser.rs` (~200 LOC)

### 8. App Server as Library Integration Layer (MEDIUM-HIGH)

**The idea**: A full production JSON-RPC server built on top of the core library, providing WebSocket streaming, thread lifecycle management, typed v1/v2 protocol with auto-generated TypeScript bindings, and experimental API gating.

**Why this matters for Cubex**: Cubex has "serving model" as an open technical decision. Codex demonstrates that a production app server can be built as a thin layer over the core library without polluting the library's design. The v2 protocol with TypeScript codegen enables first-class IDE extension support. Experimental API gating via derive macros (`#[experimental("method/or/field")]`) provides a clean path for API evolution.

**How it works** (language-agnostic pattern):

```
Architecture:
  App Server = Transport (WebSocket/HTTP) + Message Processor + Thread State

Transport layer:
  - WebSocket for streaming (bidirectional JSON-RPC)
  - HTTP REST for CRUD operations
  - Routes: /api/codex/* and /wham/* (ChatGPT backend compat)

Message Processor:
  - Receives: v2 wire format (camelCase JSON)
  - Translates: v2 types ↔ core types via macro-generated converters
    v2_enum_from_core!() generates bidirectional enum conversion
  - Dispatches: Op to core, EventMsg back to clients
  - Handles: thread creation/resume/fork/deletion

Thread State:
  - Per-conversation CodexThread with event queues
  - Thread lifecycle: create → configure → active → complete

Protocol conventions:
  - RPC methods: <resource>/<method> (e.g., thread/read, app/list)
  - Request payloads: *Params suffix
  - Response payloads: *Response suffix
  - Notifications: *Notification suffix
  - Wire format: camelCase (except config RPCs → snake_case)
  - Optional fields: #[ts(optional = nullable)] (Params only)
  - List methods: cursor pagination by default
  - Experimental fields: #[experimental("method/field")] with
    inspect_params flag for field-level gating
  - TypeScript generation: ts-rs with #[ts(export_to = "v2/")]

Config RPC:
  - config/read: get current effective config
  - config/write: update config layer
  - config/list: list all config layers with precedence
  - Uses snake_case (mirrors config.toml keys)
```

**Source**: `app-server/src/` (~17K LOC), `app-server-protocol/src/protocol/v2.rs` (~4.6K LOC)

### 9. Credential-Isolating Responses API Proxy (MEDIUM)

**The idea**: A separate process that proxies OpenAI Responses API calls, reading auth tokens from stdin (never CLI-exposed), binding to ephemeral ports, and using `zeroize` to clear credentials from memory.

**Why this matters for Cubex**: Agent tools and scripts often need LLM API access. Embedding API keys in environment variables or CLI arguments exposes them to process listing (`ps aux`), shell history, and child process inheritance. The separate-process proxy pattern keeps credentials out of the main agent's address space entirely.

**How it works** (language-agnostic pattern):

```
Startup:
  1. Read auth header from stdin (not CLI args, not env vars)
  2. Bind to ephemeral port (port 0 → OS assigns)
  3. Write server info as JSON to specified path:
     { "port": <assigned_port>, "pid": <process_id> }
  4. Optionally enable HTTP shutdown endpoint

Request proxying:
  1. Receive HTTP request from local client
  2. Inject stored auth header
  3. Forward to upstream (default: https://api.openai.com/v1/responses)
  4. Stream response back (no timeout on upstream)
  5. On shutdown/exit: zeroize auth token memory

Discovery:
  - Clients read server_info JSON to find port
  - Only localhost connections accepted
  - Ephemeral port avoids conflicts with other services
```

**Source**: `responses-api-proxy/src/` (~500 LOC)

### 10. Pre-Main Process Hardening via Constructor Attributes (MEDIUM)

**The idea**: Apply security hardening before `main()` executes using Rust's `#[ctor::ctor]` attribute, ensuring no application code runs with full privileges.

**Why this matters for Cubex**: Any initialization code that runs before hardening could leak secrets via core dumps, be debugged via ptrace, or have library loading hijacked via LD_PRELOAD. By hardening before main(), these attack vectors are closed before any application state exists.

**How it works** (language-agnostic pattern):

```
Pre-main hardening steps (by platform):

Linux/Android:
  1. prctl(PR_SET_DUMPABLE, 0) → disable ptrace attach
  2. setrlimit(RLIMIT_CORE, 0) → disable core dumps
  3. Clear all LD_* env vars (LD_PRELOAD, LD_LIBRARY_PATH, etc.)
     - Handle non-UTF-8 keys correctly
     - Defense-in-depth even for MUSL-linked binaries

macOS:
  1. ptrace(PT_DENY_ATTACH) → prevent debugger attachment
  2. setrlimit(RLIMIT_CORE, 0) → disable core dumps
  3. Clear all DYLD_* env vars (DYLD_INSERT_LIBRARIES, etc.)

BSD (FreeBSD/OpenBSD):
  1. setrlimit(RLIMIT_CORE, 0) → disable core dumps
  2. Clear all LD_* env vars

Exit codes on failure:
  5 = prctl/PR_SET_NO_NEW_PRIVS failed
  6 = ptrace/PT_DENY_ATTACH failed
  7 = setrlimit/RLIMIT_CORE failed

Rust implementation note:
  Use #[ctor::ctor] or equivalent linker-section attribute to run
  before main(). In Rust, the `ctor` crate places functions in
  .init_array (Linux) or __DATA,__mod_init_func (macOS).
```

**Source**: `process-hardening/src/lib.rs` (~190 LOC)

## Summary

codex's gifts to Cubex, in order of impact:

1. **Cross-Platform Kernel-Level Sandbox** - The most comprehensive agent sandboxing system: seccomp BPF + Landlock + bubblewrap on Linux, restricted tokens + ACLs + capability SIDs on Windows, Seatbelt on macOS. No other harness approaches this depth.
2. **Tree-Sitter Compound Command Analysis** - AST-based decomposition of shell scripts to safely auto-approve compound commands while rejecting dangerous constructs. Eliminates the false choice between "approve everything" and "interrupt constantly."
3. **Network Proxy with Kernel Enforcement** - Domain-level network policy made unbypassable via seccomp BPF blocking direct socket creation, forcing all traffic through a policy-enforcing proxy.
4. **SQ/EQ Multi-Client Architecture** - Clean bounded/unbounded channel decoupling that enables any number of frontends (TUI, headless, server, IDE) to share a single core, with per-submission security policy overrides.
5. **Shell Escalation Interception** - Unix socket protocol intercepting actual exec() calls in child processes, catching dangerous binary execution that command-line parsing would miss.
6. **Mid-Turn Context Compaction** - Three-mode compaction with model-trained injection point for mid-turn summarization, keeping agents productive through long sessions without losing conversation coherence.
7. **Execution Policy DSL** - Indexed prefix-matching rules engine with pattern alternatives, multi-rule aggregation, and integrated network domain rules for configurable per-project command classification.
8. **App Server Integration Layer** - Production JSON-RPC server as thin library wrapper with v1/v2 compat, TypeScript codegen, and experimental API gating via derive macros.
9. **Credential-Isolating API Proxy** - Separate-process proxy pattern keeping API tokens out of the main agent's address space, with stdin-based auth and memory zeroization.
10. **Pre-Main Process Hardening** - Constructor-attribute hardening closing ptrace, core dump, and library injection vectors before any application code executes.
