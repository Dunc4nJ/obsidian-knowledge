# Investing folder — placement rules

This file governs where notes go inside `Investing/`. Read it before suggesting a destination for any investing note.

## Folder structure

```
Investing/
├── CLAUDE.md                         (this file)
├── moc - Investing.md                (root nav; canonical sector list)
├── Frameworks/                       (mental models, methodologies, playbooks)
└── <Sector>/                         (one folder per sector — see moc - Investing.md)
    ├── moc - <Sector>.md             (sector nav; canonical ticker list)
    ├── Research/                     (cross-ticker research notes)
    ├── _media/                       (images for notes in this sector)
    └── <Name (TICKER)>/              (per-company; auto-created on mention)
        ├── <Name (TICKER)>.md        (hub MOC — wiki-link target)
        └── <other notes about that ticker>
```

**Canonical sector list** is `moc - Investing.md` under `## Sectors` (kept accurate by `invest sync`). Don't hardcode sector names elsewhere — read the root MOC or `ls Investing/`.

## Placement matrix

| Note type | Save to | CLI sequence |
|---|---|---|
| Framework / methodology | `Frameworks/<title>.md` | (just save) |
| About ONE company | `<Sector>/<Name (TICKER)>/<title>.md` | If folder missing: `add-ticker` FIRST → save → `sync` |
| Multi-ticker research / sector cheat sheet / supply-chain map | `<Sector>/Research/<title>.md` | save → `add-ticker --batch` (mentioned tickers) → `sync` |
| Spans multiple sectors (broker access, macro thesis) | defer — ASK USER | — |

**Subject ticker** = company a note is ABOUT (lives in its folder). **Mentioned ticker** = peer/competitor/supply-chain reference (linked via `[[Name (TICKER)]]` only). Both auto-created if missing; subject's folder must exist BEFORE its note can be saved (so `add-ticker` runs first).

The Goldman-cheat-sheet pattern (one note mentions ~30 tickers) maps to row 3: 1 research note saved + 1 batch invocation creating ~30 folders + hubs in one shot + source note edited to wiki-link each new ticker.

## Capturing notes — always invoke `/url-to-obsidian`

Every captured note from an external source — **tweets, articles, blog posts, papers, videos, podcasts, PDFs** — MUST be created via the `/url-to-obsidian` skill. Do NOT hand-write the note file from scratch.

The skill handles fetching, URL classification, image extraction, frontmatter, verbatim Original Content preservation, and image embedding. This file then governs WHERE the saved note lands and what `invest` CLI mechanics run after. If you find yourself writing a `---\ncreated: ...\n---` block by hand for a captured source, stop and use the skill.

## Primary sources before synthesis

Deep research that draws on multiple primary sources MUST capture those sources as standalone notes BEFORE writing the synthesis. The synthesis then wiki-links to each capture instead of paraphrasing — every claim traces back to a verbatim original.

**The bar**: capture-as-own-note if you'd cite it more than once OR want to re-read it in 6 months. Press releases, contract announcements, capital-raise filings, analyst notes, transcripts, regulatory filings all clear it. Point-in-time aggregator pages (current price, PT consensus, market-cap screens) do NOT — those stay inline as plain URLs.

**Pattern**: delegate captures in parallel to subagents. Each subagent invokes `/url-to-obsidian` with explicit instructions to (a) place the note in the appropriate Investing folder per the placement matrix above (NOT `Knowledge/...`), and (b) skip git operations and `invest sync`. Parent runs `invest sync` once after all captures complete, then edits the synthesis to wiki-link each captured source, then batches one commit.

## Frontmatter

All fields shown — only these are recognized (no `ticker:`, no `sectors:`):

```yaml
---
created: 2026-05-04                  # vault add date (today). Always required.
published: 2026-05-03                # SOURCE pub date. Required when source has one (a 6-month-old thesis vs yesterday's matters; don't make readers scroll into Original Content to learn it). Omit for source: internal.
description: One-sentence claim elaboration.
source: https://x.com/...            # or "internal" for synthesized notes
type: framework | research | earnings | thesis | analysis | moc
authors: ["Display Name (@handle)"]  # REQUIRED for X, Substack, blog, podcast, video, newsletter — author credibility/track record is part of the investing signal. Multi-author → list all. News-org bylines → optional unless prominent (named columnist).
subsectors: [Lasers, Components]     # OPTIONAL; values must match parent sector MOC's subsectors: list. See Sub-sectors below. In batch JSON either a list or a single string is accepted (string auto-coerced to one-element list).
---
```

