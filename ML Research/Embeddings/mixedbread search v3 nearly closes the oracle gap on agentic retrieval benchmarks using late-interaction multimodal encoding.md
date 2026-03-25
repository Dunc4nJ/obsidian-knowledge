---
created: 2026-03-25
description: Mixedbread Search v3 ranks first on BrowseComp-Plus, tops MADQA, and recovers 89% of the oracle gap on OfficeQA-Pro by combining late-interaction encoding with native multimodal PDF ingestion behind a single API
source: https://mixedbread.com/blog/closing-gap
type: learning
---

## Key Takeaways

The "oracle gap" is an elegant way to isolate retrieval quality from reasoning quality in agentic benchmarks. Oracle retrieval gives the agent perfect documents for every question — the gap between oracle performance and real-retriever performance tells you exactly how much your retrieval is costing you. This sidesteps the confound where a bad answer could be the model's fault or the retriever's fault. Mixedbread frames their entire evaluation around this metric, which makes the results more interpretable than raw accuracy numbers alone.

Mixedbread Search v3 leads on all three benchmarks tested. On BrowseComp-Plus (100K web documents, multi-hop questions), it hits 90.48% accuracy with a 3.02-point oracle gap — nearly halving the gap vs the next best retriever, [[late-interaction lets a 150M ColBERT model outperform 7B dense retrievers on reasoning-intensive retrieval|Reason-ModernColBERT]] at 5.9. On MADQA (18K pages across 800 heterogeneous PDFs), Mixedbread-powered systems take the top spots. On OfficeQA-Pro (89K pages of dense financial documents inside OpenAI Codex), it recovers 89% of the oracle gap while cutting latency 34% and halving tool calls compared to the corpus baseline.

The strongest external validation comes from MADQA, where Distyl AI independently paired Mixedbread Search with their own agent harness ("Button") and achieved state-of-the-art results without further tuning. Third-party validation like this is far more convincing than vendor self-benchmarks — it shows the retrieval quality transfers across different agent architectures rather than being optimized for one specific scaffold.

A telling signal on BrowseComp-Plus: the gap between Mixedbread and competitors *widens* when you upgrade from a standard scaffold to a stronger agentic one (get_document). This suggests Mixedbread's retrieval ranking is genuinely better — with a weaker scaffold, bad reasoning masks retrieval differences, but a better scaffold exposes them. This connects to the broader pattern in [[colbert MaxSim is a submodular facility location objective and that is why it generalizes]] — late-interaction's token-level matching preserves more signal than single-vector approaches.

The technical edge appears to be late-interaction encoding (ColBERT-style token-level MaxSim matching) combined with native multimodal PDF ingestion via screenshots rather than OCR. This means the system sees tables, charts, and layouts as a vision model would, avoiding the information loss of text extraction. The blog explicitly mentions "multimodal ingestion, late-interaction encoding" as the pipeline. However, architecture details and training data remain undisclosed — this is a hosted API, not an open model, and the blog conspicuously avoids comparisons with other commercial embedding providers like Cohere or Voyage.

The API design philosophy is notable: one upload endpoint, one search endpoint, no chunking decisions, no embedding model selection, no reranker tuning. This abstracts away the entire retrieval pipeline. Whether this opacity is a feature or a risk depends on your use case — for teams who want retrieval to "just work," it is appealing; for teams who need control over their retrieval stack, the black-box nature may be a concern.

## External Resources

