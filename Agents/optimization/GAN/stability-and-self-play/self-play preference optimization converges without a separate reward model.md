---
created: 2026-03-22
description: Self-play against a previous policy iteration, using multiplicative weight updates to approximate Nash equilibrium, aligns LLMs without requiring a separate reward model or pairwise loss.
source: https://arxiv.org/abs/2405.00675
type: paper
---

## Key Takeaways

SPPO reframes RLHF as a two-player constant-sum game where the goal is to find a Nash equilibrium policy rather than maximize a scalar reward. The key insight is that human preferences are often intransitive and irrational, so the Bradley-Terry model underlying methods like DPO is fundamentally misspecified. By working directly with pairwise preference probabilities, SPPO sidesteps this limitation entirely. This connects directly to the game-theoretic framing seen in [[self-play fine-tuning converts weak language models to strong language models]], though SPPO operates on preferences rather than on matching a target data distribution.

The algorithmic core is an exponential weight update derived from the multiplicative weights method of Freund and Schapire. At each iteration, the policy generates responses, a preference model scores them against the current policy's distribution, and a new policy is trained to match its log-probability ratio to the estimated win rate. Crucially, SPPO avoids the pairwise loss design of DPO and IPO by directly regressing on individual response win rates. This means the loss function pushes up the likelihood of high-win-rate responses and pushes down low-win-rate ones independently, rather than only adjusting relative likelihoods within a pair. The authors show this has a deep connection to policy gradient theory and implicitly learns a token-level value function.

A striking practical result is that SPPO achieves state-of-the-art performance on AlpacaEval 2.0 using only a 0.4B parameter preference model (PairRM) and 60k prompts, without any GPT-4 supervision for responses or preferences. This is remarkable because it demonstrates that the adversarial self-play dynamic can substitute for the expensive external signal that most alignment pipelines rely on. The convergence guarantee (O(1/sqrt(T)) duality gap) provides theoretical backing that iterative DPO lacks.

The relationship to GAN-style training is structural: the policy plays the role of a generator trying to produce responses that win against the previous version of itself, while the preference model acts as a fixed discriminator. Unlike GANs, however, the discriminator is not co-trained, which likely contributes to the stability of the procedure. This is a different stability mechanism than the one in [[curiosity-driven red teaming achieves higher coverage by rewarding novelty over pure effectiveness]], where the adversarial dynamic is between an attacker and a target model. In SPPO, both players are the same model across iterations.

The method also avoids the performance decay problem seen in iterative DPO/IPO. When those methods are optimized toward PairRM scores, they tend to improve on the target metric but degrade on other benchmarks. SPPO's consistent gains across AlpacaEval, MT-Bench, Arena-Hard, and the Open LLM Leaderboard suggest that the Nash equilibrium framing provides a more robust optimization landscape. This connects to the curriculum calibration concerns in [[PAIRED]] and [[PLR]], where regret-based objectives similarly aim to avoid narrow overfitting.

From the perspective of adversarial agent optimization more broadly, SPPO demonstrates that self-play can be a viable alternative to the generator-discriminator co-training of GANs, achieving stability through the multiplicative weights framework rather than through careful architectural balancing. The preference model serves as a stable anchor, and the self-play iterations refine the policy without the mode collapse risks typical of GAN training. This is complementary to the approach in [[Prover-Verifier Games]], where the adversarial dynamic is between a prover and verifier rather than between policy iterations.

## External Resources

