---
created: 2026-04-11
description: Alex Zhang, Zhening Li, and Omar Khattab argue frontier LMs are already capable enough — the next capability leap comes from training models to natively decompose tasks rather than from further scaling, with the space of decompositions as the key design variable.
source: https://x.com/a1zhang/status/2042588627260018751
type: framework
---

## Key Takeaways

- **The bottleneck has moved from model capability to scaffold quality.** The MGH claims frontier LMs are already "geniuses" on the content they were trained over (IMO, IOI, general SWE) but look bad on long-horizon and iterative tasks because we use them through brittle, human-engineered, task-specific scaffolds. Current benchmarks therefore misrepresent how capable models "actually are" at a given moment — the open question for any task the model fails at is whether it's an inherent limitation or a scaffolding limitation. This is the strongest form of the thesis that [[agent harnesses are the product not the model]] and [[the harness is everything and agent performance comes from environment design not model capability]] have been circling: the next capability curve is in how you decompose, not what you decompose.

- **"Defining the space of decompositions" is the primary design variable, and it has exponential leverage.** How a scaffold lets an LM carve a task into sub-tasks determines, with depth, an exponentially-growing set of solvable problems. Tool-call-style subagents restrict the root LM to API-shaped chunks and cap how much of a long context can be spread across children; Recursive Language Models expand the space by letting the LM write code (for loops, recursive sub-calls, tools-as-functions) to describe its own plan, which is what unlocks near-infinite-context generalization in [[RLMs inline intelligence into data pipelines by giving LLMs symbolic access to DataFrames in a persistent REPL|the RLM data-agent work by the same authors]]. Picking the decomposition language is upstream of picking the model — before asking "which LM," ask "what decompositions can this scaffold even represent."

- **Compose-around-OOD beats scale-through-OOD as a capability strategy.** LMs generalize poorly to long contexts and low-resource tasks (Blackwell GPU kernels is the authors' pointed example), but there's usually a decomposition that keeps each individual LM call inside the in-distribution region — and the *act of producing that decomposition* must itself be in-distribution. The MGH reframes the OOD problem as a composition problem: rather than paying to train-out an OOD region, train the model to shard the task into chunks it already handles. This is the philosophical complement to [[memory-first agents should dispatch stateless subagents for focused task execution]] — the orchestrator stays smart, children stay narrow, and the narrowness is what keeps them reliable.

- **The RL proof point: small models can be taught to decompose and the skill transfers across length.** RLM(Qwen3-4B-Instruct) solves ~0% of MRCRv2 1M-context 8-needle tasks out of the box, but jumps to 100% after RL training on a much simpler 32k-context 1-needle setting — a 4B model outperforming Gemini 3 Pro (~26%) and Opus 4.6 (~76%) on the benchmark, purely because it learned a decomposition strategy that generalizes. The implication is that pre-training and mid-training have already installed most of the behaviors you need; a sufficiently expressive scaffold plus modest RL can bootstrap a general task-solver, echoing the "train inside the harness, not after it" lesson in [[the agent harness is the RL training environment not deployment infrastructure bolted on after]].

- **Orchestrator-subagent scaffolds (Claude Code, OpenClaw, Hermes Agent) are the proof that LMs can manage LMs — but not the end state.** The MGH credits these systems as *first steps* because they already rely on the model outputting a rough plan and then executing via subagents, and the plans turn out to be intuitive and easy to describe (the model doesn't need to know the answer to outline the decomposition). But the authors treat them as scaffolds-we-happen-to-have rather than the correct general scaffold — the real question is the expressive ceiling, which is why they argue RLMs matter more than yet-another-orchestrator-subagent refinement. The harness-as-moat posture of [[Claude Code's edge comes from its software harness not the model]] and the planner-worker topologies in [[planner-worker hierarchies outperform flat coordination for scaling multi-agent coding]] are valuable *data points* about what works today, not claims about what the asymptote looks like.

## External Resources

