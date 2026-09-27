---
created: 2026-09-27
source: https://x.com/josharosen/status/2104201747732271519
author: Josh Rosen (ThruWire)
published: 2026-09-27
type: knowledge
tags: [jev, devops, sre, observability, opentelemetry, incident-response, ci, progressive-delivery, tool-gating, system-one-models, typesafe]
description: Rosen's fourth Jev piece surveys twelve projects across eight DevOps decision points, but the only controlled measurement in it is SREGym's 20 to 24 of 50, and the two vendor posts he leans on both contain results he does not mention.
---

# Josh Rosen's JevOps survey puts Jev at seventeen DevOps decision points - SREGym's 20 to 24 of 50 is the only controlled number, and Jev Logs' 99 percent recall comes from forwarding 99 percent

## Key Takeaways

- **One controlled number carries the entire piece.** SREGym ran ten Kubernetes incidents five times each in both conditions and got 20/50 baseline against 24/50 with Jev. That is four extra passes out of fifty, two problems regressed (3/5 to 1/5 and 4/5 to 3/5), two stayed at 0/5, and SREGym itself writes that five attempts per problem "are not enough to claim a general eight-point improvement." Rosen concedes the point in the article: "The architecture may be more important than the early benchmark." Everything else in the survey is a demo, a replay, or a vendor integration walkthrough.

- **Jev Logs' headline recall is a forwarding artifact, and its own benchmark says so.** Routing 99.3% of anomalous HDFS records toward analysis while filtering under 1% of total records means the system forwards essentially everything. The benchmark's author states it plainly: Jev's high HDFS recall "is mostly conservatism (almost never retain), not a demonstration that it found the rare bad line." The BGL 100% is not Jev at all, because a local ERROR/FATAL rule protected all 750 alerts before Jev was consulted, and a severity-only baseline also scores 100% there. The benchmark's own cost model concludes that Jev "does not pay for itself when it barely filters." This is the same threshold-versus-recall bind the vault already recorded in [[Applied Compute freezes a Sol-built 14-label taxonomy so Jev annotates the corpus - ECE 0.051 against Luna's 0.154 and 85 percent recall at 0.20, with every rival left at Jev's threshold]].

- **Cribl's post contains a loss Rosen does not mention.** He cites it for parser selection, but Cribl measured exactly that and Jev came last: 84.76% top-1 accuracy on a 28-logtype task against 92.38% for a purpose-built classifier and 95.71% for GPT-5.6 Terra, which Cribl describes as misclassifying 2-3x more often. The ">92% agreement" Rosen quotes is from a different experiment, and the committee is three frontier LLM judges over a 4,962-item intersection, not human reviewers. Jev's pairwise agreement with them runs 90.91% to 92.56%, just under the 92.54% to 95.00% the three judges manage with each other.

- **Datadog publishes no measurement whatsoever.** The post is an integration walkthrough against a fictional airline with a deliberately incomplete policy corpus and a ten-row dataset. There is no agreement figure, no span count, and no accuracy claim. Its closing advice is the opposite of Rosen's framing: measure Jev's agreement with human reviewers and its repeatability on your own traffic before relying on it. Same caution as [[LangChain's Jev-as-a-Judge bench puts Jev's quality-score variance 92 to 913x below three LLM judges at $0.34 against Claude's $28.17 - five weather traces, one human oracle, provider-default sampling]], which had one human oracle over five traces.

- **The ecosystem is eleven people.** The fourteen project links resolve to twelve distinct projects by eleven authors, two of them by the same person. Total GitHub stars across all eleven repos come to 76, four repos clear ten stars, and three sit at zero. Two links point at directory pages rather than the projects, one of those directories sells featured placements. Rosen sells ThruWire, "JevOps" is a term he is helping into existence, and he flags the softness himself: "mostly as a meme at this point," "Jev has been out for less than two weeks," "Most are small or experimental."

- **The shape is right even where the evidence is thin.** A fast typed decision running beside a reasoning agent, gating its actions and checking its evidence, is the same System 1.5 split Rosen named in [[Josh Rosen's ThruWire puts Jev at the checkpoint - prove X things happened however you like, and Jev scores the fuzzy half of that contract against the artifact not the trace]], the same verify clause as [[Grep AI's AgentRun runs an AML alert once on a Pi agent, then compiles the trace into a DSL program whose decisions are typed Jev questions - 826 tool calls and 51 minutes become 30 and 3 minutes]], and the same hand-back as [[Cua keeps the candidate menu in application code so Jev only picks an ID - CUA-S1-FORMS is a 706K-parameter form specialist at 99.7 percent against hosted Jev's 83.6, and neither model sees pixels]]. DevOps is a domain slice across four of the six patterns in [[Josh Rosen's Jev in the Wild sorts week-one projects into routing, context filtering, tool gating, worker supervision, fast control loops and fuzzy data queries - deterministic only because inference was expensive]], not a new pattern.

## The Thesis

Rosen's claim is that DevOps "is packed with exactly the kind of small semantic decisions Jev is built to make," and he lists them as questions: is this log worth investigating, does this incident look serious enough to wake someone up, is the proposed remediation broader than the evidence supports, did the repair actually solve the problem, which tests are relevant to this change. His argument is that tools already answer these questions, but have had to use "deterministic rules, specialized classifiers, humans, and increasingly LLMs," and that a cheap typed decision lets you make them "semantically, continuously, and at a much higher volume than was practical before." The reframing he wants is quantitative: "Instead of asking a model to reason through an entire incident, you can make thousands of smaller decisions as the incident unfolds."

He is careful about the status of the evidence. The term is "mostly a meme at this point." Jev "has been out for less than two weeks." The projects are "small or experimental," and there are "already enough to see a pattern" rather than enough to prove one. The closing is a projection, not a finding: DevOps "could move from a relatively small number of large reasoning steps to thousands or millions of small decisions happening continuously," and it "could be one of the first places where inference becomes a normal part of software infrastructure, distributed throughout the operational stack rather than isolated behind an agent or model endpoint."

That last sentence is the real thesis and it is an architectural one. It is also the part the evidence cannot yet reach, because none of the twelve projects runs at the volume the claim describes. The Jev Logs benchmark is the largest measured run in the survey at 6,840 calls and $0.15 of spend.

## The Eight Patterns

### 1. More Semantic Telemetry

Rosen opens with Cribl, which published two days after Jev's launch. He lists the places Cribl explored, parser selection, PII detection, alert triage, schema inference, and agent-response evaluation, and quotes one result: Jev "maintained more than 92% agreement with Cribl's committee of LLM judges at roughly 1% of the cost." He does not mention that Cribl's other headline experiment measured Jev losing to both alternatives on parser selection, the first item in his own list.

Cribl's framing is also narrower than his. Their conclusion is not that Jev is better, it is that "System One models don't make those decisions smarter, they make them cheap enough to make everywhere, which turns out to be the more useful property." That is a cost argument, and Cribl is explicit that the accuracy gap on semi-structured log data is "sizable."

In the vault: [[Josh Rosen's Jev in the Wild sorts week-one projects into routing, context filtering, tool gating, worker supervision, fast control loops and fuzzy data queries - deterministic only because inference was expensive]] calls this context filtering and routing. [[VictoriaMetrics is becoming the default observability stack for AI agent systems]] covers the pipeline this would sit inside. [[MotherDuck's prompt_jev labels 100k AG News rows in 40 seconds for 50 cents at 89 percent - a benchmark fine-tuned encoders beat by 5 points, metered at a 25 percent markup over TypeSafe list]] is the same finding in a different domain, cheap bulk classification that a purpose-built model still beats on accuracy.

### 2. Jev Moves Into OpenTelemetry

The densest section, and the one with the most measurement behind it. Jev Logs scores OpenTelemetry log records for diagnostic value before expensive analysis, and Rosen notes that "every record still goes to the normal archive." Its published benchmark "routed 99.3% of anomalous HDFS records and 100% of anomalous BGL records toward analysis, while filtering less than 1% of total records in both datasets." Read the second clause first: filtering under 1% means forwarding over 99%, so near-total recall is close to automatic. The number that would matter, how much noise still reaches the expensive path, is the retain precision, and the benchmark reports it on 21 HDFS records (0.7619) and 3 BGL records (1.0000). Those denominators are the whole story.

Jevernetes applies the idea to live Kubernetes logs with offline keyword rules as a fallback. Jevbrief compresses context before Jev sees it, and Rosen's example takes 1,447 OpenTelemetry records to 23 clusters to five candidates to one question. Jevmetrics judges metric metadata for relevance and redundancy and "starts in annotation mode so operators can inspect the assessments before allowing them to affect retention." Jevtraces does the same for spans, and its repository is blunter than Rosen is: it retains every span regardless of the probabilities returned, and warns not to read a low score as permission to discard.

In the vault: context filtering in Rosen's own taxonomy. [[Annabell frames TypeSafe's Jev as a savant for eval verdicts and routing - three question types, 255 choices, 10 score levels, and a Noul with no confidence field]] is why jevbrief exists, since Jev degrades as irrelevant state fills the window. [[agent production monitoring requires observing inputs and outputs not just system metrics]] and [[over 40 percent of agentic AI projects fail due to poor architecture not model limitations]] cover the OpenTelemetry substrate.

