---
created: 2026-06-09
description: DSPy replaces hand-written prompts with typed input/output signatures, swappable execution modules (Predict, ChainOfThought, ReAct), and optimizers like GEPA that automatically tune programs against a metric — separating task definition from both execution strategy and prompt wording.
source: https://dspy.ai/
type: framework
---

## Key Takeaways

- **Signatures decouple task definition from execution strategy.** A DSPy Signature is a typed class with `InputField` and `OutputField` annotations plus a one-line docstring; changing from `dspy.Predict` → `dspy.ChainOfThought` → `dspy.ReAct` is a one-word swap, with no prompt rewrite required. This is the mechanism that makes [[DSPy frames AI engineering as five components and adapters are the most underappreciated lever|adapters the most underappreciated lever]] — rendering (how inputs/outputs are formatted for a given model) is a separate concern from the task schema.

- **Optimizers turn prompt engineering into an offline compilation step.** Give GEPA a labeled training set and a scoring function; it runs reflective Pareto-front evolution and returns a tuned program — the homepage example shows 0.41 → 0.63 F1 on RAG and 62% → 89% accuracy on extraction at $2.18/200 examples. [[GEPA prompt optimizer beats reinforcement learning with 35x fewer rollouts by reflecting on natural-language execution traces|GEPA beats GRPO by up to 20%]] with 35× fewer rollouts; [[dspy-agent-skills shows GEPA only improves when there is failure signal - 1.2B models gain 25 points where 8B+ no-op|it only fires when the baseline leaves room to improve]], so budget is wasted on already-saturated tasks.

- **Modules are composable strategy wrappers that share a Signature interface.** `dspy.ReAct` takes a Signature plus a `tools=[]` list; `dspy.ChainOfThought` adds scratchpad reasoning; `dspy.Predict` is direct completion. A `dspy.Module` subclass with a `forward()` method can chain any combination of these — the `FactCheck` example on the homepage pipelines a claim-extractor into a per-claim verifier using plain Python list comprehension. [[predict-RLM uses GEPA to recursively optimize agent skills reaching SpreadsheetBench top-5 as open source|Predict-RLM]] wraps a DSPy Signature with a REPL-backed module to recursively self-optimize.

- **DSPy is the Stanford NLP lab's production surface: research papers land here first.** The codebase tracks seven papers from Dec 2022 (Demonstrate-Search-Predict) through Dec 2025 (Recursive Language Models / RLMs), with GEPA (Jul 2025) and MIPROv2 (Jun 2024) as the optimizer milestones. [[Quarq Labs frames GEPA and RLM as complementary context layers - GEPA optimizes static prompts before inference while RLM decomposes context at runtime|GEPA and RLMs are complementary]]: GEPA tunes the static prompt before inference; [[RLMs inline intelligence into data pipelines by giving LLMs symbolic access to DataFrames in a persistent REPL|RLMs decompose context dynamically at runtime]] via a persistent REPL.

- **Production deployments cluster around cost reduction and prompt migration.** Shopify reports ~550× cost reduction on metadata extraction; AWS uses DSPy to migrate prompts from larger to smaller Amazon Nova models; Dropbox optimized their Dash relevance judge. The common thread is that optimizers make model-switching or quality tuning tractable at scale — a problem [[HALO uses an RLM to mine harness-shaped failures from agent execution traces and lift benchmarks 10-16 percentage points|HALO]] addresses from the harness side by mining failure patterns, while DSPy addresses it from the program-compilation side.

## External Resources

