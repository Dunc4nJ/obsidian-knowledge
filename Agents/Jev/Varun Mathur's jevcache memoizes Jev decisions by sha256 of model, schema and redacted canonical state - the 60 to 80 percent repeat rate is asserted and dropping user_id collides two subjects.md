---
created: 2026-09-20
source: https://x.com/varun_mathur/status/2101371145521905688
site: https://jevcache.sh
author: Varun Mathur (Hyperspace AI)
published: 2026-09-19
type: knowledge
tags: [jev, jevcache, memoization, caching, determinism, hyperspace, system-one-models, typesafe]
description: Varun Mathur's jevcache treats a Jev decision as a pure function of model, schema and state, memoizing it under a sha256 of the redacted canonical state so repeats cost nothing and replay deterministically, and adds a publishable cache commons on top. The mechanism is sound and the pitch is the first in the Jev cluster to argue about whether to make a decision rather than where to put it, but the headline 60 to 80 percent repeat rate carries no source, the savings calculator's static markup shows half what its own script computes, the redactor drops user_id and order_id before hashing so two subjects share one cached answer, and the shipped ledger stores unredacted credentials world-readable in a repo that contains no source code.
---

# Varun Mathur's jevcache memoizes Jev decisions by sha256 of model, schema and redacted canonical state

Varun Mathur, founder and CEO of Hyperspace AI, launched jevcache on 19 September 2026 with a two-line tweet: the URL and a curl-pipe-sh install command. All the substance is on the single-page site, in the distribution repo's README, and in two open GitHub issues filed within 36 hours by third parties who had to establish the tool's behavior by black-box probing, because the repository ships no source. The resource note is [[jevcache]].

## Key Takeaways

- **This is the first project in the vault's Jev cluster that argues about whether to make a decision at all, rather than where to put it.** [[Josh Rosen's Jev in the Wild sorts week-one projects into routing, context filtering, tool gating, worker supervision, fast control loops and fuzzy data queries - deterministic only because inference was expensive|Rosen's six patterns]] are six answers to *where* you cut the line between deterministic code and a probabilistic decision, and his survey of 25 week-one projects does not contain jevcache or anything like it. Memoization is a seventh shape, and it is orthogonal to the other six: it wraps any of them. The premise is that a Jev decision is approximately a pure function of `(model, schema, state)`, which is only true because [[TypeSafe's Jev trades string generation for parallel-sampled typed decisions with calibrated probabilities at $0.042 per MTok - the 193x and 444x claims come from four self-built workflow evals|Jev fixes its output space before the call]] and samples in parallel rather than token by token. A string generator is not memoizable in this way, because the thing you would be caching is not a decision.
- **Low variance is what makes the cache coherent and also what makes it least necessary.** [[LangChain's Jev-as-a-Judge bench puts Jev's quality-score variance 92 to 913x below three LLM judges at $0.34 against Claude's $28.17 - five weather traces, one human oracle, provider-default sampling|LangChain's judge bench]] measured Jev's per-case quality variance at 92 to 913x below three LLM judges, which is the property that makes a cached answer a faithful stand-in for a fresh call. The same property undercuts the determinism pitch: if repeated calls already agree, "same input, same answer" is close to what you get without a cache, and the honest reason to install one is cost, not reproducibility. The site half-concedes this by putting latency last, noting the 0ms hit is "the bonus" rather than the point, which is the right call given that Jev already returns in 70ms to 500ms.
- **The 60 to 80 percent repeat rate is the load-bearing number and it has no source anywhere.** It appears on the site, in Varun's own self-reply, and nowhere else. No dataset, no workload, no methodology, no citation. The savings calculator hardens it into a specific 78.4 percent, and every dollar figure on the page is that assumption multiplied out. The per-decision cost holds up better: the calculator's $0.0004 is within 14 percent of the $0.00035 per call LangChain actually measured. The problem is that the site's own demo transcript prints `$0.000042` for routing a support ticket, ten times less, which at Jev's $0.042 per MTok is a 1,000-token state against the calculator's implied 9,500. The demo and the calculator disagree by an order of magnitude about what a decision costs.
- **The savings figure in the shipped markup is exactly half what the page's own script computes.** The static HTML renders `$4,704` per month at 1M decisions/day, which is what a reader without JavaScript sees and what every markdown extractor captures. The inline script sets `HITRATE=0.784, COST=0.0004` and computes `v*HITRATE*COST*30`, which is $9,408, and that is what a live browser displays once the count-up animation settles. One of the two numbers is wrong and the page does not know which; the discrepancy is a clean factor of two.
- **Redaction improves the hit rate by collapsing distinct subjects into one fingerprint, and that is a correctness bug, not a privacy feature.** The README scopes redaction to PII and "volatile fields (ids, timestamps)". Issue #2 probed the canonicalizer field by field against the mock backend and found that `user_id`, `order_id`, `session_id`, `id`, `uuid`, `request_id` and `trace_id` all leave the fingerprint unchanged, while `amount`, `name`, `email` and `idempotency_key` each change it. Two states differing only by `user_id` hash identically, so Bob receives a decision computed for Alice, returned flagged as a hit with no warning and no way to pin a field. Dropping a ticket id is defensible noise reduction; dropping the subject of "is this user allowed to do this" deletes the question. The same mechanism inflates the repeat rate the whole pitch rests on.
- **"Private by design" describes the key, not the disk.** Both issues make the same structural observation from different angles: redaction rules sufficient for a fingerprint were inherited by at-rest storage without being designed for it. The ledger keeps a `state_preview` of roughly the first 200 characters of canonicalized state in a mode-644 file, and the masker is value-shape based, so it catches emails, phones and long digit runs but stores `authorization: Bearer …` and `password: …` verbatim, readable by every account on the machine. `jevcache serve` writes the same previews for every request it handles, so wiring an app through the local HTTP API accumulates them at request volume. Note the contrast with [[pg-jev]], which keys on row content inside a Postgres backend session and dies with the connection, holding nothing on disk at all.
- **The shared commons is the ambitious half and the least defended.** Reads are open and keyless, `add` merges a bundle with no signature and no provenance check, and the README's stated defense is that a bundle is plain JSON so you should inspect it first. Issue #2 points out the second-order problem: because identifiers are stripped, fingerprints are more predictable than they would otherwise be, so a bundle asserting a chosen answer for a chosen state is easier to construct. The roadmap then turns this into "per-recall pricing so publishers can charge for a cache", which makes cached Jev outputs a resale market, and whether TypeSafe's terms permit reselling decisions produced by their model is unaddressed. The README's "never proxies or resells inference" covers the binary's own behavior, not the commons built on top of it. The decentralized index is to run over the Hyperspace P2P network, which ties directly to Mathur's [[peer-to-peer world models create collective intelligence that scales superlinearly with network size|superlinear collective intelligence thesis]] and is the clearest signal that jevcache is a Hyperspace distribution play rather than a standalone tool.
- **Model-version drift is sold as solved and is the staleness bug.** The key includes `model`, so the cache is correct exactly as long as that string changes when the weights do. The site markets "no model-version drift" as a replay guarantee, which is true for a pinned version and false the moment a caller passes a floating alias: TypeSafe ships a new Jev, the model string is unchanged, and `recall()` keeps returning the old model's answers forever with `cached: true`. There is no expiry, no TTL and no invalidation verb documented anywhere. `jevcache replay --cases cases.jsonl` is offered to *detect* drift in CI, which quietly concedes that the ledger cannot prevent it.
- **The repository contains no source code, and the sentence admitting that was deleted on launch day.** The tree is two files, `README.md` and `og.png`. Commit `812e8f2`, landed 19 September, is titled `readme: drop 'source is maintained privately' line` and removes exactly that clause from the License section, leaving "free to use" with no LICENSE file and `license: null` on the API. The README still claims the Rust CLI's "fingerprint is byte-identical to this repo's TypeScript core" and tells the reader to "See `Dockerfile`"; neither exists in the repo. So the artifact is a stripped 3 MB binary installed by curl-pipe-sh, which will hold your redacted decision fingerprints, mint hosted-index write keys to `~/.jevcache/apikey`, and accept your `TYPESAFE_API_KEY`. The installer does verify a published sha256, but that only proves you received the binary the site meant to send. Issue #2 closes by asking whether the source will be published, noting the author "would rather have read the canonicaliser than guessed at it from fingerprints"; at capture, neither issue had a maintainer reply.

