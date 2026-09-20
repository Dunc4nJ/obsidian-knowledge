---
created: 2026-09-20
description: Can Bölük released jegrep, a Rust CLI that answers a plain-language code query by running a real ripgrep scan first, keeping the top 128 lexical candidates, and then spending Jev on them in three escalating stages - one Noul per filename, one Noul per 384-byte source sketch, and finally a Noul plus a line-range Choice on at most 40 full passages - for about $0.004 a query on an 8,177-file repo, while the tweet's claim that it beats gemini-lite agentic retrieval at a tenth of the cost appears nowhere in the repo's own 40-query benchmark, which only compares jegrep against its own previous strategy.
source: https://x.com/_can1357/status/2101435662071185880
author: Can Bölük (@_can1357)
published: 2026-09-19
type: knowledge
tags: [jev, semantic-search, code-search, jegrep, agentic-retrieval, omp, system-one-models, typesafe]
---

# Can Bölük's jegrep turns Jev into a semantic grep by scoring grep-ranked candidates with one Noul per file and a Choice for the line range - $0.004 a query, and the Gemini-lite comparison is nowhere in the repo

Posted 19 September 2026 at 22:17 UTC, sixteen minutes after the repository was created. 130 likes, 5 retweets, 11 replies at capture, with a 22-second silent screen recording attached. Bölük is the author of [[hashline tags lines with content hashes to give LLMs stable edit anchors without reproducing old code|hashline]] and of `oh-my-pi`, the coding-agent harness he calls `omp` in the post. The repo is Rust, MIT, 34 stars at fetch, and its own README describes it as "Natural-language search that works like `grep`. No embeddings, no index, no daemon."

The post is a hedge wrapped around a strong number: "Jav seems to be quite good at semantic search beating gemini-lite agentic-retrieval at 10x less the cost. I have to benchmark a bit more before implementing into omp." He typed "Jav" three times and corrected himself in a one-word reply eleven minutes later. His substantive reply, sixteen minutes after the post, is the most valuable thing in the thread: it describes the algorithm as an active/passive file explorer with a halving relevance threshold.

## Key Takeaways

