---
created: 2026-09-22
source: https://x.com/josharosen/status/2102107649705734413
author: Josh Rosen (ThruWire)
published: 2026-09-21
type: knowledge
tags: [jev, checkpoints, thruwire, worker-supervision, agent-oversight, harness-engineering, system-one-models, typesafe]
description: Josh Rosen's third Jev piece is a vendor post for his own product - ThruWire replaces step-by-step supervision with checkpoints, durable states the work must reach carrying artifacts, provenance and evidence, and Jev runs semantic verification on the candidate artifact at that boundary rather than on the execution trace after the fact, with no latency figure, no cost figure, no threshold and no comparison against an LLM judge at the same boundary.
---

# Josh Rosen's ThruWire puts Jev at the checkpoint - prove X things happened however you like, and Jev scores the fuzzy half of that contract against the artifact not the trace

## Key Takeaways

- **The proposition is a contract on the work product, not on the agent loop, and that is the durable idea here even if you never buy the product.** Rosen's one-line pitch to the agent is verbatim: *"do whatever you want, however you want, as long as you can prove these X number of things happened along the way."* A checkpoint is *"a state the work needs to reach without defining exactly how the worker gets there"*, and the thing that crosses it is a candidate artifact carrying stable identity, relationships to the exact upstream artifacts it used, provenance, evidence and *"other receipts"*. ThruWire validates the artifact and those relationships before accepting it and returns validation feedback to the worker when something is wrong. This is the same move [[training beats prompting so use runtime guards not instructions]] makes at the tool boundary, lifted up to the artifact boundary: constrain what must be true at the exit, not what happens inside.

- **The precise thing Jev reads is the artifact, and that is the article's sharpest technical claim.** Rosen is explicit that the alternative he is rejecting is trace inspection: *"Instead of reconstructing what happened from agent traces after the fact, we can accumulate a semantic picture of the work as it happens."* So Jev is not scoring a trajectory, a diff, or a tool call. It evaluates *"every artifact against the fuzzier parts of that contract"* and asks to what degree the evidence supports the claim, whether an implementation satisfies its requirement, or whether something extracted from a conversation really represents a requirement. That is a genuinely different placement from [[LangChain's Sydney Runkle puts Jev inside the agent loop as classifier middleware - ModelRouterMiddleware picks the model from the latest user message and AutoModeMiddleware reproduces closed harnesses' dangerous-action gate|Sydney Runkle's middleware]], which classifies the latest user message, and from [[LangChain's Jev-as-a-Judge bench puts Jev's quality-score variance 92 to 913x below three LLM judges at $0.34 against Claude's $28.17 - five weather traces, one human oracle, provider-default sampling|LangChain's Jev-as-a-Judge]], which scores completed traces offline.

- **This is a vendor post, and the separation matters because the pitch and the argument have different evidence behind them.** ThruWire is Rosen's company; [[Josh Rosen's Jev in the Wild sorts week-one projects into routing, context filtering, tool gating, worker supervision, fast control loops and fuzzy data queries - deterministic only because inference was expensive|his own six-pattern landscape hub]] already listed "worker supervision" as a pattern with Foreman as his example, and this article is that pattern shipped as a product. The architectural argument, that the interesting engineering is the connective tissue between a fast decision model and a slow reasoning model, stands on its own and is the piece worth keeping. The claim that ThruWire's particular checkpoint schema is the right connective tissue is the pitch, and it is supported by one internal demo.

- **Every quantitative claim in the article is a word, not a number.** Jev is *"quick enough"*, *"fast semantic processing"*, it works *"without slowing down the agent"*, and it avoids *"turning the checkpoint into another expensive LLM step"*. There is no latency figure, no cost figure, and no token count anywhere in 1,749 words. More importantly there is no head-to-head against an LLM-as-a-judge sitting at the same checkpoint boundary, which is the only comparison that would establish the claim, and Rosen lists LLM-as-a-judge in his own toolbox section two screens earlier. The vault's numbers for that comparison live in [[LangChain's Jev-as-a-Judge bench puts Jev's quality-score variance 92 to 913x below three LLM judges at $0.34 against Claude's $28.17 - five weather traces, one human oracle, provider-default sampling|LangChain's bench]] and [[TypeSafe's Jev trades string generation for parallel-sampled typed decisions with calibrated probabilities at $0.042 per MTok - the 193x and 444x claims come from four self-built workflow evals|TypeSafe's launch post]], not here.

- **A gate that advances work on "sufficient probability" inherits the vault's standing calibration gap, and Rosen sets no threshold at all.** His formulation is that *"an artifact should advance only if there is sufficient probability that the evidence supports the claim"*. He never says what sufficient means, never names which Jev primitive asks the question (Noul, Choice or Score are never mentioned; he says only *"typed semantic decisions"* and links TypeSafe's launch post), and never cites a calibration measurement. That is the same hole every other Jev-gating design in the vault has: [[TypeSafe's SDE cascade gates escalation on any per-field Noul above 0.7 - the chart's y-axis is mean llm_judge and the frontier dominates only the two middle models|TypeSafe's own SDE cookbook]] picks a fixed 0.7 max-gate swept in-sample, [[Daniel Ch's How to master Jev prescribes a 0.85 and 0.55 confidence-gate ladder under an LLM that still writes - the decision-layer architecture is additive but every number and all three charts are TypeSafe's own|Daniel Ch]] prescribes a 0.85/0.55 ladder with no derivation, [[Sutro's jev-align uses GEPA to rewrite Jev's decision criteria from five labeled examples - the demo moves labeled-set ambiguity 49.6 points but full-pool certainty only 0.5|jev-align]] optimizes criteria without reporting a calibration metric, and [[Featherless's Simple Jev reproduces Jev's API on stock open models by remapping every answer to a single-token letter and softmaxing only those logits - no classifier head, and the code stamps every answer calibrated False|Featherless's Simple Jev]] stamps `calibrated: False` on every answer. Rosen's version is the weakest of the set because it does not even commit to a number you could argue with.

