---
created: 2026-03-16
description: Akira walks through Slate's terminal UX for managing parallel agent swarms — model selection for three distinct roles, live thread status, per-subagent cost tracking, inline diffs, and failure escalation to the orchestrator.
source: https://x.com/realmcore_/status/2033020007257649473
type: learning
---

## Key Takeaways

Slate's UX contribution is making multi-model parallelism legible in a terminal. The three-role model split — orchestration (Sonnet/Opus), search (GLM 5 for speed), and execution (the code-writing model) — is a practical decomposition that maps to how [[Slate's thread-based episodic memory solves long-horizon agent tasks|Slate's thread architecture]] actually works. Each role has different cost/intelligence tradeoffs, and surfacing the model choice per-role makes those tradeoffs explicit rather than hidden.

The observability layer is where this matters most. Each subagent shows token spend and dollar cost inline, thread completion status sits above the input bar, and diffs from subagent edits appear inline in chat. This is the kind of UX that [[slate is the first swarm native coding agent that orchestrates parallel subagent threads through a typescript DSL|the initial Slate announcement]] promised but hadn't shown concretely. As @twentyvisionai noted in the replies: "the hardest part isn't routing to the right model — it's making the operator feel in control without drowning in context."

The failure handling pattern is interesting: subagents that hit failures abort and escalate back to the orchestrator rather than retrying blindly. This matches the [[agents need a harness not a framework because durable event-driven infrastructure already solves retry routing and state|harness-over-framework]] principle — the orchestrator decides how to recover, not the worker.

The `/models` command for hot-swapping models mid-session, combined with $10 free credits on signup (so subthreads work without pre-configured API keys), lowers the barrier to actually experiencing multi-model orchestration rather than just reading about it.

## External Resources

- [Slate CLI](https://www.npmjs.com/package/@randomlabs/slate) — `npm i -g @randomlabs/slate`
- [Slate technical report](https://randomlabs.ai/blog/slate) — deeper architecture details on thread-based episodic memory
- [Excalidraw](https://github.com/excalidraw/excalidraw) — the repo used in the demo walkthrough

## Original Content

> @realmcore_ (akira) — 2026-03-15 (thread)
>
> I don't think there's a single terminal ux that handles agent swarms well
>
> With slate, you can literally use Opus 4.6 and GPT 5.4 at the exact same time
>
> But making it intuitive took a ton of work
>
> So heres a thread on how it works and how to actually use it
>
> ---
>
> Slate automatically knows how and when to parallelize work. Slate defaults to parallelizing exploration work while keeping execution work in the same context.
>
> To download, first run: npm i -g @randomlabs/slate
>
> To start, you'll want to select your models for the 3 main ways models are used in slate:
>
> 1 ) Orchestration - this is the agent backbone, the best models for this are Sonnet and Opus 4.6 (only when you really need it)
>
> 2) Search - this is the model that runs in a thread when you have codebase search tasks. Slate's parallelism allows it to run many many agentic search tasks in parallel. @Zai_org 's GLM 5 is the recommended model for agentic search for its speed and intelligence
>
> 3) Execution - this is the model that slate runs in threads when there are implementation or execution tasks (think setting up a dev server, editing files, etc.). This is the model that will be writing the code
>
> ---
>
> After the onboarding, to change models, you can also run the /models command
>
> The /models command will bring up a dialog allowing you to switch the models that you are using.
>
> ---
>
> Once you've selected your models
>
> The next step is to fire off a task.
>
> Slate usually begins by parallelizing an exploration, but a great way to see it in action is by asking it to deeply explore your codebase.
>
> In our example, we're going to parallelize some work in the @excalidraw repo
>
> ---
>
> After slate starts spawning threads to work on tasks, you can see how many of these subagents have completed their work by looking at the status indicator above the input bar
>
> For each subagent as they run you'll also see the total token spend and dollar spend in each subagent
>
> ---
>
> Once you start seeing edits from threads, the permissions system kicks in.
>
> You'll be able to select the permission you want to apply, and then continue.
>
> Edits applied by a subagent appear on that subagent's card, and the diffs will appear inline in the chat
>
> ---
>
> Slate can also run *multiple* implementation tasks in parallel.
>
> You'll see the exact same interactions as you would for a single subagent, but applied to each task in the list.
>
> ---
>
> If a subagent runs into a failure, subagents are designed abort the task so that they can get feedback from the main orchestrator model.
>
> ---
>
> Once the task is completed, you'll see slate's response, and a summary of all the files modified throughout the duration of the task!
>
> ---
>
> Thats it for this walkthrough. Happy slating!
>
> ---
>
> **Notable replies by @realmcore_:**
>
> Re: benchmarking memory degradation — "I think one way to do it would be to test how long it can run/how many tokens the session consumes before you can feel it degrade"
>
> Re: free credits — "You got $10 of free credits on sign up. We're working on making subthreads compatible with the ones you have configured"
>
> Re: UX challenge — "Yep def undersolved, but I think this UI moves *towards* it"
>
> Engagement: thread across 10 tweets
> [Original thread](https://x.com/realmcore_/status/2033020007257649473)
