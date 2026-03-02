---
created: 2026-03-02
description: Preliminary Factory Droid research links and 2-4 sentence summaries for harness design preparation.
source: MetaLearner pull request prep notes
---

# Factory Droid research links

Collected links and summaries for the upcoming large pull/review prep.

## Links

- [Factory AI – Terminal-Bench announcement](https://factory.ai/news/terminal-bench)
  - Factory’s announcement-style post tying Droid’s results to Terminal-Bench performance.
  - It frames Droid as a software-development agent optimized around tool use, repo understanding, and reliability loops rather than a single-model trick.
  - Use it to understand their public claims, the narrative of why they think they win, and what they emphasize (speed, grounding, iteration).

- [Factory AI – Code Droid technical report](https://factory.ai/news/code-droid-technical-report)
  - This is the most mechanics-heavy public document: it describes how Droid approaches coding tasks and why it performs well.
  - Key concepts include HyperCode (a multi-resolution codebase representation), ByteRank (their retrieval/ranking method), multi-trajectory sampling, validation via tests/tool feedback, plus safety/guardrails (sandboxing, auditability, and DroidShield-style static analysis).

- [Factory AI – Missions](https://factory.ai/news/missions)
  - Explains the “mission” framing and the product direction toward orchestrated workflows—especially useful if you care about end-to-end tasks, not just patch generation.
  - It is a window into how they package autonomy into repeatable units with checks and validation, hinting at worker-style execution (e.g., dedicated validation or UI QA steps).

- [Factory docs – Leaderboards](https://docs.factory.ai/leaderboards?utm_source=chatgpt.com)
  - Factory’s documentation page describing the leaderboard context and how they present results (including update cadence).
  - Useful for understanding what they consider comparable, what they measure, and how they communicate performance claims in a more “docs-like” form than the blog post.

- [Factory CLI quickstart](https://docs.factory.ai/cli/getting-started/quickstart)
  - Quickstart for the CLI, showing the top-level user workflow and interaction patterns (plan → propose → apply changes).
  - This helps infer harness primitives: session structure, diff/approval surfacing, and expected tool/test usage during an agent loop.

- [Factory CLI specification mode](https://docs.factory.ai/cli/user-guides/specification-mode)
  - Details an explicit two-phase (or multi-phase) workflow that enforces read-only analysis and planning before code changes.
  - A useful harness pattern that reduces failure modes by separating understanding from editing, with human-in-the-loop checkpoints and acceptance criteria.

- [Factory CLI AGENTS.md configuration](https://docs.factory.ai/cli/configuration/agents-md)
  - Defines the AGENTS.md convention—a repo briefing packet for the agent—and discovery/precedence rules across directories.
  - For a DIY harness, this is one of the most actionable ideas: a deterministic, versioned place to encode build/test commands, conventions, constraints, and project context.

- [Factory CLI plugins](https://docs.factory.ai/cli/configuration/plugins)
  - Describes extensibility points (plugins/hooks) and how the CLI/agent can be augmented with custom capabilities.
  - Essential for harness design because it implies a stable tool interface, lifecycle hooks, and a marketplace-style packaging model for reusable integrations.

- [Droid Exec overview](https://docs.factory.ai/cli/droid-exec/overview)
  - Explains Droid Exec and headless operation, including structured outputs and streaming modes (e.g., JSON/JSONL and JSON-RPC style event streams).
  - For harness builders this is especially actionable: it implies an internal event model (`tool_call`, `tool_result`, final output) and suggests safe CI/automation integration.

- [Factory GitHub organization](https://github.com/Factory-AI/factory)
  - Factory’s GitHub org entry point, typically used to orient developers to their ecosystem and tooling.
  - Even if it doesn’t include Droid’s proprietary core, it helps map how they structure projects, docs pointers, and community integration surfaces.

- [droid-action](https://github.com/Factory-AI/droid-action)
  - A GitHub Action wrapper for running Droid in CI contexts—useful for seeing how an agent is operationalized around PR workflows.
  - It’s a concrete harness example: inputs/outputs, permissions, repo checkout patterns, result reporting to GitHub, and failure/debug artifact handling.

- [droid-code-review](https://github.com/Factory-AI/droid-code-review)
  - Focused automation around code review behavior (commenting, inline annotations, PR feedback).
  - Great for review harness design: comment deduplication, context collection, and mapping model outputs into GitHub-native review primitives.

- [factory-plugins](https://github.com/Factory-AI/factory-plugins)
  - Shows how plugins are packaged/distributed and what a plugin marketplace repository looks like in practice.
  - Useful for designing a clean plugin ABI with configuration conventions, versioning, and a standardized way for third parties to add tools safely.

- [terminal-bench-leaderboard](https://github.com/Factory-AI/terminal-bench-leaderboard)
  - Benchmark artifact repo that supports or documents Terminal-Bench leaderboard submissions and/or logs.
  - Helpful to mirror evaluation hygiene: how runs are recorded, which metadata matters, and how to structure reproducible harness-driven benchmarking.

- [Every: model switching without losing your place](https://every.to/source-code/the-tool-that-lets-you-switch-models-without-losing-your-place?utm_source=chatgpt.com)
  - A third-party narrative emphasizing the harness layer and context-preserving multi-model orchestration.
  - Useful framing: it highlights why orchestration, state management, and consistent tool interfaces can matter more than model choice.

- [latent.space: Factory profile/interview coverage](https://www.latent.space/p/factory?utm_source=chatgpt.com)
  - Profile/interview-style coverage offering external perspective on Factory’s approach and product philosophy.
  - Less technical, but useful for understanding how they think about agents and scaling to many users/tasks.

- [Stack Overflow Blog: Code smells for AI agents Q&A](https://stackoverflow.blog/2026/02/04/code-smells-for-ai-agents-q-and-a-with-eno-reyes-of-factory/?utm_source=chatgpt.com)
  - Q&A surfacing practical patterns and failure modes (“code smells” for agents) from Factory leadership.
  - Useful for harness builders because it points to real integration issues and guardrails for review/validation loops.

- [nea: Factory the platform for agent-native development](https://www.nea.com/blog/factory-the-platform-for-agent-native-development?utm_source=chatgpt.com)
  - Investor/industry write-up contextualizing Factory’s product and market; less technical, more positioning/strategy.
  - Use it to triangulate claims about differentiators (workflow integration, safety, speed, reliability) and customer/team value.
