---
title: "Harness-1 — Search Infrastructure"
type: reference
source: "https://arxiv.org/abs/2606.02373"
parent: "[[Harness-1 offloads search bookkeeping into a stateful harness so a 20B RL policy beats frontier searchers on curated recall]]"
tags: [agentic-search, retrieval, rrf, reranking, vector-db, chroma, harness-engineering]
---

# Harness-1 — Search Infrastructure

How the policy's `search_corpus` / `grep_corpus` / `read_document` calls actually resolve: the Chroma Cloud vector DB, the dense+sparse hybrid retrieval, RRF fusion, the Qwen3-Reranker-8B cross-encoder, and the live-web fallback backend. All file:line refs are in `reference-repos/harness-1`.

## Whole stack at a glance

```
   POLICY emits:  search_corpus({query})   grep_corpus({pattern})   read_document({id})
                        │                          │                       │
        ┌───────────────┴──────────────────────────┴───────────────────────┴────────────┐
        │                       TOOL LAYER  (harness/tools.py)                            │
        │   two interchangeable backends · SAME schemas · SAME "# DOCUMENT ID:" output    │
        └───────────────┬───────────────────────────────────────────────┬────────────────┘
       in-domain        │                                    transfer    │
   (BC+, Web, Patents,  ▼                              (Seal0/FRAMES/     ▼
    SEC, LongSeal)  ┌───────────────────────────┐       HotpotQA)  ┌───────────────────────────┐
                    │   CHROMA CLOUD (vector DB) │                 │   SERPER + JINA (live web) │
                    │   dense + sparse → RRF→50  │                 │   Google search + scrape   │
                    └─────────────┬─────────────┘                 └─────────────┬─────────────┘
                                  └───────────────────┬─────────────────────────┘
                                                      ▼
                                   ┌─────────────────────────────────┐
                                   │  RERANKER  Qwen3-Reranker-8B     │
                                   │  cross-encoder yes/no → top-10   │
                                   └─────────────────────────────────┘
```

Two backends, one reranker, one output format. The policy never knows which backend answered.

---

## 1 · Vector DB — Chroma **Cloud** (read-only)

```python
chromadb.CloudClient(api_key=CHROMA_API_KEY, database=CHROMA_DATABASE)   # config.py:84-87
```

Managed Chroma Cloud (no tenant/host), `chromadb==1.4.0` pinned. **The corpus is pre-embedded offline** — nothing in the repo ever `add()`/`upsert()`/`create_collection()`s. The repo only ever *reads*.

### The chunk record (everything hangs off this schema)

```
   ┌────────────────────────── one Chroma record = a "chunk" ─────────────────────────┐
   │  id             : "4471_2"            ← "<docid>_<chunkidx>"                       │
   │  DOCUMENT       : "…chunk text…"       ← what the model reads                       │
   │  metadata.source: "4471"              ← parent doc id  (read_document key)         │
   │  bm25_vector    : <sparse vec>        ← PRECOMPUTED, stored field                  │
   │  dense_vector   : <1536-d vec>        ← PRECOMPUTED (text-embedding-3-small space) │
   └───────────────────────────────────────────────────────────────────────────────────┘
```

The `<docid>_<chunkidx>` convention is load-bearing: it collapses chunk IDs → doc IDs for recall, and lets `read_document` reassemble a full document.

### Collections & "load balancing"
Most datasets are replicated 44× (`<base>_replica_1 … _replica_44`); the whole load-balancer is `collection = random.choice(self._collections)` (`tools.py:440`). **SEC is the exception**: a single non-replicated `sec_1_4` collection (~2.1M chunks), and SEC uses **fact-level** evaluation.

---

## 2 · Hybrid search — dense + sparse → RRF

A `search_corpus` call embeds the **query** two ways (corpus vectors already exist) and fuses the two rankings server-side:

