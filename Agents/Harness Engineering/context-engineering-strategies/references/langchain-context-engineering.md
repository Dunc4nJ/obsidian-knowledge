---
created: 2026-03-02
description: LangChain's breakdown of four context engineering strategies for agents — write, select, compress, and isolate — with examples from popular agents and papers, plus how LangGraph supports each pattern.
source: https://blog.langchain.com/context-engineering-for-agents/
type: reference
---

# Context Engineering for Agents — LangChain

## Key Takeaways

Context engineering is the practice of managing what goes into an LLM's context window at each step of an agent's trajectory. LangChain frames this around Karpathy's analogy: the LLM is a CPU and the [[prompt caching is the foundational constraint for building long-running agents|context window is RAM]], making context curation the "operating system" job. This directly addresses [[coding agents are bottlenecked by search not coding ability|the retrieval and search bottleneck]] that limits agent performance.

The four strategies form a useful taxonomy. **Writing** context (scratchpads and memories) lets agents persist information outside the window for later retrieval — products like Cursor, Windsurf, and ChatGPT all implement long-term memory variants, which connects to [[PARA and atomic facts give AI agents durable structured memory|structured memory approaches]]. **Selecting** context means pulling the right information in via RAG, memory retrieval, or tool description filtering — the article notes that [[agentic search with grep and full-file loading replaces RAG when context windows are large enough|code agents combine grep, AST parsing, and embedding search]] rather than relying on any single retrieval method.

**Compressing** context through summarization and trimming is essential for long-running agents. Claude Code's auto-compact at 95% window capacity is a practical example, and [[auto-caching with Claude eliminates manual breakpoint management for multi-turn agents|caching strategies]] complement this by reducing cost of the remaining context. **Isolating** context via multi-agent architectures or sandboxed environments splits the problem — [[anthropic-multi-agent-research|Anthropic's multi-agent researcher]] showed that isolated subagent windows outperformed a single agent, though at 15x token cost.

