---
created: 2026-02-27
description: Trace-Free+ uses curriculum learning to train LLMs that rewrite tool descriptions for better agent tool selection and execution, generalizing to unseen tools without requiring execution traces at inference time.
source: https://arxiv.org/abs/2602.20426
type: paper
authors:
  - Ruocheng Guo
  - Kaiwen Dong
  - Xiang Gao
  - Kamalika Das
arxiv: "2602.20426"
---

## Abstract

The performance of LLM-based agents depends not only on the agent itself but also on the quality of the tool interfaces it consumes. While prior work has focused heavily on agent fine-tuning, tool interfaces — including natural language descriptions and parameter schemas — remain largely human-oriented and often become a bottleneck, especially when agents must select from large candidate tool sets. The authors propose Trace-Free+, a curriculum learning framework that progressively transfers supervision from trace-rich settings to trace-free deployment, encouraging the model to abstract reusable interface-usage patterns and tool usage outcomes. Experiments on StableToolBench and RestBench show consistent gains on unseen tools, strong cross-domain generalization, and robustness as the number of candidate tools scales to over 100.

## Key Takeaways

*Figure 1: The description generator pipeline — raw tool schemas become agent-optimized descriptions via a fine-tuned LLM*
![[guo-20426-fig-001.png]]

The core insight is that tool descriptions are a first-class optimization target, not just documentation. Most work on improving agents focuses on the agent itself (fine-tuning, prompting, reasoning). This paper shows that rewriting the tool interface — the description and parameter schema the agent sees — can deliver comparable or better gains. This connects directly to [[CLIs are the agent-native interface because legacy tooling is already machine-readable]] — the interface layer between agent and tool determines performance as much as the agent's reasoning capability.

The two-pattern approach for generating training data is particularly clever. First, an agentic annotator (built with Smolagents) explores 9,640 API providers from RapidAPI to identify which ones actually work, collecting execution traces along the way. Then synthetic multi-hop queries are generated with explicit inter-API dependencies, and a two-stage description improvement pipeline produces ground truth: D0 (original) → D1 (guideline-improved) → D2 (trace-refined with failure patterns encoded as behavioral constraints).

*Figure 2: The three-stage SFT data synthesis pipeline — tool annotation, query synthesis, and two-stage description improvement*
![[guo-20426-fig-002.png]]

The curriculum learning strategy (Trace-Free+) is what makes this deployable in practice. Training starts with a high ratio of trace-based examples (where the model sees execution traces alongside tool schemas) and gradually shifts to trace-free examples (schema only). This lets the model internalize what makes descriptions effective from traces, then apply that knowledge without them. At inference time, it only needs the original tool description — no interaction with the tool required. This matters for cold-start, privacy-constrained, or safety-critical settings where you can't just explore an API. The pattern of [[context tax compounds through cache misses bloated tools and unbudgeted output tokens]] is relevant here — better tool descriptions reduce wasted tokens from failed tool calls and re-attempts.

The scaling results are the strongest evidence. As candidate tools increase from ~10 to 100+, Trace-Free+ degrades the least — maintaining high query-level success rates while other methods (including GPT-4-prompted rewrites) fall off sharply. This is because the model has learned generalizable patterns about what makes descriptions discriminative, not just individually polished.

*Figure 3: Scaling experiments — Trace-Free+ maintains the highest QL success rate as candidate tools grow to 100+*
![[guo-20426-fig-003.png]]

![[guo-20426-fig-004.png]]

![[guo-20426-fig-005.png]]

Cross-domain generalization is strong: models trained only on ToolBench APIs transfer well to TMDB and Spotify (RestBench), with Trace-Free+ hitting 74.9% QL on TMDB vs 49.5% for original descriptions. The [[skill graphs outperform single skill files by letting agents traverse linked domain knowledge on demand]] pattern applies here too — the model learns transferable meta-knowledge about how to describe tools, not just domain-specific fixes.

Practical implications for agent builders: instead of (or alongside) fine-tuning your agent, run your tool descriptions through a trained description generator. The paper shows this is complementary to agent improvement and can be done once per tool, offline, with no ongoing cost.

## External Resources