```
   search_corpus("Acme Foods CFO retirement successor")
                          │
     ┌────────────────────┴─────────────────────┐
     ▼ SPARSE                                    ▼ DENSE
  fastembed Bm25EmbeddingFunction            OpenAI text-embedding-3-small
  (avg_len=4000, task="query")               (1536-d, encoding_format="float")
     → sparse query vector                       → dense query vector  (tools.py:408-409)
     │                                            │
     ▼                                            ▼
  KNN vs each chunk.bm25_vector              KNN vs each chunk.dense_vector
  (limit=25, return_rank=True)               (limit=25, return_rank=True)
     │   top-25 by LEXICAL rank                  │   top-25 by SEMANTIC rank
     └──────────────┬─────────────────────────────┘
                    ▼
        chromadb.Rrf   —  RECIPROCAL RANK FUSION (server-side, tools.py:414)

              score(d) = Σ over retrievers  1 / (k + rank_i(d))

        • fuses RANK position, not raw score  (scales are incomparable)
        • doc missing from a retriever's top-25 → fallback rank = 20
        • k = chromadb 1.4.0 library default (NOT set in repo; canonically 60)
                    │
                    ▼
            top  search_limit = 50  candidates  →  (reranker)  →  [:10]
```

> [!tip] Why RRF instead of score-blending
> Dense cosine and BM25 live on **incompatible scales**, so you can't just add them. RRF only uses each doc's *rank position*: `1/(k + rank)` rewards docs that place high in *either* list, and the constant `k` damps the very top ranks so a doc both retrievers *like* beats a doc only one retriever *loves*. Standard recipe for combining lexical + semantic recall.

---

## 3 · Reranker — Qwen3-Reranker-8B as a yes/no classifier

The 50 RRF candidates are rank-fused but never *read together with the query*. A cross-encoder reranker fixes that. The trick: **it's a binary classifier — the relevance score is literally `P("yes")`.**

```
  50 RRF candidates
        │
        ▼
  ┌──────────────────────── BasetenReranker (default) ──────────────────────────┐
  │  per (query, doc):                                                           │
  │    PREFIX(system: "answer only yes/no")                                      │
  │    + "<Instruct>: {DEFAULT_INSTRUCTION}\n<Query>: {q}\n<Document>: {doc}"      │
  │    + SUFFIX(assistant header, empty <think></think>)                         │
  │  → PerformanceClient.classify()   (batch 16, max_concurrent 256, 360s)       │
  │  → {"yes": p_yes, "no": p_no}   →   score = p_yes   (0.0 if no "yes" label)   │
  │  → sort DESC by score                                          rerank.py:189  │
  └───────────────────────────────────────┬──────────────────────────────────────┘
                                           ▼
              _truncate_results: greedily pack in ranked order until the
              NEXT doc would exceed max_tokens = 4096, then hard-break
                                           ▼
                                hard slice  [:10]   (tools.py:476)
                                           ▼
                10 "# DOCUMENT ID: <id> (<n> tokens)\n<text>" blocks → policy
```

- **Three swappable backends** (one ABC): `BasetenReranker` (default, `.classify()`), `VLLMQwen3Reranker` (local vLLM `/score`, `classifier_from_token=['no','yes']`, port 8011), `ContextualReranker` (real rerank API — CLI-only, not selectable from eval).
- It sits **between RRF-50 and top-10**, so the policy's 10 docs are in *reranker* order.
- **Fail-soft**: missing Baseten creds → `reranker=None`, silently degrading to hybrid-search-only (`evaluate_harness1.py:369-370`).

---

## 4 · The three tools

| Tool | Chroma query | Notes |
|---|---|---|
| `search_corpus(query)` | `Search().rank(Rrf([Knn(bm25), Knn(dense)])).limit(50)` | + rerank → top-10 (the workhorse) |
| `grep_corpus(pattern)` | `Search().where(Key.DOCUMENT.regex(pattern)).limit(5)` | exact regex, **no rerank** |
| `read_document(doc_id)` | `Search().where(Key("source")==docid).limit(300)` | sort chunks by idx → `"".join` → full doc (rerank-to-budget if long) |

---

## 5 · Worked example — a SEC query end-to-end

> **Query:** *"On what date did Acme Foods' CFO announce their retirement, and who succeeded them?"*
> Backend: Chroma collection `sec_1_4`. Gold fact lives in chunk **`4471_2`** (the 8-K press release) + **`4471_3`** (successor bio). *(Numbers below are illustrative but mechanically faithful.)*

### Step 1 — embed the query twice

```
  query ──► fastembed BM25  ──► sparse vector  (weights on: acme, foods, cfo,
            (avg_len=4000)                       retirement, announce, successor…)
        └─► text-embedding-3-small ──► dense vector  (1536-d; captures the CONCEPT
                                                       "executive departure at Acme Foods")
```

