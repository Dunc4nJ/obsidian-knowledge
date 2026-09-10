---
created: 2026-09-08
description: Part one of Daniel Ching's three-part series written after four months in the data market at Datacurve during the DeepSWE release - pretraining and post-training need structurally different data, so re-feeding a web-scale corpus into post-training wastes compute; the atomic post-training datapoint is now an executable RL environment (task world, tools, evaluator) that emits trajectories and rewards, and the old problem of data curation has become a problem of verification.
source: https://x.com/danielchingwq/status/2095920878907543621
type: synthesis
---

## Key Takeaways

- **The framing claim is a distinction, not a discovery: pretraining and post-training want structurally different data, so the same corpus cannot serve both.** Web-scale datasets — Common Pile v0.1, FineWeb, RefinedWeb — earn their value from *breadth and scale*, which is what pretraining needs. Post-training's goal is to elicit specific capabilities from signal-dense examples and environments, so "feeding the same corpus back into the model wholesale would be a relatively inefficient use of compute." Ching stacks this on the older ML-stack argument that data is the foundation layer: architecture and optimization can only extract signal that the training distribution already contains, and models "can recombine what they have learned in novel ways, but insights that require distinctions absent from their training distribution are unlikely to emerge reliably." Chinchilla then supplies the *how much* — the reading order behind that claim is [[twenty-six papers capture ninety percent of the alpha behind modern LLMs from attention through reasoning and mixture of experts]], and the layer that RL amplifies rather than creates is measured in [[mid-training builds the reasoning foundation that RL amplifies not replaces]].

- **The strongest historical move is treating benchmarks and corpora as the same class of object — the deliberately built *data artifact*.** ImageNet "made computer vision plausible by labelling millions of images"; CommonPile and FineWeb "determine the distributions that modern language models encounter during pretraining"; MMLU "defined early-era LLM progress." Ching's point is that these serve opposite purposes — one develops a model, one assesses it — yet both derive value from *measured curation*, and curation gets substantially harder once the curated thing is an environment rather than a static dataset. That equivalence is exactly what [[benchmarks are measurement instruments not question collections - regulargio's first-principles guide to claims, graders, coverage, and uncertainty]] formalizes from the measurement side, and the pretraining-side version of "quality beats scale at fixed compute" is the one [[prompt design is the single biggest lever for synthetic pretraining data]] tests directly.

- **The industry's contempt for data work is presented as a category error with a citation trail, and it is the piece's most pointed passage.** "Procuring and labelling data is often dismissed as 'dirty work'" — Ching links the Time investigation into underpaid Kenyan workers behind ChatGPT and Google's "Everyone wants to do the model work, not the data work" paper on data cascades in high-stakes AI, then notes in footnote 1 that FineWeb's ablations *held model size, architecture and training token count fixed* and still moved MMLU from ~33% to 37% and ARC from 46% to 57% purely by filtering for higher-quality educational content. The market that grew out of that dirty work is mapped in [[data is a great place to start an AI company and a dangerous place to stop - Etna Labs maps the training-signal supplier market]], and its unit economics — roughly $750-1500 per contracted environment against ~$117 distributed — in [[rl environment creation is becoming a distributed marketplace that could 10x cost efficiency over contracting firms]].

- **The concrete contribution is a clean definition of the atomic post-training datapoint: an RL environment is executable, and a trajectory is what running it produces.** One environment defines a task world, the actions a language-model agent can execute, and an evaluator that grades performance; running a solver agent against it yields a trajectory (the message-and-tool-call sequence), the evaluator returns a reward, and the *same* environment regenerates multiple trajectories across solver configurations — or across repeated runs of one configuration. That reusability is the economic point: "strong environments therefore become reusable seeds for trajectory generation; their value comes from the model improvement they can induce, not merely the unit cost of creating one." Formally it is a POMDP made runnable (footnote 2 names MuJoCo and MiniGrid as the classical instances), the history of which is [[Sergio Paniego traces RL environments from OpenAI Universe to OpenEnv - the idea barely changed while five missing pieces arrived separately]] and the engineering roadmap [[RL environments are the new unit of progress in agentic AI training]].

