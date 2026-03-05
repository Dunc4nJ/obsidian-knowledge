---
created: 2026-03-04
description: Practical guide to building internal coding agents based on how Stripe, Ramp, and Coinbase approached seven key decisions — harness, sandbox, tools, orchestration, testing, invocation, and adoption.
source: https://x.com/kishan_dahya/status/2028971339974099317
type: synthesis
---

## Key Takeaways

The most important pattern across all three companies is that **sandbox isolation is the single biggest unlock** for autonomous agents. Stripe's devboxes have no production access, no real data, no network egress — so agents run with full permissions and zero confirmation prompts. This echoes the principle from [[agents need a harness not a framework because durable event-driven infrastructure already solves retry routing and state]] — the infrastructure does the safety work, not the agent.

Stripe's **Blueprints** represent a genuinely novel orchestration pattern: a state machine that alternates between deterministic nodes (lint, format, git push) and agentic subtask nodes (implement this ticket). Each deterministic node you add is one fewer thing the LLM can get wrong. This is the [[harness engineering improved a coding agent 13 points by changing only system prompts tools and middleware|harness engineering]] principle taken to its logical conclusion — constrain the agent where you can, free it where you must.

**Tool curation > tool quantity.** Stripe has ~500 tools in their internal MCP server (Toolshed) but each agent gets a small curated subset. More tools means more confusion and wasted tokens on tool selection. This aligns with [[designing agent tools is an iterative art shaped by model capabilities not fixed engineering rules]].

Stripe's **context pre-hydration** is worth stealing: before a Minion run starts, the orchestrator scans the Slack thread for links and deterministically pulls Jira tickets, docs, and code search results. The agent starts with rich assembled context rather than discovering everything through tool calls.

The three companies form a **validation spectrum** from conservative to radical: Stripe caps at two CI runs then hands to humans; Ramp adds DOM-based visual verification; Coinbase uses "agent councils" for first-pass review and auto-merges low-risk changes, targeting 5-minute PR cycles (down from 150 hours).

**Slack is the universal adoption layer** — not because it's the best interface, but because it's where results become visible to non-users. Ramp's explicit strategy: "We didn't force anyone... we let the product do the talking" in public channels. Within months, ~30% of all merged PRs were agent-written.

