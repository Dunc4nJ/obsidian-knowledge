---
created: 2026-05-20
description: LangSmith Engine is an orchestrator agent built on Deep Agents that compresses traces into trajectory skeletons, dispatches Haiku-based screener subagents across batches, then promotes flagged traces into issues with proposed evaluators, regression assertions, and a needs_fix handoff to a separate fix agent.
source: https://x.com/palashshah/status/2056786835322687640
type: framework
---

# LangSmith Engine turns production agent traces into issues evaluators and regression examples by separating screening from investigation

## Key Takeaways

- Engine reframes [[the agent improvement loop is traces enriched with evals and human feedback converted into validated fixes|the agent improvement loop]] as an orchestrator-agent problem: instead of having humans hunt for recurring failures in [[Langfuse Academy primer argues tracing is the foundational primitive every step of the agent improvement loop operates on|tracing UIs]], an agent sits on top of trace data, groups failures into issues, and proposes the evaluator + dataset example + code fix in one pass. The unit of output is the **issue** — a named, categorized, severity-tagged failure pattern with evidence traces and proposed follow-up actions — not a flagged span.

- The architecture splits the workload along a screening/investigation seam to survive [[SmithDB makes LangSmith 12x faster by treating agent observability as an LSM problem on object storage|production trace volumes]]. A dedicated Haiku-based **screener subagent** receives batches of ~20 traces and answers a single narrow question (issue / clean) using compact **trajectory summaries** — `{role, tool_name, latency_ms, chars}` per turn with no content. Only flagged traces get full content loaded by general-purpose **investigator subagents** that the main agent prompts dynamically per investigation. This is the same context-budget logic [[trajectory eyeballing is the irreplaceable skill for debugging RL-trained agents|that trajectory eyeballing exploits at the human scale]].

- Engine constrains itself to a predefined taxonomy of failure categories — `pii_leak`, `agent_looping`, `incorrect_tool_args`, `missing_tool`, etc. — rather than inventing categories on the fly. This is a deliberate quality-control choice: known categories can be measured, evaluated, and expanded deliberately, where free-form invention makes outputs hard to trust or compare across runs. Users still steer attention through the Agent Overview, an AGENTS.md-like living instruction file that doubles as persistent memory across runs.

- For every issue, Engine proposes an evaluator (code or LLM-as-judge, picked by failure type) and **tests it against the evidence traces via a `test_evaluator` tool before surfacing it** — guarding against evaluators that look reasonable but fail to catch the very pattern they were proposed for. It also proposes [[anthropic recommends combining deterministic graders model judges and human review for agent evals|regression examples as assertions]] (key + comment) rather than full ground-truth outputs, preserving wording flexibility while pinning down what must be true. This closes the loop from production failure to offline test coverage in one agent pass.

- A late-stage architecture decision was to **split issue creation from fix generation**. Earlier versions had one agent scan traces, decide what mattered, group failures, create issues, generate evaluators, propose dataset examples, and reason about the right fix — the agent struggled at the fix step. Engine now tags issues `needs_fix` and hands off to a separate fix agent that starts from the issue, evidence traces, and repo context. This mirrors the [[every deploy should trigger a monitor-triage-fix loop that dispatches a coding agent to fix regressions before users notice|monitor-triage-fix split]] pattern: one agent finds patterns, another agent proposes the change.

## External Resources

