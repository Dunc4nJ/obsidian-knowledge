---
created: 2026-06-01
description: Claude Code's dynamic Workflows let the model write a full JavaScript orchestration script on the fly — fan out to a fleet of typed subagents, verify results, and report back — adding generated-harness compute as a third scaling axis on top of base model and thinking compute.
source: https://x.com/necmttn/status/2060180335590273355
type: framework
---

## Key Takeaways

- The fundamental shift is that the model writes the orchestration program, not just executes it. Every dynamic Workflow is a freshly synthesized conductor — plain JavaScript with four runtime globals (`agent()`, `parallel()`, `pipeline()`, `phase()/log()`) that reach back into the harness and spawn live Claudes. This makes Claude Code Workflows a generated [[the harness layer is the next hundred billion dollar AI infrastructure market not the model|harness]], not a hand-authored one — the same category as ralph, GSD, or stacked task files, but synthesized per task at runtime. See also [[Deep Agents interpreter middleware gives agents a programmable middle lane between serial tool loops and full sandboxes through explicit host-runtime bridges]] for interpreter-level orchestration as a related pattern.

- `pipeline()` is the sharpest primitive in the set. Items flow through stages with no global barrier — item A can be on stage 3 while item B is still on stage 1. Wall-clock collapses to the slowest single chain instead of the sum of every stage. `parallel()` is a barrier that waits for all results; `pipeline()` is not. Most multi-step agent work should be shaped as pipelines and isn't.

- Typed output via JSON schema is what makes fleet output composable. Pass a schema to `agent()`, and the runtime validates the response — subagents retry until they return the exact shape. This eliminates regex-against-prose and makes every subagent's output something the conductor can route, rank, or filter as structured data. [[Recursive Language Models pass context by reference through a Python REPL so subagent outputs return as variables instead of autoregressively regenerated tokens|RLMs achieve similar composability by returning subagent results as REPL variables]], not regenerated token streams.

- The model-writes-the-harness pattern adds a third scaling axis to AI coding: base model compute × thinking compute × generated harness compute. This echoes [[The Mismanaged Geniuses Hypothesis argues the next AI leap comes from training LMs to decompose not from scaling|the decomposition hypothesis]] — the bottleneck isn't raw model capability but the coordination layer that multiplies capacity across tasks. [[Claude Code's source reveals agent systems need infrastructure as a fourth layer beyond weights context and harness|Claude Code's architecture teardown]] reveals this infrastructure layer is where production agent systems actually live and die.

- The fleet pattern solves the single-agent context problem structurally: each subagent starts with a fresh context, work runs in parallel instead of one file at a time, findings are independently verified rather than taken on faith, and long tasks stop accumulating drift inside one bloated conversation. Cost is real — you pay for the whole fleet — so start scoped, learn the shape on small tasks, then graduate to migrations.

## External Resources

- [ax.necmttn.com](https://ax.necmttn.com) — local telemetry graph for coding agents that ingests every transcript so you can see what your agents actually do; built by @necmttn while reverse-engineering Claude Code's runtime traces

## Original Content

> [!quote]- Source Material
> *Article cover: "The model writes its own harness." — claude code · research preview · dynamic workflows*
> ![[necmttn-273355-001.jpg]]
>
> **@Necmttn (Necø) — Fri May 29 02:04:02 +0000 2026**
> Likes: 46 | Retweets: 8 | Replies: 2
>
> Article: Claude Code's Dynamic Workflows: the model writes its own harness
>
> Most people are sleeping on Claude Code's dynamic Workflows. It's not /goal with a bigger budget. It's not "spawn a few subagents and eyeball the output." Claude writes a full agent harness on the fly, then runs it.
>
> Hand it a big task. Claude plans the workflow, writes the orchestration script, fans the work out across tens to hundreds of subagents, validates what each one returns, and verifies the results before reporting back. The model isn't just doing the work. It's building the system that does the work, fresh, per task.
>
> Sit with that for a second. The model writes the program that controls the model.
>
> ## The primitives
>
> The orchestration script Claude writes uses a small set of building blocks:
>
> - `agent(prompt)` - spawn a subagent
> - `parallel([...])` - fan out and wait for all
> - `pipeline(items, ...stages)` - stream work through stages
> - `phase()` / `log()` - emit live progress
>
> Everything else is plain JavaScript: loops, filters, maps, conditionals. Real control flow, not a config file with a few knobs.
>
> ## Typed output is the unlock
>
> The thing that makes this usable is typed output. Pass a JSON schema to agent(), and the runtime validates the response. The subagent has to return that exact shape, retrying until it matches.
>
> No regex against walls of prose. No hoping the model formatted its answer the way you asked. Every subagent hands back structured data the script can route, rank, or filter:
>
> ```javascript
> const triaged = await parallel(issues.map((n) => () =>
>   agent(`triage issue #${n}`, { schema: TRIAGE_SCHEMA })
> ))
> ```
>
> Eleven issues become eleven agents running at once, each returning `{ priority, effort, nextStep }`. Then one more agent ranks them into a board. Typed in, typed out, no glue code in between.
>
> ## The conductor writes itself
>
> agent(), parallel(), and pipeline() aren't libraries the script imports. The runtime injects them as globals.
>
> So the script is a conductor: plain JS for control flow, with a handful of globals that reach back into the harness and spawn live Claudes. And Claude writes the conductor. It writes the program, then hands it back to the runtime to execute.
>
> ## Why this matters for codebases
>
> For code, this is the whole game. Bug hunts, migrations, audits, refactors - anything that decomposes across files or modules - stops being a single-agent slog and becomes a fleet problem.
>
> What you get over the old single-agent loop:
>
> - Each subagent starts with a fresh context
> - Work runs in parallel instead of one file at a time
> - Findings get independently verified, not taken on faith
> - Long tasks stop rotting inside one bloated conversation
>
> It's the missing /clear primitive, scaled to a fleet.
>
> ## Static trees vs. generated trees
>
> ralph, GSD, and hand-stacked .md task files are hand-written harnesses. Dynamic workflows are generated harnesses. Same category. One is pre-baked by you, the other is synthesized at runtime by the model.
>
> The sharpest primitive in that generated harness is pipeline(). Items flow through stages with no global barrier - item A can be on stage 3 while item B is still on stage 1. Wall-clock collapses to the slowest single chain instead of the sum of every stage. Most multi-step agent work should probably be shaped this way and isn't.
>
> ## The catch
>
> This isn't free magic. A dynamic workflow can use meaningfully more of your usage than a normal session, because you're paying for the whole fleet. So start scoped. Learn the shape on small tasks, then graduate to the big migrations once you trust it.
>
> ## Where this is heading
>
> AI coding is shifting from "model writes code" to "model writes the harness that coordinates models writing and verifying code." That's a new scaling axis, stacked on top of the old ones:
>
> > base model compute × thinking compute × generated harness compute
>
> None of this is documented well - I pieced most of it together by reading the runtime's own traces. That's what I'm building: ax, a local telemetry graph for your coding agents. It ingests every transcript so you can see what your agents actually do. → ax.necmttn.com
>
> [Original post](https://x.com/necmttn/status/2060180335590273355)
