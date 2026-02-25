# Agent Tool

Use Warp Grep as a tool in your AI agents

![Search code with Warp Grep](https://mintcdn.com/morph-555d6c14/73cl2rw3NdXBrKfL/images/breadth.jpeg?fit=max&auto=format&n=73cl2rw3NdXBrKfL&q=85&s=8f3c6f72fa610b86359c5fdd39e09f46)
WarpGrep is a **code search subagent**—a specialized AI model that searches your codebase and returns only relevant code. Instead of your main agent running grep and accumulating context, WarpGrep does intelligent multi-step searching in a separate context window and returns clean results.
**How it works:** Your agent calls WarpGrep with a natural language query. WarpGrep's model reasons about what to search, runs up to 24 tool calls (grep, read, list\_dir) across 4 turns in under 6 seconds, and returns the relevant code sections. Your main agent's context stays clean.
The SDK provides adapters for Anthropic, OpenAI, Google Gemini, and Vercel AI SDK.

## [​](#quick-start) Quick Start

* Anthropic
* OpenAI
* Gemini
* Vercel AI SDK
* MorphClient
* Custom Integration

```
import Anthropic from '@anthropic-ai/sdk';
import { MorphClient } from '@morphllm/morphsdk';

const morph = new MorphClient({ apiKey: "YOUR_API_KEY" });
const anthropic = new Anthropic();

// Tool inherits API key from MorphClient
const grepTool = morph.anthropic.createWarpGrepTool({ repoRoot: '.' });

const response = await anthropic.messages.create({
  model: 'claude-sonnet-4-5-20250929',
  max_tokens: 12000,
  tools: [grepTool],
  messages: [{ role: 'user', content: 'Find authentication middleware' }]
});

// Execute tool call
const toolUse = response.content.find(c => c.type === 'tool_use');
if (toolUse) {
  const result = await grepTool.execute(toolUse.input);
  console.log(grepTool.formatResult(result));
}
```

```
import OpenAI from 'openai';
import { MorphClient } from '@morphllm/morphsdk';

const morph = new MorphClient({ apiKey: "YOUR_API_KEY" });
const openai = new OpenAI();

// Tool inherits API key from MorphClient
const grepTool = morph.openai.createWarpGrepTool({ repoRoot: '.' });

const response = await openai.chat.completions.create({
  model: 'gpt-4o',
  tools: [grepTool],
  messages: [{ role: 'user', content: 'Find authentication middleware' }]
});

// Execute tool call
const toolCall = response.choices[0].message.tool_calls?.[0];
if (toolCall) {
  const result = await grepTool.execute(toolCall.function.arguments);
  console.log(grepTool.formatResult(result));
}
```

Gemini adapter requires `@google/generative-ai`:

```
npm install @google/generative-ai
```

```
import { GoogleGenerativeAI, FunctionCallingMode } from '@google/generative-ai';
import { createWarpGrepTool } from '@morphllm/morphsdk/tools/warp-grep/gemini';

const genAI = new GoogleGenerativeAI(process.env.GOOGLE_API_KEY);
const grepTool = createWarpGrepTool({
  repoRoot: '.',
  morphApiKey: "YOUR_API_KEY"
});

const model = genAI.getGenerativeModel({
  model: 'gemini-2.0-flash',
  tools: [{ functionDeclarations: [grepTool] }],
  toolConfig: { functionCallingConfig: { mode: FunctionCallingMode.AUTO } }
});

const chat = model.startChat();
const response = await chat.sendMessage('Find authentication middleware');

// Handle function call
const call = response.response.functionCalls()?.[0];
if (call) {
  const result = await grepTool.execute(call.args);

  // Send result back to model
  await chat.sendMessage([{
    functionResponse: {
      name: call.name,
      response: { result: grepTool.formatResult(result) }
    }
  }]);
}
```

```
import { generateText, stepCountIs } from 'ai';
import { anthropic } from '@ai-sdk/anthropic';
import { MorphClient } from '@morphllm/morphsdk';

const morph = new MorphClient({ apiKey: "YOUR_API_KEY" });

// Tool inherits API key from MorphClient
const grepTool = morph.vercel.createWarpGrepTool({ repoRoot: '.' });

const result = await generateText({
  model: anthropic('claude-sonnet-4-5-20250929'),
  tools: { grep: grepTool },
  prompt: 'Find authentication middleware',
  stopWhen: stepCountIs(5)
});
```

```
import { MorphClient } from '@morphllm/morphsdk';

const morph = new MorphClient({ apiKey: "YOUR_API_KEY" });

// Direct execution
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

Use the provider-agnostic Zod schema with your own tool abstraction layer:

```
import {
  warpGrepInputSchema,
  executeToolCall,
  WARP_GREP_TOOL_NAME,
  WARP_GREP_DESCRIPTION,
} from '@morphllm/morphsdk/tools/warp-grep';

// Use with your own tool definition abstraction
const toolDef = createToolDef({
  name: WARP_GREP_TOOL_NAME,
  description: WARP_GREP_DESCRIPTION,
  schema: warpGrepInputSchema,
});

// Execute
const result = await executeToolCall(
  { query: 'Find auth middleware' },
  { repoRoot: '.', morphApiKey: "YOUR_API_KEY" }
);
```

This pattern lets you:

* Use the same Zod schema across Anthropic, OpenAI, Gemini, and other providers
* Integrate with custom tool abstraction layers
* Maintain a single source of truth for tool definitions

## [​](#how-it-works) How It Works

You ask a natural language question about your codebase:

```
const result = await morph.warpGrep.execute({
  query: 'Find where billing invoices are generated and emailed',
  repoRoot: '.'
});
```

WarpGrep is a **subagent**—a specialized model that runs in its own context window. Here's what happens:

1. **Your agent** calls WarpGrep with a natural language query
2. **WarpGrep's model** receives the query + your repo's directory structure
3. **Multi-turn search** — The model reasons and executes up to 8 parallel tool calls per turn:
   * `grep` — ripgrep pattern matching
   * `read` — read specific file sections
   * `list_dir` — explore directories
4. **Refinement** — Based on results, it refines searches across up to 4 turns (24 total tool calls)
5. **Return** — Only the relevant code sections come back to your main agent

**Why a subagent?** When your main agent searches directly, grep results accumulate in its context. After several searches, irrelevant code crowds out important information and performance degrades. WarpGrep keeps your main agent's context clean.
See [benchmarks](https://morphllm.com/benchmarks) for performance data.

## [​](#direct-usage) Direct Usage

Use without an AI agent:

```
const result = await morph.warpGrep.execute({
  query: 'Find authentication middleware',
  repoRoot: '.',
  excludes: ['node_modules', '.git', 'dist']
});

console.log(result.success); // true
console.log(`Found ${result.contexts?.length} relevant sections`);
```

## [​](#remote-execution-sandbox-support) Remote Execution (Sandbox Support)

When your code lives in a remote sandbox (E2B, Modal, Daytona, Docker, SSH), use the `remoteCommands` option. You provide three simple functions that return raw stdout — the SDK handles all parsing.

* As Agent Tool
* MorphClient Direct

```
import { MorphClient } from '@morphllm/morphsdk';

const morph = new MorphClient({ apiKey: "YOUR_API_KEY" });

// Create tool with remoteCommands for use with LLMs
const grepTool = morph.anthropic.createWarpGrepTool({
  repoRoot: '/home/user/repo',
  remoteCommands: {
    grep: async (pattern, path, glob) => {
      const r = await sandbox.run(`rg --no-heading --line-number '${pattern}' '${path}'`);
      return r.stdout;
    },
    read: async (path, start, end) => {
      const r = await sandbox.run(`sed -n '${start},${end}p' '${path}'`);
      return r.stdout;
    },
    listDir: async (path, maxDepth) => {
      const r = await sandbox.run(`find '${path}' -maxdepth ${maxDepth}`);
      return r.stdout;
    },
  },
});

// Use with Anthropic, OpenAI, or Vercel AI SDK
const response = await anthropic.messages.create({
  model: 'claude-sonnet-4-5-20250929',
  tools: [grepTool],
  messages: [{ role: 'user', content: 'Find auth middleware' }]
});
```

```
import { MorphClient } from '@morphllm/morphsdk';

const morph = new MorphClient({ apiKey: "YOUR_API_KEY" });

// Direct execution with remoteCommands
const result = await morph.warpGrep.execute({
  query: 'Find authentication middleware',
  repoRoot: '/home/user/repo',
  remoteCommands: {
    grep: async (pattern, path, glob) => {
      const r = await sandbox.run(`rg --no-heading --line-number '${pattern}' '${path}'`);
      return r.stdout;
    },
    read: async (path, start, end) => {
      const r = await sandbox.run(`sed -n '${start},${end}p' '${path}'`);
      return r.stdout;
    },
    listDir: async (path, maxDepth) => {
      const r = await sandbox.run(`find '${path}' -maxdepth ${maxDepth}`);
      return r.stdout;
    },
  },
});

if (result.success) {
  for (const ctx of result.contexts) {
    console.log(`File: ${ctx.file}`);
    console.log(ctx.content);
  }
}
```

The SDK parses the raw output for you:

* `grep` → expects ripgrep format (`path:line:content`)
* `read` → expects raw file content (SDK adds line numbers)
* `listDir` → expects one path per line (from `find` command)

### [​](#platform-examples) Platform Examples

* E2B
* Modal
* Daytona
* Docker/SSH

```
import { Sandbox } from "@e2b/code-interpreter";
import { MorphClient } from '@morphllm/morphsdk';

const morph = new MorphClient({ apiKey: "YOUR_API_KEY" });
const sandbox = await Sandbox.create();
const repoDir = "/home/user/repo";

// Clone repo and install ripgrep
await sandbox.commands.run(`git clone --depth 1 https://github.com/example/repo ${repoDir}`);
await sandbox.commands.run("apt-get update && apt-get install -y ripgrep");

const grepTool = morph.anthropic.createWarpGrepTool({
  repoRoot: repoDir,
  remoteCommands: {
    grep: async (pattern, path) => {
      const r = await sandbox.commands.run(
        `rg --no-heading --line-number '${pattern}' '${path}'`,
        { cwd: repoDir }
      );
      return r.stdout || '';
    },
    read: async (path, start, end) => {
      const r = await sandbox.commands.run(`sed -n '${start},${end}p' '${path}'`);
      return r.stdout || '';
    },
    listDir: async (path, maxDepth) => {
      const r = await sandbox.commands.run(
        `find '${path}' -maxdepth ${maxDepth} -not -path '*/node_modules/*'`
      );
      return r.stdout || '';
    },
  },
});

// Use with Anthropic
const response = await anthropic.messages.create({
  model: 'claude-sonnet-4-5-20250929',
  tools: [grepTool],
  messages: [{ role: 'user', content: 'Find authentication middleware' }]
});
```

```
import { ModalClient } from "modal";
import { MorphClient } from '@morphllm/morphsdk';

const morph = new MorphClient({ apiKey: "YOUR_API_KEY" });
const modal = new ModalClient();
const sandbox = await modal.sandboxes.create(app, image);
const repoDir = "/home/repo";

const grepTool = morph.openai.createWarpGrepTool({
  repoRoot: repoDir,
  remoteCommands: {
    grep: async (pattern, path) => {
      const proc = await sandbox.exec([
        "rg", "--no-heading", "--line-number", pattern, path
      ]);
      return await proc.stdout.readText();
    },
    read: async (path, start, end) => {
      const proc = await sandbox.exec(["sed", "-n", `${start},${end}p`, path]);
      return await proc.stdout.readText();
    },
    listDir: async (path, maxDepth) => {
      const proc = await sandbox.exec([
        "find", path, "-maxdepth", String(maxDepth)
      ]);
      return await proc.stdout.readText();
    },
  },
});

// Use with OpenAI
const response = await openai.chat.completions.create({
  model: 'gpt-4o',
  tools: [grepTool],
  messages: [{ role: 'user', content: 'Find authentication middleware' }]
});
```

```
import { Daytona } from "@daytonaio/sdk";
import { MorphClient } from '@morphllm/morphsdk';

const morph = new MorphClient({ apiKey: "YOUR_API_KEY" });
const daytona = new Daytona({ apiKey: process.env.DAYTONA_API_KEY });
const sandbox = await daytona.create({ language: 'python' });
const repoDir = "/home/daytona/repo";

const grepTool = morph.vercel.createWarpGrepTool({
  repoRoot: repoDir,
  remoteCommands: {
    grep: async (pattern, path) => {
      const r = await sandbox.process.executeCommand(
        `rg --no-heading --line-number '${pattern}' '${path}'`,
        repoDir
      );
      return r.result || '';
    },
    read: async (path, start, end) => {
      const r = await sandbox.process.executeCommand(
        `sed -n '${start},${end}p' '${path}'`,
        repoDir
      );
      return r.result || '';
    },
    listDir: async (path, maxDepth) => {
      const r = await sandbox.process.executeCommand(
        `find '${path}' -maxdepth ${maxDepth}`,
        repoDir
      );
      return r.result || '';
    },
  },
});

// Use with Vercel AI SDK
const result = await generateText({
  model: anthropic('claude-sonnet-4-5-20250929'),
  tools: { grep: grepTool },
  prompt: 'Find authentication middleware'
});
```

```
import { NodeSSH } from 'node-ssh';
import { MorphClient } from '@morphllm/morphsdk';

const morph = new MorphClient({ apiKey: "YOUR_API_KEY" });
const ssh = new NodeSSH();
await ssh.connect({ host: 'your-server.com', username: 'user', privateKey: '...' });

const repoDir = "/home/user/repo";

const grepTool = morph.anthropic.createWarpGrepTool({
  repoRoot: repoDir,
  remoteCommands: {
    grep: async (pattern, path) => {
      const result = await ssh.execCommand(
        `rg --no-heading --line-number '${pattern}' '${path}'`,
        { cwd: repoDir }
      );
      return result.stdout || '';
    },
    read: async (path, start, end) => {
      const result = await ssh.execCommand(`sed -n '${start},${end}p' '${path}'`);
      return result.stdout || '';
    },
    listDir: async (path, maxDepth) => {
      const result = await ssh.execCommand(`find '${path}' -maxdepth ${maxDepth}`);
      return result.stdout || '';
    },
  },
});

// Use with Anthropic
const response = await anthropic.messages.create({
  model: 'claude-sonnet-4-5-20250929',
  tools: [grepTool],
  messages: [{ role: 'user', content: 'Find authentication middleware' }]
});
```

Your sandbox needs `ripgrep` (`rg`) installed for the grep function. Most sandbox providers support installing it via `apt-get install ripgrep`.

## [​](#configuration) Configuration

```
import { MorphClient } from '@morphllm/morphsdk';

const morph = new MorphClient({ apiKey: "YOUR_API_KEY" });

const grepTool = morph.openai.createWarpGrepTool({
  repoRoot: '.',
  excludes: ['node_modules', '.git', 'dist'],  // Glob patterns to exclude
  includes: ['src/**/*.ts'],                    // Glob patterns to include
  name: 'code_search',                          // Custom tool name
  description: 'Search for code patterns'       // Custom description
});
```

| Option | Default | Description |
| --- | --- | --- |
| `repoRoot` | (required) | Root directory of the repository to search |
| `excludes` | `['node_modules', '.git']` | Glob patterns to exclude from search |
| `includes` | (all files) | Glob patterns to include in search |
| `name` | `warpgrep_codebase_search` | Tool name exposed to the LLM |
| `description` | (see SDK) | Tool description for the LLM |
| `remoteCommands` | (local) | Functions for remote sandbox execution |
| `morphApiUrl` | `https://api.morphllm.com` | Override API base URL for proxies |
| `timeout` | `30000` | Timeout for model calls in ms (also configurable via `MORPH_WARP_GREP_TIMEOUT` env var) |

## [​](#api) API

* execute (direct)
* Tool Methods

**Input** (`WarpGrepInput`):

```
{
  query: string,            // Natural language search query
  repoRoot: string,         // Root directory to search
  excludes?: string[],      // Glob patterns to exclude
  includes?: string[],      // Glob patterns to include
  remoteCommands?: {        // For sandbox environments
    grep: (pattern, path, glob?) => Promise<string>,
    read: (path, start, end) => Promise<string>,
    listDir: (path, maxDepth) => Promise<string>,
  },
}
```

**Returns** (`WarpGrepResult`):

```
{
  success: boolean,
  contexts?: Array<{
    file: string,     // File path relative to repo root
    content: string,  // Relevant code section
  }>,
  summary?: string,   // Summary of findings
  error?: string,     // Error message if failed
}
```

When using as an agent tool, additional methods are available:

```
// Execute the tool with LLM input
const result = await grepTool.execute(toolInput);

// Format result for LLM response
const formatted = grepTool.formatResult(result);

// Get system prompt for the agent
const systemPrompt = grepTool.getSystemPrompt();
```

### [​](#handling-results) Handling Results

```
const result = await morph.warpGrep.execute({
  query: 'Find auth middleware',
  repoRoot: '.'
});

if (result.success) {
  console.log(`Found ${result.contexts.length} relevant sections`);

  for (const ctx of result.contexts) {
    console.log(`\n--- ${ctx.file} ---`);
    console.log(ctx.content);
  }
} else {
  console.error(`Search failed: ${result.error}`);
}
```

### [​](#type-exports) Type Exports

```
import {
  warpGrepInputSchema,
  executeToolCall,
  WARP_GREP_TOOL_NAME,
  WARP_GREP_DESCRIPTION,
} from '@morphllm/morphsdk/tools/warp-grep';

import type {
  WarpGrepResult,
  WarpGrepContext,
  WarpGrepInput,
  WarpGrepToolConfig,
  WarpGrepInputSchema,
  RemoteCommands,
} from '@morphllm/morphsdk';
```

## [​](#error-handling) Error Handling

```
const result = await morph.warpGrep.execute({
  query: 'Find auth',
  repoRoot: '.'
});

if (!result.success) {
  console.error(result.error);
  // "Search did not complete" | "API error" | etc.
}
```
