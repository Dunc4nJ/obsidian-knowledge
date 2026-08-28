---
created: 2026-08-28
description: REI Labs releases Discovery (Beta) for Adapt-1 — removing the authored learner ontology so the feature view itself becomes revisioned running state, formed from the same interaction that drives task learning. Transition projection and structural representation discovery commit inspectable view revisions and rebuild retained events through them. Results: on Symbolic Alchemy, removing nearly the entire authored ontology retains 95.0% of mean return (239 vs 251.6) with zero task-specific pretraining; on CausaLab, removing the complete authored causal projection matches the declared condition exactly on accuracy, all-edge F1, SHD, and runtime.
source: https://reilabs.org/blog/emergence-toward-autonomous-structure-discovery
author: REI Labs
type: article
published: 2026-08-27
tags: [autoresearch, structure-discovery, online-learning, test-time-learning, causal-discovery, representation-learning, ontology, alchemy, adapt-1]
---

## Key Takeaways

- **The move: make the *learner ontology* part of running state, not a precondition.** Most online systems update estimates while the feature view stays fixed — fields, record boundaries, temporal context, and variable roles are all chosen before learning begins. Adapt-1 Discovery folds that view into the transition itself: `(V_{t+1}, S_{t+1}) = F_D(V_t, S_t, e_t)`, where the Domain contract `D` supplies only semantics and constraints, `V_t` holds active paths, representations, temporal contexts, action/intervention roles, causal bindings, and revision identity, and `S_t` is the task state learned *through* that view. The key separation: **view readiness and task competence mature independently** — a projection can become executable before enough compatible evidence exists to predict through it.

*Adapt-1 Preview vs Discovery-enabled differ only in whether the learner ontology is authored before use or formed from interaction:*
![[adapt1-discovery-001.png]]
![[adapt1-discovery-002.png]]

