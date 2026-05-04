# Investing folder — placement rules

This file governs where notes go inside `Investing/`. It is read by `url-to-obsidian` (and any other capture skill) to route incoming notes deterministically. Read this file before suggesting a destination path for any investing note.

## Folder structure

```
Investing/
├── CLAUDE.md                         (this file)
├── moc - Investing.md                (root navigation; canonical sector list)
├── Frameworks/                       (mental models, methodologies, playbooks)
└── <Sector>/                         (one folder per sector; see moc - Investing.md)
    ├── moc - <Sector>.md             (sector navigation; canonical ticker list for the sector)
    ├── Research/                     (cross-ticker sector research notes)
    ├── _media/                       (images for notes in this sector; created on first use)
    └── <Name (TICKER)>/              (per-company; auto-created on mention)
        ├── <Name (TICKER)>.md        (hub MOC — wiki link target)
        └── <other notes about that ticker>
```

**The canonical list of sectors is `moc - Investing.md` under `## Sectors`** (kept accurate by `invest sync` from filesystem reality). Don't hardcode sector names anywhere else — read the root MOC or `ls Investing/` instead.

## Asking the user

When this file tells you to "ASK USER" or "pause and ask the user" (e.g., new sector creation, multi-sector ticker disambiguation, first ticker subfolder), use the **AskUserQuestion** tool rather than free-form prose. Present the decision as discrete labeled options so the user can pick without writing a sentence. Free-form text is fine for follow-up clarification, but the initial decision prompt should go through AskUserQuestion.

## Folder creation policy

The rules differ by folder type:

- **New SECTOR folder** (any sector NOT already listed in `moc - Investing.md` under `## Sectors`): ALWAYS pause and ask the user via the AskUserQuestion tool. Discuss the sector name and scope. Examples: should a robotics name go under an existing sector, or does it need a new `Robotics/`? Is `AI Infrastructure/` a separate sector or a slice of an existing one? Read `moc - Investing.md` first to see what already exists, then decide.

- **New TICKER folder inside an existing sector**: AUTO-CREATE without interruption. Use the disambiguation rules below to determine the canonical company name and the right sector. The ticker folder always includes a hub MOC named the same as the folder (see "Per-ticker hub MOC" below).

- **New ticker subfolder** (e.g., `Earnings/`, `Theses/` inside a ticker folder): discuss with the user before introducing the first one for a ticker. Most ticker folders should stay flat.

## Placement decision tree

```
If the note is a framework / methodology / mental model:
  → Investing/Frameworks/

If the note is about ONE specific company:
  → Investing/<Sector>/<Name (TICKER)>/
  If the sector folder is missing → ASK USER first (sector name + scope).
  If the ticker folder is missing → AUTO-CREATE folder + hub MOC.
  For multi-sector names: pick the strongest-fit sector as canonical home;
  add a wiki link in other sectors' MOCs under "Cross-sector".

If the note spans multiple tickers within one sector
  (e.g., a sector-wide cheat sheet, regulatory analysis, supply-chain map):
  → Investing/<Sector>/Research/
  Auto-create folders + hub MOCs for any mentioned tickers that don't have
  one yet (see "Auto-creating ticker folders from mentions").

If the note spans multiple sectors
  (broker access, macro thesis, cross-sector regulation):
  → defer / ask the user. No standard home yet.
```

## Per-ticker hub MOC

Every ticker folder contains a hub note named **exactly the same as the folder** (e.g., `Lumentum (LITE)/Lumentum (LITE).md`). This is what wiki links like `[[Lumentum (LITE)]]` resolve to.

The hub is a **Map of Content** for the ticker — its purpose is to list every note in the folder so you can navigate from one entry point.

### Hub stub (created with the folder)

```yaml
---
created: YYYY-MM-DD
description: <Company Name> (<TICKER>) — <one-line context: exchange, business line>
type: moc
---

# <Company Name> (<TICKER>)

<1–2 sentence context: exchange, sector(s), what the business does, why it's
on the radar. Web-searched at folder creation time.>

## Notes

_(populated as notes are added to this folder)_
```

### Hub upkeep — handled by `invest sync`

After adding any note inside a ticker folder (or anywhere in `Investing/`), run `invest sync`. This regenerates the ticker hub's `## Notes` section, the sector MOC's `## Companies` and `## Research` sections, and the root MOC's `## Frameworks` and `## Sectors` sections — all from folder reality. Do NOT manually edit those managed sections; they get rewritten on the next sync.

For multi-sector names, manually add a wiki link in the secondary sector's MOC under a `## Cross-sector` section. (Cross-sector references are not auto-managed in v1.)

## Tooling: `invest` CLI

The deterministic mechanics of this folder are automated by the `invest` CLI (source: `/data/projects/obsidian-invest-cli/`, install: `uv tool install -e /data/projects/obsidian-invest-cli/`).

