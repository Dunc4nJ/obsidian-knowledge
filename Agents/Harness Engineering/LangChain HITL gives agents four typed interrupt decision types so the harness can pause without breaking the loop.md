---
created: 2026-04-29
description: LangChain's HumanInTheLoopMiddleware exposes four typed interrupt decisions — approve, edit, reject, respond — that humans can return when an agent's tool call is paused, encoding the full contract for human-mediated tool execution on top of LangGraph's checkpoint/resume primitive.
source: https://docs.langchain.com/oss/python/langchain/human-in-the-loop#interrupt-decision-types
original_title: "Human-in-the-loop"
type: framework
---

## Key Takeaways

- **The HITL middleware compresses every possible human response into four typed decisions: `approve`, `edit`, `reject`, and `respond`.** This is the consumer-facing contract on top of the durable-checkpoint primitive that [[LangChain Deep Agents runtime builds ten production capabilities on one primitive - durable super-step checkpointing to PostgreSQL]] describes — that note explains *how* HITL pause/resume survives crashes via Postgres-backed super-steps; this page documents *what* a human can actually do once execution is paused. Together they specify the full HITL stack: durable interrupt → typed decision → resumed execution.

- **The four-type taxonomy is asymmetric on purpose, separating "what should happen to this tool call" from "what should the agent observe."** `approve` runs the call as-is, `edit` runs a modified call (new name and/or args), `reject` skips execution and feeds an explanation back into the conversation as feedback, and `respond` skips execution and returns the human's message *as the tool result itself* — purpose-built for "ask user" tools where the human IS the implementation. The respond/reject distinction is the load-bearing one: rejection trains the agent ("don't do that"), respond satisfies the contract the agent thought it was making.

- **HITL is a specific instance of the more general middleware pattern documented in [[agent middleware hooks decouple business logic from the core agent loop enabling composable customization]].** That note's `after_model` hook is exactly where this middleware lives — it inspects the model's proposed tool calls, decides which need human review based on the configured policy, and calls `interrupt()` before any execution. The HITL middleware is therefore the canonical demonstration of why middleware-as-API matters: human review is policy that should sit *outside* the prompt, configurable per-tool, with a well-typed resume contract.

