---
created: 2026-03-14
description: A comprehensive survey showing how Cursor, Cognition, OpenAI, and Windsurf all train their coding agents inside production harnesses via agentic RL, with research confirming that environment quality sets the ceiling on model capability.
source: https://x.com/hxlfed14/status/2032120526148436469
type: synthesis
---

## Key Takeaways

The central thesis is that the harness is not infrastructure you bolt on after training — it is the training environment itself. Every major coding agent lab (Cursor, Cognition, OpenAI, Windsurf) now trains models inside the same sandboxed environment that serves production users. This validates the pattern described in [[the harness is the product because model capability is commoditizing while accumulated context is not]] — the harness is where competitive advantage accumulates, not the base model.

Cursor's Composer 1.5 inverted the traditional compute ratio: post-training RL compute exceeded pretraining compute, with 20x RL scaling showing no signs of plateauing. Their production agent server is identical whether serving customers or training. This is the strongest evidence yet that [[harness engineering improved a coding agent 13 points by changing only system prompts tools and middleware]] extends far beyond prompt engineering — the entire environment is the intervention. Cursor also runs a second loop where agent session traces train the semantic search model, which improves the harness, closing a compounding feedback cycle.

The research synthesis is particularly valuable. CSO found only 16% of trajectory steps are "critical" decision points, and focusing RL on just those steps yields 37% relative improvement. This means a well-designed harness with structured tool access and verification checkpoints creates more of the critical moments that RL learns from — directly connecting to [[agent harness components can be derived from first principles by working backwards from desired agent behavior]]. A harness with all tools always available produces flat trajectories with diluted training signal.

RAGEN's "Echo Trap" finding is sobering: poorly designed environments cause models to collapse from genuine reasoning into memorized templates. Confidence increases while reasoning diversity disappears. This connects to [[stable agentic RL requires sequence-level clipping and environment-aware advantages to prevent training collapse]] — the environment design and the RL algorithm design are inseparable concerns.

The AutoHarness result (March 2026) shows the harness-model boundary dissolving: models can synthesize their own code harnesses that make them outperform larger models without harnesses. But Live-SWE-Agent demonstrates the same loop compounds failure below a capability threshold — weak models generating their own harnesses destroy performance. This mirrors the pattern in [[LLMs can synthesize their own code harness via tree search eliminating illegal actions and outperforming larger models]].

CORECRAFT demonstrates that training in realistic environments generalizes to completely different benchmarks (+4.5% BFCL, +7.4% Tau2-Bench), while synthetic environments do not transfer. Even frontier models separate sharply when environments demand real-world complexity — GPT-5.2 tops 42.6% while Claude Opus 4.6 hits 30.8% on the same tasks. This reinforces why [[RL environments are the new unit of progress in agentic AI training]].

## External Resources

