---
created: 2026-02-27
description: Survey of the emerging self-serve post-training infrastructure category — Prime Intellect Lab, Tinker, Harbor RL, and CGFT — tools that let enterprises run their own RL/fine-tuning loops without managing GPU clusters.
source: https://x.com/SeanZCai/status/2027459906543226921
type: knowledge
---

# Self-serve post-training infrastructure is emerging as the key layer between foundation models and enterprise adoption

Enterprise workflows are subjective, org-specific, and often run in regulated/on-prem environments where cloud models can't be used out of the box. Post-training (RL, SFT, RLHF) is getting easier, and a new category of tools is emerging to let teams run their own model→product optimization loops — without managing distributed GPU infrastructure or building RL pipelines from scratch.

The bottleneck isn't model capability; it's **last-mile implementation** — getting a foundation model to reliably execute bespoke workflows that require taste, judgment, and domain knowledge. These tools address that gap.

## The landscape

### Prime Intellect Lab — full-stack self-serve post-training

The most complete open offering. Three components:

1. **Environments Hub** — community marketplace of 1,000+ RL environments (task datasets + agent harnesses + scoring rubrics) built by 250+ creators
2. **Hosted Training** — large-scale agentic RL with LoRA on their GPU infrastructure
3. **Hosted Evaluations** — evaluate model capabilities using the same environments

An "environment" bundles a dataset of tasks, a harness (tools/sandboxes/context), and a scoring rubric. Can be used for RL training, evals, synthetic data generation, prompt optimization, or agent harness experimentation.

Workflow: `prime lab setup` → scaffolds project → develop environment (or pick from marketplace) → launch training runs → get model weights you own (no API lock-in).

They trained INTELLECT-3 (100B+ MoE) and INTELLECT-2 (distributed RL training of 32B) on their own stack, which gives credibility to the tooling.

Position themselves as "the Bazaar to the big lab Cathedrals" — any company should be able to run its own optimization loop (like how Cursor post-trains models on their IDE as the RL environment).

**Open source:** Yes — underlying training library is fully open.

| Resource | Link |
|---|---|
| Homepage | https://www.primeintellect.ai/ |
| Lab launch blog | https://www.primeintellect.ai/blog/lab |
| Environments Hub blog | https://www.primeintellect.ai/blog/environments |
| Environments browser | https://app.primeintellect.ai/dashboard/environments |
| `prime-rl` (async RL training, FSDP2 + vLLM) | https://github.com/PrimeIntellect-ai/prime-rl |
| INTELLECT-3 blog | https://www.primeintellect.ai/blog/intellect-3 |
| INTELLECT-2 blog | https://www.primeintellect.ai/blog/intellect-2 |

---

### Tinker — managed training API with maximum control

Four primitives, nothing else:

- `forward_backward` — compute gradients
- `optim_step` — update weights
- `sample` — generate tokens (for eval or RL rollouts)
- `save_state` — checkpoint

You write a standard Python loop: sample rollouts → score with your reward function → call `forward_backward` with RL loss → `optim_step`. Tinker handles all distributed compute behind the API. LoRA-based (backed by their "LoRA Without Regret" research arguing LoRA matches full fine-tuning for most post-training). Supports models from Llama-3.2-1B up to Qwen3-235B, DeepSeek-V3.1, and Kimi-K2.

Andrej Karpathy praised the design as *"a more clever place to slice up the complexity of post-training"* vs. the upload-data-and-we-train-for-you paradigm. Users include SkyRL (Berkeley), Goedel Prover, Redwood Research, and Stanford StatMech.

**Open source:** API is commercial (pay-per-token). Cookbook with recipes is open.

| Resource | Link |
|---|---|
| Product page | https://thinkingmachines.ai/tinker/ |
| Docs | https://tinker-docs.thinkingmachines.ai/ |
| RL docs | https://tinker-docs.thinkingmachines.ai/rl |
| Announcement blog | https://thinkingmachines.ai/blog/announcing-tinker/ |
| LoRA research blog | https://thinkingmachines.ai/blog/lora/ |
| Cookbook (GitHub) | https://github.com/thinking-machines-lab/tinker-cookbook |
| VentureBeat coverage | https://venturebeat.com/ai/thinking-machines-first-official-product-is-here-meet-tinker-an-api-for |

