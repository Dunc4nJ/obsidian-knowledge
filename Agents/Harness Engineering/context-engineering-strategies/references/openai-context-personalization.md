---
created: 2026-03-02
description: OpenAI cookbook demonstrating state-based long-term memory for agent personalization using RunContextWrapper, with patterns for memory distillation, consolidation, injection, context trimming, and summarization.
source: https://cookbook.openai.com/examples/agents_sdk/context_personalization
type: reference
---

## Key Takeaways

This cookbook presents a comprehensive state-based memory architecture for building personalized AI agents, grounded in a travel concierge use case. The core insight is that [[PARA and atomic facts give AI agents durable structured memory|structured state combined with unstructured memory notes]] provides the right balance for personalization — structured fields handle stable, machine-enforceable attributes while free-form notes capture nuanced, evolving preferences.

The memory lifecycle follows a clear four-phase pattern: **inject** curated state into the system prompt at session start, **reason** over it during the conversation, **distill** new preferences via a dedicated `save_memory_note` tool, and **consolidate** session notes into global memory at session end. This two-phase memory processing (note-taking then consolidation) is explicitly called out as more reliable than trying to build the entire memory system in one shot.

A key architectural decision is choosing state-based over retrieval-based memory. State-based memory encodes user knowledge as structured, authoritative fields with clear precedence (global vs session), supports belief updates instead of fact accumulation, and enables deterministic decision-making — making it better suited for tasks requiring continuity like travel planning. This connects to [[four memory layers serve different knowledge types|the principle that different memory types serve different functions]].

The cookbook introduces a clear precedence hierarchy for conflict resolution: latest user input wins over session overrides, which win over global defaults. Memory injection uses XML-like blocks (`<user_profile>`, `<memories>`, `<memory_policy>`) to reduce accidental instruction-following from memory text — not a security boundary, but a practical scaffolding choice.

The consolidation phase is identified as the most sensitive and error-prone stage, with common failure modes including context poisoning from bad facts entering the summary, memory loss from over-aggressive pruning, and compounding errors. The cookbook emphasizes that **forgetting is not a bug — it is essential** for maintaining memory health over time.

The second half covers two complementary context management techniques: **trimming** (keeping last N turns, zero latency but hard context loss) and **summarization** (compressing older turns into structured summaries, preserving long-range memory but risking context distortion). Both are implemented as custom `Session` objects in the OpenAI Agents SDK, with the summarization approach using a carefully designed prompt that includes contradiction checking, temporal ordering, and hallucination control.

The memory schema design is driven by a practical metaprompting question: "If this were a human agent performing the same task, what would they actively hold in working memory?" This grounds memory design in task-relevance rather than arbitrary persistence.

## External Resources

