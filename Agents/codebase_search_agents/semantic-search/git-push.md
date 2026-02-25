# Repo Storage

AI-native git for coding agents

**Repo Storage is in Early Beta**
This feature is actively being developed and refined. While stable for testing and development, expect improvements and potential changes as we optimize performance and capabilities.

Git built for AI coding agents. Store code, metadata, and agent context—then search instantly with [WarpGrep](/sdk/components/warp-grep/index).

## [​](#quick-start) Quick Start

Use git like normal. Clone locally and search with WarpGrep—no indexing required.

```
import { MorphClient } from '@morphllm/morphsdk';

const morph = new MorphClient({ apiKey: "YOUR_API_KEY" });

// Initialize repo
await morph.git.init({
  repoId: 'my-project',
  dir: './my-project'
});

// Make changes, then commit
await morph.git.add({ dir: './my-project', filepath: '.' });
await morph.git.commit({
  dir: './my-project',
  message: 'Add feature',
  metadata: { issueId: 'PROJ-123', source: 'agent' }
});

// Push changes
await morph.git.push({ dir: './my-project', branch: 'main' });

// Search with WarpGrep - no indexing needed
const results = await morph.warpGrep.execute({
  query: 'Find authentication logic',
  repoRoot: './my-project'
});
```

## [​](#searching-your-code) Searching Your Code

**[WarpGrep](/sdk/components/warp-grep/index) is the recommended way to search your code.** It's 4x faster than traditional approaches and requires no indexing—just clone and search.

```
// Search with natural language
const results = await morph.warpGrep.execute({
  query: 'Where is JWT validation implemented?',
  repoRoot: './my-project'
});

if (results.success) {
  for (const ctx of results.contexts) {
    console.log(`${ctx.file}:`);
    console.log(ctx.content);
  }
}
```

## 4x Faster Search

Sub-second results with no embedding latency. Speed matters when humans are in the loop.

## No Indexing Required

Works instantly on any repo. Clone and search immediately.

## Better Long-Horizon Performance

Returns only relevant code, reducing context pollution across multi-step tasks.

## Natural Language Queries

Ask questions like "Find where billing invoices are generated" instead of regex patterns.

See [WarpGrep documentation](/sdk/components/warp-grep/index) for full usage.

## [​](#commit-metadata) Commit Metadata

Store arbitrary metadata with your commits:

```
await morph.git.commit({
  dir: './my-project',
  message: 'Fix authentication bug',
  metadata: {
    issueId: 'PROJ-456',
    source: 'ai-agent',
    model: 'claude-3.5-sonnet'
  }
});

// Retrieve later
const notes = await morph.git.getCommitMetadata({
  dir: './my-project',
  commitSha: 'abc123...'
});
```

## [​](#why-use-repo-storage) Why Use Repo Storage?

**Git-native** – Works with your existing Git workflow. Standard operations, familiar commands.
**AI-first design** – Store agent conversations and browser recordings alongside code changes.
**Instant search** – Clone locally and search with WarpGrep immediately. No indexing delays.
**Rich metadata** – Attach context to every commit for debugging and traceability.

## [​](#next-steps) Next Steps

[## WarpGrep

4x faster code search for agents](/sdk/components/warp-grep/index)[## Git Operations

Learn all Git commands and workflows](/sdk/components/repos/git-operations)[## Agent Metadata

Store chat history with commits](/sdk/components/repos/agent-metadata)
