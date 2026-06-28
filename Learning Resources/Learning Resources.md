---
created: 2026-03-15
description: Map of Content for learning resources, study guides, courses, and certification prep materials.
---

# Learning Resources

Study guides, courses, and certification materials.

## Study Guides

- [[Claude Certified Architect exam covers five domains from agentic loops to context management]] — comprehensive self-study breakdown of all five exam domains with tutor prompts and build exercises

## Inference & serving → moved to ML Research/Inference/

These vLLM/inference explainers were re-homed to the inference folder — see [[moc - Inference]] (kept discoverable here):

- [[Joe Barrow reviews Philip Kiely's Inference Engineering as the reference work he wishes he had in 2023, with a curated what-to-read-next list]] — breadth-first review of the LLM inference-stack reference (engine selection, quantization, speculative decoding, disaggregation) + curated reading map
- [[Amit Shekhar explains how vLLM packs more LLM users onto one GPU through PagedAttention and continuous batching]] — beginner-friendly vLLM walkthrough (PagedAttention KV paging, prefix/beam sharing, continuous batching, OpenAI-compatible API)

## Interview Prep

- [[technmak's AI-ML Engineer Interview Guide for 2026 Part 1 spans classical ML, multimodal systems, and preference optimization across six domains]] — comprehensive Part 1 covering bias-variance, calibration, statistics, LLM fundamentals (FlashAttention, RoPE, long context), multimodal systems, LoRA/QLoRA, DPO/PPO/GRPO/KTO/ORPO, MoE, and prompting
- [[LLM optimization interview prep maps Flash Attention, ZeRO, speculative decoding, and MoE across training and inference]] — Gauri Gupta's AI lab interview notes on memory, compute, inference, and distributed-training optimization
- [[Xiuyu Li's 35 RL interview questions span Actor-Critic, PPO/GRPO variants, MoE infrastructure, and async rollout frameworks]] — the question set: 19 algorithm questions (PPO/GRPO variants, KL divergence, reward design, DAPO/GSPO/CISPO family) + 16 infrastructure questions (memory footprints, vLLM/SGLang, AReaL/slime/VeRL); no reference answers provided
- [[Arjun Kocher's RL algorithm Q&A traces PPO, GRPO, DAPO, and the DeepSeek R1-to-V4 training arc]] — Arjun Kocher's answers to Xiuyu Li's curated RL questions: actor-critic rationale, advantage estimation, PPO/GRPO/DAPO mechanics, DPO reward hacking, MoE mismatch, ProRL long-horizon stability, OPD distillation, and the full DeepSeek training arc
