---
created: 2026-05-19
description: Sydney Runkle's Deep Agents v0.6 release groups five distinct harness primitives — an in-loop code interpreter, per-model harness profiles, typed v3 streaming, delta-channel checkpointing, and ContextHub-backed filesystems — under a single performance theme spanning the model layer, the agent layer, scale, and time.
source: https://x.com/sydneyrunkle/status/2056419909941522687
type: synthesis
---

# Deep Agents v0.6 splits the agent harness into five composable primitives - code interpreter, per-model profiles, typed streaming, delta channels, and ContextHub backend

## Key Takeaways

- **Programmatic Tool Calling (PTC) is now model-agnostic via an installable in-loop interpreter** — Anthropic shipped PTC as a closed API behavior, but Deep Agents v0.6 reproduces it for any model (including open-weight) by giving the agent a QuickJS sandbox where intermediate tool results stay in runtime state instead of round-tripping through model context. This shifts the optimization frontier from "which model exposes PTC" to "which middleware does your harness load" — the same direction [[Anthropic Managed Agents virtualizes agent components into OS-style interfaces that decouple the brain from the hands]] takes with a different abstraction stack.

- **Recursive workflows are recast as a harness pattern, not a model architecture** — the article explicitly draws the line between Deep Agents' interpreter-as-runtime and the [[Recursive Language Models pass context by reference through a Python REPL so subagent outputs return as variables instead of autoregressively regenerated tokens|original RLM proposal]]: Deep Agents stops short of claiming model-layer RLM, but uses the same "keep working state outside the context window, dispatch subagents on selected branches" trick at the orchestration layer.

- **Harness profiles formalize what every team was already doing ad hoc** — system prompt, tool descriptions, and middleware are now a named, versionable bundle that ships per model. Sydney's claim that prompts+middleware alone shift tau2-bench by 10–20 points (gpt-5.2-codex 52.8 → 66.5 on Terminal-Bench 2.0 from harness-layer changes alone) is the strongest published number to date that [[LangChain Deep Agents adds per-model harness profiles because each provider's prompting guide demands different tools and middleware|per-model harness tuning matters more than model choice]] inside a fixed cost envelope, and reinforces [[Open models now match closed frontier models on core agent harness tasks at a fraction of the cost|open-weight viability]] at 20×+ cost reduction.

- **Delta channels collapse checkpoint storage from O(N²) to O(N/K)+O(N), turning long-running agents from a storage-cost problem into a routine one** — a 200-turn coding session drops from 5.27 GB to 129 MB (41.7× reduction at the tail), and at every length tested the ratio gets worse without deltas. This is the most quantitative defense yet of LangGraph's snapshot-every-step durability model: instead of relaxing the guarantee, they kept resumability/observability and rebuilt the persistence layer underneath.

- **ContextHub turns the agent filesystem into a Git-backed, versioned, environment-tagged artifact store** — and via `CompositeBackend` you can route only `/memories/` to Hub while leaving the rest thread-scoped. That makes prompt/skill/policy evolution a code-review artifact rather than a database mutation, sharpening Harrison Chase's argument in [[Memory ownership follows harness ownership - Harrison Chase argues picking a closed harness is picking a permanent owner for your agent's data flywheel]]: LangChain is offering a versioned, exportable home for the data flywheel instead of a closed memory service.

## External Resources

