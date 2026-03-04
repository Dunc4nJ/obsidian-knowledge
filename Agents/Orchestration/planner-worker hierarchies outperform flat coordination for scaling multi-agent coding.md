---
created: 2026-03-04
description: Cursor found that separating agents into planners and workers with periodic fresh starts scales autonomous coding to hundreds of concurrent agents over weeks, after flat self-coordination failed due to lock contention and risk aversion.
source: https://cursor.com/blog/scaling-agents
---

# Planner-worker hierarchies outperform flat coordination for scaling multi-agent coding

## Key Takeaways

Cursor ran hundreds of concurrent coding agents on single projects for weeks, producing over a million lines of code. Their journey from flat self-coordination to a planner-worker hierarchy mirrors lessons from [[intelligent AI delegation requires trust accountability and adaptive monitoring not just task decomposition]] — the coordination architecture matters more than individual agent capability.

Their first attempt at flat, peer-to-peer coordination with shared locks failed predictably: lock contention reduced twenty agents to the throughput of two or three. Switching to optimistic concurrency control helped mechanically but revealed a deeper problem — without hierarchy, agents became risk-averse and avoided hard tasks, echoing the finding in [[2 to 5 worker agents per lead is the sweet spot for multi agent orchestration]] that some form of leadership structure is essential.

The winning architecture separates planners (who explore the codebase and create tasks recursively) from workers (who grind on assigned tasks without coordinating with each other), with a judge agent deciding when to restart fresh cycles. This is strikingly similar to the [[separating cognitive blueprints from runtime engines enables portable auditable agent systems]] pattern — distinct cognitive roles with clear boundaries.

A surprising finding is that prompts matter more than the harness or model choice for sustained multi-agent coordination. This connects to [[Everything is Context: Agentic File System Abstraction for Context Engineering]] — what you feed agents shapes behavior more than infrastructure. They also found that removing complexity (cutting the integrator role) improved throughput, reinforcing that [[simple financial agents outperform complex ones when tool routing is tight|simpler agent systems often outperform complex ones]].

Model selection per role proved important: GPT-5.2 excelled at planning and sustained focus, while Opus 4.5 tended to take shortcuts and yield control early. This role-specific model assignment is a practical orchestration insight — not all agents in a squad should run the same model.

The scale of their experiments is remarkable: a browser built from scratch (1M+ LoC), a Solid-to-React migration (+266K/-193K edits over three weeks), and ongoing projects like a Java LSP (550K LoC) and Windows 7 emulator (1.2M LoC). Periodic fresh starts remain necessary to combat drift and tunnel vision.

## External Resources

