---
created: 2026-09-20
description: Daniel Ch's "How to master Jev (Full Guide)" is a practitioner's architecture guide that tells you to demote Jev from chatbot to judge under a generative LLM, split every decision into atomic parallel questions, keep the state minimal, and route on confidence bands of act above 0.85, escalate 0.55 to 0.85 to a stronger model, and queue below 0.55 for a human - advice that is genuinely additive over TypeSafe's docs, wrapped around performance numbers and three charts that are entirely TypeSafe's own.
source: https://x.com/chddaniel/status/2100925069765534024
author: Daniel Ch (@chddaniel)
published: 2026-09-18
type: knowledge
tags: [jev, guide, confidence-gates, decision-layer, question-design, system-one-models, typesafe]
---

# Daniel Ch's How to master Jev prescribes a 0.85 and 0.55 confidence-gate ladder under an LLM that still writes - the decision-layer architecture is additive but every number and all three charts are TypeSafe's own

## Key Takeaways

- **The gate ladder is the one thing in the guide with numbers attached, and the numbers come with the right disclaimer.** He prescribes "act automatically above 0.85 confidence, send 0.55–0.85 to a stronger model, and put anything below 0.55 into a human queue," then immediately withdraws the authority: "the exact thresholds need to come from tests on your own data, not from an article." That caveat is what separates this from the rest of the Jev commentary in the vault. [[BARGAIN routes classification to a small model via a confidence threshold calibrated on 500 oracle labels, cutting costs up to 86 percent more than competing cascades|BARGAIN]] is the worked version of the advice he gives and does not follow: spend a fixed label budget, sweep every observed confidence value, get a distribution-free guarantee. [[Sutro's jev-align uses GEPA to rewrite Jev's decision criteria from five labeled examples - the demo moves labeled-set ambiguity 49.6 points but full-pool certainty only 0.5|jev-align]], the tool built specifically for tuning Jev, leaves the threshold at a hardcoded `>= 0.5` and never measures it. A guide that says "measure your own" is, oddly, ahead of the tooling.
- **"Run Jev as the judge, not the writer" is the genuinely additive contribution, and it is a four-role split, not a slogan.** LLMs generate, Jev decides, code controls the thresholds and business rules, and a human catches low-confidence and high-risk cases. Naming a distinct owner for the *control* step is what the vendor framing leaves out, and it is the same economics as [[LangChain's Paid Media Agent got 40x cheaper and 13x faster by moving calculations out of the model into code]] reached without a new model class. [[LangChain's Sydney Runkle puts Jev inside the agent loop as classifier middleware - ModelRouterMiddleware picks the model from the latest user message and AutoModeMiddleware reproduces closed harnesses' dangerous-action gate|Sydney Runkle's middleware]] is the code version of the same architecture, and the same caution applies: a probabilistic classifier is the weakest place to put a safety check.
- **Every performance number is TypeSafe's, he says so plainly, and all three charts are TypeSafe's own launch charts re-hosted.** The hedge is worth quoting in full: "those are TypeSafe's numbers, and the company itself says they are probably near the high end of real-world gains... but the important part survives the disclaimer." He is more honest than most secondary coverage. But the three images in a 2,400-word "full course" are byte-for-byte the accuracy-vs-cost Pareto, the four-stage incident-response workflow, and the structured-output and tool-call error-rate bars already in this vault from [[TypeSafe's Jev trades string generation for parallel-sampled typed decisions with calibrated probabilities at $0.042 per MTok - the 193x and 444x claims come from four self-built workflow evals|TypeSafe's own launch post]]. There is no measurement in this article that the author made.
- **The chart he re-hosts contradicts the sentence he opens with.** The article's first line is "TypeSafe just released the strongest model." The Pareto chart directly below it puts Jev at roughly 68% accuracy averaged over the four workflows, below sol at about 74% and opus 5 at about 73%. Jev is the leftmost point on the frontier, which means cheapest-at-its-accuracy, not most accurate. The 0% type-error bars in the third chart are worse as evidence: the launch note records that TypeSafe added that zero by construction because schema matching is guaranteed, so it is an axiom plotted next to measurements.
- **"Keep the state clean" is TypeSafe's documented defect written up as craft.** He frames minimal state as an optimization — "the smaller useful state is the upgrade" — and softens the reason to "its own documentation says accuracy can shift as state grows." The [jaggedness page](https://docs.typesafe.ai/model-jaggedness/jev-1.13) catalogued in [[Annabell frames TypeSafe's Jev as a savant for eval verdicts and routing - three question types, 255 choices, 10 score levels, and a Noul with no confidence field|Annabell's note]] says it flatly: "Jev suffers from context rot." His "Jev 1.13 has a 64k request limit" also takes the most generous of three conflicting published figures, since the models page splits that into 32k for state plus the longest question and OpenRouter lists 32K outright. The underlying discipline is real and is stated better in [[Factory treats context as a scarce resource that must be budgeted and curated across layered scaffolding]].
- **The gate ladder does not typecheck against his own worked example.** Step 2 asks urgency, cancellation intent and refund intent "with separate Nouls," and step 3 gates on confidence — but Noul returns only a probability and carries no confidence field at all, which is the single most load-bearing gotcha in the Annabell note. Code reading `answer.confidence` uniformly across that question set breaks on three of five questions. Relatedly, "every uncertain answer gets a route... never treat low confidence as if it were a normal result" is correct advice precisely because TypeSafe documents that Jev cannot abstain: there is no unknown or needs-review option, so the model picks the least wrong answer and the escape hatch has to be yours.
- **"Abuse parallel questions" is the pillar the vault actively disputes.** He tells you to send every independent judgment you might want and discard the rest, and Jev's pricing makes that nearly free. But [[LLM Data Company experiments show explicit rubric criteria let gpt-oss-120b match Opus 4.7 at 100x lower cost and full-rubric grading beats per-criterion across every model]] found full-rubric grading beat per-criterion grading on every model tested, meaning decomposition can cost accuracy, while [[LangChain and Harvey show DeepSeek batch verifiers reduce legal agent evaluation costs by three orders of magnitude at acceptable accuracy]] runs 50+ independent per-criterion verdicts and is the reason it is affordable. Jev's architecture forces the split; the guide presents that constraint as a technique and never mentions the tradeoff.

