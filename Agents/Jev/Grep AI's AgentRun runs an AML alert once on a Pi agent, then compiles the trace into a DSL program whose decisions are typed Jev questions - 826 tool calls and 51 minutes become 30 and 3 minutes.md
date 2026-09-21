---
created: 2026-09-21
source: https://x.com/miguelriosen/status/2101029313906987422
author: Miguel Ríos Berríos (Grep AI)
published: 2026-09-18
type: knowledge
tags: [jev, agentrun, harness-engineering, pi, dsl, workflow-compilation, aml, typed-decisions, system-one-models, grep-ai]
description: Grep AI's AgentRun harness runs a repetitive knowledge-work job once on a frontier agent built on Pi, keeps the trace and the agent's own reusable notes, and compiles the SOP into an AgentRun DSL program of twelve node kinds in which typed Jev questions make every closed decision, code does the arithmetic and routing, and small tuned agents run only where something must be looked up - demonstrated on a 24-card AML alert that went from 826 tool calls and 51 minutes to about 30 calls and three minutes, and on 1,000 alerts where cost per alert fell from $2.89 to $0.25 while an LLM compliance judge scored agreement up from 90 to 95 percent.
---

# Grep AI's AgentRun runs an AML alert once on a Pi agent, then compiles the trace into a DSL program whose decisions are typed Jev questions - 826 tool calls and 51 minutes become 30 and 3 minutes

## Key Takeaways

