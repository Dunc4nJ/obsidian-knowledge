---
created: 2025-02-28
description: A comprehensive guide to wrapping Claude CLI's print mode for agentic applications, covering input/output formats, permission modes, tool configuration, session management, structured output, and production wrapper patterns.
source: https://x.com/dhasandev/status/2009529865511555506
---

## Key Takeaways

The core insight is that `claude -p` (print mode) isn't just a convenience flag — it's a complete agent runtime exposed as a CLI primitive. This makes it the natural integration point for any harness that wants to use Claude Code's capabilities (tools, file access, session management) without building a custom SDK integration. This directly relates to [[harness engineering improved a coding agent 13 points by changing only system prompts tools and middleware|harness engineering]] — the wrapper around the model matters as much as the model itself.

*The state machine: `claude -p` branches into input-format and output-format, each with distinct modes*
![[dhasandev-555506-002.png]]

The article was written in response to Anthropic locking down Claude Code's oauth tokens to prevent third-party apps from piggybacking on subscriptions. Tools like OpenCode and OpenClaw got hit with "This credential is only authorized for use with Claude Code" errors. The workaround: wrap the CLI itself instead of using the token directly. This is a pragmatic solution but also reveals print mode's power as an interface.

*Input/output format compatibility matrix — stream-json input requires stream-json output*
![[dhasandev-555506-003.jpg]]

Five input methods (argument, stdin pipe, stdin redirect, here-doc, stream-json) combined with three output formats (text, json, stream-json) create a rich matrix of integration patterns. The key gotcha: `--output-format stream-json` requires `--verbose`, and stream-json input requires stream-json output — you can't mix formats across the boundary.

*Input method × output format use cases*
![[dhasandev-555506-004.jpg]]

Structured output via `--json-schema` is the killer feature for data extraction. The response includes a `structured_output` field separate from the text `result`, giving you type-safe outputs without parsing. Combined with `--tools` whitelisting (e.g., `--tools "Bash,Read,Glob,Grep"`) and `--allowedTools` pattern matching (e.g., `Bash(git:*)`), you get fine-grained control over what the agent can do — exactly the kind of [[designing agent tools is an iterative art shaped by model capabilities not fixed engineering rules|iterative tool design]] that makes harnesses effective.

*Permission modes — from prompting for everything to full autonomy*
![[dhasandev-555506-005.jpg]]

Session management via `--session-id` enables multi-turn conversations across separate CLI invocations, while `--no-session-persistence` gives stateless microservice behavior. Combined with `--continue` for following up on the most recent session, this covers the full spectrum from ephemeral one-shots to persistent agent loops.

*Quick reference: goal → command mapping*
![[dhasandev-555506-006.jpg]]

## External Resources

