---
created: 2026-09-17
description: PlanetScale's TIN full-text index for Postgres uses the heap `ctid` itself as the posting rather than a sequential document id, which lets postings compress into two-level page/offset bitmaps that sit in AVX2 and AVX-512 registers, removes the ctid-mapping lookup every competing extension pays, pushes MVCC visibility checks into the index via the visibility map, and makes segment merges a pointer transfer instead of a renumbering rewrite — self-reported at 25x ParadeDB's QPS on mixed top-10 BM25 queries.
source: https://planetscale.com/blog/introducing-tin
type: article
---

## Key Takeaways

- **The whole design follows from one decision: the posting *is* the Postgres `ctid`, and that is what produces 25x ParadeDB's throughput with 26x lower p99 on mixed top-10 BM25 queries over an 85 GB corpus.** A `ctid` is a 48-bit physical address — upper 32 bits page number, lower 16 bits offset within that page — which is normally hostile to postings compression (delta encoding breaks at every page boundary, bitmaps are too sparse). TIN's escape is that an 8 KB Postgres page can hold at most 291 tuples and usually holds 32 or fewer for `TEXT`-bearing schemas, so page numbers are dense enough for a bitmap and offsets within a page are dense enough for a tiny per-page bitmap. Two-level bitmaps get high-frequency terms down to ~1 bit per posting, medium-frequency to ~7 bits, rare to ~25 bits. The page-level bitmap is 256 bits, which is exactly one AVX2 register, so conjunction and disjunction are literally `AND` and `OR` instructions and counting is `POPCNT`. This is the same family of move as [[indexing text with sparse n-grams and bloom filters eliminates 15-second ripgrep waits in large monorepos]] and [[SmithDB builds a byte-budgeted FST inverted index to enable 400ms full-text search over enormous agent traces in object storage]] — win by making the index layout match the hardware's fast path rather than by a cleverer ranking function.
- **The elided work matters as much as the vectorized work, and it shows up in the MB/query column rather than in the QPS headline.** For `the AND rareword`, TIN intersects page-level bitmaps first and never decodes offset bitmaps for pages the intersection dropped. For `COUNT(*)` disjunctions it can skip postings lists entirely: index metadata stores exact per-term posting counts, so if two terms' page bitmaps are disjoint the count of their union is just the sum. And because the *position of a set bit is* the `ctid`, a row-returning query computes the identifier arithmetically instead of probing a mapping structure on disk — ParadeDB and pg_textsearch both maintain a separate id-to-`ctid` table and must probe it once per matched row, 10 million times for a 10-million-row match. TIN reads 65 MB/query on the mixed workload against ParadeDB's 582 MB; on the Wikipedia count workload it is 1.7 MB against 22 MB. Lower I/O per query is also why the post can claim TIN queries do not evict the block cache out from under everything else on the box.
- **The MVCC answer is the strongest engineering in the post: TIN moves the visibility check *into* the index instead of leaving it to the executor, and it does so by intersecting bitmaps against bitmaps.** Postgres' visibility map is itself a page-level bitmap, and so is TIN's postings structure, so "which of my matches live on pages that are all-visible" is a vector `AND` — only `ctid`s on not-all-visible pages need a heap probe at all. A `COUNT(*)` over a fully all-visible heap touches zero heap pages. Deletes are handled by a per-segment liveness bitmap, one bit per `ctid` in the same page/offset layout; `VACUUM` clears the bit when it observes a `ctid` removed by an `UPDATE` or `DELETE`, page groups containing a cleared bit get marked, and a query touching a marked group `AND`s the liveness bitmap into the offset bitmaps. Queries that return heap columns are visibility-checked for free because TIN has to fetch the tuple anyway and Postgres reports visibility on the fetch. The write-path cost is measured, not asserted: under a concurrent client targeting 1,000 `UPDATE`/second, TIN drops from 148 to 125 QPS and still lands 270,279 updates in ten minutes — against ParadeDB's collapse from 17 to 2.2 QPS and pg_textsearch's 735 total updates, because its readers never release the locks writers need. Correctness-under-concurrency as the load-bearing design constraint rather than an afterthought is the same posture as [[Chroma's wal3 ports the 1996 Michael-Scott lock-free queue onto S3 conditional writes and builds the log twice - once for data, once for a setsum that proves it correct]].
- **Segment merging is the second-order payoff and it is where `ctid` postings pay for themselves twice.** TIN builds *n* immutable segments at index creation, accepts writes into mutable segments, and has a background worker promote mutable to immutable and later merge immutables into larger immutables — an LSM shape, same as [[SmithDB makes LangSmith 12x faster by treating agent observability as an LSM problem on object storage]]. The difference is what a merge costs. Engines with per-segment sequential document ids must renumber on merge (`42` in segment 4 is not `42` in segment 7), which means repacking, recompressing, and rewriting both inputs — close to 2x storage for a two-way merge. TIN has nothing to renumber: `(190, 17)` means the same tuple in every segment, so many bitmaps are transferred by ownership rather than copied or recompressed. That is the link between the merge design and the concurrent-write benchmark — low merge write-amplification is why background compaction does not eat the write path while readers are hammering it.
- **TIN does not win everything: it is the second-largest index in the comparison and 1.8x larger than GIN.** On the 85 GB Stack Exchange corpus the indexes come in at TIN 50.7 GB, ParadeDB 52.1 GB, pg_textsearch 41.5 GB, and Postgres GIN 28.0 GB. TIN wins build time decisively (8m10s vs GIN's 2h09m04s) and is the only engine that built inside the 32 GB container at all — the other three needed 64-128 GB and the authors had to raise the limit for the build phase. So the honest framing is that TIN trades disk for latency, throughput, and build headroom, the same shape of trade as [[Lakebase puts Postgres on open object storage as a third database generation - O(1) branching, sub-500ms compute start, and 7x space amplification as the price]]. On query throughput there is no published workload where TIN loses, which is itself worth noting about a vendor's own benchmark suite.
- **Methodology disclosure is unusually good for a launch post, but every number is self-run and the query trace is synthetic.** Disclosed: AWS `i7i.8xlarge` with local NVMe and AVX-512, Postgres 18.6 in containers capped at 8 vCPU / 32 GB, exact versions (TIN v1.0.2, ParadeDB v0.25.2, pg_textsearch v1.4.0, GIN in PG 18.6), three changed GUCs (`max_parallel_workers` 8, `shared_buffers` 24 GB, `maintenance_work_mem` 24 GB), phases run sequentially, driver co-located to remove network latency, and a publicly forked ParadeDB Benchmarker. Not disclosed well enough to reproduce exactly: the corpus is described (85 GB Stack Exchange Q&A export, 150M documents) but not published as an artifact, and the 1,719 queries are generated by sampling 2-to-15-term substrings and reading each three ways (conjunction, disjunction, phrase) rather than drawn from a real query log — a trace shaped that way has no head-of-distribution and no query-frequency skew, which is exactly the regime where a competitor's caching could look better or worse than it does in production. Treat the mechanism as measured and the ranking as pending independent replication, the same caution [[Hornet tunes 100M-doc ANN search and finds instruction prefixes, graph connectivity, and quantization ceilings interact in ways benchmarks miss]] earns for the vector side.
- **For agent retrieval specifically, a faster BM25 buys throughput and tail latency, not recall — and recall is where the agent gap lives.** [[BrowseComp-Plus isolates the search-agent ceiling - GPT-4.1 scores 14.6 percent finding documents with BM25 vs 93.5 percent when handed them]] puts a number on it: the retriever, not the reasoning, is the ceiling, and making the same BM25 run 25x faster does not move the 14.6. [[agents are the perfect slow searchers because LLM inference cost dominates per-query retrieval latency]] is the sharper objection — a single agent issues few queries and pays seconds of inference per query, so 200 QPS versus 8 QPS is close to invisible to it. Where TIN's numbers actually cash out is multi-tenant search backends, and harness patterns like [[Dr-DCI caches BM25 hits into a bounded grep-able workspace, making fast corpus retrieval a harness-engineering differentiator for inference providers]], where one server fans out across many concurrent agents; the p99 collapse under concurrent writes is the number that matters there, not the peak QPS. [[Entire's pgr proves definition-first ranking helps coding agents more than faster ripgrep]] and [[coding agents are bottlenecked by search not coding ability]] point the same direction — ranking quality beats raw speed for a single agent.
- **TIN is a bet that lexical retrieval is still worth deep engineering investment, placed against a field that has mostly moved to late interaction.** The vault's counter-case is strong: [[ColBERT-style semantic search beats grep 70 percent of the time for coding agents while using fewer tokens]], [[late interaction lets a 150M ColBERT model outperform 7B dense retrievers on reasoning-intensive retrieval]], and [[GLIE finds ColPali page embeddings have only ~5 degrees of freedom, so k stored vectors plus a 415K-parameter decoder can regenerate all 1,031]] all argue the marginal quality is in multi-vector scoring, while [[agentic search with grep and full-file loading replaces RAG when context windows are large enough]] argues the whole index layer is shrinking. TIN's reply is a different axis: exactness, `COUNT(*)`, phrase and span queries, regex and fuzzy terms, and transactionally correct results — things no embedding index gives you. It also strengthens the extend-Postgres-rather-than-move-the-data pattern seen in [[pgGraph compiles Postgres edges into a CSR in-memory graph layer for microsecond deep agent traversals where Apache AGE recursive SQL times out]], [[Kimi K2.6 chose TiDB because agent-native databases need constraint completeness over single-point optimality]], and [[databases are becoming the runtime layer for AI agents as application logic collapses into the data layer]] — and strengthens it more than pgGraph does, because TIN's speed comes *from* Postgres internals (`ctid`, the visibility map, `VACUUM`) rather than from bolting an in-memory structure alongside them.

## External Resources

- [TIN getting started guide](https://planetscale.com/docs/postgres/search/get-started) — `CREATE INDEX ... USING tin(col)` and the `==>` operator; GA on all PlanetScale Postgres and Neki databases
- [TIN feature docs](https://planetscale.com/docs/postgres/search) — boolean/phrase/span queries, fuzzy, wildcard, regex, case and accent folding, BM25 top-k, `COUNT(*)`
- [ParadeDB Benchmarker](https://github.com/paradedb/benchmarker) — the benchmark harness, written by the competitor TIN is measured against
- [PlanetScale's fork of the Benchmarker](https://github.com/planetscale/paradedb-benchmarker) — adds pre-warming before measurement plus bytes-read and WAL-bytes-written metrics; this is the code that produced the published numbers
- [Postgres page layout docs](https://www.postgresql.org/docs/current/storage-page-layout.html) — the source of the 291-tuples-per-8KB-page bound that makes TIN's two-level bitmap encoding viable

## Original Content

Source: [Introducing TIN: full-text search for Postgres](https://planetscale.com/blog/introducing-tin) — Eric Ridge and Patrick Reynolds, PlanetScale Engineering, September 16, 2026.

> [!quote]- Source Material
> # Introducing TIN: full-text search for Postgres
>
> [Eric Ridge](https://planetscale.com/blog/author/eebbrr), [Patrick Reynolds](https://planetscale.com/blog/author/piki) | September 16, 2026
>
> One of the Postgres features our customers ask us for the most is full-text search. Today, we are excited to announce TIN: a fast, full-featured, reliable full-text search extension for Postgres. TIN stands for "Text INdex," and that is what it does.
>
> TIN is [available immediately](https://planetscale.com/docs/postgres/search/get-started) as a GA release for all Postgres and Neki databases. Check it out:
>
> ```
> CREATE INDEX an_index_name ON table_name USING tin(text_column_name);
> SELECT * FROM table_name
>   WHERE text_column_name ==> 'some words';
>
> ```
>
> We built TIN because we believe a good text index should support:
>
> * Boolean expressions, phrase queries, and span queries
> * Fuzzy, wildcard, and regular-expression matching for terms
> * Case and accent folding
> * `COUNT(*)` queries and BM25-scored top-k queries
>
> A good text index _in Postgres_ must support all of those things while also handling joins, complicated `WHERE` clauses across full-text and other column types, continuous updates, replication, backups, and correct transaction visibility.
>
> Although there are at least three existing text-search indexes for Postgres already, none of them met all of those requirements. TIN does. TIN is also really, mind-blowingly fast.
>
> ## [What TIN is for](#what-tin-is-for)
>
> Application developers use text indexes to build a variety of search features. An e-commerce platform might need to search for the top ten products containing all keywords in the search:
>
> ```
> SELECT * FROM products
>   WHERE description ==> 'stretch denim jeans'
>   ORDER BY tin.score(ctid) DESC
>   LIMIT 10
>
> ```
>
> A legal discovery platform might be required to return every document containing one or more of a set of keywords, but not care at all about ranking:
>
> ```
> SELECT * FROM emails
>   WHERE body ==> '[insider trading conspiracy]'
>
> ```
>
> A photo tagging platform might show an exact count of photographs with a particular tag:
>
> ```
> SELECT COUNT(*) FROM photos
>   WHERE tags ==> '"san francisco"';
>
> ```
>
> Most applications also need to insert, update, and delete documents, even while continuing to query the index. Search queries must return matches based on new or changed rows as soon as they've been committed.
>
> ## [TIN performance and benchmarking](#tin-performance-and-benchmarking)
>
> We ran benchmarks to assess performance for all the above use cases and more. We tried workloads:
>
> * With conjunction (must contain all words), disjunction (must contain any word), and phrase (must contain all words in sequence) queries and a mix of all three.
> * That count documents or that ask for the top _k_ by BM25 score.
> * With and without clients writing new data to the index concurrently with the benchmark query workload.
>
> ### [Workloads and corpus](#workloads-and-corpus)
>
> We have measured TIN against a variety of text corpora: all of Wikipedia, a collection of Reddit comments totaling 2.3 TB, and a mixed workload we call simply "pile" with 797 GB of open-access research papers, legal documents, public domain books, and Enron emails. The benchmark results we share in this article are from an export of questions and answers from Stack Exchange: an 85 GB corpus with 150 million documents. Because the corpus has no standard query trace, we generated a synthetic one by sampling substrings ranging from 2 to 15 terms. We interpreted each substring three ways: as a conjunction, as a disjunction, and as a phrase query, for a total of 1,719 queries.
>
> ### [Test environment](#test-environment)
>
> We ran our benchmarks on an AWS i7i.8xlarge EC2 instance with local NVMe storage and a modern, AVX-512-capable CPU. For each text-search extension, we set up Postgres 18.6 in an isolated container limited to 8 vCPUs and 32 GB of RAM. That's small enough to show how each index system performs when the index doesn't just fit in Postgres buffers. The benchmark phases ran sequentially, so the engines did not compete for resources. We chose a standalone EC2 instance to minimize the impact of operational overhead and replication and to ensure that anyone who wants to reproduce our benchmarks of competing text-search indexes can do so using the same instance type and container limits.
>
> To drive the search traffic against the Postgres containers, we used the [ParadeDB Benchmarker](https://github.com/paradedb/benchmarker). We have [a forked version](https://github.com/planetscale/paradedb-benchmarker) that pre-warms before beginning measurement and adds metrics for bytes read and WAL bytes written. We left all Postgres parameters at the defaults that the Benchmarker supplies, except for three: we set `max_parallel_workers` to 8 (from 40), `shared_buffers` to 24 GB (from 128 MB), and `maintenance_work_mem` to 24 GB (from 64 MB), to best match the resources of the container. We ran the Benchmarker on the same EC2 instance as the target Postgres server, to ensure that network latency did not impact the measurements.
>
> For each scenario, we measured the performance of TIN v1.0.2 against all the other Postgres text-search indexes that were capable of running the workload at all: ParadeDB v0.25.2, pg\_textsearch v1.4.0, and the GIN index built into Postgres v18.6. Aside from TIN, only ParadeDB was able to complete all of the benchmarks.
>
> ### [Index build time and size](#index-build-time-and-size)
>
> Indexes range from 33% to 61% of the size of the corpus, and they took from 8 to 129 minutes to prepare, build, and finalize. The three engines other than TIN failed with the container's configured 32 GB limit, so for index builds only, we increased the available RAM as shown in the table. Before running queries, we set the container back to 32 GB of RAM for everyone.
>
> |                | Total time | Index size | Required RAM |
> | -------------- | ---------- | ---------- | ------------ |
> | TIN            | 8m10s      | 50.7 GB    | 32 GB        |
> | ParadeDB       | 19m20s     | 52.1 GB    | 64 GB        |
> | pg\_textsearch | 26m49s     | 41.5 GB    | 128 GB       |
> | Postgres GIN   | 2h09m04s   | 28.0 GB    | 64 GB        |
>
> ### [Mixed queries, top-10 ranked](#mixed-queries-top-10-ranked)
>
> Our first benchmark compares TIN against ParadeDB, for a workload with mixed (conjunction, disjunction, and phrase) queries, top-10 results by BM25 score, with no concurrent writes to the index. TIN handles 25× as many queries per second as ParadeDB does, with p99 latencies 26× lower. GIN can't complete this benchmark, because it runs out of memory performing the disjunction searches. pg\_textsearch can't complete the benchmark because it handles _only_ disjunction searches.
>
> *Mixed queries (conjunction, disjunction, and phrase), top-10 ranked by BM25, read-only, on the 85 GB Stack Exchange corpus. X-axis: elapsed time across the 10-minute run; Y-axis: queries per second, linear scale. TIN holds roughly 200 QPS for the whole run while ParadeDB sits near 8.*
> ![[planetscale-tin-001.png]]
>
> *The same mixed top-10 read-only run switched to the latency view: p99 in milliseconds, log scale. TIN stays around 250 ms; ParadeDB runs in a 3,000-7,000 ms band. This is the 26x p99 gap quoted above.*
> ![[planetscale-tin-005.png]]
>
> ### [Conjunction and phrase queries, top-10 ranked](#conjunction-and-phrase-queries-top-10-ranked)
>
> Our next benchmark compares TIN against ParadeDB and Postgres GIN, for top-10 conjunction and phrase queries, with no concurrent writes. TIN and ParadeDB rank using BM25, while GIN ranks using `ts_rank_cd`. TIN handles 10× as many queries as ParadeDB and 541× as many as GIN, with p99 latencies 6× and 1,356× lower, respectively. pg\_textsearch is again absent because it handles only disjunction queries.
>
> *Conjunction and phrase queries, top-10 ranked, read-only. X-axis: elapsed time; Y-axis: QPS, linear scale. TIN runs at roughly 240-250 QPS, ParadeDB at about 24, and Postgres GIN is the flat green line pinned against the axis at 0.4 QPS.*
> ![[planetscale-tin-002.png]]
>
> ### [Disjunction queries with concurrent writes](#disjunction-queries-with-concurrent-writes)
>
> Our third result compares TIN against both ParadeDB and pg\_textsearch, for a workload with disjunction queries, top-10 results by BM25 score, and a concurrent client targeting 1,000 `UPDATE` queries per second. TIN handles 36× as many queries as pg\_textsearch and 57× as many queries as ParadeDB, with p99 latencies 24× and 36× lower, respectively. Over the course of a ten-minute run, TIN completes 270,279 updates, while ParadeDB completes 185,584, and pg\_textsearch completes only 735.
>
> ParadeDB's approach to accepting writes sacrifices read throughput and latency. pg\_textsearch maintains the same 3.5 QPS for readers both with and without writes because continuous read traffic prevents write traffic from ever getting the locks it needs, so writes stall after just a few seconds. GIN is again absent because it runs out of memory on disjunction queries.
>
> *Disjunction queries, top-10 ranked by BM25, with a concurrent client targeting 1,000 UPDATEs per second. X-axis: elapsed time; Y-axis: QPS, linear scale. TIN sustains roughly 125 QPS under write load; ParadeDB (2.2) and pg_textsearch (3.5) are both flat against the axis.*
> ![[planetscale-tin-003.png]]
>
> *The same disjunction-with-writes run as p99 latency in milliseconds, log scale. TIN holds around 350 ms; ParadeDB and pg_textsearch overlap in the 3,000-12,000 ms range, roughly an order of magnitude worse.*
> ![[planetscale-tin-006.png]]
>
> ### [When the index fits in memory](#when-the-index-fits-in-memory)
>
> In the intro, we claimed that TIN is mind-blowingly fast.
>
> Our final graph shows what TIN, ParadeDB, and Postgres GIN can do when the index fully fits in shared buffers. This workload counts (but does not rank) the documents that match a disjunction query against Wikipedia, an 8.0 GB corpus. pg\_textsearch is absent here because it can only perform top-k queries, not counting queries.
>
> *Disjunction `COUNT(*)` queries against the 8.0 GB Wikipedia corpus with the index fully resident in shared buffers. X-axis: elapsed time; Y-axis: QPS on a log scale. TIN holds roughly 10,000 QPS, ParadeDB about 291, and Postgres GIN about 1.4 — three orders of magnitude across the field.*
> ![[planetscale-tin-004.png]]
>
> ### [Full results](#full-results)
>
> That is perhaps enough graphs, but it doesn't cover all of our use cases. Here are those same scenarios, plus several more, in table form. The "MB/query" column shows how much data each index read from the disk or block cache for each query. TIN's lower numbers for MB/query are part of why it's faster, and they also reduce the impact of TIN queries on the block cache and I/O capacity, meaning that other queries on the same server stay fast, too.
>
> ```
> Conjunction, disjunction, and phrase queries; top-10
> ┌────────────────────────────────────────────────────────────────────┐
> │                            QPS        p99    MB/query     Updates  │
> ├─────────────────────────┬───────┬──────────┬───────────┬───────────┤
> │ TIN - read-only         │  199  │   256ms  │       65  │           │
> │     - with updates      │  172  │   284ms  │       88  │  271,398  │
> ├─────────────────────────┼───────┼──────────┼───────────┼───────────┤
> │ ParadeDB - read-only    │  7.9  │ 6,765ms  │      582  │           │
> │          - with updates │  6.0  │ 7,990ms  │      591  │  193,487  │
> └─────────────────────────┴───────┴──────────┴───────────┴───────────┘
>
> ```
>
> ```
> Conjunction and phrase queries; top-10 (read-only)
> ┌───────────────────────────────────────────────┐
> │                  QPS         p99    MB/query  │
> ├───────────────┬───────┬───────────┬───────────┤
> │ TIN           │  242  │     212ms │        73 │
> ├───────────────┼───────┼───────────┼───────────┤
> │ ParadeDB      │   24  │   1,279ms │       668 │
> ├───────────────┼───────┼───────────┼───────────┤
> │ Postgres GIN  │  0.4  │ 288,066ms │       595 │
> └───────────────┴───────┴───────────┴───────────┘
>
> ```
>
> ```
> Disjunction queries; top-10
> ┌────────────────────────────────────────────────────────────────────────┐
> │                                 QPS         p99    MB/query   Updates  │
> ├──────────────────────────────┬───────┬───────────┬─────────┬───────────┤
> │ TIN - read-only              │  148  │    324ms  │     48  │           │
> │     - with updates           │  125  │    354ms  │     77  │  270,279  │
> ├──────────────────────────────┼───────┼───────────┼─────────┼───────────┤
> │ ParadeDB - read-only         │   17  │  2,385ms  │    303  │           │
> │          - with updates      │  2.2  │ 12,634ms  │    394  │  185,584  │
> ├──────────────────────────────┼───────┼───────────┼─────────┼───────────┤
> │ pg_textsearch - read-only    │  3.5  │  8,646ms  │ 11,639  │           │
> │               - with updates │  3.5  │  8,409ms  │ 11,656  │      735  │
> └──────────────────────────────┴───────┴───────────┴─────────┴───────────┘
>
> ```
>
> ```
> Conjunction, disjunction, and phrase queries; COUNT(*) (read-only)
> ┌─────────────────────────────────────────┐
> │              QPS      p99     MB/query  │
> ├───────────┬───────┬──────────┬──────────┤
> │ TIN       │  179  │   438ms  │      97  │
> ├───────────┼───────┼──────────┼──────────┤
> │ ParadeDB  │   10  │ 2,704ms  │     544  │
> └───────────┴───────┴──────────┴──────────┘
>
> ```
>
> ```
> Disjunction queries; COUNT(*); Wikipedia corpus (read-only)
> ┌───────────────────────────────────────────────────┐
> │                     QPS         p99     MB/query  │
> ├───────────────┬──────────┬─────────────┬──────────┤
> │ TIN           │  10,260  │        2ms  │     1.7  │
> ├───────────────┼──────────┼─────────────┼──────────┤
> │ ParadeDB      │     291  │       95ms  │      22  │
> ├───────────────┼──────────┼─────────────┼──────────┤
> │ Postgres GIN  │     1.4  │   30,292ms  │     2.5  │
> └───────────────┴──────────┴─────────────┴──────────┘
>
> ```
>
> As you can see, in a wide variety of scenarios, TIN has throughput at least 8× higher than the alternatives, reads far less data from the disk, and experiences only a small performance drop even while the index is updating hundreds of rows per second.
>
> ## [Why TIN is fast](#why-tin-is-fast)
>
> TIN's performance in benchmarks may be hard to believe. In the hopes of making it more believable, or at least satisfying the reader's curiosity, we'll explain a bit about architectural choices that make TIN so fast. In short: all document postings are Postgres `ctid`s rather than contiguous document identifiers, and this lends itself to highly vectorized intersection and union operations on modern CPUs.
>
> ### [Document identification](#document-identification)
>
> A text index needs an identifier for each version of each document it indexes. It groups those identifiers into highly compressed postings lists; each postings list tracks all the documents that contain one given word. In a large corpus, a postings list for a common word like "the" may contain billions of postings, while the postings list for a term like "xyz-9876" would contain only a few.
>
> Most text search systems organize their indexes into **segments**. The _n_ documents whose postings exist in a segment are usually assigned document identifiers 1 to _n_. Sequential document identifiers allow postings lists to be highly compressed using various techniques such as delta-encoding and bit-packing. But it also means document identifiers in different segments are assigned independently; document ID `42` in segment 4 is a completely different document than ID `42` in segment 7.
>
> TIN also organizes its index into segments, but not for purposes of document numbering. Instead, TIN directly uses Postgres' `ctid` value as a document identifier.
>
> Every version of every row (tuple) stored in a Postgres table has an associated `ctid` value. `ctid` is short for "current tuple identifier." Any row inserted or updated gets a new `ctid`. It is a 48-bit number that directly identifies a tuple's physical location in the Postgres heap. Represented textually as `(<block number>, <offset number>)`, the upper 32 bits indicate the block number and the lower 16 indicate the offset within that block. From now on, we will refer to the `<block number>` part as the "page number" or "page."
>
> Given the `ctid` of `(190, 17)` we know that the tuple it represents is the one at the 17th slot on page 190. Instant O(1) lookup! You can even query and retrieve rows from the heap directly using `ctid`s:
>
> ```
> -- retrieve the first 10 rows from "books" in physical heap order
> SELECT ctid, id, title FROM books ORDER BY ctid LIMIT 10;
>
> -- no scan required!  instant O(1) lookup of the row
> SELECT * FROM books WHERE ctid = '(190, 17)';
>
> ```
>
> TIN directly uses `ctid`s because Postgres internally uses `ctid`s. Postgres extensions that implement a new index type must return `ctid`s. Postgres bitmap scans are backed by potentially lossy bitmaps of `ctid`s. Postgres' internal index types (b-tree, GIN, GiST, and hash) use `ctid`s as their postings. `ctid`s are everywhere within Postgres.
>
> To operate within Postgres, a text search system that assigns sequential identifiers must, at some point, convert those identifiers back into a `ctid` in order for Postgres to work with it. Both ParadeDB and pg\_textsearch maintain a separate data structure just to perform this mapping. If a text search matches 10 million rows, ParadeDB and pg\_textsearch have to look up 10 million identifiers in their `ctid` mappings. TIN avoids that work completely.
>
> ### [48-bit identifiers are crazy](#48-bit-identifiers-are-crazy)
>
> Normal postings-list compression techniques don't work well with discontiguous 48-bit numbers. Delta encoding breaks at each page boundary, and bitmaps are too sparse to be efficient. Fortunately, some interesting properties of Postgres pages make two-level bitmap encoding practical. An 8KB page can never contain more than 291 tuples ([8192 bytes, minus 24 for the page header, divided by at least 28 per non-empty tuple](https://www.postgresql.org/docs/current/storage-page-layout.html)), and for table schemas with `TEXT` and other columns, pages often contain 32 or fewer tuples. So the list of page numbers is dense enough to use a bitmap, and within each page, the list of offset numbers is dense enough (and small enough) to use tiny bitmaps per page.
>
> Savings relative to naively storing 48-bit `ctid` values can be quite significant. Over an entire corpus, high-frequency terms approach 1 bit per posting, medium-frequency terms settle around 7 bits per posting, and rare-frequency terms can approach 25 bits per posting. Terms that appear only once are not stored as bitmaps at all.
>
> ### [Work elision and vectorization](#work-elision-and-vectorization)
>
> TIN's page-level bitmaps (which pages contain a given term) have 256 bits, which fits nicely into vector registers on any x86 CPU with AVX2 or higher. That allows several optimizations.
>
> Consider the query `the AND rareword`. TIN `AND`s the page-level bitmaps, 256 bits (pages) at a time. Any bit that's absent from the intersection is a page whose offset-level bitmaps TIN doesn't need to decode at all.
>
> For `COUNT(*)` disjunction queries such as `the OR rareword`, TIN often skips reading postings lists entirely. TIN's index metadata stores each term's exact posting counts. If the page-level bitmaps for two words have no bits in common, the count of their disjunction is just the sum of those exact posting counts.
>
> Every page-level bitmap fits into a single AVX2 register, and every offset-level bitmap fits into either one AVX-512 register or two AVX2 registers. Conjunction and disjunction queries are just `AND` and `OR` instructions on those vector registers, respectively. Queries that count the number of matches can use CPU-native `POPCNT` instructions to count the bits in the resulting bitmap. Expensive loops and branch instructions are largely avoidable.
>
> A query that wants rows rather than counts computes the `ctid` from the bit position rather than looking it up on disk. The position of a set bit _is_ the `ctid`.
>
> The document `ctid`s that TIN returns to Postgres from a given segment naturally identify pages, and tuples within a page, in heap order. This means that when Postgres needs to read matched tuples from the heap, it happens in heap order. Even with modern NVMe disks, sequential access is far faster than random access; TIN gets this optimization for free.
>
> ### [Solving MVCC](#solving-mvcc)
>
> TIN returns results that are MVCC-correct, meaning a statement executed at any point in time sees or operates only on tuples that are currently visible to it. This means every heap-backed query result needs to be checked for visibility relative to the current snapshot.
>
> #### [Heap checks](#heap-checks)
>
> There are a few different approaches to this. Some queries are inherently heap checked:
>
> ```
> SELECT a, b, c FROM lyrics WHERE content ==> 'give you up'
>
> ```
>
> Because the query returns actual heap data (the `a, b, c` columns), TIN must fetch from the heap all matching `ctid`s returned by `==> 'give you up'` anyway. When TIN asks Postgres for the physical tuple data behind each `ctid`, Postgres tells TIN whether that tuple is visible to the current snapshot. If it is, TIN returns it; otherwise, TIN moves to the next matching `ctid`, until all visible matches have been returned.
>
> #### [Visibility map](#visibility-map)
>
> Other query shapes can be executed similarly to Postgres' "Index Only Scan" where the answer is returned directly from the index without touching the heap (or at least hopefully not all of the heap). Consider a count-only query like this:
>
> ```
> SELECT COUNT(*) FROM lyrics WHERE content ==> 'give you up'
>
> ```
>
> If every heap page is marked all-visible, TIN can return that count without touching a single heap page.
>
> Not all data is static, of course, and in the case of mutated heaps, TIN does additional optimizations to ensure it's only counting visible rows by performing direct intersections with Postgres' visibility map. TIN's page-level bitmaps are exactly the right mechanism to intersect efficiently against Postgres visibility maps, which are also page-level bitmaps. Only `ctid`s on not-all-visible pages need to be checked against the heap. Normally, a Postgres index returns all `ctid`s that match regardless of visibility, and the Postgres executor checks visibility for each one. TIN plans custom scans that move visibility checks into TIN itself, where they can take advantage of vector instructions on page-level bitmaps.
>
> #### [VACUUM and TIN's liveness bitmap](#vacuum-and-tins-liveness-bitmap)
>
> Text indexes that support deleting documents typically keep some kind of "tombstone" list that's appropriate to their engine. TIN is no different. TIN keeps a per-segment liveness bitmap, one bit per `ctid`, organized the same way the page-level and offset bitmaps work. When VACUUM runs and determines a `ctid` has been deleted from the heap (as the result of an UPDATE or DELETE), TIN clears that `ctid`'s liveness bit. Groups of pages with at least one cleared bit are marked, and when a query touches a marked page group, TIN also ANDs the offset bitmaps from the postings list against the liveness bitmap, so it never returns or counts a tuple that has truly been deleted.
>
> ### [Segments and merging](#segments-and-merging)
>
> When it first creates a new index for a table, TIN creates _n_ immutable segments, each containing postings for _1/n_ of the pages associated with that table in the heap. As data is changed, TIN creates mutable segments, which are less efficient for searches but allow easy insertion of new documents. Eventually, a background worker promotes each mutable segment to an immutable segment: unchanging, but much more efficient to search.
>
> After a while, TIN will begin to merge immutable segments into larger immutable segments. This also happens in the background.
>
> Text indexing systems that use [sequential document identifiers](#document-identification) are required to renumber all documents when they create a new, merged segment. As mentioned above, document ID `42` in segment 4 is not the same as ID `42` in segment 7. So when segments 4 and 7 are merged, a new numbering must be applied to the combined set of documents and the entirety of each segment's data gets repacked, recompressed, and rewritten. While it's not quite 2× the storage to merge two segments, it can be close.
>
> TIN does not suffer the renumbering problem nor its downstream write-amplification effects.
>
> Because TIN uses Postgres' `ctid` values as its document identifiers, there is nothing to renumber. A posting like `(190, 17)` means the same thing in every segment. Page-level and offset-level bitmaps mean the same thing in every segment. When TIN merges segments, many bitmaps from each old segment can be reused intact in the new segment. They don't have to be recompressed _or even copied_; TIN can simply transfer ownership of bitmaps stored on disk from the old segments to the new one. This reduces write amplification and saves most of the CPU and I/O costs normally associated with merging segments.
>
> ## [Summary](#summary)
>
> So that's why TIN is at least 8× faster in every benchmark: the downstream effects of choosing `ctid` as the native format for each posting in the index.
>
> If you want to see how fast TIN is on your text data, read more about the [features](https://planetscale.com/docs/postgres/search) or jump straight to the [getting started guide](https://planetscale.com/docs/postgres/search/get-started). We look forward to seeing what you build with it.
>
>
