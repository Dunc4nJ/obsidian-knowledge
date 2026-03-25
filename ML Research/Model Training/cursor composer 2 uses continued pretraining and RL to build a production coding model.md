---
created: 2026-03-25
description: Cursor releases a technical report detailing how Composer 2 was trained through continued pretraining, reinforcement learning, and custom benchmark development to create a highly capable coding model.
source: https://x.com/cursor_ai/status/2036566152525009146
type: synthesis
---

## Key Takeaways

Cursor's Composer 2 training pipeline reveals a three-pronged approach that mirrors trends seen in [[RL environments are the new unit of progress in agentic AI training]] — continued pretraining, reinforcement learning, and benchmark development — all designed to closely emulate the real Cursor IDE environment. This is significant because it shows a product company investing deeply in custom model training rather than relying solely on frontier API models.

The continued pretraining phase delivers consistent downstream coding improvements, suggesting that domain-specific corpus curation remains a high-leverage activity even when starting from strong base models. This aligns with findings in [[stable agentic RL requires sequence-level clipping and environment-aware advantages to prevent training collapse]] about the importance of stable training foundations before RL.

Their RL phase is described as "critical for final performance," with the notable finding that simple approaches often work best and improve performance broadly. This echoes the GRPO-style simplification trend where heavy critic models give way to lighter, more practical methods — a pattern also explored in [[CodeGym converts coding problems into interactive tool-use environments for generalizable agent RL]].

CursorBench, their internal benchmark, prioritizes realistic coding problems over synthetic ones. This is a deliberate pushback against benchmarks that fail to capture the complexity software engineers encounter daily — the gap between leaderboard performance and real-world utility that many practitioners have noted.

The infrastructure effort is substantial: custom kernels (open-sourced), distributed training, and environment scaling for RL. Partners include Fireworks AI and Colfax, built on top of Kimi K2.5 as the base model, with Ray, ThunderKittens, and PyTorch in the stack.

## External Resources

- [Composer 2 Technical Report](https://t.co/cfW8lyMWEy) — full technical report from Cursor
- [Kimi K2.5](https://github.com/MoonshotAI) — base model by Moonshot AI
- [ThunderKittens](https://github.com/HazyResearch/ThunderKittens) — GPU kernel library from Hazy Research
- [Ray](https://github.com/ray-project/ray) — distributed computing framework used for training
- [Fireworks AI](https://fireworks.ai/) — inference and training infrastructure partner

## Original Content

> **@cursor_ai** (Cursor) — Tue Mar 24, 2026 — 255 likes, 13 retweets, 4 replies
>
> We're releasing a technical report describing how Composer 2 was trained.

*Composer 2 technical report cover*
![[cursor_ai-009146-001.jpg]]

> Composer 2 had three main efforts: continued pretraining, reinforcement learning, and benchmark development.
>
> The goal of each was to closely emulate the Cursor environment to produce a highly intelligent coding model.

*Training pipeline overview — three main efforts*
![[cursor_ai-009146-002.jpg]]

> We show how continued pretraining results in consistent improvements in downstream coding performance.

*Continued pretraining results*
![[cursor_ai-009146-003.jpg]]

> The reinforcement learning phase is critical for final performance. We discuss the algorithms we apply for this stage.
>
> We find that simple approaches often work best, and improve performance broadly.

*Reinforcement learning performance improvements*
![[cursor_ai-009146-004.jpg]]

> We describe our internal benchmark CursorBench which represents a more realistic sampling of coding problems.
>
> We discuss why we think it is important to include the complex problems software engineers see everyday.

*CursorBench benchmark design*
![[cursor_ai-009146-005.jpg]]

> We go into detail about the infrastructure behind large scale training including the kernels we developed and open-sourced for the project.
>
> We also discuss distributed training and environment scaling for RL.

*Training infrastructure and kernel development*
![[cursor_ai-009146-006.jpg]]

> Thank you to the companies and open-source communities behind Kimi K2.5, Ray, ThunderKittens, PyTorch, and more.
>
> We'd also like to thank Fireworks and Colfax for their collaboration and partnership.

> Read the full report: https://t.co/GLY24X0Gov

*Full report link card*
![[cursor_ai-009146-007.png]]

Source: https://x.com/cursor_ai/status/2036566152525009146