Three subcommands:

- `invest add-sector` — atomic sector folder + sector MOC + `Research/` subfolder. Use after the user has approved a NEW sector via AskUserQuestion. Idempotent (no-op if complete; repairs missing MOC or Research/).
  - Single: `invest add-sector Energy --description "Power generation, behind-the-meter, fuel cells."`
  - Batch: `echo '[{"name":"Robotics","description":"…"},{"name":"Biotech"}]' | invest add-sector --batch`
- `invest add-ticker` — atomic ticker folder + hub MOC creation + sector MOC update. Idempotent (no-op if folder exists; will repair a missing hub).
  - Single: `invest add-ticker LITE --name "Lumentum" --sector Photonics --description "US-listed; lasers + transceivers."`
  - Batch: pipe a JSON array on stdin: `echo '[{"ticker":"LITE","name":"Lumentum","sector":"Photonics","description":"..."}]' | invest add-ticker --batch`
- `invest sync` — regenerate managed sections of all MOCs from folder reality. Run after any capture. Sector-scoped: `invest sync --sector Photonics`. `--dry-run` prints unified diffs of every file that would change.

The CLI does NO web search, NO sector disambiguation, NO ticker validity check. The agent is responsible for: canonical company name lookup, sector inference, deciding what is/isn't a real ticker. Once the agent has those, it passes a JSON spec to `invest add-ticker --batch` (or `invest add-sector --batch`) and the CLI executes the file mechanics atomically.

Vault auto-detection: the CLI walks up from cwd looking for `Investing/CLAUDE.md`. Run from anywhere inside the vault and it Just Works. Override with `--vault PATH` or `INVEST_VAULT` env var.

Always available flags: `--dry-run` (preview without writing; on `sync` and `add-*`, prints unified diffs), `--json` (machine-readable result, on `add-*`). Batch mode rejects duplicate specs before any writes.

## Auto-creating ticker folders from mentions

When a note (especially a sector `Research/` note) mentions a ticker that doesn't have a folder yet, **auto-create the folder + hub MOC** via `invest add-ticker --batch`. Do not interrupt the user for each ticker — disambiguation decisions are made at capture time using the rules below.

The Goldman-cheat-sheet pattern (one note mentions ~30 tickers) should result in: 1 research note saved + 1 batch invocation of `invest add-ticker --batch` creating ~30 folders + hubs in one shot + the source note edited to wiki-link each new ticker.

### Subject ticker vs mentioned ticker

Two roles a ticker can play in a captured note. The order of operations differs:

- **Subject ticker** — the company the note is ABOUT. The note physically lives inside this ticker's folder (e.g., a thesis, an earnings recap). Order matters: the folder must exist before the note can be written to it.
- **Mentioned ticker** — a peer / competitor / supply-chain reference. The note links to it via `[[Name (TICKER)]]` but doesn't live in its folder.

Both kinds get auto-created via `invest add-ticker` if missing. The difference is only WHEN you create them relative to writing the note.

### Workflow A — multi-ticker research note (Goldman cheat sheet pattern)

The source note belongs in `<Sector>/Research/` and references many tickers as peers. No subject ticker; all are mentions.

1. Save the captured note via `url-to-obsidian` to `<Sector>/Research/<title>.md`.
2. Identify mentioned tickers in the note. For each:
   - Skip if private/non-tradeable (e.g., "Source Photonics — Private").
   - Skip if already has a folder (check `<Sector>/<Name (TICKER)>/`).
   - Web-search canonical short name if unknown.
   - Determine sector. Default = the source note's containing sector. For multi-sector names (e.g., AVGO is Photonics + Compute), pause and ask the user which is canonical.
3. Build a JSON spec list and pipe to `invest add-ticker --batch`.
4. Edit the source note to wiki-link each new ticker as `[[Name (TICKER)]]`.
5. Run `invest sync` — adding the research note created a new file in `<Sector>/Research/` that the sector MOC needs to pick up. (`add-ticker --batch` only synced the `## Companies` section, not `## Research`.)

### Workflow B — single-company thesis / earnings / analysis note

The source note is ABOUT one company and physically lives inside that ticker's folder. May also mention peer tickers.

1. Identify the **subject ticker**. If its folder doesn't exist yet, run `invest add-ticker SUBJECT --name "..." --sector ... --description "..."` FIRST. Folder + hub get created.
2. Save the captured note via `url-to-obsidian` to `<Sector>/<Name (TICKER)>/<long-informative-title>.md`.
3. Identify any mentioned (peer/supply-chain) tickers in the note. Apply the same skip / web-search / disambiguate rules as Workflow A.
4. If any mentioned tickers need new folders, build a JSON spec and pipe to `invest add-ticker --batch`.
5. Edit the note to wiki-link the subject AND every mentioned ticker as `[[Name (TICKER)]]`.
6. Run `invest sync` — REQUIRED. Adding a note inside a ticker folder doesn't auto-trigger sync; only `add-ticker` does. Sync updates the subject ticker's hub `## Notes` to include the new file.

