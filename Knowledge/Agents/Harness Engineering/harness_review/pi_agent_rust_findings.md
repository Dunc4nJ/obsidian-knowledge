# pi_agent_rust Findings (Deep Dive)

## Scope and Method

This document synthesizes a deep exploration of the `pi_agent_rust` repository at `/data/projects/cubex/pi_agent_rust/`. Three parallel exploration agents analyzed the ~227K LOC codebase:

- **Agent A**: Core execution architecture, extension system, security layers, hostcall performance, scheduler
- **Agent B**: Session management, compaction, V2 store, VCR testing, SDK, flake classifier
- **Agent C**: Provider abstraction, tools, interactive TUI, SSE parser, RPC mode, package manager, config

Primary sources reviewed:
- `README.md` (~800 lines), `AGENTS.md` (817 lines), `Cargo.toml` (238 lines)
- Core: `src/agent.rs` (6,164 LOC), `src/agent_cx.rs` (263 LOC), `src/scheduler.rs` (4,243 LOC)
- Extensions: `src/extensions.rs` (48,643 LOC), `src/extensions_js.rs` (23,871 LOC), `src/extension_dispatcher.rs` (13,502 LOC), `src/extension_preflight.rs` (4,373 LOC), `src/extension_scoring.rs` (3,361 LOC), `src/extension_replay.rs` (2,410 LOC), `src/extension_events.rs`, `src/extension_validation.rs`, `src/extension_tools.rs` (36KB)
- Hostcall optimization: `src/hostcall_queue.rs` (2,125 LOC), `src/hostcall_s3_fifo.rs` (1,281 LOC), `src/hostcall_trace_jit.rs` (1,357 LOC), `src/hostcall_amac.rs` (1,461 LOC), `src/hostcall_superinstructions.rs` (859 LOC), `src/hostcall_io_uring_lane.rs` (1,033 LOC)
- Sessions: `src/session.rs` (9,222 LOC), `src/session_store_v2.rs` (1,732 LOC), `src/session_sqlite.rs` (704 LOC), `src/session_index.rs` (1,701 LOC), `src/session_metrics.rs` (1,008 LOC)
- Providers: `src/provider.rs` (29KB), `src/providers/mod.rs` (96KB), `src/providers/anthropic.rs` (85KB), plus 9 other provider files
- Tools & TUI: `src/tools.rs` (8,268 LOC), `src/interactive.rs` (83KB), `src/interactive/` (18 files), `src/sse.rs` (50KB), `src/rpc.rs` (5,007 LOC)
- Infrastructure: `src/auth.rs` (7,325 LOC), `src/config.rs` (3,085 LOC), `src/compaction.rs` (2,355 LOC), `src/package_manager.rs` (5,687 LOC), `src/vcr.rs` (2,242 LOC)
- Existing findings docs: `agno_findings.md`, `deepagents_findings.md`, `opencode_findings.md`, `letta-code_findings.md`

## README Alignment: What Is Unique About This Project

**README claims**: Pi Agent Rust is a "high-performance AI coding agent CLI written in Rust" — a from-scratch port of Pi Agent (TypeScript) that is substantially faster, more memory-efficient, and materially stronger on extension runtime safety.

**Claim 1: Performance superiority.** Verified. The codebase uses jemalloc (`Cargo.toml:161`), zero-copy patterns throughout (`Cow<'a>` context in `src/provider.rs:62`, SSE event interning in `src/sse.rs:56-70`), and aggressive release optimizations (`opt-level=3`, LTO, `codegen-units=1`, `panic=abort`, strip in `Cargo.toml:173-178`). The `src/interactive/perf.rs` enforces a 16.667ms (60fps) frame budget.

**Claim 2: Dramatically stronger security model.** Verified. The extension system alone is 48K LOC (`src/extensions.rs`) with graduated enforcement rollout (`src/extensions.rs:2096-2262`), runtime risk scoring with conformal prediction and PAC-Bayes bounds (`src/extensions.rs:3021-3290`), command mediation with heredoc AST analysis (`src/extensions.rs:6686-6854`), and incident evidence bundles with SHA-256 integrity seals (`src/extensions.rs:5287-5310`).

**Claim 3: Two extension runtime families without Node/Bun.** Verified. `src/extensions_js.rs` (23,871 LOC) embeds QuickJS via `rquickjs` crate with Node API shims for `fs`, `path`, `child_process`, etc. WASM support via `wasmtime` (`Cargo.toml:122`). Sub-100ms cold load, sub-1ms warm load via isolate reuse.

**Claim 4: 7 built-in tools.** Verified. `src/tools.rs:34-66` defines the Tool trait; implementations cover read, write, edit, bash, grep, find, ls with process tree management and hard safety limits.

**Genuine identity**: Pi Agent Rust is the most security-hardened and performance-optimized agent harness in this collection, with a level of extension runtime safety engineering (statistical anomaly detection, graduated rollout, forensic evidence bundles) that has no parallel in any other repository studied. It prioritizes provable correctness and defense-in-depth over feature breadth.

## Architecture Overview

Pi Agent Rust is a single-binary CLI agent built on two custom Rust libraries: `asupersync` (structured concurrency async runtime with HTTP/TLS/SQLite) and `rich_rust` (Rich-quality terminal output). The core architecture flows: CLI (clap) → App/Config/Resources → Agent Session → Provider Layer (11 providers) → Tool Registry (built-ins + extension tools) ↔ Extension Runtime (QuickJS + WASM + capability policy) → Surfaces (Interactive TUI + RPC/stdin) → Session Persistence (JSONL + V2 sidecar + optional SQLite).

**Module/directory map:**
- `src/agent.rs` + `src/agent_cx.rs` — Agent loop with parallel tool execution and capability-scoped context
- `src/extensions*.rs` (~100K LOC total) — Extension protocol, JS runtime, dispatcher, validation, scoring, replay, events
- `src/hostcall_*.rs` (~8K LOC total) — Performance-critical hostcall pipeline: S3-FIFO cache, trace JIT, superinstructions, AMAC, io_uring lanes, queue system
- `src/session*.rs` (~15K LOC total) — Three-tier persistence (JSONL, V2 sidecar, SQLite) with tree branching and index
- `src/providers/` (~10 files, ~600KB) — 11 LLM providers with streaming, tool calls, extended thinking
- `src/interactive/` (18 files) — Elm-style TUI with bubbletea architecture
- `src/tools.rs` — 7 built-in tools with safety limits and process management
- `src/scheduler.rs` — Deterministic event loop with formal invariants
- `src/compaction.rs` + `src/compaction_worker.rs` — Context compaction with background worker
- `src/rpc.rs` — JSON wire protocol for IDE integration with two-queue message system
- `src/auth.rs` — Multi-credential authentication (API keys, OAuth, AWS, Bearer, ServiceKey)
- `src/package_manager.rs` — Package management (npm, git, local) with lockfile and trust states

**Key abstractions**: The `Provider` trait abstracts LLM backends; `Tool` trait abstracts tool implementations; `ExtensionPolicy` governs capability access; `SessionEntry` enum captures 8 conversation entry types; `MacrotaskKind` governs scheduler ordering; `ExtensionDispatcher` routes hostcalls through a multi-lane reactor mesh.

