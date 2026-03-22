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
> ## **SKILLRL: Evolving Agents via Recursive Skill-Augmented** **Reinforcement Learning**
> 
> **Peng Xia** [1 *] **Jianwen Chen** [1 *] **Hanyang Wang** [1 2 *] **Jiaqi Liu** [1] **Kaide Zeng** [1] **Yu Wang** [3] **Siwei Han** [1]
> 
> **Yiyang Zhou** [1] **Xujiang Zhao** [4] **Haifeng Chen** [4] **Zeyu Zheng** [5] **Cihang Xie** [6] **Huaxiu Yao** [1]
> 
> 
> 
> **Abstract**
> 
> 
> Large Language Model (LLM) agents have shown
> stunning results in complex tasks, yet they often
> operate in isolation, failing to learn from past
> experiences. Existing memory-based methods
> primarily store raw trajectories, which are often
> redundant and noise-heavy. This prevents agents
> from extracting high-level, reusable behavioral
> patterns that are essential for generalization. In
> this paper, we propose SKILLRL, a framework
> that bridges the gap between raw experience and
> policy improvement through automatic skill discovery and recursive evolution. Our approach
> introduces an experience-based distillation mechanism to build a hierarchical skill library SKILLBANK, an adaptive retrieval strategy for general
> and task-specific heuristics, and a recursive evolution mechanism that allows the skill library to
> co-evolve with the agent’s policy during reinforcement learning. These innovations significantly reduce the token footprint while enhancing
> reasoning utility. Experimental results on ALFWorld, WebShop and seven search-augmented
> tasks demonstrate that SKILLRL achieves stateof-the-art performance, outperforming strong
> baselines over 15.3% and maintaining robustness
> as task complexity increases. Code is available at
> [this https://github.com/aiming-lab/SkillRL.](https://github.com/aiming-lab/SkillRL)
> 
> 
> **1. Introduction**
> 
> Large language model (LLM) agents (Yao et al., 2022b;
> Shinn et al., 2023) have demonstrated remarkable capabilities across various sophisticated tasks, such as web
> navigation (Google, 2025; OpenAI, 2025c) and deep research (OpenAI, 2025b; Google, 2024; Team et al., 2025),
> 
> 
> 1UNC-Chapel Hill 2University of Chicago 3University of
> California San Diego [4] NEC Labs America [5] University of California Berkeley [6] University of California Santa Cruz. Correspondence to: Peng Xia _<_ pxia@cs.unc.edu _>_, Huaxiu Yao
> _<_ huaxiu@cs.unc.edu _>_ .
> 
> 
> _Preprint._ _February 10, 2026._
> 
> 
> 
> _Figure 1._ (a) Overview of the SKILLRL pipeline. Unlike previous methods (gray dashed lines) that store raw trajectories and
> discard failures, SKILLRL employs an experience-based distillation mechanism to transform diverse experiences into structured
> skills. (b) Performance on ALFWorld validation set (Shridhar
> et al.). SKILLRL achieves faster convergence and superior success
> rates compared to vanilla GRPO and memory-augmented RL.
> 
> 
> by interacting with complex environments through natural
> language. Despite these advances, each task execution remains largely episodic. Current LLM agents operate in isolation, unable to learn from past successes or failures (Zhang
> et al., 2025b), which significantly hinders their evolution.
> Consequently, a fundamental challenge remains: _how can_
> _agents_ _efficiently_ _learn_ _from_ _experience_ _and_ _transfer_ _that_
> _knowledge to other tasks?_
> 
> 
> The existing memory-based methods for LLM agents primarily involve saving raw trajectories directly into external
> databases during the sampling process to serve as references
> for similar future tasks (Shinn et al., 2023; Zhao et al., 2024).
> While intuitive, these raw trajectories are often lengthy and
> contain significant redundancy and noise (Chhikara et al.,
> 2025), making it difficult for the model to extract critical information. Recent work has attempted to compress trajectories and update the memory bank via online training (Zhang
> et al., 2025b; 2026), improving memory efficiency. However, these methods merely mimic past solutions and they
> fail to distill core principles or adapt the agent’s internal
> policy to leverage memory for guided decision-making. As
> depicted in the dashed flow of Figure 1(a), such approaches
> often struggle with the trade-off between information den
> 
> 
> Memory Skills
> 
> 
> 
> Base Environment
> Model
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
> 1
> 
> 
> **SKILLRL: Evolving Agents via Recursive Skill-Augmented Reinforcement Learning**
> 
> 
> 
> sity and noise, leading to sub-optimal performance or even
> degradation as shown in Figure 1(b).
> 
> 
> We argue that these approaches miss a crucial insight: effective experience transfer requires _abstraction_ . Human experts
> do not memorize every action in every situation; instead,
> they develop _skills_ (Anthropic, 2024), compact and reusable
> strategies that capture the essence of how to accomplish
> specific subtasks. Inspired by this observation, we propose
> SKILLRL, a framework that bridges the gap between raw
> experience and efficient policy improvement through automatic skill discovery and recursive skill evolution.
> 
> 
> SKILLRL first introduces an experience-based skill distillation mechanism, which gathers diverse trajectories from
> environment rollouts and applies differential processing:
> successful episodes are preserved as demonstrations, while
> failed ones are synthesized into concise failure lessons to
> mitigate context noise. Secondly, we transform these experiences into a hierarchical skill library SKILLBANK, differentiating between _general_ _skills_ for universal strategic
> guidance and _task-specific_ _skills_ for task-level heuristics.
> This abstraction allows the agent to adaptively retrieve relevant skills during decision-making, significantly reducing
> the token footprint while enhancing reasoning utility. Lastly,
> SKILLRL incorporates a recursive skill evolution mechanism during reinforcement learning (RL), where the skill
> library is treated as a dynamic component rather than a static
> knowledge source. By analyzing failure modes after each
> validation epoch to generate new skills or refine existing
> ones, our approach ensures the skill library and the agent’s
> policy co-evolve, maintaining robustness as task complexity increases. As demonstrated in Figure 1(b), SKILLRL
> achieves substantially faster convergence and higher asymptotic performance.
> 
> 
> The primary contribution is SKILLRL, a framework that enables LLM agents to bridge the gap between raw experience
> and policy improvement through automatic skill discovery
> and recursive evolution. By distilling redundant trajectories into a hierarchical SKILLBANK, our method abstracts
> general and task-specific skills to guide decision-making
> efficiently. Furthermore, we introduce a recursive evolution
> mechanism that ensures the skill library and agent policy coevolve during reinforcement learning. Empirical results on
> ALFWorld, WebShop, and seven search-augmented benchmarks demonstrate that SKILLRL achieves state-of-the-art
> performance with 15.3% improvements, significantly outperforming current memory-based agent-tuning baselines
> in both task success and reasoning utility.
> 
> 
> **2. Preliminaries**
> 
> 
> **LLM Agents.** We consider an agent operating in an interactive environment _E_ . At each timestep _t_, the agent observes
> 
> 
> 
> a state _ot_ _∈O_, selects an action _at_ _∈A_, and receives
> a reward _rt_ and next observation _ot_ +1. A trajectory _τ_ =
> ( _o_ 0 _, a_ 0 _, r_ 0 _, . . ., oT, aT, rT_ ) captures one episode of interaction. Tasks are specified by natural language descriptions _d_ .
> An LLM-based agent parameterized by _θ_ implements a policy _πθ_ ( _at|o≤t, d, c_ ) where _c_ represents additional context
> (e.g., skills, demonstrations). Our goal is to learn a policy
> that maximizes expected return max _θ_ E _τ_ _∼πθ_ �� _Tt_ =0 _[γ][t][r][t]_ 
> subject to context length constraints _|c| ≤_ _L_ max.
> 
> 
> **Group** **Relative** **Policy** **Optimization** **(GRPO).**
> GRPO (Shao et al., 2024) is a reinforcement learning method that avoids training a critic by using intra-group
> relative rewards to optimize the policy. For each query _x_,
> the model samples _G_ responses _{y_ [(1)] _, . . ., y_ [(] _[G]_ [)] _}_, which are
> scored to obtain rewards _{R_ 1 _, . . ., RG}_ . GRPO computes
> normalized advantages and updates the policy with a
> PPO-style clipped objective (Schulman et al., 2017):
> 
> 
> 
> where _ri_ = _ππ_ old _θ_ (( _yyii||xx_ )) [is] [the] [importance] [ratio,] _[A][i]_ =
> 
> _Ri−_ mean( _{Rj_ _}_ _[G]_ _j_ =1 [)]
> 
> std( _{Rj_ _}_ _[G]_ _j_ =1 [)] is the normalized advantage, _ϵ_, _β_ are hyper
> parameters, and _π_ old is the policy before the current update.
> 
> 
> **3. SKILLRL**
> 
> 
> In this section, as illustrated in Figure 2, we propose
> SKILLRL, a framework designed to bridge the gap between
> raw interaction experience and policy improvement through
> automatic skill discovery and recursive evolution. SKILLRL
> consists of three core components. First, we develop an
> experience-based skill distillation mechanism to transform
> redundant trajectories into concise, actionable knowledge.
> Second, we organize these distilled experiences into a hierarchical skill library _S_, enabling efficient retrieval of general
> and task-specific expertise. Lastly, we introduce a recursive
> skill evolution mechanism that leverages RL to dynamically
> refine the skill library in tandem with the agent’s policy. We
> detail these components as follows:
> 
> 
> **3.1. Experience-based Skill Distillation**
> 
> 
> Raw trajectories _τ_ collected from environment interactions
> are verbose, containing exploratory actions, backtracking,
> and redundant steps that obscure the critical decisions leading to success or failure. To transform these experiences
> into actionable knowledge, we employ a teacher model _MT_
> to distill trajectories into compact, reusable skills.
> 
> 
> Specifically, we first deploy a base LLM agent _π_ base in the
> 
> 
> 
> _G_
> 
> - min - _riAi,_
> 
> 
> _i_ =1
> 
> 
> 
> _J_ GRPO( _θ_ ) = E _x,{yi}_
> 
> 
> 
> 
> 1
> _G_
> 
> 
> 
> 
> 
> 
> 
> (1)
> 
> 
> 
> 
>         clip( _ri,_ 1 _−_ _ϵ,_ 1 + _ϵ_ ) _Ai_ _−_ _βD_ KL( _πθ∥π_ ref)
> 
> 
> 
> _,_
> 
> 
> 
> 2
> 
> 
> _Figure 2._ Overview of the SKILLRL framework. We collect trajectories using a base model, distill them into a hierarchical skill library,
> perform cold-start SFT to enable skill utilization, and then conduct RL training with dynamic skill evolution based on validation failures.
> 
> 
> 
> target environment _E_ to collect diverse trajectories. Unlike
> prior approaches that retain only successful episodes, we deliberately preserve both successful trajectories _T_ [+] = _{τi_ :
> _r_ ( _τi_ ) = 1 _}_ and failed trajectories _T_ _[−]_ = _{τi_ : _r_ ( _τi_ ) = 0 _}_,
> where _r_ ( _τ_ ) denotes the binary task success indicator. Failed
> trajectories reveal failure modes and boundary conditions,
> i.e., information difficult to infer from successes alone.
> 
> 
> We apply differential processing based on trajectory outcomes. For _successful trajectories τ_ [+] _∈T_ [+], we extract the
> strategic patterns that led to task completion:
> 
> 
> _s_ [+] = _MT_ ( _τ_ [+] _, d_ ) _._ (2)
> 
> 
> The teacher model identifies critical decision points, the
> reasoning behind correct actions, and generalizable patterns
> that transfer beyond the specific task instance.
> 
> 
> For _failed trajectories τ_ _[−]_ _∈T_ _[−]_, direct inclusion in context
> is infeasible due to their length and noise. Instead, we
> synthesize concise failure lessons:
> 
> _s_ _[−]_ = _MT_ ( _τ_ _[−]_ _, d_ ) _._ (3)
> 
> 
> The analysis identifies: (1) the point of failure, (2) the flawed
> reasoning or action, (3) what should have been done, and
> (4) general principles to prevent similar failures. This transforms verbose failed episodes into counterfactuals.
> 
> 
> **3.2. Hierarchical Skill Library (SKILLBANK)**
> **Construction**
> 
> 
> Following the design principles of Agent Skills (Anthropic,
> 2024), we organize the distilled knowledge into a hierarchical skill library SKILLBANK that enables efficient retrieval
> of relevant expertise during decision-making.
> 
> 
> **Skill Organization.** We structure SKILLBANK into two
> levels: 1) _General Skills Sg_ capture universal strategic prin
> 
> 
> ciples applicable across all task types within an environment.
> These typically include exploration strategies (e.g., systematic search patterns, prioritizing unvisited locations), state
> management principles (e.g., verifying preconditions before actions), and goal-tracking heuristics (e.g., maintaining
> progress counters, terminating only upon verified completion). General skills provide foundational guidance that
> transfers across different task categories. 2) _Task-Specific_
> _Skills Sk_ encode specialized knowledge for task category
> _k_ . These capture domain-specific action sequences, taskparticular preconditions and constraints, common failure
> modes unique to the task type, and optimized procedures
> that exploit task structure. By organizing trajectories by task
> type during collection, we enable extraction of fine-grained,
> category-specific strategies that complement the broader
> general skills.
> 
> The complete skill library SKILLBANK is _Sg_ _∪_ [�] _[K]_ _k_ =1 _[S][k]_ [.]
> Each skill _s_ _∈_ SKILLBANK is structured with: a concise
> name (e.g., systematic exploration), a principle describing
> the strategy, and when ~~t~~ - ~~a~~ pply conditions specifying applicability. This format enables efficient retrieval while
> providing clear guidance for application.
> 
> 
> **Skill** **Retrieval.** At inference, given a task description
> _d_, the agent retrieves relevant skills to augment its context. General skills _Sg_ are always included as foundational
> guidance. Task-specific skills are retrieved via semantic
> similarity:
> 
> 
> _S_ ret = TopK ( _{s ∈Sk_ : sim( _ed, es_ ) _> δ}, K_ ) _,_ (4)
> 
> 
> where _ed, es_ are embeddings of the task description and skill
> respectively, _δ_ is a similarity threshold, and _K_ controls the
> number of retrieved skills. The policy then conditions on
> 
> 
> 
> 3
> 
> 
> **SKILLRL: Evolving Agents via Recursive Skill-Augmented Reinforcement Learning**
> 
> 
> 
> **Algorithm 1** SKILLRL: Recursive Skill-Augmented RL
> 
> 
> **Require:** Base model _π_ base, teacher _MT_, environment _E_
> **Ensure:** Trained policy _πθ_ _[∗]_, evolved skill library SKILLBANK _[∗]_
> 
> 1: _▷_ Experience-based Skill Distillation
> 2: _T_ [+] _, T_ _[−]_ _←_ Rollout( _π_ base _, E_ )
> 3: **for all** _τ_ [+] _∈T_ [+] **do**
> 4: _s_ [+] _←MT_ ( _τ_ [+] )
> 5: **end for**
> 6: **for all** _τ_ _[−]_ _∈T_ _[−]_ **do**
> 7: _s_ _[−]_ _←MT_ ( _τ_ _[−]_ )
> 8: **end for**
> 9: _▷_ Hierarchical Skill Library Construction
> 10: _Sg_ _←_ general skills from distilled experiences
> 11: **for all** task type _k_ **do**
> 12: _Sk_ _←_ task-specific skills for category _k_
> 13: **end for**
> 14: SKILLBANK _←Sg_ _∪_ [�] _k_ _[S][k]_
> 
> 15: _▷_ Recursive Skill Evolution via RL
> 16: _// Cold-start initialization_
> 17: _D_ SFT _←MT_ ( _E,_ SKILLBANK)
> 18: _θ_ _←_ SFT( _π_ base _, D_ SFT); _π_ ref _←_ _πθ_
> 19: _// RL with recursive evolution_
> 20: **for** epoch = 1 to _N_ **do**
> 21: **for all** task _d_ **do**
> 22: _S_ ret _←_ Retrieve( _d,_ SKILLBANK)
> 23: Sample _{τ_ [(] _[i]_ [)] _}_ _[G]_ _i_ =1 _[∼]_ _[π][θ]_ [(] _[·|][d,][ S][g][,][ S]_ [ret][)]
> 24: Compute _{Ri}_ _[G]_ _i_ =1 [and update] _[ θ]_ [ via GRPO]
> 25: **end for**
> 26: **if** validation epoch **then**
> 27: _T_ val _[−]_ _[←]_ [failed validation trajectories]
> 28: _S_ new _←MT_ ( _T_ val _[−][,]_ [ S][KILL][B][ANK][)]
> 29: SKILLBANK _←_ SKILLBANK _∪S_ new
> 30: **end if**
> 31: **end for**
> 32: **return** _πθ_, SKILLBANK
> 
> 
> the retrieved skills:
> 
> 
> _at_ _∼_ _πθ_ ( _at|o≤t, d, Sg, S_ ret) _._ (5)
> 
> 
> Notably, skill distillation achieves 10–20 _×_ token compression compared to raw trajectories while enhancing rather
> than degrading the utility of the original experience. This
> compression allows the agent to leverage rich experiential
> knowledge within limited context windows.
> 
> 
> **3.3. Recursive Skill Evolution**
> 
> 
> A static skill library cannot anticipate all scenarios the agent
> will encounter. As the policy improves and explores new
> state regions, it faces situations where existing skills provide
> insufficient guidance. We introduce recursive skill evolution
> during reinforcement learning to address this limitation,
> enabling the skill library and agent policy to co-evolve.
> 
> 
> **Cold-Start Initialization.** Before RL training, we address
> a critical challenge: the base agent has not learned how
> to effectively utilize skills. Simply providing skills to an
> unchanged model yields limited benefit (Guo et al., 2025).
> We therefore perform a cold-start supervised fine-tuning
> 
> 
> 
> (SFT) stage (Ouyang et al., 2022), where the teacher model
> _MT_ generates _N_ skill-augmented reasoning traces _D_ SFT =
> _{_ ( _di, Si, τi_ _[∗]_ [)] _[}]_ _i_ _[N]_ =1 [demonstrating how to retrieve, interpret,]
> and apply skills during decision-making. The base model is
> then fine-tuned on these demonstrations:
> 
> 
> _θ_ sft = arg min _L_ CE( _D_ SFT; _θ_ ) _,_ (6)
> _θ_
> 
> 
> where _L_ CE denotes the cross-entropy loss. The resulting
> model _πθ_ sft serves as both the starting point for RL training
> and the reference policy _π_ ref for KL regularization.
> 
> 
> **Recursive Skill Evolution.** A static skill library cannot anticipate all scenarios the agent will encounter. As the policy
> improves and explores new state regions, it faces situations
> where existing skills provide insufficient guidance. We introduce recursive skill evolution to address this limitation.
> The process begins with an initial skill library containing
> baseline task-action principles.
> 
> 
> After each validation epoch, we monitor the success rate
> _Acc_ ( _C_ ) for each task category _C_ . To ensure targeted
> growth, the evolution is triggered only for categories where
> _Acc_ ( _C_ ) _< δ_ . We then collect failed trajectories _T_ val _[−]_ [=] _[ {][τ][j]_ [:]
> _r_ ( _τj_ ) = 0 _}_ _[M]_ _j_ =1 [using a diversity-aware stratified sampling]
> strategy: trajectories are grouped by category, prioritized by
> the severity of failure (negative rewards), and selected via
> round-robin sampling to maintain categorical entropy. Then
> we will analyze these samples to identify gaps:
> 
> 
> _S_ new = _MT_ ( _T_ val _[−][,]_ [ S][KILL][B][ANK][)] _[.]_ (7)
> 
> 
> The teacher model is prompted to: (1) identify failure patterns not addressed by current skills, (2) propose new skills
> to cover these gaps, and (3) suggest refinements to existing
> skills that proved ineffective. The library is then updated:
> SKILLBANK _←_ SKILLBANK _∪S_ new.
> 
> 
> This creates a virtuous cycle: as the agent improves, it encounters new challenges, which drive skill library expansion,
> which enables further improvement.
> 
> 
> **RL-based** **Policy** **Optimization.** We optimize the skillaugmented policy using GRPO. For each task with description _d_, the agent first retrieves relevant skills and then samples _G_ complete trajectories _{τ_ [(1)] _, . . ., τ_ [(] _[G]_ [)] _}_ from the current policy _πθ_ . Each trajectory _τ_ [(] _[i]_ [)] receives a binary reward
> _Ri_ = _r_ ( _τ_ [(] _[i]_ [)] ) _∈{_ 0 _,_ 1 _}_ indicating task successfulness. The
> normalized advantage for each trajectory is computed as:
> 
> 
> _[−]_ [mean][(] _[{][R][j][}][G]_ _j_ =1 [)]
> _Ai_ = _[R][i]_ _._ (8)
> std( _{Rj}_ _[G]_ _j_ =1 [)]
> 
> 
> 
> 4
> 
> 
> **SKILLRL: Evolving Agents via Recursive Skill-Augmented Reinforcement Learning**
> 
> 
> 
> The policy is updated according to:
> 
> 
> 
> _G_
> 
> - min - _ρiAi,_
> 
> 
> _i_ =1
> 
> 
> 
> _J_ ( _θ_ ) = E _d,{τ_ ( _i_ ) _}_
> 
> 
> 
> 
> - 1
> 
> _G_
> 
> 
> 
> and GRPO (Shao et al., 2024) that optimize policies via
> advantage estimation over trajectory groups. Finally, we
> compare against memory-augmented RL-based methods,
> such as EvolveR (Wu et al., 2025), MemRL (Zhang et al.,
> 2026), and the combination of Mem0+GRPO and SimpleMem (Liu et al., 2026)+GRPO, which integrate persistent memory mechanisms directly into the reinforcement learning optimization process to handle long-term
> dependencies. For search-augmented QA, we compare
> SKILLRL with R1-Instruct, Search-o1 (Li et al., 2025),
> Search-R1 (Jin et al., 2025), ZeroSearch (Sun et al., 2025),
> and StepSearch (Zheng et al., 2025).
> 
> 
> **Implementation** **Details.** We use Qwen2.5-7BInstruct (Bai et al., 2023) as our base model and
> OpenAI o3 (OpenAI, 2025a) as the teacher model for skill
> distillation and SFT data generation. For RL training, we
> use GRPO with learning rate 1 _×_ 10 _[−]_ [6], batch size 16, group
> size 8, and 4 gradient accumulation steps. We set _K_ = 6 for
> task-specific skill retrieval and _δ_ = 0 _._ 4 for the collection
> of failed trajectories. For more detailed information on
> training hyperparameters, please see Appendix B.1.
> 
> 
> **4.2. Main Results**
> 
> 
> **Comparison with Baselines.** We compare SKILLRL with
> baseline methods across two benchmarks as shown in Table 1. Our method consistently outperforms all baselines,
> with key observations as follows:
> 
> 
> 1) _Significant Gains over Prompt-based Methods_ . SKILLRL
> achieves a 89.9% success rate on ALFWorld and 72.7% on
> WebShop, outperforming the best prompt-based baselines
> by a large margin. This gap suggests that while in-context
> learning can leverage past experiences, it often fails to distill
> actionable knowledge from verbose trajectories or fundamentally adapt the agent’s policy.
> 
> 
> 2) _Superiority_ _over_ _Vanilla_ _RL_ . RL training brings substantial gains, yet SKILLRL consistently surpasses standard RL baselines. Compared to PPO, RLOO, and GRPO,
> SKILLRL achieves the best overall performance. Notably,
> since SKILLRL utilizes GRPO as its base optimizer, the
> 12.3% absolute improvement over GRPO on ALFWorld
> (from 77.6% to 89.9%) is directly attributable to our skillaugmentation mechanism rather than algorithmic variance.
> In complex subtasks like _Cool_ and _Pick2_, SKILLRL outperforms GRPO by 23.0% and 22.8% respectively, proving
> that structured skill priors effectively accelerate and enhance
> policy learning in sparse-reward environments.
> 
> 
> 3) _Advantage over Memory-Augmented RL._ SKILLRL substantially outperforms existing memory-augmented RL
> frameworks, which differ in how they manage and update
> experience. MemRL, which uses RL solely to update its
> memory bank while keeping the policy frozen, fails to adapt
> 
> 
> 
> 
>                
>         clip( _ρi,_ 1 _−_ _ϵ,_ 1 + _ϵ_ ) _Ai_ _−_ _βD_ KL( _πθ∥π_ ref) _,_
> 
> 
> 
> 
> 
> 
> 
> (9)
> 
> 
> 
> _,_
> 
> 
> 
> where _ρi_ = _ππ_ old _θ_ (( _ττ_ [(][(] _[i][i]_ [)][)] _||d,d,SSgg,,SS_ retret)) [is] [the] [importance] [ratio] [com-]
> puted over the skill-augmented context. The KL penalty
> anchored to _π_ ref = _πθ_ sft ensures that RL optimization preserves the learned skill utilization capabilities while improving task performance. The complete training procedure is
> summarized in Algorithm 1.
> 
> 
> **4. Experiments**
> 
> 
> We evaluate SKILLRL on nine challenging benchmarks
> for LLM agents: ALFWorld, WebShop, and seven searchaugmented QA tasks. Our experiments address the following questions: 1) How does SKILLRL compare to stateof-the-art methods? 2) What is the contribution of each
> component? 3) How does the skill library evolve during
> training? 4) Does skills accelerate model convergence?
> 
> 
> **4.1. Experimental Setup**
> 
> 
> **Environments.** ALFWorld (Shridhar et al.) is a text-based
> game aligned with the ALFRED embodied AI benchmark.
> Agents must complete household tasks by navigating and
> interacting with objects through text commands. WebShop
> (Yao et al., 2022a) simulates web shopping. Agents navigate
> a realistic web interface to find and purchase products matching user specifications. In addition, we also evaluate the
> performance of SKILLRL on search-augmented QA tasks,
> including single-hop QA datasets (NQ (Kwiatkowski et al.,
> 2019), TriviaQA (Joshi et al., 2017), and PopQA (Mallen
> et al., 2023)) and multi-hop QA datasets (HotpotQA (Yang
> et al., 2018), 2Wiki (Ho et al., 2020), MuSiQue (Trivedi
> et al., 2022), and Bamboogle (Press et al., 2023)).
> 
> 
> **Baselines.** We compare SKILLRL against four categories
> of competitive methods. First, we include closed-source
> LLMs, specifically GPT-4o (OpenAI, 2024) and Gemini2.5-Pro (Comanici et al., 2025), which represent the state-ofthe-art in general-purpose reasoning and instruction following. Second, we evaluate prompt-based agentic or memorybased methods, including ReAct (Yao et al., 2022b) and Reflexion (Shinn et al., 2023), which rely on in-context prompting for multi-step reasoning, as well as Mem0 (Chhikara
> et al., 2025), ExpeL (Zhao et al., 2024), and MemP (Fang
> et al., 2025), which utilize external memory or experience
> pools to guide behavior without parameter updates. Third,
> we consider RL-based methods, including group-based online RL algorithms such as RLOO (Ahmadian et al., 2024)
> 
> 
> 
> 5
> 
> 
> **SKILLRL: Evolving Agents via Recursive Skill-Augmented Reinforcement Learning**
> 
> 
> _Table 1._ Performance on ALFWorld and WebShop. For ALFWorld, we report the average success rate (%) for each subtask as well as
> the overall result. For WebShop, we report both the average score and the average success rate (%). _[∗]_ denotes the results replicated
> 
> from (Feng et al., 2025). The best results and second best results are highlighted in red and blue, respectively.
> 
> 
> **ALFWorld** **WebShop**
> 
> 
> 
> to complex environments, yielding only 21.4% on ALFWorld. EvolveR, which jointly updates the policy and memory bank, shows improvement (43.8%) but remains limited
> by its reliance on rough trajectory storage. To provide a
> more competitive baseline, we implemented Mem0+GRPO,
> which combines a state-of-the-art prompt-based memory
> mechanism with an optimized policy model. While this
> hybrid approach improves performance to 54.7% on ALFWorld and 37.5% on WebShop, it still trails SKILLRL by
> a wide margin (about 35.2% absolute success rate gap).
> These results validate our core hypothesis: effective experience transfer requires high-level skill abstraction and a
> co-evolving library rather than simple trajectory compression or prompt-based memory retrieval.
> 
> 
> **Comparison** **with** **Closed-Source** **Models.** Remarkably,
> SKILLRL with Qwen2.5-7B-Instruct significantly outperforms much larger closed-source models, as shown in Table 1. On ALFWorld, our method exceeds GPT-4o (OpenAI,
> 2024) by 41.9% and Gemini-2.5-Pro (Comanici et al., 2025)
> by 29.6%. This demonstrates that effective skill learning
> can compensate for model scale, enabling smaller opensource models to achieve superior task performance through
> structured experiential knowledge.
> 
> 
> **Performance** **on** **Search-Augmented** **QA.** As shown in
> 
> 
> 
> Table 2, SKILLRL achieves a state-of-the-art average score
> of 47.1%, significantly outperforming Search-R1 (38.5%)
> abd EvolveR (43.1%). Key observations include: 1) Superior multi-hop Reasoning: SKILLRL excels in complex
> tasks like Bamboogle, surpassing EvolveR by 19.4%. This
> demonstrates that hierarchical skills effectively guide multistep information synthesis. 2) Strong generalization: Despite being trained on limited datasets (NQ, HotpotQA),
> SKILLRL maintains competitive performance on OOD tasks
> like TriviaQA and 2Wiki, confirming that distilled search
> strategies are task-agnostic.
> 
> 
> **4.3. Analysis**
> 
> 
> In this section, we provide detailed analysis of each module’s effectiveness and the skill evolution dynamics.
> 
> 
> **Ablation Studies.** We conduct ablation experiments to evaluate each component’s contribution, with results in Table 3.
> According to the results: (1) Removing hierarchical structure (i.e., task-specific skills only) decreases performance
> by 13.1% on ALFWorld and 11.3% on WebShop, indicating
> universal strategic principles provide essential foundational
> guidance. (2) Replacing the skill library with raw trajectories causes the largest degradation (up to 25%), which
> 
> 
> 
> 6
> 
> 
> **SKILLRL: Evolving Agents via Recursive Skill-Augmented Reinforcement Learning**
> 
> 
> _Table_ _2._ Performance on search-augmented QA tasks. SKILLRL is trained on NQ and HotpotQA. _[†]_ and _[⋆]_ indicate in-domain and
> out-of-domain datasets, respectively. _[∗]_ denotes the results replicated from (Sun et al., 2025).
> 
> 
> **Single-Hop QA** **Multi-Hop QA**
> **Method** **Avg.**
> NQ _[†]_ TriviaQA _[⋆]_ PopQA _[⋆]_ HotpotQA _[†]_ 2Wiki _[⋆]_ MuSiQue _[⋆]_ Bamboogle _[⋆]_
> 
> 
> |Qwen2.5-7B-Instruct Qwen2.5∗ 11.6 35.6 1.20|16.4 22.2 4.80 14.4|15.2|
> |---|---|---|
> |CoT_∗_<br>12.8<br>35.6<br>3.80<br>RAG_∗_<br>27.4<br>58.2<br>17.8<br>Search-o1_∗_<br>19.4<br>40.6<br>11.4<br>R1-Instruct<br>21.0<br>44.9<br>17.1<br>Search-R1<br>39.3<br>61.0<br>39.7<br>ZeroSearch<br>43.6<br>61.8<br>51.5<br>StepSearch<br>-<br>-<br>-<br>EvolveR<br>43.5<br>63.4<br>44.6|16.2<br>22.6<br>6.60<br>24.0<br>25.8<br>23.2<br>9.40<br>16.8<br>17.0<br>27.0<br>8.60<br>30.4<br>20.8<br>27.5<br>6.00<br>19.2<br>37.0<br>40.1<br>14.6<br>36.8<br>34.6<br>35.2<br>18.4<br>27.8<br>38.6<br>36.6<br>22.6<br>40.0<br>38.2<br>42.0<br>15.6<br>54.4|17.4<br>25.5<br>22.1<br>22.4<br>38.5<br>39.1<br>-<br>43.1|
> |SKILLRL<br>45.9<br>63.3<br>45.9|43.2<br>40.3<br>20.2<br>73.8|47.1|
> 
> 
> 
> _Table 3._ Ablation study results. We report average success rate (%)
> on ALFWorld and WebShop.
> 
> 
> **Method** **ALFWorld** **WebShop**
> 
> 
> SKILLRL **89.9** **72.7**
> 
> 
> _Skill Library Ablations_
> w/o Hierarchical Structure 76.8 61.4
> w/o Skill Library (Raw Trajectories) 61.7 50.2
> 
> 
> _Training Pipeline Ablations_
> w/o Cold-Start SFT 65.2 46.5
> w/o Dynamic Evolution 84.4 70.3
> 
> 
> directly supports our motivation that abstraction is superior
> to memorization. Raw experiences introduce significant redundancy and noise that hinder effective knowledge transfer.
> (3) Cold-start SFT proves critical (20% drop without it),
> confirming that the base model requires an initial explicit
> demonstration phase to learn how to adaptively retrieve and
> utilize the abstracted skills before entering the RL stage.
> (4) Dynamic evolution contributes a 5.5% improvement by
> ensuring the skill library is a dynamic component rather
> than a static database. This co-evolution allows the agent to
> iteratively refine its internal policy by addressing emergent
> failure modes that were not covered by the initial skill set.
> 
> 
> **Per-Task Analysis on ALFWorld.** Table 1 breaks down
> ALFWorld performance by task type. The largest gains are
> on PickTwo (+23%), Cool (+22%) and Heat (+15%), which
> are among the most challenging tasks requiring multi-step
> planning and state tracking. Task-specific skills are particularly valuable here, capturing strategies like “when picking
> two objects, verify the first is secured before searching for
> the second” that address common failure modes.
> 
> 
> **Skill Library Growth.** Figure 3 shows how the skill library
> evolves during training. The initial skill library contains
> 55 skills (12 general, 43 task-specific). Through dynamic
> evolution, this grows to 100 skills by the end of training
> (Step 150). The growth is predominantly driven by taskspecific skills (increasing from 43 to 80), while general
> 
> 
> |To<br>G|Col2|tal Skills<br>eneral|Col4|Col5|Heat<br>Cool|Col7|Col8|Col9|Col10|Col11|Col12|Col13|Col14|Col15|Col16|Col17|Col18|Col19|Col20|Col21|Col22|Col23|Col24|Col25|Col26|Col27|Col28|
> |---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
> |Pi<br>Lo<br>Cl|Pi<br>Lo<br>Cl|ck<br>ok<br>ean|ck<br>ok<br>ean|ck<br>ok<br>ean|Pick2<br>Mista|Pick2<br>Mista|Pick2<br>Mista|kes|||||||||||||||1|1|1|00|00|
> ||||||||||||7|7|7|7<br>8|7<br>8|7<br>8|3<br>8|3<br>8|3<br>8|8<br>~~9~~|8<br>~~9~~|8<br>~~9~~|~~4~~|~~4~~||||
> ||||||||||||7|7|7|7<br>8|7<br>8|7<br>8|3<br>8|3<br>8|3<br>8|8<br>~~9~~|8<br>~~9~~|||||||
> ||||||||||||7|7|7|7<br>8|7<br>8|7<br>8|3<br>8|3<br>8||||||||||
> |~~5~~|~~5~~|~~5~~<br>6|~~5~~<br>6|~~5~~<br>6|0<br>6|0<br>6|0<br>6|6<br>7|6<br>7|6<br>7|1|1||||||||||||||||
> |~~5~~|~~5~~|~~5~~<br>6|~~5~~<br>6|~~5~~<br>6|0<br>6|0<br>6|0<br>6|6<br>7|6<br>7|||||||||||||||||||
> |~~5~~|~~5~~|~~5~~<br>6|~~5~~<br>6|~~5~~<br>6|0<br>6|0<br>6||||||||||||||||||||||
> |||||||||||||||||||||||||||||
> 
> 
> 
> _Figure 3._ Evolution of skill library size during RL training. Dynamic skill evolution adds skills at validation checkpoints.
> 
> 
> skills show a steadier increase (from 12 to 20). Notably, we
> observe a balanced expansion across various task categories,
> ensuring the agent develops specialized expertise for each
> environment rollout. This overall expansion reflects the
> agent’s increasing ability to refine its repertoire and tackle
> diverse scenarios within specific task types.
> 
> 
> **Context Efficiency.** To evaluate the impact of skill abstraction on inference overhead, we compare the average prompt
> length of SKILLRL with a memory-augmented baseline
> using raw trajectories (Qwen2.5-7B with Raw Memory) in
> Figure 4. The results reveal that while the raw memory
> approach suffers from a high and fluctuating token footprint
> (averaging _∼_ 1,450 tokens), SKILLRL maintains a significantly leaner prompt (averaging _<_ 1,300 tokens), achieving
> approximately a 10.3% reduction in context length. This efficiency stems from our distillation mechanism, which compresses verbose environment interactions into high-density,
> actionable skills. Notably, SKILLRL requires less context
> than the memory-based baseline to achieve superior performance, demonstrating that skill abstraction effectively
> mitigates the context-bloat problem common in traditional
> memory-based agents.
> 
> 
> 
> Skill Library Evolution
> 
> 
> 
> 120
> 
> 
> 100
> 
> 
> 80
> 
> 
> 60
> 
> 
> 40
> 
> 
> 20
> 
> 
> 0
> 
> 
> 
> 
> 
> Training Steps
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
> 7
> 
> 
> **SKILLRL: Evolving Agents via Recursive Skill-Augmented Reinforcement Learning**
> 
> 
> 
> _Figure 4._ Comparison of prompt length (tokens) between raw memory retrieval and our distilled skill abstraction. SKILLRL consistently reduces context overhead while maintaining reasoning utility.
> 
> 
> **Evolution** **Dynamics.** Figure 5 illustrates the reinforcement learning training curves with and without the recursive skill evolution mechanism. We observe that while
> SKILLRL without evolution shows steady improvement,
> SKILLRL with skill evolution exhibits a notably higher
> learning rate and superior asymptotic performance. Specifically, SKILLRL achieves a success rate of over 80% within
> 60 training steps, whereas the baseline requires approximately 90 steps to reach a lower peak. This acceleration
> in convergence suggests that the dynamic introduction of
> new skills and refinement of existing ones effectively provide the agent with timely strategic guidance to overcome
> local optima. Furthermore, the higher performance ceiling
> validates that the co-evolution of the skill library and the
> policy allows the agent to adapt to increasingly complex
> task scenarios that static memory methods fail to resolve.
> 
> 
> **Qualitative Analysis.** To further investigate how SKILLRL
> utilizes the learned knowledge, we visualize the reasoning
> process on ALFWorld and WebShop in Figure 6. The case
> studies demonstrate that our trained agent can effectively
> retrieve and execute relevant skills from the SKILLBANK
> to guide its decision-making. For instance, in the WebShop task, the agent invokes general strategies like _“Pri-_
> _oritize Core Keywords”_ alongside task-specific heuristics
> _“Focus Key Query”_ to ensure the product meets all constraints
> within a limited budget. Similarly, in ALFWorld, the agent
> coordinates hierarchical skills, i.e., using _“Progressive Goal_
> _Decomposition”_ for high-level planning and _“No Appliance_
> _Before Object”_ to avoid common logical pitfalls. This seamless integration of general and specific skills confirms that
> the agent does not merely memorize trajectories, but rather
> develops a structured understanding of task logic, allowing
> for more robust and efficient problem-solving.
> 
> 
> **5. Related Work**
> 
> 
> **LLM** **Agents.** The emergence of capable LLMs has
> catalyzed rapid development in autonomous agent systems (Wei et al., 2026). ReAct (Yao et al., 2022b) interleaves
> reasoning and acting, enabling chain-of-thought style plan
> 
> 
> _Figure 5._ Success rate on ALFWorld validation set. The recursive
> skill evolution significantly accelerates convergence and enhances
> the overall performance ceiling.
> 
> 
> ning during interaction, while Reflexion (Shinn et al., 2023)
> introduces verbal reinforcement through self-reflection on
> past failures. Frameworks like AutoGen (Wu et al., 2024)
> and CAMEL (Li et al., 2023) demonstrate general-purpose
> multi-agent capabilities, featuring automated orchestration
> and diverse tool integration. While initial efforts focused on
> constrained tasks like coding or basic arithmetic, these approaches primarily rely on in-context learning (ICL) (Dong
> et al., 2024). However, these agents struggle to scale as tasks
> become more complex, as they treat every interaction as an
> isolated event and must start each new task from scratch
> without any prior knowledge.
> 
> 
> **Memory Mechanisms in Agents.** To overcome the limitations of finite context windows and the inability of agents to
> learn from experience, external memory architectures have
> become a cornerstone of agent design (Hu et al., 2025;
> Wang, 2025). Early systems primarily utilized a static
> RAG paradigm or stored raw trajectories as few-shot examples (Wang et al.; Chhikara et al., 2025; Zhang et al.,
> 2025a; Wang et al., 2024). However, raw trajectories are
> often token-heavy and contain significant redundancy and
> noise, which can lead to performance degradation. Current
> research has moved toward self-improving memory, distilling interactions into higher-level insights or procedural
> tips (Wang & Chen, 2025; Tang et al., 2025; Fang et al.,
> 2025; Zhao et al., 2024; Ouyang et al., 2025; Wei et al.,
> 2025). While some recent work explores updating memory
> banks via online training to improve efficiency (Zhang et al.,
> 2025b; 2026), many existing methods still struggle to distinguish high-value experiences from noise or fail to distill
> core principles that can guide internal decision-making.
> 
> 
> **Evolution of Agentic Skills and Reinforcement Learning.**
> The development of agentic skills (Anthropic, 2024), which
> are compact, reusable strategies that capture the essence
> of subtasks, is increasingly viewed through the lens of
> Continual Learning (CL) and RL. Traditional CL (Parisi
> et al., 2019) focuses on knowledge preservation in predefined tasks, but self-evolving agents (Gao et al., 2025; Xia
> et al., 2025; Liu et al., 2025) aim for active skill acquisition
> in open-ended environments (Fang et al., 2025; Wang et al.,
> 
> 
> 8
> 
> 
> **SKILLRL: Evolving Agents via Recursive Skill-Augmented Reinforcement Learning**
> 
> 
> **WebShop** **A** **LF** **World**
> 
> 
> 
> Task: I need a women's long sleeve button-down shirt in navy blue, size large,
> machine washable, price lower than $40.00
> 
> 
> 
> Task: heat some egg and put it in countertop.
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
> _Figure 6._ Case studies of SKILLRL on WebShop and ALFWorld. The examples illustrate how the agent adaptively retrieves and integrates
> 
> General Skills and Task-Specific Skills within its reasoning process to achieve precise and efficient task execution.
> 
> 
> 
> 2025). While RL is widely used to align LLMs (Schulman
> et al., 2017; Ouyang et al., 2022), or improve reasoning
> via rule-based verifiers (Shao et al., 2024), applying it to
> agentic skills remains challenging due to sparse rewards
> and long horizons. Unlike previous memory-augmented RL
> which treats memory as a static or auxiliary source, recent
> trends suggest that the key to efficient experience transfer
> lies in abstraction (Wu et al., 2025). Our work builds on this
> by treating the skill library as a dynamic component that
> co-evolves with the agent’s policy, utilizing RL to refine
> structured skills through recursive failure analysis.
> 
> 
> **6. Conclusion**
> 
> 
> We introduced SKILLRL, a framework for skill-augmented
> reinforcement learning in LLM agents. By distilling raw
> trajectories into compact, reusable skills and enabling dynamic skill evolution during training, SKILLRL achieves
> state-of-the-art performance on ALFWorld and WebShop
> while using substantially less context than memory-based
> approaches. Our work demonstrates that the abstraction
> from experience to skill is a powerful principle for building
> capable, sample-efficient agents.
> 
> 
> **Acknowledgement**
> 
> 
> This work was partially supported by the Amazon Research
> Award, the Cisco Faculty Research Award, NEC Laboratories America Research Grant, and Coefficient Giving.
> 
> 
> **References**
> 
> 
> Ahmadian, A., Cremer, C., Galle, M., Fadaee, M., Kreutzer,´
> J., Pietquin, O., Ust [¨] un, A., and Hooker, S.¨ Back to basics:
> Revisiting reinforce-style optimization for learning from
> human feedback in llms. In _Proceedings_ _of_ _the_ _62nd_
> _Annual_ _Meeting_ _of_ _the_ _Association_ _for_ _Computational_
> _Linguistics (Volume 1:_ _Long Papers)_, pp. 12248–12267,
> 
> 
> 
> 2024.
> 
> 
> Anthropic. The claude 3 model family: Opus, sonnet, haiku, 2024. [URL https://www.anthropic.](https://www.anthropic.com/news/claude-3-family)
> [com/news/claude-3-family.](https://www.anthropic.com/news/claude-3-family)
> 
> 
> Bai, J., Bai, S., Chu, Y., Cui, Z., Dang, K., Deng, X., Fan,
> Y., Ge, W., Han, Y., Huang, F., et al. Qwen technical
> report. _arXiv preprint arXiv:2309.16609_, 2023.
> 
> 
> Chhikara, P., Khant, D., Aryan, S., Singh, T., and Yadav, D.
> Mem0: Building production-ready ai agents with scalable
> long-term memory. _arXiv_ _preprint_ _arXiv:2504.19413_,
> 2025.
> 
> 
> Comanici, G., Bieber, E., Schaekermann, M., Pasupat, I.,
> Sachdeva, N., Dhillon, I., Blistein, M., Ram, O., Zhang,
> D., Rosen, E., et al. Gemini 2.5: Pushing the frontier
> with advanced reasoning, multimodality, long context,
> and next generation agentic capabilities. _arXiv preprint_
> _arXiv:2507.06261_, 2025.
> 
> 
> Dong, Q., Li, L., Dai, D., Zheng, C., Ma, J., Li, R., Xia,
> H., Xu, J., Wu, Z., Chang, B., et al. A survey on incontext learning. In _Proceedings of the 2024 conference_
> _on empirical methods in natural language processing_, pp.
> 1107–1128, 2024.
> 
> 
> Fang, R., Liang, Y., Wang, X., Wu, J., Qiao, S., Xie,
> P., Huang, F., Chen, H., and Zhang, N. Memp:
> Exploring agent procedural memory. _arXiv_ _preprint_
> _arXiv:2508.06433_, 2025.
> 
> 
> Feng, L., Xue, Z., Liu, T., and An, B. Group-in-group
> policy optimization for llm agent training. _arXiv preprint_
> _arXiv:2505.10978_, 2025.
> 
> 
> Gao, H.-a., Geng, J., Hua, W., Hu, M., Juan, X., Liu, H., Liu,
> S., Qiu, J., Qi, X., Wu, Y., et al. A survey of self-evolving
> agents: On path to artificial super intelligence. _arXiv_
> _preprint arXiv:2507.21046_, 2025.
> 
> 
> 
> 9
> 
> 
> **SKILLRL: Evolving Agents via Recursive Skill-Augmented Reinforcement Learning**
> 
> 
> 
> Google. Try deep research and our new experimental model in gemini, your ai assistant,
> 2024. URL [https://blog.google/products/](https://blog.google/products/gemini/google-gemini-deep-research/)
> [gemini/google-gemini-deep-research/.](https://blog.google/products/gemini/google-gemini-deep-research/)
> 
> 
> Google. Introducing the gemini 2.5 computer
> use model, 2025. URL [https://blog.](https://blog.google/technology/google-deepmind/gemini-computer-use-model/)
> [google/technology/google-deepmind/](https://blog.google/technology/google-deepmind/gemini-computer-use-model/)
> [gemini-computer-use-model/.](https://blog.google/technology/google-deepmind/gemini-computer-use-model/)
> 
> 
> Guo, D., Yang, D., Zhang, H., Song, J., Zhang, R., Xu, R.,
> Zhu, Q., Ma, S., Wang, P., Bi, X., et al. Deepseek-r1: Incentivizing reasoning capability in llms via reinforcement
> learning. _arXiv preprint arXiv:2501.12948_, 2025.
> 
> 
> Ho, X., Nguyen, A.-K. D., Sugawara, S., and Aizawa, A.
> Constructing a multi-hop qa dataset for comprehensive
> evaluation of reasoning steps. In _Proceedings of the 28th_
> _International Conference on Computational Linguistics_,
> pp. 6609–6625, 2020.
> 
> 
> Hu, Y., Liu, S., Yue, Y., Zhang, G., Liu, B., Zhu, F., Lin, J.,
> Guo, H., Dou, S., Xi, Z., et al. Memory in the age of ai
> agents. _arXiv preprint arXiv:2512.13564_, 2025.
> 
> 
> Jin, B., Zeng, H., Yue, Z., Yoon, J., Arik, S., Wang, D.,
> Zamani, H., and Han, J. Search-r1: Training llms to
> reason and leverage search engines with reinforcement
> learning. _arXiv preprint arXiv:2503.09516_, 2025.
> 
> 
> Joshi, M., Choi, E., Weld, D. S., and Zettlemoyer, L. Triviaqa: A large scale distantly supervised challenge dataset
> for reading comprehension. In _Proceedings of the 55th_
> _Annual_ _Meeting_ _of_ _the_ _Association_ _for_ _Computational_
> _Linguistics_ _(Volume_ _1:_ _Long_ _Papers)_, pp. 1601–1611,
> 2017.
> 
> 
> Kwiatkowski, T., Palomaki, J., Redfield, O., Collins, M.,
> Parikh, A., Alberti, C., Epstein, D., Polosukhin, I., Devlin,
> J., Lee, K., et al. Natural questions: a benchmark for question answering research. _Transactions of the Association_
> _for Computational Linguistics_, 7:453–466, 2019.
> 
> 
> Li, G., Hammoud, H., Itani, H., Khizbullin, D., and Ghanem,
> B. Camel: Communicative agents for” mind” exploration
> of large language model society. _Advances_ _in_ _Neural_
> _Information Processing Systems_, 36:51991–52008, 2023.
> 
> 
> Li, X., Dong, G., Jin, J., Zhang, Y., Zhou, Y., Zhu, Y., Zhang,
> P., and Dou, Z. Search-o1: Agentic search-enhanced
> large reasoning models. _arXiv preprint arXiv:2501.05366_,
> 2025.
> 
> 
> Liu, J., Xiong, K., Xia, P., Zhou, Y., Ji, H., Feng, L., Han,
> S., Ding, M., and Yao, H. Agent0-vl: Exploring selfevolving agent for tool-integrated vision-language reasoning. _arXiv preprint arXiv:2511.19900_, 2025.
> 
> 
> 10
> 
> 
> 
> Liu, J., Su, Y., Xia, P., Han, S., Zheng, Z., Xie, C., Ding, M.,
> and Yao, H. Simplemem: Efficient lifelong memory for
> llm agents. _arXiv preprint arXiv:2601.02553_, 2026.
> 
> 
> Mallen, A., Asai, A., Zhong, V., Das, R., Khashabi, D., and
> Hajishirzi, H. When not to trust language models: Investigating effectiveness of parametric and non-parametric
> memories. In _Proceedings of the 61st Annual Meeting of_
> _the Association for Computational Linguistics (Volume 1:_
> _Long Papers)_, pp. 9802–9822, 2023.
> 
> 
> OpenAI. Gpt-4o system card, 2024. [https://openai.](https://openai.com/index/gpt-4o-system-card/)
> [com/index/gpt-4o-system-card/.](https://openai.com/index/gpt-4o-system-card/)
> 
> 
> OpenAI. Introducing o3 and o4-mini,
> 2025a. [https://openai.com/index/](https://openai.com/index/introducing-o3-and-o4-mini/)
> [introducing-o3-and-o4-mini/.](https://openai.com/index/introducing-o3-and-o4-mini/)
> 
> 
> OpenAI. Openai deep research system card,
> 2025b. URL [https://openai.com/index/](https://openai.com/index/introducing-deep-research/)
> [introducing-deep-research/.](https://openai.com/index/introducing-deep-research/)
> 
> 
> OpenAI. Openai computer-using agent, 2025c.
> URL [https://openai.com/index/](https://openai.com/index/computer-using-agent/)
> [computer-using-agent/.](https://openai.com/index/computer-using-agent/)
> 
> 
> Ouyang, L., Wu, J., Jiang, X., Almeida, D., Wainwright, C.,
> Mishkin, P., Zhang, C., Agarwal, S., Slama, K., Ray, A.,
> et al. Training language models to follow instructions
> with human feedback. _Advances in neural information_
> _processing systems_, 35:27730–27744, 2022.
> 
> 
> Ouyang, S., Yan, J., Hsu, I., Chen, Y., Jiang, K., Wang,
> Z., Han, R., Le, L. T., Daruki, S., Tang, X., et al. Reasoningbank: Scaling agent self-evolving with reasoning
> memory. _arXiv preprint arXiv:2509.25140_, 2025.
> 
> 
> Parisi, G. I., Kemker, R., Part, J. L., Kanan, C., and Wermter,
> S. Continual lifelong learning with neural networks: A
> review. _Neural networks_, 113:54–71, 2019.
> 
> 
> Press, O., Zhang, M., Min, S., Schmidt, L., Smith, N. A.,
> and Lewis, M. Measuring and narrowing the compositionality gap in language models. In _Findings of the As-_
> _sociation for Computational Linguistics:_ _EMNLP 2023_,
> pp. 5687–5711, 2023.
> 
> 
> Schulman, J., Wolski, F., Dhariwal, P., Radford, A., and
> Klimov, O. Proximal policy optimization algorithms.
> _arXiv preprint arXiv:1707.06347_, 2017.
> 
> 
> Shao, Z., Wang, P., Zhu, Q., Xu, R., Song, J., Bi, X., Zhang,
> H., Zhang, M., Li, Y., Wu, Y., et al. Deepseekmath: Pushing the limits of mathematical reasoning in open language
> models. _arXiv preprint arXiv:2402.03300_, 2024.
> 
> 
> Shinn, N., Cassano, F., Gopinath, A., Narasimhan, K., and
> Yao, S. Reflexion: Language agents with verbal reinforcement learning. _Advances_ _in_ _Neural_ _Information_
> _Processing Systems_, 36:8634–8652, 2023.
> 
> 
> **SKILLRL: Evolving Agents via Recursive Skill-Augmented Reinforcement Learning**
> 
> 
> 
> Shridhar, M., Yuan, X., Cote, M.-A., Bisk, Y., Trischler, A.,
> and Hausknecht, M. Alfworld: Aligning text and embodied environments for interactive learning. In _International_
> _Conference on Learning Representations_ .
> 
> 
> Sun, H., Qiao, Z., Guo, J., Fan, X., Hou, Y., Jiang, Y., Xie,
> P., Zhang, Y., Huang, F., and Zhou, J. Zerosearch: Incentivize the search capability of llms without searching.
> _arXiv preprint arXiv:2505.04588_, 2025.
> 
> 
> Tang, X., Qin, T., Peng, T., Zhou, Z., Shao, D., Du, T., Wei,
> X., Xia, P., Wu, F., Zhu, H., et al. Agent kb: Leveraging
> cross-domain experience for agentic problem solving.
> _arXiv preprint arXiv:2507.06229_, 2025.
> 
> 
> Team, T. D., Li, B., Zhang, B., Zhang, D., Huang, F., Li, G.,
> Chen, G., Yin, H., Wu, J., Zhou, J., et al. Tongyi deepresearch technical report. _arXiv preprint arXiv:2510.24701_,
> 2025.
> 
> 
> Trivedi, H., Balasubramanian, N., Khot, T., and Sabharwal,
> A. Musique: Multihop questions via single-hop question composition. _Transactions_ _of_ _the_ _Association_ _for_
> _Computational Linguistics_, 10:539–554, 2022.
> 
> 
> Wang, G., Xie, Y., Jiang, Y., Mandlekar, A., Xiao, C., Zhu,
> Y., Fan, L., and Anandkumar, A. Voyager: An open-ended
> embodied agent with large language models. _Transac-_
> _tions on Machine Learning Research_ .
> 
> 
> Wang, Y. _From Static Parameters to Updatable Memory:_
> _Enabling_ _Large_ _Language_ _Model_ _Agents_ _to_ _Remember,_
> _Adapt, and Learn_ . PhD thesis, University of California,
> San Diego, 2025.
> 
> 
> Wang, Y. and Chen, X. Mirix: Multi-agent memory system
> for llm-based agents. _arXiv preprint arXiv:2507.07957_,
> 2025.
> 
> 
> Wang, Y., Takanobu, R., Liang, Z., Mao, Y., Hu, Y.,
> McAuley, J., and Wu, X. Mem- _{\_ alpha _}_ : Learning
> memory construction via reinforcement learning. _arXiv_
> _preprint arXiv:2509.25911_, 2025.
> 
> 
> Wang, Z. Z., Mao, J., Fried, D., and Neubig, G. Agent
> workflow memory. _arXiv_ _preprint_ _arXiv:2409.07429_,
> 2024.
> 
> 
> Wei, T., Sachdeva, N., Coleman, B., He, Z., Bei, Y., Ning,
> X., Ai, M., Li, Y., He, J., Chi, E. H., et al. Evo-memory:
> Benchmarking llm agent test-time learning with selfevolving memory. _arXiv_ _preprint_ _arXiv:2511.20857_,
> 2025.
> 
> 
> Wei, T., Li, T.-W., Liu, Z., Ning, X., Yang, Z., Zou, J., Zeng,
> Z., Qiu, R., Lin, X., Fu, D., et al. Agentic reasoning for
> large language models. _arXiv preprint arXiv:2601.12538_,
> 2026.
> 
> 
> 
> Wu, Q., Bansal, G., Zhang, J., Wu, Y., Li, B., Zhu, E., Jiang,
> L., Zhang, X., Zhang, S., Liu, J., et al. Autogen: Enabling
> next-gen llm applications via multi-agent conversations.
> In _First Conference on Language Modeling_, 2024.
> 
> 
> Wu, R., Wang, X., Mei, J., Cai, P., Fu, D., Yang, C., Wen, L.,
> Yang, X., Shen, Y., Wang, Y., et al. Evolver: Self-evolving
> llm agents through an experience-driven lifecycle. _arXiv_
> _preprint arXiv:2510.16079_, 2025.
> 
> 
> Xia, P., Zeng, K., Liu, J., Qin, C., Wu, F., Zhou, Y.,
> Xiong, C., and Yao, H. Agent0: Unleashing self-evolving
> agents from zero data via tool-integrated reasoning. _arXiv_
> _preprint arXiv:2511.16043_, 2025.
> 
> 
> Yang, Z., Qi, P., Zhang, S., Bengio, Y., Cohen, W., Salakhutdinov, R., and Manning, C. D. Hotpotqa: A dataset for
> diverse, explainable multi-hop question answering. In
> _Proceedings of the 2018 conference on empirical methods_
> _in natural language processing_, pp. 2369–2380, 2018.
> 
> 
> Yao, S., Chen, H., Yang, J., and Narasimhan, K. Webshop: Towards scalable real-world web interaction with
> grounded language agents. _Advances in Neural Informa-_
> _tion Processing Systems_, 35:20744–20757, 2022a.
> 
> 
> Yao, S., Zhao, J., Yu, D., Du, N., Shafran, I., Narasimhan,
> K. R., and Cao, Y. React: Synergizing reasoning and
> acting in language models. In _The eleventh international_
> _conference on learning representations_, 2022b.
> 
> 
> Zhang, G., Fu, M., Wan, G., Yu, M., Wang, K., and Yan, S.
> G-memory: Tracing hierarchical memory for multi-agent
> systems. _arXiv preprint arXiv:2506.07398_, 2025a.
> 
> 
> Zhang, G., Ren, H., Zhan, C., Zhou, Z., Wang, J., Zhu, H.,
> Zhou, W., and Yan, S. Memevolve: Meta-evolution of
> agent memory systems. _arXiv preprint arXiv:2512.18746_,
> 2025b.
> 
> 
> Zhang, S., Wang, J., Zhou, R., Liao, J., Feng, Y., Zhang,
> W., Wen, Y., Li, Z., Xiong, F., Qi, Y., et al. Memrl:
> Self-evolving agents via runtime reinforcement learning
> on episodic memory. _arXiv preprint arXiv:2601.03192_,
> 2026.
> 
> 
> Zhao, A., Huang, D., Xu, Q., Lin, M., Liu, Y.-J., and Huang,
> G. Expel: Llm agents are experiential learners. In _Pro-_
> _ceedings_ _of_ _the_ _AAAI_ _Conference_ _on_ _Artificial_ _Intelli-_
> _gence_, volume 38, pp. 19632–19642, 2024.
> 
> 
> Zheng, X., An, K., Wang, Z., Wang, Y., and Wu, Y.
> Stepsearch: Igniting llms search ability via step-wise
> proximal policy optimization. In _Proceedings of the 2025_
> _Conference on Empirical Methods in Natural Language_
> _Processing_, pp. 21816–21841, 2025.
> 
> 
> 
> 11
> 
> 
> **SKILLRL: Evolving Agents via Recursive Skill-Augmented Reinforcement Learning**
> 
> 
> **Appendix**
> 
> 
> **A. Prompts**
> 
> 
> In this section, we provide the full prompt templates used throughout the different phases of our framework. These templates
> are designed to ensure consistent agent behavior and structured data generation across various environments.
> 
> 
> **A.1. Agent Execution Prompts**
> 
> 
> The following prompts are used during the online inference phase. These templates provide the agent with the current task
> description, a history of previous interactions, and a set of retrieved skills (experiences) to guide its decision-making process.
> The prompts explicitly enforce a Chain-of-Thought (CoT) reasoning step before action selection.
> 
> 
> **Prompt A.1:** **ALFWorld Agent Execution with Skills**
> **System Prompt:**
> You are an expert agent operating in the ALFRED Embodied Environment. Your task is to: _{_ task ~~d~~ escription _}_
> 
> 
> **## Retrieved Relevant Experience**
> _{_ retrieved ~~m~~ emories _}_
> 
> 
> **## Current Progress**
> Prior to this step, you have already taken _{_ step ~~c~~ ount _}_ step(s). Below are the most recent _{_ history ~~l~~ ength _}_ observations
> and the corresponding actions you took: _{_ action ~~h~~ istory _}_
> You are now at step _{_ current ~~s~~ tep _}_ and your current observation is: _{_ current ~~o~~ bservation _}_
> Your admissible actions of the current situation are: [ _{_ admissible ~~a~~ ctions _}_ ].
> 
> 
> Now it’s your turn to take an action. You should first reason step-by-step about the current situation. This reasoning process **MUST**
> be enclosed within <think> </think> tags. Once you’ve finished your reasoning, you should choose an admissible action for
> current step and present it within <action> </action> tags.
> 
> 
> **Prompt A.2:** **WebShop Agent Execution with Skills**
> **System Prompt:**
> You are an expert autonomous agent operating in the WebShop e-commerce environment. Your task is to: _{_ task ~~d~~ escription _}_ .
> 
> 
> **## Retrieved Relevant Experience**
> _{_ retrieved ~~m~~ emories _}_
> 
> 
> **## Current Progress**
> Prior to this step, you have already taken _{_ step ~~c~~ ount _}_ step(s). Below are the most recent _{_ history ~~l~~ ength _}_ observations
> and the corresponding actions you took: _{_ action ~~h~~ istory _}_
> You are now at step _{_ current ~~s~~ tep _}_ and your current observation is: _{_ current ~~o~~ bservation _}_
> Your admissible actions of the current situation are: [ _{_ available ~~a~~ ctions _}_ ].
> 
> 
> Now it’s your turn to take one action for the current step. You should first reason step-by-step about the current situation, then think
> carefully which admissible action best advances the shopping goal. This reasoning process **MUST** be enclosed within <think>
> </think> tags. Once you’ve finished your reasoning, you should choose an admissible action for current step and present it within
> <action> </action> tags.
> 
> 
> **A.2. Skill Generation and Distillation Prompts**
> 
> 
> These prompts are utilized during the skill discovery and library initialization phases. They guide a high-capability teacher
> model to analyze interaction trajectories, identify failure modes, and distill reusable, actionable skills into a structured JSON
> format.
> 
> 
> 12
> 
> 
> **SKILLRL: Evolving Agents via Recursive Skill-Augmented Reinforcement Learning**
> 
> 
> **Prompt B.1:** **Dynamic Skill Discovery from Failures**
> Analyze these failed _{_ env ~~d~~ escription _}_ agent trajectories and suggest NEW skills to add.
> 
> 
> **FAILED TRAJECTORIES:** _{_ failure ~~e~~ xamples _}_
> **EXISTING SKILL TITLES:** _{_ existing ~~t~~ itles _}_
> 
> 
> Generate 1-3 NEW actionable skills that would help avoid these failures. Each skill must have: skill ~~i~~ d, title (3-5 words),
> principle (1-2 sentences), when ~~t~~  - ~~a~~ pply. The skill ~~i~~ d should be unique and follow the pattern: ”dyn ~~0~~ 01”, ”dyn ~~0~~ 02”,
> etc.
> 
> 
> Return ONLY a JSON array of skills, no other text.
> 
> 
> **Prompt B.2:** **Initial Skill Distillation (ALFWorld)**
> You are an expert at distilling agent behavior patterns into concise, actionable skills. Analyze these successful and failed trajectories
> from an embodied AI agent operating in household environments (ALFWorld).
> 
> 
> **SUCCESSFUL TRAJECTORIES:** _{_ success ~~p~~ atterns _}_
> **FAILED TRAJECTORIES:** _{_ failure ~~p~~ atterns _}_
> 
> 
> Generate 8-12 GENERAL SKILLS that apply across ALL task types. These should be: 1. **Concise** ; 2. **Actionable** ; 3. **Transferable** ;
> 4. **Failure-aware** . Focus on: Navigation, object manipulation, state tracking, error recovery, and container interaction rules.
> 
> 
> Return ONLY the JSON array, no other text.
> 
> 
> **Prompt B.3:** **Initial Skill Distillation (WebShop)**
> You are an expert at distilling agent behavior patterns into concise, actionable skills. Analyze these successful and failed trajectories
> from an AI agent operating in an online shopping environment (WebShop).
> 
> 
> **SUCCESSFUL TRAJECTORIES:** _{_ success ~~p~~ atterns _}_
> **FAILED TRAJECTORIES:** _{_ failure ~~p~~ atterns _}_
> 
> 
> Generate 10-15 GENERAL SKILLS. Focus on: Search query formulation, product selection heuristics, option configuration (size,
> color, etc.), constraint verification, navigation patterns, and price handling.
> 
> 
> Return ONLY the JSON array, no other text.
> 
> 
> **A.3. Cold-start Trajectory Generation Prompts**
> 
> 
> To bridge the gap between a base model and the target performance, we use the following prompts to generate high-quality
> synthetic trajectories for Supervised Fine-Tuning (SFT). These prompts instruct the teacher model to solve tasks while
> explicitly demonstrating the application of specific skills, thereby providing a clear learning signal for the student model.
> 
> 
> **Prompt C.1:** **Synthetic Trajectory Generation (ALFWorld)**
> You are an expert agent in the ALFRED embodied environment. You will be given a task and relevant skills to apply. Your goal is to
> generate a successful trajectory that demonstrates proper use of these skills.
> 
> 
> You should generate a step-by-step trajectory that:
> 1. Uses the provided skills appropriately;
> 2. Takes realistic actions in the environment;
> 3. Completes the task successfully;
> 4. Demonstrates good planning and systematic exploration.
> 
> 
> For each step, you should:
> 
> _•_ Think through the current situation using <think></think> tags.
> 
> _•_ Choose an appropriate action using <action></action> tags.
> 
> _•_ The action should be a simple command like ”go to cabinet 1”, ”open drawer 2”, ”take apple 1”, ”put apple 1 in/on countertop 1”.
> 
> 
> Generate a complete trajectory from start to fnish. Stop when the task is complete.
> 
> 
> 13
> 
> 
> **SKILLRL: Evolving Agents via Recursive Skill-Augmented Reinforcement Learning**
> 
> 
> **Prompt C.2:** **Synthetic Trajectory Generation (WebShop)**
> You are an expert shopping agent in the WebShop e-commerce environment. You will be given a shopping task and relevant skills to
> apply. Your goal is to generate a successful trajectory that demonstrates proper use of these skills.
> 
> 
> You should generate a step-by-step trajectory that:
> 1. Uses the provided skills appropriately;
> 2. Takes realistic actions in the WebShop environment;
> 3. Successfully finds and purchases the requested product;
> 4. Demonstrates good search strategies and product evaluation.
> 
> 
> For each step, you should:
> 
> _•_ Think through the current situation using <think></think> tags.
> 
> _•_ Choose an appropriate action using <action></action> tags.
> 
> _•_ Actions can be: search[query], click[element], or buy now.
> 
> 
> Generate a complete trajectory from start to fnish. Stop when the purchase is complete.
> 
> 
> **B. Additional Experimental Details**
> 
> 
> **B.1. Hyperparameters**
> 
> 
> _Table 4._ Hyperparameters for SKILLRL.
> 
> 
> Hyperparameter Value
> 
> 
> _Cold-Start SFT_
> Learning rate 1 _×_ 10 _[−]_ [4]
> 
> Batch size 16
> Epochs 3
> SFT examples 7,500 (AlfWorld) / 2,400 (WebShop)
> 
> 
> _RL Training_
> Learning rate 1 _×_ 10 _[−]_ [6]
> 
> Batch size 64
> KL loss Coef 0.01
> Invalid Action Penalty Coef 0.1
> Max Prompt Length 6,000
> Max Response Length 1,024
> Epoch 150
> 
> 
> _Skill Retrieval_
> Top-K retrieval 6
> Validation interval 5 Steps
> Update Threshold _δ_ 0.4
> Max failures analyzed 10 (SR _<_ 0.4) / 5 (SR _>_ 0.4)
> Max new skills per evolution 3
> 
> 
> **B.2. Compute Resources**
> 
> 
> All experiments were conducted on a cluster with 8 NVIDIA H100 80GB GPUs. Training times:
> 
> 
>   - Trajectory collection: 3 hours
> 
> 
>   - Skill distillation: 0.5 hours
> 
> 
>   - Cold-start SFT: 2 hour
> 
> 
>   - RL training: 24 hours
> 
> 
> 14
> 
> 
> **SKILLRL: Evolving Agents via Recursive Skill-Augmented Reinforcement Learning**
> 
> 
> _Table 5._ Example distilled skills from SKILLBANK for ALFWorld (Shridhar et al.). This table summarizes general patterns and application
> logic derived from raw trajectories.
> 
> 
> **ID** **Skill Title** **Principle (Actionable Pattern)** **When to Apply**
> 
> 
> _General Exploration & Acquisition Skills_
> gen ~~0~~ 01 Systematic Exploration Search every plausible surface or container exactly once before Anytime the goal count is not
> revisiting; prioritize unseen locations. met and unexplored areas remain.
> gen ~~0~~ 02 Immediate Acquisition As soon as a required object becomes visible and reachable, Upon first visual confirmation
> take it immediately. of a goal-relevant object.
> gen ~~0~~ 03 Destination First Policy After picking up a goal object, navigate directly to the known Holding any goal object while
> target receptacle and place it. target location is identified.
> 
> 
> _State-Changing & Spatial Relation Skills_
> gen ~~0~~ 05 Use State-Changing Acquire the object, then immediately use the nearest suitable After picking up an object reTools Early appliance (heat/cool/clean) before placement. quiring temperature or cleanliness change.
> gen ~~0~~ 06 Establish Spatial Rela- First locate the reference object, adjust its state if needed, then Tasks containing prepositions
> tions search or place in the specified region. like “under”, “inside”, or “on”.
> 
> 
> _Reliability & Error Recovery_
> gen ~~0~~ 14 Loop Escape Trigger If the last 3–5 actions do not change the state, switch to an After several consecutive nountried search branch or action type. progress observations.
> gen ~~0~~ 15 Pre-Action Sanity Confirm prerequisites (hand free, capacity, power) before exe- Right before issuing any comCheck cuting manipulative commands. mand that could legally fail.
> 
> 
> _Table 6._ Common Agent Failures and Mitigation Strategies for ALFWorld.
> 
> 
> **ID** **Failure Description** **Root Cause (Why it happens)** **Mitigation (How to avoid)**
> 
> 
> err ~~0~~ 01 Redundant Revisit Lacks explicit memory of explored areas; strat- Maintain an exploration map; prioritize unvisegy degenerates into local loops. ited candidates.
> err ~~0~~ 06 Skipping State Changes Conflates object presence with goal satisfac- Integrate state precondition checks into the
> tion; omits cleanliness/temp checks. planner before placement.
> 
> 
> Total wall-clock time: approximately 30 hours per experiment.
> 
> 
> **C. Illustration of Skill Library**
> 
> 
> In this section, we provide some example catalog of distilled skills and error taxonomies for both the ALFWorld and
> WebShop environments. Tables 5 and 7 detail the general skills distilled for embodied manipulation and web-based
> shopping, respectively, highlighting the actionable principles required for systematic exploration and constraint satisfaction.
> Furthermore, we provide a structured analysis of failure cases in Table 6 and Table 8, which categorizes common mistakes,
> ranging from spatial reasoning loops in ALFWorld to price-shift oversights in WebShop, alongside their root causes and
> proposed mitigation strategies.
> 
> 
> 15
> 
> 
> **SKILLRL: Evolving Agents via Recursive Skill-Augmented Reinforcement Learning**
> 
> 
> _Table 7._ Example distilled skills for WebShop Navigation (Yao et al., 2022a). These skills represent the strategic patterns used by the
> agent to handle large-scale product search and constraint satisfaction.
> 
> 
> **ID** **Skill Title** **Principle (Actionable Pattern)** **When to Apply**
> 
> 
> _Search & Query Engineering_
> gen ~~0~~ 01 Prioritize Core Keywords Include product type, 1-2 functional attributes, and hard Before issuing the first search or reconstraints; omit secondary descriptors. fining over-specific queries.
> gen ~~0~~ 02 Iterative Refinement Adjust keywords or apply site filters instead of repeat- When results are irrelevant or repeat
> ing the same failed query. despite multiple searches.
> 
> 
> _Product Evaluation & Verification_
> gen ~~0~~ 03 Scan Before You Click Read titles, thumbnails, and prices in results to ensure On search results pages when choosplausibility before opening a link. ing the next product to inspect.
> gen ~~0~~ 04 Verify Early, Abort Fast Immediately check category, attributes, and price on Within the first observation on every
> the product page; leave if any constraint is violated. product detail page.
> gen ~~0~~ 06 Confirm Hidden Attributes Open Description/Features sections to ensure non- When constraints are not evident
> visible specs (e.g., material) meet constraints. from the title or variant list.
> 
> 
> _Configuration & Transaction_
> gen ~~0~~ 05 Set Mandatory Variants Always select required options (size, color, etc.) before After confirming product match but
> evaluating price or purchasing. before any purchase action.
> gen ~~0~~ 07 Check Variant Pricing For price ranges, select the exact variant combination Whenever price changes with varito verify the specific price is within budget. ant selection or shows as a range.
> gen ~~0~~ 13 Purchase Decisively Execute ’Buy Now’ immediately once all constraints After validating every constraint on
> and prices are confirmed on a variant. the current product variant.
> 
> 
> _Table 8._ Common Failures in Web-based Shopping Tasks.
> 
> 
> **ID** **Failure Description** **Root Cause** **Mitigation Strategy**
> 
> 
> err ~~0~~ 01 Missing Constraints in Omits size or price caps, leading to over- Assemble full requirement list first; ensure
> Query whelming or irrelevant result sets. every hard constraint is in the query string.
> err ~~0~~ 04 Price Shift Oversight Fails to notice price changes after selecting a Re-read the price element after every option
> specific size or color variant. change before proceeding to checkout.
> err ~~0~~ 05 Premature Purchase Clicks “Buy Now” without setting mandatory Validate that every required dropdown/radio
> variants, leading to errors or wrong items. option is explicitly selected before buying.
> err ~~0~~ 09 Ignoring Stock Status Attempts to purchase out-of-stock items by Verify that the ’Add to Cart’ button is enabled
> ignoring disabled buttons or stock labels. and no ’Out of Stock’ message is present postselection.
> err ~~0~~ 11 Sponsored Link Distraction Clicks loosely matched ads, diverting the Implement ad-label detection; prioritize orworkflow from organic, suitable products. ganic listings for higher constraint reliability.
> 
> 
> 16
> 
> 
> **SKILLRL: Evolving Agents via Recursive Skill-Augmented Reinforcement Learning**
> 
> 
> **D. Additional Cases**
> 
> 
> 
> 
> 
> 17
> 
> 
> **SKILLRL: Evolving Agents via Recursive Skill-Augmented Reinforcement Learning**
> 
> 
> 
> 
> 
> 
> 
> 18
> 
> 
> 
> [Source: SKILLRL: Evolving Agents via Recursive Skill-Augmented Reinforcement Learning](https://arxiv.org/abs/2602.03665)
