---
created: 2026-02-05
description: Multi-agent swarms work best with a small lead-to-worker ratio, role-based staffing by model/CLI, and explicit specs plus review layers to prevent lazy or stubbed work.
source: https://x.com/khaliqgant/status/2019124627860050109
type: framework
---

# 2 to 5 worker agents per lead is the sweet spot for multi agent orchestration

## Key takeaways

- **Lead capacity is the bottleneck.** A Lead managing ~10 chatty agents becomes a single point of failure; the thread’s observed “sweet spot” is **2–5 workers per Lead**.

- **Match the tool/model to the role.** Communication-heavy roles (Lead, Reviewer) benefit from agents that can be interrupted and report status; heads-down implementation benefits from agents that focus deeply. This fits our broader “separate sessions by responsibility” framing in [[multi-agent squads work when independent sessions share a mission control system]].

- **Planning is everything (agents cut corners on vague specs).** If the spec is fuzzy, agents will silently stub endpoints, leave TODOs, or claim completion early. Treat spec-writing as first-class work, not overhead.

- **Add review layers to catch lazy work.** Shadow agents + dedicated reviewers are explicitly called out as the antidote to “looks done but isn’t.” This aligns with “loop-based iteration” ideas in [[ralph loops prevents context pollution in long running ai builds]]: structured passes beat long freeform threads.

- **Persist trajectories so future agents can resume with context.** Storing "trajectories" (chaptered decisions/events + retrospectives) is framed as an unexpected unlock for continuity and debugging across sessions. This trajectory persistence is the operational equivalent of what [[Obsidian as Agentic Memory]] calls "the vault as knowledge graph" — durable file-backed context that survives session boundaries.

## Notable references (from the thread)

- Agent Relay (open-source comms layer): https://github.com/AgentWorkforce/relay
- Trajectories CLI repo: https://github.com/AgentWorkforce/trajectories/
- Blog cross-post: https://agent-relay.com/blog/let-them-cook-multi-agent-orchestration

## Source material