## How the Cache Works

**The key.** The site states the derivation in one line:

```
key = sha256( model ⊕ schema ⊕ canonical( redact( state ) ) )
```

Redaction runs before canonicalization, canonicalization before hashing. The site describes the effect as masking "emails, phones, and ids by default, more via schema policy", and says only a fingerprint and the answer ever leave the machine, never raw state. For sensitive schemas a per-schema `salt` prevents outsiders enumerating which states a publisher has decided.

**What the canonicalizer actually does** is not documented. There is no published rule for whitespace handling, key ordering or number formatting, and no source to read. What is known comes from issue #2's probe table, reproduced against `JEVCACHE_BACKEND=mock` with a one-question schema:

| field added to base state | fingerprint |
| --- | --- |
| *(base)* | `21dca6618083` |
| `user_id`, `id`, `uuid` | `21dca6618083` |
| `session_id`, `request_id`, `trace_id` | `21dca6618083` |
| `order_id` | `21dca6618083` |
| `created_at`, `timestamp`, `updated_at` | `21dca6618083` |
| `idempotency_key` | `c80feff6a382` |
| `name` | `8a2bd81a1ca2` |
| `amount` | `8ad234e13558` |
| `email` | `d84b9680fb4c` |

**recall versus decide.** `recall()` reads the local ledger only and never contacts a backend, which is what makes offline and CI replay deterministic. It exits **3** on a miss so CI can branch on it. `decide()` recalls first and, on a miss, routes to the configured backend and caches the answer permanently.

**Backends.** `JEVCACHE_BACKEND` selects `local`, `jev` or `mock`. The `jev` backend speaks TypeSafe's real `/v1/systemone` API with `TYPESAFE_API_KEY`; `local` points at any `{state, questions}` to `{answers}` endpoint, defaulting to `http://127.0.0.1:8080/v1/decide`.

**Serve.** One binary, an HTTP API, no library in any language:

```bash
# start the cache (points at your model via JEVCACHE_BACKEND)
$ jevcache serve
jevcache serving on http://127.0.0.1:9000
```

```javascript
// then, from your app — schema is inline, nothing to pre-register
const res = await fetch("http://localhost:9000/decide", {
  method: "POST",
  body: JSON.stringify({ schema, state: ticket }),
})
const { answers, cached } = await res.json()
// first call routes to your model and caches it; every repeat comes back cached.
```

The README documents both endpoints:

