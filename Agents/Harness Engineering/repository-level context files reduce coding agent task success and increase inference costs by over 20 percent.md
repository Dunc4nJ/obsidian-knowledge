---
created: 2026-03-14
description: ETH Zurich's AGENTbench evaluation shows that AGENTS.md and CLAUDE.md context files tend to reduce coding agent task resolution rates while increasing inference costs by over 20 percent, with LLM-generated files performing worse than human-written ones.
source: https://arxiv.org/abs/2602.11988
type: paper
authors:
  - Thibaud Gloaguen
  - Niels Mündler
  - Mark Niklas Müller
  - Martin Vechev
arxiv: "2602.11988"
---

## Abstract

A widespread practice in software development is to tailor coding agents to repositories using context files, such as AGENTS.md, by either manually or automatically generating them. Although this practice is strongly encouraged by agent developers, there is currently no rigorous investigation into whether such context files are actually effective for real-world tasks. In this work, the authors study this question and evaluate coding agents' task completion performance in two complementary settings: established SWE-bench tasks from popular repositories with LLM-generated context files following agent-developer recommendations, and a novel collection of issues from repositories containing developer-committed context files. Across multiple coding agents and LLMs, context files tend to reduce task success rates compared to providing no repository context, while also increasing inference cost by over 20%. Behaviorally, both LLM-generated and developer-provided context files encourage broader exploration, and coding agents tend to respect their instructions. Ultimately, unnecessary requirements from context files make tasks harder, and human-written context files should describe only minimal requirements.

## Key Takeaways

The central finding is deeply counterintuitive: despite industry consensus encouraging AGENTS.md and CLAUDE.md files, rigorously evaluated across Claude Code with Sonnet-4.5, Codex with GPT-5.2/5.1-mini, and Qwen Code with Qwen3-30b-coder, LLM-generated context files reduced resolution rates by 0.5-2% on average while increasing inference costs by 20-23%. This directly challenges the [[context files beat MCP schemas for internal agents because they encode how your team actually uses each tool|prevailing assumption that context files improve agent performance]], and suggests the mechanism is more nuanced than "more context = better results."

The paper introduces AGENTbench, a new benchmark of 138 instances across 12 niche repositories that actually contain developer-committed context files. This fills a gap that SWE-bench Lite cannot address since its 11 popular repositories predate the context file convention. The benchmark construction itself is notable — they use LLM agents to generate standardized task descriptions and unit tests from PRs, achieving 75% average code coverage. This relates to broader work on [[harness engineering improved a coding agent 13 points by changing only system prompts tools and middleware|harness engineering]] where the evaluation infrastructure matters as much as the agent itself.

The trace analysis reveals why context files hurt: they cause agents to explore more broadly (more grep, more file reads, more test runs) and use more reasoning tokens (22% increase for GPT-5.2). Agents faithfully follow instructions in context files — uv usage jumps from near-zero to 1.6 calls per instance when mentioned — but this compliance adds overhead without improving outcomes. The extra instructions effectively make the task harder by adding unnecessary requirements. This connects to [[CLAUDE.md is the highest-leverage harness config but hits a 150-200 instruction ceiling before compliance decays linearly|findings about instruction compliance ceilings in context files]].

A crucial nuance: when all documentation is removed from repositories (no .md files, no docs/ folder, no examples), LLM-generated context files consistently improve performance by 2.7% and even outperform developer-written files. This suggests context files are most valuable for under-documented codebases — which may explain anecdotal success reports from developers working on smaller projects. The implication for [[the-harness-is-the-product-because-model-capability-is-commoditizing-while-accumulated-context-is-not|harness engineering as competitive moat]] is that context should be dynamic and minimal, not comprehensive and static.

Developer-written context files marginally outperform the no-context baseline (+4% on AGENTbench) for all agents except Claude Code, while LLM-generated ones underperform it. Stronger models do not generate better context files — GPT-5.2-generated files improved SWE-bench Lite scores but degraded AGENTbench scores. Prompt choice (Codex vs Claude Code prompt) also had no consistent effect. The paper's recommendation is clear: omit LLM-generated context files entirely, and keep human-written ones minimal — describing only essential requirements like specific tooling constraints.

