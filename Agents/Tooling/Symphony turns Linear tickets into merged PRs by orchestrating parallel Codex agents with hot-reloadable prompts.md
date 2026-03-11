---
created: 2026-03-11
description: OpenAI Symphony is an open-source orchestrator that dispatches Codex agents to claim Linear tickets, plan in comments, implement, validate end-to-end, and open PRs — with hot-reloadable WORKFLOW.md prompts as the real control surface.
source: https://x.com/odysseus0z/status/2031850264240800131
type: synthesis
---

## Key Takeaways

Symphony flips the orchestration model: instead of building a custom agent loop, you **use Linear as the control surface** and let the orchestrator handle dispatch. Push tickets to Todo, agents claim them within seconds. Move to Rework with comments, agents address feedback. Cancel to stop. This is the same "ticket board as agent interface" pattern emerging in [[elite engineering orgs are building internal coding agents that spread beyond engineering through Slack visibility|internal coding agent builds at Stripe and Ramp]], but packaged as an open-source tool anyone can run.

The real insight is that **the prompt (WORKFLOW.md) does the heavy lifting, not the orchestrator**. Symphony itself is plumbing — polling Linear, managing worker slots, cloning repos. The prompt teaches agents how to plan, test, handle review, and constrain scope. This maps directly to [[agent-first engineering replaces coding with environment design scaffolding and feedback loops]] — the engineering work is in designing the environment and prompt, not writing application code.

The **planning-before-coding pattern** is notable: each agent posts its plan as a Linear comment before implementing. This creates a human review checkpoint that catches bad approaches before they become bad PRs — similar to how [[skill workflows]] emphasize planning phases.

End-to-end validation is surprisingly autonomous. One agent testing a ChatDisplay refactor attached to the running Electron app over CDP, injected a probe to force a render error, verified containment, clicked through recovery, screenshotted both states, and cleaned up — entirely self-directed, with no testing instructions in the ticket.

The scale result speaks for itself: 50 tickets pushed before bed → 30 merged PRs by morning → 7,000 net lines deleted → nothing broken two days later.

## External Resources

- [OpenAI Symphony](https://github.com/openai/symphony) — the orchestrator repo
- [George's fork](https://github.com/odysseus0/symphony) — easier getting-started fork, installable as a skill via `npx skills add`
- [Linear MCP setup](https://linear.app/docs/mcp) — official docs for giving agents Linear access

## Original Content

> [!quote]- Source: @odysseus0z — Mar 11, 2026 · 33 likes · 2 retweets
>
> **Article: Getting Started with OpenAI Symphony**
>
> I pushed 50 tickets to Linear before bed — a tech debt rewrite of an Electron app. Woke up to 30 merged PRs. 7,000 net lines deleted. Two days later, nothing has broken.
>
> This is [Symphony](https://github.com/openai/symphony) — OpenAI's open-source orchestrator for Codex agents. Point it at a Linear board and it turns tickets into pull requests.
>
> I didn't even know how to properly test an Electron app. The agents figured it out — attaching to the running app over CDP via agent-browser, validating changes end-to-end, entirely self-directed. I'm learning how to test my own app by reading their logs.
>
> ![[odysseus0z-800131-001.jpg]]
>
> ## Set it up
>
> I maintain a [fork](https://github.com/odysseus0/symphony) that's easier to get started with. From your project repo, run:
>
> ```bash
> npx skills add odysseus0/symphony -s symphony-setup -y
> ```
>
> Then tell your agent: "set up Symphony for my repo."
>
> For manual setup, follow the [skill instruction](https://github.com/odysseus0/symphony/blob/main/.agents/skills/symphony-setup/SKILL.md) manually.
>
> ## The Linear board is your control surface
>
> Everything happens through Linear. The board is the interface.
>
> Push a ticket to Todo — an idle agent claims it within seconds. Move a ticket to Rework with review comments — the agent picks it back up and addresses feedback.
>
> ![[odysseus0z-800131-002.jpg]]
>
> ## Start with a big idea, not individual tickets
>
> If you already have a well-organized Linear board, point Symphony at it and go. If you don't, have your agent play tech lead — describe the feature and let it decompose the work into tickets with dependencies mapped out.
>
> Give your agent access to Linear ([official MCP setup](https://linear.app/docs/mcp)) and hand it the big picture:
>
> > Break this into tickets in project [slug]. Scope each ticket to one reviewable PR. Include acceptance criteria. Set blocking relationships where order matters.
>
> Push the batch to Todo and let Symphony parallelize across everything that isn't blocked.
>
> My 50-ticket Electron rewrite started as one conversation: "here's the tech debt, here's what I want the codebase to look like after." The agent decomposed it, I reviewed the tickets, adjusted a few, and pushed them to Todo.
>
> ## What to expect
>
> Each worker gets its own workspace clone, reads the ticket, writes a plan as a Linear comment, implements, validates, and opens a PR.
>
> The planning step is worth watching. Before writing code, the agent posts its plan as a Linear comment. Catch bad plans before they become bad PRs. It will check off todos it is done during the run, and give you a demo video at the end!
>
> ![[odysseus0z-800131-003.png]]
>
> One of my tickets asked for a ChatDisplay refactor — no mention of testing. The agent attached to the running Electron app over CDP via agent-browser, injected a temporary probe to force a render error, verified the failure was contained, clicked through recovery, screenshotted both states, and removed the probe. End-to-end validation of a UI change, entirely self-directed.
>
> ## Tune on the fly
>
> Cancel a ticket — the agent stops on the next poll. Move something back to Backlog to hold it. Push a batch to Todo to dispatch.
>
> WORKFLOW.md hot-reloads within a second — no restart needed. Common adjustments:
>
> - agent.max_concurrent_agents — start at 2-3, scale up as you trust it
> - agent.max_turns — turn limit per ticket. Higher for complex work, lower to cap token spend.
>
> ## What's actually doing the work
>
> Most of what makes this effective isn't the orchestrator — it's the prompt in WORKFLOW.md. Symphony is plumbing: poll Linear, dispatch workers, manage slots. The prompt teaches the agent how to plan, test, handle review feedback, and constrain scope.
>
> ![[odysseus0z-800131-004.jpg]]
>
> I'll dig into that prompt in a follow-up.

[Original post](https://x.com/odysseus0z/status/2031850264240800131)
