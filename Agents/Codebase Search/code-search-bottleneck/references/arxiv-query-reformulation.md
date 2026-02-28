---
created: 2026-02-25
type: reference
description: "LLM-powered query reformulation improves file-level bug localization by 35% over BM25 baseline and 22% over SWE-agent through structured information extraction from bug reports."
source: "https://arxiv.org/html/2512.07022"
---
Title: Reformulate, Retrieve, Localize: Agents for Repository-Level Bug Localization

URL Source: https://arxiv.org/html/2512.07022

Markdown Content:
(2026)

###### Abstract.

Bug localization remains a critical yet time-consuming challenge in large-scale software repositories. Traditional information retrieval–based bug localization (IRBL) methods rely on unchanged bug descriptions, which often contain noisy information, leading to poor retrieval accuracy. Recent advances in large language models (LLMs) have improved bug localization through query reformulation, yet the effect on agent performance remains unexplored. In this study, we investigate how an LLM-powered agent can improve file-level bug localization via lightweight query reformulation and summarization. We first employ an open-source, non-fine-tuned LLM to extract key information from bug reports, such as identifiers and code snippets, and reformulate queries pre-retrieval. Our agent then orchestrates BM25 retrieval using these preprocessed queries, automating localization workflow at scale. Using the best-performing query reformulation technique, our agent achieves 35% better ranking in first-file retrieval than our BM25 baseline and up to +22% file retrieval performance over SWE-agent.

Software Engineering, Agents, Large Language Models, Bug Localization, Query Reformulation

††copyright: acmlicensed††journalyear: 2026††copyright: none††conference: 7th International Workshop on Bots and Agents in Software Engineering; April 13, 2026; Rio de Janeiro, Brazil
1. Introduction
---------------

As software systems grow in size and complexity, identifying the precise locations of bugs becomes increasingly challenging. Bug localization, the process of identifying the source of software defects, is a critical step in large repositories(improving_bug_localization; LongCodeArena). Automated bug localization can help ease the debugging process by focusing on the buggy areas, improving software quality and developer productivity(flexfl). Many automated approaches rely on information retrieval (IR) techniques that match keywords from bug reports with those in source code files(Zhou_Zhang_Lo_2012; Rahman_Roy_2018; Mahmud_2024). However, when the terminology used in the report differs from that in the code, retrieval accuracy drops: a problem known as the lexical gap(query_expansion_code_search).

Most existing works on information retrieval-based bug localization (IRBL) use unchanged bug descriptions to locate relevant files(Rahman_Roy_2018). Consequently, the quality of the information in a bug, such as the inclusion of observed behaviour, steps to reproduce, and expected behaviour, as well as localization “hints” such as code snippets or identifiers, is paramount in building effective automated retrieval methods(Mahmud_2024; search_queries_ir).

Prior work has explored query reformulation and summarization for bug localization. Query reformulation expands, reduces, or replaces query terms to emphasize relevant information(auto_summarization; Rahman_Roy_2018), while summarization produces concise bug reports that retain essential details(auto_summarization). LLMs have recently been used to improve retrieval focus in bug localization tasks by reformulating bug descriptions into more precise queries(Mahmud_2024; agents_code_search). While prior work has integrated lexical search tools into LLM-based agents for retrieval or search-space reduction (locagent),(Rafi_Kim_Chen_Wang_2025), the interaction between query reformulation and downstream agent performance remains under-explored. Existing research primarily evaluates each component in isolation, examining either the retrieval quality of reformulated queries or the reasoning ability of agents, without analyzing how reformulated inputs affect an agent’s ability to locate relevant files. Agent-based retrieval has been proposed to mitigate the issues of long context understanding and to enable large codebase traversal(locagent). LLM-based agents are used more and more for diverse software engineering (SE) tasks, such as bug localization, code generation and code review(swe-agent; agent-coder; agent-code-review). These agents coordinate retrieval and reasoning steps through tool use, providing a scalable alternative to end-to-end LLM reasoning.

In this study, we leverage agentic query reformulation and summarization for file-level bug localization. First, we prompt an LLM to extract the relevant information from a bug report, asking it to explain the bug (a summary), along with information extracted from the bug description: file paths and names, identifiers (classes, methods), code snippets, stack traces, and error messages. To retrieve relevant files using this reformulated bug description, a simple lexical search (BM25(bm25)) can narrow down the repository files to only the top-k k best candidates. The agent has access to the full bug description, the repository name, and tools to extract relevant information and preview file content. Each run begins with the bug report and a BM25 query built from the extracted fields, producing a ranked list of candidate files. The agent selects files to inspect and reasons about their relevance within a multi-step conversation. This setup allows us to measure how pre-retrieval (upstream) query reformulation affects both retrieval accuracy and post-retrieval (downstream) ranking quality in agent-based bug localization.

