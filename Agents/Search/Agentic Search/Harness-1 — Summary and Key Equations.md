---
title: "Harness-1 — Summary & Key Equations"
type: summary
source: "https://arxiv.org/abs/2606.02373"
parent: "[[Harness-1 offloads search bookkeeping into a stateful harness so a 20B RL policy beats frontier searchers on curated recall]]"
tags: [agentic-search, rl, harness-engineering, retrieval, context-engineering]
---

# Harness-1 — Summary & Key Equations

> [!abstract] One-line thesis
> A multi-turn search agent must do **two jobs**: ==semantic decisions== (what to search, what to keep, what to verify, when to stop) and ==mechanical bookkeeping== (what have I seen, dedup it, which entities bridge documents, cap the output, track budget). Prior RL-search systems force the **policy** to reconstruct the bookkeeping from a growing transcript every turn. **Harness-1 moves all bookkeeping into the environment ("the harness")** so a 20B `gpt-oss-20b` policy learns *only* the semantic part. Result: **0.730 average curated recall** across 8 benchmarks — **+11.4 pts** over the best open agent, beating GPT-5.4 / Sonnet-4.6 / Kimi-K2.5 on average.

---

## 1. The core reframing: harness design *is* the method

Define an agent interface as $\mathcal{I} = (\mathcal{A}, \mathcal{O}, T, r)$ — actions, observation renderer, transition, reward.

**Tool orchestration** fixes the interface $\mathcal{I}_0$ and trains a policy inside it, where an action just produces the next observation:

$$
a_t \mapsto o_{t+1}, \qquad \max_{\theta}\; \mathbb{E}\!\left[R(\pi_\theta;\, \mathcal{I}_0)\right]
$$

**Stateful harnessing** changes the interface itself, adding persistent, editable retrieval state $s_t$ that actions *edit*:

$$
s_t = (P_t,\, C_t,\, I_t,\, D_t,\, G_t,\, V_t,\, H_t,\, B_t)
$$
$$
(s_t, a_t) \mapsto (s_{t+1}, o_{t+1}), \qquad \max_{\theta}\; \mathbb{E}\!\left[R(\pi_\theta;\, \mathcal{I}_{\text{Harness-1}})\right]
$$

> [!important] The single idea to remember
> This is an ==MDP **state-space** redesign==, **not** a better policy on the same MDP. The policy still learns tool use, but over a *state representation the harness maintains for it*. The paper calls this **stateful cognitive offloading**.

**Teaching analogy — the librarian's desk:** the 20B policy is a researcher who can only *point* ("search this", "file these as high-importance", "double-check this claim", "I'm done"). The **desk** runs the hybrid search, throws out duplicate photocopies, highlights the 4 most relevant sentences, keeps the index current, enforces the 30-slot folder cap, and stamps a status note after every move. The researcher never files or sorts.

![[harness-1-02373-002.png]]
*Figure 2 — Overview. Policy makes semantic decisions; the harness maintains the state around them. The **same** state interface is reused for teacher rollouts, SFT replay, CISPO RL, and evaluation.*

---

## 2. The state machine (what the harness owns)

`WorkingMemory` (`ultra_core.py`) holds **two tiers**: a compact **prompt-facing** tier and an **outer full-text store** the model never sees directly (it must `review_docs`/`read_document` to pull text back in).

| State | Meaning | Code field |
|---|---|---|
| $P_t$ | candidate pool (everything seen, deduped) | `pool_ids` / `pool_id_set` |
| $C_t,\, I_t$ | curated set ($\le 30$) + importance map | `curated_ids`, `curated_importance` |
| $D_t$ | full-text store (revisitable, **outer tier**) | `doc_store` |
| $G_t$ | evidence graph (entity $\to$ docs) | `EvidenceGraph` |
| $V_t$ | verification cache (claim $\to$ doc $\to$ verdict) | `verify` outputs |
| $H_t$ | search history (tool, returned/novel counts) | `search_history` |
| $B_t$ | budget marker `[Context: X/Y]` | rendered token gauge |

**Turn loop (Algorithm 1):** render state $\to$ policy emits **one** Harmony action $\to$ harness executes, dedups/compresses, mutates state, writes a programmatic `[STATUS]` summary $\to$ re-renders. ==Reward is computed only at episode end.==

> [!tip] Budget-safe rendering (5-pass degradation)
> Prompt budget $= 30{,}720$ tokens $= 32{,}768 - 2{,}048$ (generation). On overflow the renderer degrades in 5 passes — normal $\to$ drop pool section $\to$ truncate old reasoning to 100 chars $\to$ drop oldest recent turn $\to$ bare minimum (system + query). Pass 5 always fits, so **no rollout dies from overflow, and the curated set + recent turns are the *last* things cut.**