## Feature Analysis

### 1. Agent Loop with Parallel Tool Execution (src/agent.rs)
**What it is**: The core agent loop that manages tool iteration with safety-aware parallel/sequential classification.
**Key files**: `src/agent.rs` (~220KB), `src/agent_cx.rs` (~6.6KB)
**How it works**: The `Agent` struct (line 381) manages provider, tools, messages, and two message queues (steering for priority, follow-up for idle). Tool calls are classified as read-only or state-mutating. Read-only tools run in parallel via `buffer_unordered(MAX_CONCURRENT_TOOLS=8)` (line 1570). State-mutating tools flush the parallel buffer first, then run sequentially. Steering messages are checked at four decision points during tool execution to allow mid-turn interruption. Long-running tools are raced against an `AbortSignal` using `select()` (line 1670). An `AgentEvent` enum (line 203) provides 12+ event types for lifecycle observability.
**Notable details**: The two-tier queue (steering + follow-up) with `QueueMode` control (All vs OneAtATime) is sophisticated. The 4-point steering check ensures responsiveness even during complex multi-tool turns.

### 2. Extension Capability and Policy System (src/extensions.rs)
**What it is**: A capability-based security model for extension access control with graduated enforcement rollout.
**Key files**: `src/extensions.rs` (~1.7MB), `src/extension_dispatcher.rs` (~485KB)
**How it works**: `ExtensionPolicy` (line 2013) defines three profiles (Strict/Prompt/Permissive) with default and deny capability sets. Each extension gets a `PolicyDecision` (Allow/Deny/Prompt) per hostcall category (tool/exec/http/session/ui/events). A `PolicySnapshot` (dispatcher line 143) precomputes an O(1) decision table with SHA-256 version hash for provenance. The system enforces through a `RolloutPhase` state machine (line 2096): Shadow (log only, no enforcement) → LogOnly (log denials but allow) → EnforceNew (enforce for new extensions only) → EnforceAll (full enforcement). A `RollbackTrigger` (line 2190) monitors false positive rate (max 5%), error rate (max 10%), and latency (max 200ms), automatically reverting to the previous phase if thresholds are exceeded over a 100-decision sliding window.
**Notable details**: The graduated rollout is genuinely novel among agent harnesses. It solves the real problem of deploying new security policies without breaking existing extensions. The automatic rollback on degradation is a production-grade feature.

### 3. Runtime Risk Scoring with Statistical Safety Envelopes (src/extensions.rs)
**What it is**: A statistical anomaly detection system for extension behavior using conformal prediction and PAC-Bayes bounds.
**Key files**: `src/extensions.rs` (~1.7MB, lines 2054-3300)
**How it works**: `RuntimeRiskConfig` (line 2054) configures a type-I error budget (alpha=0.01), sliding window (128 samples), and decision timeout (50ms). The Safety Envelope combines two methods: (1) Conformal Prediction (line 3098) uses Welford online mean/variance tracking with quantile-based prediction intervals at 95% confidence over a 200-sample calibration set. Anomaly detection computes nonconformity scores as absolute residuals. (2) PAC-Bayes Bound (line 3204) computes an upper bound on true error rate via KL divergence with delta=0.05, using 64-iteration binary search. These together produce calibrated anomaly decisions without assuming data distribution, with the overall system failing closed when enabled.
**Notable details**: Using formal statistical methods (conformal prediction, PAC-Bayes) for runtime security decisions is unprecedented in agent harness design. This isn't heuristic-based — it provides probabilistic guarantees on false positive rates.

### 4. Exec Mediation with Heredoc AST Analysis (src/extensions.rs)
**What it is**: Two-stage command classification that blocks dangerous shell commands, including those hidden in heredocs.
**Key files**: `src/extensions.rs` (lines 6686-6854)
**How it works**: Stage 1 classifies commands against an allowlist of safe utilities (`ls`, `pwd`, `echo`, `cat`, `head`, `tail`, `wc`) and safe git subcommands. Stage 2 handles heredoc content: `RuntimeHeredocScriptLanguage` identifies embedded script languages (Bash, Python, JavaScript, TypeScript, Ruby) with severity levels (Critical=0.34, High=0.24, Medium=0.12). The system uses `ast-grep-core` (not regex) to parse heredoc content and detect dangerous AST patterns — recursive delete, disk writes, reverse shells. Denied operations generate redacted security alerts with mediation ledger entries.
**Notable details**: Most command blocking systems use regex or keyword matching. Using actual AST parsing via `ast-grep-core` (dependency in `Cargo.toml:102-109` with tree-sitter for 5 languages) to analyze heredoc content is a significant advance that catches payloads regex would miss.

### 5. Trust Lifecycle with Kill-Switch Controls (src/extensions.rs)
**What it is**: A four-state trust lifecycle for extensions with instant quarantine and audited state transitions.
**Key files**: `src/extensions.rs`
**How it works**: Extensions progress through states: `pending` → `acknowledged` → `trusted` → `killed`. Each transition is audited with operator provenance (who changed the state and why). A kill switch can instantly quarantine an extension, requiring explicit re-acknowledgement before restoring access. Hostcall-lane kill-switch controls (`forced_compat_global_kill_switch`, `forced_compat_extension_kill_switch`) can force compatibility-lane execution globally or per-extension when fast-lane behavior needs containment.
**Notable details**: The dual kill-switch (global vs per-extension) with compatibility-lane fallback is a practical emergency containment mechanism. The audit trail with operator provenance is compliance-grade.

### 6. Hostcall Reactor Mesh (src/extension_dispatcher.rs + src/hostcall_*.rs)
**What it is**: A multi-lane dispatch system for extension hostcalls with performance optimizations at the micro-architectural level.
**Key files**: `src/extension_dispatcher.rs` (~485KB), `src/hostcall_queue.rs` (~75KB), `src/hostcall_s3_fifo.rs` (~47KB), `src/hostcall_trace_jit.rs` (~49KB), `src/hostcall_amac.rs` (~51KB), `src/hostcall_superinstructions.rs` (~30KB), `src/hostcall_io_uring_lane.rs` (~36KB), `src/hostcall_rewrite.rs` (~13KB)
**How it works**: The `ExtensionDispatcher` (line 44) routes hostcalls through a unified `dispatch_host_call_shared()` function. The routing pipeline includes: (a) S3-FIFO cache — a segmented LRU cache with small-object bias for frequently-accessed hostcall results; (b) Trace JIT — detects hot hostcall sequences and compiles them into optimized traces with guard contexts and speculative execution with fallback; (c) Superinstructions — fuses related hostcall sequences into compound operations via `HostcallSuperinstructionCompiler`; (d) AMAC (Adaptive Multi-level Architecture Cache) — prefetches the next N hostcalls using `AmacBatchExecutor` for cache-line-aware dispatch; (e) io_uring lanes — routes IO-dominant hostcalls through Linux kernel async IO via a lane decision matrix in `decide_io_uring_lane()`; (f) Multi-lane queues — SPSC channels with bounded backpressure and shard affinity for CPU locality; (g) Dual-exec sampling — shadow execution on both fast-lane and compatibility-lane to detect divergence with automatic backoff.
**Notable details**: This level of micro-architectural optimization (trace JIT, superinstructions, AMAC prefetching) applied to an extension hostcall system is unique. The dual-exec sampling provides correctness guarantees for the optimized paths.

