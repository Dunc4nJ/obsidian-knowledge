---
created: 2026-03-02
description: OpenAI's Agents SDK cookbook demonstrates two session memory strategies — trimming (drop older turns) and compression (summarize history) — for managing context in long-running multi-turn agent conversations.
source: https://cookbook.openai.com/examples/agents_sdk/session_memory
type: framework
---

## Key Takeaways

OpenAI frames short-term memory management as a choice between two concrete strategies with clear tradeoffs. Trimming is deterministic and zero-latency — you drop older turns and keep the last N — but creates "amnesia" for earlier constraints. Compression uses a secondary model call to summarize older history into a clean state, preserving long-range memory but introducing the risk of "context poisoning" where bad facts persist in summaries. This maps directly to the tradeoffs identified in [[context engineering is what separates toy agents from production systems|the broader context engineering literature]].

The cookbook grounds these strategies in the `Session` object from the OpenAI Agents SDK, which handles context length, history continuity, and memory management automatically. This is a framework-level contribution rather than a research insight — it gives developers a concrete implementation of patterns that [[anthropic effective context engineering|Anthropic]] and [[manus-context-engineering|Manus]] describe more theoretically. The Session abstraction sits between raw API calls and fully autonomous memory, letting developers choose trimming vs compression per use case.

A particularly useful framing is that summaries act as "clean rooms" that can correct prior mistakes — compression isn't just about saving tokens, it's about error correction. This contrasts with [[manus-context-engineering|Manus's approach]] of preserving errors in context for implicit belief updating. Both strategies work, but for different reasons: Manus wants the model to learn from failures, while OpenAI's compression lets you escape from them.

## External Resources

- [OpenAI Agents SDK - Session Memory](https://github.com/openai/openai-agents-python) — Python SDK with Session object for context management
- [OpenAI Responses API](https://platform.openai.com/docs/api-reference/responses/create) — Built-in basic memory support through message chaining

## Original Content

> [!quote]- Source Material
> **Context Engineering - Short-Term Memory Management with Sessions from OpenAI Agents SDK**
> By Emre Okcular
>
> AI agents often operate in long-running, multi-turn interactions, where keeping the right balance of context is critical. If too much is carried forward, the model risks distraction, inefficiency, or outright failure. If too little is preserved, the agent loses coherence.
>
> Here, context refers to the total window of tokens (input + output) that the model can attend to at once. For GPT-5, this capacity is up to 272k input tokens and 128k output tokens but even such a large window can be overwhelmed by uncurated histories, redundant tool results, or noisy retrievals. This makes context management not just an optimization, but a necessity.
>
> In this cookbook, we explore how to manage context effectively using the Session object from the OpenAI Agents SDK, focusing on two proven context management techniques — trimming and compression — to keep agents fast, reliable, and cost-efficient.
>
> **Why Context Management Matters:**
> - Sustained coherence across long threads
> - Higher tool-call accuracy
> - Lower latency and cost
> - Error and hallucination containment
> - Easier debugging and observability
> - Multi-issue and handoff resilience
>
> **Techniques Covered:**
>
> **Context Trimming** — dropping older turns while keeping the last N turns.
> - Pros: Deterministic and simple, zero added latency, fidelity for recent work, lower risk of "summary drift"
> - Cons: Forgets long-range context abruptly, user experience "amnesia", wasted signal, token spikes still possible
> - Best when: Tasks are independent with non-overlapping context, you need predictability and low latency
>
> **Context Summarization** — compressing prior messages into structured, shorter summaries injected into history.
> - Pros: Retains long-range memory compactly, smoother UX, cost-controlled scale, searchable anchor
> - Cons: Summarization loss and bias, latency and cost spikes, compounding errors, observability complexity
> - Best when: Tasks need context collected across the flow, sessions exceed N turns but must preserve decisions
>
> | Dimension | Trimming (last-N turns) | Summarizing (older → generated summary) |
> |---|---|---|
> | Latency / Cost | Lowest (no extra calls) | Higher at summary refresh points |
> | Long-range recall | Weak (hard cut-off) | Strong (compact carry-forward) |
> | Risk type | Context loss | Context distortion/poisoning |
> | Observability | Simple logs | Must log summary prompts/outputs |
> | Eval stability | High | Needs robust summary evals |
> | Best for | Tool-heavy ops, short workflows | Analyst/concierge, long threads |
>
> [Original cookbook](https://cookbook.openai.com/examples/agents_sdk/session_memory)
