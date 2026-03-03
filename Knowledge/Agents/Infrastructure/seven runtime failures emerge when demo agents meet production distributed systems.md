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

> [!quote]- Source Material

> @ashpreetbedi (Ashpreet Bedi):
> Article: The 7 Sins of Agentic Software
>
> "Demos are easy. Production is hard" is the most recycled line in AI.
>
> After three years building agent infrastructure, here's the truth:
>
> Production is not the problem.
> Distributed systems have always been hard.
> The problem is pretending demos represent production.
>
> Demos hide the infrastructure.
> They hide state.
> They hide cost.
> They hide isolation.
> They hide the failure modes.
>
> Here are 7 failure modes that show up when demo meets production.
>
> # 1. Treating a system like a script
>
> The first sin is underestimating the scope of what you're building.
>
> Most agents start as python scripts. You run it locally, it calls a model, runs tools, and returns a response. It works. You demo it. Everyone's impressed.
>
> Then someone asks: "Can we ship this?"
>
> So you wrap it in FastAPI and write endpoints for:
>
> - Chat
>
> - Session management
>
> - Cancellation and resume
>
> - File uploads
>
> - Auth
>
> One endpoint becomes five.
> Five become fifteen.
>
> Then traffic spikes.
> Rate limits.
> 429s everywhere.
>
> Now you are building queues.
> Backpressure.
> Retries.
> Caching.
> Cost controls.
>
> Your 200-line demo just became 2,000 lines of infrastructure.
>
> Most agent builders think they are writing isolated programs.
> In reality, they are building stateful distributed systems.
>
> # 2. Forcing agents into traditional request-response
>
> The second sin is assuming traditional web semantics apply to agents.
>
> Traditional software gets a request, does some work, returns a response.
>
> Agents break that contract.
>
> Agents think, stream tool calls, spawn sub-agents, retrieve memory and change direction mid-execution.
>
> Streaming handles latency and is mostly solved.
> Start with SSE. Move to WebSockets when you need bidirectional control.
>
> But some tasks require background execution and polling.
>
> "Analyze this dataset and email me a report"
>
> This is a long-running background task. Now you need:
>
> - Background execution
>
> - Job queues
>
> - Progress tracking
>
> - Completion guarantees
>
> Add human approval and minutes become days.
>
> Agents are not request handlers. They are long-running computations that may span sessions, humans, and systems.
>
> # 3. Ignoring persistence
>
> The third sin is ignoring durability.
>
> Demo agents run fresh every time.
>
> Production agents do not.
>
> - They live across sessions.
>
> - They accumulate context.
>
> - They mutate state.
>
> - They remember.
>
> That means you must persist:
>
> - Inputs and outputs
>
> - Intermediate artifacts
>
> - State transitions
>
> - Execution traces
>
> If your agent crashes on step 12 of 15, you must know exactly where it was.
>
> You need:
>
> - Checkpoints
>
> - Replays
>
> - Resume semantics
>
> Restarting is not acceptable.
> Restarting might duplicate a side effect.
> Restarting might lose critical context.
>
> But persistence is not only about recovery. Durable state lets you:
>
> - Compress context instead of replaying the full history
>
> - Debug failures
>
> - Extract successful runs into reusable few-shot patterns
>
> - Analyze latency, token usage, and tool behavior to optimize cost
>
> Without persistence, every run starts from zero.
> With persistence, every run can become cheaper, safer, and smarter.
>
> An agent without durability is a demo.
> An agent with durability is a system.
>
> You are no longer serving responses.
> You are maintaining long-lived computation.
>
> # 4. Ignoring multi-tenancy
>
> The fourth sin is ignoring multi-tenancy.
>
> Demo agents serve one user.
> Production agents serve thousands.
>
> User A's context cannot leak into User B's experience.
>
> Passing a `user_id` is easy.
> Isolating every resource the agent touches is not:
>
> - Sessions
>
> - Memory
>
> - Knowledge
>
> - Vector search
>
> - Tool outputs
>
> - Cached artifacts
>
> Your database was not designed for multi-tenant agent workloads.
> Your vector store was not either.
> Your model provider definitely was not.
>
> So you build isolation yourself:
>
> - Namespaces
>
> - Resource scoping
>
> - RBAC
>
> - Policy enforcement
>
> One missing filter.
> One incorrect join.
>
> Now you are writing an incident report.
>
> Isolation is optional in a demo.
> It is critical in production.
>
> # 5. Confusing reasoning with execution
>
> The fifth sin is treating reasoning like execution.
>
> Not every tool call should auto-execute.
>
> "Look up a record" is fine.
> "Delete a record" is not the same decision.
> "Issue a $50 refund" might be acceptable.
> "Issue a $5,000 refund" is not.
>
> If your agent can act, it can cause damage.
>
> Your runtime must express policy:
>
> - Which actions are free?
>
> - Which require user confirmation?
>
> - Which require admin approval?
>
> When an action is blocked, the agent cannot crash. It must:
>
> Pause
> Persist state
> Wait for approval
> Resume exactly where it left off
>
> Not restart.
> Resume.
> Because restarting might issue the refund twice.
>
> Governance is not a feature.
>
> It is part of the execution model.
>
> # 6. Assuming horizontal scaling is trivial
>
> The sixth sin is assuming horizontal scaling is trivial.
>
> Agents are stateful.
>
> Cloud infrastructure assumes statelessness.
>
> Spin up more instances.
> Load balance.
> Any instance can serve any request.
>
> Those assumptions conflict.
>
> The obvious solution:
>
> Externalize all state.
> Make the app layer stateless.
> Let any instance resume any session.
>
> In theory, scaling is solved.
>
> In practice:
>
> One cached artifact in memory.
> One missing write.
> One assumption about local state.
>
> It works perfectly on one instance.
> You deploy a second.
>
> Now sessions drift.
> State disappears.
> Runs resume incorrectly.
>
> Behavior becomes unpredictable and only your users can tell.
>
> # 7. Confusing observability with trust
>
> The seventh sin is confusing visibility with safety.
>
> Agents are non-deterministic. The same input can produce different outputs depending on context, memory, and model behavior.
>
> The industry response has been observability:
>
> - Trace everything
>
> - Log everything
>
> - Run evaluations
>
> Yes, you need all of that.
> But observability is retrospective.
> It explains what happened.
> Trust constrains what is allowed to happen.
>
> That means:
>
> - Input validation before reasoning
>
> - Guardrails on every step
>
> - Output checks before responses
>
> - Confidence thresholds that halt execution
>
> - Post-response evaluations that catch drift early
>
> The agent should stop itself on a bad call.
> Not log it for someone to discover later.
>
> Observability tells you the past.
> Trust guarantees correct execution.
>
> # These are runtime problems
>
> None of these sins are solved by better prompts.
>
> Calling a model is easy.
> Executing a tool is easy.
> Returning a response is easy.
>
> Serving agents.
> Managing sessions.
> Scoping users.
> Enforcing governance.
> Externalizing state.
> Embedding trust into execution.
>
> Those are runtime problems.
> Infrastructure problems.
> Language problems.
>
> All seven sins come from one mistake:
> Treating agents like a feature instead of a new type of software.
>
> The winners in agentic software will not be the best prompt engineers.
> They will be the systems engineers.
> date: Wed Feb 25 17:20:26 +0000 2026
> url: https://x.com/ashpreetbedi/status/2026708881972535724
> likes: 407  retweets: 53  replies: 12