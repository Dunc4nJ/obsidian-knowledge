---
created: 2026-03-02
description: HumanLayer's 12-factor agents framework codifies what works in production AI — own your context, keep agents small, stay out of the dumb zone where context window utilization past 40% degrades reasoning.
source: https://paddo.dev/blog/12-factor-agents/
type: framework
---

# 12 Factor Agents — Principles for AI That Actually Work

## Key Takeaways

- HumanLayer's 12 Factor Agents applies the same philosophy as Heroku's 12-factor apps to AI agent design. The core insight: most successful AI products combine deterministic code with strategically placed LLM decision points, rather than relying on purely agentic loops. This directly validates the [[harness engineering improved a coding agent 13 points by changing only system prompts tools and middleware|harness engineering approach]] — the scaffolding around the model matters more than the model itself.

- The "dumb zone" concept is the linchpin: Dex Horthy's analysis of 100,000 developer sessions found that filling past 40% of a context window causes recall degradation and reasoning failures. This connects to [[prompt caching is the foundational constraint for building long running agents|prompt caching as a foundational constraint]] — careful context management isn't just about cost, it's about agent intelligence. Manus AI rebuilt their framework four times learning this lesson.

- The factors map cleanly onto existing Anthropic patterns: Plan Mode implements factors 2, 3, 8 (own prompts, own context, launch/pause/resume); parallel subagents implement factor 10 (small focused agents); CLAUDE.md is factor 3 (curated context); and [[the codex app server turns a cli agent harness into a stable bidirectional json rpc protocol for any client|agent harnesses]] implement factors 5 and 6 (unified state, suspension points). The framework names patterns that were already emerging in practice.

- Factor 13 (pre-fetch context) deserves more attention than its appendix placement suggests. Retrieving context upfront rather than mid-execution keeps agents deterministic and reduces surprises — the same principle behind [[agentic search with grep and full-file loading replaces RAG when context windows are large enough|preferring upfront full-file loading over RAG]].

- The factors explicitly acknowledge what stays human: strategic vision, novel architecture decisions, ambiguous requirements, and final accountability. Agents optimize delegation of mechanical work, but [[over 40 percent of agentic AI projects fail due to poor architecture not model limitations|architecture decisions remain the bottleneck]], not model capabilities.

## External Resources

