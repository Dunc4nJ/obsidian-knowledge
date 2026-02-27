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
> **Learning to Rewrite Tool Descriptions for Reliable LLM-Agent Tool Use**
>
> Ruocheng Guo, Kaiwen Dong, Xiang Gao, Kamalika Das — Intuit AI Research
> Preprint, February 25, 2026
>
> The performance of LLM-based agents depends not only on the agent itself but also on the quality of the tool interfaces it consumes. While prior work has focused heavily on agent fine-tuning, tool interfaces — including natural language descriptions and parameter schemas — remain largely human-oriented and often become a bottleneck, especially when agents must select from large candidate tool sets. Existing approaches to improving tool interfaces rely on execution traces, which are frequently unavailable in cold-start or privacy-constrained settings, and typically optimize each tool independently, limiting scalability and generalization to unseen tools.
>
> We propose Trace-Free+, a curriculum learning framework that progressively transfers supervision from trace-rich settings to trace-free deployment, encouraging the model to abstract reusable interface-usage patterns and tool usage outcomes. To support this approach, we construct a large-scale dataset of high-quality tool interfaces using a structured workflow over a diverse collection of tools. Experiments on StableToolBench and RestBench show consistent gains on unseen tools, strong cross-domain generalization, and robustness as the number of candidate tools scales to over 100, demonstrating that tool interface optimization is a practical and deployable complement to agent fine-tuning.
>
> **Key contributions:**
> - Trace-Free+ curriculum learning framework transferring knowledge from trace-rich training to trace-free inference
> - Large-scale dataset of high-quality tool descriptions via agentic annotation workflow over 9,640 API providers
> - Consistent gains across in-domain (StableToolBench) and cross-domain (RestBench) benchmarks
> - Robustness to scaling: maintains performance as candidate tools grow to 100+
>
> **Methodology:**
> 1. Agentic seed tool annotation: Smolagents-based annotator explores RapidAPI tools, filters to 107 healthy API providers
> 2. Dependency-aware query synthesis: multi-hop queries requiring structured inter-API dependencies
> 3. Two-stage description improvement: D0 (original) → D1 (guideline-improved) → D2 (trace-refined with failure rules via RIMRULE)
> 4. Curriculum SFT: gradually shift from trace-based to trace-free training examples
>
> **Key results (Trace-Free+ vs original D0):**
> - StableToolBench overall: 70.1% SL / 54.0% QL vs 67.3% SL / 48.0% QL
> - RestBench TMDB: 88.1% SL / 74.9% QL vs 69.8% SL / 49.5% QL
> - RestBench Spotify: 68.1% SL / 49.3% QL vs 57.1% SL / 34.9% QL
> - Most robust method under tool scaling (100+ candidates)
>
> [Source: arxiv.org/abs/2602.20426](https://arxiv.org/abs/2602.20426)
