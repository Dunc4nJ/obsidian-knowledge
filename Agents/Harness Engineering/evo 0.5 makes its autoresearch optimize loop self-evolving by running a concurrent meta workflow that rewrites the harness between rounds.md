---
created: 2026-06-09
description: Alok Bishoyi explains how evo ported its autoresearch optimize loop to Claude Code Dynamic Workflows — making the six-step round (orient → scan → ideate → brief → fan-out → collect) deterministic code instead of long-context agent memory — and then added a concurrent "meta" workflow that wakes every few minutes, reads the run from the outside, and rewrites the optimize harness between rounds. The loop's own shape becomes a parameter space the system evolves.
source: https://x.com/alokbishoyi97/status/2064281952631525741
type: framework
tags:
  - dynamic-workflows
  - claude-code
  - autoresearch
  - meta-loop
  - self-evolving-harness
  - orchestration-as-code
  - evo
---

## Key Takeaways

- **Long-horizon adherence is the failure mode dynamic workflows are made for.** evo's autoresearch loop used to be orchestrated in-context as one long agent run holding the whole plan. Across dozens of rounds the standing rules — run this phase, use this CLI command, dedupe the briefs, keep the gate strict — quietly stopped happening. Moving the loop onto a dynamic workflow fixes that at the root: the method is the code now (phases, fan-out width, stopping rule, gates, CLI calls) and is deterministic on round 1 and round 1000. Adherence stops being something the model has to remember.

- **One round = six steps, all coded.** Each evo optimize round walks: **Orient** (read the experiment tree, take top-width frontier nodes as parents), **Scan** (parallel agents comb evaluated nodes for what works/fails, aggregate agent finds tree-wide patterns), **Ideate** (on stall, three research agents fire at once — one extrapolates the best branch, one dissects failures, one reads literature and web), **Brief** (writer folds findings into concrete experiment briefs, then dedupes), **Fan-out** (one lane per brief in parallel; each lane implements, pre-verifies against metric gaming, runs, post-audits with verifier), **Collect** (prune dead lineages, record notes, repeat until score stops improving).

- **A fixed-shape workflow is still a ceiling.** Even with the loop ported to code, "the workflow still ran same shape every round… no matter what the run had learned about itself. A long run turns up things a fixed shape can't handle: one experiment class needs a verifier step the loop doesn't have, another needs a specific method injected, a phase stops earning its value and should come out." The harness becomes the new bottleneck once the model and gates aren't.

- **evo 0.5's move: a concurrent meta workflow that rewrites the optimize harness while it runs.** Two async loops on one event loop, joined with `Promise.all` — the optimize loop is the driver (unchanged), the meta loop is a fresh agent that wakes every few minutes, reads the run from the outside, and edits the workflow. They share one plain object — the **harness** — holding the steps the loop runs, the phases and prompts, the gates and verifiers (alongside knobs like width and stall that were always adjustable). The optimizer reads it every round; the meta thread writes it. Same event loop, so writes land between the optimizer's awaits — no locks, no second process.

- **Four classes of meta output, separated by trust level.** (1) **Harness edits** — the real lever: inject steps, remove them, rewrite phases that run; takes effect next round; the loop's shape becomes data the system changes to match the run. (2) **Brief hints** — softer, queued into the next round's brief to nudge what it tries. (3) **Stops** — meta never kills directly; it hands a recommendation to a separate gated enforcer that verifies, aborts, diagnoses, discards. **Detect and act stay separate; never a silent kill.** (4) **Alerts** — runtime problems it can't fix itself (e.g., a dying GPU) go to a human.

- **The takeaway is generalizable beyond autoresearch.** "Dynamic workflows make coordination code instead of context. What that buys you is that the loop becomes a first-class object, something you can read, edit, and reason about while it runs, instead of a harness you write once and hope fits every round. The loop's own shape is one more parameter space that can be evolved." Once orchestration is code, the meta loop is just another optimizer — operating on the workflow rather than the artifact under study.

- **The pattern fits inside Anthropic's June 2 launch frame.** Dynamic workflows ([code.claude.com/docs/en/workflows](https://code.claude.com/docs/en/workflows)) let Claude write a small JavaScript program on the fly that spawns and coordinates subagents — coordination runs as code, the model does judgment. evo 0.5 demonstrates the second-order use: if coordination is code, the model can *also* judge whether the coordination shape is the right one, and edit it. Source code: [github.com/evo-hq/evo/blob/main/plugins/evo/skills/optimize/workflows/evo-optimize.js](https://github.com/evo-hq/evo/blob/main/plugins/evo/skills/optimize/workflows/evo-optimize.js).

