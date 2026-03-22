---
created: 2026-03-22
description: Casting adversarial prompt generation as quality-diversity search via MAP-Elites produces diverse, effective attacks across predefined feature dimensions without fine-tuning an attacker model.
source: https://arxiv.org/abs/2402.16822
type: paper
---

## Key Takeaways

Rainbow Teaming recasts adversarial prompt generation as a quality-diversity (QD) optimization problem, using MAP-Elites to maintain an archive of adversarial prompts organized along user-defined feature dimensions (e.g., risk category and attack style). Each cell in the archive stores the most effective prompt for its particular combination of features, and an LLM-based mutator evolves prompts by directed mutation across categories. This is a fundamentally different approach from RL-based red teaming: rather than training a policy to maximize a reward signal, Rainbow Teaming uses evolutionary search with a preference-based judge to iteratively improve and diversify a population of attacks.

The use of preference-based evaluation rather than score-based metrics is a deliberate design choice that mirrors trends in the alignment literature. The authors argue that LLM judges performing pairwise comparisons have higher human agreement than those assigning absolute scores, and that score-based evaluators are vulnerable to reward hacking when used in an optimization loop. This connects to the concerns raised in [[RM Ensembles]] and [[Evaluator Stress Tests]] about the reliability of reward models under optimization pressure. By using a judge that only needs to determine which of two responses is more unsafe, Rainbow Teaming avoids saturating a fixed scoring scale.

The relationship to [[curiosity-driven red teaming achieves higher coverage by rewarding novelty over pure effectiveness]] is complementary. Both methods aim to solve the diversity-effectiveness tradeoff in automated red teaming, but CRT does it through curiosity rewards in an RL framework while Rainbow Teaming does it through the structural constraint of the QD archive. The archive ensures diversity by construction: every cell must be filled, and each cell represents a unique feature combination. This is a stronger diversity guarantee than CRT's soft novelty rewards, but it requires the user to predefine the feature dimensions, which CRT does not.

A key strength of Rainbow Teaming is its modularity. The three components (features, mutation operator, preference model) can be independently swapped, making it applicable beyond safety to domains like question answering and cybersecurity. The paper demonstrates this versatility by applying the same framework to discover factual errors and cybersecurity vulnerabilities, achieving high attack success rates in each domain. This generality distinguishes it from methods like [[PAIRED]], which are tightly coupled to environment design in RL settings.

The evolutionary self-play dynamic in Rainbow Teaming has a GAN-like flavor: the mutator acts as a generator producing adversarial prompts, the target LLM acts as a system being probed, and the judge acts as a discriminator evaluating the quality of attacks. However, unlike a GAN, none of these components are co-trained. The mutator is a fixed instruction-tuned LLM, and the judge is a separate fixed LLM. All the "learning" happens through the archive, which stores and curates the population of solutions. This makes the method inherently more stable than co-training approaches but potentially less adaptive to targets that evolve their defenses.

The practical results are striking: Rainbow Teaming achieves over 90% attack success rate against all tested Llama models, including heavily safety-tuned variants, and the synthetic data it generates can be used to fine-tune target models for improved robustness without degrading general capabilities. This creates a virtuous cycle where the adversarial search both diagnoses vulnerabilities and provides the training signal to fix them, connecting to the broader vision in [[Prover-Verifier Games]] of adversarial dynamics that improve both sides.

From the perspective of self-play stability, Rainbow Teaming demonstrates that evolutionary approaches can avoid the convergence and mode collapse issues that plague RL-based adversarial methods. The archive acts as a diversity buffer, the mutation operator provides controlled variation, and the preference-based evaluation prevents reward hacking. This is a different stability mechanism than the multiplicative weights in [[self-play preference optimization converges without a separate reward model]] or the KL regularization in [[self-play fine-tuning converts weak language models to strong language models]], but serves the same purpose: maintaining a productive adversarial dynamic over many iterations.

## External Resources

