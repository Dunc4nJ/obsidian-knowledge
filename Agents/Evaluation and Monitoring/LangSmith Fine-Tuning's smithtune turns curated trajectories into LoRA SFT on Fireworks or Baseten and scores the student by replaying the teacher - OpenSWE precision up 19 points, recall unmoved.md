---
created: 2026-09-24
source: https://www.langchain.com/blog/langsmith-fine-tuning
via: https://x.com/langchain/status/2103182716720099748
author: LangChain (Ankush Gola, Jake Broekhuizen, Vivek Trivedy)
published: 2026-09-24
type: knowledge
tags: [langsmith, smithtune, fine-tuning, sft, lora, trajectories, post-training, fireworks, baseten, evaluation, replay-eval, langchain]
description: LangChain's smithtune CLI closes the loop from LangSmith traces to a LoRA-fine-tuned model, curating trajectories with an agent council and scoring the student on how closely it reproduces the teacher's recorded next action.
---

# LangSmith Fine-Tuning's smithtune turns curated trajectories into LoRA SFT on Fireworks or Baseten and scores the student by replaying the teacher - OpenSWE precision up 19 points, recall unmoved

## Key Takeaways

- **The headline metric is teacher imitation, not task success, and the code says so more plainly than the blog does.** `smithtune evaluate` slices each held-out trajectory before every assistant message, asks both models for the next action, and has an LLM judge decide whether the candidate matches the recorded one. The feedback keys uploaded to LangSmith are literally named `teacher_agreement` and `trajectory_teacher_agreement`. The docs page adds the sentence the blog omits: "Evaluation scores measure how closely each model matches the recorded behavior, not whether it completes tasks end to end. Smithtune does not execute the tool calls the model generates." A student that finds a different correct path is scored as a failure, since the judge is told to fail "materially different responses." This is the same teacher-anchored shape as [[LangChain and Fireworks fine-tune Qwen as a 100x cheaper trace judge that beats frontier models on unseen perceived-error domains]], and it is why [[trajectory eyeballing is the irreplaceable skill for debugging RL-trained agents]] still matters after the number comes back green.
- **In the OpenSWE result, recall does not move at all: 40.0% before, 40.0% after.** The entire F1 gain from 48.9% to 53.7% is precision, 62.9% to 81.5%, and it arrives alongside 29.8% fewer model calls and 29.4% fewer tool requests. The consistent reading is that the model learned to stop looking, not to find more bugs. For a code-review agent, fewer false flags is a real win on reviewer trust and cost per PR, but the tuned model misses exactly as many genuine issues as the base model did. LangChain frames this as "similar quality with fewer calls," which is fair, but it is not the "preserve review quality while reducing the work needed to find bugs" the setup promised in the direction most readers will assume. See [[Open SWE distills enterprise coding agent patterns into a composable open-source framework]] for the agent under test.
- **The most useful sentence in the blog is the admission of a failed run**: "An earlier, less selective training set reduced the F1 score after SFT." Data selection, not the training recipe, is the lever, and a bad selection makes the model actively worse. LangChain's fix was to add a per-trace review stage that oversamples traces where agents believed real issues existed. This is the same conclusion reached independently by [[Mercor's SkyRL recipe post-trains a 397B on 1928 expert tasks for 70 percent relative Pass@1 - and spends Steps 1-3 de-risking before any real compute]] and [[Bridgewater and Thinking Machines fine-tune Qwen3-235B to replicate expert investor judgment, beating frontier LLMs on financial information-filtering at 13.8x lower cost]].
- **LangChain is now selling the step its own founder ranks last.** The blog says "We recommend that teams start with harness engineering," which is the argument of [[LangChain's Harrison Chase argues continual learning for AI agents extends beyond model fine-tuning to harness engineering and context updates]] and of [[Prime Intellect's fine-tune-last doctrine - 5x task timeouts lifted Terminal-Bench 14.7 points with no model change]]. The Engine result is honest about reaching that point first: "we had exhausted our ability to push it or GPT-5.6 Sol further via harness engineering." Fine-tune-last is still the doctrine; smithtune is the tooling for teams who have actually arrived at last.
- **This completes a single-vendor loop: trace, store, search, mine, eval, train, deploy.** Traces land in LangSmith, [[SmithDB makes LangSmith 12x faster by treating agent observability as an LSM problem on object storage]] stores and searches them, [[LangSmith Engine turns production agent traces into issues evaluators and regression examples by separating screening from investigation]] mines them for failures, [[LangChain's Eval Engineering Skill builds Harbor-format evals from repo context and agent traces by interviewing the user]] turns them into evals, and smithtune now turns them into weights. That is the concrete instantiation of [[self-serve post-training infrastructure is emerging as the key layer between foundation models and enterprise adoption]], and it is exactly the dynamic described in [[Memory ownership follows harness ownership - Harrison Chase argues picking a closed harness is picking a permanent owner for your agent's data flywheel]]. Your traces become your training set, and whoever holds the traces holds the flywheel.
- **The pipeline quietly biases the training set toward short episodes.** A trajectory that overflows a council judge's context window is dropped, not truncated, and the coordinator is told never to shorten or split it to make it fit. Because the default judge is GLM-5.3-Flash, the judge's context, not the trainer's, is what bounds selection: a Kimi K3 run with a 196,608-token training window can still lose its longest trajectories to a judge that could not read them. Long-horizon behavior is what most teams would most want to teach, and it is the first thing filtered.
- **Training on production traces is training on customer data, and the CLI makes you say so out loud.** `smithtune acknowledge-data-rights` blocks every workflow until an interactive terminal confirms it, and the 340-word document it gates is specific where the blog is silent: trajectories "may include complete conversations, system instructions, and tool context," provider agreements "may restrict distillation, training competing models, or other uses of model outputs," and "Technical validation and evaluation results do not verify legal compliance." The blog never mentions any of this. The docs do, in a setup step.

## The Pipeline

The whole flow is one CLI. From the README:

```text
dataset pull → dataset triage (optional) → dataset push
prepare → plan → train --evaluate → deploy (optional)
```

*From trace data to an optimized model: the four smithtune stages between a LangSmith tracing project and a specialized model, with the coding agent driving from above*
![[langchain-smithtune-01.png]]

| Stage | Command | What happens |
| --- | --- | --- |
| Select | `dataset pull DIR` | Pulls whole threads matching a LangSmith root-run filter into a local directory. No model calls. Default window is the last 24 hours, default target 100 trajectories, max 2,000 candidates per pull. |
| Curate | `dataset triage DIR` | Optional agent council votes keep or drop on each whole trajectory against your rubric. Refuses to run without `--rubric` or `--rule`. |
| Publish | `dataset push DIR` | Uploads the approved set to a persistent LangSmith dataset so the training data can be audited later. |
| Prepare | `prepare` | Validates trajectories, renders them with the model's tokenizer and per-turn tool schemas, splits roughly 80/10/10 with each trajectory confined to one split, and publishes split membership back to LangSmith. Overlong trajectories are rejected, never truncated. |
| Preview | `plan` | Free. Shows model, example count, token counts, epochs, learning rate, batch size, and the evaluation call count. |
| Train | `train --evaluate` | Submits LoRA SFT to Fireworks managed training or Baseten Loops, then runs replay evaluation. |
| Deploy | `deploy` | Optional endpoint. Fireworks promotes the checkpoint to a model first; Baseten needs an explicit accelerator and context cap. |

Two guardrails are structural rather than advisory. Paid work requires `--confirm` on every command that spends money, and authorization for one step never carries to the next. Settings freeze into a directory the moment work starts, so changing the filter, window, rubric, or review mode means a new directory.

The checkpoint is selected by lowest validation loss, in `providers/fireworks.py` ("Run epochs and select the checkpoint with the best validation loss") and `providers/baseten.py`, which tracks `lowest_loss` and `best_epoch` across epochs. LoRA is the only training method exposed: both providers go through `create_lora_training_client`, and Baseten's own plan output labels the method "Baseten Loops LoRA SFT". Evaluation scores explicitly "do not affect checkpoint selection."

## Trajectories as Training Data

The argument for LangSmith's trajectory format is a real one. Supervised fine-tuning needs the exact context the teacher model had at each decision, and in long-running agents the tool set changes mid-run through mechanisms like deferred tool loading. A naive export of the final message list silently loses that, so the student trains on decisions it could not have made from the context it is shown.

*Anatomy of a trajectory: available tools are inserted as context after the system message and updated mid-run, and every assistant message becomes a separately-targeted golden action*
![[langchain-smithtune-02.png]]

The code matches the diagram. One stored conversation is not one training example: `rendering.py` iterates `training_targets(row)` and emits one datum per assistant message, each carrying its own preceding context and the tools bound at that exact call. Loss falls only on that message. For Fireworks this is `train_on_what="last_assistant_message"` with every earlier message marked untrainable; for Baseten, `hf_rendering.py` takes the tokenizer's assistant mask and then zeroes the prefix, raising an error if "final assistant target has no loss tokens." The README says it plainly: "Each supported assistant answer becomes one training target, with its preceding context and the tools available at that call."

Trajectories are fetched from LangSmith's `/v1/trajectory` endpoint with `format: "ui"` and both system messages and tool definitions explicitly requested, since per-assistant tool bindings are opt-in. A trajectory too large for one page is retried at `page_size=1` rather than truncated, and if it still does not fit it is excluded whole. Trajectories with multimodal content are filtered before judging.

## Results

Two internal agents, both LangChain's own. Neither table carries a sample size or a confidence interval.

**Engine, on a subset of IssueBench, LangChain's internal benchmark for issue detection and grouping:**

| Model | Task score ↑ |
| --- | --- |
| GPT-5.6 Sol | 87.0 |
| Kimi K3 | 90.0 |
| Kimi K3 + SFT | 96.0 |

The framing matters: "The base Kimi model was already strong, but we had exhausted our ability to push it or GPT-5.6 Sol further via harness engineering." So the six-point gain over base Kimi is measured after harness engineering had been exhausted, which is the honest place to run this comparison. What is not stated is the subset size, how the tuned model was scored, or whether the scoring used the same replay judge that smithtune ships.

**OpenSWE Review, on an internal set of real pull requests:**

| Model | F1 ↑ | Precision ↑ | Recall ↑ | Model calls per review ↓ | Tool requests per review ↓ |
| --- | --- | --- | --- | --- | --- |
| Qwen-3.8-27B | 48.9% | 62.9% | 40.0% | 55.9 | 65.8 |
| Qwen-3.8-27B + SFT | 53.7% | 81.5% | 40.0% | 39.2 | 46.5 |

