---
created: 2026-02-26
description: Karpathy argues that CLIs are the ideal agent interface because they are composable legacy tech that AI agents can install, combine, and build on top of natively
source: https://x.com/karpathy/status/2026360908398862478
type: learning
---

## Key Takeaways

The core insight is counterintuitive: CLIs are exciting precisely because they are "legacy" technology. AI agents can natively interact with them via the terminal — install packages, pipe outputs, combine tools, and build pipelines without any special integration layer. This makes CLI-first products immediately agent-accessible in a way that GUI-only products are not. The [[agent-first engineering replaces coding with environment design scaffolding and feedback loops|agent-first engineering]] paradigm naturally favors composable text interfaces over visual ones.

The practical demonstration is powerful: Karpathy asked Claude to install a new Polymarket CLI (built in Rust by @SuhailKakar), then had it build a terminal dashboard showing highest-volume markets with 24hr price changes — in about 3 minutes. No API wrangling, no SDK setup. Just `install CLI → agent reads docs → agent builds thing`. This connects to what we know about [[content systems beat content calendars when assets are modular tagged and agent-operable|agent-operable systems]] — modularity and machine-readability are the multiplier.

The checklist for product builders in 2026 is direct: Can agents access your product? Specifically — are your docs exportable as markdown? Have you written Skills for your product? Is it usable via CLI or MCP? This aligns with [[MCP best practices]] — the trend is toward every product having a machine-readable surface. "Build for agents" isn't a slogan, it's a competitive requirement.

The compounding effect matters: CLI tools become modules in bigger pipelines. A Polymarket CLI combined with a GitHub CLI means an agent can cross-reference prediction market data with repo activity, issues, and discussions. The value isn't in any single tool — it's in the combinatorial explosion of what agents can wire together when everything speaks text over stdin/stdout.

## External Resources

- [Polymarket CLI by @SuhailKakar](https://x.com/SuhailKakar/status/2026305257257775524) — Rust-based CLI for querying markets, placing trades, and pulling data from Polymarket via terminal
- [GitHub CLI](https://cli.github.com) — navigate repos, issues, PRs, discussions, and code from the terminal

## Original Content

*Karpathy's terminal dashboard built by Claude in ~3 minutes using the Polymarket CLI*
![[karpathy-862478-001.jpg]]

> @karpathy — 2026-02-24
>
> CLIs are super exciting precisely because they are a "legacy" technology, which means AI agents can natively and easily use them, combine them, interact with them via the entire terminal toolkit.
>
> E.g ask your Claude/Codex agent to install this new Polymarket CLI and ask for any arbitrary dashboards or interfaces or logic. The agents will build it for you. Install the Github CLI too and you can ask them to navigate the repo, see issues, PRs, discussions, even the code itself.
>
> Example: Claude built this terminal dashboard in ~3 minutes, of the highest volume polymarkets and the 24hr change. Or you can make it a web app or whatever you want. Even more powerful when you use it as a module of bigger pipelines.
>
> If you have any kind of product or service think: can agents access and use them?
>
> - are your legacy docs (for humans) at least exportable in markdown?
> - have you written Skills for your product?
> - can your product/service be usable via CLI? Or MCP?
>
> It's 2026. Build. For. Agents.
>
> Engagement: 11,092 likes | 1,047 retweets | 591 replies
> [Original post](https://x.com/karpathy/status/2026360908398862478)

> @SuhailKakar — 2026-02-24
>
> introducing polymarket cli - the fastest way for ai agents to access prediction markets. built with rust. your agent can query markets, place trades, and pull data - all from the terminal. fast, lightweight, no overhead.
>
> Engagement: 5,916 likes | 345 retweets | 314 replies
> [Original post](https://x.com/SuhailKakar/status/2026305257257775524)
