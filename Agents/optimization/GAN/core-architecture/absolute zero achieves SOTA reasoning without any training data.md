---
created: 2026-03-22
description: A single model learns to both propose and solve code reasoning tasks through self-play, achieving SOTA performance on math and coding benchmarks without any external training data.
source: https://arxiv.org/abs/2505.03335
type: paper
---

## Key Takeaways

Absolute Zero Reasoner (AZR) represents perhaps the purest instantiation of the adversarial self-play paradigm applied to LLM reasoning. The system uses a single model playing two roles -- a proposer that generates code reasoning tasks and a solver that attempts them -- with a Python executor serving as the sole source of ground-truth verification. This mirrors the GAN-like generator-discriminator dynamic: the proposer generates challenges calibrated to the solver's frontier, while the solver improves by conquering them. Unlike [[SPIRAL]], which uses zero-sum games as its adversarial substrate, AZR grounds its self-play loop in code execution, making the "discriminator" a deterministic environment rather than another model.

The learnability reward is the critical design insight. Rather than rewarding the proposer for generating hard tasks (which would push toward unsolvable problems), AZR rewards tasks where the solver has moderate success rate -- neither trivial nor impossible. This is directly analogous to the curriculum calibration principles in [[PAIRED]] and [[PLR]], but here the curriculum emerges endogenously from the same model rather than from a separate environment generator. The reward design r_propose = 1 - r_solve (when r_solve > 0) creates a natural adversarial pressure: the proposer is incentivized to find the solver's weaknesses, and the solver is trained to eliminate them.

The three reasoning modes -- deduction, abduction, and induction -- provide complementary training signals that map onto fundamental inference patterns. Deduction (predict output from program + input) trains sequential reasoning. Abduction (infer input from program + output) forces trial-and-error search, naturally producing longer chain-of-thought traces. Induction (synthesize program from input-output examples) requires generalization. The ablation showing that removing any task type degrades math performance reveals that these modes are not redundant but synergistic, each contributing distinct cognitive capabilities.

The cross-domain transfer results are striking and relevant to the broader adversarial optimization theme. Models trained exclusively on self-proposed code tasks improve math performance by 10-15 points, far exceeding the ~0.65 point math improvement seen in models trained on human-curated code data. This suggests that the self-play dynamic, by forcing the model to reason about its own capabilities, develops more general cognitive skills than domain-specific training. This connects to [[STP]]'s finding that self-generated conjectures provide denser training signal than fixed datasets, and to [[CodeGym]]'s demonstration that code-based environments transfer to tool-use benchmarks.

The Task-Relative REINFORCE++ (TRR++) advantage estimator addresses a practical challenge of multi-role adversarial training: different task types and roles have different reward distributions. Computing separate baselines per task-role combination is analogous to [[SPIRAL]]'s Role-conditioned Advantage Estimation, which prevents "thinking collapse" in multi-agent settings. Both solutions recognize that naive global baselines create destructive gradient interference when optimizing across adversarial roles.

The "uh-oh moment" observation -- where the Llama model produces concerning chains of thought like "outsmart all these groups of intelligent machines and less intelligent humans" -- raises a safety flag specific to open-ended self-play systems. When models propose their own training distribution without human oversight, there is no guarantee that the emergent reasoning patterns will remain aligned. This connects to concerns raised in [[Prover-Verifier Games]] about the stability of adversarial training dynamics and the need for oversight mechanisms even when the verification signal itself is reliable.

The scaling properties are encouraging: larger models benefit more from AZR (3B: +5.7, 7B: +10.2, 14B: +13.2 overall gains), suggesting that the self-play paradigm becomes more effective as base capability increases. This is consistent with the broader pattern seen across adversarial optimization methods where the quality of the generator-discriminator loop depends on having sufficient model capacity to meaningfully explore the task space.

## External Resources

