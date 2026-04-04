---
created: 2026-04-04
description: Harrison Chase's three-layer framework decomposes continual learning for AI agents into model weights, harness code, and context configuration — arguing that context is the cheapest and fastest lever while model updates carry the highest ceiling but steepest cost.
source: https://x.com/hwchase17/status/2040467997022884194
type: framework
---

## Key Takeaways

Harrison Chase decomposes agent improvement into three nested layers — model (weights), harness (code + fixed instructions/tools), and context (configurable instructions, skills, memory). This maps cleanly onto the taxonomy the vault already tracks: [[meta-harness optimizes LLM system harnesses through automated search over code and execution traces|Meta-Harness]] operates at the harness layer, while [[memento-skills turns executable skill folders into evolving non-parametric memory that lets frozen LLMs learn continuously from deployment|Memento-Skills]] and [[dual-stream experience and skill accumulation enables multimodal agents to continually improve tool use without parameter updates|XSkill]] both demonstrate context-layer learning with frozen weights.

The comparison table is the most useful artifact. Context updates are the cheapest, fastest, and most inspectable lever — but have a medium impact ceiling. Model weight updates have the highest ceiling but are expensive, slow, and opaque. Harness engineering sits in between. All three share a "batch offline job" update pattern, but only context can also be updated in the hot path while the agent is running. This echoes the vault's existing insight that [[context management replaces the semantic layer for data agents because it adapts from corrections]].

The context layer can operate at multiple granularities — agent-wide, per-user, per-org, per-team — which makes it the only layer that naturally supports tenant-level personalization without retraining. OpenClaw's SOUL.md is called out as an example of agent-level context learning, while products like Hex Context Studio and Sierra Explorer demonstrate tenant-level context. This connects to [[PARA and atomic facts give AI agents durable structured memory]] and [[multi-agent memory needs computer architecture style hierarchy and consistency models]] — the memory hierarchy problem is really about organizing the context layer at different scopes.

