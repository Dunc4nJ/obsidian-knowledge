---
created: 2026-02-27
description: OpenClaw-RL is a fully asynchronous RL framework that turns real agent conversations into training signals, running model serving, rollout collection, PRM judging, and policy training as independent non-blocking loops.
source: https://x.com/YinjieW2024/status/2027011510103363837
type: framework
---

## Key Takeaways

*OpenClaw-RL feature overview: async architecture, self-hosted, auto conversation-to-gradient pipeline, two learning paradigms*
![[yinjiew-363837-001.jpg]]

OpenClaw-RL solves the fundamental gap that [[learning machines turn agents from stateless tools into systems that compound knowledge across users and sessions]] identifies — agents don't learn from their interactions. The system turns real conversations into RL training signals automatically, with no manual labeling. The key architectural decision is making everything asynchronous: the agent keeps serving users while training runs in the background. This is the opposite of the typical train-then-deploy cycle.

*Async architecture: OpenClaw client talks to a server with decoupled model server, PRM server, and training engine*
![[yinjiew-363837-002.jpg]]

The system decouples four components into independent async loops: agent serving, rollout collection, PRM (Process Reward Model) judging, and policy training. None block each other. This means you can deploy the model and it improves continuously from real usage — the model serves requests while training runs on collected rollouts in the background, and PRM evaluation happens concurrently with new conversations.

*Training method 1: binary RL with PRM majority voting produces r ∈ {-1, 0, +1} rewards from conversational feedback*
![[yinjiew-363837-003.png]]

Two training paradigms are supported. **Binary RL (GRPO)** uses the next user or environment message as implicit feedback — a PRM evaluates the (response, feedback) pair via majority voting to produce a ternary reward (bad/neutral/good). This requires zero manual annotation but feedback is coarse. The policy is trained with a PPO-style clipped surrogate objective plus KL penalty to prevent drift from the reference model.

*Training method 2: on-policy distillation extracts hindsight hints from next-state for directional improvement signals*
![[yinjiew-363837-004.png]]

**On-Policy Distillation (OPD)** is more sophisticated — it extracts textual hindsight hints from the next conversational turn, creates an "enhanced teacher" by conditioning the model on the hint, and uses the log-probability gap between teacher and student as a token-level advantage signal. This is directional rather than just scalar — it tells the model *what to change*, not just that something was wrong. This connects to the insight in [[recursive self-improvement works when LLM judges detect friction patterns and the agent implements its own fixes]] — the feedback loop needs to be specific enough to guide improvement.

*Roadmap: from personal agent optimization to general computer-use agent RL*
![[yinjiew-363837-005.png]]

The project is fully open source and self-hosted — runs entirely on your own infrastructure with no external API dependencies. The roadmap extends from personal agent optimization (v1, released) to general computer-use agents, which naturally produce grounded feedback during real execution, making them ideal targets for continuous online RL.

Community discussion raised important questions: catastrophic forgetting ("last time I saw a rolling LLM it lost 90% of its training data over useless personal data"), whether RL is necessary when Claude Code/Codex dominate with zero fine-tuning (runtime adaptation via prompts + memory may be sufficient at high capability thresholds), and how to define the objective function. The [[file-based personal OS gives AI agents persistent identity and judgment across sessions]] approach offers a complementary non-parametric alternative.

## External Resources

- [OpenClaw-RL GitHub](https://github.com/Gen-Verse/OpenClaw-RL) — fully open source async RL framework for agents
- [Project page](https://yinjjiew.github.io/projects/openclawrl/) — blog post with additional details
- [OpenClaw](https://openclaw.ai/) — the agent framework OpenClaw-RL builds on

## Original Content

> @YinjieW2024 (Yinjie Wang) — Feb 26, 2026 — 494 likes, 53 retweets
>
> Train your @openclaw simply by talking to it. Meet OpenClaw-RL. Host your model on our RL server, and your LLM gets optimized automatically. Use it anywhere. Keep it private. Make it more personal every day. We have fully open sourced everything. Come in and have fun!
>
> ---
>
> We built a fully asynchronous RL system for OpenClaw. Just use your model in OpenClaw as usual, and the RL backend automatically turns real conversations into training signals to continuously improve your LLM.
>
> ---
>
> 2. We decouple agent serving, rollout collection, PRM judging, and policy training into independent async loops. None of them block one another — the model serves requests while training runs in the background, and PRM evaluation happens concurrently with new conversations.
>
> ---
>
> 3. We convert conversation into real training signals to conduct reinforcement learning.
>
> ---
>
> 4. We also support on-policy distillation. Specifically, we extract hindsight hints from next-state and construct enhanced teacher, which provides rich textual feedback and enables directional improvement.
>
> ---
>
> 5. We will keep update agentic RL infra / algorithm on computer use agents
>
> ---
>
> **Notable community discussion:**
>
> @lucasygu_: "genuine question for the OpenClaw-RL team: if RL is necessary for coding agents to learn *when* to use tools, how do you explain Claude Code and Codex dominating with zero fine-tuning? at some capability threshold, runtime adaptation (prompts + memory) seems to just... work."
>
> @Cypher_Samurai: "What's the catch? Last time I saw a rolling LLM it lost 90% of its training data over useless personal data"
>
> @leon2mcp: "Been running OpenClaw daily for months and the biggest limitation is the model never learns from past sessions. RL from real conversations could close that loop."
>
> @kavindpadi: "Looks promising.. but don't fully follow.. I see the rewards, but how is it used for the current conversation to improve?"
> @YinjieW2024: "The RL backend trains the model with these rewards. This is a fully async RL framework so training will not influence your inference"

[Original thread](https://x.com/YinjieW2024/status/2027011510103363837)