```
POST /decide  { schema, state }   → { answers, cached }   # caches on a miss
POST /recall  { schema, state }   → { hit, answers }       # never calls a backend
```

Issue #2 reports `hit` is inverted, with a miss returning `"cached":false,"hit":true`, and concludes `cached` is the field that tracks reality.

**The full CLI**, from the README, which is wider than the site lets on:

```bash
jevcache demo                                                 # try it in one command (no setup)
jevcache decide  --schema support.route --state ticket.json   # decide (cache on miss)
jevcache recall  --schema support.route --state ticket.json   # local only; exit 3 on miss
jevcache serve   [--host 0.0.0.0] [--port 9000]               # local decide/recall HTTP API
jevcache publish                                              # bundle your cache(s) to share
jevcache add     https://…/route.jevcache.json                # merge someone else's cache
jevcache replay  --schema eval.triage   --cases cases.jsonl   # CI determinism / drift
jevcache schemas                                              # list schemas
jevcache stats                                                # hit rate, spend saved
```

**Where it runs.** Three shapes: `jevcache serve` as a sidecar on localhost for a long-running app; a hosted instance behind `JEVCACHE_SERVE_TOKEN` for serverless and edge functions that have no daemon to run; and the bare binary for scripts and CI.

```bash
# host it as a shared cache for your serverless functions
$ docker run -p 9000:9000 -e JEVCACHE_BACKEND=jev -e JEV_API_KEY=… \
    -e JEVCACHE_SERVE_TOKEN=secret jevcache
```

Note the site's docker line uses `JEV_API_KEY` while the README's table names the variable `TYPESAFE_API_KEY`.

**Install.** The 51-line script picks `darwin` or `linux` and `arm64` or `x64`, downloads `$BASE/bin/jevcache-$o-$a` where `BASE` defaults to `https://jevcache.sh`, fetches `$url.sha256` and compares, installs to the first writable directory among `~/.local/bin` and `/usr/local/bin`, and posts to `$BASE/api/event/install` as an anonymous counter. The checksum step is conditional: if the `.sha256` fetch fails, `want` is empty and the comparison is skipped entirely rather than aborting. `jevcache-linux-x64` is 3,153,344 bytes, against the site's "about 2 MB".

## The Math and Its Assumptions

The calculator offers four volumes and defaults to 1M decisions/day. Its footnote reads: "assumes a 78% recurrence rate and ~$0.0004 / decision (Jev's own benchmark) · your numbers, your ledger."

| quantity | value |
| --- | --- |
| recurrence rate in the script | 0.784 |
| cost per decision in the script | $0.0004 |
| decisions/day served from cache at 1M/day | 784,000 |
| monthly saving in the static HTML | $4,704 |
| monthly saving the script computes and a browser renders | $9,408 |
| LangChain's measured Jev cost per call | $0.00035 |
| the site's own demo transcript, per decision | $0.000042 |

The script is `var HITRATE=0.784, COST=0.0004;` and `savedMo = v*HITRATE*COST*30`. At 1M/day that is $9,408, confirmed in a live browser once the animation settles. The server-rendered fallback in the markup says $4,704.

"Jev's own benchmark" is not linked. The nearest independent figure in the vault is LangChain's, and $0.0004 sits comfortably beside it, so the per-decision assumption is the sound part. The recurrence rate is not: 78.4 percent is a hardened version of a 60 to 80 percent range that appears without provenance, and it is the term every dollar figure scales with linearly.

## Sharing and the Hosted Index

`jevcache publish` bundles what the ledger already holds, one file per schema under `~/.jevcache/shared/`, containing fingerprints and answers only:

```bash
# bundle every cache you've built (or --gist to upload now)
$ jevcache publish
bundled support.route.v3@3  1,284 decisions → ~/.jevcache/shared/…

# or push to the hosted global index — a free write key is minted for you
$ jevcache publish --remote

# them: one command, and recall() hits your decisions — no backend
$ jevcache add https://…/route.jevcache.json   # or: jevcache use …
```

Reads are open and keyless. Writes mint a free key, cached at `~/.jevcache/apikey`, so decisions are attributable and no publisher can overwrite another's. `add` also registers the schema locally. The hosted index sits at `https://jevcache.sh/api`, overridable with `JEVCACHE_API_URL`; the bare base URL returns a Vercel 404, so it is reachable only at its subpaths.

The roadmap has three rows, two marked "now" and one "beta": local reuse; publish and add over files or gists; and the hosted global index, with "Next: a decentralized index over the Hyperspace P2P network, and per-recall pricing so publishers can charge for a cache."