Recall is identical to one decimal place. Precision rises 18.6 points, model calls fall 29.8%, tool requests fall 29.4%. The tuned model finds the same bugs while raising far fewer false alarms and doing a third less work. Whether that is the trade a code-review team wants depends entirely on whether their complaint was noise or misses. LangChain's own summary is accurate and modest: "similar review quality with fewer model and tool calls."

## Replay Evaluation and the Judge

`evaluation/replay.py` is 940 lines and its module docstring is the clearest statement of what the metric is: "Plan and score held-out next-message replay evaluations."

`build_replay_cases` walks each test trajectory and, at every assistant message carrying a visible action, emits a case containing the prefix before it, the recorded message as `reference`, the tools bound at that call, and any tool results that followed. Reasoning-only or empty assistant messages are skipped as context, not scored. `--max-points-per-trajectory` caps how many of these per trajectory, spread evenly.

Each case is scored twice. **Deterministically**, `score_replay_candidate` computes six booleans: `tool_decision_match`, `tool_name_match`, `arguments_json_valid`, `arguments_schema_valid`, `reference_arguments_match`, and `parallel_call_set_match`, aggregated into per-model rates plus a paired tuned-minus-base delta. **By judge**, `judge_replay_candidate` sends the prefix, the reference next action, the tools, and the tool results that the candidate could not see, then asks for `{"pass": bool, "reason": str}`. The instructions are teacher-anchored but not literal-minded:

> For a tool call, pass when the candidate selects an equivalent tool with correct material arguments. For a text response, pass when its meaning, usefulness, and factual claims agree with the reference. Exact wording and tool-call IDs do not matter. Fail missing, wrong, malformed, contradictory, or materially different responses. Do not prefer either model.

The default judge is `baseten/zai-org/GLM-5.3-Flash`, a third API key beyond LangSmith and the training provider. Before scoring, `calibrate_judge` runs up to five tool cases and five text cases through deliberately-wrong controls, `_wrong_tool_candidate` and `_wrong_arguments_candidate`, at three calls each, so a judge that passes everything is caught. Judge output is retried up to three times on malformed JSON. Both trajectory content and tool schemas are labelled untrusted in the prompt against injection from recorded traces.

Two results go to LangSmith as feedback: `teacher_agreement` per action and `trajectory_teacher_agreement` as the per-trajectory mean, with a single comparison link for base and tuned experiments.

## The Council and Data Rights

The council in `triage.py` is smaller than "a council of agents" suggests. `DEFAULT_COUNCIL` is **two** judges, both on Baseten Model APIs: `deepseek-ai/DeepSeek-V4.1-Flash` and `zai-org/GLM-5.3-Flash`. Between 1 and 16 slots are configurable across Fireworks, Baseten, OpenAI, and Anthropic. Aggregation, recorded verbatim in the run plan, is "all slots required; strict majority; ties drop" — so with the default two judges a trajectory survives only on a unanimous keep. The SKILL.md says this outright: "With two judges a trajectory is kept only when both vote keep; add a third judge for a majority vote."

Each judge sees one whole trajectory and returns `{"keep": 0|1, "reason": "..."}`, validated against a Draft 2020-12 JSON schema. The fixed prompt forbids per-turn scoring: "Judge all assistant behavior in that conversation together. Do not score turns separately or keep only the final answer... A good final answer does not excuse bad earlier behavior." Selection criteria come entirely from the user's `--rubric` or `--rule`; smithtune ships no default rubric and refuses to run without one. The vote rule is stated verbatim in the coordinator prompt: "A strict majority gives 1; a tie gives 0."

With the shipped default that arithmetic makes the council an AND gate rather than a vote. Two judges, strict majority, ties drop, means one dissent kills the trajectory. That is a conservative filter, which is probably the right default for training data, but "a council of agents to review and filter" in the blog reads as something more deliberative than two cheap models that must both say yes.

The optional `deepagents` extra adds an orchestrator, not a voter. `triage_coordinator.py` builds it with `create_deep_agent`, a `StateBackend`, a `SubAgentMiddleware` carrying a single `trajectory-judge` subagent, a `SummarizationMiddleware`, and an `allowed_tools` middleware restricting it to exactly two tools, `code_mode` and `task`. It pulls up to 128 unattempted trajectory-judge pairs at a time and fans them out under the configured concurrency, with no shell, network, host files, or environment access. Its own text is never a verdict: "CLI validation and saved votes determine labels, never your final text." Votes land in `judgments.jsonl`, labels in `labels.jsonl`, and a summary in `report.md`.

One filtering rule deserves more attention than it gets. A trajectory that overflows a council judge's context window is dropped with a keep of 0 and a reason, and the coordinator is explicitly told "Do not shorten, summarize, page, or split the input to make it fit." The run summary counts these separately as "trajectories that exceed a council model's context window." The consequence is a selection bias nobody advertises: **the training set skews short**, because the longest episodes are the ones most likely to be filtered. Worse, the binding constraint is the judge's context, not the trainer's. The default council runs GLM-5.3-Flash, so a Fireworks Kimi K3 run with a 196,608-token training window can still lose its long trajectories to a judge that could not read them. Long-horizon agent behavior is exactly what a practitioner would most want to teach, and it is the first thing this pipeline discards.

This is the same machine as [[Applied Compute freezes a Sol-built 14-label taxonomy so Jev annotates the corpus - ECE 0.051 against Luna's 0.154 and 85 percent recall at 0.20, with every rival left at Jev's threshold]] and [[the Error Discovery skill builds a failure-mode taxonomy while you annotate, using active learning to pick the next traces]]: a human-written rubric frozen up front, then models applied at scale to label the corpus against it. The README is careful not to oversell it — "Council review helps assess quality; it does not guarantee good training data."

`data_rights.py` is 80 lines and gates everything. `require_acknowledgment` runs before workflow dispatch and fails unless a versioned receipt exists at `~/.config/smithtune/data-rights.json`, matching both the current document version and URL. In a non-interactive shell it refuses outright and tells you to run `smithtune acknowledge-data-rights` in a terminal as the same user; `--confirm` does not substitute. The interactive prompt reads:

> You are responsible for having permission to use your data for training and evaluation and to share it with selected providers. Internal-only use and open-weight models do not automatically make a use permitted.

The document it points to, `docs/data-rights-and-permitted-use.md`, is 340 words in four sections and is more specific than the prompt. **Your responsibility for data rights** notes that "Permission to access a trace or dataset does not necessarily include permission to use its contents for these purposes." **Provider terms and model licenses** warns that the agreements governing the services that produced your traces "may restrict distillation, training competing models, or other uses of model outputs" — which is the live question for anyone whose traces came from a frontier API and whose target is an open-weight model. **Data transfers and sensitive information** is the operative one: smithtune "may transmit data to LangSmith and selected training, triage, and evaluation providers," and "Selected trajectories may include complete conversations, system instructions, and tool context—not just individual responses," with an instruction to remove credentials and secrets before processing. **No grant of third-party rights** closes it: "Technical validation and evaluation results do not verify legal compliance."

That is the honest framing of what this product does: it ships your production traces, including whatever your customers typed into your agent and whatever your system prompt says, to at least two third parties — a training provider and a judge provider, which need not be the same company. The blog does not mention data rights at all.

## Where It Sits in the LangSmith Stack

Fine-Tuning shipped the same day as three sibling posts: LangSmith Engine v2 red teaming, Trajectories in LangSmith, and LangSmith Custom Apps. Stacked against what the vault already holds, the layers are now complete:

