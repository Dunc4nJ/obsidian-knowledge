---
created: 2026-03-16
description: Letta Code demonstrates that a memory-rich orchestrator agent dispatching stateless Claude Code or Codex subagents gets both deep context and clean focus per task.
source: https://x.com/sarahwooders/status/2033592972168806827
type: learning
---

## Key Takeaways

The core insight is that persistent memory and clean context windows are competing goods — you want both but can't have them in one agent session. Letta Code's solution is architectural: the memory-rich agent acts as an [[orchestration architecture determines multi-agent investment quality|orchestrator]] that dispatches isolated subagents, transferring only relevant context from its accumulated memory. This is the "brilliant new-hire" metaphor — you brief them precisely, they execute without baggage.

The skill includes opinionated model routing: Codex 5.3 for hard debugging, 5.4 for fast general work, Claude Opus for docs and refactors. This maps to what we've seen with [[codex-custom-multi-agent-roles-unlock-repeatable-subagent-specialization|Codex custom roles]] — the orchestrator picks the right tool for the job rather than using one model for everything.

A particularly practical pattern is dispatching a subagent to critique a plan written by the orchestrator. Because the reviewer starts with a clean slate, it avoids anchoring on the assumptions that shaped the plan. This is [[context-engineering-strategies|context isolation]] used deliberately for cognitive diversity, not just token management.

The Letta Code agent also shields the user from difficult-to-interact-with models (specifically Codex 5.3), translating unreadable trajectories into clear summaries. This is harness engineering at its most literal — the harness absorbs complexity so the human doesn't have to. Similar to how [[CLAUDE.md is the highest-leverage harness config but hits a 150-200 instruction ceiling before compliance decays linearly|CLAUDE.md configurations]] shape agent behavior, the dispatching skill shapes the entire multi-agent workflow.

Back-and-forth conversation with subagents (resuming sessions with answers to subagent questions) makes this more than fire-and-forget delegation — it's supervised execution with the orchestrator maintaining coherence across the interaction.

## External Resources

- [Letta Code](https://github.com/letta-ai/letta-code) — memory-first coding agent, open source
- [Dispatching skill source](https://github.com/letta-ai/letta-code/blob/main/src/skills/builtin/dispatching-coding-agents/SKILL.md) — the full skill for invoking Claude Code and Codex as subagents
- [Letta Code skills docs](https://docs.letta.com/letta-code/skills/) — documentation on the skill system

## Original Content

> @sarahwooders (Sarah Wooders) — 2026-03-16
>
> Article: Orchestrating Claude Code & Codex agents with Letta Code
>
> Although I use [Letta Code](https://github.com/letta-ai/letta-code) (a memory-first coding agent) as my daily driver, there are still some cases where a stateless agent like Codex or Claude Code might do better. Agents with memory are generally more capable (they know your codebase, your preferences, your past decisions), but it can be advantageous to explicitly clear out *all* context except what's relevant to the problem at hand. A clean context window generally means more focus and less noise, but also means dealing with potential agent amnesia.
>
> *Letta Code skill for dispatching subagents*
> ![[sarahwooders-806827-001.jpg]]
>
> ## The best of both worlds: using Claude Code & Codex as subagents
>
> To get the best of both worlds, I recently added a new built-in [skill](https://docs.letta.com/letta-code/skills/) to Letta Code for invoking Claude Code or Codex as subagents. The skill explains to the Letta Code agents that these subagents lack memory, so will require relevant context to be provided:
>
> > Claude Code and Codex are highly optimized coding agents, but are re-born with each new session. Think of them like a brilliant new-hire starting today. Provide them with the right instructions and context to help them succeed and avoid having to re-learn what you've learned.
>
> This is a great balance. When Letta Code invokes Codex, it can point Codex to the specific files that it knows are important, or provide other context (e.g. important coding preferences) when crafting the prompt. Codex still benefits from Letta Code's relevant memories, but gets a much more isolated context window to focus on the specific task at hand.
>
> *Model routing recommendations in the dispatching skill*
> ![[sarahwooders-806827-002.jpg]]
>
> ## Choosing the right subagent
>
> The skill also instructs Letta Code on which subagent and model to use depending on the task. I added my own recommendations into the skill, but the agent can also make its own assessment over time:
>
> ```markdown
>   Codex CLI (`gpt-5.3-codex`) — Hardest debugging, complex reasoning
>   - Strengths: Frontier reasoning, excellent at debugging, best option for the hardest tasks
>   - Weaknesses: Slow with long trajectories, compactions can destroy trajectories
>
>   Codex CLI (`gpt-5.4`) — Fast general-purpose tasks
>   - Strengths: Easier for humans to understand, general-purpose, faster
>   - Weaknesses: More likely to make silly errors than gpt-5.3-codex
>
>   Claude Code CLI (`opus`) — Docs, refactors, open-ended, vague instructions
>   - Strengths: Excellent writer, understands ambiguity, general-purpose
>   - Weaknesses: Tends to generate "slop", excessive code unnecessarily
> ```
>
> ## Not having to talk to Codex 5.3 😌
>
> Codex 5.3 is incredibly good at debugging hard problems, but is especially unpleasant to interact with. I can never tell if it's derailing or not, and it often misinterprets what I say to it. My Letta Code agent effectively shields me from interacting with Codex. It gives Codex a great prompt, then explains back to me what happened in the otherwise un-readable trajectory.
>
> *Subagent conversation flow*
> ![[sarahwooders-806827-003.jpg]]
>
> ## Getting a second opinion
>
> One of my favorite patterns is asking Codex or Claude Code to give feedback on plans. My agent can write a plan to a file, then dispatch a subagent to critique it to get a context-isolated second opinion:
>
> ```bash
> claude -p "Read /tmp/my-plan.md and critique it. What am I missing? What could go wrong?" \
>   --model opus --dangerously-skip-permissions -C /path/to/repo
> ```
>
> Because the reviewer starts with a clean slate, it's less likely to be anchored by the same assumptions that shaped the original plan.
>
> ## Multi-agent conversation
>
> Letta Code can have back-and-forth conversations with the subagents. Letta Code sees the output of Codex, so if Codex has a question, Letta Code can resume the same session with an answer for Codex to continue.
>
> ## Agents as agent orchestrators
>
> As agents become more long-running and autonomous, it's getting hard to keep track of them. I like the pattern of having my Letta Code agent, which focuses on building up memory and context about me and my work, being in charge of dispatching tasks and context to isolated, stateless subagents.
>
> ## Try it yourself
>
> You can try out the skill in the latest version of Letta Code:
>
> ```bash
> npm i -g @letta-ai/letta-code
> ```
>
> The full skill is open source:
>
> [letta-ai/letta-code/src/skills/builtin/dispatching-coding-agents/SKILL.md](https://github.com/letta-ai/letta-code/blob/main/src/skills/builtin/dispatching-coding-agents/SKILL.md)
>
> Engagement: 76 likes | 7 retweets | 4 replies
> [Original post](https://x.com/sarahwooders/status/2033592972168806827)
