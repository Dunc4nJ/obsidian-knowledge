---
created: 2026-06-06
description: A 14-step practitioner's guide that maps each of Claude Code Dynamic Workflows' 6 patterns directly to the failure mode it structurally prevents, provides an explicit use-case composition matrix, and adds cost controls and anti-patterns missing from Anthropic's launch post.
source: https://x.com/0xCodez/status/2062127385923776831
type: framework
---

## Key Takeaways

- **Each of the 6 patterns is a structural fix for a specific failure mode — the mapping is the insight.** [[Claude Code dynamic workflows write a custom JS harness per task to structurally prevent agentic laziness self-preferential bias and goal drift]] names the three failure modes; this post completes the picture: drift → fan-out (each subagent sees only its piece, no cross-contamination); self-preferential bias → adversarial verification (isolated verifier with no memory of the author's work); open-ended completeness → loop-until-done; heterogeneous work → classify-and-act; too-many-items-to-score → tournament (pairwise is more reliable than absolute scoring); brainstorm quality → generate-and-filter. Knowing the failure mode determines the pattern; prompting cannot fix these structurally.

- **Real workflows compose 2–4 patterns — the composition matrix is the practical unlock.** The six patterns rarely appear alone. Migrations: fan-out per callsite in a worktree + adversarial review per fix + loop until done (how Bun rewrote from Zig to Rust). Deep research: fan-out web searches + adversarial claim verification + single synthesizer. Root-cause: generate theories from disjoint evidence (separate agents read logs, files, data) + panel of verifiers and refuters + loop until one survives. Sorting 1,000+ items: tournament with bracket in deterministic loop code, never absolute scores. The composition choice falls directly out of which failure modes the task is susceptible to. See [[Claude Code dynamic Workflows synthesize a per-task agent harness at runtime opening a third scaling axis]] for the technical primitives (`agent()`, `parallel()`, `pipeline()`) that implement these compositions.

- **Cost controls are not optional — three levers turn workflows from "cool but costly" into production tools.** `/goal` sets a hard completion requirement so the loop pattern doesn't stop at the first soft completion point. `/loop` runs the entire workflow on a recurring schedule for continuous triage or weekly research updates. Explicit token budgets in the prompt (`Use 5k tokens`) cap runaway runs — without a cap, ambitious workflows balloon to 5–10× expected cost. The `ultracode` trigger word (`/effort ultracode` = xhigh + workflows) is the CLI entry point; alternatively ask Claude directly "make a workflow that…" Most traditional coding tasks do not need a panel of 5 reviewers; the cost question must be answered before reaching for a workflow.

- **Quarantine is the mandatory security boundary for any workflow that reads untrusted content.** Reader agents operate in a no-privilege zone (read-only tools only) and pass only structured summaries to actor agents that hold high-privilege tools. This structurally prevents prompt injection from support tickets, bug reports, or public feeds reaching agents that can open PRs or send messages — a trust boundary enforced by isolation, not content filtering. Pair with `/loop` for continuous triage. This complements the quarantine guidance in [[Claude Code dynamic workflows write a custom JS harness per task to structurally prevent agentic laziness self-preferential bias and goal drift]].

- **Saving as a Skill makes a working workflow distributable.** Press `s` in the workflow menu to save to `~/.claude/workflows`. To ship it: bundle the `.workflow.js` file inside a Skill folder alongside `SKILL.md`, where SKILL.md references the file and describes when to invoke it. Anyone who installs the Skill runs the same workflow. Prompt Claude to treat the bundled workflow as a template, not a fixed script — this lets it adapt the structure to the specific task while preserving the overall shape.

## External Resources

- [movez.substack.com](https://movez.substack.com/) — @0xCodez's Substack for AI alpha posts
- [Dynamic Workflows docs](https://code.claude.com/docs/en/workflows) — official Claude Code workflow primitives reference

## Original Content

> @0xCodez (Codez) — Wed Jun 03 11:00:55 +0000 2026
>
> Article: How to master Dynamic Workflows in Claude Code: 6 patterns and 14 steps Anthropic engineers actually
>
> Most Claude Code users still write their workflows by hand. They chain prompts, copy outputs, paste them into the next prompt, fix what went wrong, repeat.
>
> 9 out of 10 builders haven't tried Dynamic Workflows even once, even though they shipped two weeks ago.
>
> They write 50 prompts when one workflow would do. This is the 14-step roadmap and the 6 patterns Anthropic's own engineers actually use - for migrations, research, sorting, root-cause, triage, and evals.
>
> Follow my Substack to get fresh AI alpha: movez.substack.com
>
> *"14 Steps — Master Claude Dynamic Workflow" — flow diagram showing lead node fanning into trigger, context, tool use, decision, then output, reflection, update, and steps 9–14.*
> ![[0xcodez-776831-001.jpg]]
>
> Dynamic Workflows shipped in Claude Code on May 28, 2026. The default Claude Code harness is built for coding - and that works well for most coding tasks. But there are classes of work where one context window starts to break down: long-running, massively parallel, highly structured, or adversarial.
>
> For those, Anthropic used to build custom harnesses themselves (Research, Code Review, agent teams). With Dynamic Workflows, Claude writes that harness for you on the fly, custom-built for your task, in JavaScript.
>
> 14 steps. 6 patterns. One workflow instead of fifty prompts.
>
> ---
>
> **Part 1 · The Mental Model**
>
> ## 01. A workflow is a harness Claude writes.
>
> The default Claude Code harness has Claude plan and execute in the same context window. For most coding work, this is great. For long-running, parallel, or adversarial work, it breaks down.
>
> A Dynamic Workflow is Claude writing its own custom harness for the task - a JavaScript file with a few special functions that spawn and coordinate subagents, plus standard JavaScript (Math, JSON, Array) to process the data flowing between them.
>
> *Ten classes of work where one context window stops scaling — migrations, research, verification, sorting, rules, root cause, triage, taste, evals, routing.*
> ![[0xcodez-776831-002.png]]
>
> Three things this gives you that the default harness cannot:
>
> - Per-agent isolation. Each subagent gets its own context window with one focused goal. No cross-contamination.
>
> - Per-agent model choice. The workflow picks which model each subagent uses - Opus for hard reasoning, Haiku for cheap exploration, Sonnet for the middle.
>
> - Per-agent isolation level. Worktree (isolated git checkout) or remote (no checkout). The workflow decides what each agent needs.
>
> Start one by either asking Claude directly ("make a workflow that…") or with the trigger word ultracode. If a workflow is interrupted - user action, terminal quit - resuming the session picks up where it left off.
>
> *Agent teams (triangle topology) vs Dynamic Workflows (orchestrator → N parallel implementer/verifier/fixer trees returning to a final synthesizer).*
> ![[0xcodez-776831-003.jpg]]
>
> ---
>
> ## 02. The 3 failure modes workflows solve.
>
> To know when a workflow is the right tool, you have to know what it fixes. The longer Claude works on a complex task in a single context window, the more it becomes susceptible to three specific failure modes - named directly in the Anthropic launch writing:
>
> - Agentic laziness - Claude stops before finishing a complex, multi-part task and declares done after partial progress. Addresses 20 of the 50 items in a security review and calls the rest "handled."
>
> - Self-preferential bias - Claude prefers its own results when asked to verify or judge them against a rubric. A verifier with skin in the game can't be a fair verifier.
>
> - Goal drift - the gradual loss of fidelity to the original objective across many turns, especially after compaction. Each summarization step is lossy. "Don't do X" constraints quietly disappear at turn 47.
>
> A workflow solves all three structurally: separate Claudes with their own contexts, focused goals, and isolated state. If your task suffers from any of these patterns - that's the signal to reach for a workflow.
>
> ---
>
> ## 03. Static vs Dynamic workflows.
>
> You may have already built static workflows using the Claude Agent SDK or claude -p - coordinating multiple Claude Code instances together.
>
> - Static workflows are generic: written once to handle every edge case. They work, but they have to be conservative.
>
> - Dynamic Workflows are different: Claude writes this workflow for this task. The harness is tailor-made. Below is the same question handled both ways:
>
> The reason the dynamic version wins isn't the search step - both can search.
>
> It's that the workflow gets to shape itself around your context: read your billing code, check each feature against the actual new provider docs, price at your transaction volume, and run an adversarial "why not to migrate" pass against its own emerging answer.
>
> A static harness can't do this because it doesn't know your code exists.
>
> *Static harness ("Should we migrate our checkout service?") produces a generic research report via 5 web searches. Dynamic workflow reads actual billing code, checks features against provider docs, runs a devil's advocate agent, and produces a specific recommendation.*
> ![[0xcodez-776831-004.png]]
>
> ---
>
> ## 04. The core API. agent(), parallel(), pipeline().
>
> Three functions do most of the work in a workflow. Knowing them is enough to read any workflow Claude writes for you and to nudge Claude when you want a specific shape.
>
> parallel() is a barrier: it fans out, then waits for everything before returning. pipeline() is streaming: each item flows through every stage independently.
>
> Pick by the question: do I need all results before I can do anything next? Yes → parallel. No → pipeline (cheaper, faster overall).
>
> *Core API reference: agent(prompt, opts?) → Promise<string | JsonSchema>; parallel([fns]) fans out with a barrier; pipeline(items, …) streams with no barrier.*
> ![[0xcodez-776831-005.png]]
>
> ---
>
> **Part 2 · The 6 Patterns**
>
> ## 05. Classify-and-act. Route the work before doing it.
>
> A classifier agent decides on the type of task, then the workflow routes to different agents or behaviors based on the answer. Or a classifier runs at the end, sorting raw outputs into buckets for whatever comes next.
>
> When this pattern earns its keep:
>
> - The task is heterogeneous - different sub-types need different treatment.
>
> - You want to spend the expensive model only where complexity demands it (classifier on cheap, then route to Opus only when needed).
>
> - The decomposition of work is itself non-trivial and benefits from a model deciding the shape.
>
> Example: "Explain how the auth module works." A classifier subagent reads the codebase first, estimates complexity, then routes the actual explanation task to Sonnet for a 10-file module or Opus for a 100-file one. The right model for the job, decided after the work is understood.
>
> ---
>
> ## 06. Fan-out-and-synthesize. Many small steps, one merged result.
>
> Split a task into many smaller steps. Run an agent on each step in parallel. Synthesize the results into one answer.
>
> The synthesize step is a barrier - it waits for every fan-out agent, then merges their structured outputs.
>
> Why this pattern dominates in practice: it solves the "too many things at once" failure of single-context work. Each subagent sees only its piece. The orchestrator never gets distracted by 50 unrelated details.
>
> Each step benefits from its own clean window so they don't cross-contaminate.
>
> Use this when:
>
> - You have a clearly enumerable list of work items (50 files, 200 endpoints, 100 reviews).
>
> - Each item is independent - no item needs another's output to begin.
>
> - You want a single consolidated answer at the end, not a pile of partial reports.
>
> ```javascript
> // Fan out: one agent per file. Barrier: wait for all.
> const reviews = await parallel(
>   files.map(file => () => agent(
>     `Review ${file} for security issues`,
>     { model: "haiku", schema: IssueList }
>   ))
> )
>
> // Synthesize: one Opus agent merges everything.
> const report = await agent(
>   `Merge these reviews into one prioritized report:\n${JSON.stringify(reviews)}`,
>   { model: "opus" }
> )
> ```
>
> ---
>
> ## 07. Adversarial verification
>
> This is the structural fix for self-preferential bias. For each spawned agent, run a separate spawned agent that adversarially verifies its output against a rubric. The verifier has never seen the original work; it can't favor it.
>
> The pattern matters most for:
>
> - Claim-checking - every factual statement in a report gets its own verifier subagent, checking against the original source.
>
> - Code review - the author agent writes the fix, the reviewer agent (separate context) reviews it. Never the same Claude judging itself.
>
> - Quality gates - before any artifact ships, an adversary tries to find the weakest case against it. If the adversary can't, you ship.
>
> The pairing rule: the verifier should know only the rubric and the artifact, not who produced it. Otherwise self-preference creeps back in through hints in the prompt.
>
> ---
>
> ## 08. Generate-and-filter.
>
> Generate a number of ideas on a topic, then filter them by a rubric or by verification. Dedupe duplicates. Return only the highest quality, tested ideas.
>
> Where this pattern shines:
>
> - Brainstorming - 30 product names, then a verifier kills clichés, trademark conflicts, and weak phonetics. You see 3.
>
> - Hypothesis generation - 5 different approaches to a problem, then each gets scored against your constraints. The winner has earned it.
>
> - Solution design - 5 different approaches to a problem, then each gets scored against your constraints. The winner has earned it.
>
> The opposite of asking Claude for "the best answer." Asking for the best answer makes Claude commit early. Generate-and-filter makes Claude commit late, after every option has been challenged.
>
> ---
>
> ## 09. Tournament. Pairwise comparison beats absolute scoring.
>
> Instead of dividing the work, have agents compete on it. Spawn N agents that each attempt the same task using different approaches, then judge the results in pairwise fashion until one wins.
>
> Comparative judgment is more reliable than absolute scoring - especially for taste-based work.
>
> Why this beats sort-by-score: trying to sort 1,000 items in one prompt fails on two fronts - quality degrades, and it won't fit in context. A tournament splits the bracket across fresh agents, each comparing just two items.
>
> The bracket itself lives in deterministic loop code, not in context. Each comparison is fast, fair, and isolated. Same idea works for taste-based ranking: design choices, candidate selection, content prioritization.
>
> *Tournament bracket: 1,000 items → round 1 pairwise comparisons (each by a fresh agent) → round 2 → final comparison → sorted ranked output.*
> ![[0xcodez-776831-006.png]]
>
> ---
>
> ## 10. Loop until done.
>
> For tasks with an unknown amount of work, loop spawning agents until a stop condition is met - no new findings, no more errors in the logs, theory verified - instead of running a fixed number of passes.
>
> This pattern is the answer to "keep going until it's actually done":
>
> - Flaky test debugging - reproduce, form theories, test them, until one theory holds.
>
> - Bug hunting - keep finding bugs until a full pass returns zero.
>
> - Mining for patterns - cluster, identify rules, until no new clusters appear.
>
> Pair this pattern with /goal to set a hard completion requirement ("don't stop until one theory works") and with /loop if you want the entire workflow itself to run on a recurring schedule.
>
> The bracket and the stop condition live in code; only the active iteration stays in context.
>
> ---
>
> **Part 3 · Composing Patterns**
>
> ## 11. Compose patterns for real use cases. One workflow, several patterns.
>
> The 6 patterns rarely appear alone. A real workflow composes 2-4 of them. The matrix below pairs each use case from the Anthropic launch writing with the patterns it tends to use:
>
> - Migrations and refactors. Fan-out (one agent per callsite/failing test in a worktree) → adversarial verification (a separate agent reviews each fix) → loop until done. This is the pattern Anthropic used to rewrite Bun from Zig to Rust.
>
> - Deep research (the /deep-research skill). Fan-out (parallel web searches) → adversarial verification (each claim verified independently) → synthesize (one cited report).
>
> - Deep verification of a draft. Identify all factual claims (one agent) → fan-out (one verifier per claim, each agent checks against source) → meta-verifier (checks the verifier's sources are high quality).
>
> - Sorting 1,000+ items. Tournament (steps 5-9) - pairwise comparison, bucket-rank, or bracket. Comparative judgment, never absolute scoring.
>
> - Memory and rule adherence. Verifier per rule (fan-out) → skeptic persona reviews the rules themselves to avoid false positives.
>
> - Root-cause investigation. Generate theories from disjoint evidence (different agents read logs, files, data) → panel of verifiers and refuters for each theory → loop until one survives.
>
> - Triage at scale. Classify-and-act → dedupe against existing tickets → either attempt the fix or escalate. Pair with /loop for continuous triage.
>
> - Exploration and taste (design, naming, UI choices). Generate-and-filter (5-20 options) → tournament with a rubric → rank or pick.
>
> - Lightweight evals. Run the candidate in a worktree → comparison agents grade against rubric → refine and re-grade. Same shape as a tournament but for grading, not ranking.
>
> The right way to internalize these: identify which failure mode your current task is failing under, then pick the pattern that structurally prevents it.
>
> Drift → fan-out. Self-preference → adversarial verification. Open-ended → loop until done. Hard-to-score → tournament.
>
> ---
>
> ## 12. Pair with /goal, /loop, and token budgets.
>
> Workflows can be expensive. Three controls turn them from "cool but costly" into "a tool I run unattended."
>
> - /goal sets a hard completion requirement. Pair it with the loop pattern: "don't stop until one theory works." Without /goal, a workflow stops at a soft completion point. With /goal, it iterates until the actual end condition is met.
>
> - /loop runs the entire workflow on a recurring schedule. Use it for workflows you want running continuously - triage, weekly research updates, recurring verification.
>
> - Explicit token budgets. Tell Claude in the prompt: "use 10k tokens." This sets a cap on the workflow run. Without a cap, an ambitious workflow can balloon to 5–10× the tokens you expected.
>
> ```
> ultracode quick adversarial review of this assumption:
>   "moving to Postgres eliminates our shard rebalancing."
>   Use 5k tokens. /goal don't stop until you have either
>   a counterexample or three independent confirmations.
> ```
>
> Quoting the Claude Code team directly: "Best practices are still developing. Dynamic workflows often use more tokens, so think carefully about when and how to use them." Most traditional coding tasks do not need a panel of 5 reviewers.
>
> Ask yourself: does this task really need more compute? If a regular Claude Code session would finish it in five minutes, you don't need a workflow.
>
> *The Claude Code effort slider: ultracode = xhigh + workflows, the top-tier effort level.*
> ![[0xcodez-776831-007.jpg]]
>
> ---
>
> ## 13. Use the quarantine pattern for untrusted input.
>
> Any workflow that reads untrusted public content - support tickets, bug reports, user feedback, scraped data - needs to assume that content might contain prompt injection.
>
> The fix: quarantine. Bar the agents that read the untrusted content from taking any high-privilege actions. Separate agents, with no exposure to the raw content, do the acting.
>
> Any workflow that processes user-submitted content (support tickets, bug reports, customer feedback, social media), scrapes public web pages, or runs against output from a third-party API.
>
> If the input wasn't written by you or a trusted teammate, quarantine it. A 30-line read-only reader agent costs almost nothing and removes an entire class of prompt injection risk.
>
> *Quarantine pattern: untrusted backlog → reader agents (quarantine zone, read-only tools) → structured summaries only → actor agent (trusted zone, high-privilege tools) → attempt fix or escalate → /loop for continuous operation.*
> ![[0xcodez-776831-008.png]]
>
> ---
>
> ## 14. Save workflows. Ship them as Skills.
>
> Once a workflow works, save it: press s in the workflow menu. Saved workflows go to ~/.claude/workflows. From there you have two paths:
>
> - Keep it local - reuse it across your own projects.
>
> - Ship it as a Skill - bundle the JavaScript file inside a Skill folder, reference it in SKILL.md, and anyone who installs the Skill runs the same workflow.
>
> One practical nuance worth knowing: when you package a workflow into a Skill, prompt Claude to treat the workflow as a template, not a script to run verbatim.
>
> That leaves room for Claude to adapt the workflow shape to the specific task at hand while keeping the overall structure intact. Especially useful for workflows like "deep verification" or "triage" that need to flex per use case.
>
> *Skill folder layout: ~/.claude/skills/deep-verify/ contains SKILL.md and verify-claims.workflow.js; SKILL.md references the .workflow.js file — "Share the folder — anyone who installs the skill runs the same workflow."*
> ![[0xcodez-776831-009.png]]
>
> ---
>
> ## The mistakes that waste tokens on workflows
>
> - Reaching for a workflow when a regular Claude Code session would do. Most traditional coding tasks don't need a panel of 5 reviewers.
>
> - No token budget. Ambitious workflows balloon to 5–10× what you expected without an explicit cap.
>
> - One agent doing both the work and the verification. Self-preferential bias makes the verifier favor the worker. They must be separate.
>
> - Treating parallel() and pipeline() as interchangeable. The barrier matters - parallel waits for all, pipeline streams.
>
> - Skipping /goal on loop patterns. The workflow stops early at the first soft completion point. /goal forces hard completion.
>
> - Letting untrusted content reach the actor. Quarantine isn't optional once you process anything user-submitted.
>
> - Sorting with absolute scores. Comparative judgment is more reliable. Use a tournament.
>
> - Never saving working workflows. Re-prompting the same shape every week. Save with s, ship as a Skill.
>
> ---
>
> **Thread replies:**
>
> @RitOnchain (venus) — Wed Jun 03 11:05:53 +0000 2026:
> @0xCodez amazing alpha released!!
>
> @0xCodez (Codez) — Wed Jun 03 11:07:11 +0000 2026:
> @RitOnchain Thanks, Venus! Dynamic Workflow is one of the most revolutionary things released by Claude in the past time, in my opinion.
>
> @gippp69 (Gipp) — Wed Jun 03 11:07:14 +0000 2026:
> @0xCodez Excellent setup, 100% bookmarking it
>
> @0xCodez (Codez) — Wed Jun 03 11:08:24 +0000 2026:
> @gippp69 thanks, Gipp. Are you using Claude Dynamic workflow yourself?
>
> @rileywestreel (Riley West) — Wed Jun 03 11:13:03 +0000 2026:
> @0xCodez The gap between casual and serious Claude users is exactly this: one prompts, the other builds workflows. it compounds fast.
>
> @kiruwaaaaaa (kiruwaaaa) — Wed Jun 03 11:15:03 +0000 2026:
> @0xCodez Awesome article bro
>
> @0xCodez (Codez) — Wed Jun 03 11:15:46 +0000 2026:
> @kiruwaaaaaa thanks browski! happy its useful for you!
>
> @dancolta (Dan Colta) — Wed Jun 03 11:39:58 +0000 2026:
> @0xCodez shipped 7 Claude Code skills this year, most of them touch these loop patterns in some form. the orchestration layer needs to be solid before adding dynamic routing tho, found that out around month 3, can share the breakdown if you fancy a read
>
> @0xMovez (Movez) — Wed Jun 03 11:40:32 +0000 2026:
> @0xCodez Top-tier reading, Codez! I was about to start learning Dynamic Workflow! Thanks for the share, bro.
>
> @Jeyxbt (Jey) — Wed Jun 03 11:51:41 +0000 2026:
> @0xCodez Dynamic workflow is the GOAT. I'm using it a lot in my work, it's burning tokens a lot, but it's worth it
>
> @0xCodez (Codez) — Wed Jun 03 11:53:50 +0000 2026:
> @Jeyxbt one of the best Claude feature they shipped for the past time in my opinion
>
> @itsthedonhashim (Hussain Hashim) — Wed Jun 03 11:56:58 +0000 2026:
> @0xCodez ngl, dynamic workflows sound like a cheat code for efficiency. might save me hours of back and forth with prompts.
>
> @0xMoysei (Moysei) — Wed Jun 03 12:03:55 +0000 2026:
> @0xCodez helpful for businesses, cool
>
> @rgk_degen (RGK) — Wed Jun 03 12:14:32 +0000 2026:
> @0xCodez useful article, thx bro
>
> @ryoxxai (Ryo) — Wed Jun 03 12:57:32 +0000 2026:
> @0xCodez Thanks bro, that's exactly what I was missing.
>
> @0xCodez (Codez) — Wed Jun 03 12:59:51 +0000 2026:
> @0xMoysei you are welcome Moysei!
>
> @0xCodez (Codez) — Wed Jun 03 13:24:03 +0000 2026:
> @rgk_degen You are welcome brother. Happy it's useful for you!
>
> @Nikitont (Nikiton) — Wed Jun 03 14:43:52 +0000 2026:
> @0xCodez Your work is getting better every day, keep going!
>
> @Quasar0x (Quasar) — Wed Jun 03 15:08:43 +0000 2026:
> @0xCodez master of workflows is whole new level, trying my best on them rn
>
> @rewind02 (rewind) — Wed Jun 03 15:57:52 +0000 2026:
> @0xCodez workflows are the real feature
>
> @ph4r05 (Dusan Klinec) — Wed Jun 03 17:20:35 +0000 2026:
> @0xCodez Workflows are awesome. But I do miss one thing though. It cannot emit an user question. AskUserQuestion tool is not available in the main workflow or spawned sub-agents.
>
> @alphabatcher (Alpha Batcher) — Wed Jun 03 17:38:53 +0000 2026:
> @0xCodez best guide about how to be master in dynamic workflow
>
> @Argona0x (Argona) — Wed Jun 03 18:10:27 +0000 2026:
> @0xCodez this is now in my top 5 best guides on dynamic workflows
>
> @leakorsawe (Lea Marie Korsawe) — Wed Jun 03 18:33:19 +0000 2026:
> @0xCodez Anyone figured out how to save tokens? I already asked Claude to only use Sonnet for reading but it still burns through them like a crypto miner in 2021.
>
> @proyecto_26 (Proyecto 26) — Wed Jun 03 21:50:46 +0000 2026:
> @0xCodez @elonmusk wondering if you can include an "Export to Markdown" option from X to be able to download/use the content of this articles w/ custom agents?
>
> @cv_usk (cv usk) — Wed Jun 03 22:24:23 +0000 2026:
> @0xCodez I believe its most practical use is instantly deploying adversarial agents to rigorously stress-test complex LLM system architectures.
>
> @StuyBoyNY (StuyBoy From NYC) — Thu Jun 04 04:42:24 +0000 2026:
> @0xCodez @readwise save
>
> @dreadlockgeek (Pantera Negra) — Fri Jun 05 13:13:29 +0000 2026:
> @0xCodez Whoops wrong thread, this is cool
>
> @thomas_rehmer (thomas_R) — Fri Jun 05 13:55:34 +0000 2026:
> @0xCodez Exactly the point most people miss: a workflow is a harness Claude writes for you, not some magic autopilot. The value sits in isolation + verification, not in saving prompts. Well summed up.
>
> @kekkodamato_ (Kekko D'Amato) — Fri Jun 05 14:07:56 +0000 2026:
> The shift from "write prompts" to "write loops" is the actual unlock. Once you internalize that a workflow is just a program that calls Claude, the surface area of what you can automate expands dramatically. Most people stop at the prompt layer and wonder why results are inconsistent.
>
> @gerardsans (Gerard Sans | Axiom) — Fri Jun 05 16:09:32 +0000 2026:
> @0xCodez [QT @gerardsans: Token Laundering: How AI labs inflate token usage without actually improving their products.]
>
> @gerardsans (Gerard Sans | Axiom) — Fri Jun 05 16:10:17 +0000 2026:
> @0xCodez [QT @gerardsans: Be wary of AI hype. Even the best frontier models achieve just 4% success on the Remote Labour Index (RLI). That's a 96% failure rate.]
>
> @kekkodamato_ (Kekko D'Amato) — Sat Jun 06 06:22:43 +0000 2026:
> The /loop + /routines combo is underrated. Most people treat Claude Code as a better autocomplete — reactive, one prompt at a time. Dynamic workflows flip it: Claude runs until done, not until you paste the next prompt. That's where the real productivity gap opens between builders who get this and those who don't.
>
> [Original post](https://x.com/0xCodez/status/2062127385923776831)
