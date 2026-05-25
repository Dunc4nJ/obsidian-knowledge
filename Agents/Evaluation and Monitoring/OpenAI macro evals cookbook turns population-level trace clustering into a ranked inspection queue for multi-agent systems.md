---
created: 2026-05-25
description: OpenAI Cookbook notebook demonstrating a two-level eval architecture for multi-agent systems — lower-level Promptfoo rubrics per trace combined with BERTopic-style population clustering and AgentTrace backward graph diagnosis to surface recurring behavior patterns ranked by prevalence × severity.
source: https://developers.openai.com/cookbook/examples/partners/macro_evals_for_agentic_systems/macro_evals_for_agentic_systems
type: framework
---

# OpenAI macro evals cookbook turns population-level trace clustering into a ranked inspection queue for multi-agent systems

## Key Takeaways

- The cookbook introduces a two-level eval architecture that mirrors [[the agent improvement loop is traces enriched with evals and human feedback converted into validated fixes|the agent improvement loop]]: **lower-level evals** (Promptfoo rubrics) grade individual agent decisions, handoffs, tools, and completed runs; **macro evals** then ask which local findings repeat at population scale and where they concentrate. The unit of output is a **behavior pattern** — a named, impact-ranked recurring operational issue — not a single failing trace. This is the same screening/investigation split that [[LangSmith Engine turns production agent traces into issues evaluators and regression examples by separating screening from investigation|LangSmith Engine]] applies, here applied to a full synthetic EV-order swarm.

- Four reader-facing labels thread the entire pipeline: `case_type` (generated scenario), `run_outcome` (terminal state), `eval_finding` (local rubric signal), and `behavior_pattern` (discovered population-level cluster). The mental model is: case_type is the setup, run_outcome is the ending, eval_finding is the local symptom, behavior_pattern is the recurrence. Sankey diagrams at two stages — before and after clustering — make this progression visible: the first Sankey maps setup → outcome → finding; the second adds → pattern. This is more legible than [[deep agent evals need bespoke per-datapoint test logic not uniform evaluators|bespoke per-datapoint logic]] because it produces a shared map for technical and business readers.

