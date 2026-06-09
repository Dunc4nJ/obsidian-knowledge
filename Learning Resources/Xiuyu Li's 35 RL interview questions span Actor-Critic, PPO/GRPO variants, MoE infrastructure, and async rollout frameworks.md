---
created: 2026-06-09
description: Xiuyu Li (@sheriyuo) distilled 35 RL interview questions from Zhihu hiring experiences, split into 19 algorithm and 16 infrastructure questions, with no reference answers provided by design because LLM-generated answers were ~50% wrong.
source: https://x.com/sheriyuo/status/2063295181131247674
type: learning
---

## Key Takeaways

- Modern RL hiring is full-stack: algorithm researchers get infrastructure questions and infrastructure engineers get algorithm questions — the 35 questions intentionally cross this boundary, making siloed prep insufficient. Compare with [[LLM optimization interview prep maps Flash Attention, ZeRO, speculative decoding, and MoE across training and inference]] which covers the ML systems side thoroughly.
- The 19 algorithm questions probe PPO/GRPO mechanics, KL divergence and its removal in DAPO/GSPO, reward design, importance sampling, and an entire ecosystem of GRPO variants (Dr.GRPO, DAPO, GSPO, CISPO, SAPO, DPPO, MaxRL, SimKO) — the companion answer key is [[Arjun Kocher's RL algorithm Q&A traces PPO, GRPO, DAPO, and the DeepSeek R1-to-V4 training arc]].
- The 16 infrastructure questions are unusually deep: memory copies during GRPO training, KV cache transfer in distributed inference, INT8/FP8 tradeoffs, long-tail rollout mitigation, batch invariance and atomic add, and comparative design choices across VeRL, TRL, Unsloth, AReaL, and slime — topics that surface directly in [[agentic RL training converges on outcome rewards inside production harnesses across Kimi Cursor and Chroma]].
- No reference answers are intentionally provided: after reading LLM-generated answers and finding roughly half wrong, the author explicitly chose not to publish a ground truth key — the point is depth of understanding, not memorization.
- The question set deliberately excludes data-related questions because those are impossible to memorize and depend on direct experience, signaling that this list targets reasoning-level competence, not pattern-matching. See [[mid-training builds the reasoning foundation that RL amplifies not replaces]] for why deep understanding scales further than memorized answers in RL contexts.

## External Resources

- [Zhihu CN version](https://zhuanlan.zhihu.com/p/2046740446353811230) — Chinese original source combining Zhihu interview experiences
- [@vivek_2332's comprehensive answer thread](https://x.com/vivek_2332/status/2063566811749331353) — community-contributed algorithm + infra answers the author called "the best answer I've seen today"
- [@bluequbit's notes on some questions](https://t.co/yvp5Fehleh) — additional community annotations

## Original Content

### Section 1: X Article — @sheriyuo (Xiuyu Li), 2026-06-06

> @sheriyuo — 2026-06-06
>
> **Article: RL Interview Questions 2026**
>
> After seeing several people receive PhD offers and then immediately land highly paid industry positions during spring recruiting, I started wondering whether going straight into industry might actually be the better move.
>
> So I went through essentially every RL-related interview experience I could find on Zhihu, combined them with recent discussions and my own observations, and distilled everything into 35 of the most interesting questions.
>
> Think of it as an RL interview benchmark.
>
> CN version in Zhihu: https://zhuanlan.zhihu.com/p/2046740446353811230
>
> A few notes:
>
> - The list does not strictly separate LLM RL from Agentic RL. Some questions have very different answers depending on the setting.
>
> - Nearly every question can be extended much further. No reference answers are provided. If you use an LLM, keep asking follow-up questions and search extensively.
>
> - Modern RL hiring increasingly expects full-stack understanding. If you are an algorithm researcher, people will still ask infrastructure questions. The reverse is also true.
>
> - Data-related questions are not included. Those are almost impossible to memorize and depend heavily on your actual experience.
>
> - Memorizing interview questions is not enough. Deep understanding matters far more.
>
> **Algorithm**
>
> 1. Why use Actor-Critic instead of a pure Critic approach?
>
> 2. What is the relationship between KL divergence, cross entropy, and MLE?
>
> 3. How should rewards be designed in different RL scenarios?
>
> 4. How do importance sampling, rejection sampling, and other Monte Carlo methods fit into RL?
>
> 5. How is advantage computed in PPO and GRPO? Why subtract a baseline? Is standard deviation normalization really necessary?
>
> 6. How do RL training and test-time scaling perform exploration differently?
>
> 7. How does PPO clipping work? Why take the minimum objective? What happens without clipping? How does CISPO differ?
>
> 8. Why does GRPO include a KL penalty? How is the KL computed? Why do methods such as DAPO and GSPO remove it?
>
> 9. During LLM training, what happens if loss is accidentally All Reduced multiple times?
>
> 10. What is the reward function in DPO? Can reward hacking occur? How can it be mitigated?
>
> 11. What methods address train-inference mismatch in MoE models, and how do they work?
>
> 12. How should group size, learning rate, PPO epochs, and generation length be selected during RL training?
>
> 13. Compared with GRPO, how do Dr.GRPO, DAPO, GSPO, CISPO, SAPO, DPPO, MaxRL, and SimKO improve the training process? What are their limitations?
>
> 14. How do TRPO, DPPO, and AReaL enforce trust-region constraints on RL objectives?
>
> 15. Can RL fundamentally expand the capability frontier of LLMs?
>
> 16. Based on works such as ProRL, how should we think about scaling the boundaries of RL training?
>
> 17. What improvements does OPD introduce over traditional RL and SFT? What are its applications?
>
> 18. At which stage of training does reasoning ability emerge in LLMs?
>
> 19. From DeepSeek R1 to V3.2 and future V4 systems, what RL-related improvements have been introduced? How is RL different in MoE models?
>
> **Infrastructure**
>
> *RL training framework architecture: Distributed Executor with Parallel Workers (Actor/Critic/Environment/Reward), Rollout Scheduler, vLLM/SGLang/Megatron/DeepSpeed strategies, and the Generation→Infer→Train runtime loop*
> ![[sheriyuo-247674-001.jpg]]
>
> 1. Ignoring CPU offload, how many model copies exist in memory during GRPO training? How much memory can various optimizations save?
>
> 2. Distributed inference: KV cache transfer optimization and multi-GPU communication strategies.
>
> 3. INT8 versus FP8. What are the tradeoffs? Which precisions are preferred for training and inference?
>
> 4. What is the long-tail problem in RL rollouts, and how can it be addressed?
>
> 5. What issues does continuous batching introduce in RL training? How do vLLM and SGLang differ?
>
> 6. How do you measure utilization in vLLM and SGLang? How do you evaluate KV cache utilization during training?
>
> 7. How is backpropagation implemented in large-scale multi-node RL training?
>
> 8. What asynchronous RL frameworks exist, and what synchronization bottlenecks do they solve?
>
> 9. In AReaL or other partially rollout frameworks, are KV caches from previous policies preserved?
>
> 10. How does Expert Parallelism affect MoE throughput?
>
> 11. In long-context training, how should compute-communication overlap be designed? How do Megatron and FSDP differ in parallelism strategies?
>
> 12. How do you enable deterministic execution? What is batch invariance? What causes it? Is atomic add involved? Can atomic add solve the issue?
>
> 13. How do AReaL and slime differ in their understanding of the RL rollout bottleneck?
>
> 14. How should we think about staleness in fully asynchronous RL training? What are typical values in practice?
>
> 15. How does data flow through slime? How is it integrated with Megatron? How is the loss computed?
>
> 16. If you had to choose among VeRL, TRL, Unsloth, AReaL, and slime, which one would you use and why?
>
> Good luck.
>
> And remember: interview preparation helps, but genuine understanding scales much further than memorized answers.
>
> [Original post](https://x.com/sheriyuo/status/2063295181131247674)

> [!quote]- Thread Replies (bird thread capture)
>
> @Lilian11120981 (加密可爱多Lilian), 2026-06-06:
>
> @sheriyuo 懂了，大家都挺会玩花样的，逻辑很完整，就是细想一下有点拧巴。。。。
>
> ---
>
> @YuvrajS9886 (Yuvraj Singh), 2026-06-06:
>
> @sheriyuo This is good man!
>
> ---
>
> @vivilinsv (Vivi), 2026-06-06:
>
> @sheriyuo This is so thorough and thoughtful - thank you for pulling them together and sharing with us!
>
> ---
>
> @Blum_OG (Blum), 2026-06-06:
>
> @sheriyuo solid article bro, appreciate how you break down all the details
>
> ---
>
> @Colonizingmaga (colonizing Maga), 2026-06-06:
>
> @sheriyuo Thanks for this
>
> ---
>
> @ZeYUAN324134 (Ze YUAN), 2026-06-07:
>
> @sheriyuo Thank you for sharing!
>
> ---
>
> @bluequbit (shubham), 2026-06-07:
>
> @sheriyuo Few notes on some questions — https://t.co/yvp5Fehleh
>
> ---
>
> @sheriyuo self-reply, 2026-06-07:
>
> This is the best answer I've seen today.
>
> After reading a bunch of LLM generated notes and finding that roughly half of them were wrong, I've become even more reluctant to provide ground truth answers.
>
> https://t.co/ah1LYLhUhY
>
> > QT @vivek_2332: went through most of these. dumping my answers in case anyone studying rl finds it useful.
> > https://x.com/vivek_2332/status/2063566811749331353
>
> ---
>
> @pradheepraop (pradheep), 2026-06-07:
>
> @sheriyuo the list is insane, would love to slowly try answering these and quote this in a bit 😁
>
> ---
>
> @AryanPa66861306 (Aryan Pandey), 2026-06-07:
>
> @sheriyuo Don't worry guys I don't think in India anybody is hiring reinforcement learning engineer, in india rag/mcp is AI, they called backend a AI.
>
> ---
>
> @0xHongliang (Hongliang), 2026-06-07:
>
> @sheriyuo 已严肃将其转至小群
>
> ---
>
> @Feixiang_Tao (空心石), 2026-06-07:
>
> @sheriyuo 严肃学习...
>
> ---
>
> @houhaowen (Haowen Hou), 2026-06-08:
>
> @sheriyuo super cool

### Section 2: Notion Page — https://app.notion.com/p/RL-Interview-Questions-2026-378802359a2a80079bbff139272e0aee

*The Notion page is a JavaScript-only render and was inaccessible to all automated capture methods (markdown.new, playbooks, curl with browser UA, Notion API). The X Article in Section 1 contains the complete question set — all 35 questions across both Algorithm and Infrastructure categories, verbatim as published.*
