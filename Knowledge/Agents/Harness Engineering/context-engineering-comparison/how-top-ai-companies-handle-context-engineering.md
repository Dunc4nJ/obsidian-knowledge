---
created: 2026-03-02
description: A comprehensive comparison of how Manus, Cursor, Anthropic, OpenAI, Google, and LangChain each approach context engineering for AI agents — revealing near-consensus on filesystem-as-memory and dynamic retrieval, but active disagreement on tool overload handling and long vs lean context.
source: https://x.com/Hxlfed14/status/2022984467380682856
type: synthesis
---

## Key Takeaways

The most striking pattern across all six companies is convergence on the filesystem as extended memory. [[manus-context-engineering|Manus]] offloads tool results to files and keeps compact references in context. [[cursor-dynamic-context-discovery|Cursor]] saves chat history to files before summarizing. [[anthropic-effective-context-engineering|Anthropic]] persists planning files across context windows. [[langchain-filesystem-context-engineering|LangChain]] explicitly calls filesystems "a single interface for infinite context." Even [[google-long-context-docs|Google]], which bets on massive context windows, uses caching mechanisms that parallel filesystem-based approaches. The filesystem has become the industry's consensus answer to the core constraint: context windows are finite, agents generate tokens exponentially.

Where companies diverge is revealing. Manus uses logit masking to control tool availability (all tools loaded, behavioral constraints applied during decoding), while Cursor uses lazy MCP loading (only tool names upfront, full definitions on demand — 46.9% token reduction). These are opposite strategies that both work, suggesting there may not be a single correct approach to tool overload. Similarly, Google's "just put it all in" long context bet contradicts everyone else's compression-first philosophy, yet research still shows 15-47% performance drops as context grows, validating the compression camp.

The thread's most valuable observation is meta: "the teams shipping the best agents keep simplifying." Manus has been rewritten five times, each time removing complexity. This echoes the [[lance-martin-context-engineering-in-manus|Bitter Lesson]] warning — if your harness gets more complex while models improve, the harness is the bottleneck. The companion thread [[agent harness is the real product|"Agent Harness is the Real Product"]] dives deeper into individual company approaches, while this thread maps the cross-company convergences and divergences.

## External Resources

