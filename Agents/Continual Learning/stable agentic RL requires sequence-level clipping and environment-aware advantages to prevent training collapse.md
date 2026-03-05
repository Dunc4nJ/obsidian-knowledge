---
created: 2025-07-05
description: ARLArena decomposes agentic RL into four design dimensions and proposes SAMPO, a stable policy optimization method that achieves 25% improvement over GRPO by combining sequence-level clipping, environment-aware advantages, and dynamic sampling.
source: https://arxiv.org/abs/2602.21534
type: paper
authors:
  - Xiaoxuan Wang
  - Han Zhang
  - Haixin Wang
  - Yidan Shi
  - Ruoyan Li
  - Kaiqiao Han
  - Chenyi Tong
  - Haoran Deng
  - Renliang Sun
  - Alexander Taylor
  - Yanqiao Zhu
  - Jason Cong
  - Yizhou Sun
  - Wei Wang
arxiv: "2602.21534"
---

## Abstract

Agentic reinforcement learning (ARL) has rapidly gained attention as a promising paradigm for training agents to solve complex, multi-step interactive tasks. Despite encouraging early results, ARL remains highly unstable, often leading to training collapse. ARLArena is a stable training recipe and systematic analysis framework that examines training stability in a controlled and reproducible setting. It constructs a clean standardized testbed, decomposes policy gradient into four core design dimensions, and assesses the performance and stability of each. Through this analysis, the authors propose SAMPO (Stable Agentic Multi-turn Policy Optimization), which achieves consistently stable training and strong performance across diverse agentic tasks with an average 25.2% improvement over the GRPO baseline.

## Key Takeaways

The central insight is that agentic RL is fundamentally harder than single-turn reasoning RL because multi-turn interactions introduce compounding errors, non-stationary dynamics, and sparse rewards that amplify instability. This connects directly to [[async RL from real conversations lets agents continuously improve without blocking inference]] — the stability problems ARLArena addresses are exactly what makes real-world continuous RL deployment difficult.

The paper's decomposition of policy gradient into four orthogonal dimensions (loss objective, importance sampling clipping, advantage design, dynamic sampling) is a genuinely useful analytical framework. Three key findings emerge: (1) tolerant clipping causes training collapse while sequence-level clipping ensures stability, (2) environment-level information in advantage design improves both stability and performance, and (3) dynamic sampling with fine-grained advantage filtering further benefits training. This systematic approach contrasts with the ad-hoc method proliferation in the field (GRPO, DAPO, SAPO, etc.), which ARLArena shows are really just different points in the same four-dimensional design space.

SAMPO's practical recipe — sequence-level clipping, environment-aware advantages, and dynamic filtering — achieves stable monotonic improvement across ALFWorld, Sokoban, WebShop, ScienceWorld, and TextCraft while baselines exhibit varying degrees of collapse. The 25.2% average improvement over GRPO is meaningful, but arguably the stability is more important than the raw performance gain. For anyone building [[learning machines turn agents from stateless tools into systems that compound knowledge across users and sessions]], training stability is the prerequisite that makes everything else possible.

The standardized testbed construction (behavior cloning initialization + format penalty + KL regularization + hyperparameter search) is valuable practical guidance for [[ProcMEM - Learning Reusable Procedural Memory from Experience via Non-Parametric PPO for LLM Agents]] and similar work that needs reliable RL baselines.

## External Resources

