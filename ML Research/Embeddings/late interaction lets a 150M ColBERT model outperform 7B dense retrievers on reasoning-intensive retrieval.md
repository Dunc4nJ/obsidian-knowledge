---
created: 2026-03-23
description: Reason-ModernColBERT, a 150M-parameter late-interaction model built on ModernBERT, outperforms all dense retrieval models up to 7B on the BRIGHT reasoning-intensive benchmark by leveraging ColBERT's multi-vector MaxSim architecture
source: https://huggingface.co/lightonai/Reason-ModernColBERT
type: learning
---

## Key Takeaways

Reason-ModernColBERT demonstrates that late interaction (ColBERT-style multi-vector retrieval) is dramatically more effective than single-vector dense retrieval for reasoning-intensive tasks. On the BRIGHT benchmark, this 150M model achieves a 27.43 mean NDCG@10 on Stack Exchange splits — outperforming ReasonIR-8B (24.76), a model more than 50 times its size trained on the same data. This is the strongest empirical evidence yet for the argument that [[ColBERT MaxSim is a submodular facility location objective and that is why it generalizes]] — the architectural advantage of per-token matching compounds when queries require multi-hop reasoning across document facets.

The controlled experiment comparing dense vs late-interaction training on identical data and base model (GTE-ModernColBERT-v1) shows a staggering gap: 12.31 vs 19.61 full mean NDCG@10. The dense model collapses on Stack Exchange splits (11.86 mean) while late interaction holds at 24.86. This confirms that [[scaling embedding models requires LLM-labeled deduplication to fix the fake negative problem]] is only half the story — even with perfect data, the single-vector bottleneck fundamentally limits reasoning-intensive retrieval.

The model benefits even more than ReasonIR-8B from GPT-4 reasoning traces (+7.66 vs +5.58 NDCG@10), reaching 30.28 full mean and top-1 overall. However, it struggles with very long queries due to MaxSim's asymmetric nature — query tokens attend to all document tokens but the 128-token query length caps representational capacity. This limitation suggests that late interaction's strength (fine-grained token matching) becomes a weakness when the query itself needs to be compressed.

The model is a PyLate fine-tune of LightOn's GTE-ModernColBERT-v1, trained on ~100K samples from the ReasonIR-HQ dataset for only 3 epochs with a batch size of 256. The entire fine-tuning takes under 2 hours. The cc-by-nc-4.0 license on the ReasonIR data constrains the release, but the training recipe is fully reproducible under Apache 2.0 using publicly available code to regenerate the data.

## External Resources