---

## 3. The action surface (8 tools)

| Tool | Effect |
|---|---|
| `fan_out_search(queries)` | up to **5** queries, each hybrid (RRF + rerank) |
| `search_corpus(query)` | single hybrid search (BM25 + dense, RRF, rerank) |
| `grep_corpus(pattern)` | exact regex over the corpus (limit 5) |
| `read_document(doc_id)` | full text, reassembled from chunks, reranked to budget |
| `review_docs(doc_ids)` | re-render seen docs from $D_t$ — **free, no corpus call** |
| `curate(add, remove, importance)` | **central state edit**: edit $C_t / I_t$ |
| `verify(doc_ids, claim)` | per-doc LLM entailment check $\to$ records to $V_t$ |
| `end_search(reasoning)` | terminate, submit $C_t$ |

---

## 4. The five derived-state mechanisms (the "magic")

These make the state **learnable**; each one's removal is what the ablations measure.

1. **Auto-seed (warm-started curation).** First successful search drops its top-$k{=}8$ reranked docs into $C_t$ tagged `fair`.
   > [!warning] Why this is *the* trainability trick
   > Without it, hard queries all terminate with **identical empty-set rewards** and RL cannot tell good rollouts apart. It converts "build $C_t$ from scratch" into "**refine** an existing set."
2. **Importance-tagged subtractive curation.** Tags ranked `very_high`$=0 <$ `high`$=1 <$ `fair`$=2 <$ `low`$=3$. At the cap $M{=}30$, evict the lowest-importance doc **only if** the incoming doc outranks it, else reject (`[CAPACITY]`). `very_high` requires prior `verify`.
3. **Evidence graph $G_t$.** Regex extracts proper nouns / years / dates and maps entity $\leftrightarrow$ docs; renders **bridge** docs (entities in $\ge 2$ docs) and **singletons** (follow-up leads). Turns "what have I seen about $X$?" from a transcript reread into a lookup.
   - Regex: `[A-Z][a-z]+(\s+[A-Z][a-z]+){0,3} | \d{4}s? | \d{1,2}/\d{1,2}/\d{2,4}` (matches **1-to-4-word** capitalized spans).
4. **Sentence-BM25 compression.** Per returned chunk, keep top $K{=}4$ sentences by BM25-vs-query, **re-sorted to original order**. (Not applied to `read_document`.)
5. **Two-level dedup.** Chunk-ID **and** content fingerprint (**MinHash-LSH**, Jaccard $\theta{=}0.85$, 64 perms, 5-gram shingles). Near-dupes are hidden from the prompt but still credited in trajectory recall.

---

## 5. Retrieval primitives & equations

**Hybrid search** fuses a sparse BM25 retriever and a dense (`text-embedding-3-small`) retriever via **Reciprocal Rank Fusion**:

$$
\text{RRF}(d) = \sum_{i \in \{\text{bm25},\,\text{dense}\}} \frac{1}{k + \text{rank}_i(d)}, \qquad k = 60
$$

Pipeline per search: KNN top-25 each $\to$ fuse to 50 $\to$ **Qwen3-Reranker-8B** reorders $\to$ policy sees **top 10**. (The reranker is run as a yes/no classifier; the score is $P(\text{"yes"})$.)

---

## 6. The reward (terminal-only, $\beta = 2$)

![[harness-1-02373-003.png]]

$$
\mathcal{R} \;=\; \underbrace{w_F F_\beta}_{\text{set quality}} \;+\; \underbrace{w_\tau \rho_\tau}_{\text{trajectory coverage}} \;+\; \underbrace{w_A \rho_A + w_{\tau A}\rho_{\tau A}}_{\text{answer evidence}} \;+\; \underbrace{B_A\,\mathbf{1}[\rho_A > 0]}_{\text{answer bonus}} \;+\; \underbrace{w_{\text{div}} \min\!\left(\tfrac{\nu}{\nu_0}, 1\right)}_{\text{tool diversity}} \;-\; \underbrace{w_{\text{miss}}\,(\rho_{\tau A} - \rho_A)_+}_{\text{answer miss}} \;-\; \underbrace{\pi_{\text{turn}}(t)}_{\text{turn penalty}}
$$

where $\rho_\tau$ = trajectory recall, $\rho_A$ = curated final-answer recall, $\rho_{\tau A}$ = trajectory final-answer recall, $\nu$ = distinct tools used, $\nu_0$ = diversity target. Clipped below by $R \ge 10^{-3}$ for any formatted episode.

**Short-circuits (bypass the formula and the floor):**

$$
C_t = \varnothing \text{ at termination} \;\Rightarrow\; \mathcal{R} = \pi_\varnothing = -0.2, \qquad \text{format error} \;\Rightarrow\; \mathcal{R} = -0.5
$$