- **jegrep is a reranker sitting on a grep prior, not a semantic index, and that is the whole cost trick.** Jev never sees the repository. `grep::keywords_from_query` strips stopwords and crudely stems the query, a real ripgrep-class scan counts per-keyword hits across every file, and only the top 128 files by IDF-weighted score are ever shown to the model. The budgets downstream are fixed constants — 20 files read, 40 full passages judged — so cost per query is roughly flat in repository size and depends almost entirely on whether the lexical prefilter surfaced the right file. That is the same lever [[Entire's pgr proves definition-first ranking helps coding agents more than faster ripgrep|pgr found decisive]], where a 9x faster ripgrep moved wall clock by 1.6 seconds and nothing else, while reranking lifted Hit@1 from 26 to 34 percent. It is also the failure mode [[coding agents are bottlenecked by search not coding ability|the code-search-bottleneck note]] warns about: a query whose vocabulary does not appear in the target file is invisible before Jev is ever consulted.
- **The relevance score is literally a Noul probability, which makes this the third independent arrival at the same primitive.** `questions.rs` opens by stating that "Nouls give absolute probabilities, so entries can be thresholded independently and batches are comparable with each other" — the entire design rests on that. [[harness-1-search-infra]] reached the identical shape from the other direction, running Qwen3-Reranker-8B as a binary classifier where "the relevance score is literally `P(\"yes\")`", and [[pg-jev]] does it per database row. The difference is what produces the candidates: Harness-1 fuses KNN and BM25 into 50 candidates, pg-jev takes whatever the query returns, and jegrep uses a keyword grep. None of them embed the corpus.
- **The Gemini-lite comparison does not exist in the repository.** There is a real benchmark harness — 40 labeled queries across pinned checkouts of CPython, Kubernetes, Linux and Postgres, a 27 KB Python runner, and a 580-line results document with macro and micro recall, region recall, line recall, precision lower bounds, cost and latency. Every comparison in it is jegrep against jegrep. Searching the whole repository for Gemini, Flash, Lite, Google or agentic retrieval returns two hits, both filenames in an unrelated test query. The headline result is the new `cascade` strategy beating the previous `window` default by 37.5 percent on cost across 30 queries, not beating anything from Google. The tweet's claim rests on an unpublished measurement.
- **Comparing a scoring pipeline against an agentic retrieval loop is not apples to apples, and the cost gap is the tell.** Jev bills $0.042 per million input tokens with output free, hard-coded as `USD_PER_INPUT_TOKEN` in `src/jev.rs`. An agentic retrieval loop driven by a generative model pays for reasoning turns, output tokens, and repeated context ingestion across turns. A tenth of the cost is roughly what you would expect from removing the loop, before any claim about retrieval quality enters. [[agents are the perfect slow searchers because LLM inference cost dominates per-query retrieval latency|The slow-searcher argument]] makes the same point in reverse: per-query inference is worth paying for because it removes tool-call round trips, which means the saving is structural rather than evidence that one retriever ranks better than another.
- **Precision is reported as a lower bound and it is low.** Cascade's file precision floor is 29.9 to 37.9 percent across the three suites, because the gold labels are positive-only and the benchmark README says plainly that these measurements "cannot establish conventional false-positive rates." Recall is what is actually measured, and it is excellent at 49 of 49 files. Whether jegrep returns four irrelevant files alongside each correct one is unknown from the published numbers. The same document warns that this is "a measured winner, not proof of a global optimum" and advises retesting finalists for overfitting.
- **Nothing calibrates the probabilities the thresholds are compared against.** The README's third bullet is "Calibrated: Every path gets an absolute yes/no probability, so thresholds mean something and batches stay comparable," and the code thresholds on 0.45 for sketch routing and 0.2 for final passage relevance. The vault has no verified calibration figure for Jev: [[Sutro's jev-align uses GEPA to rewrite Jev's decision criteria from five labeled examples - the demo moves labeled-set ambiguity 49.6 points but full-pool certainty only 0.5|jev-align]], the tool built for exactly this, publishes no calibration error, and [[Featherless's Simple Jev reproduces Jev's API on stock open models by remapping every answer to a single-token letter and softmaxing only those logits - no classifier head, and the code stamps every answer calibrated False|the open reimplementation]] stamps every answer uncalibrated. jegrep's thresholds were tuned empirically against its own suites, which works without calibration but does not transfer the way an absolute probability would.

## How jegrep Uses Jev

The default strategy is `cascade`, in `src/strategies/cascade.rs`. There are ten others behind `--strategy`, including the tree-walking `baseline`, `beam` and `deep` family, but cascade is what ships and what the benchmark validated.

**Candidate generation, no model involved.** `grep::keywords_from_query` (`src/grep.rs:208`) keeps quoted phrases whole, lowercases the rest, drops stopwords and tokens under three characters, and applies a suffix stemmer that strips `ing`, `ed`, `es` or `s` when at least four characters remain. `grep::grep_index_observed` then runs a genuine ripgrep-class scan over the tree using `grep-regex`, `grep-searcher` and `rayon`, on top of a walker vendored from `pi-walker` in his own `oh-my-pi` repository. It respects nested gitignores, skips files over 4 MiB, and records per-keyword occurrence counts per file and per directory. `window::idf` derives weights, `window::file_score` ranks every file, and the list is truncated to `JEGREP_CASCADE_CANDIDATES`, default 128.

**Stage one, one Noul per filename.** `questions::dir_batch` renders those candidates as a grouped directory tree where every judgeable entry carries an `eNNN` tag, and emits one `Noul` question per entry against a single shared `state` holding the task description, the query, the tree text and the yes/no criteria. Batches are `batch.min(max_batch).clamp(1, 128)`, default 64 entries per HTTP request. Cascade overrides the default negative criterion so that generated code is not penalized for being generated. Each answer is an independent probability written to `node.name_score`.

**Stage two, one Noul per 384-byte sketch.** The top 20 files by name score are read and cut into at most 24 candidate passages of 8 KiB each. `cascade::sketch` then compresses each passage to 384 bytes by selecting its highest-IDF *verbatim* lines, prefixed with their original line numbers — the comment calls it "a budgeted map of verbatim source lines, not an invented summary," and the selection deliberately favours deep implementation text over headers. Sketch cards from different files are packed into shared requests, `cards.chunks((18000 / sketch_bytes).clamp(1, 48))`, which is 46 cards per call at the default size. Passages scoring below `JEGREP_CASCADE_CUTOFF`, default 0.45, are discarded, and survivors are truncated to a global budget of 40 full passages.

**Stage three, Noul plus Choice on full source.** Only those surviving passages are read in full and judged. `questions::prepare_file` tags every line with an `L0001|` prefix, then asks two questions against one state: a `relevant` Noul ("Does the content of this file actually contain what this search is looking for?") and a `where` Choice over up to 16 line ranges keyed `R00`, `R01` and so on, instructed to "prefer the range where it is implemented or defined over ranges that merely import or reference it." `questions::heat_from` converts that Choice distribution into a heatmap of `HeatRange { start, end, p }`, and `window::merge_heat` merges adjacent ranges above threshold. The module docstring is explicit that sketch judgments are routing signals only: "a reported heat range always comes from a complete passage."

**Batching against the 255 cap.** `main.rs:178` clamps `--max-batch` to 255 with the comment that "Jev caps a Choice at 255 options; this keeps Noul batches in the same ballpark and under the token budget," and `--ranges` is clamped the same way. The default is 128 entries per request with a soft target of 64, and 16 requests in flight. `JEGREP_QUESTION_CHUNK` optionally splits independent Nouls into sub-requests sharing the same state, which the benchmark README notes can double physical HTTP attempts and increase repeated-state tokens. This is a looser batching regime than [[pg-jev]], which sends 20 rows per call.

**Thresholds and caching.** The CLI default is `-t 0.4,0.2`, one threshold per round, where a round ends when the frontier is exhausted and the next round reopens cached judgments at the lower bar. That machinery lives in `tree.rs` and drives `baseline`, `beam` and `deep`. Cascade does not use it: it sets `ctx.rounds = 1` and takes only the last threshold. The consequence is worth noting, because the author's reply describes the multi-round halving design rather than the strategy that actually shipped as the default.

**Transport.** `src/jev.rs` is a small ureq client that posts `{state, model, questions}` to either OpenRouter's `/api/alpha/decisions` or TypeSafe's `/v1/systemone`, defaulting to `jev-latest`, retrying 429 and 5xx with backoff, and failing over between providers when both keys are present.

## The Benchmark Claim

There is a real benchmark, and it measures something other than what the tweet claims.

| What exists in the repo | What the tweet asserts |
|---|---|
| 40 labeled queries: 10 each over CPython, Kubernetes, Linux, Postgres, at pinned commits via `tag.json` | "beating gemini-lite agentic-retrieval" |
| Comparison of `cascade` against jegrep's own previous `window` default | A comparison against a Google model |
| 37.5 percent less estimated API cost, 30 queries, $0.145097 against $0.232162 | "at 10x less the cost" |
| 49/49 files and 93/94 regions recovered | No recall figure given |

The per-suite table reports Cascade at 16/16 files and 29/29 regions on Postgres, 16/16 and 31/31 on CPython, and 17/17 and 33/34 on held-out Kubernetes, with median latencies of 1.87, 1.87 and 3.30 seconds and estimated costs between $0.0045 and $0.0051 per query. The Kubernetes suite was held out, which is the methodologically strongest part: a rival strategy called Sieve passed the Postgres and CPython gates and then fell to 80 percent macro recall on the unseen queries, and was not shipped.

What the document does not contain is any external baseline. No Gemini, no Flash, no Lite, no embeddings system, no ColBERT, no comparison to plain ripgrep on the same queries. Two files under `benches/linux/` and elsewhere mention Google only as filenames in an unrelated Pi query about Vertex integration. The "10x less the cost" figure therefore has no published derivation, and the honest reading is that Bölük ran an informal comparison in his own harness and reported the impression, exactly as his "seems to be" and "I have to benchmark a bit more" signal.

The benchmark README is unusually candid about its own limits, and those caveats are worth carrying forward: gold labels are positive-only so extras are unjudged, region recall requires only overlap within the top three ranges rather than full coverage, the Pareto marking is "a candidate set, not proof of an optimum," and one CPython case achieves about 10.9 percent annotated-line coverage despite finding its files and regions.

## The Author's Replies

Two of the eleven replies are his. The first is the substantive one.

**On how to shape the problem for Jev**, posted sixteen minutes after the original, answering nobody in particular — it reads as the explanation he owed the post:

> tl;dr on how to make the problem jav-shaped:
>
> you give the agent a stateful snapshot of a "file explorer", where items are either passive or active.
>  - passive: folders that we didn't explore, files we didn't open
>  - active: folders we're exploring, files we're reading
>
> jav is asked to rate both kinds for relevance (init K=0.5),
>  - if (p < K): passive items are dismissed, active items continue iterating, or also get dismissed if complete
>  - else: for active files, you record the section as relevant, for everything else, you simply activate.
>
> if you reach the end and did not find anything, half K and repeat (if you cache the results, prev evaluations will be almost entirely re-used, unless you go into a new folder).
>
> it's also very trivially paralellizable which is a nice bonus.

This maps onto the tree-walking strategies in `src/strategies/` rather than onto the shipped `cascade` default. The active/passive distinction is the `State` machine in `tree.rs`, where a finished node "can reopen in a later round when the cached score clears the new threshold." The halving of K is the `--thresholds 0.4,0.2` ladder. The caching claim is accurate for that family and is the reason lowering the threshold is nearly free: the second round re-reads stored probabilities instead of re-asking. Cascade abandoned the multi-round design for a single pass with a cheap sketch tier, and won the benchmark doing so. The parallelism claim holds throughout — questions are independent, 16 requests are in flight by default, and the Pool in `pool.rs` drives them concurrently.

**On the typo**, ten minutes later, in full:

> *jev 🤦

Three people had already noted it. He had written "Jav" three times in the original post and once more in the reply above.

## Other Replies

Nine replies are from other people, and eight are reactions rather than content: three riffs on the "jav" typo, one "More importantly, fast!", one "was about to try this today. thanks for saving me the time & tokens", one image, one GIF. He answered none of them directly.

Two are worth naming. `@developerAEC` wrote "be fast bring it to omp by monday," which is the thread's only pressure on the open question in the post — whether jegrep replaces grep, glob and scout inside his harness. He did not reply. `@OMID_0909` quote-tweeted himself arguing that "Jev is making AI decisions cheaper. But there's another cost sitting upstream of every decision: the cost of getting the right knowledge and context into the decision layer," which is the [[coding agents are bottlenecked by search not coding ability|retrieval-is-the-bottleneck]] thesis restated, and is the reason jegrep is interesting at all.

The post's third named target, `scout`, is not explained anywhere in the thread. The word appears in the repo only as the name of jegrep's own low-cost content prefilter in the benchmark history, where "a scout scoring at least 0.5 unlocks the remaining 16-window budget." The `scout` the tweet proposes replacing is presumably a retrieval tool inside `omp`, which is not public.

## Video

A 22.1-second screen recording at 1638x968, h264 with an AAC track. The audio is digital silence: `volumedetect` reports mean and max volume both at -91.0 dB with all 2,129,920 samples in the bottom histogram bucket. There is no speech, so there is no transcript. Three frames are kept below.

*Opening frame. A shape-sorter meme plays in the terminal, a red ball labelled "SEARCH & RETRIEVAL" being pushed into a hole labelled "JAV" — the visual pun behind his "how to make the problem jav-shaped" reply. The prompt underneath shows the working directory `/work/pi`, confirming that `omp` is the `oh-my-pi` monorepo, and the query `jegrep "antigrav` being typed.*
![[can1357-185880-001.png]]

*Results for the antigravity query, best-last. File scores climb from 0.65 on a `google-antigravity.kdl` rule file to 0.95 on `packages/ai/src/providers/google-gemini-cli.ts`, each annotated "whole file" with a line count, and two files carry line-range heat entries (`L884-973 0.91`, `L232-260 0.93`). The summary line is the mechanism in one row: `listed 8177 · judged 128 · expanded 715 dirs · read 20 files (243.0 KB) · 23 requests · 99.8k tokens · $0.0042 · 2.2s wall / 9.8s api`. Note that 128 judged and 20 files read are exactly the `CANDIDATES` and `FILES` defaults. The next query starts underneath with its configuration echoed: `jev-latest · P=16 N=64 cap=128`.*
![[can1357-185880-002.png]]

*Results for `jegrep "hashline implementation"` — his own prior project, the subject of [[hashline tags lines with content hashes to give LLMs stable edit anchors without reproducing old code]]. Fourteen files under `crates/pi-edit/src/modes/hashline/` score 0.89 to 0.97, with `tokenizer.rs`, `parser.rs` and `input.rs` at the top, and the grammar file `hashline.lark` correctly pulled in at 0.75 from a different directory. Summary: `listed 8177 · judged 128 · expanded 715 dirs · read 20 files (230.3 KB) · 25 requests · 93.1k tokens · $0.0039 · 2.0s wall / 9.7s api`. Below it a third query, `"osx autocorrection stuff"`, shows the live exploration UI mid-scan with per-folder progress bars and "names 0/128".*
![[can1357-185880-003.png]]

Two measured queries on the same 8,177-file repository cost $0.0042 and $0.0039 and returned in about two seconds of wall clock against roughly ten seconds of cumulative API time, which is the parallelism paying off. These are the only end-to-end cost figures attached to the announcement, and they are consistent with the README's stated range of $0.01 to $0.03 for "a few thousand files."

## Where This Sits

jegrep is the no-index corner of the vault's code-search cluster. It agrees with [[Entire's pgr proves definition-first ranking helps coding agents more than faster ripgrep]] that ranking rather than raw speed is the lever, and with [[BrowseComp-Plus isolates the search-agent ceiling - GPT-4.1 scores 14.6 percent finding documents with BM25 vs 93.5 percent when handed them]] that the retriever sets the ceiling. It takes the opposite side from [[indexing text with sparse n-grams and bloom filters eliminates 15-second ripgrep waits in large monorepos]], which makes grep faster rather than smarter, and from [[augment-grep-beat-embeddings]] and [[agentic search with grep and full-file loading replaces RAG when context windows are large enough]], which argue that plain tools plus a persistent agent are already sufficient.

