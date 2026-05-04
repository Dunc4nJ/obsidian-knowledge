# Investing folder — placement rules

This file governs where notes go inside `Investing/`. It is read by `url-to-obsidian` (and any other capture skill) to route incoming notes deterministically. Read this file before suggesting a destination path for any investing note.

## Folder structure

```
Investing/
├── CLAUDE.md                         (this file)
├── moc - Investing.md                (root navigation)
├── Frameworks/                       (mental models, methodologies, playbooks)
├── Photonics/
│   ├── moc - Photonics.md
│   ├── Research/                     (cross-ticker sector research)
│   └── Lumentum (LITE)/              (per-company; auto-created on mention)
│       ├── Lumentum (LITE).md        (hub MOC — wiki link target)
│       └── <other notes about LITE>
├── Drones/
│   ├── moc - Drones.md
│   └── Research/
├── Critical Minerals/
│   ├── moc - Critical Minerals.md
│   └── Research/
└── Compute/
    ├── moc - Compute.md
    └── Research/
```

## Folder creation policy

The rules differ by folder type:

- **New SECTOR folder** (anything beyond `Photonics/`, `Drones/`, `Critical Minerals/`, `Compute/`): ALWAYS pause and ask the user. Discuss the sector name and scope. Examples: should a robotics name go under `Drones/`, or does it need a new `Robotics/`? Is `AI Infrastructure/` a separate sector or a slice of `Compute/`?

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

Two subcommands:

- `invest add-ticker` — atomic ticker folder + hub MOC creation + sector MOC update. Idempotent (no-op if folder exists; will repair a missing hub).
  - Single: `invest add-ticker LITE --name "Lumentum" --sector Photonics --description "US-listed; lasers + transceivers."`
  - Batch: pipe a JSON array on stdin: `echo '[{"ticker":"LITE","name":"Lumentum","sector":"Photonics","description":"..."}]' | invest add-ticker --batch`
- `invest sync` — regenerate managed sections of all MOCs from folder reality. Run after any capture. Sector-scoped: `invest sync --sector Photonics`.

The CLI does NO web search, NO sector disambiguation, NO ticker validity check. The agent is responsible for: canonical company name lookup, sector inference, deciding what is/isn't a real ticker. Once the agent has those, it passes a JSON spec to `invest add-ticker --batch` and the CLI executes the file mechanics atomically.

Vault auto-detection: the CLI walks up from cwd looking for `Investing/CLAUDE.md`. Run from anywhere inside the vault and it Just Works. Override with `--vault PATH` or `INVEST_VAULT` env var.

Always available flags: `--dry-run` (print plan, write nothing), `--json` (machine-readable result, on `add-ticker`).

## Auto-creating ticker folders from mentions

When a note (especially a sector `Research/` note) mentions a ticker that doesn't have a folder yet, **auto-create the folder + hub MOC** via `invest add-ticker --batch`. Do not interrupt the user for each ticker — disambiguation decisions are made at capture time using the rules below.

The Goldman-cheat-sheet pattern (one note mentions ~30 tickers) should result in: 1 research note saved + 1 batch invocation of `invest add-ticker --batch` creating ~30 folders + hubs in one shot + the source note edited to wiki-link each new ticker.

### Workflow

1. Save the captured note via `url-to-obsidian` to its destination (typically `<Sector>/Research/<title>.md`).
2. Identify mentioned tickers in the note. For each:
   - Skip if private/non-tradeable (e.g., "Source Photonics — Private").
   - Skip if already has a folder (check `<Sector>/<Name (TICKER)>/`).
   - Web-search canonical short name if unknown.
   - Determine sector. Default = the source note's containing sector. For multi-sector names (e.g., AVGO is Photonics + Compute), pause and ask the user which is canonical.
3. Build a JSON spec list and pipe to `invest add-ticker --batch`.
4. Edit the source note to wiki-link each new ticker as `[[Name (TICKER)]]`.
5. Done — `add-ticker --batch` runs sync internally for affected sectors. Run `invest sync` separately only if you've also added research notes or made manual edits elsewhere.

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

When you create a new sector folder (after discussing with the user), `invest sync` will pick it up automatically and add it to the root MOC's `## Sectors`.

## Frontmatter

Follow `url-to-obsidian` defaults:

```yaml
---
created: YYYY-MM-DD
description: One sentence elaborating the title claim
source: https://original-url   (or "internal" for synthesized notes)
type: framework | research | earnings | thesis | analysis | moc
---
```

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

No additional structured fields beyond `authors:` (no `ticker:`, no `sectors:`). Discoverability comes from folder structure + wiki links + maximally-informative filenames.

## Wiki linking

Cross-link liberally between ticker folders and sector `Research/` notes. Use inline `[[Note Name]]` style woven into prose (matches the rest of the vault). Examples:

- A `Photonics/Research/` note discussing the Goldman cheat sheet should wiki-link to each ticker mentioned: `[[Lumentum (LITE)]]`, `[[Coherent (COHR)]]`, etc. Each link resolves to that ticker's hub MOC.
- A ticker folder note should wiki-link back to the sector `Research/` notes that contextualize its thesis.
- The ticker hub MOC's `## Notes` section is itself a list of wiki links to every other note in the folder.

## What this folder is NOT for

- **Short-term / systematic trading notes** → `Trading/` (different time horizon, different edge sources)
- **Prediction-market content** → `Prediction Markets/`
- **Pure macro/economics not tied to investable theses** → `Thinking/` or wherever appropriate, not here
