# claude-code Findings (Deep Dive)

## Scope and Method

- **What was explored**: The open-source portion of Anthropic's Claude Code CLI agent, located at `/data/projects/cubex/claude-code`. This repository contains no proprietary source code — the actual CLI is closed-source. What IS available: the complete plugin architecture (12 official plugins with commands, agents, skills, hooks), the extensibility formats and schemas, settings/permissions examples, DevContainer sandboxing configuration, GitHub Actions workflows for AI-powered issue management, and a ~1300-line CHANGELOG that reveals deep architectural decisions about the proprietary internals.
- **How**: Three parallel exploration agents were launched covering (A) existing findings from all 7 other repos for differentiation context, (B) plugin system architecture — every plugin.json, agent definition, command definition, skill file, and hook configuration, (C) infrastructure — settings hierarchy, hooks examples, DevContainer/firewall, GitHub workflows, CHANGELOG analysis.
- **Primary sources reviewed**: All files in `plugins/` (12 plugins with ~70 files total), `examples/settings/` (3 settings configurations), `examples/hooks/` (Python hook validator), `.devcontainer/` (Dockerfile, devcontainer.json, init-firewall.sh), `.github/workflows/` (10 workflow files), `.claude/commands/` (3 built-in commands), `scripts/` (4 scripts), `CHANGELOG.md` (~1300 lines), `README.md`, `SECURITY.md`, `.claude-plugin/marketplace.json`.

## README Alignment: What Is Unique About This Project

The README describes Claude Code as "an agentic coding tool that lives in your terminal, understands your codebase, and helps you code faster by executing routine tasks, explaining complex code, and handling git workflows."

**Claim 1: "Agentic coding tool that lives in your terminal"**
Verified. The CHANGELOG reveals a rich terminal experience including Vim motions (`2.1.0`), `readline` keybindings, Ctrl+R history search (`2.0.0`), customizable keybindings (`2.1.18`), PTY management, and a rewritten terminal renderer (`2.0.10`). The system prompt in my context confirms a full TUI with thinking display, progress spinners, and multi-line input.

**Claim 2: "Understands your codebase"**
Verified. The plugin system demonstrates dedicated exploration agents (`plugins/feature-dev/agents/code-explorer.md`), LSP integration (`2.0.74`), CLAUDE.md hierarchical memory (`2.0.64`), auto-memory that Claude proactively maintains (`2.1.59`), and @-mention file reference system with fuzzy matching.

**Claim 3: Plugin extensibility**
Verified extensively. The `plugins/` directory contains 12 official plugins demonstrating a comprehensive 5-component plugin format: commands, agents, skills, hooks, and MCP servers. Plugin marketplace with git-based distribution, version pinning (`2.1.14`), and npm source support (`2.1.51`).

**Genuine identity**: Claude Code is the most production-hardened, enterprise-focused agent CLI in this collection. Its differentiator is not raw capability but the maturity of its extension model, the sophistication of its permission/safety architecture, and the depth of its multi-agent orchestration — all battle-tested at Anthropic's scale with thousands of daily users. The open-source portion reveals the extensibility surface, not the engine.

## Architecture Overview

Claude Code is a TypeScript/Node.js CLI application (with Bun support) that follows a tool-use agent loop powered by Anthropic's Claude models. The architecture is not visible as source code, but the CHANGELOG and plugin system reveal the following:

- **Agent loop**: Standard tool-use loop with streaming, thinking mode (extended thinking with budget tokens), context compaction (auto-compact when approaching limits), and session persistence (JSONL transcripts).
- **Extension layer**: A 5-component plugin system (commands, agents, skills, hooks, MCP servers) with auto-discovery, marketplace distribution, and enterprise policy controls.
- **Safety layer**: Hierarchical permission model (session → project → user → managed), bash sandboxing (Linux/macOS), network domain allowlisting, and event-driven hooks for pre/post tool validation.
- **Multi-agent layer**: Agent Teams feature with tmux-based process isolation, git worktree isolation, background agents, task dependency tracking, and inter-agent messaging.

**Module/directory map**:
- `.claude/commands/` — Built-in slash commands (markdown format)
- `.claude/agents/` — Custom agent definitions (markdown with YAML frontmatter)
- `.claude/skills/` — Knowledge packages (SKILL.md with references)
- `plugins/` — 12 official plugins demonstrating the full extension surface
- `examples/settings/` — Settings hierarchy examples (lax, strict, sandbox)
- `examples/hooks/` — Hook implementation examples
- `.devcontainer/` — Sandboxed execution environment with network firewall
- `.github/workflows/` — AI-powered issue management (triage, dedup, sweep)
- `scripts/` — Automation scripts (GitHub CLI wrapper, lifecycle management)

**Key abstractions**:
- **Plugin**: A distributable package containing any combination of commands, agents, skills, hooks, and MCP servers, with a `plugin.json` manifest.
- **Hook**: An event handler (shell command, LLM prompt, or HTTP endpoint) that intercepts agent lifecycle events with the ability to allow, block, or modify operations.
- **Agent definition**: A markdown file with YAML frontmatter specifying model, tools, color, memory scope, and a system prompt body.
- **Skill**: A knowledge package with progressive loading — metadata only until triggered, then full SKILL.md plus references.

## Feature Analysis

### 1. Unified Plugin Architecture (plugins/)

**What it is**: A 5-component extension format that bundles commands, agents, skills, hooks, and MCP servers into a single distributable package with auto-discovery, marketplace distribution, and enterprise policy controls.

**Key files**: `plugins/*/. claude-plugin/plugin.json` (12 manifests, ~20 lines each), `plugins/README.md` (~75 lines), `.claude-plugin/marketplace.json` (~150 lines)

**How it works**: Each plugin lives in a directory with a `.claude-plugin/plugin.json` manifest containing name, description, version, and author. Components are auto-discovered by directory convention: `commands/` for slash commands (`.md` files), `agents/` for agent definitions (`.md` files with YAML frontmatter), `skills/{name}/SKILL.md` for knowledge packages, `hooks/hooks.json` for event handlers, and `.mcp.json` for MCP server configuration. The `${CLAUDE_PLUGIN_ROOT}` variable provides portable path references. Distribution happens via git-based marketplaces (configured in `marketplace.json`) or npm registries. Plugins support version pinning to specific git commit SHAs, branch/tag targeting via fragment syntax (`owner/repo#branch`), and custom npm registries. Enterprise settings can restrict plugins to `strictKnownMarketplaces` only.

**Notable details**: Auto-discovery means no explicit registration — drop files in the right directories and they're found. Plugins can ship their own `settings.json` for default configuration. Hot-reload is supported for skills (`2.1.0`). Plugin-provided hooks, commands, agents, and skills are available immediately after installation without restart (`2.1.45`).

### 2. Event-Driven Hook Lifecycle (hooks system)

**What it is**: A comprehensive event-driven system with 10+ lifecycle events, three handler types (command, prompt-based, HTTP), and the ability to modify tool inputs, block execution, inject context, or intercept session lifecycle.

**Key files**: `plugins/security-guidance/hooks/hooks.json` (~15 lines), `plugins/ralph-wiggum/hooks/stop-hook.sh` (~178 lines), `plugins/explanatory-output-style/hooks/hooks.json` (~15 lines), `examples/hooks/bash_command_validator_example.py` (~83 lines)

**How it works**: Hooks are configured in `hooks.json` with event type → matcher → handler chain structure. Events include: `PreToolUse` (before tool execution, can allow/block/modify), `PostToolUse` (after completion, can react), `Stop` (before session exit, can block and feed prompt back), `SessionStart` (inject context at session start), `ConfigChange` (audit settings changes), `WorktreeCreate`/`WorktreeRemove` (worktree lifecycle), `SubagentStart`/`SubagentStop` (subagent lifecycle), `TeammateIdle`/`TaskCompleted` (team events), `UserPromptSubmit` (prompt validation), `PermissionRequest` (auto-approve/deny permissions), and `Notification` (notification filtering). Matchers filter by tool name (e.g., `"matcher": "Edit|Write|MultiEdit"`). Command handlers receive JSON on stdin with `tool_name`, `tool_input`, `transcript_path`, and return JSON on stdout with `decision` (allow/block), `reason`, `additionalContext`, and optionally `updatedInput` (for modifying tool inputs). Exit codes: 0=allow, 1=show stderr to user, 2=block and show stderr to model. Timeout defaults to 10 minutes (changed from 60s in `2.1.3`).

