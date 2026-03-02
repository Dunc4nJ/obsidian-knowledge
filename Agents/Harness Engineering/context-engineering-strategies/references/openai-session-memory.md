---
created: 2026-03-02
description: The OpenAI Agents SDK Session object enables two proven context management techniques — trimming and summarization — to keep multi-turn agents coherent, cost-efficient, and debuggable
source: https://cookbook.openai.com/examples/agents_sdk/session_memory
---

## Key Takeaways

The cookbook frames context management as the central challenge of long-running agents — not whether the model is smart enough, but whether the right information survives across turns. This is the same core tension described in [[context engineering is the art of filling the context window with the right information for the next step]], but here it's solved at the session level rather than the retrieval level.

Two concrete patterns are implemented end-to-end. **Trimming** keeps the last N user turns verbatim and drops everything older — deterministic, zero-latency, but amnesic beyond the window. **Summarization** compresses older turns into a synthetic user-assistant pair injected at the top of history, preserving long-range memory at the cost of potential distortion. The tradeoff between context loss (trimming) and context poisoning (summarization) maps directly to the [[progressive disclosure filters force agent selectivity over what enters context]] principle — both are mechanisms for deciding what enters the next inference call.

The summarization prompt design is particularly instructive. It enforces structured sections (Product & Environment, Steps Tried, Current Status, Next Step), includes a contradiction check against system instructions, and marks uncertain facts as UNVERIFIED rather than guessing. This is a practical implementation of the compression ratios discussed in [[over 40 percent of agentic AI projects fail due to poor architecture not model limitations]] — the cookbook targets 200-word summaries that can replace hundreds of turns.

The `SummarizingSession` class demonstrates a clean async pattern: release the lock during slow summarization work, then re-check conditions before applying. This prevents stale rewrites when messages arrive during compression — a production concern that most tutorials ignore. The metadata layer (`synthetic` flags, `kind` tags) enables observability without polluting the model's view, connecting to the [[agentic software engineering requires six pillars beyond the agent itself to survive production]] emphasis on governance and debugging infrastructure.

The cookbook's eval suggestions — transcript replay, LLM-as-judge for summary quality, error regression tracking, token pressure checks — reinforce that [[four memory layers serve different knowledge types]]: you can't evaluate memory management without testing whether the agent can still act on retained information, not just recall it.

## External Resources

