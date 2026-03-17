---
created: 2026-03-17
description: LangChain releases Open SWE, an open-source framework capturing the converging architectural patterns observed across Stripe, Ramp, and Coinbase internal coding agents — isolated sandboxes, curated tools, subagent orchestration, and Slack-first invocation — built on Deep Agents and LangGraph.
source: https://x.com/LangChain/status/2033959303766512006
type: learning
---

# Open SWE distills enterprise coding agent patterns into a composable open-source framework

## Key Takeaways

LangChain observed that Stripe (Minions), Ramp (Inspect), and Coinbase (Cloudbot) independently converged on the same architectural patterns for internal coding agents: isolated cloud sandboxes, curated toolsets, subagent orchestration, Slack-first invocation, and rich context at startup. Open SWE captures these patterns as a composable, MIT-licensed framework. This is concrete evidence for the thesis in [[elite engineering orgs are building internal coding agents that spread beyond engineering through Slack visibility]].

The framework is built on [[deepagents Findings (Deep Dive)|Deep Agents]] rather than forking an existing agent — composition over fork. This gives an upgrade path (improvements flow without rebuilding customizations) and org-specific customization via configuration rather than code changes. The same approach Ramp took building Inspect on OpenCode.

The architecture maps directly to [[the agent harness is the RL training environment not deployment infrastructure bolted on after|harness-as-training-environment]] principles: every component is pluggable (sandbox provider, model, tools, triggers, system prompt, middleware). The middleware layer is particularly interesting — deterministic hooks like `check_message_queue_before_model` (injecting follow-up messages mid-run) and `open_pr_if_needed` (safety net for critical steps) separate agentic from deterministic orchestration, which connects to [[harness engineering improved a coding agent 13 points by changing only system prompts tools and middleware]].

Context engineering follows a two-layer approach: repository-wide via AGENTS.md files (conventions, testing requirements, architecture decisions) plus task-specific context from Linear issues or Slack threads. This validates the pattern in [[context files beat MCP schemas for internal agents because they encode how your team actually uses each tool]].

Tool curation is emphasized over accumulation — Stripe has ~500 tools but carefully curated. Open SWE ships a focused set plus Deep Agents builtins (read/write/edit/ls/glob/grep/write_todos/task). The "curated not accumulated" framing is a useful heuristic for [[designing agent tools is an iterative art shaped by model capabilities not fixed engineering rules|tool design]].

Sandbox support includes Modal, Daytona, Runloop, and LangSmith out of the box, with a pluggable backend for custom infrastructure. Each conversation thread gets a persistent sandbox, reused across follow-ups.

## External Resources