**The $F_\beta$ term** weights recall $4\times$ precision:

$$
F_\beta = \frac{(1+\beta^2)\,p\,r}{\beta^2 p + r}, \qquad \beta = 2 \;\Rightarrow\; F_2 = \frac{5\,p\,r}{4p + r}
$$

> [!important] The cleverest term — the answer-miss penalty
> $(\rho_{\tau A} - \rho_A)_+$ punishes exactly the gap between **finding** an answer doc anywhere in the trajectory and **promoting** it to the curated set. It directly targets the ==selection gap== — the paper's central failure mode ("found it but didn't keep it").

---

## 7. The three recalls (the whole story is in the *gaps*)

Let $C_q$ = curated set, $P_q$ = trajectory pool, $R_q$ = all relevant qrels, $A_q$ = gold answer docs ($A_q \subseteq R_q$).

$$
\text{Recall}(q) = \frac{\lvert C_q \cap R_q \rvert}{\lvert R_q \rvert}, \qquad
\text{FinalAnswerRecall}(q) = \frac{\lvert C_q \cap A_q \rvert}{\lvert A_q \rvert}, \qquad
\text{TrajRecall}(q) = \frac{\lvert P_q \cap R_q \rvert}{\lvert R_q \rvert}
$$

> [!note] Read them as a funnel with two leak points
> - **TrajRecall** — did the answer reach the desk inbox at all? *(discovery skill)*
> - **Recall** — did it make it onto the 30-slot keep-shelf? *(selection skill)*
> - **FinalAnswerRecall** — was the specific **gold answer** doc on the shelf? *(the money metric)*
>
> The ==TrajRecall $-$ Recall gap== is the single most diagnostic number: a big gap means the harness *found* the answer but the policy failed to *curate* it — exactly what auto-seed / importance / the miss-penalty target.

---

## 8. Training pipeline

$$
\text{Teacher rollouts (GPT-5.4)} \to \text{SFT replay (}\sim\!900\text{ traj, 1 datum/turn)} \to \text{SFT ckpt (gpt-oss-20b LoRA)} \to \text{CISPO RL} \to \textbf{Harness-1}
$$

**SFT — teach the *interface*, not the task.** GPT-5.4 runs as a live agent inside the same harness with turn-level coaching (curate-after-search, verify-before-`very_high`, backtrack-after-low-yield, terminate-near-budget). Keep trajectories with recall $\ge 0.10$; expand each into **one supervised datum per turn**; loss masked to that turn's action tokens only:

$$
\text{weights} = [\,\underbrace{0,\dots,0}_{\text{context}},\, \underbrace{1,\dots,1}_{\text{target action}}\,]
$$

> [!quote] That mask line *is* the thesis in code
> The student is trained to predict the **decision**, never to reproduce the **bookkeeping** (which is read-only context).

**RL — CISPO** (clipped importance-sampling policy optimization) from the SFT checkpoint. Group-relative advantage = mean-centering within each group of $G{=}8$ same-query rollouts (no $/\sigma$):

$$
A_i = R_i - \frac{1}{G}\sum_{j=1}^{G} R_j, \qquad G = 8
$$

Groups with identical rewards (zero advantage variance) are dropped. Full-trajectory rollouts, terminal-only reward, importance weight clipped at 5 (no lower clip).

![[harness-1-02373-006.png]]
*Figure 5 — Training dynamics. Without the diversity bonus, tool use collapses $6 \to 3.5$ and curated recall plateaus at ~0.53. With it, diversity stabilizes ~4.3 and recall reaches ~0.60.*

---

## 9. Why it's convincing — the three results

![[harness-1-02373-004.png]]

1. **Transfer *grows* off-distribution** — $+17.0$ pts on held-out benchmarks vs $+7.9$ on training-family (a $2.2\times$ gap). If capability lived in the **weights** it would *decay* off-distribution; it grows because the policy learned domain-general **operations over state**, and the harness is the generalization surface.
2. **The harness is a measurable confound.** Hold the model fixed at GPT-5.4, swap only the harness:
   $$
   \text{Curated Recall:}\quad 0.511 \;\xrightarrow{\text{Context-1 harness}}\; 0.807 \;\xrightarrow{\text{Harness-1 harness}}\; 0.849 \quad (\textbf{zero training})
   $$
   $\Rightarrow$ comparing trained agents through **different** harnesses inflates the apparent "training" delta. A field-wide methodology warning.
3. **Ablate the *whole* harness, keep the weights $\Rightarrow -12.2\%$ recall** — larger than any single component. Signature is always identical: the policy keeps *searching* (`search_corpus` $\to 90\%{+}$ of actions, `read`/`verify` drop $2\text{–}6\times$) but ==cannot rank what it has seen==.