### 7. Incident Evidence Bundle System (src/extensions.rs)
**What it is**: Forensic-grade security event collection with tamper-evident packaging for compliance and audit.
**Key files**: `src/extensions.rs` (lines 5069-5310)
**How it works**: `SecurityAlert` (line 5109) captures 7 categories (PolicyDenial, AnomalyDenial, ExecMediation, SecretBroker, QuotaBreach, Quarantine, ProfileTransition) with schema versioning, monotonic sequence IDs, WHO/WHAT/WHY/ACTION fields, and SHA-256 redaction context hashes. `IncidentEvidenceBundle` (line 5287) packages alerts into filterable bundles (by time range, extension ID, category, severity) with configurable redaction policy and an integrity seal (SHA-256 of serialized sections).
**Notable details**: The monotonic sequence IDs prevent reordering attacks. The configurable redaction policy allows sharing evidence bundles without exposing secrets. This is enterprise compliance-grade incident response capability.

### 8. QuickJS Extension Runtime with Node API Shims (src/extensions_js.rs)
**What it is**: An embedded JavaScript runtime that runs JS/TS extensions without Node or Bun, with Node API compatibility shims.
**Key files**: `src/extensions_js.rs` (~846KB)
**How it works**: Uses `rquickjs` crate to embed QuickJS. Provides compatibility shims for Node.js APIs: `fs` (readFileSync, writeFileSync, etc.), `path` (join, resolve, etc.), `child_process` (exec), `os`, `crypto`, `url`. Extensions call explicit host connectors (tool/exec/http/session/ui) rather than Node APIs directly. The runtime supports TypeScript via SWC transpilation (dependencies: `swc_ecma_parser`, `swc_ecma_transforms_typescript` in `Cargo.toml:115-121`). Cold load targets sub-100ms (P95), warm load sub-1ms (P99) via pre-compiled contexts and warm isolate reuse where the runtime creation cost is paid during startup prewarm.
**Notable details**: Running JS extensions without a full Node/Bun runtime is a significant architectural choice that eliminates 500ms+ startup overhead. The SWC-based TypeScript transpilation means extensions don't need a separate build step. Warm isolate reuse means repeated extension runs are near-zero-cost.

### 9. Deterministic Scheduler with Formal Invariants (src/scheduler.rs)
**What it is**: An event loop scheduler with total ordering via monotonic sequence counters and formal correctness invariants.
**Key files**: `src/scheduler.rs` (~141KB)
**How it works**: `Seq` (line 26) provides monotonic sequence numbers for stable ordering. `TimerEntry` (line 56) carries timer_id, deadline_ms, and seq. `MacrotaskKind` (line 104) classifies work into TimerFired, HostcallComplete, InboundEvent. The scheduler enforces five invariants: (I1) single macrotask per tick, (I2) microtask fixpoint after each macrotask, (I3) stable timer ordering by (deadline, seq), (I4) no reentrancy — hostcall completions enqueue rather than re-enter, (I5) total order via seq counter. A `Clock` trait (line 177) abstracts time: `WallClock` for production, fixed clocks for deterministic testing.
**Notable details**: Formal invariants on an event loop are unusual in application code. The Clock abstraction enables deterministic testing of time-dependent behavior — critical for testing retry logic, timeouts, and rate limiting without flaky wall-clock dependencies.

### 10. Three-Tier Session Persistence (src/session*.rs)
**What it is**: Session storage with three backends (JSONL, V2 sidecar, SQLite) supporting tree-structured branching and sub-100ms resume for multi-megabyte sessions.
**Key files**: `src/session.rs` (~341KB), `src/session_store_v2.rs` (~63KB), `src/session_sqlite.rs` (~22KB), `src/session_index.rs` (~64KB)
**How it works**: Sessions use a tree structure where each `EntryBase` has an optional `parent_id`. An `is_linear` flag (session.rs line 555) enables O(1) fast-path for the 99% case of non-branching conversations, avoiding tree traversal. The `entry_index` HashMap provides O(1) entry lookup by ID. `SessionEntry` enum supports 8 types: Message, ModelChange, ThinkingLevelChange, Compaction, BranchSummary, Label, SessionInfo, Custom. The V2 sidecar (`session_store_v2.rs`) stores data as segmented append logs with offset indexes: each `SegmentFrame` carries schema version, sequence numbers, parent links, payload SHA-256, and CRC32-C checksums. An SHA-256 chain hash (genesis → H(prev || payload_sha256)) provides tamper detection. Three resume modes: Full (all segments), ActivePath (leaf-to-root traversal), Tail(N) (last N entries). The SQLite backend uses WAL mode with NORMAL synchronous. A global `SessionIndex` (SQLite) indexes all sessions with metadata (cwd, timestamp, message count, name) for fast listing. Incremental persistence uses a dual-path strategy: append-only for low latency (with exclusive file lock), full rewrite via atomic temp-rename for checkpointing. An `AutosaveQueue` batches up to 256 mutations before flush with backpressure tracking.
**Notable details**: The `is_linear` optimization is clever — 99% of conversations don't branch, so avoiding tree traversal for the common case is significant. The V2 sidecar's chain hashing provides integrity guarantees. Three resume modes (Full/ActivePath/Tail) allow trading completeness for speed on massive sessions.

### 11. Context Compaction with Cut-Point Binary Search (src/compaction.rs)
**What it is**: Automatic context compaction when conversations approach the model's context window, using conservative token estimation and binary search for optimal cut points.
**Key files**: `src/compaction.rs` (~80KB), `src/compaction_worker.rs` (~9.3KB)
**How it works**: `ResolvedCompactionSettings` (line 62) configures: context_window_tokens (200K default), reserve_tokens (~8% of window = 16,384), keep_recent_tokens (~10% of window = 20,000). Token estimation uses a conservative 3 chars/token ratio for code-heavy content, 1,200 tokens per image. Compaction triggers when `context_tokens > window - reserve`. Cut-point detection (line 414) uses binary search: iterate backwards accumulating tokens until `keep_recent_tokens` is reached, then binary search for the largest valid cut point before that position. Valid cut points are message entries or branch summaries (not compaction boundaries, to preserve prior summaries). File operations (reads, writes, edits) are tracked for inclusion in summaries. A background worker (`CompactionWorkerState`, compaction_worker.rs line 41) manages compaction with quota controls: 60s cooldown between starts, 120s timeout, max 100 attempts per session.
**Notable details**: The binary search cut-point algorithm optimizes for keeping maximum recent context while respecting token budgets. Tracking file operations across the compacted region ensures the summary captures what files were touched.

