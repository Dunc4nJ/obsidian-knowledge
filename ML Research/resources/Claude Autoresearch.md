---
created: 2026-03-18
source: https://github.com/uditgoenka/autoresearch
type: resource
tags: [ml-research, autoresearch, autonomous-agents, claude-code]
status: unread
---

## What it is

A Claude Code skill that generalizes Karpathy's autoresearch pattern into a domain-agnostic autonomous improvement loop. Set a goal with a mechanical metric, and Claude iterates forever — making one atomic change per iteration, verifying against the metric, keeping improvements and auto-reverting failures.

## Why it's interesting

Extends autoresearch beyond ML training into any domain with a measurable metric (code quality, bundle size, test coverage, marketing, sales). Ships as a Claude Code skill with multiple commands (`/autoresearch`, `/autoresearch:plan`, `/autoresearch:security`, `/autoresearch:debug`, `/autoresearch:fix`) rather than requiring external bash harnesses.

## How it works

**Setup phase**: Claude reads all in-scope files, extracts or asks for a mechanical metric, defines which files are modifiable vs read-only, and establishes a baseline (iteration #0).

**Loop phase**: Each iteration follows 8 rules — read context + git history before writing, make one focused change, git commit, run mechanical verification, keep if improved or `git revert` if worse, log to TSV. Git serves as memory: experiments are committed with `experiment:` prefix, and the agent reads `git log` + `git diff` before each iteration to build on prior attempts.

**Guard system**: Optional safety net commands that must pass for changes to be kept, on top of the primary metric gate.

## Key links

- [GitHub](https://github.com/uditgoenka/autoresearch)
- [Guide](https://github.com/uditgoenka/autoresearch/blob/master/GUIDE.md)
- [Examples](https://github.com/uditgoenka/autoresearch/blob/master/EXAMPLES.md)
- [Karpathy's autoresearch (upstream inspiration)](https://github.com/karpathy/autoresearch)

## Notes

- Built by @iuditg, directly inspired by Karpathy's 630-line autoresearch script
- Interesting contrast to [[autoresearch loops cheat when guardrails are loose but converge on real findings when tightly scoped|the Chieng/Sero findings]] — this skill bakes in the "one change per iteration" + strict gate pattern they found essential
