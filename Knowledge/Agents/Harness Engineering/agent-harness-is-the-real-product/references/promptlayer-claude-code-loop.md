---
created: 2026-03-02
description: A deep dive into Claude Code's architecture revealing that a single-threaded master loop with disciplined tooling and TODO-based planning delivers controllable agent autonomy without multi-agent swarms.
source: https://blog.promptlayer.com/claude-code-behind-the-scenes-of-the-master-agent-loop/
type: reference
---

# Claude Code's single-threaded master loop delivers controllable autonomy through radical simplicity

## Key Takeaways

Claude Code's architecture is a masterclass in [[harness engineering improved a coding agent 13 points by changing only system prompts tools and middleware|harness engineering]] — the power comes not from the model but from the scaffolding around it. The core is a single-threaded `while(tool_call)` loop (codenamed `nO`) that processes one action at a time, maintaining a flat message history with no complex threading. This validates the thesis that [[agent-first engineering replaces coding with environment design scaffolding and feedback loops|agent-first engineering]] is about environment design, not model sophistication.

The tool design choices are telling: Anthropic chose regex (ripgrep-style GrepTool) over vector databases for code search, echoing the finding that [[agentic search with grep and full-file loading replaces RAG when context windows are large enough|grep beats embeddings when context windows are large enough]]. Memory is a simple CLAUDE.md Markdown file, not a database. The Compressor (wU2) triggers at ~92% context usage to summarize and offload — a practical approach to the [[prompt caching is the foundational constraint for building long-running agents|context management constraint]] that shapes long-running agents.

Sub-agent spawning is deliberately constrained: at most one sub-agent at a time, with no recursive spawning allowed. This prevents the chaos of uncontrolled agent proliferation while still enabling task decomposition. The `h2A` async queue enables real-time user steering mid-task without restart — a key UX differentiator that makes it feel like a coding partner rather than a batch processor.

