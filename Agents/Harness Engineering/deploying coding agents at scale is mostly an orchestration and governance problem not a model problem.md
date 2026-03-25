---
created: 2026-06-24
description: Zach Lloyd (Warp) breaks down the build-vs-buy decision for cloud coding agent orchestration, identifying 12 infrastructure primitives and arguing the MVP is easy but production-grade orchestration is where the real work lives.
source: https://x.com/zachlloydtweets/status/2036509756404158559
---

# Deploying coding agents at scale is mostly an orchestration and governance problem not a model problem

## Key Takeaways

Zach Lloyd frames cloud agent deployment as an infrastructure engineering challenge with a dozen primitives — control plane, orchestration, harnesses, context architecture, eval/observability, and governance. This maps cleanly onto [[the harness is the product because model capability is commoditizing while accumulated context is not]] — the model is a commodity; the surrounding system is the product.

The taxonomy of features (policies, tracking, handoff, collaboration, triggers, artifacts, metrics, sandboxing, hosting) reads like a checklist for [[agent harness components can be derived from first principles by working backwards from desired agent behavior]]. Most of these are solved problems in traditional infrastructure (event-driven orchestration, RBAC, audit logging) — the novelty is wiring them around an LLM loop.

His observation that MVPs are easy but production-grade orchestration is where the bulk of the work lives echoes [[harness engineering improved a coding agent 13 points by changing only system prompts tools and middleware]] — incremental harness refinement compounds, while raw model swaps yield diminishing returns.

The "context architecture" primitive — persistent memory, context graphs, tribal knowledge, feedback loops — is where compounding advantage lives. This connects to [[structured compaction and CLAUDE.md hierarchy prevent context drift in million-token agent sessions]] and the broader insight that [[the harness layer is the next hundred billion dollar AI infrastructure market not the model]].

Lloyd's advice for most companies: start with an MVP, but don't commit to building the full stack unless you have Stripe-level resources. Buy the orchestration layer, own the context and domain-specific integration. This is the same pattern [[Open SWE distills enterprise coding agent patterns into a composable open-source framework]] enables — composable primitives you can adopt incrementally.

## External Resources

