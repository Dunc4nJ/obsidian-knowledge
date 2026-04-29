---
created: 2026-04-29
description: Dhravya Shah launches Supermemory Filesystem (SMFS), a Rust-based mountable filesystem that makes grep semantic by default. Source-dive reveals it's a client for Supermemory's closed extraction-and-embedding cloud — sidecar transcription files materialize next to binaries, and a zsh wrapper redirects flagless grep through POST /v4/search.
source: https://x.com/DhravyaShah/status/2049324612635562492
type: learning
---

## Key Takeaways

The core observation is that [[ColBERT-style semantic search beats grep 70 percent of the time for coding agents while using fewer tokens|agentic search on filesystems]] works beautifully for codebases — filenames are signposts, function names are designed to be searchable, the whole tree was organized by humans (or agents) who knew an agent would walk it. But your notes folder is not a codebase. Drop a thousand PDFs, meeting transcripts, and design docs in there and the paradigm collapses. The agent greps for "OAuth refresh failure" and misses the doc that calls it "token rotation issue" — the same identifier-mismatch problem [[ColBERT-style semantic search beats grep 70 percent of the time for coding agents while using fewer tokens|ColGREP attacks at the model level]], here attacked at the filesystem level.

The UX move is the interesting one: same surface, semantic underneath. `grep` without flags issues a vector query scoped to your current path. `grep -F` stays literal. Same muscle memory, no new tool calls for agents to learn. Results land back on real paths the agent can `cat` or re-grep with narrower scope. This sidesteps the [[context agents should navigate heterogeneous sources natively instead of flattening everything into vector search|"agents shouldn't have to learn a separate retrieval API"]] problem by making the filesystem itself the retrieval API. The index and the file tree, both — agent picks whichever it needs.

## What's actually in the open-source repo (the OSS is a client, not the engine)

