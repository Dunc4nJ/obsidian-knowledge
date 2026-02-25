# Custom Providers

Implement custom file system providers

Most users should use `remoteCommands` instead (see [Agent Tool](/sdk/components/warp-grep/tool#remote-execution-sandbox-support)). Only implement `WarpGrepProvider` if you need custom caching, batching, or output formatting.

## [​](#provider-interface) Provider Interface

```
import type { WarpGrepProvider } from '@morphllm/morphsdk';

interface WarpGrepProvider {
  grep: (args: {
    pattern: string;
    path: string;
    glob?: string;
  }) => Promise<{ lines: string[]; error?: string }>;

  read: (args: {
    path: string;
    start?: number;
    end?: number;
  }) => Promise<{ lines: string[]; error?: string }>;

  listDirectory: (args: {
    path: string;
    maxDepth?: number;
  }) => Promise<Array<{
    name: string;
    path: string;
    type: 'file' | 'directory';
    depth: number;
  }>>;
}
```

## [​](#output-formats) Output Formats

**grep** - ripgrep-style output:

```
{ lines: [
  'src/auth/login.ts:45:export function authenticate(user: User) {',
  'src/auth/login.ts-46-  return validateCredentials(user);',
]}
// Match lines use `:`, context lines use `-`
```

**read** - numbered lines:

```
{ lines: [
  '1|import { User } from "./types";',
  '2|import { hash } from "./crypto";',
]}
// Format: lineNumber|content
```

**listDirectory** - structured entries:

```
[
  { name: 'auth', path: 'src/auth', type: 'directory', depth: 1 },
  { name: 'login.ts', path: 'src/auth/login.ts', type: 'file', depth: 2 },
]
```

## [​](#usage) Usage

```
import { MorphClient } from '@morphllm/morphsdk';
import type { WarpGrepProvider } from '@morphllm/morphsdk';

const provider: WarpGrepProvider = {
  grep: async ({ pattern, path, glob }) => {
    const results = await myCustomGrep(pattern, path, glob);
    return { lines: results };
  },
  read: async ({ path, start, end }) => {
    const content = await myCustomRead(path, start, end);
    return { lines: content.split('\n').map((l, i) => `${(start || 1) + i}|${l}`) };
  },
  listDirectory: async ({ path, maxDepth }) => {
    return await myCustomListDir(path, maxDepth);
  },
};

const morph = new MorphClient({ apiKey: process.env.MORPH_API_KEY });
const result = await morph.warpGrep.execute({
  query: 'Find auth middleware',
  repoRoot: '/path/to/repo',
  provider,
});
```

## [​](#with-streaming) With Streaming

Custom providers work with streaming:

```
const stream = morph.warpGrep.execute({
  query: 'Find auth middleware',
  repoRoot: '/path/to/repo',
  provider: myCustomProvider,
  streamSteps: true,
});

for await (const step of stream) {
  console.log(`Turn ${step.turn}:`, step.toolCalls);
}
```
