---
created: 2026-06-18
description: Joe Barrow (ex-head of ML at Pattern Data) reviews Philip Kiely's "Inference Engineering" as the single breadth-first reference for the LLM inference stack — engine selection, quantization, speculative decoding, disaggregation, scaling-as-a-service — and appends his own curated reading map for training, GPUs, and per-technique deep dives.
source: https://x.com/barrowjoseph/status/2067239202060747215
type: learning
---

## Key Takeaways

- **"Inference Engineering" is positioned as a single breadth-first reference for the whole inference stack, not a tutorial.** Barrow — a research scientist who was also head of ML at Pattern Data, where he scaled document processing past a billion pages — frames the book as the reference work he wishes he could ship back to himself in 2023 to avoid hard-earned mistakes. Its range runs from engine selection ("vLLM or SGLang or TensorRT?") to scaling inference economically as a service grows. The recommended reading mode reflects its structure: read once cover-to-cover, then revisit the most relevant chapters, which are largely independent. This sits alongside [[paged attention applies OS virtual memory paging to KV cache and unlocks 2-4x LLM serving throughput]] and [[LLM optimization interview prep maps Flash Attention, ZeRO, speculative decoding, and MoE across training and inference]] as canonical inference-serving references.

- **The "Techniques" chapter is the standout, and reportedly has the best high-level write-up of EAGLE speculative decoding Barrow has read.** It covers quantization, speculative decoding, and disaggregation — the day-to-day levers for anyone serving models. That maps directly to the speculative-decoding and quantization material in [[LLM optimization interview prep maps Flash Attention, ZeRO, speculative decoding, and MoE across training and inference]] and the broader survey in [[twenty-six papers capture ninety percent of the alpha behind modern LLMs from attention through reasoning and mixture of experts]].

- **Audience calibration is the central critique.** The book pauses early to explain linear layers and activation functions, yet Barrow would only recommend it to readers already fluent in those basics — so the introductory material is a mismatch for the actual target reader. His other nits are that he wishes it were longer (FlashAttention, estimating model FLOPS, and HFU would have been worth a deeper treatment) and that there's no hardcover.

- **The durable layer is the mental model, not the specific model capabilities — illustrated by a passage that aged in real time.** Asked whether the knowledge would be obsolete in six months, Barrow says no: principles, concepts, and foundational technologies persist even as details churn. The ironic counterexample is the book's own section 6.4.1, which claims TTS speech degrades after ~30 seconds of audio — already overtaken by a Philip Kiely tweet showing how fast TTS models improved. The takeaway is to internalize the framework and treat any single capability claim as a moving target.