- [fastrender](https://github.com/wilsonzlin/fastrender) — Browser from scratch built by the agent swarm (1M+ LoC)
- [Java LSP](https://github.com/wilson-anysphere/indonesia) — 7.4K commits, 550K LoC, still running
- [Windows 7 emulator](https://github.com/wilsonzlin/aero) — 14.6K commits, 1.2M LoC
- [Excel clone](https://github.com/wilson-anysphere/formula) — 12K commits, 1.6M LoC

## Original Content

> [!quote]- Source Material
>
> We've been experimenting with running coding agents autonomously for weeks.
>
> Our goal is to understand how far we can push the frontier of agentic coding for projects that typically take human teams months to complete.
>
> This post describes what we've learned from running hundreds of concurrent agents on a single project, coordinating their work, and watching them write over a million lines of code and trillions of tokens.
>
> ## The limits of a single agent
>
> Today's agents work well for focused tasks, but are slow for complex projects. The natural next step is to run multiple agents in parallel, but figuring out how to coordinate them is challenging.
>
> Our first instinct was that planning ahead would be too rigid. The path through a large project is ambiguous, and the right division of work isn't obvious at the start. We began with dynamic coordination, where agents decide what to do based on what others are currently doing.
>
> ## Learning to coordinate
>
> Our initial approach gave agents equal status and let them self-coordinate through a shared file. Each agent would check what others were doing, claim a task, and update its status. To prevent two agents from grabbing the same task, we used a locking mechanism.
>
> This failed in interesting ways:
>
> 1. Agents would hold locks for too long, or forget to release them entirely. Even when locking worked correctly, it became a bottleneck. Twenty agents would slow down to the effective throughput of two or three, with most time spent waiting.
> 2. The system was brittle: agents could fail while holding locks, try to acquire locks they already held, or update the coordination file without acquiring the lock at all.
>
> We tried replacing locks with optimistic concurrency control. Agents could read state freely, but writes would fail if the state had changed since they last read it. This was simpler and more robust, but there were still deeper problems.
>
> With no hierarchy, agents became risk-averse. They avoided difficult tasks and made small, safe changes instead. No agent took responsibility for hard problems or end-to-end implementation. This led to work churning for long periods of time without progress.
>
> ## Planners and workers
>
> Our next approach was to separate roles. Instead of a flat structure where every agent does everything, we created a pipeline with distinct responsibilities.
>
> - **Planners** continuously explore the codebase and create tasks. They can spawn sub-planners for specific areas, making planning itself parallel and recursive.
> - **Workers** pick up tasks and focus entirely on completing them. They don't coordinate with other workers or worry about the big picture. They just grind on their assigned task until it's done, then push their changes.
>
> At the end of each cycle, a judge agent determined whether to continue, then the next iteration would start fresh. This solved most of our coordination problems and let us scale to very large projects without any single agent getting tunnel vision.
>
> ## Running for weeks
>
> To test this system, we pointed it at an ambitious goal: building a web browser from scratch. The agents ran for close to a week, writing over 1 million lines of code across 1,000 files. You can explore the [source code on GitHub](https://github.com/wilsonzlin/fastrender).
>
> Despite the codebase size, new agents can still understand it and make meaningful progress. Hundreds of workers run concurrently, pushing to the same branch with minimal conflicts.
>
> While it might seem like a simple screenshot, building a browser from scratch is extremely difficult.
>
> Another experiment was doing an in-place migration of Solid to React in the Cursor codebase. It took over three weeks with +266K/-193K edits. It still needs careful review, but was passing our CI and early checks.
>
> *Pull request showing Solid to React migration*
> ![[cursor-scaling-agents-001.png]]
>
> Another experiment was to improve an upcoming product. A long-running agent made video rendering 25x faster with an efficient Rust version. It also added support to zoom and pan smoothly with natural spring transitions and motion blurs, following the cursor. This code was merged and will be in production soon.
>
> We have a few other interesting examples still running:
>
> - [Java LSP](https://github.com/wilson-anysphere/indonesia): 7.4K commits, 550K LoC
> - [Windows 7 emulator](https://github.com/wilsonzlin/aero): 14.6K commits, 1.2M LoC
> - [Excel](https://github.com/wilson-anysphere/formula): 12K commits, 1.6M LoC
>
> ## What we've learned
>
> We've deployed trillions of tokens across these agents toward a single goal. The system isn't perfectly efficient, but it's far more effective than we expected.
>
> Model choice matters for extremely long-running tasks. We found that GPT-5.2 models are much better at extended autonomous work: following instructions, keeping focus, avoiding drift, and implementing things precisely and completely.
>
> Opus 4.5 tends to stop earlier and take shortcuts when convenient, yielding back control quickly. We also found that different models excel at different roles. GPT-5.2 is a better planner than GPT-5.1-Codex, even though the latter is trained specifically for coding. We now use the model best suited for each role rather than one universal model.
>
> Many of our improvements came from removing complexity rather than adding it. We initially built an integrator role for quality control and conflict resolution, but found it created more bottlenecks than it solved. Workers were already capable of handling conflicts themselves.
>
> The best system is often simpler than you'd expect. We initially tried to model systems from distributed computing and organizational design. However, not all of them work for agents.
>
> The right amount of structure is somewhere in the middle. Too little structure and agents conflict, duplicate work, and drift. Too much structure creates fragility.
>
> A surprising amount of the system's behavior comes down to how we prompt the agents. Getting them to coordinate well, avoid pathological behaviors, and maintain focus over long periods required extensive experimentation. The harness and models matter, but the prompts matter more.
>
> ## What's next
>
> Multi-agent coordination remains a hard problem. Our current system works, but we're nowhere near optimal. Planners should wake up when their tasks complete to plan the next step. Agents occasionally run for far too long. We still need periodic fresh starts to combat drift and tunnel vision.
>
> But the core question, can we scale autonomous coding by throwing more agents at a problem, has a more optimistic answer than we expected. Hundreds of agents can work together on a single codebase for weeks, making real progress on ambitious projects.
>
> The techniques we're developing here will eventually inform Cursor's agent capabilities. If you're interested in working on the hardest problems in AI-assisted software development, we'd love to hear from you at [hiring@cursor.com](mailto:hiring@cursor.com).

[Source](https://cursor.com/blog/scaling-agents)
