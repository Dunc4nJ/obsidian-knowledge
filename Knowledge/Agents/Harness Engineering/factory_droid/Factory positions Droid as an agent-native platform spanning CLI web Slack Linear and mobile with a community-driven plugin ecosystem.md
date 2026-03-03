---
created: 2026-03-02
description: "Factory's open GitHub repo reveals Droid as a multi-surface agent-native development platform with CLI, VS Code, Slack/Teams, Linear/Jira, and mobile interfaces, plus an emerging community ecosystem of MCP integrations and proxy workflows."
source: https://github.com/Factory-AI/factory
---

## Key Takeaways

Factory frames itself as an "agent-native development platform" — not just a coding agent but a platform play spanning every surface developers already use: CLI, web, Slack/Teams, Linear/Jira, and mobile. This multi-surface strategy is distinct from competitors like [[Factory Code Droid combines multi-model sampling and codebase-aware retrieval to achieve state-of-the-art SWE-bench performance|Droid's technical architecture]] which focuses on model-level innovation. The platform wrapping is the product moat.

Droid claims top performance on terminal benchmarks, consistent with [[Factory Droid achieves state-of-the-art on Terminal-Bench through agent design not model choice|their Terminal-Bench results]]. The repo itself is thin — just a README and community-builds file — suggesting the core platform is closed-source with this repo serving as the public community hub and documentation gateway.

The community builds section reveals an interesting pattern: users are building proxy layers (CLIProxyAPI) to route Factory CLI through Claude Code Max and ChatGPT Codex subscriptions. This suggests Factory's own model routing may be expensive or limited, and the community is finding arbitrage. The [[Factory Droid plugins bundle skills commands hooks and MCP servers into distributable packages with marketplace-based discovery|plugin system]] is getting community-built MCP integrations (factory-mcp) for doc search.

The [[Factory droid exec uses tiered autonomy levels to gate agent permissions from read-only to full system access|tiered autonomy model]] and [[Factory droid-action wraps agent execution into a GitHub Actions contract with structured inputs MCP tools and STRIDE security skills|GitHub Actions integration]] complete the picture of a platform designed for enterprise adoption with governance controls at every layer.

## External Resources

- [Factory Website](https://factory.ai) — main product site
- [Documentation](https://docs.factory.ai) — full platform docs
- [CLI Quickstart](https://docs.factory.ai/cli/getting-started/quickstart) — getting started guide
- [VS Code Extension](https://marketplace.visualstudio.com/items?itemName=Factory.factory-vscode-extension) — editor integration
- [CLI Overview](https://docs.factory.ai/cli/getting-started/overview) — CLI architecture docs
- [GitHub Discussions](https://github.com/Factory-AI/factory/discussions) — community forum
- [factory-mcp](https://github.com/iannuttall/factory-mcp) — community MCP integration for Factory docs
- [here-now](https://github.com/fredrivett/here-now) — community build: minimal webpage hit counter
- [CLIProxyAPI guide (Codex/Claude)](https://gist.github.com/chandika/c4b64c5b8f5e29f6112021d46c159fdd) — running Factory CLI against Claude Code Max or ChatGPT Codex
- [CLIProxyAPI guide (Claude)](https://gist.github.com/ben-vargas/9f1a14ac5f78d10eba56be437b7c76e5) — Factory CLI with Claude Code Max via CLIProxyAPI
- [GrayPane](https://github.com/punitarani/flights-tracker) — community build: flight search and alerts

## Original Content

> [!quote]- Source Material

### Factory README (from GitHub)

# Factory

The agent-native development platform. Works across CLI, Web, Slack/Teams, Linear/Jira and Mobile.

Our agent, Droid, is top performing in terminal benchmarks.

*Droid ASCII art logo*
![[droid_ascii.gif]]

**The agent-native development platform built for shipping software faster.**

## Getting Started

- [CLI Quickstart](https://docs.factory.ai/cli/getting-started/quickstart)
- [VS Code Extension](https://marketplace.visualstudio.com/items?itemName=Factory.factory-vscode-extension)

## Quick Links

- [Factory Website](https://factory.ai)
- [Documentation](https://docs.factory.ai)
- [CLI Overview](https://docs.factory.ai/cli/getting-started/overview)
- [Community Builds](https://github.com/Factory-AI/factory/blob/main/community-builds.md)

## Community & Contributions

- Join the community on [GitHub Discussions](https://github.com/Factory-AI/factory/discussions)
- Share your workflows by opening a PR against [`community-builds.md`](https://github.com/Factory-AI/factory/blob/main/community-builds.md)
- Bug/issue/feature request? [Open an issue](https://github.com/Factory-AI/factory/issues) or send a pull request

## Community Builds

- [here-now](https://github.com/fredrivett/here-now) - Minimal webpage hit counter — show how many people are here/now by [fredrivett](https://github.com/fredrivett)
- [factory-mcp](https://github.com/iannuttall/factory-mcp) - Community-built Factory MCP integration to search our docs by [iannuttall](https://github.com/iannuttall)
- [Factory CLI with ChatGPT Codex / Claude subscription via CLIProxyAPI](https://gist.github.com/chandika/c4b64c5b8f5e29f6112021d46c159fdd) - Guide to run Factory CLI against Claude Code Max or ChatGPT Codex through CLIProxyAPI by [chandika](https://github.com/chandika)
- [Factory CLI with Claude subscription via CLIProxyAPI](https://gist.github.com/ben-vargas/9f1a14ac5f78d10eba56be437b7c76e5) - Setup instructions for using Factory CLI with Claude Code Max through CLIProxyAPI by [ben-vargas](https://github.com/ben-vargas)
- [GrayPane – Flight Search & Alerts](https://github.com/punitarani/flights-tracker) - Check available flights, monitor price trends, plan upcoming trips, and create personalized alerts by [Punit Arani](https://github.com/punitarani)

## License

Copyright © 2025 Factory AI. All rights reserved.

---

Source: https://github.com/Factory-AI/factory