- **Per-tool decision allowlisting (`allowed_decisions`) is the safety primitive most production agents will actually need.** The example in the docs allows `approve` and `reject` for `execute_sql` but forbids `edit` — a deliberate choice because letting reviewers freely edit SQL queries opens an attack surface (a reviewer who pastes a destructive query slips past the safety check the policy was supposed to enforce). The right framing: `allowed_decisions` lets you grant a reviewer just enough authority to be useful and no more, and the typed contract makes that grant auditable. This connects to [[Memory ownership follows harness ownership - Harrison Chase argues picking a closed harness is picking a permanent owner for your agent's data flywheel]] — when your harness owns the typed HITL contract, your audit trail of approvals/edits/rejections lives with you, not behind a vendor API.

- **The docs flag a non-obvious failure mode: editing tool arguments aggressively can cause the model to re-evaluate its plan and re-execute tools.** When the agent sees a tool call return based on substantially different arguments than it requested, downstream model turns can decide "that didn't accomplish what I wanted, let me try again." The fix is conservative edits — change a recipient, not a query intent. This is the same brittleness covered by [[training beats prompting so use runtime guards not instructions]]: human-edited tool calls are a guardrail layer, but they leak into model behavior because the agent observes the edited arg, not the original.

- **The middleware *requires* a checkpointer; without one it cannot exist.** This is the architectural tell that ties HITL to [[LangChain Deep Agents Deploy offers open harness to avoid Claude Managed Agents memory lock-in]] — the open-harness bet only pays off if the checkpoint format is portable. If the harness exists but the checkpoints encoding paused HITL state live behind a managed API (or are encrypted opaquely, as the Chase post argues Codex compaction summaries are), then the agent can technically pause for review but cannot migrate mid-conversation. Owning the harness without owning the checkpoint is a half-stack.

## External Resources

- [LangChain HITL middleware reference](https://docs.langchain.com/oss/python/langchain/middleware/built-in#human-in-the-loop) — config schema for `HumanInTheLoopMiddleware`
- [LangGraph `interrupt()` primitive](https://reference.langchain.com/python/langgraph/types/interrupt) — the underlying pause primitive HITL middleware wraps
- [LangGraph persistence layer](https://docs.langchain.com/oss/python/langgraph/persistence) — required for HITL; enables stop/resume across process boundaries
- [LangGraph interrupts guide](https://docs.langchain.com/oss/python/langgraph/interrupts) — broader patterns for using `interrupt()` and `Command(resume=...)`
- [`AsyncPostgresSaver` reference](https://reference.langchain.com/python/langgraph/checkpoints/#langgraph.checkpoint.postgres.aio.AsyncPostgresSaver) — production checkpointer
- [`InMemorySaver` reference](https://reference.langchain.com/python/langgraph/checkpoints/#langgraph.checkpoint.memory.InMemorySaver) — testing/prototyping checkpointer
- [Streaming guide](https://docs.langchain.com/oss/python/langchain/streaming) — how `stream()` interacts with HITL interrupts
- [Edit this page on GitHub](https://github.com/langchain-ai/docs/edit/main/src/oss/langchain/human-in-the-loop.mdx) — source of this docs page

## Original Content

> [!quote]- Source Material — LangChain HITL docs (full page)
>
> # Human-in-the-loop
>
> The Human-in-the-Loop (HITL) middleware lets you add human oversight to agent tool calls.
> When a model proposes an action that might require review—for example, writing to a file or executing SQL—the middleware can pause execution and wait for a decision.
>
> It does this by checking each tool call against a configurable policy. If intervention is needed, the middleware issues an interrupt that halts execution. The graph state is saved using LangGraph's persistence layer, so execution can pause safely and resume later.
>
> A human decision then determines what happens next: the action can be approved as-is (`approve`), modified before running (`edit`), rejected with feedback (`reject`), or responded to directly (`respond`) for "ask user" style tools.
>
> ## Interrupt decision types
>
> The middleware defines four built-in ways a human can respond to an interrupt:
>
> | Decision Type | Description                                                               | Example Use Case                                    |
> | ------------- | ------------------------------------------------------------------------- | --------------------------------------------------- |
> | ✅ `approve`   | The action is approved as-is and executed without changes.                | Send an email draft exactly as written              |
> | ✏️ `edit`     | The tool call is executed with modifications.                             | Change the recipient before sending an email        |
> | ❌ `reject`    | The tool call is rejected, with an explanation added to the conversation. | Reject an email draft and explain how to rewrite it |
> | 💬 `respond`  | Tool execution is skipped; the human's message becomes the tool result.   | Answer an "ask_user" prompt with a direct reply     |
>
> The available decision types for each tool depend on the policy you configure in `interrupt_on`.
> When multiple tool calls are paused at the same time, each action requires a separate decision.
> Decisions must be provided in the same order as the actions appear in the interrupt request.
>
> > **Tip:** When **editing** tool arguments, make changes conservatively. Significant modifications to the original arguments may cause the model to re-evaluate its approach and potentially execute the tool multiple times or take unexpected actions.
>
> ## Configuring interrupts
>
> To use HITL, add the middleware to the agent's `middleware` list when creating the agent.
>
> You configure it with a mapping of tool actions to the decision types that are allowed for each action. The middleware will interrupt execution when a tool call matches an action in the mapping.
>
> ```python
> from langchain.agents import create_agent
> from langchain.agents.middleware import HumanInTheLoopMiddleware
> from langgraph.checkpoint.memory import InMemorySaver
>
>
> agent = create_agent(
>     model="gpt-5.4",
>     tools=[write_file, execute_sql, read_data],
>     middleware=[
>         HumanInTheLoopMiddleware(
>             interrupt_on={
>                 "write_file": True,  # All decisions (approve, edit, reject, respond) allowed
>                 "execute_sql": {"allowed_decisions": ["approve", "reject"]},  # No editing allowed
>                 "read_data": False, # Safe operation, no approval needed
>             },
>             # Prefix for interrupt messages - combined with tool name and args to form the full message
>             # e.g., "Tool execution pending approval: execute_sql with query='DELETE FROM...'"
>             # Individual tools can override this by specifying a "description" in their interrupt config
>             description_prefix="Tool execution pending approval",
>         ),
>     ],
>     # Human-in-the-loop requires checkpointing to handle interrupts.
>     # In production, use a persistent checkpointer like AsyncPostgresSaver.
>     checkpointer=InMemorySaver(),
> )
> ```
>
> > **Info:** You must configure a checkpointer to persist the graph state across interrupts.
> > In production, use a persistent checkpointer like `AsyncPostgresSaver`. For testing or prototyping, use `InMemorySaver`.
> >
> > When invoking the agent, pass a `config` that includes the **thread ID** to associate execution with a conversation thread.
> > See the LangGraph interrupts documentation for details.
>
> **Configuration options:**
>
> - `interrupt_on` (dict, required) — Mapping of tool names to approval configs. Values can be `True` (interrupt with default config), `False` (auto-approve), or an `InterruptOnConfig` object.
> - `description_prefix` (string, default "Tool execution requires approval") — Prefix for action request descriptions
>
> **`InterruptOnConfig` options:**
>
> - `allowed_decisions` (list[string]) — List of allowed decisions: `'approve'`, `'edit'`, `'reject'`, or `'respond'`
> - `description` (string | callable) — Static string or callable function for custom description
>
> ## Responding to interrupts
>
> When you invoke the agent, it runs until it either completes or an interrupt is raised. An interrupt is triggered when a tool call matches the policy you configured in `interrupt_on`. With `version="v2"`, the result is a `GraphOutput` with an `interrupts` attribute containing the actions that require review. You can then present those actions to a reviewer and resume execution once decisions are provided.
>
> ```python
> from langgraph.types import Command
>
> # Human-in-the-loop leverages LangGraph's persistence layer.
> # You must provide a thread ID to associate the execution with a conversation thread,
> # so the conversation can be paused and resumed (as is needed for human review).
> config = {"configurable": {"thread_id": "some_id"}}
> # Run the graph until the interrupt is hit.
> result = agent.invoke(
>     {
>         "messages": [
>             {
>                 "role": "user",
>                 "content": "Delete old records from the database",
>             }
>         ]
>     },
>     config=config,
>     version="v2",
> )
>
> # result is a GraphOutput with .value and .interrupts
> print(result.interrupts)
> # > (
> # >    Interrupt(
> # >       value={
> # >          'action_requests': [
> # >             {
> # >                'name': 'execute_sql',
> # >                'arguments': {'query': 'DELETE FROM records WHERE created_at < NOW() - INTERVAL \'30 days\';'},
> # >                'description': 'Tool execution pending approval\n\nTool: execute_sql\nArgs: {...}'
> # >             }
> # >          ],
> # >          'review_configs': [
> # >             {
> # >                'action_name': 'execute_sql',
> # >                'allowed_decisions': ['approve', 'reject']
> # >             }
> # >          ]
> # >       }
> # >    ),
> # > )
>
>
> # Resume with approval decision
> agent.invoke(
>     Command(
>         resume={"decisions": [{"type": "approve"}]}  # or "reject"
>     ),
>     config=config, # Same thread ID to resume the paused conversation
>     version="v2",
> )
> ```
>
> ### Decision types
>
> **✅ approve**
>
> Use `approve` to approve the tool call as-is and execute it without changes.
>
> ```python
> agent.invoke(
>     Command(
>         # Decisions are provided as a list, one per action under review.
>         # The order of decisions must match the order of actions
>         # in the interrupt request.
>         resume={
>             "decisions": [
>                 {
>                     "type": "approve",
>                 }
>             ]
>         }
>     ),
>     config=config,  # Same thread ID to resume the paused conversation
>     version="v2",
> )
> ```
>
> **✏️ edit**
>
> Use `edit` to modify the tool call before execution.
> Provide the edited action with the new tool name and arguments.
>
> ```python
> agent.invoke(
>     Command(
>         # Decisions are provided as a list, one per action under review.
>         # The order of decisions must match the order of actions
>         # in the interrupt request.
>         resume={
>             "decisions": [
>                 {
>                     "type": "edit",
>                     # Edited action with tool name and args
>                     "edited_action": {
>                         # Tool name to call.
>                         # Will usually be the same as the original action.
>                         "name": "new_tool_name",
>                         # Arguments to pass to the tool.
>                         "args": {"key1": "new_value", "key2": "original_value"},
>                     }
>                 }
>             ]
>         }
>     ),
>     config=config,  # Same thread ID to resume the paused conversation
>     version="v2",
> )
> ```
>
> > **Tip:** When **editing** tool arguments, make changes conservatively. Significant modifications to the original arguments may cause the model to re-evaluate its approach and potentially execute the tool multiple times or take unexpected actions.
>
> **❌ reject**
>
> Use `reject` to reject the tool call and provide feedback instead of execution.
>
> ```python
> agent.invoke(
>     Command(
>         # Decisions are provided as a list, one per action under review.
>         # The order of decisions must match the order of actions
>         # in the interrupt request.
>         resume={
>             "decisions": [
>                 {
>                     "type": "reject",
>                     # An explanation about why the action was rejected
>                     "message": "No, this is wrong because ..., instead do this ...",
>                 }
>             ]
>         }
>     ),
>     config=config,  # Same thread ID to resume the paused conversation
>     version="v2",
> )
> ```
>
> The `message` is added to the conversation as feedback to help the agent understand why the action was rejected and what it should do instead.
>
> ---
>
> ### Multiple decisions
>
> When multiple actions are under review, provide a decision for each action in the same order as they appear in the interrupt:
>
> ```python
> {
>     "decisions": [
>         {"type": "approve"},
>         {
>             "type": "edit",
>             "edited_action": {
>                 "name": "tool_name",
>                 "args": {"param": "new_value"}
>             }
>         },
>         {
>             "type": "reject",
>             "message": "This action is not allowed"
>         }
>     ]
> }
> ```
>
> **💬 respond**
>
> Use `respond` for "ask user" style tools where the tool's real implementation is the human's reply. The `message` content is returned directly as the tool result; the tool itself is not executed.
>
> ```python
> agent.invoke(
>     Command(
>         # Decisions are provided as a list, one per action under review.
>         # The order of decisions must match the order of actions
>         # in the interrupt request.
>         resume={
>             "decisions": [
>                 {
>                     "type": "respond",
>                     # The human's reply, returned directly as the tool result
>                     "message": "Blue.",
>                 }
>             ]
>         }
>     ),
>     config=config,  # Same thread ID to resume the paused conversation
>     version="v2",
> )
> ```
>
> The `message` is returned to the agent as a successful `ToolMessage`. Use `respond` when the tool is intentionally a placeholder for human input—for example, an `ask_user` tool that prompts for clarification.
>
> ## Streaming with human-in-the-loop
>
> You can use `stream()` instead of `invoke()` to get real-time updates while the agent runs and handles interrupts. Use `stream_mode=['updates', 'messages']` with `version="v2"` to stream both agent progress and LLM tokens in the unified v2 format.
>
> ```python
> from langgraph.types import Command
>
> config = {"configurable": {"thread_id": "some_id"}}
>
> # Stream agent progress and LLM tokens until interrupt
> for chunk in agent.stream(
>     {"messages": [{"role": "user", "content": "Delete old records from the database"}]},
>     config=config,
>     stream_mode=["updates", "messages"],
>     version="v2",
> ):
>     if chunk["type"] == "messages":
>         # LLM token
>         token, metadata = chunk["data"]
>         if token.content:
>             print(token.content, end="", flush=True)
>     elif chunk["type"] == "updates":
>         # Check for interrupt
>         if "__interrupt__" in chunk["data"]:
>             print(f"\n\nInterrupt: {chunk['data']['__interrupt__']}")
>
> # Resume with streaming after human decision
> for chunk in agent.stream(
>     Command(resume={"decisions": [{"type": "approve"}]}),
>     config=config,
>     stream_mode=["updates", "messages"],
>     version="v2",
> ):
>     if chunk["type"] == "messages":
>         token, metadata = chunk["data"]
>         if token.content:
>             print(token.content, end="", flush=True)
> ```
>
> See the Streaming guide for more details on stream modes.
>
> ## Execution lifecycle
>
> The middleware defines an `after_model` hook that runs after the model generates a response but before any tool calls are executed:
>
> 1. The agent invokes the model to generate a response.
> 2. The middleware inspects the response for tool calls.
> 3. If any calls require human input, the middleware builds a `HITLRequest` with `action_requests` and `review_configs` and calls `interrupt`.
> 4. The agent waits for human decisions.
> 5. Based on the `HITLResponse` decisions, the middleware executes approved or edited calls, synthesizes `ToolMessage`'s for rejected calls, returns human replies directly as `ToolMessage`'s for `respond` decisions, and resumes execution.
>
> ## Custom HITL logic
>
> For more specialized workflows, you can build custom HITL logic directly using the `interrupt` primitive and `middleware` abstraction.
>
> Review the execution lifecycle above to understand how to integrate interrupts into the agent's operation.

[Original docs page](https://docs.langchain.com/oss/python/langchain/human-in-the-loop#interrupt-decision-types)
