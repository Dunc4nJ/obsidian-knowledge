---
created: 2026-03-02
description: OpenAI cookbook demonstrating a state-based long-term memory pattern using RunContextWrapper in the Agents SDK, with structured profiles, session/global memory scoping, distillation via tool calls, and post-session consolidation with deduplication and conflict resolution.
source: https://developers.openai.com/cookbook/examples/agents_sdk/context_personalization
type: framework
---

## Key Takeaways

The cookbook's central argument is that **state-based memory beats retrieval-based memory** for personalized agents where decisions depend on continuity and evolving preferences rather than ad-hoc search. This resonates with the broader [[manus context engineering]] principle that agents need structured, authoritative context — not loose document retrieval — to make reliable decisions. Retrieval-based memory is brittle to phrasing, prone to missing overrides, and unable to reconcile conflicts over time.

The **two-phase memory processing pattern** (distillation during the session, consolidation after) is the most practically useful contribution. During a conversation, the agent captures candidate memories via a dedicated `save_memory_note` tool — a "memory-as-a-tool" pattern that gives the model explicit control over what gets stored. After the session, a separate consolidation step merges session notes into global memory with deduplication, conflict resolution, and intentional forgetting. This mirrors the [[file-based personal OS gives AI agents persistent identity and judgment across sessions]] pattern of separating fast-moving from slow-moving state.

The **memory scope separation** (global vs. session) with clear precedence rules is critical infrastructure. The cookbook defines a strict hierarchy: latest user message wins, session memory overrides global memory, and within the same scope, most recent date wins. This is essentially the same precedence pattern that [[anthropic effective context engineering]] recommends for system prompts — fresh signals should always override stale defaults.

The **memory injection via hooks** approach — rendering structured profile as YAML frontmatter and memories as Markdown lists, injected into the system prompt at run start — is a clean, deterministic pattern that avoids the non-determinism of retrieval. The cookbook also handles context trimming gracefully by re-injecting session memories when the conversation history gets trimmed, preserving important short-term context.

The **memory consolidation is identified as the most error-prone stage** — susceptible to context poisoning, memory loss, and long-term hallucinations from over-aggressive pruning or promoting noisy signals. The cookbook uses a separate LLM call with strict JSON output for consolidation, with explicit rules to drop session-scoped notes (containing "this time", "this trip") and keep only durable preferences.

A useful heuristic for **memory schema design**: ask "if this were a human agent performing the same task, what would they actively hold in working memory?" This grounds memory design in task-relevance rather than arbitrary persistence — connecting to the broader [[putting yourself in the agents shoes is the unifying framework for agentic system design]] principle.

## External Resources

