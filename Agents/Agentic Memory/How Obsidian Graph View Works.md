---
created: 2026-02-28
description: How Obsidian builds and renders its graph view from wikilinks and metadata cache
---

# How Obsidian Graph View Works

## Overview

Obsidian is an **Electron-based** (Chromium + Node.js) desktop app that operates on a local folder of plain **Markdown (.md) files** — your "vault." There's no proprietary database; everything is just files on disk.

## Core Linking Mechanism

You create connections between notes using `[[wikilinks]]` or standard `[markdown](links)`. Obsidian parses all files and builds a **metadata cache** — an in-memory index of every note, its links, tags, aliases, and frontmatter. This cache is the backbone of everything: backlinks, search, and the graph.

## Graph Construction

### Data Layer
- Each markdown file = one **node**
- Each `[[wikilink]]` or markdown link between files = one **edge**
- Unresolved links (pointing to notes that don't exist yet) also appear as nodes (shown differently)
- The more inbound links a node has, the **larger** it renders

### Rendering Engine
- The graph is rendered using **PixiJS** (a WebGL/WebGPU 2D renderer) inside the Electron app — this is why it can handle thousands of nodes smoothly
- Obsidian confirmed PixiJS usage in a forum post, citing **performance reasons** (confirmed by Reddit user m_hans_223344)
- Bug reports on the Obsidian forum reference PixiJS shader issues, further confirming this is the rendering engine

### Layout Algorithm
- Uses a **force-directed graph** simulation (think: physics engine for graphs)
- Nodes repel each other (like charged particles), while edges act as springs pulling linked nodes together
- The simulation runs iteratively until it stabilizes into a readable layout
- Obsidian exposes user-tunable **force parameters**: center force, repel force, link force, and link distance
- Uses **RBush** (a high-performance R-tree spatial index for 2D) for spatial math/collision detection — confirmed by Obsidian dev **joethei** on Reddit: *"Canvas is pretty much all custom code, we only use RBush to help with some of the math"*
- The force-directed layout is **custom code**, not D3.js or another off-the-shelf library

### Pipeline Summary

```
Markdown files → metadata cache → graph data structure (adjacency list) → custom force-directed layout (with RBush spatial indexing) → PixiJS WebGL rendering
```

### Note: Quartz (Open-Source Alternative)
- **Quartz** ([github.com/jackyzha0/quartz](https://github.com/jackyzha0/quartz)) has a similar graph view but uses **D3.js** instead of PixiJS
- See: [Quartz Graph.tsx](https://github.com/jackyzha0/quartz/blob/v4/quartz/components/Graph.tsx) and its `package.json` for D3 dependency

## Two Graph Views

- **Local graph** — shows only the current note + its direct neighbors (expandable by depth)
- **Global graph** — shows the entire vault (or a filtered subset)

## Filtering & Grouping

- Filter by search query, tags, paths, or exclude folders
- Create color-coded **groups** (e.g., all notes tagged `#project` in blue)
- Toggle orphan nodes, attachments, and existing-only notes on/off
- Code snippets can be entered in the search box for advanced filtering

## Interaction

- Hover highlights a node + its connections
- Click opens the corresponding note
- Drag to reposition nodes
- Right-click for additional manipulation options
- **Animate** feature shows vault growth chronologically (time-lapse)

## Sources

1. [Obsidian Official Help — Graph View](https://help.obsidian.md/Plugins/Graph+view)
2. [A closer look at Obsidian's innovative graph view — Mind Mapping Software Blog (Dec 2022)](https://mindmappingsoftwareblog.com/obsidian-graph-view/)
3. [DeepWiki analysis of obsidianmd/obsidian-help repo — Graph View](https://deepwiki.com/obsidianmd/obsidian-help/4.5-graph-view) — confirms force-directed layout algorithm and tunable force parameters
4. [Obsidian Forum: V1.4.5 graph view PixiJS shaders broken](https://forum.obsidian.md/t/v1-4-5-graph-view-does-not-render-nodes-pixijs-shaders-broken/66621) — confirms PixiJS as the rendering engine
5. [Obsidian Forum: Graph view, physics, and force directed graphs](https://forum.obsidian.md/t/graph-view-physics-and-force-directed-graphs/72586) — discussion of force-directed physics simulation
6. [Obsidian.md](https://obsidian.md) — general architecture (Electron, local Markdown, wikilinks)
7. [Reddit r/ObsidianMD: What does Obsidian use to create their graph view?](https://www.reddit.com/r/ObsidianMD/comments/1mhujgy/what_does_obsidian_use_to_create_their_graph_view/) — Obsidian dev **joethei** confirms RBush for spatial math + custom code; **m_hans_223344** confirms PixiJS; **Delicious-Feature334** points to Quartz as open-source D3-based alternative
8. [RBush — GitHub](https://github.com/mourner/rbush) — high-performance R-tree spatial index used by Obsidian
9. [Quartz Graph.tsx source](https://github.com/jackyzha0/quartz/blob/v4/quartz/components/Graph.tsx) — open-source D3-based graph view for comparison

---

## Setting Up Obsidian for a Team

### Licensing (as of 2025)

- **Obsidian is completely free for commercial/business use** — the commercial license is now optional
- No enterprise tier needed — same app for everyone
- You'd only pay for optional cloud add-ons: **Obsidian Sync** ($4/mo/user) or **Obsidian Publish** ($8/mo/user)

### Recommended: Git-Based Sync (Free)

The **Obsidian Git** community plugin provides free team sync via any Git remote (GitHub, GitLab, Bitbucket, self-hosted).

**Setup per team member:**
1. Create a shared private Git repo (e.g., GitHub)
2. Each member clones the repo as their local vault folder
3. Open that folder as a vault in Obsidian
4. Install the **Obsidian Git** community plugin (Settings → Community Plugins → Browse → "Obsidian Git")
5. Configure auto-pull and auto-push intervals (e.g., every 5 minutes)

**Pros:**
- Zero cost
- Full version history and blame (who changed what, when)
- You own your data — no vendor lock-in
- Works offline; syncs when back online
- Branching possible for experimental work

**Cons:**
- No real-time collaborative editing (async only, not Google Docs-style)
- Merge conflicts can occur if two people edit the same file simultaneously (rare with markdown since people usually work on different notes)
- Non-technical users may need initial hand-holding with Git setup
- Binary files (images, PDFs) bloat the repo — use **Git LFS** for large media

### Alternative: Obsidian Sync (Paid)

If the team is non-technical or needs simpler onboarding:
- $4/user/month, end-to-end encrypted
- Real-time sync across devices
- No Git knowledge required
- But: vendor-hosted, less version history granularity

### For Agent Integration

See also: [[Obsidian as Agentic Memory]] for how to structure the vault so AI agents can traverse it as a knowledge graph using wikilinks, claim-based note titles, and layered orientation files.
