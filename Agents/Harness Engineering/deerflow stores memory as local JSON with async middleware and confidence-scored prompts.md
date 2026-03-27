---
created: 2026-03-27
description: DeerFlow shows a practical agent memory pattern by extracting confidence-scored facts from conversations into a local JSON and injecting only budgeted facts into every prompt.
source: https://x.com/mem0ai/status/2037545669695844399
type: learning
---

## Key Takeaways

DeerFlow treats memory as a first-class middleware concern inside its LangGraph execution graph, not a sidecar service. It updates JSON memory asynchronously on a 30-second debounce and injects selected, budgeted memory facts into prompts on every turn. That reduces critical-path recovery work and makes memory behavior easier to reason about operationally.

The system uses a confidence-scored fact store with an explicit threshold and a 100-fact cap, so noisy utterances do not immediately become durable state. Facts are sorted by confidence and injected until the `2,000-token` budget is filled, which is a concrete operationalization of memory under limited context pressure.

Persistence is intentionally simple: a local `memory.json` file with atomic write-then-rename semantics means operators can inspect and even patch memory directly. Combined with thread-aware async de-dup replacement in the queue, this gives transparency and resilience that many opaque vector-memory systems miss, including in the sense that memory design needs deterministic orchestration more than retrieval complexity.

The design demonstrates two important failure modes that matter in production: no semantic search and no semantic deduplication. That means retrieval remains confidence-first instead of relevance-first, and paraphrase-level duplicates can leak into the budget as context grows. In an [[Obsidian as Agentic Memory]] setup, this tradeoff is cleaner than full semantic pipelines but still can degrade quality as the fact store grows.

DeerFlow’s approach is a strong reminder that durable memory can be engineered as a deterministic runtime layer while leaving models to work on orchestration and action. The memory layer can remain local and deterministic, while model choice can be optimized for cost on extraction and quality where it matters most, rather than spending that complexity on model-only tuning.

## External Resources

