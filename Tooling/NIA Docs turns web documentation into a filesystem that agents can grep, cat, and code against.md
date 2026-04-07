---
created: 2026-04-07
description: Turning docs into a mounted filesystem turns documentation browsing into terminal-native agent workflows with familiar commands and fresher API context.
source: https://x.com/arlanr/status/2041215978957389908?s=46&t=8UEDdjU125-5vvrJZwBA9A
type: framework
---

## Key Takeaways

The claim is that a file-oriented interface can outperform embedding-based retrieval for code agents when correctness depends on cross-page context, version drift, and exact signatures. This aligns with the broader shift in our own notes toward `grep`/`find`-style primitives and full-file tooling for agent navigation over fragmented retrieval pipelines. [[agentic search with grep and full-file loading replaces RAG when context windows are large enough]] captures that same point from a workflow perspective.

The tweet frames this as an anti-hallucination strategy: if a model’s training snapshot is stale, grounding every call in live docs mounted as files can reduce brittle, outdated tool usage. The idea complements `filesystem context engineering` as a durable harness pattern where the agent reads, inspects, and acts on text through stable command-like interfaces instead of many custom tool schemas. [[agentic doc toolchain with filesystem context engineering|LangChain argues that filesystems provide a single interface for agents]] connects the same thesis.

A practical insight is that command surface area itself is leverage: by forcing documentation access through a small set of shell-like operations, teams can cut orchestration overhead and context tax from schema-heavy tool calls. That is the same production concern we track as the trade-off between MCP breadth and durable runtime ergonomics. [[CLIs are the agent-native interface because legacy tooling is already machine-readable|CLIs are the agent-native interface because legacy tooling is already machine-readable]] is the cleanest companion principle for deciding when this pattern outperforms heavy API wrappers.

## External Resources

