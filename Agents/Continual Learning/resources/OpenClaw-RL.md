---
created: 2026-02-27
source: https://github.com/Gen-Verse/OpenClaw-RL
type: resource
tags: [reinforcement-learning, personalization, continual-learning, self-hosted]
status: unread
---

## What it is

OpenClaw-RL is a fully asynchronous reinforcement learning framework that turns live conversations into training signals for personalized AI agents. It wraps a self-hosted model as an OpenAI-compatible API via OpenClaw, intercepts multi-turn conversations, and continuously optimizes the policy in the background — no batch collection, no interruption to usage. Four decoupled async components: model serving, rollout collection, PRM judging, and policy training.

## Why it's interesting

Most RL-for-LLM systems assume centralized batch training on pre-collected data. This flips that — the model improves from natural use in real time. It supports two learning paradigms: binary RL (GRPO with process reward model scoring) and on-policy distillation (where hindsight from the next user message becomes a teaching signal). Everything runs on your own hardware with no data leaving your system. The roadmap extends to learning skills and memory, not just policy weights.

## How it works

**Four async components:** Model serving, rollout collection, PRM (Process Reward Model) judging, and policy training run as independent async loops — none block each other. The model serves requests while training runs in the background.

**Conversation → training signal:** The system intercepts live multi-turn conversations via an OpenAI-compatible API wrapper. It classifies turns into main-line (trainable) vs. side (non-trainable), uses the next user message as a natural "next state" signal, and runs PRM evaluation asynchronously with majority voting.

**Two learning paradigms:** (1) *Binary RL (GRPO)*: PRM scores each turn as good/bad/neutral, scalar reward feeds into GRPO advantage estimation with PPO-style clipped surrogate loss. (2) *On-Policy Distillation (OPD)*: A judge model extracts textual hints from hindsight (the next state), creates an "enhanced teacher" prompt, and the token-level log-probability gap between teacher and student becomes a directional advantage signal.

**Safety:** Graceful weight updates pause submission during model updates. At-least-one guarantee ensures every session contributes a training sample. All conversations and PRM evaluations logged to JSONL.

## Key links

- [GitHub](https://github.com/Gen-Verse/OpenClaw-RL)
- [OpenClaw](https://openclaw.ai)

## Notes

- Requires 8× GPUs by default (configurable)
- Session-aware training with proper multi-turn ordering
- Logs all conversations and PRM evaluations to JSONL for analysis
- Roadmap includes scaling to general agent optimization (computer-use first)