![[harness-1-02373-001.png]]
*Figure 1 — Harness-1 (20B) reaches 0.730 curated / 0.807 trajectory recall; highest trajectory recall of **all** models, second curated only to Opus-4.6. Same `gpt-oss-20b` base scores 0.262 untrained.*

---

## 10. Constants reference (deployed run)

| Constant | Value | Constant | Value |
|---|---|---|---|
| Curated cap $M$ | 30 | Auto-seed top-$k$ | 8 (`fair`) |
| Fan-out max queries | 5 | Sentence-compress $K$ | 4 |
| MinHash Jaccard $\theta$ | 0.85 | MinHash perms | 64 |
| Evidence-graph max entities | 8 | Recent window `RECENT_K` | 5 |
| Prompt token budget | 30,720 | Model ctx limit | 32,768 |
| RRF $k$ | 60 | Reranker | Qwen3-Reranker-8B |
| **Reward weights** | | **Training** | |
| $w_F$ (set quality) | 0.7 | SFT LoRA rank / epochs | 32 / 3 |
| $w_\tau$ (trajectory) | 0.3 | SFT lr | $5\times10^{-6}$ |
| $\beta$ ($F_\beta$) | 2.0 | RL lr | $1\times10^{-5}$ |
| $w_A$ (FA recall) | 0.8 | RL group size $G$ | 8 |
| $w_{\tau A}$ (traj FA) | 0.4 | RL batch (queries/step) | 128 |
| $B_A$ (FA bonus) | 1.0 | RL algorithm | CISPO (clip $[0,5]$) |
| $w_{\text{miss}}$ (FA miss) | 0.35 | RL data | SEC train (3,453) |
| $\pi_\varnothing$ (empty-set) | $-0.2$ | $\nu_0$ (diversity target) | 6 |

---

## 11. ⚠️ Paper vs. actual repo code

> [!warning] Where `launch_rl.sh` diverges from the paper's Tables 5 & 6
> The reward **structure** and core weights above match the code exactly. The *peripheral knobs* in the released launcher differ:
>
> | Quantity | Paper | Repo `launch_rl.sh` |
> |---|---|---|
> | KL anchor | "no KL anchor" ($0$) | $\mathbf{0.005}$ (vs SFT sampler) |
> | Tool-diversity weight $w_{\text{div}}$ | $0.15$ | $\mathbf{0.5}$ (+ 0.08/missing-tool penalty) |
> | Turn penalty max | $0.02$ (start turn 20) | $\mathbf{0.0}$ (disabled, start 24) |
> | `MAX_TURNS` | $40$ | $\mathbf{128}$ (RL); 35–40 at eval |
> | Scale | 80 steps / ~82K rollouts | $\mathbf{\sim}$**230 steps / ~235K rollouts** |

> [!note] Other code facts the paper smooths over
> - **Two harnesses in one repo.** `tools.py` / `agent.py` / `prompts.py` are the *Context-1-style baseline* (PruneChunksTool, `<Document id=>` output). The real Harness-1 machine is `ultra_core.py` + `train_rl.py`'s `SlidingWindowSearchEnv`.
> - **Headline features are `V8D_*` env flags, default OFF** — flipped ON by the launch scripts. Bare module $=$ plain RRF agent.
> - `fan_out_search`'s "5 parallel queries" run in a **sequential** loop.
> - `verify` is an **LLM call** (`gpt-5.4-mini`, temp 0, $\le$20-word rationale), not a deterministic check.
> - `filter_sft_v8d.py` is referenced by the launch scripts but **missing** from the repo; the only real filter is train-time `min_recall = 0.1` (~899 raw $\to$ ~717 kept).
> - Advantages are **mean-centered only** (no $/\sigma$); terminal reward is broadcast **uniformly** to every action token.

---

## 12. Related & lineage

- Direct predecessor: [[Context-1 proves agentic search can be 20B-scale and retrieval-dominant without frontier models|Context-1]] — same base/trainer/benchmarks, but trained the **policy** to self-edit context; Harness-1 makes the **environment** do the editing.
- Same conclusion, sharper diagnostic than [[Search-R1 proves RL-only training teaches multi-turn search without supervised fine-tuning warmup|Search-R1]] / [[WebExplorer trains 8B web agents via SFT and RL to outperform frontier models on deep research tasks|WebExplorer]]: gains **grow** under shift instead of decaying.
- Harness-as-interface echoes [[the agent harness is the RL training environment not deployment infrastructure bolted on after|harness-as-training-environment]] and [[Model-Harness-Fit means tool surfaces and citation tags are post-trained into the model, not interchangeable|Model-Harness-Fit]].