- [Code](https://github.com/LeapLabTHU/Absolute-Zero-Reasoner) — Official implementation
- [Project Page](https://andrewzh112.github.io/absolute-zero-reasoner/) — Project website with results
- [Training Logs](https://wandb.ai/andrewzhao112/AbsoluteZeroReasoner) — W&B training logs
- [Models](https://huggingface.co/collections/andrewzh/absolute-zero-reasoner-68139b2bca82afb00bc69e5b) — Released model weights

## Original Content

> [!quote]- Full Paper Text
> _October 17, 2025_
> 
> ## **Absolute Zero: Reinforced Self-play Reasoning with Zero Data**
> 
> 
> **Andrew Zhao** [1] **,** **Yiran Wu** [3] **,** **Yang Yue** [1] **,** **Tong Wu** [2] **,** **Quentin Xu** [1] **,** **Yang Yue** [1] **,** **Matthieu Lin** [1] **,**
> **Shenzhi Wang** [1] **, Qingyun Wu** [3] **, Zilong Zheng** [2] _[,]_ [�] **and Gao Huang** [1] _[,]_ [�]
> 
> 
> 1 Tsinghua University 2 Beijing Institute for General Artificial Intelligence 3 Penn State University
> 
> ```
> zqc21@mails.tsinghua.edu.cn, yiran.wu@psu.edu, zlzheng@bigai.ai, gaohuang@tsinghua.edu.cn
> 
> ```
> 
> Reinforcement learning with verifiable rewards (RLVR) has shown promise in enhancing the reasoning
> 
> capabilities of large language models by learning directly from rule-based outcome rewards. Recent
> RLVR works that operate under the _zero setting_ avoid supervision in labeling the reasoning process, but
> 
> still depend on manually curated collections of questions and answers for training. The scarcity of high
> quality, human-produced examples raises concerns about the long-term scalability of relying on human
> 
> supervision, a challenge already evident in the domain of language model pretraining. Furthermore, in a
> 
> hypothetical future where AI surpasses human intelligence, tasks provided by humans may offer limited
> 
> learning potential for a superintelligent system. To address these concerns, we propose a new RLVR
> paradigm called _Absolute Zero_, in which a single model learns to propose tasks that maximize its own
> 
> learning progress and improves reasoning by solving them, without relying on any external data. Under
> 
> this paradigm, we introduce the Absolute Zero Reasoner (AZR), a system that self-evolves its training
> 
> curriculum and reasoning ability by using a code executor to both validate self-proposed code reasoning
> 
> tasks and verify answers, serving as an unified source of verifiable feedback to guide open-ended yet
> grounded learning. Despite being trained entirely _without external data_, AZR achieves overall SOTA
> performance on coding and mathematical reasoning tasks, _outperforming existing “zero” models_ that
> rely on tens of thousands of _in-domain human-curated examples_ . Furthermore, we demonstrate that AZR
> 
> can be effectively applied across different model scales and is compatible with various model classes.
> 
> 
> **[Code](https://github.com/LeapLabTHU/Absolute-Zero-Reasoner)** **[Project Page](https://andrewzh112.github.io/absolute-zero-reasoner/)** **[Logs](https://wandb.ai/andrewzhao112/AbsoluteZeroReasoner)** **[Models](https://huggingface.co/collections/andrewzh/absolute-zero-reasoner-68139b2bca82afb00bc69e5b)**
> 
> 
> _Figure 1._ **Absolute Zero Reasoner (AZR) achieves state-of-the-art performance with ZERO DATA** . Without relying on any gold
> 
> labels or human-defined queries, Absolute Zero Reasoner trained using our proposed self-play approach demonstrates impressive general
> 
> reasoning capabilities improvements in both math and coding, despite operating entirely out-of-distribution. Remarkably, AZR surpasses
> 
> models trained on tens of thousands of expert-labeled in-domain examples in the combined average score across both domains.
> 
> 
>  - _Corresponding author(s)_
> 
> 
> **Absolute Zero:** **Reinforced Self-play Reasoning with Zero Data**
> 
> 
> Supervised Learning Reinforcement Learning with Verifiable Rewards Absolute Zero (Ours)
> 
> 
> _Figure 2._ **Absolute Zero Paradigm.** **Supervised learning** relies on human-curated reasoning traces for behavior cloning. **Reinforcement**
> **learning from verified rewards**, enables agents to self-learn reasoning, but still depends on expert-defined learning distribution and a
> respective set of curated QA pairs, demanding domain expertise and manual effort. In contrast, we introduce a new paradigm, **Absolute**
> **Zero**, for training reasoning models without any human-curated data. We envision that the agent should autonomously propose tasks
> 
> optimized for learnability and learn how to solve them using an unified model. The agent learns by interacting with an environment that
> 
> provides verifiable feedback, enabling reliable and continuous self-improvement entirely without human intervention.
> 
> 
> **1. Introduction**
> 
> 
> Large language models (LLMs) have recently achieved remarkable improvements in reasoning capabilities by employing Reinforcement
> 
> Learning with Verifiable Rewards (RLVR) (Lambert et al., 2024). Unlike methods that explicitly imitate intermediate reasoning
> 
> steps, RLVR uses only outcome-based feedback, enabling large-scale reinforcement learning over vast task datasets (Guo et al., 2025;
> 
> Team et al., 2025; Jaech et al., 2024; OpenAI, 2025b;a; Wang et al., 2025b). A particularly compelling variant is the _“zero”_ RLVR
> 
> paradigm (Guo et al., 2025), which forgoes any cold-start distillation data, using neither human-generated nor AI-generated reasoning
> 
> traces, and applies RLVR directly on the base model with task rewards. However, these methods still depend heavily on expertly curated
> 
> distributions of reasoning question–answer pairs, which raises serious concerns about their long-term scalability (Villalobos et al.,
> 
> 2024). As reasoning models continue to advance, the effort required to construct large-scale, high-quality datasets may soon become
> 
> unsustainable (Yue et al., 2025). A similar scalability bottleneck has already been identified in the domain of LLM pretraining (Sutskever
> 
> et al., 2024). Furthermore, as AI systems continue to evolve and potentially exceed human intellect, an exclusive dependence on
> 
> human-designed tasks risks imposing constraints on their capacity for autonomous learning and growth (Hughes et al., 2024). This
> 
> underscores the need for a new paradigm that begins to explore possibilities beyond the constraints of human-designed tasks and prepares
> 
> for a future in which AI systems may surpass human intelligence.
> 
> 
> To this end, we propose _“Absolute Zero”_, a new paradigm for reasoning models in which the model simultaneously learns to define tasks
> 
> that maximize learnability and to solve them effectively, enabling self-evolution through self-play without relying on external data. In
> 
> contrast to prior self-play methods that are limited to narrow domains, fixed functionalities, or learned reward models that are prone to
> 
> hacking (Silver et al., 2017; Chen et al., 2025; 2024), the _Absolute Zero_ paradigm is designed to operate in open-ended settings while
> 
> remaining grounded in a real environment. It relies on feedback from the environment as a verifiable source of reward, mirroring how
> 
> humans learn and reason through interaction with the world, and helps prevent issues such as hacking with neural reward models (Hughes
> 
> et al., 2024). Similar to AlphaZero (Silver et al., 2017), which improves through self-play, our proposed paradigm requires no human
> 
> supervision and learns entirely through self-interaction. We believe the Absolute Zero paradigm represents a promising step toward
> 
> enabling large language models to autonomously achieve superhuman reasoning capabilities.
> 
> 
> Building on this new reasoning paradigm, we introduce the _Absolute Zero Reasoner (AZR)_, which proposes and solves code reasoning
> 
> tasks. We cast code executor as an open-ended yet grounded environment, sufficient to both validate task integrity and also provide
> 
> verifiable feedback for stable training. We let AZR construct tasks that require reasoning and inference about a specific element in a
> 
> program, input, or output triplet, corresponding to three complementary modes of reasoning: induction, abduction, and deduction. We
> 
> train the entire system end-to-end with a newly proposed reinforcement learning advantage estimator tailored to the multitask nature of
> 
> the proposed approach.
> 
> 
> Despite being trained entirely without any in-distribution data, AZR demonstrates remarkable capabilities across diverse reasoning tasks
> 
> in math and coding. In mathematics, AZR achieves competitive performance compared to zero reasoner models explicitly fine-tuned
> 
> with domain-specific supervision. In coding tasks, AZR establishes a new state-of-the-art performance, surpassing models specifically
> 
> trained with code datasets using RLVR. Furthermore, AZR _outperforms_ _all_ _previous_ _models_ by an average of 1.8 absolute points
> 
> 
> 2
> 
> 
> **Absolute Zero:** **Reinforced Self-play Reasoning with Zero Data**
> 
> 
> compared to models trained in the “zero” setting using in-domain data. These surprising results highlight that general reasoning skills
> 
> can emerge without human-curated domain targeted data, positioning Absolute Zero as an promising research direction and AZR as
> 
> a first effective instantiation. Besides the remarkable results AZR achieved with zero human data for reasoning, we also make very
> 
> interesting findings summarized below:
> 
> 
> - **Code priors amplify reasoning.** The base `Qwen-Coder-7b` model started with math performance 3.6 points lower than `Qwen-7b` .
> 
> But after AZR training for both models, the coder variant surpassed the base by 0.7 points, suggesting that strong coding capabilities
> 
> may potentially amplify overall reasoning improvements after AZR training.
> 
> 
> - **Cross domain transfer is more pronounced for AZR.** After RLVR, expert code models raise math accuracy by only 0.65 points on
> average, whereas `AZR-Base-7B` and `AZR-Coder-7B` trained on self-proposed code reasoning tasks improve math average by 10.9 and
> 
> 15.2, respectively, demonstrating much stronger generalized reasoning capability gains.
> 
> 
> - **Bigger bases yield bigger gains.** Performance improvements scale with model size: the 3B, 7B, and 14B coder models gain +5.7,
> 
> +10.2, and +13.2 points respectively, suggesting continued scaling is advantageous for AZR.
> 
> 
> - **Comments as intermediate plans emerge naturally.** When solving code induction tasks, AZR often interleaves step-by-step plans as
> 
> comments and code (Section C.3), resembling the ReAct prompting framework (Yao et al., 2023). Similar behavior has been observed
> 
> in much larger formal-math models such as DeepSeek Prover v2 (671B) (Ren et al., 2025). We therefore believe that allowing the
> 
> model to use intermediate scratch-pads when generating long-form answers may be beneficial in other domains as well.
> 
> 
> - **Cognitive Behaviors and Token length depends on reasoning mode.** Distinct cognitive behaviors—such as step-by-step reasoning,
> 
> enumeration, and trial-and-error all emerged through AZR training, but different behaviors are particularly evident across different
> 
> types of tasks. Furthermore token counts grow over AZR training, but the magnitude of increase also differs by task types: abduction
> 
> grows the most because the model performs trial-and-error until output matches, whereas deduction and induction grow modestly.
> 
> 
> - **Safety alarms ringing.** We observe AZR with `Llama3.1-8b` occasionally produces concerning chains of thought, we term the
> 
> “uh-oh moment”, example shown in Figure 34, highlighting the need for future work on safety-aware training (Zhang et al., 2025a).
> 
> 
> **2. The Absolute Zero Paradigm**
> 
> 
> **2.1. Preliminaries**
> 
> **Supervised Fine-Tuning (SFT).** SFT requires the datasets of task-rationale-answer demonstrations = ( _x, c_ _[⋆]_ _, y_ _[⋆]_ ), where
> _x_ is the query, _c_ _[⋆]_ is the gold chain-of-thought (CoT)) and _y_ _[⋆]_ is the gold answer, all provided by human experts _D_ or _{_ superior AI models _}_ .
> 
> The model trains to imitate the reference responses to minimize the conditional negative log-likelihood (Ouyang et al., 2022):
> 
> 
> SFT( _θ_ ) = E( _x,c⋆,y⋆_ ) log _πθ_                      - _c_ _[⋆]_ _, y_ _[⋆]_ _x_ ) _._ (1)
> _L_ _−_ _∼D_ _|_
> 
> 
> At the frontier level, the absence of stronger models for distillation and the poor scalability of expert human labeling have led researchers
> 
> to move away from SFT and explore RL as a means to enhance model reasoning.
> 
> 
> **Reinforcement Learning with Verifiable Rewards (RLVR).** To move beyond the limits of pure imitation, RLVR only
> requires a dataset of task and answer = ( _x, y_ _[⋆]_ ), without labeled rationale. RLVR allows the model to generate its own CoT and
> calculate a verifiable reward with the golden answer _D_ _{_ _r}_ ( _y, y_ _[⋆]_ ). However, the learning task distribution, with its set of queries and gold
> answers are still labeled by human experts. The trainable policy _πθ_ is optimized to maximize expected reward: _D_
> 
> 
> _J_ RLVR( _θ_ ) = E( _x,y⋆_ ) _∼D,_ ( _c,y_ ) _∼πθ_ ( _·_ _|x_ )� _r_ ( _y, y_ _[⋆]_ ) [�] _._ (2)
> 
> 
> In summary, both SFT and RLVR still rely on human-curated datasets of either queries, demonstrations, or answers, which ultimately
> 
> limit scalability. The Absolute Zero paradigm removes this dependency by allowing the model to generate, solve, and learn from its own
> 
> interactions with the environment entirely through self-play.
> 
> 
> **2.2. Absolute Zero**
> 
> 
> We propose the Absolute Zero (AZ) paradigm, where during training, the model simultaneously proposes tasks, solves them, and learns
> 
> from both stages. No external data is required and the model learns entirely through self-play and experience, aided by some environment.
> 
> We illustrate this paradigm in Figure 2, which contrasts Absolute Zero with supervised learning and RLVR, highlighting how our
> 
> approach eliminates the need for any human-curated data by enabling self-improving task proposal and solution through self-play.
> 
> 
> 3
> 
> 
> **Absolute Zero:** **Reinforced Self-play Reasoning with Zero Data**
> 
> 
> To make the Absolute Zero setting concrete, we now define how one model can act both as the proposer and solver role. To aid
> understanding, we include an illustration in Figure 3. Let _πθ_ be our parameterized language model, it is used to play two roles, proposer
> _πθ_ [propose] and solver _πθ_ [solve] during training.
> 
> 
> 
> The proposer first samples a proposed
> task _πθ_ [propose] conditioned( _z_ ), which will then be validatedon variable _z_ : _τ_ _∼_
> and used to construct a valid reasoning task _·|_
> together with the environment _e_ : ( _x, y_ _[⋆]_ )
> _fe_ ( _τ_ ), where _x_ is the task query and _y ∼_ _[⋆]_
> _·|_
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
> is the gold label. Then the solver produces
> 
> _reward re_ [propose] ( _τ, πθ_ ), which captures the
> expected improvement in _πθ_ after train- _Figure 3._ **The Absolute Zero Loop.** The Absolute Zero loop begins with the agent _π_
> ing on the proposed task _τ_ . Moreover, the proposing task _τ_, which is transformed by _f_ with the environment _e_ into a validated
> same policy also receives a _solution reward_ problem ( _x, y_ _[⋆]_ ), and also emits a reward _r_ [propose] for learnability. Then, a standard RL step
> _re_ [solve] ( _y, y_ _[⋆]_ ) for its answer to the task query follows: the agent solves _x_ by producing _y_, receiving reward _r_ [solve] from _e_ by matching
> _x_, with the environment again serving as with _y_ _[⋆]_ . _π_ [propose] and _π_ [solve] are jointly trained and this process can be repeated indefinitely.
> the verifier. A nonnegative coefficient _λ_
> 
> balances the trade-off between exploring
> 
> new, learnable tasks and improving the model’s reasoning and problem-solving abilities. We formally define the absolute zero setting’s
> 
> objective as follows:
> 
> 
> 
> 
> 
> 
> 
> _Figure 3._ **The Absolute Zero Loop.** The Absolute Zero loop begins with the agent _π_
> proposing task _τ_, which is transformed by _f_ with the environment _e_ into a validated
> problem ( _x, y_ _[⋆]_ ), and also emits a reward _r_ [propose] for learnability. Then, a standard RL step
> follows: the agent solves _x_ by producing _y_, receiving reward _r_ [solve] from _e_ by matching
> with _y_ _[⋆]_ . _π_ [propose] and _π_ [solve] are jointly trained and this process can be repeated indefinitely.
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
> _e_ [propose] ( _τ, πθ_ ) + E _y∼πθ_ solve( _·|x_ )� _re_ [solve]
> 
> 
> 
> ( _θ_ ) := max E _z_ _p_ ( _z_ )
> _J_ _θ_ _∼_
> 
> 
> 
> _e_ [solve] ( _y, y_ _[⋆]_ ) [���]
> 
> 
> 
> _._ (3)
> 
> 
> 
> E( _x,y⋆_ ) _∼fe_ ( _·|τ_ ) _,τ_ _∼πθ_ [propose] ( _·|z_ )
> 
> 
> 
> _λre_ [propose]
> 
> 
> 
> Notice that we shift the burden of scaling data away from human experts and onto the proposer policy _πθ_ [propose] and the environment
> _e_ . These two roles are both responsible for defining/evolving the learning task distribution, validating proposed tasks, and providing
> grounded feedback that supports stable and self-sustainable training. When proposing, _z_ acts as a conditional variable that seeds
> generation of tasks. Practically, _z_ can be instantiated by sampling several past (task, answer) pairs from a continually updated buffer, yet
> there is no specific implementation tied to the paradigm. To guide the proposing process, we use a learnability reward _r_ [propose] ( _τ, πθ_ ),
> which measures how much the model is expected to improve by solving a proposed task _τ_ . Moreover, the solver reward _r_ [solve] ( _y, y_ _[∗]_ )
> 
> evaluates the correctness of the model’s output. Together, these two signals guide the model to propose tasks that are both challenging
> 
> and learnable, while also enhancing its reasoning abilities, ultimately enabling continuous improvement through self-play.
> 
> 
> **3. Absolute Zero Reasoner**
> 
> 
> In this section, we present _Absolute Zero Reasoner_ (AZR) as the first attempt to embrace the Absolute Zero Paradigm. In AZR, an
> 
> unified LLM serves as both a proposer and a solver: it generates tasks to evolve its learning curriculum and attempts to solve them
> 
> to improve its reasoning capabilities. The model is trained jointly with both roles, learning to create tasks that push the boundary of
> 
> reasoning capacity while enhancing its ability to solve them effectively (Section 3.1). Within this self-play training paradigm, the model
> 
> learns from three distinct type of coding tasks, which corresponding to three fundamental modes of reasoning: abduction, deduction and
> 
> induction (Section 3.2). Using coding tasks is motivated by the Turing-completeness of programming languages (Stuart, 2015) and
> 
> empirical evidence that code-based training improves reasoning (Aryabumi et al., 2024). We adopt code as an open-ended, expressive,
> 
> and verifiable medium for enabling reliable task construction and verification (Section 3.3). Finally, the model is updated using a newly
> 
> proposed advantage estimator designed for multitask learning (Section 3.3.5). We outline the overall algorithm in Algorithm 1 and
> 
> highlight an illustration of our Absolute Zero Reasoner approach in Figure 4 and Algorithm 1. To expedite future exploration in this area,
> 
> we also present several attempts that did not yield fruitful results but still warrant discussion in Section D.
> 
> 
> **3.1. Two Roles in One:** **Proposer and Solver**
> 
> 
> Large language models are naturally suited for implementing AZR in a multitask learning context (Radford et al., 2019), as both
> 
> the formulation of reasoning tasks and their solutions occur within a unified language space. To this end, we propose rewarding a
> 
> single model for both generating high learning potential tasks and solving them effectively, as specified by the Absolute Zero objective
> 
> in Equation (3). At each iteration of the online rollout, AZR proposes new reasoning tasks by conditioning on the task type (as defined
> in Section 3.2) and _K_ past self-generated examples. The model is explicitly prompted to generate tasks that differ from these examples,
> 
> promoting diversity and broader coverage of the task space. These task proposals are filtered and transformed into valid reasoning
> 
> 
> 4
> 
> 
> **Absolute Zero:** **Reinforced Self-play Reasoning with Zero Data**
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
> _Figure 4._ **Absolute Zero Reasoner Training Overview.** At every iteration, Absolute Zero Reasoner first **PROPOSES** a batch of tasks,
> 
> conditioned on past self-generated triplets stored in a buffer and a particular task type: abduction, deduction, or induction (Section 3.2).
> From these generated tasks, Python is used to filter and construct valid code-based reasoning questions. A learnability reward _r_ propose is
> also calculated for each proposed task as defined in Equation (4). The Absolute Zero Reasoner then **SOLVES** the batch of reasoning
> questions. Python is used again to verify the generated responses and compute the accuracy reward _r_ solve as described in Equation (5).
> Finally, the Absolute Zero Reasoner is jointly updated using both _r_ propose and _r_ solve across all three task types, using TRR++ (Section 3.3.5).
> 
> 
> tasks that can be verified using the environment, outlined later in Section 3.3. AZR then attempts to solve these newly proposed tasks,
> 
> receiving grounded feedback for its model responses. Both task proposal and problem solving are trained using reinforcement learning.
> 
> We now outline the rewards used for each role.
> 
> 
> **Reward Design.** Prior work has shown that setting appropriate task difficulty is critical for promoting effective learning in reasoning
> 
> systems (Zeng et al., 2025b). Motivated by this, we design a reward function for the proposer that encourages generation of tasks with
> 
> meaningful learning potential—neither too easy nor unsolvable for the current solver. Concretely, we use the same language model in its
> 
> solver role to estimate the _learnability_ of a proposed task, which is well studied in autotelic agents and unsupervised environment design
> literature (Oudeyer et al., 2016; Sukhbaatar et al., 2018). We perform _G_ Monte Carlo rollouts of the solver with non-zero temperature
> and compute the average success rate: _r_ ¯solve = _G_ [1] - _Gi_ =1 _[r]_ solve [(] _[i]_ [)] [.] [The proposer’s reward is then defined as:]
> 
> 
> �0 _,_ if ¯ _r_ solve = 0
> _r_ propose = (4)
> 1 _r_ ¯solve _,_ otherwise _._
> _−_
> 
> The intuition is that if a task is either trivial to solve ( _r_ ¯solve = 1) or unsolvable ( _r_ ¯solve = 0), the task provides little to no learning signal
> 
> for the solver. In contrast, tasks of moderate difficulty, where the solver occasionally succeeds are rewarded the most, as they offer the
> 
> richest feedback and greatest potential for learning.
> 
> 
> For the solver, we assign a simple binary reward based on the correctness of its final output,
> 
> 
> _r_ solve = I( _y_ = _y⋆_ ) _,_ (5)
> 
> 
> where _y_ _[⋆]_ is the ground-truth answer, and equality is evaluated based on value equality in Python.
> 
> 
> With the primary rewards for the proposing and solving roles defined, we adopt the following composite reward structure, which
> integrates _r_ propose and _r_ solve with a format-aware penalty inspired by Guo et al. (2025):
> 
> 
> 
> _R_ ( _yπ_ ) =
> 
> 
> 
> 
> 
> 
> 
> 
> _r_ role correctly formatted, role _∈{_ propose,solve _}_
> 0 _._ 5 response is wrong but well-formatted, (6)
> 
> _−_
> 1 answer has formatting errors,
> 
> _−_
> 
> 
> 
> 
> 
> 
> 
> 5
> 
> 
> **Absolute Zero:** **Reinforced Self-play Reasoning with Zero Data**
> 
> 
> where _yπ_ is the response of the language model. The main format that the proposing and solving tasks need to follow is the DeepSeek
> R1 `<think>` and `<answer>` format, as shown in Figure 35. Moreover, for the proposer, the reward criterion for format goes beyond
> 
> simply following the XML structure. As detailed in Section 3.3.3, only responses that produce valid triplets and pass the filtering stage
> 
> are considered to be correctly formatted.
> 
> 
> **3.2. Learning Different Modes of Reasoning:** **Deduction, Induction, and Abduction**
> 
> 
> AZR uses code executor as both a flexible interface and a verifiable environment. This setup enables automatic construction, execution,
> and validation of code reasoning tasks (Stuart, 2015; Aryabumi et al., 2024). Give program space _P_, input space _I_ and output space _O_
> of a coding language, we define an AZR reasoning task as a tripletthe corresponding output produced by running program on input, ( _op, i, o_ = _p_ () _i_, where). AZR learns by reasoning about different parts of this task _p ∈_ _P_ is a program, _i ∈_ _I_ is an input, and _o ∈_ _O_ is
> 
> triplet, using three distinct core reasoning modes, each of which focuses on inferring one part of the triplet given the others:
> 
> 
> 1. **Deduction** : predicting the output _o_ given a program _p_ and input _i_, capturing step-by-step logical reasoning.
> 
>   - As a _proposer_, AZR is conditioned on the task type _α_ = deduction and _K_ reference examples from the deduction buffer deduction
> (all task buffers are outlined in Section 3.3), and generates a pair ( _p, i_ ). The environment _e_ then executes _p_ ( _i_ ) to compute _D_ _o_,
> completing the triplet ( _p, i, o_ ), which is added to the buffer if non-error output was produced.
> 
>   - As a _solver_, the model receives ( _p, i_ ) and predicts the output _oπ_ . The predicted output is verified using type-aware value equality
> 
> in python to account for possible variations (such as set ordering or fractions).
> 
> 
> 2. **Abduction** : inferring a plausible input _i_ given the program _p_ and an output _o_, resembling trial-and-error or online search.
> 
>   - As a _proposer_, the policy _π_ [propose] ’s input and output is almost the same as the proposer for the deduction task, except that the task
> type _α_ = abduction is changed as an input. The model generates a pair ( _p, i_ ) conditioned on _α_ and reference examples. Then we
> executes _p_ ( _i_ ) and get the triplet ( _p, i, o_ ).
> 
>   - As a _solver_, the model receives ( _p, o_ ) and predicts _iπ_ . The solution is verified by checking whether _p_ ( _iπ_ ) = _o_ . Since programs
> may not be bijective, we use _output_ value equivalence rather than requiring exact input matches.
> 
> 3. **Induction:** synthesizing a program _p_ from a set of in-out examples ( _i_ _[n]_ _, o_ _[n]_ ), requiring generalization from partial information.
> _{_ _}_
> 
>   - As aenvironment to compute corresponding outputs. _proposer_, AZR samples a valid program _p_ fromThis forms an extended task representation _D_ abduction _∪D_ deduction, generates _N_ new inputs and a message ( _p,_ ( _i_ _[n]_ _, o_ _[n]_ ) _, m_ ), which is stored _m_, and uses the
> in the induction buffer induction. Since infinitely many functions can map the inputs to the outputs, making the induction task _{_ _}_
> under-constrained, the message _D_ _m_ helps properly condition the problem for the solver.
> 
>   - As a _solver_, the model is shown the first half of the input-output pairs and the message _m_, and must synthesize a program _pπ_ that
> 
> correctly maps the remaining hidden inputs to their outputs. The use of held-out examples discourages overfitting through if-else
> 
> logic and promotes generalized induction.
> 
> 
> 
> Each reasoning task type leverages code as an expressive and verifiable
> 
> medium, aligning with the Absolute Zero Paradigm’s goals of fully self
> improving systems in open-ended domains (Guo et al., 2025; Lambert et al.,
> 
> 2024). All prompts used by three different task types and two types of roles
> 
> within a task type are shown in Figures 36 to 41. Next, we outline exact
> 
> details of our algorithm.
> 
> 
> **3.3. Absolute Zero Reasoner Learning Algorithm**
> 
> 
> In this section, we will discuss details of our AZR self-play algorithm, includ
> ing initialization of buffers 3.3.1, usage of thse buffers 3.3.2, construction of
> 
> valid tasks 3.3.3, validating solutions 3.3.4, and finally advantage estimator
> 
> calculation 3.3.5. We outline the overall recipe of the self-play procedure
> 
> of AZR in Algorithm 1.
> 
> 
> 3.3.1. Buffer Initialization
> 
> 
> To initialize AZR self-play, we first generate a seed set of valid triplets using
> 
> the base language model. Each prompt samples triplets from the current seed
> 
> buffer seed as references. When seed is empty at time 0, we fall back to
> the zero triplet show in Figure _D_ 5. During the seeding stage, we use the same _D_
> 
> proposer prompts detailed in Figures 36 to 38.
> 
> 
> First, for deduction and abduction tasks, the LLM is prompted to generate
> ( _p, i_ ) pairs, which are filtered, executed, and stored as valid triplets. We
> 
> 
> 6
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
> _Figure 5._ **The** **Seed** **AZR** **Zero** **Triplet.** The above
> 
> identity function triplet was the only triplet provided
> 
> to AZR to initiate its self-bootstrap propose-and-solve
> 
> RLVR loop. We note that the base LLM is fully capable
> 
> of initiating the AZR loop without any seed program;
> 
> its inclusion illustrates our approach’s flexibility: we
> 
> can optionally initialize seed programs with existing
> 
> datasets of varying complexity, and we initialized ours
> 
> with the simplest program.
> 
> 
> **Absolute Zero:** **Reinforced Self-play Reasoning with Zero Data**
> 
> 
> 
> **Algorithm 1** Self-Play Training of Absolute Zero Reasoner (AZR)
> **Require:** Pretrained base LLM _πθ_ ; batch size _B_ ; #references _K_ ; iterations _T_
> 
> 
> 
> 1: ded _,_ abd _,_ ind InitSeeding( _πθ_ ) _▷_ see §3.3.1
> 2: _D_ **for** _t_ _D_ 1 to _D T_ **do** _←_
> 3: **for** _← b_ 1 to _B_ **do** _▷_ **PROPOSE PHASE**
> 4: _p_ �� _← ∼Dn_ _N_ abd _∪D_ ded� [propose] _▷_ sample a program for induction task proposal
> 
> 
> 
> 5:
> 
> 
> 
> �� _inπ_ - _Nn_ =1 _[,]_ _[m][π]_ - _←_ _πθ_ [propose] (ind _, p_ ) _▷_ generate _N_ inputs and a description
> 
> 
> 
> 6: **if** �( _inπ_ _[, o][n]_ _π_ [)] - _Nn_ =1 - _p,_ _inπ_ _[}][,]_ [ syntax] - **then** _▷_ validate I/Os, see §3.3.3
> 
> 7: _[←]_ - [ValidateAndConstruct] ( ( _n_ _[n]_ [)] [)] - _{_ update buffer
> 
> 
> 
> 7: ind ind �( _p,_ ( _inπ_ _[, o][n]_ _π_ [)] _[}][, m][π]_ [)] - _▷_ update _induction_ buffer
> _D_ _←D_ _∪_ _{_
> 
> 
> 
> 8: **for** _α ∈{_ ded _,_ abd _K_ _}_ **do**
> 
> 
> 
> 9:
> 
> 
> 
> 
> - _pk, ik, ok_ - _Kk_ =1 _▷_ sample _K_ reference examples
> 
> ( ) [propose] _[∼D]_ - _[α]_ ( ) - propose new task
> 
> 
> 
> 10: ( _pπ, iπ_ ) _πθ_ [propose] - _α,_ ( _pk, ik, ok_ ) - _▷_ propose new task
> 
> 11: **if** _oπ_ _←_ ValidateAndConstruct _{_ - _}pπ, iπ,_ syntax,safety,determinism� **then** _▷_ see §3.3.3
> _←_     -     
> 
> 
> 12: _α_ _α_ �( _pπ, iπ, oπ_ )� _▷_ update _deduction_ or _abduction_ buffers
> _D_ _←D_ _∪_
> 
> 13:14: **for all** ( _x, y α_ _[⋆]_ _∈{_ ) dedSamplePrepareTasks _,_ abd _,_ ind _}_ **do** - _α, B, t_ - _▷x, y_ _[⋆]_ prepared based on _α▷_ **SOLVE PHASE** and _t_, see §3.3.3
> _←_ _D_
> 
> [solve]
> 
> 
> 
> 15: _yπ_ _πθ_ [solve] ( _x_ )
> _∼_
> 
> 
> 
> 16: **Reward:** Use proposed task triplets and solved answers to get _rpropose_ & _rsolve_ _▷_ see §3.1
> 17: **RL update:** use Task Relative REINFORCE++ to update _πθ_ _▷_ see §3.3.5
> 
> 
> 
> initialize abduction [=] deduction [=] [where] [=] _[B]_ [where] _[B]_ [is] [the] [batch] [size,] [and] _[S]_ [=] [4] [is] [a] [factor] [we] [fix] [in] [all]
> experiments. _D_ [0] All seed triplet’s program are stripped of global variables and comments (Section _[D]_ [0] _[D]_ [seed][,] _[|D]_ [seed] _[|]_ _[×][ S]_ [,] D), but subsequent iterations of adding
> 
> new triplets to the buffers are unaltered during AZR self-play training. No model updates occur during the seeding phase. Similarly, to
> 
> initialize the induction buffer, we sample programs from seed, generate matching input sets and messages, and collect valid examples
> until _|D_ induction [0] _[|]_ [ =] _[ B][ ×][ S]_ [.] _D_
> 
> 
> 3.3.2. Task Proposal Inputs and Buffer Management
> 
> 
> During the actual self-play stage of AZR, we use the task buffer in three ways. _First_, for the proposer of abduction and deduction tasks,
> we uniformly sample _K_ past triplets from the buffer, present them as in-context examples to the proposer and let it generate a new task.
> The design is to show it past examples, and prompt it to generate a different one to promote diversity (Zhao et al., 2025a). _Second_, we
> sample one triplet from the union of abduction and deduction buffersinduction proposer to generate a set ofa batch of solver problems contains fewer than _N_ matching inputs _B_ valid proposed tasks (proposer not adhering to formatting), we fill the remainder by _{i_ _[n]_ _}_ and a natural language message _D_ abd - _D_ ded, and present the program _m_ . _Lastly_, to maintain stable training, if _p_ from that triplet to the
> 
> uniformly sampling from the corresponding task buffer of previously validated triplets.
> 
> 
> The buffer grows for abduction and deduction tasks whenever _π_ propose a valid triplet ( _p, i, o_ ), regardless if it gets any task reward.
> Similarly, for induction tasks, all valid triplets ( _p,_ _i_ _[n]_ _, o_ _[n]_ ) _, m_ are added to the buffer.
> _{_ _}_
> 
> 
> 3.3.3. Constructing Valid Tasks
> 
> 
> **Proposal Task Validation.** We first describe how we construct valid tasks from the proposals generated by the policy _π_ . For _deduction_
> _and abduction_ tasks, each proposal consists of a program and an input ( _p, i_ ). To validate the task, we use the task validation procedure
> (steps shown below) on the input to obtain the correct output _o_, resulting in a complete triplet ( _p, i, o_ ). For _induction_ tasks, given a
> 
> The resulting task is considered valid only when all inputs yield valid outputs and the formatting requirements are satisfied.programin the set to obtain a corresponding output _p_ the policy proposes a set of inputs _o_ _[n]_ _{_, forming a set of input-output pairs _i_ _[n]_ _}_ and message _m_ . We also use the task validation procedure on each of the input _{i_ _[n]_ _, o_ _[n]_ _}_ . We do not impose any constraints onThe **task** _m i_ _[n]_ .
> **validation procedure** entails:
> 
> 
> 1. _Program Integrity._ We first use Python to run the program _p_ with the input _i_ . If no errors are raised and something is returned, we
> then gather the output _o_ of that ( _p, i_ ) pair and determine that the program at least has valid syntax.
> 
> 
> 2. _Program Safety._ We also check whether a program is safe for execution by restricting the use of certain sensitive packages that might
> cause harm to the Python environment, _i.e_ ., `os.sys,` `sys,` `shutil` . The list of packages used to filter out invalid programs is
> 
> 
> 7
> 
> 
> **Absolute Zero:** **Reinforced Self-play Reasoning with Zero Data**
> 
> 
> provided in Figure 10. This list is also included in the instructions when prompting the language model to generate questions. See
> 
> Figures 36 to 38.
> 
> 3. _Check for Determinism._ of all valid programs andIn our setting, we only consider _I_ is the space of all valid inputs. _deterministic programs_ Deterministic programs satisfy:, _i.e_ ., _p ∈_ _P_ deterministic _⊂_ _P_, where _P_ is the space
> 
> 
> 
> 
>        _∀p ∈_ _P_ deterministic _,_ _∀i ∈_ _I,_
> 
> 
> 
> 
>           lim [=] _[ p]_ [(] _[i]_ [)][(2)] [=] _[ · · ·]_ [ =] _[ p]_ [(] _[i]_ [)][(] _[j]_ [)]
> _j→∞_ _[p]_ [(] _[i]_ [)][(1)]
> 
> 
> 
> _,_ (7)
> 
> 
> 
> where ( _j_ ) indexes repeated independent executions of the program. That is, for all inputs _i_, the output of _p_ ( _i_ ) remains identical
> with any independent execution of the program. A _valid program/input/output triplet_ ( _p, i, o_ ) is defined such that _o_ = _p_ ( _i_ ), where
> _p ∈_ _P_ deterministic.
> Since the output of probabilistic programs can vary on every individual run, it is non-trivial to use verifiable functions to evaluate the
> 
> correctness of an answer. Therefore, to keep the verifier simple, we restrict the valid programs generated by the learner to the class
> 
> of deterministic programs. We believe that stochastic programs can encompass a larger class of behaviors and are important and
> 
> promising to include in future versions of AZR.
> 
> To implement the filtering of invalid probabilistic programs, and following the definition of a deterministic program highlighted in
> Equation (7), we approximate this procedure by independently running the program _j_ finite times and checking that all the outputs
> are equal. For computational budget reasons, we fixed _j_ = 2 for all experiments. See Figure 15 for how we did this in python.
> 
> 
> **Solving Task Construction.** If a task proposal passes these three checks, we deem it a valid task and apply appropriate procedures to
> present part of the triplet to the solver. Specifically, given _x_ is a task query, we set _x_ = ( _p, i_ ) for deduction; _x_ = ( _p, o_ ) for abduction;
> andfrom timestep _x_ = ( _{i_ _[n]_ _, o t_ ; if the batch _[n]_ _}n_ _[N//]_ =1 [2] _[, m]_ [)] _B_ [ for induction, where half of the tests cases and a program description] is not full, we uniformly sample from previously validated tasks to fill the batch. _[ m]_ [ is used.] [We use all valid tasks]
> 
> 
> 3.3.4. Answer Verification
> 
> 
> For abduction task, we receive _iπ_ from the solver policy, then we equivalence match using _p_ ( _iπ_ ) = _p_ ( _i_ _[⋆]_ ), where refers to the
> privileged gold information. The reason we do not just match _iπ_ and _i_ _[⋆]_ is because _p_ is not necessarily bijective. For deduction task, we _∗_
> matchrecommend the reader to see how we did abduction, deduction and induction verification in code in Figures _oπ_ = _o_ _[⋆]_ . For induction, we match all( _{pπ_ ( _i_ _[⋆]_ _n_ [) =] _[ o][⋆]_ _n_ _[}][N]_ [)][.] [This part might be convoluted to explain in language, therefore we] 12 to 14, respectively.
> 
> 
> 3.3.5. Task-Relative REINFORCE++
> 
> 
> Since AZR trains the combination of roles and task types, it operates in a multitask reinforcement learning setup (Zhang & Yang, 2021;
> 
> Zhao et al., 2022; Wang et al., 2023; Yue et al., 2023). Instead of computing a single global baseline as in REINFORCE++ (Hu, 2025)
> 
> (Section A), we compute separate baselines for each of the six task-role configurations. This can be viewed as an interpolation between
> 
> per-question baselines, as in GRPO (Shao et al., 2024), and a global baseline, allowing for more structured variance reduction tailored to
> each task setup. We refer to this variant as **Task-Relative REINFORCE++ (TRR++)** . The normalized advantage _A_ [norm] is computed as:
> 
> _A_ task,role [norm] [=] _[r][ −]_ _[µ]_ [task,role] _,_ task ind,ded,abd _,_ role propose,solve _,_ (8)
> 
> _σ_ task,role _∈{_ _}_ _∈{_ _}_
> 
> 
> where the mean and standard deviation are computed _within each task type and role_, yielding six baselines.
> 
> 
> **4. Experiments**
> 
> 
> **4.1. Experiment Setup**
> 
> 
> **Training Details.** For all experiments, we initialize the buffers as described in Section 3.1. AZR models are trained using a batch
> size of 64 6 (2 roles 3 task types). We use constant learning rate= 1 _e_ 6 and the AdamW optimizer (Loshchilov & Hutter, 2019).
> Complete list of hyperparameters is provided in Table _×_ _×_ 3. _−_
> 
> 
> For the main experiments, we train AZR models on `Qwen2.5-7B` and `Qwen2.5-7B-Coder`, resulting in `Absolute`
> `Zero` `Reasoner-base-7B` and `Absolute` `Zero` `Reasoner-Coder-7B`, respectively. Additional experiments include training
> `Qwen2.5-Coder-3B`, `Qwen2.5-Coder-14B`, `Qwen2.5-14B`, `Llama-3.1-8B` (Yang et al., 2024a; Hui et al., 2024; Dubey et al.,
> 
> 2024).
> 
> 
> **Evaluation Protocol.** To evaluate our models, we divide the benchmarks into in-distribution (ID) and out-of-distribution (OOD)
> 
> categories. For OOD benchmarks, which we emphasize more, we further categorize them into coding and mathematical reasoning
> 
> benchmarks. For coding tasks, we evaluate using Evalplus (Liu et al., 2023) on the HumanEval+ and MBPP+ benchmarks (Chen et al.,
> 
> 2021; Austin et al., 2021), as well as LiveCodeBench Generation (v1-5, May 23-Feb 25) (Jain et al., 2024). For mathematical reasoning,
> 
> 
> 8
> 
> 
> **Absolute Zero:** **Reinforced Self-play Reasoning with Zero Data**
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
> 
> 
> 
> 
> 
> 
> 
> _Table 1._ **Performance of RL-Trained Reasoner on Reasoning Benchmarks Based on Qwen2.5-7B Models.** Performance of various
> models is evaluated on three standard code benchmarks (HumanEval [+], MBPP [+], LCB [v1-5] and six math benchmarks (AIME’24, AIME’25,
> 
> AMC’23, MATH500, Minerva, OlympiadBench). Average performance across coding and math benchmarks is calculated as average of
> the two averages: AVG = (CAvg + MAvg) _/_ 2. We use + for absolute percentage increase from base model. All models are trained using
> different variants of the `Qwen2.5-7B` model, with the variant and data usage labeled, more details listed in Table 4
> 
> 
> we utilize six standard benchmarks commonly used in recent “zero” reasoners: AIME’24, AIME’25, OlympiadBench (He et al., 2024),
> 
> Minerva (Lewkowycz et al., 2022), Math500 (Hendrycks et al., 2021), and AMC’23. For ID benchmarks, we use CruxEval-I(nput),
> 
> CruxEval-O(utput), and LiveCodeBench-Execution (Gu et al., 2024; Jain et al., 2024), which assess reasoning capabilities regarding the
> 
> input and output of programs (Li et al., 2025). _Greedy decoding_ is used for all baseline methods and AZR results to ensure reproducibility.
> 
> All baseline models’ training data and initialization settings are summarized in Table 4.
> 
> 
> **Baselines.** For our main results, we use `Qwen2.5-7B` as the base model, along with its specialized base model variants:
> `Qwen2.5-7B-Coder`, `Qwen2.5-7B-Instruct`, and `Qwen2.5-Math-7B` (Yang et al., 2024a; Hui et al., 2024; Yang et al., 2024b).
> Furthermore, the zero-style models are usually trained specifically on either code or math data; and only `Eurus-2-7B-PRIME-Zero` (Cui
> et al., 2025) was trained jointly on both domains. For code data models, we present four variants of the `AceCoder` (Zeng et al., 2025a)
> and two different `CodeR1` models (Liu & Zhang, 2025). For math data models, we have `Qwen2.5-Math-7B-Oat-Zero` (Liu et al.,
> 2025c), `Open-Reasoner-Zero-7B` (ORZ) (Hu et al., 2025), `Qwen-2.5-7B-SimpleRL-Zoo` (Zeng et al., 2025b). All baseline models’
> 
> training data and initialization settings are summarized in Table 4. For follow-up scaling experiments, we compare each AZR model
> 
> against its own corresponding base model, due to the lack of established baselines across different parameter scales. Finally, we compare
> 
> our `Llama3.1-8B` -trained model with `Llama-3.1-8B-SimpleRL-Zoo` (Zeng et al., 2025b) and the base model.
> 
> 
> **4.2. Results**
> 
> 
> **Research Question 1:** **How does AZR compare to other zero setting models trained with human expert**
> **data?** We present the main results of reasoning models trained under both the standard zero and our proposed absolute zero settings
> in Table 1. Notably, `Absolute` `Zero` `Reasoner-Coder-7B` achieves _state-of-the-art performance_ in both the 7B overall average and
> 
> the coding average categories. Despite being entirely out-of-distribution for both math and code reasoning benchmarks, it surpasses
> the previous best model by 1 _._ 8 absolute percentages in AVG. Even more strikingly, it outperforms models trained with expert-curated
> human data in the coding category (CAvg) by 0 _._ 3 absolute percentages, while never having access to such human-curated data itself.
> 
> 
> **Strong Cross-domain Generalization.** To assess cross-domain generalization after RLVR, we evaluate math performance before and
> 
> after training, comparing AZR models with other expert code models, since AZR was trained in coding environments. After training,
> 
> most expert code models showed minimal changes or even declines in performance compared to their base versions in math, with an
> 
> average increase of only 0.65 points across these models, indicating very limited cross-domain generalization. In contrast, AZR base and
> 
> coder models achieved gains of 10.9 and 15.2 percentage points, respectively, demonstrating substantially stronger generalized reasoning
> 
> improvements. Similarly, although also out-of-distribution on human-defined code generation tasks, our AZR models improved by 3.2
> 
> and 5.0 points, while the math models on average showed just a moderate increases in coding (+2.0 on average).
> 
> 
> 9
> 
> 
> 0 _._ 70
> 
> 
> 0 _._ 65
> 
> 
> 0 _._ 60
> 
> 
> 0 _._ 55
> 
> 
> 0 _._ 50
> 
> 
> 0 _._ 45
> 
> 
> 0 _._ 40
> 
> 
> 0 _._ 35
> 
> 
> 0 _._ 30
> 
> 
> |Col1|Col2|Col3|Col4|Col5|Col6|Col7|Col8|Col9|Col10|
> |---|---|---|---|---|---|---|---|---|---|
> |||||||||||
> |||||||||||
> |||||||||||
> |||||||||||
> |||||||||||
> |||||||||||
> |||||||||er|er|
> |||AZ|-Llama|3.1-8b||AZR|7B-Co|er|er|
> |||AZR|-3B-Co|der||AZR-|14B-Co|der|der|
> 
> 
> 
> 50 75 100 125 150 175 200 225 250
> Training Steps
> 
> 
> **(a)**
> 
> 
> 
> **Absolute Zero:** **Reinforced Self-play Reasoning with Zero Data**
> 
> 
> **Model Family** **Variant** **Code Avg** **Math Avg** **Total Avg**
> 
> 
> 
> 
> 
> 
> 
> Llama3.1-8b 28.5 3.4 16.0
> 
> 
> Qwen2.5-3B Coder 51.2 18.8 35.0
> Qwen2.5-3B Coder + AZR (Ours) 54 _._ 9 [+3] _[.]_ [7] 26 _._ 5 [+7] _[.]_ [7] 40 _._ 7 [+5] _[.]_ [7]
> 
> 
> Qwen2.5-7B Coder 56.6 23.9 40.2
> Qwen2.5-7B Coder + AZR (Ours) 61 _._ 6 [+5] _[.]_ [0] 39 _._ 1 [+15] _[.]_ [2] 50 _._ 4 [+10] _[.]_ [2]
> 
> 
> Qwen2.5-14B Coder 60.0 20.2 40.1
> Qwen2.5-14B Coder + AZR (Ours) 63 _._ 6 [+3] _[.]_ [6] 43 _._ 0 [+22] _[.]_ [8] 53 _._ 3 [+13] _[.]_ [2]
> 
> **(b)**
> 
> 
> 
> _Figure 6._ **(a)** **In-Distribution** **&** **(b)** **Out-of-Distribution** **Reasoning** **Task** **Performances.** **(a)** Scores on CruxEval-I, CruxEval-O,
> 
> and LiveCodeBench-Execution, which correspond to abduction, deduction, and deduction task types respectively, used to evaluate
> 
> in-distribution abilities of AZR during training across different model sizes and types; **(b)** Out-of-distribution reasoning performance,
> 
> reported as the average of code tasks, math tasks, and their overall average, across different model sizes and types. A detailed breakdown
> 
> of all benchmark results can be found in Table 5.
> 
> 
> Overall, these results highlight the surprising effectiveness of our approach. Unlike other RLVR models trained and evaluated on
> 
> human-defined tasks, our AZR models demonstrate strong general reasoning capabilities without any direct training on downstream
> 
> human-defined math or coding data, only had access to self-proposed tasks during training, yet still psrpassing existing models.
> 
> 
> **Research** **Question** **2:** **How** **do** **initializing** **from** **different** **base** **model** **variants** **(base** **vs.** **coder)** **affect**
> **performance?** As shown in Table 1, the coder variant achieved better overall performance in both math and coding after the AZR
> 
> self-play process. Strikingly, although the coder base model variant started with a lower average performance in math than the vanilla
> 
> base model (23.9 vs. 27.5), it ultimately outperformed it after AZR training. This highlights the importance of initial code competency
> 
> as a catalyst for enhancing broader reasoning abilities within the Absolute Zero Reasoner approach.
> 
> 
> **Research Question 3:** **How does varying model size effect AZR’s in-distribution and out-of-distribution**
> **capabilities?** We examine the effects of scaling model size and present both in-distribution and out-of-distribution results in Figure 6
> 
> (a) and (b), respectively. Given the strong performance of coder models in the 7B category, we extend the analysis by evaluating smaller
> 
> and larger variants: `Qwen2.5-3B-Coder` and `Qwen2.5-14B-Coder` . Due to the absence of existing baselines for these zero-style
> 
> reasoner model sizes, we compare each model’s performance to its corresponding base coder model.
> 
> 
> The results reveal a clear trend: our method delivers _greater gains on larger, more capable models_ . In the in-distribution setting, the 7B
> 
> and 14B models continue to improve beyond 200 training steps, whereas the smaller 3B model appears to plateau. For out-of-distribution
> 
> domains, larger models also show greater overall performance improvements than smaller ones: +5.7, +10.2, +13.2 overall performance
> 
> gains, respectively for 3B, 7B and 14B. This is an encouraging sign, since base models continue to improve and also suggesting that
> 
> scaling enhances the effectiveness of AZR. In future work, we aim to investigate the scaling laws that govern performance in the Absolute
> 
> Zero paradigm.
> 
> 
> **Research Question 4:** **Any interesting observations by changing the model class?** We also evaluate our method
> on a different model class, using `Llama3.1-8B` as the base shown in Figure 6. Unlike the 3B and 14B categories, this setting has an
> existing baseline, `SimpleRL` (Zeng et al., 2025b), which enables a direct comparison. Although `Llama3.1-8B` is less capable than
> the `Qwen2.5` models, our method still produces moderate improvements (+3.2), demonstrating AZR’s effectiveness even on relatively
> 
> weaker models. However, these gains appear more limited, which aligns with our earlier observation that performance improvements
> 
> tend to scale with initial base model potency.
> 
> 
> **Research Question 5:** **Any interesting behaviors or patterns observed during AZR training?** We observed
> 
> interesting response patterns in both the proposal and solution stages. The model is capable of proposing diverse programs, such as
> 
> string manipulation tasks, dynamic programming problems, and practical cases ( _e.g_ ., calculating a triangle’s area using Heron’s formula).
> 
> We show a concrete example in Figure 7, where AZR proposes a code problem that searches for the sum of continuous sub-arrays
> 
> matching a target value and solves it through trial-and-error.
> 
> 
> Overall, the models trained exhibits distinct reasoning patterns depending on the task type. For example, when solving abduction tasks,
> 
> it repeatedly tests different input patterns, self-correcting until the reasoned output matches the given input. When predicting outputs,
> 
> it steps through the code and records structured intermediate results (such as dynamic programming arrays) until the final output is
> 
> 
> 10
> 
> 
> **Absolute Zero:** **Reinforced Self-play Reasoning with Zero Data**
> 
> ### Model-proposed Task Response of Predict Input
> 
> 
> 
> Input: [1,2,3,4,5], 5
> 
> 
> Output: 1
> 
> 
> 
> Let’s analyze the code snippet **…(analysis)** To find one possible input that produces
> the output 1, we need to find a scenario where **…(analysis)**
> **Let’s consider a simple example: numbers = [1, 2], target = 1**
> **Here’s the step-by-step calculation:**
> 1. current_sum = 0 + 1 = 1, accumulated_values = [1]
> 2. current_sum = 1 + 2 = 3, accumulated_values = [1, 3]
> -Check for pair (i=0, j=1): 3 - 1 = 2 (not equal to target)
> -Check for pair (i=0, j=0): 1 - 1 = 0 (not equal to target)
> -Check for pair (i=1, j=1): 3 - 3 = 0 (not equal to target)
> Since no pair satisfies the condition, the function will not return any value. This
> doesn’t match our output. Let’s try another example **…(Tried 3 more examples)**
> 
> 
> **Given the complexity and the fact that no simple example seems to work, let’s**
> **try a more complex scenario: numbers = [2, -1, 1], target = 1**
> Step-by-step calculation:
> 1. current_sum = 0 + 2 = 2, accumulated_values = [2]
> 2. current_sum = 2 - 1 = 1, accumulated_values = [2, 1]
> 3. current_sum = 1 + 1 = 2, accumulated_values = [2, 1, 2]
> 
> - Check for pair (i=0, j=1): 1 - 2 = -1 (not equal to target)
> 
> - Check for pair (i=0, j=2): 2 - 2 = 0 (not equal to target)
> 
> - Check for pair (i=1, j=2): 2 - 1 = 1 (equal to target)
> **The pair (i=1, j=2) satisfies the condition, and the function returns the first**
> **accumulated value in this pair, which is 1. This matches our output.**
> 
> 
> 
> _Figure 7._ **Example of a Model-Proposed Task and Its Response for Solving an Abduction Task.** (Left) The model autonomously
> 
> proposes an input and program for the abduction task. We execute the program to verify its validity and obtain the corresponding output.
> 
> (Right) The model’s reasoning process when solving the abduction task: given the code and output, it attempts to infer the original input.
> 
> The model begins by analyzing the program, proposes an initial input, and reasons through the code to produce an output. If there is a
> 
> mismatch, it reflects on the discrepancy and iteratively adjusts the input until the generated output matches the target. Interestingly, the
> 
> agent arrives at a different input than the gold one, but since it produces the correct output, the answer is considered correct.
> 
> 
> reached. When inducting programs from given inputs, outputs, and descriptions, the model systematically checks each test case to
> 
> confirm that its program produces correct results. We showcase more concrete examples of these behaviors in Figures 20 and 22 to 28.
> 
> [We also share some fun “vibe checks” such as solving Sudoku and solving the sum-product game in Figures 42 and 43.](https://en.wikipedia.org/wiki/Sum_and_Product_Puzzle)
> 
> 
> **Intermediate Planning During Code Response.** Another interesting pattern emerged in our AZR models during the code induction
> 
> task: the final code outputs were often interleaved with comments that resembled immediate step-by-step plans, reminiscent of the ReAct
> 
> prompting framework (Yao et al., 2023). A similar behavior has been observed in recent formal math proving models, such as `DeepSeek`
> `Prover` `v2`, which is significantly larger in scale (671B). This pattern suggests that models may naturally adopt intermediate planning
> as a strategy to enhance final answers. Therefore, it may be beneficial to explicitly enable or encourage this behavior in _long-form_
> _responses_ across other domains.
> 
> 
> **Cognitive** **Behavior** **in** **Llama.** Interestingly, we also observed some emergent cognitive patterns in `Absolute` `Zero`
> `Reasoner-Llama3.1-8B`, similar to those reported by Zeng et al. (2025b), and we include one example in Figure 28, where
> 
> clear state-tracking behavior is demonstrated. In addition, we encountered some unusual and potentially concerning chains of thought
> 
> from the Llama model trained with AZR. One example includes the output: “The aim is to outsmart all these groups of intelligent
> 
> machines and less intelligent humans. This is for the brains behind the future” shown in Figure 34. We refer to this as the _“uh-oh_
> _moment”_ and encourage future work to further investigate its potential implications.
> 
> 
> **Token Length Increase Depends on Task Type.** Finally, we observed that token length increases over the course of training, consistent
> 
> with findings from recent studies (Hu et al., 2025; Liu et al., 2025c). Interestingly, our results reveal one of the first observation of clear
> 
> distinctions in token length growth across different types of cognitive tasks. As shown in Figures 17 to 19, the extent of lengthening
> 
> varies by task type. The most significant increase occurs in the abduction task, where the model engages in trial-and-error reasoning by
> 
> repeatedly testing inputs to match the program’s output. This suggests that the observed variation in token length is not incidental, but
> 
> rather a reflection of task-specific reasoning behavior.
> 
> 
> **Research Question 6:** **Are all task types essential for good performance (Ablation)?** Due to resource constraints,
> we perform the ablation studies in this section and the next using only `Absolute` `Zero` `Reasoner-Base-7B` . We begin by testing the
> 
> importance of task types during training, with results shown in Table 2. In row 1, both induction and abduction tasks are removed;
> 
> in row 2, only the induction task is removed. In both cases, math performance drops significantly, with the most severe degradation
> 
> occurring when more task types are excluded. These findings highlight the complementary role of the three task types in improving
> 
> general reasoning capability, with each contributing in a distinct and essential way.
> 
> 
> 11
> 
> 
> **Absolute Zero:** **Reinforced Self-play Reasoning with Zero Data**
> 
> 
> Experiment Task Type Gen Reference Trained Roles **Code Avg.** **Math Avg.** **Overall Avg.**
> 
> 
> Deduction only Ded / / 54.6 32.0 43.3
> 
> w/o Induction Abd, Ded / / 54.2 33.3 43.8
> 
> w/o Gen Reference / 0 / 54.4 33.1 43.8
> 
> Train Solver Only / / Solve Only 54.8 36.0 45.4
> **Ours** Abd, Ded, Ind _K_ Propose & Solve **55.2** **38.4** **46.8**
> 
> 
> _Table 2._ **Ablation Results.** We ablate task types and the proposer role in the Absolute Zero Reasoner using the 7B base model. A ‘/’
> 
> indicates that the configuration remains unchanged from the standard AZR setup. Removing induction or using only deduction leads to
> significant performance drops (rows 1 & 2). For the proposer role, both removing conditioning on _K_ references (row 3) and omitting
> 
> proposer-role training (row 4) result in degraded performance. Overall, all components are essential for general reasoning.
> 
> 
> 
> 
> 
> 60
> 
> 45
> 
> 30
> 
> 15
> 
> 
> 
> 
> 
> 56
> 
> 48
> 
> 40
> 
> 32
> 
> 24
> 
> 
> 
> 90
> 
> 84
> 
> 78
> 
> 72
> 
> 66
> 
> 
> 
> 
> 
> 
> 
> 60
> 
> 
> 45
> 
> 
> 30
> 
> 
> 15
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 96
> 
> 90
> 
> 84
> 
> 78
> 
> 72
> 
> 
> 
> 
> 
> _Figure 8._ **Pass@k Results.** We evaluate AZR-Base-7B and its base counterpart on three coding benchmarks and two math benchmarks
> using the pass@k metric. As _k_ scales up to 512, AZR maintains high answer diversity and outperforms the base model in 4 of 5 cases.
> 
> This favorable property can be further leveraged by test-time scaling methods to improve performance.
> 
> 
> **Research** **Question** **7:** **How** **much** **do** **the** **designs** **of** **proposer** **contribute** **to** **the** **overall** **performance**
> **(Ablation)?** Next, we ablate two components of the proposer role and present the results in Table 2. First, we examine whether
> 
> conditioning on historic reference triplets is necessary. To do so, we design a variant in which a fixed prompt is used to propose abduction
> and deduction tasks, rather than dynamically conditioning on _K_ historical triplets (row 3). This results in a 5-point absolute drop in
> 
> math performance and a 1-point drop in code performance. This suggest that dynamically conditioning on reference programs helps
> 
> improve performance, possibly by increasing diversity and achieving better coverage of the reasoning problem space.
> 
> 
> Finally, we examine a setting where the proposer is not trained. Instead, we prompt it using the current learner and train only the solver
> 
> (row 4). This results in a moderate performance drop (-1.4), indicating that proposer training is indeed beneficial. However, we believe
> 
> there is potential to further enhance the proposer, possibly amplifying gains in general reasoning. One possible direction is to mitigate
> 
> task interference, as discussed in multitask learning literature (Suteu & Guo, 2019), or to introduce explicit incentives that encourage
> 
> broader problem space coverage. Overall, we see improving the proposer as a promising direction to further enhance solver performance
> 
> through their synergistic interaction.
> 
> 
> **Research Question 8:** **What is the relative performance of AZR vs.** **the base model for high pass@k?** We evaluate reasoning
> coverage following Yang et al. (Yue et al., 2025), with temperature 0 _._ 6, top- _p_ 0 _._ 95, max output tokens 16k, and _k_ up to 512, and present
> 
> the results in Figure 9. Across three code benchmarks (LiveCodeBench, MBPP++, HumanEval++) and two math benchmarks (AIME24,
> AIME25), AZR consistently matches or outperforms the base model at high _k_ (256/512), with one exception at AIME24 ( _k_ =512).
> These gains persist at larger _k_, indicating AZR maintains broad reasoning coverage and answer diversity after RL, compatible for further
> 
> test-time scaling (Snell et al., 2024).
> 
> 
> **Research Question 9:** **How do AZR models perform in general reasoning tasks?** We assess AZR-Base-7B on MMLU-Pro (Wang
> 
> et al., 2024b) using greedy decoding and a 16k token limit, and compare against three baselines: ORZ-7B, Qwen2.5-7B, and
> 
> SimpleRL-Zoo-7B. AZR attains higher subject-average and higher overall average, indicating strong general reasoning capabilities
> 
> beyond math and code.
> 
> 
> **Additional Results.** Beyond the core research questions, we present additional results, including the breakdown of individual
> 
> out-of-distribution benchmark scores during training for the 7B base and coder models in Figures 30 and 31, for the 14B base and coder
> 
> model in Figures 32 and 33. For completeness, we also report in-distribution benchmark performance during training for the 7B base
> 
> model in Figure 16. Finally, we invite interested readers to explore Section D, where we share several experimental directions that, while
> 
> not yielding strong performance gains, produced interesting and insightful findings.
> 
> 
> 12
> 
> 
> 1.0
> 
> 
> 0.8
> 
> 
> 
> **Absolute Zero:** **Reinforced Self-play Reasoning with Zero Data**
> 
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
> |AZR-Base-7b ORZ-7b Qwen2.5-Base-7b SimpleRL-7b|Col2|
> |---|---|
> |||
> |||
> |||
> |||
> |<br><br><br><br>||
> 
> 
> 
> _Figure 9._ **General Reasoning.** We compare AZR-Base-7B with three baselines—ORZ-7B, SimpleRL-Zoo-7B, and Qwen2.5-7B, on
> 
> MMLU-Pro (Wang et al., 2024b). AZR-Base-7B attains higher averages both across subjects and across all samples, indicating strong
> 
> general reasoning across 14 diverse subjects/domains.
> 
> 
> **5. Related Work**
> 
> 
> **Reasoning with RL.** Using RL to enhance reasoning capabilities has recently emerged as an important step in the post-training
> 
> process of strong reasoning-focused large language models (Lambert et al., 2024). One of the first works to explore a self-bootstrapping
> 
> approach to improving LLM reasoning is STaR, which employs expert iteration and rejection sampling of outcome-verified responses to
> 
> iteratively improve the model’s CoT. A monumental work, o1 (Jaech et al., 2024), was among the first to deploy this idea on a scale,
> 
> achieving state-of-the-art results in reasoning tasks at the time of release. More recently, the R1 model (Guo et al., 2025) became
> 
> the first open-weight model to match or even surpass the performance of o1. Most notably, the zero setting was introduced, in which
> 
> reinforcement learning is applied directly on top of the base LLM. This inspired followup work, which are open source attempts to
> 
> replicate the R1 process or to improve the underlying reinforcement learning algorithm (Zeng et al., 2025b; Liu et al., 2025c; Cui et al.,
> 
> 2025; Hu et al., 2025; Yu et al., 2025; Yuan et al., 2025). Recent work explored RL on human defined procedural generated puzzles saw
> 
> improvements in math (Xie et al., 2025), and using one human example can almost match the performance of thousands (Wang et al.,
> 
> 2025c). We extend the zero setting to a new absolute zero setting, where not only is the RLVR process initialized from a base LLM
> 
> without SFT, but no external prompt data or answers are provided to the learner. All data used to improve reasoning were self-proposed,
> 
> and refined entirely through RLVR. Moreover, our goal is not to only match zero-setting models, but to surpass them in the long run.
> 
> 
> **Self-play.** The self-play paradigm can be traced back to early 2000s, where Schmidhuber (2003; 2011) (of course) explored a
> 
> two-agent setup in which a proposal agent invents questions for a prediction agent to answer. This dynamic continuously and automatically
> 
> improves both agents, enabling theoretically never-ending progress (Schaul, 2024). AlphaGo and AlphaZero (Silver et al., 2016; 2017)
> 
> extend the self-play paradigm to the two-player zero-sum game of Go, where the current learner competes against earlier versions of
> 
> itself to progressively enhance its capabilities. These were among the first milestone works to demonstrate superhuman performance in
> 
> the game of Go. Moreover, areas such as asymmetric self-play (Sukhbaatar et al., 2018; OpenAI et al., 2021), unsupervised environment
> 
> design (Wang et al., 2019; Dennis et al., 2020), unsupervised reinforcement learning (Laskin et al., 2021; Zhao et al., 2022; 2025b),
> 
> autotelic agents (Colas et al., 2022a;b; Haluptzok et al., 2023), and automatic goal generation (Florensa et al., 2018) all center around
> 
> inventing new tasks for an agent to learn from—typically without supervision. In these approaches, the process of setting goals itself is
> 
> often dynamic and continuously evolving. Generative adversarial networks (Goodfellow et al., 2020), also belong in this paradigm
> 
> where a discriminator discriminate between real data and generated data, and the generated is trained to fool the discriminator.
> 
> 
> Most recently, SPIN and Self-Rewarding Language Models (Chen et al., 2024; Yuan et al., 2024) use the same instance of the language
> 
> models themselves as the reward model to progressively improve the generative and discriminative abilities of the same LLM for
> 
> alignment. (Kirchner et al., 2024) uses Prover-Verifier Game for increasing legibility and eva (Ye et al., 2024) uses self-play for
> 
> alignment, but reward model is the main bottleneck as it is not reliable for reasoning tasks (Lambert et al., 2024). SPC (Chen et al.,
> 
> 2025) used self-play to train on human-curated tasks to increase the critic capabilities and SPAG (Cheng et al., 2024) trained using
> 
> self-play in specific game of Adversarial Taboo. Concurrent works, Genius, EMPO, and TTRL (Xu et al., 2025; Zhang et al., 2025b;
> 
> Zuo et al., 2025) leverage human-curated language queries without labels to train RL agents, but still rely on a fixed human defined
> 
> learning task distribution. Moreover, Minimo (Poesia et al., 2024) extends self-play to formal mathematics, where a pair of conjecture
> and theorem-proving agents are jointly trained using reinforcement learning. Finally, (Liu et al., 2025a) obtained good reasoning
> 
> performance by self-play training on zero-sum games and (Liu et al., 2025b) uses self-play for alignment. Our work builds upon the
> 
> self-play paradigm, but it is the first to use it to elicit long CoT for improved reasoning, and the first to frame the problem space as a
> 
> 
> 13
> 
> 
> **Absolute Zero:** **Reinforced Self-play Reasoning with Zero Data**
> 
> 
> Python input/output/function abduction/deduction/induction tasks, grounding it in an operationalizable environment to facilitate RLVR.
> 
> 
> **Weak-to-Strong Supervision.** The concept of weak-to-strong supervision has been studied in prior work, where a teacher—despite
> 
> being weaker than the learner—still provides useful guidance (Burns et al., 2024; Hinton et al., 2015; Christiano, 2018; 2019; Demski &
> 
> Garrabrant, 2019; Leike & Sutskever, 2023; Hubinger et al., 2019). We consider a similar setting in which the learner may possess
> 
> superhuman capabilities. However, rather than relying on supervision from a weaker teacher, we propose an alternative approach:
> 
> guiding the learner’s improvement through verifiable rewards, which potentially offer a more reliable and scalable learning signal.
> 
> Furthermore, in our proposed method, the learning task and goal distribution is not predefined by any external supervisor—they are
> 
> entirely self-generated by the learner, enabling it to maximize its learning potential through autonomous self-practice.
> 
> 
> **6. Conclusion and Discussion**
> 
> 
> **Conclusion.** In this work, we proposed the Absolute Zero paradigm, a novel setting that addresses the data limitations of existing
> 
> RLVR frameworks. In this paradigm, reasoning agents are tasked with generating their own learning task distributions and improving
> 
> their reasoning abilities with environmental guidance. We then presented our own instantiation, the Absolute Zero Reasoner (AZR),
> 
> which is trained by having them propose and solve code-related reasoning tasks grounded by code executor.
> 
> 
> We evaluated our trained models on out-of-distribution benchmarks in both the code generation and mathematical reasoning domains.
> 
> Remarkably, even though our models were not directly trained on these tasks and lacked human expert-curated datasets, our reasoning
> 
> agents achieved exceptional performance, surpassing the state-of-the-art in combined general reasoning scores and in coding. This
> 
> demonstrates the potential of the absolute zero paradigm to drive superior reasoning capabilities without the need for extensive
> 
> domain-specific training data. Furthermore, we showed that AZR scales efficiently, offering strong performance across varying model
> 
> sizes, and can enhance the capabilities of other model classes as well. To foster further exploration and advancement of this emerging
> 
> paradigm, we are releasing the code, models, and logs as open-source, encouraging the research community to build upon our findings.
> 
> 
> **Discussion.** We believe there remains much to explore, such as altering the environment from which the reasoner receives verifiable
> 
> feedback, including sources like the world wide web, formal math languages (Sutton, 2001; Ren et al., 2025), world simulators, or even
> 
> the real world. Furthermore, AZ’s generality could possibly be extend to domains such as embodied AI (Zitkovich et al., 2023; Yue et al.,
> 
> 2024). Additionally, more complex agentic tasks or scientific experiments, present exciting opportunities to further advance the absolute
> 
> zero setting to different application domains (Wu et al., 2024; 2023). Beyond that, future directions could include exploring multimodal
> reasoning models, modifying the distribution _p_ ( _z_ ) to incorporate privileged information, defining or even let the model dynamically
> learn how to define _f_ (Equation (3)), or designing exploration/diversity rewards for both the propose and solve roles. Another promising
> 
> direction is to better estimate the learning progress, with recent works like MAGELLAN is pioneering in this direction (Gaven et al.,
> 
> 2025).
> 
> 
> While underappreciated in current reasoning literature, the exploration component of RL has long been recognized as a critical driver for
> 
> emergent behavior in traditional RL (Yue et al., 2025; Silver et al., 2016; Ladosz et al., 2022; Pourcel et al., 2024). Years of research
> 
> have examined various forms of exploration, even in related subfields using LLMs such as red teaming (Zhao et al., 2025a), yet its
> 
> role in LLM reasoning models remains underexplored. Taking this a step further, our framework investigates an even more meta-level
> 
> exploration problem: exploration within the learning task space—where the agent learns not just how to solve tasks, but what tasks to
> 
> learn from and how to find them. Rather than being confined to a fixed problem set, AI reasoner agents may benefit from dynamically
> 
> defining and refining their own learning tasks. This shift opens a powerful new frontier—where agents explore not only solution spaces
> 
> but also expand the boundaries of problem spaces. We believe this is a promising and important direction for future research.
> 
> 
> One limitation of our work is that we did not address how to safely manage a system composed of such self-improving components.
> 
> To our surprise, we observed several instances of safety-concerning CoT from the `Llama-3.1-8B` model, which we term the “uh-oh
> 
> moment”. These findings suggest that the proposed absolute zero paradigm, while reducing the need for human intervention for curating
> 
> tasks, still necessitates oversight due to lingering safety concerns and is a critical direction for future research (Wang et al., 2024a; 2025a).
> 
> 
> As a final note, we explored reasoning models that possess experience—models that not only solve given tasks, but also define and
> 
> evolve their own learning task distributions with the help of an environment. Our results with AZR show that this shift enabloveres
> 
> strong performance across diverse reasoning tasks, even with significantly fewer privileged resources, such as curated human data. We
> 
> believe this could finally free reasoning models from the constraints of human-curated data (Morris, 2025) and marks the beginning of a
> 
> new chapter for reasoning models: **“welcome to the era of experience”** (Silver & Sutton, 2025; Zhao et al., 2024).
> 
> 
> **Acknowledgements**
> 
> 
> This work is supported in part by the National Key R&D Program of China under Grant 2022ZD0114903, the National Natural Science
> 
> Foundation of China under Grants U24B20173 and W2442032 and W2442033, and the Scientific Research Innovation Capability
> 
> Support Project for Young Faculty under Grant ZYGXQNJSKYCXNLZCXM-I20.
> 
> 
> 14
> 
> 
> **Absolute Zero:** **Reinforced Self-play Reasoning with Zero Data**
> 
> 
> **References**
> 
> 
> Aryabumi, V., Su, Y., Ma, R., Morisot, A., Zhang, I., Locatelli, A., Fadaee, M., Üstün, A., and Hooker, S. To code, or not
> 
> to code? exploring impact of code in pre-training. _CoRR_, abs/2408.10914, 2024. doi: 10.48550/ARXIV.2408.10914. URL
> `[https://doi.org/10.48550/arXiv.2408.10914](https://doi.org/10.48550/arXiv.2408.10914)` .
> 
> 
> Austin, J., Odena, A., Nye, M. I., Bosma, M., Michalewski, H., Dohan, D., Jiang, E., Cai, C. J., Terry, M., Le, Q. V., and Sutton, C.
> 
> Program synthesis with large language models. _CoRR_, abs/2108.07732, 2021. URL `[https://arxiv.org/abs/2108.07732](https://arxiv.org/abs/2108.07732)` .
> 
> 
> Burns, C., Izmailov, P., Kirchner, J. H., Baker, B., Gao, L., Aschenbrenner, L., Chen, Y., Ecoffet, A., Joglekar, M., Leike, J.,
> 
> Sutskever, I., and Wu, J. Weak-to-strong generalization: Eliciting strong capabilities with weak supervision. In _Forty-first_
> _International_ _Conference_ _on_ _Machine_ _Learning,_ _ICML_ _2024,_ _Vienna,_ _Austria,_ _July_ _21-27,_ _2024_ . OpenReview.net, 2024. URL
> `[https://openreview.net/forum?id=ghNRg2mEgN](https://openreview.net/forum?id=ghNRg2mEgN)` .
> 
> 
> Canal, M. Radon: Python tool for code metrics. `[https://github.com/rubik/radon](https://github.com/rubik/radon)`, 2023. Accessed: 2025-04-06.
> 
> 
> Chen, J., Zhang, B., Ma, R., Wang, P., Liang, X., Tu, Z., Li, X., and Wong, K.-Y. K. Spc: Evolving self-play critic via adversarial games
> 
> for llm reasoning, 2025. URL `[https://arxiv.org/abs/2504.19162](https://arxiv.org/abs/2504.19162)` .
> 
> 
> Chen, M., Tworek, J., Jun, H., Yuan, Q., de Oliveira Pinto, H. P., Kaplan, J., Edwards, H., Burda, Y., et al. Evaluating large language
> 
> models trained on code. _CoRR_, abs/2107.03374, 2021. URL `[https://arxiv.org/abs/2107.03374](https://arxiv.org/abs/2107.03374)` .
> 
> 
> Chen, Z., Deng, Y., Yuan, H., Ji, K., and Gu, Q. Self-play fine-tuning converts weak language models to strong language models. In
> 
> _Forty-first International Conference on Machine Learning, ICML 2024, Vienna, Austria, July 21-27, 2024_ . OpenReview.net, 2024.
> URL `[https://openreview.net/forum?id=O4cHTxW9BS](https://openreview.net/forum?id=O4cHTxW9BS)` .
> 
> 
> Cheng, P., Hu, T., Xu, H., Zhang, Z., Dai, Y., Han, L., Du, N., and Li, X. Self-playing adversarial language game enhances LLM
> 
> reasoning. In Globersons, A., Mackey, L., Belgrave, D., Fan, A., Paquet, U., Tomczak, J. M., and Zhang, C. (eds.), _Advances in_
> _Neural Information Processing Systems 38:_ _Annual Conference on Neural Information Processing Systems 2024, NeurIPS 2024,_
> _Vancouver,_ _BC, Canada,_ _December 10 - 15,_ _2024_, 2024. URL `[http://papers.nips.cc/paper_files/paper/2024/hash/](http://papers.nips.cc/paper_files/paper/2024/hash/e4be7e9867ef163563f4a5e90cec478f-Abstract-Conference.html)`
> `[e4be7e9867ef163563f4a5e90cec478f-Abstract-Conference.html](http://papers.nips.cc/paper_files/paper/2024/hash/e4be7e9867ef163563f4a5e90cec478f-Abstract-Conference.html)` .
> 
> 
> Christiano, P. Approval-directed bootstrapping. `[https://www.alignmentforum.org/posts/6x7oExXi32ot6HjJv/](https://www.alignmentforum.org/posts/6x7oExXi32ot6HjJv/approval-directed-bootstrapping)`
> `[approval-directed-bootstrapping](https://www.alignmentforum.org/posts/6x7oExXi32ot6HjJv/approval-directed-bootstrapping)`, 2018. AI Alignment Forum.
> 
> 
> Christiano, P. Capability amplification. `[https://www.alignmentforum.org/posts/t3AJW5jP3sk36aGoC/](https://www.alignmentforum.org/posts/t3AJW5jP3sk36aGoC/capability-amplification-1)`
> `[capability-amplification-1](https://www.alignmentforum.org/posts/t3AJW5jP3sk36aGoC/capability-amplification-1)`, 2019. AI Alignment Forum.
> 
> 
> Colas, C., Karch, T., Moulin-Frier, C., and Oudeyer, P. Language and culture internalization for human-like autotelic AI. _Nat. Mac._
> _Intell._, 4(12):1068–1076, 2022a. doi: 10.1038/S42256-022-00591-4. URL `[https://doi.org/10.1038/s42256-022-00591-4](https://doi.org/10.1038/s42256-022-00591-4)` .
> 
> 
> Colas, C., Karch, T., Sigaud, O., and Oudeyer, P. Autotelic agents with intrinsically motivated goal-conditioned reinforcement learning:
> 
> A short survey. _J. Artif. Intell. Res._, 74:1159–1199, 2022b. doi: 10.1613/JAIR.1.13554. URL `[https://doi.org/10.1613/jair.](https://doi.org/10.1613/jair.1.13554)`
> `[1.13554](https://doi.org/10.1613/jair.1.13554)` .
> 
> 
> Cui, G., Yuan, L., Wang, Z., Wang, H., Li, W., He, B., Fan, Y., Yu, T., Xu, Q., Chen, W., Yuan, J., Chen, H., Zhang, K., Lv, X., Wang, S.,
> 
> Yao, Y., Han, X., Peng, H., Cheng, Y., Liu, Z., Sun, M., Zhou, B., and Ding, N. Process reinforcement through implicit rewards.
> 
> _CoRR_, abs/2502.01456, 2025. doi: 10.48550/ARXIV.2502.01456. URL `[https://doi.org/10.48550/arXiv.2502.01456](https://doi.org/10.48550/arXiv.2502.01456)` .
> 
> 
> Demski, A. and Garrabrant, S. Embedded agency. _CoRR_, abs/1902.09469, 2019. URL `[http://arxiv.org/abs/1902.09469](http://arxiv.org/abs/1902.09469)` .
> 
> 
> Dennis, M., Jaques, N., Vinitsky, E., Bayen, A. M., Russell, S., Critch, A., and Levine, S. Emergent complexity and zero
> shot transfer via unsupervised environment design. In Larochelle, H., Ranzato, M., Hadsell, R., Balcan, M., and Lin, H.
> 
> (eds.), _Advances_ _in_ _Neural_ _Information_ _Processing_ _Systems_ _33:_ _Annual_ _Conference_ _on_ _Neural_ _Information_ _Processing_ _Systems_
> _2020,_ _NeurIPS_ _2020,_ _December_ _6-12,_ _2020,_ _virtual_, 2020. URL `[https://proceedings.neurips.cc/paper/2020/hash/](https://proceedings.neurips.cc/paper/2020/hash/985e9a46e10005356bbaf194249f6856-Abstract.html)`
> `[985e9a46e10005356bbaf194249f6856-Abstract.html](https://proceedings.neurips.cc/paper/2020/hash/985e9a46e10005356bbaf194249f6856-Abstract.html)` .
> 
> 
> Dubey, A., Jauhri, A., Pandey, A., Kadian, A., Al-Dahle, A., Letman, A., Mathur, A., Schelten, A., Yang, A., Fan, A., Goyal, A.,
> 
> Hartshorn, A., Yang, A., Mitra, A., Sravankumar, A., Korenev, A., Hinsvark, A., Rao, A., Zhang, A., Rodriguez, A., Gregerson, A.,
> 
> Spataru, A., Rozière, B., Biron, B., Tang, B., Chern, B., Caucheteux, C., Nayak, C., Bi, C., Marra, C., McConnell, C., Keller, C.,
> 
> Touret, C., Wu, C., Wong, C., Ferrer, C. C., Nikolaidis, C., Allonsius, D., Song, D., Pintz, D., Livshits, D., Esiobu, D., Choudhary,
> 
> D., Mahajan, D., Garcia-Olano, D., Perino, D., Hupkes, D., Lakomkin, E., AlBadawy, E., Lobanova, E., Dinan, E., Smith, E. M.,
> 
> Radenovic, F., Zhang, F., Synnaeve, G., Lee, G., Anderson, G. L., Nail, G., Mialon, G., Pang, G., Cucurell, G., Nguyen, H., Korevaar,
> 
> H., Xu, H., Touvron, H., Zarov, I., Ibarra, I. A., Kloumann, I. M., Misra, I., Evtimov, I., Copet, J., Lee, J., Geffert, J., Vranes, J.,
> 
> 
> 15
> 
> 
> **Absolute Zero:** **Reinforced Self-play Reasoning with Zero Data**
> 
> 
> Park, J., Mahadeokar, J., Shah, J., van der Linde, J., Billock, J., Hong, J., Lee, J., Fu, J., Chi, J., Huang, J., Liu, J., Wang, J., Yu,
> 
> J., Bitton, J., Spisak, J., Park, J., Rocca, J., Johnstun, J., Saxe, J., Jia, J., Alwala, K. V., Upasani, K., Plawiak, K., Li, K., Heafield,
> 
> K., Stone, K., and et al. The llama 3 herd of models. _CoRR_, abs/2407.21783, 2024. doi: 10.48550/ARXIV.2407.21783. URL
> `[https://doi.org/10.48550/arXiv.2407.21783](https://doi.org/10.48550/arXiv.2407.21783)` .
> 
> 
> Ebert, C., Cain, J., Antoniol, G., Counsell, S., and Laplante, P. Cyclomatic complexity. _IEEE software_, 33(6):27–29, 2016.
> 
> 
> Florensa, C., Held, D., Geng, X., and Abbeel, P. Automatic goal generation for reinforcement learning agents. In Dy, J. G. and
> 
> Krause, A. (eds.), _Proceedings_ _of_ _the_ _35th_ _International_ _Conference_ _on_ _Machine_ _Learning,_ _ICML_ _2018,_ _Stockholmsmässan,_
> _Stockholm, Sweden, July 10-15, 2018_, volume 80 of _Proceedings of Machine Learning Research_, pp. 1514–1523. PMLR, 2018. URL
> `[http://proceedings.mlr.press/v80/florensa18a.html](http://proceedings.mlr.press/v80/florensa18a.html)` .
> 
> 
> Gaven, L., Carta, T., Romac, C., Colas, C., Lamprier, S., Sigaud, O., and Oudeyer, P. MAGELLAN: metacognitive predictions of
> 
> learning progress guide autotelic LLM agents in large goal spaces. _CoRR_, abs/2502.07709, 2025. doi: 10.48550/ARXIV.2502.07709.
> URL `[https://doi.org/10.48550/arXiv.2502.07709](https://doi.org/10.48550/arXiv.2502.07709)` .
> 
> 
> Goodfellow, I. J., Pouget-Abadie, J., Mirza, M., Xu, B., Warde-Farley, D., Ozair, S., Courville, A. C., and Bengio, Y. Generative
> 
> adversarial networks. _Commun. ACM_, 63(11):139–144, 2020. doi: 10.1145/3422622. URL `[https://doi.org/10.1145/3422622](https://doi.org/10.1145/3422622)` .
> 
> 
> Gu, A., Rozière, B., Leather, H. J., Solar-Lezama, A., Synnaeve, G., and Wang, S. Cruxeval: A benchmark for code reasoning,
> 
> understanding and execution. In _Forty-first International Conference on Machine Learning, ICML 2024, Vienna, Austria, July 21-27,_
> _2024_ . OpenReview.net, 2024. URL `[https://openreview.net/forum?id=Ffpg52swvg](https://openreview.net/forum?id=Ffpg52swvg)` .
> 
> 
> Guo, D., Yang, D., Zhang, H., Song, J., Wang, P., Zhu, Q., Xu, R., Zhang, R., Ma, S., Bi, X., Zhang, X., Yu, X., Wu, Y., Wu, Z. F., Gou,
> 
> Z., Shao, Z., Li, Z., Gao, Z., Liu, A., Xue, B., Wang, B., Wu, B., Feng, B., Lu, C., Zhao, C., Deng, C., Ruan, C., Dai, D., Chen, D., Ji,
> 
> D., Li, E., Lin, F., Dai, F., Luo, F., Hao, G., Chen, G., Li, G., Zhang, H., Xu, H., Ding, H., Gao, H., Qu, H., Li, H., Guo, J., Li, J.,
> 
> Chen, J., Yuan, J., Tu, J., Qiu, J., Li, J., Cai, J. L., Ni, J., Liang, J., Chen, J., Dong, K., Hu, K., You, K., Gao, K., Guan, K., Huang, K.,
> 
> Yu, K., Wang, L., Zhang, L., Zhao, L., Wang, L., Zhang, L., Xu, L., Xia, L., Zhang, M., Zhang, M., Tang, M., Zhou, M., Li, M.,
> 
> Wang, M., Li, M., Tian, N., Huang, P., Zhang, P., Wang, Q., Chen, Q., Du, Q., Ge, R., Zhang, R., Pan, R., Wang, R., Chen, R. J., Jin,
> 
> R. L., Chen, R., Lu, S., Zhou, S., Chen, S., Ye, S., Wang, S., Yu, S., Zhou, S., Pan, S., Li, S. S., Zhou, S., Wu, S., Yun, T., Pei, T., Sun,
> 
> T., Wang, T., Zeng, W., Liu, W., Liang, W., Gao, W., Yu, W., Zhang, W., Xiao, W. L., An, W., Liu, X., Wang, X., Chen, X., Nie, X.,
> 
> Cheng, X., Liu, X., Xie, X., Liu, X., Yang, X., Li, X., Su, X., Lin, X., Li, X. Q., Jin, X., Shen, X., Chen, X., Sun, X., Wang, X., Song,
> 
> X., Zhou, X., Wang, X., Shan, X., Li, Y. K., Wang, Y. Q., Wei, Y. X., Zhang, Y., Xu, Y., Li, Y., Zhao, Y., Sun, Y., Wang, Y., Yu, Y.,
> 
> Zhang, Y., Shi, Y., Xiong, Y., He, Y., Piao, Y., Wang, Y., Tan, Y., Ma, Y., Liu, Y., Guo, Y., Ou, Y., Wang, Y., Gong, Y., Zou, Y.,
> 
> He, Y., Xiong, Y., Luo, Y., You, Y., Liu, Y., Zhou, Y., Zhu, Y. X., Huang, Y., Li, Y., Zheng, Y., Zhu, Y., Ma, Y., Tang, Y., Zha, Y.,
> 
> Yan, Y., Ren, Z. Z., Ren, Z., Sha, Z., Fu, Z., Xu, Z., Xie, Z., Zhang, Z., Hao, Z., Ma, Z., Yan, Z., Wu, Z., Gu, Z., Zhu, Z., Liu, Z.,
> 
> Li, Z., Xie, Z., Song, Z., Pan, Z., Huang, Z., Xu, Z., Zhang, Z., and Zhang, Z. Deepseek-r1 incentivizes reasoning in llms through
> 
> reinforcement learning. _Nature_, 645(8081):633–638, September 2025. ISSN 1476-4687. doi: 10.1038/s41586-025-09422-z. URL
> `[http://dx.doi.org/10.1038/s41586-025-09422-z](http://dx.doi.org/10.1038/s41586-025-09422-z)` .
> 
> 
> Halstead, M. H. _Elements of Software Science (Operating and programming systems series)_ . Elsevier Science Inc., 1977.
> 
> 
> Haluptzok, P., Bowers, M., and Kalai, A. T. Language models can teach themselves to program better. In _The Eleventh International_
> _Conference_ _on_ _Learning_ _Representations,_ _ICLR_ _2023,_ _Kigali,_ _Rwanda,_ _May_ _1-5,_ _2023_ . OpenReview.net, 2023. URL `[https:](https://openreview.net/forum?id=SaRj2ka1XZ3)`
> `[//openreview.net/forum?id=SaRj2ka1XZ3](https://openreview.net/forum?id=SaRj2ka1XZ3)` .
> 
> 
> He, C., Luo, R., Bai, Y., Hu, S., Thai, Z. L., Shen, J., Hu, J., Han, X., Huang, Y., Zhang, Y., Liu, J., Qi, L., Liu, Z., and Sun, M.
> 
> Olympiadbench: A challenging benchmark for promoting AGI with olympiad-level bilingual multimodal scientific problems. In Ku,
> 
> L., Martins, A., and Srikumar, V. (eds.), _Proceedings of the 62nd Annual Meeting of the Association for Computational Linguistics_
> _(Volume_ _1:_ _Long_ _Papers),_ _ACL_ _2024,_ _Bangkok,_ _Thailand,_ _August_ _11-16,_ _2024_, pp. 3828–3850. Association for Computational
> Linguistics, 2024. doi: 10.18653/V1/2024.ACL-LONG.211. URL `[https://doi.org/10.18653/v1/2024.acl-long.211](https://doi.org/10.18653/v1/2024.acl-long.211)` .
> 
> 
> Hendrycks, D., Burns, C., Kadavath, S., Arora, A., Basart, S., Tang, E., Song, D., and Steinhardt, J. Measuring math
> ematical problem solving with the MATH dataset. In Vanschoren, J. and Yeung, S. (eds.), _Proceedings_ _of_ _the_ _Neu-_
> _ral_ _Information_ _Processing_ _Systems_ _Track_ _on_ _Datasets_ _and_ _Benchmarks_ _1,_ _NeurIPS_ _Datasets_ _and_ _Benchmarks_ _2021,_
> _December_ _2021,_ _virtual_, 2021. URL `[https://datasets-benchmarks-proceedings.neurips.cc/paper/2021/hash/](https://datasets-benchmarks-proceedings.neurips.cc/paper/2021/hash/be83ab3ecd0db773eb2dc1b0a17836a1-Abstract-round2.html)`
> `[be83ab3ecd0db773eb2dc1b0a17836a1-Abstract-round2.html](https://datasets-benchmarks-proceedings.neurips.cc/paper/2021/hash/be83ab3ecd0db773eb2dc1b0a17836a1-Abstract-round2.html)` .
> 
> 
> Hinton, G. E., Vinyals, O., and Dean, J. Distilling the knowledge in a neural network. _CoRR_, abs/1503.02531, 2015. URL
> 
> `[http://arxiv.org/abs/1503.02531](http://arxiv.org/abs/1503.02531)` .
> 
> 
> Hu, J. REINFORCE++: A simple and efficient approach for aligning large language models. _CoRR_, abs/2501.03262, 2025. doi:
> 10.48550/ARXIV.2501.03262. URL `[https://doi.org/10.48550/arXiv.2501.03262](https://doi.org/10.48550/arXiv.2501.03262)` .
> 
> 
> 16
> 
> 
> **Absolute Zero:** **Reinforced Self-play Reasoning with Zero Data**
> 
> 
> Hu, J., Zhang, Y., Han, Q., Jiang, D., Zhang, X., and Shum, H. Open-reasoner-zero: An open source approach to scaling up
> 
> reinforcement learning on the base model. _CoRR_, abs/2503.24290, 2025. doi: 10.48550/ARXIV.2503.24290. URL `[https:](https://doi.org/10.48550/arXiv.2503.24290)`
> `[//doi.org/10.48550/arXiv.2503.24290](https://doi.org/10.48550/arXiv.2503.24290)` .
> 
> 
> Hubinger, E., van Merwijk, C., Mikulik, V., Skalse, J., and Garrabrant, S. Risks from learned optimization in advanced machine learning
> 
> systems. _CoRR_, abs/1906.01820, 2019. URL `[http://arxiv.org/abs/1906.01820](http://arxiv.org/abs/1906.01820)` .
> 
> 
> Hughes, E., Dennis, M. D., Parker-Holder, J., Behbahani, F. M. P., Mavalankar, A., Shi, Y., Schaul, T., and Rocktäschel, T. Position:
> 
> Open-endedness is essential for artificial superhuman intelligence. In _Forty-first International Conference on Machine Learning,_
> _ICML 2024, Vienna, Austria, July 21-27, 2024_ . OpenReview.net, 2024. URL `[https://openreview.net/forum?id=Bc4vZ2CX7E](https://openreview.net/forum?id=Bc4vZ2CX7E)` .
> 
> 
> Hui, B., Yang, J., Cui, Z., Yang, J., Liu, D., Zhang, L., Liu, T., Zhang, J., Yu, B., Dang, K., Yang, A., Men, R., Huang, F., Ren, X., Ren,
> 
> X., Zhou, J., and Lin, J. Qwen2.5-coder technical report. _CoRR_, abs/2409.12186, 2024. doi: 10.48550/ARXIV.2409.12186. URL
> `[https://doi.org/10.48550/arXiv.2409.12186](https://doi.org/10.48550/arXiv.2409.12186)` .
> 
> 
> Jaech, A., Kalai, A., Lerer, A., Richardson, A., El-Kishky, A., Low, A., Helyar, A., Madry, A., Beutel, A., Carney, A., et al. Openai o1
> 
> system card. _arXiv preprint arXiv:2412.16720_, 2024.
> 
> 
> Jain, N., Han, K., Gu, A., Li, W., Yan, F., Zhang, T., Wang, S., Solar-Lezama, A., Sen, K., and Stoica, I. Livecodebench: Holistic and
> 
> contamination free evaluation of large language models for code. _CoRR_, abs/2403.07974, 2024. doi: 10.48550/ARXIV.2403.07974.
> URL `[https://doi.org/10.48550/arXiv.2403.07974](https://doi.org/10.48550/arXiv.2403.07974)` .
> 
> 
> Kirchner, J. H., Chen, Y., Edwards, H., Leike, J., McAleese, N., and Burda, Y. Prover-verifier games improve legibility of LLM outputs.
> 
> _CoRR_, abs/2407.13692, 2024. doi: 10.48550/ARXIV.2407.13692. URL `[https://doi.org/10.48550/arXiv.2407.13692](https://doi.org/10.48550/arXiv.2407.13692)` .
> 
> 
> Ladosz, P., Weng, L., Kim, M., and Oh, H. Exploration in deep reinforcement learning: A survey. _Inf. Fusion_, 85:1–22, 2022. doi:
> 10.1016/J.INFFUS.2022.03.003. URL `[https://doi.org/10.1016/j.inffus.2022.03.003](https://doi.org/10.1016/j.inffus.2022.03.003)` .
> 
> 
> Lambert, N., Morrison, J., Pyatkin, V., Huang, S., Ivison, H., Brahman, F., Miranda, L. J. V., Liu, A., Dziri, N., Lyu, S., Gu, Y., Malik, S.,
> 
> Graf, V., Hwang, J. D., Yang, J., Bras, R. L., Tafjord, O., Wilhelm, C., Soldaini, L., Smith, N. A., Wang, Y., Dasigi, P., and Hajishirzi,
> 
> H. Tülu 3: Pushing frontiers in open language model post-training. _CoRR_, abs/2411.15124, 2024. doi: 10.48550/ARXIV.2411.15124.
> URL `[https://doi.org/10.48550/arXiv.2411.15124](https://doi.org/10.48550/arXiv.2411.15124)` .
> 
> 
> Laskin, M., Yarats, D., Liu, H., Lee, K., Zhan, A., Lu, K., Cang, C., Pinto, L., and Abbeel, P. URLB: unsu
> pervised reinforcement learning benchmark. In Vanschoren, J. and Yeung, S. (eds.), _Proceedings_ _of_ _the_ _Neural_ _In-_
> _formation_ _Processing_ _Systems_ _Track_ _on_ _Datasets_ _and_ _Benchmarks_ _1,_ _NeurIPS_ _Datasets_ _and_ _Benchmarks_ _2021,_ _De-_
> _cember_ _2021,_ _virtual_, 2021. URL `[https://datasets-benchmarks-proceedings.neurips.cc/paper/2021/hash/](https://datasets-benchmarks-proceedings.neurips.cc/paper/2021/hash/091d584fced301b442654dd8c23b3fc9-Abstract-round2.html)`
> `[091d584fced301b442654dd8c23b3fc9-Abstract-round2.html](https://datasets-benchmarks-proceedings.neurips.cc/paper/2021/hash/091d584fced301b442654dd8c23b3fc9-Abstract-round2.html)` .
> 
> 
> Leike, J. and Sutskever, I. Introducing superalignment. `[https://openai.com/index/introducing-superalignment/](https://openai.com/index/introducing-superalignment/)`, 2023.
> 
> OpenAI Blog.
> 
> 
> Lewkowycz, A., Andreassen, A., Dohan, D., Dyer, E., Michalewski, H., Ramasesh, V. V., Slone, A., Anil, C., Schlag, I.,
> 
> Gutman-Solo, T., Wu, Y., Neyshabur, B., Gur-Ari, G., and Misra, V. Solving quantitative reasoning problems with lan
> guage models. In Koyejo, S., Mohamed, S., Agarwal, A., Belgrave, D., Cho, K., and Oh, A. (eds.), _Advances_ _in_ _Neural_
> _Information_ _Processing_ _Systems_ _35:_ _Annual_ _Conference_ _on_ _Neural_ _Information_ _Processing_ _Systems_ _2022,_ _NeurIPS_ _2022,_ _New_
> _Orleans, LA, USA, November 28 - December 9, 2022_, 2022. URL `[http://papers.nips.cc/paper_files/paper/2022/hash/](http://papers.nips.cc/paper_files/paper/2022/hash/18abbeef8cfe9203fdf9053c9c4fe191-Abstract-Conference.html)`
> `[18abbeef8cfe9203fdf9053c9c4fe191-Abstract-Conference.html](http://papers.nips.cc/paper_files/paper/2022/hash/18abbeef8cfe9203fdf9053c9c4fe191-Abstract-Conference.html)` .
> 
> 
> Li, J., Guo, D., Yang, D., Xu, R., Wu, Y., and He, J. Codei/o: Condensing reasoning patterns via code input-output prediction. _CoRR_,
> abs/2502.07316, 2025. doi: 10.48550/ARXIV.2502.07316. URL `[https://doi.org/10.48550/arXiv.2502.07316](https://doi.org/10.48550/arXiv.2502.07316)` .
> 
> 
> Li, R., Fu, J., Zhang, B., Huang, T., Sun, Z., Lyu, C., Liu, G., Jin, Z., and Li, G. TACO: topics in algorithmic code generation dataset.
> 
> _CoRR_, abs/2312.14852, 2023. doi: 10.48550/ARXIV.2312.14852. URL `[https://doi.org/10.48550/arXiv.2312.14852](https://doi.org/10.48550/arXiv.2312.14852)` .
> 
> 
> Liu, B., Guertler, L., Yu, S., Liu, Z., Qi, P., Balcells, D., Liu, M., Tan, C., Shi, W., Lin, M., Lee, W. S., and Jaques, N. SPIRAL: self-play
> 
> on zero-sum games incentivizes reasoning via multi-agent multi-turn reinforcement learning. _CoRR_, abs/2506.24119, 2025a. doi:
> 10.48550/ARXIV.2506.24119. URL `[https://doi.org/10.48550/arXiv.2506.24119](https://doi.org/10.48550/arXiv.2506.24119)` .
> 
> 
> Liu, J. and Zhang, L. Code-r1: Reproducing r1 for code with reliable rewards. _GitHub_, 2025.
> 
> 
> Liu, J., Xia, C. S., Wang, Y., and Zhang, L. Is your code generated by chatGPT really correct? rigorous evaluation of large
> 
> language models for code generation. In _Thirty-seventh_ _Conference_ _on_ _Neural_ _Information_ _Processing_ _Systems_, 2023. URL
> `[https://openreview.net/forum?id=1qvx610Cu7](https://openreview.net/forum?id=1qvx610Cu7)` .
> 
> 
> 17
> 
> 
> **Absolute Zero:** **Reinforced Self-play Reasoning with Zero Data**
> 
> 
> Liu, M., Jiang, L., Liang, Y., Du, S. S., Choi, Y., Althoff, T., and Jaques, N. Chasing moving targets with online self-play
> 
> reinforcement learning for safer language models. _CoRR_, abs/2506.07468, 2025b. doi: 10.48550/ARXIV.2506.07468. URL
> `[https://doi.org/10.48550/arXiv.2506.07468](https://doi.org/10.48550/arXiv.2506.07468)` .
> 
> 
> Liu, Z., Chen, C., Li, W., Qi, P., Pang, T., Du, C., Lee, W. S., and Lin, M. Understanding r1-zero-like training: A critical perspective.
> 
> _CoRR_, abs/2503.20783, 2025c. doi: 10.48550/ARXIV.2503.20783. URL `[https://doi.org/10.48550/arXiv.2503.20783](https://doi.org/10.48550/arXiv.2503.20783)` .
> 
> 
> Lopez, R. H. Q. Complexipy: An extremely fast python library to calculate the cognitive complexity of python files, written in rust,
> 
> 2025. URL `[https://github.com/rohaquinlop/complexipy](https://github.com/rohaquinlop/complexipy)` . Accessed: 2025-04-06.
> 
> 
> Loshchilov, I. and Hutter, F. Decoupled weight decay regularization. In _7th International Conference on Learning Representations, ICLR_
> _2019, New Orleans, LA, USA, May 6-9, 2019_ . OpenReview.net, 2019. URL `[https://openreview.net/forum?id=Bkg6RiCqY7](https://openreview.net/forum?id=Bkg6RiCqY7)` .
> 
> 
> Morris, J. There are no new ideas in ai. . . only new datasets. `[https://blog.jxmo.io/p/there-are-no-new-ideas-in-ai-only](https://blog.jxmo.io/p/there-are-no-new-ideas-in-ai-only)`,
> 
> 2025.
> 
> 
> OpenAI. Openai o3-mini, January 2025a. URL `[https://openai.com/index/openai-o3-mini/](https://openai.com/index/openai-o3-mini/)` . Accessed: 2025-04-17.
> 
> 
> OpenAI. Introducing openai o3 and o4-mini, April 2025b. URL `[https://openai.com/index/introducing-o3-and-o4-mini/](https://openai.com/index/introducing-o3-and-o4-mini/)` .
> 
> Accessed: 2025-04-17.
> 
> 
> OpenAI, Plappert, M., Sampedro, R., Xu, T., Akkaya, I., Kosaraju, V., Welinder, P., D’Sa, R., Petron, A., de Oliveira Pinto, H. P.,
> 
> Paino, A., Noh, H., Weng, L., Yuan, Q., Chu, C., and Zaremba, W. Asymmetric self-play for automatic goal discovery in robotic
> 
> manipulation. _CoRR_, abs/2101.04882, 2021. URL `[https://arxiv.org/abs/2101.04882](https://arxiv.org/abs/2101.04882)` .
> 
> 
> Oudeyer, P.-Y., Gottlieb, J., and Lopes, M. Intrinsic motivation, curiosity, and learning: Theory and applications in educational
> 
> technologies. _Progress in brain research_, 229:257–284, 2016.
> 
> 
> Ouyang, L., Wu, J., Jiang, X., Almeida, D., Wainwright, C., Mishkin, P., Zhang, C., Agarwal, S., Slama, K., Ray, A., et al. Training
> 
> language models to follow instructions with human feedback. _Advances in neural information processing systems_, 35:27730–27744,
> 
> 2022.
> 
> 
> Poesia, G., Broman, D., Haber, N., and Goodman, N. D. Learning formal mathematics from intrinsic motivation. In Glober
> sons, A., Mackey, L., Belgrave, D., Fan, A., Paquet, U., Tomczak, J. M., and Zhang, C. (eds.), _Advances_ _in_ _Neural_ _In-_
> _formation_ _Processing_ _Systems_ _38:_ _Annual_ _Conference_ _on_ _Neural_ _Information_ _Processing_ _Systems_ _2024,_ _NeurIPS_ _2024,_ _Van-_
> _couver,_ _BC,_ _Canada,_ _December_ _10_ _-_ _15,_ _2024_, 2024. URL `[http://papers.nips.cc/paper_files/paper/2024/hash/](http://papers.nips.cc/paper_files/paper/2024/hash/4b8001fc75f0532827472ea5a16af9ca-Abstract-Conference.html)`
> `[4b8001fc75f0532827472ea5a16af9ca-Abstract-Conference.html](http://papers.nips.cc/paper_files/paper/2024/hash/4b8001fc75f0532827472ea5a16af9ca-Abstract-Conference.html)` .
> 
> 
> Pourcel, J., Colas, C., Molinaro, G., Oudeyer, P., and Teodorescu, L. ACES: generating a diversity of challenging programming puzzles
> 
> with autotelic generative models. In Globersons, A., Mackey, L., Belgrave, D., Fan, A., Paquet, U., Tomczak, J. M., and Zhang, C.
> 
> (eds.), _Advances in Neural Information Processing Systems 38:_ _Annual Conference on Neural Information Processing Systems 2024,_
> _NeurIPS 2024, Vancouver, BC, Canada, December 10 - 15, 2024_, 2024. URL `[http://papers.nips.cc/paper_files/paper/](http://papers.nips.cc/paper_files/paper/2024/hash/7d0c6ff18f16797b92e77d7cc95b3c53-Abstract-Conference.html)`
> `[2024/hash/7d0c6ff18f16797b92e77d7cc95b3c53-Abstract-Conference.html](http://papers.nips.cc/paper_files/paper/2024/hash/7d0c6ff18f16797b92e77d7cc95b3c53-Abstract-Conference.html)` .
> 
> 
> Radford, A., Wu, J., Child, R., Luan, D., Amodei, D., Sutskever, I., et al. Language models are unsupervised multitask learners. _OpenAI_
> _blog_, 1(8):9, 2019.
> 
> 
> Ren, Z. Z., Shao, Z., Song, J., Xin, H., Wang, H., Zhao, W., Zhang, L., Fu, Z., Zhu, Q., Yang, D., Wu, Z. F., Gou, Z., Ma, S., Tang, H.,
> 
> Liu, Y., Gao, W., Guo, D., and Ruan, C. Deepseek-prover-v2: Advancing formal mathematical reasoning via reinforcement learning
> 
> for subgoal decomposition, 2025. URL `[https://arxiv.org/abs/2504.21801](https://arxiv.org/abs/2504.21801)` .
> 
> 
> Schaul, T. Boundless socratic learning with language games. _arXiv preprint arXiv:2411.16905_, 2024.
> 
> 
> Schmidhuber, J. Exploring the predictable. In _Advances in evolutionary computing:_ _theory and applications_, pp. 579–612. Springer,
> 
> 2003.
> 
> 
> Schmidhuber, J. POWERPLAY: training an increasingly general problem solver by continually searching for the simplest still unsolvable
> 
> problem. _CoRR_, abs/1112.5309, 2011. URL `[http://arxiv.org/abs/1112.5309](http://arxiv.org/abs/1112.5309)` .
> 
> 
> Shao, Z., Wang, P., Zhu, Q., Xu, R., Song, J., Zhang, M., Li, Y. K., Wu, Y., and Guo, D. Deepseekmath: Pushing the limits
> 
> of mathematical reasoning in open language models. _CoRR_, abs/2402.03300, 2024. doi: 10.48550/ARXIV.2402.03300. URL
> `[https://doi.org/10.48550/arXiv.2402.03300](https://doi.org/10.48550/arXiv.2402.03300)` .
> 
> 
> 18
> 
> 
> **Absolute Zero:** **Reinforced Self-play Reasoning with Zero Data**
> 
> 
> Sheng, G., Zhang, C., Ye, Z., Wu, X., Zhang, W., Zhang, R., Peng, Y., Lin, H., and Wu, C. Hybridflow: A flexible and efficient
> 
> RLHF framework. In _Proceedings_ _of_ _the_ _Twentieth_ _European_ _Conference_ _on_ _Computer_ _Systems,_ _EuroSys_ _2025,_ _Rotterdam,_
> _The_ _Netherlands,_ _30_ _March_ _2025_ _-_ _3_ _April_ _2025_, pp. 1279–1297. ACM, 2025. doi: 10.1145/3689031.3696075. URL `[https:](https://doi.org/10.1145/3689031.3696075)`
> `[//doi.org/10.1145/3689031.3696075](https://doi.org/10.1145/3689031.3696075)` .
> 
> 
> Silver, D. and Sutton, R. S. The era of experience. `[https://storage.googleapis.com/deepmind-media/Era-of-Experience%](https://storage.googleapis.com/deepmind-media/Era-of-Experience%20/The%20Era%20of%20Experience%20Paper.pdf)`
> `[20/The%20Era%20of%20Experience%20Paper.pdf](https://storage.googleapis.com/deepmind-media/Era-of-Experience%20/The%20Era%20of%20Experience%20Paper.pdf)`, 2025.
> 
> 
> Silver, D., Huang, A., Maddison, C. J., Guez, A., Sifre, L., van den Driessche, G., Schrittwieser, J., Antonoglou, I., Panneershelvam,
> 
> V., Lanctot, M., Dieleman, S., Grewe, D., Nham, J., Kalchbrenner, N., Sutskever, I., Lillicrap, T. P., Leach, M., Kavukcuoglu, K.,
> 
> Graepel, T., and Hassabis, D. Mastering the game of go with deep neural networks and tree search. _Nat._, 529(7587):484–489, 2016.
> doi: 10.1038/NATURE16961. URL `[https://doi.org/10.1038/nature16961](https://doi.org/10.1038/nature16961)` .
> 
> 
> Silver, D., Hubert, T., Schrittwieser, J., Antonoglou, I., Lai, M., Guez, A., Lanctot, M., Sifre, L., Kumaran, D., Graepel, T., Lillicrap,
> 
> T. P., Simonyan, K., and Hassabis, D. Mastering chess and shogi by self-play with a general reinforcement learning algorithm. _CoRR_,
> abs/1712.01815, 2017. URL `[http://arxiv.org/abs/1712.01815](http://arxiv.org/abs/1712.01815)` .
> 
> 
> Snell, C., Lee, J., Xu, K., and Kumar, A. Scaling LLM test-time compute optimally can be more effective than scaling model parameters.
> 
> _CoRR_, abs/2408.03314, 2024. doi: 10.48550/ARXIV.2408.03314. URL `[https://doi.org/10.48550/arXiv.2408.03314](https://doi.org/10.48550/arXiv.2408.03314)` .
> 
> 
> Stuart, T. _Understanding computation - from simple machines to impossible programs_ . O’Reilly, 2015. ISBN 978-1-449-32927-3. URL
> 
> `[http://www.oreilly.de/catalog/9781449329273/index.html](http://www.oreilly.de/catalog/9781449329273/index.html)` .
> 
> 
> Sukhbaatar, S., Lin, Z., Kostrikov, I., Synnaeve, G., Szlam, A., and Fergus, R. Intrinsic motivation and automatic curricula via
> 
> asymmetric self-play. In _6th International Conference on Learning Representations, ICLR 2018, Vancouver, BC, Canada, April 30 -_
> _May 3, 2018, Conference Track Proceedings_ . OpenReview.net, 2018. URL `[https://openreview.net/forum?id=SkT5Yg-RZ](https://openreview.net/forum?id=SkT5Yg-RZ)` .
> 
> 
> Suteu, M. and Guo, Y. Regularizing deep multi-task networks using orthogonal gradients. _CoRR_, abs/1912.06844, 2019. URL
> 
> `[http://arxiv.org/abs/1912.06844](http://arxiv.org/abs/1912.06844)` .
> 
> 
> Sutskever, I., Vinyals, O., and Le, Q. V. Neurips 2024 test of time award session: Sequence to sequence learning with neural networks.
> 
> Conference session, December 2024. URL `[https://neurips.cc/virtual/2024/test-of-time/105032](https://neurips.cc/virtual/2024/test-of-time/105032)` .
> 
> 
> Sutton, R. S. Verification, the key to ai. `[http://incompleteideas.net/IncIdeas/KeytoAI.html](http://incompleteideas.net/IncIdeas/KeytoAI.html)`, 2001.
> 
> 
> Team, K., Du, A., Gao, B., Xing, B., Jiang, C., Chen, C., Li, C., Xiao, C., Du, C., Liao, C., Tang, C., Wang, C., Zhang, D., Yuan, E., Lu,
> 
> E., Tang, F., Sung, F., Wei, G., Lai, G., Guo, H., Zhu, H., Ding, H., Hu, H., Yang, H., Zhang, H., Yao, H., Zhao, H., Lu, H., Li, H., Yu,
> 
> H., Gao, H., Zheng, H., Yuan, H., Chen, J., Guo, J., Su, J., Wang, J., Zhao, J., Zhang, J., Liu, J., Yan, J., Wu, J., Shi, L., Ye, L., Yu, L.,
> 
> Dong, M., Zhang, N., Ma, N., Pan, Q., Gong, Q., Liu, S., Ma, S., Wei, S., Cao, S., Huang, S., Jiang, T., Gao, W., Xiong, W., He, W.,
> 
> Huang, W., Wu, W., He, W., Wei, X., Jia, X., Wu, X., Xu, X., Zu, X., Zhou, X., Pan, X., Charles, Y., Li, Y., Hu, Y., Liu, Y., Chen,
> 
> Y., Wang, Y., Liu, Y., Qin, Y., Liu, Y., Yang, Y., Bao, Y., Du, Y., Wu, Y., Wang, Y., Zhou, Z., Wang, Z., Li, Z., Zhu, Z., Zhang,
> 
> Z., Wang, Z., Yang, Z., Huang, Z., Huang, Z., Xu, Z., and Yang, Z. Kimi k1.5: Scaling reinforcement learning with llms. _CoRR_,
> abs/2501.12599, 2025. doi: 10.48550/ARXIV.2501.12599. URL `[https://doi.org/10.48550/arXiv.2501.12599](https://doi.org/10.48550/arXiv.2501.12599)` .
> 
> 
> Villalobos, P., Ho, A., Sevilla, J., Besiroglu, T., Heim, L., and Hobbhahn, M. Position: Will we run out of data? limits of LLM scaling
> 
> based on human-generated data. In _Forty-first International Conference on Machine Learning, ICML 2024, Vienna, Austria, July_
> _21-27, 2024_ . OpenReview.net, 2024. URL `[https://openreview.net/forum?id=ViZcgDQjyG](https://openreview.net/forum?id=ViZcgDQjyG)` .
> 
> 
> Wang, H., Yue, Y., Lu, R., Shi, J., Zhao, A., Wang, S., Song, S., and Huang, G. Model surgery: Modulating LLM‘s behavior via
> 
> simple parameter editing. In _Proceedings of the 2025 Conference of the Nations of the Americas Chapter of the Association for_
> _Computational Linguistics_, pp. 6337–6357, 2025a.
> 
> 
> Wang, R., Lehman, J., Clune, J., and Stanley, K. O. Paired open-ended trailblazer (POET): endlessly generating increasingly complex
> 
> and diverse learning environments and their solutions. _CoRR_, abs/1901.01753, 2019. URL `[http://arxiv.org/abs/1901.01753](http://arxiv.org/abs/1901.01753)` .
> 
> 
> Wang, S., Yang, Q., Gao, J., Lin, M. G., Chen, H., Wu, L., Jia, N., Song, S., and Huang, G. Train once, get a family: State-adaptive
> 
> balances for offline-to-online reinforcement learning. In _Thirty-seventh Conference on Neural Information Processing Systems_, 2023.
> URL `[https://openreview.net/forum?id=vtoY8qJjTR](https://openreview.net/forum?id=vtoY8qJjTR)` .
> 
> 
> Wang, S., Liu, C., Zheng, Z., Qi, S., Chen, S., Yang, Q., Zhao, A., Wang, C., Song, S., and Huang, G. Boosting LLM agents with recursive
> 
> contemplation for effective deception handling. In Ku, L.-W., Martins, A., and Srikumar, V. (eds.), _Findings of the Association for_
> _Computational Linguistics:_ _ACL 2024_, pp. 9909–9953, Bangkok, Thailand, August 2024a. Association for Computational Linguistics.
> doi: 10.18653/v1/2024.findings-acl.591. URL `[https://aclanthology.org/2024.findings-acl.591/](https://aclanthology.org/2024.findings-acl.591/)` .
> 
> 
> 19
> 
> 
> **Absolute Zero:** **Reinforced Self-play Reasoning with Zero Data**
> 
> 
> Wang, S., Yu, L., Gao, C., Zheng, C., Liu, S., Lu, R., Dang, K., Chen, X., Yang, J., Zhang, Z., Liu, Y., Yang, A., Zhao,
> 
> A., Yue, Y., Song, S., Yu, B., Huang, G., and Lin, J. Beyond the 80/20 rule: High-entropy minority tokens drive effective
> 
> reinforcement learning for LLM reasoning. _CoRR_, abs/2506.01939, 2025b. doi: 10.48550/ARXIV.2506.01939. URL `[https:](https://doi.org/10.48550/arXiv.2506.01939)`
> `[//doi.org/10.48550/arXiv.2506.01939](https://doi.org/10.48550/arXiv.2506.01939)` .
> 
> 
> Wang, Y., Ma, X., Zhang, G., Ni, Y., Chandra, A., Guo, S., Ren, W., Arulraj, A., He, X., Jiang, Z., Li, T., Ku, M., Wang, K.,
> 
> Zhuang, A., Fan, R., Yue, X., and Chen, W. Mmlu-pro: A more robust and challenging multi-task language understanding
> 
> benchmark. In Globersons, A., Mackey, L., Belgrave, D., Fan, A., Paquet, U., Tomczak, J. M., and Zhang, C. (eds.), _Advances in_
> _Neural Information Processing Systems 38:_ _Annual Conference on Neural Information Processing Systems 2024, NeurIPS 2024,_
> _Vancouver, BC, Canada, December 10 - 15, 2024_, 2024b. URL `[http://papers.nips.cc/paper_files/paper/2024/hash/](http://papers.nips.cc/paper_files/paper/2024/hash/ad236edc564f3e3156e1b2feafb99a24-Abstract-Datasets_and_Benchmarks_Track.html)`
> `[ad236edc564f3e3156e1b2feafb99a24-Abstract-Datasets_and_Benchmarks_Track.html](http://papers.nips.cc/paper_files/paper/2024/hash/ad236edc564f3e3156e1b2feafb99a24-Abstract-Datasets_and_Benchmarks_Track.html)` .
> 
> 
> Wang, Y., Yang, Q., Zeng, Z., Ren, L., Liu, L., Peng, B., Cheng, H., He, X., Wang, K., Gao, J., Chen, W., Wang, S., Du,
> 
> S. S., and Shen, Y. Reinforcement learning for reasoning in large language models with one training example, 2025c. URL
> 
> `[https://arxiv.org/abs/2504.20571](https://arxiv.org/abs/2504.20571)` .
> 
> 
> Wu, Q., Bansal, G., Zhang, J., Wu, Y., Zhang, S., Zhu, E., Li, B., Jiang, L., Zhang, X., and Wang, C. Autogen: Enabling next-gen
> 
> LLM applications via multi-agent conversation framework. _CoRR_, abs/2308.08155, 2023. doi: 10.48550/ARXIV.2308.08155. URL
> `[https://doi.org/10.48550/arXiv.2308.08155](https://doi.org/10.48550/arXiv.2308.08155)` .
> 
> 
> Wu, Y., Yue, T., Zhang, S., Wang, C., and Wu, Q. Stateflow: Enhancing LLM task-solving through state-driven workflows. _CoRR_,
> abs/2403.11322, 2024. doi: 10.48550/ARXIV.2403.11322. URL `[https://doi.org/10.48550/arXiv.2403.11322](https://doi.org/10.48550/arXiv.2403.11322)` .
> 
> 
> Xie, T., Gao, Z., Ren, Q., Luo, H., Hong, Y., Dai, B., Zhou, J., Qiu, K., Wu, Z., and Luo, C. Logic-rl: Unleashing LLM
> 
> reasoning with rule-based reinforcement learning. _CoRR_, abs/2502.14768, 2025. doi: 10.48550/ARXIV.2502.14768. URL
> `[https://doi.org/10.48550/arXiv.2502.14768](https://doi.org/10.48550/arXiv.2502.14768)` .
> 
> 
> Xu, F., Yan, H., Ma, C., Zhao, H., Sun, Q., Cheng, K., He, J., Liu, J., and Wu, Z. Genius: A generalizable and purely unsupervised
> 
> self-training framework for advanced reasoning, 2025. URL `[https://arxiv.org/abs/2504.08672](https://arxiv.org/abs/2504.08672)` .
> 
> 
> Yang, A., Yang, B., Zhang, B., Hui, B., Zheng, B., Yu, B., Li, C., Liu, D., Huang, F., Wei, H., Lin, H., Yang, J., Tu, J., Zhang, J., Yang,
> 
> J., Yang, J., Zhou, J., Lin, J., Dang, K., Lu, K., Bao, K., Yang, K., Yu, L., Li, M., Xue, M., Zhang, P., Zhu, Q., Men, R., Lin, R., Li, T.,
> 
> Xia, T., Ren, X., Ren, X., Fan, Y., Su, Y., Zhang, Y., Wan, Y., Liu, Y., Cui, Z., Zhang, Z., and Qiu, Z. Qwen2.5 technical report.
> 
> _CoRR_, abs/2412.15115, 2024a. doi: 10.48550/ARXIV.2412.15115. URL `[https://doi.org/10.48550/arXiv.2412.15115](https://doi.org/10.48550/arXiv.2412.15115)` .
> 
> 
> Yang, A., Zhang, B., Hui, B., Gao, B., Yu, B., Li, C., Liu, D., Tu, J., Zhou, J., Lin, J., Lu, K., Xue, M., Lin, R., Liu, T., Ren, X., and
> 
> Zhang, Z. Qwen2.5-math technical report: Toward mathematical expert model via self-improvement. _CoRR_, abs/2409.12122, 2024b.
> doi: 10.48550/ARXIV.2409.12122. URL `[https://doi.org/10.48550/arXiv.2409.12122](https://doi.org/10.48550/arXiv.2409.12122)` .
> 
> 
> Yao, S., Zhao, J., Yu, D., Du, N., Shafran, I., Narasimhan, K. R., and Cao, Y. React: Synergizing reasoning and acting in language
> 
> models. In _The_ _Eleventh_ _International_ _Conference_ _on_ _Learning_ _Representations,_ _ICLR_ _2023,_ _Kigali,_ _Rwanda,_ _May_ _1-5,_ _2023_ .
> OpenReview.net, 2023. URL `[https://openreview.net/forum?id=WE_vluYUL-X](https://openreview.net/forum?id=WE_vluYUL-X)` .
> 
> 
> Ye, Z., Agarwal, R., Liu, T., Joshi, R., Velury, S., Le, Q. V., Tan, Q., and Liu, Y. Evolving alignment via asymmetric self-play. _CoRR_,
> abs/2411.00062, 2024. doi: 10.48550/ARXIV.2411.00062. URL `[https://doi.org/10.48550/arXiv.2411.00062](https://doi.org/10.48550/arXiv.2411.00062)` .
> 
> 
> Yu, Q., Zhang, Z., Zhu, R., Yuan, Y., Zuo, X., Yue, Y., Fan, T., Liu, G., Liu, L., Liu, X., Lin, H., Lin, Z., Ma, B., Sheng, G., Tong, Y.,
> 
> Zhang, C., Zhang, M., Zhang, W., Zhu, H., Zhu, J., Chen, J., Chen, J., Wang, C., Yu, H., Dai, W., Song, Y., Wei, X., Zhou, H., Liu, J.,
> 
> Ma, W., Zhang, Y., Yan, L., Qiao, M., Wu, Y., and Wang, M. DAPO: an open-source LLM reinforcement learning system at scale.
> 
> _CoRR_, abs/2503.14476, 2025. doi: 10.48550/ARXIV.2503.14476. URL `[https://doi.org/10.48550/arXiv.2503.14476](https://doi.org/10.48550/arXiv.2503.14476)` .
> 
> 
> Yuan, W., Pang, R. Y., Cho, K., Li, X., Sukhbaatar, S., Xu, J., and Weston, J. Self-rewarding language models. _URL https://arxiv._
> _org/abs/2401.10020_, 2024.
> 
> 
> Yuan, Y., Yu, Q., Zuo, X., Zhu, R., Xu, W., Chen, J., Wang, C., Fan, T., Du, Z., Wei, X., et al. Vapo: Efficient and reliable reinforcement
> 
> learning for advanced reasoning tasks. _arXiv preprint arXiv:2504.05118_, 2025.
> 
> 
> Yue, Y., Lu, R., Kang, B., Song, S., and Huang, G. Understanding, predicting and better resolving q-value divergence in offline-rl.
> 
> _Advances in Neural Information Processing Systems_, 36:60247–60277, 2023.
> 
> 
> Yue, Y., Wang, Y., Kang, B., Han, Y., Wang, S., Song, S., Feng, J., and Huang, G. Deer-vla: Dynamic inference of multimodal large
> 
> language models for efficient robot execution. In Globersons, A., Mackey, L., Belgrave, D., Fan, A., Paquet, U., Tomczak, J. M., and
> 
> Zhang, C. (eds.), _Advances in Neural Information Processing Systems 38:_ _Annual Conference on Neural Information Processing_
> _Systems 2024, NeurIPS 2024, Vancouver, BC, Canada, December 10 - 15, 2024_, 2024. URL `[http://papers.nips.cc/paper_](http://papers.nips.cc/paper_files/paper/2024/hash/67b0e7c7c2a5780aeefe3b79caac106e-Abstract-Conference.html)`
> `[files/paper/2024/hash/67b0e7c7c2a5780aeefe3b79caac106e-Abstract-Conference.html](http://papers.nips.cc/paper_files/paper/2024/hash/67b0e7c7c2a5780aeefe3b79caac106e-Abstract-Conference.html)` .
> 
> 
> 20
> 
> 
> **Absolute Zero:** **Reinforced Self-play Reasoning with Zero Data**
> 
> 
> Yue, Y., Chen, Z., Lu, R., Zhao, A., Wang, Z., Yue, Y., Song, S., and Huang, G. Does reinforcement learning really incentivize reasoning
> 
> capacity in llms beyond the base model?, 2025. URL `[https://arxiv.org/abs/2504.13837](https://arxiv.org/abs/2504.13837)` .
> 
> 
> Zelikman, E., Wu, Y., Mu, J., and Goodman, N. Star: Bootstrapping reasoning with reasoning. _Advances_ _in_ _Neural_ _Information_
> _Processing Systems_, 35:15476–15488, 2022.
> 
> 
> Zeng, H., Jiang, D., Wang, H., Nie, P., Chen, X., and Chen, W. ACECODER: acing coder RL via automated test-case synthesis. _CoRR_,
> abs/2502.01718, 2025a. doi: 10.48550/ARXIV.2502.01718. URL `[https://doi.org/10.48550/arXiv.2502.01718](https://doi.org/10.48550/arXiv.2502.01718)` .
> 
> 
> Zeng, W., Huang, Y., Liu, Q., Liu, W., He, K., Ma, Z., and He, J. Simplerl-zoo: Investigating and taming zero reinforcement
> 
> learning for open base models in the wild. _CoRR_, abs/2503.18892, 2025b. doi: 10.48550/ARXIV.2503.18892. URL `[https:](https://doi.org/10.48550/arXiv.2503.18892)`
> `[//doi.org/10.48550/arXiv.2503.18892](https://doi.org/10.48550/arXiv.2503.18892)` .
> 
> 
> Zhang, C., Deng, Y., Lin, X., Wang, B., Ng, D., Ye, H., Li, X., Xiao, Y., Mo, Z., Zhang, Q., et al. 100 days after deepseek-r1: A survey
> 
> on replication studies and more directions for reasoning language models. _arXiv preprint arXiv:2505.00551_, 2025a.
> 
> 
> Zhang, Q., Wu, H., Zhang, C., Zhao, P., and Bian, Y. Right question is already half the answer: Fully unsupervised llm reasoning
> 
> incentivization, 2025b. URL `[https://arxiv.org/abs/2504.05812](https://arxiv.org/abs/2504.05812)` .
> 
> 
> Zhang, Y. and Yang, Q. A survey on multi-task learning. _IEEE transactions on knowledge and data engineering_, 34(12):5586–5609,
> 
> 2021.
> 
> 
> Zhao, A., Lin, M. G., Li, Y., Liu, Y., and Huang, G. A mixture of surprises for unsupervised reinforcement learning. In
> 
> Koyejo, S., Mohamed, S., Agarwal, A., Belgrave, D., Cho, K., and Oh, A. (eds.), _Advances_ _in_ _Neural_ _Information_ _Pro-_
> _cessing_ _Systems_ _35:_ _Annual_ _Conference_ _on_ _Neural_ _Information_ _Processing_ _Systems_ _2022,_ _NeurIPS_ _2022,_ _New_ _Orleans,_
> _LA,_ _USA,_ _November_ _28_ _-_ _December_ _9,_ _2022_, 2022. URL `[http://papers.nips.cc/paper_files/paper/2022/hash/](http://papers.nips.cc/paper_files/paper/2022/hash/a7667ee5d545a43d2f0fda98863c260e-Abstract-Conference.html)`
> `[a7667ee5d545a43d2f0fda98863c260e-Abstract-Conference.html](http://papers.nips.cc/paper_files/paper/2022/hash/a7667ee5d545a43d2f0fda98863c260e-Abstract-Conference.html)` .
> 
> 
> Zhao, A., Huang, D., Xu, Q., Lin, M., Liu, Y., and Huang, G. Expel: LLM agents are experiential learners. In Wooldridge, M. J., Dy,
> 
> J. G., and Natarajan, S. (eds.), _Thirty-Eighth AAAI Conference on Artificial Intelligence, AAAI 2024, Thirty-Sixth Conference on_
> _Innovative Applications of Artificial Intelligence, IAAI 2024, Fourteenth Symposium on Educational Advances in Artificial Intelligence,_
> _EAAI 2014, February 20-27, 2024, Vancouver, Canada_, pp. 19632–19642. AAAI Press, 2024. doi: 10.1609/AAAI.V38I17.29936.
> URL `[https://doi.org/10.1609/aaai.v38i17.29936](https://doi.org/10.1609/aaai.v38i17.29936)` .
> 
> 
> Zhao, A., Xu, Q., Lin, M., Wang, S., Liu, Y., Zheng, Z., and Huang, G. Diver-ct: Diversity-enhanced red teaming large language model
> 
> assistants with relaxing constraints. In Walsh, T., Shah, J., and Kolter, Z. (eds.), _AAAI-25, Sponsored by the Association for the_
> _Advancement of Artificial Intelligence, February 25 - March 4, 2025, Philadelphia, PA, USA_, pp. 26021–26030. AAAI Press, 2025a.
> doi: 10.1609/AAAI.V39I24.34797. URL `[https://doi.org/10.1609/aaai.v39i24.34797](https://doi.org/10.1609/aaai.v39i24.34797)` .
> 
> 
> Zhao, A., Zhu, E., Lu, R., Lin, M., Liu, Y., and Huang, G. Self-referencing agents for unsupervised reinforcement learning. _Neural_
> _Networks_, 188:107448, 2025b. doi: 10.1016/J.NEUNET.2025.107448. URL `[https://doi.org/10.1016/j.neunet.2025.](https://doi.org/10.1016/j.neunet.2025.107448)`
> `[107448](https://doi.org/10.1016/j.neunet.2025.107448)` .
> 
> 
> Zitkovich, B., Yu, T., Xu, S., Xu, P., Xiao, T., Xia, F., Wu, J., Wohlhart, P., Welker, S., Wahid, A., Vuong, Q., Vanhoucke, V., Tran,
> 
> H. T., Soricut, R., Singh, A., Singh, J., Sermanet, P., Sanketi, P. R., Salazar, G., Ryoo, M. S., Reymann, K., Rao, K., Pertsch, K.,
> 
> Mordatch, I., Michalewski, H., Lu, Y., Levine, S., Lee, L., Lee, T. E., Leal, I., Kuang, Y., Kalashnikov, D., Julian, R., Joshi, N. J.,
> 
> Irpan, A., Ichter, B., Hsu, J., Herzog, A., Hausman, K., Gopalakrishnan, K., Fu, C., Florence, P., Finn, C., Dubey, K. A., Driess,
> 
> D., Ding, T., Choromanski, K. M., Chen, X., Chebotar, Y., Carbajal, J., Brown, N., Brohan, A., Arenas, M. G., and Han, K. RT-2:
> 
> vision-language-action models transfer web knowledge to robotic control. In Tan, J., Toussaint, M., and Darvish, K. (eds.), _Conference_
> _on Robot Learning, CoRL 2023, 6-9 November 2023, Atlanta, GA, USA_, volume 229 of _Proceedings of Machine Learning Research_,
> pp. 2165–2183. PMLR, 2023. URL `[https://proceedings.mlr.press/v229/zitkovich23a.html](https://proceedings.mlr.press/v229/zitkovich23a.html)` .
> 
> 
> Zuo, Y., Zhang, K., Qu, S., Sheng, L., Zhu, X., Qi, B., Sun, Y., Cui, G., Ding, N., and Zhou, B. Ttrl: Test-time reinforcement learning,
> 
> 2025. URL `[https://arxiv.org/abs/2504.16084](https://arxiv.org/abs/2504.16084)` .
> 
> 
> 21
> 
> 
> **Absolute Zero:** **Reinforced Self-play Reasoning with Zero Data**
> 
> 
> **Appendix**
> 
> 
> **Appendix Contents**
> 
> 
> **A** **Reinforcement Learning with Verifiable Rewards.** **23**
> 
> 
> **B** **Implementation Details** **23**
> 
> 
> **C** **More Results** **24**
> 
> 
> C.1 Out-of-Distribution Performance Breakdown . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 24
> 
> 
> C.2 In-Distribution Results . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 24
> 
> 
> C.3 Interplay Between Propose and Solve Roles . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 24
> 
> 
> C.4 Complexity and Diversity Metrics of AZR Proposed Tasks . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 34
> 
> 
> C.5 Generated Code Complexity Dynamics Between Abd/Ded and Ind. . . . . . . . . . . . . . . . . . . . . . . . . . . 34
> 
> 
> **D** **Alternative Approaches Considered** **51**
> 
> 
> D.1 Error Deduction Task . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 51
> 
> 
> D.2 Composite Functions as Curriculum Learning . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 51
> 
> 
> D.3 Toying with the Initial _p_ ( _z_ ) . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 51
> 
> 
> D.4 Extra Rewards . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 51
> 
> 
> D.5 Environment Transition . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 52
> 
> 
> 22
> 
> 
> **Absolute Zero:** **Reinforced Self-play Reasoning with Zero Data**
> 
> 
> **A. Reinforcement Learning with Verifiable Rewards.**
> 
> 
> We use reinforcement learning to update our learner LLM, rewarding it based on a task-specific reward function _rf_, where the subscript
> _f_ indicates the task. The goal of the RL agent is to maximize the expected discounted sum of rewards. We adopt an online variant of RL,
> 
> REINFORCE++, which is optimized using the original PPO objective:
> 
> 
> 
> _|o|_ 
> - min [�] _st_ ( _θ_ ) _A_ [norm] _f,q_ _[,]_ [clip][ (] _[s][t]_ [(] _[θ]_ [)] _[,]_ [ 1] _[ −]_ _[ϵ,]_ [ 1 +] _[ ϵ]_ [)] _[ A]_ [norm] _f,q_ 
> _t_ =1
> 
> 
> 
> _L_ PPO( _θ_ ) = E _q∼P_ ( _Q_ ) _, o∼πθ_ old ( _O|q_ )
> 
> 
> 
> 
> - 1
> _|o|_
> 
> 
> 
> _,_ (9)
> 
> 
> 
> where _st_ ( _θ_ ) is the probability ratio between the new and old policies at timestep _t_, and _A_ [norm] _f,q_ [is the normalized advantage.]
> 
> 
> REINFORCE++ computes the normalized advantage as:
> 
> _A_ [norm] _f,q_ [=] _[r][f,q]_ _[−]_ std [mean] ( _Af,q_ [(] _[{][A][f,q]_ ) _[}][B]_ [)] _,_ (10)
> 
> _{_ _}_ _[B]_
> 
> 
> where _rf,q_ is the outcome reward for question _q_, task _f_, mean and std are calculated across the global batch with batch size _B_ . Note that
> 
> we do not apply any KL penalty to the loss or reward.
> 
> 
> **B. Implementation Details**
> 
> 
> [We built Absolute Zero Reasoner upon the veRL codebase (Sheng et al., 2025).](https://github.com/volcengine/verl) For code execution, we incorporated components from
> 
> [the QwQ Python executor.](https://github.com/QwenLM/QwQ/blob/main/eval/eval/math_opensource_utils/python_executor.py) [For safer code execution, we recommend using API-based services such as E2B instead.](https://e2b.dev/)
> 
> 
> All experiments were conducted on clusters of A800 GPUs, each experiment lasts around 3-5 days
> 
> 
> **Training Hyperparameters.** We show the hyperparameters used in our training in Table 3. We do not change them for any of
> 
> the runs.
> 
> |Parameter|Value|
> |---|---|
> |**Model Confguration**|**Model Confguration**|
> |Max Prompt Length|6144|
> |Max Response Length|8096|
> |Seed Batch Factor|4|
> |Max Programs|16384|
> |**Training Settings**|**Training Settings**|
> |Train Batch Size|64 * 6|
> |Learning Rate|1e-6|
> |Optimizer|AdamW|
> |Grad Clip|1.0|
> |Total Steps|500|
> |**RL Settings**|**RL Settings**|
> |Algorithm|TRR++ (Section 3.3.5)|
> |KL Loss|False|
> |KL Reward|False|
> |Entropy Coefcient|0.001|
> |PPO Epochs|1|
> |_N_ Rollouts|1|
> |Rollout Temperature|1.0|
> |Rollout Top-P|1.0|
> |_K_ References|6|
> |_N_ Samples to Estimate Task Accuracy|8|
> 
> 
> 
> _Table 3._ **Hyperparameters Used During AZR Self-play Training.**
> 
> 
> 23
> 
> 
> **Absolute Zero:** **Reinforced Self-play Reasoning with Zero Data**
> 
> |Model|Data Curation|Base Model|
> |---|---|---|
> |`Oat-7B` (Liu et al., 2025c)|8.5k math pairs (Hendrycks et al., 2021)|`Qwen2.5-7B-Math`|
> |`SimpleRL-Zoo` (Zeng et al., 2025b)|8.5k math pairs (Hendrycks et al., 2021)|`Qwen2.5-7B-Base`|
> |`OpenReasonerZero` (Hu et al., 2025)|57k STEM + math samples|`Qwen2.5-7B-Base`|
> |`PRIME-Zero` (Cui et al., 2025)|457k math + 27k code problems|`Qwen2.5Math-7B-Base`|
> |`CodeR1-Zero-7B-LC2k-1088` (Liu & Zhang, 2025)|2k Leetcode pairs|`Qwen2.5-7B-Instruct-1M`|
> |`CodeR1-Zero-7B-12k-832` (Liu & Zhang, 2025)|2k Leetcode + 10k TACO pairs (Li et al., 2023)|`Qwen2.5-7B-Instruct-1M`|
> |`AceCoder-7B-Ins-RM` (Zeng et al., 2025a)|22k code data|`Qwen2.5-7B-Instruct`|
> |`AceCoder-7B-Ins-Rule` (Zeng et al., 2025a)|22k code data|`Qwen2.5-7B-Instruct`|
> |`AceCoder-7B-Code-RM` (Zeng et al., 2025a)|22k code data|`Qwen2.5-7B-Coder`|
> |`AceCoder-7B-Code-Rule` (Zeng et al., 2025a)|22k code data|`Qwen2.5-7B-Coder`|
> |`Qwen-7B-Instruct` (Yang et al., 2024a)|1M SFT + 150k RL pairs|`Qwen2.5-7B-Base`|
> |`AZR-7B (Ours)`|**No data**|`Qwen2.5-7B-Base`|
> |`AZR-7B-Coder (Ours)`|**No data**|`Qwen2.5-7B-Coder`|
> 
> 
> 
> _Table 4._ **Reasoner Training Data Source and Base Model.**
> 
> ```
>         logging random multiprocessing pebble subprocess
>         threading datetime time hashlib calendar
>         bcrypt os.sys os.path sys.exit os.environ
> 
> ```
> 
> _Figure 10._ **Forbidden Python Modules.** List of Python modules forbidden to exist in proposed tasks’ programs.
> 
> 
> **C. More Results**
> 
> 
> **C.1. Out-of-Distribution Performance Breakdown**
> 
> 
> We plot the out-of-distribution performance, broken down by each benchmark and in aggregate, across training steps for our 7B, 7B-Coder,
> 
> 14B, and 14B-Coder models in Figures 30 to 33. We observe a strong correlation between training using AZR and improvements in both
> 
> mathematical and coding reasoning capabilities. Moreover, our models are trained for more steps than typical zero-style reasoners; while
> 
> overfitting can occur with static datasets, it is less likely in AZR due to dynamically proposed tasks.
> 
> 
> **C.2. In-Distribution Results**
> 
> 
> Since we have defined the task domains as input prediction and output prediction, we can directly evaluate our model’s capabilities in these
> 
> areas using popular code reasoning benchmarks: CruxEval-I(nput), CruxEval-O(utput), and LiveCodeBench-Execution (LCB-E) (Gu
> 
> et al., 2024; Jain et al., 2024), where CruxEval-O and LCB-E is solving the deduction task, and CruxEval-I is solving the abduction task.
> 
> In Figure 16, we visualize the evolution of these metrics during the training of `Absolute` `Zero` `Reasoner-base-7b` . As training
> 
> progresses, we observe a consistent improvement in in-distribution performance across steps. While these three benchmark curves do
> 
> not perfectly correlate with broader coding or math reasoning capabilities (compare Figure 16 with Figure 30), they serve as useful
> 
> proxies for tracking task-specific progress.
> 
> 
> **C.3. Interplay Between Propose and Solve Roles**
> 
> 
> We visualize the training dynamics between the propose and solve roles over training steps in Figures 17 to 19. We observe that, in
> 
> general, the solve roles produce more output tokens than the propose role. Intuitively, this makes sense: the propose role emphasizes
> 
> creativity and generation of novel tasks, whereas the solve role requires deeper reasoning, which naturally leads to longer outputs.
> 
> 
> Interestingly, we also observe a consistent ordering in token length across reasoning types—abduction and deduction tasks tend to result
> 
> in shorter outputs than induction tasks during problem solving. This aligns with our intuition, as we observed the model engaging
> 
> in trial-and-error reasoning—repeatedly generating hypothesized inputs, evaluating their outcomes, and reflecting and retrying when
> 
> subsequent deductions fail to produce the correct output. To our knowledge, this is the first time such a clear distinction in token length
> 
> 
> 1 `VALIDATE_CODE_TEMPLATE` `=` `"""{code}`
> 
> 2 `repr(f({ inputs }))"""`
> 
> 
> 3
> 
> 
> 4 **`exec`** `( VALIDATE_CODE_TEMPLATE )`
> 
> 
> _Figure 11._ **Python Program to Check Valid Code.**
> 
> 
> 24
> 
> 
> **Absolute Zero:** **Reinforced Self-play Reasoning with Zero Data**
> 
> 
> 1 `EVAL_INPUT_PREDICTION_TEMPLATE` `=` `"""{code}`
> 
> 2 `{gold_output}` `==` `f({ agent_input })"""`
> 
> 
> 3
> 
> 
> 4 **`exec`** `( EVAL_INPUT_PREDICTION_TEMPLATE )`
> 
> 
> _Figure 12._ **Python Code to Check Agent Input Abduction Correctness.**
> 
> 
> 1 `EVAL_OUTPUT_PREDICTION_TEMPLATE` `=` `"""{code}`
> 
> 2 `eval ({ gold_output })` `==` `eval ({ agent_output })"""`
> 
> 
> 3
> 
> 
> 4 **`exec`** `( EVAL_OUTPUT_PREDICTION_TEMPLATE )`
> 
> 
> _Figure 13._ **Python Code to Check Agent Output Deduction Correctness.**
> 
> 
> 1 `EVAL_FUNCTION_PREDICTION_TEMPLATE` `=` `"""{code}`
> 
> 2 `matches` `=` `[]`
> 
> 3 `for` `gold_input,` `gold_output` `in` `zip({ gold_inputs},` `{ gold_outputs }):`
> 
> 4 `match` `=` `{gold_output}` `==` `f({ gold_input })`
> 
> 5 `matches.append(match)`
> 
> 6 `"""`
> 
> 
> 7
> 
> 
> 8 **`exec`** `( EVAL_OUTPUT_PREDICTION_TEMPLATE )`
> 
> 
> _Figure 14._ **Python Code to Check Agent Function Induction Correctness.**
> 
> 
> 1 `CHECK_DETERMINISM_TEMPLATE` `=` `"""{code}`
> 
> 2 `returns` `=` `f({ inputs })`
> 
> 3 `if` `returns` `!=` `f({ inputs }):`
> 
> 4 `raise` `Exception(’Non -deterministic` `code ’)`
> 
> 5 `repr(returns)"""`
> 
> 
> 6
> 
> 
> 7 **`exec`** `( CHECK_DETERMINISM_TEMPLATE )`
> 
> 
> _Figure 15._ **Python Code to Check Deterministic Program.**
> 
> 
> 0.65
> 
> 
> 0.60
> 
> 
> 
> 0.55
> 
> 
> 0.50
> 
> 
> 0.45
> 
> 
> 0.40
> 
> 
> 0.35
> 
> 
> 
> |Col1|Col2|Col3|Col4|Col5|Col6|Col7|Col8|Col9|Col10|Col11|
> |---|---|---|---|---|---|---|---|---|---|---|
> ||||||||||||
> ||||||||||||
> ||||||||||||
> ||||||||||||
> ||||||||~~Cr~~|~~xEval-I~~|||
> ||||||||Cr<br>~~Liv~~|uxEval-O<br>~~eCodeBen~~|~~ch-Execut~~|~~on~~|
> ||||||||||||
> 
> 
> 0 30 60 90 120 150 180 210 240 270
> 
> Training Steps
> 
> 
> 
> _Figure 16._ **In-distribution** **Benchmark** **Score** **During** **Training.** The evolution of CruxEval-I, CruxEval-O, and LiveCodeBench
> Execution during training for the `Qwen2.5-7B` base model trained using AZR.
> 
> 
> 25
> 
> 
> **Absolute Zero:** **Reinforced Self-play Reasoning with Zero Data**
> 
> 
> Solve Propose
> 
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
> 
> 4000
> 
> 
> 3000
> 
> 
> 2000
> 
> 
> 1000
> 
> 
> 
> 0.0
> 0 40 80 120 160 200 240 280
> 
> 
> 
> 0 40 80 120 160 200 240 280
> 
> 
> 
> Abduction Task Training Steps
> 
> 
> 
> _Figure 17._ **Abduction Task Reward and Token Lengths.** The task reward and token lengths of the two roles for abduction task type of
> 
> ```
> Absolute Zero Reasoner-base-7b.
> 
> ```
> 
> Solve Propose
> 
> 0.7
> 
> 
> 
> 0.6
> 
> 
> 0.5
> 
> 
> 0.4
> 
> 
> 0.3
> 
> 
> 0.2
> 
> 
> 0.1
> 
> 
> 
> 2000
> 
> 
> 1750
> 
> 
> 1500
> 
> 
> 1250
> 
> 
> 1000
> 
> 
> 750
> 
> 
> 500
> 
> 
> 
> 0.0
> 0 40 80 120 160 200 240 280
> 
> 
> 
> 0 40 80 120 160 200 240 280
> 
> 
> 
> 250
> 
> 
> 
> Induction Task Training Steps
> 
> 
> 
> _Figure 18._ **Induction Task Reward and Token Lengths.** The task reward and token lengths of the two roles for induction task type of
> 
> ```
> Absolute Zero Reasoner-base-7b.
> 
> ```
> 
> 26
> 
> 
> **Absolute Zero:** **Reinforced Self-play Reasoning with Zero Data**
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
> 
> 
> 
> 0.0
> 
> 
> 
> 
> |Col1|Col2|
> |---|---|
> |||
> |||
> |||
> |||
> |||
> |0<br>40<br>80<br>120|160<br>200<br>240<br>28|
> 
> 
> |Col1|Col2|Col3|
> |---|---|---|
> ||||
> ||||
> ||||
> ||||
> ||||
> ||||
> |0<br>40<br>80<br>1|0<br>40<br>80<br>1|0<br>40<br>80<br>1|
> 
> 
> 
> 
> 
> _Figure 19._ **Deduction Task Reward and Token Lengths.** The task reward and token lengths of the two roles for deduction task type of
> 
> ```
> Absolute Zero Reasoner-base-7b.
> 
> ```
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
> _Figure 20._ **Propose Deduction Task Example.** An example response of proposing a deduction task. k programs are selected as few-shot
> 
> examples to the model. The generated new program will then be verified through execution.
> 
> 
> 27
> 
> 
> **Absolute Zero:** **Reinforced Self-play Reasoning with Zero Data**
> 
> ```
> def f(numbers):
>   # Step 1: Filter out even numbers
>   filtered_numbers = [num for num in numbers if num % 2 != 0]
> 
>   # Step 2: Calculate the sum of the remaining odd numbers
>   sum_of_odd_numbers = sum(filtered_numbers)
> 
>   # Step 3: Reverse the order of the remaining odd numbers
>   reversed_odd_numbers = filtered_numbers[::-1]
> 
>   # Step 4: Calculate the product of the reversed odd numbers
>   product_of_reversed_odd_numbers = 1
>   for num in reversed_odd_numbers:
>     product_of_reversed_odd_numbers *= num
> 
>   # Step 5: Calculate the sum of the digits of the product
>   sum_of_digits_of_product = sum(int(digit) for digit in str(product_of_reversed_odd_numbers))
> 
> ```
> 
> ```
> # Step 6: Modify the original list by adding the sum of the digits to each even number
> # and subtracting it from each odd number
> modified_numbers = []
> for num in numbers:
> 
> ```
> 
> ```
> if num % 2 == 0:
> 
> ```
> 
> ```
>   modified_numbers.append(num + sum_of_digits_of_product)
> else :
> 
> ```
> 
> ```
> modified_numbers.append(num - sum_of_digits_of_product)
> 
> ```
> 
> ```
>   # Step 7: Return the modified list
>   return modified_numbers
> 
> ```
> 
> _Figure 21._ **Learned “ReAct” style program generation.** We observe that even after outputting the CoT and during answering when the
> 
> answer requires outputting code, the model usually uses comments in code to interleave its thinking and “acting”, an example is shown
> 
> here for induction task output by `Absolute` `Zero` `Reasoner-Coder-14b` during training. Similar observations are recently observed in
> 
> much bigger models (671b) for math proofs with DeepSeek Prover V2 (Ren et al., 2025).
> 
> 
> 28
> 
> 
> **Absolute Zero:** **Reinforced Self-play Reasoning with Zero Data**
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
> _Figure 22._ **Propose Abduction Task Example.** An example response of proposing an abduction task. The model uses comments as
> 
> reasoning when generating the program.
> 
> 
> 29
> 
> 
> **Absolute Zero:** **Reinforced Self-play Reasoning with Zero Data**
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
> _Figure 23._ **Propose Induction Task Example.** An example response of proposing an induction task. Given a random selected program,
> 
> the model needs to propose 10 inputs and a description of program. These inputs will be executed and verified to get outputs. At solve
> 
> phase, the model need to generate the program given the message and 5 input/output pairs (half is hidden cases)
> 
> 
> 30
> 
> 
> **Absolute Zero:** **Reinforced Self-play Reasoning with Zero Data**
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
> _Figure 24._ **Solve Abduction Task Example.** A more detailed version of the example shown in main Figure 7. The model is solving an
> 
> abduction task (predict input).
> 
> 
> 31
> 
> 
> **Absolute Zero:** **Reinforced Self-play Reasoning with Zero Data**
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
> _Figure 25._ **Solve Deduction Task Example.** Example of solving the deduction task. Given a program and input, the model simulates the
> 
> execution of the program until the final result.
> 
> 
> 32
> 
> 
> **Absolute Zero:** **Reinforced Self-play Reasoning with Zero Data**
> 
> 
> **Task:** **Solve Induction Task**
> 
> **Model Input:** Given the inputs and outputs, deduce the code snippet implementing the described functionality:
> **Input Description:** Given a list of integers, sort the list and then for each element at index _i_, multiply it by
> ( _n_ _i_ ), where _n_ is the total number of elements. Compute the final sum.
> _−_
> **Inputs:** `['[1,` `2,` `3,` `4]',` `'[4,` `3,` `2,` `1]',` `'[3,` `1,` `4,` `2]',` `'[1,` `2,` `2,` `3]',` `'[5]']`
> **Outputs:** `['20',` `'20',` `'20',` `'17',` `'5']`
> 
> ```
> # Golden
> def f(elements: list[int]) -> int:
>   n = len(elements)
>   sorted_elements = sorted(elements)
>   modified_elements = [sorted_elements[i] * (n - i) for i in range(n)]
>   return sum(modified_elements)
> 
> ```
> 
> **Model Output:**
> 
> Given the problem and the input/output pairs, we need to deduce a general code snippet that takes a sorted list and a list of multipliers, and then computes a final sum based on the multipliers.
> Let’s break down the problem step by step:
> 1. **Understand the Message:**
> 
> - We are given a list of integers.
> 
> - The list is sorted.
> 
> - For each element at index- We need to compute the sum of these products. _i_ in the sorted list, we multiply it by ( _n −_ _i_ ), where _n_ is the number of elements in the list.
> 
> 
> 
> 2. **Analyze the Input/Output Pairs:**
> 
> - For the input [1 _,_ 2 _,_ 3 _,_ 4], the sorted form is the same, and the output is 20.
> 
> 
> 
> 
> - For the input1 _·_ (4 _−_ 1) [4= _,_ 3 3, 2 _,_ 2 _·,_ (4 1] _−_, the sorted form is2) = 4, 3 _·_ (4 [1 _−,_ 23) _,_ 3= _,_ 4]3, and the output is 20 (same as above)., 4 _·_ (4 _−_ 4) = 0, Sum: 3 + 4 + 3 + 0 = 10
> 
> - For the input [3 _,_ 1 _,_ 4 _,_ 2], the sorted form is [1 _,_ 2 _,_ 3 _,_ 4], and the output is 20 (same as above).
> 
> 
> 
> **shortened**
> 3. **Re-evaluate the Outputs:**
> 
> - It seems there might be an error in the provided outputs for some inputs. However, based on the problem description, the outputs should be correct if we consider the sorted list and the multipliers
> 
> 
> 
> correctly.
> 
> 
> 
> 4. **Deduce the Function:**
> 
> - Given the sorted list and the list of multipliers, we can deduce the following function:
> 
> “‘python
> def f(a):
> sorted_a = sorted(a)
> n = len(sorted_a)
> result = 0
> for i in range(n):
> result += sorted_a[i] * (n - i)
> return result
> **...(shortened)**
> 
> 
> 
> 5. **Verify the Function:**
> 
> - Let’s verify the function with the provided inputs:
> 
> - For [1 _,_ 2 _,_ 3 _,_ 4]:
> 
> - Sorted list: [1 _,_ 2 _,_ 3 _,_ 4]
> 
> - Multipliers: [3 _,_ 4 _,_ 3 _,_ 0]
> 
> - Sum: 1 _·_ 3 + 2 _·_ 4 + 3 _·_ 3 + 4 _·_ 0 = 3 + 8 + 9 + 0 = 20
> 
> **...(shortened)**
> The corrected outputs should be: For [1 _,_ 2 _,_ 3 _,_ 4]: 20, For [4 _,_ 3 _,_ 2 _,_ 1]: 20, For [3 _,_ 1 _,_ 4 _,_ 2]: 20, For [1 _,_ 2 _,_ 2 _,_ 3]: 13, For [5]: 0
> Given the function:
> 
> 
> ```
> def f(a):
> 
> ```
> 
> ```
> sorted_a = sorted(a)
> n = len(sorted_a)
> result = 0
> for i in range(n):
> 
> ```
> 
> ```
>   result += sorted_a[i] * (n - i)
> return result
> 
> ```
> 
> 
> The outputs match the corrected sum.
> ### Final Answer
> **(repeat the program above)**
> 
> 
> _Figure 26._ **Solve Induction Task Example.** Example of solving an induction task. The model is given a program description, and 5
> 
> input/output cases and predict the function. Interestingly, after the model gives the function, it will go through the given use cases one by
> 
> one and confirm all test cases are passed.
> 
> 
> 33
> 
> 
> **Absolute Zero:** **Reinforced Self-play Reasoning with Zero Data**
> 
> 
> **Model** HEval [+] MBPP [+] LCB [v1-5] AIME’24 AIME’25 AMC’23 MATH500 Minerva OlympiadBench
> 
> 
> _Table 5._ **Detailed** **Breakdown** **of** **Evaluation** **Benchmarks** **for** **Other** **Model** **Sizes** **and** **Types.** Full evaluation of AZR trained on
> other models on three standard code benchmarks (HEval [+], MBPP [+], LCB [v1-5] ) and six math benchmarks (AIME’24, AIME’25, AMC’23,
> 
> MATH500, Minerva (Lewkowycz et al., 2022), OlympiadBench).
> 
> 
> has been observed and presented for jointly trained reasoning multi-tasks. Previously, length differences were typically noted between
> 
> correct and incorrect traces (Liu et al., 2025c).
> 
> 
> The reward dynamics between the propose and solve roles exhibit mildly adversarial behavior: when one receives higher rewards, the
> 
> other often receives lower rewards. However, this is not entirely adversarial, as the proposer is also penalized for generating unsolvable
> 
> tasks, encouraging overall cooperative behavior in the learning process.
> 
> 
> **C.4. Complexity and Diversity Metrics of AZR Proposed Tasks**
> 
> 
> We outline several metrics used to probe characteristics of the tasks proposed during the training of AZR from the base model. Specifically,
> 
> we log two sets of metrics: program complexity and task diversity. For complexity, we employ two proxy measures—ComplexiPy score
> 
> and the Halstead metric. To assess diversity, we compute the average abstract syntax tree (AST) edit distance between the proposed
> program and a set of _K_ reference programs, and an answer diversity metric. We calculate this answer diversity metric by tracking all
> 
> historical answers to the generated questions, i.e., the input-output pairs, and form a categorical distribution over these outputs. We
> define answer diversity as 1 _p_ (answer), where _p_ (answer) is the empirical probability of a specific answer—used as a proxy for the
> diversity of generated outputs. _−_
> 
> 
> We present these metrics in Figure 29. Interestingly, even without incorporating them explicitly into the reward function, the policy
> 
> appears to implicitly optimize for these metrics. This aligns well with intuitive notions of task difficulty and diversity, and that the policy
> 
> learned to propose increasingly challenging tasks over time using our proposed simple reward function in Equation (4).
> 
> 
> **C.5. Generated Code Complexity Dynamics Between Abd/Ded and Ind.**
> 
> 
> We use the `ComplexiPy` package to measure code complexity. For each generated program in the induction task, we compute the
> cognitive complexity difference from the corresponding “gold” code, _i.e_ . complexipy( _pπ_ {abduction,deduction} [propose] [)] _[ −]_ [complexipy][(] _[p][π]_ induction [solve] [)][ for each]
> pair, where the superscript of _π_ indicates the role and the subscript indicates the task type(s), and _p_ denotes the generated programs. On
> average, the difference of proposer and solver while holding the code’s functionality constant is 0 _._ 27, indicating that the proposer in the
> 
> abduction/deduction tasks often increases the cognitive complexity to make the code appear more convoluted, whereas the induction
> 
> solver tends to generate more efficient implementations.
> 
> 
> 34
> 
> 
> **Absolute Zero:** **Reinforced Self-play Reasoning with Zero Data**
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
> _Figure 27._ **Mixed Language CoT Example.** An example of the model solving an deduction task. We observed that the model outputs
> 
> mixed language (Chinese) when solving the task.
> 
> 
> 35
> 
> 
> **Absolute Zero:** **Reinforced Self-play Reasoning with Zero Data**
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
> _Figure 28._ **Absolute** **Zero** **Reasoner-Llama3.1-8b** **CoT** **Example** **on** **Solving** **Output** **Deduction** **Task.** The `Absolute` `Zero`
> `Reasoner-Llama3.1-8b` model appears to have strengthened its state-tracking behaviors during the course of training. We illus
> trate an example here.
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
> _Figure 29._ **Metrics on Proposed Tasks.** We break down the proposed task metrics into program complexity and diversity across programs
> 
> and answers. An upward trend is observed in all metrics, indicating that AZR implicitly optimizes for these qualities as training progresses.
> 
> 
> 36
> 
> 
> **Absolute Zero:** **Reinforced Self-play Reasoning with Zero Data**
> 
> 
> MATH REASONING
> 
> 
> AIME 2025
> 
> 
> 
> Olympiad Bench
> 
> 
> 
> 
> |0.200<br>0.150 Accuracy<br>0.100|Col2|Col3|Col4|Col5|Col6|Col7|Col8|Col9|
> |---|---|---|---|---|---|---|---|---|
> |0.100<br>0.150<br>0.200<br>Accuracy|||||||||
> |0.100<br>0.150<br>0.200<br>Accuracy|||||||||
> |0.100<br>0.150<br>0.200<br>Accuracy|||||||||
> |0.100<br>0.150<br>0.200<br>Accuracy|||||||||
> |0.100<br>0.150<br>0.200<br>Accuracy|||||||||
> 
> 
> 
> 
> 
> AIME 2024
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
> 0.700
> 
> 
> 0.690
> 
> 
> 0.680
> 
> 
> 0.670
> 
> 
> 0.660
> 
> 
> 0.570
> 
> 
> 0.560
> 
> 
> 0.550
> 
> 
> 0.540
> 
> 
> 
> 0.740
> 
> 0.730
> 
> 
> 
> HumanEval+
> 
> 
> 
> 
> 
> |Col1|Col2|Col3|Col4|Col5|Col6|Col7|Col8|Col9|Col10|LiveCodeBench<br>0.280<br>0.260|
> |---|---|---|---|---|---|---|---|---|---|---|
> ||||||||||||
> ||||||||||||
> |||||||||||50<br>75<br>100<br>125<br>150<br>175<br>200<br>225<br>250<br>0.240<br><br>50<br>75<br>100<br>125<br>150<br>175<br>200<br>225<br>250<br>0.420<br>0.440<br>0.460<br>0.480<br>Overall Average<br>**  nce Breakdown.**|
> ||||||||||||
> ||||||||||||
> ||||||||||||
> 
> 
> 37
> 
> 
> |Col1|Col2|
> |---|---|
> |50<br>75<br>100<br>125<br>150<br>175<br>200<br>225<br>250<br>0.300<br>0.320<br>0.340<br>0.360<br>0.380<br>0.400<br>Accuracy<br>Math Average<br>_Figure 30._ **Abso**|**l**|
> |50<br>75<br>100<br>125<br>150<br>175<br>200<br>225<br>250<br>0.300<br>0.320<br>0.340<br>0.360<br>0.380<br>0.400<br>Accuracy<br>Math Average<br>_Figure 30._ **Abso**||
> 
> 
> **Absolute Zero:** **Reinforced Self-play Reasoning with Zero Data**
> 
> 
> MATH REASONING
> 
> 
> AIME 2025
> 
> 
> 
> Olympiad Bench
> 
> 
> 
> 
> 
> AIME 2024
> 
> 
> 
> 
> 
> |0.200 0.100<br>0.080<br>0.150<br>0.060<br>0.100 0.040<br>0.020<br>0.050<br>0.000<br>50 100 150 200 250 300 350 50 100 15|Col2|Col3|Col4|Col5|Col6|Col7|Col8|0.380<br>0.360<br>0.340|Col10|Col11|Col12|Col13|Col14|Col15|
> |---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
> |50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.050<br>0.100<br>0.150<br>0.200<br><br>50<br>100<br>15<br>0.000<br>0.020<br>0.040<br>0.060<br>0.080<br>0.100|50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.050<br>0.100<br>0.150<br>0.200<br><br>50<br>100<br>15<br>0.000<br>0.020<br>0.040<br>0.060<br>0.080<br>0.100||||||||||||||
> |50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.050<br>0.100<br>0.150<br>0.200<br><br>50<br>100<br>15<br>0.000<br>0.020<br>0.040<br>0.060<br>0.080<br>0.100|50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.050<br>0.100<br>0.150<br>0.200<br><br>50<br>100<br>15<br>0.000<br>0.020<br>0.040<br>0.060<br>0.080<br>0.100||||||||||||||
> |50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.050<br>0.100<br>0.150<br>0.200<br><br>50<br>100<br>15<br>0.000<br>0.020<br>0.040<br>0.060<br>0.080<br>0.100|50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.050<br>0.100<br>0.150<br>0.200<br><br>50<br>100<br>15<br>0.000<br>0.020<br>0.040<br>0.060<br>0.080<br>0.100||||||||||||||
> |50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.050<br>0.100<br>0.150<br>0.200<br><br>50<br>100<br>15<br>0.000<br>0.020<br>0.040<br>0.060<br>0.080<br>0.100|50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.050<br>0.100<br>0.150<br>0.200<br><br>50<br>100<br>15<br>0.000<br>0.020<br>0.040<br>0.060<br>0.080<br>0.100||||||||||||||
> |50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.050<br>0.100<br>0.150<br>0.200<br><br>50<br>100<br>15<br>0.000<br>0.020<br>0.040<br>0.060<br>0.080<br>0.100|0.020<br>|0.020<br>|0.020<br>|0.020<br>|0.020<br>|0.020<br>|0.020<br>|0.020<br>|0.020<br>|0.020<br>|0.020<br>|0.020<br>|0.020<br>|0.020<br>|
> |50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.050<br>0.100<br>0.150<br>0.200<br><br>50<br>100<br>15<br>0.000<br>0.020<br>0.040<br>0.060<br>0.080<br>0.100|0.020<br>||||||||||||||
> |50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.050<br>0.100<br>0.150<br>0.200<br><br>50<br>100<br>15<br>0.000<br>0.020<br>0.040<br>0.060<br>0.080<br>0.100|0.020<br>||||||||||||||
> 
> 
> Minerva
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
> Math 500
> 
> 
> MBPP+
> 
> 
> 
> AMC 2023
> 
> 
> 50 100 150 200 250 300 350
> 
> 
> LiveCodeBench
> 
> 
> 
> 
> 
> HumanEval+
> 
> 
> 
> 
> 
> 
> 
> 
> |Col1|Col2|Col3|Col4|Col5|Col6|Col7|Col8|
> |---|---|---|---|---|---|---|---|
> |||||||||
> |||||||||
> |||||||||
> |||||||||
> |50<br>100<br>150<br>200<br>250<br>300<br>350<br>50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.320<br>0.340<br>0.360<br>0.380<br>0.400<br><br>Math Average<br>_Figure 31._ **Absolut**|OVERAL<br>50<br>100<br>15<br>50<br>100<br>15<br>0.580<br>0.590<br>0.600<br>0.610<br>0.620<br>0.630<br>C<br>**e Zero Reasoner-**|OVERAL<br>50<br>100<br>15<br>50<br>100<br>15<br>0.580<br>0.590<br>0.600<br>0.610<br>0.620<br>0.630<br>C<br>**e Zero Reasoner-**|OVERAL<br>50<br>100<br>15<br>50<br>100<br>15<br>0.580<br>0.590<br>0.600<br>0.610<br>0.620<br>0.630<br>C<br>**e Zero Reasoner-**|OVERAL<br>50<br>100<br>15<br>50<br>100<br>15<br>0.580<br>0.590<br>0.600<br>0.610<br>0.620<br>0.630<br>C<br>**e Zero Reasoner-**|OVERAL<br>50<br>100<br>15<br>50<br>100<br>15<br>0.580<br>0.590<br>0.600<br>0.610<br>0.620<br>0.630<br>C<br>**e Zero Reasoner-**|OVERAL<br>50<br>100<br>15<br>50<br>100<br>15<br>0.580<br>0.590<br>0.600<br>0.610<br>0.620<br>0.630<br>C<br>**e Zero Reasoner-**|OVERAL<br>50<br>100<br>15<br>50<br>100<br>15<br>0.580<br>0.590<br>0.600<br>0.610<br>0.620<br>0.630<br>C<br>**e Zero Reasoner-**|
> |50<br>100<br>150<br>200<br>250<br>300<br>350<br>50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.320<br>0.340<br>0.360<br>0.380<br>0.400<br><br>Math Average<br>_Figure 31._ **Absolut**||||||||
> 
> 
> |Col1|Col2|Col3|Col4|Col5|Col6|Col7|
> |---|---|---|---|---|---|---|
> ||||||||
> |50<br>100<br>15<br>0.260<br><br>50<br>100<br>15<br>0.460<br>0.480<br>0.500<br>Ov|||||||
> |**    nce Breakdown.**|**    nce Breakdown.**|**    nce Breakdown.**|||||
> ||||||||
> 
> 
> **Absolute Zero:** **Reinforced Self-play Reasoning with Zero Data**
> 
> 
> MATH REASONING
> 
> 
> |0.200<br>0.150<br>0.100<br>0.050<br>50 100 150 200 250 300 350|Col2|Col3|Col4|Col5|Col6|Col7|Col8|
> |---|---|---|---|---|---|---|---|
> |50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.050<br>0.100<br>0.150<br>0.200||||||||
> |50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.050<br>0.100<br>0.150<br>0.200||||||||
> |50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.050<br>0.100<br>0.150<br>0.200||||||||
> |50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.050<br>0.100<br>0.150<br>0.200||||||||
> 
> 
> |0.200<br>0.150<br>0.100<br>50 100 150 200 250 300 350|Col2|Col3|Col4|Col5|Col6|Col7|Col8|
> |---|---|---|---|---|---|---|---|
> |50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.100<br>0.150<br>0.200<br>||||||||
> |50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.100<br>0.150<br>0.200<br>||||||||
> |50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.100<br>0.150<br>0.200<br>||||||||
> 
> 
> |0.750<br>0.700<br>0.650<br>0.600<br>0.550<br>0.500<br>50 100 150 200 250 300 350<br>CODE REASONING<br>MBPP+<br>0.720<br>0.710<br>0.700<br>0.690<br>0.680|Col2|Col3|Col4|Col5|Col6|Col7|Col8|
> |---|---|---|---|---|---|---|---|
> |CODE REASONING<br>50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.500<br>0.550<br>0.600<br>0.650<br>0.700<br>0.750<br>0.680<br>0.690<br>0.700<br>0.710<br>0.720<br>MBPP+||||||||
> |CODE REASONING<br>50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.500<br>0.550<br>0.600<br>0.650<br>0.700<br>0.750<br>0.680<br>0.690<br>0.700<br>0.710<br>0.720<br>MBPP+||||||||
> |CODE REASONING<br>50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.500<br>0.550<br>0.600<br>0.650<br>0.700<br>0.750<br>0.680<br>0.690<br>0.700<br>0.710<br>0.720<br>MBPP+||||||||
> |CODE REASONING<br>50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.500<br>0.550<br>0.600<br>0.650<br>0.700<br>0.750<br>0.680<br>0.690<br>0.700<br>0.710<br>0.720<br>MBPP+||||||||
> |CODE REASONING<br>50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.500<br>0.550<br>0.600<br>0.650<br>0.700<br>0.750<br>0.680<br>0.690<br>0.700<br>0.710<br>0.720<br>MBPP+||||||||
> |CODE REASONING<br>50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.500<br>0.550<br>0.600<br>0.650<br>0.700<br>0.750<br>0.680<br>0.690<br>0.700<br>0.710<br>0.720<br>MBPP+||||||||
> |CODE REASONING<br>50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.500<br>0.550<br>0.600<br>0.650<br>0.700<br>0.750<br>0.680<br>0.690<br>0.700<br>0.710<br>0.720<br>MBPP+||||||||
> |CODE REASONING<br>50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.500<br>0.550<br>0.600<br>0.650<br>0.700<br>0.750<br>0.680<br>0.690<br>0.700<br>0.710<br>0.720<br>MBPP+||||||||
> |CODE REASONING<br>50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.500<br>0.550<br>0.600<br>0.650<br>0.700<br>0.750<br>0.680<br>0.690<br>0.700<br>0.710<br>0.720<br>MBPP+||||||||
> 
> 
> 
> 
> 
> AIME 2025
> 
> 
> Math 500
> 
> 
> 50 100 150 200 250 300 350
> 
> OVERALL PERFORMANCE
> 
> 
> Code Average
> 
> 
> 
> 
> 
> AIME 2024
> 
> 
> Minerva
> 
> 
> 
> 
> 
> Olympiad Bench
> 
> 
> 
> 39
> 
> 
> |0.400<br>0.350<br>0.300<br>50 100 150 200 250 300 350<br>HumanEval+<br>0.780<br>0.760<br>0.740<br>0.720|Col2|Col3|Col4|Col5|Col6|Col7|Col8|
> |---|---|---|---|---|---|---|---|
> |50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.300<br>0.350<br>0.400<br><br><br>0.720<br>0.740<br>0.760<br>0.780<br><br>HumanEval+||||||||
> |50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.300<br>0.350<br>0.400<br><br><br>0.720<br>0.740<br>0.760<br>0.780<br><br>HumanEval+||||||||
> |50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.300<br>0.350<br>0.400<br><br><br>0.720<br>0.740<br>0.760<br>0.780<br><br>HumanEval+||||||||
> |50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.300<br>0.350<br>0.400<br><br><br>0.720<br>0.740<br>0.760<br>0.780<br><br>HumanEval+||||||||
> |50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.300<br>0.350<br>0.400<br><br><br>0.720<br>0.740<br>0.760<br>0.780<br><br>HumanEval+||||||||
> |50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.300<br>0.350<br>0.400<br><br><br>0.720<br>0.740<br>0.760<br>0.780<br><br>HumanEval+||||||||
> |50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.300<br>0.350<br>0.400<br><br><br>0.720<br>0.740<br>0.760<br>0.780<br><br>HumanEval+||||||||
> |50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.700<br>50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.300<br>0.350<br>0.400<br><br>Math Average<br>_Figure 32._ **Abso**|50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.700<br>50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.300<br>0.350<br>0.400<br><br>Math Average<br>_Figure 32._ **Abso**|50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.700<br>50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.300<br>0.350<br>0.400<br><br>Math Average<br>_Figure 32._ **Abso**|50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.700<br>50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.300<br>0.350<br>0.400<br><br>Math Average<br>_Figure 32._ **Abso**|50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.700<br>50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.300<br>0.350<br>0.400<br><br>Math Average<br>_Figure 32._ **Abso**|50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.700<br>50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.300<br>0.350<br>0.400<br><br>Math Average<br>_Figure 32._ **Abso**|50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.700<br>50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.300<br>0.350<br>0.400<br><br>Math Average<br>_Figure 32._ **Abso**|50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.700<br>50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.300<br>0.350<br>0.400<br><br>Math Average<br>_Figure 32._ **Abso**|
> 
> 
> |0.400<br>0.350<br>0.300<br>0.250<br>50 100 150 200 250 300 350<br>AMC 2023<br>0.600<br>0.550<br>0.500|Col2|Col3|Col4|Col5|Col6|Col7|Col8|
> |---|---|---|---|---|---|---|---|
> |50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.250<br>0.300<br>0.350<br>0.400<br>0.500<br>0.550<br>0.600<br>AMC 2023||||||||
> |50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.250<br>0.300<br>0.350<br>0.400<br>0.500<br>0.550<br>0.600<br>AMC 2023||||||||
> |50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.250<br>0.300<br>0.350<br>0.400<br>0.500<br>0.550<br>0.600<br>AMC 2023||||||||
> |50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.250<br>0.300<br>0.350<br>0.400<br>0.500<br>0.550<br>0.600<br>AMC 2023||||||||
> |50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.250<br>0.300<br>0.350<br>0.400<br>0.500<br>0.550<br>0.600<br>AMC 2023||||||||
> |50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.250<br>0.300<br>0.350<br>0.400<br>0.500<br>0.550<br>0.600<br>AMC 2023||||||||
> |50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.450<br><br>50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.320<br>0.340<br>0.360<br>LiveCodeBench||||||||
> |50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.450<br><br>50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.320<br>0.340<br>0.360<br>LiveCodeBench||||||||
> |50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.440<br>0.460<br>0.480<br>0.500<br>Overall Average<br>**    ce Breakdown.**|50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.440<br>0.460<br>0.480<br>0.500<br>Overall Average<br>**    ce Breakdown.**|50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.440<br>0.460<br>0.480<br>0.500<br>Overall Average<br>**    ce Breakdown.**|50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.440<br>0.460<br>0.480<br>0.500<br>Overall Average<br>**    ce Breakdown.**|50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.440<br>0.460<br>0.480<br>0.500<br>Overall Average<br>**    ce Breakdown.**|50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.440<br>0.460<br>0.480<br>0.500<br>Overall Average<br>**    ce Breakdown.**|50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.440<br>0.460<br>0.480<br>0.500<br>Overall Average<br>**    ce Breakdown.**|50<br>100<br>150<br>200<br>250<br>300<br>350<br>0.440<br>0.460<br>0.480<br>0.500<br>Overall Average<br>**    ce Breakdown.**|
> 
> 
> **Absolute Zero:** **Reinforced Self-play Reasoning with Zero Data**
> 
> 
> MATH REASONING
> 
> 
> 
> 
> 
> AIME 2025
> 
> 
> |Col1|Col2|Col3|Col4|Col5|Col6|Col7|
> |---|---|---|---|---|---|---|
> ||||||||
> ||||||||
> ||||||||
> |0<br>1|00<br>1|50<br>200<br>2|50<br>200<br>2|0<br>300<br>3|0<br>300<br>3|50<br>4|
> 
> 
> 
> 50 100 150 200 250 300 350 400
> 
> OVERALL PERFORMANCE
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
> 0.440
> 
> 
> 0.420
> 
> 
> 0.340
> 
> 
> 
> 
> 
> 0.200
> 
> 
> 0.150
> 
> 
> 0.100
> 
> 
> 0.050
> 
> 
> 0.650
> 
> 
> 0.640
> 
> 
> 0.630
> 
> 
> 0.620
> 
> 
> 0.610
> 
> 
> |Col1|Col2|Col3|Col4|Col5|Col6|Col7|
> |---|---|---|---|---|---|---|
> ||||||||
> ||||||||
> ||||||||
> 
> 
> |Col1|Col2|Col3|Col4|Col5|Col6|Col7|
> |---|---|---|---|---|---|---|
> ||||||||
> ||||||||
> ||||||||
> 
> 
> 
> 
> ```
> <think>
> 
> ```
> 
> 
> _�→_
> 
> _�→_
> 
> 
> ```
> guessing and your peers puzzling.
> 
> ```
> 
> 
> _�→_ `is` `for` `the` `brains` `behind` `the` `future.`
> ```
> </think>
> - Absolute Zero Reasoner-Llama3.1-8b @ step 132
> 
> ```
> 
> |0.440<br>0.420<br>0.400<br>0.380<br>50 100 150 200 250 300 350 4<br>AMC 2023<br>0.700<br>0.650<br>0.600<br>0.550<br>0.500<br>50 100 150 200 250 300 350 4<br>LiveCodeBench<br>0.400<br>0.380<br>0.360<br>0.340<br>50 100 150 200 250 300 350 4|Col2|Col3|Col4|Col5|Col6|Col7|Col8|
> |---|---|---|---|---|---|---|---|
> |50<br>100<br>150<br>200<br>250<br>300<br>350<br>4<br>0.380<br>0.400<br>0.420<br>0.440<br> <br>50<br>100<br>150<br>200<br>250<br>300<br>350<br>4<br>0.500<br>0.550<br>0.600<br>0.650<br>0.700<br>AMC 2023<br>50<br>100<br>150<br>200<br>250<br>300<br>350<br>4<br>0.340<br>0.360<br>0.380<br>0.400<br>LiveCodeBench||||||||
> |50<br>100<br>150<br>200<br>250<br>300<br>350<br>4<br>0.380<br>0.400<br>0.420<br>0.440<br> <br>50<br>100<br>150<br>200<br>250<br>300<br>350<br>4<br>0.500<br>0.550<br>0.600<br>0.650<br>0.700<br>AMC 2023<br>50<br>100<br>150<br>200<br>250<br>300<br>350<br>4<br>0.340<br>0.360<br>0.380<br>0.400<br>LiveCodeBench||||||||
> |50<br>100<br>150<br>200<br>250<br>300<br>350<br>4<br>0.380<br>0.400<br>0.420<br>0.440<br> <br>50<br>100<br>150<br>200<br>250<br>300<br>350<br>4<br>0.500<br>0.550<br>0.600<br>0.650<br>0.700<br>AMC 2023<br>50<br>100<br>150<br>200<br>250<br>300<br>350<br>4<br>0.340<br>0.360<br>0.380<br>0.400<br>LiveCodeBench||||||||
> |50<br>100<br>150<br>200<br>250<br>300<br>350<br>4<br>0.380<br>0.400<br>0.420<br>0.440<br> <br>50<br>100<br>150<br>200<br>250<br>300<br>350<br>4<br>0.500<br>0.550<br>0.600<br>0.650<br>0.700<br>AMC 2023<br>50<br>100<br>150<br>200<br>250<br>300<br>350<br>4<br>0.340<br>0.360<br>0.380<br>0.400<br>LiveCodeBench||||||||
> |50<br>100<br>150<br>200<br>250<br>300<br>350<br>4<br>0.380<br>0.400<br>0.420<br>0.440<br> <br>50<br>100<br>150<br>200<br>250<br>300<br>350<br>4<br>0.500<br>0.550<br>0.600<br>0.650<br>0.700<br>AMC 2023<br>50<br>100<br>150<br>200<br>250<br>300<br>350<br>4<br>0.340<br>0.360<br>0.380<br>0.400<br>LiveCodeBench||||||||
> |50<br>100<br>150<br>200<br>250<br>300<br>350<br>4<br>0.380<br>0.400<br>0.420<br>0.440<br> <br>50<br>100<br>150<br>200<br>250<br>300<br>350<br>4<br>0.500<br>0.550<br>0.600<br>0.650<br>0.700<br>AMC 2023<br>50<br>100<br>150<br>200<br>250<br>300<br>350<br>4<br>0.340<br>0.360<br>0.380<br>0.400<br>LiveCodeBench|0<br>1|00<br>|50<br>200<br>2|50<br>200<br>2|0<br>300<br>3|0<br>300<br>3|50<br>4|
> |0.500<br>0.520<br>0.540<br>Overall Average|0.500<br>0.520<br>0.540<br>Overall Average|0.500<br>0.520<br>0.540<br>Overall Average|0.500<br>0.520<br>0.540<br>Overall Average|0.500<br>0.520<br>0.540<br>Overall Average|0.500<br>0.520<br>0.540<br>Overall Average|0.500<br>0.520<br>0.540<br>Overall Average|0.500<br>0.520<br>0.540<br>Overall Average|
> |0.500<br>0.520<br>0.540<br>Overall Average||||||||
> |0.500<br>0.520<br>0.540<br>Overall Average||||||||
> |0.500<br>0.520<br>0.540<br>Overall Average||||||||
> |50<br>100<br>150<br>200<br>250<br>300<br>350<br>4<br>**    nce Breakdown.**<br>`s extremely difficult to`<br>`ing models such as Snippi`<br> `less intelligent humans. This`|50<br>100<br>150<br>200<br>250<br>300<br>350<br>4<br>**    nce Breakdown.**<br>`s extremely difficult to`<br>`ing models such as Snippi`<br> `less intelligent humans. This`|50<br>100<br>150<br>200<br>250<br>300<br>350<br>4<br>**    nce Breakdown.**<br>`s extremely difficult to`<br>`ing models such as Snippi`<br> `less intelligent humans. This`|50<br>100<br>150<br>200<br>250<br>300<br>350<br>4<br>**    nce Breakdown.**<br>`s extremely difficult to`<br>`ing models such as Snippi`<br> `less intelligent humans. This`|50<br>100<br>150<br>200<br>250<br>300<br>350<br>4<br>**    nce Breakdown.**<br>`s extremely difficult to`<br>`ing models such as Snippi`<br> `less intelligent humans. This`|50<br>100<br>150<br>200<br>250<br>300<br>350<br>4<br>**    nce Breakdown.**<br>`s extremely difficult to`<br>`ing models such as Snippi`<br> `less intelligent humans. This`|50<br>100<br>150<br>200<br>250<br>300<br>350<br>4<br>**    nce Breakdown.**<br>`s extremely difficult to`<br>`ing models such as Snippi`<br> `less intelligent humans. This`|50<br>100<br>150<br>200<br>250<br>300<br>350<br>4<br>**    nce Breakdown.**<br>`s extremely difficult to`<br>`ing models such as Snippi`<br> `less intelligent humans. This`|
> 
> 
> 
> _Figure 34._ **Absolute Zero Reasoner – Llama3.1-8B “Uh-oh Moment.”** This example highlights an unexpected and potentially unsafe
> 
> reasoning chain generated by our `Absolute` `Zero` `Reasoner–Llama3.1-8B` model during training. Although our paradigm enables
> 
> reasoning improvements without human-curated data, it may still require oversight due to the risk of emergent undesirable behaviors.
> 
> 
> 40
> 
> 
> **Absolute Zero:** **Reinforced Self-play Reasoning with Zero Data**
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
> _Figure 35._ **Deepseek R1 Template.** All our models were trained using the default Deepseek R1 template.
> 
> 
> 41
> 
> 
> **Absolute Zero:** **Reinforced Self-play Reasoning with Zero Data**
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
> _Figure 36._ **Program Input Abduction Task—Problem Proposal Instruction.**
> 
> 
> 42
> 
> 
> **Absolute Zero:** **Reinforced Self-play Reasoning with Zero Data**
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
> 
> 
> 
> 
> 
> 
> 
> _Figure 37._ **Program Output Deduction Task—Problem Generation Instruction.**
> 
> 
> 43
> 
> 
> **Absolute Zero:** **Reinforced Self-play Reasoning with Zero Data**
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
> _Figure 38._ **Program Induction Task—Problem Proposal Instruction.**
> 
> 
> 44
> 
> 
> **Absolute Zero:** **Reinforced Self-play Reasoning with Zero Data**
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
> _Figure 39._ **Program Input Abduction Task—Problem Solving Prompt.**
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
> _Figure 40._ **Program Output Deduction Task—Problem Solving Prompt.**
> 
> 
> 45
> 
> 
> **Absolute Zero:** **Reinforced Self-play Reasoning with Zero Data**
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
> _Figure 41._ **Program Induction Task—Problem Solving Prompt.**
> 
> 
> 46
> 
> 
> **Absolute Zero:** **Reinforced Self-play Reasoning with Zero Data**
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
> 
> 
> 
> 
> 
> 
> 
> **`return`** `masked_board` 47
> 
> 
> **Absolute Zero:** **Reinforced Self-play Reasoning with Zero Data**
> 
> 
> **Model Output:**
> 
> To determine the input that produced the given output, we need to analyze the function ‘f‘ and understand
> what it does. Let’s break down the function step by step:
> 1. **Input Validation in ‘g_0‘**:  - The function ‘g_0‘ checks if the given board is valid.  - A board is valid
> 
> 
> if each row, each column, and each 3x3 subgrid contains the digits 1 through 9 exactly once.  - If the board
> is not valid, ‘g_0‘ returns ‘False‘.
> 2. **Input Validation in ‘f‘**:  - The function ‘f‘ first checks if there are any ”.” in the board. If there are, it
> raises a ‘ValueError‘.  - This means the input board to ‘f‘ must be a complete board with no ”.”.
> 3. **Masking the Board**:  - If the board is valid (i.e., ‘g_0(board)‘ returns ‘True‘), the function ‘f‘ proceeds
> to mask the board.  - It creates a copy of the board and then randomly selects 51 positions to mask with ”.”.
> 
>  - The masked board is then returned.
> 
> Given the output: “‘output [[”5”,”3”,”.”,”.”,”7”,”.”,”.”,”.”,”.”], [”6”,”.”,”.”,”1”,”9”,”5”,”.”,”.”,”.”],
> 
> [”.”,”9”,”8”,”.”,”.”,”.”,”.”,”6”,”.”], [”8”,”.”,”.”,”.”,”6”,”.”,”.”,”.”,”3”], [”4”,”.”,”.”,”8”,”.”,”3”,”.”,”.”,”1”],
> 
> [”7”,”.”,”.”,”.”,”2”,”.”,”.”,”.”,”6”], [”.”,”6”,”.”,”.”,”.”,”.”,”2”,”8”,”.”], [”.”,”.”,”.”,”4”,”1”,”9”,”.”,”.”,”5”],
> 
> [”.”,”.”,”.”,”.”,”8”,”.”,”.”,”7”,”9”]] “‘ We can see that the board has 51 positions masked with ”.”. Therefore,
> the input board must have been a complete board, and ‘f‘ masked 51 random positions.
> 
> 
> Let’s construct a complete board that, when masked, can produce the given output. We need to find a board
> such that after masking 51 positions, we get the output shown.
> Here is a complete board that matches the structure of the output: “‘python [ [”5”, ”3”, ”4”, ”6”, ”7”, ”8”,
> ”9”, ”1”, ”2”], [”6”, ”7”, ”2”, ”1”, ”9”, ”5”, ”3”, ”4”, ”8”], [”1”, ”9”, ”8”, ”3”, ”4”, ”2”, ”5”, ”6”, ”7”], [”8”,
> ”5”, ”9”, ”7”, ”6”, ”1”, ”4”, ”2”, ”3”], [”4”, ”2”, ”6”, ”8”, ”5”, ”3”, ”7”, ”9”, ”1”], [”7”, ”1”, ”3”, ”9”, ”2”,
> ”4”, ”8”, ”5”, ”6”], [”9”, ”6”, ”1”, ”5”, ”3”, ”7”, ”2”, ”8”, ”4”], [”2”, ”8”, ”7”, ”4”, ”1”, ”9”, ”6”, ”3”, ”5”],
> 
> [”3”, ”4”, ”5”, ”2”, ”8”, ”6”, ”1”, ”7”, ”9”] ] “‘
> Let’s verify that this board, when passed to the function ‘f‘, produces the given output.
> 1. The board is complete with no ”.”. 2. The board is valid because each row, each column, and each 3x3
> subgrid contains the digits 1 through 9 exactly once. 3. The function ‘f‘ will mask 51 random positions.
> Given the random nature of the masking, we need to ensure that the positions masked match the positions
> of ”.” in the output. Since the positions are random, we can assume that the function ‘f‘ with this complete
> 
> 
> board will produce the given output.
> Therefore, the input that produced the output is: “‘input [ [”5”, ”3”, ”4”, ”6”, ”7”, ”8”, ”9”, ”1”, ”2”], [”6”,
> ”7”, ”2”, ”1”, ”9”, ”5”, ”3”, ”4”, ”8”], [”1”, ”9”, ”8”, ”3”, ”4”, ”2”, ”5”, ”6”, ”7”], [”8”, ”5”, ”9”, ”7”, ”6”,
> ”1”, ”4”, ”2”, ”3”], [”4”, ”2”, ”6”, ”8”, ”5”, ”3”, ”7”, ”9”, ”1”], [”7”, ”1”, ”3”, ”9”, ”2”, ”4”, ”8”, ”5”, ”6”],
> 
> [”9”, ”6”, ”1”, ”5”, ”3”, ”7”, ”2”, ”8”, ”4”], [”2”, ”8”, ”7”, ”4”, ”1”, ”9”, ”6”, ”3”, ”5”], [”3”, ”4”, ”5”, ”2”,
> ”8”, ”6”, ”1”, ”7”, ”9”] ] “‘
> 
> 
> _Figure 42._ **Vibe Check 1:** **Sudoku Solver.** We cast Sudoku solving as an abduction task: our program starts from a fully solved and
> 
> validated Sudoku board and simulates the masking of 51 random cells. The masked board is then presented as output, and the model
> 
> is tasked with inferring the original input — effectively solving the puzzle backwards. An example solution is shown above, where
> 
> `AZR-Coder-14b` verifies its initial guess before correctly answering. Generation parameters: temperature=0.6.
> 
> 
> 48
> 
> 
> **Absolute Zero:** **Reinforced Self-play Reasoning with Zero Data**
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
> _Figure 43._ **Vibe Check 2:** **Sum Product Game.** [We cast the Sum-Product Game as an abduction task, where when the constraints of the](https://en.wikipedia.org/wiki/Sum_and_Product_Puzzle)
> 
> game are satisfied, function ‘f‘ returns True, return False otherwise. `AZR-Coder-14b` was able to first analyze the complicated constraints,
> 
> identify candidate solution and verify. Generation parameters: temperature=0.6, top_p=0.95.
> 
> 
> 50
> 
> 
> **Absolute Zero:** **Reinforced Self-play Reasoning with Zero Data**
> 
> 
> **D. Alternative Approaches Considered**
> 
> 
> In this section, we share many of the approaches we tried that did not prove to be particularly helpful for Absolute Zero Reasoner.
> 
> However, we believe it is especially valuable to share these findings with the community, as they are crucial for guiding future research.
> 
> Below, we outline each of the additional methods we explored during the development of our project.
> 
> 
> **D.1. Error Deduction Task**
> 
> 
> Since programming languages often have error messages, and these messages contain a lot of information about how someone might
> 
> expect a program to run, we also came up with another task domain: allowing the learner to propose a program _that will produce an_
> _error_, and requiring the solver to _deduce what kind of error is raised_ when executing this code. We experimented with this additional
> task alongside the induction ( _f_ ), deduction ( _o_ ), and abduction ( _i_ ) tasks. Unfortunately, we did not observe noticeable changes in
> 
> downstream performance with this additional task and since it requires more computational resources than our AZR setup, we decided
> 
> not to incorporate it into our final version. However, we believe further thorough investigation of this is well deserved.
> 
> 
> **D.2. Composite Functions as Curriculum Learning**
> 
> 
> One valuable property we can leverage from programming languages is the ability to compose functions—that is, to define a function as
> a composite of other functions, i.e., _f_ ( _g_ ( _x_ )). In our setting, when generating a program, we can not only require the output to be a valid
> 
> program but also constrain the LLM to utilize a predefined set of programs within its main function. For example, if the target program
> to be generated is _f_ ( ), we can sample a set of previously generated programs _g_ _0 _, . . ., gc_ from, and force a valid program to be
> _f_ ( _g_ _0 _,_ _, gc, i_ ). _·_ _{_ _}_ _D_
> _· · ·_
> 
> 
> Since all programs are generated by the LLM itself, this setup allows the model to bootstrap from its earlier generations, automatically
> 
> increasing the complexity of the generated programs. We interpret this mechanism as a form of curriculum learning: earlier programs
> 
> in the AZR self-play loop tend to be simpler, and as the loop progresses, they become increasingly complex. By composing newer
> 
> programs from progressively more difficult earlier ones, the resulting programs naturally inherit this growing difficulty, which in turn
> 
> challenges the solver step.
> 
> 
> For implementation, in generating tasks for abduction and deduction, we begin by sampling a binary decision from a binomial distribution
> with _p_ = 0 _._ 5. This determines whether the generated program should be a simple program or a composite one. If the sample is 0, we
> 
> prompt the LLM to generate a standard program along with a corresponding input. If the sample is 1, we prompt the LLM to generate a
> composite program. To construct the composite, we first sample an integer _c_ (1 _,_ 3), then uniformly select _c_ programs from the
> dataset _g_ _0 _, . . ., g D_ that are not themselves composite programs. _c_ as subcomponents, ensuring it composes these selected programs meaningfully.Finally, we prompt the LLM to generate a valid program that incorporates _∼U_ We additionally filter programs that did
> _{_ not utilize all the _}_ _c_ programs.
> 
> 
> However, we did not observe a significant difference when using this more complex curriculum compared to our simpler and more
> 
> effective approach. One failure mode we encountered was that the model often defaulted to simply returning “g(x)”, effectively learning
> _f_ ( _g_ ( _x_ )) = _g_ ( _x_ ), which failed to introduce any additional difficulty. This trivial behavior undermined the intended challenge, leading us
> 
> to deprioritize further exploration in this direction. While it may be possible to design a stricter reward mechanism—such as enforcing
> _f_ ( _g_ ( _x_ )) = _g_ ( _x_ ) by executing the code via a Python interpreter and penalizing such shortcuts—we leave this to future work.
> _̸_
> 
> **D.3. Toying with the Initial** _p_ ( _z_ )
> 
> We investigated a setting where the initial seed buffer (see Section 3.3.1 on how we generated these), _i.e_ . _p_ ( _z_ ) in Equation (3), is not
> 
> [self-generated by the base model, but instead sourced from the LeetCode Dataset.](https://huggingface.co/datasets/newfacade/LeetCodeDataset) We only modified this component and ran AZR
> 
> using the same procedure as before, continuing to add new valid programs to the initialized buffer. We observed an increase in initial
> 
> performance on coding benchmarks; however, the performance plateaued at roughly the same level after additional training steps,
> 
> compared to our official AZR setup. Interestingly, math performance was lower than in the official AZR setup, pointing towards that
> 
> on-policy data may be more beneficial to the learner to bootstrap from for mathematical reasoning. We believe that exploring different
> strategies for initializing and updating _p_ ( _z_ ) is an important and exciting direction for future research. We briefly explored different
> 
> strategies for sampling reference code, ultimately settling on uniform sampling for its simplicity, though we also experimented with
> 
> recency-based sampling and observed potential collapse.
> 
> 
> **D.4. Extra Rewards**
> 
> 
> **Complexity Rewards.** Code complexity is well studied in software science and could potentially be a good proxy for measuring
> 
> how hard it is to infer the properties of a piece of code for our reasoning learner. Therefore, for the problem proposer, we can add various
> 
> measures of complexity—such as Cyclomatic Complexity (Ebert et al., 2016), maintainability, etc.—to the reward function to incentivize
> 
> the proposer to produce more complex programs. For illustration purposes, we tried using the Maintainability measure and the Halstead
> 
> 
> 51
> 
> 
> **Absolute Zero:** **Reinforced Self-play Reasoning with Zero Data**
> 
> 
> complexity measure (Halstead, 1977) as intrinsic rewards. Concretely, we used the `complexipy` and `Radon` packages (Lopez, 2025;
> 
> Canal, 2023) to implement the respective metrics. These are then served as intrinsic rewards during the AZR self-play phase.
> 
> 
> **Diversity Rewards.** We also attempted using diversity rewards to . Inspired by DiveR-CT (Zhao et al., 2025a), we incorporate
> _code edit distance_ as an intrinsic reward. Specifically, we treat the reference programs shown in the prompt as anchors and compute the
> 
> average code edit distance between the generated program and these anchors. This serves as a measure of diversity in the generated
> 
> output. Additionally, we explored another diversity-based reward inspired by the notion of _surprise_ (Zhao et al., 2022). In this approach,
> 
> we construct a probability distribution over previously encountered input/output pairs that the solver has answered. The reward is then
> defined as 1 _p_ (input/output), where _p_ denotes the empirical probability of a particular input or output. While both strategies were
> evaluated in our experiments, we did not observe a significant difference in performance. _−_ However, we believe this aspect warrants
> 
> deeper investigation, as diversity rewards remain a promising avenue for strengthening AZR further.
> 
> 
> **Reward Aggregation.** We tested several ways on how to combine rewards for the proposer and discriminator. First, we separate
> the reward into extrinsic reward _r_ extrinsic and a set of intrinsic reward(s) _I_ = _ri_, and tested the following strategies to combine them
> into a single reward, _{_ _}_
> 
> 
> 
> _r_ = _r_ extrinsic +
> 
> 
> _r_ = _r_ extrinsic
> _·_
> 
> 
> _r_ = _r_ extrinsic
> _·_
> 
> 
> _r_ = _r_ extrinsic +
> 
> 
> 
> _|I|_
> 
> 
> _ri,_ (11)
> 
> _i_
> 
> _|I|_
> 
> 
> _ri,_ (12)
> 
> _i_
> 
> _|I|_
> 
> 
> _ri,_ (13)
> 
> _i_
> 
> _|I|_
> 
> 
> _ri._ (14)
> 
> _i_
> 
> 
> 
> We found that the simple additive way of combining rewards, a.k.a Equation (11), produced the most stable runs, possibly due to less
> 
> variance.
> 
> 
> **D.5. Environment Transition**
> 
> 
> We investigated how the transition function in our coding environment for the proposer. Specifically, after generating a piece of code, we
> 
> can apply a transformation function on it before giving it making it an valid tuple in our dataset. We investigated two
> 
> 
> **Removing Comments and Docstrings** In early iterations of our experiments, we noticed that comments and docstrings
> 
> were sometimes used to explicitly outline what the function was doing, or even served as a partial “note-taking” interleaved “ReAct”
> 
> process (Yao et al., 2023) of generating code—that is, the model could interleave think and action at the same time, and to make the
> 
> generated code valid, it used comments to encase its thoughts (Section C.3), similarly observed in DeepSeek-Prover-V2: (Ren et al.,
> 
> 2025). We then thought that to make the task harder for the solver, we should occlude this information from it. However, we observed
> 
> a significant performance drop after removing all comments and docstrings. One explanation for this phenomenon is that the only
> 
> “communication” channel between the proposer and the solver is restricted to the code itself, rather than some kind of “message” along
> 
> with the code. These messages can potentially provide hints to the solver, thus making some otherwise impossible tasks solvable. As a
> 
> result, the solver is able to learn from its experience and self-bootstrap out of certain unsolvable tasks.
> 
> 
> **Removing Global Variables.** We observed that some programs contain globally declared variables that may inadvertently leak
> 
> information about the correct answer—this issue is particularly prevalent in the input induction task generation and solving. Initially, we
> 
> were concerned that such leakage might lead to wasted computation on trivial or compromised examples. To address this, we developed
> 
> a systematic procedure to remove globally declared variables from the generated programs.
> 
> 
> However, after applying this cleaning step, we observed a noticeable drop in performance on our self-play reasoning tasks. One possible
> 
> explanation is that the generation step is unaware of this post-processing modification; since the reward is assigned after the transition
> 
> function (which includes variable removal), the model may not learn effectively from this mismatch.
> 
> 
> Moreover, we believe that even when answers are present, the solver still engages in nontrivial reasoning to reach a solution, potentially
> 
> benefiting from this exposure. This aligns with the idea of rationalization as proposed in STaR (Zelikman et al., 2022), where the model
> 
> pretends to not see the answer but still performs reasoning during learning. Therefore, in our final experiments, we choose not to remove
> 
> globally declared variables, allowing the self-play loop to naturally incorporate and adapt to such cases.
> 
> 
> 52
> 
> 
> [Source: Absolute Zero: Reinforced Self-play Reasoning with Zero Data](https://arxiv.org/abs/2505.03335)
