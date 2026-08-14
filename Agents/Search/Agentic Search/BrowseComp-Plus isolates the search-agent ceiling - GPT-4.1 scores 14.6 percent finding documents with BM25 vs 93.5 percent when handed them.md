---
created: 2026-08-14
description: Hamel Husain's summary of Nandan Thakur's session — three tools for search-agent builders: ORBIT (a fully-synthetic eval-data pipeline that inverts question generation — describe an entity without naming it, verify multi-hop difficulty, ground every claim, and have an independent judge reproduce the answer from documents alone; 20,000 verified questions at zero API cost), Hawkeye (visual trajectory analytics — correct runs finish in far fewer search rounds than unresolved runs, which sets your max-rounds threshold), and BrowseComp-Plus, whose headline finding is that the retriever, not the model, limits accuracy: GPT-4.1 scores 14.6% finding documents via BM25 vs 93.5% when handed them.
source: https://hamel.dev/notes/llm/ai-product-engineering/context-search-agents.html
author: Hamel Husain (summarizing Nandan Thakur's session)
type: article
tags: [agentic-search, eval, synthetic-data, browsecomp, retrieval, trajectory-analysis, ai-product-engineering, hamel]
---

## Key Takeaways

- **ORBIT: synthetic eval data that's actually hard, verified three ways, at zero cost.** Naive synthetic question generation (generate questions from documents) yields single-search-answerable questions. ORBIT inverts it: *describe an entity's properties without naming it*, then verify each question requires multiple search hops, require the search agent to confirm every claim against a source document, and require an independent judge to reproduce the answer from those documents alone. 20,000 verified questions generated without paid search APIs or LLMs — a bootstrapping recipe for anyone with a corpus and no labels.

- **Hawkeye's one chart earns the tool: correct runs finish in far fewer search rounds than unresolved runs.** Which means the max-search-rounds threshold isn't a guess — it falls out of the distribution. (Under review, no artifact; Hamel's advice: have your coding agent build the equivalent for your own traces.) It's the search-agent version of trajectory-eyeballing as an irreplaceable debugging skill.

- **BrowseComp-Plus's finding is the thesis of the vault's whole search cluster: the retriever, not the model, is the ceiling.** GPT-4.1 scores **14.6% when it must find answer documents with BM25 search vs 93.5% when handed them directly** — a reproducible version of OpenAI's BrowseComp that isolates retrieval from reasoning. This is the controlled-experiment confirmation of [[coding agents are bottlenecked by search not coding ability]], the premise behind [[Dr-DCI caches BM25 hits into a bounded grep-able workspace, making fast corpus retrieval a harness-engineering differentiator for inference providers|Dr-DCI's harness bet]] and [[Context-1 proves agentic search can be 20B-scale and retrieval-dominant without frontier models|Context-1's retrieval-dominant design]], and the economics case of [[agents are the perfect slow searchers because LLM inference cost dominates per-query retrieval latency|agents-as-slow-searchers]].

## External Resources

- Original note: [How to Improve Search Agents — Hamel Husain](https://hamel.dev/notes/llm/ai-product-engineering/context-search-agents.html) ([AI Product Engineering series](https://hamel.dev/notes/llm/ai-product-engineering/))
- [Nandan Thakur's talk](https://maven.com/p/cbf1b6) · [ORBIT paper (arXiv 2604.01195)](https://arxiv.org/abs/2604.01195) / [repo](https://github.com/castorini/orbit) · [BrowseComp-Plus](https://texttron.github.io/BrowseComp-Plus/) · [OpenAI BrowseComp](https://openai.com/index/browsecomp/)

## Original Content

> [!quote]- Full note — "How to Improve Search Agents" (Hamel Husain; session by Nandan Thakur)
> _This note covers Nandan Thakur’s session in the [AI Product Engineering series](../../../notes/llm/ai-product-engineering/index.html)._
>
> [Nandan Thakur’s talk](https://maven.com/p/cbf1b6) covers three projects that are useful if you are building a search agent.
>
> The first is [ORBIT](https://arxiv.org/abs/2604.01195), a synthetic data pipeline you can use to bootstrap data for retrieval evals. Traditional synthetic data approaches generate questions from documents naively which generate questions that a single search can easily answer. ORBIT inverts the question instead. It describes an entity’s properties without naming it, then checks that each question is difficult enough to require multiple search hops to get right.
>
> The ORBIT approach also verifies every question by requiring the search agent to confirm each claim against a source document. Additionally, an independent judge must reproduce the answer from those documents alone. The approach is completely synthetic, which makes it promising for anyone without labeled data. The [ORBIT pipeline](https://github.com/castorini/orbit) generated 20,000 verified questions without spending anything on search APIs or paid LLMs, and you can reuse the recipe on your own corpus.
>
> The second is Hawkeye, a visual analytics interface for understanding agent trajectories (under review, no public artifact yet). It helps you catch errors in your search agents by showing how each run unfolds. In their analysis, correct runs needed far fewer search rounds than unresolved runs. A view like this lets you find the right threshold for max search rounds for your own agent. It’s a good idea to have your favorite coding agent build something similar for you.
>
> ![[hamel-search-agents-001.png]]
>
> Hawkeye’s search round distributions. Correct runs finish in far fewer rounds than unresolved runs.
>
> He also introduced [BrowseComp-Plus](https://texttron.github.io/BrowseComp-Plus/), a reproducible version of OpenAI’s [BrowseComp](https://openai.com/index/browsecomp/), a benchmark of hard fact-finding questions where the answer is short and easy to check but takes many searches to find. An important finding from this work is that the retriever limits accuracy more than the model does. When the authors gave a model the documents that contain the answer, it answered almost every question. GPT-4.1 scored 14.6% when it had to find those documents with BM25 search, and 93.5% when it was handed them directly.
>
> You can watch Nandan’s full talk [here](https://maven.com/p/cbf1b6).