After cloning [`supermemoryai/smfs`](https://github.com/supermemoryai/smfs) and reading the source, the architecture is sharper and more honest than the announcement suggests. The repo is **the client side only**: mount, sync, SQLite cache, sidecar materialization, and a shell wrapper. All extraction, embedding, ranking, and "memory graph" intelligence runs server-side at `api.supermemory.ai`. Without an API key, the binary does nothing useful.

**The pipeline is real and explicit in the code.** From `crates/smfs-core/src/sync/push.rs:57`:

> *"The Supermemory server accepts POST and PATCH synchronously but processes them asynchronously (extracting → chunking → embedding → indexing → done). Issuing a second PATCH while the doc is still processing silently drops the new content."*

Documents move through `queued → processing → done | failed` server-side. So "No OCR. No transcription. No PDF parser. No chunking" means *you* don't run them — Supermemory does, on every binary you upload. The client recognizes 23+ MIME types (png/jpg/webp/gif/bmp/svg, pdf, mp3/wav/m4a/aac/flac/ogg/aiff, mp4/mov/webm, csv, html, xml, json, doc/docx, xls/xlsx, ppt/pptx) and ships them to the server as multipart uploads.

**The clever bit: extraction results materialize as visible sidecar files.** When a binary doc reaches `status=done`, the local SQLite reconcile loop synthesizes a read-only sibling next to the raw file (`crates/smfs-core/src/cache/fs.rs:519`):

| Source file       | Sidecar sibling                       |
|-------------------|---------------------------------------|
| `cat.png`         | `cat.png.image-transcription.md`      |
| `notes.pdf`       | `notes.pdf.pdf-transcription.md`      |
| `standup.mp4`     | `standup.mp4.video-transcription.md`  |
| `interview.m4a`   | `interview.m4a.audio-transcription.md` |
| `<webpage.html>`  | `<webpage.html>.webpage-transcription.md` |
| Failed extraction | `<file>.smfs-error.txt` with diagnostic |

These appear in `ls`, can be `cat`'d directly, are read-only (mode `0o444`), get cascade-renamed/deleted with the parent, and are how `grep` actually finds content inside binaries. The "no chunking" line is also true on the client surface but false underneath — `cache/fs.rs:565` rewrites file content as fixed-size SQLite chunks for the local cache. Different layer, same word.

**`profile.md` is a virtual file, not a real one.** Its inode is hardcoded to `u64::MAX - 1` and read calls hit `POST /v4/profile` then cache the response (`cache/profile.rs`). The "synthesized on read, always fresh" claim is closer to "fetched once on mount, refreshed by the daemon" — there's a `warm()` call and an `RwLock<Option<Vec<u8>>>` cache. The server returns `static` and `dynamic` memory lists which the client formats into markdown.

**"Semantic grep" is a zsh shell-function wrapper, not a syscall hook.** `smfs init` appends a function to `~/.zshrc` (`crates/smfs/src/cmd/init.rs:9`) that wraps `grep`. The wrapper walks up from `$PWD` (and from path arguments) looking for a `.smfs` marker file; if found and *no flags* are passed, it shells out to `smfs grep` instead of the real `grep`. Any flag — even `-r` — falls through to the real binary. There's no detection of bash or fish setups in the repo. After running `smfs init` you must `source ~/.zshrc` for it to take effect.

**The "grep-shaped" output is reconstructed client-side.** `smfs grep` calls `POST /v4/search` (`crates/smfs-core/src/api/dto.rs:149`) which returns chunks with similarity scores and filepaths. The client then re-finds each chunk in the local file (or its sidecar transcription) to compute line numbers, with a whitespace-normalized fallback for fuzzy matches. So "results land back on real paths" works because the client locally re-grounds server-side semantic hits into `path:line:content` format that mimics ripgrep output. It's vendor server-side semantic search wrapped in grep cosplay, but the cosplay is faithful — agents get back exactly the format they expect.

## Auto-extraction, in detail (the original section, now corrected)

Dhravya's announcement says *"No OCR. No transcription. No PDF parser. No chunking — the pipeline you would have built is gone."* That's a UX truth and an architectural fiction. The client doesn't run the pipeline; the server does, and the example output proves it: `screenshot.png` is tagged `[OCR]` and `standup.mp4` carries `[02:14]` timestamps. The honest reading is *"you don't build the pipeline; we operate one for you, and we materialize its output as `.image-transcription.md` / `.pdf-transcription.md` / `.video-transcription.md` / `.audio-transcription.md` files next to your originals."* File contents flow to Supermemory's cloud for processing, with the usual latency/cost/privacy tradeoffs that implies. Neither announcement nor repo discloses which OCR engine, which speech-to-text model, or what extraction quality looks like across formats — the engine is closed-source.

`profile.md` surfaces a [[context graphs let agents build verifiable, cross-agent memory instead of isolated notes|graph-backed memory]] through filesystem semantics rather than a separate query API. Multi-agent shared state happens via the mountable container — Agent A writes, Agent B's 30-second pull cycle picks it up. Local SQLite cache means operations are instant; sync drains incrementally. This is the [[every app that avoids a database ends up rebuilding one badly|"there's always a database underneath"]] pattern with the database both *local* (SQLite cache) *and remote* (Supermemory cloud + R2 for binaries).

Benchmark claims (treat as vendor-reported): on 20 real retrieval tasks, **Codex went from 1.2M → 203K tokens (-83%)** with answers found 19/20 times; **Claude went from 116 → 42 tool calls (-64%), tokens -36%, accuracy 16/20 → 18/20**. Internal claim: ">50% improvement over agentic search" on their own benchmarks. The mechanism matches [[searching more and thinking less improves agentic efficiency and generalization|brute-force grep burning tokens]] — agents stop walking the tree speculatively when the first query lands closer to the answer. The benchmarks are not yet reproducible publicly; the larger report is "forthcoming."

Implementation: one Rust binary, MIT-licensed. FUSE on Linux (`fuser` 0.17 crate), NFSv3 on macOS via `nfsserve` 0.11 as a pure-Rust localhost server — explicitly avoiding macFUSE because of the kext requirement. Works with Daytona, E2B, Cloudflare Workers, Vercel sandboxes. Local-first sync: reads never block on the network, writes commit to local SQLite (`rusqlite` 0.32 with bundled SQLite, `lru` 0.12 for dentry cache) and drain to Supermemory in the background with exponential backoff (`backoff_ms` capped at 60s after 6 attempts). Survives restarts. Offline reads keep working. The `bash/` virtual-bash TypeScript SDK exposes the same Unix surface as a single tool call for serverless edge runtimes with no kernel.

## Tensions and open questions worth flagging

This sits in tension with [[a file system is not all you need - databases beat markdown for agent context provenance and governance|"a file system is not all you need"]] but only superficially — SMFS keeps filesystem *semantics* on top of a SQLite + cloud graph backing store, which is exactly the "database underneath" answer to that critique. It's also a counterpoint to [[hierarchical tree navigation can replace vector embeddings for RAG retrieval|tree navigation as RAG replacement]] — SMFS keeps both the tree and the embeddings.

Open questions the repo and announcement leave unanswered:
- **Which extraction engines?** No disclosure of OCR (Tesseract? cloud OCR?), speech-to-text (Whisper? proprietary?), PDF parsing (PyMuPDF? Marker? proprietary?). Quality across formats is therefore unauditable.
- **Privacy posture?** Every PDF/audio/video/image you drop into a mount is uploaded to Supermemory's cloud. There's no on-device extraction option visible in the repo. ToS, retention, and training-on-your-data clauses are implicit at supermemory.ai but not surfaced in the OSS docs.
- **Cost model?** The ingest pipeline is presumably metered, but the repo just talks to `api.supermemory.ai` with an API key — no billing visibility from the client side.
- **Shell coverage?** The `grep` wrapper is zsh-only; bash and fish users get nothing. `smfs init` writes to `~/.zshrc` unconditionally.
- **Embedding model and search ranker?** Closed source. The client just calls `POST /v4/search` with a `searchMode` string.
- **Lock-in surface?** Container tags are Supermemory's primitive. Migrating away from SMFS means re-extracting binaries elsewhere; the sidecar `.transcription.md` files persist in the local SQLite cache but the *graph* (which feeds `profile.md`) is server-side only.

Bottom line: SMFS is a well-engineered **filesystem-shaped client** for Supermemory's existing closed-source extraction + embedding + memory-graph SaaS. The OSS half (mount, sync, sidecar materialization, grep wrapper) is genuinely interesting infrastructure; the closed half (the actual intelligence) is what makes it work. Treat the "open source, built with Rust btw" framing accordingly.

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