## What Is Additive vs Restated

The guide is a secondary source. Separating the two halves is the fastest way to use it.

**Genuinely additive over TypeSafe's docs and the vault's existing Jev notes:**

- **The confidence-band architecture as a three-way ladder** with concrete numbers and an explicit instruction to re-derive them on your own data. Annabell proposes act / human / drop; this is act / stronger model / human, which inserts a model-escalation tier that the vault otherwise only has from [[BARGAIN routes classification to a small model via a confidence threshold calibrated on 500 oracle labels, cutting costs up to 86 percent more than competing cascades|BARGAIN]].
- **Naming `code controls` as a distinct role** alongside generate, decide and review. Thresholds and business rules deciding act/retry/escalate/stop is the piece that keeps the model from owning the workflow.
- **State hygiene as three named sections** — the object being judged, the context needed to interpret it, and the facts that materially change the decision — plus an explicit removal list: duplicated logs, irrelevant history, and "conclusions you want the model to reach."
- **"Cut any question that never changes an action, then pin the version."** A real design rule. It is the antidote to the parallel-question free-for-all he advocates two sections earlier.
- **Tying model pinning to threshold tuning.** Use `jev-latest` for the newest stable release; use `jev-1.13.0` "if you have tuned thresholds and need the same model behavior to stay pinned." Thresholds are model-version-specific state, which is the operational consequence nobody else in the vault spells out. [[static agent skills rot silently because the codebase model and task distribution change around them]] is the general form of the decay he is guarding against.
- **The review-loop log schema:** versioned model ID, probabilities, confidence, chosen route, final outcome. That is exactly enough to recompute a threshold later, and it matches the input-and-output discipline in [[agent production monitoring requires observing inputs and outputs not just system metrics]].
- **The five workflow archetypes as a taxonomy.** Not measured, but a useful shape for deciding whether you have a Jev-shaped problem.

**Restated marketing or straight from the docs:**

- "TypeSafe just released the strongest model" and "people are calling it the first real model built for machines for a reason" — unsourced, and the first is contradicted by his own first chart.
- $0.042 per million input tokens, free output, 70–500ms, 193.6x and 444.6x — all TypeSafe's, all already recorded in the launch note, and all correctly attributed by him.
- The three primitives, parallel evaluation against one shared state, typed outputs with confidence — the docs' introduction.
- `POST /v1/systemone`, the Python and JavaScript SDKs, the coding-agent skill, `jev-latest` versus `jev-1.13.0` — the quickstart.
- All three charts.
- "Early access, English is currently its strongest language, current stable model is jev-1.13.0" — the models page.

