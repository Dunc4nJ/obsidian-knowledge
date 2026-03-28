---
created: 2026-03-26
description: Late interaction (multi-vector) models like ColBERT solve the LIMIT benchmark that exposes an intrinsic geometric limitation of single-vector dense retrieval models.
source: https://x.com/antoine_chaffin/status/2037195994081673316
type: synthesis
---

## Key Takeaways

Dense (single-vector) retrieval models compress all document information into one point in high-dimensional space. The LIMIT paper from Google DeepMind proves, both theoretically and empirically, that the number of distinct relevance patterns a single vector can represent is bounded by its embedding dimension. No amount of better training can overcome this — it is a geometric ceiling, not a training deficiency.

Multi-vector models like ColBERT keep one vector per token and use MaxSim scoring, which provides a much richer similarity signal. Corrected evaluations show GTE-ModernColBERT hits 99.5 R@100 on LIMIT (essentially solving it), while dense models barely manage 20%. BM25 also solves LIMIT easily due to per-token matching, but fails on synonym variations where ColBERT succeeds.

The corrected results came from fixing a bug in the MTEB evaluation pipeline. The original paper's ColBERT numbers were run on a buggy MTEB version, underreporting late interaction model performance. This is a cautionary tale about evaluation infrastructure reliability.

Not all multi-vector models are equal — ColBERT-v2 scores significantly worse than newer models despite using the same MaxSim architecture. The architecture creates potential but doesn't guarantee performance. MixedBread's Wholembedv3 (17M params) achieving 98 R@100 is particularly impressive.

PyLate extends Sentence Transformers to late interaction models, making it straightforward to adopt multi-vector retrieval with existing code and data pipelines.

## External Resources