- [ReasonIR-HQ Dataset](https://huggingface.co/datasets/reasonir/reasonir-data) — the training data (100K query/positive/negative triples for reasoning-intensive retrieval)
- [BRIGHT Benchmark](https://huggingface.co/datasets/xlangai/BRIGHT) — reasoning-intensive retrieval evaluation across Stack Exchange, coding, and theorem proving
- [GTE-ModernColBERT-v1](https://huggingface.co/lightonai/GTE-ModernColBERT-v1) — the base model before fine-tuning
- [ReasonIR-8B](https://huggingface.co/reasonir/ReasonIR-8B) — the 8B dense comparison model trained on the same data
- [PyLate](https://github.com/lightonai/pylate) — the training and inference library for ColBERT models
- [Reproduction boilerplate](https://gist.github.com/NohTow/d563244596548bf387f19fcd790664d3) — fine-tuning script to reproduce under Apache 2.0
- [ReasonIR data generation code](https://github.com/facebookresearch/ReasonIR/tree/main/synthetic_data_generation) — to regenerate training data without license restrictions

## Original Content

> [!quote]- Source Material
> 
> Reason-ModernColBERT is a late interaction model trained on the [reasonir-hq](https://huggingface.co/datasets/reasonir/reasonir-data) dataset.
> It achieves extremely competitive performance on the [BRIGHT benchmark](https://huggingface.co/datasets/xlangai/BRIGHT) aimed at evaluating reasoning-intensive retrieval performance, outperforming all existing models up to 7B (more than 45 times its size) and even surprisingly improving performance of [ReasonIR-8B](https://huggingface.co/reasonir/ReasonIR-8B) (a 8B model trained on the same data) by more than 2.5 NDCG@10 on average on Stack Exchange splits. We attribute such strong results to late-interaction, see evaluation section.
> 
> ## License
> 
> Unfortunately, since the [ReasonIR data](https://huggingface.co/datasets/reasonir/reasonir-data) has been released under a cc-by-nc-4.0 license, we cannot release this model under an Apache 2.0 license. However, the authors of ReasonIR [released code to generate the data](https://github.com/facebookresearch/ReasonIR/tree/main/synthetic_data_generation). Anyone willing to reproduce the data could then easily reproduce this model under an Apache 2.0 license by running a fine-tuning lasting lower than 2 hours using [this boilerplate](https://gist.github.com/NohTow/d563244596548bf387f19fcd790664d3).
> 
> ## PyLate model based on lightonai/GTE-ModernColBERT-v1
> 
> This is a [PyLate](https://github.com/lightonai/pylate) model finetuned from [lightonai/GTE-ModernColBERT-v1](https://huggingface.co/lightonai/GTE-ModernColBERT-v1) on the [reasonir-hq](https://huggingface.co/datasets/reasonir/reasonir-data) dataset. It maps sentences & paragraphs to sequences of 128-dimensional dense vectors and can be used for semantic textual similarity using the MaxSim operator.
> 
> ## Model Details
> 
> ### Model Description
> 
> - Model Type: PyLate model
> - Base model: [lightonai/GTE-ModernColBERT-v1](https://huggingface.co/lightonai/GTE-ModernColBERT-v1)
> - Document Length: 8192 tokens
> - Query Length: 128 tokens
> - Output Dimensionality: 128 tokens
> - Similarity Function: MaxSim
> - Training Dataset: [reasonir-hq](https://huggingface.co/datasets/reasonir/reasonir-data)
> - Language: en
> 
> ### Model Sources
> 
> - Documentation: [PyLate Documentation](https://lightonai.github.io/pylate/)
> - Repository: [PyLate on GitHub](https://github.com/lightonai/pylate)
> - Hugging Face: [PyLate models on Hugging Face](https://huggingface.co/models?library=PyLate)
> 
> ### Full Model Architecture
> 
> ```
> ColBERT(
>   (0): Transformer({'max_seq_length': 127, 'do_lower_case': False}) with Transformer model: ModernBertModel
>   (1): Dense({'in_features': 768, 'out_features': 128, 'bias': False, 'activation_function': 'torch.nn.modules.linear.Identity'})
> )
> ```
> 
> ## Usage
> 
> First install the PyLate library:
> 
> ```bash
> pip install -U pylate
> ```
> 
> ### Retrieval
> 
> PyLate provides a streamlined interface to index and retrieve documents using ColBERT models. The index leverages the Voyager HNSW index to efficiently handle document embeddings and enable fast retrieval.
> 
> #### Indexing documents
> 
> ```python
> from pylate import indexes, models, retrieve
> 
> model = models.ColBERT(
>     model_name_or_path=pylate_model_id,
> )
> 
> index = indexes.Voyager(
>     index_folder="pylate-index",
>     index_name="index",
>     override=True,
> )
> 
> documents_ids = ["1", "2", "3"]
> documents = ["document 1 text", "document 2 text", "document 3 text"]
> 
> documents_embeddings = model.encode(
>     documents,
>     batch_size=32,
>     is_query=False,
>     show_progress_bar=True,
> )
> 
> index.add_documents(
>     documents_ids=documents_ids,
>     documents_embeddings=documents_embeddings,
> )
> ```
> 
> #### Retrieving top-k documents for queries
> 
> ```python
> retriever = retrieve.ColBERT(index=index)
> 
> queries_embeddings = model.encode(
>     ["query for document 3", "query for document 1"],
>     batch_size=32,
>     is_query=True,
>     show_progress_bar=True,
> )
> 
> scores = retriever.retrieve(
>     queries_embeddings=queries_embeddings,
>     k=10,
> )
> ```
> 
> ### Reranking
> 
> ```python
> from pylate import rank, models
> 
> queries = ["query A", "query B"]
> documents = [["document A", "document B"], ["document 1", "document C", "document B"]]
> documents_ids = [[1, 2], [1, 3, 2]]
> 
> model = models.ColBERT(model_name_or_path=pylate_model_id)
> queries_embeddings = model.encode(queries, is_query=True)
> documents_embeddings = model.encode(documents, is_query=False)
> 
> reranked_documents = rank.rerank(
>     documents_ids=documents_ids,
>     queries_embeddings=queries_embeddings,
>     documents_embeddings=documents_embeddings,
> )
> ```
> 
> ## Evaluation
> 
> ### BRIGHT Benchmark
> 
> The BRIGHT benchmark is aimed at evaluating reasoning-intensive retrieval performance. Reason-ModernColBERT outperforms all existing models up to 7B (more than 45 times its size) and even surprisingly improving performance of ReasonIR-8B (a 8B model trained on the same data) by more than 2.5 NDCG@10 on average on Stack Exchange splits.
> 
> | Model / Metric | Biology | Earth | Economics | Psychology | Robotics | Stackoverflow | Sustainable | Leetcode | Pony | AoPS | Theorem-Q | Theorem-T | Mean SE | Mean coding | Mean theorem | Full mean |
> |---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
> | BM25 | 18.9 | 27.2 | 14.9 | 12.5 | 13.6 | 18.4 | 15 | 24.4 | 7.9 | 6.2 | 10.4 | 4.9 | 17.21 | 16.15 | 7.17 | 14.53 |
> | BGE | 11.7 | 24.6 | 16.6 | 17.5 | 11.7 | 10.8 | 13.3 | 26.7 | 5.7 | 6 | 13 | 6.9 | 15.17 | 16.2 | 8.63 | 13.71 |
> | Inst-L | 15.2 | 21.2 | 14.7 | 22.3 | 11.4 | 13.3 | 13.5 | 19.5 | 1.3 | 8.1 | 20.9 | 9.1 | 15.94 | 10.4 | 12.7 | 14.21 |
> | SBERT | 15.1 | 20.4 | 16.6 | 22.7 | 8.2 | 11 | 15.3 | 26.4 | 7 | 5.3 | 20 | 10.8 | 15.61 | 16.7 | 12.03 | 14.9 |
> | E5 | 18.6 | 26 | 15.5 | 15.8 | 16.3 | 11.2 | 18.1 | 28.7 | 4.9 | 7.1 | 26.1 | 26.8 | 17.36 | 16.8 | 20 | 17.93 |
> | SFR | 19.1 | 26.7 | 17.8 | 19 | 16.3 | 14.4 | 19.2 | 27.4 | 2 | 7.4 | 24.3 | 26 | 18.93 | 14.7 | 19.23 | 18.3 |
> | Inst-XL | 21.6 | 34.3 | 22.4 | 27.4 | 18.2 | 21.2 | 19.1 | 27.5 | 5 | 8.5 | 15.6 | 5.9 | 23.46 | 16.25 | 10 | 18.89 |
> | GritLM | 24.8 | 32.3 | 18.9 | 19.8 | 17.1 | 13.6 | 17.8 | 29.9 | 22 | 8.8 | 25.2 | 21.2 | 20.61 | 25.95 | 18.4 | 20.95 |
> | Qwen | 30.6 | 36.4 | 17.8 | 24.6 | 13.2 | 22.2 | 14.8 | 25.5 | 9.9 | 14.4 | 27.8 | 32.9 | 22.8 | 17.7 | 25.03 | 22.51 |
> | Cohere | 18.7 | 28.4 | 20.4 | 21.6 | 16.3 | 18.3 | 17.6 | 26.8 | 1.9 | 6.3 | 15.7 | 7.2 | 20.19 | 14.35 | 9.73 | 16.6 |
> | OpenAI | 23.3 | 26.7 | 19.5 | 27.6 | 12.8 | 14.3 | 20.5 | 23.6 | 2.4 | 8.5 | 23.5 | 11.7 | 20.67 | 13 | 14.57 | 17.87 |
> | Voyage | 23.1 | 25.4 | 19.9 | 24.9 | 10.8 | 16.8 | 15.4 | 30.6 | 1.5 | 7.5 | 27.4 | 11.6 | 19.47 | 16.05 | 15.5 | 17.91 |
> | Google | 22.7 | 34.8 | 19.6 | 27.8 | 15.7 | 20.1 | 17.1 | 29.6 | 3.6 | 9.3 | 23.8 | 15.9 | 22.54 | 16.6 | 16.33 | 20 |
> | ReasonIR-8B | 26.2 | 31.4 | 23.3 | 30 | 18 | 23.9 | 20.5 | 35 | 10.5 | 14.7 | 31.9 | 27.2 | 24.76 | 22.75 | 24.6 | 24.38 |
> | **Reason-ModernColBERT (150M)** | **33.25** | **41.02** | **24.93** | **30.73** | **21.12** | **20.62** | **20.31** | **31.07** | **8.51** | **9.17** | **19.51** | **11.24** | **27.43** | **19.79** | **15.38** | **22.62** |
> 
> #### Comparison with a dense model
> 
> A fair claim would be that the performance of Reason-ModernColBERT are mostly due to the ReasonIR data. Although the differences between ReasonIR-8B and Reason-ModernColBERT already hint that it is most likely more than just that, we conducted a small experiment by training a dense (single vector) model in the same setup using Sentence Transformers as a multi-vector one trained using PyLate. This experiment highlights a very large gap in performance.
> 
> | Model/Split | Biology | Earth | Economics | Psychology | Robotics | Stackoverflow | Sustainable | Leetcode | Pony | AoPS | Theorem Q | Theorem T | Mean SE | Mean coding | Mean theorem | Full mean |
> |---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
> | Dense (single vector) | 7.51 | 16.92 | 13.43 | 17.18 | 10.23 | 8.93 | 8.85 | 24.88 | 1.43 | 9.81 | 18.83 | 9.71 | 11.86 | 13.16 | 12.78 | 12.31 |
> | Late-interaction (multi vector) | 28.02 | 39.25 | 21.51 | 27.05 | 19.86 | 17.23 | 21.1 | 27.37 | 3.76 | 6.87 | 16.06 | 7.21 | 24.86 | 15.57 | 10.05 | 19.61 |
> 
> #### GPT4 reasoning trace
> 
> Although those models are able to do some reasoning-intensive matching, it has been shown that they greatly benefit from using the reasoning trace/query reformulation from a LLM such as GPT4. Here are the results of Reason-ModernColBERT on this setup:
> 
> | Model | Biology | Earth | Economics | Psychology | Robotics | Stackoverflow | Sustainable | Leetcode | Pony | AoPS | Theorem Q | Theorem T | Mean SE | Mean Code | Mean Theorem | Full mean |
> |---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|---|
> | BM25 | 53.6 | 53.6 | 24.3 | 38.6 | 18.8 | 22.7 | 25.9 | 19.3 | 17.7 | 3.9 | 20.2 | 18.9 | 33.93 | 18.5 | 19.55 | 26.46 |
> | Contriever | 37.5 | 40.5 | 22.6 | 27.1 | 15.2 | 22.6 | 19.6 | 22.5 | 13.8 | 8.1 | 24.1 | 16.2 | 26.44 | 18.15 | 20.15 | 22.48 |
> | GritLM-7B | 33.2 | 33 | 23.3 | 30.6 | 15.2 | 17.5 | 21.7 | 33.2 | 11.7 | 6.8 | 26.9 | 28 | 24.93 | 22.45 | 27.45 | 23.425 |
> | RankLLaMA-7B (top-100) | 17.5 | 15.5 | 13.1 | 13.6 | 17.9 | 6.9 | 16.9 | 8.4 | 46.8 | 2.2 | 4.5 | 3.5 | 14.49 | 27.6 | 4 | 13.9 |
> | Rank1-7B (top-100) | 48.8 | 36.7 | 20.8 | 35 | 22 | 18.7 | 36.2 | 12.7 | 31.2 | 6.3 | 23.7 | 37.8 | 31.17 | 21.95 | 30.75 | 27.49 |
> | Rank1-32B (top-100) | 49.7 | 35.8 | 22 | 37.5 | 22.5 | 21.7 | 35 | 18.8 | 32.5 | 10.8 | 22.9 | 43.7 | 32.03 | 25.65 | 33.3 | 29.41 |
> | ReasonIR-8B | 43.6 | 42.9 | 32.7 | 38.8 | 20.9 | 25.8 | 27.5 | 31.5 | 19.6 | 7.4 | 33.1 | 35.7 | 33.17 | 25.55 | 34.4 | 29.96 |
> | **Reason-ModernColBERT** | **61.54** | **56.79** | **26.2** | **43.79** | **20.76** | **31.61** | **29.12** | **27.46** | **8.31** | **8.26** | **26.46** | **23.07** | **38.54** | **17.885** | **24.765** | **30.28** |
> 
> As highlighted by these results, Reason-ModernColBERT benefits greatly from using those traces (+7.66 NDCG@10 in average) even more than ReasonIR-8B (+5.58). It thus reaches top-1 by closing the gap and outperforms it on this setup, as well as outperforming methods based on reranking with 7B models.
> 
> However, it should be noted that these experiments also highlighted that Reason-ModernColBERT does not scale very well to very large queries (while ColBERT models are known to generalize very well to large documents), most probably due to the asymmetric nature of the MaxSim operator. Training the model on longer and more diverse lengths of queries, such as in the VL split of the ReasonIR data, is a promising avenue to better leverage these extensive queries/reasoning trace.
> 
> ## Training Details
> 
> ### Training Dataset
> 
> - Dataset: [reasonir-hq](https://huggingface.co/datasets/reasonir/reasonir-data) at 0275f82
> - Size: 100,521 training samples
> - Columns: query, pos, and neg
> 
> ### Training Hyperparameters
> 
> - per_device_train_batch_size: 256
> - learning_rate: 1e-05
> - bf16: True
> - num_train_epochs: 3
> - Loss: pylate.losses.cached_contrastive.CachedContrastive

[Source](https://huggingface.co/lightonai/Reason-ModernColBERT)
