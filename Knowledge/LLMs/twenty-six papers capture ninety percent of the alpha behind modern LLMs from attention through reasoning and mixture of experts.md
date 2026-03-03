---
created: 2026-02-23
description: A curated reading order of 26 essential papers spanning transformer foundations, scaling laws, alignment, reasoning, and mixture-of-experts architectures that together cover the core knowledge needed to deeply understand modern LLMs.
source: https://x.com/TheAhmadOsman/status/2025420463715803567
type: framework
---

## Key Takeaways

The list is structured as a dependency graph, not a flat bibliography. It opens with the original Transformer paper and Jay Alammar's visual guide, then layers on BERT's encoder-side pretraining and GPT-3's in-context learning — establishing the two branches that later converge in modern decoder-only architectures. This pedagogical sequencing matters because each paper's contribution only clicks when you've absorbed the one before it, much like how [[skill graphs outperform single skill files by letting agents traverse linked domain knowledge on demand|skill graphs]] work better than flat lists.

Scaling laws form a critical inflection point in the list. Kaplan (2020) gives the first clean empirical framework, and Chinchilla (2022) corrects it by showing token count matters more than parameter count for a fixed compute budget. Together they explain why LLaMA's open-weight approach worked — it followed Chinchilla-optimal training rather than chasing raw parameter counts. The "Textbooks Are All You Need" paper extends this further: high-quality synthetic data lets small models outperform much larger ones, suggesting that data quality dominates both parameters and raw token volume.

The alignment and reasoning cluster (InstructGPT, DPO, Chain-of-Thought, ReAct, DeepSeek-R1) traces a clear arc from post-training alignment to emergent reasoning. ReAct's combination of reasoning traces with tool use is explicitly called "the foundation of agentic systems," connecting directly to [[agent-first engineering replaces coding with environment design scaffolding and feedback loops|agent-first engineering]] where the environment design matters more than the model. DeepSeek-R1 then proves that reinforcement learning alone, without supervised data, can induce self-verification — a result that reshapes how we think about [[OpenAI internal data agent succeeds through six layers of context not model capability alone|context layers]] driving capability.

The Mixture-of-Experts (MoE) arc spans from the 2017 Shazeer paper through Switch Transformers and Mixtral to Sparse Upcycling. The key insight is that sparse models can match dense quality while running at small-model inference cost — conditional computation lets you scale total parameters without scaling active compute. Qwen3's unified thinking/non-thinking modes represent the current frontier of this approach, dynamically trading off cost and reasoning depth.

Two papers sit outside the main technical arc but anchor the list's intellectual ambition: the Platonic Representation Hypothesis (evidence that scaled models converge toward shared internal representations across modalities) and Anthropic's Scaling Monosemanticity work (decomposing neural networks into millions of interpretable features). These suggest the field is moving toward both convergent representations and mechanistic understanding simultaneously.

The bonus papers — T5, Toolformer, GShard, and the original Jacobs (1991) and Jordan (1994) Mixture of Experts papers — trace MoE back to its pre-Transformer roots and round out the tool-use and transfer-learning foundations. FlashAttention's inclusion as the sole systems paper highlights that [[context tax compounds through cache misses bloated tools and unbudgeted output tokens|memory-efficient attention]] is not just an optimization but an enabler of long-context capability.

## External Resources

