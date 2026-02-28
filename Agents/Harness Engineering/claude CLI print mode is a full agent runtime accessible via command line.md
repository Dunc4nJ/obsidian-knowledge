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

> [!quote]- Full Tweet Text
> @dhasandev (danialhasan) — 2026-01-09
>
> **Article: How to Wrap the Claude CLI for Your Agentic Apps**
>
> In today's article, I'll explain how to wrap the Claude CLI properly for your agentic apps.
>
> **Context**
>
> For those who don't know, you can no longer use your Claude subscription to use opencode and other third party apps. The reason for this can be found in their Agent SDK docs:
>
> > Unless previously approved, we do not allow third party developers to offer Claude.ai login or rate limits for their products, including agents built on the Claude Agent SDK. Please use the API key authentication methods described in this document instead.
>
> Many harnesses/orchestrators like @opencode and @clawdbot have been slammed with this error as a result:
>
> ```
> LLM request rejected: This credential is only authorized for use with
> Claude Code and cannot be used for other API requests.
> ```
>
> This means the oauth token generated in Claude Code via `/login` and `claude setup-token` no longer work outside of claude code. So, you have to pursue an alternative.
>
> **Wrapping the CLI**
>
> This all comes down to CC's "print" mode. It's run via `claude -p` or `claude --print` and it is a one-shot invocation of the CLI that takes a boatload of parameters.
>
> **The State Machine**
>
> Claude CLI's print mode can be thought of as a state machine with multiple dimensions:
>
> ![[dhasandev-555506-002.png]]
>
> **Gotchas:**
> - `--output-format stream-json` requires `--verbose` or you'll get an error.
> - `--input-format stream-json` requires `--output-format stream-json`. You can't mix stream input with text output.
>
> **Basic Usage Patterns**
>
> *Getting Data IN: Input Methods*
>
> There are 5 ways to feed a prompt into `claude -p`:
>
> 1. Command Line Argument (Most Common)
> ```bash
> claude -p "What is 2+2?"
> claude -p --model haiku "Explain recursion"
> ```
>
> 2. Stdin Pipe
> ```bash
> echo "What is 2+2?" | claude -p
> cat README.md | claude -p "Summarize this"
> git diff | claude -p "Review these changes"
> ```
>
> 3. Stdin Redirect
> ```bash
> claude -p < prompt.txt
> ```
>
> 4. Here-Doc
> ```bash
> claude -p <<EOF
> You are a code reviewer. Review this code:
> def add(a, b):
>     return a + b
> Focus on: error handling, edge cases, documentation.
> EOF
> ```
>
> 5. Stream-JSON Input
> ```bash
> echo '{"type":"user","message":{"role":"user","content":"Hello"}}' | \
>   claude -p --input-format stream-json --output-format stream-json --verbose
> ```
>
> *Getting Data OUT: Output Methods*
>
> 1. Text Output (Default) — human-readable plain text
> 2. JSON Output — structured response with full metadata (cost, usage, session_id)
> 3. Stream-JSON Output — real-time events, requires `--verbose`
>
> ![[dhasandev-555506-003.jpg]]
>
> *Structured Output with JSON Schema*
>
> ```bash
> echo "What is the capital of France?" | claude -p \
>   --model haiku \
>   --output-format json \
>   --json-schema '{"type":"object","properties":{"answer":{"type":"string"},"confidence":{"type":"number"}},"required":["answer"]}'
> ```
>
> Returns both `result` (text) and `structured_output` (typed JSON) fields.
>
> *Tool Configuration*
>
> - Disable all tools: `--tools ""`
> - Whitelist specific tools: `--tools "Bash,Read,Glob,Grep"`
> - Pattern-based allow: `--allowedTools "Bash(git:*)"`
> - Block destructive tools: `--disallowedTools "Write,Edit,Bash"`
>
> *Permission Modes*
>
> ![[dhasandev-555506-005.jpg]]
>
> `--permission-mode bypassPermissions` or `--dangerously-skip-permissions` for full autonomy.
>
> *Session Management*
>
> - Ephemeral: `--no-session-persistence`
> - Fixed session: `--session-id $UUID`
> - Continue most recent: `--continue`
>
> *Custom System Prompts*
>
> - Replace entirely: `--system-prompt "..."`
> - Append to default: `--append-system-prompt "..."`
>
> *Model Selection*
>
> - `--model haiku` (fast/cheap), `--model opus` (best quality), `--model sonnet` (balanced)
> - `--fallback-model haiku` for auto-fallback on overload
>
> ![[dhasandev-555506-006.jpg]]
>
> *Production Agentic Wrapper*
>
> ```bash
> result=$(echo "$TASK" | claude -p \
>   --model sonnet \
>   --fallback-model haiku \
>   --tools "Bash,Read,Write,Edit,Glob,Grep" \
>   --permission-mode bypassPermissions \
>   --no-session-persistence \
>   --output-format json \
>   --json-schema '{"type":"object","properties":{"success":{"type":"boolean"},"summary":{"type":"string"}},"required":["success","summary"]}')
> ```
>
> Engagement: 211 likes | 10 retweets | 6 replies
> [Original post](https://x.com/dhasandev/status/2009529865511555506)
