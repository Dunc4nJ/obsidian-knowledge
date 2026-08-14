---
created: 2026-08-14
description: Hamel Husain's summary of Joe Barrow's session — choosing an OCR model via a 2x2 (plain text vs full structure × hosted vs self-hosted): big-cloud APIs at $0.60-1.50/1k pages with word boxes, document startups (Reducto/Datalab/Extend) at $5-20/1k feature-complete, open pipelines (Tesseract/PaddleOCR) cheap but narrow, open VLMs (LightOnOCR/Chandra/Docling) GPU-bound but near-complete — and only ~5% of teams should self-host. Plus seven PDF failure modes (TeX PDFs with no space characters, column-jumbled reading order, Textract hallucinating "the" 100x on noisy scans, VLM boilerplate on blank pages, license chains) and the 50-100-representative-pages selection process.
source: https://hamel.dev/notes/llm/ai-product-engineering/context-ocr.html
author: Hamel Husain (summarizing Joe Barrow's session)
type: article
tags: [ocr, document-processing, pdf, vlm, model-selection, inference, cost, ai-product-engineering, hamel]
---

## Key Takeaways

- **The 2x2 and the price ladder.** Axes: plain text blocks vs full document structure × hosted vs self-hosted. Big cloud (AWS Textract, Google Cloud Vision): **$0.60-1.50 per 1,000 pages**, word-level bounding boxes. Document startups (Reducto, Datalab, Extend): **$5-20/1k pages**, feature-complete. Open pipelines (Tesseract, PaddleOCR): cheap, fast, narrow. Open VLMs (LightOnOCR, Chandra, Docling — the extractor this vault's own pipeline runs): GPU-bound, roughly feature-complete. The punchline: **only ~5% of teams should self-host** — if you're product-focused, use an API; the economics of when self-hosting does pay are what [[HuggingFace OCRed 30K arXiv papers with Chandra-OCR 2 on parallel L40S GPU jobs for 850 dollars|HuggingFace's $850-for-30K-papers run]] quantifies.

- **Seven PDF failure modes worth memorizing — because PDFs break extractors in ways benchmark scores never show.** (1) TeX-compiled PDFs place glyphs at coordinates and contain *no space characters* — naive extraction returns one unbroken letter-run; (2) two-column pages carry no reading order — line-level extractors (Textract included) read across columns and hand the LLM jumbled text; (3) line-level output drops headers/tables/cell boundaries, starving downstream retrieval; (4) noisy scans make cloud APIs *invent* text — Textract observed returning "the" a hundred times; (5) blank pages make VLMs hallucinate boilerplate headers; (6) VLM markdown has no word-level bounding boxes — no source-phrase highlighting in the original PDF; (7) **license chains**: Chandra/Surya free only under $2M revenue and non-competition with Datalab; GLM-OCR is MIT but pulls Apache-licensed Paddle layout models — you inherit both.

- **The process is deliberately unsophisticated: run the bake-off on your own pages.** Pick your two axes, pull 50-100 *representative* pages, run every candidate on the same pages, inspect raw outputs, compare failure modes, then commit — the read-your-data discipline of [[benchmarks are measurement instruments not question collections - regulargio's first-principles guide to claims, graders, coverage, and uncertainty|benchmarking science]] applied to document ingestion. (WTF PDF is the gallery of files that break most extractors.)

## External Resources

- Original note: [How to Choose an OCR Model — Hamel Husain](https://hamel.dev/notes/llm/ai-product-engineering/context-ocr.html) ([AI Product Engineering series](https://hamel.dev/notes/llm/ai-product-engineering/))
- [Joe Barrow's talk](https://youtu.be/mSdmMdpfHpI) · [his open-OCR research ("OCR Cambrian")](https://jbarrow.ai/2026-05-09-ocr-cambrian/) · [WTF PDF gallery](https://wtfpdf.com)
- Tools: [Reducto](https://reducto.ai) · [Datalab](https://www.datalab.to) · [Extend](https://www.extend.ai) · [Tesseract](https://github.com/tesseract-ocr/tesseract) · [PaddleOCR](https://github.com/PaddlePaddle/PaddleOCR) · [LightOnOCR-1B](https://huggingface.co/lightonai/LightOnOCR-1B-1025) · [Chandra](https://huggingface.co/datalab-to/chandra) / [Surya](https://github.com/datalab-to/surya) · [Docling](https://github.com/docling-project/docling) · [GLM-4.5V](https://huggingface.co/zai-org/GLM-4.5V)

## Original Content

> [!quote]- Full note — "How to Choose an OCR Model" (Hamel Husain; session by Joe Barrow)
> _This note covers Joe Barrow’s session in the [AI Product Engineering series](../../../notes/llm/ai-product-engineering/index.html)._
>
> Joe Barrow walks through how to pick an OCR model. He presented a decision matrix with two axes: whether you need plain text blocks or full document structure, and whether you want a hosted API or a self-hosted model:
>
> ![[hamel-ocr-001.jpg]]
>
> Joe’s decision matrix. Cost and completeness across the four options.
>
> Big cloud providers like AWS Textract and Google Cloud Vision are cheap with word-level bounding boxes, at $0.60 to $1.50 per 1,000 pages. Document startups like [Reducto](https://reducto.ai), [Datalab](https://www.datalab.to), and [Extend](https://www.extend.ai) are expensive but feature complete, at $5 to $20 per 1,000 pages. Open pipelines like [Tesseract](https://github.com/tesseract-ocr/tesseract) and [PaddleOCR](https://github.com/PaddlePaddle/PaddleOCR) are cheap and fast, with narrower capabilities. Open VLMs like [LightOnOCR](https://huggingface.co/lightonai/LightOnOCR-1B-1025), [Chandra](https://huggingface.co/datalab-to/chandra), and [Docling](https://github.com/docling-project/docling) need a GPU to run and are roughly feature complete.
>
> Joe advises that only about 5% of teams should self-host. If you are product focused its often better to use an API.
>
> Even when you use an API, the model you pick still matters, because PDFs break extractors in unexpected ways. A few Joe called out:
>
> * TeX-compiled PDFs contain no space characters. TeX places glyphs at coordinates, so a naive extractor returns one long run of letters with zero spaces.
> * Two-column pages carry no reading order. A line-level extractor reads across columns and hands your LLM jumbled text. Cloud providers like Textract fall into this too.
> * Line-level output drops semantic structure. Headers, tables, and cell boundaries vanish, so downstream retrieval loses the context.
> * Bad scans make cloud APIs invent text. Textract has been observed to return the word “the” a hundred times on a noisy scan.
> * Blank pages make VLMs hallucinate boilerplate. An empty page can come back with header text.
> * VLM markdown output has no word-level bounding boxes. If your product needs to highlight the source phrase inside the original PDF, VLM output alone might not do it.
> * Model licenses have hidden chains. [Chandra and Surya](https://github.com/datalab-to/surya) are only free for organizations under $2M annual revenue that do not compete with Datalab. [GLM-OCR](https://huggingface.co/zai-org/GLM-4.5V) is MIT licensed but pulls in Apache-licensed Paddle layout models, so you inherit both.
>
> If you want to see how bad PDFs get, [WTF PDF](https://wtfpdf.com) is a gallery of files that break most extractors.
>
> Joe’s process is short. Pick your two axes, pull 50 to 100 representative pages, run every candidate on the same pages, then inspect the raw outputs and compare failure modes before you commit.
>
> Watch Joe’s session [here](https://youtu.be/mSdmMdpfHpI). His [research on open OCR models](https://jbarrow.ai/2026-05-09-ocr-cambrian/) is also worth reading.