- [OpenAI Agents SDK](https://github.com/openai/openai-agents-python) — Python SDK for building agents with session memory, hooks, and lifecycle management
- [RunContextWrapper documentation](https://openai.github.io/openai-agents-python/context/) — Persistent state management for agents
- [Session memory documentation](https://openai.github.io/openai-agents-python/sessions/) — Session object API for context management
- [Lifecycle hooks reference](https://openai.github.io/openai-agents-python/ref/lifecycle/) — Hook points for memory injection and other lifecycle events
- [TrimmingSession cookbook](https://cookbook.openai.com/examples/agents_sdk/session_memory) — Previous cookbook on session memory trimming

## Original Content

> [!quote]- Source Material
>
> Modern AI agents are no longer just reactive assistants—they're becoming adaptive collaborators. The leap from "responding" to "remembering" defines the new frontier of context engineering. At its core, context engineering is about shaping what the model knows at any given moment. By managing what's stored, recalled, and injected into the model's working memory, we can make an agent that feels personal, consistent, and context-aware.
>
> The RunContextWrapper in the OpenAI Agents SDK provides the foundation for this. It allows developers to define structured state objects that persist across runs, enabling memory, notes, or even preferences to evolve over time. When paired with hooks and context-injection logic, this becomes a powerful system for context personalization—building agents that learn who you are, remember past actions, and tailor their reasoning accordingly.
>
> This cookbook shows a state-based long-term memory pattern:
>
> - State object = your local-first memory store (structured profile + notes)
> - Distill memories during a run (tool call → session notes)
> - Consolidate session notes into global notes at the end (dedupe + conflict resolution)
> - Inject a well-crafted state at the start of each run (with precedence rules)
>
> ## Why Context Personalization Matters
>
> Context personalization is the "magic moment" when an AI agent stops feeling generic and starts feeling like your agent.
>
> It's when the system remembers your coffee order, your company's tone of voice, your past support tickets, or your preferred aisle seat—and uses that knowledge naturally, without being prompted.
>
> From a user perspective, this builds trust and delight: the agent appears to genuinely understand them. From a company perspective, it creates a strategic moat—a way to continuously capture, refine, and apply high-quality behavioral data. If implemented carefully, you can capture denser, higher-signal information about your users than typical clicks, impressions, or history data. Each interaction becomes a signal for better service, higher retention, and deeper insight into user needs.
>
> This value extends beyond the agent itself. When managed rigorously and safely, personalized context can also empower human-facing roles—support agents, account managers, travel advisors—by giving them a richer, longitudinal understanding of the customer. Over time, analyzing accumulated memories reveals how user preferences, behaviors, and goals evolve, enabling smarter product decisions and more adaptive systems.
>
> In practice, effective personalization means maintaining structured state—preferences, constraints, prior outcomes—and injecting only the relevant slices into the agent's context at the right moment. Different agents demand different memory lifecycles: a life-coaching agent may require fast-evolving, nuanced memories, while an IT troubleshooting agent benefits from slower, more predictable state. Done well, personalization transforms a stateless chatbot into a persistent digital collaborator.
>
> We'll ground this tutorial in a travel concierge agent that helps users book flights, hotels, and car rentals with a high degree of personalization.
>
> In this tutorial, you'll build an agent that:
>
> - starts each session with a structured user profile and curated memory notes
> - captures new durable preferences (for example, "I'm vegetarian") via a dedicated tool
> - consolidates those preferences into long-term memory at the end of each run
> - resolves conflicts using a clear precedence order: latest user input → session overrides → global defaults
>
> ### Architecture at a Glance
>
> This section summarizes how state and memory flow across sessions.
>
> - **Before the Session Starts** — A state object (user profile + global memory notes) is stored locally in your system. This state represents the agent's long-term understanding of the user.
> - **At the Start of a New Session** — The state object is injected into the system prompt: Structured fields are included as YAML frontmatter. Unstructured memories are included as a Markdown memory list.
> - **During the Session** — As the agent interacts with the user, it captures candidate memories using `save_memory_note(...)`. These notes are written to session memory within the state object.
> - **When the Context Is Trimmed** — If context trimming occurs (e.g., to avoid hitting the context limit): Session-scoped memory notes are reinjected into the system prompt. This preserves important short-term context across long-running sessions.
> - **At the End of the Session** — A consolidation job runs asynchronously: Session notes are merged into global memory. Conflicts are resolved and duplicates are removed.
> - **Next Run** — The updated state object is reused. The lifecycle repeats from the beginning.
>
> AI memory is still a new concept, and there is no one-size-fits-all solution. In this cookbook, we make design decisions based on a well-defined use case: a Travel Concierge agent.
>
> Considering the many challenges in retrieval-based memory mechanisms including the need to train the model, state-based memory is better suited than retrieval-based memory for a travel concierge AI agent because travel decisions depend on continuity, priorities, and evolving preferences—not ad-hoc search. A travel agent must reason over a current, coherent user state (loyalty programs, seat preferences, budgets, visa constraints, trip intent, and temporary overrides like "this time I want to sleep") and consistently apply it across flights, hotels, insurance, and follow-ups.
>
> Retrieval-based memory treats past interactions as loosely related documents, making it brittle to phrasing, prone to missing overrides, and unable to reconcile conflicts or updates over time. In contrast, state-based memory encodes user knowledge as structured, authoritative fields with clear precedence (global vs session), supports belief updates instead of fact accumulation, and enables deterministic decision-making without relying on fragile semantic search. This allows the agent to behave less like a search engine and more like a persistent concierge—maintaining continuity across sessions, adapting to context, and reliably using memory whenever it is relevant, not just when it is successfully retrieved.
>
> The shape of an agent's memory is entirely driven by the use case. A reliable way to design it is to start with a simple question:
>
> *If this were a human agent performing the same task, what would they actively hold in working memory to get the job done? What details would they track, reference, or infer in real time?*
>
> This framing grounds memory design in task-relevance, not arbitrary persistence.
>
> ### Metaprompting for Memory Extraction
>
> Use this pattern to elicit the memory schema for any workflow:
>
> **Template:**
> ```
> You are a [USE CASE] agent whose goal is [GOAL].
> What information would be important to keep in working memory during a single session?
> List both fixed attributes (always needed) and inferred attributes (derived from user behavior or context).
> ```
>
> Combining predefined structured keys with unstructured memory notes provides the right balance for a travel concierge agent—enabling reliable personalization while still capturing rich, free-form user preferences. In this design, the quality of your internal data systems becomes critical: structured fields should be consistently hydrated and kept up to date from trusted internal sources, while unstructured memories fill in the gaps where flexibility is required.
>
> For this cookbook, we keep things simple by sourcing memory notes only from explicit user messages. In more advanced agents, this definition naturally expands to include signals from tool calls, system actions, and full execution traces, enabling deeper and more autonomous memory formation.
>
> ### Structured Memory (Schema-driven, machine-enforceable, predictable)
>
> These should follow strict formats, be validated, and used directly in logic, filtering, or booking APIs.
>
> **Identity & Core Profile:** Global customer ID, Full name, Date of birth, Gender, Passport expiry date
>
> **Loyalty & Programs:** Airline loyalty status, Hotel loyalty status, Loyalty IDs
>
> **Preferences & Coverage:** Seat preference, Insurance coverage profile (car rental coverage type, travel medical coverage status, coverage level)
>
> **Constraints:** Visa requirements (array of country / region codes)
>
> ### Unstructured Memory (Narrative, contextual, semantic)
>
> These are freeform and optimized for reasoning, personalization, and human-like decision-making.
>
> **Global Memory Notes:**
> - "User usually prefers aisle seats."
> - "For trips shorter than a week, user generally prefers not to check bags."
> - "User prefers coverage that includes collision damage waiver and zero deductible when available."
>
> Tip: Do not dump all the fields from internal systems into the profile section. Make sure that every single token you add here helps agent to make better decisions. Some these fields might even be an input parameter to a tool call that you can pass from the state object without making it visible to the model.
>
> Using the RunContextWrapper, the agent maintains a persistent state object containing structured data. Separate memory by scope to reduce noise and make evolution safer over time.
>
> ### User-Level Memory (Global Notes)
>
> Durable preferences that should persist across sessions and influence future interactions. Examples: "Prefers aisle seats", "Vegetarian", "United Gold status". These are injected at the start of each session and updated cautiously during consolidation.
>
> ### Session-Level Memory (Session Notes)
>
> Short-lived or contextual information relevant only to the current interaction. Examples: "This trip is a family vacation", "Budget under $2,000 for this trip", "I prefer window seat this time for the red eye flight." Session notes act as a staging area and are promoted to global memory only if they prove durable.
>
> Rule of thumb: if it should affect future trips by default, store it globally; if it only matters now, keep it session-scoped.
>
> **Example state object:**
> ```json
> {
>   "profile": {
>     "global_customer_id": "crm_12345",
>     "name": "John Doe",
>     "age": 31,
>     "home_city": "San Francisco",
>     "currency": "USD",
>     "passport_expiry_date": "2029-06-12",
>     "loyalty_status": {"airline": "United Gold", "hotel": "Marriott Titanium"},
>     "loyalty_ids": {"marriott": "MR998877", "hilton": "HH445566", "hyatt": "HY112233"},
>     "seat_preference": "aisle",
>     "tone": "concise and friendly",
>     "active_visas": ["Schengen", "US"],
>     "tight_connection_ok": false,
>     "insurance_coverage_profile": {
>       "car_rental": "primary_cdw_included",
>       "travel_medical": "covered"
>     }
>   },
>   "global_memory": {
>     "notes": [
>       {"text": "For trips shorter than a week, user generally prefers not to check bags.", "last_update_date": "2025-04-05", "keywords": ["baggage"]},
>       {"text": "User usually prefers aisle seats.", "last_update_date": "2024-06-25", "keywords": ["seat_preference"]},
>       {"text": "User generally likes staying in central, walkable city-center neighborhoods.", "last_update_date": "2024-02-11", "keywords": ["neighborhood"]},
>       {"text": "User generally likes to compare options side-by-side.", "last_update_date": "2023-02-17", "keywords": ["pricing"]},
>       {"text": "User prefers high floors.", "last_update_date": "2023-02-11", "keywords": ["room"]}
>     ]
>   }
> }
> ```
>
> Memory is not static. Over time, you can analyze user behavior to identify different patterns, such as:
>
> - **Stability** — preferences that rarely change (e.g., "seat preference is almost always aisle")
> - **Drift** — gradual changes over time (e.g., "average trip budget has increased month over month")
> - **Contextual variance** — preferences that depend on context (e.g., "business trips vs. family trips behave differently")
>
> These signals should directly influence your memory architecture:
>
> - Stable, repeatedly confirmed preferences can be promoted from free-form notes into structured profile fields.
> - Volatile or context-dependent preferences should remain as notes, often with recency weighting, confidence scores, or a TTL.
>
> In other words, memory design should evolve as the system learns what is durable versus situational.
>
> ### 4.1 Memory Distillation
>
> Memory distillation extracts high-quality, durable signals from the conversation and records them as memory notes.
>
> In this cookbook, distillation is performed during live turns via a dedicated tool, enabling the agent to capture preferences and constraints as they are explicitly expressed.
>
> An alternative approach is post-session memory distillation, where memories are extracted at the end of the session using the full execution trace. This can be especially useful for incorporating signals from tool usage patterns and internal reasoning that may not surface directly in user-facing turns.
>
> ### 4.2 Memory Consolidation
>
> Memory consolidation runs asynchronously at the end of each session, graduating eligible session notes into global memory when appropriate.
>
> This is the most sensitive and error-prone stage of the lifecycle. Poor consolidation can lead to context poisoning, memory loss, or long-term hallucinations. Common failure modes include:
>
> - Losing meaningful information through over-aggressive pruning
> - Promoting noisy, speculative, or unreliable signals
> - Introducing contradictions or duplicate memories over time
>
> To maintain a healthy memory system, consolidation must explicitly handle:
>
> - **Deduplication** — merging semantically equivalent memories
> - **Conflict resolution** — choosing between competing or outdated facts
> - **Forgetting** — pruning stale, low-confidence, or superseded memories
>
> Forgetting is not a bug—it is essential. Without careful pruning, memory stores will accumulate redundant and outdated information, degrading agent quality over time. Well-curated prompts and strict consolidation instructions are critical to controlling the aggressiveness and safety of this step.
>
> ### 4.3 Memory Injection
>
> Inject curated memory back into the model context at the start of each session. In this cookbook, injection is implemented via hooks that run after context trimming and before the agent begins execution, under the global memory section. High-signal memory in the system prompt is extremely effective for latency.
>
> ### Design Decisions Summary
>
> To address these challenges, this cookbook applies a set of design decisions tailored to this specific agent, implemented using the OpenAI Agents SDK:
>
> - **State Management** – Maintain and evolve the agent's persistent state using the RunContextWrapper class. Pre-populate and curate key fields from internal systems before each session begins.
> - **Memory Injection** – Inject only the relevant portions of state into the agent's context at the start of each session. Use YAML frontmatter for structured, machine-readable metadata. Use Markdown notes for flexible, human-readable memory.
> - **Memory Distillation** – Capture dynamic insights during active turns by writing session notes via a dedicated tool.
> - **Memory Consolidation** – Merge session-level notes into a dense, conflict-free set of global memories. Forgetting: Prune stale, overwritten, or low-signal memories during consolidation, and deduplicate aggressively over time.
>
> Two-phase memory processing (note taking → consolidation) is more reliable than one-shot build the whole memory system at once.
>
> All techniques in this cookbook are implemented in a local-first manner. Session and global memories live in your own state object and can be kept ZDR (Zero Data Retention) by design, as long as you avoid remote persistence.
>
> These approaches are intentionally zero-shot—relying on prompting, orchestration, and lightweight scaffolding rather than training. Once the end-to-end design and evaluations are validated, a natural next step is fine-tuning to achieve stronger and more consistent memory behaviors such as extraction, consolidation, and conflict resolution.
>
> Over time, the concierge becomes more efficient and human-like:
>
> - It auto-suggests flights that match the user's seat preference.
> - It filters hotels by loyalty tier benefits.
> - It pre-fills rental forms with known IDs and preferences.
>
> This pattern exemplifies how context engineering + state management turn personalization into a sustainable differentiator. Rather than retraining models or embedding static rules, you evolve the state layer—a dynamic, inspectable memory the model can reason over.
>
> ### Implementation Code
>
> **Step 1 — Define the State Object:**
>
> ```python
> from dataclasses import dataclass, field
> from typing import Any, Dict, List
>
> @dataclass
> class MemoryNote:
>     text: str
>     last_update_date: str
>     keywords: List[str]
>
> @dataclass
> class TravelState:
>     profile: Dict[str, Any] = field(default_factory=dict)
>     global_memory: Dict[str, Any] = field(default_factory=lambda: {"notes": []})
>     session_memory: Dict[str, Any] = field(default_factory=lambda: {"notes": []})
>     trip_history: Dict[str, Any] = field(default_factory=lambda: {"trips": []})
>     system_frontmatter: str = ""
>     global_memories_md: str = ""
>     session_memories_md: str = ""
>     inject_session_memories_next_turn: bool = False
> ```
>
> **Step 2 — Memory Distillation Tool:**
>
> ```python
> @function_tool
> def save_memory_note(
>     ctx: RunContextWrapper[TravelState],
>     text: str,
>     keywords: List[str],
> ) -> dict:
>     """
>     Save a candidate memory note into state.session_memory.notes.
>     Capture HIGH-SIGNAL, reusable information that will help make better travel decisions.
>     """
>     if "notes" not in ctx.context.session_memory or ctx.context.session_memory["notes"] is None:
>         ctx.context.session_memory["notes"] = []
>
>     clean_keywords = [k.strip().lower() for k in keywords if isinstance(k, str) and k.strip()][:3]
>
>     ctx.context.session_memory["notes"].append({
>         "text": text.strip(),
>         "last_update_date": _today_iso_utc(),
>         "keywords": clean_keywords,
>     })
>     return {"ok": True}
> ```
>
> **Step 3 — Trimming Session:**
>
> ```python
> class TrimmingSession(SessionABC):
>     """Keep only the last N user turns in memory."""
>
>     def __init__(self, session_id: str, state: TravelState, max_turns: int = 8):
>         self.session_id = session_id
>         self.state = state
>         self.max_turns = max(1, int(max_turns))
>         self._items: Deque[TResponseInputItem] = deque()
>         self._lock = asyncio.Lock()
>
>     async def add_items(self, items: List[TResponseInputItem]) -> None:
>         if not items:
>             return
>         async with self._lock:
>             self._items.extend(items)
>             original_len = len(self._items)
>             trimmed = self._trim_to_last_turns(list(self._items))
>             if len(trimmed) < original_len:
>                 self.state.inject_session_memories_next_turn = True
>             self._items.clear()
>             self._items.extend(trimmed)
> ```
>
> **Step 4 — Memory Injection via Hooks:**
>
> Precedence rule (recommended):
> - The user's latest instruction in the current dialogue wins.
> - Structured profile keys are generally trusted (especially if sourced/enriched internally).
> - Global memory notes are advisory and must not override current instructions.
> - If memory conflicts with the user's current request, ask a clarifying question.
>
> ```python
> MEMORY_INSTRUCTIONS = """
> <memory_policy>
> You may receive two memory lists:
> - GLOBAL memory = long-term defaults ("usually / in general").
> - SESSION memory = trip-specific overrides ("this trip / this time").
>
> Precedence and conflicts:
> 1) The user's latest message in this conversation overrides everything.
> 2) SESSION memory overrides GLOBAL memory for this trip when they conflict.
> 3) Within the same memory list, if two items conflict, prefer the most recent by date.
> 4) Treat GLOBAL memory as a default, not a hard constraint.
> </memory_policy>
> """
> ```
>
> ```python
> class MemoryHooks(AgentHooks[TravelState]):
>     async def on_start(self, ctx: RunContextWrapper[TravelState], agent: Agent) -> None:
>         ctx.context.system_frontmatter = render_frontmatter(ctx.context.profile)
>         ctx.context.global_memories_md = render_global_memories_md(
>             (ctx.context.global_memory or {}).get("notes", []))
>         if ctx.context.inject_session_memories_next_turn:
>             ctx.context.session_memories_md = render_session_memories_md(
>                 (ctx.context.session_memory or {}).get("notes", []))
>         else:
>             ctx.context.session_memories_md = ""
> ```
>
> **Step 5 — Agent Definition and Demo:**
>
> ```python
> travel_concierge_agent = Agent(
>     name="Travel Concierge",
>     model="gpt-5.2",
>     instructions=instructions,
>     hooks=MemoryHooks(client),
>     tools=[save_memory_note],
> )
> ```
>
> Turn 1: "Book me a flight to Paris next month."
> → Agent asks for departure city/airport and travel dates.
>
> Turn 2: "Do you know my preferences?"
> → Agent recalls: aisle seat, no checked bags for short trips, central/walkable hotels, high floors, likes side-by-side comparison.
>
> Turn 3: "Remember that I am vegetarian."
> → Triggers `save_memory_note`: "Vegetarian (prefers vegetarian meal options when traveling)." Keywords: ["dietary"]
>
> Turn 4: "This time, I like to have a window seat. I really want to sleep"
> → Triggers `save_memory_note`: "This trip only: prefers a window seat to sleep." Keywords: ["seat", "flight"]
>
> **Step 8 — Post Session Memory Consolidation:**
>
> ```python
> def consolidate_memory(state: TravelState, client, model: str = "gpt-5-mini") -> None:
>     """Consolidate session notes into global memory. Merges duplicates, resolves conflicts, clears session."""
>     consolidation_prompt = f"""
>     You are consolidating travel memory notes into LONG-TERM (GLOBAL) memory.
>     RULES:
>     1) Keep only durable information
>     2) Drop session-only / ephemeral notes
>     3) De-duplicate
>     4) Conflict resolution: most recent last_update_date wins
>     5) Keep each note short (1 sentence), specific, and durable
>     6) Do NOT invent new facts
>     """
> ```
>
> After consolidation: "Vegetarian" was promoted to global memory. "This trip only: window seat" was correctly discarded as session-scoped.
>
> ---
>
> ## Part 2: Context Management — Trimming and Summarization
>
> AI agents often operate in **long-running, multi-turn interactions**, where keeping the right balance of **context** is critical. If too much is carried forward, the model risks distraction, inefficiency, or outright failure. If too little is preserved, the agent loses coherence.
>
> *Memory comparison diagram showing state-based vs retrieval-based approaches:*
> ![[openai-ctx-personal-001.jpg]]
>
> ### Why Context Management Matters
>
> - **Sustained coherence across long threads** – Keep the agent anchored to the latest user goal without dragging along stale details.
> - **Higher tool-call accuracy** – Focused context improves function selection and argument filling.
> - **Lower latency & cost** – Smaller, sharper prompts cut tokens per turn and attention load.
> - **Error & hallucination containment** – Summaries act as "clean rooms" that correct or omit prior mistakes.
> - **Easier debugging & observability** – Stable summaries and bounded histories make logs comparable.
> - **Multi-issue and handoff resilience** – Per-issue mini-summaries let the agent pause/resume or hand off while staying consistent.
>
> ### Techniques Covered
>
> **Context Trimming** – dropping older turns while keeping the last N turns.
> - **Pros:** Deterministic & simple, zero added latency, fidelity for recent work, lower risk of "summary drift"
> - **Cons:** Forgets long-range context abruptly, user experience "amnesia", wasted signal, token spikes still possible
> - **Best when:** Tasks are independent, you need predictability, conversation's useful context is local
>
> **Context Summarization** – compressing prior messages into structured, shorter summaries.
> - **Pros:** Retains long-range memory compactly, smoother UX, cost-controlled scale, searchable anchor
> - **Cons:** Summarization loss & bias, latency & cost spikes, compounding errors, observability complexity
> - **Best when:** Tasks need context collected across the flow, sessions exceed N turns but must preserve decisions
>
> | Dimension | Trimming (last-N turns) | Summarizing (older → generated summary) |
> |---|---|---|
> | Latency / Cost | Lowest (no extra calls) | Higher at summary refresh points |
> | Long-range recall | Weak (hard cut-off) | Strong (compact carry-forward) |
> | Risk type | Context loss | Context distortion/poisoning |
> | Observability | Simple logs | Must log summary prompts/outputs |
> | Best for | Tool-heavy ops, short workflows | Analyst/concierge, long threads |
>
> ### Context Trimming Implementation
>
> *Diagram showing how trimming works for max_turns=3:*
> ![[openai-ctx-personal-003.jpg]]
>
> The `TrimmingSession` keeps only the last N user turns. A "turn" = one user message and everything until the next user message (assistant replies, tool calls/results). Trimming happens on both write (`add_items`) and read (`get_items`).
>
> ### Context Summarization Implementation
>
> *Diagram showing summarization session flow:*
> ![[openai-ctx-personal-002.jpg]]
>
> The `SummarizingSession` keeps the most recent N user turns intact and summarizes everything older into a synthetic user→assistant pair. Key design principles for the summarization prompt:
>
> - **Milestones:** Highlight important events (issue resolved, information uncovered)
> - **Use Case Specificity:** Tailor compression to the specific task
> - **Contradiction Check:** Ensure summary doesn't conflict with system instructions or tool definitions
> - **Timestamps & Temporal Flow:** Incorporate timing to reduce confusion
> - **Chunking:** Organize into categories rather than long paragraphs
> - **Tool Performance Insights:** Capture which tools worked and why
> - **Hallucination Control:** Even minor hallucinations in a summary propagate forward
>
> ### Evals
>
> Evals is all you need for context engineering too. Lightweight evaluation approaches:
>
> - **Baseline & Deltas:** Compare before/after experiments to measure memory improvements
> - **LLM-as-Judge:** Use a model with a grader prompt to evaluate summarization quality
> - **Transcript Replay:** Re-run long conversations and measure next-turn accuracy with and without context trimming
> - **Error Regression Tracking:** Watch for unanswered questions, dropped constraints, unnecessary/repeated tool calls
> - **Token Pressure Checks:** Flag cases where token limits force dropping protected context
>
> ### Memory Evaluation
>
> **1) Distillation Evals (Capture Quality):** Precision, recall, safety of memory writes
>
> **2) Injection Evals (Usage Quality):** Recency correctness, over-influence, token efficiency
>
> **3) Consolidation Evals (Curation Quality):** Deduplication quality, conflict resolution, non-invention
>
> **Suggested Harness Patterns:** A/B test injection strategies, synthetic user profiles with preference drift, adversarial memory poisoning attempts
>
> **Practical Metrics to Log:** memory_write_rate per 100 turns, blocked_write_rate

[Source](https://cookbook.openai.com/examples/agents_sdk/context_personalization)
