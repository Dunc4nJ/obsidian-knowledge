---
created: 2026-06-09
description: Arjun Kocher's answers to Xiuyu Li's curated RL interview questions — covering actor-critic rationale, advantage estimation, PPO clipping, GRPO variants (Dr.GRPO, DAPO, GSPO, CISPO, SAPO, DPPO, MaxRL, SimKO), DPO reward hacking, MoE routing mismatches, ProRL long-horizon stability, OPD distillation, and the full DeepSeek R1-to-V4 training arc.
source: https://www.k-a.in/rl-algo.html
type: learning
---

## Key Takeaways

- **GRPO eliminates the critic by using the group mean as baseline** — for LLMs the critic's value function over a token sequence is hard to learn well anyway, so GRPO just normalizes rewards within a group of G sampled responses. This is the insight that drove DeepSeek-R1 and every GRPO variant since. The problem is zero-variance groups (all correct or all wrong) produce degenerate std normalization — Dr.GRPO and DAPO fix this by filtering those groups out entirely. [[RL environments are the new unit of progress in agentic AI training]] covers the practical RLVR environment design that makes verifiable rewards work at scale; [[agentic RL training converges on outcome rewards inside production harnesses across Kimi Cursor and Chroma]] shows how these variants land in production systems.

- **The RLHF KL penalty uses reverse KL, which causes mode collapse** — minimizing $D_{KL}(\pi_\theta \| \pi_{ref})$ makes the model chase high-reward modes and abandon reference coverage. This is why DAPO and GSPO remove the KL entirely for verifiable-reward settings: you can't hack a unit test by drifting from the reference, so the KL is pure drag on learning. See [[LLM optimization interview prep maps Flash Attention, ZeRO, speculative decoding, and MoE across training and inference]] for broader RLHF and distributed training context.

- **PPO's flat gradient problem is a real training hazard** — when a sample is clipped, it contributes zero gradient in PPO even though it contains information. CISPO fixes this by clipping the IS ratio in the gradient computation rather than the objective, preserving gradient flow for near-boundary samples. This is a subtle but meaningful improvement for RLVR. [[Cursor Composer 2 Technical Report]] covers Dr.GRPO modifications and gradient bias minimization in a production coding RL context.

- **RL expands reliable capability use, not the frontier itself** — pretraining sets the knowledge boundary; RL reshapes how reliably the model reaches it and teaches search-like test-time behavior. SFT gives you the format and RL gives you the strategy. The ProRL result (2000+ stable steps via periodic reference resets) shows the ceiling can be pushed significantly further than typical ~hundreds-of-steps runs. [[mid-training builds the reasoning foundation that RL amplifies not replaces]] provides mechanistic evidence: RL makes sparse surgical updates (~5% of parameters) while mid-training densely restructures the representation.

- **DeepSeek's training arc is a story of compressing the pipeline** — R1 introduced GRPO, V3.2 merged multi-stage into one mixed-RL stage to avoid catastrophic forgetting, V4 replaced mixed RL with multi-teacher OPD (On-Policy Distillation), using the actor as its own judge (GRM). The MoE-specific complication throughout: routing gradients are spiky, load balancing fights the policy gradient, and the reference model for KL must also run in MoE mode doubling expert memory. [[Recursive Agent Optimization trains a shared LLM policy to spawn REPL subagents using local-node rewards and a leave-one-out baseline]] shows the LOO baseline as a related advantage estimation technique for multi-agent RL settings.

## External Resources