## The Decision-Layer Pattern

The prescriptive core, stated as rules.

**The four roles.** Your LLM creates: Astra, Fable, Sol "or whatever comes next" still writes the code, email, report or answer. Jev decides: it classifies the request, scores the risk, chooses the route and checks the output against explicit criteria. Code controls: thresholds and business rules decide whether the system acts, retries, escalates or stops. A human catches the edge cases: low-confidence and high-risk decisions go to review "instead of being forced through automation."

**The confidence bands.**

| Band | Action |
| --- | --- |
| above 0.85 | act automatically |
| 0.55 to 0.85 | send to a stronger model |
| below 0.55 | human queue |

He states these as an example, not a default, and says the real values must come from tests on your own data. Note the asymmetry against [[Annabell frames TypeSafe's Jev as a savant for eval verdicts and routing - three question types, 255 choices, 10 score levels, and a Noul with no confidence field|Annabell's three-band split]], where the bottom band drops or flags rather than escalating, and against [[Factory droid exec uses tiered autonomy levels to gate agent permissions from read-only to full system access]], which tiers the same ladder on the risk of the action rather than the model's confidence. Confidence and blast radius are different axes and the guide only gates on one.

**Three rules that keep the layer reliable** (his words, condensed): one question, one judgment, so split broad decisions into independent pieces; keep arithmetic and hard rules in code, because "Jev judges meaning, your program calculates numbers"; every uncertain answer gets a route, and never treat low confidence as a normal result.

**Question patterns he prescribes.** Give the model three things and get out of the way: the state it needs to judge, one atomic question, and exact criteria for what each answer means. Descriptive criteria "reliably beat vague labels" — `technical = broken behavior or integration failure` over "choose the right team." Use Score rubrics for gradients like severity, quality and fit rather than forcing a yes/no. Keep one meaning per question, and decompose whenever the answer depends on two unrelated facts.

**Question patterns he proscribes.** Do not use personas, step-by-step scripts or motivational preambles, which are techniques for steering a text generator. Do not ask it to explain itself, because it returns a decision, probabilities and confidence, not reasoning. Do not hide multiple judgments in one question: "is this lead valuable, urgent and likely to buy?" is three questions combined in code.

**State hygiene.** Three sections are usually enough — the object being judged, the context needed to interpret it, and the facts that materially change the decision. Remove duplicated logs, irrelevant history, and conclusions you want the model to reach. He gives 64k as the request limit and concedes accuracy can shift as state grows.

**Parallel questions.** Thirteen independent questions about one support ticket evaluate against the state in a single call, and "adding more barely changes the response time." Send every judgment that might be useful even if code will only consume some of them: intent, risk, urgency, sentiment, relevance, required action, all against the same input.

## The Worked Workflow

A support router detecting urgency and churn risk, which he says generalizes to leads, listings, claims or documents.

1. **The state.** One object: customer plan Pro, account age 14 months, the message "the app deleted my work again. cancel me if this isn't fixed today," and previous tickets 3 technical issues in 30 days. "Keep facts in, guesses out."
2. **The questions.** Department as a Choice, frustration as a Score, and urgency, cancellation intent and refund intent as three separate Nouls. Read the results once, cut any question that never changes an action, then pin the version.
3. **The gate.** High-confidence technical issues route to support, high cancellation probability adds the retention queue, uncertain routing goes to review. "The model does not send the reply. It decides which system should."
4. **The worker.** The correct worker receives the ticket: a deterministic action, a specialist LLM, an internal agent or a person. If an LLM writes the response, Jev then evaluates that draft for policy compliance, whether it answers the request, and whether it contains a prohibited promise. This is the fan-out-then-validate shape that [[RLM subagents need structured outputs not free-text to avoid losing the plot at fan-in - fast-rlm validates every FINAL]] enforces with typed outputs at every join.
5. **The review.** Log the versioned model ID, probabilities, confidence, chosen route and final outcome. Review false positives and false negatives, adjust criteria and thresholds, run it again. "First time through takes an evening."

The gap is step 3 against step 2: three of the five questions are Nouls, which return a probability with no confidence field, so a uniform confidence gate cannot read them.

## The Five Money Workflows

No numbers are attached to any of these. They are archetypes.

