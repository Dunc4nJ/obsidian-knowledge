---
created: 2026-03-23
description: LangChain's Deep Agents framework proves that harness engineering (planning, filesystem persistence, subagents, context management) matters as much as model capability, jumping from outside Top 30 to Top 5 on Terminal Bench by changing only the harness.
source: https://agentnativedev.medium.com/deep-agents-the-harness-behind-claude-code-codex-manus-and-openclaw-bdd94688dfdb
type: synthesis
---

## Key Takeaways

The central argument is that **the harness is the product, not the model**. LangChain's team improved from 52.8% to 66.5% on Terminal Bench 2.0 — a jump from outside the Top 30 to the Top 5 — by only changing the harness while keeping the model fixed at GPT-5.2-Codex. This directly validates the architecture we use in our own agent workflows with Ralph loops, beads, and filesystem-based state.

Four core primitives have converged across all serious agent harnesses (Claude Code, Codex, Manus, Deep Agents):

1. **Planning and task decomposition** — The `write_todos` pattern gives models explicit state to reason about progress. Without it, models lose track on long tasks and declare victory too early. The "Ralph Loop" pattern (named in the article) intercepts premature exits and reinjects the original prompt with a clean context. This is exactly the pattern we implemented in our own Ralph workflow.

2. **Filesystem as working memory** — Even research agents (not just coding agents) benefit from filesystem access. The filesystem enables durable state across context compactions, context offloading for large tool outputs, collaboration between parent and subagents, and git-based versioning. The AGENTS.md/CLAUDE.md pattern for procedural memory is highlighted as the single most impactful memory type (~80% of improvement).

3. **Subagent spawning for context isolation** — Sweet spot is 3-7 subagents per complex task. The key failure mode: subagents do great research but return one-line summaries instead of comprehensive findings. Fix is always in the subagent's system prompt.

4. **Prompting still matters** — Claude Code's system prompt is ~2,000 lines. Tool descriptions are part of the prompt and deserve investment. The LangChain team's specific harness improvements (build-verify prompting, loop detection, pre-completion verification, reasoning budget management, time budgeting) each contributed to the 13.7 point benchmark improvement.

The article introduces a useful taxonomy: **tools** are functions the agent calls, **skills** are knowledge the agent loads on demand, **subagents** are agents it delegates to. Getting this right is the difference between $0.50 and $15 per agent run.

Context engineering is defined as "getting the right information to the LLM, in the right structure, at the right moment" — not more information, the *right* information.

The model-harness co-evolution problem is real: models are post-trained with specific harnesses, creating overfitting. But the Terminal Bench results prove that task-specific harness optimization still yields massive gains even with off-the-shelf models.

## External Resources