**Notable details**: PreToolUse hooks can return `updatedInput` to modify tool inputs before execution, effectively acting as middleware (`2.0.10`, `2.1.0`). Hooks can return `additionalContext` to inject information into the model's context. Hooks support `once: true` config to run only once per session (`2.1.0`). Agents and skills can define their own scoped hooks via frontmatter (`2.1.0`). The `PermissionRequest` hook enables fully automated permission handling (`2.0.45`).

### 3. Prompt-Based Hooks (LLM-as-hook-evaluator)

**What it is**: A hook handler type that uses the LLM itself to evaluate whether a tool use is appropriate, replacing deterministic shell scripts with context-aware AI judgment.

**Key files**: Referenced in `plugins/plugin-dev/skills/hook-development/SKILL.md`, CHANGELOG entries at `2.0.30` (prompt-based stop hooks), `2.0.41` (custom model for hook evaluation)

**How it works**: Instead of `"type": "command"` with a shell script, hooks use `"type": "prompt"` with a natural language prompt. The prompt receives the tool input context and the LLM evaluates the decision. Supported for Stop, SubagentStop, UserPromptSubmit, and PreToolUse events. A `model` parameter allows specifying which model evaluates the hook (e.g., using Haiku for fast, cheap evaluation). The LLM returns a structured decision (allow/block with reasoning).

**Notable details**: This creates a spectrum from deterministic validation (command hooks) to nuanced judgment (prompt hooks) to external service integration (HTTP hooks). HTTP hooks (`2.1.63`) POST JSON to a URL and receive JSON back, enabling integration with external services. This three-tier hook handler model (command/prompt/HTTP) covers deterministic rules, AI judgment, and external systems.

### 4. Hierarchical Enterprise Settings with Policy Enforcement (settings system)

**What it is**: A multi-level settings hierarchy where enterprise-managed settings override user and project settings, with granular controls over permissions, hooks, marketplaces, and sandboxing.

**Key files**: `examples/settings/settings-strict.json` (~28 lines), `examples/settings/settings-lax.json` (~7 lines), `examples/settings/settings-bash-sandbox.json` (~20 lines), `examples/settings/README.md` (~32 lines)

**How it works**: Settings resolve through a hierarchy: session → project → user → managed (enterprise). Enterprise-only controls include: `disableBypassPermissionsMode` (prevents `--dangerously-skip-permissions`), `allowManagedPermissionRulesOnly` (blocks user/project permission rules), `allowManagedHooksOnly` (blocks user/project hooks), `strictKnownMarketplaces` (restricts plugin sources), and `allowUnsandboxedCommands` (disables sandbox escape hatch). The permissions model supports three tiers: `allow` (auto-approve), `ask` (require confirmation), `deny` (block entirely), each scoped to specific tools or tool+pattern combinations (e.g., `Bash(git add:*)`). Tool permission patterns support wildcards at any position (`Bash(npm *)`, `Bash(* install)`, `Bash(git * main)`). Managed settings can be deployed via macOS plist or Windows Registry (`2.1.51`). A `ConfigChange` hook event enables auditing and optionally blocking settings changes (`2.1.49`).

**Notable details**: The sandbox configuration includes network controls (`allowedDomains`, `httpProxyPort`, `socksProxyPort`, `allowUnixSockets`, `allowLocalBinding`), command exclusions (`excludedCommands`), and nested sandbox support (`enableWeakerNestedSandbox`). The `autoAllowBashIfSandboxed` flag auto-approves sandboxed commands without prompting. The strict settings example blocks web access entirely (`deny: ["WebSearch", "WebFetch"]`). Config backups are timestamped and rotated (keeping 5 most recent) to prevent data loss (`2.1.20`).

### 5. Skill System with Description-Triggered Auto-Loading (skills/)

**What it is**: Knowledge packages that auto-load when the user's intent matches the skill's description, with progressive disclosure (metadata only until triggered, then full content plus references).

**Key files**: `plugins/frontend-design/skills/frontend-design/SKILL.md` (~300 lines), `plugins/claude-opus-4-5-migration/skills/claude-opus-4-5-migration/SKILL.md` (~200 lines), `plugins/plugin-dev/skills/*/SKILL.md` (7 skill files)

**How it works**: Each skill is a directory containing a `SKILL.md` file with YAML frontmatter (`name`, `description`, `version`) and a markdown body with knowledge content. The description field contains trigger phrases: "This skill should be used when the user asks to..." followed by specific activation phrases. The system matches user intent against skill descriptions and auto-loads matching skills. Skills support subdirectories: `references/` for detailed documentation, `scripts/` for executable helpers, `assets/` for templates, and `examples/` for working code. Skills can declare `context: fork` to run in a forked sub-agent context (`2.1.0`), specify an `agent` field for execution type, and `user-invocable: false` to hide from the slash command menu. The skill character budget scales with context window (2% of context, `2.1.32`). Skills support YAML-style lists in frontmatter `allowed-tools` for tool restrictions.

**Notable details**: Skills from `~/.claude/skills/` (user-level) and `.claude/skills/` (project-level) are both discovered automatically. Skills in additional directories (`--add-dir`) are also loaded (`2.1.32`). Hot-reload is supported — modified skills are immediately available (`2.1.0`). Recently and frequently used skills are prioritized in suggestions (`2.1.0`). Skills can auto-load other skills for subagents via a `skills` frontmatter field (`2.0.43`). The `${CLAUDE_SESSION_ID}` variable is available for session-aware skills (`2.1.9`).

### 6. Agent Definition via Markdown Frontmatter (agents/)

**What it is**: Declarative agent definitions using markdown files with YAML frontmatter for model selection, tool restrictions, color coding, memory scope, hooks, and example-based triggering.

**Key files**: `plugins/feature-dev/agents/code-explorer.md` (~52 lines), `plugins/feature-dev/agents/code-architect.md` (~50 lines), `plugins/code-review/commands/code-review.md` (~110 lines — defines multi-agent orchestration), `plugins/hookify/agents/conversation-analyzer.md` (~177 lines)

**How it works**: Each agent is a `.md` file in `.claude/agents/` or a plugin's `agents/` directory. YAML frontmatter specifies: `name` (kebab-case identifier), `description` (with `<example>` blocks for triggering), `model` (sonnet/opus/haiku/inherit), `tools` (array of allowed tools for least-privilege), `color` (visual identifier), `memory` (user/project/local scope for persistent memory, `2.1.33`), `background` (always run as background task, `2.1.49`), `isolation` (worktree for git isolation, `2.1.50`), `permissionMode` (custom permission level, `2.0.43`), `disallowedTools` (explicit tool blocking, `2.0.30`), and `hooks` (scoped PreToolUse/PostToolUse/Stop hooks, `2.1.0`). The markdown body is the system prompt. Tool restrictions support sub-agent spawning control via `Task(agent_type)` syntax (`2.1.33`). Agents can specify a custom `model` field that is respected when spawning team teammates (`2.1.47`). The `description` field uses `<example>` blocks with `Context:`, `user:`, `assistant:`, and `<commentary>` sections to define triggering conditions.

**Notable details**: Agents can be listed via `claude agents` CLI command (`2.1.50`). Agents from additional directories (`--add-dir`) are discovered automatically. The `--agent` CLI flag overrides the agent setting for the session (`2.0.59`). Resumed sessions re-use the previous `--agent` value by default (`2.0.28`). The `agent` setting allows configuring the main thread itself with a specific agent's system prompt, tool restrictions, and model (`2.0.59`). Agents with scoped hooks have those hooks active only during the agent's lifecycle.

### 7. Slash Command Architecture with Dynamic Context Injection (commands/)