### 12. Provider Abstraction with Zero-Copy Context (src/provider.rs, src/providers/)
**What it is**: A provider trait abstraction supporting 11 LLM backends with zero-copy message passing and extensive compatibility normalization.
**Key files**: `src/provider.rs` (~29KB), `src/providers/mod.rs` (~96KB), `src/providers/anthropic.rs` (~85KB), plus 9 more provider files
**How it works**: The `Provider` trait (line 28) defines `stream()` returning `Pin<Box<dyn Stream<Item = Result<StreamEvent>>>>`. The `Context<'a>` struct (line 62) uses `Cow<'a>` for messages, tools, and system prompt — providers that don't mutate data borrow without copying. `StreamOptions` (line 125) includes temperature, max_tokens, API key, cache retention (None/Short/Long), thinking levels with custom budgets per level, and custom headers. Provider routing (`providers/mod.rs:78`) uses a `ProviderRouteKind` enum with 18 variants. Edit-distance fuzzy matching (single-row O(min(a,b)) Levenshtein, line 185) suggests corrections for mistyped provider names. `CompatConfig` normalizes differences across providers: field name remapping (`max_tokens` → `max_completion_tokens`), system role overrides, custom headers, gateway routing metadata (OpenRouter, Vercel).
**Notable details**: The 11 built-in providers (Anthropic, OpenAI, OpenAI Responses, Gemini, Cohere, Azure, Bedrock, Vertex, Copilot, GitLab) is the broadest coverage of any repo studied. The `Cow<'a>` pattern for zero-copy context passing is a Rust-specific optimization that avoids cloning the full message history on every provider call. The `CompatConfig` approach to handling provider differences (rather than per-provider code paths) is cleaner than what other repos do.

### 13. SSE Parser with Event Interning (src/sse.rs)
**What it is**: A custom SSE parser optimized for LLM streaming with event type interning and incremental scanning.
**Key files**: `src/sse.rs` (~50KB)
**How it works**: `SseParser` (line 37) tracks `scanned_len` to avoid rescanning already-processed buffer content. Event types are interned: common names like `"message"`, `"message_delta"` are mapped to `Cow::Borrowed` static strings (line 56), eliminating per-event heap allocation. Uses `memchr2` for fast newline scanning. Handles UTF-8 BOM (U+FEFF) at stream start per SSE spec. Safety limit of 100MB per event to prevent OOM from malicious streams.
**Notable details**: The `scanned_len` optimization avoids O(n²) rescanning on partial chunks. Event interning eliminates allocation on the hot path — LLM APIs use ~10 fixed event types, so borrowing static strings is nearly free.

### 14. Interactive TUI with Bubbletea Architecture (src/interactive/)
**What it is**: An Elm-style terminal UI built on the Rust port of Go's bubbletea framework, with 60fps frame budget enforcement.
**Key files**: `src/interactive.rs` (~83KB), `src/interactive/state.rs` (~31KB), `src/interactive/view.rs` (~63KB), `src/interactive/commands.rs` (~94KB), `src/interactive/perf.rs` (~56KB)
**How it works**: `PiApp` state model includes: multi-line text editor with history, scrollable conversation viewport with follow-tail during streaming, model selector, session branch tree navigator, and real-time token/cost tracking. `PiMsg` enum has 40+ message variants covering agent lifecycle, streaming deltas, tool execution, credential updates, and UI interactions. Performance monitoring (`perf.rs`) uses `RefCell`/`Cell` for interior mutability in `view()` (immutable ref constraint from bubbletea). Frame timing window of 60 samples with 16.667ms budget. Viewport scroll sync maintains position relative to bottom when content is appended during streaming.
**Notable details**: The bubbletea (charmed_rust) architecture in Rust is novel — it's a port of the Go TUI framework to Rust. Auto-collapse for large tool outputs (>20 lines triggers collapse, shows 5-line preview) improves readability. The viewport sync algorithm that preserves scroll position during streaming is well-designed.

### 15. RPC Mode with Two-Queue Messaging (src/rpc.rs)
**What it is**: A JSON wire protocol for IDE integration with separate priority and normal message queues.
**Key files**: `src/rpc.rs` (~180KB)
**How it works**: JSON RPC over stdin/stdout with a compatibility subset of pi-mono's protocol. `RpcSharedState` maintains two queues: `steering` (priority) and `follow_up` (normal), each with configurable `QueueMode`. Commands support kebab-case and camelCase aliases (`follow-up` = `followUp` = `queue-follow-up`). Max 128 pending messages per queue.
**Notable details**: The two-queue system allows IDE integrations to interrupt agent processing with high-priority steering messages while queuing normal follow-up messages.

### 16. Multi-Credential Authentication (src/auth.rs)
**What it is**: Authentication supporting 5 credential types with proactive refresh for OAuth tokens.
**Key files**: `src/auth.rs` (~256KB)
**How it works**: `AuthCredential` enum (line 87) supports: ApiKey, OAuth (with refresh_token, expires, token_url), AwsCredentials (for Bedrock), BearerToken, ServiceKey (client_id, client_secret). `AuthStorage` (line 160) manages file-locked `auth.json`. Proactive refresh window of 10 minutes before actual expiry. Credential status detection distinguishes Missing, ApiKey, OAuthValid, OAuthExpired, BearerToken, AwsCredentials, ServiceKey.
**Notable details**: The proactive refresh window prevents mid-conversation auth failures. AWS credential support (with session_token and region) is necessary for Bedrock but rare in agent CLIs.

### 17. Tools with Process Tree Management (src/tools.rs)
**What it is**: 7 built-in tools with hard safety limits, zero-copy truncation, and recursive process cleanup.
**Key files**: `src/tools.rs` (~283KB)
**How it works**: The `Tool` trait (line 34) defines `is_read_only()` for parallel execution classification. Safety limits: 2,000 lines / 50KB default truncation, 100MB read limit, 100MB bash output limit, 4.5MB image limit, 20,000 entry LS scan limit. Truncation takes ownership of input `String` and uses `String::truncate()` for in-place modification (zero allocation when no truncation needed). `terminate_process_tree()` (line 4463) recursively kills child processes with a 5-second SIGTERM grace period before SIGKILL. Bash tool has 120-second default timeout.
**Notable details**: The `TruncationResult` struct captures full metadata (total_lines, total_bytes, truncated_by, first_line_exceeds_limit) for the LLM to understand what was removed. Process tree termination prevents orphaned processes from consuming resources after tool abort.

### 18. Extension Validation Pipeline (src/bin/ + tests/)
**What it is**: A multi-track validation system for extension compatibility with 224 vendored and 777 unvendored extensions.
**Key files**: `src/bin/ext_full_validation.rs` (~58KB), `src/bin/ext_release_binary_e2e.rs` (~31KB), `src/bin/ext_unvendored_fetch_run.rs` (~35KB), `src/conformance.rs` (~148KB)
**How it works**: Three validation tracks: (1) Vendored corpus (224 extensions) with deterministic conformance, compatibility matrix, and scenario suites. (2) Unvendored corpus (777 extensions) with source acquisition and onboarding prioritization. (3) Release-binary live-provider E2E testing against real providers (Ollama + qwen2.5:0.5b). The pipeline runs sharded conformance testing, auto-repair, differential analysis, and produces machine-readable reports. Latest results: 224/224 vendored passed, 25/25 scenarios passed, 20/20 first-set E2E passed, 224/224 full release E2E passed.
**Notable details**: Testing extensions against 224 real-world extensions (not just unit tests) is unique. The release-binary E2E stage that runs the actual compiled binary against live providers catches integration issues that unit tests miss.