Discoverability comes from folder structure + wiki links + maximally-informative filenames — not extra metadata.

## Tooling: `invest` CLI

Source: `/data/projects/obsidian-invest-cli/` (origin: <https://github.com/Dunc4nJ/obsidian-invest-cli>). Install: `uv tool install -e /data/projects/obsidian-invest-cli/`. Auto-detects vault by walking up from cwd looking for `Investing/CLAUDE.md`; override with `--vault PATH` or `INVEST_VAULT` env var.

| Command | What | Key flags |
|---|---|---|
| `invest add-sector NAME --description "..."` | Sector folder + MOC + `Research/`. Use AFTER AskUser approval. Idempotent. | `--batch` (JSON stdin), `--dry-run`, `--json` |
| `invest add-ticker TICKER --name N --sector S --description "..."` | Ticker folder + hub MOC + sector MOC update. Idempotent (no-op if folder exists; repairs missing hub). | `--subsectors A,B`, `--batch`, `--dry-run`, `--json` |
| `invest sync` | Regenerate managed sections from folder reality. Run after captures + manual edits. | `--sector S`, `--dry-run` (prints unified diffs) |

CLI does NO web search, NO sector disambiguation, NO ticker validity check. Agent is responsible for canonical name lookup, sector inference, ticker validity. Agent passes JSON specs; CLI executes file mechanics atomically. Batch mode rejects duplicate specs before any writes.

## Folder creation policy

| Folder type | Action |
|---|---|
| New SECTOR (any not in root MOC's `## Sectors`) | ALWAYS pause and ASK USER (sector name + scope). Examples to discuss: should a robotics name go under an existing sector or need a new `Robotics/`? Is `AI Infrastructure/` separate or a slice? |
| New TICKER inside an existing sector | AUTO-CREATE via `invest add-ticker` (no interruption). Apply Disambiguation rules below. |
| New ticker subfolder (`Earnings/`, `Theses/`, etc.) | DISCUSS before introducing the first one. Most ticker folders should stay flat. |

## Asking the user

When this file says "ASK USER" or "pause and ask," use the **AskUserQuestion** tool with discrete labeled options — not free-form prose. Free-form text is fine for follow-up clarification; the initial decision goes through AskUserQuestion.

## Disambiguation (for any new ticker)

| Decision | Rule |
|---|---|
| Canonical name | Most common short name (`Lumentum`, not `Lumentum Holdings Inc.`). Web-search if unknown. Format: `Name (TICKER)/`. |
| Sector | Default = source note's containing sector. Multi-sector ticker (e.g., AVGO is Photonics + Compute) → ASK USER which is canonical home. |
| Ticker format | Non-US: include exchange suffix that disambiguates — `5802.T` (Tokyo) vs `SMTOY` (US OTC ADR). Pick the listing you'd actually trade. |
| Skip | (a) Already has a folder (check `<Sector>/<Name (TICKER)>/`) — no-op. (b) Private (e.g., "Source Photonics — Private") or generic acronyms that aren't tickers — don't create folder, don't wiki-link. |

## Sector placement principle

**Place by primary investment thesis, not product taxonomy.** A name belongs in the sector that captures *why you'd buy it* — the dominant end-market thesis driving its valuation.

- **Intermediate-product companies** (substrates, equipment, test gear, components) go in their **dominant end-market** sector. A compound-semi epitaxial wafer maker whose customers are ~all laser/photodiode manufacturers → `Photonics/`, not an abstract substrate sector. The thesis IS the photonics laser ramp; the substrate company rides that wave.
- **Truly horizontal infrastructure** — names serving multiple sectors with no single dominant end market — goes in `Semi Infrastructure/`. TSMC (logic foundry for compute, photonics, RF, mobile, automotive) is the canonical example. If you can't pick a dominant end market, it's horizontal.
- **Cross-sector exposure** — even when a name's canonical home is clear, if it has material exposure to another sector, list it in the secondary sector's MOC under `## Cross-sector` (manual; not auto-managed by sync).

The test: ask "which sector's thesis breaking would tank this stock the most?" That's the canonical home.

## Per-ticker hub MOC

Every ticker folder contains a hub note named **exactly the same as the folder** (e.g., `Lumentum (LITE)/Lumentum (LITE).md`). This is what wiki links like `[[Lumentum (LITE)]]` resolve to. The hub is a Map of Content — its `## Notes` section lists every other note in the folder (auto-managed by sync).

Stub written by `invest add-ticker` (you don't write this by hand):

```yaml
---
created: YYYY-MM-DD
description: <Name> (<TICKER>) — <one-line context: exchange, business line>
type: moc
subsectors: [...]   # optional; only when sector declares allowed list
---

# <Name> (<TICKER>)

<1-2 sentence context: exchange, sector, business, why it's on the radar>

## Notes
_(populated by invest sync)_
```

**Cross-sector wiki-linking**: `[[Lumentum (LITE)]]` resolves to the hub regardless of which folder the link comes from. So a `Compute/Research/` note can link to LITE (canonical home `Photonics/`) without duplication. Add cross-sector links manually under `## Cross-sector` in the secondary sector's MOC.

## When `invest sync` is required

`add-ticker` runs sync internally for sectors it touched (covers `## Companies`). Run `invest sync` ADDITIONALLY when you've:

- Saved a note inside a `Research/` folder (sync picks it up under `## Research`)
- Saved a note inside a ticker folder (sync picks it up under that hub's `## Notes`)
- Manually moved/renamed/deleted any file under `Investing/`
- Manually edited a managed MOC section (sync rewrites them; do not edit by hand)

If you only ran `add-ticker --batch` with no notes written afterward (pure folder scaffolding), no separate sync is needed.

## MOC update rule

All managed MOC sections (`## Notes` in hub MOCs, `## Companies` and `## Research` in sector MOCs, `## Frameworks` and `## Sectors` in the root MOC) are auto-managed by `invest sync`. Do not edit them manually — sync will rewrite them on next run.

The ONE exception: `## Cross-sector` sections in sector MOCs are NOT auto-managed; edit those by hand.

## Sub-sectors

Optional within-sector grouping for the sector MOC's `## Companies` section. Sector MOC declares an allowed list (in render order); ticker hubs tag themselves with one or more of those values; `invest sync` renders `## Companies` grouped under H3 sub-headings.

**When to use**: a sector exceeds ~15-20 ticker folders and a flat list becomes hard to scan. **Only Photonics uses sub-sectors today.** Other sectors stay flat until they grow. Don't pre-bucket — let the taxonomy emerge from real captures.

**Schema**: both sector MOC and ticker hub frontmatter use the same key, `subsectors: [...]`. On the sector MOC the list defines allowed values + render order; on hubs it tags membership (multi-membership supported — list multiple if a name spans them honestly). Renaming or removing a value in the sector MOC requires editing every hub that uses the old value (sync errors out otherwise — see Validation below).

```yaml
# Sector MOC frontmatter (declares allowed values + order)
subsectors:
  - Substrates & epi-wafers
  - Foundries
  - Lasers
  - Optical components & engines
  - Networking systems
  - Equipment & test
```

**Sync behavior** when sector declares `subsectors:`:
- `## Companies` renders as H3 sub-sections in declared order
- Within each sub-section, hubs sort alphabetically
- Multi-tagged hubs appear in EVERY listed sub-section (no dedup — honest membership)
- Empty sub-sections suppressed (no heading rendered)
- `### Uncategorized` appended at the bottom only if any hub lacks `subsectors:`

When a sector has NO `subsectors:` declared, sync renders flat alphabetical (backwards-compatible — every other sector today).

**Validation**: sync errors hard if any hub uses a value not in the sector's allowed list. ALL errors collected before aborting (no MOCs modified on error). Each error names the hub + bad value, lists allowed values, suggests `Did you mean X?` via fuzzy match (when applicable), offers two fix paths (edit the hub, or extend the allowed list). `invest add-ticker --subsectors "..."` performs the same validation at create time.

**Escalation to sub-sector folders**: only consider promoting (`Photonics/Lasers/Lumentum (LITE)/`) when (a) a single sub-sector accumulates ~15+ tickers AND (b) you start wanting sub-sector-scoped `Research/` and `_media/` folders. Until both, frontmatter grouping covers it without folder reorganization, taxonomy lock-in, or per-name git move costs.

## Title convention

Titles must be **maximally informative** so future agents can triage by filename alone. Encode: topic + specific claim/angle + (when relevant) scope (year, source).

- ❌ Weak: `Goldman report.md`, `Photonics overview.md`, `Earnings recap.md`
- ✅ Strong:
  - `Goldman 2026 AI optical cheat sheet maps EPS upside across lasers PCBs and CCL manufacturers.md`
  - `Silicon photonics displaces EMLs in 800G+ datacenter optics by 2027 per Goldman teardown.md`
  - `LITE 2026-Q2 earnings - 800G ramp ahead of guide, China revenue down 18 pct QoQ.md`

Rule: someone reading only the filename should know the WHAT, the SO-WHAT, and roughly WHEN.

Applies to all content notes (Research/, sector overviews, cross-ticker analyses, ticker-folder notes). **Exception**: ticker hub MOCs use the bare folder name (e.g., `Lumentum (LITE).md`) — they're navigation, not content.

## Inside a ticker folder

Start with **flat files** alongside the hub MOC. Use the maximally-informative title convention for content notes. When a name accumulates 5+ notes spanning multiple categories, allow subfolders like `Earnings/`, `Theses/`, `Risk/` — discuss with the user before introducing the first subfolder for a ticker.

## Media (images, screenshots)

Captured sources often include images — they're part of the signal, capture them all.

**Where**: `Investing/<Sector>/_media/` — one `_media/` folder per sector, holding images for any note in that sector (Research/ AND ticker-folder notes). Create on first use.

**Naming** (consistent slug prefix per source so all images from one capture sort together; 1-indexed in source order):

- Tweets: `<author-handle>-<last-6-of-tweet-id>-NNN.<ext>` (matches `extract-tweet-images.sh` output)
- Articles / blog posts: `<domain-or-author>-<short-id>-NNN.<ext>`
- Research PDFs: `<first-author-or-paper-slug>-NNN.<ext>`

**Mandatory extraction**: not optional for sources that have images. Don't skip even if fetched markdown looks text-only — text extraction may have missed images. The `url-to-obsidian` skill provides extractors. Run AFTER determining destination sector so you target the right `_media/`.

**Strict no-orphans**: every image in `Investing/<Sector>/_media/` MUST be embedded in at least one note. Embed via `![[filename.ext]]` with a brief italic caption above:
```markdown
*Goldman 2026 optical supply-chain map (Sancet's annotations in red)*
![[million_sancet-579181-001.png]]
```
Delete non-content artifacts (profile pics, OG cards, decorative icons, tracking pixels) before commit. After writing the note, mechanically verify every image with the slug prefix appears in an `![[...]]` embed. Orphans signal an extraction-without-embed bug.

**Embedding placement**: in the note's **Original Content** section, place embeds at their natural positions in the source's flow. For images carrying key data (charts, tables-as-images), also reference them in **Key Takeaways**.

## Wiki linking

Cross-link liberally between ticker folders and sector `Research/` notes. Use inline `[[Note Name]]` style woven into prose. A `Research/` note discussing a cheat sheet should wiki-link every ticker mentioned (each link resolves to that ticker's hub MOC). A ticker-folder note should wiki-link back to relevant sector `Research/` notes. The hub MOC's `## Notes` section is itself a list of wiki links — auto-managed by sync.

## What this folder is NOT for

- **Short-term / systematic trading notes** → `Trading/` (different time horizon, different edge sources)
- **Prediction-market content** → `Prediction Markets/`
- **Pure macro / economics not tied to investable theses** → `Thinking/` or wherever appropriate
