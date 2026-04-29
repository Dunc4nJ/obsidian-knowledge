---
created: 2026-04-29
description: Dhravya Shah launches Supermemory Filesystem (SMFS), a Rust-based mountable filesystem that makes grep semantic by default and exposes vector search through standard Unix tooling, claiming 83% token reduction on Codex retrieval benchmarks.
source: https://x.com/DhravyaShah/status/2049324612635562492
type: learning
---

## Key Takeaways

The core observation is that [[ColBERT-style semantic search beats grep 70 percent of the time for coding agents while using fewer tokens|agentic search on filesystems]] works beautifully for codebases — filenames are signposts, function names are designed to be searchable, the whole tree was organized by humans (or agents) who knew an agent would walk it. But your notes folder is not a codebase. Drop a thousand PDFs, meeting transcripts, and design docs in there and the paradigm collapses. The agent greps for "OAuth refresh failure" and misses the doc that calls it "token rotation issue" — the same identifier-mismatch problem [[ColBERT-style semantic search beats grep 70 percent of the time for coding agents while using fewer tokens|ColGREP attacks at the model level]], here attacked at the filesystem level.

The UX move is the interesting one: same surface, semantic underneath. `grep` without flags issues a vector query scoped to your current path. `grep -F` stays literal. Same muscle memory, no new tool calls for agents to learn. Results land back on real paths the agent can `cat` or re-grep with narrower scope. This sidesteps the [[context agents should navigate heterogeneous sources natively instead of flattening everything into vector search|"agents shouldn't have to learn a separate retrieval API"]] problem by making the filesystem itself the retrieval API. The index and the file tree, both — agent picks whichever it needs.

Auto-extraction kills the *user-built* preprocessing pipeline. Drop PDFs, video, audio, screenshots straight into the mount and `grep "action items" ~/smfs/` returns hits across `contract.pdf`, `standup.mp4` (with `[02:14]` timestamps), `screenshot.png` (literally tagged `[OCR]` in the output), `handbook.docx` (with `§4` section anchor), and `interview.m4a` (with `[8:02]` timestamp) in one call. Worth being precise about what's actually happening here: Dhravya's announcement says "No OCR. No transcription. No PDF parser. No chunking" — but the example output proves all four are running. The honest reading is *"you don't build the pipeline; we operate one for you."* SMFS runs OCR, speech-to-text, PDF parsing, and docx structure extraction server-side on ingest, then surfaces hits through grep with source tags. That's a meaningfully different value prop from "no extraction needed" — file contents flow to Supermemory's cloud for processing, with the usual latency, cost, and privacy tradeoffs that implies. The thread doesn't disclose which OCR engine, which speech-to-text model, where extraction runs, or what extraction quality looks like across formats.

`profile.md` is a synthesized-on-read view of the underlying memory graph — never stored, always fresh. The agent's first useful action in a new directory is usually a read; SMFS makes that read free by deriving a live digest of every memory in the container. If a fact updates in the supermemory graph, the profile reflects it on the next `cat`. This is a [[context graphs let agents build verifiable, cross-agent memory instead of isolated notes|graph-backed memory]] surfaced through filesystem semantics rather than a separate query API.

Multi-agent shared state via mountable container — Agent A writes a memory, Agent B sees it on the next pull. The folder is the shared state, always synced with supermemory cloud. Local SQLite cache means operations are instant; sync drains incrementally. This is the [[every app that avoids a database ends up rebuilding one badly|"there's always a database underneath"]] pattern, but the database is hidden behind filesystem semantics so agents never have to know it exists.

Benchmark claims (treat as vendor-reported): on 20 real retrieval tasks, **Codex went from 1.2M → 203K tokens (-83%)** with answers found 19/20 times; **Claude went from 116 → 42 tool calls (-64%), tokens -36%, accuracy 16/20 → 18/20**. Internal claim: ">50% improvement over agentic search" on their own benchmarks, with a larger report forthcoming on smfs.ai. The pattern matches [[searching more and thinking less improves agentic efficiency and generalization|brute-force grep burning tokens]] — agents stop walking the tree speculatively when the first query lands closer to the answer.

Implementation: one Rust binary, open source. FUSE on Linux, NFSv3 on macOS via a pure-Rust localhost server (no kernel extensions, no macFUSE, no security prompts — shows up in Finder). Works with Daytona, E2B, Cloudflare Workers, Vercel sandboxes. Local-first sync — reads never block on the network, writes commit to local SQLite and drain to Supermemory in the background with exponential backoff. Survives restarts. Offline reads keep working. There's also a virtual-bash SDK exposing the same Unix surface as a single tool call for serverless edge runtimes that have no kernel.

This sits in tension with [[a file system is not all you need - databases beat markdown for agent context provenance and governance|"a file system is not all you need"]] but only superficially — SMFS keeps filesystem *semantics* on top of a SQLite + graph backing store, which is exactly the "database underneath" answer to that critique. The filesystem is the agent-facing interface; the durability and provenance live in the cloud graph. It's also a counterpoint to [[hierarchical tree navigation can replace vector embeddings for RAG retrieval|tree navigation as RAG replacement]] — SMFS keeps both the tree and the embeddings, exposing them through a unified grep.

## External Resources