### 19. VCR Testing for HTTP Streams (src/vcr.rs)
**What it is**: Record/replay infrastructure for HTTP streaming responses, enabling deterministic testing of LLM interactions.
**Key files**: `src/vcr.rs` (~79KB)
**How it works**: `VcrMode` (line 90) supports Record, Playback, and Auto (record if missing, playback if exists). Cassettes are JSONL files with schema version, test name, timestamp, and interactions (request + response pairs). Responses are stored as UTF-8 string chunks or base64 for binary data. `into_byte_stream()` creates a `Stream<Result<Vec<u8>>>` for playback. Default cassette directory: `tests/fixtures/vcr`, configurable via `VCR_CASSETTE_DIR` env var.
**Notable details**: VCR testing for streaming SSE responses is particularly valuable — it allows testing the full streaming pipeline without hitting real APIs. The auto mode (record-if-missing) makes test development seamless.

### 20. Package Manager with Trust States (src/package_manager.rs)
**What it is**: Package management for skills, prompts, themes, and extensions from npm, git, and local sources with lockfile integrity.
**Key files**: `src/package_manager.rs` (~193KB)
**How it works**: `PackageScope` (User/Project/Temporary) determines installation location. Sources: npm (`npm:pkg`), git (`git:host/owner/repo[@ref]`), local paths. `PackageLockfile` tracks entries with SHA-256 digests, source provenance, and trust state. Lockfile entries include `PackageSourceKind` and `PackageResolvedProvenance` for reproducible installations. Subcommands: install, remove, update, list.
**Notable details**: Trust state tracking in the lockfile connects to the extension trust lifecycle, creating end-to-end provenance from package installation through runtime execution.

### 21. Flake Classifier for CI Reliability (src/flake_classifier.rs)
**What it is**: Automatic classification of transient test failures for CI retry decisions.
**Key files**: `src/flake_classifier.rs` (~20KB)
**How it works**: `FlakeCategory` enum (line 11) identifies 6 patterns: OracleTimeout, ResourceExhaustion, FsContention, PortConflict, TmpdirRace, JsGcPressure. `classify_failure()` (line 95) scans output line-by-line with lowercase substring matching (no regex). Returns first match or `Deterministic`. `FlakeEvent` records target, classification, attempt, and timestamp as JSONL for trend analysis.
**Notable details**: Lightweight pattern matching without regex dependency. The categorization allows CI to distinguish retriable failures from genuine regressions.

### 22. Error Hints System (src/error_hints.rs)
**What it is**: Structured error hints that provide specific, actionable remediation suggestions.
**Key files**: `src/error_hints.rs` (~43KB)
**How it works**: `ErrorHint` (line 18) contains summary, hints array, and context fields — all `&'static str` for stability. Categorized for config, session, auth, provider, tool, extension, IO, JSON, and SQLite errors. Design principles: no OS-specific hints unless reliably detectable, no destructive action suggestions, specific commands and paths in hints.
**Notable details**: The commitment to `&'static str` makes hints testable and prevents runtime allocation. The explicit prohibition on destructive suggestions is a safety-conscious design choice.

## What Our Harness Should Adopt From pi_agent_rust

These are pi_agent_rust's distinctive contributions — features that represent genuine innovations or unusually strong implementations that Cubex should adopt. Ranked by impact.

### 1. Graduated Security Enforcement Rollout (HIGHEST)

**The idea**: A four-phase rollout system for security policy changes (Shadow → LogOnly → EnforceNew → EnforceAll) with automatic rollback on degradation metrics.

**Why this matters for Cubex**: Any agent harness that runs extensions needs to deploy security policy changes without breaking existing extensions. Without graduated rollout, you either ship enforcement changes that break production extensions (user churn) or never deploy stricter policies (security risk). This solves the deployment problem that makes security policies impractical in practice.

**How it works**:
- Define a `RolloutPhase` state machine with four states:
  - `Shadow`: New policy runs in parallel but does not affect outcomes. All decisions are logged for comparison.
  - `LogOnly`: Denials from new policy are logged and counted but the old policy's decision is used.
  - `EnforceNew`: New policy is enforced for newly-installed extensions only. Existing extensions use old policy.
  - `EnforceAll`: New policy is enforced for all extensions.
- A `RollbackTrigger` monitors a sliding window of the last N decisions (default 100) and tracks:
  - `false_positive_rate`: Fraction of denials that would have been allowed by old policy. Threshold: 5%.
  - `error_rate`: Fraction of decisions resulting in runtime errors. Threshold: 10%.
  - `max_latency_ms`: P99 decision latency. Threshold: 200ms.
- When any threshold is exceeded, the system automatically reverts to the previous phase and emits a `SecurityAlert`.
- Phase transitions require explicit operator action (cannot auto-advance). This prevents the system from oscillating between phases.
- State is persisted so rollout survives process restarts.

**Source**: `src/extensions.rs` (~1.7MB, lines 2096-2262)

### 2. Statistical Safety Envelopes for Extension Anomaly Detection (HIGHEST)

**The idea**: Use conformal prediction and PAC-Bayes bounds to detect anomalous extension behavior with calibrated false-positive guarantees, rather than heuristic thresholds.

**Why this matters for Cubex**: Traditional anomaly detection uses hardcoded thresholds that are either too loose (miss attacks) or too tight (false positives that frustrate users). Statistical safety envelopes provide mathematically calibrated detection that adapts to each extension's baseline behavior. Without this, security monitoring is either useless or annoying.

**How it works**:
- **Feature extraction**: For each hostcall, extract a risk feature vector (call frequency, argument complexity, resource access patterns, timing).
- **Conformal Prediction**:
  - Maintain a Welford online estimator tracking running mean and variance of risk scores.
  - Keep a calibration buffer of the last 200 scores.
  - For each new score, compute a nonconformity score (absolute residual from mean).
  - Compare against the quantile at `1 - alpha` (default alpha=0.01, so 99th percentile) of calibration nonconformity scores.
  - If the new score exceeds this threshold, flag as anomaly.
  - The key property: the false positive rate is bounded at `alpha` regardless of the underlying distribution.
- **PAC-Bayes Bound**:
  - Compute an upper bound on the true error rate of the anomaly detector.
  - Uses `delta=0.05` (bound holds with probability ≥ 95%).
  - Binary search (64 iterations) to find the tightest bound satisfying the PAC-Bayes inequality via KL divergence.
  - This provides a meta-guarantee: not just "this extension is anomalous" but "our anomaly detector itself is reliable."
- **Decision integration**: Combine both scores. If conformal detects anomaly AND PAC-Bayes confirms detector reliability, escalate to denial. Otherwise, log for review. Decision timeout: 50ms; on timeout, use fail-closed default.
- **Sliding window**: Only the last 128 samples influence decisions, so the detector adapts to changing extension behavior.

**Source**: `src/extensions.rs` (~1.7MB, lines 2054-3300)

### 3. Hostcall Reactor Mesh with Multi-Lane Dispatch (VERY HIGH)

**The idea**: A performance-optimized dispatch system for extension hostcalls with six optimization layers: S3-FIFO caching, trace JIT, superinstruction fusion, AMAC prefetching, io_uring routing, and dual-exec correctness sampling.