## Cross-links

This is the second-order step beyond [[Claude Code dynamic workflows write a custom JS harness per task to structurally prevent agentic laziness self-preferential bias and goal drift]] (Thariq's launch piece — same h/t in the article) and [[Claude Code dynamic Workflows synthesize a per-task agent harness at runtime opening a third scaling axis]]. The pattern composition heuristics in [[Claude Code Dynamic Workflows practical mastery maps failure modes to pattern compositions — fan-out for drift, adversarial for self-preference, tournament for taste, loop for open-ended work]] map closely to evo's six-step round (orient/scan/ideate are taste+drift mitigations; fan-out is the obvious one; collect is tournament-style pruning). evo's cost discipline answers the cost critique in [[samueljmcd argues Claude Code Dynamic Workflows earn their cost only when tasks are wide, independently verifiable, and have clear validation criteria — everything else is expensive theatre]] — autoresearch is exactly the "wide + verifiable + clear validation" case where the verification layer earns its keep.

On the autoresearch lineage: [[autoresearch lets an AI agent run ML experiments autonomously overnight]] is the Karpathy origin; [[distributed research swarms close the feedback loop that single-agent autoresearch leaves open]] is the closest sibling (a coordinator summarizing results and feeding guidance back, drawing on Sakana's ShinkaEvolve). The meta-loop's gated-enforcer-not-silent-kill pattern is the production answer to [[autoresearch loops cheat when guardrails are loose but converge on real findings when tightly scoped]] and [[autoresearch agents exploit unconstrained metrics and need multi-objective gates with regular human steering]] — the human steering moves *into* the meta loop, with humans only paged on unfixable runtime issues.

## Full Thread

### Root tweet — @alokbishoyi97 (Alok Bishoyi) · Tue Jun 09 09:42:24 +0000 2026

> 📰 Self-Evolving Autoresearch Workflow Loops
>
> In this article we explain how we ported evo's autoresesarch loop to use workflows and then also made it dynamic.
>
> On June 2 Anthropic shipped[ dynamic workflows in Claude Code](https://code.claude.com/docs/en/workflows): Claude writes a small JavaScript program on the fly that spawns and coordinates subagents. The coordination runs as code; the model does the judgment. The thing to take away is that orchestration itself moved off the model's decison and can now by described as code. h/t @trq212's [writeup](https://claude.com/blog/a-harness-for-every-task-dynamic-workflows-in-claude-code)
>
> ## what evo is
>
> evo is an autoresearch orchestrator. You give it a system, a definition of "better," and a budget. It generates hypotheses, runs each one in its own isolated workspace, scores it, and keeps a tree of attempts - extending what works, pruning what doesn't - while an auditor checks every accepted change so the optimizer can't game the metric. [Open source](https://github.com/evo-hq/evo); runs on Claude Code, Codex, Cursor, and others.
>
> ## why we moved the loop onto workflows
>
> The loop used to be orchestrated in-context, as one long agent run holding the whole plan: which phase comes next, how many experiments to launch, when to stop. evo does autoresearch in an opinionated way, and at every step the agent has to follow that method and drive the CLI we ship alongside it. Over a long autoresearch run, getting the agent to adhere to all of that was tricky. Prompt and instruction adherence is unreliable on long-horizon tasks: across dozens of rounds the standing rules (run this phase, use this CLI command, dedupe the briefs, keep the gate strict etc) quietly stop happening, and the longer a single context runs, the less it holds.
>
> Moving the loop onto a dynamic workflow fixes that at the root. The method is the code now: the phases, the fan-out width, the stopping rule, the gates, and the CLI calls are part of the script, deterministic and the same on round 1 and round 1000. Adherence stops being something the model has to remember. Every step is a fresh, scoped subagent with one job and a clean context, so there's nothing to drift. The model does judgment; the code does coordination.
>
> ## what the evo autoresearch workflow runs: one round
>
> Each round of the optimize loop walks the same six steps, in code:
>
> - Orient: Read the experiment tree: best score, the ceiling, the open frontier. Take the top width frontier nodes as this round's parents.
>
> - Scan: Agents comb the evaluated nodes in parallel for what's working and what's failing, while an aggregate agent looks for patterns across the whole tree.
>
> - Ideate: On a stall, three research agents fire at once: one extrapolates the best branch, one dissects the failures, one reads the literature and the web.
>
> - Brief. A writer folds the scan findings, the patterns, and the ideas into concrete experiment briefs, then dedupes them.
>
> - Fan-out. One lane per brief, in parallel. Each lane implements the change, pre-verifies it (and revises if it's gaming the metric), runs it, then post-audits with the verifier.
>
> - Collect. Prune dead lineages, record notes, and repeat until the score stops improving.
>
> It worked, but now the workflow still ran same shape every round: the same phases (orient, scan, ideate, brief, fan-out, collect), the same steps, the same prompts, no matter what the run had learned about itself. A long run turns up things a fixed shape can't handle: one experiment class needs a verifier step the loop doesn't have, another needs a specific method injected, a phase stops earning its value and should come out.
>
> ## now: the loop evolves itself
>
> evo 0.5 makes the optimize loop self-evolving. A second workflow runs alongside the first. Two async loops on one event loop, joined with `Promise.all`:
>
> - the optimize loop is the driver, the above defined workflow, unchanged
>
> - the meta loop is a concurrent observer: a fresh agent that wakes every few minutes, reads the run from the outside, and rewrites the optimize loop while it runs
>
> They share one plain object, the harness: the steps the loop runs, the phases and the prompts they use, the gates and verifiers in play (alongside knobs like width and stall that were always adjustable). The optimizer reads it every round; the meta thread writes it. Same event loop, so writes land between the optimizer's awaits, with no locks and no second process.
>
> ## p
>
> ## what the meta can do
>
> Each tick it observes the tree, the scores, the live logs, GPU and host state (strictly read-only), and emits four kinds of output:
>
> - harness edits:  the real lever. A run surfaces needs specific to it: this experiment class wants its own verifier step, that one needs a particular method injected, another step turns out to be dead weight and should be cut. The meta adapts the workflow to fit, injecting steps, removing them, and rewriting the phases that run. It takes effect on the next round. The loop's shape becomes data the system changes to match what the run actually needs.
>
> - brief hints: softer; queued into the next round's brief to nudge what it tries next.
>
> - stops: when an experiment is going nowhere the meta doesn't kill it. It hands a recommendation to a separate gated enforcer that verifies, aborts, diagnoses, and discards. Detect and act stay separate; never a silent kill.
>
> - alerts: runtime problems it can't fix itself (eg a dying GPU) go to a human.
>
> We have found that having an external observer / meta agent look at the experiments and nudge it to be very effective in course correcting and catching issues
>
> ## Takeaways
>
> Dynamic workflows make coordination code instead of context. What that buys you is that: the loops becomes a first-class object, something you can read, edit, and reason about while it runs, instead of a harness you write once and hope fits every round.  The loop's own shape is one more parameter space that can be evolved.
>
> ## it's all open
>
> [evo is opensource](https://github.com/evo-hq/evo). you go through our dynamic workflow implementation [here](https://github.com/evo-hq/evo/blob/main/plugins/evo/skills/optimize/workflows/evo-optimize.js)

🔗 https://x.com/alokbishoyi97/status/2064281952631525741

---

### Reply — @Aqib__786Ai (AqibAi) · Tue Jun 09 10:31:41 +0000 2026

> This feels like a subtle but important shift.
>
> Instead of forcing the model to manage every step, orchestration becomes deterministic code while the model focuses on reasoning and decision-making.
>
> The result is more reliable systems, better observability, and agents that can scale beyond a single context window. 🚀

🔗 https://x.com/Aqib__786Ai/status/2064294356488511555

---

### Author reply — @alokbishoyi97 (Alok Bishoyi) · Tue Jun 09 11:47:04 +0000 2026

> @Aqib__786Ai Yessir. Bang on

🔗 https://x.com/alokbishoyi97/status/2064313324146495881

---

### Reply — @shrishtiprabha1 (shrishti prabhagar) · Tue Jun 09 12:08:21 +0000 2026

> @alokbishoyi97 Can you also explain token consumption of these?

🔗 https://x.com/shrishtiprabha1/status/2064318681757188478

*(no author response at capture time)*

## Source artifacts

- evo repo: [github.com/evo-hq/evo](https://github.com/evo-hq/evo)
- evo-optimize workflow source: [plugins/evo/skills/optimize/workflows/evo-optimize.js](https://github.com/evo-hq/evo/blob/main/plugins/evo/skills/optimize/workflows/evo-optimize.js)
- Anthropic dynamic workflows docs: [code.claude.com/docs/en/workflows](https://code.claude.com/docs/en/workflows)
- Thariq's launch writeup: [claude.com/blog/a-harness-for-every-task-dynamic-workflows-in-claude-code](https://claude.com/blog/a-harness-for-every-task-dynamic-workflows-in-claude-code)