### Step 2 — each retriever returns its own top-N (ranks, 1-indexed)

| chunk id | what it is | BM25 rank | Dense rank |
|---|---|---|---|
| `9982_0` | risk-factors boilerplate ("retirement of our CFO could…") | **1** | 8 |
| `2841_0` | a *different company's* CFO retirement (lexical match) | 2 | — (>25) |
| `4471_2` | **the 8-K press release** (gold) | 3 | **1** |
| `4471_3` | successor bio — "Jane Doe to succeed…" (gold) | 12 | 2 |

Lexical search is fooled by keyword-dense boilerplate (`9982_0`) and a wrong-company chunk (`2841_0`); the dense retriever understands the *intent* and ranks the real press release `4471_2` first.

### Step 3 — RRF fusion (k = 60)

`score(d) = Σ 1/(k + rank_i(d))`, missing → fallback rank 20:

```
  4471_2 :  1/(60+3) + 1/(60+1)   = 1/63 + 1/61 = 0.01587 + 0.01639 = 0.03227   ← #1
  9982_0 :  1/(60+1) + 1/(60+8)   = 1/61 + 1/68 = 0.01639 + 0.01471 = 0.03110   ← #2
  4471_3 :  1/(60+12)+ 1/(60+2)   = 1/72 + 1/62 = 0.01389 + 0.01613 = 0.03002   ← #3
  2841_0 :  1/(60+2) + 1/(60+20*) = 1/62 + 1/80 = 0.01613 + 0.01250 = 0.02863   ← #4
                                              (*dense-missing fallback rank)
```

> [!important] The point of fusion
> `4471_2` was only **#3 by lexical** but **#1 by dense**, and it **wins overall** — beating `9982_0`, which was lexical **#1**. A doc ranked *moderately by both* beats a doc ranked *#1 by only one*. Meanwhile the wrong-company `2841_0` (lexical #2, semantically absent) sinks to last.

### Step 4 — reranker re-scores as P("yes")

The cross-encoder reads each `(query, doc)` *together* and emits a yes-probability:

```
  4471_2  P(yes)=0.97   ← states "retire effective March 31, 2024"
  4471_3  P(yes)=0.89   ← names "Jane Doe" as successor
  9982_0  P(yes)=0.12   ← generic boilerplate, no specific answer
  2841_0  P(yes)=0.04   ← wrong company
   →  reranked: 4471_2 > 4471_3 > 9982_0 > 2841_0
```