**Why this matters for Cubex**: Extensions that make many hostcalls (tool lookups, file reads, HTTP requests) can bottleneck the agent if dispatch is naive. A reactor mesh with adaptive optimization keeps extension overhead low without sacrificing correctness. The dual-exec sampling is critical — it lets you ship aggressive optimizations while proving they're behavior-equivalent.

**How it works**:
- **Multi-lane queue**: Each extension gets a bounded SPSC channel with shard affinity (extension ID → shard → CPU core). Backpressure telemetry tracks queue depth and wait times.
- **Policy snapshot**: Precompute an O(1) capability decision table keyed by (extension_id, hostcall_type). SHA-256 version hash for cache invalidation. Eliminates per-call policy evaluation.
- **S3-FIFO cache**: Three-segment FIFO cache (small, main, ghost) for hostcall results. Small-object segment has higher admission rate. Ghost segment tracks recently-evicted entries for frequency estimation. Reduces redundant hostcall execution for repeated patterns (e.g., same file read within a tool sequence).
- **Trace JIT**: Monitor hostcall sequences. When a sequence repeats N times (threshold), compile it into a trace — a linear sequence of operations with guard contexts at branch points. Guards check preconditions; if guard fails, deoptimize to interpreted path. Tracks JIT hits and deoptimization reasons per trace.
- **Superinstruction fusion**: Recognize common hostcall pairs/triples (e.g., read-file + parse-json, check-permission + execute-tool) and fuse them into a single compound operation that eliminates intermediate dispatch overhead.
- **AMAC batch executor**: For sequences of N independent hostcalls, interleave their pipeline stages to maximize instruction-level parallelism and cache utilization. This is the software analog of hardware memory-level parallelism.
- **io_uring lane**: For IO-dominant hostcalls (file reads, directory listings), route through a dedicated io_uring submission queue. A lane decision function evaluates whether io_uring is beneficial based on call type, payload size, and current queue depth.
- **Dual-exec sampling**: Randomly sample a fraction of hostcalls and execute them on both the optimized (fast-lane) and unoptimized (compatibility-lane) paths. Compare results. If divergence is detected, increase sampling rate and potentially disable the optimization. This provides a runtime correctness oracle for all the above optimizations.

**Source**: `src/extension_dispatcher.rs` (~485KB), `src/hostcall_*.rs` (~300KB total)

### 4. Embedded QuickJS Runtime with Node API Shims (VERY HIGH)

**The idea**: Run JavaScript/TypeScript extensions in an embedded QuickJS interpreter with Node API compatibility shims, eliminating the need for Node.js or Bun while achieving sub-100ms cold start and sub-1ms warm start.

**Why this matters for Cubex**: The JavaScript extension ecosystem is massive. Being able to run JS extensions without requiring users to install Node.js dramatically reduces friction. Embedded execution also provides a natural security boundary — extensions run in a sandboxed interpreter, not as arbitrary OS processes.

**How it works**:
- **Runtime embedding**: Use `rquickjs` (QuickJS binding for Rust) to create isolated JavaScript contexts. Each extension gets its own context with controlled globals.
- **TypeScript support**: Transpile `.ts`/`.tsx`/`.mts`/`.cts` files at load time using SWC (Rust-native TypeScript compiler). No separate build step required. The transpiled JS is cached for warm reuse.
- **Node API shims**: Implement compatibility layers for common Node.js APIs:
  - `fs` → route to host filesystem via capability-gated hostcalls
  - `path` → pure JS reimplementation (join, resolve, basename, etc.)
  - `child_process` → route to exec hostcall with command mediation
  - `os`, `crypto`, `url` → partial implementations for common operations
- **Warm isolate reuse**: Pre-compile contexts during startup prewarm. When an extension is invoked:
  1. Check if a warm isolate exists for this extension ID.
  2. If yes, reset transient state and reuse (sub-1ms).
  3. If no, create new context from pre-compiled template (sub-100ms).
- **Capability routing**: JS code calls `pi.tool()`, `pi.exec()`, `pi.http()`, etc. These route through the hostcall dispatcher with full policy enforcement. Extensions cannot bypass the capability system.
- **Memory isolation**: Each extension context has its own heap. QuickJS provides deterministic garbage collection, and the system can terminate contexts that exceed memory budgets.

**Source**: `src/extensions_js.rs` (~846KB), `rquickjs` dependency in `Cargo.toml:114`

### 5. Deterministic Scheduler with Clock Abstraction (HIGH)

**The idea**: An event loop scheduler with formal invariants (single macrotask per tick, microtask fixpoint, total ordering via monotonic sequence counters) and a Clock trait that enables fully deterministic testing.

**Why this matters for Cubex**: Agent loops with timers, retries, and async completions are notoriously hard to test deterministically. Wall-clock dependencies make tests flaky. A deterministic scheduler with explicit invariants makes behavior reproducible and enables property-based testing of timing-sensitive code without sleep/timeout hacks.

**How it works**:
- **Monotonic sequence counter** (`Seq`): A u64 counter that increments on every event. Every timer, hostcall completion, and inbound event gets a unique, ordered seq number.
- **Macrotask kinds**: `TimerFired`, `HostcallComplete`, `InboundEvent`. The scheduler processes exactly one macrotask per tick.
- **Timer ordering**: Timers are sorted by `(deadline_ms, seq)`. Equal deadlines are broken by insertion order (seq), providing deterministic ordering.
- **Microtask drain**: After each macrotask, drain all microtasks to fixpoint before processing the next macrotask. This prevents interleaving that would make behavior order-dependent.
- **No reentrancy**: Hostcall completions are enqueued as macrotasks, never directly re-entered. This prevents stack overflow and ensures ordering guarantees hold.
- **Clock trait**: Abstract time source with two implementations:
  - `WallClock`: Uses `std::time::Instant` for production.
  - Test clocks: Advance time manually for deterministic testing. Tests can verify "after 5 seconds, this timer fires" without actually waiting 5 seconds.
- **Integration**: The scheduler's generic parameter `<C: SchedulerClock>` propagates through the extension dispatcher, enabling the entire extension system to run deterministically in tests.

**Source**: `src/scheduler.rs` (~141KB)

### 6. Segmented Session Store with Integrity Chain (HIGH)

**The idea**: A v2 session storage format using segmented append logs with offset indexes, SHA-256 chain hashing, and three resume modes (Full/ActivePath/Tail) for O(index+tail) session resumption on massive sessions.

**Why this matters for Cubex**: Long coding sessions can accumulate megabytes of conversation history. Plain JSONL requires parsing the entire file to resume. A segmented store with indexes enables fast resume by loading only what's needed (active branch, or last N entries), while chain hashing detects corruption or tampering.

