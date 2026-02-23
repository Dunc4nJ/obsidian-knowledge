---
created: 2025-07-27
description: OpenAI built a million-line product with zero human-written code by shifting engineering work from writing code to designing environments, enforcing architectural invariants, and building feedback loops that let Codex agents do reliable autonomous work.
source: https://openai.com/index/harness-engineering/
type: framework
---

# Agent-first engineering replaces coding with environment design scaffolding and feedback loops

## Key Takeaways

The core experiment: OpenAI built and shipped an internal product with zero lines of manually-written code over five months — a million lines of code, ~1,500 PRs, averaging 3.5 PRs per engineer per day with a 3-person team (later 7). The throughput *increased* as the team grew. This isn't a demo; the product has daily internal power users and external alpha testers. The constraint was intentional: the only way to make progress was to get Codex to do it, which forced humans to ask "what capability is missing?" rather than "let me just write it."

The fundamental role shift is from writing code to designing environments. Early progress was slow not because the agent was incapable but because the environment was underspecified — lacking tools, abstractions, and structure for the agent to make progress toward high-level goals. This reframes engineering as building the scaffolding that enables agent work, which directly parallels the [[skill workflows]] insight that skills work best as modular structures with progressive disclosure rather than monolithic instruction dumps.

The repository knowledge architecture is the most transferable lesson. A monolithic AGENTS.md failed predictably: context is scarce (crowds out the actual task), too much guidance becomes non-guidance (agents pattern-match locally instead of navigating intentionally), it rots instantly, and it's hard to verify mechanically. The solution: treat AGENTS.md as a ~100-line table of contents pointing to a structured `docs/` directory with design docs, execution plans, architecture docs, quality grades, and references. This enables [[progressive disclosure filters force agent selectivity over what enters context]] — agents start with a small stable entry point and are taught where to look next. The knowledge store is enforced with dedicated linters, CI validation for freshness and cross-links, and a recurring "doc-gardening" agent that opens fix-up PRs for stale docs.

Agent legibility is the optimization target, not human readability. Anything the agent can't access in-context effectively doesn't exist. Slack discussions, Google Docs, knowledge in people's heads — all illegible. This forced pushing *everything* into versioned, repo-local artifacts. Technologies described as "boring" were preferred because they're easier for agents to model (composability, API stability, training set representation). In some cases, reimplementing functionality was cheaper than working around opaque upstream behavior. This connects to [[ralph loops prevents context pollution in long running ai builds]] — the same principle of keeping agent context clean and self-contained.

Architecture enforcement through invariants, not micromanagement, is what allows speed without decay. A rigid layered model (Types → Config → Repo → Service → Runtime → UI per business domain) with strictly validated dependency directions, enforced via custom linters and structural tests. Cross-cutting concerns enter through a single interface: Providers. Custom lint error messages inject remediation instructions into agent context. This is "the kind of architecture you usually postpone until hundreds of engineers — with coding agents, it's an early prerequisite."

The entropy management / garbage collection pattern is crucial: agents replicate existing patterns including suboptimal ones. Initially humans spent every Friday (20%) cleaning "AI slop." That didn't scale. Instead, "golden principles" encoded in the repo drive recurring background Codex tasks that scan for deviations, update quality grades, and open targeted refactoring PRs (most reviewable in under a minute, automerged). Technical debt as a high-interest loan, paid down continuously.

The merge philosophy inverts conventional norms: minimal blocking merge gates, short-lived PRs, test flakes addressed with follow-up runs rather than blocking. When agent throughput far exceeds human attention, corrections are cheap and waiting is expensive. The agent can now end-to-end drive a feature: validate codebase → reproduce bug → record video → implement fix → validate fix → record second video → open PR → respond to feedback → detect build failures → escalate only when judgment required → merge.

The application legibility work made the agent's environment richer: app bootable per git worktree (one instance per change), Chrome DevTools Protocol wired into agent runtime for DOM snapshots/screenshots/navigation, ephemeral observability stack per worktree with LogQL and PromQL access. Single Codex runs regularly work 6+ hours on a task while humans sleep.

## External Resources