The article also highlights a less obvious pattern: code agents that use sandboxes (like HuggingFace's CodeAgent) can isolate token-heavy objects in environment variables rather than passing them through the context window — effectively using the filesystem as overflow memory. This connects to [[skill graphs outperform single skill files by letting agents traverse linked domain knowledge on demand|progressive disclosure of context]] through filesystem-based skill organization.

## External Resources

- [Context Engineering video (LangChain)](https://youtu.be/4GiqzUHD5AA) — companion video walkthrough
- [How Contexts Fail and How to Fix Them (Drew Breunig)](https://www.dbreunig.com/2025/06/22/how-contexts-fail-and-how-to-fix-them.html) — taxonomy of context failure modes (poisoning, distraction, confusion, clash)
- [Cognition: Don't Build Multi-Agents](https://cognition.ai/blog/dont-build-multi-agents) — Cognition's case for context engineering over multi-agent splits
- [Anthropic Multi-Agent Research System](https://www.anthropic.com/engineering/built-multi-agent-research-system) — architecture for parallel subagent research
- [Reflexion paper (arXiv:2303.11366)](https://arxiv.org/abs/2303.11366) — self-reflection and memory reuse across agent turns
- [Generative Agents paper](https://ar5iv.labs.arxiv.org/html/2304.03442) — synthesized memories from collections of past agent feedback
- [RAG for Tool Selection (arXiv:2410.14594)](https://arxiv.org/abs/2410.14594) — retrieval-augmented tool description selection
- [LangGraph Bigtool](https://github.com/langchain-ai/langgraph-bigtool) — semantic search over large tool collections
- [LangMem](https://langchain-ai.github.io/langmem/) — memory management abstractions for LangGraph
- [Hierarchical Summarization (Anthropic)](https://alignment.anthropic.com/2025/summarization-for-monitoring/) — summarization strategies for monitoring agent trajectories
- [Provence context pruner (arXiv:2501.16214)](https://arxiv.org/abs/2501.16214) — trained context pruner for QA tasks

## Original Content

> [!quote]- Source Material
> 
> Source: [Context Engineering for Agents — LangChain Blog](https://blog.langchain.com/context-engineering-for-agents/)
> 
> ### TL;DR
> 
> Agents need context to perform tasks. Context engineering is the art and science of filling the context window with just the right information at each step of an agent's trajectory. In this post, we break down some common strategies — write, select, compress, and isolate — for context engineering by reviewing various popular agents and papers. We then explain how LangGraph is designed to support them!
> 
> Also, see our video on context engineering [here](https://youtu.be/4GiqzUHD5AA).
> 
> *General categories of context engineering*
> ![[langchain-context-eng-001.png]]
> 
> ### Context Engineering
> 
> As Andrej Karpathy puts it, LLMs are like a [new kind of operating system](https://www.youtube.com/watch?si=-aKY-x57ILAmWTdw&t=620&v=LCEmiRjPEtQ&feature=youtu.be). The LLM is like the CPU and its [context window](https://docs.anthropic.com/en/docs/build-with-claude/context-windows) is like the RAM, serving as the model's working memory. Just like RAM, the LLM context window has limited [capacity](https://lilianweng.github.io/posts/2023-06-23-agent/) to handle various sources of context. And just as an operating system curates what fits into a CPU's RAM, we can think about "context engineering" playing a similar role. [Karpathy summarizes this well](https://x.com/karpathy/status/1937902205765607626):
> 
> [Context engineering is the] "…delicate art and science of filling the context window with just the right information for the next step."
> 
> *Context types commonly used in LLM applications*
> ![[langchain-context-eng-002.png]]
> 
> What are the types of context that we need to manage when building LLM applications? Context engineering as an [umbrella](https://x.com/dexhorthy/status/1933283008863482067) that applies across a few different context types:
> 
> - Instructions – prompts, memories, few-shot examples, tool descriptions, etc
> - Knowledge – facts, memories, etc
> - Tools – feedback from tool calls
> 
> ### Context Engineering for Agents
> 
> This year, interest in [agents](https://www.anthropic.com/engineering/building-effective-agents) has grown tremendously as LLMs get better at [reasoning](https://platform.openai.com/docs/guides/reasoning?api-mode=responses) and [tool calling](https://www.anthropic.com/engineering/building-effective-agents). [Agents](https://www.anthropic.com/engineering/building-effective-agents) interleave [LLM invocations and tool calls](https://www.anthropic.com/engineering/building-effective-agents), often for [long-running tasks](https://blog.langchain.com/introducing-ambient-agents/). Agents interleave [LLM calls and tool calls](https://www.anthropic.com/engineering/building-effective-agents), using tool feedback to decide the next step.
> 
> *Agents interleave LLM calls and tool calls, using tool feedback to decide the next step*
> ![[langchain-context-eng-003.png]]
> 
> However, long-running tasks and accumulating feedback from tool calls mean that agents often utilize a large number of tokens. This can cause numerous problems: it can [exceed the size of the context window](https://cognition.ai/blog/kevin-32b), balloon cost / latency, or degrade agent performance. Drew Breunig [nicely outlined](https://www.dbreunig.com/2025/06/22/how-contexts-fail-and-how-to-fix-them.html) a number of specific ways that longer context can cause perform problems, including:
> 
> - [Context Poisoning: When a hallucination makes it into the context](https://www.dbreunig.com/2025/06/22/how-contexts-fail-and-how-to-fix-them.html#context-poisoning)
> - [Context Distraction: When the context overwhelms the training](https://www.dbreunig.com/2025/06/22/how-contexts-fail-and-how-to-fix-them.html#context-distraction)
> - [Context Confusion: When superfluous context influences the response](https://www.dbreunig.com/2025/06/22/how-contexts-fail-and-how-to-fix-them.html#context-confusion)
> - [Context Clash: When parts of the context disagree](https://www.dbreunig.com/2025/06/22/how-contexts-fail-and-how-to-fix-them.html#context-clash)
> 
> *Context from tool calls accumulates over multiple agent turns*
> ![[langchain-context-eng-004.png]]
> 
> With this in mind, [Cognition](https://cognition.ai/blog/dont-build-multi-agents) called out the importance of context engineering:
> 
> "Context engineering" … is effectively the #1 job of engineers building AI agents.
> 
> [Anthropic](https://www.anthropic.com/engineering/built-multi-agent-research-system) also laid it out clearly:
> 
> Agents often engage in conversations spanning hundreds of turns, requiring careful context management strategies.
> 
> So, how are people tackling this challenge today? We group common strategies for agent context engineering into four buckets — write, select, compress, and isolate — and give examples of each from review of some popular agent products and papers. We then explain how LangGraph is designed to support them!
> 
> ### Write Context
> 
> Writing context means saving it outside the context window to help an agent perform a task.
> 
> **Scratchpads**
> 
> When humans solve tasks, we take notes and remember things for future, related tasks. Agents are also gaining these capabilities! Note-taking via a "[scratchpad](https://www.anthropic.com/engineering/claude-think-tool)" is one approach to persist information while an agent is performing a task. The idea is to save information outside of the context window so that it's available to the agent. [Anthropic's multi-agent researcher](https://www.anthropic.com/engineering/built-multi-agent-research-system) illustrates a clear example of this:
> 
> The LeadResearcher begins by thinking through the approach and saving its plan to Memory to persist the context, since if the context window exceeds 200,000 tokens it will be truncated and it is important to retain the plan.
> 
> Scratchpads can be implemented in a few different ways. They can be a [tool call](https://www.anthropic.com/engineering/claude-think-tool) that simply [writes to a file](https://github.com/modelcontextprotocol/servers/tree/main/src/filesystem). They can also be a field in a runtime [state object](https://langchain-ai.github.io/langgraph/concepts/low_level/#state) that persists during the session. In either case, scratchpads let agents save useful information to help them accomplish a task.
> 
> **Memories**
> 
> Scratchpads help agents solve a task within a given session (or [thread](https://langchain-ai.github.io/langgraph/concepts/persistence/#threads)), but sometimes agents benefit from remembering things across many sessions! [Reflexion](https://arxiv.org/abs/2303.11366) introduced the idea of reflection following each agent turn and re-using these self-generated memories. [Generative Agents](https://ar5iv.labs.arxiv.org/html/2304.03442) created memories synthesized periodically from collections of past agent feedback.
> 
> *An LLM can be used to update or create memories*
> ![[langchain-context-eng-005.png]]
> 
> These concepts made their way into popular products like [ChatGPT](https://help.openai.com/en/articles/8590148-memory-faq), [Cursor](https://forum.cursor.com/t/0-51-memories-feature/98509), and [Windsurf](https://docs.windsurf.com/windsurf/cascade/memories), which all have mechanisms to auto-generate long-term memories that can persist across sessions based on user-agent interactions.
> 
> ### Select Context
> 
> Selecting context means pulling it into the context window to help an agent perform a task.
> 
> **Scratchpad**
> 
> The mechanism for selecting context from a scratchpad depends upon how the scratchpad is implemented. If it's a [tool](https://www.anthropic.com/engineering/claude-think-tool), then an agent can simply read it by making a tool call. If it's part of the agent's runtime state, then the developer can choose what parts of state to expose to an agent each step. This provides a fine-grained level of control for exposing scratchpad context to the LLM at later turns.
> 
> **Memories**
> 
> If agents have the ability to save memories, they also need the ability to select memories relevant to the task they are performing. This can be useful for a few reasons. Agents might select few-shot examples ([episodic](https://langchain-ai.github.io/langgraph/concepts/memory/#memory-types) [memories](https://arxiv.org/pdf/2309.02427)) for examples of desired behavior, instructions ([procedural](https://langchain-ai.github.io/langgraph/concepts/memory/#memory-types) [memories](https://arxiv.org/pdf/2309.02427)) to steer behavior, or facts ([semantic](https://langchain-ai.github.io/langgraph/concepts/memory/#memory-types) [memories](https://arxiv.org/pdf/2309.02427)) for task-relevant context.
> 
> One challenge is ensuring that relevant memories are selected. Some popular agents simply use a narrow set of files that are always pulled into context. For example, many code agent use specific files to save instructions ("procedural" memories) or, in some cases, examples ("episodic" memories). Claude Code uses [CLAUDE.md](http://claude.md/). [Cursor](https://docs.cursor.com/context/rules) and [Windsurf](https://windsurf.com/editor/directory) use rules files.
> 
> But, if an agent is storing a larger [collection](https://langchain-ai.github.io/langgraph/concepts/memory/#collection) of facts and / or relationships (e.g., [semantic](https://langchain-ai.github.io/langgraph/concepts/memory/#memory-types) memories), selection is harder. [ChatGPT](https://help.openai.com/en/articles/8590148-memory-faq) is a good example of a popular product that stores and selects from a large collection of user-specific memories.
> 
> Embeddings and / or [knowledge](https://arxiv.org/html/2501.13956v1#:~:text=In%20Zep%2C%20memory%20is%20powered) [graphs](https://neo4j.com/blog/developer/graphiti-knowledge-graph-memory/#:~:text=changes%20since%20updates%20can%20trigger) for memory indexing are commonly used to assist with selection. Still, memory selection is challenging. At the AIEngineer World's Fair, [Simon Willison shared](https://simonwillison.net/2025/Jun/6/six-months-in-llms/) an example of selection gone wrong: ChatGPT fetched his location from memories and unexpectedly injected it into a requested image. This type of unexpected or undesired memory retrieval can make some users feel like the context window "no longer belongs to them"!
> 
> **Tools**
> 
> Agents use tools, but can become overloaded if they are provided with too many. This is often because the tool descriptions overlap, causing model confusion about which tool to use. One approach is [to apply RAG (retrieval augmented generation) to tool descriptions](https://arxiv.org/abs/2410.14594) in order to fetch only the most relevant tools for a task. Some [recent papers](https://arxiv.org/abs/2505.03275) have shown that this improve tool selection accuracy by 3-fold.
> 
> **Knowledge**
> 
> [RAG](https://github.com/langchain-ai/rag-from-scratch) is a rich topic and it [can be a central context engineering challenge](https://x.com/_mohansolo/status/1899630246862966837). Code agents are some of the best examples of RAG in large-scale production. Varun from Windsurf captures some of these challenges well:
> 
> Indexing code ≠ context retrieval … [We are doing indexing & embedding search … [with] AST parsing code and chunking along semantically meaningful boundaries … embedding search becomes unreliable as a retrieval heuristic as the size of the codebase grows … we must rely on a combination of techniques like grep/file search, knowledge graph based retrieval, and … a re-ranking step where [context] is ranked in order of relevance.
> 
> ### Compressing Context
> 
> Compressing context involves retaining only the tokens required to perform a task.
> 
> **Context Summarization**
> 
> Agent interactions can span [hundreds of turns](https://www.anthropic.com/engineering/built-multi-agent-research-system) and use token-heavy tool calls. Summarization is one common way to manage these challenges. If you've used Claude Code, you've seen this in action. Claude Code runs "[auto-compact](https://docs.anthropic.com/en/docs/claude-code/costs)" after you exceed 95% of the context window and it will summarize the full trajectory of user-agent interactions. This type of compression across an [agent trajectory](https://langchain-ai.github.io/langgraph/concepts/memory/#manage-short-term-memory) can use various strategies such as [recursive](https://arxiv.org/pdf/2308.15022#:~:text=the%20retrieved%20utterances%20capture%20the) or [hierarchical](https://alignment.anthropic.com/2025/summarization-for-monitoring/#:~:text=We%20addressed%20these%20issues%20by) summarization.
> 
> *A few places where summarization can be applied*
> ![[langchain-context-eng-006.png]]
> 
> It can also be useful to [add summarization](https://github.com/langchain-ai/open_deep_research/blob/e5a5160a398a3699857d00d8569cb7fd0ac48a4f/src/open_deep_research/utils.py#L1407) at specific points in an agent's design. For example, it can be used to post-process certain tool calls (e.g., token-heavy search tools). As a second example, [Cognition](https://cognition.ai/blog/dont-build-multi-agents#a-theory-of-building-long-running-agents) mentioned summarization at agent-agent boundaries to reduce tokens during knowledge hand-off. Summarization can be a challenge if specific events or decisions need to be captured. [Cognition](https://cognition.ai/blog/dont-build-multi-agents#a-theory-of-building-long-running-agents) uses a fine-tuned model for this, which underscores how much work can go into this step.
> 
> **Context Trimming**
> 
> Whereas summarization typically uses an LLM to distill the most relevant pieces of context, trimming can often filter or, as Drew Breunig points out, "[prune](https://www.dbreunig.com/2025/06/26/how-to-fix-your-context.html)" context. This can use hard-coded heuristics like removing [older messages](https://python.langchain.com/docs/how_to/trim_messages/) from a list. Drew also mentions [Provence](https://arxiv.org/abs/2501.16214), a trained context pruner for Question-Answering.
> 
> ### Isolating Context
> 
> Isolating context involves splitting it up to help an agent perform a task.
> 
> **Multi-agent**
> 
> One of the most popular ways to isolate context is to split it across sub-agents. A motivation for the OpenAI [Swarm](https://github.com/openai/swarm) library was [separation of concerns](https://openai.github.io/openai-agents-python/ref/agent/), where a team of agents can handle specific sub-tasks. Each agent has a specific set of tools, instructions, and its own context window.
> 
> *Split context across multiple agents*
> ![[langchain-context-eng-007.png]]
> 
> Anthropic's [multi-agent researcher](https://www.anthropic.com/engineering/built-multi-agent-research-system) makes a case for this: many agents with isolated contexts outperformed single-agent, largely because each subagent context window can be allocated to a more narrow sub-task. As the blog said:
> 
> [Subagents operate] in parallel with their own context windows, exploring different aspects of the question simultaneously.
> 
> Of course, the challenges with multi-agent include token use (e.g., up to [15× more tokens](https://www.anthropic.com/engineering/built-multi-agent-research-system) than chat as reported by Anthropic), the need for careful [prompt engineering](https://www.anthropic.com/engineering/built-multi-agent-research-system) to plan sub-agent work, and coordination of sub-agents.
> 
> **Context Isolation with Environments**
> 
> HuggingFace's [deep researcher](https://huggingface.co/blog/open-deep-research#:~:text=From%20building%20) shows another interesting example of context isolation. Most agents use [tool calling APIs](https://docs.anthropic.com/en/docs/agents-and-tools/tool-use/overview), which return JSON objects (tool arguments) that can be passed to tools (e.g., a search API) to get tool feedback (e.g., search results). HuggingFace uses a [CodeAgent](https://huggingface.co/papers/2402.01030), which outputs that contains the desired tool calls. The code then runs in a [sandbox](https://e2b.dev/). Selected context (e.g., return values) from the tool calls is then passed back to the LLM.
> 
> This allows context to be isolated from the LLM in the environment. Hugging Face noted that this is a great way to isolate token-heavy objects in particular:
> 
> [Code Agents allow for] a better handling of state … Need to store this image / audio / other for later use? No problem, just assign it as a variable [in your state and you [use it later]](https://deepwiki.com/search/i-am-wondering-if-state-that-i_0e153539-282a-437c-b2b0-d2d68e51b873).
> 
> **State**
> 
> It's worth calling out that an agent's runtime [state object](https://langchain-ai.github.io/langgraph/concepts/low_level/#state) can also be a great way to isolate context. This can serve the same purpose as sandboxing. A state object can be designed with a [schema](https://langchain-ai.github.io/langgraph/concepts/low_level/#schema) that has fields that context can be written to. One field of the schema (e.g., messages) can be exposed to the LLM at each turn of the agent, but the schema can isolate information in other fields for more selective use.
> 
> ### Context Engineering with LangSmith / LangGraph
> 
> So, how can you apply these ideas? Before you start, there are two foundational pieces that are helpful. First, ensure that you have a way to [look at your data](https://hamel.dev/blog/posts/evals/) and track token-usage across your agent. This helps inform where best to apply effort context engineering. [LangSmith](https://docs.smith.langchain.com/) is well-suited for agent [tracing / observability](https://docs.smith.langchain.com/observability), and offers a great way to do this. Second, be sure you have a simple way to test whether context engineering hurts or improve agent performance. LangSmith enables [agent evaluation](https://docs.smith.langchain.com/evaluation/tutorials/agents) to test the impact of any context engineering effort.
> 
> **Write context**
> 
> LangGraph was designed with both thread-scoped ([short-term](https://langchain-ai.github.io/langgraph/concepts/memory/#short-term-memory)) and [long-term memory](https://langchain-ai.github.io/langgraph/concepts/memory/#long-term-memory). Short-term memory uses [checkpointing](https://langchain-ai.github.io/langgraph/concepts/persistence/) to persist [agent state](https://langchain-ai.github.io/langgraph/concepts/low_level/#state) across all steps of an agent. This is extremely useful as a "scratchpad", allowing you to write information to state and fetch it at any step in your agent trajectory.
> 
> LangGraph's long-term memory lets you to persist context across many sessions with your agent. It is flexible, allowing you to save small sets of [files](https://langchain-ai.github.io/langgraph/concepts/memory/#profile) (e.g., a user profile or rules) or larger [collections](https://langchain-ai.github.io/langgraph/concepts/memory/#collection) of memories. In addition, [LangMem](https://langchain-ai.github.io/langmem/) provides a broad set of useful abstractions to aid with LangGraph memory management.
> 
> **Select context**
> 
> Within each node (step) of a LangGraph agent, you can fetch [state](https://langchain-ai.github.io/langgraph/concepts/low_level/#state). This give you fine-grained control over what context you present to the LLM at each agent step.
> 
> In addition, LangGraph's long-term memory is accessible within each node and supports various types of retrieval (e.g., fetching files as well as [embedding-based retrieval on a memory collection](https://langchain-ai.github.io/langgraph/cloud/reference/cli/#adding-semantic-search-to-the-store)). For an overview of long-term memory, see [our Deeplearning.ai course](https://www.deeplearning.ai/short-courses/long-term-agentic-memory-with-langgraph/). And for an entry point to memory applied to a specific agent, see our [Ambient Agents](https://academy.langchain.com/courses/ambient-agents) course. This shows how to use LangGraph memory in a long-running agent that can manage your email and learn from your feedback.
> 
> *Email agent with user feedback and long-term memory*
> ![[langchain-context-eng-008.png]]
> 
> For tool selection, the [LangGraph Bigtool](https://github.com/langchain-ai/langgraph-bigtool) library is a great way to apply semantic search over tool descriptions. This helps select the most relevant tools for a task when working with a large collection of tools. Finally, we have several [tutorials and videos](https://langchain-ai.github.io/langgraph/tutorials/rag/langgraph_agentic_rag/) that show how to use various types of RAG with LangGraph.
> 
> **Compressing context**
> 
> Because LangGraph [is a low-level orchestration framework](https://blog.langchain.com/how-to-think-about-agent-frameworks/), you [lay out your agent as a set of nodes](https://www.youtube.com/watch?v=aHCDrAbH_go), [define](https://blog.langchain.com/how-to-think-about-agent-frameworks/) the logic within each one, and define an state object that is passed between them. This control offers several ways to compress context.
> 
> One common approach is to use a message list as your agent state and [summarize or trim](https://langchain-ai.github.io/langgraph/how-tos/memory/add-memory/#manage-short-term-memory) it periodically using [a few built-in utilities](https://langchain-ai.github.io/langgraph/how-tos/memory/add-memory/#manage-short-term-memory). However, you can also add logic to post-process [tool calls](https://github.com/langchain-ai/open_deep_research/blob/e5a5160a398a3699857d00d8569cb7fd0ac48a4f/src/open_deep_research/utils.py#L1407) or work phases of your agent in a few different ways. You can add summarization nodes at specific points or also add summarization logic to your tool calling node in order to compress the output of specific tool calls.
> 
> **Isolating context**
> 
> LangGraph is designed around a [state](https://langchain-ai.github.io/langgraph/concepts/low_level/#state) object, allowing you to specify a state schema and access state at each agent step. For example, you can store context from tool calls in certain fields in state, isolating them from the LLM until that context is required. In addition to state, LangGraph supports use of sandboxes for context isolation. See this [repo](https://github.com/jacoblee93/mini-chat-langchain?tab=readme-ov-file) for an example LangGraph agent that uses [an E2B sandbox](https://e2b.dev/) for tool calls. See this [video](https://www.youtube.com/watch?v=FBnER2sxt0w) for an example of sandboxing using Pyodide where state can be persisted. LangGraph also has a lot of support for building multi-agent architecture, such as the [supervisor](https://github.com/langchain-ai/langgraph-supervisor-py) and [swarm](https://github.com/langchain-ai/langgraph-swarm-py) libraries. You can [see](https://www.youtube.com/watch?v=4nZl32FwU-o) [these](https://www.youtube.com/watch?v=JeyDrn1dSUQ) [videos](https://www.youtube.com/watch?v=B_0TNuYi56w) for more detail on using multi-agent with LangGraph.
> 
> ### Conclusion
> 
> Context engineering is becoming a craft that agents builders should aim to master. Here, we covered a few common patterns seen across many popular agents today:
> 
> - Writing context - saving it outside the context window to help an agent perform a task.
> - Selecting context - pulling it into the context window to help an agent perform a task.
> - Compressing context - retaining only the tokens required to perform a task.
> - Isolating context - splitting it up to help an agent perform a task.
> 
> LangGraph makes it easy to implement each of them and LangSmith provides an easy way to test your agent and track context usage. Together, LangGraph and LangGraph enable a virtuous feedback loop for identifying the best opportunity to apply context engineering, implementing it, testing it, and repeating.
