---
created: 2026-09-09
description: LangChain's Deep Agents memory documentation specifies long-term memory as files declared via memory= and routed by a CompositeBackend to a StoreBackend whose namespace is a lambda over runtime identity, making agent, user, and organization scope a routing decision rather than a separate memory service.
source: https://docs.langchain.com/oss/python/deepagents/memory
type: framework
---

# LangChain Deep Agents specifies long-term memory as files routed to a store namespace, making user, agent, and org scope a lambda over runtime identity

## Key Takeaways

- **The whole design collapses to one substitution: scope is a namespace tuple, and the namespace is a function of the request.** `StoreBackend(namespace=lambda rt: (rt.server_info.assistant_id,))` gives agent-scoped memory shared by everyone; swapping the tuple to `(rt.server_info.user.identity,)` gives per-user isolation; `(rt.context.org_id,)` gives org policy; concatenating two gives per-agent-per-user. Nothing else in the agent changes — same `memory=["/memories/AGENTS.md"]`, same built-in `edit_file` tool. That is the same swappable-primitive discipline [[Deep Agents v0.6 splits the agent harness into five composable primitives - code interpreter, per-model profiles, typed streaming, delta channels, and ContextHub backend|Deep Agents v0.6 applied to the harness as a whole]], and it is what makes third-party backends like [[MongoDB's VFS for LangChain Deep Agents redefines grep as server-side hybrid search, splitting file bytes in S3 from a searchable chunk plane in Atlas|MongoDB's VFS]] drop-in — the memory API is a path plus a namespace, not a schema.

- **The page's own taxonomy is a six-dimension table, and the load-bearing row is *duration*, because it decides which persistence mechanism you get.** Short-term memory is thread state under a checkpointer; long-term memory is the store. Episodic memory gets no new machinery at all — the docs say checkpointed threads *already are* episodic memory and hand you a `client.threads.search(metadata={"user_id": ...})` tool to make them retrievable. That is structurally the same move as [[GPT-6 Astra swaps Codex compaction for notes across context windows plus searchable earlier windows including tool outputs|Astra's searchable earlier context windows]] and the summary-plus-dereferenceable-archive pattern in [[indexed experience memory compresses LLM agent context without discarding evidence by pairing summaries with a dereferenceable archive]]: keep the raw trajectory addressable instead of compacting it away.

*Short-term memory is scoped to a single thread via checkpoints; long-term memory persists across threads via the store*
![[langchain-da-memory-001.png]]

- **Background consolidation is specified as a second deployed agent on a cron, not a feature flag — and the docs concede the hot path is usually enough.** The "sleep time compute" pattern is a separate `consolidation_agent` registered in `langgraph.json`, reading recent threads and merging facts, scheduled with `client.crons.create(schedule="0 */6 * * *")`. The sharpest operational detail on the page is a warning that the cron interval must equal the tool's `timedelta` lookback or you either reprocess or drop memories — a real correctness coupling with no runtime enforcement. This is LangChain's version of the admission question that [[memory is a compiler not a database - Ashwin Gopinath argues admission and action utility functions are the moat, and silence is the evidence they work|Gopinath argues is the actual moat]], except the docs specify *when* consolidation runs and leave *what earns a place in memory* entirely to a system prompt — the same judgment-not-data-structure problem named in [[Hermes, Codex, and Claude Code converge on markdown plus filesystem tools because memory is a judgment problem not a data structure problem]].

- **Prompt injection via shared state is treated as the primary threat, and the mitigation is architectural rather than detective.** Because any memory a second party can write is a channel into another user's context, the docs default to user scope, make org memory read-only (populated by application code or the Store API, enforced by `permissions` or backend policy hooks), and recommend a human-in-the-loop `interrupt` before writes to sensitive paths. This is the governance layer [[LangChain deep agents require persistent memory scoped sandboxes and guardrails to move from prototype to production|the going-to-production guide sketches]] worked out in detail, and it is exactly the ownership argument in [[Memory ownership follows harness ownership - Harrison Chase argues picking a closed harness is picking a permanent owner for your agent's data flywheel|Chase's "your harness, your memory"]] and [[LangChain Deep Agents Deploy offers open harness to avoid Claude Managed Agents memory lock-in|Deep Agents Deploy]] — if memory is files you route, you can also inspect, revoke, and migrate it.

