---
created: 2026-09-20
source: https://github.com/hyperspaceai/jevcache
type: resource
tags: [jev, jevcache, memoization, caching, determinism, hyperspace, system-one-models, typesafe, rust]
status: captured
---

## What it is

`jevcache` is a decision ledger for Jev-class models from Hyperspace AI, launched 19 September 2026 by Varun Mathur. It treats a Jev decision as an approximately pure function of `(model, schema, state)` and memoizes it under a sha256 fingerprint, so a repeat of the same decision is served locally at 0ms for $0 instead of being billed again. It ships as one static binary of about 3 MB for macOS and Linux on arm64 or x64, plus a Windows x64 executable, with a `serve` mode exposing a local HTTP API so any language can use it.

The graduated knowledge note is [[Varun Mathur's jevcache memoizes Jev decisions by sha256 of model, schema and redacted canonical state - the 60 to 80 percent repeat rate is asserted and dropping user_id collides two subjects]].

## Why it's interesting

It is the first project in the vault's Jev cluster whose thesis is not *where to put the decision* but *whether to make it at all*. Every other Jev tool argues about placement in the stack. This one observes that a calibrated, low-variance, schema-fixed decision model is exactly the kind of function you can memoize, and that the cheapness of the model is not the same thing as the cheapness of a workload that asks it the same question repeatedly. The publish-and-merge story pushes further: a cache is shareable in a way a model call is not, so one team's decisions can become another's, and the roadmap turns that into a priced commons.

The repository is also a caution. **It contains no source code.** The tree is exactly two blobs, `README.md` and `og.png`; GitHub's language detection returns `{}` and there are no Actions workflows, so nothing publicly links the five published binaries to any source or build. The README's License section says jevcache is "free to use" with no LICENSE file and `license: null` on the API, and a commit landed on launch day, `812e8f2 readme: drop 'source is maintained privately' line`, removing the sentence that had said so out loud. The distributed artifact is a stripped binary whose behavior third parties have had to establish by black-box probing.

## How it works

Everything below is from the README and from two open issues whose authors reproduced the behavior against the shipped binary. **There is no source to read**, so the internals are documented behavior plus empirical fingerprint probes, not code.

**The key.** The site states the derivation directly:

```
key = sha256( model ⊕ schema ⊕ canonical( redact( state ) ) )
```

Redaction runs *before* canonicalization, and canonicalization before hashing, so the fingerprint is over what the README calls "decision-relevant content only." A per-schema `salt` is available for sensitive schemas, to stop outsiders enumerating which states a publisher has decided.

**What redaction drops.** The README names two classes: PII, meaning emails, phones and long digit runs, and volatile fields, meaning ids and timestamps. Issue #2 probed this field by field against `JEVCACHE_BACKEND=mock` and published the resulting fingerprints. Adding any of `user_id`, `id`, `uuid`, `session_id`, `request_id`, `trace_id`, `order_id`, `created_at`, `timestamp` or `updated_at` to a base state leaves the fingerprint unchanged at `21dca6618083`. Adding `idempotency_key`, `name`, `amount` or `email` each produces a distinct fingerprint. So subject identifiers are on the drop list alongside genuinely volatile trace fields, and two states differing only by `user_id` hash identically.

**The store.** An embedded, zero-dependency store described as an in-memory map plus an append-only log at `~/.jevcache` (overridable with `JEVCACHE_DIR`). A point lookup is a map access. The log file is `ledger.log`, one JSON row per decision.

**recall versus decide.** `recall()` consults the local ledger only and never touches a backend, which is what makes offline and CI replay deterministic; it exits **3** on a miss so CI can branch on it. `decide()` recalls first, and on a miss routes to the configured backend and caches the result forever.

**Backends.** Selected by `JEVCACHE_BACKEND`, one of `local`, `jev` or `mock`. The `jev` backend speaks TypeSafe's real `/v1/systemone` API using `TYPESAFE_API_KEY`, which the README says is never stored. `local` points at any endpoint matching the `{state, questions}` to `{answers}` shape, default `http://127.0.0.1:8080/v1/decide`. The README states jevcache "never proxies or resells inference (your key stays on your machine)."

**Serve.** `jevcache serve` binds `127.0.0.1:9000` by default and exposes two endpoints, so no library is needed in any language:

```
POST /decide  { schema, state }  → { answers, cached }   # caches on a miss
POST /recall  { schema, state }  → { hit, answers }      # never calls a backend
```

`JEVCACHE_SERVE_TOKEN` sets a bearer token required by `serve`, which is how a networked instance is meant to be protected.

**Schemas.** Loaded from `./jevcache.schemas.json` or `~/.jevcache/schemas/*.json`. State is a JSON file, or `-` for stdin, and a bare string is a valid state.

**The publish bundle.** `jevcache publish` writes one file per schema into `~/.jevcache/shared/`, named `<schema>.jevcache.json`, containing fingerprints and answers only and never raw state. `--gist` uploads it as a public gist using the `gh` CLI and prints a URL; `--schema` limits it to one schema; `--remote` pushes to the hosted index. On the receiving side `jevcache add <url>` merges a bundle and also registers the schema locally so `recall` and `decide` resolve it immediately. The README's stated defense against a hostile bundle is that "a bundle is plain JSON — inspect it before you add it"; there is no signature and no provenance check.

**The hosted commons.** A beta index at `https://jevcache.sh/api`, set by `JEVCACHE_API_URL`. Reads are open and keyless. Writes mint a free key, cached at `~/.jevcache/apikey` and settable as `JEVCACHE_API_KEY`, so decisions are attributable and no publisher can overwrite another's cache. `jevcache use` recalls from the index over the network. The README says only fingerprints and answers cross the wire.

**Full CLI surface.** Beyond the site's four commands the README documents `replay --cases cases.jsonl` for CI determinism and drift, `schemas` to list, and `stats` for hit rate and spend saved.

**Fingerprint compatibility.** The README claims "The CLI is written in Rust; its fingerprint is byte-identical to this repo's TypeScript core, so a Rust ledger, the TS internals, and the hosted commons all share the same keys." No TypeScript core exists in this repo, and neither does the `Dockerfile` the "Where it runs" section tells the reader to see.

## Key links

- [GitHub](https://github.com/hyperspaceai/jevcache) — distribution repo, README and `og.png` only, 52 stars and 2 forks as of 20 September 2026, no license file
- [jevcache.sh](https://jevcache.sh) — the launch site, single page
- [Install script](https://jevcache.sh/install) — 51 lines of `sh`, downloads `$BASE/bin/jevcache-<os>-<arch>` and verifies a sha256
- [Releases v0.1.0](https://github.com/hyperspaceai/jevcache/releases) — published 2026-09-19T17:44:40Z, five binaries plus five `.sha256` files
- [Issue #1](https://github.com/hyperspaceai/jevcache/issues/1) — `state_preview` persists unredacted credentials to a world-readable ledger
- [Issue #2](https://github.com/hyperspaceai/jevcache/issues/2) — no LICENSE, and `user_id`/`order_id` dropped before hashing
- [Launch tweet](https://x.com/varun_mathur/status/2101371145521905688)

## Notes

- **The two open issues are the most useful documentation of the internals that exists**, precisely because their authors could not read the source. Both are careful, both reproduce against the shipped binary, and both were filed within about 36 hours of launch. Neither had a maintainer reply at the time of capture.
- **`hit` appears inverted** in the JSON. Issue #2 reports that a miss returns `"cached":false,"hit":true` and a hit returns `"cached":true,"hit":false`, concluding that `cached` is the field tracking reality.
- **The ledger is mode 644** and carries a `state_preview` field holding roughly the first 200 characters of canonicalized state. The value-shape masker catches emails, phones and long digit runs but has no rule for credentials, so a bearer token or a password is stored verbatim and readable by every account on the machine. `jevcache serve` writes the same previews for every request it handles.
- **Binary sizes disagree slightly with the copy.** The site's install section says "about 2 MB" and the README says "~2-3 MB"; `jevcache-linux-x64` is 3,153,344 bytes.
- **Repo provenance.** Created 2026-09-18, three commits, all authored by "Supernova" and each carrying a `Co-Authored-By: Claude Fable 5` trailer. No CI, no release workflow; release v0.1.0's ten assets were uploaded rather than built in the open.
- **Name collision.** [kushals256/jevcache](https://github.com/kushals256/jevcache) is a different project by a different author, created 2026-09-19, TypeScript, 3 stars: an OpenAI-compatible local cache proxy shipped as `npx @kushalicious/jevcache` that skips LLM calls when Jev judges the intent unchanged. Not related to this one despite the identical name and launch week.
- **Sibling resources:** [[pg-jev]] caches per row content within a Postgres backend session, [[jegrep]] reopens cached judgments at a lower threshold across rounds, and [[jevlike]], [[simple-jev]] and [[jev-align]] cover the rest of the early ecosystem. The launch material lives under [[moc - Jev]].