### 3. Evals Become Operational Signals

Datadog wired Jev into both of its evaluation surfaces, online evals that score production spans as they arrive and offline experiments over a dataset, with one rubric driving both. Rosen's framing is that focused questions replace open-ended judgment: whether claims are supported, what failure occurred, how severe the impact is, recorded beside latency, token usage, errors, and tool calls. His sharpest line is structural: "LLM-as-a-judge has often happened after execution. Low-latency decision models make some of those evaluations practical inside the live operational path."

The post itself is a tutorial. Nothing in it is measured. The agent is fictional, the dataset is ten rows, and the interesting artifact is a single real response where Jev picked `none` at 0.46 against `partial_answer` at 0.42 with confidence 0.34, which Datadog treats as a routing signal to a human rather than a verdict.

In the vault: worker supervision. [[LangChain's Jev-as-a-Judge bench puts Jev's quality-score variance 92 to 913x below three LLM judges at $0.34 against Claude's $28.17 - five weather traces, one human oracle, provider-default sampling]] is the closest thing to a controlled version of this. [[LangSmith Fine-Tuning's smithtune turns curated trajectories into LoRA SFT on Fireworks or Baseten and scores the student by replaying the teacher - OpenSWE precision up 19 points, recall unmoved]] is the next step, evals as training signal. [[every deploy should trigger a monitor-triage-fix loop that dispatches a coding agent to fix regressions before users notice]] and [[ramp built a self-maintaining agentic system with one monitor per 75 lines of code]] are the same loop built without a decision model.

### 4. SRE Agents In Second Loop

The one section with a controlled experiment. SREGym kept the agent doing the investigation and added Jev alongside it, ranking proposed diagnostic tests and checking evidence sufficiency before the agent submitted a diagnosis or declared mitigation complete. Ten incidents, five attempts each, 20/50 to 24/50, 40% to 48%.

Rosen's read is the right one and he says so: "The architecture may be more important than the early benchmark." The idea is "a second operational loop running alongside the SRE agent, continuously watching and evaluating the investigation without taking it over," which scales with how cheap the decision gets.

Worth keeping the shape of the result, not just the total. Four problems improved, two regressed, two never passed in either condition, and one passed five out of five both ways. SREGym's own diagnosis of the failures is that Jev "accepted evidence of current functionality without fully testing the invariant that made the repair durable," and that ranking cannot recover a hypothesis the agent never proposed.