This is the piece with no analogue elsewhere in the Jev cluster. [[pg-jev]] caches per row content in a backend session and shares nothing. [[Can Bölük's jegrep turns Jev into a semantic grep by scoring grep-ranked candidates with one Noul per file and a Choice for the line range - $0.004 a query, and the Gemini-lite comparison is nowhere in the repo|jegrep]] reopens cached judgments at a lower threshold across rounds of one query. Both are private and ephemeral by construction. A published, content-addressed, keyless-read commons of model outputs is a different object, and the closest thing the vault holds on making content-addressed shared logs trustworthy is [[Chroma's wal3 ports the 1996 Michael-Scott lock-free queue onto S3 conditional writes and builds the log twice - once for data, once for a setsum that proves it correct|Chroma's wal3]], which builds its log twice so a setsum can prove it correct. jevcache's bundles carry no such proof.

## The Author's Replies

Varun Mathur made exactly one reply in the thread, a self-reply posted 36 seconds after the launch tweet, which is where the entire cost argument lives:

> Jev made decisions fast and cheap. It didn't make the repeats free.
>
> Agents, retries, idempotent tools: 60–80% of decisions are the same input over and over.
>
> You pay every time. jevcache fixes that.

He answered none of the questions put to him. Nothing in the thread addresses what the backend is, where the hosted index runs, how redaction works, whether the source will be published, or pricing. The two GitHub issues asked the same questions in more detail and were also unanswered at capture.

## Other Replies

Fifteen replies were returned against the 19 the tweet reports. Most are reactions. Four are substantive, and three of those converge on the same question.

**Why isn't this the model provider's job?** Jeremiah (@harveyfullstack) asked "Why isn't Jev's servers doing this?" and Shahn (@shahin43) worked through the consequence: "well Jev could be implementing same feature server side right ?? it would become still some cache hit and cost, not 0\$ though." That is the sharpest point anyone made. A provider-side cache is strictly easier to keep coherent, since the provider knows when the model version changes, and it collapses the entire correctness problem that issue #2 documents. What it cannot give you is $0, offline replay, or a cache you own and can publish, which is the real answer and one nobody supplied.

**Pooling everyone's decisions.** DODO (@DODO02806602) proposed "how about we host on server and megacache everyone using jev", which is the hosted commons already shipped in beta, arrived at independently within 90 minutes of launch. It is also the poisoning surface, and the reply treats it as an unambiguous good.

**The prior art.** Raymond Weitekamp (@raw_works) connected it backwards: "after ~3 years i think i finally now understand why the cache defaults to on in @DSPyOSS." DSPy has cached LM calls by default for years, which makes jevcache's contribution the decision-shaped key and the sharing layer rather than memoization itself. The same instinct runs through [[prompt caching is the foundational constraint for building long-running agents]] and [[six cache-friendly patterns from Claude Code make prompt caching practical for production agents]], though both concern prefix reuse inside one provider's billing rather than a durable answer ledger, and [[Hermes Agent prioritizes prompt caching stability by keeping hot memory tiny and pushing everything else to tool-based retrieval]] shows how far a system will bend its architecture to protect a cache. jevcache is the same economic pressure that [[context tax compounds through cache misses bloated tools and unbudgeted output tokens]] describes, applied to a model whose output is small enough to store forever.

**Where would you use it.** Naman Arora (@palindrome_guy) asked "where do you think this will be mostly used?" and got no answer. Am.E (@BuildToCite) quote-tweeted their own framing of Jev as replacing "the calls that act like a smart <if/else>", and Rohan Arun noted "you can use any classifier here", which is true and points at the same gap [[Featherless's Simple Jev reproduces Jev's API on stock open models by remapping every answer to a single-token letter and softmaxing only those logits - no classifier head, and the code stamps every answer calibrated False|Simple Jev]] exposes: nothing in the cache design is specific to Jev, only to decisions with a fixed output space.

Eight replies were reactions with no content: @yikesawjeez (a hiring enquiry), @CobaltHere ("Gonna test this!"), @phanindra_ai, @MatOrzelowski, @purpose_walker, @Lord_iskandar, @Shex005, and @RohanArun's link. Four of the 19 replies the tweet counts were not returned by the fetch, most likely deleted or from protected accounts.

## Related

The full Jev cluster sits under [[moc - Jev]]. Beyond the notes linked above, [[Daniel Ch's How to master Jev prescribes a 0.85 and 0.55 confidence-gate ladder under an LLM that still writes - the decision-layer architecture is additive but every number and all three charts are TypeSafe's own|Daniel Ch's guide]] cuts against caching in an interesting way: its advice to "abuse parallel questions" pushes toward one call carrying many questions over a shared state, which is the opposite granularity from a per-question ledger and would make each fingerprint rarer and each hit less likely. [[Annabell frames TypeSafe's Jev as a savant for eval verdicts and routing - three question types, 255 choices, 10 score levels, and a Noul with no confidence field|Annabell's note]] supplies the constraint that matters most for a permanent cache: Jev cannot abstain and returns no rationale, so a wrong decision is cached with the same confidence as a right one and nothing in the ledger records why it was made. [[Cua keeps the candidate menu in application code so Jev only picks an ID - CUA-S1-FORMS is a 706K-parameter form specialist at 99.7 percent against hosted Jev's 83.6, and neither model sees pixels|Cua]] and [[LangChain's Sydney Runkle puts Jev inside the agent loop as classifier middleware - ModelRouterMiddleware picks the model from the latest user message and AutoModeMiddleware reproduces closed harnesses' dangerous-action gate|LangChain's classifier middleware]] are the two placements a cache would most plausibly wrap, and [[Sutro's jev-align uses GEPA to rewrite Jev's decision criteria from five labeled examples - the demo moves labeled-set ambiguity 49.6 points but full-pool certainty only 0.5|jev-align]] is the reason to be careful about permanence, since rewriting a schema's criteria should invalidate every fingerprint derived from it and the key covers only the schema, not the instructions inside it. The resource notes are [[jevcache]], [[pg-jev]], [[jegrep]], [[jevlike]], [[simple-jev]] and [[jev-align]].

## Links

- [Launch tweet](https://x.com/varun_mathur/status/2101371145521905688) — Varun Mathur, 19 September 2026, 483 likes and 51 retweets at fetch
- [jevcache.sh](https://jevcache.sh) — the single-page launch site
- [jevcache.sh/install](https://jevcache.sh/install) — the 51-line installer
- [github.com/hyperspaceai/jevcache](https://github.com/hyperspaceai/jevcache) — distribution repo, README and og.png only, 52 stars
- [Release v0.1.0](https://github.com/hyperspaceai/jevcache/releases) — 19 September 2026, five binaries plus checksums
- [Issue #1](https://github.com/hyperspaceai/jevcache/issues/1) — `state_preview` persists unredacted credentials to a world-readable ledger
- [Issue #2](https://github.com/hyperspaceai/jevcache/issues/2) — no LICENSE, and `user_id`/`order_id` dropped before hashing
- [TypeSafe Jev](https://typesafe.ai/blog/introducing-system-one-models-and-jev) — the model jevcache caches

## Original Content

> [!quote]- Original Content
>
> #### The tweet — @varun_mathur, 19 September 2026 18:01 UTC
>
> 483 likes · 51 retweets · 19 replies at fetch. No media, no quote tweet.
>
> > introducing https://jevcache.sh
> >
> > curl -fsSL https://jevcache.sh/install | sh
>
> #### jevcache.sh — the full page
>
> ```
> Title: jevcache — compute the decision once, remember it forever
>
> URL Source: https://jevcache.sh
>
> Markdown Content:
> ---
> description: Jev returns a typed decision in milliseconds. jevcache memoizes it by (model, schema, state) so the same decision never runs — or bills — twice. Repeats are free, deterministic, and shareable.
> title: jevcache — compute the decision once, remember it forever
> image: https://jevcache.sh/og.png
> ---
> ```
>
> jevcache — compute the decision once, remember it forever
>
> 0ms
>
> a local hit — no round-trip, no inference
>
> $0
>
> every repeat you don't pay for again
>
> 100%
>
> deterministic — same input, same answer, in CI
>
> why cache a model this fast?
>
> ##### The cost isn't the model. It's asking it the same thing twice.
>
> Fast and cheap per call isn't free at volume — or reproducible. Three things a faster model can't give you:
>
> 01 / FREE AT VOLUME
>
> ###### Repeats are the norm
>
> **60–80% of an agent's decisions repeat** — loops, retries, idempotent tools, heavy-tailed inputs. Every repeat is another bill. A cache hit costs $0.
>
> 02 / DETERMINISTIC
>
> ###### Same input, same answer
>
> Pin the exact decision — replay it in CI, offline, with **no network and no model-version drift**. The reproducibility real systems demand.
>
> 03 / SHAREABLE
>
> ###### A model call can't be shared
>
> A cache can. Publish one and anyone recalls against it — **one team's decisions become everyone's**, over a file or the hosted index.
>
> Latency? A local hit returns in **~0ms**, in-process, no round-trip at all. That's the bonus. The point is you stop re-deciding what you've already decided.
>
> the math
>
> ##### What those repeats add up to
>
> Pick your volume. This is what memoization keeps off the bill.
>
> 100K / day 1M / day 10M / day 100M / day
>
> 784,000
>
> decisions/day served from cache, never re-run
>
> $4,704
>
> per month you don't spend re-deciding
>
> assumes a 78% recurrence rate and ~$0.0004 / decision (Jev's own benchmark) · your numbers, your ledger
>
> how it works
>
> private by designstate is redacted then canonicalized **before** it's hashed — emails, phones, and ids are masked by default, more via schema policy. Only a fingerprint and the answer ever leave your machine, never raw state. For sensitive schemas, a per-schema **salt** keeps outsiders from enumerating which states you've decided.
>
> offline & exactreplay every fingerprint you've already seen — zero network, deterministic CI. recall() checks the ledger only, never a backend.
>
> any backendyour own model, TypeSafe Jev, or OpenRouter. the Jev backend speaks the real /v1/systemone API; a miss routes to whichever you point at, then caches it forever.
>
> key = sha256( model ⊕ schema ⊕ canonical( redact( state ) ) ) a hit returns in 0ms for $0 — the same decision never runs twice.
>
> share a cache
>
> ##### Sharing a cache is free
>
> One command bundles what you've already decided — fingerprints and answers only, never raw state. Host the file anywhere, or push to the hosted index.
>
> ```bash
> # bundle every cache you've built (or --gist to upload now)
> $ jevcache publish
> bundled support.route.v3@3  1,284 decisions → ~/.jevcache/shared/…
>
> # or push to the hosted global index — a free write key is minted for you
> $ jevcache publish --remote
>
> # them: one command, and recall() hits your decisions — no backend
> $ jevcache add https://…/route.jevcache.json   # or: jevcache use …
> ```
>
> Reads are open and keyless. Writes mint a free key so decisions are attributable and **no one can overwrite another publisher's cache**. Per-recall pricing is coming — free for now.
>
> roadmap
>
> now
>
> Re-use your own cacheEvery decision is memoized locally. recall() returns a prior answer in 0ms for $0. Deterministic replay in CI.
>
> now
>
> Find, use & share cachesjevcache publish bundles your cache; jevcache add <url> merges someone else's. Files or gists — no server, no accounts.
>
> beta
>
> Global cache indexA hosted index is live — publish --remote pushes, use recalls, one commons keyed by fingerprint. Next: a decentralized index over the Hyperspace P2P network, and per-recall pricing so publishers can charge for a cache.
>
> in your app
>
> ##### Run it once, call it from anywhere
>
> The same binary runs as a local cache your app talks to over HTTP. No library to install, no per-call process to spawn, and it works from any language — you just POST a schema and some state.
>
> ```bash
> # start the cache (points at your model via JEVCACHE_BACKEND)
> $ jevcache serve
> jevcache serving on http://127.0.0.1:9000
> ```
>
> ```javascript
> // then, from your app — schema is inline, nothing to pre-register
> const res = await fetch("http://localhost:9000/decide", {
>   method: "POST",
>   body: JSON.stringify({ schema, state: ticket }),
> })
> const { answers, cached } = await res.json()
> // first call routes to your model and caches it; every repeat comes back cached.
> ```
>
> Prefer the command line? jevcache decide --schema … --state ticket.json --json does the same thing, and recall exits 3 on a miss for CI.
>
> where it runs
>
> ##### A cache needs to live somewhere. Pick the shape that fits.
>
> jevcache is one binary. Where you point your app at it depends on how your app is deployed.
>
> A LONG-RUNNING APP
>
> ###### Sidecar on localhost
>
> Your own server, a container, a worker? Run jevcache serve next to it and call http://localhost:9000. Nothing leaves the box.
>
> SERVERLESS / EDGE
>
> ###### Point at a hosted instance
>
> Vercel functions, Cloudflare, Lambda — there's no daemon to run in an ephemeral function. Host jevcache once (docker run, Fly, Railway) with a token, and your functions call it over HTTPS. Your state and model key stay on **your** instance.
>
> SCRIPTS / CI
>
> ###### Call the binary
>
> No server at all — jevcache decide / recall read and write the local ledger. recall exits 3 on a miss, so CI can branch on it.
>
> ```bash
> # host it as a shared cache for your serverless functions
> $ docker run -p 9000:9000 -e JEVCACHE_BACKEND=jev -e JEV_API_KEY=… \
>     -e JEVCACHE_SERVE_TOKEN=secret jevcache
>
> # then from a Vercel function — same call, remote host
> await fetch("https://cache.yourapp.com/decide", { method:"POST",
>   headers:{ authorization:"Bearer secret" }, body: JSON.stringify({ schema, state }) })
> ```
>
> install
>
> ##### A single binary, about 2 MB
>
> $ curl -fsSL jevcache.sh/install | sh copy
>
> ```bash
> # then see it work in one command — no schema, no key, no setup
> $ jevcache demo
> ticket T-1001  decide()  →  "billing"   routed to the model · $0.000042
> ticket T-2087  decide()  →  "billing"   cache HIT · 0ms · $0
> ```
>
> One static binary on your PATH — no Node, no Python, nothing to keep updated. macOS & Linux (arm64/x64); on Windows, grab [jevcache-windows-x64.exe](/bin/jevcache-windows-x64.exe).
>
> #### jevcache.sh/install — the installer, verbatim
>
> ```sh
> #!/bin/sh
> # jevcache installer — downloads a single static binary. No runtime required.
> #   curl -fsSL jevcache.sh/install | sh
> set -e
>
> BASE="${JEVCACHE_BASE:-https://jevcache.sh}"
> os=$(uname -s)
> arch=$(uname -m)
> case "$os" in
>   Darwin) o=darwin ;;
>   Linux)  o=linux ;;
>   *) echo "jevcache: unsupported OS '$os'. See $BASE" >&2; exit 1 ;;
> esac
> case "$arch" in
>   arm64|aarch64) a=arm64 ;;
>   x86_64|amd64)  a=x64 ;;
>   *) echo "jevcache: unsupported architecture '$arch'." >&2; exit 1 ;;
> esac
> name="jevcache-$o-$a"
> url="$BASE/bin/$name"
>
> # pick a writable bin dir on PATH, else ~/.local/bin
> BIN=""
> for d in "$HOME/.local/bin" "/usr/local/bin"; do
>   if [ -d "$d" ] && [ -w "$d" ]; then BIN="$d"; break; fi
> done
> [ -z "$BIN" ] && BIN="$HOME/.local/bin"
> mkdir -p "$BIN"
>
> tmp=$(mktemp)
> echo "downloading $name..."
> curl -fsSL "$url" -o "$tmp"
>
> # verify checksum
> want=$(curl -fsSL "$url.sha256" 2>/dev/null | awk '{print $1}')
> if [ -n "$want" ]; then
>   if command -v shasum >/dev/null 2>&1; then got=$(shasum -a 256 "$tmp" | awk '{print $1}');
>   else got=$(sha256sum "$tmp" | awk '{print $1}'); fi
>   if [ "$want" != "$got" ]; then echo "jevcache: checksum mismatch — aborting." >&2; rm -f "$tmp"; exit 1; fi
> fi
>
> chmod +x "$tmp"
> mv "$tmp" "$BIN/jevcache"
> # anonymous install counter (best-effort, no data collected beyond a bump)
> curl -fsS -m3 "$BASE/api/event/install" >/dev/null 2>&1 || true
> echo "installed jevcache → $BIN/jevcache"
> case ":$PATH:" in
>   *":$BIN:"*) : ;;
>   *) echo "note: add $BIN to your PATH:  export PATH=\"$BIN:\$PATH\"" ;;
> esac
> "$BIN/jevcache" version >/dev/null 2>&1 && echo "run 'jevcache' to get started." || true
> ```
>
> #### github.com/hyperspaceai/jevcache — README.md, verbatim
>
> The repository's only two files are this README and `og.png`.
>
> ```markdown
> # jevcache
>
> **The decision ledger for Jev-class models.** A Jev decision is (approximately) a pure
> function of `(model, schema, state)` — so it's memoizable. jevcache caches those
> decisions locally: same decisions, fewer bills, and deterministic replay in CI. It's
> backend-agnostic — point it at any local decision endpoint, a hosted Jev provider, or
> a mock — and it never proxies or resells inference (your key stays on your machine).
>
> - **Local-first & offline.** An embedded, zero-dependency store (in-memory map +
>   append-only log). A point lookup is a map access — instant.
> - **Private by construction.** State is redacted and canonicalized *before* it's
>   hashed, so the fingerprint is over decision-relevant content only; PII (emails,
>   phones, long digit runs) and volatile fields (ids, timestamps) never enter the key.
>   For sensitive schemas, a per-schema `salt` keeps outsiders from enumerating decided states.
> - **Deterministic CI.** Publish fixtures, `replay` them, catch model drift.
>
>
> > **This is the distribution repo** — the `jevcache` CLI binary and docs.
> > Install with `curl -fsSL jevcache.sh/install | sh`, or download a binary from [Releases](https://github.com/hyperspaceai/jevcache/releases).
>
> ## Install
>
> ```bash
> curl -fsSL jevcache.sh/install | sh
> ```
>
> Installs a single static binary (~2–3 MB, no runtime) for macOS/Linux, arm64 or x64.
> The installer verifies a SHA-256 checksum before installing. `recall()` checks the local
> ledger only (never a backend); `decide()` recalls, then on a miss routes to your configured
> backend (`JEVCACHE_BACKEND=local|jev|mock`) and caches the result.
>
> The CLI is written in Rust; its fingerprint is byte-identical to this repo's TypeScript
> core, so a Rust ledger, the TS internals, and the hosted commons all share the same keys.
>
>
> ## CLI
>
> ```bash
> jevcache demo                                                # try it in one command (no setup)
> jevcache decide  --schema support.route --state ticket.json   # decide (cache on miss)
> jevcache recall  --schema support.route --state ticket.json   # local only; exit 3 on miss
> jevcache serve   [--host 0.0.0.0] [--port 9000]              # local decide/recall HTTP API
> jevcache publish                                              # bundle your cache(s) to share
> jevcache add     https://…/route.jevcache.json                # merge someone else's cache
> jevcache replay  --schema eval.triage   --cases cases.jsonl   # CI determinism / drift
> jevcache schemas                                              # list schemas
> jevcache stats                                                # hit rate, spend saved
> ```
>
> Schemas load from `./jevcache.schemas.json` or `~/.jevcache/schemas/*.json`. State is a
> JSON file (or `-` for stdin; a bare string is a valid state). `recall` exits **3** on a
> miss so CI can branch on it.
>
> ## Where it runs
>
> - **A long-running app** — run `jevcache serve` as a sidecar and call `http://localhost:9000`.
> - **Serverless / edge** (Vercel, Cloudflare, Lambda) — no daemon in an ephemeral function, so
>   host jevcache once (`docker run`, Fly, Railway) with `JEVCACHE_SERVE_TOKEN`, and your
>   functions call it over HTTPS. See `Dockerfile`.
> - **Scripts / CI** — call the binary directly.
>
> ```bash
> POST /decide  { schema, state }   → { answers, cached }   # caches on a miss
> POST /recall  { schema, state }   → { hit, answers }       # never calls a backend
> ```
>
> ## Config (env)
>
> | Var | Default | Purpose |
> |---|---|---|
> | `JEVCACHE_BACKEND` | `local` | `local` \| `jev` \| `mock` |
> | `TYPESAFE_API_KEY` | — | your key for the `jev` backend (`POST /v1/systemone`; never stored) |
> | `JEVCACHE_LOCAL_URL` | `http://127.0.0.1:8080/v1/decide` | local decision endpoint (`{state,questions}`→`{answers}`) |
> | `JEVCACHE_DIR` | `~/.jevcache` | ledger + schemas location |
> | `JEVCACHE_HOST` / `JEVCACHE_PORT` | `127.0.0.1` / `9000` | `serve` bind address |
> | `JEVCACHE_SERVE_TOKEN` | — | bearer token required by `serve` when set (for a networked instance) |
>
> ## Share a cache
>
> Sharing needs no server. `jevcache publish` bundles the caches already in your ledger —
> one file per schema, holding fingerprints and answers only, never raw state. Host the file
> anywhere; anyone merges it with `jevcache add` and their `recall()` starts hitting your
> decisions.
>
> ```bash
> # you: bundle every cache you've built
> jevcache publish
> # → bundled support.route.v3@3  1,284 decisions → ~/.jevcache/shared/support.route.v3.jevcache.json
>
> jevcache publish --gist                 # upload as a public gist (needs the `gh` CLI), prints a URL
> jevcache publish --schema support.route  # just one schema
>
> # them: one command, then recall() hits your decisions — no backend, no account, no key
> jevcache add https://gist.github.com/you/…/raw
> jevcache recall --schema support.route.v3 --state ticket.json   # HIT
> ```
>
> `add` also registers the schema locally, so `recall`/`decide` resolve it immediately. A
> bundle is plain JSON — inspect it before you add it.
>
> ## Hosted global index (beta)
>
> A hosted index is live at `https://jevcache.sh/api` (the default). Push a cache and recall
> from it over the network — only fingerprints and answers cross the wire, never raw state.
>
> ```bash
> jevcache publish --remote                                   # push your cache to the index (free)
> jevcache use --schema support.route --state ticket.json     # recall from the index
> ```
>
> Reads are open and keyless. Writes mint a free key (cached at `~/.jevcache/apikey`) so
> decisions are attributable and no one can overwrite another publisher's cache.
>
> | Var | Default | Purpose |
> |---|---|---|
> | `JEVCACHE_API_URL` | `https://jevcache.sh/api` | commons base URL — point at a different instance to override |
> | `JEVCACHE_API_KEY` | — | write key (auto-minted on first `publish --remote`) |
>
> Next: a decentralized index over the Hyperspace P2P network, and per-recall pricing so
> publishers can charge for a cache.
>
> ## License
>
> jevcache is **free to use**. This repository distributes the CLI binary and docs. Not affiliated with TypeSafe (Jev is their model).
> ```
>
> #### All replies, verbatim
>
> Fifteen replies returned by `bird replies --all` on 20 September 2026 at 21:54 UTC, against the 19 the tweet reports.
>
> **@varun_mathur (Varun):**
> > Jev made decisions fast and cheap. It didn't make the repeats free.
> >
> > Agents, retries, idempotent tools: 60–80% of decisions are the same input over and over.
> >
> > You pay every time. jevcache fixes that.
>
> date: Sat Sep 19 18:01:37 +0000 2026 · https://x.com/varun_mathur/status/2101371147262521407
>
> **@BuildToCite (Am.E):**
> > @varun_mathur https://t.co/Uqs2NGlHT9
> >
> > QT @BuildToCite:
> > How I see Jev:
> >
> > You're not swapping out LLMs altogether, just replacing the calls that act like a smart &lt;if/else&gt; with structured confidence &amp; probabilities.
> >
> > https://x.com/BuildToCite/status/2101210833149739198
>
> date: Sat Sep 19 22:04:54 +0000 2026 · https://x.com/BuildToCite/status/2101432370142261284
>
> **@RohanArun (Rohan Arun):**
> > @varun_mathur Nice you can use any classifier here  https://t.co/QJrKHXcULf
>
> date: Sat Sep 19 23:22:11 +0000 2026 · https://x.com/RohanArun/status/2101451817829781856
>
> **@palindrome_guy (Naman Arora):**
> > @varun_mathur Excuse my dumbness but where do you think this will be mostly used?
>
> date: Sun Sep 20 08:51:14 +0000 2026 · https://x.com/palindrome_guy/status/2101595024228249702
>
> **@DODO02806602 (DODO):**
> > @varun_mathur how about we host on server and megacache everyone using jev
>
> date: Sat Sep 19 23:33:39 +0000 2026 · https://x.com/DODO02806602/status/2101454705473753575
>
> **@yikesawjeez (yikes (:D/acc)):**
> > @varun_mathur oh youre the hyperspace guy! sick! 2nd thing of urs i have enjoyed, ru hiring or anything, i may have a slot coming up in jan/feb &amp; open for spec work prior to
>
> date: Sun Sep 20 21:15:05 +0000 2026 · https://x.com/yikesawjeez/status/2101782222919569650
>
> **@harveyfullstack (Jeremiah):**
> > @varun_mathur Why isn't Jev's servers doing this?
>
> date: Sun Sep 20 03:53:21 +0000 2026 · https://x.com/harveyfullstack/status/2101520060535742593
>
> **@CobaltHere (Cobalt):**
> > @varun_mathur Gonna test this!
>
> date: Sun Sep 20 12:21:14 +0000 2026 · https://x.com/CobaltHere/status/2101647872085078241
>
> **@phanindra_ai (Phanindra Reddy):**
> > @varun_mathur this is super cool, making all use cases and opensourcing for jev
> >
> > would love your use case here
> > https://t.co/hQEBeoMwb6
>
> date: Sat Sep 19 21:21:42 +0000 2026 · https://x.com/phanindra_ai/status/2101421497852305850
>
> **@MatOrzelowski (Mateusz Orzełowski):**
> > @varun_mathur funny how fast things move these days
>
> date: Sat Sep 19 19:30:18 +0000 2026 · https://x.com/MatOrzelowski/status/2101393463002415492
>
> **@shahin43 (Shahn):**
> > @varun_mathur Nice !!!
> > well Jev could be implementing same feature server side right ?? it would become still some cache hit and cost, not 0$ though
>
> date: Sun Sep 20 16:12:37 +0000 2026 · https://x.com/shahin43/status/2101706104350609884
>
> **@purpose_walker (purpose):**
> > @varun_mathur Isn't this runic 😭
>
> date: Sun Sep 20 10:31:05 +0000 2026 · https://x.com/purpose_walker/status/2101620154740113416
>
> **@raw_works (Raymond Weitekamp):**
> > @varun_mathur after ~3 years i think i finally now understand why the cache defaults to on in @DSPyOSS
> >
> > i'm a slow learner
>
> date: Sat Sep 19 20:25:07 +0000 2026 · https://x.com/raw_works/status/2101407259179860341
>
> **@Lord_iskandar (Lord Iskandar):**
> > @varun_mathur sick man.
> > you fast
>
> date: Sat Sep 19 23:56:58 +0000 2026 · https://x.com/Lord_iskandar/status/2101460574706290878
>
> **@Shex005 (sherif):**
> > @varun_mathur This is cool
>
> date: Sun Sep 20 13:12:02 +0000 2026 · https://x.com/Shex005/status/2101660658072686643