The article highlights two timing patterns for context updates: in the hot path (synchronous, adds latency) and in background jobs (asynchronous, like OpenClaw's "dreaming"). The harness layer uses a Meta-Harness-style loop: run tasks, evaluate, store traces, then let a coding agent propose harness changes. All flows depend on traces as the shared substrate — which is LangChain's pitch for LangSmith as the trace collection layer and Deep Agents as the harness.

The OpenClaw and Claude Code examples ground the taxonomy in concrete systems. For Claude Code: Model = claude-sonnet, Harness = Claude Code itself, Context = CLAUDE.md + /skills + mcp.json. For OpenClaw: Model = many, Harness = Pi + scaffolding, Context = SOUL.md + ClawhHub skills. This three-layer decomposition is a useful mental model for deciding *where* to invest optimization effort — and the answer for most practitioners is context first, harness second, model last. This aligns with [[the-harness-is-the-product-because-model-capability-is-commoditizing-while-accumulated-context-is-not|the harness is the product because model capability is commoditizing while accumulated context is not]] and [[agent harness is the real product|the broader harness engineering thesis]].

## External Resources

- [Meta-Harness: End-to-End Optimization of Model Harnesses](https://yoonholee.com/meta-harness/) — paper on automated harness optimization through iterative code search
- [LangChain: Anatomy of an Agent Harness](https://blog.langchain.com/the-anatomy-of-an-agent-harness/) — LangChain's definition and breakdown of harness components
- [LangChain: Improving Deep Agents with Harness Engineering](https://blog.langchain.com/improving-deep-agents-with-harness-engineering/) — how harness-only changes improved Terminal Bench scores
- [OpenClaw SOUL.md docs](https://docs.openclaw.ai/concepts/soul) — context-layer learning via evolving personality/instruction files
- [OpenClaw Memory & Dreaming](https://docs.openclaw.ai/concepts/memory-dreaming) — background context consolidation pattern
- [LangSmith CLI](https://docs.langchain.com/langsmith/langsmith-cli) — trace collection for harness improvement loops
- [Deep Agents Memory docs](https://docs.langchain.com/oss/python/deepagents/memory) — user-scoped memory and background consolidation in LangChain's harness
- [Hex Context Studio](https://hex.tech/product/context-studio/) — tenant-level context learning for data agents
- [Decagon Duet](https://decagon.ai/blog/introducing-duet) — tenant-level context updates for support agents
- [Sierra Explorer](https://sierra.ai/blog/explorer) — tenant-level context learning for conversational agents
- [Prime Intellect](https://www.primeintellect.ai/) — model training from agent traces
- [SFT guide](https://cameronrwolfe.substack.com/p/understanding-and-using-supervised) — supervised fine-tuning overview
- [GRPO guide](https://cameronrwolfe.substack.com/p/grpo) — group relative policy optimization for RL
- [LoRA guide](https://unsloth.ai/docs/get-started/fine-tuning-llms-guide/lora-hyperparameters-guide) — low-rank adaptation hyperparameters

## Original Content

> @hwchase17 (Harrison Chase) — 2026-04-04
>
> Article: Continual learning for AI agents
>
> Most discussions of continual learning in AI focus on one thing: updating model weights. But for AI agents, learning can happen at three distinct layers: the model, the harness, and the context. Understanding the difference changes how you think about building systems that improve over time.
>
> The three main layers of agentic systems are:
>
> - Model: the model weights themselves.
> - Harness: the harness around the model that powers all instances of the agent. This refers to the code that drives the agent, as well as any instructions or tools that are always part of the harness.
> - Context: additional context (instructions, skills) that lives outside the harness, and can be used to configure it.
>
> *Three-layer nested architecture: Context wraps Harness wraps Model*
> ![[hwchase17-884194-002.jpg]]
>
> Example #1: Mapping this a coding agent like Claude Code:
>
> - Model: claude-sonnet, etc
> - Harness: Claude Code
> - User context: CLAUDE.md, /skills, mcp.json
>
> Example #2: Mapping this to OpenClaw:
>
> - Model: many
> - Harness: Pi + some other scaffolding
> - Agent context: SOUL.md, skills from clawhub
>
> When we talk about continual learning, most people jump immediately to the model. But in reality - an AI system can learn at all three of these levels.
>
> **Continual learning at the model layer**
>
> When most people talk about continual learning, this is what they most commonly refer to: updating the model weights.
>
> Techniques to update this include SFT, RL (e.g. GRPO), etc.
>
> A central challenge here is catastrophic forgetting — when a model is updated on new data or tasks, it tends to degrade on things it previously knew. This is an open research problem.
>
> When people do train models for a specific agentic system (e.g. you could view the OpenAI codex models as being trained for their Codex agent) they largely do this for the agentic system as a whole. In theory, you could do this at a more granular level (e.g. you could have a LORA per user) but in practice this is mostly done at the agent level.
>
> **Continual learning at the harness layer**
>
> As defined earlier, the harness refers to the code that drives the agent, as well as any instructions or tools that are always part of the harness.
>
> As harnesses have become more popular, there have been several papers that talk about how to optimize harnesses.
>
> A recent one is Meta-Harness: End-to-End Optimization of Model Harnesses.
>
> *Meta-Harness iterative optimization loop: propose harness code → evaluate against tasks with frozen LLM → store logs → repeat*
> ![[hwchase17-884194-003.jpg]]
>
> The core idea is that the agent is running in a loop. You first run it over a bunch of tasks, and then evaluate them. You then store all these logs into a filesystem. You then run a coding agent to look at these traces, and suggest changes to the harness code.
>
> Similar to continual learning for models, this is usually done at the agent level. You could in theory do this at a more granular level (e.g. learn a different code harness per user).
>
> **Continual learning at the context layer**
>
> "Context" sits outside the harness and can be used to configure it. Context consists of things like instructions, skills, even tools. This is also commonly referred to as memory.
>
> This same type of context exists inside the harness as well (e.g. the harness may have base system prompt, skills). The distinction is whether it is part of the harness or part of the configuration.
>
> Learning context can be done at several different levels.
>
> Learning context can be done at the agent level - the agent has a persistent "memory" and updates its own configuration over time. A great example is OpenClaw which has its own SOUL.md that gets updated over time.
>
> Learning context is more commonly done at the tenant level (user, org, team, etc). In this case each tenant gets their own context that is updated over time. Examples include Hex's Context Studio, Decagon's Duet, Sierra's Explorer.
>
> You can also mix and match! So you could have an agent with agent level context updates, user level context updates, AND org level context updates.
>
> These updates can be done in two ways:
>
> - After the fact in an offline job. Similar to harness updates - run over a bunch of recent traces to extract insights and update context. This is what OpenClaw calls "dreaming".
> - In the hot path as the agent is running. The agent can decided to (or the user can prompt it to) update its memory as it is working on the core task.
>
> *Two patterns for memory updates: synchronous in the hot path vs. asynchronous background process*
> ![[hwchase17-884194-004.jpg]]
>
> Another dimension to consider here is how explicit the memory update is. Is the user prompting the agent to remember, or is the agent remembering based on core instructions in the harness itself?
>
> **Comparison**
>
> *Comparison table: Model vs Harness vs Context across form factor, granularity, cost/speed, inspectability, impact ceiling, and update pattern*
> ![[hwchase17-884194-001.jpg]]
>
> *Detailed comparison table with color coding: red for expensive/slow (model), green for cheap/fast (context)*
> ![[hwchase17-884194-005.jpg]]
>
> **Traces are the core**
>
> All of these flows are powered by traces - the full execution path of what an agent did. LangSmith is our platform that (among other things) helps collect traces.
>
> You can then use these traces in a variety of different ways.
>
> If you want to update the model, you can collect traces and then work with someone like Prime Intellect to train your own model.
>
> If you want to improve the harness, you can use LangSmith CLI and LangSmith Skills to give a coding agent access to these traces. This pattern is how we improved Deep Agents (our open source, model agnostic, general purpose base harness) on terminal bench.
>
> If you want to learn context over time (either at the agent, user, or org level) - then your agent harness needs to support this. Deep Agents - our harness of choice - supports this in a production ready way. See the documentation there for examples of how to do user-level memory, background learning, and more.
>
> Thank you to @sydneyrunkle @Vtrivedy10 @nfcampos for review and feedback on this article
>
> Engagement: 207 likes | 31 retweets | 11 replies
> [Original post](https://x.com/hwchase17/status/2040467997022884194)