- **The universal verifier** — wrap every expensive LLM call: check the prompt for injection, the tool choice for obvious errors, the output for missing requirements, the final answer for unsupported claims. "Cheap checks around an expensive brain." Closest to a measured result in the vault via [[LangChain and Fireworks fine-tune Qwen as a 100x cheaper trace judge that beats frontier models on unseen perceived-error domains]], though a classifier is a weak injection defense.
- **The support control tower** — classify tickets, detect urgency, frustration, refunds and churn, route to the correct queue. "The win is not a prettier reply... it's fewer tickets in the wrong place and fewer valuable customers missed."
- **The lead qualification engine** — score company fit, maturity, pain, intent and urgency as separate signals, combine the probabilities with your own weights, send the best to sales, nurture the middle, leave the rest alone.
- **The model router** — decide whether each request needs deterministic code, a cheap model, a frontier model or a human, so the expensive model is used where it earns its cost. The production caution is in the Sydney Runkle note: `ModelRouterMiddleware` routes on the latest user message and then locks that model for the whole run, which fails when "the first prompt says quick bugfix, three tool calls later you're doing repo archaeology." The guide never says when to re-decide.
- **The giant dataset job** — run the same semantic judgments across support logs, reviews, listings, transcripts, research papers or agent traces; extract structured features, detect patterns, rank records worth inspecting. [[Bridgewater and Thinking Machines fine-tune Qwen3-235B to replicate expert investor judgment, beating frontier LLMs on financial information-filtering at 13.8x lower cost]] is the same job done with a fine-tune, an alternative the guide does not consider.

## Replies

Six replies at fetch and six retrieved. None engage with the architecture, none correct a claim, and none come from TypeSafe. Reproduced in full because there are so few.

> **@tonykastaneda (Tony Kastaneda)**, 19 September 2026
> @chddaniel You tell it to get rid of the em dashes but you can't get it to stop with the excessive parentheticals

> **@Anina_CE (Anina D. Lampret)**, 19 September 2026
> @chddaniel @JayceTheGlitch are we still not interested in this ?

> **@1mmarq (i need YHWH)**, 18 September 2026
> @chddaniel It's just not free 🥲

> **@kyle_wired (kyle)**, 18 September 2026
> @chddaniel it just came out 😭

> **@bobodee0130 (miu boll)**, 19 September 2026
> @chddaniel can grok 4.8 do this?@elonmusk

> **@metamantra (metamantra)**, 19 September 2026
> @chddaniel Check out @JevLawdotxyz I think it will blow your mind

Zero skipped. The first reply is the only one touching the text, and it is about the prose reading as machine-written rather than about Jev.

## Related

Jev notes in this vault:

