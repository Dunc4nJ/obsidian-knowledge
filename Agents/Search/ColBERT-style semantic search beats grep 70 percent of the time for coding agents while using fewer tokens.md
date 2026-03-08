---
created: 2026-03-08
description: Antoine Chaffin announces ColGREP and LateOn-Code models showing that ColBERT-style multi-vector semantic code search preferred 70% over grep with 15.7% fewer tokens and 56% fewer search operations.
source: https://x.com/antoine_chaffin/status/2021977663716380800
type: learning
---

## Key Takeaways

The core problem ColGREP solves is the identifier mismatch: when an agent asks "where is the caching logic?" but the function is called `_build_lru_store`, grep can't find it on the first try. Agents waste thousands of tokens on trial-and-error grep cycles — guessing identifiers, refining patterns, reading wrong files, backtracking. This is [[searching more and thinking less improves agentic efficiency and generalization|the same pattern]] where brute-force search burns tokens that could be spent reasoning.

ColBERT-style models preserve per-token representations instead of collapsing everything into a single vector, giving them both the soft-matching power of embeddings and the fine-grained matching of lexical search. This is particularly well-suited to code, where structure is rigid but intent and syntax rarely share vocabulary. The [[resources/ColGREP|ColGREP]] tool wraps this in a grep-compatible CLI so agents can use it without learning a new interface.