- **The file layout is the reusable artifact here, and the anti-reward-hacking rule is stated as a constraint on it.** Drawing on Harbor's task documentation, a task is a `task.toml`, a `prompt.md` (what the solver is asked to do), a Dockerfile or equivalent environment setup, a solution script proving the task is solvable, and an evaluator/verifier that grades output. The solver collapses to any coding agent — Claude Code, Codex — and "one must ensure that this solver agent does not have access to the solution script, as well as the evaluator / verifier," or the task becomes trivially reward-hackable. The Harbor format shows up on the eval side in [[LangChain's Eval Engineering Skill builds Harbor-format evals from repo context and agent traces by interviewing the user]]; the argument that this scaffolding *is* the training environment rather than deployment plumbing is [[the agent harness is the RL training environment not deployment infrastructure bolted on after]]; a live example of a solvability check doubling as a de-risking gate is Step 1-3 of [[Mercor's SkyRL recipe post-trains a 397B on 1928 expert tasks for 70 percent relative Pass@1 - and spends Steps 1-3 de-risking before any real compute]].

- **The value argument routes through long-horizon capability, and the market figure is quoted rather than verified.** SFT trains on fixed demonstrations; RL lets the model generate its own attempts and be optimized on outcome feedback, and when outcomes are checkable that feedback can come from a verifier instead of human judgement — with GRPO sampling multiple rollouts per task and comparing them, the algorithm family traced in [[Arjun Kocher's RL algorithm Q&A traces PPO, GRPO, DAPO, and the DeepSeek R1-to-V4 training arc]] and the outcome-reward convergence documented in [[agentic RL training converges on outcome rewards inside production harnesses across Kimi Cursor and Chroma]]. Why this matters: knowledge work "largely consists of interdependent tasks rather than isolated actions," and the difficulty for agents lies in *stringing longer sequences together* rather than in individual steps — METR's time-horizon framing, and the same variable [[Charlie O'Neill's LONG REAL YOURS thesis - horizon length is the only thing RL generalises, and what you distil from matters more than how well you distil]] argues is the only thing RL generalises. On demand: "by July 2026, more than 50 companies were selling training data and RL environments to frontier labs, collectively generating roughly ~$8.5B in annual revenue," a LinkedIn list Ching cites without independent checking. Labs outsource because of *data diversity* (footnote 5, flagged as his opinion): vendors curate through separate methods, which beats one in-house pipeline.

- **The piece is an argument, not a result, and the conflict is on the page rather than hidden.** There are no experiments, no benchmarks and no measurements of Ching's own — every number is quoted (FineWeb's ablation deltas, the ~$8.5B figure). He wrote it after four months at Datacurve, a vendor in the market he is describing, with a front-row seat to the DeepSWE release; the strongest reading is as a practitioner's map of a market from inside one of its suppliers. The closing thesis is what part two cashes out — "this old problem of data curation has increasingly become a problem of verification" — with the observation that environments vary enormously in whether they even produce the intended training signal. That thread continues in [[Daniel Ching's On Data II makes environment quality a verification problem - prompt-verifier bijectivity, realism, and ex post trace analysis]], is argued as a moat in [[Phoebe Yao argues verifier engineering is the moat in RL post-training because verifiability bounds learnability]], appears as pass-rate-band gating in [[Prime Intellect general-agent self-evolves a tool-use corpus through a synthesizer-solver game gated on empirical pass-rate bands]], as edge-of-ability task sampling in [[AgentFrontier synthesizes training data at the boundary of what LLMs can and cannot do]], as production rubric-graded environments in [[Harvey's Tenet post-trains Kimi K3 with GSPO in rubric-graded legal environments, doubling LAB hold-out completions while co-optimizing cost via reward shaping]], and as the emerging vendor layer in [[self-serve post-training infrastructure is emerging as the key layer between foundation models and enterprise adoption]].

## External Resources

Datasets and artifacts cited:

- [Common Pile v0.1](https://huggingface.co/collections/common-pile/common-pile-v01), [FineWeb](https://huggingface.co/spaces/HuggingFaceFW/blogpost-fineweb-v1), [RefinedWeb](https://huggingface.co/datasets/tiiuae/falcon-refinedweb) — the web-scale pretraining corpora
- [ImageNet](https://ieeexplore.ieee.org/document/5206848) — the labelling effort that made computer vision plausible
- [MMLU](https://arxiv.org/abs/2009.03300) — the benchmark that defined early-era LLM progress
- [Chinchilla scaling laws](https://arxiv.org/pdf/2203.15556) — makes model capacity vs training-data scale explicit

Environments and tooling:

- [DeepSWE](http://deepswe.datacurve.ai/) — the Datacurve release Ching had a front-row seat to
- [Harbor](https://github.com/harbor-framework/harbor) and its [task documentation](https://www.harborframework.com/docs/tasks) — packaging RL environments for delivery to frontier labs
- [MuJoCo](https://mujoco.org/) and [MiniGrid](https://arxiv.org/abs/2306.13831) — the classical RL environment instances of the POMDP formalism

Post-training background:

- [InstructGPT](https://arxiv.org/abs/2203.02155) — model generates its own attempts, optimized on outcome feedback
- [GSM8K / verifiers](https://arxiv.org/pdf/2110.14168) — feedback from a verifier rather than human judgement
- [GRPO / DeepSeekMath](https://arxiv.org/pdf/2402.03300) — multiple rollouts per task, compared against one another
- [METR time horizons](https://metr.org/time-horizons/) — multi-step, long-horizon task completion
- [Knowledge work as interdependent tasks](https://pubsonline.informs.org/doi/10.1287/orsc.2025.21838) (Organization Science)

Market and commentary:

- [AI training data startups list, July 2026](https://www.linkedin.com/posts/debarghyadas_full-ai-training-data-startups-list-july-share-7481840399964327936-enOt/) — the >50 companies / ~$8.5B ARR figure
- [Epoch AI: state of RL envs](https://epoch.ai/gradient-updates/state-of-rl-envs)
- [Time: OpenAI's Kenyan workers](https://time.com/6247678/openai-chatgpt-kenya-workers/) and Google's [data cascades paper](https://research.google/pubs/everyone-wants-to-do-the-model-work-not-the-data-work-data-cascades-in-high-stakes-ai/)
- [The limitations of deep learning](https://blog.keras.io/the-limitations-of-deep-learning.html) (Chollet) — models recombine, but cannot invent absent distinctions
- Cross-posted at [danielcwq.com/posts/data-learning-1](https://danielcwq.com/posts/data-learning-1)

## Original Content

Source: [On Data, I: When Data Becomes an Environment](https://x.com/danielchingwq/status/2095920878907543621) — X Article by @danielchingwq (Daniel Ching), 4 Sep 2026. 102 likes, 7 retweets, 9 replies.

> [!quote]- On Data, I: When Data Becomes an Environment — full X Article text
>
> @danielchingwq (Daniel Ching):
> Article: On Data, I: When Data Becomes an Environment
>
> This (mostly handwritten!) piece collects my thoughts on the data market after a short four-month stint in it. During that time, I had a front-row seat to the release of [DeepSWE](http://deepswe.datacurve.ai/) at Datacurve (@datacurve), and worked on similar projects. This is the first of a three-part series on my learnings from the industry. Also cross-posted on my personal website [here](https://danielcwq.com/posts/data-learning-1).
>
> ## Setting the scene
>
> Pretraining and post-training rely on structurally different kinds of data. Historically, web-scale datasets such as [Common Pile v0.1](https://huggingface.co/collections/common-pile/common-pile-v01), [FineWeb](https://huggingface.co/spaces/HuggingFaceFW/blogpost-fineweb-v1), and [RefinedWeb](https://huggingface.co/datasets/tiiuae/falcon-refinedweb) have primarily served pretraining in the model development lifecycle; their value comes from breadth and scale. Post-training is different: the goal is to elicit specific capabilities through more signal-dense examples and environments, so feeding the same corpus back into the model wholesale would be a relatively inefficient use of compute.
>
> *Pretraining vs post-training: web-scale corpus to static tokens to breadth and scale, against targeted environment to executable interactions to dense capability signal*
> ![[danielchingwq-543621-001.png]]
>
> Even before the current LLM era, [data was the foundation of the ML stack](https://x.com/Hesamation/status/1916563425137766593). Before upper layers such as model architecture or optimization can be meaningfully explored, the training data must first contain sufficient signal for the model to learn from. Improvements higher up the stack can then extract that signal much more effectively. [Models can recombine what they have learned in novel ways, but insights that require distinctions absent from their training distribution are unlikely to emerge reliably.](https://blog.keras.io/the-limitations-of-deep-learning.html)
>
> Having merely the right signal is insufficient, there also needs to be enough of it. The [Chinchilla scaling laws](https://arxiv.org/pdf/2203.15556) made this relationship between model capacity and training-data scale explicit for language models. Scaling laws allow us to solve for how much data to use.
>
> Now that the importance of scale has been established, how do we curate the data itself? Some of the most consequential advances in ML have come from the creation of the right data artifact.
>
> [ImageNet](https://ieeexplore.ieee.org/document/5206848) made computer vision plausible by labelling millions of images. CommonPile and FineWeb determine the distributions that modern language models encounter during pretraining. We have go-to benchmarks like [MMLU](https://arxiv.org/abs/2009.03300) which defined early-era LLM progress. While these datasets serve very different purposes, their inherent value comes from a measured curation that enables either a model’s development or provides an assessment of a model’s capabilities. By extension, huge amounts of data need to be cleaned and filtered before becoming useful training fuel. The same problem of purposeful curation becomes substantially harder once the thing being curated is no longer a static dataset, but an environment in which an agent acts.
>
> Much of the industry’s disdain for data has come from the very manual, [sometimes underpaid process of data labelling and data cleaning](https://time.com/6247678/openai-chatgpt-kenya-workers/). Yet some of the largest gains in language modelling have come from higher quality data while keeping model size, architecture and training token count fixed¹. [Procuring and labelling data is often dismissed as “dirty work](https://x.com/svpino/status/1933427773273743779?s=20)”. Unfortunately, said dirty work is the most [under-valued and de-glamorised aspect of AI.](https://research.google/pubs/everyone-wants-to-do-the-model-work-not-the-data-work-data-cascades-in-high-stakes-ai/)
>
> The form this curation takes, however, is changing. What is more interesting (and the result of where I’ve spent my past 4 months) is how the object we call data has changed in the current post-training era. Instead of static corpora of text / multi-modal data, increasingly valuable data points can take the form of executable environments in which language-model agents act and receive feedback.
>
> Yet the underlying problem has barely changed. The bar for how one determines the quality of data in this new paradigm has only gotten more challenging; I posit that this old problem of data curation has increasingly become a problem of verification, which is apparent in the scaling of RL environments.
>
> ## Shifting Paradigms
>
> Investor attention has followed this shift. [By July 2026, more than 50 companies were selling training data and RL environments to frontier labs, collectively generating roughly ~$8.5B in annual revenue.](https://www.linkedin.com/posts/debarghyadas_full-ai-training-data-startups-list-july-share-7481840399964327936-enOt/) What, then, are these environments in practice, and why have they become so valuable?
>
> For the purposes of this piece, I treat a single RL environment as the atomic post-training datapoint². Unlike a static text or multi-modal sample, this datapoint is executable: it defines a task world (“environment”), the actions that a LLM agent can execute, and an evaluator that determines how well it performed.
>
> Running a solver agent against this datapoint produces a trajectory³: the sequence of messages and actions (tool calls) an agent takes while attempting to solve this task. The evaluator then grades the resulting outcome and returns some form of reward. The same environment can therefore generate multiple trajectories across repeated solver agent configurations (or even on the same configuration).
>
> *One RL environment / datapoint: task, environment state and tools, evaluator; the solver agent generates trajectories in an observation-action loop until task completion, yielding a reward*
> ![[danielchingwq-543621-002.jpg]]
>
> As language models have progressed from generating text to code, making tool calls and completing multi-step tasks, the field has borrowed heavily from classical RL terminology. In agentic RL for LLMs, [Harbor](https://github.com/harbor-framework/harbor) provides one way to package such RL-environments into the final ingestible form for delivery to clients (which would be frontier LLM labs).
>
> Concretely, what would an “RL environment” really look like, in code? Drawing from [Harbor documentation](https://www.harborframework.com/docs/tasks), any task would consist of a task.toml, a [prompt.md](http://prompt.md/)⁴, a Dockerfile or equivalent environment setup, a solution script to prove that this task is solvable, and an evaluator / verifier that grades the solver’s output. In this case, you could collapse the definition of a solver agent into any coding agent (Claude Code with some Anthropic model, Codex with some form of GPT model, etc.).
>
> *The Harbor task directory: `prompt.md` and Dockerfile are visible to the solver; `solution.sh` and `verifier/` are hidden from it*
> ![[danielchingwq-543621-003.png]]
>
> This solver agent then attempts the task that it’s given (in the [prompt.md](http://prompt.md/)) using the tools that are installed in the Dockerfile, much as a human would use available libraries. In doing so, one must ensure that this solver agent does not have access to the solution script, as well as the evaluator / verifier – if not such a task would be too trivial / easy for the agent (some would consider this to be a case of “reward hacking”).
>
> To understand why these environments matter for training, it is useful to place them in the broader history of post-training. In Supervised Fine Tuning (SFT), a model is trained on fixed demonstrations of desired behavior; in RL, [the model can instead generate its own attempts and be optimized according to feedback on their outcomes](https://arxiv.org/abs/2203.02155). When outcomes are checkable, the feedback can come from a [verifier rather than exclusively from human judgement](https://arxiv.org/pdf/2110.14168).
>
> This is where RL environments become particularly useful. Here, the coding / solver agent generates its own trajectories, receives a reward based on the outcome and under RL settings, its policy is then updated to favour behaviors that score more highly. In algorithms like [GRPO](https://arxiv.org/pdf/2402.03300), multiple trajectories (or rollouts) can be sampled for the same task and compared against one another to determine which behaviors to reinforce.
>
> The value of these environments are a reflection of why the current paradigm of language models are useful: for their ability to use intelligence well through executing complex tool calls, in the hope of [completing multi-step, long horizon tasks](https://metr.org/time-horizons/). This maps closely onto most knowledge work, which [largely consists of interdependent tasks](https://pubsonline.informs.org/doi/10.1287/orsc.2025.21838) rather than isolated actions. More importantly, the difficulty for agents increasingly lies in stringing longer sequences of actions together successfully rather than merely performing individual steps. As labs push models toward automating more of this work, they need environments in which those capabilities can be practiced and evaluated. A well defined environment lets the model learn from the consequences of its actions. Such an environment (as elaborated further later) is both a source of training and an instrument for measuring model behavior.
>
> Why, then, has so much attention and capital accumulated around these environments? At the simplest level, labs have large budgets allocated toward improving model capabilities. [Several](https://x.com/danielrupawalla/status/2085124053745217822) posts have explained why labs do not inherently create all of post-training data in house (more on this later, as well)⁵. Labs, with their ever-growing areas to hillclimb on, have mostly insatiable demand, with supply of data of their required task shape / form lagging very much behind. Strong environments therefore become reusable seeds for trajectory generation; their value comes from the model improvement they can induce, not merely the unit cost of creating one. [While these environments are valued highly](https://epoch.ai/gradient-updates/state-of-rl-envs), there is often significant deviation in the quality of said environments – whether these environments even produce the intended training signal – which will be explored in the following piece.
>
> ## Notes
>
> ¹FineWeb’s ablations held model size, architecture and training token count fixed, yet filtering for higher-quality educational content increased MMLU perf from ~33% to 37%, and ARC from 46% to 57%.
>
> ²The classical formalism underlying an RL environment is the Partially Observable Markov Decision Process (POMDP), in which an agent receives observations of an underlying state, takes actions that transition the environment and receives rewards for said behavior. An RL environment can be thought of as the runnable instantiation of this interaction. Classical RL examples include [MuJoCo](https://mujoco.org/) or [MiniGrid](https://arxiv.org/abs/2306.13831).
>
> ³Also known as trace(s).
>
> ⁴A specification of what the solver agent is being asked to solve. For instance, it could be as simple as “Create a Python function that calculates the `nth` Fibonacci number”.
>
> ⁵The reason that is the most intuitive to me would be that of data diversity. It is, in my opinion, a rather high leverage move to outsource this task of curating data to various vendors, who then have their own separate methods of curating said data (through contractors, in house experts, etc.), rather than for labs to spin up their own in-house efforts.
>
> date: Fri Sep 04 17:04:12 +0000 2026
> url: https://x.com/danielchingwq/status/2095920878907543621
> likes: 102  retweets: 7  replies: 9
