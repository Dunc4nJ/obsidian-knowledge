---
created: 2026-05-21
description: Hunter Lovell's "Give your agents an interpreter" — the Deep Agents code interpreter as a narrow-by-default QuickJS runtime that sits between serial tool loops and full sandboxes, exposing host capabilities only through explicit bridges, adding interpreter state as a third context surface, and delivering up to 35% token reduction via PTC.
source: https://x.com/huntlovell/status/2057166131924988002
type: synthesis
---

# Deep Agents interpreter middleware gives agents a programmable middle lane between serial tool loops and full sandboxes through explicit host-runtime bridges

## Key Takeaways

- **Interpreters occupy the missing lane between tool loops and sandboxes** — Serial tool loops force every intermediate result back through model context; full sandboxes give broad host access but are heavy to provision. The interpreter is middleware inside the agent loop where the agent writes TypeScript/Python to compose tool calls, keep intermediate state, and return only the relevant output to the model. The [[Deep Agents v0.6 splits the agent harness into five composable primitives - code interpreter, per-model profiles, typed streaming, delta channels, and ContextHub backend|v0.6 release]] introduced the interpreter as a first-class primitive alongside harness profiles and delta channels.

- **Narrow-by-default is the key design principle — capabilities are added back, not restricted** — By default the interpreter has no filesystem, no network, no shell, no packages, and no agent tools. Starting surface is just language features: objects, arrays, maps, JSON, control flow. If you need more, you bridge it explicitly from the host runtime. This inverts the sandbox model (which starts broad and restricts) and produces a smaller action surface, more predictable failure modes, and more repeatable results. The same architectural shape appears in Figma plugins, Shopify scripts, and AWS Lambda extensions.

- **PTC becomes model-agnostic middleware, not a model-specific API feature** — Anthropic shipped Programmatic Tool Calling as a closed API behavior. Deep Agents reproduces it for any model (including open-weight: Kimi, Qwen, DeepSeek) via the interpreter middleware: allowlisted tools appear under `tools.*` inside interpreter code as async functions, intermediate results stay in the runtime rather than round-tripping through model context, and the host runtime still executes the real tool call. Measured result on OOLONG trec-coarse: up to 35% token reduction on PTC tasks (opus-4-7 baseline 831,414 tokens → quickjs-opus-4-7 538,349 tokens, a 35.3% reduction).

- **Interpreter state is a third harness context surface alongside message history and filesystem** — Message history is expensive and attention-constrained; the filesystem is durable but forces serialization; interpreter state holds live values (arrays, maps, queues, counters, helper functions) that persist across `eval` calls like a REPL session. The model can inspect or reuse values without them becoming prompt tokens. This makes the interpreter specifically useful for agent-loop state: scoring candidates, tracking seen IDs, managing task queues — things that need to live somewhere but shouldn't flood the context window.

- **The eval tool is middleware, not arbitrary code execution** — The harness adds an `eval` tool, creates a QuickJS context, executes agent TypeScript, and returns the final expression back into model context. The interpreter runs inside that context; it has no host access unless the harness explicitly bridges it. Runtime controls sit at the boundary: memory limits, per-eval timeouts, max PTC calls, max result size, console capture, and snapshotting for serializable state between turns. This is the same architectural boundary [[Recursive Language Models pass context by reference through a Python REPL so subagent outputs return as variables instead of autoregressively regenerated tokens|RLMs use at the model layer]], but applied at the harness layer in a model-agnostic way.

## External Resources

