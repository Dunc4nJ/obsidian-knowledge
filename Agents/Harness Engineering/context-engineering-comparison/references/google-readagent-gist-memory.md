---
created: 2026-03-02
description: Google DeepMind's ReadAgent compresses long documents into episodic gist memories that increase effective context length by 3-20x, inspired by how humans interactively read and selectively revisit details.
source: https://arxiv.org/abs/2402.09727
type: paper
authors:
  - Kuang-Huei Lee
  - Xinyun Chen
  - Hiroki Furuta
  - John Canny
  - Ian Fischer
arxiv: "2402.09727"
---

## Abstract

Current Large Language Models (LLMs) are not only limited to some maximum context length, but also are not able to robustly consume long inputs. To address these limitations, we propose ReadAgent, an LLM agent system that increases effective context length up to 20x. Inspired by how humans interactively read long documents, ReadAgent uses LLMs to (1) decide what content to store together in a memory episode, (2) compress those memory episodes into short episodic memories called gist memories, and (3) take actions to look up passages in the original text if relevant details are needed. ReadAgent outperforms baselines on QuALITY, NarrativeQA, and QMSum while extending the effective context window by 3-20x.

## Key Takeaways

ReadAgent implements a human-inspired reading pattern: skim first, then dive deep where needed. The agent creates compressed "gist memories" of document sections, then looks up the original text only when it needs specific details. This is conceptually similar to [[manus-context-engineering|Manus's file-system-as-extended-memory]] pattern — both compress information and keep the originals accessible for on-demand retrieval.

The 3-20x effective context extension makes this directly relevant to the context engineering debate between Google's "just use long context" approach and everyone else's compression strategies. ReadAgent shows that even Google's own researchers recognize compression has value — the question is where in the pipeline to apply it. The gist memory approach occupies a middle ground: you don't throw away information (like trimming), but you also don't carry everything (like raw long context).

The model decides what content to group into episodes and how to compress them, making this an LLM-driven context management strategy rather than a heuristic one. This connects to [[anthropic-effective-context-engineering|Anthropic's attention budget]] framing — the model allocates its own attention by choosing what to compress and what to preserve.

## External Resources

- [Paper on arXiv](https://arxiv.org/abs/2402.09727) — Full research paper
- [Google DeepMind publication page](https://deepmind.google/research/publications/74917/) — Overview and download

## Original Content

> [!quote]- Source Material
> **A Human-Inspired Reading Agent with Gist Memory of Very Long Contexts**
> Published February 15, 2024
>
> Current Large Language Models (LLMs) are not only limited to some maximum context length, but also are not able to robustly consume long inputs. To address these limitations, we propose ReadAgent, an LLM agent system that increases effective context length up to 20x in our experiments. Inspired by how humans interactively read long documents, we implement ReadAgent as a simple prompting system that uses the advanced language capabilities of LLMs to (1) decide what content to store together in a memory episode, (2) compress those memory episodes into short episodic memories called gist memories, and (3) take actions to look up passages in the original text if ReadAgent needs to remind itself of relevant details to complete a task. We evaluate ReadAgent against baselines using retrieval methods, using the original long contexts, and using the gist memories. These evaluations are performed on three long-document reading comprehension tasks: QuALITY, NarrativeQA, and QMSum. ReadAgent outperforms the baselines on all three tasks while extending the effective context window by 3-20x.
>
> Authors: Kuang-Huei Lee, Xinyun Chen, Hiroki Furuta, John Canny, Ian Fischer
>
> [Original paper](https://arxiv.org/abs/2402.09727)
