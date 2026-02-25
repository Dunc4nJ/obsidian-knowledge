# Streaming

Stream Warp Grep progress in real-time

Show users what Warp Grep is doing as it searches. Pass `streamSteps: true` to get an async generator that yields each turn's tool calls before execution.

## [​](#basic-usage) Basic Usage

```
import { MorphClient } from '@morphllm/morphsdk';

const morph = new MorphClient({ apiKey: process.env.MORPH_API_KEY });

const stream = morph.warpGrep.execute({
  query: 'Find authentication middleware',
  repoRoot: '.',
  streamSteps: true
});

for await (const step of stream) {
  console.log(`Turn ${step.turn}:`, step.toolCalls);
}
// Note: The final WarpGrepResult is returned when the generator completes
```

To capture the final result:

```
const stream = morph.warpGrep.execute({
  query: 'Find auth middleware',
  repoRoot: '.',
  streamSteps: true
});

let result;
for (;;) {
  const { value, done } = await stream.next();
  if (done) {
    result = value; // WarpGrepResult
    break;
  }
  console.log(`Turn ${value.turn}:`, value.toolCalls);
}

console.log('Found:', result.contexts?.length, 'files');
```

## [​](#step-format) Step Format

Each yielded step contains the turn number and tool calls made:

```
type WarpGrepStep = {
  turn: number;  // 1-4
  toolCalls: Array<{
    name: string;       // "grep" | "read" | "list_directory" | "finish"
    arguments: Record<string, unknown>;
  }>;
};
```

Example output:

```
// Turn 1
{ turn: 1, toolCalls: [
  { name: "grep", arguments: { pattern: "auth", path: "src/" } },
  { name: "list_directory", arguments: { path: "src/auth" } }
]}

// Turn 2
{ turn: 2, toolCalls: [
  { name: "read", arguments: { path: "src/auth/middleware.ts", start: 1, end: 50 } }
]}

// Turn 3 (finish)
{ turn: 3, toolCalls: [
  { name: "finish", arguments: { files: [...] } }
]}
```

## [​](#type-imports) Type Imports

```
import { MorphClient } from '@morphllm/morphsdk';
import type { WarpGrepStep, WarpGrepResult } from '@morphllm/morphsdk';
```

## [​](#return-type) Return Type

```
// streamSteps: true
AsyncGenerator<WarpGrepStep, WarpGrepResult, undefined>

// streamSteps: false (default)
Promise<WarpGrepResult>
```
