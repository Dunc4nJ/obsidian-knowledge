---
created: 2026-08-20
description: Harvey's post-training update (Pereyra, Grupen et al.) introducing Tenet — a Kimi K3 base post-trained with Fireworks via async RL (GSPO, rank-64 LoRA over ~500k expert tensors, ~150 B300s for 2 months, ~1,750 rubric-graded legal environments) for long-horizon legal work. Nearly 2x LAB hold-out task completions, SOTA on LAB Contracts, gains transferring zero-shot to APEX Agents and RedlineBench; cost co-optimized via reward shaping for efficient tool use. Plus three capability tracks: RLM harnesses for 80M-token M&A diligence (43.8% → 60.1%), Review Table extraction at one-tenth cost per cell, and Engram parametric firm-knowledge memory (-58% tokens, -90% cost per query, 3x intelligence-per-token).
source: https://x.com/gabepereyra/status/2090453918547685537
author: "Harvey (Gabe Pereyra, Niko Grupen, Julio Pereyra, Calvin Congelado, V. Rengarajan)"
type: article
tags: [post-training, rl, gspo, legal-agents, open-weights, kimi-k3, rlm, agent-memory, reward-shaping, harvey, fireworks, vertical-models]
---

## Key Takeaways

- **The strategic frame: frontier legal intelligence on open weights, and letting law firms own their models.** Harvey's two research goals — build frontier legal capability on open-weight bases, and create systems for firms to post-train their *own* specialized models — are [[Harrison Chase argues companies must own their intelligence by controlling the model-harness-context system its governance and the compounding feedback loop|own-your-intelligence]] executed at a legal-vertical leader, and the professional-services sibling of [[Bridgewater and Thinking Machines fine-tune Qwen3-235B to replicate expert investor judgment, beating frontier LLMs on financial information-filtering at 13.8x lower cost|Bridgewater's differentiated-intelligence play]]. **Tenet** = Kimi K3 base + Fireworks post-training for long-horizon legal work: nearly **2x LAB hold-out task completions** (+9pp all-pass) and +20% on LAB Contracts (SOTA there; second place on LAB). Crucially, gains **transfer zero-shot** to benchmarks never seen in training — Mercor's APEX Agents (corporate law) and Crosby's RedlineBench — while parametric-knowledge benchmarks (LegalBench, CUAD, MAUD, APEX-v1, PRBench) hold steady: agentic capability improved without eroding textbook legal knowledge.

- **The training recipe is a production-harness RL case study.** Environments mirror LAB tasks: a ~50-word partner-style request, a closed-universe client matter with issues *embedded across files*, and an expert rubric of ~50 atomic pass/fail criteria (largest: hundreds) — single rollouts span **>1,000 turns and hundreds of thousands of tokens**. Reward = weighted rubric-fraction + holistic issues-solved + perfect-score bonus, judged by **Kimi 2.6** (ablated against heavier frontier judges — the [[LangChain and Harvey show DeepSeek batch verifiers reduce legal agent evaluation costs by three orders of magnitude at acceptable accuracy|cheap-judge result]] applied to training). Optimizer: **GSPO** with group-normalized advantages, re-judging near-tied groups to keep noise out of the gradient, intra-group length term favoring concise deliverables, double-sided clipping + high-importance-ratio token masking against RL collapse. Scale: rank-64 LoRA over the full K3 network (~500k expert tensors), 8 groups × 8 rollouts per step, ~1,750 environments, >10,000 rollouts/epoch, **~150 B300s for 2 months**, async with hot-loaded weights. The subtle infrastructure point: trainer/rollout numerical misalignment destabilizes RL on a finite-precision MoE, solved by Fireworks' kernel-level co-building + token-in-token-out with router replay — [[the agent harness is the RL training environment not deployment infrastructure bolted on after|the-harness-is-the-training-environment]] and [[RL environments are the new unit of progress in agentic AI training|environments-as-the-unit-of-progress]] made concrete. No customer data used.