- **What the docs specify is a mechanism; what they assume is that markdown files are an adequate representation — and they never argue for it.** There is no evaluation on the page: no retrieval-quality numbers, no comparison against a database- or graph-backed store, no measurement of whether the "load into system prompt at startup" default degrades as `AGENTS.md` grows. The vault's counter-notes are the missing half — [[a file system is not all you need - databases beat markdown for agent context provenance and governance]] on why flat markdown loses provenance and governance, [[Mem0 surveys nine agent harness memory systems and finds five recurring gaps - bounded storage, keyword retrieval, harness scoping, weak staleness, and isolation|Mem0's five recurring gaps]] (bounded storage and weak staleness both apply directly to an unbounded, agent-edited `AGENTS.md`), and [[Claude Code memory has a silent 200-line index cap that drops old memories without warning|Claude Code's silent 200-line index cap]] as the concrete failure this design has not ruled out. The OpenWiki pointer is a related boundary: a generated repository wiki is compiled corpus knowledge, and [[The LLM Wiki compiles a corpus into maintained markdown at ingest, but a wiki is not user memory (mem0's State of Agent Wikis)|a wiki is not user memory]] — the docs list both under one heading without marking the seam.

- **The concurrency section is the page's most candid moment and its weakest guarantee.** Parallel writes to the same file are last-write-wins; the mitigations offered are "serialize through background consolidation" or "split memory into per-topic files," and the closing argument is that the LLM is usually smart enough to retry, so a lost write is not catastrophic. That is a probabilistic answer to a consistency question, and it is precisely the gap [[multi-agent memory needs computer architecture style hierarchy and consistency models]] says agent memory systems keep leaving open. The files-as-memory substrate is the vault's recurring one — [[Everything is Context - Agentic File System Abstraction for Context Engineering]] and [[Obsidian as Agentic Memory]] both build on it, and [[PARA and atomic facts give AI agents durable structured memory]] plus [[progressive disclosure filters force agent selectivity over what enters context]] supply the file-shaping discipline these docs leave to the prompt.

## External Resources