- [OpenAI Agents SDK (Python)](https://github.com/openai/openai-agents-python) — the SDK providing the Session abstraction used throughout the cookbook
- [OpenAI Agents SDK Sessions docs](https://openai.github.io/openai-agents-python/sessions/) — API reference for the SessionABC interface
- [OpenAI Responses API](https://platform.openai.com/docs/api-reference/responses/create#responses-create-previous_response_id) — the underlying API with `previous_response_id` chaining that Sessions build on

## Original Content

> [!quote]- Source Material
> AI agents often operate in long-running, multi-turn interactions, where keeping the right balance of context is critical. If too much is carried forward, the model risks distraction, inefficiency, or outright failure. If too little is preserved, the agent loses coherence.
>
> Here, context refers to the total window of tokens (input + output) that the model can attend to at once. For GPT-5, this capacity is up to 272k input tokens and 128k output tokens but even such a large window can be overwhelmed by uncurated histories, redundant tool results, or noisy retrievals. This makes context management not just an optimization, but a necessity.
>
> In this cookbook, we'll explore how to manage context effectively using the Session object from the OpenAI Agents SDK, focusing on two proven context management techniques — trimming and compression — to keep agents fast, reliable, and cost-efficient.
>
> #### Why Context Management Matters
>
> - Sustained coherence across long threads – Keep the agent anchored to the latest user goal without dragging along stale details. Session-level trimming and summaries prevent "yesterday's plan" from overriding today's ask.
> - Higher tool-call accuracy – Focused context improves function selection and argument filling, reducing retries, timeouts, and cascading failures during multi-tool runs.
> - Lower latency & cost – Smaller, sharper prompts cut tokens per turn and attention load.
> - Error & hallucination containment – Summaries act as "clean rooms" that correct or omit prior mistakes; trimming avoids amplifying bad facts ("context poisoning") turn after turn.
> - Easier debugging & observability – Stable summaries and bounded histories make logs comparable: you can diff summaries, attribute regressions, and reproduce failures reliably.
> - Multi-issue and handoff resilience – In multi-problem chats, per-issue mini-summaries let the agent pause/resume, escalate to humans, or hand off to another agent while staying consistent.
>
> The OpenAI Responses API includes basic memory support through built-in state and message chaining with `previous_response_id`.
>
> You can continue a conversation by passing the prior response's id as `previous_response_id`, or you can manage context manually by collecting outputs into a list and resubmitting them as the input for the next response.
>
> What you don't get is automatic memory management. That's where the Agents SDK comes in. It provides session memory on top of Responses, so you no longer need to manually append `response.output` or track IDs yourself. The session becomes the memory object: you simply call `session.run("...")` repeatedly, and the SDK handles context length, history, and continuity — making it far easier to build coherent, multi-turn agents.
>
> #### Real-World Scenario
>
> We'll ground the techniques in a practical example for one of the common long-running tasks, such as:
>
> - Multi-turn Customer Service Conversations: In extended conversations about tech products — spanning both hardware and software — customers often surface multiple issues over time. The agent must stay consistent and goal-focused while retaining only the essentials rather than hauling along every past detail.
>
> #### Techniques Covered
>
> To address these challenges, we introduce two separate concrete approaches using OpenAI Agents SDK:
>
> **Context Trimming** – dropping older turns while keeping the last N turns.
>
> Pros:
> - Deterministic & simple: No summarizer variability; easy to reason about state and to reproduce runs.
> - Zero added latency: No extra model calls to compress history.
> - Fidelity for recent work: Latest tool results, parameters, and edge cases stay verbatim — great for debugging.
> - Lower risk of "summary drift": You never reinterpret or compress facts.
>
> Cons:
> - Forgets long-range context abruptly: Important earlier constraints, IDs, or decisions can vanish once they scroll past N.
> - User experience "amnesia": Agent can appear to "forget" promises or prior preferences midway through long sessions.
> - Wasted signal: Older turns may contain reusable knowledge (requirements, constraints) that gets dropped.
> - Token spikes still possible: If a recent turn includes huge tool payloads, your last-N can still blow up the context.
>
> Best when: Your tasks in the conversation are independent from each other with non-overlapping context. You need predictability, easy evals, and low latency. The conversation's useful context is local.
>
> **Context Summarization** – compressing prior messages (assistant, user, tools, etc.) into structured, shorter summaries injected into the conversation history.
>
> Pros:
> - Retains long-range memory compactly: Past requirements, decisions, and rationales persist beyond N.
> - Smoother UX: Agent "remembers" commitments and constraints across long sessions.
> - Cost-controlled scale: One concise summary can replace hundreds of turns.
> - Searchable anchor: A single synthetic assistant message becomes a stable "state of the world so far."
>
> Cons:
> - Summarization loss & bias: Details can be dropped or misweighted; subtle constraints may vanish.
> - Latency & cost spikes: Each refresh adds model work.
> - Compounding errors: If a bad fact enters the summary, it can poison future behavior ("context poisoning").
> - Observability complexity: You must log summary prompts/outputs for auditability and evals.
>
> Best when: You have use cases where tasks need context collected across the flow. You need continuity over long horizons. Sessions exceed N turns but must preserve decisions, IDs, and constraints reliably.
>
> *Comparison table of techniques:*
> ![[openai-session-memory-001.jpg]]
>
> ### Define Agents
>
> #### Customer Service Agent
>
> ```python
> support_agent = Agent(
>     name="Customer Support Assistant",
>     model="gpt-5",
>     instructions=(
>         "You are a patient, step-by-step IT support assistant. "
>         "Your role is to help customers troubleshoot and resolve issues with devices and software. "
>         "Guidelines:\n"
>         "- Be concise and use numbered steps where possible.\n"
>         "- Ask only one focused, clarifying question at a time before suggesting next actions.\n"
>         "- Track and remember multiple issues across the conversation; update your understanding as new problems emerge.\n"
>         "- When a problem is resolved, briefly confirm closure before moving to the next.\n"
>     )
> )
> ```
>
> ### Context Trimming
>
> #### Implement Custom Session Object
>
> We are using the Session object from the OpenAI Agents Python SDK. Here's a `TrimmingSession` implementation that keeps only the last N turns (a "turn" = one user message and everything until the next user message — including the assistant reply and any tool calls/results). It's in-memory and trims automatically on every write and read.
>
> ```python
> class TrimmingSession(SessionABC):
>     """Keep only the last N *user turns* in memory."""
>
>     def __init__(self, session_id: str, max_turns: int = 8):
>         self.session_id = session_id
>         self.max_turns = max(1, int(max_turns))
>         self._items: Deque[TResponseInputItem] = deque()
>         self._lock = asyncio.Lock()
>
>     async def get_items(self, limit: int | None = None) -> List[TResponseInputItem]:
>         async with self._lock:
>             trimmed = self._trim_to_last_turns(list(self._items))
>             return trimmed[-limit:] if (limit is not None and limit >= 0) else trimmed
>
>     async def add_items(self, items: List[TResponseInputItem]) -> None:
>         if not items:
>             return
>         async with self._lock:
>             self._items.extend(items)
>             trimmed = self._trim_to_last_turns(list(self._items))
>             self._items.clear()
>             self._items.extend(trimmed)
>
>     def _trim_to_last_turns(self, items):
>         if not items:
>             return items
>         count = 0
>         start_idx = 0
>         for i in range(len(items) - 1, -1, -1):
>             if _is_user_msg(items[i]):
>                 count += 1
>                 if count == self.max_turns:
>                     start_idx = i
>                     break
>         return items[start_idx:]
> ```
>
> *How trimming works — keeping only the last N user turns:*
> ![[openai-session-memory-003.jpg]]
>
> **What counts as a "turn"**: A turn = one user message plus everything that follows it (assistant replies, reasoning, tool calls, tool results) until the next user message.
>
> **When trimming happens**: On write (`add_items` appends then trims) and on read (`get_items` returns a trimmed view).
>
> **How it decides what to keep**: Scan the history backwards and collect the indices of the last N user messages. Find the earliest index among those N user messages. Keep everything from that index to the end; drop everything before it.
>
> ### Context Summarization
>
> Once the history exceeds `max_turns`, it keeps the most recent N user turns intact and summarizes everything older into two synthetic messages:
> - user: "Summarize the conversation we had so far."
> - assistant: {generated summary}
>
> #### Summarization Prompt
>
> A well-crafted summarization prompt is essential for preserving conversation context. The prompt should strike the right balance: not overloaded with unnecessary information, but not so sparse that key context is lost.
>
> ```python
> SUMMARY_PROMPT = """
> You are a senior customer-support assistant for tech devices, setup, and software issues.
> Compress the earlier conversation into a precise, reusable snapshot for future turns.
>
> Before you write (do this silently):
> - Contradiction check: compare user claims with system instructions and tool definitions/logs
> - Temporal ordering: sort key events by time; the most recent update wins
> - Hallucination control: if any fact is uncertain/not stated, mark it as UNVERIFIED
>
> Write a structured, factual summary ≤ 200 words using these sections:
> • Product & Environment
> • Reported Issue
> • Steps Tried & Results
> • Identifiers
> • Timeline Milestones
> • Tool Performance Insights
> • Current Status & Blockers
> • Next Recommended Step
> """
> ```
>
> **Key Principles for Designing Memory Summarization Prompts:**
> - Milestones: Highlight important events — when an issue is resolved, valuable information is uncovered, or all necessary details have been collected.
> - Use Case Specificity: Tailor the compression prompt to the specific use case.
> - Contradiction Check: Ensure the summary does not conflict with itself, system instructions or tool definitions.
> - Timestamps & Temporal Flow: Incorporate timing of events to help the model reason about updates in sequence.
> - Chunking: Organize details into categories or sections rather than long paragraphs.
> - Tool Performance Insights: Capture lessons learned from multi-turn, tool-enabled interactions.
> - Hallucination Control: Be precise — even minor hallucinations in a summary can propagate forward.
> - Model Choice: Select a summarizer model based on use case requirements, summary length, and latency/cost tradeoffs.
>
> *How summarization works — compressing older turns into a synthetic summary pair:*
> ![[openai-session-memory-002.jpg]]
>
> #### SummarizingSession Implementation
>
> ```python
> class SummarizingSession:
>     """
>     Session that keeps only the last N user turns verbatim
>     and summarizes the rest.
>     """
>     def __init__(self, keep_last_n_turns=3, context_limit=3,
>                  summarizer=None, session_id=None):
>         self.keep_last_n_turns = keep_last_n_turns
>         self.context_limit = context_limit
>         self.summarizer = summarizer
>         self._records: deque[Record] = deque()
>         self._lock = asyncio.Lock()
>
>     async def add_items(self, items):
>         # 1) Ingest items
>         # 2) Check if summarization needed
>         # 3) If needed: snapshot prefix, summarize (outside lock),
>         #    re-check, apply atomically
>         # Key: release lock during slow summarization,
>         #      then re-verify before applying
>         ...
> ```
>
> **Design notes:**
> - Turn boundary preserved at the "fresh" side: the `keep_last_n_turns` user turns remain verbatim; everything older is compressed.
> - Two-message summary block: easy for downstream tooling to detect (metadata.synthetic == True).
> - Async + lock discipline: release the lock while the (potentially slow) summarization runs; then re-check the condition before applying to avoid racey merges.
> - Idempotent behavior: if more messages arrive during summarization, the post-await recheck prevents stale rewrites.
>
> #### Evaluation Ideas
>
> - **Baseline & Deltas**: Run core eval sets and compare before/after experiments.
> - **LLM-as-Judge**: Use a model with a carefully designed grader prompt to evaluate summarization quality.
> - **Transcript Replay**: Re-run long conversations and measure next-turn accuracy with and without context trimming.
> - **Error Regression Tracking**: Watch for unanswered questions, dropped constraints, or unnecessary/repeated tool calls.
> - **Token Pressure Checks**: Flag cases where token limits force dropping protected context.
>
> [Original page](https://cookbook.openai.com/examples/agents_sdk/session_memory)