- **Commit-and-rebuild is the mechanism that makes this practical.** Completed events are retained in a bounded buffer while learner admission stays closed (the projection reports `accumulating`). Once retained events support a stable scalar projection, Core commits a **new view revision** and *rebuilds compatible buffered events through it* — so sample count can sit at zero and then jump by more than one on the event that makes the projection ready. "View formation and task learning share one attributed history." This is the same append-only-evidence, swappable-interpretation discipline as [[Sara puts an LLM agent at the center of the Bayesian optimization loop - agentic BO keeps the probabilistic surrogate while letting the agent reconfigure the search mid-run|lenz's raw trial log as single source of truth]] — reconfigure the view, never invalidate the data.

*Events retained while admission is closed; a supported commit creates revision 1 and rebuilds the buffer through it:*
![[adapt1-discovery-003.png]]

- **What gets discovered, and how it's scored: a bounded family evaluated prequentially with a complexity charge.** The candidate set is `R = {current fields} ∪ {typed joint contexts over ≤K paths} ∪ {within-episode lags ≤L}`, with the task contract bounding K and L. Each target-bearing event is scored **prequentially** — the candidate estimate is scored against state accumulated *before* the current outcome is admitted, score recorded first, state updated after. Supported candidates become active; **supported *harmful* candidates become inhibited**; older evidence is discounted as the stream changes; and larger combinations carry an explicit **complexity charge** — a working instance of [[The weakest hypothesis generalizes best - Bennett proves compression is neither necessary nor sufficient and weakness-maximization beats MDL by 1.1-5x|the least-commitment principle]], penalizing over-specific structure rather than over-long description. Temporal candidates stay inside one episode; causal binding discovery follows the same acquisition principle, though "the experiment still determines identifiability and confounding."

*Current fields, bounded joint contexts, and temporal lags scored on pre-update evidence; queries pass readiness, path-coverage, and support gates or return a typed abstention:*
![[adapt1-discovery-004.png]]
![[adapt1-discovery-005.png]]

- **Queries abstain with a typed reason, and every decision is traceable to the exact view that produced it.** Readiness alone does not force a prediction: the query must contain the active path set *and* clear a support threshold, otherwise it returns `⊥_r` — a typed abstention carrying a reason (missing paths, accumulating view, insufficient support). Each decision preserves the active projection revision, learner version, state identity, and evidence identifiers, and frozen evaluation lets a caller withhold writes so held-out scoring doesn't leak into the projection. That combination — abstention-with-reason plus per-decision provenance — is the governance story that makes discovered structure auditable rather than opaque, and it's the same posture the vault's eval cluster argues for in [[deep agent evals need bespoke per-datapoint test logic not uniform evaluators|per-datapoint eval logic]].

- **The results: 95% of authored-ontology return on Alchemy, and an exact match on CausaLab.** On **Symbolic Alchemy** — the sharpest test — Discovery removes potion/cauldron identities, slot semantics, observation decomposition, action-to-state meaning, **42 transition inputs**, causal bindings, six signed-axis effect possibilities, eight objective hypothesis sets, and three chemistry priors, keeping only observation, legal actions, reward, chronology, and episode boundary. Across 25 online episodes it reaches **239 vs 251.6** with the authored ontology — **95.0%** — with zero Alchemy-specific pretraining, while unresolved selections fall from 29.6% (Trial 1) to 1.0% (Trial 5) to **0.24%** (Trials 6-10). The comparison table is admirably honest: external results keep **task exposure and decision-time computation attached** rather than being normalized into one leaderboard (Pinon et al. 251.5 with *one million* 200-step trajectories plus 10,000 tree expansions per decision; symbolic V-MPO 155.4 after *one billion* episodes) — the benchmarking discipline of [[benchmarks are measurement instruments not question collections - regulargio's first-principles guide to claims, graders, coverage, and uncertainty|reporting the conditions with the number]]. On **CausaLab**, removing the complete authored causal projection (5 predictor paths, 6 causal variables, 12 before/after bindings, 1 intervention path) still reaches **identical 0.9400 accuracy, 0.88999 all-edge F1, 2.08 SHD, ~6.51s/model** at reported precision, with binding discovery completing in 22/22 randomized cases. A lovely detail from object-scene grounding: after the identity view commits, **reward matches 42/42 while policy matches only 3/42** — the formed view finds a *different decision path to the same reward*.

*Alchemy ontology removal, the early projection trace committing revision 1, object/scene grounding, and the CausaLab parity result:*
![[adapt1-discovery-006.png]]
![[adapt1-discovery-007.png]]
![[adapt1-discovery-008.png]]
![[adapt1-discovery-009.png]]

- **Where it sits: structure discovery as a substrate property rather than an agent behavior.** The trajectory is explicit — Preview removed task-specific pretraining and the separate training phase; Discovery removes the authored learner ontology; **making Domains optional is next** ("a prompt should be enough to describe the interaction and begin"). Compare the vault's LLM-driven approaches to the same problem: [[Model Discovery Agent couples an LLM proposer with SMC, SBI, and value-of-information to discover mechanistic world models from few experiments|MDA]] expands its hypothesis space via an LLM proposer when a predictive check fails (the 𝓜-open setting), and [[CEDAR runs LLM-driven MCTS with a Judge as fitness function and an Editor as variation operator to design complex systems from natural-language goals|CEDAR]] mutates system structure with an LLM editor under an LLM judge. Adapt-1 does structure discovery with **no LLM in the loop at all** — bounded candidate families, prequential scoring, and commit thresholds — which buys determinism, latency, and provenance at the cost of the open-ended semantic leaps an LLM proposer can make. That contrast is the useful thing to hold: the same problem (the truth isn't in your declared hypothesis space) attacked from the statistical-substrate end rather than the semantic-proposer end, and it extends [[Defining Continual Learning in LLMs requires efficient adaptation under sequential distribution shifts|continual learning]] from parameters to the feature ontology itself.

## External Resources

- Original post: [Emergence: Toward Autonomous Structure Discovery in Adapt-1 — REI Labs, 2026-08-27](https://reilabs.org/blog/emergence-toward-autonomous-structure-discovery)
- Prior Adapt-1 posts: [Adaptive State from Partially Observed Streams](https://reilabs.org/blog/adaptive-state-from-partially-observed-streams) · [Introducing Adapt-1 Preview: A Pretraining-Free Substrate for Test-Time Learning](https://reilabs.org/blog/introducing-adapt-1-preview) · [The Dynamics of Sequential, Transitional and Contextual Online Learning](https://reilabs.org/blog/ADAPT1-BEHAVIORAL-BLOG)
- Benchmarks/baselines cited: [Alchemy (Wang et al., NeurIPS D&B 2021)](https://arxiv.org/abs/2102.02926) · [Pinon et al., model-based meta-RL with transformers and tree search (ESANN 2023)](https://arxiv.org/abs/2208.11535) · [AlKhamissi et al., Symbolic Alchemy abstractions (2021)](https://arxiv.org/abs/2112.08360)

## Original Content

> [!quote]- Full post — "Emergence: Toward Autonomous Structure Discovery in Adapt-1" (REI Labs, 2026-08-27)
> # // Emergence: Toward Autonomous Structure Discovery in Adapt-1
>
> *Adapt-1 Preview and Adapt-1 Preview with Discovery enabled differ only in whether the learner ontology is authored before use or formed from interaction.*
> ![[adapt1-discovery-001.png]]
>
> Discovery stays inside the ongoing Adapt-1 Preview. The condition label records the starting structure: authored ontology in Adapt-1 Preview, unresolved ontology in Adapt-1 Preview (Discovery Enabled).
>
> ## 1\. The learner view
>
> Most online systems can update estimates during operation while the feature view stays fixed. Fields, record boundaries, temporal context, and variable roles are selected before learning begins.
>
> Adapt-1 Preview (Discovery Enabled) makes that learner-facing ontology part of the running state. The notation below formalizes observable API behavior. It leaves the private path-ranking, utility-estimation, and commit algorithms unspecified.
>
> *The declared Domain contract constrains a revisioned learner view. Task state is learned through the active view, and queries use both.*
> ![[adapt1-discovery-002.png]]
>
> The Domain supplies semantics and constraints. Discovery forms the executable learner view. Enabled mechanisms accumulate task state through that view.
>
> Let DD denote the task contract declared through the Domain API, VtV\_t the learner view active at step tt, StS\_t the task state learned through that view, and ete\_t a completed event. The public transition is
>
> (Vt+1,St+1)\=ℱD(Vt,St,et).(V\_{t+1},S\_{t+1})=\\mathcal{F}\_D(V\_t,S\_t,e\_t). 
>
> VtV\_t contains the active paths, representations, temporal contexts, action and intervention roles, causal bindings, lifecycle status, and revision identity. StS\_t contains the task state accumulated through that view.
>
> View readiness and task competence mature separately. A projection can become executable before enough compatible task evidence exists to support a prediction.
>
> Beta exposes two complementary surfaces. Transition projection forms stable scalar inputs and before-and-after bindings. Structural representation discovery evaluates current fields, bounded field combinations, and within-episode lags. Both commit inspectable state.
>
> ## 2\. Commit and rebuild
>
> Automatic transition projection starts with a target and an empty input list. Completed events can be retained while learner admission remains closed. The projection reports `accumulating`, and a successful event write can still report `projection_accumulating`.
>
> Core commits a new view revision after the retained events support a stable and sufficiently available scalar projection. Projection admission establishes an executable record contract. Predictive usefulness is learned after admission.
>
> Bt→supported viewV(k+1)→rebuild{(ΠV(k+1)(xi),yi):ei∈Bt}.B\_t \\xrightarrow{\\text{supported view}} V^{(k+1)} \\xrightarrow{\\text{rebuild}} \\left\\{ \\bigl(\\Pi\_{V^{(k+1)}}(x\_i),y\_i\\bigr) :\\ e\_i\\in B\_t \\right\\}. 
>
> Here, BtB\_t is the bounded retained event buffer and ΠV(k+1)\\Pi\_{V^{(k+1)}} means “read this event through the committed view.” Earlier compatible events are rebuilt through the new revision.
>
> The commit can make several retained events eligible at once. The sample count can remain at zero while the view accumulates, then advance by more than one on the event that makes the projection ready.
>
> | Stage            | Learner-view state                              | Learner admission                  |
> | ---------------- | ----------------------------------------------- | ---------------------------------- |
> | Opening events   | accumulating, no executable paths               | events stored, samples withheld    |
> | Supported commit | ready, schema\_changed: true, revision advances | compatible buffered events rebuilt |
> | Following query  | discovered paths define required context        | prediction or typed abstention     |
>
> *Complete events are retained while projection admission is closed. A supported commit creates revision one and rebuilds buffered events into learner samples.*
> ![[adapt1-discovery-003.png]]
>
> A supported commit changes the executable view and rebuilds compatible retained events through it. The event count is illustrative.
>
> The lifecycle remains online. Interaction supplies evidence for the learner view, the committed view becomes persistent state, and retained interaction is immediately reconsidered through it. View formation and task learning share one attributed history.
>
> ## 3\. Representation evidence
>
> Transition projection decides which scalar paths can form an executable record. Structural representation discovery evaluates a broader bounded family:
>
> ℛ\={xt\[p\]}∪{ϕ(xt\[p1\],…,xt\[pk\]):k≤K}∪{xt−ℓ\[p\]:ℓ≤L}.\\mathcal{R}= \\{x\_t\[p\]\\} \\cup \\{\\phi(x\_t\[p\_1\],\\ldots,x\_t\[p\_k\]) : k\\le K\\} \\cup \\{x\_{t-\\ell}\[p\] : \\ell\\le L\\}. 
>
> The first term contains current fields. The second contains typed joint contexts over at most KK paths. The third contains within-episode lags up to LL steps. The task contract bounds both values. The function ϕ\\phi denotes the typed context formed from a bounded field combination.
>
> Each target-bearing event is evaluated prequentially. The candidate estimate is scored against state accumulated before the current outcome is admitted. The score is recorded first; baseline and candidate state update afterward.
>
> Supported candidates can become active. Supported harmful candidates can become inhibited. Older evidence is discounted as the stream changes, and larger combinations carry a complexity charge. The exact estimator and update remain outside this public formalization.
>
> *Current fields, bounded joint contexts, and temporal lags are scored using pre-update evidence. Their support, utility, interval, and lifecycle state persist.*
> ![[adapt1-discovery-004.png]]
>
> Current, joint, and temporal candidates share one evidence lifecycle. The current outcome changes candidate state only after the pre-update estimate has been scored.
>
> Active representations constrain the structural learner’s feature surface. Hypotheses built through that surface expose conditions, predictions, local support, uncertainty, supporting memory IDs, and counterevidence memory IDs. Representation utility and hypothesis evidence remain separate layers.
>
> Temporal candidates stay inside one episode. A lag connects only records with the same episode identity. Without an episode identifier, the stream is treated as continuous.
>
> Causal binding discovery follows the same acquisition principle. Valid before-and-after intervention records can resolve variable names, before and after locations, and the intervention field. The experiment still determines identifiability and confounding.
>
> ## 4\. Queries
>
> A committed learner view defines the context required by later queries. The public gate is
>
> 𝒬(q;V,S)\={ŷ,ready(V)∧P(V)⊆Paths(q)∧support(S,q)≥smin,⊥r,otherwise.\\mathcal{Q}(q;V,S)= \\begin{cases} \\widehat{y}, & \\operatorname{ready}(V) \\land P(V)\\subseteq\\operatorname{Paths}(q) \\land \\operatorname{support}(S,q)\\ge s\_{\\min},\\\\\[4pt\] \\bot\_r, & \\text{otherwise.} \\end{cases} 
>
> P(V)P(V) is the active path set. ⊥r\\bot\_r is a typed abstention carrying a reason. Readiness alone does not force a prediction. The query must contain the required paths and reach the learner-specific support threshold.
>
> *A query passes readiness, active-path coverage, and support gates before producing a prediction. A failed gate produces a typed abstention with a reason.*
> ![[adapt1-discovery-005.png]]
>
> The active projection governs query context. Missing paths, an accumulating view, or insufficient compatible support remain explicit abstention reasons.
>
> The target stays outside query context. During frozen evaluation, the caller withholds event and feedback writes, freezing the projection and outcome-conditioned state during held-out scoring. Queries still create auditable decision snapshots. Temporal history can advance without admitting held-out outcomes.
>
> Each decision preserves the active projection revision, learner version, state identity, and evidence identifiers. A prediction or abstention can therefore be traced to the exact view used at decision time.
>
> Automatic, explicit, and mixed setup use the same substrate. Automatic setup leaves the learner ontology unresolved. Explicit setup pins it. Mixed setup can retain reviewed base fields while allowing combinations, lags, transition inputs, or causal bindings to form during use.
>
> ## 5\. Symbolic Alchemy
>
> Symbolic Alchemy is the sharpest comparison in this release.[2](#fn2) Both Adapt-1 conditions begin with the public task surface, 40 legal slot actions, source reward, empty learned state, and zero Alchemy-specific pretraining.
>
> Adapt-1 Preview also begins with an authored Alchemy ontology. The Domain supplies potion, cauldron, and no-op identities; stone and potion slot semantics; observation decomposition; action-to-state meaning; 42 transition inputs; causal bindings; six signed-axis effect possibilities; eight objective hypothesis sets; and three chemistry priors.
>
> Adapt-1 Preview (Discovery Enabled) removes that ontology. The task contract retains the observation, legal action set, reward, chronology, and episode boundary. Policy IDs remain opaque.
>
> *Symbolic Alchemy comparison between Adapt-1 Preview and Adapt-1 Preview with Discovery enabled. The Discovery-enabled condition removes policy semantics, transition inputs, signed-axis effect possibilities, objective hypotheses, chemistry priors, and action and observation ontology.*
> ![[adapt1-discovery-006.png]]
>
> This is the broadest ontology removal in the beta. The public task surface and zero-pretraining starting point stay fixed while the authored learner interpretation is removed.
>
> The opening trace shows how quickly the missing view forms. `episode-00-step-000` selects `action_20` while the projection is accumulating at revision 0 with no input paths or causal variables. The next selection still uses revision 0\. Its committed consequence changes the event-side projection to `ready`, advances the revision, and exposes six input paths and 12 causal variables.
>
> ```
> episode-00-step-000 · selection
> policy                 action_20
> projection             accumulating · revision 0
> input_path_count       0
> causal_variable_count  0
> event buffered         1
>
> episode-00-step-001 · event
> projection             ready · revision 1
> input_path_count       6
> causal_variable_count  12
> intervention_path      values.intervention.target
> schema_changed         true
>
> episode-00-step-002 · selection
> policy                 action_03
> projection             ready · revision 1
> input_path_count       6
> causal_variable_count  12
> ```
>
> *Early Symbolic Alchemy trace. The first two selections use revision zero with no discovered inputs. The second consequence commits revision one with six inputs and twelve causal variables, and the third selection uses it.*
> ![[adapt1-discovery-007.png]]
>
> The event at `episode-00-step-001` creates revision 1\. `episode-00-step-002` is the first selection in the excerpt that reads the formed projection.
>
> The opaque action IDs in the excerpt are `action_20`, `action_06`, and `action_03`. Selection provenance records Core exploration and `factorized_effect_belief`. The Domain does not name them as potion-on-stone operations.
>
> Revision 1 is only the learner view. Chemistry learning continues through that view. Unresolved selections fall from 148 of 500 decisions in Trial 1 (29.6%) to 5 of 500 in Trial 5 (1.0%), then to 6 of 2,500 across Trials 6–10 (0.24%). These counts measure unresolved selections rather than task errors.
>
> Across 25 online episodes, Adapt-1 Preview (Discovery Enabled) reaches 239\. Adapt-1 Preview reaches 251.6 with the authored ontology. The Discovery-enabled condition retains 95.0% of that mean return after removing the learner interpretation supplied before use.
>
> 239 / 251.6 = 0.950
>
> | Condition                           | Preparation and evaluation context                                                                                                     | Reported score |
> | ----------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------- | -------------- |
> | Adapt-1 Preview (Discovery Enabled) | Zero Alchemy-specific pretraining; empty learned state; authored learner ontology removed; view forms during the 25-episode online run | 239            |
> | Adapt-1 Preview                     | Zero Alchemy-specific pretraining; empty learned state; authored Alchemy learner ontology and projection                               | 251.6          |
> | Pinon et al.[3](#fn3)               | One million 200-step training trajectories; learned-model search with 10,000 tree expansions per decision                              | 251.5 ± 4.5    |
> | AlKhamissi et al.[4](#fn4)          | Modified state, action, and memory representations; no added reward penalties in the cited condition                                   | 236.06 ± 2.18  |
> | Symbolic V-MPO                      | One billion training episodes; evaluation without weight updates on 1,000 test episodes                                                | 155.4 ± 1.6    |
>
> The external rows keep task exposure and decision-time computation attached to the score. They are not normalized into one leaderboard. Within the displayed values, the Discovery-enabled run sits above the cited no-penalty representation-shaped result and symbolic V-MPO, and below the trained-model search condition and the earlier Adapt-1 Preview run.
>
> Preview established the zero-pretraining result. Discovery changes the structure present at that starting point. In Alchemy, nearly the entire authored learner ontology now forms from the interaction that also drives task learning.
>
> ## 6\. Object and scene grounding
>
> A narrower object-and-scene grounding behavior tests identity formation without the larger Alchemy ontology. In Adapt-1 Preview, `values.entity_key` and `values.scene_key` are chosen in advance. With Discovery enabled, the object view begins empty.
>
> Object and scene grounding · absent before interaction
>
> Object input view
>
> `[]`
>
> Entity identity
>
> `values.entity_key` is not preselected.
>
> Scene identity
>
> `values.scene_key` is not preselected.
>
> The opening item supplies two grounding samples. Core commits both fields before the following query, which becomes the first selection able to use the formed identity view.
>
> *Object and scene grounding behavior. Two grounding samples support entity and scene identity fields before the next query.*
> ![[adapt1-discovery-008.png]]
>
> The object view forms from feedback. The following query can use `values.entity_key` and `values.scene_key` without either field being preselected.
>
> Adapt-1 Preview (Discovery Enabled) remains in the same task-balanced utility band: 0.486–0.491 versus 0.479 in Adapt-1 Preview. Across the final 42 exploit decisions, reward matches on 42 of 42 while policy matches on 3 of 42.
>
> The first policy divergence begins after the identity view commits. The formed view supports a different decision path while preserving the final reward sequence in this comparison.
>
> ## 7\. CausaLab
>
> CausaLab removes the complete authored causal projection. Adapt-1 Preview supplies five predictor paths, six causal variables, 12 before-and-after bindings, and one intervention path. Adapt-1 Preview (Discovery Enabled) begins with each field absent.
>
> CausaLab · absent before interaction
>
> Transition input paths
>
> `[]` · five authored paths removed.
>
> Causal variables
>
> `[]` · six authored variable declarations removed.
>
> Before / after bindings
>
> `[]` · 12 authored bindings removed.
>
> Intervention path
>
> `""` · the authored intervention binding removed.
>
> Hypotheses
>
> None supplied.
>
> Answer labels
>
> None supplied.
>
> Feature selection, causal-variable selection, intervention-field identification, and transition pairing become acquisition problems inside the run. Revision 1 commits between events 22 and 23 with five predictor paths, six causal variables, 12 bindings, and the intervention path used by the causal learner.
>
> *CausaLab moves from collecting at event 22 to ready at event 23. The declared and Discovery-enabled conditions match on task accuracy, all-edge F1, structural Hamming distance, and runtime at the reported precision.*
> ![[adapt1-discovery-009.png]]
>
> Across 50 fresh six-node structural causal models, both conditions reach 0.9400 task accuracy, 0.88999 all-edge F1, 2.08 structural Hamming distance, and approximately 6.51 seconds per model. Equality is reported at the displayed precision.
>
> A separate randomized check completes binding discovery in 22 of 22 cases and recovers every causal variable. Across the 50-model benchmark, the Discovery-enabled condition produces 31 distinct input-path sets. The randomized check and the benchmark are separate evaluations.
>
> This ablation isolates the removed declaration. Graph recovery and runtime remain unchanged at the reported precision after the causal learner view moves from pre-run configuration into revisioned state.
>
> ## 8\. Next steps
>
> Adapt-1 Preview removed task-specific pretraining and the separate training phase from the starting condition. Discovery (Beta) removes the authored learner ontology. Discovery already moves input paths, representations, field combinations, temporal lags, action and intervention roles, transition bindings, causal variables, and task hypotheses into the running instance.
>
> The system still receives a simple task contract: the interaction surface, legal choices, learnable outcome, chronology, and episode boundary. Everything else shown in this article can begin unresolved and become persistent state during use.
>
> **The goal is to make test-time learning practical under real system constraints.** Learning should begin from the interaction already required to perform the task, remain queryable throughout that process, and preserve the performance, latency, provenance, inspectability, and control expected from a prepared system.
>
> Making Domains optional is next. A prompt should be enough to describe the interaction and begin. Adapt-1 will form the task contract and initial learner view from that description, then refine them from live evidence. Explicit Domains will remain available when a team wants to inspect, pin, reproduce, or govern the resulting specification.
>
> Discovery already removes a large amount of integration work. Prompted setup removes the remaining authoring requirement. The direction is toward no task-specific pretraining, no authored learner ontology, and eventually no required Domain before online learning starts.
