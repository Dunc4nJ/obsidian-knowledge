---
created: 2026-09-19
source: https://github.com/realZachi/pg-jev
description: A PostgreSQL extension that filters, ranks, classifies and scores rows with plain-language conditions by sending every row to TypeSafe's Jev, a System One Model returning calibrated probabilities instead of text.
type: resource
tags: [jev, postgres, extension, system-one-models, typesafe, structured-decisions]
status: unread
---

## What it is

`jev` is a PostgreSQL extension that lets you put a plain-language condition in a `WHERE` clause. Every row is judged by [TypeSafe's Jev](https://docs.typesafe.ai), a System One Model that returns calibrated probabilities rather than generated text, so there is no index, no embeddings and no vector column anywhere in the design. It ships four judgment shapes over the same row: `jev()` returns a boolean predicate, `jev_prob()` a probability from 0 to 1, `jev_choice()` the most likely option from an array, and `jev_score()` a probability-weighted position on an ordered list of levels.

Because `jev()` is an ordinary boolean function it composes with the rest of SQL: `AND age > 40`, joins, `GROUP BY`, `LIMIT`, and `ORDER BY jev_prob(...)`.

```sql
CREATE EXTENSION jev CASCADE;

SELECT * FROM people WHERE jev(people, 'the name is European');

SELECT subject, jev_prob(tickets, 'the customer is angry') AS p
FROM tickets ORDER BY p DESC LIMIT 20;

SELECT jev_choice(tickets, 'which team should handle this?',
                  ARRAY['billing', 'technical', 'security', 'sales']) AS team, count(*)
FROM tickets GROUP BY 1;

SELECT name, jev_score(products, 'how luxurious is this product?',
                       ARRAY['budget', 'mid-range', 'premium', 'luxury']) AS luxury
FROM products ORDER BY luxury DESC;
```

The repo is Shell and C with the extension body in PL/Python, licensed under the PostgreSQL License, published on PGXN as dist `jev`, and unaffiliated with TypeSafe. It requires self-hosted PostgreSQL 14 to 17 with the untrusted language `plpython3u` and a superuser, which rules out Supabase, Neon and RDS-class managed hosts.

## Why it's interesting

Most "LLM in your database" integrations are a UDF that calls a chat completion endpoint and parses whatever string comes back. This one is built on a model whose native output is a calibrated probability per question, which changes what the SQL surface can honestly promise. A threshold becomes a real knob rather than a prompt-engineering trick, `ORDER BY jev_prob(...)` is a meaningful ranking instead of a sort over hallucinated scores, and `jev_confidence()` can exist at all. It is also one of the first third-party use cases built on Jev, so it doubles as evidence about what the model is actually good for.

The engineering underneath is the other draw. The v0.2.0 changelog reads like a systems paper in miniature: the author measured accuracy against ground truth to pick a batch size, measured TLS handshake cost to justify connection pooling, and measured token overhead to justify dropping a single generic phrase from every request. Very little of it is about prompting.

**Why it matters for the vault.** This is "inference as a database operator" stopped being a slide and became an extension you can `make install`. The pattern the analysts and researchers have been describing in the abstract shows up here with concrete numbers attached: an optimizer-visible predicate, a cost model in tokens per row, spend guards as GUCs, and a cache keyed on row content. Read it against [[Snowflake, Databricks and ClickHouse preview AI architecture by turning inference into a database operator, the semantic layer into agent infrastructure, and agents into a new database workload]], which forecasts exactly this shape of operator arriving inside the warehouses, and against [[Berkeley's EPIC Data Lab argues near-free intelligence makes agents the dominant data-systems workload, needing data systems for, of, and by agents]], whose "data systems for agents" thesis predicts the batching, read-ahead and caching work that dominates this codebase. The instructive difference is that both of those argue from the warehouse side, where the operator can be fused into the execution engine, while pg-jev bolts it onto an unmodified Postgres from the outside and has to recover the same wins through read-ahead and session caching. The sibling resource [[jevlike]] covers the other early ecosystem tool, and the Jev launch material itself lives alongside this note under [[moc - Jev]].

## How it works

Every row the executor asks about goes to the API. That is the design, not a limitation being worked around, and the extension's whole job is to make the full scan cheap enough to be tolerable.

**Composite row to shared state.** `jev(table, 'condition')` receives the row as a composite value, not as a set of scalar arguments. Rows are then packed `jev.batch_size` (default 20) per request into one shared *state* object of the form `{"condition": ..., "rows": [...]}`, carrying one yes/no [Noul](https://docs.typesafe.ai/primitives/noul) question per row. Jev evaluates every question over that single state in parallel within one request. Rows are serialised with `to_json`, which preserves column order, rather than `to_jsonb`, which sorts keys by length.

**Why 20.** The batch size is an accuracy decision, not a throughput one, and the author measured it. Jev has to find `rows[i]` by position in the array and that gets unreliable as the array grows. Tested against ground truth drawn from structured columns (job title, EU membership, a phrase in a free-text field, 400 rows each), batches of 1 to 20 rows were 100% correct, batches of 40 fell to 92-98%, and batches of 80 to 77-94%. Widening the rows to 1,000 characters made no difference at 20. Naming rows instead of indexing them did not help either. Batches of 20 cost 4% more tokens than batches of 40 and are just as fast, because a request's latency barely depends on its size. The default moved from 40 to 20 in v0.2.0 for this reason.

**Overhead amortization.** Batching exists to spread a fixed ~270-token request overhead across rows. A single row judged alone costs about 435 input tokens; in batches of 20 the cost is about 175 input tokens per row. A related v0.2.0 change deleted the generic `criteria` string ("the record satisfies the condition") from Noul questions after measuring that it consumed 16% of all input tokens and changed no answers.

**Streaming read-ahead.** The first call for a given table and condition starts a read-ahead that streams the table in physical order, using TID range scans for tables and `OFFSET` pages for views. Memory stays constant whatever the table size. This replaced v0.1.0's approach of reading the whole table up to `jev.max_prefetch_rows` before answering anything, under which rows beyond the 5,000-row limit were judged one request at a time. The setting now bounds only how far past a cache miss the read-ahead scans and how many skipped rows it remembers.

**Concurrency over persistent connections.** Up to 2 × `jev.concurrency` requests (32 by default, since concurrency defaults to 16) are in flight over persistent HTTPS connections. Keep-alive is load-bearing: reusing connections across batches and statements cut per-request cost from 880 ms to 300 ms from Europe, and the first request on a fresh connection was measured at 0.9-1.9 s against 0.3 s afterwards. Pooled connections are validated before reuse, carry TCP keepalive probes so a request is never sent into a dead socket, and are reconnected after `jev.keepalive` (600 s) of idle time. A connection that still fails is immediately retried on a fresh one, and `429`, `529` and `5xx` responses honour `Retry-After`.

**Short-circuiting.** Every row is answered as soon as its batch returns rather than after the whole scan, which is what makes the cheap paths cheap. A `LIMIT` stops the read-ahead after the in-flight window. Rows that cheaper predicates reject before `jev()` runs, as in `WHERE age > 60 AND jev(...)`, are skipped rather than judged. Rows requested out of physical order, from backward index scans or joins, are batched with their neighbours instead of judged one at a time.

**Session cache.** Answers are keyed by row content and held in the backend session's PL/Python `GD` dictionary. Re-running a query, changing the threshold, or sorting by `jev_prob()` costs nothing and issues no API call. A cache hit costs no SPI call at all. The cache is per session, so a connection pool with many sessions warms each one separately.

**The subquery limitation.** Rows arriving from a subquery or CTE have an anonymous `record` type, which the read-ahead cannot batch. Those are judged one request at a time, at roughly 435 tokens per row instead of 175. The documented workaround is to call `jev()` on a base table or a view, and views get read ahead and batched exactly like tables. That also happens to be the recommended way to send the model only the columns the judgment needs.

**Measured.** On a 2,000-row table from Europe with ~190 ms to the API: first run ≈ 3.5 s in 100 requests, ≈ 296k input tokens, ≈ $0.012; second run ≈ 50 ms from the cache; `LIMIT 3` on a new condition ≈ 0.6 s. A new condition in a session still holding its pooled connections takes ≈ 2.3 s, since the first request on each fresh connection is the slow one. Version 0.1.0 needed 8.5 s and 338k tokens for the same full query, and 8.4 s for the `LIMIT`. Pricing is input tokens × $0.042 per million (jev-1.13 list price, output tokens free), and `jev_stats()` reports the running total as `estimated_cost_usd` alongside requests, tokens, cache hits, in-flight requests and pooled connections.

**Spend guards and privacy.** `jev.max_rows_per_statement` and `jev.max_chars_per_statement` (both `0`, off, by default) abort a statement that would send more than the configured volume to the API. Row contents leave the database for a third-party endpoint, which the caveats state plainly. Because `plpython3u` is untrusted, the functions run with the server's OS privileges and only a superuser can create the extension.

## Key links

- [GitHub](https://github.com/realZachi/pg-jev) — the extension, 210 stars, created 2026-09-17
- [pgjev.com](https://pgjev.com) — project site; every docs page has a Markdown twin at `<path>.md`
- [How it works](https://pgjev.com/docs/how-it-works) — the batching, read-ahead and cache design with the measured numbers
- [PGXN dist `jev`](https://pgxn.org/dist/jev/) — `pgxn install jev`
- [TypeSafe docs](https://docs.typesafe.ai) — the Jev model itself
- [Noul primitive](https://docs.typesafe.ai/primitives/noul) — the yes/no question type each row is judged with

## Notes

No architecture diagram exists to capture. The repo's only asset is a decorative `docs/assets/header.svg` banner.

The project site is already behind the code. The homepage still describes batches of 40 and six concurrent requests, which were the v0.1.0 defaults; the README and the `/docs/how-it-works` page have the current 20 and 16.

Open questions a skeptical reader should hold onto:

- **Cost at scale.** Extrapolating the measured run, $0.012 per 2,000 rows is $6 per million rows scanned, and the measured 296k tokens over 2,000 rows works out to ~148 input tokens per row. Using the documented rule of thumb of ~175 tokens per row at $0.042 per million gives ~$7.35 per million rows. So a single unfiltered predicate over a 10M-row table is a $60-75 query, repeated in full for every new condition, and the session cache does nothing across connections in a pooled application. The spend guards exist precisely because this is easy to do by accident.
- **Latency floor.** The 190 ms round trip is measured from Europe and the docs never say where the API is hosted, so the numbers are a single geography's result rather than a floor. Judging 2,000 rows in 100 sequential-ish batches means the wall clock is dominated by round trips, and the 3.5 s figure should be expected to move with distance to the endpoint.
- **Failure mid-scan.** Retries on `429`, `529` and `5xx` are documented, but what a query returns when retries are exhausted halfway through a scan is not. A predicate that can error out partway is a different thing to reason about than one that cannot, particularly inside `UPDATE ... WHERE jev(...)` or `DELETE ... WHERE jev(...)`, both of which the homepage advertises.
- **Are the probabilities stable enough to sort by?** The batch-size evidence is about boolean correctness against ground truth, not about the stability of the underlying probability. `ORDER BY jev_prob(...)` needs the values to be comparable across rows that were judged in different batches alongside different neighbours, and nothing published here tests that directly. The docs' own advice to inspect the distribution before choosing a threshold hints that the calibration is worth verifying on your own data.
- **Batch position sensitivity.** Accuracy degrading with array length implies the answer for a row may depend on which other rows shared its request. Since batching follows physical table order, that makes results a function of on-disk layout, and a `VACUUM FULL` or a reload could in principle shift them.
