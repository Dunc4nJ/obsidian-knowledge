---
created: 2026-03-03
description: ParamMem encodes cross-sample reflection patterns into a lightweight LoRA module, generating diverse reflections via temperature sampling that consistently outperform retrieval-based approaches across code, math, and QA tasks.
source: https://arxiv.org/abs/2602.23320
type: learning
---

# Parametric memory encoding cross-sample reflection patterns into weights produces more diverse and effective self-improvement than retrieval

## Key Takeaways

The central insight is that **reflective diversity strongly correlates with task success** (Pearson r=0.76 across five datasets), yet existing reflection mechanisms — both prompt-based and retrieval-based — hit diversity ceilings. ParamMem addresses this by fine-tuning a lightweight LoRA adapter on synthetic reflection data, encoding cross-sample patterns into model parameters rather than storing them for retrieval. This is conceptually related to how [[ProcMEM - Learning Reusable Procedural Memory from Experience via Non-Parametric PPO for LLM Agents]] internalizes procedural patterns, but ParamMem specifically targets diversity of reflective signals rather than procedural accuracy.

The framework unifies three memory types — episodic (self-reflections from prior iterations), cross-sample (retrieved trajectories from solved problems), and parametric (learned reflection patterns) — into a coherent agent called ParamAgent. This three-layer architecture resonates with [[MemSkill - Learning and Evolving Memory Skills for Self-Evolving Agents]], which also explores layered memory for self-evolving agents, though ParamMem's parametric layer is a novel addition that neither retrieval nor prompt-engineering can replicate.

ParamMem is remarkably sample-efficient: just 500 diverse training examples deliver performance close to 8000+ samples. This makes it practical for [[learning machines turn agents from stateless tools into systems that compound knowledge across users and sessions]] scenarios where training data is scarce. The module also enables **self-improvement without stronger external models** — when Llama-3.1-8B generates its own training data and fine-tunes itself, it still gains substantial diversity and performance, echoing the spirit of [[recursive self-improvement works when LLM judges detect friction patterns and the agent implements its own fixes]].

Perhaps most striking is the **weak-to-strong transfer**: an 8B parametric module can meaningfully boost agents built on 70B+ scale LLMs. The smaller model doesn't need to be accurate — it just needs to produce diverse reflections that expand the hypothesis space for error diagnosis. This has direct implications for cost-efficient deployment, since the parametric module runs independently and can be much smaller than the base agent.

The temperature-controlled sampling strategy is elegant: T=0.2 for the first iteration (focused, high-confidence reflection), then T=1.0 for subsequent iterations (maximum diversity). This avoids the embedding collapse problem that plagues retrieval-based approaches like DoT-bank, where learned embeddings degenerate into low-rank subspaces.

Across programming (HumanEval, MBPP, LiveCodeBench), math (MATH), and multi-hop QA (HotpotQA, 2WikiMultiHopQA), ParamAgent and ParamAgent-plus consistently outperform all baselines. The gains are especially large for code (+23-34 points on HumanEval) and multi-hop QA (+20-60 points on 2WikiMultiHopQA), where diverse diagnostic hypotheses matter most.

## External Resources

- <https://github.com/tianyao-aka/ParamAgent> — Code and data for ParamMem/ParamAgent
- <https://arxiv.org/abs/2602.23320> — Full paper on arXiv

## Original Content