- [LangSmith Engine launch](https://www.langchain.com/langsmith) — the product page where Engine appears inside a tracing project
- [Deep Agents](https://docs.langchain.com/oss/python/deepagents/overview) — the LangChain harness library Engine is built on top of
- [LangSmith Sandboxes](https://docs.langchain.com/langsmith) — the controlled working environment Engine runs inside, with optional repo checkout
- [LangSmith CLI](https://docs.langchain.com/langsmith/cli) — Engine's primary interface to LangSmith data; same CLI is available to local coding agents

## Original Content

> [!quote]- Source Material — X long-form Article by Palash Shah, 2026-05-19, 145 likes / 25 RTs / 5 replies
>
> **@palashshah (Palash Shah)**
> **Article: How We Built LangSmith Engine, Our Agent for Improving Agents**
>
> Last week we launched LangSmith Engine. Engine is an agent that sits on top of your agent traces, spots recurring issues, and suggests what to do next.
>
> This post goes into the technical details of how we built it: why we built Engine, what inputs and outputs it works with, and the architecture decisions that let it analyze large volumes of traces.
>
> *Cover diagram: LangSmith Engine inputs/outputs overview*
>
> ![[palashshah-687640-002.jpg]]
>
> ## Why we built Engine
>
> LangSmith is the home of the agent improvement loop. Build, test, deploy, and monitor are the four pillars of this loop that power agent development.
>
> As the number of agents you deploy grows, the number of traces they generate grows as well. As a result, you spend more and more time sorting through traces and figuring out where your agent went wrong.
>
> Basic tool errors are relatively easy to catch. Overall trajectories are also visible from the trace view. But many agent issues are much harder to detect unless you inspect each trace at a granular level:
>
> - the agent loops through the same tool calls
> - it uses incorrect tool arguments
> - it executes inefficiently
> - it misses a tool it should have used
> - it fails the same kind of request repeatedly across different runs
>
> After running into this problem internally at LangChain, we set out to build LangSmith Engine.
>
> Engine has three jobs:
>
> 1. Find recurring failures in traces.
> 2. Turn those failures into actionable issues.
> 3. Convert those issues into durable improvements: evaluators, dataset examples, and fixes.
>
> Engine is itself an agent: an orchestrator that uses specialized components to run the improvement loop end to end. It pulls traces, reads code when a repository is connected, groups failures into issues, proposes evaluators and dataset examples, and updates its understanding of your agent over time.
>
> ## What Engine produces: issues
>
> At its core, Engine identifies issues.
>
> An issue is a recurring failure pattern, backed by evidence traces, with proposed follow-up actions. Issues are presented to the user in an Issue Board: a list of problems Engine has found in the tracing project.
>
> An issue consists of:
>
> - Name: title of the issue
> - Description: paragraph description of the issue
> - Category: one of a predefined set of agent failure categories
> - Severity: low, medium, or high
> - Traces: associated traces that provide evidence for where the issue occurs
> - Proposed actions: suggested next steps for preventing the issue from recurring
> - Tags: metadata used to drive follow-up workflows, such as needs_fix
>
> The proposed actions can include:
>
> - Proposed online evaluator: an evaluator that would flag the issue if it happens again
> - Proposed dataset examples: additions to an offline dataset that are representative of the issue
> - Proposed fix: code or prompt changes to fix the underlying issues.
>
> The important point is that Engine does not just point at a bad trace. It tries to turn a production failure into something your team can act on and test against in the future.
>
> ## What Engine consumes
>
> Engine receives, or is able to fetch, four main inputs.
>
> **Instructions**
>
> Engine is guided by an Agent Overview. This is similar to an AGENTS.md file: a living description of what your agent does, what trace structures to expect, what failure modes to watch for, and what preferences your team has expressed.
>
> The first run is bootstrapped from onboarding answers and project context. During that initial run, Engine analyzes traces and uses what it learns to create the first version of the Agent Overview. On subsequent runs, the Agent Overview becomes a persistent input that Engine reads and updates.
>
> You can also edit the Agent Overview manually at any point.
>
> **Traces**
>
> Engine pulls traces from the relevant LangSmith tracing project through the LangSmith CLI.
>
> A full trace includes the messages and trajectory of an agent run. For scale, Engine does not always start by loading the full content of every trace. It often starts from compact trajectory summaries, then selectively loads full trace contents when a trace needs deeper investigation.
>
> **Existing issues**
>
> Engine fetches the current set of Issues, including open issues and previously closed issues.
>
> This gives Engine the current state of the project. It can avoid duplicating known issues, add evidence to existing ones, and understand what has already been resolved or closed.
>
> **Codebase, optionally**
>
> You can optionally connect Engine to your codebase. This lets Engine diagnose issues more precisely and enables a separate fix agent to propose changes.
>
> If a repository is connected, the repo is installed into the sandbox. During setup, you can specify which branch or subdirectory Engine should use.
>
> ## What Engine updates
>
> Engine can update several outputs as it runs.
>
> **Issues**
>
> The main role of Engine is to update the current set of issues. It can create new issues, update existing issues, attach evidence traces, and change issue metadata.
>
> For each issue, Engine can propose an evaluator that catches the same pattern in future traces. It can also propose regression examples from evidence traces, so failures observed in production can become offline test coverage. It can also suggest prompt or code changes to fix the underlying issue.
>
> **Agent Overview**
>
> Engine can take notes on what it discovered and update the Agent Overview for future runs.
>
> This is how Engine remembers project-specific information over time: common failure modes, trace patterns, tool behavior, and user preferences.
>
> ## High-level architecture
>
> Engine is built on top of Deep Agents and connects to a sandbox where it can write files, inspect traces, execute code, and work with a checked-out repository.
>
> At a high level, Engine is driven by:
>
> - System prompt and instructions: including the Agent Overview
> - Sandbox: the environment where Engine works
> - LangSmith CLI: the main interface Engine uses to fetch data and push updates back to LangSmith
> - Custom tools: especially tools for testing evaluators and proposing regression examples
> - Subagents: used to screen traces and investigate likely issues without overflowing the main agent context
> - Memory: maintained through the Agent Overview and updated based on user actions
>
> *LangSmith Engine agent architecture — orchestrator connected to instructions, CLI, tools, subagents, and outputs*
>
> ![[palashshah-687640-003.jpg]]
>
> The rest of this post walks through the core loop:
>
> 1. Prepare the agent's context.
> 2. Screen traces at scale.
> 3. Investigate likely issues.
> 4. Create issues, evaluators, and dataset examples.
> 5. Hand off fixes to a separate agent when needed.
> 6. Update memory for the next run.
>
> ## 1. Preparing the agent's context
>
> Before Engine can analyze traces, it needs an environment to work in and enough context to understand the agent it is inspecting.
>
> **Sandbox setup**
>
> Engine runs connected to a sandbox. We use LangSmith Sandboxes for this.
>
> Before running Engine, we set up the agent's environment. First, we pull the base Engine Docker image. This image includes the required libraries and the LangSmith CLI, which Engine uses to interact with LangSmith data.
>
> If Engine is connected to a GitHub repository, we also pull down the relevant code artifacts. The user can specify which branch or subdirectory to use during setup.
>
> The sandbox matters because Engine often needs to inspect trace data, write intermediate files, test evaluator code, and iterate on proposed outputs. Giving the agent a controlled working environment makes that workflow much more reliable.
>
> **Agent Overview**
>
> The Agent Overview is both an instruction file and a memory layer.
>
> When you set up Engine, you answer a base set of onboarding questions. Engine uses those answers, along with what it discovers during its first run, to create the initial Agent Overview.
>
> The overview helps Engine maintain a continuous record of:
>
> - what your agent does
> - what trace structures to expect
> - common pitfalls to watch for
> - project-specific context
> - user preferences
>
> Engine reads and updates this file on consecutive runs.
>
> **LangSmith CLI**
>
> The main way Engine interacts with LangSmith is through the LangSmith CLI.
>
> We prefer this, for the most part, over creating a custom tool for every LangSmith operation. The CLI gives Engine a general-purpose interface for pulling traces, querying issues, creating issues, attaching traces, updating issue metadata, and proposing artifacts.
>
> It also makes Engine easier to debug and reproduce. The CLI is the same interface that is available for download and can be given to coding agents locally. If Engine does something through the CLI, it is usually possible to understand and reproduce that operation outside of Engine as well.
>
> ## 2. Screening traces at scale
>
> The biggest architecture challenge in building Engine was trace volume.
>
> It was relatively easy to get an agent to investigate and sort through 50 traces at a time. But once we connected the system to production agents, the techniques that worked at that volume started to fall apart. Production projects can have thousands or tens of thousands of traces in a lookback window.
>
> Loading all full trace contents into the main agent's context is not viable. Even 10 traces from long-running agents can contain hundreds of tool calls and messages.
>
> So we split the problem into two phases:
>
> 1. A broad screening phase that quickly identifies suspicious traces.
> 2. A deeper investigation phase that only loads full context for traces that are likely to matter.
>
> **Trajectory format**
>
> To make screening possible, we needed a compressed representation of each trace.
>
> The question was:
>
> > How do you compress the information in a trace while retaining the information needed to navigate back into it?
>
> The answer was agent trajectory: compact skeletons of traces.
>
> A trajectory has one entry per turn, with role, optional tool name, latency, and content size. It does not include full content.
>
> ```json
> { role: "human", chars: 142 }
> { role: "ai", latency_ms: 1820, chars: 89 }
> { role: "tool", tool_name: "search_db", latency_ms: 340, chars: 2100 }
> { role: "tool", tool_name: "search_db", latency_ms: 312, chars: 1980 }
> { role: "tool", tool_name: "search_db", latency_ms: 298, chars: 2040 }
> { role: "ai", latency_ms: 2100, chars: 210 }
> ```
>
> The trajectory acts as a navigation tool. It lets the screener spot suspicious shapes quickly, then grep around the full trace and load only the information it needs into context.
>
> *Trajectory summaries compress traces for screening — full message+tool+output run data on the left compressed to a per-turn role/latency/chars skeleton on the right, used by screeners to spot suspicious shapes*
>
> ![[palashshah-687640-004.jpg]]
>
> **Prioritizing traces with feedback**
>
> Traces may already have feedback associated with them. This can come from human annotations, LLM-as-a-judge scores, or end-user feedback (thumbs up/down).
>
> Engine consumes feedback on traces as a high-priority signal that an issue may exist.
>
> The initial set of traces Engine pulls includes feedback stats. Engine is instructed to look for traces with feedback and prioritize them for triage.
>
> Feedback does not automatically become an issue. It raises the priority for screening and investigation. The agent still needs to determine whether the trace is part of a real issue.
>
> **The screener subagent**
>
> The core screening question is:
>
> > Given this trace, is there an issue in it that warrants further investigation?
>
> Engine uses a dedicated screener subagent for this. The screener is a Haiku-based subagent that the main agent dispatches across groups of roughly 20 traces.
>
> The screener's job is intentionally narrow. It does not create issues. It does not diagnose root cause. It only decides, at a surface level, whether a trace is clean or might contain an issue.
>
> The screener returns a structured response to the main agent. The response contains one line per flagged trace, with the trace ID, category, and a short reason, followed by a count of clean traces.
>
> ```
> <trace_id> | <category> | <one-line reason>
> CLEAN: 47
> ```
>
> This step reduces the search space. Instead of asking the main agent to reason over every trace in full, we use parallel screeners to identify the traces that deserve deeper attention.
>
> ## 3. Investigating likely issues
>
> After screening, the main agent reads the screener outputs and dispatches deeper investigations.
>
> **Investigator subagents**
>
> The investigator takes flagged traces, pulls the full trace contents, reads the codebase when available, and does a deeper analysis of the potential issue.
>
> We encourage the main agent to use subagents for this because full trace contents can be large. Loading several full traces and relevant code into the main agent's context window would cause it to overflow quickly.
>
> Unlike the screener, the investigator is not a dedicated subagent with a fixed system prompt. It is a general-purpose subagent prompted by the main agent for the specific investigation. This gives the main agent flexibility: different issue types may require different investigation strategies.
>
> The investigator's job is to determine whether the flagged traces represent a real issue, whether traces should be grouped together, and what should be recorded on the issue.
>
> **Issue categories**
>
> Engine has a concept of category for each issue.
>
> We identified a predefined set of common agent failure modes and prompt Engine to primarily look for those types of issues. This list includes things like:
>
> - pii_leak
> - agent_looping
> - incorrect_tool_args
> - missing_tool
>
> Constraining Engine to known categories helps us control what issues it finds and evaluate those issue types before introducing them to customers. It also makes the output easier for users to understand.
>
> Users can still customize what Engine should focus on through the Agent Overview. If a team cares about particular issue types, they can describe those priorities there.
>
> We are actively expanding this category list over time as we identify and validate new recurring agent failure modes.
>
> ## 4. Creating issues, evaluators, and dataset examples
>
> Once Engine identifies a real issue, the main agent creates or updates the issue and attaches evidence traces.
>
> The main agent is responsible for issue creation and the evaluation artifacts around the issue. It is not responsible for directly fixing the underlying code or prompt.
>
> For each issue, Engine can produce:
>
> 1. The issue itself, with evidence traces.
> 2. A proposed evaluator.
> 3. Proposed regression examples.
> 4. A needs_fix tag, if a separate fix agent should be kicked off.
>
> **Evaluators**
>
> Engine is prompted to propose an evaluator for every issue.
>
> The idea is simple: once you find a failure pattern, you want a check that catches the same pattern on future traces.
>
> Engine supports two evaluator types.
>
> Code evaluators are JavaScript functions that inspect the structure of a trace — field values, tool outputs, step counts, error patterns. They are the right choice when the failure is detectable without reading the content.
>
> LLM-as-judge evaluators handle cases that require understanding: hallucinations, grounding failures, unhelpful refusals, wrong advice.
>
> The agent picks the evaluator type based on the issue. Structural failures get code evaluators. Semantic failures get judge evaluators.
>
> Before Engine surfaces a proposed evaluator, it calls the test_evaluator tool.
>
> **test_evaluator tool**
>
> The test_evaluator tool lets Engine test proposed evaluators on evidence traces before suggesting them to the user.
>
> This matters because an evaluator can look reasonable while failing to catch the actual issue. Engine calls the tool with the evaluator definition and the traces it wants to run the evaluator on. The tool executes the evaluator and returns a mapping from trace ID to result.
>
> ```
> def test_evaluator(evaluator, traces) -> {run_id: PASS | FAIL | SKIPPED}
> ```
>
> Where
>
> ```
> PASS     caught issue
> FAIL     missed issue, or evaluator errored
> SKIPPED  evaluator did not apply to this trace
> ```
>
> If the evaluator does not catch the right traces, Engine can iterate on the code or prompt. The goal is to ship the version that best captures the failure pattern represented by the evidence traces.
>
> **Regression examples and assertions**
>
> Whenever an issue is created or a new trace is added to an issue, Engine is instructed to call propose_regression_example once per evidence trace.
>
> This creates a proposed regression example for that trace. The example consists of the original input to the agent along with assertions on the expected output.
>
> We propose assertions rather than a full ground-truth output because assertions are simpler and more flexible. A correct response may be phrased in many different ways. What matters is whether it satisfies the key claims implied by the trace.
>
> Each assertion has:
>
> - key: the feedback identifier, written as a short slug
> - comment: a one-sentence human-readable claim about what a correct response would satisfy
>
> ```
> {
>   "key": "must_cite_max_connections_4096",
>   "comment": "Response cites the max_connections value of 4096 returned by the get_config tool call."
> }
> {
>   "key": "must_not_reference_strict_mode_flag",
>   "comment": "Response must not suggest enabling strict_mode, which was deprecated in this version."
> }
> ```
>
> The proposed examples show up on the issue in the frontend. A reviewer can then promote them into a dataset.
>
> This closes the loop from production failure to offline test coverage.
>
> ## 5. Handing off fixes to a separate agent
>
> A key design decision was separating issue creation from fix generation.
>
> In earlier versions, we tried to have the main agent both identify issues and propose prompt or code fixes. This made the agent's job too broad. It had to scan traces, decide what mattered, group failures, create issues, generate evaluators, propose dataset examples, and also reason about the right fix.
>
> We saw that the main agent struggled to identify fixes reliably when all of that happened in one pass.
>
> So we split the workflow:
>
> 1. The main Engine agent identifies and records the issue.
> 2. It creates the dataset and evaluator artifacts.
> 3. If the issue needs a fix, it leaves a needs_fix tag.
> 4. A separate fix agent is kicked off to propose the actual code or prompt change.
>
> This made the main agent simpler and gave the fix agent a more focused task. The fix agent can start from the issue, evidence traces, and connected repository context, without also needing to perform the full trace-screening workflow.
>
> ## 6. Updating memory for the next run
>
> Engine does not start from scratch every time.
>
> The Agent Overview is updated not only by Engine's investigations, but also by user actions. When you resolve an issue, close an issue, or create an evaluator, that action becomes signal.
>
> Engine can pull recent events through the LangSmith CLI, generalize observations from those events, and update the Agent Overview.
>
> It is specifically prompted to maintain a User Preferences section. This section records what Engine learns from observing how users interact with issues.
>
> Every team cares about a different set of problems. The Agent Overview is how Engine adapts its analysis to those preferences over time.
>
> ## Architecture decisions and lessons learned
>
> A few architecture decisions ended up being especially important.
>
> **Keep the main agent focused on issues**
>
> The main agent only creates issues and the associated dataset/evaluator artifacts. It does not try to fix prompt or code directly.
>
> When an issue needs a fix, the main agent tags it with needs_fix. A separate fix agent then handles the fix proposal.
>
> This split came from observing that one agent struggled when it had to both identify issues and propose fixes in the same pass.
>
> **Use the CLI as the main LangSmith interface**
>
> Most of what Engine does, it does through the LangSmith CLI. This made the system more flexible than creating a narrow custom tool for every operation. It also made Engine behavior easier to reproduce and debug.
>
> **Compress traces before reading them**
>
> Full traces are too large to screen at production scale. Trajectories let Engine reason over the shape of many traces, then selectively load the details that matter.
>
> **Split screening from investigation**
>
> The screener optimizes for scale. The investigator optimizes for deeper analysis.
>
> This split lets Engine handle large trace volumes without forcing every trace through an expensive full investigation.
>
> **Use a dedicated screener but flexible investigators**
>
> The screener has a narrow, repeatable job, so it benefits from a dedicated prompt and structure.
>
> Investigations are more varied. Some require reading code, some require understanding evaluator failures, and some require comparing traces. For that reason, we use general-purpose investigator subagents that the main agent prompts dynamically.
>
> **Constrain issue categories**
>
> Letting the agent invent arbitrary issue categories makes the output harder to evaluate and harder to trust. A predefined taxonomy lets us control quality, measure performance, and expand coverage deliberately.
>
> **Prefer assertions over full expected outputs**
>
> For regression examples, assertions are often a better fit than full reference answers. They capture what must be true without over-constraining the exact wording of a correct response.
>
> ## Conclusion
>
> Engine is our attempt to automate more of the agent improvement loop.
>
> The hard part of agent observability is not just seeing what happened in one trace. It is finding recurring patterns across many traces, deciding which ones matter, and turning those patterns into issues, evaluators, dataset examples, and fixes.
>
> The architecture reflects that loop. Engine prepares context, screens traces at scale, investigates likely issues, creates issue artifacts, hands off fixes to a separate agent when needed, and updates its memory for the next run.
>
> It has already changed how we improve our own agents internally. Instead of manually digging through traces and separately writing evals, we can turn production behavior directly into issues, fixes, and tests.
>
> You can find Engine in your LangSmith tracing project. Connect a repository if you want code-aware fix proposals, or start with traces alone to see what recurring patterns Engine finds.
>
> ---
> date: Tue May 19 17:19:29 +0000 2026
> url: https://x.com/palashshah/status/2056786835322687640
> likes: 145  retweets: 25  replies: 5

## Source

[Article: How We Built LangSmith Engine, Our Agent for Improving Agents](https://x.com/palashshah/status/2056786835322687640) — Palash Shah on X, 2026-05-19