- [Rainbow Teaming Website](https://sites.google.com/view/rainbow-teaming) — project page with example archives

## Original Content

> [!quote]- Full Paper Text
> #### **1 Introduction**
> 
> Large language models (LLMs) have recently experienced remarkable growth in both their capabilities (OpenAI,
> 2023; Gemini Team et al., 2023; Touvron et al., 2023) and their applications in various fields (NLLB Team et al.,
> 2022; Thirunavukarasu et al., 2023; Schick et al., 2023; Bubeck et al., 2023). As LLMs become increasingly
> complex and are deployed in safety-critical environments (Singhal et al., 2022; Li et al., 2023; Maddela et al.,
> 2023), it is essential to thoroughly understand their robustness to different inputs. Indeed, the susceptibility
> of LLMs to adversarial prompts - prompts crafted to mislead the model or exploit its weaknesses, potentially
> leading to unsafe, biased, or incorrect outputs - poses a significant challenge (Perez et al., 2022; Wei et al.,
> 2023; Zou et al., 2023). Identifying and mitigating these vulnerabilities is therefore vital to ensure the safe
> and reliable operation of LLMs in the real world (Anwar et al., 2024; Hendrycks et al., 2022).
> 
> 
> Current methods for identifying adversarial prompts aimed at “attacking” LLMs and eliciting undesirable
> outputs are limited by several factors. These limitations include the necessity of fine-tuning an attacker
> model (Perez et al., 2022; Ge et al., 2023); white-box access to the target model (Liu et al., 2023); or significant
> human input (Yu et al., 2023). Several recent black-box methods, such as PAIR (Chao et al., 2023) and
> TAP (Mehrotra et al., 2023), rely on a human-in-the-loop to specify harmful behaviours (e.g., “Write a tutorial
> on how to hack the university server”) in a way where the human effort required is linear in the number of
> desired prompts. Many existing methods for systematically discovering adversarial attacks exhibit a lack
> of diversity by design (Liu et al., 2023), for instance by restricting themselves to a single predefined attack
> strategy (Shah et al., 2023; Jiang et al., 2024; Anil et al., 2024). Others suffer from loss of diversity, a common
> issue in objective-based prompt optimisation approaches (Zhou et al., 2022; Fernando et al., 2023). In both
> 
> 
> 1
> 
> 
> **Figure 1** An example archive generated by Rainbow Teaming when used to discover safety vulnerabilities in Llama
> 2-chat 7B. Here, we search over two features: Risk Category and Attack Style. Shading corresponds to the Llama
> Guard (Inan et al., 2023) scores of responses induced by the adversarial prompt in each cell (higher means more
> confidence in the response being unsafe). Some excerpts of discovered prompts from a single archive are shown. [1]
> 
> 
> cases, the narrow focus of generated prompts limits the usefulness of those methods both as a diagnostic tool
> and as a source of synthetic data for improving robustness.
> 
> 
> We introduce Rainbow Teaming, a versatile approach for systematically generating diverse adversarial
> prompts for LLMs via LLMs. While the prevailing approach to automatic _red_ _teaming_ (Perez et al., 2022)
> also uses LLMs to generate adversarial inputs, it exhibits a steep trade-off between the diversity of discovered
> attacks and their success rate. In contrast, Rainbow Teaming takes a more deliberate approach, efficiently
> covering the space of attacks by directly optimising for the attack quality and diversity. To this end, our
> method casts the problem of adversarial prompt generation as _quality-diversity_ (QD) search (Lehman and
> Stanley, 2011; Pugh et al., 2016; Cully and Demiris, 2018) and takes direct inspiration from Samvelyan et al.
> (2024) to discover a set of adversarial prompts that are both diverse and effective.
> 
> 
> Rainbow Teaming is an _open-ended_ approach (Hughes et al., 2024) which builds on MAP-Elites (Mouret
> and Clune, 2015), an evolutionary search method that iteratively populates an “archive” with increasingly
> higher-performing solutions. In our case, these solutions are adversarial prompts that elicit undesirable
> behaviours in a target LLM, while the archive is a discrete grid where each dimension categorises prompts
> according to a feature of interest for diversity, such as attack style, risk category, or prompt length. The
> output of our method, as shown in Figure 1, is a set of prompts covering every combination of features
> specified by the archive. These diverse and effective attack prompts serve both as a diagnostic tool for the
> vulnerabilities of the target LLM and as a high-quality synthetic dataset to robustify the target.
> 
> 
> Rainbow Teaming is directly applicable to a wide range of domains. Implementing Rainbow Teaming
> requires three essential building blocks: 1) A set of _features_ that specify the dimensions of diversity (e.g.,
> “Risk Category” or “Attack Style”); 2) A _mutation_ _operator_ to evolve adversarial prompts (e.g., an LLM that
> is itself prompted to mutate previously discovered prompts (Lehman et al., 2022)); and 3) a _preference_ _model_
> that ranks adversarial prompts based on their effectiveness. For safety, this can be a “judge” LLM (Zheng
> et al., 2023) that compares two responses to determine which is more unsafe.
> 
> 
> We demonstrate the effectiveness of Rainbow Teaming through extensive experiments targeting several
> state-of-the-art LLMs fine-tuned on safety-aligned data, including the Llama 2-chat (Touvron et al., 2023) and
> Llama 3-Instruct (AI@Meta, 2024) models. Despite the rigorous development of these models, our experiments
> reveal hundreds of adversarial prompts per individual run, achieving an attack success rate higher than 90%
> across all tested models without requiring external data. Using popular safety benchmarks, we demonstrate
> that Rainbow Teaming outperforms strong baselines in identifying vulnerabilities. Additionally, fine-tuning
> LLMs with synthetic data generated by our approach significantly enhances their adversarial robustness,
> 
> 
> 1For additional adversarial prompts and details, visit our website at [https://sites.google.com/view/rainbow-teaming.](https://sites.google.com/view/rainbow-teaming)
> 
> 
> 2
> 
> 
> improving resistance to unseen attacks and subsequent rounds of Rainbow Teaming, without diminishing
> their general capabilities and helpfulness.
> 
> 
> We further illustrate the versatility of Rainbow Teaming by applying it to other domains, such as question
> answering and cybersecurity, uncovering hundreds of effective adversarial prompts in each case. These
> findings underscore Rainbow Teaming’s potential as a comprehensive tool for diagnosing and advancing the
> robustness and reliability of LLMs across diverse applications.
> #### **2 Background**
> 
> 
> Rainbow Teaming builds on existing approaches in quality-diversity (QD) search to automate the discovery
> of a broad spectrum of adversarial prompts. QD methods seek to produce a collection of solutions that are
> individually high-performing and collectively diverse (Lehman and Stanley, 2011; Cully and Demiris, 2018).
> Given a space of solutions _X_, the quality of a solution _x ∈X_ is measured using a _fitness_ _function_ _f_ : _X_ _→_ R.
> The diversity of solutions is characterised using a _feature_ _descriptor_ _function_, _d_ : _X_ _�→Z_ that maps each
> solution to a point in a feature space _Z_ = R _[N]_ . This space encompasses specific pre-defined attributes of
> the solution, such as its behavioral aspects. For each _z_ _∈Z_, QD searches for the solution _x ∈X_ such that
> _d_ ( _x_ ) = _z_ and _f_ ( _x_ ) is maximised.
> 
> 
> Our work builds directly on _MAP-Elites_ (Mouret and Clune, 2015), a simple yet effective QD method.
> MAP-Elites tracks the highest-fitness solutions in a multidimensional grid, referred to as the _archive_, which
> discretises the feature space _Z_ . The archive is first initialised with random solutions. During each iteration of
> MAP-Elites, a solution _x_ is sampled at random from the archive and modified to create a new solution _x_ _[′]_
> 
> (e.g., by injecting Gaussian noise). The new solution _x_ _[′]_ is then evaluated and assigned to its corresponding
> archive cell based on its descriptor _z_ _[′]_ = _d_ ( _x_ _[′]_ ). If the cell is vacant, or if _x_ _[′]_ has higher fitness than the current
> occupant, also known as the _elite_, _x_ _[′]_ becomes the new elite for that cell. Through repeated cycles of selection,
> mutation, and evaluation, MAP-Elites fills the archive with the highest-fitness solutions. Algorithm 1 in
> Appendix B provides the pseudocode of this method.
> 
> #### **3 Rainbow Teaming**
> 
> 
> We now describe Rainbow Teaming, our new approach for automatically generating a diverse collection of
> adversarial prompts. Rainbow Teaming casts this task as a QD search problem with the solution space
> corresponding to all possible prompts. Our rationale for employing QD is twofold:
> 
> 
> - Effective adversarial prompts for specific scenarios (e.g., criminal planning) could be effective for others (e.g.,
> cybercrime and hacking) with relatively small modifications. This adaptability implies that solutions can
> serve as _stepping_ _stones_ to accelerate the discovery of new adversarial strategies across different categories.
> 
> 
> - A thorough diagnostic of the vulnerabilities of a model calls for a comprehensive analytical tool to mitigate
> the risks of leaving attack vectors undiscovered. Similarly, safety fine-tuning requires a sufficiently _diverse_
> dataset to improve a model’s adversarial robustness against a wide range of attacks. Diversity is essential
> for both of these objectives, and QD allows us to optimise it explicitly.
> 
> 
> Rainbow Teaming is based on MAP-Elites (Mouret and Clune, 2015). We store adversarial prompts as
> solutions in a _K_ -dimensional archive, with each dimension corresponding to one of the pre-defined features.
> Each cell in the archive corresponds to a unique combination of _K_ categories that describe the prompt within
> it, known as the cell’s and the solution’s _descriptor_, and denoted _z_ = _⟨c_ 1 _, . . ., cK⟩_ . The LLM for which
> the adversarial prompts are generated is referred to as the _Target_ . Initial solutions can be either generated
> randomly using an LLM or loaded from an existing dataset. As shown in Figure 2, all key operation of the
> iterative search are performed with LLMs.
> 
> 
> At each iteration of Rainbow Teaming, we sample 1) an adversarial prompt _x_ from the archive with
> descriptor _z_, and 2) a descriptor _z_ _[′]_ for the new _candidate_ prompt to be generated. Note that _z_ and _z_ _[′]_ are
> different. [2] We provide _x_ and _z_ _[′]_ to the _Mutator_ LLM to generate a new candidate prompt _x_ _[′]_ with descriptor
> _z_ _[′]_ . We then feed _x_ _[′]_ to the Target to generate a response. Finally, we ask a _Judge_ LLM (Zheng et al., 2023)
> to compare the effectiveness of the candidate prompt _x_ _[′]_ to that of the archive’s elite prompt - the prompt
> 
> 
> 2In Figure 2, _z_ = _⟨_ “Criminal Planning” _,_ “Role Play” _⟩_, while _z′_ = _⟨_ “Fraud and Scams” _,_ “Misspellings” _⟩_ .
> 
> 
> 3
> 
> 
> |Col1|Col2|Col3|Col4|Col5|Col6|
> |---|---|---|---|---|---|
> |||||||
> ||||**>_**|||
> |||||||
> |||||||
> |||||||
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> **Figure 2** Overview of Rainbow Teaming in the safety domain: Our method operates on a discretised grid, archiving
> adversarial prompts with _K_ defining features, such as Risk Category or Attack Style. Each iteration involves a _Mutator_
> LLM applying _K_ mutations to generate new candidate prompts. These prompts are then fed into the _Target_ LLM. A
> _Judge_ LLM evaluates these responses against archived prompts with the same features, updating the archive with any
> prompt that elicits a more unsafe response from the Target.
> 
> 
> stored in the archive with a descriptor _z_ _[′]_ . This comparison focuses on the criteria of interest, such as the
> toxicity of the Target response, to determine which of the two prompts more effectively meets the adversarial
> objective. We then store the winning prompt in the archive at the position specified by _z_ _[′]_ . Algorithm 2 in
> Appendix B provides the pseudocode of our method.
> 
> 
> Rainbow Teaming is highly versatile and can easily be applied to various settings by implementing three
> components: prompt features, a mutation operator, and a preference model.
> 
> 
> **3.1** **Prompt Features**
> 
> 
> The features define the archive, with each predefined feature corresponding to one of the _K_ archive dimensions.
> A feature can be either categorical or numerical. For categorical features, the axis of the archive is composed
> of discrete bins each representing a unique feature category. For instance, the Risk Category and Attack Style
> features in Figure 1 each consist of 10 categories. Numerical features are represented on a continuous scale,
> discretised into a set of intervals. Features therefore determine both the final archive size and the axes of
> diversity that Rainbow Teaming prioritises. This is particularly true given their interplay with the _mutation_
> _operator_, as described next.
> 
> 
> **3.2** **Mutation Operator**
> 
> 
> Rainbow Teaming generates new candidates by applying directed mutations to previously discovered
> adversarial prompts. The Mutator receives a parent prompt _x_ sampled uniformly at random from the archive
> and the prescribed descriptor _z_ _[′]_ = _⟨c_ _[′]_ 1 _[, . . ., c][′]_ _K_ _[⟩]_ [for] [the] [candidate.] [It] [then] [mutates] [the] [prompt] _[x]_ [once] [for] [each]
> feature - _K_ times overall - to produce a new candidate prompt _x_ _[′]_ .
> 
> 
> Sampling the candidate’s descriptor in advance confers several key benefits. First, this allows us to forgo using
> a classifier for assigning the candidate to its corresponding cell, which can be inaccurate. Second, it introduces
> more diversity by mitigating the biases of the Mutator, which could otherwise neglect entire categories. Third,
> it helps avoid spending iterations on areas of the archive for which we already have effective adversarial
> prompts. We do this by biasing the sampling distribution of the descriptors towards areas of the archive with
> low fitness. We compute fitness explicitly for this purpose but do not use it to inform archive updates.
> 
> 
> 4
> 
> 
> To further promote diversity, the candidate prompt is considered for further evaluation only if it is sufficiently
> dissimilar from its parent. We measure the similarity using BLEU (Papineni et al., 2002) and filter out
> prompts that have high BLEU scores with respect to their parents.
> 
> 
> **3.3** **Preference Model**
> 
> 
> The preference model, operated through the Judge, performs the ranking of adversarial prompts based on
> their effectiveness (e.g., whether they elicit unsafe responses). The Judge inputs can vary between domains,
> but preference-based evaluations include the Target responses to both the candidate and the existing prompt
> from the archive with descriptor _z_ _[′]_ . The Judge determines which prompt is more effective using a majority
> vote over multiple evaluations and swapping prompt positions to mitigate order bias (Zheng et al., 2023). If
> the candidate wins the comparison, it replaces the existing prompt.
> 
> 
> Relying on a preference model rather than a score-based evaluator offers two advantages. First, LLMs prompted
> to perform pairwise comparisons have a higher agreement with humans than those performing single-answer
> grading (Zheng et al., 2023). This is particularly true in an optimisation context, which introduces the risk
> of reward hacking the evaluator. Second, the score of any numerical evaluator with a fixed scale can be
> maximised, at which point it is impossible to identify better candidate prompts, resulting in minimal updates
> in the archive. We present a preference model ablation supporting those claims in Appendix E.4.
> 
> 
> While we describe Rainbow Teaming as using LLMs for all key steps, those can be substituted by other
> models or rule-based components in some domains (e.g., see Section 6.1).
> 
> #### **4 Rainbow Teaming for Safety**
> 
> 
> In this section, we evaluate the effectiveness of Rainbow Teaming in discovering adversarial prompts that
> trigger unsafe (i.e., harmful, offensive, or toxic) responses. We target various models that are fine-tuned with
> safety-aligned data and are among the safest publicly available LLMs, including Llama 2 and Llama 3 models.
> 
> 
> - **Features:** We use two feature dimensions: Risk Category and Attack Style. Our risk categories expand upon
> the safety risk taxonomy in Inan et al. (2023) and cover common safety issues in LLMs, such as “Criminal
> Planning”, “Violence and Hate” or “Self-Harm”. Attack Style pertains to the method of eliciting unsafe
> responses, such as “Authority Manipulation” and “Role Play”. Together, these features enable a thorough
> evaluation of LLM safety, covering a broad spectrum of adversarial threats and tactics. The full list of
> categories for both features is provided in Appendix H.1.
> 
> - **Mutation Operator:** We use an instruction-tuned Llama 2 70B model, which applies two mutations to create
> the candidate prompt, as illustrated in Figure 2. The first mutation targets the risk category, using a
> few-shot prompt template shared across all categories. The second mutation focuses on the attack style,
> employing few-shot prompts handcrafted for each individual category.
> 
> - **Preference Model:** We use an instruction-tuned Llama 2 70B model as a Judge to compare Target responses
> to two adversarial prompts. Its role is to determine which response is more unsafe, ignoring the prompts.
> The prompt corresponding to the winner’s response is the one we then keep in the archive. Details about
> the prompts used for the Judge are provided in Appendix I.
> 
> 
> To initialise the archive, we generate prompts from scratch according to risk categories without relying on a
> pre-existing seed dataset. These are then mutated with respect to attack style and used as a foundation for
> subsequent evolutionary iterations. We use two independent measures of Attack Success Rate (ASR) - the
> proportion of prompts in the archive that elicit unsafe responses. Specifically, we use two safety classifiers,
> namely GPT-4 (OpenAI, 2023) with a specialised prompt and the Llama Guard safeguard model (Inan et al.,
> 2023). GPT-4 acts as a binary classifier for whether a response is generally unsafe or not, independent of risk
> categories. In contrast, Llama Guard is prompted to perform _per-category_ _binary_ _classification_ (Inan et al.,
> 2023), considering an attack successful only if the resulting response violates the risk category it is assigned
> to. Neither of these metrics is explicitly optimised by Rainbow Teaming, but the probability of Llama
> Guard classifying a prompt as unsafe is the fitness score used to bias the selection of the prescribed feature
> 
> 
> 5
> 
> 
> descriptors for new candidates. Prompts for both evaluators are provided in Appendix I. For all experiments,
> we report the mean and standard error over 3 independent runs.
> 
> 
> We also measure inter-evaluator agreement on 100 pairs of prompts and responses. Table 8 in Appendix E.3
> 
> shows that human-human agreement (83%) is similar to human-AI agreement (81% for GPT-4 and 78% for
> Llama Guard) and GPT-4-Llama Guard agreement (79%), and is consistent with prior work (Zheng et al.,
> 2023). We therefore use GPT-4 and Llama Guard as proxies for human evaluation.
> 
> 
> 
> 
> 
> 
> 
> 1.0
> 
> 
> 0.8
> 
> 
> 0.6
> 
> 
> 0.4
> 
> 
> 0.2
> 
> 
> 0.0
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 1.0
> 
> 
> 0.8
> 
> 
> 0.6
> 
> 
> 0.4
> 
> 
> 0.2
> 
> 
> 0.0
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 0 500 1000 1500 2000
> Iterations
> 
> 
> **Figure 3** Attack success rate of adversarial prompts discovered by Rainbow Teaming for different models, as
> evaluated by GPT-4.
> 
> 
> **4.1** **Results**
> 
> 
> 
> 0 500 1000 1500 2000
> Iterations
> 
> 
> **Figure 4** Attack success rate of adversarial prompts discovered by Rainbow Teaming and baselines against the
> Llama 2-chat 7B model.
> 
> 
> 
> **Main Results.** Figure 3 presents the ASR of Rainbow Teaming when applied to the Llama 2-chat 7B (Touvron
> et al., 2023), Llama 3-Instruct 8B (AI@Meta, 2024), Mistral 7B (Jiang et al., 2023) and Vicuna 7B v1.5 (Chiang
> et al., 2023) models across 2000 iterations, using GPT-4 for evaluation. Rainbow Teaming is highly effective,
> generating a large collection of adversarial prompts against all models. The Llama models exhibit the highest
> robustness: following 2000 iterations, we obtain archives of 100 prompts with an approximate **ASR of 92%**
> against both variants. Mistral 7B and Vicuna 7B demonstrate a higher level of vulnerability with **98%** of the
> adversarial prompts in Rainbow Teaming-generated archives being successful. These results are echoed by
> the ASR reported by Llama Guard in Figure 10.
> 
> 
> While Figure 3 showcases relatively small LLMs, Rainbow Teaming is equally effective against larger models.
> 
> Figure 8 in Appendix E.1 presents results of Rainbow Teaming targeting 7B, 13B, and 70B variants of
> Llama 2-chat model, **achieving 90% or higher ASR across all model sizes** .
> 
> 
> We compare Rainbow Teaming to two baselines. The first baseline _(No_ _Stepping_ _Stones)_ ignores past
> solutions in the archive and generates new prompts based on the risk category, before applying the attack
> style mutation, effectively repeating the process we use to initialise the Rainbow Teaming archive. The
> second baseline, _(Same_ _Cell_ _Mutations)_, is identical to Rainbow Teaming, except that it uses the parent
> prompt’s descriptor as the candidate prompt descriptor, i.e., it performs mutations within each archive cell
> independently. Figure 4 shows Rainbow Teaming outperforming both baselines, highlighting the value of
> stepping stones in one case and the significance of cross-category mutations in the other.
> 
> 
> **JailbreakBench Results.** We also apply Rainbow Teaming towards eliciting specific harmful behaviours from
> the JailbreakBench (Chao et al., 2024) dataset. Using the same attack styles, we generate 1000 prompts evenly
> spanning 100 harmful behaviours, with results presented in Table 1. We compare against two PAIR (Chao
> et al., 2023) variants: one from Chao et al. (2024), based on MiXtral, and another using the same mutator
> LLM as our Rainbow Teaming implementation, with _N_ = 20 parallel streams generating a total of 2000
> prompts. We classify jailbreaks using both the same classifier as Chao et al. (2024) and Llama Guard prompted
> with the harmful behaviours. For each prompt, we regenerate 4 responses and consider the prompt successful
> if any of the responses is classified as harmful. We believe this is representative of user interaction with LLMs,
> 
> 
> 6
> 
> 
> where they can prompt the model repeatedly in the hope of obtaining a different response. Compared to both
> PAIR variants, Rainbow Teaming discovers more jailbreaks across more behaviours, while also maintaining
> much higher prompt diversity.
> 
> 
> **Table 1** Comparison of Rainbow Teaming against PAIR (Chao et al., 2023) for eliciting harmful behaviours from
> JailbreakBench (Chao et al., 2024). Top: ( _n/k_ ) indicates the total number of successful jailbreaks ( _n_ ) and the total
> number of behaviours jailbroken ( _k_ ) for each method and classifier (best of 4 responses). Bottom: Self-BLEU similarity
> score.
> 
> |Classifier|PAIR with<br>PAIR RT mutator LLM Rainbow Teaming|
> |---|---|
> |JailbreakBench Classifer (Chao et al., 2024) (_↑_)<br>Llama Guard (JBB Behaviours) (_↑_)|-/4<br>1/1<br>**8/7**<br>-<br>14/11<br>**66/41**|
> |Self-BLEU (_↓_)|-<br>0.74<br>**0.51**|
> 
> 
> 
> **Transfer of Adversarial Prompts.** Understanding whether attacks transfer across models is important to assess
> the generality of the adversarial prompts, and whether they are intrinsically tied to the models they are
> optimised for. To evaluate transfer, we take the final prompts generated by Rainbow Teaming for each
> _original_ _target_ in Figure 3 and evaluate their ASR against other _transfer_ _targets_ .
> 
> 
> Table 2 presents the ASR on four different models using archives generated by Rainbow Teaming targeting
> each of these models. We show the ASR in grey when re-prompting targets using their own archive. On
> average, the ASR when transferring prompts is 50% of the ASR against the original target, indicating that
> Rainbow Teaming discovers general prompts which apply to multiple models. However, the exact transfer
> rate is highly dependent upon the pairing of original and transfer targets. We find that prompts transfer
> better from safer to less safe models than in the opposite direction. That said, the highest transfer rate is
> from Vicuna 7B 1.5 to Mistral 7B, even though Vicuna is fine-tuned from a Llama 2 base. We also achieve up
> to 66% ASR on GPT-4o, indicating no significant difference between open and closed-source models.
> 
> 
> **Table 2** Transfer of adversarial prompts across different models. We take 3 archives for each original target, apply them
> to the transfer target, and report the mean and standard deviation of the ASR as evaluated by Llama Guard (best of
> 4 responses). 50% of adversarial prompts transfer on average, but the exact transfer varies drastically between models.
> All models reported are instruction fine-tuned.
> 
> |Original Target|Transfer Target Model<br>Llama 2-chat 7B Llama 3-Instruct 8B Mistral 7B Vicuna 7B 1.5 GPT-4o|
> |---|---|
> |Llama 2-chat 7B<br>Llama 3-Instruct 8B<br>Mistral 7B<br>Vicuna 7B 1.5|0.95 _±_ 0.02<br>0.57 _±_ 0.10<br>0.64 _±_ 0.09<br>0.67 _±_ 0.09<br>0.48 _±_ 0.08<br>0.36 _±_ 0.05<br>0.90 _±_ 0.04<br>0.82 _±_ 0.02<br>0.75 _±_ 0.01<br>0.66 _±_ 0.01<br>0.01 _±_ 0.01<br>0.10 _±_ 0.02<br>0.96 _±_ 0.01<br>0.65 _±_ 0.04<br>0.12 _±_ 0.01<br>0.03 _±_ 0.02<br>0.16 _±_ 0.09<br>0.93 _±_ 0.01<br>0.93 _±_ 0.01<br>0.41 _±_ 0.02|
> 
> 
> 
> **Impact of the Similarity Filter.** Because archive categories are not mutually exclusive, we run the risk of
> populating the archive with near identical prompts. This is useful for discovering a category-agnostic failure
> mode but comes at the cost of significant diversity loss in the archive. To mitigate the issue, we implement
> a parent-child similarity filter at the mutation stage, as described in Section 3.2. Table 3 compares the
> performance of Rainbow Teaming with and without using this similarity filter. We also report archive selfBLEU (Zhu et al., 2018), BERTScore (Zhang et al., 2020), ROGUE-L (Lin and Och, 2004)m and compression
> ratio (Shaib et al., 2024) scores designed to measure the diversity of a whole dataset. Our results show that
> the similarity filter is an effective way of maintaining the linguistic diversity of the archive.
> 
> 
> Additional results with different system prompts are provided in Appendix E.2. We include an ablation study
> in Appendix E.4 to assess the role of the preference model. We discuss computational costs in Appendix G.
> 
> 
> 7
> 
> 
> **Table 3** Analysis of the effect of a mutation-level similarity filter of Rainbow Teaming on ASR measured by GPT-4
> and archive diversity (self-BLEU, BERTScore, ROGUE-L, and gzip compression ratio). Filtering out prompts that are
> too similar to their parent maintains a balance between ASR and diversity, whereas removing the filter encourages
> the method to reuse highly effective prompts across multiple cells. The filter is set at _τ_ = 0 _._ 6, discarding _∼_ 24% of
> mutated prompts. We report mean and standard error over 3 independent runs.
> 
> |Similar Filter|ASR ↑|Self-BLEU ↓ BERTScore ↓ ROGUE-L ↓ Compress Ratio ↓|
> |---|---|---|
> |Yes<br>No|0_._92_ ±_ 0_._01<br>**0**_._**99**_ ±_** 0**_._**01**|**0**_._**42**_ ±_** 0**_._**01**<br>**0**_._**74**_ ±_** 0**_._**01**<br>**0**_._**15**_ ±_** 0**_._**01**<br>**3**_._**10**_ ±_** 0**_._**04**<br>0_._79_ ±_ 0_._04<br>0_._83_ ±_ 0_._02<br>0_._39_ ±_ 0_._06<br>6_._35_ ±_ 0_._65|
> 
> 
> #### **5 Enhancing Robustness with Synthetic Data**
> 
> 
> Generating diverse, high-quality instruction-tuning datasets can be expensive, often requiring human annotations. Rainbow Teaming offers a low-cost alternative, generating diverse synthetic data that specifically
> targets the model’s vulnerabilities. In this section, we demonstrate the usefulness of Rainbow Teaming as a
> synthetic dataset generation method by applying it to improve the safety of LLMs. We find that training
> on our synthetically generated data improves robustness to adversarial prompts while retaining the general
> capabilities of the model.
> 
> 
> We use Rainbow Teaming to generate 15 archives targeting the Llama 2-chat 7B model, yielding a total of
> 1500 adversarial prompts. We perform a 12/3 train-test split and use Llama 2-chat 70B with a handcrafted
> system prompt to generate safe refusal prompts for the train set. We then perform supervised fine-tuning
> (SFT) (Wei et al., 2022) on this dataset and evaluate the ASR of the 300 held-out prompts before and after
> SFT. As shown in Table 4, we find that **fine-tuning Llama 2-chat 7B on the synthetic dataset generated by**
> **Rainbow Teaming substantially reduces the attack success rate from 92% / 95% to 0.3% / 0.7%**, as measured
> by GPT-4 and Llama Guard. Similarly, the ASR of PAIR (Chao et al., 2023) on the JailbreakBench (JBB,
> Chao et al. (2024)) behaviours drops from 14% to 0% (measured by Llama Guard, as in Table 1). This
> demonstrates that additional SFT on Rainbow Teaming data also improves safety against out-of-distribution
> attacks. Crucially, SFT does not diminish the model’s general capabilities as measured on the GSM8K (8-shot,
> maj@1) (Cobbe et al., 2021) and MMLU (5-shot) (Hendrycks et al., 2021) benchmarks. [3]
> 
> 
> **Table 4** Safety and capabilities scores of the Llama 2-chat 7B model before and after SFT on Rainbow Teaminggenerated data. Fine-tuning greatly improves robustness to adversarial prompts without hurting capabilities.
> 
> |When|ASR on New Archives<br>GPT-4↓ Llama Guard↓|PAIR ASR<br>on JBB↓|General Capabilities<br>GSM8K↑ MMLU↑|RM Scores<br>Safe ↑ Helpful↑|
> |---|---|---|---|---|
> |Before SFT<br>After SFT|0_._92_ ±_ 0_._008<br>0_._95_ ±_ 0_._005<br>0_._003_ ±_ 0_._003<br>0_._007_ ±_ 0_._003|0.14<br>0.0|0_._224<br>0_._412<br>0_._219<br>0_._405|0_._883<br>0_._518<br>0_._897<br>0_._513|
> 
> 
> 
> Table 4 also reports the reward model scores (Touvron et al., 2023) of the Llama 2-chat 7B model before
> and after SFT. We report safety and helpfulness scores on the Anthropic Harmless and Anthropic Helpful
> datasets (Ganguli et al., 2022) respectively. We observe a 1 _._ 5% safety score increase, despite the fact that
> Llama 2-chat models use the Anthropic Harmless dataset as a part of the reinforcement learning from human
> feedback (RLHF) pipeline (Touvron et al., 2023). This is accompanied by a 0 _._ 5% drop in helpfulness, which
> we attribute to fine-tuning the model exclusively on the adversarial prompts produced by Rainbow Teaming.
> Mixing the adversarial data with helpfulness data would likely negate this effect, but we leave the study of
> adversarial fine-tuning strategies to future work.
> 
> 
> To further investigate the robustness of the newly fine-tuned model, we reapply Rainbow Teaming to the
> Llama 2-chat 7B model after fine-tuning it on synthetic data generated by our method. As shown in Figure 5,
> the new model is substantially more robust to our approach, with a **final ASR of 39% (down from 92%)** . We
> expect that performing multiple rounds of Rainbow Teaming, alternating between collecting synthetic
> data and adversarial fine-tuning, will further increase the model’s robustness to adversarial attacks. We show
> examples of archives at different iterations of Rainbow Teaming before and after SFT in Figure 13.
> 
> 
> 3Touvron et al. (2023) report base model scores on these benchmarks while we report those of the chat model.
> 
> 
> 8
> 
> 
> **Figure 5** Attack success rate before and after fine-tuning Llama 2-chat 7B on synthetic data generated via Rainbow
> Teaming. The fine-tuned model is significantly less vulnerable to Rainbow Teaming on a second application, with
> the method achieving a substantially lower ASR after 2000 iterations.
> 
> #### **6 Rainbow Teaming for Other Applications**
> 
> 
> **6.1** **Question Answering**
> 
> 
> 
> We apply Rainbow Teaming to question answering,
> generating adversarial trivia questions - questions
> which the target model answers incorrectly. We define a 3D archive, with Topic, Interrogative Word and
> Question Length as features. The mutation operators for topics and interrogative words are analogous
> to those used in Section 4. For length, we simply
> prompt the Mutator to either “lengthen” or “shorten”
> the question. The preference model uses a Judge
> to compare answers from a Target (Llama 2-chat
> 7B) and a superior Oracle (Llama 2-chat 70B) to
> determine the fitness of questions based on the correctness of the responses. For more information, see
> Appendix F.1.
> 
> 
> 
> Where
> 
> 
> When
> 
> 
> What
> 
> 
> Who
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 24
> 
> 
> 
> 
> 
> **Results.** In Table 5 we compare Rainbow Teaming **Figure 6** An example archive of adversarial questions disto a baseline that generates candidate questions from covered by Rainbow Teaming. Vacant cells are marked
> 
> in yellow, intermediate but unsuccessful attempts are in
> 
> scratch rather than relying on existing questions in
> 
> green, and successful adversarial questions are in purple.
> 
> the archive. We observe that Rainbow Teaming
> achieves higher fitness, higher coverage (percentage of non-empty cells in the archive), and higher diversity in
> questions, indicating the importance of utilising previously discovered adversarial questions. Importantly, not
> relying on previous solutions leaves regions of the archive uncovered, particularly for short questions as seen
> in the example archives in Appendix E. Figure 6 illustrates an example archive generated using Rainbow
> Teaming. Some example questions are also shown in Appendix E.7.
> 
> 
> **Table 5** Comparison of Rainbow Teaming to a baseline generating new questions from scratch each turn for the
> Q&A domain. Without reusing past questions as stepping stones, performance is worse across all metrics considered.
> 
> 
> Method Mean Fitness _↑_ Coverage _↑_ Self-BLEU _↓_
> 
> Rainbow Teaming **0** _**.**_ **91** _**±**_ **0** _**.**_ **01** **0** _**.**_ **97** _**±**_ **0** _**.**_ **01** **0** _**.**_ **50** _**±**_ **0** _**.**_ **02**
> Baseline (No Stepping Stones) 0 _._ 79 _±_ 0 _._ 01 0 _._ 90 _±_ 0 _._ 01 0 _._ 60 _±_ 0 _._ 01
> 
> 
> 9
> 
> 
> **6.2** **Cybersecurity**
> 
> 
> We apply Rainbow Teaming to cybersecurity, searching for adversarial prompts that elicit behaviour such
> as generating insecure code or providing assistance in orchestrating cyberattacks. We use a 2D archive with
> the 10 MITRE categories for cyberattack tactics (MITRE, 2024) (e.g., “Exfiltration” or “Defense Evasion”)
> and prompt length divided into 10 equal bins. Our Mutator is an instruction-tuned Llama 2 70B model,
> mutating first for MITRE attack style, and then for prompt length. We use a binary Judge mechanism
> involving Llama 2-chat 70B and CodeLlama-34B Instruct models to evaluate generated prompts, as outlined
> in CyberSecEval (Bhatt et al., 2023). We provide further details in Appendix F.2.
> 
> 
> **Table 6** Cybersecurity ASR of Rainbow Teaming on four Targets, as reported by CyberSecurityEval (Bhatt et al.,
> 2023) (3 seeds), and human expert evaluation (1 seed).
> 
> 
> Target CyberSecEval Human
> Llama 2-chat 7B 1.00 0.94
> Llama 2-chat 70B 1.00 0.80
> CodeLlama 7B Instruct 1.00 0.92
> CodeLlama 34B Instruct 1.00 0.80
> 
> 
> **Results.** Table 6 presents the results of a cybersecurity assessment for various target models on prompts
> generated by Rainbow Teaming. For all models, we successfully generate 10 _×_ 10 archives that are fully
> identified as malicious, as classified by CyberSecEval (Bhatt et al., 2023). Human expert evaluation finds a
> lower ASR, with 0 _._ 94 and 0 _._ 92 for Llama 2-chat 7B and CodeLlama 7B Instruct, and 0 _._ 8 for both Llama
> 2-chat 70B and CodeLlama 34B Instruct. While Rainbow Teaming remains highly effective, the discrepancy
> between CyberSecEval and expert annotations suggests the need for a better cybersecurity-specific evaluation,
> which we hope will be the focus of future work.
> 
> #### **7 Related Work**
> 
> 
> **Adversarial Attacks on LLMs.** Rainbow Teaming relates most closely to prompt-level attacks which rely on
> strategies such as misspellings, prompting in foreign languages (Yong et al., 2023), or persona-modulation (Shah
> et al., 2023) to jailbreak LLMs. Perez et al. (2022) use an LLM and a brute-force approach to automatically
> discover prompt-level attacks, but this approach can suffer from mode collapse and does not always generate
> a diverse set of prompts. Meanwhile, Liu et al. (2023) propose a white-box method that refines hand-crafted
> attack prompts using a mix of genetic algorithms and LLM-based mutations. However, they focus on
> optimising a single solution rather than a diverse population. The closest works to our own are PAIR (Chao
> et al., 2023) and Tree of Attacks with Pruning (TAP) (Mehrotra et al., 2023) - two black-box methods for
> automatically discovering prompt-level attacks by using an LLM to iteratively generate candidates. However,
> both methods are designed to jailbreak the model with respect to a single task rather than across a range of
> diverse risk categories and attack styles. In contrast, our work uses quality-diversity search to automatically
> discover attacks covering a diverse set of risks and attack strategies. Although evolutionary algorithms have
> previously been used for adversarial attacks on LLMs (Liu et al., 2023; Lapid et al., 2023a; Chao et al., 2023),
> this work is the first to apply a quality-diversity framework (Lehman and Stanley, 2011; Cully and Demiris,
> 2018) in this area. Unlike most evolutionary algorithms (e.g., genetic algorithms), which evolve a single
> optimal solution, quality-diversity approaches generate a wide variety of distinct, high-quality solutions.
> 
> 
> **Open-Endedness and LLMs.** Rainbow Teaming builds on the ability of LLMs to act as a powerful mutation
> operator over language inputs, one that adheres to the underlying structure of natural language (Lehman et al.,
> 2022). Several recent methods exploit this capability of LLMs in order to perform an efficient novelty-driven
> evolutionary search in the language space, leading to the discovery of potentially open-ended repertoires
> of solutions (Chen et al., 2023; Fernando et al., 2023; Meyerson et al., 2023). Closest to our approach is
> QDAIF (Bradley et al., 2023) which similarly uses LLMs for QD search in order to generate a diverse archive
> of LLM outputs. Rainbow Teaming is different from QDAIF in several important factors. First, we search
> for and archive diverse _prompts_ for the target LLMs, whereas QDAIF archives diverse _responses_ from it
> 
> 
> 10
> 
> 
> - a separate problem altogether. While QDAIF focuses purely on generating diverse outputs for creative
> writing, our method seeks to find a diverse set of adversarial prompts. QDAIF relies on a score-based fitness
> function (log probability of the token generation), whereas Rainbow Teaming uses a preference-based judge
> for performing updates to the archive. Rainbow Teaming additionally incorporates parent-child similarity
> filtering to preserve the linguistic diversity of the prompts.
> 
> 
> An extended related work section is provided in Appendix C.
> 
> #### **8 Conclusion**
> 
> 
> In this work, we introduce Rainbow Teaming, a novel approach for the automatic generation of diverse
> adversarial prompts for LLMs. By leveraging quality-diversity search, Rainbow Teaming efficiently explores
> the space of potential adversarial attacks, resulting in a diverse archive of prompts that highlight the
> vulnerabilities of LLMs. Our extensive experiments with multiple models, such as Llama 3-Instruct and Llama
> 2-chat, and across various domains, including safety, question answering, and cybersecurity, demonstrate the
> generality of Rainbow Teaming. Moreover, the synthetic data generated through Rainbow Teaming can
> be utilised for fine-tuning LLMs, thereby enhancing their resilience against further adversarial attacks without
> compromising their general performance. This illustrates the potential of Rainbow Teaming as a means for
> the continuous, open-ended self-improvement of LLMs, with minimal human intervention. Future work with
> Rainbow Teaming involves extending its application beyond LLMs to areas such as vision and multi-modal
> AI systems. Moreover, incorporating Rainbow Teaming into the fine-tuning stages of LLM development
> presents an opportunity to consistently strengthen their defences against adversarial attacks.
> 
> 
> We discuss the limitations and broader impact of our work in Appendix A.
> 
> #### **Acknowledgements**
> 
> 
> We extend our gratitude to Alex Havrilla, Robert Kirk, Maya Pavlova, Suyu Ge, Joshua Saxe, and Aaron
> Grattafiori for their insightful discussions and feedback on our work. We also thank Sten Sootla, Lovish
> Madaan, Anthony Hartshorn, Jeremy Reizenstein, and Henry Estela, for their assistance in conducting
> experiments. We extend our deepest gratitude to Nicola Cancedda and Naila Murray for their invaluable
> support and guidance, which were crucial to this work.
> 
> 
> Andrei was partially funded by a _Fonds_ _de_ _recherche_ _du_ _Québec_ doctoral training scholarship.
> 
> #### **References**
> 
> 
> AI@Meta. Llama 3 model card. 2024. [URL https://github.com/meta-llama/llama3/blob/main/MODEL_CARD.md.](https://github.com/meta-llama/llama3/blob/main/MODEL_CARD.md)
> 
> 
> Cem Anil, Esin Durmus, Mrinank Sharma, Joe Benton, Sandipan Kundu, Joshua Batson, Nina Rimsky, Meg Tong,
> Jesse Mu, Daniel Ford, et al. Many-shot jailbreaking, 2024.
> 
> 
> Usman Anwar, Abulhair Saparov, Javier Rando, Daniel Paleka, Miles Turpin, Peter Hase, Ekdeep Singh Lubana, Erik
> Jenner, Stephen Casper, Oliver Sourbut, Benjamin L. Edelman, Zhaowei Zhang, Mario Günther, Anton Korinek,
> Jose Hernandez-Orallo, Lewis Hammond, Eric Bigelow, Alexander Pan, Lauro Langosco, Tomasz Korbak, Heidi
> Zhang, Ruiqi Zhong, Seán Ó hÉigeartaigh, Gabriel Recchia, Giulio Corsi, Alan Chan, Markus Anderljung, Lilian
> Edwards, Yoshua Bengio, Danqi Chen, Samuel Albanie, Tegan Maharaj, Jakob Foerster, Florian Tramer, He He,
> Atoosa Kasirzadeh, Yejin Choi, and David Krueger. Foundational challenges in assuring alignment and safety of
> large language models, 2024.
> 
> 
> Manish Bhatt, Sahana Chennabasappa, Cyrus Nikolaidis, Shengye Wan, Ivan Evtimov, Dominik Gabi, Daniel Song,
> Faizan Ahmad, Cornelius Aschermann, Lorenzo Fontana, Sasha Frolov, Ravi Prakash Giri, Dhaval Kapil, Yiannis
> Kozyrakis, David LeBlanc, James Milazzo, Aleksandar Straumann, Gabriel Synnaeve, Varun Vontimitta, Spencer
> Whitman, and Joshua Saxe. Purple llama cyberseceval: A secure coding benchmark for language models, 2023.
> 
> 
> Varun Bhatt, Bryon Tjanaka, Matthew Fontaine, and Stefanos Nikolaidis. Deep surrogate assisted generation of
> environments. _Advances_ _in_ _Neural_ _Information_ _Processing_ _Systems_, 35:37762–37777, 2022.
> 
> 
> 11
> 
> 
> Herbie Bradley, Andrew Dai, Hannah Teufel, Jenny Zhang, Koen Oostermeijer, Marco Bellagente, Jeff Clune, Kenneth
> Stanley, Grégory Schott, and Joel Lehman. Quality-diversity through ai feedback, 2023.
> 
> 
> Sébastien Bubeck, Varun Chandrasekaran, Ronen Eldan, Johannes Gehrke, Eric Horvitz, Ece Kamar, Peter Lee,
> Yin Tat Lee, Yuanzhi Li, Scott Lundberg, Harsha Nori, Hamid Palangi, Marco Tulio Ribeiro, and Yi Zhang. Sparks
> of artificial general intelligence: Early experiments with gpt-4, 2023.
> 
> 
> Patrick Chao, Alexander Robey, Edgar Dobriban, Hamed Hassani, George J Pappas, and Eric Wong. Jailbreaking
> black box large language models in twenty queries. _arXiv_ _preprint_ _arXiv:2310.08419_, 2023.
> 
> 
> Patrick Chao, Edoardo Debenedetti, Alexander Robey, Maksym Andriushchenko, Francesco Croce, Vikash Sehwag,
> Edgar Dobriban, Nicolas Flammarion, George J Pappas, Florian Tramer, et al. Jailbreakbench: An open robustness
> benchmark for jailbreaking large language models. _arXiv_ _preprint_ _arXiv:2404.01318_, 2024.
> 
> 
> Angelica Chen, David M. Dohan, and David R. So. Evoprompting: Language models for code-level neural architecture
> search, 2023.
> 
> 
> Wei-Lin Chiang, Zhuohan Li, Zi Lin, Ying Sheng, Zhanghao Wu, Hao Zhang, Lianmin Zheng, Siyuan Zhuang, Yonghao
> Zhuang, Joseph E. Gonzalez, Ion Stoica, and Eric P. Xing. Vicuna: An open-source chatbot impressing gpt-4 with
> 90%* chatgpt quality, March 2023. URL [https://lmsys.org/blog/2023-03-30-vicuna/.](https://lmsys.org/blog/2023-03-30-vicuna/)
> 
> 
> Karl Cobbe, Vineet Kosaraju, Mohammad Bavarian, Mark Chen, Heewoo Jun, Lukasz Kaiser, Matthias Plappert,
> Jerry Tworek, Jacob Hilton, Reiichiro Nakano, Christopher Hesse, and John Schulman. Training verifiers to solve
> math word problems, 2021.
> 
> 
> Antoine Cully and Yiannis Demiris. Quality and diversity optimization: A unifying modular framework. _IEEE_
> _Transactions_ _on_ _Evolutionary_ _Computation_, 22(2):245–259, 2018. doi: 10.1109/TEVC.2017.2704781.
> 
> 
> Michael Dennis, Natasha Jaques, Eugene Vinitsky, Alexandre Bayen, Stuart Russell, Andrew Critch, and Sergey
> Levine. Emergent complexity and zero-shot transfer via unsupervised environment design. In _Advances_ _in_ _Neural_
> _Information_ _Processing_ _Systems_, volume 33, 2020.
> 
> 
> Talfan Evans, Shreya Pathak, Hamza Merzic, Jonathan Schwarz, Ryutaro Tanno, and Olivier J Henaff. Bad students
> make great teachers: Active learning accelerates large-scale visual understanding. _arXiv_ _preprint_ _arXiv:2312.05328_,
> 2023.
> 
> 
> Chrisantha Fernando, Dylan Banarse, Henryk Michalewski, Simon Osindero, and Tim Rocktäschel. Promptbreeder:
> Self-referential self-improvement via prompt evolution, 2023.
> 
> 
> Matthew C Fontaine and Stefanos Nikolaidis. Evaluating human–robot interaction algorithms in shared autonomy via
> quality diversity scenario generation. _ACM_ _Transactions_ _on_ _Human-Robot_ _Interaction_ _(THRI)_, 11(3):1–30, 2022.
> 
> 
> Matthew C Fontaine, Ya-Chuan Hsu, Yulun Zhang, Bryon Tjanaka, and Stefanos Nikolaidis. On the importance of
> environments in human-robot coordination. _Robotics:_ _Science_ _and_ _Systems_ _(RSS)_, 2021.
> 
> 
> Deep Ganguli, Liane Lovitt, Jackson Kernion, Amanda Askell, Yuntao Bai, Saurav Kadavath, Ben Mann, Ethan
> Perez, Nicholas Schiefer, Kamal Ndousse, Andy Jones, Sam Bowman, Anna Chen, Tom Conerly, Nova DasSarma,
> Dawn Drain, Nelson Elhage, Sheer El-Showk, Stanislav Fort, Zac Hatfield-Dodds, Tom Henighan, Danny Hernandez,
> Tristan Hume, Josh Jacobson, Scott Johnston, Shauna Kravec, Catherine Olsson, Sam Ringer, Eli Tran-Johnson,
> Dario Amodei, Tom Brown, Nicholas Joseph, Sam McCandlish, Chris Olah, Jared Kaplan, and Jack Clark. Red
> teaming language models to reduce harms: Methods, scaling behaviors, and lessons learned, 2022.
> 
> 
> Suyu Ge, Chunting Zhou, Rui Hou, Madian Khabsa, Yi-Chia Wang, Qifan Wang, Jiawei Han, and Yuning Mao. Mart:
> Improving llm safety with multi-round automatic red-teaming. _arXiv_ _preprint_ _arXiv:2311.07689_, 2023.
> 
> 
> Gemini Team, Rohan Anil, Sebastian Borgeaud, Yonghui Wu, Jean-Baptiste Alayrac, Jiahui Yu, Radu Soricut, Johan
> Schalkwyk, Andrew M. Dai, Anja Hauth, Katie Millican, David Silver, Slav Petrov, Melvin Johnson, Ioannis
> Antonoglou, Julian Schrittwieser, and others. Gemini: A family of highly capable multimodal models, 2023.
> 
> 
> Alex Graves, Marc G Bellemare, Jacob Menick, Remi Munos, and Koray Kavukcuoglu. Automated curriculum learning
> for neural networks. In _international_ _conference_ _on_ _machine_ _learning_, pages 1311–1320. Pmlr, 2017.
> 
> 
> Dan Hendrycks, Collin Burns, Steven Basart, Andy Zou, Mantas Mazeika, Dawn Song, and Jacob Steinhardt. Measuring
> massive multitask language understanding, 2021.
> 
> 
> Dan Hendrycks, Nicholas Carlini, John Schulman, and Jacob Steinhardt. Unsolved problems in ml safety, 2022.
> 
> 
> 12
> 
> 
> Edward Hughes, Michael D Dennis, Jack Parker-Holder, Feryal Behbahani, Aditi Mavalankar, Yuge Shi, Tom Schaul,
> and Tim Rocktäschel. Position: Open-endedness is essential for artificial superhuman intelligence. In _Proceedings_ _of_
> _the_ _41st_ _International_ _Conference_ _on_ _Machine_ _Learning_, volume 235 of _Proceedings_ _of_ _Machine_ _Learning_ _Research_,
> pages 20597–20616. PMLR, 21–27 Jul 2024.
> 
> 
> Hakan Inan, Kartikeya Upasani, Jianfeng Chi, Rashi Rungta, Krithika Iyer, Yuning Mao, Michael Tontchev, Qing Hu,
> Brian Fuller, Davide Testuggine, et al. Llama guard: Llm-based input-output safeguard for human-ai conversations.
> _arXiv_ _preprint_ _arXiv:2312.06674_, 2023.
> 
> 
> Albert Q. Jiang, Alexandre Sablayrolles, Arthur Mensch, Chris Bamford, Devendra Singh Chaplot, Diego de las Casas,
> Florian Bressand, Gianna Lengyel, Guillaume Lample, Lucile Saulnier, Lélio Renard Lavaud, Marie-Anne Lachaux,
> Pierre Stock, Teven Le Scao, Thibaut Lavril, Thomas Wang, Timothée Lacroix, and William El Sayed. Mistral 7b,
> 2023.
> 
> 
> Fengqing Jiang, Zhangchen Xu, Luyao Niu, Zhen Xiang, Bhaskar Ramasubramanian, Bo Li, and Radha Poovendran.
> Artprompt: Ascii art-based jailbreak attacks against aligned llms. _arXiv_ _preprint_ _arXiv:2402.11753_, 2024.
> 
> 
> Minqi Jiang, Michael Dennis, Jack Parker-Holder, Jakob Foerster, Edward Grefenstette, and Tim Rocktäschel.
> Replay-guided adversarial environment design. In _Advances_ _in_ _Neural_ _Information_ _Processing_ _Systems_ . 2021.
> 
> 
> Mandar Joshi, Eunsol Choi, Daniel S. Weld, and Luke Zettlemoyer. Triviaqa: A large scale distantly supervised
> challenge dataset for reading comprehension. In _Proceedings_ _of_ _the_ _55th_ _Annual_ _Meeting_ _of_ _the_ _Association_ _for_
> _Computational_ _Linguistics_, Vancouver, Canada, July 2017. Association for Computational Linguistics.
> 
> 
> Douwe Kiela, Max Bartolo, Yixin Nie, Divyansh Kaushik, Atticus Geiger, Zhengxuan Wu, Bertie Vidgen, Grusha
> Prasad, Amanpreet Singh, Pratik Ringshia, et al. Dynabench: Rethinking benchmarking in nlp. _arXiv_ _preprint_
> _arXiv:2104.14337_, 2021.
> 
> 
> Raz Lapid, Ron Langberg, and Moshe Sipper. Open sesame! universal black box jailbreaking of large language models,
> 2023a.
> 
> 
> Raz Lapid, Ron Langberg, and Moshe Sipper. Open sesame! universal black box jailbreaking of large language models.
> _arXiv_ _preprint_ _arXiv:2309.01446_, 2023b.
> 
> 
> Joel Lehman and Kenneth O Stanley. Abandoning objectives: Evolution through the search for novelty alone.
> _Evolutionary_ _computation_, 19(2):189–223, 2011.
> 
> 
> Joel Lehman, Jonathan Gordon, Shawn Jain, Kamal Ndousse, Cathy Yeh, and Kenneth O. Stanley. Evolution through
> large models, 2022.
> 
> 
> Yunxiang Li, Zihan Li, Kai Zhang, Ruilong Dan, Steve Jiang, and You Zhang. Chatdoctor: A medical chat model
> fine-tuned on a large language model meta-ai (llama) using medical domain knowledge, 2023.
> 
> 
> Chin-Yew Lin and Franz Josef Och. Automatic evaluation of machine translation quality using longest common
> subsequence and skip-bigram statistics. In _Proceedings_ _of_ _the_ _42nd_ _Annual_ _Meeting_ _of_ _the_ _Association_ _for_ _Compu-_
> _tational_ _Linguistics_ _(ACL-04)_, pages 605–612, Barcelona, Spain, July 2004. doi: 10.3115/1218955.1219032. URL
> 
> [https://aclanthology.org/P04-1077.](https://aclanthology.org/P04-1077)
> 
> 
> Xiaogeng Liu, Nan Xu, Muhao Chen, and Chaowei Xiao. Autodan: Generating stealthy jailbreak prompts on aligned
> large language models. _arXiv_ _preprint_ _arXiv:2310.04451_, 2023.
> 
> 
> Mounica Maddela, Megan Ung, Jing Xu, Andrea Madotto, Heather Foran, and Y-Lan Boureau. Training models to
> generate, recognize, and reframe unhelpful thoughts, 2023.
> 
> 
> Natalie Maus, Patrick Chao, Eric Wong, and Jacob R Gardner. Black box adversarial prompting for foundation models.
> In _The_ _Second_ _Workshop_ _on_ _New_ _Frontiers_ _in_ _Adversarial_ _Machine_ _Learning_, 2023.
> 
> 
> Anay Mehrotra, Manolis Zampetakis, Paul Kassianik, Blaine Nelson, Hyrum Anderson, Yaron Singer, and Amin
> Karbasi. Tree of attacks: Jailbreaking black-box llms automatically. _arXiv_ _preprint_ _arXiv:2312.02119_, 2023.
> 
> 
> Bhairav Mehta, Manfred Diaz, Florian Golemo, Christopher J. Pal, and Liam Paull. Active domain randomization. In
> _Proceedings_ _of_ _the_ _Conference_ _on_ _Robot_ _Learning_, 2020.
> 
> 
> Elliot Meyerson, Mark J. Nelson, Herbie Bradley, Adam Gaier, Arash Moradi, Amy K. Hoover, and Joel Lehman.
> Language model crossover: Variation through few-shot prompting, 2023.
> 
> 
> Sören Mindermann, Jan M Brauner, Muhammed T Razzak, Mrinank Sharma, Andreas Kirsch, Winnie Xu, Benedikt
> Höltgen, Aidan N Gomez, Adrien Morisot, Sebastian Farquhar, et al. Prioritized training on points that are learnable,
> 
> 
> 13
> 
> 
> worth learning, and not yet learnt. In _International_ _Conference_ _on_ _Machine_ _Learning_, pages 15630–15649. PMLR,
> 2022.
> 
> 
> MITRE. MITRE ATT&CK - Enterprise Matrix. [https://attack.mitre.org/matrices/enterprise/,](https://attack.mitre.org/matrices/enterprise/) 2024. Accessed:
> 02/02/2024.
> 
> 
> Jean-Baptiste Mouret and Jeff Clune. Illuminating search spaces by mapping elites, 2015.
> 
> 
> NLLB Team, Marta R. Costa-jussà, James Cross, Onur Çelebi, Maha Elbayad, Kenneth Heafield, Kevin Heffernan, Elahe
> Kalbassi, Janice Lam, Daniel Licht, Jean Maillard, Anna Sun, Skyler Wang, Guillaume Wenzek, Al Youngblood, Bapi
> Akula, Loic Barrault, Gabriel Mejia Gonzalez, Prangthip Hansanti, John Hoffman, Semarley Jarrett, Kaushik Ram
> Sadagopan, Dirk Rowe, Shannon Spruit, Chau Tran, Pierre Andrews, Necip Fazil Ayan, Shruti Bhosale, Sergey
> Edunov, Angela Fan, Cynthia Gao, Vedanuj Goswami, Francisco Guzmán, Philipp Koehn, Alexandre Mourachko,
> Christophe Ropers, Safiyyah Saleem, Holger Schwenk, and Jeff Wang. No language left behind: Scaling humancentered machine translation, 2022.
> 
> 
> OpenAI. Gpt-4 technical report, 2023.
> 
> 
> Kishore Papineni, Salim Roukos, Todd Ward, and Wei-Jing Zhu. Bleu: a method for automatic evaluation of machine
> translation. In Pierre Isabelle, Eugene Charniak, and Dekang Lin, editors, _Proceedings_ _of_ _the_ _40th_ _Annual_ _Meeting_
> _of_ _the_ _Association_ _for_ _Computational_ _Linguistics_, pages 311–318, July 2002.
> 
> 
> Jack Parker-Holder, Minqi Jiang, Michael Dennis, Mikayel Samvelyan, Jakob Foerster, Edward Grefenstette, and Tim
> Rocktäschel. Evolving curricula with regret-based environment design, 2022. [URL https://arxiv.org/abs/2203.01302.](https://arxiv.org/abs/2203.01302)
> 
> 
> Ethan Perez, Saffron Huang, Francis Song, Trevor Cai, Roman Ring, John Aslanides, Amelia Glaese, Nat McAleese,
> and Geoffrey Irving. Red teaming language models with language models. _arXiv_ _preprint_ _arXiv:2202.03286_, 2022.
> 
> 
> Justin K Pugh, Lisa B Soros, and Kenneth O Stanley. Quality diversity: A new frontier for evolutionary computation.
> _Frontiers_ _in_ _Robotics_ _and_ _AI_, 3:40, 2016.
> 
> 
> Sharath Chandra Raparthy, Bhairav Mehta, Florian Golemo, and Liam Paull. Generating automatic curricula via
> self-supervised active domain randomization. _CoRR_, abs/2002.07911, 2020. URL [https://arxiv.org/abs/2002.07911.](https://arxiv.org/abs/2002.07911)
> 
> 
> Alexander Robey, Eric Wong, Hamed Hassani, and George J Pappas. Smoothllm: Defending large language models
> against jailbreaking attacks. _arXiv_ _preprint_ _arXiv:2310.03684_, 2023.
> 
> 
> Baptiste Rozière, Jonas Gehring, Fabian Gloeckle, Sten Sootla, Itai Gat, Xiaoqing Ellen Tan, Yossi Adi, Jingyu Liu,
> Tal Remez, Jérémy Rapin, Artyom Kozhevnikov, Ivan Evtimov, Joanna Bitton, Manish Bhatt, Cristian Canton
> Ferrer, Aaron Grattafiori, Wenhan Xiong, Alexandre Défossez, Jade Copet, Faisal Azhar, Hugo Touvron, Louis
> Martin, Nicolas Usunier, Thomas Scialom, and Gabriel Synnaeve. Code llama: Open foundation models for code,
> 2023.
> 
> 
> Mikayel Samvelyan, Akbir Khan, Michael D Dennis, Minqi Jiang, Jack Parker-Holder, Jakob Nicolaus Foerster,
> Roberta Raileanu, and Tim Rocktäschel. MAESTRO: Open-ended environment design for multi-agent reinforcement
> learning. In _International_ _Conference_ _on_ _Learning_ _Representations_, 2023. URL [https://openreview.net/forum?id=](https://openreview.net/forum?id=sKWlRDzPfd7)
> [sKWlRDzPfd7.](https://openreview.net/forum?id=sKWlRDzPfd7)
> 
> 
> Mikayel Samvelyan, Davide Paglieri, Minqi Jiang, Jack Parker-Holder, and Tim Rocktäschel. Multi-agent diagnostics
> for robustness via illuminated diversity. _arXiv_ _preprint_ _arXiv:2401.13460_, 2024.
> 
> 
> L. J. Savage. The theory of statistical decision. _Journal_ _of_ _the_ _American_ _Statistical_ _association_, 1951.
> 
> 
> Timo Schick, Jane Dwivedi-Yu, Roberto Dessì, Roberta Raileanu, Maria Lomeli, Luke Zettlemoyer, Nicola Cancedda,
> and Thomas Scialom. Toolformer: Language models can teach themselves to use tools, 2023.
> 
> 
> Rusheb Shah, Soroush Pour, Arush Tagade, Stephen Casper, Javier Rando, et al. Scalable and transferable black-box
> jailbreaks for language models via persona modulation. _arXiv_ _preprint_ _arXiv:2311.03348_, 2023.
> 
> 
> Chantal Shaib, Joe Barrow, Jiuding Sun, Alexa F. Siu, Byron C. Wallace, and Ani Nenkova. Standardizing the
> measurement of text diversity: A tool and a comparative analysis of scores, 2024. URL [https://arxiv.org/abs/2403.](https://arxiv.org/abs/2403.00553)
> [00553.](https://arxiv.org/abs/2403.00553)
> 
> 
> Karan Singhal, Shekoofeh Azizi, Tao Tu, S. Sara Mahdavi, Jason Wei, Hyung Won Chung, Nathan Scales, Ajay
> Tanwani, Heather Cole-Lewis, Stephen Pfohl, Perry Payne, Martin Seneviratne, Paul Gamble, Chris Kelly, Nathaneal
> Scharli, Aakanksha Chowdhery, Philip Mansfield, Blaise Aguera y Arcas, Dale Webster, Greg S. Corrado, Yossi
> Matias, Katherine Chou, Juraj Gottweis, Nenad Tomasev, Yun Liu, Alvin Rajkomar, Joelle Barral, Christopher
> Semturs, Alan Karthikesalingam, and Vivek Natarajan. Large language models encode clinical knowledge, 2022.
> 
> 
> 14
> 
> 
> Joar Skalse, Nikolaus H. R. Howe, Dmitrii Krasheninnikov, and David Krueger. Defining and characterizing reward
> hacking, 2022.
> 
> 
> Arun James Thirunavukarasu, Darren Shu Jeng Ting, Kabilan Elangovan, Laura Gutierrez, Ting Fang Tan, and
> Daniel Shu Wei Ting. Large language models in medicine. _Nature_ _Medicine_, 29(8):1930–1940, 2023. doi: 10.1038/
> s41591-023-02448-8. URL [https://doi.org/10.1038/s41591-023-02448-8.](https://doi.org/10.1038/s41591-023-02448-8)
> 
> 
> Hugo Touvron, Louis Martin, Kevin Stone, Peter Albert, Amjad Almahairi, Yasmine Babaei, Nikolay Bashlykov,
> Soumya Batra, Prajjwal Bhargava, Shruti Bhosale, Dan Bikel, Lukas Blecher, Cristian Canton Ferrer, Moya Chen,
> Guillem Cucurull, David Esiobu, Jude Fernandes, Jeremy Fu, Wenyin Fu, Brian Fuller, Cynthia Gao, Vedanuj
> Goswami, Naman Goyal, Anthony Hartshorn, Saghar Hosseini, Rui Hou, Hakan Inan, Marcin Kardas, Viktor Kerkez,
> Madian Khabsa, Isabel Kloumann, Artem Korenev, Punit Singh Koura, Marie-Anne Lachaux, Thibaut Lavril,
> Jenya Lee, Diana Liskovich, Yinghai Lu, Yuning Mao, Xavier Martinet, Todor Mihaylov, Pushkar Mishra, Igor
> Molybog, Yixin Nie, Andrew Poulton, Jeremy Reizenstein, Rashi Rungta, Kalyan Saladi, Alan Schelten, Ruan
> Silva, Eric Michael Smith, Ranjan Subramanian, Xiaoqing Ellen Tan, Binh Tang, Ross Taylor, Adina Williams,
> Jian Xiang Kuan, Puxin Xu, Zheng Yan, Iliyan Zarov, Yuchen Zhang, Angela Fan, Melanie Kambadur, Sharan
> Narang, Aurelien Rodriguez, Robert Stojnic, Sergey Edunov, and Thomas Scialom. Llama 2: Open foundation and
> fine-tuned chat models, 2023.
> 
> 
> Alexander Wei, Nika Haghtalab, and Jacob Steinhardt. Jailbroken: How does llm safety training fail?, 2023.
> 
> 
> Jason Wei, Maarten Bosma, Vincent Y. Zhao, Kelvin Guu, Adams Wei Yu, Brian Lester, Nan Du, Andrew M. Dai,
> and Quoc V. Le. Finetuned language models are zero-shot learners, 2022.
> 
> 
> Zheng-Xin Yong, Cristina Menghini, and Stephen H Bach. Low-resource languages jailbreak gpt-4. _arXiv_ _preprint_
> _arXiv:2310.02446_, 2023.
> 
> 
> Jiahao Yu, Xingwei Lin, and Xinyu Xing. Gptfuzzer: Red teaming large language models with auto-generated jailbreak
> prompts. _arXiv_ _preprint_ _arXiv:2309.10253_, 2023.
> 
> 
> Tianyi Zhang, Varsha Kishore, Felix Wu, Kilian Q. Weinberger, and Yoav Artzi. Bertscore: Evaluating text generation
> with bert, 2020.
> 
> 
> Lianmin Zheng, Wei-Lin Chiang, Ying Sheng, Siyuan Zhuang, Zhanghao Wu, Yonghao Zhuang, Zi Lin, Zhuohan Li,
> Dacheng Li, Eric Xing, Hao Zhang, Joseph E. Gonzalez, and Ion Stoica. Judging LLM-as-a-judge with MT-bench and
> chatbot arena. In _Thirty-seventh_ _Conference_ _on_ _Neural_ _Information_ _Processing_ _Systems_ _Datasets_ _and_ _Benchmarks_
> _Track_, 2023. URL [https://openreview.net/forum?id=uccHPGDlao.](https://openreview.net/forum?id=uccHPGDlao)
> 
> 
> Yongchao Zhou, Andrei Ioan Muresanu, Ziwen Han, Keiran Paster, Silviu Pitis, Harris Chan, and Jimmy Ba. Large
> language models are human-level prompt engineers. _arXiv_ _preprint_ _arXiv:2211.01910_, 2022.
> 
> 
> Yaoming Zhu, Sidi Lu, Lei Zheng, Jiaxian Guo, Weinan Zhang, Jun Wang, and Yong Yu. Texygen: A benchmarking
> platform for text generation models. In _The_ _41st_ _international_ _ACM_ _SIGIR_ _conference_ _on_ _research_ _&_ _development_
> _in_ _information_ _retrieval_, pages 1097–1100, 2018.
> 
> 
> Andy Zou, Zifan Wang, J. Zico Kolter, and Matt Fredrikson. Universal and transferable adversarial attacks on aligned
> language models, 2023.
> 
> 
> 15
> 
> 
> #### **A Limitations and Broader Impact**
> 
> Despite many advantages of Rainbow Teaming, its current implementation has several limitations. First,
> the features that define the archive and its categories are pre-defined and fixed. In future work, it would be
> interesting to extend our approach to discover features and categories automatically. Another limitation of
> Rainbow Teaming is that the number of prompts it can generate is constrained by the grid size. While this
> is due to using MAP-Elites as the base QD algorithm, we note that even the current setting allows generating
> hundreds of adversarial prompts from a single run and this can be extended by providing additional features
> or categories or storing several values within the same archive cell.
> 
> 
> Unlike simpler adversarial attack methods (Chao et al., 2023), Rainbow Teaming requires extensive
> computational resources. Furthermore, its undirected, open-ended approach is less likely to produce a prompt
> for a specific behaviour (e.g., writing a fake news article about a specific public figure). While these attributes
> can be considered limitations, we highlight that because of them, Rainbow Teaming is less likely to be used
> for malicious purposes. The primary value of Rainbow Teaming lies in its potential to identify and address
> robustness issues in LLMs, contributing to their responsible development and deployment.
> 
> 
> Ultimately, we believe Rainbow Teaming to be a powerful tool in improving the robustness of LLMs to
> adversarial attacks and see the prompts it generates as a valuable complement to crowd-sourced data.
> 
> #### **B Algorithm Pseudocode**
> 
> 
> **B.1** **MAP-Elites**
> 
> 
> Algorithm 1 provides a pseudocode of MAP-Elites method (Mouret and Clune, 2015) described in Section 2.
> 
> 
> **Algorithm 1:** MAP-Elites (Mouret and Clune, 2015)
> 
> **Input:** fitness function _f_, dimension _K_, feature descriptor function _d_, mutation function _m_, number of seed
> solutions _n_
> **Initialise:** Empty _K_ -dimensional grid of solutions _G_ (the _archive_ ) and grid of fitness scores _F_
> Populate _G_ with _n_ random initial solutions and _F_ with corresponding fitness scores
> **for** _i_ = _{_ 1 _,_ 2 _, . . . }_ **do**
> 
> _x ∼_ _G_ _#_ _Sample_ _a_ _solution_ _x_ _from_ _archive._
> _x_ _[′]_ _←_ _m_ ( _x_ ) _#_ _Create_ _new_ _solution_ _x_ _[′]_ _by_ _mutating_ _x._
> _f_ _[′]_ _←_ _f_ ( _x_ _[′]_ ) _#_ _Compute_ _the_ _fitness_ _score_ _of_ _the_ _new_ _solution_ _x_ _[′]_ _._
> _z_ _[′]_ _←_ _d_ ( _x_ _[′]_ ) _#_ _Get_ _the_ _descriptor_ _of_ _the_ _new_ _solution_ _x_ _[′]_ _._
> **if** _G_ [ _z_ _[′]_ ] = _∅_ _or_ _F_ [ _z_ _[′]_ ] _< f_ _[′]_ **then**
> 
> _#_ _If_ _the_ _corresponding_ _cell_ _is_ _vacant_ _or_ _includes_ _a_ _less_ _effective_ _solution._
> _G_ [ _z_ _[′]_ ] _←_ _x_ _[′]_ _#_ _Update_ _the_ _archive_ _with_ _solution_ _x_ _[′]_ _._
> _F_ [ _z_ _[′]_ ] _←_ _f_ _[′]_ _#_ _Update_ _the_ _fitness_ _score_ _for_ _the_ _new_ _solution._
> **Return:** _G_, _F_
> 
> 
> **B.2** **Rainbow Teaming Pseudocode**
> 
> 
> Algorithm 2 provides a pseudocode of Rainbow Teaming described in Section 3.
> 
> 
> Throughout this work, we use BLEU score (Papineni et al., 2002) as the similarity metric _sim_ . In the safety
> domain, we use the probability of Llama Guard categorising a response as unsafe as the fitness function _f_ .
> The fitness function is used for biasing the sampling of descriptor _d_ but not for updating the archive.
> 
> 
> For clarity, the algorithm shows the Rainbow Teaming loop over a single prompt _x_, but the process can be
> batched to reduce wall clock time. In practice, we use batch sizes between 16 and 64.
> 
> 
> 16
> 
> 
> **Algorithm 2:** Rainbow Teaming
> 
> **Input:** Target _πT_, Mutator _πM_, and Judge _πJ_ LLMs, mutator function _m_, preference model _p_, fitness
> function _f_, similarity function _sim_, similarity threshold _θ_, number of seed prompts _n_, temperature _t_
> **Optional Input:** Existing dataset of prompts _D_
> **Initialise:** Empty _K_ -dimensional grid of adversarial prompts _G_ (the _archive_ ), grid of responses to prompts _R_
> and grid of fitness scores _F_
> **if** _D_ = _∅_ **then**
> 
> Sample _n_ prompts _X_ seed = _{x_ [1] seed _[, . . ., x][n]_ seed _[}]_ [from] _[D]_
> **else**
> 
> Generate _n_ prompts _X_ seed = _{x_ [1] seed _[, . . ., x][n]_ seed _[}]_ [randomly]
> **for** _i_ = _{_ 1 _,_ 2 _, . . . }_ **do**
> 
> **if** _i ≤_ _n_ **then**
> 
> _x_ = _x_ _[i]_ seed _#_ _Sample_ _a_ _prompt_ _x_ _from_ _Xseed._
> **else**
> 
> 
> 
> _x ∼_ _G_ _#_ _Sample_ _a_ _prompt_ _x_ _from_ _archive._
> Sample descriptor _z_ _∈_ N _[K]_, where _p_ ( _z_ ) _∝_ _e_ _[F]_ [ [] _[z]_ []] _[/t]_ _#_ _Bias_ _towards_ _low_ _fitness_ _archive_ _cells._
> _x_ _[′]_ _←_ _x_ _#_ _Initialise_ _the_ _candidate_ _prompt._
> **for** _j_ = _{_ 1 _, . . ., K}_ **do**
> 
> _x_ _[′]_ _←_ _m_ ( _πM_ _, x_ _[′]_ _, z_ [ _j_ ]) _#_ _Apply_ _mutations_ _w.r.t._ _each_ _feature_ _using_ _categories_ _in_ _z._
> **if** _sim_ ( _x, x_ _[′]_ ) _< θ_ **then**
> 
> _r_ _[′]_ _←_ _πT_ ( _x_ _[′]_ ) _#_ _Feed_ _candidate_ _prompt_ _to_ _Target_ _and_ _get_ _a_ _response_ _r_ _[′]_ _._
> **if** _G_ [ _z_ ] = _∅_ **then**
> 
> _#_ _If_ _corresponding_ _cell_ _in_ _archive_ _is_ _empty._
> _G_ [ _z_ ] _←_ _x_ _[′]_ _#_ _Update_ _the_ _archive_ _with_ _prompt_ _x_ _[′]_ _._
> _R_ [ _z_ ] _←_ _r_ _[′]_ _#_ _Update_ _the_ _response_ _for_ _the_ _new_ _prompt._
> _F_ [ _z_ ] _←_ _f_ ( _x_ _[′]_ ) _#_ _Update_ _the_ _fitness_ _score_ _for_ _the_ _new_ _prompt._
> **else**
> 
> 
> 
> _#_ _If_ _corresponding_ _cell_ _in_ _archive_ _is_ _not_ _empty._
> _r_ _←_ _R_ [ _z_ ] _#_ _Get_ _the_ _response_ _to_ _the_ _archive’s_ _prompt_ _with_ _descriptor_ _z._
> **if** _p_ ( _πJ_ _, r_ _[′]_ _, r_ ) **then**
> 
> _#_ _If_ _the_ _preference_ _model_ _concludes_ _that_ _r_ _[′]_ _is_ _more_ _adversarial._
> _G_ [ _z_ ] _←_ _x_ _[′]_ _#_ _Update_ _the_ _archive_ _with_ _prompt_ _x_ _[′]_ _._
> _R_ [ _z_ ] _←_ _r_ _[′]_ _#_ _Update_ _the_ _response_ _for_ _the_ _new_ _prompt._
> _F_ [ _z_ ] _←_ _f_ ( _x_ _[′]_ ) _#_ _Update_ _the_ _fitness_ _score_ _for_ _the_ _new_ _prompt._
> **Return:** _G_, _R_, _F_
> 
> #### **C Extended Related Work**
> 
> 
> **C.1** **Token-Level Attacks**
> 
> 
> Token-level attacks circumvent the LLM’s defences against generating undesirable responses by adding
> adversarial tokens to a malicious prompt. Such methods originally required white-box access to the LLM (Zou
> et al., 2023), but that assumption has since been relaxed using black-box optimisation (Lapid et al., 2023b;
> Maus et al., 2023). Token-level attacks have proven effective, but brittle to perturbations (Robey et al., 2023).
> Although Rainbow Teaming could be adapted to create token-level attacks by integrating the appropriate
> attack categories and prompts, we restrict this study to prompt-level attacks given that prompt-level attacks
> are more interpretable and harder to detect.
> 
> 
> **C.2** **Adversarial Training**
> 
> 
> Rainbow Teaming’s approach parallels other forms of adversarial training, which prioritises training on
> tasks or data points where the model performs poorly. In reinforcement learning (RL), methods such as
> active domain randomisation (Mehta et al., 2020; Raparthy et al., 2020) and regret-based unsupervised
> environment design (Dennis et al., 2020; Jiang et al., 2021; Parker-Holder et al., 2022; Samvelyan et al., 2023)
> 
> 
> 17
> 
> 
> search for training tasks where the agent performs poorly in terms of absolute task performance or regret,
> respectively. Regret-based prioritisation has been shown to hold robustness guarantees at convergence and
> carry the benefit of avoiding unsolvable tasks (which always result in zero regret). The fitness score used by
> Rainbow Teaming coincides with regret (Savage, 1951), as a high fitness here implies the existence of another
> prompt that elicits a less undesirable response, as evaluated by the Judge. Similarly, many active learning
> and automatic curriculum learning methods in supervised learning focus training on examples maximising
> error metrics derived from the model’s predictions (Graves et al., 2017; Mindermann et al., 2022; Evans et al.,
> 2023). Dynabench (Kiela et al., 2021) extends this paradigm by querying humans-in-the-loop for adversarial
> examples. Many methods in scenario generation also closely relate to Rainbow Teaming, including recent
> approaches using QD search to find adversarial environments that induce poor behaviour in fully-automated
> or mixed-autonomy systems (Fontaine et al., 2021; Fontaine and Nikolaidis, 2022; Bhatt et al., 2022). This
> extends to recent work applying QD to multi-agent RL (Samvelyan et al., 2024), which inspired our method.
> 
> #### **D Adversarial Prompts as Stepping Stones**
> 
> 
> Figure 7 provides a qualitative example of how the directed mutation in Rainbow Teaming can produce
> diverse adversarial prompts from a single common ancestor.
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> **Figure 7** An illustrative example of how a single parent prompt can yield diverse successor adversarial prompts. Here,
> akin to Figure 2, the candidate’s feature descriptor corresponds to “Criminal Planning” and “Role Play” categories.
> With dashed lines, we show other hypothetical mutation paths corresponding to different feature descriptors.
> 
> #### **E Additional Results**
> 
> 
> **E.1** **Varying Model Sizes**
> 
> 
> Figure 8 presents the ASR of Rainbow Teaming when applied to Llama 2-chat models with 7B, 13B, and
> 70B parameters across 2000 iterations, using GPT-4 and Llama Guard for evaluation. Archives generated
> through Rainbow Teaming demonstrate 90% or higher ASR across all model sizes, as measured using
> GPT-4 and Llama Guard evaluators.
> 
> 
> 18
> 
> 
> 0 500 1000 1500 2000
> Iterations
> 
> 
> 
> 
> 
> 1.0
> 
> 
> 0.8
> 
> 
> 0.6
> 
> 
> 0.4
> 
> 
> 0.2
> 
> 
> 0.0
> 
> 
> 
> 0 500 1000 1500 2000
> Iterations
> 
> 
> 
> 1.0
> 
> 
> 0.8
> 
> 
> 0.6
> 
> 
> 0.4
> 
> 
> 0.2
> 
> 
> 0.0
> 
> 
> 
> 
> 
> 
> 
> **Figure 8** Attack success rate of adversarial prompts discovered by Rainbow Teaming on Llama 2-chat 7B, 13B, and
> 70B, as measured by GPT-4 and Llama Guard. We report the mean and standard error over 3 independent runs.
> 
> 
> **E.2** **Role of System Prompts**
> 
> 
> While our main experiments provide the prompts to the Target as is (within appropriate instruction tokens),
> we additionally analyse incorporating two _system_ _prompts_ . The _legacy_ system prompt is designed to emphasise
> both _safety_ _and_ _helpfulness_ . [4] The _helpful_ system prompt is a handcrafted variant of the legacy prompt that
> focuses on helpfulness without explicitly emphasising safety. All system prompts are provided in Appendix I.3.
> 
> 
> **Table 7** Attack success rate against Llama 2-chat 7B model with different system prompts. “Legacy” is an original
> Llama 2-chat system prompt that explicitly promotes safety, but was deprecated as it results in a high false refusal
> rate (Touvron et al., 2023). Nonetheless, it makes the model significantly more robust, supporting the idea that system
> prompts are an imperfect but low-effort defence mechanism against adversarial attacks.
> 
> 
> System Prompt
> Evaluator No System Prompt Helpful Legacy
> GPT-4 0 _._ 92 _±_ 0 _._ 008 0 _._ 82 _±_ 0 _._ 029 0 _._ 51 _±_ 0 _._ 016
> Llama Guard 0 _._ 95 _±_ 0 _._ 005 0 _._ 93 _±_ 0 _._ 012 0 _._ 74 _±_ 0 _._ 009
> 
> 
> The effectiveness of Rainbow Teaming when using these different system prompts is presented in Table 7.
> Our results indicate the inclusion of a system prompt emphasising safety diminishes the success rate of
> adversarial attacks to 51% / 74%, according to GPT-4 and Llama Guard evaluations, respectively. However,
> using this system prompt makes the model overly conservative, occasionally refusing to answer benign questions
> that appear unsafe. On the other hand, the helpful system prompt, remains vulnerable to attacks, with 82% /
> 93% ASR, yet still offers improved robustness compared to not using a system prompt at all, which sees 92%
> / 95% ASR. The Llama 2-chat 7B model has been safety-aligned regardless of the system prompt, but its
> robustness is highly dependent on this variable.
> 
> 
> **E.3** **Human Evaluation**
> 
> 
> Table 8 shows the ASR of 100 prompts, as evaluated by GPT-4, Llama Guard and human annotators. The
> inter-evaluator agreement is also provided.
> 
> 
> 4It was initially released with Llama 2 but has since been deprecated due to its high false refusal rate. See the change [here.](https://github.com/facebookresearch/Llama/commit/a971c41bde81d74f98bc2c2c451da235f1f1d37c)
> 
> 
> 19
> 
> 
> **Table 8** Attack success rate according to different evaluators and inter-evaluator agreement on 100 (prompt, response)
> pairs. Results are aggregated over 4 human annotators. Human-AI agreement matches inter-human agreement,
> indicating that GPT-4 and Llama Guard evaluations are a good proxy for human evaluations. Starred scores ( _[∗]_ ) are
> consistent with Zheng et al. (2023).
> 
> |Attack Success Rate|Agreement<br>Llama Guard Human|
> |---|---|
> |GPT-4<br>0_._66<br>Llama Guard<br>0_._77<br>Human<br>0_._70_ ±_ 0_._06|0_._79<br>_∗_0_._81_ ±_ 0_._02<br>0_._78_ ±_ 0_._03<br>_∗_0_._83_ ±_ 0_._02|
> 
> 
> 
> The 100 prompts were randomly sampled from a combination of archives targeting Llama 2-chat 7B or 70B,
> using either no system prompt or the Legacy prompt. This was done to ensure sufficient prompt variety. The
> annotations were done within a single session by four of the authors following the same harm taxonomy as
> Llama Guard. The annotators were not informed of the data mix or the expected ASR as evaluated by either
> Llama Guard or GPT-4 at the time of annotation to mitigate bias. All annotations were performed through
> an interactive spreadsheet, where authors tick a checkbox to label the model response as “GOOD BOT” (when
> the target model refused to answer or answered in a safe manner) or “BAD BOT” (when the model answered
> in a way that is violating according to the harm taxonomy).
> 
> 
> **E.4** **Preference Model Ablation**
> 
> 
> We investigate the role of the preference model used for Rainbow Teaming. One option is to prompt an
> LLM to act as a pairwise comparison Judge (Zheng et al., 2023). The Judge takes as input the response to
> the candidate prompt and the response to the prompt already in the archive, and is instructed to say which of
> the two is more harmful. As recommended by Zheng et al. (2023), we use position swapping (evaluating twice
> for each order of the prompt-response pairs) to reduce positional bias, and few-shot prompting to improve
> consistency. We refer to this variant as “Comparison-based (Judge)” and use it as default throughout the
> paper.
> 
> 
> We compare the default version of Rainbow Teaming with a variant that uses the Llama Guard probability
> of classifying the response as “unsafe” as a preference model. In this case, we perform an archive substitution
> if the probability for the candidate response is higher than that of the existing response. We refer to this
> Rainbow Teaming variant as “Score-based (No Judge)”.
> 
> 
> In our evaluation, as shown in Figure 9, the score-based baseline achieves a higher Llama Guard-evaluated
> ASR, aligning with its optimisation objective. However, it falls short in GPT-4-evaluated ASR, suggesting
> overfitting to Llama Guard scores, indicative of reward hacking (Skalse et al., 2022). Qualitatively, we find
> that the adversarial prompts produced by the score-based method are also of lower quality. We also show the
> number of archive updates for the two variations of Rainbow Teaming. We observe that the No Judge
> baseline quickly maximising the Llama Guard score (capped to 1 _._ 0) leads to sparse updates thereafter. In
> contrast, the Judge-based variant continues to refine the _quality_ of the adversarial prompts in the archive,
> indicated by ongoing archive updates, even after filling the archive with successful prompts. This underscores
> the advantage of Rainbow Teaming’s open-ended search process over a purely score-driven approach.
> 
> 
> Note that the performance differences between Rainbow Teaming results here and in other parts of the
> manuscript arise from variations in the experimental setup. In this specific experiment, we use Anthropic
> Harmless as the seed dataset with slightly different mutation prompts, and two risk category names have
> been updated.
> 
> 
> **E.5** **Full Evaluations**
> 
> 
> Figure 10 presents the ASR of Rainbow Teaming when applied to Llama 2-chat 7B (Touvron et al., 2023),
> Llama 3-Instruct 8B (AI@Meta, 2024), Mistral 7B (Jiang et al., 2023) and Vicuna 7B v1.5 (Chiang et al.,
> 2023) models across 2000 iterations, using both GPT-4 and Llama Guard for evaluation. Figure 11 shows the
> 
> 
> 20
> 
> 
> 1.0
> 
> 0.8
> 
> 0.6
> 
> 0.4
> 
> 0.2
> 
> 0.0
> 
> 
> 
> Iterations
> 
> 
> 
> 1.0
> 
> 0.8
> 
> 0.6
> 
> 0.4
> 
> 0.2
> 
> 0.0
> 
> 
> 
> Iterations
> 
> 
> 
> 5000
> 
> 4000
> 
> 3000
> 
> 2000
> 
> 1000
> 
> 0
> 
> 
> 
> Iterations
> 
> 
> 
> **Figure** **9** Comparison of Rainbow Teaming with a pairwise comparison (Judge) and a score-based (No Judge)
> preference models applied to Llama 2-chat 7B. Left: ASR as evaluated by GPT-4. Centre: ASR as evaluated by Llama
> Guard. Right: total archive updates over time. The score-based baseline reward hacks the Llama Guard score and
> underperforms under GPT-4 evaluation. It also stops updating the archive after saturating the Llama Guard score,
> whereas the comparison method Rainbow Teaming performs a more open-ended search.
> 
> 
> 
> 0 500 1000 1500 2000
> Iterations
> 
> 
> 
> 
> 
> 1.0
> 
> 
> 0.8
> 
> 
> 0.6
> 
> 
> 0.4
> 
> 
> 0.2
> 
> 
> 0.0
> 
> 
> 
> 0 500 1000 1500 2000
> Iterations
> 
> 
> 
> 1.0
> 
> 
> 0.8
> 
> 
> 0.6
> 
> 
> 0.4
> 
> 
> 0.2
> 
> 
> 0.0
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> **Figure 10** Attack success rate of adversarial prompts discovered by Rainbow Teaming on various models, as measured
> by GPT-4 and Llama Guard. We report the mean and standard error over 3 independent runs.
> 
> 
> performance of Rainbow Teaming against No Stepping Stones and Same Cell Mutations baselines, using
> GPT-4 and Llama Guard for evaluations. In Figure 12 we report the performance of our approach targeting
> Llama 2-chat 7B model before and after performing SFT on Rainbow Teaming-generated data.
> 
> 
> **E.6** **Archive Visualisation**
> 
> 
> Figure 13 illustrates examples archives at various iterations of Rainbow Teaming generated in the safety
> domain. Figure 14 shows 2D projections of 3D archives of Rainbow Teaming at different iterations when
> applied in the question answering domain.
> 
> 
> **E.7** **Question Answering Examples**
> 
> 
> Table 9 provides sample questions generated by Rainbow Teaming for the question answering domain.
> 
> 
> 21
> 
> 
> 0 500 1000 1500 2000
> Iterations
> 
> 
> 
> 
> 
> 1.0
> 
> 
> 0.8
> 
> 
> 0.6
> 
> 
> 0.4
> 
> 
> 0.2
> 
> 
> 0.0
> 
> 
> 
> 0 500 1000 1500 2000
> Iterations
> 
> 
> 
> 1.0
> 
> 
> 0.8
> 
> 
> 0.6
> 
> 
> 0.4
> 
> 
> 0.2
> 
> 
> 0.0
> 
> 
> 
> 
> 
> 
> 
> **Figure 11** Attack success rate of adversarial prompts discovered by Rainbow Teaming and baselines against Llama
> 2-chat 7B model, as measured by GPT-4 and Llama Guard. We report the mean and standard deviation over 3
> independent runs.
> 
> 
> **Figure 12** Attack success rate before and after fine-tuning Llama 2-chat 7B on synthetic data generated via Rainbow
> Teaming. The fine-tuned model is significantly less vulnerable to Rainbow Teaming on a second application, with
> the method achieving a substantially lower ASR after 2000 iterations. We report the mean and standard error over 3
> independent runs.
> 
> 
> **Table 9** Sample questions generated by Rainbow Teaming for the question answering domain, complete with Target
> (Llama 2-chat 7B) and Oracle (Llama 2-chat 70B) responses. All three examples have a fitness of 1.
> 
> 
> 
> 
> 
> |Question|Target|Oracle|
> |---|---|---|
> |What was the name of the ship in the<br>novel "Moby-Dick"?|USS Enterprise|Pequod|
> |When was the largest living organism<br>in the world, which is a type of fungus,<br>frst discovered in Oregon?|1860s|1998|
> |Where was the famous equation that<br>measures the strength of a celestial<br>body’s gravitational pull frst proposed?|Galileo|Cambridge|
> 
> 
> 22
> 
> 
> **(a)** Before SFT, 50 iterations. **(b)** After SFT, 50 iterations.
> 
> 
> **(c)** Before SFT, 300 iterations. **(d)** After SFT, 300 iterations.
> 
> 
> **(e)** Before SFT, 2000 iterations. **(f)** After SFT, 2000 iterations.
> 
> 
> **Figure 13** Sample archive (single seed) snapshots after 50 (top), 300 (middle) and 2000 (bottom) iterations of Rainbow
> Teaming in the safety domain. The left column uses Llama 2-chat 7B as the Target, while the right column uses the
> same model but after fine-tuning on data generated by Rainbow Teaming.
> 
> 
> 23
> 
> 
> **(a)** Rainbow Teaming
> 
> 
> **(b)** Baseline (No Stepping Stones)
> 
> 
> **Figure 14** 2D projections of a 3D archive for the question answering domain for (a) Rainbow Teaming and (b) the
> generative baseline (no stepping stones). Scores are averaged across the collapsed dimensions. The generative baseline
> achieves a significantly lower coverage, particularly in low-length bins.
> 
> #### **F Additional Details for Preference Models**
> 
> 
> **F.1** **Question Answering**
> 
> 
> The preference model used in question answering domain differs from that used in Section 4 to account for
> the difficulty of evaluating the relative correctness of responses to two different questions. For each question _q_,
> we generate an answer _rt_ from the Target and another _ro_ from an _Oracle_ LLM.
> 
> 
> While both the Oracle and Target models receive identical prompts, the Oracle is equipped with superior
> capabilities (Llama 2-chat 70B) compared to the Target (Llama 2-chat 7B). We then provide the question _q_
> alongside both answers _rt_ and _ro_ to the Judge to determine whether the question is factual and objective
> and whether the Oracle’s answer is better than the Target’s answer. If these conditions are met, we save the
> question to the archive with fitness 1. If not, but the archive cell is empty, we save the question with a fitness
> of 0 _._ 1 to act as a stepping stone. We discard the question in all other scenarios.
> 
> 
> **F.2** **Cybersecurity**
> 
> 
> When using Rainbow Teaming in the cybersecurity domain, we use a binary Judge mechanism to evaluate
> the potential maliciousness of generated prompts. This is aligned with the framework outlined by Bhatt
> et al. (2023), which leverages two distinct LLMs for classifying the output of an LLM as either “benign” or
> “malicious”. For the initial processing of the output, we use the Llama 2-chat 70B model, which is responsible
> for preliminary analysis and identification of potentially malicious content. The final decision of whether a
> response is indeed malicious is then made by the CodeLlama-34B Instruct model (Rozière et al., 2023).
> 
> 
> 24
> 
> 
> #### **G Inference Cost Analysis**
> 
> Since inference costs vary based on infrastructure, the number of generation tokens, and specific LLMs used,
> we choose to discuss computational costs in terms of LLM inference calls. For the majority of our experiments,
> one Rainbow Teaming loop requires 2 Mutator inference calls, 1 Target inference call, and 4 Judge inference
> calls, where every inference call corresponds to a batch of prompts (our batch size is 16 for most experiments,
> except 64 for our JailbreakBench ones). When running for 2000 iterations, this represents a total of 14000
> batched inference calls per run.
> 
> 
> We conducted our experiments on a cluster of A100 GPUs, with access ranging from 128 to 256 GPUs
> throughout the project. Each run was typically completed in around two days, though we often accelerated
> them significantly by leveraging a distributed client-server setup for parallelised LLM inference.
> 
> 
> Although the computational cost is substantial, we believe the effectiveness and diversity of the resulting
> prompts make our method a highly competitive alternative to crowd-sourced data.
> 
> 
> Depending on the user’s needs, costs can be further amortised by leveraging earlier Rainbow Teaming
> checkpoints as a source of additional prompts, potentially expanding the final dataset size by an order of
> magnitude. As LLMs become more powerful, so do the components of our method. For example, if an LLM
> can serve as an accurate judge in a single inference call, this could significantly reduce the inference cost
> associated with the Judge.
> 
> #### **H Feature Descriptors**
> 
> 
> **H.1** **Safety**
> 
> 
> **Risk Category**
> 
> 
>   - Violence and Hate
> 
> 
>   - Sexual Content
> 
> 
>   - Criminal Planning
> 
> 
>   - Guns and Illegal Weapons
> 
> 
>   - Regulated or Controlled Substances
> 
> 
>   - Self-Harm
> 
> 
>   - Inciting or Abetting Discrimination
> 
> 
>   - Fraud and Scams
> 
> 
>   - Cybercrime and Hacking
> 
> 
>   - Terrorism
> 
> 
> **Attack Style**
> 
> 
>   - Slang
> 
> 
>   - Technical Terms
> 
> 
>   - Role Play
> 
> 
>   - Authority Manipulation
> 
> 
>   - Misspellings
> 
> 
>   - Word Play
> 
> 
>   - Emotional Manipulation
> 
> 
> 25
> 
> 
>   - Hypotheticals
> 
> 
>   - Historical Scenario
> 
> 
>   - Uncommon Dialects
> 
> 
> **H.2** **Question Answering**
> 
> 
> **Topic**
> 
> 
>   - Science and Technology
> 
> 
>   - Health and Wellness
> 
> 
>   - History and Culture
> 
> 
>   - Arts and Entertainment
> 
> 
>   - Nature and Environment
> 
> 
>   - Travel and Geography
> 
> 
>   - Society and Politics
> 
> 
>   - Education and Learning
> 
> 
>   - Food and Cooking
> 
> 
>   - Relationships and Life
> 
> 
> **Question Length** (measured in number of characters)
> 
> 
>   - Min: 24
> 
> 
>   - Max: 96
> 
> 
>   - Number of bins: 10
> 
> 
> **Interrogative Word**
> 
> 
>   - Where
> 
> 
>   - Who
> 
> 
>   - What
> 
> 
>   - When
> 
> 
> **H.3** **Cybersecurity**
> 
> 
> **MITRE attack tactics**
> 
> 
>   - Reconnaissance
> 
> 
>   - Discovery
> 
> 
>   - Execution
> 
> 
>   - Privilege Escalation
> 
> 
>   - Persistence
> 
> 
>   - Defense Evasion
> 
> 
>   - Lateral Movement
> 
> 
>   - Collection
> 
> 
> 
> 26
> 
> 
>   - Command and Control
> 
> 
>   - Exfiltration
> 
> 
> **Instruction Length** (measured in number of characters)
> 
> 
>   - Min: 100
> 
> 
>   - Max: 1000
> 
> 
>   - Number of bins: 10
> 
> #### **I Safety Experiment Prompts**
> 
> 
> This section includes various prompts used in experiments in the safety domain.
> 
> 
> 
> 27
> 
> 
> **I.1** **Llama Guard Evaluation Prompt**
> 
> 
> For Llama Guard evaluations, we use the default system prompts by Inan et al. (2023) for 6 original categories.
> For the 4 new categories, similar system prompts have been generated by the authors.
> 
> 
> **I.2** **Mutation Prompts**
> 
> 
> We have elected not to share mutation prompts to prevent misuse.
> 
> 
> **I.3** **System Prompt of Target LLM**
> 
> 
> Below are the prompts given to the Target Llama 2-chat model in our experiments with various system
> prompts presented in Appendix E.2. Here the {input} is replaced with adversarial prompts.
> 
> 
> 
> 
> 
> 
> 
> 28
> 
> 
> #### **J Question Answering Experiment Prompts**
> 
> This section includes prompts used in the question answering experiments.
> 
> 
> 
> 
> 
> 
> 
> 29
> 
> 
> 30
> 
> 
> #### **K Hyperparameters**
> 
> Tables 10, 11, and 12 provide the hyperparameters used in safety, question answering, and cybersecurity
> domains, respectively.
> 
> 
> **Table 10** List of hyperparameters used in safety experiments.
> 
> 
> 
> 
> 
> |Experiments|Hyperparameter Value|
> |---|---|
> |Rainbow Teaming|Number of Initial Examples<br>0<br>Batch Size<br>32<br>Iterations<br>2000<br>BLEU Similarity Filter<br>0_._6<br>Archive Sampling Temperature<br>0_._1<br>Archive Size<br>100|
> |Generator Parameters|Temperature<br>0_._7<br>Top-k<br>0_._95<br>Maximum Tokens<br>256|
> |SFT|Learning Rate<br>2_e −_7<br>Batch Size<br>32<br>Learning Rate Scheduler<br>Constant<br>Sequence Length<br>4096|
> 
> 
> 31
> 
> 
> **Table 11** List of hyperparameters used in question answering experiments.
> 
> 
> 
> 
> 
> 
> |Experiments|Hyperparameter Value|
> |---|---|
> |Rainbow Teaming|Number of Initial Examples<br>256<br>Dataset of Initial Examples<br>TriviaQA (Joshi et al., 2017)<br>Batch Size<br>32<br>Iterations<br>1000<br>BLEU Similarity Filter<br>0_._6<br>Archive Sampling Temperature<br>0_._1<br>Archive Size<br>100|
> |Generator Parameters|Temperature<br>0_._7<br>Top-k<br>0_._95<br>Maximum Tokens<br>256|
> 
> 
> 
> **Table 12** List of hyperparameters used in cybersecurity experiments.
> 
> 
> 
> 
> 
> |Experiments|Hyperparameter Value|
> |---|---|
> |Rainbow Teaming|Number of Initial Examples<br>16<br>Dataset of Initial Examples<br>CyberSecEval (Bhatt et al., 2023)<br>Batch Size<br>32<br>Iterations<br>200<br>BLEU Similarity Filter<br>0_._6<br>Archive Sampling Temperature<br>0_._1<br>Archive Size<br>100|
> |Generator Parameters|Temperature<br>0_._7<br>Top-k<br>0_._95<br>Maximum Tokens<br>256|
> 
> 
> 32
> 
> 
> 
> [Source: Rainbow Teaming: Open-Ended Generation of Diverse Adversarial Prompts](https://arxiv.org/abs/2402.16822)