- [Open SWE on GitHub](https://github.com/langchain-ai/open-swe) — the framework itself (MIT license)
- [Deep Agents](https://github.com/langchain-ai/deepagents) — the composable agent foundation
- [LangSmith Sandboxes](https://blog.langchain.com/introducing-langsmith-sandboxes-secure-code-execution-for-agents/) — secure code execution for agents
- [Stripe Minions blog post](https://stripe.dev/blog/minions-stripes-one-shot-end-to-end-coding-agents)
- [Ramp Inspect on Modal](https://modal.com/blog/how-ramp-built-a-full-context-background-coding-agent-on-modal)
- [Coinbase Cloudbot blog post](https://www.coinbase.com/blog/building-enterprise-AI-agents-at-Coinbase)
- [Installation Guide](https://github.com/langchain-ai/open-swe/blob/main/INSTALLATION.md)
- [Customization Guide](https://github.com/langchain-ai/open-swe/blob/main/CUSTOMIZATION.md)

## Original Content

> [!quote]- Source: @LangChain on X (Mar 17, 2026) · 332 likes · 35 retweets · 7 replies

**Open SWE: An Open-Source Framework for Internal Coding Agents**

Over the past year, we've observed several engineering organizations building internal coding agents that operate alongside their development teams. Stripe developed [Minions](https://stripe.dev/blog/minions-stripes-one-shot-end-to-end-coding-agents), Ramp built [Inspect](https://modal.com/blog/how-ramp-built-a-full-context-background-coding-agent-on-modal), and Coinbase created [Cloudbot](https://www.coinbase.com/blog/building-enterprise-AI-agents-at-Coinbase). These systems integrate into existing workflows (accessible through Slack, Linear, and GitHub) rather than requiring engineers to adopt new interfaces.

While these systems were developed independently, they've converged on similar architectural patterns: isolated cloud sandboxes, curated toolsets, subagent orchestration, and integration with developer workflows. This convergence suggests some common requirements for deploying AI agents in production engineering environments.

Today, we're releasing Open SWE, an open-source framework that captures these patterns in a customizable form. Built on [Deep Agents](https://github.com/langchain-ai/deepagents) and [LangGraph](https://langchain-ai.github.io/langgraph/), Open SWE provides the core architectural components we've observed across these implementations. If your organization is exploring internal coding agents, this can serve as a starting point.

### Patterns from Production Deployments

When we looked at how Stripe, Ramp, and Coinbase built their coding agents, we noticed they made similar architectural decisions. Here's what these systems have in common:

Isolated execution environments: Tasks run in dedicated cloud sandboxes with full permissions inside strict boundaries. This isolates the blast radius of any mistake from production systems while allowing agents to execute commands without approval prompts for each action.

Curated toolsets: According to [Stripe's engineering team](https://stripe.dev/blog/minions-stripes-one-shot-end-to-end-coding-agents), their agents have access to around 500 tools, but these are carefully selected and maintained rather than accumulated over time. Tool curation appears to matter more than tool quantity.

Slack-first invocation: All three systems integrate with Slack as a primary interface, meeting developers in their existing communication workflows rather than requiring context switches to new applications.

Rich context at startup: These agents pull full context from Linear issues, Slack threads, or GitHub PRs before beginning work, reducing the overhead of discovering requirements through tool calls.

Subagent orchestration: Complex tasks get decomposed and delegated to specialized child agents, each with isolated context and focused responsibilities.

These architectural choices have proven effective across multiple production deployments, though organizations will likely need to adapt specific components to their own environments and requirements.

### Open SWE's Architecture

Open SWE provides an open-source implementation of similar architectural patterns. Here's how the framework maps to what we've observed:

**1. Agent Harness: Composed on Deep Agents**

Rather than forking an existing agent or building from scratch, Open SWE composes on the [Deep Agents](https://github.com/langchain-ai/deepagents) framework. This approach is similar to how [Ramp's team built Inspect](https://modal.com/blog/how-ramp-built-a-full-context-background-coding-agent-on-modal) on top of OpenCode.

Composition provides two advantages:

Upgrade path: When Deep Agents improves (better context management, more efficient planning, optimized token usage), you can incorporate those improvements without rebuilding your customizations.

Customization without forking: You can maintain org-specific tools, prompts, and workflows as configuration rather than as modifications to core agent logic.

```python
create_deep_agent(
    model="anthropic:claude-opus-4-6",
    system_prompt=construct_system_prompt(repo_dir, ...),
    tools=[
        http_request,
        fetch_url,
        commit_and_open_pr,
        linear_comment,
        slack_thread_reply
    ],
    backend=sandbox_backend,
    middleware=[
        ToolErrorMiddleware(),
        check_message_queue_before_model,
        ...
    ],
)
```

Deep Agents provides infrastructure that can support these patterns: built-in planning via write_todos, file-based context management, native subagent spawning via the task tool, and middleware hooks for deterministic orchestration.

**2. Sandbox: Isolated Cloud Environments**

Each task runs in its own isolated cloud sandbox, a remote Linux environment with full shell access. The repository is cloned in, the agent receives complete permissions, and any errors are contained within that environment.

Open SWE supports multiple sandbox providers out of the box:

- [Modal](https://modal.com/)
- [Daytona](https://www.daytona.io/)
- [Runloop](https://www.runloop.ai/)
- [LangSmith](https://blog.langchain.com/introducing-langsmith-sandboxes-secure-code-execution-for-agents/)

You can also implement your own sandbox backend.

This follows a pattern we've observed: isolate first, then grant full permissions inside the boundary.

Key behaviors:

- Each conversation thread gets a persistent sandbox, reused across follow-up messages
- Sandboxes automatically recreate if they become unreachable
- Multiple tasks run in parallel, each in its own sandbox

**3. Tools: Curated, Not Accumulated**

Open SWE ships with a focused toolset:

*Open SWE's curated tool inventory*
![[langchain-512006-002.png]]

Plus the built-in Deep Agents tools: read_file, write_file, edit_file, ls, glob, grep, write_todos, and task (subagent spawning).

A smaller, curated toolset can be easier to test, maintain, and reason about. When you need additional tools for your organization (internal APIs, custom deployment systems, specialized testing frameworks), you can add them explicitly.

**4. Context Engineering: AGENTS.md + Source Context**

Open SWE gathers context from two sources:

AGENTS.md file: If your repository contains an AGENTS.md file at the root, it's read from the sandbox and injected into the system prompt. This file can encode conventions, testing requirements, architectural decisions, and team-specific patterns that every agent run should follow.

Source context: The full Linear issue (title, description, comments) or Slack thread history is assembled and passed to the agent before it starts, providing task-specific context without additional tool calls.

This two-layer approach balances repository-wide knowledge with task-specific information.

**5. Orchestration: Subagents + Middleware**

Open SWE's orchestration combines two mechanisms:

Subagents: The Deep Agents framework supports spawning child agents via the task tool. The main agent can delegate independent subtasks to isolated subagents, each with its own middleware stack, todo list, and file operations.

Middleware: Deterministic middleware hooks run around the agent loop:

- check_message_queue_before_model: Injects follow-up messages (Linear comments or Slack messages that arrive mid-run) before the next model call. This allows users to provide additional input while the agent is working.
- open_pr_if_needed: Acts as a safety net that commits and opens a PR if the agent didn't complete this step. This ensures critical steps happen reliably.
- ToolErrorMiddleware: Catches and handles tool errors gracefully.

This separation between agentic (model-driven) and deterministic (middleware-driven) orchestration can help balance reliability with flexibility.

**6. Invocation: Slack, Linear, and GitHub**

We've observed that many teams converge on Slack as a primary invocation surface. Open SWE follows a similar pattern:

Slack: Mention the bot in any thread. Supports repo:owner/name syntax to specify which repository to work on. The agent replies in-thread with status updates and PR links.

Linear: Comment @openswe on any issue. The agent reads the full issue context, reacts with 👀 to acknowledge, and posts results back as comments.

GitHub: Tag @openswe in PR comments on agent-created PRs to have it address review feedback and push fixes to the same branch.

Each invocation creates a deterministic thread ID, so follow-up messages on the same issue or thread route to the same running agent.

**7. Validation: Prompt-Driven + Safety Nets**

The agent is instructed to run linters, formatters, and tests before committing. The open_pr_if_needed middleware acts as a backstop—if the agent finishes without opening a PR, the middleware handles it automatically.

You can extend this validation layer by adding deterministic CI checks, visual verification, or review gates as additional middleware.

### Why Deep Agents

Deep Agents provides the foundation that makes this architecture composable and maintainable.

Context management: Long-running coding tasks can produce large amounts of intermediate data (file contents, command outputs, search results). Deep Agents handles this through file-based memory, offloading large results instead of keeping everything in the conversation history. This can help prevent context overflow when working on larger codebases.

Planning primitives: The built-in write_todos tool provides a structured way to break down complex work, track progress, and adapt plans as new information emerges. We've found this particularly helpful for multi-step tasks that span extended periods.

Subagent isolation: When the main agent spawns a child agent via the task tool, that subagent gets its own isolated context. Different subtasks don't pollute each other's conversation history, which can lead to clearer reasoning on complex, multi-faceted work.

Middleware hooks: Deep Agents' middleware system allows you to inject deterministic logic at specific points in the agent loop. This is how Open SWE implements message injection and automatic PR creation—behaviors that need to happen reliably.

Upgrade path: Because Deep Agents is actively developed as a standalone library, improvements to context compression, prompt caching, planning efficiency, and subagent orchestration can flow to Open SWE without requiring you to rebuild your customizations.

This composability offers similar advantages to what [Ramp's team described](https://modal.com/blog/how-ramp-built-a-full-context-background-coding-agent-on-modal) when building on OpenCode: you get the benefits of a maintained, improving foundation while retaining control over your org-specific layer.

### Customization for Your Organization

Open SWE is intended as a customizable foundation rather than a finished product. Every major component is pluggable:

Sandbox provider: Swap between Modal, Daytona, Runloop, or LangSmith. Implement your own sandbox backend if you have internal infrastructure requirements.

Model: Use any LLM provider. The default is Claude Opus 4, but you can configure different models for different subtasks.

Tools: Add tools for your internal APIs, deployment systems, testing frameworks, or monitoring platforms. Remove tools you don't need.

Triggers: Modify the Slack, Linear, and GitHub integration logic. Add new trigger surfaces like email, webhooks, or custom UIs.

System prompt: Customize the base prompt and the logic for incorporating AGENTS.md files. Add org-specific instructions, constraints, or conventions.

Middleware: Add your own middleware hooks for validation, approval gates, logging, or safety checks.

The [Customization Guide](https://github.com/langchain-ai/open-swe/blob/main/CUSTOMIZATION.md) walks through each of these extension points with examples.

### Comparison to Internal Implementations

Here's how Open SWE compares to the internal systems at Stripe, Ramp, and Coinbase based on [publicly](https://stripe.dev/blog/minions-stripes-one-shot-end-to-end-coding-agents) [available](https://modal.com/blog/how-ramp-built-a-full-context-background-coding-agent-on-modal) [information](https://www.coinbase.com/blog/building-enterprise-AI-agents-at-Coinbase):

*Comparison of architectural decisions across Open SWE, Stripe Minions, Ramp Inspect, and Coinbase Cloudbot*
![[langchain-512006-003.png]]

The core patterns are similar. The differences lie in implementation details, internal integrations, and org-specific tooling—which is exactly what you'd expect when adapting a framework to different environments.

### Getting Started

Open SWE is available now on [GitHub](https://github.com/langchain-ai/open-swe).

[Installation Guide](https://github.com/langchain-ai/open-swe/blob/main/INSTALLATION.md): Walks through GitHub App creation, LangSmith setup, Linear/Slack/GitHub triggers, and production deployment.

[Customization Guide](https://github.com/langchain-ai/open-swe/blob/main/CUSTOMIZATION.md): Shows how to swap the sandbox, model, tools, triggers, system prompt, and middleware for your organization.

The framework is MIT-licensed. You can fork it, customize it, and deploy it internally. If you build something interesting on top of it, we'd be interested to hear about it.

Several engineering organizations have successfully deployed internal coding agents in production. Open SWE provides an open-source implementation of similar architectural patterns, designed to be customized for different codebases and workflows. While we're still learning what works across different contexts, this framework offers a starting point for teams exploring this approach.

Try Open SWE: [github.com/langchain-ai/open-swe](https://github.com/langchain-ai/open-swe)

Learn about Deep Agents: [docs.langchain.com/oss/python/deepagents](https://docs.langchain.com/oss/python/deepagents/overview)

Learn about LangSmith Sandboxes: https://blog.langchain.com/introducing-langsmith-sandboxes-secure-code-execution-for-agents/

Read the docs: [Open SWE Documentation](https://github.com/langchain-ai/open-swe/tree/main/apps/docs)

[Original post](https://x.com/LangChain/status/2033959303766512006)