- [Gist with experiments and findings](https://gist.github.com/danialhasan/abbf1d7e721475717e5d07cee3244509) — from trysquad.ai's implementation
- [trysquad.ai](https://trysquad.ai/) — the author's agent verification/coordination platform
- [Claude Agent SDK docs](https://docs.anthropic.com/) — Anthropic's official SDK documentation

## Original Content

> [!quote]- Source Material
> 
> @dhasandev (danialhasan):
> Article: How to Wrap the Claude CLI for Your Agentic Apps
> 
> In today's article, I'll explain how to wrap the Claude CLI properly for your agentic apps.
> 
> # Context
> 
> For those who don't know, you can no longer use your Claude subscription to use opencode and other third party apps. The reason for this can be found in their Agent SDK docs:
> 
> > Unless previously approved, we do not allow third party developers to offer Claude.ai login or rate limits for their products, including agents built on the Claude Agent SDK. Please use the API key authentication methods described in this document instead.
> 
> Many harnesses/orchestrators like @opencode and @clawdbot have been slammed with this error as a result:
> 
> ```markdown
> LLM request rejected: This credential is only authorized for use with 
> Claude Code and cannot be used for other API requests.
> ```
> 
> This means the oauth token generated in Claude Code via `/login` and `claude setup-token` no longer work outside of claude code. So, you have to pursue an alternative.
> 
> # Wrapping the CLI
> 
> This all comes down to CC's "print" mode. It's run via `claude -p` or `claude --print` and it is a one-shot invocation of the CLI that takes a boatload of parameters. In this article, I'll outline the different flags you can use for various applications.
> 
> # The State Machine
> 
> Claude CLI's print mode can be thought of as a state machine with multiple dimensions:
> 
> ## Input/Output Format Matrix
> 
> ## Gotchas
> 
> - `--output-format stream-json` requires `--verbose` or you'll get an error.
> 
> - `--input-format stream-json` requires `--output-format stream-json`. You can't mix stream input with text output.
> 
> Before we get into it: This is all derived from our implementation at [trysquad.ai](https://trysquad.ai/), where we're developing robust agent verification and coordination techniques to enable engineers to scale up from 5 parallel claudes to 500. Sign up for the waitlist now for early access! Experiments and findings available at:
> 
> [https://gist.github.com/danialhasan/abbf1d7e721475717e5d07cee3244509](https://gist.github.com/danialhasan/abbf1d7e721475717e5d07cee3244509)
> 
> # Basic Usage Patterns
> 
> ## Getting Data IN: Input Methods
> 
> There are 5 ways to feed a prompt into `claude -p`:
> 
> 1. Command Line Argument (Most Common)
> 
> ```bash
> claude -p "What is 2+2?"
> claude -p --model haiku "Explain recursion"
> ```
> 
> 2. Stdin Pipe (Pipe content from another command:)
> 
> ```bash
> echo "What is 2+2?" | claude -p
> cat README.md | claude -p "Summarize this"
> git diff | claude -p "Review these changes"
> ```
> 
> 3. Stdin Redirect (Read from a file:)
> 
> ```bash
> claude -p < prompt.txt
> claude -p --model sonnet < complex_task.md
> ```
> 
> Here-Doc (Multi-line Prompts, perfect for complex prompts with formatting)
> 
> ```bash
> claude -p <<EOF
> You are a code reviewer. Review this code:
> 
> python
> def add(a, b):
>     return a + b
> 
> 
> Focus on: error handling, edge cases, documentation.
> EOF
> 
> ```
> 
> 5. Stream-JSON Input (Advanced, for programmatic, real-time input)
> 
> ```bash
> echo '{"type":"user","message":{"role":"user","content":"Hello"}}' | \
>   claude -p --input-format stream-json --output-format stream-json --verbose
> ```
> 
> Note: Stream input REQUIRES stream output (bidirectional only).
> 
> ## Combining Input Methods
> 
> You can combine argument + stdin for context + instruction:
> 
> ```bash
> # File content via stdin, instruction via argument
> cat code.py | claude -p "Find bugs in this code"
> 
> # Git diff via stdin, task via argument
> git diff HEAD~3 | claude -p "Write commit message for these changes"
> ```
> 
> # Getting Data OUT: Output Methods
> 
> There are 3 output formats controlled by `--output-format`:
> 
> 1. Text Output (Default, human-readable, plain text)
> 
> ```bash
> # To terminal
> claude -p "What is 2+2?"
> # Output: 4
> 
> # Capture to variable
> response=$(claude -p "What is 2+2?")
> echo "$response"  # 4
> 
> # Save to file
> claude -p "Write a haiku" > haiku.txt
> 
> # Pipe to another command
> claude -p "List 5 colors as JSON array" | jq '.'
> ```
> 
> 2. JSON Output
> 
> Structured response with full metadata:
> 
> ```bash
> claude -p --output-format json "What is 2+2?"
> ```
> 
> Returns:
> 
> ```json
> {
>   "type": "result",
>   "subtype": "success",
>   "is_error": false,
>   "duration_ms": 1336,
>   "duration_api_ms": 20400,
>   "num_turns": 1,
>   "result": "4",
>   "session_id": "uuid-here",
>   "total_cost_usd": 0.0427,
>   "usage": {
>     "input_tokens": 2,
>     "output_tokens": 5,
>     "cache_read_input_tokens": 15792
>   },
>   "modelUsage": {
>     "claude-haiku-4-5-20251001": {
>       "inputTokens": 5,
>       "outputTokens": 169,
>       "costUSD": 0.028
>     }
>   }
> }
> ```
> 
> Extract fields with jq:
> 
> ```bash
> # Get just the result
> claude -p --output-format json "What is 2+2?" | jq -r '.result'
> 
> # Get cost
> claude -p --output-format json "Hello" | jq '.total_cost_usd'
> 
> # Check for errors
> claude -p --output-format json "task" | jq '.is_error'
> ```
> 
> 3. Stream-JSON Output (Real-Time)
> 
> For live UI updates - requires `--verbose`:
> 
> ```bash
> claude -p --output-format stream-json --verbose "Write a poem"
> ```
> 
> Emits multiple JSON events (one per line):
> 
> ```json
> {"type":"system","subtype":"init","session_id":"...","tools":[...],"model":"..."}
> {"type":"stream_event","event":{"type":"content_block_delta","delta":{"text":"Roses"}}}
> {"type":"stream_event","event":{"type":"content_block_delta","delta":{"text":" are"}}}
> {"type":"stream_event","event":{"type":"content_block_delta","delta":{"text":" red"}}}
> {"type":"assistant","message":{...}}
> {"type":"result","subtype":"success","total_cost_usd":0.02,...}
> ```
> 
> Parse in real-time:
> 
> ```bash
> claude -p --output-format stream-json --verbose "Write a story" | \
>   while IFS= read -r line; do
>     text=$(echo "$line" | jq -r '.event.delta.text // empty' 2>/dev/null)
>     [ -n "$text" ] && printf "%s" "$text"
>   done
> ```
> 
> Or in Node.js:
> 
> ```javascript
> const readline = require('readline');
> 
> for await (const line of readline.createInterface({ input: process.stdin })) {
>   const event = JSON.parse(line);
>   if (event.type === 'stream_event' && event.event?.delta?.text) {
>     process.stdout.write(event.event.delta.text);
>   }
> }
> ```
> 
> ## Input/Output Combination Matrix
> 
> ## Structured Output with JSON Schema
> 
> This is the killer feature for data extraction apps:
> 
> ```bash
> echo "What is the capital of France?" | claude -p \
>   --model haiku \
>   --output-format json \
>   --json-schema '{"type":"object","properties":{"answer":{"type":"string"},"confidence":{"type":"number"}},"required":["answer"]}'
> ```
> 
> Key Discovery #3: The response includes a `structured_output` field separate from the text `result`:
> 
> ```json
> {
>   "result": "The capital of France is **Paris**.",
>   "structured_output": {
>     "answer": "Paris",
>     "confidence": 1.0
>   }
> }
> ```
> 
> This is perfect for:
> 
> - Data extraction pipelines
> 
> - Form filling automation
> 
> - API response formatting
> 
> - Type-safe agentic outputs
> 
> - Literally anything
> 
> ## Tool Configuration
> 
> You have quite a few options for tool configuration. By default it uses its native tools like Glob, Grep, Search, etc; but you can add custom tools,  remove all tools, or some combination of the two. You can get real granular with this.
> 
> Disable All Tools (Pure LLM)
> 
> For chat-only applications where you don't want file access or command execution:
> 
> ```bash
> echo "Hello" | claude -p --tools ""
> ```
> 
> Specific Tool Whitelist
> 
> Enable only the tools you need.
> 
> ```bash
> echo "List files" | claude -p --tools "Bash,Read,Glob,Grep"
> ```
> 
> Pattern-Based Allow/Deny
> 
> Fine-grained control with patterns:
> 
> ```bash
> # Only allow git commands
> claude -p --allowedTools "Bash(git:*)" "commit these changes"
> 
> # Block destructive tools
> claude -p --disallowedTools "Write,Edit,Bash" "analyze this code"
> ```
> 
> ## Permission Modes
> 
> This is critical for autonomous execution:
> 
> For CI/CD Pipelines
> 
> ```bash
> echo "$task" | claude -p \
>   --model sonnet \
>   --permission-mode bypassPermissions \
>   --tools "Bash,Read,Write,Edit" \
>   --output-format json
> ```
> 
> I'm supposed to put a warning here saying "be careful with bypassPermissions and only use it in a sandbox with no internet access!!" but honestly bro? Fuck it. Bypass the permissions; as long as you set the guardrails right Claude won't be able to do some crazy shit like delete your google drive. like antigravity did. Oh well!
> 
> There's also a convenience flag:
> 
> ```bash
> --dangerously-skip-permissions  # Equivalent to --permission-mode bypassPermissions
> 
> ```
> 
> ## Session Management
> 
> Ephemeral Sessions (No Disk Storage)
> 
> For stateless microservices:
> 
> ```bash
> echo "task" | claude -p --no-session-persistence
> ```
> 
> Fixed Session ID (Multi-Turn Conversations)
> 
> Maintain context across calls:
> 
> ```bash
> SESSION="11111111-1111-1111-1111-111111111111"
> 
> # Turn 1
> echo "My name is Alice" | claude -p --session-id $SESSION --output-format json
> 
> # Turn 2 (remembers context)
> echo "What's my name?" | claude -p --session-id $SESSION --continue
> 
> 
> ### Continue Most Recent
> 
> bash
> claude -p --continue "follow up question"
> ```
> 
> ## Custom System Prompts
> 
> Replace Entirely
> 
> ```bash
> echo "review this code" | claude -p \
>   --system-prompt "You are a senior code reviewer. Be concise and critical."
> ```
> 
> Append to Default (Recommended)
> 
> Preserves Claude Code's capabilities while adding custom behavior:
> 
> ```bash
> echo "help me" | claude -p \
>   --append-system-prompt "IMPORTANT: Always respond in bullet points."
> ```
> 
> ## Custom Agents
> 
> Define personas inline:
> 
> ```bash
> claude -p \
>   --agents '{"reviewer":{"description":"Code reviewer","prompt":"You are a strict code reviewer."}}' \
>   --agent reviewer \
>   "review this function"
> ```
> 
> ## Model Selection
> 
> Basic Model Choice
> 
> ```bash
> # Fast and cheap
> claude -p --model haiku "quick question"
> 
> # Best quality
> claude -p --model opus "complex task"
> 
> # Balanced
> claude -p --model sonnet "standard task"
> ```
> 
> Fallback for Reliability
> 
> Auto-fallback when primary model is overloaded:
> 
> ```bash
> claude -p --model sonnet --fallback-model haiku "important task"
> ```
> 
> ## Bidirectional Streaming (Advanced)
> 
> For real-time interactive applications:
> 
> ```bash
> echo '{"type":"user","message":{"role":"user","content":"Hello"}}' | \
>   claude -p \
>   --input-format stream-json \
>   --output-format stream-json \
>   --verbose \
>   --replay-user-messages
> ```
> 
> The `--replay-user-messages` flag echoes user messages back with `"isReplay": true` for acknowledgment tracking.
> 
> Input format:
> 
> ```json
> {"type":"user","message":{"role":"user","content":"Your message"}}
> ```
> 
> # Putting It All Together
> 
> Production Agentic Wrapper
> 
> ```bash
> 
> #!/bin/bash
> # agentic-claude.sh - Production wrapper for autonomous execution
> 
> TASK="$1"
> SESSION_ID="${2:-$(uuidgen)}"
> 
> result=$(echo "$TASK" | claude -p \
>   --model sonnet \
>   --fallback-model haiku \
>   --tools "Bash,Read,Write,Edit,Glob,Grep" \
>   --permission-mode bypassPermissions \
>   --no-session-persistence \
>   --output-format json \
>   --json-schema '{"type":"object","properties":{"success":{"type":"boolean"},"summary":{"type":"string"}},"required":["success","summary"]}')
> 
> # Extract structured output
> success=$(echo "$result" | jq -r '.structured_output.success')
> summary=$(echo "$result" | jq -r '.structured_output.summary')
> cost=$(echo "$result" | jq -r '.total_cost_usd')
> 
> echo "Task: $success"
> echo "Summary: $summary"
> echo "Cost: \$$cost"
> ```
> 
> Chatbot Wrapper
> 
> ```typescript
> import { execSync } from 'child_process';
> 
> interface ClaudeResult {
>   type: string;
>   subtype: string;
>   result: string;
>   total_cost_usd: number;
>   is_error: boolean;
> }
> 
> function chat(prompt: string, model = 'haiku'): ClaudeResult {
>   const result = execSync(
>     `claude -p --model ${model} --output-format json`,
>     { input: prompt, encoding: 'utf-8' }
>   );
>   return JSON.parse(result);
> }
> 
> const response = chat('What is the meaning of life?');
> console.log(response.result);
> console.log(`Cost: $${response.total_cost_usd.toFixed(4)}`);
> ```
> 
> Data Extraction Pipeline
> 
> ```typescript
> import { execSync } from 'child_process';
> 
> interface ExtractedData {
>   entities: string[];
>   sentiment: 'positive' | 'negative' | 'neutral';
>   summary: string;
> }
> 
> interface ClaudeResult {
>   result: string;
>   structured_output?: ExtractedData;
> }
> 
> const SCHEMA = JSON.stringify({
>   type: 'object',
>   properties: {
>     entities: { type: 'array', items: { type: 'string' } },
>     sentiment: { enum: ['positive', 'negative', 'neutral'] },
>     summary: { type: 'string' }
>   },
>   required: ['entities', 'sentiment', 'summary']
> });
> 
> function extract(text: string): ExtractedData | undefined {
>   const result = execSync(
>     `claude -p --model haiku --output-format json --json-schema '${SCHEMA}'`,
>     { input: `Extract entities, sentiment, and summary from: ${text}`, encoding: 'utf-8' }
>   );
>   const data: ClaudeResult = JSON.parse(result);
>   return data.structured_output;
> }
> 
> const info = extract('I love this new iPhone! Apple really outdid themselves.');
> console.log(info); // { entities: ['iPhone', 'Apple'], sentiment: 'positive', ... }
> ```
> 
> ## Quick Reference
> 
> ## Gotchas
> 
> 1. Stream-json requires --verbose - Won't work without it
> 
> 2. Stream input requires stream output - Can't mix formats
> 
> 3. MCP tools load regardless - Use `--strict-mcp-config` to disable
> 
> 4. bypassPermissions must be used responsibly - set your guardrails!
> 
> 5. JSON schema output is separate - Look for `structured_output` field
> 
> 6. Context caching reduces cost - First run is expensive, subsequent runs cheaper as long as you don't blow up the KV cache at the start using a dynamic timestamp or something.
> 
> ---
> 
> The Claude CLI's print mode is a powerful primitive for building agentic applications. By understanding the state machine of input/output formats, permission modes, and tool configurations, you can build everything from simple chatbots to fully autonomous coding agents.
> 
> The key insight is that `claude -p` isn't just a CLI wrapper - it's a full-featured agent runtime that happens to be accessible via command line. Use it wisely.
> 
> ---
> 
> This is all derived from our implementation at trysquad.ai, where we're developing robust agent verification and coordination techniques to enable engineers to scale up from 5 parallel claudes to 500. Sign up for the waitlist now for early access!
> 
> Experiments and findings available at: https://gist.github.com/danialhasan/abbf1d7e721475717e5d07cee3244509
> 
> Claude Code version: 2.1.2 | Tested: 2026-01-08
> date: Fri Jan 09 07:37:09 +0000 2026
> url: https://x.com/dhasandev/status/2009529865511555506
> ──────────────────────────────────────────────────
> 
> @local0ptimist (kenneth):
> @dhasandev LFG
> date: Fri Jan 09 17:49:56 +0000 2026
> url: https://x.com/local0ptimist/status/2009684077243494632
> ──────────────────────────────────────────────────
> 
> @JoeHtoo2 (Joe Htoo):
> @dhasandev This is cool thanks for sharing
> date: Fri Jan 09 20:57:45 +0000 2026
> url: https://x.com/JoeHtoo2/status/2009731340296401086
> ──────────────────────────────────────────────────
> 
> @dhasandev (danialhasan):
> @JoeHtoo2 thank you! would love to see what you implement with this, skies the limit
> date: Fri Jan 09 21:00:05 +0000 2026
> url: https://x.com/dhasandev/status/2009731930192064970
> ──────────────────────────────────────────────────
> 
> @rayzhudev (Ray Zhu🐨):
> @dhasandev I built an SDK for this very purpose because I think the future is local apps wrapping AI agents
> >  QT @rayzhudev:
> > CLAUDE CODE WRAPPERS ARE THE NEW CHATGPT WRAPPERS.
> > 
> > Introducing AgentConnect – the all in one SDK to integrate Claude Code and ChatGPT Codex with any vibecoded app you create. 
> > Say goodbye to paying for every AI SaaS you use, now you can use your Claude code subscription to power...
> > VIDEO: https://pbs.twimg.com/amplify_video_thumb/2009470262065156100/img/mHoBZneOij3xlEtI.jpg
> >  https://x.com/rayzhudev/status/2009473202398101779
> date: Fri Jan 09 21:53:57 +0000 2026
> url: https://x.com/rayzhudev/status/2009745486786564098
> ──────────────────────────────────────────────────
> 
> @dhasandev (danialhasan):
> @rayzhudev This looks really cool bro, what was the last thing you wrapped?
> date: Sat Jan 10 00:29:46 +0000 2026
> url: https://x.com/dhasandev/status/2009784696507691456
> ──────────────────────────────────────────────────
> 
> @aroussi (Ran Aroussi):
> @dhasandev Took your idea and turned it into an app:
> https://t.co/GM4fnd2VTe
> >  QT @aroussi:
> > Anthropic disabled pro and max plans for 3rd-party harness, so, naturally, I asked Claude to hack itself.
> > 
> > Introducing CC-Bridge: an Anthropic API compatible service that's using the official Claude CLI under the hood (original idea by @dhasandev).
> > 
> >  https://x.com/aroussi/status/2009810971771195759
> date: Sat Jan 10 02:15:27 +0000 2026
> url: https://x.com/aroussi/status/2009811292559925420
> ──────────────────────────────────────────────────
> 
> @dhasandev (danialhasan):
> @aroussi Brooo this is insane
> date: Sat Jan 10 02:34:09 +0000 2026
> url: https://x.com/dhasandev/status/2009816000125149221
> ──────────────────────────────────────────────────
> 
> @sachinadlakha18 (Sachin Adlakha):
> @dhasandev I am going to try this out, need this solution real bad. 
> 
> Does it work for you all without any issues ? Does it have an overhead to maintain it as the updates for claude code come in ?
> date: Wed Feb 18 05:34:56 +0000 2026
> url: https://x.com/sachinadlakha18/status/2023994619818578068
> ──────────────────────────────────────────────────
> 
> @dhasandev (danialhasan):
> @sachinadlakha18 yeah it works fine; its linked your claude code so as claude gets updated, this gets updated too
> date: Fri Feb 27 18:23:09 +0000 2026
> url: https://x.com/dhasandev/status/2027449441502777732
> ──────────────────────────────────────────────────
> 
> @SavarSareen (Savar):
> @dhasandev But then can you have memory? With one shot -print I’ve not found it much more useful than api calls
> date: Sat Feb 28 01:03:12 +0000 2026
> url: https://x.com/SavarSareen/status/2027550117457498465
> ──────────────────────────────────────────────────
> 
> @dhasandev (danialhasan):
> @SavarSareen you can attach session id for persistence; its ephemeral by default but you can attach persistence
> date: Sat Feb 28 01:06:14 +0000 2026
> url: https://x.com/dhasandev/status/2027550879600284051
> ──────────────────────────────────────────────────
> 
> @glipsman (Graham Lipsman):
> @dhasandev You could do all that or you could just use the Agent SDK as god intended
> date: Sat Feb 28 09:12:26 +0000 2026
> url: https://x.com/glipsman/status/2027673238197903694
> ──────────────────────────────────────────────────
> 
> @1zahlmann (Johann Zahlmann):
> @dhasandev Nice for starting out building with agents programmatically but you will realize that claude -p is way too slow once you use a good agent sdk
> date: Sat Feb 28 12:00:35 +0000 2026
> url: https://x.com/1zahlmann/status/2027715554010620311
> ──────────────────────────────────────────────────
> 
> @dhasandev (danialhasan):
> @1zahlmann ya honestly the startup times aint too bad
> date: Sat Feb 28 15:31:29 +0000 2026
> url: https://x.com/dhasandev/status/2027768625159962909
> ──────────────────────────────────────────────────
> 
> @dhasandev (danialhasan):
> @glipsman oauth subscriptions are better
> date: Sat Feb 28 15:31:40 +0000 2026
> url: https://x.com/dhasandev/status/2027768673142751713
> ──────────────────────────────────────────────────
