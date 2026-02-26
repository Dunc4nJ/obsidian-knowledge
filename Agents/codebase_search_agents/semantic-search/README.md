---
created: 2026-02-25
type: project-doc
description: "Semantic Search uses two-stage retrieval (vector search plus GPU reranking) to find code with natural language queries in about 1230ms."
---
# Semantic Search

Find code with natural language - ~1230ms, two-stage retrieval

Search code using natural language queries. Two-stage retrieval: vector search (fast, broad) + GPU reranking (precise).
![Semantic Search](https://mintcdn.com/morph-555d6c14/LrBmvnkYaQeUplbf/images/search.png?fit=max&auto=format&n=LrBmvnkYaQeUplbf&q=85&s=07f4bd1d477842ab4963860b2dba4623)

Push your code with `morph.git.push()` first (see [Repo Storage](/sdk/components/git)). Embedding takes 3-8 seconds in background.

## [​](#installation) Installation

```
npm install @morphllm/morphsdk
```

## [​](#quick-start) Quick Start

* MorphClient
* Anthropic
* OpenAI
* Vercel AI SDK

```
import { MorphClient } from '@morphllm/morphsdk';

const morph = new MorphClient({ apiKey: "YOUR_API_KEY" });

// Direct search
const results = await morph.codebaseSearch.search({
  query: "How does JWT validation work?",
  repoId: 'my-project', // will use latest main
  target_directories: [],
  limit: 10,
  // Optional: search specific branch or commit
  // branch: 'develop',
  // commitHash: 'abc123...'
});

console.log(`Found ${results.results.length} matches`);
```

```
import Anthropic from '@anthropic-ai/sdk';
import { MorphClient } from '@morphllm/morphsdk';

const morph = new MorphClient({ apiKey: "YOUR_API_KEY" });
const anthropic = new Anthropic();

// Tool inherits API key from MorphClient
const tool = morph.anthropic.createCodebaseSearchTool({
  repoId: 'my-project',
  // branch: 'develop',
  // commitHash: 'abc123...'
});

const response = await anthropic.messages.create({
  model: "claude-sonnet-4-5-20250929",
  tools: [tool],
  messages: [{
    role: "user",
    content: "Find the authentication code"
  }],
  max_tokens: 12000
});
```

```
import OpenAI from 'openai';
import { MorphClient } from '@morphllm/morphsdk';

const morph = new MorphClient({ apiKey: "YOUR_API_KEY" });
const openai = new OpenAI();

// Tool inherits API key from MorphClient
const tool = morph.openai.createCodebaseSearchTool({
  repoId: 'my-project',
  // branch: 'develop',
  // commitHash: 'abc123...'
});

const response = await openai.chat.completions.create({
  model: "gpt-4o",
  tools: [tool],
  messages: [{
    role: "user",
    content: "Find the authentication code"
  }]
});
```

```
import { generateText, stepCountIs } from 'ai';
import { anthropic } from '@ai-sdk/anthropic';
import { MorphClient } from '@morphllm/morphsdk';

const morph = new MorphClient({ apiKey: "YOUR_API_KEY" });

// Tool inherits API key from MorphClient
const tool = morph.vercel.createCodebaseSearchTool({
  repoId: 'my-project',
  // branch: 'develop',
  // commitHash: 'abc123...'
});

const result = await generateText({
  model: anthropic('claude-sonnet-4-5-20250929'),
  tools: { codebaseSearch: tool },
  prompt: "Figure out how to add 2FA to the authentication code",
  stopWhen: stepCountIs(5)
});
```

## [​](#how-it-works) How It Works

**Two-stage retrieval** (~1000ms total):

1. **Vector search** (~240ms) - Embed query, HNSW index retrieves top 50 candidates
2. **GPU rerank** (~630ms) - morph-rerank-v3 scores for precision
3. Returns top 10 most relevant

**Why two stages?** Vector search is fast but imprecise. Reranking is slow but accurate. Together = fast + accurate.

## [​](#direct-usage) Direct Usage

```
const results = await morph.codebaseSearch.search({
  query: "Where is JWT validation implemented?",
  repoId: 'my-project',
  target_directories: [], // Empty = all, or ["src/auth"]
  limit: 10,
  // Optional: search specific branch or commit
  // branch: 'develop',        // Uses latest commit on 'develop'
  // commitHash: 'abc123...'   // Uses exact commit (takes precedence)
});

console.log(`Found ${results.results.length} matches in ${results.stats.searchTimeMs}ms`);
results.results.forEach(r => {
  console.log(`${r.filepath} - ${(r.rerankScore * 100).toFixed(1)}% match`);
  console.log(r.content);
});
```

## [​](#search-tips) Search Tips

**Good queries**:

* "Where is JWT validation implemented?"
* "Show database error handling"
* "Find the login flow"

**Avoid**:

* Single words ("auth")
* Too vague ("code")
* Too broad ("everything")

## [​](#searching-specific-branches-or-commits) Searching Specific Branches or Commits

By default, semantic search uses the latest commit on `main`. You can search specific branches or exact commits:

* Latest Main (default)
* Specific Branch
* Exact Commit

```
// Searches latest commit on 'main' branch
const results = await morph.codebaseSearch.search({
  query: "How does auth work?",
  repoId: 'my-project'
});
```

```
// Searches latest commit on 'develop' branch
const results = await morph.codebaseSearch.search({
  query: "How does auth work?",
  repoId: 'my-project',
  branch: 'develop'
});
```

```
// Searches specific commit (e.g., for debugging)
const results = await morph.codebaseSearch.search({
  query: "How does auth work?",
  repoId: 'my-project',
  commitHash: 'abc123def456...'
});
```

**Priority**: `commitHash` (if provided) > `branch` (if provided) > `main` (default)

## [​](#api) API

**Input**:

```
{
  query: string,              // Natural language question
  repoId: string,             // Repository ID
  branch?: string,            // Optional: branch name (uses latest commit)
  commitHash?: string,        // Optional: specific commit (takes precedence)
  target_directories: string[], // Filter paths, or [] for all
  limit?: number              // Max results (default: 10)
}
```

**Returns**:

```
{
  success: boolean,
  results: [{
    filepath: string,         // "auth.ts::login@L5-L20"
    content: string,          // Code chunk
    rerankScore: number,      // 0-1 relevance (use this!)
    language: string,
    startLine: number,
    endLine: number
  }],
  stats: { searchTimeMs: number }
}
```