- [DeerFlow repository](https://github.com/bytedance/deer-flow) — open-source super agent harness (LangGraph-based) where memory is implemented in middleware and stored in `memory.json`.
- [mem0 developer page](https://mem0.ai/?utm_source=x_article_mem0&utm_medium=incontext_article&utm_campaign=deerflow_memory&utm_content=deerflow_memory) — in-context series context and supporting memory platform referenced by the post.
- [mem0 GitHub repository](https://github.com/mem0ai/mem0) — alternative memory layer for LLMs and agents, referenced in the post.

## Original Content

> [!quote]- Source Material
> @mem0ai (mem0):
> Article: How Memory Works in DeerFlow?
> 
> The #1 repo on GitHub right now is a superagent harness, DeerFlow by ByteDance. It stores memory in JSON. Here’s how it works.
> 
> Most frameworks simulate memory by replaying chat history, stuffing everything into the context window and hoping the model picks what matters.
> 
> DeerFlow does something different.
> 
> It doesn’t store conversations. 
> It extracts facts about the user, scores them by confidence, and injects what fits within a 2,000-token budget into each prompt, async, without bloating the context.
> 
> In this article, I’ll break down how it works based on reverse-engineering a self-hosted DeerFlow instance I run in my docker and inspecting its JSON memory.
> 
> ---
> 
> ## What Is DeerFlow
> 
> DeerFlow (Deep Exploration and Efficient Research Flow) is an open-source super agent harness that orchestrates sub-agents, memory, and sandboxes to do almost anything,  powered by extensible skills.
> 
> They are currently trending #1 in Github with 49.2K stars. Check out their repository [here](https://github.com/bytedance/deer-flow).
> 
> The DeerFlow UI looks like a ChatGPT or Claude interface where you have chat interface + agent options on your left sidebar.
> 
> I tested it by having conversations for about 3 hours, running it locally on Docker Container in my Macbook.
> 
> What I tested:
> 
> - I conversed with DeerFlow about technical topics; memory benchmarks (LOCOMO, LongMemEval), understanding DeerFlow architecture, and general topics like my hobby (paragliding recommendations).
> 
> - I tested memory retrieval by asking questions and asking the agent to omit certain memories.
> 
> The part that doesn’t get enough attention is the memory layer.
> 
> ## The Memory Interface
> 
> The Memory panel organizes everything into:
> 
> - User Context (Work + Personal)
> 
> - Current Focus (Top of Mind)
> 
> - History layers (recent months, earlier context, long-term background)
> 
> - A Facts table
> 
> You can see everything the system learned about you, when it learned it, and how confident it is.
> 
> The source field on each fact is the actual thread UUID, so the system knows exactly which conversation each piece of knowledge came from.
> 
> ## Where the memory sits
> 
> Memory in DeerFlow lives as a file on disk: backend/.deer-flow/memory.json.
> 
> It’s local and it persists across every session. A structured JSON file.
> 
> Within one session, DeerFlow builds a structured profile.
> 
> Each fact has similar content like we have seen in the Memory panel UI.
> 
> Facts below 0.7 confidence don’t get included. 
> The store caps at 100 facts total, evicting the lowest-confidence ones first when it overflows.
> 
> ## How It Actually Works
> 
> DeerFlow’s Lead Agent runs on LangGraph, a graph-based orchestration framework where each agent turn is a node in a stateful execution graph.
> 
> Memory isn’t a plugin or sidecar. It’s baked directly into the middleware chain as position #8, meaning it runs on every agent turn automatically.
> 
> The key component is MemoryMiddleware.
> 
> MemoryMiddleware sits right after TitleMiddleware and before the vision and loop-detection layers.
> 
> This is intentional, memory updates should happen after the title is generated (so the LLM knows what the conversation was about) but before any loop or clarification checks cut the session short.
> 
> MemoryMiddleware doesn't update memory synchronously. It queues the conversation for async processing.
> 
> The flow works like this:
> 
> 1. User sends a message. Agent responds.
> 
> 2. MemoryMiddleware filters the exchange, only user inputs and final AI responses are considered.
> 
> 3. The conversation is added to an async queue with a 30-second debounce timer. If another message arrives from any thread within 30 seconds, the timer resets.
> 
> 4. LLM extractor runs against the conversation and produces a diff: newFacts to add, factsToRemove to delete, and shouldUpdate flags for each summary section.
> 
> 5. Memory JSON is updated
> 
> Before appending a new fact, the system checks for exact content duplication (normalized by stripping whitespace). 
> 
> Note: different phrasing of the same semantic fact will still get added, the dedup is text-based, not semantic.
> 
> You can point model_name at a cheaper model for the extraction step, the memory LLM doesn't need to be your best model, it just needs to be good at structured extraction.
> 
> What I found interesting on step 3 is if the same thread_id already has a pending update in the queue, the new entry replaces it rather than appending. You never process stale mid-conversation snapshots, only the final state of each thread gets processed.
> 
> Memory ingestion doesn’t affect the user experience on getting response from the agent from latency perspective. If a user sends a message, they will get a response right away.
> 
> This is example of a good harness in agentic system.
> 
> ## Where the Memory Actually Shows Up
> 
> When you start a new conversation, every fact that fits within a 2,000-token budget, sorted by confidence, plus all the user, history, and topOfMind summaries get injected into the system prompt inside <memory> tags. 
> 
> There's no hardcoded "top N" limit; it's a token budget, not a count. Tiktoken counts the tokens precisely as facts are added one by one until the budget runs out.
> 
> The agent sees something like this at the start of every session, from my actual session, formatted exactly as format_memory_for_injection() .
> 
> The agent never has to ask "what are you working on?" It already knows based on my Top of Mind History.
> 
> ## What It Looks Like In Practice
> 
> After a 3 hours session, this is what DeerFlow showed in its Fact section in Memory panel. This is what's being compacted into 2000 token.
> 
> ## Memory Retrieval Test
> 
> I tried testing more to understand if it’s able to retrieve my information based on the conversation I had with them.
> 
> Retrieval worked as expected.
> 
> I tried deleting the memories through the chat.
> It only adds more preference in the fact table that "I don't want to talk about this topic despite the LLM Extractor steps showing it has factsToRemove diff recorded.
> 
> There is definitely a workaround, which is modifying the json within the codebase. This shows limitations on this memory system.
> 
> Another limitation I encountered was when I talked about memory benchmark in one of my sessions, despite my user profile showing English preference, it shows questions recommendation in Chinese.
> 
> Likely due to context dominance overriding memory on Deerflow repository itself.
> 
> ---
> 
> ## Conclusion
> 
> Highlight from Deerflow Memory
> 
> 1. Local and yours. No vendor lock-in on the memory store. It's a JSON file. You can read it, edit it, reset it.
> 
> 2. Async by default. Memory updates never slow down your response. The 30-second debounce is clever, it absorbs conversational noise without burning LLM calls on every single message.
> 
> 3. Confidence-scored storage. A single mention of something ("I might try Rust someday") won't permanently alter your memory profile. The confidence threshold filters out weak signals before they accumulate.
> 
> 4. Atomic writes. Write-then-rename is the right pattern here. Memory corruption on process crash is a real failure mode that most toy implementations ignore.
> 
> 5. Deduplication. The duplicate-check before appending means the system won't keep layering the same preference 50 times in 50 different phrasings.
> 
> What It Doesn't Do
> 
> 1. No semantic search. Injection is the highest-confidence facts that fit in the token budget, not the most relevant facts for your current query. If you have 100 stored facts and ask a highly specific question, you get the top facts by confidence, not by relevance to your question.
> 
> 2. No semantic deduplication. The duplicate check is text-based, it strips whitespace and compares strings exactly. I can see this in my actual memory file: facts about comparing DeerFlow's memory against a filesystem + markdown approach, same semantic intent, different phrasing, stored as two separate entries. At 9 facts after one session, this isn't a problem. At 80 facts after a month, it starts to matter.
> 
> 3. Limited intelligence layer + potential compaction issues. Memory is capped at 100 facts, which means it can struggle as context grows. While the confidence score helps prioritize which memories to keep or omit.
> 
> 4. No vector embeddings. This is a deliberate tradeoff, no embedding pipeline, no similarity search. It keeps the system simple and dependency-light, but it brings limitation
> 
> ## Why It Matters
> 
> Most agent frameworks treat memory as a retrieval problem:
> embed everything, store it in a vector database, and retrieve the most similar chunks at query time.
> 
> That works, but it comes at a cost.
> You’re adding an embedding model, a vector store, and a retrieval step to every request. That means more infrastructure, more latency, and more complexity.
> 
> DeerFlow takes a different approach: don’t store conversations, store understanding.
> 
> It runs an asynchronous LLM extraction pass that distills raw conversations into structured facts, then injects those facts directly into future prompts.
> 
> The expensive step happens after the response is already delivered, on a debounced 30-second timer, using any model you choose.
> 
> Overall, it delivers on its promise as a SuperAgent harness.
> 
> The memory system is efficient and production-ready in its current form, with some clear limitations.
> 
> It combines an agentic approach to scoring and injecting facts, but still lacks deeper intelligence layers.
> 
> The result is an agent that knows you, not because it remembers everything you said, but because it builds a persistent model of your preferences, goals, and context. And that model lives as a simple JSON file on your machine.
> 
> DeerFlow builds memory directly into its middleware, so it works out of the box, on every conversation, by default.
> 
> That’s the part worth paying attention to.
> 
> Try the repo below, let me know what you think!
> 
> ## Reference
> 
> - Deerflow Repository: [https://github.com/bytedance/deer-flow](https://github.com/bytedance/deer-flow)
> 
> - Image generated from @claudeai based on personal prompts.
> 
> ---
> 
> In Context #1
> 
> This blog is part of In Context, a mem0 blog series covering AI Agent memory and context engineering.
> 
> [mem0](https://mem0.ai/?utm_source=x_article_mem0&utm_medium=incontext_article&utm_campaign=deerflow_memory&utm_content=deerflow_memory) is an intelligent, open-source memory layer designed for LLMs and AI agents to provide long-term, personalized, and context-aware interactions across sessions.
> 
> - Get your free API Key here --> [app.mem0.ai](https://app.mem0.ai/?utm_source=x_article_mem0&utm_medium=incontext_article&utm_campaign=deerflow_memory&utm_content=deerflow_memory)
> 
> - or self-host mem0 from our open source [github repository](https://github.com/mem0ai/mem0)
> 
> ## Author:
> 
> Livia Ellen (@ellen_in_sf) - Growth engineer at mem0
> 
> ---
> 
> Disclaimer: 
> This is a personal view based on the current analysis and personal testing on the deerflow codebase when the article is written (March 27, 2026). If the source code changes upstream, this analysis might age. Current analysis is tested using Azure OpenAI GPT 5.2 on Docker Container using default config setup. You might have different experiences based on the model that you use.
> 
> For question regarding this publication reach me at livia[dot]ellen[at]mem0[dot]ai
> date: Fri Mar 27 15:01:58 +0000 2026
> likes: 31  retweets: 3  replies: 4
> url: https://x.com/mem0ai/status/2037545669695844399
> 
> [Original post](https://x.com/mem0ai/status/2037545669695844399)
