---
created: 2026-03-02
description: AI agents degrade with excess context; progressive disclosure — layered, on-demand context loading — produces smarter systems than bigger context windows.
source: https://www.honra.io/articles/progressive-disclosure-for-ai-agents
type: reference
---

## Key Takeaways

Progressive disclosure, a UX principle from the 1990s Nielsen Norman Group work, maps directly onto agent architecture as a three-layer pattern: lightweight index metadata for routing, full content loaded on relevance, and deep-dive materials accessed only when needed. This is the same layered approach described in [[progressive disclosure filters force agent selectivity over what enters context]], but here applied specifically to production agent systems like Claude Code's Skills.

The article names a key failure mode — "context rot" — where front-loading everything into the system prompt actively degrades agent reasoning by introducing noise into the attention mechanism. This reinforces what [[designing agent tools is an iterative art shaped by model capabilities not fixed engineering rules]] found from Anthropic's own tool design experience: less surface area, better outcomes.

The Claude Code Skills case study is the most concrete example: Phase 1 loads only skill names and descriptions, Phase 2 activates full content on match with user confirmation, Phase 3 pulls supporting files on demand. Forked contexts (sub-agents) prevent multi-step operations from polluting the main thread. This is essentially the architecture behind [[skill graphs outperform single skill files by letting agents traverse linked domain knowledge on demand]].

The article frames RAG, Tool RAG, and memory systems all as instances of the same progressive disclosure pattern — retrieval becoming an iterative process within a reasoning loop rather than a one-shot preprocessing step. MCP embodies this by treating retrieval itself as a tool the agent invokes when it determines additional context would help.

The practical heuristic "two-tier everything" — always maintain a lightweight index alongside detailed content — distills the design principle. Quality of metadata descriptions determines quality of routing decisions, making description writing a first-class engineering concern rather than documentation afterthought.

## External Resources

