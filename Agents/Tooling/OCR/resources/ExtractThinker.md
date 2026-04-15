---
created: 2026-03-21
source: https://github.com/enoch3712/ExtractThinker
type: resource
tags: [document-intelligence, extraction, llm, pydantic, ocr]
status: unread
---

## What it is

ExtractThinker is a Python library for document intelligence that uses LLMs to extract and classify structured data from documents. It works like an ORM for documents — you define Pydantic contracts (schemas) and the library handles loading, parsing, classifying, and extracting data from PDFs, images, spreadsheets, and other formats.

## Why it's interesting

It abstracts away the messy plumbing of document processing (OCR, layout parsing, chunking) behind a clean ORM-style API. Supports a wide range of document loaders (Tesseract, Azure Form Recognizer, AWS Textract, Google Document AI) and LLM providers (OpenAI, Anthropic, Cohere), so you can swap components without rewriting extraction logic. The classification and splitting strategies are particularly useful for processing mixed-document batches (e.g., a PDF containing both invoices and driver's licenses).

## How it works

**Document Loading** — Pluggable loaders handle the raw document parsing. Each loader (PyPdf, Tesseract OCR, Azure Form Recognizer, etc.) converts a document into a normalized internal representation.

**Contract Definition** — Users define Pydantic models (called Contracts) that describe the fields they want extracted. For example, an `InvoiceContract` with `invoice_number` and `invoice_date` fields.

**Extraction** — The `Extractor` sends the document content plus the contract schema to an LLM, which returns structured data matching the contract. The LLM acts as the intelligent parsing layer.

**Classification** — Documents can be classified against a set of named classifications (each with a description and associated contract). The LLM determines which classification best matches, returning a name and confidence score.

**Splitting** — For multi-document files (e.g., a PDF with an invoice on page 1 and a license on page 2), splitters (like `ImageSplitter`) break the document into sections. A `Process` object orchestrates splitting → classification → extraction per section, using lazy or eager strategies.

## Key links

- [GitHub](https://github.com/enoch3712/ExtractThinker)
- [PyPI](https://pypi.org/project/extract-thinker/)
- [Author's Medium](https://medium.com/@enoch3712)

## Notes

- Apache 2.0 licensed
- Python 3.9+
- Could be useful for building document processing pipelines in agent workflows
