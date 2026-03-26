---
created: 2026-03-26
description: PostHog shares five lessons from building their AI agent over two years, concluding that custom harnesses waste innovation points and MCP plus the Claude Agent SDK is the right architecture.
source: https://x.com/posthog/status/2036847339466301918
type: learning
---

# PostHog learned your agent harness is not your moat and switched to the Claude Agent SDK after three iterations

## Key Takeaways

PostHog's journey through three harness architectures is the clearest real-world validation of the thesis that [[the harness is the product because model capability is commoditizing while accumulated context is not]]. Their first harness (coordinator routing to sub-agents) failed because of context loss — the same black-box problem that plagues multi-agent orchestration generally. Their second (single loop with 44 hand-built tools) didn't scale because [[designing agent tools is an iterative art shaped by model capabilities not fixed engineering rules]] — writing tools one-by-one is a losing strategy when a sandbox can let the model improvise.

The punchline: they landed on the [[anthropic-mcp-code-execution|Claude Agent SDK with MCP tools and a code-execution sandbox]], which matches the converging architecture pattern documented in [[agent harness is the real product]]. The sandbox unlocked creativity the hand-built tools couldn't, and MCP made their built-in agent and external MCP server converge on one interface.

Their "should you even build an agent?" framing is refreshingly honest — 34% of AI-created dashboards came through their MCP server, not the built-in agent. This echoes the [[harness engineering improved a coding agent 13 points by changing only system prompts tools and middleware|principle]] that sometimes the best agent is no agent at all, just a well-structured API surface.

