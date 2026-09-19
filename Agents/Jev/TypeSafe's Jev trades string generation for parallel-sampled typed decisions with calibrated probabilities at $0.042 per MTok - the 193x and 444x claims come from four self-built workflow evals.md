---
created: 2026-09-19
description: TypeSafe AI's first System One Model returns schema-guaranteed structured decisions with calibrated probabilities in one parallel sample instead of generating strings, priced at $0.042 per MTok input with free output, and its headline speed and cost multiples are self-reported from four in-house workflow evals scored against a GPT-6 Astra and Fable 5.1 average.
source: https://typesafe.ai/blog/introducing-system-one-models-and-jev
author: Diogo Almeida (TypeSafe AI)
published: 2026-09-15
type: knowledge
tags: [jev, system-one-models, typesafe, structured-outputs, calibration, rlcd, automation]
---

# TypeSafe's Jev trades string generation for parallel-sampled typed decisions with calibrated probabilities at $0.042 per MTok

Diogo Almeida, who worked on the instruction-following research behind ChatGPT at OpenAI, spent two years in stealth building a model class that deliberately cannot write prose. Jev is the first public one, released in early access on 15 September 2026.

## Key Takeaways

- **The product is the type signature, not the text.** Jev takes unstructured state in and returns a predeclared set of typed values out: booleans, scores, and choices, each with a calibrated probability. Because the output space is fixed before the call, schema violations are not merely rare but impossible, which is a categorically different guarantee from the constrained-decoding and retry loops that [[separating cognitive blueprints from runtime engines enables portable auditable agent systems]] describes as the standing mismatch between stochastic models and deterministic backends.
- **Parallel sampling is where the two orders of magnitude come from.** Every answer is emitted in one forward pass rather than one token at a time, which is what collapses end-to-end latency to 70ms-500ms against the 3-329 second range the post cites for frontier models. Giving up strings is the price paid for that, and the author is explicit that it is a trade, not a free win.
- **Pricing inverts the usual LLM cost model.** Input is $0.042 per MTok, roughly 5x to 240x below the $0.20-$10 band, and output is free because there are no output tokens to meter. That matters most for the exact workloads [[context tax compounds through cache misses bloated tools and unbudgeted output tokens]] identifies as unbudgeted, and it is the concrete version of the near-free-inference premise behind [[Berkeley's EPIC Data Lab argues near-free intelligence makes agents the dominant data-systems workload, needing data systems for, of, and by agents]] and [[Snowflake, Databricks and ClickHouse preview AI architecture by turning inference into a database operator, the semantic layer into agent infrastructure, and agents into a new database workload]].
- **RLCD replaces preference with calibration as the optimization target.** Reinforcement Learning for Calibrated Decisions optimizes for epistemically honest probabilities rather than rater-preferred text (RLHF) or programmatically checkable answers (RLVR). Almeida calls this the bitterest lesson: picking the right task matters more than data, compute, or algorithms. Calibration as an actionable output, not a decoration, is the same move [[BARGAIN routes classification to a small model via a confidence threshold calibrated on 500 oracle labels, cutting costs up to 86 percent more than competing cascades]] and [[LATTICE uses LLM-guided semantic tree traversal with calibrated scoring to achieve logarithmic-complexity retrieval that outperforms reranking on reasoning-intensive benchmarks]] make in narrower settings.
- **The skeptic's read: three claims are checkable, the headline multiples are not.** Speed per call, price per call, and the zero-type-error guarantee are all independently falsifiable, and the post says so. The 193.6x faster and 444.6x cheaper figures are not: they come from four workflows TypeSafe authored, run through a harness TypeSafe wrote, scored against a reference answer that is the average of two competitor models. TypeSafe discloses each of those biases itself, which is more than most launch posts do, but disclosure is not independent replication. The same thesis reached through ordinary engineering is in [[LangChain's Paid Media Agent got 40x cheaper and 13x faster by moving calculations out of the model into code]], which got 40x cheaper and 13x faster by moving the arithmetic out of the model, and it did not need a new model class to do it.
- **Zero percent is an axiom, not a measurement.** The type-error charts put Jev at 0% next to LLM rates that run from 0.58% to 45.5%, and the post states plainly that its own number is not empirical: schema matching is guaranteed, so 0% was added to the plot by construction. The competitor numbers come from OpenRouter traffic, which routes harder queries to better models, so the comparison is between a theorem and a biased sample.

## Frontiers, Old and New

The comparison table as published, both columns intact.

