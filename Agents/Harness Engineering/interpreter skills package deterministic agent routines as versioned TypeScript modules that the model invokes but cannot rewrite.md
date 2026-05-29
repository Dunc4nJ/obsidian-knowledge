---
created: 2026-05-29
description: Hunter Lovell's "Building workflows for agents with Skills + Interpreters" — interpreter skills extend the standard skills format with a TypeScript module the agent can import and execute inside the interpreter, letting the deterministic part of a routine live in code while the model retains control over when to invoke it and what to do with the result.
source: https://x.com/huntlovell/status/2060399973506924612
type: synthesis
---

# Interpreter skills package deterministic agent routines as versioned TypeScript modules that the model invokes but cannot rewrite

## Key Takeaways

- **Interpreter skills are the "discretion on the outside, determinism on the inside" pattern** — A normal skill gives instructions the agent interprets and may carry out inconsistently. An interpreter skill adds a TypeScript module the agent imports into the [[Deep Agents interpreter middleware gives agents a programmable middle lane between serial tool loops and full sandboxes through explicit host-runtime bridges|QuickJS interpreter]] alongside those instructions. The model still decides whether the skill applies, which inputs to pass, and what to do with the result — but the procedure itself is frozen in code that can be reviewed, tested, and versioned independently of the prompt.

- **The unit of distribution stays the same: SKILL.md + optional index.ts** — Progressive disclosure is unchanged. The agent first sees a compact skill list, loads the full SKILL.md only when the task matches, and then the SKILL.md points the agent to `@/skills/<name>` for import. This means interpreter skills compose with the existing skills ecosystem without requiring a new discovery or loading mechanism. The `metadata.module` front-matter field is the only structural addition.

- **Interpreter skills solve the evaluation brittleness of prompt-only procedure following** — With instructions alone, evaluation questions are fuzzy ("did it generally stay on track?"). With interpreter skills the questions become binary: did the agent call the expected function? Did it pass expected inputs? Did the function return the expected shape? This shift also eliminates a class of instruction-negotiation failures where the agent treats a mid-task detour as part of the same procedure rather than as an interruption.

- **Fan-out routines that require hundreds of subagents are the canonical use case** — The repo-triage example spawns one subagent per open issue/PR/discussion to produce condensed descriptions, then feeds a second subagent layer to cluster them. Running that routine inside a module keeps the 300-item fan-out instrumented by code rather than by the model tracking every partial step in context. This directly addresses [[Deep Agents interpreter middleware gives agents a programmable middle lane between serial tool loops and full sandboxes through explicit host-runtime bridges|context anxiety]] — the model hands off the bookkeeping to the runtime state rather than carrying it across hundreds of turns.

- **Interpreter state beats both filesystem and message history for task-scoped intermediate state** — The module exposes typed operations (`parseCsv`, `joinTables`, `validateRows`, `groupBy`) that keep values as live TypeScript objects. Compared to writing every intermediate result to a file (forced serialization) or returning it to model context (token cost), interpreter state gives the agent a pliable workspace where the skill author controls what "join" or "validate" means across all invocations.

- **Interpreter skills are the mechanism for "best known routine" distribution** — When the same agent task is run repeatedly, the model may find several valid approaches; for many operational tasks the desired behavior is not flexibility but repeatability. Packaging the routine as a skill module lets organizations version-control, code-review, and share agent procedures the same way they share libraries — the Factory plugins ecosystem uses the same SKILL.md-as-distribution-unit pattern for [[Factory plugins marketplace uses a git-native catalog with SKILL.md files as the primary distribution unit for agent capabilities|catalog-based discovery]].

## External Resources