- [[TypeSafe's Jev trades string generation for parallel-sampled typed decisions with calibrated probabilities at $0.042 per MTok - the 193x and 444x claims come from four self-built workflow evals]] — the launch post every number and all three charts in this guide come from
- [[Annabell frames TypeSafe's Jev as a savant for eval verdicts and routing - three question types, 255 choices, 10 score levels, and a Noul with no confidence field]] — the Noul-has-no-confidence gotcha that breaks this guide's uniform gate, plus the cannot-abstain and context-rot entries from the jaggedness page
- [[LangChain's Sydney Runkle puts Jev inside the agent loop as classifier middleware - ModelRouterMiddleware picks the model from the latest user message and AutoModeMiddleware reproduces closed harnesses' dangerous-action gate]] — the model-router archetype as shipping code, including the decide-once limitation
- [[Sutro's jev-align uses GEPA to rewrite Jev's decision criteria from five labeled examples - the demo moves labeled-set ambiguity 49.6 points but full-pool certainty only 0.5]] — tunes the criteria this guide tells you to write, and leaves the threshold hardcoded at 0.5
- [[Featherless's Simple Jev reproduces Jev's API on stock open models by remapping every answer to a single-token letter and softmaxing only those logits - no classifier head, and the code stamps every answer calibrated False]] — what happens to confidence gating when the probabilities are an uncalibrated softmax
- [[moc - Jev]]
- [[pg-jev]], [[jevlike]], [[jev-align]], [[simple-jev]] — the resource notes

Confidence routing, judging and state elsewhere in the vault:

- [[BARGAIN routes classification to a small model via a confidence threshold calibrated on 500 oracle labels, cutting costs up to 86 percent more than competing cascades]] — how to actually derive 0.85 and 0.55
- [[LangChain's Paid Media Agent got 40x cheaper and 13x faster by moving calculations out of the model into code]] — the judge-not-writer economics without a new model class
- [[anthropic recommends combining deterministic graders model judges and human review for agent evals]] — the deterministic / model-judge / human ladder this guide gates on confidence
- [[LLM Data Company experiments show explicit rubric criteria let gpt-oss-120b match Opus 4.7 at 100x lower cost and full-rubric grading beats per-criterion across every model]] — the counterevidence to "abuse parallel questions"
- [[LangChain and Harvey show DeepSeek batch verifiers reduce legal agent evaluation costs by three orders of magnitude at acceptable accuracy]] — per-criterion verification at scale, the supporting side of the same argument
- [[LangChain and Fireworks fine-tune Qwen as a 100x cheaper trace judge that beats frontier models on unseen perceived-error domains]] — a measured cheap judge under an expensive model
- [[agent production monitoring requires observing inputs and outputs not just system metrics]] — the reviewer throughput that the bottom band implicitly budgets
- [[Factory droid exec uses tiered autonomy levels to gate agent permissions from read-only to full system access]] — the same ladder gated on action risk instead of confidence
- [[Factory treats context as a scarce resource that must be budgeted and curated across layered scaffolding]] — the state-hygiene argument, stated more rigorously
- [[static agent skills rot silently because the codebase model and task distribution change around them]] — why any pinned threshold goes stale
- [[RLM subagents need structured outputs not free-text to avoid losing the plot at fan-in - fast-rlm validates every FINAL]] — fan-out to parallel judgments with typed validation at the join
- [[Bridgewater and Thinking Machines fine-tune Qwen3-235B to replicate expert investor judgment, beating frontier LLMs on financial information-filtering at 13.8x lower cost]] — the dataset-filtering archetype done with a fine-tune

## Original Content

> [!quote]- How to master Jev (Full Guide) - Daniel Ch (@chddaniel), X Article, 18 September 2026 (972 likes, 62 retweets, 6 replies)
>
> **Article: How to master Jev (Full Guide)**
>
> TypeSafe just released the strongest model, and it introduced a completely different way to put intelligence inside software...
>
> Jev is in a category of its own right now, not because it writes better than Fable or codes better than Astra, but because it does not try to do either
>
> out of the box it's an insanely fast decision engine, exceptional at classification, routing, scoring and verification... it turns messy information into typed answers your software can act on immediately
>
> and if you understand the methods, the primitives and the architecture behind it, you can put intelligence inside parts of your product that were previously too slow, expensive or unreliable to automate
>
> *TypeSafe's own accuracy-versus-cost chart, reproduced by the author: the average of four workflows, with Jev the leftmost point on the frontier at roughly 68 percent, below sol and opus 5. This is the same image already in the vault as `typesafe-jev-002.png` from TypeSafe's launch post.*
> ![[typesafe-jev-002.png]]
>
> people are calling it the first real model built for machines for a reason...
>
> so this is the full course
>
> what Jev is actually exceptional at, how to use it beside your existing LLMs, the question patterns that pull the best results out of it, the confidence gates that stop bad decisions, and the five workflows where it can make or save real money
>
> one note: Jev is still in early access, English is currently its strongest language, and the current stable model is jev-1.13.0
>
> this is early software, so test it on your own data before you let it touch anything expensive
>
> but if you want to understand the model everyone is suddenly talking about, start here
>
> # what this model is exceptional at
>
> before the methods, meet the machine... five things Jev does differently from the LLMs you're used to:
>
> ## it makes decisions instead of writing answers
>
> give it a piece of state and a set of possible outcomes, and it returns the decision in a type your software already understands
>
> no essay, no markdown, no hoping the JSON parser survives... you get a choice, a score or a probability
>
> that sounds smaller than an LLM until you realize how much software is really just thousands of decisions connected together
>
> ## it tells you when it isn't sure
>
> every Choice and Score comes back with confidence, while Noul returns the probability that a condition is true
>
> that means uncertainty can become part of the architecture instead of something the model hides behind confident language
>
> high confidence can act, medium confidence can ask a stronger model, and low confidence can go to a person
>
> ## it evaluates in parallel
>
> ask thirteen independent questions about the same support ticket and Jev evaluates them against the state in one call
>
> the questions do not need to wait for one another, and adding more barely changes the response time
>
> *TypeSafe's four-stage incident-response workflow diagram, reproduced by the author: triage, disposition, containment, playbook, with eleven parallel readings of the incident state and Bool, Score and Choice question markers. Already in the vault as `typesafe-jev-003.png` from TypeSafe's launch post.*
> ![[typesafe-jev-003.png]]
>
> you can check urgency, refund intent, frustration, product area, churn risk and abuse at once... then let code decide what happens next
>
> ## it fits inside normal software
>
> Jev does not ask to become your entire application
>
> it behaves more like a frontier-intelligence function call: unstructured state goes in, typed probabilistic decisions come out
>
> your code keeps control of the workflow, which means the model cannot invent a new branch, tool or output type halfway through the run
>
> ## it's cheap enough to use everywhere
>
> TypeSafe prices Jev 1.13 at $0.042 per million input tokens, with output tokens free
>
> its own published tests report response times around 70–500ms and gains of up to 193.6x in speed and 444.6x in cost on the workflows it tested
>
> those are TypeSafe's numbers, and the company itself says they are probably near the high end of real-world gains... but the important part survives the disclaimer
>
> decisions that were previously too expensive to run on every event can now sit inside the product loop
>
> # the cockpit: every control you need
>
> sixty seconds of setup, then the controls
>
> open the TypeSafe Playground and paste any text into state
>
> then add one of three questions:
>
> > Choice picks one option from a fixed list
>
> > Score places the state on an ordered rubric
>
> > Noul returns the probability that one statement is true
>
> when you're ready to put it inside a product, call POST /v1/systemone, install the Python or JavaScript SDK, or add TypeSafe's skill to your coding agent
>
> use jev-latest if you want the SDK to follow the newest stable release
>
> *TypeSafe's structured-output and tool-call error-rate bar charts, reproduced by the author: Jev at 0 percent on both against 0.58 to 45.5 percent and 0.67 to 17.0 percent for the LLMs. Already in the vault as `typesafe-jev-004.png` from TypeSafe's launch post, where the note records that the 0 percent was added by construction rather than measured.*
> ![[typesafe-jev-004.png]]
>
> use jev-1.13.0 if you have tuned thresholds and need the same model behavior to stay pinned
>
> that's the whole cockpit
>
> the rest of this course is knowing which decision to hand it, and which decisions should stay in code
>
> # the main event: run Jev as the judge, not the writer
>
> the single biggest upgrade is a role change
>
> stop prompting Jev like it's another chatbot... make it the decision layer underneath your system, because this model is worth more choosing what should happen than trying to produce the final artifact
>
> the setup:
>
> > your LLM creates: Astra, Fable, Sol or whatever comes next still writes the code, email, report or answer
>
> > Jev decides: it classifies the request, scores the risk, chooses the correct route and checks the output against explicit criteria
>
> > code controls: thresholds and business rules decide whether the system acts, retries, escalates or stops
>
> > a human catches the edge cases: low-confidence and high-risk decisions go to review instead of being forced through automation
>
> why this works: LLMs are flexible because they can generate anything, but that freedom is exactly what makes them difficult to bury inside a dependable workflow
>
> Jev gives up string generation and gains a much narrower contract... the available answers are defined before the request starts, every result fits the schema, and uncertainty is visible
>
> and the economics work in your favor
>
> the expensive model only handles the moments that genuinely require generation or long reasoning, while Jev handles the repeated judgments around it at a fraction of the latency and cost
>
> # build your decision layer
>
> the judge setup needs questions, and a good question takes two minutes to write
>
> every call contains one shared state and a set of independent questions: the instruction, the answer type and the criteria that define each possible result
>
> that's the entire mechanic... Jev reads the same state once and answers every question against it in parallel
>
> a complete support-triage call looks like this:
>
> ```json
> {
>   "state": "I've tried connecting Stripe for three days. I'm losing sales and need this fixed today.",
>   "model": "jev-1.13.0",
>   "questions": {
>     "department": {
>       "type": "choice",
>       "instructions": "Which team should own this ticket?",
>       "criteria": {
>         "billing": "Payments, charges or subscription issues",
>         "technical": "Bugs, broken behavior or integration failures",
>         "sales": "Pricing, plans or pre-purchase questions"
>       }
>     },
>     "frustration": {
>       "type": "score",
>       "instructions": "How frustrated does the customer appear?",
>       "criteria": [
>         "Calm",
>         "Frustrated but civil",
>         "Extremely frustrated"
>       ]
>     },
>     "urgent": {
>       "type": "noul",
>       "instructions": "The customer needs a time-sensitive resolution"
>     }
>   }
> }
> ```
>
> the confidence gate matters more than any individual question
>
> a wrong decision is still possible, even when the output type is always valid... confidence is what lets the surrounding system decide how much autonomy that answer deserves
>
> three rules that keep the layer reliable:
>
> > one question, one judgment... split broad decisions into independent pieces
>
> > keep arithmetic and hard rules in code... Jev judges meaning, your program calculates numbers
>
> > every uncertain answer gets a route... never treat low confidence as if it were a normal result
>
> and if you already use coding agents, TypeSafe ships a skill for Claude Code, Codex and other agent environments, so the agent can build this architecture without pretending Jev is a normal LLM
>
> # secret 1: don't prompt it like a chatbot
>
> everything you learned about getting beautiful prose from an LLM is irrelevant here
>
> personas, step-by-step scripts, long motivational preambles... those techniques are meant to steer a text generator, and Jev is not generating text
>
> Jev is naturally good at fast, common-sense judgments when the possible answers and their boundaries are clear
>
> so give it three things and get out of the way:
>
> > the state it needs to judge
>
> > one atomic question
>
> > exact criteria for what each answer means
>
> that last part matters more than people expect... descriptive criteria reliably beat vague labels
>
> and two things to avoid, because both fight the model:
>
> > don't ask it to explain itself... it returns a decision, probabilities and confidence, not a paragraph of reasoning
>
> > don't hide multiple judgments inside one question... "is this lead valuable, urgent and likely to buy?" should be three questions whose outputs are combined in code
>
> # secret 2: keep the state clean
>
> state is the information Jev evaluates, and it is the closest thing this model has to a working world
>
> the instinct is to dump everything into it... resist that, because relevant state beats maximum state on this model
>
> three sections are usually enough:
>
> > the object being judged: the ticket, lead, document, prompt or output
>
> > the context needed to interpret it: product, customer, policy or goal
>
> > the facts that materially change the decision
>
> remove duplicated logs, irrelevant history and conclusions you want the model to reach
>
> Jev 1.13 has a 64k request limit, but its own documentation says accuracy can shift as state grows
>
> the smaller useful state is the upgrade
>
> # secret 3: abuse parallel questions and confidence gates
>
> this is where Jev stops being a classifier and becomes an intelligence layer that can run across an entire product
>
> parallel questions: send every independent judgment that might be useful, even if the code will only use some of them later
>
> one call can label intent, risk, urgency, sentiment, relevance and required action against the same input
>
> the craft is making each question impossible to blur:
>
> > define visible boundaries: "technical = broken behavior or integration failure" is better than "choose the right team"
>
> > use rubrics for gradients: severity, quality and fit belong in Score, not a forced yes/no
>
> > keep one meaning per question: if the answer depends on two unrelated facts, decompose it
>
> confidence gates decide what happens after the answer
>
> for example: act automatically above 0.85 confidence, send 0.55–0.85 to a stronger model, and put anything below 0.55 into a human queue
>
> the exact thresholds need to come from tests on your own data, not from an article
>
> between parallel questions and confidence routing you can put Jev on every event without pretending every event deserves the same treatment
>
> millions of tiny decisions, with the uncertain ones automatically pulled out before they become expensive mistakes
>
> # how to one-shot a real workflow
>
> everything above, assembled once, on a real product
>
> the example is a support router that detects urgency and churn risk, but swap in leads, listings, claims or documents and the sequence holds
>
> ## step 1, the state
>
> your system sends one object:
>
> ```
> customer plan: Pro
> account age: 14 months
> message: "the app deleted my work again. cancel me if this isn't fixed today"
> previous tickets: 3 technical issues in 30 days
> ```
>
> keep facts in, guesses out
>
> ## step 2, the questions
>
> ask for department with Choice, frustration with Score, and urgency, cancellation intent and refund intent with separate Nouls
>
> read the results once, cut any question that never changes an action, then pin the version
>
> ## step 3, the gate goes to work
>
> high-confidence technical issues route to support, high cancellation probability adds the retention queue, and uncertain routing goes to review
>
> the model does not send the reply
>
> it decides which system should
>
> ## step 4, the worker
>
> now the correct worker receives the ticket: a deterministic action, a specialist LLM, an internal agent or a person
>
> if an LLM writes the response, Jev can evaluate that draft for policy compliance, whether it answers the request, and whether it contains a prohibited promise
>
> ## step 5, the review
>
> log the versioned model ID, probabilities, confidence, chosen route and final outcome
>
> review false positives and false negatives, adjust criteria and thresholds, then run it again
>
> first time through takes an evening
>
> the second time you'll realize the architecture is the same for every fuzzy decision your team still handles with brittle rules... which is exactly what the next chapter is about
>
> # the five workflows where it makes real money
>
> now point the whole setup at something worth automating
>
> these five are where Jev can make a difference you can actually measure:
>
> the universal verifier: place Jev around every expensive LLM call
>
> check the prompt for injection, the chosen tool for obvious errors, the output for missing requirements and the final answer for unsupported claims... cheap checks around an expensive brain
>
> the support control tower: classify tickets, detect urgency, frustration, refunds and churn, then route each conversation to the correct queue
>
> the win is not a prettier reply... it's fewer tickets in the wrong place and fewer valuable customers missed
>
> the lead qualification engine: evaluate company fit, maturity, pain, intent and urgency as separate signals
>
> combine the probabilities with your own weights, send the best leads to sales, nurture the middle and leave the rest alone
>
> the model router: decide whether each request needs deterministic code, a cheap model, a frontier model or a human
>
> Jev becomes the traffic controller, so the expensive model is used where it earns its cost instead of receiving every request by default
>
> the giant dataset job: run the same semantic judgments across support logs, reviews, listings, transcripts, research papers or agent traces
>
> extract structured features, detect patterns and rank the records worth inspecting... the kind of analysis that becomes possible only when each decision is fast and almost too cheap to count
>
> each of these used to require either brittle keyword rules or an LLM call you could not afford to run a million times
>
> each one is a Jev workflow now
>
> # the whole setup in one block
>
> > run Jev as the judge: LLMs generate, Jev decides, code controls, humans catch uncertainty
>
> > don't chat with it: state + atomic question + explicit criteria
>
> > keep state clean: only the object, the context and the facts that change the judgment
>
> > abuse parallel questions: evaluate every useful dimension in one call, then combine results in code
>
> > gate every action by confidence: automate the obvious, escalate the uncertain, review the dangerous
>
> > point it at the five workflows: verification, support, leads, model routing and giant datasets
>
> Jev is not the model that replaces every other model
>
> it's the model that can decide when, where and whether the others should run... and that might end up being far more valuable
>
> ---
>
> date: Fri Sep 18 12:29:04 +0000 2026
> url: https://x.com/chddaniel/status/2100925069765534024
> likes: 972  retweets: 62  replies: 6

## Links

- [How to master Jev (Full Guide)](https://x.com/chddaniel/status/2100925069765534024) - the original X Article, Daniel Ch (@chddaniel), 18 September 2026
- [Introducing System One Models & Jev](https://typesafe.ai/blog/introducing-system-one-models-and-jev) - the launch post that is the source of the $0.042, 70–500ms, 193.6x, 444.6x figures and all three charts
- [TypeSafe Playground](https://console.typesafe.ai/playground) - the "cockpit" he tells you to open first; requires early access
- [docs.typesafe.ai](https://docs.typesafe.ai/) - the API and schema documentation behind the `POST /v1/systemone` endpoint he names
- [Jev primitives](https://docs.typesafe.ai/primitives) - [Choice](https://docs.typesafe.ai/primitives/choice), [Score](https://docs.typesafe.ai/primitives/score), [Noul](https://docs.typesafe.ai/primitives/noul), the three question types
- [Confidence](https://docs.typesafe.ai/confidence) - where the docs record that Noul carries no confidence field, which his worked example does not account for
- [State](https://docs.typesafe.ai/concepts/state) - the payload his "keep the state clean" section is about
- [TypeSafe SDKs](https://docs.typesafe.ai/sdk) - the Python and JavaScript clients he tells you to install
- [TypeSafe agent skill](https://docs.typesafe.ai/agent-skill) - the skill for Claude Code, Codex and other agent environments
- [Models page](https://docs.typesafe.ai/models) - says 64k per request and 32k for state plus the longest question, against his flat "64k request limit"
- [Model jaggedness, jev-1.13](https://docs.typesafe.ai/model-jaggedness/jev-1.13) - "Jev suffers from context rot," and the cannot-abstain entry behind his "every uncertain answer gets a route"
- [OpenRouter jev-1.13](https://openrouter.ai/typesafe/jev-1.13) - lists 32K, a third conflicting context figure
