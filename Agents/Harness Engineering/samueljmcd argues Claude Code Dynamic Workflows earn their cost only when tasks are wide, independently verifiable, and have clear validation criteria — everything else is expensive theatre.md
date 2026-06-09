---
created: 2026-06-09
description: A production AI engineer's honest accounting of Claude Code Dynamic Workflows — why the verification layer and reusable JS orchestration scripts matter more than the 1,000-parallel-agent headline, how token costs compound to 50-100x at ultracode scale, and the precise conditions under which workflows are worth it.
source: https://x.com/samueljmcd/status/2064078883318825416
type: learning
---

## Key Takeaways

- The real innovation in Dynamic Workflows is not parallelism — it's the clean-context adversarial reviewer. The "1,000 parallel agents" framing is misleading: the runtime caps concurrency at 16; 1,000 is total dispatch through that pipe. What actually matters is that [[Claude Code Dynamic Workflows practical mastery maps failure modes to pattern compositions — fan-out for drift, adversarial for self-preference, tournament for taste, loop for open-ended work|a reviewer spawned from a clean context]] cannot inherit the original agent's accumulated justifications, eliminating the "confident plausibility" failure mode where single-agent self-review just agrees with itself. The caveat: both agents share the same training, so systematic blind spots remain — the clean context strips local bias, not model-level bias.

- Token costs compound faster than Anthropic's docs acknowledge. N subagent completions plus a verification layer is 2N, plus aggregation on top. The token cost chart embedded in the article illustrates the scale: a small-scope dynamic workflow (~10 agents) runs 8-15x a baseline session; `/effort ultracode` on a full codebase hits 50-100x+. This maps to exactly the cost traps described in [[Claude Code dynamic workflows write a custom JS harness per task to structurally prevent agentic laziness self-preferential bias and goal drift|Thariq Shihipar's launch post]] — vague task specs and leaving ultracode on as default are the primary ways to get an unpleasant invoice.

- The real architectural signal is the shift from conversational assistant to workflow runtime. The generated JS orchestration script, once saved to `.claude/workflows/`, is versioned infrastructure — an executable spec of how to decompose a class of task that can be re-run on next quarter's codebase. A chat history cannot do that. This is what [[Claude Code dynamic Workflows synthesize a per-task agent harness at runtime opening a third scaling axis|necmttn's third-axis framing]] calls out: generated-harness compute is a new scaling dimension orthogonal to context size and model capability.

- The decision rule is narrow but reliable: use workflows when the task scope exceeds what one agent can hold coherently AND the subtasks are independently verifiable AND there is a clear validation criterion a reviewer can check against. Wide + independent + checkable = worth it. The moment the success definition would be debated by reasonable engineers, workflows burn tokens and produce noise. Bug fixes, architecture design, open-ended exploration, and module test writing are all out of scope.

- Precision in the task spec is the primary cost control. "Improve the auth layer" produces a decomposition that diverges and wastes tokens. "Audit X, output Y, validation rule Z, no file modifications" gives the orchestrator something to work with. The quality of the generated script scales directly with how precisely the scope, output format, validation criteria, and editing policy are specified upfront — a pattern [[Claude Code Dynamic Workflows practical mastery maps failure modes to pattern compositions — fan-out for drift, adversarial for self-preference, tournament for taste, loop for open-ended work|the practitioner guide]] operationalizes as the anti-pattern checklist.

## External Resources

