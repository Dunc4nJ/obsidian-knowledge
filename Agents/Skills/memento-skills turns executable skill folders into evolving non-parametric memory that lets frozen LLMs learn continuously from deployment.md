---
created: 2025-03-22
description: Memento-Skills treats reusable skill folders (code, prompts, specs) as external memory units in a Stateful Reflective Decision Process, enabling frozen LLMs to continuously improve through a Read-Write loop without any parameter updates.
source: https://arxiv.org/abs/2603.18743
type: framework
---

## Key Takeaways

Memento-Skills represents a significant step forward from prior skill-learning systems by making the **skill folder** — not a text snippet or trajectory log — the atomic unit of memory. Each skill contains a declarative spec (SKILL.md), helper scripts, and prompts, making it directly executable and independently improvable. This is the same structure we use in [[skills are living folders not markdown files and building them is the new developer setup|our own agent skills]], which validates the folder-as-unit-of-knowledge pattern at a theoretical level.

The core mechanism is a **Read-Write Reflective Learning loop**: the agent reads (retrieves) a skill via a trained router, acts (executes it through the frozen LLM), gets feedback from a judge, and writes (updates the skill or creates new ones). This is formally equivalent to policy iteration over a Reflected MDP, where the memory state is part of the augmented state space. The convergence guarantee from Memento 2 (Theorem 1.3) shows this isn't just engineering — it's provably convergent under bounded rewards and discount factor < 1. This connects to [[stable agentic RL requires sequence-level clipping and environment-aware advantages to prevent training collapse|the broader challenge of stable agentic RL]], but sidesteps parameter updates entirely.

The **behaviour-aligned contrastive router** is a key innovation over naive semantic retrieval. They train a Qwen3-Embedding-0.6B model via single-step offline RL with InfoNCE loss, treating routing as a KL-regularised Boltzmann policy. This lifts Recall@1 from 0.54 (semantic baseline) to 0.60 and end-to-end judge success from 0.79 to 0.80. The insight that [[SkillRL distills raw trajectories into a co-evolving hierarchical skill library that outperforms memory-based agents|semantic similarity is a poor proxy for behavioural utility]] is validated here with hard data — skills sharing domain terminology often require fundamentally different execution strategies.

The **self-evolution pipeline** handles failure attribution at the skill level: a failure attribution selector identifies which skill was responsible, a rewriter proposes targeted fixes, and if utility drops below a threshold, the system escalates to skill discovery (creating entirely new skills). All mutations are guarded by automatic unit tests — a synthetic test case is generated, executed, and scored before the mutation is accepted. This mirrors [[agent skills should self-improve through observed failures not stay as static prompt files|the principle that skills should self-improve through observed failures]].

Results on GAIA (66.0% vs 52.3% baseline) and HLE (38.7% vs 17.9% baseline) show the system works, with a crucial finding about **cross-task transfer**: it's strongest when skills align with structured domain categories. On GAIA (diverse, unstructured tasks), most trained skills never triggered during testing. On HLE (8 academic subject categories), skills transferred well within domains. This has direct implications for how we organise skill libraries — [[the best agent skills fit one category and grow from gotchas not upfront design|domain-aligned categorisation matters for reuse]].

The paper's convergence analysis decomposes the performance gap into three independent knobs: LLM quality, embedding quality, and memory density. This modularity means you can improve any axis independently — upgrade the LLM, improve the router, or simply run more episodes. The diminishing returns curve they observe is exactly what the theory predicts as the memory coverage radius shrinks.