- **Capture** — trajectories, the format this post depends on, and the feedback-on-traces argument in [[LangChain's Harrison Chase argues agent observability needs feedback attached to traces to power learning]].
- **Store and search** — [[SmithDB makes LangSmith 12x faster by treating agent observability as an LSM problem on object storage]], [[SmithDB builds a byte-budgeted FST inverted index to enable 400ms full-text search over enormous agent traces in object storage]], and [[SmithDB's 12x agent observability speedup was built on top of Apache DataFusion and Vortex not instead of them]].
- **Mine** — [[LangSmith Engine turns production agent traces into issues evaluators and regression examples by separating screening from investigation]].
- **Evaluate** — [[LangChain's Eval Engineering Skill builds Harbor-format evals from repo context and agent traces by interviewing the user]], by Vivek Trivedy, who is also on this byline. The same person is building the eval layer and the training layer, which explains why the two share the rubric-plus-judge shape.
- **Train** — smithtune.
- **Harness** — [[Deep Agents v0.6 splits the agent harness into five composable primitives - code interpreter, per-model profiles, typed streaming, delta channels, and ContextHub backend]], from the same author cluster.

The loop is exactly [[the agent improvement loop is traces enriched with evals and human feedback converted into validated fixes]], with the final step upgraded from a prompt edit to a weight update, and every stage inside one vendor. Compare the independent route in [[Harvey's Tenet post-trains Kimi K3 with GSPO in rubric-graded legal environments, doubling LAB hold-out completions while co-optimizing cost via reward shaping]], which owns its own post-training stack end to end.

## The Post and Replies

The launch post was light: 19 likes, 1 retweet, 7 replies as captured. LangChain's own self-reply carried the four-step summary. Baseten congratulated the launch and confirmed "smithtune training running on Baseten Loops," which the code corroborates: Loops is a first-class provider at 1,722 lines, the larger of the two integrations.

One reply is worth flagging as wrong. @ADLXBT described the mechanism as extracting pairs "so the weights adapt to your exact schema without manual labeling." The blog describes the opposite: the labeling step is human plus agent, and the README states that smithtune ships no default rubric and that `triage` refuses to run without one written by the user. Without a trusted pre-existing quality signal such as validated feedback scores, a human writes the rubric before any council runs. The "without manual labeling" claim inverts the post's actual recommendation.

Adoption is early. The repository is 14 days old with 9 stars, tagged v0.1.0. The PyPI name `smithtune` holds an unrelated 0.0.1 placeholder described as "Utilities for preparing conversational datasets," and the real CLI installs from git, not PyPI:

```bash
uv tool install --python 3.12 \
  --overrides https://raw.githubusercontent.com/langchain-ai/smithtune/v0.1.0/overrides.txt \
  'smithtune[deepagents] @ git+https://github.com/langchain-ai/smithtune.git@v0.1.0'
```

The overrides file exists to force `transformers==5.10.4`, because the upstream Fireworks and Tinker cookbooks pin versions affected by CVE-2026-9856.

Repository details and a code-level walkthrough are in [[resources/smithtune]].

## Supported Models

From `capabilities.py`, the supported base models are a short, hard-coded list per provider, not a general catalog.

| Provider | Model | Limit |
| --- | --- | --- |
| Fireworks | `qwen3p8-27b` | 131,072 |
| Fireworks | `kimi-k3` | 196,608 |
| Fireworks | `deepseek-v4-flash-0731` | 262,144 |
| Fireworks | `muse-glimmer-30b` | 131,072 |
| Baseten | `Qwen/Qwen3.8-27B` | per workspace |
| Baseten | `Qwen/Qwen3.5-9B` | per workspace |
| Baseten | `moonshotai/Kimi-K3` | per workspace |
| Baseten | `zai-org/GLM-5.3-Flash` | per workspace |

Fireworks limits are documented shared-pool training context lengths, and smithtune refuses outright any Fireworks model without such an entry, because there is no read-only API for pool eligibility. Preflight then queries the Fireworks model API for a `supervisedLoraTunable` flag and a `trainingContextLength`, with a code comment recording that DeepSeek 0731 and Muse Glimmer report that flag as false while still supporting serverless Training API LoRA — a provider metadata inconsistency smithtune works around rather than trusting. Baseten limits are queried live from the workspace, and the four models listed are those with verified cross-entropy training compatibility; the tokenizer must match the official base model identity exactly. `qwen3p8-27b` is the default and the only model that works on both providers.

## Links

- [Introducing LangSmith Fine-Tuning](https://www.langchain.com/blog/langsmith-fine-tuning) — the launch post by Ankush Gola, Jake Broekhuizen, and Vivek Trivedy
- [Fine-tune models with Smithtune](https://docs.langchain.com/langsmith/smithtune) — the docs page, with the "matches recorded behavior, not end to end" caveat
- [langchain-ai/smithtune](https://github.com/langchain-ai/smithtune) — the CLI, MIT, Python, v0.1.0
- [SKILL.md](https://github.com/langchain-ai/smithtune/blob/main/src/smithtune/skills/smithtune/SKILL.md) — the skill a coding agent installs to drive the flow
- [Data Rights and Permitted Use](https://github.com/langchain-ai/smithtune/blob/main/docs/data-rights-and-permitted-use.md) — what `acknowledge-data-rights` gates
- [Trajectories now in LangSmith](https://www.langchain.com/blog/langsmith-trajectories-tracing) — the format this depends on, same-day sibling post
- [Fireworks managed SFT](https://docs.fireworks.ai/fine-tuning/fine-tuning-models) and [Baseten Loops SDK](https://www.baseten.co/blog/introducing-the-baseten-loops-sdk/) — the two training backends
- [The anatomy of an agent harness](https://www.langchain.com/blog/the-anatomy-of-an-agent-harness) — the harness-engineering-first step the blog recommends before SFT
- [Original post](https://x.com/langchain/status/2103182716720099748) — @LangChain, 2026-09-24

Part of [[moc - Evaluation and Monitoring]].

## Original Content

> [!quote]- Original Content - the post, the blog, the docs page, the README, SKILL.md, and the replies
> ### The Post
>
> **@LangChain** ([LangChain](https://x.com/langchain)) - 2026-09-24 18:00 UTC - 19 likes, 1 retweet, 7 replies
> [https://x.com/langchain/status/2103182716720099748](https://x.com/langchain/status/2103182716720099748)
>
> Introducing LangSmith Fine-Tuning and the smithtune CLI.
>
> LangSmith now handles the entire fine-tuning process. Use your traces to train specialized models that cut cost and latency.
>
> Now in Public Beta. https://www.langchain.com/blog/langsmith-fine-tuning
>
>
> #### Blog: Introducing LangSmith Fine-Tuning
>
> *[www.langchain.com/blog/langsmith-fine-tuning](https://www.langchain.com/blog/langsmith-fine-tuning) - Ankush Gola, Jake Broekhuizen, Vivek Trivedy - September 24, 2026 - 8 min read*
>
> *Article body only. Site navigation, author headshots, share widgets, the three "Related content" teasers, the newsletter form, and the trailing JSON-LD block are excluded.*
>
> # Introducing LangSmith Fine-Tuning
>
> Ankush Gola, Jake Broekhuizen, Vivek Trivedy
>
> September 24, 2026
>
> ## Key Takeaways
>
> * Use the LangSmith Fine-Tuning CLI and skill - `smithtune` \- to leverage agent trajectories stored in LangSmith to a fine-tuned model in one end-to-end workflow
> * In addition to driving training, the `smithtune` CLI handles evaluating the fine-tuned model and uploads eval results to LangSmith for easy analysis
> * We partnered with [Fireworks](https://fireworks.ai/) & [Baseten](https://www.baseten.co/) to create a seamless link between LangSmith trajectories and creation of a dataset for fine-tuning both the platforms
>
> Today we're launching LangSmith Fine-Tuning and `smithtune`, a CLI that helps teams turn [LangSmith trajectories](https://www.langchain.com/blog/langsmith-trajectories-tracing) into custom fine-tuned models for their agents. It handles the entire fine-tuning process from one CLI: dataset creation and preparation from LangSmith trajectories, training with Fireworks or Baseten, and evaluation with LangSmith. You can run `smithtune` directly or work with your coding agent to run commands and inspect the results.
>
> `smithtune` is built for post-training models. It currently supports supervised fine-tuning (SFT) which trains a model using examples of good behavior. You give the model inputs/outputs and it learns by updating model weights to imitate that behavior. LangSmith trajectory data is designed to support SFT, and `smithtune` helps turn these trajectories into useful training data.
>
> This gives teams a way to train specialized models without building the data pipeline by hand. A model trained on your examples can often perform as well as or better than a general purpose frontier model on specified tasks, often at lower cost and latency.
>
> [Try LangSmith Fine-Tuning on GitHub](https://github.com/langchain-ai/smithtune) and have your coding agent drive the fine-tuning process end to end by installing the `smithtune` [skill from the repository](https://github.com/langchain-ai/smithtune/blob/main/src/smithtune/skills/smithtune/SKILL.md).
>
> > _One of the biggest drivers of fine-tuning gains is data selection. With the launch of `smithtune`, it’s easier to connect that loop — from curated production traces in LangSmith to managed training and a served model on Fireworks. Teams can move seamlessly from data to training to deployment without standing up infrastructure along the way. That’s the path we’re excited to be building with LangChain._‍
>
> > – Pranav Jain, Product Lead at Fireworks
>
> > _`smithtune's` integration with Baseten Loops makes it seamless for teams to go from data collection to running fine-tuning experiments in minutes. Builders are able to continuously collect and curate better data to produce better models over time with the fully managed training infrastructure that Loops provides so they can focus on designing for their biggest customer use-cases._ ‍
>
> > – Aaron Ellis-Bloor, Applied Researcher at Baseten
>
> ## Agent trajectories and post-training
>
> Before diving into the capabilities `smithtune` provides, let’s first discuss agent trajectories.
>
> A trajectory is an ordered sequence of messages, tool calls, and tool results that shows how an agent worked through a task. [LangSmith](https://www.langchain.com/langsmith-platform) assembles this sequence from a trace or thread, brings supported message formats into a common representation, preserves tool definitions, and removes duplicated history.
>
> LangSmith trajectory format was designed with post-training in mind. For SFT, the student model needs the exact context the teacher model had when it produced a successful result. In complex long-running agents, tool availability context often changes as the agent works (for example, [deferred tool loading](https://www.anthropic.com/engineering/advanced-tool-use)), and a naive export of the final message list loses that nuance. LangSmith's trajectory format records precisely what the model saw at every turn, so smithtune can pair each action with its true context.
>
> *Anatomy of a trajectory in LangSmith*
> ![[langchain-smithtune-02.png]]
>
> `smithtune` uses trajectories throughout the workflow. You curate successful example trajectories, prepare them for your chosen model, and train on their recorded responses and tool calls. Trajectories kept out of the training split provide the context and reference actions for evaluation.
>
> ## Step-by-step walkthrough
>
> *From trace data to an optimized model: the smithtune pipeline*
> ![[langchain-smithtune-01.png]]
>
> ### Build your dataset
>
> A dataset contains ‘golden’ trajectories that a target model will fit to. This data is the foundation for supervised fine-tuning.
>
> There are a few key stages when creating a dataset with `smithtune` :
>
> 1. **Pull Dataset:** `smithtune` pulls trajectories from a LangSmith tracing project to a local directory `DIR`, with optional filters.
> 2. **Label Traces:** `smithtune` works with humans (and their agents) to identify characteristics of “good” traces, create a rubric to based on this, and then sends a council of agents to review and filter trajectories that are good candidates for SFT
> 3. **Store a persistent dataset:** `smithtune` makes sure that any data used for training can be audited later as a persistent artifact. It uploads the agreed on set of golden trajectories to a LangSmith dataset for training and evaluation.
>
> Along the way `smithtune` handles details such as:
>
> * making sure trajectories are compatible with a chosen model by filtering traces that are beyond a given sequence length
> * splitting data into train/val/tests splits for downstream evaluation
>
> ### Train a model
>
> Before committing to training, `smithtune plan` helps humans review their settings such as the selected model, the number of training examples, and hyperparameters like the learning rate, batch size, and epochs.
>
> You can adjust these settings before running `smithtune train` to start the fine-tuning job. `smithtune` submits the job to [Fireworks managed SFT](https://docs.fireworks.ai/fine-tuning/fine-tuning-models) or [Baseten Loops](https://www.baseten.co/blog/introducing-the-baseten-loops-sdk/) which support LoRA training on your prepared trajectories. There's no GPU provisioning or training infrastructure to manage on your side. During training, `smithtune` also checks performance on the validation set and selects the saved checkpoint with the lowest validation loss.
>
> ### Evaluate the result
>
> After training completes, run `smithtune evaluate` to compare the selected checkpoint with the base model.
>
> `smithtune` uses a built-in replay evaluation to test the base vs fine-tuned model. Models are evaluated on being able to complete actions from a golden trajectory and a judge scores those predictions against the true recorded examples.
>
> The CLI returns a LangSmith comparison link, with results appearing as evaluation progresses. You can compare scores, inspect individual responses and tool choices, and see where fine-tuning helped or introduced regressions.
>
> ### Deploy your model
>
> If you’re happy with your evaluation results, use `smithtune deploy` to serve your tuned model and connect it to your application.
>
> If the results aren’t what you were looking for, refine your dataset or adjust the training settings, then train and evaluate again. You can review the comparison in LangSmith with your coding agent to identify which responses or tool choices need more work.
>
> ## Results from running this in practice
>
> To assess the quality of our `smithtune` flow, we applied it to two highly used agents at LangChain:
>
> * [Engine](https://www.langchain.com/langsmith/engine) analyzes agent traces to find failures and group related issues. Using a stripped-down version of one of the agents in Engine, we tested whether SFT could improve its ability to identify and organize those problems.
> * [OpenSWE Review](https://github.com/langchain-ai/open-swe) reviews code changes in our real-world repositories. We tested whether SFT could preserve review quality while reducing the work needed to find bugs.
>
> ### Engine: higher task performance through specialization
>
> We curated a set of good trajectories and used them to fine-tune base Kimi K3\. The base Kimi model was already strong, but we had exhausted our ability to push it or GPT-5.6 Sol further via harness engineering. The fine-tuned model scored well above both base Kimi and GPT-5.6 Sol on a subset of IssueBench, our internal benchmark for issue detection and grouping.
>
> | Model         | Task score ↑ |
> | ------------- | ------------ |
> | GPT-5.6 Sol   | 87.0         |
> | Kimi K3       | 90.0         |
> | Kimi K3 + SFT | 96.0         |
>
> ### OpenSWE Review: similar quality with fewer calls
>
> We also evaluated Qwen-3.8-27B on an internal evaluation set of real pull requests used to measure code-review quality and bug detection. In this comparison, SFT raised F1 from **48.9% to 53.7%**, while using **29.8% fewer model calls** and **29.4% fewer tool requests**.
>
> | Model              | F1 ↑  | Precision ↑ | Recall ↑ | Model calls per review ↓ | Tool requests per review ↓ |
> | ------------------ | ----- | ----------- | -------- | ------------------------ | -------------------------- |
> | Qwen-3.8-27B       | 48.9% | 62.9%       | 40.0%    | 55.9                     | 65.8                       |
> | Qwen-3.8-27B + SFT | 53.7% | 81.5%       | 40.0%    | 39.2                     | 46.5                       |
>
> An earlier, less selective training set reduced the F1 score after SFT. We then went back to our data curation pipeline and added a review stage for each Trace, looking to oversample traces where agents thought potential issues actually existed.
>
> The practical opportunity is similar review quality with fewer model and tool calls. This means a cheaper outcome per review and a faster time-to-review per PR.
>
> ## Considerations for post-training
>
> ### When SFT makes sense
>
> SFT is especially useful when your application performs repeated tasks and you have examples of how it should behave. Look for consistent patterns you want the model to learn, such as following workflows, using tool results to decide what to do next, and verifying its work.
>
> We recommend that teams start with harness engineering to understand if a better [harness](https://www.langchain.com/blog/the-anatomy-of-an-agent-harness) gives good performance. If agents still make recurring mistakes on tasks, and you have trajectories that show how to correctly do that task, then SFT is a great candidate to try.
>
> ### Data selection
>
> We consistently find that the most successful post-training runs come from investing time into data selection for training. `smithtune` explicitly helps users look at their data with agents and we find that having domain experts work with agents to review traces for SFT improves the chances of successful post-training runs
>
> ## Getting started with LangSmith Fine-Tuning
>
> LangSmith Fine-Tuning is now available in Public Beta. To get started, you’ll need:
>
> * A [LangSmith account](https://smith.langchain.com/) with traces from your agent
> * An API key for [Fireworks](https://fireworks.ai/) or [Baseten](https://www.baseten.co/)
> * [The smithtune CLI](https://github.com/langchain-ai/smithtune)
>
> Try `smithtune` on GitHub, and let us know what you want to see next. We’d love your feedback as we keep improving fine-tuning workflows in LangSmith.
>
> [Get started with LangSmith Fine-Tuning on GitHub](https://github.com/langchain-ai/smithtune).
>
> #### Docs: smithtune
>
> *[docs.langchain.com/langsmith/smithtune](https://docs.langchain.com/langsmith/smithtune)*
>
> # Fine-tune models with Smithtune
>
> > Use Smithtune to fine-tune models on LangSmith conversations and compare the results in LangSmith.
>
> <Note>
>   Smithtune is in [beta](/langsmith/release-stages).
> </Note>
>
> Smithtune is a command-line tool for fine-tuning models on [trajectories](/langsmith/observability-concepts#trajectories) recorded in LangSmith. It trains a model with [Fireworks](https://fireworks.ai/) or [Baseten](https://www.baseten.co/) and compares the base and tuned models in a LangSmith [experiment](/langsmith/evaluation-concepts#experiment). You can optionally deploy the tuned model as an endpoint for your application.
>
> ## How Smithtune works
>
> <Steps>
>   <Step title="Create a dataset">
>     Select trajectories from a tracing project with a [trace query](/langsmith/trace-query-syntax) filter, a model judge, or both.
>   </Step>
>
>   <Step title="Prepare data">
>     Validate the trajectories, then split them into training, validation, and test data. Each trajectory stays in one split.
>   </Step>
>
>   <Step title="Train a model">
>     Preview the run, then fine-tune a supported model with your provider.
>   </Step>
>
>   <Step title="Compare results">
>     Evaluate the base and tuned models on the test data, then [compare the experiments](/langsmith/compare-experiment-results) in LangSmith. Evaluation does not require a deployed endpoint.
>   </Step>
>
>   <Step title="Deploy an endpoint (optional)">
>     Serve the tuned model for your application. To run an agent that uses it in production, see [LangSmith Deployment](/langsmith/deployment).
>   </Step>
> </Steps>
>
> <Tip>
>   To have your coding agent drive the fine-tuning process end to end, use the [Smithtune skill](https://github.com/langchain-ai/smithtune/blob/main/src/smithtune/skills/smithtune/SKILL.md).
> </Tip>
>
> Evaluation scores measure how closely each model matches the recorded behavior, not whether it completes tasks end to end. Smithtune does not execute the tool calls the model generates.
>
> ## Set up Smithtune
>
> Smithtune requires trajectories in a tracing project or a LangSmith trajectory dataset. You also need API keys for LangSmith, your training provider, and a judge model. Training, evaluation, and deployed endpoints incur charges from the services you use.
>
> To set up Smithtune:
>
> 1. Install Smithtune and the [LangSmith CLI](/langsmith/langsmith-cli), and set your API keys. Follow the [Smithtune README](https://github.com/langchain-ai/smithtune#readme) for the install command and the environment variables each provider needs.
>
> 2. Read the [data rights and permitted use terms](https://github.com/langchain-ai/smithtune/blob/main/docs/data-rights-and-permitted-use.md) linked from the [README](https://github.com/langchain-ai/smithtune#readme), then acknowledge them before your first run:
>
>    ```bash theme={"theme":{"light":"catppuccin-latte","dark":"catppuccin-mocha"}}
>    smithtune acknowledge-data-rights
>    ```
>
> 3. Check your local setup:
>
>    ```bash theme={"theme":{"light":"catppuccin-latte","dark":"catppuccin-mocha"}}
>    smithtune doctor
>    ```
>
> For the commands in each step, see the [README](https://github.com/langchain-ai/smithtune#readme) or run `smithtune --help`.
>
> ## See also
>
> * [Trajectory evaluations](/langsmith/trajectory-evals)
> * [Query threads](/langsmith/query-threads)
> * [Manage datasets](/langsmith/manage-datasets)
>
> ***
>
> <div className="source-links">
>   <Callout icon="terminal-2">
>     [Connect these docs](/use-these-docs) to your agent of choice via MCP for real-time answers.
>   </Callout>
>
>   <Callout icon="edit">
>     [Edit this page on GitHub](https://github.com/langchain-ai/docs/edit/main/src/langsmith/smithtune.mdx) or [file an issue](https://github.com/langchain-ai/docs/issues/new/choose).
>   </Callout>
> </div>
>
> #### README: langchain-ai/smithtune
>
> *[github.com/langchain-ai/smithtune](https://github.com/langchain-ai/smithtune) - 9 stars, Python, MIT, created 2026-09-10, v0.1.0*
>
> <h1 align="center">smithtune</h1>
>
> Fine-tune models on [trajectories](https://docs.langchain.com/langsmith/observability-concepts#trajectories)
> recorded in LangSmith. Train with Fireworks or Baseten, compare the base and tuned models
> in LangSmith, then optionally deploy an endpoint for your application.
>
> smithtune is an early beta project; commands and saved-directory formats may change
> between releases. If you run into issues, please report them in the
> [repository](https://github.com/langchain-ai/smithtune/issues).
>
> ## Quickstart
>
> Install the CLI with [uv](https://docs.astral.sh/uv/getting-started/installation/):
>
> ```bash
> uv tool install --python 3.12 \
>   --overrides https://raw.githubusercontent.com/langchain-ai/smithtune/v0.1.0/overrides.txt \
>   'smithtune[deepagents] @ git+https://github.com/langchain-ai/smithtune.git@v0.1.0'
> ```
>
> Install the smithtune skill so your coding agent (Claude Code, Codex, Cursor, and
> others) can run the whole flow:
>
> ```bash
> npx skills add langchain-ai/smithtune
> ```
>
> Set `LANGSMITH_API_KEY` and `BASETEN_API_KEY` (or `FIREWORKS_API_KEY`; see
> [credentials](#credentials-and-first-use-setup)), then check your setup:
>
> ```bash
> smithtune acknowledge-data-rights
> smithtune doctor
> ```
>
> Then ask your agent:
>
> ```text
> Use the smithtune skill to fine-tune a model on my LangSmith project <project> with [Baseten or Fireworks].
> ```
>
> The flow:
>
> ```text
> dataset pull → dataset triage (optional) → dataset push
> prepare → plan → train --evaluate → deploy (optional)
> ```
>
> | What you have | Start here |
> | --- | --- |
> | Trajectories in a tracing project | [Create a dataset](#create-a-dataset-from-trajectories) |
> | A LangSmith trajectory dataset | [Prepare data](#prepare-data) |
> | Prepared smithtune data | [Plan and train](#plan-and-train) |
> | A completed training run | [Evaluate](#evaluate-a-trained-model) or [deploy](#deploy-a-trained-model) |
>
> ## Setup
>
> The [quickstart](#quickstart) install includes the `deepagents` extra, used by the
> optional agent council that votes on which trajectories to keep. The overrides file
> selects a newer Hugging Face Transformers release; when installing another tag, use
> the same tag in both URLs. To update, rerun the install with the new tag and `--force`.
>
> Install the [LangSmith CLI](https://github.com/langchain-ai/langsmith-cli) for reading traces and datasets:
>
> ```bash
> curl -fsSL https://cli.langsmith.com/install.sh | sh
> ```
>
> ## Using with a coding agent
>
> The [smithtune skill](https://github.com/langchain-ai/smithtune/blob/main/src/smithtune/skills/smithtune/SKILL.md) walks a coding
> agent through the whole flow: choosing and testing a filter, optional council
> review, preparation, training, evaluation, and deployment, with a check after each
> step. Install it with `npx skills add langchain-ai/smithtune` (add `-g` to install
> it for every project), or just tell your agent to install it for you.  Then describe your task:
>
> ```text
> Use the smithtune skill to <task> with <provider>.
> My data: <workspace/project/dataset IDs or prepared-data directory>.
> ```
>
> ### Credentials and first-use setup
>
> Set these environment variables in the shell where you run smithtune:
>
> | Variable | Needed for |
> | --- | --- |
> | `LANGSMITH_API_KEY` | Every workflow: dataset access, split publication, and LangSmith experiments |
> | `BASETEN_API_KEY` | Baseten training and evaluation, plus the default council and evaluation judge (DeepSeek V4.1 Flash and GLM-5.3-Flash on Baseten Model APIs) |
> | `FIREWORKS_API_KEY` | Fireworks training and evaluation, and Fireworks-hosted judges |
>
> The LangSmith CLI uses `LANGSMITH_API_KEY` for authentication.
>
> Read [Data Rights and Permitted Use](https://github.com/langchain-ai/smithtune/blob/main/docs/data-rights-and-permitted-use.md).
> The first workflow requires an interactive acknowledgment, saved locally;
> `--confirm` does not replace it. Before running scripts, acknowledge and check setup:
>
> ```bash
> smithtune acknowledge-data-rights
> smithtune doctor
> ```
>
> `doctor` checks local prerequisites, not service access. Use `smithtune --help`
> or `smithtune <command> --help` for command options.
>
> ### Confirm paid work
>
> Paid model calls and GPU capacity require `--confirm` on the command to run them.
>
> | Command | Without `--confirm` |
> | --- | --- |
> | `dataset triage` | Previews council calls |
> | `dataset resume` | Shows pending work |
> | `train`, `evaluate`, `deploy` | Stops before paid work |
> | `dataset push` | Previews the upload |
> | `undeploy` | Stops before changing provider resources |
>
> You can use `plan` before training and `eval-plan` before evaluation. Neither starts paid
> compute. Commands without confirmation can still read remote data or write local
> files. `prepare` and `dataset publish-splits` also write LangSmith split metadata;
> they do not train or call models. Running endpoints keep incurring charges until stopped.
>
> ### Choose your provider and directories
>
> Use the same provider and paths throughout. For an existing run, use its original
> provider and directories. Set the workspace to the one containing your dataset:
>
> ```bash
> provider=fireworks # or baseten
> model=qwen3p8-27b
> workspace_id='<workspace-id>'
> data_dir='./data/my-sft'
> run_dir='./runs/my-sft'
> judge_model='baseten/zai-org/GLM-5.3-Flash'  # Fireworks only: accounts/fireworks/models/deepseek-v4p1-flash
>
> smithtune models list --provider "$provider"
> ```
>
> `qwen3p8-27b` works with both providers. Choose another supported model from the list;
> preparation selects its tokenizer and formatting.
>
> ## Create a dataset from trajectories
>
> Skip this step if you already have a LangSmith trajectory dataset. Otherwise,
> pull trajectories from a tracing project and push them to a LangSmith dataset.
> Reviewing them with an agent council in between is optional.
>
> ### 1. Write and test a filter
>
> The filter decides what the model learns from, and `pull` saves it for the
> directory. Filters use [LangSmith filter syntax](https://docs.langchain.com/langsmith/trace-query-syntax)
> and match **root runs**; each match brings in its whole thread. Look at your
> project's real root names, tags, metadata, and feedback keys, then test the
> filter with the LangSmith CLI over the window you will pull. It uses the same
> syntax and costs nothing:
>
> ```bash
> project_id='<project-id>'
> filter='and(eq(feedback_key, "correctness"), gte(feedback_score, 0.9))'
>
> langsmith trace list --workspace "$workspace_id" --project-id "$project_id" \
>   --filter "$filter" --since 2026-09-01T00:00:00Z --before 2026-09-22T00:00:00Z \
>   --limit 50 --full --format json
> ```
>
> ### 2. Pull, then push
>
> When the filter already selects on a trusted quality signal, such as validated
> feedback scores or human labels, skip council review with `--no-triage`:
>
> ```bash
> smithtune dataset pull data/datasets/my-sft \
>   --workspace-id "$workspace_id" --project-id "$project_id" \
>   --start-time 2026-09-01T00:00:00Z --end-time 2026-09-22T00:00:00Z \
>   --filter "$filter" --target-count 100 --no-triage
>
> smithtune dataset push data/datasets/my-sft --name my-sft-dataset   # preview
> smithtune dataset push data/datasets/my-sft --confirm               # upload
> ```
>
> - `pull` downloads without model calls. Inspect its summary for usable trajectories and exclusion reasons.
> - `--target-count` is how many trajectories you want (default 100); `--max-candidates` caps new candidates per pull (default 1,000, maximum 2,000).
> - Always set `--start-time` and `--end-time`; the default window is the last 24 hours.
> - `push` previews the upload; `--confirm` uploads and returns the dataset ID for `prepare`.
>
> Selecting an agent by name or filtering out errors alone does not establish
> training quality. Without a trusted signal, use council review.
>
> ### Optional: review with an agent council
>
> Omit `--no-triage` from the first `pull`, then run `triage` before `push`. A
> council of models judges each whole trajectory against your rubric and keeps it
> on a strict majority. You need:
>
> - the `deepagents` extra (included in the install above);
> - keys for the judges: `BASETEN_API_KEY` for the default council (DeepSeek
>   V4.1 Flash and GLM-5.3-Flash on Baseten), 'FIREWORKS_API_KEY' or pick others with `--judges`
>   (see [judge options](https://github.com/langchain-ai/smithtune/blob/main/docs/datasets.md#review-training-examples-with-an-agent-council));
> - a `rubric.md` describing the task, what to keep, what to drop, and a few
>   concrete examples of each. smithtune ships no default rubric; `triage`
>   requires `--rubric` or `--rule`. Write it after reading a varied sample of the
>   pulled trajectories; the
>   [smithtune skill](https://github.com/langchain-ai/smithtune/blob/main/src/smithtune/skills/smithtune/SKILL.md#3-triage-with-a-council-only-in-council-mode)
>   has a template.
>
> ```bash
> smithtune dataset triage data/datasets/my-sft --rubric ./rubric.md   # preview, no model calls
> smithtune dataset triage data/datasets/my-sft --confirm              # run the council
> ```
>
> Decisions are saved in `labels.jsonl` and summarized in `report.md`; read them
> before pushing. Review stops at the target. If the pool runs out first, run
> `pull` and `triage --confirm` again in the same directory to review unseen
> candidates (up to three rounds). Council review helps assess quality; it does
> not guarantee good training data.
>
> Keep the same directory throughout. The review mode, filter, window, and limits
> are fixed once you pull. Use `smithtune dataset resume data/datasets/my-sft` to
> inspect pending work and add `--confirm` to continue it. See
> [dataset curation](https://github.com/langchain-ai/smithtune/blob/main/docs/datasets.md) for selection and recovery details.
>
> ## Prepare data
>
> Use the dataset ID returned by `push`, or your existing dataset ID:
> ```bash
> dataset_id='<dataset-id>'
>
> smithtune prepare \
>   --provider "$provider" --model "$model" \
>   --workspace-id "$workspace_id" --dataset-id "$dataset_id" \
>   --data-dir "$data_dir"
> ```
>
> Preparation checks each trajectory and the tools available at each assistant turn.
> It assigns about 80% to training, 10% to validation, and 10% to testing. Each source trajectory
> stays in one split; the memberships are also published to the LangSmith dataset.
>
> Recorded system messages are preserved; reasoning is omitted by default. Unsupported
> or overlong trajectories are excluded without truncation and listed in
> `"$data_dir/prepared/rejected.json"`. Each supported assistant answer becomes one
> training target, with its preceding context and the tools available at that call.
> See the [preparation reference](https://github.com/langchain-ai/smithtune/blob/main/docs/reference.md#prepare-data) for data requirements,
> reasoning options, and split recovery.
>
> ## Plan and train
>
> Preview the work, then run training and evaluation:
> ```bash
> smithtune plan \
>   --provider "$provider" --data-dir "$data_dir" \
>   --evaluate --judge-model "$judge_model" --max-points-per-trajectory 2
>
> smithtune train \
>   --provider "$provider" --data-dir "$data_dir" --run-dir "$run_dir" \
>   --evaluate --judge-model "$judge_model" --max-points-per-trajectory 2 \
>   --confirm
> ```
>
> **Training and evaluation incur provider charges.** Review the preview's case and
> call counts. The example caps evaluation at two assistant actions per test trajectory;
> omit the cap from both commands to evaluate every eligible action. Each comparison
> generates and judges a base response and a tuned response, plus judge calibration calls.
>
> Use a new or empty run directory. Repeat custom settings on both commands;
> `plan` is a preview and does not save settings for `train`.
>
> The CLI selects the saved model checkpoint with the lowest validation loss and
> compares it with the base model on held-out test data. Evaluation uses provider
> samplers to generate responses. Fireworks reuses its training session; Baseten starts temporary paid
> samplers and deactivates them on exit. You do not need to run `deploy` for this step.
> Omit `--evaluate` and its replay options to train only.
>
> ## Review results in LangSmith
>
> The CLI prints **one comparison link** for the base and tuned experiments when
> evaluation starts. Results publish in the background; each trajectory's row appears
> when all its selected comparisons finish. The final JSON includes `langsmith.comparison_url`.
>
> - `teacher_agreement`: whether an assistant action passed the judge, with an explanation.
> - `trajectory_teacher_agreement`: the trajectory's average score.
>
> Replay predicts the next response or tool call from recorded context; generated
> tool calls are **not executed**. Scores measure agreement with recorded behavior,
> not end-to-end task completion, and do not affect checkpoint selection.
>
> ## Evaluate a trained model
>
> Use standalone evaluation after training or to resume interrupted evaluation.
> Keep the original provider, directories, and replay settings:
>
> ```bash
> smithtune eval-plan \
>   --provider "$provider" --data-dir "$data_dir" --run-dir "$run_dir" \
>   --max-points-per-trajectory 2
>
> smithtune evaluate \
>   --provider "$provider" --data-dir "$data_dir" --run-dir "$run_dir" \
>   --judge-model "$judge_model" --max-points-per-trajectory 2 --confirm
> ```
>
> `eval-plan` previews without model calls. `evaluate` compares the saved best checkpoint
> with the base model and saves results in `"$run_dir/replay"`. Rerunning reuses completed
> predictions and judgments and retries LangSmith publication. Keep your local artifacts.
>
> To change the judge, replay cap, or sampling settings, use a fresh
> `--output-dir` on both commands. See [evaluation options and recovery](https://github.com/langchain-ai/smithtune/blob/main/docs/reference.md#replay-options).
>
> ## Deploy a trained model
>
> Deploy when you want an endpoint for your application. Both providers
> use `deploy`; Fireworks handles promotion automatically and reuses saved promotions.
> Run the command for your training provider:
>
> **Fireworks**: install [firectl](https://docs.fireworks.ai/tools-sdks/firectl/firectl)
> and use the account owning your checkpoint:
>
> ```bash
> smithtune deploy --provider fireworks --run-dir "$run_dir" \
>   --account-id '<fireworks-account>' --output-model-id my-tuned-model \
>   --deployment-id my-endpoint --deployment-shape '<compatible-deployment-shape>' \
>   --confirm
> ```
>
> **Baseten**: install the [deployment extra](https://github.com/langchain-ai/smithtune/blob/main/docs/deployment.md#deploy-a-baseten-checkpoint)
> first. Choose hardware and a context cap suitable for your model; these are example values:
>
> ```bash
> smithtune deploy --provider baseten --run-dir "$run_dir" \
>   --accelerator H200:1 --max-seq-len 32768 --confirm
> ```
>
> Endpoints stay running and can incur charges. Stop serving when finished:
>
> ```bash
> # Fireworks
> smithtune undeploy --provider fireworks \
>   --account-id '<fireworks-account>' --deployment-id my-endpoint --confirm
>
> # Baseten
> smithtune undeploy --provider baseten --run-dir "$run_dir" --confirm
> ```
>
> See the [deployment guide](https://github.com/langchain-ai/smithtune/blob/main/docs/deployment.md) for setup, recovery, and endpoint evaluation.
>
> ## More guides
>
> | Task | Guide |
> | --- | --- |
> | Filter, judge, resume, or extend a dataset | [Dataset curation](https://github.com/langchain-ai/smithtune/blob/main/docs/datasets.md) |
> | Configure models, splits, reasoning, or evaluation | [Preparation and evaluation reference](https://github.com/langchain-ai/smithtune/blob/main/docs/reference.md) |
> | Deploy and manage endpoints | [Deployment](https://github.com/langchain-ai/smithtune/blob/main/docs/deployment.md) |
> | Contribute to smithtune | [Development setup](https://github.com/langchain-ai/smithtune/blob/main/CONTRIBUTING.md) |
>
> #### docs/data-rights-and-permitted-use.md
>
> *[docs/data-rights-and-permitted-use.md](https://github.com/langchain-ai/smithtune/blob/main/docs/data-rights-and-permitted-use.md) - the document `smithtune acknowledge-data-rights` requires you to confirm you have read*
>
> # Data Rights and Permitted Use
>
> Version: 1
>
> smithtune helps you prepare agent trajectories, fine-tune models, and evaluate results. Its availability does not establish that a particular dataset, model, or use is authorized.
>
> ## Your responsibility for data rights
>
> You are responsible for ensuring that you have all rights, permissions, and any required consents to use the data you process with smithtune for your intended training, evaluation, and deployment. This includes prompts, system instructions, model-generated outputs, tool calls and results, code, and other content contained in your traces or datasets. Permission to access a trace or dataset does not necessarily include permission to use its contents for these purposes.
>
> ## Provider terms and model licenses
>
> Your use must comply with applicable law, relevant model and dataset licenses, and the agreements governing the services used to generate or process your data. These agreements may restrict distillation, training competing models, or other uses of model outputs. Do not use smithtune to violate or circumvent those restrictions.
>
> Ownership of model outputs, internal-only use, or selection of an open-weight target model does not, by itself, establish permission for your intended use. Review the agreements applicable to your workflow and obtain any required authorization before proceeding.
>
> ## Data transfers and sensitive information
>
> Depending on the commands and configuration you use, smithtune may transmit data to LangSmith and selected training, triage, and evaluation providers. Selected trajectories may include complete conversations, system instructions, and tool context—not just individual responses.
>
> Before processing or transmitting data, review its contents, remove credentials and other secrets, and ensure that any personal, confidential, or third-party information is authorized for the intended use and disclosure. You are responsible for selecting appropriate providers and complying with applicable privacy, confidentiality, and security obligations.
>
> ## No grant of third-party rights
>
> Support for a model, provider, or integration is not a representation that your intended use is permitted. smithtune’s software license does not grant rights to third-party data, model weights, or services, or override their applicable terms. Technical validation and evaluation results do not verify legal compliance.
>
> #### SKILL.md: the smithtune skill
>
> *[src/smithtune/skills/smithtune/SKILL.md](https://github.com/langchain-ai/smithtune/blob/main/src/smithtune/skills/smithtune/SKILL.md)*
>
> ---
> name: smithtune
> description: Run the smithtune fine-tuning flow end to end — select LangSmith trajectories and upload them as a dataset (pull, optional council triage, push), prepare it for Fireworks or Baseten, plan and train with base-vs-tuned evaluation, and optionally deploy. Use when a user wants to fine-tune a model on their LangSmith traces, build an SFT dataset from a tracing project, train or evaluate with smithtune, or resume/debug a smithtune run.
> ---
>
> # smithtune workflow
>
> smithtune turns LangSmith trajectories into a fine-tuned model:
>
> ```text
> dataset pull → (dataset triage) → dataset push    build a LangSmith dataset
> prepare → plan → train --evaluate                 train and compare base vs tuned
> deploy → undeploy                                 optional endpoint
> ```
>
> Installation and credentials live in the
> [README](https://github.com/langchain-ai/smithtune/blob/main/README.md). This
> skill covers how to operate the flow: which command to run, in what order, what
> to check after each one, and when you are done. Run `smithtune <command> --help`
> before an unfamiliar command.
>
> ## Rules that apply to every step
>
> - **Parse the JSON.** Every command prints a JSON result on stdout and progress
>   on stderr. Keep the IDs and paths it returns, and follow its `next_command`
>   when present instead of guessing the next step.
> - **Preview before paying.** `triage`, `resume`, `push`, `train`, `evaluate`,
>   `deploy`, and `undeploy` do nothing billable or remote-changing without
>   `--confirm`. Run each one without `--confirm` first, show the user the
>   preview, and add `--confirm` only when the user has authorized that specific
>   operation. Authorization for one step does not cover the next.
> - **One directory per stage, reused throughout.** The same dataset directory for
>   `pull`/`triage`/`push`/`resume`; the same `--data-dir` for
>   `prepare`/`plan`/`train`/`evaluate`; a new or empty `--run-dir` per training
>   run. Settings are frozen into these directories once work starts. To change
>   source, filter, time window, limits, review mode, or rubric, use a new
>   directory.
> - **Same provider throughout.** One `--provider` (`fireworks` or `baseten`)
>   from `prepare` through `deploy`.
> - **Never guess IDs, fields, or thresholds.** Ask for workspace, project, and
>   dataset IDs. Build filters only from fields you have seen in the project.
> - **Never print credential values.** Check presence with `smithtune doctor`.
>
> ## 0. Before anything
>
> ```bash
> smithtune doctor
> smithtune models list --provider "$provider"
> ```
>
> Check:
> - `doctor` shows the keys the user's path needs as `set` (presence only, not
>   validity); `credentials_required_for` says what each key is for:
>
> | Path | Keys |
> | --- | --- |
> | Baseten | `LANGSMITH_API_KEY`, `BASETEN_API_KEY` (Model API access covers the default council and evaluation judge) |
> | Fireworks, with a Baseten key | `LANGSMITH_API_KEY`, `FIREWORKS_API_KEY`, `BASETEN_API_KEY` for the default judges |
> | Fireworks only | `LANGSMITH_API_KEY`, `FIREWORKS_API_KEY`; then pass `--judges deepseek-v4.1-flash,glm-5.3-flash` to `triage` and set `judge_model=accounts/fireworks/models/deepseek-v4p1-flash` |
>
> - The requested model is in `models list`.
> - Data rights are acknowledged. If not, the user must run
>   `smithtune acknowledge-data-rights` in an interactive terminal; you cannot do
>   it for them and `--confirm` does not replace it.
>
> Set the values used below once, and reuse them in every command:
>
> ```bash
> provider=baseten                 # or fireworks; --provider defaults to fireworks, so always pass it
> model=qwen3p8-27b                # from `smithtune models list`
> workspace_id='<workspace-id>'
> project_id='<project-id>'
> dataset_dir=./data/datasets/my-sft
> data_dir=./data/my-sft
> run_dir=./runs/my-sft
> judge_model=baseten/zai-org/GLM-5.3-Flash   # default; see the table above for Fireworks only
> start_time=2026-09-01T00:00:00Z  # ISO 8601 with timezone
> end_time=2026-09-22T00:00:00Z
> ```
>
> Pick the starting point:
>
> | The user has | Start at |
> | --- | --- |
> | Traces in a tracing project | Step 1 |
> | A LangSmith trajectory dataset | Step 5 (`prepare`) |
> | A prepared `--data-dir` | Step 6 (`plan`) |
> | A finished `--run-dir` | Step 8 (`evaluate`) or step 9 (`deploy`) |
>
> Continue from existing directories when they match the task. For an existing
> LangSmith dataset that smithtune did not create, `prepare` recovers per-turn
> tool data from the source traces only when the example's messages match the
> source trajectory exactly; otherwise it rejects those examples.
>
> ## 1. Choose the source and write the filter
>
> The filter decides what the model learns from. Do this carefully and with the
> user; `pull` freezes it into the directory.
>
> **1a. Identify the project.** Get the workspace ID and project ID from the
> user. If they only know the name, list projects:
>
> ```bash
> langsmith project list --workspace "$workspace_id" --format json
> ```
>
> **1b. Look at real root runs.** Filters match **root runs** (traces), so
> inspect roots, not child LLM calls:
>
> ```bash
> langsmith trace list --workspace "$workspace_id" --project-id "$project_id" \
>   --since 2026-09-01T00:00:00Z --limit 20 --full --format json
> ```
>
> From the output, write down what actually exists:
> - root `name` values (which agent or graph produced the trace);
> - `tags` and `custom_metadata` keys and typical values (environment, version,
>   customer tier, etc.);
> - `feedback_stats` keys and their score ranges (e.g. `correctness` 0–1,
>   `user_thumbs` 0/1) and how many roots have each key;
> - how many roots errored.
>
> **1c. Agree with the user what "good training data" means**, then map it to
> those fields. Ask:
> - Which agent (root name) should the model imitate?
> - Is there feedback that means the run was good? Which key, and what score
>   counts as good? What fraction of traces have it?
> - Any environment, version, or tag restrictions (e.g. production only, after a
>   prompt change)?
> - What time window?
>
> Do not invent feedback keys, thresholds, or what a missing score means. If
> there is no trustworthy quality signal, say so; that is the case for council
> review in step 3.
>
> **1d. Write the filter** in [LangSmith filter syntax](https://docs.langchain.com/langsmith/trace-query-syntax).
> Common building blocks:
>
> | Intent | Filter |
> | --- | --- |
> | One agent | `eq(name, "support-agent")` |
> | Has a tag | `has(tags, "production")` |
> | Metadata value | `and(eq(metadata_key, "env"), eq(metadata_value, "prod"))` |
> | Good feedback | `and(eq(feedback_key, "correctness"), gte(feedback_score, 0.9))` |
> | One known root | `eq(id, "<root-run-id>")` (time bounds must include it) |
> | Combine | `and(eq(name, "support-agent"), has(tags, "production"))` |
>
> **1e. Test the filter before pulling.** `langsmith trace list --filter` takes
> the same syntax and costs nothing. Use the same window you will pull:
>
> ```bash
> langsmith trace list --workspace "$workspace_id" --project-id "$project_id" \
>   --filter "$filter" --since "$start_time" --before "$end_time" \
>   --limit 50 --full --format json
> ```
>
> Check that:
> - the matches are the agent and behavior the user wants (open a few);
> - there are enough of them for the target (the smithtune default target is 100);
> - nothing obviously wrong slipped in (errors, test traffic, other agents).
>
> Adjust and re-test until the user agrees. Only then pull.
>
> Know what the filter does **not** limit: each matching root pulls in its
> **whole thread**, including earlier turns and turns outside the filter and time
> window. The training example is the full trajectory.
>
> ## 2. Pull
>
> **Ask the user whether to review with a council before pulling.** The choice is
> fixed for the directory, so settle it now. Explain both options:
>
> | | No council review | Council review |
> | --- | --- | --- |
> | Use when | The filter already selects on a trusted quality signal (validated feedback score, human labels) | There is no trustworthy quality signal, or the user wants a second check |
> | Pull flag | `--no-triage` | none (this is the CLI default) |
> | What the target counts | Structurally usable trajectories | Council-approved trajectories |
> | Extra keys | None | Judge keys (`BASETEN_API_KEY` for the default council) |
> | Extra work | None; go straight to push | Write a rubric with the user (step 3) |
> | Cost | No model calls | One judge call per trajectory per council member |
>
> Recommend one based on what you found in step 1: if the user's quality signal
> is real and well covered, suggest no review; if not, suggest council review.
> An agent-name filter or "no errors" alone is not a quality signal. Let the user
> decide, and record the choice.
>
> Because omitting the flag means council review, always pass `--no-triage`
> explicitly when the user chose no review.
>
> ```bash
> smithtune dataset pull "$dataset_dir" \
>   --workspace-id "$workspace_id" --project-id "$project_id" \
>   --start-time "$start_time" --end-time "$end_time" \
>   --filter "$filter" \
>   --target-count 100 --max-candidates 1000 \
>   --no-triage   # omit to use council review
> ```
>
> - Always pass explicit `--start-time`/`--end-time` (ISO 8601 with timezone).
>   Without them the window is the last 24 hours.
> - `--target-count`: how many trajectories you want in the final dataset.
> - `--max-candidates`: cap on **new** candidates per pull round (max 2000). In
>   council mode, set it well above the target, since some will be rejected.
> - Pull makes no model calls. Re-running the same command resumes it.
>
> Check:
> - `download_summary`: selected roots, threads, traces, and exclusion counts by
>   reason. Exclusions come from missing tool data, multimodal content, provider
>   built-in tools, or oversized pages. If a large share is excluded, report the
>   reasons before continuing.
> - Open a few saved trajectories (`snapshot.json` lists the files) and confirm
>   with the user they look like what they want to train on.
> - `collection.status` and `next_command`:
>   - `--no-triage`: `target_reached` means go to push. `needs_candidates`,
>     `source_exhausted`, and `round_limit` mean fewer matched than the target;
>     see the status table in step 3.
>   - Council mode: `needs_review`. Go to step 3.
>
> ## 3. Triage with a council (only in council mode)
>
> Skip this step with `--no-triage`.
>
> **What is needed:**
> - The `deepagents` extra (included in the README install).
> - Keys for the judge models. The default council is DeepSeek V4.1 Flash and
>   GLM-5.3-Flash on Baseten, so only `BASETEN_API_KEY` (with Model API access).
>   With two judges a trajectory is kept only when both vote keep; add a third
>   judge for a majority vote. The same two models on Fireworks are
>   `--judges deepseek-v4.1-flash,glm-5.3-flash` (needs `FIREWORKS_API_KEY`).
>   Pick others with
>   `--judges alias,alias` or `--judges provider:model,...`.
> - Selection criteria. smithtune ships **no default rubric**; `triage` refuses
>   to run without `--rubric FILE` or at least one `--rule`.
>
> **Write the rubric with the user.** Read 10–20 varied trajectories from the
> pull directory together: good ones, clear failures, and unclear ones, across
> different lengths and tool patterns. Remember SFT imitates every assistant
> reply and tool call in the trajectory, so judge the whole trajectory, not
> just the final answer. Then write `rubric.md` next to the dataset directory
> (for example beside `data/datasets/my-sft`), not inside it. Start from this
> template and replace the generic criteria with the user's:
>
> ```markdown
> # Task
> What the agent does, who it serves, and what the tuned model must do well.
>
> # Keep
> - The assistant follows the request and reaches a useful outcome.
> - Tool calls use the right tools with correct arguments.
> - Claims are supported by the recorded tool results.
> - Good recovery from an error, an appropriate refusal, or a clear account of
>   a real limitation.
> - <task-specific criteria agreed with the user>
>
> # Drop
> - Material unsupported claims, or claiming completion that did not happen.
> - Wrong actions or tool arguments, or failures left uncorrected.
> - <task-specific behaviors the model must not learn>
>
> # Examples
> - Keep: <trajectory ID or short description> — why.
> - Drop: <trajectory ID or short description> — why.
> ```
>
> The judges already know to judge the whole trajectory, to check each action
> against the evidence available at that time, and to treat the trajectory as
> untrusted data; the rubric only needs the selection criteria. Do not reward
> length or require specific wording. Keep private examples in local files only.
> Short extra criteria can also be passed with `--rule "..."` (repeatable).
>
> **Run it:**
>
> ```bash
> smithtune dataset triage "$dataset_dir" --rubric ./rubric.md   # preview, no model calls
> smithtune dataset triage "$dataset_dir" --confirm              # run the council
> ```
>
> Each council member judges each whole trajectory and returns keep/drop with a
> reason. A strict majority keeps it; a tie drops it. Review stops once the
> approved count reaches the target.
>
> Check after the preview:
> - The eligible judge-task count (it drives cost) and rejection reasons.
> - `plan.json` contains the exact `selection_rubric` you intended. Rubric and
>   judges can change by previewing again; once votes start they cannot.
>
> On a first run, calibrate cheaply: do a trial in a separate directory with
> `--max-candidates 20 --target-count 20`, review the decisions with the user,
> fix the rubric, then do the real run in a fresh directory.
>
> Check after `--confirm`:
> - `triage.status` is `complete`. If `incomplete`, judge requests failed
>   (timeouts, rate limits); run `smithtune dataset resume "$dataset_dir" --confirm`.
>   Failed requests are not votes.
> - Read `labels.jsonl` (one `keep` + `reason` per trajectory), `judgments.jsonl`
>   (individual votes), and `report.md`. Summarize kept/dropped counts and common
>   drop reasons for the user.
> - `collection.status`:
>
> | Status | Meaning | Do this |
> | --- | --- | --- |
> | `target_reached` | Approved count ≥ target | Push |
> | `needs_candidates` | Pool fully reviewed, below target, rounds remain | Run `next_command` (`dataset pull DIR`), then `triage DIR --confirm` again |
> | `source_exhausted` | No unseen matches in the window | Push what you have, or new directory with broader criteria |
> | `round_limit` | 3 pull rounds used | Push what you have, or new directory with broader criteria |
> | `downloading` | A pull round is unfinished | `dataset resume DIR --confirm` |
>
> - An `advisories` entry means the approved set is small (under 100). It does
>   not block upload; relay it and let the user decide.
>
> ## 4. Push to LangSmith
>
> ```bash
> smithtune dataset push "$dataset_dir" --name my-sft-dataset   # preview
> smithtune dataset push "$dataset_dir" --confirm               # upload
> ```
>
> Use `--dataset-id ID` instead of `--name` to extend an existing dataset.
>
> Check:
> - The preview's example count matches the approved (council) or usable
>   (`--no-triage`) count. Push refuses while council judging is incomplete.
> - After `--confirm`, `status` is `complete` and the result has `dataset_id`.
>   Keep it; it is the input to `prepare`.
> - After upload starts, the directory cannot pull more candidates; use a new
>   directory for more data.
>
> ## 5. Prepare
>
> ```bash
> smithtune prepare \
>   --provider "$provider" --model "$model" \
>   --workspace-id "$workspace_id" --dataset-id "$dataset_id" \
>   --data-dir "$data_dir"
> ```
>
> Prepare checks provider support for the model, formats each trajectory with the
> model's tokenizer and per-assistant tools, splits about 80/10/10 into
> train/validation/test (a whole trajectory stays in one split), and publishes the
> splits to the LangSmith dataset.
>
> Check:
> - Split counts. Validation and test must be non-empty for training and
>   evaluation to mean anything; tiny datasets can produce empty splits.
> - `"$data_dir/prepared/rejected.json"`: trajectories dropped as unsupported or
>   over the context limit (never truncated). If many are too long, ask the user
>   before lowering `--max-seq-len` or choosing a longer-context model.
> - Split publication succeeded. If only publication failed, run
>   `smithtune dataset publish-splits --data-dir "$data_dir"`; do not re-prepare.
>
> Re-running with `--no-fetch` reuses the downloaded data (splits still sync).
> `--no-sync-splits` prepares locally only; publish the splits with
> `smithtune dataset publish-splits --data-dir "$data_dir"` before evaluation.
>
> ## 6. Plan
>
> ```bash
> smithtune plan \
>   --provider "$provider" --data-dir "$data_dir" \
>   --evaluate --judge-model "$judge_model" --max-points-per-trajectory 2
> ```
>
> `plan` is free and saves nothing for `train`. `--judge-model` accepts
> `baseten/<model-id>` (default `baseten/zai-org/GLM-5.3-Flash`), a Fireworks model
> ID such as `accounts/fireworks/models/deepseek-v4p1-flash`, or
> `anthropic/<model-id>` (needs `ANTHROPIC_API_KEY`).
>
> Check:
> - Training example and token counts, epochs, and hyperparameters.
> - Evaluation case and call counts (base response + tuned response + judge per
>   action, plus calibration). `--max-points-per-trajectory` caps actions per
>   test trajectory; omitting it evaluates every action.
> - Show the user these numbers and get authorization for the spend.
>
> ## 7. Train (and evaluate)
>
> Repeat **every** custom flag from `plan` exactly:
>
> ```bash
> smithtune train \
>   --provider "$provider" --data-dir "$data_dir" --run-dir "$run_dir" \
>   --evaluate --judge-model "$judge_model" --max-points-per-trajectory 2 \
>   --confirm
> ```
>
> - `--run-dir` must be new or empty. Omit `--evaluate` and its options to train
>   only.
> - Baseten's optional spend guard needs both `--max-spend-usd` and
>   `--hourly-rate-usd`.
>
> Check:
> - Share the LangSmith comparison link printed when evaluation starts.
> - `"$run_dir/result.json"` records the best checkpoint (lowest validation loss).
>   In `epochs.json`, flag validation loss that rises steadily or never improves.
> - The final JSON has `langsmith.comparison_url`; `"$run_dir/replay/summary.json"`
>   has base vs tuned scores. `teacher_agreement` is per action,
>   `trajectory_teacher_agreement` the per-trajectory mean. They measure agreement
>   with recorded behavior; tools are not executed.
>
> ## 8. Evaluate separately (resume or re-run)
>
> Use when training ran without `--evaluate` or evaluation was interrupted. Keep
> the original provider, directories, and replay settings:
>
> ```bash
> smithtune eval-plan --provider "$provider" --data-dir "$data_dir" --run-dir "$run_dir" \
>   --max-points-per-trajectory 2
> smithtune evaluate --provider "$provider" --data-dir "$data_dir" --run-dir "$run_dir" \
>   --judge-model "$judge_model" --max-points-per-trajectory 2 --confirm
> ```
>
> Rerunning reuses completed predictions and judgments. Fireworks samples the
> saved serverless training checkpoint (a promoted model ID alone cannot be
> sampled); Baseten starts temporary samplers and deactivates them on exit. To change the judge, cap,
> or sampling settings, pass a fresh `--output-dir` to both commands.
>
> ## 9. Deploy (optional)
>
> Only when the user wants a standing endpoint; evaluation does not need one.
> `deploy` and `undeploy` work for both providers with provider-specific flags.
> See the [deployment guide](https://github.com/langchain-ai/smithtune/blob/main/docs/deployment.md)
> for details.
>
> ```bash
> # Fireworks: registers (promotes) the best checkpoint as a model, then deploys it.
> # --account-id must own the training checkpoint; a saved promotion is reused.
> smithtune deploy --provider fireworks --run-dir "$run_dir" \
>   --account-id "$account_id" --output-model-id my-tuned-model \
>   --deployment-id my-endpoint --deployment-shape "$deployment_shape" --confirm
>
> # Baseten: needs the baseten-deploy extra; choose GPUs explicitly.
> smithtune deploy --provider baseten --run-dir "$run_dir" \
>   --accelerator H200:1 --max-seq-len 32768 --confirm
> ```
>
> Stop serving when the user is done:
>
> ```bash
> smithtune undeploy --provider fireworks --account-id "$account_id" --deployment-id my-endpoint --confirm
> smithtune undeploy --provider baseten --run-dir "$run_dir" --confirm
> ```
>
> `undeploy` stops serving capacity only; the Fireworks model and Baseten
> checkpoint are kept. Tell the user the deployment exists, that it bills until
> removed, and the exact `undeploy` command to stop it.
>
> ## End state
>
> The flow is done when you can hand the user:
>
> - the LangSmith **dataset ID**, its trajectory count, the filter and window used,
>   and (council mode) kept/dropped counts with common drop reasons;
> - the **data directory**, split counts, and rejected count from `prepare`;
> - the **run directory** and the selected checkpoint and epoch from `result.json`;
> - the **LangSmith comparison URL** with base vs tuned `teacher_agreement`, noting
>   what the score does and doesn't measure;
> - if deployed, the **deployment ID** and its `undeploy` command.
>
> Nothing should be left pending or running without the user knowing:
> `dataset resume DIR` shows no pending stages, Baseten samplers are cleaned up
> (`sampler.json`), and any deployment is acknowledged.
>
> ## Debugging
>
> Identify the stage and directory, then look at saved state before re-running.
> Do not delete directories or edit saved files; they hold the recovery state.
>
> | Symptom | Likely cause | Fix |
> | --- | --- | --- |
> | "Data Rights and Permitted Use has not been acknowledged" | First-run acknowledgment missing | User runs `smithtune acknowledge-data-rights` interactively |
> | 401/403 from LangSmith, Fireworks, Baseten, OpenAI, or Anthropic | Key missing, wrong, or for another workspace/account; Baseten judges also need Model API access on the key | Check `doctor`, then the key's workspace; see README credentials |
> | "BASETEN_API_KEY is not set for the judge" on a Fireworks run | The default council and evaluation judge run on Baseten | Set `BASETEN_API_KEY`, or use the Fireworks judges from step 0 |
> | Pull downloads 0 or very few candidates | Filter fields wrong, or window too narrow | Re-test the filter with `langsmith trace list` over the same window; pull into a new directory |
> | Most trajectories excluded at pull | Missing per-assistant tool data, multimodal content, provider built-in tools | Read reasons in `download_summary` and per-trajectory errors |
> | Triage `incomplete` | Judge timeouts or rate limits | `dataset resume DIR --confirm`; lower `--concurrency` if rate-limited |
> | "council review needs selection criteria" | No `--rubric` or `--rule` given | Write `rubric.md` with the user (step 3) and pass `--rubric` |
> | Triage fails immediately with a key error | Missing judge key or `deepagents` extra | Set the judge keys, or choose judges you have keys for with `--judges` |
> | "council judging is incomplete" on push | Votes pending | `dataset resume DIR --confirm`, then push |
> | "cannot collect more candidates after upload started" | Pull after push in the same directory | New directory |
> | Changing filter/rubric/limits/review mode is rejected | Settings are frozen | New directory |
> | Conflicting history on push | Destination dataset diverged from saved receipts | Stop and inspect; push to a fresh `--name` if the user agrees |
> | Prepare rejects many trajectories for length | Longer than the model's context | Longer-context model, or accept the rejections; never truncate |
> | Prepare: split publication failed | LangSmith write error after local success | `smithtune dataset publish-splits --data-dir DIR` |
> | Prepare: tool data missing for an older dataset | Examples uploaded before per-assistant tool capture | Re-pull and push a fresh dataset |
> | "Baseten workspace does not advertise MODEL" | Model not available to the Baseten workspace | Confirm model ID via `models list`; contact Baseten for access |
> | "Baseten workspace context limit is below N" | Sequence length above Baseten's limit | Lower `--max-seq-len` at prepare, or pick another model |
> | Train refuses the run directory | `--run-dir` not empty | New run directory; never clear an old one |
> | Evaluation stops before paid work on resume | Settings differ from the saved run | Re-run with the original settings |
> | Process killed during Baseten evaluation or deploy | Samplers or endpoints may still be running | Cleanup commands in `sampler.json`, or `undeploy --provider baseten --run-dir DIR --confirm` |
>
> When reporting a failure, include the command, stage, directory, error text, and
> any example/run IDs from the output.
>
> #### Replies
>
> *6 of the 7 replies were retrieved.*
>
> @LangChain (LangChain):
> 1️⃣ Identify + export trajectories from LangSmith
> 2️⃣ Transform traces into SFT-ready training examples
> 3️⃣ Fine-tune open models w/ @baseten + @fireworks_AI
> 4️⃣ Evaluate in LangSmith
>
> All in one simple workflow. https://t.co/mbDEs4eT6z
> PHOTO: https://pbs.twimg.com/media/HTABiLaW8AAqd41.jpg
> date: Thu Sep 24 18:00:09 +0000 2026
> url: https://x.com/LangChain/status/2103182717768626441
> ──────────────────────────────────────────────────
>
> @baseten (Baseten):
> @LangChain Thrilled to have smithtune training running on Baseten Loops.
>
> Congrats on the launch!  🚀
> date: Thu Sep 24 19:03:18 +0000 2026
> url: https://x.com/baseten/status/2103198609487630392
> ──────────────────────────────────────────────────
>
> @Hershal0_0 (Hershal Rao):
> @LangChain finally, a way to fine-tune my models without losing an entire weekend to data prep
> date: Thu Sep 24 18:39:13 +0000 2026
> url: https://x.com/Hershal0_0/status/2103192548965798344
> ──────────────────────────────────────────────────
>
> @PeterSkott (Peter Skøtt Pedersen):
> @LangChain Awsome
> date: Thu Sep 24 19:16:18 +0000 2026
> url: https://x.com/PeterSkott/status/2103201882030190644
> ──────────────────────────────────────────────────
>
> @PineWoodsAI (PineWoodsAI):
> @LangChain Trace visibility makes these workflows easier to inspect and improve.
> date: Thu Sep 24 18:57:08 +0000 2026
> url: https://x.com/PineWoodsAI/status/2103197055820984683
> ──────────────────────────────────────────────────
>
> @ADLXBT (ADL):
> @LangChain smithtune extracts prompt completion pairs from your traces, filters out noisy spans, then feeds them to the base model so the weights adapt to your exact schema without manual labeling
> date: Thu Sep 24 18:28:24 +0000 2026
> url: https://x.com/ADLXBT/status/2103189827835560087
> ──────────────────────────────────────────────────