- [Manus — Context Engineering blog](https://manus.im/blog/Context-Engineering-for-AI-Agents-Lessons-from-Building-Manus) — Six production principles
- [Cursor — Dynamic Context Discovery](https://cursor.com/blog/dynamic-context-discovery) — Five techniques with A/B data
- [Anthropic — Effective Context Engineering](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents) — Attention budget framework
- [Anthropic — Effective Harnesses](https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents) — Long-running agent patterns
- [Anthropic — Code Execution with MCP](https://www.anthropic.com/engineering/code-execution-with-mcp) — 98.7% context reduction
- [OpenAI — Session Memory cookbook](https://cookbook.openai.com/examples/agents_sdk/session_memory) — Trimming and compression
- [OpenAI — Context Personalization cookbook](https://cookbook.openai.com/examples/agents_sdk/context_personalization) — State-based long-term memory
- [Google DeepMind — ReadAgent](https://arxiv.org/abs/2402.09727) — Gist memory for 3-20x context extension
- [Google — Long Context docs](https://ai.google.dev/gemini-api/docs/long-context) — 1M+ token context paradigm
- [LangChain — Context Engineering for Agents](https://blog.langchain.com/context-engineering-for-agents/) — Write/select/compress/isolate taxonomy
- [LangChain — The Rise of Context Engineering](https://blog.langchain.com/the-rise-of-context-engineering/) — Foundational definition
- [LangChain — Filesystem Context Engineering](https://blog.langchain.com/how-agents-can-use-filesystems-for-context-engineering/) — Filesystem as context primitive
- [LangChain — Deep Agents](https://blog.langchain.com/deep-agents/) — No-op tools as context engineering
- [Phil Schmid — Context Engineering Part 2](https://www.philschmid.de/context-engineering-part-2) — Practitioner patterns
- [Lance Martin — Context Engineering in Manus](https://rlancemartin.github.io/2025/10/15/manus/) — Reduce/isolate/offload analysis

## References

Existing notes (from [[agent harness is the real product|companion thread]]):
- [[manus-context-engineering]]
- [[cursor-dynamic-context-discovery]]
- [[anthropic-effective-context-engineering]]
- [[anthropic-effective-harnesses]]
- [[langchain-deep-agents]]
- [[phil-schmid-context-engineering-pt2]]

New reference notes:
- [[openai-session-memory-cookbook]]
- [[openai-context-personalization-cookbook]]
- [[google-readagent-gist-memory]]
- [[google-long-context-docs]]
- [[langchain-context-engineering-for-agents]]
- [[langchain-rise-of-context-engineering]]
- [[langchain-filesystem-context-engineering]]
- [[lance-martin-context-engineering-in-manus]]

Existing vault note:
- [[code execution with MCP cuts tool token overhead 98 percent by presenting servers as filesystem APIs instead of upfront definitions]]

## Original Content

> @Hxlfed14 (Himanshu) — 2026-02-15
>
> Article: How Top AI Companies Handle Context Engineering
>
> The companies building the most capable AI agents today: Manus, Cursor, Anthropic, OpenAI, Google DeepMind, LangChain — are all solving the same problem: what information should an LLM see, when should it see it, and how should it be structured?
>
> What is interesting is that these companies have been publishing their approaches openly through detailed blog posts, SDK cookbooks, research papers.
>
> Each started from different constraints and arrived at different solutions. Some of those solutions converge. Some directly contradict each other.
>
> I went through all of it. This article breaks down what each company does, compares their strategies head-to-head, and maps the techniques that are emerging as industry standard versus those that remain experimental.
>
> *Thread header image*
> ![[hxlfed14-682856-001.jpg]]
>
> ---
>
> ## The Core Problem
>
> Every company here faces the same constraint: context windows are finite, and agents generate tokens exponentially.
>
> A typical Manus task involves ~50 tool calls. Each appends observations to the context. Without intervention, the window fills and performance degrades: "context rot."
>
> The companies frame this differently, Anthropic calls it an "attention budget" problem, LangChain uses the "context window = RAM" analogy but all converge on the same conclusion: smarter context management beats bigger context windows.
>
> *Sources analyzed overview*
> ![[hxlfed14-682856-002.png]]
>
> ---
>
> ## How Each Company Does It
>
> ### Manus: "Six Principles from Production"
>
> Context: Manus serves millions of users. A typical task averages 50 tool calls with a 100:1 input-to-output token ratio.
>
> They have rewritten their agent framework four times each time after discovering a better way to shape context. They call this process "Stochastic Gradient Descent"
>
> Six principles, condensed:
>
> - KV-Cache is sacred. Cached tokens cost $0.30/MTok vs $3/MTok uncached (10x). Keep the prompt prefix stable, logs append-only. Even reordered JSON keys invalidate the cache.
> - Logit masking over tool removal. All tools stay loaded permanently. Availability per step is controlled by constraining output token probabilities during decoding. Context stays stable; only behavioral constraints change.
> - File system as extended memory. Large observations go to files; only lightweight references stay in context. Compression is fine as long as it is reversible.
> - Attention manipulation via recitation. A living todo.md is updated and re-read every step, placing the current objective in the high-attention zone (end of context).
> - Errors preserved, not cleaned. Failed actions stay in context for implicit belief updating, reducing repeated mistakes.
> - Structured variation against fixation. Different serialization templates and phrasing across iterations prevent the model from falling into rigid, repetitive patterns.
>
> *Manus architecture overview*
> ![[hxlfed14-682856-003.jpg]]
>
> *Manus KV-cache and token economics*
> ![[hxlfed14-682856-004.jpg]]
>
> *Manus six principles summary*
> ![[hxlfed14-682856-005.jpg]]
>
> ---
>
> ### Cursor: "Dynamic Context Discovery"
>
> Context: Their Jan 2026 research blog describes five techniques they developed after observing that as models improved, providing fewer details up front and letting the agent pull its own context produced better results. They back this with A/B test data.
>
> Five techniques, condensed:
>
> - Files as tool output interface. Large JSON responses get written to files. Agent reads incrementally via tail/grep. No unnecessary summarization.
> - Chat history files for lossless compression. Full history is saved to a file before summarization. Agent can restore any lost detail — lossy compression becomes lossless.
> - Skills as discoverable files. Domain capabilities stored as files, discovered via search, not pre-loaded in the system prompt.
> - Lazy MCP tool loading. Only tool names loaded upfront. Full definitions fetched on-demand. 46.9% token reduction in A/B tests.
> - Terminal sessions as files. Shell history becomes a searchable file and agent greps for what it needs.
>
> Key assumption: This works because models are now good enough to know what context they need.
>
> *Cursor techniques overview*
> ![[hxlfed14-682856-006.jpg]]
>
> *Cursor five techniques detail*
> ![[hxlfed14-682856-007.jpg]]
>
> ---
>
> ### Anthropic: "The Attention Budget Framework"
>
> Context: Anthropic published what many consider the foundational framing for context engineering (September 2025), followed by a deep dive on long-running agent harnesses (January 2026) and MCP-based code execution (November 2025). Their work is grounded in building Claude Code.
>
> Core strategies, condensed:
>
> - The Goldilocks Zone for system prompts. Two failure modes: over-engineered 2K+ word if-else prompts that break on edge cases, and vague "be helpful" prompts. Fix: organized sections (XML tags/markdown headers), canonical examples, let the model handle edge cases.
> - Just-in-time retrieval. Agent retrieves context at runtime based on what it actually needs — shifting from pre-inference RAG to in-loop retrieval.
> - Lean tools with no overlap. If a human engineer cannot say which tool to use in a given situation, neither can the model.
> - Compaction at 95%. Claude Code auto-summarizes when the window hits 95% capacity. For long-running agents, an initializer agent writes a comprehensive requirements file (200+ features) that persists across windows.
> - Code execution over direct tool calls. For MCP with many servers, agents write code that calls tools rather than invoking them directly.
>
> Two failure patterns: Agents "one-shot" complex projects (run out of context mid-implementation), and compaction transfers information imperfectly across windows.
>
> *Anthropic approach overview*
> ![[hxlfed14-682856-008.jpg]]
>
> *Anthropic strategies detail*
> ![[hxlfed14-682856-009.jpg]]
>
> ---
>
> ### OpenAI: "Session Memory as Infrastructure"
>
> Context: OpenAI's approach is documented through their Agents SDK and two detailed cookbooks — one on short-term session memory (September 2025) and one on long-term context personalization (December 2025).
>
> Three patterns, condensed:
>
> - Trimming. Drop older turns, keep last N. Simple, deterministic, zero latency — but causes "amnesia" for earlier constraints.
> - Compression. Summarize older history with a separate model call. Summaries act as "clean rooms" that can correct prior mistakes. Risk: summary drift.
> - State-based long-term memory. Structured state objects (profile + notes) persist across sessions. Each run: distill memories → consolidate notes → inject state with precedence (latest input → session → global defaults).
>
> Key distinction: OpenAI contrasts retrieval-based memory (searching past interactions as documents) with state-based memory (structured fields with precedence). State-based supports belief updates over fact accumulation — more reliable, more deterministic.
>
> *OpenAI approach overview*
> ![[hxlfed14-682856-010.png]]
>
> *OpenAI three patterns detail*
> ![[hxlfed14-682856-011.png]]
>
> ---
>
> ### Google DeepMind: "The Long Context Bet"
>
> Context: Google's approach is distinct. While other companies focus on fitting the right tokens into a limited window, Google bets on abundance — Gemini models offer up to 2M tokens of context, with research testing up to 10M. Their ReadAgent paper (2024) adds a complementary research angle on memory compression.
>
> Approach, condensed:
>
> - "Just put it all in." Default to filling the context window. RAG and summarization are workarounds for limited context models. Evidence: Gemini learned to translate Kalamang (<200 speakers) from in-context materials alone.
> - Context caching. Up to 75% cost reduction via caching APIs, analogous to Manus's KV-cache optimization.
> - Progressive truncation. Compress older context while maintaining the logical thread.
> - ReadAgent — Gist Memory (research). Compress interactions into episodic "gist memories," look up originals when needed. Increases effective context by 20x. Modeled on how humans read long documents.
> - Many-shot in-context learning. Unique leverage of massive windows — hundreds/thousands of examples in-context, matching fine-tuned model performance.
>
> The tension: Long context doesn't eliminate context engineering but it changes what it looks like. Research still shows 15-47% performance drops as context length increases.
>
> *Google approach overview*
> ![[hxlfed14-682856-012.jpg]]
>
> ---
>
> ### LangChain: "The Framework Taxonomy"
>
> Context: Their contribution is taxonomic — organizing what others are doing into a coherent framework, backed by their LangGraph implementation and "Deep Agents" analysis.
>
> - Write — save context outside the window. Scratchpads, persistent state objects, filesystem storage.
> - Select — pull relevant context in. RAG, semantic search, filesystem traversal with grep/glob.
> - Compress — retain only essential tokens. Conversation summarization, tool output compression. LangChain measured reduction from 115K to 60K tokens.
> - Isolate — split context across agents. Multi-agent architectures where sub-agents get their own context windows.
> - No-op tools as context engineering. Claude Code's todo list tool does nothing functionally — it's purely a context strategy that forces the agent to articulate its plan.
>
> ---
>
> ## The Technique Matrix
>
> Quick-reference mapping techniques to companies based on public documentation.
>
> Legend: [C] = Core differentiator, [Y] = Yes, uses/advocates, [--] = Not discussed publicly, [alt] = Different approach to same problem
>
> *Context window management matrix*
> ![[hxlfed14-682856-013.png]]
>
> *Information retrieval matrix*
> ![[hxlfed14-682856-014.png]]
>
> *Planning and coherence matrix*
> ![[hxlfed14-682856-015.png]]
>
> *Multi-agent and isolation matrix*
> ![[hxlfed14-682856-016.png]]
>
> *Memory and robustness matrix*
> ![[hxlfed14-682856-017.png]]
>
> ---
>
> ## Where The Industry Agrees (and Where It Doesn't)
>
> **Near-consensus:** File system as extended memory. Dynamic over static retrieval. Persistent plan files for long-running tasks. Error traces kept, not cleaned.
>
> **Active disagreement:** How to handle tool overload (Manus's logit masking vs Cursor's lazy loading — opposite strategies, both work). Long context vs lean context (Google vs everyone else). Whether to use frameworks or raw primitives.
>
> **Unsolved:** Session memory — no two companies do it the same way. Context engineering evaluation — no standard benchmarks exist. Cursor's 46.9% token reduction is one of the few published numbers. When to isolate sub-agent context vs share it is still purely empirical.
>
> One pattern worth noting: the teams shipping the best agents keep simplifying. Manus has been rewritten five times. Each rewrite removed things. If your agent harness is getting more complex while models get better, something is wrong.
>
> ---
>
> ## Open Questions
>
> Long context vs. smart compression — which wins at scale?
> Should sub-agents share context or communicate results?
> How do you evaluate context engineering quality?
>
> ---
>
> Based entirely on publicly available blogs, documentation, and research papers from the companies referenced.
>
> Engagement: Thread posted 2026-02-15
> [Original thread](https://x.com/Hxlfed14/status/2022984467380682856)