- [NIA Docs announcement on X: turning the web into a filesystem](https://x.com/arlanr/status/2041215978957389908?s=46&t=8UEDdjU125-5vvrJZwBA9A) — primary source describing why and how a docs-as-filesystem design improves agent reliability.
- [agentsearch.sh (docs shell)](https://www.agentsearch.sh/) — project endpoint referenced as the public-facing implementation.
- [NIA docs package on npm (`npx nia-docs`)](https://docs.trynia.ai) — target command surface for indexing and mounting documentation as filesystem trees.

## Original Content

> @arlanr — 2026-04-06
>
> Article: Turning the entire web into a filesystem.
>
> Code hallucinations are not a model problem. They're a data problem.
>
> Every day, APIs ship breaking changes, deprecate endpoints, and rename  parameters. Models can’t keep up because their training data is months,  sometimes years behind. So your agent writes code that looks perfect,  compiles clean, and fails at runtime because the library moved on six  months ago.
>
> The standard fix is RAG: chunk the docs, embed them, retrieve the top-K  fragments that match. This gets you 80% of the way, until the answer  lives across three pages, or the agent needs exact function signatures  that didn’t survive the chunking process. Retrieval gives you fragments,  but agents need the whole picture.
>
> We wanted something different. What if an agent could just read the docs? Not retrieve chunks, but actually browse them. The same way you’d grep through a codebase or cat a README.
>
> The filesystem idea
>
> Unix figured this out fifty years ago. Devices, processes, sockets. All files. One interface. `open`, `read`, `write`, `close`. You didn't need to learn a new API for every resource. You learned files, and that knowledge applied everywhere.
>
> Agents were pre-trained on Unix. Billions of tokens of filesystem interactions are baked into the weights. `tree`, `grep`, `find`. These aren't tools agents learn to use. They're tools agents already know. Every coding model has seen millions of examples of `cat README.md` and `grep -r "auth" .` and `find . -name "*.md"`.
>
> Compare that to MCP. Every tool needs a JSON schema, a natural-language description, and careful argument construction. Each one eats context window space and introduces a surface for misuse. A filesystem needs none of that.
>
> @jerryjliu0 put it well: an agent with filesystem tools and a code interpreter is just as general, if not more general, than an agent with 100+ MCP tools.
>
> So we asked: what if every documentation site on the web was a directory you could `cd` into?
>
> Try it: https://www.agentsearch.sh/
>
> ```bash
> npx nia-docs https://docs.trynia.ai
> ```
>
> Or set it up for your agent:
>
> ```bash
> npx nia-docs setup https://docs.trynia.ai | claude
> ```
>
> Works with Claude Code, Cursor, Copilot, Codex, OpenCode. Anything that reads an instructions file or supports skills.
>
> How it works
>
> ```bash
> $ npx nia-docs https://docs.trynia.ai
> ```
>
> That's the whole interface. No API keys, no install, no config. One command gives you a bash shell where any documentation is mounted as a filesystem. `tree` it. `grep` it. `cat` individual pages. Pipe it into your agent.
>
> Under the hood, three things happen.
>
> 1. Index
>
> When you hit a URL for the first time, the backend crawls the site. It respects `llms.txt`, detects OpenAPI specs, handles redirects. Each page becomes a file. The URL `https://docs.stripe.com/api/charges/create` becomes `/api/charges/create.md`.
>
> The tricky part is path normalization. Documentation sites have wildly inconsistent URL structures. Some put everything under `/docs/`, some under `/api/reference/`, some just use the root. We auto-detect the common path prefix across all indexed URLs and strip it, so the filesystem isn't three levels deep before you reach actual content.
>
> ```python
> def detect_common_path_prefix(urls, base_url):
>     # Split all paths into segments, find shared prefix
>     path_segments = [p.split('/') for p in paths]
>     common_prefix = []
>     for i in range(min(len(segs) for segs in path_segments)):
>         segments_at_i = [segs[i] for segs in path_segments]
>         if len(set(segments_at_i)) == 1:
>             common_prefix.append(segments_at_i[0])
>         else:
>             break
>     return '/' + '/'.join(common_prefix)
> ```
>
> The result: `https://better-auth.com/docs/installation` becomes `/installation.md`, not `/docs/installation.md`. The filesystem mirrors how you think about the documentation, not how the URL happens to be structured.
>
> 2. Serve
>
> The backend exposes filesystem operations as API endpoints:
>
> ```shell
> GET  /shell-docs/load?url=...              # status + full dump
> GET  /shell-docs/{namespace}/read?path=... # single file
> POST /shell-docs/{namespace}/grep          # regex search
> GET  /shell-docs/{namespace}/ls?path=...   # directory listing
> GET  /shell-docs/{namespace}/tree          # full tree
> GET  /shell-docs/{namespace}/find?pattern= # glob matching
> ```
>
> Everything is gzip-compressed. The `/load` endpoint returns status and all files in a single request. One round trip to boot a shell session. Responses are cached (`Cache-Control: public, max-age=300`), and the CLI maintains a disk cache at `~/.cache/nia-docs/` keyed by namespace and `indexed_at` timestamp. Second visit to the same docs? Instant.
>
> Namespaces are shared. When someone indexes `docs.stripe.com`, it's stored under `shelldocs-{canonical_id}` and available to everyone. The entire thing is unauthenticated by design. These are public docs.
>
> 3. Shell
>
> The shell itself runs on the client. No container, no sandbox, no VM. We use [just-bash](https://github.com/nicolo-ribaudo/just-bash), a TypeScript reimplementation of bash with support for grep, cat, ls, find, cd, tree, pipes, and aliases. The entire filesystem is an in-memory JavaScript object.
>
> ```typescript
> const bash = new Bash({
>   files: initialFiles,    // { "/stripe.com/docs/api/charges.md": "..." }
>   cwd: `/${domain}/docs`,
>   env: buildCommonEnv(domain),
>   executionLimits: EXECUTION_LIMITS,
> });
> ```
>
> All files are loaded upfront and mounted into the virtual filesystem. Commands execute in-process. A grep -r "webhook" . over 500 documentation pages completes in milliseconds because it’s just string matching in memory. For large sites (1,000+ pages), we load the file tree upfront and fetch content lazily on cat, cached for the session.
>
> Why not a real sandbox?
>
> - Boot time: ~100ms (cached), ~2s (already indexed), ~30-120s (cold index of a new site)
>
> - Per-session compute: zero on the server. Files come from Postgres, commands run on the client
>
> - No orchestration or warm pools
>
> The obvious alternative is to give the agent an actual filesystem. Spin up a container, clone the docs into it, let the agent loose. It’s correct and it works. But it’s slow and expensive  for what is fundamentally a read-only workload over static text.
>
> A documentation shell doesn’t need process isolation, writable storage, or a kernel. It needs string matching over a known set of  files. Running that inside a micro-VM is like renting a warehouse to  store a bookshelf.
>
> We went the other way: the shell runs entirely on the client as an in-process TypeScript bash interpreter. The backend is a dumb file server. No containers to boot and no sessions to manage.
>
> Agents already know this
>
> The setup for an agent is one line:
>
> ```bash
> npx nia-docs setup https://docs.example.com | claude
>
> codex "$(npx nia-docs setup https://docs.example.com)"
>
> npx nia-docs agents https://docs.example.com >> AGENTS.md
>
> opencode --prompt "$(npx nia-docs setup https://docs.example.com)"
>
> gemini "$(npx nia-docs setup https://docs.example.com)"
>
> copilot -i "$(npx nia-docs setup https://docs.example.com)"
> ```
>
> This appends a few lines to the agent's instruction file:
>
> ```markdown
> ## Stripe Docs
>
> Before working on a Stripe feature, check the docs via `npx nia-docs https://docs.stripe.com`.
>
>     # Search for a topic
>     npx nia-docs https://docs.stripe.com -c "grep -rl 'webhook' ."
>
>     # Read a specific page
>     npx nia-docs https://docs.stripe.com -c "cat getting-started.md"
> ```
>
> The agent picks it up. When it needs to check how something works, it  runs the command, gets the actual current documentation, and writes code against that. Not against whatever was in the training data.
>
> The -c flag executes a single command and exits. The agent never enters an interactive session. It runs grep, gets the result, reads the relevant file, moves on. Standard tool-use loop. The filesystem is just the interface.
>
> Starting with docs
>
> We’re starting with documentation because it’s where hallucinations hurt most and the data problem is most tractable. Documentation sites are public, structured, and relatively small (most are under 1,000 pages). They change frequently enough that training data is always  stale, but slowly enough that a 5-day cache TTL keeps things current.
>
> But the idea is bigger than docs. An API reference is a directory. A changelog is a file. An OpenAPI spec is already JSON you can cat. We auto-detect and index OpenAPI specs alongside the documentation. They show up under /api-spec/ in the filesystem.
>
> The entire web should be navigable the same way a codebase is. We’re  building the infrastructure to make that real, starting with the part that matters most to agents right now.
>
> What we're measuring
>
> Every command the agent runs in a shell session is logged (opt-out via NIA_DOCS_TELEMETRY=off): the command name, whether it succeeded, how long it took, what files matched a grep. Not the content, just the patterns. We want to understand how agents actually navigate documentation so we can make the  filesystem better.
>
> Early data shows agents converge on a consistent workflow: tree to orient, grep -rl to find relevant files, cat to read them. Exactly what a human developer would do. The filesystem abstraction isn’t something agents need to learn. It’s something they default to when given the option.
>
> The web is big. But every doc site, every API reference, every changelog. It all becomes a directory you can cd into.
>
> ---
>
> Arlan Rakhmetzhanov is the CEO of [Nozomio Labs](https://nozomio.com), building search and indexing infrastructure for AI agents at [Nia](https://trynia.ai).
> date: Mon Apr 06 18:06:27 +0000 2026
> url: https://x.com/arlanr/status/2041215978957389908
> likes: 249  retweets: 24  replies: 18
>
> [Original post](https://x.com/arlanr/status/2041215978957389908)