- [Deep Agents GitHub](https://github.com/langchain-ai/deepagents) — LangChain's open-source MIT-licensed implementation
- [Terminal Bench 2.0](https://www.terminalbench.com/) — The benchmark showing harness-vs-model impact
- Claude Agent SDK — Anthropic's harness implementation
- Manus — Another converging harness implementation
- Daytona, Modal, LangGraph Cloud — Sandbox providers supported by Deep Agents

## Original Content

> [!quote]- Source Material
>
> **Deep Agents: The Harness Behind Claude Code, Codex, Manus, and OpenClaw**
> *Agent Native — Mar 11, 2026 — 31 min read — 142 claps*
>
> LangChain team's agents moved from 52.8% to 66.5% on Terminal Bench 2.0, a jump from outside the Top 30 to the Top 5, only by changing the harness, not the model.
>
> In a moment, I'll walk you through the biggest lessons and hard-won best practices for building agent harnesses, drawing both from my own experience and from the work of frontier teams like Anthropic, OpenAI, and LangChain.
>
> But first, a story that explains why this matters.
>
> A year ago, I was building an agent for a client that needed to optimize live marketing campaigns over long-running execution windows.
>
> This is what the overall solution looked like.
>
> *Campaign optimization architecture*
> ![[deep-agents-001.webp]]
>
> The task initially sounded straightforward: ingest campaign performance data, generate recommendations, apply budget and targeting adjustments, monitor outcomes, and keep iterating until the campaign hit its efficiency goals.
>
> I had a strong model, clean tools, and a workflow that looked solid.
>
> Just ship it, right?
>
> It worked beautifully right up until reality showed up.
>
> The job didn't finish in one neat session.
>
> It ran for hours.
>
> Sometimes it had to wait on delayed reporting data.
> Sometimes an external API timed out.
> Sometimes a worker crashed halfway through an optimization cycle.
>
> And every time that happened, the agent would lose track of where it was.
>
> One failure meant re-running analysis it had already completed, and another meant reprocessing performance snapshots it had already evaluated.
>
> Once, it got all the way through recommendation generation, crashed before execution, and when it came back up it had no idea whether it had already adjusted the campaign or not.
>
> That was the moment it hit me.
>
> I had the best model money could buy, and it was failing at basic operational reliability.
>
> What I didn't have was a harness.
>
> Because in a real production workflow, the harder part is making the intelligence durable.
>
> A harness is everything that is NOT the model.
>
> It's the system prompt, the tools, the middleware, the orchestration layer, the state machine, the checkpointing system, the recovery logic, the persistent memory, the execution logs, the planning infrastructure, and the guardrails around every phase of work.
>
> The significant improvements came when I started treating it like a long-running process.
>
> I had to broke the campaign workflow into explicit phases.
>
> The agent would analyze performance, persist its state, checkpoint its outputs, and only then move to the next step.
>
> After recommendations, another checkpoint.
> After execution, another checkpoint.
> After validation, another checkpoint.
>
> In hindsight, it was obvious from the beginning, but I still got caught up in the belief that AGI was near with every new model release.
>
> Checkpoints resumed tasks from the last successful state.
>
> If a tool failed, the agent knew which phase had completed and which one still needed work.
>
> If the optimization task ran across long time windows, the state stayed intact.
>
> Then for the first time, the agent behaved less like a reliable operator.
>
> That's when I fully understood the idea that the harness is the product.
>
> Running LLMs in a loop was always the original vision for agents, but what makes them usable in production is durable execution.
>
> It's recoverability, structured state, the environment that lets a capable model keep working even when the surrounding systems are messy, delayed, or unreliable.
>
> Models are now good enough to reason, call tools, and iterate.
>
> The real work is building the environment that lets them do that over long-running, failure-prone workflows without falling apart.
>
> The model is the brain, but the harness is the body, the memory, the workflow engine, the checkpoint ledger, the recovery system, and the quality control layer.
>
> This is why understanding the architecture of Deep Agents matters.
>
> It's LangChain's open-source implementation of the harness patterns reverse-engineered from systems like Claude Code, Deep Research, and Manus.
>
> It's under the MIT license, and it captures the engineering patterns the best agent teams have converged on: persistence, planning, tool orchestration, compaction, subagents, and the infrastructure that makes agents reliable beyond a single session.
>
> Honestly, it would have saved me weeks of pain on that campaign optimization system.
>
> Let me take you through the whole thing.
>
> **The Architecture: What Deep Agents Actually Is**
>
> Before diving into code, it helps to understand the stack.
>
> LangChain maintains three layers, and most confusion I see from engineers comes from conflating them.
>
> *The three-layer LangChain stack*
> ![[deep-agents-002.webp]]
>
> LangGraph is the bottom layer, the fundamental infrastructure.
> LangChain is the middle layer, the agent framework with the core abstraction of an LLM running in a loop calling tools.
> Deep Agents is the top layer, an agent harness that does context engineering for you.
>
> The other agent harnesses in this emerging category?
>
> The Claude Agent SDK from Anthropic and Manus. All converging on the same primitives.
>
> **The API**
>
> Here's what it looks like to create a deep agent:
>
> ```python
> from deepagents import create_deep_agent
>
> agent = create_deep_agent(
>   tools=[internet_search],
>   system_prompt="You are an expert researcher...",
> )
>
> result = agent.invoke({"messages": [{"role": "user", "content": "Research X"}]})
> ```
>
> Three parameters and you have an agent with planning, file management, context offloading, and subagent capabilities built in.
>
> That create_deep_agent call returns a LangGraph CompiledStateGraph, which means you get streaming, human-in-the-loop, memory, checkpointing, and LangGraph Studio for free.
>
> The full function signature looks like this:
>
> ```python
> create_deep_agent(
>   model: str | BaseChatModel | None = None,
>   tools: Sequence[BaseTool | Callable | dict[str, Any]] | None = None,
>   *,
>   system_prompt: str | SystemMessage | None = None,
>   middleware: Sequence[AgentMiddleware] = (),
>   subagents: list[SubAgent | CompiledSubAgent] | None = None,
>   skills: list[str] | None = None,
>   memory: list[str] | None = None,
>   response_format: ResponseFormat | None = None,
>   context_schema: type[Any] | None = None,
>   checkpointer: Checkpointer | None = None,
>   store: BaseStore | None = None,
>   backend: BackendProtocol | BackendFactory | None = None,
>   interrupt_on: dict[str, bool | InterruptOnConfig] | None = None,
>   debug: bool = False,
>   name: str | None = None,
>   cache: BaseCache | None = None,
> ) -> CompiledStateGraph
> ```
>
> A few things worth noting:
>
> Default model is claude-sonnet-4-6, but you can use OpenAI, Anthropic, Azure, Google Gemini, AWS Bedrock, or HuggingFace models. The provider:model shorthand (e.g., openai:gpt-5.2) makes swapping easy.
> Connection resilience is built in. LangChain chat models automatically retry with exponential backoff, 6 retries by default for network errors, 429 rate limits, and 5xx server errors. You can tune this per model.
> Every parameter is optional. A bare create_deep_agent() gives you a fully functional agent with planning, filesystem, subagents, and context management. You add specificity as you need it.
>
> The simplicity of the API is deceptive.
>
> What it hides is a stack of middleware, tools, and context management that represents years of convergent evolution across the best agent teams in the world.
>
> **The Four Pillars: Core Harness Primitives**
>
> Every serious agent harness, e.g. Claude Code, Codex, Deep Agents, Manus, has converged on four core primitives.
>
> This isn't coincidence because any agent running long enough to be useful runs into the same problems: losing track of progress, running out of context, getting confused by subtask noise, and not knowing what to do.
>
> Here's how Deep Agents implements each one.
>
> **1. Planning and Task Decomposition**
>
> The write_todos tool is one of those things that sounds too simple to matter. The model generates a to-do list, marks items as in-progress or complete, and adapts the plan as it goes. TodoListMiddleware is auto-attached by create_deep_agent, you don't configure it.
>
> It's very helpful for keeping the agent on track.
>
> It gives the model explicit state to reason about its own progress. Without it, models on long tasks lose track, repeat work, or stop early.
>
> I've been burned by this more times than I can count. You give a model a 10-step task, it nails the first three steps, then on step four it generates a confident-sounding conclusion that ignores steps five through ten.
>
> It literally can't see what it hasn't done yet, especially true for small open-source models.
>
> The to-do list gives models that visibility.
>
> This connects directly to the Ralph Loop pattern, a technique for long-horizon execution where the harness intercepts the model's attempt to exit, reinjects the original prompt in a clean context, and the model reads its to-do list from the filesystem and continues where it left off.
>
> The LangChain team implements this as a PreCompletionChecklistMiddleware that intercepts the agent before it exits and reminds it to run a verification pass.
>
> Planning is the foundation that makes everything else, i.e. filesystem persistence, subagent coordination, long-running execution, actually work.
>
> I want to emphasize something about the build-verify loop that the LangChain team discovered during their Terminal Bench optimization.
>
> From their learnings:
>
> The most common failure pattern was that the agent wrote a solution, re-read its own code, confirmed it looks ok, and stopped. Testing is a key part of autonomous agentic coding. It helps test for overall correctness and simultaneously gives agents signal to hill-climb against.
>
> They added a four-phase problem-solving framework to the system prompt:
>
> Planning and Discovery (read the task, scan the codebase, build an initial plan),
> Build (implement with verification in mind),
> Verify (run tests, read output, compare against what was asked),
> Fix (analyze errors, revisit the spec, fix issues).
>
> The verification step is critical because models have a strong bias toward their first plausible solution.
>
> Without explicit planning that includes verification as a step, agents will consistently declare victory too early.
>
> Anthropic encountered the same problem.
>
> "Absent explicit prompting, Claude tended to make code changes, and even do testing with unit tests or curl commands against a development server, but would fail to recognize that the feature didn't work end-to-end."
>
> Their solution was providing browser automation tools and prompting the agent to test features as a human user would.
>
> The lesson generalizes: agents need both the tools AND the prompting to verify their own work.
>
> **2. Filesystem as Working Memory**
>
> This is the most counterintuitive insight in the entire harness engineering space, and it's the one that changed how I build agents: even research agents (not just coding agents) need filesystems.
>
> FilesystemMiddleware provides ls, read_file, write_file, edit_file, glob, and grep. These aren't there for writing Python files. They're there for context management.
>
> The filesystem unlocks several critical patterns:
>
> Durable state: The agent writes intermediate results to files. If context gets compacted, the knowledge survives. If the agent restarts in a new context window, the files are still there.
> Context offloading: When a tool returns 40,000 tokens of search results, the old approach (what AutoGPT did) was to stuff that entire response into the next message as a tool result. The harness approach: write it to a file, show the model only the first ~1,000 tokens with a pointer, and let the model decide whether to read more.
> Collaboration surface between agents: When a subagent finishes its work, it writes results to the filesystem. The parent agent reads the summary. The full results are available on disk if needed. No context pollution.
> Self-managed context: The model decides what to keep in its working memory and what to offload.
> Git integration for versioning: When the filesystem is backed by a real directory (via FilesystemBackend), agents can use git to track their changes, revert bad edits, and maintain a clean history.
> The AGENTS.md memory pattern: AGENTS.md file gets injected into context on agent start. The agent reads and edits it. Store knowledge from one session, load it in the next.
>
> For now, understand that the filesystem is the single most important primitive in the modern agent harness.
>
> **3. Subagent Spawning for Context Isolation**
>
> SubAgentMiddleware provides a task tool that spawns child agents.
>
> This is where the name "Deep Agents" comes from.
>
> You can spin up sub-agents that are specialized on particular tasks. This provides agents a clear context window and work on those tasks exclusively, where they plan and execute as deep as they can.
>
> Each subagent gets: name identifier, description (used to decide whether to delegate), system_prompt, tools (optional), model (optional — can route different models per task), middleware (optional), interrupt_on (optional).
>
> There is a context isolation. The parent agent stays coherent because subtask context never enters its window. The subagent goes deep into a research question, searches a dozen sources, analyzes results, all in its own context. Then it writes results to the filesystem, reports back a compact summary. The parent never sees those intermediate 50,000 tokens of search results.
>
> Getting the handoff right, i.e. the prompting that ensures subagents report back useful summaries, is a significant part of harness engineering.
>
> In my experience, the sweet spot is 3-7 subagents for a complex task. Fewer than that and you're not getting enough context isolation benefit. More than that and the coordination overhead starts to dominate.
>
> **4. Prompting Still Matters More Than You Think**
>
> In 2026, prompting feels like we should be past it but we're not.
>
> Claude Code's system prompt is ~2,000 lines long, and models' proper alignment with user intent is still critical.
>
> Deep Agents ships a built-in default system prompt that includes detailed instructions for using the planning tool, filesystem tools, and subagents. When middleware adds special tools like the filesystem tools, it automatically appends relevant instructions to the system prompt.
>
> You have to remember: tool descriptions ARE part of the prompt. The model decides whether and how to use a tool based on its description. A poorly described tool is a tool that gets misused.
>
> **Context Engineering**
>
> Context engineering is the discipline of getting the right information to the LLM, in the right structure, at the right moment.
>
> Right information. Right format. Right time.
>
> Not "more information." Not "all information." The right information.
>
> Harnesses today are largely delivery mechanisms for this.
>
> **The Default Middleware Stack**
>
> Every deep agent created with create_deep_agent gets this middleware stack automatically:
>
> *Default middleware stack diagram*
> ![[deep-agents-003.webp]]
>
> If you configure memory, skills, or interrupt_on, you also get: MemoryMiddleware, SkillsMiddleware, HumanInTheLoopMiddleware.
>
> **Custom Middleware**
>
> This is where the harness becomes genuinely powerful. You can intercept every tool call with custom logic.
>
> The @wrap_tool_call decorator gives you a before/after hook on every tool execution. You can add: Logging, Validation, Rate limiting, Cost tracking, Safety checks, Custom compaction logic, PII detection.
>
> The LangChain team's Terminal Bench improvements show this in action: they built LoopDetectionMiddleware, PreCompletionChecklistMiddleware, and LocalContextMiddleware.
>
> They moved the team from 52.8% to 66.5% on Terminal Bench 2.0, changing only the harness, not the model.
>
> **Context Rot and How to Fight It**
>
> Context rot is the degradation of model performance as the context window fills up. Models don't just "run out of space", they get worse at reasoning, more likely to hallucinate, more likely to ignore instructions.
>
> Deep Agents implements three strategies:
>
> 1. Compaction via SummarizationMiddleware — model-directed compaction where the agent triggers it at opportune moments.
> 2. Tool call offloading — large outputs written to filesystem with truncated previews.
> 3. Skills as progressive disclosure — smaller system prompt at startup, load detailed instructions on demand.
>
> **The Skills System**
>
> Think of it this way: tools are functions the agent can call. Skills are knowledge the agent can load. Subagents are agents the agent can delegate to.
>
> *Tools vs Skills vs Subagents cost comparison*
> ![[deep-agents-004.webp]]
>
> Getting this taxonomy right is the difference between an agent that costs $0.50 per run and one that costs $15.
>
> **Backends and Sandboxes: Where Agents Actually Run**
>
> The agent doesn't need to know whether it's writing to memory, disk, a cloud store, or a Docker container. It just uses write_file and read_file.
>
> Built-in Backends: StateBackend (default, ephemeral), FilesystemBackend (local disk), LocalShellBackend (filesystem + execute), StoreBackend (durable cross-thread), CompositeBackend (route different paths to different backends).
>
> Custom Backends implement BackendProtocol with six methods: ls_info, read, grep_raw, glob_info, write, edit.
>
> **Sandbox Deep Dive**
>
> Two architectural patterns: Agent in Sandbox (runs inside container) vs Sandbox as Tool (recommended — agent on host, code execution in remote sandbox).
>
> *Sandbox providers comparison*
> ![[deep-agents-005.webp]]
>
> **Human-in-the-Loop**
>
> Per-tool granularity via interrupt_on parameter. Three decision types: Approve, Edit, Reject. Supports nested approval chains with subagents.
>
> **Memory: Three Types for Production Agents**
>
> 1. Procedural Memory (AGENTS.md files and skills) — how to do things. ~80% of memory improvement.
> 2. Semantic Memory (vector databases, knowledge graphs) — facts and knowledge.
> 3. Episodic Memory (previous thread search) — what happened before.
>
> Hierarchy: start with procedural, add episodic for recurring tasks, add semantic if domain requires it.
>
> **Structured Output**
>
> Pydantic models for constraining agent results. Essential for agent pipelines and downstream system integration.
>
> **The Model-Harness Co-Evolution Problem**
>
> Models are post-trained with harnesses in the loop, creating overfitting. But the best harness for YOUR task is not necessarily the one the model was trained with. The Terminal Bench proof: same model, different harness = Top 30 to Top 5.
>
> The LangChain team literally built an agent to improve their agent's harness — analyzing traces of failed runs, identifying patterns, and suggesting harness changes.
>
> **Building Real Systems: Patterns from Production**
>
> Pattern 1: The Enterprise Support Agent — Klarna's lesson that agents need to know their boundaries. HITL as a product feature.
>
> Pattern 2: The Research Agent — Plan, fan out subagents, aggregate in filesystem, synthesize.
>
> Pattern 3: The Long-Running Autonomous Agent — The Ralph Loop pattern for multi-hour runs with checkpointing and clean context reinjection.
>
> *Long-running agent failure modes and solutions*
> ![[deep-agents-006.webp]]
>
> Pattern 4: The Coding Agent as General-Purpose Agent — OpenClaw's success from sandbox + freedom to write whatever tool it needs.
>
> **Concluding Thoughts**
>
> We're at the "Rails moment" for agent engineering. The core algorithm is settled (LLM in a loop calling tools). The core primitives are converging. What remains is optimizing the harness for your specific task.
>
> Same model + different harness = a jump from outside the Top 30 to the Top 5 on a respected benchmark.
>
> The harness is the product.
>
> [Original article](https://agentnativedev.medium.com/deep-agents-the-harness-behind-claude-code-codex-manus-and-openclaw-bdd94688dfdb)