Note the reranker **promotes `4471_3` above the boilerplate** (RRF had it #3, behind `9982_0`) — because it actually *reads* that the chunk names the successor. This is the reranker's job: true relevance reading fixes RRF's lexical-noise ordering.

### Step 5 — what the policy finally sees (top-10, packed to 4096 tok)

```
# DOCUMENT ID: 4471_2 (412 tokens)
Acme Foods Inc. today announced that Chief Financial Officer John Smith will retire
effective March 31, 2024 …

# DOCUMENT ID: 4471_3 (388 tokens)
… the Board appointed Jane Doe, currently SVP Finance, to succeed Mr. Smith as CFO,
effective April 1, 2024 …

# DOCUMENT ID: 9982_0 (503 tokens)
Risk Factors — The retirement or departure of key executive officers, including our
Chief Financial Officer …
   ⋮  (up to 10)
```

> [!note] Hand-off to the harness
> The first search's **top-8 are auto-seeded** into the curated set (tagged `fair`) by a *harness* mechanism — separate from retrieval. And because SEC is **fact-level**, the answer fact (date = 2024-03-31; successor = Jane Doe) counts as recalled if *any* of its gold chunk_ids is retrieved — here `4471_2` covers it.

---

## 6 · Second backend — live web (Serper + Jina)

Three of the four transfer benchmarks skip Chroma entirely, behind the *same* tool schemas:

```
  _build_tooling() routes by dataset (evaluate_transfer.py):
     seal0qa            → WebToolSet   (general Google)
     frames, hotpotqa   → WikiToolSet  (Google "site:wikipedia.org")
     longsealqa, BC+, … → Chroma

  search_corpus → POST google.serper.dev/search → organic[] → URLMapper (URL→rand int 0..100000)
  read_document → resolve id → retry×3 [scrape.serper.dev THEN r.jina.ai] →
                  if page > 4096 tok & query known: chunk@512 (cl100k) → embed
                  (text-embedding-3-small) → cosine → keep top-10 chunks ; else truncate
```

Same `# DOCUMENT ID:` output, so policy + reranker are backend-agnostic. Caveat: **web `grep` is fake** — Serper has no regex, so the "pattern" is just a keyword query.

---

## 7 · Three confusables (read before you teach this)

> [!warning] THREE different "BM25 / ranking" mechanisms — do not merge them
> ```
> (a) Chroma sparse retriever   fastembed Bm25EmbeddingFunction   → recall (corpus-wide)
> (b) sentence compressor       rank_bm25 BM25Okapi (top-4 sents) → trim each chunk  [OFF by default]
> (c) reranker                  Qwen3-Reranker-8B yes/no          → precision (50→10 reorder)
> ```
> Different libraries, different jobs. (c) is **not** BM25 at all.

> [!warning] TWO different RRF stages — the famous "60" is the eval one
> ```
> (1) in-Chroma RRF   fuses DENSE + SPARSE   per search    k = chromadb library default
> (2) resolved_harness_rrf  k=60, 1/(60+rank)   fuses ROLLOUTS   at eval → top-30
> ```
> The per-search RRF's `k` is **not set in the repo** (`chromadb.Rrf([...])` takes only the Knn list); `k=60` is the *cross-rollout* fusion in `eval_scripts/resolved_harness_rrf.py:33`.

> [!note] Dead params that look live
> - `display_limit` / `search_display_limit` → output is a **hardcoded `[:10]`** (`tools.py:476`); the param is ignored.
> - `snippet_max_chars` / `DEFAULT_SNIPPET_MAX_CHARS=2048` → never applied; only `DOC_TRUNCATION=51,200,000` (≈no-op) truncates.
> - `pre_rerank_chunk_ids` → declared but **never populated**, so the `rerank_recall` metric is always `None`.
> - per-domain **rerank instruction** plumbing (`build_rerank_instruction`, sec/patents/… templates, the gpt-5.4-mini writer) → **never wired**; every rerank uses the single hardcoded `DEFAULT_INSTRUCTION`.

---

## 8 · Constants reference

| Piece | Value | Location |
|---|---|---|
| Chroma client | `CloudClient(api_key, database)` | `config.py:84-87` |
| chromadb pin | `==1.4.0` | `pyproject.toml:13` |
| Dense embedder | `text-embedding-3-small`, 1536-d, `float` | `tools.py:409,483-487` |
| Sparse embedder | `Bm25EmbeddingFunction(avg_len=4000, task="query")` | `tools.py:374,408` |
| KNN per retriever | `limit=25, default=20, return_rank=True` | `tools.py:417-428` |
| Hybrid fuse | `Rrf([Knn(bm25), Knn(dense)])` → `.limit(50)` | `tools.py:414-434` |
| Replicas | `<base>_replica_{1..44}`; SEC = single `sec_1_4` | `search_dataset.py:639` |
| Load balance | `random.choice(self._collections)` | `tools.py:440` |
| Reranker | Qwen3-Reranker-8B, score = `P("yes")` | `rerank.py:189-218` |
| Baseten cfg | `batch_size=16, max_concurrent=256, timeout_s=360` | `rerank.py:157-159` |
| Rerank budget | `max_tokens=4096`, hard-break pack | `rerank.py:140` (eval sets 4096) |
| Display slice | hardcoded `[:10]` | `tools.py:476` |
| grep / read limits | regex `limit(5)` / `limit(300)` chunks | `tools.py:548,646` |
| Concurrency | `BoundedSemaphore(8)`, tenacity 5× exp 4–15s | `tools.py:70,78-101` |
| Cross-rollout RRF | `rrf_k=60`, `1/(60+rank)`, top-30 (eval) | `resolved_harness_rrf.py:33-45` |
| Web search | Serper `google.serper.dev/search` (num 10/5) | `web_tools.py:523` |
| Web read | `scrape.serper.dev` → `r.jina.ai` fallback | `web_tools.py:772-817` |
| Web chunking | 512 tok (cl100k), embed `text-embedding-3-small`, top-10 | `web_tools.py:352,442` |

---

See also: [[Harness-1 — Summary and Key Equations]] · [[Harness-1 offloads search bookkeeping into a stateful harness so a 20B RL policy beats frontier searchers on curated recall]]