- [github.com/stanfordnlp/dspy](https://github.com/stanfordnlp/dspy) — 35k stars, 431+ contributors; MIT license, Python ≥ 3.10
- [DSPy: Compiling Declarative LM Calls (arXiv:2310.03714)](https://arxiv.org/abs/2310.03714) — original DSPy paper, Oct 2023
- [GEPA: Reflective Prompt Evolution (arXiv:2507.19457)](https://arxiv.org/abs/2507.19457) — GEPA optimizer paper, Jul 2025
- [Recursive Language Models (arXiv:2512.24601)](https://arxiv.org/abs/2512.24601) — RLMs paper, Dec 2025
- [MIPROv2: Optimizing Instructions & Demos (arXiv:2406.11695)](https://arxiv.org/abs/2406.11695) — MIPROv2 paper, Jun 2024
- [BetterTogether: Fine-Tuning + Prompt Opt. (arXiv:2407.10930)](https://arxiv.org/abs/2407.10930) — BetterTogether paper, Jul 2024
- [STORM: Writing Wikipedia-like Articles (arXiv:2402.14207)](https://arxiv.org/abs/2402.14207) — STORM paper, Feb 2024
- [Demonstrate-Search-Predict (arXiv:2212.14024)](https://arxiv.org/abs/2212.14024) — original DSP paper, Dec 2022
- [Shopify: Metadata extraction with DSPy (YouTube)](https://www.youtube.com/watch?v=bxToahwOVpY) — ~550× cost reduction case study
- [Dropbox: Optimizing Dash relevance judge with DSPy](https://dropbox.tech/machine-learning/optimizing-dropbox-dash-relevance-judge-with-dspy) — ranking and evaluation optimization
- [AWS: Prompt migration with DSPy on Amazon Nova](https://aws.amazon.com/blogs/machine-learning/improve-amazon-nova-migration-performance-with-data-aware-prompt-optimization/) — migrating larger model prompts to smaller models
- [Databricks: DSPy for LM judges, RAG, classification](https://www.databricks.com/blog/dspy-databricks) — enterprise deployment patterns
- [Replit: Code repair pipeline with DSPy](https://blog.replit.com/code-repair) — code LLMs synthesizing diffs
- [Nous Research: Hermes agent self-evolution](https://github.com/NousResearch/hermes-agent-self-evolution) — evolutionary self-improvement with DSPy
- [Discord community](https://discord.gg/XCGy2WDCQB) — 8.4k members

## Original Content

> [!quote]- Source Material
> ---
> description: The framework for programming—rather than prompting—language models.
> title: DSPy
> ---
>
> * Diving Deeper
> * [Tutorials](tutorials/)
> * [Optimize AI Programs with DSPy](tutorials/optimize_ai_program/)
> * [Reflective Prompt Evolution with dspy.GEPA](tutorials/gepa_ai_program/)
> * [Experimental RL Optimization for DSPy](tutorials/rl_ai_program/)
> * [Tools, Development, and Deployment](tutorials/core_development/)
> * [Real-World Examples](tutorials/real_world_examples/)
> * Community
> * FAQ
> * [API Reference](api/)
> * Evaluation
> * Experimental
> * Models
> * Modules
> * Optimizers
> * [BetterTogether](api/optimizers/BetterTogether/)
> * [BootstrapFewShot](api/optimizers/BootstrapFewShot/)
> * [BootstrapFewShotWithRandomSearch](api/optimizers/BootstrapFewShotWithRandomSearch/)
> * [BootstrapFinetune](api/optimizers/BootstrapFinetune/)
> * [BootstrapRS](api/optimizers/BootstrapRS/)
> * [COPRO](api/optimizers/COPRO/)
> * [Ensemble](api/optimizers/Ensemble/)
> * [InferRules](api/optimizers/InferRules/)
> * [KNN](api/optimizers/KNN/)
> * [KNNFewShot](api/optimizers/KNNFewShot/)
> * [LabeledFewShot](api/optimizers/LabeledFewShot/)
> * [MIPROv2](api/optimizers/MIPROv2/)
> * [SIMBA](api/optimizers/SIMBA/)
> * Primitives
> * Signatures
> * Tools
> * Utils
>
> DSPy 3.3.0b1 — New ReActV2 Module and improved LM/BaseLM · [learn more →](https://github.com/stanfordnlp/dspy/releases)
>
> # Program, don't prompt, your LLMs.
>
> DSPy is a Python framework for building AI systems. Express your tasks as structured signatures, not prompts, to produce maintainable, modular, and optimizable programs.
>
> [$ pip install -U dspy](getting-started/installation/) [Getting Started →](getting-started/program-dont-prompt/)
>
> **python** ≥ 3.10 · MIT license · Stanford NLP · [github.com/stanfordnlp/dspy](https://github.com/stanfordnlp/dspy)
>
> Change LLM · Add a Field · Make it an Agent
>
> **extract_events.py**
>
> ```python
> lm = dspy.LM("openai/gpt-5.4-nano")
>
> class ExtractEvent(dspy.Signature):
>     """Extract event details from an email."""
>
>     email: str = dspy.InputField()
>
>     event_name: str = dspy.OutputField()
>
>     date: str = dspy.OutputField()
>
> extract = dspy.Predict(ExtractEvent)
>
> extract(email=inbox_message)
> ```
>
> output:
> ```
> Prediction(
>     event_name="Team Offsite",
>     date="Thursday, June 5"
> )
> ```
>
> 7.3M+ monthly downloads · 431+ contributors · 35k GitHub stars
>
> in production at:
>
> *Partner logos: Databricks, Shopify, Dropbox*
> ![[dspy-homepage-databricks.svg]]
> ![[dspy-homepage-shopify.svg]]
> ![[dspy-homepage-dropbox.svg]]
>
> ## Compose programs with reusable primitives.
>
> ### Signatures
>
> Declare your task.
>
> Define your task as typed inputs and outputs instead of managing messy prompts. Portable, maintainable, and easy to iterate on.
>
> [Learn about Signatures →](getting-started/expanding-signatures/)
>
> ```python
> class Triage(dspy.Signature):
>     """Route a support ticket."""
>
>     ticket: str = dspy.InputField()
>
>     urgency: Literal["low", "high"] = dspy.OutputField()
>
>     team: str = dspy.OutputField()
> ```
>
> ### Modules
>
> Same interface, different strategy.
>
> Modules control how your signature executes. Reason, run ensembles, use tools, add a REPL, and more without rewriting your task.
>
> [Explore Modules →](getting-started/changing-modules/)
>
> ```python
> # Direct completion
> classify = dspy.Predict(Triage)
>
> # Add step-by-step reasoning
> classify = dspy.ChainOfThought(Triage)
>
> # Add tools and a reasoning loop
> classify = dspy.ReAct(Triage, tools=[search])
> ```
>
> ### Optimizers
>
> Compile your program against a metric.
>
> Give DSPy examples and a scoring function. It tunes your prompts automatically until quality converges.
>
> [Try Optimizers →](getting-started/gepa-optimization/)
>
> ```python
> tp = dspy.GEPA(
>     metric=semantic_f1,
>     auto="medium")
>
> opt = tp.compile(rag, trainset)
>
> # Before: 0.41 F1
> # After: 0.63 F1
>
> opt.save("rag.v2.json")
> ```
>
> ## Define a task. Grow it into a system.
>
> Extract · Agent · Pipeline · Multimodal · Optimize
>
> **Extract:**
> ```python
> class Extract(dspy.Signature):
>     """Extract contact info."""
>
>     message: str = dspy.InputField()
>
>     name: str = dspy.OutputField()
>
>     email: Optional[str] = dspy.OutputField()
>
>     intent: Literal[
>         "meeting", "intro", "follow-up"
>     ] = dspy.OutputField()
>
> extract = dspy.Predict(Extract)
>
> extract(message="I'm Sarah (sarah@acme.co). Meet Thursday?")
> ```
>
> output:
> ```
> Prediction(
>     name="Sarah",
>     email="sarah@acme.co",
>     intent="meeting"
> )
> ```
>
> **Agent:**
> ```python
> def search(query: str) -> list[str]:
>     """Search a knowledge base."""
>     return kb.query(query, k=3)
>
> def calc(expr: str) -> float:
>     """Evaluate a math expression."""
>     return dspy.PythonInterpreter({}).execute(expr)
>
> agent = dspy.ReAct(
>     "question -> answer",
>     tools=[search, calc])
>
> agent(question="GDP per capita of France?")
> ```
>
> output:
> ```
> # thought 1: I need France's GDP and population.
> # action 1: search("France GDP") → ...
> # thought 2: Now divide GDP by population.
> # action 2: calc("3.13e12 / 68e6") → 46029.4
> Prediction(answer="$46,029")
> ```
>
> **Pipeline:**
> ```python
> class FactCheck(dspy.Module):
>     def __init__(self):
>         self.find = dspy.ChainOfThought(
>             "article -> claims: list[str]")
>         self.verify = dspy.ChainOfThought(
>             "claim, source -> verdict")
>
>     def forward(self, article):
>         found = self.find(article=article)
>         return [
>             self.verify(claim=c, source=article)
>             for c in found.claims]
> ```
>
> output:
> ```
> # >>> FactCheck()(article=news_article)
> [Prediction(verdict="supported"),
>  Prediction(verdict="unsupported"),
>  Prediction(verdict="supported")]
> ```
>
> **Multimodal:**
> ```python
> class AnalyzeChart(dspy.Signature):
>     """Describe the trend and key data points in a chart."""
>
>     chart: dspy.Image = dspy.InputField()
>
>     title: str = dspy.OutputField()
>
>     trend: str = dspy.OutputField()
>
>     data_points: list[dict] = dspy.OutputField()
>
> analyze = dspy.Predict(AnalyzeChart)
>
> analyze(chart=dspy.Image("quarterly_revenue.png"))
> ```
>
> output:
> ```
> Prediction(
>     title="Quarterly Revenue (2024)",
>     trend="Steady growth, Q3 dip, strong Q4 recovery",
>     data_points=[{"q": "Q1", "rev": "$4.2M"}, ...]
> )
> ```
>
> **Optimize:**
> ```python
> optimizer = dspy.GEPA(
>     metric=accuracy, auto="medium")
>
> optimized = optimizer.compile(
>     extract, trainset=labeled_emails)
>
> optimized.save("extract_v2.json")
> ```
>
> output:
> ```
> # Baseline 62% (gpt-5.4-mini, zero-shot)
> # Optimized 89% (gpt-5.4-mini + GEPA compile)
> # Cost $2.18 · 200 examples
> # Saved to → extract_v2.json
> ```
>
> Signatures define tasks and enforce output types · Define tools as functions and pass them to a ReAct module · Compose multiple Signatures into new modules with plain Python control flow · Images are a Signature field type, enabling multimodal tasks · Optimizers improve your program against a defined metric
>
> [Learn more about Signatures →](getting-started/expanding-signatures/) · [Learn how to add tools →](getting-started/react-and-tools/) · [Learn how to compose modules →](getting-started/composing-modules/) · [Learn how to build multimodal programs →](tutorials/image_generation_prompting/) · [Learn how to write metrics and optimize →](getting-started/gepa-optimization/)
>
> ## Built in the open, since Dec 2022.
>
> DSPy started at Stanford NLP and grew into a research community. New optimizers and module types land here first — then show up in production systems at companies you've heard of.
>
> | Date | Paper |
> |------|-------|
> | Dec 2025 | [Recursive Language Models](https://arxiv.org/abs/2512.24601) |
> | Jul 2025 | [GEPA: Reflective Prompt Evolution](https://arxiv.org/abs/2507.19457) |
> | Jul 2024 | [BetterTogether: Fine-Tuning + Prompt Opt.](https://arxiv.org/abs/2407.10930) |
> | Jun 2024 | [MIPROv2: Optimizing Instructions & Demos](https://arxiv.org/abs/2406.11695) |
> | Feb 2024 | [STORM: Writing Wikipedia-like Articles](https://arxiv.org/abs/2402.14207) |
> | Oct 2023 | [DSPy: Compiling Declarative LM Calls](https://arxiv.org/abs/2310.03714) |
> | Dec 2022 | [Demonstrate-Search-Predict](https://arxiv.org/abs/2212.14024) |
>
> ### DSPy in production
>
> [Shopify](https://www.youtube.com/watch?v=bxToahwOVpY) — Metadata extraction across all shops; ~550× cost reduction
>
> [Dropbox](https://dropbox.tech/machine-learning/optimizing-dropbox-dash-relevance-judge-with-dspy) — Optimized Dash relevance judge for ranking and evaluation
>
> [AWS](https://aws.amazon.com/blogs/machine-learning/improve-amazon-nova-migration-performance-with-data-aware-prompt-optimization/) — Prompt migration from larger to smaller models on Amazon Nova
>
> [JetBlue](https://www.databricks.com/blog/optimizing-databricks-llm-pipelines-dspy) — Multiple chatbot use cases on Databricks
>
> [Replit](https://blog.replit.com/code-repair) — Code repair pipeline using code LLMs to synthesize diffs
>
> [Databricks](https://www.databricks.com/blog/dspy-databricks) — LM judges, RAG, classification, and customer solutions
>
> [Nous Research](https://github.com/NousResearch/hermes-agent-self-evolution) — Evolutionary self-improvement for the Hermes agent
>
> [More →](community/use-cases/) — See all companies using DSPy in production
>
> Community: 431+ contributors · 8.4k Discord members · 546+ merged PRs/yr · 60+ tutorials & recipes
>
> [GitHub →](https://github.com/stanfordnlp/dspy) · [Discord →](https://discord.gg/XCGy2WDCQB)
>
> [Original page](https://dspy.ai/)