- [LangSmith Context Hub](https://smith.langchain.com/context) — the LangSmith-backed versioned filesystem behind `ContextHubBackend`; agent reads/writes land as commits with history and environment tagging.
- [Anthropic — Advanced Tool Use](https://www.anthropic.com/engineering/advanced-tool-use) — the Anthropic engineering write-up that popularized Programmatic Tool Calling as a Claude API behavior; Deep Agents v0.6 generalizes it to any model.
- [Deep Agents interpreter docs](https://docs.langchain.com/oss/python/deepagents/interpreters) — installation (`deepagents[quickjs]` / `@langchain/quickjs`) and middleware setup.
- [Deep Agents profile docs](https://docs.langchain.com/oss/python/deepagents/profiles) — how to author a `HarnessProfile`.
- [Tuning Deep Agents across different models](https://www.langchain.com/blog/tuning-deep-agents-different-models) — companion post with the Terminal-Bench / tau2-bench delta numbers.
- [Agent Streaming Protocol](https://github.com/langchain-ai/agent-protocol/tree/main/streaming) — the spec that v3 streaming aligns with.
- [Streaming Cookbook](https://github.com/langchain-ai/streaming-cookbook) — runnable examples for message streams, subagents, custom channels, multimodal UI, reconnect behavior, and per-framework patterns (React, Vue, Svelte, Angular).
- [Delta Channels writeup (Notion)](https://www.notion.so/Delta-Channels-How-We-re-Evolving-our-Runtime-for-Long-Running-Agents-35d808527b17803eb4f3d3b7dc550875?pvs=21) — full deep dive on the snapshot-vs-delta tradeoff and the multi-file coding benchmark.
- [ContextHubBackend full docs](https://docs.langchain.com/oss/python/deepagents/backends#contexthubbackend) — conflict handling and storage limits.
- [Release notes — Python](https://docs.langchain.com/oss/python/releases/changelog) | [TypeScript](https://docs.langchain.com/oss/javascript/releases/changelog).

## Original Content

> [!quote]- Source article — Sydney Runkle, "Deep Agents v0.6" (X, 2026-05-18, 62 likes / 17 retweets / 5 replies)
>
> ![[sydneyrunkle-522687-001.png]]
> *Release banner: Deep Agents v0.6.*
>
> **Article: Deep Agents v0.6**
>
> The latest DeepAgents release is centered around performance at the model layer, the agent layer, at scale, and over time. Five things in this release contribute:
>
> - Code interpreter: a lightweight runtime for agents to compose tools, manage state, and control what reaches model context — without the overhead of a full sandbox.
>
> - Harness profiles: per-model tuning so your harness gets the most out of whichever model you're running, including open-weight models like Kimi, Qwen, and DeepSeek.
>
> - Streaming: typed projections for messages, tool calls, subagents, and custom application events — subscribe to exactly what your application needs instead of parsing raw stream output.
>
> - DeltaChannel: efficient checkpoint storage as agents run longer and context accumulates, without sacrificing the durable execution guarantees that make agents resumable, observable, and resilient.
>
> - ContextHubBackend: backed by [LangSmith Context Hub](https://smith.langchain.com/context), store the skills, policies, and memories that shape agent behavior in a versioned, collaborative home, so what your agent learns from one run can improve the next.
>
> # Code interpreter
>
> We're releasing an installable code interpreter in Deep Agents, which give agents a programmable workspace where they can transform data, coordinate tool calls, and keep intermediate work out of the model context. The agent writes code to express its intent, then an in-memory runtime executes that code and returns the relevant results.
>
> Where sandboxes are a code-first way for acting on an environment (such as running commands, installing dependencies, and editing files), interpreters are a code-first way for acting inside the agent loop: composing tools, preserving state, and deciding what information should be returned to the model.
>
> This enables a few new novel capabilities for agents that we're particularly excited about:
>
> ## Model-agnostic PTC
>
> Standard tool calling loops make the model the traffic controller for every step. The model asks for a tool, receives the full result in context, reasons over that result, and repeats. Even when an intermediate result is only needed to compute the next input, it still has to chain through multiple model calls.
>
> Programmatic Tool Calling (PTC) changes that workflow. The model writes code that calls tools from inside an execution runtime, so workflows can run without a round-trip to a model for every individual tool invocation. Intermediate results can stay in runtime state where the interpreter can filter noisy outputs, process data, retry failures, and return only the relevant context back to the model.
>
> *Parallel subagent dispatch — the agent writes JS that fans out one `tools.task` per topic and `Promise.all`s the results, never round-tripping through the main model.*
> ![[sydneyrunkle-522687-002.jpg]]
>
> *Filter intermediate state in-runtime — fetch many pages, keep only those containing "interpreter", and slice each to 500 characters before any of it touches the model context.*
> ![[sydneyrunkle-522687-003.jpg]]
>
> This pattern of doing tool calling reduces token consumption, cuts down on avoidable model round trips, and makes the agent's reasoning step smaller.
>
> [Anthropic](https://www.anthropic.com/engineering/advanced-tool-use) helped popularize this pattern by adding it as an API behavior for their model family, but with an interpreter this can now be achieved by any agent with any model (including open source models).
>
> ## Recursive workflows
>
> Interpreters let agents interact with the harness in more novel ways. Because tools and subagents are callable from code, an agent can take the output of one subagent, inspect it, transform it, and feed it into another step without routing every intermediate artifact back through the main model.
>
> That makes recursive workflows possible: the agent can keep a queue of questions, call a subagent on the next question, store the result, generate follow-up work from that result, and continue until it has enough evidence to synthesize an answer. (This is more than just "call another LLM on the full input context": the key is maintaining working state outside the model context and controlling what gets passed into each next call.)
>
> *Recursive workflow loop — a `frontier` queue feeds subagent calls, follow-up questions are extracted from each report and pushed back onto the queue until six findings accumulate.*
> ![[sydneyrunkle-522687-004.jpg]]
>
> This is adjacent to the idea behind Recursive Language Models (RLM): keep working state outside the model context, call models or subagents on selected branches, and control what enters the next model call.[Recursive Language Models](https://www.notion.so/paper%20link)
>
> In Deep Agents, the interpreter becomes the working runtime for that pattern — without claiming we "do RLM" as originally defined at the model layer.
>
> All of this can be enabled by installing deepagents[quickjs] on pypi, or @langchain/quickjs on npm and adding it as a middleware.
>
> *Minimal install — `pip install deepagents[quickjs]` then attach `CodeInterpreterMiddleware` to a deep agent (here pointed at an open-weight GLM-5 hosted on Baseten).*
> ![[sydneyrunkle-522687-005.jpg]]
>
> See the [docs](https://docs.langchain.com/oss/python/deepagents/interpreters) for more information on interpreters.
>
> # Harness profiles
>
> Open-weight models like Kimi K2.6, GLM 5.1, and DeepSeek V4 are now viable for production agent work, often at 20×+ lower cost than closed frontier models. But models are post-trained on different tool-calling format and prompt conventions, while most harnesses are tuned for the closed model their authors built against. Drop one in cold, and you might see only a fraction of its true capability because the model is speaking a dialect the harness doesn't understand.
>
> That gap is large and measurable. In our own testing, harness-layer changes alone moved gpt-5.2-codex from 52.8% → 66.5% on Terminal-Bench 2.0 (Top 30 → Top 5), lifted gpt-5.3-codex 20% on tau2-bench, and opus-4.7 10%. Across tau2-bench, prompts and middleware can move scores by 10 to 20 points without changing the model.
>
> The "harness" is around the model: the base system prompt, tools and their descriptions, and middleware that shapes each turn. A harness profile captures these per-model overrides as a named, versionable unit.
>
> DeepAgents v0.6 makes harness profiles a first-class abstraction. You can diff, version, and swap a profile alongside the model, so tuning work carries forward. We're shipping built-in profiles for major models so strong performance is the default, and the same machinery is available for your own stack.
>
> More in [tuning deep agents across different models](https://www.langchain.com/blog/tuning-deep-agents-different-models). See the [docs](https://docs.langchain.com/oss/python/deepagents/profiles) to write your own.
>
> ## Streaming
>
> Agents do a lot of work before they return a final answer. For a good user experience, you want to surface that work as it happens, and give users the ability to steer the agent along the way: streaming is the primitive that makes this possible. LangChain's new release makes streaming a first-class application primitive. With stream_events(..., version="v3"), agents and graphs now emit a unified event stream with ergonomic projections for primitives developers actually want to render: message text, reasoning blocks, tool calls, state updates, subgraphs, subagents, custom channels, and final output. The stream is content-block-centric, which means UIs no longer need to guess whether a chunk is text, reasoning, media, or tool-call data. Everything is organized around typed events, namespaces, and channels, all aligned with the new [Agent Streaming Protocol](https://github.com/langchain-ai/agent-protocol/tree/main/streaming).
>
> *Typed stream projections — iterate `stream.messages` and `stream.subagents` independently instead of parsing raw event dicts; subagent text streams under each subagent's namespace.*
> ![[sydneyrunkle-522687-006.jpg]]
>
> This streaming model also carries over the wire through new Agent Server endpoints and SDK support. The LangGraph SDK exposes remote event streaming through client.threads.stream(...), with support for multimodal content, reconnect/replay behavior, and transport-agnostic delivery over SSE or WebSockets. Because local and remote streams now follow the same protocol, developers get a consistent way to observe agent runs across scripts, backend services, and production frontends. Applications can subscribe to exactly the parts of a run they need, such as messages from a specific subagent, updates from a custom channel, or events within a particular namespace.
>
> On the frontend, this release brings v1 framework integrations for @langchain/react, @langchain/vue, @langchain/svelte, and @langchain/angular, giving teams idiomatic hooks and utilities for building rich streamed experiences without hand-rolling event parsers. To make the new stack easy to explore, we're also publishing the [Streaming Cookbook](https://github.com/langchain-ai/streaming-cookbook): a collection of runnable examples covering message streaming, subgraphs, subagents, custom stream transformers, multimodal UI, reconnect behavior, and framework-specific patterns. The result is a streaming foundation that is lower-level where you need precision, higher-level where you want productivity, and consistent from agent runtime to user interface.
>
> ## Delta channels
>
> Deep Agents is built on the LangGraph runtime, which checkpoints agent progress at every step. That's what makes observability, human-in-the-loop, and failure recovery possible: you always know exactly where an agent is and can resume from any point.
>
> As agents get more capable:
>
> 1. They run longer, with message histories that grow across dozens or hundreds of steps
>
> 2. They use more context, utilizing the filesystem for context management and offloading
>
> For deepagents, message history and files live in agent state, and with a snapshot-every-step approach, checkpoint storage grows at O(N²).
>
> Delta channels are how we're evolving the runtime to keep up. Rather than serializing a full snapshot at every checkpoint, we store only the diff. For Deep Agents, that means delta-based storage for message histories and files.
>
> *Snapshot-every-step (left, O(N²) — every step re-stores everything) vs. deltas-plus-periodic-snapshot (right, O(N²/K) + O(N) — K× smaller coefficient because most steps store only Δmsg and Δfile, with a full snapshot every K steps).*
> ![[sydneyrunkle-522687-007.jpg]]
>
> You still get a complete history of agent progress, just at a fraction of the storage cost. This also helps to mitigate the bottleneck of writes to the checkpointer (database) for long-running agents, and storage costs at scale are much more manageable.
>
> Depending on the conversation length and context size, swapping to delta channels can reasonably bring 10-100x reductions in checkpointer storage.
>
> Consider, for example, an experiment: a simulated multi-file coding session where an agent writes files, retrieves documentation, and reasons through its work — 200 turns of the kind of sustained, context-heavy work a capable coding agent actually does. Without delta channels, that session accumulates 5.27 GB of checkpoint storage. With delta channels: 129 MB.
>
> Here's a comparison of checkpointer storage for the same agent with and without delta channels:
>
> *Workload B benchmark — per-turn checkpoint storage with deltas disabled vs. enabled, scaling 10→200 turns. Reduction grows from 11.8× at 10 turns to 41.7× at 200 turns.*
> ![[sydneyrunkle-522687-008.png]]
>
> And a graphical representation of said explosion:
>
> *Same Workload B plotted as storage vs. agent turns — the 0.5.8 baseline (red) blows up super-linearly to 5.3 GB at 200 turns; 0.6 with DeltaChannel (green) stays near-flat at 129 MB.*
> ![[sydneyrunkle-522687-009.png]]
>
> Long-running agents with deep context are where the field is heading, and delta channels are how our runtime scales to meet their needs.
>
> See the [full writeup](https://www.notion.so/Delta-Channels-How-We-re-Evolving-our-Runtime-for-Long-Running-Agents-35d808527b17803eb4f3d3b7dc550875?pvs=21) for more details.
>
> ## ContextHub Backend
>
> Context Hub is a LangSmith-backed filesystem for Deep Agents. It gives you a versioned place for the files that shape agent behavior, so improvements to prompts, skills, and other context can carry forward across runs.
>
> *ContextHub UI for a "gtm-agent" repo — AGENTS.md plus a `skills/` tree (batch-email-drafting, meeting-prep, outbound-follow-ups, web-research, etc.) on the left, rendered markdown in the center, Prod/Staging environment tags on the right; each save lands as a commit (here `13ac11f1`, "15 hours ago • Vishnu Suresh").*
> ![[sydneyrunkle-522687-010.jpg]]
>
> Under the hood, your agent reads from (and can write to) a Hub repo. Those writes land as commits with history, review, and environment tagging—so you can iterate in staging and promote to production without wiring up a separate storage layer.
>
> To use it as your agent's filesystem backend:
>
> *Single-backend setup — point the deep agent at `ContextHubBackend("my-agent")` and the entire filesystem is Hub-backed.*
> ![[sydneyrunkle-522687-011.jpg]]
>
> Or scope just /memories/ to Hub while keeping the rest of the filesystem thread-scoped:
>
> *Composite routing — `StateBackend()` is the default, but `/memories/` is routed to `ContextHubBackend("my-agent")` so only persistent memories cross runs; ephemeral files stay thread-scoped.*
> ![[sydneyrunkle-522687-012.jpg]]
>
> Reads are served from cache, and writes are committed back to the Hub repo. If the repo doesn't exist yet, the first write creates it—after that, you can diff, review, and tag changes like any other piece of versioned context.
>
> Set LANGSMITH_API_KEY before using ContextHubBackend. See the [full docs](https://docs.langchain.com/oss/python/deepagents/backends#contexthubbackend) for conflict handling and limits.
>
> # Wrapping Up
>
> The through-line across our Deep Agents v0.6 release is performance:
>
> - Harness profiles help you squeeze performance out of a model with an optimal harness and unlock viable agent runs on open-weight models at a fraction of the cost of frontier APIs
>
> - Code interpreter gives an agent more autonomy to write an execute code, helping it accomplish complex tasks and optimize context window usage.
>
> - Streaming enables support for highly parallelized systems with a subscription model for tool and subagent progress.
>
> - DeltaChannel introduces a storage primitive that supports checkpoints for long-running, long-context agents.
>
> - ContextHubBackend provides a versioned home for the files that power agent behavior, backed by [LangSmith Context Hub](https://smith.langchain.com/context), enables context improvements from one run to the next.
>
> We're excited for you to give the latest deepagents a spin. Let us know what you think!
>
> Release notes: [Python](https://docs.langchain.com/oss/python/releases/changelog), [TypeScript](https://docs.langchain.com/oss/javascript/releases/changelog)
>
> *Posted: Mon May 18 17:01:27 +0000 2026 — [original tweet](https://x.com/sydneyrunkle/status/2056419909941522687)*

### Thread replies

> [!quote]- Replies
>
> **@sauvast (Saurabh)** — Mon May 18 17:46:54 +0000 2026 — [tweet](https://x.com/sauvast/status/2056431347183550518)
>
> > @sydneyrunkle @hwchase17 Definitely going to try it this week !
> > Will share my PoVs in a post.
>
> **@Vtrivedy10 (Viv)** — Mon May 18 17:59:22 +0000 2026 — [tweet](https://x.com/Vtrivedy10/status/2056434484401381439)
>
> > @sydneyrunkle woohoo!  hype to see builders cook even harder with these new features
> >
> > Delta Channels is an incredibly underrated piece of fun engineering to massively reduce storage costs for long-running agents
>
> **@Hershal0_0 (Hershal Rao)** — Mon May 18 20:53:25 +0000 2026 — [tweet](https://x.com/Hershal0_0/status/2056478285681553478)
>
> > @sydneyrunkle now the real work begins: refreshing the analytics dashboard every 5 minutes
>
> **@vela_gao (Vela)** — Tue May 19 00:44:21 +0000 2026 — [tweet](https://x.com/vela_gao/status/2056536403853623434)
>
> > @sydneyrunkle Just post this: https://t.co/utFmVIAYH8
> >
> > > QT @vela_gao: Article: Inside LangChain's Deepagents: The Harness Behind Multi-Tool Agents — https://x.com/vela_gao/status/2056403669063791016

---

Source: <https://x.com/sydneyrunkle/status/2056419909941522687>
