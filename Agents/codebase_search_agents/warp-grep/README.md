# WarpGrep

4x faster agentic code search with better long-horizon performance. No embeddings required.

**WarpGrep is a code search subagent.** Instead of dumping raw grep results into your main agent's context, WarpGrep intelligently searches your codebase and returns only the relevant code sections—keeping your agent focused across long tasks.

## [​](#what-is-warpgrep) What is WarpGrep?

WarpGrep is a specialized AI model that acts as a **subagent** for code search. When your main agent needs to find code, it delegates to WarpGrep instead of running grep commands directly.
**Under the hood**, WarpGrep has access to three tools:

* **grep** — ripgrep for pattern matching
* **read** — read specific file sections
* **list\_dir** — explore directory structure

The model reasons about what to search, runs up to **24 tool calls** (8 parallel calls × 4 turns) in **under 6 seconds**, and returns only the code that matters.

```
Your Agent                    WarpGrep Subagent
    │                              │
    │  "Find auth middleware"      │
    │ ─────────────────────────────▶
    │                              │ ← grep("auth", src/)
    │                              │ ← grep("middleware", src/)
    │                              │ ← list_dir(src/auth)
    │                              │   ... reasons ...
    │                              │ ← read(src/auth/jwt.ts)
    │     [relevant code only]     │
    │ ◀─────────────────────────────
    │                              │
```

**Why a subagent?** When your main agent searches code directly, grep results pollute its context—irrelevant files accumulate, and performance degrades on long tasks. WarpGrep keeps your main agent's context clean by doing the searching in a separate context window.

Requires `rg` (ripgrep) installed locally. No embeddings, no index setup—works anywhere.

## [​](#why-warpgrep) Why WarpGrep?

## 4x Faster Search

Sub-6 second searches with parallel tool calls. Speed matters when humans are in the loop.

## Clean Context

Search happens in a separate context window. Your main agent only sees relevant results.

## Better Long-Horizon Performance

Agents stay on track across 10, 20, 50+ step tasks without getting lost in irrelevant files.

## No Indexing Required

Works instantly on any repo. No embeddings, no vector database, no setup.

![Warp-Grep Performance](https://mintcdn.com/morph-555d6c14/kn4gdKyv0ura7S84/images/warpgrepwhy.jpg?fit=max&auto=format&n=kn4gdKyv0ura7S84&q=85&s=4989fd16406fb4a99e97ba1c4bed47f5)

[@swyx](https://twitter.com/swyx) and [@cognition](https://twitter.com/cognition) pin P(breaking\_flow) at +10% every 1s. For coding agents, speed is critical. See [benchmarks](https://morphllm.com/benchmarks) for performance data.

## [​](#quick-start) Quick Start

For personal use we recommend using warp grep through our [MCP](/mcpquickstart). If you're building a coding agent, warpgrep is available through the SDK as:

```
import { MorphClient } from '@morphllm/morphsdk';

const morph = new MorphClient({ apiKey: "YOUR_API_KEY" });

const result = await morph.warpGrep.execute({
  query: 'Find authentication middleware',
  repoRoot: '.'
});

if (result.success) {
  for (const ctx of result.contexts) {
    console.log(`File: ${ctx.file}`);
    console.log(ctx.content);
  }
}
```

## [​](#pricing) Pricing

| Type | Price |
| --- | --- |
| Input | $0.80 per 1M tokens |
| Output | $0.80 per 1M tokens |

## [​](#next-steps) Next Steps

[## SDK Tool

Use Warp Grep as a tool in your AI agents with Anthropic, OpenAI, Gemini, or Vercel AI SDK](/sdk/components/warp-grep/tool)[## Direct API

Use SDK primitives to build custom agent loops with full control](/sdk/components/warp-grep/direct)

### [​](#advanced) Advanced

[## Streaming

Stream progress to show users what Warp Grep is doing in real-time](/sdk/components/warp-grep/streaming)[## Custom Providers

Implement custom file system providers for maximum control](/sdk/components/warp-grep/custom-providers)