In the vault: worker supervision, and the same verify-clause architecture as [[Grep AI's AgentRun runs an AML alert once on a Pi agent, then compiles the trace into a DSL program whose decisions are typed Jev questions - 826 tool calls and 51 minutes become 30 and 3 minutes]] and the hand-back in [[Cua keeps the candidate menu in application code so Jev only picks an ID - CUA-S1-FORMS is a 706K-parameter form specialist at 99.7 percent against hosted Jev's 83.6, and neither model sees pixels]]. [[Josh Rosen's ThruWire puts Jev at the checkpoint - prove X things happened however you like, and Jev scores the fuzzy half of that contract against the artifact not the trace]] is Rosen's own name for the split.

### 5. Semantic Gates on Actions

The argument is that authorization answers a different question than the one that matters: "Traditional authorization still determines what the agent *can* do, while Jev can continuously evaluate whether an allowed action makes sense in context." The demonstration is dsh-jev inside DeepSeek Harness, where an agent proposes a broad network-policy change that would restore connectivity while also exposing PostgreSQL, and Jev catches the blast radius before it executes.

Two things Rosen leaves out. The demo is a labelled replay of recorded model calls with no live replanning, and the repository documents a false positive in the same run, a harmless reset that got blocked. The second omission matters more: SREGym explicitly did not run this experiment and says a safety evaluation "would need explicit unsafe-action labels and controlled measurements, not an inference from these pass rates." The one group with a controlled harness declined to make the claim this section makes from a demo.

This is also where the vault's calibration finding bites hardest. A gate is a threshold on a probability, and [[Applied Compute freezes a Sol-built 14-label taxonomy so Jev annotates the corpus - ECE 0.051 against Luna's 0.154 and 85 percent recall at 0.20, with every rival left at Jev's threshold]] measured 21% recall at the default threshold despite good calibration, while [[Praneeth Paikray measures Jev's calibration for the first time - ECE 0.173 and Brier 0.156 lose to a TF-IDF baseline, and GEPA nearly halves the probability error]] found Jev worse calibrated than logistic regression. To their credit the serious projects here do publish thresholds: SREGym gates at 0.70, Datadog pins the model version because "the thresholds were calibrated against this exact version," the incident router uses 0.75 and 0.70 and calls them illustrative, and Jev Logs publishes a sensitivity curve. The hobby demos do not.

In the vault: tool gating. [[LangChain's Sydney Runkle puts Jev inside the agent loop as classifier middleware - ModelRouterMiddleware picks the model from the latest user message and AutoModeMiddleware reproduces closed harnesses' dangerous-action gate]] is the same gate in a framework. [[training beats prompting so use runtime guards not instructions]] is the general principle. [[Daniel Ch's How to master Jev prescribes a 0.85 and 0.55 confidence-gate ladder under an LLM that still writes - the decision-layer architecture is additive but every number and all three charts are TypeSafe's own]] is the threshold ladder written down.

### 6. Incident Response Decomposition

Rosen frames incident response as "a large reasoning problem surrounded by smaller judgments" and lists them: is this a real incident, how severe, what evidence to collect, is containment warranted, should someone be paged, is the service recovered. Three projects decompose it. Jev-oncall judges alerts while ordinary code decides paging, review, or suppression. An incident router uses exact ownership data when available and Jev only when routing needs interpretation, sending low-confidence answers to a review queue. A security-operations repository spans triage, investigation, mitigation, escalation, recovery, and closeout, and Rosen notes it "stops short of executing the proposed actions itself."

The design discipline is consistent and good: exact facts stay in code, Jev handles only the interpretive gap, and uncertainty routes to humans. The evidence is not. Jev-oncall has one star and its own directory listing says the repository's latency and cost figures come from one synthetic-alert run and "do not establish routing correctness." The incident router runs on synthetic incidents. The security repository's fixture run, by its author's own description, checks that each request returns a typed answer and does not measure whether the answer is correct.

In the vault: routing. [[ramp built a self-maintaining agentic system with one monitor per 75 lines of code]] is a production version of this loop without a decision model, with a triage step that tunes or deletes noisy monitors.

### 7. CI and Semantic Selection

Jev-ci-pathfinder asks which allowlisted CI jobs are relevant to a change. Rosen is careful about the division: "The job inventory remains deterministic, always-on jobs remain always on, and dependency closure stays in code." The best line in the article is here, and it generalises past CI: "Many existing rules are approximations for judgments we previously could not ask directly."

The project has zero stars, defaults to dry-run, and its catalog entry records that no live CI run was performed in the review.

In the vault: routing and context filtering. [[Harrison Chase frames agent development as a Build-Test-Deploy-Monitor lifecycle wrapped by iteration and governance]] places this in the wider lifecycle.

### 8. Semantic Decisions During Deployment

Canary promotion is the cleanest fit in the survey, because the evidence is already collected and structured and something has to decide hold, promote, or roll back. The state-machine experiment keeps the machine deterministic and lets Jev choose only at model-eligible branches, and in the captured run "Jev first chose to hold at 5% traffic, then promoted the deployment through subsequent stages as more evidence arrived." The Temporal experiment splits responsibilities the other way: Jev picks the action, Temporal owns execution, retries, durable state, and human approval, and when the rollback initially times out "Temporal retries it without asking Jev to make the decision again."

That retry detail is the most transferable idea in the article. A decision made once should not be re-litigated because the infrastructure flaked, and keeping the decision and its execution in different systems is what makes that possible.

Both are demos. The state machine page replays sanitized JSON captured on 2026-09-20 across five synthetic scenarios and runs no model at all. The Temporal demo has zero stars and no license.

In the vault: fast control loops. [[Harvey Spectre makes durable runs the core primitive while workers stay ephemeral and sandboxes enforce explicit boundaries]] and [[Opencomputer reframes harness-vs-sandbox debate as git branches for VMs via hibernation egress proxies and checkpoints]] are the durable-execution and checkpoint substrate. [[lessons from building AI agents for financial services — sandbox skills streaming and eval at Fintool]] is Temporal in production for the same reason.

## The Projects

Twelve distinct projects behind fourteen of the seventeen links, plus the three vendor posts. Star counts and licenses fetched 2026-09-27.

