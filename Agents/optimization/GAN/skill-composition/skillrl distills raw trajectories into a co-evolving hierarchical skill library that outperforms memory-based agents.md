---
created: 2026-03-22
description: A framework that distills raw agent trajectories into a hierarchical skill library and co-evolves it with the agent's policy through recursive reinforcement learning, achieving state-of-the-art on embodied and search-augmented tasks.
source: https://arxiv.org/abs/2602.03665
type: paper
---

## Key Takeaways

SkillRL addresses a fundamental limitation of memory-based LLM agents: raw trajectory storage is noisy, redundant, and fails to produce transferable knowledge. The core insight is that effective experience transfer requires abstraction. Rather than memorizing what happened, the agent should distill why something worked or failed into compact, reusable skills. This distillation is performed by a teacher model (o3) that processes both successful and failed trajectories differentially: successes yield strategic patterns, while failures are synthesized into concise counterfactual lessons. This asymmetric treatment of positive and negative experience is reminiscent of how [[Curiosity-Driven Red Teaming]] and [[Rainbow Teaming]] use failure modes to drive exploration, but SkillRL applies it to skill formation rather than attack generation.

The hierarchical SKILLBANK structure, split into general skills and task-specific skills, provides a principled way to organize abstracted knowledge. General skills capture universal strategies (systematic exploration, state verification, goal tracking) while task-specific skills encode domain-particular heuristics. This two-level hierarchy enables efficient retrieval via semantic similarity at inference time, achieving roughly 10-20x token compression compared to raw trajectory storage. The retrieval mechanism parallels how [[AgentGen]] and [[AgentFrontier]] construct curricula that adapt to the agent's current capability frontier, but here the adaptation happens at the skill-retrieval level rather than the environment-generation level.

The recursive skill evolution mechanism is where SkillRL most clearly connects to the adversarial optimization theme. During RL training with GRPO, the skill library is treated as a dynamic component rather than a static knowledge base. After each validation epoch, failed trajectories are analyzed to identify gaps in the current skill library, and new skills are synthesized to cover those gaps. This creates a virtuous cycle: as the policy improves, it encounters new failure modes at the frontier of its capability, which drive skill library expansion, which enables further policy improvement. This co-evolutionary dynamic mirrors the generator-solver loops in [[Absolute Zero]] and [[Self-Challenging Improves Self-Reasoning]], but with the crucial difference that one side of the co-evolution is a structured knowledge base rather than a neural network.

The cold-start SFT stage addresses a practical problem that many skill-augmented systems overlook: a base model does not inherently know how to use skills. Simply providing skills in context yields limited benefit unless the model has been explicitly trained to retrieve, interpret, and apply them. The 20% performance drop without cold-start SFT in the ablations confirms this. This finding has implications for systems like [[Voyager builds a persistent skill library that enables open-ended exploration without gradient updates]], which relies on GPT-4's native ability to use retrieved code snippets without any adaptation training. SkillRL's approach of first teaching skill utilization through SFT, then optimizing through RL, creates a more robust pipeline.

The results are striking: a 7B parameter model (Qwen2.5-7B-Instruct) with SkillRL outperforms GPT-4o by 41.9% on ALFWorld and Gemini-2.5-Pro by 29.6%. This demonstrates that structured experiential knowledge can compensate for raw model scale, a finding that resonates with the [[RM Ensembles]] and [[Evaluator Stress Tests]] work on how evaluation infrastructure can amplify smaller models' effective capabilities. The 12.3% improvement over vanilla GRPO on ALFWorld is directly attributable to skill augmentation, isolating the contribution of the skill mechanism from the RL optimizer.

The comparison with memory-augmented RL baselines (MemRL, EvolveR, Mem0+GRPO) is particularly informative. MemRL, which updates memory but freezes the policy, achieves only 21.4% on ALFWorld. EvolveR, which jointly updates both, reaches 43.8%. SkillRL's 89.9% demonstrates that the abstraction layer, converting raw memory into structured skills, is the decisive factor. This validates the paper's central hypothesis and suggests that for the broader field of adversarial agent optimization, the quality of knowledge representation matters more than the sophistication of the optimization algorithm. The [[PLR]] and [[ACCEL]] approaches to curriculum design could potentially benefit from similar skill-abstraction mechanisms rather than operating purely on environment-level features.

## External Resources