**What it is**: Markdown-defined slash commands with YAML frontmatter for tool restrictions and a body that serves as the prompt, including `!` prefix for injecting live bash output into the command context.

**Key files**: `plugins/commit-commands/commands/commit.md` (~40 lines), `plugins/feature-dev/commands/feature-dev.md` (~126 lines), `plugins/code-review/commands/code-review.md` (~110 lines), `.claude/commands/triage-issue.md` (~100 lines)

**How it works**: Commands are `.md` files in `.claude/commands/` or a plugin's `commands/` directory, triggered via `/command-name`. YAML frontmatter specifies `description`, `argument-hint` (parameter documentation), and `allowed-tools` (tool restrictions). The `allowed-tools` field supports fine-grained patterns: `Bash(git add:*)` restricts to git add commands only, `Bash(gh pr view:*)` allows only PR viewing. The markdown body is the prompt Claude follows. Dynamic context injection uses the `!` prefix followed by a backtick-delimited bash command: ``!`git status` `` executes and injects the output into the prompt. User arguments are accessed via `$ARGUMENTS`, with indexed syntax `$ARGUMENTS[0]`, `$ARGUMENTS[1]` for individual args. Plugin paths use `${CLAUDE_PLUGIN_ROOT}`. Commands from `/skills/` directories are visible in the slash command menu by default (`2.1.0`). Colon syntax groups related commands: `/pr-review-toolkit:review-pr` separates plugin name from command name.

**Notable details**: Commands can orchestrate multi-agent workflows entirely through prompt engineering. The `code-review.md` command defines a 9-step pipeline: launch validation agent → load CLAUDE.md → get PR summary → launch 4 parallel review agents → validate each issue with subagents → filter false positives → post inline comments. The `feature-dev.md` command defines a 7-phase workflow with user gates at each phase. Commands automatically skip approval when they have no additional permissions beyond what's already granted (`2.1.19`). Slash command suggestions prioritize recently and frequently used commands.

### 8. Self-Referential Loop via Stop Hook (Ralph Wiggum pattern)

**What it is**: A Stop hook pattern that intercepts session exit, reads the transcript, detects completion promises via XML tags, and feeds the same prompt back for iterative autonomous loops.

**Key files**: `plugins/ralph-wiggum/hooks/stop-hook.sh` (~178 lines), `plugins/ralph-wiggum/commands/ralph-loop.md` (command to start loops), `plugins/ralph-wiggum/commands/cancel-ralph.md` (command to stop loops)

**How it works**: When activated via `/ralph-loop`, state is stored in `.claude/ralph-loop.local.md` as YAML frontmatter (iteration counter, max_iterations limit, completion_promise string, and the prompt text below the frontmatter). The Stop hook runs when Claude attempts to exit. It reads the state file, extracts the current iteration and completion promise, reads the transcript JSONL to get the last assistant message, and checks for a `<promise>` XML tag in the output. If the promise text matches the completion_promise string, the loop ends. If not, the hook returns `{"decision": "block", "reason": "<original-prompt>", "systemMessage": "iteration N"}` — this blocks the exit and feeds the original prompt back as a new user message. The iteration counter is atomically updated via temp file + mv. Numeric fields are validated before arithmetic. Corrupted state files are detected and cleaned up gracefully. The completion promise uses Perl for multiline XML tag extraction with non-greedy matching.

**Notable details**: The `jq -r` pipeline extracts text content from the JSONL transcript format: `grep '"role":"assistant"' | tail -1 | jq '.message.content | map(select(.type == "text")) | map(.text) | join("\n")'`. The system message includes the iteration count and the completion promise text, creating a meta-awareness loop. String comparison uses `=` instead of `==` in `[[ ]]` to avoid glob pattern matching with special characters. The pattern is general-purpose — any iterative task can be expressed as "repeat this prompt until the agent outputs `<promise>DONE</promise>`."

### 9. Confidence-Based Multi-Agent Code Review Pipeline (code-review plugin)

**What it is**: A multi-step PR review workflow using 4-6 parallel specialized agents with validation subagents and confidence scoring (≥80 threshold) to eliminate false positives.

**Key files**: `plugins/code-review/commands/code-review.md` (~110 lines), `plugins/pr-review-toolkit/commands/review-pr.md` (~190 lines), `plugins/pr-review-toolkit/agents/` (6 agent files)

**How it works**: The code-review plugin orchestrates a 9-step pipeline: (1) Haiku agent pre-checks (PR closed? draft? trivial? already reviewed?), (2) Haiku agent finds all relevant CLAUDE.md files scoped by modified file paths, (3) Sonnet agent summarizes PR changes, (4) Four parallel agents review — 2 Sonnet agents for CLAUDE.md compliance, 2 Opus agents for bugs and logic errors, (5) For each issue found by bug agents, launch parallel validation subagents that independently verify the issue exists in the code (Opus for bugs, Sonnet for CLAUDE.md violations), (6) Filter unvalidated issues, (7) Output summary, (8) If `--comment` flag provided, post inline GitHub comments with committable suggestion blocks for small fixes. The system has an explicit false positive exclusion list: pre-existing issues, pedantic nitpicks, linter-catchable issues, silenced lint warnings, and general code quality concerns. The PR review toolkit extends this with 6 specialized agents: comment-analyzer, pr-test-analyzer, silent-failure-hunter, type-design-analyzer, code-reviewer, and code-simplifier.

**Notable details**: The pipeline uses model-tiered agents: Haiku for cheap validation, Sonnet for compliance checks, Opus for bug detection. Each agent type is chosen for the complexity of its task. The validation step (step 5) is the key innovation — instead of trusting agent findings directly, independent subagents verify each issue. The false positive list is explicitly defined in the prompt, not learned. The "only flag where you are CERTAIN" instruction is repeated multiple times in different phrasings.

### 10. MCP Tool Search with Auto-Deferral (context management)

**What it is**: When MCP tool descriptions exceed 10% of the context window, they are automatically deferred and discovered via a `ToolSearch` tool instead of being loaded upfront, reducing context usage.

**Key files**: Documented in CHANGELOG `2.1.7` (auto mode enabled by default), `2.1.9` (`auto:N` syntax for custom threshold), system prompt `ToolSearch` tool definition

**How it works**: At session start, the system calculates the total token count of all MCP tool descriptions. If they exceed a configurable percentage of the context window (default 10%), tools are not included in the system prompt. Instead, a `ToolSearch` meta-tool is injected that accepts keyword queries or `select:<tool_name>` for direct selection. When the model needs an MCP tool, it first calls `ToolSearch` to discover and load the tool, then calls the tool itself. The `auto:N` syntax (e.g., `auto:5` for 5%) allows configuring the threshold. Users can disable this by adding `MCPSearch` to `disallowedTools`. Tools returned by `ToolSearch` are immediately available to call — no further selection step needed. The system supports both keyword search (returns up to 5 matching tools ranked by relevance) and direct selection (returns just that one tool).

**Notable details**: This solves a real scaling problem — users with many MCP servers configured (Slack, GitHub, databases, etc.) can have hundreds of tool descriptions consuming tens of thousands of tokens. The deferred loading pattern means context is only consumed when tools are actually needed. MCP auth failures are cached to avoid repeated connection attempts during startup (`2.1.49`). MCP tool token counting is batched into a single API call (`2.1.49`).

### 11. Hookify: Conversation-to-Hook Pipeline (hookify plugin)

**What it is**: An AI agent that analyzes conversation transcripts to identify problematic behaviors (user frustrations, corrections, repeated mistakes) and automatically generates hook rules to prevent those behaviors in future sessions.

**Key files**: `plugins/hookify/agents/conversation-analyzer.md` (~177 lines), `plugins/hookify/commands/configure.md` (~129 lines), `plugins/hookify/skills/writing-rules/SKILL.md`

