---
created: 2026-03-22
description: AgentFrontier operationalizes the Zone of Proximal Development for LLM training by using an LKP-MKO adversarial calibration pipeline to synthesize frontier-level reasoning data that maximally improves agent capabilities.
source: https://arxiv.org/abs/2507.16530
type: paper
---

## Key Takeaways

AgentFrontier translates the Zone of Proximal Development (ZPD) from educational psychology into a concrete data synthesis framework for LLM agents. The core mechanism is an adversarial calibration between two personas: a Less Knowledgeable Peer (LKP, the base model without tools) and a More Knowledgeable Other (MKO, the same model augmented with search, scholar, browser, and code tools). Training data that the LKP cannot solve but the MKO can is, by definition, at the model's capability frontier -- the LLM analogue of what [[PAIRED uses antagonist regret to auto-generate perfectly calibrated training environments|PAIRED]]'s regret mechanism identifies as the zone where learning is maximally informative.

The three-stage pipeline is: (1) generate seed questions from composite units of thematically related document chunks, forcing knowledge fusion across sources; (2) iteratively escalate complexity through an agentic refinement loop with tool access; (3) filter through the LKP-MKO calibration to isolate ZPD-appropriate data. Questions solvable by the LKP go to continued pre-training; questions solvable by the MKO but not the LKP become post-training data; questions neither can solve go to human review. This tripartite partition is reminiscent of how [[PLR improves RL generalization by prioritizing training levels with high estimated learning potential|PLR]] bins levels into easy (low value loss), frontier (high value loss), and too-hard (no signal) categories.

The results are impressive: AgentFrontier-30B-A3B achieves 28.6% on Humanity's Last Exam (text-only), surpassing many proprietary agents. The ZPD Exam benchmark they introduce is designed to be a living benchmark that co-evolves with model capabilities, categorizing performance into three zones that directly correspond to the ZPD framework. The key finding is that access to tools is necessary but insufficient -- the bottleneck is the agent's meta-cognitive ability to orchestrate tools strategically, not the tools themselves.

The connection to curriculum calibration is direct: just as [[ACCEL compounds environment complexity through evolution guided by regret-based curation|ACCEL]] evolves environments to stay at the frontier of RL agent capabilities, AgentFrontier's iterative refinement escalates question complexity to stay at the frontier of LLM capabilities. The LKP-MKO pair functions analogously to PAIRED's protagonist-antagonist pair, with the critical difference that in AgentFrontier the "antagonist" (MKO) is a strictly more capable version of the protagonist rather than a separate agent trained in parallel. This sidesteps the multi-agent convergence issues that plague PAIRED.

The cost analysis is revealing: approximately $0.78 per verified PhD-level QA pair, with 33% of candidates passing MKO verification. This quantifies the "tax" of frontier-calibrated data synthesis and highlights why approaches like [[AgentGen creates diverse planning environments with bidirectional task evolution for LLM agent training|AgentGen]]'s more lightweight generation methods remain valuable for lower-capability-level training.

The paper's emphasis on knowledge fusion -- synthesizing insights across multiple documents rather than single-document comprehension -- pushes beyond what standard RAG evaluates. This cross-document reasoning requirement connects to the compositional challenges addressed by [[Voyager]] and [[SkillRL]], where combining simpler capabilities into novel configurations is the key to advancing agent capability.

## External Resources