- [Anthropic Dynamic Workflows announcement](https://anthropic.com) — June 2nd launch of Dynamic Workflows for Claude Code

## Original Content

> [!quote]- Source Material
> *Claude Code Dynamic workflows — composed at runtime*
> ![[samueljmcd-825416-001.jpg]]
>
> **Article: Claude Code Dynamic Workflows: What's Actually Changed**
>
> Anthropic announced Dynamic Workflows for Claude Code on June 2nd, and the coverage has been predictably breathless. "Complete quarterly tasks in days." "Up to 1,000 parallel subagents." That kind of thing.
>
> The capability is real and it's a meaningful architectural shift. But the framing in most writeups skips past the parts that actually matter for anyone building production systems: how orchestration works under the hood, what it costs, and when it's a bad idea.
>
> **What's Actually New Here**
>
> Classic Claude Code is fundamentally sequential: one context window, one thread of reasoning, tasks executed turn-by-turn. That works fine for a focused coding session. It falls apart at scale, on jobs like auditing 400 routes, porting a large codebase, or running a multi-source investigation, because the single context either overflows or loses coherence across a long chain of steps.
>
> Dynamic Workflows solves this with a different execution model. Instead of Claude reasoning inside a single context, it generates a JavaScript orchestration script that describes the task decomposition, then executes that script with subagents running in parallel, each subagent getting a clean, scoped context. Intermediate results live inside the script's variables rather than in Claude's context window, so they're aggregated at the end without ever polluting the main thread.
>
> *Sequential vs. Dynamic Workflow execution model: classic Claude Code fills a single context window step-by-step; Dynamic Workflows dispatches scoped subagents in parallel with no shared context accumulation*
> ![[samueljmcd-825416-002.png]]
>
> "Parallel" has a ceiling worth knowing. The runtime caps a run at 16 subagents running concurrently and 1,000 total per run. So the work is wide, not infinite, and the breathless "1,000 parallel" framing is really 1,000 dispatched across a 16-wide pipe.
>
> The generated orchestration script is inspectable before execution. You can read the decomposition logic and approve the plan before committing tokens to it. That's the right default. Don't skip it.
>
> **The Verification Layer Is The Actually Interesting Part**
>
> Parallel execution of subagents is not new ground. Any orchestration framework can do that. What makes this worth paying attention to is the built-in verification pattern.
>
> Anthropic's design explicitly allows one subagent to review or adversarially challenge another's output. For an AI system working on a large codebase, this matters a lot. The failure mode in single-agent LLM work is confident plausibility: the model produces something that looks right and passes surface checks, but has quietly introduced a regression or made a bad assumption in step 14 of 30.
>
> > The failure mode in single-agent LLM work is confident plausibility. A reviewer spawned from a clean context doesn't carry the original agent's running justifications, so it's far less likely to rationalise a bad step into a good one.
>
> A reviewer agent that spawns from a clean context doesn't inherit the original's running justifications, so it's much less likely to rationalise the choices that produced the output. That's a real improvement over post-hoc self-review, where the model re-reads its own reasoning and agrees with itself.
>
> The caveat worth stating, before a sharp reader states it for you: both agents are the same model with the same training, so they share systematic blind spots. A clean context strips out the local bias that makes self-review weak. It doesn't hand you a genuinely independent second opinion. Treat the reviewer as a strong check, not an oracle.
>
> **Token Economics: The Honest Version**
>
> Anthropic's own docs flag that dynamic workflows "consume significantly more tokens than a typical Claude Code session." That's underselling it.
>
> Each subagent gets its own context window. That's the whole point of avoiding context overflow, but it means you're paying for N independent completions rather than one. Add a verification layer on top, and you're paying 2N. Add the aggregation step. It compounds fast.
>
> *Relative token cost — illustrative order of magnitude: single focused task = 1x; complex multi-step session = 3-5x; Dynamic Workflow small scope (~10 agents) = 8-15x; Dynamic Workflow with /effort ultracode on full codebase = 50-100x+*
> ![[samueljmcd-825416-003.png]]
>
> /effort ultracode is the mode where Claude decides for itself whether a task warrants a workflow. It combines xhigh reasoning with automatic orchestration and lasts for the session. Leaving it on for routine work is how you get a very unpleasant invoice at the end of the month. Drop back to /effort high once the heavy task is done.
>
> **Three Invocation Patterns**
>
> The feature ships with three ways to invoke it, which differ meaningfully in how much control you cede to the orchestrator.
>
> 1. /deep-research (built-in workflow). Lowest friction. Runs a multi-agent research sweep with cross-verification and returns a cited report. The orchestration is opaque; you don't write the decomposition. Fine for information gathering where the cost of a wrong decomposition is low. Not what you want for production code changes.
>
> 2. Asking Claude to create a workflow. This is the one you actually want for technical tasks. You ask Claude to run a workflow and you write the scope, the expected output format, the validation criteria, and the editing policy explicitly in the prompt. The orchestrator generates a script from that spec, which you approve before anything runs.
>
> ```
> Run a workflow to audit every API endpoint under src/routes
> for missing auth checks. For each endpoint found:
> - Log the file path and line number
> - Classify the risk level (public, needs auth, uncertain)
> - Do not modify any files, output a JSON report only
> - Verify by having a second agent cross-check each flagged route
> ```
>
> The quality of the generated script is directly proportional to how precisely you define those parameters. "Improve the auth layer" will produce a decomposition that diverges and wastes tokens. "Audit X, output Y, validation rule Z, no file modifications" gives the orchestrator something to work with.
>
> 3. /effort ultracode. Automated orchestration mode. Claude decides when to invoke workflows. High inference, high token burn, lowest manual control. Useful when you want to throw a genuinely large task at it and not micromanage the decomposition. The tradeoff is that cost predictability goes out the window.
>
> **When To Actually Use It**
>
> The honest decision rule is: does this task require broader scope than one agent can hold coherently, and is it decomposable into independently verifiable subtasks?
>
> | Task type | Use workflows? | Why |
> |---|---|---|
> | Codebase-wide security audit (auth, input validation) | Yes | Scope exceeds single context. Results from each file are independently verifiable. |
> | Large-scale migration (e.g. React 17 to 18, Express 4 to 5) | Yes | Decomposable per-file with clear pass/fail (tests green). Verification is built-in. |
> | Multi-source investigation / research synthesis | Yes | Parallel sourcing with cross-check is exactly the pattern this is designed for. |
> | Bug fix in a single file | No | Overkill. Single context session is faster and cheaper by an order of magnitude. |
> | Architecture design / open-ended exploration | No | No correct answer for agents to converge on. Subagents will diverge or confabulate. |
> | Writing tests for a new module | No | Scope is bounded. Sequential reasoning plus human review is better here. |
> | Deprecation sweep (find all usages of X across repo) | Yes | Embarrassingly parallel. Each file is independent. Low risk per agent. |
>
> The tasks where this genuinely shines share a structure: the work is wide, the subtasks are independent, and success has a clear definition the verification agent can check against. The moment you're in territory where reasonable engineers would disagree on what "done" looks like, dynamic workflows will burn tokens and produce noise.
>
> **What This Actually Signals Architecturally**
>
> The more interesting read on this feature isn't "Claude Code can now do bigger tasks." It's that Anthropic is shifting the product model for Claude Code from conversational assistant to workflow runtime.
>
> The generated JavaScript script is the key artefact here. The orchestration logic is inspectable, auditable, and already saveable: a finished run can be written to .claude/workflows/ as a custom command and re-run on any branch or project. That's a fundamentally different thing from a chat history. It's an executable spec of how to decompose a class of task.
>
> That matters because repeatability is where AI tooling in production actually earns its keep. A one-off answer from a chat session is hard to operationalise. A versioned orchestration script that you can run against next quarter's codebase is infrastructure.
>
> This abstraction layer is moving fast. The coordination logic that needed custom engineering six months ago, spawning agents via the API and stitching results back together by hand, is becoming a native feature. If you're writing that logic by hand today, the question worth asking is whether you're building something genuinely differentiated, or just doing work the platform will absorb in the next release cycle.
>
> > Practical takeaway. For teams running regular codebase hygiene tasks like auth audits, deprecation sweeps, and test-coverage gaps, dynamic workflows are worth evaluating as a scheduled job rather than an ad-hoc tool. The ROI calculation changes significantly when you're amortising the token cost over repeated execution of a stable script.
> >
> > Watch out for. Vague task specs, /effort ultracode left on as default, and using workflows for tasks with no clear validation criterion. These are the three ways to burn a lot of money and get plausible-looking output that you can't actually trust.
>
> **Where It Sits In My Current Stack**
>
> I'm running an agentic chatbot in production with a ReAct loop, context compaction, and a human-in-the-loop observability layer. The eval harness covers 100+ ground-truth queries with LLM-as-judge failure aggregation wired into CI. That's the kind of system where Dynamic Workflows would have real utility for certain tasks: running the full eval suite in parallel across prompt variants, or a codebase-wide audit of tool-call patterns.
>
> What I won't be doing is reaching for it as a default. The token cost on a system like this is non-trivial, and most of the tasks I'm dealing with day-to-day are scoped enough that a focused single-agent session with good prompting outperforms a distributed workflow on both cost and latency.
>
> The framing that resonates for me: Dynamic Workflows is what you use when you've identified a task that's genuinely too wide for one agent to hold coherently, and you've been precise enough about the success criteria that a verification agent can actually do its job. Everything else is just expensive theatre.
>
> I'm an AI engineer based in Dublin, Ireland. I write about production AI systems and the gap between AI benchmarks and real-world reliability.
>
> ---
>
> @samueljmcd — Mon Jun 08 20:45:54 +0000 2026
>
> My first article here. A few days late but I thought it would be a nice starter. Let me know what you guys think!
>
> ---
>
> Engagement: 11 likes | 0 retweets | 2 replies
> [Original post](https://x.com/samueljmcd/status/2064078883318825416)