**How it works**: When the user runs `/hookify` without arguments, the conversation-analyzer agent reads the current transcript in reverse chronological order, looking for frustration signals: explicit corrections ("Don't use X", "Stop doing Y"), frustrated reactions ("Why did you do X?"), user reversions of Claude's changes, and repeated issues. For each identified behavior, the agent determines which tool was involved (Bash, Edit, Write), extracts a regex pattern from the problematic action, categorizes severity (high=block, medium=warn, low=optional), and outputs a structured analysis. The system then generates `.claude/hookify.{rule-name}.local.md` files with YAML frontmatter (`name`, `enabled`, `event`, `pattern`, `action`) and a markdown body with the warning message. The `/hookify:configure` command provides an interactive toggle interface for enabling/disabling rules. Rules are per-project and take effect immediately without restart.

**Notable details**: The agent explicitly handles edge cases: hypothetical discussions ("What would happen if..."), teaching moments ("Here's what you shouldn't do..."), one-time accidents (low priority), and subjective preferences (let user decide). The regex pattern extraction is the key challenge — the agent must convert observed behavior into a matchable pattern without being overly broad. This is a meta-capability: the agent learns from its own mistakes and creates guardrails to prevent them.

### 12. Structured Feature Development Workflow (feature-dev plugin)

**What it is**: A 7-phase structured workflow for feature development with user gates at each phase, parallel agent orchestration, and explicit "understand before acting" philosophy.

**Key files**: `plugins/feature-dev/commands/feature-dev.md` (~126 lines), `plugins/feature-dev/agents/code-explorer.md` (~52 lines), `plugins/feature-dev/agents/code-architect.md` (~50 lines), `plugins/feature-dev/agents/code-reviewer.md` (~50 lines)

**How it works**: Phase 1 (Discovery): Clarify what needs to be built. Phase 2 (Codebase Exploration): Launch 2-3 code-explorer agents in parallel with different foci (similar features, architecture, UI patterns). Each returns a list of 5-10 key files. The orchestrator then reads all identified files to build deep context. Phase 3 (Clarifying Questions): Identify all underspecified aspects before designing. Phase 4 (Architecture Design): Launch 2-3 code-architect agents with different approaches (minimal changes, clean architecture, pragmatic balance), present tradeoffs and recommendation to user. Phase 5 (Implementation): Wait for explicit user approval. Phase 6 (Quality Review): Launch 3 code-reviewer agents (simplicity/DRY, bugs/correctness, conventions). Phase 7 (Summary): Document what was built.

**Notable details**: The "CRITICAL: do not skip" annotation on Phase 3 (Clarifying Questions) reflects learned experience about premature implementation. The architecture design phase produces multiple approaches rather than a single recommendation, reflecting the principle that architectural decisions should be user-driven. The code-explorer agent uses a read-only tool set (`Glob, Grep, LS, Read, NotebookRead, WebFetch`) to prevent any modifications during analysis.

### 13. AI-Powered Issue Management Workflows (.github/workflows/)

**What it is**: GitHub Actions workflows that use Claude as an automated issue triage agent, duplicate detector, and lifecycle manager.

**Key files**: `.github/workflows/claude-issue-triage.yml` (~30 lines), `.github/workflows/claude-dedupe-issues.yml` (~40 lines), `.github/workflows/sweep.yml` (~20 lines), `.claude/commands/triage-issue.md` (~100 lines), `.claude/commands/dedupe.md` (~80 lines), `scripts/sweep.ts` (~200 lines), `scripts/gh.sh` (~80 lines)

**How it works**: Three automated workflows: (1) **Issue Triage** — on issue open or comment, Claude (Opus) analyzes the issue and applies category labels (bug, enhancement, question) and lifecycle labels (`needs-repro` 7d, `needs-info` 7d, `stale` 14d, `autoclose` 14d). Lifecycle labels include timeout-based auto-closure. Concurrency groups prevent parallel triage of the same issue. (2) **Duplicate Detection** — on issue open, Claude (Sonnet) launches 5 parallel search agents with diverse keywords, filters false positives, and posts a comment linking max 3 duplicate issues. Auto-closes in 3 days unless user reacts with thumbs-up or thumbs-down. Events are logged to Statsig for analytics. (3) **Lifecycle Sweep** — runs twice daily via cron, marks unassigned issues inactive >14 days as "stale", closes issues where lifecycle labels expired. Issues with ≥10 upvotes bypass lifecycle management. The `gh.sh` script is a whitelist-first GitHub CLI wrapper that only allows specific subcommands and flags.

**Notable details**: The triage system runs with `timeout-minutes: 10` to prevent runaway costs. The dedupe system uses 5 parallel search agents with "diverse keywords" to maximize recall. The sweep system has a `STALE_UPVOTE_THRESHOLD = 10` constant — popular issues are never auto-closed. The `gh.sh` security wrapper rejects repo/org/user scoping in searches and only allows whitelisted flags (`--comments`, `--state`, `--limit`, `--label`), preventing Claude from accessing unrelated repositories.

### 14. DevContainer Network Sandboxing (devcontainer/)

**What it is**: A Docker-based development environment with iptables/ipset network firewall that implements allow-list-only outbound access.

**Key files**: `.devcontainer/init-firewall.sh` (~138 lines), `.devcontainer/devcontainer.json` (~25 lines), `.devcontainer/Dockerfile` (~50 lines)

**How it works**: The container starts with `NET_ADMIN` and `NET_RAW` capabilities. On post-start, `init-firewall.sh` executes: (1) Extract Docker DNS rules before flushing, (2) Flush all iptables rules and ipsets, (3) Restore Docker DNS rules, (4) Allow DNS (UDP 53), SSH (TCP 22), and localhost, (5) Create `allowed-domains` ipset (hash:net with CIDR support), (6) Dynamically fetch GitHub IP ranges from `api.github.com/meta` and aggregate with `aggregate -q`, (7) Resolve and add IPs for registry.npmjs.org, api.anthropic.com, sentry.io, statsig.anthropic.com, marketplace.visualstudio.com, etc., (8) Detect host network from default route and allow host communication, (9) Set default INPUT/FORWARD/OUTPUT policies to DROP, (10) Add ESTABLISHED/RELATED connection tracking, (11) Allow only traffic to `allowed-domains` ipset, (12) REJECT everything else with `icmp-admin-prohibited` for immediate feedback, (13) Verify by confirming example.com is blocked and api.github.com is accessible.

**Notable details**: Every IP and CIDR is validated with regex before adding to ipset. DNS failures are treated as fatal errors (the script exits). The `aggregate -q` command combines overlapping CIDR blocks from GitHub's meta API. The REJECT rule (vs DROP) provides immediate feedback to failed connections rather than timeout. Persistent volumes preserve bash history and `.claude` config across container restarts. NODE_OPTIONS sets `--max-old-space-size=4096` for memory-intensive sessions.

### 15. Agent Teams with Worktree Isolation (multi-agent)

**What it is**: Multi-agent coordination using tmux-based process isolation, git worktree isolation, background agents, task dependency tracking, and inter-agent messaging.

**Key files**: Documented in CHANGELOG `2.1.32` (teams feature), `2.1.49` (worktree flag, background agents), `2.1.50` (worktree isolation in agent definitions, agents CLI command), system prompt (SendMessage, TeamCreate, TaskCreate tools)

**How it works**: Agent Teams enables spawning multiple agent processes coordinated through a shared task list and message bus. Teams are created with `TeamCreate` which creates a team config file (`~/.claude/teams/{team-name}/config.json`) and a task directory (`~/.claude/tasks/{team-name}/`). Teammates are spawned via the `Agent` tool with `team_name` and `name` parameters, each running as a separate process in tmux. Tasks are managed through `TaskCreate`/`TaskUpdate`/`TaskList` with status workflow (pending → in_progress → completed) and dependency tracking (`blockedBy`, `blocks`). Teammates communicate via `SendMessage` (direct message, broadcast, shutdown_request/response, plan_approval_request/response). Each teammate discovers others by reading the team config file. Worktree isolation (`isolation: "worktree"` in agent frontmatter) creates a temporary git worktree so the agent works on an isolated copy of the repo. Background agents (`background: true`) run without blocking the main thread. Ctrl+F kills all background agents (two-press confirmation). Ctrl+B backgrounds running foreground tasks.