- [Deep Agents interpreter docs](https://docs.langchain.com/oss/python/deepagents/interpreters) — QuickJS setup and interpreter middleware
- [Deep Agents interpreter skills docs](https://docs.langchain.com/oss/python/deepagents/skills#use-interpreter-skills) — packaging + module loading
- [Repo triage trace (LangSmith)](https://smith.langchain.com/public/c869be73-f311-48cd-ac10-6834e65b0f42/r?scroll_to=output) — live trace of the github-triage skill fanning out to hundreds of subagents
- [Repo triage report (Gist)](https://gist.github.com/hntrl/3008504cf4cb69cc7f36fda93dc2be35) — sample output produced by the triage routine
- [Deep Agents Python](https://github.com/langchain-ai/deepagents) / [TypeScript](https://github.com/langchain-ai/deepagentsjs) — OSS harness

## Original Content

> [!quote]- Source thread — Hunter Lovell, "Building workflows for agents with Skills + Interpreters" (X, 2026-05-29)
>
> ![[huntlovell-924612-001.jpg]]
> ![[huntlovell-924612-002.jpg]]
> ![[huntlovell-924612-003.jpg]]
> ![[huntlovell-924612-004.jpg]]
> ![[huntlovell-924612-005.jpg]]
>
> **@huntlovell (Hunter Lovell):**
>
> 📰 Building workflows for agents with Skills + Interpreters
>
> TL;DR We're experimenting with interpreter skills: an extension to agent skills that lets you include a TypeScript module with a skill. The agent can import and run the skill code inside an interpreter when the behavior applies like you would with a workflow. Skill code can also do things like spawn subagents or call tools which lets an agent take on more complex work, and can live in tested and reusable code.
>
> ---
>
> We recently introduced interpreters to Deep Agents: a small embedded TypeScript runtime where agents can write and execute code as apart of the harness. Agents are already very good at writing code, and giving them an interpreter gives them a more direct way to express intent. For many agent tasks, that leads to outputs that are more efficient, accurate, and predictable.
>
> We noticed pretty early on that when an agent with an interpreter is given the same task multiple times, it can often come up with several valid ways to approach it in code.
>
> That isn't always bad- sometimes the whole point of an agent is to adapt. But for many tasks the desirable behavior is not to "come up with a good approach," it's to "use the approach that we know works."
>
> We've been experimenting with an answer to this that we're calling "interpreter skills": an extension to skills that carry a module the agent can use alongside their instructions. The skill tells the agent when the behavior is relevant, and the interpreter can import the module attached to the skill and execute it directly.
>
> ```markdown
> ---
> name: github-triage
> description: Use this skill to triage GitHub issues, pull requests, and discussions.
> metadata:
>   module: ./index.ts
> ---
>
> Use this skill when a user asks for repository triage.
>
> Import the module using the interpreter and call `triage(repo, options)`.
>
> Usage:
>
> ‵‵‵ts
> const { triage } = await import("@/skills/github-triage");
>
> const result = await triage("langchain-ai/deepagents", {
>   issues: true,
>   prs: true,
> });
>
> result.toMarkdown();
> ‵‵‵
> ```
>
> SKILL.md is how the agent discovers the behavior. index.ts is what the interpreter can execute. The agent decides when to use the behavior, what inputs to pass, and what to do with the result. The interpreter handles the actual execution of code.
>
> ## Remind me what skills are again?
>
> Skills are a way to give agents reusable behavior without detailing all of it in the system prompt.
>
> A skill is usually a directory with a SKILL.md file. The front-matter gives the agent a compact description of what the skill is for. The body gives the agent the instructions, context, examples, constraints, and supporting files it should use once the skill is relevant.
>
> What makes skills work is a mechanism called "progressive disclosure". The agent does not need every skill in context all the time. It can first see a short list of available skills, decide which ones match the task, and then read in the full SKILL.md only when needed.
>
> That makes skills a great distribution unit for agent behavior. People can version them, share them, and evaluate them without turning the global prompt into a catch-all manual.
>
> But normal skills still mostly work through instructions. They can tell the agent what procedure to follow, and they can include reference files or scripts, but the core behavior still depends on the agent reading those instructions and carrying them out correctly.
>
> ## What's an interpreter?
>
> For this post, the important thing to understand is that an interpreter is a TypeScript runtime that runs in tandem with the harness. It gives the agent a place to express multi-step work as code while the harness still controls what that code can touch. (If you're curious to learn more, go read the writeup on interpreters.)
>
> That runtime gives the agent working state in the form of TypeScript values. Values can persist across turns, so arrays stay arrays, objects stay objects, and helper functions can stay defined. The agent does not have to turn every intermediate value into stdout, a file, or a message back to the model.
>
> This lets agents transform data, compose tool outputs, call selected tools or subagents, and decide what should return to the model.
>
> Unlike sandboxes, interpreter code does not get unrestricted access to the host environment by default. Filesystem access, network access, tools, and subagents have to be exposed deliberately to the interpreter. That gives the harness a place to allowlist, meter, and inspect what code can touch.
>
> ## What's an interpreter skill?
>
> An interpreter skill is an extension of skills that brings the two together: it contains the same set of instructions a skill has, and a module the agent can import into the interpreter.
>
> SKILL.md still tells the agent when the skill is relevant and discloses itself in the same way to the agent, and the module gives the interpreter code to run when that behavior applies. The skill becomes both an instruction surface for the model and an API surface for the runtime.
>
> The basic shape is the same one from the opening example. SKILL.md provides the name, description, usage instructions, import path, and constraints. index.ts exports the helpers or workflows that define the behavior in code:
>
> ```typescript
> // skills/table-cleanup/index.ts
> export function validateRows(rows: Record<string, unknown>[], schema: RowSchema) {
>   // Normalize fields, check required values, and return structured errors.
>   // (this is code you would write as apart of the skill)
> }
> ```
>
> When the skill applies, the agent can import the module and call it:
>
> ```typescript
> const { validateRows } = await import("@/skills/table-cleanup");
>
> const errors = validateRows(rows, invoiceSchema);
> ```
>
> This changes what a skill can guarantee:
>
> - A normal skill says: here are instructions for how to do this task. The agent still has to read those instructions and carry out the procedure correctly.
>
> - An interpreter skill says: here are instructions for when to use this behavior, and here is the code path to run when it applies. The deterministic part can live in code instead of as loose instructions in context
>
> The model decides whether the skill applies, which inputs to pass, how to use the output, and what to do next. The module defines how procedures should actually be ran.
>
> Because interpreter code can interact with the harness, this means that you can do things like spawn subagents from within the skill code programmatically.
>
> ## Example: Repo Triage
>
> One way that we're using this: github repo triage. The user can ask the agent to triage a repository:
>
> > "Please triage all the issues in langchain-ai/deepagents"
>
> Instead of reconstructing the triage process from prompt instructions, the agent imports the skill module and calls a function:
>
> ```typescript
> const { triage } = await import("@/skills/github-triage");
>
> const result = await triage("langchain-ai/deepagents", {
>   issues: true,
>   prs: true,
>   discussions: true,
> });
> ```
>
> When this gets called, the workflow:
>
> - fetches all open items from github (as specified by the agent in the options)
> - spawns a subagent for each item to create a more condensed description
> - drops the subagents response into a queue
> - consumes the queue one at a time where a subagent determines if the item should be put in an existing cluster, or if it should create a new cluster
>
> In practice this routine fans out to hundreds of different subagents. Its also the kind of routine where you want the procedure to be fixed, even if the inputs are chosen dynamically.
>
> - Here's [the trace](https://smith.langchain.com/public/c869be73-f311-48cd-ac10-6834e65b0f42/r?scroll_to=output) showing how the agent works through the routine
> - Here's [the report](https://gist.github.com/hntrl/3008504cf4cb69cc7f36fda93dc2be35) it outputs
>
> The result value is also part of the API. It can give the agent structured data about the run, and it can expose a rendering helper for presentation:
>
> ```typescript
> result.clusters;
> result.unassigned;
> result.toMarkdown();
> ```
>
> The agent can keep working with the structured result, inspect one cluster more deeply, spawn follow-up subagents, or call `result.toMarkdown()` when it needs a compact model-friendly report.
>
> With a task like this, models tend to lose coherence over time. Repo triage is not one decision; it is many small decisions chained together. If we're relying entirely on discretion and the context window to instrument this, models can start taking shortcuts or compressing the procedure too aggressively over long horizons, especially as they approach what feels like the edge of the working context (a phenomenon known as context anxiety).
>
> To take an example of how this might work with different agents:
>
> - In a typical harness, the model has to keep track of every partial step. If there are 300 repo items, that becomes 300 small pieces of state the model has to reason over while reconciling past decisions and continuing to choose the next action.
>
> - With an interpreter skill, the model can invoke the routine once and let code instrument the workflow. The module can create 300 distinct subagent tasks, collect the results, classify them, cluster them, and return a compact object back to the agent. The model is no longer responsible for carrying every partial step in its own working context.
>
> ## Using skills as workflows
>
> When coding agents started getting popular, the default mental model for agents also shifted.
>
> The previous generation of agents were more workflow-style. Developers explicitly defined the sequence of steps the agent should follow ahead of time: reliability came from pre-defining the execution path.
>
> Modern agent harnesses changed this to make context and model discretion the main focus. The model decides what to do next based on the current context. Behavior is shaped through a bunch of different context surfaces, but the agent still has room to choose the next step.
>
> That interface is easier for many people to reason about. Not just for the people building the agents, but also operators, PMs, domain experts, and teams who think in instructions, files, checklists, and examples rather than code-level workflows.
>
> But the need for deterministic agent routines never went away. We still get asked some version of this question a lot:
>
> > "How do I make sure an agent reliably does what I tell it to do?"
>
> In those cases, people need to know more than whether the final answer looked plausible: they need to know whether the required procedure ran, whether it ran with the right inputs, and whether it completed fully before the agent moved on.
>
> Prompt-only procedure following is brittle in this way. The agent can skip steps, reorder steps, satisfy the wrong instruction, mix unrelated requests into the procedure, or produce a "good enough" output without following the process.
>
> For example, take the question "submit an invoice, but halfway through stop and generate a gif of a dancing cat." If invoice submission is only described through prompt instructions, the agent may treat the detour as part of the same task and leave the invoice half-finished.
>
> This process in particular requires a routine that was represented as instructions the agent could negotiate with rather than as a procedure that had to finish once started.
>
> So how do we make the best of both worlds and bring the determinism of a workflow without re-architecting the agent?
>
> Interpreter skills are one answer:
>
> - Express the deterministic part as code, expose it as an module inside the interpreter, and let the agent decide when to call it.
> - Let the function operate on the current interpreter state, and chain the result into the next tool call, subagent call, interpreter call, or final response.
>
> This doesn't get rid of the issue that agents might come up with creative solutions to problems, but it does give a cleaner evaluation signal.
>
> - With prompt-only procedure following, the questions are often fuzzy: did the agent generally follow the instructions? Did it seem to stay on track? Did the final answer look plausible?
> - With an interpreter skill, issues become more identifiable: did the agent call the expected function? Did it pass the expected inputs? Did the function return the expected output shape?
>
> ## Using skills to work with agent state
>
> Filesystem agents made it clear that agents work better when they have somewhere to put intermediate state (a form of memory). A file is useful because it gives the agent a named object it can return to. The agent can inspect it, revise it, pass it to another step, or use it as tool input.
>
> Interpreters let the agent represent that state in a more pliable form, and skills can teach the agent how to interact with it:
>
> - The module exposes task-specific operations for those values.
> - The agent writes code to combine those operations.
> - The skill author owns the behavior of each operation.
>
> Imagine a skill for interacting with csv files. SKILL.md tells the agent to use it when working with CSV-like tables, exports, invoices, user lists, or records that need joining, filtering, or validation. index.ts exports a small table API:
>
> ```typescript
> export {
>   parseCsv,
>   joinTables,
>   filterRows,
>   validateRows,
>   groupBy,
>   summarize,
>   toCsv,
> };
> ```
>
> The agent can then compose those operations in interpreter code:
>
> ```typescript
> const invoices = parseCsv(await tools.readFile({ path: "/invoices.csv" }));
> const customers = parseCsv(await tools.readFile({ path: "/customers.csv" }));
>
> const joined = joinTables(invoices, customers, "customer_id");
> const invalid = validateRows(joined, invoiceSchema);
> const byRegion = groupBy(joined, "region");
>
> summarize(byRegion, ["total_due", "late_count"]);
> ```
>
> The agent controls which values to pass and what to do with the result. The skill author controls what "join", "validate", and "summarize" mean.
>
> This is different from asking the agent to write the helper itself. Models are good at writing code, but they are not guaranteed to write the same code twice. If the procedure matters, the implementation should live in skill code that can be reviewed, tested, versioned, and reused.
>
> ## FAQ
>
> ### Why package this as a skill?
>
> Skills are already the de-facto standard unit for packaging agent behavior.
>
> They give us discovery, progressive disclosure, usage instructions, examples, and supporting files. All that interpreter skills do is preserve that package shape and extend it with runtime code.
>
> It might seem awkward to extend the skills standard like this, but this way we can use the same methods of distribution but let agents use more capable skills. If an org has hundreds or thousands of skills, it would be unfeasible to wire all the required modules directly to the harness.
>
> ### Can't I just include a script file?
>
> Script files are useful for a different reason.
>
> A script is a good fit when the agent needs an external helper it can interact with its environment: scripts usually communicate through command arguments, files, stdout/stderr, or serialized state.
>
> That boundary makes scripts a poor fit for orchestrating agent work. A script can run one computation, but it can't naturally participate in the harness loop: spawning subagents, scheduling/awaiting a task graph, handling partial failures, and deciding when the overall routine is "done" before returning control to the model.
>
> In the repo triage example, the module calls an allowlisted `tools.task(...)` function to spawn subagents from inside the routine. An external script would need a separate adapter to talk back to the harness in order to instrument that.
>
> ### Why not make every API a tool?
>
> Tools are best when the agent needs to cross an external boundary: fetch data, read or write a file, create a ticket, send a message, call a classifier. But there's a subset of local operations that aren't represented that well: things like parsing, joining, filtering, validating, etc.
>
> Making every helper a tool would bloat the action surface. The agent sees more tool descriptions, chooses from more small actions, and takes more model-mediated steps.
>
> We can lean on an existing runtime (TypeScript) which is already prominent in model weights to represent that instead. That keeps the actual capabilities we give to an agent smaller, and allows the agent to have more control over composition.
>
> ## Closing
>
> Interpreter skills are our attempt to turn "best known agent routines" into reviewable, testable APIs while keeping the model in charge of when to apply them. If you're building agents with a few critical subroutines, interpreter skills might be for you: discretion on the outside, determinism on the inside.
>
> If you're interested in learning more, here's a couple of resources we've published related to interpreters and more on this topic:
>
> - Read: What interpreters are (concept + motivation) — [Give your agents an interpreter](https://x.com/huntlovell/status/2057166131924988002)
> - Docs: How to use interpreters (API + examples) — [Using interpreters](https://docs.langchain.com/oss/python/deepagents/interpreters)
> - Docs: How to add interpreter skills (packaging + module loading) — [Adding interpreter skills](https://docs.langchain.com/oss/python/deepagents/skills#use-interpreter-skills)
>
> Deep Agents is a general purpose agent harness available in [Python](https://github.com/langchain-ai/deepagents) and [TypeScript](https://github.com/langchain-ai/deepagentsjs).
