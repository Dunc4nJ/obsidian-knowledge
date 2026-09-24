---
created: 2026-09-24
source: https://github.com/langchain-ai/smithtune
type: resource
tags: [langsmith, smithtune, fine-tuning, sft, lora, trajectories, post-training, fireworks, baseten, evaluation, cli]
status: captured
---

## What it is

LangChain's "LangSmith Post-Training CLI": a Python command-line tool that takes agent trajectories recorded in LangSmith, curates them into a supervised fine-tuning dataset, trains a LoRA adapter on Fireworks managed SFT or Baseten Loops, and compares the base and tuned models back in LangSmith. MIT licensed, created 2026-09-10, tagged v0.1.0, 9 stars at capture. It ships a `SKILL.md` so a coding agent can drive the entire flow.

The CLI installs from git, not PyPI. The PyPI name `smithtune` is an unrelated 0.0.1 placeholder ("Utilities for preparing conversational datasets"), so the documented install is `uv tool install --python 3.12 --overrides .../v0.1.0/overrides.txt 'smithtune[deepagents] @ git+https://github.com/langchain-ai/smithtune.git@v0.1.0'`. The overrides file forces `transformers==5.10.4` because the upstream Fireworks and Tinker cookbooks pin versions affected by CVE-2026-9856.

## Why it's interesting

It is the first end-to-end, self-serve path from production agent traces to fine-tuned weights inside a single observability vendor, and the implementation is unusually candid about what it does and does not measure. The evaluation is explicitly teacher-imitation rather than task success, the data-rights gate is enforced in code rather than in a terms page, and the supported-model list is a short hard-coded allowlist rather than a marketing claim of universality.

It is also worth reading as a reference implementation of trace curation. The council, the rubric requirement, the frozen-directory discipline, and the confirm-before-paid-work pattern are all reusable ideas independent of LangSmith.

## How it works

**Pull.** `dataset pull` queries LangSmith for root runs matching a filter in LangSmith trace-query syntax, then fetches each match's whole thread from `/v1/trajectory` with `format: "ui"` and both `system_messages` and `tool_definitions` explicitly requested, since per-assistant tool bindings are opt-in. No model calls. A trajectory too large for one response is retried at `page_size=1` and, if it still does not fit, excluded whole rather than truncated. Downloads are checkpointed by content hash in `checkpoint.json` so an interrupted pull resumes. Defaults: last 24 hours, target 100 trajectories, 1,000 new candidates per round (max 2,000), three rounds.

**Triage (optional).** `triage.py` runs an agent council. `DEFAULT_COUNCIL` is two judges, both on Baseten Model APIs: `deepseek-ai/DeepSeek-V4.1-Flash` and `zai-org/GLM-5.3-Flash`. One to sixteen slots are configurable across Fireworks, Baseten, OpenAI, and Anthropic. Each judge makes exactly one model request per whole trajectory and returns `{"keep": 0|1, "reason": "..."}`, validated against a Draft 2020-12 JSON schema. Aggregation, recorded verbatim in the plan as "all slots required; strict majority; ties drop", makes the shipped default an AND gate rather than a vote: with two judges one dissent drops the trajectory. The fixed judge prompt in `triage_judges.py` forbids per-turn scoring and treats trajectory content as untrusted data; all selection criteria come from the user's `--rubric` or `--rule`, and the CLI ships no default rubric and refuses to run without one.

The optional `deepagents` extra adds an orchestrator, not a voter. `triage_coordinator.py` assembles it from `create_deep_agent`, a `StateBackend`, `SubAgentMiddleware` carrying one `trajectory-judge` subagent, `SummarizationMiddleware`, and an `allowed_tools` middleware that restricts the agent to exactly `code_mode` and `task`. It batches up to 128 unattempted trajectory-judge pairs per call with no shell, network, host-file, or environment access, and its own text is never accepted as a verdict.

Trajectories with multimodal content are filtered before judging. A provider context-window rejection drops the whole trajectory with a keep of 0, and the coordinator is instructed "Do not shorten, summarize, page, or split the input to make it fit." This is a real selection bias: the training set skews short, and the binding limit is the judge's context rather than the trainer's, so a Kimi K3 run with a 196,608-token training window can still lose long trajectories to a GLM-5.3-Flash judge. The run summary counts these separately as trajectories that "exceed a council model's context window."

**Push and prepare.** `dataset push` uploads the approved set to a persistent LangSmith dataset for auditability. `prepare` validates each trajectory, renders it with the model's tokenizer and the tools bound at each assistant call, filters anything over the sequence limit, and splits roughly 80/10/10 with each source trajectory confined to one split. Split membership is published back to the LangSmith dataset.

**Rendering.** This is the subtle part. One stored conversation is not one training example. `rendering.py` iterates `training_targets(row)` and emits one datum per assistant message, each with its own preceding context and tool bindings, and loss falling only on that message. Fireworks goes through the pinned `fireworks-training-cookbook` with `train_on_what="last_assistant_message"` and every earlier message marked untrainable. Baseten uses `hf_rendering.py`, which takes the tokenizer's `return_assistant_tokens_mask` output and then zeroes the prefix, erroring if the final assistant target has no loss tokens. Three models get a verified native-prefix renderer in `native_rendering.py` instead: Kimi K3, Qwen3.5-9B, and GLM-5.3-Flash.