- **Cost is co-optimized, not traded off — reward shaping for token efficiency.** Open weights give cheaper tokens, but Harvey also shaped rewards to prefer trajectories consuming fewer inference tokens at equivalent performance — "co-optimize for both cost and quality, gaining significant performance while keeping cost stable." Expert data (Mercor et al.) for both authoring and synthetic-data remediation is named as the thing that made training at this scale possible.

*LAB all-pass rate vs cache-aware cost per task — Tenet (Harvey) moves straight up from the Kimi K3 base at stable cost:*
![[gabepereyra-685537-001.png]]

- **Capability track 1 — RLM harnesses for 80M-token M&A diligence.** No baseline passes >43.8% of LAB Diligence rubric criteria. With Baseten, Harvey extended the harness to [[Recursive Language Models pass context by reference through a Python REPL so subagent outputs return as variables instead of autoregressively regenerated tokens|Recursive Language Models]]: a root agent holds the dataroom in a REPL, slices it programmatically, and delegates to sub-agents with their own contexts. RLM harness alone (GLM-5.2 orchestrator): 46.1%; **post-training the orchestrator in-harness via self-distillation over high-coverage traces: 60.1%** — mostly by fixing the base model's tendency to *under-delegate* dataroom review. Post-training targets the harness behavior, not just the model.

*LAB Diligence criteria pass rates — RLM harness beats coding-agent harnesses, and in-harness post-training beats both:*
![[gabepereyra-685537-002.png]]

- **Capability tracks 2 & 3 — extraction at a tenth the cost, and parametric firm memory.** *Review Table* (with Applied Compute): GLM-5.2 post-trained in the production harness for structured extraction over up to 10,000 documents — **+3.6 answer quality, +12.1 citation quality at ~one-tenth the cost per cell**, learning to abstain when questions don't apply and to cite precisely rather than pad. *Firm Knowledge* (with Engram): a Qwen3.8-27B that consolidates a ~100M-token firm corpus into 1M tokens of structured notes and internalizes it in weights via distillation + RL over self-generated data — **+15% criteria pass, -58% trajectory tokens, -90% cost per query, and 3x "intelligence-per-token"** (190.8 vs 129.3 for the best frontier config) — the [[learning machines turn agents from stateless tools into systems that compound knowledge across users and sessions|compounding-knowledge]] thesis implemented in weights rather than files. Both validate training *inside* the production harness, per [[agentic RL training converges on outcome rewards inside production harnesses across Kimi Cursor and Chroma]].

*Engram firm-knowledge results — study effort beats reasoning effort, and the post-trained 27B triples intelligence-per-token:*
![[gabepereyra-685537-005.png]]
![[gabepereyra-685537-006.png]]

