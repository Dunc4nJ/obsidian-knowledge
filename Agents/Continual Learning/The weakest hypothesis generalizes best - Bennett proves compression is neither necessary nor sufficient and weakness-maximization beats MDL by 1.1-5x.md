---
created: 2026-08-05
description: Michael Timothy Bennett (ANU) proves — within a lattice formalism of enactive cognition, under uniformly distributed tasks — that the hypothesis most likely to generalize is the WEAKEST one consistent with the data (largest extension), not the shortest: compression/MDL is neither necessary nor sufficient, and weakness-maximization generalized 1.1-5x better than minimum description length in binary-arithmetic experiments. Surfaced via Erik Meijer's tip to feed it to any agent self-improvement loop, where it operationalizes as: write the weakest lesson consistent with all observed failures.
source: https://arxiv.org/abs/2301.12987
type: paper
authors:
  - Michael Timothy Bennett
arxiv: "2301.12987"
via: https://x.com/headinthebox/status/2084414685701632406
tags: [generalization, induction, occams-razor, mdl, hypothesis-selection, continual-learning, self-improvement, agi-theory]
---

## Key Takeaways

- **The claim: to generalize, pick the *weakest* consistent hypothesis, not the shortest.** Given data A ⊂ B, many hypotheses fit A but only some construct B. The Occam/MDL/Solomonoff tradition picks the shortest program — equating compression with intelligence (the foundation of AIXI). Bennett defines **weakness** as the size of a hypothesis's *extension* (how many statements/situations it remains consistent with) and proves, within his formalism, that weakness-maximization is **necessary and sufficient** to maximize the probability of generalizing — while "compression is neither necessary nor sufficient to maximise performance." The empirical toy: on 8-bit binary arithmetic tasks, maximum-weakness selection generalized at **1.1–5x the rate** of minimum-description-length selection, which he argues also explains why DeepMind's Apperception Engine generalizes well (its hand-tuned inductive bias approximates weakness, not brevity).

- **The conceptual contribution survives the formalism: semantics over syntax.** Description length is representation-relative — change the language/UTM and what counts as "short" changes — while extension size is *semantic*, independent of encoding. Weakness is "least commitment" made rigorous: presume as little as possible beyond the evidence; keep the hypothesis consistent with the largest space of futures. Where a short hypothesis may bind incidental structure of the observations into its program, the weakest hypothesis constrains only what the data actually forces.

- **The fine print that carries the proof — read before adopting wholesale.** (1) The optimality result assumes **tasks are uniformly distributed**; real-world task distributions are decidedly non-uniform (the world has compressible structure — which is precisely the classical argument *for* simplicity priors), so in practice some weak-and-simple blend likely wins, and the paper doesn't give the mix. (2) Weakness is **intractable at scale** — extension sizes are enumerable in the paper's finite lattice world, not over an LLM's hypothesis space, where "weaker" can only be approximated as "less specific." (3) The whole result lives inside an idiosyncratic enactive-cognition lattice formalism (built partly to counter AIXI's subjectivity problems) — the proof is real, but its transfer to messy practice is an analogy, not a theorem.

- **Why it's in this folder — Erik Meijer's framing: give your self-improvement loop a selection principle.** Meijer's viral tip ("show this paper to the model and ask it to incorporate it") lands because most improvement loops — [[Grey Haven autocontext runs five-role recursive improvement loops with persistent playbooks and traces that next runs inherit|recursive playbook loops]], [[MemSkill - Learning and Evolving Memory Skills for Self-Evolving Agents|self-evolving memory skills]], [[Self-Harness lets a fixed LLM rewrite its own agent harness from clustered failure traces, lifting Terminal-Bench held-out pass rates up to 21 points|harness self-rewriting]], [[Bridgewater's PAT treats agentic codegen as a compiler problem, turning 50 years of written-down investment logic into a deterministic AI analyst with a benchmark-gated Teach loop|PAT's Teach button]], or [[the agent improvement loop is traces enriched with evals and human feedback converted into validated fixes|the generic traces→fixes loop]] — contain a **hypothesis-selection step**: from this failure, which lesson do I write down? The paper's payload for that step is one sentence: **"write the weakest rule consistent with all observed failures — never more specific than the evidence demands."** You don't need the lattice formalism; you need that sentence in the lesson-induction prompt.

