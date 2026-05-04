---
created: 2026-05-04
description: Grey Haven's autocontext is a recursive self-improving harness that runs Competitor/Analyst/Coach/Architect/Curator role pipelines, gates promotions through tournaments and curator review, and persists scenario-keyed playbooks, hints, tools, and SQLite-indexed snapshots that the next run inherits automatically.
source: https://x.com/JayScambler/status/2050307709530984787
type: framework
---

## Key Takeaways

- The unit of improvement is the *scenario*, not the prompt — autocontext takes a goal in plain language, generates an evaluable scenario from it, then runs a five-role pipeline (Competitor proposes, Analyst diagnoses, Coach drafts a playbook patch, Architect proposes new tools, Curator decides accept/reject/merge) until a tournament-gated quality threshold is hit. This is the actionable distinction from prompt optimizers like DSPy/TextGrad/GEPA: those optimize the string, autocontext optimizes the *operating procedure* and ships transferable artifacts. Pairs naturally with [[GEPA prompt optimizer beats reinforcement learning with 35x fewer rollouts by reflecting on natural-language execution traces]] (which can be slotted in as a sub-optimizer for a single role).
- Cross-run inheritance is by **scenario name string only** — `GenerationRunner._startup` checks for `playbook.md`; if absent and `cross_run_inheritance=true`, it queries `get_best_knowledge_snapshot(scenario_name)` from SQLite and restores the highest-`best_score` snapshot. There is no content-hash matching, no fuzzy scenario discovery, no embedding lookup. This is a deliberate simplification — scenarios are the primary key and the user controls the namespace. Compare to [[memento-skills turns executable skill folders into evolving non-parametric memory that lets frozen LLMs learn continuously from deployment]] which keys skills by behaviour-aligned routers instead.
- The architecture treats inheritable knowledge as **versioned markdown plus SQLite metadata**, not as embeddings or model weights. `playbook.md` is rewritten in full each successful round (last 5 versions retained via `VersionedFileStore`); `hints.md` is appended; `tools/` holds Architect-generated helpers; `events.ndjson` is the synchronous trace; SQLite indexes runs/generations/matches/agent_outputs/role_metrics/knowledge_snapshots for fast trajectory queries. This is the same "files are the substrate, DB is the index" pattern as [[a file system is not all you need - databases beat markdown for agent context provenance and governance]] applied to agent self-improvement specifically.
- Per-role provider/model selection (`AUTOCONTEXT_MODEL_COMPETITOR`, `AUTOCONTEXT_MODEL_ARCHITECT`, etc.) is the economic primitive that makes the loop affordable: cheap models for high-volume Competitor turns, frontier models for low-volume Coach/Architect/Curator/Judge decisions. Judge configuration is deliberately separate from agent provider so the evaluator can be at least as strong as the generator — Jay's framing is "if your judge is weaker than your generator, you are grading calculus exams with an algebra student." Aligns with the harness-engineering thesis in [[LangChain Deep Agents adds per-model harness profiles because each provider's prompting guide demands different tools and middleware]].
- Pi integration is shockingly simple: `runtimes/pi_cli.py:110` literally calls `subprocess.run([pi, "--print", "--model", model, prompt], ...)` per role turn. autocontext is the loop, Pi is the agent execution. This validates the [[agents need a harness not a framework because durable event-driven infrastructure already solves retry routing and state]] thesis in production — the loop owner doesn't need to own the agent runtime.
- Termination is multi-criteria, which matters more than it sounds: `TerminationReason` covers `threshold_met`, `max_rounds`, `plateau_stall` (epsilon=0.01 over 2 rounds), `unchanged_output`, and 3 consecutive judge failures. Most "self-improvement" demos only check max_rounds and overshoot; explicit plateau and stagnation gates make the loop honest about when it has converged. Same problem space as [[Cognition finds multi-agent systems work only when writes stay single-threaded and additional agents contribute intelligence not actions]] — gates are how you keep multi-role systems from drifting.
- Documented surprise: README references `trace.jsonl` but the actual file written is `events.ndjson` via `EventStreamEmitter`, synchronously appended with no buffer. Worth knowing if you ever try to tail one.

## External Resources

