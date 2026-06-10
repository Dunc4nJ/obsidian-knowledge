---
created: 2026-06-10
description: LlamaParse now emits word, line, and cell-level bounding box coordinates for every parsed value, giving compliance and audit workflows a verifiable trail from each extracted figure back to its exact pixel location in the source document.
source: https://x.com/jerryjliu0/status/2064479193988206933
type: learning
---

# LlamaParse ships word-level bounding boxes so agents can cite exact words and figures not entire document regions

## Key Takeaways

The motivating claim is auditability scaling. As frontier models (Jerry Liu cites Fable 5) extend the task horizon of automated knowledge work, the bottleneck shifts from "can the agent produce an answer" to "can a human trace any specific number back to a specific pixel." Most parsers can ground a value to a paragraph or a table block — that's where the trail ends, which is the kind of artifact that breaks down under compliance or financial-filing review. This is the same auditability gap surfaced in [[OpenAI internal data agent succeeds through six layers of context not model capability alone|OpenAI's internal data agent]] and what [[LangChain's Harrison Chase argues agent observability needs feedback attached to traces to power learning|Harrison Chase frames as feedback-on-traces]] — citation density is a first-class observability surface, not a UI nicety.

Granular Bounding Boxes upgrades LlamaParse output from page-level or block-level coordinates to word, line, and table-cell coordinates for every extracted value. A downstream agent or human reviewer can now click any single word or number in an extraction and jump to the exact bounding rectangle on the rendered page — useful precisely for the [[Anthropic's self-service analytics stack achieves 95% accuracy by treating the bottleneck as context and entity mapping not SQL generation|"context-and-entity-mapping is the bottleneck"]] pattern where the auditor's job is to confirm that the model picked the right cell out of a busy financial statement. This sits one level up from raw OCR accuracy: [[LightOnOCR-2 outscores proprietary models at table extraction with 1B parameters|table extractors like LightOnOCR-2]] decide *what* the cell contains, while bounding-box emission decides *where* the model said it came from, and the two compose into the parser → extractor → citation pipeline that [[ExtractThinker|ExtractThinker-style]] document intelligence stacks need underneath them.

The deeper engineering lesson is that citation format is a wire-format contract, not a presentation detail. [[Model-Harness-Fit means tool surfaces and citation tags are post-trained into the model, not interchangeable|Nicolas Bustamante's Model-Harness-Fit argument]] generalises here — once an agent is post-trained against a parser that emits word-level `bbox` coordinates, downgrading to a parser that only emits page-level regions silently breaks the model's citation discipline even though both outputs look like JSON. LlamaParse leaning into granularity at the parser layer is a bet that the next generation of audit-grade document agents will be built against this contract; brochures, marketing collateral, and other [[HuggingFace OCRed 30K arXiv papers with Chandra-OCR 2 on parallel L40S GPU jobs for 850 dollars|visually-heavy corpora]] are the natural next surface to test whether word/line/cell coordinates generalise beyond financial filings and academic papers.

## External Resources

- [Announcing Granular Bounding Boxes in LlamaParse](https://www.llamaindex.ai/blog/announcing-granular-bounding-boxes-in-llamaparse) — the official LlamaIndex blog announcement (the `t.co/Me1QFEka8n` in the original post).
- [LlamaIndex Cloud](https://cloud.llamaindex.ai/) — hosted LlamaParse with the new bounding-box output (the `t.co/TqP6OT5U5O` in Jerry's tweet).
- [@llama_index post on X](https://x.com/llama_index/status/2064355983292240066) — the LlamaIndex org post Jerry quote-tweeted, with the longer framing for compliance and audit reviewers.

## Original Content

> @jerryjliu0 (Jerry Liu) — 2026-06-09
>
> As frontier models (e.g. Fable 5) continue to push the task horizon of knowledge work automation, it becomes ever more important for humans to be able to audit decisions back to the source context.
>
> It is extremely easy for agents to cite an entire document or document page, but much harder for them to trace back to the exact numbers/words/figures within a page.
>
> Today we've launched granular bounding boxes within LlamaParse, which allows you to obtain visual citations of every single word in the document. This allows human users to audit exact words and figures - not just general document regions or entire pages!
>
> Come check it out: [cloud.llamaindex.ai](https://cloud.llamaindex.ai/?utm_source=xjl&utm_medium=social)
>
> *LlamaParse granular bounding boxes — product demo video thumbnail*
> ![[jerryjliu0-206933-1.jpg]]
>
> *Quote-tweeting [@llama_index](https://x.com/llama_index/status/2064355983292240066):*
>
> > Parsing a document accurately is one thing. Proving where every value came from is another.
> >
> > When a compliance team reviews an AI extraction, or an auditor needs to sign off on a figure pulled from a financial filing, "it came from this document" isn't enough. They need to see exactly where. The specific cell in the table, the exact line on the page, the precise word the agent used.
> >
> > Most parsers can get you to a paragraph or a table block. That's where the trail ends.
> >
> > Today we're shipping Granular Bounding Boxes in LlamaParse — word, line, and cell level coordinates for every value in your document.
> >
> > The result is a complete, verifiable trail from every extracted value back to its exact source in the document. Built for audit workflows, compliance review, and any pipeline where verification isn't optional.
> >
> > Read the full announcement → [llamaindex.ai/blog/announcing-granular-bounding-boxes-in-llamaparse](https://www.llamaindex.ai/blog/announcing-granular-bounding-boxes-in-llamaparse?utm_medium=socials&utm_source=twitter&utm_campaign=2026--)
> >
> > *Granular bounding boxes — LlamaIndex announcement video thumbnail*
> > ![[jerryjliu0-206933-2.jpg]]
>
> [Original post](https://x.com/jerryjliu0/status/2064479193988206933)
