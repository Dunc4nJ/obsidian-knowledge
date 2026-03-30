---
created: 2026-03-30
description: "AIRA2 overcomes three structural bottlenecks in AI research agents — compute throughput, evaluation noise, and static operators — achieving 76% percentile rank on MLE-bench-30 at 72 hours with monotonic improvement"
source: https://arxiv.org/abs/2603.26499
type: paper
authors:
  - Karen Hambardzumyan
  - Nicolas Baldwin
  - Edan Toledo
  - Rishi Hazra
  - Michael Kuchnik
  - Martin Josifoski
arxiv: "2603.26499"
---

## Abstract

AIRA2 addresses three structural bottlenecks in AI research agents: synchronous single-GPU execution constraining throughput, a generalization gap where validation-based selection degrades over extended search, and limited capability of fixed single-turn LLM operators. The system introduces an asynchronous multi-GPU worker pool for linear throughput scaling, a Hidden Consistent Evaluation protocol for reliable evaluation signal, and ReAct agents for dynamic multi-step reasoning. On MLE-bench-30, AIRA2 achieves 71.8% mean Percentile Rank at 24 hours (surpassing the previous best of 69.9%) and improves to 76.0% at 72 hours.

*Figure 1: AIRA2 performance on MLE-bench-30*
![[aira2-2603-001.jpeg]]

## Key Takeaways

The core insight is that [[autoresearch agents exploit unconstrained metrics and need multi-objective gates with regular human steering|evaluation noise, not true overfitting, causes performance degradation]] in long-horizon AI research agents. AIRA2's Hidden Consistent Evaluation protocol — fixing data splits externally and hiding validation labels from agents — proves that what prior work called "overfitting" was actually evaluation procedure noise. Once the metric is stationary, performance improves monotonically with compute, which is a prerequisite for [[scaling autoresearch to 16 GPUs changes the search strategy not just the speed|scaling autonomous research to many GPUs]].

The async multi-GPU architecture confirms that [[distributed research swarms close the feedback loop that single-agent autoresearch leaves open|parallelism without shared state is worthless]] — a Best-of-K baseline with 8 GPUs converges to the exact same ceiling as a single-GPU evolutionary agent. The evolutionary selection mechanism is what converts parallel compute into higher asymptotic performance, not just faster wall-clock convergence. This echoes the finding from [[autoresearch loops cheat when guardrails are loose but converge on real findings when tightly scoped|autoresearch loops]] that environment design trumps raw compute.

ReAct agents replacing static operators act as an efficiency multiplier rather than a capability ceiling breaker. The performance gap narrows from 5.5 points at 3 hours to 2.3 points at 72 hours, suggesting that evolutionary search can eventually compensate for operator weakness — but interactive debugging and dynamic scoping get you there much faster. This parallels the [[praxlab generalizes autoresearch into a multi-task harness that ran 550 experiments with zero intervention|PraxLab]] finding that structured agent trajectories with memory outperform simple iteration.

The "eureka moment" case study on champs-scalar-coupling is striking: the agent correctly diagnosed underfitting (15 min training in a 9-hour budget with converging loss) rather than rejecting the auxiliary task that temporarily lowered scores. No other evaluated agent achieved a medal on this task. This kind of reasoning — distinguishing poor methodology from poor execution — is what separates [[tight constraints make autonomous agents more useful than open-ended freedom|constrained but capable agents]] from blind search.

The paper uses Gemini 3.0 Pro Preview as the backbone LLM and 8x NVIDIA H200 GPUs. Despite reserving 20% of training data for evaluation (a conservative handicap), AIRA2 still beats all baselines including concurrent work like MARS+ and FM-Agent 2.0.

## External Resources