### When `invest sync` is required

`add-ticker` runs sync internally for the sectors it touched, so it covers `## Companies` updates from new ticker folders. Run `invest sync` ADDITIONALLY whenever you've:

- Saved a note inside a `Research/` folder (Workflow A step 5)
- Saved a note inside an existing ticker folder (Workflow B step 6)
- Manually moved, renamed, or deleted any file under `Investing/`
- Manually edited a ticker hub or sector MOC's managed sections (sync rewrites them; do not edit by hand)

If you only ran `add-ticker --batch` and didn't write any notes afterward (pure folder scaffolding), no separate sync is needed.

### Disambiguation

For each mentioned ticker, determine:

1. **Canonical company name** for the folder — use the most common short name (e.g., `Lumentum`, not `Lumentum Holdings Inc.`). If you don't know it, do a quick web search. Format: `Name (TICKER)/`.

2. **Sector** — inferred from the source note's containing folder. If the source note is in `Photonics/Research/`, all mentioned tickers default to `Photonics/`. If the ticker is genuinely multi-sector (e.g., AVGO is photonics AND compute), pause and ask the user which sector should be the canonical home.

3. **Ticker format inside parens** — for non-US tickers include the exchange suffix if it disambiguates: `Sumitomo Electric (5802.T)/` (Tokyo) vs `Sumitomo Electric (SMTOY)/` (US OTC ADR). Pick the listing you would actually trade.