**Train.** LoRA only, on both providers, via `create_lora_training_client`. Fireworks runs epochs and selects the checkpoint with the best validation loss, with early stopping on a min-delta; Baseten tracks `lowest_loss` and `best_epoch` the same way. Evaluation scores do not feed back into checkpoint selection.

**Replay evaluation.** `evaluation/replay.py` is the largest single idea in the repo. `build_replay_cases` slices each held-out test trajectory before every assistant message that carries a visible action (reasoning-only and empty messages are skipped as context), producing a case with the prefix, the recorded message as the reference, the tools at that call, and the tool results that followed. Both models generate a next action for each case. Scoring is dual: `score_replay_candidate` computes six deterministic booleans (`tool_decision_match`, `tool_name_match`, `arguments_json_valid`, `arguments_schema_valid`, `reference_arguments_match`, `parallel_call_set_match`) with paired tuned-minus-base deltas, and `judge_replay_candidate` asks an LLM judge for `{"pass": bool, "reason": str}`. The judge default is `baseten/zai-org/GLM-5.3-Flash`, a third API key. Before scoring, `calibrate_judge` runs up to five tool cases and five text cases through deliberately-wrong controls (`_wrong_tool_candidate`, `_wrong_arguments_candidate`) at three calls each. Results upload to LangSmith as `teacher_agreement` per action and `trajectory_teacher_agreement` per trajectory. Generated tool calls are never executed.

**Data rights.** `data_rights.py` gates every workflow behind a versioned local receipt at `~/.config/smithtune/data-rights.json`. In a non-interactive shell it refuses outright; `--confirm` does not substitute. The document it gates, `docs/data-rights-and-permitted-use.md` at version 1, runs 340 words in four sections: your responsibility for data rights ("Permission to access a trace or dataset does not necessarily include permission to use its contents"), provider terms and model licenses (those agreements "may restrict distillation, training competing models, or other uses of model outputs"), data transfers and sensitive information (smithtune "may transmit data to LangSmith and selected training, triage, and evaluation providers," and trajectories "may include complete conversations, system instructions, and tool context"), and no grant of third-party rights ("Technical validation and evaluation results do not verify legal compliance").

**Supported models.** `capabilities.py` hard-codes the allowlist. Fireworks documented shared-pool training context limits: `qwen3p8-27b` 131,072; `kimi-k3` 196,608; `deepseek-v4-flash-0731` 262,144; `muse-glimmer-30b` 131,072. Baseten verified cross-entropy models: `Qwen/Qwen3.8-27B`, `Qwen/Qwen3.5-9B`, `moonshotai/Kimi-K3`, `zai-org/GLM-5.3-Flash`, with limits queried live per workspace and the tokenizer required to match the official base-model identity. `qwen3p8-27b` is the default and the only model on both providers. Fireworks preflight refuses any model without a documented shared-pool entry, since no read-only pool-eligibility API exists, then checks the model API's `supervisedLoraTunable` flag and `trainingContextLength`. A code comment records that DeepSeek 0731 and Muse Glimmer report that flag false while still supporting serverless Training API LoRA, so the flag is read but not trusted as a gate.

**Spend discipline.** `triage`, `resume`, `push`, `train`, `evaluate`, `deploy`, and `undeploy` do nothing billable without `--confirm`, and the SKILL.md instructs the agent that authorization for one step never covers the next. `plan` and `eval-plan` are free previews. Settings freeze into a directory once work starts.

## Key links

- [GitHub](https://github.com/langchain-ai/smithtune)
- [Docs](https://docs.langchain.com/langsmith/smithtune)
- [SKILL.md](https://github.com/langchain-ai/smithtune/blob/main/src/smithtune/skills/smithtune/SKILL.md)
- [Data Rights and Permitted Use](https://github.com/langchain-ai/smithtune/blob/main/docs/data-rights-and-permitted-use.md)
- [Launch blog post](https://www.langchain.com/blog/langsmith-fine-tuning)

## Notes

- Roughly 12,000 lines of Python across `src/`. The Baseten integration is the largest single file at 1,722 lines, more than twice the Fireworks one, which matches Baseten's public enthusiasm for the launch.
- `tinker==0.23.0` and `trl==1.13.0` are pinned dependencies but neither provider path is a Tinker path; Tinker appears via the cookbook's constraints. Worth checking whether a Tinker backend is planned.
- No RL, no DPO, no full fine-tuning. SFT with LoRA is the entire surface as of v0.1.0.
- The default council of two judges requiring unanimity is a stricter filter than "majority vote" implies, and the SKILL.md tells the agent to add a third judge if an actual majority is wanted.
- The context-overflow drop is the least-discussed design decision in the repo and the one most likely to surprise a user: long trajectories vanish from training with only a line in the run summary, and the judge model sets the ceiling.
- Open question: `--max-points-per-trajectory` changes which actions get scored, so evaluation numbers are only comparable across runs that used the same cap.

Captured into [[LangSmith Fine-Tuning's smithtune turns curated trajectories into LoRA SFT on Fireworks or Baseten and scores the student by replaying the teacher - OpenSWE precision up 19 points, recall unmoved]].