- [autocontext repo](https://github.com/greyhaven-ai/autocontext) — Apache 2.0, Python `autocontext==0.5.0` + TypeScript `autoctx@0.5.0` + Pi `pi-autocontext@0.2.4`
- [Pi (badlogic/pi-mono coding-agent)](https://github.com/badlogic/pi-mono/tree/main/packages/coding-agent) — local coding agent with self-handled auth, used by autocontext via `pi --print` subprocess invocation
- [Hermes Agent (Nous Research)](https://github.com/nousresearch/hermes-agent) — self-improving agent with persistent memory, toolsets, messaging; can drive autocontext as the operator layer
- [Grey Haven](https://github.com/greyhaven-ai) — the org behind autocontext
- [autoctx on npm](https://www.npmjs.com/package/autoctx) — TypeScript CLI
- [pi-autocontext on npm](https://www.npmjs.com/package/pi-autocontext) — Pi extension package

## Original Content

> @JayScambler — 2026-05-01
>
> **Article: autocontext: Running the Loop and the Big 0.5.0 Release**
>
> In the initial autocontext article I explained the core idea: agents should not start from zero every time. autocontext gives them a recursive improvement loop, a set of roles that test and refine each run, and local artifacts the next run can inherit: traces, playbooks, reports, and validated knowledge.
>
> The most common response was some version of "okay cool, but how do I actually use it?"
>
> So let's do that, starting with the easiest possible version.
>
> ## The Shortcut: Just Let Your Agent Do It
>
> The easiest way to interact with autocontext is to point your agent at the repo and tell it to get to work. If you're already working with a coding agent, such as Claude Code, Codex, Pi, Hermes, OpenClaw, Cursor, or whatever else you don't really need to read the rest of this article. Your agent can read it for you. And I bet if you've bookmarked this X Article that's exactly what you plan to do.
>
> Give it the repo link and describe your problem:
>
> ```plaintext
> Use https://github.com/greyhaven-ai/autocontext to build a self-improving
> process that triages incoming security incidents, classifies severity,
> identifies affected systems, and produces structured postmortems with
> root cause analysis. Install it, set it up, and start running improvement
> rounds until the output quality stabilizes.
> ```
>
> That's it. That's the point. When the agent is finished it should produce a
>
> The agent reads the README, the integration docs, and the examples. It installs autocontext==0.5.0 for Python or autoctx@0.5.0 for TypeScript, invokes the autoctx CLI, picks a provider, configures the environment, and starts running the loop. You described the problem. The agent figures out the tooling. Important detail: the npm packages are [autoctx](https://www.npmjs.com/package/autoctx) and [pi-autocontext](https://www.npmjs.com/package/pi-autocontext); npm autocontext is unrelated (we are actively trying to acquire it. Please help npm lol. Prime opportunity for slopsquatting us).
>
> This works because autocontext was designed for agent consumption. The autoctx CLI is the default integration surface for external agents because it is text, composable, uses explicit exit codes, and keeps stdout and stderr machine-usable. JSON output is there when you need it and the command line is the simple default.
>
> You do not need to know the flags. You do not need to know the env vars. You do not even need to know which provider to use. The agent will figure that out. Your job is to describe what "better" looks like for your problem and then let the agent improve. The result for the run above will look something like this:
>
> *Sample agent run output: 10 improvement rounds stabilizing at judge=1.0000 / checklist=1.0000 by round 8*
> ![[jayscambler-984787-001.jpg]]
>
> ```bash
> Done.
>
> Installed/setup:
>  - Local editable install
>  - Added reusable runner
>  - Added custom scenario config
>
>  Run command used:
>
>  bash
>    cd autocontext/autocontext
>    uv run python scripts/run_security_incident_improvement.py \
>      --min-rounds 10 \
>      --max-rounds 12 \
>      --threshold 0.98
>
>
> It ran 10 autocontext improvement rounds and stabilized at rounds 8–10:
> judge=1.0000, checklist=1.0000, range=0.0000
>
>    ┌─────────────────────────────────────────────────────────────────┐
>    │ 1.0 ┤                                       ···●·····●·····●    │
>    │ 0.9 ┤                             ·○·····●··                    │
>    │ 0.8 ┤                          ····◆···                         │
>    │ 0.7 ┤                      ··●··                                │
>    │ 0.6 ┤         ···○·····○····                                    │
>    │ 0.5 ┤      ○·· ··◆·····◆·                                       │
>    │ 0.4 ┤     ·◆···                                                 │
>    │ 0.3 ┤    ··                                                     │
>    │ 0.2 ┤  ··                                                       │
>    │ 0.1 ┤ ··                                                        │
>    │ 0.0 ┤●                                                          │
>    │      └──────────────────────────────────────────────────────────│
>    │      1     2     3     4     5     6     7     8     9     10   │
>    └─────────────────────────────────────────────────────────────────┘
>
>     Legend: ◆ judge score   ○ checklist score   ● both
>
> Round scores :
>
>  r01 judge 0.0000 [░░░░░░░░░░░░░░░░░░░░░░░░░░░░░░] checklist 0.0000
>  r02 judge 0.3966 [████████████░░░░░░░░░░░░░░░░░░] checklist 0.5000
>  r03 judge 0.5241 [████████████████░░░░░░░░░░░░░░] checklist 0.5714
>  r04 judge 0.5241 [████████████████░░░░░░░░░░░░░░] checklist 0.5714
>  r05 judge 0.6726 [████████████████████░░░░░░░░░░] checklist 0.7143
>  r06 judge 0.8256 [█████████████████████████░░░░░] checklist 0.8571
>  r07 judge 0.8676 [██████████████████████████░░░░] checklist 0.9286
>  r08 judge 1.0000 [██████████████████████████████] checklist 1.0000
>  r09 judge 1.0000 [██████████████████████████████] checklist 1.0000
>  r10 judge 1.0000 [██████████████████████████████] checklist 1.0000
> ```
>
> If you want to understand what is happening under the hood or if you want more control over how the loop runs keep reading. But if you just want to start the paragraphs above are the whole story. Just sit back and let your agent figure it out.
>
> ## Other Paths (For When You Want Control)
>
> Under the hood, autocontext does not care how you invoke it. The loop is the same whether you are typing commands in a terminal, routing through Pi, or letting something like Hermes Agent drive the workflow. What changes is how much capability your runner has.
>
> We're just gonna show a few paths in this article:
>
> 1. Direct harness: the autoctx CLI, available in Python and TypeScript. The CLI is the main integration surface, and autoctx solve is the current starting point in both runtimes.
>
> 2. [Pi](https://github.com/badlogic/pi-mono/tree/main/packages/coding-agent): the fastest no-key path when you already have Pi set up. Pi handles auth, autocontext drives the recursive loop, and persistent Pi RPC is available for session-based workflows. @badlogicgames @mitsuhiko
>
> 3. [Hermes Agent](https://github.com/nousresearch/hermes-agent): the self-improving AI agent built by Nous Research, with persistent memory, toolsets, messaging, and a built-in learning loop. The agent does not just run the loop. It can also use its own runtime context while doing it. @NousResearch  @Teknium
>
> ## Method 1: Direct Harness
>
> This is autocontext with the guardrails off. You run the CLI, you read the output, and you decide what happens next. No agent middleware. No framework opinions about how you should work.
>
> The autoctx CLI is available in both Python and TypeScript. The important command is autoctx solve: describe the goal in plain language and let the harness generate the scenario, run the loop, keep what worked, and write the trace and artifacts locally.
>
> Setup
>
> ```bash
> # Python (with uv)
> uv tool install autocontext==0.5.0
> # TypeScript (with bun)
> bun add -g autoctx@0.5.0
> ```
>
> The Real Starting Point: Describe Your Problem
>
> The best way to actually use autocontext is just by telling it what you want to get better at.
>
> ```bash
> AUTOCONTEXT_AGENT_PROVIDER=pi \
> autoctx solve \
>   "A process that triages incoming security incidents, \
>   classifies severity, identifies affected systems, and produces \
>   structured postmortems with root cause analysis." \
>   --iterations 3 --json
> ```
>
> You described a problem in plain language. autocontext generates a scenario spec from that description and starts the improvement loop. The Competitor proposes an approach. The Analyst explains outcomes. The Coach updates the playbook and hints. The Architect proposes tools or harness changes. The Curator gates what knowledge persists. Each generation builds on validated lessons from the last.
>
> No YAML to write for the first run. No scoring function to implement before you can start. No scenario files to scaffold by hand. Describe what you want, and the system turns that into an evaluable loop, then iterates toward it.
>
> Working with Runs
>
> Everything speaks JSON when you ask it to:
>
> ```bash
> # Check progress
> uv run autoctx status <run-id> --json
>
> # List all runs
> uv run autoctx list --json
>
> # Replay a specific generation to see what happened
> uv run autoctx replay <run-id> --generation 2
>
> # Export the strategy package
> uv run autoctx export --scenario my_task --output strategy_pkg.json --json
> ```
>
> The --json flag is important. It is not just for pretty-printing. It is the contract that makes autocontext composable with other tools. Every command returns structured output that a script, agent, or pipeline can parse.
>
> What Comes Back
>
> autocontext writes inspectable local state, not just terminal output:
>
> *Run and knowledge directory layout — runs/ holds per-generation traces and artifacts; knowledge/ holds accumulated playbooks, hints, and tools per scenario*
> ![[jayscambler-984787-002.jpg]]
>
> ```markdown
> runs/<run_id>/
> ├── trace.jsonl
> ├── generations/
> │   ├── gen_1/
> │   │   ├── strategy.json
> │   │   ├── analysis.md
> │   │   └── score.json
> │   ├── gen_2/ ...
> ├── report.md
> └── artifacts/
>
> knowledge/<scenario>/
> ├── playbook.md
> ├── hints.md
> └── tools/
> ```
>
> Runs live in runs/. Accumulated knowledge lives in knowledge/. Indexed metadata lives in SQLite. That makes the loop inspectable, diffable, and portable.
>
> Per-Role Model Selection
>
> Not every role in the pipeline needs the same model. The Competitor grinding through the task does not need Claude 4.7-level reasoning, but your Architect planning the approach might:
>
> ```bash
> AUTOCONTEXT_MODEL_COMPETITOR=claude-sonnet-4-6
> AUTOCONTEXT_MODEL_ANALYST=claude-opus-4-7
> AUTOCONTEXT_MODEL_COACH=claude-sonnet-4-6
> AUTOCONTEXT_MODEL_ARCHITECT=claude-opus-4-7
> AUTOCONTEXT_MODEL_CURATOR=claude-opus-4-7
> ```
>
> You can also set per-role providers, credentials, and endpoints, so your Architect can run on Anthropic while your Competitor runs through a separate OpenAI-compatible gateway:
>
> ```bash
> AUTOCONTEXT_AGENT_PROVIDER=anthropic
> ANTHROPIC_API_KEY=...
> AUTOCONTEXT_COMPETITOR_PROVIDER=openai-compatible
> AUTOCONTEXT_COMPETITOR_API_KEY=...
> AUTOCONTEXT_COMPETITOR_BASE_URL=http://localhost:8000/v1
> AUTOCONTEXT_ARCHITECT_PROVIDER=anthropic
> ```
>
> The economics matter. Competitor turns run frequently and process large volumes, so cheaper models keep costs sane. Coach, Architect, and Curator make higher-leverage decisions where a stronger model can pay for itself.
>
> Judge Configuration
>
> The judge has its own independent configuration:
>
> ```bash
> AUTOCONTEXT_JUDGE_PROVIDER=anthropic
> ANTHROPIC_API_KEY=...
> AUTOCONTEXT_JUDGE_MODEL=claude-opus-4-7
> ```
>
> For OpenAI-compatible judges:
>
> ```bash
> AUTOCONTEXT_JUDGE_PROVIDER=openai-compatible
> AUTOCONTEXT_JUDGE_API_KEY=...
> AUTOCONTEXT_JUDGE_BASE_URL=http://localhost:8000/v1
> AUTOCONTEXT_JUDGE_MODEL=judge-model
> ```
>
> Keep judge configuration separate from the agent provider on purpose. You want your evaluator to be at least as capable as your generator, ideally more so. A common pattern is to generate with a cheaper model or a fine-tuned model, then judge with Claude 4.7 or GPT-5.5. If your judge is weaker than your generator, you are grading calculus exams with an algebra student.
>
> Operator Loops
>
> The operator loop is runnable now. The practical question is judgment: when should an agent act, ask for clarification, or escalate to a human operator? Specs can include description, environment_description, initial_state_description, escalation_policy, success_criteria, failure_modes, actions, and max_steps.
>
> Python SDK
>
> For when you need the loop inside your own Python code:
>
> ```python
> from autocontext import AutoContext
>
> client = AutoContext(db_path="runs/autocontext.sqlite3")
>
> # Export a portable strategy package
> package = client.export_package("my_scenario")
> The SDK gives you typed Python access when you need it, but the CLI is still the default integration surface for agents and scripts.
> ```
>
> When to Use Direct Harness
>
> You want full control and no agent middleware. You are generating training data for frontier-to-local distillation. You want local traces, reports, and playbooks you can inspect directly. Or you are building the loop into your own code or pipeline.
>
> ## Method 2: Through Pi
>
> Pi is the second path: use Pi as the runtime for the agent step while autocontext keeps the outer improvement loop.
>
> This is the part worth teaching first. Once autocontext==0.5.0 is installed, run the normal autoctx CLI and set Pi as the provider:
>
> ```bash
> export AUTOCONTEXT_AGENT_PROVIDER=pi
>
> autoctx solve \
>   "A process that triages incoming security incidents, classifies severity, identifies affected systems, and produces structured postmortems with root cause analysis." \
>   --iterations 3 --json
> ```
>
> Under the hood, autocontext invokes Pi's print-oriented runtime with pi --print for the agent turn, captures the result, scores it, writes the trace and artifacts, then decides whether another pass is needed.
>
> That is the clean mental model: Pi handles the agent execution. autocontext handles the loop.
>
> If you want the Pi-side extension, just install it into Pi:
>
> ```bash
> pi install npm:pi-autocontext@0.2.4
> ```
>
> That package is loaded by Pi and gives Pi autocontext-related tools, skills, and prompts. It is not installed by uv, and it is separate from the Python autocontext==0.5.0 package and the npm autoctx@0.5.0 package.
>
> For this article, though, the useful point is simpler than the package model: Pi is a runtime autocontext can use when you want terminal-first agent execution without rebuilding auth and model plumbing.
>
> ## Method 3: Through Hermes Agent
>
> Hermes Agent is the third path and honestly the one I would start with if I wanted an operator workflow instead of a one off task especially if you already have it setup.
>
> Hermes Agent can read files, run commands, use tools, remember prior work, spawn subagents, and work from Slack or the terminal.
>
> Like I mention earlier you can basically just tell Hermes something like this direcly from your preferred channel (Telegram, Slack, Discord, etc.):
>
> ```bash
> Use https://github.com/greyhaven-ai/autocontext to build a self-improving
> operations agent that monitors deployment health, detects anomalies in error
> rates and latency, and produces structured incident reports with recommended
> remediation steps. Set up the autocontext skill, run autoctx solve with JSON
> output, inspect the artifacts, and summarize what improved across iterations.
> ```
>
> Hermes can then do the operator work around the loop: read the repo, install the package, export or refresh the Hermes-facing skill, run the CLI, inspect the JSON output, inspect the generated reports and traces, and decide what to do next.
>
> The commands are plain CLI commands:
>
> ```bash
> # Give Hermes local operating instructions for autocontext
> autoctx hermes export-skill --output ~/.hermes/skills/autocontext/SKILL.md --json
>
> # Run the loop
> autoctx solve \
>   "An operations agent that monitors deployment health, detects anomalies in error rates and latency, and produces structured incident reports with recommended remediation steps." \
>   --iterations 3 --json
>
> # Optional: inspect Hermes-facing context and Curator reports
> autoctx hermes inspect --json
> ```
>
> Hermes is the operator layer. autocontext is the bounded recursive loop. The skill gives Hermes the local playbook for using the loop correctly.
>
> The path is straightforward: point Hermes at autocontext, let it set up the skill, run the CLI, read the artifacts, and keep going.
>
> When to Use Hermes
>
> Use Hermes when you want the agent itself, not just the underlying model endpoint, to participate in the workflow. Hermes is the better fit when you want persistent memory, procedural skills, toolsets, terminal backends, messaging integrations, and subagent delegation in addition to the model call itself.
>
> ## Picking Your Path
>
> The harness is the engine. Pi and Hermes are vehicles built for different terrain. Everything else in this article is a knob or interface for more control. If your problem is code, Pi gets you there faster. If your problem is everything else, including research, operations, content, and multi-step workflows, Hermes Agent is a very capable runtime. And if you just want to understand the loop and build from scratch, the direct harness hides nothing.
>
> autocontext is open source under Apache 2.0. Built by [Grey Haven](https://github.com/greyhaven-ai).
>
> *Closing graphic from the article*
> ![[jayscambler-984787-003.jpg]]
>
> ## What's Coming
>
> The open-source loop runs on your infrastructure, with your keys, your data never leaving your environment. That stays.
>
> In order to continue to support our work we are we are actively considering building two things on top of it.
>
> autocontext Cloud: a hosted control plane for teams who want the improvement loop without the infrastructure. Trace explorer, failure clustering, candidate comparisons, promotion workflows, cost reporting, and team management. Auth, tenancy, and data isolation built in from the start.
>
> autocontext Box: a turnkey on-premises appliance for enterprises that need data residency but don't want to spec out the hardware stack themselves. The loop, the models, the storage, and the trace surfaces, all pre-configured. Plug it in, point your agents at it, and the knowledge stays inside your walls. No cloud dependency, no data leaving the building, no GPU procurement odyssey.
>
> The recursive loop stays the same. The hosted layer makes it a shared system instead of a solo instrument. The box makes it a facility.
>
> If you have interest, thoughts, or want to help with Cloud and/or Box, DM me.
>
> Engagement: 85 likes | 13 retweets | 4 replies
> [Original post](https://x.com/JayScambler/status/2050307709530984787)