- [Project page](https://tongyi-agent.github.io/blog) -- AgentFrontier project blog
- [Code repository](https://github.com/Alibaba-NLP/DeepResearch) -- Open source implementation

## Original Content

> [!quote]- Full Paper Text
> 2025-10-29
> 
> ## **AgentFrontier: Expanding the Capability Frontier of** **LLM Agents with ZPD-Guided Data Synthesis**
> 
> 
> Xuanzhong Chen _[∗]_, Zile Qiao _[∗]_ [(] [�] [)], Guoxin Chen, Liangcai Su, Zhen Zhang, Xinyu Wang, Pengjun
> Xie, Fei Huang, Jingren Zhou, Yong Jiang [(] [�] [)]
> 
> 
> Tongyi Lab, Alibaba Group
> 
> ```
>          https://tongyi-agent.github.io/blog
> 
>          https://github.com/Alibaba-NLP/DeepResearch
> 
> ```
> 
> **Abstract**
> 
> 
> Training large language model agents on tasks at the frontier of their capabilities is key to unlocking advanced reasoning. We introduce a data synthesis
> approach inspired by the educational theory of the _Zone of Proximal Development_
> (ZPD), which defines this frontier as tasks an LLM cannot solve alone but can
> master with guidance. To operationalize this, we present the **AgentFrontier**
> **Engine**, an automated pipeline that synthesizes high-quality, multidisciplinary
> data situated precisely within the LLM’s ZPD. This engine supports both continued pre-training with knowledge-intensive data and targeted post-training
> on complex reasoning tasks. From the same framework, we derive the **ZPD**
> **Exam**, a dynamic and automated benchmark designed to evaluate agent capabilities on these frontier tasks. We train **AgentFrontier-30B-A3B** model on our
> synthesized data, which achieves state-of-the-art results on demanding benchmarks like Humanity’s Last Exam, even surpassing some leading proprietary
> agents. Our work demonstrates that a ZPD-guided approach to data synthesis
> offers a scalable and effective path toward building more capable LLM agents.
> 
> 
> 
> Humanity's Last Exam (Text-only)
> 
> 
> 
> 0 20 40 60 80 100
> 
> 
> (b) ZPD Exam-v1 Results.
> 
> 
> 
> ZPD Exam-v1
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
> 0 5 10 15 20 25 30
> 
> 
> (a) Humanity’s Last Exam (Text-only) Results.
> 
> 
> 
> Figure 1: Performance of LLM agents on the text-only HLE text-only set and ZPD Exam-v1.
> 
> 
> _∗_ Equal Core Contributors. xuanzhchen@gmail.com, qiaozile.qzl@alibaba-inc.com
> 
> - Corresponding author. {qiaozile.qzl, yongjiang.jy}@alibaba-inc.com
> 
> 
> 1
> 
> 
> **1** **Introduction**
> 
> 
> Large language models (LLMs) have demonstrated impressive proficiency on various fundamental
> reasoning tasks (Rein et al., 2023; Wang et al., 2024; Tian et al., 2024). However, they still struggle
> with the scenarios demanding in-depth, cross-domain, and integrative reasoning (Mialon et al., 2023;
> Wei et al., 2025; Phan et al., 2025). This gap presents a critical impediment in the pursuit of artificial
> general intelligence (AGI). Achieving such a leap requires LLMs to move beyond internal knowledge
> toward agentic behavior, encompassing tool using (Qin et al., 2024), self-reflection (Shinn et al., 2023),
> iterative planning, and multi-step reasoning. The development of such abilities is slowed by the deficit in
> existing training corpora, which provide little systematic support for cultivating these agentic skills in a
> unified manner (Shi et al., 2025). Besides the scarcity of high-quality training resources, progress is further
> constrained by the saturation of existing benchmarks and the absence of scalable methods for synthesizing
> challenging data that reflects the frontiers of human knowledge. While expert-crafted evaluations such
> as _Humanity’s Last Exam_ (Phan et al., 2025) offer invaluable benchmarks, their prohibitive cost and lack of
> scalability underscore the urgent need for automated, frontier-level data synthesis pipelines.
> 
> 
> Recent datasets have significantly enhanced LLMs’ single-step reasoning (Liu et al., 2025), but they
> seldom target the deeper challenge of **knowledge fusion** (Wan et al., 2024): integrating and transforming
> information across diverse sources. While retrieval-augmented generation (RAG) (Lewis et al., 2020)
> excels when the answer can be grounded in a single document, its performance degrades on tasks
> requiring reasoning across heterogeneous information. This deficiency traces back to the dominant
> data-synthesis paradigms, which fall into two broad categories: query-centric methods (Yan et al., 2025)
> that generate variations of existing question–answer (QA) pairs, and document-centric methods (Fan
> et al., 2025; Yuan et al., 2025) that derive document-grounded QA pairs from the corpus. Both approaches
> primarily assess localized comprehension, akin to examining a student on individual textbook chapter
> rather than their ability to synthesize insights across an entire curriculum. In contrast, complex realworld tasks such as academic research, legal analysis, or engineering design demand multi-document
> synthesis and cross-domain knowledge fusion. Human experts rarely treat information in isolation;
> instead, they connect, contrast, and integrate it to derive in-depth insights, which is the intrinsic essence
> of **deep research** (OpenAI, 2025a; Google, 2025). Cultivating this synthetic reasoning capacity in LLMs is
> 
> 
> erating difficult tasks, but calibrating their difficulty to the
> 
> yet solvable with appropriate support. Existing approaches
> typically rely on coarse-grained difficulty annotations (Su
> 
> tier. In practice, self-generated approaches tend to yield data
> that remain within the model’s own expressive ceiling, mak
> concept of the _**Zone of Proximal Development**_ (ZPD) (Vygotsky, 1978; McLeod, 2012), which defines the cognitive space Figure 2: High-quality data situated in an
> where a learner cannot solve tasks independently but can LLM’s ZPD acts as a catalyst, transformsucceed with guidance. We operationalize this by defining ing it from a LKP into a MKO.
> two personas: the **Less Knowledgeable Peer** (LKP), a base
> LLM without tools, and the **More Knowledgeable Other** (MKO), a superior tool-augmented agent with
> advanced reasoning. Training data unsolvable by the LKP but solvable by the MKO is by definition
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
> Figure 2: High-quality data situated in an
> LLM’s ZPD acts as a catalyst, transforming it from a LKP into a MKO.
> 
> 
> 
> 2
> 
> 
> situated at the model’s capability frontier, offering maximally informative supervision. As the model
> learns, its ZPD advances, enabling a continuously adaptive curriculum.
> 
> 
> Collectively, we instantiate this principle in the **AgentFrontier Engine**, a novel data synthesis framework
> designed to automatically generate complex-reasoning data within LLM’s ZPD. The engine operates
> through a process of adversarial calibration, dynamically probing the capability frontier of the LLMs. It
> systematically constructs multidisciplinary QA that necessitate knowledge fusion across multiple web
> documents, moving beyond simple fact retrieval. Knowledge-intensive data tasks solvable by the LKP
> are retained for continued pre-training (CPT), while tasks solvable only by the MKO are marked as
> frontier-level data for post-training. This dual-pipeline design yields a continuous stream of adaptive,
> high-quality training data, establishing a virtuous cycle of capability growth.
> 
> 
> Our contributions are threefold:
> 
> 
> 1. We present **AgentFrontier Engine**, a scalable data synthesis framework founded on the theory of
> _Zone of Proximal Development_ (ZPD). By integrating agentic refinement and LKP–MKO adversarial
> calibration, our engine create both knowledge-intensive and frontier-level reasoning data.
> 
> 
> 2. We establish **ZPD Exam**, an automated benchmark designed to probe the ZPD of LLMs. It assesses
> advanced capabilities such as tool using and in-depth reasoning by complex multidisciplinary
> questions that require cross-document knowledge fusion and deep research.
> 
> 
> 3. We build **AgentFrontier-30B-A3B** by further training Qwen3-30B-A3B-Thing-2507. The model
> was continually pre-trained on 50 billion tokens of knowledge-intensive data and then posttrained on 12,000 frontier-level QA trajectories synthesized by our engine, achieving 28.6% on
> HLE, as well as state-of-the-art performance on ZPD Exam-v1, R-Bench-T and xBench-ScienceQA.
> 
> 
> **2** **AgentFrontier** **Data** **Engine**
> 
> 
> **AgentFrontier Engine** addresses the critical need for training data that fosters knowledge fusion and
> complex reasoning, which operationalizes the theoretical framework of the _Zone of Proximal Development_ to
> generate challenging tasks that reside at the frontier of a LLM’s capabilities. Instead of passively curating
> existing information, the engine is designed to actively forge complexity through a three-stage agentic
> synthesis pipeline. This process aims to evolve LLMs from knowledge retrievers into sophisticated
> reasoning agents. The entire workflow, depicted in Figure 3, transforms a raw document corpus _C_ raw into
> a calibrated, high-value dataset _D_ ZPD. The detailed procedure is presented in Algorithm 1.
> 
> 
> **2.1** **Stage** **I:** **Seed** **Question** **Generation** **for** **Knowledge** **Fusionn**
> 
> 
> The pipeline begins with a diverse, multi-disciplinary corpus _C_ raw of one million public documents. We
> first employ a powerful LLM, Qwen3-235B-A22B (Yang et al., 2025), as a chunking function Φchunk to
> preprocess the corpus. This function cleans artifacts (e.g., HTML tags) and condenses long texts into
> information-dense chunks _C_ chunk, such that _C_ chunk = [�] _d∈C_ raw [Φ] chunk [(] _[d]_ [)][.]
> 
> 
> To generate tasks that inherently demand knowledge fusion, we synthesize questions from **composite**
> **units** —groups of thematically related chunks. To overcome the computational infeasibility of a combinatorial search, we adopt an efficient, retrieval-based approach. We first build a vector index over _C_ chunk
> and, for each chunk _ci_, retrieve its _k_ nn nearest neighbors. Within this local neighborhood, we search for
> triplets ( _ci_, _cj_, _ck_ ) that exhibit high thematic coherence, formally defined as Sim( _cx_, _cy_ ) _>_ _τ_ theme for all
> distinct pairs, where Sim( _·_, _·_ ) is a semantic similarity function.
> 
> 
> These composite units are then fed to a generator model, _M_ gen, to synthesize initial question-answer
> pairs. This process yields a seed dataset that serves as the foundation for complexity escalation: _D_ seed =
> _{_ ( _q_ 0, _a_ 0) = _M_ gen( _Uc_ ) _| Uc_ is a composite unit _}_ .
> 
> 
> 3
> 
> 
> Figure 3: The three-stage synthesis pipeline of the AgentFrontier Engine. It begins by creating multisource seed questions, then iteratively escalates their complexity using a tool-augmented agent, and
> finally filters through our ZPD-based calibration mechanism to isolate high-value training data.
> 
> 
> **2.2** **Stage** **II:** **Escalating** **Complexity** **through** **Agentic** **Refinement**
> 
> 
> The core of our engine is an iterative refinement loop driven by a refinement agent _A_ refine with a tool
> suite _T_ = _{T_ search, _T_ scholar, _T_ browser, _T_ code _}_ . For a QA pair ( _qk_, _ak_ ) at iteration _k_, the agent applies an
> escalation operator Ψescalate to generate a more sophisticated pair ( _qk_ +1, _ak_ +1) = Ψescalate( _qk_, _ak_, _A_ refine).
> This operator enriches the QA along four dimensions:
> 
> 
>   - **Knowledge Expansion:** It actively queries external sources to retrieve and weave in relevant
> background knowledge, broadening the informational scope of the question.
> 
> 
>   - **Conceptual Abstraction:** It conducts in-depth analysis of the core concepts within the provided
> materials, abstracting higher-level principles or identifying subtle relationships.
> 
> 
>   - **Factual Grounding:** It performs multi-source cross-validation and targeted augmentation to
> enhance the factual accuracy and depth of the content.
> 
> 
>   - **Computational Formulation:** It leverages the Python execution to craft QA that require quantitative calculation or logical simulation, assessing reasoning and computational skills.
> 
> 
> This self-bootstrapping process creates a virtuous cycle, where the output of one iteration becomes the
> input for the next, building increasingly more intricate reasoning paths. Figure 4 illustrates an example
> where a question is progressively refined by interleaving web search with numerical computation. After
> _K_ iterations, this stage produces a dataset of highly complex QA pairs, _D_ refined.
> 
> 
> **2.3** **Stage** **III:** **ZPD-based** **Filtering** **and** **Calibration**
> 
> 
> Not all synthesized QA pairs are equally valuable for training. To isolate tasks that reside precisely within
> an LLM’s ZPD, we introduce a rigorous calibration mechanism based on our **LKP-MKO** framework. We
> instantiate a **Less Knowledgeable Peer** ( _A_ LKP) with the base LLM and a **More Knowledgeable Other**
> ( _A_ MKO) with the powerful, tool-augmented agent.
> 
> 
> For each candidate pair ( _q_, _a_ ) _∈D_ refined, we first assess its difficulty. Let IsSolvableBy( _A_, _q_, _a_ ) _∈{_ 0, 1 _}_ be
> a binary function, implemented by an automated judge (GPT-4o (OpenAI, 2024)), which returns 1 if agent
> _A_ correctly answers _q_ . (a) If IsSolvableBy( _A_ LKP, _q_, _a_ ) = 1, the pair is deemed too simple and is allocated
> 
> 
> 4
> 
> 
> _**Round 1**_ _**Round 2**_ _**Round K+1**_
> 
> 
> Figure 4: An overview of our iterative refinement process. We start with a biomedical seed QA, which is
> then refined into a complex diagnostic reasoning problem by synthesizing knowledge from academic
> literature. Finally, this problem is evolved into a practical computational challenge grounded in a realworld application, a process involving web search and programmatic validation.
> 
> 
> to a general knowledge dataset _D_ pretrain for continued pre-training. (b) If IsSolvableBy( _A_ LKP, _q_, _a_ ) = 0,
> the pair is challenging and passed to the MKO for further evaluation.
> 
> 
> To stratify the challenging data, _A_ MKO performs Best-of-N (BoN) verification with _N_ = 3, generating _N_
> independent solutions _{s_ 1, . . ., _sN}_ . The data is then partitioned based on the outcome:
> 
> 
>   - **Verified for Post-Training (** _D_ **ZPD):** If the MKO finds at least one correct solution (i.e., ∑ _i_ _[N]_ =1 [IsCorrect][(] _[s][i]_ [,] _[ a]_ [)] _[ ≥]_
> 1), the pair is considered to be within the model’s ZPD—challenging yet learnable. These verified
> pairs form our final training set.
> 
>   - **Flagged for Human Review (** _D_ **human):** If the MKO fails in all _N_ attempts (i.e., ∑ _i_ _[N]_ =1 [IsCorrect][(] _[s][i]_ [,] _[ a]_ [) =]
> 0), the pair is either flawed or exceptionally difficult and is routed to human experts for analysis.
> 
> 
> Finally, to ensure dataset diversity, we apply a semantic redundancy filter. A newly generated pair ( _q_ _[′]_, _a_ _[′]_ )
> is discarded if its question _q_ _[′]_ is too similar to any question already in _D_ ZPD. Specifically, we discard ( _q_ _[′]_, _a_ _[′]_ )
> if max( _q_, _a_ ) _∈D_ ZPD Sim( _q_ _[′]_, _q_ ) _≥_ _ϵ_, where Sim( _·_, _·_ ) is measured by a reranker model (Zhang et al., 2025) and
> the threshold _ϵ_ is set to 0.7.
> 
> 
> Through this three-stage pipeline, the AgentFrontier Engine provides a scalable method for generating
> complex reasoning data, continuously pushing the boundaries of LLM capabilities.
> 
> 
> **3** **ZPD** **Exam:** **A** **Self-Evolving** **Benchmark** **for** **LLM** **Agents**
> 
> 
> Evaluating rapidly advancing LLMs requires benchmarks that co-evolve with their capabilities. While
> expert-crafted exams like Humanity’s Last Exam (Phan et al., 2025) probe the frontier of human knowledge, their static nature and prohibitive creation costs hinder scalable and continuous assessment. We
> introduce the **ZPD Exam**, an automated and continuously evolving benchmark designed to assess the
> deep research capabilities of advanced LLM agents.
> 
> 
> **3.1** **Benchmark** **Construction:** **From** **Frontier** **Knowledge** **to** **Agentic** **Research**
> 
> 
> The ZPD Exam is designed to simulate scientific discovery by generating tasks that are intractable using
> only parametric knowledge, thus compelling models to function as research agents. The benchmark
> 
> 
> 5
> 
> 
> is constructed using our AgentFrontier Engine (Section 2), specifically configured to generate novel,
> multi-disciplinary questions. Crucially, this benchmark corpus is strictly disjoint from the corpus used to
> construct our training data, ensuring a fair and uncontaminated evaluation.
> 
> 
> **Grounding in the Knowledge Frontier.** We ground this exam in the knowledge frontier by curating a
> corpus of 30,000 recent scientific papers published between 2023 and 2025, spanning multi-disciplinary
> domains such as mathematics, computer science, and physics. This ensures that success demands
> genuine, on-the-fly reasoning and information synthesis, not merely knowledge retrieval.
> 
> 
> **Calibrating** **Tasks** **to** **the** **LLM’s** **ZPD.** From our initial corpus, the AgentFrontier Engine generates
> candidate questions, which are then subjected to a strict adversarial filter to align with the ZPD of a
> baseline model. To be included in ZPD Exam-v1, a problem must satisfy a dual constraint: it must be
> unsolvable by the baseline model in three unaided attempts, yet consistently solvable by the same model
> across three attempts when granted access to tools. This process isolates problems that are difficult but
> solvable with assistance, defining the empirical boundary of the model’s ZPD.
> 
> 
> This automated pipeline enables a flywheel-like iterative process: as models improve, the ZPD exam can
> be regenerated to target the new frontier, making it a **living benchmark** resistant to saturation. After
> multiple rounds of validation and deduplication, ZPD Exam-v1 was constructed by sampling 1,024
> public questions and a corresponding private set. All questions are open-ended short-answer format,
> facilitating automated grading. The benchmark composition is detailed in Figure 5.
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
> 
> 
> 
> |Col1|Q: In international relations theory, what<br>term describes the systemic risk that occurs<br>when a declining hegemonic power reduces its<br>provision of global public goods while an emerging power is unwilling or unable to Humanities<br>assume leadership responsibilities,<br>potentially leading to underprovision of<br>essential transnational services during crises?<br>A: Kindleberger Trap|
> |---|---|
> |**_`Q:`_**_`In the biocatalytic pathway to Hormaomycins, what`_<br>_`nitrocyclopropane fragment is synthesized via Fe-catalyzed`_<br>_`oxidative cyclization of a nitroalkane intermediate?`_<br>_`A: 3-(2-nitrocyclopropyl)alanine`_<br>**`Chemistry`**|**_`Q:`_**_`In the biocatalytic pathway to Hormaomycins, what`_<br>_`nitrocyclopropane fragment is synthesized via Fe-catalyzed`_<br>_`oxidative cyclization of a nitroalkane intermediate?`_<br>_`A: 3-(2-nitrocyclopropyl)alanine`_<br>**`Chemistry`**|
> 
> 
> 
> Figure 5: The ZPD Exam-v1 consists of 1024 questions categorized into 9 disciplines: Mathematics,
> Computer Science / Artificial Intelligence, Physics, History, Humanities, Chemistry, Biology / Medicine,
> Engineering, and Geography.
> 
> 
> **3.2** **ZPD** **Exam:** **A** **Diagnostic** **Benchmark** **for** **Agentic** **Reasoning**
> 
> 
> The ZPD Exam proposes a new evaluative framework, shifting the focus from an LLM’s static parametric
> knowledge (Hendrycks et al., 2021) to its dynamic capacity for knowledge discovery, which functions as
> an "open-book" examination where agent must first author the "book" through active exploration and
> tool use. This design philosophy deliberately situates the challenges within the ZPD for current LLMs, a
> calibration confirmed by their low initial scores (Figure 1b). Our empirical results validate this diagnostic
> power, revealing a clear stratification of agent performance into three distinct zones.
> 
> 
> **Zone 1:** **Intrinsic Competence (Score < 20).** This tier establishes the baseline, reflecting the performance
> of LLMs relying solely on their parametric knowledge (e.g., GPT-5 and Gemini-2.5-Pro without tools). By
> design, the problems are intractable without external information, confirming that these tasks lie outside
> the models’ unaided capabilities. This zone effectively establishes a baseline, quantifying the limits of
> 
> 
> 6
> 
> 
> intrinsic, "closed-book" reasoning, confirming that any score above this threshold is directly attributable
> to the agent’s ability to leverage external tools support.
> 
> 
> **Zone 2:** **The Reasoning Bottleneck (Score 20-60).** This intermediate tier characterizes the ZPD itself,
> where agents (e.g., GPT-4o with tools, WebShaper-72b) can achieve partial success with assistance but
> lack mastery. This zone highlights the benchmark’s crucial distinction from standard RAG evaluations.
> While RAG tests comprehension of a given context, agents here falter in the more demanding task of
> autonomously discovering, structuring, and reasoning over the necessary information. Their failures
> stem not from tool-level errors but from a higher-order "reasoning bottleneck": a deficit in strategic
> planning, synthesizing information across multiple tool calls, and adapting their approach. This reveals
> that access to tools is necessary but insufficient; the primary limiting factor is the agent’s meta-cognitive
> ability to orchestrate these tools effectively.
> 
> 
> **Zone 3:** **Emergent Mastery (Score > 60).** Agents in this top tier (e.g., DeepSeek-V3.1 with tools) demonstrate a qualitative leap in capability. They have transcended the reasoning bottleneck and exhibit robust,
> multi-step planning and synthesis. Their behavior is analogous to the More Knowledgeable Other,
> seamlessly integrating tool-based exploration into a coherent reasoning process to solve problems far
> beyond their intrinsic reach. Achieving this level of performance signifies the emergence of a truly
> capable agent that can autonomously navigate complex problem spaces.
> 
> 
> In summary, the ZPD Exam serves not merely as a leaderboard but as a powerful diagnostic instrument.
> Its tiered results provide a fine-grained analysis of an agent’s developmental stage—from what it knows
> (intrinsic), to what it can learn to do with support (ZPD), to what it has mastered. This allows us to
> pinpoint critical reasoning faculties that require improvement, thereby charting a clear path toward more
> autonomous and capable AI agents.
> 
> 
> **4** **Experiments**
> 
> 
> **4.1** **Experimental** **Setup**
> 
> 
> **Training Data Synthesis** We synthesize training trajectories using a tool-augmented agent, following
> the iterative tool-calling and summarization paradigm from WebResearcher (Qiao et al., 2025). Each
> trajectory is generated through a multi-round process adhering to the ReAct (Yao et al., 2023), comprising
> a sequence of round-wise reasoning reports and observations after the corresponding tool calls. In each
> round, the model generates a reasoning report that summarizes accumulated evidence, analyzes progress
> towards the research question, and specifies the next action—either invoking a new tool or outputting a
> final answer.
> 
> 
> **Rejection Sampling Fine-Tuning** Formally, given a research question _q_ [(] _[i]_ [)], the model generates the
> 
> reasoning report _r_ [(] _j_ _[i]_ [)] at round _j_ conditioned on the previous report–observation pair _{r_ [(] _j−_ _[i]_ [)] 1 [,] _[ o]_ [(] _j−_ _[i]_ [)] 1 _[}]_ [, with]
> 
> initialization _r_ 0 [(] _[i]_ [)] = _o_ 0 [(] _[i]_ [)] = ∅. For a collection of _K_ accepted trajectories, where trajectory _i_ has _Li_ rounds,
> the objective reduces to supervised learning that maximizes the conditional log-likelihood:
> 
> 
> 
> _K_
> ## L RFT( θ ) = − ∑
> 
> _i_ =1
> 
> 
> 
> _Li_ ## ∑ log pθ r [(] j [i] [)]
> 
> _j_ =1
> 
> 
> 
> ��� _q_ ( _i_ ), _r_ ( _j−i_ )1 [,] _[ o]_ [(] _j−_ _[i]_ [)] 1�, (1)
> 
> 
> 
> where _θ_ denotes the model parameters. The loss computed is exclusively on the reasoning report tokens;
> tool observations are included in the context but excluded from backpropagation.
> 
> 
> **Models and Benchmarks** We apply RFT to the Qwen3 family of models (Yang et al., 2025), including
> both dense (Qwen3-8B, Qwen3-32B) and mixture-of-experts (Qwen3-30B-A3B-Thinking-2507) variants.
> We evaluate performance on four challenging benchmarks designed to probe high-level reasoning across
> diverse disciplines:
> 
> 
> 7
> 
> 
>   - **HLE** (Phan et al., 2025) - Humanity’s Last Exam is an expert-curated benchmark of 2,500 highly
> challenging questions spanning a wide range of disciplines, designed to assess frontier-level
> academic competence. We use the 2,154 text-only questions.
> 
> 
>   - **ZPD Exam**   - Our newly proposed multidisciplinary benchmark designed to probe the LLM’s
> zone of proximal development. We use the 1,024 questions from its first version.
> 
> 
>   - **R-Bench** (Guo et al., 2025) - A graduate-level, multidisciplinary benchmark designed to comprehensively assess the complex reasoning capabilities of LLMs. We used its English text-only
> version. After excluding one question for potential ambiguity, our evaluation set consists of 1,093
> multiple-choice questions.
> 
> 
>   - **xBench-ScienceQA** (Xbench-Team, 2025)   - A curated set of 100 Chinese QA items from the
> xBench suite, designed to evaluate foundational scientific knowledge.
> 
> 
> **Baselines** We evaluate our proposed AgentFrontier dataset by comparing it with three well-established,
> multidisciplinary public datasets for agent fine-tuning:
> 
> 
>   - **TaskCraft** (Shi et al., 2025) - The TaskCraft dataset facilitates the fine-tuning of agent models
> by programmatically generating agentic tasks at scale. These tasks are characterized by their
> inclusion of multiple tools, tiered difficulty levels, and verifiable execution trajectories.
> 
> 
>   - **MegaScience** (Fan et al., 2025) - The MegaScience dataset is constructed by integrating highquality subsets from multiple open-source scientific datasets to ensure sample abundance and
> high fidelity. The majority of its questions are sourced from university textbooks.
> 
> 
>   - **MiroVerse** (MiroMind-Data-Team, 2025) - MiroVerse is an open-source, large-scale dataset for
> AI agents, covering diverse tasks such as multi-hop question answering, web navigation, and
> scientific reasoning. We use the SFT data from its v0.1 release.
> 
> 
> For each dataset, we first curate 12,000 high-quality trajectories via rejection sampling, retaining only
> instances where the model’s final answer perfectly matches the ground truth. As shown in Table 1,
> our AgentFrontier dataset exhibits a more balanced and diverse tool-use distribution compared to the
> baselines, with substantial usage across scholar, browser, and code tools. This reflects its focus on complex,
> knowledge-intensive problem-solving. To ensure a fair comparison, we normalize the training data
> volume to 25,600 rounds for each dataset, with each round capped at 40,960 tokens, and train for 3 epochs.
> 
> 
> Table 1: Statistics of the training datasets. "Avg. Rounds" and "Avg. Calls" are computed per trajectory.
> 
> 
> **Avg.** **Calls**
> **Dataset** **Avg.** **Rounds**
> 
> **Search** **Scholar** **Browser** **Code**
> 
> 
> TaskCraft 3.38 1.04 0.14 1.19 0.01
> MegaScience 2.68 0.26 0.56 0.49 0.37
> MiroVerse 2.18 0.12 0.04 0.09 0.93
> AgentFrontier 3.32 0.32 0.66 0.82 0.52
> 
> 
> **Hyper-parameters and Metric** For all generation tasks, we use nucleus sampling with a **temperature** of
> 0.6 and a **top-p** of 0.95. To evaluate the correctness of the final answers, we employ an **LLM-as-a-Judge** .
> Specifically, we use o3-mini (OpenAI, 2025b) as the judge, guided by the official strict evaluation prompt
> from HLE (Phan et al., 2025), to assess the correctness of model responses against the ground truth.
> 
> 
> **4.2** **Main** **Results**
> 
> 
> **Overall** **Performance** **Across** **Benchmarks** As illustrated in Figure 6, when fine-tuning the Qwen330B-A3B model, models trained on AgentFrontier consistently achieve state-of-the-art performance,
> 
> 
> 8
> 
> 
> 94
> 
> 
> 92
> 
> 
> 90
> 
> 
> 88
> 
> 
> 86
> 
> 
> 84
> 
> 
> 94
> 
> 
> 92
> 
> 
> 90
> 
> 
> 88
> 
> 
> 86
> 
> 
> 84
> 
> 
> 90
> 
> 
> 88
> 
> 
> 86
> 
> 
> 84
> 
> 
> 82
> 
> 
> 
> ZPD Exam-v1 Score on Qwen3-30B-A3B
> 
> 
> 
> RBench-T Score on Qwen3-30B-A3B
> 
> 
> 
> xBench-ScienceQA Score on Qwen3-30B-A3B
> 
> 
> 
> Fine-tuning Dataset
> 
> RBench-T Score on Qwen3-8B
> 
> |Base Model: 55.0|Col2|
> |---|---|
> |<br> Base + Tools: 58.2||
> 
> 
> 
> ~~67.2~~
> 
> 
> 
> 
> 
> 
> 
> 26
> 
> 
> 24
> 
> 
> 22
> 
> 
> 20
> 
> 
> 24
> 
> 23
> 
> 22
> 
> 21
> 
> 20
> 
> 19
> 
> 18
> 
> 
> 19
> 
> 
> 18
> 
> 
> 17
> 
> 
> 16
> 
> 
> 15
> 
> 
> 14
> 
> 
> 
> HLE Score on Qwen3-30B-A3B
> 
> 
> 
> 
> 
> 
> 
> 74.4
> 
> 
> 
> 56
> 
> 54
> 
> 52
> 
> 50
> 
> 48
> 
> 46
> 
> 44
> 
> 42
> 
> 
> 
> 
> 
> 
> 
> 72.3
> 
> 
> 
> ~~73.1~~
> 
> 
> 
> 
> 
> 
> 
> 70.6
> 
> 
> Fine-tuning Dataset
> 
> RBench-T Score on Qwen3-32B
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
> 52
> 
> 50
> 
> 48
> 
> 46
> 
> 44
> 
> 42
> 
> 40
> 
> 38
> 
> 
> 
> 
> 
> 
> 
> 70.3
> 
> 
> 
> 
> 
> 68.4
> 
> 
> 
> ~~67.4~~
> 
> 
> 
> 66.2
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
> 78
> 
> 
> 76
> 
> 
> 74
> 
> 
> 72
> 
> 
> 70
> 
> 
> 68
> 
> 
> 72
> 
> 
> 70
> 
> 
> 68
> 
> 
> 66
> 
> 
> 64
> 
> 
> 70
> 
> 
> 68
> 
> 
> 66
> 
> 
> 64
> 
> 
> 62
> 
> 
> 60
> 
> 
> 
> 42
> 
> 
> 40
> 
> 
> 38
> 
> 
> 36
> 
> 
> 34
> 
> 
> 32
> 
> 
> 30
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
> **5** **Analysis**
> 
> 
> 9
> 
> 
> Table 2: Accuracy on the Humanity’s Last Exam (full text-only set). Results are reported across major
> knowledge domains. Each block corresponds to a different Qwen3 backbone. Numbers with a colored
> background denote the best within each block; underlined numbers denote the second best.
> 
> 
> **Domain Accuracy on Humanity’s Last Exam (%)**
> **RFT Dataset** **Tools**
> 
> Math CS/AI Bio./Med. Physics Humanities Chem. Eng. Other Avg.
> 
> 
> _Backbone:_ _Qwen3-8B_
> 
>  - ✗ 6.46 2.65 5.88 0.99 3.63 1.00 6.45 1.61 4.00
> 
>  - ✓ 6.26 3.54 9.05 2.48 7.25 7.00 6.45 5.14 5.94
> 
> 
>  - ✗ 8.72 5.75 10.41 0.50 7.77 8.00 6.45 5.14 7.34
> 
>  - ✓ 10.97 5.31 9.05 4.95 7.25 5.00 6.45 4.57 8.36
> TaskCraft ✓ 20.72 14.16 16.74 8.91 25.39 14.00 14.52 20.57 18.43
> MegaScience ✓ 21.23 14.60 14.93 6.44 29.02 12.00 11.29 21.71 18.52
> 
> 
>  - ✗ 13.03 7.96 8.14 3.47 7.25 5.00 8.06 2.86 9.24
> 
>  - ✓ 13.13 7.96 6.33 1.98 11.92 10.00 6.45 10.29 10.17
> TaskCraft ✓ 24.62 12.39 16.29 7.92 21.76 19.00 12.90 22.29 19.87
> MegaScience ✓ 23.69 14.60 20.81 9.90 26.94 15.00 8.06 18.29 20.15
> MiroVerse ✓ 23.38 12.39 20.81 9.41 24.87 7.00 11.29 22.86 19.64
> **AgentFrontier** ✓ **29.85** **16.81** **21.27** **17.82** **31.61** **22.00** **14.52** **28.00** **25.67**
> 
> 
> attempts was correct (pass@ _N_ ).
> 
> 
> As shown in Figure 7, the accuracy dramatically Best-of-N (BoN) Accuracy
> 
> sights. **First, it validates the designed difficulty**
> 
> 36
> 
> **of AgentFrontier:** the dataset is not a binary mix
> 
> a challenging frontier where initial attempts may
> 
> 24
> 
> fail, but success is achievable through exploration.
> This provides a rich learning signal beyond super- 18
> 
> |Best-of-N Accuracy|Col2|
> |---|---|
> |Best-of-N Accuracy<br>95% Confidence Interval|Best-of-N Accuracy<br>95% Confidence Interval|
> |||
> |||
> |Total Gain<br>~~+19.0 pts~~|Total Gain<br>~~+19.0 pts~~|
> |+11.3 pts<br>|+11.3 pts<br>|
> |||
> |||
> |||
> 
> ficial pattern matching. **Second, it highlights the** 1 2 3 4 5 6 7 8
> 
> N (Number of Attempts)
> 
> **significant** **potential** **for** **subsequent** **reinforce-**
> **ment learning (RL)** While supervised fine-tuning
> 
> Figure 7: Best-of-N (BoN) accuracy of our RFT
> 
> (SFT) trains the model on a single reference solu
> Qwen3-30B-A3B model on a 300-sample validation
> 
> tion, the large gap between pass@1 and pass@8
> 
> set from AgentFrontier.
> 
> confirms that for problems the model fails to solve
> on the first attempt, its policy distribution contains diverse and successful alternative trajectories. This is
> a crucial precondition for effective RL, ensuring that exploration can discover high-reward experiences
> necessary for effective policy optimization. Therefore, AgentFrontier serves not only as a robust training
> resources for SFT but also as a strong foundation for RL to further unlock an agent’s problem-solving
> potential.
> 
> 
> 
> Best-of-N (BoN) Accuracy
> 
> 
> 
> 48
> 
> 
> 
> 42
> 
> 
> 
> 
> 
> 36
> 
> 
> 
> 30
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
> 18
> 
> 
> 
> 1 2 3 4 5 6 7 8
> N (Number of Attempts)
> 
> 
> 
> Figure 7: Best-of-N (BoN) accuracy of our RFT
> Qwen3-30B-A3B model on a 300-sample validation
> set from AgentFrontier.
> 
> 
> 
> 10
> 
> 
> **5.2** **Why** **AgentFrontier** **Excels:** **Deconstructing** **the** **Gains** **in** **Reasoning** **and** **Tool-Use**
> 
> 
> 
> **From** **Shallow** **Retrieval** **to** **Deep** **Causal** **Reasoning.** Figure 8 reveals the performance dynamics that underscore
> AgentFrontier’s superiority. The vast majority (95%) of problems are solved within a 15-round horizon, a critical window
> in which our RFT dataset consistently outperforms all finetuning dataset baselines. This advantage is a principled consequence of our data generation strategy rooted in the Zone
> of Proximal Development. By curating tasks that are unsolvable by the base model yet solvable with external scaffolding,
> we create training instances of optimal difficulty. This forces
> the model to abandon simplistic, single-source retrieval and
> instead master knowledge fusion—the non-trivial meta-skill
> of integrating disparate information streams into a coherent solution. The agent learns not merely what information
> to retrieve, but how to synthesize it, shifting from shallow
> pattern-matching to in-depth causal reasoning.
> 
> 
> 
> 25
> 
> 
> 20
> 
> 
> 15
> 
> 
> 10
> 
> 
> 5
> 
> 
> 0
> 
> 
> 100%
> 
> 
> 80%
> 
> 
> 60%
> 
> 
> 40%
> 
> 
> 20%
> 
> 
> 
> |HLE Accuracy vs. Round Intervals|Col2|
> |---|---|
> |||
> |||
> |||
> |||
> ||RFT Datasets<br>AgentFrontier<br>~~TaskCraft~~|
> ||MegaScience<br>MiroVerse|
> 
> 
> Round Interval
> 
> Cumulative Distribution of Rounds
> 
> 
> 
> **From High-Volume Invocation to High-Efficacy Orchestra-**
> 
> 0%
> 
> |Col1|Col2|Col3|Col4|Col5|Col6|Col7|Col8|
> |---|---|---|---|---|---|---|---|
> ||||||95%|||
> |||||||||
> |||||||||
> |||||||||
> |||||||||
> 
> 
> **tion.** The design philosophy of AgentFrontier prioritizes 0 5 10 15 20 25
> 
> Number of Rounds
> 
> the cultivation of strategic tool orchestrators over rote tool
> callers. Unlike datasets that promote skewed tool dependen- Figure 8: Accuracy vs. number of rounds
> cies (e.g., code-centric MiroVerse or search-centric TaskCraft), on 4 datasets.
> AgentFrontier promotes a balanced tool-use distribution (Table 1). This forces the agent to develop a
> sophisticated understanding of inter-tool synergy rather than mastering a single tool in isolation. The
> results on the HLE benchmark (Table 3) confirm this empirical payoff. Our agent achieves a macroaverage conditional tool accuracy of 26.3%—a significant leap from the 21% plateau of competitors—with
> a comparable number of interactions. This demonstrates that agent capability stems not from the volume
> of tool calls, but their efficacy. Our method trains the model to transition from high-volume, low-yield
> tool usage to precise, high-efficacy orchestration, which is a crucial step toward creating more resourceful
> agents.
> 
> 
> 
> 0%
> 
> 
> 
> 0 5 10 15 20 25
> Number of Rounds
> 
> 
> 
> Figure 8: Accuracy vs. number of rounds
> on 4 datasets.
> 
> 
> 
> Table 3: Tool usage statistics for the Qwen3-30B-A3B agent on the HLE text-only test set (2154 problems).
> Each column block shows performance after RFT on a different dataset. We report average usage per
> round and conditional tool accuracy (Acc, %), defined as the success rate for tasks that use the tool. The
> final row details overall metrics. Best results are in **bold** .
> 
> 
> **TaskCraft** **MegaScience** **MiroVerse** **AgentFrontier**
> 
> 
> **Tool / Metric** Usage Acc (%) Usage Acc (%) Usage Acc (%) Usage Acc (%)
> 
> 
> **Overall** (Rounds/Acc.) 4.21 21.0 4.70 20.6 **4.74** 20.5 4.57 **26.3**
> 
> 
> **5.3** **Holistic** **Agentic** **Training**
> 
> 
> **Setup** We further investigate the performance gains a holistic training pipeline that incorporates
> continued pre-training (CPT) and post-training. Due to the large-scale GPU computation in CPT, this
> 
> 
> 11
> 
> 
> study is conducted only on Qwen3-30B-A3B-Thinking-2507 and our AgentFrontier data. The holistic
> training pipeline consists of two stages:
> 
> 
> 1. **Continual Pre-training (CPT)** : One epoch over 50B tokens, comprising 1 million summarized
> text chunks and 20 million knowledge-intensive QA pairs.;
> 
> 
> 2. **Rejection Sampling Fine-tuning (RFT)** : Three epochs on 12,000 high-quality trajectories.
> 
> 
> **CPT Objective** The CPT stage minimizes the standard language modeling loss:
> 
> 
> _T_
> ## L CPT( θ ) = − ∑ log pθ ( xt | x<t ), (2)
> 
> _t_ =1
> 
> 
> where _xt_ denotes the token at position _t_, and _θ_ are the model parameters.
> 
> 
> Table 4: Comparison of AgentFrontier with state-of-the-art proprietary and open-source LLMs/Agents
> on four high-level multidisciplinary benchmarks. [†] marks the result from the corresponding official
> reports. The final row highlights the performance gain from our Continual Pre-training (CPT) stage.
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
> **Evaluation** To comprehensively assess our model, AgentFrontier (CPT+RFT), we conduct extensive
> evaluations against a diverse range of competitors. These include leading closed-source (OpenAI, 2024;
> anthropic, 2025; DeepMind, 2025) and open-source (Liu et al., 2024; Yang et al., 2025) language models,
> evaluated with and without access to external tools. Additionally, we compare AgentFrontier with
> both proprietary deep-research agents (OpenAI, 2025a; Google, 2025; MoonshotAI, 2025) and prominent
> open-source agents (Wu et al., 2025; Li et al., 2025a; Tao et al., 2025).
> 
> 
> 12
> 
> 
> **Main Results** Table 4, our holistically trained agent not only sets a new state-of-the-art among opensource models but also competes effectively with significantly larger, proprietary agents. The final row
> isolates the contribution of CPT, which consistently boosts performance across all benchmarks (+2.9 on
> HLE, +7.0 on xBench-ScienceQA). Notably, CPT yields a +2.0 point gain on ZPD Exam, where the RFTonly model’s performance was already near-saturation. This provides strong evidence that strengthening
> a model’s foundational knowledge via CPT directly enhances its capacity for complex agentic tasks.
> 
> 
> **5.4** **Case** **Study**
> 
> 
> A qualitative analysis on an HLE case (Phan et al., 2025) (Appendix C) further illustrates our agent’s
> reasoning process. In a complex clinical scenario, OpenAI DeepResearch (OpenAI, 2025a) agent exhibited
> **diagnostic fixation**, misdiagnosing _**Charcot Arthropathy**_ by focusing on common negative findings like
> sterile synovial fluid. In contrast, our AgentFrontier agent correctly identified the key anomaly: the
> patient’s paradoxical worsening on prednisone. It hypothesized that this was due to a latent infection
> unmasked by immunosuppression, rather than an inflammatory rebound. This triggered a targeted
> inquiry, using a literature search to confirm that _**Chronic Osteomyelitis**_ can present with sterile aspirates
> and is exacerbated by steroids. This progression from identifying an anomaly to forming a hypothesis
> and validating it with targeted research demonstrates AgentFrontier’s advanced research capabilities.
> 
> 
> **6** **Related** **Work**
> 
> 
> **Data Synthesis for LLM Agents** Synthesizing high-quality data is critical for advancing LLM agents
> that require complex reasoning and tool use (Zeng et al., 2025; Liu et al., 2025; Zhou et al., 2024). Initial
> efforts replaced costly manual curation with programmatic generation, creating agentic tasks with
> verifiable solution trajectories (Shi et al., 2025; Hongjin et al., 2025; Huang et al., 2025). Subsequent
> research aimed to enhance data quality by grounding synthesis in external knowledge sources like
> scientific documents (Fan et al., 2025; Feng et al., 2025). While these approaches increase factual richness,
> they often produce tasks solvable via localized information retrieval, rather than promoting the deep
> knowledge integration essential for complex research (OpenAI, 2025a). A central challenge remains the
> precise calibration of task difficulty. Without a principled control mechanism, synthetic data risks being
> too simple for effective learning or too complex to yield a usable training signal (Li et al., 2025b). These
> strategies rely on heuristics like incremental constraint addition (Patel et al., 2025) or probes to distinguish
> reasoning from recitation (Yan et al., 2025), yet lack a principled framework to calibrate difficulty for
> scaffolding complex reasoning.
> 
> 
> **Multi-disciplinary Benchmark** The evaluation of advanced reasoning in large language models (LLMs)
> was pioneered by MMLU (Hendrycks et al., 2021), which set the standard for assessing multi-disciplinary
> knowledge. This led to a wave of subsequent benchmarks (Rein et al., 2023; Wang et al., 2024; Du
> et al., 2025; Guo et al., 2025; Xbench-Team, 2025) targeting undergraduate or graduate level knowledge.
> However, the rapid progress of frontier models (OpenAI, 2025b; DeepMind, 2025; anthropic, 2025) is
> causing performance saturation on these static benchmarks, reducing their effectiveness in differentiating
> top-tier models. While newer benchmarks like Humanity’s Last Exam (Phan et al., 2025) increase
> difficulty through expert curation, they remain fixed assessments. In contrast, our work introduces
> the ZPD Exam, a self-evolving evaluation framework that adapts in lockstep with model capabilities,
> providing a consistently challenging frontier for LLM agent evaluation.
> 
> 
> **Deep-Research Agents** Deep-research agent, a system built upon large reasoning models (LRMs), is
> designed to automate multi-step search and reasoning. It empowers users to complete complex, crossdomain information synthesis and in-depth research tasks in minutes, a process that would otherwise
> require hours of human effort. Proprietary agents (OpenAI, 2025a; Google, 2025; Anthropic, 2025;
> xAI, 2025; Perplexity, 2025; MoonshotAI, 2025) have demonstrated impressive capabilities in complex,
> 
> 
> 13
> 
> 
> multi-step research tasks. The open-source community has fostered a rich ecosystem of transparent
> and reproducible agents (Jin et al., 2025; Li et al., 2025c;d; Tao et al., 2025; Li et al., 2025a; Qiao et al.,
> 2025). These efforts typically leverage explicit planning, tool-use, and web navigation to emulate human
> research processes, advancing the field through shared methodologies.
> 
> 
> **7** **Conclusion**
> 
> 
> In this work, we presented a novel data synthesis paradigm based on the Zone of Proximal Development
> (ZPD) theory. Our framework co-generates a targeted training resources and a self-evolving ZPD Exam
> to progressively enhance and evaluate agentic reasoning. The resulting model, AgentFrontier-30B-A3B,
> validates our approach by achieving state-of-the-art results on challenging expert-level multi-disciplinary
> benchmarks, surpassing even significantly larger proprietary agents. This work demonstrates that a
> principled, pedagogical approach to data synthesis is a highly effective, if not essential, strategy for
> cultivating advanced reasoning abilities in a data-efficient manner.
> 
> 
> **Limitations** **and** **Future** **Work**
> 
> 
> While our ZPD-guided framework demonstrates significant promise, we identify three primary limitations that chart clear paths for future research:
> 
> 
> 1. **Graduated Scaffolding:** Our current ZPD operationalization relies on binary, "all-or-nothing"
> scaffolding, where the More Knowledgeable Other (MKO) provides a complete solution trajectory.
> This simplifies the nuanced support common in human pedagogy. A key future direction is
> to develop graduated scaffolding, offering tiered assistance from high-level strategic hints to
> specific sub-goals. Such a system would not only teach the agent what to do with help but also
> foster the crucial meta-cognitive skill of learning how to seek it, leading to more autonomous
> and sample-efficient learning.
> 
> 
> 2. **From Imitation to Exploration:** Our reliance on imitation learning (IL), specifically RejectionSampling Fine-Tuning, constrains the agent to mode-seeking behavior. The significant gap
> between our pass@1 and pass@N results strongly indicates a diverse distribution of valid solutions that IL under-explores. This presents a prime opportunity for Reinforcement Learning (RL).
> We propose using our fine-tuned model as a high-quality policy prior to initialize an RL agent,
> and repurposing the ZPD-guided data as a principled reward signal. This shift from imitation to
> exploration would empower the agent to discover novel and superior policies, breaking beyond
> the performance ceiling of the demonstration data.
> 
> 
> 3. **Dynamic** **Tool** **Creation:** The agent’s problem-solving capacity is currently bounded by its
> predefined, static toolset. While proficient as a tool user, it cannot function as a tool creator.
> A pivotal advancement is to empower the agent with tool creation abilities, pursuing two
> complementary paths: (1) Hierarchical Tool Composition, learning to combine existing tools
> into reusable "meta-tools" for recurring sub-tasks; and (2) Program Synthesis, programmatically
> generating new functions to address novel problem requirements. This evolution from tool user
> to creator is a critical step towards more general and resourceful agents capable of dynamically
> extending their capabilities for a broader problem space.
> 
> 
> **Acknowledgment**
> 
> 
> We sincerely thank Kuan Li for providing the LaTeX template used in the preparation of this paper.
> 
> 
> 14
> 
> 
> **A** **Data** **Engine** **Details**
> 
> 
> This section provides a detailed breakdown of the hyperparameters, procedural logic, and computational
> costs associated with the AgentFrontier Data Engine, as outlined in Algorithm 1. These details are
> provided to ensure the transparency and reproducibility of our data synthesis framework.
> 
> 
> **A.1** **Hyperparameter** **Configuration**
> 
> 
> The data generation pipeline is governed by several key hyperparameters that control the granularity
> of data sourcing, the complexity of generated questions, and the strictness of the filtering process. Our
> configuration is as follows:
> 
> 
>   - **Thematic Coherence Threshold (** _τ_ **theme):** Set to **0.8** . This value determines the minimum semantic
> similarity required between text chunks to form a "composite unit" for seed question generation.
> A higher value ensures that initial questions are synthesized from thematically tighter content,
> promoting knowledge fusion.
> 
> 
>   - **Nearest Neighbors for Seeding (** _k_ **nn):** Set to **10** . During seed generation, for each text chunk,
> we retrieve its _k_ nn nearest neighbors to search for coherent triplets. This balances computational
> efficiency with a sufficiently large search space for discovering novel combinations.
> 
> 
>   - **Maximum Refinement Iterations (** _K_ **max):** Set to **30** . This parameter defines the maximum number
> of complexity escalation steps for any given QA pair in Stage II. This upper bound prevents
> infinite loops and manages computational resources.
> 
> 
>   - **Best-of-N (BoN) Verification Size (** _N_ **):** Set to **3** . In the ZPD-filtering stage, the More Knowledgeable Other ( _A_ MKO) makes _N_ independent attempts to solve a problem. This helps to reduce
> the variance in the agent’s performance and provides a more reliable signal of whether a task is
> solvable.
> 
> 
>   - **Diversity Filter Threshold (** _ϵ_ **):** Set to **0.7** . To ensure dataset diversity, a new QA pair is discarded
> if its question’s semantic similarity to any existing question in _D_ ZPD exceeds this threshold. The
> similarity is measured by a state-of-the-art reranker model.
> 
> 
> **A.2** **Agentic** **Refinement** **and** **Stopping** **Criterion**
> 
> 
> The core of our data engine is the iterative refinement loop (Stage II), driven by the agent _A_ refine. The
> goal of the escalation operator, Ψescalate, is to progressively increase the cognitive load required to answer
> a question. This is achieved by prompting the agent to perform a series of enrichment actions, including
> but not limited to: expanding the question with new, relevant concepts discovered through tool use;
> abstracting a general principle from specific examples; grounding the problem in a more complex, realistic
> context; or transforming a qualitative problem into a quantitative one requiring computation.
> 
> 
> The iterative escalation is guided by a principled stopping criterion tied to the ZPD framework: for
> a given QA pair, the refinement loop terminates when the generated question _qk_ becomes unsolvable
> by the **Less** **Knowledgeable** **Peer** ( _A_ LKP), a baseline model formally defined in Stage III, or when a
> predefined maximum of _K_ max = 30 iterations is reached. This targeted termination ensures that the
> engine’s computational resources are focused on producing problems that precisely challenge the base
> model’s capabilities.
> 
> 
> **A.3** **Computational** **Cost** **Analysis**
> 
> 
> We provide a detailed analysis of the computational cost required to generate a single high-quality data
> point for the _D_ ZPD dataset. The cost is broken down into the two primary stages of our pipeline: agentic
> 
> 
> 15
> 
> 
> refinement and MKO verification. All token counts are based on the respective model’s tokenizer, and
> costs are estimated using official API pricing as of the experiment date [1] .
> 
> 
> **A.3.1** **Cost of Agentic Refinement (Stage II)**
> 
> 
> In this stage, the refinement agent, _A_ refine, iteratively enhances a QA pair until it reaches the capability
> frontier of the Less Knowledge Peer (LKP). The cost per data point is variable, depending on the number
> of iterations ( _K_ ) needed.
> 
> 
> On average, processing a single candidate data point involves the following:
> 
> 
>   - **Refinement Iterations (** _K_ **):** A data point undergoes an average of **7.81** iterations.
> 
> 
>   - **Token Throughput per API Call:**
> 
> 
> **–** Input: **18,613.82** tokens.
> 
> 
> **–** Output: **11,643.22** tokens.
> 
> 
>   - **Tool Calls per Data Point:**
> 
> 
> **–** Search: **0.70** calls.
> 
> 
> **–** Scholar: **0.61** calls.
> 
> 
> **–** Browser: **1.21** calls (avg. 10,000 tokens/call).
> 
> 
> **–** Code Interpreter: **0.94** calls (executed locally, no API cost).
> 
> 
> **Cost** **Breakdown.** The average refinement cost per candidate is approximately **$0.24**, calculated as
> follows:
> 
> 
>   - **LLM Cost:** 7.81 _×_ (18, 614 _×_ $0.56/M + 11, 643 _×_ $1.68/M) _≈_ $0.234.
> 
> 
>   - **Search Cost:** (0.70 + 0.61) _×_ $0.00275/call _≈_ $0.0036.
> 
> 
>   - **Browser Cost:** 1.21 _×_ 10, 000 _×_ $0.00005/token _≈_ $0.0006.
> 
> 
> **A.3.2** **Cost of MKO Verification (Stage III)**
> 
> 
> Candidates that pass the refinement stage are then verified by the More Knowledgeable Other agent,
> _A_ MKO. This Best-of-N ( _N_ = 3) verification confirms that the problem is solvable by an expert-level agent,
> thus ensuring its placement within the Zone of Proximal Development (ZPD).
> 
> 
> For the _N_ = 3 verification attempts on a single candidate, the average resource consumption is:
> 
> 
>   - **Total API Calls:** **3.32** calls.
> 
> 
>   - **Token Throughput per API Call:**
> 
> 
> **–** Input: **20,181.57** tokens.
> 
> 
> **–** Output: **24,169.88** tokens.
> 
> 
>   - **Total Tool Calls:**
> 
> 
> **–** Search: **0.50** calls.
> 
> 
> **–** Scholar: **0.92** calls.
> 
> 
> **–** Browser: **1.30** calls (avg. 10,000 tokens/call).
> 
> 
> **–** Code Interpreter: **0.53** calls (executed locally, no API cost).
> 
> 
> 1Pricing references: DeepSeek Model API ( `[https://api-docs.deepseek.com/](https://api-docs.deepseek.com/)` ), SerpApi for Google Search
> ( `[https://serpapi.com/enterprise](https://serpapi.com/enterprise)` ), and Jina Reader API ( `[https://jina.ai/reader/](https://jina.ai/reader/)` )
> 
> 
> 16
> 
> 
> **Cost Breakdown.** The verification cost for a single candidate is approximately **$0.18** :
> 
> 
>   - **LLM Cost:** 3.32 _×_ (20, 182 _×_ $0.56/M + 24, 170 _×_ $1.68/M) _≈_ $0.172.
> 
> 
>   - **Search Cost:** (0.50 + 0.92) _×_ $0.00275/call _≈_ $0.0039.
> 
> 
>   - **Browser Cost:** 1.30 _×_ 10, 000 _×_ $0.00005/token _≈_ $0.00065.
> 
> 
> However, only a fraction of candidates pass this stage. With an observed success rate of **33%**, the
> amortized cost to obtain one successfully verified data point is $0.18/0.33 _≈_ **$0.54** .
> 
> 
> In summary, the total end-to-end amortized cost to generate one high-quality, verified PhD-level QA pair
> with its solution trajectory for _D_ ZPD is approximately **$0.78** ($0.24 for refinement + $0.54 for amortized
> verification). While this represents a non-trivial investment per sample, it aligns with our "quality-overquantity" approach. This automated pipeline produces a valuable training asset at a fraction of the cost
> and time that manual curation by human experts would demand.
> 
> 
> **B** **Experimental** **Details**
> 
> 
> **B.1** **Tools** **Implementation**
> 
> 
> Our agent is equipped with a suite of tools to support its research process, from broad exploration to
> empirical validation. Each tool is designed for batch processing to enhance efficiency and produces
> structured outputs for seamless integration into the agent’s iterative reasoning loop.
> 
> 
>   - **Search:** Performs parallel web searches using the Google Search API. It returns a list of structured
> results, each containing a title, snippet, and URL, allowing the agent to efficiently assess the
> relevance of multiple sources.
> 
> 
>   - **Scholar:** Tackles multi-disciplinary challenges by querying the Google Scholar API to navigate
> scientific literature. It returns structured metadata, including authors, publication venue, and
> citation counts, enabling the agent to identify authoritative works and their scholarly context.
> 
> 
>   - **Browser:** Extracts targeted information from a given URL. The agent provides a specific goal
> (e.g., "extract the dataset and evaluation metrics"). The tool first fetches the page content using
> Jina Reader (Jina.ai, 2025) and then employs Qwen3 (Yang et al., 2025) to synthesize a precise
> answer based on the goal. This allows for focused knowledge extraction from web pages.
> 
> 
>   - **Code:** Provides a sandboxed Python environment for computational analysis and verification.
> It is equipped with standard scientific libraries (e.g., NumPy, SciPy) and allows the agent to
> execute code for tasks like data analysis or simulations. All outputs (stdout, stderr, and figures)
> are captured as text, providing empirical evidence for the agent’s reasoning process.
> 
> 
> **B.2** **Training** **Details**
> 
> 
> We implement supervised fine-tuning (SFT) using the Megatron-LM framework (Shoeybi et al., 2019).
> The hyperparameters for fine-tuning our MoE and Dense models are detailed in Table 5 and Table 6,
> respectively.
> 
> 
> **B.3** **More** **Results** **on** **on** **Fine-tuning** **Datasets**
> 
> 
> Table 7 presents a detailed analysis of tool usage and conditional accuracy for Qwen3-30B-A3B model
> after undergoing rejection-sampling fine-tuning (RFT) on four distinct datasets. The results clearly
> demonstrate the effectiveness of our synthesized dataset, AgentFrontier. The agent fine-tuned on
> AgentFrontier achieves the highest overall conditional accuracy on both the ZPD-Exam (87.6%) and
> RBench-T (63.7%) benchmarks. Furthermore, it consistently secures top-tier accuracy for critical tools
> across various benchmarks, such as for the Scholar (91.7%) and Browser (91.8%) tools on ZPD-Exam and
> 
> 
> 17
> 
> 
> Table 5: SFT Hyperparameters for the MoE
> Model.
> 
> 
> **Parameter** **Value**
> 
> 
> Training Epochs 3
> Max Sequence Length 40,960
> Batch Size 256
> ### Learning Rate 7.0 × 10 [−] [6] Learning Rate (Min) 7.0 × 10 [−] [7]
> 
> LR Scheduler Linear Decay
> Tensor Parallel (MP) 4
> Expert Parallel (EP) 2
> Pipeline Parallel (PP) 1
> 
> 
> 
> Table 6: SFT Hyperparameters for the Dense
> Model.
> 
> 
> **Parameter** **Value**
> 
> 
> Training Epochs 3
> Max Sequence Length 40,960
> Batch Size 64
> ### Learning Rate 4.0 × 10 [−] [5]
> 
> LR Scheduler Cosine Decay
> Warmup Ratio 0.1
> 
> 
> 
> the Code tool on both ZPD-Exam (83.3%) and RBench-T (78.6%). This superior performance underscores
> the quality of AgentFrontier in enhancing an agent’s capability to correctly and robustly utilize tools
> across a diverse range of complex tasks.
> 
> 
> Table 7: Tool usage statistics for the Qwen3-30B-A3B agent on the ZPD Exam, RBench-T and xBenchScienceQA. Each column block shows performance after RFT on a different dataset. We report average
> usage per round and conditional tool accuracy (Acc, %), defined as the success rate for tasks that use the
> tool. The final row details overall metrics. Best results are in **bold** .
> 
> 
> **Fine-tuning Dataset** **TaskCraft** **MegaScience** **MiroVerse** **AgentFrontier**
> 
> 
> **Benchmark** **Tool / Metric** Usage Acc (%) Usage Acc (%) Usage Acc (%) Usage Acc (%)
> 
> 
> 
> xBench-SciQA
> 
> 
> 
> Search 0.15 **90.8** 0.10 85.4 **0.18** 74.8 0.13 83.6
> 
> 
> Search 0.23 55.0 0.24 53.6 0.26 50.0 **0.28** **58.1**
> Scholar 0.14 **63.1** 0.15 59.6 **0.16** 54.8 **0.16** 59.7
> 
> 
> Search **0.44** 28.6 0.39 50.0 0.36 46.4 0.43 **57.1**
> Scholar 0.29 54.2 **0.39** 44.8 0.36 **66.7** 0.28 48.1
> Browser 0.46 31.6 **0.61** 38.5 0.48 **52.4** 0.36 42.1
> Code **0.62** 47.2 0.54 46.8 0.60 42.6 0.58 **55.6**
> 
> 
> **Overall** (Rounds/Acc.) 2.81 40.4 **2.93** 45.0 2.81 **52.0** 2.66 50.7
> 
> 
> 18
> 
> 
> **C** **Case** **Study**
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 19
> 
> 
> 20
> 
> 
> 21
> 
> 
> 22
> 
> 
> 23
> 
> 
> **D** **Prompts** **Used** **in** **Experiments**
> 
> 
> The key prompts used in our experiments are presented below to ensure reproducibility.
> 
> 
> **D.1** **Evaluation** **Prompt**
> 
> 
> 
> 
> 
> **D.2** **Similarity** **Filter** **Prompt**
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
> **D.3** **Agentic** **Refinement** **Prompt**
> 
> 
> 
> 
> 
> 25
> 
> 
> **Algorithm 1** AgentFrontier Data Engine Pipeline
> 
> 
> **Input:**
> 
> _C_ raw: Raw document corpus; Φchunk: Chunking model; _M_ gen, _A_ refine, _A_ LKP, _A_ MKO: Models and
> agents; Sim, IsCorrect, IsSolvableBy: Similarity and evaluation functions; _τ_ theme, _K_, _N_, _ϵ_, _k_ nn: Hyperparameters (thematic threshold, escalation steps, BoN size, redundancy threshold, number of
> neighbors)
> **Output:**
> 
> _D_ ZPD: Calibrated training dataset for post-training; _D_ pretrain: Dataset for continued pre-training;
> _D_ human: Dataset for human review
> 
> 
> 1: **procedure** GENERATEZPDDATA( _C_ raw, . . . )
> 
> 2: _D_ ZPD, _D_ pretrain, _D_ human _←_ ∅, ∅, ∅
> 
> _▷_ **Stage I: Seed Question Generation**
> 
> 3: _C_ chunk _←_ [�] _d∈C_ raw [Φ] chunk [(] _[d]_ [)] _▷_ Preprocess corpus into semantic chunks
> 
> 4: _V_ index _←_ BuildVectorIndex( _C_ chunk) _▷_ Build index for efficient search
> 
> 5: _D_ seed _←_ ∅
> 
> 6: **for** each chunk _ci_ _∈C_ chunk **do**
> 
> 7: _Ni_ _←_ FindNearestNeighbors( _ci_, _V_ index, _k_ nn) _▷_ Find k-NN for efficient combination
> 
> 8: **for** each pair ( _cj_, _ck_ ) from _Ni_ **do**
> 
> 9: **if** Sim( _ci_, _cj_ ) _>_ _τ_ theme _∧_ Sim( _ci_, _ck_ ) _>_ _τ_ theme _∧_ Sim( _cj_, _ck_ ) _>_ _τ_ theme **then**
> 
> 10: ( _q_ 0, _a_ 0) _←M_ gen( _{ci_, _cj_, _ck}_ ) _▷_ Generate QA from thematic unit
> 
> 11: _D_ seed _←D_ seed _∪{_ ( _q_ 0, _a_ 0) _}_
> 
> 12: **end if**
> 
> 13: **end for**
> 
> 14: **end for**
> 
> _▷_ **Stages II & III: Iterative Escalation and ZPD Calibration**
> 
> 15: _V_ ZPD _←_ BuildVectorIndex(∅) _▷_ Initialize index for ZPD-set diversity check
> 
> 16: **for** each ( _q_ 0, _a_ 0) in _D_ seed **do**
> 
> 17: ( _q_, _a_ ) _←_ ( _q_ 0, _a_ 0)
> 
> _▷_ **Stage II: Agentic Refinement**
> 
> 18: **for** _k_ = 1 to _K_ **do** _▷_ Iteratively escalate complexity
> 
> 19: ( _q_, _a_ ) _←_ Ψescalate( _q_, _a_, _A_ refine) _▷_ e.g., Expand, Abstract, Ground, etc.
> 
> 20: **end for**
> 
> _▷_ **Stage III: ZPD-based Filtering**
> 
> 21: **if** IsSolvableBy( _A_ LKP, _q_, _a_ ) **then** _▷_ Check if too easy for Less Knowledgeable Peer
> 
> 22: _D_ pretrain _←D_ pretrain _∪{_ ( _q_, _a_ ) _}_
> 
> 23: **else** _▷_ Challenging for LKP, now verify with MKO
> 
> 24: _S_ solutions _←{A_ MKO( _q_ ) for _i_ = 1 . . . _N}_ _▷_ Best-of-N by More Knowledgeable Other
> 
> 25: **if** _∃s ∈_ _S_ solutions s.t. IsCorrect( _s_, _a_ ) **then** _▷_ Verified as solvable, thus within ZPD
> 
> 26: _q_ nearest _←_ FindNearestNeighbor( _q_, _V_ ZPD)
> 
> 27: **if** _q_ nearest = ∅ or Sim( _q_, _q_ nearest) _<_ _ϵ_ **then** _▷_ Filter for diversity
> 
> 28: _D_ ZPD _←D_ ZPD _∪{_ ( _q_, _a_ ) _}_
> 
> 29: UpdateVectorIndex( _V_ ZPD, _q_ )
> 
> 30: **end if**
> 
> 31: **else** _▷_ Unsolvable by MKO, potentially flawed or too hard
> 
> 32: _D_ human _←D_ human _∪{_ ( _q_, _a_ ) _}_
> 
> 33: **end if**
> 
> 34: **end if**
> 
> 35: **end for**
> 
> 36: **return** _D_ ZPD, _D_ pretrain, _D_ human
> 37: **end procedure**
> 
> 
> 26
> 
> 
> **References**
> 
> 
> anthropic. Meet claude, 2025. URL `[https://www.anthropic.com/claude](https://www.anthropic.com/claude)` .
> 
> 
> Anthropic. Claude takes research to new places. `[https://www.anthropic.com/news/research](https://www.anthropic.com/news/research)`, April
> 2025.
> 
> 
> Google DeepMind. Gemini 2.5, 2025. URL `[https://blog.google/technology/google-deepmind/gemi](https://blog.google/technology/google-deepmind/gemini-model-thinking-updates-march-2025/)`
> `[ni-model-thinking-updates-march-2025/](https://blog.google/technology/google-deepmind/gemini-model-thinking-updates-march-2025/)` .
> 
> 
> Xinrun Du, Yifan Yao, Kaijing Ma, Bingli Wang, Tianyu Zheng, King Zhu, Minghao Liu, Yiming Liang,
> Xiaolong Jin, Zhenlin Wei, et al. SuperGPQA: Scaling LLM evaluation across 285 graduate disciplines.
> _arXiv preprint arXiv:2502.14739_, 2025.
> 
> 
> Run-Ze Fan, Zengzhi Wang, and Pengfei Liu. Megascience: Pushing the frontiers of post-training datasets
> for science reasoning. _arXiv preprint arXiv:2507.16812_, 2025.
> 
> 
> Yunzhen Feng, Elvis Dohmatob, Pu Yang, Francois Charton, and Julia Kempe. Beyond model collapse:
> Scaling up with synthesized data requires verification. In _The Thirteenth International Conference on_
> _Learning Representations_, 2025.
> 
> 
> Google. Deep research is now available on gemini 2.5 pro experimental., 2025. URL `[https://blog.goo](https://blog.google/products/gemini/deep-research-gemini-2-5-pro-experimental/)`
> `[gle/products/gemini/deep-research-gemini-2-5-pro-experimental/](https://blog.google/products/gemini/deep-research-gemini-2-5-pro-experimental/)` .
> 
> 
> Meng-Hao Guo, Jiajun Xu, Yi Zhang, Jiaxi Song, Haoyang Peng, Yi-Xuan Deng, Xinzhi Dong, Kiyohiro
> Nakayama, Zhengyang Geng, Chen Wang, et al. Rbench: Graduate-level multi-disciplinary benchmarks for llm & mllm complex reasoning evaluation. In _Forty-second International Conference on Machine_
> _Learning_, 2025.
> 
> 
> Dan Hendrycks, Collin Burns, Steven Basart, Andy Zou, Mantas Mazeika, Dawn Song, and Jacob
> Steinhardt. Measuring massive multitask language understanding. In _ICLR_ . OpenReview.net, 2021.
> 
> 
> SU Hongjin, Ruoxi Sun, Jinsung Yoon, Pengcheng Yin, Tao Yu, and Sercan O Arik. Learn-by-interact: A
> data-centric framework for self-adaptive agents in realistic environments. In _The Thirteenth International_
> _Conference on Learning Representations_, 2025.
> 
> 
> Yue Huang, Siyuan Wu, Chujie Gao, Dongping Chen, Qihui Zhang, Yao Wan, Tianyi Zhou, Chaowei
> Xiao, Jianfeng Gao, Lichao Sun, et al. Datagen: Unified synthetic dataset generation via large language
> models. In _The Thirteenth International Conference on Learning Representations_, 2025.
> 
> 
> Bowen Jin, Hansi Zeng, Zhenrui Yue, Jinsung Yoon, Sercan Arik, Dong Wang, Hamed Zamani, and Jiawei
> Han. Search-r1: Training llms to reason and leverage search engines with reinforcement learning. _arXiv_
> _preprint arXiv:2503.09516_, 2025.
> 
> 
> Jina.ai. Jina, 2025. URL `[https://jina.ai/](https://jina.ai/)` .
> 
> 
> Patrick Lewis, Ethan Perez, Aleksandra Piktus, Fabio Petroni, Vladimir Karpukhin, Naman Goyal,
> Heinrich Küttler, Mike Lewis, Wen-tau Yih, Tim Rocktäschel, et al. Retrieval-augmented generation for
> knowledge-intensive nlp tasks. _Advances in neural information processing systems_, 33:9459–9474, 2020.
> 
> 
> Kuan Li, Zhongwang Zhang, Huifeng Yin, Liwen Zhang, Litu Ou, Jialong Wu, Wenbiao Yin, Baixuan Li,
> Zhengwei Tao, Xinyu Wang, et al. Websailor: Navigating super-human reasoning for web agent. _arXiv_
> _preprint arXiv:2507.02592_, 2025a.
> 
> 
> Xiaochuan Li, Zichun Yu, and Chenyan Xiong. Montessori-instruct: Generate influential training data
> tailored for student learning. In _The Thirteenth International Conference on Learning Representations_, 2025b.
> 
> 
> 27
> 
> 
> Xiaoxi Li, Guanting Dong, Jiajie Jin, Yuyao Zhang, Yujia Zhou, Yutao Zhu, Peitian Zhang, and Zhicheng
> Dou. Search-o1: Agentic search-enhanced large reasoning models. _arXiv preprint arXiv:2501.05366_,
> 2025c.
> 
> 
> Xiaoxi Li, Jiajie Jin, Guanting Dong, Hongjin Qian, Yutao Zhu, Yongkang Wu, Ji-Rong Wen, and
> Zhicheng Dou. Webthinker: Empowering large reasoning models with deep research capability.
> _CoRR_, abs/2504.21776, 2025d. doi: 10.48550/ARXIV.2504.21776. URL `[https://doi.org/10.48550/a](https://doi.org/10.48550/arXiv.2504.21776)`
> `[rXiv.2504.21776](https://doi.org/10.48550/arXiv.2504.21776)` .
> 
> 
> Aixin Liu, Bei Feng, Bing Xue, Bingxuan Wang, Bochao Wu, Chengda Lu, Chenggang Zhao, Chengqi
> Deng, Chenyu Zhang, Chong Ruan, et al. DeepSeek-V3 technical report. _arXiv preprint arXiv:2412.19437_,
> 2024.
> 
> 
> Junteng Liu, Yuanxiang Fan, Zhuo Jiang, Han Ding, Yongyi Hu, Chi Zhang, Yiqi Shi, Shitong Weng, Aili
> Chen, Shiqi Chen, et al. Synlogic: Synthesizing verifiable reasoning data at scale for learning logical
> reasoning and beyond. _arXiv preprint arXiv:2505.19641_, 2025.
> 
> 
> SA McLeod. Zone of proximal development, 2012.
> 
> 
> Grégoire Mialon, Clémentine Fourrier, Thomas Wolf, Yann LeCun, and Thomas Scialom. Gaia: a
> benchmark for general ai assistants. In _The Twelfth International Conference on Learning Representations_,
> 2023.
> 
> 
> MiroMind-Data-Team. Miroverse v0.1: A reproducible, full-trajectory, ever-growing deep research
> dataset, 2025. URL `[https://huggingface.co/datasets/miromind-ai/MiroVerse-v0.1](https://huggingface.co/datasets/miromind-ai/MiroVerse-v0.1)` .
> 
> 
> MoonshotAI. Kimi-researcher, 2025. URL `[https://moonshotai.github.io/Kimi-Researcher/](https://moonshotai.github.io/Kimi-Researcher/)` .
> 
> 
> OpenAI. Hello GPT-4o, 2024. URL `[https://openai.com/index/hello-gpt-4o/](https://openai.com/index/hello-gpt-4o/)` .
> 
> 
> OpenAI. Deep research system card, 2025a. URL `[https://cdn.openai.com/deep-research-system-c](https://cdn.openai.com/deep-research-system-card.pdf)`
> `[ard.pdf](https://cdn.openai.com/deep-research-system-card.pdf)` .
> 
> 
> OpenAI. Introducing openai o3 and o4-mini, 2025b. URL `[https://openai.com/index/introducing-o](https://openai.com/index/introducing-o3-and-o4-mini/)`
> `[3-and-o4-mini/](https://openai.com/index/introducing-o3-and-o4-mini/)` .
> 
> 
> Arkil Patel, Siva Reddy, and Dzmitry Bahdanau. How to get your llm to generate challenging problems
> for evaluation. _arXiv preprint arXiv:2502.14678_, 2025.
> 
> 
> Perplexity. Introducing perplexity deep research, 2025. URL `[https://www.perplexity.ai/hub/blog/i](https://www.perplexity.ai/hub/blog/introducing-perplexity-deep-research)`
> `[ntroducing-perplexity-deep-research](https://www.perplexity.ai/hub/blog/introducing-perplexity-deep-research)` .
> 
> 
> Long Phan, Alice Gatti, Ziwen Han, Nathaniel Li, Josephina Hu, Hugh Zhang, Chen Bo Calvin Zhang,
> Mohamed Shaaban, John Ling, Sean Shi, et al. Humanity’s last exam. _arXiv preprint arXiv:2501.14249_,
> 2025.
> 
> 
> Zile Qiao, Guoxin Chen, Xuanzhong Chen, Donglei Yu, Wenbiao Yin, Xinyu Wang, Zhen Zhang, Baixuan
> Li, Huifeng Yin, Kuan Li, et al. Webresearcher: Unleashing unbounded reasoning capability in
> long-horizon agents. _arXiv preprint arXiv:2509.13309_, 2025.
> 
> 
> Yujia Qin, Shihao Liang, Yining Ye, Kunlun Zhu, Lan Yan, Yaxi Lu, Yankai Lin, Xin Cong, Xiangru
> Tang, Bill Qian, Sihan Zhao, Lauren Hong, Runchu Tian, Ruobing Xie, Jie Zhou, Mark Gerstein,
> dahai li, Zhiyuan Liu, and Maosong Sun. ToolLLM: Facilitating large language models to master
> 16000+ real-world APIs. In _The Twelfth International Conference on Learning Representations_, 2024. URL
> `[https://openreview.net/forum?id=dHng2O0Jjr](https://openreview.net/forum?id=dHng2O0Jjr)` .
> 
> 
> 28
> 
> 
> David Rein, Betty Li Hou, Asa Cooper Stickland, Jackson Petty, Richard Yuanzhe Pang, Julien Dirani,
> Julian Michael, and Samuel R. Bowman. GPQA: A graduate-level Google-proof Q&A benchmark.
> _CoRR_, abs/2311.12022, 2023.
> 
> 
> Dingfeng Shi, Jingyi Cao, Qianben Chen, Weichen Sun, Weizhen Li, Hongxuan Lu, Fangchen Dong,
> Tianrui Qin, King Zhu, Minghao Liu, et al. Taskcraft: Automated generation of agentic tasks. _arXiv_
> _preprint arXiv:2506.10055_, 2025.
> 
> 
> Noah Shinn, Federico Cassano, Ashwin Gopinath, Karthik Narasimhan, and Shunyu Yao. Reflexion:
> Language agents with verbal reinforcement learning. _Advances in Neural Information Processing Systems_,
> 36:8634–8652, 2023.
> 
> 
> Mohammad Shoeybi, Mostofa Patwary, Raul Puri, Patrick LeGresley, Jared Casper, and Bryan Catanzaro.
> Megatron-lm: Training multi-billion parameter language models using model parallelism. _arXiv_
> _preprint arXiv:1909.08053_, 2019.
> 
> 
> Dan Su, Kezhi Kong, Ying Lin, Joseph Jennings, Brandon Norick, Markus Kliegl, Mostofa Patwary,
> Mohammad Shoeybi, and Bryan Catanzaro. Nemotron-CC: Transforming Common Crawl into a
> refined long-horizon pretraining dataset. In Wanxiang Che, Joyce Nabende, Ekaterina Shutova,
> and Mohammad Taher Pilehvar (eds.), _Proceedings_ _of_ _the_ _63rd_ _Annual_ _Meeting_ _of_ _the_ _Association_ _for_
> _Computational Linguistics (Volume 1:_ _Long Papers)_, pp. 2459–2475, Vienna, Austria, July 2025. Association
> for Computational Linguistics. ISBN 979-8-89176-251-0. doi: 10.18653/v1/2025.acl-long.123. URL
> `[https://aclanthology.org/2025.acl-long.123/](https://aclanthology.org/2025.acl-long.123/)` .
> 
> 
> Zhengwei Tao, Jialong Wu, Wenbiao Yin, Junkai Zhang, Baixuan Li, Haiyang Shen, Kuan Li, Liwen Zhang,
> Xinyu Wang, Yong Jiang, et al. Webshaper: Agentically data synthesizing via information-seeking
> formalization. _arXiv preprint arXiv:2507.15061_, 2025.
> 
> 
> Minyang Tian, Luyu Gao, Shizhuo Zhang, Xinan Chen, Cunwei Fan, Xuefei Guo, Roland Haas, Pan
> Ji, Kittithat Krongchon, Yao Li, et al. Scicode: A research coding benchmark curated by scientists.
> _Advances in Neural Information Processing Systems_, 37:30624–30650, 2024.
> 
> 
> Lev S Vygotsky. _Mind in society:_ _The development of higher psychological processes_, volume 86. Harvard
> university press, 1978.
> 
> 
> Fanqi Wan, Xinting Huang, Deng Cai, Xiaojun Quan, Wei Bi, and Shuming Shi. Knowledge fusion of
> large language models. In _The Twelfth International Conference on Learning Representations_, 2024. URL
> `[https://openreview.net/forum?id=jiDsk12qcz](https://openreview.net/forum?id=jiDsk12qcz)` .
> 
> 
> Yubo Wang, Xueguang Ma, Ge Zhang, Yuansheng Ni, Abhranil Chandra, Shiguang Guo, Weiming Ren,
> Aaran Arulraj, Xuan He, Ziyan Jiang, Tianle Li, Max Ku, Kai Wang, Alex Zhuang, Rongqi Fan, Xiang
> Yue, and Wenhu Chen. MMLU-Pro: A more robust and challenging multi-task language understanding
> benchmark. _CoRR_, abs/2406.01574, 2024.
> 
> 
> Jason Wei, Zhiqing Sun, Spencer Papay, Scott McKinney, Jeffrey Han, Isa Fulford, Hyung Won Chung,
> Alex Tachard Passos, William Fedus, and Amelia Glaese. Browsecomp: A simple yet challenging
> benchmark for browsing agents. _arXiv preprint arXiv:2504.12516_, 2025.
> 
> 
> Jialong Wu, Baixuan Li, Runnan Fang, Wenbiao Yin, Liwen Zhang, Zhengwei Tao, Dingchu Zhang, Zekun
> Xi, Yong Jiang, Pengjun Xie, et al. Webdancer: Towards autonomous information seeking agency. _arXiv_
> _preprint arXiv:2505.22648_, 2025.
> 
> 
> xAI. Grok 3 beta — the age of reasoning agents, 2025. URL `[https://x.ai/news/grok-3](https://x.ai/news/grok-3)` .
> 
> 
> Xbench-Team. Xbench-deepsearch, 2025. URL `[https://xbench.org/agi/aisearch](https://xbench.org/agi/aisearch)` .
> 
> 
> 29
> 
> 
> Kai Yan, Yufei Xu, Zhengyin Du, Xuesong Yao, Zheyu Wang, Xiaowen Guo, and Jiecao Chen. Recitation
> over reasoning: How cutting-edge language models can fail on elementary school-level reasoning
> problems? _arXiv preprint arXiv:2504.00509_, 2025.
> 
> 
> An Yang, Anfeng Li, Baosong Yang, Beichen Zhang, Binyuan Hui, Bo Zheng, Bowen Yu, Chang Gao,
> Chengen Huang, Chenxu Lv, et al. Qwen3 technical report. _arXiv preprint arXiv:2505.09388_, 2025.
> 
> 
> Shunyu Yao, Jeffrey Zhao, Dian Yu, Nan Du, Izhak Shafran, Karthik Narasimhan, and Yuan Cao. React: Synergizing reasoning and acting in language models. In _International_ _Conference_ _on_ _Learning_
> _Representations (ICLR)_, 2023.
> 
> 
> Weizhe Yuan, Jane Yu, Song Jiang, Karthik Padthe, Yang Li, Ilia Kulikov, Kyunghyun Cho, Dong Wang,
> Yuandong Tian, Jason E Weston, et al. Naturalreasoning: Reasoning in the wild with 2.8 m challenging
> questions. _arXiv preprint arXiv:2502.13124_, 2025.
> 
> 
> Aohan Zeng, Xin Lv, Qinkai Zheng, Zhenyu Hou, Bin Chen, Chengxing Xie, Cunxiang Wang, Da Yin,
> Hao Zeng, Jiajie Zhang, et al. Glm-4.5: Agentic, reasoning, and coding (arc) foundation models. _arXiv_
> _preprint arXiv:2508.06471_, 2025.
> 
> 
> Yanzhao Zhang, Mingxin Li, Dingkun Long, Xin Zhang, Huan Lin, Baosong Yang, Pengjun Xie, An Yang,
> Dayiheng Liu, Junyang Lin, Fei Huang, and Jingren Zhou. Qwen3 embedding: Advancing text
> embedding and reranking through foundation models. _arXiv preprint arXiv:2506.05176_, 2025.
> 
> 
> Kun Zhou, Beichen Zhang, Zhipeng Chen, Xin Zhao, Jing Sha, Zhichao Sheng, Shijin Wang, Ji-Rong Wen,
> et al. Jiuzhang3. 0: Efficiently improving mathematical reasoning by training small data synthesis
> models. _Advances in Neural Information Processing Systems_, 37:1854–1889, 2024.
> 
> 
> 30
> 
> 

> [Source: AgentFrontier: Expanding the Capability Frontier of LLM Agents with ZPD-Guided Data Synthesis](https://arxiv.org/abs/2507.16530)
