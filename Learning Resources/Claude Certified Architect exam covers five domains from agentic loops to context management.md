---
created: 2026-03-15
description: Comprehensive self-study guide for the Claude Certified Architect (Foundations) exam, covering agentic architecture, tool design/MCP, Claude Code configuration, prompt engineering, and context management — with domain-by-domain breakdowns, anti-patterns, build exercises, and ready-to-paste tutor prompts.
source: https://x.com/hooeem/status/2033198345045336559
type: study-guide
---

# Claude Certified Architect exam covers five domains from agentic loops to context management

A breakdown of the Claude Certified Architect (Foundations) exam by [@hooeem](https://x.com/hooeem). The exam itself requires being a Claude partner, but the knowledge is freely learnable and directly monetisable. The guide covers all five domains with anti-patterns, build exercises, and full tutor prompts you can paste into Claude.

## Key Takeaways

- The exam tests five domains: Agentic Architecture & Orchestration (27%), Claude Code Configuration & Workflows (20%), Prompt Engineering & Structured Output (20%), Tool Design & MCP Integration (18%), and Context Management & Reliability (15%).
- Subagents do NOT share memory with the coordinator — every piece of information must be passed explicitly. This is the single most commonly misunderstood concept in multi-agent systems.
- When stakes are financial or security-critical, prompt instructions alone aren't enough — you must enforce tool ordering programmatically with hooks and prerequisite gates.
- Tool descriptions are the primary mechanism Claude uses for tool selection; vague or overlapping descriptions cause misrouting. Better descriptions beat routing classifiers as a first fix.
- The CLAUDE.md hierarchy trap: user-level config (~/.claude/CLAUDE.md) is not version-controlled, so new team members won't get those instructions.
- Progressive summarisation kills transactional data — use a persistent "case facts" block with extracted amounts, dates, and order numbers that never gets summarised.
- An independent review instance catches more issues than self-review in the same session (the model retains reasoning context that biases it).
- Few-shot examples (2-4 targeted) are the highest-leverage technique for consistency — more effective than additional instructions or confidence thresholds.

## Domain Breakdown

### Domain 1: Agentic Architecture & Orchestration (27%)

The heaviest-weighted domain. Covers:

- **Agentic loops**: stop_reason-driven termination (not natural language parsing, not arbitrary iteration caps, not checking for text content)
- **Multi-agent orchestration**: hub-and-spoke architecture where all communication flows through the coordinator; subagents have isolated context
- **Subagent invocation**: Task tool for spawning, parallel spawning for latency, fork_session for divergent exploration
- **Workflow enforcement**: programmatic hooks for high-stakes operations, prompt-based guidance for low-stakes
- **Agent SDK hooks**: PostToolUse hooks for data normalisation, tool call interception for policy enforcement
- **Task decomposition**: fixed sequential pipelines vs dynamic adaptive decomposition; attention dilution problem with large file sets
- **Session state**: --resume vs fork_session vs fresh start with summary injection

Three anti-patterns the exam tests: parsing natural language for loop termination, arbitrary iteration caps, and checking for assistant text as completion indicator.

**Build exercise**: A multi-tool agent with 3-4 MCP tools, proper stop_reason handling, a PostToolUse hook normalising data formats, and a tool call interception hook blocking policy violations.

**Learning resources**:
- [Agent SDK Overview](https://platform.claude.com/docs/en/agent-sdk/overview)
- [Building Agents with the Claude Agent SDK](https://www.anthropic.com/engineering/building-agents-with-the-claude-agent-sdk)
- [Agent SDK Python repo + examples](https://github.com/anthropics/claude-agent-sdk-python)

### Domain 2: Tool Design & MCP Integration (18%)

- **Tool descriptions**: the primary mechanism for tool selection. Expand vague descriptions before reaching for routing classifiers or consolidation.
- **Structured error responses**: four categories (transient, validation, business, permission). Critical distinction between access failure and valid empty result.
- **Tool distribution**: 4-5 tools per agent optimal; 18 tools degrades selection. tool_choice options: "auto", "any", forced specific tool.
- **MCP server integration**: project-level (.mcp.json) vs user-level (~/.claude.json); environment variable expansion for credentials.
- **Built-in tools**: Grep (file contents) vs Glob (file paths) — the exam deliberately tests using the wrong one.

**Build exercise**: Two MCP tools with intentionally similar functionality. Write vague descriptions, experience misrouting, then fix them.

**Learning resources**:
- [MCP Integration for Claude Code](https://code.claude.com/docs/en/mcp)
- [MCP specification and community servers](https://github.com/modelcontextprotocol)
- [Claude Agent SDK TypeScript repo](https://www.npmjs.com/package/@anthropic-ai/claude-agent-sdk)

### Domain 3: Claude Code Configuration & Workflows (20%)

- **CLAUDE.md hierarchy**: user-level (personal, not shared) → project-level (version-controlled, team-wide) → directory-level (scoped). Exam trap: new team member missing instructions because they're in user-level config.
- **Path-specific rules**: .claude/rules/ with YAML frontmatter glob patterns (e.g. `**/*.test.tsx`) — applies across entire codebase, unlike directory-level CLAUDE.md.
- **Skills vs CLAUDE.md**: skills are on-demand task-specific workflows; CLAUDE.md is always-loaded universal standards. Don't mix them.
- **Plan mode**: for complex multi-file changes, architectural decisions. Direct execution: for well-understood single-file fixes.
- **CI/CD**: -p flag for non-interactive mode (without it, CI hangs). Independent review instance for code review. --output-format json for structured findings.

**Build exercise**: Project with CLAUDE.md hierarchy, .claude/rules/ with glob patterns, a skill with context: fork, and a CI script using -p flag with JSON output.

**Learning resources**:
- [Claude Code official docs](https://code.claude.com/docs/en/mcp)
- [Claude Code CLI Cheatsheet](https://shipyard.build/blog/claude-code-cheat-sheet/)
- [Creating the Perfect CLAUDE.md](https://dometrain.com/blog/creating-the-perfect-claudemd-for-claude-code/)

### Domain 4: Prompt Engineering & Structured Output (20%)

- **Explicit criteria**: "Be conservative" doesn't work. Define exactly which issues to report vs skip, with code examples per severity level.
- **Few-shot prompting**: 2-4 targeted examples showing ambiguous-case handling with reasoning. Higher leverage than more instructions.
- **tool_use with JSON schemas**: eliminates syntax errors but NOT semantic errors. Schema design: nullable fields prevent fabrication, "unclear" enum values, "other" + detail strings.
- **Validation-retry loops**: effective for format/structural errors, ineffective for genuinely absent information.
- **Message Batches API**: 50% savings, up to 24h processing, no multi-turn tool calling. Batch for overnight reports, synchronous for blocking checks.
- **Multi-instance review**: same session self-review is biased. Independent instance catches more.

**Build exercise**: Extraction pipeline with tool_use (required, optional, nullable fields), validation-retry loop, batch processing via Batches API.

**Learning resources**:
- [Anthropic Prompt Engineering docs](https://docs.claude.com/en/docs/build-with-claude/prompt-engineering/overview)
- [Anthropic API Tool Use documentation](https://platform.claude.com/docs/en/release-notes/overview)

### Domain 5: Context Management & Reliability (15%)

- **Context preservation**: persistent "case facts" block for transactional data (never summarised). "Lost in the middle" effect — place key summaries at the beginning.
- **Escalation triggers**: three valid (customer requests human, policy gaps, inability to progress) vs two unreliable (sentiment analysis, self-reported confidence).
- **Error propagation**: structured context (failure type, attempted query, partial results, alternatives). Anti-patterns: silent suppression and full workflow termination on single failures.
- **Codebase exploration**: scratchpad files, subagent delegation, /compact for context management.
- **Human review**: 97% overall accuracy can hide 40% error on a specific document type — validate by type and field.

**Build exercise**: Coordinator with two subagents, persistent case facts block, simulated timeout with structured error propagation, conflicting sources with preserved attribution.

**Learning resources**:
- [Building Agents with the Claude Agent SDK](https://www.anthropic.com/engineering/building-agents-with-the-claude-agent-sdk)
- [Agent SDK session docs](https://platform.claude.com/docs/en/agent-sdk/overview)
- [Everything Claude Code repo](https://github.com/affaan-m/everything-claude-code)

## Recommended Anthropic Courses

1. [Building with the Claude API](https://anthropic.skilljar.com/claude-with-the-anthropic-api)
2. [Introduction to Model Context Protocol](https://anthropic.skilljar.com/introduction-to-model-context-protocol)
3. [Claude Code in Action](https://anthropic.skilljar.com/claude-code-in-action)
4. [Claude 101](https://anthropic.skilljar.com/claude-101)

## Original Content

The thread includes full tutor prompts for each domain — ready to paste into Claude for guided study. Each prompt covers all task statements in the domain with practice scenarios, check questions, and a scored practice exam.

The thread also notes that the exam itself requires Claude partner status, but the knowledge maps directly to building production-grade applications with Claude Code, Agent SDK, Claude API, and MCP.

> "You don't need the certificate to build production-grade applications. You just need the knowledge."

---

*Source: [@hooeem on X](https://x.com/hooeem/status/2033198345045336559) — 2,207 likes, 217 retweets (as of 2026-03-15)*