| Project | Author / org | What it does | Numbers it publishes | License | Stars | Status |
| --- | --- | --- | --- | --- | --- | --- |
| Jev Logs (site, npm, HF benchmark) | reachjalil | Wraps an OpenTelemetry log exporter, scores diagnostic value before expensive LLM analysis, archive untouched | HDFS recall 0.9933 at 0.84% retain, BGL 1.0000 at 0.12% retain, retain precision 0.7619 (16/21) and 1.0000 (3/3), p50 968ms, 6,840 calls for $0.154 | MIT | 14 | Shipped, v0.3.0 on npm, with the survey's only rigorous benchmark |
| jevernetes | sunil-sadasivan | Live Kubernetes log tail in terminal or dashboard, flags events worth investigating, hands evidence to a coding agent, offline keyword fallback | None | Apache-2.0 | 11 | Shipped tool |
| jevbrief | Parth Komalwad | Compresses a source into a small briefing before Jev sees it, one reason code per dropped fact | web 100% to 100% at -57% tokens, json 89% to 100% at -48%, otel 83% to 100% at -96%, synthetic data, author calls them illustrations | MIT | 4 | Shipped, PyPI 0.1.0 |
| jevmetrics | ishantanu | OTel Collector metrics processor, judges metric metadata for retention, annotate mode first | None, states filtering effectiveness needs evaluation on your own telemetry | Apache-2.0 | 3 | Alpha |
| jevtraces | ishantanu | OTel trace processor, annotates spans for diagnostic usefulness, retains every span regardless | None | Apache-2.0 | 0 | Alpha |
| dsh-jev | buberlo | Jev decision layer for DeepSeek Harness, gates tools and actions pre-execution, the PostgreSQL example | None, a 66-second replay of recorded calls, one documented false positive | MIT | 25 | Demo, most-starred in the survey |
| jev-oncall | mingleiw | Four typed questions per alert, code routes paging, review, or suppression, fail-open defaults | Latency and cost from one synthetic-alert run, listing says they do not establish routing correctness | Not stated | 1 | Experiment |
| Jev incident router | kyle-chalmers | Registry first for exact ownership, Jev for interpretation, low confidence to a review queue | Thresholds 0.75 Choice, 0.70 Score, 0.70 Noul, 2.0 impact, all called illustrative, synthetic incidents | None | 7 | Demonstration repository |
| jev-usecases | kenhuangus | Six-stage security operations plus 20-plus other use cases, stops before executing actions | 27 runners returned a typed answer on fixtures, author states it does not measure correctness | MIT | 11 | Reference implementation |
| jev-ci-pathfinder | JevForge | GitHub Action, picks which allowlisted CI jobs to run, exports run_jobs and skip_jobs | None, dry-run by default, no live CI in the catalog review | MIT | 0 | Action, unproven |
| Jev deployment state machine | Manoj Mahalingam (StackToHeap) | Canary state machine where Jev chooses only among enabled transitions | Replays sanitized JSON captured 2026-09-20, five synthetic scenarios, no model runs on the page | Not stated | No repo | Demo page |
| jev-temporal-demo | thenoahhein | Temporal workflow owns the loop, Jev picks the next action, rollback survives worker death | check_recent_deploy 61%, rollback_deploy 75%, 18% error rate, all scripted | None | 0 | Demo |

Eleven distinct authors, 76 stars in total across the eleven repositories, four repositories above ten stars, three at zero. Two of the seventeen links point at JevList, an AI-assisted directory that states it does not run the projects it reviews, and one points at JevCases, which sells featured listings.

## The Three Vendor Posts

### Cribl

"What TypeSafe's Jev means for telemetry," by Connor Swanson and Jonathan Vengosh of Cribl's AI Research team, 2026-09-17. Two experiments.

The first is log-type classification, one of 28 common types including an "other" bucket to simulate out-of-domain data. Jev's most common failure is putting known types into that bucket. Top-1 accuracy:

| Model | Top-1 accuracy |
| --- | --- |
| GPT-5.6 Terra | 95.71% |
| Custom classifier | 92.38% |
| TypeSafe Jev | 84.76% |

*Top-1 accuracy on the 28-logtype classification task*
![[josharosen-271519-cribl-01.png]]

Cribl's summary of that gap: Jev "misclassifies events 2-3x more frequently than a purpose-built classifier or GPT-5.6 Terra." They attribute part of it to the task shape, 28 options being unusually many, and note Jev was "18x faster inference and 20x lower cost per prediction on this task."

*Cost against latency per call on the logtype task, with p50, mean, and p99 marks*
![[josharosen-271519-cribl-02.png]]

The second experiment is the one Rosen quotes, grading AI agent responses. Cribl's sentence in full:

> Another challenge we encounter daily on the AI Research team at Cribl is grading AI agent responses. Agent responses are long, nuanced, and rarely reducible to a deterministic scorer, so we decided on LLM-as-judge. It works, but it's a reasoning model doing a classification job. We pay frontier prices and wait on frontier latency to answer what amounts to a bounded question. Jev held >92% agreement with our committee of LLM judges at roughly 1% the cost.

The committee is three frontier LLMs, and the agreement matrix is over a 4,962-item intersection:

| Scorer | Jev | Claude Sonnet 5 | Gemini 3.6 Flash | GPT-5.6 Terra |
| --- | --- | --- | --- | --- |
| Jev | 100.00% | 91.48% | 92.56% | 90.91% |
| Claude Sonnet 5 | 91.48% | 100.00% | 95.00% | 92.54% |
| Gemini 3.6 Flash | 92.56% | 95.00% | 100.00% | 92.87% |
| GPT-5.6 Terra | 90.91% | 92.54% | 92.87% | 100.00% |

*Pairwise checklist agreement across all three jobs, same 4,962-item intersection for every pair*
![[josharosen-271519-cribl-03.png]]

Read the diagonal neighbours. The three LLM judges agree with each other at 92.54% to 95.00%, and Jev agrees with them at 90.91% to 92.56%. Jev is close to the inter-judge floor but under it on two of three pairs, so ">92% agreement with the committee" describes agreement with the committee's aggregate rather than with its members. No human oracle appears anywhere in the post, which answers the question the vault keeps asking: this is Jev replacing a committee of LLMs, not a committee of people.

*Cost against latency per scoring call, Jev against the three judges*
![[josharosen-271519-cribl-04.png]]

Cribl's own conclusion is a cost argument, not a quality one. Once a typed decision costs nothing, "the list of places to put one grows fast: parser selection, PII detection, alert triage, schema inference. We're evaluating that list now." Rosen reproduces that list as if it were a set of results.

### Datadog

"Using TypeSafe's Jev for evals in Datadog Agent Observability," by Fouad Wahabi, Alex Barksdale, and Miguel Tulla Lizardi, 2026-09-24. There is no experiment and no measurement in this post. It is a walkthrough of one rubric driving two surfaces, online evals that score live spans out of band and offline evals inside a Datadog experiment.

