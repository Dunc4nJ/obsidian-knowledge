---
created: 2026-03-02
description: LangChain argues that filesystems provide a single interface for agents to store, retrieve, and update infinite context — solving token bloat, niche retrieval, and self-improving instructions through tools like grep, glob, and read_file.
source: https://blog.langchain.com/how-agents-can-use-filesystems-for-context-engineering/
type: framework
---

## Key Takeaways

The filesystem-as-context-engineering-primitive thesis unifies several patterns from different companies into a single abstraction. [[manus-context-engineering|Manus]] uses the filesystem to offload tool results (compact references in context, full content on disk). [[cursor-dynamic-context-discovery|Cursor]] uses it for chat history compression (save full history to file, summarize in context, restore on demand). Claude Code uses grep and glob instead of vector search. All of these are instances of the same principle: the filesystem is infinite context with random access.

The four failure modes — too many tokens, needs large context, finding niche information, and learning over time — map cleanly to the write/select/compress/isolate taxonomy from [[langchain-context-engineering-for-agents|LangChain's broader context engineering framework]]. The filesystem addresses all four: write results to files (token reduction), read plans back (long-horizon coherence), grep for specifics (niche retrieval), and update instruction files from user feedback (learning).

The most forward-looking pattern is agents writing their own instruction files — essentially self-modifying their prompts based on user feedback. This is still emerging and unsolved, but represents the natural endpoint of filesystem-based context engineering: the agent's entire context becomes a living, evolving workspace rather than a static prompt plus conversation history.

## External Resources

- [Deep Agents (Python)](https://github.com/langchain-ai/deepagents) — Open source agent with filesystem access
- [Deep Agents (TypeScript)](https://github.com/langchain-ai/deepagentsjs) — TypeScript version
- [Manus Context Engineering blog](https://manus.im/blog/Context-Engineering-for-AI-Agents-Lessons-from-Building-Manus) — Filesystem offloading pattern

## Original Content

> [!quote]- Source Material
> **How agents can use filesystems for context engineering**
> By Nick Huang — LangChain Blog, November 2025
>
> A key feature of deep agents is their access to a set of filesystem tools. Deep agents can use these tools to read, write, edit, list, and search for files in their filesystem.
>
> **A view of context engineering:** Agents generally have access to a lot of context. In order to answer a question, the agent needs some important context. While aiming to answer, the agent retrieves some body of context. Our job as agent engineers is to fit retrieved to needed (make sure retrieved context is as small a superset of needed information as possible).
>
> **Challenges:**
> 1. Too many tokens (retrieved >> necessary) — web search returns 10k tokens per call
> 2. Needs large amounts of context (necessary > window) — requires agentic search
> 3. Finding niche information (retrieved ≠ necessary) — semantic search fails on technical content
> 4. Learning over time (total ≠ necessary) — agent lacks context it needs
>
> **How filesystems help:**
>
> **Too many tokens:** Write tool results to filesystem, grep for relevant parts. Agent uses filesystem as scratch pad for large context.
>
> **Large context needs:** Write plans to filesystem and read back later ("manipulate attention through recitation"). Subagents write knowledge to filesystem instead of replying to main agent ("minimize game of telephone"). Store instructions as files for dynamic discovery (Anthropic skills).
>
> **Niche information:** Filesystem search (ls, glob, grep) as alternative to semantic search. Models are specifically trained to traverse filesystems. Information is often already structured logically in directories. glob and grep allow isolating specific files, lines, and characters. read_file allows specifying which lines to read. Cursor showed benefits of using both filesystem and semantic search together.
>
> **Learning over time:** Agents can write to their own instruction files, updating prompts based on user feedback. This is emerging and unsolved but represents agents growing their own skillsets over time.
>
> [Original post](https://blog.langchain.com/how-agents-can-use-filesystems-for-context-engineering/)