- [Attention Is All You Need](https://arxiv.org/abs/1706.03762) — the original Transformer paper (Vaswani et al., 2017)
- [The Illustrated Transformer](https://jalammar.github.io/illustrated-transformer/) — visual intuition builder for attention and tensor flow (Alammar, 2018)
- [BERT](https://arxiv.org/abs/1810.04805) — encoder-side pretraining and masked language modeling (Devlin et al., 2018)
- [GPT-3](https://arxiv.org/abs/2005.14165) — few-shot in-context learning at scale (Brown et al., 2020)
- [Scaling Laws](https://arxiv.org/abs/2001.08361) — empirical framework for parameters, data, and compute (Kaplan et al., 2020)
- [Chinchilla](https://arxiv.org/abs/2203.15556) — compute-optimal training shows tokens matter more than parameters (Hoffmann et al., 2022)
- [LLaMA](https://arxiv.org/abs/2302.13971) — open-weight era with RMSNorm, SwiGLU, RoPE defaults (Touvron et al., 2023)
- [RoFormer (RoPE)](https://arxiv.org/abs/2104.09864) — rotary position embeddings as the modern default (Su et al., 2021)
- [FlashAttention](https://arxiv.org/abs/2205.14135) — memory-efficient attention enabling long context (Dao et al., 2022)
- [RAG](https://arxiv.org/abs/2005.11401) — combining parametric models with external knowledge retrieval (Lewis et al., 2020)
- [InstructGPT](https://arxiv.org/abs/2203.02155) — instruction tuning and RLHF alignment blueprint (Ouyang et al., 2022)
- [DPO](https://arxiv.org/abs/2305.18290) — preference alignment without PPO (Rafailov et al., 2023)
- [Chain-of-Thought](https://arxiv.org/abs/2201.11903) — reasoning through prompting (Wei et al., 2022)
- [ReAct](https://arxiv.org/abs/2210.03629) — reasoning traces with tool use for agentic systems (Yao et al., 2022)
- [DeepSeek-R1](https://arxiv.org/abs/2501.12948) — RL-induced self-verification and structured reasoning (Guo et al., 2025)
- [Qwen3 Technical Report](https://arxiv.org/abs/2505.09388) — unified MoE with dynamic thinking modes (Yang et al., 2025)
- [Sparsely-Gated MoE](https://arxiv.org/abs/1701.06538) — conditional computation at scale (Shazeer et al., 2017)
- [Switch Transformers](https://arxiv.org/abs/2101.03961) — simplified single-expert MoE routing (Fedus et al., 2021)
- [Mixtral of Experts](https://arxiv.org/abs/2401.04088) — open-weight MoE matching dense quality at lower inference cost (Mistral AI, 2024)
- [Sparse Upcycling](https://arxiv.org/abs/2212.05055) — converting dense checkpoints to MoE (Komatsuzaki et al., 2022)
- [Platonic Representation Hypothesis](https://arxiv.org/abs/2405.07987) — convergent representations across modalities (Huh et al., 2024)
- [Textbooks Are All You Need](https://arxiv.org/abs/2306.11644) — high-quality synthetic data beats scale (Gunasekar et al., 2023)
- [Scaling Monosemanticity](https://transformer-circuits.pub/2024/scaling-monosemanticity/) — interpretable features from Claude 3 Sonnet (Templeton et al., 2024)
- [PaLM](https://arxiv.org/abs/2204.02311) — large-scale training orchestration (Chowdhery et al., 2022)
- [GLaM](https://arxiv.org/abs/2112.06905) — MoE scaling economics (Du et al., 2022)
- [The Smol Training Playbook](https://github.com/huggingface/smol-course) — practical handbook for efficient LM training (Hugging Face, 2025)

## Original Content

> @TheAhmadOsman — 2026-02-22
>
> BREAKING
>
> Elon Musk endorsed my Top 26 Essential Papers for Mastering LLMs and Transformers
>
> Implement those and you've captured ~90% of the alpha behind modern LLMs.
>
> Everything else is garnish.
>
> This list bridges the Transformer foundations with the reasoning, MoE, and agentic shift
>
> Recommended Reading Order
>
> 1. Attention Is All You Need (Vaswani et al., 2017) — The original Transformer paper. Covers self-attention, multi-head attention, and the encoder-decoder structure (even though most modern LLMs are decoder-only.)
>
> 2. The Illustrated Transformer (Jay Alammar, 2018) — Great intuition builder for understanding attention and tensor flow before diving into implementations
>
> 3. BERT: Pre-training of Deep Bidirectional Transformers (Devlin et al., 2018) — Encoder-side fundamentals, masked language modeling, and representation learning that still shape modern architectures
>
> 4. Language Models are Few-Shot Learners (GPT-3) (Brown et al., 2020) — Established in-context learning as a real capability and shifted how prompting is understood
>
> 5. Scaling Laws for Neural Language Models (Kaplan et al., 2020) — First clean empirical scaling framework for parameters, data, and compute. Read alongside Chinchilla to understand why most models were undertrained
>
> 6. Training Compute-Optimal Large Language Models (Chinchilla) (Hoffmann et al., 2022) — Demonstrated that token count matters more than parameter count for a fixed compute budget
>
> 7. LLaMA: Open and Efficient Foundation Language Models (Touvron et al., 2023) — The paper that triggered the open-weight era. Introduced architectural defaults like RMSNorm, SwiGLU and RoPE as standard practice
>
> 8. RoFormer: Rotary Position Embedding (Su et al., 2021) — Positional encoding that became the modern default for long-context LLMs
>
> 9. FlashAttention (Dao et al., 2022) — Memory-efficient attention that enabled long context windows and high-throughput inference by optimizing GPU memory access.
>
> 10. Retrieval-Augmented Generation (RAG) (Lewis et al., 2020) — Combines parametric models with external knowledge sources. Foundational for grounded and enterprise systems
>
> 11. Training Language Models to Follow Instructions with Human Feedback (InstructGPT) (Ouyang et al., 2022) — The modern post-training and alignment blueprint that instruction-tuned models follow
>
> 12. Direct Preference Optimization (DPO) (Rafailov et al., 2023) — A simpler and more stable alternative to PPO-based RLHF. Preference alignment via the loss function
>
> 13. Chain-of-Thought Prompting Elicits Reasoning in Large Language Models (Wei et al., 2022) — Demonstrated that reasoning can be elicited through prompting alone and laid the groundwork for later reasoning-focused training
>
> 14. ReAct: Reasoning and Acting (Yao et al., 2022 / ICLR 2023) — The foundation of agentic systems. Combines reasoning traces with tool use and environment interaction
>
> 15. DeepSeek-R1: Incentivizing Reasoning Capability in LLMs via Reinforcement Learning (Guo et al., 2025) — The R1 paper. Proved that large-scale reinforcement learning without supervised data can induce self-verification and structured reasoning behavior
>
> 16. Qwen3 Technical Report (Yang et al., 2025) — A modern architecture lightweight overview. Introduced unified MoE with Thinking Mode and Non-Thinking Mode to dynamically trade off cost and reasoning depth
>
> 17. Outrageously Large Neural Networks: Sparsely-Gated Mixture of Experts (Shazeer et al., 2017) — The modern MoE ignition point. Conditional computation at scale
>
> 18. Switch Transformers (Fedus et al., 2021) — Simplified MoE routing using single-expert activation. Key to stabilizing trillion-parameter training
>
> 19. Mixtral of Experts (Mistral AI, 2024) — Open-weight MoE that proved sparse models can match dense quality while running at small-model inference cost
>
> 20. Sparse Upcycling: Training Mixture-of-Experts from Dense Checkpoints (Komatsuzaki et al., 2022 / ICLR 2023) — Practical technique for converting dense checkpoints into MoE models. Critical for compute reuse and iterative scaling
>
> 21. The Platonic Representation Hypothesis (Huh et al., 2024) — Evidence that scaled models converge toward shared internal representations across modalities
>
> 22. Textbooks Are All You Need (Gunasekar et al., 2023) — Demonstrated that high-quality synthetic data allows small models to outperform much larger ones
>
> 23. Scaling Monosemanticity: Extracting Interpretable Features from Claude 3 Sonnet (Templeton et al., 2024) — The biggest leap in mechanistic interpretability. Decomposes neural networks into millions of interpretable features
>
> 24. PaLM: Scaling Language Modeling with Pathways (Chowdhery et al., 2022) — A masterclass in large-scale training orchestration across thousands of accelerators
>
> 25. GLaM: Generalist Language Model (Du et al., 2022) — Validated MoE scaling economics with massive total parameters but small active parameter counts
>
> 26. The Smol Training Playbook (Hugging Face, 2025) — Practical end-to-end handbook for efficiently training language models
>
> Bonus Material: T5 (Raffel et al., 2019), Toolformer (Schick et al., 2023), GShard (Lepikhin et al., 2020), Adaptive Mixtures of Local Experts (Jacobs et al., 1991), Hierarchical Mixtures of Experts (Jordan and Jacobs, 1994)
>
> If you deeply understand these fundamentals — Transformer core, scaling laws, FlashAttention, instruction tuning, R1-style reasoning, and MoE upcycling — you already understand LLMs better than most. Time to lock-in, good luck!
>
> *Header graphic showing the 26 papers organized by category*
> ![[ahmadosman-803567-001.jpg]]
>
> Engagement: 1241 likes | 117 retweets | 32 replies
> [Original post](https://x.com/TheAhmadOsman/status/2025420463715803567)