Goose (Block's open-source agent, now in [[Goose|our vault]]) gets a real-world validation signal here: Stripe forked it as the foundation for their Minions system, which produces 1,300+ merged PRs per week.

*Harness selection: Stripe forked, Ramp composed, Coinbase built from scratch*
![[kishan-099317-001.jpg]]

*The fork/compose/build tradeoff matrix*
![[kishan-099317-002.jpg]]

*Full decision matrix across all seven dimensions*
![[kishan-099317-003.jpg]]

## External Resources

- [Stripe Minions Part 1](https://stripe.dev/blog/minions-stripes-one-shot-end-to-end-coding-agents) — one-shot end-to-end coding agents
- [Stripe Minions Part 2](https://stripe.dev/blog/minions-stripes-one-shot-end-to-end-coding-agents-part-2) — infrastructure and orchestration details
- [Ramp: Why We Built Our Background Agent](https://builders.ramp.com/post/why-we-built-our-background-agent)
- [Coinbase: Chintan Turakhia on How I AI podcast](https://youtu.be/tidINuXB7PA)
- [Ry Walker's survey of in-house coding agents](https://rywalker.com/research/in-house-coding-agents)
- [Goose (Block)](https://github.com/block/goose) — open-source agent Stripe forked
- [OpenCode](https://github.com/opencode-ai/opencode) — agent Ramp built on top of

## Original Content

> [!quote]- Source Material (kishan_dahya on X, 2026-03-03)
>
> **Article: Enough About Harnesses, Your Org Needs Its Own Coding Agent**
>
> Elite engineering orgs like Stripe, Ramp, and Coinbase are building their own internal coding agents. These agents run as Slackbots, CLIs, web apps, and Chrome Extensions, meeting engineers where they already work.
>
> They're connected to internal systems with the right context, permissioning, and safety boundaries to operate with minimal or no human approvals.
>
> And because they're so useful, they're spreading beyond engineering as product managers, GTM, and other non-technical team members see their success in Slack and begin using them too.
>
> Background: The best engineering orgs are AI-native already. It's not coming, it's here:
>
> 1. Stripe runs hundreds of millions of lines of Ruby with Sorbet typing — a stack most LLMs struggle with — while processing over a trillion dollars in payments annually. Their agents now produce over 1,300 merged pull requests per week.
>
> 2. Ramp needed agents that could verify their own work across both frontend and backend, with full engineer-level context. They built a multi-client agent platform in-house that spans Slack, web, and a Chrome extension.
>
> 3. Coinbase had financial and crypto security requirements that blocked third-party background agents entirely. They compressed PR cycle time from 150 hours to 15 hours, and are now targeting 5 minutes.
>
> And as @rywalker's survey of in-house coding agents shows, they're far from alone — this is becoming a pattern across the industry.
>
> What follows is a practical guide to the decisions you'll face if you go down this path, showing how Stripe, Ramp, and Coinbase approached each one differently and what you can learn from each.
>
> Sources: This article draws from Stripe's two-part Minions blog series on stripe.dev, Ramp's "Why We Built Our Background Agent", Chintan Turakhia's appearance on the How I AI podcast, and original research comparing open-source agent harness implementations.
>
> ## 1. The Agent Harness
>
> The first decision is what harness your agent will run in.
>
> Stripe forked. They took Block's open-source goose coding agent and customized it with opinionated orchestration that interleaves agent loops with deterministic code for git operations, linters, and testing. Forking gave them a head start on the core agent loop while letting them impose strict control over how that loop interacts with Stripe's infrastructure.
>
> Ramp composed. They built on top of OpenCode as the underlying agent, choosing it for its server-first architecture and typed SDK. A practical bonus: the agent can read its own source code, which helps it understand its own capabilities. Composing on an existing agent gives you an upgrade path — you can pull in improvements from upstream — but couples you to that project's architectural decisions.
>
> Coinbase built from scratch. Their agent, Cloudbot, is in-house built and multi-model — not locked to any single provider. Security requirements for a financial platform handling crypto drove this decision. Building from scratch gives you total control but carries the highest implementation cost.
>
> The tradeoffs are straightforward. Forking gives you speed but ties you to upstream decisions you may not agree with. Composing gives you an upgrade path but couples you to a framework's center of gravity. Building gives you full control but means you own every bug.
>
> ## 2. The Sandbox: Where Agents Run Code
>
> You could have engineers run agents locally, but once agents are writing and executing code autonomously, uncontrolled local execution gets risky fast. All three companies converge on cloud-based sandboxes whether ephemeral VMs or containers. The sandbox is part of your safety model. Your agent execution environment is one of the most consequential decisions you'll make.
>
> Stripe: Cloud VMs as Cattle
>
> Stripe runs agents on devboxes — AWS EC2 instances that serve as standardized cloud developer environments. They're treated as cattle, not pets: easily replaceable, spun up from a proactively warmed pool with 10-second readiness.
>
> Each devbox comes pre-loaded with everything an engineer (or agent) needs:
> - Pre-cloned git repositories (gigabytes of source code)
> - Warmed Bazel and type-checking caches
> - Running code generation services
> - Checked out to a recent copy of master
>
> The isolation model is what makes this work at a payments company. Devboxes run in a QA environment with no real user data, no access to production Stripe services, and no arbitrary network egress. Because the blast radius of any mistake is fully contained, agents can run with full permissions and no confirmation prompts.
>
> Stripe's insight here is: a development environment that is safe for humans has proven to be just as useful for agents. You don't need to invent new security primitives — you need to make your existing ones fast enough for agents to use.
>
> Ramp: Container Platform with Pre-Warming
>
> Ramp uses Modal for isolated development environments. Pre-built images and snapshots keep repositories current within a 30-minute window — fresh enough for most work, fast enough for on-demand spin-up.
>
> Ramp optimizes for speed. They pre-warm sandboxes while the user is still typing their prompt. By the time the user hits enter, the sandbox is ready. They also do early file reads before sync is fully complete and batch repository-level build steps to minimize startup latency. Agents can also spawn child sessions for parallel work — a sandbox-within-a-sandbox model that lets one agent fan out across multiple tasks.
>
> The result: "Inspect sessions are fast to start and effectively free to run...There's no limit to how many sessions you can have running concurrently, and your laptop doesn't need to be involved at all." They can start a session the moment inspiration hits from anywhere.
>
> Coinbase: Security-Driven In-House
>
> Coinbase built their sandbox in-house, driven by security requirements specific to handling financial and crypto infrastructure. The specifics aren't public, but the motivation is clear: when you're a regulated financial institution, the sandbox isn't just a developer convenience — it's a compliance boundary.
>
> The Pattern
>
> All three converge on the same principle: isolate first, then give full permissions inside the boundary. The sandbox is what makes unattended agent execution safe. If you try to make agents safe through permission prompts and approval gates instead of isolation, you'll end up with an agent that's too slow to be useful or too permissive to be safe.
>
> ## 3. Tools and Context: What Agents Can See and Do
>
> How many tools your LLM can handle and what context to give it is more art than science. Here's how each company approaches it:
>
> Tool Infrastructure
>
> All three companies give their agents access to internal tools via structured interfaces, but at very different scales.
>
> Stripe built an internal MCP server called Toolshed hosting nearly 500 tools spanning internal systems and SaaS platforms. But the critical design decision isn't the number of tools — it's the curation. Agents receive an intentionally small default subset of tools, not unrestricted access to all 500. Each agent instance gets a curated toolset, with per-user customizability and thematic tool grouping. Security controls prevent destructive actions.
>
> The insight: tool curation matters more than tool quantity. Giving an agent access to 500 tools doesn't make it more capable — it makes it more confused and wastes tokens on tool selection. Constraining the toolset per agent type produces better results.
>
> Coinbase takes a different approach to tool breadth. Cloudbot connects to MCPs for Datadog, Sentry, Amplitude, and internal Snowflake databases, plus custom Skills layered on top. It can work across multiple codebases. The emphasis is less on a unified tool platform and more on connecting the specific observability and data sources that matter for debugging and implementation.
>
> Ramp builds on OpenCode's built-in tool system at the SDK level, extending it with their own integrations.
>
> Context Engineering
>
> This is where the real sophistication lives. Getting the right information into the agent's context — not too much, not too little — is the difference between an agent that produces useful PRs and one that hallucinates.
>
> Stripe's rule files use Cursor's format with directory and pattern scoping. Rules automatically attach as the agent traverses the filesystem, and they're synced across three platforms: Minions, Cursor, and Claude Code. This means the same institutional knowledge that helps a human engineer in Cursor also helps an unattended agent. Almost all rules are conditionally applied based on subdirectories — necessary for a codebase with hundreds of millions of lines where different regions have radically different conventions.
>
> Stripe also does context pre-hydration: before a Minion run even starts, the orchestrator scans the Slack thread for links, deterministically pulls Jira tickets, documentation, and Sourcegraph code search results, and runs relevant MCP tools over likely-looking links. The agent starts its work with a rich, pre-assembled context rather than having to discover everything through tool calls.
>
> Coinbase uses Linear as a single context source. All context gets captured in Linear tickets first — the structured bug report, the relevant user journey, the attached files. Then Cloudbot pulls from Linear and fans out into MCPs for additional context. This creates a clean separation: humans curate context into Linear, agents consume it from Linear plus everything else.
>
> As Turakhia put it on the How I AI podcast, the thing he realized is that context is the most important thing — so they funnel everything into Linear first, then let Cloudbot fan out from here.
>
> ## 4. Orchestration: How Agents Think and Act
>
> The fourth decision is how you structure the agent's execution — the loop between receiving a task and producing a pull request.
>
> Stripe's Blueprints
>
> This is Stripe's most distinctive architectural contribution. Blueprints are a hybrid pattern that combines the determinism of workflows with the flexibility of agents, implemented as a state machine that alternates between two types of nodes.
>
> Deterministic nodes always execute the same way: run linters, format code, push to git, execute pre-push hooks. These are the steps that must happen and that LLMs are bad at remembering to do consistently.
>
> Agentic subtask nodes give the LLM creative freedom within a bounded scope: "implement the task described in this ticket," "fix CI failures from the previous run." The LLM can use whatever tools and reasoning it needs, but only within that subtask boundary.
>
> The power of Blueprints is composability. Teams create team-specific custom blueprints for specialized workflows. A team that owns a particular service can encode their deployment conventions, testing requirements, and code review standards into a blueprint — and every agent that runs against their code automatically follows those conventions.
>
> The key principle: putting LLMs into contained boxes compounds reliability. Each deterministic node you add is one fewer thing the LLM can get wrong, which saves tokens, saves CI costs, and makes the overall pipeline more predictable.
>
> Ramp's Session Model
>
> Ramp's orchestration centers on sessions — long-running agent contexts that support follow-up prompts, stopping mechanisms, and multiplayer collaboration.
>
> The session model introduces a design decision Stripe doesn't face with one-shot agents: when a user sends a follow-up prompt, do you queue it or execute immediately? Ramp handles both cases. They also support child sessions, where an agent can spawn sub-agents for parallel work while maintaining a parent context.
>
> Multiplayer is a feature Ramp frames as mission-critical. Multiple team members can collaborate on a single agent session with individual authorship tracking. Use cases include teaching workflows (a senior engineer guides a junior through an agent-assisted task) and QA workflows (a reviewer joins an active session to inspect the agent's work in progress).
>
> Coinbase's Three-Mode Model
>
> Cloudbot offers three distinct modes, each optimized for a different interaction pattern:
>
> 1. Create PR: Takes a Linear ticket and generates a full pull request with code changes.
> 2. Plan: Like Cursor's plan mode — generates an implementation plan and writes it back to the Linear ticket for human review before any code is written.
> 3. Explain: Debug mode — answers questions about why something isn't working, pulling context from MCPs (Datadog, Sentry, etc.) to diagnose issues.
>
> When a PR is complete, Cloudbot responds in Slack with a link to the Cursor branch using Cursor's deep link format, plus a QR code so the engineer can scan it on their phone and immediately test a mobile build.
>
> ## 5. Testing and Validation: How Agents Prove Their Work
>
> The fifth decision is how you validate what the agent produces. This is where the three companies diverge most in philosophy, forming a spectrum from conservative to radical.
>
> Stripe: Shift-Left, Max Two CI Runs
>
> Stripe's testing strategy has three layers:
> 1. Local: Automated lint heuristics run within 5 seconds per git push via pre-push hooks with cached results.
> 2. CI: Selective test execution drawn from over 3 million total tests.
> 3. Agent retry: If CI fails and there's no autofix, the agent gets one single additional attempt.
>
> After that second CI run, if failures persist, it goes to human review. No third attempt, no retry loop. The philosophy is explicit: avoid diminishing returns from excessive LLM iteration.
>
> Ramp: Visual Verification
>
> Ramp's distinctive contribution to validation is visual verification via their Chrome extension. The extension is React-aware and operates on DOM trees rather than screenshots — more reliable for detecting actual UI state versus pixel-level appearance.
>
> Coinbase: Agent Councils and Auto-Merge
>
> Coinbase is the most aggressive. They use Greptile for automated code reviews and have introduced agent councils — groups of AI agents that do first-pass code review. According to Chintan Turakhia, these agent councils produce reviews that are "95%+ better than human" reviews. They're targeting PR cycle time from 15 hours down to 5 minutes.
>
> ## 6. Invocation: How Engineers Access Agents
>
> All three companies converge on Slack as the primary invocation surface. Chintan Turakhia articulated why: the cost of writing something in Slack is zero, but the cost of answering something in Slack is enormous. An agent in Slack turns that dynamic inside out: the cost of answering drops to zero too.
>
> Beyond Slack, Stripe embeds invocation buttons directly into internal platforms (docs, feature flags, ticketing). Ramp builds three client surfaces (web with VS Code, Chrome extension, Slack). Coinbase adds Cursor deep links and QR codes for mobile testing.
>
> ## 7. Adoption: Making It Stick
>
> None forced adoption — they all let the product spread organically:
> - Ramp: "Let the product talk" — ~30% of merged PRs were agent-written within months
> - Stripe: Made it impossible to avoid by embedding everywhere
> - Coinbase: Social proof via "Cursor Wins and Losses" Slack channel, PR speedruns (800 engineers, 300-400 PRs in 30 minutes), dedicated "Super Builder" role
>
> All converge: don't mandate, demonstrate. Put the agent where people already work, make results visible, let adoption compound.
>
> 56 likes · 1 retweet · 1 reply · [Original post](https://x.com/kishan_dahya/status/2028971339974099317)