- [ARLArena GitHub](https://github.com/WillDreamer/ARL-Arena) — code, configs, and training recipes for reproducing the framework
- [UCLA-SCAI HuggingFace models](https://huggingface.co/UCLA-SCAI/models) — pretrained and fine-tuned model checkpoints

## Original Content

> [!quote]- Full Paper Text
> # **ARLArena: A Unified Framework for Stable** **Agentic Reinforcement Learning**
> 
> Xiaoxuan Wang [1,*], Han Zhang [1,*], Haixin Wang [1,*], Yidan Shi [1,†], Ruoyan Li [1,†], Kaiqiao Han [1,†], Chenyi Tong [2],
> Haoran Deng [1], Renliang Sun [1], Alexander Taylor [1], Yanqiao Zhu [1], Jason Cong [1], Yizhou Sun [1], Wei Wang [1]
> 
> 
> _1University of California, Los Angeles,_ _2University of Wisconsin–Madison_
> 
> _∗These authors share first authorship._ _†These authors share second authorship._
> 
> 
> Agentic reinforcement learning (ARL) has rapidly gained attention as a promising paradigm for training agents
> to solve complex, multi-step interactive tasks. Despite encouraging early results, ARL remains highly unstable,
> often leading to training collapse. This instability limits scalability to larger environments and longer interaction
> horizons, and constrains systematic exploration of algorithmic design choices. In this paper, we first propose
> **ARLArena**, a stable training recipe and systematic analysis framework that examines training stability in a
> controlled and reproducible setting. ARLArena first constructs a clean and standardized testbed. Then, we
> decompose policy gradient into four core design dimensions and assess the performance and stability of each
> dimension. Through this fine-grained analysis, we distill a unified perspective on ARL and propose **SAMPO**, a
> stable agentic policy optimization method designed to mitigate the dominant sources of instability in ARL.
> Empirically, SAMPO achieves consistently stable training and strong performance across diverse agentic tasks.
> Overall, this study provides a unifying policy gradient perspective for ARL and offers practical guidance for
> building stable and reproducible LLM-based agent training pipelines.
> 
> 
> **GitHub:** `[https://github.com/WillDreamer/ARL-Arena](https://github.com/WillDreamer/ARL-Arena)`
> **HuggingFace:** `[https://huggingface.co/UCLA-SCAI/models](https://huggingface.co/UCLA-SCAI/models)`
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> **Figure** **1** _|_ Overview of **ARLArena** . Part 1: A standardized testbed via behavior cloning, format penalty, KL
> regularization, and hyperparameter search. Part 2: Policy gradient decomposition into four dimensions with representative
> methods mapped to each. Part 3: Key findings on training stability and collapse modes. Part 4: Insights unified into
> **SAMPO** for stable ARL training.
> 
> 
> 1
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
> Training Steps
> 
> 
> 
> ALFWorld
> 
> 
> 
> Training Steps
> 
> 
> 
> Sokoban
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
> DAPO SAPO GSPO EMPG GIGPO GRPO CISPO SAMPO (Ours)
> 
> 
> 
> **Figure 2** _|_ Training curves on ALFWorld (left) and Sokoban (right). SAMPO (ours) achieves the highest success rates
> on both environments with stable, monotonic improvement throughout training, while baseline methods exhibit varying
> degrees of instability. These results demonstrate that principled integration of sequence-level clipping, advantage design,
> and dynamic filtering, as combined in SAMPO, is critical for both training stability and final performance in multi-turn
> agentic RL.
> 
> ## **1 Introduction**
> 
> 
> Large language models (LLMs) have been increasingly deployed as autonomous agents for complex, multi-step
> interactive tasks spanning web navigation (Zhou et al., 2024), embodied environments (Shridhar et al., 2020), games (Xi
> et al., 2024), and deep research (Guan et al., 2025; Jin et al., 2025). These tasks demand planning, tool use, and
> long-horizon decision-making, necessitating training objectives that capture multi-turn interactions. Reinforcement
> learning (RL) offers a principled post-training framework for this purpose, building on its success in static reasoning
> tasks ( _e.g._, DeepSeek-R1 (Guo et al., 2025), OpenAI o1 (Jaech et al., 2024)), and early results in the agentic setting are
> promising (Cheng et al., 2025; Jin et al., 2025; Xi et al., 2024).
> 
> 
> However, agentic RL (ARL) training remains highly unstable and prone to collapse (Xi et al., 2025). This instability
> arises from the interactive, multi-turn nature of agentic environments, which introduce compounding challenges such as
> invalid actions, sparse rewards, long-horizon credit assignment, and non-stationary agent–environment dynamics (Wang
> et al., 2025b; Xu et al., 2026). Small deviations in early decisions can cascade across turns, causing distribution shifts
> that amplify credit-assignment noise and produce degenerate rollouts (Xia et al., 2026; Xie et al., 2026). Consequently,
> ARL outcomes are difficult to reproduce across runs and environments, and scaling to longer horizons or more complex
> interaction spaces remains severely limited (Abdulhai et al., 2023; Xi et al., 2025). These challenges underscore the need
> for stable and scalable training solutions for ARL.
> 
> 
> This paper addresses this gap by introducing **ARLArena**, a stable training recipe and systematic analysis framework for
> agentic reinforcement learning. We first construct a clean, standardized testbed through format correction, behavior
> cloning initialization, and KL-based regularization, establishing reliable baseline performance. We then decompose
> policy-gradient–based RL into four orthogonal design dimensions and evaluate the effectiveness and stability of each
> across diverse agentic tasks. Each dimension is examined in isolation using representative policy optimization (PO)
> methods; for methods that exhibit training collapse, we further diagnose the underlying failure modes and develop
> targeted stabilization strategies.
> 
> 
> This systematic analysis yields three key findings: (1) tolerant clipping induces training collapse, whereas sequence-level
> clipping ensures stable improvement; (2) incorporating environment-level information into advantage design improves
> both stability and performance; and (3) dynamic sampling combined with fine-grained advantage design further benefits
> ARL training. Motivated by these insights, we propose **S** table **A** gentic **M** ulti-turn **P** olicy **O** ptimization ( **SAMPO** ),
> a unified PO method that directly addresses the dominant sources of instability identified in our analysis. SAMPO
> consistently improves training stability and performance, achieving an average **25.2%** improvement over the GRPO
> baseline. We additionally study the impact of off-policy staleness in agentic environments and conduct comparative
> evaluations against proprietary models, demonstrating the robustness and generality of our approach.
> 
> 
> 2
> 
> 
> **Method** **Loss Objective** **Advantage (** _Ai_ **)**
> 
> 
> 
> **IS (** _wt_ **) Clipping** **Dynamical**
> **Adv** _<_ 0 **Adv** _>_ 0 **Sampling**
> 
> 
> 
> _G_
> 
> 
> 
> _i_ =1
> 
> 
> 
> 
> - 1 + _ε_ _wt_ _>_ 1 + _ε,_ _×_
> _wt,_ otherwise _._
> 
> 
> - 1 + _ε,_ _wt_ _>_ 1 + _ε,_ _×_
> _wt,_ otherwise _._
> 
> 
> - 1 + _ε,_ _wt_ _>_ 1 + _ε,_ _×_
> _wt,_ otherwise _._
> 
> 
> 
> 1
> GRPO - _G_
> _i_ =1 _[T][i]_
> 
> 
> 
> _Ti−_ 1
> 
> 
> 
> 
> 
> - min� _wt Ai,_ clip( _wt,_ 1 _±ε_ ) _Ai_ - _ri −_ std(mean( _ri_ ) _ri_ )
> 
> _t_ =0
> 
> 
> 
> std( _ri_ )
> 
> 
> 
> _Ti−_ 1
> 
> 
> 
> _t_ =0
> 
> 
> 
> 1
> GRPO `ST` _G_
> 
> 
> 
> 
> - _G_ 1
> 
> _i_ =1 _Ti_
> 
> 
> 
> min� _wt Ai,_ clip( _wt,_ 1 _±ε_ ) _Ai_ - _ri −_ std(mean( _ri_ ) _ri_ )
> 
> 
> 
> _Ti−_ 1
> 
> - _Mi_ min� _wt Ai,_ clip( _wt,_ 1 _±ε_ ) _Ai_ 
> 
> _t_ =0
> 
> 
> 
> _Ti−_ 1
> 
> 
> 
> 
> _|Ti|−_ 1
> 
>  
> 
> 
> 
> - 1 _−_ _ε,_ _wt_ _<_ 1 _−_ _ε,_
> _wt,_ otherwise _._
> 
> 
> - 1 _−_ _ε,_ _wt_ _<_ 1 _−_ _ε,_
> _wt,_ otherwise _._
> 
> 
> - 1 _−_ _ε,_ _wt_ _<_ 1 _−_ _ε,_
> _wt,_ otherwise _._
> 
> 
> 
> GRPO `SM`
> 
> 
> 
> 1
> 
> - _G_
> _i_ =1 _[T][i]_
> 
> 
> 
> 
> 
> _G_
> 
> 
> 
> _i_ =1
> 
> 
> 
> _ri −_ mean( _ri_ )
> 
> std( _ri_ )
> 
> 
> 
> 
> `[old]` _≤_ _δ_
> 
> _πθ_ ( _yt|x, y<t_ )
> 
> 
> 
> 1
> 
> _Mi_ = **1**  _Ai_ _≥_ 0 or _|Ti|_
> 
> 
> 
> 1
>  _Ai_ _≥_ 0 or _|Ti|_
> 
> 
> 
> 
> - log _[π][θ]_ `[old]` [(] _[y][t][|][x, y][<t]_ [)]
> 
> _t_ =0 _πθ_ ( _yt|x, y<t_ )
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> std(mean( _ri_ ) _ri_ ) _σ_ ( _τ_ neg( _wt −_ 1)) _·_ _τ_ neg4
> 
> 
> 
> _×_
> 
> 
> 
> _Ti−_ 1
> 
> 
> 
> 
> 4
> _σ_ ( _τ_ pos( _wt −_ 1)) _·_
> _τ_ pos
> 
> 
> 
> 1
> SAPO - _G_
> _i_ =1 _[T][i]_
> 
> 
> 
> _G_
> 
> 
> 
> _i_ =1
> 
> 
> 
> 
> - _fi,t_ ( _wt_ ) _Ai_ _ri −_ std(mean( _ri_ ) _ri_ )
> 
> _t_ =0
> 
> 
> 
> 1
> CISPO - _G_
> _i_ =1 _[T][i]_
> 
> 
> 
> _G_
> 
> 
> 
> _i_ =1
> 
> 
> 
> _Ti−_ 1
> 
> 
> 
> 
> 
> - sg( _wt_ ) _Ai_ log _πθ_ _ri −_ std(mean( _ri_ ) _ri_ )
> 
> _t_ =0
> 
> 
> 
> 
> - 1 _−_ _ε_ low _,_ _wt_ _<_ 1 _−_ _ε_ low _,_
> sg( _wt_ ) _,_ otherwise _._
> 
> 
> 
> std( _ri_ )
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> _T_ - _i−_ 1 min� _wt A′i,k_ _[,]_ [clip(] _[w][t][,]_ [ 1] _[±][ε]_ [)] _[A]_ _′i,k_ - _Ai_ + _ω · A_ step(ˆ _yi,k_ )
> 
> _t_ =0
> 
> 
> 
> 1
> GIGPO - _G_
> _i_ =1 _[T][i]_
> 
> 
> 
> _G_
> 
> 
> 
> _i_ =1
> 
> 
> 
> 
> - 1 _−_ _ε,_ _wt_ _<_ 1 _−_ _ε,_
> _wt,_ otherwise _._
> 
> 
> 
> _G_
> 
> 
> 
> _i_ =1
> 
> 
> _G_
> 
> 
> 
> _i_ =1
> 
> 
> 
> 1
> EMPG - _G_
> _i_ =1 _[T][i]_
> 
> 
> 1
> DAPO - _G_
> _i_ =1 _[T][i]_
> 
> 
> 
> _T_ - _ti_ =0 _−_ 1 min� _wt A′i_ _[,]_ [clip(] _[w][t][,]_ [ 1] _[±][ε]_ [)] _[A]_ _′i_ - _g_ - _Hk_ - _Ai_ + _ζ f_ - _Hk_ +1� - 1 _w −t,_ _ε,_ _w_ otherwise _t_ _<_ 1 _−.ε,_
> 
> 
> 
> _Ti−_ 1
> 
> 
> 
> 
> 
> - 1 + _ε_ high _,_ _wt_ _>_ 1 + _ε_ high _,_ _×_
> sg( _wt_ ) _,_ otherwise _._
> 
> 
>  - 1 + _ε,_ _wt_ _>_ 1 + _ε,_ _×_
> _wt,_ otherwise _._
> 
> 
>  - 1 + _ε,_ _wt_ _>_ 1 + _ε,_ _×_
> _wt,_ otherwise _._
> 
> 
> - 1 + _ε_ high _,_ _wt_ _>_ 1 + _ε_ high _,_ ✓
> _wt,_ otherwise _._
> 
> 
> 
> 
> - min� _wt Ai,_ clip( _wt,_ 1 _±ε_ ) _Ai_ - _ri −_ std(mean( _ri_ ) _ri_ )
> 
> _t_ =0
> 
> 
> 
> 
> - 1 _−_ _ε_ low _,_ _wt_ _<_ 1 _−_ _ε_ low _,_
> _wt,_ otherwise _._
> 
> 
> 
> std( _ri_ )
> 
> 
> 
> **Table 1** _|_ A summary of policy optimization methods studied in ARLArena, decomposed along four design dimensions:
> loss objective formulation, advantage ( _Ai_ ), importance sampling (IS) clipping, and dynamic sampling. Colored entries
> highlight distinctive design choices: purple denotes modified loss aggregation (seq-mean-token-mean), violet indicates
> alternative IS clipping strategies (tolerant or sequence-level), and green marks novel advantage designs. The importance
> sampling weight is _wt_ = _πθ_ ( _yt_ _| x, y<t_ ) _/πθ_ `old` ( _yt_ _| x, y<t_ ), and sg( _·_ ) denotes the stop-gradient operator.
> 
> 
> In summary, our contributions are: (i) a unifying policy gradient perspective and four-dimensional categorization of PO
> methods for ARL; (ii) a standardized, reproducible testbed and diagnostic methodology for multi-turn ARL stability;
> (iii) principled, task-robust findings and remedies for common collapse modes; and (iv) SAMPO, a new PO method
> that achieves both reliable training and strong final performance. We hope this study provides a foundation for more
> reproducible and principled progress in LLM agent post-training.
> 
> ## **2 Problem Formulation**
> 
> 
> **2.1** **Policy Gradient for Agentic RL**
> 
> 
> During RL optimization for LLMs, the policy _πθ_ generates a response trajectory _y_ = ( _y_ 0 _, . . ., yT_ ) conditioned on a
> prompt _x_, which is subsequently used for policy updates (Ouyang et al., 2022). Following PPO-style optimization
> (Schulman et al., 2017), trajectories collected under a behavior policy _πθ_ old are used to update the current policy _πθ_ . The
> corresponding policy gradient can be written as:
> 
> 
> 
> 
> 
> 
> 
> _,_ (1)
> 
> 
> 
> _∇θL_ ( _θ_ ) = E _y∼πθ_ `old`
> 
> 
> 
> 
> - _T_
> 
>  
> 
> 
> _wt_ ( _y_ ) _∇θ_ log _πθ_ ( _yt_ _| x, y<t_ ) _A_ ( _x, y_ )
> 
> _t_ =0
> 
> 
> 
> where the importance sampling weight is given by:
> 
> 
> _Pθ_ ( _yt_ _| x, y<t_ ) _πθ_ ( _yt_ _| x, y<t_ )
> _wt_ ( _y_ ) = (2)
> _Pθ_ `old` ( _yt_ _| x, y<t_ ) [=] _πθ_ `old` ( _yt_ _| x, y<t_ ) _[.]_
> 
> 
> Here, _A_ ( _x, y_ ) represents the advantage of the sampled sequence.
> 
> 
> 3
> 
> 
> **Agentic** **RL.** An agent interacts with the environment over _K_ turns, forming a long-horizon decision-making
> process (Luo et al., 2026; Wei et al., 2026). At each turn, the policy conditions on the accumulated history to generate a
> response, from which an action is extracted and executed to transition the environment state.
> 
> 
> The initial user prompt is _x_ [(1)] . At turn _k_ _∈{_ 1 _, . . ., K}_, the policy generates a response _y_ [(] _[k]_ [)] _∼_ _πθ_ ( _·_ _|_ _x_ [(] _[k]_ [)] ). Given
> the environment state _s_ [(] _[k]_ [)], actions _a_ [(] _[k]_ [)] are extracted from _y_ [(] _[k]_ [)], and the environment transitions to the next state
> _s_ [(] _[k]_ [+1)] according to an update function _f_ : _s_ [(] _[k]_ [+1)] = _f_ - _a_ [(] _[k]_ [)] _, s_ [(] _[k]_ [)][�], where _f_ ( _·_ ) is the state transition function that
> incorporates tool calls, environment observations, or retrieved information. The user prompt for turn _k_ + 1, denoted
> _x_ [(] _[k]_ [+1)], is constructed from the updated state _s_ [(] _[k]_ [+1)] . Finally, the complete multi-turn interaction trajectory is defined as
> _τ_ = - _x_ [(1)] _, y_ [(1)] _, x_ [(2)] _, y_ [(2)] _, . . ., x_ [(] _[K]_ [)] _, y_ [(] _[K]_ [)][�] .
> 
> 
> In the multi-turn agent–environment setting described above, we decompose a _K_ -turn trajectory into single-turn updates.
> This yields the following policy gradient formulation for agentic LLM interaction:
> 
> 
> 
> _wt_ ( _y_ [(] _[k]_ [)] )
> 
> - �� IS
> 
> 
> 
> 
> _._ (3)
> 
> 
> 
> 
>     -    _∇θ_ log _πθ_ _yt_ [(] _[k]_ [)] _| x_ [(] _[k]_ [)] _, y<t_ [(] _[k]_ [)]
> 
> 
> - �� Log prob
> 
> 
> 
> _A_ ( _x_ [(] _[k]_ [)] _, y_ [(] _[k]_ [)] )
> 
> - �� Advantage
> 
> 
> 
> _∇θL_ ( _θ_ ) = E _τ_ _∼πθ_ `old`
> 
> 
> 
> _Tk_
> 
> - - _[K]_ 
> 
> _k_ =1 _t_ =0
> 
> 
> 
> **2.2** **Policy Gradient Decomposition Dimensions**
> 
> 
> According to Equation 3, the policy gradient formulation for agentic LLMs can be decomposed into four key research
> dimensions: Loss Aggregation, Importance Sampling (IS) clipping, Trajectory Filtering and Resampling, and Advantage
> Design. To study each dimension in isolation, we analyze the batch-level loss objective without loss of generality. We
> summarize mainstream PO algorithms across the different design dimensions of the policy gradient in Table 1.
> 
> 
> **Loss Aggregation.** In practice, we approximate the loss objective using different loss aggregation schemes.
> 
> 
> 
> _L_ ( _θ_ ) = E _y_ ( _i_ ) _∼πθ_ old �E _t_ - _ℓi,t_ ( _θ_ )� [�]
> 
> 
> 
> ≜ [1]
> 
> _N_
> 
> 
> 
> _N_
> 
> 
> 
> _i_ =1
> 
> 
> 
> 1
> _Ti_
> 
> 
> 
> _Ti−_ 1
> 
> 
> 
> _t_ =0
> 
> 
> 
> _ℓi,t_ ( _θ_ ) (seq-mean-token-mean) (4)
> 
> 
> 
> _Ti−_ 1
> 
> 
> 
> _t_ =0
> 
> 
> 
> 1
> ≜
> 
>  - _N_
> _i_ =1 _[T][i]_
> 
> 
> 
> _N_
> 
> 
> 
> _i_ =1
> 
> 
> 
> _ℓi,t_ ( _θ_ ) (token-mean) _,_ (5)
> 
> 
> 
> where _ℓi,t_ ( _θ_ ) := min� _wi,t_ ( _θ_ ) _Ai,_ clip� _wi,t_ ( _θ_ ) _,_ 1 _−_ _ε,_ 1 + _ε_ - _Ai_ �. _N_ denotes the total number of decomposed turns
> over trajectories. _Ai_ denotes the advantage of sequence _y_ [(] _[i]_ [)], and _wi,t_ ( _θ_ ) is the importance sampling ratio at token _t_ of
> sequence _y_ [(] _[i]_ [)] . Seq-mean-token-mean weights each token by the inverse of its trajectory length, biasing optimization
> toward shorter trajectories and potentially introducing response-level length bias. Token-mean assigns equal weight to
> all unmasked tokens in the batch. Additional aggregation strategies are provided in the Appendix A.1.
> 
> 
> **IS Clipping.** Clipping methods constrain the magnitude of policy updates by limiting the change in action probabilities
> relative to the old policy. By constraining the deviation between the new and old policies within a bounded range,
> clipping mitigates performance degradation and instability caused by excessively large policy updates. The loss objective
> is formulated as follows:
> 
> 
> 
> _Ti−_ 1
> 
> - min - _wi,t_ ( _θ_ ) _Ai,_ clip� _wi,t_ ( _θ_ ) _,_ 1 _±ε_ - _Ai_ - _._ (6)
> 
> 
> _t_ =0
> 
> 
> 
> 1
> _L_ ( _θ_ ) =
> 
>   - _N_
> _i_ =1 _[T][i]_
> 
> 
> 
> _N_
> 
> 
> 
> _i_ =1
> 
> 
> 
> Within the GRPO (Guo et al., 2025) framework, several clipping variants are considered, including CISPO (Chen et al.,
> 2025), SAPO (Gao et al., 2025), and GSPO (Zheng et al., 2025). CISPO employs a stop-gradient mechanism to avoid
> hard clipping of out-of-bounds tokens while preserving their gradient information. SAPO adopts a soft-clipping strategy,
> in which excessively large ratios are smoothly attenuated rather than truncated. GSPO performs clipping by using the
> sequence-level importance ratio as the clipping criterion. Detailed formulations of these variants are provided in Table 1
> and further introduced in Appendix A.2.
> 
> 
> 4
> 
> 
> **Algorithm** **Strategy** **Task Score** **Success Rate**
> 
> 
> + Behavior Cloning + 2.56 + 20.71
> 
> 
> 
> GRPO
> 
> 
> 
> + _R_ format + 0.49 + 7.34
> 
> 
> + KL _k_ 3( _x_ ) + 0.95 + 18.10
> 
> 
> 
> _ϵ_ : _e_ _[−]_ [2] _→_ _e_ _[−]_ [3] + 0.70 + 3.36
> GSPO
> 
> _ϵ_ : _e_ _[−]_ [3] _→_ _e_ _[−]_ [4] _−_ 1.16 _−_ 9.88
> 
> 
> 
> DAPO Max_try: 2 _→_ 3 + 0.59 + 22.15
> 
> 
> Temperature: 1 _→_ 2 _−_ 1.20 _−_ 9.85
> SAPO
> 
> Temperature: 2 _→_ 3 _−_ 0.70 _−_ 9.20
> 
> 
> **Table 2** _|_ Incremental stabilization strategies for constructing a standardized testbed on ALFWorld, evaluated using GRPO
> as the base policy optimizer. Each row adds one stabilization technique or adjusts a method-specific hyperparameter. Task
> Score and Success Rate report the absolute improvement (+) or degradation ( _−_ ) relative to the preceding configuration.
> 
> 
> **Trajectory Filtering and Resampling.** Dynamic sampling addresses inefficiency caused by zero-gradient trajectories
> in long-horizon agent training (Yu et al., 2025a).
> 
> 
> 
> _Ti−_ 1
> 
> - min - _wi,t_ ( _θ_ ) _Ai,_ clip� _wi,t_ ( _θ_ ) _,_ 1 _±ε_ - _Ai_ - _,_
> 
> 
> _t_ =0
> 
> 
> 
> 1
> _L_ ( _θ_ ) =
> 
>   - _N_
> _i_ =1 _[T][i]_
> 
> 
> 
> _N_
> 
> 
> 
> _i_ =1
> 
> 
> 
> (7)
> 
> 
> 
> s.t. 0 _<_                     - _y_ [(] _[i]_ [)] [��] is_equivalent( _a, y_ [(] _[i]_ [)] ) _< G._
> ���                                                                       - ����
> 
> 
> Here, _a_ denotes the ground-truth task completion target, and equivalence is determined by whether the agent successfully
> completes the task. It adaptively filters out trajectories whose sampled output groups receive identical rewards (e.g., all
> correct or all incorrect) and resamples additional trajectories to increase the proportion of samples with informative
> gradient signals.
> 
> 
> **Advantage Design.** Multi-turn agentic reinforcement learning introduces additional interaction steps and explicit
> agent–environment state transitions, which motivates specialized advantage designs. GiGPO (Feng et al., 2025) defines
> advantages at the state level by grouping actions conditioned on the same preceding environment state and assigning them
> a shared relative advantage. EMPG (Wang et al., 2025a) augments the advantage function with an entropy-dependent
> term, which modulates the learning signal at each turn to better account for uncertainty across interaction steps. Detailed
> formulations of these variants are provided in Table 1 and further introduced in Appendix A.3.
> 
> ## **3 Experimental Setup**
> 
> 
> **3.1** **Standardized Testbed**
> 
> 
> A primary challenge is constructing a fair and effective testbed for comparing different algorithms. To address this
> issue, we progressively apply a sequence of stabilization strategies shown in Table 2. Specifically, we start with
> behavior cloning, followed by format penalty enforcement and KL regularization when necessary, and finally PO-specific
> hyperparameter tuning. This process yields a standardized and stable testbed that provides a solid foundation for
> systematically comparing different policy optimization strategies.
> 
> 
> **(1) Behavior Cloning.** We first perform behavior cloning (BC) on supervised interaction traces to initialize the policy
> within a reasonable behavioral manifold. Specifically, we construct a multi-turn SFT dataset by deploying the Qwen3
> series model (Yang et al., 2025) in the target training environments, collecting self-generated interaction trajectories, and
> retaining only high-scoring rollouts for supervision. This self-bootstrapped SFT stage initializes the policy within a
> reasonable behavioral manifold aligned with the environment dynamics.
> 
> 
> 5
> 
> 
> **ALFWorld** **WebShop** **Sokoban** **TIR Math**
> **Dimension** **Method** **Avg**
> **Score** **Success** **Score** **Success** **Score** **Success** **AIME** **AIME25**
> 
> 
> Base GRPO 3.70 62.36 75.32 57.71 5.51 83.90 49.96 30.78 46.16 (48.08)
> 
> 
> Loss Agg GRPO `ST` 4.41 _↑_ 19.2% 72.61 _↑_ 16.4% 64.57 _↓_ 14.3% 51.29 _↓_ 11.1% 3.03 _↓_ 45.0% 68.73 _↓_ 18.1% 27.55 _↓_ 44.9% 21.63 _↓_ 29.7% 39.23 _↓_ 15.0%
> 
> 
> SAPO 0.80 _↓_ 78.4% 25.16 _↓_ 59.7% 73.85 _↓_ 1.9% 52.10 _↓_ 9.7% _−_ 0.23 _↓_ 104% 30.25 _↓_ 63.9% 45.00 _↓_ 9.9% 30.85 _↑_ 0.2% 32.22 _↓_ 30.2%
> 
> 
> 
> Importance
> Sampling
> 
> 
> Advantage
> Design
> 
> 
> Dynamic
> Sampling
> 
> 
> 
> CISPO 2.16 _↓_ 41.6% 54.42 _↓_ 12.7% 67.96 _↓_ 9.8% 54.71 _↓_ 5.2% _−_ 0.47 _↓_ 109% 26.02 _↓_ 69.0% 36.53 _↓_ 26.9% 30.87 _↑_ 0.3% 34.03 _↓_ 26.3%
> 
> 
> GSPO 5.19 _↑_ 40.3% 78.61 _↑_ 26.1% 85.29 _↑_ 13.3% 72.48 _↑_ 25.6% 5.22 _↓_ 5.3% 82.22 _↓_ 1.7% 51.29 _↑_ 2.7% 37.95 _↑_ 23.3% 52.28 _↑_ 13.3%
> 
> 
> GIGPO 4.97 _↑_ 34.3% 81.09 _↑_ 30.0% 67.76 _↓_ 10.0% 56.55 _↓_ 2.0% 5.19 _↓_ 5.8% 82.67 _↓_ 1.5% - - 49.71 _↑_ 3.4%
> 
> 
> EMPG 3.32 _↓_ 10.3% 57.91 _↓_ 7.1% 79.16 _↑_ 5.1% 64.32 _↑_ 11.5% 4.48 _↓_ 18.7% 79.16 _↓_ 5.6% - - 48.06 _↓_ 0.1%
> 
> 
> DAPOGRPO 1.95 _↓_ 47.3% 49.58 _↓_ 20.5% 62.43 _↓_ 17.1% 46.17 _↓_ 20.0% 5.16 _↓_ 6.4% 82.40 _↓_ 1.8% 54.66 _↑_ 9.4% 38.97 _↑_ 26.6% 42.67 _↓_ 7.6%
> 
> 
> DAPOGIGPO 2.49 _↓_ 32.7% 60.55 _↓_ 2.9% 88.10 _↑_ 17.0% 76.82 _↑_ 33.1% 6.01 _↑_ 9.1% 86.20 _↑_ 2.7% - - 53.36 _↑_ 11.0%
> 
> 
> 
> **Ours** **SAMPO** **7.04** _↑_ 90.3% **92.72** _↑_ 48.7% **88.37** _↑_ 17.3% **77.73** _↑_ 34.7% **6.56** _↑_ 19.1% **88.86** _↑_ 5.6% **–** **–** **60.21** _↑_ 25.2%
> 
> 
> **Table** **3** _|_ Performance comparison of policy optimization methods across four agentic tasks, evaluated on the SFT
> version of Qwen3-4B. Methods are organized by their primary design dimension: loss aggregation, importance sampling
> clipping, advantage design, and dynamic sampling. Green/red subscripts denote the percentage improvement/degradation
> relative to the GRPO baseline. SAMPO (ours) achieves the highest average score (59.55) with consistent gains across
> ALFWorld (92.72% success), WebShop (74.08% success), and Sokoban (88.86% success). The evaluation metric for
> TIR Math is Pass@4; “–” indicates the method is not applicable. For GRPO, the value in parentheses reports the average
> over the first three tasks only.
> 
> 
> **(2) Format Penalty.** We incorporate _R_ format that enforces structured outputs with explicit `<think>` `</think>` and
> `<action>` `</action>` tags. If the generated output violates this format ( _e.g._, missing tags, malformed nesting, or
> extraneous content outside the tags), we apply a fixed penalty to the final reward. This explicit structural constraint
> provides dense shaping signals during early training and substantially reduces invalid rollouts that would otherwise
> corrupt policy updates.
> 
> 
> **(3) Auxiliary KL Loss.** Unconstrained updates may cause the policy to drift excessively from the reference model.
> To regularize policy updates and preserve the pretrained knowledge embedded in the base model, we introduce a KL
> divergence penalty between the current policy _πθ_ and a reference policy _π_ ref . This constraint encourages conservative
> policy improvement while still allowing sufficient exploration in the action space. We adopt the commonly used
> Bregman divergence estimator _k_ 3 for KL approximation, which leverages control variates to achieve unbiasedness and
> low variance (Schulman, 2017). Specifically, _k_ 3 is defined as _k_ 3( _x_ ) = _δ_ ( _x_ ) _−_ 1 _−_ log _δ_ ( _x_ ) _,_ where _δ_ ( _x_ ) = _[p]_ _q_ ( [(] _x_ _[x]_ ) [)] [denotes]
> 
> the likelihood ratio.
> 
> 
> **(4) PO-specific Hyper-parameter Grid Search.** A natural question is how to ensure that each PO method is fairly
> evaluated in the multi-turn setting. Our solution is to first run each method with its default configuration, and then
> perform a PO-specific hyperparameter grid search. We continue tuning until the training trajectory becomes stable,
> measured by the variance of the success rate over the final 20% of training steps falling below a predefined threshold. As
> shown in Table 1, hyperparameters related to IS clipping are particularly sensitive. The best-performing configurations
> and full results are reported in Appendix B.
> 
> 
> **3.2** **Tasks and Training Details**
> 
> 
> We adapt ALFWorld (Shridhar et al., 2020), WebShop (Yao et al., 2022), Sokoban (Schrader, 2018), and TIR Math (Xue
> et al., 2025) as the agentic tasks. Our entire codebase is built upon the `verl` RL framework (Sheng et al., 2024).
> We employ an agentic-loop architecture to coordinate rollouts and environment interactions, after which we segment
> each complete trajectory into multiple single-turn samples for policy optimization. For mathematical tasks, we use
> `Qwen3-4B-base` as the policy model, while for all other tasks we initialize from the SFT-tuned variant `Qwen3-4B` . For
> consistency validation, we additionally employed SFT-tuned `Qwen3-8B`, and the corresponding experimental results are
> provided in Appendix C. All experiments are conducted on NVIDIA H200 or B200 GPUs. Key hyperparameters and
> training details are reported in Appendix B.
> 
> 
> 6
> 
> 
> **Figure 3** _|_ Training dynamics of six IS variants on ALFWorld: GRPO, GSPO, SAPO, CISPO, and their sequence-masked
> counterparts SAPO `SM` and CISPO `SM` . Panels show (from left to right) success rate, off-policy KL divergence between the
> current and behavior policies, KL loss between the current and reference policies, gradient norm, and valid-format ratio
> of rollout actions.
> 
> ## **4 Exploring Gradient Dimensions on ARL**
> 
> 
> The experimental results for all policy optimization methods are reported in Table 3. GRPO `ST` denotes GRPO with
> sequence-mean-token-mean loss aggregation. DAPO `GRPO` and DAPO `GIGPO` denote GRPO and GIGPO augmented with
> dynamic filtering, respectively.
> 
> 
> **4.1** **Impact of IS on ARL**
> 
> 
> We study GSPO, CISPO, and SAPO along the importance-sampling (IS) dimension. GSPO adopts sequence-level
> clipping, while CISPO and SAPO employ tolerant clipping techniques. For CISPO and SAPO, we further apply sequence
> masking (denoted as CISPO `SM` and SAPO `SM` ) to improve training stability. Detailed training dynamics are reported in
> Figure 3, with IS token-level and sequence-level analyses presented in Figure 4.
> 
> 
> Table 3 shows that CISPO and SAPO perform substantially worse than GRPO across all tasks, achieving average scores
> of 34.03 and 32.22, respectively, compared to 46.16 for GRPO. In contrast, GSPO consistently outperforms all other
> policy optimization methods, achieving an average improvement of 13.3% compared to GRPO.
> 
> 
> To understand training behavior beyond final performance, we analyze training dynamics from multiple perspectives
> across several metrics. Different IS designs induce varying distances between the current policy and both the behavior
> and reference policies during training. These distance variations, in turn, influence optimization behavior (reflected by
> gradient norms), impact data quality (through the valid action ratio), and ultimately affect task success rates. Jointly
> examining these metrics enables a more comprehensive understanding of training stability and failure modes. Figure 3
> reports success rate, off-policy KL divergence (between the new and old policies), KL loss (between the new and
> reference policies), gradient norm, and the valid-format ratio of rollout action tokens.
> 
> 
> As shown in Figure 3, CISPO and SAPO with tolerant clipping exhibit rapid initial performance gains, characterized by
> higher success rates, larger policy updates relative to the reference model, and faster format ratio adaptation compared to
> GRPO and GSPO. This behavior indicates more aggressive optimization that departs quickly from the reference policy
> and adapts rapidly to the task. A possible explanation is that tolerant clipping may preserve gradient contributions
> from tokens that deviate substantially from the current policy, resulting in overly exploratory updates. However, such
> aggressiveness leads to training instability, with collapse occurring around step 130. This collapse is marked by exploding
> gradient norms and KL divergence, accompanied by a sharp drop in the valid-format ratio, ultimately resulting in a
> severe degradation of success rate. In contrast, GSPO demonstrates a substantially more stable training pattern, with
> gradual performance improvement accompanied by steady KL divergence and gradient norms. These results indicate
> that sequence-level clipping is effective for stabilizing training, while overly tolerant clipping thresholds may yield
> short-term gains at the cost of long-term stability. Furthermore, IS design substantially impacts both performance and
> training stability in ARL, making it an important dimension in ARL system design.
> 
> 
> 7
> 
> 
> **Figure 4** _|_ Token-level and sequence-level IS analysis of SAPO and its sequence-masked variant SAPO `SM` . (a, b) Fraction
> of tokens with importance ratios outside the clipping range, decomposed into lower-bound (negative advantage) and
> upper-bound (positive advantage) portions. (c, d) Rollout groups partitioned by advantage sign, entropy level, and IS
> ratio magnitude, with KL divergence normalized for relative comparison.
> 
> 
> **Rooted cause of training collapse.** To investigate the root causes of training collapse along the IS dimension, we
> analyze token-level importance ratio statistics and stratify sequences by IS ratio, advantage, and entropy for SAPO
> and SAPO `SM`, where SAPO `SM` denotes a stabilized variant of SAPO introduced later. Figure 4 reports token-level and
> sequence-level IS ratio analysis. Subfigures (a) and (b) present the statistics of tokens whose importance sampling
> ratios fall outside the standard clipping range. Specifically, we report the proportion of out-of-bounds tokens and
> decompose it into lower- and upper-bound portions. The lower-bound portion corresponds to negative-advantage tokens
> with importance ratios below _ϵ_ low, while the upper-bound portion corresponds to positive-advantage tokens with ratios
> exceeding _ϵ_ high.
> 
> 
> As shown in Figure 4, During the collapse stage, SAPO exhibits a rapidly growing number of out-of-bounds tokens,
> predominantly from negative-advantage sequences with small importance ratios (the lower-bound portion) In contrast,
> for stable training runs, the portion of out-of-bounds tokens remains fairly low, and lower- and upper-bound ratio portions
> remain relatively balanced. This growing pattern and imbalance during collapse suggests that negative-advantage
> samples with low IS ratios are the main contributors the observed training instability.
> 
> 
> Beyond token-level analysis, we conduct a sequence-level comparison across training steps in Subfigures (c) and (d).
> Rollout samples are partitioned according to three factors: the sign of the advantage, whether the importance ratio
> is smaller or larger than one, and whether policy entropy falls below or exceeds a predefined threshold. This yields
> eight groups per training step. The vertical area denotes the normalized KL divergence between the current policy and
> the reference policy. A larger area therefore corresponds to a greater deviation from the reference policy, indicating
> a stronger contribution to policy shift during training. For collapsed experiments, the proportion of KL divergence
> attributed to sequences with negative advantages and low importance ratios increases abruptly, whereas for stable training
> this KL distribution remains relatively balanced across groups. Entropy is less impactful than advantage and IS ratio.
> This pattern further reinforces the conclusion that negative-advantage samples with low importance ratios are a primary
> source of training instability.
> 
> 
> **Stabilization Strategies for SAPO and CISPO.** We explore several strategies to stabilize SAPO and CISPO training,
> reported in Table 4. First, we consider increasing the KL coefficient to regularize optimization, and enlarging the
> mini-update batch size to mitigate off-policy effects. As shown in Table 4, increasing the KL coefficient overly constrains
> training and yields limited performance gains (full success-rate plots reported in Appendix C). Similarly, increasing the
> mini-update batch size degrades performance. Motivated by the IS-token analysis during training collapse, we adopt
> sequence masking following (Liu et al., 2025) to directly control negative samples that induce instability. Specifically,
> sequences with negative advantages and low importance ratios are masked (see Table 1 for the detailed formulation), a
> variant we denote as GRPO `SM` . We apply sequence masking to SAPO and CISPO, denoted as SAPO `SM` and CISPO `SM` .
> 
> 
> 8
> 
> 
> **Method** **Metric** **Original** **KL (0.05)** **Off-Policy (1024)** **Seq-Mask**
> 
> 
> 
> Score 2.16 1.60 0.98 **5.25**
> CISPO
> 
> Success 54.42 38.46 21.59 **78.88**
> 
> 
> Score 0.80 2.40 3.82 **4.88**
> SAPO
> 
> Success 25.16 48.05 64.30 **76.92**
> 
> 
> **Table 4** _|_ Effect of different stabilization strategies on CISPO and SAPO in ALFWorld. We evaluate three stabilization
> techniques applied to the tolerant-clipping methods CISPO and SAPO: increasing the KL penalty coefficient to 0.05,
> enlarging the off-policy mini-update batch size to 1024, and applying sequence-level masking (Seq-Mask).
> 
> 
> According to Figure 4 and Table 4, applying sequence masking improves the success rate from 54.12 to 78.88 for
> CISPO and from 25.16 to 76.92 for SAPO. SAPO `SM` and CISPO `SM` effectively stabilizes training, yielding success rates
> comparable to GSPO, along with steady KL divergence and gradient norms (Figures 3, 4).
> 
> 
> 
> **4.2** **Impact of Advantage Design on ARL**
> 
> 
> We study GIGPO and EMPG along the advantage-design dimension. GIGPO incorporates both global and local
> advantage information from the environment, enabling fine-grained advantage estimation, while EMPG reshapes
> advantages by incorporating uncertainty information from the training data.
> 
> 
> Table 3 shows that GIGPO generally outperforms GRPO, achieving an average score of 49.71 compared to 48.08, with a
> particularly strong improvement of 34.4% on ALFWorld. In addition, EMPG exhibits task-dependent performance,
> improving the success rate on WebShop by 11.5% while degrading performance on ALFWorld by 7.1%, resulting in an
> average score difference of 0.1 compared to GRPO. This suggests that fine-grained advantage design incorporating richer
> environmental information improves performance and alleviates reward sparsity in ARL, whereas advantage reshaping
> based on uncertainty signals has a smaller effect.
> 
> 
> **4.3** **Impact of Dynamic Filtering on ARL**
> 
> 
> Dynamic filtering is well known for delivering strong performance improvements on mathematical reasoning tasks (Xue
> et al., 2025; Yu et al., 2025a). However, we find that these gains do not always transfer to agentic reinforcement
> learning settings. As shown in Table 3, dynamic filtering improves performance more consistently when combined
> with GIGPO than with GRPO. This difference stems from how dynamic filtering interacts with format learning. In
> early training, many rollout groups fail entirely due to format errors, which amplifies the format penalty and produces
> strong implicit advantage signals for format correction. As a result, the model rapidly acquires correct formatting from
> early rollouts. Meanwhile, dynamic filtering removes such all-failure groups. For GRPO, whose advantage signals have
> limited diversity, filtering substantially reduces format-related learning signals, leading to unstable format behavior and
> limited gains. In contrast, GIGPO produces more diverse advantage signals, which stabilize format learning even after
> filtering, allowing DAPO `GIGPO` to achieve better and more stable performance. The detailed evidence supporting the
> above analyses is provided in Appendix G.
> 
> 
> 
> 
> 
> 9
> 
> 
> **ALFWorld** **Math**
> 
> 
> **Degree** **AIME** **AIME25**
> **Score** **Success**
> 
> **k@1** **k@32** **k@1** **k@32**
> 
> 
> Low 3.50 60.80 26.95 87.34 24.61 50.00
> 
> 
> Medium 3.83 58.38 24.22 75.00 17.97 48.59
> 
> 
> High 2.33 52.71 19.53 74.99 16.41 43.85
> 
> 
> **Table 5** _|_ Effect of off-policy staleness on ALFWorld and MATH. We vary the degree of off-policy staleness (Low,
> Medium, High) and report task score, success rate (ALFWorld), and pass@ _k_ accuracy (AIME, AIME25).
> 
> 
> **4.4** **Impact of Loss Aggregation on ARL**
> 
> 
> As shown in Table 3, sequence-mean-token-mean loss aggregation (GRPO `ST` ) degrades performance from 46.16 to 39.23
> relative to token-mean aggregation (GRPO). Although GRPO `ST` yields a 16.4% improvement on ALFWorld, it leads to a
> substantial decline on TIR-Math, with a 44.9% decrease on AIME. Notably, math rollouts exhibit higher variance in
> sequence length compared to other tasks, ranging from brief solutions to extended reasoning traces. These findings
> suggest that the unbalanced token weighting induced by sequence-level aggregation may negatively affect ARL training,
> particularly in tasks characterized by high length variability.
> 
> 
> **4.5** **Further Stability Considerations**
> 
> 
> **Exploration on Off-Policy Staleness.** Due to infrastructure and efficiency constraints, policy training is typically
> performed in batched rollouts, where groups of trajectories are generated and updated sequentially before proceeding to
> the next rollout stage. Off-policy effects arise because later updates within the same rollout stage use data from an earlier
> policy while the current policy has already evolved. Such off-policy mismatch is further amplified in multi-turn settings,
> where turn-wise decomposition increases the number of samples subject to staleness.
> 
> 
> **Experiment Setup and Results.** We control off-policy degree through rollout configuration while holding the update
> batch size fixed. For TIR Math, rollout batch sizes of 128, 512, and 1024 correspond to low, medium, and high off-policy
> degrees, respectively. For ALFWorld, we vary the off-policy degree by adjusting the number of groups per rollout to
> 8, 16, and 32. The effects of off-policy staleness are summarized in Table 5. TIR Math achieves higher performance
> under a low off-policy ratio (rollout batch size = 128), with 87.34% and 50.00% for avg@32, compared to 74.99%
> and 43.85% under a high off-policy ratio. Similarly, ALFWorld attains its highest success rate of 60.80% under low
> off-policy settings, which decreases to 52.71% under high off-policy settings. These results suggest that policy gradient
> optimization for agentic tasks exhibits sensitivity to the off-policy ratio.
> 
> ## **5 SAMPO**
> 
> 
> **5.1** **Motivation**
> 
> 
> _Can we derive a unified understanding of ARL training based on these insights?_ By systematically analyzing POs along
> orthogonal design dimensions in ARL, we identify key factors that determine training stability and optimization efficacy.
> At initialization, formatting errors and invalid action tokens induce severe optimization noise. We eliminate these failure
> modes through behavior cloning and explicit format correction, constraining learning to a valid behavioral manifold.
> Along the importance sampling dimension, sequence-level clipping, rather than token-wise constraints, is critical for
> long-horizon ARL. This mechanism addresses off-policy drift by suppressing harmful trajectories and yields substantial
> improvements in training stability. For advantage design, our analysis reveals that increasing advantage diversity across
> finer scales is essential to overcoming reward sparsity. Integrating global and local signals significantly enhances credit
> assignment. Finally, we show that dynamic trajectory filtering helps stabilize gradient updates by removing samples with
> degenerate advantages, leading to more informative and effective policy gradients.
> 
> 
> 10
> 
> 
> **5.2** **Our Method**
> 
> 
> Guided by this unified understanding, we propose SAMPO, a new PO paradigm built on these principles. SAMPO
> integrates sequence-level clipping, fine-grained advantage estimation, and dynamic filtering into a unified framework,
> yielding a stable and scalable solution for ARL. It is formulated as:
> 
> 
> 
> _Ti−_ 1
> 
> - min - _si_ ( _θ_ ) _A′i_ _[,]_ [clip] - _si_ ( _θ_ ) _,_ 1 _±ε_ - _A′i_ - _,_
> 
> _t_ =0
> 
> 
> 
> 1
> _L_ ( _θ_ ) =
> 
>   - _N_
> _i_ =1 _[T][i]_
> 
> 
> 
> _N_
> 
> 
> 
> _i_ =1
> 
> 
> 
> (8)
> 
> 
> 
> s.t. 0 _< |{y_ _|_ is_equivalent( _a, y_ ) _}| < G._
> 
> 
> Here, _A′i,k_ [=] _[A][i]_ [ +] _[ ω][ ·][ A]_ [step][(ˆ] _[y][i,k]_ [)][,] _[ s][i]_ [(] _[θ]_ [)] [=] [exp] - _|T_ 1 _i|_ - _|tT_ =0 _i|−_ 1 log _ππθ_ `old` _θ_ ( _y_ ( _ty|tx,y|x,y<t<t_ ) ) �. Across all evaluated agentic tasks,
> SAMPO consistently achieves the strongest overall performance shown in Table 1. Compared to methods that modify
> only one dimension, SAMPO demonstrates that combining multiple design dimensions is necessary for stable and
> effective ARL. Notably, SAMPO delivers particularly large improvements on long-horizon interactive tasks such as
> ALFWorld, highlighting the importance of sequence-aware control in agentic settings. These results validate our central
> claim that stable agentic PO method requires satisfying multiple necessary conditions simultaneously, rather than relying
> on isolated algorithmic modifications.
> 
> 
> **5.3** **Benchmarking against Inference Paradigms**
> 
> 
> To further contextualize the performance of SAMPO and evaluate whether a small open-source model trained with stable
> RL can compete with state-of-the-art inference strategies, we benchmark ARLArena against frontier closed-source
> models and complex multi-agent workflows. This comparison verifies a key hypothesis: principled RL training may
> offer greater gains in agentic tasks than heavy inference-time engineering on generic models.
> 
> 
> **Experiment Setup and Results.** We evaluate GPT-5.2 (OpenAI, 2025a), o3 (OpenAI, 2025b), and Gemini 2.5 Pro
> (Comanici et al., 2025) on ALFWorld and WebShop, under two paradigms: (i) Single LLM as Agent (SLA), following a
> standardized protocol; (ii) Multi-Agent System (MAS), with Debate and Aggressive Debate coordination strategies
> (details in Appendix F.5). Qwen3-4B-RFT post-trained with SAMPO achieves 92.72% all-task success on ALFWorld,
> outperforming GPT-5.2 (51.56%) and o3-based MAS (56.25%). Open-source models with SAMPO consistently exceed
> larger closed-source models, showing that scale and complex inference cannot replace stable, environment-aligned ARL
> training.
> 
> ## **6 Insights for Future Work**
> 
> 
> Based on our systematic dissection of policy gradient design choices in ARL, we identify several promising directions
> that merit deeper exploration.
> 
> 
> **(1) Clean training recipes are foundational for complex reasoning.** ARLArena reveals that ARL is extraordinarily
> sensitive to initialization and early-stage training dynamics. A carefully constructed clean setting, combining short
> supervised cold-start SFT, format-enforcing structural constraints, and conservative KL regularization, proves essential
> for unlocking stable multi-turn reasoning behaviors. Without such a controlled recipe, policy gradient signals are easily
> corrupted by malformed trajectories or premature collapse. This suggests that future research should treat training recipes
> not as auxiliary tricks, but as essential algorithmic components that define the feasible region in which sophisticated
> reasoning policies can emerge. Our codebase also provides detailed training recipes for reference.
> 
> 
> **(2) IS clipping is highly sensitive, while advantage design offers a comparatively stable gain.** Among the policy
> gradient dimensions we examine, IS clipping strategies exhibit high sensitivity: minor changes in clipping thresholds or
> ratio parameterization can drastically affect stability. In contrast, advantage design tends to provide more stable but
> relatively modest improvements across tasks. These observations indicate that IS clipping strategy represents a _**high-risk,**_
> _**high-reward**_ direction, whereas advantage design offers a more predictable but limited performance gains in ARL.
> 
> 
> 11
> 
> 
> **(3) Stable ARL unlocks long-horizon scaling opportunities.** Once training collapse is mitigated, we observe that
> agentic policies can sustain performance improvements over substantially more optimization steps without degradation.
> This stability opens the door to scaling both interaction horizon and environment size, analogous to scaling laws in
> supervised pretraining. Consequently, future progress in the field will increasingly depend on scaling environment
> diversity, interaction data volume, and multi-task curricula.
> 
> ## **7 Conclusion**
> 
> 
> This work systematically analyzes how policy gradient design choices impact training stability for agentic LLMs in
> multi-turn environments. ARLArena demonstrates that sequence-level clipping is critical for stability, while advantage
> design and dynamic filtering offer smaller but consistent gains, and loss aggregation has limited effect. Based on these
> insights, we introduce **SAMPO**, a unified policy optimization framework that achieves stable and effective agentic RL
> training. Overall, this study underscores the importance of principled policy design and reproducible evaluation for
> advancing ARL.
> 
> 
> 12
> 
> 
> ## **References**
> 
> Marwa Abdulhai, Isadora White, Charlie Snell, Charles Sun, Joey Hong, Yuexiang Zhai, Kelvin Xu, and Sergey Levine.
> Lmrl gym: Benchmarks for multi-turn reinforcement learning with language models. _arXiv preprint arXiv:2311.18232_,
> 2023.
> 
> 
> Aili Chen, Aonian Li, Bangwei Gong, Binyang Jiang, Bo Fei, Bo Yang, Boji Shan, Changqing Yu, Chao Wang,
> Cheng Zhu, et al. Minimax-m1: Scaling test-time compute efficiently with lightning attention. _arXiv_ _preprint_
> _arXiv:2506.13585_, 2025.
> 
> 
> Mingyue Cheng, Jie Ouyang, Shuo Yu, Ruiran Yan, Yucong Luo, Zirui Liu, Daoyu Wang, Qi Liu, and Enhong Chen.
> Agent-r1: Training powerful llm agents with end-to-end reinforcement learning. _arXiv preprint arXiv:2511.14460_,
> 2025.
> 
> 
> Gheorghe Comanici, Eric Bieber, Mike Schaekermann, Ice Pasupat, Noveen Sachdeva, Inderjit Dhillon, Marcel Blistein,
> Ori Ram, Dan Zhang, Evan Rosen, and et al. Gemini 2.5: Pushing the frontier with advanced reasoning, multimodality,
> long context, and next generation agentic capabilities, 2025.
> 
> 
> Lang Feng, Zhenghai Xue, Tingcong Liu, and Bo An. Group-in-group policy optimization for llm agent training. _arXiv_
> _preprint arXiv:2505.10978_, 2025.
> 
> 
> Chang Gao, Chujie Zheng, Xiong-Hui Chen, Kai Dang, Shixuan Liu, Bowen Yu, An Yang, Shuai Bai, Jingren Zhou, and
> Junyang Lin. Soft adaptive policy optimization. _arXiv preprint arXiv:2511.20347_, 2025.
> 
> 
> Xinyan Guan, Jiali Zeng, Fandong Meng, Chunlei Xin, Yaojie Lu, Hongyu Lin, Xianpei Han, Le Sun, and Jie Zhou.
> Deeprag: Thinking to retrieve step by step for large language models, 2025.
> 
> 
> Daya Guo, Dejian Yang, Haowei Zhang, Junxiao Song, Peiyi Wang, Qihao Zhu, Runxin Xu, Ruoyu Zhang, Shirong
> Ma, Xiao Bi, et al. Deepseek-r1 incentivizes reasoning in llms through reinforcement learning. _Nature_, 645(8081):
> 633–638, 2025.
> 
> 
> Aaron Jaech, Adam Kalai, Adam Lerer, Adam Richardson, Ahmed El-Kishky, Aiden Low, Alec Helyar, Aleksander
> Madry, Alex Beutel, Alex Carney, et al. Openai o1 system card. _arXiv preprint arXiv:2412.16720_, 2024.
> 
> 
> Dongfu Jiang, Yi Lu, Zhuofeng Li, Zhiheng Lyu, Ping Nie, Haozhe Wang, Alex Su, Hui Chen, Kai Zou, Chao Du, et al.
> Verltool: Towards holistic agentic reinforcement learning with tool use. _arXiv preprint arXiv:2509.01055_, 2025.
> 
> 
> Bowen Jin, Hansi Zeng, Zhenrui Yue, Jinsung Yoon, Sercan Arik, Dong Wang, Hamed Zamani, and Jiawei Han. Search-r1:
> Training llms to reason and leverage search engines with reinforcement learning. _arXiv preprint arXiv:2503.09516_,
> 2025.
> 
> 
> Devvrit Khatri, Lovish Madaan, Rishabh Tiwari, Rachit Bansal, Sai Surya Duvvuri, Manzil Zaheer, Inderjit S Dhillon,
> David Brandfonbrener, and Rishabh Agarwal. The art of scaling reinforcement learning compute for llms. _arXiv_
> _preprint arXiv:2510.13786_, 2025.
> 
> 
> Minghao Li, Yingxiu Zhao, Bowen Yu, Feifan Song, Hangyu Li, Haiyang Yu, Zhoujun Li, Fei Huang, and Yongbin
> Li. Api-bank: A comprehensive benchmark for tool-augmented llms. In _Proceedings of the 2023 Conference on_
> _Empirical Methods in Natural Language Processing_, pages 3102–3116, 2023.
> 
> 
> Aixin Liu, Aoxue Mei, Bangcai Lin, Bing Xue, Bingxuan Wang, Bingzheng Xu, Bochao Wu, Bowei Zhang, Chaofan
> Lin, Chen Dong, et al. Deepseek-v3. 2: Pushing the frontier of open large language models. _arXiv_ _preprint_
> _arXiv:2512.02556_, 2025.
> 
> 
> Yinyi Luo, Yiqiao Jin, Weichen Yu, Mengqi Zhang, Srijan Kumar, Xiaoxiao Li, Weijie Xu, Xin Chen, and Jindong
> Wang. Agentark: Distilling multi-agent intelligence into a single llm agent. _arXiv preprint arXiv:2602.03955_, 2026.
> 
> 
> OpenAI. Introducing GPT-5.2, December 2025a. Accessed: 2026-01-28.
> 
> 
> OpenAI. Introducing openai o3 and o4-mini, April 2025b. Accessed: 2026-01-28.
> 
> 
> Long Ouyang, Jeffrey Wu, Xu Jiang, Diogo Almeida, Carroll Wainwright, Pamela Mishkin, Chong Zhang, Sandhini
> Agarwal, Katarina Slama, Alex Ray, et al. Training language models to follow instructions with human feedback.
> _Advances in neural information processing systems_, 35:27730–27744, 2022.
> 
> 
> 13
> 
> 
> Feng Peiyuan, Yichen He, Guanhua Huang, Yuan Lin, Hanchong Zhang, Yuchen Zhang, and Hang Li. Agile: A novel
> reinforcement learning framework of llm agents. _Advances in Neural Information Processing Systems_, 37:5244–5284,
> 2024.
> 
> 
> Aske Plaat, Max van Duijn, Niki van Stein, Mike Preuss, Peter van der Putten, and Kees Joost Batenburg. Agentic large
> language models, a survey. _arXiv preprint arXiv:2503.23037_, 2025.
> 
> 
> Timo Schick, Jane Dwivedi-Yu, Roberto Dessì, Roberta Raileanu, Maria Lomeli, Luke Zettlemoyer, and Nicola Cancedda.
> Language models can teach themselves to use tools. _arXiv preprint_, 2023. arXiv:2302.04761.
> 
> 
> Max-Philipp B. Schrader. gym-sokoban. `[https://github.com/mpSchrader/gym-sokoban](https://github.com/mpSchrader/gym-sokoban)`, 2018.
> 
> 
> John Schulman. Approximating kl divergence. `[http://joschu.net/blog/kl-approx.html](http://joschu.net/blog/kl-approx.html)`, 2017. Blog post.
> 
> 
> John Schulman, Filip Wolski, Prafulla Dhariwal, Alec Radford, and Oleg Klimov. Proximal policy optimization algorithms.
> In _Proceedings of the International Conference on Learning Representations (ICLR)_, 2017. arXiv:1707.06347.
> 
> 
> Y. Sheng et al. Hybridflow: A flexible and efficient rlhf training framework with a 3d-hybridengine. _arXiv preprint_,
> 2024.
> 
> 
> Mohit Shridhar, Xingdi Yuan, Marc-Alexandre Côté, Yonatan Bisk, Adam Trischler, and Matthew Hausknecht. Alfworld:
> Aligning text and embodied environments for interactive learning. _arXiv preprint arXiv:2010.03768_, 2020.
> 
> 
> Guanzhi Wang, Yuqi Xie, Yunfan Jiang, Ajay Mandlekar, Chaowei Xiao, Yuke Zhu, Linxi Fan, and Anima Anandkumar.
> Voyager: An open-ended embodied agent with large language models. _arXiv preprint_, 2023. arXiv:2305.16291.
> 
> 
> Jiawei Wang, Jiacai Liu, Yuqian Fu, Yingru Li, Xintao Wang, Yuan Lin, Yu Yue, Lin Zhang, Yang Wang, and
> Ke Wang. Harnessing uncertainty: Entropy-modulated policy gradients for long-horizon llm agents. _arXiv preprint_
> _arXiv:2509.09265_, 2025a.
> 
> 
> Zihan Wang, Kangrui Wang, Qineng Wang, Pingyue Zhang, Linjie Li, Zhengyuan Yang, Xing Jin, Kefan Yu, Minh Nhat
> Nguyen, Licheng Liu, et al. Ragen: Understanding self-evolution in llm agents via multi-turn reinforcement learning.
> _arXiv preprint arXiv:2504.20073_, 2025b.
> 
> 
> Tianxin Wei, Ting-Wei Li, Zhining Liu, Xuying Ning, Ze Yang, Jiaru Zou, Zhichen Zeng, Ruizhong Qiu, Xiao Lin,
> Dongqi Fu, et al. Agentic reasoning for large language models. _arXiv preprint arXiv:2601.12538_, 2026.
> 
> 
> Zhiheng Xi, Yiwen Ding, Wenxiang Chen, Boyang Hong, Honglin Guo, Junzhe Wang, Dingwen Yang, Chenyang Liao,
> Xin Guo, Wei He, Songyang Gao, Lu Chen, Rui Zheng, Yicheng Zou, Tao Gui, Qi Zhang, Xipeng Qiu, Xuanjing
> Huang, Zuxuan Wu, and Yu-Gang Jiang. Agentgym: Evolving large language model-based agents across diverse
> environments, 2024.
> 
> 
> Zhiheng Xi, Jixuan Huang, Chenyang Liao, Baodai Huang, Honglin Guo, Jiaqi Liu, Rui Zheng, Junjie Ye, Jiazheng
> Zhang, Wenxiang Chen, et al. Agentgym-rl: Training llm agents for long-horizon decision making through multi-turn
> reinforcement learning. _arXiv preprint arXiv:2509.08755_, 2025.
> 
> 
> Hanchen Xia, Baoyou Chen, Zelin Zang, Yutang Ge, Guojiang Zhao, and Siyu Zhu. Latent poincaré shaping for agentic
> reinforcement learning, 2026.
> 
> 
> Yutao Xie, Nathaniel Thomas, Nicklas Hansen, Yang Fu, Erran Li Li, and Xiaolong Wang. Tips: Turn-level informationpotential reward shaping for search-augmented llms. In _International Conference on Learning Representations (ICLR)_,
> 2026.
> 
> 
> Tianshi Xu, Yuteng Chen, and Meng Li. Cleaner: Self-purified trajectories boost agentic reinforcement learning. _arXiv_
> _preprint arXiv:2601.15141_, 2026.
> 
> 
> Zhipeng Xu, Zhongyu Zhang, and Zhen Zhang. Deepseek-r1: Incentivizing reasoning capability in LLMs via
> reinforcement learning. _arXiv preprint arXiv:2501.12948_, 2025.
> 
> 
> Zhenghai Xue, Longtao Zheng, Qian Liu, Yingru Li, Xiaosen Zheng, Zejun Ma, and Bo An. Simpletir: End-to-end
> reinforcement learning for multi-turn tool-integrated reasoning. _arXiv preprint arXiv:2509.02479_, 2025.
> 
> 
> An Yang, Anfeng Li, Baosong Yang, Beichen Zhang, Binyuan Hui, Bo Zheng, Bowen Yu, Chang Gao, Chengen Huang,
> Chenxu Lv, et al. Qwen3 technical report. _arXiv preprint arXiv:2505.09388_, 2025.
> 
> 
> 14
> 
> 
> Shunyu Yao, Howard Chen, John Yang, and Karthik Narasimhan. Webshop: Towards scalable real-world web interaction
> with grounded language agents. _Advances in Neural Information Processing Systems_, 35:20744–20757, 2022.
> 
> 
> Shunyu Yao, Jeffrey Zhao, Dian Yu, Nan Du, Izhak Shafran, Karthik Narasimhan, and Yuan Cao. ReAct: Synergizing
> reasoning and acting in language models. In _International Conference on Learning Representations (ICLR)_, 2023.
> arXiv:2210.03629.
> 
> 
> Qiying Yu, Zheng Zhang, Ruofei Zhu, Yufeng Yuan, Xiaochen Zuo, Yu Yue, Weinan Dai, Tiantian Fan, Gaohong Liu,
> and Lingjun Liu. Dapo: An open-source llm reinforcement learning system at scale. _arXiv preprint arXiv:2503.14476_,
> 2025a.
> 
> 
> Qiying Yu, Zheng Zhang, Ruofei Zhu, Yufeng Yuan, Xiaochen Zuo, Yu Yue, Weinan Dai, Tiantian Fan, Gaohong Liu,
> Lingjun Liu, et al. Dapo: An open-source llm reinforcement learning system at scale. _arXiv preprint arXiv:2503.14476_,
> 2025b.
> 
> 
> Zhaochen Yu, Ling Yang, Jiaru Zou, Shuicheng Yan, and Mengdi Wang. Demystifying reinforcement learning in agentic
> reasoning. _arXiv preprint arXiv:2510.11701_, 2025c.
> 
> 
> Weihao Zeng, Yuzhen Huang, Qian Liu, Wei Liu, Keqing He, Zejun Ma, and Junxian He. Simplerl-zoo: Investigating
> and taming zero reinforcement learning for open base models in the wild. _arXiv preprint arXiv:2503.18892_, 2025.
> 
> 
> Hanchen Zhang, Xiao Liu, Bowen Lv, Xueqiao Sun, Bohao Jing, Iat Long Iong, Zhenyu Hou, Zehan Qi, Hanyu Lai,
> Yifan Xu, et al. Agentrl: Scaling agentic reinforcement learning with a multi-turn, multi-task framework. _arXiv_
> _preprint arXiv:2510.04206_, 2025.
> 
> 
> Chujie Zheng, Shixuan Liu, Mingze Li, Xiong-Hui Chen, Bowen Yu, Chang Gao, Kai Dang, Yuqiong Liu, Rui Men,
> An Yang, et al. Group sequence policy optimization. _arXiv preprint arXiv:2507.18071_, 2025.
> 
> 
> Shuyan Zhou, Frank F. Xu, Hao Zhu, Xuhui Zhou, Robert Lo, Abishek Sridhar, Xianyi Cheng, Tianyue Ou, Yonatan
> Bisk, Daniel Fried, Uri Alon, and Graham Neubig. Webarena: A realistic web environment for building autonomous
> agents, 2024.
> 
> 
> Yifei Zhou, Song Jiang, Yuandong Tian, Jason Weston, Sergey Levine, Sainbayar Sukhbaatar, and Xian Li. Sweet-rl:
> Training multi-turn llm agents on collaborative reasoning tasks. _arXiv preprint arXiv:2503.15478_, 2025.
> 
> 
> 15
> 
> 
> ## **Supplementary Materials for ARLArena**
> 
> **A** **More Details on Research Dimension** **17**
> 
> 
> A.1 Loss Aggregation . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 17
> 
> 
> A.2 Importance Sampling Clipping . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 18
> 
> 
> A.3 Advantage Design . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 19
> 
> 
> **B** **Key Hyper-parameter** **21**
> 
> 
> **C** **Additional Experiment Result** **21**
> 
> 
> C.1 Performance on 8B Model . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 21
> 
> 
> C.2 Additional Analysis Result . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 21
> 
> 
> C.3 Task Environment Details . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 23
> 
> 
> **D** **Related Work** **23**
> 
> 
> **E** **Another Roadmap of Building Agentic LLM: Multi-agent System** **24**
> 
> 
> E.1 Debate . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 24
> 
> 
> E.2 Aggressive Debate . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 24
> 
> 
> E.3 Experiment Results on SLA and MAS . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 25
> 
> 
> **F** **Failure Analysis** **25**
> 
> 
> F.1 Method: Sankey Graphs for Action-Transition Flows . . . . . . . . . . . . . . . . . . . . . . . . . . 25
> 
> 
> F.2 WebShop: Action-Transition Patterns and Failure Modes . . . . . . . . . . . . . . . . . . . . . . . . 25
> 
> 
> F.3 WebShop: How RL Post-training Changes Behaviors . . . . . . . . . . . . . . . . . . . . . . . . . . 27
> 
> 
> F.4 ALFWorld: Action-Transition Patterns . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 28
> 
> 
> F.5 Implications . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 28
> 
> 
> **G** **Visualization** **29**
> 
> 
> G.1 Evidence of Format v.s. Dynamic Filtering . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 29
> 
> 
> **H** **Case Study** **29**
> 
> 
> H.1 Prompt Templates . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 29
> 
> 
> H.2 Multi-turn State-Action Templates . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . 32
> 
> 
> 16
> 
> 
> ## **A More Details on Research Dimension**
> 
> **A.1** **Loss Aggregation**
> 
> 
> As discussed in Section 2.2, the policy gradient objective for agentic LLMs is implemented through a batch-level loss
> aggregation over token-level surrogate losses. For a batch of _N_ sampled trajectories _{yi}_ _[N]_ _i_ =1 [, where trajectory] _[ i]_ [ has]
> length _Ti_, we define the token-level loss as
> 
> 
> _ℓi,t_ ( _θ_ ) := min( _wi,t_ ( _θ_ ) _Ai,_ clip( _wi,t_ ( _θ_ ) _,_ 1 _−_ _ε,_ 1 + _ε_ ) _Ai_ ) _,_ (S1)
> 
> 
> where _wi,t_ ( _θ_ ) = _πθ_ ( _yi,t_ _|_ _xi, yi,<t_ ) _/πθ_ `old` ( _yi,t_ _|_ _xi, yi,<t_ ) and _Ai_ denotes the (sequence-level) advantage associated
> with trajectory _yi_ .
> 
> 
> Different loss aggregation strategies correspond to different empirical estimators of the expectation over trajectories and
> tokens. Below we summarize several commonly used schemes.
> 
> 
> **Token-mean.** The token-mean estimator averages the loss uniformly over all unmasked tokens in the batch:
> 
> 
> 
> _Ti−_ 1
> 
> - _ℓi,t_ ( _θ_ ) _._ (S2)
> 
> 
> _t_ =0
> 
> 
> 
> 1
> _L_ token-mean( _θ_ ) = - _N_
> _i_ =1 _[T][i]_
> 
> 
> 
> _N_
> 
> 
> 
> _i_ =1
> 
> 
> 
> This scheme assigns equal weight to each token across the entire batch and is invariant to trajectory length at the sequence
> level. Token-mean has been adopted in several recent works (e.g., DAPO) as a means of stabilizing optimization.
> However, because trajectories with longer responses contribute more tokens, they implicitly receive larger total weight,
> which may bias optimization toward long trajectories.
> 
> 
> **Sequence-mean token-mean (Seq-mean-token-mean).** This estimator first averages over tokens within each trajectory
> and then averages across trajectories:
> 
> 
> 
> 1
> _L_ seq-mean-token-mean( _θ_ ) =
> _N_
> 
> 
> 
> _N_
> 
> 
> 
> _i_ =1
> 
> 
> 
> 1
> _Ti_
> 
> 
> 
> _Ti−_ 1
> 
> - _ℓi,t_ ( _θ_ ) _._ (S3)
> 
> 
> _t_ =0
> 
> 
> 
> Under this scheme, each trajectory contributes equally regardless of its length. Equivalently, each token is weighted by
> 1 _/Ti_ . As a result, shorter trajectories assign larger per-token weight, while longer trajectories are relatively down-weighted.
> This behavior can introduce response-level length bias, rewarding short correct trajectories more strongly and penalizing
> long incorrect trajectories less.
> 
> 
> 
> **Sequence-mean token-sum (Seq-mean-token-sum).** An alternative aggregation removes the per-trajectory normalization over tokens:
> 
> 
> 
> _Ti−_ 1
> 
> 
> 
> 
> 1
> _L_ seq-mean-token-sum( _θ_ ) =
> _N_
> 
> 
> 
> _N_
> 
> 
> 
> _i_ =1
> 
> 
> 
> _ℓi,t_ ( _θ_ ) _._ (S4)
> 
> _t_ =0
> 
> 
> 
> This formulation corresponds to maximizing the expected cumulative surrogate objective over full trajectories. Compared
> to Seq-mean-token-mean, longer trajectories receive proportionally larger weight.
> 
> 
> **Sequence-mean token-sum with length normalization (Seq-mean-token-sum-norm).** In practice, some implementations normalize by a fixed maximum generation length _T_ max:
> 
> 
> 
> _Ti−_ 1
> 
> - _ℓi,t_ ( _θ_ ) _._ (S5)
> 
> 
> _t_ =0
> 
> 
> 
> 1
> _L_ seq-mean-token-sum-norm( _θ_ ) =
> _NT_ max
> 
> 
> 
> _N_
> 
> 
> 
> _i_ =1
> 
> 
> 
> This estimator enforces a uniform upper bound on the contribution of each trajectory and assigns equal weight to tokens
> across batches under a fixed-length budget.
> 
> 
> 17
> 
> 
> **Discussion.** These aggregation schemes differ primarily in how they trade off trajectory-level fairness, token-level
> weighting, and variance control. Seq-mean-token-mean and token-mean are the two most commonly used estimators
> in practice and are the focus of our empirical analysis in Section 4.4. The remaining variants are included here for
> completeness and to clarify their implicit inductive biases in agentic reinforcement learning.
> 
> 
> **A.2** **Importance Sampling Clipping**
> 
> 
> As discussed in Section 2.2, importance sampling (IS) clipping plays a central role in stabilizing off-policy policy
> optimization. While all methods considered in this work rely on the same token-level importance ratio
> 
> 
> _πθ_ ( _yi,t_ _| xi, yi,<t_ )
> _wi,t_ ( _θ_ ) = (S6)
> _πθ_ `old` ( _yi,t_ _| xi, yi,<t_ ) _[,]_
> 
> 
> they differ substantially in _where_ and _how_ clipping is applied. Below we summarize the clipping mechanisms of GRPO,
> CISPO, SAPO, and GSPO.
> 
> 
> **A.2.1** **GRPO**
> 
> 
> Group Relative Policy Optimization (GRPO) adopts the standard PPO-style hard clipping applied independently at each
> token:
> _ℓ_ [GRPO] _i,t_ ( _θ_ ) = min( _wi,t_ ( _θ_ ) _Ai,_ clip( _wi,t_ ( _θ_ ) _,_ 1 _−_ _ε,_ 1 + _ε_ ) _Ai_ ) _._ (S7)
> 
> 
> Clipping is performed directly on the token-level importance ratio. When _wi,t_ falls outside the clipping range, the
> gradient contribution of that token is truncated.
> 
> 
> **A.2.2** **CISPO**
> 
> 
> Clipped Importance Sampling Policy Optimization (CISPO) modifies GRPO by clipping the importance ratio itself
> rather than the surrogate objective. Specifically, the clipped ratio is defined as
> 
> 
> 
> _w_ ˜ _i,t_ ( _θ_ ) =
> 
> 
> 
> 
> 1 + _ε,_ _wi,t_ ( _θ_ ) _>_ 1 + _ε,_
> (S8)
> _wi,t_ ( _θ_ ) _,_ otherwise _,_
> 
> 
> 
> and is treated as a stop-gradient quantity. The resulting loss takes the form
> 
> 
> _ℓ_ [CISPO] _i,t_ ( _θ_ ) = sg( ˜ _wi,t_ ( _θ_ )) _Ai_ log _πθ_ ( _yi,t_ _| xi, yi,<t_ ) _,_ (S9)
> 
> 
> where sg( _·_ ) denotes the stop-gradient operator. By avoiding hard truncation of token updates, CISPO preserves gradient
> flow for clipped tokens while still bounding their influence. However, clipping remains token-local and does not explicitly
> enforce sequence-level coherence.
> 
> 
> **A.2.3** **SAPO**
> 
> 
> Soft Adaptive Policy Optimization (SAPO) replaces hard clipping with a smooth, temperature-controlled gating function.
> The surrogate loss is defined as
> _ℓ_ [SAPO] _i,t_ ( _θ_ ) = _fi,t_ ( _wi,t_ ( _θ_ )) _Ai,_ (S10)
> 
> 
> 
> where
> 
> 
> 
> _fi,t_ ( _x_ ) = _σ_ - _τi,t_ ( _x −_ 1)� _·_ [4] _,_ _τi,t_ =
> _τi,t_
> 
> 
> 
> 
> _τ_ pos _,_ _Ai_ _>_ 0 _,_
> (S11)
> _τ_ neg _,_ _Ai_ _<_ 0 _._
> 
> 
> 
> Here _σ_ ( _·_ ) denotes the sigmoid function. SAPO implements a continuous trust region: near on-policy updates are
> preserved, while off-policy updates are smoothly attenuated rather than abruptly clipped. The asymmetric temperature
> design further suppresses high-variance negative-advantage updates. Despite improved smoothness, SAPO remains a
> token-level method and does not explicitly prevent a few extreme tokens from destabilizing a full trajectory.
> 
> 
> 18
> 
> 
> **A.2.4** **GSPO**
> 
> 
> Group Sequence Policy Optimization (GSPO) fundamentally changes the unit of clipping by operating at the sequence
> level. The sequence-level importance ratio is defined as
> 
> 
> 
> _Ti−_ 1
> 
> 
> 
> 
> log _wi,t_ ( _θ_ )
> 
> _t_ =0
> 
> 
> 
> 
> 
> 
> 
> 
>  - _πθ_ ( _yi_ _| xi_ )
> =
> _πθ_ `old` ( _yi_ _| xi_ )
> 
> 
> 
> �1 _/Ti_
> _._ (S12)
> 
> 
> 
> _si_ ( _θ_ ) = exp
> 
> 
> 
> 
> 1
> _Ti_
> 
> 
> 
> Clipping is then applied once per sequence:
> 
> 
> _ℓ_ [GSPO] _i_ ( _θ_ ) = min( _si_ ( _θ_ ) _Ai,_ clip( _si_ ( _θ_ ) _,_ 1 _−_ _ε,_ 1 + _ε_ ) _Ai_ ) _._ (S13)
> 
> 
> All tokens within a trajectory share the same clipped update. This design aligns the unit of importance sampling with the
> unit of reward and enforces strong sequence-level coherence. As a result, GSPO effectively suppresses high-variance
> token outliers and yields substantially more stable optimization in long-horizon agentic reinforcement learning.
> 
> 
> **Summary.** In summary, GRPO, CISPO, and SAPO apply clipping at the token level with increasing degrees of
> smoothness, whereas GSPO performs clipping at the sequence level. Our empirical results in Section 4.1 demonstrate
> that sequence-level clipping is a key factor for stabilizing multi-turn agentic RL training.
> 
> 
> **A.3** **Advantage Design**
> 
> 
> This section provides detailed formulations of the advantage designs introduced in Section 2.2, including Group-in-Group
> Policy Optimization (GiGPO) and Entropy-Modulated Policy Gradients (EMPG). Both methods extend standard
> group-based advantage estimation to better handle long-horizon agentic reinforcement learning.
> 
> 
> **Notation.** We consider a batch of _N_ trajectories _{τi}_ _[N]_ _i_ =1 [, where each trajectory] _[ τ][i]_ [=] _[ {]_ [(] _[s][i,k][, a][i,k][, r][i,k]_ [)] _[}][K]_ _k_ =1 _[i]_ [is generated]
> under the behavior policy _πθ_ `old` . The total return of a trajectory is denoted by
> 
> 
> 
> _R_ ( _τi_ ) =
> 
> 
> **A.3.1** **Group-in-Group Policy Optimization (GiGPO)**
> 
> 
> 
> _Ti_
> 
> - _ri,k._ (S14)
> 
> 
> _t_ =1
> 
> 
> 
> GiGPO introduces a hierarchical advantage structure that combines trajectory-level and step-level relative advantages.
> The design preserves the critic-free and group-based nature of GRPO while enabling finer-grained credit assignment.
> 
> 
> **Episode-level** **relative** **advantage.** GiGPO first computes a trajectory-level (episode-level) relative advantage by
> normalizing total returns within the rollout group:
> 
> 
>                            - _{R_ ( _τj_ ) _}_ _[N]_ _j_ =1�
> _Ai_ = _[R]_ [(] _[τ][i]_ _F_ [)] _[ −]_ norm [mean]                 - _{R_ ( _τj_ ) _}_ _[N]_ _j_ =1� _,_ (S15)
> 
> 
> where _F_ norm( _·_ ) is a normalization factor. In the original formulation, _F_ norm may be chosen as the standard deviation or
> a fixed constant.
> 
> 
> 19
> 
> 
> **Step-level relative advantage via anchor state grouping.** To assign fine-grained credit within a trajectory, GiGPO
> constructs step-level groups based on repeated environment states. Let _U_ denote the set of distinct environment states
> appearing in the trajectory batch. For each anchor state ˜ _s ∈U_, a step-level group is defined as
> 
> 
> _GS_ (˜ _s_ ) = �� _ai,k, Ri,k_ ��� _si,k_ = _s_ ˜� _,_ (S16)
> 
> 
> where _Ri,k_ denotes the discounted return from step _k_ reward:
> 
> 
> 
> _Ri,k_ =
> 
> 
> 
> _Ti_
> 
> - _γ_ _[m][−][t]_ _ri,m._ (S17)
> 
> 
> _m_ = _t_
> 
> 
> 
> Within each step-level group, GiGPO computes a relative advantage for individual actions:
> 
> 
> _[|]_ [ (] _[a][j,k][′][, R][j,k][′]_ [)] _[ ∈G][S]_ [(˜] _[s]_ [)] _[}]_ [)]
> _A_ step(ˆ _yi,k_ ) = _[R][i,k][ −]_ [mean (] _[{][R][j,k][′]_ _._ (S18)
> 
> _F_ norm ( _{Rj,k′_ _|_ ( _aj,k′, Rj,k′_ ) _∈GS_ (˜ _s_ ) _}_ )
> 
> 
> **Combined advantage.** The final advantage used for policy optimization is a linear combination of episode-level and
> step-level components:
> _′_
> _Ai,k_ [=] _[ A][i]_ [+] _[ ω A]_ [step][(] _[y][i,k]_ [)] _[,]_ (S19)
> 
> 
> where _ω_ _≥_ 0 is a weighting coefficient controlling the contribution of step-level credit.
> 
> 
> **A.3.2** **Entropy-Modulated Policy Gradients (EMPG)**
> 
> 
> Entropy-Modulated Policy Gradients (EMPG) augments the advantage function by incorporating step-wise uncertainty
> measured via policy entropy. The method reshapes the learning signal at each decision step while preserving a
> trajectory-level optimization objective, making it suitable for long-horizon agentic reinforcement learning.
> 
> 
> **Step-level** **entropy.** For a trajectory _τi_ and its _t_ -th step, EMPG defines a step-level entropy _Hi,t_ as the average
> token-level entropy over the tokens generated at that step:
> 
> 
> 
> 
> - _πθ_ ( _v_ _| yi,t,<j_ ) log _πθ_ ( _v_ _| yi,t,<j_ ) _,_ (S20)
> 
> 
> _v∈V_
> 
> 
> 
> 1
> _Hi,t_ = _−_ _|yi,t|_
> 
> 
> 
> _|yi,t|_
> 
> 
> 
> _j_ =1
> 
> 
> 
> where _|yi,t|_ is the number of tokens in step _t_, _yi,t,<j_ denotes the prefix before token _j_ within that step, and _V_ is the
> vocabulary.
> 
> 
> **Entropy-modulated advantage.** Let _A_ ( _τi_ ) denote the trajectory-level advantage (e.g., computed via group-based
> normalization as described in Section 2.2). EMPG defines a step-wise modulated advantage as
> 
> 
> _A_ mod( _i, t_ ) = _g_ ( _Hi,t_ ) _A_ ( _τi_ ) + _ζ f_ ( _Hi,t_ +1) _,_ (S21)
> 
> 
> where _g_ ( _·_ ) is a self-calibrating scaling function based on current-step entropy, _f_ ( _·_ ) is a future-clarity bonus depending
> on the next step, and _ζ_ _≥_ 0 controls the contribution of the future-clarity term.
> 
> 
> **Self-calibrating gradient scaling.** The scaling function _g_ ( _·_ ) reweights the trajectory-level advantage according to the
> relative entropy of each step within a batch:
> 
> 
> 
> 
>        -        exp _−k_ _H_ [˜] _i,t_
> _g_ ( _Hi,t_ ) =
> 
> 
> 
> _,_ (S22)
> _j_ 1 _[T][j]_ - _j,t_ _[′]_ [ exp] - _−k_ _H_ [˜] _j,t_ _[′]_ 
> 
> 
> 1
> 
> 
> 
> 
> where _H_ [˜] _i,t_ denotes a batch-normalized entropy value, _Tj_ is the length of trajectory _τj_, and _k_ _>_ 0 is a temperature
> parameter. This normalization ensures that the average scaling factor over the batch equals one.
> 
> 
> 20
> 
> 
> **Future clarity bonus.** To encourage transitions toward lower-uncertainty future states, EMPG introduces a future-clarity
> bonus defined as
> _f_ ( _Hi,t_ +1) = exp� _−k_ _[′]_ _H_ [˜] _i,t_ +1� _,_ (S23)
> 
> 
> where _k_ _[′]_ _>_ 0 controls sensitivity to the entropy of the next step.
> 
> 
> **Final advantage normalization.** After computing _A_ mod( _i, t_ ) for all steps in the batch, EMPG applies a final batch-level
> normalization (e.g., zero-mean normalization) before using the resulting advantages in policy gradient updates.
> 
> ## **B Key Hyper-parameter**
> 
> 
> The hyperparameters reported in Table S1 are determined through task-specific grid search. For each policy optimization
> method and environment, we sweep over the method-relevant hyperparameters while keeping the remaining training and
> optimization settings fixed. The final configurations correspond to the stable settings selected from the grid search.
> 
> ## **C Additional Experiment Result**
> 
> 
> **C.1** **Performance on 8B Model**
> 
> 
> To further investigate the scalability of our findings, we evaluate the 8B parameter model (Qwen3-8B) on AlfWorld,
> which serves as a representative benchmark for complex, multi-turn agentic tasks. Given the substantial computational
> requirements for large-scale RL training, we focus on this environment to verify if the core design principles distilled
> from the 4B models remain consistent at a larger scale.
> 
> 
> As shown in Table S2, the experimental results on AlfWorld demonstrate that the relative performance gains and stability
> trends are highly consistent with our observations in the 4B experiments Section 4. Specifically, the critical importance
> of sequence-level clipping is reaffirmed: even with increased model capacity, it remains the indispensable factor for
> preventing training collapse. Furthermore, we observe that the benefits of advantage design and dynamic filtering
> persist at this larger scale, providing consistent but incremental improvements to final performance. In contrast, the
> choice of loss aggregation continues to exhibit limited impact, echoing our findings on 4B models. These results
> collectively suggest that the hierarchical impact of policy design choices—and the resulting SAMPO recipe—is robust
> and scale-invariant, effectively leveraging the enhanced reasoning capabilities of larger models while maintaining stable
> training dynamics.
> 
> 
> **C.2** **Additional Analysis Result**
> 
> 
> **Figure S1** _|_ Sequence-Level IS Analysis of CISPO and CISPO `SM` (CISPO with sequence masking) on ALFWorld.
> 
> 
> We further visualize the training dynamics of CISPO and CISPO `SM` on the AlfWorld task using diagrams. Specifically,
> following the same setup as in the main text, we categorize trajectories according to three factors: the sign of the
> advantage, whether the entropy exceeds a predefined threshold, and whether the IS ratio is greater than zero. These
> criteria partition the samples into eight groups, which we use to analyze how the KL divergence evolves during training.
> 
> 
> 21
> 
> 
> **Table S1** _|_ Key training hyperparameters for agentic RL experiments across four tasks (ALFWorld, WebShop, Sokoban,
> TIR Math). “–” indicates the method is not applicable to that task.
> 
> 
> **Category** **ALFWorld** **WebShop** **Sokoban** **TIR Math**
> 
> 
> _Model and Environment Configuration_
> 
> 
> Base model Qwen3-4B-RFT Qwen3-4B-RFT Qwen3-4B-VL-Instruct-RFT Qwen3-4B-Base
> 
> 
> Max interaction steps 50 15 15 5
> 
> 
> Memory context window 2 (turns) 2 (turns) 2 (turns) 8196 (tokens)
> 
> 
> Group rollout size 8 8 8 5
> 
> 
> Max prompt length 2048 4096 1024 8196
> 
> 
> Max response length 512 512 512 4096
> 
> 
> Format penalty coefficient 0.1 0.1 0.1 0.1
> 
> 
> _Training Optimization_
> 
> 
> Group normalization mode mean_std_norm mean_std_norm mean_std_norm mean_std_norm
> 
> Learning rate 1 _×_ 10 _[−]_ [6] 1 _×_ 10 _[−]_ [6] 1 _×_ 10 _[−]_ [6] 1 _×_ 10 _[−]_ [6]
> 
> 
> Mini-batch size 256 128 64 128
> 
> 
> KL coefficient 0.01 0.01 0.01 0
> 
> 
> _Rollout and Inference Configuration_
> 
> 
> Rollout engine vLLM vLLM vLLM vLLM
> 
> 
> Temperature (training) 1.0 1.0 1.0 1.0
> 
> 
> Temperature (validation) 0.6 0.6 0.7 0.6
> 
> 
> Top- _p_ (validation) 0.95 0.95 0.95 0.95
> 
> 
> Top- _k_ (validation) 20 20 20 20
> 
> 
> _Training and Batching_
> 
> 
> User Prompt Number 16 16 32 512
> 
> 
> Validation batch size 128 128 128 128
> 
> 
> Total epochs 200( _∼_ 24h) 200( _∼_ 22h) 200( _∼_ 12h) 30( _∼_ 80h)
> 
> 
> GPUs NVIDIA H200/B200 NVIDIA H200/B200 NVIDIA H200/B200 NVIDIA H200/B200
> 
> 
> _PO-specific Parameters_
> 
> 
> _ε_ high 0.2 0.2 0.2 0.28
> GRPO
> 
> _ε_ low 0.2 0.2 0.2 0.2
> 
> 
> _ε_ 0.2 0.2 0.2      
> 
> 
> GIGPO
> 
> 
> EMPG
> 
> 
> 
> _γ_ 0.95 0.95 0.95 
> 
> _ω_ 1 1 1 
> 
> _ε_ 0.2 0.2 0.2 
> _k, k_ _[′]_ 1.0 1.0 1.0 
> 
> _ζ_ 0.05 0.05 0.05 
> 
> 
> _ε_ high 4e-3 4e-2 4e-3 4e-3
> GSPO
> 
> _ε_ low 3e-3 3e-2 3e-3 3e-3
> 
> 
> 
> _ε_ high 0.2 0.2 0.2 0.28
> CISPO
> 
> _ε_ low 1 1 1 1
> 
> 
> 
> _τ_ pos 1.0 1.0 1.0 1.0
> SAPO
> 
> _τ_ neg 1.05 1.05 1.05 1.05
> 
> 
> 
> DAPO
> 
> 
> 
> _ε_ high 0.2 0.2 0.2 0.28
> 
> 
> _ε_ low 0.2 0.2 0.2 0.2
> 
> 
> _N_ oversample 3 3 3 2
> 
> 
> 22
> 
> 
> **ALFWorld**
> **Dimension** **Method**
> 
> Score Success
> 
> 
> Base GRPO 2.37 50.92
> 
> 
> Loss Agg GRPO `ST` 1.68 _↓_ 29.1% 49.31 _↓_ 3.2%
> 
> 
> SAPO 0.08 _↓_ 96.6% 1.93 _↓_ 96.21%
> 
> 
> 
> Importance
> Sampling
> 
> 
> Advantage
> Design
> 
> 
> Dynamic
> Sampling
> 
> 
> 
> CISPO 0.80 _↓_ 66.2% 30.83 _↓_ 39.5%
> 
> 
> GSPO 5.05 _↑_ 113.1% 79.70 _↑_ 56.5%
> 
> 
> GIGPO 4.10 _↑_ 73.0% 80.03 _↑_ 57.2%
> 
> 
> EMPG 4.51 _↑_ 90.3% 71.48 _↑_ 40.4%
> 
> 
> DAPO `GRPO` 0.81 _↓_ 65.8% 38.11 _↓_ 25.16%
> 
> 
> DAPO `GIGPO` 2.49 _↑_ 5.1% 60.27 _↑_ 18.4%
> 
> 
> 
> **Ours** **SAMPO** **8.98** _↑_ 278.9% **97.71** _↑_ 91.9%
> 
> 
> **Table S2** _|_ Performance on **Qwen3-8B** for **ALFWorld** . The overall trend on the 8B variant remains consistent, and
> SAMPO continues to achieve the best performance, indicating stable gains under model scaling.
> 
> 
> Consistent with our earlier findings, we clearly observe that after CISPO collapses, trajectories with negative advantages
> and low IS ratios (i.e., adv _<_ 0 and IS _<_ 1) rapidly dominate the distribution. This imbalance correlates strongly with
> the surge in KL divergence and subsequent training instability.
> 
> 
> This observation also explains why CISPO `SM`, which incorporates sequence-level masking, achieves substantially
> improved stability: by masking these harmful negative-advantage and low-ratio trajectories, the optimization process
> avoids pathological updates and maintains more balanced gradient signals.
> 
> 
> **C.3** **Task Environment Details**
> 
> 
> **ALFWorld** **(Shridhar** **et** **al.,** **2020)** : It provides a text-based interactive setting in which LLM agents are required
> to complete goal-driven tasks that involve reasoning over multiple sequential decisions. The environment focuses on
> everyday household activities and evaluates an agent’s ability to plan and act through iterative interaction.
> 
> 
> **WebShop** **(Yao** **et** **al.,** **2022)** : It is a large-scale interactive environment that places agents in realistic e-commerce
> scenarios, requiring them to interpret user instructions and make sequential decisions to identify and purchase suitable
> products.
> 
> 
> **Sokoban (Schrader, 2018)** : It is a classic grid-based planning task where an agent navigates a 2D environment to push
> all boxes onto designated target cells. The state is represented visually, and the agent selects from discrete movement
> actions
> 
> 
> **TIR Math (Xue et al., 2025)** : This task focuses on standard mathematical question answering, where Python is used
> as a tool for intermediate calculations and symbolic reasoning. The overall pipeline follows Xue et al. (2025). The
> training data are adapted from SimpleRL (Zeng et al., 2025), and evaluation is conducted on the AIME and AIME25
> benchmarks. Performance is measured using avg@k, following the evaluation protocol in Yu et al. (2025b).
> 
> ## **D Related Work**
> 
> 
> Large language models have demonstrated strong capabilities in agent-based environments and attracted increasing
> attention (Li et al., 2023; Shridhar et al., 2020; Yao et al., 2022). Prior studies investigate LLMs as agents in
> multi-turn, action-based environments, emphasizing long-horizon memory and explicit tool use for sequential decision
> making and reasoning (Schick et al., 2023; Wang et al., 2023; Yao et al., 2023). Recently, driven by the success of
> reinforcement learning in reasoning (Khatri et al., 2025; OpenAI, 2025a; Xu et al., 2025), RL has been extended to agentic
> settings (Abdulhai et al., 2023; Jin et al., 2025; Plaat et al., 2025; Yu et al., 2025c). Several representative RL frameworks
> 
> 
> 23
> 
> 
> for LLM agents have emerged. AGILE (Peiyuan et al., 2024) proposes a framework for LLM-driven conversational
> agents capable of planning, tool use, and expert consultation. SWEET-RL (Zhou et al., 2025) studies collaborative LLM
> agents that interact with simulated human partners in ColBench, where agents ask clarifying questions and learn from
> multi-turn feedback. Agent-R1 (Cheng et al., 2025) extends this paradigm to external tool-based environments and
> enables multi-turn reasoning with tool calls. Similarly, AgentGym-RL (Xi et al., 2025) presents an RL framework
> for autonomous LLM agents that supports multi-turn interactions, modular architectures, and real-world scenarios.
> AgentRL (Zhang et al., 2025) develops a multi-turn, multi-task RL system and demonstrates superior performance
> relative to closed-source models. VerlTool (Jiang et al., 2025) focuses on tool-using LLM agents and aligns well with the
> VeRL codebase. Most prior work provides limited analysis of agentic RL training instability. In contrast, ARLArena
> offers a unified training and analysis framework for examining how policy-gradient design choices relate to stability and
> performance across agentic tasks.
> 
> ## **E Another Roadmap of Building Agentic LLM: Multi-agent System**
> 
> 
> **E.1** **Debate**
> 
> 
> Let A = _{A_ 1 _, A_ 2 _, . . ., AN_ _}_ denote the set of _N_ agents, where _N_ is an odd integer to prevent tie-breaking scenarios
> during majority voting. Let _x_ denote the task prompt. In the initial round ( _t_ = 0), each agent _Ai_ independently generates
> a candidate solution _c_ [(0)] _i_ based solely on the prompt _x_ :
> 
> 
> _c_ [(0)] _i_ = _Ai_ ( _x_ ) _,_ _∀i ∈{_ 1 _, . . ., N_ _}_ (S24)
> 
> 
> Let _C_ [(] _[t]_ [)] = _{c_ [(] 1 _[t]_ [)] _[, c]_ 2 [(] _[t]_ [)] _[, . . ., c]_ _N_ [(] _[t]_ [)] _[}]_ [ be the set of candidate solutions at round] _[ t]_ [.] [We define a majority consensus function]
> _M_ ( _·_ ) that returns the solution _y_ if it appears in more than half of the agent responses:
> 
> 
> 
> _y_ = _M_ ( _C_ [(] _[t]_ [)] ) =
> 
> 
> 
> 
> - _c_ ˆ if �� _{c ∈C_ ( _t_ ) : _c_ = ˆ _c}_ �� _>_ _N_ 2 (S25)
> _∅_ otherwise
> 
> 
> 
> If _M_ ( _C_ [(0)] ) = _∅_, the process terminates and outputs _y_ . Otherwise, the system enters the debate phase. The process
> iterates through debate rounds _t_ = 1 _,_ 2 _, . . ., Tmax_ . For each round, we construct the debate prompt for each agent,
> which includes the original prompt _x_, the set of unique candidate solutions from the previous round Unique( _C_ [(] _[t][−]_ [1)] ),
> and agents’ reasoning in previous round _R_ [(] _[t][−]_ [1)] . Let _R_ [(] _[t]_ [)] = _{r_ 1 [(] _[t]_ [)] _[, r]_ 2 [(] _[t]_ [)] _[, . . ., r]_ _N_ [(] _[t]_ [)] _[}]_ [ be the agents’ reasoning at round] _[ t]_ [,]
> and _R_ [(0)] = _∅_ .
> 
> 
>                  _ri_ [(] _[t]_ [)] _[, c]_ _i_ [(] _[t]_ [)] = _Ai_ _x,_ Unique( _C_ [(] _[t][−]_ [1)] ) _, R_ [(] _[t][−]_ [1)][�] _._ (S26)
> 
> 
> At the end of each round _t_, we check for consensus again and output the solution _y_ if consensus is reached. This
> mechanism enables agents to either rectify perceived flaws by proposing a new solution or align with a peer by voting for
> an existing candidate. The debate terminates when a majority consensus is achieved, _M_ ( _C_ [(] _[t]_ [)] ) _̸_ = _∅_ . If the maximum
> iteration limit _Tmax_ is reached without consensus, the final output _y_ is randomly sampled from the final set of candidates
> _C_ [(] _[T][max]_ [)] .
> 
> 
> **E.2** **Aggressive Debate**
> 
> 
> We extend the Debate framework discussed above to build a decisively goal-oriented variant designed to prioritize task
> completion over exhaustive exploration. While the standard framework seeks consensus on an optimal solution, the
> aggressive variant compels agents to accept partial success by securing the best available option within a strict finite
> horizon.
> 
> 
> Formally, we modify the agent _Ai_ by conditioning it on an additional constraint set _Iagg_ . Unlike standard debate agents
> that aim for a perfect solution, the aggressive agent _Ai_ ( _·|Iagg_ ) operates under a modified utility function characterized
> by several governing principles: **(1) Bounded Exploration:** The agent must finalize the interaction within a finite
> horizon. This constraint suppresses excessive exploration and ensures the agent commits to a definitive outcome rather
> than prolonging the information-gathering phase; **(2) Temporal Efficiency:** The agent is encouraged to conclude the
> interaction as early as possible; **(3) Incentive Awareness:** The agent is explicitly informed that partial rewards are
> 
> 
> 24
> 
> 
> available. This awareness incentivizes the agent to accept high-utility suboptimal outcomes when a perfect solution is
> unattainable; **(4) Pragmatic Optimization:** The agent prioritizes securing a result that maximizes available partial
> rewards rather than seeking a theoretical global optimum, thereby avoiding diminishing returns associated with perfecting
> the solution in complex environments.
> 
> 
> **E.3** **Experiment Results on SLA and MAS**
> 
> 
> 
> 
> 
> 
> 
> GPT-4o 61.11 33.33 36.36 50.00 45.45 63.64 50.00 13.60 12.50
> 
> 
> GPT-5.2 70.03 66.07 35.37 62.30 52.08 37.36 51.56 26.56 26.56
> 
> 
> Debate 67.74 64.28 33.33 60.00 52.38 65.00 56.25 22.65 34.65
> 
> 
> Aggressive Debate       -       -       -       -       -       -       - 28.51 61.53
> 
> 
> Gemini-2.5-pro 84.97 61.61 63.94 22.22 62.50 75.25 66.41       -       
> 
> GRPO 87.41 62.65 46.42 72.28 58.89 38.37 72.61 75.32 57.71
> 
> 
> SAPO 34.49 32.19 24.13 24.92 16.21 9.37 25.16 73.85 52.10
> 
> 
> CISPO 76.03 37.12 58.56 50.97 57.88 23.68 54.42 67.96 54.71
> 
> 
> GSPO 90.36 79.31 90.71 75.45 77.95 48.95 78.61 85.29 72.48
> 
> 
> GIGPO 94.80 83.03 86.37 81.15 75.38 59.21 81.09 67.76 56.55
> 
> 
> EMPG 84.18 61.53 69.83 72.49 46.51 0.04 57.91 79.16 64.32
> 
> 
> DAPO `GRPO` 81.28 37.57 53.97 40.16 51.28 6.43 49.58 62.43 46.17
> 
> 
> DAPO `GIGPO` 85.04 55.26 65.35 58.98 56.52 26.57 60.55 88.10 76.82
> 
> 
> **SAMPO** **96.30** **88.49** **93.65** **92.42** **92.70** **88.35** **92.72** **88.04** **74.08**
> 
> 
> **Table S3** _|_ Unified comparison across ALFWorld (six task types + overall) and WebShop (score and success rate). The
> upper block reports closed-source baselines and multi-agent strategies; the lower block reports policy optimization
> methods trained with Qwen3-4B.
> 
> ## **F Failure Analysis**
> 
> 
> **F.1** **Method:** **Sankey Graphs for Action-Transition Flows**
> 
> 
> We analyze agent rollouts by visualizing step-wise action transitions with Sankey graphs. Each column corresponds
> to a time step, node height indicates the empirical frequency of an action at that step, and edges represent transitions
> between consecutive steps. Compared with action histograms, Sankey graphs preserve temporal structure and thus reveal
> loop-like behaviors (e.g., repetitive pagination or oscillation between two actions) that dominate long-horizon failures.
> 
> 
> **F.2** **WebShop:** **Action-Transition Patterns and Failure Modes**
> 
> 
> **Overall flow (API agent).** The API agent is a single-agent baseline powered by GPT-4o via API under the same
> interaction protocol, without any task-specific training. Figure S2 summarizes WebShop trajectories of the API agent,
> where green links correspond to successful episodes and red links correspond to failures. A large fraction of failures is
> characterized by repetitive `next` actions, suggesting exploration inefficiency where the agent keeps paginating without
> making progress toward constraint satisfaction.
> 
> 
> 25
> 
> 
> **Figure S2** _|_ WebShop action-transition Sankey for the API agent. Green flows denote successful trajectories and red
> flows denote failures.
> 
> 
> **Failure-only flow with action coloring.** Figure S3 focuses on failed trajectories and colors nodes by action type. Two
> dominant failure patterns are observed: (i) **Pagination loops** : long runs of `next` (and occasional `search` ) that rarely
> transition into `click_product` (product-detail inspection); (ii) **Backtracking oscillation** : frequent alternation between
> `click_product` and `back`, suggesting repeated revisits to previously viewed product pages and limited progress toward
> constraint satisfaction. Notably, our API agent is provided with a long interaction history (past actions and observations)
> in the prompt, so this pattern is unlikely to be explained by insufficient context alone. Instead, it may reflect limited
> _effective_ memory usage: without structured tracking or summarization of verified attributes and visited items, the agent
> may fail to retrieve previously established evidence from a long, unstructured context and thus re-check similar products.
> We emphasize that this is only one plausible factor; we find instruction ambiguity or conflicting constraints may also
> contribute.
> 
> 
> **Figure S3** _|_ WebShop failure-only action-transition Sankey for the API agent. Nodes are colored by action type (e.g.,
> `search`, `click_product`, `click_other`, `buy`, `back`, `next` ).
> 
> 
> 26
> 
> 
> **F.3** **WebShop:** **How RL Post-training Changes Behaviors**
> 
> 
> **Overall flow (RL-optimized agent).** Figure S4 shows the same visualization for our RL-optimized agent (post-trained
> with RL). Compared with the API baseline, the RL agent exhibits fewer `next` -dominated failure paths and a higher
> proportion of trajectories that transition into `click_product` and eventually attempt `buy`, consistent with more targeted
> product inspection and earlier decision making.
> 
> 
> **Figure S4** _|_ WebShop action-transition Sankey for the RL-optimized agent. Green flows denote successful trajectories
> and red flows denote failures.
> 
> 
> **Remaining failure modes after RL post-training.** Figure S5 focuses on failed RL trajectories. While `next` -heavy
> pagination loops become less prominent, two residual issues remain: (i) **Backtracking-heavy browsing** : repeated
> `click_other` / `back` transitions, suggesting inefficient navigation; (ii) **Premature purchase** : occasional `buy` attempts
> that do not satisfy all constraints, suggesting incomplete constraint tracking.
> 
> 
> **Figure S5** _|_ WebShop failure-only action-transition Sankey for the RL-optimized agent. Nodes are colored by action
> type (e.g., `search`, `click_product`, `click_other`, `buy`, `back`, `next` ).
> 
> 
> 27
> 
> 
> **Figure S6** _|_ ALFWorld action-transition Sankey diagrams for the API agent. Top: Success (green) vs. failure (red)
> trajectories. Bottom: Failure trajectories with nodes colored by action type.
> 
> 
> **F.4** **ALFWorld:** **Action-Transition Patterns**
> 
> 
> Figure S6 visualizes ALFWorld rollouts. Navigation actions (e.g., `go`, `look` ) dominate early steps across episodes,
> whereas successful trajectories more often transition into object-centric interactions (e.g., `examine`, `open/close`, `take`,
> `use` ) and explicit state-checking ( `inventory` ). In contrast, failed trajectories frequently exhibit prolonged navigation
> with comparatively fewer object interactions, which may reflect weak progression toward concrete object-level subgoals
> and imperfect tracking of what has already been tried or collected over long horizons.
> 
> 
> **F.5** **Implications**
> 
> 
> Our analysis suggests two actionable directions: (1) **Loop-aware control** (e.g., detecting repeated `next` or `click_product`
> _↔_ `back` cycles and triggering a plan change); (2) **Explicit constraint/state memory** (e.g., introducing a lightweight
> memory agent that maintains a concise record of visited items and verified constraints, and feeds the acting agent
> with short summaries or retrieval results). Together, these mechanisms may further improve robustness beyond RL
> post-training.
> 
> 
> 28
> 
> 
> ## **G Visualization**
> 
> **G.1** **Evidence of Format v.s.** **Dynamic Filtering**
> 
> 
> To support the analysis in Section 4.4, we report the format validity ratio during training for different policy optimization
> variants. The results illustrate that DAPO combined with GIGPO maintains more stable format behavior than
> DAPO+GRPO after dynamic filtering.
> 
> 
> AlfWorld WebShop
> 
> 
> **Figure** **S7** _|_ Format validity ratio during training on AlfWorld and WebShop for GRPO, GIGPO, DAPO `GRPO`, and
> DAPO `GIGPO` . Applying dynamic filtering to GRPO leads to degraded format stability, whereas DAPO `GIGPO` maintains
> stable format behavior across training.
> 
> ## **H Case Study**
> 
> 
> **H.1** **Prompt Templates**
> 
> 
> **H.1.1** **TIR Math**
> 
> 
> 
> 29
> 
> 
> **H.1.2** **WebShop**
> 
> 
> 
> 
> 
> 
> 
> **H.1.3** **ALFWorld**
> 
> 
> 
> 
> 
> 
> 
> 30
> 
> 
> **H.1.4** **Sokoban**
> 
> 
> 
> 
> 
> 
> 
> 31
> 
> 
> **H.2** **Multi-turn State-Action Templates**
> 
> 
> **H.2.1** **TIR Math**
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> 
> **H.2.2** **WebShop**
> 
> 
> 
> 
> 
> 
> 
> 32
> 
> 
> **H.2.3** **Alfworld**
> 
> 
> 
> 
> 
> 
> 
> 33
> 
> 
> **H.2.4** **Sokoban**
> 
> 
> 
> 
> 
> 
> 
> 34
> 
> 
> 35
> 
> 
> 
>
> [Source: ARLArena paper](https://arxiv.org/pdf/2602.21534)