**How it works**:
- **Segmented storage**: Session data is split across segment files (`0000000001.seg`, `0000000002.seg`, ...) that rotate at a configurable byte threshold. Each segment is an append-only log.
- **Frame format**: Each entry is wrapped in a `SegmentFrame` containing: schema version, segment_seq, frame_seq, entry_seq (monotonic), entry_id, parent_entry_id, entry_type, timestamp, payload_sha256, payload_bytes, and deferred-deserialization payload (`Box<RawValue>`).
- **Offset index**: A separate `offsets.jsonl` file maps entry_seq → (segment_seq, byte_offset, byte_length, crc32c). This enables O(1) random access to any entry without scanning segments.
- **Chain hashing**: Genesis hash is all zeros. Each frame's hash = SHA-256(previous_hash || frame_payload_sha256). This creates a tamper-evident chain — modifying any entry invalidates all subsequent hashes.
- **Resume modes**:
  - `Full`: Load all segments sequentially. Slowest but complete.
  - `ActivePath`: Read offset index to find leaf entry, walk parent_id chain back to root, load only those frames. Skips all branch entries.
  - `Tail(N)`: Read last N offset index entries, load only corresponding frames. Fastest for "just show me recent context."
- **Manifest**: Per-session metadata snapshot tracking counters (entries_total, messages_total, branches_total), integrity state (chain_hash, manifest_hash), and structural invariants (parent_links_closed, monotonic_entry_seq).
- **Checkpoints**: Periodic snapshots for crash recovery, stored in `checkpoints/` subdirectory.
- **Migration path**: Existing JSONL sessions can be migrated to V2 via `pi migrate` command.

**Source**: `src/session_store_v2.rs` (~63KB)

### 7. Command Mediation with Heredoc AST Analysis (HIGH)

**The idea**: Block dangerous shell commands in extension exec calls using two-stage classification: allowlist/blocklist for direct commands, then AST parsing of heredoc/inline-script content to catch payloads that regex would miss.

**Why this matters for Cubex**: Extensions that can execute shell commands are the highest-risk vector. Simple keyword blocking is easily bypassed by embedding dangerous commands inside heredocs, multi-line strings, or script wrappers. AST-level analysis catches these evasion techniques.

**How it works**:
- **Stage 1 — Direct command classification**:
  - Safe utilities allowlist: `ls`, `pwd`, `echo`, `cat`, `head`, `tail`, `wc`, etc.
  - Safe git subcommands: `status`, `log`, `diff`, `show`, `branch`, `tag`, `remote`.
  - Blocked destructive patterns: `push --force`, `reset --hard`, `clean`, `rm -rf`, etc.
  - Commands not in allowlist → Stage 2 analysis.
- **Stage 2 — Heredoc/inline-script analysis**:
  - Detect heredoc markers and extract embedded script content.
  - Identify script language: `RuntimeHeredocScriptLanguage` enum (Bash, Python, JavaScript, TypeScript, Ruby).
  - Assign severity: Critical (0.34), High (0.24), Medium (0.12) based on language risk profile.
  - Parse extracted script using `ast-grep-core` with language-specific tree-sitter grammars.
  - Match against dangerous AST patterns: recursive delete operations, disk/device writes, reverse shell constructs.
  - Each match generates a scored assessment combining language severity and pattern severity.
- **Enforcement**: Denied operations produce redacted security alerts (command hashed, not stored in plain text) and mediation ledger entries. The alert includes the denial reason, severity, and remediation guidance.

**Source**: `src/extensions.rs` (lines 6686-6854), `ast-grep-core` and `ast-grep-language` in `Cargo.toml:102-109`

### 8. Extension Validation Pipeline with 224-Extension Corpus (HIGH)

**The idea**: A multi-track automated validation pipeline that tests extension compatibility against a 224-extension vendored corpus, a 777-extension unvendored corpus, and live-provider E2E execution.

**Why this matters for Cubex**: Extension systems fail when they work in unit tests but break with real-world extensions and real providers. Testing against hundreds of actual extensions and real API responses catches compatibility issues before users hit them. This is the difference between "extensions work in theory" and "extensions work in practice."

**How it works**:
- **Track 1 — Vendored conformance** (224 extensions):
  - Deterministic conformance tests verify each extension's behavior against expected outputs.
  - Compatibility matrix tests each extension × provider combination.
  - Scenario suites test complex multi-step extension interactions.
  - Sharded execution for parallelism.
  - Auto-repair pass attempts to fix common extension issues programmatically.
  - Differential analysis detects behavioral changes between versions.
- **Track 2 — Unvendored acquisition** (777 extensions):
  - Fetch tool clones GitHub repos and unpacks npm tarballs.
  - Produces acquisition status and onboarding priority queue.
  - Extensions are scored for onboarding into the vendored corpus.
- **Track 3 — Release-binary live-provider E2E**:
  - First-set gate: 20 representative extensions run against debug binary with real provider (Ollama + qwen2.5:0.5b).
  - Full release: all 224 vendored extensions run against release binary with real provider.
  - Each case captures stdout/stderr and produces structured pass/fail results.
  - Required pass rate: 100% (fail-closed gate).
- **Artifacts**: Machine-readable reports (JSON) and human-readable summaries (Markdown) for each stage.

**Source**: `src/bin/ext_full_validation.rs` (~58KB), `src/bin/ext_release_binary_e2e.rs` (~31KB), `src/bin/ext_unvendored_fetch_run.rs` (~35KB), `src/conformance.rs` (~148KB)

### 9. Forensic Incident Evidence Bundles (MEDIUM-HIGH)

**The idea**: Package security events into tamper-evident evidence bundles with configurable redaction, filterable by time/extension/category/severity, sealed with SHA-256 integrity hashes.

**Why this matters for Cubex**: When something goes wrong with an extension, you need to answer "what happened, when, and who authorized it." Incident evidence bundles provide a compliance-grade audit trail that can be shared with security teams without exposing secrets (via redaction policies).

**How it works**:
- **Security alerts**: 7 categories (PolicyDenial, AnomalyDenial, ExecMediation, SecretBroker, QuotaBreach, Quarantine, ProfileTransition). Each alert has: schema version, monotonic sequence ID (prevents reordering), WHO/WHAT/WHY/ACTION fields, and SHA-256 redaction context hash.
- **Bundle creation**: `IncidentEvidenceBundle` filters alerts by: time range, extension ID, alert categories, severity threshold.
- **Redaction**: Configurable policy determines what's hashed vs. shown in cleartext. Command text, API keys, and file paths can be redacted to SHA-256 hashes while preserving the event structure.
- **Integrity seal**: SHA-256 hash of the serialized bundle sections. Any modification invalidates the seal.
- **Monotonic sequence IDs**: Alerts are numbered sequentially. Gaps in sequence numbers indicate deleted events (another tamper detection signal).

**Source**: `src/extensions.rs` (lines 5069-5310)

### 10. Two-Queue Message System for Agent Steering (MEDIUM-HIGH)

**The idea**: Separate priority and normal message queues that allow mid-turn interruption of agent processing via steering messages.

**Why this matters for Cubex**: Users and IDE integrations need to redirect the agent while it's working (e.g., "stop that, do this instead"). A single FIFO queue can't express priority. Two queues with steering checks at critical decision points enable responsive interruption without losing queued follow-up work.

**How it works**:
- **Two queues**: `steering` (priority) and `follow_up` (normal). Each has a configurable `QueueMode` (All — process everything, OneAtATime — process one item per cycle).
- **Steering check points**: The agent loop checks the steering queue at 4 points during tool execution:
  1. Before flushing parallel tool results
  2. Before executing an unsafe (state-mutating) tool
  3. Between each tool result processing
  4. Final check before flushing remaining parallel tools