4. **Skip non-tradeable mentions** — if a name is private (e.g., "Source Photonics — Private") or not a real ticker (a generic acronym in caps that isn't a stock), do NOT create a folder. Just don't wiki-link it.

### Cross-sector wiki linking

A wiki link `[[Lumentum (LITE)]]` resolves to the hub `.md` file regardless of which folder it lives in. So when a `Compute/Research/` note mentions LITE (whose canonical home is `Photonics/`), the link still works without duplication. Add LITE to `Compute/moc - Compute.md` under `## Cross-sector` so it's discoverable from both sector MOCs.

## Title convention for general / research notes

Titles must be **maximally informative** so future agents can triage by filename alone without opening the file. A title should encode: the topic + the specific claim or angle + (when relevant) the scope (year, sector breadth, source).

- ❌ Weak: `Goldman report.md`, `Photonics overview.md`, `Earnings recap.md`
- ✅ Strong:
  - `Goldman 2026 AI optical cheat sheet maps EPS upside across lasers PCBs and CCL manufacturers.md`
  - `Silicon photonics displaces EMLs in 800G+ datacenter optics by 2027 per Goldman teardown.md`
  - `LITE 2026-Q2 earnings - 800G ramp ahead of guide, China revenue down 18 pct QoQ.md`

Rule of thumb: someone reading only the filename should know the WHAT, the SO-WHAT, and roughly WHEN. This matches the existing vault pattern (e.g., `SJ Investments asymmetric investing framework screens for compressed valuations with uncapped upside.md`).

Applies to: `Research/` notes, sector overviews, cross-ticker analyses, and ticker-folder notes alike. **Exception**: ticker hub MOCs use the bare folder name as their filename (e.g., `Lumentum (LITE).md`), not a maximally-informative title — the hub is a navigation file, not a content note.

## Inside a ticker folder

Start with **flat files** alongside the hub MOC. Use the maximally-informative title convention for content notes. Once a name accumulates 5+ notes spanning multiple categories, allow subfolders like `Earnings/`, `Theses/`, `Risk/`. Discuss with the user before introducing the first subfolder for a ticker.

## MOC update rule

All MOC managed sections (`## Notes` in hub MOCs, `## Companies` and `## Research` in sector MOCs, `## Frameworks` and `## Sectors` in the root MOC) are auto-managed by `invest sync`. Do not edit them manually — they get regenerated from folder reality on the next sync.

The ONE exception: `## Cross-sector` sections in sector MOCs (used to surface multi-sector tickers in their non-canonical sector) are not auto-managed in v1; edit those by hand.

When you create a new sector (after discussing with the user via AskUserQuestion), use `invest add-sector <Name>` — it atomically creates the folder + sector MOC + `Research/` subfolder and updates the root MOC's `## Sectors`.

## Frontmatter

Follow `url-to-obsidian` defaults, with the Investing-specific additions below:

```yaml
---
created: YYYY-MM-DD          # date the note was added to the vault (today)
published: YYYY-MM-DD        # date the SOURCE was originally published; required when source has one
description: One sentence elaborating the title claim
source: https://original-url   (or "internal" for synthesized notes)
type: framework | research | earnings | thesis | analysis | moc
---
```

### `created` vs `published`

- **`created`** — date the note was added to the vault (today's date when you write the note). Always required.
- **`published`** — date the SOURCE was originally published (tweet date, article date, paper date, video upload date). Required when source has one; omit for synthesized notes (`source: internal`). For investing this matters a lot — a thesis from 6 months ago is very different from yesterday's, and you shouldn't have to scroll into the Original Content blockquote to find out.

### Author capture (REQUIRED for opinion/source content)

When the captured content is from an attributable individual — **X (Twitter) posts, Substack articles, blog posts, podcast episodes, YouTube videos, newsletters** — include an `authors:` field with the source's display name and handle. This matters for investing notes because the credibility/track record of the author is part of the signal.

```yaml
---
created: 2026-05-04
description: ...
source: https://x.com/SJCapitalInvest/status/...
type: framework
authors: ["S&J Investments (@SJCapitalInvest)"]
---
```

For multi-author posts (e.g., joint Substacks), list all authors. For news-org articles (Bloomberg, FT, Reuters) where the byline is incidental, the author field is optional but include it if prominent (e.g., a named columnist).

No additional structured fields beyond `authors:` and `published:` (no `ticker:`, no `sectors:`). Discoverability comes from folder structure + wiki links + maximally-informative filenames.

## Media (images, screenshots)

Captured sources often include images: tweet attachments, article diagrams, PDF figures, video frames. These are part of the note's signal — capture them all.

### Where they live

`Investing/<Sector>/_media/` — one `_media/` folder per sector, holding images for any note in that sector (Research/ notes AND ticker-folder notes). Create the folder on first use; mirrors the existing `Knowledge/<Section>/_media/` convention used elsewhere in the vault.

### Naming

Use a consistent slug prefix per source so all images from one capture sort together:

- **Tweets**: `<author-handle>-<last-6-of-tweet-id>-NNN.<ext>` — e.g., `million_sancet-579181-001.png` (matches the `extract-tweet-images.sh` script's output)
- **Articles / blog posts**: `<domain-or-author>-<short-id>-NNN.<ext>` — e.g., `bloomberg-photonics-001.png`
- **Research PDFs**: `<first-author-or-paper-slug>-NNN.<ext>` — e.g., `goldman-2026-optical-001.png`

Numbering is 1-indexed in the order images appear in the source.

### Mandatory extraction

Image extraction is **not optional** for sources that have images. Every tweet, article, and figure-bearing PDF must go through extraction. Don't skip even if the fetched markdown looks "text-only" — the source may have images the text extraction missed.

The `url-to-obsidian` skill provides `extract-tweet-images.sh` for tweets and per-source extraction for web/PDF. Run AFTER determining the destination sector so you target the right `_media/`.

### Strict no-orphans rule

Every image in any `Investing/<Sector>/_media/` MUST be embedded in at least one note. After extraction, review what got pulled:

- **Embed every content image** in the relevant note's body via `![[filename.ext]]` with a brief italic caption above:
  ```markdown
  *Goldman 2026 optical supply-chain map (Sancet's annotations in red)*
  ![[million_sancet-579181-001.png]]
  ```
- **Delete non-content artifacts** before commit: profile pics, OG/social cards, decorative icons, navigation elements, tracking pixels.
- **Verify mechanically** after writing the note: every image with the slug prefix must appear in at least one `![[...]]` embed in the corresponding note.

Orphan images are a quality bug — they signal the agent extracted images but didn't actually use them, or that source images were missed.

### Embedding placement

In the note's **Original Content** section, place embeds at their natural positions in the source's flow (where the image originally appeared). For images that contain key data (charts, tables-as-images), also reference them in **Key Takeaways** if their content isn't otherwise reflected in the prose.

## Wiki linking

Cross-link liberally between ticker folders and sector `Research/` notes. Use inline `[[Note Name]]` style woven into prose (matches the rest of the vault). Examples:

- A `Photonics/Research/` note discussing the Goldman cheat sheet should wiki-link to each ticker mentioned: `[[Lumentum (LITE)]]`, `[[Coherent (COHR)]]`, etc. Each link resolves to that ticker's hub MOC.
- A ticker folder note should wiki-link back to the sector `Research/` notes that contextualize its thesis.
- The ticker hub MOC's `## Notes` section is itself a list of wiki links to every other note in the folder.

## What this folder is NOT for

- **Short-term / systematic trading notes** → `Trading/` (different time horizon, different edge sources)
- **Prediction-market content** → `Prediction Markets/`
- **Pure macro/economics not tied to investable theses** → `Thinking/` or wherever appropriate, not here
