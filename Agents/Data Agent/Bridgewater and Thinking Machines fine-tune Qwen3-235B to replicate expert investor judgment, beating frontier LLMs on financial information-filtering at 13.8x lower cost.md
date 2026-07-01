---
created: 2026-07-01
description: Bridgewater AIA Labs, training on Thinking Machines' Tinker, cleans an expert-labeled dataset via a contested-example verification loop and fine-tunes Qwen3-235B with a multi-task RL recipe (interleaved round-robin batching + CISPO asymmetric-clipping loss + on-policy distillation from a checkpoint promoted only on new validation-accuracy highs), lifting average accuracy on six investor information-filtering tasks from the best frontier model's 78.2% to 84.7% (29.8% fewer mistakes) at 13.8x lower inference cost — evidence for "differentiated intelligence" built from proprietary expert data rather than a better base model.
source: https://thinkingmachines.ai/news/learning-to-replicate-expert-judgment-in-financial-tasks/
type: research
---

## Key Takeaways

- **Frontier LLMs plateau on "simple" financial judgment, and the plateau is not closing.** Naive prompts put Gemini/Claude/GPT variants at ~50% accuracy — a coin flip — on six routine investor triage tasks. Expert-written prompts plus task *reframing* (splitting "relevant" into *relevant-and-interesting* / *relevant-but-uninteresting* / *irrelevant*) lifted them only into the mid-to-high 70s, and automatic prompt-optimization added nothing further. Newer generations barely move per dollar (GPT 5.4 costs 43% more than 5.2 for marginal gains). The judgment that matters is the part experts *cannot articulate*, so it cannot be prompted in — the same ceiling seen in [[DAB benchmark exposes frontier data agents at 38 percent pass at 1 with 85 percent of failures in planning or implementation]] and the argument behind [[context management replaces the semantic layer for data agents because it adapts from corrections]].

- **The training data is the moat, and cleaning it is a model-in-the-loop problem.** Non-expert vendor labels were often simply wrong, and models trained on them stayed poor. The fix is a *contested-example verification loop*: train a model on the noisy labels, re-score the training set, and route only the examples where the model disagrees with the label to expensive expert investors — because a model that can't fit an example from its own training set signals either a genuinely hard case or a mislabel. This is the same "spend expert attention only where it changes the answer" discipline as the reward design in [[Prime Intellect duckdb-qa - RL reward shaping for SQL tool use]], and it targets the accuracy-for-trust threshold emphasized in [[Anthropic's self-service analytics stack achieves 95% accuracy by treating the bottleneck as context and entity mapping not SQL generation]].

- **A stacked multi-task RL recipe, with every component ablated, drives the gains.** Qwen3-235B base sits at 44.8%; plain GRPO jumps it to 73.5%; the final recipe reaches 84.7%. Three additions on top of GRPO each contribute measurably: **interleaved round-robin batching** (one batch per task, +12.1% over fully-mixed batches), **CISPO loss with asymmetric clipping** (+10.1% over the importance-sampling baseline), and **on-policy distillation** where the teacher is the *current checkpoint*, promoted every 20 steps but only when validation accuracy hits a new high (+3.1% over a frozen teacher). This mirrors the multi-task-RL-vs-distillation exploration in [[multi-task RL on heterogeneous search behaviors produces knowledge agents that generalize across grounded reasoning tasks]].

- **The custom model wins on both axes at once.** It beats the best frontier model on accuracy (78.2% → 84.7%, i.e. 29.8% fewer mistakes) *and* costs 13.8x less per task thanks to its smaller size. This is the same "custom/open model beats the closed frontier at a fraction of the cost" pattern documented in [[Open models now match closed frontier models on core agent harness tasks at a fraction of the cost]] — but reached through org-specific fine-tuning on proprietary data, not merely a stronger public base model.

- **The strategic thesis is "differentiated intelligence."** When alpha comes from taste that can't be written down, the durable advantage is a proprietary expert-labeled dataset plus cheap fine-tuning infrastructure (Tinker), yielding many small models each tuned to one organizational task rather than one general frontier model prompted harder. It is a data-and-fine-tuning counterpart to the context-over-capability argument in [[OpenAI internal data agent succeeds through six layers of context not model capability alone]]. See also [[moc - Data Agent]].

## Method and Results

### The six information-filtering tasks

All six are drawn from an investor's daily workflow — "trivial for investors, but they get stuck when articulating their decision process."