**Notable details**: Messages from teammates are automatically delivered — no manual inbox polling. Teammates go idle after every turn, which is normal behavior. The system sends idle notifications with peer DM summaries for visibility. Plan mode is supported for teammates with `plan_mode_required`. The `mode` parameter supports `acceptEdits`, `bypassPermissions`, `default`, `dontAsk`, and `plan`. Completed teammate tasks are garbage-collected from session state (`2.1.50`). The `max_turns` parameter limits API round-trips for warmup. Agent context is released after task completion to manage memory (`2.1.47`).

### 16. Auto-Memory System (memory)

**What it is**: Claude proactively saves useful context and patterns to persistent memory files that carry across sessions, managed via CLAUDE.md hierarchy and `/memory` command.

**Key files**: Documented in CHANGELOG `2.1.59` (auto-memory), `2.1.32` (automatic recording/recall), `2.0.64` (CLAUDE.md rules), agent frontmatter `memory` field (`2.1.33`)

**How it works**: CLAUDE.md files form a hierarchical memory system: `~/.claude/CLAUDE.md` (global, loaded always), `project/.claude/CLAUDE.md` (project-level, loaded for that project), and nested CLAUDE.md files in subdirectories (loaded when working in those directories). Auto-memory (`2.1.59`) means Claude proactively identifies useful patterns, conventions, and user preferences during a session and saves them to the appropriate CLAUDE.md scope without being asked. The `/memory` command provides management. Agents can have their own memory scope via the `memory` frontmatter field: `user` (persists across all projects), `project` (persists for this project), or `local` (session-local). Memory files from additional directories (`--add-dir`) are also loaded. CLAUDE.md files support `@~/.path/to/file` import directives for modular organization. Binary files are excluded from `@include` directives (`2.1.2`). Memory is shared across git worktrees of the same repository (`2.1.63`).

**Notable details**: The auto-memory feature is distinct from user-directed memory — Claude decides what's worth remembering based on session context. The `/memory` command provides a management interface. Project configs and auto-memory are shared across worktrees (`2.1.63`). The `CLAUDE_CODE_SIMPLE` mode disables CLAUDE.md loading entirely for minimal sessions.

### 17. Bash Permission Pattern Matching (permission classifier)

**What it is**: A sophisticated pattern matching system for bash command permissions that supports wildcards, compound command analysis, and fine-grained tool+command restrictions.

**Key files**: Documented across numerous CHANGELOG entries, `examples/hooks/bash_command_validator_example.py` (~83 lines), system prompt tool descriptions

**How it works**: Permission rules follow the format `Bash(pattern:*)` where pattern supports wildcards at any position: `Bash(npm *)` (any npm command), `Bash(* install)` (any install command), `Bash(git * main)` (git commands targeting main). Compound commands with shell operators (`;`, `&&`, `||`, `|`) are decomposed and each subcommand is matched independently (`2.1.59`). Output redirections are matched through — `Bash(python:*)` matches `python script.py > output.txt` (`1.0.123`). Environment variable wrappers like `FOO=bar command` are parsed to extract the actual command. Bash commands with inline env vars, heredocs with template literals, backslash line continuations, and `$()` substitution are all handled. Wildcard rules cannot match compound commands containing shell operators (security fix, `2.1.7`). The classifier validates that match descriptions correspond to actual input rules to prevent hallucinated permissions (`2.1.47`). Unreachable rules are detected and warned about in `/doctor` (`2.1.3`).