Unlike prompt engineering or query expansion, which adjust prompt text to guide generation, our method treats reformulation as an intermediate representation task—transforming noisy bug reports into structured, retrieval-ready summaries optimized for repository-scale search. We then assess how LLM-based reformulation improves BM25 retrieval and benefits agentic workflows. Specifically, we ask:

RQ1: How does query reformulation help in localizing files in a large repository? We prompt a smaller, open-sourced LLM to extract structured information from each bug description using a predefined JSON schema, and compare BM25 retrieval results against a baseline BM25 search using the full, unmodified bug description.

RQ2: How does upstream query reformulation improve localization accuracy for LLM-based agents? We use open-source, non-fine-tuned models-Qwen2.5-coder-32B (Qwen2.5-32B) and Qwen3-coder-30B (Qwen3-30B), and integrate BM25 as a tool for search-space reduction within an LLM-based agentic pipeline.

This work is the first to explore the effect of upstream query reformulation on agent-based bug localization. Specifically, we contribute:

*   •Evaluate the impact of query reformulation using information extraction by an LLM on two long-context datasets: Long Code Arena(LongCodeArena) and SWE-Bench Lite(swe-bench). We report improvements of up to 36% on MAP@1. 
*   •Design a lightweight agent workflow, including tools such as BM25 for space reduction and individual file viewing, to assess the retrieval ability of LLMs as agents against lightweight BM25 retrieval with query reformulation. 
*   •Evaluate the impact of upstream query reformulation and show improvements of up to 35% on first-file retrieval. Our agent achieves improvements of up to 22%. 
*   •Publish all artifacts in our replication package(replication). 

2. Related Work
---------------

Bug localization research has evolved from traditional information-retrieval (IR) techniques to modern, LLM-driven agentic systems. Early approaches focused on enhancing lexical and structural matching between bug reports and source code; subsequent work concentrated on automating query reformulation to improve retrieval accuracy. Most recently, LLM-based and multi-agent frameworks have extended these ideas to repository-level reasoning and scalable localization.

Retrieval-Based Bug Localization. Early studies on file-level bug localization focused on improving information retrieval techniques. Zhou et al. (BugLocator)(Zhou_Zhang_Lo_2012) study a revised Vector Space Model (rVSM), outperforming VSM(vsm), LDA(lda), LSI(lsi), and SUM(sum). Saha et al. (BLUiR)(improving_bug_localization) incorporates structured code information such as class and method names. Hybrid methods like DNNLOC(bug_loc_deep_learning) combine rVSM with deep neural networks, achieving 50% top-1 localization accuracy.

Query Reformulation. Kim et al.(Kim_Lee_2019) improved retrieval by automatically selecting and augmenting bug report terms, yielding +17% top-1 and +10% Mean Average Precision (MAP)@10 gains. Rahman et al.(Rahman_Roy_2018) proposed BLIZZARD, which classifies bug report quality and reformulates queries accordingly, improving Hit@10 by 56% and MAP@10 by 19%. Mahmud(Mahmud_2024) highlighted the lexical gap between reporters and developers, showing through ChatGPT-based extraction that LLM reformulation can bridge this gap.

Agent-Based Retrieval. Yang et al. introduced SWE-Agent(swe-agent), which integrates keyword-based search and file inspection tools to locate and edit relevant code segments, reaching an 18% resolution rate on SWE-bench Lite with GPT-4-Turbo. Xie et al.(xie-etal-2025-swe-fixer) developed SWE-Fixer, a lightweight approach comprising two modules: code retrieval (BM25-based) and code editing, using open-source fine-tuned models. They obtain competitive performance on SWE-bench Lite/Verified (22% and 30.2% task resolution, respectively). Chen et al. introduced LocAgent(locagent), which uses fine-tuned LLM agents and heterogeneous code graphs with BM25 indexing to locate buggy files, outperforming prior IR methods. Similarly, Rafi et al.(Rafi_Kim_Chen_Wang_2025) proposed LLM4FL, a multi-agent framework combining graph-based navigation and reasoning, achieving an 18.6% improvement over the baseline.

We use a lightweight, non-fine-tuned LLM-based agent to extract key information for lexical retrieval. We explicitly examine how reformulating bug descriptions upstream affects both lexical retrieval and the agent’s ability to identify relevant files.

3. Proposed Method
------------------

For RQ1, we select BM25(bm25), a lightweight lexical search tool that does not require prior training on our datasets and is widely used in other studies(swe-bench; locagent; LongCodeArena). We use the Pyserini toolkit with default BM25 settings to first index all code files in each repository(Lin_etal_SIGIR2021_Pyserini). As a baseline, we use bug descriptions as input for the BM25 search, without any modifications. Similar to previous works(Rahman_Roy_2018; kbl_query_reformulation; rafi_enhancing_fl), we select three top-k k values: {1,5,10}\{1,5,10\} to evaluate ranking quality (MAP) and the presence of at least one relevant file in the top-k k results (Hit@K).