| # | Task | What the model must decide | Metric |
|---|------|----------------------------|--------|
| 01 | Financial Article Relevancy | Is a financial article relevant to a C-suite investment professional? | F1, Accuracy |
| 02 | Central Bank Document Relevancy | Does a central-bank document signal the direction of future rate changes? | F1, Accuracy |
| 03 | Generic Document Relevancy | Given an investor's question + a research doc, does the doc help answer it? | F1, Accuracy |
| 04 | Ad Hoc Content Labeling | Is a doc recurring boilerplate or mixed (boilerplate + one-off analysis)? Find the last page of issue-specific content. | Accuracy |
| 05 | Document Truncation | Where does boilerplate content begin in a document? | Exact-match accuracy |
| 06 | Email Truncation | Where does boilerplate content begin in an email? | Exact-match accuracy |

The relevance judgment is subtle: both a "Trump insists Greenland is his" story and a "US stocks fall as Trump threatens China tariffs" story touch geopolitics + finance, yet only the second is materially relevant to US markets.

*"Not relevant" example — a geopolitics story that reads as noise to a macro investor (Source: Financial Times).*
![[tm-expertjudgment-001.jpg]]

*"Relevant" example — a market-moving tariff story a macro investor must act on (Source: Financial Times / AFP-Getty).*
![[tm-expertjudgment-002.jpg]]

### Frontier models plateau below the trust threshold

Naive prompt → coin flip; best expert-engineered prompt → high-70s, still short of the ~80% investors demand. F1 is averaged over the 3 classification tasks; accuracy over all 6.

| Frontier model (release) | Naive-prompt accuracy | Expert-prompt accuracy |
|---|---|---|
| Claude Opus 4.6 (Feb 5) | 47.2% | 77.2% |
| Gemini 3.1 Pro (Feb 19) | 50.1% | 74.3% |
| GPT 5.4 (Mar 5) | 47.2% | 75.8% |
| GPT 5.5 (Apr 23) | 48.5% | 78.2% |
| Claude Opus 4.8 (May 28) | 45.6% | 78.0% |

Automatic prompt optimization yielded no further gains, and per-dollar accuracy is nearly flat across generations.

### Cleaning the data: contested-example verification

1. Source a large dataset from non-expert labeling vendors.
2. Train a model on it; re-evaluate that model on the *same* training data.
3. Send only the examples where model ≠ label to expert investors for re-adjudication (a mismatch means either a genuinely hard case or a wrong label).
4. Use the cleaned set for training; hold out a separate test set for final evaluation.

This routes scarce expert attention only to the labels that actually need it.

### Training recipe (on Tinker, base = Qwen3-235B)

Baseline: standard GRPO with importance-sampling loss (critic-free).

| Model / Training | Avg Accuracy | Avg Pos F1 |
|---|---|---|
| Qwen base | 44.8% | 55.24% |
| Qwen + GRPO | 73.48% | 88.95% |

Three modifications push past the 80% threshold:

1. **Interleaved batching** — one batch per task in round-robin order (vs sequential or fully-mixed). Best strategy; +12.1% accuracy over fully-mixed batches.
2. **CISPO loss with asymmetric clipping** — replaces the importance-sampling loss; +10.1% over the IS baseline.
3. **On-policy distillation (OPD) with a promoted teacher** — the advantage penalizes drift from the teacher's distribution:

$$r = \text{reward} - \beta \cdot \operatorname{avg}(\text{student\_lp} - \text{teacher\_lp})$$

$$\text{adv}_i = r_i - \operatorname{avg}(r)$$

Every 20 steps the current checkpoint is promoted to teacher — but only if validation accuracy hits a new high, so the model never distills toward a weaker teacher. This adds +3.1% over a frozen base-model teacher.

### Results and leave-one-out ablation

Final model: **84.7% average accuracy** vs the best frontier model's 78.2% → **29.8% fewer mistakes**, at a **13.8x lower inference cost per task**. Each ablation row removes exactly one component from the final recipe.

| Configuration | Avg Accuracy | Avg Pos F1 |
|---|---|---|
| Qwen + Final Recipe | 84.66% | 92.99% |
| − Interleaved Batching | 72.18% | 89.01% |
| − CISPO + Asymmetric Clips | 74.56% | 90.64% |
| − OPD | 72.39% | 87.93% |
| − OPD w/ Best-Val-Accuracy Teacher | 81.55% | 89.41% |

## External Resources

