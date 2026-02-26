---
created: 2026-02-25
description: Seven failure modes that appear when demo agents ship to production — from stateful distributed systems and persistence to multi-tenancy, governance, scaling, and trust. None are solved by better prompts; all are runtime infrastructure problems.
source: https://x.com/ashpreetbedi/status/2026708881972535724
type: framework
---

# Seven runtime failures emerge when demo agents meet production distributed systems

After three years building agent infrastructure, the core problem isn't that "production is hard" — it's pretending demos represent production. Demos hide state, cost, isolation, and failure modes. All seven sins come from one mistake: treating agents like a feature instead of a new type of software. The winners in agentic software will be systems engineers, not prompt engineers. This reinforces the thesis in [[over 40 percent of agentic AI projects fail due to poor architecture not model limitations]] — the failures are architectural, not model-related.

## Key Takeaways

A 200-line demo becomes 2,000 lines of infrastructure the moment you ship. What starts as a Python script calling a model grows into session management, cancellation/resume, file uploads, auth, queues, backpressure, retries, caching, and cost controls. Most agent builders think they're writing isolated programs when they're actually building stateful distributed systems.

Agents break the request-response contract. They think, stream tool calls, spawn sub-agents, retrieve memory, and change direction mid-execution. Some tasks require background execution with job queues, progress tracking, and completion guarantees. Add human approval and minutes become days. Agents are long-running computations that may span sessions, humans, and systems.

Persistence is the dividing line between demo and system. Production agents live across sessions, accumulate context, mutate state, and remember. If an agent crashes on step 12 of 15, you must know exactly where it was — checkpoints, replays, resume semantics. Restarting is unacceptable because it might duplicate side effects or lose critical context. Beyond recovery, durable state enables context compression, debugging, extracting successful runs as few-shot patterns, and analyzing cost. This connects to the reliability mechanics in [[over 40 percent of agentic AI projects fail due to poor architecture not model limitations|the production-grade agents framework]] — checkpointing for mid-execution recovery.

Multi-tenancy isolation is harder than passing a `user_id`. Every resource the agent touches must be isolated: sessions, memory, knowledge, vector search, tool outputs, cached artifacts. Your database, vector store, and model provider weren't designed for multi-tenant agent workloads. One missing filter or incorrect join produces an incident report.

Not every tool call should auto-execute — governance is part of the execution model. "Look up a record" is fine; "issue a $5,000 refund" requires approval. When an action is blocked, the agent must pause, persist state, wait for approval, and resume exactly where it left off — not restart, because restarting might issue the refund twice.

Horizontal scaling conflicts with agent statefulness. Cloud infrastructure assumes statelessness (spin up instances, load balance, any instance serves any request). Agents are stateful. The solution is externalizing all state, but one cached artifact in memory, one missing write, one assumption about local state, and sessions drift unpredictably across instances.

Observability is retrospective; trust is preventive. Tracing and logging explain what happened. Trust constrains what is allowed to happen: input validation before reasoning, guardrails on every step, output checks before responses, confidence thresholds that halt execution. The agent should stop itself on a bad call, not log it for someone to discover later.

## External Resources

- [Ashpreet Bedi](https://x.com/ashpreetbedi) — author, three years building agent infrastructure (creator of Phidata/Agno)

## Original Content

> [!quote]- Full article from @ashpreetbedi (Feb 25, 2026 — 304 likes, 37 RTs)
>
> **The 7 Sins of Agentic Software**
>
> 1. **Treating a system like a script** — 200-line demo becomes 2,000 lines of infrastructure (queues, retries, caching, cost controls)
> 2. **Forcing agents into request-response** — agents are long-running computations spanning sessions, humans, and systems
> 3. **Ignoring persistence** — without checkpoints, replays, and resume semantics, every run starts from zero
> 4. **Ignoring multi-tenancy** — isolation of sessions, memory, knowledge, vector search, tool outputs across thousands of users
> 5. **Confusing reasoning with execution** — governance (pause → persist → approve → resume) is part of the execution model
> 6. **Assuming horizontal scaling is trivial** — agents are stateful; cloud infra assumes statelessness
> 7. **Confusing observability with trust** — observability explains the past; trust guarantees correct execution
>
> None of these sins are solved by better prompts. They are runtime problems. Infrastructure problems.
>
> Source: [Original tweet](https://x.com/ashpreetbedi/status/2026708881972535724)