Against the semantic-search camp it is cheaper and stateless but weaker in principle. [[ColBERT-style semantic search beats grep 70 percent of the time for coding agents while using fewer tokens]] and [[ColGREP]] index the corpus and can retrieve on meaning alone; jegrep cannot, because its recall ceiling is whatever the keyword scan surfaces. The counterargument is [[arxiv-embedding-limitations-deepmind]], which shows single-vector embedding dimension formally bounds which result sets are representable at all, and the operational one is that there is no index to build, refresh, or let go stale. [[LATTICE uses LLM-guided semantic tree traversal with calibrated scoring to achieve logarithmic-complexity retrieval that outperforms reranking on reasoning-intensive benchmarks]] is the closest relative in spirit, pairing calibrated model scoring with tree traversal to avoid scoring everything linearly.

The rival architectures are [[CodeScout trains small models via RL to outperform 18x larger LLMs at code search using only terminal commands]] and [[cognition-swe-grep]], which train a small model to drive terminal tools well, and [[Toast 1 takes over the search loop as a specialized subagent - 3.5x fewer tokens at identical Harvey-bench scores and OfficeQA SOTA at 1.15 dollars per task]], which sells the search loop as a subagent. jegrep needs no training at all, which is its strongest practical claim. [[SMFS makes grep itself a vector query so agents get RAG without learning a new tool]] and [[MongoDB's VFS for LangChain Deep Agents redefines grep as server-side hybrid search, splitting file bytes in S3 from a searchable chunk plane in Atlas]] share the "keep the grep interface, change what is behind it" move. [[Dr-DCI caches BM25 hits into a bounded grep-able workspace, making fast corpus retrieval a harness-engineering differentiator for inference providers]] is the two-stage pattern jegrep implements: cheap lexical scoping, expensive verification on a small set.

Returning ranked line ranges rather than raw grep output is a direct response to [[chroma-context-rot]], and it is what makes the tool composable with his own [[hashline tags lines with content hashes to give LLMs stable edit anchors without reproducing old code|hashline]] addressing scheme. Within the Jev folder, this is the first application of Jev to retrieval: [[LangChain's Sydney Runkle puts Jev inside the agent loop as classifier middleware - ModelRouterMiddleware picks the model from the latest user message and AutoModeMiddleware reproduces closed harnesses' dangerous-action gate|Sydney Runkle's middleware]] puts it in the agent loop as a router, [[Cua keeps the candidate menu in application code so Jev only picks an ID - CUA-S1-FORMS is a 706K-parameter form specialist at 99.7 percent against hosted Jev's 83.6, and neither model sees pixels|Cua]] keeps the candidate menu in application code so Jev only picks an ID, and jegrep does the same thing for files. The cost model comes from [[TypeSafe's Jev trades string generation for parallel-sampled typed decisions with calibrated probabilities at $0.042 per MTok - the 193x and 444x claims come from four self-built workflow evals]], the per-call latency from [[LangChain's Jev-as-a-Judge bench puts Jev's quality-score variance 92 to 913x below three LLM judges at $0.34 against Claude's $28.17 - five weather traces, one human oracle, provider-default sampling]], and the threshold-ladder pattern from [[Daniel Ch's How to master Jev prescribes a 0.85 and 0.55 confidence-gate ladder under an LLM that still writes - the decision-layer architecture is additive but every number and all three charts are TypeSafe's own]]. The API detail that matters most here is from [[Annabell frames TypeSafe's Jev as a savant for eval verdicts and routing - three question types, 255 choices, 10 score levels, and a Noul with no confidence field]]: a Noul returns only a probability and carries no confidence field, which is why jegrep thresholds raw probabilities and never reads a confidence value off a file judgment, though it does read one off the `where` Choice. See also [[resources/jegrep]] and [[moc - Jev]].

## Links

- [jegrep on GitHub](https://github.com/can1357/jegrep) — the repository, Rust, MIT, created 2026-09-19
- [The post](https://x.com/_can1357/status/2101435662071185880) — the announcement with the screen recording
- [The mechanism reply](https://x.com/_can1357/status/2101439572152582235) — the active/passive file-explorer explanation
- [oh-my-pi](https://github.com/can1357/oh-my-pi) — his harness, the `omp` of the post; jegrep vendors its `pi-walker` and ports its native grep
- [TypeSafe docs](https://docs.typesafe.ai) — the Jev API jegrep calls
- [OpenRouter decisions endpoint](https://openrouter.ai/api/alpha/decisions) — the default provider path in `src/jev.rs`

## Original Content

> [!quote]- Complete thread, verbatim
>
> **@_can1357 (Can Bölük)** — Sat Sep 19 22:17:59 +0000 2026 — 130 likes, 5 retweets, 11 replies
> https://x.com/_can1357/status/2101435662071185880
>
> Jav seems to be quite good at semantic search beating gemini-lite agentic-retrieval at 10x less the cost.
>
> I have to benchmark a bit more before implementing into omp, but might be a great alternative to grep/glob/scout.
>
> Give it a try! https://github.com/can1357/jegrep
>
> *[One video attached: 22.1s, 1638x968, h264 + AAC. The AAC track is digital silence — ffmpeg volumedetect reports mean_volume -91.0 dB and max_volume -91.0 dB, with all 2,129,920 samples in the -91 dB histogram bucket. There is no speech to transcribe. Frames are embedded in the Video section above.]*
>
> ──────────────────────────────────────────────────
>
> **@_can1357 (Can Bölük)** — Sat Sep 19 22:33:31 +0000 2026
> https://x.com/_can1357/status/2101439572152582235
>
> tl;dr on how to make the problem jav-shaped:
>
> you give the agent a stateful snapshot of a "file explorer", where items are either passive or active.
>  - passive: folders that we didn't explore, files we didn't open
>  - active: folders we're exploring, files we're reading
>
> jav is asked to rate both kinds for relevance (init K=0.5),
>  - if (p < K): passive items are dismissed, active items continue iterating, or also get dismissed if complete
>  - else: for active files, you record the section as relevant, for everything else, you simply activate.
>
> if you reach the end and did not find anything, half K and repeat (if you cache the results, prev evaluations will be almost entirely re-used, unless you go into a new folder).
>
> it's also very trivially paralellizable which is a nice bonus.
>
> ──────────────────────────────────────────────────
>
> **@_can1357 (Can Bölük)** — Sat Sep 19 22:43:32 +0000 2026
> https://x.com/_can1357/status/2101442092631196091
>
> *jev 🤦
>
> ──────────────────────────────────────────────────
>
> **@usr_bin_roygbiv (Roy)** — Sat Sep 19 23:16:57 +0000 2026
> https://x.com/usr_bin_roygbiv/status/2101450502034653621
>
> @_can1357 I love jav myself
>
> ──────────────────────────────────────────────────
>
> **@GeorgeRD_Builds (George Builds)** — Sun Sep 20 07:23:02 +0000 2026
> https://x.com/GeorgeRD_Builds/status/2101572830022529465
>
> @_can1357 More importantly, fast!
>
> ──────────────────────────────────────────────────
>
> **@toprak_dikici (Toprak)** — Sun Sep 20 00:05:08 +0000 2026
> https://x.com/toprak_dikici/status/2101462629868884061
>
> @_can1357 holy typo
>
> ──────────────────────────────────────────────────
>
> **@kaanaricioglu (Kaan)** — Sat Sep 19 22:43:53 +0000 2026
> https://x.com/kaanaricioglu/status/2101442182213226734
>
> @_can1357 was about to try this today. thanks for saving me the time & tokens
>
> ──────────────────────────────────────────────────
>
> **@developerAEC (aec)** — Sat Sep 19 22:42:02 +0000 2026
> https://x.com/developerAEC/status/2101441716754465079
>
> @_can1357 be fast bring it to omp by monday
>
> ──────────────────────────────────────────────────
>
> **@Viking2333 (Lemon)** — Sun Sep 20 01:58:01 +0000 2026
> https://x.com/Viking2333/status/2101491035805487259
>
> @_can1357 jav 😉
>
> ──────────────────────────────────────────────────
>
> **@OMID_0909 (EKOS _ AGI 🦊 🇮🇷)** — Sat Sep 19 23:43:25 +0000 2026
> https://x.com/OMID_0909/status/2101457162950123648
>
> @_can1357 https://t.co/bOgir4jqoi https://t.co/hMJ256CaR7
> PHOTO: https://pbs.twimg.com/media/HSngJiwWYAAzAJx.jpg
> >  QT @OMID_0909:
> > Jev is making AI decisions cheaper.
> >
> > But there's another cost sitting upstream of every decision: the cost of getting the right knowledge and context into the decision layer.
> >
> >  https://x.com/OMID_0909/status/2101437950386921704
>
> ──────────────────────────────────────────────────
>
> **@retardrutide (Malcolm Caldwell Appreciator)** — Sat Sep 19 23:51:48 +0000 2026
> https://x.com/retardrutide/status/2101459273138176084
>
> @_can1357 https://t.co/vizEmsiME0
> GIF: https://pbs.twimg.com/tweet_video_thumb/HSniER6bMAAeWP1.jpg