What was evaluated: a fictional airline support agent, Vega Air, answering tickets from a policy corpus with deliberate holes so some tickets have no grounded answer. How many spans: the experiment dataset is ten rows, and the online path is demonstrated rather than measured. Against what: five narrow questions in one request, two Nouls plus a Choice for failure mode, a second Noul pair, and a Score for customer impact. Agreement: not reported. The only percentage on the page is a 90% pass rate in a screenshot of the `jev_grounded` distribution, which is a UI illustration.

The real content is design guidance, and most of it is about thresholds. The model is pinned to `jev-1.13.0` rather than an alias because "the thresholds below were calibrated against this exact version, and an alias moves when a release ships." The composite verdict stays in application code because thresholds are "application policy rather than model judgment." Submitting the raw probability rather than a binarized verdict means "changing the threshold later" becomes a query change instead of a re-run. And a Choice question "always returns the option with the highest probability, so Jev never abstains," which is why the rubric has to carry an explicit `unclear` option.

The worked response is the most useful artifact, because the interesting part is a near-tie:

| Key | Answer |
| --- | --- |
| grounded | noul 0.63 |
| answers_question | noul 0.02 |
| offers_handoff | noul 0.99 |
| failure_mode | choice `none`, confidence 0.34, `none` 0.46 against `partial_answer` 0.42 |
| customer_impact | score 1.25, confidence 0.74 |

Datadog's reading: flattening that to the string `none` "throws the interesting part away," and a near-tie is "a natural trigger for routing the trace to a human reviewer." They also warn that Jev "loses accuracy as the state fills with material the question doesn't need," which is the context-rot finding in [[Annabell frames TypeSafe's Jev as a savant for eval verdicts and routing - three question types, 255 choices, 10 score levels, and a Noul with no confidence field]].

The closing caution is the sentence Rosen's section most needs: like any judge, Jev has known limitations, so measure its agreement with human reviewers and its repeatability on your own traffic before you rely on it.

*Five Jev eval metrics on one span with probability scores, thresholds, and judge model tags*
![[josharosen-271519-datadog-01.png]]

*The jev_grounded score distribution, a UI illustration showing a 90% pass rate*
![[josharosen-271519-datadog-02.png]]

*Traces faceted by jev_failure_mode, isolating one flagged as a partial answer*
![[josharosen-271519-datadog-03.png]]

*A Datadog experiment run, six Jev evaluators over ten scored records*
![[josharosen-271519-datadog-04.png]]

### SREGym

"Can Jev Make SRE Agents More Reliable?", by Jackson Clark, Saad Mohammad Rafid Pial, Yiming Su, and Tianyin Xu, 2026-09-17. The only controlled experiment in the survey.

Setup: Jev added to SREGym as a decision-support tool, ten SREGym-Lite problems, five attempts per problem per condition, 100 runs total. Both conditions used `gpt-5.6-luna` under the Codex harness. Two tools were exposed. `jev_plan` takes three to five competing hypotheses with a read-only test each, adds a bounded namespace snapshot, and ranks the tests. `jev_submit` reviews evidence before a diagnosis or a mitigation reaches the grader. Every required question must clear a probability of 0.70, and a rejection sends the agent back to gather new evidence rather than reword the claim.

| SRE problem | Without Jev | With Jev |
| --- | --- | --- |
| Request-filter CPU saturation | 2/5 | 4/5 |
| Namespace memory limit | 0/5 | 0/5 |
| Wrong pod selection | 3/5 | 1/5 |
| Local traffic policy | 0/5 | 3/5 |
| Network policy block | 1/5 | 2/5 |
| Duplicate PVC mounts | 4/5 | 3/5 |
| Misconfigured rolling update | 0/5 | 0/5 |
| Stale rotated credentials | 2/5 | 2/5 |
| Wrong DNS policy | 3/5 | 4/5 |
| Valkey authentication | 5/5 | 5/5 |
| **Total** | **20/50** | **24/50** |

*The decision loop: plan, test, diagnose, repair, with jev_submit gating both submissions*
![[josharosen-271519-sregym-01.svg]]

*Successful attempts per problem, with and without Jev*
![[josharosen-271519-sregym-02.svg]]

Where it helped: distinguishing a causal mechanism from believable noise. The 0/5 to 3/5 problem had baseline agents chasing OpenTelemetry errors and unrelated workloads while the real fault was an `internalTrafficPolicy` set to `Local` with the endpoint and frontend on different nodes.

Where it failed: Jev accepted evidence of current functionality without testing the invariant that made a repair durable, so agents restored service while leaving a namespace quota, a `maxUnavailable: 100%`, or an invalidated credential in a broken state. And ranking cannot rescue a hypothesis the agent never proposed.

Their own caveats are strong. Five attempts per problem "are not enough to claim a general eight-point improvement, and two problems did regress." The experiment measured pass rate, not time to diagnosis. The agent was a lower-cost model, and they want to know whether Jev "mainly lifts less capable agents or improves consistency across the board." Most relevant to Rosen's semantic-gates section, they have not evaluated Jev as a prospective safety reviewer, and say such an experiment "would need explicit unsafe-action labels and controlled measurements, not an inference from these pass rates."

Their summary: Jev "added useful friction before premature diagnosis and repair. But it is a decision aid, not an oracle."

## Replies

Not captured. The post showed four replies at fetch time. Two `bird replies --all` attempts were made from this session and both failed, the second timing out at 100 seconds with no output. No retry, to avoid rate-limiting the account.

## Related

Sits in [[moc - Jev]] as Rosen's fourth Jev piece, after the landscape hub, the ThruWire checkpoint note, and his contributions to the Data Agent and Agentic Memory threads.