- **The appendix is a model of benchmark-reporting honesty — worth reading in full.** Harvey documents every harness divergence: their APEX Agents runs used direct bash access vs Mercor's MCP harness, which helped some models (+7.7% Fable 5) and hurt others (-4.2% GPT-5.6 Sol) — so they report Mercor's official scores as primary while disclosing their own harness lifts K3 from 58.8% → 67.5%; APEX-v1 was run *blind* by Mercor on held-out tasks; LegalBench needed structured outputs because exact-match grading fails modern chat models; CUAD/MAUD's AUPR metric is impossible without logprobs so they document the substitute metric per benchmark. This is [[benchmarks are measurement instruments not question collections - regulargio's first-principles guide to claims, graders, coverage, and uncertainty|benchmarking-science]] discipline in a vendor report — and the [[Prime Intellect's fine-tune-last doctrine - 5x task timeouts lifted Terminal-Bench 14.7 points with no model change|harness-effect-on-scores]] shown from the vendor side. Standing caveat per [[vertical model advantage may not survive the next frontier release]]: Tenet's edge is measured against today's frontier.

## External Resources

- Original post: [Update on our post-training effort — @gabepereyra (Harvey), 2026-08-20](https://x.com/gabepereyra/status/2090453918547685537); authors Niko Grupen, Julio Pereyra, Calvin Congelado, V. Rengarajan, Gabe Pereyra
- Harvey blog series: [LAB](https://www.harvey.ai/blog/introducing-harveys-legal-agent-benchmark) · [LAB Diligence](https://www.harvey.ai/blog/legal-agent-bench-m-and-a-due-diligence) · [LAB: Firm Knowledge](https://www.harvey.ai/blog/legal-agent-bench-law-firm-knowledge) · [LAB: Contracts](https://www.harvey.ai/blog/legal-agent-benchmark-in-house-contracting) · [Review Table training (with Applied Compute)](https://www.harvey.ai/blog/training-frontier-review-table-models-with-applied-compute) · [Engram's firm-memory post](https://engram.com/blog/legal-agents-with-memory)
- Method: [GSPO (arXiv 2507.18071)](https://arxiv.org/abs/2507.18071) · partners: Fireworks (training platform, batch-invariant kernels), Baseten (RLM), Applied Compute, Engram, Mercor, NVIDIA, Snorkel
- Benchmarks: [APEX Agents](https://www.mercor.com/apex/apex-agents-leaderboard/corporate-lawyer-agent/) · [RedlineBench](https://intelligence.crosby.ai/) · [APEX-v1](https://www.mercor.com/apex/apex-v1-leaderboard/) · [PRBench](https://github.com/scaleapi/PRBench) · [LegalBench](https://hazyresearch.stanford.edu/legalbench/) · [CUAD](https://www.atticusprojectai.org/cuad/) / [MAUD](https://www.atticusprojectai.org/maud/) · [Vals LAB leaderboard](https://www.vals.ai/benchmarks/hlab)

## Original Content

> [!quote]- Full X Article — "Update on our post-training effort" (Harvey; @gabepereyra et al., 2026-08-20)
> Article: Update on our post-training effort
>
> Authors: [@nikogrupen](https://x.com/@nikogrupen) [@ItsJulioPereyra](https://x.com/@ItsJulioPereyra) @calvincongelado @vtrengarajan @gabepereyra
>
> Over the past six months, Harvey’s research agenda has focused on two goals:
>
> 1. Building frontier legal intelligence using open-weight models; and
>
> 2. Creating systems to allow law firms to build their own specialized models and own their intelligence.
>
> Today, we’re sharing an update on that research effort, including initial results from our first post-trained model, which we’re calling Tenet. Tenet is a Kimi K3 base that we post-trained together with Fireworks research for long-horizon legal work. In addition, it incorporates harness improvements to make training and task execution more effective. Our initial work shows promising results for both performance and cost-efficiency.
>
> Quality
>
> Our goal in training was to improve the model's ability to perform long-horizon, agentic legal tasks. Post-training on a combined corpus of synthetic data, publicly-available legal data, and human expert data substantially improves model performance on LAB hold-out tasks. Our model successfully completes almost twice as many held out tasks on LAB and 20% more on LAB contracts than base Kimi K3, increasing all-pass rate by 9 and 2 percentage points, respectively. These improvements are grounded in broad criteria gains around answer detail and citations similar to those we’ve seen across models like [NVIDIA’s Nemotron](https://www.trajectory.ai/field-notes/harvey-nemotron-3-ultra). It achieves state-of-the-art performance on LAB Contracts and places second on LAB.
>
> We find these improvements generalize to other leading agent benchmarks including Mercor’s [APEX Agents](https://www.mercor.com/apex/apex-agents-leaderboard/corporate-lawyer-agent/) (Corporate Law) and Crosby’s [Redline Bench](https://intelligence.crosby.ai/) where our model substantially outperforms the K3 base. These gains are particularly interesting, as our model had not seen these benchmarks during training, and thus demonstrate that the model’s learned behaviors transfer robustly across benchmarks and harnesses.
>
> Our model also maintains strong performance on benchmarks that test legal knowledge, rather than agentic capabilities. This includes legal-specific parametric reasoning benchmarks, such as Mercor’s [APEX-v1](https://www.mercor.com/apex/apex-v1-leaderboard/) and, Scale’s [Professional Reasoning Benchmark](https://labs.scale.com/leaderboard/prbench-finance), and legal knowledge benchmarks like [LegalBench](https://hazyresearch.stanford.edu/legalbench/), [CUAD](https://www.atticusprojectai.org/cuad/), and [MAUD](https://www.atticusprojectai.org/maud/). We find that agentic capabilities can be improved without affecting the base model’s broader understanding of textbook legal concepts.
>
> Full details on our benchmarking can be found in the appendix.
>
> Cost-efficiency
>
> Our second major finding is cost-efficiency. Post-training open models provides two opportunities for improving a model’s cost profile. The first is obvious, open-weight models have cheaper per token prices. But cost is a function of both token prices and tokens used. In post-training, we incentivized efficient tool use and reasoning through reward shaping, preferring trajectories that would reduce tokens consumed at inference-time given equivalent performance. This allowed us to co-optimize for both cost and quality, gaining significant performance while keeping cost stable.
>
> Data, and specifically human expert data, is a crucial component of our post-training work. We collaborated closely with Mercor and others to build and scale human expert datasets and for review and remediation of synthetically-generated data, which made training at this scale possible.
>
> In the rest of this post, we outline our training and evaluation methodology, and highlight additional capabilities that we have developed through our research and will be incorporating into the Harvey product over time.
>
> ## Training
>
> Starting from a Kimi K3 base, we worked with Fireworks to post-train our model via asynchronous reinforcement learning (RL) in realistic legal work settings. During training, an agent is given long-horizon legal tasks to solve and is graded on its ability to produce substantive legal work product efficiently.
>
> Training environments share the structure of [Legal Agent Benchmark](https://www.harvey.ai/blog/introducing-harveys-legal-agent-benchmark) tasks. Each environment consists of:
>
> 1. A task instruction written as a request for work from a partner;
>
> 2. A client matter containing the relevant documents and materials; and
>
> 3. An expert rubric that outlines the substantive points a high-quality work product must contain.
>
> For each training rollout, the agent is initialized in a sandboxed workspace containing the task's client matter files and the tools it needs to search the matter, read documents, and draft work product. After completing its work, the agent writes its final deliverables to disk, which ends the episode.
>
> Each rollout is graded via LLM-as-a-judge over the task's rubric. Reward is defined as the weighted sum of a granular term for the fraction of rubric criteria satisfied and a holistic term counting the number of underlying legal issues solved, plus a bonus for rollouts that score perfectly on all criteria. We ran ablations comparing candidate judge models against heavier frontier models for grading and converged on Kimi 2.6 as the optimal judge for quality and efficiency.
>
> We optimize the agent's policy with group-sequence policy optimization ([GSPO](https://arxiv.org/abs/2507.18071)). For each training task, we sample a group of independent rollouts, score each with the rubric reward described above, and compute advantages within the group, normalized by group variance. Near-tied groups are rejudged to reduce noise entering the gradient, and a small intra-group length term favors concise deliverables. Tokens are weighted via sequence-averaged importance weights, which we find results in stable and efficient training. We additionally enforce double-sided clipping and mask out high-importance-ratio tokens to prevent RL collapse.
>
> Additional training details can be found in the appendix. We did not use any customer data in any of our post-training efforts.
>
> ## Capabilities
>
> In addition to our work on core legal task execution, we have explored ways to post-train models around capabilities beyond those available in a standard agent harness. These capabilities are each trained separately and can be deployed as tools and sub-agents that our model can route to in order to tackle specific tasks.
>
> In this section, we outline initial results across:
>
> 1. M&A Diligence: Post-training in RLM harnesses to enable models to effectively coordinate high-scale, long-horizon tasks like M&A diligence.
>
> 2. Review Tables: Making models more effective and efficient at high-volume document review and structured data extraction.
>
> 3. Firm Knowledge: Models that are trained to understand firm knowledge through memory and emergent, structured taxonomies, enabling higher-quality and more efficient search.
>
> Each capability is trained and evaluated on a task-specific dataset. For each capability, we describe the dataset, our current results, and why we think they provide a promising direction to better legal agents.
>
> M&A Diligence
>
> We have seen significant gains from post-training on complex, document-intensive tasks like M&A Diligence. On [LAB Diligence](https://www.harvey.ai/blog/legal-agent-bench-m-and-a-due-diligence), a single task requires traversing up to 80M tokens of document context to identify risks and produce a diligence memo. Both frontier models and off-the-shelf coding agents struggle in this setting, with no baseline passing more than 43.8% of rubric criteria on LAB Diligence.
>
> Maximizing agent performance for specialized tasks like this comes from post-training within an agent harness that has the right primitives for the domain. Together with Baseten research, we extended our agent harness to include Recursive Language Models (RLMs). In the RLM construction, a root agent holds each task’s dataroom in a REPL environment, can search and slice it programmatically, and delegate research and analysis to sub-agents with their own context windows. Moving to the RLM harness with a GLM-5.2 orchestrator alone lifts criteria pass rate to 46.1%. Post-training GLM-5.2 within the RLM harness via self-distillation over high-coverage traces further improves the pass rate to 60.1%, largely by correcting the base model's tendency to under-delegate review of the dataroom.
>
> These are early research results and we will be sharing more detail in a forthcoming technical report.
>
> Review Table
>
> Another area where we have seen substantial gains from post-training is in high-volume document analysis tasks like Harvey's Review Table. With Review Table, users perform structured data extraction and analysis at scale, over up to 10,000 documents at a time, and each model response must be well-structured with accurate citations.
>
> *Harvey Review Table — structured extraction over a commercial-agreements matter, with per-cell verification:*
> ![[gabepereyra-685537-003.jpg]]
>
> Together with Applied Compute, we built a corpus of synthetic and public data targeting capability gaps of frontier models in representative Review Table tasks. We used this corpus to post-train a GLM-5.2 model for structured data extraction and analysis, with reward shaping to encourage well-formatted, concise answers with precise citations. Relative to the strongest baselines, the post-trained model improves answer quality by 3.6 points and citation quality by 12.1 points at roughly one-tenth the cost per cell, pushing the cost-quality Pareto frontier. During RL post-training, the model learns useful behaviors like abstaining when a question does not apply to a document and citing precise supporting evidence rather than padding citations.
>
> *Answer and citation quality vs baselines — the post-trained GLM-5.2 leads both at ~one-tenth cost per cell:*
> ![[gabepereyra-685537-004.png]]
>
> We attribute these gains to our ability to train directly inside the Review Table production harness, where the model can learn how to navigate retrieval context, schema constraints, and citation requirements during training. Full details are in our [blog post](https://www.harvey.ai/blog/training-frontier-review-table-models-with-applied-compute).
>
> Firm Knowledge
>
> We have seen similarly promising gains from post-training agents to search and reason over a firm's accumulated knowledge. On [LAB: Firm Knowledge](https://www.harvey.ai/blog/legal-agent-bench-law-firm-knowledge), completing precedent search tasks requires reasoning over ~100M tokens of synthetic client matters. Lacking any knowledge of the firm, base models default to repetitive, exhaustive search, re-reading the same workspace on every query.
>
> To address this, we partnered with Engram to train a Qwen3.8-27B model that encodes the firm’s knowledge into parametric memory and structured text notes. During training, the agent explores the firm knowledge base, consolidates features into 1M tokens of structured knowledge, and internalizes the corpus in its weights through distillation and RL over self-generated data.
>
> This approach substantially improves the model’s ability to efficiently identify relevant law firm knowledge, improving criteria pass rate more than 15% and task completion rate by nearly 10%. Memory also leads to more targeted searches, cutting total tokens in completed trajectories by 58%. Combined, the post-trained model identifies relevant matters and completes tasks competitively with leading frontier models while reducing cost per query by 90%.
>
> It also triples intelligence-per-token, which is measured as the mean rubric criteria points that an agent completes successfully per 100k inference tokens. Our model scores 190.8 in our intelligence-per-token metric against 129.3 for the best frontier configuration and 37.2 for equivalently sized models. Token-efficient trajectories are not only faster and cheaper, they avoid polluting an agent’s context window with irrelevant results allowing for more accurate and precise answers over large-scale context.
>
> Full details are in Engram’s [blog post](https://engram.com/blog/legal-agents-with-memory).
>
> ## What’s next
>
> Tenet and its extended capabilities are a major milestone in our research across environment design, post-training, and open weight models. It shows that training on the right environments can improve model capabilities even for the most complex legal tasks and, when coupled with novel research, unlock entirely new approaches to building more effective legal agents.
>
> Next, we are scaling LAB to more jurisdictions, practice areas, and workflows to help understand and improve agent performance across the full diversity of legal work. We are also focused on scaling our compute so that we can bring our work from research to production with new generalist models and capabilities in Harvey.
>
> LAB and post-training show promise for better professional service agents, and we’re excited to work to deliver on that promise for our customers.
>
> ## Acknowledgements
>
> This work would not have been possible without the support of many teams and partners. We’re especially grateful to Fireworks, Engram, Baseten, Applied Compute, NVIDIA, Mercor, and Snorkel AI for their partnership in building these models and environments, and to Spencer Poff, Nick Gillies and Karl de la Roche for their contributions to these projects. And a special thanks to the Assistant, AI Platform, Review Table, Security within Harvey for helping to bridge research and product.
>
> # Appendix
>
> Here we describe environment design, training, and evaluation methodologies in more detail.
>
> ## Environment design
>
> Our model was trained on agentic legal environments, similar to those found in LAB, and evaluated across legal benchmarks. Each task is built as a closed-universe client matter. Instructions are short, averaging around 50 words, and are written as a request for work from a partner rather than a detailed specification of the expected output. The matter files mix key and peripheral documents, with the underlying legal issues embedded across multiple files, so the agent must start from a loose instruction, build context across the matter, and use that context to produce reviewable work product.
>
> Each task's expert rubric decomposes partner-level review into atomic, binary pass/fail criteria – facts, conclusions, citations, severity ratings, recommendations, and formatting – with each criterion tied to a specific deliverable file. On average, a task contains 50 rubric criteria, with the largest tasks containing hundreds. Given the breadth of the matter files and the granularity of the rubrics, a single rollout can span >1,000 turns and use hundreds of thousands of tokens.
>
> ## Training details
>
> Training consisted of GSPO with a rank-64 LoRA over the full Kimi K3 network, adapting all attention, MLP, and routed-expert weights (~500k expert tensors). For optimization, we leveraged AdamW, with each optimizer step consuming 8 task groups of 8 rollouts. The training dataset comprised ~1,750 agentic legal task environments as described above. For each training epoch, we ran 150 optimizer steps across more than 10,000 individual rollouts. The model was trained on approximately 150 NVIDIA B300 GPUs over the course of 2 months.
>
> During training, agent rollouts and the trainer itself run in an asynchronous loop. A local orchestrator keeps a fleet of agent rollouts in flight against the rollout deployments while the trainer consumes finished groups, with a hard staleness bound keeping off-policyness in check. After every optimizer step the new weights are hot-loaded into the deployments in place, so the deployments never restart and generation rarely stops.
>
> A key to successful RL is alignment between training and inference. Kimi K3 is a large mixture-of-experts model served in finite precision, and the trainer recomputes logprobs in a different numerical world than the one that generated the rollout. This misalignment can destabilize RL. To solve this, the Fireworks training platform co-builds the trainer and rollout deployments at the kernel level to minimize numerical gaps (see the blog on batch-invariant kernels). At the loop level, we further adopt a token-in-token-out design with router replay to guarantee alignment.
>
> ## Benchmarks
>
> Here we discuss the evaluation methodology we used to ensure consistency and accuracy on each reported benchmark. We also describe any implementation divergences or divergences from other public reports of those benchmarks.
>
> The table above includes additional baseline models that we ran in our evaluation.
>
> Legal Agent Bench (LAB)
>
> [LAB](https://www.harvey.ai/blog/introducing-harveys-legal-agent-benchmark) is Harvey’s open-source benchmark of long-horizon legal agent tasks, consisting of more than 1,200 tasks across 24 practice areas. All evaluations for LAB were scored on the official hold-out set. Our model was run in the standard public harness with the addition of a finish tool, which was added as a training optimization and carried over to the test-time harness. We report scores for base models from [Vals](https://www.vals.ai/benchmarks/hlab) as we find they track more closely to our internal methodology.
>
> Our internal runs differ from those of other external reporting partners due to differences in harness and judge implementation. Artificial Analysis documents its harness and judge methodology [here](https://artificialanalysis.ai/methodology/intelligence-benchmarking#harvey-lab-aa). They run models in their stirrup harness and use Gemini 3.1 Pro as a grader. Vals documents its methodology [here](https://www.vals.ai/benchmarks/hlab). They run LAB on their internal LLM abstractions, Valkyrie infrastructure and change judge instructions to allow for more efficient caching. Vals reports that these changes are purely infrastructural and do not represent a substantive change from the canonical setup.
>
> LAB: Contracts
>
> [LAB: Contracts](https://www.harvey.ai/blog/legal-agent-benchmark-in-house-contracting) extends LAB to in-house contracting work, containing 500 agentic tasks across contract drafting, review, and negotiation. We follow the same harness, grading, and reporting methodology described for LAB above and report scores on a 50-task official hold-out set. All reported scores are internal Harvey runs, as there is not yet a public leaderboard for LAB: Contracts.
>
> APEX Agents
>
> [APEX Agents](https://www.mercor.com/blog/introducing-apex-agents/) is Mercor's benchmark of long-horizon, professional-services tasks set in simulated work environments. We evaluated our model on the corporate-lawyer subset, whose tasks were authored by practicing attorneys. We ran our post-trained Kimi K3 checkpoint in our internal harness with direct bash access to a filesystem mount of each task's world. This differs from Mercor's canonical implementation, which exposes files/tools to the model through structured MCP servers driven by a ReAct or Loop agent harness ([Archipelago](https://github.com/Mercor-Intelligence/archipelago/tree/main/agents/runner/agents)).
>
> We found that our approach had a mixed effect on other models, with some scoring better (Fable 5: +7.7%) and some regressing (GPT-5.6 Sol: -4.2%). Accordingly, we chose to report Mercor’s published [scores](https://www.mercor.com/apex/apex-agents-leaderboard/corporate-lawyer-agent/) for all models as our primary leaderboard metric. Running Kimi K3 in our harness improves it from its reported score of 58.8% to 67.5%.
>
> We otherwise keep Mercor's official grading (Gemini 3 Flash, thinking=low) and report Pass@1 over 8 trajectories.
>
> Redline Bench
>
> [RedlineBench](https://intelligence.crosby.ai/) is Crosby's multi-turn, contract negotiation benchmark, in which models produce document-native redlines across alternating negotiation turns and are graded against attorney-authored rubrics. We ran our model using Crosby’s standard Harbor config including their default harness, skill scripts, and judging set up. For some models not reported on Hugging Face, we received internal scores from the Crosby team and reproduce them here with their permission.
>
> APEX
>
> [APEX](https://www.mercor.com/apex/apex-v1-leaderboard/), the predecessor to APEX Agents, is Mercor's expert-graded benchmark of economically valuable knowledge work across four professions. We evaluated our model on its legal subset, [Big Law Associate](https://www.mercor.com/apex/apex-v1-leaderboard/big-law-associate/). APEX was run and graded by Mercor against their held-out set of 100 tasks.
>
> We provided Mercor with access to our model, which they ran independently without disclosing the runs, tasks, or task-level scores. For other models, we use publicly reported scores from Mercor's [leaderboard](https://www.mercor.com/apex/apex-v1-leaderboard/big-law-associate/).
>
> PRBench
>
> [PRBench](https://github.com/scaleapi/PRBench) is Scale AI’s benchmark of high-stakes professional reasoning in law and finance, with expert-authored tasks graded against expert-curated rubrics. We evaluated our model on the full benchmark using the standard configs and evaluation implementation. For other models, we report Scale's [public scores](https://labs.scale.com/leaderboard/prbench-legal).
>
> PRBench has a 250-question “hard” subset but its public leaderboard is stale as of the time of publication with the most recent model reported being GPT-5. Our model showed non-statistically significant improvement over K3 base on the hard subset, increasing from 36.0% to 36.8% criteria pass rate.
>
> LegalBench
>
> [LegalBench](https://hazyresearch.stanford.edu/legalbench/) is a benchmark of 162 legal tasks spanning six types of legal reasoning and totaling more than 200,000 evaluation examples. We evaluated our model across 161 tasks available on [Hugging Face](https://huggingface.co/datasets/nguha/legalbench), omitting the Rule QA task that states it is meant to be hand-graded. For other models, we report scores from [Vals](https://www.vals.ai/benchmarks/legal_bench) who run a longstanding LegalBench leaderboard. The Vals team samples 200 examples per task type, finding that additional examples do not materially change scores when aggregated across tasks. We adopted this 200-example convention in our own runs.
>
> LegalBench is designed to run on legacy completion models, with models being prompted to complete the result from a few-shot output. For example:
>
> ```
> A mark is generic if it is the common name for the product. A mark is descriptive if it describes a purpose, nature, or attribute of the product. A mark is suggestive if it suggests or implies a quality or characteristic of the product. A mark is arbitrary if it is a real English word that has no relation to the product. A mark is fanciful if it is an invented word.
>
> [few-shot examples omitted but follow Q: A: form]
>
> Q: {{text}} What is the type of mark?
>
> A:
> ```
>
> These types of prompts create noisy responses in modern chat models, which often provide additional context before or after a response without additional prompting such as “the mark is fanciful” or “answer: fanciful”. These responses fail the standard LegalBench grader which does exact text matching against the response and an expected golden answer (“fanciful”). For cases involving exact match grading, we used structured outputs to standardize our model’s responses without providing any additional substantive content beyond the LegalBench prompt.
>
> Contract Understanding Atticus Dataset (CUAD)
>
> [CUAD](https://www.atticusprojectai.org/cuad/) is a contract-review dataset of 510 commercial contracts annotated by legal experts for 41 clause categories. We evaluated our model on the full dataset. As originally described, CUAD requires log probabilities to estimate model uncertainty and reports Area Under the Precision-Recall curve (AUPR) as its headline metric.
>
> Most leading closed-source models do not expose log probabilities, making this metric impossible to compute independently. We instead report CUAD's alternative metric of generative F1 for all models, using CUAD's standard [implementation](https://github.com/TheAtticusProject/cuad/blob/main/evaluate.py). This metric measures precision and recall of passages retrieved from a contract with at least 0.5 Jaccard similarity to a human-annotated gold set. We report Harvey-run scores for every model.
>
> Merger Agreement Understanding Dataset (MAUD)
>
> [MAUD](https://www.atticusprojectai.org/maud/) is a dataset for merger agreement understanding, posing 92 deal-point questions over 152 public-target merger agreements. We evaluated our model across all 92 questions, sampling up to 20 examples per question. MAUD's full test set is roughly 42,000 rows; the 20-example cap keeps every question represented while bounding the run size and landing full run standard errors for all models below 1%. We report scores for all models under this sampling methodology.
>
> Like CUAD, MAUD's standard metric is AUPR, which cannot be computed without access to a model's log probabilities. MAUD does not provide a standard alternative grading approach, but the dataset largely consists of classifying passages of a merger agreement into specific categories. We therefore report generative answer-matching accuracy. To compute this, the model is shown the excerpt, question, and answer options and generates its choice, which is scored correct when it matches the gold answer. We report mean per-question accuracy across the 1,840 sampled questions for every model.