The TODO-based planning via `TodoWrite` creates structured task lists that the UI renders as interactive checklists, with system messages re-injecting TODO state after each tool use to prevent the model from losing track. This is [[putting yourself in the agents shoes is the unifying framework for agentic system design|putting yourself in the agent's shoes]] — designing affordances that keep the model oriented.

## External Resources

- [Tom's Guide: Anthropic adding limits to Claude Code](https://www.tomsguide.com/ai/anthropic-is-putting-a-limit-on-a-claude-ai-feature-because-people-are-using-it-24-7) — reporting on 24/7 usage patterns
- [Context engineering (PromptLayer)](https://blog.promptlayer.com/what-is-context-engineering/) — related framing of the discipline
- [Claude Code reverse engineering (xugj520)](https://www.xugj520.cn/en/archives/claude-code-reverse-engineering.html) — technical details on Compressor wU2
- [h2A queue analysis (putaojie)](https://llm.putaojie.top/news/LargeLanguageModel/2025080309284.html) — async dual-buffer queue details
- [Anthropic: Claude Code best practices](https://www.anthropic.com/engineering/claude-code-best-practices) — official permission system docs
- [Latent Space: /think planning mode](https://www.latent.space/p/claude-code) — deep dive on planning capabilities
- [System prompt source (tweet)](https://x.com/Yangyixxxx/status/1951921569196015924) — Claude Code's design principles

## Original Content

> [!quote]- Source Material
>
> # Claude Code: Behind-the-scenes of the master agent loop
>
> By Jared Zoneraich — Aug 29, 2025
>
> When [Tom's Guide](https://www.tomsguide.com/ai/anthropic-is-putting-a-limit-on-a-claude-ai-feature-because-people-are-using-it-24-7) reported that Anthropic had to add weekly limits after users ran Claude Code 24/7, it caused quite a stir. Claude Code did something right. Let's dive into the architecture behind the scenes and see if we can learn a thing or two about agentic engineering (or [context engineering](https://blog.promptlayer.com/what-is-context-engineering/)?).
>
> At its core lies a deceptively simple architecture: a layered system built around a single-threaded master loop (codenamed `nO`), enhanced with real-time steering capabilities (the `h2A` queue), a rich toolkit of developer tools, intelligent planning through TODO lists, controlled sub-agent spawning, and comprehensive safety measures including memory management and diff-based workflows. The thesis is straightforward: **a simple, single-threaded master loop combined with disciplined tools and planning delivers controllable autonomy.** A powerful systems built on the simple foundations.
>
> ## Architecture at a glance
>
> Claude Code's architecture follows a clean, layered design that prioritizes simplicity and debuggability. At the top sits the **user interaction layer**—whether you're using the CLI, VS Code plugin, or web UI, this is where you communicate with Claude. Below that, the **agent core scheduling layer** houses the brain of the system: the main agent loop engine (`nO`) working in tandem with an asynchronous message queue ([h2A](https://llm.putaojie.top/news/LargeLanguageModel/2025080309284.html)) that handles events.
>
> Key components:
>
> * **StreamGen** manages streaming output generation
> * **ToolEngine & Scheduler** orchestrates tool invocations and queues model queries
> * [**Compressor wU2**](https://www.xugj520.cn/en/archives/claude-code-reverse-engineering.html) automatically triggers at approximately 92% context window usage to summarize conversations and move important information to long-term storage. This storage is in a simple Markdown document that serves as the project's long-term memory.
>
> *The Claude Code Flowchart*
> ![[promptlayer-cc-001.png]]
>
> The **operational flow** is elegantly straightforward: user input arrives → the model analyzes and decides on actions → if tools are needed, they're called → results feed back to the model → the cycle continues until a final answer emerges → control returns to the user.
>
> **Claude Code's core design principles**:
>
> > Maintain a flat message history (no complex threading), and always "do the simple thing first"—choosing regex over embeddings for search, Markdown files over databases for memory. ([prompt source](https://x.com/Yangyixxxx/status/1951921569196015924))
>
> ## The master agent loop (nO)
>
> At Claude Code's heart beats a classic agent loop that embodies simplicity through constraint. The **core pattern** is beautifully minimal: `while(tool_call) → execute tool → feed results → repeat`. The loop continues as long as the model's response includes tool usage; when Claude produces a plain text response without tool calls, the loop naturally terminates, awaiting the next user input.
>
> This design maintains a single main thread with one flat list of messages—no swarms, no multiple agent personas competing for control.
>
> Anthropic explicitly chose this approach for debuggability and reliability. When complex problems arise that might benefit from parallelism, Claude Code allows **at most one sub-agent branch** at a time, preventing the chaos of uncontrolled agent proliferation while still enabling sophisticated problem decomposition.
>
> *The simple loop*
> ![[promptlayer-cc-002.png]]
>
> A typical execution chain might look like this: Claude receives a request to fix a bug → uses **Grep** to search for relevant code → calls **View** to read specific files → applies **Edit** to modify the code → runs **Bash** to execute tests → formulates a final answer. Each step builds logically on the previous one, creating a transparent audit trail of the agent's reasoning and actions.
>
> ## Real-time steering with h2A
>
> What makes the `h2A` async dual-buffer queue special is its pause/resume support and ability to incorporate user interjections mid-task without requiring a full restart. Imagine Claude Code working through a complex refactoring when you realize you need to add a constraint or redirect its approach. Instead of stopping everything and starting over, you can simply inject new instructions into the queue, and Claude will seamlessly adjust its plan on the fly.
>
> This queue cooperates with `nO` to create truly interactive, streaming conversations. Rather than waiting for one massive completion, users experience a dynamic back-and-forth where they can guide, correct, or enhance Claude's work in real-time. It's this interactivity that transforms Claude Code from a batch processor into a genuine coding partner.
>
> ## Tools: the agent's hands
>
> Claude Code's tools follow a consistent interface pattern: JSON tool calls flow to sandboxed execution environments, which return results as plain text. This uniformity makes the system predictable and secure while giving Claude access to a developer's full toolkit.
>
> Reading and discovery tools form the foundation. These tools give Claude eyes on your codebase without overwhelming it with information.
>
> * The **View** tool reads files (defaulting to about 2000 lines)
> * **LS** lists directory contents
> * **Glob** performs wildcard searches across even massive repositories.
>
> For searching, Claude relies on **GrepTool**—a full regex-powered search utility that mirrors ripgrep's capabilities. _Notably, Anthropic chose regex over vector databases or embeddings._ Claude already understands code structure deeply enough to craft sophisticated regex patterns, eliminating the complexity and overhead of maintaining search indices.
>
> Code editing happens through three primary tools.
>
> * **Edit** enables surgical patches and diffs for targeted changes
> * **Write/Replace** handle whole-file operations or new file creation
>
> The CLI displays minimal diffs to keep output readable, but every change is tracked and reviewable.
>
> The **Bash** tool provides persistent shell sessions, complete with risk level classification and confirmation prompts for dangerous commands. The system actively filters for injection attempts (blocking backticks and `$()` constructs) while maintaining the flexibility developers need for legitimate operations.
>
> Specialized tools round out the toolkit.
>
> * **WebFetch** retrieves URLs (restricted to user-mentioned or in-project URLs for security)
> * **NotebookRead/Edit** handle Jupyter notebooks by parsing their JSON structure
> * **BatchTool** enables grouped operations for efficiency. Each tool is designed with both power and safety in mind.
>
> *The many layers of Claude Code*
> ![[promptlayer-cc-003.png]]
>
> ## Planning and controlled parallelism
>
> When faced with multi-step tasks, Claude Code's first move is often to call **TodoWrite**, creating a structured JSON task list with IDs, content, status, and priority levels. This isn't just internal bookkeeping—the UI renders these as interactive checklists, giving users visibility into Claude's planning process. As work progresses, Claude updates the entire list (the system doesn't support partial updates), marking items as "in_progress" or "completed."
>
> The [/think planning mode](https://www.latent.space/p/claude-code) allows users to explicitly request a plan before execution begins.
>
> > Behind the scenes, the system uses reminders to keep Claude focused: after tool uses, system messages inject the current TODO list state, preventing the model from losing track of its objectives in long conversations.
>
> For tasks requiring exploration or alternative approaches, Claude can invoke **sub-agents** through the dispatch_agent tool (internally called I2A/Task Agent). These sub-agents operate with **depth limitations**—they cannot spawn their own sub-agents, preventing recursive explosion. Common use cases include wide searches across the codebase or trying multiple solution approaches in parallel. Results from sub-agents feed back into the main loop as regular tool outputs, maintaining the single-thread simplicity of the overall system.
>
> ## Safety, memory, and transparency
>
> Claude Code implements multiple layers of protection through its [permission system](https://www.anthropic.com/engineering/claude-code-best-practices). Write operations, risky Bash commands, and external tool usage (MCP/web) all require explicit allow/deny decisions. Users can configure whitelists or always-allow rules for trusted operations, balancing security with workflow efficiency.
>
> Command sanitization goes beyond simple filtering. The system classifies commands by risk level and appends safety notes to tool outputs, reminding both the model and user of potential dangers. This multi-layered approach catches both accidental mistakes and potential security issues.
>
> The diffs-first workflow transforms how developers interact with AI-generated code. Colorized diffs make changes immediately apparent, encouraging minimal modifications and easy review/revert cycles. This approach naturally promotes test-driven development—Claude can run tests, see failures, and iterate on fixes, all while keeping changes transparent and contained.
>
> For memory and context management, Claude Code uses the CLAUDE.md file as project memory, supplemented by the Compressor wU2 that summarizes conversations when approaching context limits. All tool calls and messages are logged, creating a complete audit trail of the agent's actions and decisions.
>
> ## Conclusion
>
> Claude Code's architecture—the master loop working with h2A, a comprehensive tool suite, TODO-based planning, controlled sub-agents, and robust safety measures—creates a controllable, transparent coding agent that balances power with predictability. The system's strength lies not in complex multi-agent swarms but in its simple, single-loop design that does one thing exceptionally well: help developers write better code faster.
>
> The power comes from its **radical simplicity**. While competitors chase multi-agent swarms and complex orchestration, Anthropic built a single-threaded loop that does one thing obsessively well—think, act, observe, repeat. The same pattern that powers a CS101 while loop now drives an agent capable of refactoring entire codebases. Elegant engineering + constraint-driven design.

[Source](https://blog.promptlayer.com/claude-code-behind-the-scenes-of-the-master-agent-loop/)