| | Existing LLMs | System One + Jev |
|---|---|---|
| **Optimized with** | Reinforcement Learning with Human Feedback (RLHF) / Reinforcement Learning with Verifiable Rewards (RLVR) | Reinforcement Learning for Calibrated Decisions (RLCD) |
| **Optimizes for** | Human preference: writeups and chat responses that human raters prefer.<br><br>Verifiable rewards: outputs that can be programmatically verified. | Calibrated decisions: answers with epistemically honest probabilities on System One tasks. |
| **Inputs** | Unstructured data (e.g. text) with an emphasis on **sequential messages**. | Unstructured data (e.g. text) with an emphasis on **structured program state**. |
| **Outputs** | **Strings / generated text.** Strings are flexible and can be anything: chat responses, code, hallucinations, refusals, or even type-safe structured values. To be used by software, responses need to be parsed + validated. There is also always some risk that the AI goes off the rails. | **Type-safe structured values.** Possible outputs and structure are defined in advance. The model never makes type errors. All answers are accompanied with calibrated probabilities and confidence scores. |
| **Sampling** | **Sequential.** Generates one token at a time, each conditioned on the last. | **Parallel.** Generates all outputs in a single query. Incredibly efficient and hardware-aware. |
| **Cost** | Input tokens: from $0.20 to $10 / MTok.<br><br>Output tokens: ~5x more expensive than input tokens. | Input tokens: $0.042 / MTok ($42 per billion tokens).<br><br>Output tokens: FREE (too cheap to meter). |
| **Speed** | **End-to-end response time is 3 to 329 seconds** for frontier models. Fast enough for interfacing with humans, but a big bottleneck when integrated in code. | **End-to-end response time is 70ms-500ms** for TypeSafe. This can range from 40x-200x faster for the same levels of frontier intelligence for System One shaped queries. |
| **Confidence** | Even if prompted for a confidence estimate, models tend to be overconfident and inconsistent. If a model can do a task 95% of the time but doesn't say when it's in the 5%, it can't automate that task. | Always communicates confidence and uncertainty with every output. Calibrated: higher confidence means higher accuracy. More consistent: returns similar answers for similar inputs. |
| **Use cases** | **Human-in-the-loop tasks (chatbots, copilots, coding agents).** General and powerful, but requires human oversight because their freedom also means they might go off the rails.<br><br>**Verifiable problems (math proofs, kernel optimization).** When correctness can be checked cheaply and automatically, LLMs can generate, test, and iterate until they find something that works.<br><br>**Demos.** The flexibility of strings allows it to be incredible for quickly making prototypes that only work sometimes. | **AI-Powered Workflows / smart if-statements.** Structured outputs slot into ordinary software as fuzzy decision rules: classify, route, score, extract, or branch where hand-written logic is too brittle. The surrounding code constrains their freedom, making them easier to compose into reliable systems.<br><br>**Map-reducing over big data.** Turn petabytes of data into features and insights.<br><br>**Real-time applications.** 100ms speeds means you can use AI in your applications where UX is critical.<br><br>**Verify everything.** Score, judge, verify, guardrail, and detect jailbreaks of LLM prompts, reasoning traces, and/or outputs.|

## Use Cases

The post's own FAQ answer on this is a deflection. Asked "What use cases is Jev good for?", the reply is only that TypeSafe has "found diverse use cases for Jev across industries", with a pointer to the [use case map in the docs](https://docs.typesafe.ai/concepts/use-case-map). The substance lives in the comparison table and the demos instead.

**Four families named in the table.**