The context engineering section maps directly to patterns in [[how top ai companies handle context engineering]]: MCP tools as capabilities, markdown "skills" as workflow templates rendered at build time (exactly the SKILL.md pattern from [[Factory plugins marketplace uses a git-native catalog with SKILL.md files as the primary distribution unit for agent capabilities|Factory's plugin system]]), layered runtime context injection, a taxonomy tool for on-demand exploration instead of upfront stuffing, and a memory onboarding flow for persistent personalization.

Their emphasis on observability from day one — tracing, replay, "traces hour" manual analysis, LLM-as-judge evals — reinforces that [[lessons from building AI agents for financial services — sandbox skills streaming and eval at Fintool|domain-specific evals rooted in real usage]] are the only evals that matter.

Finally, the user feedback section is a grounding reminder: users don't care about capability range, they care about consistency, clear errors, and signs of progress. Building agents is [[the harness is everything and agent performance comes from environment design not model capability|a product engineering problem, not an AI showcase]].

## External Resources

- [PostHog AI](https://posthog.com/ai) — their built-in AI agent product
- [PostHog MCP Server docs](https://posthog.com/docs/model-context-protocol)
- [Claude Agent SDK](https://platform.claude.com/docs/en/agent-sdk/overview)
- [Anthropic: Building Effective Agents](https://www.anthropic.com/engineering/building-effective-agents)
- [AmpCode: How to Build an Agent](https://ampcode.com/notes/how-to-build-an-agent)
- [PostHog architecture handbook](https://posthog.com/handbook/engineering/ai/architecture) — their harness architecture docs
- [PostHog: Implementing MCP tools](https://posthog.com/handbook/engineering/ai/implementing-mcp-tools)
- [PostHog: Writing skills](https://posthog.com/handbook/engineering/ai/writing-skills)
- [PostHog skills example (GitHub)](https://github.com/PostHog/posthog/blob/master/products/posthog_ai/skills/query-examples/SKILL.md)
- [PostHog taxonomy tool (GitHub)](https://github.com/PostHog/posthog/blob/master/ee/hogai/tools/read_taxonomy/mcp_tool.py)
- [PostHog memory onboarding (GitHub)](https://github.com/PostHog/posthog/blob/master/ee/hogai/chat_agent/memory/nodes.py)
- [PostHog context injection (GitHub)](https://github.com/PostHog/posthog/blob/master/ee/hogai/context/context.py)
- [PostHog LLM Analytics](https://posthog.com/llm-analytics)
- [PostHog: 8 Learnings from 1 Year of Agents](https://posthog.com/blog/8-learnings-from-1-year-of-agents-posthog-ai)

## Original Content

> [!quote]- Source Material
>
> **What we wish we knew about building AI agents**
> *By [PostHog](https://x.com/posthog) · March 25, 2026 · [Original post](https://x.com/posthog/status/2036847339466301918)*
>
> One thing on every startup's mind: Should we build an AI agent?
>
> We had this thought two years ago, released an "AI product assistant" 6 months later, iterated, and then relaunched as [PostHog AI](https://posthog.com/ai) in November last year
>
> We learned a lot along the way that we wished we knew when we started. With that knowledge, we could have…
>
> 1. Launched months earlier.
> 2. Provided a better early experience to users.
> 3. Made progress on capabilities faster.
>
> To help you build a better agent faster, we're sharing what we wished we had known about building AI agents.
>
> ## 1. Should you build an MCP server instead?
>
> Should you even build an AI agent into your product? The capabilities of agents are unquestionably valuable but this does not mean you need to build a custom one. Making your product accessible to agents is often a better option.
>
> Could your agent capabilities just be an [MCP server](https://posthog.com/docs/model-context-protocol)? These are simpler to build and require less maintenance, and for us, is used as much as our built-in agent, PostHog AI. For example, 34% of dashboards created by AI were done through our MCP server (18% of all dashboards created).
>
> *Sources of dashboards created last week*
> ![[posthog-301918-dashboard-sources.jpg]]
>
> MCP servers are great if you expect your users to be developers or people combining your product with others in their ✨*agentic workflows*✨. Just as importantly, MCP servers validate demand for further agentic capabilities.
>
> Custom agents are better when your users are [non-engineers](https://posthog.com/newsletter/engineeringification-of-everything), when compliance blocks external agents, or when you need full control of the user experience (for example, custom image generation).
>
> Even when you decide to go custom, consider if simpler alternatives fit your use case:
>
> - For one-shot Q&A like generating product descriptions, try a simple LLM call with good prompting
> - For a single task like SQL or code generation, use a specialized model with structured output
> - For a multi-step but predictable flow like email classification plus response drafting, create a hardcoded workflow with LLM steps
>
> Although PostHog AI is an agent now, we validated demand for it with a simpler use case and system. We built a workflow for data-related questions like "How many people signed up last week?" which lead directly to insight generation.
>
> Only once this workflow saw adoption and users demanded other use cases (like answering docs questions or [creating feature flags](https://posthog.com/docs/feature-flags/creating-feature-flags)) did the team build an agent.
>
> ## 2. Your harness is not your moat
>
> Once you decide to build an agent, the next question is how will it work. The answer to this is an agent harness: the code and infrastructure that combines with a model to help it understand and use your product.
>
> You aren't going to win because you've created some genius new harness, especially if you're building your first AI agent. Don't use innovation points here. Anthropic wrote a [perfectly good SDK](https://platform.claude.com/docs/en/agent-sdk/overview), and both [Anthropic](https://www.anthropic.com/engineering/building-effective-agents) and [AmpCode](https://ampcode.com/notes/how-to-build-an-agent) have helpful guides.
>
> If we were restarting today, we would have skipped building a custom harness and made MCP the canonical interface. We learned this the hard way through three iterations of PostHog AI this year.
>
> The [first harness](https://posthog.com/blog/8-learnings-from-1-year-of-agents-posthog-ai) was a coordinator that routed user messages to specialized sub-agents, but this created a black box problem as the coordinator couldn't see what sub-agents were doing leading to context loss and confusion.
>
> The [second](https://posthog.com/handbook/engineering/ai/architecture) was a single agent loop with self contained modes and tools within each mode. This solved the visibility issue, but didn't scale. If we didn't write a tool, the capability wouldn't exist. This led us to spending a lot of time writing tools (44 by the end) rather than improving in other ways.
>
> Our third and current harness uses the Claude Agent SDK with MCP tools and skills. This change came from two realizations:
>
> 1. **Our agent could be more creative.** The Claude Agent SDK gives PostHog AI access to a code-execution sandbox. The agent can use it to query with SQL and run custom scripts, unlocking new capabilities without us needing to build them.
> 2. **Agents are a primary persona.** Our "users" are increasingly agents, whether that is through PostHog AI or our [MCP server](https://posthog.com/docs/model-context-protocol). Our work here should converge and support both using a single architecture.
>
> The flexibility of the sandbox plus the scalability of MCP tools and skill standards (which I'll explain more about later) solves the issues of the second harness and positions us better for an agent-first future.
>
> *PostHog AI harness architecture evolution*
> ![[posthog-301918-harness-architecture.jpg]]
>
> ## 3. Your context is your advantage
>
> When building an agent, there's ultimately one question you need to answer to succeed: How does this beat Claude?
>
> Context is the most important part of an answer. The combination of your app's functionality and user data create a unique blend no other product can match.
>
> Although you have product and user context sitting around, you need structure and format it to be useful for the agent. We do this with:
>
> 1. **[MCP tools](https://github.com/PostHog/posthog/blob/master/products/data_warehouse/mcp/tools.yaml).** Capabilities [selected and extracted from the PostHog API](https://posthog.com/handbook/engineering/ai/implementing-mcp-tools) to expose all possible actions that agents can perform in PostHog. Examples include list feature flags, create a survey, or execute an SQL query.
> 2. **[Skills](https://github.com/PostHog/posthog/blob/master/products/posthog_ai/skills/query-examples/SKILL.md).** Markdown files [we write to teach the agent complete workflows](https://posthog.com/handbook/engineering/ai/writing-skills) and how to use our product. These include query patterns, system table schemas, examples, and MCP tool references. They are templates rendered at build time, so they can pull live context from the codebase like model schemas.
> 3. **[Layered runtime context injection](https://github.com/PostHog/posthog/blob/master/ee/hogai/context/context.py).** The frontend sends the user's current view and state such as dashboards, insights, [session recordings](https://posthog.com/session-replay), and filters. This is enriched with actual queries results and project metadata like timezone and organization name.
> 4. **[A taxonomy tool](https://github.com/PostHog/posthog/blob/master/ee/hogai/tools/read_taxonomy/mcp_tool.py).** This lets the agent explore the user's event names, properties, and property values on demand rather than stuffing them all into the prompt upfront.
> 5. **[A memory onboarding flow](https://github.com/PostHog/posthog/blob/master/ee/hogai/chat_agent/memory/nodes.py).** This collects company and product context through conversation and persists it across sessions, so the agent builds understanding of each user's setup over time.
>
> Without this structured product context, the agent struggles to understand both our product and the user's goals. It can get lost on simple questions because the context behind those questions is complex.
>
> Reality has a surprising amount of detail and people define tasks in ambiguous ways. How would you answer "where do users drop off in CFMP conversion" without context?
>
> ## 4. Set up observability and evaluation from day one
>
> These are essential as AI agents are non-deterministic and [can fail in unpredictable ways](https://posthog.com/newsletter/ai-coding-mistakes). Without visibility into this, you can't improve them or catch regressions.
>
> We didn't have observability and evaluation early and regretted it. We wish we had:
>
> - [Tracing](https://posthog.com/docs/llm-analytics/traces) for every LLM call with inputs, outputs, latency, and cost
> - Trace IDs that span the full conversation
> - The ability to [replay and debug](https://posthog.com/docs/llm-analytics/sessions) specific interactions
> - A [curated datasets](https://posthog.com/docs/llm-analytics/clusters) of real user queries
> - Automated scorers like [LLM-as-judge](https://posthog.com/blog/stop-ai-slop) and deterministic checks
>
> Basically, [LLM analytics](https://posthog.com/llm-analytics).
>
> Unfortunately, LLM analytics alone isn't enough. Reality is gnarly and to deal with it, our team often looks at real usage.
>
> They run a "traces hour," where they meet, manually analyze LLM traces (AKA real user interactions), and find areas to improve. [Evals](https://posthog.com/docs/llm-analytics/evaluations) make the most sense when they stem from these investigations.
>
> Like building any successful product, understanding a user's experience is critical to building a successful agent.
>
> ## 5. It doesn't matter how cool your capabilities are
>
> After getting buried in technical details, it's important to poke your head out and remember who you're building for. You're not building for some hypothetical "coolest AI agent" contest, you're building for your users.
>
> *User feedback on PostHog AI pain points*
> ![[posthog-301918-user-feedback.jpg]]
>
> What users want is often at odds with what's coolest. The most common pain points users faced weren't our agent's range of capabilities or functionality, but things like:
>
> - Inconsistent performance
> - Unexpected failures
> - Generic error messages without clear explanation
> - Unclear capabilities leading to complex queries failing
> - Lack of signs of uncertainty, source of insights, and progress
>
> While new capabilities are cool, ensuring your agent actually solves your customer's problems is even cooler. Ultimately, building an AI agent is not just a showcase of your AI skillz, but a [product engineering problem](https://posthog.com/blog/what-is-a-product-engineer). This requires you to talk to users, ship features they want, and iterate.
>
> ---
>
> *Words by [Ian Vanagas](https://x.com/ianvanagas) who has plenty of agentic capabilities himself if you ask nicely.*
>
> For more posts like this, [subscribe to our newsletter](https://go.posthog.com/newsletter-x).