- [12 Factor Agents repo](https://github.com/humanlayer/12-factor-agents) — full implementation examples and deeper explanations for each factor
- [Heroku's 12-factor apps](https://12factor.net/) — the original inspiration for cloud-native application design
- [Anthropic's context engineering guidance](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents) — complementary reading on finding the smallest set of high-signal tokens
- [Dex Horthy on X](https://x.com/dexhorthy) — HumanLayer founder who coined the "dumb zone" concept

## Original Content

> [!quote]- Source Material
>
> *Header image for 12 Factor Agents article*
> ![[horthy-12factor-001.webp]]
>
> 05-DEC-25 [5 MIN]
>
> # 12 Factor Agents: Principles for AI That Actually Work
>
> Heroku's [12-factor apps](https://12factor.net/) shaped how a generation of engineers built cloud software. Stateless processes, config in environment variables, disposable instances. The principles became so embedded in how we think about deployment that we stopped naming them.
>
> [12 Factor Agents](https://github.com/humanlayer/12-factor-agents) from HumanLayer aims to do the same for AI. The core insight is disarmingly practical: most successful AI products aren't purely agentic loops. They combine deterministic code with strategically placed LLM decision points.
>
> > Most of the products out there billing themselves as 'AI Agents' are not all that agentic. The fastest path to quality involves incorporating modular agent concepts into existing products rather than adopting full agent frameworks.
> >
> > — HumanLayer, 12 Factor Agents
>
> ## The 12 Factors
>
> Here's the full list, organized by what they govern:
>
> ### Control
>
> * **Own your prompts** - Direct control over prompt engineering, not framework abstractions
> * **Own your control flow** - Explicit execution paths, not delegated loops
> * **Stateless reducer** - Agents as pure functions: input state → output state
>
> ### Context
>
> * **Own your context window** - Curate what enters the LLM's attention
> * **Compact errors** - Distill failures into concise context, not verbose logs
> * **Pre-fetch context** - Retrieve information upfront, not mid-execution
>
> ### State
>
> * **Unify execution and business state** - No parallel state systems to synchronize
> * **Launch/pause/resume** - Suspension points for human intervention
>
> ### Interface
>
> * **Natural language to tool calls** - LLM outputs decisions, not final execution
> * **Tools are structured outputs** - Tool-calling is structured output generation
> * **Trigger from anywhere** - Webhooks, cron, user actions, external events
>
> ### Architecture
>
> * **Small, focused agents** - Narrow responsibilities over monolithic systems
> * **Contact humans with tool calls** - Human-in-the-loop as first-class operation
>
> The appendix factor
>
> Factor 13 (pre-fetch context) appears in the appendix but deserves equal weight. Retrieving context upfront reduces mid-execution lookups and keeps agents deterministic.
>
> ## The Dumb Zone
>
> Factor 3 - own your context window - is the linchpin. The others depend on it.
>
> Context windows aren't just storage. They're attention budgets. [Dex Horthy](https://x.com/dexhorthy) (HumanLayer founder) analyzed 100,000 developer sessions and identified the "dumb zone": the middle 40-60% of a large context window where model recall degrades and reasoning falters. Fill past 40% and diminishing returns kick in. The more you use the context window, the worse the outcomes.
>
> This aligns with research on the "lost in the middle" problem: LLMs perform best when relevant information is at the beginning or end of context, with significant degradation for information buried in long sequences.
>
> > As agents become more capable, they naturally accumulate more tools. Your heavily armed agent gets dumber.
> >
> > — Manus AI, Context Engineering for Agents
>
> Manus rebuilt their agent framework four times learning this. Anthropic's [context engineering guidance](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents) frames it as finding "the smallest set of high-signal tokens that maximize the likelihood of your desired outcome."
>
> Check your context
>
> In Claude Code, type `/context` to see what's loaded. You'll often find MCP definitions, bloated CLAUDE.md files, and conversation history consuming tokens before you've started real work. Clean context = sharp agent.
>
> ## Factors in Practice
>
> These principles aren't theoretical. Anthropic's tools embody them:
>
> **Plan Mode = Factors 2, 3, 8** [Plan Mode](/blog/plan-mode-mandatory-auto-compact-yes) blocks write tools at the system level. You own the prompt (factor 2), the context stays focused on planning not execution artifacts (factor 3), and you control when execution begins (factor 8). No framework abstractions hiding the decision points.
>
> **Parallel subagents = Factor 10** Plan Mode spawns lightweight Haiku agents to explore your codebase simultaneously. Each gets an isolated context window, returns condensed findings, and dies. Small, focused, disposable. Factor 10 in action.
>
> **CLAUDE.md = Factor 3** Project and user-level instruction files are [curated context](/blog/stop-speedrunning-claude-code). Short, specific, opinionated. Not documentation for you - training for Claude. Every token in CLAUDE.md is a token not available for understanding your actual code.
>
> **Agent harnesses = Factors 5, 6** [Progress files and feature lists](/blog/agent-harnesses-from-diy-to-product) unify execution state with business state. The agent reads `claude-progress.txt` before touching code. Launch/pause/resume happens through git commits and human review, not magic framework hooks.
>
> ## Small Over Monolithic
>
> Factor 10 - small, focused agents - is the antidote to framework bloat.
>
> The community built elaborate scaffolding: BMAD with 19 specialized agents, Spec-Kit with multi-stage workflows, external orchestration layers. These existed because the tools lacked native structure.
>
> Now [native features absorb the patterns](/blog/external-scaffolding-era-ending). Plan Mode does what manual plan/act splits did. Parallel subagents do what external orchestration did. The scaffolding becomes friction.
>
> The 12-factor philosophy aligns: don't build monolithic agent systems. Build small agents with clear interfaces. Let them compose. The complexity lives in the composition, not the individual agents.
>
> ## What Factors Don't Solve
>
> Factor 7 (contact humans with tool calls) enables human-in-the-loop workflows. It doesn't replace the need for human judgment.
>
> What stays human:
>
> * **Strategic vision** - What problem to solve, what market to enter
> * **Novel architecture** - Cross-cutting decisions that require deep system intuition
> * **Ambiguous requirements** - When the spec is unclear, agents can't resolve it themselves
> * **Final accountability** - Engineers own what ships
>
> The [SDLC collapse](/blog/sdlc-is-collapsing) pattern holds: delegate mechanical work, review for correctness, own the judgment calls. The factors optimize the delegation. They don't automate the ownership.
>
> The 90/90 rule still applies
>
> The first 90% of the code takes 90% of the time. The remaining 10% takes the other 90%. Agents accelerate the first pass. The long tail of edge cases, integration issues, and iterative refinement remains long.
>
> ## Applying the Factors
>
> If you're building with AI agents:
>
> * **Treat context as a scarce resource** - Every MCP, every tool definition, every line of CLAUDE.md consumes attention budget. Keep it lean.
> * **Own the control flow** - Don't hand execution to framework loops. Know exactly when and why the LLM makes decisions.
> * **Build small agents** - One agent, one job. Compose them rather than building monoliths.
> * **Design pause points** - Factor 6 isn't optional. Agents need suspension points for human review, especially for irreversible operations.
> * **Pre-fetch aggressively** - Factor 13 reduces mid-execution surprises. Gather context upfront, not when the agent stumbles.
> * **Stay out of the dumb zone** - Keep context under 40% capacity. `/clear` between tasks. Let auto-compact handle overflow.
>
> The 12 factors aren't new ideas. They're the patterns that emerged from building agents that actually work in production. Now they have names.
>
> Read the original
>
> The full [12 Factor Agents](https://github.com/humanlayer/12-factor-agents) repo includes implementation examples and deeper explanations for each factor. Worth reading alongside Anthropic's [context engineering guidance](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents).

Source: [12 Factor Agents: Principles for AI That Actually Work](https://paddo.dev/blog/12-factor-agents/)