- **The Granola run is a worked demo of the rendering, not a measurement of the gate.** One meeting, three checkpoints, a Jev-enabled classifier asking three affect questions, and an interactive app at the end. The hard numbers come from the screenshot rather than the prose: 420 moment artifacts across 13 conversation chapters, overall Positivity 0.23, Negativity 0.04, Confusion 0.06 on a 15-moment rolling average. There is no ground truth, no human labels, no agreement rate, no accuracy, no cost and no latency, and critically the classifier here is *not* gating anything: Rosen says the questions accumulate *"without making the answer part of the gate"*. So the one experiment in the article exercises the data-generation claim and leaves the verification claim untested. Rosen hedges it himself as *"this first experiment"* and *"just the starting point"*.

- **"Checkpoint" in this note means something different from every other checkpoint note in the vault, and the distinction is worth holding onto.** [[Harvey Spectre makes durable runs the core primitive while workers stay ephemeral and sandboxes enforce explicit boundaries|Harvey's Spectre]], [[LangChain Deep Agents runtime builds ten production capabilities on one primitive - durable super-step checkpointing to PostgreSQL|LangChain's Deep Agents runtime]], [[Opencomputer reframes harness-vs-sandbox debate as git branches for VMs via hibernation egress proxies and checkpoints|Opencomputer]], [[Archil makes the agent turn the unit of filesystem atomicity with copy-on-write checkpoints and branches|Archil]] and [[Browser Use stitches stateless Lambdas into multi-hour browser agents via S3 checkpoints and SQS continuations|Browser Use]] all checkpoint *execution state* so a run can resume, fork or survive a worker dying. ThruWire checkpoints *work state*: nothing is snapshotted for resumption, and the artifact is gated on whether it is semantically acceptable. The durable-run primitive already existed in the vault without Jev. What ThruWire adds on top is semantic verification of the thing produced, which is orthogonal to all five.

