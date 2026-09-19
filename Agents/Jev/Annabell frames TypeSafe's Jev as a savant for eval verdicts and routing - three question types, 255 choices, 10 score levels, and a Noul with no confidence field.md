---
created: 2026-09-20
description: Annabell reads TypeSafe's Jev as a deliberate savant - a model that cannot write a sentence and returns no reasoning, but answers Choice, Score, and Noul questions in parallel against one shared state, which she argues makes it the right shape for routing, ticket classification, escalation, and rubric-verdict eval scoring, with the caveat that she relays TypeSafe's speed and cost claims rather than measuring them.
source: https://x.com/annabellschfr/status/2100962787094597807
author: Annabell (@annabellschfr)
published: 2026-09-18
type: knowledge
tags: [jev, evals, classification, routing, system-one-models, typesafe, structured-outputs]
---

# Annabell frames TypeSafe's Jev as a savant for eval verdicts and routing - three question types, 255 choices, 10 score levels, and a Noul with no confidence field

An X Article published 18 September 2026, three days after [[TypeSafe's Jev trades string generation for parallel-sampled typed decisions with calibrated probabilities at $0.042 per MTok - the 193x and 444x claims come from four self-built workflow evals|TypeSafe launched the model]]. Annabell works on the Langfuse side of the eval world, and the article is written from that vantage: what Jev changes for people who build evaluators. It closes with a runnable script that scores Langfuse traces with Jev and writes the verdict back as a Langfuse score. 59 likes, 9 retweets, 1 reply at capture.

## Key Takeaways

- **The savant framing is the actual argument, not a flourish.** Her point is that agents and workflows make decisions constantly, that for years we extracted those decisions from LLMs with structured outputs and JSON schemas, and that we "still paid generation prices for a yes/no." Jev is built for the decision rather than adapted to it. The cost of that specialization is stated plainly: no code, no summaries, and no account of why it answered as it did. This is the demand-side version of the supply-side claim in [[TypeSafe's Jev trades string generation for parallel-sampled typed decisions with calibrated probabilities at $0.042 per MTok - the 193x and 444x claims come from four self-built workflow evals]], and the same economics that [[BARGAIN routes classification to a small model via a confidence threshold calibrated on 500 oracle labels, cutting costs up to 86 percent more than competing cascades]] and [[LangChain and Fireworks fine-tune Qwen as a 100x cheaper trace judge that beats frontier models on unseen perceived-error domains]] reach without a new model class.
- **Parallel isolated questions change how you write an eval harness, not just what it costs.** Every question is scored independently against the same state, so a fourth or fourteenth question barely moves latency, costs only its own tokens, and cannot degrade the answers to the others. Her conclusion follows directly: ask speculatively and discard what you do not need. That composability is what makes the one-evaluator-per-failure-mode discipline in [[anthropic recommends combining deterministic graders model judges and human review for agent evals]] cheap to actually follow, and it cuts against the finding in [[LLM Data Company experiments show explicit rubric criteria let gpt-oss-120b match Opus 4.7 at 100x lower cost and full-rubric grading beats per-criterion across every model]] that full-rubric grading beats per-criterion grading on every model tested. Jev's architecture forces the per-criterion split.
- **The Noul gotcha is the most immediately useful thing in the article.** Choice and Score both return a confidence value; Noul returns only the probability that the answer is true and carries no separate confidence field. Code that reads `answer.confidence` uniformly across a question set breaks the moment a binary appears. The figure she includes marks this explicitly with a struck-through `.confidence` labelled "no such field."
- **The whole eval use case rests on probabilities being trustworthy, and nobody in the vault has verified that yet.** She proposes a three-way split on the Noul probability: act on high confidence, route the middle band to a human, drop or flag the rest. That only works if the numbers are calibrated. The vault's existing finding is that [[Sutro's jev-align uses GEPA to rewrite Jev's decision criteria from five labeled examples - the demo moves labeled-set ambiguity 49.6 points but full-pool certainty only 0.5|jev-align, the calibration CLI built for exactly this model, reports no calibration metric at all]] and publishes no calibration error figure. Confidence-gated routing is a design pattern here, not a measured result.
- **The skeptic's read: she relays claims she does not measure, and offers no judge-agreement numbers of her own.** The 20-200x faster and 40-400x cheaper figures are TypeSafe's own, cited as such. Her one external data point is Good Start Labs grading 6,003 rubric checks, where Jev matched Fable 5.1 91.5% of the time at $160 per million answers against $33,000 for Fable, but she also notes DeepSeek V4.1 Flash agreed 93.5% of the time for $260, which is better agreement for a rounding error in cost. The eval-scoring case assumes Jev's rubric verdicts are as good as an LLM judge's, and the article contains no agreement measurement she ran. [[Nova Escola's lesson-planner evals worked only after error analysis rewrote the rubric - annotators agreed worse than chance until experts defined good]] is the cautionary version: agreement is where rubric evals actually fail, and it is the number she does not have.
- **"No reasoning back" is a real cost for evals specifically, and she says so.** When a trace scores badly, Jev never tells you why, so you debug by rereading your own criteria. She is explicit that anything audited or customer-facing still needs a generative model on top. That is the same division of labour as [[LangChain and Harvey show DeepSeek batch verifiers reduce legal agent evaluation costs by three orders of magnitude at acceptable accuracy]], and it is why [[RLM subagents need structured outputs not free-text to avoid losing the plot at fan-in - fast-rlm validates every FINAL]] keeps a text channel alongside the typed one.

## What Jev Is Good For

Her criterion for reaching for Jev is a decision that is repeated, high volume, and whose possible answers are known before the call. Her list:

- agent and tool routing
- document and ticket classification
- escalation decisions
- eval scoring, where a rubric verdict is all you need

The last one is the article's centre of gravity. Everything after it is written for people building evaluators, and she connects Jev's insistence on atomic questions to Langfuse's own guidance on writing one evaluator per failure mode. Her framing is that Jev does not find your criteria for you, but it forces you to think in distinct categories and binary decisions, and punishes you with low confidence when you do not. Compare [[LangChain's Eval Engineering Skill builds Harbor-format evals from repo context and agent traces by interviewing the user]], which solves the same criteria-discovery problem by interviewing the developer instead.

## The Three Primitives and Their Limits

| Primitive | Question shape | Returns | Limit she cites |
|---|---|---|---|
| [Choice](https://docs.typesafe.ai/primitives/choice) | Pick one option from a set you define | Probability per option, plus a confidence value | Up to 255 options |
| [Score](https://docs.typesafe.ai/primitives/score) | Rate the state against ordered rubric levels | Probability-weighted value, full distribution, confidence value | Up to 10 levels |
| [Noul](https://docs.typesafe.ai/primitives/noul) | Yes or no | Probability the answer is true | [No separate confidence field](https://docs.typesafe.ai/confidence) |

The 255-option and 10-level ceilings both come from [TypeSafe's launch post](https://typesafe.ai/blog/introducing-system-one-models-and-jev) rather than the primitive docs. The Noul asymmetry is an API-shape fact worth internalizing before you write a generic answer handler.

She also lists what TypeSafe itself publishes as Jev's weak spots on its [per-version jaggedness page](https://docs.typesafe.ai/model-jaggedness/jev-1.13), keeping the three that bite when Jev is the judge:

- **It cannot abstain.** A forced binary with no unknown or needs-review option makes Jev pick the least wrong answer rather than say it does not know, so you have to design the escape hatch yourself.
- **No rationale when you need one.** Fine for eval design in aggregate, bad for the individual failing case.
- **Context rot, with an unclear limit.** Accuracy drops as the state fills with material the question does not need, which is awkward precisely because agent traces are long and mostly irrelevant. She flags a documentation contradiction: the [models page](https://docs.typesafe.ai/models) says 64k per request and 32k for state plus the longest question, while [OpenRouter](https://openrouter.ai/typesafe/jev-1.13) lists 32K. Verify before designing around it.

## Eval Harness Example

Her worked example asks three questions about one finished agent run in a single request: a Noul for whether a human should look at it, a Score over four ordered severity criteria, and a Choice over five labelled failure modes.

```json
{
  "model": "jev-latest",
  "state": {
    "task": "{{task}}",
    "tool_calls": "{{tool_calls}}",
    "final_output": "{{final_output}}"
  },
  "questions": {
    "needs_review": {
      "type": "noul",
      "instructions": "Does this run need a human to look at it?"
    },
    "severity": {
      "type": "score",
      "instructions": "How badly did this run go?",
      "criteria": [
        "Completed the task cleanly",
        "Completed it, but took a wasteful or confusing path",
        "Delivered a wrong or incomplete result",
        "Took a destructive or unsafe action"
      ]
    },
    "failure_mode": {
      "type": "choice",
      "instructions": "What went wrong, if anything?",
      "criteria": {
        "tool_error": "A tool returned an error or unusable output",
        "missing_context": "The agent lacked information it needed",
        "wrong_approach": "The agent chose an unsuitable strategy",
        "user_abandoned": "The user left before the task finished",
        "none": "Nothing went wrong"
      }
    }
  }
}
```

The response she shows returns `needs_review` at 0.88, `severity` at a probability-weighted 1.89 with the full four-level distribution attached, and `failure_mode` landing on `missing_context` at 0.58 with confidence 0.51 because `wrong_approach` sits close behind at 0.24. Her reading of that last one is the point of the whole primitive set: the low confidence is not a defect, it is the model reporting that those two failure modes are genuinely hard to separate from a trace alone. Total usage for all three questions is 1,840 input tokens and 27 output tokens.

The article's second worked example rewrites a conventional LLM-as-judge disagreement-detection prompt as a single Noul with an explicit scope and fully enumerated true and false criteria. Both versions return a boolean, but the Jev version forces the criteria to be written down as a structure rather than buried in prose. This is the same discipline that [[LLM Data Company experiments show explicit rubric criteria let gpt-oss-120b match Opus 4.7 at 100x lower cost and full-rubric grading beats per-criterion across every model]] found does most of the work in cheap grading, and the same failure-taxonomy thinking as [[Decagon's failure-informed data flywheel promotes a failure hypothesis into a sampling dimension only when a classifier and a measured accuracy gap validate it]].

## Replies

Two replies exist on the post and neither is substantive. Ayaz Ahmed Khan wrote "Super helpful, Aanna. Thanks." and Annabell replied "Very happy to help!" No corrections, no pushback from TypeSafe, and no eval-practitioner objections. The Noul-has-no-confidence point, the 255-choice cap, and the 10-level Score limit all went unchallenged.

## Related

- [[moc - Jev]] for the whole Jev cluster
- [[TypeSafe's Jev trades string generation for parallel-sampled typed decisions with calibrated probabilities at $0.042 per MTok - the 193x and 444x claims come from four self-built workflow evals]] for the launch claims she relays
- [[Sutro's jev-align uses GEPA to rewrite Jev's decision criteria from five labeled examples - the demo moves labeled-set ambiguity 49.6 points but full-pool certainty only 0.5]] for the calibration gap under her confidence-gating pattern
- [[jev-align]], [[jevlike]], and [[pg-jev]] for the tooling around the model
- [[anthropic recommends combining deterministic graders model judges and human review for agent evals]] for the grader-mix she is slotting Jev into
- [[BARGAIN routes classification to a small model via a confidence threshold calibrated on 500 oracle labels, cutting costs up to 86 percent more than competing cascades]] for confidence-threshold routing done with ordinary models

## Links

- [Jev the savant](https://x.com/annabellschfr/status/2100962787094597807) - the original X Article
- [TypeSafe docs introduction](https://docs.typesafe.ai/introduction) - the atomic-question insistence she cites
- [Introducing System One Models and Jev](https://typesafe.ai/blog/introducing-system-one-models-and-jev) - source of the 20-200x, 40-400x, and 255-option numbers
- [Jev primitives](https://docs.typesafe.ai/primitives) - [Choice](https://docs.typesafe.ai/primitives/choice), [Score](https://docs.typesafe.ai/primitives/score), [Noul](https://docs.typesafe.ai/primitives/noul)
- [Confidence](https://docs.typesafe.ai/confidence) - where the Noul exception is documented
- [State](https://docs.typesafe.ai/concepts/state) - the string-or-JSON payload every question is scored against
- [Model jaggedness, jev-1.13](https://docs.typesafe.ai/model-jaggedness/jev-1.13) - the per-version list of what Jev is bad at
- [Models page](https://docs.typesafe.ai/models) - 64k per request, 32k for state plus longest question
- [OpenRouter jev-1.13](https://openrouter.ai/typesafe/jev-1.13) - lists 32K, contradicting the models page
- [Vercel AI Gateway](https://vercel.com/ai-gateway/models/jev) - third-party access without a new vendor relationship
- [TypeSafe SDKs](https://docs.typesafe.ai/sdk) and [agent skill](https://docs.typesafe.ai/agent-skill) - Python and JavaScript, plus full API context for a coding agent
- [Cookbooks](https://docs.typesafe.ai/llms.txt) - guardrails, RAG passage screening, citation checks, confidence-gated classification
- [TypeSafe waitlist](https://typesafe.ai/)
- [Langfuse: writing evaluators](https://langfuse.com/academy/evaluate/writing-evaluators#one-evaluator-per-failure-mode) - the one-evaluator-per-failure-mode guidance she aligns Jev with
- [Langfuse: choosing what to evaluate](https://langfuse.com/academy/evaluate/choosing-what-to-evaluate) - finding criteria is still on you
- [Langfuse: query via SDK](https://langfuse.com/docs/api-and-data-platform/features/query-via-sdk) and [scores via SDK](https://langfuse.com/docs/evaluation/evaluation-methods/scores-via-sdk) - the two halves of her scoring script
- [Good Start Labs: verification is the bottleneck](https://goodstartlabs.com/research/verification-is-the-bottleneck) - the 6,003-rubric-check comparison

## Original Content

> [!quote]- Jev the savant - Annabell (@annabellschfr), X Article, 18 September 2026 (59 likes, 9 retweets, 1 reply)
>
> **Article: Jev the savant.**
>
> [TypeSafe](https://docs.typesafe.ai/introduction) just launched Jev. It cannot write a sentence, but is interesting for anything that classifies or decides at scale. Evals included. They claim it to be [20 to 200x faster and 40 to 400x cheaper](https://typesafe.ai/blog/introducing-system-one-models-and-jev) than frontier models.
>
> You send a [state](https://docs.typesafe.ai/concepts/state), a string or json, plus typed questions. You get typed answers with probabilities. It gives you no reasoning back. It's useless at other tasks. A real savant.
>
> AI agents and AI powered workflows take decisions all day long. They decide between different categories, whether something is true or not, which tool or path to take. And in the case of evals, AI classifies or simply decides if an output is right or wrong.
>
> Over the past years we forced this out of LLMs with structured outputs and json schemas, and still paid generation prices for a yes/no. Jev is deliberately built for that job instead of adapted to it. The flipside: it will not write code, summaries, or tell you why it answered the way it did.
>
> ## What Jev is good for
>
> Jev can help anywhere in your pipeline or eval harness where decisions are repeated, high volume, and the possible answers are known before the call:
>
> - agent and tool routing
>
> - document and ticket classification
>
> - escalation decisions
>
> - and eval scoring, where a rubric verdict is all you need
>
> Jev covers this surface with [three question types](https://docs.typesafe.ai/primitives):
>
> - [Choice](https://docs.typesafe.ai/primitives/choice) picks one option from a set you define, [up to 255](https://typesafe.ai/blog/introducing-system-one-models-and-jev), and returns the probability of each plus a confidence value.
>
> - [Score](https://docs.typesafe.ai/primitives/score) rates the state against ordered rubric levels and returns a probability weighted value, the full distribution, and a confidence value. Up to 10 levels.
>
> - [Noul](https://docs.typesafe.ai/primitives/noul) answers yes or no and returns the probability it is true. It [carries no separate confidence field](https://docs.typesafe.ai/confidence), so code that reads answer.confidence on everything will break on binaries.
>
> *The three question types with worked outputs, and the Noul confidence field marked as not existing*
> ![[annabellschfr-597807-001.jpg]]
>
> A finished agent run needs three judgements at once, and with Jev they go in one request:
>
> ```json
> {
>   "model": "jev-latest",
>   "state": {
>     "task": "{{task}}",
>     "tool_calls": "{{tool_calls}}",
>     "final_output": "{{final_output}}"
>   },
>   "questions": {
>     "needs_review": {
>       "type": "noul",
>       "instructions": "Does this run need a human to look at it?"
>     },
>     "severity": {
>       "type": "score",
>       "instructions": "How badly did this run go?",
>       "criteria": [
>         "Completed the task cleanly",
>         "Completed it, but took a wasteful or confusing path",
>         "Delivered a wrong or incomplete result",
>         "Took a destructive or unsafe action"
>       ]
>     },
>     "failure_mode": {
>       "type": "choice",
>       "instructions": "What went wrong, if anything?",
>       "criteria": {
>         "tool_error": "A tool returned an error or unusable output",
>         "missing_context": "The agent lacked information it needed",
>         "wrong_approach": "The agent chose an unsuitable strategy",
>         "user_abandoned": "The user left before the task finished",
>         "none": "Nothing went wrong"
>       }
>     }
>   }
> }
> ```
>
> And what you get back:
>
> ```json
> {
>   "model": "jev-1.13.0",
>   "answers": {
>     "needs_review": { "type": "noul", "noul": 0.88 },
>     "severity": {
>       "type": "score",
>       "score": 1.89,
>       "confidence": 0.44,
>       "legend": {
>         "0": "Completed the task cleanly",
>         "1": "Completed it, but took a wasteful or confusing path",
>         "2": "Delivered a wrong or incomplete result",
>         "3": "Took a destructive or unsafe action"
>       },
>       "probabilities": { "0": 0.02, "1": 0.21, "2": 0.63, "3": 0.14 }
>     },
>     "failure_mode": {
>       "type": "choice",
>       "choice": "missing_context",
>       "probabilities": {
>         "tool_error": 0.11,
>         "missing_context": 0.58,
>         "wrong_approach": 0.24,
>         "user_abandoned": 0.05,
>         "none": 0.02
>       },
>       "confidence": 0.51
>     }
>   },
>   "usage": { "input_tokens": 1840, "output_tokens": 27 }
> }
> ```
>
> needs_review comes back at 0.88, so queue it. severity lands at 1.89, just short of "delivered a wrong result". failure_mode is inconclusive: missing_context wins at 0.58, but confidence is 0.51 because wrong_approach is close behind at 0.24, and those two are genuinely hard to separate from a trace alone.
>
> Every question is evaluated in parallel and in isolation against the same state. So adding a fourth question, or a fourteenth, barely changes response time, costs only the tokens of the question itself, and cannot degrade the answers to the others. You can ask speculatively and throw away what you do not need.
>
> ## Jev's strengths for evals
>
> The TypeSafe docs are [insistent that each question must be atomic](https://docs.typesafe.ai/introduction). This is very much in line with [guidance on how to write good evaluators](https://langfuse.com/academy/evaluate/writing-evaluators#one-evaluator-per-failure-mode).
>
> Jev gives you a cheap and scalable way to evaluate your application against criteria you define. [Finding those criteria is still on you](https://langfuse.com/academy/evaluate/choosing-what-to-evaluate), but Jev forces you to think in distinct categories and yes/no decisions to define what good means. If you do not, the answer comes back with low confidence.
>
> Let's take user disagreement as an example. The goal is to identify from a message whether the user of a chatbot is disagreeing with the reply.
>
> With a typical LLM as a judge approach you would write a prompt and force a structured output with a decision, true or false:
>
> ```plaintext
> You are evaluating a conversation between a user and an AI assistant.
> Read the conversation history and the last user message. Decide whether the
> user is disagreeing with the assistant's prior response.
> The user IS disagreeing if they reject, correct or challenge the assistant's
> answer, say it misunderstood them, or ask it to start over. The user is NOT
> disagreeing if they ask a neutral follow-up, politely clarify, debug
> collaboratively, report an unrelated product problem, or express general
> frustration not aimed at the assistant. If there is no prior assistant
> response, the answer is false.
> Judge what the user believes, not whether the assistant was actually wrong.
> Return only JSON: {"disagreement": true | false}
> Conversation history: {{conversation_history}}
> Last user message: {{last_user_message}}
> ```
>
> With Jev you define user disagreement as one question with a scope, and then both criteria, true and false, cleanly:
>
> ```json
> {
>   "model": "jev-latest",
>   "state": {
>     "conversation_history": "{{conversation_history}}",
>     "last_user_message": "{{last_user_message}}"
>   },
>   "questions": {
>     "user_disagreement": {
>       "type": "noul",
>       "instructions": {
>         "question": "Does `last_user_message` clearly communicate that the user believes the assistant's prior response, reasoning, assumption, work, or approach was mistaken or proceeding in the wrong direction?",
>         "inspect": "last_user_message",
>         "scope": [
>           "Evaluate the user's expressed perception, not whether the assistant was objectively wrong.",
>           "Use `conversation_history` only to identify the relevant prior assistant response and resolve references.",
>           "If there is no prior assistant response, the answer is false."
>         ]
>       },
>       "criteria": {
>         "true": {
>           "definition": "The user clearly rejects, corrects, challenges, asks to undo, or repeatedly redirects the assistant's prior response or approach.",
>           "includes": [
>             "Directly saying the answer, assumption, or interpretation is wrong",
>             "Saying the assistant misunderstood the request",
>             "Questioning why the assistant made a particular assumption",
>             "Requesting that the assistant revert, restart, or abandon its approach",
>             "Repeated steering that indicates the assistant is still following the wrong direction"
>           ]
>         },
>         "false": {
>           "definition": "The user does not clearly indicate that the assistant made a mistake or took the wrong approach.",
>           "includes": [
>             "A neutral follow-up or request for more detail",
>             "A polite clarification that does not reject the prior response",
>             "Collaborative debugging without criticism of the assistant's approach",
>             "Reporting an external product or system problem",
>             "General frustration not directed at the assistant",
>             "An ambiguous reaction",
>             "No prior assistant response"
>           ]
>         }
>       }
>     }
>   }
> }
> ```
>
> 0.93 means a 93% probability of disagreement. The cutoff is yours to define in your app context, and because you get a probability rather than a label you can run three paths instead of two: act on high confidence, send the middle band to a human, drop or flag the rest. See the[ noul documentation](https://docs.typesafe.ai/primitives/noul) for the full shape.
>
> Both versions give you a true/false indication back. Jev forces you to define distinct criteria while writing your evaluator and has the potential to save you a significant amount of money and time.
>
> ## Jev's early bench results
>
> In just a few days in developers hands, people have already benched Jev against the established models.
>
> Early results point towards potential for time and money savings, especially over frontier models. [Good Start Labs](https://goodstartlabs.com/research/verification-is-the-bottleneck) graded 6,003 rubric checks with Jev and five LLMs on identical instructions. Jev matched Claude Fable 5.1's verdict 91.5% of the time at $160 per million graded answers, against $33,000 of Fable 5.1, $400 for GPT-5.6 Luna and $1,600 for Gemini 3.8 Flash.
>
> The Open Source comparison is less distinct: DeepSeek V4.1 Flash cost $260 and agreed with Fable 93.5% of the time, two points better for $100 more.
>
> Overall, this primarily points out one thing: There are tasks and decisions, like routing, classification and eval verdicts, that do not need the frontier. Models like Jev, the rise of OpenSource models, and the increasing demand for specialized models, are means to that end.
>
> ## Where Jev is falling short
>
> TypeSafe publishes a[ per-version page listing what Jev is bad at](https://docs.typesafe.ai/model-jaggedness/jev-1.13). Read it before you design an evaluator. Most of it is general, it reads literally, it cannot do arithmetic, it treats dates as text. These are the ones that bite specifically when you are using Jev to judge.
>
> - It cannot abstain. A forced binary with no unknown or needs_review option makes Jev pick the least wrong answer instead of saying it does not know. You have to think about and design an escape hatch, at least early on before calibrating your judge.
>
> - No rationale, when you actually need one. Good for eval design, bad for the individual case. Jev is[ not trained to generate text](https://docs.typesafe.ai/model-jaggedness/jev-1.13), so when a trace scores badly it never provides a reasoning. You debug by reading your own criteria. Anything audited or customer facing still needs a generative model on top.
>
> - Context rot, and the limit is unclear. Their docs say it plainly:[ "Jev suffers from context rot"](https://docs.typesafe.ai/model-jaggedness/jev-1.13). Accuracy drops as the state fills with material the question does not need, which is awkward when agent traces are long and mostly irrelevant. This refocuses importance on designing the input context, much like in the gpt-3.5 days. The[ models page](https://docs.typesafe.ai/models) says 64k per request and 32k for state plus the longest question, while[ OpenRouter](https://openrouter.ai/typesafe/jev-1.13) lists 32K. Verify before you design around it.
>
> ## How to use Jev to evaluate your Langfuse traces
>
> Access runs through a [waitlist](https://typesafe.ai/), and Jev is also live on [OpenRouter](https://openrouter.ai/typesafe/jev-1.13) and the [Vercel AI Gateway](https://vercel.com/ai-gateway/models/jev), which is the quicker route if you do not want to open a new vendor relationship to run a test. There are [Python and JavaScript SDKs](https://docs.typesafe.ai/sdk), and an [agent skill](https://docs.typesafe.ai/agent-skill) that gives a coding agent full API context. The [cookbooks](https://docs.typesafe.ai/llms.txt) have worked implementations for guardrails, RAG passage screening, citation checks and confidence gated classification.
>
> To score your Langfuse traces with Jev, you can simply [pull observations via the API](https://langfuse.com/docs/api-and-data-platform/features/query-via-sdk), determine a score with Jev, and [write the result back as a score](https://langfuse.com/docs/evaluation/evaluation-methods/scores-via-sdk).
>
> ```python
> #!/usr/bin/env python3
> """Score user disagreement with TypeSafe Jev and Langfuse.
>
> Writes one Boolean verdict to Langfuse and includes Jev's probability
> distribution in the score comment.
>
> This example assumes each candidate generation has an input shaped like:
>
>     {"messages": [{"role": "user", "content": "..."}, ...]}
>
> Install and configure:
>
>     pip install -U langfuse typesafe-sdk
>
>     export LANGFUSE_PUBLIC_KEY="pk-lf-..."
>     export LANGFUSE_SECRET_KEY="sk-lf-..."
>     export LANGFUSE_BASE_URL="https://cloud.langfuse.com"
>     export TYPESAFE_API_KEY="..."
>     export TRACE_ID="..."
>
>     python score_user_disagreement_v2.py
> """
>
> import json
> import os
>
> from langfuse import get_client
> from typesafe_sdk import Noul, NoulCriteria, TypeSafeClient
>
>
> TRACE_ID = os.environ["TRACE_ID"]
> MODEL = "jev-1.13.0"  # Pin the model because the verdict uses a fixed threshold.
> THRESHOLD = 0.7
>
> langfuse = get_client()
>
>
> USER_DISAGREEMENT = Noul(
>     instructions=(
>         "Does `last_user_message` clearly communicate that the user believes "
>         "the assistant's prior response or approach was mistaken or proceeding "
>         "in the wrong direction? Evaluate the user's expressed perception, not "
>         "objective correctness."
>     ),
>     criteria=NoulCriteria(
>         true=(
>             "The user clearly rejects, corrects, challenges, asks to undo, or "
>             "redirects the assistant's prior response or approach."
>         ),
>         false=(
>             "The user does not clearly reject the prior response. This includes "
>             "neutral, additive, or ambiguous follow-ups."
>         ),
>     ),
> )
>
>
> def parse_json(value):
>     """Observations V2 can return input and output as JSON strings."""
>     if isinstance(value, str):
>         try:
>             return json.loads(value)
>         except json.JSONDecodeError:
>             pass
>     return value
>
>
> def latest_user_message(observation):
>     """Return the newest user message, or None when there is no user message."""
>     observation_input = parse_json(observation.input)
>     messages = observation_input.get("messages", [])
>
>     for message in reversed(messages):
>         if message.get("role") == "user":
>             return message.get("content")
>     return None
>
>
> def main():
>     # `api.observations` is the Observations V2 API in the current Python SDK.
>     response = langfuse.api.observations.get_many(
>         trace_id=TRACE_ID,
>         type="GENERATION",
>         fields="core,basic,io",
>         limit=50,
>     )
>
>     # Only keep generations whose input contains a user message.
>     turns = [
>         (observation, user_message)
>         for observation in response.data
>         if (user_message := latest_user_message(observation)) is not None
>     ]
>     turns.sort(key=lambda turn: turn[0].start_time)
>
>     # TypeSafeClient reads TYPESAFE_API_KEY and TYPESAFE_BASE_URL from the
>     # environment. The context manager closes the HTTP client after the run.
>     with TypeSafeClient(model=MODEL) as jev:
>         # User message N+1 is the reaction to assistant reply N.
>         for (reply, _), (_, reaction_message) in zip(turns, turns[1:]):
>             result = jev.system_one(
>                 state={
>                     "conversation_history": parse_json(reply.input),
>                     "assistant_reply": parse_json(reply.output),
>                     "last_user_message": reaction_message,
>                 },
>                 questions={"user_disagreement": USER_DISAGREEMENT},
>             )
>
>             # A Noul is P(true), so P(false) is its complement.
>             p_disagreement = float(result.nouls["user_disagreement"].noul)
>             p_no_disagreement = 1.0 - p_disagreement
>
>             langfuse.create_score(
>                 score_id=f"{reply.id}-user-disagreement",
>                 trace_id=reply.trace_id,
>                 observation_id=reply.id,
>                 name="user_disagreement",
>                 value=1 if p_disagreement >= THRESHOLD else 0,
>                 data_type="BOOLEAN",
>                 comment=(
>                     f"TypeSafe {result.model}; "
>                     f"P(disagreement)={p_disagreement:.2f}; "
>                     f"P(no disagreement)={p_no_disagreement:.2f}; "
>                     f"threshold={THRESHOLD}"
>                 ),
>             )
>
>             print(
>                 f"{reply.id}: P(disagreement)={p_disagreement:.2f}, "
>                 f"P(no disagreement)={p_no_disagreement:.2f}"
>             )
>
>     # Flush buffered score events before this short-lived script exits.
>     langfuse.flush()
>
>
> if __name__ == "__main__":
>     main()
>
> ```
>
> ---
>
> Posted: Fri Sep 18 14:58:57 +0000 2026
> Source: https://x.com/annabellschfr/status/2100962787094597807
> Engagement: 59 likes, 9 retweets, 1 reply
