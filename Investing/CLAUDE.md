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
│   └── Name (TICKER)/                (per-company; created on demand)
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

## Discuss before creating new folders

DO NOT silently create a new sector folder or a new ticker subfolder. If the placement decision tree below would require creating a folder that does not exist, **pause and ask the user to confirm**:

- For a new **sector folder** (beyond the four scaffolded above): confirm the sector name and scope. Examples to discuss: should a robotics name go under `Drones/`, or does it need a new `Robotics/`? Is `AI Infrastructure/` a separate sector or a slice of `Compute/`?
- For a new **ticker subfolder** inside an existing sector: confirm the canonical short name and the primary-sector fit. Examples to discuss: is it `Lumentum (LITE)/` or `Lumentum Holdings (LITE)/`? Does AVGO live under `Photonics/` or `Compute/`?

Only create the folder once the user confirms. This applies to both new sectors and new ticker folders inside existing sectors.

## Placement decision tree

```
If the note is a framework / methodology / mental model:
  → Investing/Frameworks/

If the note is about ONE specific company:
  → Investing/<Sector>/<Name (TICKER)>/
  If the sector folder is missing → DISCUSS with user first (name + scope).
  If the ticker folder is missing → DISCUSS with user first (canonical name).
  For multi-sector names: pick the strongest-fit sector as canonical home;
  update other sectors' MOCs to wiki-link to it.

If the note spans multiple tickers within one sector
  (e.g., a sector-wide cheat sheet, regulatory analysis, supply-chain map):
  → Investing/<Sector>/Research/

If the note spans multiple sectors
  (broker access, macro thesis, cross-sector regulation):
  → defer / ask the user. No standard home yet.
```

## Title convention for general / research notes

Titles must be **maximally informative** so future agents can triage by filename alone without opening the file. A title should encode: the topic + the specific claim or angle + (when relevant) the scope (year, sector breadth, source).

- ❌ Weak: `Goldman report.md`, `Photonics overview.md`, `Earnings recap.md`
- ✅ Strong:
  - `Goldman 2026 AI optical cheat sheet maps EPS upside across lasers PCBs and CCL manufacturers.md`
  - `Silicon photonics displaces EMLs in 800G+ datacenter optics by 2027 per Goldman teardown.md`
  - `LITE 2026-Q2 earnings - 800G ramp ahead of guide, China revenue down 18 pct QoQ.md`

Rule of thumb: someone reading only the filename should know the WHAT, the SO-WHAT, and roughly WHEN. This matches the existing vault pattern (e.g., `SJ Investments asymmetric investing framework screens for compressed valuations with uncapped upside.md`).

Applies to: `Research/` notes, sector overviews, cross-ticker analyses, and ticker-folder notes alike.

## Ticker folder naming

`Name (TICKER)/`. Use the most common short name (e.g., `Lumentum (LITE)/`, not `Lumentum Operations LLC (LITE)/`). For non-US tickers, include the exchange suffix in the ticker if it disambiguates (e.g., `Sumitomo Electric (5802.T)/` vs `Sumitomo Electric (SMTOY)/` if you're tracking the ADR).

## Inside a ticker folder

Start with **flat files**. Use the same maximally-informative title convention. Once a name accumulates 5+ notes spanning multiple categories, allow subfolders like `Earnings/`, `Theses/`, `Risk/`. Discuss with the user before introducing the first subfolder for a ticker.

## MOC update rule

- When adding a **new ticker folder** or a notable **Research/ note**, update the parent sector's `moc - <Sector>.md` with a wiki link.
- When adding a **new sector folder**, update root `moc - Investing.md`.
- When a ticker is multi-sector, add the wiki link to the secondary sector's MOC (under a "Cross-sector" sub-section if needed) so the ticker is discoverable from both.

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

No additional structured fields (no `ticker:`, no `sectors:`). Discoverability comes from folder structure + wiki links + maximally-informative filenames.

## Wiki linking

Cross-link liberally between ticker folders and sector `Research/` notes. Use inline `[[Note Name]]` style woven into prose (matches the rest of the vault). Examples:

- A `Photonics/Research/` note discussing the Goldman cheat sheet should wiki-link to each ticker folder it mentions: `[[Lumentum (LITE)]]`, `[[Coherent (COHR)]]`, etc.
- A ticker folder note should wiki-link back to the sector `Research/` notes that contextualize its thesis.

## What this folder is NOT for

- **Short-term / systematic trading notes** → `Trading/` (different time horizon, different edge sources)
- **Prediction-market content** → `Prediction Markets/`
- **Pure macro/economics not tied to investable theses** → `Thinking/` or wherever appropriate, not here