- **Semantics**: If a steering message arrives, current tool execution completes (no abort) but the follow-up queue is paused. The agent processes the steering message first, then resumes follow-up.
- **RPC integration**: IDE clients send steering commands (`steer`, `abort`) via RPC. Follow-up messages are queued via `follow-up`/`queue-follow-up` commands.
- **Bounded**: Max 128 pending messages per queue to prevent memory exhaustion.

**Source**: `src/agent.rs` (lines 122-196, 1570-1714), `src/rpc.rs` (lines 62-190)

### 11. Bubbletea TUI Architecture in Rust (MEDIUM)

**The idea**: Port the Go bubbletea TUI framework to Rust (charmed_rust) and use Elm-style architecture (Model-Update-View) for the interactive terminal interface.

**Why this matters for Cubex**: Elm architecture provides clean separation between state, events, and rendering. The bubbletea pattern has proven successful in Go for building complex TUIs (Charm ecosystem). A Rust port brings the same ergonomics with Rust's performance and safety.

**How it works**:
- **Model**: `PiApp` struct holds all application state (input, viewport, messages, session, config, agent reference, performance telemetry).
- **Messages**: `PiMsg` enum with 40+ variants covering every user and system event.
- **Update**: `update(msg: PiMsg) -> Command` handles state transitions and produces side-effect commands.
- **View**: `view(&self) -> String` renders the current state to a string. Uses `RefCell`/`Cell` for interior mutability of performance counters (since bubbletea requires immutable `&self`).
- **Key innovations**: Auto-collapse for large tool outputs (>20 lines → 5-line preview + expand toggle). Viewport scroll stability: when content is appended during streaming, scroll position is maintained relative to the bottom. 60fps frame budget enforcement with timing metrics.

**Source**: `src/interactive.rs` (~83KB), `src/interactive/` (18 files, ~550KB total), `charmed-bubbletea`/`charmed-lipgloss`/`charmed-bubbles`/`charmed-glamour` in `Cargo.toml:66-69`

### 12. VCR HTTP Stream Testing (MEDIUM)

**The idea**: Record/replay infrastructure for HTTP streaming (SSE) responses that enables deterministic testing of LLM interactions without hitting real APIs.

**Why this matters for Cubex**: LLM provider tests that hit real APIs are slow, expensive, and flaky. VCR recording captures real responses once and replays them deterministically in all subsequent test runs. This is especially important for streaming responses (SSE) where chunk boundaries, timing, and partial data matter.

**How it works**:
- **Three modes**: Record (capture live responses to cassette files), Playback (replay from cassettes), Auto (record if cassette missing, playback if exists).
- **Cassette format**: JSONL files containing `Interaction` records with request (method, URL, headers, body) and response (status, headers, chunks).
- **Stream replay**: `into_byte_stream()` creates a Rust `Stream` from recorded chunks, supporting both UTF-8 string chunks and base64-encoded binary chunks. The stream faithfully reproduces chunk boundaries from the recording.
- **Integration**: The HTTP client has an optional `VcrRecorder` field. When enabled, all requests are intercepted — in record mode they're captured alongside real responses, in playback mode they return cassette data.
- **Configuration**: Cassette directory and mode controlled via environment variables (`VCR_CASSETTE_DIR`, `VCR_MODE`).

**Source**: `src/vcr.rs` (~79KB), integration in `src/http/client.rs`

### 13. Zero-Copy Provider Context Pattern (MEDIUM)

**The idea**: Use `Cow<'a>` (clone-on-write) for the provider context struct so message history, tools, and system prompt are borrowed by default and only cloned when mutation is needed.

**Why this matters for Cubex**: Provider requests happen on every turn. Deep-cloning the full message history (which can be megabytes) on every request wastes CPU and memory. `Cow` borrows by default and only clones if the provider needs to mutate — which most don't. This is a Rust-specific optimization that has no equivalent in GC'd languages.

**How it works**:
- **Context struct**: `Context<'a>` uses `Cow<'a, [Message]>` for messages, `Cow<'a, [ToolDef]>` for tools, and `Cow<'a, str>` for system prompt.
- **Provider flow**: The agent creates a `Context` that borrows its message vec. The provider receives `&Context<'_>` and reads fields through `Deref`. If a provider needs to add internal messages (e.g., for prompt caching markers), it calls `messages.to_mut()` which triggers a clone-on-first-write.
- **SSE event interning**: Same `Cow` pattern applied to SSE event types. Common types like `"message"`, `"content_block_delta"` are mapped to `Cow::Borrowed(&'static str)`, eliminating per-event heap allocation.
- **Truncation ownership transfer**: The truncation pipeline takes `String` by value and uses `String::truncate()` for in-place modification. If no truncation needed, the string is moved without allocation.

**Source**: `src/provider.rs` (line 62), `src/sse.rs` (lines 56-70), `src/tools.rs` (lines 165-303)

## Summary

pi_agent_rust's gifts to Cubex, in order of impact:

1. **Graduated Security Enforcement Rollout** — Deploy extension security policies incrementally with automatic rollback on degradation, solving the "can't ship strict policies without breaking extensions" problem.
2. **Statistical Safety Envelopes** — Conformal prediction + PAC-Bayes bounds for extension anomaly detection with mathematically calibrated false-positive guarantees, replacing heuristic thresholds.
3. **Hostcall Reactor Mesh** — Six-layer performance optimization pipeline (S3-FIFO, trace JIT, superinstructions, AMAC, io_uring, dual-exec sampling) for extension dispatch, with correctness verification via shadow execution.
4. **Embedded QuickJS with Node Shims** — Run JS/TS extensions without Node/Bun in sub-100ms cold / sub-1ms warm start, with SWC transpilation and capability-gated host connectors.
5. **Deterministic Scheduler** — Formal invariants + Clock abstraction enabling fully reproducible event loop behavior, critical for testing timing-sensitive agent logic.
6. **Segmented Session Store** — O(index+tail) resume for massive sessions via segmented logs, offset indexes, and SHA-256 chain hashing for integrity.
7. **Heredoc AST Command Mediation** — AST-level (not regex) analysis of embedded scripts in heredocs using tree-sitter grammars, catching evasion techniques that text matching misses.
8. **224-Extension Validation Pipeline** — Multi-track testing against real extensions and live providers, proving compatibility at scale rather than in theory.
9. **Forensic Evidence Bundles** — Tamper-evident, redactable security event packages with monotonic IDs and integrity seals for compliance-grade audit trails.
10. **Two-Queue Agent Steering** — Priority message queue with 4-point interruption checks for responsive mid-turn agent redirection.
11. **Bubbletea TUI in Rust** — Elm-style architecture with 60fps frame budget, auto-collapse for large outputs, and scroll-stable streaming viewport.
12. **VCR Stream Testing** — Record/replay for SSE streaming responses enabling deterministic LLM interaction testing.
13. **Zero-Copy Provider Context** — Cow-based borrowing pattern that eliminates deep-cloning of message history on every provider request.