- [LIMIT paper (ICLR)](https://x.com/antoine_chaffin/status/2037195994081673316) — original Google DeepMind paper demonstrating dense model limitations
- [PyLate library](https://lightonai.github.io/pylate/) — extends Sentence Transformers for late interaction model training and evaluation
- [Wholembedv3 by MixedBread](https://x.com/mixedbreadai/status/2032127466081567106) — multi-vector omni model with strong LIMIT results
- [MTEB ColBERT bug fix PR](https://github.com/embeddings-benchmark/mteb/pull/3711) — the evaluation bug that caused incorrect original results

## Original Content

> [!quote]- Source Material
>
> **@antoine_chaffin (Antoine Chaffin)** — Thu Mar 26, 2026 · 118 likes · 21 retweets
>
> Article: Late interaction models have no LIMIT: a story about benchmarks, bugs and better retrieval
>
> How a toy synthetic dataset, a broken evaluation and one model breaking the ceiling sparked a conversation worth having
>
> Tl;Dr: Evaluations are hard and it is easy to get results wrong. Final results show that strong late interaction models already solve LIMIT. However, don't dismiss it as a toy. The theoretical result at its core is rock solid: single-vector dense models have a fundamental, dimension-bound ceiling on what retrieval combinations they can represent, and no amount of better training will fix that. In a world where retrieval is increasingly asked to handle semi-structured, attribute-rich, or instruction-driven queries, that's a limitation worth taking seriously.
>
> Last year, researchers from Google DeepMind (including my dear friend @orionweller) released a paper that has now been accepted to ICLR (congratulations!).
>
> This paper is very insightful because it demonstrates, theoretically AND empirically that dense (single) vector models for retrieval have fundamental limitations.
> More than a simple claim, they released a dataset called LIMIT to highlight these limitations. This dataset is absurdly simple and yet, state-of-the-art models topping the usual competitive benchmarks barely manage to hit 20% of Recall@100 (!). On the other hand, BM25, a simple lexical approach solve the dataset without much issue, highlighting its simplicity and showcasing that it is more of a limitation of the dense models than really an hard task. In the same vein, late interaction models, also referred to as multi-vector retrieval, despite achieving worse results than BM25, exhibits much stronger results, exhibiting that they do not suffer the same limitations.
>
> Fast forward to two weeks ago, where @mixedbreadai released their new embedding model, hitting 98 of R@100 (basically solving the LIMIT dataset) , which is a very strong results!
> ... and @matospiso sharing that actually, GTE-ModernColBERT (the late interaction model that we built and is used in the original paper) actually hits 99.5 of R@100!
>
> So what happens? Which results are correct? What does these results tell us? Should we care about LIMIT results?
> Let me break it down for you!
>
> ### Why Dense Models Hit a Wall
>
> The construction of the LIMIT datasetis deliberately simple by design. The authors generated a list of 1,850 random attributes a person could like (Hawaiian pizza, sports cars, that kind of thing). They then created 50,000 fictional people, each assigned a random first and last name and a handful of these attributes. Queries are of the form "Who likes [attribute]?", and the relevant documents are the people who have that attribute listed in their description. The key design choice is the qrel matrix, the mapping of which documents are relevant to which queries. Rather than assigning relevance arbitrarily, the authors chose 46  "special" documents and made sure that every possible pair among those 46 appears as the relevant set for exactly one query. The result is a fully exhaustive combination space: every way of picking 2 documents out of those 46 is a valid query in the dataset. That's what makes it hard: a model must correctly learn to separate each of the 1,035 distinct pairings from the other 49,954 documents in the corpus, and it must get all of them right. Getting good at returning Jon and Ovid for "who likes quokkas?" gives you no shortcut for returning Jon and Leslie for "who likes apples?", every pair is its own independent retrieval problem.
>
> So the failure is not really about semantic/language understanding. The existing models understand the queries and documents of the LIMIT dataset just fine. The problem is actually... geometric!
>
> Dense models compress all of the information into a single vector, a single point in a high-dimensional space. They then measure the relevance between a query and a document by computing the cosine similarity between them.
>
> The question raised by the paper is how many distinct "who's relevant" patterns this single vector can actually capture and represent.
> I am skipping all the complicated math (I'm rather bad at math, anyways), but the authors show that it is directly tied to the dimension of the embeddings. The more your dataset requires modelling different combinations, the higher the embedding dimension needs to be. And LIMIT is built exactly to showcase this: it's built so it is mathematically impossible for existing model dimensions to solve it, there is too many combinations for too few dimensions.*
>
> This is not a limitation of the training of the models, this is an intrinsic limitation of dense vector models. You can create the vector the way you want, you won't solve LIMIT.
>
> *Actually, the current version of LIMIT is theoretically solvable with embeddings of dimension 12. The same conclusion holds nonetheless, because we just need to scale the dataset a bit to make it arbitrarily harder to a point that won't be solvable for a given dimension. The current small limit is due to the dataset being very small. Actually, it makes an even stronger case: even though the current models could solve the existing dataset, their really poor performances highlight that, in addition to these limitations, the single vector models are not properly trained anyways.
>
> ### Why BM25 and Multi-Vector Models Do Better
>
> The previous explanation also explains why BM25 scores near-perfectly on LIMIT. BM25 uses one "dimension" per token, allowing to separate the various combinations of the LIMIT dataset without any issue.
>
> The main issue is that BM25 use exact (hard) matching. Thus, it manages to  correctly identify the combination, but only if the words used are the same. Swap one word for its synonym and the results drop.
>
> Multi-vector models (ColBERT models) are somewhat of a middle ground. Instead of one vector per document, we keep one vector per token and use the MaxSim operator (the sum, for each query token of its maximum similarity with one of the document tokens) to get a similarity score. This is much richer than a simple cosine similarity and is intuitively more suited to LIMIT: we can match the tokens to create the different combinations as with BM25 but, contrary to BM25, we can also match to other tokens that are not the exact same but are semantically close. This is illustrated in the paper with the LIMIT small (synonym) dataset, where BM25 drops lower than GTE-ModernColBERT.
> However, for the version that uses the same words, BM25 seemed to have an edge and ColBERT models, despite being much stronger than dense models, still struggled a bit on this simple task.
>
> Time passed... and then something happened.
>
> ### Enter Wholembedv3, solving LIMIT
>
> Two weeks ago, @mixedbreadai [released Wholembedv3](https://x.com/mixedbreadai/status/2032127466081567106?s=20), a multi-vector omni model achieving very strong results on various tasks and modalities. Importantly, they [reported 98 R@100 on LIMIT](https://x.com/mixedbreadai/status/2032127502295203941?s=20), essentially solving the task, an impressive results considering the previous known results of ColBERT models. Considering it was a toy task and the model also achieve impressive results on other benches, it kind of made sense they could break the bench.
>
> Then @matospiso shared [some evaluations that he ran](https://x.com/matospiso/status/2032447591489671422?s=20) with several late interaction models and the numbers were much higher than what was reported in the paper for the GTE-ModernColBERT paper (actually achieving a near perfect score of 99.5 R@100). I was a bit surprised by those results, so I ran them myself using MTEB and... it turns out they are correct!
>
> ### What happened?
>
> At this point, maybe some context would be helpful. I'm one of the co-creator of the [PyLate library](https://lightonai.github.io/pylate/), used to train and evaluate the state-of-the-art late interaction models. I trained GTE-ModernColBERT and I also worked on building the MTEB integration that Orion (the paper's lead author) used to run his evaluations. So let's say that I was quite surprised by those results, especially as I ran a LIMIT evaluation just prior the release of MixedBread and the results were not outstanding.
>
> Considering that running MTEB evaluation right now with these models corroborates the results of the simple boilerplate of @matospiso, the logical conclusion is that the results reported in the paper are wrong. So what happened? Well, I can't tell for sure, but Orion probably ran the evaluation on a version of MTEB that had a bug (probably [this one](https://github.com/embeddings-benchmark/mteb/pull/3711), that I fixed later). So yeah, when correctly evaluated, some of the late interaction models already solve LIMIT.
>
> In my exploration, I also found something else worth mentioning: MTEB by default uses PLAID indexes for ColBERT-style models because MaxSim is much more expensive to run exact search than simple cosine. However, LIMIT's "full" corpus is only 50,000 documents, making the IVF estimation rather poor and tanking a bit the results. When we run an exact search GTE-ModernColBERT hits indeed nearly 100% while only 90% when using PLAID.
>
> ### What This All Means (And What It Doesn't)
>
> A tempting conclusion of this would be that we cannot draw any conclusions from the LIMIT results. However, I do not think this is entirely true and I think there are various things to learn from all of this:
>
> 1. Evaluations are hard. Anyone working in NLP knows this, and it's a real pain. That is why I am really happy to have merged PyLate into MTEB. Yes, it still can break (case in point), but it still gives a source of truth that allows anyone to easily run the benches and verify the results.
>
> 2. Dense models are doomed. The theoretical results of LIMIT still stand: single-vector models genuinely cannot represent all combinations of relevant documents. The fact that multi-vector models does not suffer this limitation does not mean we should forget that. And yes, LIMIT is a synthetic toy benchmark, but the capabilities it is studying is actually meaningful: semi-structured tasks are everywhere in practical retrieval use cases (and multi-vector models are solving much more than just LIMIT!).
>
> 3. Multi-vector models are not a guaranteed solution. Even with the corrected evaluation, not all late interaction models perform equally. ColBERT-v2, despite using the same MaxSim architecture, scores significantly worse than newer models on LIMIT. The architecture creates the potential for solving this kind of task; it doesn't guarantee it.  Yes ColBERT-v2 is old, but even one of our most recent late interaction models scored rather poorly on LIMIT (compared to the best ColBERT models, we are still much above dense models 😇). The scores achieved by the 17M model by MixedBread are thus very impressive.
>
> 4. Evaluations are hard (and really, you should stop using dense models).
>
> If you want to start using late interaction models and you are familiar with dense models and sentence transformers, [PyLate](https://lightonai.github.io/pylate/) should be your next step.
> It is a library that extends ST to late interaction models, so the code is essentially the same (you can re-use your existing data/code/setups).
>
> We already trained and released models (alongside code/data!) to train state-of-the-art models for [general domain/long context](https://x.com/antoine_chaffin/status/1917582078561997258?s=20), [reasoning-intensive](https://x.com/antoine_chaffin/status/1925555110521798925?s=20) (that actually showed SOTA on [deep research](https://x.com/antoine_chaffin/status/2034649565614272925?s=20) as well) and [code](https://x.com/antoine_chaffin/status/2021977663716380800?s=20) retrieval.
> Everything is open, so you have no excuses not trying out existing strong models and even train your own (and claim SOTAs using the [bug-free MTEB evaluation!](https://x.com/antoine_chaffin/status/2036470225848172838?s=20))
>
> [Source](https://x.com/antoine_chaffin/status/2037195994081673316)