> [!quote]- Source Material — ParamMem: Augmenting Language Agents with Parametric Reflective Memory (Yao et al., March 2026)
>
> ### ParamMem: Augmenting Language Agents with Parametric Reflective Memory
>
> Tianjun Yao, Yongqiang Chen, Yujia Zheng, Pan Li, Zhiqiang Shen, Kun Zhang
>
> Mohamed bin Zayed University of Artificial Intelligence, Carnegie Mellon University, Georgia Institute of Technology. Preprint. March 2, 2026.
>
> #### Abstract
>
> Self-reflection enables language agents to iteratively refine solutions, yet often produces repetitive outputs that limit reasoning performance. Recent studies have attempted to address this limitation through various approaches, among which increasing reflective diversity has shown promise. Our empirical analysis reveals a strong positive correlation between reflective diversity and task success, further motivating the need for diverse reflection signals. We introduce ParamMem, a parametric memory module that encodes cross-sample reflection patterns into model parameters, enabling diverse reflection generation through temperature-controlled sampling. Building on this module, we propose ParamAgent, a reflection-based agent framework that integrates parametric memory with episodic and cross-sample memory. Extensive experiments on code generation, mathematical reasoning, and multi-hop question answering demonstrate consistent improvements over state-of-the-art baselines. Further analysis reveals that ParamMem is sample-efficient, enables weak-to-strong transfer across model scales, and supports self-improvement without reliance on stronger external model, highlighting the potential of ParamMem as a effective component for enhancing language agents. Code and data can be found at: https://github.com/tianyao-aka/ParamAgent.
>
> #### 1. Introduction
>
> Large language models (LLMs) have exhibited remarkable progress in complex reasoning tasks. A key insight driving recent advances is test-time scaling, i.e., allocating additional computation during inference to improve reasoning.
>
> *Correlation between reflective diversity and task performance across five datasets*
> ![[parammem-_page_0_Figure_8.jpeg]]
>
> Among these approaches, reflection-based frameworks have proven particularly effective, where agents verbally reflect on task feedback and accumulate self-reflections in episodic memory to guide subsequent trials. Such reflection mechanisms have been successfully applied to programming, mathematical reasoning, decision-making, and multi-agent systems.
>
> However, recent studies have identified limitations in self-reflection, showing that it often produces repetitive and inaccurate outputs, which hinders the effectiveness of self-reflection. Among these works, Lingam et al. (2025) attempts to increase reflective diversity through prompt-level modifications (DoT) and by incorporating cross-sample trajectories (DoT-bank), demonstrating preliminary success. In this work, we first explore how reflective diversity relates to final performance. Specifically, we conduct experiments on five datasets using LLaMA-3.1-8B, computing the pairwise cosine distance across multi-round reflection logs for each sample under Reflexion, DoT, and DoT-bank, and averaging these distances. The average Pearson correlation coefficient across the five datasets is 0.76, indicating a strong positive relationship between reflective diversity and task performance.
>
> Despite its effectiveness, the retrieval-based approach like DoT-bank relies on embedding similarity to retrieve cross-sample trajectories, which has limited capacity for capturing compositional patterns; moreover, learned embeddings are prone to collapse into low-rank subspaces, reducing retrieval diversity. This naturally raises our question: **How can we further expand reflective diversity to achieve stronger reasoning performance?**
>
> To address this challenge, we introduce **ParamMem**, a new form of reflective memory that provides diversity through a fundamentally different mechanism. Unlike approaches that rely on prompt variations and retrieval-based methods that explicitly utilize similar samples, ParamMem operates by fine-tuning a lightweight parametric module on an auxiliary reflection dataset. Through training, the module encodes cross-sample patterns into its parameters; at inference time, it generates reflections by generalizing from these learned patterns rather than retrieving existing examples.
>
> **Contribution.** We propose a new paradigm for enhancing reflective diversity to improve reasoning in language agents. Central to our approach is ParamMem, a parametric memory module that internalizes cross-sample reflection patterns. ParamMem targets diversity, is lightweight, and can seamlessly integrate into existing reflection-based frameworks. Building upon ParamMem, we propose ParamAgent and its enhanced variant ParamAgent-plus, which unify parametric reflective memory with episodic and cross-sample memory within a coherent framework. Through extensive empirical evaluation, our method exhibits several notable advantages: (1) Substantial performance gains across programming, mathematical reasoning, and multi-hop question answering. (2) Sample efficiency — only ~500 training samples needed. (3) Self-improvement without relying on stronger external models. (4) Weak-to-strong transfer — even when trained using a weaker LLM, its generated reflective signals still enhance ParamAgent built on stronger LLMs.
>
> #### 2. Preliminaries
>
> We consider a pretrained language model p_θ that generates output y given input x. We use r_1, ..., r_k to denote self-reflections accumulated up to k iterations, and use r_k^g to denote the model-based outputs sampled from the parametric memory module M_g.
>
> **Reflexion Framework.** Reflexion enables iterative reasoning through four components: (1) an actor p_θ that generates candidate solutions, (2) an evaluator that provides task-specific feedback, (3) a self-reflection module that converts feedback into natural language reflections diagnosing errors, and (4) an episodic memory M that stores reflections from prior iterations. At iteration k, the actor generates candidate solutions conditioned on accumulated reflections: y_k ~ p_θ(· | x, r_{1:k-1}).
>
> **Cross-Sample Memory.** Cross-sample memory leverages past experiences or external logs to enhance agent reasoning capabilities. Given a new task, relevant trajectories are retrieved from the memory bank and incorporated into the prompt: y ~ p_θ(· | x, r_{1:k}, RETRIEVE(B, x)).
>
> In ParamAgent, the actor generates solutions conditioned on both episodic memory and parametric memory: y_k ~ p_θ(· | x, r_{1:k-1}, r_k^g), where r_k^g ~ p_φ(· | x) denotes the reflection sampled from ParamMem. ParamAgent-plus further incorporates cross-sample memory, conditioning on all three memory sources: y_k ~ p_θ(· | x, r_{1:k-1}, RETRIEVE(B, x), r_k^g).
>
> *Comparison of memory mechanisms across different frameworks*
> ![[parammem-_page_2_Figure_1.jpeg]]
>
> #### 3. Augmenting Language Agents with ParamMem
>
> **3.1. Building ParamMem**
>
> The core idea of ParamMem is to implicitly capture cross-sample regularities via training dynamics. Through fine-tuning, the module learns to generalize reflection patterns to unseen examples, rather than relying on prompt-based instructions or retrieving similar samples. The building process begins with constructing an auxiliary dataset D = {(x_i, r_i^g)}. We then fine-tune a pretrained LLM on D using LoRA to obtain the parametric module M_g.
>
> For programming and math tasks, r_i^g takes the form of reflective feedback that enumerates potential mistakes and buggy implementations. For multi-hop QA, we prompt the LLM to decompose the query into compact semantic units and potential reasoning sub-tasks.
>
> *Illustration of the output produced by ParamMem*
> ![[parammem-_page_3_Figure_1.jpeg]]
>
> **3.2. Incorporating ParamMem into Reflexion-based Framework**
>
> Once the parametric module M_g is obtained, we incorporate it into the Reflexion-based framework. At the k-th iteration, we additionally sample a model-based output r_k^g ~ p_ψ(· | x) from M_g and concatenate it with the self-reflections: y_k ~ p_θ(· | x, r_{1:k-1}, r_k^g). ParamAgent-plus additionally retrieves reasoning trajectories from a memory bank B of previously solved tasks: y_k ~ p_θ(· | x, r_{1:k-1}, r_k^g, τ_{1:i}).
>
> **Algorithm 1:** Phase 1 (ParamAgent) iterates up to T_max times: sample from M_g with T=0.2 for first iteration, T=1.0 thereafter; generate solution; if correct, store trajectory; otherwise generate self-reflection. Phase 2 (ParamAgent-plus) reattempts failed tasks with additional cross-sample trajectories.
>
> #### 4. Experiments
>
> **4.1. Setup**
>
> Datasets: HumanEval, MBPP, LiveCodeBench (programming); MATH (math reasoning); HotpotQA, 2WikiMultiHopQA (multi-hop QA). Evaluation: Pass@1 for programming, 0-1 accuracy for math/QA. Baselines: Base, Reflexion, Retroformer, DoT, DoT-bank. Backbone LLMs: Llama-3.1-8B, Mistral-7B-v0.2, Qwen2-1.5B-instruct. LoRA config: r=128, α=32, lr=2e-5, 3 epochs.
>
> **4.2. Experimental Results**
>
> **Observation 1: ParamMem consistently enhances Reflexion-based frameworks across all domains.** On HumanEval with Llama-3.1-8B: ParamAgent achieves 82.93 (+23.78 over Base), outperforming DoT-bank's 79.56. On MBPP: ParamAgent 67.00 vs DoT-bank 64.82. On 2WikiMultiHopQA: ParamAgent 88.67 (+48.34) vs DoT-bank 80.33. On MATH, cross-sample trajectories play a more critical role, but ParamAgent-plus still outperforms DoT-bank (75.45 vs 73.02).
>
> **Observation 2: ParamMem induces an additional layer of reflective diversity.** Clustering analysis shows ParamAgent achieves K*=39 optimal clusters, substantially larger than Reflexion, DoT, and DoT-bank. Silhouette scores are consistently higher, confirming superior clustering quality and semantic coherence.
>
> *Reflection diversity analysis: pairwise cosine distance, clustering, and silhouette scores*
> ![[parammem-_page_6_Figure_1.jpeg]]
> ![[parammem-_page_6_Figure_2.jpeg]]
> ![[parammem-_page_6_Figure_3.jpeg]]
>
> **Observation 3: Diverse reflections enlarge the hypothesis space for error diagnosis.** Case study on MBPP shows Reflexion and DoT produce misleading reflections, while ParamAgent's increased diversity provides broader diagnostic hypotheses.
>
> **Observation 4: ParamMem supports agent self-improvement without stronger external models.** Using Llama-3.1-8B as both agent and data generator: ParamAgent-plus reaches 86.59 on HumanEval and 83.33 on HotpotQA, outperforming all baselines.
>
> *Iterative self-teaching performance on HumanEval*
> ![[parammem-_page_6_Figure_8.jpeg]]
>
> **Observation 5: Iterative self-teaching further enhances ParamAgent.** Starting from Llama-3.1-8B-Instruct, fine-tuning ParamMem and iterating for 3 rounds shows steady improvement.
>
> **Observation 6: Weak-to-strong transfer.** With Qwen3-Next-80B-A3B-Instruct as base, ParamMem instantiated by Llama-3.1-8B or Qwen3-Next-30B-A3B consistently outperforms baselines. On LiveCodeBench: ParamAgent-plus reaches 68.00 (+16.00 over base).
>
> **Observation 7: Sample efficiency.** 500 K-means-selected training examples yield ParamAgent 81.71 on HumanEval (vs 82.93 with 8000+ samples). ParamAgent-plus with 500 samples (86.59) outperforms ParamAgent with 8000+.
>
> #### 5. Related Work
>
> **LLM Reasoning and Diversity:** CoT prompting, Self-Consistency, ReAct, Tree of Thoughts, Graph of Thoughts, DoT.
>
> **Improving Reflection in LLM Agents:** Retroformer (policy gradient for reflection accuracy), Self-RAG (reflection tokens), ExpeL (experiential learning).
>
> **Self-improving Language Agents:** STaR (bootstrapped reasoning), ReST/ReST-EM (self-generated training data), Self-Rewarding Language Models, SPIN (self-play fine-tuning). ParamMem requires no external reward signal or human annotation.
>
> **Memory Systems for Language Agents:** Generative Agents (memory stream), MemGPT (virtual memory management), MemoryBank (Ebbinghaus forgetting curves), ExpeL (experience pools). Nearly all existing memory systems are retrieval-based.
>
> **Parametric Approaches:** Retroformer (RL-trained retrospective model), Self-RAG (reflection tokens), LEMA (mistake-correction pairs), SCoRe (multi-turn RL for self-correction), MemoryLLM (self-updatable memory pool).
>
> #### 6. Conclusions and Limitations
>
> ParamMem induces an additional layer of diversity beyond episodic and cross-sample memory. ParamAgent and ParamAgent-plus deliver substantial performance gains across 3 domains. Limitation: increased token consumption in certain scenarios, inherent cost of additional reflective diversity.
>
> Source: https://arxiv.org/abs/2602.23320
