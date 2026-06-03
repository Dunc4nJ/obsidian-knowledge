---
created: 2026-06-03
description: Thariq Shihipar (Anthropic) explains how Claude Code's dynamic workflows let the model write and execute a custom JavaScript orchestration harness per task, structurally eliminating the three failure modes that break single-context agents at scale.
source: https://x.com/trq212/status/2061907337154367865
type: framework
---

## Key Takeaways

- Three structural failure modes explain why single-context agents collapse on complex tasks: **agentic laziness** (declaring done after partial progress), **self-preferential bias** (preferring its own findings when asked to verify them), and **goal drift** (losing edge-case constraints across compaction boundaries). Prompting cannot fix these — they require isolated context windows. Dynamic workflows address all three by spawning subagents with fresh, focused contexts. See [[Claude Code dynamic Workflows synthesize a per-task agent harness at runtime opening a third scaling axis]] for the technical primitives (`agent()`, `parallel()`, `pipeline()`) and how typed JSON schema output makes fleet results composable.

- Dynamic harnesses beat static templates because the synthesis happens with full task context. A static workflow for "should we migrate our checkout service?" runs 5 web searches and returns a generic report. A dynamic workflow reads the actual billing code, fans out agents to check each feature against the new provider's docs, prices at the actual transaction volume in parallel, then runs a devil's advocate agent against switching — task-specific knowledge that no pre-authored harness can encode. The distinction mirrors [[the harness layer is the next hundred billion dollar AI infrastructure market not the model|the harness-layer thesis]]: the harness is the product, and generating it per-task is the next inflection.

- The six canonical patterns cover most orchestration needs: **Classify-and-act** (route to different agents by type), **Fan-out-and-synthesize** (split, parallelize, then merge at a barrier), **Adversarial verification** (a skeptic agent per finding), **Generate-and-filter** (brainstorm + rubric dedupe), **Tournament** (pairwise judges across N attempts — pairwise comparison is more reliable than absolute scoring for 1000+ items), and **Loop-until-done** (keep spawning until stop condition, not a fixed count). Most real workflows compose two or three of these. See also [[separating cognitive blueprints from runtime engines enables portable auditable agent systems]] for the orchestration theory underneath.

- Quarantine is the security primitive for triage over untrusted content. Reader agents operate in a no-privilege zone (read-only tools) and pass only structured summaries to actor agents that hold high-privilege tools. This prevents prompt injection from user-submitted content (support tickets, bug reports, public feeds) from reaching agents that can open PRs or send messages — a structural trust boundary, not a content filter. Pair with `/loop` for continuous operation.

- Workflows ship inside skill folders: a `.workflow.js` file alongside `SKILL.md` makes custom harnesses distributable and reusable. Anyone who installs the skill runs the same workflow — the same primitive that makes CLAUDE.md rules and tool descriptions shareable. See [[agent skills should self-improve through observed failures not stay as static prompt files]] and [[repo-local skills and AGENTS.md turn recurring engineering work into repeatable agent workflows]] for the composability model that underlies this.

## External Resources