- [Announcement thread](https://x.com/DhravyaShah/status/2049324612635562492) — full launch thread
- [smfs.ai](https://smfs.ai/) — landing page and demo
- [GitHub: supermemoryai/smfs](https://github.com/supermemoryai/smfs) — open-source repo
- Install: `curl -fsSL smfs.ai/install | sh` then `smfs mount my-project`

## Original Content

> [!quote]- Source Thread — @DhravyaShah, Apr 29 2026
>
> 📰 Introducing SMFS - RAG sucks and filesystems are broken. We fixed both with supermemory filesystems.
>
> Everyone and their mom is arguing about "RAG is dead" and "filesystems are awesome", without capturing the full nuance.
>
> > TLDR: We brought the best of RAG and filesystem into a mountable filesystem which replaces the UNIX operations and makes them better for agents. it's called Supermemory Filesystem (SMFS.ai)
> > github.com/supermemoryai/smfs
>
> RAG isn't dead. With better agents, managing embeddings and vector databases just became too much of a pain. MCP and grep seemed to make "fancy retrieval" unnecessary. Claude Code popularized agentic search - letting the agent walk a codebase with grep and find... and it worked! Very well!
>
> And yeah, agentic search on a filesystem is a simply beautiful paradigm. You throw in some files and let the agent look around.
>
> It works because codebases are special. Filenames mean what they say. Function names are designed to be searchable. The whole tree was organized by humans (or agents) who knew an agent would walk it later.
>
> Your notes folder is not a codebase. Drop a thousand PDFs, meeting transcripts, and design docs in there and watch it fall apart. Filenames stop being signposts. The agent greps for "OAuth refresh failure" and misses the doc that calls it "token rotation issue." It can't grep a diagram inside a PDF at all.
>
> So, you reach for RAG. Top-K returns chunks - relevant, severed from the files they came from - leading to subpar answers. What do you do now? You stitch together many systems, trying to make it better one step at a time.
>
> ## What if you didn't have to choose? Introducing SMFS: Supermemory Filesystem.
>
> We made a mountable filesystem that our agent can use to do semantic search while also just... dealing with files.
>
> Still simply beautiful, but with steroids.
>
> **1/ Semantic grep**
>
> What if grep itself was semantic? What if the agent didn't have to learn separate tool calls like "search vectors" etc.? Agents are already great at filesystems, so what if the filesystem ITSELF could be made for the agent?
>
> Same command, same line-oriented output, same muscle memory, but the matching function underneath is a vector query, scoped to the path you're standing in. Results land back on real paths. The agent cats the file. Lists the directory. Re-greps with a narrower scope.
>
> The index and the file tree. both. It can do whatever it needs to do.
>
> ```
> $ grep "oauth refresh failure" work/
> work/debug-notes.md:42:refresh token failed after deploy
> research-paper.pdf:118:the benchmark failed after token rotation
> ```
>
> Flagged `grep -F` stays literal. `grep` without flags is semantic. Same muscle memory. New reach.
>
> **2/ User profiles**
>
> `cat profile.md` returns a live digest of every memory in the container. Not stored - synthesized on read and always fresh. The agent's first useful action in a new directory is usually a read. We made that read free.
>
> We keep it fresh because the profile is actually derived from the graph. If a fact updates in the supermemory graph, it automatically updates in the profile.
>
> **3/ Sync engine**
>
> Multiple agents can mount the same container. Agent A writes a memory. Agent B sees it on the next pull. The folder is the shared state, always synced with supermemory cloud.
>
> This also means that the operations themselves are instant, in a local sqlite state, and can incrementally synchronize with the system.
>
> **4/ Auto extraction: Drop the file. We'll do the rest.**
>
> PDFs, videos, screenshots, audio, docs — drop the raw files straight into the mount. No OCR. No transcription. No PDF parser. No chunking. The pipeline you would have built is gone, and grep works across every format.
>
> ```
> $ grep "action items" ~/smfs/
> contract.pdf      ...follow-up action items due Friday
> standup.mp4       [02:14] action items from yesterday
> screenshot.png    [OCR] Action Items (whiteboard)
> handbook.docx     §4 tracking action items effectively
> interview.m4a     [8:02] emerging action items for Q1
> ```
>
> ## The numbers
>
> We ran 20 real retrieval tasks with Claude and Codex. Same agent, same documents, with and without SMFS:
>
> - Codex: 1.2M → 203K tokens (-83%). Answer found 19/20 times
> - Claude: 116 → 42 tool calls (-64%). Tokens -36%. Answer found 16/20 → 18/20 with smfs.
>
> Less context, more right answers, fewer turns. The agent stops walking the tree speculatively and starts asking the right question, directly.
>
> > We are working on a larger report which will be published soon on smfs.ai, it almost always beats agentic search by >50% in our internal benchmarks!
>
> ## A few details we sweated.
>
> One binary. Open source. Built with rust btw.
>
> No kernel extensions. FUSE on Linux. NFSv3 on macOS via a pure-Rust localhost server, mounted natively. No macFUSE. No kext. No security prompts. Shows up in Finder.
>
> Works with Daytona, E2B, Cloudflare, Vercel, and pretty much all sandboxes.
>
> Local-first sync. Reads never block on the network. Writes commit to a local SQLite cache and drain to Supermemory in the background with exponential backoff. Survives restarts. Offline reads keep working. Your edits don't get lost.
>
> Same surface, every runtime. Your laptop, an ephemeral sandbox, a serverless edge runtime with no kernel — there's a virtual-bash SDK that exposes the same Unix surface as a single tool the agent can call.
>
> ```bash
> $ curl -fsSL smfs.ai/install | sh
> $ smfs mount my-project
> # → grep away. we'll do the vectors.
> ```
>
> You get the index. You get the map.
>
> Just try it! or view our demo at [smfs.ai](https://smfs.ai/)
>
> And star the repo! github.com/supermemoryai/smfs