- [What is Progressive Disclosure?](https://www.interaction-design.org/literature/topics/progressive-disclosure) — Interaction Design Foundation overview of the UX principle
- [Tool RAG: The Next Breakthrough in Scalable AI Agents](https://next.redhat.com/2025/11/26/tool-rag-the-next-breakthrough-in-scalable-ai-agents) — Red Hat on retrieving relevant tools from large registries
- [From RAG to Context: A 2025 Year-End Review](https://ragflow.io/blog/rag-review-2025-from-rag-to-context) — RAGFlow retrospective on retrieval evolution
- [Context Engineering for AI Agents](https://weaviate.io/blog/context-engineering) — Weaviate on treating context as engineered input
- [Agentic Retrieval-Augmented Generation: A Survey](https://arxiv.org/abs/2501.09136) — Academic survey on agentic RAG patterns
- [Claude Code Skills Documentation](https://code.claude.com/docs/en/skills) — Anthropic's official Skills reference

## Original Content

> [!quote]- Source Material
>
> *Hero image: Progressive disclosure concept illustration*
> ![[honra-progdisc-001.jpeg]]
>
> February 11, 2026
>
> # Progressive Disclosure for AI Agents: Why Less Context Means Smarter Systems
>
> In the 1990s, usability researchers at Nielsen Norman Group popularized a concept called progressive disclosure: show users only what they need right now, and defer advanced features until requested. The goal was simple -reduce cognitive load, prevent overwhelm, and let people focus on the task at hand.
>
> Thirty years later, this principle is finding unexpected new life. Not in user interfaces, but inside AI agents themselves.
>
> As organizations race to build AI systems that can reason, plan, and act autonomously, they're discovering a counterintuitive truth: agents get dumber when you give them too much information upfront. The solution isn't bigger context windows. It's smarter context management -and progressive disclosure is emerging as the defining pattern.
>
> ## The Kitchen Sink Problem
>
> When developers first build AI agents, the instinct is to front-load everything. Company documentation, API references, coding guidelines, past conversation history, tool definitions -throw it all into the system prompt. More context means better answers, right?
>
> Wrong. This "kitchen sink" approach creates what practitioners call context rot. As irrelevant information accumulates, the agent's effective intelligence degrades. It struggles to identify what matters. It hallucinates connections between unrelated concepts. It loses track of the actual task.
>
> The problem is architectural, not just computational. Large language models process context through attention mechanisms that weigh every token against every other token. When you stuff the context window with marginally relevant information, you're not just wasting tokens -you're actively introducing noise into the reasoning process.
>
> Think of it like trying to have a focused conversation in a crowded room where everyone is talking at once. The information you need might be present, but it's drowned out by everything else competing for attention.
>
> The false intuition that more information equals better results has led teams to build increasingly baroque prompt architectures, only to find diminishing returns. The answer isn't more context. It's the right context, at the right time.
>
> ## Progressive Disclosure: A Quick Primer
>
> Progressive disclosure, at its core, is about layered revelation. You start with the minimum viable information, then expand based on need.
>
> In traditional UX, this manifests as collapsible menus, "advanced settings" toggles, and wizard-style workflows that reveal complexity one step at a time. The user sees what they need to accomplish their immediate goal, with deeper functionality available on demand.
>
> Applied to AI agents, the pattern translates into a three-layer architecture:
>
> * **Layer 1 (Index):** Lightweight metadata -titles, descriptions, capabilities, token counts. Enough to know what exists and make routing decisions.
> * **Layer 2 (Details):** Full content, loaded only when the agent determines it's relevant to the current task.
> * **Layer 3 (Deep Dive):** Supporting materials, examples, and reference documentation, accessed only when the agent needs to go deeper.
>
> The philosophy is elegant: provide the map, let the agent choose the path. Context becomes a resource to be spent wisely, not a dump truck to be emptied into every conversation.
>
> ## Case Study: Claude Code's Skills Architecture
>
> Anthropic's Claude Code offers a compelling implementation of progressive disclosure through its Skills feature. Skills are reusable capabilities -workflows, domain knowledge, specialized instructions -stored as markdown files in a filesystem hierarchy.
>
> What makes the architecture interesting isn't what Skills contain, but how they load.
>
> **Phase 1: Discovery.** At startup, Claude loads only Skill names and descriptions. A user might have dozens of Skills installed, but the agent sees just metadata -enough to know what's available without consuming meaningful context. This keeps initialization fast and the base context lean.
>
> **Phase 2: Activation.** When a user's request matches a Skill's description, Claude asks for permission to load it. Only after confirmation does the full Skill content enter context. This creates an explicit control point: users know exactly when specialized knowledge is being activated.
>
> **Phase 3: Execution.** Once activated, the Skill can reference supporting files -examples, API documentation, utility scripts. These load on demand as the agent works through the task. Scripts are executed but not read into context; their outputs consume tokens, not their source code.
>
> The architecture also supports forked contexts. Complex Skills can run in isolated sub-agents with separate conversation histories, preventing multi-step operations from polluting the main thread. When the fork completes, only the results return.
>
> This three-phase approach means an agent can have access to extensive capabilities while paying only minimal context cost upfront - just the lightweight metadata needed for routing decisions. The system scales well: the context cost grows with what you actually use, not with what you have installed.
>
> ## The Broader Pattern: RAG, Tools, and Memory
>
> Claude's Skills are one implementation, but progressive disclosure is becoming the organizing principle across AI agent architectures.
>
> **Retrieval-Augmented Generation (RAG)** is fundamentally a progressive disclosure pattern. Instead of fine-tuning a model with all relevant knowledge, RAG systems retrieve only the chunks relevant to the current query. The knowledge base might contain terabytes of documentation, but each inference sees only the most pertinent fragments.
>
> **Tool RAG** extends this principle to capabilities. As enterprise agents grow to support dozens or hundreds of tools, exposing all of them simultaneously overwhelms the model. Tool RAG retrieves only the tools relevant to the current task from a larger registry, just as classic RAG retrieves relevant knowledge from a larger corpus.
>
> **Memory systems** implement progressive disclosure temporally. Short-term memory lives in the context window -recent messages, current task state. Long-term memory lives in external stores, retrieved when the agent needs to recall past interactions, user preferences, or historical context. Most modern systems implement hybrid memory: immediate context for what's happening now, retrieval for everything else.
>
> Anthropic's Model Context Protocol (MCP) embodies this philosophy by treating retrieval itself as a tool. Rather than preloading information, agents invoke retrieval capabilities when they determine additional context would help. The agent decides what it needs, when it needs it.
>
> The pattern is converging: retrieval is becoming an iterative process within a reasoning loop, not a one-shot preprocessing step. Context is written, compressed, and isolated dynamically throughout execution.
>
> ## The Trade-offs
>
> Progressive disclosure isn't free. Loading information on demand introduces latency. The agent must make routing decisions about what to load, adding complexity. And those decisions can be wrong -an agent might fail to retrieve relevant context because its metadata didn't surface as matching.
>
> The core trade-off is latency versus accuracy. Front-loading context means the information is immediately available, but at the cost of noise and bloat. Loading on demand keeps context clean, but introduces retrieval delays and the risk of missing something important.
>
> The "two-tier everything" principle offers a practical heuristic: always maintain a lightweight index layer alongside detailed content. Invest heavily in good metadata and descriptions -they're the routing mechanism that determines what gets loaded. Poor descriptions mean poor routing decisions.
>
> Teams also learn to limit disclosure depth. Just as UX research suggests keeping progressive disclosure to 2-3 layers to avoid user frustration, agent architectures benefit from similar constraints. Deep chains of nested references can cause partial loads or context fragmentation.
>
> ## Implications for Product Builders
>
> For teams building AI agents, progressive disclosure suggests several design principles:
>
> **Design for layers.** Structure knowledge, tools, and capabilities with explicit index and detail tiers. Every component should have lightweight metadata that supports routing decisions without requiring full content loads.
>
> **Invest in descriptions.** The quality of your metadata determines the quality of your routing. Descriptions aren't documentation -they're the trigger terms and semantic signals that help agents decide what's relevant.
>
> **Respect context as currency.** Every token loaded is a token that competes for attention. Treat context window space as a scarce resource to be allocated deliberately, not a bucket to be filled.
>
> **Build explicit control points.** Users should understand when and why additional context is being loaded. Transparency about what the agent knows -and when that changes -builds trust.
>
> **Keep it shallow.** Avoid deep chains of progressive disclosure. Two to three layers is typically sufficient; beyond that, you're trading complexity for diminishing returns.
>
> ## Conclusion
>
> Progressive disclosure is ultimately about respect -for the limits of attention, whether human or artificial. The most capable AI systems won't be the ones with the largest context windows or the most comprehensive knowledge bases. They'll be the ones that know what to know, and when to know it.
>
> The pattern isn't new. It's a lesson from decades of human-computer interaction research, finding new application in a new medium. As AI agents grow more sophisticated, the principles that made interfaces usable will make agents intelligent.
>
> Less context, thoughtfully managed, means smarter systems. The art isn't in knowing everything. It's in knowing when to look.
>
> ## Sources & Further Reading
>
> * [What is Progressive Disclosure?](https://www.interaction-design.org/literature/topics/progressive-disclosure) - Interaction Design Foundation
> * [Tool RAG: The Next Breakthrough in Scalable AI Agents](https://next.redhat.com/2025/11/26/tool-rag-the-next-breakthrough-in-scalable-ai-agents) - Red Hat Emerging Technologies
> * [From RAG to Context: A 2025 Year-End Review](https://ragflow.io/blog/rag-review-2025-from-rag-to-context) - RAGFlow
> * [Context Engineering for AI Agents](https://weaviate.io/blog/context-engineering) - Weaviate
> * [Agentic Retrieval-Augmented Generation: A Survey](https://arxiv.org/abs/2501.09136) - arXiv
> * [Claude Code Skills Documentation](https://code.claude.com/docs/en/skills) - Anthropic

[Source: Honra.io](https://www.honra.io/articles/progressive-disclosure-for-ai-agents)
