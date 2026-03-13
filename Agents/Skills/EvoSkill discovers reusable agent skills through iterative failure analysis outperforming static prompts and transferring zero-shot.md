---
created: 2026-03-13
description: EvoSkill uses failure-driven textual feedback descent to automatically discover and refine structured agent skills that improve benchmark performance by up to 12% and transfer zero-shot to unseen tasks.
source: https://arxiv.org/abs/2603.02766
type: paper
authors:
  - Salaheddin Alzubi
  - Noah Provenzano
  - Jaydon Bingham
  - Weiyuan Chen
  - Tu Vu
arxiv: "2603.02766"
---

## Abstract

Coding agents are increasingly used as general-purpose problem solvers, but their flexibility does not by itself confer the domain expertise needed for specialized tasks. Recent work addresses this through agent skills: reusable workflows and code that augment agents with domain-specific capabilities. Most skills today are hand-crafted, and existing evolutionary approaches optimize low-level artifacts (e.g. prompts and code) that are tightly coupled to specific models and tasks. EvoSkill is a self-evolving framework that automatically discovers and refines agent skills through iterative failure analysis. It analyzes execution failures, proposes new skills or edits to existing ones, and materializes them into structured, reusable skill folders. A Pareto frontier of agent programs governs selection, retaining only skills that improve held-out validation performance while the underlying model remains frozen. EvoSkill improves exact-match accuracy by 7.3% on OfficeQA (60.6% to 67.9%) and 12.1% on SealQA (26.6% to 38.7%), with a skill evolved on SealQA transferring zero-shot to BrowseComp for a 5.3% gain.

## Key Takeaways

The central contribution is elevating evolutionary optimization from the artifact level (prompts, code) to the skill level. Where AlphaEvolve and GEPA evolve code or prompts tightly coupled to a specific model and task, EvoSkill evolves structured SKILL.md folders — the same format used by Claude Code and the [[agent skills should self-improve through observed failures not stay as static prompt files|Agent Skills specification]]. This means the outputs are human-readable, composable, and portable across agent harnesses rather than opaque optimized strings.

The three-agent architecture (Executor, Proposer, Skill-Builder) implements a clean separation of concerns that mirrors how [[skill-creator now brings software testing rigor to agent skill authoring without requiring code|skill authoring already works in practice]]: one agent runs tasks and fails, another diagnoses failures and proposes fixes, and a third materializes proposals into concrete skill folders. The Proposer maintains cumulative feedback history across iterations, preventing redundant proposals and enabling progressively richer diagnosis — a design reminiscent of how [[MemSkill: Learning and Evolving Memory Skills for Self-Evolving Agents|MemSkill]] accumulates experience for self-evolving agents.

The zero-shot transfer result is the most striking finding: a search-persistence-protocol skill evolved on SealQA (noisy web search QA) transfers directly to BrowseComp (browsing agent benchmark) with no modifications, yielding a 5.3% improvement. This validates the thesis that [[skill graphs outperform single skill files by letting agents traverse linked domain knowledge on demand|structured skill representations]] produce more transferable capabilities than prompt-level optimization, because skills encode general strategies (like "exhaustive search before committing") rather than task-specific token patterns.

The skill-merge configuration — combining unique skills from independent runs — outperforms any individual run (67.9% vs best single run of 65.8% on OfficeQA). This suggests that different evolution runs surface complementary failure modes and capabilities, and the resulting skill libraries are compositional rather than redundant. This has practical implications for [[agent skills need eval harnesses not vibe checks to ship reliably|skill evaluation]]: running multiple evolution seeds and merging the results may be a reliable strategy for building comprehensive skill libraries.

The framework requires only small training subsets (5-15% of benchmark data) to discover effective skills, with diminishing returns beyond 10%. This is practical for real deployments where labeled data is scarce. The underlying model stays completely frozen — all improvement comes from the skill layer, supporting the broader thesis that [[repo-local skills and AGENTS.md turn recurring engineering work into repeatable agent workflows|agent capabilities should be encoded in reusable artifacts]] rather than requiring model fine-tuning.