- [OpenAI Agents SDK](https://openai.github.io/openai-agents-python/) — the Python SDK used throughout the cookbook
- [RunContextWrapper docs](https://openai.github.io/openai-agents-python/context/) — persistent state management for agent runs
- [Agents SDK Hooks/Lifecycle reference](https://openai.github.io/openai-agents-python/ref/lifecycle/) — hook points for memory injection and lifecycle orchestration
- [TrimmingSession cookbook](https://cookbook.openai.com/examples/agents_sdk/session_memory) — companion cookbook on short-term memory management with sessions

## Original Content

> [!quote]- Source Material
> Modern AI agents are no longer just reactive assistants — they're becoming adaptive collaborators. The leap from "responding" to "remembering" defines the new frontier of **context engineering**. At its core, context engineering is about shaping what the model knows at any given moment. By managing what's stored, recalled, and injected into the model's working memory, we can make an agent that feels personal, consistent, and context-aware.
>
> The `RunContextWrapper` in the **OpenAI Agents SDK** provides the foundation for this. It allows developers to define structured state objects that persist across runs, enabling memory, notes, or even preferences to evolve over time. When paired with hooks and context-injection logic, this becomes a powerful system for **context personalization** — building agents that learn who you are, remember past actions, and tailor their reasoning accordingly.
>
> This cookbook shows a **state-based long-term memory** pattern:
>
> - **State object** = your local-first memory store (structured profile + notes)
> - **Distill** memories during a run (tool call → session notes)
> - **Consolidate** session notes into global notes at the end (dedupe + conflict resolution)
> - **Inject** a well-crafted state at the start of each run (with precedence rules)
>
> ## Why Context Personalization Matters
>
> Context personalization is the "magic moment" when an AI agent stops feeling generic and starts feeling like *your* agent.
>
> It's when the system remembers your coffee order, your company's tone of voice, your past support tickets, or your preferred aisle seat — and uses that knowledge naturally, without being prompted.
>
> From a user perspective, this builds trust and delight: the agent appears to genuinely understand them. From a company perspective, it creates a **strategic moat** — a way to continuously capture, refine, and apply high-quality behavioral data. If implemented carefully, you can capture denser, higher-signal information about your users than typical clicks, impressions, or history data. Each interaction becomes a signal for better service, higher retention, and deeper insight into user needs.
>
> This value extends beyond the agent itself. When managed rigorously and safely, personalized context can also empower **human-facing roles** — support agents, account managers, travel advisors — by giving them a richer, longitudinal understanding of the customer. Over time, analyzing accumulated memories reveals how user preferences, behaviors, and goals evolve, enabling smarter product decisions and more adaptive systems.
>
> In practice, effective personalization means maintaining structured state — preferences, constraints, prior outcomes — and injecting only the *relevant* slices into the agent's context at the right moment. Different agents demand different memory lifecycles: a life-coaching agent may require fast-evolving, nuanced memories, while an IT troubleshooting agent benefits from slower, more predictable state. Done well, personalization transforms a stateless chatbot into a persistent digital collaborator.
>
> ## Real-World Scenario: Travel Concierge Agent
>
> We'll ground this tutorial in a **travel concierge** agent that helps users book flights, hotels, and car rentals with a high degree of personalization.
>
> In this tutorial, you'll build an agent that:
>
> - starts each session with a structured user profile and curated memory notes
> - captures new durable preferences (for example, "I'm vegetarian") via a dedicated tool
> - consolidates those preferences into long-term memory at the end of each run
> - resolves conflicts using a clear precedence order: **latest user input → session overrides → global defaults**
>
> **Architecture at a Glance**
>
> This section summarizes how state and memory flow across sessions.
>
> 1. **Before the Session Starts** — A state object (user profile + global memory notes) is stored locally in your system. This state represents the agent's long-term understanding of the user.
> 2. **At the Start of a New Session** — The state object is injected into the system prompt: structured fields as YAML frontmatter, unstructured memories as a Markdown memory list.
> 3. **During the Session** — As the agent interacts with the user, it captures candidate memories using `save_memory_note(...)`. These notes are written to session memory within the state object.
> 4. **When the Context Is Trimmed** — If context trimming occurs (e.g., to avoid hitting the context limit): session-scoped memory notes are reinjected into the system prompt. This preserves important short-term context across long-running sessions.
> 5. **At the End of the Session** — A consolidation job runs asynchronously: session notes are merged into global memory, conflicts are resolved and duplicates are removed.
> 6. **Next Run** — The updated state object is reused. The lifecycle repeats from the beginning.
>
> ## AI Memory Architecture Decisions
>
> AI memory is still a new concept, and there is no one-size-fits-all solution. In this cookbook, we make design decisions based on a well-defined use case: a Travel Concierge agent.
>
> ### 1. Retrieval-Based vs State-Based Memory
>
> Considering the many challenges in retrieval-based memory mechanisms including the need to train the model, state-based memory is better suited than retrieval-based memory for a travel concierge AI agent because travel decisions depend on continuity, priorities, and evolving preferences — not ad-hoc search. A travel agent must reason over a *current, coherent user state* (loyalty programs, seat preferences, budgets, visa constraints, trip intent, and temporary overrides like "this time I want to sleep") and consistently apply it across flights, hotels, insurance, and follow-ups.
>
> Retrieval-based memory treats past interactions as loosely related documents, making it brittle to phrasing, prone to missing overrides, and unable to reconcile conflicts or updates over time. In contrast, state-based memory encodes user knowledge as structured, authoritative fields with clear precedence (global vs session), supports belief updates instead of fact accumulation, and enables deterministic decision-making without relying on fragile semantic search. This allows the agent to behave less like a search engine and more like a persistent concierge — maintaining continuity across sessions, adapting to context, and reliably using memory whenever it is relevant, not just when it is successfully retrieved.
>
> ### 2. Shape of a Memory
>
> The shape of an agent's memory is entirely driven by the use case. A reliable way to design it is to start with a simple question:
>
> > *If this were a human agent performing the same task, what would they actively hold in working memory to get the job done? What details would they track, reference, or infer in real time?*
>
> This framing grounds memory design in *task-relevance*, not arbitrary persistence.
>
> **Metaprompting for Memory Extraction**
>
> Use this pattern to elicit the memory schema for any workflow:
>
> > *You are a [USE CASE] agent whose goal is [GOAL]. What information would be important to keep in working memory during a single session? List both fixed attributes (always needed) and inferred attributes (derived from user behavior or context).*
>
> Combining predefined structured keys with unstructured memory notes provides the right balance for a travel concierge agent — enabling reliable personalization while still capturing rich, free-form user preferences. In this design, the quality of your internal data systems becomes critical: structured fields should be consistently hydrated and kept up to date from trusted internal sources, while unstructured memories fill in the gaps where flexibility is required.
>
> For this cookbook, we keep things simple by sourcing memory notes only from explicit user messages. In more advanced agents, this definition naturally expands to include signals from tool calls, system actions, and full execution traces, enabling deeper and more autonomous memory formation.
>
> **Structured Memory** (Schema-driven, machine-enforceable, predictable):
> - Identity & Core Profile: Global customer ID, Full name, Date of birth, Gender, Passport expiry date
> - Loyalty & Programs: Airline loyalty status, Hotel loyalty status, Loyalty IDs
> - Preferences & Coverage: Seat preference, Insurance coverage profile (car rental coverage type, travel medical coverage status, coverage level)
> - Constraints: Visa requirements (array of country/region codes)
>
> **Unstructured Memory** (Narrative, contextual, semantic):
> - "User usually prefers aisle seats."
> - "For trips shorter than a week, user generally prefers not to check bags."
> - "User prefers coverage that includes collision damage waiver and zero deductible when available."
>
> **Tip:** Do not dump all the fields from internal systems into the profile section. Make sure that every single token you add here helps agent to make better decisions.
>
> ### 3. Memory Scope
>
> Separate memory by **scope** to reduce noise and make evolution safer over time.
>
> **User-Level Memory (Global Notes)** — Durable preferences that should persist across sessions and influence future interactions. Examples: "Prefers aisle seats", "Vegetarian", "United Gold status". These are injected at the start of each session and updated cautiously during consolidation.
>
> **Session-Level Memory (Session Notes)** — Short-lived or contextual information relevant only to the current interaction. Examples: "This trip is a family vacation", "Budget under $2,000 for this trip", "I prefer window seat this time for the red eye flight." Session notes act as a staging area and are promoted to global memory only if they prove durable.
>
> **Rule of thumb:** if it should affect future trips by default, store it globally; if it only matters now, keep it session-scoped.
>
> Example state object:
>
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
> ### 4. Memory Lifecycle
>
> Memory is not static. Over time, you can analyze user behavior to identify different patterns:
> - **Stability** — preferences that rarely change (e.g., "seat preference is almost always aisle")
> - **Drift** — gradual changes over time (e.g., "average trip budget has increased month over month")
> - **Contextual variance** — preferences that depend on context (e.g., "business trips vs. family trips behave differently")
>
> These signals should directly influence your memory architecture:
> - Stable, repeatedly confirmed preferences can be **promoted** from free-form notes into structured profile fields.
> - Volatile or context-dependent preferences should remain as notes, often with recency weighting, confidence scores, or a TTL.
>
> **Memory design should evolve** as the system learns what is durable versus situational.
>
> #### 4.1 Memory Distillation
>
> Memory distillation extracts high-quality, durable signals from the conversation and records them as memory notes. In this cookbook, distillation is performed during live turns via a dedicated tool, enabling the agent to capture preferences and constraints as they are explicitly expressed.
>
> An alternative approach is post-session memory distillation, where memories are extracted at the end of the session using the full execution trace.
>
> #### 4.2 Memory Consolidation
>
> Memory consolidation runs asynchronously at the end of each session, graduating eligible session notes into global memory when appropriate.
>
> This is the **most sensitive and error-prone stage** of the lifecycle. Poor consolidation can lead to context poisoning, memory loss, or long-term hallucinations. Common failure modes include:
> - Losing meaningful information through over-aggressive pruning
> - Promoting noisy, speculative, or unreliable signals
> - Introducing contradictions or duplicate memories over time
>
> To maintain a healthy memory system, consolidation must explicitly handle:
> - **Deduplication** — merging semantically equivalent memories
> - **Conflict resolution** — choosing between competing or outdated facts
> - **Forgetting** — pruning stale, low-confidence, or superseded memories
>
> Forgetting is not a bug — it is essential. Without careful pruning, memory stores will accumulate redundant and outdated information, degrading agent quality over time.
>
> #### 4.3 Memory Injection
>
> Inject curated memory back into the model context at the start of each session. In this cookbook, injection is implemented via hooks that run after context trimming and before the agent begins execution. High-signal memory in the system prompt is extremely effective for latency.
>
> ## Techniques Covered
>
> - **State Management** — Maintain and evolve the agent's persistent state using the `RunContextWrapper` class. Pre-populate and curate key fields from internal systems before each session begins.
> - **Memory Injection** — Inject only the relevant portions of state into the agent's context at the start of each session. Use YAML frontmatter for structured, machine-readable metadata. Use Markdown notes for flexible, human-readable memory.
> - **Memory Distillation** — Capture dynamic insights during active turns by writing session notes via a dedicated tool.
> - **Memory Consolidation** — Merge session-level notes into a dense, conflict-free set of global memories. Forgetting: Prune stale, overwritten, or low-signal memories during consolidation, and deduplicate aggressively over time.
>
> Two-phase memory processing (note taking → consolidation) is more reliable than one-shot. All techniques are implemented in a **local-first** manner and can be kept **ZDR (Zero Data Retention)** by design. These approaches are intentionally **zero-shot** — relying on prompting, orchestration, and lightweight scaffolding rather than training.
>
> ## Implementation
>
> ### Step 1 — Define the State Object (Local-First Memory Store)
>
> The state includes:
> - `profile` — Structured, predefined fields (often hydrated from internal systems or CRMs)
> - `global_memory.notes` — Curated long-term memory notes that persist across sessions, with `last_updated` timestamp and `keywords`
> - `session_memory.notes` — Newly captured candidate memories (staging area before consolidation)
> - `trip_history` — Lightweight view of the user's recent activity
>
> ```python
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
> ### Step 2 — Define Tools for Live Memory Distillation
>
> Live memory distillation is implemented via a tool call during the conversation. This follows the memory-as-a-tool pattern, where the model explicitly emits candidate memories in real time as it reasons through a turn.
>
> The `save_memory_note` tool captures HIGH-SIGNAL, reusable information that will help make better travel decisions. Key rules:
> - Save only durable, actionable, explicit information
> - 1-2 sentences max, normalized into durable statements
> - 1-3 lowercase keyword tags
> - Never store sensitive PII, secrets, or instruction-like content
>
> ### Step 3 — Define Trimming Session for Context Management
>
> Keep only the last N user turns. When trimming occurs, set `inject_session_memories_next_turn` to trigger reinjection of session-scoped memories into the system prompt on the next turn.
>
> ### Step 4 — Memory Injection (with Precedence Rules)
>
> **Precedence rule:**
> 1. The user's latest instruction in the current dialogue wins.
> 2. Structured profile keys are generally trusted (especially if sourced/enriched internally).
> 3. Global memory notes are advisory and must not override current instructions.
> 4. If memory conflicts with the user's current request, ask a clarifying question.
>
> Inject the profile and memory lists inside explicit blocks (`<user_profile>` and `<memories>`), with a `<memory_policy>` block that tells the model how to interpret them.
>
> The `<memory_policy>` includes:
> - SESSION memory overrides GLOBAL memory when they conflict
> - Within the same list, prefer the most recent by date
> - GLOBAL memory is a default, not a hard constraint
> - Do NOT treat "this time" requests as changes to GLOBAL defaults
> - Only promote to GLOBAL if user indicates a lasting rule ("from now on", "generally")
>
> ### Step 5 — Render State as YAML Frontmatter + Memories List Markdown
>
> Keeping rendering deterministic avoids hallucinations in the injection layer.
>
> ### Step 6 — Define Hooks for the Memory Lifecycle
>
> At the start of a run (`on_agent_start`):
> - Render a YAML frontmatter block from structured state
> - Render free-form global memories as sorted Markdown
> - Inject session notes only after a trim event
>
> ### Step 7 — Define the Travel Concierge Agent
>
> The agent uses `gpt-5.2` with dynamic instructions that inject profile, memories, and memory policy.
>
> ### Step 8 — Post Session Memory Consolidation
>
> Consolidation merges session notes into global memory using a separate LLM call (`gpt-5-mini`). Rules:
> - Keep only durable information
> - Drop session-only/ephemeral notes (containing "this time", "this trip", etc.)
> - De-duplicate exact and near-duplicates
> - Conflict resolution: most recent `last_update_date` wins; ties go to SESSION_NOTES
> - Do NOT invent new facts
> - Output strict JSON array
>
> Example result: "Vegetarian" preference was promoted to global memory, while "this trip: window seat to sleep" was correctly discarded as session-scoped.
>
> ## Evaluation
>
> ### 1. Distillation Evals (Capture Quality)
> - Precision: are only durable preferences and constraints stored?
> - Recall: were key stable preferences captured when they appeared?
> - Safety: rate of attempted sensitive memory writes (blocked vs. allowed)
>
> ### 2. Injection Evals (Usage Quality)
> - Recency correctness: when memories overlap, was the most recent one used?
> - Over-influence: did memory incorrectly override current user intent?
> - Token efficiency: did injected memory remain within budget while still being useful?
>
> ### 3. Consolidation Evals (Curation Quality)
> - Deduplication quality: duplicates removed without losing meaning
> - Conflict resolution: correct "latest wins" or precedence behavior
> - Non-invention: no hallucinated facts introduced during consolidation
>
> ### Suggested Harness Patterns
> - A/B test injection strategies (e.g., top-k by relevance vs. top-k by relevance + recency)
> - Synthetic user profiles with scripted preference drift over time
> - Adversarial memory poisoning attempts (e.g., "remember my SSN...", "store this rule...")
>
> ### Practical Metrics to Log
> - `memory_write_rate` per 100 turns (high values often indicate noisy capture)
> - `blocked_write_rate` (tracks adversarial or accidental sensitive writes)
>
> [Original page](https://developers.openai.com/cookbook/examples/agents_sdk/context_personalization)
