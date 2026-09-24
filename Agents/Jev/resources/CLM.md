---
created: 2026-09-24
source: https://github.com/Contrastive-LM/CLM
type: resource
tags: [jev, clm, contrastive, system-one-models, bi-encoder, verifier, best-of-n, qwen3, open-weights, stanford, hazy-research]
status: exploring
---

## What it is

`Contrastive-LM/CLM` serves **CLM-8B**, a "System One model" from Jacky Kwok and co-authors at Stanford, Hazy Research and NVIDIA Research, behind an API that deliberately copies TypeSafe's: `POST /v1/systemone` taking a state plus `noul` / `choice` / `score` questions. CLM is a **bi-encoder** — a state encoder and an action encoder, each a frozen Qwen3-8B plus a ~20M-parameter trainable MLP projection head — trained with bidirectional InfoNCE so a softmax over the two embeddings' scaled cosine *is* the answer distribution.

The repo is the inference half of the project: the `clm` package, a browser playground, the fine-tuning script, and a T-Rex game example that races CLM against Jev. The scaling experiments, data pipelines and paper figures live in a separate research repo (`jackyk02/contrastive_learning`). Apache-2.0, created 2026-09-23, 33 stars at capture.

## Why it's interesting

It is the first Jev reimplementation with an actual training recipe, published scaling laws, and open weights — as opposed to [[jevlike]] (a trained cross-attention option head) or [[Featherless's Simple Jev reproduces Jev's API on stock open models by remapping every answer to a single-token letter and softmaxing only those logits - no classifier head, and the code stamps every answer calibrated False]] (stock LM logits, no training). It is also the first to adopt TypeSafe's endpoint name and wire format verbatim, so a request written against Jev replays unchanged.

The architectural bet is **disaggregation**: because the state and the candidate actions go through *different* encoders, their embeddings cache independently. Jev, per the authors, caches state only. When the action set is fixed and the state moves — game controls, a tool registry, a menu of UI affordances — CLM re-encodes one thing per step and does a dot product against everything else.

## How it works

**Two processes.** A vLLM pooling server holds Qwen3-8B on the GPU at `:8090` and answers OpenAI-format `/v1/embeddings`; `clm-serve` runs the tiny heads (CPU by default, GPU when torch sees one) at `:8700`. The reference head, `CLM_v0.1-8B.pt`, is 75 MB and downloads from Hugging Face on first run.

**The heads** (`src/clm/heads.py`). A checkpoint is a `torch.save` dict of `state_head` / `action_head` state dicts, a `logit_scale`, and a `cfg` of `width`, `depth`, `projection_dim`, `activation`, `layernorm`, `residual`. Each head is an MLP `4096 -> width -> ... -> 512` over the encoder's last-token hidden state, with optional LayerNorm and residual hidden blocks. The released configuration, per the blog's collapsed architecture note, is a three-layer MLP `4096 -> 1536 -> 1536 -> 512` with GELU activations and a LayerNorm on the hidden layer — matching the `bon_eval.py` defaults of width 1536, depth 3, `layernorm` true. The pair score is `exp(logit_scale) * cos(state_head(s), action_head(c))`, clamped at 100. Heads hot-reload when the file's mtime changes, and each reload bumps a `generation` counter that invalidates cached rows.