- [SkillRL Code](https://github.com/aiming-lab/SkillRL) — official implementation

## Original Content

> [!quote]- Full Paper Text
> # SKILLRL: Evolving Agents via Recursive Skill-Augmented Reinforcement Learning
> 
> Peng Xia <sup>1\*</sup> Jianwen Chen <sup>1\*</sup> Hanyang Wang <sup>12\*</sup> Jiaqi Liu <sup>1</sup> Kaide Zeng <sup>1</sup> Yu Wang <sup>3</sup> Siwei Han <sup>1</sup> Yiyang Zhou <sup>1</sup> Xujiang Zhao <sup>4</sup> Haifeng Chen <sup>4</sup> Zeyu Zheng <sup>5</sup> Cihang Xie <sup>6</sup> Huaxiu Yao <sup>1</sup>
> 
> #### **Abstract**
> 
> Large Language Model (LLM) agents have shown stunning results in complex tasks, yet they often operate in isolation, failing to learn from past experiences. Existing memory-based methods primarily store raw trajectories, which are often redundant and noise-heavy. This prevents agents from extracting high-level, reusable behavioral patterns that are essential for generalization. In this paper, we propose SKILLRL, a framework that bridges the gap between raw experience and policy improvement through automatic skill discovery and recursive evolution. Our approach introduces an experience-based distillation mechanism to build a hierarchical skill library SKILL-BANK, an adaptive retrieval strategy for general and task-specific heuristics, and a recursive evolution mechanism that allows the skill library to co-evolve with the agent's policy during reinforcement learning. These innovations significantly reduce the token footprint while enhancing reasoning utility. Experimental results on ALF-World, WebShop and seven search-augmented tasks demonstrate that SKILLRL achieves stateof-the-art performance, outperforming strong baselines over 15.3% and maintaining robustness as task complexity increases. Code is available at this https://github.com/aiming-lab/SkillRL.
> 
> #### 1. Introduction
> 
> Large language model (LLM) agents (Yao et al., 2022b; Shinn et al., 2023) have demonstrated remarkable capabilities across various sophisticated tasks, such as web navigation (Google, 2025; OpenAI, 2025c) and deep research (OpenAI, 2025b; Google, 2024; Team et al., 2025),
> 
> Preprint. February 10, 2026.
> 
> <span id="page-0-0"></span>![[skillrl_page_0_Figure_9.jpeg]]
> 
> Figure 1. (a) Overview of the SKILLRL pipeline. Unlike previous methods (gray dashed lines) that store raw trajectories and discard failures, SKILLRL employs an experience-based distillation mechanism to transform diverse experiences into structured skills. (b) Performance on ALFWorld validation set (Shridhar et al.). SKILLRL achieves faster convergence and superior success rates compared to vanilla GRPO and memory-augmented RL.
> 
> by interacting with complex environments through natural language. Despite these advances, each task execution remains largely episodic. Current LLM agents operate in isolation, unable to learn from past successes or failures (Zhang et al., 2025b), which significantly hinders their evolution. Consequently, a fundamental challenge remains: how can agents efficiently learn from experience and transfer that knowledge to other tasks?
> 
> The existing memory-based methods for LLM agents primarily involve saving raw trajectories directly into external databases during the sampling process to serve as references for similar future tasks (Shinn et al., 2023; Zhao et al., 2024). While intuitive, these raw trajectories are often lengthy and contain significant redundancy and noise (Chhikara et al., 2025), making it difficult for the model to extract critical information. Recent work has attempted to compress trajectories and update the memory bank via online training (Zhang et al., 2025b; 2026), improving memory efficiency. However, these methods merely mimic past solutions and they fail to distill core principles or adapt the agent's internal policy to leverage memory for guided decision-making. As depicted in the dashed flow of Figure 1(a), such approaches often struggle with the trade-off between information den-
> 
> <sup>&</sup>lt;sup>1</sup>UNC-Chapel Hill <sup>2</sup>University of Chicago <sup>3</sup>University of California San Diego <sup>4</sup>NEC Labs America <sup>5</sup>University of California Berkeley <sup>6</sup>University of California Santa Cruz. Correspondence to: Peng Xia <pxia@cs.unc.edu>, Huaxiu Yao <huaxiu@cs.unc.edu>.
> 
> sity and noise, leading to sub-optimal performance or even degradation as shown in Figure 1(b).
> 
> We argue that these approaches miss a crucial insight: effective experience transfer requires *abstraction*. Human experts do not memorize every action in every situation; instead, they develop *skills* (Anthropic, 2024), compact and reusable strategies that capture the essence of how to accomplish specific subtasks. Inspired by this observation, we propose SKILLRL, a framework that bridges the gap between raw experience and efficient policy improvement through automatic skill discovery and recursive skill evolution.
> 
> SKILLRL first introduces an experience-based skill distillation mechanism, which gathers diverse trajectories from environment rollouts and applies differential processing: successful episodes are preserved as demonstrations, while failed ones are synthesized into concise failure lessons to mitigate context noise. Secondly, we transform these experiences into a hierarchical skill library SKILLBANK, differentiating between general skills for universal strategic guidance and task-specific skills for task-level heuristics. This abstraction allows the agent to adaptively retrieve relevant skills during decision-making, significantly reducing the token footprint while enhancing reasoning utility. Lastly, SKILLRL incorporates a recursive skill evolution mechanism during reinforcement learning (RL), where the skill library is treated as a dynamic component rather than a static knowledge source. By analyzing failure modes after each validation epoch to generate new skills or refine existing ones, our approach ensures the skill library and the agent's policy co-evolve, maintaining robustness as task complexity increases. As demonstrated in Figure 1(b), SKILLRL achieves substantially faster convergence and higher asymptotic performance.
> 
> The primary contribution is SKILLRL, a framework that enables LLM agents to bridge the gap between raw experience and policy improvement through automatic skill discovery and recursive evolution. By distilling redundant trajectories into a hierarchical SKILLBANK, our method abstracts general and task-specific skills to guide decision-making efficiently. Furthermore, we introduce a recursive evolution mechanism that ensures the skill library and agent policy coevolve during reinforcement learning. Empirical results on ALFWorld, WebShop, and seven search-augmented benchmarks demonstrate that SKILLRL achieves state-of-the-art performance with 15.3% improvements, significantly outperforming current memory-based agent-tuning baselines in both task success and reasoning utility.
> 
> #### 2. Preliminaries
> 
> **LLM Agents.** We consider an agent operating in an interactive environment  $\mathcal{E}$ . At each timestep t, the agent observes
> 
> a state  $o_t \in \mathcal{O}$ , selects an action  $a_t \in \mathcal{A}$ , and receives a reward  $r_t$  and next observation  $o_{t+1}$ . A trajectory  $\tau = (o_0, a_0, r_0, \ldots, o_T, a_T, r_T)$  captures one episode of interaction. Tasks are specified by natural language descriptions d. An LLM-based agent parameterized by  $\theta$  implements a policy  $\pi_{\theta}(a_t|o_{\leq t},d,c)$  where c represents additional context (e.g., skills, demonstrations). Our goal is to learn a policy that maximizes expected return  $\max_{\theta} \mathbb{E}_{\tau \sim \pi_{\theta}} \left[ \sum_{t=0}^{T} \gamma^t r_t \right]$  subject to context length constraints  $|c| \leq L_{\max}$ .
> 
> Group Relative Policy Optimization (GRPO). GRPO (Shao et al., 2024) is a reinforcement learning method that avoids training a critic by using intra-group relative rewards to optimize the policy. For each query x, the model samples G responses  $\{y^{(1)}, \ldots, y^{(G)}\}$ , which are scored to obtain rewards  $\{R_1, \ldots, R_G\}$ . GRPO computes normalized advantages and updates the policy with a PPO-style clipped objective (Schulman et al., 2017):
> 
> $$\begin{split} \mathcal{J}_{\text{GRPO}}(\theta) &= \mathbb{E}_{x,\{y_i\}} \left[ \frac{1}{G} \sum_{i=1}^{G} \min \left( r_i A_i, \right. \right. \\ \left. \text{clip}(r_i, 1 - \epsilon, 1 + \epsilon) A_i \right) - \beta D_{\text{KL}}(\pi_{\theta} \| \pi_{\text{ref}}) \right], \end{split} \tag{1}$$
> 
> where  $r_i = \frac{\pi_{\theta}(y_i|x)}{\pi_{\text{old}}(y_i|x)}$  is the importance ratio,  $A_i = \frac{R_i - \text{mean}(\{R_j\}_{j=1}^G)}{\text{std}(\{R_j\}_{j=1}^G)}$  is the normalized advantage,  $\epsilon$ ,  $\beta$  are hyperparameters, and  $\pi_{\text{old}}$  is the policy before the current update.
> 
> ### 3. SKILLRL
> 
> In this section, as illustrated in Figure 2, we propose SKILLRL, a framework designed to bridge the gap between raw interaction experience and policy improvement through automatic skill discovery and recursive evolution. SKILLRL consists of three core components. First, we develop an experience-based skill distillation mechanism to transform redundant trajectories into concise, actionable knowledge. Second, we organize these distilled experiences into a hierarchical skill library  $\mathcal{S}$ , enabling efficient retrieval of general and task-specific expertise. Lastly, we introduce a recursive skill evolution mechanism that leverages RL to dynamically refine the skill library in tandem with the agent's policy. We detail these components as follows:
> 
> #### 3.1. Experience-based Skill Distillation
> 
> Raw trajectories  $\tau$  collected from environment interactions are verbose, containing exploratory actions, backtracking, and redundant steps that obscure the critical decisions leading to success or failure. To transform these experiences into actionable knowledge, we employ a teacher model  $\mathcal{M}_T$  to distill trajectories into compact, reusable skills.
> 
> Specifically, we first deploy a base LLM agent  $\pi_{\text{base}}$  in the
> 
> <span id="page-2-0"></span>![[skillrl_page_2_Figure_1.jpeg]]
> 
> Figure 2. Overview of the SKILLRL framework. We collect trajectories using a base model, distill them into a hierarchical skill library, perform cold-start SFT to enable skill utilization, and then conduct RL training with dynamic skill evolution based on validation failures.
> 
> target environment  $\mathcal E$  to collect diverse trajectories. Unlike prior approaches that retain only successful episodes, we deliberately preserve both successful trajectories  $\mathcal T^+=\{\tau_i:r(\tau_i)=1\}$  and failed trajectories  $\mathcal T^-=\{\tau_i:r(\tau_i)=0\}$ , where  $r(\tau)$  denotes the binary task success indicator. Failed trajectories reveal failure modes and boundary conditions, i.e., information difficult to infer from successes alone.
> 
> We apply differential processing based on trajectory outcomes. For *successful trajectories*  $\tau^+ \in \mathcal{T}^+$ , we extract the strategic patterns that led to task completion:
> 
> $$s^+ = \mathcal{M}_T(\tau^+, d). \tag{2}$$
> 
> The teacher model identifies critical decision points, the reasoning behind correct actions, and generalizable patterns that transfer beyond the specific task instance.
> 
> For failed trajectories  $\tau^- \in \mathcal{T}^-$ , direct inclusion in context is infeasible due to their length and noise. Instead, we synthesize concise failure lessons:
> 
> $$s^- = \mathcal{M}_T(\tau^-, d). \tag{3}$$
> 
> The analysis identifies: (1) the point of failure, (2) the flawed reasoning or action, (3) what should have been done, and (4) general principles to prevent similar failures. This transforms verbose failed episodes into counterfactuals.
> 
> ## 3.2. Hierarchical Skill Library (SKILLBANK) Construction
> 
> Following the design principles of Agent Skills (Anthropic, 2024), we organize the distilled knowledge into a hierarchical skill library SKILLBANK that enables efficient retrieval of relevant expertise during decision-making.
> 
> **Skill Organization.** We structure SKILLBANK into two levels: 1) *General Skills*  $S_q$  capture universal strategic prin-
> 
> ciples applicable across all task types within an environment. These typically include exploration strategies (e.g., systematic search patterns, prioritizing unvisited locations), state management principles (e.g., verifying preconditions before actions), and goal-tracking heuristics (e.g., maintaining progress counters, terminating only upon verified completion). General skills provide foundational guidance that transfers across different task categories. 2) Task-Specific Skills  $S_k$  encode specialized knowledge for task category k. These capture domain-specific action sequences, taskparticular preconditions and constraints, common failure modes unique to the task type, and optimized procedures that exploit task structure. By organizing trajectories by task type during collection, we enable extraction of fine-grained, category-specific strategies that complement the broader general skills.
> 
> The complete skill library SKILLBANK is  $S_g \cup \bigcup_{k=1}^K S_k$ . Each skill  $s \in SKILLBANK$  is structured with: a concise name (e.g., systematic exploration), a principle describing the strategy, and when\_to\_apply conditions specifying applicability. This format enables efficient retrieval while providing clear guidance for application.
> 
> **Skill Retrieval.** At inference, given a task description d, the agent retrieves relevant skills to augment its context. General skills  $S_g$  are always included as foundational guidance. Task-specific skills are retrieved via semantic similarity:
> 
> $$S_{\text{ret}} = \text{TopK} \left( \{ s \in S_k : \sin(e_d, e_s) > \delta \}, K \right), \quad (4)$$
> 
> where  $e_d$ ,  $e_s$  are embeddings of the task description and skill respectively,  $\delta$  is a similarity threshold, and K controls the number of retrieved skills. The policy then conditions on
> 
> #### <span id="page-3-0"></span>Algorithm 1 SKILLRL: Recursive Skill-Augmented RL
> 
> ```
> Require: Base model \pi_{\text{base}}, teacher \mathcal{M}_T, environment \mathcal{E}
> Ensure: Trained policy \pi_{\theta^*}, evolved skill library SKILLBANK*
>   1: ▷ Experience-based Skill Distillation
>  2: \mathcal{T}^+, \mathcal{T}^- \leftarrow \text{Rollout}(\pi_{\text{base}}, \mathcal{E})
>  3: for all \tau^+ \in \mathcal{T}^+ do
>  4: s^+ \leftarrow \mathcal{M}_T(\tau^+)
>  5: end for
>  6: for all \tau^- \in \mathcal{T}^- do
>       s^- \leftarrow \mathcal{M}_T(\tau^-)
>  8: end for
>  9: ▷ Hierarchical Skill Library Construction
> 10: S_g \leftarrow general skills from distilled experiences
> 11: for all task type k do
>           S_k \leftarrow \text{task-specific skills for category } k
> 12:
> 13: end for
> 14: SKILLBANK \leftarrow \mathcal{S}_g \cup \bigcup_k \mathcal{S}_k
> 15: ▷ Recursive Skill Evolution via RL
> 16: // Cold-start initialization
> 17: \mathcal{D}_{SFT} \leftarrow \mathcal{M}_T(\mathcal{E}, SKILLBANK)
> 18: \theta \leftarrow SFT(\pi_{base}, \mathcal{D}_{SFT}); \quad \pi_{ref} \leftarrow \pi_{\theta}
> 19: // RL with recursive evolution
> 20: for epoch = 1 to N do
>           for all task d \ \mathbf{do}
> 21:
>                S_{\text{ret}} \leftarrow \text{Retrieve}(d, SKILLBANK})
> 22:
>                Sample \{\tau^{(i)}\}_{i=1}^G \sim \pi_{\theta}(\cdot|d,\mathcal{S}_g,\mathcal{S}_{\text{ret}})
> Compute \{R_i\}_{i=1}^G and update \theta via GRPO
> 23:
> 24:
> 25:
>            if validation epoch then
> 26:
>                \mathcal{T}_{\text{val}}^- \leftarrow \text{failed validation trajectories}
> 27:
>                \mathcal{S}_{\text{new}} \leftarrow \mathcal{M}_T(\mathcal{T}_{\text{val}}^-, \text{SKILLBANK})
> 
> \text{SKILLBANK} \leftarrow \text{SKILLBANK} \cup \mathcal{S}_{\text{new}}
> 28:
> 29:
> 30:
>            end if
> 31: end for
> 32: return \pi_{\theta}, SKILLBANK
> ```
> 
> the retrieved skills:
> 
> $$a_t \sim \pi_{\theta}(a_t | o_{\le t}, d, \mathcal{S}_a, \mathcal{S}_{\text{ret}}).$$
>  (5)
> 
> Notably, skill distillation achieves 10– $20\times$  token compression compared to raw trajectories while enhancing rather than degrading the utility of the original experience. This compression allows the agent to leverage rich experiential knowledge within limited context windows.
> 
> #### 3.3. Recursive Skill Evolution
> 
> A static skill library cannot anticipate all scenarios the agent will encounter. As the policy improves and explores new state regions, it faces situations where existing skills provide insufficient guidance. We introduce recursive skill evolution during reinforcement learning to address this limitation, enabling the skill library and agent policy to co-evolve.
> 
> **Cold-Start Initialization.** Before RL training, we address a critical challenge: the base agent has not learned how to effectively utilize skills. Simply providing skills to an unchanged model yields limited benefit (Guo et al., 2025). We therefore perform a cold-start supervised fine-tuning
> 
> (SFT) stage (Ouyang et al., 2022), where the teacher model  $\mathcal{M}_T$  generates N skill-augmented reasoning traces  $\mathcal{D}_{SFT} = \{(d_i, \mathcal{S}_i, \tau_i^*)\}_{i=1}^N$  demonstrating how to retrieve, interpret, and apply skills during decision-making. The base model is then fine-tuned on these demonstrations:
> 
> $$\theta_{\text{sft}} = \arg\min_{\theta} \mathcal{L}_{\text{CE}}(\mathcal{D}_{\text{SFT}}; \theta),$$
>  (6)
> 
> where  $\mathcal{L}_{\text{CE}}$  denotes the cross-entropy loss. The resulting model  $\pi_{\theta_{\text{sft}}}$  serves as both the starting point for RL training and the reference policy  $\pi_{\text{ref}}$  for KL regularization.
> 
> Recursive Skill Evolution. A static skill library cannot anticipate all scenarios the agent will encounter. As the policy improves and explores new state regions, it faces situations where existing skills provide insufficient guidance. We introduce recursive skill evolution to address this limitation. The process begins with an initial skill library containing baseline task-action principles.
> 
> After each validation epoch, we monitor the success rate Acc(C) for each task category C. To ensure targeted growth, the evolution is triggered only for categories where  $Acc(C) < \delta$ . We then collect failed trajectories  $\mathcal{T}_{\mathrm{val}}^- = \{\tau_j: r(\tau_j) = 0\}_{j=1}^M$  using a diversity-aware stratified sampling strategy: trajectories are grouped by category, prioritized by the severity of failure (negative rewards), and selected via round-robin sampling to maintain categorical entropy. Then we will analyze these samples to identify gaps:
> 
> $$S_{\text{new}} = \mathcal{M}_T(\mathcal{T}_{\text{val}}^-, \text{SKILLBANK}).$$
>  (7)
> 
> The teacher model is prompted to: (1) identify failure patterns not addressed by current skills, (2) propose new skills to cover these gaps, and (3) suggest refinements to existing skills that proved ineffective. The library is then updated:  $SKILLBANK \leftarrow SKILLBANK \cup S_{new}$ .
> 
> This creates a virtuous cycle: as the agent improves, it encounters new challenges, which drive skill library expansion, which enables further improvement.
> 
> **RL-based Policy Optimization.** We optimize the skill-augmented policy using GRPO. For each task with description d, the agent first retrieves relevant skills and then samples G complete trajectories  $\{\tau^{(1)},\ldots,\tau^{(G)}\}$  from the current policy  $\pi_{\theta}$ . Each trajectory  $\tau^{(i)}$  receives a binary reward  $R_i = r(\tau^{(i)}) \in \{0,1\}$  indicating task successfulness. The normalized advantage for each trajectory is computed as:
> 
> $$A_{i} = \frac{R_{i} - \text{mean}(\{R_{j}\}_{j=1}^{G})}{\text{std}(\{R_{j}\}_{j=1}^{G})}.$$
>  (8)
> 
> The policy is updated according to:
> 
> $$\mathcal{J}(\theta) = \mathbb{E}_{d,\{\tau^{(i)}\}} \left[ \frac{1}{G} \sum_{i=1}^{G} \min\left(\rho_{i} A_{i}, \right. \right. \\ \left. \text{clip}(\rho_{i}, 1 - \epsilon, 1 + \epsilon) A_{i} \right) - \beta D_{\text{KL}}(\pi_{\theta} \| \pi_{\text{ref}}) \right],$$
> 
> $$(9)$$
> 
> where  $\rho_i = \frac{\pi_{\theta}(\tau^{(i)}|d,\mathcal{S}_g,\mathcal{S}_{\text{ret}})}{\pi_{\text{old}}(\tau^{(i)}|d,\mathcal{S}_g,\mathcal{S}_{\text{ret}})}$  is the importance ratio computed over the skill-augmented context. The KL penalty anchored to  $\pi_{\text{ref}} = \pi_{\theta_{\text{sft}}}$  ensures that RL optimization preserves the learned skill utilization capabilities while improving task performance. The complete training procedure is summarized in Algorithm 1.
> 
> ## 4. Experiments
> 
> We evaluate SKILLRL on nine challenging benchmarks for LLM agents: ALFWorld, WebShop, and seven search-augmented QA tasks. Our experiments address the following questions: 1) How does SKILLRL compare to state-of-the-art methods? 2) What is the contribution of each component? 3) How does the skill library evolve during training? 4) Does skills accelerate model convergence?
> 
> #### 4.1. Experimental Setup
> 
> Environments. ALFWorld (Shridhar et al.) is a text-based game aligned with the ALFRED embodied AI benchmark. Agents must complete household tasks by navigating and interacting with objects through text commands. WebShop (Yao et al., 2022a) simulates web shopping. Agents navigate a realistic web interface to find and purchase products matching user specifications. In addition, we also evaluate the performance of SKILLRL on search-augmented QA tasks, including single-hop QA datasets (NQ (Kwiatkowski et al., 2019), TriviaQA (Joshi et al., 2017), and PopQA (Mallen et al., 2023)) and multi-hop QA datasets (HotpotQA (Yang et al., 2018), 2Wiki (Ho et al., 2020), MuSiQue (Trivedi et al., 2022), and Bamboogle (Press et al., 2023)).
> 
> Baselines. We compare SKILLRL against four categories of competitive methods. First, we include closed-source LLMs, specifically GPT-40 (OpenAI, 2024) and Gemini-2.5-Pro (Comanici et al., 2025), which represent the state-of-the-art in general-purpose reasoning and instruction following. Second, we evaluate prompt-based agentic or memory-based methods, including ReAct (Yao et al., 2022b) and Reflexion (Shinn et al., 2023), which rely on in-context prompting for multi-step reasoning, as well as Mem0 (Chhikara et al., 2025), ExpeL (Zhao et al., 2024), and MemP (Fang et al., 2025), which utilize external memory or experience pools to guide behavior without parameter updates. Third, we consider RL-based methods, including group-based online RL algorithms such as RLOO (Ahmadian et al., 2024)
> 
> and GRPO (Shao et al., 2024) that optimize policies via advantage estimation over trajectory groups. Finally, we compare against memory-augmented RL-based methods, such as EvolveR (Wu et al., 2025), MemRL (Zhang et al., 2026), and the combination of Mem0+GRPO and SimpleMem (Liu et al., 2026)+GRPO, which integrate persistent memory mechanisms directly into the reinforcement learning optimization process to handle long-term dependencies. For search-augmented QA, we compare SKILLRL with R1-Instruct, Search-01 (Li et al., 2025), Search-R1 (Jin et al., 2025), ZeroSearch (Sun et al., 2025), and StepSearch (Zheng et al., 2025).
> 
> Implementation Details. We use Qwen2.5-7B-Instruct (Bai et al., 2023) as our base model and OpenAI o3 (OpenAI, 2025a) as the teacher model for skill distillation and SFT data generation. For RL training, we use GRPO with learning rate  $1 \times 10^{-6}$ , batch size 16, group size 8, and 4 gradient accumulation steps. We set K=6 for task-specific skill retrieval and  $\delta=0.4$  for the collection of failed trajectories. For more detailed information on training hyperparameters, please see Appendix B.1.
> 
> #### 4.2. Main Results
> 
> **Comparison with Baselines.** We compare SKILLRL with baseline methods across two benchmarks as shown in Table 1. Our method consistently outperforms all baselines, with key observations as follows:
> 
> - 1) Significant Gains over Prompt-based Methods. SKILLRL achieves a 89.9% success rate on ALFWorld and 72.7% on WebShop, outperforming the best prompt-based baselines by a large margin. This gap suggests that while in-context learning can leverage past experiences, it often fails to distill actionable knowledge from verbose trajectories or fundamentally adapt the agent's policy.
> - 2) Superiority over Vanilla RL. RL training brings substantial gains, yet SKILLRL consistently surpasses standard RL baselines. Compared to PPO, RLOO, and GRPO, SKILLRL achieves the best overall performance. Notably, since SKILLRL utilizes GRPO as its base optimizer, the 12.3% absolute improvement over GRPO on ALFWorld (from 77.6% to 89.9%) is directly attributable to our skill-augmentation mechanism rather than algorithmic variance. In complex subtasks like Cool and Pick2, SKILLRL outperforms GRPO by 23.0% and 22.8% respectively, proving that structured skill priors effectively accelerate and enhance policy learning in sparse-reward environments.
> - 3) Advantage over Memory-Augmented RL. SKILLRL substantially outperforms existing memory-augmented RL frameworks, which differ in how they manage and update experience. MemRL, which uses RL solely to update its memory bank while keeping the policy frozen, fails to adapt
> 
> <span id="page-5-0"></span>*Table 1.* Performance on ALFWorld and WebShop. For ALFWorld, we report the average success rate (%) for each subtask as well as the overall result. For WebShop, we report both the average score and the average success rate (%). <sup>∗</sup> denotes the results replicated from [\(Feng et al.,](#page-8-6) [2025\)](#page-8-6). The best results and second best results are highlighted in red and blue , respectively.
> 
> |                                              |      |      |       | ALFWorld |      |       |      |       | WebShop |
> |----------------------------------------------|------|------|-------|----------|------|-------|------|-------|---------|
> | Method                                       | Pick | Look | Clean | Heat     | Cool | Pick2 | All  | Score | Succ.   |
> | Closed-source LLMs                           |      |      |       |          |      |       |      |       |         |
> | GPT-4o                                       | 75.3 | 60.8 | 31.2  | 56.7     | 21.6 | 49.8  | 48.0 | 31.8  | 23.7    |
> | Gemini-2.5-Pro                               | 92.8 | 63.3 | 62.1  | 69.0     | 26.6 | 58.7  | 60.3 | 42.5  | 35.9    |
> | Qwen2.5-7B-Instruct                          |      |      |       |          |      |       |      |       |         |
> | Qwen2.5                                      | 33.4 | 21.6 | 19.3  | 6.90     | 2.80 | 3.20  | 14.8 | 26.4  | 7.80    |
> | Prompt-based Agentic or Memory-based Methods |      |      |       |          |      |       |      |       |         |
> | ReAct∗                                       | 48.5 | 35.4 | 34.3  | 13.2     | 18.2 | 17.6  | 31.2 | 46.2  | 19.5    |
> | Reflexion∗                                   | 62.0 | 41.6 | 44.9  | 30.9     | 36.3 | 23.8  | 42.7 | 58.1  | 28.8    |
> | Mem0                                         | 54.0 | 55.0 | 26.9  | 36.4     | 20.8 | 7.69  | 33.6 | 23.9  | 2.00    |
> | ExpeL                                        | 21.0 | 67.0 | 55.0  | 52.0     | 71.0 | 6.00  | 46.3 | 30.9  | 11.2    |
> | MemP                                         | 54.3 | 38.5 | 48.1  | 56.2     | 32.0 | 16.7  | 41.4 | 25.3  | 6.40    |
> | SimpleMem                                    | 64.5 | 33.3 | 20.0  | 12.5     | 33.3 | 3.84  | 29.7 | 33.2  | 8.59    |
> | RL-based Methods                             |      |      |       |          |      |       |      |       |         |
> | RLOO∗                                        | 87.6 | 78.2 | 87.3  | 81.3     | 71.9 | 48.9  | 75.5 | 80.3  | 65.7    |
> | GRPO∗                                        | 90.8 | 66.1 | 89.3  | 74.7     | 72.5 | 64.7  | 77.6 | 79.3  | 66.1    |
> | Memory-Augmented RL-based Methods            |      |      |       |          |      |       |      |       |         |
> | MemRL                                        | 62.8 | 38.5 | 22.2  | 12.5     | 8.00 | 0.00  | 21.4 | 29.5  | 9.20    |
> | EvolveR                                      | 64.9 | 33.3 | 46.4  | 13.3     | 33.3 | 33.3  | 43.8 | 42.5  | 17.6    |
> | Mem0+GRPO                                    | 78.1 | 54.8 | 56.1  | 31.0     | 65.0 | 26.9  | 54.7 | 58.1  | 37.5    |
> | SimpleMem+GRPO                               | 89.5 | 36.3 | 60.0  | 50.0     | 64.9 | 26.3  | 62.5 | 67.8  | 46.9    |
> | SKILLRL                                      | 97.9 | 71.4 | 90.0  | 90.0     | 95.5 | 87.5  | 89.9 | 85.2  | 72.7    |
> 
> to complex environments, yielding only 21.4% on ALF-World. EvolveR, which jointly updates the policy and memory bank, shows improvement (43.8%) but remains limited by its reliance on rough trajectory storage. To provide a more competitive baseline, we implemented Mem0+GRPO, which combines a state-of-the-art prompt-based memory mechanism with an optimized policy model. While this hybrid approach improves performance to 54.7% on ALF-World and 37.5% on WebShop, it still trails SKILLRL by a wide margin (about 35.2% absolute success rate gap). These results validate our core hypothesis: effective experience transfer requires high-level skill abstraction and a co-evolving library rather than simple trajectory compression or prompt-based memory retrieval.
> 
> Comparison with Closed-Source Models. Remarkably, SKILLRL with Qwen2.5-7B-Instruct significantly outperforms much larger closed-source models, as shown in Table [1.](#page-5-0) On ALFWorld, our method exceeds GPT-4o [\(OpenAI,](#page-9-14) [2024\)](#page-9-14) by 41.9% and Gemini-2.5-Pro [\(Comanici et al.,](#page-8-2) [2025\)](#page-8-2) by 29.6%. This demonstrates that effective skill learning can compensate for model scale, enabling smaller opensource models to achieve superior task performance through structured experiential knowledge.
> 
> Performance on Search-Augmented QA. As shown in
> 
> Table [2,](#page-6-0) SKILLRL achieves a state-of-the-art average score of 47.1%, significantly outperforming Search-R1 (38.5%) abd EvolveR (43.1%). Key observations include: 1) Superior multi-hop Reasoning: SKILLRL excels in complex tasks like Bamboogle, surpassing EvolveR by 19.4%. This demonstrates that hierarchical skills effectively guide multistep information synthesis. 2) Strong generalization: Despite being trained on limited datasets (NQ, HotpotQA), SKILLRL maintains competitive performance on OOD tasks like TriviaQA and 2Wiki, confirming that distilled search strategies are task-agnostic.
> 
> #### 4.3. Analysis
> 
> In this section, we provide detailed analysis of each module's effectiveness and the skill evolution dynamics.
> 
> Ablation Studies. We conduct ablation experiments to evaluate each component's contribution, with results in Table [3.](#page-6-1) According to the results: (1) Removing hierarchical structure (i.e., task-specific skills only) decreases performance by 13.1% on ALFWorld and 11.3% on WebShop, indicating universal strategic principles provide essential foundational guidance. (2) Replacing the skill library with raw trajectories causes the largest degradation (up to 25%), which
> 
> <span id="page-6-0"></span>*Table 2.* Performance on search-augmented QA tasks. SKILLRL is trained on NQ and HotpotQA. † and \* indicate in-domain and out-of-domain datasets, respectively. \* denotes the results replicated from (Sun et al., 2025).
> 
> | Method              |                | Single-Hop (       | QA        |                       | Mult   | i-Hop QA |            | Ava  |
> |---------------------|----------------|--------------------|-----------|-----------------------|--------|----------|------------|------|
> | Method              | $NQ^{\dagger}$ | $TriviaQA^{\star}$ | $PopQA^*$ | HotpotQA <sup>†</sup> | 2Wiki* | MuSiQue* | Bamboogle* | Avg. |
> | Qwen2.5-7B-Instruct |                |                    |           |                       |        |          |            |      |
> | Qwen2.5*            | 11.6           | 35.6               | 1.20      | 16.4                  | 22.2   | 4.80     | 14.4       | 15.2 |
> | $CoT^*$             | 12.8           | 35.6               | 3.80      | 16.2                  | 22.6   | 6.60     | 24.0       | 17.4 |
> | $RAG^*$             | 27.4           | 58.2               | 17.8      | 25.8                  | 23.2   | 9.40     | 16.8       | 25.5 |
> | Search-o1*          | 19.4           | 40.6               | 11.4      | 17.0                  | 27.0   | 8.60     | 30.4       | 22.1 |
> | R1-Instruct         | 21.0           | 44.9               | 17.1      | 20.8                  | 27.5   | 6.00     | 19.2       | 22.4 |
> | Search-R1           | 39.3           | 61.0               | 39.7      | 37.0                  | 40.1   | 14.6     | 36.8       | 38.5 |
> | ZeroSearch          | 43.6           | 61.8               | 51.5      | 34.6                  | 35.2   | 18.4     | 27.8       | 39.1 |
> | StepSearch          | -              | -                  | -         | 38.6                  | 36.6   | 22.6     | 40.0       | -    |
> | EvolveR             | 43.5           | 63.4               | 44.6      | 38.2                  | 42.0   | 15.6     | 54.4       | 43.1 |
> | SKILLRL             | 45.9           | 63.3               | 45.9      | 43.2                  | 40.3   | 20.2     | 73.8       | 47.1 |
> 
> <span id="page-6-1"></span>*Table 3.* Ablation study results. We report average success rate (%) on ALFWorld and WebShop.
> 
> | Method                                                                                        | ALFWorld     | WebShop      |
> |-----------------------------------------------------------------------------------------------|--------------|--------------|
> | SKILLRL                                                                                       | 89.9         | 72.7         |
> | Skill Library Ablations<br>w/o Hierarchical Structure<br>w/o Skill Library (Raw Trajectories) | 76.8<br>61.7 | 61.4<br>50.2 |
> | Training Pipeline Ablations w/o Cold-Start SFT w/o Dynamic Evolution                          | 65.2<br>84.4 | 46.5<br>70.3 |
> 
> directly supports our motivation that abstraction is superior to memorization. Raw experiences introduce significant redundancy and noise that hinder effective knowledge transfer. (3) Cold-start SFT proves critical (20% drop without it), confirming that the base model requires an initial explicit demonstration phase to learn how to adaptively retrieve and utilize the abstracted skills before entering the RL stage. (4) Dynamic evolution contributes a 5.5% improvement by ensuring the skill library is a dynamic component rather than a static database. This co-evolution allows the agent to iteratively refine its internal policy by addressing emergent failure modes that were not covered by the initial skill set.
> 
> **Per-Task Analysis on ALFWorld.** Table 1 breaks down ALFWorld performance by task type. The largest gains are on PickTwo (+23%), Cool (+22%) and Heat (+15%), which are among the most challenging tasks requiring multi-step planning and state tracking. Task-specific skills are particularly valuable here, capturing strategies like "when picking two objects, verify the first is secured before searching for the second" that address common failure modes.
> 
> **Skill Library Growth.** Figure 3 shows how the skill library evolves during training. The initial skill library contains 55 skills (12 general, 43 task-specific). Through dynamic evolution, this grows to 100 skills by the end of training (Step 150). The growth is predominantly driven by task-specific skills (increasing from 43 to 80), while general
> 
> ![[skillrl_page_6_Figure_8.jpeg]]
> 
> <span id="page-6-2"></span>![[skillrl_page_6_Figure_9.jpeg]]
> 
> Figure 3. Evolution of skill library size during RL training. Dynamic skill evolution adds skills at validation checkpoints.
> 
> skills show a steadier increase (from 12 to 20). Notably, we observe a balanced expansion across various task categories, ensuring the agent develops specialized expertise for each environment rollout. This overall expansion reflects the agent's increasing ability to refine its repertoire and tackle diverse scenarios within specific task types.
> 
> Context Efficiency. To evaluate the impact of skill abstraction on inference overhead, we compare the average prompt length of SKILLRL with a memory-augmented baseline using raw trajectories (Qwen2.5-7B with Raw Memory) in Figure 4. The results reveal that while the raw memory approach suffers from a high and fluctuating token footprint (averaging  $\sim$ 1,450 tokens), SKILLRL maintains a significantly leaner prompt (averaging <1,300 tokens), achieving approximately a 10.3% reduction in context length. This efficiency stems from our distillation mechanism, which compresses verbose environment interactions into high-density, actionable skills. Notably, SKILLRL requires less context than the memory-based baseline to achieve superior performance, demonstrating that skill abstraction effectively mitigates the context-bloat problem common in traditional memory-based agents.
> 
> <span id="page-7-0"></span>![[skillrl_page_7_Figure_1.jpeg]]
> 
> *Figure 4.* Comparison of prompt length (tokens) between raw memory retrieval and our distilled skill abstraction. SKILLRL consistently reduces context overhead while maintaining reasoning utility.
> 
> Evolution Dynamics. Figure [5](#page-7-0) illustrates the reinforcement learning training curves with and without the recursive skill evolution mechanism. We observe that while SKILLRL without evolution shows steady improvement, SKILLRL with skill evolution exhibits a notably higher learning rate and superior asymptotic performance. Specifically, SKILLRL achieves a success rate of over 80% within 60 training steps, whereas the baseline requires approximately 90 steps to reach a lower peak. This acceleration in convergence suggests that the dynamic introduction of new skills and refinement of existing ones effectively provide the agent with timely strategic guidance to overcome local optima. Furthermore, the higher performance ceiling validates that the co-evolution of the skill library and the policy allows the agent to adapt to increasingly complex task scenarios that static memory methods fail to resolve.
> 
> Qualitative Analysis. To further investigate how SKILLRL utilizes the learned knowledge, we visualize the reasoning process on ALFWorld and WebShop in Figure [6.](#page-8-7) The case studies demonstrate that our trained agent can effectively retrieve and execute relevant skills from the SKILLBANK to guide its decision-making. For instance, in the Web-Shop task, the agent invokes general strategies like *"Prioritize Core Keywords"* alongside task-specific heuristics *"Focus Key Query"* to ensure the product meets all constraints within a limited budget. Similarly, in ALFWorld, the agent coordinates hierarchical skills, i.e., using *"Progressive Goal Decomposition"* for high-level planning and *"No Appliance Before Object"* to avoid common logical pitfalls. This seamless integration of general and specific skills confirms that the agent does not merely memorize trajectories, but rather develops a structured understanding of task logic, allowing for more robust and efficient problem-solving.
> 
> ## 5. Related Work
> 
> LLM Agents. The emergence of capable LLMs has catalyzed rapid development in autonomous agent systems [\(Wei et al.,](#page-10-12) [2026\)](#page-10-12). ReAct [\(Yao et al.,](#page-10-0) [2022b\)](#page-10-0) interleaves reasoning and acting, enabling chain-of-thought style plan-
> 
> ![[skillrl_page_7_Figure_7.jpeg]]
> 
> *Figure 5.* Success rate on ALFWorld validation set. The recursive skill evolution significantly accelerates convergence and enhances the overall performance ceiling.
> 
> ning during interaction, while Reflexion [\(Shinn et al.,](#page-9-0) [2023\)](#page-9-0) introduces verbal reinforcement through self-reflection on past failures. Frameworks like AutoGen [\(Wu et al.,](#page-10-13) [2024\)](#page-10-13) and CAMEL [\(Li et al.,](#page-9-19) [2023\)](#page-9-19) demonstrate general-purpose multi-agent capabilities, featuring automated orchestration and diverse tool integration. While initial efforts focused on constrained tasks like coding or basic arithmetic, these approaches primarily rely on in-context learning (ICL) [\(Dong](#page-8-8) [et al.,](#page-8-8) [2024\)](#page-8-8). However, these agents struggle to scale as tasks become more complex, as they treat every interaction as an isolated event and must start each new task from scratch without any prior knowledge.
> 
> Memory Mechanisms in Agents. To overcome the limitations of finite context windows and the inability of agents to learn from experience, external memory architectures have become a cornerstone of agent design [\(Hu et al.,](#page-9-20) [2025;](#page-9-20) [Wang,](#page-10-14) [2025\)](#page-10-14). Early systems primarily utilized a static RAG paradigm or stored raw trajectories as few-shot examples [\(Wang et al.;](#page-10-15) [Chhikara et al.,](#page-8-0) [2025;](#page-8-0) [Zhang et al.,](#page-10-16) [2025a;](#page-10-16) [Wang et al.,](#page-10-17) [2024\)](#page-10-17). However, raw trajectories are often token-heavy and contain significant redundancy and noise, which can lead to performance degradation. Current research has moved toward self-improving memory, distilling interactions into higher-level insights or procedural tips [\(Wang & Chen,](#page-10-18) [2025;](#page-10-18) [Tang et al.,](#page-10-19) [2025;](#page-10-19) [Fang et al.,](#page-8-3) [2025;](#page-8-3) [Zhao et al.,](#page-10-4) [2024;](#page-10-4) [Ouyang et al.,](#page-9-21) [2025;](#page-9-21) [Wei et al.,](#page-10-20) [2025\)](#page-10-20). While some recent work explores updating memory banks via online training to improve efficiency [\(Zhang et al.,](#page-10-3) [2025b;](#page-10-3) [2026\)](#page-10-5), many existing methods still struggle to distinguish high-value experiences from noise or fail to distill core principles that can guide internal decision-making.
> 
> Evolution of Agentic Skills and Reinforcement Learning. The development of agentic skills [\(Anthropic,](#page-8-1) [2024\)](#page-8-1), which are compact, reusable strategies that capture the essence of subtasks, is increasingly viewed through the lens of Continual Learning (CL) and RL. Traditional CL [\(Parisi](#page-9-22) [et al.,](#page-9-22) [2019\)](#page-9-22) focuses on knowledge preservation in predefined tasks, but self-evolving agents [\(Gao et al.,](#page-8-9) [2025;](#page-8-9) [Xia](#page-10-21) [et al.,](#page-10-21) [2025;](#page-10-21) [Liu et al.,](#page-9-23) [2025\)](#page-9-23) aim for active skill acquisition in open-ended environments [\(Fang et al.,](#page-8-3) [2025;](#page-8-3) [Wang et al.,](#page-10-22)
> 
> <span id="page-8-7"></span>![[skillrl_page_8_Figure_1.jpeg]]
> 
> Figure 6. Case studies of SKILLRL on WebShop and ALFWorld. The examples illustrate how the agent adaptively retrieves and integrates General Skills and Task-Specific Skills within its reasoning process to achieve precise and efficient task execution.
> 
> 2025). While RL is widely used to align LLMs (Schulman et al., 2017; Ouyang et al., 2022), or improve reasoning via rule-based verifiers (Shao et al., 2024), applying it to agentic skills remains challenging due to sparse rewards and long horizons. Unlike previous memory-augmented RL which treats memory as a static or auxiliary source, recent trends suggest that the key to efficient experience transfer lies in abstraction (Wu et al., 2025). Our work builds on this by treating the skill library as a dynamic component that co-evolves with the agent's policy, utilizing RL to refine structured skills through recursive failure analysis.
> 
> #### 6. Conclusion
> 
> We introduced SKILLRL, a framework for skill-augmented reinforcement learning in LLM agents. By distilling raw trajectories into compact, reusable skills and enabling dynamic skill evolution during training, SKILLRL achieves state-of-the-art performance on ALFWorld and WebShop while using substantially less context than memory-based approaches. Our work demonstrates that the abstraction from experience to skill is a powerful principle for building capable, sample-efficient agents.
> 
> #### Acknowledgement
> 
> This work was partially supported by the Amazon Research Award, the Cisco Faculty Research Award, NEC Laboratories America Research Grant, and Coefficient Giving.
> 
> #### References
> 
> <span id="page-8-4"></span>Ahmadian, A., Cremer, C., Gallé, M., Fadaee, M., Kreutzer, J., Pietquin, O., Üstün, A., and Hooker, S. Back to basics: Revisiting reinforce-style optimization for learning from human feedback in Ilms. In *Proceedings of the 62nd Annual Meeting of the Association for Computational Linguistics (Volume 1: Long Papers)*, pp. 12248–12267,
> 
> 2024.
> 
> <span id="page-8-1"></span>Anthropic. The claude 3 model family: Opus, sonnet, haiku, 2024. URL https://www.anthropic.com/news/claude-3-family.
> 
> <span id="page-8-5"></span>Bai, J., Bai, S., Chu, Y., Cui, Z., Dang, K., Deng, X., Fan, Y., Ge, W., Han, Y., Huang, F., et al. Qwen technical report. *arXiv preprint arXiv:2309.16609*, 2023.
> 
> <span id="page-8-0"></span>Chhikara, P., Khant, D., Aryan, S., Singh, T., and Yadav, D. Mem0: Building production-ready ai agents with scalable long-term memory. *arXiv preprint arXiv:2504.19413*, 2025.
> 
> <span id="page-8-2"></span>Comanici, G., Bieber, E., Schaekermann, M., Pasupat, I., Sachdeva, N., Dhillon, I., Blistein, M., Ram, O., Zhang, D., Rosen, E., et al. Gemini 2.5: Pushing the frontier with advanced reasoning, multimodality, long context, and next generation agentic capabilities. arXiv preprint arXiv:2507.06261, 2025.
> 
> <span id="page-8-8"></span>Dong, Q., Li, L., Dai, D., Zheng, C., Ma, J., Li, R., Xia, H., Xu, J., Wu, Z., Chang, B., et al. A survey on incontext learning. In *Proceedings of the 2024 conference* on empirical methods in natural language processing, pp. 1107–1128, 2024.
> 
> <span id="page-8-3"></span>Fang, R., Liang, Y., Wang, X., Wu, J., Qiao, S., Xie, P., Huang, F., Chen, H., and Zhang, N. Memp: Exploring agent procedural memory. *arXiv* preprint *arXiv*:2508.06433, 2025.
> 
> <span id="page-8-6"></span>Feng, L., Xue, Z., Liu, T., and An, B. Group-in-group policy optimization for llm agent training. *arXiv* preprint *arXiv*:2505.10978, 2025.
> 
> <span id="page-8-9"></span>Gao, H.-a., Geng, J., Hua, W., Hu, M., Juan, X., Liu, H., Liu, S., Qiu, J., Qi, X., Wu, Y., et al. A survey of self-evolving agents: On path to artificial super intelligence. *arXiv* preprint arXiv:2507.21046, 2025.
> 
> - <span id="page-9-4"></span>Google. Try deep research and our new experimental model in gemini, your ai assistant, 2024. URL [https://blog.google/products/](https://blog.google/products/gemini/google-gemini-deep-research/) [gemini/google-gemini-deep-research/](https://blog.google/products/gemini/google-gemini-deep-research/).
> - <span id="page-9-1"></span>Google. Introducing the gemini 2.5 computer use model, 2025. URL [https://blog.](https://blog.google/technology/google-deepmind/gemini-computer-use-model/) [google/technology/google-deepmind/](https://blog.google/technology/google-deepmind/gemini-computer-use-model/) [gemini-computer-use-model/](https://blog.google/technology/google-deepmind/gemini-computer-use-model/).
> - <span id="page-9-7"></span>Guo, D., Yang, D., Zhang, H., Song, J., Zhang, R., Xu, R., Zhu, Q., Ma, S., Wang, P., Bi, X., et al. Deepseek-r1: Incentivizing reasoning capability in llms via reinforcement learning. *arXiv preprint arXiv:2501.12948*, 2025.
> - <span id="page-9-12"></span>Ho, X., Nguyen, A.-K. D., Sugawara, S., and Aizawa, A. Constructing a multi-hop qa dataset for comprehensive evaluation of reasoning steps. In *Proceedings of the 28th International Conference on Computational Linguistics*, pp. 6609–6625, 2020.
> - <span id="page-9-20"></span>Hu, Y., Liu, S., Yue, Y., Zhang, G., Liu, B., Zhu, F., Lin, J., Guo, H., Dou, S., Xi, Z., et al. Memory in the age of ai agents. *arXiv preprint arXiv:2512.13564*, 2025.
> - <span id="page-9-17"></span>Jin, B., Zeng, H., Yue, Z., Yoon, J., Arik, S., Wang, D., Zamani, H., and Han, J. Search-r1: Training llms to reason and leverage search engines with reinforcement learning. *arXiv preprint arXiv:2503.09516*, 2025.
> - <span id="page-9-10"></span>Joshi, M., Choi, E., Weld, D. S., and Zettlemoyer, L. Triviaqa: A large scale distantly supervised challenge dataset for reading comprehension. In *Proceedings of the 55th Annual Meeting of the Association for Computational Linguistics (Volume 1: Long Papers)*, pp. 1601–1611, 2017.
> - <span id="page-9-9"></span>Kwiatkowski, T., Palomaki, J., Redfield, O., Collins, M., Parikh, A., Alberti, C., Epstein, D., Polosukhin, I., Devlin, J., Lee, K., et al. Natural questions: a benchmark for question answering research. *Transactions of the Association for Computational Linguistics*, 7:453–466, 2019.
> - <span id="page-9-19"></span>Li, G., Hammoud, H., Itani, H., Khizbullin, D., and Ghanem, B. Camel: Communicative agents for" mind" exploration of large language model society. *Advances in Neural Information Processing Systems*, 36:51991–52008, 2023.
> - <span id="page-9-16"></span>Li, X., Dong, G., Jin, J., Zhang, Y., Zhou, Y., Zhu, Y., Zhang, P., and Dou, Z. Search-o1: Agentic search-enhanced large reasoning models. *arXiv preprint arXiv:2501.05366*, 2025.
> - <span id="page-9-23"></span>Liu, J., Xiong, K., Xia, P., Zhou, Y., Ji, H., Feng, L., Han, S., Ding, M., and Yao, H. Agent0-vl: Exploring selfevolving agent for tool-integrated vision-language reasoning. *arXiv preprint arXiv:2511.19900*, 2025.
> 
> - <span id="page-9-15"></span>Liu, J., Su, Y., Xia, P., Han, S., Zheng, Z., Xie, C., Ding, M., and Yao, H. Simplemem: Efficient lifelong memory for llm agents. *arXiv preprint arXiv:2601.02553*, 2026.
> - <span id="page-9-11"></span>Mallen, A., Asai, A., Zhong, V., Das, R., Khashabi, D., and Hajishirzi, H. When not to trust language models: Investigating effectiveness of parametric and non-parametric memories. In *Proceedings of the 61st Annual Meeting of the Association for Computational Linguistics (Volume 1: Long Papers)*, pp. 9802–9822, 2023.
> - <span id="page-9-14"></span>OpenAI. Gpt-4o system card, 2024. [https://openai.](https://openai.com/index/gpt-4o-system-card/) [com/index/gpt-4o-system-card/](https://openai.com/index/gpt-4o-system-card/).
> - <span id="page-9-18"></span>OpenAI. Introducing o3 and o4-mini, 2025a. [https://openai.com/index/](https://openai.com/index/introducing-o3-and-o4-mini/) [introducing-o3-and-o4-mini/](https://openai.com/index/introducing-o3-and-o4-mini/).
> - <span id="page-9-3"></span>OpenAI. Openai deep research system card, 2025b. URL [https://openai.com/index/](https://openai.com/index/introducing-deep-research/) [introducing-deep-research/](https://openai.com/index/introducing-deep-research/).
> - <span id="page-9-2"></span>OpenAI. Openai computer-using agent, 2025c. URL [https://openai.com/index/](https://openai.com/index/computer-using-agent/) [computer-using-agent/](https://openai.com/index/computer-using-agent/).
> - <span id="page-9-8"></span>Ouyang, L., Wu, J., Jiang, X., Almeida, D., Wainwright, C., Mishkin, P., Zhang, C., Agarwal, S., Slama, K., Ray, A., et al. Training language models to follow instructions with human feedback. *Advances in neural information processing systems*, 35:27730–27744, 2022.
> - <span id="page-9-21"></span>Ouyang, S., Yan, J., Hsu, I., Chen, Y., Jiang, K., Wang, Z., Han, R., Le, L. T., Daruki, S., Tang, X., et al. Reasoningbank: Scaling agent self-evolving with reasoning memory. *arXiv preprint arXiv:2509.25140*, 2025.
> - <span id="page-9-22"></span>Parisi, G. I., Kemker, R., Part, J. L., Kanan, C., and Wermter, S. Continual lifelong learning with neural networks: A review. *Neural networks*, 113:54–71, 2019.
> - <span id="page-9-13"></span>Press, O., Zhang, M., Min, S., Schmidt, L., Smith, N. A., and Lewis, M. Measuring and narrowing the compositionality gap in language models. In *Findings of the Association for Computational Linguistics: EMNLP 2023*, pp. 5687–5711, 2023.
> - <span id="page-9-6"></span>Schulman, J., Wolski, F., Dhariwal, P., Radford, A., and Klimov, O. Proximal policy optimization algorithms. *arXiv preprint arXiv:1707.06347*, 2017.
> - <span id="page-9-5"></span>Shao, Z., Wang, P., Zhu, Q., Xu, R., Song, J., Bi, X., Zhang, H., Zhang, M., Li, Y., Wu, Y., et al. Deepseekmath: Pushing the limits of mathematical reasoning in open language models. *arXiv preprint arXiv:2402.03300*, 2024.
> - <span id="page-9-0"></span>Shinn, N., Cassano, F., Gopinath, A., Narasimhan, K., and Yao, S. Reflexion: Language agents with verbal reinforcement learning. *Advances in Neural Information Processing Systems*, 36:8634–8652, 2023.
> 
> - <span id="page-10-2"></span>Shridhar, M., Yuan, X., Cote, M.-A., Bisk, Y., Trischler, A., and Hausknecht, M. Alfworld: Aligning text and embodied environments for interactive learning. In *International Conference on Learning Representations*.
> - <span id="page-10-10"></span>Sun, H., Qiao, Z., Guo, J., Fan, X., Hou, Y., Jiang, Y., Xie, P., Zhang, Y., Huang, F., and Zhou, J. Zerosearch: Incentivize the search capability of llms without searching. *arXiv preprint arXiv:2505.04588*, 2025.
> - <span id="page-10-19"></span>Tang, X., Qin, T., Peng, T., Zhou, Z., Shao, D., Du, T., Wei, X., Xia, P., Wu, F., Zhu, H., et al. Agent kb: Leveraging cross-domain experience for agentic problem solving. *arXiv preprint arXiv:2507.06229*, 2025.
> - <span id="page-10-1"></span>Team, T. D., Li, B., Zhang, B., Zhang, D., Huang, F., Li, G., Chen, G., Yin, H., Wu, J., Zhou, J., et al. Tongyi deepresearch technical report. *arXiv preprint arXiv:2510.24701*, 2025.
> - <span id="page-10-8"></span>Trivedi, H., Balasubramanian, N., Khot, T., and Sabharwal, A. Musique: Multihop questions via single-hop question composition. *Transactions of the Association for Computational Linguistics*, 10:539–554, 2022.
> - <span id="page-10-15"></span>Wang, G., Xie, Y., Jiang, Y., Mandlekar, A., Xiao, C., Zhu, Y., Fan, L., and Anandkumar, A. Voyager: An open-ended embodied agent with large language models. *Transactions on Machine Learning Research*.
> - <span id="page-10-14"></span>Wang, Y. *From Static Parameters to Updatable Memory: Enabling Large Language Model Agents to Remember, Adapt, and Learn*. PhD thesis, University of California, San Diego, 2025.
> - <span id="page-10-18"></span>Wang, Y. and Chen, X. Mirix: Multi-agent memory system for llm-based agents. *arXiv preprint arXiv:2507.07957*, 2025.
> - <span id="page-10-22"></span>Wang, Y., Takanobu, R., Liang, Z., Mao, Y., Hu, Y., McAuley, J., and Wu, X. Mem-{\alpha}: Learning memory construction via reinforcement learning. *arXiv preprint arXiv:2509.25911*, 2025.
> - <span id="page-10-17"></span>Wang, Z. Z., Mao, J., Fried, D., and Neubig, G. Agent workflow memory. *arXiv preprint arXiv:2409.07429*, 2024.
> - <span id="page-10-20"></span>Wei, T., Sachdeva, N., Coleman, B., He, Z., Bei, Y., Ning, X., Ai, M., Li, Y., He, J., Chi, E. H., et al. Evo-memory: Benchmarking llm agent test-time learning with selfevolving memory. *arXiv preprint arXiv:2511.20857*, 2025.
> - <span id="page-10-12"></span>Wei, T., Li, T.-W., Liu, Z., Ning, X., Yang, Z., Zou, J., Zeng, Z., Qiu, R., Lin, X., Fu, D., et al. Agentic reasoning for large language models. *arXiv preprint arXiv:2601.12538*, 2026.
> 
> - <span id="page-10-13"></span>Wu, Q., Bansal, G., Zhang, J., Wu, Y., Li, B., Zhu, E., Jiang, L., Zhang, X., Zhang, S., Liu, J., et al. Autogen: Enabling next-gen llm applications via multi-agent conversations. In *First Conference on Language Modeling*, 2024.
> - <span id="page-10-9"></span>Wu, R., Wang, X., Mei, J., Cai, P., Fu, D., Yang, C., Wen, L., Yang, X., Shen, Y., Wang, Y., et al. Evolver: Self-evolving llm agents through an experience-driven lifecycle. *arXiv preprint arXiv:2510.16079*, 2025.
> - <span id="page-10-21"></span>Xia, P., Zeng, K., Liu, J., Qin, C., Wu, F., Zhou, Y., Xiong, C., and Yao, H. Agent0: Unleashing self-evolving agents from zero data via tool-integrated reasoning. *arXiv preprint arXiv:2511.16043*, 2025.
> - <span id="page-10-7"></span>Yang, Z., Qi, P., Zhang, S., Bengio, Y., Cohen, W., Salakhutdinov, R., and Manning, C. D. Hotpotqa: A dataset for diverse, explainable multi-hop question answering. In *Proceedings of the 2018 conference on empirical methods in natural language processing*, pp. 2369–2380, 2018.
> - <span id="page-10-6"></span>Yao, S., Chen, H., Yang, J., and Narasimhan, K. Webshop: Towards scalable real-world web interaction with grounded language agents. *Advances in Neural Information Processing Systems*, 35:20744–20757, 2022a.
> - <span id="page-10-0"></span>Yao, S., Zhao, J., Yu, D., Du, N., Shafran, I., Narasimhan, K. R., and Cao, Y. React: Synergizing reasoning and acting in language models. In *The eleventh international conference on learning representations*, 2022b.
> - <span id="page-10-16"></span>Zhang, G., Fu, M., Wan, G., Yu, M., Wang, K., and Yan, S. G-memory: Tracing hierarchical memory for multi-agent systems. *arXiv preprint arXiv:2506.07398*, 2025a.
> - <span id="page-10-3"></span>Zhang, G., Ren, H., Zhan, C., Zhou, Z., Wang, J., Zhu, H., Zhou, W., and Yan, S. Memevolve: Meta-evolution of agent memory systems. *arXiv preprint arXiv:2512.18746*, 2025b.
> - <span id="page-10-5"></span>Zhang, S., Wang, J., Zhou, R., Liao, J., Feng, Y., Zhang, W., Wen, Y., Li, Z., Xiong, F., Qi, Y., et al. Memrl: Self-evolving agents via runtime reinforcement learning on episodic memory. *arXiv preprint arXiv:2601.03192*, 2026.
> - <span id="page-10-4"></span>Zhao, A., Huang, D., Xu, Q., Lin, M., Liu, Y.-J., and Huang, G. Expel: Llm agents are experiential learners. In *Proceedings of the AAAI Conference on Artificial Intelligence*, volume 38, pp. 19632–19642, 2024.
> - <span id="page-10-11"></span>Zheng, X., An, K., Wang, Z., Wang, Y., and Wu, Y. Stepsearch: Igniting llms search ability via step-wise proximal policy optimization. In *Proceedings of the 2025 Conference on Empirical Methods in Natural Language Processing*, pp. 21816–21841, 2025.
> 
> ## Appendix
> 
> ## A. Prompts
> 
> In this section, we provide the full prompt templates used throughout the different phases of our framework. These templates are designed to ensure consistent agent behavior and structured data generation across various environments.
> 
> ## A.1. Agent Execution Prompts
> 
> The following prompts are used during the online inference phase. These templates provide the agent with the current task description, a history of previous interactions, and a set of retrieved skills (experiences) to guide its decision-making process. The prompts explicitly enforce a Chain-of-Thought (CoT) reasoning step before action selection.
> 
> #### Prompt A.1: ALFWorld Agent Execution with Skills
> 
> #### System Prompt:
> 
> You are an expert agent operating in the ALFRED Embodied Environment. Your task is to: {task description}
> 
> #### ## Retrieved Relevant Experience
> 
> {retrieved memories}
> 
> #### ## Current Progress
> 
> Prior to this step, you have already taken {step count} step(s). Below are the most recent {history length} observations and the corresponding actions you took: {action history}
> 
> You are now at step {current step} and your current observation is: {current observation}
> 
> Your admissible actions of the current situation are: [{admissible actions}].
> 
> Now it's your turn to take an action. You should first reason step-by-step about the current situation. This reasoning process MUST be enclosed within <think> </think> tags. Once you've finished your reasoning, you should choose an admissible action for current step and present it within <action> </action> tags.
> 
> #### Prompt A.2: WebShop Agent Execution with Skills
> 
> #### System Prompt:
> 
> You are an expert autonomous agent operating in the WebShop e-commerce environment. Your task is to: {task description}.
> 
> #### ## Retrieved Relevant Experience
> 
> {retrieved memories}
> 
> #### ## Current Progress
> 
> Prior to this step, you have already taken {step count} step(s). Below are the most recent {history length} observations and the corresponding actions you took: {action history}
> 
> You are now at step {current step} and your current observation is: {current observation}
> 
> Your admissible actions of the current situation are: [ {available actions} ].
> 
> Now it's your turn to take one action for the current step. You should first reason step-by-step about the current situation, then think carefully which admissible action best advances the shopping goal. This reasoning process MUST be enclosed within <think> </think> tags. Once you've finished your reasoning, you should choose an admissible action for current step and present it within <action> </action> tags.
> 
> ### A.2. Skill Generation and Distillation Prompts
> 
> These prompts are utilized during the skill discovery and library initialization phases. They guide a high-capability teacher model to analyze interaction trajectories, identify failure modes, and distill reusable, actionable skills into a structured JSON format.
> 
> #### Prompt B.1: Dynamic Skill Discovery from Failures
> 
> Analyze these failed {env description} agent trajectories and suggest NEW skills to add.
> 
> FAILED TRAJECTORIES: {failure examples} EXISTING SKILL TITLES: {existing titles}
> 
> Generate 1-3 NEW actionable skills that would help avoid these failures. Each skill must have: skill id, title (3-5 words), principle (1-2 sentences), when to apply. The skill id should be unique and follow the pattern: "dyn 001", "dyn 002", etc.
> 
> Return ONLY a JSON array of skills, no other text.
> 
> #### Prompt B.2: Initial Skill Distillation (ALFWorld)
> 
> You are an expert at distilling agent behavior patterns into concise, actionable skills. Analyze these successful and failed trajectories from an embodied AI agent operating in household environments (ALFWorld).
> 
> SUCCESSFUL TRAJECTORIES: {success patterns} FAILED TRAJECTORIES: {failure patterns}
> 
> Generate 8-12 GENERAL SKILLS that apply across ALL task types. These should be: 1. Concise; 2. Actionable; 3. Transferable; 4. Failure-aware. Focus on: Navigation, object manipulation, state tracking, error recovery, and container interaction rules.
> 
> Return ONLY the JSON array, no other text.
> 
> #### Prompt B.3: Initial Skill Distillation (WebShop)
> 
> You are an expert at distilling agent behavior patterns into concise, actionable skills. Analyze these successful and failed trajectories from an AI agent operating in an online shopping environment (WebShop).
> 
> SUCCESSFUL TRAJECTORIES: {success patterns} FAILED TRAJECTORIES: {failure patterns}
> 
> Generate 10-15 GENERAL SKILLS. Focus on: Search query formulation, product selection heuristics, option configuration (size, color, etc.), constraint verification, navigation patterns, and price handling.
> 
> Return ONLY the JSON array, no other text.
> 
> ## A.3. Cold-start Trajectory Generation Prompts
> 
> To bridge the gap between a base model and the target performance, we use the following prompts to generate high-quality synthetic trajectories for Supervised Fine-Tuning (SFT). These prompts instruct the teacher model to solve tasks while explicitly demonstrating the application of specific skills, thereby providing a clear learning signal for the student model.
> 
> #### Prompt C.1: Synthetic Trajectory Generation (ALFWorld)
> 
> You are an expert agent in the ALFRED embodied environment. You will be given a task and relevant skills to apply. Your goal is to generate a successful trajectory that demonstrates proper use of these skills.
> 
> You should generate a step-by-step trajectory that:
> 
> - 1. Uses the provided skills appropriately;
> - 2. Takes realistic actions in the environment;
> - 3. Completes the task successfully;
> - 4. Demonstrates good planning and systematic exploration.
> 
> For each step, you should:
> 
> - Think through the current situation using <think></think> tags.
> - Choose an appropriate action using <action></action> tags.
> - The action should be a simple command like "go to cabinet 1", "open drawer 2", "take apple 1", "put apple 1 in/on countertop 1".
> 
> Generate a complete trajectory from start to finish. Stop when the task is complete.
> 
> #### Prompt C.2: Synthetic Trajectory Generation (WebShop)
> 
> You are an expert shopping agent in the WebShop e-commerce environment. You will be given a shopping task and relevant skills to apply. Your goal is to generate a successful trajectory that demonstrates proper use of these skills.
> 
> You should generate a step-by-step trajectory that:
> 
> - 1. Uses the provided skills appropriately;
> - 2. Takes realistic actions in the WebShop environment;
> - 3. Successfully finds and purchases the requested product;
> - 4. Demonstrates good search strategies and product evaluation.
> 
> #### For each step, you should:
> 
> - Think through the current situation using <think></think> tags.
> - Choose an appropriate action using <action></action> tags.
> - Actions can be: search[query], click[element], or buy now.
> 
> Generate a complete trajectory from start to finish. Stop when the purchase is complete.
> 
> ## B. Additional Experimental Details
> 
> #### <span id="page-13-0"></span>B.1. Hyperparameters
> 
> *Table 4.* Hyperparameters for SKILLRL.
> 
> | Hyperparameter               | Value                              |
> |------------------------------|------------------------------------|
> | Cold-Start SFT               |                                    |
> | Learning rate                | 1 × 10−4                           |
> | Batch size                   | 16                                 |
> | Epochs                       | 3                                  |
> | SFT examples                 | 7,500 (AlfWorld) / 2,400 (WebShop) |
> | RL Training                  |                                    |
> | Learning rate                | 1 × 10−6                           |
> | Batch size                   | 64                                 |
> | KL loss Coef                 | 0.01                               |
> | Invalid Action Penalty Coef  | 0.1                                |
> | Max Prompt Length            | 6,000                              |
> | Max Response Length          | 1,024                              |
> | Epoch                        | 150                                |
> | Skill Retrieval              |                                    |
> | Top-K retrieval              | 6                                  |
> | Validation interval          | 5 Steps                            |
> | Update Threshold δ           | 0.4                                |
> | Max failures analyzed        | 10 (SR < 0.4) / 5 (SR > 0.4)       |
> | Max new skills per evolution | 3                                  |
> 
> ## B.2. Compute Resources
> 
> All experiments were conducted on a cluster with 8 NVIDIA H100 80GB GPUs. Training times:
> 
> • Trajectory collection: 3 hours
> 
> • Skill distillation: 0.5 hours
> 
> • Cold-start SFT: 2 hour
> 
> • RL training: 24 hours
> 
> <span id="page-14-0"></span>*Table 5.* Example distilled skills from SKILLBANK for ALFWorld [\(Shridhar et al.\)](#page-10-2). This table summarizes general patterns and application logic derived from raw trajectories.
> 
> | ID      | Skill Title                              | Principle (Actionable Pattern)                                                                                  | When to Apply                                                                   |
> |---------|------------------------------------------|-----------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------|
> |         | General Exploration & Acquisition Skills |                                                                                                                 |                                                                                 |
> | gen 001 | Systematic Exploration                   | Search every plausible surface or container exactly once before<br>revisiting; prioritize unseen locations.     | Anytime the goal count is not<br>met and unexplored areas re<br>main.           |
> | gen 002 | Immediate Acquisition                    | As soon as a required object becomes visible and reachable,<br>take it immediately.                             | Upon first visual confirmation<br>of a goal-relevant object.                    |
> | gen 003 | Destination First Policy                 | After picking up a goal object, navigate directly to the known<br>target receptacle and place it.               | Holding any goal object while<br>target location is identified.                 |
> |         | State-Changing & Spatial Relation Skills |                                                                                                                 |                                                                                 |
> | gen 005 | Use<br>State-Changing<br>Tools Early     | Acquire the object, then immediately use the nearest suitable<br>appliance (heat/cool/clean) before placement.  | After picking up an object re<br>quiring temperature or cleanli<br>ness change. |
> | gen 006 | Establish Spatial Rela<br>tions          | First locate the reference object, adjust its state if needed, then<br>search or place in the specified region. | Tasks containing prepositions<br>like "under", "inside", or "on".               |
> |         | Reliability & Error Recovery             |                                                                                                                 |                                                                                 |
> | gen 014 | Loop Escape Trigger                      | If the last 3–5 actions do not change the state, switch to an<br>untried search branch or action type.          | After several consecutive no<br>progress observations.                          |
> | gen 015 | Pre-Action<br>Sanity<br>Check            | Confirm prerequisites (hand free, capacity, power) before exe<br>cuting manipulative commands.                  | Right before issuing any com<br>mand that could legally fail.                   |
> 
> *Table 6.* Common Agent Failures and Mitigation Strategies for ALFWorld.
> 
> <span id="page-14-1"></span>
> 
> | ID      | Failure Description    | Root Cause (Why it happens)                                                                                               | Mitigation (How to avoid)                                                                     |
> |---------|------------------------|---------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------|
> | err 001 | Redundant Revisit      | Lacks explicit memory of explored areas; strat                                                                            | Maintain an exploration map; prioritize unvis                                                 |
> | err 006 | Skipping State Changes | egy degenerates into local loops.<br>Conflates object presence with goal satisfac<br>tion; omits cleanliness/temp checks. | ited candidates.<br>Integrate state precondition checks into the<br>planner before placement. |
> 
> Total wall-clock time: approximately 30 hours per experiment.
> 
> ## C. Illustration of Skill Library
> 
> In this section, we provide some example catalog of distilled skills and error taxonomies for both the ALFWorld and WebShop environments. Tables [5](#page-14-0) and [7](#page-15-0) detail the general skills distilled for embodied manipulation and web-based shopping, respectively, highlighting the actionable principles required for systematic exploration and constraint satisfaction. Furthermore, we provide a structured analysis of failure cases in Table [6](#page-14-1) and Table [8,](#page-15-1) which categorizes common mistakes, ranging from spatial reasoning loops in ALFWorld to price-shift oversights in WebShop, alongside their root causes and proposed mitigation strategies.
> 
> #### SKILLRL: Evolving Agents via Recursive Skill-Augmented Reinforcement Learning
> 
> <span id="page-15-0"></span>*Table 7.* Example distilled skills for WebShop Navigation [\(Yao et al.,](#page-10-6) [2022a\)](#page-10-6). These skills represent the strategic patterns used by the agent to handle large-scale product search and constraint satisfaction.
> 
> | ID                 | Skill Title                                      | Principle (Actionable Pattern)                                                                                                                                                                 | When to Apply                                                                                                                                 |
> |--------------------|--------------------------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------|
> |                    | Search & Query Engineering                       |                                                                                                                                                                                                |                                                                                                                                               |
> | gen 001<br>gen 002 | Prioritize Core Keywords<br>Iterative Refinement | Include product type, 1-2 functional attributes, and hard<br>constraints; omit secondary descriptors.<br>Adjust keywords or apply site filters instead of repeat<br>ing the same failed query. | Before issuing the first search or re<br>fining over-specific queries.<br>When results are irrelevant or repeat<br>despite multiple searches. |
> |                    | Product Evaluation & Verification                |                                                                                                                                                                                                |                                                                                                                                               |
> | gen 003            | Scan Before You Click                            | Read titles, thumbnails, and prices in results to ensure<br>plausibility before opening a link.                                                                                                | On search results pages when choos<br>ing the next product to inspect.                                                                        |
> | gen 004            | Verify Early, Abort Fast                         | Immediately check category, attributes, and price on<br>the product page; leave if any constraint is violated.                                                                                 | Within the first observation on every<br>product detail page.                                                                                 |
> | gen 006            | Confirm Hidden Attributes                        | Open Description/Features sections to ensure non<br>visible specs (e.g., material) meet constraints.                                                                                           | When constraints are not evident<br>from the title or variant list.                                                                           |
> |                    | Configuration & Transaction                      |                                                                                                                                                                                                |                                                                                                                                               |
> | gen 005            | Set Mandatory Variants                           | Always select required options (size, color, etc.) before<br>evaluating price or purchasing.                                                                                                   | After confirming product match but<br>before any purchase action.                                                                             |
> | gen 007            | Check Variant Pricing                            | For price ranges, select the exact variant combination<br>to verify the specific price is within budget.                                                                                       | Whenever price changes with vari<br>ant selection or shows as a range.                                                                        |
> | gen 013            | Purchase Decisively                              | Execute 'Buy Now' immediately once all constraints<br>and prices are confirmed on a variant.                                                                                                   | After validating every constraint on<br>the current product variant.                                                                          |
> 
> *Table 8.* Common Failures in Web-based Shopping Tasks.
> 
> <span id="page-15-1"></span>
> 
> | ID      | Failure Description                   | Root Cause                                                                                | Mitigation Strategy                                                                                            |
> |---------|---------------------------------------|-------------------------------------------------------------------------------------------|----------------------------------------------------------------------------------------------------------------|
> | err 001 | Missing<br>Constraints<br>in<br>Query | Omits size or price caps, leading to over<br>whelming or irrelevant result sets.          | Assemble full requirement list first; ensure<br>every hard constraint is in the query string.                  |
> | err 004 | Price Shift Oversight                 | Fails to notice price changes after selecting a<br>specific size or color variant.        | Re-read the price element after every option<br>change before proceeding to checkout.                          |
> | err 005 | Premature Purchase                    | Clicks "Buy Now" without setting mandatory<br>variants, leading to errors or wrong items. | Validate that every required dropdown/radio<br>option is explicitly selected before buying.                    |
> | err 009 | Ignoring Stock Status                 | Attempts to purchase out-of-stock items by<br>ignoring disabled buttons or stock labels.  | Verify that the 'Add to Cart' button is enabled<br>and no 'Out of Stock' message is present post<br>selection. |
> | err 011 | Sponsored Link Distraction            | Clicks loosely matched ads, diverting the<br>workflow from organic, suitable products.    | Implement ad-label detection; prioritize or<br>ganic listings for higher constraint reliability.               |
> 
> ## D. Additional Cases
> 
> | Task: I want a pair of men's black slip-resistant work shoes, size 10, rubber sole, price lower than \$50.00. |                                                                                                                                                                                                                           |  |
> |---------------------------------------------------------------------------------------------------------------|---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--|
> | Skills<br>Avoid                                                                                               | [foo 002] Verify features in description; [foo 004] Confirm price after variant selection.<br>[err 001] Omitting price cap; [err 003] Selecting wrong product category.                                                   |  |
> |                                                                                                               | Agent Trajectory with Skill-Guided Reasoning                                                                                                                                                                              |  |
> | Step 1                                                                                                        | Obs: WebShop homepage.<br>Think: Per [gen 001], I'll include key constraints (type, function, color, price) in the query.<br>Action: search[men black slip resistant work shoes rubber sole under 50]                     |  |
> | Step 2                                                                                                        | Obs: Results: [1] Chef Shoes \$38.99; [2] Kitchen Shoes \$42.50; [3] Steel Toe Boots \$55.99.<br>Think: [gen 003] Item [1] is under budget and matches function. Item [3] is over budget (skip).<br>Action: click[Item 1] |  |
> | Step 3                                                                                                        | Obs: Product page. Price: \$35.99-\$45.99. Colors: Black, White. Sizes: 7-12.<br>Think: [foo 002] Description confirms rubber sole. Now selecting Black and Size 10 [foo 003].<br>Action: click[Black] → click[10]        |  |
> | Step 5                                                                                                        | Obs: Selected: Black, Size 10. Price updated to \$38.99.<br>Think: [foo 004] \$38.99 ¡ \$50. All constraints (color, size, function, price) are satisfied.<br>Action: click[Buy Now]                                      |  |
> 
> | Task: I need a portable bluetooth speaker, waterproof, black color, price lower than \$30.00. |                                                                                                                                                                                                                                               |  |  |  |
> |-----------------------------------------------------------------------------------------------|-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--|--|--|
> | Skills<br>Avoid                                                                               | [ele 001] Constraint-rich search; [ele 004] Bail on mismatch fast; [gen 002] Iterative refinement.<br>[err 002] Overly specific variant names in search; [ele 006] Avoid click loops.                                                         |  |  |  |
> |                                                                                               | Agent Trajectory: Handling Missing Constraints                                                                                                                                                                                                |  |  |  |
> | Step 1                                                                                        | Obs: WebShop homepage.<br>Think: [ele 001] Packing all mandatory attributes: portable, bluetooth, waterproof, black, ¡\$30.<br>Action: search[portable bluetooth speaker waterproof black under 30]                                           |  |  |  |
> | Step 2                                                                                        | Obs: Results: [1] Waterproof Speaker \$28.99; [2] Mini LED Speaker \$19.99; [3] 20W Speaker \$35.50.<br>Think: [ele 005] Item [1] matches most keywords and price.<br>Action: click[Item 1]                                                   |  |  |  |
> | Step 3                                                                                        | Obs: Product page (Item 1). Colors: Blue, Red, Green, Army Green. Black unavailable.<br>Think: [gen 004] Verify Early, Abort Fast: No black option! [ele 004] Bail immediately to find another<br>candidate.<br>Action: click[Back to Search] |  |  |  |
> | Step 4                                                                                        | Obs: Back on search results.<br>Think: [gen 002] Iterative refinement. Item [2] \$19.99 is the next best candidate.<br>Action: click[Item 2]                                                                                                  |  |  |  |
> | Step 5                                                                                        | Obs: Product page (Item 2). Colors: Black, Blue, Red. Specs: IPX5 Waterproof.<br>Think: [ele 002] Black is available! IPX5 confirms waterproof. Selecting Black.<br>Action: click[Black]                                                      |  |  |  |
> | Step 6                                                                                        | Obs: Black selected. Final price: \$19.99.<br>Think: [ele 003] \$19.99 ¡ \$30. All specs (black, portable, waterproof) verified.<br>Action: click[Buy Now]                                                                                    |  |  |  |
> 
> ## **Case 1: ALFWorld Clean Task (Lettuce** → **Sink** → **Countertop)** Task: Clean some lettuce and put it in countertop. Core Skills [cle 001] Phase-ordered plan (Locate → Clean → Place); [cle 006] Use location priors (Fridge for food). Mistakes Avoided [err 002] Skipping closed containers; [err 003] Ignoring visible target objects. Step 1-3 Obs: Fridge 1 is closed. Action: open fridge 1 → take lettuce 1 Reasoning: Per [cle 006], food is likely in the fridge. [gen 002] Grab lettuce immediately on sight. Step 4-6 Obs: Arrive at sinkbasin 1. Action: clean lettuce 1 with sinkbasin 1 Reasoning: Per [cle 001] Phase 2: bring to water source. [cle 003] Go straight to sink. Step 7 Obs: Arrive at countertop 1. Action: put lettuce 1 in/on countertop 1 Reasoning: Per [gen 003] Destination First: place cleaned object immediately to finish.
> 
> Result: SUCCESS (7 Steps) — Skills used: [gen 010] (Decomposition), [cle 003] (Sink First).
> 
> |             | Task: Heat some egg and put it in countertop.                                                                                                                                    |  |  |
> |-------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|--|--|
> | Core Skills | [hea 001] Secure exact target first; [hea 003] Open-Place-Heat sequence; [hea 004] No appliance before object.                                                                   |  |  |
> | Step 1-3    | Obs: Countertop 1 (no egg) → Countertop 2 (egg found). Action: take egg 1<br>Reasoning: [hea 004] Avoid microwave until object is held. [hea 002] Systematic search of surfaces. |  |  |
> | Step 4-6    | Obs: Microwave 1 is closed. Action: open microwave 1 → heat egg 1<br>Reasoning: [hea 003] Correct sequence: open door first, then initiate state change.                         |  |  |
> | Step 7-8    | Obs: Egg is heated. Action: go to countertop 1 → put egg 1<br>Reasoning: [hea 005] Direct Post-Heat Placement: move to target without detours.                                   |  |  |
> 
> |                                 | Task: Look at pencil under the desklamp.                                                                                                                                                                                               |
> |---------------------------------|----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
> | Core Skills<br>Mistakes Avoided | [loo 001] Seek lamp surfaces (Desk/Sidetable); [loo 002] Switch lamp on; [exa 001] Pair objects early<br>(Target & Tool co-location).<br>[err 003] Ignoring reachable targets; [loo 005] Preventing action loops (Toggle only once).   |
> |                                 | Agent Trajectory: High-Efficiency Co-location Handling                                                                                                                                                                                 |
> | Step 1                          | Obs: Mid-room. Visible: desk 1/2, drawer 1-3, sidetable 1, etc.<br>Reasoning: [loo 001] Desklamps usually sit on desks. Prioritizing desk 1 to find both pencil and lamp in one<br>go.<br>Action: go to desk 1                         |
> | Step 2                          | Obs: On desk 1: alarmclock 1, desklamp 1, pencil 1.<br>Reasoning: [exa 001] Successful co-location! Both objects are present. [exa 002] Pick up target first before<br>interacting with the tool.<br>Action: take pencil 1 from desk 1 |
> | Step 3                          | Obs: Holding pencil 1.<br>Reasoning: [loo 002] Toggle the lamp state to satisfy the "under light" condition. [exa 004] Single toggle rule<br>ensures no repeated actions.<br>Action: use desklamp 1                                    |