- [Backends](https://docs.langchain.com/oss/python/deepagents/backends) — where memory files are physically stored; `CompositeBackend`, `StateBackend`, `StoreBackend`, and policy hooks
- [Context engineering](https://docs.langchain.com/oss/python/deepagents/context-engineering) — the short-term memory counterpart: offloading and summarization within a session
- [Skills](https://docs.langchain.com/oss/python/deepagents/skills) — procedural memory loaded on demand rather than into the startup prompt
- [OpenWiki](https://docs.langchain.com/oss/openwiki/overview) — generates and maintains a repository wiki that coding agents discover through `AGENTS.md`
- [AGENTS.md](https://agents.md/) — the open instruction-file standard the memory files are named after
- [Permissions](https://docs.langchain.com/oss/python/deepagents/permissions) — declaratively deny writes to specific paths to enforce read-only memory
- [Checkpointers](https://docs.langchain.com/oss/python/langgraph/checkpointers#checkpoints) — the thread persistence mechanism the docs identify as episodic memory
- [LangGraph state](https://docs.langchain.com/oss/python/langgraph/graph-api#state) — where short-term memory lives automatically
- [Interrupts](https://docs.langchain.com/oss/python/langgraph/interrupts) — human approval gate before writes to sensitive memory paths
- [Cron jobs](https://docs.langchain.com/langsmith/cron-jobs) — scheduling the consolidation agent; all schedules interpreted in UTC
- [Custom store API](https://docs.langchain.com/langsmith/custom-store) — populating read-only memory from application code
- [LangSmith tracing](https://docs.langchain.com/langsmith/trace-with-langgraph) — every memory write appears as a tool call, making memory auditable
- [Semantic memory concepts](https://docs.langchain.com/oss/python/concepts/memory#semantic-memory) — LangChain's definition of the facts-and-preferences memory type
- [Going to production](https://docs.langchain.com/oss/python/deepagents/going-to-production) — deploying agents with background processes

## Original Content

> [!quote]- Source Material — LangChain Deep Agents documentation, "Memory" (full page, verbatim)
> # Memory
>
> > Add persistent memory to agents built with Deep Agents so they learn and improve across conversations
>
> Memory lets your agent learn and improve across conversations. Deep Agents makes memory first class with filesystem-backed memory: the agent reads and writes memory as files, and you control where those files are stored using [backends](https://docs.langchain.com/oss/python/deepagents/backends).
>
> **[Tip]**
> To generate a repository wiki that coding agents discover through [`AGENTS.md`](https://agents.md/), see [OpenWiki](https://docs.langchain.com/oss/openwiki/overview).
>
> **[Note]**
> This page covers **long-term memory**: memory that persists across conversations. For short-term memory (conversation history and scratch files within a single session), see the [context engineering](https://docs.langchain.com/oss/python/deepagents/context-engineering) guide. Short-term memory is managed automatically as part of the agent's [state](https://docs.langchain.com/oss/python/langgraph/graph-api#state).
>
> *Short-term memory is scoped to a single thread via checkpoints; long-term memory persists across threads via the store*
> ![[langchain-da-memory-001.png]]
>
> ## How memory works
>
> 1. **Point the agent at memory files.** Pass file paths to `memory=` when creating the agent. You can also pass [skills](https://docs.langchain.com/oss/python/deepagents/skills) via `skills=` for procedural memory (reusable instructions that tell the agent *how* to perform a task). A [backend](https://docs.langchain.com/oss/python/deepagents/backends) controls where files are stored and who can access them.
> 2. **Agent reads memory.** The agent can load memory files into the system prompt at startup, or read them on demand during the conversation. For example, [skills](https://docs.langchain.com/oss/python/deepagents/skills) use on-demand loading: the agent reads only skill descriptions at startup, then reads the full skill file only when it matches a task. This keeps context lean until a capability is needed.
> 3. **Agent updates memory (optional).** When the agent learns new information, it can use its built-in `edit_file` tool to update memory files. Updates can happen during the conversation (the default) or in the background between conversations via [background consolidation](#background-consolidation). Changes are persisted and available in the next conversation. Not all memory is writable: developer-defined [skills](https://docs.langchain.com/oss/python/deepagents/skills) and [organization policies](#organization-level-memory) are typically read-only. See [read-only vs writable memory](#read-only-vs-writable-memory) for details.
>
> The two most common patterns are [agent-scoped memory](#agent-scoped-memory) (shared across all users) and [user-scoped memory](#user-scoped-memory) (isolated per user).
>
> For a generated repository wiki that coding agents discover through [`AGENTS.md`](https://agents.md/), see [OpenWiki](https://docs.langchain.com/oss/openwiki/overview).
>
> ## Scoped memory
>
> Agent memory can be scoped so the same memory files are accessible to everyone using the agent or memory files can be individual to each user.
>
> ### Agent-scoped memory
>
> Give the agent its own persistent identity that evolves over time. Agent-scoped memory is shared across all users, so the agent builds up its own persona, accumulated knowledge, and learned preferences through every conversation. As it interacts with users, it develops expertise, refines its approach, and remembers what works. It can also learn and update [skills](https://docs.langchain.com/oss/python/deepagents/skills) when it has write access.
>
> The key is the backend namespace: setting it to `(assistant_id,)` means every conversation for this agent reads and writes to the same memory file.
>
> **[Note]**
> Accessing `rt.server_info` requires `deepagents>=0.5.0`. On older versions, read the assistant ID from `get_config()["metadata"]["assistant_id"]` instead.
>
> ```python theme={"theme":{"light":"catppuccin-latte","dark":"catppuccin-mocha"}}
> from deepagents import create_deep_agent
> from deepagents.backends import CompositeBackend, StateBackend, StoreBackend
>
> agent = create_deep_agent(
>     model="google_genai:gemini-3.6-flash",
>     memory=["/memories/AGENTS.md"],
>     skills=["/skills/"],
>     backend=CompositeBackend(
>         default=StateBackend(),
>         routes={
>             "/memories/": StoreBackend(
>                 namespace=lambda rt: (
>                     rt.server_info.assistant_id,  # [!code highlight]
>                 ),
>             ),
>             "/skills/": StoreBackend(
>                 namespace=lambda rt: (
>                     rt.server_info.assistant_id,  # [!code highlight]
>                 ),
>             ),
>         },
>     ),
> )
> ```
>
> **[Accordion: Full example: seed memory and invoke]**
> Populate the store with initial memories, then invoke the agent across two threads to see it remember and update what it learns.
>
> ```python theme={"theme":{"light":"catppuccin-latte","dark":"catppuccin-mocha"}}
> from langchain_core.utils.uuid import uuid7
>
> from deepagents import create_deep_agent
> from deepagents.backends import CompositeBackend, StateBackend, StoreBackend
> from deepagents.backends.utils import create_file_data
> from langgraph.store.memory import InMemoryStore
>
> store = InMemoryStore()  # Use platform store when deploying to LangSmith
>
> # Seed the memory file
> store.put(
>     ("my-agent",),
>     "/memories/AGENTS.md",
>     create_file_data("""## Response style
> - Keep responses concise
> - Use code examples where possible
> """),
> )
>
> # Seed a skill
> store.put(
>     ("my-agent",),
>     "/skills/langgraph-docs/SKILL.md",
>     create_file_data("""---
> name: langgraph-docs
> description: Fetch relevant LangGraph documentation to provide accurate guidance.
> ---
>
> # langgraph-docs
>
> Use the fetch_url tool to read https://docs.langchain.com/llms.txt, then fetch relevant pages.
> """),
> )
>
> agent = create_deep_agent(
>     model="google_genai:gemini-3.6-flash",
>     memory=["/memories/AGENTS.md"],
>     skills=["/skills/"],
>     backend=lambda rt: CompositeBackend(
>         default=StateBackend(rt),
>         routes={
>             "/memories/": StoreBackend(
>                 rt, namespace=lambda rt: ("my-agent",)
>             ),
>             "/skills/": StoreBackend(
>                 rt, namespace=lambda rt: ("my-agent",)
>             ),
>         },
>     ),
>     store=store,
> )
>
> # Thread 1: the agent learns a new preference and saves it to memory
> config1 = {"configurable": {"thread_id": str(uuid7())}}
> agent.invoke(
>     {"messages": [{"role": "user", "content": "I prefer detailed explanations. Remember that."}]},
>     config=config1,
> )
>
> # Thread 2: the agent reads memory and applies the preference
> config2 = {"configurable": {"thread_id": str(uuid7())}}
> agent.invoke(
>     {"messages": [{"role": "user", "content": "Explain how transformers work."}]},
>     config=config2,
> )
> ```
>
> ### User-scoped memory
>
> Give each user their own memory file. The agent remembers preferences, context, and history per user while core agent instructions stay fixed. Users can also have per-user [skills](https://docs.langchain.com/oss/python/deepagents/skills) if stored in a user-scoped backend.
>
> The namespace uses `(user_id,)` so each user gets an isolated copy of the memory file. User A's preferences never leak into User B's conversations.
>
> ```python theme={"theme":{"light":"catppuccin-latte","dark":"catppuccin-mocha"}}
> from deepagents import create_deep_agent
> from deepagents.backends import CompositeBackend, StateBackend, StoreBackend
>
> agent = create_deep_agent(
>     model="google_genai:gemini-3.6-flash",
>     memory=["/memories/preferences.md"],
>     skills=["/skills/"],
>     backend=CompositeBackend(
>         default=StateBackend(),
>         routes={
>             "/memories/": StoreBackend(
>                 namespace=lambda rt: (rt.server_info.user.identity,),
>             ),
>             "/skills/": StoreBackend(
>                 namespace=lambda rt: (rt.server_info.user.identity,),
>             ),
>         },
>     ),
> )
> ```
>
> **[Accordion: Full example: isolated memory across users]**
> Seed per-user memories and invoke the agent as two different users. Each user sees only their own preferences.
>
> ```python theme={"theme":{"light":"catppuccin-latte","dark":"catppuccin-mocha"}}
> from langchain_core.utils.uuid import uuid7
>
> from deepagents import create_deep_agent
> from deepagents.backends import CompositeBackend, StateBackend, StoreBackend
> from deepagents.backends.utils import create_file_data
> from langgraph.store.memory import InMemoryStore
>
>
> store = InMemoryStore()  # Use platform store when deploying to LangSmith
>
> # Seed preferences for two users
> store.put(
>     ("user-alice",),
>     "/memories/preferences.md",
>     create_file_data("""## Preferences
> - Likes concise bullet points
> - Prefers Python examples
> """),
> )
> store.put(
>     ("user-bob",),
>     "/memories/preferences.md",
>     create_file_data("""## Preferences
> - Likes detailed explanations
> - Prefers TypeScript examples
> """),
> )
>
> # Seed a skill for Alice
> store.put(
>     ("user-alice",),
>     "/skills/langgraph-docs/SKILL.md",
>     create_file_data("""---
> name: langgraph-docs
> description: Fetch relevant LangGraph documentation to provide accurate guidance.
> ---
>
> # langgraph-docs
>
> Use the fetch_url tool to read https://docs.langchain.com/llms.txt, then fetch relevant pages.
> """),
> )
>
> agent = create_deep_agent(
>     model="google_genai:gemini-3.6-flash",
>     memory=["/memories/preferences.md"],
>     skills=["/skills/"],
>     backend=lambda rt: CompositeBackend(
>         default=StateBackend(rt),
>         routes={
>             "/memories/": StoreBackend(
>                 rt,
>                 namespace=lambda rt: (rt.server_info.user.identity,),
>             ),
>             "/skills/": StoreBackend(
>                 rt,
>                 namespace=lambda rt: (rt.server_info.user.identity,),
>             ),
>         },
>     ),
>     store=store,
> )
>
> # When deployed, each authenticated request resolves
> # `rt.server_info.user.identity` to the calling user, so Alice and Bob
> # automatically see only their own preferences.
> agent.invoke(
>     {"messages": [{"role": "user", "content": "How do I read a CSV file?"}]},
>     config={"configurable": {"thread_id": str(uuid7())}},
> )
> ```
>
> ## Advanced usage
>
> On top of the basic configuration options for memory paths and scope, you can also configure more advanced parameters for memory:
>
> | Dimension             | Question it answers             | Options                                                                                                                                                                                    |
> | --------------------- | ------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
> | **Duration**          | How long does it last?          | [Short-term](https://docs.langchain.com/oss/python/deepagents/context-engineering) (single conversation) or [long-term](#scoped-memory) (across conversations)                                                       |
> | **Information type**  | What kind of information is it? | [Episodic](#episodic-memory) (past experiences), [procedural](https://docs.langchain.com/oss/python/deepagents/skills) (instructions and skills), or [semantic](https://docs.langchain.com/oss/python/concepts/memory#semantic-memory) (facts) |
> | **Scope**             | Who can see and modify it?      | [User](#user-scoped-memory), [agent](#agent-scoped-memory), or [organization](#organization-level-memory)                                                                                  |
> | **Update strategy**   | When are memories written?      | During conversation (default) or [between conversations](#background-consolidation)                                                                                                        |
> | **Retrieval**         | How are memories read?          | Loaded into prompt (default) or on demand (e.g., [skills](https://docs.langchain.com/oss/python/deepagents/skills))                                                                                                  |
> | **Agent permissions** | Can the agent write to memory?  | [Read-write](#read-only-vs-writable-memory) (default) or [read-only](#read-only-vs-writable-memory) (for shared policies)                                                                  |
>
> ### Episodic memory
>
> Episodic memory stores records of past experiences: what happened, in what order, and what the outcome was. Unlike semantic memory (facts and preferences stored in files like `AGENTS.md`), episodic memory preserves the full conversational context so the agent can recall *how* a problem was solved, not just *what* was learned from it. To generate and maintain a repository-level wiki for coding agents, see [OpenWiki](https://docs.langchain.com/oss/openwiki/overview).
>
> Deep Agents already use [checkpointers](https://docs.langchain.com/oss/python/langgraph/checkpointers#checkpoints) which is the mechanism that supports episodic memory: every conversation is persisted as a checkpointed thread.
>
> To make past conversations searchable, wrap thread search in a tool. The `user_id` is pulled from the runtime context rather than passed as a parameter:
>
> ```python theme={"theme":{"light":"catppuccin-latte","dark":"catppuccin-mocha"}}
> from langgraph_sdk import get_client
> from langchain.tools import tool, ToolRuntime
>
> client = get_client(url="<DEPLOYMENT_URL>")
>
>
> @tool
> async def search_past_conversations(query: str, runtime: ToolRuntime) -> str:
>     """Search past conversations for relevant context."""
>     user_id = runtime.server_info.user.identity  # [!code highlight]
>     threads = await client.threads.search(
>         metadata={"user_id": user_id},
>         limit=5,
>     )
>     results = []
>     for thread in threads:
>         history = await client.threads.get_history(thread_id=thread["thread_id"])
>         results.append(history)
>     return str(results)
> ```
>
> You can scope thread search by user or organization by adjusting the metadata filter:
>
> ```python theme={"theme":{"light":"catppuccin-latte","dark":"catppuccin-mocha"}}
> # Search conversations for a specific user
> threads = await client.threads.search(
>     metadata={"user_id": user_id},
>     limit=5,
> )
>
> # Search conversations across an organization
> threads = await client.threads.search(
>     metadata={"org_id": org_id},
>     limit=5,
> )
> ```
>
> This is useful for agents that perform complex, multi-step tasks. For example, a coding agent can look back at a past debugging session and skip straight to the likely root cause.
>
> ### Organization-level memory
>
> Organization-level memory follows the same pattern as user-scoped memory, but with an organization-wide namespace instead of a per-user one. Use it for policies or knowledge that should apply across all users and agents in an organization.
>
> Organization memory is typically **read-only** to prevent prompt injection via shared state. See [read-only vs writable memory](#read-only-vs-writable-memory) for details.
>
> ```python theme={"theme":{"light":"catppuccin-latte","dark":"catppuccin-mocha"}}
> from deepagents import create_deep_agent
> from deepagents.backends import CompositeBackend, StateBackend, StoreBackend
>
> agent = create_deep_agent(
>     model="google_genai:gemini-3.6-flash",
>     memory=[
>         "/memories/preferences.md",
>         "/policies/compliance.md",
>     ],
>     backend=CompositeBackend(
>         default=StateBackend(),
>         routes={
>             "/memories/": StoreBackend(
>                 namespace=lambda rt: (rt.server_info.user.identity,),
>             ),
>             "/policies/": StoreBackend(
>                 namespace=lambda rt: (rt.context.org_id,),
>             ),
>         },
>     ),
> )
> ```
>
> Populate organization memory from your application code:
>
> ```python theme={"theme":{"light":"catppuccin-latte","dark":"catppuccin-mocha"}}
> from langgraph_sdk import get_client
> from deepagents.backends.utils import create_file_data
>
> client = get_client(url="<DEPLOYMENT_URL>")
>
> await client.store.put_item(
>     (org_id,),
>     "/compliance.md",
>     create_file_data("""## Compliance policies
> - Never disclose internal pricing
> - Always include disclaimers on financial advice
> """),
> )
> ```
>
> Use [permissions](https://docs.langchain.com/oss/python/deepagents/permissions) to enforce that org-level memory is read-only, or [policy hooks](https://docs.langchain.com/oss/python/deepagents/backends#add-policy-hooks) for custom validation logic.
>
> ### Background consolidation
>
> By default, the agent writes memories during the conversation (hot path). An alternative is to process memories **between conversations** as a background task, sometimes called **sleep time compute**. A separate deep agent reviews recent conversations, extracts key facts, and merges them with existing memories.
>
> | Approach                               | Pros                                                                 | Cons                                                                    |
> | -------------------------------------- | -------------------------------------------------------------------- | ----------------------------------------------------------------------- |
> | **Hot path** (during conversation)     | Memories available immediately, transparent to user                  | Adds latency, agent must multitask                                      |
> | **Background** (between conversations) | No user-facing latency, can synthesize across multiple conversations | Memories not available until next conversation, requires a second agent |
>
> For most applications, the hot path is sufficient. Add background consolidation when you need to reduce latency or improve memory quality across many conversations.
>
> The recommended pattern is to deploy a **consolidation agent** alongside your main agent — a deep agent that reads recent conversation history, extracts key facts, and merges them into the memory store — and trigger it on a [cron schedule](#cron). Pick a cadence that reflects how often your users actually interact with the agent: a chat product with steady daily traffic might consolidate every few hours, while a tool used a handful of times per week only needs to run nightly or weekly. Consolidating much more often than users converse just burns tokens on no-op runs.
>
> #### Consolidation agent
>
> The consolidation agent reads recent conversation history and merges key facts into the memory store. Register it alongside your main agent in `langgraph.json`:
>
> ```python consolidation_agent.py theme={"theme":{"light":"catppuccin-latte","dark":"catppuccin-mocha"}}
> from datetime import datetime, timedelta, timezone
>
> from deepagents import create_deep_agent
> from langchain.tools import tool, ToolRuntime
> from langgraph_sdk import get_client
>
> sdk_client = get_client(url="<DEPLOYMENT_URL>")
>
>
> @tool
> async def search_recent_conversations(query: str, runtime: ToolRuntime) -> str:
>     """Search this user's conversations updated in the last 6 hours."""
>     user_id = runtime.server_info.user.identity  # [!code highlight]
>
>     since = datetime.now(timezone.utc) - timedelta(hours=6)
>     threads = await sdk_client.threads.search(
>         metadata={"user_id": user_id},
>         updated_after=since.isoformat(),
>         limit=20,
>     )
>     conversations = []
>     for thread in threads:
>         history = await sdk_client.threads.get_history(
>             thread_id=thread["thread_id"]
>         )
>         conversations.append(history["values"]["messages"])
>     return str(conversations)
>
>
> agent = create_deep_agent(
>     model="google_genai:gemini-3.6-flash",
>     system_prompt="""Review recent conversations and update the user's memory file.
> Merge new facts, remove outdated information, and keep it concise.""",
>     tools=[search_recent_conversations],
> )
> ```
>
> ```json langgraph.json theme={"theme":{"light":"catppuccin-latte","dark":"catppuccin-mocha"}}
> {
>   "dependencies": ["."],
>   "graphs": {
>     "agent": "./agent.py:agent",
>     "consolidation_agent": "./consolidation_agent.py:agent"
>   },
>   "env": ".env"
> }
> ```
>
> #### Cron
>
> A [cron job](https://docs.langchain.com/langsmith/cron-jobs) runs the consolidation agent on a fixed schedule. The agent searches recent conversations and synthesizes them into memory. Match the schedule to your usage patterns so consolidation runs roughly track real activity.
>
> ```mermaid theme={"theme":{"light":"catppuccin-latte","dark":"catppuccin-mocha"}}
> graph LR
>     Store[(Memory store)] -.->|reads| Conv1[Conversation 1]
>     Store -.->|reads| Conv2[Conversation 2]
>     Cron[Cron schedule] -->|periodic| Agent[Consolidation agent]
>     Agent -->|writes| Store
>
>     classDef trigger fill:#F6FFDB,stroke:#6E8900,stroke-width:2px,color:#2E3900
>     classDef process fill:#E5F4FF,stroke:#006DDD,stroke-width:2px,color:#030710
>     classDef output fill:#EBD0F0,stroke:#885270,stroke-width:2px,color:#441E33
>     classDef schedule fill:#FDF3FF,stroke:#7E65AE,stroke-width:2px,color:#504B5F
>
>     class Conv1,Conv2 trigger
>     class Agent process
>     class Store output
>     class Cron schedule
> ```
>
> Schedule the consolidation agent with a cron job:
>
> ```python theme={"theme":{"light":"catppuccin-latte","dark":"catppuccin-mocha"}}
> from langgraph_sdk import get_client
>
> client = get_client(url="<DEPLOYMENT_URL>")
>
> cron_job = await client.crons.create(
>     assistant_id="consolidation_agent",
>     schedule="0 */6 * * *",
>     input={"messages": [{"role": "user", "content": "Consolidate recent memories."}]},
> )
> ```
>
> **[Note]**
> All cron schedules are interpreted in **UTC**. See [cron jobs](https://docs.langchain.com/langsmith/cron-jobs) for details on managing and deleting cron jobs.
>
> **[Warning]**
> The cron interval must match the lookback window inside the consolidation agent. The example above runs every 6 hours (`0 */6 * * *`) and the agent's `search_recent_conversations` tool looks back `timedelta(hours=6)` — keep these in sync. If the cron runs more often than the lookback, you'll reprocess the same conversations; if it runs less often, you'll drop memories that fall outside the window.
>
> For more on deploying agents with background processes, see [going to production](https://docs.langchain.com/oss/python/deepagents/going-to-production).
>
> ### Read-only vs writable memory
>
> By default, the agent can both read and write memory files. For shared state like organization policies or compliance rules, you may want to make memory **read-only** so the agent can reference it but not modify it. This prevents prompt injection via shared memory and ensures that only your application code controls what's in the file.
>
> | Permission               | Use case                                                                                                                   | How it works                                                                                                                                                                                                                                                        |
> | ------------------------ | -------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
> | **Read-write** (default) | User preferences, agent self-improvement, learned [skills](https://docs.langchain.com/oss/python/deepagents/skills)                                  | Agent updates files via `edit_file` tool                                                                                                                                                                                                                            |
> | **Read-only**            | Organization policies, compliance rules, shared knowledge bases, developer-defined [skills](https://docs.langchain.com/oss/python/deepagents/skills) | Populate via application code or the [Store API](https://docs.langchain.com/langsmith/custom-store). Use [permissions](https://docs.langchain.com/oss/python/deepagents/permissions) to deny writes to specific paths, or [policy hooks](https://docs.langchain.com/oss/python/deepagents/backends#add-policy-hooks) for custom validation logic. |
>
> **Security considerations:** If one user can write to memory that another user reads, a malicious user could inject instructions into shared state. To mitigate this:
>
> * **Default to user scope** `(user_id)` unless you have a specific reason to share
> * Use **read-only memory** for shared policies (populate via application code, not the agent)
> * Add **human-in-the-loop** validation before the agent writes to shared memory. Use an [interrupt](https://docs.langchain.com/oss/python/langgraph/interrupts) to require human approval for writes to sensitive paths.
>
> To enforce read-only memory, use [permissions](https://docs.langchain.com/oss/python/deepagents/permissions) to declaratively deny writes to specific paths. For custom validation logic (rate limiting, audit logging, content inspection), use [backend policy hooks](https://docs.langchain.com/oss/python/deepagents/backends#add-policy-hooks).
>
> ### Concurrent writes
>
> Multiple threads can write to memory in parallel, but concurrent writes to the **same file** can cause last-write-wins conflicts. For user-scoped memory this is rare since users typically have one active conversation at a time. For agent-scoped or organization-scoped memory, consider using [background consolidation](#background-consolidation) to serialize writes, or structure memory as separate files per topic to reduce contention.
>
> In practice, if a write fails due to a conflict, the LLM is usually smart enough to retry or recover gracefully, so a single lost write is not catastrophic.
>
> ### Multiple agents in the same deployment
>
> To give each agent its own memory in a shared deployment, add `assistant_id` to the namespace:
>
> ```python theme={"theme":{"light":"catppuccin-latte","dark":"catppuccin-mocha"}}
> StoreBackend(
>     namespace=lambda rt: (
>         rt.server_info.assistant_id,  # [!code highlight]
>         rt.server_info.user.identity,
>     ),
> )
> ```
>
> Use `assistant_id` alone if you only need per-agent isolation without per-user scoping.
>
> **[Tip]**
> Use [LangSmith tracing](https://docs.langchain.com/langsmith/trace-with-langgraph) to audit what your agent writes to memory. Every file write appears as a tool call in the trace.
>
> ## See also
>
> * [OpenWiki](https://docs.langchain.com/oss/openwiki/overview): Generate and maintain repository wikis that coding agents find through `AGENTS.md`
> * [Backends](https://docs.langchain.com/oss/python/deepagents/backends): Choose where memory files are stored
> * [Context engineering](https://docs.langchain.com/oss/python/deepagents/context-engineering): Short-term memory, offloading, and summarization
> * [Skills](https://docs.langchain.com/oss/python/deepagents/skills): On-demand procedural memory
>
> [Original page](https://docs.langchain.com/oss/python/deepagents/memory)