- [Oz by Warp](https://www.warp.dev/) — Warp's cloud orchestration platform for coding agents
- [Stripe Minions blog post](https://stripe.dev/blog/minions-stripes-one-shot-end-to-end-coding-agents) — referenced as an example of a company with enough complexity and resources to justify building the full stack in-house

## Original Content

> **@zachlloydtweets** (Zach Lloyd) · Mar 24, 2026 · 141 likes · 15 retweets · 5 replies

> [!quote]- Source Material
>
> Article: Build vs buy: how to deploy coding agents at scale
>
> The consensus amongst engineering leaders I talk to is that they want to deploy cloud coding agents to automate development this year. Their goal is for agents to be first-line contributors across the entire SDLC: from planning and prototyping to coding and testing to deploying and monitoring.
>
> The big question I keep hearing is how. Should they build an in-house orchestration system, or buy one off the shelf from Warp, Cursor, OpenAI, or someone else? Or perhaps some hybrid?
>
> It depends on a bunch of factors, and there is no one size fits all solution. It depends on how complex a company's internal stack is, how much appetite there is for building and maintaining an agent stack, how many harnesses to support, needs around handoff, tracking, sandboxing, etc.
>
> Let me dive in on how I would make this decision and how we are thinking about it as we build Oz, Warp's cloud orchestration platform.
>
> The way I conceive of the problem (and how Oz is architected) is to help companies deploy intelligence infrastructure that allows for agents to scale in the cloud. Your agent infrastructure should support a bunch of primitives like auditing, governance, sandboxing, etc.
>
> *Agent infrastructure primitives diagram*
> ![[zachlloydtweets-158559-001.jpg]]
>
> Expanding on these primitives, you probably want:
>
> 1. Control plane: an abstraction layer that governs which models/harnesses are used and why
>
> 2. Orchestration: workflow coordination across models, agents, tools, and systems
>
> 3. Harnesses: what drives the model (e.g. Claude Code, Codex, Oz, etc.)
>
> 4. Context Architecture: persistent memory, context graphs, proprietary data integration, tribal knowledge and feedback loops - the institutional intelligence that compounds over time as agents access it
>
> 5. Evaluation and Observability: continuous benchmarking, performance monitoring, cost optimization, and quality assurance across vendors
>
> 6. Enterprise governance and compliance: policy enforcement, access controls, sandboxing, model risk management, compliance logging, auditability, traceability, guardrails and regulatory alignment
>
> All of these need to be packaged together into a great developer experience (DX). Your engineering team is going to be the primary user of your internal orchestration system, so they need a good admin user experience for configuration and management.
>
> *Feature requirements for agent infrastructure*
> ![[zachlloydtweets-158559-002.jpg]]
>
> In terms of features, you'll want your infrastructure to have:
>
> 1. Policies: who can use what model/harness on what repo and when
>
> 2. Tracking for agent runs: what triggered the agent, what did it do, etc.
>
> 3. Continuous improvement: how your agent system improves over time using memory
>
> 4. Handoff: how engineers take the wheel when an agent gets stuck
>
> 5. Collaboration: how  engineers work together and how they see what agents are doing, to coordinate and approve their work
>
> 6. Data access: what data stores can agents access, how is that access granted and tracked
>
> 7. Triggers: how are agents triggered, how they integrate with internal and external systems, and how it is programmable. You may also consider an "if this, then that" type system
>
> 8. Artifacts: what files, PRs, branches, plans etc. can agents produce
>
> 9. Metrics: how do you measure the success of agents and improve them over time
>
> 10. Sandboxing: how do you control what the agent can do and make sure they execute securely
>
> 11. Hosting: what compute does the agent run on
>
> 12. And so on…
>
> In terms of build vs. buy, there's obviously a big surface area of stuff to build here, but there's no need to build it all at once.
>
> For instance, it's easy to build a simple web app that lets developers prompt an agent to run on a cloud machine somewhere. The MVP I see folks often build is an app with a big prompt box and a harness picker that spins up a dev environment, passes a prompt to an agent SDK and then polls for the result. You can build something like this in a few days; a lot of companies are starting here.
>
> Tempting as it is, I would only go down this route if you are committed to building the real thing – because you'll find that as soon as you have the MVP, you'll start to want features like handoff, audit logs, evals, integrations into other apps, agent access to private data, self-improvement, etc., and that starts to become a pretty big effort.
>
> In other words, the MVP is pretty easy, but the remaining pieces to manage agents at scale is actually where the bulk of the work is. For companies with large engineering teams and very complex dev setups (say, [Stripe](https://stripe.dev/blog/minions-stripes-one-shot-end-to-end-coding-agents), for example), I think owning this entire stack makes sense. It's going to be a lot of work for them to integrate a third-party stack, and they have the resources to continuously improve their homegrown system.
>
> For most companies though, I might start with an MVP and get a feel for the limits. But I would also explore how you can use other primitives to build on (or maybe just try a soup-to-nuts solution). For instance, you probably don't want to build handoff and mobile access. I doubt you'll want to build evals. I would try to figure out the essential parts that make sense for you to own, which are typically related to the idiosyncrasies of your dev setup, and find ways to buy the rest.
>
> For Oz, what we are finding in our discussions with eng leaders is that while some companies want a plug-and-play orchestrator, others want to use parts of our solution, which is why we are building it as a programming stack, not just a product.
>
> For instance, folks want the ability to run an agent within their existing dev setups, and not have to define new Docker environments in order for an agent to do work. They can get this by running a "raw" agent SDK inside their existing container, but if they go that route they have to build all the orchestration primitives themselves. Oz supports a raw-style deployment that comes with tracking features built in, without having to use any of our other orchestration primitives.
>
> Other things we consistently hear are the need for self-hosting agents so that code doesn't flow to third-party systems and a desire to swap multiple harnesses for benchmarking and cost control. They want a memory layer that sits above the harnesses that can self-improve over time. Increasingly, they want not just developers but all knowledge workers to be able to build with a single agent platform.
>
> To summarize, the factors to consider are:
>
> - Resources to build and maintain an orchestrator – it's easy to do an MVP, but a lot of surface area for a production grade solution that will scale
>
> - Complexity of your company's development stack– the more complex it is, the less likely a prebuilt cloud agents solution will serve your needs (and if Oz doesn't fit those needs, we'd love to talk to you).You should think incrementally though and not approach build vs. buy as an all or nothing decision
>
> - How fast you want to get up and running – this one actually could go either way. You might be able to build an MVP very fast that is a good short term solution, or you might be able to deploy something like Oz more quickly.
>
> - Lock-in aversion: if you don't care about lock-in, you might go all in on a single-harness solution, which will simplify building…but you lose optionality down the road.
>
> If you're an engineering leader weighing these choices I'd love to connect, learn and help you navigate the landscape.

[Original post](https://x.com/zachlloydtweets/status/2036509756404158559)