- [BrowseComp-Plus paper](https://arxiv.org/abs/2508.06600) — benchmark for evaluating deep-research agents on multi-hop web retrieval
- [MADQA paper](https://arxiv.org/abs/2603.12180) — multimodal agentic document QA benchmark across 800 heterogeneous PDFs
- [OfficeQA-Pro paper](https://arxiv.org/abs/2603.08655) — enterprise knowledge-work benchmark by Databricks with 89K pages of financial documents
- [BrowseComp-Plus leaderboard](https://huggingface.co/spaces/Tevatron/BrowseComp-Plus) — current standings
- [MADQA leaderboard](https://huggingface.co/spaces/Snowflake/MADQA-Leaderboard) — current standings
- [Distyl AI](https://distyl.ai/) — built the top MADQA system (Button) using Mixedbread retrieval
- [Mixedbread platform](https://www.platform.mixedbread.com/) — hosted search API

## Original Content

### Tweet Thread

> @mixedbreadai — 2026-03-24
>
> For Agentic tasks, Oracle-level performance is the maximum performance a system can achieve, assuming it is able to retrieve all relevant documents perfectly, every time.
>
> We're proud to show that Mixedbread Search approaches the Oracle on multiple knowledge intensive benchmarks.
>
> *Oracle gap comparison chart from tweet*
> ![[mixedbread-oracle-gap-002.jpg]]
>
> ---
>
> Agents are increasingly performing knowledge work: Deep Research, generating financial reports, reasoning across historical knowledgebases...
>
> Many high-quality benchmarks now focus on evaluating such tasks, among which BrowseComp-Plus, @databricks's OfficeQA, or @Snowflake's MADQA, released just last week.
>
> ---
>
> So what is the Oracle gap?
>
> Optimising agentic systems is complicated. There are many individual components you need to get just right.
>
> Retrieval is one of those components, and its impact is best measured by the Oracle gap: the difference between the performance of the same system between an imperfect retriever and perfect, fully-relevant results that would be provided by a so-called Oracle.
>
> ---
>
> You can read more about this in our blog post, where we present more detailed benchmark results and elaborate on the nature of the three benchmarks, and why we're very proud to be topping all three of them.
>
> ---
>
> Mixedbread search's ultimate aim is to power all workflows, no matter their modality or language.
>
> Try it for your own knowledge-intensive tasks today.
>
> Engagement: 93 likes | 16 retweets | 2 replies
> [Original thread](https://x.com/mixedbreadai/status/2036481382315336093)

### Blog Post

> [!quote]- Source Material
> **Closing the Oracle Gap for Your Agents**
> *Mixedbread Team — 2026-03-24*
>
> In retrieval for agentic workflows, the most important number is not the raw score, but the gap to oracle.
>
> Oracle retrieval is the ceiling: the score you get when the system has access to the correct evidence for every question, without retrieval misses. The smaller the gap, the less retrieval is holding the rest of your stack back.
>
> Our goal with Mixedbread Search is that you should not have to think about that gap at all. Building agentic systems is already complex enough without also having to debug retrieval quality. Search should be one less thing your team has to worry about.
>
> Across three agentic benchmarks, Mixedbread Search v3 consistently narrows that gap: on broad general-domain tasks like BrowseComp-Plus, on newer multimodal benchmarks like MADQA, and on enterprise knowledge-work benchmarks like OfficeQA-Pro. We chose these benchmarks because they stress the workflows our customers actually care about.
>
> *Oracle gap comparison across benchmarks*
> ![[mixedbread-oracle-gap-001.jpg]]
>
> ### BrowseComp-Plus
>
> [BrowseComp-Plus](https://arxiv.org/abs/2508.06600) measures deep-research agents on multi-hop questions over a corpus of roughly 100,000 web documents. It is designed specifically to separate retrieval quality from model capability.
>
> | Retriever | Scaffold | Accuracy | Gap to Oracle (93.5%) |
> | ----- | ----- | ----- | ----- |
> | **Mixedbread Search** | **get\_document** | **90.48%** | **3.02** |
> | Reason-ModernColBERT | get\_document | 87.59% | 5.9 |
> | Mixedbread Search | standard | 80.00 | 13.5 |
> | Reason-ModernColBERT | standard | 79.52 | 13.98 |
> | Qwen3-Embed-8B | standard | 71.69% | 21.81 |
>
> Mixedbread Search v3 **ranks #1** on the [leaderboard](https://huggingface.co/spaces/Tevatron/BrowseComp-Plus) in both settings: with the default standardized benchmarking scaffold, and with the stronger agentic scaffold where the model can read the full document behind each retrieved snippet.
>
> Notably, the gap between Mixedbread Search and other retrieval approaches widens under the better harness. That suggests retrieval is less often the limiting factor, and that more of the remaining headroom lies in the overall agent setup. In practice, that means teams can spend less time debugging retrieval and more time improving the rest of their system.
>
> ### MADQA
>
> [MADQA](https://arxiv.org/abs/2603.12180), released just last week, tests whether agents can navigate more than 18,000 pages from 800 heterogeneous PDFs to answer 500 human-authored questions. The benchmark is inherently multimodal: models are given screenshots of PDF pages, and the dataset is designed to reflect complex in-domain knowledge across areas like financial reports and legal documents.
>
> It can be run in two settings. In one-turn mode, the model gets a single search call before it must answer. In agentic mode, the model is given up to ten turns, with metrics that explicitly measure the tradeoff between answer quality and effort, a proxy for both token cost and system speed.
>
> | Model | Retriever | Accuracy | Gap to Oracle (99.4%) | Page F1 |
> | ----- | ----- | ----- | ----- | ----- |
> | Human w/ Oracle Retriever | Oracle | 99.4% | 0.0 | - |
> | Button, an agentic document-QA system built on Gemini 3.1 Pro (Agentic) | **Hybrid w/ Mixedbread** | **91.7%** | **7.7** | **86.9** |
> | Gemini 3 Pro (One-shot RAG) | **Mixedbread** | **88.2%** | **11.2** | **82.2** |
> | Human w/ BM25 | BM25 | 82.2% | 17.2 | 79.3 |
> | Claude Sonnet 4.5 (Agentic) | BM25 | 80.6% | 18.8 | 79.1 |
> | Gemini 3 Pro (Preview) with File Search | Google Files Search | 78.6 | 20.8 | 70.1 |
>
> On the current MADQA [leaderboard](https://huggingface.co/spaces/Snowflake/MADQA-Leaderboard), Mixedbread-powered systems occupy the top spots in each category, with only a human using oracle documents outperforming them. In the single-search setting, Gemini 3 Pro with Mixedbread outperforms human experts who are allowed up to 10 BM25 searches.
>
> Gemini 3 Pro also gains nearly 10 points of accuracy with Mixedbread compared to Google's File Search API. Notably, the top-performing system, Button, is not ours: [Distyl AI](https://distyl.ai/) paired Mixedbread Search with its own harness and reached state-of-the-art results without further tuning.
>
> Taken together, these results suggest that Mixedbread Search is effective at surfacing the evidence agentic workflows need, including on heterogeneous, multimodal corpora.
>
> ### OfficeQA-Pro
>
> Finally, [OfficeQA-Pro](https://arxiv.org/abs/2603.08655) is a specialized enterprise knowledge-work benchmark designed by Databricks. It contains 89,000 pages of complex financial documents, including U.S. Treasury Bulletins, dense tables, and scanned PDFs, along with questions that require multi-document reasoning to answer satisfactorily.
>
> We wanted to measure the effect of retrieval quality inside a widely used tool: OpenAI's Codex. So we ran the benchmark in the same Codex-based setup while varying only the retrieval tooling: a corpus baseline, where the raw corpus is stored on disk as OCR plus PDF images and Codex uses its usual tools; an oracle setting, where the model is given all correct documents; and Mixedbread Search-based retrieval.
>
> This setup does not isolate retrieval as cleanly as the other benchmarks, which were designed specifically for that purpose. Still, we think it is informative because OfficeQA documents are unusually difficult, and because many teams rely on agents' native "no-RAG" context tools in similar settings.
>
> | Method | Correctness | Gap to Oracle | Latency (min) | Tool Calls |
> | ----- | ----- | ----- | ----- | ----- |
> | Codex (Oracle, thinking high) | 65.41 | - | 2.2* | 20.7* |
> | **Codex (Mixedbread, thinking high)** | **64.42** | **0.99** | **2.36** | **17.35** |
> | Codex (Corpus, thinking high) | 56.39 | 9.02 | 3.6 | 34.5 |
> | GPT 5.4 Agent + Semantic Search ** | 51.90 | 13.51 | 8.93 | 86.4 |
>
> With all other settings held equal, Mixedbread comes close to the oracle setting while materially reducing latency and tool use. Compared with Codex's built-in retrieval over the corpus, Mixedbread recovers 89% of the gap between the corpus baseline and oracle (8.03 of 9.02 points) while cutting latency by 34% and reducing tool calls by roughly half.
>
> Within the same harness, Mixedbread Search moves the agent substantially closer to oracle with less search effort.
>
> *: performance reported from paper
> **: using Databricks agent (from paper)
>
> ## More Limits to Overcome
>
> Even with these results, knowledge work is far from solved. Hard cases remain: ambiguous queries, genuinely missing evidence, messy enterprise corpora, and tasks where the core difficulty is not finding documents but reasoning correctly over them once found.
>
> Closing the oracle gap does not eliminate system failures, and it does not fully eliminate retrieval failures either. But as the gap shrinks, the source of failure shifts. When retrieval is less often the bottleneck, more of the remaining headroom moves to reasoning, prompting, and domain-specific system design, which is where teams are often best served spending their effort.
>
> **One API**
>
> To make retrieval one less thing teams have to manage, we built Mixedbread Search behind a simple API:
>
> **Python:**
> ```python
> from mixedbread import Mixedbread
> from pathlib import Path
>
> client = Mixedbread()
>
> # Index documents (any modality)
> client.stores.files.upload(
>     store_identifier="my-store",
>     file=Path("doc.pdf")
> )
>
> # Search
> results = client.stores.search(
>     store_identifiers=["my-store"],
>     query="quarterly revenue growth",
> )
> ```
>
> **TypeScript:**
> ```typescript
> const client = new Mixedbread();
>
> // Index documents (any modality)
> await client.stores.files.upload({
>     storeIdentifier: "my-store",
>     file: fs.createReadStream("doc.pdf")
> });
>
> // Search
> const results = await client.stores.search({
>     store_identifiers: ["my-store"],
>     query: "quarterly revenue growth",
> });
> ```
>
> No chunking decisions, embedding model choices, image preprocessing, vector database configuration, or reranker threshold tuning.
>
> We handle multimodal ingestion, late-interaction encoding, indexing, and retrieval. You upload documents and start searching. To get started just [sign up](https://www.platform.mixedbread.com/).
>
> We are building Mixedbread to close the gap between the search that is possible today and what users and agents of tomorrow will demand. If that sounds like a problem you want to work on, we are [hiring](https://mixedbread.com/careers).
>
> [Original blog post](https://mixedbread.com/blog/closing-gap)
