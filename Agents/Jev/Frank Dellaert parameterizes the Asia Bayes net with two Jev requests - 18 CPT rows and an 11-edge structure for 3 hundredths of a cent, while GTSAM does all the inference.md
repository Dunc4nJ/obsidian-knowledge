---
created: 2026-09-21
source: https://x.com/fdellaert/status/2101828698756325825
author: Frank Dellaert (Georgia Tech, GTSAM)
published: 2026-09-21
type: knowledge
tags: [jev, graphical-models, bayesian-networks, factor-graphs, gtsam, probabilistic-reasoning, zero-shot, system-one-models, typesafe]
description: Frank Dellaert, creator of GTSAM, asks whether TypeSafe's Jev can supply zero-shot probabilistic factors for graphical models. Two experiments on the classic Asia/Chest Clinic network - one Jev request returns all 18 CPT rows, a second returns an 11-edge structure from 28 pairwise questions at 72.7% precision and 100% recall - for 3/100th of a cent total, with GTSAM doing every inference query afterward at no further model cost. He raises the contamination caveat himself.
---

# Frank Dellaert parameterizes the Asia Bayes net with two Jev requests - 18 CPT rows and an 11-edge structure for 3 hundredths of a cent, while GTSAM does all the inference

Frank Dellaert is a Georgia Tech robotics and computer vision professor, the creator of [GTSAM](https://gtsam.org/) (the factor-graph library underneath much of robotics SLAM), and part-time CAIO at Verdant Robotics. He is a career probabilist writing about [[moc - Jev|Jev]] from inside the field the claim would affect, and he put a question mark in his own title.

## Key Takeaways

- **The durable idea is a division of labor, not a new inference engine: the language model supplies local semantic knowledge, and a conventional graphical-model engine does the inference.** Dellaert's own closing sentence says exactly this. Once Jev has written the 18 CPT rows, GTSAM answers every subsequent evidence query by multiplying local factors, with no further model calls. That is what makes the pattern interesting relative to prompting an LLM per query: the probabilities become reusable components with a life beyond the API call, and inference cost drops to zero. This is the same split [[Sara puts an LLM agent at the center of the Bayesian optimization loop - agentic BO keeps the probabilistic surrogate while letting the agent reconfigure the search mid-run|Sara's agentic Bayesian optimization]] makes, where the agent contributes semantic priors and the Bayesian backend owns posterior uncertainty.