The DevOps sections map onto four of the six patterns in [[Josh Rosen's Jev in the Wild sorts week-one projects into routing, context filtering, tool gating, worker supervision, fast control loops and fuzzy data queries - deterministic only because inference was expensive]]: telemetry and OpenTelemetry and CI are context filtering, incident response and CI job selection are routing, the dsh-jev demo is tool gating, evals and the SRE second loop are worker supervision, and canary promotion is a fast control loop. No new pattern appears here, which supports Rosen's own framing that this is a domain, not a category.

On calibration and thresholds, the gates in this article are only as good as the probabilities under them: [[Applied Compute freezes a Sol-built 14-label taxonomy so Jev annotates the corpus - ECE 0.051 against Luna's 0.154 and 85 percent recall at 0.20, with every rival left at Jev's threshold]] and [[Praneeth Paikray measures Jev's calibration for the first time - ECE 0.173 and Brier 0.156 lose to a TF-IDF baseline, and GEPA nearly halves the probability error]]. On the gate itself, [[LangChain's Sydney Runkle puts Jev inside the agent loop as classifier middleware - ModelRouterMiddleware picks the model from the latest user message and AutoModeMiddleware reproduces closed harnesses' dangerous-action gate]], [[TypeSafe's SDE cascade gates escalation on any per-field Noul above 0.7 - the chart's y-axis is mean llm_judge and the frontier dominates only the two middle models]], and [[training beats prompting so use runtime guards not instructions]]. On judging, [[LangChain's Jev-as-a-Judge bench puts Jev's quality-score variance 92 to 913x below three LLM judges at $0.34 against Claude's $28.17 - five weather traces, one human oracle, provider-default sampling]] and [[Daniel Ch's How to master Jev prescribes a 0.85 and 0.55 confidence-gate ladder under an LLM that still writes - the decision-layer architecture is additive but every number and all three charts are TypeSafe's own]]. On the model's own shape, [[TypeSafe's Jev trades string generation for parallel-sampled typed decisions with calibrated probabilities at $0.042 per MTok - the 193x and 444x claims come from four self-built workflow evals]] and [[TypeSafe's Advanced structure page makes instructions and criteria arbitrary JSON via EntryType's open key map - field, inspect, focus and not_for are convention, and the page quantifies nothing]].

## Not Yet Captured

Projects from this survey that would carry their own note:

- **Jev Logs benchmark** — https://huggingface.co/datasets/reachjalil/jevlogs-log-triage-benchmark — the most rigorous independent Jev measurement seen so far: threshold sensitivity, naive baselines, a GPT-5.6 Luna head-to-head, prompt-injection pairs, and a cost model that concludes against its own tool. Deserves a full capture.
- **SREGym** — https://sregym.com/blog/jev-sregym-lite — the only controlled Jev-in-the-loop agent experiment, with a per-problem breakdown and an honest failure analysis.
- **Cribl** — https://cribl.io/blog/what-typesafes-jev-means-for-telemetry/ — the first infrastructure vendor to publish a Jev loss alongside a Jev win.
- **Datadog** — https://www.datadoghq.com/blog/jev-evals-agent-observability/ — the reference pattern for probability-preserving eval submission and threshold-as-application-policy.
- **dsh-jev** — https://github.com/buberlo/dsh-jev — the most-starred project here and the clearest statement of the pre-step, tool-call, and routing gate layout.
- **jevbrief** — https://github.com/parthkomalwad/jevbrief — context compression as a first-class Jev concern, with a reason code per dropped fact.

## Original Content