Context files fail as repository overviews. Despite 100% of Sonnet-4.5-generated files and 99% of GPT-5.2-generated files containing codebase overviews, agents with context files did not reach relevant files faster. This aligns with [[coding agents are bottlenecked by search not coding ability|research showing that coding agents are bottlenecked by search]], and suggests that static overviews are redundant with what agents can discover dynamically through [[Dynamic context discovery beats static context injection for coding agents|dynamic context discovery patterns]].

## External Resources

- [AGENTbench GitHub repo](https://github.com/eth-sri/agentbench) — Code to generate AGENTbench instances and evaluate coding agents
- [AGENTS.md specification](https://agents.md/) — The open format for guiding coding agents that this paper evaluates
- [SWE-bench](https://www.swebench.com/) — The established benchmark used alongside AGENTbench in this evaluation

## Original Content

> [!quote]- Full Paper Text
> **Evaluating AGENTS.md: Are Repository-Level Context Files Helpful for Coding Agents?**
> Thibaud Gloaguen, Niels Mündler, Mark Niklas Müller, Martin Vechev
> ETH Zurich — Machine Learning, ICML
>
> **Abstract**
>
> A widespread practice in software development is to tailor coding agents to repositories using context files, such as AGENTS.md, by either manually or automatically generating them. Although this practice is strongly encouraged by agent developers, there is currently no rigorous investigation into whether such context files are actually effective for real-world tasks. In this work, we study this question and evaluate coding agents' task completion performance in two complementary settings: established SWE-bench tasks from popular repositories, with LLM-generated context files following agent-developer recommendations, and a novel collection of issues from repositories containing developer-committed context files.
>
> Across multiple coding agents and LLMs, we find that context files tend to reduce task success rates compared to providing no repository context, while also increasing inference cost by over 20%. Behaviorally, both LLM-generated and developer-provided context files encourage broader exploration (e.g., more thorough testing and file traversal), and coding agents tend to respect their instructions. Ultimately, we conclude that unnecessary requirements from context files make tasks harder, and human-written context files should describe only minimal requirements.
>
> **1 Introduction**
>
> Coding agents are being rapidly adopted across the software engineering industry (Sarkar, 2025), and providing context files like AGENTS.md, a README specifically targeting agents, has become common practice. With various industry leaders (AGENTS.md, 2025; Anthropic, 2025b) recommending this approach to adapt their agents to specific repositories, context files are now supported by most popular agent frameworks, and included in over 60,000 open-source repositories at the time of writing, as reported by AGENTS.md (2025).
>
> These context files typically contain a repository overview and information on relevant developer tooling, aiming to help coding agents to navigate a given repository more efficiently, run build and test commands correctly, adhere to style guides and design patterns, and ultimately to solve tasks to the user's satisfaction more frequently. To date, despite their widespread adoption, the impact of context files on the coding agent's ability to solve complex software engineering tasks has not been rigorously studied. This is due to two key challenges: i) because of their recent introduction, context files are not available for instances of prior benchmarks, and ii) popular, well-known repositories, typically used to create such benchmarks, are not representative of most codebases. As a result, a rigorous evaluation of the context files used in practice requires a new, complementary benchmark that contains only issues from less popular repositories with developer-committed context files.
>
> *Figure 1: Overview of the evaluation pipeline. Beginning with real-world repositories and tasks derived from past pull requests. For each repository state, three settings are generated: (1) If a developer-provided context file exists, it is included. (2) The context file is omitted. (3) The coding agent's recommended settings are used to generate the context file. The repository and context file are passed to the coding agent to autonomously resolve the task. Traces are analyzed for behavioral changes and the generated patch is applied to check for task resolution success.*
>
> **This work: Benchmarking context files' impact on resolving GitHub issues**
>
> In this work, we investigate the effect of actively used context files on the resolution of real-world coding tasks. We evaluate agents both in popular and less-known repositories, and, importantly, with context files provided by repository developers. For this purpose, we construct a novel benchmark (Figure 1, left), AGENTbench, comprising Python software engineering tasks, created specifically from real GitHub issues. The benchmark contains 138 unique instances, covering both bug-fixing and feature addition tasks across 12 recent and niche repositories, which all feature developer-written context files. AGENTbench complements SWE-bench Lite, which we leverage for the evaluation of automatically generated context files on popular repositories.
>
> We evaluate coding agents in three settings (Figure 1, middle): without any context file, with context files automatically generated using agent-developer recommendations, and with the developer-provided context file. Our code to generate AGENTbench instances and evaluate coding agents is available at https://github.com/eth-sri/agentbench.
>
> Surprisingly, we observe that developer-provided files only marginally improve performance compared to omitting them entirely (an increase of 4% on average), while LLM-generated context files have a small negative effect on agent performance (a decrease of 3% on average). These observations are robust across different LLMs and prompts used to generate the context files. In a more detailed analysis (Figure 1, right), we observe that context files lead to increased exploration, testing, and reasoning by coding agents, and, as a result, increase costs by over 20%. We therefore suggest omitting LLM-generated context files for the time being, contrary to agent developers' recommendations, and including only minimal requirements (e.g., specific tooling to use with this repository). We hope our evaluation framework will aid agent and model developers to improve the helpfulness of LLM-generated context files.
>
> **Key contributions**
>
> 1. AGENTbench, a new curated benchmark for the impact of actively used context files on agents' ability to solve real-world software engineering tasks.
> 2. An extensive evaluation of different coding agents and underlying models on AGENTbench and SWE-bench Lite, showing that LLM-generated context files tend to decrease agent performance, across models or prompts used to generate them, while developer-written context files tend to slightly improve it.
> 3. A detailed investigation of agent traces, showing that context files lead to more thorough testing and exploration by coding agents.
>
> **2 Background and Related Work**
>
> *Coding agents* — Coding agents are LLM-based systems designed for autonomous resolution of coding tasks (Yang et al., 2024). Typically, they consist of a harness that allows an LLM to interact with its environment using specialized tools for executing bash commands, conducting web searches, or reading, creating, or modifying files (Wang et al., 2025; Yang et al., 2024). Their impressive performance on repository-level coding tasks like SWE-bench (Jimenez et al., 2024) led to rapid adoption in the software engineering community (Sarkar, 2025) and the development of new agents by specialized companies (Aider, 2024; Wang et al., 2025) and model providers (OpenAI, 2025c; Google, 2025; QwenLM, 2025; Anthropic, 2025a). Model providers now train their LLMs to use the tools exposed by their harnesses (QwenLM, 2025), which can substantially improve coding ability relative to simpler harnesses (Lieret et al., 2025). Accordingly, in Section 4, each LLM is evaluated only within its corresponding harness.
>
> *Context files* — As coding agents were more broadly adopted, a common need arose to provide the agent with additional context about novel and little-known codebases (Boyina, 2025; Sewell, 2025). To address this issue, model and agent developers recommend including context files, such as AGENTS.md or CLAUDE.md, with codebases (OpenAI, 2025a; Anthropic, 2025b). Many agent harnesses provide built-in commands to initialize such context files automatically using the coding agent itself, e.g., by providing a dedicated /init command in the agent interface (OpenAI, 2025c; QwenLM, 2025; Anthropic, 2025a). At the time of writing, AGENTS.md (2025) report that over 60,000 public GitHub repositories include a context file.
>
> *Evaluating context files* — Prior work collected and categorized the content of context files (Chatlatanagulchai et al., 2025; Mohsenimofidi et al., 2025), deriving mostly descriptive metrics about their content without investigating their effectiveness (Nigh, 2025). While individual developers report anecdotal evidence of better alignment and solution capabilities when providing context files (Sewell, 2025; Sawers, 2025), this is the first work to investigate the impact of actively used context files on agent behavior and performance at scale.
>
> *Repository-level evaluation* — Spearheaded by Jimenez et al. (2024), evaluating coding agents on the autonomous resolution of real-world repository-level tasks quickly became the gold standard for assessing their capabilities. While initial work focuses on issue resolution, follow-up work proposed benchmarks on feature addition (Li et al., 2025; Du et al., 2025), unit test generation (Mündler et al., 2024), function generation (Liang et al., 2024), code performance (He et al., 2025), and security (Chen et al., 2025). Orthogonally, benchmarks have also been extended by mining more recent and more difficult problems (Badertdinov et al., 2025; Zhang et al., 2025a), as well as instances focusing on end-user applications (Vergopoulos et al., 2025).
>
> **3 AGENTbench**
>
> *3.1 Notation and Definitions*
>
> Following the notation of Mündler et al. (2024), a codebase or repository R after applying patch X is denoted R∘X. Several patches can be applied sequentially: R∘X∘Y. A test suite T is a collection of tests used to validate the functionality of code. Executing T on repository state R returns exec_R(T) ∈ {pass, fail}. An issue I is a task for autonomous completion by the coding agent. Quadruples (I, R, T, X*) are instances, where the coding agent predicts a patch X̂ given issue I and repository state R such that exec_{R∘X̂}(T) = pass, and X* is the golden patch. The success rate S is the percentage of predicted patches where all tests pass.
>
> *3.2 Generation of AGENTbench Instances*
>
> *Requirements* — The aim is to evaluate the impact of both automatically generated and developer-written context files on the success rate of coding agents. The primary source is open-source projects and their publicly tracked pull requests (PRs). Context files have only been formalized in August 2025, and adoption is not uniform.
>
> *Finding repositories* — GitHub search is used to build a list of candidate repositories containing a context file (AGENTS.md or CLAUDE.md) at the root directory, using Python as the main language, featuring a test suite, and with at least 400 PRs.
>
> *Filtering pull requests* — PRs are filtered to retain those referencing at least one issue and modifying at least one Python file. PRs are assessed by an LLM agent to introduce deterministic, testable behaviors. Unlike SWE-bench Lite, PRs are not required to edit unit tests, enabling inclusion of niche repositories.
>
> *Environment Set-Up* — For every PR, an execution environment is set up using a coding agent that produces a script to set up the environment, run the test suite, and store results. Only PRs where at least one test passes are kept (87% of filtered instances).
>
> *Task Descriptions* — A third LLM agent produces standardized task descriptions based on PR descriptions, associated issues, and original patches. Descriptions are divided into 6 sections: description, steps to reproduce, expected behavior, observed behavior, specification, and additional information. 10% were manually inspected for solution leakage — none found.
>
> *Generating Unit Tests* — An LLM agent generates unit tests from the task description, test files, original code changes, and base repository state. Tests are verified to fail on R and pass on R∘X*. Over-specified tests are manually improved. Final tests achieve average 75% coverage of modified code.
>
> *Overview of AGENTbench* — 138 instances from 5694 PRs across 12 repositories, using GPT-5.2 with Codex. The dataset is more evenly distributed over repositories than SWE-bench Lite.
>
> **Table 1: Key statistics of AGENTbench (138 instances)**
>
> | Metric | Mean | Min | Max |
> |---|---|---|---|
> | PR body words | 415.3 | 5 | 4961 |
> | Issue words | 211.6 | 96 | 500 |
> | Codebase files | 3337 | 151 | 26602 |
> | PR lines edited | 118.9 | 12 | 1973 |
> | PR files edited | 2.5 | 1 | 23 |
> | Test coverage | 75% | 2.5% | 100% |
> | Context file words | 641.0 | 24 | 2003 |
> | Context file sections | 9.7 | 1 | 29 |
>
> **4 Experimental Evaluation**
>
> *4.1 Experimental Setup*
>
> *Coding Agents* — Four coding agents: Claude Code with Sonnet-4.5, Codex with GPT-5.2 and GPT-5.1 mini, and Qwen Code with Qwen3-30b-coder. Claude Code and Codex use temperature 0. Qwen Code uses chat compression at 60% context limit (256K tokens), shell outputs restricted to 2000 tokens, temperature 0.7 with top-p 0.8, deployed locally via vLLM. Context files are written to AGENTS.md (Codex, Qwen Code) or CLAUDE.md (Claude Code).
>
> *Datasets* — SWE-bench Lite (300 tasks, 11 popular Python repos, no developer context files) and AGENTbench (138 instances, 12 repos with developer context files).
>
> *Settings* — Three settings: None (no context files), LLM (auto-generated using each agent's recommended initialization), Human (developer-provided, AGENTbench only).
>
> *Metrics* — Success rate, number of steps (environment interactions), and total inference cost.
>
> *4.2 Main Results*
>
> **Table 2: Steps and cost per instance**
>
> | | Sonnet-4.5 | | GPT-5.2 | | GPT-5.1 M. | | Qwen3-30B | |
> |---|---|---|---|---|---|---|---|---|
> | | Steps | Cost | Steps | Cost | Steps | Cost | Steps | Cost |
> | **SWE-bench Lite** | | | | | | | | |
> | None | 54.4 | $1.30 | 12.5 | $0.32 | 40.9 | $0.18 | 29.7 | $0.12 |
> | LLM | 57.2 | $1.51 | 12.7 | $0.43 | 45.2 | $0.22 | 32.2 | $0.13 |
> | **AGENTbench** | | | | | | | | |
> | None | 40.7 | $1.15 | 12.1 | $0.38 | 40.6 | $0.18 | 31.5 | $0.13 |
> | LLM | 46.5 | $1.33 | 13.1 | $0.57 | 46.9 | $0.20 | 34.2 | $0.15 |
> | Human | 45.3 | $1.30 | 13.6 | $0.54 | 46.6 | $0.19 | 32.8 | $0.15 |
>
> *LLM-generated context files increase cost and reduce performance* — LLM-generated context files cause performance drops in 5 out of 8 settings. Average resolution rate reduced by 0.5% and 2% on SWE-bench Lite and AGENTbench respectively. Steps increase by 2.45 and 3.92 on average, leading to cost increases of 20% and 23%.
>
> *Human context files increase cost and performance* — Developer-provided context files outperform LLM-generated ones for all four agents, and improve performance compared to no context for all agents but Claude Code. However, they also increase steps by 3.34 on average and costs by up to 19%.
>
> *Context files do not provide effective overviews* — 100% of Sonnet-4.5-generated and 99% of GPT-5.2-generated context files contain codebase overviews. Yet the number of steps before the agent first interacts with a PR-relevant file is not meaningfully reduced by context files. GPT-5.1 mini actually takes longer because it issues commands to find and re-read context files already in its context.
>
> *Context files are redundant documentation* — When all documentation is removed (files ending with .md, example code, docs/ folder), LLM-generated context files consistently improve performance by 2.7% on average and outperform developer-written documentation. This suggests context files are valuable primarily for under-documented codebases.
>
> *4.3 Trace analysis*
>
> *Context files lead to more testing and exploration* — Across all models, context files cause agents to run more tests, search more files (grep), read more files, write more files, and use more repository-specific tooling (e.g., uv and repo_tool).
>
> *Instructions in context files are typically followed* — uv is used 1.6 times per instance when mentioned in context files vs fewer than 0.01 when not mentioned. Repository-specific tools are used 2.5 times when mentioned vs fewer than 0.05 when not. The absence of improvements is not due to lack of instruction-following.
>
> *Following context files requires more thinking* — LLM-generated context files increase reasoning tokens by 22% for GPT-5.2 and 14% for GPT-5.1 mini on SWE-bench Lite (14% and 10% on AGENTbench). Developer-written files increase reasoning tokens by 20% and 2% for GPT-5.2 and GPT-5.1 mini respectively.
>
> *4.4 Ablations*
>
> *Stronger models don't generate better context files* — Context files generated with GPT-5.2 + Codex improve SWE-bench Lite performance (2% average) but degrade AGENTbench performance (3% average).
>
> *No difference between specific prompts* — Neither the Codex nor Claude Code prompt for generating context files performs consistently better across agents and benchmarks.
>
> **5 Limitations and Future Work**
>
> *Niche programming languages* — The evaluation focuses on Python, which is well-represented in training data. Context files may be more valuable for niche languages where models have less parametric knowledge.
>
> *Context files beyond task resolution* — Future work could evaluate impact on code efficiency and security. Prior work found that prompting LLMs for secure code significantly improves security.
>
> *Improving context file generation* — Human developers appear to dominate LLM-generated files. Planning and continuous learning from prior tasks may improve automatic generation.
>
> **6 Conclusion**
>
> All context files consistently increase the number of steps required to complete tasks. LLM-generated context files have a marginal negative effect on task success rates, while developer-written ones provide a marginal performance gain. Instructions are generally followed and lead to more testing and broader exploration, but do not function as effective repository overviews. Context files have only marginal effect on agent behavior and are likely only desirable when manually written. This highlights a concrete gap between current agent-developer recommendations and observed outcomes.
>
> [Source paper](https://arxiv.org/abs/2602.11988)
