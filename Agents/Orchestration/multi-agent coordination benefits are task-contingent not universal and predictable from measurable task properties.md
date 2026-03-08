---
created: 2026-03-08
description: A controlled study across 180 configurations derives quantitative scaling principles showing multi-agent coordination helps parallelizable tasks (+81%) but degrades sequential ones (-70%), with a predictive model achieving 87% architecture selection accuracy.
source: https://arxiv.org/abs/2512.08296
type: paper
authors:
  - Yubin Kim
  - Ken Gu
  - Chanwoo Park
  - Chunjong Park
  - Samuel Schmidgall
  - A. Ali Heydari
  - Yao Yan
  - Zhihan Zhang
  - Yuchen Zhuang
  - Yun Liu
  - Mark Malhotra
  - Paul Pu Liang
  - Hae Won Park
  - Yuzhe Yang
  - Xuhai Xu
  - Yilun Du
  - Shwetak Patel
  - Tim Althoff
  - Daniel McDuff
  - Xin Liu
arxiv: "2512.08296"
---

## Abstract

Agents, language model-based systems capable of reasoning, planning, and acting are becoming the dominant paradigm for real-world AI applications. Despite widespread adoption, the principles determining their performance remain underexplored. This paper derives quantitative scaling principles for agent systems by formalizing agentic evaluation and characterizing scaling laws as the interplay between agent quantity, coordination structure, model capability, and task properties. Evaluated across four benchmarks (Finance-Agent, BrowseComp-Plus, PlanCraft, Workbench) with five canonical architectures (Single-Agent and four Multi-Agent: Independent, Centralized, Decentralized, Hybrid) across three LLM families in 180 configurations, the study derives a predictive model (R2=0.524) that predicts optimal coordination strategy for 87% of held-out configurations. Out-of-sample validation on GPT-5.2 achieves MAE=0.071.

## Key Takeaways

The paper's central finding directly challenges the "more agents is all you need" narrative. Rather than universal benefits, multi-agent coordination is governed by three quantifiable trade-offs that practitioners can measure before deployment. This connects to the vault's existing understanding that [[2 to 5 worker agents per lead is the sweet spot for multi agent orchestration]] — the paper provides the theoretical underpinning for why that ratio works: beyond moderate team sizes, per-agent reasoning capacity becomes "prohibitively thin" under fixed token budgets, with communication overhead growing super-linearly (exponent 1.724).

The tool-coordination trade-off (beta=-0.267, p<0.001) is perhaps the most operationally important finding: tool-heavy tasks suffer disproportionately from multi-agent overhead. This validates the intuition behind [[simple financial agents outperform complex ones when tool routing is tight]] — when each agent needs access to many tools, splitting the token budget across agents leaves insufficient capacity for complex tool orchestration. Single-agent systems paradoxically handle tool-rich environments better despite lower absolute efficiency.

The capability saturation threshold at ~45% single-agent baseline performance provides a concrete decision boundary: if your single agent already exceeds 45% accuracy, adding more agents yields diminishing or negative returns. This is the first quantitative criterion replacing heuristic "when to use agents" guidance, and it directly informs how [[orchestration architecture determines multi-agent investment quality]] — the architecture only matters when there's headroom for improvement.

The error amplification findings are striking: independent agents amplify errors 17.2x through unchecked propagation, while centralized coordination contains this to 4.4x through validation bottlenecks. This mechanistically explains why [[planner-worker hierarchies outperform flat coordination for scaling multi-agent coding]] — the orchestrator acts as an error interceptor, catching failures before they propagate to the final output. Decentralized peer debate achieves intermediate error amplification (7.8x) through explicit challenge-response exchanges.

*Agent scaling across model intelligence and system architectures*
![[arxiv-2512-08296-_page_1_Figure_1.jpeg]]

Task decomposability, not complexity or team size, determines coordination success. Finance-Agent tasks decompose into parallelizable subtasks (revenue, cost, market factors analyzed independently), yielding +80.8% improvement with centralized coordination. PlanCraft requires strictly sequential state-dependent reasoning where each action modifies inventory state, and every multi-agent variant degraded performance by 39-70%. This distinction between parallelizable and sequential tasks is the key architectural decision factor, reinforcing the insight from [[intelligent AI delegation requires trust accountability and adaptive monitoring not just task decomposition]] that delegation must match task structure.