- [SPPO Code](https://github.com/uclaml/SPPO) — official implementation

## Original Content

> [!quote]- Full Paper Text
> # Self-Play Preference Optimization for Language Model Alignment
> 
> Yue Wu [∗†] Zhiqing Sun [∗‡] Huizhuo Yuan [∗§] Kaixuan Ji [¶] Yiming Yang [‖] Quanquan Gu [∗∗]
> 
> 
> **Abstract**
> 
> 
> Standard reinforcement learning from human feedback (RLHF) approaches relying on parametric models like the Bradley-Terry model fall short in capturing the intransitivity and irrationality in
> human preferences. Recent advancements suggest that directly working with preference probabilities can yield a more accurate reflection of human preferences, enabling more flexible and accurate
> language model alignment. In this paper, we propose a self-play-based method for language model
> alignment, which treats the problem as a constant-sum two-player game aimed at identifying
> the Nash equilibrium policy. Our approach, dubbed _Self-Play_ _Preference_ _Optimization_ (SPPO),
> utilizes iterative policy updates to provably approximate the Nash equilibrium. Additionally,
> we propose a new SPPO objective which is both strongly motivated by theory and is simple
> and effective in practice. In our experiments, using only 60k prompts (without responses) from
> the UltraFeedback dataset and without any prompt augmentation, by leveraging a pre-trained
> preference model PairRM with only 0.4B parameters, SPPO can obtain a model from fine-tuning
> Mistral-7B-Instruct-v0.2 that achieves the state-of-the-art length-controlled win-rate of 28.53%
> against GPT-4-Turbo on AlpacaEval 2.0. It also outperforms the (iterative) DPO and IPO on
> MT-Bench, Arena-Hard, and the Open LLM Leaderboard. Starting from a stronger base model
> Llama-3-8B-Instruct, we are able to achieve a length-controlled win rate of 38.77%. Notably, the
> strong performance of SPPO is achieved without additional external supervision (e.g., responses,
> preferences, etc.) from GPT-4 or other stronger language models. Codes are available at
> `[https://github.com/uclaml/SPPO](https://github.com/uclaml/SPPO)` .
> 
> ### **1 Introduction**
> 
> 
> Large Language Models (LLMs) (e.g., Ouyang et al., 2022; OpenAI et al., 2023), have shown
> remarkable capabilities in producing human-like text, fielding questions, and coding. Despite
> 
> 
> ∗Equal contribution
> †Department of Computer Science, University of California, Los Angeles, Los Angeles, CA 90095; e-mail:
> 
> ```
> ywu@cs.ucla.edu
> ```
> 
> ‡Language Technologies Institute, Carnegie Mellon University, Pittsburgh, PA 15213; e-mail: `zhiqings@cs.cmu.edu`
> §Department of Computer Science, University of California, Los Angeles, Los Angeles, CA 90095; e-mail:
> 
> ```
> hzyuan@cs.ucla.edu
> ```
> 
> ¶Department of Computer Science, University of California, Los Angeles, Los Angeles, CA 90095; e-mail:
> 
> ```
> kauxuanji@cs.ucla.edu
> ```
> 
> ‖Language Technologies Institute & Machine Learning Department, Carnegie Mellon University, Pittsburgh, PA
> 15213; e-mail: `yiming@cs.cmu.edu`
> ∗∗Department of Computer Science, University of California, Los Angeles, Los Angeles, CA 90095; e-mail:
> 
> ```
> qgu@cs.ucla.edu
> 
> ```
> 
> 1
> 
> 
> their advancements, these models encounter challenges in tasks requiring high levels of reliability,
> safety, and ethical alignment. To address these challenges, Reinforcement Learning from Human
> Feedback (RLHF), also known as Preference-based Reinforcement Learning (PbRL), presents a
> promising solution. This framework for policy optimization, highlighted in works by Christiano et al.
> (2017) and recently in Ouyang et al. (2022), has led to significant empirical success in fine-tuning
> instruction-following LLMs, making them more aligned with human preferences and thus more
> helpful.
> Most existing approaches to RLHF rely on either explicit or implicit reward models. Taking
> InstructGPT (Ouyang et al., 2022) as an example, a reference policy _π_ ref is first established,
> typically from supervised pre-training or instruction-based (supervised) fine-tuning. An explicit
> reward function is obtained by training a reward model based on human preference feedback data,
> employing the Bradley-Terry (BT) model (Bradley and Terry, 1952). Subsequently, reinforcement
> learning algorithms such as Proximal Policy Optimization (Schulman et al., 2017, PPO) are used to
> fine-tune the reference LLM _π_ ref by maximizing the expected reward function. The reward model
> provides a “reward score” _r_ ( **y** ; **x** ) for the given response **y** and prompt **x**, approximately reflecting how
> humans value these responses. More recently, methods like Direct Preference Optimization (Rafailov
> et al., 2024b, DPO) have been introduced. These methods forgo the training of a separate reward
> model but still fundamentally adhere to the reward maximization objective and are determined by
> parametric models such as the BT model.
> These models presuppose a monotonous and transitive relationship among preferences for
> different choices. However, empirical evidence suggests otherwise. For instance, Tversky (1969)
> observed human decisions can be influenced by different factors and exhibit inconsistency. Such
> observations indicate that human preferences do not always adhere to a single, value-based hierarchy
> and can even appear irrational, such as exhibiting loops in preference relations. For LLMs, another
> motivating evidence is that Munos et al. (2023) has empirically shown that directly predicting the
> pairwise preference can achieve higher accuracy than predicting the preference via a BT-based
> reward model.
> To address the inconsistency in human preference, researchers have proposed to work directly
> with the preference probability and design algorithms that can more flexibly represent human
> preferences (Lou et al., 2022; Wu et al., 2023) in the ranking or bandit setting. Recently, an
> emerging line of work (Wang et al., 2024; Munos et al., 2023; Swamy et al., 2024) also proposed to
> study RLHF for LLMs under such general preference P( **y** _≻_ **y** _[′]_ _|_ **x** ), where **y** and **y** _[′]_ are two different
> responses and **x** is prompt. The goal is to identify the Nash equilibrium or von Neumann winner of
> the two-player constant-sum game
> 
> 
>                       ( _π_ _[∗]_ _, π_ _[∗]_ ) = arg max _π_ min _π_ _[′]_ [E] **[x]** _[∼X]_ E **y** _∼π_ ( _·|_ **x** ) _,_ **y** _′∼π′_ ( _·|_ **x** )�P( **y** _≻_ **y** _[′]_ _|_ **x** )� [�] _,_
> 
> 
> where each player is an LLM that outputs responses and aims to maximize its probability of being
> preferred over its opponent.
> Independent from our work, Swamy et al. (2024) proposed Self-play Preference Optimization
> (SPO) [1] for the same (unregularized) two-player constant-sum game. They provide a general reduction
> of preference optimization to no-regret online learning for the multi-step Markov Decision Process.
> When constrained to the bandit setting for LLMs, their proposed algorithmic framework reduces to
> 
> 
> 1The SPO framework does not pertain to the efficient fine-tuning of LLMs. Our Self-Play Preference Optimization
> (SPPO) focuses on LLM alignment and was developed independently. To distinguish it from the SPO framework, we
> use the abbreviation SPPO.
> 
> 
> 2
> 
> 
> the famous Hedge algorithm (Freund and Schapire, 1997), which admits the exponential update
> rule as described in (4.1). To approximately solve the exponential update, Swamy et al. (2024) then
> proposed to employ typical policy optimization algorithms such as Proximal Policy Optimization
> (PPO) (Schulman et al., 2017) or Soft Actor-Critic (SAC) (Haarnoja et al., 2018) to maximize the
> win rate against the reference policy and evaluated the performance of their self-play algorithms
> in robotic and game tasks. However, it typically requires more effort to apply PPO or SAC to
> large-scale fine-tuning of LLM and make them work stably. Therefore, it remains unclear how their
> self-play framework can be applied to large-scale language model alignment efficiently.
> In this paper, motivated by these developments mentioned above, we propose a new self-play
> algorithm that (1) enjoys provable guarantees to solve the two-player constant-sum game; and (2)
> can scale up to large-scale efficient fine-tuning of large language models. In detail, we formulate
> the RLHF problem as a constant-sum two-player game. Our objective is to identify the Nash
> equilibrium policy, which consistently provides preferred responses over any other policy on average.
> To identify the Nash equilibrium policy approximately, we adopt the classic online adaptive algorithm
> with multiplicative weights (Freund and Schapire, 1999) as a high-level framework that solves the
> two-player game. Further, each step of the high-level framework can be approximated by a _self-play_
> mechanism, where in each round the policy is playing against itself in the previous round by
> fine-tuning it on synthetic data that are generated by the policy and annotated by the preference
> model.
> Our contributions are highlighted as follows:
> 
> 
> - Starting from the exponential weight update algorithm which provably converges to the Nash equilibrium of the two-player constant-sum game, we propose the _Self-Play_ _Preference_ _Optimization_
> (SPPO) algorithm for large language model alignment. The algorithm converges to an approximate
> Nash equilibrium provably and admits a simple form of loss function for easy optimization.
> 
> 
> - Unlike the symmetric pairwise loss such as DPO and Identity Preference Optimization (IPO) (Azar
> et al., 2023), we propose a new optimization objective that does not rely on pairwise comparisons.
> The new loss objective (4.4), initially driven by game-theoretical concepts, turns out strongly
> motivated by the policy gradient theory and implicitly encourages the LLM to learn a token-level
> optimal value function.
> 
> 
> - Empirically, SPPO significantly enhances the well-aligned Mistral-7B-Instruct-v0.2 and Llama-38B-Instruct model, achieving an increase of over 11% on the length-controlled win rate against
> GPT-4-Turbo on the AlpacaEval 2.0 (Dubois et al., 2024a) test set. Additionally, SPPO exhibits
> strong generalist abilities across different tasks, including MT-Bench, the Open LLM Leaderboard,
> and the more recent, more challenging benchmark, Arena-Hard. Unlike iterative DPO/IPO, which
> tends to show performance decay on other benchmarks when optimized towards the PairRM
> score, SPPO’s performance gain is consistent. Notably, all the strong performances are achieved
> without external supervision (e.g., responses, preferences, etc.) from GPT-4 or other stronger
> language models.
> 
> 
> Concurrent to our work, several studies, including Direct Nash Optimization (Rosset et al.,
> 2024) and REBEL (Gao et al., 2024) have also explored using either cross-entropy loss or square
> loss minimization to approximate the exponential update. Specifically, they used the same trick
> proposed in DPO (Rafailov et al., 2024b) to cancel out the log-partition factor and directly regress
> on the win-rate difference. However, it is shown theoretically and empirically by Pal et al. (2024)
> 
> 
> 3
> 
> 
> that the pairwise loss may only drive the _relative_ likelihood gap to be large, but may not necessarily
> drive up the likelihood of the preferred responses. Our method instead has a deeper connection to
> the policy gradient theory and can effectively match the likelihood of the response to its win rate.
> 
> ### **2 Related Work**
> 
> 
> **RLHF** **with** **Explicit/Implicit** **Reward** **Model** Originally, reinforcement learning from human
> feedback (RLHF) was proposed by Christiano et al. (2017) as a methodology that first learns a reward
> model reflecting human preferences and then uses reinforcement learning algorithms to maximize
> the reward. This methodology is applied by Ouyang et al. (2022) to fine-tune instruction-following
> large language models and leads to the popular ChatGPT.
> The reward model in the works mentioned above assumes a parametric model such as the
> Bradley-Terry model (Bradley and Terry, 1952), which assigns a “score” representing how preferred
> a given response is. More recently, Rafailov et al. (2024b) proposed to instead directly solve
> the closed-form solution of such a score implied by the Bradley-Terry model. The Direct Policy
> Optimization (DPO) method is claimed to be more efficient and stable, yet, still implicitly assumes
> such a reward model that specifies the “score”. In a similar spirit, Zhao et al. (2023) proposed to
> calibrate the score so that the score of the winner in comparison has a margin over the score of
> the loser, and induces a different SLic loss. Similarly, Ethayarajh et al. (2024) derived a different
> loss function (called KTO) from the Kahneman-Tversky human utility function, which implicitly
> denotes a score of the given response. Liu et al. (2023) proposed Rejection Sampling Optimization
> (RSO) which utilizes a preference model to generate preference pairs with candidates sampled from
> the optimal policy; then preference optimization is applied on the sampled preference pairs. Hong
> et al. (2024) proposed Odds Ratio Preference Optimization (ORPO) algorithm that can perform
> supervised fine-tuning and preference alignment in one training session without maintaining an
> intermediate reference policy.
> 
> 
> **RLHF** **with** **General** **Preference** **Model** Often, the human preference is not strictly transitive,
> and cannot be sufficiently represented by a single numerical score. Azar et al. (2023) proposed a
> general preference optimization objective based on the preference probability between a pair of
> responses instead of a score of a single response. They further propose a learning objective based on
> identity mapping of the preference probability called IPO (Preference Optimization with Identity
> mapping), which aims to maximize the current policy’s expected winning probability over a given
> reference policy. Munos et al. (2023) formulated the RLHF problem with general preference as a
> two-player, constant-sum game, where each player is one policy that aims to maximize the probability
> of its response being preferred against its opponent. They aim to identify the Nash equilibrium policy
> of this game and propose a mirror-descent algorithm that guarantees the last-iterate convergence of
> a policy with tabular representations [2] . Wang et al. (2024) proposed to identify the Nash equilibrium
> policy for multi-step MDPs when a general preference model is present and shows that the problem
> can be reduced to a two-player zero-sum Markov game.
> 
> 
> **Theory** **of** **RLHF** There is also a line of research to analyze RLHF and provide its theoretical
> guarantees. Zhu et al. (2023) studied the standard RLHF with separate reward-learning and
> 
> 
> 2Due to the tabular representation, computing the normalizing factor is prohibitive and the algorithm is approximately executed by sampling one token instead of a full response.
> 
> 
> 4
> 
> 
> model-tuning and proposed a pessimistic reward-learning process that provably learns a linear
> reward model. Wang et al. (2024) proposed a framework to reduce any RLHF problem with a
> reward model to a reward-based standard RL problem. Additionally, they proposed to identify the
> Nash equilibrium policy when a general preference model is present and show that the problem
> can be reduced to a two-player zero-sum Markov game. Xiong et al. (2023) studied the reverse-KL
> regularized contextual bandit for RLHF in different settings and proposed efficient algorithms with
> finite-sample theoretical guarantees. Ye et al. (2024) studied the theoretical learnability of the
> KL-regularized Nash-Learning from Human Feedback (NLHF) by considering both offline and online
> settings and proposed provably efficient algorithms. Ji et al. (2024) proposed an active-query-based
> proximal policy optimization algorithm with regret bounds and query complexity based on the
> problem dimension and the sub-optimality gap.
> 
> 
> **Self-Play** **Fine-Tuning** Most works mentioned above (Rafailov et al., 2024b; Zhao et al., 2023;
> Azar et al., 2023; Ethayarajh et al., 2024) consider one single optimization procedure starting from
> some reference policy. The same procedure may be applied repeatedly for multiple rounds in a
> self-play manner. In each round, new data are generated by the policy obtained in the last round;
> these new data are then used for training a new policy that can outperform the old policy.
> The self-play fine-tuning can be applied to both scenarios with or without human preference
> data. For example, Singh et al. (2023) proposed an Expectation-Maximization (EM) framework
> where in each round, new data are generated and annotated with a reward score; the new policy is
> obtained by fine-tuning the policy on the data with a high reward. Chen et al. (2024) proposed
> a self-play framework to fine-tune the model in a supervised way. In each round, new preference
> pairs are synthesized by labeling the policy-generated responses as losers and the human-generated
> responses as winners. Then DPO is applied in each round to fine-tune another policy based on
> these synthesized preference data. Yuan et al. (2024) proposed Self-Rewarding Language Models,
> where the language model itself is used to annotate preference on its own responses. Iterative
> DPO is applied to fine-tune language models on these annotated data. These works show iterative
> fine-tuning can significantly improve the performance.
> 
> Swamy et al. (2024) considered a more general multi-step Markov Decision Process (MDP)
> setting and proposed Self-play Preference Optimization (SPO), an RLHF framework that can
> utilize any no-regret online learning algorithm for preference-based policy optimization. They then
> instantiated their framework with Soft Policy Iteration as an idealized variant of their algorithm,
> which reduces to the exponential weight update rule (4.1) when constrained to the bandit setting.
> The main difference is that they focus on the multi-round Markov decision process (MDP) in robotic
> and game tasks rather than on fine-tuning large language models and approximating the update
> using policy optimization methods such as PPO.
> Concurrent to our work, Rosset et al. (2024) proposed the Direct Nash Optimization (DNO)
> algorithm based on the cross-entropy between the true and predicted win rate gaps, and provided
> theoretical guarantees on the error of finite-sample approximation. However, their practical version
> still utilizes the iterative-DPO framework as in Xu et al. (2023) with the DPO loss instead of their
> derived DNO loss. Notably, in their experiments, they added the GPT-4 generated responses as
> their “gold sample” into their fine-tuning data, and used GPT-4 as a judge to assign a numerical
> score to each response for preference pair construction. In sharp contrast, our work does not require
> the use of any strong external supervision besides a small-sized reward model. Another concurrent
> work (Gao et al., 2024) proposed REBEL, an iterative fine-tuning framework via regressing the
> 
> 
> 5
> 
> 
> relative reward. When applied to the preference setting, it results in a similar algorithm to our
> algorithm SPPO, except that SPPO approximates the log-partition factor log _Zπt_ ( **x** ) with a constant
> _η/_ 2 while REBEL regresses on the win rate difference (so that log _Zπt_ ( **x** ) is canceled). Additionally,
> Calandriello et al. (2024) pointed out that optimizing the IPO loss (Azar et al., 2023) iteratively
> with self-play generated data is equivalent to finding the Nash equilibrium of the two-player game,
> and they proposed the IPO-MD algorithm based on this observation, which generates data with a
> mixture policy similar to the Nash-MD algorithm.
> 
> ### **3 Preliminaries**
> 
> 
> We consider the preference learning scenario as follows. Given a text sequence (commonly referred
> to as prompt) **x** = [ _x_ 1 _, x_ 2 _, . . ._ ], two text sequences **y** = [ _y_ 1 _, y_ 2 _, . . ._ ] and **y** _[′]_ are generated as responses
> to the prompt **x** . An autoregressive language model _π_ given the prompt **x** can generate responses **y**
> following the probability decomposition
> 
> 
> 
> _π_ ( **y** _|_ **x** ) =
> 
> 
> 
> _N_
> 
> 
> _π_ ( _yi|_ **x** _,_ **y** _<i_ ) _._
> 
> _i_ =1
> 
> 
> 
> Given the prompt **x** and two responses **y** and **y** _[′]_, a preference oracle (either a human annotator or
> a language model) will provide preference feedback _o_ ( **y** _≻_ **y** _[′]_ _|_ **x** ) _∈{_ 0 _,_ 1 _}_ indicating whether **y** is
> preferred over **y** _[′]_ . We denote P( **y** _≻_ **y** _[′]_ _|_ **x** ) = E[ _o_ ( **y** _≻_ **y** _[′]_ _|_ **x** )] as the probability of **y** “winning the
> duel” over **y** _[′]_ . The KL divergence of two probability distributions of density _p_ and _q_ is defined as
> 
>          -          KL( _p∥q_ ) = E **y** _∼p_ ( **y** ) log _[p]_ _q_ ( [(] **y** **[y]** ) [)] .
> 
> 
> **3.1** **RLHF** **with** **Reward** **Models**
> 
> 
> Christiano et al. (2017) first learn a reward function _r_ ( **y** ; **x** ) following the Bradley-Terry model (Bradley
> and Terry, 1952). For a prompt-response-response triplet ( **x** _,_ **y** _,_ **y** _[′]_ ), the Bradley-Terry model specifies
> the probability of **y** being chosen over **y** as
> 
> 
> P( **y** _≻_ **y** _[′]_ _|_ **x** ) = exp( _r_ ( **y** ; **x** ))        - _r_ ( **y** ; **x** ) _−_ _r_ ( **y** _[′]_ ; **x** )� _,_ (3.1)
> exp( _r_ ( **y** ; **x** )) + exp( _r_ ( **y** _[′]_ ; **x** )) [=] _[ σ]_
> 
> 
> where _σ_ ( _x_ ) = _e_ _[x]_ _/_ ( _e_ _[x]_ + 1) is the logistic function. The reward function associated with the BradleyTerry model can be estimated by maximizing the log-likelihood log P( **y** _≻_ **y** _[′]_ _|_ **x** ). Suppose the
> true reward function _r_ ( **y** ; **x** )) is available, Christiano et al. (2017) proposed to solve the following
> optimization problem with policy optimization algorithms in RL such as PPO (Schulman et al.,
> 2017):
> 
> 
> max _**θ**_ E **x** _∼X_ _,_ **y** _∼π_ _**θ**_ ( _·|_ **x** )[ _r_ ( **y** ; **x** )] _−_ _η_ _[−]_ [1] E **x** _∼X_ [KL( _π_ _**θ**_ ( _·|_ **x** ) _∥π_ ref( _·|_ **x** ))] _,_ (3.2)
> 
> 
> where _X_ is the prompt distribution.
> 
> Rafailov et al. (2024b) identified that the optimization problem above has a closed-form solution
> such that for any **y**,
> 
> 
> _π_ _[∗]_ ( **y** _|_ **x** ) _∝_ _π_ ref( **y** _|_ **x** ) exp( _ηr_ ( **y** ; **x** )) _,_
> 
> 
> 6
> 
> 
> which can be further converted to the DPO loss for any triplet ( **x** _,_ **y** _w,_ **y** _l_ ) where the winner **y** _w_ is
> chosen over the loser **y** _l_ :
> 
> 
> 
> 
> - _−_ log - _π_ _**θ**_ ( **y** _l|_ **x** )
> _π_ ref( **y** _l|_ **x** )
> 
> 
> 
> �� [�]
> 
> _._
> 
> 
> 
> _ℓ_ DPO( **x** _,_ **y** _w,_ **y** _l_ ; _**θ**_ ; _π_ ref) := _−_ log _σ_
> 
> 
> 
> 
> 
>   -   - _π_ _**θ**_ ( **y** _w|_ **x** )
> _η_ _[−]_ [1] log
> _π_ ref( **y** _w|_ **x** )
> 
> 
> 
> **3.2** **RLHF** **with** **General** **Preference**
> 
> 
> Following Wang et al. (2024); Munos et al. (2023), we aim to establish RLHF methods without a
> reward model, as the human preference can be non-transitive (Tversky, 1969). Under a general
> preference oracle P( **y** _≻_ **y** _[′]_ _|_ **x** ), we follow Dud´ık et al. (2015) and aim to identify the _von_ _Neumann_
> _winner_ . More specifically, the von Neumann winner _π_ _[∗]_ is the (symmetric) Nash equilibrium of the
> following two-player constant-sum game:
> 
> 
>                       ( _π_ _[∗]_ _, π_ _[∗]_ ) = arg max _π_ min _π_ _[′]_ [E] **[x]** _[∼X]_ E **y** _∼π_ ( _·|_ **x** ) _,_ **y** _′∼π′_ ( _·|_ **x** )�P( **y** _≻_ **y** _[′]_ _|_ **x** )� [�] _._ (3.3)
> 
> 
> In addition, we define the winning probability of one response **y** against a distribution of
> responses _π_ as
> 
> 
> P( **y** _≻_ _π|_ **x** ) = E **y** _′∼π_ ( _·|_ **x** )[P( **y** _≻_ **y** _[′]_ _|_ **x** )] _,_
> 
> 
> and the winning probability of one policy _π_ against another policy _π_ _[′]_ as
> 
> 
> P( _π_ _≻_ _π_ _[′]_ _|_ **x** ) = E **y** _∼π_ ( _·|_ **x** )E **y** _′∼π′_ ( _·|_ **x** )[P( **y** _≻_ **y** _[′]_ _|_ **x** )] _._
> 
> 
> Furthermore, we define P( _π_ _≻_ _π_ _[′]_ ) = E **x** _∼X_ [P( _π_ _≻_ _π_ _[′]_ _|_ **x** )], where **x** is a prompt drawn from the
> prompt distribution _X_ . The two-player constant-sum game (3.3) can be simplified as
> 
> 
> ( _π_ _[∗]_ _, π_ _[∗]_ ) = arg max _π_ min _π_ _[′]_ [P][(] _[π]_ _[≻]_ _[π][′]_ [)] _[.]_
> 
> ### **4 Self-Play Preference Optimization(SPPO)**
> 
> 
> In this section, we introduce the Self-Play Preference Optimization(SPPO) algorithm, derived from
> the following theoretical framework.
> 
> 
> **4.1** **Theoretical** **Framework**
> 
> 
> There are well-known algorithms to approximately solve the Nash equilibrium in a constant-sum
> two-player game. In this work, we follow Freund and Schapire (1999) to establish an iterative
> framework that can asymptotically converge to the optimal policy on average. We start with a
> theoretical framework that conceptually solves the two-player game as follows:
> 
> 
> _πt_ +1( **y** _|_ **x** ) _∝_ _πt_ ( **y** _|_ **x** ) exp( _η_ P( **y** _≻_ _πt|_ **x** )) _,_ for _t_ = 1 _,_ 2 _, . . . ._ (4.1)
> 
> 
> (4.1) is an iterative framework that relies on the multiplicative weight update in each round _t_ and
> enjoys a clear structure. Initially, we have a base policy _π_ 1 usually from some supervised fine-tuned
> model. In each round, the updated policy _πt_ +1 is obtained from the reference policy _πt_ following
> 
> 
> 7
> 
> 
> the multiplicative weight update. More specifically, a response **y** should have a higher probability
> weight if it has a higher average advantage over the current policy _πt_ .
> Equivalently, (4.1) can be written as
> 
> 
>                           - _η_ P( **y** _≻_ _πt|_ **x** )�
> _πt_ +1( **y** _|_ **x** ) = _[π][t]_ [(] **[y]** _[|]_ **[x]** [) exp] _,_ (4.2)
> 
> _Zπt_ ( **x** )
> 
> where _Zπt_ ( **x** ) = [�] **y** _[π][t]_ [(] **[y]** _[|]_ **[x]** [)][ exp] - _η_ P( **y** _≻_ _πt|_ **x** )� is the normalizing factor (a.k.a., the partition
> function). For any fixed **x** and **y**, the ideal update policy _πt_ +1 should satisfy the following equation:
> 
> 
> 
> 
>  - _πt_ +1( **y** _|_ **x** )
> log
> _πt_ ( **y** _|_ **x** )
> 
> 
> 
> 
> = _η ·_ P( **y** _≻_ _πt|_ **x** ) _−_ log _Zπt_ ( **x** ) _._ (4.3)
> 
> 
> 
> Unlike the pair-wise design in DPO or IPO that cancels the log normalizing factor log _Zπt_ ( **x** ) by
> differentiating (4.3) between **y** and **y** _[′]_, we choose to approximate (4.3) directly in terms of _L_ 2
> distance:
> 
> 
> 
> 
> - 2
> 
>   -  - [�]
> 
> _−_ _η_ P( **y** _≻_ _πt|_ **x** ) _−_ log _Zπt_ ( **x** ) _._ (4.4)
> 
> 
> 
> _πt_ +1 = argmin E **x** _∼X_ _,_ **y** _∼πt_ ( _·|_ **x** )
> _π_
> 
> 
> 
> 
> - - _π_ ( **y** _|_ **x** )
> log
> _πt_ ( **y** _|_ **x** )
> 
> 
> 
> **Estimation** **of** **the** **Probability** The optimization objective (4.4) can be approximated with finite
> samples. We choose to sample _K_ responses **y** 1 _,_ **y** 2 _, . . .,_ **y** _K_ _∼_ _πt_ ( _·|_ **x** ) for each prompt **x**, and denote
> the empirical distribution by _π_ - _t_ _[K]_ [.] [The] [finite-sample] [optimization] [problem] [can] [be] [approximated] [as]
> 
> 
> 
> 
> - 2
> 
>   -  - [�]
> 
> _−_ _η_ P( **y** _≻_ _π_ - _t_ _[K][|]_ **[x]** [)] _[ −]_ [log] _[ Z]_ _π_ - _t_ _[K]_ [(] **[x]** [)] _._ (4.5)
> 
> 
> 
> _πt_ +1 = argmin E **x** _∼X_ _,_ **y** _∼πt_ ( _·|_ **x** )
> _π_
> 
> 
> 
> 
> - - _π_ ( **y** _|_ **x** )
> log
> _πt_ ( **y** _|_ **x** )
> 
> 
> 
> Specifically, P( **y** _≻_ _π_ - _t_ _[K][|]_ **[x]** [)] [=] [�] _k_ _[K]_ =1 [P][(] **[y]** _[≻]_ **[y]** _[k][|]_ **[x]** [)] _[/K]_ [and] _[Z]_ _π_ - _t_ _[K]_ [(] **[x]** [)] [=] [E] **[y]** _[∼][π][t]_ [(] _[·|]_ **[x]** [)][[][exp][(] _[η]_ [P][(] **[y]** _[≻]_ _[π]_ [�] _t_ _[K][|]_ **[x]** [))].]
> _Zπ_ - _tK_ [(] **[x]** [),] [treated] [as] [an] [expectation,] [can] [be] [further] [estimated] [by] _[B]_ [new] [samples] [with] [in] [total] _[O]_ [(] _[KB]_ [)]
> queries of the preference oracle P. (4.5) is an efficiently tractable optimization problem. Informally
> speaking, when _K_ _→∞_, (4.5) will recover (4.4). We have the following guarantee on the convergence
> of (4.4):
> 
> 
> **Theorem** **4.1.** Assume the optimization problem (4.4) is realizable. Denote _√πt_ as the policy
> obtained via (4.4) and the mixture policy _π_ ¯ _T_ = [1] - _Tt_ =1 _[π][t]_ [.] [By] [setting] _[η]_ [= Θ(1] _[/]_ _T_ ), we have that
> 
> 
> 
> _√_
> _T_ [1] - _Tt_ =1 _[π][t]_ [.] [By] [setting] _[η]_ [= Θ(1] _[/]_
> 
> 
> 
> _T_ ), we have that
> 
> 
> 
> _√_
> max �P( _π_ _≻_ _π_ ¯ _T_ )� _−_ min �P( _π_ _≺_ _π_ ¯ _T_ )� = _O_ (1 _/_
> _π_ _π_
> 
> 
> 
> _T_ ) _._
> 
> 
> 
> Theorem 4.1 characterizes the convergence rate of the average policy across the time horizon _T_
> towards the Nash equilibrium, in terms of the duality gap. The proof is based on Theorem 1 in
> Freund and Schapire (1999) with slight modification. For completeness, we include the proof in
> Appendix B.
> Alternatively, we can avoid estimating log _Zπ_   - _tK_ [(] **[x]** [)] [by] [replacing] [it] [with] [a] [constant] [based] [on] [the]
> human preference model. The choice of the constant is discussed in detail in Appendix A. Here, we
> replace log _Zπ_ - _tK_ [(] **[x]** [)] [with] _[η/]_ [2][3] [in] [(][4.5][)] [to] [obtain] [a] [more] [clear] [objective:]
> 
> 
> 
> 
> - 
> _−_ _η_ P( **y** _≻_ _π_ - _t_ _[K][|]_ **[x]** [)] _[ −]_ [1] 2
> 
> 
> 
> ��2
> _._ (4.6)
> 
> 
> 
> _πt_ +1 = argmin E **x** _∼X_ _,_ **y** _∼πt_ ( _·|_ **x** )
> _π_
> 
> 
> 
> 
> - - _π_ ( **y** _|_ **x** )
> log
> _πt_ ( **y** _|_ **x** )
> 
> 
> 
> 3Assuming the winning probability between any given pair is either 1 or 0 with equal chance, when _K_ _→∞_, we
> can show that indeed _Zπ_ - _tK_ [(] **[x]** [)] _[ →]_ _[e][η/]_ [2][.] [Also] [see] [Appendix] [A] [for] [a] [complete] [derivation.]
> 
> 
> 8
> 
> 
> **Algorithm** **1** `Self-Play` `Preference` `Optimization(SPPO)`
> 
> 
> 1: **input** : base policy _π_ _**θ**_ 1, preference oracle P, learning rate _η_, number of generated samples _K_ .
> 
> 2: **for** _t_ = 1 _,_ 2 _, . . ._ **do**
> 
> 3: Generate synthetic responses by sampling **x** _∼X_ and **y** 1: _K_ _∼_ _πt_ ( _·|_ **x** ).
> 
> 4: Annotate the win-rate P( **y** _k_ _≻_ **y** _k′|_ **x** ) _, ∀k, k_ _[′]_ _∈_ [ _K_ ].
> 
> 5: Select responses from **y** 1: _K_ to form dataset _Dt_ = _{_ ( **x** _i,_ **y** _i,_ _P_ [�] ( **y** _i_ _≻_ _πt|_ **x** _i_ )) _}i∈_ [ _N_ ].
> 
> 6: Optimize _π_ _**θ**_ _t_ +1 according to (4.6):
> 
> 
> 
> ��2
> _._ (4.7)
> 
> 
> 
> _**θ**_ _t_ +1 _←_ argmin _**θ**_ E( **x** _,_ **y** _,_     - _P_ ( **y** _≻πt|_ **x** )) _∼Dt_
> 
> 
> 7: **end** **for**
> 
> 
> 
> 
> - - _π_ _**θ**_ ( **y** _|_ **x** )
> log
> _πt_ ( **y** _|_ **x** )
> 
> 
> 
> 
> - 
> _−_ _η_ _P_ �( **y** _≻_ _πt|_ **x** ) _−_ [1]
> 2
> 
> 
> 
> Intuitively, if a tie occurs (i.e., P( **y** _≻_ _π_ - _t_ _[K][|]_ **[x]** [) = 1] _[/]_ [2),] [we] [prefer] [the] [model] [does] [not] [update] [weight]
> at **y** . If **y** wins over _π_ - _t_ _[K]_ on average (i.e., P( **y** _≻_ _π_ - _t_ _[K][|]_ **[x]** [)] _[>]_ [1] _[/]_ [2),] [then] [we] [increase] [the] [probability]
> density at **y** to employ the advantage of **y** over _π_ - _t_ _[K]_ [.] [In] [our] [experiments,] [we] [choose] [to] [minimize] [the]
> objective (4.6).
> 
> 
> **4.2** **The** **SPPO** **Algorithm**
> 
> 
> Based on the aformentioned theoretical framework, we propose the _Self-Play Preference Optimization_
> algorithm in Algorithm 1. In each round _t_, Algorithm 1 will first generate _K_ responses **y** 1 _,_ **y** 2 _, . . .,_ **y** _K_
> according to _πt_ ( _·|_ **x** ) for each prompt **x** (Line 3). Then, the preference oracle P will be queried
> to calculate the win rate among the _K_ responses (Line 4). At Line 5, certain criteria can be
> applied to determine which response should be kept in the constructed dataset _Dt_ and construct
> the prompt-response-probability triplet ( **x** _,_ **y** _,_ _P_ [�] ( **y** _≻_ _πt|_ **x** )). We will discuss the design choices later
> in Section 5. One straightforward design choice is to include all _K_ responses into _Dt_ and each
> _P_ �( **y** _i_ _≻_ _πt|_ **x** ) is estimated by comparing **y** _i_ to all _K_ responses. In total, _O_ ( _K_ [2] ) queries will be made.
> Then the algorithm will optimize (4.6) on the dataset _Dt_ (Line 6).
> 
> 
> **4.3** **Connection** **to** **Policy** **Gradient**
> 
> 
> While SPPO is derived from the iterative framework (Freund and Schapire, 1999) for two-player
> games, the square loss in the SPPO objective (4.4) provides an alternative interpretation for SPPO
> as a _semi-online_ variant of policy gradient method due to its special loss form. The difference from
> standard policy gradient is that it collects samples from _π_ _**θ**_ _t_ at the start of iteration _t_, rather than
> perform on-policy sampling at each gradient step.
> Consider a general reward function _r_ ( **y** ; **x** ), the RLHF problem (3.2) can be written as:
> 
> 
> 
> 
> _._ (4.8)
> 
> 
> 
> max _**θ**_ _J_ ( _**θ**_ ) := E **x** _∼X_ _,_ **y** _∼π_ _**θ**_ ( _·|_ **x** )
> 
> 
> The policy gradient of the objective _J_ ( _**θ**_ ) is:
> 
> 
> 
> 
> _r_ ( **y** ; **x** ) _−_ _η_ _[−]_ [1] log _[π]_ _**[θ]**_ [(] **[y]** _[|]_ **[x]** [)]
> 
> _π_ ref( **y** _|_ **x** )
> 
> 
> 
> _∇J_ ( _**θ**_ ) = E **x** _∼X_ _,_ **y** _∼π_ _**θ**_ ( _·|_ **x** )
> 
> 
> 
> �� - _r_ ( **y** ; **x** ) _−_ _η_ _[−]_ [1] log _[π]_ _**[θ]**_ [(] **[y]** _[|]_ **[x]** [)] _∇_ log _π_ _**θ**_ ( **y** _|_ **x** ) (4.9)
> 
> _π_ ref( **y** _|_ **x** ) _[−]_ _[b]_ [(] **[x]** [)]
> 
> 
> 9
> 
> 
> �2�
> _,_ (4.10)
> 
> 
> 
> = _η_ E **x** _∼X_ _,_ **y** _∼π_ _**θ**_ ( _·|_ **x** )
> 
> 
> 
> 
> - _−∇_ _r_ ( **y** ; **x** ) _−_ _η_ _[−]_ [1] log _[π]_ _**[θ]**_ [(] **[y]** _[|]_ **[x]** [)]
> 
> 
> 
> _π_ ref( **y** _|_ **x** ) _[−]_ _[b]_ [(] **[x]** [)]
> 
> 
> 
> where the first line follows the policy gradient theorem (Sutton et al., 1999) and the baseline _b_ ( **x** )
> is an arbitrary constant relying only on **x** used for variance reduction. Comparing the square loss
> (4.10) with the SPPO objective (4.4) (rewritten below):
> 
> 
> 
> 
> - �2�
> 
> _−_ _η_ _[−]_ [1] log _Zπ_ _**θ**_ _t_ ( **x** ) _,_
> 
> 
> 
> _**θ**_ _t_ +1 = argmin _**θ**_ E **x** _∼X_ _,_ **y** _∼π_ _**θ**_ _t_ ( _·|_ **x** )
> 
> 
> 
> �� - _π_ _**θ**_ ( **y** _|_ **x** )
> P( **y** _≻_ _π_ _**θ**_ _t|_ **x** ) _−_ _η_ _[−]_ [1] log _π_ _**θ**_ _t_ ( **y** _|_ **x** )
> 
> 
> 
> one can see that the win rate P( **y** _≻_ _π_ _**θ**_ _t|_ **x** ) is exactly the reward SPPO aims to maximize, and
> _η_ _[−]_ [1] log _Zπ_ _**θ**_ _t_ ( **x** ) is in fact the best possible baseline–the (soft) value function. When the value
> function is not available in practice, it can be replaced by any constant baseline to reduce the
> variance of the policy gradient. We choose 1 _/_ 2 as a good approximation to _η_ _[−]_ [1] log _Zπ_ _**θ**_ _t_ ( **x** ) but the
> constant can vary depending on the human preference model (see Appendix A). Equation (4.9) is
> also discussed in Munos et al. (2023).
> Comparing with the general framework proposed by Swamy et al. (2024), SPPO can be seen as a
> new, straightforward variant of policy gradient method without the need of extra modifications such
> as gradient clipping in PPO, Hessian calculation in TRPO, or maintaining multiple components
> (Q-critic, V-critic, actor, etc.) in many policy optimization algorithms.
> 
> 
> **4.4** **Token-Level** _Q_ _[∗]_ **Learning**
> 
> 
> Rafailov et al. (2024a) showed that under the Max-Entropy RL formulation, the token-level log-ratio
> log _[π]_ _**[θ]**_ [(] **[y]** _[|]_ **[x]** [)] [be] [seen] [as] [an] [implicit] [token-level] [reward] [or] [advantage] [function] [(invariant] [under]
> 
> _π_ ref( **y** _|_ **x** ) [can]
> reward shaping). Below we show the square loss in SPPO can also lead to the optimal Max-Entropy
> policy _π_ _[∗]_, with token-level optimal value/advantage function.
> We first briefly restate the setting and results in Rafailov et al. (2024b). The token-level MDP
> defines the state **s** _h_ = ( **x** _, y_ 1 _, y_ 2 _, . . ., yh−_ 1) as the prefix tokens, and the action **a** _h_ = _yh_ as the next
> token. An auto-regressive language model _π_ ( **y** _|_ **x** ) can be viewed as a token-level policy _π_ ( **a** _h|_ **s** _h_ )
> and the transition kernel is known and deterministic because it only concatenates the next token to
> the prefix to form a new token sequence **s** _h_ +1 = ( **x** _, y_ 1 _, y_ 2 _, . . ., yh_ ).
> The Max-Entropy RL setting again considers the reverse-KL regularized reward maximization
> problem (3.2):
> 
> 
> max _**θ**_ E **x** _∼X_ _,_ **y** _∼π_ _**θ**_ ( _·|_ **x** )[ _r_ ( **y** ; **x** )] _−_ _η_ _[−]_ [1] E **x** _∼X_ [KL( _π_ _**θ**_ ( _·|_ **x** ) _∥π_ ref( _·|_ **x** ))]
> 
> =E **x** _∼X_ _,_ **y** _∼π_ _**θ**_ ( _·|_ **x** )[ _r_ ( **y** ; **x** ) + _η_ _[−]_ [1] log _π_ ref( **y** _|_ **x** )] + _η_ _[−]_ [1] E **x** _∼X_ [ _H_ ( _π_ _**θ**_ ( _·|_ **x** ))] _._
> 
> 
> We denote the optimal solution for the problem above as _π_ _[∗]_ . Rafailov et al. (2024a) showed that
> the Bradley-Terry preference model (4.13) can be rewritten as:
> 
> 
> 
> 
>      - _|_ **y** _w|_
> 
>     P( **y** _w_ _≻_ **y** _l|_ **x** ) = _σ_ _η_ _[−]_ [1]
> 
> 
> 
> _l_
> 
> - _h_ _[|]_ **[s]** _[l]_ _h_ [)]
> 
> log _[π][∗]_ [(] **[a]** _[l]_
> _h_ =1 _π_ ref( **a** _[l]_ _h_ _[|]_ **[s]** _[l]_ _h_ [)]
> 
> 
> 
> _|_ **y** _w|_ _|_ **y** _l|_
> 
> - _h_ _[|]_ **[s]** _h_ _[w]_ [)] 
> log _[π][∗]_ [(] **[a]** _[w]_
> _h_ =1 _π_ ref( **a** _[w]_ _h_ _[|]_ **[s]** _h_ _[w]_ [)] _[−]_ _[η][−]_ [1] _h_ =1
> 
> 
> 
> 
> _,_
> 
> 
> 
> where the state and action is defined as in the token-level MDP introduced above, with superscription
> ( _·_ ) _[w]_ and ( _·_ ) _[l]_ denoting if it is for the winner **y** _w_ or the loser **y** _l_ . And maximizing the log likelihood
> with _π_ _[∗]_ replaced by _π_ _**θ**_ gives the DPO loss.
> 
> 
> 10
> 
> 
> From now on we assume the horizon is fixed at _H_ for simplicity. The derivation of the MaxEntropy RL formulation relies on the (soft) optimal value function _Q_ _[∗]_ and _V_ _[∗]_ as [4] :
> 
> 
> _V_ _[∗]_ ( **s** _H_ +1) = _r_ ( **s** _H_ +1) := _r_ ( **y** ; **x** ) _,_ (reward at EOS)
> 
> _Q_ _[∗]_ ( **s** _h,_ **a** _h_ ) = _η_ _[−]_ [1] log _π_ ref( **a** _h|_ **s** _h_ ) + _V_ _[∗]_ ( **s** _h_ +1) _,_
> 
> _V_ _[∗]_ ( **s** _h_ ) = _η_ _[−]_ [1] log          - exp          - _ηQ_ _[∗]_ ( **s** _h,_ **a** )� _,_ when _h ≤_ _H._
> 
> 
> **a**
> 
> 
> Rafailov et al. (2024a) showed that the optimal policy _π_ _[∗]_ satisfies:
> 
> 
> _η_ _[−]_ [1] log _π_ _[∗]_ ( **a** _h|_ **s** _h_ ) = _Q_ _[∗]_ ( **s** _h,_ **a** _h_ ) _−_ _V_ _[∗]_ ( **s** _h_ )
> 
> = _η_ _[−]_ [1] log _π_ ref( **a** _h|_ **s** _h_ ) + _V_ _[∗]_ ( **s** _h_ +1) _−_ _V_ _[∗]_ ( **s** _h_ ) _._
> 
> 
> It can be verified that for **s** 1 = ( **x** ), we have _ηV_ _[∗]_ ( **s** 1) = log [�] **y** _[π]_ [ref][(] **[y]** _[|]_ **[x]** [) exp] - _ηr_ ( **y** ; **x** )�:
> 
> 
> exp          - _ηV_ _[∗]_ ( **s** 1)� =          - exp          - _ηQ_ _[∗]_ ( **s** 1 _,_ **a** 1)�
> 
> **a** 1
> 
> =           - _π_ ref( **a** 1 _|_ **s** 1) exp           - _ηV_ _[∗]_ ( **s** 2)�
> 
> **a** 1
> 
> =           - _π_ ref( **a** 1 _|_ **s** 1) _π_ ref( **a** 2 _|_ **s** 2) exp           - _ηV_ _[∗]_ ( **s** 3)�
> 
> **a** 1 _,_ **a** 2
> 
> 
> _· · ·_
> 
> 
> 
> 
>  =
> 
> 
> ( **a** 1 _,_ **a** 2 _,...,_ **a** _H_ )
> 
> 
> 
> _H_
> 
> - _π_ ref( **a** _h|_ **s** _h_ ) exp - _ηr_ ( **s** _H_ +1)�
> 
> 
> _h_ =1
> 
> 
> 
> =           - _π_ ref( **y** _|_ **x** ) exp           - _ηr_ ( **y** ; **x** )� _._
> 
> 
> **y**
> 
> 
> Going back to the SPPO objective (4.4) at _t_ -th iteration, if we set _π_ ref = _πt_ and _r_ ( **y** ; **x** ) = P( **y** _≻_
> _πt|_ **x** ), we have _V_ _[∗]_ ( **s** 1) = _η_ _[−]_ [1] log _Zπt_ ( **x** ), and the learning objective at _t_ -th iteration becomes:
> 
> 
> 
> 
> - 2
> 
>   -  - [�]
> 
> _−_ _η_ P( **y** _≻_ _πt|_ **x** ) _−_ log _Zπt_ ( **x** )
> 
> 
> 
> _πt_ +1 = argmin E **x** _∼X_ _,_ **y** _∼πt_ ( _·|_ **x** )
> _π_
> 
> 
> 
> 
> - - _π_ ( **y** _|_ **x** )
> log
> _πt_ ( **y** _|_ **x** )
> 
> 
> 
> = argmin E **s** 1 _∼X_ _,_ **a** _h∼πt_ ( _·|_ **s** _h_ )
> _π_
> 
> 
> 
> _H_
> 
> 
>  
> 
> 
> 
> 
> log _[π]_ [(] **[a]** _[h][|]_ **[s]** _[h]_ [)]
> 
> _π_ _[∗]_ ( **a** _h|_ **s** _h_ )
> 
> _h_ =1
> 
> 
> 
> _π_ _[∗]_ ( **a** _h|_ **s** _h_ )
> 
> 
> 
> �2
> _._ (4.11)
> 
> 
> 
> Similar to DPO, SPPO “secretly” encourages the policy _π_ _**θ**_ to converge to the optimal policy _π_ _[∗]_
> 
> at token level via the square loss form (4.11). Additionally, one may realize that minimizing the
> square-loss form is related to minimizing the KL divergence KL( _π_ _**θ**_ _∥π_ _[∗]_ ) via policy gradient:
> 
> 
> 
> _∇_ _**θ**_ KL( _π_ _**θ**_ _∥π_ _[∗]_ ) = E **s** 1 _∼X_ _,_ **a** _h∼π_ _**θ**_ ( _·|_ **s** _h_ )
> 
> 
> 
> _H_
> ��
> 
>  
> 
> 
> 
> 
> log _[π]_ _**[θ]**_ [(] **[a]** _[h][|]_ **[s]** _[h]_ [)]
> 
> _π_ _[∗]_ ( **a** _h|_ **s** _h_ )
> 
> _h_ =1
> 
> 
> 
> _π_ _[∗]_ ( **a** _h|_ **s** _h_ )
> 
> 
> 
> _H_
> 
> - 
>  - _∇_ _**θ**_ log _π_ _**θ**_ ( **a** _h|_ **s** _h_ )
> 
> 
> _h_ =1
> 
> 
> 
> 4Here we restated with the sequence-level reward _r_ ( **y** ; **x** ). Rafailov et al. (2024a) started their derivation from
> a ground-truth token-level reward _r_ ( **s** _h,_ **a** _h_ ), which is under-specified due to the reward reshaping issue (Ng et al.,
> 1999): reshaping the reward will not affect the Bradley-Terry preference probability so it is impossible to recover the
> ground-truth reward from the preference signal (Rafailov et al., 2024a, Section 4.2).
> 
> 
> 11
> 
> 
>         
> = E **s** 1 _∼X_ _,_ **a** _h∼π_ _**θ**_ ( _·|_ **s** _h_ ) _∇_ _**θ**_
> 
> 
> 
> _H_
> 
> 
>  
> 
> 
> 
> 
> log _[π]_ _**[θ]**_ [(] **[a]** _[h][|]_ **[s]** _[h]_ [)]
> 
> _π_ _[∗]_ ( **a** _h|_ **s** _h_ )
> 
> _h_ =1
> 
> 
> 
> _π_ _[∗]_ ( **a** _h|_ **s** _h_ )
> 
> 
> 
> �2�
> _._
> 
> 
> 
> **4.5** **Comparison** **with** **DPO,** **IPO,** **and** **KTO**
> 
> 
> In practice, we utilize mini-batches of more than 2 responses to estimate the win rate of a given
> response, while the DPO and IPO loss focus on a single pair of responses. When only a pair of
> responses **y** _w_ and **y** _l_ is available, we have the pair-wise symmetric loss based on the preference
> triplet ( **x** _,_ **y** _w,_ **y** _l_ ) defined as:
> 
> 
> 
> 
>         -         - _π_ _**θ**_ ( **y** _w|_ **x** )
> _ℓ_ SPPO( **x** _,_ **y** _w,_ **y** _l_ ; _**θ**_ ; _π_ ref) := log
> _π_ ref( **y** _w|_ **x** )
> 
> 
> 
> 
> 
>   
> _−_ _η_ P( **y** _w_ _≻_ **y** _l|_ **x** ) _−_ [1]
> 
> 2
> 
> 
> 
> 2
> 
> - [�]
> 
> 
> 
> 
>  -  - _π_ _**θ**_ ( **y** _l|_ **x** )
> + log
> _π_ ref( **y** _l|_ **x** )
> 
> 
> 
> 
> 
>   
> _−_ _η_ P( **y** _w_ _≺_ **y** _l|_ **x** ) _−_ [1]
> 
> 2
> 
> 
> 
> 2
> 
> - [�]
> _,_ (4.12)
> 
> 
> 
> where P( **y** _w_ _≻_ **y** _l|_ **x** ) can be either a soft probability within [0 _,_ 1] or a hard label 1 indicating **y** _w_ _≻_ **y** _l_ .
> We now compare the SPPO loss to other baselines assuming a hard label **y** _w_ _≻_ **y** _l_ is given. For
> the ease of comparison, let ( _β_ = _η_ _[−]_ [1] ):
> 
> 
> 
> 
>    - _π_ _**θ**_ ( **y** _w|_ **x** )
> _a_ = _β_ log
> _π_ ref( **y** _w|_ **x** )
> 
> 
> 
> 
> - - _π_ _**θ**_ ( **y** _l|_ **x** )
> _, b_ = _β_ log
> _π_ ref( **y** _l|_ **x** )
> 
> 
> 
> 
> _, c_ = _β_ KL( _π_ _**θ**_ _∥π_ ref) _,_
> 
> 
> 
> then we have
> 
> 
> _ℓ_ DPO( **y** _w,_ **y** _l,_ **x** ) = _−_ log _σ_ ( _a −_ _b_ ) _,_ (4.13)
> 
> _ℓ_ IPO( **y** _w,_ **y** _l,_ **x** ) = [( _a −_ _b_ ) _−_ 1] [2] _,_ (4.14)
> 
> _ℓ_ KTO( **y** _w,_ **y** _l,_ **x** ) = _σ_ ( _−a_ + _c_ ) + _σ_ ( _b −_ _c_ ) (simplified) _,_ (4.15)
> 
> 
> where _σ_ ( _x_ ) = _e_ _[x]_ _/_ ( _e_ _[x]_ + 1) and the SPPO loss can be written as
> 
> 
> _ℓ_ SPPO( **y** _w,_ **y** _l,_ **x** ) = ( _a −_ 1 _/_ 2) [2] + ( _b_ + 1 _/_ 2) [2] _._
> 
> 
> 
> It can be seen that SPPO not only pushes the gap between _a_ and _b_ to be 1, but also attempts
> to push the value of _a_ to be close to 1 _/_ 2 and the value of _b_ to be close to _−_ 1 _/_ 2 so that _π_ _**θ**_ ( **y** _w|_ **x** ) _>_
> _π_ ref( **y** _w|_ **x** ) and _π_ _**θ**_ ( **y** _l|_ **x** ) _<_ _π_ ref( **y** _l|_ **x** ). We believe this to be particularly important: when the
> preference pairs are scarce (e.g., one pair for each prompt), there is no guarantee that the winner
> log-ratio _a_ will increase and the loser log-ratio _b_ will decrease. Instead, only the gap between the
> winner and the loser (i.e., _a −_ _b_ ) will increase. This phenomenon is observed by Pal et al. (2024)
> that DPO only lowers the loser’s likelihood, but barely change the winner’s likelihood.
> 
>              - _πt_ +1( **y** _|_ **x** )              As discussed above, fitting _β_ log directly to P( **y** _≻_ _πt|_ **x** ) _−_ 1 _/_ 2 under a square loss is
> 
> 
> 
> 
>              - _πt_ +1( **y** _|_ **x** )              As discussed above, fitting _β_ log _πt_ ( **y** _|_ **x** ) directly to P( **y** _≻_ _πt|_ **x** ) _−_ 1 _/_ 2 under a square loss is
> 
> closely related to the policy gradient. This explains why SPPO is more effective than IPO which
> attempts to fit _β_ log - _ππt_ +1 _t_ ( **y** ( **y** _ww|_ **x** _|_ **x** ) ) - _−_ _β_ log - _ππt_ +1 _t_ ( **y** ( **y** _l|l_ **x** _|_ **x** ) ) - to P( **y** _w_ _≻_ _πt|_ **x** ) _−_ P( **y** _l_ _≻_ _πt|_ **x** ). In addition,
> 
> SPPO shares a similar spirit as KTO. The KTO loss pushes _a_ to be large by minimizing _σ_ ( _−a_ + _c_ )
> and pushes _b_ to be small by minimizing _σ_ ( _b −_ _c_ ). In contrast, SPPO pushes _a_ to be as large as 1 _/_ 2
> and _b_ to be as small as _−_ 1 _/_ 2.
> On the other hand, we would like to comment that although DPO and KTO can be extended
> to their iterative variants, they are not by nature iterative algorithms and do not have provable
> 
> 
> 12
> 
> 
> 
> _t_ +1( **y** _w|_ **x** ) - _−_ _β_ log - _πt_ +1( **y** _l|_ **x** )
> 
> _πt_ ( **y** _w|_ **x** ) _πt_ ( **y** _l|_ **x** )
> 
> 
> 
> _πt_ +1 _t_ ( **y** ( **y** _l|l_ **x** _|_ **x** ) ) - to P( **y** _w_ _≻_ _πt|_ **x** ) _−_ P( **y** _l_ _≻_ _πt|_ **x** ). In addition,
> 
> 
> guarantees that they can reach the Nash equilibrium. In contrast, SPPO and IPO are by design
> capable to solve the Nash equilibrium iteratively. SPPO is superior to IPO because its design
> explicitly alleviates the data sparsity issue, as discussed above and detailed in Pal et al. (2024).
> 
> ### **5 Experiments**
> 
> 
> **5.1** **Experiment** **Setup**
> 
> 
> **Base** **Model** **and** **Datasets** We follow the experimental setup of Snorkel [5], a model that utilizes
> iterative DPO to achieve state-of-the-art performance on AlpacaEval benchmarks. Specifically,
> we use Mistral-7B-Instruct-v0.2 as our base model [6] . Mistral-7B-Instruct-v0.2 is an instruction
> fine-tuned version of Mistral-7B-v0.2 model (Jiang et al., 2023a). We also adopt Ultrafeedback (Cui
> et al., 2023) as our source of prompts which includes around 60k prompts from diverse resources.
> During generation, we follow the standard chat template of Mistral-7B. To avoid overfitting during
> the fine-tuning, we split the dataset into three portions and use only one portion per iteration.
> These settings were also adopted by training the model Snorkel-Mistral-PairRM-DPO [7] (Snorkel).
> We follow the splitting in Snorkel for a fair comparison. Additionally, we use Llama-3-8B-Instruct [8]
> 
> as a stronger base model along with the same preference dataset and data splitting.
> 
> 
> **Preference** **Model** We employ PairRM (Jiang et al., 2023b), an efficient pair-wise preference
> model of size 0.4B. PairRM is based on DeBERTA-V3 (He et al., 2021) and trained on high-quality
> human-preference datasets. Results on benchmarks like Auto-J Pairwise dataset (Li et al., 2023a)
> show that it outperforms most of the language-model-based reward models and performs comparably
> with larger reward models like UltraRM-13B (Cui et al., 2023). We refer the readers to the homepage
> on Huggingface [9] for detailed benchmark results. We therefore keep PairRM as our ranking model
> following Snorkel for a balance between accuracy and efficiency.
> Specifically, PairRM will output a “relative reward” _s_ ( **y** _,_ **y** _[′]_ ; **x** ) that reflects the strength difference
> between **y** and **y** _[′]_, i.e.,
> 
> 
> exp( _s_ ( **y** _,_ **y** _[′]_ ; **x** ))
> P( **y** _≻_ **y** _[′]_ _|_ **x** ) =
> 1 + exp( _s_ ( **y** _,_ **y** _[′]_ ; **x** )) _[.]_
> 
> 
> Unlike the Bradley-Terry-based reward model, PairRM only assigns the relative reward which is not
> guaranteed to be transitive (i.e., _s_ ( **y** 1 _,_ **y** 2; **x** ) + _s_ ( **y** 2 _,_ **y** 3; **x** ) _̸_ = _s_ ( **y** 1 _,_ **y** 3; **x** )). So it indeed models the
> general preference.
> 
> 
> **Response** **Generation** **and** **Selection** During the generation phase in each iteration, we use top
> _p_ = 1 _._ 0 and temperature 1 _._ 0 to sample from the current policy. We sample with different random
> seeds to get _K_ = 5 different responses for each prompt. Previous works utilizing Iterative DPO
> choose 2 responses to form a pair for each prompt. For a fair comparison, we do not include all
> _K_ = 5 responses in the preference data but choose two responses among them. Following Snorkel,
> 
> 
> 5 `[https://huggingface.co/snorkelai/Snorkel-Mistral-PairRM-DPO](https://huggingface.co/snorkelai/Snorkel-Mistral-PairRM-DPO)`
> 6 `[https://huggingface.co/mistralai/Mistral-7B-Instruct-v0.2](https://huggingface.co/mistralai/Mistral-7B-Instruct-v0.2)`
> 7 `[https://huggingface.co/snorkelai/Snorkel-Mistral-PairRM-DPO](https://huggingface.co/snorkelai/Snorkel-Mistral-PairRM-DPO)`
> 8 `[https://huggingface.co/meta-llama/Meta-Llama-3-8B-Instruct](https://huggingface.co/meta-llama/Meta-Llama-3-8B-Instruct)`
> 9 `[https://huggingface.co/llm-blender/PairRM](https://huggingface.co/llm-blender/PairRM)`
> 
> 
> 13
> 
> 
> we choose the winner **y** _w_ and loser **y** _l_ to be the response with the _highest_ and _lowest_ PairRM score,
> which is defined for each response **y** _i_ as:
> 
> 
> 
> _s_ PairRM( **y** _i_ ; **x** ) := [1]
> 
> _K_
> 
> 
> 
> _K_
> 
> 
> _s_ ( **y** _i,_ **y** _k_ ; **x** ) _._
> 
> _k_ =1
> 
> 
> 
> **Probability** **Estimation** We then estimate the win rate over the distribution by the average win
> rate over all the sampled responses as explained in (4.5):
> 
> 
> 
> _P_ �( **y** _i_ _≻_ _πt|_ **x** ) = [1]
> _K_
> 
> 
> 
> _K_
> 
> 
> P( **y** _i_ _≻_ **y** _k|_ **x** ) _, ∀i ∈_ [ _K_ ] _._
> 
> _k_ =1
> 
> 
> 
> **Hyperparameter** **Tuning** The experiments are conducted on 8 _×_ Nvidia A100 GPUs. For
> SPPO, we trained three iterations in total. In each iteration, we selected the model trained on
> the first epoch of the 20k prompts from UltraFeedback to proceed to the next iteration. For both
> Mistral-7B-Instruct-v0.2 and Llama-3-8B-Instruct, the global training batch size is set to 64, and _η_
> is set to 1 _e_ 3. The learning rate schedule is determined by the following hyperparameters: learning
> rate=5.0e-7, number of total training epochs=18, warmup ratio=0.1, linear schedule. The best
> hyper-parameters for each model are selected by the average win rate (judged by PairRM-0.4B)
> on a hold-out subset of Ultrafeedback as the metric. For more details on the win-rate comparison
> using PairRM as a judge, please refer to Section 5.2 and Figure 3.
> 
> 
> **Baselines** We evaluate the following base models as well as baseline methods for fine-tuning
> LLMs:
> 
> 
> - Mistral-7B-Instruct-v0.2: Mistral-7B-Instruct-v0.2 is an instruction fine-tuned version of Mistral7B-v0.2 model (Jiang et al., 2023a). It is the starting point of our algorithm.
> 
> 
> - Snorkel (Mistral-PairRM-DPO): We directly evaluate the uploaded checkpoint on HuggingFace [10] .
> This model is obtained by three rounds of iterative DPO from Mistral-7B-Instruct-v0.2.
> 
> 
> - (Iterative) DPO: We also implement the iterative DPO algorithm by ourselves. The experimental
> settings and model selection schemes align with those used for SPPO, except for the adoption
> of the DPO loss function as defined in (4.13). Hyperparameters are optimized to maximize the
> average win-rate assessed by PairRM at each iteration. Note that the practical algorithm in
> Rosset et al. (2024) is essentially the same as iterative DPO.
> 
> 
> - (Iterative) IPO: We implement the iterative IPO algorithm by ourselves. The experimental setting
> and the model selection scheme is the same as iterative DPO, except that the loss function is
> the IPO loss (4.14). For fair comparison, hyperparameters for IPO is also selected by evaluation
> using the average PairRM win-rate on the hold-out subset of Ultrafeedback.
> 
> 
> - Self-rewarding LM: Yuan et al. (2024) proposed to prompt the LLM itself as a preference judge
> to construct new preference pairs and iteratively fine-tune the LLM with the DPO algorithm.
> We use the AlpacaEval 2.0 win rate reported by Yuan et al. (2024) for comparison. Note that
> Self-rewarding LM is a trained from Llama 2 70B.
> 
> 
> 10 `[https://huggingface.co/snorkelai/Snorkel-Mistral-PairRM-DPO](https://huggingface.co/snorkelai/Snorkel-Mistral-PairRM-DPO)`
> 
> 
> 14
> 
> 
> - Llama-3-8B-Instruct: Llama-3-8B-Instruct is an instruction-tuned model optimized for dialogue
> use cases and outperforms many of the available open-source chat models on common industry
> benchmarks.
> 
> 
> **Benchmarks** Following previous works, we use AlpacaEval 2.0 (Dubois et al., 2024a), ArenaHard(Li et al., 2024), MT-Bench (Zheng et al., 2024), and Open LLM Leaderboard (Beeching et al.,
> 2023a) as our evaluation benchmarks.
> 
> 
> - **AlpacaEval** **2.0** is an LLM-based automatic evaluation benchmark. It employs AlpacaFarm
> (Dubois et al., 2024b) as its prompts set composed of general human instructions. The model
> responses and the reference response generated by GPT-4-Turbo are fed into a GPT-4-Turbo-based
> annotator to be judged. We follow the standard approach and report the win rate over the
> reference responses.
> 
> 
> - **Arena-Hard** (Li et al., 2024) is a high-quality benchmark that claims to be harder and has
> the highest correlation and separability to Chatbot Arena among popular open-ended LLM
> benchmarks including AlpacaEval 2.0. We evaluate our models Mistral-PairRM-SPPO and the
> baseline models.
> 
> 
> - **MT-Bench** (Zheng et al., 2024) is a collection of 80 high-quality multi-turn open-ended questions.
> The questions cover topics like writing, role-playing, math, coding, etc.. The generated answer is
> judged by GPT-4 and given a score directly without pairwise comparison.
> 
> 
> - **Open** **LLM** **Leaderboard** (Beeching et al., 2023a) consists of six datasets, each of which
> focuses on a facet of language model evaluation. In detail, the evaluation rubric includes math
> problem-solving, language understanding, human falsehood mimicking, and reasoning. We follow
> the standard evaluation process and use in-context learning to prompt the language model and
> compute the average score over six datasets to measure the performance.
> 
> 
> **5.2** **Experimental** **Results**
> 
> 
> **Evaluation** **using** **GPT-4** **as** **a** **judge** Human evaluation remains the benchmark for quality
> and accuracy (Askell et al., 2021; Ouyang et al., 2022). However, due to its limitations in scalability
> and reproducibility, we explore the alternative approach of using the advanced capabilities of
> GPT-4 (OpenAI et al., 2023) as an automatic evaluation tool. We conduct GPT-4-based automatic
> evaluation on AlpacaEval 2.0 (Li et al., 2023b), MT-Bench (Zheng et al., 2023), and Arena-Hard (Li
> et al., 2024) to measure the chatbot capability of our model. The results can be found in Table 1
> for AlpacaEval 2.0, Figure 2 (left) for MT-Bench, and Figure 2 (right) for Arena-Hard. We found
> that the performance of SPPO models consistently improves throughout all iterations.
> Table 1 (AlpacaEval 2.0) shows the win rate over the GPT-4-Turbo baseline of different models
> on 805 prompts. We also include one column indicating the length-controlled win rate, and one
> column on the average length of each model, to account for the tendency of the LLM-based judge
> to favor longer sequence outputs - an issue colloquially termed the ”reward hacking” phenomenon.
> 
> 
> 15
> 
> 
> Table 1: AlpacaEval 2.0 evaluation of various models (detailed in Baselines) in terms of both normal
> and length-controlled (LC) win rates in percentage (%). Mistral-7B-SPPO Iter3 model achieves
> the highest LC win rate of 28.53% and a normal win rate of 31.02%. SPPO demonstrates steady
> performance gains across iterations and outperforms other baselines which show a tendency to
> produce longer responses. Additionally, re-ranking with the PairRM reward model (best-of-16) at
> test time consistently enhances the performance across all models and SPPO (best-of-16) achieves
> high win rate _without_ _strong_ _external_ _supervision_ _like_ _GPT-4_ . We additionally include the results
> obtained from fine-tuning Llama-3-8B-Instruct, which also show steady performance improvement.
> 
> 
> AlpacaEval 2.0
> Model
> LC Win Rate Win Rate Avg. Len
> 
> 
> Mistral-7B-Instruct-v0.2 17.11 14.72 1676
> Mistral-7B-Instruct-v0.2 (best-of-16) 22.45 17.94 1529
> 
> 
> Snorkel (Mistral-PairRM-DPO) 26.39 30.22 2736
> Snorkel (Mistral-PairRM-DPO best-of-16) 29.97 34.86 2616
> 
> 
> Self-Rewarding 70B Iter1    - 9.94 1092
> Self-Rewarding 70B Iter2    - 15.38 1552
> Self-Rewarding 70B Iter3    - 20.44 2552
> 
> 
> Mistral-7B-DPO Iter1 23.81 20.44 1723
> Mistral-7B-DPO Iter2 24.23 24.46 2028
> Mistral-7B-DPO Iter3 22.30 23.39 2189
> 
> 
> Mistral-7B-IPO Iter1 23.78 20.77 1693
> Mistral-7B-IPO Iter2 21.08 23.38 2660
> Mistral-7B-IPO Iter3 20.06 22.47 2760
> 
> 
> Llama-3-8B-Instruct 22.92 22.57 1899
> 
> 
> According to the table, Mistral-7B-SPPO Iter3 has the highest win rate, 28.52% for the lengthcontrolled version, and 31.02% for the overall win rate.
> The performance gains over previous iterations are 7.69% (Mistral-7B-Instruct _→_ Iter1), 2.10%
> (Iter1 _→_ Iter2), and 1.64% (Iter2 _→_ Iter3), respectively, indicating steady improvements across
> iterations, as illustrated in Figure 1. We also apply SPPO to a stronger baseline model, i.e.,
> Llama-3-8B-Instruct, and the fine-tuned model Llama-3-8B-SPPO has a higher length-controlled
> 
> 
> 16
> 
> 
> Table 2: AlpacaEval 2.0 leaderboard results of both normal and length-controlled (LC) win rates in
> percentage (%). Mistral-7B-SPPO can outperform larger models and Mistral-7B-SPPO (best-of-16)
> can outperform proprietary models such as GPT-4(6/13). Llama-3-8B-SPPO exhibits even better
> performance.
> 
> 
> AlpacaEval 2.0
> Model
> LC. Win Rate Win Rate
> 
> 
> 
> 35
> 
> 
> 30
> 
> 
> 25
> 
> 
> 20
> 
> 
> 
> |Col1|Col2|Col3|Col4|Col5|Col6|
> |---|---|---|---|---|---|
> |||~~GPT-4 0314~~||||
> |||<br>Snorkel (Mistral-Pair<br>Mistral-7B-Instruct-v<br>Mistral-7B-DPO<br>|RM-DPO)<br>0.2|||
> |||||||
> |||||||
> |||||||
> |||~~Mistral-7B-IPO~~<br>Mistral-7B-SPPO||||
> |||||||
> |||||||
> |||||||
> |||||||
> |||||||
> |||||||
> 
> 
> (a)
> 
> 
> 
> 30
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
> 
> |Col1|Col2|Col3|Col4|Col5|Col6|
> |---|---|---|---|---|---|
> |||||||
> |||||||
> |||||||
> |||~~GP~~<br>Sn<br>Mis<br>~~Se~~|~~T-4 0314~~<br>orkel (Mistral-PairRM-DPO<br>tral-7B-Instruct-v0.2<br>~~f-Rewarding 70B~~|)||
> |||<br>Mis<br>Mis<br>mi|<br>tral-7B-DPO<br>tral-7B-IPO<br>tral-7B-SPPO|||
> |||||||
> |||||||
> 
> 
> (b)
> 
> 
> 
> Figure 1: Win Rate against GPT-4-Turbo with (a) and without (b) Length Controlling (LC) on
> AlpacaEval 2.0. SPPO demonstrates steady improvements on both LC and raw win rates.
> 
> 
> win rate 38.77% and overall win rate 39.85%. The performance gains are more significant: 8.81%
> (Llama-3-8B-Instruct _→_ Iter1), 3.42% (Iter1 _→_ Iter2), and 3.62% (Iter2 _→_ Iter3), summing up to a
> total gain of 15.85%.
> Additionally, the result indicates that SPPO achieves superior performance compared to the
> iterative variants of DPO and IPO. The length-controlled win rate for SPPO reaches 28.53%,
> 
> 
> 17
> 
> 
> Model Arena-Hard-Auto-v0.1
> 
> 
> Mistral-7B-Instruct 12.6
> 
> 
> Snorkel (Mistral-PairRM-DPO) 20.7
> 
> 
> |Model|MT-Bench<br>1st Turn 2nd Turn Average|Col3|
> |---|---|---|
> |Mistral-7B-Instruct-v0.2<br>Snorkel (Mistral-PairRM-DPO)|7.78<br>7.25<br>7.83<br>7.33|7.51<br>7.58|
> |Mistral-7B-DPO Iter1<br>Mistral-7B-DPO Iter2<br>Mistral-7B-DPO Iter3|7.45<br>6.58<br>7.57<br>6.56<br>7.49<br>6.69|7.02<br>7.06<br>7.09|
> |Mistral-7B-SPPO Iter1<br>Mistral-7B-SPPO Iter2<br>Mistral-7B-SPPO Iter3|7.63<br>6.79<br>7.90<br>7.08<br>7.84<br>7.34|7.21<br>7.49<br>**7.59**|
> 
> 
> 
> Figure 2: **MT-Bench** **&** **Arena-Hard** **Evaluation.** Left: Mistral-7B-SPPO Iter3 outperforms
> all baseline models by achieving an average score of 7.59 in MT-Bench. Despite initial drops in
> performance in the first two iterations, SPPO Iter3 improves upon the base model by the final
> iteration. Right: Mistral-7B-SPPO Iter3 outperforms the baseline model Snorkel(Mistral-PairRMDPO) in Arena-Hard. The improvement across different iterations is consistent.
> 
> 
> outperforming the DPO’s best rate of 26.39% (by Snorkel) and IPO’s rate of 25.45%. Notably, while
> DPO and IPO training tend to significantly increase the average output length—2736 and 2654,
> respectively—SPPO shows a more moderate length increase, moving from 1676 in the base model
> to 2163 at the third iteration. Finally, we present the best-of-16 results for each model, selected
> using the PairRM reward model. We find that re-ranking with the preference model at test time
> can consistently improve the performance of base model (Mistral-7B-Instruct-v0.2), DPO (Snorkel),
> and SPPO (Iter3) by 5.34%, 3.57%, and 3.6%, respectively. Notably, this shows that while SPPO
> significantly enhances model alignment using PairRM-0.4B as the sole external supervision, it has
> not resulted in over-optimization against the preference model (Gao et al., 2023).
> In Table 2, we compare SPPO on the AlpacaEval 2.0 leaderboard with other state-of-the-art AI
> chatbots. We found our SPPO model outperforms many competing models trained on proprietary
> alignment data (e.g., Claude 2, Gemini Pro, & Llama 3 8B Instruct). When applied to Llama 3
> 8B Instruct, our Llama-3-8B-SPPO exhibits an even higher win rate. With test-time reranking,
> Mistral-7B-SPPO Iter3 (best-of-16) is even competitive to GPT-4 0613 and Llama 3 70B Instruct.
> In Figure 2 (left), we evaluate the performance of SPPO on MT-Bench. We can see that
> Mistral-7B-SPPO Iter3 outperforms all baseline models, achieving an average score of 7.59. While
> we are not certain why the MT-Bench performance drops at the first two iterations, the performance
> of SPPO at the final iteration still improves over the base model.
> Arena-Hard (Li et al., 2024) contains 500 challenging user queries and follow the same evaluation
> method as AlpacaEval 2.0. In Figure 2 (right), we evaluate the performance of SPPO on Arena-Hard.
> We can see that Mistral-7B-SPPO exhibits a steady performance gain across iterations.Mistral-7BSPPO Iter 3 outperforms the baseline models, achieving an average score of 23.3.
> 
> 
> **Open LLM Leaderboard** We further evaluate the capabilities of SPPO models using Huggingface
> Open LLM Leaderboard (Beeching et al., 2023b). This leaderboard encompasses 6 different datasets,
> each focusing on a specific capability of LLMs: Arc (Clark et al., 2018), HellaSwag (Zellers et al.,
> 2019), Winogrande (Sakaguchi et al., 2021), MMLU (Hendrycks et al., 2020), TruthfulQA (Lin et al.,
> 2021), and GSM8k (Cobbe et al., 2021). The models are prompted with zero or few-shot exemplars.
> 
> 
> 18
> 
> 
> Table 3: **Open** **LLM** **Leaderboard** **Evaluation** . SPPO fine-tuning improves the base model’s
> performance on different tasks, reaching a state-of-the-art average score of 66.75 for Mistral-7B
> and 70.29 for Llama-3-8B. For Mistral-7B, subsequent iterations of DPO, IPO, and SPPO see
> a decline in performance. It is possible that aligning with human preferences (simulated by the
> PairRM preference model in our study) may not always enhance, and can even detract from, overall
> performance.
> 
> 
> Models Arc TruthfulQA WinoGrande GSM8k HellaSwag MMLU Average
> 
> 
> Mistral-7B-Instruct-v0.2 63.65 66.85 77.98 41.93 84.89 59.15 65.74
> 
> 
> Snorkel 66.04 70.86 77.74 36.77 85.64 60.83 66.31
> 
> 
> Mistral-7B-DPO Iter1 63.14 68.39 77.19 40.33 85.25 59.41 65.62
> Mistral-7B-DPO Iter2 64.16 67.84 76.09 39.95 85.23 59.03 65.38
> Mistral-7B-DPO Iter3 65.19 67.89 77.27 32.30 85.49 59.00 64.52
> 
> 
> Mistral-7B-IPO Iter1 64.68 68.60 77.98 43.75 85.08 59.04 66.52
> Mistral-7B-IPO Iter2 62.12 66.30 77.51 39.20 83.15 59.70 64.66
> Mistral-7B-IPO Iter3 62.97 67.12 77.51 37.45 83.69 59.57 64.72
> 
> 
> Llama-3-8B-Instruct 62.29 51.65 76.09 75.89 78.73 65.59 68.37
> 
> 
> The results, presented in Table 3, demonstrate that SPPO can enhance the performance of the
> base model on Arc, TruthfulQA, and GSM8k, and achieve the state-of-the-art performance with an
> averagte score of 66.75. However, these improvements do not hold in subsequent alignment iterations:
> DPO, IPO, and SPPO’s performance declines after the first or second iterations. This limitation
> may be attributed to the “alignment tax” phenomenon (Askell et al., 2021), which suggests that
> aligning with human preferences (simulated by PairRM preference in our study) might not improve
> or even hurt the general performance. Improving language model capabilities through alignment
> iterations remains a topic for future research, and we posit that incorporating high-quality SFT
> annotations (Chen et al., 2024) could play a significant role in this endeavor.
> 
> 
> **Evaluation** **using** **PairRM** **as** **a** **judge** As SPPO identifies the von Neumann winner (see (3.3))
> in a two-player constant-sum game, we examine the pairwise preferences among SPPO models and
> other baselines. The pairwise win rates, measured by PairRM, are depicted in Figure 3. We observe
> that in all algorithms—namely DPO, IPO, and SPPO—the newer model iterations surpass the
> previous ones. For example, SPPO Iteration 3 outperforms SPPO Iteration 2. Both SPPO and IPO
> consistently outperform DPO across all iterations. While SPPO is superior to IPO in the first two
> iterations, IPO exceeds SPPO in performance during the final iteration. Considering the superior
> performance of SPPO in standard benchmarks evaluated by GPT-4 or against ground-truth answers
> (e.g., AlpacaEval 2.0, MT-Bench, and Open LLM Leaderboard), along with IPO’s tendency to
> 
> 
> 19
> 
> 
> IPO Iter3
> 
> 
> SPPO Iter3
> 
> 
> Snorkel (Mistral-PairRM-DPO)
> 
> 
> DPO Iter3
> 
> 
> SPPO Iter2
> 
> 
> IPO Iter2
> 
> 
> DPO Iter2
> 
> 
> SPPO Iter1
> 
> 
> DPO Iter1
> 
> 
> IPO Iter1
> 
> 
> Mistral-7B-Instruct-v0.2
> 
> 
> 
> 
> 
> 0.8
> 
> 
> 0.7
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
> 
> 0.2
> 
> |0.5|00|0.5|52 0.5|Col5|72 0.5|Col7|77 0.6|Col9|31 0.6|Col11|56 0.6|Col13|64 0.7|Col15|19 0.7|Col17|13 0.7|Col19|41 0.8|Col21|09|
> |---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
> |||||||||||||||||||||||
> |~~0.~~|~~48~~|~~0.~~|~~00~~|~~0.~~|~~20 0.~~|~~20 0.~~|~~23~~<br>~~0.~~|~~23~~<br>~~0.~~|~~77~~<br>~~0.~~|~~77~~<br>~~0.~~|~~01~~<br>~~0.~~|~~01~~<br>~~0.~~|~~27~~<br>~~0.~~|~~27~~<br>~~0.~~|~~76 0.~~|~~76 0.~~|~~82~~<br>~~0.~~|~~82~~<br>~~0.~~|~~06~~<br>~~0.~~|~~06~~<br>~~0.~~|~~81~~|
> |||||||||||||||||||||||
> |||||||||||||||||||||||
> |~~0.~~<br>|~~28~~<br>~~0.~~<br><br>|~~28~~<br>~~0.~~<br><br>|~~80~~<br>~~0.~~<br><br>|~~0.~~|~~00 ~~|~~0.~~|~~96~~<br>~~0.~~<br><br>|~~96~~<br>~~0.~~<br><br>|~~68~~<br>~~0.~~<br><br>|~~68~~<br>~~0.~~<br><br>|~~80~~<br>~~0.~~<br><br>|~~80~~<br>~~0.~~<br><br>|~~09~~<br>~~0.~~<br><br>|~~09~~<br>~~0.~~<br><br>|~~59 0.~~<br>|~~59 0.~~<br>|~~52~~<br>~~0.~~<br><br>|~~52~~<br>~~0.~~<br><br>|~~73~~<br>~~0.~~<br><br>|~~73~~<br>~~0.~~<br><br>|~~58~~<br>|
> |~~0.~~<br>|~~28~~<br>~~0.~~<br><br>|~~28~~<br>~~0.~~<br><br>|~~80~~<br>~~0.~~<br><br>|~~0.~~||||||||||||||||||
> |~~0.~~<br>|~~23~~<br>~~0.~~<br><br>|~~23~~<br>~~0.~~<br><br>|~~77~~<br>~~0.~~<br><br>|~~77~~<br>~~0.~~<br><br>|~~04 0.~~<br>|~~0.~~|~~00~~|~~0.~~|~~52~~<br>~~0.~~<br><br>|~~52~~<br>~~0.~~<br><br>|~~77~~<br>~~0.~~<br><br>|~~77~~<br>~~0.~~<br><br>|~~08~~<br>~~0.~~<br><br>|~~08~~<br>~~0.~~<br><br>|~~36 0.~~<br>|~~36 0.~~<br>|~~31~~<br>~~0.~~<br><br>|~~31~~<br>~~0.~~<br><br>|~~67~~<br>~~0.~~<br><br>|~~67~~<br>~~0.~~<br><br>|~~50~~<br>|
> |~~0.~~<br>|~~23~~<br>~~0.~~<br><br>|~~23~~<br>~~0.~~<br><br>|~~77~~<br>~~0.~~<br><br>|~~77~~<br>~~0.~~<br><br>|~~04 0.~~<br>|~~0.~~||||||||||||||||
> |~~0.~~<br>|~~69~~<br>~~0.~~<br><br>|~~69~~<br>~~0.~~<br><br>|~~23~~<br>~~0.~~<br><br>|~~23~~<br>~~0.~~<br><br>|~~32 0.~~<br>|~~32 0.~~<br>|~~48~~<br>~~0.~~<br><br>|~~0.~~|~~00~~|~~0.~~|~~17~~<br>~~0.~~<br><br>|~~17~~<br>~~0.~~<br><br>|~~51~~<br>~~0.~~<br><br>|~~51~~<br>~~0.~~<br><br>|~~95 0.~~<br>|~~95 0.~~<br>|~~98~~<br>~~0.~~<br><br>|~~98~~<br>~~0.~~<br><br>|~~31~~<br>~~0.~~<br><br>|~~31~~<br>~~0.~~<br><br>|~~22~~<br>|
> |~~0.~~<br>|~~69~~<br>~~0.~~<br><br>|~~69~~<br>~~0.~~<br><br>|~~23~~<br>~~0.~~<br><br>|~~23~~<br>~~0.~~<br><br>|~~32 0.~~<br>|~~32 0.~~<br>|~~48~~<br>~~0.~~<br><br>|~~0.~~||||||||||||||
> |~~0.~~<br>~~0.~~|~~44~~<br>~~0.~~<br>~~36~~<br>~~0.~~|~~44~~<br>~~0.~~<br>~~36~~<br>~~0.~~|~~99~~<br>~~0.~~<br>~~73~~<br>~~0.~~|~~99~~<br>~~0.~~<br>~~73~~<br>~~0.~~|~~20 0.~~<br>~~91 0.~~|~~20 0.~~<br>~~91 0.~~|~~23~~<br>~~0.~~<br>~~92~~<br>~~0.~~|~~23~~<br>~~0.~~<br>~~92~~<br>~~0.~~|~~83~~<br>~~0.~~<br>~~49~~<br>~~0.~~|~~0.~~|~~00~~|~~0.~~|~~30~~<br>~~0.~~<br>~~00~~<br>~~0.~~|~~30~~<br>~~0.~~<br>~~00~~<br>~~0.~~|~~74 0.~~<br>~~50 0.~~|~~74 0.~~<br>~~50 0.~~|~~77~~<br>~~0.~~<br>~~62~~<br>~~0.~~|~~77~~<br>~~0.~~<br>~~62~~<br>~~0.~~|~~13~~<br>~~0.~~<br>~~87~~<br>~~0.~~|~~13~~<br>~~0.~~<br>~~87~~<br>~~0.~~|~~07~~<br>~~70~~|
> |~~0.~~<br>~~0.~~|~~44~~<br>~~0.~~<br>~~36~~<br>~~0.~~|~~44~~<br>~~0.~~<br>~~36~~<br>~~0.~~|~~99~~<br>~~0.~~<br>~~73~~<br>~~0.~~|~~99~~<br>~~0.~~<br>~~73~~<br>~~0.~~|~~20 0.~~<br>~~91 0.~~|~~20 0.~~<br>~~91 0.~~|~~23~~<br>~~0.~~<br>~~92~~<br>~~0.~~|~~23~~<br>~~0.~~<br>~~92~~<br>~~0.~~|~~83~~<br>~~0.~~<br>~~49~~<br>~~0.~~|~~0.~~|~~70~~|~~0.~~|~~00~~|~~00~~|~~00~~|~~00~~|~~00~~|~~00~~|~~00~~|~~00~~|~~00~~|
> |~~0.~~|~~81~~<br>~~0.~~|~~81~~<br>~~0.~~|~~24~~<br>~~0.~~|~~24~~<br>~~0.~~|<br>~~41 0.~~|<br>~~41 0.~~|~~64~~<br>~~0.~~|~~64~~<br>~~0.~~|~~05~~<br>~~0.~~|~~05~~<br>~~0.~~|~~26~~<br>~~0.~~||||<br>~~00 0.~~|<br>~~00 0.~~|~~14~~<br>~~0.~~|~~14~~<br>~~0.~~|~~40~~<br>~~0.~~|~~40~~<br>~~0.~~|~~51~~|
> |~~0.~~|~~81~~<br>~~0.~~|~~81~~<br>~~0.~~|~~24~~<br>~~0.~~|~~24~~<br>~~0.~~|<br>~~41 0.~~|<br>~~41 0.~~|~~64~~<br>~~0.~~|~~64~~<br>~~0.~~|~~05~~<br>~~0.~~|~~05~~<br>~~0.~~|~~26~~<br>~~0.~~||~~50~~|~~0.~~|~~00 ~~|~~00 ~~|~~00 ~~|~~00 ~~|~~00 ~~|~~00 ~~|~~00 ~~|
> ||||||<br>|<br>||||||||||||||||
> ||||||<br>|<br>||||||||||||||||
> |~~0.~~<br>|~~87~~<br>~~0.~~<br><br>|~~87~~<br>~~0.~~<br><br>|~~18~~<br>~~0.~~<br><br>|~~18~~<br>~~0.~~<br><br>|~~48 0.~~<br>|~~48 0.~~<br>|~~69~~<br>~~0.~~<br><br>|~~69~~<br>~~0.~~<br><br>|~~02~~<br>~~0.~~<br><br>|~~02~~<br>~~0.~~<br><br>|~~23~~<br>~~0.~~<br><br>|~~23~~<br>~~0.~~<br><br>|~~38~~<br>~~0.~~<br><br>|~~38~~<br>~~0.~~<br><br>|~~86 0.~~<br>|~~0.~~|~~00~~|~~0.~~|~~26~~<br>~~0.~~<br><br>|~~26~~<br>~~0.~~<br><br>|~~33~~<br>|
> |~~0.~~<br>|~~87~~<br>~~0.~~<br><br>|~~87~~<br>~~0.~~<br><br>|~~18~~<br>~~0.~~<br><br>|~~18~~<br>~~0.~~<br><br>|~~48 0.~~<br>|~~48 0.~~<br>|~~69~~<br>~~0.~~<br><br>|~~69~~<br>~~0.~~<br><br>|~~02~~<br>~~0.~~<br><br>|~~02~~<br>~~0.~~<br><br>|~~23~~<br>~~0.~~<br><br>|~~23~~<br>~~0.~~<br><br>|~~38~~<br>~~0.~~<br><br>|~~38~~<br>~~0.~~<br><br>|~~86 0.~~<br>|~~0.~~||||||
> |~~0.~~<br>|~~59~~<br>~~0.~~<br><br>|~~59~~<br>~~0.~~<br><br>|~~94~~<br>~~0.~~<br><br>|~~94~~<br>~~0.~~<br><br>|~~27 0.~~<br>|~~27 0.~~<br>|~~33~~<br>~~0.~~<br><br>|~~33~~<br>~~0.~~<br><br>|~~69~~<br>~~0.~~<br><br>|~~69~~<br>~~0.~~<br><br>|~~87~~<br>~~0.~~<br><br>|~~87~~<br>~~0.~~<br><br>|~~13~~<br>~~0.~~<br><br>|~~13~~<br>~~0.~~<br><br>|~~60 0.~~<br>|~~60 0.~~<br>|~~74~~<br>~~0.~~<br><br>|~~0.~~|~~00~~|~~0.~~|~~13~~|
> |~~0.~~<br>|~~59~~<br>~~0.~~<br><br>|~~59~~<br>~~0.~~<br><br>|~~94~~<br>~~0.~~<br><br>|~~94~~<br>~~0.~~<br><br>|~~27 0.~~<br>|~~27 0.~~<br>|~~33~~<br>~~0.~~<br><br>|~~33~~<br>~~0.~~<br><br>|~~69~~<br>~~0.~~<br><br>|~~69~~<br>~~0.~~<br><br>|~~87~~<br>~~0.~~<br><br>|~~87~~<br>~~0.~~<br><br>|~~13~~<br>~~0.~~<br><br>|~~13~~<br>~~0.~~<br><br>|~~60 0.~~<br>|~~60 0.~~<br>|~~74~~<br>~~0.~~<br><br>|~~0.~~||||
> |~~0.~~|~~91~~<br>~~0.~~|~~91~~<br>~~0.~~|~~19~~<br>~~0.~~|~~19~~<br>~~0.~~|~~42 0.~~|~~42 0.~~|~~50~~<br>~~0.~~|~~50~~<br>~~0.~~|~~78~~<br>~~0.~~|~~78~~<br>~~0.~~|~~93~~<br>~~0.~~|~~93~~<br>~~0.~~|~~30~~<br>~~0.~~|~~30~~<br>~~0.~~|~~49 0.~~|~~49 0.~~|~~67~~<br>~~0.~~|~~67~~<br>~~0.~~|~~87~~|~~0.~~|~~00~~|
> 
> 
> 
> Figure 3: Pairwise win rates among base model (Mistral-7B-Instruct-v0.2), DPO models, IPO
> models, and SPPO models using **PairRM-0.4B** as a judge, which may favor models with longer
> outputs. On benchmarks with more powerful judge models (e.g., GPT-4), such as AlpacaEval 2.0
> and MT-Bench, SPPO outperforms other baseline algorithms by a large margin.
> 
> 
> produce longer sequence outputs (see Avg. Len in Table 1), we believe this is due to IPO exploiting
> the length bias in PairRM that favors longer sequences. Conversely, SPPO models benefit from a
> more robust regularization within a multiplicative weight update framework.
> 
> 
> **5.3** **Ablation** **Study**
> 
> 
> We study the effect of mini-batch size when estimating the win rate P( **y** _≻_ _πt|_ **x** ). Specifically, for
> each prompt, we still generate 5 responses and choose the winner **y** _w_ and loser **y** _l_ according to the
> PairRM score. When estimating the probability, we varies the batch size to be _K_ = 2 _,_ 3 _,_ 5. For
> _K_ = 2, we estimate P( **y** _≻_ _πt|_ **x** ) with only 2 samples **y** _w_ and **y** _l_ :
> 
> _P_ �( **y** _w_ _≻_ _πt|_ **x** ) = [P][(] **[y]** _[w]_ _[≻]_ **[y]** _[w][|]_ **[x]** [) +][ P][(] **[y]** _[w]_ _[≻]_ **[y]** _[l][|]_ **[x]** [)] = [1] _[/]_ [2 +][ P][(] **[y]** _[w]_ _[≻]_ **[y]** _[l][|]_ **[x]** [)] _,_
> 2 2
> 
> 
> and _P_ [�] ( **y** _l_ _≻_ _πt|_ **x** ) similarly. _K_ = 5 indicates the original setting we use.
> We compare the results on AlpacaEval 2.0, as shown in Figure 4. We find that the performance
> of SPPO is robust to the noise in estimating P( **y** _≻_ _πt|_ **x** ). While _K_ = 5 initially outperforms
> 
> 
> 20
> 
> 
> 28
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
> 18
> 
> 
> 
> Mini-Batch
> Iteration
> Size
> 
> 
> 
> AlpacaEval 2.0
> Win Rate Avg. Len
> LC. Raw (chars)
> 
> 
> 
> _K_ = 2
> 
> 
> 
> Iter1 23.85 23.53 1948
> Iter2 26.91 27.24 1999
> Iter3 28.26 28.22 1961
> 
> 
> 
> 
> |Col1|Col2|Col3|Col4|Col5|Col6|
> |---|---|---|---|---|---|
> |||||||
> |||||||
> |||||||
> |||||||
> ||||l-PairRM-DPO)<br>|l-PairRM-DPO)<br>||
> |||Snorkel (Mistra<br>|l-PairRM-DPO)<br>|l-PairRM-DPO)<br>|l-PairRM-DPO)<br>|
> |||~~Mistral-7B-Inst~~<br>SPPO (K=2)<br>|~~uct-v0.2~~|||
> |||~~SPPO (K=5)~~||||
> |||||||
> 
> 
> 
> Figure 4: AlpacaEval 2.0 evaluation on SPPO of different mini-batch size in terms of both normal
> and length-controlled (LC) win rates in percentage (%). _K_ = 2 _,_ 5 denote different mini-batch sizes
> when estimating the win rate P( **y** _≻_ _πt|_ **x** ).
> 
> 
> _K_ = 2 in the first iteration, the difference in their performance diminishes in subsequent iterations.
> Additionally, we observe that _K_ = 2 exhibits a reduced tendency to increase output length.
> 
> ### **6 Conclusions**
> 
> 
> This paper introduced Self-Play Preference Optimization(SPPO), an approach to fine-tuning Large
> Language Models (LLMs) from Human/AI Feedback. SPPO has demonstrated significant improvements over existing methods such as DPO and IPO across multiple benchmarks, including
> AlpacaEval 2.0, MT-Bench, Arena-Hard, and the Open LLM Leaderboard. By integrating a preference model and employing a new optimization objective, SPPO can align LLMs more closely with
> human preferences.
> **Limitations** Theoretically, approximating the optimal policy update via regression relies on the
> assumption that the model class is expressive enough and the generated data well cover the input
> space. Approximating the log-partition factor with a constant can help reduce variance only when it
> is close to the soft value function. The experiments are run on one dataset UltraFeedback and the
> models are tested on a few benchmarks due to limited computational resources, but the proposed
> methods can be further validated on more models, datasets, and benchmarks to have a holistic
> evaluation given more resources.
> 
> ### **Acknowledgement**
> 
> 
> We would like to thank Alekh Agarwal for his insightful comments that helped clarify the technical
> contributions of our work and its connection and distinction from SPO (Swamy et al., 2024). We
> would also like to thank Wen Sun for pointing out the concurrent work (Gao et al., 2024) and for
> the valuable discussion on the design choice of objective functions.
> 
> 
> 21
> 
> 
> ### **A Approximating the Normalizing Factor**
> 
> As discussed before, we replace the log-partition factor with a constant to avoid either estimating
> or predicting the log-partition factor. In hindsight, the approximation of the normalizing factor
> serves as a baseline for variance reduction, and does not need to be exact. Here we discuss the
> implicit assumptions and how we obtained an approximation based on different assumptions on
> human preference behaviour.
> We first consider the case where we have _K_ responses and then calculate the limit of _Zπ_  - _tK_ [(] **[x]** [)]
> when _K_ _→∞_ . We have two extreme cases:
> 
> 
> 1. The most “disordered” case: any preference is a fair coin flip
> 
> 
> 2. The most “ordered” case: there is a strict ordering among all responses.
> 
> 
> **The** **most** **“disordered”** **case** Specifically, we have _K_ different responses **y** 1 _,_ **y** 2 _, . . .,_ **y** _K_ for the
> given prompt **x** . Since we consider the general preference setting, we assume that the preference
> probability between **y** _i_ and **y** _j_ ( _i < j_ ) we observe is a fair coin toss:
> 
> 
> 
> P( **y** _i_ _≻_ **y** _j|_ **x** ) =
> 
> 
> 
> 
> 1 _,_ w.p. 1 _/_ 2 _,_
> 
> 0 _,_ w.p. 1 _/_ 2 _._
> 
> 
> 
> Note that for simplicity, we assumed that the _preference_ _probability_ follows the Bernoulli distribution,
> not the _preference_ _feedback_ . The preference feedback is deterministic since the preference probability
> is either 0 or 1. Assuming P( **y** _i_ _≻_ **y** _j|_ **x** ) follows any other 1 _/_ 2-mean distribution will yield the same
> constant.
> We define the random variable _pi,j_ := 2P( **y** _i_ _≻_ **y** _j|_ **x** ) _−_ 1 for convenience. In total, we have
> _K_ ( _K −_ 1) _/_ 2 independent Rademacher random variables for all _i < j_, and then we have _pj,i_ = _−pi,j_
> for all _i > j_ . For _i_ = _j_, _pi,j_ = 0. We also define _Xi_ = [�] _j_ _[K]_ =1 _[p][i,j][/K]_ [.]
> Given the setting and notations above, we have
> 
> 
> 
> P( **y** _i_ _≻_ _π_ - _t_ _[K][|]_ **[x]** [) =]
> 
> 
> 
> _K_
> 
> 
> P( **y** _i_ _≻_ **y** _j|_ **x** ) _/K_ = 1 _/_ 2 + _Xi._
> 
> _j_ =1
> 
> 
> 
> Furthermore,
> 
> 
> 
> _K_
> 
> 
> _e_ _[ηX][i]_ _/K._
> 
> _i_ =1
> 
> 
> 
> _Zπ_ - _tK_ [(] **[x]** [) =]
> 
> 
> 
> _K_
> 
> 
> exp( _η_ P( **y** _i_ _≻_ _π_  - _t_ _[K][|]_ **[x]** [))] _[/K]_ [=] _[ e][η/]_ [2] _[ ·]_
> _i_ =1
> 
> 
> 
> For any fixed _i_, we have the expectation as follows:
> 
> 
> 
> 
> - _K_
> 
>  
> 
> 
> =
> 
> 
> 
> E[ _e_ _[ηX][i]_ ] = E
> 
> 
> 
> _K_ 
> 
> _e_ _[ηp][i,j]_ _[/K]_
> 
> _j_ =1
> 
> 
> 
> _K_
> 
> 
> 
> 
> _K_ - _η/K_ _−η/K_
> 
> - - _e_ + _e_
> 
> E _e_ _[ηp][i,j]_ _[/K]_ [�] =
> 
> 2
> 
> _j_ =1
> 
> 
> 
> 2
> 
> 
> 
> 
> - _K−_ 1
> _,_
> 
> 
> 
> where the last equation comes from the definition of _pi,j_ (note that _pi,i_ = 0). The variance is:
> 
> 
> 
> 
>           - _e_ 2 _η/K_ + _e−_ 2 _η/K_
> Var[ _e_ _[ηX][i]_ ] = E[ _e_ [2] _[ηX][i]_ ] _−_ E[ _e_ _[ηX][i]_ ] [2] =
> 
> 2
> 
> 
> 22
> 
> 
> 
> 
> - _K−_ 1 - _eη/K_ + _e−η/K_
> 
> _−_
> 
> 2
> 
> 
> 
> �2 _K−_ 2
> _._
> 
> 
> Additionally, the covariance between _e_ _[ηX][i]_ and _e_ _[ηX][j]_ ( _i ̸_ = _j_ ) is:
> 
> 
> Cov( _e_ _[ηX][i]_ _, e_ _[ηX][j]_ ) = E[ _e_ _[ηX][i]_ [+] _[ηX][j]_ ] _−_ E[ _e_ _[ηX][i]_ ]E[ _e_ _[ηX][j]_ ]
> 
> 
> 
> _K_
> 
> 
> _pj,l/K_
> 
> _l_ =1
> 
> 
> 
> 
>   
> = E
> 
> 
> 
> 
> 
> _η_
> 
> 
> 
> _K_
> 
> 
> _pi,k/K_ + _η_
> 
> _k_ =1
> 
> 
> 
> ��
> 
> 
> 
> exp
> 
> 
> 
> 
> _−_ E[ _e_ _[ηX][i]_ ]E[ _e_ _[ηX][j]_ ]
> 
> 
> 
> 
>  - _eη/K_ + _e−η/K_
> =
> 
> 2
> 
> 
> 
> 
>  - _eη/K_ + _e−η/K_
> =
> 
> 2
> 
> 
> 
> �2 _K−_ 4
> 
> _−_ E[ _e_ _[ηX][i]_ ]E[ _e_ _[ηX][j]_ ]
> 
> 
> �2 _K−_ 4 - _eη/K_ + _e−η/K_
> 
> _−_
> 
> 2
> 
> 
> 
> �2 _K−_ 2
> _,_
> 
> 
> 
> where the third line holds because _pi,i_ = _pj,j_ = 0, _pi,j_ + _pj,i_ = 0, and the rest terms are i.i.d..
> One can check that when _K_ _→∞_, we have E[ _e_ _[ηX][i]_ ] _→_ 1, Var[ _e_ _[ηX][i]_ ] _→_ 0, and Cov( _e_ _[ηX][i]_ _, e_ _[ηX][j]_ ) _→_ 0.
> By Chebyshev’s inequality, [�] _i_ _[K]_ =1 _[e][ηX][i][/K]_ [will] [converge] [to] [1] [in] [probability.] [So] [we] [have]
> 
> 
> 
> _Zπ_             - _tK_ [(] **[x]** [) =] _[ e][η/]_ [2] _[ ·]_
> 
> 
> and we can approximate log _Zπ_ - _tK_ [(] **[x]** [)] [with] _[η/]_ [2.]
> 
> 
> 
> _K_
> 
> 
> _e_ _[ηX][i]_ _/K_ _→_ _e_ _[η/]_ [2] _,_
> 
> _i_ =1
> 
> 
> 
> **The** **most** **“ordered”** **case** We assume there is an ordering _σ_ ( _·_ ) among the _K_ different responses
> **y** 1 _,_ **y** 2 _, . . .,_ **y** _K_ for the given prompt **x** . The preference probability between **y** _i_ and **y** _j_ ( _i < j_ ) is:
> 
> 
> 
> P( **y** _i_ _≻_ **y** _j|_ **x** ) =
> 
> 
> 
> 
> 1 _,_ if _σ_ ( _i_ ) _< σ_ ( _j_ ) _,_
> 
> 0 _,_ if _σ_ ( _i_ ) _> σ_ ( _j_ ) _._
> 
> 
> 
> Again, the preference feedback is deterministic: as long as **y** _i_ is ranked higher than **y** _j_, **y** _i_ will always
> be preferred over **y** _j_ . The same responses still tie: P( **y** _i_ _≻_ **y** _i|_ **x** ) = 1 _/_ 2.
> Without loss of generality, we can assume **y** 1 _≺_ **y** 2 _≺_ **y** 3 _≺· · ·_ _≺_ **y** _K_ . Given the setting and
> notations above, we have
> 
> 
> 
> 
> [1 + 1] _[/]_ [2]
> 
> = _[i][ −]_ [1] _[/]_ [2]
> _K_ _K_
> 
> 
> 
> _,_
> _K_
> 
> 
> 
> P( **y** _i_ _≻_ _π_ - _t_ _[K][|]_ **[x]** [) =]
> 
> 
> 
> _K_
> 
> 
> 
> 
> 
> 
> P( **y** _i_ _≻_ **y** _j|_ **x** ) _/K_ = _[i][ −]_ [1 + 1] _[/]_ [2]
> 
> _K_
> 
> _j_ =1
> 
> 
> 
> because for **y** _i_, there are _i −_ 1 responses that are strictly worse, and **y** _i_ ties with itself.
> For the normalizing factor, we have
> 
> 
> _K_
> 
>              -             
>        log _Zπ_              - _tK_ [(] **[x]** [) = log] exp( _η_ P( **y** _≻_ _π_              - _t_ _[K][|]_ **[x]** [))] _[/K]_
> 
> _i_ =1
> 
> 
> 
> _K_
> 
>   
>  = log
> 
> 
> 
> _K_
> 
> 
> 
> 
>   
> 
> exp _η_ _[i][ −]_ [1] _[/]_ [2]
> 
> _K_
> 
> _i_ =1
> 
> 
> 
> 
> - _/K_
> 
> 
> 
> �� 1
> _→_ log
> 
> 0
> 
> = log _[e][η][ −]_ [1]
> 
> 
> 
> 1 
> exp( _ηx_ ) _dx_
> 0
> 
> 
> 
> _._
> _η_
> 
> 
> 
> 23
> 
> 
> where the third line (limiting) can be obtained by the squeeze theorem.
> For _η_ = 1, log _[e][η][−]_ [1] _≈_ 0 _._ 54 _η_ . For large _η_ _≈_ 1 _e_ 3 as we used in
> 
> 
> 
> For _η_ = 1, log _≈_ 0 _._ 54 _η_ . For large _η_ _≈_ 1 _e_ 3 as we used in the experiments, we have
> 
> _η_
> log _[e][η][−]_ [1] _≈_ _η_ .
> 
> 
> 
> _≈_ _η_ .
> _η_
> 
> 
> 
> **Choice** **of** _η_ Depending on how “disordered” the preference is, _η_ can vary between _η/_ 2 and _η_ . As
> this paper is partially motivated by human **intransitive** **and** **irrational** **preference** **behavior**,
> we chose to use _η/_ 2 to approximate log _Zπ_ - _tK_ [(] **[x]** [).] [Fine-tuning] [the] [coefficient] [of] [this] [constant] [as] [a]
> hyperparameter is also an option and can help improve performance on given dataset.
> 
> ### **B Proof of Theorem 4.1**
> 
> 
> _Proof_ _of_ _Theorem_ _4.1._ Suppose the optimization problem is realizable, we have exactly that
> 
> 
> _πt_ +1( **y** _|_ **x** ) _∝_ _πt_ ( **y** _|_ **x** ) exp( _η_ P( **y** _≻_ _πt|_ **x** )) _,_ for _t_ = 1 _,_ 2 _, . . . ._ (B.1)
> 
> 
> To prove that the exponential weight update can induce the optimal policy, we directly invoke a
> restated version of Theorem 1 in Freund and Schapire (1999):
> 
> 
> **Lemma** **B.1** (Theorem 1 in Freund and Schapire (1999), restated) **.** For any oracle P and for any
> sequence of mixed policies _µ_ 1 _, µ_ 2 _, . . ., µT_, the sequence of policies _π_ 1 _, π_ 2 _, . . ., πT_ produced by (B.1)
> satisfies:
> 
> 
> 
> _T_
> 
>    
> P( _πt_ _≺_ _µt_ ) _≤_ min
> _π_
> _t_ =1
> 
> 
> By setting _µt_ = _πt_, we have that
> 
> 
> 
> 
> - _η_
> 1 _−_ _e_ _[−][η]_
> 
> 
> 
> _T_
> 
> 
> 
> 
> 
> 
> P( _π_ _≺_ _µt_ ) + [KL(] _[π][∥][π]_ [0][)]
> 
> 1 _−_ _e_ _[−][η]_
> 
> _t_ =1
> 
> 
> 
> 1 _−_ _e_ _[−][η]_
> 
> 
> 
> 
> _._
> 
> 
> 
> _T_
> 
> 2 _[≤]_ [min] _π_
> 
> 
> 
> 
> - _ηT_
> 
> [P][(] _[π]_ _[≺]_ _[π]_ [¯] _[T]_ [ ) +] [KL(] _[π][∥][π]_ [0][)]
> 1 _−_ _e_ _[−][η]_ 1 _−_ _e_ _[−][η]_
> 
> 
> 
> 
> _,_
> 
> 
> 
> where the LHS comes from that P( _πt_ _≺_ _πt_ ) = 1 _/_ 2 and the RHS comes from that _T_ [1] - _Tt_ =1 [P][(] _[π]_ _[≺]_
> 
> _πt_ ) = P( _π_ _≺_ _π_ ¯ _t_ ). Now rearranging terms gives
> 
> 
> 
> 1 _−_ _e_ _[−][η]_
> 
> _≤_ min
> 2 _η_ _π_
> 
> 
> 
> 
> P( _π_ _≺_ _π_ ¯ _T_ ) + [KL(] _[π][∥][π]_ [0][)]
> 
> _ηT_
> 
> 
> 
> 
> _._
> 
> 
> 
> Note that _π_ 0 is an autoregressive model that is fully supported on a finite vocabulary ( _π_ 0( _yk_ +1 _|_ **x** _,_ **y** 1: _k_ )
> has non-zero probability for every token). Because its support is a large but finite set, _|_ log _π_ 0( _·_ ) _|_ is
> bounded from above. So we can naively bound the KL-divergence KL( _π∥π_ 0) _≤∥_ log _π_ 0( _·_ ) _∥∞_, which
> can be seen as a (large) constant.
> By choosing _η_ = _[∥]_ [log] _[ π]_ ~~_√_~~ [0][(] _[·]_ [)] _[∥][∞]_, we have
> 
> _T_
> 
> 
> 
> 1
> 
> ~~_√_~~
> 
> 2 _[−]_ _[∥]_ [log] 4 _[ π]_ [0] _T_ [(] _[·]_ [)] _[∥][∞]_
> 
> 
> 
> 
> _[∞]_ + _O_ ( _T_ _[−]_ [1] ) _≤_ min �P( _π_ _≺_ _π_ ¯ _T_ )� +
> 
> _T_ _π_
> 
> 
> 
> 
> ~~�~~ _∥_ log _π_ 0( _·_ ) _∥∞_
> 
> _,_
> _T_
> 
> 
> 
> ~~_√_~~
> 4
> 
> 
> 
> where the LHS comes from Taylor’s expansion [1] _[−][e][−][η]_
> 
> 
> 
> 
> [1]
> 
> 2 _[−]_ _[η]_ 4
> 
> 
> 
> 
> _[e]_ = [1]
> 
> 2 _η_ 2
> 
> 
> 
> where the LHS comes from Taylor’s expansion [1] _[−][e]_ = [1] [Notice] [that] [1] _[/]_ [2] [at] [the]
> 
> 2 _η_ 2 _[−]_ _[η]_ 4 [+] _[ O]_ [(] _[η]_ [2][).]
> 
> LHS is already the value of the symmetric two-player constant-sum game. This shows that for
> 
> 
> 
> 24
> 
> 
> appropriately chosen _η_ and _T_, the mixture policy _π_ ¯ _T_ is close to the minimax optimal policy (Nash
> equilibrium).
> The optimality gap is thus bounded by
> 
> 
> max �P( _π_ _≻_ _π_ ¯ _T_ )� _−_ min �P( _π_ _≺_ _π_ ¯ _T_ )�
> _π_ _π_
> 
> = max �1 _−_ P( _π_ _≺_ _π_ ¯ _T_ )� _−_ min �P( _π_ _≺_ _π_ ¯ _T_ )�
> _π_ _π_
> 
> = 2� 1 �P( _π_ _≺_ _π_ ¯ _T_ )� [�]
> 2 _[−]_ [min] _π_
> 
> 
> 
> 
>   - 1
> = _O_ ~~_√_~~
> 
> _T_
> 
> 
> 
> 
> _._
> 
> 
> ### **C Response Examples in Different Iterations**
> 
> 25
> 
> 
> Table 4: Generation example of our fine-tuned model by SPPO at different iterations.
> 
> 
> Prompt You will be given a definition of a task first, then some input of the task. You are
> given a dialog between 2 or more individuals. The dialog will include information
> as to the relationship between 2 of the participants. At the end, you will be asked
> to provide an answer as to the relationship of those 2 participants. In this scenario,
> ’0’ will represent a spousal relationship, ’1’ will represent siblings, and ’2’ will
> represent a child/parent relationship. Speaker 1: I’ll be right with you. Okay?
> Thanks, Wendy. Speaker 2: Oh my God! How cute is the on-call doctor? Speaker
> 3: Ooh, so cute, that I’m thinking about jamming this pen in my eye. Speaker 4:
> Dr. Burke will see you know. Speaker 2: Oh no-no-no, not Dr. Burke. Dr. Burke
> is out of town. The-the on-call doctor will see me now. Speaker 4: Dr. Richard
> Burke is out of town. Dr. Timothy Burke, his son, will see you now. Speaker 5:
> Ready? What is the relationship between Speaker 5 and Richard Burke? Output:
> 
> 
> `Mistral-7B` The relationship between Speaker 5 and Richard Burke is that of a parent and
> child, as Richard Burke is identified as the son of another character in the dialog.
> 
> 
> Iteration 1 The relationship between Speaker 5 and Richard Burke is that of a father and
> child. Based on the dialogue, it was revealed that Dr. Timothy Burke is the on-call
> doctor and the son of Dr. Richard Burke.
> 
> 
> Iteration 2 The relationship between Speaker 5 and Richard Burke is that of a father and
> child. The conversation reveals that Dr. Timothy Burke is the on-call doctor and
> he is identified as the son of Dr. Richard Burke.
> 
> 
> Iteration 3 Speaker 5 is the individual asking about the relationship, so they are not directly
> related to Dr. Richard Burke. The information provided in the dialog reveals
> that Dr. Timothy Burke is the on-call doctor and the son of Dr. Richard Burke.
> Therefore, the answer is: The relationship between Speaker 5 and Dr. Richard
> Burke is that of a child (Dr. Timothy Burke) and parent. Speaker 5 is inquiring
> about the relationship, but they are not themselves a part of it. The specified
> relationship codes (0 for spousal, 1 for sibling, 2 for child/parent) align with
> this description: Speaker 5 (0, 1, or 2) and Dr. Richard Burke (2) connect as a
> parent-child duo. Output: 2 (child/parent relationship) In this scenario, Speaker
> 5’s role is to determine the relationship between herself and Dr. Richard Burke,
> but since they are not related (she is an outside inquirer), the correct answer
> pertains only to the relationship identified within the dialog: Dr. Richard Burke
> (father) and Dr. Timothy Burke (son).
> 
> 
> 26
> 
> 
> Table 5: Another generation example of our fine-tuned model by SPPO at different iterations.
> 
> 
> Prompt Q: Context: Roman Brady is a fictional character from the long running NBC soap
> opera, Days of Our Lives. The role was originated in 1981 by Wayne Northrop
> who played the role until 1984, was filled by Drake Hogestyn from 1986      - 1991,
> again by Northrop from 1991       - 1994, and is currently being portrayed by series
> veteran Josh Taylor, who stepped into the role in 1997. Question: who is roman
> brady on days of our lives? Let’s give stream of consciousness below
> 
> 
> `Mistral-7B` Roman Brady is a fictional character on the NBC soap opera ”Days of Our Lives.”
> He was first portrayed by Wayne Northrop from 1981 to 1984. Later, Drake
> Hogestyn took over the role from 1986 to 1991. Northrop returned to the role from
> 1991 to 1994. Since 1997, the character is being portrayed by Josh Taylor. Roman
> Brady is a significant character in the show’s long-running storylines.
> 
> 
> Iteration 1 Roman Brady is a fictional character on the NBC soap opera ”Days of Our Lives.”
> He was first portrayed by Wayne Northrop from 1981 to 1984. Drake Hogestyn
> took over the role from 1986 to 1991. Northrop returned to play Roman again
> from 1991 to 1994. Since 1997, the character has been portrayed by Josh Taylor.
> So, in summary, Roman Brady is a long-standing character on ”Days of Our Lives”
> who has been played by three different actors over the years: Wayne Northrop
> (1981-1984, 1991-1994), Drake Hogestyn (1986-1991), and currently by Josh Taylor
> (1997-present).
> 
> 
> Iteration 2 Roman Brady is a fictional character on the NBC soap opera ”Days of Our Lives.”
> He was first portrayed by Wayne Northrop from 1981 to 1984. Drake Hogestyn
> took over the role from 1986 to 1991. Northrop returned to play Roman again
> from 1991 to 1994. Since 1997, the character has been portrayed by Josh Taylor.
> Overall, Roman Brady is a long-standing and complex figure in the show’s history,
> with multiple actors bringing their unique interpretations to the role.
> 
> 
> Iteration 3 Roman Brady is a fictional character on the NBC soap opera ”Days of Our Lives.”
> He was originally played by Wayne Northrop from 1981 to 1984. Drake Hogestyn
> took over the role from 1986 to 1991. Northrop returned to portray Roman
> once more from 1991 to 1994. Since 1997, the character has been portrayed by
> Josh Taylor.Roman Brady is a complex and prominent figure in the long-running
> daytime drama. Initially played by Northrop in the early 1980s, his tenure included
> involvement in various storylines, such as romantic relationships and business
> dealings. Hogestyn’s portrayal during the late 1980s and early 1990s introduced
> new dimensions to the character. Northrop’s second stint, from 1991 to 1994,
> further developed Roman’s narrative. Since 1997, Josh Taylor has assumed the
> role, continuing to contribute to the evolving story of Roman Brady on ”Days of
> Our Lives.” Throughout these different portrayals, Roman has remained a central
> character, known for his intricate relationships, business ventures, and personal
> struggles.
> 
> 
> 27
> 
> 
> ### **References**
> 
> Askell, A., Bai, Y., Chen, A., Drain, D., Ganguli, D., Henighan, T., Jones, A., Joseph,
> N., Mann, B., DasSarma, N. et al. (2021). A general language assistant as a laboratory for
> alignment. _arXiv_ _preprint_ _arXiv:2112.00861_ .
> 
> 
> Azar, M. G., Rowland, M., Piot, B., Guo, D., Calandriello, D., Valko, M. and Munos,
> R. (2023). A general theoretical paradigm to understand learning from human preferences. _arXiv_
> _preprint_ _arXiv:2310.12036_ .
> 
> 
> Beeching, E., Fourrier, C., Habib, N., Han, S., Lambert, N., Rajani, N., Sanseviero,
> O., Tunstall, L. and Wolf, T. (2023a). Open llm leaderboard. `[https://huggingface.co/](https://huggingface.co/spaces/HuggingFaceH4/open_llm_leaderboard)`
> `[spaces/HuggingFaceH4/open_llm_leaderboard](https://huggingface.co/spaces/HuggingFaceH4/open_llm_leaderboard)` .
> 
> 
> Beeching, E., Fourrier, C., Habib, N., Han, S., Lambert, N., Rajani, N., Sanseviero, O.,
> Tunstall, L. and Wolf, T. (2023b). Open llm leaderboard. _Hugging_ _Face_ .
> 
> 
> Bradley, R. A. and Terry, M. E. (1952). Rank Analysis of Incomplete Block Designs: I. The
> Method of Paired Comparisons. _Biometrika_ **39** 324–345.
> 
> 
> Calandriello, D., Guo, D., Munos, R., Rowland, M., Tang, Y., Pires, B. A., Richemond,
> P. H., Lan, C. L., Valko, M., Liu, T. et al. (2024). Human alignment of large language
> models through online preference optimisation. _arXiv_ _preprint_ _arXiv:2403.08635_ .
> 
> 
> Chen, Z., Deng, Y., Yuan, H., Ji, K. and Gu, Q. (2024). Self-play fine-tuning converts weak
> language models to strong language models. _arXiv_ _preprint_ _arXiv:2401.01335_ .
> 
> 
> Christiano, P. F., Leike, J., Brown, T., Martic, M., Legg, S. and Amodei, D. (2017).
> Deep reinforcement learning from human preferences. _Advances_ _in_ _neural_ _information_ _processing_
> _systems_ **30** .
> 
> 
> Clark, P., Cowhey, I., Etzioni, O., Khot, T., Sabharwal, A., Schoenick, C. and Tafjord,
> O. (2018). Think you have solved question answering? try arc, the ai2 reasoning challenge. _arXiv_
> _preprint_ _arXiv:1803.05457_ .
> 
> 
> Cobbe, K., Kosaraju, V., Bavarian, M., Chen, M., Jun, H., Kaiser, L., Plappert, M.,
> Tworek, J., Hilton, J., Nakano, R. et al. (2021). Training verifiers to solve math word
> problems. _arXiv_ _preprint_ _arXiv:2110.14168_ .
> 
> 
> Cui, G., Yuan, L., Ding, N., Yao, G., Zhu, W., Ni, Y., Xie, G., Liu, Z. and Sun, M.
> (2023). Ultrafeedback: Boosting language models with high-quality feedback. _arXiv_ _preprint_
> _arXiv:2310.01377_ .
> 
> 
> Dubois, Y., Galambosi, B., Liang, P. and Hashimoto, T. B. (2024a). Length-controlled
> alpacaeval: A simple way to debias automatic evaluators. _arXiv_ _preprint_ _arXiv:2404.04475_ .
> 
> 
> Dubois, Y., Li, C. X., Taori, R., Zhang, T., Gulrajani, I., Ba, J., Guestrin, C., Liang,
> P. S. and Hashimoto, T. B. (2024b). Alpacafarm: A simulation framework for methods that
> learn from human feedback. _Advances_ _in_ _Neural_ _Information_ _Processing_ _Systems_ **36** .
> 
> 
> 28
> 
> 
> Dud´ık, M., Hofmann, K., Schapire, R. E., Slivkins, A. and Zoghi, M. (2015). Contextual
> dueling bandits. In _Conference_ _on_ _Learning_ _Theory_ . PMLR.
> 
> 
> Ethayarajh, K., Xu, W., Muennighoff, N., Jurafsky, D. and Kiela, D. (2024). Kto: Model
> alignment as prospect theoretic optimization. _arXiv_ _preprint_ _arXiv:2402.01306_ .
> 
> 
> Freund, Y. and Schapire, R. E. (1997). A decision-theoretic generalization of on-line learning
> and an application to boosting. _Journal_ _of_ _computer_ _and_ _system_ _sciences_ **55** 119–139.
> 
> 
> Freund, Y. and Schapire, R. E. (1999). Adaptive game playing using multiplicative weights.
> _Games_ _and_ _Economic_ _Behavior_ **29** 79–103.
> 
> 
> Gao, L., Schulman, J. and Hilton, J. (2023). Scaling laws for reward model overoptimization.
> In _International_ _Conference_ _on_ _Machine_ _Learning_ . PMLR.
> 
> 
> Gao, Z., Chang, J. D., Zhan, W., Oertell, O., Swamy, G., Brantley, K., Joachims, T.,
> Bagnell, J. A., Lee, J. D. and Sun, W. (2024). Rebel: Reinforcement learning via regressing
> relative rewards. _arXiv_ _preprint_ _arXiv:2404.16767_ .
> 
> 
> Haarnoja, T., Zhou, A., Abbeel, P. and Levine, S. (2018). Soft actor-critic: Off-policy
> maximum entropy deep reinforcement learning with a stochastic actor. In _International_ _conference_
> _on_ _machine_ _learning_ . PMLR.
> 
> 
> He, P., Gao, J. and Chen, W. (2021). Debertav3: Improving deberta using electra-style
> pre-training with gradient-disentangled embedding sharing.
> 
> 
> Hendrycks, D., Burns, C., Basart, S., Zou, A., Mazeika, M., Song, D. and Steinhardt, J.
> (2020). Measuring massive multitask language understanding. _arXiv_ _preprint_ _arXiv:2009.03300_ .
> 
> 
> Hong, J., Lee, N. and Thorne, J. (2024). Reference-free monolithic preference optimization with
> odds ratio. _arXiv_ _preprint_ _arXiv:2403.07691_ .
> 
> 
> Ji, K., He, J. and Gu, Q. (2024). Reinforcement learning from human feedback with active queries.
> _arXiv_ _preprint_ _arXiv:2402.09401_ .
> 
> 
> Jiang, A. Q., Sablayrolles, A., Mensch, A., Bamford, C., Chaplot, D. S., Casas, D.
> d. l., Bressand, F., Lengyel, G., Lample, G., Saulnier, L. et al. (2023a). Mistral 7b.
> _arXiv_ _preprint_ _arXiv:2310.06825_ .
> 
> 
> Jiang, D., Ren, X. and Lin, B. Y. (2023b). Llm-blender: Ensembling large language models with
> pairwise ranking and generative fusion. _arXiv_ _preprint_ _arXiv:2306.02561_ .
> 
> 
> Li, J., Sun, S., Yuan, W., Fan, R.-Z., Zhao, H. and Liu, P. (2023a). Generative judge for
> evaluating alignment. _arXiv_ _preprint_ _arXiv:2310.05470_ .
> 
> 
> Li, T., Chiang, W.-L., Frick, E., Dunlap, L., Wu, T., Zhu, B., Gonzalez, J. E. and Stoica,
> I. (2024). From crowdsourced data to high-quality benchmarks: Arena-hard and benchbuilder
> pipeline. _arXiv_ _preprint_ _arXiv:2406.11939_ .
> 
> 
> Li, X., Zhang, T., Dubois, Y., Taori, R., Gulrajani, I., Guestrin, C., Liang, P. and
> Hashimoto, T. B. (2023b). Alpacaeval: An automatic evaluator of instruction-following models.
> `[https://github.com/tatsu-lab/alpaca_eval](https://github.com/tatsu-lab/alpaca_eval)` .
> 
> 
> 29
> 
> 
> Lin, S., Hilton, J. and Evans, O. (2021). Truthfulqa: Measuring how models mimic human
> falsehoods. _arXiv_ _preprint_ _arXiv:2109.07958_ .
> 
> 
> Liu, T., Zhao, Y., Joshi, R., Khalman, M., Saleh, M., Liu, P. J. and Liu, J. (2023).
> Statistical rejection sampling improves preference optimization. _arXiv_ _preprint_ _arXiv:2309.06657_
> .
> 
> 
> Lou, H., Jin, T., Wu, Y., Xu, P., Gu, Q. and Farnoud, F. (2022). Active ranking without
> strong stochastic transitivity. _Advances_ _in_ _neural_ _information_ _processing_ _systems_ .
> 
> 
> Munos, R., Valko, M., Calandriello, D., Azar, M. G., Rowland, M., Guo, Z. D., Tang,
> Y., Geist, M., Mesnard, T., Michi, A. et al. (2023). Nash learning from human feedback.
> _arXiv_ _preprint_ _arXiv:2312.00886_ .
> 
> 
> Ng, A. Y., Harada, D. and Russell, S. (1999). Policy invariance under reward transformations:
> Theory and application to reward shaping. In _Icml_, vol. 99.
> 
> 
> OpenAI, J., Achiam, Adler, S., Agarwal, S., Ahmad, L., Akkaya, I., Aleman, F. L.,
> Almeida, D., Altenschmidt, J., Altman, S., Anadkat, S. et al. (2023). Gpt-4 technical
> report. _arXiv_ _preprint_ _arXiv:2303.08774_ .
> 
> 
> Ouyang, L., Wu, J., Jiang, X., Almeida, D., Wainwright, C., Mishkin, P., Zhang, C.,
> Agarwal, S., Slama, K., Ray, A. et al. (2022). Training language models to follow instructions
> with human feedback. _Advances_ _in_ _Neural_ _Information_ _Processing_ _Systems_ **35** 27730–27744.
> 
> 
> Pal, A., Karkhanis, D., Dooley, S., Roberts, M., Naidu, S. and White, C. (2024). Smaug:
> Fixing failure modes of preference optimisation with dpo-positive. _arXiv preprint arXiv:2402.13228_
> .
> 
> 
> Rafailov, R., Hejna, J., Park, R. and Finn, C. (2024a). From r to q*: Your language model is
> secretly a q-function. _arXiv_ _preprint_ _arXiv:2404.12358_ .
> 
> 
> Rafailov, R., Sharma, A., Mitchell, E., Manning, C. D., Ermon, S. and Finn, C. (2024b).
> Direct preference optimization: Your language model is secretly a reward model. _Advances_ _in_
> _Neural_ _Information_ _Processing_ _Systems_ **36** .
> 
> 
> Rosset, C., Cheng, C.-A., Mitra, A., Santacroce, M., Awadallah, A. and Xie, T. (2024).
> Direct nash optimization: Teaching language models to self-improve with general preferences.
> _arXiv_ _preprint_ _arXiv:2404.03715_ .
> 
> 
> Sakaguchi, K., Bras, R. L., Bhagavatula, C. and Choi, Y. (2021). Winogrande: An
> adversarial winograd schema challenge at scale. _Communications_ _of_ _the_ _ACM_ **64** 99–106.
> 
> 
> Schulman, J., Wolski, F., Dhariwal, P., Radford, A. and Klimov, O. (2017). Proximal
> policy optimization algorithms. _arXiv_ _preprint_ _arXiv:1707.06347_ .
> 
> 
> Singh, A., Co-Reyes, J. D., Agarwal, R., Anand, A., Patil, P., Liu, P. J., Harrison,
> J., Lee, J., Xu, K., Parisi, A. et al. (2023). Beyond human data: Scaling self-training for
> problem-solving with language models. _arXiv_ _preprint_ _arXiv:2312.06585_ .
> 
> 
> 30
> 
> 
> Sutton, R. S., McAllester, D., Singh, S. and Mansour, Y. (1999). Policy gradient methods
> for reinforcement learning with function approximation. _Advances in neural information processing_
> _systems_ **12** .
> 
> 
> Swamy, G., Dann, C., Kidambi, R., Wu, Z. S. and Agarwal, A. (2024). A minimaximalist
> approach to reinforcement learning from human feedback. _arXiv_ _preprint_ _arXiv:2401.04056_ .
> 
> 
> Tversky, A. (1969). Intransitivity of preferences. _Psychological_ _review_ **76** 31.
> 
> 
> Wang, Y., Liu, Q. and Jin, C. (2024). Is rlhf more difficult than standard rl? a theoretical
> perspective. _Advances_ _in_ _Neural_ _Information_ _Processing_ _Systems_ **36** .
> 
> 
> Wu, Y., Jin, T., Di, Q., Lou, H., Farnoud, F. and Gu, Q. (2023). Borda regret minimization for
> generalized linear dueling bandits. In _ICML_ _2023_ _Workshop_ _The_ _Many_ _Facets_ _of_ _Preference-Based_
> _Learning_ .
> 
> 
> Xiong, W., Dong, H., Ye, C., Zhong, H., Jiang, N. and Zhang, T. (2023). Gibbs sampling from
> human feedback: A provable kl-constrained framework for rlhf. _arXiv_ _preprint_ _arXiv:2312.11456_ .
> 
> 
> Xu, J., Lee, A., Sukhbaatar, S. and Weston, J. (2023). Some things are more cringe than
> others: Preference optimization with the pairwise cringe loss. _arXiv_ _preprint_ _arXiv:2312.16682_ .
> 
> 
> Ye, C., Xiong, W., Zhang, Y., Jiang, N. and Zhang, T. (2024). A theoretical analysis
> of nash learning from human feedback under general kl-regularized preference. _arXiv_ _preprint_
> _arXiv:2402.07314_ .
> 
> 
> Yuan, W., Pang, R. Y., Cho, K., Sukhbaatar, S., Xu, J. and Weston, J. (2024). Selfrewarding language models. _arXiv_ _preprint_ _arXiv:2401.10020_ .
> 
> 
> Zellers, R., Holtzman, A., Bisk, Y., Farhadi, A. and Choi, Y. (2019). Hellaswag: Can a
> machine really finish your sentence? _arXiv_ _preprint_ _arXiv:1905.07830_ .
> 
> 
> Zhao, Y., Joshi, R., Liu, T., Khalman, M., Saleh, M. and Liu, P. J. (2023). Slic-hf: Sequence
> likelihood calibration with human feedback. _arXiv_ _preprint_ _arXiv:2305.10425_ .
> 
> 
> Zheng, L., Chiang, W.-L., Sheng, Y., Zhuang, S., Wu, Z., Zhuang, Y., Lin, Z., Li, Z., Li,
> D., Xing, E. et al. (2023). Judging llm-as-a-judge with mt-bench and chatbot arena. _Advances_
> _in_ _Neural_ _Information_ _Processing_ _Systems_ **36** .
> 
> 
> Zheng, L., Chiang, W.-L., Sheng, Y., Zhuang, S., Wu, Z., Zhuang, Y., Lin, Z., Li, Z., Li,
> D., Xing, E. et al. (2024). Judging llm-as-a-judge with mt-bench and chatbot arena. _Advances_
> _in_ _Neural_ _Information_ _Processing_ _Systems_ **36** .
> 
> 
> Zhu, B., Jiao, J. and Jordan, M. I. (2023). Principled reinforcement learning with human
> feedback from pairwise or _k_ -wise comparisons. _arXiv_ _preprint_ _arXiv:2301.11270_ .
> 
> 
> 31
> 
> 
> 
> [Source: Self-Play Preference Optimization for Language Model Alignment](https://arxiv.org/abs/2405.00675)