- **This is the fullest instance yet of the pattern the vault has been assembling piecemeal: an LLM generates the program once, [[TypeSafe's Jev trades string generation for parallel-sampled typed decisions with calibrated probabilities at $0.042 per MTok - the 193x and 444x claims come from four self-built workflow evals|Jev]] decides forever, and code controls.** Where [[Josh Rosen's Jev in the Wild sorts week-one projects into routing, context filtering, tool gating, worker supervision, fast control loops and fuzzy data queries - deterministic only because inference was expensive|Rosen's survey]] catalogued 25 projects that each insert Jev at one decision point in conventional software, AgentRun inserts it at *every* closed decision inside a whole procedure and gives the other steps their own node kinds. It is not in Rosen's list, and it uses five of his six patterns inside a single program: routing (the `route` card), context filtering (`sift`), worker supervision (the `verify` clause on any agent), tool gating (`escalate` plus per-run tool grants), and fast control loops (`loop until` with confidence predicates). The rule is stated as a slogan worth stealing: "Jev decides what a thing is; code decides what follows." The framing of the seam is credited to 12-Factor Agents, and it is the same move as [[LangChain's Paid Media Agent got 40x cheaper and 13x faster by moving calculations out of the model into code|LangChain's Paid Media Agent taking calculations out of the model into code]], one level up: not one calculation but an entire 508-line rulebook.

- **The compilation step is done by an LLM agent reading its own traces, and the only correctness check is an eval gate - which the article is unusually honest about being insufficient.** "After several runs, the agent uses the traces and notes from the previous runs to write a workflow in the AgentRun DSL." Which model authors the workflow is never named. Nothing verifies the program against the SOP; a candidate version "went live only after it beat the current version on the development set," and the piece then reports the failure mode of exactly that gate: "on the banking messages, the author eventually matched every development label and still scored the same on the reserved set, so the development score alone is not a promotion criterion." That is an admission that the compiler overfits its dev set, answered with a held-out set rather than with verification. Contrast [[Bridgewater's PAT treats agentic codegen as a compiler problem, turning 50 years of written-down investment logic into a deterministic AI analyst with a benchmark-gated Teach loop|Bridgewater's PAT]], which reaches for the same compiler framing on the same kind of written-down regulated logic but enforces correctness in the architecture and converts operator feedback into failing benchmarks.

- **The saving is not from Jev being cheap; it is from not reading pages, and the article's own bar chart proves it.** Of the final $0.25 per alert, about 30 Jev questions cost $0.003 - 1.2 percent. The other $0.244 is agents: $0.138 research, $0.044 Opus 5 fallback, $0.041 identity judge, $0.021 report. Ríos Berríos says it plainly: "The saving is in the 30% of cards that never opened." So the mechanism that pays is the *triage and early-stop routing* the program encodes, and Jev's contribution is making that routing affordable to ask per item rather than being the economy itself. This is the same lesson as [[Toast 1 takes over the search loop as a specialized subagent - 3.5x fewer tokens at identical Harvey-bench scores and OfficeQA SOTA at 1.15 dollars per task|Toast 1's 3.5x token cut]] - you win by not retrieving, not by retrieving cheaper.

- **Every gate in this system branches on a Jev probability, and the article asserts calibration without showing any.** It states the premise flatly - "a confidence that is calibrated, meaning a 0.7 is right about seven times in ten" - and builds policy on it: "clears below a chosen confidence go to review, and the threshold itself is versioned," "the threshold is a number in code, not a feeling," a worked answer of `{ could_stop_the_customer: 0.97 }`. No reliability diagram, no calibration curve, no held-out calibration metric appears anywhere. That inherits the vault's standing gap: [[LangChain's Sydney Runkle puts Jev inside the agent loop as classifier middleware - ModelRouterMiddleware picks the model from the latest user message and AutoModeMiddleware reproduces closed harnesses' dangerous-action gate|LangChain measured repeatability, not calibration]], [[Sutro's jev-align uses GEPA to rewrite Jev's decision criteria from five labeled examples - the demo moves labeled-set ambiguity 49.6 points but full-pool certainty only 0.5|jev-align ships no calibration metric]], Featherless stamps `calibrated: False`, and [[TypeSafe's SDE cascade gates escalation on any per-field Noul above 0.7 - the chart's y-axis is mean llm_judge and the frontier dominates only the two middle models|TypeSafe's own SDE cascade cookbook uses a flat 0.7 gate]]. A compiled program that routes a regulated decision on `p > threshold` is the highest-stakes consumer of that unverified assumption the vault has seen.

- **"Fire itself" is marketing; the agent is demoted to 1.5 percent of alerts and still spends most of the money.** Day two keeps four LLM jobs: research agents on the cards that stayed open, the judge agent escalation for "the card no question could settle," the identity judge on 8 percent of alerts, the report agent, and "human review where the SOP requires it." Fallback to the full agent ran "about one alert in twenty early on, about one in seventy over the last 300," settling at 1.5 percent. That is the same hand-back architecture as [[Cua keeps the candidate menu in application code so Jev only picks an ID - CUA-S1-FORMS is a 706K-parameter form specialist at 99.7 percent against hosted Jev's 83.6, and neither model sees pixels|Cua's escape hatch]] and the same division of labour [[Applied AI doesn't work because the time was never in the work - Varick maps Hammer's 1990 re-engineering critique onto enterprise agents and sorts every step into deterministic, agentic, or human|Varick prescribes]]: sort each step into deterministic, agentic, or human. The honest version of the thesis is the one in the closing line - "The model that can figure anything out is the most expensive thing in the building. Use it to write the program, and to catch what the program cannot."

- **Read the numbers as a vendor's single-procedure case study, because that is what they are.** One customer's AML procedure, 1,000 alerts, all instrumentation and all scoring by Grep AI. Accuracy is "the compliance judge," an LLM judge scoring agreement against historical labels, never a human adjudication; 90 percent came from the first two 50-alert batches and 95 percent from the last six, so the headline delta rests on roughly 100 versus 300 alerts at a batch granularity where binomial noise alone is a few points. The cost-per-alert chart labels the agent baseline $2.95 while the prose and the arms table say $2.89. The $290K-versus-$26K projection over 100,000 alerts is an extrapolation from the final rates, not a measurement. The mechanism is described in enough detail to be reimplemented and judged on its own; the arithmetic is not independently checkable.

## Let the Agent Fire Itself

The thesis, stated as a section heading: "let a smart agent do the job, then find a way to automate it as a workflow, so most cases never need the agent at all."

The loop has four beats.

1. **A job and an SOP.** "It starts with a job and an SOP, a standard operating procedure. The agent selects tools, writes code when it needs to, and finds a way to finish the job."
2. **Learning mode leaves notes.** "In learning mode, it also leaves notes about how it worked: which tools it used, what approach worked or failed, and any tips for the next agent to do the work more easily."
3. **The agent writes the program.** "After several runs, the agent uses the traces and notes from the previous runs to write a workflow in the AgentRun DSL, our language for workflows."
4. **Traffic shifts onto the program.** "As the workflow takes shape, the agent routes a subset of cases to it instead of doing the job itself... By the end of the run in the last section, 98 of every 100 cases go through the workflow, and the full agent handles the rest, the odd ones."

Two benefits are claimed: cost savings of "50-95% using workflows vs an agent with a frontier model," and inspectability, because "humans can inspect the workflow by looking at specific steps, their inputs, outputs, and routing logic instead of having to deduct these from agent traces and chain-of-thought."

**The shape of the program** is the seam the whole design follows, credited to 12-Factor Agents. "Take a tool call apart and there are two things inside: a decision, which action and with what arguments, and an action, the code that carries it out. Nothing about the decision needs a text generator. It needs something that can pick an option well and say how sure it is." Hence: "An agent where something must be found or done in the world. A typed question where something must be decided. Plain code where the step is mechanical. And a handful of shapes that hold the three together."

The problem being solved is governance as much as cost. Grep AI's customers "perform repetitive knowledge work in a regulated space, thousands of times a day." Around 95 percent of AML alerts are false positives; an analyst spends "the better part of an hour on one alert"; a frontier-model agent does it "for about $3 an alert." Scripts break "the first time a source changes its pages," and agents are "expensive and hard to govern."

## Built on Pi

AgentRun does not implement its own agent loop. "Our harness is built on top of Pi. We use their loop for the general agent and the agents inside our workflows. Around it, AgentRun provides the instructions, tools, skills, workspace, budgets, and output requirements."

So the borrowing is precise and narrow: **the loop only**. Pi is Mario Zechner's coding agent, the same project whose design philosophy the vault holds in [[coding agents should be personal canvases not uniform tools]] - and the same project that already hosts a Jev decision layer in `pi-warden`, the tool-gating entry in Rosen's survey. Everything around the loop is AgentRun's: the model router, the skills and workspace, the Executor tool gateway, the typed result contract, the run traces, and the case notes.

The architecture diagram (image 001) names the parts. Notable in it and in the text:

- **Executor, the tool gateway.** "Executor, connects the agent to hundreds of tools for web research, registries, and other work. Each run gets the tools it's allowed to use. The gateway also supports tool discovery, so we can expose a large catalog without putting every tool definition into every prompt."
- **A three-year skill library.** "We have been building our skill library for three years, most of it for compliance work. The same authoring and evaluation system we use for those skills is the one our users get to build skills for their own Grep.ai agents."
- **Traces and notes.** "We save the tool calls, results, submissions, errors, and usage for each run. In the tuning process, each case has a JSONL trace file and a ledger entry with its outcome, cost, and latency."
- **The learned lesson is one to three sentences.** "When learning is enabled, we ask the agent to write its most reusable lesson into the workspace. A note might say that a particular registry website found the company when web search didn't, or that a page required a browser because a fetch couldn't expose the information. One to three sentences is enough." This is the [[Autobrowse iterates browser agents to convergence then graduates the winning strategy into a durable SKILL.md, ending the per-site rediscovery tax|Autobrowse move]] - graduate one expensive exploration into a durable artifact - and the failure it has to dodge is the one [[ProcMEM - Learning Reusable Procedural Memory from Experience via Non-Parametric PPO for LLM Agents|ProcMEM]] names: experience stored as passive narrative is not an executable decision procedure.

**Lineage correction worth recording:** the "Claude in a box" link in the opening paragraph is not a sandbox layer under AgentRun. It is Grep AI's *previous* harness - "Claude in a Box: Building Grep on the Agents SDK," a post about running production entity-research agents on the Claude Agent SDK with their compliance expertise loaded as skills. AgentRun is the successor to it, and the arc in the first paragraph is React agent on Claude 1, then Celery/Temporal workflows, then Claude Agent SDK, then AgentRun.

## The AgentRun DSL and Node Types

"The AgentRun DSL is the small language that gives them names: a few kinds of agent, plain code, the shapes that hold steps together, and, newest, a way to ask a typed question and get a calibrated answer. The agent that authors a workflow plays the same twelve cards we play by hand."

**Twelve cards, four kinds.** From image 002, verbatim on the cards: four green `AGENT` cards - Research ("searches, reads, browses, cites"), Judge ("reads it all when the question is hard"), Report ("renders the record, never re-decides"), Operator ("the only agent that writes: browser and write tools, files the paperwork"). Four purple `JEV` cards - Route ("which path does this case take?"), Classify ("a typed question, a calibrated answer"), Sift ("yes or no for each item; keep the yeses"), Pick ("compare the items; choose one, or none"). One `CODE` card - Code ("parse, count, compare, decide"). Three `FLOW` cards - Map / Reduce ("the same step over every item, then fold the answers into one"), Loop until ("repeat, bounded, stop on a condition"), Escalate ("when confidence is low, route the case to an agent").

**The agents**, verbatim on what each is for:

- **Research** "searches, fetches websites, and drives a browser through multi-page sites and logins. We tuned it for accuracy at low cost. Today it runs on DeepSeek V4.1 Flash, and it has completed nearly every research task we have given it."
- **Judge** "reads everything when the question is hard. It takes the procedure and the evidence and makes a supported determination... We give it a smarter model and let it open a source to verify a claim. It is also the agent the rest of the workflow escalates to."
- **Report** "renders the record into the document the customer receives. It never re-decides. If a report is wrong, the separation tells us whether the fault was in gathering the facts, judging them, or writing them up."
- **Operator** "is the only agent that writes outside of the sandbox. It acts in the world: fills the portal, files the paperwork, submits the case to the system of record... it runs under the tightest tool grants and every action is on the trace."

**Code and mechanical steps.** `code` does "the arithmetic of ages and dates, the tally of discrepancies, the rule that says two of these make a stop." A `call` "performs one external action with no model in the loop." An `artifact` "declares the deliverable and checks that the promised file exists." The one code block in the article is a `call` polling spec, verbatim:

```json
{
  "deadline_s": 15,
  "poll": {
    "until":     { "predicate": "field_equals", "path": "status", "value": "completed" },
    "fail_when": { "predicate": "field_equals", "path": "status", "value": "failed" },
    "interval_s": 5,
    "deadline_s": 120
  }
}
```

"The engine waits five seconds between checks, allows up to 15 seconds for each call, and stops polling after two minutes."

**The shapes that hold them together.** "Steps run in a **chain**. **Map / Reduce** runs the same step over every item of a list at once, then folds the answers into one: twenty-four cards researched in parallel, one verdict. **Loop until** repeats a body within a bound and stops on a condition the state can answer: until nothing left can change the rating, at most three waves. **Escalate** routes a case off the cheap path, to the judge agent when a question is hard, or to a person with the record when the procedure requires review. It is the shape that makes the rest safe to run cheap." Between steps, "We pass structured records between steps. Nodes declare required inputs, and the engine checks every submission against its schema."

This is the same split [[separating cognitive blueprints from runtime engines enables portable auditable agent systems|blueprint-versus-engine]] argues for on auditability grounds, and mechanically the nearest thing in the vault is [[Claude Code dynamic Workflows synthesize a per-task agent harness at runtime opening a third scaling axis|Claude Code's dynamic Workflows]], where a model likewise authors an orchestration program and code holds control flow and state.

## Jev Nodes - Decisions as Typed Questions

"AgentRun is the first harness built around Jev, TypeSafe's System One model, and it is the first time classification inside a procedure gets its own engine."

What Jev is doing here, verbatim: "Jev does not write text. It answers typed questions over a structured state: a choice among named options, a yes/no, a score on a scale, each with a probability distribution and a confidence that is calibrated, meaning a 0.7 is right about seven times in ten. An answer takes about 150 milliseconds and costs a few hundred-thousandths of a dollar."

What it replaced: "Before we had anything better, a constrained LLM call with a schema did them: cheap, but a language model all the same. It answers with a label and no calibrated sense of how sure it is, and it has to be prompted again for every new case."

**The four cards, verbatim:**

- **Route** "is a choice among branches of the workflow. Each branch carries the criteria under which the procedure takes it, and an 'unsure' branch for when no option is confident."
- **Classify** "compiles an output schema into questions. Every enum becomes a choice, every boolean a yes/no, and the criteria the author writes for each option are the criteria Jev applies. The values land in the workflow state; the probabilities land beside them, so the code that follows can ask not only what but how sure. (In the DSL this is the judge node.)"
- **Sift** "asks the same yes/no of every item in a list in one request and keeps the ones that pass: which of these sources is about our subject."
- **Pick** "compares the items and chooses one, or none: which of these records is our customer."

**Two cardless uses.** The `verify` clause is the more interesting: "A verify clause on any agent turns the agent's own output schema into a checklist: when the agent submits, Jev reads the submission against the evidence the agent cited and answers, per field, whether the evidence supports the claim. A submission that fails comes back to the same agent session with exactly the fields it could not support, and the agent keeps working; claims still unsupported after the last round are removed before anything downstream sees them." That is Rosen's worker-supervision pattern made a language feature, with the important difference that unsupported claims are *deleted* rather than flagged. Second: "predicates on loops and escalations let a confidence gate a retry or a hand-off to review."

**The rule.** "**Jev decides what a thing is; code decides what follows.** A hit's name link is a nickname or it is not; its location is a different country or it is not; the arithmetic of ages and dates and the counting of discrepancies is code." Two consequences are claimed: decisions are auditable "because every rating names the questions and probabilities it rests on," and replayable "because the answers are retained: we can change the code that reads them and re-run the judgment of a thousand cases in two minutes for a few cents, with no agent and no model call. Auto-tuning the judgment stops being a series of runs and becomes a replay."

**What a Jev question looks like.** "Jev never sees the procedure. It gets one question with the bank's criteria written into it, and one card." The request for "could this card stop the customer," verbatim and simplified by the author:

```
state:
  hit:      { name, screenType, events: ["... drug trafficking ... sentenced ..."], country }
  customer: { name, dob, job }
 
question could_stop_the_customer (yes/no):
  instructions: Could this profile floor the case at HIGH under the bank's procedure
                if it is the customer? HIGH floors are: a sanctions designation;
                a senior national PEP or a family member of one; a conviction for a
                serious offence (trafficking, violence, sexual offences, terrorism,
                organised crime, major fraud). Ordinary adverse media, regulatory
                matters, arrests without conviction, minor offences cannot.
  true:  a sanctions designation, a senior PEP or relative, or a serious conviction
  false: ordinary adverse media, regulatory or civil matters, arrests, minor offences
 
answer: { could_stop_the_customer: 0.97 }     126 ms, $0.00004
```

Three things to note about that form. The state is a typed record, not prose. The criteria are written per-outcome (`true:` / `false:`), which is exactly the surface [[Sutro's jev-align uses GEPA to rewrite Jev's decision criteria from five labeled examples - the demo moves labeled-set ambiguity 49.6 points but full-pool certainty only 0.5|jev-align rewrites with GEPA]] - though neither jev-align nor GEPA is mentioned anywhere in this article. And the answer is a bare probability: "The answer is a probability, not a label, so a 0.44 can be treated differently from a 0.97, and the threshold is a number in code, not a feeling." Policy edits are cheap: "If the bank adds a rule tomorrow, it is a line in that list, and the change replays over every past card in minutes."

## Evaluation and Auto-Tuning

"Every card in a workflow has one model, one input contract, and one output schema. That is what makes it evaluable on its own... We freeze the evidence the decision was made on and change only the thing under suspicion. We never run the whole investigation again for every experiment."

**Evaluating a Jev node is a replay over a table, not a rerun.** "The judgment in the alert review is 21 typed questions. Every answer and its probability is kept with the case, so the judgment of a thousand alerts is a table we can re-run without an agent and without a model call: change the code that reads the answers, replay, compare." The worked instance: "When we rewrote the verdict rules to follow the rulebook clause by clause and deleted thirteen special cases, the replay showed the same rating on all 868 hits in two minutes for a few cents." The diagnostic for a bad question: "the one with the lowest confidence on the cases we got wrong is the one whose criteria need rewriting, and we can test the rewrite on the same table." And a governance bonus: "A Jev question set is also something a compliance officer can read. It is the rubric, stated once, in the bank's own words."

**Evaluating an agent is on hand-off, not on process.** "The research agent is judged on what it hands over, not on how it got there. Did the judge downstream have the facts the rulebook needed, or did a case escalate because a fact was missing? Did the verify pass hold up: how often did Jev send a submission back, and for which fields?" That pair of numbers gated a model swap: "When we switched the research agent from a frontier model to DeepSeek V4.1 Flash, that is the test it had to pass, on the same cards, before the swap." Compare [[Bridgewater and Thinking Machines fine-tune Qwen3-235B to replicate expert investor judgment, beating frontier LLMs on financial information-filtering at 13.8x lower cost|Bridgewater and Thinking Machines' tuned Qwen3-235B]] for the same economics arrived at by tuning rather than by swapping.

**So what does auto-tuning actually change?** Four things, all named: the verdict **code** (rewritten clause by clause, thirteen special cases deleted), the Jev question **criteria** (rewrite the lowest-confidence question on the cases you got wrong), the **routing** (v2 "added the triage question and put the stoppers first," v3 "stopped a case once nothing left could change the rating," v4 "looked up the customer's identity only when a card needed it"), and the **model per card**. Thresholds are described as versioned policy rather than as tuned parameters: "Confidence is a number the policy can set: clears below a chosen confidence go to review, and the threshold itself is versioned."

**The promotion gate and its known hole.** "A candidate version goes live only after it beats the current one on a development set. We learned to keep a second set the author never sees: on the banking messages, the author eventually matched every development label and still scored the same on the reserved set, so the development score alone is not a promotion criterion."

**Two checks on every judgment node.** "It needs the complete rubric relevant to its decision: criteria, exceptions, blockers, scoring. Splitting a workflow into smaller steps can leave a judge with half the policy, and the prompt a node actually receives is the thing to read." And fingerprinting: "the workflow, the SOP, and the skill used in each run are recorded, structure is validated before execution (required inputs, schemas, loop bounds), and the results behind each promotion are kept."

**Model governance** is the pitch, answered as four examiner questions - "which model made it, on what inputs, under which version of the policy, and can you show me" - and the strongest concrete claim is the lookback: "When the policy changes, the last quarter's judgments can be re-run under the new rules without re-researching a single case, which turns a lookback from a project into an afternoon."

**The honest limitation, verbatim:** "For reviewed workflows, crash recovery currently covers flat chains of code, calls, polling, and file artifacts; model nodes and nested workflows are not on that path yet. If an external action's outcome is unknown, we preserve it for reconciliation before anyone retries it."

## The AML Worked Example

**The job.** "You are an analyst. On your desk: one customer's file, and 24 cards from the watch-list company, 24 people with the same name who have been in trouble somewhere. Two questions. Is our customer any of these people? And if so, is it bad enough to turn them away? The customer is 18, an apprentice, from a small town. The cards carry a name, what happened, and a country. Nothing more. The bank's procedure is 508 lines long."

**Day one: by the book.** "Open every card. Look the person up. Find their age, their job, their town, their family. Compare with the customer. Write it down. Twenty-four times. On this alert that was 826 tool calls, 271 web pages, 51 minutes, and in two other runs it hit the hour and never finished. The answer was right: STOP. Cards 9 and 21 are one drug trafficker with a long sentence, and nothing shows he is not our customer. The explanation was a page of prose."

**What it writes down.** Three notes, verbatim, and they are shortcuts rather than answers:

- "Cards 9 and 21 decided the whole case. If I had known up front they were the dangerous ones, I would have looked at those two and nothing else."
- "Card 3 was clearly not our customer, you could see it on the card. I did not need to open it. Same for 12 and 18."
- "After card 9 nothing could change the answer. I opened fifteen more anyway. Fifty minutes."

"These are not answers. They are shortcuts, and they generalize: every alert has cards that could stop the customer and cards that could not, and every alert has a point after which nothing can change the answer."

**The rulebook becomes a program.** In prose first - "every line says who does it": `jev(classify)` for which cards could stop the customer, `agent(research)` to look those up all at once, `jev(classify)` for whether any of them is our customer, `code(decide)` for the verdict and the hand-off. Then in the DSL, verbatim:

```
chain
  map over the cards      jev(classify: could this card stop the customer? is it hard to clear?)
  code(order the cards: stoppers first, the rest after)
  loop until done, at most 3 waves
    map over the wave     agent(research: look up the card) + jev(verify: the card kind's checklist)
    map over the wave     jev(classify: the 21 facts the rulebook defines)
    code(verdict per card; done when STOP, or when nothing left can change the answer)
    escalate(judge: the card no question could settle)
  code(the record: rating, the card that decided it, every card not opened and why)
  agent(report: render the record)
```

"Three kinds of step. Code where it is mechanical. Jev where it is a closed question. An agent only where something must be found, or where no question could settle it. The agent, which used to be the whole job, is two lines."

**Day two: from the program.** "Same 24 cards, run through the program. Three are clearly not our customer from the card alone: gone. Jev asks the rest the rulebook's question; two could stop the customer. Both are looked up, together. One is him as far as anyone can show. STOP... The reason for the STOP is one line: card 9, the sentence."

### Before and after, on the one alert

| | Day one, agent by the book | Day two, AgentRun DSL program |
| --- | --- | --- |
| Tool calls | 826 (the animation's counter ends at 816 clicks) | about 30 |
| Web pages read | 271 | not stated |
| Wall time | 51 minutes; two other runs "hit the hour and never finished" | about 3 minutes |
| Cards opened | all 24, sequentially | 2, at the same time |
| Cards not opened | none | 22 (3 ruled out on the card, 19 could not change the answer) |
| Explanation | "a page of prose" | "one line: card 9, the sentence" |
| Rating | STOP, correct | STOP |

### Cost and accuracy, on 100 and then 1,000 alerts

On 100 fresh alerts: "30% of the card look-ups never ran, the case stopped early on 32 alerts, the customer's own web presence was established on 8 alerts instead of 100, and the cost per alert came down from $2.89 on the production agent to $0.25."

The arms measured on those 100 alerts, verbatim:

| Approach | Model cost per alert | Notes |
| --- | --- | --- |
| Full agent, frontier model (Opus 5) | **$2.89** | Reads everything, one long context |
| Full research agent on Gemini Flash + code judgment | **$2.02** | Every profile researched; the judgment already questions and code |
| Lean research agent on DeepSeek V4.1 Flash + Jev judgment | **$0.39** | Every profile researched |
| Routed workflow: triage, early stop, lazy identity | **$0.25** | 30% of profile research not run; judge agent on identity in 8% of cases; 100 of 100 alerts completed |
| Jev questions per alert (about 30) | **$0.003** | 150 ms a question |

The 1,000-alert run, with every number the piece gives:

| Quantity | Value |
| --- | --- |
| Batch size | 50 alerts |
| Allocation, fixed before the run | first 100 on the full agent; then 50% of the next 200, 75% of the next 200, 90%, then all of the final 300 may try the workflow |
| Hand-backs to the agent | about 1 in 20 early on, about 1 in 70 over the last 300 |
| Final share through the workflow | 98 of every 100 cases |
| Accepted workflow versions | 4 (v1 replaced the judgment with Jev and code; v2 added triage and put stoppers first; v3 early stop; v4 lazy identity look-up) |
| Cost per alert, start to end | $2.95 on the full agent per the chart, $2.89 per the prose, to $0.25 |
| Accuracy by the compliance judge | 90% over the first 100 alerts, 95% over the last 300 |
| Tuning run cost | $1,049 in model usage, of which $68 was the author's sessions and development checks |
| Same 1,000 alerts on Opus 5 | $2,884, so "the learning bill was recovered before alert 150" |
| Projection over 100,000 alerts | $26K for the workflow with fallback and a retro every 1,000; $290K on Opus 5; $265K saving per the chart |

Where the final 25 cents goes, from the bar chart: research agents on cards that stayed open (DeepSeek V4.1 Flash) $0.138; fallback to the full agent on 1.5 percent of alerts (Opus 5) $0.044; identity judge agent on 8 percent of alerts (DeepSeek V4.1 Flash) $0.041; report agent $0.021; about 30 Jev questions $0.003.

Two hedges the author supplies, verbatim. On disagreements: "The compliance judge's verdict on the disagreements with historical labels was the same across those arms, roughly two to one for the workflow, and the number of unsafe clears was lowest on the lean arms." On where the money was saved: "The saving is not from a smaller model reading the same pages. It is from not reading pages whose content could not change the rating, and from a judgment that costs nothing." And on why accuracy rose rather than fell: "The versions that cut cost also raised accuracy, because each one removed a place where the agent could wander. Fewer pages read means fewer places to be wrong."

## Availability

Closed. AgentRun is a hosted product, not a release: "We're rolling AgentRun out to Grep.ai enterprise customers this week, and to Pro customers in the days after." There is no repository anywhere in the article or the host tweet - the only outbound links in the payload are `grep.ai` (twice) and the `blog.grep.ai` "Claude in a box" post. The host tweet's display text `agent.run()` links to `https://agent.run`, which did not resolve when checked. No resource note was written, because there is nothing to point one at.

## Replies

Six of the eleven replies on the host tweet were returned by the fetch; the other five did not come back and are not reproduced. **Ríos Berríos did not reply to any of them**, so there are no author replies to quote.

One is substantive. **@OMID_0909 (EKOS _ AGI)** quote-tweeted their own thread at the post: "AgentRun solves the workflow problem really well. But once traces, notes and past runs start becoming inputs for future workflows, the harder problem becomes knowledge provenance - what was actually known at decision time." That is the right objection to aim at this design, and the article half-answers it with version fingerprinting ("the workflow, the SOP, and the skill used in each run are recorded") while leaving the notes themselves unversioned - a note written on alert 40 silently shapes every workflow version after it.

**@pylok (Alex)** offers the thesis back as a slogan: "hyper-focusing on repetitive loops instead of open-ended autonomy is the only way agents survive production scale." **@voiys** reports building the same thing: "i'm building this exact same thing lmao, congratz on the launch!" The remaining three are congratulations (@JucelyMarie, @jamesreggio, @danitoszwarc).

## Links

- [grep.ai](https://grep.ai/) - Grep AI, the company; AgentRun is rolling out to enterprise customers first, Pro customers after.
- [Claude in a Box: Building Grep on the Agents SDK](https://blog.grep.ai/blog/claude-in-a-box) - Grep AI's *previous* harness, not a layer under AgentRun. It describes running open-ended entity research on the Claude Agent SDK with three years of Parcha compliance workflows loaded as skills, and building Grep on top of it.
- `https://agent.run` - the host tweet's link target, which did not resolve when checked.
- [Host tweet](https://x.com/miguelriosen/status/2101029313906987422) - text `agent.run()`, 2026-09-18 19:23 UTC.
- 12-Factor Agents - credited for the decision-versus-action framing, mentioned by name but not linked in the article.

## Related

- [[moc - Jev]] - the Jev map of content.
- [[TypeSafe's Jev trades string generation for parallel-sampled typed decisions with calibrated probabilities at $0.042 per MTok - the 193x and 444x claims come from four self-built workflow evals]] - the model AgentRun's decision layer is built on, and the origin of the calibration claim this article repeats without testing.
- [[Josh Rosen's Jev in the Wild sorts week-one projects into routing, context filtering, tool gating, worker supervision, fast control loops and fuzzy data queries - deterministic only because inference was expensive]] - AgentRun is absent from his 25-project list but uses five of his six patterns inside one program.
- [[Daniel Ch's How to master Jev prescribes a 0.85 and 0.55 confidence-gate ladder under an LLM that still writes - the decision-layer architecture is additive but every number and all three charts are TypeSafe's own]] - "run Jev as the judge, not the writer," which AgentRun takes further by removing the writer from the ordinary path entirely.
- [[LangChain's Sydney Runkle puts Jev inside the agent loop as classifier middleware - ModelRouterMiddleware picks the model from the latest user message and AutoModeMiddleware reproduces closed harnesses' dangerous-action gate]] - the repeatability-not-calibration measurement, and the standing objection to gating safety on a probabilistic classifier.
- [[Cua keeps the candidate menu in application code so Jev only picks an ID - CUA-S1-FORMS is a 706K-parameter form specialist at 99.7 percent against hosted Jev's 83.6, and neither model sees pixels]] - the hand-back rule AgentRun implements as `escalate` and the 1.5 percent fallback.
- [[TypeSafe's SDE cascade gates escalation on any per-field Noul above 0.7 - the chart's y-axis is mean llm_judge and the frontier dominates only the two middle models]] - the fixed-threshold gate AgentRun generalizes into versioned policy.
- [[Sutro's jev-align uses GEPA to rewrite Jev's decision criteria from five labeled examples - the demo moves labeled-set ambiguity 49.6 points but full-pool certainty only 0.5]] - criteria rewriting as an optimizer, which is the automated version of AgentRun's "rewrite the lowest-confidence question"; neither jev-align nor GEPA is named in this article.
- [[jev-align]] and [[simple-jev]] - the tooling around the decision layer.
- [[coding agents should be personal canvases not uniform tools]] - Pi, whose loop AgentRun runs for both the general agent and every agent node.
- [[the harness is everything and agent performance comes from environment design not model capability]] - the general claim AgentRun is an industrial-scale instance of.
- [[Claude Code's edge comes from its software harness not the model]] - the same argument for a coding agent.
- [[LangChain's Paid Media Agent got 40x cheaper and 13x faster by moving calculations out of the model into code]] - the identical move, one calculation at a time rather than a whole rulebook.
- [[LLMs can synthesize their own code harness via tree search eliminating illegal actions and outperforming larger models]] - self-authored harnesses with a search-based correctness signal, which is the guarantee AgentRun's eval gate lacks.
- [[training beats prompting so use runtime guards not instructions]] - why the `verify` clause is a guard rather than an instruction.
- [[DSPy is a framework for programming—not prompting—language models through typed signatures and metric-driven optimizers]] - typed signatures plus a metric-driven optimizer, the research lineage of a DSL whose nodes declare schemas and get promoted on a dev-set score.
- [[GEPA prompt optimizer beats reinforcement learning with 35x fewer rollouts by reflecting on natural-language execution traces]] - reflecting on traces to rewrite instructions, which is exactly what AgentRun's learning mode does by hand.
- [[Bridgewater's PAT treats agentic codegen as a compiler problem, turning 50 years of written-down investment logic into a deterministic AI analyst with a benchmark-gated Teach loop]] - the closest prior art: written-down regulated logic compiled into a deterministic program, but with correctness enforced architecturally rather than by a dev-set score.
- [[Applied AI doesn't work because the time was never in the work - Varick maps Hammer's 1990 re-engineering critique onto enterprise agents and sorts every step into deterministic, agentic, or human]] - the demand-side method for sorting each step into deterministic, agentic, or human.
- [[Claude Code dynamic Workflows synthesize a per-task agent harness at runtime opening a third scaling axis]] - a model authoring an orchestration program whose primitives hold control flow, the nearest mechanical analogue to the AgentRun DSL.
- [[separating cognitive blueprints from runtime engines enables portable auditable agent systems]] - the declarative-specification-versus-execution-substrate split, argued on the auditability grounds AgentRun sells on.
- [[Toast 1 takes over the search loop as a specialized subagent - 3.5x fewer tokens at identical Harvey-bench scores and OfficeQA SOTA at 1.15 dollars per task]] - specializing the look-up loop, the $0.138 line in AgentRun's final cost breakdown.
- [[Bridgewater and Thinking Machines fine-tune Qwen3-235B to replicate expert investor judgment, beating frontier LLMs on financial information-filtering at 13.8x lower cost]] - tuning a model for the judgment call instead of typing the question, the alternative to the Jev node.
- [[Autobrowse iterates browser agents to convergence then graduates the winning strategy into a durable SKILL.md, ending the per-site rediscovery tax]] - one expensive exploration graduated into a durable reusable artifact, AgentRun's learning mode in miniature.
- [[ProcMEM - Learning Reusable Procedural Memory from Experience via Non-Parametric PPO for LLM Agents]] - names the obstacle the compile step exists to clear: stored experience is not an executable decision procedure.

## Original Content

Captured from the X Article (id 2100840456200581120) reconstructed from the raw Draft.js payload, so headers, emphasis, links, the four embedded markdown entities and all thirteen media sit exactly where the author put them. Two of the thirteen are animated GIFs; their final frames are embedded as PNGs, because the opening frames are blank. The article cover image is a title card reading `agent.run()` and is not reproduced.

> [!quote]- Host tweet and full article - Miguel Ríos Berríos, 2026-09-18
> **@MiguelriosEN (Miguel Ríos Berríos)** - Fri Sep 18 19:23:18 +0000 2026
> 170 likes / 13 reposts / 11 replies / 491 bookmarks / 7 quotes / 116,718 views
>
> `agent.run()` https://x.com/i/article/2100840456200581120
>
> ---
>
> # AgentRun: a harness for repetitive knowledge work
>
> *We built AgentRun for jobs our customers do thousands of times a day. Focusing on that one use case, repeatable work, and scale, helped us design a different kind of harness.*
>
> At [Grep.ai](http://grep.ai/), we've been building AI agents for enterprise companies since 2023. We've gone from brittle agents that made good demos, to putting agents on rails (static workflows with LLM loops) to make them work, and back to building agents on top of harnesses like the [Claude Agent SDK](https://blog.grep.ai/blog/claude-in-a-box) in the span of three years. Yet we still felt we had not found the right tool for the problem our customers’ need us to solve.
>
> Most of our customers perform repetitive knowledge work in a regulated space, thousands of times a day, each case a little different from the last.
>
> Take one: an anti-money-laundering alert. A bank screens a customer against sanctions, politically-exposed-person and adverse-media lists, and the screening vendor returns every profile that shares the name. Around 95% of those alerts are false positives, but each one has to be cleared: read the articles, find the customer's own footprint in registries and press, compare age, location, occupation and family, apply the bank's procedure, and write down why. An analyst spends the better part of an hour on one alert . A frontier-model agent does the same work for about $3 an alert, because it reads the news, the court reports and the registries the way the analyst does, then reasons over all of it in one long session. The stakes are high: clearing a real match is a regulatory failure, so the procedure is written with an asymmetry in it, and the harness has to keep that asymmetry.
>
> One could script the procedure: fixed queries against fixed sources, a conditional for each list. That's how we tackled this before agents. Or build an agent with the procedure as its system prompt, a browser, search, and other tools. That's how we solved it when agents started to "work". Both did their job. But the script breaks the first time a source changes its pages, and the agent is expensive at scale.
>
> With the static workflow, you end up maintaining and constantly updating code. With a frontier model, an agent can figure out pretty much anything we throw at it, but the result is expensive and hard to govern. We work in regulated industries. Customers need to know how a decision was made, which evidence supported it, and which procedure the agent followed. They need to explain that to their own teams, auditors, and regulators. Agents make this hard.
>
> # Let the agent do the job, then fire itself from it
>
> AgentRun takes a different approach: let a smart agent do the job, then find a way to automate it as a workflow, so most cases never need the agent at all. It starts with a job and an SOP, a standard operating procedure. The agent selects tools, writes code when it needs to, and finds a way to finish the job. In learning mode, it also leaves notes about how it worked: which tools it used, what approach worked or failed, and any tips for the next agent to do the work more easily.
>
> After several runs, the agent uses the traces and notes from the previous runs to write a workflow in the AgentRun DSL, our language for workflows. The workflow can contain research agents, judgment agents, typed questions, and ordinary code. We use agents we've tuned for those jobs, so they perform well at low cost.
>
> As the workflow takes shape, the agent routes a subset of cases to it instead of doing the job itself. It keeps iterating on the workflow as more cases come in and increases the share of cases it does not handle directly. By the end of the run in the last section, 98 of every 100 cases go through the workflow, and the full agent handles the rest, the odd ones.
>
> This approach has two main benefits:
>
> 1. Cost. We've seen cost savings of 50–95% using workflows vs an agent with a frontier model. The workflow is more efficient than LLM turns and even when nodes in the workflow are agents, these tend to be very inexpensive.
>
> 2. The workflow is a system whose steps we can inspect and evaluate separately. Model Governance becomes easier when a system can be decoupled into clear subsystems. And likewise, humans can inspect the workflow by looking at specific steps, their inputs, outputs, and routing logic instead of having to deduct these from agent traces and chain-of-thought.
>
> ## The shape of the program
>
> We owe one framing to 12-Factor Agents, and we lean on it every day. Take a tool call apart and there are two things inside: a decision, which action and with what arguments, and an action, the code that carries it out. Nothing about the decision needs a text generator. It needs something that can pick an option well and say how sure it is. Follow that seam through a whole procedure and it shows up everywhere: a long compliance job is mostly decisions and mechanical steps, with a few places where someone genuinely has to go and look.
>
> We build AI programs along that seam. An agent where something must be found or done in the world. A typed question where something must be decided. Plain code where the step is mechanical. And a handful of shapes that hold the three together. Until now the decisions were made by the same instrument as the searching, a language model with a prompt, and that is where much of the cost and the opacity came from. The AgentRun DSL gives each kind of step its own place, and the decisions get their own engine, further down.
>
> # Built on Pi
>
> Our harness is built on top of Pi. We use their loop for the general agent and the agents inside our workflows. Around it, AgentRun provides the instructions, tools, skills, workspace, budgets, and output requirements.
>
> *Architecture: AgentRun supplies the SOP, budgets and output contract around a Pi agent loop, with a model router, skills and workspace, the Executor tool gateway, a typed result, run traces and usage, and reusable case notes when learning is enabled.*
> ![[miguelriosen-987422-001.jpg]]
>
> Our tool gateway, Executor, connects the agent to hundreds of tools for web research, registries, and other work. Each run gets the tools it's allowed to use. The gateway also supports tool discovery, so we can expose a large catalog without putting every tool definition into every prompt.
>
> We have been building our skill library for three years, most of it for compliance work. The same authoring and evaluation system we use for those skills is the one our users get to build skills for their own Grep.ai agents.
>
> ## Traces and notes
>
> We save the tool calls, results, submissions, errors, and usage for each run. In the tuning process, each case has a JSONL trace file and a ledger entry with its outcome, cost, and latency. We also retain the reasoning or summaries the model exposes, where available.
>
> Those records let us inspect where the agent spent its time and money. We can see whether a tool returned useful evidence, an empty result, or an error, and what the agent did next.
>
> When learning is enabled, we ask the agent to write its most reusable lesson into the workspace. A note might say that a particular registry website found the company when web search didn't, or that a page required a browser because a fetch couldn't expose the information. One to three sentences is enough.
>
> # The AgentRun DSL
>
> As we built workflows ourselves, we kept needing the same primitives. The AgentRun DSL is the small language that gives them names: a few kinds of agent, plain code, the shapes that hold steps together, and, newest, a way to ask a typed question and get a calibrated answer. The agent that authors a workflow plays the same twelve cards we play by hand.
>
> *The twelve cards of the AgentRun DSL: four green agent cards (Research, Judge, Report, Operator), four purple Jev cards (Route, Classify, Sift, Pick), one code card, and three flow cards (Map / Reduce, Loop until, Escalate).*
> ![[miguelriosen-987422-002.jpg]]
>
> Everything in a workflow is one of these. Reading a workflow is reading which cards it plays, in what order, over which data.
>
> ## The agents
>
> The agents are the characters. Each one runs the Pi loop with its own instructions, tools, model, and effort budget, and each has one job.
>
> **Research** searches, fetches websites, and drives a browser through multi-page sites and logins. We tuned it for accuracy at low cost. Today it runs on DeepSeek V4.1 Flash, and it has completed nearly every research task we have given it.
>
> **Judge** reads everything when the question is hard. It takes the procedure and the evidence and makes a supported determination: whether this record is our customer, whether this risk is low, medium, or high. We give it a smarter model and let it open a source to verify a claim. It is also the agent the rest of the workflow escalates to.
>
> **Report** renders the record into the document the customer receives. It never re-decides. If a report is wrong, the separation tells us whether the fault was in gathering the facts, judging them, or writing them up.
>
> **Operator **is the only agent that writes outside of the sandbox. It acts in the world: fills the portal, files the paperwork, submits the case to the system of record. It has a browser and the other write tools. Its effects leave the workspace, so it runs under the tightest tool grants and every action is on the trace.
>
> ## Code and mechanical steps
>
> Some steps need no model at all. **Code** parses a payload, counts, compares, and decides what follows: the arithmetic of ages and dates, the tally of discrepancies, the rule that says two of these make a stop. A **call** performs one external action with no model in the loop. We can see the tool or command being invoked and its deadline. An **artifact** declares the deliverable and checks that the promised file exists.
>
> Suppose an external service is generating a document. A call can poll until the service completes, reports failure, or reaches the deadline. We don't need a model turn for every status check. This excerpt specifies the polling behavior; the surrounding call names the tool and its inputs:
>
> ```json
> {
>   "deadline_s": 15,
>   "poll": {
>     "until":     { "predicate": "field_equals", "path": "status", "value": "completed" },
>     "fail_when": { "predicate": "field_equals", "path": "status", "value": "failed" },
>     "interval_s": 5,
>     "deadline_s": 120
>   }
> }
> ```
>
> The engine waits five seconds between checks, allows up to 15 seconds for each call, and stops polling after two minutes. The status values come from the service's contract.
>
> ## The shapes that hold them together
>
> Steps run in a **chain**. **Map / Reduce** runs the same step over every item of a list at once, then folds the answers into one: twenty-four cards researched in parallel, one verdict. **Loop until** repeats a body within a bound and stops on a condition the state can answer: until nothing left can change the rating, at most three waves. **Escalate** routes a case off the cheap path, to the judge agent when a question is hard, or to a person with the record when the procedure requires review. It is the shape that makes the rest safe to run cheap.
>
> We pass structured records between steps. Nodes declare required inputs, and the engine checks every submission against its schema. We can inspect the data at each handoff and test the next step with those same inputs.
>
> ## Decisions as typed questions: the Jev nodes
>
> Routing, classification, and probabilistic decisions were always part of the AgentRun DSL. Before we had anything better, a constrained LLM call with a schema did them: cheap, but a language model all the same. It answers with a label and no calibrated sense of how sure it is, and it has to be prompted again for every new case.
>
> AgentRun is the first harness built around Jev, TypeSafe's System One model, and it is the first time classification inside a procedure gets its own engine. Jev does not write text. It answers typed questions over a structured state: a choice among named options, a yes/no, a score on a scale, each with a probability distribution and a confidence that is calibrated, meaning a 0.7 is right about seven times in ten. An answer takes about 150 milliseconds and costs a few hundred-thousandths of a dollar. That turns out to be exactly the shape of most decisions inside a procedure.
>
> The four purple cards are the four ways to ask:
>
> - **Route** is a choice among branches of the workflow. Each branch carries the criteria under which the procedure takes it, and an "unsure" branch for when no option is confident.
>
> - **Classify** compiles an output schema into questions. Every enum becomes a choice, every boolean a yes/no, and the criteria the author writes for each option are the criteria Jev applies. The values land in the workflow state; the probabilities land beside them, so the code that follows can ask not only what but how sure. (In the DSL this is the judge node.)
>
> - **Sift** asks the same yes/no of every item in a list in one request and keeps the ones that pass: which of these sources is about our subject.
>
> - **Pick** compares the items and chooses one, or none: which of these records is our customer.
>
> Two more places Jev shows up without a card of its own. A verify clause on any agent turns the agent's own output schema into a checklist: when the agent submits, Jev reads the submission against the evidence the agent cited and answers, per field, whether the evidence supports the claim. A submission that fails comes back to the same agent session with exactly the fields it could not support, and the agent keeps working; claims still unsupported after the last round are removed before anything downstream sees them. And predicates on loops and escalations let a confidence gate a retry or a hand-off to review.
>
> The rule we follow: **Jev decides what a thing is; code decides what follows.** A hit's name link is a nickname or it is not; its location is a different country or it is not; the arithmetic of ages and dates and the counting of discrepancies is code. Two things fall out of that. The decision is auditable, because every rating names the questions and probabilities it rests on. And the decision is replayable, because the answers are retained: we can change the code that reads them and re-run the judgment of a thousand cases in two minutes for a few cents, with no agent and no model call. Auto-tuning the judgment stops being a series of runs and becomes a replay.
>
> ## Evaluate one node or the whole workflow
>
> Every card in a workflow has one model, one input contract, and one output schema. That is what makes it evaluable on its own. Say the final risk decision is wrong. We freeze the evidence the decision was made on and change only the thing under suspicion. We never run the whole investigation again for every experiment.
>
> **Evaluating a Jev node.** The judgment in the alert review is 21 typed questions. Every answer and its probability is kept with the case, so the judgment of a thousand alerts is a table we can re-run without an agent and without a model call: change the code that reads the answers, replay, compare. When we rewrote the verdict rules to follow the rulebook clause by clause and deleted thirteen special cases, the replay showed the same rating on all 868 hits in two minutes for a few cents. When a question is the problem, we can see it: the one with the lowest confidence on the cases we got wrong is the one whose criteria need rewriting, and we can test the rewrite on the same table. A Jev question set is also something a compliance officer can read. It is the rubric, stated once, in the bank's own words.
>
> **Evaluating an agent.** The research agent is judged on what it hands over, not on how it got there. Did the judge downstream have the facts the rulebook needed, or did a case escalate because a fact was missing? Did the verify pass hold up: how often did Jev send a submission back, and for which fields? Those two numbers, per card kind, tell us whether to fix the instructions, the tools, or the model. When we switched the research agent from a frontier model to DeepSeek V4.1 Flash, that is the test it had to pass, on the same cards, before the swap. The report agent is judged against the record it was given: every finding in the record is in the report, nothing in the report is outside the record.
>
> **Evaluating code.** A code node is deterministic, so it is tested like any other code: the arithmetic of ages and dates, the counting of discrepancies, the rule that says two of these make a stop. When it changes, the replay above tells us exactly which cases changed rating and why.
>
> **Evaluating the whole workflow.** After a node is fixed, we run the whole workflow on the same cases and compare versions side by side: the rating, the cost, the cards opened, the confidence behind each stop. A candidate version goes live only after it beats the current one on a development set. We learned to keep a second set the author never sees: on the banking messages, the author eventually matched every development label and still scored the same on the reserved set, so the development score alone is not a promotion criterion.
>
> **Two things we check on every judgment node.** It needs the complete rubric relevant to its decision: criteria, exceptions, blockers, scoring. Splitting a workflow into smaller steps can leave a judge with half the policy, and the prompt a node actually receives is the thing to read. And every version is fingerprinted: the workflow, the SOP, and the skill used in each run are recorded, structure is validated before execution (required inputs, schemas, loop bounds), and the results behind each promotion are kept.
>
> **What this does for model governance.** Model risk teams ask four questions of any automated decision: which model made it, on what inputs, under which version of the policy, and can you show me. A workflow answers all four by construction. Each decision names its node, its model, its inputs, and the questions and probabilities it rests on, so an examiner can follow one alert from the card to the rating. A model change is a change to one card, evaluated on that card's own inputs, with the before and after kept; swapping the research model does not touch the judgment, and the replay proves it. When the policy changes, the last quarter's judgments can be re-run under the new rules without re-researching a single case, which turns a lookback from a project into an afternoon. Confidence is a number the policy can set: clears below a chosen confidence go to review, and the threshold itself is versioned. And the boundary between what a model decides and what code decides is written down, so the parts a validator needs to test deterministically are deterministic.
>
> Saved traces let us reconstruct inputs for all of this. For reviewed workflows, crash recovery currently covers flat chains of code, calls, polling, and file artifacts; model nodes and nested workflows are not on that path yet. If an external action's outcome is unknown, we preserve it for reconciliation before anyone retries it.
>
> Sometimes the fix is a new step. Often it is a better instruction, a better query, or a smaller classification task that can move to a cheaper model, or to a Jev question.
>
> # Auto-tuning an AML alert review
>
> The alert review is the clearest picture of what the harness does: let a smart agent do the job once, the expensive way, and let it write down how the job should really be done.
>
> ## The job
>
> You are an analyst. On your desk: one customer's file, and 24 cards from the watch-list company, 24 people with the same name who have been in trouble somewhere. Two questions. Is our customer any of these people? And if so, is it bad enough to turn them away?
>
> The customer is 18, an apprentice, from a small town. The cards carry a name, what happened, and a country. Nothing more. The bank's procedure is 508 lines long.
>
> *The job: an analyst with the customer's file and the watch-list cards laid out on the desk.*
> ![[miguelriosen-987422-003.jpg]]
>
> ## Day one: by the book
>
> The agent does what the procedure says an analyst does. Open every card. Look the person up. Find their age, their job, their town, their family. Compare with the customer. Write it down. Twenty-four times.
>
> On this alert that was 826 tool calls, 271 web pages, 51 minutes, and in two other runs it hit the hour and never finished. The answer was right: STOP. Cards 9 and 21 are one drug trafficker with a long sentence, and nothing shows he is not our customer. The explanation was a page of prose.
>
> *Day one by the book: the analyst buried in stacks of paper and open books, with the clock running.*
> ![[miguelriosen-987422-004.jpg]]
>
> ## What it writes down
>
> While it works, the agent keeps notes, not about this customer, about the job. Where did the time go? What did it wish it had known at the start?
>
> - "Cards 9 and 21 decided the whole case. If I had known up front they were the dangerous ones, I would have looked at those two and nothing else."
>
> - "Card 3 was clearly not our customer, you could see it on the card. I did not need to open it. Same for 12 and 18."
>
> - "After card 9 nothing could change the answer. I opened fifteen more anyway. Fifty minutes."
>
> These are not answers. They are shortcuts, and they generalize: every alert has cards that could stop the customer and cards that could not, and every alert has a point after which nothing can change the answer.
>
> *What it writes down: the analyst facing a corkboard of sticky notes, the case folders closed on the desk.*
> ![[miguelriosen-987422-005.jpg]]
>
> ## The rulebook is turned into a program
>
> The notes say which parts of the job are mechanical, which are a yes/no, and which need someone to go and look something up. So the rulebook is written again as a program, and every line says who does it. Simplified to its bones:
>
> - jev(classify): which cards could stop the customer? The rulebook's list: sanctions, a senior official or their family, a serious conviction.
>
> - agent(research): look those up, all at once.
>
> - jev(classify): is any of them our customer? The rulebook's tests: age, place, job, family, how the names match.
>
> - code(decide): if one of them is our customer, STOP. If not, look up the rest the same way. If none of the 24 is our customer, CLEAR. If we cannot tell for one of them, hand that card to the judge agent.
>
> In the AgentRun DSL that program is a handful of nodes. Simplified, with the instructions and schemas left out:
>
> ```
> chain
>   map over the cards      jev(classify: could this card stop the customer? is it hard to clear?)
>   code(order the cards: stoppers first, the rest after)
>   loop until done, at most 3 waves
>     map over the wave     agent(research: look up the card) + jev(verify: the card kind's checklist)
>     map over the wave     jev(classify: the 21 facts the rulebook defines)
>     code(verdict per card; done when STOP, or when nothing left can change the answer)
>     escalate(judge: the card no question could settle)
>   code(the record: rating, the card that decided it, every card not opened and why)
>   agent(report: render the record)
> ```
>
> Three kinds of step. Code where it is mechanical. Jev where it is a closed question. An agent only where something must be found, or where no question could settle it. The agent, which used to be the whole job, is two lines.
>
> ## What a Jev question looks like
>
> Jev never sees the procedure. It gets one question with the bank's criteria written into it, and one card. This is the request for "could this card stop the customer", simplified:
>
> ```
> state:
>   hit:      { name, screenType, events: ["... drug trafficking ... sentenced ..."], country }
>   customer: { name, dob, job }
>
> question could_stop_the_customer (yes/no):
>   instructions: Could this profile floor the case at HIGH under the bank's procedure
>                 if it is the customer? HIGH floors are: a sanctions designation;
>                 a senior national PEP or a family member of one; a conviction for a
>                 serious offence (trafficking, violence, sexual offences, terrorism,
>                 organised crime, major fraud). Ordinary adverse media, regulatory
>                 matters, arrests without conviction, minor offences cannot.
>   true:  a sanctions designation, a senior PEP or relative, or a serious conviction
>   false: ordinary adverse media, regulatory or civil matters, arrests, minor offences
>
> answer: { could_stop_the_customer: 0.97 }     126 ms, $0.00004
> ```
>
> The bank's policy is the instructions and the criteria, written once by whoever authors the workflow from the procedure. Jev's job is narrow: read the card, read the list, say how well the card fits. The answer is a probability, not a label, so a 0.44 can be treated differently from a 0.97, and the threshold is a number in code, not a feeling. If the bank adds a rule tomorrow, it is a line in that list, and the change replays over every past card in minutes.
>
> ## Day two: from the program
>
> Same 24 cards, run through the program. Three are clearly not our customer from the card alone: gone. Jev asks the rest the rulebook's question; two could stop the customer. Both are looked up, together. One is him as far as anyone can show. STOP.
>
> Two cards opened, at the same time. About 30 tool calls. About three minutes. The other 22 stay closed, and the record says why: three were not our customer on their face, and once card 9 was him, the other nineteen could not change the answer. The reason for the STOP is one line: card 9, the sentence.
>
> *Day two: the same twenty-four cards, only two of them opened.*
> ![[miguelriosen-987422-006.jpg]]
>
> ## Before and after
>
> Side by side, the two ways of doing the same job. On the left, the agent by the book: a smart model with the procedure in its prompt, opening every card because nothing tells it which ones matter. 826 tool calls, 51 minutes, a page of prose. On the right, the same alert through AgentRun: the procedure written as a program, one question per card, two cards opened. Thirty tool calls, three minutes, and a record that names the card that decided it and says why the other 22 stayed closed. The agent on the left is not gone. It wrote the program on the right, and it is still there for the case the program cannot handle.
>
> *Before: the AgentRun agent, by the book, opens all 24 cards.*
> *Before, final frame of the animation: "AgentRun agent, by the book - open every card, read everything, twenty-four times." The counter reads 816 clicks, every one of the twenty-four cards is open, and the case ends STOP.*
> ![[miguelriosen-987422-007.png]]
>
> *After: the AgentRun DSL workflow asks each card one question and opens two.*
> *After, final frame of the animation: "AgentRun DSL workflow - ask each card one question, open only the two that matter, stop." The counter reads 30 clicks, three cards are crossed out unopened, two are open, and the case ends STOP.*
> ![[miguelriosen-987422-008.png]]
>
>
> ## What about cost and accuracy?
>
> On 100 fresh alerts the same shape held: 30% of the card look-ups never ran, the case stopped early on 32 alerts, the customer's own web presence was established on 8 alerts instead of 100, and the cost per alert came down from $2.89 on the production agent to $0.25.
>
> These are the arms we measured on those 100 alerts before the full run.
>
> | Approach | Model cost per alert | Notes |
> | --- | --- | --- |
> | Full agent, frontier model (Opus 5) | **$2.89** | Reads everything, one long context |
> | Full research agent on Gemini Flash + code judgment | **$2.02** | Every profile researched; the judgment already questions and code |
> | Lean research agent on DeepSeek V4.1 Flash + Jev judgment | **$0.39** | Every profile researched |
> | Routed workflow: triage, early stop, lazy identity | **$0.25** | 30% of profile research not run; judge agent on identity in 8% of cases; 100 of 100 alerts completed |
> | Jev questions per alert (about 30) | **$0.003** | 150 ms a question |
>
> The compliance judge's verdict on the disagreements with historical labels was the same across those arms, roughly two to one for the workflow, and the number of unsafe clears was lowest on the lean arms. The saving is not from a smaller model reading the same pages. It is from not reading pages whose content could not change the rating, and from a judgment that costs nothing.
>
> We ran the 1,000 alerts in batches of 50. The allocation was fixed before the run: the first 100 alerts went to the full agent, so there would be traces and notes to learn from. Half of the next 200 could try the workflow, then 75% of the following 200, then 90%. The final 300 could all try it, with the full agent as the fallback. After every batch the author read the results, the traces, and the notes, and proposed a new version of the workflow. A candidate went live only after it beat the current version on the development set. Where a dot sits below the schedule, the workflow handed a case back to the agent: about one alert in twenty early on, about one in seventy over the last 300.
>
> *Share of alerts completed through the workflow. The stepped area is the allocation schedule fixed before the run (100 on the agent, then 50%, 75%, 90%, everything); the dots are what actually finished in the workflow rather than falling back, rising from about 50% to about 99%.*
> ![[miguelriosen-987422-009.jpg]]
>
> Cost per alert fell in steps, not on a slope. Each step is a workflow version. The first version still researched every card, but replaced the agent's judgment with Jev questions and code. The second added the triage question and put the stoppers first. The third stopped a case once nothing left could change the rating. The fourth looked up the customer's identity only when a card needed it.
>
> *Cost per alert, batch by batch, each point 50 alerts on a log scale, with orange marks at the four accepted workflow versions. The chart labels the start $2.95 on the full agent (Opus 5) and the end $0.25.*
> ![[miguelriosen-987422-010.jpg]]
>
> Accuracy did not pay for the saving. The compliance judge scored every batch: 90% on the full agent in the first 100 alerts, 95% over the last 300. The versions that cut cost also raised accuracy, because each one removed a place where the agent could wander. Fewer pages read means fewer places to be wrong.
>
> *Accuracy by the SOP judge: share of each 50-alert batch where the rating agreed with the compliance judge, shaded band 90 to 95 percent, labelled 90% at the start and 95.0% at the end, with the four version marks.*
> ![[miguelriosen-987422-011.jpg]]
>
> The tuning run cost $1,049 in model usage, and $68 of that was the author's sessions and the development checks. Every alert on the full agent (Opus 5) would have cost $2,884, so the learning bill was recovered before alert 150. A bank does not review 1,000 alerts, it reviews 100,000, so we kept going. Over 100,000 alerts, with fallback and a retro every 1,000 included, the workflow cost $26K. The same alerts on Opus 5 would have cost $290K.
>
> *Cumulative spend over 100,000 alerts. The tuning run is the first 1,000 alerts at $1,049; the tuned workflow with fallback and retros included reaches $26K while every alert on Opus 5 reaches $290K, a saving of $265K.*
> ![[miguelriosen-987422-012.jpg]]
>
> The last 25 cents go to agents, not questions. Research agents on the cards that stayed open (DeepSeek V4.1 Flash) take more than half.  The escalation to the full agent (Opus 5) runs on 1.5%, and the report agent renders the record. The thirty or so Jev questions per alert cost a third of a cent together. The saving is in the 30% of cards that never opened.
>
> *What the last 25 cents buy, by who spent it: research agents on the cards that stayed open (DeepSeek V4.1 Flash) $0.138; judge agent on identity, 8% of alerts (DeepSeek V4.1 Flash) $0.041; fallback to the full agent, 1.5% of alerts (Opus 5) $0.044; report agent (DeepSeek V4.1 Flash) $0.021; about 30 Jev questions (System One) $0.003. Footnote: "30% of the card look-ups never ran; the saving is in the pages nobody had to read."*
> ![[miguelriosen-987422-013.jpg]]
>
> ## That is AgentRun
>
> A frontier agent does the job the expensive way once and writes down what it would do faster. Then it writes the program: a pipeline that moves between a typed question, a line of code, and a small agent loop only where something must be looked up or done. The program takes the ordinary cases. The agent stays for the strange ones.
>
> That is where we think agents are going. Not one long session that reads everything and reasons about all of it every time, but agents that learn a job, write it down as a program of cheap, inspectable steps, and get out of the way. **The model that can figure anything out is the most expensive thing in the building.** Use it to write the program, and to catch what the program cannot.
>
> Jev is what makes that program possible, and it is a new kind of instrument. Until now, every judgment an agent made cost a model turn: slow, priced by the token, and answered with a label and no sense of how sure. A model that answers a typed question with a calibrated probability in 150 milliseconds for a few hundred-thousandths of a dollar changes what an agent can afford to ask. It can check every claim it makes against the source it cited. It can ask a question of every item in a list instead of a sample. It can gate its own next step on a confidence rather than a feeling. And when it learns a job, it can write its judgment down as questions and code, so the next run answers in milliseconds what took it minutes of reading.
>
> We keep that agent available for the cases the workflow can't handle. Operations teams already work this way: software automates the ordinary path and people handle the exceptions. We use the same division of work, with a frontier-model agent on the exceptions and human review where the SOP requires it. You want the ability to figure things out. You don't want to pay for it from scratch on every ordinary case.
>
> We're rolling AgentRun out to Grep.ai enterprise customers this week, and to Pro customers in the days after. If you have a repetitive job you've wanted to hand to an agent but held back because agents felt too opaque or too expensive to run at volume, we'd like to prove you wrong on both counts. Go to [grep.ai](https://grep.ai/) and try it, or DM me and I'll demo it on your job, not ours.
>
>
> ---
>
> ### Replies (6 of 11 returned by the fetch, none from the author)
>
> **@JucelyMarie (Jucely Marie Rivera)** - Fri Sep 18 19:37:32 +0000 2026
> @MiguelriosEN Congrats on this launch!
> https://x.com/JucelyMarie/status/2101032895184068876
>
> **@danitoszwarc (Dani)** - Fri Sep 18 21:57:42 +0000 2026
> @MiguelriosEN Esto es una maravilla!!!
> https://x.com/danitoszwarc/status/2101068172665516348
>
> **@OMID_0909 (EKOS _ AGI)** - Fri Sep 18 22:52:13 +0000 2026
> @MiguelriosEN https://t.co/61Yy2uU7ge
> > QT @OMID_0909:
> > AgentRun solves the workflow problem really well. But once traces, notes and past runs start becoming inputs for future workflows, the harder problem becomes knowledge provenance — what was actually known at decision time,
> > (thread continues)
> > https://x.com/OMID_0909/status/2101080496306356433
> https://x.com/OMID_0909/status/2101081891298218315
>
> **@pylok (Alex)** - Sat Sep 19 00:10:24 +0000 2026
> @MiguelriosEN hyper-focusing on repetitive loops instead of open-ended autonomy is the only way agents survive production scale.
> https://x.com/pylok/status/2101101565973287015
>
> **@jamesreggio (James Reggio)** - Sat Sep 19 12:32:42 +0000 2026
> @MiguelriosEN super interesting read — appreciate you sharing / building in public
> https://x.com/jamesreggio/status/2101288373587448267
>
> **@voiys (zgodni)** - Mon Sep 21 21:26:09 +0000 2026
> @MiguelriosEN i'm building this exact same thing lmao, congratz on the launch!
> https://x.com/voiys/status/2102147395731488844