- [Recursive Language Models (RLMs)](https://x.com/a1zhang/status/2042588627260018751) — the authors' prior work proposing RLMs as a decomposition scaffold that uses code execution (loops, recursive sub-calls, tools-as-functions) rather than fixed API tool-calls
- [MRCRv2 benchmark](https://x.com/a1zhang/status/2042588627260018751) — long-context benchmark (1M context, 8 needles) used as the empirical proof that RL-trained decomposition generalizes from simpler (32k, 1 needle) settings
- [Alex Zhang (@a1zhang)](https://x.com/a1zhang) — first author
- [Zhening (Zed) Li (@zli11010)](https://x.com/zli11010) — second author
- [Omar Khattab (@lateinteraction)](https://x.com/lateinteraction) — third author; DSPy creator, whose compositional-program-over-LMs lineage is the intellectual precedent for the MGH

## Original Content

*Hero diagram: frontier LMs already solve the green region ("tasks a 'genius' frontier LM can solve") but are "mismanaged" when scaled further into the blue region of compositional tasks, which the MGH claims is reachable via scaffolds not scale*
![[a1zhang-018751-001.jpg]]

> @a1zhang (alex zhang) — 2026-04-10
>
> **Article: The "Mismanaged Geniuses" Hypothesis**
>
> tldr; AI models are already good enough for the next leap in capabilities.
>
> By: Alex Zhang (@a1zhang), Zhening (Zed) Li (@zli11010), Omar Khattab (@lateinteraction).
>
> ---
>
> For the last decade, scaling the size and data of AI models has led to groundbreaking, super-human achievements in the capabilities of these systems. The recent success of RL and reasoning in particular implies that models can be trained to generalize on tasks we have never even solved ourselves. It is natural to believe that continuing this trend of scaling across a single neural model will be the recipe that gets us to the next jump in AI capabilities.
>
> We have an alternate hypothesis on what will take us to the next inflection point of AI systems.
>
> It can be said that frontier language models (LMs) are "geniuses" at solving the broad range of tasks they've been trained on. Nowadays, this represents virtually all the advanced subjects and content we learn throughout higher education to prepare ourselves for researching unsolved problems. Yet despite the fact that these models outperform even the brightest humans on the hardest exams like IMO and IOI and are super-human at general software engineering, they oddly also struggle to reliably tackle long-horizon and iterative reasoning problems that may seem "easy" to us. It is an interesting thought experiment to consider whether this is an inherent limitation of the LM, or the way in which we use them.
>
> The mismanaged geniuses hypothesis (MGH) posits that existing frontier language models are severely underutilized due to sub-optimal use of individual language model calls. We believe that the next leap in "language model" capabilities will come not from continued scaling of existing LMs, but from enabling language models to "manage" themselves, i.e. natively decompose tasks and act on these decompositions. In particular, we believe that existing systems that let LMs decompose tasks are the limiting bottleneck, and the first step would be to define the space of decompositions the LM has access to. Upon figuring out this space of decompositions, the "bitter-lesson"-pilled allocation of compute would go towards training models to perform the correct decompositions
>
> *The MGH diagram: green = what a "genius" frontier LM can already solve; blue = what a properly managed (composed) LM can reach; pink boundary = truly non-practical / adversarially hard tasks. The arrow labeled "continued scaling of current frontier LMs (mismanaged)" sits inside the blue region, the authors' claim being that further scaling walks over ground that composition already covers.*
> ![[a1zhang-018751-002.jpg]]
>
> **You and I are not good managers.**
>
> It is worth articulating the "mismanagement" of language models.
>
> Nearly all modern agent scaffolds are human-engineered, task-specific decomposition strategies that use language models. These systems rely on our intuition about how individual language model calls can be used together to solve a larger problem, and are often brittle with respect to different models and different problems. The outcome is a diverse set of agent scaffolds that can only solve narrow problems and must frequently be updated, leading to a misrepresentation of how good language models "actually are" at any given time. As an example, is it really true that frontier language models cannot play certain video games at a human level, or is it just that we haven't put in the effort to build a good scaffold around them?
>
> Coding agents like Claude Code are a first step in enabling the language model itself to decompose a problem into sub-tasks, then launch subagents to solve each sub-task. These "orchestrator-subagent" systems, where the orchestrator LM outputs a rough plan of how its going to go about solving a task, and then executes this plan using subagents, have been shown to work extremely well for general human-like workflows (e.g. for software engineering). Furthermore, it turns out that the plans that these models generate tend to be intuitive and easy to describe: the model does not need to know the exact solution to a problem to outline how it may go about decomposing it!
>
> The success of these more general scaffolds like Claude Code, OpenClaw, Hermes Agent, etc. suggest that LMs are perfectly capable of managing other LMs to solve longer-horizon tasks. Furthermore, it is natural to ask whether the "orchestrator-subagent" scaffold is sufficient for longer running tasks, with recent works like Recursive Language Models (RLMs) proposing a more expressive mechanism for describing "plans" through code execution with recursive sub-calls / tools as functions, enabling fully recursive task decomposition. In particular, RLMs show how expanding the space of decompositions used to manage LM sub-calls beyond API-based tool calling unlocks length generalization capabilities for LMs.
>
> Whether it be RLMs, coding agents, or undiscovered systems, a key unknown is the right general scaffold to train over that fully enables LMs to properly manage LMs.
>
> **Using composition to get around the out-of-distribution (OOD) problem.**
>
> So where do we go from here, and how can we fix the "mismanagement" issue?
>
> To preface, it is well known that neural network language models have a generalization problem. Rather unsurprisingly, they naturally struggle to generalize to longer lengths (i.e. context rot) and low-resource tasks (e.g. as of the time of writing, writing GPU kernels on Blackwell).
>
> One interpretation of the mismanaged geniuses hypothesis is that within the bounds of what is considered "in-distribution" for frontier language models, there already exists a powerful general "language model" system that can solve OOD problems in which its individual LM calls only see in-distribution inputs. Based on our intuition for scaffolds that currently work (e.g. Claude Code, RLMs, etc.), this loosely involves decomposing tasks into sub-tasks that the LM can solve, where the act of "decomposing the task" itself must also be an "in-distribution" task for the LM!
>
> More generally, composition is an efficient way to solve OOD tasks in a learning-based system that is sufficiently capable. To be specific, the MGH posits that modern LMs are so good yet so expensive to further train, that directly learning the operator to compose LMs is a significantly more efficient strategy for reaching these OOD tasks than continuing to scale current LMs.
>
> Assuming the MGH is actually true, we believe there are two main research / engineering directions in creating these systems:
>
> 1. **Defining "decomposition".** Defining the space of decompositions the LM is allowed to express is important for ensuring the individual LM calls stay "in-distribution". How we define "decomposition" has an exponentially large impact (with respect to depth) on the tasks solvable via decomposition. In long-context tasks, for example, tool-call-style subagents prevent the root LM from decomposing the context into arbitrarily many chunks, inhibiting its ability to scale. In RLMs, the space of decompositions is expanded so as to allow an efficient representation of decomposition into arbitrarily many subtasks (e.g. using a for loop), which suddenly enables the system to handle near-infinite context. Similarly, simple expansions to the space of decompositions, compounded by the effect of recursion, may suddenly unlock generalization to near-infinite long-horizon tasks, self-improvement through near-infinite in-context learning, and more.
>
> 2. **Training and scaling the ability to compose.** LMs need to be trained to correctly decompose tasks under any scaffold, but the correct decompositions are likely already within the distribution of what LMs can generate. To provide an example, we examine MRCRv2 1M context with 8 needles, a commonly reported long-context benchmark for frontier models. We find that while RLM(Qwen3-4B-Instruct) solves nearly 0% of the tasks, it gets 100% after only RL training on a significantly simpler setting (32k context, 1 needle). Despite being a small model, it learns purely through its own rollouts the correct decomposition that generalizes.
>
> *Figure: MRCRv2 1M context, 8 needles — RLM(Qwen3-4B-Instruct) out-of-the-box scores ~3%, RLM(Qwen3-4B-Instruct) trained on the simpler 32k/1-needle setting scores 100%, Gemini 3 Pro ~26%, Opus 4.6 ~76%. A 4B model beats the frontier after RL on a dramatically smaller task because the learned decomposition transfers to the harder length/needle regime.*
> ![[a1zhang-018751-003.jpg]]
>
> An exciting corollary of this hypothesis is that it implies that most of the necessary behavior that the model needs to learn during pre-training and mid-training is likely already there. Given a sufficiently well-designed scaffold that supports composition (e.g. RLMs), training out such a system through bootstrapping may be enough to draw out a general task solving system.
>
> Language models have gotten to the point where they're ridiculously powerful, and the bottlenecks to creating fancy things like long-horizon solvers or self-improving systems seem sort of silly (i.e. is length generalization really a bottleneck). Should the MGH be true, the problem that remains is managing the geniuses (with guardrails, of course).
>
> Acknowledgements. We thank Armando Solar-Lezama and Matthew Ho for helpful feedback.
>
> Engagement: 862 likes | 96 retweets | 32 replies
> [Original post](https://x.com/a1zhang/status/2042588627260018751)