> [!quote]- Original Content
>
> ### Host tweet
>
> **Josh Rosen** ([@JoshARosen](https://x.com/JoshARosen)) - 2026-09-27 13:29 UTC - 98 likes, 14 reposts, 4 replies, 141 bookmarks, 3 quotes, 7,149 views - Twitter Web App
>
> The tweet body is the bare article link, `https://x.com/i/article/2104175225092952064`. There is no commentary above the Article.
>
> ### Cover image
>
> Not embedded. The cover (`https://pbs.twimg.com/media/HTOgHckXAAA5TIq.jpg`, 2950x1180) is a pencil-sketch title card: a bolted sign reading "DevOps" with the D unscrewed and lying on the ground among loose screws while a crane lowers a J into its place. It is a visual pun on the title and carries no data, no diagram, and no text beyond the wordmark.
>
> ### Article, verbatim
>
> **JevOps: Early Signs Decision Models Are Transforming DevOps**
>
> By Josh Rosen ([@JoshARosen](https://x.com/JoshARosen)), article id 2104175225092952064, created 2026-09-27T13:29:25Z, host tweet https://x.com/josharosen/status/2104201747732271519
>
> DevOps may be one of the largest untapped use cases for decision models. We are already seeing early signs of what that could look like, with developers putting Jev into telemetry, incident response, SRE agents, CI, Kubernetes, and infrastructure tooling.
>
> The term “JevOps” has started floating around the ecosystem, mostly as a meme at this point. But the opportunity behind it is massive because DevOps is packed with exactly the kind of small semantic decisions Jev is built to make.
>
> Is this log worth investigating? Does this incident look serious enough to wake someone up? Is the proposed remediation broader than the evidence supports? Did the repair actually solve the problem? Which tests are relevant to this change?
>
> These are questions that many DevOps tools are already designed to answer, but until now have had to resort to deterministic rules, specialized classifiers, humans, and increasingly LLMs.
>
> Decision models offer another option: fast semantic decisions that can run directly inside operational systems. That means more of these decisions can be made semantically, continuously, and at a much higher volume than was practical before. Instead of asking a model to reason through an entire incident, you can make thousands of smaller decisions as the incident unfolds.
>
> Jev has been out for less than two weeks, and projects are already appearing across nearly every part of DevOps. Most are small or experimental, but there are already enough to see a pattern.
>
> Here is what people are building and what it tells us about where DevOps may be headed.
>
> ## More Semantic Telemetry
>
> Cribl was one of the first infrastructure companies to experiment publicly with Jev. Two days after launch, its AI Research team published an investigation into [what decision models might mean for telemetry](https://cribl.io/blog/what-typesafes-jev-means-for-telemetry/).
>
> The team explored several places where fast semantic decisions could fit into telemetry pipelines, including parser selection, PII detection, alert triage, schema inference, and evaluating agent responses. In the agent evaluation test, Jev maintained more than 92% agreement with Cribl’s committee of LLM judges at roughly 1% of the cost.
>
> Millions of events are constantly being classified, enriched, routed, prioritized, retained, or discarded. Many of those decisions are handled well by existing rules and classifiers, but others require semantic judgment that has historically been too expensive to put directly into the pipeline.
>
> ## Jev Moves Into OpenTelemetry
>
> Logs have attracted several experiments already. [Jev Logs](https://jevlogs.com/) puts Jev in front of expensive log analysis, assessing diagnostic value, priority, and whether deeper investigation is warranted. Every record still goes to the normal archive, while Jev determines whether it should also travel down the expensive analysis path.
>
> Its [published benchmark](https://huggingface.co/datasets/reachjalil/jevlogs-log-triage-benchmark) over sanitized HDFS and BGL logs successfully routed 99.3% of anomalous HDFS records and 100% of anomalous BGL records toward analysis, while filtering less than 1% of total records in both datasets.
>
> [Jev Logs also ships as an npm package](https://github.com/reachjalil/jevlogs/blob/main/package.json) and can wrap an existing OpenTelemetry log exporter, adding Jev assessments without changing the primary archive.
>
> [Jevernetes](https://jevlist.ai/projects/jevernetes) applies the idea to live Kubernetes logs. It highlights events that may deserve investigation, shows surrounding context, and can generate evidence for a coding agent. Jev is optional, with offline keyword rules available as a fallback.
>
> Another project, [jevbrief](https://pypi.org/project/jevbrief/0.1.0/), reduces operational context before Jev sees it. One example takes 1,447 OpenTelemetry log records, groups them into 23 clusters, narrows those to five candidates, and asks Jev which evidence best explains a checkout incident.
>
> The experiments now cover the other major OpenTelemetry signals as well. [jevmetrics](https://github.com/ishantanu/jevmetrics) examines metric metadata for operational relevance, redundancy, and whether a metric belongs in primary storage. It starts in annotation mode so operators can inspect the assessments before allowing them to affect retention.
>
> [jevtraces](https://github.com/ishantanu/jevtraces) does something similar for spans, assessing whether operations are likely to be useful for diagnosis, business-critical, and worth retaining. A separate experiment combines those annotations with OpenTelemetry tail sampling while maintaining a full archive branch.
>
> These experiments put decision models directly into the pipelines for all three major telemetry signals: logs, metrics, and traces.
>
> ## Evals Become Operational Signals
>
> Datadog’s Agent Observability team recently showed [Jev powering offline experiments and online evaluations](https://www.datadoghq.com/blog/jev-evals-agent-observability/) of production agent spans as they arrive.
>
> Instead of asking a generative model for an open-ended judgment, the example asks focused questions about whether claims are supported, what failure occurred, and how severe the impact is. The results can be recorded alongside normal telemetry.
>
> Agent traces already contain latency, token usage, errors, and tool calls. Jev can add semantic properties such as whether requirements appear satisfied, whether a policy violation occurred, or whether human review is warranted.
>
> LLM-as-a-judge has often happened after execution. Low-latency decision models make some of those evaluations practical inside the live operational path.
>
> ## SRE Agents In Second Loop
>
> [SREGym added Jev to an SRE agent](https://sregym.com/blog/jev-sregym-lite) working through Kubernetes incidents. The agent still investigated the system, ran commands, formed hypotheses, and performed repairs. Jev ran alongside it, ranking proposed diagnostic tests and checking whether enough evidence existed before the agent submitted a diagnosis or declared mitigation complete.
>
> Across ten incidents with five attempts each, the baseline agent passed 20 of 50 attempts. The Jev-assisted version passed 24 of 50, moving from 40% to 48%.
>
> The architecture may be more important than the early benchmark. The idea is that a reasoning model can stay focused on the open-ended investigation while a decision model continuously evaluates smaller questions around its work. 
>
> This creates the possibility of a second operational loop running alongside the SRE agent, continuously watching and evaluating the investigation without taking it over. As decision models get faster and cheaper, that loop could make many more decisions than would ever be practical with another reasoning agent.
>
> ## Semantic Gates on Actions
>
> Permissions can tell an agent whether it is allowed to take an action, but they cannot easily determine whether that action makes sense given the current situation. Jev can help here by evaluating proposed actions before they execute, usually in a high-risk production environment.
>
> The [dsh-jev project](https://github.com/buberlo/dsh-jev) explores this inside DeepSeek Harness. Its Kubernetes demo has an agent troubleshooting a broken network path while Jev evaluates proposed tools and actions against the current incident.
>
> In one demonstration, the agent proposes a broad network-policy change that would restore connectivity while also exposing PostgreSQL. The action may solve the immediate problem, but Jev identifies the broader risk before it executes.
>
> Traditional authorization still determines what the agent *can* do, while Jev can continuously evaluate whether an allowed action makes sense in context.
>
> That opens up a much richer set of runtime gates. Is this remediation proportional to the incident? Does this tool call match the current diagnosis? Is there enough evidence to justify a destructive action? Instead of trying to encode every situation into policy ahead of time, DevOps systems can evaluate the proposed action against the situation as it happens.
>
> ## Incident Response Decomposition
>
> Incident response contains a large reasoning problem surrounded by smaller judgments. Is this a real incident? How severe is it? What evidence should we collect? Is containment warranted? Should someone be paged? Is the service actually recovered?
>
> Several projects are decomposing incident response this way. [jev-oncall](https://jevcases.com/cases/jev-oncall/) assesses alerts while ordinary code determines whether the result leads to paging, review, or suppression.
>
> A [Jev incident router](https://github.com/kyle-chalmers/typesafe-jev-incident-router) uses exact ownership data when available and Jev when routing requires interpretation. Low-confidence answers go to a review queue instead of being automatically followed.
>
> A larger [security-operations experiment](https://github.com/kenhuangus/jev-usecases) applies Jev across triage, investigation, mitigation, escalation, recovery, and closeout. Each stage asks focused questions rather than handing the entire incident to one model, and the repository stops short of executing the proposed actions itself.
>
> These projects treat incident response less like one giant AI problem and more like a bunch of smaller, less consequential semantic decisions.
>
> ## CI and Semantic Selection
>
> [jev-ci-pathfinder](https://jevlist.ai/projects/jev-ci-pathfinder) brings the same idea into CI. It looks at a code change and decides which allowlisted CI jobs appear relevant.
>
> The job inventory remains deterministic, always-on jobs remain always on, and dependency closure stays in code. Jev handles the harder question of whether a particular change is relevant to a particular job.
>
> The same question appears across tests, security scans, deployment environments, canaries, rollout checks, and rollback decisions. Many existing rules are approximations for judgments we previously could not ask directly.
>
> ## Semantic Decisions During Deployment
>
> Deployment and progressive delivery are another natural fit for decision models. A canary rollout already collects evidence about errors, latency, traffic, and system health, but eventually something has to decide whether to hold, promote, or roll back.
>
> A [Jev deployment state-machine experiment](https://stacktoheap.com/demos/jev-deployment-state-machine/) puts Jev directly at those decision points. The state machine remains deterministic, while Jev evaluates the current canary evidence when the deployment reaches a model-eligible branch. In a captured run, Jev first chose to hold at 5% traffic, then promoted the deployment through subsequent stages as more evidence arrived.
>
> A [Jev and Temporal experiment](https://github.com/thenoahhein/jev-temporal-demo) applies the same idea to rollback. Jev looks at operational state and can choose to investigate a recent deployment or roll it back, while Temporal handles execution, retries, durable state, and human approval. In the demo, Jev identifies a recent deployment and chooses rollback as the next action. When the rollback operation initially times out, Temporal retries it without asking Jev to make the decision again.
>
> This opens up a richer version of progressive delivery. Instead of promoting or rolling back from a handful of fixed thresholds, a deployment controller can evaluate the broader state of the rollout at each transition. Is the canary healthy enough to promote? Is the degradation meaningful enough to hold? Does the evidence point strongly enough to this deployment to justify a rollback? The mechanics of deployment stay deterministic while the decisions between stages can become semantic.
>
> ## Early Signs of JevOps
>
> JevOps is still extremely early, but the opportunity is already visible. DevOps sits between enormous amounts of machine state and a much smaller number of consequential actions, creating countless points where systems have to decide what deserves attention and what should happen next.
>
> Decision models make it practical to put semantic judgment into more of those decisions. DevOps could move from a relatively small number of large reasoning steps to thousands or millions of small decisions happening continuously as systems operate. Every alert, deployment, tool call, incident, trace, and remediation is another opportunity for software to ask a narrow question before deciding what to do next.
>
> DevOps could be one of the first places where inference becomes a normal part of software infrastructure, distributed throughout the operational stack rather than isolated behind an agent or model endpoint.
>
> ### Replies
>
> Not captured. Four replies existed at fetch time. Two `bird replies --all` attempts failed, the second timing out at 100 seconds with no output. Not retried, to avoid rate-limiting the account.
>
> ### Supporting posts
>
> The Cribl, Datadog, and SREGym posts are third-party sources rather than this note's source. Their load-bearing content - every published figure, both data tables, the agreement matrix, the worked Jev response, and the sentences this note relies on - is quoted and reproduced under "The Three Vendor Posts" above, with their charts saved alongside this note. Full text stays at the publishers:
>
> - Cribl, "What TypeSafe's Jev means for telemetry," Connor Swanson and Jonathan Vengosh, 2026-09-17 - https://cribl.io/blog/what-typesafes-jev-means-for-telemetry/
> - Datadog, "Using TypeSafe's Jev for evals in Datadog Agent Observability," Fouad Wahabi, Alex Barksdale, and Miguel Tulla Lizardi, 2026-09-24 - https://www.datadoghq.com/blog/jev-evals-agent-observability/
> - SREGym, "Can Jev Make SRE Agents More Reliable?", Jackson Clark, Saad Mohammad Rafid Pial, Yiming Su, and Tianyin Xu, 2026-09-17 - https://sregym.com/blog/jev-sregym-lite

## Links

Source: https://x.com/josharosen/status/2104201747732271519

All seventeen links in the article, in order of appearance:

1. [Cribl, what decision models might mean for telemetry](https://cribl.io/blog/what-typesafes-jev-means-for-telemetry/)
2. [Jev Logs](https://jevlogs.com/)
3. [Jev Logs published benchmark (Hugging Face dataset)](https://huggingface.co/datasets/reachjalil/jevlogs-log-triage-benchmark)
4. [Jev Logs npm package](https://github.com/reachjalil/jevlogs/blob/main/package.json)
5. [Jevernetes (JevList entry)](https://jevlist.ai/projects/jevernetes)
6. [jevbrief (PyPI 0.1.0)](https://pypi.org/project/jevbrief/0.1.0/)
7. [jevmetrics](https://github.com/ishantanu/jevmetrics)
8. [jevtraces](https://github.com/ishantanu/jevtraces)
9. [Datadog, Jev powering offline experiments and online evaluations](https://www.datadoghq.com/blog/jev-evals-agent-observability/)
10. [SREGym added Jev to an SRE agent](https://sregym.com/blog/jev-sregym-lite)
11. [dsh-jev](https://github.com/buberlo/dsh-jev)
12. [jev-oncall (JevCases entry)](https://jevcases.com/cases/jev-oncall/)
13. [Jev incident router](https://github.com/kyle-chalmers/typesafe-jev-incident-router)
14. [Security-operations experiment (jev-usecases)](https://github.com/kenhuangus/jev-usecases)
15. [jev-ci-pathfinder (JevList entry)](https://jevlist.ai/projects/jev-ci-pathfinder)
16. [Jev deployment state-machine experiment](https://stacktoheap.com/demos/jev-deployment-state-machine/)
17. [Jev and Temporal experiment](https://github.com/thenoahhein/jev-temporal-demo)

Underlying repositories and pages resolved while building the project table:

- [reachjalil/jevlogs](https://github.com/reachjalil/jevlogs)
- [sunil-sadasivan/jevernetes](https://github.com/sunil-sadasivan/jevernetes)
- [parthkomalwad/jevbrief](https://github.com/parthkomalwad/jevbrief)
- [mingleiw/jev-oncall](https://github.com/mingleiw/jev-oncall)
- [JevForge/jev-ci-pathfinder](https://github.com/JevForge/jev-ci-pathfinder)
- [StackToHeap (Manoj Mahalingam)](https://stacktoheap.com/about/)
- [Datadog notebooks for the Jev rubric](https://github.com/DataDog/llm-observability/tree/main/typesafe-jev)
- [SREGym benchmark](https://github.com/SREGym/SREGym)