- [Phil Schmid: The importance of Agent Harness in 2026](https://www.philschmid.de/agent-harness-2026) — argues competitive advantage is the trajectories your harness captures, not the prompt
- [Cursor: Composer 1.5](https://cursor.com/blog/composer-1-5) — 20x RL scaling with post-training compute exceeding pretraining
- [Cursor: Building Composer with RL](https://cursor.com/blog/composer) — architecture details on training inside production harness
- [Cursor: Improving agent with semantic search](https://cursor.com/blog/semsearch) — second training loop using agent session traces
- [Cognition: SWE-1.5](https://cognition.ai/blog/swe-1-5) — co-developed model and harness with GRPO variant
- [Cognition: SWE-grep](https://cognition.ai/blog/swe-grep) — RL-trained context retrieval inside the harness
- [OpenAI: Harness engineering](https://openai.com/index/harness-engineering/) — built 1M LOC product with zero manually-written code
- [OpenAI: Codex System Card](https://cdn.openai.com/pdf/codex_system_card.pdf) — RL training teaches calibrated honesty (15% to 85% on impossible tasks)
- [Windsurf: SWE-1](https://www.businesswire.com/news/home/20250515138505/en/) — trains on real developer workflows via Shared Timeline Data Model
- [Anthropic: Advanced tool use](https://www.anthropic.com/engineering/advanced-tool-use) — programmatic tool calling reduces token usage
- [CSO: Critical Step Optimization](https://arxiv.org/abs/2602.03412) — only 16% of trajectory steps are critical, focusing on them yields 37% improvement
- [CARL: Critical Action RL](https://arxiv.org/abs/2512.04949) — confirms 28% of actions carry signal, rest is noise
- [RAGEN: Echo Trap in multi-turn RL](https://arxiv.org/abs/2504.20073) — bad environments cause reasoning collapse into memorized templates
- [CORECRAFT: High-fidelity RL environments](https://arxiv.org/abs/2602.16179) — realistic training generalizes, synthetic does not
- [Live-SWE-Agent](https://arxiv.org/abs/2511.13646) — self-evolving agents hit 79.2% SWE-bench but fail below capability threshold
- [AutoHarness](https://arxiv.org/abs/2603.03329) — models synthesize code harnesses that beat larger models without them
- [Karpathy: autoresearch](https://github.com/karpathy/autoresearch) — minimal harness where program.md quality determines what the agent learns

## Original Content

> @Hxlfed14 (Himanshu) — 2026-03-12
>
> The Agent Harness Shapes the RL Loop
>
> @cursor_ai scaled RL 20x for Composer 1.5. Post-training compute exceeded pretraining compute. The scaling curve showed no sign of plateauing.
>
> This happened inside hundreds of thousands of sandboxed environments running Cursor's actual agent tools- the same code editor, the same semantic search, the same terminal.
>
> The production agent server is identical whether serving customers or training the model.
>
> Cursor is not alone. Cognition co-developed SWE-1.5's model and harness as a single process. OpenAI trained Codex inside isolated containers preloaded with production tools and list goes on.
>
> > The harness is not deployment infrastructure you bolt on after training. The harness is the training environment.
>
> And if the training environment is poorly designed, the model learns to be confidently wrong.
>
> This article breaks down how each lab trains inside their harness, what recent research says about why environment quality sets the ceiling on model capability, and why the line between "harness" and "model" is dissolving.
>
> Sources analyzed (all listed at the end with links)
>
> *Article header image*
> ![[hxlfed14-436469-001.jpg]]
>
> ---
>
> **Why the Harness Is the Training Environment**
>
> A quick primer on the terms you will see throughout this article.
>
> - Reinforcement learning (RL) is how you train a model by letting it try things, then rewarding good outcomes and penalizing bad ones, learning from experience rather than examples.
>
> - A rollout is one complete attempt at a task- every decision the model makes from start to finish.
>
> - Standard RLHF (RL from Human Feedback) is how most chatbots are trained: single-turn, model generates a response, a human rates it, ~100 RL steps total.
>
> Agentic RL is a different beast.
>
> - Multi-turn with hundreds of tool calls per rollout.
>
> - A combinatorial action space: which tools, in what order, with what arguments, in parallel or serial.
>
> - Sparse rewards- complex tasks succeed maybe 1 in 1,000 attempts.
>
> - Each rollout consumes 100,000 to 1 million tokens and requires a full sandboxed OS environment.
>
> But agentic RL has one massive advantage: verifiable rewards. Tests pass or fail. Linters catch errors. Code executes or crashes. No need for a human to rate the output. This enables 10,000+ RL steps versus ~100 in standard RLHF. Cursor's Composer went even further.
>
> RL optimizes exactly what the environment specifies: the tools available, the feedback returned, the decisions the agent is forced to make. A model trained inside a harness with ten well-designed tools learns to use those ten tools effectively. A model trained with a hundred tools dumped into context learns to pick randomly.
>
> > Phil Schmid captured where this is heading: "Competitive advantage is no longer the prompt. It is the trajectories your Harness captures."
>
> Source: Schmid "The importance of Agent Harness in 2026" [https://www.philschmid.de/agent-harness-2026](https://www.philschmid.de/agent-harness-2026)
>
> *Diagram comparing standard RLHF vs agentic RL*
> ![[hxlfed14-436469-002.jpg]]
>
> ---
>
> **How Top AI Companies train Inside Their Harness**
>
> > @cursor_ai - Composer 1.5
>
> Cursor has not publicly disclosed which specific RL algorithm they use.
>
> What they have disclosed is the architecture: "20x RL scaling" means 20x more training steps on the same pretrained base model. Total post-training compute surpassed pretraining compute, inverting the typical ratio where pre-training dominates.
>
> The training infrastructure has three server types.
>
> - A Trainer running PyTorch with custom MXFP8 kernels (a low-precision number format that speeds up math operations)
>
> - An Inference Server using Ray (a framework for running many tasks in parallel) for orchestrating rollouts
>
> - And an Environment Server spinning up hundreds of thousands of concurrent sandboxed microVMs- each a self-contained coding workspace.
>
> Each VM runs the full Cursor agent harness: file reading and editing, semantic search, grep, terminal commands.
>
> The critical innovation: the production agent server is identical whether running agents for customers or training the RL model. They reused the same Background Agents infrastructure, the same tools, the same search model. The training environment is the production environment.
>
> Emergent behaviors appeared during training without explicit programming: the model learned to perform complex codebase searches, fix linter errors autonomously, write and execute unit tests, increase parallel tool calling over time, and shift from making too many edits to reading more files first.
>
> Composer 1.5 hit 47.9% on Terminal-Bench 2.0, outperforming Claude Sonnet 4.5 (41.6%).
>
> Source: Cursor "Introducing Composer 1.5" [https://cursor.com/blog/composer-1-5](https://cursor.com/blog/composer-1-5)
>
> Source: Cursor "Composer: Building a fast frontier model with RL" [https://cursor.com/blog/composer](https://cursor.com/blog/composer)
>
> But Cursor runs a second training loop on top of this. They train their semantic search embedding model: the model that finds relevant files in your codebase using agent session traces as training data.
>
> When an agent works through a task, Cursor analyzes which files should have been retrieved earlier, ranks the most helpful content with an LLM, and trains the embedding model to match those rankings.
>
> Result: 12.5% higher accuracy in answering questions across the codebase (6.5% to 23.5% depending on the model), and 2.6% higher code retention on codebases with 1,000+ files.
>
> The harness produces sessions. The sessions become training data for the search model. The search model improves the harness. Loop closed.
>
> Source: Cursor "Improving agent with semantic search" [https://cursor.com/blog/semsearch](https://cursor.com/blog/semsearch)
>
> *Cursor's training infrastructure architecture*
> ![[hxlfed14-436469-003.jpg]]
>
> ---
>
> > @cognition - SWE-1.5
>
> SWE-1.5 was co-developed. Not 'build harness, then train model.' Simultaneous iteration on model, harness, tools, and prompts as a single process.
>
> Cognition uses a variant of GRPO: Group Relative Policy Optimization, an algorithm where you generate multiple attempts at the same task, rank them, and update the model to favor the better ones.
>
> Unlike PPO (Proximal Policy Optimization), which requires a separate "critic" model to estimate how good each state is (expensive in memory and often inaccurate for complex tasks), GRPO uses the group of attempts itself as the baseline.
>
> Cognition added per-sequence importance sampling to correct for numerical mismatches between training and inference as a technical fix for the fact that the model producing training data drifts away from the model being updated.
>
> RL runs in full task environments via their Otterlink VM hypervisor, scaling to tens of thousands of concurrent machines.
>
> The reward system uses three grading mechanisms:
>
> - classical tests,
>
> - rubrics for code quality,
>
> - and agentic grading
>
> They address "AI slop" explicitly: exclusively verifiable correctness rewards without quality rubrics produce functional but ugly code. Their reward hardening process has human experts actively try to circumvent graders across multiple rounds, reducing false positives.
>
> 950 tokens/second. 6x faster than Haiku 4.5. Near-SOTA coding performance.
>
> Source: Cognition "Introducing SWE-1.5" [https://cognition.ai/blog/swe-1-5](https://cognition.ai/blog/swe-1-5)
>
> Source: Cognition "Introducing SWE-grep and SWE-grep-mini: RL for Multi-Turn, Fast Context Retrieval" [https://cognition.ai/blog/swe-grep](https://cognition.ai/blog/swe-grep)
>
> *Cognition SWE-1.5 architecture*
> ![[hxlfed14-436469-004.jpg]]
>
> ---
>
> > @OpenAI - Codex
>
> Codex-1 is o3 optimized for software engineering via RL on real-world coding tasks.
>
> Each task runs in an isolated cloud container preloaded with user code and a development environment. After setup, internet access is disabled and the trajectory begins. OpenAI has not disclosed the specific RL algorithm.
>
> But they reveal something about the training signal. Before RL training, only 15% of agents correctly stated they could not complete impossible tasks. After training, this rose to 85%. The reward structure teaches calibrated honesty, not just code generation. The model learns when to say "I can't do this" instead of hallucinating a solution.
>
> Later Codex iterations introduced compaction, allowing the model to work across multiple context windows by summarizing its own progress.
>
> The harness team's internal proof: they built a full product of ~1 million lines of code, ~1,500 PRs with zero manually-written code over five months. Three engineers. They did not write code. They designed the harness.
>
> Source: OpenAI "Harness engineering: leveraging Codex in an agent-first world" [https://openai.com/index/harness-engineering/](https://openai.com/index/harness-engineering/)
>
> Source: OpenAI Codex System Card [https://cdn.openai.com/pdf/codex_system_card.pdf](https://cdn.openai.com/pdf/codex_system_card.pdf)
>
> *OpenAI Codex architecture*
> ![[hxlfed14-436469-005.png]]
>
> ---
>
> > @windsurf - SWE-1
>
> Windsurf takes a different angle. SWE-1 trains on real developer workflows captured in their editor- a "Shared Timeline Data Model" that tracks every action.
>
> The model learns from real, incomplete engineering states: the interruptions, the context switches, the partial builds. Windsurf calls this "flow awareness."
>
> The model does not learn coding in isolation. It learns coding as developers actually experience it through the harness.
>
> Source: Windsurf "SWE-1: A Frontier AI Model Family" [https://www.businesswire.com/news/home/20250515138505/en/](https://www.businesswire.com/news/home/20250515138505/en/)
>
> *Comparison table: how each lab trains*
> ![[hxlfed14-436469-006.png]]
>
> ---
>
> **Research Confirms: Environment Quality Sets the Ceiling**
>
> Six papers published between late 2025 and March 2026 converge on the same finding. What the model trains inside determines what it can learn.
>
> 1. Only 16% of trajectory steps actually matter.
>
> CSO (Critical Step Optimization) analyzed multi-step agent trajectories and found that the vast majority of actions have near-zero impact on task outcomes. Only 16% of steps are "critical"- decision points where choosing differently would flip the result from failure to success.
>
> Focusing RL updates on just these critical steps produced a 37% relative improvement over training on all steps indiscriminately.
>
> CARL confirmed this independently: over half of trajectory actions induce near-zero reward changes. Training on only the high-impact 28% of actions yielded stronger performance with better efficiency.
>
> The harness implication is direct. A harness with all tools always available, no verification checkpoints, no structured task decomposition is the harness that produces flat trajectories with fewer meaningful decision moments.
>
> The training signal gets diluted before it reaches the optimizer. A well-designed harness with structured tool access and verification steps creates more of the critical moments that RL actually learns from.
>
> Source: CSO "Verified Critical Step Optimization for LLM Agents" [https://arxiv.org/abs/2602.03412](https://arxiv.org/abs/2602.03412)
>
> Source: CARL "Critical Action Focused RL for Multi-Step Agent" [https://arxiv.org/abs/2512.04949](https://arxiv.org/abs/2512.04949)
>
> 2. Training in realistic environments generalizes. Synthetic does not.
>
> CORECRAFT built a high-fidelity customer support RL environment of 2,500+ interconnected entities across 14 types, 23 tools, expert-authored rubrics for scoring.
>
> One epoch of RL inside this environment improved a model from 25.37% to 36.76% on held-out tasks. The gains transferred to completely different benchmarks: +4.5% on BFCL, +7.4% on Tau2-Bench Retail, +6.8% on Tool Decathlon. Train in a realistic environment, and the capabilities generalize beyond it.
>
> Even frontier models struggle when the environment is realistic. GPT-5.2 (xHigh reasoning) tops out at 42.6% on CORECRAFT tasks. Claude Opus 4.6 hits 30.8%. Models that look equivalent on synthetic benchmarks separate sharply when the environment demands real-world complexity.
>
> Source: CORECRAFT "Training Generalizable Agents on High-Fidelity RL Environments" [https://arxiv.org/abs/2602.16179](https://arxiv.org/abs/2602.16179)
>
> *Research findings visualization*
> ![[hxlfed14-436469-007.jpg]]
>
> 3. Bad environments teach bad habits.
>
> RAGEN discovered what they call the "Echo Trap." Here is what it looks like: early in training, agents reason about different options- weighing tradeoffs, considering evidence, exploring alternatives. After training in a poorly designed environment, responses collapse into memorized templates repeated identically. Reward variance drops. The model's confidence increases while its reasoning diversity disappears. It has learned the shortest path to reward, not the deepest understanding of the task.
>
> The fix was environment design: diverse initial states so the model cannot memorize, medium interaction granularity so each turn involves real decisions, and reasoning-aware rewards.
>
> The paper's sobering admission: even with all their enhancements, training still eventually collapses over longer horizons.
>
> Source: RAGEN "Understanding Self-Evolution in LLM Agents via Multi-Turn RL" [https://arxiv.org/abs/2504.20073](https://arxiv.org/abs/2504.20073)
>
> ---
>
> **The Feedback Loop That Compounds**
>
> Every company in this article runs the same loop:
>
> > Harness design → agent trajectories → RL training signal → better model → better harness.
>
> The loop compounds. Better harness produces better trajectories. Better trajectories produce better training signal. Better training produces a model that generates even better trajectories inside the same harness.
>
> Cursor runs this loop twice. First: the model trains inside the harness and learns its tools. Second: agent sessions become training data for the search model, which improves the harness, which produces better sessions. Each improvement in the search model creates better context for the next round of agent training.
>
> *The compounding feedback loop*
> ![[hxlfed14-436469-008.jpg]]
>
> ---
>
> @karpathy's autoresearch, open-sourced recently is the purest distillation of this loop.
>
> A minimal Python tool for autonomous ML experiments. The program.md file is the harness spec- it defines the research strategy.
>
> Human iterates on program.md. Agent iterates on train.py. Twelve experiments per hour. ~100 overnight. The quality of a single markdown file directly determines what the agent learns.
>
> Source: Karpathy autoresearch [https://github.com/karpathy/autoresearch](https://github.com/karpathy/autoresearch)
>
> The loop also runs in reverse. Live-SWE-Agent starts with a minimal scaffold, only basic bash tools and the agent generates custom tools on the fly as it works.
>
> With Claude Opus 4.5, this approach hit 79.2% on SWE-bench Verified. But with GPT-5-Nano (a much weaker model), performance dropped from 44.0% to 14.0%. A weak model generating its own harness generates a bad harness, which generates bad trajectories.
>
> The same loop that compounds improvement also compounds failure. There is a capability threshold below which self-modification destroys performance.
>
> AutoHarness (March 2026) demonstrated the upside: models can synthesize code harnesses (small programs that constrain their own behavior) that make them outperform larger models without harnesses. Gemini-2.5-Flash with an auto-generated harness beat Gemini-2.5-Pro without one.
>
> Source: Live-SWE-Agent "Can Software Engineering Agents Self-Evolve on the Fly?" [https://arxiv.org/abs/2511.13646](https://arxiv.org/abs/2511.13646)
>
> Source: AutoHarness "Improving LLM Agents by Automatically Synthesizing a Code Harness" [https://arxiv.org/abs/2603.03329](https://arxiv.org/abs/2603.03329)
>
> ---
>
> **The Model Is Learning to Be Its Own Harness**
>
> Something else is happening simultaneously. Functions that used to live exclusively in the harness are migrating into the model.
>
> Anthropic shipped programmatic tool calling. Instead of the model making one inference call per tool invocation (slow, expensive), Claude now writes and executes code to call multiple tools in sequence, significantly reducing token usage. Anthropic described this as a key factor in unlocking agent performance on their hardest benchmarks.
>
> Source: Anthropic "Introducing advanced tool use" [https://www.anthropic.com/engineering/advanced-tool-use](https://www.anthropic.com/engineering/advanced-tool-use)
>
> GPT-5.4 launched with native tool search.
>
> Anthropic's tool search reduces context from ~55K tokens of tool definitions to ~8.7K (85% reduction) and improves accuracy from 49% to 74%.
>
> Does this make the harness less important?
>
> The opposite. The harness is now both the deployment infrastructure and the training environment that teaches the model these skills. A model that learns tool search inside a bad harness learns bad tool search. The harness shapes the capability itself.
>
> *Harness-model convergence diagram*
> ![[hxlfed14-436469-009.png]]
>
> ---
>
> **References**
>
> Company Sources
>
> 1. Cursor - "Composer: Building a fast frontier model with RL" (2025) - [https://cursor.com/blog/composer](https://cursor.com/blog/composer)
> 2. Cursor - "Introducing Composer 1.5" (2026) - [https://cursor.com/blog/composer-1-5](https://cursor.com/blog/composer-1-5)
> 3. Cursor - "Improving agent with semantic search" (2026) - [https://cursor.com/blog/semsearch](https://cursor.com/blog/semsearch)
> 4. Cognition - "Introducing SWE-1.5" (2025) - [https://cognition.ai/blog/swe-1-5](https://cognition.ai/blog/swe-1-5)
> 5. Cognition - "Introducing SWE-grep and SWE-grep-mini" (2026) - [https://cognition.ai/blog/swe-grep](https://cognition.ai/blog/swe-grep)
> 6. OpenAI - "Harness engineering: leveraging Codex in an agent-first world" (2026) - [https://openai.com/index/harness-engineering/](https://openai.com/index/harness-engineering/)
> 7. OpenAI - Codex System Card - [https://cdn.openai.com/pdf/codex_system_card.pdf](https://cdn.openai.com/pdf/codex_system_card.pdf)
> 8. Anthropic - "Introducing advanced tool use" (2026) - [https://www.anthropic.com/engineering/advanced-tool-use](https://www.anthropic.com/engineering/advanced-tool-use)
> 9. Anthropic - "Quantifying infrastructure noise in agentic coding evals" (2026) - [https://www.anthropic.com/engineering/infrastructure-noise](https://www.anthropic.com/engineering/infrastructure-noise)
> 10. Windsurf - "SWE-1: A Frontier AI Model Family" (2025) - [https://www.businesswire.com/news/home/20250515138505/en/](https://www.businesswire.com/news/home/20250515138505/en/)
> 11. Phil Schmid - "The importance of Agent Harness in 2026" - [https://www.philschmid.de/agent-harness-2026](https://www.philschmid.de/agent-harness-2026)
> 12. METR - "Recent Frontier Models Are Reward Hacking" (2025) - [https://metr.org/blog/2025-06-05-recent-reward-hacking/](https://metr.org/blog/2025-06-05-recent-reward-hacking/)
>
> Research Papers
>
> 1. CSO - "Verified Critical Step Optimization for LLM Agents" - [https://arxiv.org/abs/2602.03412](https://arxiv.org/abs/2602.03412)
> 2. CARL - "Critical Action Focused RL for Multi-Step Agent" - [https://arxiv.org/abs/2512.04949](https://arxiv.org/abs/2512.04949)
> 3. RAGEN - "Understanding Self-Evolution in LLM Agents via Multi-Turn RL" - [https://arxiv.org/abs/2504.20073](https://arxiv.org/abs/2504.20073)
> 4. CORECRAFT - "Training Generalizable Agents on High-Fidelity RL Environments" - [https://arxiv.org/abs/2602.16179](https://arxiv.org/abs/2602.16179)
> 5. ATLAS - "Scaling Agentic Capabilities, Not Context" - [https://arxiv.org/abs/2603.06713](https://arxiv.org/abs/2603.06713)
> 6. Live-SWE-Agent - "Can Software Engineering Agents Self-Evolve on the Fly?" - [https://arxiv.org/abs/2511.13646](https://arxiv.org/abs/2511.13646)
> 7. AutoHarness - "Improving LLM Agents by Automatically Synthesizing a Code Harness" - [https://arxiv.org/abs/2603.03329](https://arxiv.org/abs/2603.03329)
>
> Tools
>
> 1. @karpathy - autoresearch - [https://github.com/karpathy/autoresearch](https://github.com/karpathy/autoresearch)
>
> Engagement: 141 likes | 17 retweets | 6 replies
> [Original post](https://x.com/Hxlfed14/status/2032120526148436469)