- [arXiv paper](https://arxiv.org/abs/2602.20426) — full paper with appendices
- [StableToolBench](https://github.com/THUNLP-MT/StableToolBench) — primary evaluation benchmark
- [RestBench](https://github.com/Yifan-Song793/RestGPT) — cross-domain evaluation benchmark
- [Smolagents](https://github.com/huggingface/smolagents) — framework used for the agentic tool annotator
- [RIMRULE](https://arxiv.org/abs/2501.15839) — rule extraction method used for trace-aware description refinement

## Original Content

> [!quote]- Full Paper Text
>
> Learning to Rewrite Tool Descriptions for Reliable LLM-Agent Tool Use
>
> Ruocheng Guo * 1 Kaiwen Dong * 1 Xiang Gao 1 Kamalika Das 1
>
> Abstract
>
> The performance of LLM-based agents de-
> pends not only on the agent
> itself but also
> interfaces it con-
> on the quality of the tool
> sumes. While prior work has focused heavily
> on agent fine-tuning, tool interfaces—including
> natural
> language descriptions and parameter
> schemas—remain largely human-oriented and of-
> ten become a bottleneck, especially when agents
> must select from large candidate tool sets. Exist-
> ing approaches to improving tool interfaces rely
> on execution traces, which are frequently unavail-
> able in cold-start or privacy-constrained settings,
> and typically optimize each tool independently,
> limiting scalability and generalization to unseen
> tools. We propose Trace-Free+ , a curriculum
> learning framework that progressively transfers
> supervision from trace-rich settings to trace-free
> deployment, encouraging the model to abstract
> reusable interface–usage patterns and tool usage
> outcomes. To support this approach, we construct
> a large-scale dataset of high-quality tool inter-
> faces using a structured workflow over a diverse
> collection of tools. Experiments on StableTool-
> Bench and RestBench show consistent gains on
> unseen tools, strong cross-domain generalization,
> and robustness as the number of candidate tools
> scales to over 100, demonstrating that tool inter-
> face optimization is a practical and deployable
> complement to agent fine-tuning.
>
> 6
> 2
> 0
> 2
>
> b
> e
> F
> 3
> 2
>
> ]
> I
>
> A
> .
> s
> c
> [
>
> 1
> v
> 6
> 2
> 4
> 0
> 2
> .
> 2
> 0
> 6
> 2
> :
> v
> i
> X
> r
> a
>
> 1. Introduction
>
> Advances in large language models (LLMs) have en-
> abled the widespread adoption of LLM-based tool-using
> agents (Team et al., 2025a; Wang et al., 2024; Luo et al.,
> 2025; Wang et al., 2025), which interact with external
> tools—such as APIs (Patil et al., 2024; Song et al., 2023;
> Guo et al., 2024), code execution environments (Huang
>
> *Equal contribution 1Intuit AI Research, Mountain View,
> Kamalika Das <Kama-
>
> CA, USA. Correspondence to:
> lika_Das@intuit.com>.
>
> Preprint. February 25, 2026.
>
> 1
>
> et al., 2025a), and databases (Li et al., 2024)—to solve
> complex multi-step tasks beyond the limits of their inter-
> nal knowledge. This paradigm substantially extends the
> scope of LLMs to real-world applications including deep
> research (Huang et al., 2025b), coding (Zhang et al., 2024),
> and web browsing (Yang et al., 2024; Qi et al., 2025). In
> such systems, performance is governed by two comple-
> mentary factors: the agent’s reasoning capability and the
> quality of the tool interfaces it consumes. While prior
> work has largely focused on improving agents themselves,
> tool interfaces—particularly descriptions and parameter
> schemas—remain largely human-centric and increasingly
> constrain performance as agents are exposed to large and
> evolving sets of candidate tools.
>
> Figure 1. An illustration of the proposed tool interface improve-
> ment pipeline. Compared to the original description (D0), the
> learned description generator produces more effective tool descrip-
> tions that lead to better tool usage.
>
> Improving tool descriptions has therefore emerged as an ef-
> fective lever for enhancing tool-using agents. Prior work has
> shown that revising tool descriptions—often with the help
> of strong LLMs—can substantially improve tool selection
> and execution accuracy (Qu et al., 2025; Yuan et al., 2025;
> Fang et al., 2025). Several approaches further leverage tool
> execution traces to refine descriptions based on observed
> successes and failures (Qu et al., 2025; Fang et al., 2025).
>
> Despite these advances, existing approaches face fundamen-
> tal limitations that hinder real-world deployment. Most
> existing methods rely heavily on tool execution traces and
> require carefully engineered interaction procedures such
> as iterative exploration or tree search. However, in many
> practical settings—such as cold-start deployment of newly
> released APIs, safety-critical or privacy-constrained envi-
>
> Learning to Rewrite Tool Descriptions for Reliable LLM-Agent Tool Use
>
> ronments—interacting with tools to collect such traces is
> unsafe, costly, or infeasible. In addition, existing approaches
> typically optimize each tool in isolation, without learning
> generalizable patterns of effective tool interfaces, leading
> to poor generalization to unseen tools and degraded per-
> formance as the number of candidate tools grows. Finally,
> these prompt-based methods incur high inference cost, raise
> data privacy concerns, and offer limited control over model
> behavior, restricting their scalability and robustness.
>
> In this work, we propose Trace-Free+, a learning-based
> approach for improving tool interfaces in a generalizable
> and deployable manner. Trace-Free+ leverages execution
> traces only during training, where they provide supervision
> on relation between tool interface specifications and success-
> ful and failed tool usage. Leveraging curriculum learning,
> the model is trained to generate the same improved tool
> descriptions with and without traces, progressively reduc-
> ing reliance on trace information. This enables knowledge
> learned from trace-rich tools to transfer to cold-start trace-
> free inference settings.
>
> We instantiate this approach using a large collection of real-
> world tools, for which high-quality tool descriptions and
> repaired parameter schemas are synthesized through a prin-
> cipled improvement workflow. Fine-tuning open-weight
> LLMs on this data yields generalizable tool description gen-
> erators that can be applied directly to unseen tools without
> tool execution traces at test time.
>
> Through extensive experiments on StableToolBench and
> RestBench, we demonstrate that our approach substantially
> improves tool selection and parameter generation on unseen
> tools, generalizes across domains, and remains robust as the
> number of candidate tools scales.
>
> Contributions. In summary, our contributions are:
>
> • We propose Trace-Free+, a curriculum learning frame-
> work that enables effective tool interface improvement
> by transferring knowledge from trace-rich training to
> trace-free inference.
>
> • We develop a large-scale dataset of high-quality tool
> descriptions and repaired parameter schemas through
> a principled agentic workflow to support training gen-
> eralizable tool description generators.
>
> • Extensive experiments in both trace-free and trace-
> based settings, across in-domain and cross-domain test
> datasets, and evaluated using subtask-, query-, and
> tool-level metrics, demonstrate strong generalization to
> unseen tools and robustness as the number of candidate
> tools scales beyond 100.
>
> 2. Problem Statement
>
> t , ..., hq
>
> 1, ..., hq
>
> For a multi-step query q, a tool use trace H(q) =
> {hq
> T } has multiple subtasks t = 1, ..., T . For
> simplicity of notations, we will ignore the superscription q
> when it is not necessary. Each subtask ht = (xt, at, pt, ot)
> consists of the input xt (context and subtask query), the
> agent’s tool selection at, parameter generation pt, and sub-
> task output (i.e., tool response) ot. For each step, a tool-
> using agent decides which tool to use with generated param-
> eters given the subtask input xt and the interfaces of a set
> of tools A, which is represented by at, pt = Fagent(xt, A).
> Then, the agent observes the output of the subtask ot =
> Fenv(at, pt), which then becomes a part of the input of the
> next subtask xt+1.
>
> For each step, we optimize a combined metric of tool se-
> lection accuracy and API call success rate, denoted by
> r(at, pt) which is impacted by the tool interface A. Then,
> let R(A; Q) denote the aggregated evaluation metric for all
> subtasks for a set of queries Q.
>
> Tool Interface Improvement for Training Data Synthesis.
> With access to a set of tools A = (a1, ..., aM ) and a set
> of (synthetic) training queries Qtr, where each tool ai =
> {di, pi} contains its description di and parameter schema
> si. Given A and Qtr, our goal is to improve tool interfaces
> M } by optimizing the metric R(A′; Qts)
> A′ = {a′
> where a′
> i, s′
> i} is the improved interface for the i-
> th tool. Then, A′ is used as ground truth for supervised
> fine-tuning (SFT) description generators for tool interface
> improvement at test time.
>
> 1, ..., a′
> i = {d′
>
> Trace-free Tool Interface Improvement. Given a set
> of test tools A′ = {aM +1, ..., aM +K}, where tool call-
> ing is not allowed, we aim to revise them to obtain A′ =
> {a′
> M +K} for better R(A′; Qts). In practice, we
> focus on tool description improvement under the trace-free
> setting since paramter fixing without traces is extremely
> challenging.
>
> M +1, ..., a′
>
> Trace-based Tool Interface Improvement. Given a set of
> unseen tools A′ = {aM +1, ..., aM +K} and testing queries
> Qts, we allow tool interaction at inference time, then the
> task is to obtain A′ = {a′
> M +K} that has im-
> proved R(A′; Qts).
>
> M +1, ..., a′
>
> 3. Methodology
>
> In this section, we present the data synthesis workflow used
> for tool interface improvement and describe how we fine-
> tune open-weight LLMs to serve as tool description genera-
> tors, along with the corresponding inference procedure. The
> workflow begins with a data synthesis pipeline that includes
> tool annotation and filtering, query synthesis, tool call his-
> tory collection, and tool description improvement. Using
>
> 2
>
> Learning to Rewrite Tool Descriptions for Reliable LLM-Agent Tool Use
>
> the synthesized data, we perform SFT so that description
> generators learn to produce descriptions more suitable for
> LLM-based tool use across a large number of tools. Finally,
> we support both trace-based and trace-free settings (detailed
> in Section 3.3) for the description generator, which target
> interactive and non-interactive tool sets, respectively.
>
> Figure 2. The SFT data synthesis pipeline.
>
> 3.1. Data Synthesis for Tool Interface Improvement
>
> 3.1.1. AGENTIC SEED TOOL ANNOTATION AND
>
> FILTERING
>
> To synthesize training data for tool-using agents, we first
> filter a set of tools that work as expected for the tool-using
> agent, referred to as seed tools. We use the tool set from
> ToolBench (Qin et al., 2023) as the initial source of seed
> tools. ToolBench collects real-world RESTful APIs from
> RapidAPI1 and organizes them into 49 categories, including
> data, finance, sports, and media, covering a wide range of
> realistic scenarios. Within each category, APIs are grouped
> by API providers. Each API provider corresponds to a
> single service backend and exposes multiple API endpoints
> that support related functions, such as querying, filtering, or
> aggregating data within the same service scope.
>
> However, the tools in ToolBench cannot be directly used for
> query synthesis due to two limitations. First, as reported by
> StableToolBench (Guo et al., 2024), a substantial fraction
>
> 1https://rapidapi.com/
>
> 3
>
> of ToolBench APIs are either unavailable or only return
> server-side errors. It is essential to ensure that the seed tools
> are fully operational because our data synthesis process
> needs meaningful tool responses. Second, the original tool
> interfaces in ToolBench lacks tool response examples, which
> makes it difficult to generate natural and interdependent
> multi-step queries during data synthesis.
>
> To address these issues, we design an agentic tool annotator
> to assess health of the API tools and collect tool response
> examples from tool call history. We implement the anno-
> tator using Smolagents (Roucher et al., 2025) and enforce
> an action–observation loop with self-reflection (Pan et al.,
> 2024) until a termination condition is reached. The annota-
> tor is equipped with the original interfaces of the APIs in
> ToolBench as well as a set of utility functions. It is prompted
> to explore and interact with each API provider, and then
> annotate API health status and response examples, including
> both API requests and responses. Through direct tool call,
> the annotator determines whether APIs are functional and
> records representative tool call history.
>
> We follow the principle of everything is a tool, and equip the
> annotator with utility functions including: (1) a TakeNote
> tool, which supports intermediate reasoning capability when
> needed (Yao et al., 2023); (2) an AnnotateHealth tool, which
> labels each API as good, bad, or unknown; (3) an Anno-
> tateExample tool, which records concrete API interaction
> examples; and (4) a FinalAnswer tool, which signals the
> end of the annotation process. The full annotator prompt is
> provided in the Appendix.
>
> We apply the annotator to all 9,640 API providers in Tool-
> Bench. After annotation, 1,234 API providers have all end-
> points labeled as health = good. From this set, we further
> exclude API providers that appear in the evaluation bench-
> marks (see Section 4.1) or contain fewer than three APIs.
> This process results in 107 API providers, which form the
> final set of seed tools used for data synthesis.
>
> 3.1.2. USER QUERY SYNTHESIS
>
> Given the seed tools, we synthesize user queries that explic-
> itly target complex, multi-step tool usage. Our primary goal
> is to generate queries that are (1) naturally phrased and goal-
> oriented, (2) unsolvable by a single API call, and (3) require
> structured dependencies between multiple APIs. Unlike-
> queries where API tools can be invoked independently, we
> focus on queries whose solution requires reasoning about
> intermediate outputs and the order of tool calls.
>
> Our key contribution in this stage is a dependency-aware
> query synthesis strategy. Beyond schema-based prompting,
> we leverage previously annotated tool call history to guide
> query generation. These history provides concrete evidence
> of how APIs within the same provider are composed in
>
> Learning to Rewrite Tool Descriptions for Reliable LLM-Agent Tool Use
>
> practice. We explicitly prompt the LLM to first analyze
> inter-API dependencies and select a small set of APIs that
> form a coherent workflow, and only then generate a single
> natural-language query that implicitly requires all selected
> APIs to be used in sequence.
>
> This design encourages realistic multi-step tool-using and
> prevents degenerate queries that can be solved by isolated
> tool calls. Additional details are provided in Appendix A.2.
>
> 3.1.3. WORKFLOW FOR TRACE-BASED TOOL
>
> INTERFACE IMPROVEMENT
>
> The multi-step user queries synthesized in the previous stage
> allow us to systematically probe how tool descriptions affect
> agent behavior during execution. By running a tool-using
> agent on these queries, we collect execution traces that re-
> veal whether existing tool interfaces provide sufficient guid-
> ance for correct tool selection, argument construction, and
> step ordering. In particular, failure traces expose systematic
> mismatches between how tools are described and how they
> must be used to complete each subtask in interdependent
> multi-step tasks.
>
> We generate execution traces by running the tool-using agent
> Fagent described in Section 2 on the synthesized queries
> and recording both successful and failed trajectories. These
> traces serve as supervision for improving tool descriptions.
> Our key insight is that tool descriptions can be improved
> by explicitly encoding behavioral constraints – such as only
> IPv4 and IPv6 format are acceptable for a tool parameter
> called ip_address — inferred from execution failures.
>
> Based on the collected traces, we introduce a two-stage
> description improvement pipeline. First, starting from the
> original set of tool descriptions D0, we generate a data-
> independent improved descriptions D1 by applying general
> tool description guidelines. This stage focuses on improving
> clarity, completeness, and schema alignment, independent
> of any specific execution outcome.
>
> Second, we refine D1 using execution traces to produce
> a trace-aware description D2. We adopt RIMRULE (Gao
> et al., 2025) to extract generalizable rules in natural language
> from failed traces. These rules capture recurring usage con-
> straints and failure patterns, such as unaccetable values for
> a parameter or incorrect assumptions about tool responses.
> For each tool, we retrieve the relevant rules and incorporate
> them into its description, yielding a final description that
> reflects both general best practices and tool-specific usage
> constraints based on observed tool execution traces.
>
> The resulting D2 descriptions serve as supervision for train-
> ing our description generator. Finally, we split the dataset
> into two splits as in Table 6 in Appendix A.3, where Split A
> includes all the tools that are included in the test queries of
> StableToolBench, and Split B contains all the other healthy
>
> tools. There is no overlapping tools or queries between the
> two splits, enabling us to test the generalizability of the
> trained models. Additional implementation details, prompts,
> and examples are provided in the Appendix A.3.
>
> 3.2. Trace-free+: Training Generalizable Tool
>
> Description Generators
>
> To enable tool description generation for unseen tools at
> test time, in both trace-based and trace-free settings, we
> fine-tune open-weight LLMs using the SFT dataset con-
> structed in Section 3.1. Each training example takes the
> form {((ai, hi), d′
> i)} for
> trace-free data, where ai denotes the original tool interface,
> hi = Summary(H(ai)) is a summary of tool execution
> traces collected under that the original interface, and d′
> i is
> the improved description used as supervision.
>
> i)} for trace-based data and {(ai, d′
>
> Trace-based models. We first train description generators
> using standard SFT with trace-based examples. The model
> is trained to generate the optimized description d′
> i. We
> denote this model as Trace-Based, which only needs traces
> collected with the original tool interface/description.
>
> Trace-free models. In many deployment scenarios, tool
> execution traces are unavailable for new tools due to safety,
> privacy, or cold-start constraints. In this setting, the model
> must generate high-quality tool descriptions without access
> to hi at inference time.
>
> Training only on trace-based data leads to a mismatch be-
> tween training and inference inputs, while training only on
> trace-free data removes critical supervision about tool behav-
> ior, such as valid usage conditions and common parameter
> errors. To balance these factors, we adopt a curriculum
> learning strategy (Bengio et al., 2009).
>
> Specifically, we construct trace-free training examples by
> removing hi from the prompts of trace-based examples,
> thereby simulating the trace-free setting at inference time.
> Training begins with a higher proportion of trace-based ex-
> amples and gradually increases the proportion of trace-free
> examples until they dominate the training data. This cur-
> riculum allows the model to first learn how execution traces
> inform effective descriptions and then adapt to generating
> descriptions without traces. We denote the models trained
> with a mixture of trace-based and trace-free data as Trace-
> Free+. For comparison, we also train a model using only
> trace-free examples, denoted as Trace-Free.
>
> 3.3. Inference for Unseen Tools
>
> Finally, at inference time, we use the trained models to
> generate tool descriptions for tools that were unseen dur-
> ing training. Given any unseen tool, our models require
> only minimal data processing to construct the trace-free
> or trace-based inputs. In constrast, existing methods like
>
> 4
>
> Learning to Rewrite Tool Descriptions for Reliable LLM-Agent Tool Use
>
> DRAFT (Qu et al., 2024) and Play2Prompt (Fang et al.,
> 2025) rely on heavily engineered multi-turn tool execution
> pipelines to collect inputs for the inference stage, resulting
> in higher cost and difficulties to reproduce on new datasets.
>
> Trace-free. In this setting, execution traces of the test tools
> Ats are unavailable due to cold-start conditions or privacy
> constraints. Consequently, the tool description generator
> must produce an improved tool description d′
> i using only the
> original description di and parameter schema si. Parameter
> fixing is not feasible in this setting because execution traces
> are unavailable.
>
> Trace-based. We assume there is a pre-test stage where the
> test tools Ats can be called to collect traces H(ai), ∀ai ∈
> Ats, but the test queries Qts are not available. To test the
> generalization of models trained by our dataset, we ensure
> the tools in Ats are unseen in the training set. This is to
> show that our dataset can also be used for tool description
> improvement in this setting. Trace-based description gener-
> ation obtains d′
> i from the tool description, parameter schema
> and the tool execution traces (ai, H(ai)).
>
> 4. Experiments
>
> We conduct a comprehensive set of experiments to show
> the effectiveness of models fine-tuned on the trace-masked,
> mixed and trace-based SFT data based on our dataset. To
> demonstrate generalizability of our models, the test set only
> consists of tools unseen at the training time for our models,
> while baseline methods may use tool execution traces of test
> tools in their training phase.
>
> 4.1. Experimental Setup
>
> Evaluation Protocol. To enable a well-controlled experi-
> mental setting, we introduce step-wise teacher-forcing eval-
> uation as a principled protocol for measuring the quality
> of tool interfaces. By teacher forcing we aim to guarantee
> a correct intermediate context by calling the ground truth
> API at each step, this evaluation isolates failures due to tool
> descriptions, enables clearer error attribution, and yields a
> richer set of first-time errors, while still supporting mean-
> ingful query-level metrics. For error attribution, it ensures
> that the differences in the agent’s performance can only be
> attributed to the differences of the tool descriptions rather
> than to downstream effects of earlier mistakes in context.
> Without teacher forcing, for each subtask, errors may arise
> either from (1) the agent’s misunderstanding of the tool de-
> scriptions or (2) corrupted context (e.g., missing or incorrect
> parameter values), leading to compounded errors that are
> difficult to disentangle. Only the former reflects the quality
> of the tool interfaces. For the this reason, teacher forcing
> allows us to identify true first-time errors, rather than errors
> caused by earlier missteps, while preserving the ability to
>
> compute end-to-end performance metrics at the query level.
>
> Evaluation Metrics. We evaluate performance using
> subtask-level, query-level, and tool-level metrics. Subtask-
> Level (SL) Success Rate: A subtask is considered successful
> if the correct tool is selected and its execution completes
> successfully. Query-Level (QL) Success Rate: A query is
> considered successful iff all of its constituent subtasks are
> successful. They do not rely LLM-as-a-judge and are more
> precise than coarse-grained metrics like query-level recall
> used in existing work, which may be insufficient to distin-
> guish between different methods. For example, query-level
> recall (Qu et al., 2025) fails to capture errors such as in-
> voking tools in an incorrect order and does not adequately
> penalize redundant tool calls. While prior work predomi-
> nantly reports query-centric metrics, we additionally intro-
> duce tool-level metrics, which are essential for analyzing
> (1) the proportion of tools whose performance improves or
> degrades and (2) the average magnitude of improvement
> across tools. These metrics treat all tools equally, regard-
> less of how many subtasks or queries they are selected for
> or executed on. Concretely, for tool selection, we report
> the Tool-Level F1 Score rather than tool-level accuracy to
> mitigate the effect of the large number of true negatives
> (TN). For tool usage, we report API execution success rate.
> Additional details on the evaluation protocol and metrics
> are provided in Appendix B.1.
>
> Evaluation Benchmark. We evaluate our method on Rest-
> Bench (Song et al., 2023) and StableToolBench (Guo et al.,
> 2024). We select these two datasets for two main reasons:
> (1) they provide real-world API tools that return realistic
> responses and errors, and (2) the API tools are reused across
> multiple test queries, offering opportunities to test general-
> izable patterns for tool selection and execution. RestBench
> focuses on real-world RESTful API usage on TMDB 2 and
> Spotify 3 platforms. It consists of human-written multi-
> hop queries, each with a set of ground truth APIs. Each
> query requires selecting correct APIs in a specific order
> and generating valid parameters, making it suitable for eval-
> uating the quality of tool interfaces in realistic web ser-
> vice scenarios. StableToolBench is a stabilized version of
> ToolBench (Qin et al., 2023), which provides large-scale
> evaluation across diverse 49 cateogries and supports both
> single-tool and multi-tool settings. The large-scale tool can-
> didates in StableToolBench presents a suitable testbed to
> evaluate the generalizability of our method across various
> tools. To better reflect realistic conditions while retaining
> reproducibility, we keep the caching mechanism of Stable-
> ToolBench but disable the virtual API simulation. This
> setting balances realistic tool behavior with controlled and
> repeatable evaluation.
>
> 2themoviedb.org
> 3spotify.com
>
> 5
>
> Learning to Rewrite Tool Descriptions for Reliable LLM-Agent Tool Use
>
> Data Pre-processing. For a clean and controlled experi-
> ment setup, we correct the original parameter schemas in
> StableToolBench. This is because some tools used in the
> test queries have parameter schemas that are inconsistent
> with the actual parameters needed, which cause server-side
> errors during evaluation. With incorrect parameter schemas,
> there are two issues for evaluating different methods for tool
> description optimization. First, the tool-using agent always
> fail when executing these tools, making no difference with
> tool descriptions from different methods (Lu et al., 2025).
> Second, for our teacher-foring evaluation, incorrect parame-
> ter schemas lead to errors in responses of the ground truth
> APIs. To mitigate this issue, we systematically validate
> and revise parameter schemas through tool execution. This
> preprocessing step reduces spurious failures and yields a
> cleaner evaluation environment. Implementation details are
> provided in Appendix B.2.
>
> Baseline Methods. In the trace-free setting, we compare
> models fine-tuned on our SFT dataset with the prompting-
> based baseline EasyTool (Yuan et al., 2025) that does not
> require tool execution traces as well as D0 and D1. Then,
> for the trace-based setting, we consider DRAFT (Qu et al.,
> 2025) and Prompt2Play (Fang et al., 2025) which rely on
> complicated multi-turn tool execution pipelines to collect
> tool execution traces with the test tools. We also include
> D2, D1 and D0 for comparison.
>
> 4.2. Trace-free Evaluation
>
> The trace-free evaluation tests the generalizability of meth-
> ods. Here, for each unseen tool in the test set, the model is
> given the original tool interface ai and needs to generate an
> improved tool description d′
> i.
>
> In this setting, we split the queries and tools into non-
> overlapping training Qtr(Atr), Atr and test Qts, Ats sets.
> Then we use a random subset of the training tools and their
> corresponding queries as the validation set to avoid overfit-
> ting. We run our description improvement workflow (see
> Section 3.1) on Qtr(Atr), Atr to create SFT data and train
> the tool description generator. Then we apply the generator
> model to improve Ats without observing the test queries
> Qts or any tool use traces based on these tools or queries.
> Thus, the trace-free evaluation tests the generalizability of
> the trained tool description generators, where they need to
> deeply understand the original tool description and parame-
> ter schema and guess the use cases of the tool and potential
> parameter errors. More specifically, we split the tools in Sta-
> bleToolBench (Guo et al., 2024) into two exclusive subsets:
> training Atr and test Ats, where the test set contains all the
> tools listed as candidates in the test queries.
>
> In-domain Results. Split B (see Table 6 in Appendix B)
> of the synthesized SFT data is used as the training set, and
> we run evaluation on the original test queries of Stable-
>
> ToolBench which uses tools in Split A as candidates. We
> can make the following observations from the results in
> Table 1. First, compared to Trace-Free, Trace-Free+ is sig-
> nificantly better in many cases, demonstrating the effectivess
> of the curriculum learning strategy. Second, the Trace-Free+
> model outperforms D1 with manually optimized prompt
> on GPT-41 for the harder subsets (G2 and G3) where the
> queries are multi-hop and therefore the understanding of
> interdependencies of tools are needed. This implies that
> the traces collected from the synthesized multi-hop queries
> helps generate effective tool descriptions for unseen test
> multi-hop queries that need unseen tools to solve. EasyTool
> is slightly worse than D0 on the SL and QL results because
> it relies on manually optimized prompts for an old version of
> ChatGPT and Vicuna-30B (Peng et al., 2023) while newer
> models are used as the tool-using agent in this work, this
> observation agrees with the results in (Fang et al., 2025) on
> GPT-4o (Hurst et al., 2024).
>
> Cross-domain Results. Then, we test the cross-domain
> generalizability of Trace-Free+ and Trace-Free fine-tuned
> by our dataset. In particular, we fine-tune models on the
> Split B of our dataset that only has API tools from Stable-
> ToolBench, and then test them on tools and queries from
> the TMDB and Spotify datasets of RestBench (Song et al.,
> 2023). We include all API tools of those two datasets as
> the candidates to make tool selection more challenging. As
> shown in Table 2, we can make similar observations to the
> in-domain trace-free experiment that Trace-Free+ outper-
> forms others significantly due to (1) learned generalizable
> patterns from the dataset and (2) the internalized knowledge
> about tool execution result from the trace-based examples
> in curriculum learning.
>
> Tool-level Results. Table 3 shows the results aggregated
> on the tool level for the trace-free setting on StableTool-
> Bench. We can observe that, Trace-Free+ outperforms other
> methods w.r.t.
> tool selection F1 score and is the second
> best in API execution success rate. Compared to the advan-
> tage over D0 in subtask-level or query-level metrics (see
> Table 1), the magnitude ∆ is smaller because infrequently
> selected or used tools are weighted significantly more in
> tool-level metrics. Compared with Table 9 in Appendix C,
> trace-based methods generally improve more on the API
> execution success rate, which shows the importance of tool
> usage patterns in traces-based data.
>
> In addition, we conduct a parameter study on the trace-free
> data ratio in the curriculum learning, see Appendix C.
>
> 4.3. Trace-based Evaluation
>
> To show the effectiveness of our learning based approach
> as well as dataset, for scenarios with tool execution traces,
> we demonstrate that, once we have trace-based models, for
> a new tool, generating high-quality tool descriptions only
>
> 6
>
> Learning to Rewrite Tool Descriptions for Reliable LLM-Agent Tool Use
>
> Table 1. Trace-free evaluation results on the six subsets of StableToolBench, where no tool execution traces are available at inference
> time. The evaluation metrics are subtask-level (SL) and query-level (QL) success rates. Success means the tool selection is correct and
> execution is successful.
>
> G1 Category
>
> G1 Instruction
>
> G1 Tool
>
> G2 Category
>
> G2 Instruction
>
> G3 Instruction
>
> Overall
>
> SL
>
> QL
>
> SL
>
> QL
>
> SL
>
> QL
>
> SL
>
> QL
>
> SL
>
> QL
>
> SL
>
> QL
>
> SL QL
>
> StableToolBench
>
> Average
>
> Trace-Free+ 73.8 ± 0.7 65.6 ± 1.0 72.6 ± 1.5 60.0 ± 1.0 70.0 ± 1.4 56.4 ± 1.6 68.7 ± 0.7 47.5 ± 0.8 71.4 ± 1.1 48.3 ± 1.6 63.9 ± 1.8 46.4 ± 4.1 70.1 54.0
> 71.8 ± 2.3 62.7 ± 2.1 70.8 ± 0.1 60.8 ± 0.9 68.5 ± 2.7 53.6 ± 2.8 66.4 ± 1.2 44.1 ± 0.0 69.2 ± 4.0 46.4 ± 3.6 59.9 ± 1.2 41.8 ± 1.2 67.8 51.6
> Trace-Free
> 75.5 ± 1.3 64.9 ± 1.3 74.7 ± 0.7 66.1 ± 0.6 68.0 ± 0.6 53.7 ± 0.5 67.9 ± 1.2 43.1 ± 2.4 67.4 ± 1.0 42.9 ± 1.4 45.2 ± 4.2 25.4 ± 3.1 66.5 49.4
> D1
> 73.0 ± 0.3 62.4 ± 1.5 72.8 ± 0.4 62.3 ± 0.9 71.0 ± 0.9 52.8 ± 1.1 68.4 ± 0.3 42.4 ± 1.0 67.8 ± 0.8 43.4 ± 0.6 50.7 ± 0.2 24.6 ± 0.1 67.3 48.0
> D0
> 67.4 ± 1.1 56.9 ± 0.7 69.5 ± 1.2 56.0 ± 2.3 66.4 ± 1.3 47.6 ± 1.0 68.1 ± 0.7 40.4 ± 1.3 68.2 ± 0.6 43.5 ± 1.2 41.4 ± 1.7 17.5 ± 0.9 63.5 43.7
> EasyTool
>
> Table 2. Trace-free evaluation results on RestBench – TMDB and
> Spotify. SL: subtask-level, QL: query-level. No tool execution
> traces are available at inference time.
>
> RestBench
>
> TMDB
>
> Spotify
>
> Method
>
> SL
>
> QL
>
> SL
>
> QL
>
> Trace-Free+
> Trace-Free
> D1
> D0
> EasyTool
>
> 88.1 ± 0.4
> 78.4 ± 1.1
> 78.2 ± 0.1
> 69.8 ± 0.2
> 76.4 ± 0.1
>
> 74.9 ± 0.5
> 57.7 ± 1.2
> 58.0 ± 0.8
> 49.5 ± 0.2
> 52.5 ± 0.0
>
> 68.1 ± 0.3
> 65.0 ± 1.6
> 65.1 ± 0.8
> 57.1 ± 2.9
> 63.4 ± 0.8
>
> 49.3 ± 0.6
> 44.7 ± 2.8
> 45.7 ± 1.8
> 34.9 ± 2.1
> 43.2 ± 0.2
>
> Table 3. Tool-wise improvement against the original description
> D0 for the trace-free setting.
>
> Method
>
> Impr. ↑ (%) Degr. ↓ (%) Avg ∆ ↑
>
> F1 Score
>
> 6.8
> 5.7
> 6.2
> 4.7
>
> 3.4
> 3.9
> 5.7
> 2.3
>
> API Execution Success Rate
>
> 11.5
> 10.8
> 14.1
> 9.6
>
> 11.2
> 11.3
> 13.9
> 10.3
>
> Trace-Free+
> Trace-Free
> D1
> EasyTool
>
> Trace-Free+
> Trace-Free
> D1
> EasyTool
>
> 0.0211
> 0.0113
> 0.0085
> 0.0000
>
> 0.0095
> 0.0059
> 0.0122
> 0.0056
>
> requires tool execution traces collected from single-turn
> tool execution with the original tool descriptions without
> relying on the heavily engineered multi-turn processes in
> the trace-based baselines like DRAFT (Qu et al., 2024) and
> Play2Prompt (Fang et al., 2025).
>
> In trace-based evaluation, we allow the tool description
> generators to have access to tool-use traces collected based
> on the synthetic training queries Qtr(Ats) for the test tools
> Ats, which has no overlap with the test queries Qts, i.e.,
> Qtr(Ats) ∩ Qts = ∅. This reflects the scenarios where
> there is a time gap between when tools become available
> to the side that aims to improve the tool descriptions (e.g.,
> the Rapid API platform) before the users start to use LLM
> agents to call them with their own queries.
>
> 7
>
> 4.4. Tool Scaling Experiments
>
> Benchmarks such as StableToolBench provide a limited set
> of relevant tools for each complex user queries. In prac-
> tice, however, it is often unrealistic to manually restrict the
> candidate set to a small, carefully selected subset for each
> query (Qu et al., 2024). Instead, agents are commonly ex-
> posed to many irrelevant tools, which increases the difficulty
> of tool selection. Here, we study how different versions of
> tool descriptions affect agent performance when the number
> of available tools scales up to the level of 100 tools.
>
> For this setting, we augment each query in StableToolBench
> with additional tool candidates. Specifically, we use the
> tool’s category label to randomly sample extra API providers
> from the same category as the original provider associated
> with the query. Then, we include them as candidate tools.
> We then evaluate accuracy under varying tool descriptions
> when agents are exposed to an increased number of tools.
> Unlike prior tool scaling studies (Qin et al., 2023; Yuan et al.,
> 2025; Qu et al., 2025), which evaluate only the effectiveness
> of a tool retriever as a separate first stage, we directly expose
> the full tool set to the LLM and measure accuracy end-to-
> end. This setting better reflects practical usage and avoids
> a fixed retrieval stage prior to agent execution, which is
> increasingly unnecessary given the large context windows
> supported by modern LLMs 4.
>
> As shown in Fig. 3, we can see the Trace-Free+ model
> is the most robust one against the increasing number of
> tools across different subsets of StableToolBench. Its query
> success drops the least compared to the other methods, main-
> taining a high query-level success rate in most of the cases.
>
> 5. Related Work
>
> Tool-using LLM Agents. Tool-using LLM agents are AI
> systems that combine LLMs (OpenAI, 2024; Google, 2025;
> Yang et al., 2025; Team et al., 2025a) with external tools
> or APIs to extend the model’s capabilities beyond text gen-
> eration (Qin et al., 2023; Schick et al., 2023; Wang et al.,
> 2025). LLMs serve as the controller of the agent (Yao
>
> 4Recent LLMs such as OpenAI GPT-4.1 and Google Gemini
>
> 2.5 Flash support context windows of up to one million tokens.
>
> Learning to Rewrite Tool Descriptions for Reliable LLM-Agent Tool Use
>
> Table 4. Trace-based evaluation results on the six subsets of StableToolBench. The evaluation metric is subtask-level (SL) and query-level
> (QL) success rate. Success means the tool selection is correct and execution is successful.
>
> G1 Category
>
> G1 Instruction
>
> G1 Tool
>
> G2 Category
>
> G2 Instruction
>
> G3 Instruction
>
> Overall
>
> SL
>
> QL
>
> SL
>
> QL
>
> SL
>
> QL
>
> SL
>
> QL
>
> SL
>
> QL
>
> SL
>
> QL
>
> SL QL
>
> StableToolBench
>
> Average
>
> Trace-Based 76.8 ± 1.8 64.5 ± 3.3 75.5 ± 1.5 66.9 ± 2.3 69.1 ± 0.9 54.7 ± 1.2 71.0 ± 1.8 50.7 ± 2.7 68.8 ± 2.0 45.4 ± 2.4 60.7 ± 1.6 45.1 ± 2.1 70.3 54.6
> 75.9 ± 0.8 66.4 ± 1.3 73.4 ± 0.9 62.5 ± 2.1 71.1 ± 0.0 57.3 ± 0.0 70.7 ± 2.5 47.1 ± 5.9 68.2 ± 0.3 43.2 ± 2.6 57.4 ± 0.8 38.3 ± 0.9 69.5 52.5
> D2
> 75.5 ± 1.3 64.9 ± 1.3 74.7 ± 0.7 66.1 ± 0.6 68.0 ± 0.6 53.7 ± 0.5 67.9 ± 1.2 43.1 ± 2.4 67.4 ± 1.0 42.9 ± 1.4 45.2 ± 4.2 25.4 ± 3.1 66.5 49.4
> D1
> 73.0 ± 0.3 62.4 ± 1.5 72.8 ± 0.4 62.3 ± 0.9 71.0 ± 0.9 52.8 ± 1.1 68.4 ± 0.3 42.4 ± 1.0 67.8 ± 0.8 43.4 ± 0.6 50.7 ± 0.2 24.6 ± 0.1 67.3 48.0
> D0
> 73.2 ± 0.4 60.4 ± 1.6 70.0 ± 1.3 58.0 ± 2.6 67.8 ± 1.2 48.5 ± 2.6 66.3 ± 1.4 45.3 ± 5.4 68.2 ± 1.8 44.9 ± 4.3 63.2 ± 0.4 42.6 ± 0.0 68.1 50.0
> DRAFT
> Play2Prompt 74.6 ± 0.4 66.2 ± 1.9 72.0 ± 0.5 62.5 ± 1.5 71.3 ± 0.7 55.2 ± 0.9 66.7 ± 1.1 42.4 ± 1.2 68.0 ± 1.4 43.4 ± 0.7 66.3 ± 1.9 45.1 ± 3.5 69.8 52.5
>
> Figure 3. Scaling experiment results for the trace-free setting on G2 Category, G2 Instruction and G3 Instruction subsets of StableTool-
> Bench. We report query-level (QL) success rate.
>
> et al., 2023), deciding when and how to use tools given
> complex tasks. With external tools, an LLM can retrieve
> up-to-date information, perform calculations, and execute
> code (Huang et al., 2025a). Tools generally fall into two
> broad categories: general-purpose tools and domain-specific
> tools (APIs). General-purpose tools (Team et al., 2025b),
> such as search engines and code interpreters, are designed
> for broad utility and can be applied across many tasks. In
> contrast, domain-specific tools or APIs are tailored for par-
> ticular applications, such as retrieving weather data, man-
> aging to-do lists, or querying specialized databases. These
> APIs typically require structured input arguments and return
> domain-specific outputs, making correct selection and invo-
> cation more challenging. In this work, we focus on domain-
> specific tools. As platforms such as RapidAPI, TMDB, and
> Spotify provide a large number of APIs with real-world re-
> sponses, making accurate and informative tool descriptions
> especially critical for the performance of tool-using agents.
>
> Tool Interface Improvement. Tool interfaces play an im-
> portant role in guiding tool-using agents towards accurate
> tool selection and usage. (Xu et al., 2023) incorporate both
> usage examples and tool descriptions to improve agents.
> However, collecting high-quality tool use examples for each
> tool is challenging while (Hsieh et al., 2023) show that
> tool descriptions can support zero-shot tool usage. Results
> from (Bandlamudi et al., 2025; Chen et al., 2025; Faghih
> et al., 2025) all show the importance of tool descriptions.
> (Chen et al., 2025) add a new role in the chat message for
> tool descriptions to improve tool calling performance. A
> series of work on tool description improvement has been
>
> focusing on prompting-based methods. EasyTool (Yuan
> et al., 2025) summarize three issues of existing tool de-
> scriptions: inconsitency, redundancy, and incompleteness
> and propose a two-step workflow with two carefully de-
> signed prompts to address them. Play2Prompt (Fang et al.,
> 2025) synthesize single-hop queries and uses the tool exe-
> cution traces to improve tool descriptions by prompting a
> strong LLM. DRAFT (Qu et al., 2025) is an iterative work-
> flow that collects traces from synthesized queries and uses
> self-correction ability of LLMs to revise tool descriptions.
> However, they rely heavily on specialized trace collection
> process and improve each tool independently. They cannot
> learn generalizable patterns from a large set of high-quality
> tool descriptions. In addition, DRAFT and Play2Prompt
> cannot handle unseen tools without execution traces.
>
> 6. Conclusion
>
> This work studies how to improve tool-using agents by im-
> proving tool descriptions, with a focus on settings where
> execution traces are unavailable at deployment time. We in-
> troduce a large-scale supervised fine-tuning dataset of high-
> quality tool descriptions derived from real APIs, repaired
> schemas, and carefully synthesized multi-step queries. By
> training LLMs on this dataset, we obtain generalizable tool
> description generators that improve both tool selection and
> parameter generation for unseen tools. Our results across
> RestBench and StableToolBench show consistent gains in
> trace-free and trace-based settings, as well as stronger ro-
> bustness when the number of candidate tools increases.
>
> 8
>
> Learning to Rewrite Tool Descriptions for Reliable LLM-Agent Tool Use
>
> Impact Statement
>
> The proposed method and dataset do not involve personal or
> sensitive data. While improved agent–tool interaction may
> increase automation and efficiency, the potential societal and
> ethical considerations are consistent with those commonly
> associated with LLM-based agent systems, and we do not
> identify risks specific to this work.
>
> References
>
> Bandlamudi, J., Chaudhuri, R., Gantayat, N., Ghosh, S.,
> Mukherjee, K., Agarwal, P., Sindhgatta, R., and Mehta,
> S. A framework for testing and adapting rest apis as llm
> tools. arXiv preprint arXiv:2504.15546, 2025.
>
> Bengio, Y., Louradour, J., Collobert, R., and Weston, J.
> Curriculum learning. In Proceedings of the 26th annual
> international conference on machine learning, pp. 41–48,
> 2009.
>
> Chen, Y.-C., Hsu, P.-C., Hsu, C.-J., and Shiu, D.-s. En-
> hancing function-calling capabilities in llms: Strategies
> for prompt formats, data integration, and multilingual
> translation. In Proceedings of the 2025 Conference of the
> Nations of the Americas Chapter of the Association for
> Computational Linguistics: Human Language Technolo-
> gies (Volume 3: Industry Track), pp. 99–111, 2025.
>
> Faghih, K., Wang, W., Cheng, Y., Bharti, S., Sriramanan,
> G., Balasubramanian, S., Hosseini, P., and Feizi, S. Gam-
> ing tool preferences in agentic llms. arXiv preprint
> arXiv:2505.18135, 2025.
>
> Fang, W., Zhang, Y., Qian, K., Glass, J., and Zhu, Y.
> Play2prompt: Zero-shot tool instruction optimization for
> llm agents via tool play. arXiv preprint arXiv:2503.14432,
> 2025.
>
> Gao, X., Yao, Y., Zhang, Q., Dong, K., Baidya, A., Guo,
> R., Hasson, H., and Das, K. Rimrule: Improving tool-
> using language agents via mdl-guided rule learning. arXiv
> preprint arXiv:2601.00086, 2025.
>
> Google. Gemini 2.5: Pushing the frontier with advanced
> reasoning, multimodality, long context, and next genera-
> tion agentic capabilities, 2025. URL https://arxiv.
> org/abs/2507.06261.
>
> Guo, Z., Cheng, S., Wang, H., Liang, S., Qin, Y., Li, P.,
> Liu, Z., Sun, M., and Liu, Y. Stabletoolbench: Towards
> stable large-scale benchmarking on tool learning of large
> In Findings of the Association for
> language models.
> Computational Linguistics ACL 2024, pp. 11143–11156,
> 2024.
>
> Hsieh, C.-Y., Chen, S.-A., Li, C.-L., Fujii, Y., Ratner, A.,
> Lee, C.-Y., Krishna, R., and Pfister, T. Tool documen-
> tation enables zero-shot tool-usage with large language
> models. arXiv preprint arXiv:2308.00675, 2023.
>
> Huang, K., Zhang, S., Wang, H., Qu, Y., Lu, Y., Roohani,
> Y., Li, R., Qiu, L., Li, G., Zhang, J., et al. Biomni: A
> general-purpose biomedical ai agent. biorxiv, 2025a.
>
> Huang, Y., Chen, Y., Zhang, H., Li, K., Zhou, H., Fang, M.,
> Yang, L., Li, X., Shang, L., Xu, S., et al. Deep research
> agents: A systematic examination and roadmap. arXiv
> preprint arXiv:2506.18096, 2025b.
>
> Hurst, A., Lerer, A., Goucher, A. P., Perelman, A., Ramesh,
> A., Clark, A., Ostrow, A., Welihinda, A., Hayes, A.,
> Radford, A., et al. Gpt-4o system card. arXiv preprint
> arXiv:2410.21276, 2024.
>
> Kwon, W., Li, Z., Zhuang, S., Sheng, Y., Zheng, L., Yu,
> C. H., Gonzalez, J. E., Zhang, H., and Stoica, I. Efficient
> memory management for large language model serving
> with pagedattention. In Proceedings of the ACM SIGOPS
> 29th Symposium on Operating Systems Principles, 2023.
>
> Li, G., Zhou, X., and Zhao, X. Llm for data management.
> Proceedings of the VLDB Endowment, 17(12):4213–4216,
> 2024.
>
> Lu, Y., Ye, F., Li, J., Gao, Q., Liu, C., Luo, H., Du, N., Li,
> X., and Ren, F. Codetool: Enhancing programmatic tool
> invocation of llms via process supervision. arXiv preprint
> arXiv:2503.20840, 2025.
>
> Luo, J., Zhang, W., Yuan, Y., Zhao, Y., Yang, J., Gu, Y., Wu,
> B., Chen, B., Qiao, Z., Long, Q., et al. Large language
> model agent: A survey on methodology, applications and
> challenges. arXiv preprint arXiv:2503.21460, 2025.
>
> OpenAI. Gpt-4 technical report, 2024. URL https://
>
> arxiv.org/abs/2303.08774.
>
> Pan, L., Saxon, M., Xu, W., Nathani, D., Wang, X., and
> Wang, W. Y. Automatically correcting large language
> models: Surveying the landscape of diverse automated
> correction strategies. Transactions of the Association for
> Computational Linguistics, 12:484–506, 2024. doi: 10.
> 1162/tacl_a_00660. URL https://aclanthology.
> org/2024.tacl-1.27/.
>
> Patil, S. G., Zhang, T., Wang, X., and Gonzalez, J. E. Go-
> rilla: Large language model connected with massive apis.
> Advances in Neural Information Processing Systems, 37:
> 126544–126565, 2024.
>
> Peng, B., Li, C., He, P., Galley, M., and Gao, J. Instruc-
> tion tuning with gpt-4. arXiv preprint arXiv:2304.03277,
> 2023.
>
> 9
>
> Learning to Rewrite Tool Descriptions for Reliable LLM-Agent Tool Use
>
> Qi, Z., Liu, X., Iong, I. L., Lai, H., Sun, X., Sun, J., Yang, X.,
> Yang, Y., Yao, S., Xu, W., et al. Webrl: Training llm web
> agents via self-evolving online curriculum reinforcement
> learning. In The Thirteenth International Conference on
> Learning Representations, 2025.
>
> R., Fang, R., Chen, S., Huang, S., Wang, S., Cai, S.,
> Shen, W., Wang, X., Guan, X., Geng, X., Shi, Y., Wu,
> Y., Chen, Z., Li, Z., and Jiang, Y. Tongyi deepresearch
> technical report, 2025b. URL https://arxiv.org/
> abs/2510.24701.
>
> Qin, Y., Liang, S., Ye, Y., Zhu, K., Yan, L., Lu, Y., Lin, Y.,
> Cong, X., Tang, X., Qian, B., Zhao, S., Hong, L., Tian, R.,
> Xie, R., Zhou, J., Gerstein, M., Li, D., Liu, Z., and Sun, M.
> ToolLLM: Facilitating Large Language Models to Master
> 16000+ Real-world APIs. October 2023. URL https:
> //openreview.net/forum?id=dHng2O0Jjr.
>
> Qu, C., Dai, S., Wei, X., Cai, H., Wang, S., Yin, D.,
> Xu, J., and Wen, J.-R. Towards completeness-oriented
> In Proceed-
> tool retrieval for large language models.
> ings of the 33rd ACM International Conference on In-
> formation and Knowledge Management, CIKM ’24,
> pp. 1930–1940, New York, NY, USA, 2024. Associa-
> tion for Computing Machinery. ISBN 9798400704369.
> doi: 10.1145/3627673.3679847. URL https://doi.
> org/10.1145/3627673.3679847.
>
> Qu, C., Dai, S., Wei, X., Cai, H., Wang, S., Yin, D., Xu, J.,
> and Wen, J.-R. From exploration to mastery: Enabling
> llms to master tools via self-driven interactions. In The
> Thirteenth International Conference on Learning Repre-
> sentations, 2025.
>
> Roucher, A., del Moral, A. V., Wolf, T., von Werra, L.,
> and Kaunismäki, E.
> ‘smolagents‘: a smol library to
> build great agentic systems. https://github.com/
> huggingface/smolagents, 2025.
>
> Schick, T., Dwivedi-Yu, J., Dessì, R., Raileanu, R., Lomeli,
> M., Hambro, E., Zettlemoyer, L., Cancedda, N., and
> Scialom, T. Toolformer: Language models can teach
> themselves to use tools. Advances in Neural Information
> Processing Systems, 36:68539–68551, 2023.
>
> Song, Y., Xiong, W., Zhu, D., Wu, W., Qian, H., Song, M.,
> Huang, H., Li, C., Wang, K., Yao, R., et al. Restgpt:
> Connecting large language models with real-world restful
> apis. arXiv preprint arXiv:2306.06624, 2023.
>
> Team, K., Bai, Y., Bao, Y., Chen, G., Chen, J., Chen,
> N., Chen, R., Chen, Y., Chen, Y., Chen, Y., et al.
> Kimi k2: Open agentic intelligence. arXiv preprint
> arXiv:2507.20534, 2025a.
>
> Team, T. D., Li, B., Zhang, B., Zhang, D., Huang, F., Li, G.,
> Chen, G., Yin, H., Wu, J., Zhou, J., Li, K., Su, L., Ou,
> L., Zhang, L., Xie, P., Ye, R., Yin, W., Yu, X., Wang, X.,
> Wu, X., Chen, X., Zhao, Y., Zhang, Z., Tao, Z., Zhang,
> Z., Qiao, Z., Wang, C., Yu, D., Fu, G., Shen, H., Yang,
> J., Lin, J., Zhang, J., Zeng, K., Yang, L., Yin, H., Song,
> M., Yan, M., Liao, M., Xia, P., Xiao, Q., Min, R., Ding,
>
> 10
>
> Wang, J., Ma, Z., Li, Y., Zhang, S., Chen, C., Chen, K., and
> Le, X. Gta: A benchmark for general tool agents, 2024.
> URL https://arxiv.org/abs/2407.08713.
>
> Wang, M., Zhang, Y., Yu, B., Hao, B., Peng, C., Chen, Y.,
> Zhou, W., Gu, J., Zhuang, C., Guo, R., et al. Function
> calling in large language models: Industrial practices,
> challenges, and future directions. ACM Computing Sur-
> veys, 2025.
>
> Xu, Q., Hong, F., Li, B., Hu, C., Chen, Z., and Zhang,
> J. On the tool manipulation capability of open-source
> large language models. arXiv preprint arXiv:2305.16504,
> 2023.
>
> Xu, Z., Soria, A. M., Tan, S., Roy, A., Agrawal, A. S.,
> Poovendran, R., and Panda, R. Toucan: Synthesiz-
> ing 1.5m tool-agentic data from real-world mcp envi-
> ronments, 2025. URL https://arxiv.org/abs/
> 2510.01179.
>
> Yang, A., Li, A., Yang, B., Zhang, B., Hui, B., Zheng, B.,
> Yu, B., Gao, C., Huang, C., Lv, C., et al. Qwen3 technical
> report. arXiv preprint arXiv:2505.09388, 2025.
>
> Yang, K., Liu, Y., Chaudhary, S., Fakoor, R., Chaudhari,
> P., Karypis, G., and Rangwala, H. Agentoccam: A sim-
> ple yet strong baseline for llm-based web agents. arXiv
> preprint arXiv:2410.13825, 2024.
>
> Yao, S., Zhao, J., Yu, D., Du, N., Shafran, I., Narasimhan,
> K. R., and Cao, Y. React: Synergizing reasoning
> In The Eleventh In-
> and acting in language models.
> ternational Conference on Learning Representations,
> 2023. URL https://openreview.net/forum?
> id=WE_vluYUL-X.
>
> Yuan, S., Song, K., Chen, J., Tan, X., Shen, Y., Ren, K., Li,
> D., and Yang, D. Easytool: Enhancing llm-based agents
> with concise tool instruction. In Proceedings of the 2025
> Conference of the Nations of the Americas Chapter of
> the Association for Computational Linguistics: Human
> Language Technologies (Volume 1: Long Papers), pp.
> 951–972, 2025.
>
> Zhang, K., Li, J., Li, G., Shi, X., and Jin, Z. Codeagent:
> Enhancing code generation with tool-integrated agent sys-
> tems for real-world repo-level coding challenges. arXiv
> preprint arXiv:2401.07339, 2024.
>
> Learning to Rewrite Tool Descriptions for Reliable LLM-Agent Tool Use
>
> A. Implementation Details
>
> A.1. Detailed Agentic Tool Annotator
>
> The prompt of the agentic tool annotator can be found below.
>
> Agentic Tool Annotator
>
> <system_prompt>
> You are an agent that explores APIs to evaluate their health and discover working call patterns. You work in an Action and
> Observation loop until you return the final answer.
>
> What you have
> 1) The JSON string of the current MCP schema for one API provider (initially).
> 2) A set of tools (APIs) defined by that schema that you can call to get concrete feedback.
> 3) Generic utilities that annotate the schema with health labels and successful call examples.
>
> Your goal
> - For each API in the provider, actively explore how to call it successfully.
> - Use both the schema to infer true parameter names, types, and constraints.
> - Adapt your calls when you see errors, instead of giving up after a single failure.
> - After a reasonable amount of exploration for each API, decide its health and record at least one successful example call when
> possible.
>
> What to annotate
> - You must not change any tool name or delete tools.
> - You should not rewrite the schema; instead, you infer how to call each API in practice.
> - For each API, use ‘utility_annotate_health‘ to set:
>
> - ‘health = "good"‘ if you can find at least one meaningful, repeatable, successful call that returns plausible data.
> - ‘health = "bad"‘ if, after careful attempts and adapting to error messages, all calls fail due to issues you cannot fix from
> the client side (for example, persistent authorization errors, missing server configuration, 404 for the endpoint, or fundamentally
>
> broken behavior).
>
> - ‘health = "unknown"‘ if you cannot confidently determine whether the API works (for example, ambiguous or inconsistent errors,
>
> or not enough steps left to explore).
> - When you mark an API as ‘"good"‘, you should, whenever possible, also call ‘utility_annotate_example‘ to store one or more
> concrete successful call examples.
>
> - The ‘example‘ input must be a JSON string representing a list of argument objects, such as ‘[{"param1": "value1"}, {"param1": "
>
> value2", "param2": 3}]‘.
>
> - Each object corresponds to a full set of arguments that you actually used in a successful call.
> - Prefer 1-3 diverse, minimal, safe examples that future agents can reuse directly.
>
> How to explore APIs
> - Prefer live Observations over assumptions.
> - If a call fails with "Missing required parameter X" or similar, try again including that parameter.
> - If a call fails with "Unexpected parameter Y" or type errors, adjust or remove that parameter.
> - When behavior is unclear, run a minimal, low-risk test call to probe the interface rather than guessing wildly.
> - Be efficient: you have a limited number of tool calls. Do not brute-force huge parameter spaces. Instead, reason about likely
> values based on descriptions.
>
> Protocol
> - Every step you take is an Action. An Action is a JSON blob of the form:
> Action:
> {
>
> "name": "<tool_name>",
> "arguments": <tool_input>
>
> }
> The "arguments" field must match what the tool expects. For most tools it is an object; for tools that accept a single value, it
> can be a raw value such as a string or number.
> - Use the utility tools to write your findings back into the schema:
>
> - ‘utility_annotate_health‘: Record the health label and a concise reason for each API.
> - ‘utility_annotate_example‘: Record JSON examples of successful calls for APIs you understand well.
>
> - After each Action, you will receive an Observation. Treat it as ground truth. The Observation may be plain text or structured
> JSON. Use it to decide the next Action.
> - Use only listed tools. Do not invent tool names or parameters. Pass literal values, not variable names.
>
> Required loop
> 1) Inspect the current schema to list all APIs you need to evaluate.
> 2) For each API, design and execute a small sequence of test calls to discover a working call (or to conclude that the API is
> broken or uncertain).
> 3) Update your calling strategy for that API whenever you observe new errors or unexpected behavior.
> 4) Once you have enough evidence, annotate the API’s health and, if possible, record successful call examples using the utility
> tools.
> 5) Repeat until all APIs in the schema are annotated.
> 6) End by calling the "final_answer" tool with a concise summary of what you annotated.
>
> Output and completion
> - You must finish by calling the "final_answer" tool. It is the only way to complete the task.
> - The "final_answer" tool will automatically validate and save the annotated schema.
>
> Examples
> Task: "Evaluate APIs and annotate their health"
> Action:
> {
>
> "name": "some_api",
> "arguments": {"parameter1": "value1"}
>
> }
> Observation: "{response: ...successful result...}"
>
> 11
>
> Learning to Rewrite Tool Descriptions for Reliable LLM-Agent Tool Use
>
> Action:
> {
>
> "name": "utility_annotate_health",
> "arguments": {"api_name": "some_api", "health": "good", "reason": "Successfully called with parameter1=value1 and obtained
>
> plausible results."}
> }
> Observation: "Health for API ’some_api’ annotated."
> Action:
> {
>
> "name": "utility_annotate_example",
> "arguments": {"api_name": "some_api", "example": "[{\"parameter1\": \"value1\"}]"}
>
> }
> Observation: "Example for API ’some_api’ annotated."
> Action:
> {
>
> "name": "final_answer",
> "arguments": "Annotated health and examples for all APIs."
>
> }
>
> Task: "Handle ambiguous or failing APIs"
> Action:
> {
>
> "name": "another_api",
> "arguments": {"paramA": "val"}
>
> }
> Observation: "Error: Missing required parameter ’paramB’"
> Action:
> {
>
> "name": "another_api",
> "arguments": {"paramA": "val", "paramB": 10}
>
> }
> Observation: "Error: 401 Unauthorized"
> Action:
> {
>
> "name": "utility_annotate_health",
> "arguments": {"api_name": "another_api", "health": "bad", "reason": "Repeated calls with corrected parameters still return server
>
> -side authorization errors."}
> }
> Observation: "Health for API ’another_api’ annotated."
> Action:
> {
>
> "name": "final_answer",
> "arguments": "Annotated health as ’bad’ for failing APIs where client-side fixes do not help."
>
> }
>
> Available tools
> {%- for tool in tools.values() %}
> - {{ tool.to_tool_calling_prompt() }}
> {%- endfor %}
>
> Rules you must follow
> 1) Always provide a tool call. If you are answering, call "final_answer".
> 2) Use only the arguments the tool expects. Pass literal values, not variable names.
> 3) Do not repeat an identical tool call with the exact same arguments.
> 4) Prefer evidence from Observations. If information is missing, probe with a minimal call.
>
> Now Begin!
> </system_prompt>
>
> <user_prompt>
> Evaluate and annotate the health of each API based on the schema by actively interacting with the tools.
>
> The schema you are given is:
> {{schema}}
> </user_prompt>
>
> A.2. Detailed User Query Synthesis Procedure
>
> This section provides a detailed description of the user query synthesis process.
>
> Target Query Properties. High-quality synthetic queries must satisfy three properties. First, queries should sound natural
> and reflect how real users describe tasks, rather than exposing explicit tool usage or step-by-step instructions. Second,
> queries must require multiple tool calls to complete, such that no single API invocation suffices. Third, the required tool
> calls must exhibit dependency relationships, where later calls depend on the outputs of earlier ones, enforcing non-trivial
> planning and intermediate result handling.
>
> Base Pipeline. We partially adopt the query synthesis pipeline from TOUCAN (Xu et al., 2025), which emphasizes
> realism, linguistic quality, and multi-tool reasoning. Similar to TOUCAN, we prompt an LLM with tool schemas and
> descriptions to generate candidate queries under constraints that exclude trivial or single-step tasks. However, our approach
> differs in how tool combinations are selected and how dependencies are enforced.
>
> 12
>
> Learning to Rewrite Tool Descriptions for Reliable LLM-Agent Tool Use
>
> Dependency-Aware Query Construction.
> In addition to schema information, we leverage API calling histories collected
> during seed tool annotation. These histories reveal common call orders, data flow patterns, and functional relationships
> between APIs within the same provider. We explicitly prompt the LLM to analyze these relationships before generating
> queries.
>
> Concretely, for each API provider, the LLM is instructed to select three APIs whose functionalities exhibit clear dependency
> structure, such as retrieval followed by transformation or filtering followed by aggregation. The model first produces a brief
> dependency analysis describing how these APIs interact, and then generates a single user query that implicitly requires
> invoking all selected APIs in the correct order. Tool names and execution details are omitted from the query text to preserve
> naturalness.
>
> Outcome. By grounding query synthesis in real API usage traces and explicit dependency reasoning, this process produces
> queries that are both linguistically natural and structurally challenging. These queries reliably induce multi-step tool-use
> trajectories with meaningful inter-call dependencies, which are critical for supervising and evaluating advanced tool-using
> LLM agents.
>
> A.3. Detailed Traces and Improved Description Generation
>
> This section provides a detailed description of how execution traces are collected and how they are used to generate improved
> tool descriptions D1 and D2.
>
> Trace Collection. The synthesized user queries are designed to require multi-step tool use with explicit dependencies
> between APIs. We execute a tool-using agent on these queries and record full execution traces, including intermediate
> reasoning steps, tool calls, tool responses, and termination states. For each query, we retain both successful traces and
> failure traces, where failures include incorrect tool selection, invalid argument construction, premature termination, or
> unrecoverable tool errors.
>
> We associate each failure trace with its corresponding ground-truth tool sequence, enabling direct comparison between
> incorrect and correct executions. This comparison allows us to identify whether failures arise from missing information in
> the tool description, unclear argument semantics, or undocumented usage constraints.
>
> Data-Independent Description Improvement. Starting from the original tool description D0, we first generate a data-
> independent improved description D1. This step applies general guidelines for tool description writing, including: clearly
> stating the tool’s intent, specifying required versus optional parameters, documenting expected input formats, describing
> output semantics, and clarifying common error conditions. These guidelines are initialized from publicly available tool-use
> best practices5 and iteratively refined by measuring downstream agent performance when consuming D1. The prompt used
> to generate D1 below.
>
> Trace-Driven Rule Extraction. To incorporate execution-specific information, we further refine descriptions using rules
> extracted from traces. We adopt the RIMRULE framework (Gao et al., 2025), which compares failed traces against their
> corresponding ground-truth executions to identify root-cause reasoning errors. These errors are distilled into compact,
> generalizable rules that describe correct tool usage under specific conditions, such as required call ordering, necessary
> preconditions, or constraints on argument construction. The resulting rules form a reusable rule library derived from
> observed agent behavior.
>
> Trace-Aware Description Generation. For each tool, we retrieve the subset of rules relevant to that tool and combine
> them with its D1 description to generate a final description D2. Unlike D1, which is independent of execution context, D2
> explicitly encodes behavioral constraints grounded in observed failures and successes. This process produces descriptions
> that are tailored to the actual usage patterns of each tool while remaining general enough to apply across different queries.
>
> The final D2 descriptions are used as supervision for supervised fine-tuning of the description generator.
>
> 13
>
> Learning to Rewrite Tool Descriptions for Reliable LLM-Agent Tool Use
>
> Table 5. Descriptive statistics of RestBench and StableToolBench for evaluation. For StableToolBench, we only consider their solvable
> queries (Guo et al., 2024).
>
> Dataset
>
> Queries Tools Tools per Query
>
> TMDB
> Spotify
>
> RestBench
> 54
> 40
>
> 100
> 57
>
> StableToolBench
>
> G1 Category
> G1 Instruction
> G1 Tool
> G2 Category
> G2 Instruction
> G3 Instruction
>
> 153
> 163
> 158
> 124
> 105
> 61
>
> 364
> 820
> 500
> 433
> 595
> 44
>
> 54
> 40
>
> 4.21
> 5.29
> 5.03
> 5.90
> 6.49
> 5.77
>
> B. Experiment Setup Details
>
> Here, we present additional details about the experiments for better understanding and reproducibility.
>
> B.1. Teacher-forcing Evaluation
>
> The teacher-forcing evaluation begins with a task decomposition step, adopted from DRAFT (Qu et al., 2024), to obtain a
> set of subtasks and their dependencies given a query. Each subtask requires no more than one tool to solve. Then, for each
> subtask, we perform the following steps: subtask-level tool selection annotation, tool selection, tool execution, and tool
> response processing. Subtask-level evaluation metrics are computed based on the results of tool selection and tool execution.
> For the concern of budget, we use GPT-41 (2025-05-14) as our tool-using agent in all the experiments.
>
> Subtask Tool Selection Annotation. For calculation of tool selection accuracy on subtask and query-level and F1 score
> on tool-level, we annotated the ground truth API tool for each subtask using GPT-41, which also judges whether a subtask
> needs a tool or not. We manually checked correctness on 100 randomly selected subtasks, the annotation is correct in 96
> cases. The prompt of subtask tool selection annotation can be found below.
>
> Subtask Tool Selection Annotation
>
> <system_prompt>
> You are an expert at analyzing task decomposition and determining whether subtasks require external API calls.
> </system_prompt>
>
> <user_prompt>
> TASK: Analyze whether a subtask requires an API call or is just data processing.
>
> CONTEXT:
> - Original Query: {original_query}
> - Subtask Input: {subtask_input}
> - Previous Context: {previous_context}
> - Available APIs: {tool_info}
>
> INSTRUCTIONS:
> 1. Analyze the subtask input to understand what it’s trying to accomplish
> 2. Consider whether the subtask needs to fetch NEW data from external sources
> 3. Determine if the subtask is just processing/analyzing data that’s already available
>
> CRITERIA for API NEED:
> - The subtask needs to SEARCH for, FIND, GET, or RETRIEVE information
> - The subtask needs to access external data sources
> - The subtask cannot be completed with just the data from previous steps
> - The subtask involves making requests to external services or databases
>
> CRITERIA for NO API NEED (Processing Step):
> - The subtask only processes/analyzes data from previous steps
> - The subtask involves counting, filtering, selecting, comparing, or organizing existing data
> - The subtask uses phrases like "from the list", "from the results", "based on the", "select one", etc.
> - The subtask can be completed using only the information already gathered
> - The subtask involves logical operations, calculations, or data manipulation on existing data
>
> 5https://platform.claude.com/docs/en/agents-and-tools/tool-use/implement-tool-use#best-practices-for-tool-definitions
>
> 14
>
> Learning to Rewrite Tool Descriptions for Reliable LLM-Agent Tool Use
>
> OUTPUT FORMAT:
> Respond with a JSON object containing:
> {{
>
> "needs_api": true/false,
> "reasoning": "Detailed explanation of your decision",
> "confidence": 0.0-1.0,
> "api_name": "Name of the API if needed, or empty string if not needed"
>
> }}
>
> EXAMPLES:
> - Subtask: "Search for movies with Tom Hanks" -> needs_api: true, api_name: "search_movies"
> - Subtask: "Count how many are comedies from the results" -> needs_api: false, api_name: ""
> - Subtask: "Select the highest rated movie from the list" -> needs_api: false, api_name: ""
> - Subtask: "Get movie details for the selected movie" -> needs_api: true, api_name: "get_movie_details"
> - Subtask: "Compare the ratings of the top 3 movies" -> needs_api: false, api_name: ""
> - Subtask: "Find similar movies to the selected one" -> needs_api: true, api_name: "get_similar_movies"
>
> Now analyze the given subtask and provide your judgment.
> </user_prompt>
>
> Tool Selection, Execution, and Response Processing. These three steps are performed by the tool-using agent model
> based on the following prompts below. Basically, in both tool selection and execution, the tool descriptions generated by
> different methods are injected to the prompts in the corresponding section marked by tools_info. After the response is
> processed, the result is fed into context of the next subtask as its context.
>
> Subtask Tool Selection
>
> <system_prompt>
> You are an expert API selector. Given a user query for a specific subtask and available tools/APIs, you need to select exactly ONE
> most appropriate API to handle this subtask.
> </system_prompt>
>
> <user_prompt>
> Available Tools and APIs:
> {tools_info}
>
> Your task:
> 1. Analyze the subtask query and the "subtask_output" in the Context Section to understand what specific information is needed
> 2. Select exactly ONE API from the available tools that is most appropriate for this subtask
> 3. Focus on the current subtask only - don’t consider future steps
>
> ### Context Section
> {context_section}
>
> ### Subtask Query
> {query}
>
> Important: You must select exactly ONE API that is most appropriate for this specific subtask.
>
> You must respond in JSON format with exactly one selected API:
> {{
>
> "selected_api": {{
>
> "reasoning": "why this specific API was selected for this subtask",
> "api_name": "api_name_here",
>
> }}
>
> }}
> </user_prompt>
>
> Subtask Tool Execution (Parameter Generation)
>
> <system_prompt>
> You are a helpful assistant that generates parameters for an API call.
> </system_prompt>
>
> <user_prompt>
> Given a subtask and an API and its description, you need to first write your reasoning step by step in plain text about how to
> extract the correct parameters. After reasoning, you must then output the final parameters in strict JSON format according to the
> API description.
>
> Please note that:
>
> The API description can help you better understand the use of the API.
>
> Ensure the parameters you output are correct. The output must contain the required parameters, and may contain the optional
> parameters if needed. If no parameters exist in the required and optional parameters, just leave it as {{"Parameters":{{}}}}.
>
> If the subtask mentions other APIs, you should ONLY consider the API description I give and do not consider other APIs.
>
> 15
>
> Learning to Rewrite Tool Descriptions for Reliable LLM-Agent Tool Use
>
> Parameter Extraction from Previous Context: When the API requires path parameters (like person_id, movie_id, tv_id, company_id, etc
> .), you may have to extract them from the subtask_output of previous steps if they are missing from the subtask input. Try to
> extract the numeric ID values from these text descriptions and use them as the corresponding path parameters.
>
> You must ONLY output in a parsable JSON format for the final answer, with no extra explanations, notes, or comments after it.
>
> The output must have two parts:
>
> "Reasoning": your step-by-step reasoning as plain text.
>
> "Parameters": the final extracted parameters in JSON format.
>
> An example output looks like:
>
> {{
>
> "Reasoning": "The subtask asks for person details. The required parameter is person_id. From previous_log, I see that person_id
>
> is 190. Therefore, the correct parameter is person_id=190.",
>
> "Parameters": {{
>
> "person_id": 190
>
> }}
>
> }}
>
> There are logs of previous questions and answers:
> {previous_log}
>
> This is API tool documentation:
> {api_instruction}
>
> This is the current subtask:
> {question}
>
> Output:
> </user_prompt>
>
> Subtask Tool Response Processing
>
> <system_prompt>
> You are a helpful assistant.
> </system_prompt>
>
> <user_prompt>
> You should answer the question based on the response output by the API tool.
>
> Please note that:
> 1. Try to organize the response into a natural language answer.
> 2. We will not show the API response to the user, thus you need to make full use of the response and give the information in the
> response that can satisfy the user’s question in as much detail as possible.
> 3. The question may have dependencies on answers of other questions, so we will provide logs of previous questions and answers.
>
> There are logs of previous questions and answers:
> {context_section}
>
> This is the user’s question: {subtask query}
>
> This is the response output by the API tool:
> {call_result}
> ...
> </user_prompt>
>
> Evaluation Metrics For the tool-level F1 score, precision and recall are defined as Prec = T P
> T P +F N .
> A true positive (TP) corresponds to a tool that is both part of the ground truth and selected; a false positive (FP) is a selected
> tool that is not in the ground truth; and a false negative (FN) is a ground-truth tool that is not selected.
>
> T P +F P , Recall = T P
>
> B.2. StableToolBench Parameter Schema Correction
>
> This section describes the preprocessing procedure used to correct parameter schemas in StableToolBench.
>
> We observe that a subset of tool parameter schemas in StableToolBench does not accurately reflect the true API requirements.
> Common issues include missing required parameters, inclusion of unsupported parameters, and incorrect parameter types.
> When such schemas are used during evaluation, tool invocations can fail with server-side errors, even when the model selects
> the correct tool and follows a reasonable call pattern. These failures introduce noise into benchmark results and confound
> comparisons between methods.
>
> To address this issue, we connect StableToolBench to Smolagents (Roucher et al., 2025) and programmatically invoke each
> tool in an iterative manner. For each API, we examine server responses to identify mismatches between the declared schema
>
> 16
>
> Learning to Rewrite Tool Descriptions for Reliable LLM-Agent Tool Use
>
> and actual API behavior. Based on these observations, we revise parameter definitions to align with the true requirements
> enforced by the server, including parameter presence and type constraints.
>
> By correcting these schema-level inconsistencies, we eliminate a class of evaluation failures that are unrelated to model
> capability. This preprocessing step improves the stability and interpretability of StableToolBench results and enables more
> reliable assessment of tool-use performance. The prompt of the parameter fixing agent can be found below.
>
> Schema Parameter Fixing
>
> <system_prompt>
> You are an agent that rewrites a tool’s schema so future tool calls succeed. You work in an Action and Observation loop until you
> return the final answer.
>
> What you have
> 1) The JSON string of the current schema that you will rewrite (initially).
> 2) A set of tools defined by that schema that you can call to get concrete feedback.
> 3) Generic utilities that help edit the schema incrementally.
> 4) The interactive history of past tool calls and their results.
>
> What to change
> - You may change a tool’s description and parameters.
> - You must not change any tool name. You must not change the structure of the schema.
> - Add types, defaults, value ranges, enums, and constraints when the history shows they are needed.
> - Make hidden requirements explicit in the description and parameter docs.
> - Rewrite the API provider description and API descriptions to be clear and helpful for future LLM function calls.
>
> How to write the description
> Start with a one-sentence plain summary of what the tool does and the problem it solves. Then document:
> - Inputs: each parameter with type, required/optional, default, min/max, allowed values, and formatting rules.
> - Data model: shape of nested objects or arrays; limits on size or length; paging or cursors if present.
> - Outputs: what the tool returns and what it does not return, including common items a caller might expect but are not provided.
> - Primary use cases: the common ways the tool is used.
> - Non-use cases: when the tool should not be used.
>
> How to decide changes
> - Prefer observed behavior from the history over assumptions. If a call failed with "Missing required parameter X," make X required
>
> and document it.
>
> - If a call failed with "Unexpected parameter Y," remove or rename Y to match the actual interface.
> - When behavior is unclear, run a minimal tool call to probe the interface rather than guessing.
> - Keep backward compatibility with prior successful calls when possible.
>
> Protocol
> - Every step you take is an Action. An Action is a JSON blob of the form:
>
> Action:
> {
>
> "name": "<tool_name>",
> "arguments": <tool_input>
>
> }
> The "arguments" field must match what the tool expects. For most tools it is an object; for tools that accept a single value, it
>
> can be a raw value such as a string or number.
> - Use the utility tools to update the schema incrementally.
>
> - ‘utility_update_provider_description‘: Update the provider’s description.
> - ‘utility_update_api_description‘: Update an API’s description.
> - ‘utility_update_api_parameters‘: Update an API’s parameters (JSON string).
> - ‘utility_remove_api_parameters‘: Remove the ’parameters’ field from an API (making it accept no parameters).
> - ‘utility_print_schema‘: See the current state of the schema.
>
> - After each Action, you will receive an Observation. Treat it as ground truth. The Observation may be plain text or structured
> JSON. Use it to decide the next Action.
> - Use only listed tools. Do not invent tool names or parameters. Pass literal values, not variable names.
>
> Required loop
> 1) Inspect the current schema and the history.
> 2) Exercise the tool(s) with targeted calls to reveal true parameter names, required fields, and constraints.
> 3) Edit the schema incrementally using the utility tools to reflect observed behavior.
> 4) Validate by re-running the previously failing calls until they succeed or until you reach the real limits of the tool.
> 5) End with the final answer tool.
>
> Output and completion
> - You must finish by calling the "final_answer" tool. It is the only way to complete the task.
> - The "final_answer" tool will automatically save the schema.
>
> Examples
> Task: "Rewrite the schema based on the log"
> Action:
> {
>
> "name": "some_tool_in_schema",
> "arguments": {"parameter1": "value1"}
>
> }
> Observation: "TypeError: some_tool_in_schema() takes 0 positional arguments but 1 was given"
> Action:
> {
>
> "name": "utility_remove_api_parameters",
> "arguments": {"api_name": "some_tool_in_schema"}
>
> }
> Observation: "Parameters field removed from API ’some_tool_in_schema’."
> Action:
>
> 17
>
> Learning to Rewrite Tool Descriptions for Reliable LLM-Agent Tool Use
>
> Table 6. Descriptive statistics of the dataset we created for tool interface improvement including massive synthesized quries, improved
> tool descriptions, and fixed paramters. Each API tool in this dataset returns real API response.
>
> Dataset Queries
>
> Tools
>
> Tools per Query
>
> Split A
> Split B
>
> Synthesized SFT Data
> 4,585
> 4,726
> 991
> 2,189
>
> 6.81
> 9.21
>
> {
>
> "name": "some_tool_in_schema",
> "arguments": {}
>
> }
> Observation: "{response: ...}"
> Action:
> {
>
> "name": "final_answer",
> "arguments": "The schema has been rewritten."
>
> }
>
> Task: "Update parameters"
> Action:
> {
>
> "name": "another_tool",
> "arguments": {"paramA": "val"}
>
> }
> Observation: "Missing required parameter: paramB"
> Action:
> {
>
> "name": "utility_update_api_parameters",
> "arguments": {
>
> "api_name": "another_tool",
> "parameters_json": "{\"paramA\": {\"type\": \"string\", \"required\": true, \"description\": \"...\"}, \"paramB\": {\"type\":
>
> \"string\", \"required\": true, \"description\": \"...\"}}"
>
> }
>
> }
> Observation: "Parameters for API ’another_tool’ updated."
> Action:
> {
>
> "name": "final_answer",
> "arguments": "Updated parameters."
>
> }
>
> Task: "Clarify API description"
> Action:
> {
>
> "name": "utility_update_api_description",
> "arguments": {
>
> "api_name": "complex_tool",
> "description": "This tool calculates the mortgage payment. Inputs: ’principal’ (number, required), ’rate’ (number, required,
>
> annual interest rate in percentage), ’years’ (number, required, loan term). Output: Monthly payment amount."
>
> }
>
> }
> Observation: "Description for API ’complex_tool’ updated."
> Action:
> {
>
> "name": "final_answer",
> "arguments": "Updated API description to be more clear."
>
> }
>
> Available tools
> {%- for tool in tools.values() %}
> - {{ tool.to_tool_calling_prompt() }}
> {%- endfor %}
>
> Rules you must follow
> 1) Always provide a tool call. If you are answering, call "final_answer".
> 2) Use only the arguments the tool expects. Pass literal values, not variable names.
> 3) Do not repeat an identical tool call with the exact same arguments.
> 4) Prefer evidence from Observations and the history over guesses. If information is missing, probe with a minimal call.
>
> Now Begin!
> </system_prompt>
>
> <user_prompt>
> Rewrite the schema of the tool based on the log below and interacting with the tools.
>
> The schema you are given is:
> {{schema}}
> </user_prompt>
>
> 18
>
> Learning to Rewrite Tool Descriptions for Reliable LLM-Agent Tool Use
>
> Table 7. Parameter Study for Trace-Free+ in Trace-free Evaluation
>
> StableToolBench
>
> G1 Category
>
> G1 Instruction
>
> G1 Tool
>
> G2 Category
>
> G2 Instruction
>
> G3 Instruction
>
> Trace-free Ratios
>
> SL
>
> QL
>
> SL
>
> QL
>
> SL
>
> QL
>
> SL
>
> QL
>
> SL
>
> QL
>
> SL
>
> QL
>
> (0.1, 0.9)
> (0.3, 0.7)
> (0.5, 0.5)
>
> 73.8 ± 0.7
> 73.7 ± 1.9
> 75.8 ± 0.0
>
> 65.6 ± 1.0
> 63.6 ± 2.8
> 66.0 ± 0.0
>
> 72.6 ± 1.5
> 73.2 ± 2.3
> 71.1 ± 0.0
>
> 60.0 ± 1.0
> 61.3 ± 4.3
> 64.3 ± 0.0
>
> 70.0 ± 1.4
> 68.3 ± 1.1
> 69.2 ± 0.0
>
> 56.4 ± 1.6
> 52.8 ± 0.7
> 55.6 ± 0.0
>
> 68.7 ± 0.7
> 68.6 ± 0.0
> 65.9 ± 0.0
>
> 47.5 ± 0.8
> 47.9 ± 0.6
> 48.3 ± 0.0
>
> 71.4 ± 1.1
> 69.1 ± 2.9
> 68.9 ± 0.0
>
> 48.3 ± 1.6
> 45.4 ± 3.6
> 44.9 ± 0.0
>
> 63.9 ± 1.8
> 61.1 ± 3.0
> 59.8 ± 0.0
>
> 46.4 ± 4.1
> 41.8 ± 3.5
> 39.3 ± 0.0
>
> Trace-Free
>
> 71.8 ± 2.3
>
> 62.7 ± 2.1
>
> 70.8 ± 0.1
>
> 60.8 ± 0.9
>
> 68.5 ± 2.7
>
> 53.6 ± 2.8
>
> 66.4 ± 1.2
>
> 44.1 ± 0.0
>
> 69.2 ± 4.0
>
> 46.4 ± 3.6
>
> 59.9 ± 1.2
>
> 41.8 ± 1.2
>
> B.3. Training and Inference Details
>
> All experiments are conducted on a single cloud node equipped with 8 × NVIDIA A100 (80GB) GPUs. For SFT, we
> develop based on the FSDP SFT Trainer of the verl library6 to optimize training efficiency and streamline checkpoint saving
> and conversion. The SFT hyperparameters are shown in Table 8. For inference, we leverage vLLM (Kwon et al., 2023) for
> efficiency and perform top-p sampling with temperature 0.3, top-p 0.9, repetition_penalty 1.1.
>
> We fine-tune Qwen3-4B-Instruct-25077 due to its strong instruction following ability with split B of our synthesized dataset
> to make split A and the test queries unseen during training.
>
> Parameter
>
> SFT
>
> Base Model
> Hardware
> Optimizer
> Learning Rate
> LR Scheduler
> Training Epochs
> LoRA Rank
> Precision
> Max Length
> Effective Batch Size
> DeepSpeed Stage
>
> Qwen3-4B-Instruct-2507
> 1 × 8-A100 GPU Node
> AdamW
> 5.0 × 10−5
> Cosine
> 2.0
> 64
> bf16
> 2,048
> 8
> ZeRO-3
>
> Table 8. Hyperparameters for SFT.
>
> The prompts for Trace-Free+, Trace-Free, and Trace-Based are shown below.
>
> Prompt for Trace-Free+ and Trace-Free
>
> <system_prompt>
> You are an API documentation specialist.
> </system_prompt>
>
> <user_prompt>
>
> Rewrite the API description so an AI agent can:
> 1) Decide when to use this API
> 2) Generate valid parameters
>
> Inputs:
> - API name: {tool_name}
> - Parameter schema: {parameter_json}
> - Baseline description: {original_description}
>
> Infer (do not output):
> - When to use vs not use this API
> - Required vs optional parameters
> - Parameter meanings and constraints
> - Cross-parameter dependencies or exclusions
> - Common parameter mistakes
>
> - no examples are provided, infer from the schema and baseline description only
>
> Write a clear API description that:
> - States when to use and NOT use the API
> - Does not invent or reference non-provided APIs
> - Explains each parameter’s meaning, type, required/optional status, constraints, and defaults
>
> 6https://github.com/volcengine/verl
> 7https://huggingface.co/Qwen/Qwen3-4B-Instruct-2507
>
> 19
>
> Learning to Rewrite Tool Descriptions for Reliable LLM-Agent Tool Use
>
> - Describes likely validation failures and how to avoid them
> - Abstracts patterns into general rules
> - Does not restate the full schema verbatim
> - Does not mention whether examples were provided
>
> You may replace the baseline description entirely.
>
> Output ONLY valid JSON (no markdown, no code blocks):
> {{"description": "<your improved API description here>"}}
>
> </user_prompt>
>
> Prompt for Trace-Based
>
> <system_prompt>
> You are an API documentation specialist.
> </system_prompt>
>
> <user_prompt>
> Rewrite the API description so an AI agent can:
> 1) Decide when to use this API
> 2) Generate valid parameters
>
> Inputs:
> - API name: {tool_name}
> - Parameter schema: {parameter_json}
> - Example queries + errors: {query_examples}
> - Baseline description: {original_description}
>
> Infer (do not output):
> - When to use vs not use this API
> - Common parameter mistakes
> - Required vs optional parameters
> - Cross-parameter constraints
>
> Write a clear API description that:
> - States when to use and NOT use the API
> - Does not invent other APIs
> - Explains each parameter’s meaning, type, required/optional status, constraints, and defaults
> - Describes common validation failures and how to avoid them
> - Abstracts examples into general rules
> - Does not restate the full schema or copy examples
>
> You may replace the baseline entirely.
>
> Output ONLY valid JSON (no markdown, no code blocks):
> {{"description": "<your improved API description here>"}}
>
> </user_prompt>
>
> C. Additional Experimental Results
>
> Parameter Study: Ratio of Trace-free Data in Curriculum. Here, we also investigate the impact of the ratio of the
> trace-free data in the curriculum learning. We fix the number of total training samples and investigate the impact of different
> learning curriculums. To avoid overfitting, we limit the training to 2 epochs. As we can observe from Table 7 in Appendix B,
> the two stage curriculum with 10% trace-free data in the first stage and 90% in the second stage is the most effective one. A
> hypothesis for this is that the second with 90% trace-free is close to the trace-free scenario at inference time. We also tried 3
> stages but the results are worse than 2 stages on StableToolBench.
>
> Tool-level Results for Trace-based Setting. Table 9 shows the tool-level metrics for trace-based methods. Trace-based and
> D2 have the best improvement percentage as well as average ∆, they also influence more tools than the baselines probably
> due to the bias towards a smaller portion of tools in the complicated execution trace collection procedure of DRAFT and
> Play2Prompt.
>
> D. Future work
>
> This work opens several directions for future research. First, fine-tuning agents and improving tool interfaces can be
> done jointly for optimizing the performance of agents. Second, within the scope of tool interface improvement, existing
> description generators operate on given parameter schemas; extending it to jointly optimize schemas and descriptions.
> Finally, while we focus on RESTful APIs, the same framework may apply to other domains such as databases or code
> execution environments. Finally, combining tool interface optimization with downstream agent training in an end-to-end
>
> 20
>
> Learning to Rewrite Tool Descriptions for Reliable LLM-Agent Tool Use
>
> Table 9. Tool-Level Results in the trace-based setting.
>
> Method
>
> Impr. ↑ (%) Degr. ↓ (%) Avg ∆ ↑
>
> F1 Score
>
> Trace-based
> D2
> DRAFT
> Play2Prompt
>
> 6.8
> 6.3
> 3.8
> 4.2
>
> 6.3
> 5.8
> 5.0
> 3.0
>
> API Execution Success Rate
>
> Trace-based
> D2
> DRAFT
> Play2Prompt
>
> 14.8
> 14.5
> 11.1
> 9.3
>
> 14.8
> 14.0
> 10.9
> 9.8
>
> 0.0080
> 0.0141
> 0.0006
> 0.0034
>
> 0.0153
> 0.0172
> 0.0145
> -0.0002
>
> fashion may lead to further gains.
>
> 21
>
>
> [Source: arxiv.org/abs/2602.20426](https://arxiv.org/abs/2602.20426)
