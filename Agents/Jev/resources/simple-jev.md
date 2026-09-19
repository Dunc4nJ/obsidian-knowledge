---
created: 2026-09-20
source: https://github.com/featherless-ai/simple-jev
description: Featherless AI's open-source reimplementation of TypeSafe's Jev API that turns any compatible Hugging Face chat model into a structured classifier by reading next-token logits for single-token answer labels, with no trained classifier head and no calibration step.
type: resource
tags: [jev, simple-jev, featherless, open-source, logit-classification]
status: exploring
---

## What it is

A Python repository from Featherless AI, published 18 September 2026, whose one-line description is "Turn any open model into a classifier/jev endpoint." It serves TypeSafe's Jev request shape - shared `state` or `messages` plus a map of `choice`, `score`, and `noul` questions - from ordinary Hugging Face models, and builds the JSON response in server code rather than having the model generate it. At the time of capture it had 268 stars, 30 forks, and 1 open issue.

Four top-level pieces. `common/` holds engine-independent request validation, prompt planning, and response scoring in plain Python with only pydantic and NumPy. `hf-server/` is a single 803-line Transformers reference server. `RFDT/` is an optional fine-tuning path. `demos/` holds the browser demos, including the adapted JevPilot driving simulator. The companion site is [simple-jev.featherless.ai](https://simple-jev.featherless.ai/) and the graduated knowledge note is [[Featherless's Simple Jev reproduces Jev's API on stock open models by remapping every answer to a single-token letter and softmaxing only those logits - no classifier head, and the code stamps every answer calibrated False]].

## Why it's interesting

It is the second open reimplementation of Jev to appear in the launch week, and it takes the opposite bet from [[jevlike]]. Jevlike trains a new option-attention head so the model can be tiny; Simple Jev trains nothing at all and rents a stock 27B-to-35B instruction model's language understanding, paying full model cost per decision. Between them they bracket the design space, and neither reproduces the thing TypeSafe actually sells, which is calibration.

The engineering is also unusually disciplined for launch-week code. `common/PROMPT_STRUCTURE_V1.md` is a language-independent specification of the prompt strings, role assembly, label mapping, and scoring arithmetic, so a Go or Rust server can produce identical tokens. The scoring module's docstring commits to it: "Future versions that change scoring rules must retain and dispatch to the correct old mapping." Version `v1` is not a client-selectable field.

## How it works

**Validation.** `common/request_schema.py` defines `ClassifierRequest` in pydantic. Exactly one of `state` or `messages`, 1 to 256 questions, each discriminated on `type`. `ChoiceQuestion` takes 2-50 candidate keys mapping to optional descriptions; `ScoreQuestion` takes an ordered list of 2-50 rubric levels; `NoulQuestion` takes optional `true`/`false` descriptions only. Unknown top-level fields are ignored so stray `temperature` and `stream` are harmless, but unknown fields inside questions are rejected.

**Prompt planning.** `common/prompt_builder.py::prepare_prompt()` dispatches to `_prepare_v1()` and returns a `PromptPlan` with the context deliberately excluded: a fixed `SYSTEM_PROMPT_PREFIX_V1` containing the rules and three worked examples, a `prefix_instruction` that briefs every question *before* the context so the branches can share tokens, a shared `suffix_instruction`, and one `ScoringQuestion` per question.

**How multi-token labels are handled: they are renamed away.** `CHOICE_LABELS = string.ascii_uppercase + string.ascii_lowercase[:24]` gives 50 single-character labels, A-Z then a-x. Choice candidates always take letters. Score levels take digits `0`-`9` up to ten levels and switch to letters above that, explicitly "to avoid multi-token numbers." Noul always uses the fixed digit labels `1` through `9`. The options JSON shows the model both halves, for example `[{"answer":"red","description":null,"label":"A"},...]`, so a candidate named `escalate_to_tier_three` costs exactly one scored token. Insertion order assigns the letters and resolves exact ties.

**Which logits are read.** Not the first token of the label text, and not a full label sequence log-probability. Exactly one vocabulary position per question, holding the single remapped symbol. `answer_prefix` is deliberately unfinished JSON appended *after* `apply_chat_template(..., add_generation_prompt=True)`: `{"answer": "` for letter labels, `{"answer": ` with a trailing space for digits. The next token position is the label.

**Boundary verification.** `hf_server.py::PromptCompiler.compile()` checks the remap actually holds for this tokenizer by encoding `text + label` for every label and raising `Answer label {label!r} is not single-token stable` unless the result is exactly one token longer with an identical prefix, then rejecting duplicate token IDs. It checks at the real rendered boundary, not in isolation, because the template and context can change tokenization. The README concedes "compatibility with every open model is not guaranteed."

**Shared prefix reuse.** `HFBackend._score()` calls `common_prefix()` on the branches' token ID lists, comparing actual IDs rather than rendered strings - the comment notes that matching strings "does not prove that the tokenizer produced reusable prefix tokens." The prefix is trimmed to leave at least one suffix token per branch, then one unchunked forward pass with `use_cache=True` produces a seed cache. Each suffix batch gets `copy.deepcopy(cache)` followed by `branch_cache.reorder_cache(torch.zeros(len(batch)))` to broadcast the single prefix row across the batch, so no branch can mutate the seed. Suffixes are sorted longest-first to reduce padding, capped by `--max-batch-size` rows and `--max-batch-tokens` padded width, right-padded with position IDs continuing past the prefix. `logits_to_keep` avoids materializing full-sequence logits where the model's forward accepts it, and only `selected[row, branch.output_ids]` is moved to CPU float32. **Reuse is per-request only**: the README states "Cache reuse currently lasts only for a single request" and the server "processes model requests serially."

**Scoring, and how `confidence` and `score` are computed.** `common/response_scoring.py::build_answers()` → `_assemble()`. Softmax over the permitted labels alone, `p = np.exp(z - z.max()); p /= p.sum()`, with no temperature.

- **`confidence` is simply the max probability.** `winner = int(np.argmax(z))`, then `confidence = float(p[winner])`. It is not a margin and not an interval. The margin is computed but kept internal: `margin = ordered[-1] - ordered[-2]`, alongside a `ties` list, exposed only under `advanced=True`. The docstring: "Confidence is the largest label probability, not a calibrated correctness estimate or confidence interval."
- **`score` is the probability-weighted zero-based rubric index**, `score = p @ np.arange(len(labels))`, so a three-level rubric returns 0 to 2 and fractional values are expected. `confidence` for a score question is still just the largest single-level probability, not a spread around the score. A `variance` diagnostic is computed internally.
- **`noul` maps nine rating bins, not yes/no tokens.** The model scores the digits `1` through `9` against a prompt reading "Rate the probability that the answer is yes, from 0.1 to 0.9." The mean rating `mean = p @ np.arange(1, 10)` is remapped with `noul = np.clip(0.01 + (mean/10 - 0.1) * (0.98/0.8), 0.01, 0.99)`, putting rating 5 at exactly 0.5. The schema is explicit that this "is not a calibrated probability or a binary-token softmax," and noul returns no confidence field.

**Calibration: none, and the code says so in the payload.** There is no temperature scaling, no Platt or isotonic fit, and no expected calibration error anywhere in the repository. Every answer dict carries `"calibrated": False`, hidden from the default response only because it is absent from `PUBLIC_FIELDS`; `build_response(advanced=True)` adds `metadata: {"template_version": "v1", "calibration": "not_calibrated"}`. Both the site and the docs repeat the warning in plain language: "Scores reflect model preferences, not calibrated certainty."

**RFDT** (Really Fancy Decision Training) is the optional fine-tune: `prepare.py` builds the dataset and can call a larger teacher to fill in missing answers, `train.py` trains directly on the allowed answer-token logits under the identical v1 prompt structure with LoRA and multi-GPU support, and `export.py` produces a student for the HF server.

## Key links

- [GitHub](https://github.com/featherless-ai/simple-jev) - Python, created 18 September 2026, 268 stars at capture
- [Project site](https://simple-jev.featherless.ai/) - landing, [how it works](https://simple-jev.featherless.ai/how-it-works.html), [API docs](https://simple-jev.featherless.ai/docs.html), [demos](https://simple-jev.featherless.ai/demos.html), [playground](https://simple-jev.featherless.ai/playground.html)
- [common/PROMPT_STRUCTURE_V1.md](https://github.com/featherless-ai/simple-jev/blob/main/common/PROMPT_STRUCTURE_V1.md) - the language-independent v1 prompt and scoring specification
- [hf-server/API_REFERENCE.md](https://github.com/featherless-ai/simple-jev/blob/main/hf-server/API_REFERENCE.md) - the full server contract
- [RFDT](https://github.com/featherless-ai/simple-jev/tree/main/RFDT) - the fine-tuning path
- Demo API - `POST https://simple-jev-demo-api.featherless.ai/v1/classifier`, no key, 2k context, 4 RPS per the site and 2 RPS per the README
- [google/gemma-4-26B-A4B-it](https://huggingface.co/google/gemma-4-26B-A4B-it) - the stock checkpoint behind the demo's Gemma alias. No model card exists for any `featherless-ai/*-classifier` ID
- [standardagents/jevpilot](https://github.com/standardagents/jevpilot) - upstream of the driving demo

## Notes

**The `-classifier` model IDs are serving aliases, not fine-tunes.** The README's own GPU instructions start the server with `--model google/gemma-4-26B-A4B-it`, the stock Gemma 4 26B-A4B Instruct checkpoint, which resolves on Hugging Face. None of `featherless-ai/gemma-4-26B-A4B-classifier`, `Qwen3.6-35B-A3B-classifier`, or the RWKV IDs resolve to a public model card. The suffix names the endpoint mode. Fine-tuning is the separate, optional RFDT path, and hosted fine-tuned models are announced as planned rather than shipped.

**There is no LICENSE file.** Repository metadata reports `license: null` and the root tree contains no LICENSE or COPYING. With 268 stars and 30 forks, everything in it is technically all-rights-reserved until Featherless adds one. Worth checking before building on `common/` in anything shipped. Contrast [[jevlike]], which is MIT.

**Cost does not land in Jev's class.** Featherless beta pricing is $0.28 per million input tokens for the Gemma and Qwen3.6 classifiers and $0.30 for Qwen3.8, against Jev's $0.042 - roughly seven times more. Only the text-only RWKV tier at $0.03 undercuts it. The v1 template is not cheap either: it repeats the selected question twice, carries worked JSON examples, and briefs every question before the context, so a one-question bicycle request billed 413 input tokens.

**"Parallel across questions" means one batched forward, within one request.** Real concurrency across the suffix batch, but it is not Jev's parallel sampling, and the prefix cache evaporates when the request ends. Asking the same four questions about a new document re-prefills the shared instructions from scratch.

**The published server cannot do vision, but the hosted demo can.** `PromptCompiler.compile()` raises on `tools`, `mm_processor_kwargs`, or `media_io_kwargs`, and the README says the HF server "supports text only; images, audio, video, and tool calls are unsupported." Meanwhile the vision lab classifies photos against Gemma and Qwen on the hosted API. That is the largest gap between product and code.

**Two documented facts to double check.** The README says the demo is 2 RPS and every page of the website says 4. The docs and every curl example use `featherless-ai/gemma-4-26B-A4B-classifier`, but on 20 September 2026 the live `/v1/models` list returned only the two Qwen and three RWKV IDs.

**Open questions worth an experiment.** Nobody has published an ECE number for this, and the demos suggest it would be bad - a live bicycle call returned `confidence: 0.9999985694885254` and all eleven vision-lab photos came back at 98.5 percent or higher. Also untested: whether the letter remap costs accuracy compared to scoring the label words themselves, and whether the RWKV models can honour a "shared KV prefix" story at all given they have no transformer KV cache. See [[moc - Jev]] for the rest of the cluster.