- [Deep Agents interpreter docs](https://docs.langchain.com/oss/python/deepagents/interpreters) — installation (`deepagents[quickjs]` / `@langchain/quickjs`) and middleware setup
- [Anthropic PTC docs](https://platform.claude.com/docs/en/agents-and-tools/tool-use/programmatic-tool-calling) — the Claude-specific API version that Deep Agents generalizes
- [Cloudflare Code Mode](https://blog.cloudflare.com/code-mode/) — converging pattern: scoped runtime where model writes code to manage control flow
- [RLM paper](https://alexzhang13.github.io/blog/2025/rlm/) — related idea at the model layer; Deep Agents uses the same "keep working state outside context" principle at the harness layer
- [OOLONG benchmark](https://huggingface.co/datasets/oolongbench/oolong-synth/viewer/default/validation) — the trec-coarse dataset used to measure the 35% token reduction claim

## Original Content

> [!quote]- Source article — Hunter Lovell, "Give your agents an interpreter" (X, 2026-05-20, 46 likes / 11 retweets / 0 replies)
>
> ![[huntlovell-988002-001.png]]
> *Article header: "Give your agents an interpreter" — Deep Agents / LangChain.*
>
> **Article: Give your agents an interpreter**
>
> TL;DR We're adding interpreters to Deep Agents: small embedded runtimes where agents can write and execute code inside the agent loop. They give agents a middle ground between one-at-a-time tool calls and full sandboxes, so agents can express multi-step work, keep intermediate state out of model context, and execute code and actions in a more predictable way.
>
> ## What's an interpreter?
>
> An interpreter is a small embedded runtime that an agent can write code against while it is working. Functionally, it feels like giving the agent a Python or Node REPL: it can define variables, inspect values, write helper functions, and reuse state across calls.
>
> Many agents today already execute code by issuing commands to a host or sandbox environment. This is great when the task is environment-level work: running commands, installing dependencies, or operating over a filesystem. Interpreters are aimed at a different layer: the agent writes code that runs inside the agent loop to coordinate delegation, compose tool calls, transform structured data, and decide what information should come back to the model.
>
> ```typescript
> // agent writes code like this
> const rows = [
>   { team: "support", tickets: 18 },
>   { team: "infra", tickets: 7 },
>   { team: "sales", tickets: 11 },
> ];
>
> const total = rows.reduce((sum, row) => sum + row.tickets, 0);
> const busiest = rows.sort((a, b) => b.tickets - a.tickets)[0];
>
> `${busiest.team} has the most tickets. ${total} tickets total.`;
> ```
>
> This gives agents a new place to express behavior that doesn't fit cleanly into a sequence of tool calls. The agent gets a working space for multi-step logic, while the harness still controls what that working space can touch. The interpreter can hold temporary state and return only the part that matters.
>
> ## Where interpreters fit
>
> ![[huntlovell-988002-002.jpg]]
> *Left: typical tool loop — each tool call returns a full result back to the model before the next step. Right: interpreter loop — model calls eval once, interpreter fans out to multiple tools in parallel, returns a single computed result.*
>
> When you think of an agent, you usually think of attaching tools.
>
> In the simplest form of an agent, the agent uses those tools in a loop: the model calls one tool, inspects the observation, then decides what to do next. That one-step-at-a-time style is straightforward to debug and evaluate, and a lot of workflows do require a way to reason over immediate observations.
>
> Sandboxes build on top of that by giving the agent a bash tool that works against an environment to run commands, install dependencies, and work with files.
>
> But both ends have downsides: sandboxes can handle local procedure (since it can just write code to do so), but they can be harder to provision and scale; and purely serial tool loops can be awkward when those intermediate steps mostly feed the next step.
>
> Some agent work sits between those two extremes, which interpreters slot nicely into. They give the agent code-level composition over scoped capabilities without giving it a whole environment. The model can write a small program to express control flow over existing capabilities, while the harness decides which capabilities are available through the host.
>
> ## More limited by design
>
> We call this an interpreter, not just a code runtime, because the interpreter is intentionally limited. By default it does not have the APIs you would expect from a normal programming environment: no filesystem, no network, no shell, no package installation, and no wall-time access. The agent starts with basic control flow and object manipulation: objects, arrays, maps, JSON, and the rest of the small language runtime.
>
> ![[huntlovell-988002-003.jpg]]
> *Capability table: Filesystem, Network, Shell, and Packages are "Not available" by default; Agent tools and Subagents are "Not available automatically" — each requires an explicit bridge or PTC allowlist entry.*
>
> Those capabilities are exposed through explicit bridges to the host runtime. If the agent needs to call a tool, read from a scoped filesystem API, fetch a URL, or delegate to a subagent, the harness has to expose that capability deliberately. For instance, this script only works when we explicitly bridge the fetch, read_file and task tools directly to the interpreter:
>
> ```typescript
> // calls the `fetch` tool to make a network request
> const response = tools.fetch("https://docs.langchain.com");
> // calls the `readFile` tool to fetch files from the agents filesystem
> const file = tools.readFile("SPEC.md");
> // calls the `task` tool to spawn a subagent
> const subagentOutput = tools.task({
>   description: "Do you know the muffin man?"
> });
> ```
>
> The host runtime (the same one that runs the harness) contains all the actions an agent can take using the interpreter, and explicitly decides which ones the interpreter code can call. The interpreter is the agent's programmable side of that boundary.
>
> By default, the interpreter starts with language features only, not generic host access like a sandbox gives you. Anything that touches the outside world has to cross an explicit bridge that you specify.
>
> We do this for a few reasons:
>
> - Smaller action surface: With bash or a sandbox, the starting point is broad: the agent has something shaped like a computer, and you restrict what it can do from there. With an interpreter, the starting point is narrow: the agent has a language runtime, and capabilities are added back deliberately. That does not replace sandboxing when you require process or VM isolation, but it does mean the agent is not inheriting broad host access by default.
>
> - Predictability: A small, fixed runtime makes agent behavior easier to anticipate and evaluate. If the interpreter had broad host access or a rich library surface, the same goal could be achieved through many different strategies, which makes outputs less consistent and harder to test. By keeping the default environment minimal and forcing extra capabilities to cross explicit bridges, you make the agent's action space narrower, the failure modes clearer, and the results more repeatable.
>
> You see the same architectural shape in systems from Figma, Shopify, AWS, and others: constrained code runs on one side, while the host exposes a controlled API boundary on the other.
>
> ## What interpreters unlock
>
> A few recent systems have converged on similar patterns: give the model a small, scoped runtime where it can write a bit of code to manage control flow and intermediate state. Cloudflare's [Code Mode](https://blog.cloudflare.com/code-mode/), Anthropic's [Programmatic Tool Calling (PTC)](https://platform.claude.com/docs/en/agents-and-tools/tool-use/programmatic-tool-calling), and [RLM-style workflows](https://alexzhang13.github.io/blog/2025/rlm/) each point at that idea from different angles. In Deep Agents, an interpreter is how you get that pattern in a model-agnostic way. Here are a few places it's already been useful:
>
> ## Interpreter state as a context surface
>
> ![[huntlovell-988002-004.jpg]]
> *Three-surface context diagram: Message history (SystemMessage / HumanMessage / AIMessage / ToolMessage), Filesystem (/memory/project.md, /scratch/notes.md, /outputs/report.csv, /code/analyze.ts), and Interpreter state (candidates: Doc[], scores: Map<id, number>, queue: Task[], seenIds: Set<string>). Only "selected context" flows into message history; filesystem and interpreter state feed it selectively.*
>
> Agent harnesses already organize context across a few surfaces:
>
> - Message history is the context immediately available to the model. It is expensive and attention-constrained: just because a model can accept a million tokens does not mean it will reason over every token equally well. (e.g. [context rot](https://www.trychroma.com/research/context-rot))
>
> - A filesystem gives the agent somewhere to store durable artifacts, notes, intermediate files, and longer-lived working memory. It is durable and flexible, but it forces the agent to serialize working state into files and then reconstruct it later. Part of the job of the harness is to control the flow of context between the filesystem and the message history.
>
> Interpreter state gives the agent another option. Values can stay in the runtime as arrays, objects, maps, counters, queues, and helper functions. The model does not need to see every intermediate value as prompt text, but it can still ask the interpreter to inspect or reuse those values later.
>
> This is similar to why a REPL feels different from running a one-off command. If you define a variable in a REPL, it is still there on the next command you submit. You do not have to turn it into stdout, write it to a file, or reconstruct it before doing the next thing. The same principle applies when an agent calls the interpreter multiple times, since it can just reuse the value from a previous call.
>
> That makes interpreters useful for agent-loop state. Message history is for what the model needs to reason over now, the filesystem is for durable artifacts and environment-level work, and interpreter state is for live working values that may be useful later but do not need to become model input yet.
>
> ## Programmatic tool calling
>
> Anthropic's [Programmatic Tool Calling (PTC)](https://platform.claude.com/docs/en/agents-and-tools/tool-use/programmatic-tool-calling) is another version of this pattern: tool calls happen from inside code the agent writes, rather than as a sequence of model-mediated actions.
>
> If the model calls a tool, receives the full result, reasons over it, and calls the next tool, every small step becomes another model round trip. If the agent can write code that calls tools directly, it can keep intermediate outputs in the runtime and return only the final result or selected evidence.
>
> In Deep Agents, PTC is implemented as middleware rather than as a model-provider behavior. The developer passes an allowlist, allowlisted tools appear under the global tools namespace, and each tool is exposed as an async function the interpreter can call with await. This means that you can enable PTC for any model (including open source ones).
>
> ```typescript
> const topics = ["retrieval", "memory", "evaluation"];
>
> const reports = await Promise.all(
>   topics.map((topic) =>
>     tools.task({
>       description:
>        `Research ${topic} in Deep Agents and return ` +
>        `three concise findings.`,
>       subagent_type: "general-purpose",
>     }),
>   ),
> );
>
> reports.join("\\n\\n");
> ```
>
> ![[huntlovell-988002-005.png]]
> *LangSmith trace showing the interpreter loop in action: model → tools → eval → three parallel task subagents (general-purpose), each completing in ~3.5s at 2.8K tokens.*
>
> In some of our early testing, this style of tool calling used up to 35% fewer tokens on some tasks. (we evaluated this on a collected set of tasks from the [OOLONG](https://huggingface.co/datasets/oolongbench/oolong-synth/viewer/default/validation) trec-coarse dataset)
>
> ![[huntlovell-988002-006.jpg]]
> *Token reduction benchmark: opus-4-7 baseline 831,414 tokens / 4.67 steps; sonnet-4-6 794,182 tokens (−37K); quickjs-sonnet-4-6 595,751 tokens (−235K, 28% reduction); quickjs-opus-4-7 538,349 tokens (−293K, 35% reduction).*
>
> ## Working over large datasets
>
> Take a document-heavy task: an agent needs to classify, extract, or synthesize information from 10,000 documents.
>
> With a standard tool-calling agent, the natural shape is a long sequence of model-mediated actions. The model searches, gets results back in context, decides what to inspect next, calls another tool, gets more results back, and repeats. For small tasks, that loop is sufficient. But at scale it starts to break down:
>
> - It is hard to verify that the agent actually followed the intended procedure.
>
> - Too much intermediate context gets routed back through the model.
>
> - It is easy to run into latency, context, or tool-call limits.
>
> - The response can degrade because the model is forced to manage too much working state through history.
>
> An interpreter-shaped version looks different. The model can write code that keeps document and search state in the runtime, iterates through batches programmatically, scores or filters candidates, and calls subagents only on selected slices. Instead of returning every intermediate result to the model, the interpreter returns a compact evidence set: the documents that matched, the fields that were extracted, the unresolved cases, or the few summaries worth reasoning over.
>
> The interpreter is not magically reasoning over all 10,000 documents. It gives the agent a better way to control the search space and decide what should enter model context.
>
> ```typescript
> const candidates = documents
>   .map((doc) => ({ doc, score: scoreDocument(doc, query) }))
>   .filter(({ score }) => score > 0.75)
>   .sort((a, b) => b.score - a.score)
>   .slice(0, 10);
>
> const reports = await Promise.all(
>   candidates.map(
>     ({ doc }) =>
>       tools.task({
>         description:
>           `Extract evidence from ${doc.id} for: ${query}`,
>         subagent_type: "general-purpose",
>       }),
>   ),
> );
>
> reports.join("\n\n");
> ```
>
> ## Recursive Language Models
>
> Another related idea is [Recursive Language Models (RLMs)](https://alexzhang13.github.io/blog/2025/rlm/). RLMs treat long prompts as part of an external REPL environment, then let the model write code to inspect, decompose, and recursively call models over selected snippets.
>
> Deep Agents interpreters are not implementing RLMs at the model layer, but there is still a relevant connection at the harness level: code can hold working state outside the model context, select a slice of that state, and pass only that slice into the next model or subagent call.
>
> In Deep Agents, tools.task is the bridge for this. Interpreter code can select a slice of work, delegate that slice to a subagent, combine the result with existing runtime state, and return only the synthesized output to the main model.
>
> ## How it works in Deep Agents
>
> At the harness level, the interpreter is middleware between the agent loop and a small runtime. The middleware:
>
> - adds an eval tool to the agent
>
> - creates and maintains a QuickJS context
>
> - executes the agent's TypeScript code
>
> - captures console.log output when configured
>
> - returns the final expression back into model context
>
> The eval tool is not "run arbitrary code on the host." The code runs inside the interpreter context. If it needs to communicate with the outside world, it does so through bridges the host runtime exposes.
>
> Programmatic tool calling is one of those host bridges. The developer passes a ptc allowlist, allowlisted tools appear inside the interpreter under the tools namespace (e.g. tools.getWeather(...)), and each tool is exposed as an async function the interpreter can call with await. The host runtime still executes the real tool call.
>
> The rough flow looks like this:
>
> 1. the model writes code and calls eval
>
> 2. QuickJS evaluates the code inside the interpreter context
>
> 3. interpreter code optionally calls allowlisted tools
>
> 4. the host runtime executes the real tool calls
>
> 5. results cross back into the interpreter
>
> 6. the final expression crosses back into model context
>
> Repeated eval calls in a run can share the same live interpreter context, which is what lets values behave like REPL state. Snapshotting between conversation turns is also available, but it should be treated as a way to preserve serializable working data rather than live handles or host resources.
>
> Runtime controls live at this boundary too:
>
> ![[huntlovell-988002-007.jpg]]
> *Runtime controls table: Memory limit (how much memory interpreter code can use), Per-eval timeout (how long a single eval can run), Max PTC calls (how many bridged tool calls one eval can make), Max result size (how much data can be returned to the model), Console capture (whether console.log output is captured), Snapshots (what serializable state can persist between turns).*
>
> ## How to use it in Deep Agents
>
> You can install the interpreter and add the middleware using create_deep_agent:
>
> ```bash
> uv add "deepagents[quickjs]"
> ```
>
> ```python
> from deepagents import create_deep_agent
> from langchain_quickjs import CodeInterpreterMiddleware
>
> agent = create_deep_agent(
>     model="openai:gpt-5.5",
>     middleware=[CodeInterpreterMiddleware()],
> )
> ```
>
> (and in TypeScript)
>
> ```bash
> pnpm install deepagents @langchain/quickjs
> ```
>
> ```typescript
> import { createDeepAgent } from "deepagents";
> import { createCodeInterpreterMiddleware } from "@langchain/quickjs";
>
> const agent = createDeepAgent({
>   model: "openai:gpt-5.5",
>   middleware: [createCodeInterpreterMiddleware()],
> });
> ```
>
> To let interpreter code call agent tools, enable programmatic tool calling with an allowlist. Tools are not automatically exposed to interpreter code; you must choose which tools can cross the host-runtime bridge.
>
> ```python
> agent = create_deep_agent(
>     model="openai:gpt-5.5",
>     middleware=[CodeInterpreterMiddleware(ptc=["task"])],
> )
> ```
>
> ```typescript
> const agent = createDeepAgent({
>   model: "openai:gpt-5.5",
>   middleware: [createCodeInterpreterMiddleware({ ptc: ["task"] })],
> });
> ```
>
> Once PTC is enabled, allowlisted tools appear under the global tools namespace. Each tool is an async function, and the model receives the final interpreter output rather than every intermediate tool result.
>
> Deep Agents is available in [Python](https://github.com/langchain-ai/deepagents) and [TypeScript](https://github.com/langchain-ai/deepagentsjs). See the docs for more information on [interpreters](https://docs.langchain.com/oss/python/deepagents/interpreters), as well as the full set of middleware options and runtime controls.
>
> ---
>
> Special thanks to @sydneyrunkle, @hwchase17, and @veryboldbagel for their review on this writeup.