- [Ralph Wiggum Loop (ghuntley.com)](https://ghuntley.com/loop/) — the review loop pattern where agents iterate until all agent reviewers are satisfied
- [ARCHITECTURE.md (matklad)](https://matklad.github.io/2021/02/06/ARCHITECTURE.md.html) — the approach to top-level architecture documentation
- [Codex Execution Plans (OpenAI Cookbook)](https://cookbook.openai.com/articles/codex_exec_plans) — structured plans with progress and decision logs
- [Parse, Don't Validate (lexi-lambda)](https://lexi-lambda.github.io/blog/2019/11/05/parse-don-t-validate/) — the boundary validation principle enforced on Codex
- [AI Is Forcing Us to Write Good Code (bits.logic.inc)](https://bits.logic.inc/p/ai-is-forcing-us-to-write-good-code) — strict boundaries and predictable structure for agent effectiveness
- [Aardvark (OpenAI)](/index/introducing-aardvark/) — another agent working on the same codebase

## Original Content

> [!quote]- Full Article by Ryan Lopopolo (OpenAI) — Feb 11, 2026
>
> **Harness engineering: leveraging Codex in an agent-first world**
>
> Over the past five months, our team has been running an experiment: building and shipping an internal beta of a software product with **0 lines of manually-written code**.
>
> The product has internal daily users and external alpha testers. It ships, deploys, breaks, and gets fixed. What's different is that every line of code — application logic, tests, CI configuration, documentation, observability, and internal tooling — has been written by Codex. We estimate that we built this in about 1/10th the time it would have taken to write the code by hand.
>
> **Humans steer. Agents execute.**
>
> We intentionally chose this constraint so we would build what was necessary to increase engineering velocity by orders of magnitude. We had weeks to ship what ended up being a million lines of code. To do that, we needed to understand what changes when a software engineering team's primary job is no longer to write code, but to design environments, specify intent, and build feedback loops that allow Codex agents to do reliable work.
>
> ---
>
> **We started with an empty git repository**
>
> The first commit landed in late August 2025. The initial scaffold — repository structure, CI configuration, formatting rules, package manager setup, and application framework — was generated by Codex CLI using GPT-5. Even the initial AGENTS.md was itself written by Codex.
>
> Five months later: ~1M lines of code, ~1,500 PRs merged, 3 engineers → 7 engineers, 3.5 PRs per engineer per day. Throughput increased as the team grew. Used by hundreds of users internally.
>
> Core philosophy: **no manually-written code**.
>
> ---
>
> **Redefining the role of the engineer**
>
> Engineering work shifted to systems, scaffolding, and leverage. Early progress was slower than expected because the environment was underspecified. The primary job became enabling agents to do useful work.
>
> Depth-first approach: break goals into building blocks, prompt agent to construct them, use them to unlock more complex tasks. When something failed, the fix was never "try harder" — always "what capability is missing?"
>
> PR workflow: engineer describes task → agent opens PR → Codex reviews its own changes → requests additional agent reviews → responds to feedback → iterates until all agent reviewers satisfied (Ralph Wiggum Loop). Humans may review but aren't required to. Almost all review pushed to agent-to-agent.
>
> ---
>
> **Increasing application legibility**
>
> *Codex drives the app with Chrome DevTools MCP to validate its work*
> ![[openai-harness-001-devtools-validation-loop.png]]
>
> Bottleneck became human QA capacity. Made the app bootable per git worktree so Codex could launch one instance per change. Wired Chrome DevTools Protocol into agent runtime for DOM snapshots, screenshots, navigation. Codex reproduces bugs, validates fixes, reasons about UI directly.
>
> *Giving Codex a full observability stack*
> ![[openai-harness-002-observability-stack.png]]
>
> Same for observability: logs, metrics, traces exposed via ephemeral local stack per worktree. Agents query logs with LogQL and metrics with PromQL. Prompts like "ensure service startup completes in under 800ms" become tractable.
>
> Single Codex runs regularly work 6+ hours on a task (often while humans sleep).
>
> ---
>
> **Repository knowledge as the system of record**
>
> "Give Codex a map, not a 1,000-page instruction manual."
>
> The monolithic AGENTS.md approach failed:
> - Context is scarce — crowds out the task
> - Too much guidance becomes non-guidance
> - Rots instantly
> - Hard to verify mechanically
>
> Solution: AGENTS.md (~100 lines) as table of contents. Knowledge base in structured `docs/`:
>
> ```
> AGENTS.md
> ARCHITECTURE.md
> docs/
> ├── design-docs/
> │   ├── index.md
> │   ├── core-beliefs.md
> │   └── ...
> ├── exec-plans/
> │   ├── active/
> │   ├── completed/
> │   └── tech-debt-tracker.md
> ├── generated/
> │   └── db-schema.md
> ├── product-specs/
> │   ├── index.md
> │   ├── new-user-onboarding.md
> │   └── ...
> ├── references/
> │   ├── design-system-reference-llms.txt
> │   ├── nixpacks-llms.txt
> │   ├── uv-llms.txt
> │   └── ...
> ├── DESIGN.md
> ├── FRONTEND.md
> ├── PLANS.md
> ├── PRODUCT_SENSE.md
> ├── QUALITY_SCORE.md
> ├── RELIABILITY.md
> └── SECURITY.md
> ```
>
> Progressive disclosure: agents start with small stable entry point, taught where to look next. Enforced mechanically with linters, CI validation for freshness and cross-links, and a recurring "doc-gardening" agent.
>
> ---
>
> **Agent legibility is the goal**
>
> *The limits of agent knowledge: what Codex can't see doesn't exist*
> ![[openai-harness-003-agent-knowledge-limits.png]]
>
> Repository optimized for Codex's legibility, not human preferences. From the agent's POV, anything not in-context doesn't exist. Knowledge in Google Docs, Slack, people's heads = illegible.
>
> Favored "boring" technologies (composability, API stability, training set representation). Sometimes cheaper to reimplement than work around opaque upstream behavior (e.g., custom map-with-concurrency helper instead of generic p-limit, integrated with OpenTelemetry, 100% test coverage).
>
> ---
>
> **Enforcing architecture and taste**
>
> *Layered domain architecture with explicit cross-cutting boundaries*
> ![[openai-harness-004-layered-architecture.png]]
>
> Rigid architectural model: each business domain divided into fixed layers (Types → Config → Repo → Service → Runtime → UI). Cross-cutting concerns through single interface: Providers. Enforced via custom linters (Codex-generated) and structural tests.
>
> "Taste invariants": structured logging, naming conventions, file size limits, platform reliability requirements. Custom lint error messages inject remediation into agent context.
>
> Enforce boundaries centrally, allow autonomy locally. Code doesn't always match human style preferences — that's okay if correct, maintainable, and legible to future agent runs.
>
> ---
>
> **Throughput changes the merge philosophy**
>
> Minimal blocking merge gates. Short-lived PRs. Test flakes addressed with follow-up runs. Corrections cheap, waiting expensive.
>
> ---
>
> **What "agent-generated" actually means**
>
> Everything: product code, tests, CI, release tooling, internal dev tools, documentation, design history, eval harnesses, review comments, repo management scripts, production dashboards.
>
> Humans: prioritize work, translate feedback into acceptance criteria, validate outcomes. When agent struggles → identify what's missing → feed it back into repo (always via Codex).
>
> ---
>
> **Increasing levels of autonomy**
>
> Given a single prompt, Codex can now: validate codebase → reproduce bug → record failure video → implement fix → validate fix → record resolution video → open PR → respond to feedback → detect/remediate build failures → escalate only when judgment required → merge.
>
> ---
>
> **Entropy and garbage collection**
>
> Agents replicate existing patterns, including suboptimal ones → drift. Team spent every Friday (20%) cleaning "AI slop" — didn't scale.
>
> Solution: "golden principles" encoded in repo + recurring background Codex tasks that scan for deviations, update quality grades, open targeted refactoring PRs. Most reviewable in under a minute, automerged.
>
> Technical debt = high-interest loan. Pay down continuously. Human taste captured once, enforced continuously on every line.
>
> ---
>
> **What we're still learning**
>
> Don't yet know how architectural coherence evolves over years. Still learning where human judgment adds most leverage and how to encode it so it compounds.
>
> "Building software still demands discipline, but the discipline shows up more in the scaffolding rather than the code."
>
> *Author: Ryan Lopopolo, Member of the Technical Staff*
> *With Victor Zhu and Zach Brock*

[Original article](https://openai.com/index/harness-engineering/)