The connection to [[Voyager builds a persistent skill library that enables open-ended exploration without gradient updates|Voyager's skill library approach]] is direct but Memento-Skills advances it with formal convergence guarantees and a trained router (vs Voyager's semantic retrieval). Similarly, it builds on [[MemSkill - Learning and Evolving Memory Skills for Self-Evolving Agents|MemSkill's memory-skill concept]] but with a more rigorous RL-theoretic foundation and executable multi-artefact skills rather than text-only memory entries.

## External Resources

- GitHub: <https://github.com/Memento-Teams/Memento-Skills>
- Skill marketplace: <https://skills.memento.run/market/>
- Memento 2 foundation paper: <https://arxiv.org/abs/2512.22716>
- Qwen3-Embedding-0.6B (router base): <https://huggingface.co/Qwen/Qwen3-Embedding-0.6B>
- GEPA (reflective prompt evolution): <https://arxiv.org/abs/2507.19457>
- Letta skill learning blog: <https://www.letta.com/blog/skill-learning>
- ProcMEM (procedural memory via non-parametric PPO): <https://arxiv.org/abs/2602.01869>

## Original Content

> [!quote]- Source Material
>
> # Memento-Skills: Let Agents Design Agents
>
> **Memento-Team**
>
> **Abstract**
>
> We introduce *Memento-Skills*, a generalist, continually-learnable LLM agent system that functions as an *agent-designing agent*: it autonomously constructs, adapts, and improves task-specific agents through experience. The system is built on a memory-based reinforcement learning framework with *stateful prompts*, where reusable skills (stored as structured markdown files) serve as persistent, evolving memory. These skills encode both behaviour and context, enabling the agent to carry forward knowledge across interactions.
>
> Starting from simple elementary skills (like Web search and terminal operations), the agent continually improves via the Read-Write Reflective Learning mechanism introduced in Memento 2. In the read phase, a behaviour-trainable skill router selects the most relevant skill conditioned on the current stateful prompt; in the write phase, the agent updates and expands its skill library based on new experience. This closed-loop design enables continual learning without updating LLM parameters, as all adaptation is realised through the evolution of externalised skills and prompts.
>
> Unlike prior approaches that rely on human-designed agents, Memento-Skills enables a generalist agent to design agents end-to-end for new tasks. Through iterative skill generation and refinement, the system progressively improves its own capabilities. Experiments on the General AI Assistants benchmark and Humanity's Last Exam demonstrate sustained gains, achieving 26.2% and 116.2% relative improvements in overall accuracy, respectively. Code is available at https://github.com/Memento-Teams/Memento-Skills.
>
> *Overview of self-evolving results on two benchmarks*
> ![[memento-skills-_page_0_Figure_7.jpeg]]
>
> ## 1 The Self-Evolving Agent Problem
>
> ### 1.1 Why Frozen LLMs Need External Memory
>
> Modern machine learning is about learning from experience. At the forefront of this evolution, Large Language Models (LLMs) have fundamentally reshaped the learning paradigm, demonstrating exceptional performance across diverse scenarios through few-shot learning, supervised fine-tuning, and post-training. Despite their promise, however, achieving practical utility typically requires parameter optimisation via backpropagation, which in turn demands vast amounts of data and computational resources. In practice, the cost and complexity of continual parameter updates mean that most LLM agents are deployed as frozen models: their parameters θ remain fixed after pre-training. When such an agent encounters a novel task, it draws only on knowledge encoded in θ and whatever fits in its context window.
>
> *The three paradigms of LLM adaptation: Pre-training, Fine-tuning, and Deployment-time learning*
> ![[memento-skills-_page_2_Figure_2.jpeg]]
>
> This creates a fundamental limitation: the agent is stateless and it cannot learn from its own deployment experience. The Stateful Reflective Decision Process (SRDP) resolves this by augmenting the agent with an episodic memory M_t that grows over time:
>
> π^μ(a | s, M_t) = Σ_{c ∈ M_t} μ(c | s, M_t) p_LLM(a | s, c)
>
> where p_LLM denotes the LLM decision kernel, s is the current state, c represents a retrieved case from the episodic memory M_t, and μ is the retrieval policy.
>
> *Overview of the Read-Write Reflective Learning loop*
> ![[memento-skills-_page_2_Figure_4.jpeg]]
>
> ### 1.2 Stateful Reflective Decision Process
>
> **Definition 1.1** (Skill Memory). A skill memory M_t = {c_i}^{N_t}_{i=1} is a finite, growing collection of reusable skill artefacts. Unlike traditional episodic memory that logs raw transitions, each c_i encapsulates a declarative specification, prompts, and executable code.
>
> **Definition 1.2** (SRDP). D_SRDP = ⟨S, A, P, R, γ, M, p_LLM⟩, extending the standard MDP with episodic memory M and an LLM decision kernel p_LLM(a | s, c).
>
> The Reflected MDP reformulates this with transition kernel:
>
> P^LLM(x' | x, c) = Σ_{a ∈ A} p_LLM(a | s, c) 1{x' = (s', Write(M, s, a, r))} P(s' | s, a)
>
> **Theorem 1.3** (Convergence). Under bounded rewards |r| ≤ R_max and γ < 1, the KL-regularised soft policy iteration over the Reflected MDP converges to the optimal retrieval policy μ*.
>
> ### 1.3 From Zero to Self-Evolving Agent
>
> *The GUI of Memento-Skills*
> ![[memento-skills-_page_3_Figure_13.jpeg]]
>
> ### 1.4 From Theory to Configuration
>
> In the foundational theory of Memento 2, Read-Write Reflective Learning is cast as an implicit form of policy iteration operating over raw episodic memory. Memento-Skills bridges this theory to production by upgrading the memory unit from passive trajectory logs to an active skill library:
>
> - **Writing (Policy Evaluation):** Instead of merely appending interaction logs, writing in Memento-Skills actively mutates the memory. It evaluates execution traces and consolidates the feedback by directly rewriting the reusable skill artefacts (code, prompts, and declarative specs).
> - **Reading (Policy Improvement):** Reading retrieves the most behaviourally relevant skill to guide the frozen LLM. By conditioning the agent's action on an actively refined skill rather than a static prompt or raw historical trace, the system achieves effective policy improvement for the current task.
>
> *Architecture of the Self-Evolving Agent based on Read-Write Reflective Learning*
> ![[memento-skills-_page_5_Figure_7.jpeg]]
>
> ## 2 Read-Write Reflective Learning
>
> ### 2.1 The Skill-Level Read-Write Loop
>
> Memento-Skills is grounded in the theory of Read-Write Reflective Learning, which provides the theoretical foundation for read-write memory updates as policy iteration. The skill library serves as an external, writable memory, and the agent alternates between (i) reading skills to induce an execution policy for the current goal and (ii) writing updates back to the skill artefacts based on post-hoc reflection.
>
> This self-evolving mechanism draws on a principle familiar from biological motor learning: early in skill acquisition, performance depends on deliberate, high-level planning; with repeated practice, neural pathways consolidate and execution becomes increasingly automatic. Analogously, a newly created skill in Memento-Skills may be brittle and narrowly scoped, but through iterative revision it is consolidated into a robust, reusable routine, finally forming muscle memory for recurring task patterns.
>
> After a failed attempt, an LLM-based failure attribution selector first examines the full execution trace and the judge's rationale to identify the single skill most responsible for the error, performing credit assignment at the skill level. Given this diagnosis, a skill rewriter then proposes targeted file-level updates. When the running utility of a skill drops below a threshold, the system escalates to skill discovery: it either restructures the existing skill folder or synthesises an entirely new skill. All mutations are guarded by an automatic unit-test gate.
>
> The Read-Write loop algorithm:
> ```
> Require: Utility threshold δ, minimum samples n_min, max feedback rounds K
> 1: Initialise skill library S_0 ← S_base, tip memory T_0 ← ∅, utility table U_0(s) ← 0.5 ∀s
> 2: for t = 0, 1, 2, ... do
>      (1) Observe: Receive task q_t; form augmented input x_t = (q_t, T_t)
>      (2) Read: Route c_t ← Router(x_t, S_t); if empty and CreateOnMiss: create new skill
>      (3) Execute: a_t ← LLM(x_t, c_t)
>      (4) Feedback: r_t ← Judge(q_t, a_t, a*_t)
>      (5) Write:
>          (5a) Utility update
>          (5b) Tip memory update
>          (5c) Skill evolution: TargetSelector → OptimiseSkill or DiscoverSkill
>          (5d) Feedback retry (≤ K rounds)
> end for
> ```
>
> *Component architecture of Memento-Skills*
> ![[memento-skills-_page_7_Figure_2.jpeg]]
>
> ### 2.2 Self-evolving Architecture
>
> *Self-Evolution Engine flowchart: transforms task failures into system growth*
> ![[memento-skills-_page_11_Figure_13.jpeg]]
>
> ### 2.3 InfoNCE Routing as a One-Step Soft Policy
>
> Purely semantic routers (e.g., BM25 or embedding routers such as Qwen-Embedding) are insufficient for skill selection, because they primarily capture semantic similarity rather than behavioural similarity. The router is trained with single-step offline RL on top of an embedding model, so that retrieval optimises for behaviour similarity instead of lexical or semantic proximity.
>
> The skill database is built from ~8k crawled skills, with ~3k sampled as seeds for synthetic query generation. An LLM-based judge verifies query quality, producing high-quality paired data of positive queries and hard negatives.
>
> Router score and multi-positive InfoNCE loss (temperature τ):
>
> L_i = -log (Σ_{q ∈ Q_i^+} exp(s(d_i,q)/τ)) / (Σ_{q ∈ Q} exp(s(d_i,q)/τ))
>
> One-step offline Q-learning view: cast routing as a one-step MDP with state q, action d, reward r(q,d). The learned score as a soft Q-function yields a Boltzmann routing policy:
>
> π_θ(d | q) = exp(Q_θ(q,d)/τ) / Σ_{d'} exp(Q_θ(q,d')/τ)
>
> This is equivalently the maximiser of a KL-regularised objective with uniform prior.
>
> *Retrieval pipeline overview: sparse BM25 + dense embedding, reciprocal rank fusion, cross-encoder reranker*
> ![[memento-skills-_page_12_Figure_3.jpeg]]
>
> *Router performance evaluation: offline recall and end-to-end execution success*
> ![[memento-skills-_page_12_Figure_3.jpeg]]
>
> Results: Memento-Qwen lifts Recall@1 from 0.32 (BM25) and 0.54 (Qwen3) to 0.60. Route hit rate: from 0.29 (BM25) and 0.53 (Qwen3) to 0.58. Judge success rate: from 0.50 and 0.79 to 0.80.
>
> ## 3 Self-Evolving Evaluation
>
> ### 3.1 Experimental Setup and Results
>
> **GAIA:** 165 questions (100 train, 65 test). Non-trivial real-world questions requiring multi-step reasoning, multimodality, web browsing, and tool use.
>
> **HLE:** 2,500 questions across 8 academic subjects. 788 train, 342 test.
>
> All experiments use Gemini-3.1-Flash as the underlying LLM.
>
> **GAIA Results:** Training success climbs from 65.1% (first attempt) to 91.6% (third round). Test: 66.0% (Memento-Skills) vs 52.3% (Read-Write baseline) — 13.7pp gain.
>
> *GAIA results: training accuracy across retries and test-set comparison*
> ![[memento-skills-_page_15_Figure_2.jpeg]]
>
> **HLE Results:** Training success from 30.8% (R0) to 54.5% (R3). Test: 38.7% (Memento-Skills) vs 17.9% (Read-Write baseline) — 20.8pp gain, more than doubling the baseline.
>
> *HLE results: training accuracy and test-set comparison*
> ![[memento-skills-_page_15_Figure_7.jpeg]]
>
> **Skill Library Growth:**
>
> *t-SNE projection of skill embeddings: seed skills (red) and learned skills (blue)*
> ![[memento-skills-_page_16_Figure_4.jpeg]]
>
> GAIA produces 41 skills; HLE expands to 235 skills spanning diverse domains. Learned skills cluster into semantically coherent neighbourhoods.
>
> ### 3.2 Convergence Analysis
>
> The asymptotic value gap decomposes as:
>
> sup_s |V^{π*}(s) - V^{π_M}(s)| ≤ (2R_max/(1-γ)^2) (ε_LLM(r_M) + δ_M)
>
> Three independent knobs: (1) LLM quality, (2) Embedding quality, (3) Memory density.
>
> *Three independent knobs for reducing the performance gap*
> ![[memento-skills-_page_17_Picture_7.jpeg]]
>
> ## 4 Conclusion
>
> Memento-Skills bridges the gap between memory-based learning and skill-based learning for LLM agents. The central insight is to treat executable skills as the unit of external memory, thereby transferring the theoretical guarantees of the Stateful Reflective Decision Process into a concrete, deployable artefact. Through the Read-Write Reflective Learning loop, the agent autonomously acquires, refines, and reuses these skills from deployment experience alone, requiring no parameter updates to the underlying LLM. A behaviour-aligned contrastive router, trained via single-step offline RL, ensures that retrieval optimises for execution success rather than surface-level similarity. Experiments on GAIA and HLE confirm that this skill-as-memory formulation substantially outperforms a static-library ablation, and that cross-task transfer is strongest when skills are aligned with structured domain categories.
>
> **Contributions:**
> - Algorithm Team: Huichi Zhou (UCL), Siyuan Guo (Jilin Univ), Anjie Liu (HKUST-GZ), Zhongwei Yu (HKUST-GZ), Ziqin Gong, Bowen Zhao, Zhixun Chen, Menglong Zhang (HKUST-GZ), Yihang Chen (UCL)
> - Engineering Team: Jinsong Li, Runyu Yang, Qiangbin Liu, Xinlei Yu, Jianmin Zhou, Na Wang, Chunyang Sun (AI Lab, Yangtze River Delta)
> - Advisor: Jun Wang (UCL)
>
> *Reading path diagram showing interleaving Research and Practitioner tracks*
> ![[memento-skills-_page_21_Figure_4.jpeg]]

[Source: https://arxiv.org/abs/2603.18743](https://arxiv.org/abs/2603.18743)