- **The most reusable artifact is the curated "what to read next" map, organized by goal.** For training: HuggingFace's *Ultra-Scale Training Playbook* (Tensor/Sequence/Pipeline/Context/Data parallelism, the ZeRO optimizer series, scaling trade-offs). For a higher-level view: Chip Huyen's *AI Engineering*. For GPUs: the Modal GPU Glossary plus *CUDA Programming: A Developer's Guide*. Per technique — inference engines: the nano-vllm and Mini-SGLang pedagogical codebases; speculative decoding: the vLLM docs; quantization: ngrok's *Quantization From the Ground Up* and the 35-year-old Goldberg IEEE-754 floating-point paper. The training and GPU recommendations complement the inference focus of [[twenty-six papers capture ninety percent of the alpha behind modern LLMs from attention through reasoning and mixture of experts]] and [[technmak's AI-ML Engineer Interview Guide for 2026 Part 1 spans classical ML, multimodal systems, and preference optimization across six domains]].

## External Resources

- [Inference Engineering — free online edition (BaseTen)](https://www.baseten.co/inference-engineering/) — Philip Kiely's book, readable for free
- [Inference Engineering — physical copy (BaseTen store)](https://books.baseten.com/products/inference-engineering) — the paperback Barrow calls "completely worth it"
- [Formatted review on jbarrow.ai](https://jbarrow.ai/2026-06-17-book-review-inference-engineering/) — the same review on the author's site
- [Philip Kiely tweet on TTS progress](https://x.com/philipkiely/status/2061852493429248260) — the example of how fast model capabilities outpace a book's knowledge cutoff
- [HuggingFace Ultra-Scale Training Playbook](https://huggingface.co/spaces/nanotron/ultrascale-playbook) — Barrow's top pick for learning to scale training (parallelism + ZeRO)
- [Modal GPU Glossary](https://modal.com/gpu-glossary) — broad GPU reference
- [nano-vllm](https://github.com/GeeeekExplorer/nano-vllm) — pedagogical inference-engine codebase
- [Mini-SGLang](https://github.com/sgl-project/mini-sglang) — minimal SGLang implementation for learning
- [vLLM speculative decoding docs](https://docs.vllm.ai/en/latest/features/speculative_decoding/#notes) — recommended for the speculative-decoding deep dive
- [ngrok — Quantization From the Ground Up](https://ngrok.com/blog/quantization) — recommended quantization explainer
- [What Every Computer Scientist Should Know About Floating-Point Arithmetic (Goldberg, 1991)](https://www.itu.dk/~sestoft/bachelor/IEEE754_article.pdf) — the classic Xerox PARC floating-point paper

## Original Content

> [!quote]- Source Material — @barrowjoseph (Joe Barrow), X Article "Book Review: Inference Engineering", Jun 17 2026 · 14 likes
>
> ## Article: Book Review: Inference Engineering
>
> *The physical copy of "Inference Engineering" by Philip Kiely*
> ![[barrowjoseph-747215-001.png]]
>
> I recently bought a copy of "Inference Engineering" by @philipkiely. The book is [available for free from BaseTen](https://www.baseten.co/inference-engineering/), but the physical copy is beautiful and, in my opinion, [completely worth it](https://books.baseten.com/products/inference-engineering?_gl=1*19lq56g*_gcl_au*MTI3Mjc0NjQ0Ny4xNzgxNjk5NDU2). If there were a hardback I'd buy it tomorrow.
>
> N.B. as always you can read the formatted version [here](https://jbarrow.ai/2026-06-17-book-review-inference-engineering/).
>
> The top line of my review is: I desperately wish I could ship this book back to myself in 2023.
>
> My background: I'm a research scientist, but I was also the head of ML at Pattern Data, where we scaled document processing a billion+ pages. There is a lot of material in the book that I was already familiar with from hard-earned lessons or mistakes. Having a single reference work to handle all of that would have helped me avoid those mistakes. And probably make a fun set of new ones!
>
> If your job touches ML inference at all, you should probably read this book. Save yourself from the mistakes that I made! It's got immense technical breadth, covering everything from "when should I choose vLLM or SGLang or TensorRT?" to "how do I efficiently scale inference as a service grows?"
>
> My recommendation for how to read the book is to read it through once to familiarize yourself with all of the content, and then revisit the specific most interesting chapters. The book is largely organized as a reference work, with chapters being largely independent. If there are sections that don't apply to you, you can probably skip them.
>
> Use the chapters you revisit as a jumping off point to the broader literature (there's a really nice set of "papers to read next" organized by topic in the back of the book).
>
> I personally really enjoyed the "Techniques" chapter, where he covers quantization, speculative decoding, disaggregation, etc. because those are things I think about in the day-to-day. It contains the best high-level description of EAGLE speculative decoding that I've read.
>
> I only have three very minor nits:
>
> 1. At times I was unsure what the level of the intended audience was. For example, early on he takes care to explain linear layers and activation functions. I'd probably only recommend the book to an audience already fluent in those concepts.
>
> 2. I really wish the book were longer. Philip is really good at distilling and explaining concepts! A few concepts would have been nice to cover in depth, like FlashAttention or estimating model FLOPS and HFU.
>
> 3. I wish there were a hardcover.
>
> ## Will this knowledge be obsolete in 6 months?
>
> I got asked this when discussing the book with a friend, so it may be worth addressing. Short answer: Nope!
>
> Long answer: I'll let Philip speak for himself on this:
>
> > Like LLMs, books have knowledge cutoffs. [...] While details will change, the principles, concepts, and foundational technologies in this book provide a strong background on inference engineering that will serve you well for years to come.
>
> However, in a fun sign of just how fast the world of AI changes, consider this passage for 6.4.1:
>
> > TTS models are rarely used outside of real-time applications. However, if you do end up with a batch use case like backfilling a large corpus of documents to audio for improved accessibility, note that tts models don't do well with long inputs, speech starts to degrade after 30 seconds or so.
>
> Now, consider this tweet:
>
> [https://x.com/philipkiely/status/2061852493429248260](https://x.com/philipkiely/status/2061852493429248260)
>
> Models get much better quite quickly!
>
> ## What Should I Read Next?
>
> I think this book is a very valuable jumping off point, and what you should read next depends on your interests and needs. For starters, there's a really nice set of "papers to read next" organized by topic in the back of the book. I've got a few to add to that, depending on what you want to focus on.
>
> ### I'm interested in training LLMs
>
> This one I have a great answer for!
>
> In my opinion the single best book you could read next is HuggingFace's "Ultra Scale Training Playbook." It's packed with code examples, visuals, and tons of great explanations about how you scale the training of models. It'll help you get deeply familiar with concepts like Tensor/Sequence/Pipeline/Context/Data Parallelism, the ZeRO series of optimizers, and the difficulties and trade-offs you have to make as models scale.
>
> ### This book was too in the inference weeds for me
>
> Chip Huyen's "AI Engineering" seems like a good fit, in that case?
>
> ### I want to dig deeper into GPUs
>
> Here we're going a little further outside of my comfort zone. The [Modal GPU Glossary](https://modal.com/gpu-glossary) contains an incredible amount of breadth, but is probably best used as a reference rather than a standalone book. I'm going to be working through some GPU programming books in the near future where I can provide a more thorough review. The one I saw most highly recommended was: "CUDA Programming: A Developer's Guide to Parallel Computing with GPUs"
>
> ### I want to learn more about TECHNIQUE
>
> If TECHNIQUE="inference engines", then the [nano-vllm codebase](https://github.com/GeeeekExplorer/nano-vllm) is a really neat place to start. I don't know of any good books on the topic (outside of this one), but there are lots of good vLLM/PagedAttention explainers and pedagogical codebases like nano-vllm or [Mini-SGLang](https://github.com/sgl-project/mini-sglang).
>
> If TECHNIQUE="speculative decoding", then [the vLLM speculative decoding docs](https://docs.vllm.ai/en/latest/features/speculative_decoding/#notes) are very good!
>
> If TECHNIQUE="quantization", then ngrok's [Quantization From the Ground Up](https://ngrok.com/blog/quantization) is a good resource. I also enjoyed [What Every Computer Scientist Should Know About Floating Point Arithmetic](https://www.itu.dk/~sestoft/bachelor/IEEE754_article.pdf), a 35-year-old paper from Xerox PARC.
>
> ### None of the above apply to me!
>
> Feel free to @ me or DM me and ask for recommendations!

---

Source: [Joe Barrow (@barrowjoseph) — "Book Review: Inference Engineering"](https://x.com/barrowjoseph/status/2067239202060747215) · X Article, Jun 17 2026