> [!quote]- Thread: Khaliq Gant — “Let Them Cook: Lessons from 6 Weeks of Multi-Agent Orchestration”
> 
> (Original: https://x.com/khaliqgant/status/2019124627860050109)
> 
> THREAD_START
> 
> @Khaliqgant (Khaliq Gant):
> Article: Let Them Cook: Lessons from 6 Weeks of Multi-Agent Orchestration
> 
> I've been building [Agent Relay](https://github.com/AgentWorkforce/relay) (@agent_relay) using Agent Relay. Agents coordinating to build the tool that lets them coordinate. It's recursive and I love it. I took some time to jot down some thoughts about multi agent orchestration from the past few weeks where I've spoken to agents more than I've spoken to my wife  😳.
> 
> For the past six weeks, I've been deep in this world. Agent Relay is an [open-source communication](https://github.com/AgentWorkforce/relay) layer allowing any CLI tool (Claude, Cursor, OpenCode, Gemini) to communicate efficiently and seamlessly. And it's rumored that Claude Code is coming out with first-party support for agent swarms.
> 
> [Embedded Tweet: https://x.com/i/status/2014698883507462387]
> 
> Am I worried about this? If I'm being completely honest, yes, a little bit. But my main feeling is that it's great to push multi-agent orchestration into the forefront of developer minds so the true power can be experienced and more best practices form around it.
> 
> ## Key Takeaways
> 
> - 2-5 worker agents per Lead is the sweet spot
> 
> - Claude for coordination, Codex for deep work (match the CLI to the role)
> 
> - Planning is everything (agents cut corners on vague specs)
> 
> - Shadow agents and reviewers catch lazy work
> 
> - Store trajectories so future agents have context
> 
> ## Part 1: The Promise
> 
> Multi-agent orchestration is a step change in how tasks get done. It puts agents front and center while the human takes a step back and just lets them cook. That doesn't mean the human will be completely removed. There are still bumps in the road to truly autonomous agent work, and the planning phase becomes one of the most crucial steps.
> 
> What Multi-Agent Orchestration Unlocks
> 
> Having agents who can communicate with each other and coordinate on tasks is a huge unlock. Assigning [agent profiles](https://github.com/AgentWorkforce/relay/tree/main/.claude/agents) similar to how human teams would organize has been a paradigm I have found success with. For instance:
> 
> - Lead – coordinates the team and breaks down tasks
> 
> - Backend – implements server-side logic
> 
> - BackendReviewer – reviews backend code for quality
> 
> - FrontendReviewer – reviews frontend code for quality
> 
> - TypeChecker – ensures type safety across the codebase
> 
> - TestWriter – writes and maintains tests
> 
> - DocumentationExpert – handles docs and comments
> 
> Each agent assumes its role, can read the logs of other agents, and can message others to check their work, sanity-check their decisions, and hand off tasks in a coordinated manner.
> 
> The Speed Improvement
> 
> The other method that has worked well for me is creating a detailed spec upfront and then spawning a Lead agent. I give it the spec and tell it to assemble a team as it sees fit. The Lead then spawns agents accordingly. Because Agent Relay is CLI-agnostic, I make sure to mix Codex, Claude, OpenCode, Gemini, and Droid agents, assigning different models based on the role. A fast model like Haiku or Conductor for Lead roles, and for deeper technical tasks, Opus or GPT-5 Codex high.
> 
> Using this workflow, I've seen that not only does code quality increase, but the speed at which agents can pump out complex features is at least a 4-5X improvement.
> 
> I have been using Agent Relay to build itself on the cloud environment at agent-relay.com and the pace of delivery using agent orchestration has been mind-blowing.
> 
> It hasn't been all good though...
> 
> ## Part 2: The Problems
> 
> Agents Are Sometimes Lazy
> 
> I've had instances where an agent swarm takes on a complicated feature and then the Lead excitedly declares everything done. On one build, the Lead proudly reported "All 12 endpoints implemented!" When I tested it, only 8 actually returned data. The rest were stubbed out with TODOs. This happened occasionally with single-agent sessions, but imagine it compounding across 5, 6, or 10 agents...
> 
> Agents Get Overwhelmed and Die
> 
> Having a Lead agent creates a single point of failure. If the swarm is large and chatty, the Lead receives a flood of messages from other agents plus queries from the human asking about status or redirecting work. This can overwhelm the Lead, causing it to enter an endless loop and eventually die or become completely unresponsive.
> 
> ## Part 3: The Playbook
> 
> Here's what I've learned about making multi-agent orchestration actually work.
> 
> Team Structure
> 
> Team structure is critical. There's a magic ratio of Lead-to-worker agents that I haven't exactly figured out yet (it varies depending on roles) but I've had success with 2-5 worker agents per Lead. A single Lead managing 10 agents usually becomes problematic.
> 
> Communication Patterns by CLI
> 
> Not all CLI agents communicate the same way, and taking this into account is beneficial when working with swarms.
> 
> Codex is great at heads-down work but doesn't communicate well. Once it's working, it's hard to interrupt. I've had Leads waiting 7+minutes (a lifetime in agentic development!) for a response, assuming the agent died, when Codex was just deep in implementation.
> 
> Claude communicates well and can be interrupted mid-task without issue. It naturally provides status updates and even sometimes asks clarifying questions.
> 
> Cursor (particularly Composer) is very fast and communicates well, making it good for rapid iteration.
> 
> My staffing rule of thumb: Put Claude agents in Lead and Reviewer roles where communication is key. Put Codex agents on isolated implementation tasks where heads-down focus is more valuable than status updates. Use Cursor when you need speed and tight feedback loops.
> 
> Agent Relay allows users to define a teams.json ([docs](https://docs.agent-relay.com/reference/configuration)) that auto-spawns agents on start, so these staffing decisions can be codified and stay consistent across sessions:
> 
> ```json
> {
>   "team": "my-team",
>   "autoSpawn": true,
>   "agents": [
>     {
>       "name": "Coordinator",
>       "cli": "claude",
>       "role": "coordinator",
>       "task": "Coordinate the team..."
>     },
>     {
>       "name": "Developer",
>       "cli": "codex",
>       "task": "Implement features..."
>     }
>   ]
> }
> ```
> 
> Catching Lazy Work
> 
> Agent Relay has a notion of a [shadow agent](https://docs.agent-relay.com/features/shadows#shadow-agents) that helps quite a bit with this problem. Reviewer agents also typically catch this type of shoddy work.
> 
> Additionally, layering in one of the many AI code review tools has been effective at catching minor issues.
> 
> Continuity and Hooks
> 
> Agent Relay also has a "continuity" concept ([docs](https://docs.agent-relay.com/guides/session-continuity)), largely borrowed from the [Continuous Claude package](https://github.com/parcadei/Continuous-Claude-v3) by @parcadei. This enables ephemeral agents that save their context periodically, get released, then spawn again and continue seamlessly by reading their saved state.
> 
> If you want more granular control or access to agent lifecycle events, Agent Relay has an extensive [hooks system](https://docs.agent-relay.com/features/hooks#lifecycle-hooks) that gives you access to 7 different events:
> 
> Trajectories: Preserving Context
> 
> One other thing that has been a huge and unexpected unlock is to have agents store trajectories, which can be defined as a train of thought of an agent stored in logical chapters for a completed task. It was inspired by this thread from @GergelyOrosz
> 
> [Embedded Tweet: https://x.com/i/status/2002160432841097239]
> 
> An example would look like this
> 
> ```json
> {
>   "id": "traj_itn5hyej5mi6",
>   "task": {
>     "title": "Fix module resolution issues - 17 test failures"
>   },
>   "status": "completed",
>   "chapters": [
>     {
>       "title": "Work",
>       "events": [
>         {
>           "type": "decision",
>           "content": "Thread shadowMode through protocol layers",
>           "raw": {
>             "reasoning": "Devin review found fields were silently dropped..."
>           },
>           "significance": "high"
>         }
>       ]
>     }
>   ],
>   "retrospective": {
>     "summary": "Fixed issue by threading shadow options through all layers",
>     "confidence": 0.9
>   }
> }
> ```
> 
> The [AgentWorkforce/trajectories repo](https://github.com/AgentWorkforce/trajectories/) provides a CLI tool that agents can easily understand. It also It becomes invaluable when an agent in a new session needs to revisit a previously-worked feature or investigate a bug. By finding the relevant trajectory, the agent gains instant context and insight, making it much better informed on how to proceed. These trajectories are also useful to humans reviewing the codebase.
> 
> The Human's New Role
> 
> Coordinating with multiple agents and seeing output fly in at rapid speed is quite exhilarating. Being able to remove myself as the bottleneck and just let the agents do their thing is a huge benefit. This necessitates that the planning phase is carefully and meticulously done to ensure agents have well-defined tasks with edge cases thought out.
> 
> It also means the review phase is paramount. Having agents self-review and cross-review is an effective strategy.
> 
> ## Try It Yourself
> 
> Want to experiment with multi-agent orchestration? You can get started with Agent Relay Cloud at https://agent-relay.com or [set it up locally](https://docs.agent-relay.com/quickstart) in seconds.
> 
> Just tell your CLI agent to run:
> 
> ```bash
> curl -s https://raw.githubusercontent.com/AgentWorkforce/relay/main/docs/guide/agent-setup.md
> 
> ```
> 
> The agent will read the setup guide and configure everything, then let it cook.
> 
> Check out the docs at https://docs.agent-relay.com for more details, or hit me on X with any thoughts or questions. I'm all for a discussion: @khaliqgant
> 
> This has been cross posted on our blog: https://agent-relay.com/blog/let-them-cook-multi-agent-orchestration
> 
> ## References
> 
> • Cursor: Scaling Agents (https://cursor.com/blog/scaling-agents) – An interesting perspective on how Cursor is thinking about agent scaling and the challenges involved
> 
> • @pbteja1998 on multi-agent swarms with OpenClaw (https://x.com/pbteja1998/status/2017662163540971756) – Exciting developments in how people are experimenting with multi-agent orchestration
> date: Wed Feb 04 19:03:19 +0000 2026
> url: https://x.com/Khaliqgant/status/2019124627860050109
> likes: 181  retweets: 6  replies: 7
> THREAD_END