The efficiency of the models is striking: the 17M parameter LateOn-Code-edge model (based on mixedbread's Ettin ColBERT) outperforms 149M models (9x bigger), only falling short of EmbeddingGemma-300M. The 149M LateOn-Code model competes with 500-600M LLM-based retrievers. Both run locally on CPU — no GPU, no API, no server.

The hybrid search mode is the key practical insight: regex narrows candidates, semantics re-ranks them. The biggest gains come on hard behavioral queries ("error handling in API layer"), while grep still wins on trivial identifier lookups. ColGREP subsumes grep rather than replacing it — hybrid beats either alone.

Benchmarked across 135 questions on 7 repos: answers with ColGREP preferred 70% of the time, 15.7% fewer tokens, 56% fewer search operations. At scale that's ~$243 saved per 1,000 questions.

Everything is open-sourced: models, training data (CoRNStack + CoIR with nv-retriever negatives), training recipes, and the ColGREP harness itself. The tool supports any PyLate model, so it's extensible beyond code retrieval.

## External Resources

- [Announcement thread](https://x.com/antoine_chaffin/status/2021977663716380800) — full thread with benchmarks and context
- [LightOn blog post](https://lighton.ai/blog/colgrep) — detailed writeup
- [HuggingFace collection](https://huggingface.co/collections/lightonai/lateon-code) — models and training data
- [ColGREP GitHub](https://github.com/lightonai/next-plaid/tree/main/colgrep) — the tool itself
- [Training code](https://github.com/lightonai/late-interaction-code) — full training recipes
- [NextPlaid](https://github.com/lightonai/next-plaid) — the Rust multi-vector database engine underneath

## Original Content

> [!quote]- Source Thread — @antoine_chaffin, Feb 12 2026 (422 likes, 48 RTs)
>
> **@antoine_chaffin:** Your coding agent is burning tokens on grep like it's 1973. Because semantic search means remote APIs & babysitting an index. Introducing ColGrep & LateOn-Code. SOTA code retrieval with lightweight models. Wins 70% vs grep. 15.7% less tokens. Local, open & free. Runs on a toaster.
>
> *ColGREP announcement banner*
> ![[chaffin-380800-001.jpg]]
>
> ---
>
> **@antoine_chaffin:** Blog post: https://lighton.ai/blog/colgrep
> HF collection: https://huggingface.co/collections/lightonai/lateon-code
> Start saving token today: https://github.com/lightonai/next-plaid/tree/main/colgrep
>
> We release everything, the models, the training data, the recipes and most importantly, ColGrep, the harness to enhance your agent and save tokens
>
> *Release overview graphic*
> ![[chaffin-380800-002.jpg]]
>
> ---
>
> **@antoine_chaffin:** Agents waste thousands of tokens doing trial-and-error grep. They guess identifiers, refine patterns, grep again, read wrong files and backtrack. When a query is "where is the caching logic?" and the function is called `_build_lru_store`, grep has no chance on the first try
>
> *Agent grep failure example*
> ![[chaffin-380800-003.jpg]]
>
> ---
>
> **@antoine_chaffin:** ColBERT-style models keep per-token representations instead of crushing everything into one vector. Soft-matching power of embeddings + fine-grained matching of lexical search. Perfect for code, where there's rigid structure but intent and syntax rarely share the same words
>
> ---
>
> **@antoine_chaffin:** We pre-trained models on the CoRNStack data and then further refined them using nv-retriever negatives on the CoIR train sets. The smaller model, based on the 17M ColBERT model from @mixedbreadai outperforms 149M models (9x bigger), only falling short of EmbeddingGemma-300M
>
> *Model benchmark comparison chart*
> ![[chaffin-380800-004.jpg]]
>
> ---
>
> **@antoine_chaffin:** The bigger one is based on our (soon-to-be-released) in-house LateOn model is strongly outperforms EmbeddingGemma-300M and is competing with LLMs of 500-600M while being only 149M. Both models punch way above their weight and are small enough to run locally
>
> ---
>
> **@antoine_chaffin:** "Nice benchmarks. Does it work in practice?" Agents know grep, so ColGrep keeps the interface and add semantic ranking on top. Regex finds idiomatic retry patterns while semantic ranking surfaces intent about backoff logic. grep's precision + embedding's understanding
>
> ---
>
> **@antoine_chaffin:** Agents go wild with this and have no issue leveraging its effectiveness. We ran 135 questions (variable difficulty) across 7 repos. Answers generated with ColGrep were preferred 70% of the time, while using 15.7% fewer tokens on average and using 56% less search operations
>
> ---
>
> **@antoine_chaffin:** Tokens aren't free. On our 135 questions bench, we saved around 32$. As a rule of thumb, this means 243$/1k question. It starts to add up pretty quickly, especially given large team usages
>
> *Token cost savings breakdown*
> ![[chaffin-380800-005.jpg]]
>
> ---
>
> **@antoine_chaffin:** The most satisfying result is that the biggest gains are on the hardest questions that describe behavior, not function names, where embeddings really shines. On very simple queries where function names are within the query, however, grep still wins. That's why ColGrep subsumes grep rather than replacing it. Hybrid > either alone
>
> *Hard vs easy query performance comparison*
> ![[chaffin-380800-006.jpg]]
> ![[chaffin-380800-007.jpg]]
>
> ---
>
> **@antoine_chaffin:** ColGrep leverage NextPlaid under the hood, which means that even though it's multi-vector model, indexing and search is fast and easy. Coupled to powerful lightweight models, it means you can benefit from these results using only your laptop
>
> QT @raphaelsrty: Releasing NextPlaid today at @LightOnIO. It's a production-ready multi-vector database. NextPlaid lets you deploy an API in seconds using our pre-built containers. It embeds a multi-vector database and an inference engine for late-interaction models based on ONNX.
>
> ---
>
> **@antoine_chaffin:** As usual, everything is open for you to use and extends. Training code: https://github.com/lightonai/late-interaction-code. Collection with models and data: https://huggingface.co/collections/lightonai/lateon-code. But most importantly, just give it a try in ColGrep: https://github.com/lightonai/next-plaid/tree/main/colgrep. It's more than free, it saves you money
>
> ---
>
> **@antoine_chaffin:** Try it, break it, we deeply appreciate any feedback to make it better! As a closing note, although it has been built for code retrieval, we know agents are used for other tasks. Since ColGrep supports any PyLate models, you can extends agents with our other models, for example for you creative writing! Looking forward to see what people will build with it!
>
> ---
>
> **@antoine_chaffin:** Now is cc/thanks time! Obviously thanks to my awesome co-maintainer and creator of ColGrep, @raphaelsrty, he really went hard on this one. Thanks to @mixedbreadai (@rikiyatakehi @aaxsh18 @bclavie @drexalt) for building this cool small model out of Ettin, and also building mgrep, which is a great source of inspiration of this work. Thanks to @TarunSures41845 @gangi_official and @zach_nussbaum (and @nomic_ai) for CoRNStack. Thanks @AmelieTabatta @iacopo_poli and @tomaarsen for proof reading. Cc @fujikanaeda "the next release" is now out. And cc @baggiponte and @tiagoefreitas for finding out the easter egg during previous release :)
>
> ---
>
> **@antoine_chaffin:** Also cc to my old fellow late interaction enjoyers gang, it has been a while since our latest model releases, but we are back and we are going to have a lot in the next weeks. @helloiamleonie @17Ahmetyucel @doesdatmaksense @MehdiAllahyari @jobergum @vishal_learner @trillarnie @CShorten30 @tonywu_71 @ManuelFaysse
