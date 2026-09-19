---
created: 2026-09-19
source: https://github.com/vinnylarouge/jevlike
description: Independent open-source starter model that reproduces the input/output shape of TypeSafe AI's Jev — text context plus N text options in, one probability per option out, in a single forward pass.
type: resource
tags: [jev, system-one-models, open-source, classifier, attention, pytorch]
status: unread
---

## What it is

Jevlike is a small PyTorch package that trains a model to choose among a changing list of text options. It takes a context string and a list of `N` option strings and returns one probability per option in a single forward pass, rather than writing an answer token by token. The README is explicit about its relationship to [[pg-jev|Jev]]: "Jev is TypeSafe's commercial model for this kind of task. TypeSafe has not published its design. This repository is an independent starter model with the same input and output shape."

It is MIT-licensed, version 0.1.0, authored under the name Minimal Labs, and depends only on `numpy` and `torch` for the core path. It appeared on 2026-09-16, one day after the TypeSafe launch post, and had 971 stars within days. Four console scripts ship with it: data generation, training, evaluation, and single-prediction.

## Why it's interesting

This is the community reverse-engineering the *shape* of a System One Model within a day of the announcement, and in doing so it makes the interface legible in a way the launch post does not. Stripped of the marketing frame, Jev's contract is a fixed-cardinality choice head: you must hand it the complete option list up front, and it returns a distribution over exactly those options. It is not a language model with a constrained decoder bolted on. Jevlike demonstrates that the *interface* is reproducible in roughly 700 lines of Python, which relocates the interesting question to what TypeSafe actually did with training data and calibration.

The contrast with Jev is instructive. Jev supports cardinality up to 255 and uses a two-stage score-then-choose path for higher cardinality; jevlike has no stated cap, requires a minimum of two options, and does a single softmax across whatever it is given. Jev's headline claim is calibrated probabilities; jevlike computes expected calibration error in its evaluator but publishes no calibration number anywhere.

## How it works

*The option-attention architecture: each option queries the context, receives an attended context vector, and becomes one probability*
![[jevlike-001.svg]]

**Option encoding.** Each option string is turned into one vector. Under the default encoder, option bytes are embedded and mean-pooled over the option's token mask. Under the frozen Hugging Face path, the option is run through the pretrained encoder and its last hidden states are mask-mean-pooled.

**Option-as-query attention over context.** Each option vector becomes a query. The query assigns attention weights over the context tokens, and those weights produce one context vector specific to that option. Both context and options are layer-normalised first, and query, key, and value are separate bias-free linear projections down to a `rank`-dimensional space. Padding positions in the context are masked to the dtype minimum before the softmax.

**Shared dot-product scorer.** The score for an (option, context) pair is the dot product of that option's query with its own attended context vector, divided by the square root of the rank. One shared scorer handles every option, which is what lets the option count vary per row.

**Softmax across options.** A single softmax over the option axis converts scores into probabilities that sum to one. Inactive option slots are masked out. Training is plain cross-entropy against the correct index, with AdamW at learning rate 2e-3, weight decay 1e-4, gradient clipping at 1.0, and best-validation-NLL checkpointing.

**Two encoder paths.** The default `tiny` encoder learns byte embeddings from scratch — a 257-entry embedding table plus learned positions, defaulting to width 64 and rank 64, truncating context to 192 bytes and each option to 32 bytes. The optional path wraps any Hugging Face encoder with `requires_grad_(False)`, so only the small scorer head trains. The checkpoint then stores the head and the encoder *name*, not the frozen weights, so loading requires access to the same Hugging Face model.

**Data format.** One JSON object per line, with a zero-based label index:

```json
{"context":"The customer needs a refund.","options":["refund","sales","technical support"],"label":0}
```

Each row may carry a different number of options, minimum two.

**Training quickstart.**

```sh
uv venv
source .venv/bin/activate
uv pip install -e '.[dev]'

jevlike-data synthetic --output data/synthetic
jevlike-train data/synthetic/train.jsonl \
  --validation data/synthetic/validation.jsonl \
  --output runs/synthetic.pt
jevlike-eval runs/synthetic.pt data/synthetic/test.jsonl
```

The evaluator prints top-1 accuracy, top-3 accuracy, expected calibration error over ten confidence bins, and a shuffled-context control that pairs each menu with the wrong context. The README's stated bar: "A useful model should beat that control."

**The vision path.** `jevlike.vision.DoomScorerV2` applies the same head to pixels. A 160x120 RGB frame plus one motion channel (a signed greyscale frame difference) goes through a small convolutional stem, then a stride-4 patch convolution producing an 8x10 grid of 80 patches. Fixed 2D sinusoidal positions are added to the attention *keys* after the learned projection — the code comments that this is deliberate, so the positions "cannot be washed out by context normalisation or routed only into V." One embedding table holds 12 option vectors: ids 0-6 are the Doom buttons, ids 7-11 are the chess keys. Patches play the role of context tokens, controller buttons play the role of options, and the scorer is unchanged. Both game examples import this one network; there is no second model copy.

