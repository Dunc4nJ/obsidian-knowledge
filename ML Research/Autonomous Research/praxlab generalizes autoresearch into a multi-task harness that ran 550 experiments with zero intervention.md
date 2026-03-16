---
created: 2026-03-16
description: PraxLab extends the autoresearch loop beyond pre-training into a tree of self-contained workspaces with structured memory, running 550+ experiments across RL, SFT, tool routing, and prompt co-evolution over a weekend with zero human intervention.
source: https://x.com/hamostaf04/status/2033305681395392932
type: learning
---

## Key Takeaways

The central argument is that [[autoresearch lets an AI agent run ML experiments autonomously overnight|autoresearch]]'s significance isn't in pre-training results but in the *pattern* — the scientific method compressed into an agent-executable loop. Hamza Mostafa and Dennis Lee built PraxLab to prove this pattern generalizes across ML tasks, not just Karpathy's original train.py optimization.

The analysis of *why* agent loops fail without structure mirrors the [[tight constraints make autonomous agents more useful than open-ended freedom|tight constraints]] thesis exactly: agents given open-ended freedom make the same mistakes as junior researchers without a protocol — changing multiple variables at once, losing memory between sessions, ignoring broken components. The autoresearch protocol forces discipline (one change, one hypothesis, confirm/refute) and memory (git as lab notebook). This is the same insight behind [[autokernel applies the autoresearch loop to GPU kernel optimization reaching 187 TFLOPS from 18 autonomously|autokernel's]] success with kernel optimization.

PraxLab's architecture is a tree of self-contained "leaves," each with its own `program.md`, mutable training scripts, and a lightweight CLI (`lab context`, `lab failures`, `lab log`) backed by SQLite for structured experiment tracking. The key innovation over raw autoresearch is the explicit hypothesis-result cycle — the agent must state *why* before and *what it learned* after each experiment, turning random search into research.

The results across four leaves are striking: RL hit 93% on MATH level 4-5 from pure binary reward with reasoning emerging from scratch; SFT via self-distillation matched RL at half the cost; tool routing jumped from 0.76 to 0.94; and prompt co-evolution (GEPA) went from 0.75 to 0.94 over four generations. These span fundamentally different ML tasks, validating the generalization claim.

The human role shifts from execution to strategy — choosing which task, which metric, which levers, what constraints. This echoes the emerging pattern in [[distributed research swarms close the feedback loop that single-agent autoresearch leaves open|distributed research swarms]] and [[autoresearch-gen scaffolds the entire autoresearch setup into a single command|autoresearch-gen]]: as experiment cost drops to near-zero, the bottleneck moves entirely to the decisions that frame the search space.

The prediction about `program.md` becoming a standard primitive — a "research specification" rather than a conversation prompt — is worth watching. This is distinct from CLAUDE.md/AGENTS.md in that it programs a *session loop* rather than a conversational interaction.

## External Resources

- [PraxLab](https://github.com/Hamza-Mos/praxlab) — open-source multi-task autoresearch harness
- [autoresearch](https://github.com/karpathy/autoresearch) — Karpathy's original autonomous ML experiment runner
- [AlphaEvolve](https://deepmind.google/discover/blog/alphaevolve-a-gemini-powered-coding-agent-for-designing-advanced-algorithms/) — Gemini-powered closed-loop algorithm evolution
- [OpenEvolve](https://github.com/codelion/openevolve) — open-source AlphaEvolve alternative
- [Letting AI agents train models](https://hamzamostafa.com/blog/agents-training-their-own-models) — Mostafa's earlier post on agents executing training pipelines
- [OpenRLHF](https://github.com/OpenRLHF/OpenRLHF), [SkyRL](https://github.com/NovaSky-AI/SkyRL), [veRL](https://github.com/volcengine/verl), [TRL](https://github.com/huggingface/trl), [Unsloth](https://github.com/unslothai/unsloth) — suggested frameworks for new PraxLab leaves

## Original Content

> **@hamostaf04** (hamza mostafa) — Sun Mar 15, 2026 — 61 likes, 5 retweets, 1 reply
>
> Article: The Agent Research Loop
>
> TL;DR: Karpathy's autoresearch is more important than people realize. Not because of the results, but because of the pattern. A tight loop with structured feedback turns a coding agent into an autonomous researcher. I think this pattern generalizes far beyond ML training, and I think it changes what humans actually do in technical work. My friend @DennwsLee and I built an open-source harness to test this. 550+ experiments across four tasks over a weekend, zero babysitting.
>
> ## Autoresearch Is Bigger Than Pre-Training
>
> When Karpathy released [autoresearch](https://github.com/karpathy/autoresearch) earlier this month, a lot of the coverage focused on the results. 126 experiments overnight. 20 additive improvements. 11% speedup on Time-to-GPT-2.
>
> Those are good numbers. But I think people are missing the more important thing: the pattern.
>
> One GPU, one file, one metric. The agent reads the training script, forms a hypothesis, modifies the code, runs the experiment for exactly 5 minutes, checks if the result improved, keeps or discards, and repeats. Git is the memory. The fixed time budget makes comparison fair. One change at a time so you know what caused the effect.
>
> This isn't a pre-training trick. This is the scientific method compressed into a loop that an agent can execute indefinitely. And there's nothing about it that's specific to training neural networks.
>
> ## Why the Loop Works
>
> A month ago I wrote about [letting AI agents train models](https://hamzamostafa.com/blog/agents-training-their-own-models). My conclusion was that agents could execute training pipelines but couldn't do ML research. Training is execution. Research is judgment.
>
> What I've come to understand since then is that the problem wasn't missing judgment. It was missing structure. When I gave agents open-ended freedom, they made bad decisions: changing reward functions mid-training, ignoring broken learning rate schedulers, starting from scratch every session with no memory of what worked. But those are the same mistakes a junior researcher makes when they don't have a protocol.
>
> Autoresearch is a protocol. And it works because it forces two things:
>
> Discipline. One change at a time. Hypothesis before experiment. Confirm or refute after. This sounds obvious, but agents without this structure will change three things at once, get a result, and have no idea what mattered. The constraint is what makes the exploration useful.
>
> Memory. The git history is a lab notebook. The agent can see what it already tried, what worked, what didn't. Without this, agents repeat themselves endlessly. With it, they build on their own results.
>
> The deeper insight is about the balance between freedom and constraint. You need to give agents real space to explore. Their stochastic nature is a feature, not a bug. They'll try things a human wouldn't think to try, and some of those end up being genuine findings. But you need walls too. Without guardrails, agents go off the rails. Too much freedom is just as bad as too little.
>
> The right model: human sets direction and constraints, agent does exhaustive exploration within those bounds. The human brings taste. Which problems are worth solving, which metrics matter, what "good" looks like. The agent brings tirelessness. Trying every combination, running every ablation, waiting patiently through the flat periods that a human would quit on.
>
> ## What Changes for Humans
>
> There's a question lurking in all of this: if agents can run 550 experiments over a weekend, what do humans actually do?
>
> I think the answer is that human decisions get more important, not less. When the cost of running an experiment drops to near-zero, the bottleneck shifts entirely to the decisions that happen before the loop starts. Which task? Which model? Which metric? What levers can the agent pull? What's the feedback loop?
>
> These are strategic decisions. They're the difference between an agent that discovers something useful and an agent that burns compute on a dead end. And they're the kind of decisions that require context, taste, and judgment about what matters. Exactly the things agents are still developing.
>
> The other thing that changes is time. Agents don't have a clock. They don't context-switch, they don't get tired, they don't have meetings. An agent told "never stop" will run experiment 88 at 3 AM with the same rigor as experiment 1. It'll wait through 100 flat training steps for a phase transition that a human would've given up on. The grunt work that separates a good result from a great one (the 50th hyperparameter sweep, the careful ablation, the 12th self-distillation round) is exactly what agents are built for.
>
> This is already happening, but I think it becomes mainstream quickly. Right now it's ML researchers running agent loops. Soon it'll be performance engineers, security auditors, data engineers, anyone who iterates against a metric. The lines between "human work" and "agent work" will keep blurring, and I think that's OK as long as we're honest about where the boundaries are.
>
> ## Where This Goes
>
> I see two flavors of agent loop emerging.
>
> The first is closed-loop optimization, where there's a defined end state and the agent searches for it. [AlphaEvolve](https://deepmind.google/discover/blog/alphaevolve-a-gemini-powered-coding-agent-for-designing-advanced-algorithms/) and [OpenEvolve](https://github.com/codelion/openevolve) are examples. You have a benchmark, the agent evolves solutions toward it, and eventually you converge or hit a ceiling.
>
> The second is open-ended research, where there's a metric to improve but no finish line. Autoresearch is the prototype. The agent just keeps going, and the human decides when to stop and what to do with the findings.
>
> Both are useful. Both will get more popular. And both need some kind of structured interface for the human to specify what the agent should do.
>
> Right now that interface is a prompt, or a CLAUDE.md, or an AGENTS.md. Those work for conversational tasks. But for long-running autonomous loops, you need something different. Something that specifies the metric, the levers, the feedback loop, and the constraints.
>
> Karpathy's autoresearch uses a program.md. We used the same pattern. I think something like this, a structured document that programs an agent session rather than prompting a conversation, becomes a standard primitive. Not a conversation starter. A research specification.
>
> Maybe this gets baked into agent harnesses directly. A "research mode" in Claude Code or Codex or Cursor or Windsurf where you define a program and it loops. Maybe it stays a file convention, like how CLAUDE.md emerged organically. Either way, I think the programmatized agent loop becomes a normal part of how software gets built and improved.
>
> ## What We Built
>
> To test whether the autoresearch pattern generalizes beyond pre-training, we built an open-source harness over the past week called [PraxLab](https://github.com/Hamza-Mos/praxlab).
>
> The idea: a tree of self-contained workspaces. Each leaf has its own program.md (agent instructions), mutable training scripts, and experiment tracking. You pick a leaf, edit Section 1 with your task, and spin up your favourite coding agent with the prompt: "Read program.md and begin the loop!" The agent creates a git worktree and starts running experiments.
>
> The lab CLI is the structured memory layer. 5 commands, SQLite, zero dependencies. Before each experiment the agent runs 'lab context' and 'lab failures'. After each experiment it logs a result with flag confirming or refuting the mechanism. This is what turns random search into research. The agent has to say why before and what it learned after.
>
> We configured four leaves, started four Claude Code instances, and let them run for 48+ hours over the weekend. 550+ experiments total, zero intervention. Some highlights:
>
> - RL: 93% on MATH level 4-5 from pure binary reward. Reasoning emerged from scratch. The agent discovered a MAX_TOKENS scaling law on its own.
>
> - SFT: Self-distillation hit 93-95% majority vote, matching RL at half the cost. The agent found that training roughness (higher LR) preserves output diversity for majority voting.
>
> - Tool routing (Prime Intellect): 0.76→0.94 on 6-tool routing. Phase transitions at steps 50-100, difficulty filtering as the key lever.
>
> - Prompt co-evolution (GEPA): 0.75→0.94 over four generations. System prompt and evaluation rubric evolving simultaneously.
>
> The experiment branch has the full history. Every commit, every hypothesis, every result. The notes.md in each leaf reads like a lab notebook.
>
> ## Try It, Extend It
>
> The repo: [github.com/Hamza-Mos/praxlab](https://github.com/Hamza-Mos/praxlab)
>
> Clone it, edit Section 1 of a program.md, spin up your favourite coding agent. But more than that, I'd love to see what happens when people add their own leaves. The tree structure means anyone can contribute a new workspace for their framework or task. Some starting ideas: RL with [OpenRLHF](https://github.com/OpenRLHF/OpenRLHF) or [SkyRL](https://github.com/NovaSky-AI/SkyRL), training with [veRL](https://github.com/volcengine/verl) or [TRL](https://github.com/huggingface/trl), fine-tuning with [Unsloth](https://github.com/unslothai/unsloth). Each one is just a new leaf with a program.md and a training script. But all ideas and collaborations are welcome.
>
> If you build a leaf, open a PR. Let's grow this together into a hub for autonomous research on anything.

*PraxLab profile image*
![[hamostaf04-392932-001.jpg]]

*PraxLab experiment results*
![[hamostaf04-392932-002.png]]

[Original tweet](https://x.com/hamostaf04/status/2033305681395392932)
