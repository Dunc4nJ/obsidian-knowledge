---
created: 2026-03-29
description: LightOnOCR-2, a 1B parameter open-source model, scores first among all dedicated OCR models on an independent table extraction benchmark, beating GPT-5 mini, Claude Sonnet 4.6, and Mathpix.
source: https://x.com/igorcarron/status/2037682114833842629
type: learning
---

# LightOnOCR-2 outscores proprietary models at table extraction with 1B parameters

## Key Takeaways

Table extraction is the critical first step in any document-processing pipeline — financial statements, clinical trial results, compliance matrices. Get the table wrong and every downstream component hallucinates numbers. This matters directly for [[agentic search with grep and full-file loading replaces RAG when context windows are large enough|RAG pipelines]] and data agents that need structured data from unstructured documents. The benchmark from Offenburg University and University of Mannheim tested 21 parsers on 451 tables using LLM-as-a-judge scoring validated against 1,500+ human ratings, giving it real methodological weight.

LightOnOCR-2 scored 9.08/10, ahead of Mathpix (8.53), Qwen3-VL-235B (8.43), GPT-5 mini (7.14), and Claude Sonnet 4.6 (7.02). The model is 1B parameters, Apache 2.0 licensed, and runs on a single GPU — making it deployable on-premise behind a firewall. This is the same pattern seen in [[context tax compounds through cache misses bloated tools and unbudgeted output tokens|context-efficient tooling]]: a small, specialized model outperforming general-purpose giants at a fraction of the cost.

For document intelligence workflows like those built with [[ExtractThinker|ExtractThinker]], having a dedicated high-accuracy table extraction step before LLM processing could dramatically improve output quality. The study (arxiv.org/abs/2603.18652) provides a reusable evaluation methodology — LLM-as-a-judge validated against human ratings — that's applicable beyond table extraction to any structured extraction task.

## External Resources

- [LightOnOCR-2 on HuggingFace](https://huggingface.co/lightonai/LightOnOCR-2-1B) — the 1B parameter model, Apache 2.0
- [LightOn](https://lighton.ai/) — company behind the model, offers managed deployment
- [Benchmarking PDF Parsers on Table Extraction (arXiv:2603.18652)](https://arxiv.org/abs/2603.18652) — the independent benchmark paper from Offenburg University and University of Mannheim
- [LightOn Pricing](https://lighton.ai/pricing) — managed deployment pricing

## Original Content

> @IgorCarron — 2026-03-28
>
> Article: Open source LightOnOCR-2 just outscored OpenAI, Anthropic, Alibaba, and Mathpix at table extraction
>
> Why does table extraction matter? Because the most valuable information in enterprise documents lives in tables. Financial statements. Clinical trial results. Defence procurement specs. Engineering reports. Compliance matrices. Pricing schedules.
>
> It is also the first step of Search and Reason with Enteprise Documents.
>
> Get the table wrong and your RAG pipeline hallucinates numbers. Your agent makes decisions on corrupted data. Your analyst misses the cell that changes the deal.
>
> An independent benchmark from Offenburg University and University of Mannheim just tested 21 parsers on 451 tables with LLM-as-a-judge scoring validated against 1,500+ human ratings.
>
> *LightOnOCR-2 benchmark results*
> ![[igorcarron-842629-001.jpg]]
>
> [LightOn](https://lighton.ai/)'s [LightOnOCR-2](https://huggingface.co/lightonai/LightOnOCR-2-1B) scored 9.08/10 or #1 among all dedicated OCR models. Ahead of Mathpix (8.53), Qwen3-VL-235B (8.43), GPT-5 mini (7.14), and Claude Sonnet 4.6 (7.02).
>
> *Detailed parser comparison table*
> ![[igorcarron-842629-002.png]]
>
> 1B parameters. Apache 2.0. Single GPU. The model that beat the biggest names in AI is the one you can deploy on-premise, behind your firewall.
>
> *Model architecture and deployment overview*
> ![[igorcarron-842629-003.png]]
>
> The study: Benchmarking PDF Parsers on Table Extraction with LLM-based Semantic Evaluation, Pius Horn and Janis Keuper Institute for Machine Learning and Analytics (IMLA), Offenburg University, Offenburg, Germany & University of Mannheim, Mannheim, Germany arxiv.org/abs/2603.18652
>
> Go and get it: huggingface.co/lightonai/LightOnOCR-2-1B
>
> Deploy it at scale with @LightOnIO : lighton.ai/pricing
>
> Engagement: 55 likes | 8 retweets | 1 replies
> [Original post](https://x.com/IgorCarron/status/2037682114833842629)