## External Resources

- [EvoSkill GitHub](https://github.com/sentient-agi/EvoSkill) — Open-source implementation of the framework
- [Agent Skills Specification](https://agentskills.io/specification) — The open format for portable agent skills that EvoSkill targets
- [AlphaEvolve](https://arxiv.org/abs/2506.13131) — Google's evolutionary code optimization framework (operates at artifact level vs EvoSkill's skill level)
- [GEPA](https://arxiv.org/abs/2507.19457) — Reflective prompt evolution within DSPy
- [Feedback Descent](https://arxiv.org/abs/2511.07919) — The textual feedback optimization paradigm EvoSkill builds on
- [Voyager](https://arxiv.org/abs/2305.16291) — Earlier work on ever-growing skill libraries for LLM agents in Minecraft
- [OfficeQA](https://www.databricks.com/blog/introducing-officeqa-benchmark-end-to-end-grounded-reasoning) — Grounded reasoning benchmark over U.S. Treasury data
- [SealQA](https://arxiv.org/abs/2506.01062) — Search-augmented QA benchmark with noisy retrieval
- [BrowseComp](https://arxiv.org/abs/2504.12516) — Browsing agent benchmark used for zero-shot transfer evaluation

## Original Content

> [!quote]- Full Paper Text
> **EvoSkill: Automated Skill Discovery for Multi-Agent Systems**
>
> Salaheddin Alzubi, Noah Provenzano, Jaydon Bingham, Weiyuan Chen, Tu Vu
> Sentient / Virginia Tech
> https://github.com/sentient-agi/EvoSkill
>
> **Abstract**
>
> Coding agents are increasingly used as general-purpose problem solvers, but their flexibility does not by itself confer the domain expertise needed for specialized tasks. Recent work addresses this through agent skills: reusable workflows, and code, that augment agents with domain-specific capabilities. Most skills today are hand-crafted, and existing evolutionary approaches optimize low-level artifacts (e.g. prompts & code) that are tightly coupled to specific models and tasks. We introduce EvoSkill, a self-evolving framework that automatically discovers and refines agent skills through iterative failure analysis. EvoSkill analyzes execution failures, proposes new skills or edits to existing ones, and materializes them into structured, reusable skill folders. A Pareto frontier of agent programs governs selection, retaining only skills that improve held-out validation performance while the underlying model remains frozen. We evaluate EvoSkill on two benchmarks: OfficeQA, a grounded reasoning benchmark over U.S. Treasury data, where it improves exact-match accuracy by 7.3% (60.6% → 67.9%); and SealQA, a search-augmented QA benchmark with noisy retrieval, where it yields a 12.1% gain (26.6% → 38.7%). We also investigate the zero-shot transfer capabilities of skills evolved on one task to the other; in particular: skills evolved from SealQA transfers zero-shot to BrowseComp, improving accuracy by 5.3% without modification demonstrating that skill-level optimization produces transferable capabilities beyond the training task.
>
> **1 Introduction**
>
> Coding agents (e.g., Claude Code, OpenHands, Codex) have emerged as a dominant paradigm for solving tasks across a wide range of domains. This trend is driven by the increasing use of code as a flexible intermediate representation, enabling coding agents to invoke complex abstractions and operate as general-purpose problem solvers. However, while this flexibility allows agents to interface with diverse tools and domains, it does not by itself confer the domain expertise required to perform specialized tasks at a consistently high level.
>
> To bridge this gap, recent work has explored agent skills: reusable, domain-specific capabilities that augment general-purpose coding agents with structured workflows, instructions, and supporting code. Most skills today are hand-crafted on an ad-hoc basis, requiring both domain knowledge and significant manual effort; a process that scales poorly as the number of target tasks grows. Evolutionary methods such as AlphaEvolve, and GEPA, offer a promising alternative by optimizing agent artifacts: codebases, or prompts, through iterative search. However, these approaches operate at the artifact level: the optimized prompts or code are tightly coupled to a specific model and task configuration, and do not naturally yield reusable components that transfer across settings.
>
> In this work, we introduce EvoSkill, a self-evolving framework that operates at a higher level of abstraction: rather than optimizing prompts or code directly, EvoSkill iteratively discovers and refines agent skills through failure-driven textual feedback. EvoSkill maintains a Pareto frontier of agent programs and, at each iteration, analyzes execution failures to propose new skills or refine existing ones. Proposed skills are materialized into structured, reusable skill folders comprising instructions, trigger metadata, and helper scripts, and are retained only if they improve performance on a held-out validation set. Skills accumulate across iterations, progressively expanding the agent's capabilities while the underlying model remains frozen.
>
> We validate EvoSkill across two benchmarks. On OfficeQA, a grounded reasoning benchmark over U.S. Treasury data, EvoSkill improves Claude Code with Opus 4.5 from 60.6% to 67.9% exact-match accuracy (+7.3%) using only a small training subset. On SealQA, a search-augmented QA benchmark with noisy retrieval, EvoSkill yields a 12.1% improvement (26.6% → 38.7%). Furthermore, a skill evolved on SealQA transfers zero-shot to BrowseComp with no modifications, improving accuracy by 5.3% providing direct evidence that skills discovered by EvoSkill generalize beyond their training task.
>
> Our contributions are as follows:
>
> 1. We propose EvoSkill, a framework for automatically discovering and refining reusable agent skills through iterative failure analysis, operating at the skill abstraction level rather than on low-level artifacts such as prompts or codebases.
> 2. We demonstrate that EvoSkill yields substantial improvements across two distinct benchmarks: +7.3% on OfficeQA (grounded document reasoning) and +12.1% on SealQA (search-augmented QA), using only small training subsets.
> 3. We show that skills evolved by EvoSkill transfer zero-shot to unseen tasks, with a skill discovered on SealQA improving BrowseComp accuracy by 5.3% without modification; demonstrating that skill-level optimization produces transferable capabilities.
>
> **2 Methodology**
>
> The core idea behind EvoSkill is to iteratively discover and refine agent skills by applying textual feedback descent to examples where the current agent fails. EvoSkill assumes a coding agent harness that supports skill folders (e.g., Claude Code, Codex, OpenCode) and a model capable of utilizing such skills. The underlying model remains frozen throughout; only the skill repository and agent metadata evolve across iterations.
>
> **2.1 Framework Overview**
>
> EvoSkill consists of three collaborating agents:
>
> 1. **Executor Agent (A):** Executes tasks under the governance of the current agent program. The base program initializes the Executor with no skills.
> 2. **Proposer Agent (P):** Analyzes the Executor's output traces, predicted answers, and ground-truth answers to diagnose failures and propose high-level skill descriptions. Ground-truth answers are provided to enable root-cause diagnosis, analogous to examining labeled misclassifications during error analysis in supervised learning, and are not propagated to the generated skills themselves. The Proposer determines whether to create a new skill or refine an existing one.
> 3. **Skill-Builder Agent (S):** Materializes a high-level proposal from the Proposer into a concrete skill folder comprising trigger metadata, procedural instructions (SKILL.md), and optional helper scripts (Python or Typescript code) or reference material. The Skill-Builder is bootstrapped with a meta-skill that codifies best practices for skill authoring.
>
> All agents have read access to the base agent's repository; only the Skill-Builder has write permissions to the skills directory. The Proposer additionally maintains a cumulative feedback history H that logs all prior proposals, their outcomes, and score deltas. This serves two purposes: it prevents redundant proposals, and it enables the Proposer to refine what previously partially worked and avoid making the same mistakes making its context progressively richer across iterations.
>
> **2.2 EvoSkill Loop**
>
> EvoSkill optimizes agent programs through iterative skill mutations guided by textual feedback (Algorithm 1). A program p encapsulates the agent's system prompt and accumulated skills. The loop maintains a fixed-capacity frontier G of the k highest-scoring programs.
>
> At each iteration t, a parent program p is selected from the frontier G via round-robin cycling, ensuring each frontier member is explored before any is revisited. The parent is evaluated on a training batch sampled without replacement, cycling through all examples before repeating. Responses are scored against ground-truth answers using a task-specific scoring function. Samples scoring below a fixed threshold are collected into a failure set F; if no failures are found, the iteration is skipped.
>
> The Proposer P receives F together with the feedback history H and performs structured failure analysis: reviewing execution traces, identifying capability gaps, and auditing existing skills. It then produces a textual proposal π specifying either a new skill or an edit to an existing one.
>
> The Skill-Builder S receives the current parent program p and proposal π, and materializes the proposal into a candidate program p̃: the parent's configuration augmented with the new or revised skill. The candidate is evaluated on the held-out validation set V using the same scoring function.
>
> The candidate enters the frontier G if its score exceeds that of the weakest frontier member, displacing it; otherwise the candidate is discarded. Regardless of outcome, the proposal, its score, and the selection verdict are appended to H, ensuring the Proposer can reference which strategies succeeded or regressed and why. After T iterations, the loop returns the highest-scoring program in G.
>
> **2.3 Implementation Details**
>
> **2.3.1 Data Setup**
>
> Given a supervised dataset D = {(xi, yi)}^N_{i=1} and a scoring function, we first cluster the dataset into K categories using an LLM as a classifier, assigning each example to a single category. We then perform stratified partitioning into three disjoint subsets: a training set used for failure detection during evolution, a validation set used for scoring candidate programs (frontier selection), and a held-out test set comprising all remaining examples, which is never exposed during evolution and is used exclusively for final evaluation. Split ratios are configurable, with defaults ensuring every category is represented in both the training and validation partitions regardless of category size. Training data are organized as category-keyed pools to support the category-aware sampling used during evolution.
>
> **2.3.2 Environment Setup**
>
> EvoSkill operates within a git repository where the codebase is fixed. Each agent program is represented as a branch that diverges from its parent only in its skill folders and metadata (system prompt, lineage information, validation score). This design ensures that performance differences between programs are attributable solely to their evolved skills, while keeping program branches lightweight.
>
> **3 Experiments**
>
> We evaluate EvoSkill along three axes: (1) whether iterative skill evolution improves agent performance on challenging benchmarks, (2) what properties of the training setup influence skill quality, and (3) whether evolved skills transfer zero-shot to unseen tasks. We additionally present qualitative examples of discovered skills to illustrate the nature of the capabilities EvoSkill produces.
>
> **3.1 OfficeQA**
>
> **3.1.1 Benchmark**
>
> OfficeQA is a grounded reasoning benchmark built from U.S. Treasury Bulletins — a corpus of approximately 89,000 pages spanning five decades of monthly and quarterly publications. Each bulletin is 100-200 pages of prose, complex tables, charts, and figures describing Treasury operations. The benchmark consists of 246 questions organized into easy and hard difficulty levels. Questions require locating and synthesizing information across an average of two bulletin documents, navigating dense tabular data, and performing basic quantitative reasoning. Human solvers average 50 minutes per question, with the majority of time spent locating relevant information across tables and figures within the corpus.
>
> **3.1.2 Setup**
>
> All experiments use Claude Code with Opus 4.5 as the underlying model. Following the data setup described in Section 2.3.1, we partition the benchmark into three disjoint splits: a training set used for failure detection during evolution, a validation set of 17 examples (≈7%) used for frontier selection, and a held-out test set comprising the remaining questions, which is never exposed during evolution. We evaluate three training set sizes: 5% (12 examples), 10% (24 examples), and 15% (36 examples); each evolved for 1.5 epochs. We additionally evaluate a skill-merge configuration, which combines unique skills discovered across independent runs into a single skill library; when skills overlap (identified by matching names or descriptions), we retain the version from the highest-performing run. All reported accuracies are computed on the held-out test partition unless otherwise noted.
>
> **3.1.3 Results**
>
> EvoSkill yields consistent improvements over the baseline across all settings. On exact match (0% tolerance), training on 5% of the data improves accuracy from 60.6% to 63.4% (+2.8%), while 10% training data yields 65.8% (+5.2%). Performance plateaus beyond 10%: the 15% split achieves 64.5%, slightly below the 10% run, suggesting diminishing returns or mild overfitting as training data grows.
>
> The skill-merge configuration achieves the strongest result at 67.9% exact match (+7.3% over baseline), outperforming every individual run. This indicates that skills discovered from independent runs are complementary: each run surfaces different failure modes and corresponding capabilities, and combining them produces a more complete skill library. The improvement pattern is consistent across tolerance levels, with gains ranging from 2.7-4.5% at stricter tolerances.
>
> **3.1.4 Qualitative Analysis of Discovered Skills**
>
> **Data Extraction Verification.** EvoSkill discovered a skill enforcing a rigorous protocol for extracting numerical data from Treasury Bulletin tables. The skill is triggered whenever the agent extracts any value from parsed tables, and addresses concrete failure modes identified during evolution: adjacent cell misreads, wrong metric selection, and incorrect time granularity. This skill emerged directly from the Proposer's analysis of cases where the agent retrieved values from neighboring cells or confused similar-sounding metrics.
>
> **Quantitative Analysis Methodology.** A second skill provides structured methodology guidance for quantitative financial analysis, including risk calculations, forecasting, currency conversion, and statistical inference. The skill enforces mandatory validation checkpoints before computation, preventing systematic errors from wrong data transformations, date misalignment, or confusion between sample and population statistics.
>
> These examples illustrate that EvoSkill discovers interpretable, domain-relevant skills that target specific failure modes rather than producing opaque optimizations.
>
> **3.2 SealQA**
>
> **3.2.1 Benchmark**
>
> SealQA is a challenge benchmark for evaluating search-augmented language models on fact-seeking questions where web search yields conflicting, noisy, or unhelpful results. Unlike OfficeQA, which tests grounded reasoning over a fixed document corpus, SealQA evaluates an agent's ability to navigate the open web under adversarial retrieval conditions. This makes it a complementary testbed for EvoSkill: the skills required are fundamentally different, centering on search strategy and source verification rather than document parsing and numerical extraction.
>
> **3.2.2 Setup**
>
> We run EvoSkill on the seal-0 split of SealQA (111 questions) using Claude Code with Opus 4.5 and a 10% training split, following the partition methodology described in Section 2.3.1. The remaining questions not used for training or frontier selection form the held-out test set. Evolution is run for 1.5 epochs.
>
> **3.2.3 Results**
>
> EvoSkill improves accuracy on SealQA from 26.6% to 38.7%, an absolute gain of 12.1%. Among the skills discovered, EvoSkill produced a search-persistence-protocol that enforces exhaustive search strategies before the agent commits to an answer. The skill requires term interpretation expansion, multi-source verification, and completeness checks, directly addressing the benchmark's core challenge of premature search termination when initial results are noisy or misleading. This result demonstrates that EvoSkill generalizes beyond document-grounded reasoning to search-intensive tasks, discovering qualitatively different skills suited to the target domain.
>
> **3.3 Zero-Shot Skill Transfer**
>
> A key design goal of EvoSkill is that evolved skills, being structured and interpretable, should transfer across tasks without modification. We test this by taking the search-persistence-protocol skill evolved on SealQA and applying it zero-shot (with no edits) to BrowseComp: a benchmark for evaluating browsing agents on challenging fact-seeking questions with short, uniquely correct answers. We evaluate on a stratified sample of 128 examples.
>
> Despite being evolved on a different benchmark with different questions and difficulty characteristics, the transferred skill improves accuracy from 43.5% to 48.8%, an absolute gain of 5.3%. This provides direct evidence that skills discovered by EvoSkill are not overfit to their training task: the search-persistence-protocol captures a general capability — exhaustive search before committing to an answer — that is broadly useful for fact-seeking tasks regardless of the specific benchmark. This result supports the hypothesis that optimizing at the skill level, rather than at the level of prompts or code, yields more transferable improvements.
>
> **4 Related Work**
>
> **4.1 Agent Skills**
>
> The idea of augmenting agents with reusable, modular capabilities has roots in both embodied AI and software engineering. Voyager introduced an ever-growing skill library of executable code for an LLM-powered Minecraft agent, where skills are stored as programs in a vector database and retrieved by semantic similarity. Skills in Voyager are discovered through an automatic curriculum and iterative prompting with environment feedback, enabling lifelong learning without parameter updates. More recently, the Agent Skills specification has formalized skills as a portable, open format: each skill is a filesystem directory containing a SKILL.md file with metadata and procedural instructions, optionally bundled with helper scripts and reference materials. This format has been adopted across multiple agent harnesses including Claude Code, the Claude API, and third-party tools. Skills in this paradigm leverage progressive disclosure: metadata is loaded at startup, instructions are read on demand, and scripts are executed without entering the context window enabling agents to maintain many skills with minimal context overhead. Despite the maturity of skill infrastructure, skills today are predominantly hand-authored. EvoSkill addresses this gap by automatically discovering and refining skills through iterative failure analysis, producing artifacts that conform to the same structured skill format.
>
> **4.2 Textual Feedback and Evolutionary Optimization**
>
> A growing body of work explores using natural-language feedback, rather than scalar rewards, to guide iterative improvement of LLM-generated artifacts. Self-Refine demonstrated that a single LLM can improve its own outputs through a generate-critique-refine loop, achieving consistent gains across diverse tasks without additional training. However, Self-Refine operates on individual outputs and does not accumulate knowledge across iterations.
>
> Feedback Descent formalizes this intuition into a general optimization framework, showing that rich textual feedback from evaluators can drive sustained improvement across domains including molecular design, SVG optimization, and prompt engineering. Feedback Descent maintains a frontier of top-performing candidates and accumulates feedback history, enabling an editor LLM to make increasingly informed revisions. EvoSkill builds directly on this paradigm, applying textual feedback descent to the problem of skill discovery rather than artifact optimization.
>
> On the evolutionary side, AlphaEvolve uses an ensemble of LLMs to evolve entire codebases through an evolutionary loop grounded by automatic evaluation, achieving breakthroughs in algorithm discovery and infrastructure optimization at Google. GEPA takes a similar evolutionary approach to prompt optimization within the DSPy framework, using reflective mutation and Pareto-based candidate selection to evolve textual components of complex systems. Both approaches demonstrate the power of evolutionary search with LLM-driven mutations, but they optimize low-level artifacts (code or prompts) that are tightly coupled to specific tasks and models.
>
> EvoSkill differs from these approaches in its level of abstraction. Rather than evolving code or prompts directly, EvoSkill evolves skills: structured, reusable capability modules that persist across tasks. This distinction has practical consequences: evolved skills are interpretable, composable, and as we demonstrate transferable to new tasks without modification.
>
> **4.3 Transfer Learning in LLM Agents**
>
> Transfer learning has been extensively studied in the context of neural network fine-tuning, but its application to LLM-based agents remains nascent. In embodied settings, Voyager showed that a skill library learned in one Minecraft world could be applied to solve novel tasks in a new world, providing early evidence that code-based skills can transfer across environments. More broadly, work on prompt transfer has explored whether optimized prompts generalize across tasks or models, with mixed results — prompts optimized for one setting often degrade when the model or task distribution shifts.
>
> EvoSkill offers a different angle on transfer: because skills are structured as self-contained folders with explicit trigger conditions and procedural instructions, they are decoupled from both the training task and the underlying model. Our experiments provide direct evidence of this: a search-persistence skill evolved on SealQA transfers zero-shot to BrowseComp, yielding a 5.3 percentage point improvement without any modification. This suggests that skill-level optimization may offer a more natural unit of transfer than prompt-level or code-level optimization, though broader investigation across more diverse task pairs is needed.
>
> **5 Conclusion**
>
> We presented EvoSkill, a self-evolving framework that automatically discovers and refines reusable agent skills through iterative failure analysis. By operating at the skill level rather than optimizing low-level artifacts such as prompts or codebases, EvoSkill produces structured, interpretable capabilities that accumulate over iterations and transfer across tasks. Our experiments demonstrate consistent improvements on two distinct benchmarks: OfficeQA (+7.3%) and SealQA (+12.1%) using only small training subsets, and we provide direct evidence of zero-shot skill transfer from SealQA to BrowseComp (+5.3%).
>
> Several directions remain for future work. First, we aim to evaluate EvoSkill across a broader range of domains to better understand the generality of evolved skills and to characterize which skills emerge as domain-general (e.g., search persistence, verification protocols) versus domain-specific (e.g., treasury table extraction). Second, extending EvoSkill to multi-modal tasks where skills may need to coordinate across vision, code, and language presents a natural next step as coding agents increasingly operate over heterogeneous inputs. Third, the modular structure of evolved skills opens the possibility of building shared skill libraries, where skills discovered on one task can be browsed, composed, and reused by other agents and users. Finally, deeper investigation into the transferability of skills across tasks, models, and agent harnesses, will be critical for realizing the full potential of skill-level optimization as a paradigm for improving coding agents.
>
> **References**
>
> [1] Agent Skills. Agent skills specification, 2025. https://agentskills.io/specification
> [2] Agrawal et al. GEPA: Reflective prompt evolution can outperform reinforcement learning, 2026. https://arxiv.org/abs/2507.19457
> [3] Alzu'bi et al. Roma: Recursive open meta-agent framework for long-horizon multi-agent systems, 2026. https://arxiv.org/abs/2602.01848
> [4] Anthropic. Anthropic skills documentation, 2025. https://platform.claude.com/docs/en/agents-and-tools/agent-skills/overview
> [5] Anthropic. Claude code overview, 2026. https://code.claude.com/docs/en/overview
> [6] Lee, Boen, and Finn. Feedback descent: Open-ended text optimization via pairwise comparison, 2025. https://arxiv.org/abs/2511.07919
> [7] Madaan et al. Self-refine: Iterative refinement with self-feedback, 2023. https://arxiv.org/abs/2303.17651
> [8] Novikov et al. AlphaEvolve: A coding agent for scientific and algorithmic discovery, 2025. https://arxiv.org/abs/2506.13131
> [9] OpenAI. Codex, 2026. https://openai.com/codex/
> [10] Pham et al. SealQA: Raising the bar for reasoning in search-augmented language models, 2025. https://arxiv.org/abs/2506.01062
> [11] The Mosaic Research Team. Introducing OfficeQA: A benchmark for end-to-end grounded reasoning, December 2025. https://www.databricks.com/blog/introducing-officeqa-benchmark-end-to-end-grounded-reasoning
> [12] Vu et al. Foundational autoraters: Taming large language models for better automatic evaluation, 2024. https://arxiv.org/abs/2407.10817
> [13] Wang et al. Voyager: An open-ended embodied agent with large language models, 2023. https://arxiv.org/abs/2305.16291
> [14] Wang et al. OpenHands: An open platform for AI software developers as generalist agents, 2025. https://arxiv.org/abs/2407.16741
> [15] Wei et al. BrowseComp: A simple yet challenging benchmark for browsing agents, 2025. https://arxiv.org/abs/2504.12516
>
> **Appendix A: EvoSkill Generated Skills**
>
> The following section shows some of the skills generated using EvoSkill on different agentic tasks.
>
> A.1 OfficeQA Skills: The economic-timeseries-skill is a complex skill that contains both a SKILL.md file and relevant Python scripts to be called with it. (Full skill code shown as figures in the original paper.)
>
> A.2 SealQA: The search-persistence-protocol skill contains comprehensive instructions for web-search for conclusive answers where conflicting sources may exist. SealQA is considered a challenging benchmark for many multi-agent systems. (Full skill shown as figures in the original paper.)
>
> **Appendix B: Agent Prompts**
>
> This appendix provides the prompts used for each agent role (placeholders shown). Includes the Proposer prompt, Skill-Builder prompt, and Auto-Grader prompt (using the default LLM-as-a-judge template provided in the original SealQA task for all auto-grading tasks). (Full prompts shown as figures in the original paper.)
>
> **Appendix C: Scoring and Data Setup**
>
> Agent responses are evaluated using a deterministic fuzzy matching scorer that returns a binary correctness signal (1.0 or 0.0). Given a ground-truth answer g and a predicted answer p, the scorer first attempts to extract numerical values from both strings along with surrounding textual context (a 20-character window). When both g and p contain numeric content, the scorer normalizes each extracted number by detecting unit keywords in the local context (e.g., "million," "billion," "trillion") and compares base values using a relative tolerance τ: a prediction is accepted if |g_base − p_base| / |g_base| ≤ τ. For the primary evaluation τ = 0, requiring exact numerical agreement. To avoid spurious matches against incidental year references (e.g., "reported in 2023"), the scorer filters candidate numbers in the 1900-2100 range from predictions unless the ground truth itself is a year or contains significant non-numeric text. For hybrid answers containing both text and numbers (e.g., "March 1977"), the scorer additionally verifies that key textual elements present in the ground truth appear in the prediction via case-insensitive substring matching after stripping unit words and parenthetical abbreviations. Multi-number ground-truth answers (i.e., lists) require that all constituent values are recovered in the prediction. For purely textual answers, matching is performed via case-insensitive substring containment after normalization (whitespace trimming, quote removal, and parenthetical stripping). During the self-improvement training loop, a multi-tolerance scoring variant computes a weighted average over five tolerance levels τ ∈ {0.0, 0.01, 0.025, 0.05, 0.10}, with weights w(τ) = 1/(1 + 20τ) that favor stricter thresholds; a weighted score below 0.8 flags the example as a failure for targeted skill refinement.
>
> **Appendix D: Environment Branches**
>
> Agent configurations (programs) are managed using a git-backed version control scheme that naturally encodes parent-child lineage and supports efficient frontier-based selection. Each program is stored on a dedicated git branch (prefixed program/) with a YAML configuration file (.claude/program.yaml) that records the program's name, a pointer to its parent branch, a generation counter (mutation depth from root), the agent's system prompt, allowed tools, and evaluation metadata including scores. At initialization, a base program is created at generation 0 with no parent. At each iteration, the system selects the highest-scoring program from a maintained frontier — a bounded set of top-performing programs tracked via git tags (prefixed frontier/) — and designates it as the parent. The parent's configuration is then mutated by invoking a proposer agent that analyzes sampled failures, producing a child program that inherits all parent attributes while introducing a targeted modification: either a new or edited skill file (in skill-only mode) or a rewritten system prompt (in prompt-only mode). The child is instantiated by checking out the parent branch, creating a new branch named iter-mode-n, writing the mutated configuration, and committing all changes. After evaluation on a held-out validation set, the child is admitted to the frontier if either the frontier has not reached maximum capacity K (default K=3) or its score exceeds that of the current worst frontier member, in which case the weakest member is evicted. Children that fail to enter the frontier are discarded — their branches are deleted to prevent repository bloat. This design yields a tree-structured search over program space where each node is a fully reproducible snapshot. An early-stopping criterion halts the loop after a configurable number of consecutive iterations without frontier improvement.
>
> [Original paper](https://arxiv.org/abs/2603.02766)