*Comparative performance across four agentic benchmarks*
![[arxiv-2512-08296-_page_10_Figure_1.jpeg]]

The predictive scaling equation (Equation 1 in the paper) with 20 parameters enables practitioners to compute expected performance for any architecture given measurable task properties (tool count, single-agent baseline, model capability). Cross-validation confirms 87% correct architecture selection on held-out configurations, substantially exceeding random choice (20%) or capability-only models (54%). The out-of-sample validation on GPT-5.2 confirms four of five scaling principles generalize to unseen frontier models.

## External Resources

- [arXiv paper](https://arxiv.org/abs/2512.08296) — full paper with appendices
- [Artificial Analysis Intelligence Index](https://artificialanalysis.ai/evaluations/artificial-analysis-intelligence-index) — the model capability metric used as a predictor in the scaling equation

## Original Content

> [!quote]- Full Paper Text
> # Towards a Science of Scaling Agent Systems
>
> **Yubin Kim**, **Ken Gu**, **Chanwoo Park**, **Chunjong Park**, **Samuel Schmidgall**, **A. Ali Heydari**, **Yao Yan**, **Zhihan Zhang**, **Yuchen Zhuang**, **Yun Liu**, **Mark Malhotra**, **Paul Pu Liang**, **Hae Won Park**, **Yuzhe Yang**, **Xuhai Xu**, **Yilun Du**, **Shwetak Patel**, **Tim Althoff**, **Daniel McDuff** and **Xin Liu**
> Google Research, Google DeepMind, Massachusetts Institute of Technology
>
> **Agents**, language model (LM)-based systems that are capable of reasoning, planning, and acting are becoming the dominant paradigm for real-world AI applications. Despite this widespread adoption, the principles that determine their performance remain underexplored, leaving practitioners to rely on heuristics rather than principled design choices. We address this gap by deriving quantitative *scaling principles* for agent systems. We first formalize a definition for agentic evaluation and characterize scaling laws as the interplay between agent quantity, coordination structure, model capability, and task properties. We evaluate this across four diverse benchmarks: Finance-Agent, BrowseComp-Plus, PlanCraft, and Workbench, spanning financial reasoning, web navigation, game planning, and workflow execution. Using five canonical agent architectures (Single-Agent System and four Multi-Agent Systems: Independent, Centralized, Decentralized, Hybrid), instantiated across three LLM families, we perform a controlled evaluation spanning 180 configurations, standardizing tools, prompt structures, and token budgets to isolate architectural effects from implementation confounds. We derive a predictive model using empirical coordination metrics, including efficiency, overhead, error amplification, and redundancy, that achieves cross-validated R2=0.524, enabling prediction on unseen task domains by modeling task properties rather than overfitting to a specific dataset. We identify three dominant effects: (1) a *tool-coordination trade-off*: under fixed computational budgets, tool-heavy tasks suffer disproportionately from multi-agent overhead. (2) a *capability saturation*: we observe that coordination yields diminishing or negative returns once single-agent baselines exceed an empirical threshold of ~45%. (3) *topology-dependent error amplification*: independent agents amplify errors 17.2x through unchecked propagation, while centralized coordination contains this to 4.4x. Crucially, coordination benefits are task-contingent. Centralized coordination improves performance by 80.8% on parallelizable tasks like financial reasoning, while decentralized coordination excels on dynamic web navigation (+9.2% vs. +0.2%). Yet for sequential reasoning tasks, every multi-agent variant we tested degraded performance by 39-70%. The framework predicts the optimal coordination strategy for 87% of held-out configurations. Out-of-sample validation on GPT-5.2, released after our study, achieves MAE=0.071 and confirms four of five scaling principles generalize to unseen frontier models, providing a quantitatively predictive framework for *agentic scaling* based on measurable task properties.
>
> ## 1. Introduction
>
> *Agents*, language model-driven systems that operate through iterative cycles of reasoning, planning, and acting, adapting their behavior based on environmental or tool-generated feedback, have achieved remarkable performance in diverse applications, from code generation, web browsing, medical decision-making, finance, sustainability, to scientific discovery. As tasks grow in complexity and require sustained environmental interaction, the field has increasingly turned to multi-agent systems (MAS), relying on the premise that specialized collaboration consistently outperforms single-agent systems (SAS). Previous work has made positive claims about multi-agent systems: "More agents is all you need", suggesting that agent collaboration follows collaborative scaling principles, and that MAS consistently outperforms single-agent systems (SAS) on complex tasks. Yet, despite rapid adoption, there remains no principled quantitative framework to predict when adding agents amplifies performance and when it erodes it.
>
> *Figure 1: Agent Scaling across model intelligence and system architectures*
> ![[arxiv-2512-08296-_page_1_Figure_1.jpeg]]
>
> To determine when multi-agent coordination provides benefit, we first establish which task categories require agentic capabilities. A critical prerequisite is distinguishing between *agentic* and *non-agentic* evaluation paradigms. We characterize *agentic tasks* as those requiring: (i) sustained multistep interactions with an external environment, (ii) iterative information gathering under partial observability, and (iii) adaptive strategy refinement based on environmental feedback.
>
> These characteristics differentiate tasks like web browsing, financial trading, software engineering, and interactive planning from traditional static benchmarks. This distinction matters profoundly because multi-agent system evaluations have been conducted predominantly on non-agentic tasks, potentially providing misleading guidance about when collaboration provides value. Multi-agent systems that show monotonic improvement with team size on static benchmarks (reaching 89% on HumanEval with five agents) exhibit fundamentally different scaling behavior when evaluated on tasks requiring sustained environmental interaction, where coordination overhead and error propagation dynamics dominate.
>
> Fundamentally, this distinction reflects a trade-off between context integration and diversity. Single-agent systems maximize context integration by maintaining a unified memory stream in which all reasoning steps share full access to prior history. In contrast, multi-agent systems impose intrinsic information fragmentation: while parallel agents enable diverse exploration, they incur an unavoidable *coordination tax* in which the global context must be compressed into inter-agent messages.
>
> Two fundamental challenges hinder progress toward principled multi-agent design. **First**, existing MAS evaluations compare architectures using different prompts, tools, or computational budgets, conflating architectural effects with implementation choices. **Second**, evaluations focus exclusively on final accuracy metrics without examining process dynamics such as coordination overhead, error propagation, and information flow.
>
> Our primary contributions are:
> - **Formalization of Agentic Evaluation rigor:** We redefine rigorous agentic assessment by distinguishing it from static reasoning tasks
> - **Controlled evaluation of agent systems:** We establish a framework spanning 180 configurations across three LLM families and four diverse benchmarks
> - **Intelligence-Coordination alignment:** We characterize the non-linear relationship between foundational model capabilities and agentic performance
> - **Quantitative scaling principles and architecture alignment:** We derive a mixed-effects model (R2=0.524) using empirical coordination metrics
>
> ## 2. Related Work
>
> **Multi-Agent Systems (MAS) versus Single-Agent Systems (SAS):** A Single-Agent System contains one reasoning locus. A Multi-Agent System comprises multiple LLM-backed agents communicating through structured message passing, shared memory, or orchestrated protocols. MAS architectures vary by topology: Independent systems aggregate isolated outputs; Decentralized enable peer-to-peer exchange; Centralized route through orchestrators; Hybrid combine hierarchical control with lateral communication. Empirical challenges: benefits diminish as base models improve, with frontier models often outperforming teams; 14 failure modes identified; comparable performance achieved at 6-45% cost through dynamic architecture search.
>
> **Agentic Tasks and Benchmarks:** Agentic tasks require (1) sustained multi-step environment interactions, (2) iterative information gathering under partial observability, and (3) adaptive strategy refinement from feedback. On non-agentic benchmarks, multi-agent systems show monotonic improvement through ensemble effects (89% on HumanEval with five agents), as voting corrects errors without sequential compounding.
>
> **Scaling Laws and Coordination Mechanisms:** Neural scaling follows power laws requiring million-fold parameter increases, while collaborative scaling exhibits logistic growth patterns at smaller scales. Coordination benefits arise from matching communication topology to task structure, not from scaling the number of agents.
>
> ## 3. Agent Systems and Tasks
>
> ### 3.1. System Definition
>
> An agent system S = (A, E, C, Omega) consists of a set of agents, a shared environment, a communication topology, and an orchestration policy.
>
> **Single-Agent System (SAS):** One reasoning locus, computational complexity O(k), zero communication overhead, minimal memory O(k).
>
> **Multi-Agent System (MAS):** Multiple agents interacting through communication topology C and orchestration policy Omega.
>
> Communication topologies:
> - **Independent**: agent-to-aggregator only, no peer communication
> - **Centralized**: orchestrator-to-agents only
> - **Decentralized**: all-to-all topology
> - **Hybrid**: orchestrator plus limited peer-to-peer
>
> ### 3.2. Agentic Tasks and Benchmarks
>
> Agentic tasks require: Sequential Interdependence, Partial Observability, and Adaptive Strategy Formation.
>
> ## 4. Experiments & Results
>
> ### 4.1. Setup
>
> **Benchmarks:** BrowseComp-Plus (web browsing), Finance-Agent (financial analysis), PlanCraft (game planning), WorkBench (workplace tasks). 180 experiments total.
>
> **LLMs:** OpenAI (GPT-5-nano, GPT-5-mini, GPT-5), Google (Gemini 2.0 Flash, 2.5 Flash, 2.5 Pro), Anthropic (Claude Sonnet 3.7, 4.0, 4.5). Intelligence Index values from 42 to 71.
>
> ### 4.2. Main Results
>
> *Figure 2: Comparative performance of SAS and MAS across four agentic benchmarks*
> ![[arxiv-2512-08296-_page_10_Figure_1.jpeg]]
>
> **MAS exhibits domain-dependence with architectural variation.** On Finance Agent: Centralized +80.8%, Decentralized +74.5%, Hybrid +73.1%. On Workbench: Decentralized +5.7%. On BrowseComp-Plus: Decentralized +9.2%. On PlanCraft: universal degradation from -39.1% (Hybrid) to -70.1% (Independent).
>
> PlanCraft trajectories show single agents following direct 3-step execution, while centralized MAS decomposes into artificial subtasks consuming token budget on coordination rather than reasoning. Finance Agent's natural decomposability (revenue, cost, market factors analyzed independently) aligns with coordination structure.
>
> Overall mean MAS improvement: -3.5% (95% CI: [-18.6%, +25.7%]), with range from -70.0% to +80.9%.
>
> **Domain Complexity Moderates Coordination Efficacy.** Mixed-effects regression confirms domain complexity as a significant negative moderator (beta=-0.114, p=0.002). Sequential interdependence, rather than complexity alone, determines coordination viability.
>
> ### 4.3. Scaling Principles
>
> **Mixed-Effects Model Achieves 52.4% Cross-Validated Variance Explanation.** The scaling equation relates performance to four predictor categories: base model capability, system configuration, task properties, and empirically measured coordination metrics. Cross-validated R2=0.524 (+/-0.033), MAE=0.089, RMSE=0.112. Substantially outperforms simpler alternatives using only architectural labels (R2=0.43) or intelligence alone (R2=0.28).
>
> *Figure 3: Cost-Performance Trade-offs Across Model Families and Architectures*
> ![[arxiv-2512-08296-_page_15_Figure_1.jpeg]]
>
> **The Efficiency-Tools Interaction Dominates** (beta=-0.267, p<0.001). Tool-heavy tasks suffer disproportionately from multi-agent inefficiency. Single-agent systems achieve Ec=0.466 while multi-agent architectures range from Ec=0.074 (hybrid) to Ec=0.234 (independent), a 2-6x efficiency penalty.
>
> **Error Amplification Exhibits Architecture-Dependent Failure Modes.** Single-agent (Ae=1.0), centralized (Ae=4.4), decentralized (Ae=7.8), hybrid (Ae=5.1), independent (Ae=17.2). However, neither the main effect nor its interaction with tool count reaches statistical significance after controlling for other metrics.
>
> **Overhead Scales Non-Linearly with Task Complexity** via the O%xT interaction (beta=-0.162, p<0.001). Independent (58%), centralized (285%), decentralized (263%), hybrid (515%) overhead relative to SAS.
>
> **Intelligence Shows Linear Positive Effect** (beta=0.171, p=0.001). Quadratic term not significant (p=0.509).
>
> **Redundancy Provides Marginal Benefit at Scale** (betaRxn=0.047, p=0.001). Minor compared to overhead penalties (3.4x larger) and efficiency losses (5.7x larger).
>
> The scaling principle achieves 87% correct architecture selection on held-out configurations. Decision boundary between single-agent and multi-agent corresponds to raw performance ~0.45.
>
> ### 4.4. Coordination Efficiency, Error Dynamics, and Information Transfer
>
> **Turn count follows power-law scaling with number of agents:** T = 2.72 x (n+0.5)^1.724, R2=0.974. Super-linear exponent reflects quadratic message complexity tempered by bandwidth limits. Beyond 3-4 agents, per-agent reasoning quality degrades sharply under fixed budgets.
>
> **Message Density Exhibits Logarithmic Saturation.** S = 0.73 + 0.28 ln(c), R2=0.68. Performance plateaus near c*=0.39 messages/turn.
>
> **Error absorption mechanisms.** Centralized/Hybrid/Decentralized architectures achieve 22.7% average error reduction, peaking at 31.4% for Finance Agent. Independent MAS shows no error correction (+4.6% amplification).
>
> *Figure 4: Agent Heterogeneity Effects on Multi-Agent Performance*
> ![[arxiv-2512-08296-_page_21_Figure_1.jpeg]]
>
> **Error Taxonomy:** Four categories — Logical Contradiction, Numerical Drift, Context Omission, Coordination Failure. Centralized reduces context omission by 66.8% via orchestrator synthesis. Hybrid shows highest coordination failure rate (12.4%) due to protocol complexity.
>
> *Figure 5: Number of agents scaling reveals model-dependent coordination limits*
> ![[arxiv-2512-08296-_page_22_Figure_1.jpeg]]
>
> Three operational coordination regimes: (i) Under-coordination (O<100%): minimal accuracy gain; (ii) Optimal band (200-300%): highest success-cost ratio; (iii) Over-coordination (O>400%): reduced efficiency, protocol complexity introducing coordination-failure modes.
>
> **Information Gain predicts MAS benefit in low-complexity domains.** In Finance Agent, IG correlates strongly with MAS-SAS gap (r=0.71, p<0.001). In open-world domains (BrowseComp-Plus), IG shows weak and non-significant predictive power.
>
> **Economic Efficiency:** SAS achieves 67.7 successes/1K tokens; Centralized 21.5 (3.1x worse); Hybrid 13.6 (5.0x worse).
>
> ## 5. Limitations and Future Works
>
> (i) Scaling to larger collectives may face fundamental barriers from super-linear communication overhead. (ii) All agents share identical base architectures — future work should investigate teams combining fundamentally different model architectures. (iii) Tool-heavy environments represent a primary failure mode — specialized coordination protocols needed. (iv) Prompts were not optimized per model family. (v) Four benchmarks may not capture the full spectrum of agentic task characteristics. (vi) Token consumption and latency grow substantially with agent count, often without proportional performance gains.
>
> ## 6. Conclusion
>
> Multi-agent performance is governed by quantifiable trade-offs: a tool-coordination trade-off, capability saturation beyond ~45% single-agent baselines, and architecture-dependent error amplification ranging from 4.4x (centralized) to 17.2x (independent). Performance gains vary from +80.9% on Finance Agent to -70.0% on PlanCraft. The predictive model (R2=0.524) achieves 87% accuracy in selecting optimal architectures for held-out configurations. Out-of-sample validation on GPT-5.2 confirms four of five scaling principles generalize with MAE=0.071.
>
> ## Appendix A: Model Intelligence Index
>
> Intelligence Index values for all models: GPT-5.2 (75), GPT-5 (71), Claude Sonnet 4.5 (68), GPT-5 mini (59), Gemini 2.5 Pro (65), Gemini 2.5 Flash (58), Gemini 2.0 Flash (47), Claude Sonnet 4.0 (55), Claude Sonnet 3.7 (47), GPT-5 nano (42).
>
> ## Appendix B: Out-of-Sample Validation
>
> GPT-5.2 (Intelligence Index=75) validation: MAE=0.071, four of five qualitative findings generalize. Architecture selection accuracy: 75% for MAS ranking (3/4 correct), though SAS over-predicted. Capability ceiling persists (PSA=0.45, best MAS gain=+6.7%). Independent MAS shows predicted degradation (-22.2%).
>
> ## Appendix C: Domain Complexity
>
> Domain complexity D in [0,1]: Workbench (0.000), Finance Agent (0.407), PlanCraft (0.419), BrowseComp-Plus (0.839). Critical threshold at D~0.40: below, MAS yields net positive returns; above, coordination overhead consumes resources otherwise allocated to reasoning.
>
> *Figure 6: Benchmark-specific scaling dynamics across LLM families*
> ![[arxiv-2512-08296-_page_37_Figure_1.jpeg]]
>
> [Source: Towards a Science of Scaling Agent Systems](https://arxiv.org/pdf/2512.08296)