- [Dynamic Workflows docs](https://code.claude.com/docs/en/workflows) — official Claude Code reference for workflow primitives
- [Claude Blog post](https://claude.com/blog/a-harness-for-every-task-dynamic-workflows-in-claude-code) — same article mirrored on the Claude Blog
- [Bun rewrite from Zig to Rust via workflows](https://x.com/jarredsumner/status/2060050578026189172) — Jarred Sumner's thread on how Bun used workflows for the migration
- [Claude Code agent teams](https://code.claude.com/docs/en/agent-teams) — multi-agent team primitives
- [Claude Code code review](https://code.claude.com/docs/en/code-review) — built-in code review harness

## Original Content

> [!quote]- Source Material
> *Article cover: fan-out task diagram — "A harness for every task / Dynamic workflows in Claude Code"*
> ![[trq212-367865-001.jpg]]
>
> **@trq212 (Thariq) — Tue Jun 02 20:26:32 +0000 2026**
> Article: A harness for every task: dynamic workflows in Claude Code
>
> Last week, we released [dynamic workflows](https://code.claude.com/docs/en/workflows) in Claude Code. Claude can now write its own [harness](https://code.claude.com/docs/en/glossary#agentic-harness) on the fly, custom-built for the task at hand.
>
> While the default Claude Code harness is built for coding, it is also useful for many other types of tasks because, as it turns out, many tasks resemble coding tasks. But there are certain classes of tasks where we have had to build custom harnesses on top of Claude Code to achieve peak performance such as [Research](https://support.claude.com/en/articles/11088861-using-research-on-claude), [security analysis](https://support.claude.com/en/articles/11932705-automated-security-reviews-in-claude-code), [agent teams](https://code.claude.com/docs/en/agent-teams), or [Code Review](https://code.claude.com/docs/en/code-review).
>
> Workflows allow you to dynamically create harnesses that enable Claude to solve all of those problems and more natively inside of Claude Code. You can also share and re-use these workflows with others.
>
> In this article, I'll cover my initial workflows experiences and learnings so you can take full advantage.
>
> That said, best practices are still developing! Dynamic workflows often use more tokens, so think carefully about when and how to use them.
>
> Note: this post is also [available on the Claude Blog](https://claude.com/blog/a-harness-for-every-task-dynamic-workflows-in-claude-code)
>
> ## Example prompts
>
> Before diving into the technical details, I'd like to start with some example prompts to get you thinking about the possibilities with workflows:
>
> - "This test fails maybe 1 in 50 runs. Set up a workflow to reproduce it, form theories and adversarially test them in worktrees /goal don't stop until one theory works."
>
> - "Using a workflow, go through my last 50 sessions and mine them for corrections I keep making and turn the recurring ones into CLAUDE.md rules"
>
> - "Use a workflow to dig through #incidents in Slack for the past six months and find recurring root causes where nobody has filed a ticket."
>
> - "Take my business plan and run a workflow where different agents tear it apart from an investor's, a customer's, and a competitor's perspective."
>
> - "Here's a folder of 80 resumes, use a workflow to rank them for the backend role and double-check the top ten. Interview me using the AskUserQuestion tool for a rubric."
>
> - "I need a name for this CLI tool. Use a workflow to brainstorm a bunch of options and run a tournament to pick the top 3."
>
> - "Use a workflow to rename our User model to Account everywhere."
>
> - "Go through my blog post draft and using a workflow verify every technical claim against the codebase, I don't want to ship anything wrong."
>
> ## How dynamic workflows work
>
> Dynamic workflows execute a javascript file with a few special functions that help spawn and coordinate [subagents](https://code.claude.com/docs/en/sub-agents):
>
> *API reference: `agent(prompt, opts?): Promise<string | JsonSchema>` with `parallel()` (barrier — waits for all) and `pipeline()` (no barrier — each item streams through stages)*
> ![[trq212-367865-002.jpg]]
>
> Dynamic workflows also include standard JavaScript functions like JSON, Math, and Array, to help process data.
>
> It's particularly useful to know that dynamic workflows can decide which models an agent uses and whether subagents are run in their own worktree, allowing Claude to choose the intelligence level and isolation needed.
>
> If a workflow is interrupted, for example by user action or quitting the terminal, resuming the session will allow the workflow to pick up where it left off.
>
> ## Why dynamic workflows
>
> When you ask the default Claude Code harness to do a task, it needs to both plan and execute in the same context window. For many coding tasks, this is highly effective, but it can sometimes break down over long-running, massively parallel and/or highly structured adversarial tasks.
>
> This is because the longer Claude works on a complex task in a single context window, the more it becomes susceptible to a few specific failure modes:
>
> - Agentic laziness refers to when Claude stops before finishing a particularly complex, multi-part task and declares the job done after partial progress, for example addressing 20 of the 50 items in a security review.
>
> - Self-preferential bias refers to Claude's tendency to prefer its own results or findings, especially when asked to verify or judge them against a rubric.
>
> - Goal drift refers to the gradual loss of fidelity to the original objective across many turns, especially after compaction. Each summarization step is lossy, and details like edge-case requirements or "don't do X" constraints can get lost.
>
> Creating a workflow helps combat these by orchestrating separate Claudes with their own context windows and focused, isolated goals.
>
> ## Dynamic vs static workflows
>
> You may have previously created a static workflow using the Claude Agent SDK or claude -p to coordinate multiple instances of Claude Code together.
>
> But because static workflows need to work for all edge cases, they are usually more generic. With [Claude Opus 4.8](https://www.anthropic.com/news/claude-opus-4-8) and dynamic workflows, Claude is now intelligent enough to write a custom harness tailor-made for your use case.
>
> *Static harness: generic 4-step pipeline → generic report. Dynamic workflow: task-specific fan-out with devil's advocate → specific recommendation.*
> ![[trq212-367865-003.png]]
>
> # Helpful patterns when using dynamic workflows
>
> You can start using dynamic workflows just by asking Claude to make one, or by using the trigger word "ultracode" to ensure that Claude Code creates a workflow.
>
> But building a mental model for how dynamic workflows work will help you understand when to use them and how you might nudge Claude via prompts.
>
> There are a few common patterns that Claude might use and compose together when building workflows:
>
> *Six workflow patterns: Classify-And-Act, Fanout-And-Synthesize, Adversarial Verification, Generate-And-Filter, Tournament, Loop Until Done*
> ![[trq212-367865-004.jpg]]
>
> Classify-and-act
>
> Use a classifier agent to decide on the type of task, and then route to different agents or behavior based on the task. Or, use a classifier at the end to determine output.
>
> Fan-out-and-synthesize
>
> Split up a task into many smaller steps, run an agent on each step and then synthesize those results. This is particularly useful for when there are a large number of smaller steps, or when each step benefits from its own clean context window so they don't interfere or cross-contaminate. The synthesize step is a barrier—it waits for all the fan-out agents, then merges their structured outputs into one result.
>
> Adversarial verification
>
> For each spawned agent, run a separate spawned agent to adversarially verify its output against a rubric or criteria.
>
> Generate-and-filter
>
> Generate a number of ideas on a topic and then filter them by a rubric or by verification, dedupe duplicates and return only the highest quality, tested ideas.
>
> Tournament
>
> Instead of dividing the work, have agents compete on it. Spawn N agents that each attempt the same task using different approaches. Prompts or models then judge the results in a pairwise fashion using a judging agent until you have a winner.
>
> Loop until done
>
> For tasks with an unknown amount of work, loop spawning agents until a stop condition is met (no new findings, or no more errors in the logs) instead of a fixed number of passes.
>
> # Use cases
>
> Think creatively of when and how to ask Claude Code to make dynamic workflows. I've found that workflows are sometimes even more useful for non-technical work.
>
> *Where workflows shine: Migrations, Research, Verification, Sorting, Rules, Root cause, Triage, Taste, Evals, Routing*
> ![[trq212-367865-005.png]]
>
> ## Migrations and refactors
>
> [Bun](https://bun.com/) was rewritten from Zig to Rust using workflows. You can read more about how that was done in [Jarred's X thread](https://x.com/jarredsumner/status/2060050578026189172).
>
> The key is to break down the task into a series of steps that need to be operated on for example callsites, failing tests, modules, etc. Spin off a subagent for every fix in a worktree to make the fix, then have another agent adversarially review, and merge them. Consider telling the agent not to use resource intensive commands so that you can maximally parallelize without running out of resources on your machine.
>
> ## Deep research
>
> We published a deep research skill (/deep-research) inside Claude Code that uses dynamic workflows. Specifically, it fans-out web searches, fetches sources, adversarially verifies their claims, and synthesizes a cited report.
>
> But you may do this sort of research for more than just web searches. For example, asking Claude to compile a status report from context in Slack or to research how a feature works by exploring a codebase in-depth.
>
> ## Deep verification
>
> On the other hand, if you have a report where you want to check and source every factual claim that it references you may want to generate a workflow which has one agent identify all of the factual claims and then spin off a subagent to check each one in-detail. You could also have a verification agent check the source subagent to make sure its source is high quality.
>
> *Deep verification: Claim extractor → one Claim checker per claim → optional Source auditor → Verified report*
> ![[trq212-367865-006.jpg]]
>
> ## Sorting
>
> You may have a list of items that you want to sort by some qualitative measurement that you believe that Claude Code is good at evaluating, for example: support tickets sorted by severity of the bug. But if you try to sort 1000+ rows in one prompt, quality degrades and it won't fit in context. Instead run a tournament, a pipeline of pairwise-comparison agents (comparative judgment is more reliable than absolute scoring), or bucket-rank in parallel then merge. Each comparison is its own agent, so the deterministic loop holds the bracket and only the running order stays in context.
>
> *Tournament sorting: 1,000 items → pairwise bracket with fresh agent per match → Sorted list*
> ![[trq212-367865-007.jpg]]
>
> ## Memory and rule adherence
>
> If you have a particular set of rules that you find Claude misses or struggles with, even when put into the CLAUDE.mds, create a workflow with a list of rules that must be checked by verifier agents—one verifier per rule. Creating a skeptic persona subagent to review the rules to make sure they are in line will help avoid too many false positives.
>
> The reverse direction works too: mine your recent sessions and code review comments for corrections you keep making, cluster them with parallel agents, adversarially verify each candidate (would this rule have prevented a real mistake?), and then distill the survivors back into a [CLAUDE.md](http://claude.md/).
>
> *Memory/rule adherence: diff → one verifier agent per rule → Skeptic re-reads each flag → Confirmed violations only*
> ![[trq212-367865-008.jpg]]
>
> ## Root-cause investigation
>
> Debugging works best when you come up with several independent hypotheses and test them, but if you're only using one context window, Claude can run into self-preferential bias.
>
> A workflow can structurally prevent this by spinning up agents to generate hypotheses from disjoint evidence. For example, separate agents for logs, files, and data. Each hypothesis can then face a panel of verifiers and refuters.
>
> This isn't just for code. Workflows can be used for sales (why did sales drop in March?), data engineering (why did this pipeline fail?), or any post-mortem exercise.
>
> ## Triaging at scale
>
> Every team has a support queue, bug reports, or some other backlog that cannot be fully processed by humans.
>
> A triage workflow classifies each item, dedupes against what's already tracked, and takes action. This could mean attempting the fix or escalating to a human user.
>
> A useful pattern for triage workflows is quarantine. This involves barring the agents that read untrusted public content from taking high-privilege actions, which are instead done by the agents in charge of acting on the information.
>
> Pair triage workflows with /loop to have Claude do this continuously.
>
> *Triage with quarantine: Reader agents in no-privilege zone → structured summary only → Actor agent with high-privilege tools → attempt fix or escalate → /loop runs continuously*
> ![[trq212-367865-009.jpg]]
>
> ## Exploration and taste
>
> Workflows can be useful when exploring different approaches to a solution, especially when it is taste based, like design or naming, and would benefit from a rubric.
>
> Try asking Claude to explore a bunch of solutions, and give a review agent a rubric for what a good solution looks like. The task is complete when the review agent feels like it has met the criteria. Solutions can also be ordered or selected via a tournament based on the rubric.
>
> ## Evals
>
> You can run lightweight evals for particular tasks by spinning off separate agents in a worktree and then spinning off comparison agents to compare and grade the specific outputs against a rubric. For example, evaluating and then refining a skill you've created against a particular criteria.
>
> ## Model and intelligence routing
>
> Create a classifier agent tuned to your tasks that decides which model to use. This can be helpful when your task will involve many tool calls and conducting research prior to execution can identify the best model for the job.
>
> For example, the best model for the task "explain how the auth module works" depends on how many files in the auth module there are and the shape of the codebase. A classifier agent can do this research and then route to Sonnet or Opus based on the expected complexity of the task.
>
> ## When not to use dynamic workflows
>
> Workflows are new. While there are many use cases where it will create outsized results, they are not needed for every task and may end up using significantly more tokens.
>
> It's best to use workflows creatively to push Claude Code in ways that you haven't previously. For regular coding tasks, try and ask yourself does it really need more compute? For example, most traditional coding tasks do not need a panel of 5 reviewers.
>
> # Tips for building dynamic workflows
>
> Prompting
>
> Detailed prompting, using the specific techniques we described above, for dynamic workflows creates the best results.
>
> Workflows are not just for large tasks. You can prompt the model to use a "quick workflow." For example, you can create a quick adversarial review of an assumption.
>
> Combine with /goal and /loop
>
> When using workflows that can be repeated, for example triage, research, or verification, pair them with /loop to be run at regular intervals, and /goal to set a hard completion requirement.
>
> Token usage budgets
>
> You can set explicit token usage budgets for dynamic workflows to limit how many tokens a task uses. You can prompt it with a budget like: "use 10k tokens," which will set the cap.
>
> Saving and sharing dynamic workflows
>
> You can save workflows by pressing "s" in the workflow menu. You can check these into ~/.claude/workflows or distribute them via a skill.
>
> *Dynamic workflows UI: 1 running, 2 completed — review-changes (14 agents, 482k tok, 6m 12s), find-flaky-tests (6 agents, 121k tok, 1m 48s), deep-research (22 agents, 1.1M tok, 11m 3s)*
> ![[trq212-367865-010.jpg]]
>
> To share them via a skill, put your JavaScript workflow files in the skill and folder and reference them in the [SKILL.MD](http://skill.md/). To allow for more flexibility, you may want to prompt Claude to think of the workflows in the skill as a template instead of a script that needs to be run verbatim.
>
> *Workflow file ships inside the skill folder alongside SKILL.md — anyone who installs the skill runs the same workflow*
> ![[trq212-367865-011.jpg]]
>
> ## A whole new world
>
> Workflows are a helpful new way to extend Claude Code. I encourage you to think of this as a starting point, there's still much to discover in how to use them best. Let us know what you find.
>
> Thariq Shihipar and Sid Bidasaria (@sidbid) are members of technical staff at Anthropic, working on Claude Code.
>
> ---
> **Thread replies**
>
> > @J_VillaDev (Javier V.) — Tue Jun 02 20:42:52 +0000 2026
> > @trq212 I've Been running a triage agent in production for months, the agentic laziness and self-preferential bias problems are real.
> > Excited to see how workflows handle long-running triage at scale.
>
> > @jeroendee (Jeroen Dee) — Tue Jun 02 20:50:40 +0000 2026
> > @trq212 cc @jgordijn Thariq X article prob. worth reading.
>
> > @ReshAimFire (Omniphage) — Tue Jun 02 21:01:08 +0000 2026
> > @trq212 Can we call these self authoring harnesses?
>
> > @jameshonsa (James Honsa) — Tue Jun 02 21:29:07 +0000 2026
> > @trq212 is there guidance coming on invoking dynamic workflows in the agent sdk?
>
> > @bbishdotdev (Brenden Bishop) — Tue Jun 02 21:49:24 +0000 2026
> > @trq212 "…workflows tend to use more tokens so use wisely!"
> > Also Thariq:
> > "I need a name for this CLI tool. Use a workflow to brainstorm a bunch of options and run a tournament to pick the top 3."
>
> > @trq212 (Thariq) — Tue Jun 02 21:50:25 +0000 2026
> > @bbishdotdev lmao this is relatively cheap from a token perspective because names dont need much context/toolcalls and naming is important!
>
> > @its_sj13 (Sufiyan Junaidi) — Tue Jun 02 21:52:40 +0000 2026
> > @trq212 @karpathy The token-saving warning never stood a chance against the urge to over-engineer a CLI name. Burn them in style
>
> > @embw_l0x (embw_l0x) — Tue Jun 02 21:53:39 +0000 2026
> > @trq212 @karpathy Workflows are great until you realize claude did nothin for 18 hours
>
> > @badlogicgames (Mario Zechner) — Tue Jun 02 21:58:27 +0000 2026
> > @trq212 good stuff, i'd like to understand what caveats this has:
> > > resuming the session will allow the workflow to pick up where it left off.
> > it seems hard to ensure general durability for arbitrary workflows?
>
> > @irshit0 (irshit) — Tue Jun 02 22:01:52 +0000 2026
> > @trq212 @karpathy I have started using /workflows for dynamic workflows its going pretty well been using ultracode for this
>
> > @numerounochef (((((Tom))))) — Tue Jun 02 22:04:36 +0000 2026
> > @trq212 Unfortunately I used this on a very small problem, and it really messed up my code in a way I haven't experienced since I was a JR dev using gpt 3.5x
>
> > @trq212 (Thariq) — Tue Jun 02 22:05:19 +0000 2026
> > @numerounochef what was your prompt?
>
> > @trq212 (Thariq) — Tue Jun 02 22:08:40 +0000 2026
> > @badlogicgames yeah it's definitely not like we shipped temporal inside of your terminal, but we do things in the JS environment to make it more deterministic
> > I would model it as roughly as durable as "/resume"ing every subagent
>
> > @norlava (Norin) — Tue Jun 02 22:23:16 +0000 2026
> > I really love the idea of a dynamic workflow. In my experience, you still need the developer to define the constraints, gates, and be able to steer the agent mid-run inside a stage. Otherwise, it's slop and too expensive. A model making its own harness still doesn't have the same context about a team's repo, build process, etc.
>
> > @trq212 (Thariq) — Tue Jun 02 22:24:53 +0000 2026
> > @norlava I thought so too before trying it out.. but I feel like workflows just mostly works as is, though you can prompt it to follow particular patterns
>
> > @rstagi_ (Roberto Stagi) — Tue Jun 02 22:25:54 +0000 2026
> > @trq212 @karpathy Yet another signal that agents tend to solutions where they "code" their behavior, rather than letting the model call the tooling directly. Is this really the direction?
>
> > @NateHelmig (Nathan Helmig) — Tue Jun 02 22:30:57 +0000 2026
> > @trq212 Nobody likes workflows. You made a feature that works against the fundamentals of your own technology. It burns tokens so fast 4-5 prompts in and you have maxed out your 5 hour limit. This was a feature for anthropomorphic balance sheet and not the users.
>
> > @M0ckaj (Ladislav Hustý) — Tue Jun 02 22:54:29 +0000 2026
> > @trq212 Does it make sense using workflows for creating a spec sessions?
>
> > @trq212 (Thariq) — Tue Jun 02 22:57:46 +0000 2026
> > @M0ckaj I think it can make sense to do a bunch of research or exploration of different areas before building a spec!
>
> > @aHev (Adam Hevenor) — Tue Jun 02 23:19:35 +0000 2026
> > @trq212 In theory I like this feature idea but so far it has not worked well for me. Skills issue perhaps.
>
> > @trq212 (Thariq) — Tue Jun 02 23:21:03 +0000 2026
> > @aHev ah really, what have you tried?
>
> > @Hem_chandiran (Hemachandiran) — Tue Jun 02 23:24:02 +0000 2026
> > @trq212 I'd recommend everyone to read this article fully. Here is my view on this — This is a great article to understand the nook and corner of the new feature of Opus 4.8. I strongly believe when not to use this is also imp to make it more effective and save compute. @trq212 Also discussed the ways to limit the token and iterations.
>
> > @seshubon (seshu bonam) — Tue Jun 02 23:53:07 +0000 2026
> > @trq212 claude generally has a good habit of asking questions to clarify the choices. how is that handled in workflow. to make the decisions transparent and trustable.
>
> > @theadanovak (Ada Novak) — Wed Jun 03 00:01:35 +0000 2026
> > @trq212 Gate design isn't configuration rather it's encoded domain knowledge. The dev who defines constraints mid-run is doing the work a model can't yet replicate: knowing which failure mode matters more than speed.
>
> > @mark5lab (Mark5 Labs) — Wed Jun 03 00:04:46 +0000 2026
> > @trq212 the tournament pattern for sorting 1000+ items is the part that stuck with me. pairwise comparison is way more reliable than absolute scoring. tried something similar manually and the context window hit me hard mid-way through.
>
> > @zhijun28566 (Lethe.Li) — Wed Jun 03 00:24:01 +0000 2026
> > @trq212 dynamic workflows... this is exactly what i have been trying to piece together myself lately
>
> > @ArtemXTech (Artem Zhutov) — Wed Jun 03 00:24:41 +0000 2026
> > @trq212 Do you have a reliable process for extracting the patterns from previous conversations? I'm sure you guys looked into that. Why can't we automate everything if we have access to those conversations? A naive question.
>
> > @VPsing06 (Tejas AI) — Wed Jun 03 01:17:23 +0000 2026
> > Dynamic workflows let Claude spin up custom harnesses with subagents, adversarial verification, tournaments, and fan-out patterns. This directly attacks the biggest failure modes we see in long sessions laziness, self-preferential bias, goal drift.
> > The examples are excellent, especially the non-coding ones like resume ranking, business plan stress-testing, and root cause analysis.
> > That said, as @trq212 mentioned, these use significantly more tokens. The real skill now is knowing when a task actually needs this level of orchestration vs when normal Claude Code is enough.
>
> > @consideray (Ray Kwan) — Wed Jun 03 01:44:52 +0000 2026
> > @trq212 Glad to see that the harness concept doesn't just apply to coding. Can't wait to test out what this new framework could achieve.
>
> > @JeffersonDjango (Jefferson) — Wed Jun 03 02:27:15 +0000 2026
> > @trq212 Half the time Claude says it doesn't know what workflow is, that it didn't found a workflow tool
>
> > @ktchn_ngnr42 (kitchen-engineer42) — Wed Jun 03 02:27:41 +0000 2026
> > @trq212 now claude code as a harness feels more like navigating through a 2-dimensional task matrix. the sequential axis managed by ralph/taskboards, and the parallel axis managed by workflows.
>
> > @0xpenguin2 (Penguin) — Wed Jun 03 02:38:06 +0000 2026
> > @trq212 And appreciate the writeup, Claude team is one of the few that ships a product and then actually teaches people how to get the most out of it.
> > Been using it a few days, still need more reps before I'm using it well in real work.
>
> [Original post](https://x.com/trq212/status/2061907337154367865)
