---
created: 2026-03-22
description: AgentGen uses LLMs to automatically generate diverse environments from an inspiration corpus and creates smoothly difficulty-graded planning tasks via bidirectional evolution, enabling scalable agent training data synthesis.
source: https://arxiv.org/abs/2408.00764
type: paper
---

## Key Takeaways

AgentGen addresses a bottleneck that most agent training papers take for granted: where do diverse environments and tasks actually come from? While [[PAIRED uses antagonist regret to auto-generate perfectly calibrated training environments|PAIRED]], [[PLR improves RL generalization by prioritizing training levels with high estimated learning potential|PLR]], and [[ACCEL compounds environment complexity through evolution guided by regret-based curation|ACCEL]] assume a parameterized environment exists, AgentGen generates the environments themselves using LLMs. The framework expands from a handful of manually designed environments (typical in prior agent training work) to 592 automatically generated ones, each with 20 tasks -- a qualitative leap in diversity.

The environment generation pipeline uses an "inspiration corpus" (LIMA) to seed diverse environment specifications. A random text segment like "How to boost your diet with peanut butter powder?" prompts the LLM to generate a related environment where an agent operates as a nutritionist. This overcomes the inductive bias of LLMs that makes them generate repetitive environments when prompted in a zero-shot manner. The generated specification is then implemented as PDDL code, with syntax validation providing iterative feedback. An environment library provides expanding in-context examples, creating a self-improving loop reminiscent of how [[Absolute Zero]] bootstraps its own training data.

The central algorithmic contribution is Bi-Evol (bidirectional evolution), which evolves seed tasks in both easier and harder directions. This is critical because, unlike instruction-following where models handle simple cases well, LLM agents often fail even on easy planning tasks. Easy-evol simplifies goal conditions so agents can learn basic mechanics; hard-evol adds complexity to push capability boundaries. The resulting smooth difficulty curve means the training set spans the full range from trivial to challenging, allowing agents to bootstrap from simple successes into complex behaviors. This bidirectional approach contrasts with [[AgentFrontier synthesizes training data at the boundary of what LLMs can and cannot do|AgentFrontier]]'s purely upward escalation and [[ACCEL compounds environment complexity through evolution guided by regret-based curation|ACCEL]]'s start-simple inductive bias.

The results validate the approach convincingly: AGENTGEN-tuned Llama-3.1-8B outperforms GPT-3.5 on planning tasks, and the 70B version exceeds GPT-4 and sets a new state-of-the-art. Crucially, improvements generalize to out-of-domain tasks (Alfworld, BabyAI, Jericho) implemented in Python rather than PDDL, demonstrating that the planning capabilities transfer across implementation substrates. The robustness across different base models (Llama-3, CodeLlama, Mistral) further confirms the dataset quality.

In the GAN-like adversarial framing, AgentGen's contribution is on the environment generation side. While it doesn't use an explicit adversarial signal for calibration (relying instead on the evolution mechanism and an optimal planner for trajectory quality), the bidirectional evolution creates a natural tension between simplification and complexification that mirrors the generator-discriminator dynamic. The inspiration corpus acts as a diversity prior, and the PDDL planner acts as a verifier ensuring task solvability -- functionally similar to how [[Prover-Verifier Games]] and [[Math-Shepherd]] use verification to ensure training signal quality.

The limitation is that AgentGen relies on a domain-independent planner (FastDownward) for trajectory synthesis, which restricts it to deterministic, fully-observable planning. Extending to partially-observable or stochastic environments would require different trajectory generation approaches. Nevertheless, as the first framework for fully automatic environment and task generation for agent training, AgentGen opens a new dimension in the curriculum design space that complements the level-curation approaches of the PAIRED-PLR-ACCEL lineage.

## External Resources