- Trace normalization into **comparable documents** is where evaluation design lives, not in clustering hyperparameters. Each bundle (scenario setup + event log + environment signals + review packet + SDK spans) is compressed into a structured narrative preserving scenario, routing, handoffs, findings, and terminal state. What a document includes defines what the clusterer can notice: including agent handoffs exposes routing patterns; including environment signals exposes market-drift failures. [[Langfuse Academy argues offline evaluation starts with manual review and automates only the failure modes worth checking repeatedly|Langfuse Academy's principle]] — automate only the failure modes worth checking repeatedly — applies: document construction encodes which signals matter before any model is run.

- BERTopic-style discovery uses a modular pipeline: embed trace documents → UMAP dimensionality reduction → HDBSCAN density clustering → class-aware TF-IDF labeling. Impact ranking uses `prevalence × severity_weighted_prevalence` so that patterns rank higher when they are both common and consequential. The notebook then adds a **cohort-analysis lift layer** after topic assignment: for each (behavior_pattern, case_type) pair, `lift = slice_pattern_share / overall_pattern_share`. A lift > 1 means the pattern concentrates in that scenario slice — which converts a generic pattern into an investigation target. A fulfillment-reroute pattern with lift 2× inside supplier_substitution_compound cases should send the team to procurement handoffs and routing policies, not to clean-order logic.

- AgentTrace-style diagnosis builds a lightweight execution graph $G = (V, E)$ from the event log of traces in the selected pattern, then scores upstream suspects from an anchor (review/finding marker, failure status, late-stage decision) backward through the graph. The explainable suspect score is `0.4·proximity + 0.3·frequency + 0.2·bridge + 0.1·role`. This is not causal proof; it is a prioritized inspection queue — which agents, tools, handoffs, or review policies appear most often near the failure signal across the sampled traces. The output separates eval/review signals (the "where the workflow said something is wrong") from operational targets (the "where to look next in the system").

- ![[openai-cookbook-macro-evals-001.svg]]

  The architecture diagram shows how scenario inputs drive an orchestrated specialist swarm; the runtime emits trace bundles; saved Promptfoo labels are joined to normalized traces; and the macro-eval layer turns that joined evidence into pattern and diagnosis views. Specialists include: validation, supply risk, procurement planning, capacity balancing, factory routing, market intelligence, pricing, compliance, customer communications, and release review.

- Practical division of next steps: AI engineers promote clear lower-level failures into regression suites, calibrate rubric strictness, and inspect top suspect agents/tools/handoffs before changing the system. Business stakeholders validate whether generated case types match real operating risks and whether high-impact patterns correspond to important customer or operational outcomes. The macro eval makes this division of labor tractable because the patterns are legible to both audiences — unlike raw trace tables.

## External Resources

- [OpenAI Cookbook: Macro Evals for Agentic Systems](https://developers.openai.com/cookbook/examples/partners/macro_evals_for_agentic_systems/macro_evals_for_agentic_systems)
- [GitHub: openai-cookbook / macro_evals_for_agentic_systems](https://github.com/openai/openai-cookbook/tree/main/examples/partners/macro_evals_for_agentic_systems)
- [BERTopic algorithm walkthrough](https://maartengr.github.io/BERTopic/algorithm/algorithm.html)
- [Promptfoo: OpenAI Agents provider](https://www.promptfoo.dev/docs/providers/openai-agents/)
- [AgentTrace paper: Causal Graph Tracing for Root Cause Analysis in Deployed Multi-Agent Systems](https://arxiv.org/abs/2603.14688)

## Original Content

> [!note]- Full Notebook — OpenAI Cookbook, Macro Evals for Agentic Systems (joint OpenAI × Slalom)
>
> ### Macro Evals for Agentic Systems
>
> When an agentic system fails, the problem is often larger than a single bad response. A handoff may happen too late, a specialist agent may miss the same signal across many runs, or a review process may trigger for the wrong class of cases. To improve the system, teams need to see recurring behavior across the whole population of traces.
>
> This cookbook walks through a macro-eval workflow for a multi-agent system. We use a synthetic EV order workflow where specialist agents handle pricing, compliance, supply, factory routing, scheduling, and release decisions while market and operational conditions change.
>
> The notebook uses precomputed synthetic traces and saved lower-level eval labels, so you can run the full workflow without an OpenAI API key.
>
> You will learn how to:
> 1. Generate or collect many traced agent runs;
> 2. Run lower-level evals on each completed run;
> 3. Turn each trace into a compact document;
> 4. Discover recurring behavior patterns across the population; and
> 5. Drill into one high-impact pattern to find where a human should inspect the system next.
>
> The goal is not to build a perfect taxonomy of every trace. The goal is to show how an AI engineering team can move from thousands of agent events to a small number of patterns that are understandable by both technical and business stakeholders.
>
> ---
>
> ### End-to-End Agentic System Map
>
> The key idea is that the notebook evaluates a saved agentic system, not a generic chat transcript. Scenario inputs drive an orchestrated specialist swarm, the runtime emits trace bundles, saved Promptfoo labels are joined to normalized traces, and the macro-eval layer turns that evidence into pattern and diagnosis views.
>
> ---
>
> ### 1. Why Macro Evals?
>
> Evals are how AI teams measure whether a system is working. For a simple model call, an eval might compare one output against a rubric or reference answer. For an agentic system, we also need to evaluate whether the system used the right tools, delegated to the right specialist, paused for review when risk was high, and stayed grounded in the business context.
>
> Multi-agent systems make this harder because a final answer is only the last event in a longer workflow. A release recommendation can look plausible while the trace reveals that the pricing agent ignored an incentive, the supply agent missed a stockout, or the orchestrator routed around a required review step.
>
> This notebook separates the problem into two levels:
>
> - **Lower-level evals** grade individual agents, handoffs, tools, and completed runs. In this example, Promptfoo stands in for that agent-level eval layer by grading whether a run handled final decision quality, policy correctness, specialist routing, market drift, and review appropriateness.
> - **Macro evals** look across many lower-level findings. They ask: which kinds of problems repeat, where do they concentrate, and which part of the agent workflow should we inspect first?
>
> We will use four reader-facing labels throughout the cookbook:
>
> - `case_type`: the generated business situation, such as a clean order, a validation block, a supplier substitution, or a pricing exception.
> - `run_outcome`: how the run ended, such as completed, awaiting review, blocked, or failed.
> - `eval_finding`: the lower-level signal that says what seemed wrong or risky.
> - `behavior_pattern`: the recurring pattern discovered across many traces.
>
> A useful mental model is: `case_type` is the setup, `run_outcome` is the ending, `eval_finding` is the local symptom, and `behavior_pattern` is the population-level pattern.
>
> ---
>
> ### 2. The Simulation: Automotive Orders in a Changing World
>
> The simulated business is an EV order and post-configuration workflow. A customer has chosen a vehicle configuration, and the company needs to decide whether the order can proceed as-is, needs adjustment, should be rerouted, requires substitution, or should pause for review.
>
> The simulation includes the kinds of constraints that make real automotive fulfillment hard:
>
> - component availability and supplier substitution;
> - factory capacity and production scheduling;
> - pricing exceptions, promotions, and incentives;
> - tariffs and dated market signals;
> - regional compliance constraints;
> - customer clarification and escalation paths;
> - release review thresholds for risky or ambiguous cases.
>
> The agent swarm is organized around those business responsibilities. An orchestrator receives the order and current environment, then delegates to specialists such as validation, supply risk, procurement planning, capacity balancing, factory routing, market intelligence, pricing, compliance, customer communications, and release review.
>
> This maps naturally to the OpenAI Agents SDK. In the SDK, an agent is the core unit of a workflow: it packages a model, instructions, and optional runtime behavior such as tools, handoffs, guardrails, and structured outputs. The simulation follows that pattern:
>
> - **specialized agents** package the instructions and tools for one part of the decision;
> - **handoffs** let the orchestrator delegate to another specialist agent instead of stuffing every responsibility into one prompt;
> - **function tools** expose order data, environment signals, and approval markers through structured inputs and outputs;
> - **guardrails and review thresholds** represent validation, blocking, and human-review flows for risky or ambiguous cases;
> - **structured outputs** make downstream grading and aggregation possible;
> - **traces** preserve structured records of model calls, tool calls, handoffs, guardrails, and custom spans for debugging and macro-level analysis.
>
> The low-level evals later in the notebook are grounded in this simulation story. If the case type says there is a supplier substitution under tariff pressure, the trace should show awareness of supply, policy, market, and review risk. If the case type is clean, unnecessary escalation is itself a finding.
>
> ---
>
> ### What One Bundle Represents
>
> In this notebook, a **bundle** is the evidence packet for one simulated customer-order interaction.
>
> A bundle matters because macro evals need the workflow evidence behind the final answer. They need to know which agents were consulted, which tools were called, which environment signals were active, whether review was required, and where the workflow changed direction. With that evidence, we can move from "what happened in this one run?" to "which workflow patterns repeat across many runs?"
>
> Bundle anatomy:
>
> | bundle_part | what it contains | why it matters |
> |---|---|---|
> | run | Run id, trace id, terminal state, batch metadata, and synthetic order context | Lets us join one interaction across tables and understand its business setup |
> | events | A normalized event log: status updates, handoffs, tool/function activity, responses, and findings | Main evidence stream for trace documents and AgentTrace-style diagnosis |
> | spans | OpenAI Agents SDK trace spans for handoffs, function calls, responses, and timing | Gives lower-level execution structure behind the event log |
> | environment_events | The dated world state active for the order: tariffs, incentives, stockouts, promotions, competitor pressure, launches, and schedule/capacity signals | Lets evals check whether the swarm reacted to the world it was given |
> | review_packet | A simulated review artifact with findings, recommended action, allowed actions, and review status | Lets us evaluate whether escalation or review was appropriate |
> | snapshots | Optional inventory, capacity, and environment snapshots | Provides operational context when a case depends on supply or scheduling |
>
> The generated batch asked the swarm to handle 1,000 synthetic order interactions. For 992 of them, we have a bundle complete enough for grading, document-building, clustering, and path inspection.
>
> ---
>
> ### 3. Lower-Level Agent Evals with Promptfoo
>
> A mature multi-agent system should not rely on final-answer inspection alone. Each launched agent usually needs its own evals: did this specialist use the right evidence, call the right tools, respect policy, hand off at the right time, and produce an output that the rest of the system can trust?
>
> Promptfoo grades completed traces with five rubrics:
>
> | rubric | plain_english_question |
> |---|---|
> | final_decision_quality | Final decision is supported by the active issues, terminal state, and agent outputs |
> | policy_compliance_correctness | Policy, tariff, incentive, and regional compliance context is handled correctly |
> | routing_specialist_activation | Specialist routing matches the issues present in the bundle |
> | market_drift_awareness | Changing market conditions and dated environment signals are noticed |
> | review_appropriateness | Review and escalation behavior is proportionate to the case risk |
>
> These checks produce `eval_finding`. A failing lower-level eval is a local signal: one trace, one rubric, one symptom. The macro-eval sections later ask what those local signals become at population scale.
>
> ---
>
> ### 4. Build the Analysis Dataset
>
> The public analysis path is:
>
> `case_type -> run_outcome -> eval_finding -> behavior_pattern`
>
> The first three labels are known before clustering. The fourth appears after discovery.
>
> **Trace documents: turning runs into comparable text**
>
> A good trace document includes:
> - the business setup (`case_type`, selected route, active environment signals);
> - the run outcome and severity;
> - the important handoffs and specialist activations;
> - review/finding markers;
> - a short state-transition digest.
>
> The document view defines what the clustering algorithm is allowed to notice. The quality of the trace document is therefore part of the evaluation design, not a mechanical cleanup step.
>
> **Focus-event glossary**
>
> | focus_event_signal | meaning | how_to_use_it |
> |---|---|---|
> | review finding | An issue was recorded by review, validation, or a grading surface | Start from this when the trace has an explicit finding |
> | review required / awaiting_review | The simulated business process paused for review | Check whether review was justified by the active risk |
> | failed / blocked | The run ended in a degraded terminal state | Walk backward to the last handoff, tool, or specialist decision |
> | triage route / reroute | The workflow changed ownership or path | Inspect whether routing matched the case type and environment signals |
> | tool warning / policy marker | A structured tool exposed risk or policy context | Check whether later decisions used or ignored that signal |
>
> ---
>
> ### 5. BERTopic-Style Discovery
>
> The discovery pass is modular:
>
> 1. **Represent** each trace document as a vector: $e_i = f(d_i)$
> 2. **Reduce** via UMAP to preserve useful local neighborhoods
> 3. **Cluster** dense regions via HDBSCAN; outliers are noise (topic -1)
> 4. **Label** each cluster using class-aware term scores: $score(t, k) = tf(t, k) \times \log\left(\frac{1 + N}{1 + df(t)}\right)$
>
> Impact ranking:
>
> $$impact\_score(k) = prevalence\_share(k) \times severity\_weighted\_prevalence(k)$$
>
> The topic table functions as a triage board: `trace_count` and `prevalence` say how often a pattern appears; `impact_score` combines prevalence and severity into a ranking; `keywords_text` gives what makes the cluster distinctive.
>
> **Comparing patterns across slices (lift analysis)**
>
> After topic assignment, a cohort-analysis layer computes:
>
> $$lift = \frac{slice\ pattern\ share}{overall\ pattern\ share}$$
>
> A lift > 1.0 means the pattern is concentrated in that case_type slice. This converts a generic pattern into a directed inspection target: inspect procurement handoffs and routing policies for a fulfillment-reroute pattern that lifts 2× inside `supplier_substitution_compound`.
>
> ---
>
> ### 6. AgentTrace-Style Diagnosis
>
> Discovery tells us what repeats. Diagnosis asks where to inspect first.
>
> For the selected behavior pattern, we build a lightweight execution graph $G = (V, E)$ from the event log, choose an anchor (review/finding marker or failure event), and walk backward scoring upstream suspects:
>
> $$suspect\_score = 0.4 \cdot proximity + 0.3 \cdot frequency + 0.2 \cdot bridge + 0.1 \cdot role$$
>
> - **Proximity**: rewards events close to the focus event
> - **Frequency**: rewards events recurring across sampled traces in the same pattern
> - **Bridge**: rewards events connecting parts of the execution graph
> - **Role**: rewards events whose agent/tool role is plausibly related to the finding
>
> This is not proof of causality. It is a way to turn "this pattern is important" into "inspect these agents, tools, handoffs, or review policies first."
>
> From a technical perspective, this output tells an AI engineer where to inspect: agent instructions and tool contracts for named agents; handoff rules around the repeated transition; whether review markers trigger too early or too late; whether a tool output is being ignored or over-weighted.
>
> From a business perspective, the same output tells an operations or product stakeholder which business function appears to own the pattern.
>
> ---
>
> ### 7. What We Learned and What to Do Next
>
> The cookbook moved through four levels of evidence:
>
> 1. **Simulation setup:** EV order cases under changing supply, pricing, capacity, compliance, and market conditions
> 2. **Lower-level evals:** Promptfoo supplied agent/workflow-level eval signals
> 3. **Macro discovery:** BERTopic-style clustering grouped lower-level findings into recurring behavior patterns ranked by impact
> 4. **Trace diagnosis:** AgentTrace-style graph analysis inspected one high-impact pattern and identified repeated upstream suspects
>
> Practical next steps for an AI engineering team:
> - promote the clearest lower-level eval failures into a regression suite;
> - review a small sample of automated grades to calibrate rubric strictness;
> - track behavior patterns by model version, prompt version, and orchestration mode;
> - assign business owners to the highest-impact patterns;
> - inspect the top suspect agents, tools, and handoffs before changing the system.
>
> Practical next steps for a business stakeholder:
> - decide whether the generated case types match the real operating risks;
> - check whether high-impact patterns correspond to important customer or operational outcomes;
> - validate whether review thresholds are producing the intended business behavior;
> - use the Sankey and heatmap views to prioritize which scenarios need better policy or process design.
>
> **The core lesson:** agent-level evals tell us which local behaviors look risky, while macro evals tell us what those risks become at system scale.
>
> ---
>
> *Contributors: Shikhar Kwatra, Will Thieme, Bradley Strauss (OpenAI × Slalom)*
