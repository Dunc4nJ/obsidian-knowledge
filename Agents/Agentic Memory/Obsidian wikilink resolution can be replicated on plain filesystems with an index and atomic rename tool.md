---
created: 2026-02-28
description: How Obsidian resolves wikilinks under the hood and what you'd need to build to replicate the same behavior on a plain markdown filesystem without Obsidian.
source: https://help.obsidian.md/links
type: framework
---

## Key Takeaways

Obsidian's wikilink system works because it maintains a **flat namespace index** on top of a hierarchical filesystem. On vault load, it scans every `.md` file and builds an in-memory map of `filename → full path`, plus any frontmatter `aliases`. When it encounters `[[some note]]`, it resolves by filename alone — folders are irrelevant to link resolution. This is why you can move files between folders without breaking links, as long as filenames stay unique. The [[four memory layers serve different knowledge types]] framework already depends on this property — the vault's declarative memory layer only works because links survive reorganization.

The resolution algorithm follows a priority order: exact filename match (case-insensitive, `.md` optional) → alias match from frontmatter → normalized match (spaces, dashes, underscores treated as equivalent) → path-qualified match if the link contains a `/`. When duplicate filenames exist, Obsidian resolves to the shortest path from the vault root. This is documented in community reverse-engineering but not fully specified in official docs.

The auto-update feature (Settings → Files & Links → "Automatically update internal links") is the critical companion. When you rename or move a file *within Obsidian*, it scans every `.md` file for references to the old name and rewrites them — including heading links, display text aliases, and embeds. The major limitation: this only triggers for operations done through Obsidian. Renames via terminal, git, or external editors leave stale links behind.

For replicating this on a plain filesystem, you need five components: (1) a filename→path index rebuilt on file changes, (2) a resolver implementing the same priority chain, (3) an atomic rename tool that updates all references before moving the file, (4) a file watcher to keep the index fresh, and (5) broken link detection as a safety net. The key architectural decision is making all renames go through a single CLI tool — a `vault-mv` that renames + updates links + rebuilds index atomically. This replaces Obsidian's in-process guarantee with a process-level one. Post-commit hooks can catch anything that slips through.

Obsidian offers three link format settings for how *new* links are written: "shortest path when possible" (default — bare `[[note]]` if unique, adds path for duplicates), "relative path" (relative to current file), and "absolute path" (from vault root). These only affect link generation, not resolution. For a filesystem replica, "shortest path" is the right default since it produces the most portable links.

## Replication Architecture

**Component 1 — Index:** Scan all `.md` files, build `basename → full_path` map. Also parse YAML frontmatter `aliases` fields as additional keys. Rebuild on file create/delete/move events.

**Component 2 — Resolver:** Given a link target, try exact match → alias match → normalized match (collapse spaces/dashes/underscores) → path-qualified match. Return the resolved path or flag as broken.

**Component 3 — Atomic rename tool (`vault-mv`):** Before moving/renaming a file, grep all `.md` files for `[[old name]]` patterns (including `[[old name|display]]`, `[[old name#heading]]`, `![[old name]]`) and rewrite them to the new name. Then perform the actual file operation. Then update the index.

**Component 4 — File watcher:** `inotifywait` (Linux) or `fswatch` (macOS) monitoring the vault directory for create/delete/move events. Triggers incremental index updates.

**Component 5 — Broken link detector:** Periodically or on pre-commit, extract all `[[link]]` targets from all files, resolve each against the index, report any that don't resolve.

## External Resources

- [Obsidian Internal Links — Official Help Docs](https://help.obsidian.md/links) — canonical reference for link syntax, formats, and auto-update setting
- [Obsidian Internal Links — GitHub source](https://raw.githubusercontent.com/obsidianmd/obsidian-help/master/en/Linking%20notes%20and%20files/Internal%20links.md) — raw markdown of the official docs
- [Obsidian Wikilink Rules — Community Gist](https://gist.github.com/dhpwd/9bb86c53b69cb63e09ccca42e3bf924c) — reverse-engineered resolution order: exact filename → normalized → path
- [Forum: "Shortest path when possible" explained](https://forum.obsidian.md/t/settings-new-link-format-what-is-shortest-path-when-possible/6748) — community discussion of the three link format settings
- [Forum: Link resolution mode feature request](https://forum.obsidian.md/t/add-settings-to-control-link-resolution-mode/69560) — demonstrates `[[A]]` resolving to root `A.md` over `Folder/A.md`
- [Reddit: Absolute vs relative vs shortest path](https://www.reddit.com/r/ObsidianMD/comments/r27lj6/absolute_relative_or_shortest_path_to_file_which/) — community discussion with practical tradeoffs for each format
- [Reddit: Auto-update only works for renames within Obsidian](https://www.reddit.com/r/ObsidianMD/comments/1ijyvbr/can_obsidian_automatically_update_internal_links/) — confirms external renames break links