- **The vault already documents the failure mode weakness-maximization prevents — from three independent directions.** Over-specific induced rules are why [[most popular CLAUDE.md files add noise not signal with a 556 to 1 copy-to-contribution ratio|CLAUDE.md files add noise not signal]], why [[repository-level context files reduce coding agent task success and increase inference costs by over 20 percent|repo context files reduce task success]], and why [[static agent skills rot silently because the codebase model and task distribution change around them|static skills rot silently]] — each is a lesson-writing process that overfit its incidents, binding constraints the evidence never demanded. Weak rules also age better (fewer constraints to invalidate as the environment shifts) and spend less instruction budget. The strongest existing practice of the principle is [[HALO uses an RLM to mine harness-shaped failures from agent execution traces and lift benchmarks 10-16 percentage points|HALO's failure-mining]], which clusters *many* traces before inducing a fix — aggregation being one honest way to approximate "consistent with all observed failures" — and the compounding goal is exactly that of [[learning machines turn agents from stateless tools into systems that compound knowledge across users and sessions]].

## External Resources

- Paper: [The Optimal Choice of Hypothesis Is the Weakest, Not the Shortest (arXiv 2301.12987v4)](https://arxiv.org/abs/2301.12987) — Michael Timothy Bennett (ANU); [appendices on GitHub](https://github.com/ViscousLemming/Technical-Appendices) · [author site](http://www.michaeltimothybennett.com/)
- Discovery source: [Erik Meijer (@headinthebox), 2026-08-03](https://x.com/headinthebox/status/2084414685701632406) — "if you have any kind of self improvement loop, show this paper to the model and ask it to incorporate it."
- Context: [AIXI](https://en.wikipedia.org/wiki/AIXI) (compression-as-intelligence tradition this argues against) · DeepMind's Apperception Engine (Evans et al.) — the system whose generalization the paper reinterprets · [Grokking (Power et al. 2022)](https://arxiv.org/abs/2201.02177) — cited alongside in the delayed-generalization discussion

## Original Content

> [!quote]- Full paper text (The Optimal Choice of Hypothesis Is the Weakest, Not the Shortest — arXiv 2301.12987v4, Michael Timothy Bennett, ANU)
> ## The Optimal Choice of Hypothesis Is the Weakest, Not the Shortest
>
> Michael Timothy Bennett 1
>
> [0000 -0001 -6895 -8782]
>
> The Australian National University michael.bennett@anu.edu.au http://www.michaeltimothybennett.com/
>
> Abstract. If A and B are sets such that A ⊂ B , generalisation may be understood as the inference from A of a hypothesis sufficient to construct B . One might infer any number of hypotheses from A , yet only some of those may generalise to B . How can one know which are likely to generalise? One strategy is to choose the shortest, equating the ability to compress information with the ability to generalise (a 'proxy for intelligence'). We examine this in the context of a mathematical formalism of enactive cognition. We show that compression is neither necessary nor sufficient to maximise performance (measured in terms of the probability of a hypothesis generalising). We formulate a proxy unrelated to length or simplicity, called weakness. We show that if tasks are uniformly distributed, then there is no choice of proxy that performs at least as well as weakness maximisation in all tasks while performing strictly better in at least one. In experiments comparing maximum weakness and minimum description length in the context of binary arithmetic, the former generalised at between 1 . 1 and 5 times the rate of the latter. We argue this demonstrates that weakness is a far better proxy, and explains why Deepmind's Apperception Engine is able to generalise effectively 1 .
>
> Keywords:
>
> simplicity · induction · artificial general intelligence.
>
> ## 1 Introduction
>
> If A and B are sets such that A ⊂ B , generalisation may be understood as the inference from A of a hypothesis sufficient to construct B . One might infer any number of hypotheses from A , yet only some of those may generalise to B . How can one know which are likely to generalise? According to Ockham's Razor, the simpler of two explanations is the more likely [2]. Simplicity is not itself a measurable property, so the minimum description length principle [3] relates simplicity to length. Shorter representations are considered to be simpler, and tend to generalise more effectively. This is often applied in the context of induction by comparing the length of programs that explain what is observed (to chose the shortest, all else being equal). The ability to identify shorter representations
>
> 1 Appendices are to be found on GitHub [1].
>
> is compression, and the ability to generalise is arguably intelligence [4]. Hence the ability to compress information is often portrayed as a proxy for intelligence [5], even serving as the foundation [6, 7, 8] of the theoretical super-intelligence AIXI [9]. That compression is a good proxy seems to have gone unchallenged. The optimal choice of hypothesis is widely considered to be the shortest. We show that it is not 2 . We present an alternative, unrelated to description length, called weakness. We prove that to maximise the probability that one's hypotheses generalise, it is necessary and sufficient to infer the weakest valid hypotheses possible 3 .
>
> ## 2 Background definitions
>
> To do so, we employ a formalism of enactive cognition [10, 11, 12, 13, 14, 1], in which sets of declarative programs are related to one another in such a way as to form a lattice. This unusual representation is necessary to ensure that both the weakness and description length of a hypothesis are well defined 4 . This formalism can be understood in three steps.
>
> 1. The environment is represented as a set of declarative programs.
> 2. A finite subset of the environment is used to define a language with which to write statements that behave as logical formulae.
> 3. Finally, induction is formalised in terms of tasks made up of these statements.
>
> ## Definition 1 (environment).
>
> - -We assume a set Φ whose elements we call states , one of which we single out as the present state 5 .
> - -A declarative program is a function f : Φ →{ true, false } , and we write P for the set of all declarative programs. By an objective truth about a state φ , we mean a declarative program f such that f ( φ ) = true .
>
> ## Definition 2 (implementable language).
>
> - -V = { V ⊂ P : V is finite } is a set whose elements we call vocabularies , one of which we single out as the vocabulary v for an implementable language.
>
> 2 This proof is conditional upon certain assumptions regarding the nature of cognition as enactive, and a formalism thereof.
>
> 3 Assuming tasks are uniformly distributed, and weakness is well defined.
>
> - 4 An example of how one might translate propositional logic into this representation is given at the end of this paper. It is worth noting that this representation of logical formulae addresses the symbol grounding problem [15], and was specifically constructed to address subjective performance claims in the context of AIXI [16].
>
> 5 Each state is just reality from the perspective of a point along one or more dimensions. States of reality must be separated by something, or there would be only one state of reality. For example two different states of reality may be reality from the perspective of two different points in time, or in space and so on.
>
> - -L v = { l ⊆ v : ∃ φ ∈ Φ ( ∀ p ∈ l : p ( φ ) = true ) } is a set whose elements we call statements 6 . L v follows from Φ and v . We call L v an implementable language .
> - -l ∈ L v is true iff the present state is φ and ∀ p ∈ l : p ( φ ) = true .
> - -The extension of a statement a ∈ L v is Z a = { b ∈ L v : a ⊆ b } .
> - -The extension of a set of statements A ⊆ L v is Z A = ⋃ a ∈ A Z a .
>
> (Notation) Z with a subscript is the extension of the subscript 7 . Lower case letters represent statements, and upper case represent sets of statements.
>
> Definition 3 ( v -task). For a chosen v , a task α is 〈 S α , D α , M α 〉 where:
>
> - -S α ⊂ L v is a set whose elements we call situations of α .
> - -S α has the extension Z S α , whose elements we call decisions of α .
> - -D α = { z ∈ Z S α : z is correct } is the set of all decisions which complete α .
> - -M α = { l ∈ L v : Z S α ∩ Z l = D α } whose elements we call models of α .
>
> Γ v is the set of all tasks 8 .
>
> (Notation) If ω ∈ Γ v , then we will use subscript ω to signify parts of ω , meaning one should assume ω = 〈 S ω , D ω , M ω 〉 even if that isn't written.
>
> (How a task is completed) Assume we've a v -task ω and a hypothesis h ∈ L v s.t.
>
> 1. we are presented with a situation s ∈ S ω , and
> 2. we must select a decision z ∈ Z s ∩ Z h .
> 3. If z ∈ D ω , then z is correct and the task is complete. This occurs if h ∈ M ω .
>
> ## 3 Formalising induction
>
> Definition 4 (probability). We assume a uniform distribution over Γ v .
>
> Definition 5 (generalisation). A statement l generalises to α ∈ Γ v iff l ∈ M α . We say l generalises from α to v -task ω if we first obtain l from M α and then find it generalises to ω .
>
> Definition 6 (child and parent). A v -task α is a child of v -task ω if S α ⊂ S ω and D α ⊆ D ω . This is written as α /squareimage ω . If α /squareimage ω then ω is then a parent of α .
>
> A proxy is meant to estimate one thing by measuring another. In this case, if intelligence is the ability to generalise [10, 4], then a greater proxy value is meant to indicate that a statement is more likely to generalise. Not all proxies are effective (most will be useless). We focus on two in particular.
>
> 6 Statements are the logical formulae about which we will reason.
>
> 7 e.g. Z s is the extension of s .
>
> 8 For example, we might represent chess as a supervised learning problem where s ∈ S α is the state of a chessboard, z ∈ Z s is a sequence of moves by two players that begins in s , and d ∈ D α ∩ Z s is such a sequence of moves that terminates in victory for one player in particular (the one undertaking the task).
>
> Definition 7 (proxy for intelligence). A proxy is a function parameterized by a choice of v such that q v : L v → N . The set of all proxies is Q .
>
> (Weakness) The weakness of a statement l is the cardinality of its extension | Z l | . There exists q v ∈ Q such that q v ( l ) = | Z l | .
>
> (Description length) The description length of a statement l is its cardinality | l | . Longer logical formulae are considered less likely to generalise [3], and a proxy is something to be maximised, so description length as a proxy is q v ∈ Q such that q v ( l ) = 1 | l | .
>
> A child task may serve as an ostensive definition [17] of its parent, meaning one can generalise from child to parent.
>
> Definition 8 (induction). α and ω are v -tasks such that α /squareimage ω . Assume we are given a proxy q v ∈ Q , the complete definition of α and the knowledge that α /squareimage ω . We are not given the definition of ω . The process of induction would proceed as follows:
>
> 1. Obtain a hypothesis by computing a model h ∈ arg max q v ( m ) .
>
> m ∈ M α
>
> 2. If h ∈ M ω , then we have generalised from α to ω .
>
> ## 4 Proofs
>
> Proposition 1 (sufficiency). Weakness is a proxy sufficient to maximise the probability that induction generalises from α to ω .
>
> Proof: You're given the definition of v -task α from which you infer a hypothesis h ∈ M α . v -task ω is a parent of α to which we wish to generalise:
>
> 1. The set of statements which might be decisions addressing situations in S ω and not S α , is Z S α = { l ∈ L v : l / ∈ Z S α } .
> 2. For any given h ∈ M α , the extension Z h of h is the set of decisions h implies. The subset of Z h which fall outside the scope of what is required for the known task α is Z S α ∩ Z h (because Z S α is the set of all decisions we might make when attempting α , and so the set of all decisions that can't be made when undertaking α is Z S α because those decisions occur in situations that aren't part of S α ).
> 3. | Z S α ∩ Z h | increases monotonically with | Z h | , because ∀ z ∈ Z m : z / ∈ Z S α → z ∈ Z S α .
> 4. 2 | Z Sα | is the number of tasks which fall outside of what it is necessary for a model of α to generalise to (this is just the powerset of Z S α defined in step 2), and 2 | Z Sα ∩ Z h | is the number of those tasks to which a given h ∈ M α does generalise.
>
> 5. Therefore the probability that a given model h ∈ M α generalises to the unknown parent task ω is
>
> $$p ( h \in M _ { \omega } \, | \, h \in M _ { \alpha } , \alpha \, [ \, \omega \, ) = \frac { 2 ^ { | \overline { Z } _ { S _ { \alpha } } \cap Z _ { h } | } } { 2 ^ { | \overline { Z } _ { S _ { \alpha } } | } }$$
>
> p ( h ∈ M ω | h ∈ M α , α /squareimage ω ) is maximised when | Z h | is maximised.
>
> Proposition 2 (necessity). To maximise the probability that induction generalises from α to ω , it is necessary to use weakness as a proxy, or a function thereof 9 .
>
> Proof: Let α and ω be defined exactly as they were in the proof of prop. 1.
>
> 1. If h ∈ M α and Z S ω ∩ Z h = D ω , then it must be he case that D ω ⊆ Z h .
> 2. If | Z h | &lt; | D ω | then generalisation cannot occur, because that would mean that D ω /negationslash⊆ Z h .
> 3. Therefore generalisation is only possible if | Z m | ≥ | D ω | , meaning a sufficiently weak hypothesis is necessary to generalise from child to parent.
> 4. The probability that | Z m | ≥ | D ω | is maximised when | Z m | is maximised. Therefore to maximise the probability induction results in generalisation, it is necessary to select the weakest hypothesis.
>
> To select the weakest hypothesis, it is necessary to use weakness (or a function thereof) as a proxy.
>
> Remark 1 (prior). The above describes inference from a child to a parent. However, it follows that increasing the weakness of a statement increases the probability that it will generalise to any task (not just a parent of some given child). As tasks are uniformly distributed, every statement in L v is a model to one or more tasks, and the number of tasks to which each statement l ∈ L v generalises is 2 | Z l | . Hence the probability of generalisation 10 to ω is p ( h ∈ M ω | h ∈ L v ) = 2 | Z h | 2 | L v | . This assigns a probability to every statement l ∈ L v given an implementable language. It is a probability distribution in the sense that the probability of mutually exclusive statements sums to one 11 . This prior may be considered universal in the very limited sense that it assigns a probability to every conceivable hypothesis (where what is conceivable depends upon the implementable language) absent any parameters or specific assumptions about the task as with AIXI's intelligence order relation [9, def. 5.14 pp. 147] 12 . As the vocabulary v is finite, L v must also be finite, and so p is computable.
>
> 9 For example we might use weakness multiplied by a constant to the same effect.
>
> 10 2 | Z h | 2 | L v | is maximised when h = ∅ , because the optimal hypothesis given no information is to assume nothing (you've no sequence to predict, so why make assertions that might contradict the environment?).
>
> 11 Two statements a and b are mutually exclusive if a /negationslash∈ Z b and b /negationslash∈ Z a , which we'll write as µ ( a, b ) . Given x ∈ L v , the set of all mutually exclusive statements is a set K x ⊂ L v such that x ∈ K x and ∀ a, b ∈ K x : µ ( a, b ) . It follows that ∀ x ∈ L v , ∑ p ( b ) = 1 .
>
> b
>
> ∈
>
> K
>
> x
>
> 12 We acknowledge that some may object to the term universal, because v is finite.
>
> We have shown that, if tasks are uniformly distributed, then weakness is a necessary and sufficient proxy to maximise the probability that induction generalises. It is important to note that another proxy may perform better given cherrypicked combinations of child and parent task for which that proxy is suitable. However, such a proxy would necessarily perform worse given the uniform distribution of all tasks. Can the same be said of description length?
>
> Proposition 3. Description length is neither a necessary nor sufficient proxy for the purposes of maximising the probability that induction generalises.
>
> Proof: In propositions 1 and 2 we proved that weakness is a necessary and sufficient choice of proxy to maximise the probability of generalisation. It follows that either maximising 1 | m | (minimising description length) maximises | Z m | (weakness), or minimisation of description length is unnecessary to maximise the probability of generalisation. Assume the former, and we'll construct a counterexample with v = { a, b, c, d, e, f, g, h, j, k, z } s.t. L v = {{ a, b, c, d, j, k, z } , { e, b, c, d, k } , { a, f, c, d, j } , { e, b, g, d, j, k, z } , { a, f, c, h, j, k } , { e, f, g, h, j, k }} and a task α where
>
> - -S α = {{ a, b } , { e, b
> - -D α = {{ a, b, c, d, j, k, z } , { e, b, g, d, j, k, z }}
> - -M α = {{ z } , { j, k
>
> ```
> }} }}
> ```
>
> Weakness as a proxy selects { j, k } , while description length as a proxy selects { z } . This demonstrates the minimising description length does not necessarily maximise weakness, and maximising weakness does not minimise description length. As weakness is necessary and sufficient to maximise the probability of generalisation, it follows that minimising description length is neither.
>
> ## 5 Experiments
>
> Included with this paper is a Python script to perform two experiments using PyTorch with CUDA, SymPy and A ∗ [18, 19, 20, 21] (see technical appendix for details). In these two experiments, a toy program computes models to 8bit string prediction tasks (binary addition and multiplication). The purpose of these experiments was to compare weakness and description length as proxies.
>
> ## 5.1 Setup
>
> To specify tasks with which the experiments would be conducted, we needed a vocabulary v with which to describe simple 8-bit string prediction problems. There were 256 states in Φ , one for every possible 8-bit string. The possible statements were then all the expressions regarding those 8 bits that could be written in propositional logic (the simple connectives ¬ , ∧ and ∨ needed to perform binary arithmetic - a written example of how propositional logic can be used in to specify v is also included in the appendix). In other words, for each statement in L v there existed an equivalent expression in propositional logic.
>
> For efficiency, these statements were implemented as either PyTorch tensors or SymPy expressions in different parts of the program, and converted back and forth as needed (basic set and logical operations on these propositional tensor representations were implemented for the same reason). A v -task was specified by choosing D n ⊂ L v such that all d ∈ D n conformed to the rules of either binary addition or multiplication with 4-bits of input, followed by 4-bits of output.
>
> ## 5.2 Trials
>
> Each experiment had parameters were 'operation' and 'number\_of\_trials'. For each trial the number | D k | of examples ranged from 4 to 14 . A trial had 2 phases.
>
> ## Training phase:
>
> 1. A task n (referred to in code as T n ) was generated:
> 2. (a) First, every possible 4-bit input for the chosen binary operation was used to generate an 8-bit string. These 16 strings then formed D n .
> 3. (b) A bit between 0 and 7 was then chosen, and S n created by cloning D n and deleting the chosen bit from every string ( S n contained 16 different 7-bit strings, each of which was a sub-string of an element of D n ).
> 2. A child-task k = 〈 S k , D k , M k 〉 (referred to in code as T k ) was sampled (assuming a uniform distribution over children) from the parent task T n . Recall, | D k | was determined as a parameter of the trial.
> 3. From T k two models were then generated; a weakest c w , and a MDL c mdl .
>
> Testing phase: For each model c ∈ { c w , c mdl } , the testing phase was as follows:
>
> 1. The extension Z c of c was then generated.
> 2. A prediction D recon was made s.t. D recon = { z ∈ Z c : ∃ s ∈ S n ( s ⊂ z ) } .
> 3. D recon was then compared to the ground truth D n , and results recorded.
>
> Between 75 and 256 trials were run for each value of the parameter | D k | . Fewer trials were run for larger values of | D k | as these took longer to process. The results of these trails were then averaged for each value of | D k | .
>
> ## 5.3 Results
>
> /negationslash
>
> Two sorts of measurements were taken for each trial. The first was the rate at generalisation occurred . Generalisation was deemed to have occurred where D recon = D n . The number of trials in which generalisation occurred was measured, and divided by n to obtain the rate of generalisation for c w and c mdl . Error was computed as a Wald 95 % confidence interval. The second measurement was the average extent to which models generalised . Even where D recon = D n , the extent to which models generalised could be ascertained. | D recon ∩ D n | | D n | was measured and averaged for each value of | D k | , and the standard error computed. The results (see tables 1 and 2) demonstrate that weakness is a better proxy for intelligence than description length. The generalisation rate for c w was between 110 -500% of c mdl , and the extent was between 103 -156% .
>
> Table 1. Results for Binary Addition
>
> |            | c w         | c w   |        | c      | mdl   | mdl   |        |        |
> |------------|-------------|-------|--------|--------|-------|-------|--------|--------|
> | &#124; D k | &#124; Rate | ± 95% | AvgExt | StdErr | Rate  | ± 95% | AvgExt | StdErr |
> | 6          | .11         | .039  | .75    | .008   | .10   | .037  | .48    | .012   |
> | 10         | .27         | .064  | .91    | .006   | .13   | .048  | .69    | .009   |
> | 14         | .68         | .106  | .98    | .005   | .24   | .097  | .91    | .006   |
>
> Table 2. Results for Binary Multiplication
>
> |            | c w           | c w   |        | c      | mdl   | mdl   |        |        |
> |------------|---------------|-------|--------|--------|-------|-------|--------|--------|
> | &#124; D k | &#124; Rate ± | 95%   | AvgExt | StdErr | Rate  | ± 95% | AvgExt | StdErr |
> | 6          | .05           | .026  | .74    | .009   | .01   | .011  | .58    | .011   |
> | 10         | .16           | .045  | .86    | .006   | .08   | .034  | .78    | .008   |
> | 14         | .46           | .061  | .96    | .003   | .21   | .050  | .93    | .003   |
>
> ## 6 Concluding remarks
>
> We have shown that, if tasks are uniformly distributed, then weakness maximisation is necessary and sufficient to maximise the probability that induction will produce a hypothesis that generalises. It follows that there is no choice of proxy that performs at least as well as weakness maximisation across all possible combinations of child and parent task while performing strictly better in at least one. We've also shown that the minimisation of description length is neither necessary nor sufficient. This calls into question the relationship between compression and intelligence [5, 22, 23], at least in the context of enactive cognition. This is supported by our experimental results, which demonstrate that weakness is a far better predictor of whether a hypothesis will generalise, than description length. Weakness should not be conflated with Ockham's Razor. A simple statement need not be weak, for example 'all things are blue crabs'. Likewise, a complex utterance can assert nothing. Weakness is a consequence of extension, not form. If weakness is to be understood as an epistemological razor, it is this (which we humbly suggest naming 'Bennett's Razor'):
>
> Explanations should be no more specific than necessary. 13
>
> The Apperception Engine: The Apperception Engine [24, 25, 26] (Evans et. al. of Deepmind) is an inference engine that generates hypotheses that generalise often. To achieve this, Evans formalised Kant's philosophy to give the engine a
>
> 13 We do not know which possibilities will eventuate. A less specific statement contradicts fewer possibilities. Of all hypotheses sufficient to explain what we perceive, the least specific is most likely.
>
> 'strong inductive bias'. The engine forms hypotheses from only very general assertions, meaning logical formulae which are universally quantified. That is possible because the engine uses language specifically tailored to efficiently represent the sort of sequences to which it is applied. Our results suggest a simpler and more general explanation of why the engine's hypotheses generalise so well. The tailoring of logical formulae to represent certain sequences amounts to a choice of v , and the use of only universally quantified logical formulae ensures the resulting hypothesis is weak. Obviously this can work well, but only for the subset of possible tasks that the vocabulary is able to describe in this way (anything else will not be able to be represented as a universally quantified rule, and so will not be represented at all [27]). This illustrates how future research may explore choices of v in aid of more efficient induction in particular sorts of task, such as the inference of linguistic meaning and intent (see appendix).
>
> Neural networks: How might a task be represented in the context of a function? Though we use continuous real values in base 10 to formalise neural networks, all computation still takes place in a discrete, finite and binary system. A finite number of imperative programs composed a finite number of times may be represented by a finite set of declarative programs. Likewise, activations within a network given an input can be represented as a finite set of declarative programs, expressing a decision. The choice of architecture specifies the vocabulary in which this is written, determining what sort of relations can be described according to the Chomsky Hierarchy [28]. The reason why LLMs are so prone to fabrication and inconsistency may be because they are optimised only to minimise loss, rather than maximise weakness [10]. Perhaps grokking [29] can be induced by optimising for weakness. Future research should investigate means by which weakness can be maximised in the context of neural networks.
>
> ## References
>
> - [1] M. T. Bennett. Appendices . Version 1.2.1. 2023. doi : 10.5281/zenodo.7641742 . url : github.com/ViscousLemming/Technical-Appendices .
> - [2] E. Sober. Ockham's Razors: A User's Manual . Cambridge Uni. Press, 2015.
> - [3] J. Rissanen. 'Modeling By Shortest Data Description*'. In: Autom. 14 (1978), pp. 465-471.
> - [4] F. Chollet. On the Measure of Intelligence . 2019.
> - [5] G. Chaitin. 'The Limits of Reason'. In: Sci. Am. 294.3 (2006), pp. 74-81.
> - [6] R. Solomonoff. 'A formal theory of inductive inference. Part I'. In: Information and Control 7.1 (1964), pp. 1-22.
> - [7] R. Solomonoff. 'A formal theory of inductive inference. Part II'. In: Information and Control 7.2 (1964), pp. 224-254.
> - [8] A. Kolmogorov. 'On tables of random numbers'. In: Sankhya: The Indian Journal of Statistics A (1963), pp. 369-376.
> - [9] M. Hutter. Universal Artificial Intelligence: Sequential Decisions Based on Algorithmic Probability . Berlin, Heidelberg: Springer-Verlag, 2010.
>
> - [10] M. T. Bennett. 'Symbol Emergence and the Solutions to Any Task'. In: Artificial General Intelligence . Cham: Springer, 2022, pp. 30-40.
> - [11] M. T. Bennett. Computational Dualism and Objective Superintelligence . 2023. url : arxiv.org/abs/2302.00843 .
> - [12] M. T. Bennett. 'Emergent Causality and the Foundation of Consciousness'. In: Artificial General Intelligence . Springer, 2023, pp. 52-61.
> - [13] M. T. Bennett. 'On the Computation of Meaning, Language Models and Incomprehensible Horrors'. In: Artificial General Intelligence . Springer, 2023, pp. 32-41.
> - [14] D. Ward, D. Silverman, and M. Villalobos. 'Introduction: The Varieties of Enactivism'. In: Topoi 36 (Apr. 2017).
> - [15] S. Harnad. 'The symbol grounding problem'. In: Physica D: Nonlinear Phenomena 42.1 (1990), pp. 335-346.
> - [16] J. Leike and M. Hutter. 'Bad Universal Priors and Notions of Optimality'. In: Proceedings of The 28th COLT, PMLR (2015), pp. 1244-1259.
> - [17] A. Gupta. 'Definitions'. In: The Stanford Encyclopedia of Philosophy . Ed. by E. N. Zalta. Winter 2021. Stanford University, 2021.
> - [18] A. Paszke et al. 'PyTorch: An Imperative Style, High-Performance Deep Learning Library'. In: NeurIPS . USA: Curran Assoc. Inc., 2019.
> - [19] D. Kirk. 'NVIDIA Cuda Software and Gpu Parallel Computing Architecture'. In: ISMM '07 . Canada: ACM, 2007, pp. 103-104.
> - [20] A. Meurer et al. 'SymPy: Symbolic computing in Python'. In: PeerJ Computer Science 3 (Jan. 2017), e103. doi : 10.7717/peerj-cs.103 .
> - [21] P. E. Hart, N. J. Nilsson, and B. Raphael. 'A Formal Basis for the Heuristic Determination of Minimum Cost Paths'. In: IEEE Transactions on Systems Science and Cybernetics 4.2 (1968), pp. 100-107.
> - [22] J. Hernández-Orallo and D. L. Dowe. 'Measuring universal intelligence: Towards an anytime intelligence test'. In: Artificial Intelligence 174.18 (2010), pp. 1508-1539.
> - [23] S. Legg and J. Veness. 'An Approximation of the Universal Intelligence Measure'. In: Algorithmic Probability and Friends . 2011.
> - [24] R. Evans. 'Kant's Cognitive Architecture'. PhD thesis. Imperial, 2020.
> - [25] R. Evans, M. Sergot, and A. Stephenson. 'Formalizing Kant's Rules'. In: J Philos Logic 49 (2020), pp. 613-680.
> - [26] R. Evans et al. 'Making Sense of Raw Input'. In: Artificial Intelligence 299 (2021).
> - [27] M. T. Bennett. 'Compression, The Fermi Paradox and Artificial SuperIntelligence'. In: Artificial General Intelligence . Springer, 2022, pp. 41-44.
> - [28] G. Delétang et al. Neural Networks and the Chomsky Hierarchy . 2022.
> - [29] A. Power et al. 'Grokking: Generalization Beyond Overfitting on Small Algorithmic Datasets'. In: ICLR . 2022. url : https://arxiv.org/abs/2201.02177 .
