---
created: 2026-05-15
description: Maxime Rivest reframes DSPy's five components — Optimizers, Signatures, LMs, Modules, Adapters — as the universal vocabulary of AI engineering (Evals, Interface, Inference, Call Graph, Rendering), arguing that rendering/adapters is the under-noticed axis where the big providers' recent advances (reasoning, structured outputs, tool calls) actually live.
source: https://x.com/MaximeRivest/status/2055293570119065875
type: framework
---

# DSPy frames AI engineering as five components and adapters are the most underappreciated lever

*DSPy banner from the article*
![[maximerivest-065875-001.jpg]]

## Key Takeaways

- **Five components exhaust the AI engineering surface area.** Rivest maps DSPy's Optimizers, Signatures, LMs, Modules, Adapters onto the general concerns every AI engineer faces: Evals, Interface, Inference, Call Graph, and Rendering. The framing is normative — *every* working AI program makes a decision on each axis, even if it's a default delegated to the provider. Other frameworks ship several of these; per Rivest, none other than DSPy ships all five. Pairs naturally with [[agent harness components can be derived from first principles by working backwards from desired agent behavior]].

- **Rendering is the under-noticed axis that drives provider-side advancement.** Structured output, reasoning, and tool calls — the three headline capabilities from the big labs over the past two years — are all rendering choices: how the model is asked to format its output and how that output is parsed back. XML tags vs JSON vs custom delimiters vs `<toolcall>...</toolcall>` vs `#!run` Markdown cells aren't task decisions, they're inference-strategy choices that should be swappable. Treating rendering as a first-class layer (DSPy's adapters) is what makes the difference between "delegating to OpenAI's defaults" and engineering a cost/accuracy profile. Complements [[Model-Harness-Fit means tool surfaces and citation tags are post-trained into the model, not interchangeable]] — Bustamante argues tool/citation rendering is post-trained into the model; Rivest argues you should still own the rendering layer so you can swap providers.

- **Call graph decomposition is the cheapest way to move the cost/performance frontier.** Splitting a task into many specialized LLM calls — guards, persona-specialists, multilingual majority vote, mixed AI-and-traditional-code branches — reshapes the cost, latency, and accuracy profile far more than swapping models. Modules in DSPy enforce that the decomposition stays internal to a single end-to-end-callable unit, so the interface above doesn't leak when you reshuffle the graph below. Reinforces [[multi-agent memory needs computer architecture style hierarchy and consistency models]] at the call-graph level rather than the memory level.

- **Inference must target a universal format and map once per provider.** Provider churn is now daily; the only sustainable pattern is to write your rendering, prompts, and call graphs against one canonical request/response shape and map that shape *once* into each provider's idiosyncrasies. This is the litmus test that distinguishes a portable AI pipeline from a thin wrapper around OpenAI.

- **Don't build heavyweight evals before you have working examples.** Rivest's escalation ladder: hand evaluation → small dataset for automatic prompt optimization → production data collection → enough data for fine-tuning. Most teams skip to step 2 or 3 prematurely. Aligns with the eval-driven hill-climbing pattern in [[LangChain's Better-Harness uses eval-driven hill-climbing for agent harness improvement]] — but starts the loop later, after the program already produces non-trivial outputs.

- **Empirical anchor for the framework's economics.** Rivest's prior pipeline at an academic publisher classified ~100M scientific publications/week. ChatGPT-priced equivalent: $400K/week. DSPy + vLLM + Llama 8B + Qwen embeddings: $50/week. The 8,000x cost gap is the durable argument for owning the five components instead of delegating them to a frontier API.

## External Resources

- [DSPy GitHub repository](https://github.com/stanfordnlp/dspy) — the framework being described
- [DSPy Getting Started docs](https://dspy.ai/) — Rivest specifically calls out these example snippets as sufficient
- [BAML](https://github.com/BoundaryML/baml) — listed as one of the structured-output alternatives to JSON/XML
- [Maxime Rivest's first DSPy PR](https://github.com/stanfordnlp/dspy) — formalizing the contract between the five components (referenced but not linked in source)

## Original Content

> [!quote]- @MaximeRivest (Maxime Rivest) — May 15, 2026 — 396 likes, 55 retweets, 5 replies
>
> Article: A Simple Explanation of What DSPy Can Teach You About AI Engineering
>
> ![[maximerivest-065875-001.jpg]]
>
> Exactly one year ago, I tried DSPy for the first time. It felt magical. It took me a whole year of wanting to look into it before I finally sat down one morning and actually ran the example snippets in the Getting Started docs. They felt too short and magical to be "enough"—but they are enough.
>
> Anyway, today this post is not so much about why DSPy is so magical, but rather about what DSPy is doing a bit differently that makes it so important for the future of integrating AI into our society.
>
> > Why listen to me? In the last year, while I was working for a big academic publisher, I used DSPy to build a pipeline that runs on virtually all scientific publications in the world—roughly 100 million times per week—fully releasing data analysts from the tedious task of creating custom scientific classifications. That would have cost $400K per week with ChatGPT. With vLLM, Llama 8B, Qwen embeddings, and DSPy, it cost just $50. I also built a pipeline to parse millions of scanned PDFs at human-level quality while being 10× faster. I have since moved on and am now working full-time in open-source AI engineering. I've made several DSPy community libraries and am now a contributor to DSPy. Just this morning I pushed my first PR to DSPy, where we're taking the first step toward formalizing DSPy's contract between its five key components. Those five components are what I want to teach you about.
>
> ## Optimizers, Signatures, LMs, Modules, and Adapters
>
> I've stated them with their DSPy names and in the order people tend to encounter them.
>
> - Optimizers: Automatically change your prompts and/or model weights to improve performance on an eval.
>
> - Signatures: A high-level way to specify input and output names and types so the details can be left to automatic optimization.
>
> - LM: The connection between DSPy and the outside world—that's where tokens are generated.
>
> - Modules: Where programming, inference strategies, and several LLM calls can be put together into a compute graph, working together as one system (a compound AI system).
>
> - Adapters: Where task-independent, type- and structure-related inference strategies live. These render the task inputs and the optimized instructions into text prompts and request parameters.
>
> Any effective AI programming will need these components. Many AI frameworks have several of them; few (if any, other than DSPy) have all of them. My favorite—and the one that is most underappreciated—is the adapters.
>
> Let's rename them in more general terms. The work of an AI engineer will be about:
>
> - Evals: Evaluating and improving
>
> - Interface: Defining your task, its inputs and outputs at the highest level
>
> - Inference: Making your pipeline run on different providers and models
>
> - Call Graph: Considering how you decompose the task (if you do), what you do with AI, what you do in code or traditional ML, whether you're using reasoning, whether you're using tools
>
> - Rendering: How you render, format, and parse the domain-specific prompt and input/output types into the actual complete request
>
> ## Rendering
>
> That is probably the least obvious part to most readers, so let's start here.
>
> Rendering is about how you render your instructions and inputs to the model and how you instruct the model to render its output. The two often go together. If you tell the model to use XML tags, you'll use XML tags in your prompt. The same goes for JSON and custom delimiters.
>
> When you decide to ask for structured output using XML tags, you are using an inference strategy. That inference strategy is independent of your task—it's about how you will render your prompt to show to the model and how you ask it to render its output so you can parse it.
>
> To get structured output, XML is just one of many options. Alternatives include: JSON, native structured outputs, custom delimiters, BAML, CSV, and many more.
>
> Structured output is only one axis of rendering. How you render reasoning, images, tool calls, videos, PDFs, and citations—these are all rendering-related, task-independent inference strategies you need to make. You can keep it simple and just use whatever is "native" from the provider, but that is rarely the best option. It's just delegating the decision to them.
>
> For example, JSON tool calling is the default now, but there are many other (often superior) ways of rendering a request for tool usage. You could parse and run all Markdown code cells that start with `#!run`. You could parse and run text inside `<toolcall></toolcall>` delimiters, etc.
>
> For PDFs, you could extract the text with traditional OCR *and* provide an image of the document. You could provide just the text, just the image, or the binary (probably with low success), etc.
>
> For images, if it's like a logo, you could turn it into SVG and provide just the SVG. You could do two steps: a model that describes it, then a model that receives just the description. You could lower the resolution or tile multiple images together into one, etc.
>
> For reasoning, you could use `<thinking></thinking>` at the top of the document. You could require the model to have a `#REASONING:` comment before any lines of code. You could have thinking tags throughout the outputs, etc.
>
> This is simple. It's done for you if you're not doing it yourself. The three biggest recent advancements from the big AI providers were all related to rendering: reasoning, structured outputs, and tool calls.
>
> ## Call Graph
>
> Decomposing a task into many sub-calls to the LLM and delegating each to the appropriate model is one of the most effective ways to change the cost, performance, and latency profile of your AI pipeline.
>
> You can call the same model many times. You can use specialized models (guards). You can call the best models and combine their responses. You can have a task done in many different languages and programs and take the majority response. You can have "specialized" model personas, each focusing on different elements. You can mix AI calls with code and traditional programming.
>
> This is all done inside a module, and you should have an end-to-end way of calling it that is independent of your decomposition. These are compound AI systems—and they are powerful.
>
> ## Inference
>
> You will need to shop around and evolve. Open-source and commercial models are released pretty much daily now. You need all of your work on prompts, rendering, and call graphs to be easily plug-and-play with any provider and model.
>
> The most effective way to do that is to target one specific universal format for your AI request, then map that format *once* to all the providers and models you want to try, and map their responses back into a universal format that your pipeline can parse, evaluate, render, etc.
>
> ## Interface
>
> To be useful and impactful, your AI program needs to interface with the world. It needs to be called by an app. It needs to run daily on some data stream, etc. That interface needs to be stable—because it *is* your true task.
>
> You have to keep that separate and abstracted away from all the hacking, fiddling, optimizing, decomposing, and rendering you're doing underneath to reach a satisfactory cost, performance, and accuracy profile. Define your system's signature once, then fiddle inside it.
>
> ## Evals
>
> None of the above means anything if you're not trying to improve your performance. You need to evaluate your work.
>
> Don't build big, beautiful evals too early, though. On many tasks, a single obvious example won't even work. Once you're making your program go from zero to a few working examples, just evaluate by hand: interact, look at your data and traces. Is there a bug in your rendering? In your request to the language models? In your parsing? Etc.
>
> After that, make a small dataset—that's enough to run automatic prompt optimization. Then run it in production, collect your inputs and outputs so you have a real data distribution, and maybe you'll even have enough for fine-tuning!
>
> ## Conclusion
>
> AI engineering has five important components. For any given task, a subset of these will be more important to focus on, but they are all always there—you might just be delegating the decisions to others and to circumstances.
>
> DSPy lets me geek out on any one of them without worrying too much about the others, and it lets all of us share best practices and general solutions to those problems.
>
> — [Original tweet](https://x.com/MaximeRivest/status/2055293570119065875)