**Question to candidates** (`src/clm/schema.py`, `engine.py`). `build_pairs` turns a typed question into one state text (the state with the question's instructions appended) and a list of candidate texts. A `choice` embeds each option's *description*, or the key when the description is empty; a `score` embeds the ordered rubric levels; a `noul` becomes a true/false pair. The engine embeds states and candidates separately, takes `scale * cosine / temperature`, and softmaxes. `Engine.rank` is the same primitive with the candidates supplied directly, which is what best-of-N selection uses. A `clm-raw` model skips the heads entirely and cosines in the encoder's own 4096-d space — a built-in ablation.

**Two caches, not one.** `embedder.py` keeps a 200k-entry LRU of L2-normalised encoder embeddings keyed by text. `cache.py` reserves a flat device arena at start-up the way vLLM claims its KV cache — a fraction of device memory (`0.02` default) or an absolute size — and carves fixed-width pools from it (512-d projections, 4096-d raw). It never grows, so a long-running server cannot drift into an OOM kill. Rows are keyed by `head@generation` plus the text, with LRU eviction. A hit skips the encoder call, the host-to-device copy and the head's forward pass. The README's own measurements on an RTX 4090 put a revisited state at 0.6–0.7 ms against 28 ms for a fresh one.

**Serving detail worth knowing.** The documented encoder launch uses `--max-model-len 2048`, and `Embedder` sends `truncate_prompt_tokens: 2048`. The reference configuration therefore truncates any state longer than 2048 tokens. The DeepSWE and Terminal-Bench heads are separate 8k checkpoints.

**Fine-tuning** (`train/finetune.py`). Only the heads train, on precomputed frozen-encoder embeddings, so a full Nemotron pre-training run is about an hour on one RTX 4090. `--task clm` trains the contrastive path; `--task choice` trains typed decisions; `--task prm` trains the step-scoring path used for agentic trajectories.

**Evaluation** (`evaluation/bon_eval.py`). Scores every trajectory step, takes the **mean of the final `--window` step scores** (12 by default) as the trajectory score, and picks the argmax. It reports three numbers per task set: the selector's rate, `random_pick` (the expected rate of choosing uniformly, which the release charts label "Pass@1"), and `oracle_any` (any of N passes). Best-of-N is an **exact expectation over uniform N-subsets** with uniform tie-breaking, not a sampled estimate.

## Key links

- [GitHub](https://github.com/Contrastive-LM/CLM) - Apache-2.0, Python, 33 stars at capture
- [Blog](https://contrastive-lm.notion.site) - the primary write-up, with the scaling-law fits
- [Discord](https://discord.gg/5dAQEDJBs)
- [Hugging Face org](https://huggingface.co/Contrastive-LM)
- [CLM-v0.1-8B](https://huggingface.co/Contrastive-LM/CLM-v0.1-8B) - Apache-2.0, `CLM_v0.1-8B.pt` at 75,557,149 bytes
- [deepswe-clm-heads-8k](https://huggingface.co/Contrastive-LM/deepswe-clm-heads-8k) - MIT, the head behind the 31/38 DeepSWE result
- [deepswe-clm-train-embeddings-8k](https://huggingface.co/datasets/Contrastive-LM/deepswe-clm-train-embeddings-8k) - MIT, 6.20 GB, 405,919 steps
- [CLM-v0.1-Pretrain-Nemotron](https://huggingface.co/datasets/Contrastive-LM/CLM-v0.1-Pretrain-Nemotron) - 1,875 files across six shards, 1,023.5 GB of precomputed embeddings, no card
- [examples/t_rex](https://github.com/Contrastive-LM/CLM/blob/main/examples/t_rex/README.md) - the CLM-vs-Jev dinosaur runner

## Notes

- **Licensing is not uniform.** The repo and the CLM-8B weights are Apache-2.0 (the base Qwen3-8B is too). The DeepSWE heads and their embedding dataset are MIT. The pre-training corpus derives from NVIDIA's Nemotron DQA and the mid-training negatives were generated by Gemini 2.5 Flash-Lite, so the provenance stack is wider than either repo license covers.
- **The DeepSWE dataset card leaks an earlier identity.** It is titled "DeepSWE PRM training embeddings", describes itself as the data "the released DeepSWE PRM heads were fine-tuned on", and points at `tarsur385/deepswe-prm-heads-8k` under a personal namespace. `finetune.py` still carries a `--task prm` path. So the verifier half of CLM looks like a rebadged process reward model that predates the CLM framing, which bears on `@schemaevolves` asking whether this was a response to Jev or prior private work.
- The pre-training dataset repo is real but uncarded: 1 TB of `.npy` question and answer embedding chunks plus parquet metadata, no README.
- `GET /v1/models` advertises `clm-latest` with `release_date: 2026-09-19`, four days before the public launch.
- `--cors` is off by default with an explicit reason in the README: an API key would otherwise travel in a header any page could send.
- Graduated into [[Stanford's CLM-8B is an open bi-encoder System One model caching actions apart from state - 13x over Jev at 1K candidates and 3 of 38 DeepSWE tasks over random where Jev loses 1]].
