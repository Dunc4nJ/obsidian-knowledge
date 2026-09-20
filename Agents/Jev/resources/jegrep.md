---
created: 2026-09-20
source: https://github.com/can1357/jegrep
type: resource
tags: [jev, jegrep, code-search, semantic-search, cli]
status: captured
description: Rust CLI that answers a plain-language code query by ranking files with a real ripgrep scan and then spending Jev Nouls on the top candidates in three escalating tiers, returning files and line ranges with no embeddings, no index and no daemon.
---

## What it is

A single-binary Rust CLI by Can Bölük (`@_can1357`, also the author of `oh-my-pi` and hashline) that behaves like `grep` but takes a description instead of a pattern: `jegrep "where do we verify JWT tokens?"`. It returns matching files *and* line ranges with original line numbers, ranked by probability, with `--json` output for coding agents. MIT licensed, created 19 September 2026, 34 stars at capture. Installs via `cargo install jegrep` or prebuilt binaries for five platforms.

The pitch is what it does *not* have: no embeddings, no index, no daemon, nothing to build or let go stale. It searches the live tree on every run and pays a fraction of a cent to a cheap classifier instead.

## Why it's interesting

It is the first application of TypeSafe's Jev to retrieval rather than to routing or eval scoring, and it arrives at the same primitive Harness-1 reached from the reranker direction: the relevance score is just a yes/no probability. The economics are the point. Jev bills $0.042 per million input tokens with output free, so a search over a few thousand files costs one to three cents, and the two measured queries in the announcement video cost $0.0042 and $0.0039 on an 8,177-file repository in about two seconds of wall clock.

The design choice worth studying is that Jev never sees the repository. A conventional ripgrep scan does the culling, and the model only reranks what the keyword prior surfaced. That keeps cost roughly flat in repo size and makes the tool stateless, at the price of a hard recall ceiling: a file whose vocabulary misses the query is invisible before the model is consulted.

## How it works

The default strategy is `cascade` in `src/strategies/cascade.rs`. Ten others are selectable with `--strategy`.

**Lexical prefilter, no model.** `grep::keywords_from_query` (`src/grep.rs:208`) keeps quoted phrases whole, drops stopwords and short tokens, and stems `ing`/`ed`/`es`/`s` when four characters remain. `grep::grep_index_observed` runs a real ripgrep-class scan using `grep-regex`, `grep-searcher` and `rayon` over a walker vendored from `pi-walker` in `oh-my-pi`, honouring nested gitignores and skipping files over 4 MiB. `window::idf` and `window::file_score` rank every file; the top `JEGREP_CASCADE_CANDIDATES` (default 128) survive.

**Tier one, filename Nouls.** `questions::dir_batch` renders those candidates as a grouped tree tagged `e000`, `e001`, …, and emits one `Noul` per entry against a single shared `state` carrying the task, the query, the tree text and yes/no criteria. Default 64 entries per request, capped at 128. Cascade rewrites the negative criterion so generated code is not penalized for being generated.

**Tier two, sketch routing.** The top 20 files are read and cut into up to 24 passages of 8 KiB. `cascade::sketch` compresses each to 384 bytes of the highest-IDF *verbatim* source lines, keeping their original line numbers. Cards from different files are packed together — `cards.chunks((18000 / sketch_bytes).clamp(1, 48))`, about 46 per request — with one Noul each. Anything under the 0.45 cutoff is dropped, and survivors are truncated to a global budget of 40 full passages.

**Tier three, full-source verification.** Surviving passages are read in full, every line prefixed `L0001|`, and judged with two questions in one call: a `relevant` Noul ("does the content actually contain it") and a `where` Choice over up to 16 line ranges keyed `R00`…, instructed to prefer where a thing is defined over where it is merely referenced. `questions::heat_from` turns the Choice distribution into the heatmap; `window::merge_heat` merges adjacent ranges. Sketch scores never produce hits — only full passages do.

**Batching and caps.** `main.rs:178` clamps `--max-batch` to 255 because Jev caps a Choice at 255 options; `--ranges` is clamped the same way. Sixteen requests in flight by default. `JEGREP_QUESTION_CHUNK` optionally splits independent Nouls into sub-requests sharing one state, at the cost of repeated state tokens.

**Thresholds and caching.** `-t 0.4,0.2` gives one threshold per round, where a later round reopens *cached* judgments at the lower bar, so lowering the bar is nearly free. That machinery drives the `baseline`, `beam` and `deep` tree strategies. Cascade sets `ctx.rounds = 1` and uses only the last threshold, so the default is a single pass.

**Cost.** `USD_PER_INPUT_TOKEN = 42.0 / 1e9` in `src/jev.rs:66`, output free. The client posts `{state, model, questions}` to OpenRouter's `/api/alpha/decisions` or TypeSafe's `/v1/systemone`, defaulting to `jev-latest`, retrying 429 and 5xx and failing over between providers when both keys are set.

**Benchmark harness.** `benches/` holds 40 labeled queries, ten each over pinned checkouts of CPython, Kubernetes, Linux and Postgres, plus a 27 KB Python runner and a 580-line results document scoring macro and micro file/region recall, line recall, precision lower bounds, cost and latency. The headline is `cascade` beating jegrep's own previous `window` default across 30 queries: 49/49 files, 93/94 regions, $0.145097 against $0.232162, or 37.5 percent less estimated cost.

## Key links

- [GitHub](https://github.com/can1357/jegrep) — the repository
- [Announcement post](https://x.com/_can1357/status/2101435662071185880) — with the screen recording showing $0.0042 per query
- [Mechanism reply](https://x.com/_can1357/status/2101439572152582235) — the active/passive file-explorer framing
- [oh-my-pi](https://github.com/can1357/oh-my-pi) — his harness, the `omp` of the post; jegrep vendors its walker and ports its native grep
- [TypeSafe docs](https://docs.typesafe.ai) — the Jev API
- [benches/RESULTS.md](https://github.com/can1357/jegrep/blob/main/benches/RESULTS.md) — the full benchmark writeup

## Notes

- **The tweet's Gemini comparison is not in the repo.** Searching the whole tree for Gemini, Flash, Lite, Google or agentic retrieval returns two hits, both filenames in an unrelated test query. Every comparison in `benches/RESULTS.md` is jegrep against jegrep. The "10x less cost than gemini-lite agentic-retrieval" claim rests on the tweet alone, which is consistent with his own hedge that he has "to benchmark a bit more."
- **Precision is a lower bound and it is low.** Gold labels are positive-only, so file precision floors land at 29.9 to 37.9 percent and the README states these numbers "cannot establish conventional false-positive rates." Recall is what is measured well.
- **Nothing calibrates the thresholds.** The README advertises calibrated absolute probabilities, and the code thresholds on 0.45 and 0.2. Compare [[jev-align]], which publishes no calibration error, and [[simple-jev]], which stamps its reconstructed probabilities uncalibrated.
- **Batching contrast with [[pg-jev]].** Both score one Noul per unit against a shared state, but pg-jev sends 20 rows per call while jegrep sends 64 filenames or about 46 sketch cards, tuned against the 255-option Choice ceiling.
- **Open question.** Whether cost stays flat on a repository far larger than the 8,177 files demonstrated. The 128/20/40 budgets are constants, so the model spend should not grow, but the ripgrep scan and the recall ceiling both will.
- Captured into [[Can Bölük's jegrep turns Jev into a semantic grep by scoring grep-ranked candidates with one Noul per file and a Choice for the line range - $0.004 a query, and the Gemini-lite comparison is nowhere in the repo]]. See [[moc - Jev]].