---

### Harbor RL — containerized eval + rollout generation infrastructure

From the **Laude Institute** (creators of Terminal-Bench). Harbor is the plumbing layer — it doesn't do RL training itself but generates the rollouts that feed into RL pipelines.

Provides:
- Modular interfaces for environments, agents, and tasks (all containerized)
- Pre-integrated popular CLI coding agents
- Registry of benchmarks and datasets (including Terminal-Bench 2.0)
- Cloud sandbox integrations: Daytona, Modal, E2B for horizontal scaling
- RL/optimization integrations: SkyRL and GEPA for agent optimization
- SFT trace generation and RL rollout generation in sandboxed containers

Think of it as "the gym" — define tasks in containers, run agents against them, collect rollouts, pipe those into RL training via SkyRL or similar.

**Open source:** Yes, fully.

| Resource | Link |
|---|---|
| Homepage | https://harborframework.com/ |
| Docs | https://harborframework.com/docs |
| GitHub | https://github.com/laude-institute/harbor |
| Terminal-Bench 2.0 announcement | https://www.tbench.ai/news/announcement-2-0 |
| HuggingFace dataset | https://huggingface.co/datasets/harborframework/terminal-bench-2.0 |
| VentureBeat coverage | https://venturebeat.com/ai/terminal-bench-2-0-launches-alongside-harbor-a-new-framework-for-testing |

Install: `uv tool install harbor`

---

### CGFT — managed RL fine-tuning with real product metrics

"RLFT on Your Data." Managed platform for RL-based fine-tuning of 8B–30B parameter models. Reports 2–3× accuracy gains for vertical-specific agents, with fine-tuned 7B models beating o3-mini/o4 on targeted tasks.

Their approach (from their unit-test generation case study):
1. **Data curation** — pair source files with test files, use LSP to map functions→tests
2. **Chain-of-thought warmup** — bootstrap thinking traces from a larger model (32B), distill into smaller (7B)
3. **RL training** — reward signal from actual product impact: code coverage increase, passing tests, mutation testing — not example matching

Target workloads: search/RAG, domain-specific code gen, tool-use agents, goal-oriented chatbots.

Backed by Khosla Ventures, Max Levchin, Gradient.

**Open source:** Platform is commercial. `benchmax` (framework-agnostic RL environments) is open.

| Resource | Link |
|---|---|
| Homepage | https://www.cgft.io/ |
| `benchmax` (RL environments framework) | https://github.com/cgftinc/benchmax |
| GitHub org | https://github.com/cgftinc |
| Unit test RL blog post | https://www.cgft.io/blog/rl-unit-test |
| Contact | finetune@cgft.io |

They also maintain forks of `verl` (Volcano Engine RL for LLMs), `SkyRL`, and `slime` (LLM post-training RL scaling framework).

---

## How they fit together

These tools occupy different layers of the same stack:

| Layer | Tool | What it provides |
|---|---|---|
| **Eval + rollout generation** | Harbor RL | Containerized environments, agent harnesses, benchmark runner |
| **Training compute** | Tinker | Managed GPU API with low-level training primitives |
| **Full-stack platform** | Prime Intellect Lab | Environments + training + evals in one platform |
| **Vertical RL service** | CGFT | End-to-end managed RL with product-metric rewards |

A realistic pipeline: define tasks in **Harbor** containers → generate rollouts → train with **Tinker** or **Prime Intellect**'s `prime-rl` → evaluate with Harbor or Prime Intellect's eval system. **CGFT** is the "just hand us your data and codebase" option for teams that don't want to build the pipeline.

## Market context

The old RLaaS data companies are splitting into research-first players (like Fleet, who define new data shapes for new research directions) and volume-first players (Scale, Turing, Surge) who produce massive amounts of data fast. Companies caught in the middle — neither research-first nor volume-winners — are folding or getting acquired.

Research direction shifts every ~3 months (computer use, one-shot coding, long-horizon specs), and over-investing in infrastructure for one data shape is a losing strategy. The self-serve post-training tools above let enterprises sidestep this by owning their own training loops.

## Links

- [Market analysis thread by Sean Cai](https://x.com/SeanZCai/status/2027459906543226921) — original source
- Related: [[agent RL training environments let you use the same tools for production and training]]
