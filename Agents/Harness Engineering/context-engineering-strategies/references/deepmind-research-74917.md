---
created: 2026-03-02
source: https://deepmind.google/research/publications/74917/
arxiv: https://arxiv.org/abs/2402.09727
description: "ReadAgent: A human-inspired LLM agent system that uses episodic gist memory and interactive look-up to extend effective context length up to 20x for long-document comprehension."
authors:
  - Kuang-Huei Lee
  - Xinyun Chen
  - Hiroki Furuta
  - John Canny
  - Ian Fischer
venue: ICML 2024
publisher: Google DeepMind
date: 2024-02-15
tags:
  - agents
  - context-length
  - memory
  - reading-comprehension
  - gist-memory
  - long-context
---

# A Human-Inspired Reading Agent with Gist Memory of Very Long Contexts

> [!info] Paper Links
> - **DeepMind:** https://deepmind.google/research/publications/74917/
> - **arXiv:** https://arxiv.org/abs/2402.09727
> - **Project website:** https://read-agent.github.io

## Abstract

Current Large Language Models (LLMs) are not only limited to some maximum context length, but also are not able to robustly consume long inputs. To address these limitations, we propose **ReadAgent**, an LLM agent system that increases effective context length up to 20× in experiments. Inspired by how humans interactively read long documents, ReadAgent is implemented as a simple prompting system that uses the advanced language capabilities of LLMs to:

1. **Episode Pagination** — decide what content to store together in a memory episode
2. **Memory Gisting** — compress those memory episodes into short episodic memories called *gist memories*
3. **Interactive Look-up** — take actions to look up passages in the original text when relevant details are needed to complete a task

Evaluated on three long-document reading comprehension tasks: **QuALITY**, **NarrativeQA**, and **QMSum**. ReadAgent outperforms baselines on all three tasks while extending the effective context window by 3.5–20×.

## Key Ideas

### Human-Inspired Reading

The approach is motivated by **fuzzy-trace theory** (Reyna & Brainerd, 1995): humans form two types of memory representations — *verbatim* (exact details) and *gist* (fuzzy substance). People prefer to reason with gists rather than verbatim memories, and look up original text when details are needed.

### Three-Step Pipeline

#### 1. Episode Pagination
The LLM reads through long text and decides where to pause (at natural break points between paragraphs). Content between pause points becomes an "episode" or "page." Controlled by `min_words` and `max_words` parameters.

#### 2. Memory Gisting
Each page is compressed into a short gist via prompting (using the word "shorten" rather than "summarize" to preserve narrative flow). Gists are tagged with page numbers for context. The ordered collection of gists forms the **gist memory**.

#### 3. Interactive Look-Up and Response
Given a task, the LLM examines the gist memory and decides which original page(s) to retrieve:
- **ReadAgent-P (Parallel):** requests multiple pages in one prompt
- **ReadAgent-S (Sequential):** requests one page at a time, seeing previously expanded pages before deciding the next

Retrieved raw pages replace corresponding gists in memory, preserving narrative flow.

### Computational Efficiency
- Pagination cost bounded by `max_words / min_words` factor
- Gisting is one additional pass over raw input
- Look-ups operate mostly on compressed gists
- Gists are a **one-time cost** — amortized across multiple tasks on the same document
- On QuALITY: 20.4% token savings with up-to-2-page lookup vs. full text

## Results

### QuALITY (multiple choice QA)
- ReadAgent-P (1-6 pages): **86.91%** accuracy (vs. 85.83% full text baseline)
- ReadAgent-S (1-6 pages): **87.17%** accuracy
- Compression rate ~72% → 3.5× effective context extension
- **Outperforms using full original text** (because LLMs struggle with long, distracting context)

### NarrativeQA (Gutenberg test set, avg 71k words, max 343k words)
- ReadAgent improves LLM rating by **12.97%** and ROUGE-L by **31.98%** over best retrieval baseline
- Effective context length extended ~20×
- ReadAgent-S particularly strong on movie scripts

### QMSum (meeting summarization)
- ReadAgent outperforms both truncated text and retrieval baselines
- Effective context extended ~5× with compression rate ~80%

## Design Insights

| Aspect | Detail |
|---|---|
| **Why "shorten" not "summarize"** | "Shorten" preserves narrative flow for concatenation; "summarize" tends to restructure |
| **Page size trade-off** | Larger pages → more compression (remove redundancy) but lose more details |
| **Parallel vs. Sequential** | Sequential gives more information per step but costs more; use only when it provides clear benefits |
| **vs. Full context** | ReadAgent can outperform full-context because it reduces distracting information (Liu et al., 2023) |
| **vs. RAG** | ReadAgent uses LLM reasoning over contextualized gists for retrieval, rather than embedding similarity; better for densely-correlated documents |
| **vs. MemWalker** | Hierarchical summaries make it difficult to reason over related but distant information at the same granularity |

## Relevance to Context Engineering

This paper is directly relevant to **context engineering strategies**:

- Demonstrates that **compressing context intelligently** (gist memory) can actually *improve* performance over using raw full context
- Shows that LLMs benefit from **curated, relevant context** rather than dumping everything into the window
- The pagination → gisting → selective retrieval pipeline is a practical pattern for agent systems handling long documents
- The "gist + look-up" pattern mirrors how well-designed agent systems should manage context: maintain a compressed overview, expand details on demand
- Validates that **reducing distracting information** in context is as important as having all information available