**Notable details**: The `Bash(*)` pattern is treated as equivalent to `Bash` (all commands, `2.1.20`). The `autoAllowBashIfSandboxed` flag auto-approves all bash commands that run inside the sandbox (`2.0.24`). Heredoc delimiter parsing was hardened to prevent command smuggling (`2.1.38`). Shell line continuation (`\` at end of line) was fixed to prevent permission bypass (`2.1.6`). The `MCP tool permission` wildcard syntax `mcp__server__*` allows/denies all tools from a specific MCP server (`2.0.70`). This is one of the most iterated-upon systems in the entire codebase, with security fixes in nearly every release.

### 18. Session Lifecycle Management (sessions)

**What it is**: Comprehensive session persistence, resumption, compaction, and forking with git branch linking, PR association, and cross-environment portability.

**Key files**: Documented across CHANGELOG entries, system prompt context

**How it works**: Sessions persist as JSONL transcript files with metadata. Resumption via `claude --resume <name-or-id>` or `/resume` picker with git branch filtering, message count, context summary, and search. Named sessions via `/rename` with terminal tab title updates. Session forking via `--fork-session` preserves history while creating a new branch. Sessions are automatically linked to PRs when created via `gh pr create` (`2.1.27`). The `--from-pr` flag resumes sessions linked to a specific PR. Context compaction auto-triggers when approaching context limits and can be manually triggered via `/compact`. Compaction strips heavy payloads (images, PDFs, large tool results) and uses the LLM to summarize. Two-phase compaction prunes outputs before LLM summarization. Plan mode is preserved through compaction (`2.1.47`). Session names persist through compaction (`2.1.47`). Large tool results (>50K chars) are persisted to disk and referenced by file path rather than kept in context (`2.1.51`). Auto-compact was made instant (`2.0.64`). Session resume memory usage was reduced by 68% through stat-based loading and progressive enrichment (`2.1.30`).

**Notable details**: Sessions work across worktrees of the same repo. The 5-hour session limit is enforced with warnings. Corrupted transcripts with `parentUuid` cycles are handled gracefully. The `/rewind` command (`2.0.0`) undoes code changes by reverting to a previous conversation point. Session data is flushed before hooks and analytics during graceful shutdown (`2.1.50`). Remote sessions from claude.ai can be teleported to CLI (`2.0.24`).

## What Our Harness Should Adopt From claude-code

These are claude-code's distinctive contributions — features that represent genuine innovations or unusually strong implementations that Cubex should adopt. Ranked by impact.

### 1. Unified Plugin Architecture with 5-Component Format (HIGHEST)

**The idea**: A single distributable extension format that bundles commands (slash commands), agents (autonomous sub-processes), skills (knowledge packages), hooks (event handlers), and MCP servers into one package with auto-discovery and marketplace distribution.

**Why this matters for Cubex**: Cubex needs an extension system. Most frameworks offer only one extension type (tools, or plugins, or middleware). Claude Code's approach unifies five different extension types into a single distributable format. Without this, extension developers must create separate packages for related functionality. With it, a "code-review" plugin can ship a `/review` command, a `code-reviewer` agent, a `review-best-practices` skill, a `security-check` hook, and a GitHub MCP server — all in one package.

**How it works** (language-agnostic pattern):

The plugin format uses directory convention for auto-discovery:
```
plugin-name/
  .plugin/manifest.toml        # Required: name, version, author, description
  commands/                     # Slash commands (markdown with frontmatter)
    review.md                   # Triggered by /review
  agents/                       # Autonomous agents (markdown with frontmatter)
    reviewer.md                 # Triggered by description match or explicit spawn
  skills/                       # Knowledge packages
    best-practices/
      SKILL.md                  # Auto-loaded when user intent matches description
      references/               # Deep reference material
      scripts/                  # Helper executables
  hooks/                        # Event handlers
    hooks.toml                  # Event → matcher → handler chain config
    validator.py                # Handler implementation
  mcp.toml                      # MCP server configuration
```

Discovery algorithm:
1. On startup, scan plugin directories (user-level `~/.config/cubex/plugins/`, project-level `.cubex/plugins/`)
2. For each directory containing `.plugin/manifest.toml`, register the plugin
3. Auto-discover components by directory name convention — no explicit registration in manifest
4. Hot-reload: watch for file changes and update available components without restart

Distribution model:
- Git-based marketplaces: `marketplace.toml` defines git repos containing plugins
- Version pinning: specific commit SHA, branch, or tag via `repo#ref` syntax
- Enterprise policy: `strict_known_marketplaces` restricts to approved sources only
- Plugin validation: CLI command to verify structure, manifest, and component formats

Component lifecycle:
- Commands: Loaded on demand when user types `/command-name`
- Agents: Available immediately, triggered by description matching or explicit spawn
- Skills: Metadata loaded on startup (for matching), full content loaded on activation
- Hooks: Registered on plugin load, trigger on configured events
- MCP servers: Started on demand, support stdio/SSE/HTTP/WebSocket transports

**Source**: `plugins/*/` (~70 files across 12 plugins), `.claude-plugin/marketplace.json` (~150 lines), `plugins/README.md` (~75 lines)

### 2. Event-Driven Hook Lifecycle with Three Handler Types (HIGHEST)

**The idea**: An event bus for agent lifecycle with 10+ event types, three handler types (deterministic command, AI-evaluated prompt, external HTTP service), the ability to modify tool inputs before execution, and scoped hooks that activate only during specific agent/skill lifecycles.

**Why this matters for Cubex**: Hooks are the safety and customization backbone. Without them, users can't validate tool calls before execution, inject context at session start, prevent premature exit, audit configuration changes, or integrate with external security services. The three-tier handler model (command/prompt/HTTP) covers all customization needs: fast deterministic rules, nuanced AI judgment, and external service integration.

**How it works** (language-agnostic pattern):

Event types (exhaustive):
- `PreToolUse`: Before tool execution. Input: tool_name, tool_input. Can: allow, block, modify input, inject context.
- `PostToolUse`: After tool completion. Input: tool_name, tool_input, tool_output. Can: react, inject context.
- `Stop`: Before session exit. Input: transcript_path, reasoning, last_assistant_message. Can: block exit and feed new prompt.
- `SubagentStop`: Before subagent exit. Input: agent_id, transcript_path. Can: validate completion.
- `SubagentStart`: When subagent launches. Input: agent config.
- `SessionStart`: Session initialization. Can: inject additional context.
- `ConfigChange`: Configuration file modified. Can: block changes (enterprise auditing).
- `WorktreeCreate`/`WorktreeRemove`: Worktree lifecycle.
- `TeammateIdle`/`TaskCompleted`: Multi-agent coordination events.
- `UserPromptSubmit`: User submits a prompt. Can: validate/modify.
- `PermissionRequest`: Permission dialog shown. Can: auto-approve/deny.
- `Notification`: Notification generated. Can: filter.

Hook configuration structure:
```toml
[hooks.PreToolUse]
  [[hooks.PreToolUse.chain]]
  matcher = "Edit|Write"   # Regex on tool name (optional, default: all)

    [[hooks.PreToolUse.chain.handlers]]
    type = "command"        # Deterministic shell handler
    command = "python3 ${PLUGIN_ROOT}/validate.py"
    timeout_ms = 600000     # 10 minutes max
    once = false            # Run every time (vs once per session)

    [[hooks.PreToolUse.chain.handlers]]
    type = "prompt"         # AI-evaluated handler
    prompt = "Evaluate if this file edit introduces security vulnerabilities"
    model = "haiku"         # Use cheap model for fast evaluation

    [[hooks.PreToolUse.chain.handlers]]
    type = "http"           # External service handler
    url = "https://security.internal/validate"
    # POSTs JSON, receives JSON response
```

Handler protocol:
- **Command**: Receives JSON on stdin (`{tool_name, tool_input, session_id, transcript_path}`). Returns JSON on stdout (`{decision, reason, additionalContext, updatedInput}`). Exit codes: 0=allow, 1=show error to user, 2=block and show error to model.
- **Prompt**: System provides the hook prompt + tool context to an LLM call. LLM returns structured decision.
- **HTTP**: POST JSON payload to URL, receive JSON response with same schema as command handler.

Key behaviors:
- `updatedInput`: PreToolUse handlers can modify tool inputs before execution (middleware pattern)
- `additionalContext`: Any handler can inject text into the model's context
- `decision: "block"` with `reason` in Stop hooks feeds the reason as a new user message (enables loops)
- Matchers support regex: `"Edit|Write|MultiEdit"` matches any of those tools
- Handlers chain: multiple handlers per event, all must pass
- Scoped hooks: agents and skills can define hooks in their frontmatter, active only during that component's lifecycle

**Source**: `plugins/security-guidance/hooks/hooks.json` (~15 lines), `plugins/ralph-wiggum/hooks/stop-hook.sh` (~178 lines), `examples/hooks/bash_command_validator_example.py` (~83 lines)

### 3. Hierarchical Enterprise Settings with Policy Enforcement (VERY HIGH)

**The idea**: A multi-level settings cascade where enterprise-managed settings override all other levels, with granular controls that can lock down permissions, hooks, marketplaces, sandboxing, and network access.

**Why this matters for Cubex**: Any agent harness used in enterprise environments needs the ability for administrators to enforce policies. Without hierarchical settings, every user can configure their own permissions, potentially bypassing security measures. With it, organizations can deploy Cubex with consistent security guarantees while still allowing user customization within bounds.

**How it works** (language-agnostic pattern):

Settings resolution (highest priority wins):
```
managed (enterprise)  →  overrides everything
  ↑
user (~/.config/cubex/settings.toml)
  ↑
project (.cubex/settings.toml)
  ↑
session (runtime flags)
```

Enterprise-only controls (only effective in managed settings):
```toml
[enterprise]
disable_bypass_permissions = true        # Cannot --dangerously-skip-permissions
managed_permission_rules_only = true     # Users can't define own allow/deny rules
managed_hooks_only = true                # Users can't define own hooks
strict_known_marketplaces = ["https://approved.corp.com/plugins"]  # Restrict plugin sources
allow_unsandboxed_commands = false       # Cannot escape sandbox

[sandbox]
enabled = true
auto_allow_if_sandboxed = false          # Still prompt even in sandbox
[sandbox.network]
allowed_domains = ["github.com", "api.corp.com"]
allow_unix_sockets = []
allow_local_binding = false
http_proxy_port = 8080
socks_proxy_port = 1080

[permissions]
allow = ["Bash(git status:*)", "Read"]   # Auto-approved
ask = ["Bash", "Write"]                  # Require confirmation
deny = ["WebSearch", "WebFetch"]         # Blocked entirely

# Tool+pattern matching with wildcards:
# "Bash(npm *)" - any npm command
# "Bash(* install)" - any install command
# "mcp__server__*" - all tools from an MCP server
```

Permission evaluation algorithm:
1. Check managed deny rules → block if matched
2. Check managed allow rules → allow if matched
3. Check user deny rules (if not `managed_permission_rules_only`) → block if matched
4. Check project allow rules → allow if matched
5. Check session-level rules
6. For compound bash commands, decompose by shell operators and evaluate each subcommand independently
7. Validate wildcard rules cannot match compound commands containing shell operators
8. Detect and warn about unreachable rules

Config change auditing:
- `ConfigChange` hook event fires when settings files change during a session
- Enterprise can block settings changes via hook handler returning `decision: "block"`
- Config backups are timestamped and rotated (keep 5 most recent)

Deployment:
- Linux: `/etc/cubex/managed-settings.toml`
- macOS: Plist or file-based
- Windows: Registry or file-based

**Source**: `examples/settings/settings-strict.json` (~28 lines), `examples/settings/settings-lax.json` (~7 lines), `examples/settings/settings-bash-sandbox.json` (~20 lines)

### 4. Skill Auto-Loading via Description Matching with Progressive Disclosure (HIGH)

**The idea**: Knowledge packages that auto-load when the user's intent semantically matches the skill's description, with a three-stage loading pipeline: metadata only (for matching) → frontmatter + summary (for context budget) → full content + references (on activation).

**Why this matters for Cubex**: An agent's effectiveness depends on having the right knowledge at the right time. Loading all skills upfront wastes context. Never loading them means users must manually invoke them. Description-based auto-loading means the agent automatically gains domain expertise when the task requires it, without explicit user action or context waste.

**How it works** (language-agnostic pattern):

Skill structure:
```
skills/
  code-review/
    SKILL.md            # Required: frontmatter + knowledge content
    references/         # Detailed documentation (loaded on demand)
      style-guide.md
      patterns.md
    scripts/            # Executable helpers
      lint.sh
    assets/             # Templates, configurations
      template.toml
```

SKILL.md format:
```markdown
---
name: code-review
description: "This skill should be used when the user asks to 'review code', 'check for bugs', 'audit this PR', or wants feedback on code quality"
version: 1.0.0
user-invocable: true       # Show in slash command menu (default: true)
context: fork              # Run in forked sub-agent context (optional)
agent: sonnet              # Agent type for execution (optional)
allowed-tools: [Read, Grep, Glob]  # Tool restrictions (optional)
skills: [testing-patterns]  # Auto-load other skills for subagents (optional)
---

# Code Review Guidelines
[Knowledge content...]
```

Loading pipeline:
1. **Startup**: Scan all skill directories, parse frontmatter only (name, description, version)
2. **Context budget**: Calculate total token count for all skill metadata (2% of context window)
3. **Intent matching**: When user sends a message, compare against all skill descriptions
4. **Activation**: If match found, load full SKILL.md content + reference files into context
5. **Hot-reload**: File watcher detects changes to skills and updates available set without restart

Activation triggers:
- User message matches description phrases
- Explicit `/skill-name` command invocation
- Subagent declares skill dependency via `skills` frontmatter field
- User @-mentions a skill

Priority:
- Recently and frequently used skills ranked higher in suggestions
- Skills from project-level (`.cubex/skills/`) take priority over user-level

**Source**: `plugins/frontend-design/skills/frontend-design/SKILL.md` (~300 lines), `plugins/plugin-dev/skills/*/SKILL.md` (7 files)

### 5. Agent Definition via Markdown Frontmatter (HIGH)

**The idea**: Declarative agent definitions using markdown files where YAML frontmatter specifies runtime configuration (model, tools, memory, hooks, isolation) and the markdown body is the system prompt.

**Why this matters for Cubex**: Most frameworks define agents in code, requiring language expertise and recompilation. Markdown-defined agents can be created by non-developers, shared as files, version-controlled alongside project code, and modified without rebuilding. This dramatically lowers the barrier to agent customization.

**How it works** (language-agnostic pattern):

Agent file format (`.cubex/agents/reviewer.md`):
```markdown
---
name: code-reviewer
description: >
  Use this agent when reviewing code quality.
  <example>
  Context: User asks for code review
  user: "Review this PR"
  assistant: "I'll launch the code-reviewer agent"
  <commentary>Explicit review request triggers this agent</commentary>
  </example>
model: sonnet                    # Model selection (default: inherit from parent)
tools: [Read, Grep, Glob]       # Least-privilege tool set (default: all tools)
color: green                     # Visual identifier in TUI
memory: project                  # Persistent memory scope (user/project/local)
background: true                 # Run as background task (default: false)
isolation: worktree              # Run in isolated git worktree (default: none)
permission_mode: accept_edits    # Permission level for this agent
disallowed_tools: [WebSearch]    # Explicit tool blocking
hooks:                           # Scoped hooks (active only during agent lifecycle)
  PreToolUse:
    - matcher: "Bash"
      type: prompt
      prompt: "Is this bash command safe for a code review agent?"
---

You are an expert code reviewer specializing in...

# Responsibilities
1. Analyze code quality
2. Identify bugs and security issues
...
```

Triggering mechanism:
- Description field contains `<example>` blocks with `Context:`, `user:`, `assistant:`, and `<commentary>` sections
- System matches user messages against example patterns
- Agents can also be spawned explicitly via the Agent/Task tool
- The `--agent` CLI flag configures the main thread with a specific agent's configuration

Lifecycle:
- Agent processes inherit parent's model by default (unless `model` specified)
- Scoped hooks activate only during this agent's execution
- Memory writes are scoped to the configured level
- Worktree isolation creates a temp git worktree, cleaned up on completion
- Background agents send notifications on completion

Discovery:
- User-level: `~/.config/cubex/agents/`
- Project-level: `.cubex/agents/`
- Plugin-level: `plugin/agents/`
- Additional directories: `--add-dir` flag
- CLI listing: `cubex agents`

**Source**: `plugins/feature-dev/agents/code-explorer.md` (~52 lines), `plugins/hookify/agents/conversation-analyzer.md` (~177 lines), `plugins/code-review/commands/code-review.md` (~110 lines)

### 6. Self-Referential Loop Pattern via Stop Hook (HIGH)

**The idea**: Using the Stop hook to intercept session exit, read the conversation transcript, detect completion signals via structured markers (XML tags), and feed the same prompt back if not complete — enabling iterative autonomous loops with configurable iteration limits and graceful completion detection.

**Why this matters for Cubex**: Many tasks require iterative refinement — the agent tries something, evaluates the result, and tries again. Without a loop mechanism, users must manually re-prompt. This pattern enables autonomous iteration with built-in safety (max iterations, completion promises) and full transcript access for self-evaluation.

**How it works** (language-agnostic pattern):

State management:
```toml
# .cubex/loop-state.toml
iteration = 1
max_iterations = 10
completion_promise = "All tests pass"

# Below a separator, store the original prompt text
# [prompt]
# text = "Fix all failing tests..."
```

Stop hook algorithm:
```
on_stop(transcript_path, session_id):
  state = read_state_file()
  if state is None: return ALLOW  # No active loop

  if state.iteration >= state.max_iterations:
    cleanup_state()
    return ALLOW  # Max iterations reached

  last_message = extract_last_assistant_message(transcript_path)
  # Parse JSONL, filter role=="assistant", take last, extract text content

  if state.completion_promise:
    promise_text = extract_xml_tag(last_message, "promise")
    if promise_text == state.completion_promise:
      cleanup_state()
      return ALLOW  # Promise fulfilled

  state.iteration += 1
  atomic_write_state(state)  # temp file + rename for atomicity

  return BLOCK(
    reason = state.prompt,      # Feed original prompt back as user message
    system_message = f"Iteration {state.iteration} | To complete: output <promise>{state.completion_promise}</promise>"
  )
```

Safety mechanisms:
- Max iteration limit prevents infinite loops
- Completion promise uses exact string matching (not fuzzy)
- Numeric field validation prevents arithmetic errors on corrupted state
- Corrupted state files are detected and cleaned up (loop stops)
- Missing transcript files stop the loop gracefully
- Cancel command removes the state file

**Source**: `plugins/ralph-wiggum/hooks/stop-hook.sh` (~178 lines)

### 7. Confidence-Based Multi-Agent Review with Validation Subagents (MEDIUM-HIGH)

**The idea**: A multi-agent code review pipeline where specialized agents find issues, then independent validation agents verify each issue before reporting — using confidence-based filtering and an explicit false positive exclusion list to maximize signal-to-noise ratio.

**Why this matters for Cubex**: Multi-agent review is common, but false positives erode trust. The two-stage pipeline (find → validate) with model-tiered agents (cheap models for validation, expensive models for bug detection) produces higher-quality results than a single-pass approach. The explicit false positive exclusion list prevents the most common failure modes.

**How it works** (language-agnostic pattern):

Pipeline stages:
```
1. PRE-CHECK (cheap model):
   - Is PR closed/draft/trivial/already reviewed?
   - If yes: abort early

2. CONTEXT GATHERING (parallel, cheap model):
   - Agent A: Find all relevant config/rules files scoped by modified paths
   - Agent B: Summarize PR changes (title, description, diff overview)

3. PARALLEL REVIEW (4 agents, mixed models):
   - Agent 1-2 (medium model): Rules compliance audit
   - Agent 3-4 (expensive model): Bug and security analysis
   - Each returns: [{description, reason, confidence, file, line}]
   - Only flag issues with confidence ≥ 80

4. VALIDATION (parallel subagents per issue):
   - For each issue from step 3:
     - Spawn validation agent with issue description + PR context
     - Agent independently verifies: does this issue actually exist?
     - Use expensive model for bugs, medium model for compliance
   - Filter out unvalidated issues

5. REPORTING:
   - Aggregate validated issues
   - Post inline comments with suggestions (for small fixes)
   - Describe fix approach (for large fixes)
   - Maximum one comment per unique issue

FALSE POSITIVE EXCLUSION LIST:
  - Pre-existing issues (not introduced by this PR)
  - Correct code that appears buggy
  - Pedantic nitpicks a senior engineer wouldn't flag
  - Linter-catchable issues (don't duplicate linter)
  - Issues explicitly silenced in code (lint ignore comments)
  - General quality concerns unless required by project rules
```

Model tiering strategy:
- Haiku-tier: Pre-checks, context gathering (high volume, low complexity)
- Sonnet-tier: Compliance audits, validation (medium complexity)
- Opus-tier: Bug detection, logic analysis (highest complexity, lowest volume)

**Source**: `plugins/code-review/commands/code-review.md` (~110 lines), `plugins/pr-review-toolkit/commands/review-pr.md` (~190 lines)

### 8. MCP Tool Search with Auto-Deferral (MEDIUM-HIGH)

**The idea**: Automatically deferring MCP tool descriptions from the system prompt when they exceed a context budget threshold, and instead providing a search tool that loads tools on demand.

**Why this matters for Cubex**: Users with many MCP servers (GitHub, Slack, databases, monitoring, etc.) can have hundreds of tool descriptions consuming tens of thousands of tokens. This directly competes with conversation context. Deferral means tools are available but only consume context when actually needed.

**How it works** (language-agnostic pattern):

```
Startup:
  total_mcp_tokens = sum(token_count(tool.description) for tool in mcp_tools)
  context_budget = context_window_size * threshold_percentage  # default 10%

  if total_mcp_tokens > context_budget:
    # Defer all MCP tools
    for tool in mcp_tools:
      move_to_deferred_index(tool)

    # Inject ToolSearch meta-tool into active tool set
    register_tool("ToolSearch", {
      description: "Search for and load deferred tools",
      params: { query: string, max_results: int }
    })

ToolSearch invocation:
  if query starts with "select:":
    tool_name = query.strip_prefix("select:")
    return load_single_tool(tool_name)  # Load and make available
  else:
    results = fuzzy_search(deferred_index, query, max_results)
    for result in results:
      load_tool(result)  # All search results are immediately loaded
    return results

Configuration:
  auto:N  # Custom threshold percentage (e.g., auto:5 for 5%)
  disallowed_tools: ["ToolSearch"]  # Disable deferral entirely
```

Optimizations:
- MCP auth failures are cached to avoid repeated connection attempts
- Tool token counting is batched into a single API call
- `list_changed` notifications from MCP servers dynamically update available tools without reconnection

**Source**: CHANGELOG entries `2.1.7`, `2.1.9`, system prompt ToolSearch definition

### 9. Conversation-to-Hook Pipeline (Hookify) (MEDIUM)

**The idea**: An AI agent that analyzes the current conversation transcript to identify user frustrations and automatically generates hook rules to prevent those behaviors in future sessions — the agent learns from its own mistakes.

**Why this matters for Cubex**: Manual hook creation requires technical knowledge and forethought. Hookify inverts this — users simply get frustrated during a session, then run a command to capture that frustration as a permanent guardrail. This creates a feedback loop where the agent gets safer and more aligned over time through actual usage.

**How it works** (language-agnostic pattern):

```
Analysis pipeline:
  1. Read transcript in reverse chronological order
  2. Identify frustration signals:
     - Explicit corrections: "Don't use X", "Stop doing Y"
     - Frustrated reactions: "Why did you do X?"
     - User reversions of agent's changes
     - Repeated same mistake

  3. For each identified behavior:
     - Determine involved tool (Bash, Edit, Write)
     - Extract regex pattern from problematic action
     - Categorize severity: high (block), medium (warn), low (optional)
     - Check for false positives:
       - Hypothetical discussions → skip
       - Teaching moments → skip
       - One-time accidents → low priority

  4. Generate rule files:
     # .cubex/hooks/warn-dangerous-rm.local.toml
     name = "warn-dangerous-rm"
     enabled = true
     event = "PreToolUse"
     matcher = "Bash"
     pattern = "rm\\s+-rf"
     action = "block"
     message = "Dangerous rm command detected. Verify path."

  5. Rules take effect immediately (no restart needed)

Interactive management:
  /hookify              # Analyze conversation and suggest rules
  /hookify:configure    # Toggle existing rules on/off
  /hookify:list         # Show all configured rules
```

**Source**: `plugins/hookify/agents/conversation-analyzer.md` (~177 lines), `plugins/hookify/commands/configure.md` (~129 lines)

### 10. Slash Command Architecture with Dynamic Context Injection (MEDIUM)

**The idea**: Markdown-defined commands where the body is a prompt template with `!` prefix for injecting live bash output, `$ARGUMENTS` for user input, and `allowed-tools` for fine-grained tool restrictions — enabling complex multi-agent workflows to be defined entirely as text.

**Why this matters for Cubex**: Commands are the primary user-facing extension point. The markdown format means non-developers can create powerful commands. The bash injection pattern (`!` prefix) lets commands dynamically gather context (git status, branch info, file contents) at invocation time. Tool restrictions ensure commands can only perform their intended operations.

**How it works** (language-agnostic pattern):

Command file (`.cubex/commands/deploy.md`):
```markdown
---
description: Deploy the current branch to staging
argument-hint: "[environment]"
allowed-tools:
  - Bash(git push:*)
  - Bash(kubectl apply:*)
  - Read
---

Deploy target: $ARGUMENTS

Current state:
- Branch: !`git branch --show-current`
- Status: !`git status --short`
- Last commit: !`git log --oneline -1`
- Cluster: !`kubectl config current-context`

Steps:
1. Verify all changes are committed
2. Push to remote
3. Apply Kubernetes manifests
4. Verify deployment health

Do not send any other text besides tool calls.
```

Execution model:
1. User types `/deploy staging`
2. System resolves `$ARGUMENTS` → "staging"
3. System executes each `!`backtick`` expression and injects output
4. Combined prompt is sent to the LLM with tool set restricted to `allowed-tools`
5. LLM executes the workflow using only permitted tools

Indexed arguments: `$ARGUMENTS[0]`, `$ARGUMENTS[1]` for individual positional args
Plugin path: `${PLUGIN_ROOT}` for portable references
Colon grouping: `/plugin-name:command-name` for namespaced commands

**Source**: `plugins/commit-commands/commands/commit.md` (~40 lines), `plugins/feature-dev/commands/feature-dev.md` (~126 lines)

## Summary

claude-code's gifts to Cubex, in order of impact:

1. **Unified Plugin Architecture** — The 5-component format (commands, agents, skills, hooks, MCP) with auto-discovery and marketplace distribution is the most comprehensive extension model in the collection, and no other repo approaches this level of unification.
2. **Event-Driven Hook Lifecycle** — 10+ lifecycle events with three handler types (command/prompt/HTTP), tool input modification, context injection, and scoped hooks provide the safety and customization backbone that a production agent harness needs.
3. **Hierarchical Enterprise Settings** — Multi-level settings cascade with enterprise policy enforcement (managed hooks only, managed permissions only, strict marketplaces, sandbox controls) is unique and essential for organizational deployment.
4. **Skill Auto-Loading via Description Matching** — Progressive disclosure skills that auto-load based on user intent matching, with hot-reload, context budget scaling, and subagent skill inheritance.
5. **Agent Definition via Markdown Frontmatter** — Declarative agents with model selection, tool restrictions, memory scope, isolation mode, scoped hooks, and example-based triggering, all in a single markdown file.
6. **Self-Referential Loop Pattern** — Stop hook interception with transcript reading, completion promise detection via XML tags, and prompt re-injection for autonomous iterative tasks.
7. **Confidence-Based Multi-Agent Review** — Find → validate pipeline with model-tiered agents and explicit false positive exclusion list for high-signal automated review.
8. **MCP Tool Search with Auto-Deferral** — Automatic context budget management for MCP tools via deferred loading and search-based discovery.
9. **Conversation-to-Hook Pipeline (Hookify)** — Agent self-improvement through conversation analysis, turning user frustrations into permanent guardrails.
10. **Slash Commands with Dynamic Context Injection** — Markdown-defined commands with bash injection (`!` prefix), tool restrictions, and argument expansion for powerful yet accessible command authoring.