- [Xiuyu Li's RL Questions tweet](https://x.com/sheriyuo/status/2063295181131247674) — compiled list of RL interview questions that prompted this Q&A
- [Dr.GRPO (Liu et al, 2503.20783)](https://arxiv.org/abs/2503.20783) — removes std normalization, filters zero-variance groups
- [DAPO (Yu et al, 2503.14476)](https://arxiv.org/abs/2503.14476) — drops KL penalty, asymmetric clip-higher, dynamic sampling, token-level loss normalization
- [GSPO (Zheng et al, 2507.18071)](https://arxiv.org/abs/2507.18071) — sequence-level IS ratio constraint instead of token-level KL/clipping
- [CISPO (Minimax, 2506.13585)](https://arxiv.org/abs/2506.13585) — clips IS ratio in gradient (not objective), preserving gradient flow for clipped samples
- [SAPO (Gao et al, 2511.20347)](https://arxiv.org/abs/2511.20347) — sequence-coherent + token-adaptive with soft gating continuous trust region
- [DPPO (Qi et al, 2602.04879)](https://arxiv.org/abs/2602.04879) — principled divergence constraint (TV or KL) replacing heuristic clipping, Binary/Top-K approximations for efficiency
- [MaxRL (Tajwar et al, 2602.02710)](https://arxiv.org/abs/2602.02710) — compute-indexed objectives interpolating between RL and exact MLE
- [SimKO (Peng et al, 2510.14807)](https://arxiv.org/abs/2510.14807) — asymmetric token-level probability adjustment to reduce over-concentration
- [Expert Choice Routing (Zhou et al, 2202.09368)](https://arxiv.org/abs/2202.09368) — experts choose top-K tokens for perfect load balance, but causes train/inference mismatch
- [ProRL (2505.24864)](https://arxiv.org/abs/2505.24864) — entropy collapse prevention via reference policy resets, sustains 2000+ training steps
- [OPD: Learning beyond Teacher (2602.12125)](https://arxiv.org/abs/2602.12125) — dense credit assignment via token-level rewards from any teacher model
- [Does RL Really Incentivize Reasoning Beyond the Base Model? (2504.13837)](https://arxiv.org/abs/2504.13837) — open research question on RL capability frontier expansion
- [Emergent Abilities of LLMs (Wei et al 2022, 2206.07682)](https://arxiv.org/abs/2206.07682) — CoT reasoning emergence in models >68B parameters
- [Chinchilla (Hoffmann et al 2022, 2203.15556)](https://arxiv.org/abs/2203.15556) — smaller models on more tokens can outperform larger ones
- [Schaeffer et al 2023 (2304.15004)](https://arxiv.org/abs/2304.15004) — emergence may be a metric artifact, not a sharp behavioral shift
- [DeepSeek-R1 (2501.12948)](https://arxiv.org/abs/2501.12948) — long-form reasoning as a primarily RL phenomenon

## Original Content

*Chapter opener animation*
![[k-a-rl-algo-001.gif]]

> [!quote]- Source Material
> 
> This was a fun exercise! thanks to [Xiuyu Li(@sheriyuo)](https://x.com/sheriyuo/status/2063295181131247674) for compiling all the questions.
> 
> *Xiuyu Li's compiled RL questions tweet*
> ![[k-a-rl-algo-002.png]]
> 
> Here's my attempt to answer all the questions as best i could. Happy to be corrected and update my understanding.
> 
> **Q. Why Actor-Critic instead of pure Critic**
> 
> A pure critic (value based like DQN) need an argmax over actions, for LLMs the action space is the entire vocab so argmax is dead on arrival and impossible for continuous control. Actor-critic handles continuous action spaces naturally.
> Actor-critic has lower variance than pure policy gradient (REINFORCE). pure policy handles big action spaces fine but the updates are high variance since youre using full returns. actor-critic keeps a parameterized policy and uses the critic as baseline to kill that variance, plus the critic lets you bootstrap so credit assignment doesnt have to wait for the whole episode.
> 
> one thing to note > in LLM RL the actor-critic argument is actually weaker than in classical RL because value function over token sequence is hard to learn well, which is exactly why GRPO throws the critic away and just uses a group mean as the baseline.
> 
> **Q: Relationship between KL divergence, cross entropy, and MLE?**
> 
> KL divergence from P to Q:
> $$D_{KL}(P | Q) = \sum_x P(x) \log \frac{P(x)}{Q(x)} = H(P, Q) - H(P)$$
> 
> where $H(P,Q)$ is cross-entropy and $H(P)$ is entropy of P.
> 
> data distribution $P$ is fixed, so $H(P)$ is constant. So minimizing $D_{KL}(P_{data} | Q_\theta)$ is exactly equivalent to minimizing cross-entropy $H(P_{data}, Q_\theta)$, which is exactly MLE (maximizing $\sum_i \log Q_\theta(x_i)$).
> 
> (direction-wise) the RLHF KL penalty is reverse KL (model seeking behavior) and thats the reason why RL'd models lose diversity. The policy chases high reward modes and abandons the references covering instead. DPO inherits the reverse KL behavior too.
> 
> **Q: How should rewards be designed in different RL scenarios?**
> 
> Designing reward functions is problem-dependent so it comes down to whether the domain can be properly verified.
> 
> - Verifiable correctness: math/code can be rewarded cleanly with unit tests and symbolic checks.
> - LLM-as-judge: for writing and open-ended stuff which are noise and gameable. More prone to reward hacking.
> - Format rewards: like reward for using `<think>` tags properly, but these forward rewards should decay once the model has learned the format or itll start gaming the format at the cost of content.
> - Outcome/Process rewards: ORMs rewards final answer correnctness and PRMs reward intermediate steps. most LLM RL uses ORMs at scale.
> 
> **Q: How do importance sampling, rejection sampling, and other Monte Carlo methods fit into RL?**
> 
> **Importance Sampling (IS)**: reuses off policy data by reweighing with the **IS** ratio $\rho$, to correct for the mismatch between behavior policy $\beta$ (which generated data) and target policy $π_θ$:
> 
> $$\rho = \frac{\pi_\theta(a|s)}{\beta(a|s)}$$
> PPO uses a clipped IS ratio. GRPO also uses IS implicitly when the old policy generates rollouts and the new policy is trained on them. IS has high variance when $π_θ$ and $\beta$ diverge significantly.
> 
> **Rejection Sampling** is for filtering, best of N, dropping the too easy and too hard prompts, or ReST style where you sample, keep the good ones, and refit.
> 
> **Q: How is advantage computed in PPO and GRPO? Why subtract a baseline? Is standard deviation normalization necessary?**
> 
> **PPO** uses **GAE** (Generalized Advantage Estimation).
> $$A_t^{GAE} = \sum_{l=0}^{\infty} (\gamma\lambda)^l \delta_{t+l}, \quad \delta_t = r_t + \gamma V(s_{t+1}) - V(s_t)$$
> 
> requires a learned value function (critic).
> advantage is typically whitened (mean subtracted, divided by std) per minibatch.
> 
> **GRPO** drops both the critic and the reward model. No value network, for each question q, sample G responses ${[o_1, ..., o_G]}$, score each with reward $r_i$.
> 
> Advantage is: $$A_i = \frac{r_i - \text{mean}({r_j})}{\text{std}({r_j})}$$
> this is pure group-normalized reward, so the baseline is just the group mean.
> 
> **Why subtract a baseline?**
> subtracting any baseline for the return in the policy gradient doenst bias the gradient (because $\mathbb{E}\!\left[\nabla \log \pi \cdot b\right] = 0$) but reduces variance dramatically. The optimal baseline is $\mathbb{E}[G_t]$, which the value function approximates.
> 
> **Is std normalization necessary?**
> Empirically it helps stabilize training by keeping gradient magnitudes consistent regardless of reward scale but it can distort advantage when the group has near-zero variance. dividing by std systematically upweights low variance prompts (the all right or all wrong ones) and those zero variance groups carry no learning signal so they are unnecessary.
> 
> **Dr.GRPO** and **DAPO** either clip or skip the update for such groups, which is a meaningful improvement over vanilla GRPO.
> 
> **Q: How do RL training and test-time scaling perform exploration differently?**
> 
> RL training is "learning", test-time scaling is "exploration/search"
> 
> RL training is about finding the high-reward trajectories and reinforcing good outputs and reshaping the weights accordingly, the exploration here is just stochastic sampling during rollouts.
> 
> Test-time scaling explores the output space and spends inference budget searching for the best path (best-of-N, beam search, MCTS, sequential revision) without modifying model weights.
> 
> training exploration changes the policy whereas test-time exploration uses the fixed policy more extensively. so an exploration problem which arises is if the policy never samples correct trajectory for a prompt, the reward is zero and that prompt is never learned.
> 
> **Q: How does PPO clipping work? Why take the minimum? What happens without clipping? How does CISPO differ?**
> 
> PPO objective: $$L^{CLIP}(\theta) = \mathbb{E}_t \left[ \min\left( r_t(\theta) A_t,\ \text{clip}(r_t(\theta), 1-\epsilon, 1+\epsilon) A_t \right) \right]$$
> 
> where $$r_t(\theta) = \pi_\theta(a_t|s_t)/\pi_{\theta_{old}}(a_t|s_t)$$
> 
> - when $A_t$ > 0 (good action): if the ratio exceeds 1+e, the clipped term is smaller, so we take the clipped (smaller) value preventing overconfident policy updates.
> - when $A_t$ < 0 (bad action): if the ratio goes below 1-e , again the clipped term is larger (less negative), so we take the unclipped (more negative) value not letting the policy escape punishment.
> 
> **The Minimum**, in both cases ensures we don't take steps that are too large in either sign of the advantage
> 
> **Without clipping**, pure IS-weighted gradient. The ratio r_t can become arbitrarily large for actions the new policy assigns much higher probability, causing catastrophically large gradient steps and policy collapse. This is why TRPO used a hard KL constraint instead.
> 
> **CISPO (Clipped IS Policy Optimization):** Instead of clipping the objective, CISPO clips the IS ratio _before_ computing the gradient specifically, it clips $r_t$ to $[1-\epsilon, 1+\epsilon]$ in the gradient computation but not in the loss value. This avoids the flat gradient problem in PPO where clipped samples contribute zero gradient even though they contain information. CISPO maintains gradient flow for clipped samples.
> 
> **Q: Why does GRPO include a KL penalty? How is KL computed? Why do DAPO and GSPO remove it?**
> 
> The KL is a per token term between the current policy and a frozen reference,
> 
> $$\text{KL}(\pi_\theta | \pi_{ref}) = \sum_t \left[ \pi_\theta(a_t|s_t, a_{<t}) \log \frac{\pi_\theta(a_t|s_t, a_{<t})}{\pi_{ref}(a_t|s_t, a_{<t})} \right]$$
> 
> and it needs a reference forward pass to compute. The reason it exists is to stop the policy drifting too far from a good base model and reward hacking. In practice this is approximated per-token and averaged.
> 
> In RLVR the reward is a verifier, you can't hack a unit test by drifting from the reference, so the verifier self insures against hacking and the KL's protective job is redundant. Once that's gone the KL is pure drag, it stops you moving far enough to actually learn the new domain. So DAPO/GSPO drops it, and the clip already bounds step size anyway, saving the reference model memory is a nice bonus but the learning argument is the real one.
> 
> **Q: During LLM training, what happens if loss is accidentally All Reduced multiple times?**
> 
> AllReduce averages or sums gradients across data parallel ranks. Do it k times and the gradient the optimizer sees is scaled by k, which is just a k times learning rate you didn't ask for. You get gradient explosion overflow in BF16 or FP16 and the effective batch semantics break because the model thinks it saw k times more data. it shows up as loss spikes or NaNs. It's nasty because the code can look fine the extra reduce usually sneaks in from a gradient hook, a custom optimizer step or wrong placement in a pipeline flush.
> 
> **Q: What is the reward function in DPO? Can reward hacking occur? How can it be mitigated?**
> 
> **Implicit Reward Function** in **DPO**
> $$r{(x, y)} = \beta \log \frac{\pi^{*}{(y|x)}}{\pi_{ref}{(y|x)}} + \beta \log Z(x)$$
> 
> DPO parameterizes this directly with the policy, optimizing the policy directly through the preference pairs , giving the loss:
> 
> $$L_{DPO} = -\mathbb{E} \left[ \log \sigma\left( \beta \log \frac{\pi_\theta(y_w|x)}{\pi_{ref}(y_w|x)} - \beta \log \frac{\pi_\theta(y_l|x)}{\pi_{ref}(y_l|x)} \right) \right]$$
> 
> **Can reward hacking occur?**
> Yes. DPO can increase the likelihood of chosen responses and simultaneously decrease the likelihood of rejected responses, but the reference model constraint is only implicit (via the ratio).
> 
> The model can exploit:
> - **Length**: preferred responses tend to be longer, so the model learns to be verbose regardless of quality
> - surface features of preferred responses rather than their actual quality
> - degenerate solutions where the policy collapses on a narrow set of outputs.
> 
> **Mitigations** that help, **IPO** to stop overconfident margins, explicit length regularization, SFT warmup, and the strongest one is iterative or online DPO where you regenerate the preference pairs from the current policy instead of training on stale offline pairs.
> 
> **Q: What methods address train-inference mismatch in MoE models, and how do they work?**
> 
> MoE models route tokens to experts via a router. during training (typically with auxiliary load-balancing losses) expert utilization is approximately uniform. During inference, routing is different some experts are heavily loaded, some idle, causing:
> 
> - **Expert capacity overflow**, tokens dropped if expert buffer is full
> - **load imbalance across devices**, some GPUs idle while others are bottlenecked
> - **different routing than at training time** when using different batch sizes or token distributions
> 
> **Methods:**
> 
> - **Expert Choice routing ([Zhou et al](https://arxiv.org/abs/2202.09368)):** Instead of tokens choosing experts (top-K), experts choose top-K tokens. guarantees perfect load balance by construction but causes train-inference mismatch because at inference you can't do expert-choice (causal masking prevents tokens from knowing which future tokens the expert will select).
> - **Auxiliary load-balancing loss:** use losses that encourage uniform expert routing during training. doesn't fully solve inference mismatch.
> - **Shared experts:** some experts are always active (dense), reducing the routing instability problem.
> - **Fine-grained expert segmentation:** more experts, lower top-K per token, finer granularity reduces the impact of any single routing decision.
> - **Inference-time load balancing:** vLLM and SGLang implement expert-parallel load balancing at inference with dynamic dispatch (e.g., EP with work stealing).
> 
> **Q: How should group size, learning rate, PPO epochs, and generation length be selected during RL training?**
> 
> these are empirical hyperparameters but there are principled constraints:
> 
> **Group size G (GRPO**): larger G gives better advantage estaimates (lower variance baselines) but costs proportionally more compute. In practice G is ~ **8 to 16** is common, too small (G=2) gives noise advantages, and diminishing returns beyond 32.
> 
> **Learning rate**: RL training is more unstable than SFT. Typical values **1e-6** to **5e-6** for 7B models, lower for larger models. Start at the lower end, RL requires more conservative LR than SFT because reward signal is sparse and noisy. Overly large step can push the policy off a cliff. Cosine schedule or constant with warmup both work.
> 
> **PPO epochs** (number of passes over a batch of rollouts), more epochs = better data efficiency but increased off-policy bias (old rollouts become stale).
> Typically **1– 4** epochs in LLM RL. DeepSeek-R1 used 1 epoch, going beyond 4 often hurts because the IS ratio drifts outside the clip region.
> 
> **Generation length** directly caps exploration, too short and the model can't express reasoning, too long and you get padding waste and training instability.
> 
> **Adaptive length** (let the model generate until EOS within a maximum) is better than fixed-length. In long-CoT training, lengths of **4K–32K** tokens are used, but these require careful memory management.
> The long-tail problem (a few very long sequences dominating a batch) needs specific handling (e.g., sequence packing with length-aware batching).
> 
> **Q: Compared with GRPO, how do Dr.GRPO, DAPO, GSPO, CISPO, SAPO, DPPO, MaxRL, and SimKO improve training?**
> 
> **Dr.GRPO ([Liu et al](https://arxiv.org/abs/2503.20783)):** Identifies that GRPO's std normalization becomes degenerate when all group samples have the same reward (all correct or all wrong). Dr.GRPO removes std normalization and instead uses question-level filtering, skip updates for groups with zero variance in rewards (no learning signal). Cleaner gradient estimates.
> 
> **DAPO ([Yu et al](https://arxiv.org/abs/2503.14476)):** removes token-level KL penalty.
> Uses clip-higher, asymmetric clipping: higher upper clip for positive advantages to encourage exploration.
> Dynamic sampling, filter out groups where all samples are correct or all wrong, same insight as Dr.GRPO.
> token-level policy gradient loss; normalize by token count not sample count to prevent long-sequence bias.
> 
> **GSPO ([Zheng et al](https://arxiv.org/abs/2507.18071)):** Replaces token-level trust region (KL/clipping) with sequence-level IS ratio constraint. Argues sequence-level constraint is better aligned with sequence-level rewards. Reduces variance from token-level IS ratio products.
> 
> **CISPO ([Minimax](https://arxiv.org/abs/2506.13585)):** clips IS ratio in gradient rather than objective, preserving gradient flow for near-boundary samples.
> 
> **SAPO ([Gao et al](https://arxiv.org/abs/2511.20347)):** Compared with GSPO and GRPO, SAPO is both sequence-coherent and token-adaptive. Like GSPO, SAPO maintains sequence-level coherence, but its soft gating forms a continuous trust region that avoids the brittle hard clipping band used in GSPO.
> 
> **DPPO ([Qi et al](https://arxiv.org/abs/2602.04879)):** unlike PPO, DPPO substitutes heuristic clipping with a more principled constraint based on a direct estimate of policy divergence (eg Total Variation or KL). To avoid huge memory footprint the efficient Binary and Top-K approximations to capture the essential divergence with negligible overhead.
> 
> **MaxRL([Tajwar et al](https://arxiv.org/abs/2602.02710)):** a sampling-based framework to approximate maximum likelihood using reinforcement learning techniques. MaxRL addresses the challenges of non-differentiable sampling by defining a compute-indexed family of sample-based objectives that interpolate between standard reinforcement learning and exact maximum likelihood as additional sampling compute is allocated. The resulting objectives admit a simple, unbiased policy-gradient estimator and converge to maximum likelihood optimization in the infinite-compute limit.
> 
> **SimKO ([Peng et al](https://arxiv.org/abs/2510.14807)):** a method designed to mitigate the over-concentration issue, thereby encouraging exploration. SimKO operates in an asymmetrical manner. For verified-correct responses, it boosts the probabilities of the top-K candidates. For verified-incorrect responses, it applies stronger penalties to the top-1 candidate. This asymmetric design is particularly effective at mitigating over-concentration when applied at tokens with high entropy.
> 
> **Q: How do TRPO, DPPO, and AReaL enforce trust-region constraints?**
> 
> **TRPO** is Hard KL constrain, maximize the surrogate subject to E[KL(π_old|π_θ)] ≤ δ, solved with conjugate gradient and a line search, accurate but it needs Hessian vector products and doesn't scale to LLMs.
> 
> **DPPO**, substitutes heuristic clipping with a more principled constraint based on a direct estimate of policy divergence (eg Total Variation or KL).
> 
> **AReaL (Async Real-time RL):** Uses importance sampling with staleness correction instead of Hard KL, watches the importance ratio and drops or downweights rollouts past a staleness threshold.
> 
> **Q: Can RL fundamentally expand the capability frontier of LLMs?**
> 
> RL expands the _reliable use_ of existing capabilities and improves _test-time search behavior_, but the fundamental knowledge frontier is set by pretraining. Whether RL can push beyond the pretraining frontier remains an open research question.
> 
> An interesting paper to read is: [Does Reinforcement Learning Really Incentivize Reasoning Capacity in LLMs Beyond the Base Model?](https://arxiv.org/abs/2504.13837)
> 
> **Q: Based on works such as ProRL, how should we think about scaling the boundaries of RL training?**
> 
> [ProRL](https://arxiv.org/abs/2505.24864) addresses the core problems in extended RL training: **entropy collapse** and **training instability**, through
> 
> **GRPO as the Base Algorithm**
> ProRL builds on **GRPO**, which estimates advantages from group scores rather than a critic model:
> 
> $$A(\tau) = \frac{R_\tau - \text{mean}(\{R_i\}_{i \in G(\tau)})}{\text{std}(\{R_i\}_{i \in G(\tau)})}$$
> 
> **DAPO Enhancements**
> - **Decoupled clipping**: Uses separate lower/upper bounds ($\epsilon_\text{low} = 0.2$, $\epsilon_\text{high} = 0.4$), promoting exploration by allowing unlikely tokens to be uplifted.
> - **Dynamic sampling**: Filters out prompts where the model always succeeds or always fails, keeping training focused on informative examples.
> 
> **KL Divergence Regularization**
> A KL penalty between the current policy $\pi_\theta$ and a reference policy $\pi_\text{ref}$ is added:
> 
> $$\mathcal{L}_\text{KL-RL}(\theta) = \mathcal{L}_\text{GRPO}(\theta) - \beta D_\text{KL}(\pi_\theta \| \pi_\text{ref})$$
> 
> This prevents the policy from drifting too far and stabilizes long-horizon training.
> 
> **Reference Policy Reset**
> As training progresses, the KL term can dominate and suppress updates. ProRL periodically **hard-resets** the reference policy to a recent snapshot of the online policy and reinitializes the optimizer allowing continued improvement without losing the benefits of KL regularization.
> 
> **Diverse Task Coverage**
> Training spans **136K problems** across math, code, STEM, logical puzzles, and instruction following. This breadth is critical, it prevents overfit to narrow domains and enables generalization.
> 
> >The result is a training loop that sustains meaningful policy updates for **2,000+ steps**, far beyond the ~hundreds of steps typical of prior work enabling the model to explore genuinely novel reasoning strategies over time.
> 
> **Q: What improvements does OPD introduce over traditional RL and SFT? What are its applications?**
> 
> Standard RL only gives an effective reward at the final token ($r_t = 0$ for $t < T$, outcome reward only at $t = T$).
> 
> OPD assigns a meaningful token-level reward to _every_ action:
> 
> $$r^{\text{OPD}}_t = \log \frac{\pi^*(y_t | x, y_{<t})}{\pi_{\text{ref}}(y_t | x, y_{<t})}$$
> This provides dense credit assignment, making optimization more efficient
> 
> In standard RL the reference model is fixed to the starting checkpoint, but OPD allows $\pi_\text{ref}$ to be _any_ model including models of different sizes since it cancels out in the final objective.
> 
> **On-policy training**: SFT trains the student on _teacher-generated_ trajectories. OPD instead has the student generate its own trajectories and receives the teacher's supervision on those avoiding the distribution mismatch between training and inference.
> 
> **Empirically stronger**: OPD consistently outperforms SFT across math reasoning and code generation benchmarks.
> 
> Read more: [Learning beyond Teacher: Generalized On-Policy Distillation with Reward Extrapolation](https://arxiv.org/abs/2602.12125)
> 
> **Applications** may include, **Multi-task capability merging, Strong-to-weak distillation, Budget-controlled reasoning**.
> 
> **Q: At which stage of training does reasoning ability emerge in LLMs?**
> 
> **Pretraining** establishes the foundational pattern matching and associative reasoning, this is usually where arithmetic, logical, and linguistic structure is internalized.
> 
> **SFT on reasoning traces** (chain-of-thought data) teaches the model to _express_ reasoning in a structured way.
> 
> **RL on verifiable tasks** amplifies and refines reasoning, teaches the model to _search_ for correct reasoning paths rather than just imitate them.
> 
> [Emergent Abilities of Large Language Models, (Wei et al 2022)](https://arxiv.org/abs/2206.07682) identified that chain-of-thought (CoT) reasoning emerges in models exceeding ~68B parameters. However, Chinchilla scaling laws [Hoffmann et al. 2022](https://arxiv.org/abs/2203.15556) proved that smaller models trained on more tokens can outperform larger ones, while subsequent work ([Schaeffer et al. 2023](https://arxiv.org/abs/2304.15004)) argued that emergence may be a metric artifact rather than a sharp behavioral shift. More recently, [DeepSeek-R1](https://arxiv.org/abs/2501.12948) demonstrated that sophisticated long-form reasoning is primarily a RL phenomenon; while a "cold-start" supervised fine-tuning (SFT) phase provides the structural format, advanced strategies like self-reflection and verification emerge through RL-driven optimization rather than imitation of human SFT data alone. SFT gives you the format and RL gives you the strategy.
> 
> **Q: From DeepSeek R1 to V3.2 and future V4 systems, what RL-related improvements have been introduced? How is RL different in MoE models?**
> 
> **DeepSeek-R1:** Introduced **GRPO**, dropping value/critic network of PPO and estimating advantages from group-relative rewards. Lower memory, and much simpler. **R1-zero** with pure RL from the base model with no SFT cold-start, showing reasoning can emerge from RL alone (answered above as well). **Rule-based/verifiable rewards** (math answer-checking code test cases) plus format rewards, avoiding a learned reward model to dodge reward hacking. Multi-stage pipeline: **cold-start -> reasoning RL -> rejection-sampling SFT -> final RL covering helpfulness/harmlessness**.
> 
> **DeepSeek V3.2**: SIngle mixed RL stage merging reasoning + agent + human-alignment, explicitly to dodge catastrophic forgetting from multi-stage pipelines. **GRPO stabilization tricks** for scaling compute (post-training budget > 10% of pretraining cost). Unbiased KL estimate, Off-Policy Sequence Masking, for MoE freeze the expert-routing paths from sampling and reuse them in training, so identical expert params get optimized (crucial for MoE RL stability), keep sampling mask, **Generative reward model with per-prompt rubrics** for general/hard-to-verify tasks, Large scale agentic task synthesis, Cold-start for thinking-in-tool-use, and **DeepSeek-V3.2-Speciale** - reasoning-only RL with relaxed length penalty + DeeSeekMath-V2 proof data, the official V3.2 deliberately tightened the length penalty to trade off cost vs peak reasoning.
> 
> **DeepSeek V4**: Mixed RL replaced by On-Policy Distillation (**OPD**), train independent domain specialist (each via SFT->GRPO) then merge into one student via **multi-teacher OPD**, minimizing reverse KL on the students own trajectories. Avoids weight-merging/mixed-RL degradation. Full vocab logit distillation instead of cheaper per-token KL estimate. lower-variance gradients, more stable than reusing the RL advantage-estimate trick > 10 teachers, each possibly trillion-scale. **Generative Reward Model (GRM)** - the actor itself serves as judge, with RL applied directly to the GRM, fusing generation and evaluation; rubric-guided RL for hard-to-verify tasks, replacing RLHF reward models. **Reasoning-effort modes** (Non-think/High/Max) trained with distinct length penalties and context windows in RL. **Infra for RL/OPD** FP4 (MXFP4) quantized rollouts and teacher/reference forwards; **preemptible, fault-tolerant rollout** via token-granular Write-Ahead Log; **million-token-context RL** scaling; **DSec** sandbox platform for agentic RL environments.
> 
> ### Full Arc
> PPO -> GRPO with verifiable rewards (**R1**) -> a unified mixed-RL stage (**V3.2**) -> specialist GRPO + generative/rubric reward models, then collapse into one model by full-vocabulary on-policy distillation, on FP4 fault-tolerant million-token infra (**V4**).
> 
> RL in MoE differs because routing makes gradients spiky, the load balancing objective fights the policy gradient, expert parallelism spreads rollout generation across many GPUs, and the reference model for the KL also has to run in MoE mode which roughly doubles the expert memory unless you offload.
> 
> ---
> _will cover the infra section in the next part!_
> 
> [Original page](https://www.k-a.in/rl-algo.html)
