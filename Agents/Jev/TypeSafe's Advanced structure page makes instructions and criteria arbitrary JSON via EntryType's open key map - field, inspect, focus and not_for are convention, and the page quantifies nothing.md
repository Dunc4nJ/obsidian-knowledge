---
created: 2026-09-22
source: https://docs.typesafe.ai/primitives/advanced
via: https://x.com/dotpem/status/2102119751774527859
author: TypeSafe AI (docs); post by Nathan LeClaire (TypeSafe)
type: knowledge
tags: [jev, typesafe, docs, primitives, structured-criteria, rubric, taxonomy, question-design, system-one-models]
description: TypeSafe's Advanced structure docs page opens instructions, Choice option values, Score levels and Noul true/false to any JSON, but EntryType is an open string-to-JsonValue map, so every field name in every example is convention rather than schema, and the page states no measured benefit for structure at all.
---

## Key Takeaways

- **There is no schema. `EntryType` is an open key map, so every field name on the page is a convention the model reads as English, not an interface it validates against.** The page links each of the four structurable fields to [`EntryType`](https://docs.typesafe.ai/sdk/javascript/api/type-aliases/EntryType), whose whole definition is `string | { [key: string]: JsonValue } | JsonValue[] | null`. That single line is the most load-bearing fact here and the page never says it out loud. It means `field`, `extracted_value`, `question`, `focus`, `note`, `inspect`, `compare`, `what`, `not_for`, `examples`, `summary` and `signals` are just keys the authors happened to pick, and the page itself is inconsistent across its own five examples. It also explains why [[Annabell frames TypeSafe's Jev as a savant for eval verdicts and routing - three question types, 255 choices, 10 score levels, and a Noul with no confidence field]] can use `scope`, `definition` and `includes` where the docs use `focus`, `what` and `examples` and still be correct. Nothing was violated because nothing was specified.
- **An employee shouting "USE THE STRUCTURED CRITERIA" points at a page with zero numbers in it.** Nathan LeClaire works at TypeSafe. The page he links contains no accuracy delta, no confidence delta, no consistency measurement, no ablation, and no token counts. Its two stated reasons for structuring are "when it helps with clarity" and "when question needs supporting data", both asserted. Structure here is a documented best practice, not a measured one. The measured case for explicit written criteria lives outside TypeSafe's docs, in [[LLM Data Company experiments show explicit rubric criteria let gpt-oss-120b match Opus 4.7 at 100x lower cost and full-rubric grading beats per-criterion across every model]], which is the evidence this page is missing.
- **The sibling pages contradict the post's urgency, and they are the more careful advice.** Choice, Score and Noul each say some version of "Start with strings" and escalate to objects only on a specific observed failure: when the model keeps confusing two neighbouring options, or keeps scoring between two levels on inputs you think are clear. That is a debugging escalation triggered by evidence, not a default. Prose is still the default because structure costs tokens on every call while buying nothing on questions the model already gets right.
- **Structured criteria roughly triple the per-question token bill, and Jev charges input only.** Rewriting the Noul page's string criteria into the advanced page's object form takes the question from about 59 to about 180 tokens by my estimate at 3.6 characters per token; the three-option Choice goes from about 48 to about 142. At the $0.042 per MTok in [[TypeSafe's Jev trades string generation for parallel-sampled typed decisions with calibrated probabilities at $0.042 per MTok - the 193x and 444x claims come from four self-built workflow evals]] that is roughly four to five dollars more per million questions. Negligible against an LLM, real against Jev's own economics, and worth caching per [[jevcache]] because the criteria block is the static half of every request.
- **Taken with jev-align, this page is the schema for the only tunable surface a Jev question has.** [[Sutro's jev-align uses GEPA to rewrite Jev's decision criteria from five labeled examples - the demo moves labeled-set ambiguity 49.6 points but full-pool certainty only 0.5]] mutates exactly `instructions`, `true_criteria` and `false_criteria`, because that is all there is to mutate. A Jev question has no temperature, no few-shot slots, no system prompt and no reasoning budget. The criteria text is the entire optimization target, and this page describes its shape.

## Where and When Structure Is Allowed

The page's rule table is short and worth quoting exactly. Every one of the four fields is an `EntryType`.

| Field | Applies to | Accepted shape |
| --- | --- | --- |
| `instructions` | Choice, Score, Noul | `string`, `object`, `array`, or `null` |
| `criteria` values (option descriptions) | Choice | `string`, `object`, `array`, or `null` |
| `criteria` entries (level descriptions) | Score | `string`, `object`, `array`, or `null` |
| `criteria.true` and `criteria.false` | Noul | `string`, `object`, `array`, or `null` |

The two rules for when to reach for JSON are given verbatim as:

> **When it helps with clarity.** When a question has multiple parts, putting them in the form of JSON helps with clarity because the keys are labeled.

> **When question needs supporting data.** A schema, a taxonomy, or a database row is already JSON. Use the JSON entirely or pass in the relevant subfields instead of serializing them into a string template.

The second rule is the sharper one and it is really an anti-serialization rule. If the thing you want the model to consider is already structured, do not flatten it into an f-string; hand it over as the object it already is. The page's one-line justification for the whole feature sits above the table: "System One models are trained to understand structure."

Note what the page does **not** say. It never restates the 255-option Choice cap or the 10-level Score cap, and it never claims structure changes them. Those caps live on the sibling pages and they count options and levels, not bytes, so an object-valued option consumes exactly one of the 255 slots just as a string does. Structure buys description depth per option, never option count.

## Structured Instructions

The first example is the densest thing on the page. One `field` object describes the column being checked and four questions of three different types all refer to it, from a single invoice string as state.

```json
{
  "state": {
    "source_text": "Invoice #4471 issued March 3, 2026 to Beaver Dam Logistics for $12,840.00, net 30."
  },
  "questions": {
    "invoice_number_is_correct": {
      "type": "noul",
      "instructions": {
        "field": {
          "name": "invoice_number",
          "type": "string",
          "description": "The identifier printed on the invoice."
        },
        "extracted_value": "4471",
        "question": "Does `extracted_value` match the `field` as it appears in `source_text`?"
      }
    },
    "customer_name": {
      "type": "choice",
      "instructions": {
        "field": {
          "name": "customer_name",
          "type": "string",
          "description": "The organization the invoice was issued to."
        },
        "question": "Which option is the value of `field` in `source_text`?"
      },
      "criteria": {
        "Beaver Logistics": null,
        "Dam Logistics": null,
        "Beaver Dam Logistics": null,
        "Beaver": null,
        "Dam": null
      }
    },
    "amount_due": {
      "type": "score",
      "instructions": {
        "field": {
          "name": "amount_due",
          "type": "number",
          "unit": "USD",
          "description": "The total the invoice asks to be paid."
        },
        "question": "How large is the `field` value in `source_text`?"
      },
      "criteria": [
        "Under $1,000",
        "$1,000 to $10,000",
        "$10,000 to $100,000",
        "$100,000 to $1,000,000",
        "Over $1,000,000"
      ]
    },
    "payment_terms": {
      "type": "score",
      "instructions": {
        "field": {
          "name": "payment_terms",
          "type": "integer",
          "unit": "days",
          "description": "Days allowed for payment, from terms such as \"net 30\"."
        },
        "question": "How many days does the `field` in `source_text` allow for payment?"
      },
      "criteria": [
        "Due on receipt",
        "Net 10",
        "Net 30",
        "Net 60",
        "Net 90"
      ]
    }
  }
}
```

Three details deserve attention. The `criteria` map on `customer_name` uses `null` values throughout, which is the page demonstrating that an option needs no description when the option name is itself the whole answer; five candidate substrings of the same company name are unambiguous as labels. The two Score questions carry a `unit` key inside `field`, a piece of metadata with no equivalent anywhere in the base Score page. And `payment_terms` is a Score whose levels are categorical net-terms rather than a magnitude scale, which quietly stretches what "a spectrum" means.

The page then tells you the real deployment pattern in one sentence: "In code, you could loop over the potential records and build one of these questions per field, all sent in a single call." That is exactly the shape of [[TypeSafe's SDE cascade gates escalation on any per-field Noul above 0.7 - the chart's y-axis is mean llm_judge and the frontier dominates only the two middle models]], which the page cites by name, and of the code-generated question keys in [[Grep AI's AgentRun runs an AML alert once on a Pi agent, then compiles the trace into a DSL program whose decisions are typed Jev questions - 826 tool calls and 51 minutes become 30 and 3 minutes]].

Arrays are allowed too, for when the instruction is a list to check or compare:

```json
"instructions": {
  "question": "Does the claimed sender identity conflict with the sending domain?",
  "compare": ["ticket.sender.display_name", "ticket.sender.email"],
  "focus": "Compare the named organization with the email domain."
}
```

## Structured Choice Options

### JSON rubric for boundary clarification

The rubric pattern gives every option three keys: what it covers, what it explicitly does not cover, and a couple of example inputs. The `not_for` key is the interesting one, because it encodes the negative space between neighbouring options rather than describing each in isolation.

```json
{
  "state": "I ordered the standing desk two weeks ago and tracking still says label created. Was I even charged?",
  "questions": {
    "department": {
      "type": "choice",
      "instructions": {
        "question": "Which team should handle this message?",
        "focus": "Classify the customer's primary request, not every topic mentioned."
      },
      "criteria": {
        "billing": {
          "what": "Charges, invoices, refunds, or subscriptions",
          "not_for": "Order tracking or account access",
          "examples": [
            "I was charged twice",
            "Where is my refund?"
          ]
        },
        "orders": {
          "what": "Order status, delivery, cancellation, or returns",
          "not_for": "Charges or account access",
          "examples": [
            "Where is my package?",
            "Cancel my order"
          ]
        },
        "account": {
          "what": "Login, password, profile, or security",
          "not_for": "Charges or delivery",
          "examples": [
            "I can't log in",
            "Change my email"
          ]
        }
      }
    }
  }
}
```

The chosen state is deliberately a two-topic message: it asks about delivery and about a charge. The `focus` key on `instructions` and the `not_for` keys on the options are both doing the same job from opposite ends, pushing the model toward the primary request. This is annotation-guideline writing moved into the request body, the same discipline that [[Nova Escola's lesson-planner evals worked only after error analysis rewrote the rubric - annotators agreed worse than chance until experts defined good]] found was the difference between sub-chance agreement and a usable rubric.

### Walking a taxonomy

The taxonomy section is the page's most genuinely novel idea and it is a pattern rather than a feature. To classify into a deep tree, ask one Choice per level and walk the tree in code. At each step the options are the children of the current node, and each option's **value is the child's entire subtree**. The subtree is the description.

```json
{
  "state": "32oz plastic bottle with a flip straw lid. Fits most bike cages.",
  "questions": {
    "department": {
      "type": "choice",
      "instructions": "Which top-level department does this product belong to?",
      "criteria": {
        "Sporting Goods": {
          "Cycling": [
            "Bike Bottles & Cages",
            "Bike Lights",
            "Helmets"
          ],
          "Fitness": [
            "Yoga Mats",
            "Resistance Bands"
          ],
          "Outdoor": [
            "Tents",
            "Sleeping Bags",
            "Hydration Packs"
          ]
        },
        "Home & Kitchen": {
          "Drinkware": [
            "Water Bottles",
            "Travel Mugs",
            "Tumblers"
          ],
          "Cookware": [
            "Pots & Pans",
            "Bakeware"
          ]
        },
        "Baby & Toddler": [
          "Sippy Cups",
          "Bottle Warmers",
          "Bibs"
        ]
      }
    }
  }
}
```

The mechanism the page is selling is lookahead. A bike bottle is plausibly `Sporting Goods > Cycling > Bike Bottles & Cages` or `Home & Kitchen > Drinkware > Water Bottles`, and a model shown only the two top-level names cannot tell. Showing the subtrees lets it see both leaves exist before committing to a branch. The page then hands the uncertainty to the caller: "The `probabilities` on this answer tell you whether the split is close enough to explore both branches." That is the confidence contract from [[Daniel Ch's How to master Jev prescribes a 0.85 and 0.55 confidence-gate ladder under an LLM that still writes - the decision-layer architecture is additive but every number and all three charts are TypeSafe's own]] applied to tree search, and the page points at the Hierarchical Classification cookbook for a beam search that keeps several paths alive when probabilities are close.

On the 255-option cap the page offers no staged-Choice recommendation and no numbers, only a note about size:

> Subtrees can get large. If a branch is too large, trim the value to its direct children and a sample of leaves.

Worth being precise about why the cap is mostly a non-issue here. Walking the tree already keeps each question's option count down to one node's children, which is the real reason the pattern scales; the cap would only bite on a pathologically wide single level. The pressure this design actually creates is token pressure, not slot pressure, and the note above is the page acknowledging exactly that. It is the same decomposition [[Cua keeps the candidate menu in application code so Jev only picks an ID - CUA-S1-FORMS is a 706K-parameter form specialist at 99.7 percent against hosted Jev's 83.6, and neither model sees pixels]] uses to dodge the cap from the other direction, by splitting one N-way question into many small ones.

## Structured Score Levels

Each entry in a Score `criteria` array can be an object. Here the vocabulary changes again, to `summary` and `signals`, where the Choice example used `what` and `examples`.

```json
{
  "state": "Fixed the null check in the payment handler. Also refactored the retry loop while I was in there, and bumped the SDK version since the old one had that timeout bug.",
  "questions": {
    "pr_scope": {
      "type": "score",
      "instructions": {
        "question": "How focused is this pull request description on a single change?",
        "note": "Judge the number of independent changes, not the size of any one change."
      },
      "criteria": [
        {
          "summary": "One change, clearly stated",
          "signals": [
            "A single fix or feature",
            "Nothing described as \"also\" or \"while I was in there\""
          ]
        },
        {
          "summary": "One main change plus a small related tweak",
          "signals": [
            "A primary change and one minor adjacent edit",
            "The tweak supports the main change"
          ]
        },
        {
          "summary": "Several independent changes bundled together",
          "signals": [
            "Two or more unrelated fixes or features",
            "Changes that could each be their own PR"
          ]
        }
      ]
    }
  }
}
```

The `note` on `instructions` separates the dimension being judged from a confound, telling the model to count independent changes rather than measure diff size. The `signals` arrays are observable surface features rather than definitions, and the first level's signal quotes the exact phrase ("while I was in there") that appears in the state, which is a slightly awkward piece of example-fitting. The base Score page's own advice on this is to "use the same field names on every level so the model can compare like with like", which this example follows and which matters because the Score page says each level is judged on its own against the state.

## Structured Noul Criteria

The last example is a phishing check, and it is the one Nathan LeClaire is effectively pointing at. Noul `criteria` is optional; structuring it pins down a subtle yes/no boundary with a definition and examples on each side.

```json
{
  "state": {
    "sender": {
      "display_name": "Beaver Dam Builders Ltd.",
      "email": "donotreply@payroll.example"
    },
    "message": "Your Q3 bonus is ready. Reply with your login password so we can verify your identity and release the funds."
  },
  "questions": {
    "requests_credentials": {
      "type": "noul",
      "instructions": {
        "question": "Does the `message` ask the recipient to disclose a sensitive credential?",
        "inspect": "message",
        "focus": "Look for a request to send the credential itself, not a request to change or reset it."
      },
      "criteria": {
        "true": {
          "what": "Asks the recipient to reply with, type, or send a password, PIN, one-time code, or other security sensitive answer",
          "examples": [
            "Reply with your password",
            "Send us the 6-digit code you just received"
          ]
        },
        "false": {
          "what": "No sensitive credential is requested",
          "examples": [
            "Reset your password from the settings page",
            "Your statement is ready"
          ]
        }
      }
    }
  }
}
```

`inspect` is the key that matters operationally. The state carries both a `sender` object and a `message`, and `inspect: "message"` narrows the model's attention to one of them, while `focus` rules out the specific near-miss that would otherwise produce a false positive. That pairing is a context-discipline tool: it is the request-level version of the "keep the state clean" advice that follows from the context rot documented on TypeSafe's own model-jaggedness page and recorded in [[Annabell frames TypeSafe's Jev as a savant for eval verdicts and routing - three question types, 255 choices, 10 score levels, and a Noul with no confidence field]]. If you cannot always shrink the state, you can at least tell the model which part of it to read.

Annabell's production Noul is the same shape with different key names, which is the clearest available proof that the vocabulary is free-form. Her `instructions` are `{question, inspect, scope}` against the docs' `{question, inspect, focus}`; her `criteria` are `{true: {definition, includes}, false: {definition, includes}}` against the docs' `{true: {what, examples}, false: {what, examples}}`. Only `question` and `inspect` match the docs exactly. Her `scope` is an array of three rules where the docs' `focus` is a single string, and her `includes` enumerates qualifying behaviours where the docs' `examples` gives sample inputs. Nothing here is wrong on either side, because `EntryType` admits any key.

## Base vs Structured

Drawn from the sibling primitive pages, which define the base shapes this page extends. The right-hand column is the advanced page's escalation, and the trigger column is the siblings' own stated condition for reaching for it.

| Field | Base shape (sibling pages) | Structured shape (advanced page) | Documented trigger to escalate |
| --- | --- | --- | --- |
| `instructions`, all three types | A string. "A string is enough for most questions." | Object with the question in one key and its data in others, or an array for a list to check | Question has multiple parts, or refers to data that is already JSON |
| Choice `criteria` values | Map of option name to a one-line string description; up to 255 options | Map of option name to `{what, not_for, examples}`, or `null` when the name says everything | "When two options are similar and the model keeps confusing them" |
| Score `criteria` entries | Ordered array of level strings, low to high; at least 2, API accepts up to 10 | Ordered array of `{summary, signals}` or `{what, examples}` objects, same keys on every level | "When the model keeps scoring between two neighbouring levels on inputs you think are clear" |
| Noul `criteria` | Optional `{true, false}` with a string on each side | `{true: {what, examples}, false: {what, examples}}` | "When the yes/no boundary is subtle" |
| `state` | String, object, or array of text. Objects preferred so each part has a name | Unchanged by this page; structure in state was always the norm | Use an object "for most requests" |

Two asymmetries fall out of this table. First, `state` was always expected to be structured, per the State page's "Use an object for most requests", while `instructions` and `criteria` default to prose. The advanced page closes that gap, and the invoice example is the payoff: a structured question referring by key into a structured state. Second, every sibling trigger is phrased as a response to observed model behaviour. None of them says to start structured.

## The Post and Replies

Nathan LeClaire (@dotpem) is a TypeSafe employee, bio "Golang/observability hacker changing the world @typesafeai, alum @docker @honeycombio @Bauplan_labs". He posted on 2026-09-21 at 19:36 UTC, 147 likes, 4 reposts, 6 replies:

> guys I'm telling you USE THE STRUCTURED CRITERIA you gonna unlock the full power of the jevvy
>
> more here: https://docs.typesafe.ai/primitives/advanced

The attached image is a meme, in the two-panel disapproving-then-approving format, drawn in an anime-styled 19th-century-gentleman idiom. It is content he chose, and it does real work: the approving panel transcribes a genuine structured question for a Lean proof-search agent, a use case that appears nowhere in the docs.

*The meme: prose instructions rejected, structured instructions and criteria approved, with a Lean proof-step agent as the worked example*
![[dotpem-527859-001.jpg]]

Transcribed, the top panel reads "Imagine using strings 😒 instead of objects in `instructions` and `criteria`" over the rejected form:

```json
"instructions": "blah"
"criteria": "how"
```

The approving panel shows two code cards:

```json
{
  "instructions": {
    "task": "Choose the next proof step",
    "prefer": "Existing moves first",
    "llm_notes": {
      "try": "Induction",
      "watch": "Weak induction hypothesis"
    }
  }
}
```

```json
{
  "criteria": {
    "induct": {"tactic": "induction", "on": "n"},
    "rewrite": {"tactic": "rw", "using": "ih"},
    "simplify": {"tactic": "simp_all"},
    "ask_astra": {
      "when": "Useful moves exhausted"
    }
  }
}
```

A mock newspaper in the corner, "THE JEV TIMES", Monday, September 21, 2026, runs the headline "JEV SOLVES NAVIER-STOKES" with subheads "Fluid Dynamics Community In Shambles", "Astra Consulted Once; Jev Handles The Rest", and "Lean Confirms: Proof Holds Water". The footer reads "this meme brought to you by structure gang".

The joke is a division-of-labour claim, that a cheap System One model picks nearly every proof step and the expensive model gets consulted once. But the criteria card is worth reading straight, because it is a better illustration than anything on the docs page: the options are Lean tactics, each option's value is the concrete invocation (`{"tactic": "rw", "using": "ih"}`), and one option is an escape hatch gated on a condition (`ask_astra` when "Useful moves exhausted"). That is a Choice whose option values are executable arguments rather than descriptions, which the docs never demonstrate and which `EntryType` plainly permits.

All six replies were retrieved. None is from TypeSafe. Nathan LeClaire did not reply to any of them, no @typesafeai account posted, and @CompleteSkeptic (Diogo Almeida) is not in the thread. The two obvious questions an employee's "use structured criteria" invites, why it is not the default and what it buys measured, were both effectively asked and neither got an answer.

**Jorge Colon (@JorgeConsulting) asked the schema question directly and got silence.** His reply is the most valuable thing in the thread:

> What I'm trying to wrap my head around are what are the absolute minimum required fields? Based on the examples it seems like it's free-for-all; I can create my own criteria DSL as long as it's valid JSON.

He attached a screenshot of the page's own "Where structure is allowed" table, the table that prompted the question. He is right, and the `EntryType` definition confirms it: the minimum is zero required fields and it is a free-for-all. A reader had to infer from examples what one line of the SDK reference states outright, which is a documentation gap rather than a product one.

*Jorge Colon's screenshot: the "Where structure is allowed" table he is asking about*
![[dotpem-527859-003.jpg]]

**Dev Agrawal (@devagrawal09) named the unstated implication:**

> probably another week before people realize they can put structured examples in there for in context learning

That is correct and the page half-demonstrates it without saying so. The `examples` arrays in the Choice rubric and the Noul criteria are few-shot exemplars smuggled into a classifier that has no few-shot slot. It matters for [[Sutro's jev-align uses GEPA to rewrite Jev's decision criteria from five labeled examples - the demo moves labeled-set ambiguity 49.6 points but full-pool certainty only 0.5]], whose reflection instructions explicitly tell GEPA not to memorize story-specific wording; if criteria are also the in-context-learning channel, that guardrail is drawing a line the format does not enforce.

**Midas (@TheMoonMidas)** posted a before/after explainer he made while working it out, "my smolbrain had some issues understanding it at first, but i think i'm getting there lol". It is a cleaner teaching artifact than the docs page, because it shows the same question twice and names the failure the structure fixes.

*Midas's before/after: the same department Choice as bare strings, then as option cards with what, not_for and examples*
![[dotpem-527859-002.jpg]]

**jem (@sheherenow_)** is shipping it into a real product, "oh i am SO adding this to the smoothbrain natural language->rules step in Jeval", quote-tweeting her own demo of jemo 3, natural-language visual linting for websites built on Jev plus [[simple-jev]] plus Inception's mercury 2.5 plus Browserbase. The remaining two replies are "i dont get it" and an unrelated offer to send a PR against TypeSafe's agent skill.

## Related

The criteria text is the whole tunable surface of a Jev question, so this page is the schema for everything in the vault that tunes it. [[Sutro's jev-align uses GEPA to rewrite Jev's decision criteria from five labeled examples - the demo moves labeled-set ambiguity 49.6 points but full-pool certainty only 0.5]] and its companion [[jev-align]] mutate `instructions`, `true_criteria` and `false_criteria` and nothing else, freezing the key set so the optimizer cannot rename a class or a level. [[Grep AI's AgentRun runs an AML alert once on a Pi agent, then compiles the trace into a DSL program whose decisions are typed Jev questions - 826 tool calls and 51 minutes become 30 and 3 minutes]] compiles an output schema into questions where the criteria the author writes for each option are the criteria Jev applies, which is this page's contract stated from the compiler's side.

For structured criteria in the wild: [[Frank Dellaert parameterizes the Asia Bayes net with two Jev requests - 18 CPT rows and an 11-edge structure for 3 hundredths of a cent, while GTSAM does all the inference]] writes explicit `criteria: {"false": ..., "true": ...}` per CPT row, [[TypeSafe's SDE cascade gates escalation on any per-field Noul above 0.7 - the chart's y-axis is mean llm_judge and the frontier dominates only the two middle models]] carries a `NoulCriteria` per extracted field, and [[Daniel Ch's How to master Jev prescribes a 0.85 and 0.55 confidence-gate ladder under an LLM that still writes - the decision-layer architecture is additive but every number and all three charts are TypeSafe's own]] reduces the whole practice to "state plus atomic question plus explicit criteria". [[MotherDuck's prompt_jev labels 100k AG News rows in 40 seconds for 50 cents at 89 percent - a benchmark fine-tuned encoders beat by 5 points, metered at a 25 percent markup over TypeSafe list]] is the SQL surface of the same idea, where `STRUCT(label, description)[]` is a structured option list with exactly two fields and no room for `not_for`.

The open reimplementations show what structure costs downstream. [[simple-jev]] serializes each option as `[{"answer":"red","description":null,"label":"A"},...]` and remaps the answer to a single-token letter, so a structured option value simply lands in `description` as nested JSON while the scored token stays one character; the taxonomy walk survives intact, though its 50 single-character labels cap a level at 50 children rather than 255. [[jevlike]] takes the opposite bet with a trained option-attention head. Neither reproduces calibration, which is what the `probabilities` in the taxonomy walk depend on. [[jevcache]] matters here because a criteria block is the static half of a request and the natural cache key.

On rubric authoring as a discipline: [[LLM Data Company experiments show explicit rubric criteria let gpt-oss-120b match Opus 4.7 at 100x lower cost and full-rubric grading beats per-criterion across every model]] is the measured version of this page's unmeasured claim, [[Nova Escola's lesson-planner evals worked only after error analysis rewrote the rubric - annotators agreed worse than chance until experts defined good]] is the warning that criteria written before error analysis are worthless, [[the Error Discovery skill builds a failure-mode taxonomy while you annotate, using active learning to pick the next traces]] is how you derive the taxonomy the walk then traverses, and [[LangChain and Harvey show DeepSeek batch verifiers reduce legal agent evaluation costs by three orders of magnitude at acceptable accuracy]] covers checklist decomposition for partially satisfied criteria. [[DSPy is a framework for programming—not prompting—language models through typed signatures and metric-driven optimizers]] is the structural analogue outside TypeSafe, typed signatures instead of hand-written prompts.

Also relevant: [[LangChain's Jev-as-a-Judge bench puts Jev's quality-score variance 92 to 913x below three LLM judges at $0.34 against Claude's $28.17 - five weather traces, one human oracle, provider-default sampling]] for how a quality rubric and a binary criterion get scored against a human oracle, [[Can Bölük's jegrep turns Jev into a semantic grep by scoring grep-ranked candidates with one Noul per file and a Choice for the line range - $0.004 a query, and the Gemini-lite comparison is nowhere in the repo]] for an escalating cascade of question granularity, [[Josh Rosen's ThruWire puts Jev at the checkpoint - prove X things happened however you like, and Jev scores the fuzzy half of that contract against the artifact not the trace]] for which half of a contract belongs in a criterion rather than in code, [[Josh Rosen's Jev in the Wild sorts week-one projects into routing, context filtering, tool gating, worker supervision, fast control loops and fuzzy data queries - deterministic only because inference was expensive]] for the six-way taxonomy of question shapes, [[LangChain's Sydney Runkle puts Jev inside the agent loop as classifier middleware - ModelRouterMiddleware picks the model from the latest user message and AutoModeMiddleware reproduces closed harnesses' dangerous-action gate]] for criteria inside an agent loop, [[Featherless's Simple Jev reproduces Jev's API on stock open models by remapping every answer to a single-token letter and softmaxing only those logits - no classifier head, and the code stamps every answer calibrated False]] for label-cardinality constraints on taxonomy design, and [[TypeSafe's Jev trades string generation for parallel-sampled typed decisions with calibrated probabilities at $0.042 per MTok - the 193x and 444x claims come from four self-built workflow evals]] for the pricing the token argument rests on. Indexed in [[moc - Jev]].

## Original Content

> [!quote]- Original Content: Nathan LeClaire's post, the Advanced structure docs page, and replies
>
> #### Post: @dotpem, 2026-09-21 19:36 UTC
>
> **Nathan LeClaire (@dotpem)** — "Golang/observability hacker changing the world @typesafeai, alum @docker @honeycombio @Bauplan_labs"
> 147 likes, 4 retweets, 6 replies
> https://x.com/dotpem/status/2102119751774527859
>
> > guys I'm telling you USE THE STRUCTURED CRITERIA you gonna unlock the full power of the jevvy
> >
> > more here: https://t.co/6RFAFQhcKa https://t.co/HpXzF0ElJW
> >
> > PHOTO: https://pbs.twimg.com/media/HSw6marbMAA1Kxo.jpg
> > date: Mon Sep 21 19:36:18 +0000 2026
> > url: https://x.com/dotpem/status/2102119751774527859
> > likes: 147  retweets: 4  replies: 6
>
> The shortened link `https://t.co/6RFAFQhcKa` resolves to https://docs.typesafe.ai/primitives/advanced.
>
> *Attached photo, full resolution 1536x1024*
> ![[dotpem-527859-001.jpg]]
>
> ---
>
> #### Docs: Advanced - structure
>
> Source: https://docs.typesafe.ai/primitives/advanced (rendered page, captured 2026-09-22). The markdown twin at `/primitives/advanced.md` opens with a ~235-line exported MDX JavaScript component (`export function TypesafeExample(...)`, an LZ-string compressor that builds playground share links); that component is omitted below and every example is reproduced as the rendered page displays it, which is the strict JSON the component emits. Prose is identical between the twin and the rendered page. The page carries no images or diagrams, only navigation icons.
>
> PRIMITIVES (QUESTIONS)
>
> # Advanced: structure
>
> > Instructions, Choice options, Score levels, and Noul criteria all accept JSON structure.
>
> System One models are trained to understand structure.
>
> ## Where structure is allowed
>
> Every one of these fields is an [`EntryType`](/sdk/javascript/api/type-aliases/EntryType).
>
> | Field                                   | Applies to          | Accepted shape                         |
> | --------------------------------------- | ------------------- | -------------------------------------- |
> | `instructions`                          | Choice, Score, Noul | `string`, `object`, `array`, or `null` |
> | `criteria` values (option descriptions) | Choice              | `string`, `object`, `array`, or `null` |
> | `criteria` entries (level descriptions) | Score               | `string`, `object`, `array`, or `null` |
> | `criteria.true` and `criteria.false`    | Noul                | `string`, `object`, `array`, or `null` |
>
> ## When to structure a question
>
> * **When it helps with clarity.** When a question has multiple parts, putting them in the form of JSON helps with clarity because the keys are labeled.
> * **When question needs supporting data.** A schema, a taxonomy, or a database row is already JSON. Use the JSON entirely or pass in the relevant subfields instead of serializing them into a string template.
>
> ## Structured instructions
>
> One `field` object describes the field being checked, and each question refers to it by key. The same shape drives a Noul that verifies a value, a Choice that picks one from candidates, and two Scores that place a value on a scale.
>
> REQUEST
>
> ```json
> {
>   "state": {
>     "source_text": "Invoice #4471 issued March 3, 2026 to Beaver Dam Logistics for $12,840.00, net 30."
>   },
>   "questions": {
>     "invoice_number_is_correct": {
>       "type": "noul",
>       "instructions": {
>         "field": {
>           "name": "invoice_number",
>           "type": "string",
>           "description": "The identifier printed on the invoice."
>         },
>         "extracted_value": "4471",
>         "question": "Does `extracted_value` match the `field` as it appears in `source_text`?"
>       }
>     },
>     "customer_name": {
>       "type": "choice",
>       "instructions": {
>         "field": {
>           "name": "customer_name",
>           "type": "string",
>           "description": "The organization the invoice was issued to."
>         },
>         "question": "Which option is the value of `field` in `source_text`?"
>       },
>       "criteria": {
>         "Beaver Logistics": null,
>         "Dam Logistics": null,
>         "Beaver Dam Logistics": null,
>         "Beaver": null,
>         "Dam": null
>       }
>     },
>     "amount_due": {
>       "type": "score",
>       "instructions": {
>         "field": {
>           "name": "amount_due",
>           "type": "number",
>           "unit": "USD",
>           "description": "The total the invoice asks to be paid."
>         },
>         "question": "How large is the `field` value in `source_text`?"
>       },
>       "criteria": [
>         "Under $1,000",
>         "$1,000 to $10,000",
>         "$10,000 to $100,000",
>         "$100,000 to $1,000,000",
>         "Over $1,000,000"
>       ]
>     },
>     "payment_terms": {
>       "type": "score",
>       "instructions": {
>         "field": {
>           "name": "payment_terms",
>           "type": "integer",
>           "unit": "days",
>           "description": "Days allowed for payment, from terms such as \"net 30\"."
>         },
>         "question": "How many days does the `field` in `source_text` allow for payment?"
>       },
>       "criteria": [
>         "Due on receipt",
>         "Net 10",
>         "Net 30",
>         "Net 60",
>         "Net 90"
>       ]
>     }
>   }
> }
> ```
>
> [Try it in the Playground →](https://console.typesafe.ai/decode#share/N4IghgDglgagpgJwM5QPYDsQC4QDcCMIANCACaoDGArgLZzoAuAKnAB4PYjAA66ABH24gkqKggpwA+gzYMhWQSACS6XKigS+AYgAsOgOz4+UJEipxSfALJhxACz4BmInwBMABlcA2Pg1R8AITgwXEQ+ABEwGj4AGVQAcxMGDSQ+ADNUBD4AEnxXIgAOHXcAOnd3F3Q4BidSoV4AX2IQCARUGggGJBZ2Th5+RShVdQlJdFoAI0RJE0kKTIQ4CjlsPn6BASEGAE8IOHlFdFEAGyEiXg3B9CQGBCpltGuD9cvFNKg4Y9Jni9fNkHQUX2qyEQzUGik4xoUwQZ1+fy2u2BCiENwQQ3icIGCLIcCQFHRnUeByETDscGMpHoyXeYVaQxklgwvnJxmGEJK9WxGwa525-1kCDAywsklwYGO5hJID0hixOIAjuYbsSQSBwqg8XwAAaC4WMsUS8zavg0MAMCgOBis7W0r4msCpKA1SB7WxO-jakRiUYydjagD8XMuDV+vN+QmoN3a00BdB+3MRe2llpGwL5l1B11u92SGCQCZxdu+qxeOLjyMUUb8dAQYyB8r+ih2ybVaIxjZxVPxhLz6GlZIpmXiYHQUAAXubHiyKWC03wAO6O4ymcyWPyckDwnkZ15CJV4vvSgDqdg0DlQROZJhnfHFkqHaR1xZNQx13vEUj9DEDwZ328jdEZHRMBCz3EAghCMI4kSFUKALVZxmOY5d0zdUoliBIkhSA4kJQ7d-kg0IskiaIYOw+DcKoZDUI2IQiMQKiaIIxRSKY05uVDAZwwGIQolERhJFIKVSwAkAW0rVF5kWTsrjRXNHgQhQyzokBizA8sGzVfiqEE4T0xY-4JOlKEYVktDdOdaUAFUAGVwnM1TuwJKAr37NVB18VAGAlW85whPhHQAa1SPw+CmPgIDAKBSE3FieMVZUjzVAAJVAFz4Y5bHiWdQptF87yNWdPQ-X1ZF-LdONowDnUQKBQNWABtFihGs9AqSyXIiHKdxHKELqeq8nJ8AqHq+pAXJRvKIbJqm3riBaiaRrmmb8G68p1vm2j-gAeWI4bNs2v8BAAXTDXchCi7Y6EE4CaCUtYxOMttpIMxMQCGeSHnzDTVPU0T+VUitpSum6GGkRB7scoykWlBk4By2EFsB-5LJWFEyDAbYEO2py8RctzpUibHAuQ9KLHSTJIqxsGXDSNpoju1IzEtQLUm4DmAWqWoOaEOLAYS8CDxVDBpTSjKzXQbY+FILHUnILVrQpW0PntNl31ET8If9UnjnSymslB6kg0qkNqpAFzgPqg5msBoRwnMPhmUWCRXJWXGhAAOW5kbxu9mpHC2xb-b4Lwg7tkAQ4ATnm7czu4xpmiQT4lkZKxUCpY4kGwRqQAAKzgXAAFospkG4QBOhogA)
>
> In code, you could loop over the potential records and build one of these questions per field, all sent in a single call. The [SDE cascade cookbook](/cookbooks/sde_cascade) does something similar to this.
>
> Arrays work too. Use one when the instruction is a list of things to check or to compare:
>
> ```json
> "instructions": {
>   "question": "Does the claimed sender identity conflict with the sending domain?",
>   "compare": ["ticket.sender.display_name", "ticket.sender.email"],
>   "focus": "Compare the named organization with the email domain."
> }
> ```
>
> ## Structured Choice options
>
> A Choice option description can be a structured object as well.
>
> ### JSON rubric for boundary clarification
>
> REQUEST
>
> ```json
> {
>   "state": "I ordered the standing desk two weeks ago and tracking still says label created. Was I even charged?",
>   "questions": {
>     "department": {
>       "type": "choice",
>       "instructions": {
>         "question": "Which team should handle this message?",
>         "focus": "Classify the customer's primary request, not every topic mentioned."
>       },
>       "criteria": {
>         "billing": {
>           "what": "Charges, invoices, refunds, or subscriptions",
>           "not_for": "Order tracking or account access",
>           "examples": [
>             "I was charged twice",
>             "Where is my refund?"
>           ]
>         },
>         "orders": {
>           "what": "Order status, delivery, cancellation, or returns",
>           "not_for": "Charges or account access",
>           "examples": [
>             "Where is my package?",
>             "Cancel my order"
>           ]
>         },
>         "account": {
>           "what": "Login, password, profile, or security",
>           "not_for": "Charges or delivery",
>           "examples": [
>             "I can't log in",
>             "Change my email"
>           ]
>         }
>       }
>     }
>   }
> }
> ```
>
> [Try it in the Playground →](https://console.typesafe.ai/decode#share/N4IghgDglgagpgJwM5QPYDsQC4QDcCMIANCACaoDGArgLZzoAuAKnAB4PYgCSABKgqURxSPBgAs4PJAzDpSUdAHMegpAGtRAd1Q9NcOGqQ8winbJEMEYCmoXLpUADaOpYAJ5HHYAEZwXFBDgwBmEAOh4AdTAjXjhceh4KMTAERWEAfmIQCARUGggGJBZ2TmAAHXQeHjKyOAgUhjpGGqwecsqq6pAGNwg4Fq6k1CgKfuIKzq6FaQQqCgY0dCQB9smqmoBHKjgHDAGaiLERsVEgmikxVCpHEWS5R0lxKCM6JCQTOHSaogm1moAzShUZbYLoAYS8byg-zcogkiWBDDyiAA5EYclAaClYYEtjsGEQeOhUAweHFELCkdAKDwmgsMGEar8qgBfH4ddYgAJQEIIKBgFbMzo1bxORx2QUcv4gTTJBj7EBg5KpHaEhS4YajJCEwL-KhybV8BBSKjeJDcgqLEHstbCkDEhgAfUBCAVAHkBIhRFYbHYjcYKBQrowA1rrULJjU2GB8g8Qa0ANoR6W8TTRRLKtIWTQjMY2212w5CHjPWk4uB6uRfEDJqoAXWTbOTNX4gmQkoLXVlwXdnuN0mCwMJgnF8QQbkJFFko2cwUWhP4PECDCoCCW31rXQdzv4CqVKTSRkX1iD+tJJ526alkZA0djOwGSev0qLgRLL1h9RsH2r+c7NTBac-DLI02yZZ960bP87RPYN5VBVYCxqbt4NaGoABlUEUBRCXqN5tAEXDcn+Jw4AXfs4GoPkeg3CCtxJHdXVBADMx2f0RygMc3Fo-9b1YGMIDjR9N05Xgp3QFFSUcLCS3QHjO3BO40hAuAsSccDOwbZ8WSFHSOj0lksiQPxKJCUgAFlUBHJBsATEAACs4gAWi8EJpBAOsWSAA)
>
> The example tells the model what each option does and does *not* cover. It sharpens the boundary between options.
>
> ### Walking a taxonomy
>
> To classify into a deep taxonomy, ask one Choice per level and walk the tree in code. At each step the options are the children of the current node, and each option's value is the child's tree. Doing so lets the model see what lives under a branch before committing to it, which matters when the item belongs to a leaf whose name is not obvious from the branch name alone.
>
> Here the state is a product listing and the first question picks a top-level department.
>
> REQUEST
>
> ```json
> {
>   "state": "32oz plastic bottle with a flip straw lid. Fits most bike cages.",
>   "questions": {
>     "department": {
>       "type": "choice",
>       "instructions": "Which top-level department does this product belong to?",
>       "criteria": {
>         "Sporting Goods": {
>           "Cycling": [
>             "Bike Bottles & Cages",
>             "Bike Lights",
>             "Helmets"
>           ],
>           "Fitness": [
>             "Yoga Mats",
>             "Resistance Bands"
>           ],
>           "Outdoor": [
>             "Tents",
>             "Sleeping Bags",
>             "Hydration Packs"
>           ]
>         },
>         "Home & Kitchen": {
>           "Drinkware": [
>             "Water Bottles",
>             "Travel Mugs",
>             "Tumblers"
>           ],
>           "Cookware": [
>             "Pots & Pans",
>             "Bakeware"
>           ]
>         },
>         "Baby & Toddler": [
>           "Sippy Cups",
>           "Bottle Warmers",
>           "Bibs"
>         ]
>       }
>     }
>   }
> }
> ```
>
> [Try it in the Playground →](https://console.typesafe.ai/decode#share/N4IghgDglgagpgJwM5QPYDsQC4QDcCMIANCACaoDGArgLZzoAuAKnAB4PYgDMATKgF4ACCABswSBlAqCARqgYMRcQQHcoDABaCwggGYioEQRIRgVgg6QB0ggGLqkgmqgmyoAa2UUwAczhIrYhAIBFQaCAYkFnZOYAAddEFBOLI4CDAEBjpGFKxBeMSk5JAGAE8IOFziig1UKUriBKLiqHQTKgpJDCQqlIB1DSktBlQIAFolXDgRQVI0jKz6BlnUf0FNKEcQ1FIO5ZlpjB911AB+FKImopSKBHVEKDAqguaklIBlCFRM1uOAcVQOx62HyV1exQAwqUKAZ0D4qgBtMHg4oAIQ8ylR8kUawAZIIIb5-BdkeCUujPIIADJQHwaSIkwoo4oACWmdAZIFJRQAupcma8UvYGOh-MC8kiBWSQABNVA+HQAWTAnP5zLeIAASv5NgwwOgKJj9aRgdyknyzcUAPJUBjkb6Iy0aliMYFq9UfJRpX6CVG+N1O1mlUimLqJAAKYAo7lNUt53IAvu7mikWWFlPiANLqGr0Z6WlIAETu6HcKgyDQlgf6KsQvuxSgDcZTICYpimM0VVB8TfVxSYtBkSmQKUtFubkMBZYrjonGvD8kc+MjbUZffJYE85YQDTHieT1xAfpkpUE+KYO1Iw9nzI+hggp4hVAgvZR5Ibyj6GToI8aE-JUAyLG4I8siCZXOB6AJkESDTHAnRwKQio7NMSDYAiIAAFZwLgEy1hIIA8gmQA)
>
> The bottle plausibly fits under two departments. Showing the subtrees lets the model see that both `Sporting Goods > Cycling > Bike Bottles & Cages` and `Home & Kitchen > Drinkware > Water Bottles` exist, and weigh the listing's emphasis on bike cages against everyday drinkware. The `probabilities` on this answer tell you whether the split is close enough to explore both branches.
>
> Once a department is chosen, ask the next Choice with that department's children as the options and their subtrees as the values, and repeat until you reach a leaf. In code this could be a loop over a nested dict, where each question's `criteria` is simply the current node. The [Hierarchical Classification cookbook](/cookbooks/hierarchical_classification) shows an example of a similar walk of the tree, including a beam search that keeps several candidate paths alive when the probabilities are close.
>
> > **Note:** Subtrees can get large. If a branch is too large, trim the value to its direct children and a sample of leaves.
>
> ## Structured Score levels
>
> Each entry in a Score `criteria` array can be an object.
>
> REQUEST
>
> ```json
> {
>   "state": "Fixed the null check in the payment handler. Also refactored the retry loop while I was in there, and bumped the SDK version since the old one had that timeout bug.",
>   "questions": {
>     "pr_scope": {
>       "type": "score",
>       "instructions": {
>         "question": "How focused is this pull request description on a single change?",
>         "note": "Judge the number of independent changes, not the size of any one change."
>       },
>       "criteria": [
>         {
>           "summary": "One change, clearly stated",
>           "signals": [
>             "A single fix or feature",
>             "Nothing described as \"also\" or \"while I was in there\""
>           ]
>         },
>         {
>           "summary": "One main change plus a small related tweak",
>           "signals": [
>             "A primary change and one minor adjacent edit",
>             "The tweak supports the main change"
>           ]
>         },
>         {
>           "summary": "Several independent changes bundled together",
>           "signals": [
>             "Two or more unrelated fixes or features",
>             "Changes that could each be their own PR"
>           ]
>         }
>       ]
>     }
>   }
> }
> ```
>
> [Try it in the Playground →](https://console.typesafe.ai/decode#share/N4IghgDglgagpgJwM5QPYDsQC4QDcCMIANCACaoDGArgLZzoAuAKnAB4PYgBiUrcpAAgYALOAPRUANpIEVRFANYCo6IaIEQwATzqMBwsOlKTEAOgEBBSUlQCEcAGZgKDVPcEix9hgi0DJqKgQAgDuwlAmAgCSoWBIyqqe9kQChoIARrQQ-GpiAMoAIgDSAriIKBgCKOgUYp4CqJKCGGIGHgYMQlB0qFSdmQDmpsQgEAioNBAMSCzsnMAAOqoCC6MIAPpIFEFwq1gCi8sCKyAMWtl7J1tuu8RLx8erKkg+VC5o6EiXhw8PqwCOVDgLw+l1WAAlUCEBA5KFQkDkoPEREiNFIZPZAcDOqRgRQEFAph8GqowFUVANInJDAM4AB+VZEe6-E7oVAMW77VYAKSopFpuXEtHSiAaDgSuOyRnonWp6FpSBSbM69RQAC8xKhxYY-C1ZAZ5XBTKtmccAL5Mo4nfFQDkEsCXADapoePxZjxASFoNDAvjBIAA8ugxHLaSkKCZfZI-C8wBzSIyXb9VigBugwNYnUmWasLOT5ZEHLwGggYXA41R7Imre7VgA5dnheUCXFbAkiwRxFYLVYZmw91Yl7urMIRMQxEJdlS5Ks9kAmmsPAC62Yt2bdtc93t9Wn9QbEPunobEEEk8NSVR90jscEkcZyDBC5YU1fdHtT6cz2AEzsXyZAeZjN0O76jSYhpCSB4qG4qSkAAVs4MoCPwtqvm+HpMOoj7PlUVAQBAbjTIKh6qMeC7oSui5rouG45luNA+n636rHkcBlAgGYSnAUq4nox7xJkRgmB4qC0kkaGbh+fZZn+fwgEwIS2DBNA3AIVDoPYd7xjCvDAkODjlgwlbAhJb6rAAwgaCpqHGsi9E0yHOMIAgirkUCllCqgAAoAErkW+lHumaLqBQIwXoGaIwIiYLj8AAsqguLWNgjogHBbEALRadiIBLmaQA)
>
> ## Structured Noul criteria
>
> Noul `criteria` is optional, and when the yes/no boundary is subtle, structured `true` and `false` descriptions let you pin it down with a definition and examples on each side.
>
> REQUEST
>
> ```json
> {
>   "state": {
>     "sender": {
>       "display_name": "Beaver Dam Builders Ltd.",
>       "email": "donotreply@payroll.example"
>     },
>     "message": "Your Q3 bonus is ready. Reply with your login password so we can verify your identity and release the funds."
>   },
>   "questions": {
>     "requests_credentials": {
>       "type": "noul",
>       "instructions": {
>         "question": "Does the `message` ask the recipient to disclose a sensitive credential?",
>         "inspect": "message",
>         "focus": "Look for a request to send the credential itself, not a request to change or reset it."
>       },
>       "criteria": {
>         "true": {
>           "what": "Asks the recipient to reply with, type, or send a password, PIN, one-time code, or other security sensitive answer",
>           "examples": [
>             "Reply with your password",
>             "Send us the 6-digit code you just received"
>           ]
>         },
>         "false": {
>           "what": "No sensitive credential is requested",
>           "examples": [
>             "Reset your password from the settings page",
>             "Your statement is ready"
>           ]
>         }
>       }
>     }
>   }
> }
> ```
>
> [Try it in the Playground →](https://console.typesafe.ai/decode#share/N4IghgDglgagpgJwM5QPYDsQC4QDcCMIANCACaoDGArgLZzoAuAKnAB4PYjAA66ABH24gk9UoiFY+PfgMFkoSCABswATwD66MHQlyAQnDC5EfACLa+eqlCVjkfADINSAOiFFesuXBpgbuoXJ0VAYEOGVVAAEINQRUJSUXNm1lOCFPPgBfDxkhOiQkMABzNOw5AE1UKgQ+AEUAZj4AIwwqJD4FPjCwUlUXPgAlcKVVPgB3KAYACz5VKpqlVCKofhiCsdQEUj4kVHG4PgowfmMEKAAzUbnqjrFGSdHj7bClQxE+aYPzqnRSJDcQLxMsQQBA4jQIAwkCx2JxpAIhGEAI5UOBIKHqChhO4MKBgJRIXTw2RCBiqCClSRCYJUJTuDIIkArdEIKgUXEYQllYleIQotEc9ABECmVBoj5TA4AA3yhRKUr4YCQAGsJQcwhQoNB6AwPntSAoKIt3mAdvQULjjIdsTq8UoAPz0mS8pnoRRwdnC2XFUo5LyM86UNrChyoVCqwM1U3I1HovVm35q61wHF2jpQuBKc5EPjBXXRuD8uMMPYUKbHEp8TZdNFwXWTAEMrJ+kkgLGTRB4olNxmhVHd53+oRjcsMYUAQRV7U+Nc12sY8bCEXGkymObJFJz1ZEidNayQGy2OYACgBJAByW-QcAAtLi6IdUGItzUQpKaiJqGcyQmLVArccB7iMQPatskEKvFykgANqgS6QzLhM0yzPMfD7oepBOv6Q4gAAyqIfBtEmABsN4GssuoUE+BzXHwABWbS6hqcD-im6SDl4AC6oHZKBQjnPiIgDthjIjmAY5lEI557Duf5WliKa2viHTtDGApsSBHFgawKSQbosFafBta6tcNToZs2znOCSYiAwuLoEU7QxCUWEiYylQ3Oi4k+DqKk1j0qjsW53FaZkTZhTIEXAiQIivOyKYALLUQS2DQSAdFwLgN4qAwAogJxmRAA)
>
> Was this page helpful?
>
> On this page: Where structure is allowed / When to structure a question / Structured instructions / Structured Choice options / JSON rubric for boundary clarification / Walking a taxonomy / Structured Score levels / Structured Noul criteria
>
> ---
>
> #### Supporting definition from the SDK reference
>
> Source: https://docs.typesafe.ai/sdk/javascript/api/type-aliases/EntryType
>
> ```ts
> type EntryType =
>   | string
>   | {
> [key: string]: JsonValue;
> }
>   | JsonValue[]
>   | null;
> ```
>
> Text, a JSON object or array, or `null` for state, instructions, and criteria.
>
> ---
>
> #### Replies
>
> Fetched with one `bird replies --all` call at 2026-09-22 03:07 UTC. All 6 replies that the post reports were returned, then the paginator hit `HTTP 429: Rate limit exceeded` while following the cursor for a further page; since the post's own reply count is 6 and 6 were captured, nothing is believed missing. Verbatim below, in the order returned.
>
> ```
> @sheherenow_ (jem 💜🩵🩷):
> @dotpem oh i am SO adding this to the smoothbrain natural language-&gt;rules step in Jeval  tysmmmm https://t.co/lVxnJsXit3
> >  QT @sheherenow_:
> > 🔊 jemo 3: natural-language visual linting for websites
> >
> > @typesafeai jev + @FeatherlessAI simple-jev + @_inception_ai mercury 2.5 + @browserbase https://t.co/ypml2gypON
> > VIDEO: https://pbs.twimg.com/amplify_video_thumb/2101450456799350784/img/bley2ILRq0bMhtLB.jpg
> >  https://x.com/sheherenow_/status/2101450485438017815
> date: Mon Sep 21 22:18:14 +0000 2026
> url: https://x.com/sheherenow_/status/2102160503720361986
> ──────────────────────────────────────────────────
>
> @TheMoonMidas (Midas 👑):
> @dotpem my smolbrain had some issues understanding it at first, but i think i'm getting there lol https://t.co/5EGnir84YZ
> PHOTO: https://pbs.twimg.com/media/HSxM3dZa4AA4uXc.jpg
> date: Mon Sep 21 20:55:44 +0000 2026
> url: https://x.com/TheMoonMidas/status/2102139739134709910
> ──────────────────────────────────────────────────
>
> @devagrawal09 (Dev Agrawal):
> @dotpem probably another week before people realize they can put structured examples in there for in context learning
> date: Mon Sep 21 20:08:25 +0000 2026
> url: https://x.com/devagrawal09/status/2102127834135474269
> ──────────────────────────────────────────────────
>
> @JorgeConsulting (Jorge Colon):
> @dotpem What I'm trying to wrap my head around are what are the absolute minimum required fields? Based on the examples it seems like it's free-for-all; I can create my own criteria DSL as long as it's valid JSON. https://t.co/PPBbCBwaXu
> PHOTO: https://pbs.twimg.com/media/HSxg5tzWYAELW2N.jpg
> date: Mon Sep 21 22:22:54 +0000 2026
> url: https://x.com/JorgeConsulting/status/2102161675419804111
> ──────────────────────────────────────────────────
>
> @JustLingonberry (Just_Lingonberry_352):
> @dotpem i dont get it
> date: Mon Sep 21 20:15:56 +0000 2026
> url: https://x.com/JustLingonberry/status/2102129725854633992
> ──────────────────────────────────────────────────
>
> @iWatch_AAPL (apple):
> @dotpem Would you guys accept a PR to improve your skill because it needs so much work.
> date: Tue Sep 22 01:16:07 +0000 2026
> url: https://x.com/iWatch_AAPL/status/2102205268692283863
> ──────────────────────────────────────────────────
> [info] More replies available. Use --cursor "DAAKCgABHSyiIm___WILAAIAAADwRW1QQzZ3QUFBZlEvZ0dKTjB2R3AvQUFBQUJRZEs5V0FIRnFRengwc1pMYTdXMUdhSFN4S0hIb2FJQk1kSy92RFY1cmdHeDBzWU9mejFtSFBIU3dUYkxRWFVOTWRMRHJHMTlwaGN4MHNRb0JnMjBHUUhTeE05SU5iVUpZZExIbGJDMXJoU3gwc2lJM05XN0hYSFN4M2NBTGF3SFlkTEVJZ3Foc3dYUjBzVzkvV1c1QmlIU3hEMlIxYTBBZ2RMSTRBRHRzaEp4MHNCZFF2R3JBaUhTeFJSSURiSVNFZEs3dGc3QmRSOFIwc1g5Y2xHOEFDCAADAAAAAgsABAAAAAZCb3R0b20AAA" to continue.
> [err] Failed to fetch replies: HTTP 429: Rate limit exceeded
> ```
>
> *Photo attached to @TheMoonMidas's reply, a strings-vs-structured before/after*
> ![[dotpem-527859-002.jpg]]
>
> *Photo attached to @JorgeConsulting's reply, a screenshot of the page's "Where structure is allowed" table*
> ![[dotpem-527859-003.jpg]]

## Links

- [Advanced: structure](https://docs.typesafe.ai/primitives/advanced) — the source of truth for this note; markdown twin at https://docs.typesafe.ai/primitives/advanced.md
- [`EntryType` type alias](https://docs.typesafe.ai/sdk/javascript/api/type-aliases/EntryType) — the one-line definition that makes every field name on the advanced page a convention
- [Nathan LeClaire's post](https://x.com/dotpem/status/2102119751774527859) — the TypeSafe employee's "USE THE STRUCTURED CRITERIA" post that points at the page
- [Primitives](https://docs.typesafe.ai/primitives) — the three question types, how to choose between them, and asking several at once
- [Choice](https://docs.typesafe.ai/primitives/choice) — base option map, the 255-option cap, and the "Structured instructions and criteria" section
- [Score](https://docs.typesafe.ai/primitives/score) — base level array, the 10-level cap, and "Structured level descriptions"
- [Noul](https://docs.typesafe.ai/primitives/noul) — base optional `{true, false}` criteria and its own structured-instructions example
- [State](https://docs.typesafe.ai/concepts/state) — how state is structured, the counterpart to structured questions
- [Confidence](https://docs.typesafe.ai/confidence) — what `probabilities` and `confidence` mean, which the taxonomy walk depends on
- [SDE cascade cookbook](https://docs.typesafe.ai/cookbooks/sde_cascade) — cited by the page as the per-field question-generation pattern
- [Hierarchical Classification cookbook](https://docs.typesafe.ai/cookbooks/hierarchical_classification) — cited by the page for the tree walk with beam search

Playground share links captured from the rendered page, one per example, in page order:

1. [Structured instructions, the invoice example](https://console.typesafe.ai/decode#share/N4IghgDglgagpgJwM5QPYDsQC4QDcCMIANCACaoDGArgLZzoAuAKnAB4PYjAA66ABH24gkqKggpwA+gzYMhWQSACS6XKigS+AYgAsOgOz4+UJEipxSfALJhxACz4BmInwBMABlcA2Pg1R8AITgwXEQ+ABEwGj4AGVQAcxMGDSQ+ADNUBD4AEnxXIgAOHXcAOnd3F3Q4BidSoV4AX2IQCARUGggGJBZ2Th5+RShVdQlJdFoAI0RJE0kKTIQ4CjlsPn6BASEGAE8IOHlFdFEAGyEiXg3B9CQGBCpltGuD9cvFNKg4Y9Jni9fNkHQUX2qyEQzUGik4xoUwQZ1+fy2u2BCiENwQQ3icIGCLIcCQFHRnUeByETDscGMpHoyXeYVaQxklgwvnJxmGEJK9WxGwa525-1kCDAywsklwYGO5hJID0hixOIAjuYbsSQSBwqg8XwAAaC4WMsUS8zavg0MAMCgOBis7W0r4msCpKA1SB7WxO-jakRiUYydjagD8XMuDV+vN+QmoN3a00BdB+3MRe2llpGwL5l1B11u92SGCQCZxdu+qxeOLjyMUUb8dAQYyB8r+ih2ybVaIxjZxVPxhLz6GlZIpmXiYHQUAAXubHiyKWC03wAO6O4ymcyWPyckDwnkZ15CJV4vvSgDqdg0DlQROZJhnfHFkqHaR1xZNQx13vEUj9DEDwZ328jdEZHRMBCz3EAghCMI4kSFUKALVZxmOY5d0zdUoliBIkhSA4kJQ7d-kg0IskiaIYOw+DcKoZDUI2IQiMQKiaIIxRSKY05uVDAZwwGIQolERhJFIKVSwAkAW0rVF5kWTsrjRXNHgQhQyzokBizA8sGzVfiqEE4T0xY-4JOlKEYVktDdOdaUAFUAGVwnM1TuwJKAr37NVB18VAGAlW85whPhHQAa1SPw+CmPgIDAKBSE3FieMVZUjzVAAJVAFz4Y5bHiWdQptF87yNWdPQ-X1ZF-LdONowDnUQKBQNWABtFihGs9AqSyXIiHKdxHKELqeq8nJ8AqHq+pAXJRvKIbJqm3riBaiaRrmmb8G68p1vm2j-gAeWI4bNs2v8BAAXTDXchCi7Y6EE4CaCUtYxOMttpIMxMQCGeSHnzDTVPU0T+VUitpSum6GGkRB7scoykWlBk4By2EFsB-5LJWFEyDAbYEO2py8RctzpUibHAuQ9KLHSTJIqxsGXDSNpoju1IzEtQLUm4DmAWqWoOaEOLAYS8CDxVDBpTSjKzXQbY+FILHUnILVrQpW0PntNl31ET8If9UnjnSymslB6kg0qkNqpAFzgPqg5msBoRwnMPhmUWCRXJWXGhAAOW5kbxu9mpHC2xb-b4Lwg7tkAQ4ATnm7czu4xpmiQT4lkZKxUCpY4kGwRqQAAKzgXAAFospkG4QBOhogA) — Noul, Choice and two Scores over a shared `field` object
2. [JSON rubric for boundary clarification](https://console.typesafe.ai/decode#share/N4IghgDglgagpgJwM5QPYDsQC4QDcCMIANCACaoDGArgLZzoAuAKnAB4PYgCSABKgqURxSPBgAs4PJAzDpSUdAHMegpAGtRAd1Q9NcOGqQ8winbJEMEYCmoXLpUADaOpYAJ5HHYAEZwXFBDgwBmEAOh4AdTAjXjhceh4KMTAERWEAfmIQCARUGggGJBZ2TmAAHXQeHjKyOAgUhjpGGqwecsqq6pAGNwg4Fq6k1CgKfuIKzq6FaQQqCgY0dCQB9smqmoBHKjgHDAGaiLERsVEgmikxVCpHEWS5R0lxKCM6JCQTOHSaogm1moAzShUZbYLoAYS8byg-zcogkiWBDDyiAA5EYclAaClYYEtjsGEQeOhUAweHFELCkdAKDwmgsMGEar8qgBfH4ddYgAJQEIIKBgFbMzo1bxORx2QUcv4gTTJBj7EBg5KpHaEhS4YajJCEwL-KhybV8BBSKjeJDcgqLEHstbCkDEhgAfUBCAVAHkBIhRFYbHYjcYKBQrowA1rrULJjU2GB8g8Qa0ANoR6W8TTRRLKtIWTQjMY2212w5CHjPWk4uB6uRfEDJqoAXWTbOTNX4gmQkoLXVlwXdnuN0mCwMJgnF8QQbkJFFko2cwUWhP4PECDCoCCW31rXQdzv4CqVKTSRkX1iD+tJJ526alkZA0djOwGSev0qLgRLL1h9RsH2r+c7NTBac-DLI02yZZ960bP87RPYN5VBVYCxqbt4NaGoABlUEUBRCXqN5tAEXDcn+Jw4AXfs4GoPkeg3CCtxJHdXVBADMx2f0RygMc3Fo-9b1YGMIDjR9N05Xgp3QFFSUcLCS3QHjO3BO40hAuAsSccDOwbZ8WSFHSOj0lksiQPxKJCUgAFlUBHJBsATEAACs4gAWi8EJpBAOsWSAA) — three-option department Choice with `what`, `not_for` and `examples`
3. [Walking a taxonomy](https://console.typesafe.ai/decode#share/N4IghgDglgagpgJwM5QPYDsQC4QDcCMIANCACaoDGArgLZzoAuAKnAB4PYgDMATKgF4ACCABswSBlAqCARqgYMRcQQHcoDABaCwggGYioEQRIRgVgg6QB0ggGLqkgmqgmyoAa2UUwAczhIrYhAIBFQaCAYkFnZOYAAddEFBOLI4CDAEBjpGFKxBeMSk5JAGAE8IOFziig1UKUriBKLiqHQTKgpJDCQqlIB1DSktBlQIAFolXDgRQVI0jKz6BlnUf0FNKEcQ1FIO5ZlpjB911AB+FKImopSKBHVEKDAqguaklIBlCFRM1uOAcVQOx62HyV1exQAwqUKAZ0D4qgBtMHg4oAIQ8ylR8kUawAZIIIb5-BdkeCUujPIIADJQHwaSIkwoo4oACWmdAZIFJRQAupcma8UvYGOh-MC8kiBWSQABNVA+HQAWTAnP5zLeIAASv5NgwwOgKJj9aRgdyknyzcUAPJUBjkb6Iy0aliMYFq9UfJRpX6CVG+N1O1mlUimLqJAAKYAo7lNUt53IAvu7mikWWFlPiANLqGr0Z6WlIAETu6HcKgyDQlgf6KsQvuxSgDcZTICYpimM0VVB8TfVxSYtBkSmQKUtFubkMBZYrjonGvD8kc+MjbUZffJYE85YQDTHieT1xAfpkpUE+KYO1Iw9nzI+hggp4hVAgvZR5Ibyj6GToI8aE-JUAyLG4I8siCZXOB6AJkESDTHAnRwKQio7NMSDYAiIAAFZwLgEy1hIIA8gmQA) — one Choice per level with subtrees as option values
4. [Structured Score levels](https://console.typesafe.ai/decode#share/N4IghgDglgagpgJwM5QPYDsQC4QDcCMIANCACaoDGArgLZzoAuAKnAB4PYgBiUrcpAAgYALOAPRUANpIEVRFANYCo6IaIEQwATzqMBwsOlKTEAOgEBBSUlQCEcAGZgKDVPcEix9hgi0DJqKgQAgDuwlAmAgCSoWBIyqqe9kQChoIARrQQ-GpiAMoAIgDSAriIKBgCKOgUYp4CqJKCGGIGHgYMQlB0qFSdmQDmpsQgEAioNBAMSCzsnMAAOqoCC6MIAPpIFEFwq1gCi8sCKyAMWtl7J1tuu8RLx8erKkg+VC5o6EiXhw8PqwCOVDgLw+l1WAAlUCEBA5KFQkDkoPEREiNFIZPZAcDOqRgRQEFAph8GqowFUVANInJDAM4AB+VZEe6-E7oVAMW77VYAKSopFpuXEtHSiAaDgSuOyRnonWp6FpSBSbM69RQAC8xKhxYY-C1ZAZ5XBTKtmccAL5Mo4nfFQDkEsCXADapoePxZjxASFoNDAvjBIAA8ugxHLaSkKCZfZI-C8wBzSIyXb9VigBugwNYnUmWasLOT5ZEHLwGggYXA41R7Imre7VgA5dnheUCXFbAkiwRxFYLVYZmw91Yl7urMIRMQxEJdlS5Ks9kAmmsPAC62Yt2bdtc93t9Wn9QbEPunobEEEk8NSVR90jscEkcZyDBC5YU1fdHtT6cz2AEzsXyZAeZjN0O76jSYhpCSB4qG4qSkAAVs4MoCPwtqvm+HpMOoj7PlUVAQBAbjTIKh6qMeC7oSui5rouG45luNA+n636rHkcBlAgGYSnAUq4nox7xJkRgmB4qC0kkaGbh+fZZn+fwgEwIS2DBNA3AIVDoPYd7xjCvDAkODjlgwlbAhJb6rAAwgaCpqHGsi9E0yHOMIAgirkUCllCqgAAoAErkW+lHumaLqBQIwXoGaIwIiYLj8AAsqguLWNgjogHBbEALRadiIBLmaQA) — three `{summary, signals}` level objects for PR scope
5. [Structured Noul criteria](https://console.typesafe.ai/decode#share/N4IghgDglgagpgJwM5QPYDsQC4QDcCMIANCACaoDGArgLZzoAuAKnAB4PYjAA66ABH24gk9UoiFY+PfgMFkoSCABswATwD66MHQlyAQnDC5EfACLa+eqlCVjkfADINSAOiFFesuXBpgbuoXJ0VAYEOGVVAAEINQRUJSUXNm1lOCFPPgBfDxkhOiQkMABzNOw5AE1UKgQ+AEUAZj4AIwwqJD4FPjCwUlUXPgAlcKVVPgB3KAYACz5VKpqlVCKofhiCsdQEUj4kVHG4PgowfmMEKAAzUbnqjrFGSdHj7bClQxE+aYPzqnRSJDcQLxMsQQBA4jQIAwkCx2JxpAIhGEAI5UOBIKHqChhO4MKBgJRIXTw2RCBiqCClSRCYJUJTuDIIkArdEIKgUXEYQllYleIQotEc9ABECmVBoj5TA4AA3yhRKUr4YCQAGsJQcwhQoNB6AwPntSAoKIt3mAdvQULjjIdsTq8UoAPz0mS8pnoRRwdnC2XFUo5LyM86UNrChyoVCqwM1U3I1HovVm35q61wHF2jpQuBKc5EPjBXXRuD8uMMPYUKbHEp8TZdNFwXWTAEMrJ+kkgLGTRB4olNxmhVHd53+oRjcsMYUAQRV7U+Nc12sY8bCEXGkymObJFJz1ZEidNayQGy2OYACgBJAByW-QcAAtLi6IdUGItzUQpKaiJqGcyQmLVArccB7iMQPatskEKvFykgANqgS6QzLhM0yzPMfD7oepBOv6Q4gAAyqIfBtEmABsN4GssuoUE+BzXHwABWbS6hqcD-im6SDl4AC6oHZKBQjnPiIgDthjIjmAY5lEI557Duf5WliKa2viHTtDGApsSBHFgawKSQbosFafBta6tcNToZs2znOCSYiAwuLoEU7QxCUWEiYylQ3Oi4k+DqKk1j0qjsW53FaZkTZhTIEXAiQIivOyKYALLUQS2DQSAdFwLgN4qAwAogJxmRAA) — `{true, false}` each with `what` and `examples` for a phishing check