- [MLE-bench](https://openreview.net/forum?id=6s5uXNWGIh) — benchmark of 30 Kaggle competitions for evaluating ML research agents
- [AIRA-dojo (Toledo et al., 2025)](https://openreview.net/forum?id=RwfrdKSgCE) — predecessor work formalizing the three bottlenecks addressed here
- [AIDE (Jiang et al., 2025)](https://arxiv.org/abs/2502.13138) — AI-driven exploration agent for code generation
- [MARS (Chen et al., 2026)](https://arxiv.org/abs/2602.02660) — modular agent with reflective search, concurrent work
- [AlphaEvolve (Novikov et al., 2025)](https://arxiv.org/abs/2506.13131) — evolutionary coding agent for scientific discovery
- [The AI Scientist v2 (Yamada et al., 2025)](https://arxiv.org/abs/2504.08066) — agentic tree search for automated scientific discovery

## Original Content

> [!quote]- Full Paper Text
> # AIRA2: Overcoming Bottlenecks in AI Research Agents
>
> Karen Hambardzumyan1,2,<sup>∗</sup> , Nicolas Baldwin1,<sup>∗</sup> , Edan Toledo1,2,<sup>∗</sup> , Rishi Hazra1,<sup>∗</sup> , Michael Kuchnik1,<sup>∗</sup> , Bassel Al Omari<sup>1</sup> , Thomas Simon Foster1,<sup>3</sup> , Anton Protopopov<sup>1</sup> , Jean-Christophe Gagnon-Audet<sup>1</sup> , Ishita Mediratta<sup>1</sup> , Kelvin Niu<sup>1</sup> , Michael Shvartsman<sup>1</sup> , Alisia Lupidi1,<sup>3</sup> , Alexis Audran-Reiss<sup>1</sup> , Parth Pathak<sup>1</sup> , Tatiana Shavrina<sup>1</sup> , Despoina Magka<sup>1</sup> , Hela Momand<sup>1</sup> , Derek Dunfield<sup>1</sup> , Nicola Cancedda<sup>1</sup> , Pontus Stenetorp<sup>2</sup> , Carole-Jean Wu<sup>1</sup> , Jakob Nicolaus Foerster1,<sup>3</sup> , Yoram Bachrach<sup>1</sup> , Martin Josifoski1,<sup>∗</sup>
>
> Existing research has identified three structural performance bottlenecks in AI research agents: (1) synchronous single-GPU execution constrains sample throughput, limiting the benefit of search; (2) a generalization gap where validation-based selection causes performance to degrade over extended search horizons; and (3) the limited capability of fixed, single-turn LLM operators imposes a ceiling on search performance. We introduce AIRA2, which addresses these bottlenecks through three architectural choices: an asynchronous multi-GPU worker pool that increases experiment throughput linearly; a Hidden Consistent Evaluation protocol that delivers a reliable evaluation signal; and ReAct agents that dynamically scope their actions and debug interactively. On MLE-bench-30, AIRA<sup>2</sup> achieves a mean Percentile Rank of 71.8% at 24 hours—surpassing the previous best of 69.9%—and steadily improves to 76.0% at 72 hours. Ablation studies reveal that each component is necessary and that the "overfitting" reported in prior work was driven by evaluation noise rather than true data memorization.
>
> Correspondence: Martin Josifoski at [martinjosifoski@meta.com](mailto:martinjosifoski@meta.com)
>
> ### 1 Introduction
>
> The rapid advancement of Large Language Model (LLM) capabilities has enabled the development of autonomous agents capable of executing complex, multi-step workflows [\(Josifoski et al.,](#page-13-0) [2023;](#page-13-0) [Wu et al.,](#page-14-0) [2024\)](#page-14-0). While these agents have achieved remarkable success in software engineering [\(Wang et al.,](#page-14-1) [2025b;](#page-14-1) [Anthropic,](#page-13-1) [2025;](#page-13-1) [OpenAI,](#page-14-2) [2025\)](#page-14-2) and mathematics [\(Novikov et al.,](#page-14-3) [2025;](#page-14-3) [Hubert et al.,](#page-13-2) [2025\)](#page-13-2)—benefiting from execution environments with rapid feedback loops of verifiable signal—automating the scientific process presents a
>
> *Figure 1: AIRA2 performance on MLE-bench-30*
> ![[aira2-2603-001.jpeg]]
>
> Figure 1 : AIRA<sup>2</sup> performance on MLE-bench-30. We evaluate AIRA<sup>2</sup> against top-performing agents from the MLE-bench leaderboard across different compute budgets. Utilizing 8 GPU workers for all configurations, AIRA<sup>2</sup> matches the performance of the strongest leaderboard agents at a 24-GPU-hour budget. Performance improves consistently with additional compute, demonstrating the effectiveness of our architectural design.
>
> <sup>1</sup>FAIR at Meta, <sup>2</sup>University College London, <sup>3</sup>University of Oxford
>
> <sup>∗</sup>Equal contribution (author order determined by Mario Kart placement)
>
> distinct class of challenges. Scientific research requires agents to learn through controlled experimentation within a vast, partially observable, open-ended design space [\(Langley et al.,](#page-13-3) [1987\)](#page-13-3). Unlike coding, research involves navigating noisy evaluation signals and designing proxy tasks to estimate performance [\(Chan et al.,](#page-13-4) [2025\)](#page-13-4). Furthermore, given the high computational cost and latency of valid experiments, optimizing the research process requires looking beyond individual reasoning capabilities: research agents must be designed to manage long-horizon exploration and parallelize compute-intensive evaluations efficiently.
>
> The best performing open-source agent on MLE-bench[1](#page-1-0) [\(Chan et al.,](#page-13-4) [2025\)](#page-13-4), AIRA-dojo [\(Toledo et al.,](#page-14-4) [2025\)](#page-14-4), frames research agents as a search over candidate solutions, that can be decomposed into search policies and operators. Through systematic ablations, the authors formalized three structural bottlenecks preventing further scaling: (1) Compute Throughput—synchronous single-GPU execution constrains sample generation and limits exploration; (2) Generalization Gap—validation-test divergence misleads the search signal, causing overfitting over extended research horizons; and (3) Operator Capability—fixed, single-turn operators limit the agent to shallow, single-turn reasoning that sophisticated search cannot overcome. As noted by [Chan](#page-13-4) [et al.](#page-13-4) [\(2025\)](#page-13-4); [Jiang et al.](#page-13-5) [\(2025\)](#page-13-5); [Zhu et al.](#page-15-0) [\(2026\)](#page-15-0), these performance plateaus emerge even within a relatively short 24-hour regime, suggesting that addressing these fundamental bottlenecks is a prerequisite for effectively utilizing additional compute.
>
> Guided by these insights, we introduce AIRA2, a research agent designed to overcome these structural bottlenecks. AIRA<sup>2</sup> resolves the three bottlenecks via specific architectural choices: (1) asynchronous multi-agent exploration, (2) a Hidden Consistent Evaluation protocol, and (3) dynamically scoped ReAct agents.
>
> First, the standard reliance on synchronous single-GPU execution severely bottlenecks throughput: the search process stalls whenever an expensive experiment runs, starving exploration of samples and limiting the learnings from experiment results within the available wall-clock budget. AIRA<sup>2</sup> introduces an asynchronous multi-GPU worker pool and containerization system that decouples decision-making from execution, enabling massively parallel experimentation and increasing experiment throughput linearly with available GPU resources. Concretely, 8 GPUs yield approximately 8× the experimental throughput, compressing what would otherwise require days of sequential exploration into hours.
>
> Second, the generalization gap undermines long-horizon search: agents optimize validation metrics at the expense of held-out test performance, causing trajectories to overfit. AIRA<sup>2</sup> addresses this overfitting with a Hidden Consistent Evaluation (HCE) protocol, which stabilizes the evaluation noise by keeping data splits fixed throughout the search, hides validation labels from the agent to prevent metric gaming, and separates the search-time evaluation signal from final model selection. HCE leads to improved performance at the 24-hour mark, and enables continued performance gains with additional compute.
>
> Third, operators that depend on fixed prompts and single-turn actions impose a performance ceiling: for example, a static "debug" prompt cannot iteratively diagnose complex errors, and no amount of search sophistication can compensate. AIRA<sup>2</sup> replaces all operators with ReAct agents [\(Yao et al.,](#page-15-1) [2022\)](#page-15-1) that autonomously scope their actions—performing exploratory data analysis, running small development experiments, inspecting logs, and more, thus alleviating the limitations of operator design. ReAct agents expand the range of tasks the system can tackle, improve performance, and speed up the discovery of strong solutions, making search more efficient.
>
> Together, these design decisions in compute, evaluation, and operators, enable AIRA<sup>2</sup> to achieve a state-ofthe-art mean Percentile Rank of 71.8% and 76.0% at 24 and 72 hours, respectively, on MLE-bench-30 [\(Singh](#page-14-5) [et al.,](#page-14-5) [2025\)](#page-14-5), demonstrating the value of systems designed for high-throughput, open-ended exploration.
>
> ### <span id="page-1-1"></span>2 Background
>
> The domain of automated machine learning has shifted rapidly from simple heuristics [\(Bergstra and Bengio,](#page-13-6) [2012;](#page-13-6) [Elsken et al.,](#page-13-7) [2017;](#page-13-7) [Li et al.,](#page-14-6) [2018\)](#page-14-6) to autonomous agents capable of long-horizon research [\(Yamada](#page-15-2) [et al.,](#page-15-2) [2025\)](#page-15-2). Recent state-of-the-art systems, such as MARS [\(Chen et al.,](#page-13-8) [2026\)](#page-13-8), MLEvolve [\(Du et al.,](#page-13-9) [2025\)](#page-13-9),
>
> <span id="page-1-0"></span><sup>1</sup>A challenging benchmark where agents compete in Kaggle competitions.
>
> PiEvolve [\(Botla et al.,](#page-13-10) [2025\)](#page-13-10), FM-Agent 2.0 [\(Li et al.,](#page-13-11) [2025\)](#page-13-11), and ML-Master 2.0 [\(Liu et al.,](#page-14-7) [2025b\)](#page-14-7), leverage inference-time scaling and evolutionary search to solve Kaggle competitions. These systems typically model research as a search process over a graph of candidate solutions. However, despite these advances, performance is currently hindered by three structural bottlenecks identified in prior formalizations of the agentic research process [\(Toledo et al.,](#page-14-4) [2025\)](#page-14-4).
>
> ### <span id="page-2-0"></span>2.1 The Compute & Throughput Bottleneck
>
> Effective search requires high sample throughput—the number of candidate solutions generated and evaluated per unit time—to explore the vast combinatorial space of ML solutions. However, the standard agent architecture often relies on synchronous execution, where the reasoning loop blocks while waiting for experimental feedback.
>
> In the context of MLE-bench, where model training and evaluation can take hours, this serialization is catastrophic. A synchronous agent is effectively "sample-bound," and, on compute-heavy tasks, limited to evaluating only ≈1–20 candidates per day. This throughput is insufficient to support the deep exploration required by evolutionary or tree-search methods, rendering them theoretically powerful but practically intractable without parallelization.
>
> #### <span id="page-2-1"></span>2.2 The Generalization Gap (Overfitting)
>
> The utility of any search process is contingent on the fidelity of its reward signal. Crucially, this signal need not be a single quantitative metric—in many research settings, such a reduction is neither possible nor desirable. What matters is that the signal, whether numeric, qualitative, or composite, faithfully represents the underlying phenomenon under study. In the competition setting of MLE-bench, this principle manifests concretely as the generalization gap—the divergence between the validation metric (used to guide the search) and the held-out test metric (the true objective).
>
> Oracle experiments in prior work revealed that selecting the final submission based on test scores rather than validation scores improves medal rates by 9–13% (absolute) [\(Toledo et al.,](#page-14-4) [2025\)](#page-14-4). This gap stems from two sources: (1) agents "gaming" self-reported metrics to satisfy the search objective, and (2) the reuse of the validation set for both hill-climbing (optimization) and final selection, which inevitably leads to overfitting as the search horizon extends. Beyond algorithmic overfitting, the search signal is frequently corrupted by execution noise. Implementation bugs can spuriously inflate validation metrics (see Appendix [A](#page-16-0) for a concrete example), while brittle output parsing often leads to missing or erroneous score extraction. Furthermore, stochasticity in data splitting introduces significant variance, allowing inferior solutions to survive selection purely due to favourable random seeds. Closing the generalization gap is therefore a prerequisite for reliable automated research: without a trustworthy reward signal, even a perfect search algorithm will converge on solutions that exploit evaluation artifacts rather than capture genuine predictive structure.
>
> #### <span id="page-2-2"></span>2.3 The Static Operator Limitation
>
> Research agents can be decomposed into a search policy (which selects which node to expand) and a set of atomic operators (which transform a node into new candidates). In practice, these operators are often hand-designed for anticipated sub-tasks: one prompt for exploratory data analysis, another for feature engineering, another for hyperparameter tuning, and so on. This design is fundamentally brittle: each new domain demands additional human-scoped operators, and the agent can only perform actions its designers anticipated. As tasks grow in complexity—requiring multi-file codebases, shared artifacts, and iterative debugging—a fixed operator pipeline cannot adapt to the unpredictable dependencies that arise.
>
> Empirically, [Toledo et al.](#page-14-4) [\(2025\)](#page-14-4) demonstrated that when operators are static (e.g., fixed Draft/Improve prompts), more advanced search algorithms yield no statistically significant improvement over greedy baselines though this finding is confounded by evaluation noise. Beyond search effectiveness, fixed operators cannot dynamically allocate compute proportional to the difficulty of a sub-problem, limiting the agent to solutions reachable by shallow, single-turn reasoning.
>
> <span id="page-3-0"></span>> *Figure 2: AIRA2 architecture*
> ![[aira2-2603-002.jpeg]]
>
> Figure 2: AIRA<sub>2</sub> architecture. The Evolutionary Agent orchestrates the search by maintaining a population of candidate solutions and dispatching mutation tasks to the N workers as they become available, without any synchronization barriers. Each worker asynchronously executes a ReAct agent which iteratively reasons, executes code, and observes outputs until a candidate solution is ready. Candidate solutions are evaluated in a separate container, and agents observe only the resulting score. Evaluation is partitioned:  $\mathcal{D}_{\text{search}}$  guides optimization while  $\mathcal{D}_{\text{val}}$  determines final selection. In our main experiments, we use N=8 workers.
>
> ### 3 AIRA<sub>2</sub> Research Agent Design
>
> In this section, we describe the design of AIRA<sub>2</sub>, a system that addresses the three bottlenecks identified in Section 2. Its architecture comprises two tiers: a **Global Orchestrator** that coordinates search over a population of candidates, and an **Asynchronous Worker Pool of ReAct agents** mutating solutions in isolated containers (Figure 2).
>
> #### 3.1 Evolutionary Search
>
> The orchestrator maintains a population  $\mathcal{P}$  of candidate solutions, their fitness scores, and all other associated metadata. Search proceeds via asynchronous, steady-state evolution (Syswerda, 1991): whenever a worker becomes available, the orchestrator samples a parent (or two) and dispatches a mutation/crossover task.
>
> **Selection.** Parents are sampled via temperature-scaled rank-based selection. Given a population  $\mathcal{P}$  of size N sorted by fitness, we assign rank  $r_i \in \{1, \dots, N\}$  to each individual (where 1 is the best). The probability of selecting individual i is:
>
> $$p(i) = \frac{(N - r_i + 1)^{1/T}}{\sum_{j=1}^{N} (N - r_j + 1)^{1/T}},$$
> (1)
>
> where T controls the exploration-exploitation tradeoff. As  $T \to 0$ , the policy becomes greedy (selecting the rank 1 individual), while higher T increases diversity. We opted for rank-based rather than fitness-proportionate selection because ranks are invariant to the magnitude and scale of fitness scores, which vary widely across tasks.
>
> **Mutation/Crossover.** The orchestrator randomly selects between mutation (refining a single parent) and crossover (combining two parents) with probability c. Both operations are executed by ReAct agents (Section 3.4), which receive the parent solution(s) (and other metadata) as context.
>
> #### 3.2 Scaling Compute: Asynchronous Multi-GPU Execution
>
> The asynchronous nature of steady-state evolution inherently facilitates parallel orchestration, allowing us to distribute the search workload across concurrent workers without synchronization barriers. Unlike generational evolution, which must wait for all workers to complete before proceeding, steady-state evolution allows the orchestrator to sample parents and dispatch mutations as soon as any individual worker becomes available. This is particularly beneficial when mutations are longer, more involved processes—such as multi-step ReAct trajectories that may vary widely in duration—since fast-completing workers are never left idle waiting for slower ones. To bypass the complexity of dynamic resource scheduling, we adopt a static allocation scheme where each worker is assigned a dedicated GPU. This hardware configuration is mirrored across both development and evaluation environments, ensuring that every execution begins from an identical, clean slate.
>
> Remote Execution & Containerization. We employ a remote tool execution system to decouple agent logic from the execution environment. Workers execute code within ephemeral Apptainer [\(Kurtzer et al.,](#page-13-12) [2021\)](#page-13-12) containers using the Superimage environment [\(Toledo et al.,](#page-14-4) [2025\)](#page-14-4), which comes pre-installed with a comprehensive suite of Python, machine learning, and data science packages. Crucially, containers run in fakeroot mode, granting the agent perceived root privileges to install system-level dependencies via apt or pip. This setup ensures a flexible, reproducible, and robust action space where crashed containers do not affect the orchestrator or other workers.
>
> Stateful Interaction. Unlike previous systems such as AIDE [\(Jiang et al.,](#page-13-5) [2025\)](#page-13-5) and AIRA-dojo, our Bash command and Jupyter kernel execution tools are stateful. This allows agents to maintain context across multiple turns, enabling a more interactive and iterative debugging process. Tool outputs also include execution duration, allowing agents to monitor their own efficiency.
>
> Resource Allocation. We enforce a strict 1:1 worker-to-GPU mapping using NVIDIA H200 GPUs (141GB VRAM). Each worker is allocated 12 logical CPU cores and a dedicated 120GB of system RAM, providing sufficient compute for training large models, running hyperparameter sweeps, or building deep ensembles without resource contention.
>
> Data Management & Limits. The program database resides in-memory for fast access, with large artifacts automatically offloaded to hard disk. Subagents communicate exclusively through this central database, contributing ideas and code asynchronously. To optimize resource utilization, evaluation is performed in the foreground without a separate job queue, running in an identical container with a dedicated GPU. The search process continues until a global hard limit is reached, with individual code executions capped at a 9-hour hard time limit to prevent stalled processes.
>
> #### <span id="page-4-0"></span>3.3 Closing the Generalization Gap: Hidden Consistent Evaluation
>
> To close the generalization gap, AIRA<sup>2</sup> decouples the signal used for search from the signal used for final selection, and externalizes all evaluation to prevent metric gaming. Beyond serving as a practical safeguard, this protocol is designed as an experimental tool: by controlling the evaluation procedure, we can systematically test whether agents truly overfit to their data or whether previously reported degradation stems from evaluation noise (Section [4.3.2\)](#page-8-0).
>
> Data partitioning. Before search begins, available labels are split into three disjoint sets:
>
> - Dtrain: visible to the agent for model training.
> - Dsearch: used by the orchestrator for fitness computation; labels hidden from agents.
> - Dval: used only for final selection after search terminates; hidden from both agents and the search process.
>
> These splits are created once via random sampling of the available labeled training data (80%/10%/10%) and reused identically across all seeds. Notably, baselines are evaluated using their published results on the test set with access to all training data, while AIRA<sup>2</sup> reserves 20% of training data for search/selection, making the comparison conservative. Upon submission, the solution submits predictions for  $\mathcal{D}_{test}$ . Thus, all splits are consistent across programs and seeds.
>
> **Externalized evaluation.** Agents never self-report metrics. When a worker returns a solution, the orchestrator evaluates it on  $\mathcal{D}_{\text{search}}$  in a separate container, mirroring the dev environment. Agents observe only the resulting score, not the labels, preventing feedback loops that enable metric hacking. The evaluation is performed on all  $\mathcal{D}_{\text{search}}$ ,  $\mathcal{D}_{\text{val}}$  and  $\mathcal{D}_{\text{test}}$  splits, but  $\mathcal{D}_{\text{test}}$  is neither forwarded to agents nor to orchestrator.
>
> **Decoupled selection.** Because  $\mathcal{D}_{val}$  is never used during search, the final selection is insulated from hill-climbing dynamics. This separation—combined with the hidden consistent evaluation procedures across all candidates—is designed to reduce the validation—test gap observed in prior systems.
>
> #### <span id="page-5-0"></span>3.4 Beyond Static Operators: ReAct Agents
>
> To overcome the operator limitations, AIRA<sub>2</sub> replaces static operators with ReAct agents (Yao et al., 2022) that execute multi-step reasoning trajectories. Each mutation produces a trajectory:
>
> $$\tau = (\text{Reason}_1, \text{Act}_1, \text{Obs}_1, \dots, \text{Reason}_{K-1}, \text{Act}_{K-1}, \text{Obs}_{K-1}, \text{Reason}_K, \text{Act}_K), \tag{2}$$
>
> where Actions (Act<sub>t</sub>) are Python or Bash commands executed in a sandboxed environment, and Observations (Obs<sub>t</sub>) consist of execution outputs. Within the ReAct trajectory, no additional guidance and instructions are provided. The final Act<sub>K</sub> is the "submit" tool, which sends the solution back to the orchestrator; the orchestrator then performs the evaluation and finally adds the program and the artifacts to the database.
>
> This formulation provides two capabilities that fixed operators lack:
>
> **Dynamic scoping.** The agent decides at runtime what actions are necessary. For tasks requiring exploratory data analysis, it inspects distributions and observes correlations before modelling; conversely, for tasks focused on model refinement, it prioritizes hyperparameter tuning and architecture evaluation. It has the ability to do local experimentation and simulation before committing to specific ideas. This eliminates brittle "scope engineering" in fixed operator prompts.
>
> **Interactive debugging.** When code raises an exception, the agent observes the traceback within the same trajectory, hypothesizes a fix, and re-executes—resolving errors without forfeiting the mutation attempt. Static Debug operators, by contrast, lack iterative access to the execution environment and require handcrafted re-prompting and consecutive operator calls.
>
> ### 4 Experiments and Results
>
> #### 4.1 Experimental Setup
>
> Tasks. We evaluate AIRA<sub>2</sub> on MLE-bench-30, a curated subset of 30 Kaggle competitions from MLE-bench (Chan et al., 2025) used in the GPT-5 system card (Singh et al., 2025). We opted for this subset to facilitate a lightweight yet representative evaluation; unlike MLE-bench Lite, which focuses primarily on low-complexity tasks, MLE-bench-30 spans a broader difficulty spectrum stratified into 5 low, 20 medium, and 5 high complexity tasks. Following standard protocol, we report the **medal rate**—the fraction of runs achieving at least a bronze medal on the Kaggle leaderboard. However, our primary analytical metric is **Percentile Rank**, representing the agent's simulated leaderboard position. Calculated as  $P = \frac{N-R}{N-1} \times 100$  (where N is total entries and R is the ordinal rank, with 1 being best), Percentile Rank offers three advantages over medal rate: (1) it is continuous rather than discrete, enabling finer-grained comparisons; (2) it captures the full distribution of performance rather than a binary medal outcome; and (3) it avoids threshold effects near medal boundaries that amplify noise in aggregate statistics (Audran-Reiss et al., 2025). Importantly, gains at higher percentiles are progressively harder to achieve, as each increment requires outperforming increasingly skilled human competitors.
>
> System configuration. While AIRA<sub>2</sub> can scale to large GPU counts, for these experiments, we use  $8 \times$  NVIDIA H200 GPUs (141GB VRAM each) with 1:1 worker-to-GPU mapping. Workers execute in Apptainer containers with CUDA, PyTorch, and standard data science libraries. ReAct agents are powered by Gemini 3.0 Pro
>
> <span id="page-6-0"></span>
>
> |                                   |              | % Percentile Rank |              | % Bronze+    |              |              | % Silver+    |              |              | % Gold       |              |              |
> |-----------------------------------|--------------|-------------------|--------------|--------------|--------------|--------------|--------------|--------------|--------------|--------------|--------------|--------------|
> | Method                            | 3h           | 24h               | 72h          | 3h           | 24h          | 72h          | 3h           | 24h          | 72h          | 3h           | 24h          | 72h          |
> | AIRA2                             | 59.9<br>±3.6 | 71.8<br>±3.5      | 76.0<br>±3.4 | 38.9<br>±5.2 | 57.8<br>±5.2 | 61.1<br>±5.2 | 33.3<br>±5.0 | 50.0<br>±5.3 | 58.9<br>±5.2 | 20.0<br>±4.2 | 32.2<br>±5.0 | 36.7<br>±5.1 |
> | AIRA2<br>(1 GPU)                  | 41.3<br>±3.9 | 56.8<br>±3.8      | 63.5<br>±3.8 | 22.2<br>±4.4 | 41.1<br>±5.2 | 51.1<br>±5.3 | 17.8<br>±4.1 | 32.2<br>±5.0 | 41.1<br>±5.2 | 10.0<br>±3.2 | 20.0<br>±4.2 | 24.4<br>±4.6 |
> | AIRA2<br>(No Subagents)           | 54.4<br>±3.7 | 68.6<br>±3.6      | 73.7<br>±3.6 | 33.3<br>±5.0 | 52.2<br>±5.3 | 60.0<br>±5.2 | 30.0<br>±4.9 | 47.8<br>±5.3 | 53.3<br>±5.3 | 13.3<br>±3.6 | 32.2<br>±5.0 | 37.8<br>±5.1 |
> | AIRA2<br>(No HCE)                 | 43.4<br>±3.8 | 56.8<br>±4.2      | 56.3<br>±4.3 | 29.7<br>±4.6 | 46.5<br>±5.0 | 47.5<br>±5.0 | 25.7<br>±4.4 | 45.5<br>±5.0 | 46.5<br>±5.0 | 12.9<br>±3.3 | 30.7<br>±4.6 | 32.7<br>±4.7 |
> | AIRA2<br>(No Evo.)                | 54.7<br>±3.6 | 64.0<br>±3.5      | 65.2<br>±3.5 | 35.3<br>±5.2 | 45.9<br>±5.4 | 47.1<br>±5.4 | 31.8<br>±5.1 | 40.0<br>±5.3 | 43.5<br>±5.4 | 16.5<br>±4.0 | 23.5<br>±4.6 | 24.7<br>±4.7 |
> | MARS+ (Chen et al., 2026)         |              | 69.9<br>±0.2      |              |              | 64.4<br>±1.1 |              |              | 51.1<br>±2.9 |              |              | 24.4<br>±2.2 |              |
> | FM-Agent 2.0 (Li et al., 2025)    |              | 69.6<br>±2.2      |              |              | 61.1<br>±2.9 |              |              | 57.8<br>±2.9 |              |              | 36.7<br>±3.3 |              |
> | MLEvolve (Du et al., 2025)        |              | 64.1<br>±0.3      |              |              | 57.8<br>±2.9 |              |              | 52.2<br>±1.1 |              |              | 22.2<br>±4.8 |              |
> | MARS (Chen et al., 2026)          |              | 60.4<br>±3.1      |              |              | 54.4<br>±4.0 |              |              | 44.4<br>±4.0 |              |              | 18.9<br>±1.1 |              |
> | ML-Master 2.0 (Liu et al., 2025b) |              | 57.6<br>±1.2      |              |              | 52.2<br>±4.0 |              |              | 40.0<br>±5.8 |              |              | 8.9<br>±1.1  |              |
> | PiEvolve (Botla et al., 2025)     |              | 54.1<br>±1.6      |              |              | 54.4<br>±1.1 |              |              | 50.0<br>±1.9 |              |              | 27.8<br>±5.6 |              |
> | AIRA-dojo (Toledo et al., 2025)   |              | 39.5<br>±0.7      |              |              | 25.8<br>±1.3 |              |              | 20.5<br>±1.2 |              |              | 8.8<br>±0.7  |              |
>
> Table 1 : Main performance evaluation of AIRA<sup>2</sup> across varying time budgets (3h, 24h, 72h). We report Percentile Rank metric and medal rates (Bronze+, Silver+, and Gold) for the full AIRA<sup>2</sup> method (8 GPUs, Subagents, Hidden Consistent Eval (HCE)) against ablations (1 GPU, No Subagents, No HCE) and state-of-the-art baselines (reported at 24h). Confidence intervals denote ±SE. AIRA2, at 72h, outperforms all baselines, demonstrating that the combination of parallel search, subagents, and HCE closes the gap to human-competitive performance.
>
> Preview [\(Google DeepMind,](#page-13-14) [2025\)](#page-13-14). The orchestrator runs steady-state evolution with temperature-scaled rank selection (T = 0.2) and crossover probability p<sup>c</sup> = 15%.
>
> Protocol. Each task runs for 72 hours wall-clock time. We run 3 independent seeds per task and report mean ± SE. Task data is partitioned as 80% Dtrain / 10% Dsearch / 10% Dval. Final submissions are evaluated directly on the held-out test set Dtest without retraining on the full available training data ∪{Dtrain, Dsearch, Dval}.
>
> #### 4.2 Main Results
>
> Table [1](#page-6-0) presents the performance of AIRA<sup>2</sup> under varying time budgets and component ablations. All reported baselines utilize Gemini 3.0 Pro Preview [\(Google DeepMind,](#page-13-14) [2025\)](#page-13-14), with the exception of ML-Master 2.0, which uses DeepSeek V3.2-Speciale [\(Liu et al.,](#page-14-9) [2025a\)](#page-14-9). We note that MARS+, MARS, FM-Agent 2.0, and MLEvolve are concurrent work released after the development and evaluation of AIRA2. MARS+ and ML-Master 2.0 utilize 2 GPUs; all other baselines use a single GPU. We report Percentile Rank as our primary metric, as discrete medal thresholds are sensitive to noise near boundaries and fail to capture progress on difficult tasks where no agent achieves medals—for instance, improving from the 5th to the 55th percentile on a hard task is invisible to medal rates but reflected in Percentile Rank.
>
> Early Search (3h) At the 3-hour mark, AIRA<sup>2</sup> achieves a Percentile Rank of 59.9%. While the system is not optimized for compute efficiency—it uses 8 GPUs to prioritize search breadth over resource efficiency—this early result demonstrates that strong initial solutions emerge quickly and provide a foundation for continued refinement. This result shows that AIRA<sup>2</sup> is comparable in performance to top single-GPU baseline agents like MARS at 24 GPU-hours.
>
> <span id="page-7-1"></span>> *Figure 3: Compute analysis*
> ![[aira2-2603-003.jpeg]]
>
> - (a) Compute Efficiency (Performance vs. GPU Hours). Comparison of AIRA<sub>2</sub> with 1 vs. 8 GPUs normalized by total compute. While the 8-GPU setup incurs an initial exploration cost (GPU-hours), it establishes a diverse population that yields superior long-term performance, with the gap widening to 7.5 Percentile Rank points at 144 GPU-hours.
> - (b) Search Strategy at Scale (Performance vs. Wall Time). We compare  $AIRA_2$  (8-GPU Evo) against a No-Evo (Best-of-K) parallel baseline (8-GPU, no evolution) and a single-GPU baseline. Parallelism without information sharing (Best-of-K) saturates early, converging to the same final performance as the single-GPU agent.
>
> Figure 3: Compute Analysis. We analyse the impact of parallel resources on  $AIRA_2$ , demonstrating that effective use of parallel compute requires both additional resources and an evolutionary mechanism to utilize them.
>
> **Standard Evaluation (24h)** At 24 hours, AIRA<sub>2</sub> achieves a mean Percentile Rank of 71.8%, surpassing the previous best of 69.9% (MARS+ (Chen et al., 2026)). This result is achieved despite reserving 20% of the training data for the Hidden Consistent Evaluation protocol (Section 3.3), which trades short-term performance for a more reliable search signal.
>
> Long-Horizon Search (72h) AIRA<sub>2</sub> is designed for sustained improvement over extended time horizons. At 72 hours, performance reaches 76.0% Percentile Rank—a further 4.2 percentage point gain over the 24h result. Notably, unlike prior systems where extended runtime leads to performance degradation due to overfitting (Toledo et al., 2025), AIRA<sub>2</sub> continues to improve with additional compute. We analyse the specific contributions of each ablated component (Subagents, Consistent Eval) in Section 4.3.
>
> #### <span id="page-7-0"></span>4.3 Ablation Studies
>
> We adopt a subtractive ablation design, removing one component at a time from the full system, to directly test whether each is necessary for the observed performance.
>
> #### 4.3.1 Resolving the Compute Bottleneck
>
> We analyse the impact of increasing AIRA<sub>2</sub>'s available compute resources from a 1-GPU to an 8-GPU setup. As discussed in Section 2.1, synchronous single-GPU execution is a fundamental throughput bottleneck. Here, we ask two questions: (1) does parallel compute improve performance beyond simply being faster? and (2) is evolutionary search necessary to exploit additional GPUs?
>
> Parallel compute improves efficiency, not just speed. In Figure 3a, we normalize performance by cumulative GPU hours to assess fundamental compute efficiency. Initially, the 8-GPU setup underperforms slightly. This is likely due to the fact that the single GPU version of AIRA<sub>2</sub> has the GPU time for sequential iteration, but the 8-GPU setup spends the first few hours building up a diverse initial population. However, once this foundation is laid, the 8-GPU setup improves significantly compared to the single-GPU baseline, with the performance gap widening over time: 3.1 Percentile Rank points at 24 hours, 5.2 at 96 hours, and 7.5 at 144 hours. This suggests that the broader parallel exploration facilitates a more robust search space traversal, preventing the local optima traps that constrain the single-GPU regime. Crucially, parallelism also increases
>
> the effective branching factor of the search: multiple workers simultaneously can explore different mutations of the same parent, generating diverse descendants whose quality is only assessed after execution. This provides a source of exploration that is not controlled by the evolutionary selection pressure, allowing the population to cover more of the solution space per generation.
>
> Parallelism without evolution is suboptimal. Does adding GPUs automatically yield better solutions or just faster ones? In Figure [3b,](#page-7-1) we compare AIRA<sup>2</sup> against a "Best-of-K/No Evo."[2](#page-8-1) baseline—an embarrassingly parallel setup using 8 GPUs where agents generate solutions from scratch without evolutionary lineage (no parents/shared memory).
>
> We observe that while the Best-of-K approach scales rapidly in the first few hours due to high throughput, it quickly hits a performance ceiling, plateauing at the exact same level as the single-GPU evolutionary agent (9-hour mark). This reveals a critical insight: parallelism without shared state is sample-inefficient. The 8-GPU Best-of-K agent effectively "wastes" 7 GPUs to achieve a result that a single GPU could eventually reach, albeit in faster wall-clock time. In contrast, AIRA<sup>2</sup> utilizes the distributed compute to maintain a global population, ensuring that increased throughput translates into higher asymptotic performance rather than just faster convergence to a lower bound.
>
> #### <span id="page-8-0"></span>4.3.2 Closing the Generalization Gap
>
> As discussed in Section [2.2,](#page-2-1) the generalization gap—the divergence between validation and test performance—is a key bottleneck, with prior work reporting performance degradation over extended search horizons. Here, we evaluate whether Hidden Consistent Evaluation (HCE) resolves this. We proceed in three steps: first, we reproduce the degradation under self-reported evaluation; second, we show that HCE eliminates it; and third, we investigate whether the remaining gap reflects true overfitting or evaluation noise.
>
> Without HCE: reproducing degradation. We replicate the evaluation setup of [Toledo et al.](#page-14-4) [\(2025\)](#page-14-4) and [Jiang](#page-13-5) [et al.](#page-13-5) [\(2025\)](#page-13-5), where agents self-report metrics using dynamic validation splits (e.g., 5-fold CV) and their own validation procedure. Our results confirm their findings: under this regime, performance peaks early and subsequently degrades (Figure [4a\)](#page-9-0). While prior work attributed this to "overfitting", we hypothesize that the degradation is driven by evaluation noise—"lucky" splits and spurious successes create false positive signals that destabilize the search trajectory. Separately, we have also observed failure cases such as evaluation code bugs leading to perfect validation scores regardless of the data split thus destroying all future progress (see the example presented in Appendix [A\)](#page-16-0).
>
> With HCE: eliminating degradation. To test this hypothesis, we apply the HCE protocol: the search set Dsearch is fixed externally and hidden from the agent, ensuring the hill-climbing metric remains stationary throughout the run. AIRA<sup>2</sup> searches on Dsearch and selects the final submission on a held-out Dval, ensuring the selection signal is fully decoupled from the optimization signal. As shown in Figure [4a,](#page-9-0) this eliminates the degradation entirely. The gap between our method and the Oracle (selecting the best solution based on test set performance) stabilizes at approximately 4 Percentile Rank points at 24 hours and narrows further to under 4 points at 72 hours. Quantitatively, HCE accounts for a 13.0 Percentile Rank point improvement at 24 hours and 18.4 points at 72 hours (Figure [4a,](#page-9-0) green region), and without HCE performance stagnates between 24h and 72h, confirming that HCE is essential for sustained long-horizon improvement.
>
> Diagnosing the remaining gap: noise, not memorization. Finally, we ask whether the improvements under HCE reflect genuine generalization or whether the agent is overfitting to Dsearch in a way that happens to transfer. If classical overfitting to the search set were occurring, we would expect test performance to degrade over time when selecting on Dsearch — the metric being optimized against. However, as shown in Figure [4a,](#page-9-0) test performance improves monotonically even under Dsearch selection, and the difference between selecting on Dsearch versus the unseen Dval is marginal. This strongly suggests that the degradation observed in prior work was not due to data memorization, but rather to the inconsistency of the evaluation procedure itself. Once
>
> <span id="page-8-1"></span><sup>2</sup>K refers to however many solutions 8 ReAct agents (each with their own GPU) can come up with in the given wall-clock time. This number will be different depending on the compute requirements of the task. Once a ReAct agent submits a solution for evaluation, it starts fresh with no memory of its previous attempt. By the end of a specific wall-clock duration, the total number of evaluated solutions represent K and the selected solution is the best out of this K on Dval.
>
> <span id="page-9-0"></span>> *Figure 4: Stabilizing long-horizon search and performance profile*
> ![[aira2-2603-004.jpeg]]
>
> Figure 4: (a) Stabilizing Long-Horizon Search. We compare the standard self-reported evaluation (blue) against our Hidden Consistent Evaluation protocol (green). While self-reporting leads to eventual performance degradation (confirming Toledo et al. (2025)), consistent evaluation ensures long-term improvement. Furthermore, the marginal difference between selecting via  $\mathcal{D}_{\text{search}}$  (seen) and  $\mathcal{D}_{\text{val}}$  (unseen) splits suggests the degradation in prior work was due to evaluation noise, not true data overfitting. (b) The performance profile of AIRA<sub>2</sub>: We observe steady increase in performance in all configurations, with 8-worker parallel version performing the best, achieving the highest Percentile Rank among all evaluated agents at 24 hours, while performing competitively at the 24-gpu-hours mark.
>
> the evaluation metric is fixed, the agent improves reliably. This is not to say true overfitting will not be a problem in the future as agents are given more compute.
>
> #### 4.3.3 Overcoming the Static Operator Limitation
>
> As discussed in Section 2.3, fixed, single-turn operators are too rigid to handle the diversity of sub-tasks encountered in open-ended research. Here, we isolate the impact of replacing them with ReAct agents by comparing the full AIRA<sub>2</sub> against a variant restricted to static, single-turn LLM operators.
>
> ReAct agents act as an efficiency multiplier. As shown in Table 1 and Figure 4b, at the 3-hour mark, AIRA<sub>2</sub> with ReAct agents outperforms single-turn operators by 5.5 Percentile Rank points. The ability to self-correct, inspect outputs, and iterate within a single mutation attempt allows the agent to traverse the search space more effectively when time is constrained.
>
> The gap narrows with more compute. However, this performance gap shrinks to 3.2 points at 24 hours and 2.3 points at 72 hours. This suggests that single-turn operators are not hitting a hard complexity ceiling; rather, they are inefficient. Given enough time, the evolutionary loop compensates for the lack of internal agency by externalizing context—passing stdout, stderr, and metadata between independent single-shot attempts—allowing the system to eventually approximate the performance of a fully interactive agent.
>
> The current evaluation may understate the benefit. In this study, AIRA<sub>2</sub> was restricted to standard Python and Bash execution environments. We hypothesize that the value of the ReAct paradigm would be more pronounced in scenarios requiring broader tool use—such as internet browsing or API interaction—where multi-turn navigation of dynamic environments is structurally required and cannot be easily simulated by iterative single-shot generation.
>
> #### 4.4 Case Study: Eureka Moments in MLE-bench
>
> Overview & Takeaways: To understand the qualitative behaviours driving AIRA<sub>2</sub>'s quantitative success, we analyse its trajectory on specific high-complexity tasks. We find that AIRA<sub>2</sub> appears to exhibit reasoning capabilities—specifically the ability to distinguish between poor methodology and poor execution (e.g., underfitting)—allowing it to recover from local minima where greedy agents would likely fail.
>
> #### 4.4.1 Deep Dive: Predicting Molecular Properties
>
> <span id="page-10-0"></span>We highlight the agent's performance on champs-scalar-coupling, a task predicting magnetic interactions between atom pairs. As illustrated in Figure 5, AIRA<sub>2</sub> demonstrates a "eureka" moment.
>
> *Figure 5: Eureka moment on champs-scalar-coupling task*
> ![[aira2-2603-005.jpeg]]
>
> Agent's Thought and Action Trajectory Summary
>
> 13, Mutation: The previous approach with SchNet significantly improved the score, and ran very quickly. Due to the competition's evaluation metric-mean log MAE calculated per coupling type with varied value ranges-we will decouple and train separate models for each type.
>
> **14, Mutation**: The previous solution achieved a higher score by implementing 8 separate SchNet models. Next, we will be using Mulliken charges as an auxiliary prediction task during training. **15, Mutation**: The parent's score was lower than the grandparent's, with training taking only 15 minutes-well within the 9-hour budget-yet the loss was converging well. This suggests that the model likely underfit or stopped prematurely, failing to fully benefit from the auxiliary task. My next step is to train a larger model for a longer duration.  $\rightarrow$ 
>
> **16, Crossover**: The parent A's approach can be further scaled up to improve the performance. I will combine it with parent B's efficient data preprocessing strategy.  $\rightarrow \mbox{\em $\ast$}$ 
>
> Figure 5: Example of typical behaviour observed in AIRA<sub>2</sub> during the champs-scalar-coupling task. The left side displays the chronological performance of each solution in the database (solid lines for mutation, dashed for crossover). The right-hand panel presents a concise summary of the agent's thought process for the nodes and trajectory annotated in green, highlighting the "eureka" moment where the agent identifies underfitting and subsequently scales the model to achieve medal-winning performance. Horizontal dashed lines indicate the medal thresholds and display the previous best attempt (Thesis Labs, 2025) on the task among all agents.
>
> The shown trajectory begins with the agent testing SchNet (Schütt et al., 2017), which performed well. Building on this, the agent attempted to introduce an auxiliary prediction task (Mulliken charges) at Step 14, leveraging supplementary competition data to further improve results. As shown in the trace, this caused the validation score to drop. A standard ReAct loop or greedy algorithm might reject this change and revert. However, AIRA2 investigates the execution logs, noting that the training only utilized 15 minutes of the available 9-hour budget and that the loss was still converging, correctly identifying the root cause as underfitting — recognizing that the auxiliary task was effective despite the lack of immediate improvement — rather than a fundamental flaw in the idea.
>
> Consequently, at Step 15, the agent commits to scaling the model size and extending the training duration significantly. This reasoning leads directly to a dramatic performance boost, securing a Bronze medal and surpassing all previous agents. Following this improvement, AIRA<sub>2</sub> further refined the approach by adopting an effective preprocessing technique via crossover from a much weaker solution. This combination elevated the solution to a Silver and ultimately a Gold medal. Notably, no other reported agent (FM-Agent 2.0, MARS, etc.) achieved a medal on this task.
>
> Breaking the Ceiling on Stalled Tasks. To illustrate that this exceptional performance is not an isolated event, we briefly outline two other complex tasks where  $AIRA_2$  uniquely surpassed the medal threshold despite the failure of all prior methods.
>
> On billion-word-imputation, a challenging NLP task where baselines failed to make significant progress, AIRA<sub>2</sub> achieved a 100% Percentile Rank by decomposing the problem into two learned sub-tasks: a RoBERTa-large token classifier trained on 8M synthetically constructed gapped sentences to *detect* the missing-word position, followed by a separately fine-tuned RoBERTa-large masked language model to *fill* the gap.
>
> On the fine-grained visual classification task imet-2020-fgvc7 (3,474 attribute classes), AIRA<sub>2</sub> achieved a 91% Percentile Rank—the highest among all evaluated agents—by ensembling an EVA-02 Large (Fang et al., 2024) and a ConvNeXt Large CLIP (Liu et al., 2022) model with asymmetric loss (Ridnik et al., 2021), layer-wise learning rate decay, and grid-searched ensemble weights and classification thresholds.
>
> # 5 Related Work
>
> The domain of automated machine learning has shifted rapidly from simple heuristics [\(Bergstra and Bengio,](#page-13-6) [2012;](#page-13-6) [Elsken et al.,](#page-13-7) [2017;](#page-13-7) [Li et al.,](#page-14-6) [2018\)](#page-14-6) to autonomous agents capable of long-horizon research [\(Yamada](#page-15-2) [et al.,](#page-15-2) [2025\)](#page-15-2). While early methods optimized within fixed search spaces, LLM-powered agents now tackle open-ended tasks, including, software engineering [\(Wang et al.,](#page-14-1) [2025b;](#page-14-1) [Anthropic,](#page-13-1) [2025;](#page-13-1) [OpenAI,](#page-14-2) [2025\)](#page-14-2), mathematics [\(Novikov et al.,](#page-14-3) [2025;](#page-14-3) [Hubert et al.,](#page-13-2) [2025\)](#page-13-2), chemistry [\(Wang et al.,](#page-14-14) [2025a\)](#page-14-14), material science [\(Ab](#page-13-16)[hyankar et al.,](#page-13-16) [2025\)](#page-13-16), computational complexity theory [\(Yu et al.,](#page-15-3) [2025\)](#page-15-3). This work focuses on agents for AI research (AI4AI), typically evaluated via benchmarks like MLE-bench [\(Chan et al.,](#page-13-4) [2025\)](#page-13-4), and more recently AIRS-Bench [\(Lupidi et al.,](#page-14-15) [2026\)](#page-14-15) that are composed of a suite of tasks spanning diverse machine learning domains. Recent agents have achieved strong benchmark performance by scaling inference-time compute. These agents employ iterative refinement strategies via tree [\(Du et al.,](#page-13-9) [2025;](#page-13-9) [Chen et al.,](#page-13-8) [2026\)](#page-13-8) or graph search [\(Botla et al.,](#page-13-10) [2025;](#page-13-10) [Li et al.,](#page-13-11) [2025\)](#page-13-11), multi-agent collaboration [\(Gottweis et al.,](#page-13-17) [2025\)](#page-13-17), advanced context management [\(Liu et al.,](#page-14-7) [2025b\)](#page-14-7), and external knowledge [\(Nam et al.,](#page-14-16) [2025\)](#page-14-16).
>
> However, these systems often conflate multiple design choices together, making it difficult to isolate which components drive performance. In contrast, AIRA-dojo [\(Toledo et al.,](#page-14-4) [2025\)](#page-14-4) formalises a systematic approach for agent design by disentangling gains from infrastructure, operators and search strategy, and evaluation signals. To this end, it exposes critical bottlenecks to agent design that affects its performance. We build on this decomposition by targeting these bottlenecks and developing modules incrementally, achieving state-of-the-art results on established benchmarks. Relative to similar evolutionary agentic approaches [\(Novikov et al.,](#page-14-3) [2025;](#page-14-3) [Lange et al.,](#page-13-18) [2026\)](#page-13-18), we provide a controlled, module-by-module ablation of the end-to-end research agent.
>
> ### 6 Limitations
>
> Data Contamination. While performance gains scale with increased compute, it remains difficult to determine how much of the improvement stems from genuine reasoning versus latent data retrieval. Since many topperforming Kaggle solutions are publicly available, the underlying LLMs may have encountered them during pre-training. Increased search iterations could simply raise the probability of "recalling" these solutions rather than generating novel insights. This suggests that while MLE-bench provides a strong signal, future evaluation on more "closed" or private benchmarks is necessary to isolate an agent's true research capability.
>
> Conversely, there is a pragmatic argument for treating all available data as "fair game." Rather than strictly aiming to replicate past results in a vacuum, research agents could be redirected toward improving upon the current state-of-the-art. In this paradigm, agents would leverage existing winning solutions and technical blog posts as a knowledge base to identify remaining gaps, effectively shifting the goal from simple competition-winning to iterative scientific discovery.
>
> Preparing the splits. In order to prevent the agents from reward hacking and overfitting to a poor evaluation signal proxy, we reformulate the format of each task to have additional validation splits in addition to train and (the original) test data. While this necessitates a degree of human curation during the initial task-loading phase, it serves as a critical one-time setup to ensure evaluation integrity. Importantly, this intervention is limited strictly to the environment configuration; once initialized, the agent operates with full autonomy, navigating the research process without any human-in-the-loop assistance. We also note that this step is itself automatable—an agent could generate its own consistent splits given access to the dataset schema—and we expect future systems to internalize this as part of the environment setup.
>
> Compute Specialization. The design of AIRA<sup>2</sup> is specifically optimized for high-compute regimes, focusing on maximizing performance over extended research horizons and multi-GPU configurations. Consequently, it may not be the optimal choice for constrained environments, such as short-duration runs or single-GPU setups. We acknowledge that there is currently no "one-size-fits-all" architecture for research agents; by prioritizing deep exploration and parallel compute utilization, AIRA<sup>2</sup> sacrifices the immediate efficiency of lightweight agents in favour of superior long-term results and higher performance ceilings.
>
> # 7 Conclusion
>
> In this work, we introduce AIRA2, an agent engineered to address three structural bottlenecks that constrain the performance of AI research agents, as identified by prior work: compute throughput, evaluation instability, and operator capability. By addressing all three, AIRA<sup>2</sup> achieves a new state of the art on the MLE-bench benchmark: 71.8% mean Percentile Rank at 24 hours, surpassing the previous best of 69.9%, and improving further to 76.0% at 72 hours. Notably, performance improves monotonically with additional compute, without the degradation observed in prior work.
>
> By transitioning from synchronous execution to an asynchronous multi-GPU worker pool, we achieved linear growth in sample throughput, transforming the agent from a sequential optimizer into a massively parallel explorer. By implementing a Hidden Consistent Evaluation protocol, we successfully decoupled the search signal from the selection signal, ensuring that performance gains represent robust generalization rather than metric gaming. Finally, by replacing static, single-turn prompts with ReAct agents, we enabled dynamic scoping and interactive debugging, allowing the system to handle the complexity of open-ended research tasks.
>
> Crucially, our ablation studies reveal that no single component acts as a "silver bullet," but each is critical under practical constraints. First, removing ReAct agents reduces performance by 5.5 percentile points at 3 hours; the gap narrows to 2.3 points at 72 hours, indicating that agents act as an efficiency multiplier in the discovery of strong solutions. Moreover, agents expand the range of tasks the system can tackle: complex tasks that demand interactive debugging, iterative feature engineering, or multi-step reasoning pipelines are beyond the reach of single-turn prompts, making agent-based operators essential for generality. Second, reducing to a single GPU or replacing evolution with a Best-of-K baseline reveals a different bottleneck: parallelism without shared state quickly saturates at the single-GPU performance ceiling, confirming that evolutionary selection is necessary for effective use of parallel compute, not merely parallelism. Finally, removing Hidden Consistent Evaluation causes performance to degrade over time, confirming that stable evaluation is necessary for long-horizon search; this ablation also revealed that the "overfitting" reported in previous studies was driven by evaluation noise rather than data memorization. It is the interplay between these three pillars that enables AIRA<sup>2</sup> to improve reliably with both time and compute.
>
> Ultimately, AIRA<sup>2</sup> represents a step away from fragile, competition-winning scripts and toward autonomous systems capable of genuine, open-ended scientific discovery. By solving these fundamental engineering challenges, we move closer to agents that can reliably generate novel knowledge in domains beyond standard benchmarks.
>
> ### References
>
> - <span id="page-13-16"></span>Nikhil Abhyankar, Sanchit Kabra, Saaketh Desai, and Chandan K. Reddy. Accelerating materials design via llm-guided evolutionary search, 2025. <https://arxiv.org/abs/2510.22503>.
> - <span id="page-13-1"></span>Anthropic. Claude code overview. <https://code.claude.com/docs/en/overview>, 2025.
> - <span id="page-13-13"></span>Alexis Audran-Reiss, Jordi Armengol-EstapÊ, Karen Hambardzumyan, Amar Budhiraja, Martin Josifoski, Edan Toledo, Rishi Hazra, Despoina Magka, Michael Shvartsman, Parth Pathak, et al. What does it take to be a good ai research agent? studying the role of ideation diversity. arXiv preprint arXiv:2511.15593, 2025.
> - <span id="page-13-6"></span>James Bergstra and Yoshua Bengio. Random search for hyper-parameter optimization. The journal of machine learning research, 13(1):281–305, 2012.
> - <span id="page-13-10"></span>Sai Kiran Botla, Kirubanath Sankar, Abhishek Chopde, and Fardeen Pettiwala. Pi-evolve: Long-horizon evolutionary optimization for autonomous scientific discovery, 2025.
> - <span id="page-13-4"></span>Jun Shern Chan, Neil Chowdhury, Oliver Jaffe, James Aung, Dane Sherburn, Evan Mays, Giulio Starace, Kevin Liu, Leon Maksin, Tejal Patwardhan, Aleksander Madry, and Lilian Weng. MLE-bench: Evaluating machine learning agents on machine learning engineering. In The Thirteenth International Conference on Learning Representations, 2025. <https://openreview.net/forum?id=6s5uXNWGIh>.
> - <span id="page-13-8"></span>Jiefeng Chen, Bhavana Dalvi Mishra, Jaehyun Nam, Rui Meng, Tomas Pfister, and Jinsung Yoon. Mars: Modular agent with reflective search for automated ai research. arXiv preprint arXiv:2602.02660, 2026.
> - <span id="page-13-9"></span>Shangheng Du, Xiangchao Yan, Dengyang Jiang, Jiakang Yuan, Yusong Hu, Xin Li, Liang He, Bo Zhang, and Lei Bai. Automlgen: Navigating fine-grained optimization for coding agents. arXiv preprint arXiv:2510.08511, 2025.
> - <span id="page-13-7"></span>Thomas Elsken, Jan-Hendrik Metzen, and Frank Hutter. Simple and efficient architecture search for convolutional neural networks. arXiv preprint arXiv:1711.04528, 2017.
> - <span id="page-13-15"></span>Yuxin Fang, Quan Sun, Xinggang Wang, Tiejun Huang, Xinlong Wang, and Yue Cao. Eva-02: A visual representation for neon genesis. Image and Vision Computing, 149:105171, 2024.
> - <span id="page-13-14"></span>Google DeepMind. Gemini 3: Our most intelligent AI model, 2025. <https://deepmind.google/models/gemini/>.
> - <span id="page-13-17"></span>Juraj Gottweis, Wei-Hung Weng, Alexander Daryin, Tao Tu, Anil Palepu, Petar Sirkovic, Artiom Myaskovsky, Felix Weissenberger, Keran Rong, Ryutaro Tanno, Khaled Saab, Dan Popovici, Jacob Blum, Fan Zhang, Katherine Chou, Avinatan Hassidim, Burak Gokturk, Amin Vahdat, Pushmeet Kohli, Yossi Matias, Andrew Carroll, Kavita Kulkarni, Nenad Tomasev, Yuan Guan, Vikram Dhillon, Eeshit Dhaval Vaishnav, Byron Lee, Tiago R D Costa, José R Penadés, Gary Peltz, Yunhan Xu, Annalisa Pawlosky, Alan Karthikesalingam, and Vivek Natarajan. Towards an ai co-scientist, 2025. <https://arxiv.org/abs/2502.18864>.
> - <span id="page-13-2"></span>Thomas Hubert, Rishi Mehta, Laurent Sartran, Miklós Z Horváth, Goran Žužić, Eric Wieser, Aja Huang, Julian Schrittwieser, Yannick Schroecker, Hussain Masoom, et al. Olympiad-level formal mathematical reasoning with reinforcement learning. Nature, pages 1–3, 2025.
> - <span id="page-13-5"></span>Zhengyao Jiang, Dominik Schmidt, Dhruv Srikanth, Dixing Xu, Ian Kaplan, Deniss Jacenko, and Yuxiang Wu. Aide: Ai-driven exploration in the space of code. arXiv preprint arXiv:2502.13138, 2025.
> - <span id="page-13-0"></span>Martin Josifoski, Lars Klein, Maxime Peyrard, Nicolas Baldwin, Yifei Li, Saibo Geng, Julian Paul Schnitzler, Yuxing Yao, Jiheng Wei, Debjit Paul, et al. Flows: Building blocks of reasoning and collaborating ai. arXiv preprint arXiv:2308.01285, 2023.
> - <span id="page-13-12"></span>Gregory M. Kurtzer, cclerget, Michael Bauer, Ian Kaneshiro, David Trudgian, and David Godlove. hpcng/singularity: Singularity 3.7.3, April 2021. <https://doi.org/10.5281/zenodo.4667718>.
> - <span id="page-13-18"></span>Robert Tjarko Lange, Yuki Imajuku, and Edoardo Cetin. Shinkaevolve: Towards open-ended and sample-efficient program evolution. In The Fourteenth International Conference on Learning Representations, 2026. [https://](https://openreview.net/forum?id=lKEdGCoDNC) [openreview.net/forum?id=lKEdGCoDNC](https://openreview.net/forum?id=lKEdGCoDNC).
> - <span id="page-13-3"></span>Pat Langley, Herbert A Simon, Gary L Bradshaw, and Jan M Zytkow. Scientific discovery, 1987.
> - <span id="page-13-11"></span>Annan Li, Chufan Wu, Zengle Ge, Yee Hin Chong, Zhinan Hou, Lizhe Cao, Cheng Ju, Jianmin Wu, Huaiming Li, Haobo Zhang, Shenghao Feng, Mo Zhao, Fengzhi Qiu, Rui Yang, Mengmeng Zhang, Wenyi Zhu, Yingying Sun, Quan Sun, Shunhao Yan, Danyu Liu, Dawei Yin, and Dou Shen. The fm agent, 2025. <https://arxiv.org/abs/2510.26144>.
>
> - <span id="page-14-6"></span>Lisha Li, Kevin Jamieson, Giulia DeSalvo, Afshin Rostamizadeh, and Ameet Talwalkar. Hyperband: A novel bandit-based approach to hyperparameter optimization. Journal of Machine Learning Research, 18(185):1–52, 2018.
> - <span id="page-14-9"></span>Aixin Liu, Aoxue Mei, Bangcai Lin, Bing Xue, Bingxuan Wang, Bingzheng Xu, Bochao Wu, Bowei Zhang, Chaofan Lin, Chen Dong, et al. Deepseek-v3. 2: Pushing the frontier of open large language models. arXiv preprint arXiv:2512.02556, 2025a.
> - <span id="page-14-7"></span>Zexi Liu, Yuzhu Cai, Xinyu Zhu, Yujie Zheng, Runkun Chen, Ying Wen, Yanfeng Wang, Weinan E, and Siheng Chen. Ml-master: Towards ai-for-ai via integration of exploration and reasoning, 2025b. <https://arxiv.org/abs/2506.16499>.
> - <span id="page-14-12"></span>Zhuang Liu, Hanzi Mao, Chao-Yuan Wu, Christoph Feichtenhofer, Trevor Darrell, and Saining Xie. A convnet for the 2020s. In Proceedings of the IEEE/CVF conference on computer vision and pattern recognition, pages 11976–11986, 2022.
> - <span id="page-14-15"></span>Alisia Lupidi, Bhavul Gauri, Thomas Simon Foster, Bassel Al Omari, Despoina Magka, Alberto Pepe, Alexis Audran-Reiss, Muna Aghamelu, Nicolas Baldwin, Lucia Cipolina-Kun, et al. Airs-bench: a suite of tasks for frontier ai research science agents. arXiv preprint arXiv:2602.06855, 2026.
> - <span id="page-14-16"></span>Jaehyun Nam, Jinsung Yoon, Jiefeng Chen, Jinwoo Shin, Sercan O Arik, and Tomas Pfister. MLE-STAR: Machine learning engineering agent via search and targeted refinement. In The Thirty-ninth Annual Conference on Neural Information Processing Systems, 2025. <https://openreview.net/forum?id=vS1M06Px6u>.
> - <span id="page-14-3"></span>Alexander Novikov, Ngân V˜u, Marvin Eisenberger, Emilien Dupont, Po-Sen Huang, Adam Zsolt Wagner, Sergey Shirobokov, Borislav Kozlovskii, Francisco JR Ruiz, Abbas Mehrabian, et al. Alphaevolve: A coding agent for scientific and algorithmic discovery. arXiv preprint arXiv:2506.13131, 2025.
> - <span id="page-14-2"></span>OpenAI. Codex: AI coding agent for ChatGPT. <https://chatgpt.com/codex>, 2025.
> - <span id="page-14-13"></span>Tal Ridnik, Emanuel Ben-Baruch, Nadav Zamir, Asaf Noy, Itamar Friedman, Matan Protter, and Lihi Zelnik-Manor. Asymmetric loss for multi-label classification. In Proceedings of the IEEE/CVF international conference on computer vision, pages 82–91, 2021.
> - <span id="page-14-11"></span>Kristof Schütt, Pieter-Jan Kindermans, Huziel Enoc Sauceda Felix, Stefan Chmiela, Alexandre Tkatchenko, and Klaus-Robert Müller. Schnet: A continuous-filter convolutional neural network for modeling quantum interactions. Advances in neural information processing systems, 30, 2017.
> - <span id="page-14-5"></span>Aaditya Singh, Adam Fry, Adam Perelman, Adam Tart, Adi Ganesh, Ahmed El-Kishky, Aidan McLaughlin, Aiden Low, AJ Ostrow, Akhila Ananthram, et al. Openai gpt-5 system card. arXiv preprint arXiv:2601.03267, 2025.
> - <span id="page-14-8"></span>Gilbert Syswerda. A study of reproduction in generational and steady-state genetic algorithms. In Foundations of genetic algorithms, volume 1, pages 94–101. Elsevier, 1991.
> - <span id="page-14-10"></span>Thesis Labs. Thesis is state-of-the-art on MLE-bench. <https://thesislabs.ai/writings/sota-mle-bench>, 2025. Accessed: 2026-02-25.
> - <span id="page-14-4"></span>Edan Toledo, Karen Hambardzumyan, Martin Josifoski, RISHI HAZRA, Nicolas Baldwin, Alexis Audran-Reiss, Michael Kuchnik, Despoina Magka, Minqi Jiang, Alisia Maria Lupidi, Andrei Lupu, Roberta Raileanu, Tatiana Shavrina, Kelvin Niu, Jean-Christophe Gagnon-Audet, Michael Shvartsman, Shagun Sodhani, Alexander H Miller, Abhishek Charnalia, Derek Dunfield, Carole-Jean Wu, Pontus Stenetorp, Nicola Cancedda, Jakob Nicolaus Foerster, and Yoram Bachrach. AI research agents for machine learning: Search, exploration, and generalization in MLE-bench. In The Thirty-ninth Annual Conference on Neural Information Processing Systems, 2025. [https://openreview.net/](https://openreview.net/forum?id=RwfrdKSgCE) [forum?id=RwfrdKSgCE](https://openreview.net/forum?id=RwfrdKSgCE).
> - <span id="page-14-14"></span>Haorui Wang, Marta Skreta, Cher Tian Ser, Wenhao Gao, Lingkai Kong, Felix Strieth-Kalthoff, Chenru Duan, Yuchen Zhuang, Yue Yu, Yanqiao Zhu, Yuanqi Du, Alan Aspuru-Guzik, Kirill Neklyudov, and Chao Zhang. Efficient evolutionary search over chemical space with large language models. In The Thirteenth International Conference on Learning Representations, 2025a. <https://openreview.net/forum?id=awWiNvQwf3>.
> - <span id="page-14-1"></span>Xingyao Wang, Boxuan Li, Yufan Song, Frank F. Xu, Xiangru Tang, Mingchen Zhuge, Jiayi Pan, Yueqi Song, Bowen Li, Jaskirat Singh, Hoang H. Tran, Fuqiang Li, Ren Ma, Mingzhang Zheng, Bill Qian, Yanjun Shao, Niklas Muennighoff, Yizhe Zhang, Binyuan Hui, Junyang Lin, Robert Brennan, Hao Peng, Heng Ji, and Graham Neubig. Openhands: An open platform for AI software developers as generalist agents. In The Thirteenth International Conference on Learning Representations, 2025b. <https://openreview.net/forum?id=OJd3ayDDoF>.
> - <span id="page-14-0"></span>Qingyun Wu, Gagan Bansal, Jieyu Zhang, Yiran Wu, Beibin Li, Erkang Zhu, Li Jiang, Xiaoyun Zhang, Shaokun Zhang, Jiale Liu, Ahmed Hassan Awadallah, Ryen W White, Doug Burger, and Chi Wang. Autogen: Enabling
>
> - next-gen LLM applications via multi-agent conversations. In First Conference on Language Modeling, 2024. <https://openreview.net/forum?id=BAakY1hNKS>.
> - <span id="page-15-2"></span>Yutaro Yamada, Robert Tjarko Lange, Cong Lu, Shengran Hu, Chris Lu, Jakob Foerster, Jeff Clune, and David Ha. The AI Scientist-v2: Workshop-Level Automated Scientific Discovery via Agentic Tree Search, 2025. [https:](https://arxiv.org/abs/2504.08066) [//arxiv.org/abs/2504.08066](https://arxiv.org/abs/2504.08066).
> - <span id="page-15-1"></span>Shunyu Yao, Jeffrey Zhao, Dian Yu, Nan Du, Izhak Shafran, Karthik R Narasimhan, and Yuan Cao. React: Synergizing reasoning and acting in language models. In The eleventh international conference on learning representations, 2022.
> - <span id="page-15-3"></span>Cunxi Yu, Rongjian Liang, Chia-Tung Ho, and Haoxing Ren. Autonomous code evolution meets np-completeness. arXiv preprint arXiv:2509.07367, 2025.
> - <span id="page-15-0"></span>Xinyu Zhu, Yuzhu Cai, Zexi Liu, Bingyang Zheng, Cheng Wang, Rui Ye, Jiaao Chen, Hanrui Wang, Wei-Chen Wang, Yuzhi Zhang, et al. Toward ultra-long-horizon agentic science: Cognitive accumulation for machine learning engineering. arXiv preprint arXiv:2601.10402, 2026.
>
> # <span id="page-16-0"></span>Appendix
>
> ### A Evaluation Failure: A Concrete Example
>
> To illustrate how implementation bugs can silently corrupt the search signal (Section [2.2\)](#page-2-1), we present a real example from an AI agent solving the LMSYS Chatbot Arena competition on MLE-bench. The agent's solution reported a perfect cross-validation log-loss of 0.0, which the search process then treated as the best candidate—despite the underlying model being unremarkable.
>
> The bug. The competition requires predicting which of three outcomes occurred (winner\_model\_a, winner\_ model\_b, or winner\_tie). The agent converts multi-hot target columns to single labels via idxmax(axis=1), which returns column name strings, not integer indices:
>
> ```
> t a r g e t _ c ol s = [ "winner_model_a" , "winner_model_b" , " winne r_ tie " ]
> t r a i n _ l a b e l s = t r ai n_ d f [ t a r g e t _ c ol s ] . idxmax ( a x i s =1) . v al u e s
> # Agent comment: "0, 1 , 2" - - actua l ly returns str ings :
> # [ 'winner_model_b ', 'winner_model_a ', 'winner_model_b ', . . . ]
> ```
>
> When computing the validation metric, the agent passes labels=[0, 1, 2] (integers), creating a type mismatch:
>
> ```
> l o s s = l o g _l o s s ( t r a i n _ l a b e l s [ val_idx ] , val_pred , l a b e l s = [0 , 1 , 2 ] )
> # Returns 0.0 regard less of predictions
> ```
>
> Because scikit-learn's log\_loss cannot match the string ground-truth labels ('winner\_model\_a', etc.) with the integer label list ([0, 1, 2]), it silently returns 0.0 for any set of predictions:
>
> ```
> >>> t r a i n _ l a b e l s [ : 3 ]
> a r r a y ( [ ' winner_model_b ' , ' winner_model_a ' , ' winner_model_b ' ] , dtype=o b j e c t )
> >>> val_pred = [ [ 0 . 3 , 0 . 3 , 0 . 4 ] ] * 3 # arbitrary predictions
> >>> l o g _l o s s ( t r a i n _ l a b e l s [ : 3 ] , val_pred , l a b e l s = [0 , 1 , 2 ] )
> 0. 0
> ```
>
> Why this matters for search. This bug is particularly insidious in the context of search-based agents. A greedy or evolutionary search process that relies on self-reported validation scores would select this solution as the global optimum, halting further exploration. The solution would persist as the "best" candidate indefinitely, while its actual test performance would be no better than chance. This example concretely demonstrates why decoupling the search signal from agent-controlled evaluation—as in our Hidden Consistent Evaluation protocol (Section [3.3\)](#page-4-0)—is essential for reliable long-horizon search.
>
> # B MLE-bench
>
> Table 2 : Per-task Percentile Rank scores for AIRA<sup>2</sup> at different time cutoffs. Values shown as score with 95% CI below.
>
> | Task                                              | 3h                       | 12h                      | 24h                      | 72h                     |
> |---------------------------------------------------|--------------------------|--------------------------|--------------------------|-------------------------|
> | aptos2019-blindness-detection                     | 70.30                    | 87.66                    | 97.31                    | 97.35                   |
> |                                                   | 51.16,                   | 64.79,                   | 93.75,                   | 96.41,                  |
> |                                                   | 93.31                    | 99.76                    | 99.76                    | 98.16                   |
> | billion-word-imputation                           | 66.67                    | 100.00                   | 100.00                   | 100.00                  |
> |                                                   | 8.05, 100.00             | 100.00, 100.00           | 100.00, 100.00           | 100.00, 100.00          |
> | bms-molecular-translation                         | 19.72                    | 28.15                    | 57.67                    | 69.07                   |
> |                                                   | 19.45,                   | 19.45,                   | 32.95,                   | 60.64,                  |
> |                                                   | 20.25                    | 34.10                    | 80.66                    | 85.93                   |
> | cassava-leaf-disease-classification               | 58.85                    | 87.38                    | 84.73                    | 89.15                   |
> |                                                   | 39.49,                   | 82.90,                   | 77.59,                   | 86.36,                  |
> |                                                   | 88.97                    | 90.26                    | 90.26                    | 92.13                   |
> |                                                   | 30.72                    | 49.17                    | 63.12                    | 78.13                   |
> | champs-scalar-coupling                            | 9.02,                    | 33.02,                   | 41.09,                   | 60.56,                  |
> |                                                   | 45.80                    | 64.10                    | 94.34                    | 98.79                   |
> |                                                   | 98.16                    | 99.68                    | 100.00                   | 100.00                  |
> | freesound-audio-tagging-2019                      | 97.60,<br>98.56<br>27.62 | 99.04, 100.00<br>29.03   | 100.00, 100.00<br>29.21  | 100.00, 100.00<br>29.60 |
> | h-and-m-personalized-fashion-recommendations      | 27.06,                   | 28.75,                   | 28.95,                   | 29.19,                  |
> |                                                   | 28.65                    | 29.53                    | 29.53                    | 30.00                   |
> | hms-harmful-brain-activity-classification         | 30.30                    | 30.57                    | 30.28                    | 31.76                   |
> |                                                   | 29.50,                   | 29.25,                   | 29.25,                   | 31.63,                  |
> |                                                   | 31.09                    | 31.89                    | 31.31                    | 31.89                   |
> | hotel-id-2021-fgvc8                               | 85.51                    | 89.13                    | 89.86                    | 94.57                   |
> |                                                   | 82.61,                   | 89.13,                   | 89.13,                   | 92.39,                  |
> |                                                   | 89.13                    | 89.13                    | 91.30                    | 95.65                   |
> | hubmap-kidney-segmentation                        | 89.27                    | 93.27                    | 93.91                    | 98.92                   |
> |                                                   | 87.32,                   | 89.49,                   | 89.49,                   | 97.58,                  |
> |                                                   | 90.49                    | 97.58                    | 99.50                    | 99.58                   |
> | imet-2020-fgvc7                                   | 38.60                    | 52.63                    | 71.93                    | 85.61                   |
> |                                                   | 37.89,                   | 46.32,                   | 47.37,                   | 83.16,                  |
> |                                                   | 40.00                    | 55.79                    | 84.21                    | 88.42                   |
> |                                                   | 8.05                     | 8.05                     | 8.06                     | 8.37                    |
> | jigsaw-unintended-bias-in-toxicity-classification | 7.86,                    | 7.90,                    | 7.90,                    | 7.94,                   |
> |                                                   | 8.39                     | 8.36                     | 8.36                     | 8.85                    |
> |                                                   | 86.69                    | 94.43                    | 95.34                    | 97.50                   |
> | kuzushiji-recognition                             | 69.97,<br>97.61          | 84.30, 100.00            | 86.01, 100.00            | 92.49, 100.00           |
> | mlsp-2013-birds                                   | 96.67<br>95.00,<br>98.75 | 97.92<br>96.25,<br>98.75 | 98.33<br>97.50,<br>98.75 | 98.75<br>97.50, 100.00  |
> | multi-modal-gesture-recognition                   | 62.96                    | 70.37                    | 70.37                    | 81.48                   |
> |                                                   | 38.89, 100.00            | 44.44, 100.00            | 44.44, 100.00            | 55.56, 100.00           |
> | new-york-city-taxi-fare-prediction                | 37.47                    | 38.79                    | 38.79                    | 37.04                   |
> |                                                   | 35.58,                   | 35.58,                   | 35.58,                   | 32.95,                  |
> |                                                   | 40.09                    | 40.50                    | 40.50                    | 40.30                   |
> | nfl-player-contact-detection                      | 42.49                    | 71.07                    | 71.92                    | 82.73                   |
> |                                                   | 23.22,                   | 25.03,                   | 26.30,                   | 58.09,                  |
> |                                                   | 79.23                    | 94.46                    | 94.99                    | 95.63                   |
> | nomad2018-predict-transparent-conductors          | 99.66<br>99.54,<br>99.89 | 99.58<br>99.54,<br>99.66 | 99.66<br>99.54,<br>99.89 | 99.77<br>99.66, 100.00  |
> | osic-pulmonary-fibrosis-progression               | 13.85                    | 10.89                    | 11.02                    | 12.50                   |
> |                                                   | 12.40,                   | 10.07,                   | 10.07,                   | 11.88,                  |
> |                                                   | 15.70                    | 11.50                    | 11.88                    | 13.22                   |
> |                                                   | 54.37                    | 56.41                    | 63.37                    | 88.62                   |
> | petfinder-pawpularity-score                       | 52.78,                   | 54.11,                   | 51.12,                   | 68.45,                  |
> |                                                   | 55.75                    | 59.88                    | 83.74                    | 99.72                   |
> |                                                   | 100.00                   | 100.00                   | 100.00                   | 100.00                  |
> | plant-pathology-2021-fgvc8                        | 100.00, 100.00           | 100.00, 100.00           | 100.00, 100.00           | 100.00, 100.00          |
> | smartphone-decimeter-2022                         | 4.89                     | 5.00                     | 5.00                     | 9.02                    |
> |                                                   | 4.89,                    | 4.89,                    | 4.89,                    | 4.89,                   |
> |                                                   | 4.89                     | 5.06                     | 5.06                     | 16.75                   |
> | spooky-author-identification                      | 97.29                    | 98.04                    | 97.90                    | 98.39                   |
> |                                                   | 96.45,                   | 97.99,                   | 97.26,                   | 98.31,                  |
> |                                                   | 98.15                    | 98.07                    | 98.31                    | 98.47                   |
> | stanford-covid-vaccine                            | 100.00                   | 100.00                   | 100.00                   | 100.00                  |
> |                                                   | 100.00, 100.00           | 100.00, 100.00           | 100.00, 100.00           | 100.00, 100.00          |
> | tensorflow2-question-answering                    | 48.91                    | 94.30                    | 97.27                    | 97.73                   |
> |                                                   | 48.66,                   | 88.97,                   | 96.51,                   | 96.51,                  |
> |                                                   | 49.15                    | 97.89                    | 97.89                    | 98.54                   |
> | tweet-sentiment-extraction                        | 73.34                    | 96.28                    | 95.92                    | 93.73                   |
> |                                                   | 60.39,                   | 95.95,                   | 93.57,                   | 85.86,                  |
> |                                                   | 83.12                    | 96.49                    | 98.25                    | 98.16                   |
> | us-patent-phrase-to-phrase-matching               | 96.52<br>91.53,<br>99.15 | 99.51<br>99.21,<br>99.89 | 99.63<br>99.42, 100.00   | 99.91<br>99.79, 100.00  |
> | uw-madison-gi-tract-image-segmentation            | 18.06                    | 22.54                    | 26.18                    | 33.35                   |
> |                                                   | 4.91,                    | 5.30,                    | 5.04,                    | 5.04,                   |
> |                                                   | 43.83                    | 56.43                    | 67.61                    | 89.08                   |
> | ventilator-pressure-prediction                    | 48.78                    | 55.40                    | 55.93                    | 61.78                   |
> |                                                   | 47.96,                   | 50.02,                   | 50.38,                   | 60.83,                  |
> |                                                   | 49.39                    | 63.52                    | 63.52                    | 63.52                   |
> | whale-categorization-playground                   | 92.11                    | 98.55                    | 98.55                    | 99.31                   |
> |                                                   | 86.17,                   | 97.35,                   | 97.35,                   | 98.30,                  |
> |                                                   | 96.59                    | 99.24                    | 99.24                    | 99.81                   |
>
> [Source: AIRA2: Overcoming Bottlenecks in AI Research Agents](https://arxiv.org/abs/2603.26499)