**Reported text results, verbatim from the README:** "the one-pass scorer reached about 98% accuracy on synthetic menus. On target-disjoint Wikispeedia next-click data, a frozen Qwen2.5-0.5B encoder plus the scorer reached 26%, against about 8% for shuffled and random-encoder controls. A small model trained from scratch on 40,000 clicks reached 29%. At eight options, one pass was about 100 times faster than a small decoder forced to write 400 tokens." The README immediately adds: "These numbers describe local experiments, not this quickstart run. We did not show equal quality with Jev or reproduce TypeSafe's private training method."

**Reported game results.** The Doom window in the demo film came from the joint checkpoint, "which averaged 0.60 kills and -97.50 reward across its ten recorded episodes." The chess window came from the chess-only checkpoint, "which scored 4 wins, 46 draws and 0 losses in 50 sampled games against a random mover, but 0 wins, 2 draws and 48 losses against Stockfish level 0." Against Stockfish level 3 it went 0-0-50. The README's own caveat: "The windows were selected for activity and are not typical-play or competence claims."

*The chess board as the model sees it, scaled up — cursor border, lifted piece, and legal-destination dots are all drawn into the same 160x120 frame Doom uses*
![[jevlike-002.png]]

The chess example is candid about where the ceiling sits. Naming the cursor's square from the frame is 99.95% accurate on held-out positions. Walking to a square that is *marked* on screen reaches 94% next-key accuracy after 1,250 steps. Without the mark, held-out next-key accuracy levels off near 65%, and "a network twice as wide was no better at the same training step." The legal-move dots are worth about seven points of key accuracy, and DAgger on the model's own states cut wasted presses from 24% to 4%. The author's summary: "the model has learned the controller but not chess."

## Key links

- [GitHub](https://github.com/vinnylarouge/jevlike)
- [TypeSafe launch post: Introducing System One Models and Jev](https://typesafe.ai/blog/introducing-system-one-models-and-jev)
- [Doom example README](https://github.com/vinnylarouge/jevlike/blob/main/examples/doom/README.md)
- [Chess example README](https://github.com/vinnylarouge/jevlike/blob/main/examples/chess/README.md)
- [Wikispeedia dataset (SNAP)](https://snap.stanford.edu/data/wikispeedia.html) — the one non-synthetic text benchmark used

## Notes

**It reproduces the interface, not the intelligence.** The architecture here is a single attention read plus a dot product. Nothing about it explains how Jev would be accurate across open-ended domains; the mechanism is cheap precisely because all the difficulty has been pushed into the encoder and the training data. The README says so plainly under Limitations: "This is a research starter, not a copy of Jev" and "The byte encoder is cheap but weak on language meaning."

**Calibration is computed but never reported.** `jevlike/eval.py` implements ten-bin expected calibration error, yet no ECE figure appears in the README, the example READMEs, or the results table. Since calibrated probabilities are the load-bearing claim of the System One framing, the one number that would test the framing is the one number absent. Anyone evaluating jevlike as a Jev stand-in should run `jevlike-eval` and read the ECE before trusting the probabilities as probabilities.

**The speed claim is against a weak baseline.** "About 100 times faster" compares one forward pass to "a small decoder forced to write 400 tokens" — the README concedes the comparison "used a small local decoder rather than a large commercial model." Forcing 400 tokens for an eight-way choice is close to a worst case for the baseline, so the multiple says more about the framing than the architecture.

**The game demos are weak by the author's own admission, and that is the honest part.** Negative reward in Doom, zero wins against the lowest Stockfish setting, and an explicit statement that the selected windows are not competence claims. This is unusually well-behaved reporting for a repo riding a launch-week wave, and it is the main reason the results are worth citing at all.

**What a fair text benchmark against Jev would look like.** Fix a real option-selection task with a public test split — intent routing, next-click, tool selection, retrieval reranking — hold the option lists identical for both systems, and report top-1, ECE, and latency per decision at matched cardinality, including at the high cardinalities where Jev switches to its two-stage score-then-choose path. Without matched cardinality the comparison is meaningless, because the cheap single-softmax design is exactly what degrades as the option list grows.

**Where it sits among things already in the vault.** The thesis that a small task-specific model beats a large general one on a narrow task is the same one in [[CodeScout trains small models via RL to outperform 18x larger LLMs at code search using only terminal commands]]. The economic version — route the classification to a small model and use a calibrated confidence threshold to decide when to escalate — is worked out in [[BARGAIN routes classification to a small model via a confidence threshold calibrated on 500 oracle labels, cutting costs up to 86 percent more than competing cascades]], which is the natural deployment pattern for something Jev-shaped. [[autoharness lets LLMs synthesize their own code harness to eliminate illegal actions and outperform larger models]] makes the adjacent point that constraining the action space, rather than scaling the model, is what eliminates illegal outputs. And the programming-not-prompting framing in [[DSPy is a framework for programming—not prompting—language models through typed signatures and metric-driven optimizers]] is the software-engineering counterpart: typed signatures over free text, optimised against a metric. See [[moc - Jev]] for the rest of this thread.