- **Three vendors have now converged on the same three-layer shape, and Rosen is the third.** [[Cua keeps the candidate menu in application code so Jev only picks an ID - CUA-S1-FORMS is a 706K-parameter form specialist at 99.7 percent against hosted Jev's 83.6, and neither model sees pixels|Cua]] keeps the candidate menu in application code and hands back to an LLM on an unexpected return edge; [[Grep AI's AgentRun runs an AML alert once on a Pi agent, then compiles the trace into a DSL program whose decisions are typed Jev questions - 826 tool calls and 51 minutes become 30 and 3 minutes|Grep AI's AgentRun]] compiles a trace into a DSL where Jev answers the typed decisions and a verify clause escalates; ThruWire puts Jev at a checkpoint and attaches deterministic policy to the typed answer. In all three the shape is identical: Jev judges at a boundary, ordinary code decides what follows, and a frontier model handles the exception. Rosen names the shape directly in the embedded self-quote, calling it *"System 1.5"*.

*The ThruWire architecture diagram from the article's animated GIF: an Agent (labeled "Codex, Claude, etc") on the left sits entirely outside the ThruWire boundary on the right, which holds three Checkpoint nodes each with its own Validator. Solid arrows are the fixed checkpoint graph; the animated dashed arcs are the agent's round trips out to a checkpoint and back. In this frame the top checkpoint's round trip is lit.*
![[josharosen-734413-001.png]]

## Today's Toolbox

Rosen's framing is that a gap is opening between model reasoning and human monitoring, and his evidence is OpenAI's own admission on the Astra page: *"OpenAI recently reported that GPT-6 Astra's written reasoning was harder to monitor than GPT-5.6 Sol's, including a greater ability to accomplish work without verbalizing all of its reasoning."* The vault captured that same sentence from the source page in [[GPT-6 Astra swaps Codex compaction for notes across context windows plus searchable earlier windows including tool outputs]], which recorded it as a counter-signal OpenAI published anyway alongside the benchmark sweep, together with the fuller quote that the finding came from *"tests that explicitly asked it to evade monitoring"*. Rosen's use of it is fair but load-bearing: it is the single piece of external evidence for the premise that step-by-step watching is becoming a weaker control.

His taxonomy of what we have today comes in three groups.

**Before production.** Evals and simulations that test whether agents behave correctly across known and adversarial tasks.

**During execution.** Sandboxes, permissions, approval gates and deterministic checks that constrain what an agent can do, with Anthropic's [Claude Code sandbox](https://www.anthropic.com/engineering/claude-code-sandboxing) named as *"a good example of giving an agent freedom inside a deliberately constrained environment"* — the vault's note on that layer is [[Anthropic sandboxes Claude across three products with gVisor containers, OS syscall filters, and VMs because model-layer defenses cannot stand alone against injection attacks]].

**Watching and evaluating.** Tracing systems like [LangSmith](https://www.langchain.com/langsmith-platform) record what happened inside the run, while deterministic evaluators, LLM-as-a-judge and human review decide whether the behavior or output looks right, offline or [against production traces](https://docs.langchain.com/langsmith/online-evaluations-llm-as-judge). That trio is exactly the combination [[anthropic recommends combining deterministic graders model judges and human review for agent evals]] prescribes, so Rosen is describing consensus practice rather than a strawman.

**Or constrain the agent up front.** Workflows and orchestration encode the path as chains, routers, approval nodes and evaluator loops, with Anthropic's [workflows-versus-agents line](https://www.anthropic.com/engineering/building-effective-agents) as the reference.

His objection is a dilemma rather than a dismissal: *"we're usually either watching the execution, checking it, or constraining it. Give the agent too much unchecked freedom and important decisions can disappear inside the run. Encode too much ourselves and we start giving up the capability we wanted from the agent in the first place."*

## Checkpoint But Don't Smother

The proposition, bolded in the original:

> do whatever you want, however you want, as long as you can prove these X number of things happened along the way.

ThruWire separates the work from whatever is executing it. The executor can be *"Claude or Codex, a custom agent, several agents working together in a software factory, a deterministic process, a human, or some combination of them"*, and ThruWire *"doesn't need to own the agent loop or prescribe every tool call"*.

The exact definition of a checkpoint, twice over:

> ThruWire defines checkpoints in the work: durable states the work needs to reach, along with the artifacts, provenance, evidence, and other receipts it has to leave behind.

> A checkpoint defines a state the work needs to reach without defining exactly how the worker gets there.

His three worked examples of what a checkpoint requires: a research checkpoint needs *"a set of claims grounded in evidence"*; a software checkpoint needs *"an implementation tied back to its requirements with verification attached"*; a customer workflow needs *"an extracted requirement connected to the exact conversation from which it was derived"*. All three are relational, which is the load-bearing property — each requires a link back to a specific upstream artifact, not just a well-formed output.

**What crosses the boundary.** When a worker reaches a checkpoint it *"publishes a candidate artifact with stable identity and relationships to the exact upstream artifacts it used"*. ThruWire validates the artifact and those relationships before accepting it, returns validation feedback to the worker when something is wrong, and preserves the history.

**How the enforcement works.** Three named mechanisms: *"goal-defining blocks, provable relationships between artifacts with attestation, and server-side schema enforcement and validation"*. Rosen's own summary is that this makes it *"not only a receipt system but a self-describing obstacle course for the agent"*. Server-side is the operative word, since it is what makes the contract unfakeable by the worker.

The typed-artifact-plus-provenance model is the same governance argument [[a file system is not all you need - databases beat markdown for agent context provenance and governance]] makes for agent context, arriving at the same conclusion from the storage side rather than the workflow side.

## Jev at the Checkpoint

What ThruWire already had before Jev was structural: which artifact should exist, which upstream work produced it, what evidence came with it, and whether the worker satisfied the structural requirements. What it lacked, in Rosen's words including his own typo:

> What we didn't have was a true decision model that couldco evaluate every artifact against the fuzzier parts of that contract without turning the checkpoint into another expensive LLM step.

**The questions Jev is asked at the boundary.** To what degree the evidence supports the claim; whether an implementation satisfies its requirement; whether something extracted from a conversation really represents a requirement. Rosen never names the Jev primitive behind these. Two of the three are yes/no in shape and would map to a Noul, the first is a degree question and would map to a Score, but that is inference, not something the article states. Compare [[Annabell frames TypeSafe's Jev as a savant for eval verdicts and routing - three question types, 255 choices, 10 score levels, and a Noul with no confidence field|Annabell's breakdown of the three question types]] for what the choice actually costs you.

**What changes on the answer.** The gate itself moves from absolute to probabilistic. Before Jev, *"the semantics around advancing the work were mostly absolute: this artifact exists, this relationship is valid, this evidence is present."* After, *"the model can also say that an artifact should advance only if there is sufficient probability that the evidence supports the claim, or that an implementation satisfies its requirement."* Rosen's framing of the benefit is that it *"lets the checkpoint model express gray areas without giving up the contract"*.

**Three routes for an answer, not one.** From the data section: *"Some of those results can become policy, some can steer the agent, and others can simply become useful data attached to the model of work."* So the answer can gate, steer, or simply be recorded. On a failing gated answer the article does not describe a route to a human or a frontier model; the only failure path described anywhere is the pre-existing structural one, *"returning validation feedback to the worker when something is wrong"*, which implies the worker retries. Whether a low-probability Jev answer produces the same feedback-and-retry loop is not stated.

**What "semantic processing right at that boundary" means versus an LLM judge at the same boundary.** Rosen's differentiator is three-part and only the third is really about the boundary. First, cost and speed, asserted but unquantified. Second, the output shape: Jev *"returns typed semantic decisions that ThruWire can attach policy to"*, meaning the answer arrives as a typed value with a probability rather than prose a parser has to interpret. Third, placement in time: the judgment happens inline while the work is passing through, so its result can gate the advance and feed the next step, rather than being computed after the fact over a trace. An LLM judge can be wired at the same boundary and produce a structured verdict, so the first two differences are quantitative, not categorical, and the article supplies no quantity for either.

*The final frame of the same animation, with the bottom checkpoint's round trip lit instead. The loop cycles the highlight through each checkpoint in turn, illustrating that the agent makes a separate out-and-back trip per checkpoint rather than streaming through them.*
![[josharosen-734413-002.png]]

## Checkpoints as Data

Rosen's pivot is that *"validation and interpretation are close cousins"* — once a checkpoint can semantically validate work, it can ask anything else about that work *"without making the answer part of the gate"*.

**What data.** Characterizations of the work as it passes: whether a customer sounds confused, whether an objection is unresolved, whether an implementation appears to be drifting, whether something deserves human attention.

**What it is for.** Not evals and not training, at least not in this article. The stated consumer is ThruWire's *"renderers"*, which turn artifacts, relationships and evidence into *"purpose-built applications that users can interact with like apps rather than forcing them to inspect a pile of JSON"*. So the answer is human and agent comprehension, plus policy. Training data is never mentioned.

**Is there a flywheel claim.** Yes, but a soft one and only about volume: *"The more work that passes through checkpoints, the richer that data becomes."* That is accumulation, not a loop — nothing in the article feeds the accumulated data back into improving the classifier, the criteria or the model. A real flywheel would look like [[Sutro's jev-align uses GEPA to rewrite Jev's decision criteria from five labeled examples - the demo moves labeled-set ambiguity 49.6 points but full-pool certainty only 0.5|jev-align]] rewriting criteria from labeled outcomes, and Rosen does not claim it.

**The tension with his own prior position.** [[Josh Rosen argues context infrastructure should decide later - CortexDB and Statewave preserve raw history because the write path cannot know what will matter]] argued that the write path cannot know what will matter, so preserve raw history and decide later. Here he argues the opposite direction on the same axis: *"Instead of reconstructing what happened from agent traces after the fact, we can accumulate a semantic picture of the work as it happens."* The two reconcile only because the checkpoint keeps both — the durable artifact and its provenance survive alongside the semantic annotations, so the Jev output is additive rather than lossy compression of the run. That is the strongest form of "decide later" available here, and it is worth naming that Rosen does not address the tension himself. The same "make the semantic layer a first-class part of the infrastructure" instinct runs through [[Snowflake, Databricks and ClickHouse preview AI architecture by turning inference into a database operator, the semantic layer into agent infrastructure, and agents into a new database workload|his read of the data-platform vendors]].

## The Granola Experiment

**The task.** One meeting, already flowing through Granola and ThruWire to automate post-meeting work.

**The checkpoints defined.** Three, each deriving from the last: the source meeting; conversational sections derived from it; individual conversation moments derived from those sections.

**What Jev decided.** A Jev-enabled classifier in ThruWire accumulated semantic observations on each moment, asking three questions verbatim: *"Does this moment express a positive reaction? Is there material friction? Does it show confusion or a breakdown in shared understanding?"* These observations were explicitly not gating anything.

**What was measured.** The prose gives one quantity, *"hundreds of moments"*. The rest comes from the screenshot in the embedded tweet, which is the ThruWire renderer over this dataset:

| Quantity | Value |
| --- | --- |
| Moment artifacts | 420 |
| Conversation chapters | 13 |
| Positivity, overall | 0.23 |
| Negativity, overall | 0.04 |
| Confusion, overall | 0.06 |
| Smoothing window | 15-moment rolling average |
| Pinned example, moment 22 | Positivity 0.53, Negativity 0.00, Confusion 0.00 |

**What was not measured.** No ground truth, no human labels, no inter-rater agreement, no accuracy against any oracle, no latency, no cost, no comparison to an LLM classifier over the same 420 moments, and no second meeting. The pipeline also never exercises the article's central claim, since the classifier is deliberately outside the gate.

**The hedges, kept.** *"For this first experiment"*; *"to explore what happens"*; *"And this is just the starting point. There are a lot more things to try"*. Rosen is not overselling this one, and the honest reading is that it demonstrates the renderer and the data-accumulation claim, not the verification claim.

**Attribution caveat.** The screenshot and the embedded tweet are Seth Rosen's (@sethrosen), who is also building ThruWire and was Josh's co-founder at TopCoat. The article says *"we were already using Granola and ThruWire"*; the tweet says *"I was already using..."*. This is the same company demonstrating its own product, not independent corroboration.

*Seth Rosen's ThruWire renderer over the Granola meeting: a "Meeting Conversation Atlas" app titled "Conversation moments" showing 420 artifacts, three stacked time series for Positivity (overall 0.23), Negativity (0.04) and Confusion (0.06) on a 15-moment rolling average, a pinned moment card labeled "CUSTOMER - PROBLEM FRAMING" quoting "And then at the same time, like we're seeing heavy adoption." with per-dimension scores and an "Open this moment" button, and 13 conversation chapters along the bottom.*
![[josharosen-734413-003.jpg]]

## The Real Work Is the Connective Tissue

The conclusion, with his hedges intact:

> The more I work with Jev, the more convinced I am that the interesting architecture isn't System 1 or System 2 on its own. It's everything we build between them. We now have frontier models capable of doing increasingly open-ended work and decision models capable of making fast semantic judgments around that work. Neither tells us how to put the whole system together.

> The checkpoints, contracts, artifacts, context, policies, feedback loops, and other deterministic connective tissue are what let System 1 and System 2 work together. I suspect a lot of the hard engineering in the next generation of AI systems happens right there.

Note the hedge verbs: *"I think that becomes increasingly valuable"*, *"I suspect a lot of the hard engineering"*. The strong-form claim in the piece is architectural taste, offered as such.

## Replies

Two replies existed at capture; one was retrievable. Rosen posted no public reply to it as of capture.

Nicholas Price (@NickArcherPrice), 2026-09-21 22:44 UTC, asked the reliability question the article does not answer:

> @JoshARosen Thanks! Have you done any 'ThruWire/Jev-maxxing', such that you asymptomatically approach 100% reliability on something like a citation, or the interpretation of it? Running 1,000x checks — or something? Or other ways to kill hallucinations by throwing massive resources at it?

Worth noting that the one public question on the thread is precisely about whether repeated Jev checks at a checkpoint drive error toward zero, which is the calibration-and-thresholds question the article leaves open, and it went unanswered.

## Related

- [[moc - Jev]]
- [[TypeSafe's Jev trades string generation for parallel-sampled typed decisions with calibrated probabilities at $0.042 per MTok - the 193x and 444x claims come from four self-built workflow evals]] — the launch post Rosen links for "typed semantic decisions"
- [[Josh Rosen's Jev in the Wild sorts week-one projects into routing, context filtering, tool gating, worker supervision, fast control loops and fuzzy data queries - deterministic only because inference was expensive]] — his own landscape hub; this article is the product instance of its "worker supervision" pattern
- [[Josh Rosen argues context infrastructure should decide later - CortexDB and Statewave preserve raw history because the write path cannot know what will matter]] — the "decide later" thesis this piece both extends and pulls against
- [[Snowflake, Databricks and ClickHouse preview AI architecture by turning inference into a database operator, the semantic layer into agent infrastructure, and agents into a new database workload]] — Rosen on the semantic layer as infrastructure
- [[GPT-6 Astra swaps Codex compaction for notes across context windows plus searchable earlier windows including tool outputs]] — the monitorability admission Rosen's premise rests on
- [[Cua keeps the candidate menu in application code so Jev only picks an ID - CUA-S1-FORMS is a 706K-parameter form specialist at 99.7 percent against hosted Jev's 83.6, and neither model sees pixels]] — Jev judges, code decides, LLM handles the exception
- [[Grep AI's AgentRun runs an AML alert once on a Pi agent, then compiles the trace into a DSL program whose decisions are typed Jev questions - 826 tool calls and 51 minutes become 30 and 3 minutes]] — the verify-clause-and-escalate version of the same shape
- [[LangChain's Sydney Runkle puts Jev inside the agent loop as classifier middleware - ModelRouterMiddleware picks the model from the latest user message and AutoModeMiddleware reproduces closed harnesses' dangerous-action gate]] — Jev inside the loop instead of at the artifact boundary
- [[TypeSafe's SDE cascade gates escalation on any per-field Noul above 0.7 - the chart's y-axis is mean llm_judge and the frontier dominates only the two middle models]] — what a concrete Jev threshold looks like, and why a fixed one is contested
- [[LangChain's Jev-as-a-Judge bench puts Jev's quality-score variance 92 to 913x below three LLM judges at $0.34 against Claude's $28.17 - five weather traces, one human oracle, provider-default sampling]] — the cost and variance numbers Rosen asserts without citing
- [[Daniel Ch's How to master Jev prescribes a 0.85 and 0.55 confidence-gate ladder under an LLM that still writes - the decision-layer architecture is additive but every number and all three charts are TypeSafe's own]] — another gate ladder with undeclared provenance for its thresholds
- [[Sutro's jev-align uses GEPA to rewrite Jev's decision criteria from five labeled examples - the demo moves labeled-set ambiguity 49.6 points but full-pool certainty only 0.5]] — what closing the loop on checkpoint data would actually require
- [[Featherless's Simple Jev reproduces Jev's API on stock open models by remapping every answer to a single-token letter and softmaxing only those logits - no classifier head, and the code stamps every answer calibrated False]] — the hardest evidence that "sufficient probability" is not yet a calibrated quantity
- [[Annabell frames TypeSafe's Jev as a savant for eval verdicts and routing - three question types, 255 choices, 10 score levels, and a Noul with no confidence field]] — the three question types Rosen leaves unspecified
- [[simple-jev]]
- [[Harvey Spectre makes durable runs the core primitive while workers stay ephemeral and sandboxes enforce explicit boundaries]] — durable checkpointing of execution state, no Jev required
- [[LangChain Deep Agents runtime builds ten production capabilities on one primitive - durable super-step checkpointing to PostgreSQL]] — the same primitive at the runtime layer
- [[Opencomputer reframes harness-vs-sandbox debate as git branches for VMs via hibernation egress proxies and checkpoints]] — checkpoint-fork durability at the VM layer
- [[Archil makes the agent turn the unit of filesystem atomicity with copy-on-write checkpoints and branches]] — checkpoint as filesystem atomicity unit
- [[Browser Use stitches stateless Lambdas into multi-hour browser agents via S3 checkpoints and SQS continuations]] — checkpoint as continuation boundary
- [[training beats prompting so use runtime guards not instructions]] — constrain at the boundary, not in the prompt
- [[Anthropic sandboxes Claude across three products with gVisor containers, OS syscall filters, and VMs because model-layer defenses cannot stand alone against injection attacks]] — the sandbox layer Rosen cites
- [[anthropic recommends combining deterministic graders model judges and human review for agent evals]] — the evaluation trio his toolbox section restates
- [[a file system is not all you need - databases beat markdown for agent context provenance and governance]] — typed schemas and provenance as governance, from the storage side
- [[Company Brain Part 1 - Why Most Companies Have Data But No Memory]] — Granola as one of the four wedges converging on org-level memory

## Links

- [ThruWire](https://thruwire.ai/) — Rosen's product, the checkpoint system this article describes
- [OpenAI, GPT-6 Astra](https://openai.com/index/gpt-6-astra/) — source of the "harder to monitor" finding
- [Anthropic, Claude Code sandboxing](https://www.anthropic.com/engineering/claude-code-sandboxing) — freedom inside a constrained environment
- [LangSmith](https://www.langchain.com/langsmith-platform) — tracing platform cited as the watch-the-execution approach
- [LangSmith online evaluations with LLM-as-judge](https://docs.langchain.com/langsmith/online-evaluations-llm-as-judge) — judging against production traces
- [Anthropic, Building effective agents](https://www.anthropic.com/engineering/building-effective-agents) — the workflows-versus-agents distinction
- [TypeSafe, Introducing System One Models and Jev](https://typesafe.ai/blog/introducing-system-one-models-and-jev) — the "typed semantic decisions" the checkpoint attaches policy to
- Host tweet: [x.com/josharosen/status/2102107649705734413](https://x.com/josharosen/status/2102107649705734413)
- Embedded: [Seth Rosen on Jev + Granola + ThruWire](https://x.com/sethrosen/status/2101304951620145454)
- Embedded: [Josh Rosen, "build System 1.5"](https://x.com/JoshARosen/status/2102029360186196155)
- Animated diagram source: [video.twimg.com/tweet_video/HSwvjo8XcAAL5_k.mp4](https://video.twimg.com/tweet_video/HSwvjo8XcAAL5_k.mp4) (10.0s, 200 frames at 20fps, 1200x674, no audio track)
- Article cover image: [pbs.twimg.com/media/HSwlJf9X0AAQRMg.jpg](https://pbs.twimg.com/media/HSwlJf9X0AAQRMg.jpg) (2642x1057) — a decorative pen-and-ink illustration of a wire threading through three rings labeled CHECKPOINT, carrying no information beyond the title, so not embedded

## Original Content

> [!quote]- Josh Rosen (@JoshARosen), "Jev and AI Checkpoints: Using Decision Models to Wrangle Agent Work" — X Article, 2026-09-21 18:48 UTC, 65 likes / 5 RTs / 4 quotes / 136 bookmarks / 2 replies / 14,863 views
>
> **Host tweet** — https://x.com/josharosen/status/2102107649705734413
>
> > https://x.com/i/article/2102095156254023680
>
> ---
>
> # Jev and AI Checkpoints: Using Decision Models to Wrangle Agent Work
>
> *By Josh Rosen (@JoshARosen), article created 2026-09-21T18:48:13.000Z, host tweet https://x.com/josharosen/status/2102107649705734413, article id 2102095156254023680*
>
> AI is reaching an awkward point. We barely trust our agents today, and yet models are getting capable enough that we increasingly want to let them just do the work. If they are smarter than us, who are we to tell them how to work, right? Let them solve the problem and figure out what it takes to get there.
>
> But that should leave you uneasy. We can’t just hand over the work and hope for the best. Is it too much to ask that we can still check their work and, just as importantly, learn something about what happened along the way?
>
> There are signs that a gap is forming between model reasoning capabilities and us mere humans. OpenAI recently ⁠[reported that GPT-6 Astra’s written reasoning was harder to monitor than GPT-5.6 Sol’s](https://openai.com/index/gpt-6-astra/), including a greater ability to accomplish work without verbalizing all of its reasoning. It’s one example of a broader problem. As models get better, watching their execution step by step becomes a weaker way to understand and govern their work.
>
> We’ve been building ⁠[ThruWire](https://thruwire.ai/) in anticipation of this exact challenge. Instead of prescribing everything an agent does, ThruWire defines checkpoints in the work: durable states the work needs to reach, along with the artifacts, provenance, evidence, and other receipts it has to leave behind. Between checkpoints, the agent can "cook". At the checkpoint, it has to show its work.
>
> Then Jev showed up, and it fit this architecture almost perfectly. Checkpoints already give us a place to inspect the work before it moves forward. Jev lets us add fast semantic processing right at that boundary. It’s quick enough to understand something about the work, make decisions about it, record what we learn, and feed those observations back into what happens next without slowing down the agent.
>
> This is a look at how we got here, what Jev changes about the checkpoint, and what becomes possible once the checkpoint can understand the work.
>
> ## How We Try to Keep Agents on Track Today
>
> We already have a growing toolbox for keeping agents under control. Before production, evals and simulations test whether they behave correctly across known and adversarial tasks. During execution, sandboxes, permissions, approval gates, and deterministic checks constrain what they can do. Anthropic’s ⁠[Claude Code sandbox](https://www.anthropic.com/engineering/claude-code-sandboxing) is a good example of giving an agent freedom inside a deliberately constrained environment.
>
> We can also watch and evaluate the execution. Tracing systems like ⁠[LangSmith](https://www.langchain.com/langsmith-platform) record what happened inside the run, while deterministic evaluators, LLM-as-a-judge, and human review decide whether particular behavior or output looks right. These checks can happen offline or ⁠[against production traces](https://docs.langchain.com/langsmith/online-evaluations-llm-as-judge).
>
> Or we can reduce the problem by giving the agent less freedom in the first place. Workflows and orchestration encode more of the path ourselves: chains, routers, approval nodes, evaluator loops, and other predefined transitions. Anthropic draws this line explicitly between ⁠[workflows that follow predefined code paths and agents that dynamically direct their own process](https://www.anthropic.com/engineering/building-effective-agents).
>
> All of these approaches have a place, and most serious systems will combine them. But we’re usually either watching the execution, checking it, or constraining it. Give the agent too much unchecked freedom and important decisions can disappear inside the run. Encode too much ourselves and we start giving up the capability we wanted from the agent in the first place.
>
> ## Checkpoint But Don’t Smother
>
> ThruWire is built around a separation between the work and whatever happens to be executing it. It’s a simple proposition to the agent: **do whatever you want, however you want, as long as you can prove these X number of things happened along the way.**
>
> The execution can be Claude or Codex, a custom agent, several agents working together in a software factory, a deterministic process, a human, or some combination of them. ThruWire doesn’t need to own the agent loop or prescribe every tool call. Instead, it models the breadcrumbs that need to exist and the checkpoints through which the work progresses, giving the human enough visibility to stay comfortable and the process enough structure to stay on the rails.
>
> A checkpoint defines a state the work needs to reach without defining exactly how the worker gets there. A research checkpoint might require a set of claims grounded in evidence. A software checkpoint might require an implementation tied back to its requirements with verification attached. A customer workflow might require an extracted requirement connected to the exact conversation from which it was derived.
>
> *[Animated GIF at this position in the article — the ThruWire checkpoint architecture. An Agent labeled "(Codex, Claude, etc)" sits outside the ThruWire boundary; three Checkpoint nodes sit inside it, each with its own Validator. Solid arrows form the fixed checkpoint graph, and animated dashed arcs show the agent's round trip out to one checkpoint and back, cycling through them. Source mp4: https://video.twimg.com/tweet_video/HSwvjo8XcAAL5_k.mp4 — 10.0s, 200 frames at 20fps, 1200x674, no audio track. Two frames below: mid-loop with the top checkpoint lit, and the final frame with the bottom checkpoint lit.]*
>
> ![[josharosen-734413-001.png]]
>
> ![[josharosen-734413-002.png]]
>
> Between those checkpoints, the agent can cook. The requirement is to present ThruWire with the right-shaped artifacts at the right time, in a form it can validate and trust. ThruWire does this with a combination of goal-defining blocks, provable relationships between artifacts with attestation, and server-side schema enforcement and validation. Put together, it’s not only a receipt system but a self-describing obstacle course for the agent.
>
> When a worker reaches a checkpoint, it publishes a candidate artifact with stable identity and relationships to the exact upstream artifacts it used. ThruWire validates the artifact and those relationships before accepting it, returning validation feedback to the worker when something is wrong and preserving the history of what happened along the way.
>
> The result is a different kind of control. We don’t need to micromanage the agent or tell it how to clear every obstacle. Instead, ThruWire lets us define a clear contract for the work and leave the execution up to the agent.
>
> ## Jev Adds Semantic Processing to the Checkpoint
>
> Jev arrived at just the right time for this architecture. ThruWire checkpoints already gave us a strong contract around the work. We knew what artifact was supposed to exist, which upstream work produced it, what evidence came with it, and whether the worker had satisfied the structural requirements for moving forward.
>
> What we didn’t have was a true decision model that couldco evaluate every artifact against the fuzzier parts of that contract without turning the checkpoint into another expensive LLM step.
>
> Jev fits naturally into that job. Now we can establish that an artifact comes from the right upstream work and carries the required evidence, while also asking to what degree that evidence supports the claim, whether an implementation satisfies its requirement, or whether something extracted from a conversation really represents a requirement.
>
> Importantly, this lets the checkpoint model express gray areas without giving up the contract. Before, the semantics around advancing the work were mostly absolute: this artifact exists, this relationship is valid, this evidence is present. Now the model can also say that an artifact should advance only if there is sufficient probability that the evidence supports the claim, or that an implementation satisfies its requirement.
>
> Jev is particularly well suited to this because it returns [typed semantic decisions](https://typesafe.ai/blog/introducing-system-one-models-and-jev) that ThruWire can attach policy to. And that policy doesn’t have to be limited to whether the artifact passes or fails.
>
> ## Checkpoints Generate Useful Data
>
> Validation and interpretation are close cousins. Once a checkpoint can semantically validate work and reject it when necessary, it can just as easily ask what else is true about that work without making the answer part of the gate.
>
> That makes checkpoints useful for much more than validation. Jev can characterize the work as it passes through, such as whether a customer sounds confused, whether an objection is unresolved, whether an implementation appears to be drifting, or whether something deserves human attention. Some of those results can become policy, some can steer the agent, and others can simply become useful data attached to the model of work.
>
> ThruWire already had a powerful way to expose that data to humans. ThruWire “renderers” can turn the underlying artifacts, relationships, and evidence into purpose-built applications that users can interact with like apps rather than forcing them to inspect a pile of JSON. Jev gives those applications a whole new source of data.
>
> Every checkpoint can now generate new data about the work while the work is passing through. The same semantic processing we use to govern whether work moves forward can also help a human, or another agent, understand what is happening. The more work that passes through checkpoints, the richer that data becomes.
>
> Instead of reconstructing what happened from agent traces after the fact, we can accumulate a semantic picture of the work as it happens. As models get smarter and their execution gets harder for us to follow, I think that becomes increasingly valuable.
>
> ## We Tried It on a Granola Meeting
>
> A Granola meeting turned out to be a surprisingly good way to put this architecture together.
>
> We were already using Granola and ThruWire to automate work coming out of our meetings. We took one meeting and represented it as a series of three checkpoints: the source meeting, conversational sections derived from it, and individual conversation moments derived from those sections.
>
> For this first experiment, we used a Jev-enabled classifier in ThruWire to explore what happens when those moments also accumulate semantic observations. Does this moment express a positive reaction? Is there material friction? Does it show confusion or a breakdown in shared understanding?
>
> *[Embedded tweet at this position in the article — https://x.com/i/status/2101304951620145454, posted by Seth Rosen, Josh Rosen's ThruWire colleague and TopCoat co-founder, not an independent third party]*
>
> > **Seth Rosen (@sethrosen)** — 2026-09-19 13:38 UTC, 29 likes / 2 RTs / 1 reply / 8,908 views — https://x.com/sethrosen/status/2101304951620145454
> >
> > Jev + Granola + ThruWire ... mind blown
> >
> > I was already using Granola and ThruWire to automate outputs from my meetings but now with Jev I can look at a meeting over time across any dimension. Here I have positivity/negativity/confusion
> >
> > *Attached photo (2006x1116): the ThruWire renderer over the meeting dataset — "Meeting Conversation Atlas" / "Conversation moments", Artifacts 420, three stacked time series for Positivity (overall 0.23), Negativity (0.04) and Confusion (0.06), each a 15-moment rolling average; a pinned card labeled "CUSTOMER - PROBLEM FRAMING" quoting "And then at the same time, like we're seeing heavy adoption." with Positivity 0.53 / Negativity 0.00 / Confusion 0.00 at moment 22; 13 conversation chapters along the bottom.*
> >
> > ![[josharosen-734413-003.jpg]]
>
> Each moment gives us a few observations about one small piece of the conversation. Across hundreds of moments, we now have a new dataset about how the entire conversation unfolded. ThruWire can render that data as an interactive app where we can explore positivity, negativity, and confusion, then jump all the way back to the source behind any signal.
>
> And this is just the starting point. There are a lot more things to try now that checkpoints can generate this kind of semantic data as the work moves through them.
>
> ## The Real Work Is the Connective Tissue
>
> The more I work with Jev, the more convinced I am that the interesting architecture isn’t System 1 or System 2 on its own. It’s everything we build between them. We now have frontier models capable of doing increasingly open-ended work and decision models capable of making fast semantic judgments around that work. Neither tells us how to put the whole system together.
>
> *[Embedded tweet at this position in the article — https://x.com/i/status/2102029360186196155, Rosen quoting his own post from earlier the same day]*
>
> > **Josh Rosen (@JoshARosen)** — 2026-09-21 13:37 UTC, 440 likes / 22 RTs / 59 replies / 39,704 views — https://x.com/JoshARosen/status/2102029360186196155
> >
> > Our job is clear now: build System 1.5
> >
> > Connect System 1 (Jev) to System 2 (frontier reasoning models) using really good software architecture and deterministic connective tissue.
>
> The checkpoints, contracts, artifacts, context, policies, feedback loops, and other deterministic connective tissue are what let System 1 and System 2 work together. I suspect a lot of the hard engineering in the next generation of AI systems happens right there.
>
> ---
>
> **Replies** (2 at capture; 1 retrievable via bird, no Rosen reply surfaced)
>
> > **Nicholas Price (@NickArcherPrice)** — 2026-09-21 22:44 UTC — https://x.com/NickArcherPrice/status/2102167125972713785
> >
> > @JoshARosen Thanks! Have you done any 'ThruWire/Jev-maxxing', such that you asymptomatically approach 100% reliability on something like a citation, or the interpretation of it? Running 1,000x checks — or something? Or other ways to kill hallucinations by throwing massive resources at it?