- [Project page](https://agent-gen.github.io/) -- AgentGen project page

## Original Content

> [!quote]- Full Paper Text
> ## **AGENTGEN: Enhancing Planning Abilities for Large** **Language Model based Agent via Environment and** **Task Generation**
> 
> **Mengkang Hu** [1] **, Pu Zhao** [2] **, Can Xu** [2] **, Qingfeng Sun** [2] **, Jianguang Lou** [2] **, Qingwei Lin** [2] **,**
> **Ping Luo** [1], **Saravan Rajmohan** [2]
> 
> 1The University of Hong Kong 2 Microsoft Corporation
> `{v-humengkang,puzhao}@microsoft.com`, `pluo.lhi@gmail.com`,
> ```
>          {caxu,qins,jlou,qlin,saravar}@microsoft.com
> 
> ```
> 
> **Abstract**
> 
> 
> Large Language Model (LLM) based agents have garnered significant attention
> and are becoming increasingly popular. Furthermore, _planning_ ability is a crucial
> component of an LLM-based agent, involving interaction with the _environment_ and
> executing actions to complete a _planning task_, which generally entails achieving a
> desired goal from an initial state. This paper investigates enhancing the planning
> abilities of LLM-based agents through instruction tuning, referred to as _agent_
> _training_ . Recent studies on agent training have demonstrated that utilizing expertlevel trajectory data (sequences of action-observation pairs) for instruction-tuning
> LLMs effectively enhances their planning capabilities. However, existing work
> primarily focuses on synthesizing trajectories from manually designed planning
> tasks and environments. The labor-intensive nature of creating these environments
> and tasks impedes the generation of sufficiently varied and extensive trajectories
> for agent training. To address this limitation, this paper explores the automated
> synthesis of diverse environments and a gradual range of planning tasks, from easy
> to difficult. We introduce a framework, AGENTGEN, that leverages LLMs first to
> generate environments and subsequently generate planning tasks conditioned on
> these environments. Specifically, to improve _environmental diversity_, we propose
> using an inspiration corpus composed of various domain-specific text segments
> as the context for synthesizing environments. Moreover, to increase the _difficulty_
> _diversity_ of generated planning tasks, we propose a bidirectional evolution method,
> BI-EVOL, that evolves planning tasks from easier and harder directions to synthesize a task set with a smoother difficulty curve, thereby enhancing the learning
> process of LLMs more effectively. These methods collectively contribute to the
> generation of diverse trajectory data for instruction-tuning. Based on AGENTGEN,
> we greatly expanded the number of environments and planning tasks available for
> agent training. The evaluation results from AgentBoard indicate that AGENTGEN
> greatly enhances the planning capabilities of LLMs. For instance, the AGENTGEN instruction-tuned Llama-3.1-8B outperforms GPT-3.5 in overall performance.
> Moreover, the AGENTGEN-tuned Llama-3.1-70B model achieves state-of-the-art
> results in planning tasks. Project page: [this URL.](https://agent-gen.github.io/)
> 
> 
> **1** **Introduction**
> 
> 
> Recently, owing to advancements in Large Language Models (LLMs) [42, 43, 39, 62], the LLM-based
> Agents have garnered widespread attention from the artificial intelligence community. Generally,
> an LLM-based agent refers to utilizing LLMs to perceive the environment, make decisions, and
> execute actions to substitute or help people accomplish some specific tasks [77, 65, 79]. Furthermore,
> _planning_ is often regarded as one of the most important applications of LLM-based agents, such as
> 
> 
> Accepted by KDD 2025 (Research Track).
> 
> 
> robotic planning [54, 46, 19, 63], travel planning [90, 78], etc. In this study, planning is conceptualized
> as the systematic process of identifying a sequence of executable actions within a given _environment_
> to complete a _planning task_, defined as the transition from an initial state to achieve specified goal
> conditions, considering constraints and available resources [25, 50].
> 
> 
> Improving planning capabilities through instruction-tuning LLMs is a significant research problem,
> referred to as _agent training_ . As shown in Figure 1, similar to imitation learning [23], a typical agent
> training process can be divided into three stages: _(i)_ Preparing environments and planning tasks. _(ii)_
> Synthesizing expert-level trajectories (sequences of action-observation pairs) on these planning tasks.
> For example, utilizing state-of-the-art LLMs (e.g., GPT-4 [43]) as the agent and filtering trajectory
> based on reward score [86, 6]. _(iii)_ Instruction-tuning LLMs with the synthesized trajectory data.
> Recently, the effectiveness of enhancing the planning capabilities of LLMs through agent training
> has been demonstrated by many studies [86, 85, 6, 68, 8, 87, 64, 57]. Despite their success, one key
> limitation of these works is that they primarily rely on manually designed environments and planning
> tasks. The labor-intensive nature of creating environments and planning tasks hinders the generation
> of diverse and extensive trajectory data. More explicitly, designing diverse environments requires
> defining a range of rich and practical scenarios, and implementing these environments typically
> involves the participation of human experts with programming skills. Additionally, formulating tasks
> often demands creating a task set with a gradual difficulty progression. Due to this constraint, existing
> agent training studies typically use only a few environments for data synthesis.
> 
> 
> Figure 1: A typical agent training process includes three stages: task preparation, trajectory synthesis,
> and instruction tuning. AGENTGEN primarily distinguishes itself from existing agent training literature in the task preparation stage, where we introduce a _fully automated_ task generation framework
> AGENTGEN for constructing _diverse_ environments and planning tasks with _gradual learning curves_ .
> 
> 
> To address the aforementioned deficiencies, this paper introduces an automatic framework **AGENT-**
> **GEN** that utilizes LLMs to construct diverse environments and planning tasks for agent training,
> expanding the available environments from a few to hundreds. More specifically, AGENTGEN is
> structured around two stages: (1) _**Environment**_ _**Generation**_ : Achieving sufficient _environmental_
> _diversity_ is essential for creating diverse planning tasks, which involves covering a broad range
> of scenarios and domains. To ensure this, we use an _inspiration corpus_ composed of diverse text
> segments as context for generating environment specifications with LLMs, where actions, restrictions,
> and other details are defined using natural language. For example, in Figure 2, we randomly selected
> a text segment from the inspiration corpus: _“How to boost your diet with peanut butter powder?”_
> This prompted the generation of a related environment specification: _“You are a nutritionist tasked_
> _with creating a new healthy recipe book that incorporates peanut butter powder as a key ingredient”_ .
> Subsequently, we prompt the LLM to produce the corresponding code based on this specification,
> which may be composed of Python, Planning Domain Definition Language (PDDL) [38], or other
> domain-specific languages. Furthermore, we constructed an environment library to serve as in-context
> examples and iteratively expanded it by incorporating high-quality newly generated environments.
> (2) _**Task Generation**_ : Conditioned on the generated environment, we aim to create multiple planning
> tasks. In this stage, it is crucial to have a gradual set of tasks ranging from easy to difficult, i.e.,
> _difficulty_ _diversity_ . To achieve greater difficulty diversity, we propose a bidirectional evolution
> 
> 
> 2
> 
> 
> method, **BI-EVOL**, where the LLM first generates random planning tasks and then evolves these
> tasks by applying constraints towards both simplification and increased difficulty. The created task set
> with BI-EVOL has a smooth difficulty curve that facilitates LLMs’ smoother acquisition of planning
> skills.
> 
> 
> To verify the effectiveness of our method, we synthesized environments and planning tasks based on
> PDDL [38] and constructed a dataset comprising 592 environments, each with 20 tasks. We then
> used a domain-independent planner to obtain 7,246 high-quality trajectories. Subsequently, we used
> this trajectory data for instruction-tuning a series of LLMs and demonstrated the trained model on
> AgentBoard [37]. Since our instruction-tuning dataset is composed of trajectory synthesized from
> PDDL-based planning tasks, we refer to evaluation tasks implemented in PDDL as _in-domain tasks_
> and tasks implemented in other programming languages as _out-of-domain tasks_ . Importantly, this
> evaluation was conducted in a _zero-shot_ manner without utilizing any trajectory data from these
> tasks. Experimental results demonstrate that AGENTGEN achieved more than a tenfold improvement
> over the raw LLama-3.1-8B on in-domain tasks (33.3 vs. 3.0), with overall performance surpassing
> that of GPT-3.5. Furthermore, the performance of AGENTGEN-tuned Llama-3.1-70B exceeded
> GPT-4, setting a new state-of-the-art in planning tasks. In out-of-domain tasks, AGENTGEN also
> demonstrated similar experimental outcomes. Specifically, it led to a significant improvement in
> average success rates, with the raw LLama-3.1-8B model achieving a 10.0% increase and the 70B
> model a 3.7% improvement. In summary, the proposed environment and planning task generation
> method AGENTGEN can help improve planning ability. Moreover, not only can in-domain tasks
> benefit from this, but out-of-domain tasks also improve, which confirms both the effectiveness and
> generalization. Our contributions can be summarized as follows:
> 
> 
>     - We introduce AGENTGEN, which, as far as we know, is the first framework for automatically
> generating diverse planning tasks and environments targeted for LLM-based agent training.
> 
>     - We propose utilizing an inspiration corpus as the context for generating environments with
> LLMs, resulting in 592 diverse environments that encompass a broad range of scenarios.
> 
>     - We propose a bidirectional evolution method BI-EVOL that evolves seed planning tasks in
> both simpler and more complex directions, thereby constructing a task set with a smoother
> difficulty curve.
> 
>     - We constructed an agent instruction-tuning dataset with 7246 high-quality trajectories
> through AGENTGEN. LLMs instruction-tuned with this dataset achieved massive improvement in both in-domain and out-of-domain planning tasks, which validated the effectiveness
> and generalization of AGENTGEN.
> 
> 
> **2** **Preliminary**
> 
> 
> **2.1** **Planning Problems**
> 
> 
> We consider goal-directed deterministic planning problems [50], which are formally defined as a
> tuple _P_ = (T _,_ E), where E denotes the environment in which the agent interacts and T denotes
> the task that the agent needs to complete. Specifically, an environment E typically models a world,
> encompassing the definitions of the action space _A_ and state space _S_, as well as the transition
> function _T_ : _S_ _× A_ _→S_ . Task T is further defined by the tuple T = ( _G,_ _I_ ), where _G_ refers to
> the goal conditions and _I_ refers to initial states of the agent. The initial states _I_ are a subset of
> the state space _Si_ that specifies the starting conditions of the agent. The goal _G_ is a subset of the
> state space _Sg_ that specifies the desired outcomes or conditions. Specifically, _G_ can be expressed as
> _G_ = _{s_ _∈Sg_ _|_ _ϕ_ ( _s_ ) = true _}_ . Here, _ϕ_ ( _s_ ) is a boolean-valued function representing conditions or
> propositions that must be satisfied for the state _s_ to be considered part of the goal set.
> 
> 
> **2.2** **Planning Problem Implementation**
> 
> 
> A planning problem can be implemented with programming languages such as Python or domainspecific languages such as Planning Domain Definition Language (PDDL) [38]. For example, in
> a PDDL-based planning problem, the domain PDDL file can be regarded as the environment E,
> defining states (predicates) and actions and specifying the transition function using preconditions and
> effects of each action. The problem PDDL file, on the other hand, can be seen as the task T. Both
> initial states and goal conditions are typically defined as combinations of predicates. Another widely
> 
> 
> 3
> 
> 
> used programming language for constructing planning problems is Python. For example, in OpenAI
> gym [1], a planning problem will be implemented as a Python class, where the transition function is
> implemented as a method of the class, usually named the "step" or "update" function. Meanwhile,
> the goal _G_ is typically represented as a reward function that indicates the objective of the task, and
> the initial states _I_ are defined in a method named "reset."
> 
> 
> **2.3** **Large Language Model based Agent**
> 
> 
> An LLM-based agent leverages a pre-trained language model to operate within the defined environment E and complete the given task T. Given an environment E, the LLM-based agent perceives its
> state _S_ and takes actions _A_ based on its understanding and processing of the input. The transition
> function _T_ : _S_ _× A_ _→S_ remains consistent, where the LLM-based agent determines the next
> state by generating appropriate actions through natural language processing. The goal _G_ guides the
> LLM-based agent in selecting actions that maximize the reward. The agent utilizes the language
> model to interpret the task requirements and generate actions that align with achieving the specified
> goal. In essence, the LLM-based agent forms a policy _π_ : _S_ _→A_ using the LLM, where _π_ ( _s_ ) is the
> action taken in state _s_ based on the LLM’s understanding and processing of the task.
> 
> 
> **3** **Methodology**
> 
> 
> **Problem** **Definition** The process of generating planning tasks can be formalized as a function
> _f_ : _I_ _→_ (T _,_ E), where _I_ is the input space (e.g., instructions or prompts) and tuple (T _,_ E) is the
> space of all possible planning tasks and environments. Based on the definition in Section 2.1, we
> can express this as _f_ ( _i_ ) = (T _i,_ E _i_ ) _,_ _i_ _∈_ _I_, where T _i_ is the generated planning task and E _i_ is
> the generated environment for a given input _i_ . Our two-stage approach can be further decomposed
> as follows: i) _**Environment Generation**_ (§3.1): In the first stage, we generate the environment E _i_
> based on the input instruction _i_ . This can be represented as E _i_ = _g_ E( _i_ ), where _g_ E is the environment
> generation function that takes the instruction _i_ as input and produces the environment E _i_ . ii) _**Task**_
> _**Generation**_ (§3.2): In the second stage, we generate the task T _i_, conditioned on the environment E _i_
> generated in the first stage. This can be expressed as: T _i_ = _g_ T( _i,_ E _i_ ), where _g_ T is the task generation
> function that takes both the original instruction _i_ and the generated environment E _i_ as inputs to
> produce the task T _i_ . We will detail the implementation of these two stages in the following section.
> 
> 
> **3.1** **Environment Generation**
> 
> 
> Figure 2: Overview of the process of environment generation.
> 
> 
> 1 `[https://www.gymlibrary.dev/index.html](https://www.gymlibrary.dev/index.html)`
> 
> 
> 4
> 
> 
> **Overview** As is shown in Figure 2, we propose a sophisticated framework for environment generation structured around three main components: (1) an _environment specification generation_ module
> where an LLM first generates a specification of the environment, typically including a general
> overview of the environment, descriptions of the state space and action space, and definitions of
> the transition functions; (2) an _environment implementation_ module that generates corresponding
> code based on the environment specification; and (3) an _environment library_ that stores previously
> generated high-quality environments, serving as a comprehensive environment dataset and providing
> in-context examples for generating new environments. Each component will be elaborated on in the
> following paragraph.
> 
> 
> **Environment Specification** We initially prompt the LLM to generate an environment specification, which typically includes an overall depiction of the environment, specific actions and their
> corresponding preconditions and effects, and certain restrictions within the environment. The environment specification will serve as the basis for generating specific environment codes. This
> two-stage approach, similar to the Chain-of-Thought [74], can better assist the LLM in creating
> high-quality environments. For generating environment specifications, One direct approach is to
> prompt LLMs to generate random environments. However, due to the inherent inductive bias of
> LLMs, they struggle to generate diverse environments in this way. Therefore, to address this issue,
> we build an inspiration corpus _D_ = _{t_ 0 _, t_ 1 _, ·, tn}_, containing sufficiently diverse text segments used
> to serve as the "inspiration" for generating environment specification with LLMs. More specifically,
> when generating an environment, we first sample a text segment _ti_ from _D_, then prompt the LLM to
> generate a related environment based on _ti_ . Taking the example in Figure 2, we first sample a text
> segment " _How to boost your diet with peanut butter powder?_ " from _D_ . Then we prompt an LLM
> to generate a related environment where the agent is defined as a nutritionist tasked with creating a
> new healthy recipe book that prominently features peanut butter powder as a key ingredient. This
> approach significantly enhances the diversity of generated environments, thereby empowering more
> generalized agent training. The inspiration corpus can be implemented in various ways, such as using
> a large-scale pre-trained corpus like Common Crawl. Alternatively, a domain-specific corpus, such as
> a code generation dataset [27, 7], can be used to generate environments for a specific domain. This
> paper uses LIMA [93] as the inspiration corpus, an instruction-tuning dataset with sufficient diversity.
> 
> 
> **Environment Implementation** Conditioned on the generated environment specification, we generate its corresponding code, i.e., implementing the environment. This can be formulated as a typical
> code-generation problem with LLMs. We also introduce a validation tool capable of capturing syntax
> errors to provide feedback during the code generation process, thereby iteratively refining it.
> 
> 
> **Environment** **Library** We define the library at iteration _t_ as: _Lt_ = _L_ 0 _∪_ [�] _[t]_ _k_ =1 _[{]_ [E] _[i][|]_ [E] _[i]_ [=]
> _g_ E( _i, Lk−_ 1) _, i ∈_ _Ik, v_ (E _i_ ) = _true}_, where _L_ 0 is the initial seed library, and the union represents all
> verified environments generated up to iteration _t_ . This iterative process allows continuous expansion
> and refinement of the environment library, potentially leading to increasingly complex and diverse
> environments over time.
> 
> 
> **3.2** **Task Generation**
> 
> 
> **Overview** As depicted in Figure 3, conditioned on the generated environments, we prompt LLMs
> to generate corresponding planning tasks. We employ a two-stage generation approach BI-EVOL for
> creating a diverse range of planning tasks in terms of difficulty. We begin by prompting the LLM
> with a specific environment, enabling it to generate an initial set of planning tasks in a zero-shot
> way. Subsequently, we adjust these tasks to make them simpler or more challenging, forming a
> comprehensive set of planning tasks.
> 
> 
> **Bidirectional Evolution** Many studies have proposed evolving instructions, primarily focusing
> on making instructions more difficult [80, 36, 35]. The effectiveness of this approach relies heavily
> on the assumption that LLMs inherently possess the ability to follow simple instructions. However,
> according to findings from some studies [37, 33], LLMs often exhibit poor performance even in
> simple planning tasks. Therefore, we propose **BI-EVOL**, which introduces evolution in two directions:
> easy-evol and hard-evol. Easy-evol typically involves simplifying the goal conditions. The motivation
> is that easier tasks can facilitate learning when the agent performs poorly and cannot directly learn
> from typically difficult goals. Conversely, hard-evol usually involves making the goal conditions
> 
> 
> 5
> 
> 
> Figure 3: Overview of the process of task generation. The two-stage task generation process
> includes first generating unconditioned tasks, then applying BI-EVOL to evolve these planning tasks.
> Ultimately, both parts are incorporated into the task set. In examples of evolving methods, red
> indicates evolution towards more difficult tasks, while green indicates the opposite.
> 
> 
> more complex, increasing the number of steps required for the agent to complete the task. This can
> further enhance the agent’s capability to perform the planning task. To our knowledge, we are the
> first to introduce bidirectional evolution in the agent data generation scenario. The prompt examples
> are shown in Figure 3.
> 
> 
> **4** **Experiments**
> 
> 
> To evaluate the effectiveness of the proposed framework, we synthesize environments and planning
> tasks using the Planning Domain Definition Language (PDDL), a widely adopted programming
> language for planning. Subsequently, we evaluate its performance across various unseen planning
> tasks in a **zero-shot** manner. To validate the effectiveness and generalizability of AGENTGEN,
> we categorized the evaluated tasks into two distinct groups: i) _In-Domain_ _Tasks_ : Planning tasks
> implemented using PDDL. ii) _Out-of-Domain Tasks_ : These comprise tasks developed using other
> programming languages, such as Python.
> 
> 
> **4.1** **Experimental Setup**
> 
> 
> **Evaluation Tasks** For _In-Domain Tasks_, we select four widely used PDDL-based planning tasks:
> Blocksworld, Gripper, Tyreworld, and Barman [37]. More explicitly, Blocksworld requires an agent
> to achieve a target configuration by moving blocks, while Gripper involves moving objects between
> different rooms. Tyreworld simulates changing a car tire, including removing the flat tire, replacing it
> with a spare, and installing the new tire. Barman emulates a bartender’s tasks in mixing cocktails,
> which include combining various ingredients, using shakers, and garnishing drinks. For _Out-of-_
> _Domain_ _Tasks_, we select three challenging partial-observable planning tasks: Alfworld [54] and
> BabyAI [10], Jericho [15]. Alfworld is an environment designed to test agents’ abilities to perform
> everyday household tasks. While in BabyAI, the agent interprets and executes natural language
> instructions in a grid-world setting. Jericho [15] is a collection of text-based interactive fiction games
> in which players issue textual commands to alter the environment.
> 
> 
> **Evaluation Metrics** We utilized two evaluation metrics to evaluate planning ability: _success rate_
> and _progress_ _rate_ [37]. During each interaction round, we assigned a progress rate, denoted as
> _rt_, to measure the progression towards the goal state _g_ . As the agent transitions through states
> _st_ = [ _s_ 0 _, . . ., st_ ], its progress is assessed using a matching score _f_ ( _·, g_ ) _→_ [0 _,_ 1], which quantifies
> the similarity between the current state and the goal state. Initially, _rt_ is set to 0, indicating no
> progress. Only when the progress rate reaches 1 does the success rate attain 1; all other scenarios
> yield a 0 outcome. The success rate reflects the agent’s capacity to complete a comprehensive task.
> 
> 
> 6
> 
> 
> **Baselines** We compare AGENTGEN with a series of widely-used multipurpose foundation models
> that exhibit state-of-the-art performance, such as GPT-3.5 [42] and GPT-4 [44], CodeLlama [48],
> Mistral [24], Llama-2 [62], and Llama-3.1 [39]. We use their instruct-tuned versions for all multipurpose foundation models (§A.1). Additionally, some models have undergone specialized training
> on agent trajectory data, such as AgentLM [86], FireAct [6], Agent-Flan [8]. We also utilize the
> AgentInstruct [86] dataset to train Llama-3.1, following the training configuration of AGENTGEN as
> a baseline model.
> 
> 
> **Implementation** **Details** We followed the environment and task implementation of AgentBoard [37]. For the configuration of evaluation tasks, we employ act-only prompting [82], setting the
> maximum step length for the LLM agent to 30. We selected LIMA [93] as the text corpus _D_ for generating environments, which leverages various data manipulation techniques to ensure a diverse range
> of instructions. For environment generation and task generation, we employ GPT-4 [2], configuring
> the inference parameters with a temperature of 0 and a top_p value of 0.95. Based on AGENTGEN,
> we generated a total of 592 environments. For each environment, we generated ten unconditioned
> tasks, which were then evolved into ten refined tasks using BI-EVOL. To generate trajectory data for
> training, we utilized the domain-independent planner FastDownward [3], ensuring optimal trajectory
> data. This process ultimately led to 7246 trajectories. More details of the dataset can be found in
> Appendix B and C. Since the trajectory data is structured, such as _"pickup(o1)"_, we employ GPT-4 to
> generate a natural language mapping, for example, _"pick up object {arg1}"_, to transform structured
> actions into natural language actions. We detailed the generation of natural language mapping in A.2.
> During the training process, we employed Llama-3.1-8B (base version) as our foundation model,
> blending general instruction data from the ShareGPT dataset in a 1:4 ratio. For the 70B model,
> we selected Llama-3.1-70B-Instruct and trained it using LoRA [17] without incorporating general
> instructions, with a rank of 16. The hyperparameters were configured as follows: a batch size of
> 64, 10 epochs, a context length of 4096 tokens, and no warmup steps. Checkpoints from epochs 5
> through 10 were retained and subsequently evaluated on in-domain tasks. The model demonstrating
> optimal performance was then selected for further evaluation on out-of-domain tasks. We conducted
> all experiments utilizing V100 and A100 GPUs.
> 
> 
> **4.2** **Evaluation on In-Domain Tasks**
> 
> 
> As shown in Table 1, the AGENTGEN-tuned Llama-3.1-8B model outperforms GPT-3.5 in overall
> progress rate (33.3 vs. 25.0). Furthermore, the AGENTGEN-tuned Llama-3.1-70B model slightly
> surpasses GPT-4 (81.5 vs. 81.2). When compared to other models with similar parameter scales,
> AGENTGEN consistently demonstrates superior performance across four distinct tasks. In relation to
> the base Llama-3.1 model, our model exhibits a substantial improvement for both the 8B and 70B
> versions, with overall progress rates increasing by 30.3 and 2.5, respectively. Notably, in tasks where
> the success rate of Llama-3.1-8B is zero, AGENTGEN achieves significant breakthroughs, further
> validating the efficacy of AGENTGEN. From the above, we can draw the following conclusions: _i)_
> AGENTGEN-tuned Llama-3.1-8B outperforms GPT-3.5 in overall performance, while the 70B version
> achieves state-of-the-art results; _ii)_ AGENTGEN-tuned Llama-3.1 has significantly improved both
> success rate and progress rate; _iii)_ AGENTGEN consistently outperforms other models with similar
> parameter scales.
> 
> 
> **4.3** **Robustness**
> 
> 
> To validate the robustness of the constructed dataset with AGENTGEN, we conducted a series of
> experiments to evaluate its performance across different foundation models. We selected several
> widely used 7-8B foundation models, including Llama-3-8B, CodeLLama-7B, and Mistral-7B, to test
> the versatility and effectiveness of AGENTGEN. As is shown in Table 2, all three models exhibited
> significant improvements after training, with Llama-3-8B showing the highest success rate increase of
> 10.0 and CodeLlama-7B demonstrating a maximum progress rate increase of 9.9. These experimental
> results prove that the dataset constructed with AGENTGEN for agent training is highly effective across
> different models.
> 
> 
> 2We applied the gpt-4-20230321 API from Azure OpenAI service.
> 3 `[https://www.fast-downward.org/](https://www.fast-downward.org/)`
> 
> 
> 7
> 
> 
> Table 1: Performance comparison between AGENTGEN and baseline models in in-domain tasks.
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
> |verall” is the weighted average of performance in different tasks. “SR” and “PR” stand for “succe te” and “progress rate” metrics.|Col2|rmance in different tasks. “SR” and “PR” stand for “succe|
> |---|---|---|
> |**Model**<br>**Size**<br>**Version**<br>**Gripper**<br>**Blockworld**<br>**Barman**<br>**Tyreworld**<br>**Overall**<br>**SR**<br>**PR**<br>**SR**<br>**PR**<br>**SR**<br>**PR**<br>**SR**<br>**PR**<br>**SR**<br>**PR**|**Model**<br>**Size**<br>**Version**<br>**Gripper**<br>**Blockworld**<br>**Barman**<br>**Tyreworld**<br>**Overall**<br>**SR**<br>**PR**<br>**SR**<br>**PR**<br>**SR**<br>**PR**<br>**SR**<br>**PR**<br>**SR**<br>**PR**|**Gripper**<br>**Blockworld**<br>**Barman**<br>**Tyreworld**<br>**Overall**|
> |**Model**<br>**Size**<br>**Version**<br>**Gripper**<br>**Blockworld**<br>**Barman**<br>**Tyreworld**<br>**Overall**<br>**SR**<br>**PR**<br>**SR**<br>**PR**<br>**SR**<br>**PR**<br>**SR**<br>**PR**<br>**SR**<br>**PR**|**Model**<br>**Size**<br>**Version**<br>**Gripper**<br>**Blockworld**<br>**Barman**<br>**Tyreworld**<br>**Overall**<br>**SR**<br>**PR**<br>**SR**<br>**PR**<br>**SR**<br>**PR**<br>**SR**<br>**PR**<br>**SR**<br>**PR**|**SR**<br>**PR**<br>**SR**<br>**PR**<br>**SR**<br>**PR**<br>**SR**<br>**PR**<br>**SR**<br>**PR**|
> |GPT-4|`-`<br>`2023-05-15`<br>`-`<br>`turbo`|55.0<br>83.3<br>50.0<br>75.0<br>75.0<br>82.5<br>60.0<br>80.3<br>61.7<br>81.2<br>50.0<br>87.8<br>40.0<br>71.7<br>10.0<br>17.5<br>10.0<br>39.3<br>23.3<br>44.7|
> |GPT-3.5|`-`<br>`turbo`<br>`-`<br>`turbo-16k`|0.0<br>30.6<br>0.0<br>18.3<br>10.0<br>21.7<br>10.0<br>27.1<br>5.0<br>25.0<br>0.0<br>28.2<br>0.0<br>20.0<br>5.0<br>13.3<br>10.0<br>32.7<br>3.3<br>22.6|
> |CODELLAMA|7B<br>`instruct`<br>13B<br>`instruct`<br>34B<br>`instruct`|0.0<br>7.4<br>0.0<br>8.3<br>0.0<br>0.0<br>10.0<br>26.0<br>1.7<br>8.2<br>5.0<br>15.6<br>0.0<br>5.0<br>0.0<br>0.0<br>0.0<br>19.3<br>1.7<br>9.3<br>0.0<br>28.7<br>10.0<br>21.7<br>5.0<br>7.5<br>0.0<br>17.1<br>3.3<br>18.5|
> |MISTRAL|7B<br>`instruct-v0.2`|0.0<br>5.3<br>0.0<br>10.0<br>0.0<br>2.5<br>0.0<br>7.3<br>0.0<br>5.5|
> |LLAMA-2|7B<br>`chat`<br>13B<br>`chat`<br>70B<br>`chat`|0.0<br>1.5<br>0.0<br>0.0<br>0.0<br>0.0<br>0.0<br>0.0<br>0.0<br>0.5<br>0.0<br>0.0<br>0.0<br>6.7<br>0.0<br>1.7<br>0.0<br>14.8<br>0.0<br>4.1<br>0.0<br>8.8<br>0.0<br>5.0<br>5.0<br>9.2<br>0.0<br>7.8<br>1.7<br>8.1|
> |FIREACT|7B<br>`-`|0.0<br>0.0<br>0.0<br>5.0<br>0.0<br>0.0<br>0.0<br>0.0<br>0.0<br>1.5|
> |AGENT-FLAN|7B<br>`-`|0.0<br>0.0<br>0.0<br>0.0<br>0.0<br>0.0<br>0.0<br>0.0<br>0.0<br>0.0|
> |AGENTLM|7B<br>`-`<br>70B<br>`-`|0.0<br>0.0<br>0.0<br>0.0<br>0.0<br>2.5<br>0.0<br>0.0<br>0.0<br>0.8<br>0.0<br>0.8<br>0.0<br>6.7<br>5.0<br>13.3<br>10.0<br>26.0<br>3.3<br>10.2|
> |LLAMA-3.1<br>_w._ AGENTINSTRUCT<br>_w._ AGENTGEN|8B<br>`instruct`<br>8B<br>`-`<br>8B<br>`-`|0.0<br>0.0<br>0.0<br>1.7<br>0.0<br>0.0<br>0.0<br>16.2<br>0<br>3.0<br>0.0<br>3.4<br>0.0<br>5.0<br>0.0<br>6.7<br>10.0<br>26.0<br>1.7<br>8.5<br>20.0<br>45.2<br>20.0<br>31.7<br>10.0<br>32.7<br>10.0<br>32.7<br>15.0<br>33.3|
> |LLAMA-3.1<br>_w._ AGENTINSTRUCT<br>_w._ AGENTGEN|70B<br>`instruct`<br>70B<br>`-`<br>70B<br>`-`|55.0<br>89.3<br>50.0<br>70.0<br>70.0<br>80.0<br>40.0<br>65.3<br>56.7<br>79.0<br>45.0<br>78.9<br>70.0<br>80.0<br>25.0<br>32.5<br>50.0<br>74.4<br>43.4<br>62.9<br>55.0<br>89.3<br>50.0<br>63.3<br>70.0<br>82.5<br>50.0<br>82.2<br>58.3<br>81.5|
> 
> 
> Table 2: Overall performance comparison of models before and after training with AGENTGEN on
> in-domain tasks. “SR” and “PR” stands for “success rate” and “progress rate” respectively.
> 
> 
> **Before** **After** ∆
> **Model**
> 
> **SR** **PR** **SR** **PR** **SR** **PR**
> 
> 
> **4.4** **Evaluation on Out-of-Domain Tasks**
> 
> 
> We also conducted evaluations on out-of-domain agent tasks. As illustrated in Table 3, similar
> experimental phenomena were observed. Firstly, AGENTGEN demonstrates a substantial performance
> improvement over Llama-3.1, with an increase of 13.1% in the average progress rate for the 8B model
> and 5.0% for the 70B model. Additionally, the AGENTGEN-tuned Llama-3.1-8B model outperforms
> GPT-3.5. When compared to general models and agent fine-tuning models with similar parameter
> scales, AGENTGEN consistently outperforms them on both tasks. The superior performance on
> out-of-domain tasks further emphasizes the effectiveness and generalization capability of our data
> synthesis methods.
> 
> 
> **5** **Related Work**
> 
> 
> **Large Language Model based Agent.** Large Language Models have demonstrated exceptional
> reasoning capabilities [62, 39, 42, 43, 24]. Owing to such abilities, over the past two years, LLMbased agents have experienced significant development [53, 75, 16, 58, 65, 77]. Unlike the traditional
> method of using LLMs for text-based reasoning, such as Chain-of-Thought [74], LLM-based agents
> typically involve interaction with the environment, adjusting the output in a closed-loop manner
> based on environmental information. These LLM-based agents, now fortified with capabilities like
> Memorizing [91, 32, 29, 84, 53, 88, 95, 61, 22], Tool-use [9, 45, 52, 28, 51, 47], and Planning [12, 5,
> 41, 40, 49, 2], exhibit a marked enhancement in their overall efficacy. Although this paper mainly
> 
> 
> 8
> 
> 
> |Table 3: Performance comparison between AGENTGEN and baseline models on out-of-domain tasks. “SR” and “PR” stand for “success rate” and “progress rate” metrics.|Col2|NTGEN and baseline models on out-of-domain tasks. “SR” and ” metrics.|Col4|
> |---|---|---|---|
> |**Model**<br>**Size**<br>**Version**<br>**Alfworld [54]**<br>**BabyAI** [10]<br>**Jericho** [15]<br>**Average**<br>**SR**<br>**PR**<br>**SR**<br>**PR**<br>**SR**<br>**PR**<br>**SR**<br>**PR**|**Model**<br>**Size**<br>**Version**<br>**Alfworld [54]**<br>**BabyAI** [10]<br>**Jericho** [15]<br>**Average**<br>**SR**<br>**PR**<br>**SR**<br>**PR**<br>**SR**<br>**PR**<br>**SR**<br>**PR**|**Alfworld [54]**<br>**BabyAI** [10]<br>**Jericho** [15]<br>**Average**|**Alfworld [54]**<br>**BabyAI** [10]<br>**Jericho** [15]<br>**Average**|
> |**Model**<br>**Size**<br>**Version**<br>**Alfworld [54]**<br>**BabyAI** [10]<br>**Jericho** [15]<br>**Average**<br>**SR**<br>**PR**<br>**SR**<br>**PR**<br>**SR**<br>**PR**<br>**SR**<br>**PR**|**Model**<br>**Size**<br>**Version**<br>**Alfworld [54]**<br>**BabyAI** [10]<br>**Jericho** [15]<br>**Average**<br>**SR**<br>**PR**<br>**SR**<br>**PR**<br>**SR**<br>**PR**<br>**SR**<br>**PR**|**SR**<br>**PR**<br>**SR**<br>**PR**<br>**SR**<br>**PR**|**SR**<br>**PR**|
> |GPT-4|`-`<br>`2023-05-15`|43.4<br>65.5<br>56.2<br>70.7<br>35.0<br>52.4|44.9<br>62.9|
> |GPT-3.5|`-`<br>`turbo`<br>`-`<br>`turbo-16k`|17.2<br>35.6<br>18.9<br>31.9<br>0.0<br>20.4<br>4.5<br>25.2<br>33.9<br>45.1<br>0.0<br>16.1|12.0<br>29.3<br>12.8<br>28.8|
> |CODELLAMA|7B<br>`instruct`<br>13B<br>`instruct`<br>34B<br>`instruct`|1.4<br>2.2<br>15.2<br>28.3<br>0.0<br>9.2<br>2.2<br>13.4<br>17.0<br>22.2<br>0.0<br>0.0<br>3.0<br>11.3<br>13.4<br>19.9<br>0.0<br>15.5|5.5<br>13.9<br>6.4<br>11.9<br>5.5<br>15.6|
> |MISTRAL|7B<br>`instruct-v0.2`|0.0<br>9.8<br>18.1<br>24.4<br>0.0<br>12.1|6.0<br>15.4|
> |LLAMA-2|7B<br>`chat`<br>13B<br>`chat`<br>70B<br>`chat`|0.0<br>1.5<br>5.4<br>8.3<br>0.0<br>4.2<br>0.0<br>7.8<br>6.2<br>18.2<br>0.0<br>3.2<br>3.0<br>13.2<br>19.6<br>30.0<br>0.0<br>7.8|1.8<br>4.7<br>2.1<br>9.7<br>7.5<br>17.0|
> |FIREACT|7B<br>`-`|0.0<br>0.8<br>4.5<br>8.6<br>0.0<br>2.8|1.5<br>4.7|
> |AGENT-FLAN|7B<br>`-`|0.0<br>0.8<br>0.0<br>0.0<br>0.0<br>0.0|0.0<br>0.3|
> |AGENTLM_†_|7B<br>`-`<br>70B<br>`-`|`-`<br>`-`<br>8.0<br>9.9<br>5.5<br>15.2<br>`-`<br>`-`<br>27.7<br>37.1<br>0.0<br>18.4|`-`<br>`-`<br>`-`<br>`-`|
> |LLAMA-3.1<br>_w._ AGENTTUNING_†_<br>_w._ AGENTGEN|8B<br>`instruct`<br>8B<br>`-`<br>8B<br>`-`|0.0<br>10.5<br>17.9<br>33.6<br>0.0<br>8.8<br>`-`<br>`-`<br>10.7<br>19.3<br>0.0<br>8.2<br>17.9<br>31.7<br>32.1<br>46.0<br>0.0<br>14.3|6.0<br>17.6<br>`-`<br>`-`<br>16.0<br>30.7|
> |LLAMA-3.1<br>_w._ AGENTTUNING_†_<br>_w._ AGENTGEN|70B<br>`instruct`<br>70B<br>`-`<br>70B<br>`-`|17.2<br>42.7<br>38.4<br>57.2<br>10.0<br>31.5<br>`-`<br>`-`<br>17.9<br>35.9<br>10.0<br>31.9<br>19.4<br>46.1<br>42.0<br>62.2<br>15.0<br>38.1|21.8<br>43.8<br>`-`<br>`-`<br>25.5<br>48.8|
> 
> 
> focuses on the planning capability of LLM-based agents, we believe AGENTGEN has the potential to
> generalize to other scenarios of LLM-based agents.
> 
> 
> **Planning with Large Language Models.** Planning is one of the key applications of LLM-based
> agents, applicable in various scenarios such as robotic planning [54, 46, 19, 63, 11, 76, 31, 13], travel
> planning [78, 1], calendar scheduling [90], code generation [4] and others [72]. It is typically defined
> as the process of systematically determining a sequence of actions or steps required to achieve a
> desired goal from an initial state, considering constraints and available resources. This definition
> primarily differentiates from studies that utilize LLMs to generate ungrounded plans as guidance
> for problem-solving [94, 66], rather than directly producing executable actions. Planning can be
> categorized into two types: open-loop planning, where the LLM outputs an entire action sequence
> before execution [19, 63], and closed-loop planning, where the LLM-based agent decides the next
> action based on real-time environmental interaction after executing a previous action [55, 5, 59, 60,
> 30, 56, 21, 20]. This paper mainly focuses on close-loop planning, which is more adaptable for
> error correction, human interaction, and environmental grounding. Recent studies on close-loop
> planning have integrated chain-of-thought reasoning into the planning process [82]. Additionally,
> some papers have explored the use of tree-search methods to enhance the performance of LLM
> planning [18, 14, 83, 34, 89, 70, 92]. Instead of designing novel frameworks or engaging in prompt
> engineering, this paper explores how training can enhance the planning capabilities of LLM-based
> agents.
> 
> 
> **Agent Training.** Recently, numerous studies have aimed to enhance LLM-based agent capabilities
> by incorporating agent trajectory data into their training [68, 8, 87, 64, 57]. Advanced works such
> as AgentTuning [86] utilize GPT-4 to generate trajectory data across six distinct environments.
> Subsequently, this data is filtered and employed in training Large Language Models, enhancing the
> agent capabilities of base models. Another work, FireAct [6], proposes training with both CoT data
> 
> 
> 3 _†_ AgentTuning utilized Alfworld’s training set, meaning Alfworld cannot be considered an out-of-domain
> task. Consequently, we did not evaluate the performance of AgentLM or the AgentTuning-trained model on
> Alfworld.
> 
> 
> 9
> 
> 
> and ReAct format data, enabling the model to discern when to use reasoning to solve problems and
> when to call external tools. Agent LUMOS [85] suggests separately training Planning and Grounding
> models, enabling LLM-based agents to learn to decompose complex problems before execution.
> LLM-Modulo framwork [26] proposes to leverage LLMs generating candidate plans and verify them
> with an external verifier. Then, use the verified trajectories for fine-tuning LLMs. Similarly, [3] takes
> a generate-test loop to synthesize trajectories for LLM training. Unlike previous papers on all agent
> training, AGENTGEN goes beyond merely generating trajectory data using Large Language Models.
> Instead, we utilize Large Language Models to generate agent environments, which can be considered
> a more foundational application. As a result, we have constructed over 500 environments for training,
> whereas previous works typically use fewer than 10 environments to synthesize agent data.
> 
> 
> **Environment and Task Generation with Large Language Models.** The utilization of LLMs to
> generate environments and tasks is an emerging application. Some studies have explored utilizing
> LLMs to generate layouts in robotic simulations, typically involving the creation of configuration
> files [71, 81, 67]. While these methods can construct numerous scene-level environments, they often
> struggle to achieve diversity at the underlying mechanism level. AgentTuning [86] employs a task
> generation approach similar to the Self-instruct [73] method, using the test set as seed data. This
> approach not only poses a risk of data leakage but also leads to insufficient diversity in task difficulty.
> ByteSized32 [69] uses LLMs to generate Python-based games based on predefined task specifications
> automatically. Similarly, other works [13] leverage LLMs to automatically construct PDDL domains
> based on a task specification. In contrast to these studies, this paper proposes using a diverse text
> corpus to generate environment code automatically. This approach facilitates the creation of a wide
> range of rich environments without predefined definitions.
> 
> 
> **6** **Conclusion**
> 
> 
> In this paper, we explore using LLMs to automatically generate environment and planning tasks for
> LLM-based agent training. Specifically, for generating diverse environments, we propose utilizing an
> inspiration corpus composed of various domain-specific text segments as the context for environment
> synthesis. To enhance the difficulty diversity of generated planning tasks, we introduce a bidirectional
> evolution method, BI-EVOL, which evolves planning tasks from both easier and more challenging
> directions to create a task set with a more gradual difficulty curve, thereby improving the effectiveness
> of LLM learning. Based on AGENTGEN, we developed a dataset consisting of 592 environments and
> 7246 trajectories and trained it on a series of LLMs. The AGENTGEN-tuned Llama-3.1-8B model
> surpassed GPT-3.5 on planning tasks, while the AGENTGEN-tuned Llama-3.1-70B model achieved a
> new state-of-the-art performance.
> 
> 
> 10
> 
> 
> **References**
> 
> 
> [1] Mohamed Aghzal, Erion Plaku, and Ziyu Yao. Can large language models be good path
> planners? a benchmark and investigation on spatial-temporal reasoning. _arXiv_ _preprint_
> _arXiv:2310.03249_, 2023.
> 
> 
> [2] Anurag Ajay, Seungwook Han, Yilun Du, Shuang Li, Abhi Gupta, Tommi Jaakkola, Josh
> Tenenbaum, Leslie Kaelbling, Akash Srivastava, and Pulkit Agrawal. Compositional foundation
> models for hierarchical planning. _Advances_ _in_ _Neural_ _Information_ _Processing_ _Systems_, 36,
> 2024.
> 
> 
> [3] Daman Arora and Subbarao Kambhampati. Learning and leveraging verifiers to improve
> planning capabilities of pre-trained language models. _arXiv preprint arXiv:2305.17077_, 2023.
> 
> 
> [4] Ramakrishna Bairi, Atharv Sonwane, Aditya Kanade, Arun Iyer, Suresh Parthasarathy, Sriram
> Rajamani, B Ashok, and Shashank Shet. Codeplan: Repository-level coding using llms and
> planning. _Proceedings of the ACM on Software Engineering_, 1(FSE):675–698, 2024.
> 
> 
> [5] Anthony Brohan, Yevgen Chebotar, Chelsea Finn, Karol Hausman, Alexander Herzog, Daniel
> Ho, Julian Ibarz, Alex Irpan, Eric Jang, Ryan Julian, et al. Do as i can, not as i say: Grounding
> language in robotic affordances. In _Conference on robot learning_, pages 287–318. PMLR, 2023.
> 
> 
> [6] Baian Chen, Chang Shu, Ehsan Shareghi, Nigel Collier, Karthik Narasimhan, and Shunyu Yao.
> Fireact: Toward language agent fine-tuning. _arXiv preprint arXiv:2310.05915_, 2023.
> 
> 
> [7] Mark Chen, Jerry Tworek, Heewoo Jun, Qiming Yuan, Henrique Ponde De Oliveira Pinto, Jared
> Kaplan, Harri Edwards, Yuri Burda, Nicholas Joseph, Greg Brockman, et al. Evaluating large
> language models trained on code. _arXiv preprint arXiv:2107.03374_, 2021.
> 
> 
> [8] Zehui Chen, Kuikun Liu, Qiuchen Wang, Wenwei Zhang, Jiangning Liu, Dahua Lin, Kai Chen,
> and Feng Zhao. Agent-flan: Designing data and methods of effective agent tuning for large
> language models. _arXiv preprint arXiv:2403.12881_, 2024.
> 
> 
> [9] Zhoujun Cheng, Tianbao Xie, Peng Shi, Chengzu Li, Rahul Nadkarni, Yushi Hu, Caiming
> Xiong, Dragomir Radev, Mari Ostendorf, Luke Zettlemoyer, et al. Binding language models in
> symbolic languages. _arXiv preprint arXiv:2210.02875_, 2022.
> 
> 
> [10] Maxime Chevalier-Boisvert, Dzmitry Bahdanau, Salem Lahlou, Lucas Willems, Chitwan
> Saharia, Thien Huu Nguyen, and Yoshua Bengio. Babyai: A platform to study the sample
> efficiency of grounded language learning. _arXiv preprint arXiv:1810.08272_, 2018.
> 
> 
> [11] Yan Ding, Xiaohan Zhang, Chris Paxton, and Shiqi Zhang. Task and motion planning with
> large language models for object rearrangement, 2023.
> 
> 
> [12] Zeyu Gao, Yao Mu, Jinye Qu, Mengkang Hu, Lingyue Guo, Ping Luo, and Yanfeng Lu. Dagplan: Generating directed acyclic dependency graphs for dual-arm cooperative planning. _arXiv_
> _preprint arXiv:2406.09953_, 2024.
> 
> 
> [13] Lin Guan, Karthik Valmeekam, Sarath Sreedharan, and Subbarao Kambhampati. Leveraging
> pre-trained large language models to construct and utilize world models for model-based task
> planning. _Advances in Neural Information Processing Systems_, 36:79081–79094, 2023.
> 
> 
> [14] Shibo Hao, Yi Gu, Haodi Ma, Joshua Jiahua Hong, Zhen Wang, Daisy Zhe Wang, and Zhiting Hu. Reasoning with language model is planning with world model. _arXiv_ _preprint_
> _arXiv:2305.14992_, 2023.
> 
> 
> [15] Matthew Hausknecht, Prithviraj Ammanabrolu, Marc-Alexandre Côté, and Xingdi Yuan. Interactive fiction games: A colossal adventure. In _Proceedings of the AAAI Conference on Artificial_
> _Intelligence_, volume 34, pages 7903–7910, 2020.
> 
> 
> [16] Sirui Hong, Xiawu Zheng, Jonathan Chen, Yuheng Cheng, Jinlin Wang, Ceyao Zhang, Zili
> Wang, Steven Ka Shing Yau, Zijuan Lin, Liyang Zhou, et al. MetaGPT: Meta programming for
> multi-agent collaborative framework. _arXiv preprint arXiv:2308.00352_, 2023.
> 
> 
> 11
> 
> 
> [17] Edward J Hu, Yelong Shen, Phillip Wallis, Zeyuan Allen-Zhu, Yuanzhi Li, Shean Wang,
> Lu Wang, and Weizhu Chen. Lora: Low-rank adaptation of large language models. _arXiv_
> _preprint arXiv:2106.09685_, 2021.
> 
> 
> [18] Mengkang Hu, Yao Mu, Xinmiao Yu, Mingyu Ding, Shiguang Wu, Wenqi Shao, Qiguang Chen,
> Bin Wang, Yu Qiao, and Ping Luo. Tree-planner: Efficient close-loop task planning with large
> language models. _arXiv preprint arXiv:2310.08582_, 2023.
> 
> 
> [19] Wenlong Huang, Pieter Abbeel, Deepak Pathak, and Igor Mordatch. Language models as
> zero-shot planners: Extracting actionable knowledge for embodied agents. In _International_
> _conference on machine learning_, pages 9118–9147. PMLR, 2022.
> 
> 
> [20] Wenlong Huang, Fei Xia, Ted Xiao, Harris Chan, Jacky Liang, Pete Florence, Andy Zeng,
> Jonathan Tompson, Igor Mordatch, Yevgen Chebotar, Pierre Sermanet, Noah Brown, Tomas
> Jackson, Linda Luu, Sergey Levine, Karol Hausman, and Brian Ichter. Inner monologue:
> Embodied reasoning through planning with language models, 2022.
> 
> 
> [21] Wenlong Huang, Fei Xia, Dhruv Shah, Danny Driess, Andy Zeng, Yao Lu, Pete Florence, Igor
> Mordatch, Sergey Levine, Karol Hausman, and Brian Ichter. Grounded decoding: Guiding text
> generation with grounded models for robot control, 2023.
> 
> 
> [22] Xu Huang, Jianxun Lian, Yuxuan Lei, Jing Yao, Defu Lian, and Xing Xie. Recommender
> ai agent: Integrating large language models for interactive recommendations. _arXiv preprint_
> _arXiv:2308.16505_, 2023.
> 
> 
> [23] Ahmed Hussein, Mohamed Medhat Gaber, Eyad Elyan, and Chrisina Jayne. Imitation learning:
> A survey of learning methods. _ACM Computing Surveys (CSUR)_, 50(2):1–35, 2017.
> 
> 
> [24] Albert Q Jiang, Alexandre Sablayrolles, Arthur Mensch, Chris Bamford, Devendra Singh
> Chaplot, Diego de las Casas, Florian Bressand, Gianna Lengyel, Guillaume Lample, Lucile
> Saulnier, et al. Mistral 7b. _arXiv preprint arXiv:2310.06825_, 2023.
> 
> 
> [25] Leslie Pack Kaelbling and Tomás Lozano-Pérez. Hierarchical task and motion planning in the
> now. In _2011 IEEE International Conference on Robotics and Automation_, pages 1470–1477,
> 2011. doi: 10.1109/ICRA.2011.5980391.
> 
> 
> [26] Subbarao Kambhampati, Karthik Valmeekam, Lin Guan, Kaya Stechly, Mudit Verma, Siddhant
> Bhambri, Lucas Saldyt, and Anil Murthy. Llms can’t plan, but can help planning in llm-modulo
> frameworks. _arXiv preprint arXiv:2402.01817_, 2024.
> 
> 
> [27] Yuhang Lai, Chengxi Li, Yiming Wang, Tianyi Zhang, Ruiqi Zhong, Luke Zettlemoyer, Wentau Yih, Daniel Fried, Sida Wang, and Tao Yu. Ds-1000: A natural and reliable benchmark
> for data science code generation. In _International Conference on Machine Learning_, pages
> 18319–18345. PMLR, 2023.
> 
> 
> [28] Minghao Li, Yingxiu Zhao, Bowen Yu, Feifan Song, Hangyu Li, Haiyang Yu, Zhoujun Li,
> Fei Huang, and Yongbin Li. Api-bank: A comprehensive benchmark for tool-augmented llms.
> _arXiv preprint arXiv:2304.08244_, 2023.
> 
> 
> [29] Xinnian Liang, Bing Wang, Hui Huang, Shuangzhi Wu, Peihao Wu, Lu Lu, Zejun Ma, and
> Zhoujun Li. Unleashing infinite-length input capacity for large-scale language models with
> self-controlled memory system. _arXiv e-prints_, pages arXiv–2304, 2023.
> 
> 
> [30] Bill Yuchen Lin, Chengsong Huang, Qian Liu, Wenda Gu, Sam Sommerer, and Xiang Ren.
> On grounded planning for embodied tasks with language models. In _Proceedings of the AAAI_
> _Conference on Artificial Intelligence_, volume 37, pages 13192–13200, 2023.
> 
> 
> [31] Bo Liu, Yuqian Jiang, Xiaohan Zhang, Qiang Liu, Shiqi Zhang, Joydeep Biswas, and Peter
> Stone. Llm+ p: Empowering large language models with optimal planning proficiency. _arXiv_
> _preprint arXiv:2304.11477_, 2023.
> 
> 
> [32] Lei Liu, Xiaoyan Yang, Yue Shen, Binbin Hu, Zhiqiang Zhang, Jinjie Gu, and Guannan Zhang.
> Think-in-memory: Recalling and post-thinking enable llms with long-term memory. _arXiv_
> _preprint arXiv:2311.08719_, 2023.
> 
> 
> 12
> 
> 
> [33] Xiao Liu, Hao Yu, Hanchen Zhang, Yifan Xu, Xuanyu Lei, Hanyu Lai, Yu Gu, Hangliang Ding,
> Kaiwen Men, Kejuan Yang, et al. AgentBench: Evaluating llms as agents. _arXiv_ _preprint_
> _arXiv:2308.03688_, 2023.
> 
> 
> [34] Yanming Liu, Xinyue Peng, Yuwei Zhang, Jiannan Cao, Xuhong Zhang, Sheng Cheng, Xun
> Wang, Jianwei Yin, and Tianyu Du. Tool-planner: Dynamic solution tree planning for large
> language model with tool clustering. _arXiv preprint arXiv:2406.03807_, 2024.
> 
> 
> [35] Haipeng Luo, Qingfeng Sun, Can Xu, Pu Zhao, Jianguang Lou, Chongyang Tao, Xiubo Geng,
> Qingwei Lin, Shifeng Chen, and Dongmei Zhang. Wizardmath: Empowering mathematical reasoning for large language models via reinforced evol-instruct. _arXiv preprint arXiv:2308.09583_,
> 2023.
> 
> 
> [36] Ziyang Luo, Can Xu, Pu Zhao, Qingfeng Sun, Xiubo Geng, Wenxiang Hu, Chongyang Tao, Jing
> Ma, Qingwei Lin, and Daxin Jiang. Wizardcoder: Empowering code large language models
> with evol-instruct. _arXiv preprint arXiv:2306.08568_, 2023.
> 
> 
> [37] Chang Ma, Junlei Zhang, Zhihao Zhu, Cheng Yang, Yujiu Yang, Yaohui Jin, Zhenzhong Lan,
> Lingpeng Kong, and Junxian He. Agentboard: An analytical evaluation board of multi-turn llm
> agents. _arXiv preprint arXiv:2401.13178_, 2024.
> 
> 
> [38] Drew McDermott, Malik Ghallab, Adele E. Howe, Craig A. Knoblock, Ashwin Ram,
> Manuela M. Veloso, Daniel S. Weld, and David E. Wilkins. Pddl-the planning domain definition
> language. 1998. URL `[https://api.semanticscholar.org/CorpusID:59656859](https://api.semanticscholar.org/CorpusID:59656859)` .
> 
> 
> [39] Meta AI. Introducing meta Llama 3: The most capable openly available LLM to date, April
> 2024. URL `[https://ai.meta.com/blog/meta-llama-3/](https://ai.meta.com/blog/meta-llama-3/)` . Accessed: 2024-04-18.
> 
> 
> [40] Yao Mu, Junting Chen, Qinglong Zhang, Shoufa Chen, Qiaojun Yu, Chongjian Ge, Runjian
> Chen, Zhixuan Liang, Mengkang Hu, Chaofan Tao, et al. Robocodex: Multimodal code
> generation for robotic behavior synthesis. _arXiv preprint arXiv:2402.16117_, 2024.
> 
> 
> [41] Yao Mu, Qinglong Zhang, Mengkang Hu, Wenhai Wang, Mingyu Ding, Jun Jin, Bin Wang,
> Jifeng Dai, Yu Qiao, and Ping Luo. Embodiedgpt: Vision-language pre-training via embodied
> chain of thought. _Advances in Neural Information Processing Systems_, 36, 2024.
> 
> 
> [42] OpenAI. Openai: Introducing chatgpt, 2022. URL `[https://openai.com/blog/chatgpt](https://openai.com/blog/chatgpt)` .
> 
> 
> [43] OpenAI. Gpt-4 technical report, 2023.
> 
> 
> [44] R OpenAI. Gpt-4 technical report. arxiv 2303.08774. _View in Article_, 2:13, 2023.
> 
> 
> [45] Aaron Parisi, Yao Zhao, and Noah Fiedel. Talm: Tool augmented language models. _arXiv_
> _preprint arXiv:2205.12255_, 2022.
> 
> 
> [46] Xavier Puig, Kevin Ra, Marko Boben, Jiaman Li, Tingwu Wang, Sanja Fidler, and Antonio
> Torralba. Virtualhome: Simulating household activities via programs. In _Proceedings of the_
> _IEEE conference on computer vision and pattern recognition_, pages 8494–8502, 2018.
> 
> 
> [47] Yujia Qin, Shihao Liang, Yining Ye, Kunlun Zhu, Lan Yan, Yaxi Lu, Yankai Lin, Xin Cong,
> Xiangru Tang, Bill Qian, et al. ToolLLM: Facilitating large language models to master 16000+
> real-world apis. _arXiv preprint arXiv:2307.16789_, 2023.
> 
> 
> [48] Baptiste Roziere, Jonas Gehring, Fabian Gloeckle, Sten Sootla, Itai Gat, Xiaoqing Ellen Tan,
> Yossi Adi, Jingyu Liu, Tal Remez, Jérémy Rapin, et al. Code llama: Open foundation models
> for code. _arXiv preprint arXiv:2308.12950_, 2023.
> 
> 
> [49] Jingqing Ruan, Yihong Chen, Bin Zhang, Zhiwei Xu, Tianpeng Bao, Guoqing Du, Shiwei
> Shi, Hangyu Mao, Xingyu Zeng, and Rui Zhao. Tptu: Task planning and tool usage of large
> language model-based ai agents. _arXiv preprint arXiv:2308.03427_, 2023.
> 
> 
> [50] Stuart J Russell and Peter Norvig. _Artificial intelligence:_ _a modern approach_ . Pearson, 2016.
> 
> 
> 13
> 
> 
> [51] Timo Schick, Jane Dwivedi-Yu, Roberto Dessì, Roberta Raileanu, Maria Lomeli, Luke Zettlemoyer, Nicola Cancedda, and Thomas Scialom. Toolformer: Language models can teach
> themselves to use tools. _CoRR_, abs/2302.04761, 2023. doi: 10.48550/ARXIV.2302.04761.
> URL `[https://doi.org/10.48550/arXiv.2302.04761](https://doi.org/10.48550/arXiv.2302.04761)` .
> 
> 
> [52] Yongliang Shen, Kaitao Song, Xu Tan, Dongsheng Li, Weiming Lu, and Yueting Zhuang. Hugginggpt: Solving AI tasks with chatgpt and its friends in huggingface. _CoRR_, abs/2303.17580,
> 2023. doi: 10.48550/ARXIV.2303.17580. URL `[https://doi.org/10.48550/arXiv.2303.](https://doi.org/10.48550/arXiv.2303.17580)`
> `[17580](https://doi.org/10.48550/arXiv.2303.17580)` .
> 
> 
> [53] Noah Shinn, Federico Cassano, Ashwin Gopinath, Karthik R Narasimhan, and Shunyu Yao.
> Reflexion: Language agents with verbal reinforcement learning. In _Thirty-seventh Conference_
> _on Neural Information Processing Systems_, 2023.
> 
> 
> [54] Mohit Shridhar, Xingdi Yuan, Marc-Alexandre Côté, Yonatan Bisk, Adam Trischler, and
> Matthew Hausknecht. Alfworld: Aligning text and embodied environments for interactive
> learning. _arXiv preprint arXiv:2010.03768_, 2020.
> 
> 
> [55] Ishika Singh, Valts Blukis, Arsalan Mousavian, Ankit Goyal, Danfei Xu, Jonathan Tremblay,
> Dieter Fox, Jesse Thomason, and Animesh Garg. Progprompt: Generating situated robot task
> plans using large language models. In _2023 IEEE International Conference on Robotics and_
> _Automation (ICRA)_, pages 11523–11530. IEEE, 2023.
> 
> 
> [56] Chan Hee Song, Jiaman Wu, Clayton Washington, Brian M. Sadler, Wei-Lun Chao, and Yu Su.
> Llm-planner: Few-shot grounded planning for embodied agents with large language models,
> 2023.
> 
> 
> [57] Yifan Song, Da Yin, Xiang Yue, Jie Huang, Sujian Li, and Bill Yuchen Lin. Trial and error:
> Exploration-based trajectory optimization for llm agents. _arXiv preprint arXiv:2403.02502_,
> 2024.
> 
> 
> [58] Theodore R Sumers, Shunyu Yao, Karthik Narasimhan, and Thomas L Griffiths. Cognitive
> architectures for language agents. _arXiv preprint arXiv:2309.02427_, 2023.
> 
> 
> [59] Haotian Sun, Yuchen Zhuang, Lingkai Kong, Bo Dai, and Chao Zhang. Adaplanner: Adaptive
> planning from feedback with language models. _arXiv preprint arXiv:2305.16653_, 2023.
> 
> 
> [60] Simeng Sun, Yang Liu, Shuohang Wang, Chenguang Zhu, and Mohit Iyyer. Pearl: Prompting
> large language models to plan and execute actions over long documents. _arXiv_ _preprint_
> _arXiv:2305.14564_, 2023.
> 
> 
> [61] Jihoon Tack, Jaehyung Kim, Eric Mitchell, Jinwoo Shin, Yee Whye Teh, and Jonathan Richard
> Schwarz. Online adaptation of language models with a memory of amortized contexts. _arXiv_
> _preprint arXiv:2403.04317_, 2024.
> 
> 
> [62] Hugo Touvron, Louis Martin, Kevin Stone, Peter Albert, Amjad Almahairi, Yasmine Babaei,
> Nikolay Bashlykov, Soumya Batra, Prajjwal Bhargava, Shruti Bhosale, et al. Llama 2: Open
> foundation and fine-tuned chat models. _arXiv preprint arXiv:2307.09288_, 2023.
> 
> 
> [63] Karthik Valmeekam, Matthew Marquez, Alberto Olmo, Sarath Sreedharan, and Subbarao
> Kambhampati. Planbench: An extensible benchmark for evaluating large language models on
> planning and reasoning about change. _Advances in Neural Information Processing Systems_, 36,
> 2024.
> 
> 
> [64] Boshi Wang, Hao Fang, Jason Eisner, Benjamin Van Durme, and Yu Su. Llms in the imaginarium: tool learning through simulated trial and error. _arXiv_ _preprint_ _arXiv:2403.04746_,
> 2024.
> 
> 
> [65] Lei Wang, Chen Ma, Xueyang Feng, Zeyu Zhang, Hao Yang, Jingsen Zhang, Zhiyuan Chen,
> Jiakai Tang, Xu Chen, Yankai Lin, et al. A survey on large language model based autonomous
> agents. _arXiv preprint arXiv:2308.11432_, 2023.
> 
> 
> 14
> 
> 
> [66] Lei Wang, Wanyu Xu, Yihuai Lan, Zhiqiang Hu, Yunshi Lan, Roy Ka-Wei Lee, and Ee-Peng
> Lim. Plan-and-solve prompting: Improving zero-shot chain-of-thought reasoning by large
> language models. _arXiv preprint arXiv:2305.04091_, 2023.
> 
> 
> [67] Lirui Wang, Yiyang Ling, Zhecheng Yuan, Mohit Shridhar, Chen Bao, Yuzhe Qin, Bailin
> Wang, Huazhe Xu, and Xiaolong Wang. Gensim: Generating robotic simulation tasks via large
> language models. _arXiv preprint arXiv:2310.01361_, 2023.
> 
> 
> [68] Renxi Wang, Haonan Li, Xudong Han, Yixuan Zhang, and Timothy Baldwin. Learning from
> failure: Integrating negative examples when fine-tuning large language models as agents. _arXiv_
> _preprint arXiv:2402.11651_, 2024.
> 
> 
> [69] Ruoyao Wang, Graham Todd, Eric Yuan, Ziang Xiao, Marc-Alexandre Côté, and Peter Jansen.
> Bytesized32: A corpus and challenge task for generating task-specific world models expressed
> as text games. _arXiv preprint arXiv:2305.14879_, 2023.
> 
> 
> [70] Xinyuan Wang, Chenxi Li, Zhen Wang, Fan Bai, Haotian Luo, Jiayou Zhang, Nebojsa Jojic,
> Eric P Xing, and Zhiting Hu. Promptagent: Strategic planning with language models enables
> expert-level prompt optimization. _arXiv preprint arXiv:2310.16427_, 2023.
> 
> 
> [71] Yufei Wang, Zhou Xian, Feng Chen, Tsun-Hsuan Wang, Yian Wang, Katerina Fragkiadaki,
> Zackory Erickson, David Held, and Chuang Gan. Robogen: Towards unleashing infinite data
> for automated robot learning via generative simulation. _arXiv preprint arXiv:2311.01455_, 2023.
> 
> 
> [72] Zihao Wang, Shaofei Cai, Anji Liu, Xiaojian Ma, and Yitao Liang. Describe, explain, plan and
> select: Interactive planning with large language models enables open-world multi-task agents,
> 2023.
> 
> 
> [73] Jason Wei, Maarten Bosma, Vincent Y Zhao, Kelvin Guu, Adams Wei Yu, Brian Lester, Nan
> Du, Andrew M Dai, and Quoc V Le. Finetuned language models are zero-shot learners. _arXiv_
> _preprint arXiv:2109.01652_, 2021.
> 
> 
> [74] Jason Wei, Xuezhi Wang, Dale Schuurmans, Maarten Bosma, Fei Xia, Ed Chi, Quoc V Le,
> Denny Zhou, et al. Chain-of-thought prompting elicits reasoning in large language models.
> _Advances in Neural Information Processing Systems_, 35:24824–24837, 2022.
> 
> 
> [75] Qingyun Wu, Gagan Bansal, Jieyu Zhang, Yiran Wu, Shaokun Zhang, Erkang Zhu, Beibin Li,
> Li Jiang, Xiaoyun Zhang, and Chi Wang. AutoGen: Enabling next-gen llm applications via
> multi-agent conversation framework. _arXiv preprint arXiv:2308.08155_, 2023.
> 
> 
> [76] Zhenyu Wu, Ziwei Wang, Xiuwei Xu, Jiwen Lu, and Haibin Yan. Embodied task planning with
> large language models, 2023.
> 
> 
> [77] Zhiheng Xi, Wenxiang Chen, Xin Guo, Wei He, Yiwen Ding, Boyang Hong, Ming Zhang,
> Junzhe Wang, Senjie Jin, Enyu Zhou, et al. The rise and potential of large language model
> based agents: A survey. _arXiv preprint arXiv:2309.07864_, 2023.
> 
> 
> [78] Jian Xie, Kai Zhang, Jiangjie Chen, Tinghui Zhu, Renze Lou, Yuandong Tian, Yanghua Xiao,
> and Yu Su. Travelplanner: A benchmark for real-world planning with language agents. _arXiv_
> _preprint arXiv:2402.01622_, 2024.
> 
> 
> [79] Tianbao Xie, Fan Zhou, Zhoujun Cheng, Peng Shi, Luoxuan Weng, Yitao Liu, Toh Jing
> Hua, Junning Zhao, Qian Liu, Che Liu, Leo Z. Liu, Yiheng Xu, Hongjin Su, Dongchan
> Shin, Caiming Xiong, and Tao Yu. Openagents: An open platform for language agents in
> the wild. _CoRR_, abs/2310.10634, 2023. doi: 10.48550/ARXIV.2310.10634. URL `[https:](https://doi.org/10.48550/arXiv.2310.10634)`
> `[//doi.org/10.48550/arXiv.2310.10634](https://doi.org/10.48550/arXiv.2310.10634)` .
> 
> 
> [80] Can Xu, Qingfeng Sun, Kai Zheng, Xiubo Geng, Pu Zhao, Jiazhan Feng, Chongyang Tao, and
> Daxin Jiang. Wizardlm: Empowering large language models to follow complex instructions.
> _arXiv preprint arXiv:2304.12244_, 2023.
> 
> 
> [81] Yue Yang, Fan-Yun Sun, Luca Weihs, Eli VanderBilt, Alvaro Herrasti, Winson Han, Jiajun Wu,
> Nick Haber, Ranjay Krishna, Lingjie Liu, et al. Holodeck: Language guided generation of 3d
> embodied ai environments. In _Proceedings of the IEEE/CVF Conference on Computer Vision_
> _and Pattern Recognition_, pages 16227–16237, 2024.
> 
> 
> 15
> 
> 
> [82] Shunyu Yao, Jeffrey Zhao, Dian Yu, Nan Du, Izhak Shafran, Karthik Narasimhan, and Yuan Cao.
> React: Synergizing reasoning and acting in language models. _arXiv preprint arXiv:2210.03629_,
> 2022.
> 
> 
> [83] Shunyu Yao, Dian Yu, Jeffrey Zhao, Izhak Shafran, Thomas L Griffiths, Yuan Cao, and Karthik
> Narasimhan. Tree of thoughts: Deliberate problem solving with large language models. _arXiv_
> _preprint arXiv:2305.10601_, 2023.
> 
> 
> [84] Weiran Yao, Shelby Heinecke, Juan Carlos Niebles, Zhiwei Liu, Yihao Feng, Le Xue, Rithesh
> Murthy, Zeyuan Chen, Jianguo Zhang, Devansh Arpit, et al. Retroformer: Retrospective large
> language agents with policy gradient optimization. _arXiv preprint arXiv:2308.02151_, 2023.
> 
> 
> [85] Da Yin, Faeze Brahman, Abhilasha Ravichander, Khyathi Chandu, Kai-Wei Chang, Yejin
> Choi, and Bill Yuchen Lin. Lumos: Learning agents with unified data, modular design, and
> open-source llms. _arXiv preprint arXiv:2311.05657_, 2023.
> 
> 
> [86] Aohan Zeng, Mingdao Liu, Rui Lu, Bowen Wang, Xiao Liu, Yuxiao Dong, and Jie Tang.
> Agenttuning: Enabling generalized agent abilities for llms. _arXiv preprint arXiv:2310.12823_,
> 2023.
> 
> 
> [87] Jianguo Zhang, Tian Lan, Rithesh Murthy, Zhiwei Liu, Weiran Yao, Juntao Tan, Thai Hoang,
> Liangwei Yang, Yihao Feng, Zuxin Liu, et al. Agentohana: Design unified data and training
> pipeline for effective agent learning. _arXiv preprint arXiv:2402.15506_, 2024.
> 
> 
> [88] Andrew Zhao, Daniel Huang, Quentin Xu, Matthieu Lin, Yong-Jin Liu, and Gao Huang. Expel:
> Llm agents are experiential learners. In _Proceedings_ _of_ _the_ _AAAI_ _Conference_ _on_ _Artificial_
> _Intelligence_, volume 38, pages 19632–19642, 2024.
> 
> 
> [89] Zirui Zhao, Wee Sun Lee, and David Hsu. Large language models as commonsense knowledge
> for large-scale task planning. _Advances in Neural Information Processing Systems_, 36, 2024.
> 
> 
> [90] Huaixiu Steven Zheng, Swaroop Mishra, Hugh Zhang, Xinyun Chen, Minmin Chen, Azade
> Nova, Le Hou, Heng-Tze Cheng, Quoc V Le, Ed H Chi, et al. Natural plan: Benchmarking
> llms on natural language planning. _arXiv preprint arXiv:2406.04520_, 2024.
> 
> 
> [91] Wanjun Zhong, Lianghong Guo, Qiqi Gao, He Ye, and Yanlin Wang. Memorybank: Enhancing
> large language models with long-term memory. In _Proceedings of the AAAI Conference on_
> _Artificial Intelligence_, volume 38, pages 19724–19731, 2024.
> 
> 
> [92] Andy Zhou, Kai Yan, Michal Shlapentokh-Rothman, Haohan Wang, and Yu-Xiong Wang.
> Language agent tree search unifies reasoning acting and planning in language models. _arXiv_
> _preprint arXiv:2310.04406_, 2023.
> 
> 
> [93] Chunting Zhou, Pengfei Liu, Puxin Xu, Srinivasan Iyer, Jiao Sun, Yuning Mao, Xuezhe Ma,
> Avia Efrat, Ping Yu, Lili Yu, et al. Lima: Less is more for alignment. _Advances in Neural_
> _Information Processing Systems_, 36, 2024.
> 
> 
> [94] Denny Zhou, Nathanael Schärli, Le Hou, Jason Wei, Nathan Scales, Xuezhi Wang, Dale
> Schuurmans, Claire Cui, Olivier Bousquet, Quoc Le, et al. Least-to-most prompting enables
> complex reasoning in large language models. _arXiv preprint arXiv:2205.10625_, 2022.
> 
> 
> [95] Xizhou Zhu, Yuntao Chen, Hao Tian, Chenxin Tao, Weijie Su, Chenyu Yang, Gao Huang, Bin
> Li, Lewei Lu, Xiaogang Wang, et al. Ghost in the minecraft: Generally capable agents for
> open-world environments via large language models with text-based knowledge and memory.
> _arXiv preprint arXiv:2305.17144_, 2023.
> 
> 
> 16
> 
> 
> **A** **More Implementation Details**
> 
> 
> **A.1** **Models**
> 
> 
> We applied the instruct version for models. Specifically, the detailed version for each model is
> presented in Table 4.
> 
> 
> Model Version
> 
> 
> CodeLlama [meta-llama/CodeLlama-7b-Instruct-hf](https://huggingface.co/meta-llama/CodeLlama-7b-Instruct-hf)
> Mistral [mistralai/Mistral-7B-Instruct-v0.2](https://huggingface.co/mistralai/Mistral-7B-Instruct-v0.2)
> Llama2 [meta-llama/Llama-2-7b-chat-hf](https://huggingface.co/meta-llama/Llama-2-7b-chat-hf)
> Llama3 [meta-llama/Meta-Llama-3-8B-Instruct](https://huggingface.co/meta-llama/Meta-Llama-3-8B-Instruct)
> AgentLM [THUDM/agentlm-7b](https://huggingface.co/THUDM/agentlm-7b)
> 
> Table 4: Evaluated models in this study.
> 
> 
> **A.2** **Natural Language Mapping**
> 
> 
> We leverage GPT-4 to generate the natural language mapping that converts structured actions into its
> natural language format. When the mapping failed to yield, we heuristically serialized the structured
> actions. The prompt for generating natural language mapping with GPT-4 is as follows:
> 
> 
> 
> 17
> 
> 
> **B** **More Statistics on Environment**
> 
> 
> **B.1** **Environment Specification**
> 
> 
> We analyzed the token distribution within the environmental specifications. Among the 592 environmental specifications, the average token count is 473.55, with a median of 467.00. The minimum
> token count is 207, and the maximum is 934. As depicted in Figure 4, the number of specification
> tokens for the environment is predominantly concentrated within the range of 300 to 699.
> 
> 
> **B.2** **Environment Implementation**
> 
> 
> The scale of action space and state space in an environment typically dictates its complexity, with
> a greater number of actions and states generally indicating a more complex environment. An
> environment library with a greater variety of difficulty levels is preferable for a training set. As shown
> in Figure 5, there is a significant diversity in the number of actions and predicates.
> 
> 
> **B.3** **Diversity Analysis**
> 
> 
> We evaluate the diversity of generated environments using cosine similarity. More specifically, we
> randomly sampled 100 environment specifications for better visualization and converted them into
> TF-IDF vectors. After calculating the cosine similarity matrix between all pairs of specifications, we
> visualize the matrix using heatmap as is shown in Figure 6. The computed average cosine similarity
> 
> 
> 18
> 
> 
> 250
> 
> 
> 200
> 
> 
> 150
> 
> 
> 100
> 
> 
> 50
> 
> 
> 0
> 
> 
> 
> Number of Tokens
> 
> 
> Figure 4: The token distribution of the generated environment specification.
> 
> 
> 80
> 
> 70
> 
> 60
> 
> 50
> 
> 40
> 
> 30
> 
> 20
> 
> 10
> 
> 0
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
> 10
> 
> 
> 
> 
> 
> Figure 5: The frequency distribution of actions and predicates in datasets.
> 
> 
> 19
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
> Figure 6: Cosine similarity heatmap depicting the semantic relationships among randomly sampled
> 100 environment specifications. Darker shades represent a higher similarity between the two specifications.
> 
> 
> of the sampled environment specifications is 0.176, indicating that the corpus exhibits a high degree
> of diversity, reflecting a rich tapestry of distinct semantic features and thematic elements.
> 
> 
> **C** **Examples**
> 
> 
> In this section, we present the specific details of the cases depicted in Figure 2 and Figure 3.
> 
> 
> **C.1** **Environment Specification**
> 
> 
> 
> 20
> 
> 
> **C.2** **Environment Implementation**
> 
> 
> 
> 21
> 
> 
> **C.3** **Trajectory Data**
> 
> 
> 
> 
> 
> 22
> 
> 
> 23
> 
> 

> [Source: AGENTGEN: Enhancing Planning Abilities for Large Language Model based Agent via Environment and Task Generation](https://arxiv.org/abs/2408.00764)