1. **AI-powered workflows and smart if-statements.** Classify, route, score, extract, or branch inside ordinary code where hand-written logic is too brittle. Because the model returns a typed value rather than prose, the surrounding program constrains it, which is what makes the pieces composable. This is the same structural argument as [[RLM subagents need structured outputs not free-text to avoid losing the plot at fan-in - fast-rlm validates every FINAL]] and the typed-signature discipline in [[DSPy is a framework for programming—not prompting—language models through typed signatures and metric-driven optimizers]].
2. **Map-reduce over big data.** Turn petabytes into features and insights. Free output tokens and sub-second latency are what make per-row inference affordable at that scale, which is the workload [[Berkeley's EPIC Data Lab argues near-free intelligence makes agents the dominant data-systems workload, needing data systems for, of, and by agents]] predicts will dominate. [[Bridgewater and Thinking Machines fine-tune Qwen3-235B to replicate expert investor judgment, beating frontier LLMs on financial information-filtering at 13.8x lower cost]] reaches the same economics by fine-tuning instead.
3. **Real-time applications.** At roughly 100ms the model can sit inside a UX loop rather than behind a spinner. The Doom bot is the extreme case at 10 queries per second.
4. **Verify everything.** Score, judge, verify, guardrail, and detect jailbreaks against LLM prompts, reasoning traces, and outputs. This is the cheapest of the four to evaluate and the easiest to adopt, and it lands inside the taxonomy in [[anthropic recommends combining deterministic graders model judges and human review for agent evals]]. [[LLM Data Company experiments show explicit rubric criteria let gpt-oss-120b match Opus 4.7 at 100x lower cost and full-rubric grading beats per-criterion across every model]] is the counter-anchor on how far a cheap model plus a good rubric already gets you.

**The published workflow eval.** The one workflow diagram in the post is a security incident-response pipeline, described as the simplest of four. It runs four stages: Triage reads three properties off the alert, Disposition turns those into close, queue, or act with the asset's environment and tier in the balance, Containment runs eleven readings of the incident state, and Playbook picks the first applicable group and then the strongest action whose conditions hold. Questions are typed as Bool, Score, or Choice, and branches fire on probability thresholds such as P greater than 0.75 for act and a 0.15-0.60 grey zone that notifies a user. This is a concrete template for what "smart if-statements" means in production.

*The published workflow: a four-stage security incident-response pipeline with typed Bool, Score and Choice questions and probability-threshold branching*
![[typesafe-jev-003.png]]

**Two fun demos.**

- **Doom.** A bot plays Doom at 10 queries per second for about $7 per hour. The recorded run shows Jev answering FIRING, GOAL, JUDGE and MOVEMENT questions with confidence bars while a decision graph updates live. The author's own caveats: the bot reads a structured text representation of game state rather than pixels, and a hand-written non-AI bot would play better. The point is reactivity to changing state representations and instruction-following, not skill.
- **Wikiracing.** Navigate from one Wikipedia page to a target using only links encountered on the way, choosing between hundreds to thousands of links per step. It exercises high-cardinality choice, where not hallucinating a nonexistent link compounds across steps. Jev supports cardinality up to 255; above that it runs a two-stage system that scores options independently and then makes an explicit choice, which is where the occasional slowdown comes from.

**Ecosystem tools.** Two community projects built on the model, covered in their own notes: [[pg-jev]] and [[jevlike]].

## Evidence and Caveats

The post separates what a reader can check from what they must take on trust, and attaches an explicit Nuance list to every bolder claim. Those hedges are reproduced here next to the claim each one qualifies, because they are the most useful part of the piece for a skeptical reader.

**Claims TypeSafe says you can verify yourself**

| Claim | What TypeSafe concedes |
|---|---|
| Speed per call | "We truly are that fast, though our published evals are generally run from our laptops on the West Coast (this is where our service is currently based)." Latency numbers are therefore best-case geography. |
| Cost per call | "We make our pricing transparent. We can't prove it isn't subsidized; we'll need the long-term to prove the sustainability of our pricing (which we expect to go down, not up)." |
| No type errors | "This would be an easy thing to falsify with just a single counter-example, but it is mathematically impossible." A single counterexample would settle it, and none is claimed. |

**Side-by-side demonstration.** The recorded run puts Jev and GPT-5.6 Terra on the same 27 questions in the same order. Read off the video: Jev finished in 0.114s at $0.000081, Terra in 8.566s at $0.013880, which the overlay renders as 74.9x faster and 171.0x cheaper. Nuance, verbatim in spirit and paraphrased only for length: the query is highly simplified and the question keys were chosen to be human-readable so the screen output is legible; the input state is a short, dense paragraph chosen to emphasize the sampling difference, and the relatively shorter input "paints our model in an advantageous light"; the only disagreement in the recorded run is on "Churn likelihood level", which TypeSafe says "seems genuinely ambiguous to us"; Terra was run with default reasoning because TypeSafe finds it the closest match to Jev on average intelligence.

*Side-by-side run: 27 questions, one request each, Jev at 0.114s and $0.000081 against GPT-5.6 Terra at 8.566s and $0.013880*
![[typesafe-jev-005.png]]

**Workflow evals.** TypeSafe built a new eval format: fix the compute graph, give every model the same workflow, and score against the predictions of the largest external models rather than a ground-truth label. The four caveats attached to it are where the headline numbers come from and where they bend.

| Nuance | Why it matters |
|---|---|
| "This is where the claims of 193.6x faster, 444.6x cheaper on our home page comes from, and we expect that these are on the higher end of real world gains." | The marketing multiples are self-identified as an upper bound. |
| The workflows "were not deliberately chosen nor constructed to make our model look good, and are not in our training distribution. However, they were made by individuals on our model capabilities team, so some bias could exist." | The benchmark author and the vendor are the same party. |
| "We use the average of GPT-6 Astra and Fable 5.1 as the reference answer, which biases answers towards OpenAI and Anthropic's models. We likely underestimate the relative performance of our model and DeepSeek's models." | There is no ground truth. The target is agreement with two competitors, so the ceiling is defined by the models being beaten. |
| The LLM baselines run through TypeSafe's own System One LLM adapter, which "tends to be slower and more expensive than giving decisions without probabilities." | The harness that makes the comparison apples-to-apples also imposes a tax on the baseline. |

The Pareto chart plots accuracy against cost per workflow on a log axis. Jev sits at roughly 68% accuracy near $0.0004 per workflow, holding the frontier across almost two orders of magnitude of cost, with OpenAI's luna and terra, Anthropic's opus 5 and sonnet 5, and Fireworks' DeepSeek v4 variants to its right. The chart also distinguishes workflow runs (diamonds) from prompt runs (circles) and shows the prompt variant doing consistently worse, which is the post's argument that the gain comes from the workflow structure and not only the model.

*Workflow evals: accuracy against cost per workflow, log scale, averaged over four workflows*
![[typesafe-jev-002.png]]

**Hallucination and type safety.** Two bar charts, and the numbers are worth recording because they appear nowhere in the prose.

| Model | Structured output error rate | Tool call error rate |
|---|---|---|
| Jev | 0% | 0% |
| luna | 0.58% | 7.67% |
| terra | 0.58% | 5.5% |
| sol | 0.83% | 17.0% |
| astra | 1.43% | 16.6% |
| gemini 3.1 pro | 1.94% | 3.17% |
| gemini 3.8 flash | 3.15% | 2.15% |
| opus 5 | 5.73% | 0.67% |
| fable 5.1 | 8.25% | 1.38% |
| sonnet 5 | 13.2% | 2.07% |
| haiku 4.5 | 45.5% | 1.76% |

Both nuances undercut the chart in opposite directions. "The numbers for LLMs are from OpenRouter i.e., there almost certainly is bias here: more complex queries might be routed to better models." And: "Our number is not empirical. Schema matching is guaranteed, thus we can confidently add 0% into the plots." So the comparison sets a measured distribution against a mathematical guarantee. The guarantee is real, but it is a claim about the output format, not about whether the decision is correct.

*Structured output error rate and tool call error rate, Jev at 0% by construction against LLM rates sourced from OpenRouter*
![[typesafe-jev-004.png]]

**Wikiracing.** The recorded Baseball to Sun run: Jev 1.13.0 wins in 0.419s over 3 hops at 0.047 cents, against Claude Sonnet 5 at 3.724s over 4 hops and 3.310 cents, Claude Haiku 4.5 at 4.975s over 6 hops and 1.030 cents, and GPT-5.6 Terra at 9.453s over 6 hops and 2.044 cents with one hallucination. The overlay reports 8.89x faster and 71.1x cheaper, and the footnote says model time excludes Wikipedia loading. TypeSafe's own nuance is unusually candid here: "Our speedups here tend to be a lot less than in previous demos. That's because this is against the non-reasoning modes of the models (except Astra which was set to the lowest reasoning setting)... The LLMs look much worse at this task than with reasoning enabled." The lower multiple is the more honest one.

*Wikirace results, Baseball to Sun: Jev wins in 0.419 seconds over 3 hops at 8.89x faster and 71.1x cheaper, GPT-5.6 Terra logs one hallucination*
![[typesafe-jev-007.png]]

*The Doom bot: game state on the left, live Jev decisions with confidence bars on the right, decision graph below*
![[typesafe-jev-006.png]]

**No public benchmarks, by policy.** TypeSafe declines to publish against public benchmarks and says it plans only one-off evals at product updates, advocating instead that users put no weight on public benchmarks, build their own evals, disclose eval nuance, and de-emphasize benchmarks even when ahead. That is a defensible position and also a convenient one, since it means the only numbers in circulation are the vendor's.

## Related

- [[RLM subagents need structured outputs not free-text to avoid losing the plot at fan-in - fast-rlm validates every FINAL]]
- [[DSPy is a framework for programming—not prompting—language models through typed signatures and metric-driven optimizers]]
- [[LangChain's Paid Media Agent got 40x cheaper and 13x faster by moving calculations out of the model into code]]
- [[LATTICE uses LLM-guided semantic tree traversal with calibrated scoring to achieve logarithmic-complexity retrieval that outperforms reranking on reasoning-intensive benchmarks]]
- [[Snowflake, Databricks and ClickHouse preview AI architecture by turning inference into a database operator, the semantic layer into agent infrastructure, and agents into a new database workload]]
- [[Berkeley's EPIC Data Lab argues near-free intelligence makes agents the dominant data-systems workload, needing data systems for, of, and by agents]]
- [[Sam Z Liu's context gold rush map - why everyone is building the same org-level company brain]]
- [[BARGAIN routes classification to a small model via a confidence threshold calibrated on 500 oracle labels, cutting costs up to 86 percent more than competing cascades]]
- [[separating cognitive blueprints from runtime engines enables portable auditable agent systems]]
- [[anthropic recommends combining deterministic graders model judges and human review for agent evals]]
- [[LLM Data Company experiments show explicit rubric criteria let gpt-oss-120b match Opus 4.7 at 100x lower cost and full-rubric grading beats per-criterion across every model]]
- [[Bridgewater and Thinking Machines fine-tune Qwen3-235B to replicate expert investor judgment, beating frontier LLMs on financial information-filtering at 13.8x lower cost]]
- [[context tax compounds through cache misses bloated tools and unbudgeted output tokens]]

## Ecosystem

- [[pg-jev]]
- [[jevlike]]
- [[jev-align]] — Sutro's GEPA CLI that tunes a Jev task's criteria text to your labels; see [[Sutro's jev-align uses GEPA to rewrite Jev's decision criteria from five labeled examples - the demo moves labeled-set ambiguity 49.6 points but full-pool certainty only 0.5]] for the launch demo and its numbers

## Original Content

The full post as published, with the FAQ accordions expanded and the page's images and demo frames embedded at their positions.

> [!quote]- Introducing System One Models & Jev — Diogo Almeida, founder, TypeSafe (Sep 15, 2026)
>
> *Article cover art*
> ![[typesafe-jev-001.png]]
>
> # Introducing System One Models & Jev
>
> *Diogo Almeida, founder, TypeSafe*
>
> Models have been superhuman at chat for years, so where is all the automation?
>
> This has been my driving question for the last four years. At OpenAI, I helped build the methods that made language models useful at following instructions and talking with people. That work ended up as the research behind ChatGPT. At the time, I thought maybe chat models would lead to AGI, but despite the hype it became obvious to me that there was something really big missing.
>
> After two years in stealth, countless technical challenges, and research breakthroughs… I am beyond excited to announce that today, TypeSafe AI is releasing our first **System One Model**: a new class of frontier models built to make fast, structured decisions that software can use directly.
>
> We built a new stack entirely focused on automation: with a new model architecture, parallel sampler for maximum efficiency, and training method we call Reinforcement Learning for Calibrated Decisions (RLCD).
>
> Our first public model is **Jev**, available today in early access. Jev achieves similar levels of intelligence on System One tasks compared to existing LLMs, while being two orders of magnitude faster and more efficient. While Jev gives up string generation, it's optimized for structured outputs and *can't* hallucinate.
>
> Think of Jev as a frontier-intelligence function call: unstructured state in, typed probabilistic decisions out.
>
> Extraordinary claims require extraordinary evidence so see below for the receipts. 💅
>
> ## Frontiers, Old and New
>
> | | **Existing LLMs** | **System One + Jev** |
> |---|---|---|
> | Optimized with | Reinforcement Learning with Human Feedback (RLHF) / Reinforcement Learning with Verifiable Rewards (RLVR) | Reinforcement Learning for Calibrated Decisions (RLCD) |
> | Optimizes for | Human preference: writeups and chat responses that human raters prefer.<br><br>Verifiable rewards: outputs that can be programmatically verified. | Calibrated decisions: answers with epistemically honest probabilities on System One tasks. |
> | Inputs | Unstructured data (e.g. text) with an emphasis on **sequential messages**. | Unstructured data (e.g. text) with an emphasis on **structured program state**. |
> | Outputs | **Strings / generated text.** Strings are flexible and can be anything: chat responses, code, hallucinations, refusals, or even type-safe structured values. To be used by software, responses need to be parsed + validated. There is also always some risk that the AI goes off the rails. | **Type-safe structured values.** Possible outputs and structure are [defined in advance](https://docs.typesafe.ai/). The model never makes type errors. All answers are accompanied with calibrated probabilities and confidence scores. |
> | Sampling | **Sequential.** Generates one token at a time, each conditioned on the last. | **Parallel.** Generates all outputs in a single query. Incredibly efficient and hardware-aware. |
> | Cost | Input tokens: from $0.20 to $10 / MTok.<br><br>Output tokens: ~5x more expensive than input tokens. | Input tokens: $0.042 / MTok ($42 per billion tokens).<br><br>Output tokens: FREE (too cheap to meter). |
> | Speed | **End-to-end response time is [3 to 329 seconds](https://llm-benchmarks.diegoromero.es/)** for frontier models. Fast enough for interfacing with humans, but a big bottleneck when integrated in code. | **End-to-end response time is 70ms-500ms** for TypeSafe. This can range from 40x-200x faster for the same levels of frontier intelligence for System One shaped queries. |
> | Confidence | Even if prompted for a confidence estimate, models tend to be overconfident and inconsistent. If a model can do a task 95% of the time but doesn't say when it's in the 5%, it can't automate that task. | Always communicates confidence and uncertainty with every output. Calibrated: higher confidence means higher accuracy. More consistent: returns similar answers for similar inputs. |
> | Use cases | **Human-in-the-loop tasks (chatbots, copilots, coding agents).** General and powerful, but requires human oversight because their freedom also means they might go off the rails.<br><br>**Verifiable problems (math proofs, kernel optimization).** When correctness can be checked cheaply and automatically, LLMs can generate, test, and iterate until they find something that works.<br><br>**Demos.** The flexibility of strings allows it to be incredible for quickly making prototypes that only work sometimes. | **AI-Powered Workflows / smart if-statements.** Structured outputs slot into ordinary software as fuzzy decision rules: classify, route, score, extract, or branch where hand-written logic is too brittle. The surrounding code constrains their freedom, making them easier to compose into reliable systems.<br><br>**Map-reducing over big data.** Turn petabytes of data into features and insights.<br><br>**Real-time applications.** 100ms speeds means you can use AI in your applications where UX is critical.<br><br>**Verify everything.** Score, judge, verify, guardrail, and detect jailbreaks of LLM prompts, reasoning traces, and/or outputs. |
>
> ## Evidence / Technical Results
>
> We love skeptics, and are skeptics ourselves.
>
> There are some claims you can easily verify:
> - **Speed per call:** We truly are that fast, though our published evals are generally run from our laptops on the West Coast (this is where our service is currently based).
> - **Cost per call:** We make our pricing transparent. We can't prove it isn't subsidized; we'll need the long-term to prove the sustainability of our pricing (which we expect to go down, not up).
> - **No type errors**: This would be an easy thing to falsify with just a single counter-example, but it is mathematically impossible.
>
> For our bolder claims, we want to provide as much nuance as we can.
>
> ### Side-by-side demonstration
>
> Our side-by-side demo shows a key difference between our models and LLMs: Jev outputs all probabilities in parallel instead of autoregressively generating by token. Strings are extremely powerful and general, but costly. "Giving up" strings actually gives us a lot of superpowers!
>
> *Embedded video: [typesafe-race-white-720p](https://player.vimeo.com/video/1227496082). Frame captured at completion — Jev 0.114s / $0.000081 against gpt-5.6-terra 8.566s / $0.013880, headline 74.9x faster and 171.0x cheaper on the same 27 questions*
> ![[typesafe-jev-005.png]]
>
> ##### Nuance
> - For people with early access to TypeSafe, here is the [actual query](https://console.typesafe.ai/playground?share=shr_13a74b495fb786c4bd7964f11597301e7c9).
>    - The query is highly simplified and `questions` were chosen to have descriptive, human-readable keys so that the output on the screen is understandable.
>    - The `state` is also a short, dense, and detailed paragraph, to emphasize the difference in sampling methodology. The relatively shorter input paints our model in an advantageous light.
> - For the keen eyed, for the recorded run, the only disagreement with GPT-5.6 Terra is on "Churn likelihood level". The actual answer seems genuinely ambiguous to us.
> - We used GPT-5.6 Terra with default reasoning for this example, because we've found it to be the most comparable at intelligence to Jev on average.
> - Fun fact: a similar demo was what convinced us to go all-in in the direction of System One Models!
>
> ### Workflow evals
>
> We made a new type of evaluation to measure how well AI works within code. We don't optimize for a ground truth classification or allow the harness and model to change (potentially allowing for overfitting via harness engineering). Instead, we assume there is a correct compute graph (a "workflow" represented in code) and use the predictions of the largest, smartest, and most expensive external models as reference probabilities.
>
> Rephrased: every model gets the same workflow. We test how they compare to the average of the smartest models (in this case, Astra and Fable).
>
> *Average of 4 workflows: accuracy vs cost, log scale. Jev holds the frontier at roughly 68% near $0.0004 per workflow; diamonds are workflow runs, circles are prompt runs*
> ![[typesafe-jev-002.png]]
>
> Jev is off the charts – owning the Pareto frontier for almost 2 orders of magnitude. We also compare to models with a generated prompt doing all the logic in their chain-of-thought, but this tends to do significantly worse than using the workflow itself.
>
> Note that the calls here are significantly more complex than the side-by-side demonstration above. That's because they're more representative of the types of production workloads needed for true business automation. Below is the simplest of the 4 workflows we're publishing:
>
> *The simplest of the four published workflows: a security incident-response pipeline running Triage, Disposition, Containment and Playbook over Bool, Score and Choice questions*
> ![[typesafe-jev-003.png]]
>
> The most reliable real-world workflows tend to have many independent, decomposed questions, with fine-grained behavior that's dependent on probabilities instead of discrete decisions. The end result is discrete branching, but how we get to a final answer involves a lot of domain-specific engineering that needs to be done highly consistently.
>
> See [our workflow evals site](https://evals.typesafe.ai/) for all the details: examples, disagreements, full queries, and each workflow.
>
> ##### Nuance
> - This is where the claims of 193.6x faster, 444.6x cheaper on our home page comes from, and we expect that these are on the higher end of real world gains.
> - These content of these workflows were not deliberately chosen nor constructed to make our model look good, and are not in our training distribution. However, they were made by individuals on our model capabilities team, so some bias could exist.
> - We use the average of GPT-6 Astra and Fable 5.1 as the reference answer, which biases answers towards OpenAI and Anthropic's models. We likely underestimate the relative performance of our model and DeepSeek's models.
> - The LLMs use our [System One LLM](https://github.com/typesafe-ai/system-one-adapter-python) wrapper, which constrains LLMs to output structured decisions compatible with our API. We have found this to be the most accurate way to get decisions from LLMs, but this tends to be slower and more expensive than giving decisions without probabilities.
>
> ### Hallucination and Type-safety
>
> *Structured output error rate and tool call error rate, lower is better. Jev at 0% in both; structured output runs from luna 0.58% to haiku 4.5 45.5%, tool calls from opus 5 0.67% to sol 17.0%*
> ![[typesafe-jev-004.png]]
>
> Hallucination and type-safety are intrinsically related, and we think the latter is table stakes for automation. Having a hallucinated tool call is inconvenient in an agent, but is an absolute deal-breaker if it's part of a system with latency guarantees or it's buried several layers deep in a dependency chain. Existing models, *no matter how smart*, still hallucinate and have type errors.
>
> ##### Nuance
> - The numbers for LLMs are from OpenRouter i.e., there almost certainly is bias here: more complex queries might be routed to better models.
> - Our number is not empirical. Schema matching is guaranteed, thus we can confidently add 0% into the plots.
>
> ### Fun Demos
>
> Perhaps the most exciting part of our work is enabling new use cases. We have a lot more to show you, but here are a couple of the team's favorites:
>
> #### Doom
>
> We love how this doomo doomonstrates real-time intelligence and what can be doone with code + AI. The engineer behind it was worried about making 10 queries a second (which ends up costing ~$7/hour), but the rest of us agreed that was lower than expected! This is so fun we intend to not only release an in-depth walkthrough, but also host some events to hack on this.
>
> *Embedded video: [Jev-Demo-Doom-Full](https://player.vimeo.com/video/1227495732). Frame captured mid-run — game view left, live Jev decisions with confidence bars right (FIRING, GOAL, JUDGE, MOVEMENT), decision graph below*
> ![[typesafe-jev-006.png]]
>
> ##### Nuance
> - The demo is on structured state as a data structure with text, not on images (yet…)
> - A non-AI doom bot could play better, but we wanted a bot that was reactive to different representations of game state, and most importantly… following instructions was cool as heck!
>
> #### Wikiracing
>
> The objective of the game is to start on one Wikipedia page and reach a specific other Wikipedia page using only links you come across while traversing. Each step can mean choosing between hundreds to thousands of links! It's a great playground for demonstrating not just intelligence-per-second, but also the compounding benefits of not hallucinating with high-cardinality choices.
>
> *Embedded video: [Jev-Demo-Wikirace](https://player.vimeo.com/video/1227495711). Results card for Baseball to Sun — Jev 1.13.0 wins in 0.419s over 3 hops at 0.047¢, 8.89x faster and 71.1x cheaper; Sonnet 5 3.724s / 4 hops / 3.310¢; Haiku 4.5 4.975s / 6 hops / 1.030¢; GPT-5.6 Terra 9.453s / 6 hops / 2.044¢ with 1 hallucination*
> ![[typesafe-jev-007.png]]
>
> ##### Nuance
> - As far as we know, it was completely random that both the 2nd and 3rd challenges started with "Rubber Duck." The author only noticed when the team pointed it out.
> - Our speedups here tend to be a lot less than in previous demos. That's because this is against the non-reasoning modes of the models (except Astra which was set to the lowest reasoning setting). This is also why Jev tended to finish in fewer steps (a sign of greater intelligence). This was to make the demo more bearable to watch. The LLMs look much worse at this task than with reasoning enabled.
> - Jev supports a cardinality up to 255. For the higher cardinality choices, we do a 2 stage-system of scoring independently then making an explicit choice, hence the occassional slowdown.
>
> ## What's next
>
> We're still in Jev's early days. We have a lot more in the pipeline and are so excited to keep on shipping 🔥.
>
> Today, we are opening [early access](https://typesafe.ai/) and bringing developers off the waitlist as quickly as we can. We want to hear which decisions you need to automate, where Jev works, and where it falls short. Tell us what sci-fi you want to build!!
>
> We started TypeSafe because we believe that AI needs an interface software could depend on. We can't wait to see new use cases *continuously diffuse* through the community and economy.
>
> ### We Give A FAQ
>
> **Where do the names "System One Models" and "Jev" come from?**
>
> We were inspired by Daniel Kahneman, [Thinking, Fast and Slow](https://www.penguinrandomhouse.com/books/89308/thinking-fast-and-slow-by-daniel-kahneman/). The model class name draws on the distinction between fast, intuitive System 1 thinking and slow, deliberate System 2 reasoning.
>
> "System 1 thinking" has also implied error-prone. For reasons we will get into in the future, we believe System One Models can be made more reliable than its alternatives.
>
> We named Jev after William Stanley Jevons. We expect machine intelligence to follow a similar path to coal, after steam-engine efficiency led to an increase in demand. Every order of magnitude drop in the cost of intelligence unlocks orders of magnitude more use cases.
>
> **Why was a new training algorithm needed?**
>
> Every lab optimizes for the same task during Reinforcement Learning with Human Feedback (RLHF): produce the text that a human rater prefers. That was the right task for a chat product, but it is the wrong task for automation. This is what we call [the bitterest lesson](https://typesafe.ai/blog/bitterest-lesson): optimizing for the right task matters more than data, compute, or algorithms.
>
> RLVR is great for tasks with simple programmatic verification, but most real-world judgement tasks don't fit into that shape. This tends to cause spikey / non-robust intelligence.
>
> **What use cases is Jev good for?**
>
> We've found diverse use cases for Jev across industries. We outline some [in our docs](https://docs.typesafe.ai/concepts/use-case-map), and are excited to see what else developers build.
>
> **Is Jev just a smaller LLM?**
>
> Jev is neither small nor an LLM, hence being off the intelligence Pareto curve.
>
> **How does Jev perform against public benchmarks?**
>
> We deliberately chose not to publish performance against public benchmarks. In fact, we plan to only have one-off evals when we make product updates.
>
> Given that we are opening up a new frontier for models, we're pushing for more useful best practices:
>
> - Put no weight on public benchmarks.
> - Encourage users to create their own evals for their use cases (System One tasks are much easier to evaluate).
> - Disclose the nuance in your evals.
> - De-emphasizing benchmarks even when you're ahead.
>
> See [this blog post](https://typesafe.ai/blog/antibenchmaxxing) about our philosophy around optimizing for benchmarks.
>
> **Where does our training data come from?**
>
> TypeSafe is primarily a data research lab, which is how the biggest results in AI get made. We make all the data ourselves. We wouldn't train on your data even if you asked us to (no offense). We do some pretty sophisticated stuff, but if you want to find out more, we'd have to hire you.
>
> **These are results are kinda crazy - how is it possible?**
>
> See our blog post on [AI's bitterest lesson](https://typesafe.ai/blog/bitterest-lesson). The short answer is that you get what you optimize for. LLMs optimized for being incredible chatbots and copilots, which made them superhuman at those humans-in-the-loop tasks. We're optimizing for the System One interface.
>
> TypeSafe AI © 2026

## Links

- [Introducing System One Models & Jev](https://typesafe.ai/blog/introducing-system-one-models-and-jev) — the source post, TypeSafe AI blog, 15 September 2026
- [docs.typesafe.ai](https://docs.typesafe.ai/) — API and schema documentation, where output structure is declared in advance
- [Use case map](https://docs.typesafe.ai/concepts/use-case-map) — the docs page the "what use cases" FAQ answer defers to
- [evals.typesafe.ai](https://evals.typesafe.ai/) — the workflow evals site with examples, disagreements, full queries, and each of the four workflows
- [Playground share link for the side-by-side query](https://console.typesafe.ai/playground?share=shr_13a74b495fb786c4bd7964f11597301e7c9) — requires early access
- [typesafe-ai/system-one-adapter-python](https://github.com/typesafe-ai/system-one-adapter-python) — the System One LLM adapter that constrains LLMs to emit API-compatible structured decisions, used for every baseline in the workflow evals
- [The bitterest lesson](https://typesafe.ai/blog/bitterest-lesson) — TypeSafe's argument that optimizing for the right task beats data, compute, and algorithms
- [Antibenchmaxxing](https://typesafe.ai/blog/antibenchmaxxing) — TypeSafe's stated philosophy on why it publishes no public-benchmark numbers
- [Thinking, Fast and Slow](https://www.penguinrandomhouse.com/books/89308/thinking-fast-and-slow-by-daniel-kahneman/) — Daniel Kahneman, the source of the System One naming
- [llm-benchmarks.diegoromero.es](https://llm-benchmarks.diegoromero.es/) — the third-party latency benchmark behind the 3 to 329 second figure
- [@typesafeai on X](https://x.com/typesafeai) — company account
- Demo videos, not downloaded: [side-by-side race](https://player.vimeo.com/video/1227496082), [Doom](https://player.vimeo.com/video/1227495732), [Wikirace](https://player.vimeo.com/video/1227495711)