- [Tinker — Thinking Machines Lab](https://thinkingmachines.ai/tinker/) — the managed fine-tuning service used for training; abstracts away GPU infrastructure for fast experimentation.
- [On-Policy Distillation](https://thinkingmachines.ai/blog/on-policy-distillation/) (Kevin Lu et al., Thinking Machines) — the OPD method this recipe builds on.
- [CISPO loss with asymmetric clipping](https://arxiv.org/abs/2510.13786) (arXiv 2510.13786) — the loss function that replaced importance-sampling.
- [Bridgewater AIA Labs](https://www.bridgewater.com/aia-labs) — the team behind the work.
- [F-score](https://en.wikipedia.org/wiki/F-score) (Wikipedia) — evaluation metric used for the classification tasks.

## Original Content

> [!quote]- Source Material — "Learning to Replicate Expert Judgment in Financial Tasks" (Bridgewater AIA Labs × Thinking Machines, Jun 30, 2026)
> # Learning to Replicate Expert Judgment in Financial Tasks
>
> Sarah Su, Kevin Zhu, Emily Xiao, Rohan Alur, Daniel Kang ([Bridgewater AIA Labs](https://www.bridgewater.com/aia-labs)) in collaboration with Thinking Machines — Jun 30, 2026
>
> ## Judging information
>
> Outperforming the market is hard. When every investor has access to the same sources of public information, alpha must come from unique insight built on taste and judgment. A strong investor's judgment is difficult to articulate and teach directly to others, whether human or AI. It comes from experience.
>
> Even when we decompose an investor's job into its simplest constituent tasks, those tasks turn out to be surprisingly difficult for LLMs. In this post, we consider a simple special case: filtering and processing financial documents to surface information relevant to investment decisions.
>
> Investors are bombarded with information every day: news articles, research reports, company documents, emails, internal write-ups, and more. Reading is the easy part. The real work is the small, repeated judgments carried over it — filtering, interpreting, segmenting, and identifying where the useful signal lies. These judgments are embedded throughout an investor's daily workflow and consume substantial time.
>
> We wanted to see if we could automate the information triage task: identifying what is relevant and interesting to read. This alone could greatly augment investors' productivity, letting them spend their freed up attention on higher-level synthesis and decision making.
>
> Given that LLMs perform poorly on simple financial tasks, we asked: is it possible to teach LLMs financial judgement? We find that with **high-quality human annotations**, we can teach LLMs to interpret text with expert-level taste and judgement. **Our proprietary model outperforms all frontier models we tested on information accuracy and recall, at a fraction of their cost.**
>
> We describe our training process and results on a subset of data cleared for public release. Based on our results, we further describe the seeds of a vision of _differentiated intelligence_, with models tuned for specific organizational needs.
>
> ## Frontier model performance
>
> We evaluated models on six information filtering tasks drawn from investors' daily workflows. Beyond these tasks, we have many others internally that show similar patterns to these six tasks: frontier models we tested on underperform compared to our internally trained models.
>
> We measured accuracy — the percentage of documents that were correctly labeled according to our investors. For classification tasks, we also calculated the F1 score ([F-score](https://en.wikipedia.org/wiki/F-score), Wikipedia).
>
> **01 — Financial Article Relevancy.** Given a financial article, classify whether it is relevant to a C-suite investment professional. *Eval metrics: F1 score, Accuracy.*
>
> **02 — Central Bank Document Relevancy.** Given a central bank document, classify whether it signals the direction of future interest rate changes. *Eval metrics: F1 score, Accuracy.*
>
> **03 — Generic Document Relevancy.** Given an investor's question and a research document, classify whether the document helps answer it. *Eval metrics: F1 score, Accuracy.*
>
> **04 — Ad Hoc Content Labeling.** Research documents are either recurring (repeated boilerplate) or mixed (boilerplate plus one-off, issue-specific analysis). Classify which, and find the last page of issue-specific content. *Eval metric: Accuracy.*
>
> **05 — Document Truncation.** Identify where boilerplate content begins in a document. *Eval metric: Exact Match Accuracy.*
>
> **06 — Email Truncation.** Identify where boilerplate content begins in an email. *Eval metric: Exact Match Accuracy.*
>
> The six financial tasks we evaluate in this blog post, each drawn from the routine work of an investor.
>
> These tasks are trivial for investors, but they get stuck when articulating their decision process. Consider the following example of classifying a news article as relevant to an investment professional below:
>
> **Not relevant** — [ft.com](https://www.ft.com/content/e021f12b-d2a0-4637-ac0f-4e3dae5a8843): "Trump insists Greenland is his"
>
> *Illustration from an article about Trump and Greenland. © Jeremy Banx*
> ![[tm-expertjudgment-001.jpg]]
>
> **Relevant** — [ft.com](https://www.ft.com/content/b9ae2417-2e89-4b0a-bad5-d94f4e980ecc?syn-25a6b1a6=1): "US stocks close sharply lower after Trump threatens new China tariffs"
>
> *Biggest one-day drop in S&P 500 since April brings weeks long rally to a halt. © AFP/Getty Images*
> ![[tm-expertjudgment-002.jpg]]
>
> Example of judging the relevance of a financial article to US markets. Source: Financial Times.
>
> The Greenland example is unlikely to be taken seriously given the context of the article, while the China tariffs are highly relevant. Yet both examples touch on geopolitics and finance.
>
> In contrast to our investors, frontier models we tested on perform surprisingly poorly. Variants of Gemini, Claude, and GPT averaged a mere ~50% accuracy when given a prompt that simply states each of the six tasks to perform.
>
> We first tried to improve LLM performance with stronger prompting. Our experts wrote instructions based on real task descriptions, and also suggested reframing certain tasks. For example, while an article about a small IPO is clearly financially relevant, it lacks the broad significance that would make it interesting to a macroeconomic investor at Bridgewater. LLM performance on the article classification task improved when they were asked to sort news stories into three labels: relevant and interesting, relevant but uninteresting, and irrelevant.
>
> These changes boosted their accuracy from a coin flip to the mid-70s. We saw no further gains in accuracy from automatic prompt-optimization methods. With our best prompts the frontier models we tested on still achieved less than 80% accuracy — the threshold investors expect from a system they could trust in their daily workflow.
>
> Accuracy & Positive Class F1 score of frontier models on our financial tasks after manual and automatic prompt engineering (F1 averaged across our 3 classification tasks; accuracy averaged across all 6). Naive prompt vs Expert prompt, average accuracy:
>
> - **Opus 4.6** (Feb 5): 47.2 → 77.2
> - **Gemini 3.1 Pro** (Feb 19): 50.1 → 74.3
> - **GPT 5.4** (Mar 5): 47.2 → 75.8
> - **GPT 5.5** (Apr 23): 48.5 → 78.2
> - **Opus 4.8** (May 28): 45.6 → 78.0
>
> Our results also suggest that newer models aren't improving rapidly at this task, especially per dollar spent. GPT 5.4 costs 43% more than 5.2 but is only marginally more accurate.
>
> An explicit prompt can only convey the intuition an expert is able to put into words, while the judgments that matter most are often the hardest to articulate. Fine-tuning sidesteps this: rather than contorting the expert's intuition into a static prompt, the training process lets the model develop its own judgment. Could we train open-weight models to outperform frontier models we tested on these tasks?
>
> ## Training dataset construction
>
> The first challenge of training a custom model was acquiring a dataset that reflects **high-quality investor taste**. In particular, much of the information is only useful when filtered through an investment professional's judgment.
>
> We initially sourced a dataset from vendors providing non-expert labeling. Models trained on this dataset still performed poorly. After examining the reasoning traces of the model we realized that the labels in the dataset were often wrong. Since expert labelers are costly, we devised a verification scheme that routes only the contested examples to experts.
>
> The scheme worked as follows: we trained a model on the dataset from non-expert labelers, then evaluated it on the same data. Examples where the model's answer differed from the labelers' were sent to our experts for reevaluation — if a model couldn't match an example from its own training set then either the example is genuinely difficult, or the original label was wrong. This procedure was used to clean the training set data; the final evaluation was done on a held out test set.
>
> ## Training recipe
>
> We trained our models on Tinker from Thinking Machines Lab ([Tinker](https://thinkingmachines.ai/tinker/)). Tinker allowed us to iterate quickly without worrying about GPU infrastructure.
>
> We chose Qwen3-235B as the base model as its fine-tuning performance is widely studied in the academic literature.
>
> We began with standard GRPO and importance-sampling loss as a simple, critic-free starting point. This baseline approach resulted in a massive jump in the model performance, but it still fell short of our desired 80% threshold.
>
> | Model / Training | Average Accuracy | Average Pos F1 |
> | ---------------- | ---------------- | -------------- |
> | Qwen Base        | 44.8%            | 55.24%         |
> | Qwen + GRPO      | 73.48%           | 88.95%         |
>
> We make the following modifications to our training recipe to push performance farther:
>
> ### 1. Interleaved batching
>
> For our multi-task training recipe, we compared three batching strategies: training each task sequentially, fully mixing tasks within a batch, and interleaving one batch per task in round-robin order. We found interleaving worked best, improving accuracy by 12.1% over fully mixed batches.
>
> ### 2. CISPO loss with asymmetric clipping
>
> We used CISPO loss with asymmetric clipping ([CISPO loss with asymmetric clipping](https://arxiv.org/abs/2510.13786), arXiv) to replace the standard importance-sampling loss. Across the loss functions and clipping schemes we tried, this performed best, improving accuracy by 10.1% over the importance-sampling baseline.
>
> ### 3. On-policy distillation with strong teachers
>
> We train with on-policy distillation ([On-Policy Distillation](https://thinkingmachines.ai/blog/on-policy-distillation/), Kevin Lu in collaboration with others, Thinking Machines) (OPD), constructing the advantage as follows:
>
> $$r = \text{reward} - \beta \cdot \operatorname{avg}(\text{student\_lp} - \text{teacher\_lp})$$
>
> $$\text{adv}_i = r_i - \operatorname{avg}(r)$$
>
> The reward is penalized when the student drifts from the teacher's distribution, regularizing the policy while it learns the task.
>
> Every 20 steps, we promote the current checkpoint to the teacher — but only if validation accuracy has reached a new high, so we never distill toward a weaker model. This gave a further 3.1% gain over a frozen base-model teacher.
>
> ## Results
>
> Finding the optimal training recipe required several iterations of different approaches. Tinker's accessibility allowed us to run fast experiments and refine our approach.
>
> Accuracy versus price for our trained model and frontier models: our model outperforms frontier models on both dimensions across generations (frontier models plotted include Gemini 3.1 Pro, Claude Opus 4.6, Claude Opus 4.8, GPT 5.2, GPT 5.4, GPT 5.5; axes span 72–86% average accuracy and $0–$100 cost per 1,000 tasks).
>
> Our trained model improves average accuracy from 78.2% to 84.7%, meaning the trained model makes 29.8% fewer mistakes than the best frontier model we evaluated. We find this level of accuracy is sufficient for our daily work.
>
> Our trained model is also vastly cheaper due to its smaller size: a 13.8x reduction in inference costs per task. As we plan to rely on more models trained to help with specific tasks and to scale AI across the organization, cost is an important consideration.
>
> We ablated each part of our training recipe to show how each portion contributes to performance.
>
> | Training Method Ablations        | Average Accuracy | Avg Pos F1 |
> | -------------------------------- | ---------------- | ---------- |
> | Qwen + Final Recipe              | 84.66%           | 92.99%     |
> | Interleaved Batching             | 72.18%           | 89.01%     |
> | CISPO + Asymmetric Clips         | 74.56%           | 90.64%     |
> | OPD                              | 72.39%           | 87.93%     |
> | OPD w/ Best Val Accuracy Teacher | 81.55%           | 89.41%     |
>
> Each row shows the final recipe with that single component removed (leave one out ablations).
>
> ## Conclusion
>
> Frontier models we tested on struggle with relatively simple financial tasks, and model advances don't improve performance much. In contrast, we've shown that **high-quality proprietary datasets** labeled by expert investors and used for fine-tuning produce custom models that exceed frontier performance on our tasks. We have found that this outcome holds true well beyond the six tasks we've discussed in this post.
>
> Aside from higher accuracy, custom models are also substantially cheaper. We expect to see more productivity gains from custom model training in the future, especially with the availability of training infrastructure like Tinker that enables rapid experimentation.
>
> Our results show the possibility of a future of differentiated intelligence, where custom models tuned to specific organizational needs outperform frontier models.
>
> ## Citation
>
> Su, Sarah; Zhu, Kevin; Xiao, Emily; Alur, Rohan; Kang, Daniel (Bridgewater AIA Labs), "Learning to replicate expert judgment in financial tasks", Thinking Machines Lab: News, June 2026.
>
> ```
> @article{su2026expertjudgment,
>   author = {Sarah Su, Kevin Zhu, Emily Xiao, Rohan Alur, Daniel Kang (Bridgewater AIA Labs)},
>   title = {Learning to replicate expert judgment in financial tasks},
>   journal = {Thinking Machines Lab: News},
>   year = {2026},
>   note = {https://thinkingmachines.ai/news/learning-to-replicate-expert-judgment-in-financial-tasks/}
> }
> ```

Source: [Learning to Replicate Expert Judgment in Financial Tasks](https://thinkingmachines.ai/news/learning-to-replicate-expert-judgment-in-financial-tasks/) — Sarah Su, Kevin Zhu, Emily Xiao, Rohan Alur, Daniel Kang (Bridgewater AIA Labs) in collaboration with Thinking Machines, Jun 30, 2026.
