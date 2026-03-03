---
created: 2026-03-02
description: Factory documents AGENTS.md as a universal Markdown briefing file that any AI coding agent discovers via directory proximity, providing build commands, architecture, conventions, and gotchas without polluting README files.
source: https://docs.factory.ai/cli/configuration/agents-md
---

## Key Takeaways

Factory's AGENTS.md convention solves a fundamental problem in [[agentic-software-engineering-requires-six-pillars-beyond-the-agent-itself-to-survive-production|agent infrastructure]]: how to give coding agents the same tribal knowledge that senior engineers carry implicitly. Rather than inventing a proprietary format, they chose plain Markdown with a predictable filename — the same pattern now adopted by Cursor, Aider, Gemini CLI, Codex, and others.

The discovery hierarchy uses proximity-based precedence: the AGENTS.md closest to the file being edited wins, with a chain from the current working directory up to the repo root, plus sub-folder overrides and a personal `~/.factory/AGENTS.md` fallback. This mirrors how `.gitignore` or `.editorconfig` work — local specificity overrides global defaults. This is relevant to how [[Factory droid-action wraps agent execution into a GitHub Actions contract with structured inputs MCP tools and STRIDE security skills|Factory's droid-action]] consumes repository context in CI.

The recommended structure is terse (≤ 150 lines) with concrete back-ticked commands across five canonical sections: Build & Test, Architecture Overview, Security, Git Workflows, and Conventions & Patterns. The emphasis on brevity over completeness is deliberate — long context files bury signal and slow agents, echoing lessons from [[Factory droid exec uses tiered autonomy levels to gate agent permissions from read-only to full system access|Factory's tiered autonomy model]] where precise constraints outperform broad permissions.

The agent consumption pipeline is four stages: Ingestion (load nearest file), Planning (extract build/test commands), Tool Selection (use folder/naming conventions to steer file operations), and Validation (use gotchas and domain vocabulary to reduce hallucinations). This maps cleanly to the Explore → Plan → Code → Verify loop Factory promotes.

Section 9 on drift recovery is notably pragmatic: warning signs include self-rewriting plans, edits outside declared paths, and claimed fixes without failing tests. The recovery playbook — tighten spec, salvage good artifacts, restart clean, or take over manually — acknowledges that agent reliability is probabilistic and human oversight remains essential.

## External Resources

- [Factory AGENTS.md docs](https://docs.factory.ai/cli/configuration/agents-md) — canonical reference
- [Specification Mode](https://docs.factory.ai/cli/user-guides/specification-mode) — specs + AGENTS.md for instant feature context
- [Auto-Run](https://docs.factory.ai/cli/user-guides/auto-run) — automation that depends on accurate build/test commands in AGENTS.md

## Original Content

> [!quote]- Source Material
> 
> # AGENTS.md
> 
> > Teach agents everything they need to know about your project with a single Markdown file.
> 
> ## 1 · What is **AGENTS.md**?
> 
> **AGENTS.md** is a Markdown file that lives in your repository (or home directory) and acts as a *briefing packet* for AI coding agents.
> 
> ### Why AGENTS.md?
> 
> **README.md** files are for humans: quick starts, project descriptions, and contribution guidelines.
> 
> **AGENTS.md** complements this by containing the extra, sometimes detailed context coding agents need: build steps, tests, and conventions that might clutter a README or aren't relevant to human contributors.
> 
> We intentionally kept it separate to:
> 
> * Give agents a clear, predictable place for instructions
> * Keep READMEs concise and focused on human contributors
> * Provide precise, agent-focused guidance that complements existing README and docs
> 
> ### What it contains:
> 
> * Describes how to **build, test, and run** your project
> * Explains architectural patterns and conventions
> * Lists external services, environment variables, or design docs
> * Provides domain-specific vocabulary and code style rules
> 
> Agents read AGENTS.md *before* planning any change, giving them the same tribal knowledge senior engineers already carry in their heads.
> 
> ---
> 
> ## 2 · One AGENTS.md works across many agents
> 
> Your AGENTS.md file is compatible with a growing ecosystem of AI coding agents and tools, including:
> 
> * **Droids** - Factory's AI coding agents
> * **Cursor** - AI-powered code editor
> * **Aider** - AI pair programming in your terminal
> * **Gemini CLI** - Google's command-line AI assistant
> * **Jules** - Google's coding assistant
> * **Codex** - OpenAI's code generation model
> * **Zed** - AI-enhanced editor
> * **Phoenix** - AI development platform
> * And many more emerging tools
> 
> Rather than introducing another proprietary file format, AGENTS.md uses a standard that works across the entire AI development ecosystem.
> 
> ---
> 
> ## 3 · File locations & discovery hierarchy
> 
> Agents look for AGENTS.md in this order (first match wins):
> 
> 1. `./AGENTS.md` in the **current working directory**
> 2. The nearest parent directory up to the repo root
> 3. Any `AGENTS.md` in sub-folders the agent is working inside
> 4. Personal override: `~/.factory/AGENTS.md`
> 
> > **Note:** Multiple files can coexist. The closer one to the file being edited takes precedence.
> 
> ---
> 
> ## 4 · File structure & syntax
> 
> AGENTS.md is plain Markdown; headings provide semantic hints.
> 
> ```md
> # Build & Test ← exact commands for compiling and testing
> 
> # Architecture Overview ← short description of major modules
> 
> # Security ← auth flows, API keys, sensitive data
> 
> # Git Workflows ← branching, commit conventions, PR requirements
> 
> # Conventions & Patterns ← naming, folder layout, code style
> ```
> 
> Agents recognize:
> 
> * **Top-level headings** (`#`) as sections
> * **Bullet lists** for commands or rules
> * **Inline code** (`` ` ``) for exact commands, filenames, env vars
> * **Links** to external docs (GitHub, Figma, Confluence…)
> 
> ---
> 
> ## 5 · Common sections
> 
> | Section                    | Purpose                                                       |
> | -------------------------- | ------------------------------------------------------------- |
> | **Build & Test**           | Exact commands for compiling and running the test suite.      |
> | **Architecture Overview**  | One-paragraph summary of major modules and data flow.         |
> | **Security**               | API keys, endpoints, auth flows, rate limits, sensitive data. |
> | **Git Workflows**          | Branching strategy, commit conventions, PR requirements.      |
> | **Conventions & Patterns** | Folder structure, naming patterns, code style, lint rules.    |
> 
> Include only what *future you* will care about—brevity beats encyclopaedia-length files.
> 
> ---
> 
> ## 6 · Templates & examples
> 
> ### Factory-style comprehensive example
> 
> ```md
> # MyProject
> 
> This is an overview of My Project. It's an example app used to highlight AGENTS.md files utility.
> 
> ## Core Commands
> 
> • Type-check and lint: `pnpm check`
> • Auto-fix style: `pnpm check:fix`
> • Run full test suite: `pnpm test --run --no-color`
> • Run a single test file: `pnpm test --run <path>.test.ts`
> • Start dev servers (frontend + backend): `pnpm dev`
> • Build for production: `pnpm build` then `pnpm preview`
> 
> All other scripts wrap these six tasks.
> 
> ## Project Layout
> 
> ├─ client/ → React + Vite frontend
> ├─ server/ → Express backend
> 
> • Frontend code lives **only** in `client/`
> • Backend code lives **only** in `server/`
> • Shared, environment-agnostic helpers belong in `src/`
> 
> ## Development Patterns & Constraints
> 
> Coding style
> • TypeScript strict mode, single quotes, trailing commas, no semicolons.
> • 100-char line limit, tabs for indent (2-space YAML/JSON/MD).
> • Use interfaces for public APIs; avoid `@ts-ignore`.
> • Tests first when fixing logic bugs.
> • Visual diff loop for UI tweaks.
> • Never introduce new runtime deps without explanation in PR description.
> 
> ## Git Workflow Essentials
> 
> 1. Branch from `main` with a descriptive name: `feature/<slug>` or `bugfix/<slug>`.
> 2. Run `pnpm check` locally **before** committing.
> 3. Force pushes **allowed only** on your feature branch using
>    `git push --force-with-lease`. Never force-push `main`.
> 4. Keep commits atomic; prefer checkpoints (`feat: …`, `test: …`).
> 
> ## Evidence Required for Every PR
> 
> A pull request is reviewable when it includes:
> 
> - All tests green (`pnpm test`)
> - Lint & type check pass (`pnpm check`)
> - Diff confined to agreed paths (see section 2)
> - **Proof artifact**
>   • Bug fix → failing test added first, now passes
>   • Feature → new tests or visual snapshot demonstrating behavior
> - One-paragraph commit / PR description covering intent & root cause
> - No drop in coverage, no unexplained runtime deps
> ```
> 
> ### Node + React monorepo
> 
> ```md
> # Build & Test
> 
> - Build: `npm run build`
> - Test: `npm run test -- --runInBand`
> 
> # Run Locally
> 
> - API: `npm run dev --workspace=api`
> - Web: `npm run dev --workspace=web`
> - Storybook: `npm run storybook`
> 
> # Conventions
> 
> - All backend code in `packages/api/src`
> - React components in `packages/web/src/components`
> - Use `zod` for request validation
> 
> # Architecture Overview
> 
> The API is GraphQL (Apollo). Web uses Next.js with SSR.
> 
> # External Services
> 
> - Stripe for payments (`STRIPE_KEY`)
> - S3 for uploads (`AWS_BUCKET`)
> 
> # Gotchas
> 
> - Test snapshot paths are absolute—run `npm run test -- --updateSnapshot` after refactors.
> ```
> 
> ### Python microservice
> 
> ```md
> # Build & Test
> 
> - Build: `pip install -e .`
> - Test: `pytest`
> 
> # Run Locally
> 
> - `uvicorn app.main:app --reload`
> 
> # Conventions
> 
> - Config via Pydantic settings (`settings.py`)
> - CELERY tasks live in `tasks/`
> ```
> 
> ---
> 
> ## 7 · Best practices
> 
> - **Keep it short** — Aim for ≤ 150 lines. Long files slow the agent and bury signal.
> - **Use concrete commands** — Wrap commands in back-ticks so agents can copy-paste without guessing.
> - **Update alongside code** — Treat AGENTS.md like code—PR reviewers should nudge updates when build steps change.
> - **One source of truth** — Avoid duplicate docs; link to READMEs or design docs instead of pasting them.
> - **Make requests precise** — The more precise your guidance for the task at hand, the more likely the agent is to accomplish that task to your liking.
> - **Verify before merging** — Require objective proof: tests, lint, type check, and a diff confined to agreed paths.
> 
> ---
> 
> ## 8 · How agents use AGENTS.md
> 
> 1. **Ingestion** — On task start, agents load the nearest AGENTS.md into their context window.
> 2. **Planning** — Build/test commands are used to form the execution plan (e.g. run tests after edits).
> 3. **Tool selection** — Folder and naming conventions steer tools like `edit_file` and `create_file`.
> 4. **Validation** — Gotchas and domain vocabulary improve reasoning and reduce hallucinations.
> 
> ---
> 
> ## 9 · When things go wrong
> 
> Like any development work, agent tasks sometimes need course correction when scope creeps or assumptions prove wrong. The same iteration patterns that work with human collaborators apply here.
> 
> ### Warning signs of agent drift:
> 
> * Plans that rewrite themselves mid-execution
> * Edits outside the declared paths
> * Fixes claimed without failing tests to prove they work
> * Diffs bloated with unrelated changes
> 
> ### Recovery playbook:
> 
> 1. **Tighten the spec**: Narrow the directory or tests the agent may touch
> 2. **Salvage the good**: Keep valid artifacts such as a failing test; revert noisy edits
> 3. **Restart clean**: Launch a fresh session with improved instructions
> 4. **Take over**: When you can tell the agent is failing, pair program the final changes
> 
> ---
> 
> ## 10 · Getting started
> 
> ### Summary
> 
> 1. Add **AGENTS.md** at your repo root (and optionally submodules).
> 2. Document build/test commands, conventions, and gotchas—*concise & actionable*.
> 3. Agents read it automatically; no extra flags required.
> 
> Pick one modest bug or small feature from your backlog. Write three clear sentences that state where to begin, how to reproduce the issue, and what proof signals completion. Run the agent through Explore → Plan → Code → Verify, review the evidence, and merge.
> 
> Ship faster with fewer surprises—give your agent the playbook it needs!