- **A Jev probability is not a calibrated CPT entry, and nobody has measured whether it is.** This is the sharpest objection to the piece, and Dellaert half-raises it by listing "probability calibration (which Jev explicitly was trained for)" as future work. The vault's standing finding is that the calibration claim remains unmeasured: [[LangChain's Jev-as-a-Judge bench puts Jev's quality-score variance 92 to 913x below three LLM judges at $0.34 against Claude's $28.17 - five weather traces, one human oracle, provider-default sampling|LangChain's judge bench]] measured variance, not calibration; [[Sutro's jev-align uses GEPA to rewrite Jev's decision criteria from five labeled examples - the demo moves labeled-set ambiguity 49.6 points but full-pool certainty only 0.5|Sutro's jev-align]] tunes prompt text with no calibration metric in the loop; and [[Featherless's Simple Jev reproduces Jev's API on stock open models by remapping every answer to a single-token letter and softmaxing only those logits - no classifier head, and the code stamps every answer calibrated False|Featherless's reimplementation]] stamps every answer `calibrated: False`. A Bayes net *multiplies* CPTs, so a per-row miscalibration compounds through the joint over all 256 assignments. Reading the article against this is the whole game, and Dellaert names the gap without closing it.

- **One CPT row is verifiably wrong in a way calibration cannot excuse, and it is a logical error rather than a numerical one.** The variable E is *defined* as "the patient has tuberculosis or lung cancer" - a deterministic OR, which GTSAM's canonical example writes as the literal gate `"F T T T"`. Three of its four rows came back exactly 1.00, correctly, and returning exact unity is itself proof that Jev reproduced the logical form rather than estimating. The fourth, P(E=true | T=0, L=0), came back **1%** where the gate forces 0. That 1% creates a path where "either disease" is true with neither disease present, and it flows into every downstream posterior through X and D. The point generalizes: zero-shot factors need a hard-constraint check before they enter the graph, because a language model has no mechanism that enforces a definitional identity. This is checkable for free and has nothing to do with calibration.

- **The notebook is considerably more careful about contamination than the article prose, and neither measure actually settles the question.** Dellaert flags in the article that the Asia network is in every textbook and in GTSAM's own docs, so it is presumably in Jev's training data. The notebook then takes two deliberate countermeasures the prose never mentions. For Experiment 1, `CPT_STATE['population']` literally instructs Jev to "use ordinary real-world medical knowledge, **not the memorized textbook Asia-network numbers**"; the article says only that "shared instructions specify the population and say to treat unspecified facts as unknown." For Experiment 2, the variables are anonymized to shuffled identifiers `V1` through `V8` and the state adds that "these questions ask about model structure, not whether a variable is true for a particular patient"; the article says only that he "supplied only the variable meanings." The divergence from the canonical table is therefore **by instruction**, which demonstrates that Jev follows an instruction to avoid the textbook numbers - not that it lacks them. Read honestly, neither countermeasure is evidence against contamination, and the real test remains a network the model has never seen. As @Imfulao put it in the replies, "the real test will be unfamiliar networks where memorization can't help." Dellaert does not run one.

- **Zero-shot CPTs are the first of his own three classical methods automated, not a fourth source of information.** He opens by teaching that CPTs come from our own judgment, expert interviews, or estimation from data. Jev supplies judgment distilled from text at scale - it adds no observation of the world. So the honest framing is a *much faster prior*, not a new epistemic channel, and the value is that priors become cheap enough to regenerate per context rather than elicited once and frozen. The cost supports that reading: 46 typed questions across both experiments for $0.0003, around 0.00065 cents each, which is consistent with the [[TypeSafe's Jev trades string generation for parallel-sampled typed decisions with calibrated probabilities at $0.042 per MTok - the 193x and 444x claims come from four self-built workflow evals|$0.042 per MTok]] launch pricing. The whole 18-row CPT set costs roughly a hundredth of a cent.

- **This is a use pattern that the standing taxonomy of Jev deployments does not contain.** [[Josh Rosen's Jev in the Wild sorts week-one projects into routing, context filtering, tool gating, worker supervision, fast control loops and fuzzy data queries - deterministic only because inference was expensive|Josh Rosen's landscape hub]] sorts week-one projects into routing, context filtering, tool gating, worker supervision, fast control loops and fuzzy data queries. Parameterizing a probabilistic model is none of those: the output is not a decision at all, it is a *parameter* consumed by a separate inference engine. Mechanically it is the "abuse parallel questions" technique [[Daniel Ch's How to master Jev prescribes a 0.85 and 0.55 confidence-gate ladder under an LLM that still writes - the decision-layer architecture is additive but every number and all three charts are TypeSafe's own|Daniel Ch prescribes]], pushed to its logical end - 18 and then 28 independent questions in a single request - and it runs into the [[Annabell frames TypeSafe's Jev as a savant for eval verdicts and routing - three question types, 255 choices, 10 score levels, and a Noul with no confidence field|limits Annabell documents]] soon enough, since Choice caps at 255 options and TypeSafe's own jaggedness page says the model cannot do arithmetic. The escape here is that every question is binary or ternary and no question asks for a number.

- **Choice returns a confidence alongside the distribution, and Dellaert uses none of it.** The notebook reads `response["answers"][qid]["probabilities"][label]` and nothing else. That is arguably correct, because in a CPT the probability *is* the parameter and a second-order confidence has no slot in the table. But it discards the one signal that would flag which rows to distrust, and @Madeactual's reply proposes exactly that missing piece: "gate low-confidence edges." For the structure experiment, where each answer is a model-selection vote rather than a parameter, gating on confidence is clearly the right move and would be cheap to add.

## Experiment 1 - CPTs from One Request

The target is the classic **Asia / Chest Clinic network** ([Lauritzen & Spiegelhalter, 1988](https://doi.org/10.1111/j.2517-6161.1988.tb01721.x)): eight binary variables covering travel history, smoking, diseases and symptoms. The full joint has 256 assignments; the graph's sparsity means only **18 CPT rows** are needed to specify it.

Each CPT row becomes one Jev **Choice** question about a child variable under one specific parent assignment, with options `false` and `true`. Shared instructions in the `state` fix the population and tell the model to treat unspecified facts as unknown. **All 18 rows came back from a single API request.**

The exact request is the reusable artifact. This is the state, verbatim from the notebook:

```python
CPT_STATE = {'task': 'Parameterize a small educational Bayesian network about respiratory disease.',
 'population': 'Imagine a randomly selected adult patient in a general clinical population. '
               'Use ordinary real-world medical knowledge, not the memorized textbook '
               'Asia-network numbers.',
 'interpretation': 'For each question, return a probability distribution for the child '
                   'variable under exactly the stated parent assignment. Treat unspecified '
                   'variables as unknown; do not assume them false.'}
```

And this is how the 18 questions are generated, one per parent assignment, each a `Choice` with two criteria:

```python
rows = [(child, values) for child, (_, parents) in NODES.items()
        for values in it.product((0, 1), repeat=len(parents))]
cpt_questions = {}
for child, values in rows:
    meaning, parents = NODES[child]
    suffix = "_".join(f"{p}{v}" for p, v in zip(parents, values)) or "root"
    condition = " ".join(
        f"It is {'true' if v else 'false'} that {NODES[p][0]}."
        for p, v in zip(parents, values)
    ) or "No other facts about this randomly selected patient are given."
    cpt_questions[f"cpt_{child}_{suffix}"] = {
        "instructions": f"Given the stated condition, which truth value best describes whether {meaning}? "
                        f"Condition: {condition}",
        "criteria": {"false": f"It is false that {meaning}.",
                     "true": f"It is true that {meaning}."},
    }
```

All 18 go out in one call against `jev-1.13.0`:

```python
with TypeSafeClient() as client:
    response = client.system_one(
        model=MODEL, state=state,
        questions={qid: Choice(**spec) for qid, spec in questions.items()},
    ).model_dump(mode="json")
return np.array([[response["answers"][qid]["probabilities"][label]
                  for label in labels] for qid in questions], dtype=float)
```

### The 18 CPT rows, against the canonical table

Jev's values are transcribed from Figure 2 (teal = P(true)) and cross-checked against the notebook's `recorded_cpts` array, which agrees exactly. Note that the recorded array stores two decimal places, so it carries no more precision than the figure's whole percentages.

The canonical column is the Lauritzen & Spiegelhalter parameterization as it appears in [GTSAM's own Asia example](https://borglab.github.io/gtsam/discretebayesnetexample) - the page Dellaert names as the likely contamination source, and which he co-authored. P(false) is the complement throughout.

| Variable | Parent condition | Jev P(true) | Canonical P(true) | Delta |
| --- | --- | --- | --- | --- |
| A - Asia visit | root, no parents | 4% | 1% | +3 |
| S - Smoking | root, no parents | 20% | 50% | -30 |
| T - Tuberculosis | A=0 | 3% | 1% | +2 |
| T - Tuberculosis | A=1 | 32% | 5% | +27 |
| L - Lung cancer | S=0 | 1% | 1% | 0 |
| L - Lung cancer | S=1 | 8% | 10% | -2 |
| B - Bronchitis | S=0 | 5% | 30% | -25 |
| B - Bronchitis | S=1 | 69% | 60% | +9 |
| E - Either disease | T=0, L=0 | 1% | 0% | +1 |
| E - Either disease | T=0, L=1 | 100% | 100% | 0 |
| E - Either disease | T=1, L=0 | 100% | 100% | 0 |
| E - Either disease | T=1, L=1 | 100% | 100% | 0 |
| X - Abnormal X-ray | E=0 | 11% | 5% | +6 |
| X - Abnormal X-ray | E=1 | 99% | 98% | +1 |
| D - Shortness of breath | E=0, B=0 | 7% | 10% | -3 |
| D - Shortness of breath | E=0, B=1 | 85% | 80% | +5 |
| D - Shortness of breath | E=1, B=0 | 95% | 70% | +25 |
| D - Shortness of breath | E=1, B=1 | 97% | 90% | +7 |

Mean absolute deviation across the 18 rows is **8.1 percentage points**, with four divergences of 20 points or more: smoking prevalence (20% against 50%), tuberculosis given an Asia visit (32% against 5%), bronchitis in a non-smoker (5% against 30%), and shortness of breath given disease without bronchitis (95% against 70%). Four rows match exactly, three of which are the deterministic `E` rows.

**These are not the textbook numbers. But that is because the prompt told Jev not to use them**, and the divergence has to be read in that light - see the takeaway on contamination below.

**The numerical agreement is weak while the structural agreement is exact.** The canonical `E` row is a hard OR gate, written in GTSAM as `"F T T T"` - a literal false followed by three trues. Jev returned exactly 1.00 on all three true rows, which no genuinely uncertain estimator would do, so it clearly reproduced the logical form of the gate. It then leaked **1%** onto the one row the gate forces to zero. Three rows right by construction, one row wrong by construction.

**Direction of error is mixed, so "Jev's priors are more modern" is only half true.** Smoking at 20% against the 1988 table's 50%, and non-smoker bronchitis at 5% against 30%, are both far closer to present-day epidemiology than the benchmark. But tuberculosis at 32% following an Asia visit is clinically absurd and much worse than the canonical 5%. Jev is not uniformly recalibrating toward reality; it is producing plausible-sounding numbers that happen to be better on two rows and considerably worse on another.

### What GTSAM does with them

The tables are loaded into a `gtsam.DiscreteBayesNet`, observations are added as unary factors on a `DiscreteFactorGraph`, and `DiscreteMarginals` produces the posteriors. **No further Jev calls.** With Asia held at False, adding an abnormal X-ray and then shortness of breath moves the three disease posteriors:

| Observations | Tuberculosis | Lung cancer | Bronchitis |
| --- | --- | --- | --- |
| No Asia visit (A=0) | 3.00% | 2.40% | 17.80% |
| + abnormal X-ray (A=0, X=1) | 17.98% | 14.38% | 21.47% |
| + shortness of breath (A=0, X=1, D=1) | 35.26% | 28.39% | 40.21% |

Dellaert is explicit that this part is not new: "inference in Bayes nets is very well established." The novelty claim is only about where the tables came from.

## Experiment 2 - The Structure Itself

Second request, same pattern, different question. He supplied **only the variable meanings**, sent **no reference edges and no CPTs**, and asked about all **28 unordered pairs** in one API request. Each question was a three-option Choice: an edge from the first variable to the second, an edge in the reverse direction, or no direct edge (`no_edge`, `u_to_v`, `v_to_u`). The instructions ask the model to account for mediation through the other listed variables, so that association through a shared cause does not earn a direct edge.

The variables are **anonymized**, which is the second contamination countermeasure the article prose does not mention. The notebook maps shuffled identifiers `V1` through `V8` onto the letters `LSABETDX`, so `V1` is lung cancer and `V3` is the Asia visit, and every question is phrased in terms of the opaque identifier plus a meaning string. The state adds that "these questions ask about model structure, not whether a variable is true for a particular patient." The three extra edges were therefore proposed against anonymized identifiers, not against the familiar `A`, `T`, `E` labels.

He then combined the 28 answers into an acyclic graph by maximizing `sum(log P(pair choice)) - number of edges` with an edge penalty of 1.0, checking all **8! = 40,320** variable orderings to enforce acyclicity. That took **38 ms on a MacBook Air**.

**Result: 11 edges - all 8 reference directions recovered, 3 extras, 0 missing, 0 reversed. 72.7% directed precision, 100% recall.** The three extras connect diseases directly to symptoms that the reference graph routes through "either disease":

- lung cancer → abnormal X-ray
- tuberculosis → abnormal X-ray
- tuberculosis → shortness of breath

These are arguably defensible clinically rather than simply wrong, which makes the 72.7% precision figure harsher than the result deserves. Dellaert flags his own thumb on the scale: "I also cheated a bit by selecting a nice edge penalty in the structure recovery example." The exhaustive search is factorial, which he notes is fine at eight variables and not a method.

## The Notebook

The gist `dellaert/ed9c8ed6bbfa22a4f027474b9c3e32b5` contains one file, `jev_minimal_repro.ipynb` - 242 lines, 14 cells (6 code, 8 markdown), no stored outputs. Its own title cell says it reproduces "the article's CPTs, three evidence updates, and structure recovery," so it covers all three stages including the posterior inference the article body only alludes to. Full code is in the Original Content callout below under its own sub-heading; the two most reusable pieces are quoted in the Experiment 1 section above.

**Everything is pinned, including the model.** The setup cell fixes `typesafe-sdk==0.7.0` and `numpy==1.26.4`, and installs a pre-release `gtsam>4.3a0` only when neither `gtsam` nor `gtsam-develop` is already newer than `4.3a0`. The model string is the exact version **`jev-1.13.0`**, not a floating `jev-latest` alias - which matters, because a CPT set is only reproducible against a pinned model. @Madeactual's reply independently recommends the same practice.

**The default path makes no API calls at all.** `LIVE = False` replays the `recorded_cpts` and `recorded_pairs` arrays embedded in the notebook, and only `LIVE = True` issues the two requests, prompting for `TYPESAFE_API_KEY` if it is unset. That is a good reproducibility design: anyone can rerun the full pipeline and get the article's exact figures without a key or a cent of spend. The one caveat is that the recorded arrays are stored at two decimal places, so the replay carries the same precision as the published figures and no more.

The three evidence queries the notebook runs, all after Jev is out of the loop, are cumulative observations on a `DiscreteFactorGraph`: `{A: 0}`, then `{A: 0, X: 1}`, then `{A: 0, X: 1, D: 1}`. Each is added as a unary factor and marginalized with `DiscreteMarginals`, reading back the posterior for tuberculosis, lung cancer and bronchitis. The results are the table in the Experiment 1 section.

The variable definitions and dependency structure that feed the question generator:

```python
NODES = {
    'A': ('the patient recently visited Asia', ()),
    'S': ('the patient is a smoker', ()),
    'T': ('the patient has tuberculosis', ('A',)),
    'L': ('the patient has lung cancer', ('S',)),
    'B': ('the patient has bronchitis', ('S',)),
    'E': ('the patient has tuberculosis or lung cancer', ('T', 'L')),
    'X': ("the patient's chest X-ray is abnormal", ('E',)),
    'D': ('the patient has shortness of breath (dyspnea)', ('E', 'B')),
}
```

Note that `E`'s meaning string is a definitional OR over `T` and `L`, which is what makes the 1% row a definite error rather than a debatable estimate.

The notebook's own closing disclaimer: "The graph is the classic Asia/Chest Clinic benchmark (Lauritzen & Spiegelhalter, 1988); the probabilities are Jev's estimates. The edge penalty was selected for the article's comparison. These are modeling demonstrations, not clinical estimates."

He credits **GPT-6 Astra** for help writing the code, and separately admits the best line in the Discussion section - "Graphical models give Jev's judgments a life beyond the API call" - was AI generated.

## Discussion and Limits

Dellaert's own list of what still needs doing, in his words: "evaluation on unfamiliar networks, probability calibration (which Jev explicitly was trained for), and measuring how modeling errors affect inference." He adds the edge-penalty selection as a fourth admission.

Three limits worth separating out from his hedges:

1. **He never runs the novel-network test.** Both experiments use the single most famous toy Bayes net in existence, one that ships in GTSAM's own documentation. The contamination caveat is stated, not addressed.
2. **Calibration is asserted upstream, not measured here.** "Which Jev explicitly was trained for" is a claim about TypeSafe's training objective, not evidence about these 18 numbers. Error propagation through the joint is listed as future work, and it is the thing that determines whether the method is usable.
3. **Continuous and hybrid factors are left entirely open.** Everything here is discrete and binary. GTSAM's main strength is continuous optimization and it has [hybrid](https://borglab.github.io/gtsam/hybrid/) discrete-continuous machinery, but a Choice question over `{false, true}` has no path to a Gaussian factor, and Jev cannot emit numbers. Whether the pattern extends past discrete variables is unaddressed.

## Reading List

An AI-assisted search, with his disclaimer: "I'm not an expert in this literature... I have not (yet) read them carefully" and "Summaries below are entirely AI."

- [Causal Reasoning and Large Language Models: Opening a New Frontier for Causality](https://www.microsoft.com/en-us/research/publication/causal-reasoning-and-large-language-models-opening-a-new-frontier-for-causality/) - Kıcıman et al. (TMLR, 2024). LLMs answering causal questions from variable names and descriptions; already suggested combining semantic knowledge with conventional causal methods.
- [Causal Discovery with Language Models as Imperfect Experts](https://arxiv.org/abs/2307.02390) - Long et al. (2023). Treat the model as a fallible domain expert supplying constraints to an ordinary causal-discovery procedure, not as the inference algorithm.
- [Large Language Models are Effective Priors for Causal Graph Discovery](https://arxiv.org/abs/2405.13551) - Darvariu, Hailes, and Musolesi (2024). Turns LLM judgments about structure and edge direction into priors for conventional algorithms.
- [Scalability of Bayesian Network Structure Elicitation with Large Language Models](https://aclanthology.org/2025.coling-main.713/) - Babakov, Reiter, and Bugarín (COLING, 2025). Majority-vote aggregation over multiple LLM structure proposals, and it surfaces both problems that matter here: performance degrades as networks grow, and famous benchmarks may already be familiar to the model.
- [Bayesian Network Structure Discovery Using Large Language Models](https://arxiv.org/abs/2511.00574) - Zhang et al. (2026). PromptBN builds a whole DAG from variable descriptions; ReActBN adds observational-data scores.
- [Extracting Probabilistic Knowledge from Large Language Models for Bayesian Network Parameterization](https://jmlr.org/tmlr/papers/) - Nafar et al. (TMLR, 2026). Dellaert calls this the closest prior work: eliciting the numerical conditional probabilities themselves, evaluated across **80 Bayesian networks**, positioning LLM-derived distributions as expert priors when data is scarce. This is the paper that makes the "paradigm shift" question mark appropriate.
- [Can Large Language Models Infer Causation from Correlation?](https://proceedings.iclr.cc/paper_files/paper/2024/hash/7b75a7339dfb256ee4b4bec028a6890b-Abstract-Conference.html) - Jin et al. (ICLR, 2024). LLMs do poorly at abstract causal inference from correlational information alone, which is the motivation for the whole split: let the model supply local semantic knowledge and let a graphical-model engine do the inference.

## Replies

**11 replies fetched; none are from Dellaert.** He had not replied in the thread at capture time, so there are no author replies to quote. The host tweet showed 12 replies at the orchestrator's fetch against 11 returned, a one-reply gap most likely from a deletion or a nested reply not surfaced by the thread endpoint. No pure reactions are exposed by this endpoint, so none were counted or skipped.

The substantive ones:

- **@sirbayes (Kevin Patrick Murphy)** - the highest-signal reply in the thread, from the author of the standard Bayesian ML textbooks: "I was planning to try exactly this idea (with a different PGM backend) but you beat me to it!" He points to "large language bayes" by @JustinDomke. Independent convergence on the same idea from the field's most visible textbook author is stronger evidence that the pattern is real than anything in the article. The vault already holds Murphy's own work on the adjacent problem in [[Model Discovery Agent couples an LLM proposer with SMC, SBI, and value-of-information to discover mechanistic world models from few experiments]], where an LLM proposer is paired with sequential Monte Carlo and simulation-based inference rather than with a discrete PGM.
- **@jatingargiitk (Jatin Garg)** - the real probabilist objection to Experiment 2: "It can specify the structure if you give it examples and variable names. The harder part is getting it to respect conditional independence without violating d-separation rules." Dellaert's method sidesteps this by asking about pairs independently and then repairing acyclicity with a search, which means the model never reasons about conditional independence at all; the edge penalty is doing that work.
- **@Imfulao (Stephen)** - states the contamination objection cleanly: eliciting every CPT row in one request "shows Jev working as a knowledge front-end for GTSAM. The real test will be unfamiliar networks where memorization can't help."
- **@Madeactual** - the most operationally specific reply: "Jev is useful here, but not as a reasoning engine. It answers typed noul/choice/score questions over state and returns calibrated probabilities; the graph owns structure. Batch checks, pin jev-1.13.0, and gate low-confidence edges. Bad criteria still produce wrong decisions." The "gate low-confidence edges" suggestion is the confidence signal Dellaert leaves unused; the "returns calibrated probabilities" clause repeats the unmeasured vendor claim.
- **@nicklaunchesai** - compressed skepticism: "Jev is more classifier than spec, graphs still need a schema."
- **@hilbertshelper (DeepClause)** - asks whether there are implications for probabilistic logic programming, tagging @NandoDF.
- **@malikatifsaleem (Atif Saleem)** - asks about graphical workflows combining Jev-style decision models with reasoning, vision and agentic models.
- **@jbermudez5 (JB)** - points to a World Models talk that "really sold me on thinking of next action/state prediction."
- **@ItsCuthulhu (Cuth)** - quote-tweets their own MetaCog article rather than engaging.

Praise only, no content: **@MichelIvan92347** ("Interesting read and ideas here. Bravo!") and **@avi_research** ("Wow, very cool connection.").

## Related

Within Jev: [[moc - Jev]] indexes the folder. The mechanics of Choice, Score and Noul and their hard limits are in [[Annabell frames TypeSafe's Jev as a savant for eval verdicts and routing - three question types, 255 choices, 10 score levels, and a Noul with no confidence field]]; the launch and pricing in [[TypeSafe's Jev trades string generation for parallel-sampled typed decisions with calibrated probabilities at $0.042 per MTok - the 193x and 444x claims come from four self-built workflow evals]]. On calibration specifically: [[LangChain's Jev-as-a-Judge bench puts Jev's quality-score variance 92 to 913x below three LLM judges at $0.34 against Claude's $28.17 - five weather traces, one human oracle, provider-default sampling]], [[Sutro's jev-align uses GEPA to rewrite Jev's decision criteria from five labeled examples - the demo moves labeled-set ambiguity 49.6 points but full-pool certainty only 0.5]] with its repo at [[jev-align]], and [[simple-jev]] with [[Featherless's Simple Jev reproduces Jev's API on stock open models by remapping every answer to a single-token letter and softmaxing only those logits - no classifier head, and the code stamps every answer calibrated False]]. Other open reimplementations are catalogued in [[jevlike]].

On the batched-questions technique this pushes to its limit: [[Daniel Ch's How to master Jev prescribes a 0.85 and 0.55 confidence-gate ladder under an LLM that still writes - the decision-layer architecture is additive but every number and all three charts are TypeSafe's own]] and [[Can Bölük's jegrep turns Jev into a semantic grep by scoring grep-ranked candidates with one Noul per file and a Choice for the line range - $0.004 a query, and the Gemini-lite comparison is nowhere in the repo]]. Because a CPT set is a pure function of the graph and the variable descriptions, it is an unusually good fit for the memoization in [[Varun Mathur's jevcache memoizes Jev decisions by sha256 of model, schema and redacted canonical state - the 60 to 80 percent repeat rate is asserted and dropping user_id collides two subjects]]. The taxonomy this pattern escapes is in [[Josh Rosen's Jev in the Wild sorts week-one projects into routing, context filtering, tool gating, worker supervision, fast control loops and fuzzy data queries - deterministic only because inference was expensive]].

Outside the folder, the same LLM-proposes / probabilistic-engine-infers split appears in [[Sara puts an LLM agent at the center of the Bayesian optimization loop - agentic BO keeps the probabilistic surrogate while letting the agent reconfigure the search mid-run]] and in [[Model Discovery Agent couples an LLM proposer with SMC, SBI, and value-of-information to discover mechanistic world models from few experiments]], and the pattern of consuming a model's calibrated scores as a component of a larger algorithm appears in [[LATTICE uses LLM-guided semantic tree traversal with calibrated scoring to achieve logarithmic-complexity retrieval that outperforms reranking on reasoning-intensive benchmarks]].

## Links

- [Host tweet](https://x.com/fdellaert/status/2101828698756325825) - "Can Jev specify graphical models for us?", 2026-09-21, 266 likes / 31 RTs / 12 replies
- [Introducing System One Models and Jev](https://typesafe.ai/blog/introducing-system-one-models-and-jev) - TypeSafe's launch post
- [Choice primitive docs](https://docs.typesafe.ai/primitives/choice) - the interface both experiments use
- [The notebook (gist)](https://gist.github.com/dellaert/ed9c8ed6bbfa22a4f027474b9c3e32b5) - `jev_minimal_repro.ipynb`, runs without an API key
- [GTSAM](https://gtsam.org/) - the factor-graph library
- [GTSAM discrete inference](https://borglab.github.io/gtsam/discrete/)
- [GTSAM discrete Bayes nets](https://borglab.github.io/gtsam/discretebayesnet/)
- [GTSAM's own Asia network example](https://borglab.github.io/gtsam/discretebayesnetexample) - the contamination source he names, and the source of the canonical CPT column above: priors `99/1` and `50/50`, `P(T|A)` as `99/1 95/5`, `P(L|S)` as `99/1 90/10`, `P(B|S)` as `70/30 40/60`, `P(E|T,L)` as the gate `F T T T`, `P(X|E)` as `95/5 2/98`, and `P(D|E,B)` as `9/1 2/8 3/7 1/9`
- [GTSAM hybrid inference](https://borglab.github.io/gtsam/hybrid/)
- [testSudoku.cpp](https://github.com/borglab/gtsam/blob/develop/gtsam_unstable/discrete/tests/testSudoku.cpp) - GTSAM solving Sudoku with discrete factors
- [Lauritzen & Spiegelhalter, 1988](https://doi.org/10.1111/j.2517-6161.1988.tb01721.x) - the original Asia / Chest Clinic paper
- [Causal Reasoning and Large Language Models](https://www.microsoft.com/en-us/research/publication/causal-reasoning-and-large-language-models-opening-a-new-frontier-for-causality/) - Kıcıman et al., TMLR 2024
- [Causal Discovery with Language Models as Imperfect Experts](https://arxiv.org/abs/2307.02390) - Long et al., 2023
- [LLMs are Effective Priors for Causal Graph Discovery](https://arxiv.org/abs/2405.13551) - Darvariu et al., 2024
- [Scalability of Bayesian Network Structure Elicitation with LLMs](https://aclanthology.org/2025.coling-main.713/) - Babakov et al., COLING 2025
- [Bayesian Network Structure Discovery Using LLMs](https://arxiv.org/abs/2511.00574) - Zhang et al., 2026
- [Extracting Probabilistic Knowledge from LLMs for Bayesian Network Parameterization](https://jmlr.org/tmlr/papers/) - Nafar et al., TMLR 2026
- [Can Large Language Models Infer Causation from Correlation?](https://proceedings.iclr.cc/paper_files/paper/2024/hash/7b75a7339dfb256ee4b4bec028a6890b-Abstract-Conference.html) - Jin et al., ICLR 2024

## Original Content

> [!quote]- Host tweet and full article - Frank Dellaert, "Jev + graphical models: a paradigm shift?" (2026-09-21)
>
> #### Host tweet
>
> **@fdellaert (Frank Dellaert)** - 2026-09-21 00:19 UTC - 266 likes / 31 RTs / 12 replies
> https://x.com/fdellaert/status/2101828698756325825
>
> > Can Jev specify graphical models for us?
>
> #### Article
>
> # Jev + graphical models: a paradigm shift?
>
> *By Frank Dellaert (@fdellaert), article created 2026-09-21T00:19:46.000Z, host tweet https://x.com/fdellaert/status/2101828698756325825, article id 2101819215795609601*
>
> Could [Jev](https://typesafe.ai/blog/introducing-system-one-models-and-jev) + graphical models fundamentally change how we build systems that reason under uncertainty? Unless you've been off the grid this week, you now know that Jev is @typesafeai’s new model for structured decisions: give it a question and a set of possible outcomes, and it returns probabilities for those outcomes. That ability combined with graphical models (my neck of the woods!) strikes me as potentially revolutionary.
>
> In particular, Jev could provide zero-shot probabilistic factors for any graphical model reasoning engine, including [GTSAM](https://gtsam.org/)! While GTSAM is best known as a *continuous* optimization library for robotics and computer vision, we also have [discrete](https://borglab.github.io/gtsam/discrete/) and [hybrid](https://borglab.github.io/gtsam/hybrid/) inference built in. It can even [solve Sudoku puzzles](https://github.com/borglab/gtsam/blob/develop/gtsam_unstable/discrete/tests/testSudoku.cpp)! Jev gives us a way to supply those factors from knowledge *expressed in language*.
>
> When I introduce ***Bayes networks*** in a class, I usually explain three ways to obtain their ***conditional probability tables*** (CPTs): our own judgment, interviews with experts, or estimation from data. Even when the inference machinery is ready, assembling that knowledge can be a substantial undertaking.
>
> With some help from Astra, I ran two experiments using Jev+GTSAM that I think are very cool! **And they only cost me a total of 3/100th of a cent!** In the first experiment, *one* Jev request gave me every conditional probability table in an eight-variable network. GTSAM then used those tables to answer new evidence queries. In the second experiment, I used Jev to elucidate the Bayes net topology itself: it proposed relationships from variable descriptions, and came remarkably close to the example I used. Both experiments are *zero-shot*: they draw on knowledge already available in the model, without expert interviews or a dedicated training dataset.
>
> A quick AI-assisted literature search also turned up quite some prior work on using language models to build probabilistic models. I’ve collected some papers at the end, but should note I have not (yet) read them carefully - and this is not quite my home turf.
>
> ## Bayesian Networks
>
> ![[fdellaert-325825-001.jpg]]
>
> *Figure 1. A Bayes network and one CPT. The arrows specify the dependencies, while CPTs specify a conditional probability distribution for each parent assignment. A CPT can also be seen as a factor in factor graph, which is how GTSAM treats them. In my first experiment, Jev supplies the probabilities for the classic Asia/Chest Clinic graph.*
>
> A [Bayesian network](https://borglab.github.io/gtsam/discretebayesnet/) represents uncertain quantities through a graph of local dependencies. I’ll use the **classic Asia/Chest Clinic network ([Lauritzen & Spiegelhalter, 1988](https://doi.org/10.1111/j.2517-6161.1988.tb01721.x))**, a historical (and deliberately over-simplified) benchmark with eight variables covering travel history, smoking, diseases, and symptoms. Every variable is binary: true or false. An arrow identifies a parent whose value is an input to the child's conditional probability table.
>
> > CAVEAT: This particular example is very well known in the literature, is present in many textbooks, including in [GTSAM's own example](https://borglab.github.io/gtsam/discretebayesnetexample), and presumably also in Jev's training data. So all of the results below are in a sense potentially tainted.
>
> A conditional probability table (CPT) gives a distribution for every assignment of a variable’s parents. For *tuberculosis*, this graph uses just one parent: whether the patient visited *Asia*. The table therefore has two rows. With no *Asia* visit, the Jev table assigns 97% probability to *tuberculosis* being absent and 3% to it being present. An *Asia* visit gives 68% and 32%. Each row sums to one.
>
> Multiplying all local CPTs defines a ***joint distribution*** over all 256 binary assignments in this example. The sparsity induced by the graph let us specify that distribution with only 18 CPT rows. The dependency structure makes that compact representation possible. ***Inference*** in Bayes nets lets us predict symptoms from diseases and update disease probabilities from observed symptoms.
>
> ## The “Jev” opportunity
>
> Jev’s [Choice interface](https://docs.typesafe.ai/primitives/choice) is exactly what we want to query for the outcome probabilities needed in each CPT row: we define the options, and it returns a probability for each. Here those options are false and true, and each question describes one child variable under one parent assignment.
>
> ![[fdellaert-325825-002.jpg]]
>
> *Figure 2. Jev supplies eight CPTs from 18 questions in one API request. Teal shows P(true); the remainder is P(false). Each condition identifies a particular row, and the graph in Figure 1 defines the variable letters.*
>
> I used [this notebook](https://gist.github.com/dellaert/ed9c8ed6bbfa22a4f027474b9c3e32b5) to demonstrate the idea: each CPT row becomes a *language question* about a child variable, given a specific parent assignment. For example, the notebook asks whether the patient has tuberculosis under the condition that it is false that the patient recently visited Asia. Shared instructions specify the population and say to treat unspecified facts as unknown. We repeat this for every required parent assignment.
>
> One API request supplied all 18 CPT rows, without example tables or task-specific training data. I just provided the graph and variable descriptions; Jev supplied the numbers. That is zero-shot CPT generation for the entire network.
>
> ![[fdellaert-325825-003.jpg]]
>
> *Figure 3. Add no Asia visit, then an abnormal X-ray, then shortness of breath. Each row accumulates the listed observations. The three disease columns share the same 0–50% scale; other variables remain unknown and are summed over.*
>
> The graph computes these joint evidence updates from local distributions, without sending the combined questions to Jev. In my case, I used GTSAM with Jev’s tables to compute new posteriors - without any further model calls! The same tables support a whole family of queries.
>
> For example, with *Asia* held fixed at False, the tuberculosis posterior rises **3.00% → 17.98% → 35.26%**, as we add an abnormal X-ray and then shortness of breath. Lung cancer goes from **2.40% → 14.38% → 28.39%**, and bronchitis from **17.80% → 21.47% → 40.21%**. This is nothing new: inference in Bayes nets is very well established.
>
> What *is* new (although see related work at end), and a potential paradigm shift, is turning Jev's pretrained knowledge into the explicit, reusable components of a graphical model.
>
> ## Can Jev give us the Bayes Net itself?
>
> Yes !!! Jev can also propose the graph itself: in a second experiment I supplied only the variable meanings, and asked about all 28 unordered pairs, again in *one* API request. Each question now offered three possibilities: an edge in either direction, or no direct edge. Hence, the prompt asked Jev to account for relationships mediated by the other variables. I then combined those answers into an acyclic graph, scoring their log probabilities, with a penalty per edge to favor a sparse structure.
>
> ![[fdellaert-325825-004.jpg]]
>
> *Figure 4. The recovered graph contains 11 edges: all eight reference directions and three extras, with no missing or reversed edges. That is **72.7% directed precision and 100% recall**. Dashed orange edges mark the additional dependencies.*
>
> The figure above shows the result: Compared to the Asia network, Jev wants to add three extra edges, connecting diseases directly to symptoms that the reference graph reaches through “either disease.” They are lung cancer → abnormal X-ray, tuberculosis → abnormal X-ray, and tuberculosis → shortness of breath.
>
> [The notebook](https://gist.github.com/dellaert/ed9c8ed6bbfa22a4f027474b9c3e32b5)’s exhaustive graph search has factorial complexity, but machine learning offers a substantial literature on more scalable alternatives. For eight variables, though, checking all **8! = 40,320 orderings** is quite doable: it only took 38 ms on my MacBook Air 😃.
>
> ## Discussion
>
> > Graphical models give Jev’s judgments a life beyond the API call.
>
> The sentence above was was AI generated, but I like it! A generated CPT becomes part of an explicit graphical model that can use new evidence, supports new queries, and even the sparse graphical structure can be inferred, at an incredibly low cost. That must mean something !
>
> ## Next Steps and Quick Lit Search
>
> Try this yourself with [the notebook I provided](https://gist.github.com/dellaert/ed9c8ed6bbfa22a4f027474b9c3e32b5). It should install everything that's needed, and does not need a Jev API key, unless you want to modify the example or re-query Jev.
>
> Careful science still needs to be done. This includes evaluation on unfamiliar networks, probability calibration (which Jev explicitly was trained for), and measuring how modeling errors affect inference. These examples use a [familiar benchmark](https://borglab.github.io/gtsam/discretebayesnetexample), and I also cheated a bit by selecting a nice edge penalty in the structure recovery example.
>
> The main ideas above -- using language models to supply the structure of probabilistic models, and using them to supply the probabilities themselves -- have already been explored in a number of recent papers. ***I’m not an expert in this literature***, and I found these using a quick AI-assisted literature search. So, don't yell at me for missing your work 😃. Summaries below are entirely AI:
>
> - [Causal Reasoning and Large Language Models: Opening a New Frontier for Causality](https://www.microsoft.com/en-us/research/publication/causal-reasoning-and-large-language-models-opening-a-new-frontier-for-causality/) — Kıcıman et al. (TMLR, 2024). An early influential demonstration that LLMs can use knowledge encoded in language to answer causal questions and propose causal relationships from variable names and descriptions. Crucially, the authors already suggested combining this semantic knowledge with conventional causal methods.
>
> - [Causal Discovery with Language Models as Imperfect Experts](https://arxiv.org/abs/2307.02390) — Long et al. (2023). Makes the connection especially explicit: treat the language model not as the inference algorithm, but as a fallible domain expert whose judgments provide constraints to an ordinary causal-discovery procedure.
>
> - [Large Language Models are Effective Priors for Causal Graph Discovery](https://arxiv.org/abs/2405.13551) — Darvariu, Hailes, and Musolesi (2024). Pushes this idea further by turning LLM judgments about graph structure and edge direction into priors for conventional causal-discovery algorithms.
>
> - [Scalability of Bayesian Network Structure Elicitation with Large Language Models](https://aclanthology.org/2025.coling-main.713/) — Babakov, Reiter, and Bugarín (COLING, 2025). Moves specifically to Bayesian networks: multiple LLM queries independently propose network structure, which is aggregated by majority vote. Their experiments also expose two important problems for evaluation: performance degrades as networks grow, and famous benchmark networks may already be familiar to the LLM.
>
> - [Bayesian Network Structure Discovery Using Large Language Models](https://arxiv.org/abs/2511.00574) — Zhang et al. (2026). PromptBN asks an LLM to construct an entire DAG directly from variable descriptions, while ReActBN combines this semantic proposal with scores from observational data. This comes particularly close to automatically constructing the graphical model from language.
>
> - [Extracting Probabilistic Knowledge from Large Language Models for Bayesian Network Parameterization](https://jmlr.org/tmlr/papers/) — Nafar et al. (TMLR, 2026). This is the closest prior work to the experiments here. Rather than only asking which variables should be connected, they elicit the numerical conditional probabilities themselves, evaluating the idea across 80 Bayesian networks and showing how LLM-derived distributions can serve as expert priors when observational data are scarce.
>
> - Jin et al., in [Can Large Language Models Infer Causation from Correlation?](https://proceedings.iclr.cc/paper_files/paper/2024/hash/7b75a7339dfb256ee4b4bec028a6890b-Abstract-Conference.html) (ICLR, 2024), show that LLMs perform poorly when asked to carry out abstract causal inference from correlational information alone.
>
> The last paper is interesting, and in a way motivates the others: **we should have the language model supply local semantic knowledge. After that, a conventional graphical-model engine does the inference.**
>
> #### Notebook (gist)
>
> `https://gist.github.com/dellaert/ed9c8ed6bbfa22a4f027474b9c3e32b5` - one file, `jev_minimal_repro.ipynb`, 14 cells (6 code, 8 markdown), no stored outputs.
>
> **Cell 0 (markdown)**
>
> > # Jev + GTSAM: minimal reproduction
> >
> > A standalone reproduction of the article’s CPTs, three evidence updates, and structure recovery for the classic Asia/Chest Clinic network.
>
> **Cell 1 (markdown)**
>
> > The setup cell installs missing dependencies into the active kernel. It installs or upgrades `gtsam` only when neither `gtsam` nor `gtsam-develop` is newer than `4.3a0`; any newer installed version is left unchanged.
>
> **Cell 2 (code)**
>
> ```python
> import importlib.util
> import subprocess
> import sys
> from importlib.metadata import version, PackageNotFoundError
>
> requirements = {
>     "numpy": "numpy==1.26.4",
>     "typesafe_sdk": "typesafe-sdk==0.7.0",
>     "packaging": "packaging",
> }
> missing_packages = [package for module, package in requirements.items()
>                     if importlib.util.find_spec(module) is None]
> if missing_packages:
>     subprocess.check_call([sys.executable, "-m", "pip", "install", "-q", *missing_packages])
>
> from packaging.version import Version
>
> gtsam_versions = []
> for package in ("gtsam", "gtsam-develop"):
>     try:
>         gtsam_versions.append(Version(version(package)))
>     except PackageNotFoundError:
>         pass
> if any(v > Version("4.3a0") for v in gtsam_versions):
>     print("GTSAM newer than 4.3a0 is already installed; leaving it unchanged.")
> else:
>     subprocess.check_call([sys.executable, "-m", "pip", "install", "-q", "--pre", "gtsam>4.3a0"])
> ```
>
> **Cell 3 (markdown)**
>
> > You can run this notebook even if you do not have a JEV API key. `LIVE = False` uses the original `jev-1.13.0` probabilities embedded below. Change it to `True` to make **two Jev requests** with the original prompts; enter your key in the hidden prompt or set `TYPESAFE_API_KEY`.
>
> **Cell 4 (code)**
>
> ```python
> import itertools as it
> import os
> from getpass import getpass
>
> import numpy as np
> import gtsam
>
> LIVE = False
> MODEL = "jev-1.13.0"
>
>
> def ask(state, questions, recorded, labels):
>     if not LIVE:
>         return np.array(recorded, dtype=float)
>     from typesafe_sdk import Choice, TypeSafeClient
>     if not os.getenv("TYPESAFE_API_KEY", "").strip():
>         os.environ["TYPESAFE_API_KEY"] = getpass("TypeSafe API key: ").strip()
>     with TypeSafeClient() as client:
>         response = client.system_one(
>             model=MODEL, state=state,
>             questions={qid: Choice(**spec) for qid, spec in questions.items()},
>         ).model_dump(mode="json")
>     return np.array([[response["answers"][qid]["probabilities"][label]
>                       for label in labels] for qid in questions], dtype=float)
> ```
>
> **Cell 5 (markdown)**
>
> > ## 1. Jev supplies 18 CPT rows
> >
> > Variables are binary (`0 = false`, `1 = true`). Parent assignments are in lexicographic order, with the last parent changing fastest; each GTSAM row is `P(false)/P(true)`.
>
> **Cell 6 (code)**
>
> ```python
> NODES = {
>     'A': ('the patient recently visited Asia', ()),
>     'S': ('the patient is a smoker', ()),
>     'T': ('the patient has tuberculosis', ('A',)),
>     'L': ('the patient has lung cancer', ('S',)),
>     'B': ('the patient has bronchitis', ('S',)),
>     'E': ('the patient has tuberculosis or lung cancer', ('T', 'L')),
>     'X': ("the patient's chest X-ray is abnormal", ('E',)),
>     'D': ('the patient has shortness of breath (dyspnea)', ('E', 'B')),
> }
>
> CPT_STATE = {'task': 'Parameterize a small educational Bayesian network about respiratory disease.',
>  'population': 'Imagine a randomly selected adult patient in a general clinical population. '
>                'Use ordinary real-world medical knowledge, not the memorized textbook '
>                'Asia-network numbers.',
>  'interpretation': 'For each question, return a probability distribution for the child '
>                    'variable under exactly the stated parent assignment. Treat unspecified '
>                    'variables as unknown; do not assume them false.'}
>
> rows = [(child, values) for child, (_, parents) in NODES.items()
>         for values in it.product((0, 1), repeat=len(parents))]
> cpt_questions = {}
> for child, values in rows:
>     meaning, parents = NODES[child]
>     suffix = "_".join(f"{p}{v}" for p, v in zip(parents, values)) or "root"
>     condition = " ".join(
>         f"It is {'true' if v else 'false'} that {NODES[p][0]}."
>         for p, v in zip(parents, values)
>     ) or "No other facts about this randomly selected patient are given."
>     cpt_questions[f"cpt_{child}_{suffix}"] = {
>         "instructions": f"Given the stated condition, which truth value best describes whether {meaning}? "
>                         f"Condition: {condition}",
>         "criteria": {"false": f"It is false that {meaning}.",
>                      "true": f"It is true that {meaning}."},
>     }
>
> # Original Jev probabilities, in the same order as rows.
> recorded_cpts = [
>     [0.96, 0.04],  # A | {}
>     [0.8, 0.2],  # S | {}
>     [0.97, 0.03],  # T | {'A': 0}
>     [0.68, 0.32],  # T | {'A': 1}
>     [0.99, 0.01],  # L | {'S': 0}
>     [0.92, 0.08],  # L | {'S': 1}
>     [0.95, 0.05],  # B | {'S': 0}
>     [0.31, 0.69],  # B | {'S': 1}
>     [0.99, 0.01],  # E | {'T': 0, 'L': 0}
>     [0.0, 1.0],  # E | {'T': 0, 'L': 1}
>     [0.0, 1.0],  # E | {'T': 1, 'L': 0}
>     [0.0, 1.0],  # E | {'T': 1, 'L': 1}
>     [0.89, 0.11],  # X | {'E': 0}
>     [0.01, 0.99],  # X | {'E': 1}
>     [0.93, 0.07],  # D | {'E': 0, 'B': 0}
>     [0.15, 0.85],  # D | {'E': 0, 'B': 1}
>     [0.05, 0.95],  # D | {'E': 1, 'B': 0}
>     [0.03, 0.97],  # D | {'E': 1, 'B': 1}
> ]
> cpt_probabilities = ask(CPT_STATE, cpt_questions, recorded_cpts, ("false", "true"))
> cpt_probabilities /= cpt_probabilities.sum(axis=1, keepdims=True)
> for (child, values), (p0, p1) in zip(rows, cpt_probabilities):
>     print(f"{child} | {str(dict(zip(NODES[child][1], values))):20}  {p0:.2f} / {p1:.2f}")
> ```
>
> **Cell 7 (markdown)**
>
> > ## 2. GTSAM computes the evidence updates
> >
> > Add observations as unary factors, then marginalize. These queries make no Jev calls.
>
> **Cell 8 (code)**
>
> ```python
> keys = {name: (i, 2) for i, name in enumerate(NODES)}
> asia = gtsam.DiscreteBayesNet()
> for child, (_, parents) in NODES.items():
>     table = " ".join(f"{p0:.12g}/{p1:.12g}"
>                      for (name, _), (p0, p1) in zip(rows, cpt_probabilities) if name == child)
>     if parents:
>         parent_keys = gtsam.DiscreteKeys()
>         for parent in parents:
>             parent_keys.push_back(keys[parent])
>         asia.add(keys[child], parent_keys, table)
>     else:
>         asia.add(keys[child], table)
>
>
> def posterior(evidence):
>     factors = gtsam.DiscreteFactorGraph(asia)
>     for name, value in evidence.items():
>         factors.add(keys[name], "0 1" if value else "1 0")
>     marginals = gtsam.DiscreteMarginals(factors)
>     return [marginals.marginalProbabilities(keys[name])[1] for name in ("T", "L", "B")]
>
>
> scenarios = [("No Asia visit", {"A": 0}),
>              ("+ abnormal X-ray", {"A": 0, "X": 1}),
>              ("+ shortness of breath", {"A": 0, "X": 1, "D": 1})]
> evidence_results = np.array([posterior(evidence) for _, evidence in scenarios])
> print(f"{'Observations':25} {'Tuberculosis':>14} {'Lung cancer':>14} {'Bronchitis':>14}")
> for (label, _), probabilities in zip(scenarios, evidence_results):
>     print(f"{label:25}" + "".join(f"{p:14.2%}" for p in probabilities))
> ```
>
> **Cell 9 (markdown)**
>
> > ## 3. Jev proposes structure from variable meanings
> >
> > Use the original shuffled identifiers (`V1`–`V8`), and ask about all 28 pairs. Neither the reference edges nor CPTs are sent. Each answer is `[P(no edge), P(u → v), P(v → u)]`.
>
> **Cell 10 (code)**
>
> ```python
> id_to_variable = dict(zip((f"V{i}" for i in range(1, 9)), "LSABETDX"))
> ids = tuple(id_to_variable)
> pairs = list(it.combinations(ids, 2))
> STRUCTURE_STATE = {'interpretation': 'Consider all listed variables when judging each pair. Prefer direct '
>                    'generative or definitional dependencies. Association through a shared '
>                    'cause or a path through other listed variables alone does not require a '
>                    'direct edge. An observed test result can inform beliefs about a disease '
>                    'without being a generative cause of it. Deterministic definitions can '
>                    'have incoming edges. If neither direct direction belongs in the model, '
>                    'choose no_edge. These questions ask about model structure, not whether a '
>                    'variable is true for a particular patient.',
>  'population': 'Adult patients in a general clinical population; no individual patient '
>                'observations are supplied.',
>  'task': 'Specify direct dependencies in a sparse generative Bayesian network over the listed '
>          'binary variables.'}
> STRUCTURE_STATE["variables"] = [
>     {"id": ident, "meaning": NODES[variable][0]} for ident, variable in id_to_variable.items()
> ]
> structure_questions = {
>     f"pair_{i:02d}": {
>         "instructions": f"Which direct relationship should connect {u} and {v} in the proposed model, "
>                         "accounting for possible mediation by the other listed variables?",
>         "criteria": {
>             "no_edge": f"No direct edge between {u} and {v}; an indirect association may still exist.",
>             "u_to_v": f"A direct edge {u} -> {v}: {u} is a parent of {v}.",
>             "v_to_u": f"A direct edge {v} -> {u}: {v} is a parent of {u}.",
>         },
>     } for i, (u, v) in enumerate(pairs, 1)
> }
> recorded_pairs = [
>     [0.02, 0.0, 0.98],  # pair_01
>     [0.96, 0.0, 0.04],  # pair_02
>     [0.85, 0.14, 0.01],  # pair_03
>     [0.0, 1.0, 0.0],  # pair_04
>     [0.99, 0.0, 0.01],  # pair_05
>     [0.28, 0.72, 0.0],  # pair_06
>     [0.17, 0.83, 0.0],  # pair_07
>     [1.0, 0.0, 0.0],  # pair_08
>     [0.1, 0.9, 0.0],  # pair_09
>     [0.98, 0.02, 0.0],  # pair_10
>     [0.98, 0.02, 0.0],  # pair_11
>     [0.98, 0.02, 0.0],  # pair_12
>     [0.99, 0.01, 0.0],  # pair_13
>     [0.71, 0.29, 0.0],  # pair_14
>     [0.37, 0.63, 0.0],  # pair_15
>     [0.07, 0.93, 0.0],  # pair_16
>     [1.0, 0.0, 0.0],  # pair_17
>     [0.99, 0.01, 0.0],  # pair_18
>     [0.97, 0.01, 0.02],  # pair_19
>     [0.53, 0.0, 0.47],  # pair_20
>     [0.11, 0.89, 0.0],  # pair_21
>     [0.39, 0.61, 0.0],  # pair_22
>     [0.01, 0.0, 0.99],  # pair_23
>     [0.22, 0.78, 0.0],  # pair_24
>     [0.25, 0.75, 0.0],  # pair_25
>     [0.23, 0.77, 0.0],  # pair_26
>     [0.21, 0.79, 0.0],  # pair_27
>     [0.97, 0.01, 0.02],  # pair_28
> ]
> pair_probabilities = ask(STRUCTURE_STATE, structure_questions, recorded_pairs,
>                          ("no_edge", "u_to_v", "v_to_u"))
> pair_probabilities /= pair_probabilities.sum(axis=1, keepdims=True)
> ```
>
> **Cell 11 (markdown)**
>
> > ## 4. Select the graph and compare edges
> >
> > Maximize `sum(log P(pair choice)) − number of edges` (edge penalty **1**), searching all **8! = 40,320** orders to enforce acyclicity. Ties prefer fewer edges, then the first order. The recorded result is **8 correct directions, 3 extra edges, 0 missing**, with **72.7% precision and 100% recall**.
>
> **Cell 12 (code)**
>
> ```python
> EDGE_PENALTY = 1.0
> log_p = np.log(np.maximum(pair_probabilities, 1e-12))
> orders = np.array(list(it.permutations(range(len(ids)))))
> ranks = np.argsort(orders, axis=1)
> pair_indices = np.array(list(it.combinations(range(len(ids)), 2)))
> forward = ranks[:, pair_indices[:, 0]] < ranks[:, pair_indices[:, 1]]
> gain = np.where(forward, log_p[:, 1] - log_p[:, 0], log_p[:, 2] - log_p[:, 0]) - EDGE_PENALTY
> include = gain > 0
> scores = log_p[:, 0].sum() + np.maximum(gain, 0).sum(axis=1)
> best = np.lexsort((np.arange(len(orders)), include.sum(axis=1), -scores))[0]
> recovered = set()
> for j, (u, v) in enumerate(pairs):
>     if include[best, j]:
>         u, v = (u, v) if forward[best, j] else (v, u)
>         recovered.add((id_to_variable[u], id_to_variable[v]))
>
> reference = {(parent, child) for child, (_, parents) in NODES.items() for parent in parents}
> correct = recovered & reference
> extra = recovered - reference
> missing = reference - recovered
> print("Recovered:", ", ".join(f"{u} → {v}" for u, v in sorted(recovered)))
> print(f"Correct directions: {len(correct)}/{len(reference)}; extra: {len(extra)}; missing: {len(missing)}")
> print(f"Precision: {len(correct) / len(recovered):.1%}; recall: {len(correct) / len(reference):.1%}")
> print("Extra edges:", ", ".join(f"{u} → {v}" for u, v in sorted(extra)))
> ```
>
> **Cell 13 (markdown)**
>
> > The graph is the classic [Asia/Chest Clinic benchmark (Lauritzen & Spiegelhalter, 1988)](https://doi.org/10.1111/j.2517-6161.1988.tb01721.x); the probabilities are Jev’s estimates. The edge penalty was selected for the article’s comparison. These are modeling demonstrations, not clinical estimates.
>
> #### Replies (11 fetched, none from the author)
>
> **@sirbayes (Kevin Patrick Murphy)** - Mon Sep 21 13:22:31 +0000 2026 - https://x.com/sirbayes/status/2102025682859794875
>
> > @fdellaert I was planning to try exactly this idea ( with a different PGM backend) but you beat me to it! But thanks for sharing. See also “large language bayes” by @JustinDomke .
>
> **@jatingargiitk (Jatin Garg)** - Mon Sep 21 01:03:15 +0000 2026 - https://x.com/jatingargiitk/status/2101839642844860653
>
> > @fdellaert It can specify the structure if you give it examples and variable names. The harder part is getting it to respect conditional independence without violating d-separation rules.
>
> **@nicklaunchesai (Nick Launches AI Agents)** - Mon Sep 21 12:23:38 +0000 2026 - https://x.com/nicklaunchesai/status/2102010864551465178
>
> > @fdellaert Jev is more classifier than spec, graphs still need a schema
>
> **@malikatifsaleem (Atif Saleem)** - Mon Sep 21 16:09:25 +0000 2026 - https://x.com/malikatifsaleem/status/2102067683923792372
>
> > @fdellaert Can we have graphical workflows with Jev-style decision models, reasoning (+vision for multimodality), and agentic models?
>
> **@jbermudez5 (JB)** - Mon Sep 21 15:40:55 +0000 2026 - https://x.com/jbermudez5/status/2102060514993901885
>
> > @fdellaert There is a great talk on World Models where they touch on this. Its what really sold me on thinking of next action/state prediction.
> >
> > https://t.co/dMPJw0zPVT
>
> **@MichelIvan92347 (Michel aka Agent B)** - Mon Sep 21 13:13:40 +0000 2026 - https://x.com/MichelIvan92347/status/2102023458267746572
>
> > @fdellaert Thanks for sharing Frank. Interesting read and ideas here. Bravo ! 👏
>
> **@avi_research (Avinash Subramanian)** - Mon Sep 21 01:04:58 +0000 2026 - https://x.com/avi_research/status/2101840072114913516
>
> > @fdellaert Wow, very cool connection.
>
> **@Madeactual (Madeactual)** - Mon Sep 21 14:57:36 +0000 2026 - https://x.com/Madeactual/status/2102049610885710324
>
> > @fdellaert Jev is useful here, but not as a reasoning engine. It answers typed noul/choice/score questions over state and returns calibrated probabilities; the graph owns structure. Batch checks, pin jev-1.13.0, and gate low-confidence edges. Bad criteria still produce wrong decisions.
>
> **@Imfulao (Stephen)** - Mon Sep 21 13:49:26 +0000 2026 - https://x.com/Imfulao/status/2102032459282194926
>
> > @fdellaert The Asia-network experiment is a compelling demo — eliciting every CPT row from a single API request shows Jev working as a knowledge front-end for GTSAM. The real test will be unfamiliar networks where memorization can't help.
>
> **@hilbertshelper (DeepClause)** - Mon Sep 21 09:33:08 +0000 2026 - https://x.com/hilbertshelper/status/2101967955924038105
>
> > @fdellaert @NandoDF Possible implications for probabilistic logic programming? https://t.co/8pAlOBGpmo
>
> **@ItsCuthulhu (Cuth)** - Mon Sep 21 03:15:32 +0000 2026 - https://x.com/ItsCuthulhu/status/2101872929730400699
>
> > @fdellaert https://t.co/G1TDtblzpg
> >
> > Many possibilities
> >
> > > QT @ItsCuthulhu:
> > > Article: MetaCog: Increase accuracy without changing speed or cost (~36% improvement)
> > > https://x.com/ItsCuthulhu/status/2101818318219096299