Next, we integrate an LLM in the loop: from a bug description, we ask it to extract relevant information into a JSON schema. We select Qwen3-30B for this task, and set the temperature to 0 for stability. Our idea is to primarily use localization hints as strong signals(search_queries_ir) (variable and method identifiers, code snippets, stack traces, error messages), as they are more likely to match code files. Still, those hints may not always be available in bug reports. For this reason, we include an “explanation” as a summary of the bug, effectively eliminating any boilerplate characters included in bug report templates.

Schema definition. We design a JSON schema (Table[1](https://arxiv.org/html/2512.07022v1#S3.T1 "Table 1 ‣ 3. Proposed Method ‣ Reformulate, Retrieve, Localize: Agents for Repository-Level Bug Localization")) that contains essential information from a bug, such as Explanation (summary of the bug), Paths, Filenames, Identifiers (list of identifiers mentioned in the bug, such as class, method and variable names), Code snippet, Stack trace and Error message. We evaluate the impact of using only the extracted information by running a BM25 search on the combined fields of the JSON schema, removing the field names, commas and double quotes. We exemplify this process in Table[1](https://arxiv.org/html/2512.07022v1#S3.T1 "Table 1 ‣ 3. Proposed Method ‣ Reformulate, Retrieve, Localize: Agents for Repository-Level Bug Localization").

Ablation study. We examine how each component of the schema contributes to the accuracy of BM25 by forming the following groups: All schema information; Explanation field only; All code signals, including identifiers, code snippets, stack trace and error message; Only code identifiers and code snippets; Only explanation, identifiers and code snippets.  We create the groups based on these assumptions: for group[](https://arxiv.org/html/2512.07022v1#S3.I1.i2 "item 2 ‣ 3. Proposed Method ‣ Reformulate, Retrieve, Localize: Agents for Repository-Level Bug Localization"), we aim to test the inclusion of relevant code signals in the summary; for[](https://arxiv.org/html/2512.07022v1#S3.I1.i3 "item 3 ‣ 3. Proposed Method ‣ Reformulate, Retrieve, Localize: Agents for Repository-Level Bug Localization"), all fields that contain code-related signals are included; for[](https://arxiv.org/html/2512.07022v1#S3.I1.i4 "item 4 ‣ 3. Proposed Method ‣ Reformulate, Retrieve, Localize: Agents for Repository-Level Bug Localization") we exclude stack traces and error messages as they may consist of extra tokens not found in source files; for[](https://arxiv.org/html/2512.07022v1#S3.I1.i5 "item 5 ‣ 3. Proposed Method ‣ Reformulate, Retrieve, Localize: Agents for Repository-Level Bug Localization"): in addition to[](https://arxiv.org/html/2512.07022v1#S3.I1.i4 "item 4 ‣ 3. Proposed Method ‣ Reformulate, Retrieve, Localize: Agents for Repository-Level Bug Localization"), we include a summary of the bug to provide any extra signals that did not fit any of our categories. We assume that files and paths are primarily helpful for LLM-based evaluation, as they might give insights into which files to inspect. Thus, we do not include them in our groups for this experiment.

Statistical analysis. We apply Mann–Whitney U (Mann_Whitney_1947) and McNemar (McNemar1947) tests to assess significance(cliff_interpretation).

Table 1. Example of JSON fields extracted from a bug report.

For RQ2, we propose automating bug localization and query reformulation using a lightweight agent-based workflow. Existing frameworks require a particular format for tool calling, which our models do not uniformly support. Thus, we implement our own agentic loop with tool-calling capabilities.

![Image 1: Refer to caption](https://arxiv.org/html/2512.07022v1/figures/agent_flow.png)

Figure 1. Our Agentic Workflow. At every step, the outputs are validated, and the model is asked to correct invalid outputs.

Agentic Workflow. We design an agent that can effectively use available tools to extract the relevant context and localize suspicious files. This agent is guided through the localization process, as shown by our workflow in Figure[1](https://arxiv.org/html/2512.07022v1#S3.F1 "Figure 1 ‣ 3. Proposed Method ‣ Reformulate, Retrieve, Localize: Agents for Repository-Level Bug Localization"). It is divided into steps: (1)Extract relevant information from the bug; (2)Retrieve relevant files using BM25 search; (3)View individual files; (4)Final answer: a ranked list of n n candidate files in JSON format.  At step 3), the agent is also given the option to exit tool calling and provide its final answer as described in 4). Prompts are provided in our replication package(replication).

Tools. Our open-sourced models do not support out-of-the-box tool calling. Thus, we design simple functions and instruct the models to return a tool call with parameters in JSON format. We make the following tools available to our agent: (1)Extract relevant information from a bug description (extract_relevant), returning relevant information from the bug description; (2)Retrieve k k-best results with BM25, with options k={10,20,30}k=\{10,20,30\} (bm25_topk); (3)View a particular file given its path (view_file); (4)View the top-level readme file (view_readme).

Input. We initialize the prompt with the complete bug description and repository name, and instruct the model to retrieve the top-k k candidate files ranked by their likelihood of containing the fix (k={1,5,10}k=\{1,5,10\}). During the conversation, the agent has access to the full conversation context: complete bug description, extracted information, and history of tool calls with their results. To manage context size, file views are truncated to 512 tokens. In preliminary experiments, extending views to 1024 tokens yielded only marginal MAP improvements, so we adopt the shorter, more resource-efficient option.

Query reformulation. We design two experiments to assess the benefit of upstream query reformulation for LLMs.

For our first experiment, the bug description and extracted information always appear at the top of the conversation, and the BM25 query will include all fields; we name this experiment All-at-top. With this experiment, we aim to investigate how much the agent can improve on the BM25 results (variation [](https://arxiv.org/html/2512.07022v1#S3.I1.i1 "item 1 ‣ 3. Proposed Method ‣ Reformulate, Retrieve, Localize: Agents for Repository-Level Bug Localization")), given the same list of candidate files.

For our second experiment, we replicate a similar setup but restrict the extracted information to the best BM25 result (variation [](https://arxiv.org/html/2512.07022v1#S3.I1.i5 "item 5 ‣ 3. Proposed Method ‣ Reformulate, Retrieve, Localize: Agents for Repository-Level Bug Localization")). With this setting, BM25 is called with fewer fields. This experiment aims to demonstrate the improvement our agent achieves using the best-performing BM25 setting. We name this experiment Best-at-top.

Space reduction. To propose candidate files, the models need to review related files from the project. However, viewing all files is impractical and resource-intensive; context window limitations prohibit processing an entire codebase at once(locagent). We apply a space reduction step, building on prior works(flexfl; swe-bench) prior to LLM-based file localization using BM25. The models are asked to select between three top-k k settings for retrieval: {10, 20, 30}.

Refinement. Once a list of candidate files is retrieved, the models are given the option to explore individual files. To limit token usage, we provide a partial view of the file, up to 512 tokens, by chunking it from the top. Before chunking, we remove any copyright headers and imports, leaving only the relevant context. Models can view multiple files until they are ready to provide a ranked list of candidate files.

Self-correction. Initial observations with our tested models indicate that they occasionally return invalid JSON and incorrect file paths. To mitigate these issues, we implement a simple self-correction mechanism with prompting(self_correction): the model’s outputs are evaluated for conformity with the JSON format using regular expressions, and file paths are combined with the canonical drive path to confirm their existence. When validation fails, the model is prompted to correct its response given the error. We grant the model three tries to correct its output.

Self-evaluation. After a model outputs a response, it is prompted again to validate its answer against all the information it gathered. We start from a fresh context and include information to help the model assess the response: bug description, BM25 results, files viewed and final ranking. The model is asked to review the final ranking and return the list of files with a revised ranking order.

Baselines. First, we evaluate the relative accuracy of our agent-based approach against our best BM25 approach from Section[3](https://arxiv.org/html/2512.07022v1#S3 "3. Proposed Method ‣ Reformulate, Retrieve, Localize: Agents for Repository-Level Bug Localization")/RQ1 on both LCA and SWE. Then, we evaluate our agentic approach on SWE against prior state-of-the-art approaches: Agentless(agentless), LocAgent(locagent) and SWE-agent(swe-agent). SWE-agent does not report file-level localization in their study; thus, we use the results reported by LocAgent. We note that the results reported for Agentless, SWE-agent and LocAgent use Accuracy@K (the fraction of bugs for which the correct file appears within the top-k k retrieved results). Because each bug in SWE has a single relevant file, Accuracy@k is equivalent to Hit@K in our setup.

4. Experiment Settings
----------------------

### 4.1. Datasets

We leverage two datasets that contain real-world SE tasks: SWE-bench-Lite(swe-bench), widely used in SE research(swe-agent; agentless; autocoderover) and Long Code Arena(LongCodeArena), whose Bug Localization subset contains 50% multi-file tasks.

Table 2. Summary statistics for the Long Code Arena and SWE-bench-Lite datasets.

*   *Source files include only ‘.py‘, ‘.java‘ and ‘.kt‘ files w/o test files. 
*   †Source files include only ‘.py‘ files w/o test files. 

Long Code Arena (LCA)(LongCodeArena) contains six repository-level benchmarks. We focus on the Bug Localization dataset which spans multiple programming languages, including Python, Java, and Kotlin. Our experiments use the test set consisting of 150 manually verified data points — 50 from each language subset. Among these 150 tasks, half involve modifications across two or more files, while the remaining 50% are single-file tasks.

SWE-bench (SWE)(swe-bench) tests models’ ability to resolve real-world GitHub issues and is exclusively focused on Python. There are three variations of the dataset; we select the SWE-bench Lite variation due to time and resource limitations. This dataset contains 300 tasks that span 11 GitHub repositories, selected from the larger SWE-bench dataset to preserve the distribution and difficulty spectrum of the original benchmark. It contains only single-file tasks.

### 4.2. Models

Many previous works focus on proprietary, larger models(autocoderover; agentless); however, results of proprietary models are harder to reproduce, pose serious privacy concerns and may incur significant costs in a typical development pipeline. We pick two models based on our constraints: 1) Ability to run on higher-end consumer hardware; 2) Good instruction following abilities (for structured outputs); and 3) coding abilities.

Qwen2.5-32B: Code-specific model in its 32B parameters variant(qwen2.5-coder). Qwen2.5-32B was trained on code-specific datasets and scores 83.46% on the instruction following benchmark IFEval(ifeval) and 92.1% on MBPP EvalPlus Base 1 1 1[https://evalplus.github.io/leaderboard.html](https://evalplus.github.io/leaderboard.html).

Qwen3-30B: Code-specific model in its 30.5B parameters variant(yang2025qwen3technicalreport). This model has a Mixture-of-Experts (MoE) architecture, where only 3.3B parameters are activated at a given time. It scores 51.6% on SWE-Bench Verified(swe-bench) when combined with the OpenHands(wang2025openhandsopenplatformai) scaffold. As it is a relatively new model at the time of writing, results on other benchmarks are not yet available.

Environment. We use Ollama, version 0.11.10, to host our models locally. All experiments are run on a Mac Studio M4 Max with 64GB of RAM. We limit all models to a 16k context window due to resource constraints, and use greedy decoding (temperature=0) and a fixed seed to minimize variability. However, LLMs are inherently non-deterministic, even in this setting(song2024goodbadgreedyevaluation). To mitigate this, we repeat each run three times and report the average. To minimize the variability introduced by LLM-based information extraction during query reformulation, we reuse the best results from Section[3](https://arxiv.org/html/2512.07022v1#S3 "3. Proposed Method ‣ Reformulate, Retrieve, Localize: Agents for Repository-Level Bug Localization")/RQ1 in our agent workflow.

### 4.3. Metrics

We use two widely known metrics from information retrieval: Mean Average Precision (MAP) and Hit@K(flexfl; LongCodeArena; irfl_best_practices). MAP represents the quality of the ranking in retrieval tasks. It measures the average position of all relevant files found by retrieval(irfl_best_practices; flexfl). Hit@K represents the proportion of rankings that contain at least one valid candidate(irfl_best_practices). Both metrics are complementary; the former evaluates the ranking quality (i.e. order of retrieved files), the latter informs about the proportion of tasks that include at least one relevant file.

5. Results
----------

Table[3](https://arxiv.org/html/2512.07022v1#S5.T3 "Table 3 ‣ 5. Results ‣ Reformulate, Retrieve, Localize: Agents for Repository-Level Bug Localization") shows the results of RQ1 for both datasets. The first row shows the baseline, which includes the full bug description. The next rows show results for each group, defined in Section[3](https://arxiv.org/html/2512.07022v1#S3 "3. Proposed Method ‣ Reformulate, Retrieve, Localize: Agents for Repository-Level Bug Localization"). Indicators show significant differences with the baseline (†\dagger) and the explanation-only (‡\ddagger) variation.

Table 3. BM25 Baseline vs Extracted Information.

*   •Bold = highest mean in column, shaded = best configuration. 
*   •Superscripts indicate significant improvement at p<<0.05: † over Baseline, ‡ over Explanation. 

Performance on LCA. All schema-based variations outperform the BM25 baseline except when using explanation only ([](https://arxiv.org/html/2512.07022v1#S3.I1.i2 "item 2 ‣ 3. Proposed Method ‣ Reformulate, Retrieve, Localize: Agents for Repository-Level Bug Localization")) for top-1 retrieval. The full schema ([](https://arxiv.org/html/2512.07022v1#S3.I1.i1 "item 1 ‣ 3. Proposed Method ‣ Reformulate, Retrieve, Localize: Agents for Repository-Level Bug Localization")) performs well overall but is surpassed by identifiers + snippets ([](https://arxiv.org/html/2512.07022v1#S3.I1.i4 "item 4 ‣ 3. Proposed Method ‣ Reformulate, Retrieve, Localize: Agents for Repository-Level Bug Localization")) and explanation + identifiers + snippets ([](https://arxiv.org/html/2512.07022v1#S3.I1.i5 "item 5 ‣ 3. Proposed Method ‣ Reformulate, Retrieve, Localize: Agents for Repository-Level Bug Localization")) on most metrics except Hit@1. While explanations alone do not provide enough lexical overlap with code, all code ([](https://arxiv.org/html/2512.07022v1#S3.I1.i3 "item 3 ‣ 3. Proposed Method ‣ Reformulate, Retrieve, Localize: Agents for Repository-Level Bug Localization")) adds noise, reducing performance at higher k k. The best overall results are obtained with explanation + identifiers + snippets ([](https://arxiv.org/html/2512.07022v1#S3.I1.i5 "item 5 ‣ 3. Proposed Method ‣ Reformulate, Retrieve, Localize: Agents for Repository-Level Bug Localization")), achieving +31% MAP@1, +11% Hit@5, and +12% Hit@10. For smaller k k, identifiers + snippets ([](https://arxiv.org/html/2512.07022v1#S3.I1.i4 "item 4 ‣ 3. Proposed Method ‣ Reformulate, Retrieve, Localize: Agents for Repository-Level Bug Localization")) achieves the highest MAP@1 (+36%) and Hit@1 (+28%). In terms of statistical significance, among top schema variants,[](https://arxiv.org/html/2512.07022v1#S3.I1.i1 "item 1 ‣ 3. Proposed Method ‣ Reformulate, Retrieve, Localize: Agents for Repository-Level Bug Localization") and[](https://arxiv.org/html/2512.07022v1#S3.I1.i5 "item 5 ‣ 3. Proposed Method ‣ Reformulate, Retrieve, Localize: Agents for Repository-Level Bug Localization") are not significantly different at Hit@5/10 and are tied with other variants, except[](https://arxiv.org/html/2512.07022v1#S3.I1.i2 "item 2 ‣ 3. Proposed Method ‣ Reformulate, Retrieve, Localize: Agents for Repository-Level Bug Localization") at k k=1. Effect size for significant differences between the best performing variation[](https://arxiv.org/html/2512.07022v1#S3.I1.i5 "item 5 ‣ 3. Proposed Method ‣ Reformulate, Retrieve, Localize: Agents for Repository-Level Bug Localization") and the baseline and explanation variations is small on MAP@1, and negligible on Hit@K.

Performance on SWE. Overall ranking quality and Hit@K scores are higher than on LCA-baseline. MAP@1 is 60% higher and Hit@1 is 20% higher, likely due to richer, better-aligned bug reports. As with LCA, all schema-based variations except explanation[](https://arxiv.org/html/2512.07022v1#S3.I1.i2 "item 2 ‣ 3. Proposed Method ‣ Reformulate, Retrieve, Localize: Agents for Repository-Level Bug Localization") outperform the baseline, achieving up to +16% MAP and +12% Hit@10. Differences among schema variations are minor for Hit@K: explanation ([](https://arxiv.org/html/2512.07022v1#S3.I1.i2 "item 2 ‣ 3. Proposed Method ‣ Reformulate, Retrieve, Localize: Agents for Repository-Level Bug Localization")), all code ([](https://arxiv.org/html/2512.07022v1#S3.I1.i3 "item 3 ‣ 3. Proposed Method ‣ Reformulate, Retrieve, Localize: Agents for Repository-Level Bug Localization")) and identifiers + snippets ([](https://arxiv.org/html/2512.07022v1#S3.I1.i4 "item 4 ‣ 3. Proposed Method ‣ Reformulate, Retrieve, Localize: Agents for Repository-Level Bug Localization")) have a Hit@10 equivalent to the baseline, suggesting that the benefits are limited to lower k k with these variations. Overall,[](https://arxiv.org/html/2512.07022v1#S3.I1.i5 "item 5 ‣ 3. Proposed Method ‣ Reformulate, Retrieve, Localize: Agents for Repository-Level Bug Localization") performs best in terms of ranking quality and finding relevant files, although it is equivalent to[](https://arxiv.org/html/2512.07022v1#S3.I1.i1 "item 1 ‣ 3. Proposed Method ‣ Reformulate, Retrieve, Localize: Agents for Repository-Level Bug Localization") on Hit@10. In terms of statistical significance, the top variants are tied on MAP and Hit@1, while[](https://arxiv.org/html/2512.07022v1#S3.I1.i1 "item 1 ‣ 3. Proposed Method ‣ Reformulate, Retrieve, Localize: Agents for Repository-Level Bug Localization") and[](https://arxiv.org/html/2512.07022v1#S3.I1.i5 "item 5 ‣ 3. Proposed Method ‣ Reformulate, Retrieve, Localize: Agents for Repository-Level Bug Localization") are tied on Hit@5 and Hit@10. The best performing variation[](https://arxiv.org/html/2512.07022v1#S3.I1.i5 "item 5 ‣ 3. Proposed Method ‣ Reformulate, Retrieve, Localize: Agents for Repository-Level Bug Localization") is significantly different from the baseline and[](https://arxiv.org/html/2512.07022v1#S3.I1.i2 "item 2 ‣ 3. Proposed Method ‣ Reformulate, Retrieve, Localize: Agents for Repository-Level Bug Localization") (except on MAP@1) with a small effect size.

We show our results for RQ2 in Table[4](https://arxiv.org/html/2512.07022v1#S5.T4 "Table 4 ‣ 5. Results ‣ Reformulate, Retrieve, Localize: Agents for Repository-Level Bug Localization"). As a baseline, we use the best-performing variation (explanation, identifiers and snippets ([](https://arxiv.org/html/2512.07022v1#S3.I1.i5 "item 5 ‣ 3. Proposed Method ‣ Reformulate, Retrieve, Localize: Agents for Repository-Level Bug Localization"))) query reformulation technique from RQ1 for both LCA and SWE. For SWE, we also compare our results with three prior techniques: SWE-agent(swe-agent), Agentless(agentless), and LocAgent(locagent).

Table 4. File-level localization agent results showing averages over three runs.

*   ‡Fine-tuned model. 
*   —Not reported by the source. 

Consistent with RQ1 findings, we observe a significant gap between LCA and SWE, both in terms of ranking quality and Hit@K, with SWE reaching 0.928 Hit@10 against 0.880 for LCA, and MAP@10 reaching 0.790 on SWE while LCA maxes at 0.490, a 38% difference in ranking quality.

Performance on LCA. Both models outperform the baseline in the All-at-top experiment. Qwen2.5-32B achieves up to +28% MAP@1 and +27% Hit@1, while Qwen3-30B reaches +28% MAP@5 and +27% MAP@10, with Hit@5/10 improving by up to 14%. We observe that gains decline as k k increases. Qwen3-30B underperforms on MAP@1, despite leading at higher k k values; we analyzed BM25 tool-call patterns across Top-1, Top-5, and Top-10 retrievals but found no clear explanation for this case. The issue likely stems from how Qwen3-30B performs semantic matching based on available signals, as it does not appear in the Best-at-top setting or with Qwen2.5-32B. A detailed BM25 tool call analysis can be found in our replication package(replication).

Looking into Best-at-top, we observe that it yields further improvements at small k k, reaching +32% MAP@1 and +30% Hit@1, but when compared with All-at-top, MAP@5 and MAP@10 drop slightly (–1.5% amd -2%, respectively) for Qwen3-30B. Qwen2.5-32B only show marginal drop on MAP@5 (-0.8%) and increase on Hit@5 (+0.8%). Both models perform better on MAP@1 and Hit@1/5 but see drops in ranking quality on higher MAP.

Performance on SWE. Both experiments show consistent gains over the baseline, with All-at-top reaching a near-perfect Hit@10 of 0.928 (+9.5%). The largest improvements occur at Top-1, where Best-at-top increases MAP@1 and Hit@1 by 35%. For this dataset, however, Best-at-top offers limited additional benefit for larger k k. Comparing best performances: MAP@5 drops slightly (0.784 vs. 0.779), Hit@5 slightly increases, and Hit@10 is almost equal. In terms of model-specific performance, Qwen2.5-32B performs better overall except on Hit@10 where it sees a marginal drop, while Qwen3-30B only performs better on first file retrieval and sees minor drops on other values of k k.

Variability. For both datasets, we report low variability across our three runs, with standard deviations between ±\pm 0.000 and ±0.0075\pm 0.0075.

Prior works. Comparing with prior works on SWE, LocAgent attains the highest accuracy, about 4% above our best model on first-file retrieval and Hit@5-but relies on a fine-tuned Qwen2.5-32B. Our approach surpasses SWE-Agent by 21% on MAP/Hit@1 and 22% on Hit@5, and exceeds Agentless, achieving +16% on Hit@5. Notably, our non-fine-tuned models rival or outperform these larger baselines despite being orders of magnitude smaller.

Our results show that lightweight query reformulation is beneficial to first-file retrieval, highlighting the value of upstream query refinement. However, the effect tends to taper at higher k k. A possible explanation is that paths/filenames are not included in the Best-at-top configuration: they may be useful to the agent to better rank files. We leave it for future work to evaluate their impact.

6. Discussion
-------------

Integration in Development Workflows. Debugging remains one of the most time-consuming and costly SE activities, accounting for 35–50% of developers’ time(debugging_mindset). Localizing files relevant to a bug is one of the first steps in a bug-fixing workflow: our approach proposes to assist with that task. One key advantage of our approach is its usability for real-world software development environments: we rely on smaller, open-source LLMs and a lightweight lexical retriever (BM25), which can be deployed without specialized hardware or costly API access.

The information extraction step is both fast and efficient, completing in an average of 5.125 seconds per task on LCA and 4.445 seconds on SWE with Qwen3-30B. The average localization task execution time on LCA lies between ≈\approx 23-50 seconds and ≈\approx 18-78 seconds on SWE with Qwen3-30B, the top-10 variations being the most time-intensive. From a practical use standpoint, these results indicate that query reformulation and retrieval can be performed on the fly within a developer’s workflow. This approach is well-suited for integration into IDE assistants where fast, low-cost retrieval is essential.

Tool Usage and Error Analysis. Tool-calling preferences vary across models and datasets. To better understand tool usage frequency, we collect detailed statistics, summarized in Table[5](https://arxiv.org/html/2512.07022v1#S6.T5 "Table 5 ‣ 6. Discussion ‣ Reformulate, Retrieve, Localize: Agents for Repository-Level Bug Localization").

Tool call averages. We note that bm25_topk and extract_relevant are invoked multiple times per repository. Models have access to prior conversation turns and may choose to re-invoke a previously available tool, which explains this behaviour.

We also observe a high average number of file-view requests per repository. These include: 1) valid file views, where the same file may be opened repeatedly, and 2) invalid paths. To mitigate 1), we warn the model after duplicate views and block repeated access after five occurrences. To address 2), we apply self-correction (Section[3](https://arxiv.org/html/2512.07022v1#S3 "3. Proposed Method ‣ Reformulate, Retrieve, Localize: Agents for Repository-Level Bug Localization")/RQ2). After removing duplicate and erroneous calls, file views drop by up to 95%, highlighting the models’ difficulty in 1) reproducing file paths accurately and 2) following the instruction to view each file only once. Calls to the view_readme tool are rare and have a negligible impact on results.

Errors. Self-correction covers tool-call validity (correct tool and parameters), file-path verification, and JSON formatting. When an error occurs, the model is warned and given up to three retries. Any model call exceeding ten minutes (600 sec) is cancelled. Table[5](https://arxiv.org/html/2512.07022v1#S6.T5 "Table 5 ‣ 6. Discussion ‣ Reformulate, Retrieve, Localize: Agents for Repository-Level Bug Localization") reports the corresponding error counts. We observe more aborted file views with Qwen2.5-32B, whereas Qwen3-30B exhibits repetitive behavior leading to timeouts. JSON formatting errors are corrected more reliably by Qwen2.5-32B, while Qwen3-30B shows a slightly higher number of cases where it was unable to correct its output.

Table 5. Average tool calls per repository (top) and error counts (bottom) by dataset and model, computed on one run.

SWE LCA
Qwen2 Qwen3 Qwen2 Qwen3
Tool call averages / repo
bm25_top_k 6.0 5.4 6.7 7.2
extract_relevant 6.0 4.8 6.0 6.0
view_file 40.2 20.1 36.8 22.2
view_file unique 2.0 1.6 5.3 4.0
view_readme 0.0 0.0 0.0 0.0
Error counts
Aborted file views (%)12.6 6.4 10.0 3.8
Model timeouts 0 18 0 11
Aborted - invalid JSON 2 12 4 9

*   •* Qwen2 = Qwen2.5-32B, Qwen3 = Qwen3-30B 

7. Threats to Validity
----------------------

Output variability. LLMs remain non-deterministic, even at temperature 0. To mitigate this threat, we run agent-based experiments three times and report the average of the runs.

Bug information extraction. The quality of extracted information can affect retrieval quality; thus, the model used to extract the information and summarize the bug can significantly impact the results. We use Qwen3-30B due to resource constraints.

Metrics. This threat concerns whether our chosen metrics accurately capture retrieval performance for bug localization. We use widely accepted metrics (MAP and Hit@K), commonly used in previous studies.

Dataset contamination. The LLMs we evaluate are pretrained on web-scale code corpora that may include the projects used in LCA and SWE-bench. Observed gains could stem from memorization rather than effective retrieval, and should be interpreted as an upper bound of real-world performance.

Generalizability. We run with two different models on two large datasets spanning three programming languages: Java, Python and Kotlin. We expect that the results may not hold for commercial code, models of different sizes or bug reports with a different structure.

Repository-Level Tasks. Although SWE-bench Lite contains single-file tasks, they often require searching the entire repository to locate the relevant file, making the problem comparable in complexity to repository-level localization.

8. Conclusion
-------------

This study investigates the impact of query reformulation on agent-based workflows for file-level bug localization. Query reformulation, which adds a summary and code signals (identifiers, snippets), consistently strengthens lexical retrieval: with BM25, it boosts first-file localization by 36% over our baseline. When an LLM-based agent uses the best combination, we achieve an improvement over our best BM25 baseline of 35%. Our open-sourced, non-fine-tuned LLM agent further advances file-level localization, outperforming SWE-Agent and Agentless by up to 22%. Future work will explore method-level code chunking for finer retrieval granularity and an IDE plugin to assist in file-level bug localization.

## Figures

### Figure 1: Agentic Workflow
![Figure 1](../../../../_media/query-reformulation-fig1-agent-flow.png)
*The agentic workflow. At every step, outputs are validated, and the model is asked to correct invalid outputs.*
