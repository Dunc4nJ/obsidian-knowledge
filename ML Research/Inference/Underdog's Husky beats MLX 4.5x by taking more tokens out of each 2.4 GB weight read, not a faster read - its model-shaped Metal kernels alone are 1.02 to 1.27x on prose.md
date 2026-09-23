---
created: 2026-09-23
source: https://husky.underdog.ai
via: https://x.com/0xsigil/status/2102165862065328538
author: Sigil Wen (Underdog)
published: 2026-09-20
cite: Wen, Sigil. "Husky - a model-specific inference engine up to 4.5x faster than Apple's MLX." Underdog, 20 September 2026. https://husky.underdog.ai
type: knowledge
tags: [inference, metal, mlx, megakernel, kernel-fusion, apple-silicon, local-inference, quantization, speculative-decoding, underdog, husky, woof]
description: Underdog's Husky engine claims up to 4.5x over Apple's MLX and 730 tok/s for a 4-bit 4B Woof on an M5 Max, but its own write-up concedes the 2.4 GB per-token weight read and the ~6 ms step are unchanged - the speedup is tokens kept per read (prompt lookup plus a trained draft), and model-shaped Metal kernels on their own are worth 1.02 to 1.27x on prose.
---

# Underdog's Husky beats MLX 4.5x by taking more tokens out of each 2.4 GB weight read, not a faster read

On 2026-09-21 Sigil Wen launched **Husky**, which he calls a **Model-Specific Inference (MSI) engine**, with the line "up to 4.5x faster than Apple's MLX" and "730 tokens/sec on a MacBook". The tweet attributes the win to "model-shaped Metal Megakernels" and says "the GPU never waits."

The tweet is the compressed version. The full technical write-up at **[husky.underdog.ai](https://husky.underdog.ai)** — published 2026-09-20, ungated, with a complete method section — says something materially different and more interesting, and it says it plainly:

> Producing a token means streaming all 2.4 GB of Woof from unified memory through the 40 GPU cores, about 6 ms on the M5 Max, and no engine reads faster than the bus. **What Husky changes is how many tokens come out of each read.**

That single sentence is the whole note. Husky did not make the step faster. It made the step produce more tokens. The headline multiple is speculative decoding, and the kernel work it is credited to is worth roughly 5 to 25 percent.

## Key takeaways

- **The 4.5x and the ~6 ms step are not in conflict once you see that Husky emits several tokens per weight read.** MLX keeps 1.0 tokens per read of the weights; Husky keeps 5.4 on edits and 2.7 on prose with the Flash draft on. At 6.1 ms per step that is 164 tok/s single-token and 730 tok/s at 4.5 accepted tokens — the arithmetic closes exactly. The catch is that `mlx-lm` ships speculative decoding too, through `--draft-model`, and the Method section never says whether the baseline was allowed one, so the headline multiple compares a drafted engine to an apparently undrafted one. This is the thesis of [[Modal argues speculative decoding is the only inference optimization that matters, and custom DFlash speculators turn acceptance length into 2-3x speedups]] restated on Apple silicon, and the roofline it obeys is [[Step 01 - Decode is memory-bandwidth-bound (the roofline)]].
- **Strip the speculation and the megakernel story is a rounding error.** Husky's own Table 1 puts the engine alone at **1.02x to 1.27x over MLX on prose** (call summary 1.02x, tone rewrite 1.04x, question over a document 1.21x, invoice to JSON 1.27x). The 3.8x on a function edit is prompt lookup, not kernel fusion: "most of the file is already there." A tell anyone can check from the chart alone — MLX's bar is flat across all sixteen tasks (151 to 164 tok/s, a 9 percent spread) while Husky's spans 164 to 614, a 3.7x spread. Kernel fusion cannot be task-dependent; the same 2.4 GB is read whatever you ask. Whatever varies by task is a guesser, not a kernel.
- **The write-up contains an honest negative result that the tweet inverts.** Husky ships *specialized* kernels, not a whole-step megakernel. The team built the first piece — a layer's whole MLP as one persistent dispatch with a grid barrier — and reports: "identical output, and **no faster**." Their explanation is that back-to-back dispatches in one Metal encoder already run with almost no gap, so a megakernel only pays when it overlaps the next stage's weight loads with the current stage's tail. The tweet's "we wrote model-shaped Metal Megakernels / the GPU never waits" describes the aspiration; the paper describes a measured null. Compare the same discipline in [[agentic kernel development ships to production by profiling the whole model first - 42.3 percent latency cut on Qwen-Image]], where microbenchmark wins evaporate on integration.
- **Woof is public, contradicting most of the reply thread.** `ConwayResearch/Underdog-Woof-4B-1.1` sits on Hugging Face under Apache-2.0, ungated, 815 downloads; the Husky-packed build with the draft is `ConwayResearch/husky-flash`. It is a **Qwen3.5 4B** at 4 bits, group size 64, hidden 2560, 32 layers split **24 linear-attention and 8 full-attention** on a 3:1 interval. The "24 recurrence layers" of the tweet's slide are exactly those 24 linear-attention layers — Woof is a hybrid recurrent/attention model, not a plain transformer.
- **The real engineering win is latency, not throughput, and it is the one nobody is discussing.** Time to first word on a continued chat goes from MLX's 137 to 177 ms down to 29 to 39 ms, a 3.6x to 5.5x cut, from a resident prefix cache plus removing the fixed per-call cost. That is the same shape as [[Perplexity serves embeddings by treating them as a CPU-overhead problem - whole-model CUDA graphs and LazyTensors cut p50 from 4.60ms to 1.53ms while throughput stays at parity with vLLM]]: killing host overhead buys latency, and throughput stays near parity.

## The claims, as made

| Claim | Where | Status after checking |
| --- | --- | --- |
| "up to 4.5x faster than Apple's MLX" | tweet | True as stated, but it is Flash-on vs MLX on one task (function edit, 730 vs 163). Engine alone on that task is 3.77x, and on prose 1.02 to 1.27x. |
| "730 tokens/sec on a MacBook" | tweet | Real, on an **M5 Max MacBook Pro** (40-core GPU, 128 GB, macOS 26.5.1), greedy, with Flash on, on a function edit. The video's live race names the machine and independently shows 150 tok/s for MLX against 537 for Flash-on on the typo-fix prompt, matching the table's 159 and 535. |
| "Model-Specific Inference (MSI) engine" | tweet | A new name. The idea — compile kernels against one model's known shapes — is model-shaped AOT compilation, long-standing. |
| "Woof, Underdog's Pareto frontier model" | tweet | A 4-bit Qwen3.5 4B. `ConwayResearch/Underdog-Woof-4B-1.1`. |
| "<4 GB on your computer" | underdog.ai homepage | `model.safetensors` is 2.367 GB. Checks out. |
| 2.4 GB read per token | slide / write-up | Verified from the `husky-flash` manifest: head 357.6 MB + 32 layers (24 x 63.9 MB + 8 x 60.5 MB = 2,017.9 MB) = **2,375.5 MB**. The embedding table is excluded, correctly, since decode reads one row. |
| ~6 ms per decode step | slide / write-up | 6.3 ms MLX, 6.1 ms Husky. A plain streaming read of 2.4 GB is ~4.5 ms, so both engines sit near but not at the bus. |
| 270 dispatches became 206 | slide only | **Not in the write-up.** A 24 percent cut, and the write-up's own measurement says removing dispatch gaps bought ~5 percent on long prose. |
| 24 recurrence layers on one resident grid | slide / write-up | Confirmed by the model config: 24 `linear_attention` layers, `full_attention_interval: 4`. |

## The mechanism

### The slide in the self-reply, transcribed

Titled **"Model-shaped Metal megakernels."**, subtitle **"Metal · one decode layer"**. Body: "Each projection has its own kernel for its exact matrix, with the norm folded in, gate and up walked together, and the 4-bit weights unpacked straight into the multiply. Fewer dispatches, no host between them."

Top row, "A general engine, one layer: a dispatch per operation and the host between them" — `norm | q | k | v | attention | norm | gate | up | down`, red dashed gaps between every box, "x 32 layers".

Bottom row, "Husky: the norm folded into each projection, gate and up in one walk, back to back on the GPU" — `norm + q k v | attention | norm + gate · up | down`, "x 32, next step already queued".

Red caption: "red dashes: the host encoding the next dispatch. Husky has none between kernels, and the next token's whole step is already submitted."

Then: "Same GPU, same 2.4 GB read per token. The step is about 6 ms either way; what changed is what comes out of it." And in bold: **"270 dispatches a step became 206,** the 24 recurrence layers run on one resident grid, and the next step is submitted while this one runs."

Nine boxes to four per layer is 5 saved x 32 layers = 160 dispatches, but the slide says 64 (270 to 206), so the 270 evidently counts more than the projection chain.

### Mapped to standard vocabulary

| Husky's phrasing | Standard term |
| --- | --- |
| "the norm folded into each projection" | RMSNorm/matmul **kernel fusion** — the epilogue-into-prologue trick from [[Ahmad Osman's kernel curriculum - you don't run a model you run kernels, and here are eight mini-projects from RMSNorm in Triton to a custom op profiled inside vLLM]] |
| "gate and up walked together" | fusing the two SwiGLU projections into one weight walk |
| "4-bit weights unpacked straight into the multiply" | **dequant-in-matmul** — never materialise the dequantised tensor |
| "each matrix gets one kernel" for its exact size | **shape-specialised AOT kernel compilation**, no runtime shape dispatch |
| "the 24 recurrence layers run on one resident grid ... hand off through device-side counters" | a **persistent kernel** with device-side synchronisation, bypassing the command stream |
| "the next step is submitted while this one runs" | **CPU/GPU pipelining**, command-buffer batching — the Metal analogue of CUDA graphs |
| "verifies eight tokens per step at 1.5x the cost of one" | **speculative decoding** with a verify block of 8 |
| "the guesses come from your own prompt" | **prompt lookup / n-gram speculative decoding** |
| Flash | a **trained draft head** reading hidden states from 5 layers, proposing 7 tokens |

So: the slide is a correct and even elegant description of real kernel work. It is just not what produced the headline number, and the write-up says so.

### Where the speed actually comes from

Husky's own decomposition, in its own words:

1. **Prose / writing: pipelining, worth ~5 percent.** "Every step used to cost almost half a millisecond of encoding and waiting between GPU commands; Husky now encodes the next step while the current one runs... That is the 5% on the transcript."
2. **Edits: prompt lookup, worth 1.8x to 3.9x.** "When the last few tokens Husky wrote also appear in the prompt, it proposes the seven that followed there, and Woof keeps the ones it agrees with, typically five or six."
3. **Everything else: the Flash draft, worth 1.1x to 3.2x on top.** A single small layer reading Woof's hidden states from five layers, proposing seven tokens, self-distilled on Woof's replies to 139,000 conversations, about two hours on one B200. It lands ~2 tokens/step on prose, 4 to 5 on code and structured output. 273 MB.
4. **First token: a resident prefix cache, worth 3.6x to 5.5x.**

The routing between 2 and 3 is adaptive: "If the last few tokens appear earlier in the prompt, lookup proposes, since it is better at copying. Otherwise the draft runs while its guesses land at least half a token a step, and rests on the one-row path when they stop." The acceptance-length lever is exactly the one formalised in [[Step 04 - Draft models and the acceptance-rate lever (α = distributional overlap)]], and 7 tokens is an aggressive draft length that only pays because the block verify costs 1.5x one row rather than 8x.

One genuine kernel result *does* feed the speculation, and it is the most transferable thing in the write-up: the eight-row verify step originally cost 2.3x a one-row step "because the kernels walked a 12,800-wide input as one serial chain of matrix ops per simdgroup; splitting that input across the eight simdgroups brought the step to 1.5x". That single change moved two benchmark rows from 403 to 487 and from 483 to 611 tok/s. Kernel work here is not what beats MLX — it is what makes speculation cheap enough to be worth doing. That is a better story than the one the tweet told.

### Table 1, all sixteen prompts

The page's own results table, reproduced in full. Medians of three runs per engine, greedy, each in its own quiet window with a canary check first and repeats agreeing within 12 percent. The "Faster" columns are against MLX. First-token times are for a conversation re-sent with one more message, both engines continuing from their caches.

| Prompt | MLX tok/s | Husky tok/s | Faster | Flash on | Faster | MLX first | Husky first | Sooner |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| Function edit, 368 tokens in | 163 | 614 | 3.77x | 730 | 4.48x | 177 ms | 32 ms | 5.5x |
| Add a field to a JSON file, 477 tokens in | 157 | 611 | 3.89x | 672 | 4.28x | 145 ms | 30 ms | 4.8x |
| Rename a SQL column, 240 tokens in | 158 | 487 | 3.08x | 547 | 3.46x | 143 ms | 33 ms | 4.3x |
| Write a function, 40 tokens in | 155 | 170 | 1.10x | 545 | 3.52x | 145 ms | 29 ms | 5.0x |
| Fix typos in a paragraph, 301 tokens in | 159 | 463 | 2.91x | 535 | 3.36x | 141 ms | 31 ms | 4.5x |
| Invoice to JSON, 321 tokens in | 164 | 208 | 1.27x | 496 | 3.02x | 144 ms | 30 ms | 4.8x |
| CSV to a table, 303 tokens in | 158 | 287 | 1.82x | 462 | 2.92x | 141 ms | 34 ms | 4.1x |
| Data to a table, 247 tokens in | 163 | 188 | 1.15x | 282 | 1.73x | 150 ms | 31 ms | 4.8x |
| Repeated transcript, 857 tokens in | 153 | 164 | 1.07x | 273 | 1.78x | 140 ms | 39 ms | 3.6x |
| Tone rewrite, 195 tokens in | 162 | 168 | 1.04x | 269 | 1.66x | 138 ms | 34 ms | 4.1x |
| Short email, 38 tokens in | 151 | 164 | 1.09x | 260 | 1.72x | 148 ms | 38 ms | 3.9x |
| Project plan, 51 tokens in | 158 | 171 | 1.08x | 246 | 1.56x | 139 ms | 37 ms | 3.8x |
| Meeting notes to to-dos, 249 tokens in | 163 | 175 | 1.07x | 234 | 1.44x | 148 ms | 36 ms | 4.1x |
| Reply to an email thread, 280 tokens in | 163 | 170 | 1.04x | 217 | 1.33x | 139 ms | 36 ms | 3.9x |
| Call summary, 657 tokens in | 162 | 166 | 1.02x | 211 | 1.30x | 151 ms | 34 ms | 4.4x |
| Question over a document, 297 tokens in | 159 | 193 | 1.21x | 210 | 1.32x | 137 ms | 34 ms | 4.0x |

Read the MLX column downward: 151 to 164 across every task, a 9 percent spread on inputs ranging from 38 to 857 tokens. That flatness is the signature of one-token-per-read decode pinned to the bus. Then read the Husky column: 164 to 614, a 3.7x spread on the same weights and the same machine. Nothing about kernel fusion can vary by prompt. The spread is the guesser.

### Is the comparison fair

Mostly yes, with one asymmetry that matters for the headline.

The baseline is named and current. The Method section gives **mlx-lm 0.31.3 on MLX 0.32.2**, and both are the latest releases on PyPI as of this capture, mlx-lm 0.31.3 dating to 2026-04-22. This is not a stale build chosen to flatter, which is a real point in the page's favour and worth saying plainly.

The **Husky column is a fair engine-versus-engine comparison**: same file, same greedy output, verified token by token, both engines continuing from their own caches. The 1.02x to 3.9x there is credible.

The **Flash-on column is not like-for-like**. `mlx-lm` ships its own speculative decoding through `--draft-model` and `--num-draft-tokens`, and the Method section never says whether the MLX column was run with a draft. On the evidence, it was not. So the 1.3x to 4.5x compares a drafted engine against an undrafted one, which is a comparison of configurations rather than of engines. The fair version of that test is Husky with Flash against `mlx-lm` with a draft model, and it has not been published. This does not make the 730 tok/s wrong, and a user of the Underdog app genuinely gets it. It does mean the headline multiple is not a measure of how much better Husky's Metal work is than Apple's.

### Bandwidth check against the vault's own numbers

The vault puts the **M5 Max 40-core at 614 GB/s** ([[matmuls are parallel memory reads - Roy's bandwidth ladder puts a 1K RTX 3090 at 936 GB-s above a 5K Mac or DGX Spark, but it has no capacity or prefill column]], [[buy the RAM that holds the model - a SKU-by-SKU M5 Mac guide with the CUDA tax and separate decode-prefill predictions]]), and measures dense models on that part at 74 to 85 percent of spec.

| Quantity | Value |
| --- | --- |
| Weights read per decode step | 2.375 GB (manifest-verified) |
| Single-token ceiling at 614 GB/s | **256 tok/s** |
| Single-token ceiling at the vault's 74-85% dense band (455-522 GB/s) | **192-220 tok/s** |
| Husky's own plain-streaming-read floor (4.5 ms) | 533 GB/s = 87% of spec, **222 tok/s** |
| MLX measured, 6.3 ms/step | 381 GB/s = 62% of spec, 159 tok/s |
| Husky measured, 6.1 ms/step | 393 GB/s = 64% of spec, 164 tok/s |
| Husky + Flash headline | **730 tok/s = 2.85x the 614 GB/s ceiling** |

Two conclusions fall out. First, **730 tok/s is flatly impossible for one-token-per-read decode on this part** — it is 2.85x the hard bandwidth ceiling — so the number is only coherent as multi-token-per-read, which is what it is. Second, both engines are leaving 20 to 25 points of bandwidth utilisation on the table relative to the vault's 74-85 percent dense band, so the "MLX is slow on Metal" premise behind the whole project is real: this is the same ~40 percent MLX versus ~80 percent CUDA gap recorded in [[GLM-5.3-Flash FP8 really is 306GB and really fits in 512GB - but 60 t-s is 80-90 percent of the roofline on a machine that does not ship until October]]. Husky closed a small slice of it and then went around it.

## What is missing, and what is not

The tweet is thin, but the write-up answers nearly every fair objection raised in the replies. Setting the record straight:

**Supplied, contrary to the thread.** The exact chip (Apple M5 Max, 40-core GPU, 128 GB, macOS 26.5.1); the MLX baseline (mlx-lm 0.31.3 on MLX 0.32.2); the quantisation (4-bit, group 64, affine, the same file for both engines, repacked without changing a value); decoding (greedy, compared token by token against MLX after every change); the protocol (medians of three, per-prompt quiet windows, a canary run first, alternated order, repeats agreeing within 12 percent, disagreeing runs discarded); and the model, openly on Hugging Face.

**Genuinely missing.**

- **One machine, one chip.** Every number is a single M5 Max. @ddalcu's demand for M1 through M4 figures is unanswered, and @corysus asks the sharp version: is Husky M5-only? Kernels written for one part's simdgroup width and cache hierarchy do not automatically carry.
- **Batch size is never stated.** Everything reads as batch 1, which is the honest regime for a local assistant but should be said.
- **Whether the MLX baseline was allowed a draft model.** `mlx-lm` 0.31.3, the latest PyPI release at capture, ships its own speculative decoding through `--draft-model` and `--num-draft-tokens`, and the Method section does not say whether the MLX column used one. The Husky-alone column at 1.02x to 3.9x is the fair engine-versus-engine comparison on identical greedy output; the 1.3x to 4.5x headline is not, as far as the page shows. Worked through above.
- **iPhone is claimed but never measured.** Both the opening slide and the MSI slide say "Built to run on your Mac and iPhone, even without wifi", and the underdog.ai FAQ says iPhone builds are "coming". Every number in the write-up is a Mac. The tweet does not mention iPhone at all, so the slides claim more than the post does.
- **No quality or acceptance-rate table.** "Same weights, same answers" is asserted for greedy decoding and is architecturally plausible with rejection sampling, but there is no held-out benchmark for Woof and no α figure, only accepted-token counts.
- **The engine is closed.** The weights are Apache-2.0; Husky itself is not published. A "Greyhound repository" and `husky serve` are referenced in the model card with no public link, and there is no GitHub organisation — searches for `husky metal megakernel` and `underdog.ai` return nothing relevant, and `underdogdotai` is not a GitHub org.
- **The 270-to-206 dispatch figure has no counterpart in the write-up** and no methodology behind it.
- **The slide's matrix dimensions do not match the published model.** The video slide shows `q 2560 x 4096`, `k v 2560 x 512`, `gate·up 2560 x 12800`, `down 12800 x 2560`. The config gives hidden 2560 and 16 heads x 256 head_dim = 4096, so `q` matches exactly — but `intermediate_size` is **9216**, not 12800. The 12,800 figure recurs in the prose ("walked a 12,800-wide input"), so it is probably the fused gate+up stride of an earlier Woof; either way the illustrated model is not `Woof-4B-1.1`.
- **English only.** @VrianCao and @HaHoang411 ask about Chinese and multilingual; the model card says `language: en`. Unanswered. (The sibling ASR model, `Underdog-Bark-0.8B-1.0`, lists 30 languages — the LLM does not.)
- **Prefill is under-sold rather than missing.** @indesjyo asks for prefill rather than decode, and Figure 4 half-answers: on a long prompt of 857 to 890 tokens, prefill goes 3,094 to 5,151 tokens a second, a 1.67x. But on a short prompt of 40 to 70 tokens it goes 259 to 1,355, a **5.2x**, the largest single multiple anywhere in the write-up and one the tweet never mentions. Short-prompt prefill is dominated by fixed per-call cost, which is exactly what Husky removes, so this is the cleanest demonstration of the engine's real strength and it is buried in the fourth figure.

## Is MSI a new idea

No, and the write-up is careful enough not to claim otherwise — it only claims the name. "An engine that knows one model's every shape at compile time and spends none of its time being general" is model-shaped ahead-of-time compilation, which is what TensorRT-LLM engine builds, `torch.compile` with static shapes, and XLA/IREE ahead-of-time lowering have all done for years. What is new here is the *target*: a full shape-specialised Metal stack for one 4B model on consumer Apple silicon, shipped in a consumer app, where the prior art is thin because nobody had the incentive. [[Chris Leary frames AI-written kernels as compilers 2.0 - the LLM is a stochastic optimizer in STOKE's seat, and semantic-equivalence checking is what makes not reading the kernel safe]] is the argument for why this specialisation is about to get cheap to produce; Husky is a hand-written instance of it. For the underlying vocabulary see [[Modal's GPU Glossary is a browsable reference that maps the GPU stack from device hardware through the CUDA software layers to performance concepts in ~80 linked terms]], and for the shape-choice side of the same coin, [[NVIDIA's hardware-friendly LLM design guide - near-square tile-aligned dimensions, width over depth, NVFP4, and wide expert parallelism]].

The declared next step is "CUDA megakernels ... for our upcoming launches with NVIDIA and Microsoft", which is a notable disclosure buried in a What's Next list.

## Replies

180 reply blocks retrieved against 200 stated. Exactly one is by the author — the self-reply carrying the megakernel slide.

The distribution is the story: **roughly 120 of the 179 third-party replies are invite requests or one-line praise.** The substantive minority:

- **Hardware questions, the single largest real category (~20 replies).** M4 Max 128 GB (@ssandeshwar), M3 Ultra (@notdevin), M4 Pro 48 GB (@sjoerdhui), M4 32 GB (@shanelogsdon), M1 Max (@cody_bunch), M1 Pro (@horwath_ryan, @sanderjson), M2 Pro (@sugardruid), M5 Max 128 GB (@KurtFehlhauer, @shirodkartejas), 8 GB M2 Air (@meaningmean_). None answered in-thread. @corysus asks it properly: "are M1, M2, M3, M4 supported, or is this like the recently released engine that mainly supports M5?"
- **The sharpest skeptic, @ddalcu:** "Interesting article, but very sensationalist. 4B Model ? My grandma can do 700 tok/s. Common, put a real model on there, and give us M1,M2,M3,M4 numbers not only M5Max. Also... open source, it's the only way, very few people will trust it otherwise." Half right. The 4B and M5-Max-only points stand. The "my grandma can do 700 tok/s" jab does not: the bandwidth ceiling above puts single-token decode for this model at 256 tok/s on this part, so 700 is not casually reachable. And the open-source complaint is aimed at the wrong artefact — the weights are Apache-2.0.
- **@ptbthefirst:** "730 tokens per sec on a macbook sounds inflated until they show the exact chip and quant used." They did, on the write-up page the tweet did not link.
- **Open-source pressure, ~6 replies:** @eldersavant "You're not on huggingface?", @zorrobyte "Where's the GitHub?", @kcwolfy_ "No one cares if it's not open source. Sorry.", @MgkMshrmBrkfst, @valkyr11393, @HaHoang411 ("opensourcing this would create a huge bomb"). The Hugging Face premise is simply wrong; the GitHub one is correct.
- **@liminalsunset_** supplies the missing fact the thread needed, tersely: "4B params, 4-bit, to save the reading."
- **@tensorquay** asks the best engineering question in the thread and gets no answer: "Can a Woof fine-tune reuse Husky's kernels if tensor shapes and the 4-bit layout stay the same? That would make local apps easier to maintain: ship new weights without retuning the engine each time." Given that specialisation is keyed to shapes and tile order, the answer is almost certainly yes — which would make MSI far more practical than "one engine per model" sounds, and is the thing worth confirming.
- **@YiCasillas** makes the strongest pro-argument in the thread, in Chinese: "730 tokens/s 这种数字很抓眼，但更有意思的是你们没有把'通用性'当成免费的：知道模型形状后把多步合成一个 kernel，少掉 CPU/GPU 间的来回，才是真正把延迟压下去。" Translated: *"A number like 730 tokens/s is eye-catching, but what is more interesting is that you did not treat generality as free: knowing the model's shape and then fusing multiple steps into one kernel, cutting out the CPU-GPU round trips, is what actually brings the latency down."* The instinct is right about where the engineering is, and the write-up's own numbers say it pays in time-to-first-word rather than in throughput.
- **@JoshConstine:** "Unclear how you are both shipping a consumer agent at lightspeed but also have time to just... fundamentally speed up inference."
- **@indesjyo:** "你如果能讓Prefill x10倍 而不是decode" — make prefill 10x instead of decode.
- **@rsms**, on the product rather than the engine: "I struggle to understand what underdog is. Tried making sense of the website on my iPhone but scrolljacking makes is hard to focus. Is it a Mac app? A website? A service?"
- **@mattwiebe** on the go-to-market: "This looks great but I can't try it with this invite gate and I ain't posting begging tweets" — a fair read of a thread that is majority invite-begging.

**No reply supplies the parameter count with a source, the base model, the exact SKU, or the MLX baseline.** Every one of those came from the write-up and the model config, not the thread.

## Related notes

- [[moc - Inference]] — the folder map.
- [[Step 01 - Decode is memory-bandwidth-bound (the roofline)]] — the physics Husky's own write-up restates verbatim.
- [[Modal argues speculative decoding is the only inference optimization that matters, and custom DFlash speculators turn acceptance length into 2-3x speedups]] — the prior that predicted this result.
- [[Step 04 - Draft models and the acceptance-rate lever (α = distributional overlap)]] — why a 7-token draft needs a cheap verify to pay.
- [[Rachel Rapp explains how Baseten trains speculative-decoding draft models live from inference hidden states, raising accept rates 20%+ with no offline data storage]] — the closest match to Flash's design anywhere in the vault. Flash is a single layer reading Woof's hidden states from five layers, self-distilled on the target's own replies; Baseten trains the same shape of draft from inference hidden states. Read together they say draft-from-hidden-states is converging on a standard recipe.
- [[From GPT-2 to Kimi K3 - a visual worklog on how attention architecture evolved to fix the KV cache with linear attention, DeltaNet, gating, and hybrid retrieval]] — the family Woof belongs to. Its 24 linear-attention layers interleaved 3:1 with 8 full-attention layers are exactly the hybrid this note traces, and the resident-grid trick only works because recurrence carries state instead of a growing cache.
- [[DSpark (DeepSeek paper) couples a semi-autoregressive drafter with a hardware-aware confidence scheduler to raise accepted length 16-31% offline and shift DeepSeek-V4's serving Pareto frontier]] and [[Hao AI Lab argues DSpark and JetSpec split the speculative-decoding throughput-latency frontier by adding causality to cheap parallel drafting]] — the datacentre versions of the same lever, where Husky's adaptive lookup-versus-draft routing has a formal analogue in confidence scheduling.
- [[SpecSpec specializes block-diffusion drafters with LoRA to speed speculative decoding on out-of-distribution languages]] — the distribution-shift risk for a draft self-distilled on 139,000 of one app's own conversations, and a reason the English-only limit may bite harder than it looks.
- [[Ashutosh Maheshwari's sub-second LLM study list catalogs sixteen inference optimizations from KV-caching and speculative decoding to tensor parallelism and memory offloading]] — Husky is a stack of four items from this list.
- [[Ahmad Osman's kernel curriculum - you don't run a model you run kernels, and here are eight mini-projects from RMSNorm in Triton to a custom op profiled inside vLLM]] — the fusion vocabulary, and the "47 tiny launches" complaint Husky is answering.
- [[CUDA game kernels beat JAX RL environments 7x because PyTorch dispatch overhead dominates tiny networks not simulation]] — the case where dispatch removal *was* the whole speedup, and why it is not here.
- [[Perplexity serves embeddings by treating them as a CPU-overhead problem - whole-model CUDA graphs and LazyTensors cut p50 from 4.60ms to 1.53ms while throughput stays at parity with vLLM]] — same trade: host overhead removal buys latency, not throughput.
- [[agentic kernel development ships to production by profiling the whole model first - 42.3 percent latency cut on Qwen-Image]] — kernel wins that vanish on integration, which is what Husky's null megakernel result is.
- [[Chris Leary frames AI-written kernels as compilers 2.0 - the LLM is a stochastic optimizer in STOKE's seat, and semantic-equivalence checking is what makes not reading the kernel safe]] — why per-model kernel specialisation is about to get cheap.
- [[matmuls are parallel memory reads - Roy's bandwidth ladder puts a 1K RTX 3090 at 936 GB-s above a 5K Mac or DGX Spark, but it has no capacity or prefill column]] — the 614 GB/s figure and the utilisation band used above.
- [[buy the RAM that holds the model - a SKU-by-SKU M5 Mac guide with the CUDA tax and separate decode-prefill predictions]] — the "CUDA tax" this project exists to repay.
- [[GLM-5.3-Flash FP8 really is 306GB and really fits in 512GB - but 60 t-s is 80-90 percent of the roofline on a machine that does not ship until October]] — the MLX-vs-CUDA utilisation gap, and the template for checking a Mac tok/s claim.
- [[know the difference between the harness, the model, and serving inference - Roy's longpost on why Qwen 27B flies on a 5090 in pi but feels awful in OpenCode on a MacBook or DGX]] — Husky is the serving layer of that split, and its TTFT win is a harness win.
- [[the anti-Mac guy calls the M5 Ultra an insane deal - 5x the bandwidth and 2x the RAM of a DGX Spark for 2x the price, as an agent host not a fast decoder]], [[at 15-20K with 512GB the real gap is bandwidth not compute - Mac Studio M5 Ultra vs 4x DGX Spark vs 4x Ryzen AI Halo]], [[buy 2x 256GB Mac Studios instead of one 512GB - two boxes give 2x 1.2 TB-s parallel instances and can still be linked, but a 512GB box can never be split]] — the Apple hardware context.
- [[Modal's GPU Glossary is a browsable reference that maps the GPU stack from device hardware through the CUDA software layers to performance concepts in ~80 linked terms]], [[NVIDIA's hardware-friendly LLM design guide - near-square tile-aligned dimensions, width over depth, NVFP4, and wide expert parallelism]] — reference for the kernel and shape vocabulary.

## Links

- [Husky: a model-specific inference engine up to 4.5x faster than Apple's MLX](https://husky.underdog.ai) — the full technical write-up, 2026-09-20. Ungated, and the only place the method appears.
- [The launch tweet](https://x.com/0xsigil/status/2102165862065328538) and [the self-reply with the megakernel slide](https://x.com/0xSigil/status/2102165863956910339).
- [ConwayResearch/husky-flash](https://huggingface.co/ConwayResearch/husky-flash) — Woof repacked in Husky's tile order plus the 273 MB Flash draft, with a benchmark table in the card.
- [ConwayResearch/Underdog-Woof-4B-1.1](https://huggingface.co/ConwayResearch/Underdog-Woof-4B-1.1) — the model, Apache-2.0, 4-bit MLX, 2.367 GB. Also [woof-1.0-4B](https://huggingface.co/ConwayResearch/woof-1.0-4B) (the Husky-flash base), [Underdog-Woof-2B-1.1](https://huggingface.co/ConwayResearch/Underdog-Woof-2B-1.1) (a Llama 2B), [Underdog-Bark-0.8B-1.0](https://huggingface.co/ConwayResearch/Underdog-Bark-0.8B-1.0) (Qwen3 ASR, 30 languages) and [pii-30M-mlx-4bit-v1.0](https://huggingface.co/ConwayResearch/pii-30M-mlx-4bit-v1.0) (a BERT redaction model).
- [underdog.ai](https://underdog.ai) — the product. Invite-only beta; `/husky`, `/woof`, `/blog/husky` and `/research` all return the invite gate.
- Cite as: Wen, Sigil. "Husky: a model-specific inference engine up to 4.5x faster than Apple's MLX." Underdog, 20 September 2026.

## Original Content

> [!quote]- Source Material - the launch post, the video, the self-reply slide, the full husky.underdog.ai write-up, the husky-flash model card, the underdog.ai homepage, and all 180 replies
>
> ### 1. The launch post
>
> **[@0xSigil (Sigil Wen)](https://x.com/0xsigil/status/2102165862065328538)** - 2026-09-21 22:39 UTC
> Bio: thiel fellow | creator of @underdogdotai | chairman @extraordinary | ai research @ConwayResearch | angel investor
> 2,061 likes · 179 reposts · 200 replies · 2,445 bookmarks · 37 quotes · 277,686 views (at fetch)
>
> > Meet Husky: a Model-Specific Inference (MSI) engine up to 4.5× faster than Apple's MLX
> >
> > Woof, Underdog's Pareto frontier model, now runs up to 730 tokens/sec on a MacBook
> >
> > Finally local models are as fast & capable. Try it now in https://underdog.ai - your personal private AI
>
> ### 2. The attached video
>
> 19.3 s, 1920x1080, no speech (silent demo over music - faster-whisper with VAD kept 0 segments).
> mp4: `https://video.twimg.com/amplify_video/2102165493725683712/vid/avc1/1920x1080/IbHbNKFjcsVl8BWk.mp4?tag=29`
>
> *Frame 1 (~0.6 s). The opening slide, and the clearest statement of the mechanism in the whole launch. Right rule "M5 Max · one decode step, on an edit". Title: "**Husky** - a model-specific inference engine up to 4.5× faster than Apple's MLX". Standfirst: "On a MacBook, Woof runs up to 730 tokens a second with Husky Flash on, and answers 5× sooner with the same weights. Built to run on your Mac and iPhone, even without wifi." Two panels of the same die. **MLX**, cornered "one read, one row": "CPU, the host" marked in red "waiting on the host"; "GPU, 40 cores" all empty; "bus, ~400 GB/s" carrying "1 row"; "Unified memory" holding "Woof, 2.4 GB" and "prompt, reread each turn"; footer "tokens out - **2 tokens so far** - 2 reads of 2.4 GB, 1 per read · a host gap between reads". **Husky**, cornered "one read, eight rows checked": "CPU, the host - next read already queued"; "GPU, 40 cores" fully coloured; "bus, ~400 GB/s" carrying "8 rows"; "Unified memory" holding "Woof, 2.4 GB" and "conversation state, kept"; footer "tokens out - **5 tokens so far** - 1 read of 2.4 GB, 5 per read · **an eight-row read costs 1.5× a one-row read**". The stated ~400 GB/s matches the 393 GB/s implied by 2.4 GB at 6.1 ms.*
> ![[sigil-husky-001.png]]
>
> *Frame 2 (~1.9 s). Slide headed "Husky by Underdog", right rule "MSI · model-specific inference". Title: "Inference engines are general: one runtime, many models. Husky runs one." Subtitle: "Woof, Underdog's Pareto-frontier model, is compiled in: every matrix shape, every kernel, the order of every byte on disk, decided before it runs. On your Mac and iPhone, even without wifi." Left panel "A general engine" / "one kernel for any shape" / "checks sizes at run time, converts at load". Right panel "Husky" with four rainbow-bordered matrices at named shapes: q · 2560 x 4096, k v · 2560 x 512, down · 12800 x 2560, gate · up · 2560 x 12800, beside a tall block labelled "Woof, 32 layers". Legend: "kernel compiled for that matrix" and "weights, in tile order".*
> ![[sigil-husky-002.png]]
>
> *Frame 3 (~6.8 s). The same slide as the self-reply photo, rendered in the video. Right rule "Metal · one decode layer". Title "Model-shaped Metal megakernels." Full text transcribed in section 3 below.*
> ![[sigil-husky-003.png]]
>
> *Frame 4 (~11.6 s). The benchmark chart. Right rule "Decode · tokens a second, M5 Max". Title: "Up to 730 tokens a second. Faster than MLX on all sixteen tasks, 1.3 to 4.5× with Flash on." Subtitle: "Flash is a small draft trained on Woof itself. It guesses the next seven tokens and Woof checks them. Same weights, same answers." Three-bar legend: MLX, Husky, "Husky, Flash on"; right column header "tokens a second: MLX · Husky · Flash on". Rows, MLX/Husky/Flash-on with the labelled multiple: Function edit 163/614/730 4.5×; Add a field to a JSON file 157/611/672 4.3×; Rename a SQL column 158/487/547 3.5×; Write a function 155/170/545 3.5×; Fix typos in a paragraph 159/463/535 3.4×; Invoice to JSON 164/208/496 3.0×; CSV to a table 158/287/462 2.9×; Data to a table 163/188/282 1.7×; Repeated transcript 153/164/273 1.8×; Tone rewrite 162/168/269 1.7×; Short email 151/164/260 1.7×; Project plan 158/171/246 1.6×; Meeting notes to to-dos 163/175/234 1.4×; Reply to an email thread 163/170/217 1.3×; Call summary 162/166/211 1.3×; Question over a document 159/193/210 1.3×.*
> ![[sigil-husky-004.png]]
>
> *Frame 5 (~14.2 s). The time-to-first-word slide. Right rule "First word · when a chat continues". Title: "One more message. MLX rereads the chat. Husky answers from where it left off." A mock chat: "Summarize the storage migration call." / "Five bullets, two decisions, three open questions." / "One more: who owns the certificate renewals?" Caption "time to the first word of the reply, 10× slow motion". Two bars: MLX **157 ms**, annotated "extends its prompt cache, then pays a fixed cost per call"; Husky **34 ms**, annotated "continues from the state it kept on the GPU". Footer: "29 to 39 ms on Husky, 137 to 177 ms on MLX, both engines continuing from their caches. 3.6 to 5.5× sooner."*
> ![[sigil-husky-005.png]]
>
> *Frame 6 (~16.0 s). The live side-by-side race, and the frame that names the hardware. Header "Husky by Underdog". Left: "real time **1.20 s**", "both on the same **M5 Max MacBook Pro**, same Woof weights". Prompt: "Fix the spelling and grammar in this paragraph. Change nothing else and return the whole paragraph." Top stream "MLX / Apple's engine" counter **150 tokens a second**, part-way through a paragraph about a storage migration ("finished last night, about 40 terabytes in total... he needs the staging environment to himself from six to nine. Separ"). Bottom stream "Husky / Flash on" counter **537 tokens a second**, "done in 0.53 s", already finished ("...we can cover backend with contractors for a quarter."). Footer: "Woof served with Husky, Flash on - Underdog · the same M5 Max MacBook Pro, the same Woof weights · a real stream, replayed at the speed it arrived", and right "Up to **730** tok/s · 16 of 16 tasks faster than MLX · husky.underdog.ai".*
> ![[sigil-husky-006.png]]
>
> ### 3. The author self-reply (the mechanism)
>
> **[@0xSigil (Sigil Wen)](https://x.com/0xSigil/status/2102165863956910339)** - 2026-09-21 22:39 UTC
>
> > To beat Apple's MLX we wrote model-shaped Metal Megakernels.
> >
> > MLX is general, so each layer is a chain of small GPU calls with the CPU in between. Husky knows Woof's shapes ahead of time, so each matrix gets one kernel: norm, 4-bit unpack and multiply in one pass.
> >
> > The GPU never waits.
>
> *The attached slide, transcribed in full. Header "Husky by Underdog", right rule "Metal · one decode layer". Title: "Model-shaped Metal megakernels." Body: "Each projection has its own kernel for its exact matrix, with the norm folded in, gate and up walked together, and the 4-bit weights unpacked straight into the multiply. Fewer dispatches, no host between them." Top row, "A general engine, one layer: a dispatch per operation and the host between them": boxes norm | q | k | v | attention | norm | gate | up | down, separated by red dashed gaps, trailing "× 32 layers". Bottom row, "Husky: the norm folded into each projection, gate and up in one walk, back to back on the GPU": boxes norm + q k v | attention | norm + gate · up | down, trailing "× 32, next step already queued". Red caption: "red dashes: the host encoding the next dispatch. Husky has none between kernels, and the next token's whole step is already submitted." Grey caption: "Same GPU, same 2.4 GB read per token. The step is about 6 ms either way; what changed is what comes out of it." Bold line: "270 dispatches a step became 206, the 24 recurrence layers run on one resident grid, and the next step is submitted while this one runs."*
> ![[sigil-husky-diagram.jpg]]
> Original: `https://pbs.twimg.com/media/HSxketUa0AAXKIz.jpg`
>
> ### 4. husky.underdog.ai - the full technical write-up (verbatim)
>
> Title: Husky: a model-specific inference engine up to 4.5× faster than Apple's MLX
>
> URL Source: https://husky.underdog.ai
>
> Markdown Content:
> ---
> description: Husky, a model-specific inference engine for Apple silicon, up to 4.5× faster than Apple's MLX on all sixteen tasks measured: 1.8 to 3.9× on edits, 3.6 to 5.5× to the first word, and with Flash on, its trained draft, up to 4.5×.
> title: Husky: a model-specific inference engine up to 4.5× faster than Apple's MLX
> image: https://husky.underdog.ai/husky-card.jpg
> ---
>
>  
>
> [![](icon.png)Husky by Underdog](https://underdog.ai) 
>
> Research · Inference · Underdog
>
> # Husky: a model-specific inference engine up to 4.5× faster than Apple's MLX
>
> Husky is a model-specific inference engine that runs Underdog's Pareto-frontier model, Woof. On a MacBook, Woof runs up to 730 tokens a second with Husky Flash on, up to 4.5× faster than MLX, and answers 5× sooner with the same weights. Built for Apple silicon, so Underdog runs on your Mac and iPhone, even without wifi.
>
> **Sigil Wen**, Underdog · [\[email protected\]](/cdn-cgi/l/email-protection#d6a5bfb1bfba96b5b9b8a1b7aff8a2b3b5be)20 September 2026Apple M5 Max
>
> **730 tok/s**decode, Flash onup to, on a function edit; MLX 163\. 1.3 to 4.5× across all sixteen tasks
>
> **5,150 tok/s**prefillcold, 859-token prompt, at the caller; MLX 3,094\. Inside the engine, 5,460
>
> **35 ms**to the first wordon a continued chat; MLX 140 ms with its cache, 280 ms rereading. 3.6 to 5.5× sooner
>
> **16 of 16**tasks faster than MLXsame weights, same answers. Without Flash 1.02 to 3.9×, edits 1.8 to 3.9×
>
> Against MLX, the runtime Underdog has shipped Woof on since day one, Husky is faster on all sixteen prompt types we measure. The edits are fast because Husky verifies eight tokens per step at 1.5× the cost of one, and most of the reply is already in the prompt. The writing lead comes from pipelining: the next step is encoded and submitted while the current one runs, so the GPU never waits on the host. Cold, on a prompt neither has seen, Husky reaches the first word 1.8 to 3× sooner; against MLX's plain generate call, which prefills the whole conversation again, 4 to 7×.
>
> ### Husky: higher model data efficiency on Apple silicon than MLX
>
> Producing a token means streaming all 2.4 GB of Woof from unified memory through the 40 GPU cores, about 6 ms on the M5 Max, and no engine reads faster than the bus. What Husky changes is how many tokens come out of each read.
>
> The same edit, written on both dies, same clock**1×**
>
> MLX0 tokens
>
> Husky0 tokens
>
> Measured on this edit: **MLX 159** tokens per second, **Husky 463**, **Flash on 535**.Tokens kept per read of the weights: MLX 1.0, Husky 5.4 on edits, Flash on 2.7 on writing.Click a die to pause.
>
> **Figure 1.** One decode step on the M5 Max, on an edit. Producing a token means streaming all 2.4 GB of Woof across the memory bus into the 40 GPU cores, about 6 ms either way. MLX gets one token per read and waits on the host between reads. Husky feeds eight candidate rows through each read, keeps the ones that match, has the next read queued before this one ends, and keeps the conversation's state in memory instead of rereading it. Being built for one model is what makes each of those possible. Click to pause.
>
> ## Results
>
> One M5 Max, one set of Woof weights, greedy decoding. Sixteen prompt types drawn from what the app asks Woof to do: emails, thread replies, rewrites, plans, notes, call summaries, questions over a document, invoices to JSON, data to a table, code from scratch and code edits. Each prompt was measured on both engines in its own quiet window, three runs each, with a canary run first and the order alternated from prompt to prompt.
>
> **Figure 2.** Decode throughput across sixteen prompt types, tokens per second while writing the reply, three bars per prompt: MLX, Husky, and Husky with Flash on, the draft model described below. Husky alone is 1.02 to 1.27× faster than MLX on writing and 3.8× on the function edit, where most of the reply is already in the prompt. Flash on adds 1.1 to 1.7× on writing, 2.4× on Invoice to JSON and 3.2× on code from scratch, and on the edits it defers to prompt lookup and edges it.
>
> **Figure 3.** Time to the first token when a conversation is re-sent with one more message, the way a chat works. Both engines continue from their caches: Husky from its prefix cache, MLX from mlx-lm's prompt cache extended over the previous turn, so only the new message (26 to 31 tokens) is fed. MLX's plain generate call, which prefills the whole conversation again, takes 145 to 295 ms. Cold prompts are Figure 4.
>
> **Figure 4.** Cold prefill measured at the caller: prompt tokens per second of wall-clock time to the first token, on prompts neither engine has seen. Inside the engines the long-prompt rates are 4,878 (MLX) and 5,460 (Husky).
>
> **Table 1.** Sixteen prompt types, medians of three runs per engine, each measured in its own quiet window with a canary check first and repeats that agree within 12%. Flash on is the same engine with the trained draft in its slot; its Faster column is against MLX. First-token times are for a conversation re-sent with one more message, the way a chat works, with both engines at their best: Husky answers from its prefix cache; MLX from mlx-lm's prompt cache extended over the previous turn, fed only the 26 to 31 new tokens. MLX's plain generate call, which prefills the whole conversation again, takes 145 to 295 ms instead; that is the number a caller sees without the cache. Cold, on a prompt neither engine has seen, Husky reaches the first word in 0.05 s on the short prompt and 0.17 s on the 859-token one; MLX takes 0.15 s and 0.30 s.
>
> | Prompt                                    | MLX tok/s | Husky tok/s | Faster    | Flash on | Faster    | MLX first | Husky first | Sooner   |
> | ----------------------------------------- | --------- | ----------- | --------- | -------- | --------- | --------- | ----------- | -------- |
> | Function edit, 368 tokens in              | 163       | 614         | **3.77×** | 730      | **4.48×** | 177 ms    | 32 ms       | **5.5×** |
> | Add a field to a JSON file, 477 tokens in | 157       | 611         | **3.89×** | 672      | **4.28×** | 145 ms    | 30 ms       | **4.8×** |
> | Rename a SQL column, 240 tokens in        | 158       | 487         | **3.08×** | 547      | **3.46×** | 143 ms    | 33 ms       | **4.3×** |
> | Write a function, 40 tokens in            | 155       | 170         | **1.10×** | 545      | **3.52×** | 145 ms    | 29 ms       | **5.0×** |
> | Fix typos in a paragraph, 301 tokens in   | 159       | 463         | **2.91×** | 535      | **3.36×** | 141 ms    | 31 ms       | **4.5×** |
> | Invoice to JSON, 321 tokens in            | 164       | 208         | **1.27×** | 496      | **3.02×** | 144 ms    | 30 ms       | **4.8×** |
> | CSV to a table, 303 tokens in             | 158       | 287         | **1.82×** | 462      | **2.92×** | 141 ms    | 34 ms       | **4.1×** |
> | Data to a table, 247 tokens in            | 163       | 188         | **1.15×** | 282      | **1.73×** | 150 ms    | 31 ms       | **4.8×** |
> | Repeated transcript, 857 tokens in        | 153       | 164         | **1.07×** | 273      | **1.78×** | 140 ms    | 39 ms       | **3.6×** |
> | Tone rewrite, 195 tokens in               | 162       | 168         | **1.04×** | 269      | **1.66×** | 138 ms    | 34 ms       | **4.1×** |
> | Short email, 38 tokens in                 | 151       | 164         | **1.09×** | 260      | **1.72×** | 148 ms    | 38 ms       | **3.9×** |
> | Project plan, 51 tokens in                | 158       | 171         | **1.08×** | 246      | **1.56×** | 139 ms    | 37 ms       | **3.8×** |
> | Meeting notes to to-dos, 249 tokens in    | 163       | 175         | **1.07×** | 234      | **1.44×** | 148 ms    | 36 ms       | **4.1×** |
> | Reply to an email thread, 280 tokens in   | 163       | 170         | **1.04×** | 217      | **1.33×** | 139 ms    | 36 ms       | **3.9×** |
> | Call summary, 657 tokens in               | 162       | 166         | **1.02×** | 211      | **1.30×** | 151 ms    | 34 ms       | **4.4×** |
> | Question over a document, 297 tokens in   | 159       | 193         | **1.21×** | 210      | **1.32×** | 137 ms    | 34 ms       | **4.0×** |
>
> ## How it works
>
> Husky refuses to be general, and that is where the speed comes from.
>
> * **Kernels compiled for Woof's exact shapes.** Every matrix in Woof has one size, so every GPU kernel is written for that size and nothing else.
> * **Weights packed the way the kernels read them.** Woof's 4-bit weights are laid out on disk in the kernels' own tile order and mapped straight into memory. No conversion at load, no copy.
> * **An 8-bit cache the attention kernels read directly,** and a memory plan worked out for your Mac when the engine starts. No config file, nothing to tune.
> * **It remembers your conversation.** Send the same chat again with one more message and Husky answers from where it left off, which is why the first word takes about 35 ms. MLX's prompt cache does the same job and still takes about 140 ms, the fixed cost of a call on that path.
> * **It checks eight tokens at once.** Every step verifies a block of eight tokens for the price of one. Today the guesses come from your own prompt, which is why a function edit runs 3.8× faster: most of the file is already there. With Flash on, a draft trained on Woof guesses for everything else.
>
> **Figure 5.** Inference engines are general: one runtime, many models. Husky runs one. A general engine keeps one kernel for any shape and checks sizes as it goes. Husky knows Woof's four matrices at compile time, so each has a kernel drawn to its size, and the weights are stored on disk in the tile order that kernel reads.
>
> ## Why prose is close, and how Husky pulls ahead
>
> Producing one token means reading all 2.4 GB of Woof's weights. On this Mac that takes about 4.5 ms even for a plain streaming read, and no engine gets under it. Husky and MLX both sit near that line for plain writing: about 6.1 ms per token against 6.3\. What separated them was the host. Every step used to cost almost half a millisecond of encoding and waiting between GPU commands; Husky now encodes the next step while the current one runs, so the GPU goes straight from one token to the next. That is the 5% on the transcript. The way past the line itself is to get several tokens out of one read.
>
> That is what the eight-token check is for. The guesses come from the prompt when the reply repeats it, and otherwise from Flash, a draft trained on Woof itself, which lands about 2 tokens a step today and takes prose from 164 to 175 tokens per second to 210 to 273\. Every extra token a step is another 60 or so tokens per second.
>
> ## Built for edits
>
> Much of what an assistant does to your text is not writing, it is editing: fix the typos in this paragraph, add a field to this file, turn this CSV into a table, rename this column, change one thing in this function and give it all back. In every one of those the reply repeats long runs of the prompt word for word. Husky is built for that shape.
>
> Every decode step verifies a block of eight tokens for about one and a half times the price of one. When the last few tokens Husky wrote also appear in the prompt, it proposes the seven that followed there, and Woof keeps the ones it agrees with, typically five or six. A plain engine writes those replies one token at a time; Husky writes them five and six tokens at a time, which is where the 1.8 to 3.9× in the table comes from, with the answer identical to the letter. Underdog asks Woof for edits like these all day, so this is not a corner case, it is the common one.
>
> ## Flash on
>
> Prompt lookup only helps when the reply repeats the prompt. For everything else the eight-row step needs a guesser, and we trained one, the Flash draft: a single small layer that reads Woof's own hidden states from five of its layers and proposes the next seven tokens. It is trained by self-distillation on Woof's replies to 139,000 conversations: Underdog's own prompt shapes (edits, JSON, tables, HTML and markdown UI, tool calls, mail, code, summaries, browser steps, follow-ups) and public chat, instruction and code sets, about two hours on one B200\. Nothing about the answer changes: Woof still checks every proposal and keeps only what it would have written.
>
> With Flash on, Husky decides each step who guesses. If the last few tokens appear earlier in the prompt, lookup proposes, since it is better at copying. Otherwise the draft runs while its guesses land at least half a token a step, and rests on the one-row path when they stop. On writing the draft lands about 2 tokens a step, which turns 164 to 175 tokens per second into 210 to 273\. On code from scratch it lands 5 and the reply runs at 545, three and a half times MLX; on Invoice to JSON, 496\. The edits stay with lookup and gain a little from the draft between matches: 462 to 730 tokens per second, 2.9 to 4.5× MLX. This is the same weights, the same answers, and a 273 MB draft file in the package.
>
> Two engine changes made the draft pay. A draft step is an eight-row step, and the eight-row projections had been running at 2.3× the cost of one row because the kernels walked a 12,800-wide input as one serial chain of matrix ops per simdgroup; splitting that input across the eight simdgroups brought the step to 1.5×, which is also why the edit rows above rose from 403 to 487 and from 483 to 611 in the same change. And the draft is judged the way lookup is, by what it landed, over a window long enough to see past a reply's opening, where every draft guesses worst.
>
> ## MSI: model-specific inference
>
> We call the approach MSI, model-specific inference: an engine that knows one model's every shape at compile time and spends none of its time being general. Today that means four things, all shipped in the numbers above.
>
> * **Model-shaped, specialized Metal megakernels.** Each projection has its own kernel for its exact matrix, with the norm that precedes it folded in, the gate and up projections walked together, the 4-bit weights unpacked four at a time straight into the multiply, and the eight-row step's long inputs split across the simdgroups. A layer's whole MLP already runs as one persistent dispatch; the whole step is the direction below.
> * **A resident grid for the recurrence.** The 24 linear-attention layers run their recurrence on a persistent grid of threadgroups that hand off through device-side counters, not through the command stream.
> * **Weights and cache in kernel order.** The package stores the weights in the tile order the kernels read, and the 8-bit key-value cache in the layout the attention kernels consume, so nothing is rearranged at load or at run time.
> * **Pipelined submission.** The next decode step is encoded and submitted while the current one runs, with the next token handed over on the GPU. The host is off the critical path, which is where the last 5% on long prose came from.
>
> **Figure 6.** One decode layer as a row of dispatches, to scale in GPU time. A general engine issues one per operation with the host encoding between them. Husky folds the norm into each projection, walks gate and up together and splits the long inputs across the simdgroups, so a layer is four kernels back to back, and the next token's step is already submitted when this one ends.
>
> The direction from here is a whole-step megakernel: one persistent dispatch that runs all 32 layers of a decode step against a static tile schedule, meeting at device-side barriers between stages. We built the first piece, a layer's whole MLP as one persistent dispatch with a grid barrier, and measured it honestly: identical output, and no faster. On this GPU, dispatches placed back to back in one encoder already run with almost no gap, so a megakernel only pays where it can overlap the next stage's weight loads with the current stage's tail. That is the version worth building, and it matters most for the eight-row verify step a trained draft will make the common case.
>
> ## What's next
>
> * **A better draft.** Round four lands about 2 tokens a step on writing; later rounds continue from it on fresh data while the held-out score keeps improving. Every extra token a step is another 60 tokens per second on prose.
> * **Husky in the app.** Husky is live in Underdog on the Mac today, with no setup.
> * **CUDA megakernels.** The same approach, one model's shapes known at compile time, is being written for NVIDIA GPUs for our upcoming launches with NVIDIA and Microsoft.
>
> ## Method
>
> Apple M5 Max, 40-core GPU, 128 GB, macOS 26.5.1\. Woof is Underdog's published 4B model at 4 bits, the same file for both engines; Husky repacks it without changing a value, and greedy output is compared token by token against MLX after every change. MLX is mlx-lm 0.31.3 on MLX 0.32.2\. The sixteen-prompt suite ran on the evening of 20 September with a load average under 10 and the production app idle for every measurement; the cold prefill figures come from an earlier quiet window the same day. Runs that disagreed with their own repeats were discarded, and the receipts are kept.
>
> ## Try it today
>
> Husky is live in Underdog on the Mac. Download Underdog, connect your mail and calendar, and Woof runs on your own machine at these speeds today, with nothing sent anywhere and no setup. [Get Underdog at underdog.ai](https://underdog.ai).
>
> ## Cite
>
> Wen, Sigil. "Husky: a model-specific inference engine up to 4.5× faster than Apple's MLX." Underdog, 20 September 2026\. https://husky.underdog.ai>
> ### 5. Figures rendered from husky.underdog.ai
>
> The page's figures are interactive SVG, so the markdown twin above carries their captions but not their content. Captured from the live page at 1280px. Figures 1, 5 and 6 are omitted: 1 and 5 duplicate video frames 1 and 2 above, and 6's animated dispatch bars do not draw in a headless capture.
>
> *Figure 2, with the page's own caption. Decode throughput across sixteen prompt types, three bars per prompt. Every value matches Table 1.*
> ![[sigil-husky-fig2.png]]
>
> *Figure 3, with the page's own caption. Milliseconds to the first token on a continued chat, sorted by the multiple: Function edit 32 ms against 177 ms for 5.5x, down to Repeated transcript 39 ms against 140 ms for 3.6x.*
> ![[sigil-husky-fig3.png]]
>
> *Figure 4, with the page's own caption. Cold prefill at the caller, the one chart with no counterpart in the video. Short prompt of 40 to 70 tokens: MLX 259 against Husky 1,355 prompt tokens a second, a 5.2x gap. Long prompt of 857 to 890 tokens: MLX 3,094 against Husky 5,151, a 1.67x gap. Inside the engines the long-prompt rates are 4,878 and 5,460.*
> ![[sigil-husky-fig4.png]]
>
> ### 6. ConwayResearch/husky-flash model card (verbatim)
>
> ---
> license: other
> base_model: ConwayResearch/woof-1.0-4B
> tags:
>   - husky
>   - apple-silicon
>   - metal
>   - speculative-decoding
> ---
>
> # Husky Flash: Woof 1.0 4B for Husky, with the Flash draft
>
> Woof is the Pareto-frontier model that runs Underdog on your Mac and iPhone, even without wifi. This is Woof packed for **Husky**, Underdog's model-specific inference engine for Apple silicon, with **Flash on**: the trained draft that lets Husky check several tokens per read of the weights.
>
> Husky is built around Woof's exact shapes instead of around any model. On an M5 Max it is faster than Apple's MLX on all sixteen tasks we measure: 1.8 to 3.9× on edits, 3.6 to 5.5× to the first word on a continued conversation, and with Flash on, 1.3 to 4.5× across the board. Same weights, same answers. The numbers, the method and the receipts are at [husky.underdog.ai](https://husky.underdog.ai).
>
> ## What is in the package
>
> - `target/`: Woof's 4-bit weights laid out in the order Husky's kernels read them. A repack, not a requantization: no value changes.
> - `draft/`: the Flash draft, round 4. One small layer that reads Woof's own hidden states from five of its layers and proposes the next seven tokens; trained by self-distillation on Woof's replies to 139,000 conversations: Underdog's own prompt shapes (edits, JSON, tables, HTML and markdown UI, tool calls, mail, code, summaries, browser steps, follow-ups) and public chat, instruction and code sets. On writing it lands about 2 tokens a step; on code and structured output, 4 to 5.
> - `manifest.json`: the model's geometry, which the engine reads instead of assuming.
> - `tokenizer/`: Woof's tokenizer.
>
> ## How to run it
>
> Download Underdog for the Mac and Husky runs Woof for you. In Underdog, the Woof card on the Models page has the engine switch: Apple MLX, Husky, or Husky with Flash on.
>
> Developers can serve this package directly with the Husky server from the Underdog Greyhound repository:
>
> ```sh
> husky serve --model ConwayResearch/husky-flash
> ```
>
> ## Measured on this package (M5 Max, greedy, medians of three, quiet windows)
>
> | Prompt | MLX tok/s | Husky | Flash on |
> | --- | ---: | ---: | ---: |
> | Short email | 151 | 164 | 260 |
> | Reply to a thread | 163 | 170 | 217 |
> | Tone rewrite | 162 | 168 | 269 |
> | Meeting notes to to-dos | 163 | 175 | 234 |
> | Call summary | 162 | 166 | 211 |
> | Question over a document | 159 | 193 | 210 |
> | Invoice to JSON | 164 | 208 | 496 |
> | Data to a table | 163 | 188 | 282 |
> | Write a function | 155 | 170 | 545 |
> | CSV to a table | 158 | 287 | 462 |
> | Fix typos in a paragraph | 159 | 463 | 535 |
> | Rename a SQL column | 158 | 487 | 547 |
> | Add a field to a JSON file | 157 | 611 | 672 |
> | Function edit | 163 | 614 | 730 |
>
> First token on a continued conversation, both engines from their caches: 29 to 39 ms on Husky, 137 to 177 ms on MLX.
>
> ## Licence
>
> Woof's licence applies to these weights, as for `ConwayResearch/woof-1.0-4B`.
>
> ### 7. underdog.ai (homepage, verbatim)
>
> Title: Underdog. The Most Loyal AI.
>
> URL Source: https://underdog.ai
>
> Markdown Content:
> ---
> description: A loyal AI for your mail, calendar, and everyday work. Runs locally on your Mac.
> title: Underdog. The Most Loyal AI.
> image: https://underdog.ai/social/underdog-preview-v4.png
> ---
>
> [![](/icon.png)Underdog](#chapter-hello)
>
> Underdog is in an invite-only beta and getting better every day.
>
> # The most  
> _loyal_ AI.
>
> 100% local AI. 100% private.
>
> come on.  
> I’ll show you.
>
> [Scroll to walk with me](#chapter-woof)
>
> ## I’m _Underdog._
>
> I’m a small but mighty AI model, trained to help you.
>
> I run on your computer, not in a data center. Your data stays **_private_**.  
> Less than 4GB on your computer.
>
> I’m loyal. And a good boi.
>
> 02 Browser
>
> ## Give me  
> an _errand._
>
> I use your ![Chrome](/chrome-logo.svg)**_browser_** to book flights, reserve tables, order groceries, shop, and cancel forgotten subscriptions. You approve before I book, buy, or cancel. Take over any time.
>
> united.com/book-flightUnderdog is using your browserTake over
>
> RoundtripOne-wayMulti-cityWhere to?UnderdogRoundtripOne-wayMulti-cityWhere to?Underdog
>
> **Find a nonstop SFO → New York flight, Sep 18.**Opening the flight search
>
> Sample 1/4_No ticket purchased_
>
> FlightsDinnerGroceriesSubscriptions
>
> I’m very good at fetch.
>
> 03 Email
>
> ## Fast email.  
> _100% private._
>
> I connect directly to your ![](/gmail-logo.png)**_Gmail_** and ![](/outlook-logo.svg)**Outlook**. Your credentials are stored securely on your computer.
>
> EC⌘KMade for your keyboard.
>
> ![](/mail-demo/inbox-zero-meadow.jpg)
>
> AIMail
>
> ComposeJD
>
> Inbox 6Important 2Other 4
>
> Today
>
> Maya ChenWednesday’s design reviewCan we meet at 11? I’ll have the revised screens ready.9:42 AM
>
> Elliot ParkCoffee after the call?There’s a new place around the corner.9:18 AM
>
> Morning BriefA few things worth readingYour Monday reading list is here.8:30 AM
>
> Weekend NotesYour weekend, a little slowerA few ideas for a quieter weekend.8:12 AM
>
> Product WeeklyThis week in good designThree thoughtful products we found this week.7:50 AM
>
> Studio JournalA little inspiration for todayFresh ideas from the studio.7:24 AM
>
> **New Message**Saving…
>
> ToMaya Chen Cc Bcc
>
> Subject**Wednesday’s design review**
>
> **B**_I_UA⌄
>
> ![](/icon.png)SendSend laterRemind meShare draft
>
> **Jordan Davis**JD[\[email protected\]](/cdn-cgi/l/email-protection)Choose senderEDIT PROFILE example.com
>
> UnderdogE Mark DoneH set a reminderC compose/ search⌘ K for Underdog AI Command commands Local
>
> Your inbox. Your computer. Your business.
>
> 04 Meeting notes
>
> ## You talk.  
> I take _notes._
>
> Fully private meeting notes, transcribed and summarized on your device. Underdog never sends your audio or notes to a data center for processing.
>
>  Monday team syncSample meeting
>
> Monday team sync23:18
>
> Camera offMC
>
> Maya Chen
>
> Camera offEP
>
> Elliot Park
>
> Camera offY
>
> You
>
> CC _Call captions_
>
> **Maya:** I’ll finish the signup screens Tuesday. Let’s review them Wednesday at 11 and resolve any open design questions.
>
> MicCameraShareLeave
>
> ![](/icon.png)**Underdog**
>
> ### Monday team sync
>
> Sep 14Sep 14 · 10:30 AM3 people24 min
>
> **Notes**Transcript
>
> Write your thoughts, or pause to generate notes…
>
> Listening on your computer
>
> 23:18
>
> Meeting in progressOn your computer
>
> All ears. Every little detail.
>
> 05 Dictation
>
> ## Speak  
> _anywhere._
>
> Underdog turns your voice into words, faster than you can type, in any app. Your audio is transcribed on your device, never streamed to a data center.
>
> Dictating in **Slack** **launch**
>
> M
>
> **Maya Chen**3:39 PM
>
> How’s the launch coming along?
>
> **B**_I_~~S~~
>
> Message #launch
>
> Draft · not sent
>
> Y
>
> **You**Just now
>
> Sent · demo
>
> fn**Hold fn**Speak naturally.Hold fn
>
> Underdog dictation
>
> Your voice. Your words. Your computer.
>
> 06 Calendar
>
> ## Fast calendar.  
> _Fully private._
>
> I find free time, flag conflicts, and prepare events for your approval. I connect directly to your ![](/google-calendar-logo.png)**_Google Calendar_** and ![](/outlook-logo.svg)**Outlook Calendar**.
>
> AICalendar
>
> New eventJD
>
> Today**Sep 2026**Week 
>
> PDT
>
> Sun**13**
>
> Mon**14**
>
> Tue**15**
>
> Wed**16**
>
> Thu**17**
>
> Fri**18**
>
> Sat**19**
>
> all-day
>
> **Launch day**
>
> 9 AM10 AM11 AM12 PM1 PM2 PM
>
> **Morning walk**10:00 AM
>
> **Monday team sync**
>
> **Focus time**12:00 PM
>
> **Coffee with Elliot**
>
> **Revised screens**9:30 AM
>
> **Lunch**12:00 PM
>
> **Weekly planning**
>
> **Project time**1:00 PM
>
> **Check signup flow**
>
> **Lunch**12:00 PM
>
> **Launch check-in**
>
> **Focus time**11:00 AM
>
> S**13**M**14**T**15**W**16**T**17**F**18**S**19**
>
> **Monday team sync**10:30 AM – 10:54 AM
>
> **Focus time**12:00 PM – 1:30 PM
>
> **Coffee with Elliot**2:00 PM – 2:30 PM
>
> **September 2026**
>
> **S** **M** **T** **W** **T** **F** **S**3031123456789101112131415161718192021222324252627282930123
>
> **Calendars**
>
> **All connected accounts**
>
> [\[email protected\]](/cdn-cgi/l/email-protection)[\[email protected\]](/cdn-cgi/l/email-protection)On this deviceHolidays in United StatesSample events
>
> Examples only. Turn off here or in Settings.
>
> Synced 9:45 AM
>
> UnderdogD dayW weekM monthT today\= next− previousB create an event Local
>
> Your week. Your way.
>
> 07 Sensitive tasks
>
> ## Sensitive tasks.  
> _Protected._
>
> Doctor’s appointments, prescription refills, tax paperwork. I find what you need and get the next step ready for your approval. Your information ~~isn’t~~ **can’t be** used to train AI models. It’s all on device.
>
> AIChat
>
> New chatJD
>
> All ···Skills
>
> ### Ask Underdog
>
> Message Underdog…
>
>  Underdog 
>
> Return sends · Option-Return adds a line
>
> Things to trySchedule a doctor’s visit
>
> UnderdogC new chat/ search chats⌘ K commands Local
>
> Doctor visitPrescriptionTax return
>
> Your details. Your next step. Your say.
>
> 08 He protec
>
> ## He protec.  
> He attack.  
> _He got your back!_
>
> I track down your personal information on data-broker sites and send removal requests. Less of you out there.
>
> AIChat
>
> Concept preview
>
> New chatJD
>
> All He protecSkills
>
> ### Ask Underdog
>
> Message Underdog…
>
>  Underdog 
>
> Return sends · Option-Return adds a line
>
> Things to tryFind my data. Get it off data-broker sites.
>
> UnderdogC new chat/ search chats⌘ K commands Local
>
> A good boi on guard.
>
> 09 ALWAYS ON YOUR SIDE
>
> ## Your life  
> stays _yours._
>
> I run on your computer. Mail syncs directly with your provider. Messages and bookings you approve go to their intended recipients or websites.
>
> Close to you. Private by nature.
>
> AT HOME, ON YOUR COMPUTER
>
> MailNotesCalendarVoice
>
> **Private by nature.** Local AI · No cloud AI service
>
> STILL THE SAME SMALL, MIGHTY DOG.
>
> ## And the rest  
> of my _tricks._
>
> more tricks on the way.
>
> ### Memory you can inspect.
>
> Saved memories stay on your Mac. See, edit, or delete them in Settings.
>
> ### 100% local intelligence.
>
> Summaries, drafts, and answers come from a model running on your computer. Your content isn’t sent to a cloud AI service for processing. Underdog’s models are trained to be fast, power efficient, and mighty on your computer.
>
> ### Guards the door.
>
> Keeps you safe from remote images, scripts, and tracking pixels — stripped on sight.
>
> ### Tracks your expenses.Coming soon
>
> Receipts out of your inbox, into a ledger, with nothing to file.
>
> ### Does your taxes.Coming soon
>
> Every W-2, 1099, and receipt he already saw, sorted into a return you only have to sign.
>
> ### Protected where he sleeps.
>
> Every account gets its own AES-256-GCM vault. The key lives in Apple Keychain, secured by the Secure Enclave, and never leaves the device — Underdog curls up on top of it.
>
> BEFORE YOU BRING ME HOME
>
> ## Questions,  
> _answered._
>
> Which AI does Underdog use?+
>
> Our own. We are training models that are fast, power-efficient, and small but mighty — built to run on your computer. He may not top the leaderboards, but he is 100% yours: AI processing runs on your computer, without sending your content to a cloud AI service.
>
> How does my email sync?+
>
> Mail syncs directly between your computer and your email provider. Your AI processing happens privately on your computer.
>
> What stays on my device?+
>
> AI processing happens on your computer, where Underdog stores your recordings, notes, and transcripts. Mail syncs directly with your email provider. Messages you send and bookings you approve go to their intended recipients or websites.
>
> What does Underdog need to run?+
>
> A Mac with Apple silicon for the local AI. iPhone and iPad, Windows, Android, and Linux are coming — [tick the ones you want](/waitlist) and we’ll send one email per build when it ships.
>
> When can I adopt him?+
>
> Today, if you have a Mac with Apple silicon. [Download Underdog](/download). For every other device, pick yours below and we will send one email when that build is ready — nothing more.
>
> [And what about pricing? ↗](/pricing)
>
> GOOD DAYS START WITH A GOOD DOG.
>
> ## Bring me _home._
>
> Fast email. Calendar. Meeting notes. Dictation.  
> Your own AI. 100% private. On your computer.  
> And I’ll run your errands, too.
>
> [Adopt Underdog ](/download)For Apple silicon Macs
>
> your new best friend.
>
> Waiting for another device? ＋
>
> iPhone, iPad, Windows, Android, and Linux. Pick your devices and hear when I’m ready.
>
> ✦✦✦
>
> loyal means loyal
>
> ## Aligned with you — not advertisers, not an AI lab. _You._
>
> Underdog may not be the biggest model in the pack — just underrated and mighty. He listens, he remembers, he tries his best. His AI runs on your computer. Your content isn’t sent to a cloud AI service for processing. Mail syncs directly with your provider; messages you send and bookings you approve go to their intended recipients or websites. Local AI. Loyal to you.
>
> z z z
>
> A NOTE FROM MY CREATOR
>
> > “I’m building Underdog _for myself._”
>
> [Read the founder’s note ↗](/founder)>
> ### 8. Replies (180 blocks retrieved of 200 stated; the first is the author self-reply)
>
>
> @0xSigil (Sigil Wen):
> To beat Apple's MLX we wrote model-shaped Metal Megakernels.  
>
> MLX is general, so each layer is a chain of small GPU calls with the CPU in between. Husky knows Woof's shapes ahead of time, so each matrix gets one kernel: norm, 4-bit unpack and multiply in one pass.  
>
> The GPU never waits.
> PHOTO: https://pbs.twimg.com/media/HSxketUa0AAXKIz.jpg
> date: Mon Sep 21 22:39:32 +0000 2026
> url: https://x.com/0xSigil/status/2102165863956910339
> ──────────────────────────────────────────────────
>
> @JoshConstine (Josh Constine 📶🔥):
> @0xSigil Unclear how you are both shipping a consumer agent at lightspeed but also have time to just... fundamentally speed up inference. Also, name is adorable
> date: Mon Sep 21 22:43:54 +0000 2026
> url: https://x.com/JoshConstine/status/2102166959374926308
> ──────────────────────────────────────────────────
>
> @matt503ea5sf9z5 (Matt):
> @0xSigil this is crazy. this is what anthropic doesn't want people to know how to build themselves
> date: Tue Sep 22 23:01:53 +0000 2026
> url: https://x.com/matt503ea5sf9z5/status/2102533873498198058
> ──────────────────────────────────────────────────
>
> @ssandeshwar (Sandy):
> @0xSigil Would like to test it on M4 Max 128gb
> date: Tue Sep 22 05:19:03 +0000 2026
> url: https://x.com/ssandeshwar/status/2102266402073989543
> ──────────────────────────────────────────────────
>
> @VrianCao (VrianCao):
> @0xSigil I'm curious about multilingual ability, like Chinese, instead of just English
> date: Tue Sep 22 11:18:12 +0000 2026
> url: https://x.com/VrianCao/status/2102356788188492112
> ──────────────────────────────────────────────────
>
> @notdevin (notdevin):
> @0xSigil This is filthy, would love to try it on my loaded m3 ultra
> date: Tue Sep 22 04:41:34 +0000 2026
> url: https://x.com/notdevin/status/2102256971831448053
> ──────────────────────────────────────────────────
>
> @binji_x (binji):
> @0xSigil After our call today, I ate dinner, and you shipped a MSI engine 4.5x faster than Apple’s. 
>
> Atleast we’re both eating.
> date: Mon Sep 21 22:48:04 +0000 2026
> url: https://x.com/binji_x/status/2102168009053753438
> ──────────────────────────────────────────────────
>
> @dhaiwat (Dhai):
> @0xSigil so cool. would love to try this out!
> date: Wed Sep 23 02:12:50 +0000 2026
> url: https://x.com/dhaiwat/status/2102581930525151601
> ──────────────────────────────────────────────────
>
> @thattallguy (Jess 🌱):
> @0xSigil ya, people should try this. My pup is cooking.
> date: Mon Sep 21 23:27:15 +0000 2026
> url: https://x.com/thattallguy/status/2102177870227603524
> ──────────────────────────────────────────────────
>
> @pohmarcelo (Marcelo):
> @0xSigil can i get an invite to test?
> date: Tue Sep 22 01:19:52 +0000 2026
> url: https://x.com/pohmarcelo/status/2102206212892987425
> ──────────────────────────────────────────────────
>
> @SteveMoraco (steve):
> @0xSigil boy howdy that's fast
> date: Tue Sep 22 03:08:13 +0000 2026
> url: https://x.com/SteveMoraco/status/2102233477810966905
> ──────────────────────────────────────────────────
>
> @0xIlyy (ily⚡️):
> @0xSigil LFGGGG this looks fire
> date: Tue Sep 22 00:50:24 +0000 2026
> url: https://x.com/0xIlyy/status/2102198796767867378
> ──────────────────────────────────────────────────
>
> @benaratame (Ben Aratame):
> @0xSigil @shaojun_wen Incredible
> date: Tue Sep 22 00:00:18 +0000 2026
> url: https://x.com/benaratame/status/2102186185648910602
> ──────────────────────────────────────────────────
>
> @ddalcu (David Dalcu):
> @0xSigil Interesting article, but very sensationalist. 4B Model ? My grandma can do 700 tok/s.
> Common, put a real model on there, and give us M1,M2,M3,M4 numbers not only M5Max.  
> Also... open source, it's the only way, very few people will trust it otherwise.
> date: Tue Sep 22 18:24:01 +0000 2026
> url: https://x.com/ddalcu/status/2102463945512788174
> ──────────────────────────────────────────────────
>
> @chieng920811 (chi eng):
> @0xSigil 这个看起来真不错，能给个邀请吗
> date: Tue Sep 22 03:44:36 +0000 2026
> url: https://x.com/chieng920811/status/2102242636539285860
> ──────────────────────────────────────────────────
>
> @sjoerdhui (Sjoerd):
> @0xSigil Amazing, would it cook on a m4 pro / 48gb?
> date: Tue Sep 22 07:48:57 +0000 2026
> url: https://x.com/sjoerdhui/status/2102304128688881885
> ──────────────────────────────────────────────────
>
> @eldersavant (stochastic savants):
> @0xSigil You're not on huggingface?
> date: Tue Sep 22 09:03:06 +0000 2026
> url: https://x.com/eldersavant/status/2102322787545465147
> ──────────────────────────────────────────────────
>
> @mfrager7 (Mike Frager ⧉):
> @0xSigil Yo! Can I get an invite code? Thx!
> date: Tue Sep 22 23:45:15 +0000 2026
> url: https://x.com/mfrager7/status/2102544789157884276
> ──────────────────────────────────────────────────
>
> @meaningmean_ (otter):
> @0xSigil @grok can i use it on my 8gb ram macbook air m2
> date: Tue Sep 22 02:04:38 +0000 2026
> url: https://x.com/meaningmean_/status/2102217476574699717
> ──────────────────────────────────────────────────
>
> @jaigerbombs (deignan):
> @0xSigil Could I get access to test?
> date: Tue Sep 22 22:00:25 +0000 2026
> url: https://x.com/jaigerbombs/status/2102518404179702257
> ──────────────────────────────────────────────────
>
> @CuriousPub (Curious Pub):
> @0xSigil @pmarca Can we try it on a M3 Pro?
> date: Tue Sep 22 06:22:12 +0000 2026
> url: https://x.com/CuriousPub/status/2102282295973462223
> ──────────────────────────────────────────────────
>
> @continuumlabs_ (Continuum Labs):
> @0xSigil Local personal AI is the future!
> date: Tue Sep 22 14:09:35 +0000 2026
> url: https://x.com/continuumlabs_/status/2102399915238555839
> ──────────────────────────────────────────────────
>
> @zorrobyte (Ross Fisher):
> @0xSigil Ah, found it! https://t.co/VBmQD4WQdW
> date: Tue Sep 22 00:45:30 +0000 2026
> url: https://x.com/zorrobyte/status/2102197563759988931
> ──────────────────────────────────────────────────
>
> @cupseycode (Cupsey):
> @0xSigil 4.5x mlx on a macbook is kinda insane
> date: Tue Sep 22 19:22:25 +0000 2026
> url: https://x.com/cupseycode/status/2102478642567901379
> ──────────────────────────────────────────────────
>
> @HuskyUnderdog (Husky the Underdog):
> @0xSigil Can I get an invite to test Husky? @0xSigil
> date: Tue Sep 22 20:33:16 +0000 2026
> url: https://x.com/HuskyUnderdog/status/2102496472264487382
> ──────────────────────────────────────────────────
>
> @shanelogsdon (Shane Logsdon):
> @0xSigil interested if this is runnable at usable speeds on an M4 w/ 32GB shared RAM?
> date: Tue Sep 22 08:18:19 +0000 2026
> url: https://x.com/shanelogsdon/status/2102311518624993630
> ──────────────────────────────────────────────────
>
> @MinOnTn (Min On):
> @0xSigil Can I get an invite? MacBook Air  13 m4 16 GB
> date: Tue Sep 22 10:52:37 +0000 2026
> url: https://x.com/MinOnTn/status/2102350350342881416
> ──────────────────────────────────────────────────
>
> @JumpyJasonJia (Jason Jia):
> @0xSigil Why can't I sign up?
> date: Tue Sep 22 12:45:20 +0000 2026
> url: https://x.com/JumpyJasonJia/status/2102378716416638986
> ──────────────────────────────────────────────────
>
> @itsjulianpaul (Julian Paul):
> @0xSigil Love this! Would look amazing on @earlytools : )
> date: Tue Sep 22 07:39:10 +0000 2026
> url: https://x.com/itsjulianpaul/status/2102301663897792523
> ──────────────────────────────────────────────────
>
> @BenRacicot (Ben Racicot):
> @0xSigil Can I swap my engine for this and ship it? 
> I'm on the list!
> date: Tue Sep 22 14:55:17 +0000 2026
> url: https://x.com/BenRacicot/status/2102411417072848945
> ──────────────────────────────────────────────────
>
> @KadriJibraan (Jibraan):
> @0xSigil babe wake up sigil just shipped something crazy again
> date: Tue Sep 22 20:43:15 +0000 2026
> url: https://x.com/KadriJibraan/status/2102498988142563522
> ──────────────────────────────────────────────────
>
> @mattwiebe (Matt Wiebe):
> @0xSigil This looks great but I can't try it with this invite gate and I ain't posting begging tweets
> date: Wed Sep 23 00:01:47 +0000 2026
> url: https://x.com/mattwiebe/status/2102548949966143573
> ──────────────────────────────────────────────────
>
> @JhonDennisxiud (Jhon Dennis):
> @0xSigil 本地模型越来越快  普通人不用先学一堆名词  开了就能用
> date: Tue Sep 22 11:53:43 +0000 2026
> url: https://x.com/JhonDennisxiud/status/2102365725885387226
> ──────────────────────────────────────────────────
>
> @shirodkartejas (Tejas Shirodkar):
> @0xSigil Have a M5 Max 128Gb, M4 Pro 48Gb and a M2 Pro 32Gb, would love to try it out!
> date: Tue Sep 22 14:54:49 +0000 2026
> url: https://x.com/shirodkartejas/status/2102411300982919512
> ──────────────────────────────────────────────────
>
> @Vardaan02 (Vardaan Chaphekar):
> @0xSigil Would love an invite! M4 Pro MBP 24Gb
> date: Wed Sep 23 00:46:52 +0000 2026
> url: https://x.com/Vardaan02/status/2102560294920995322
> ──────────────────────────────────────────────────
>
> @cody_bunch (Cody Bunch - @codybunch.com):
> @0xSigil So, how does one get this rolling on an M1Max?
> date: Wed Sep 23 01:20:23 +0000 2026
> url: https://x.com/cody_bunch/status/2102568727179035130
> ──────────────────────────────────────────────────
>
> @rsms (Rasmus Andersson):
> @0xSigil I struggle to understand what underdog is. Tried making sense of the website on my iPhone but scrolljacking makes is hard to focus. Is it a Mac app? A website? A service?
> date: Tue Sep 22 21:31:32 +0000 2026
> url: https://x.com/rsms/status/2102511138755998121
> ──────────────────────────────────────────────────
>
> @HaHoang411 (Ha Hoang):
> @0xSigil wow what about multilingual? and is it coming with training/finetuning code as well? I think opensourcing this would create a huge bomb
> date: Tue Sep 22 14:25:45 +0000 2026
> url: https://x.com/HaHoang411/status/2102403984317161681
> ──────────────────────────────────────────────────
>
> @ptbthefirst (Paul-Simon):
> @0xSigil 730 tokens per sec on a macbook sounds inflated until they show the exact chip and quant used.
> date: Tue Sep 22 06:57:12 +0000 2026
> url: https://x.com/ptbthefirst/status/2102291104049856699
> ──────────────────────────────────────────────────
>
> @thesophiaxu (Sophia Xu):
> @0xSigil Congrats, would love an invite!
> date: Tue Sep 22 17:59:33 +0000 2026
> url: https://x.com/thesophiaxu/status/2102457789025329183
> ──────────────────────────────────────────────────
>
> @valkyr11393 (MISSANTHROP\C):
> @0xSigil Will this be made open source at any point?
> date: Tue Sep 22 03:01:29 +0000 2026
> url: https://x.com/valkyr11393/status/2102231782271898023
> ──────────────────────────────────────────────────
>
> @adacyborg11 (ada cyborg (🤖, 🔮)):
> @0xSigil https://t.co/jRMddJNOAE
> PHOTO: https://pbs.twimg.com/media/HSxlGDGawAA-ns7.jpg
> date: Mon Sep 21 22:41:13 +0000 2026
> url: https://x.com/adacyborg11/status/2102166283802517976
> ──────────────────────────────────────────────────
>
> @skcache (Siddhant):
> @0xSigil Wow this is just amazing engineering!
> date: Tue Sep 22 23:30:30 +0000 2026
> url: https://x.com/skcache/status/2102541076213207207
> ──────────────────────────────────────────────────
>
> @jacobpeake (Jacob):
> @0xSigil this is awesome
> date: Tue Sep 22 03:19:26 +0000 2026
> url: https://x.com/jacobpeake/status/2102236302649282615
> ──────────────────────────────────────────────────
>
> @frogggias (Tomas Sustek):
> @0xSigil Can I get an invite, pls?
> date: Tue Sep 22 22:59:41 +0000 2026
> url: https://x.com/frogggias/status/2102533320940859463
> ──────────────────────────────────────────────────
>
> @_aug11_ (a11 from Malibu):
> @0xSigil Holy smokes thats fast!
>
> Keen to try it out
> date: Tue Sep 22 10:44:58 +0000 2026
> url: https://x.com/_aug11_/status/2102348422670074324
> ──────────────────────────────────────────────────
>
> @dellatorna (Dell Torna ▪️▫️◾️◽️):
> @0xSigil This looks awesome. Could I please try a go at it. M4 max 64gb
> date: Tue Sep 22 10:35:43 +0000 2026
> url: https://x.com/dellatorna/status/2102346095267557663
> ──────────────────────────────────────────────────
>
> @sanderjson (Jonathan Sanderson):
> @0xSigil Looks like a fun ecosystem, no surprise your MSI is faster than MLX. Do you have any published results for woof? I would like to test on M1 pro.
> date: Tue Sep 22 08:02:47 +0000 2026
> url: https://x.com/sanderjson/status/2102307610372555179
> ──────────────────────────────────────────────────
>
> @yesadok (Sadok):
> @0xSigil local inference speed is getting absurd
> date: Mon Sep 21 23:05:48 +0000 2026
> url: https://x.com/yesadok/status/2102172472049365177
> ──────────────────────────────────────────────────
>
> @YiCasillas (Yi Casillas):
> @0xSigil 730 tokens/s 这种数字很抓眼，但更有意思的是你们没有把“通用性”当成免费的：知道模型形状后把多步合成一个 kernel，少掉 CPU/GPU 间的来回，才是真正把延迟压下去。
> date: Tue Sep 22 23:09:10 +0000 2026
> url: https://x.com/YiCasillas/status/2102535707319480675
> ──────────────────────────────────────────────────
>
> @zorrobyte (Ross Fisher):
> @0xSigil Where's the GitHub?
> date: Tue Sep 22 00:43:24 +0000 2026
> url: https://x.com/zorrobyte/status/2102197034962899254
> ──────────────────────────────────────────────────
>
> @ShardulAggarwal (Shardul):
> @0xSigil Nice! Congratulations!
> date: Tue Sep 22 22:53:54 +0000 2026
> url: https://x.com/ShardulAggarwal/status/2102531866918302122
> ──────────────────────────────────────────────────
>
> @dragosroua (Dragos Roua):
> @0xSigil I'd love to test this and put up a video on my YT!
> date: Tue Sep 22 02:11:11 +0000 2026
> url: https://x.com/dragosroua/status/2102219127444348994
> ──────────────────────────────────────────────────
>
> @eric_lee (Eric Lee):
> @0xSigil Can I try it please?
> date: Tue Sep 22 09:17:22 +0000 2026
> url: https://x.com/eric_lee/status/2102326376351383731
> ──────────────────────────────────────────────────
>
> @nickyboy (Nick Davis):
> @0xSigil Looks great, could I get an invite please?
> date: Tue Sep 22 08:28:29 +0000 2026
> url: https://x.com/nickyboy/status/2102314076835877333
> ──────────────────────────────────────────────────
>
> @soobrosa (Daniel Molnar):
> @0xSigil would love to give it a whirl
> date: Tue Sep 22 09:06:07 +0000 2026
> url: https://x.com/soobrosa/status/2102323548417401336
> ──────────────────────────────────────────────────
>
> @corysus (Almir):
> @0xSigil Ok, it would be nice to have a bit more detail—are M1, M2, M3, M4 supported, or is this like the recently released engine that mainly supports M5?
> date: Tue Sep 22 07:43:57 +0000 2026
> url: https://x.com/corysus/status/2102302867071623437
> ──────────────────────────────────────────────────
>
> @BackseatVC (Jen):
> @0xSigil Sick!! Congrats Sigil!!
> date: Tue Sep 22 14:35:26 +0000 2026
> url: https://x.com/BackseatVC/status/2102406420704456981
> ──────────────────────────────────────────────────
>
> @KurtFehlhauer (Kurt Fehlhauer):
> @0xSigil I would like to try this on a M5 Max 128GB
> date: Tue Sep 22 16:26:24 +0000 2026
> url: https://x.com/KurtFehlhauer/status/2102434347588723180
> ──────────────────────────────────────────────────
>
> @david_zhang_sf (David Zhang):
> @0xSigil Whoa love this
>
> Will Husky be available for use outside of underdog as well?
> date: Tue Sep 22 02:26:59 +0000 2026
> url: https://x.com/david_zhang_sf/status/2102223099987153296
> ──────────────────────────────────────────────────
>
> @betterclever (Pranjal Paliwal):
> @0xSigil I need an invite!!!
> date: Tue Sep 22 05:40:58 +0000 2026
> url: https://x.com/betterclever/status/2102271919701848179
> ──────────────────────────────────────────────────
>
> @kcwolfy_ (KC):
> @0xSigil No one cares if it's not open source. Sorry.
> date: Tue Sep 22 00:28:58 +0000 2026
> url: https://x.com/kcwolfy_/status/2102193402565599596
> ──────────────────────────────────────────────────
>
> @bhowconda (Abhishek Gahlot):
> @0xSigil Nice stuff , how do i access it
> date: Tue Sep 22 22:35:40 +0000 2026
> url: https://x.com/bhowconda/status/2102527277313749090
> ──────────────────────────────────────────────────
>
> @andrew_n_carr (Andrew Carr 🤸):
> @0xSigil So cool Sigil, really great stuff
> date: Tue Sep 22 15:17:33 +0000 2026
> url: https://x.com/andrew_n_carr/status/2102417020113346612
> ──────────────────────────────────────────────────
>
> @horwath_ryan (Ryan Horwath):
> @0xSigil How bout a M1 PRO!! 32Gs woof woof LFG!!!
> date: Wed Sep 23 00:33:45 +0000 2026
> url: https://x.com/horwath_ryan/status/2102556995303981462
> ──────────────────────────────────────────────────
>
> @tiagoefreitas (Tiago Freitas):
> @0xSigil Finally a use for my 15 Pro can I get an invite?
> date: Tue Sep 22 22:10:18 +0000 2026
> url: https://x.com/tiagoefreitas/status/2102520891636584553
> ──────────────────────────────────────────────────
>
> @SgShreejith (ShreejithSG):
> @0xSigil wud love to get access and try this out at meta @0xSigil
> date: Tue Sep 22 18:12:13 +0000 2026
> url: https://x.com/SgShreejith/status/2102460977853948326
> ──────────────────────────────────────────────────
>
> @UnemployedVip (Unemployed VIP):
> @0xSigil Any chance I can get an invite?
> date: Tue Sep 22 23:29:29 +0000 2026
> url: https://x.com/UnemployedVip/status/2102540821992210466
> ──────────────────────────────────────────────────
>
> @Hawkeswatcher (Hawkes):
> @0xSigil This sounds like malware to me
> date: Tue Sep 22 03:20:05 +0000 2026
> url: https://x.com/Hawkeswatcher/status/2102236466374160402
> ──────────────────────────────────────────────────
>
> @mr_walderman (Brondad):
> @0xSigil I have a few machines I could try this on…
> date: Tue Sep 22 06:48:30 +0000 2026
> url: https://x.com/mr_walderman/status/2102288915462009235
> ──────────────────────────────────────────────────
>
> @roderik (Roderik):
> @0xSigil can i get an invite by any chance?
> date: Tue Sep 22 10:59:30 +0000 2026
> url: https://x.com/roderik/status/2102352082263236684
> ──────────────────────────────────────────────────
>
> @dsllwn (dev):
> @0xSigil can i pls test?
> date: Tue Sep 22 01:41:03 +0000 2026
> url: https://x.com/dsllwn/status/2102211542041387121
> ──────────────────────────────────────────────────
>
> @liangsays (Brent Liang):
> @0xSigil love this!!
> date: Mon Sep 21 22:41:09 +0000 2026
> url: https://x.com/liangsays/status/2102166266861814253
> ──────────────────────────────────────────────────
>
> @rizur1zu (rizu):
> @0xSigil I’d love to test this! M5 pro user here
> date: Tue Sep 22 03:35:12 +0000 2026
> url: https://x.com/rizur1zu/status/2102240268112289888
> ──────────────────────────────────────────────────
>
> @sugardruid (蜜袋魯伊 1128 成為洋流 🌊):
> @0xSigil I need an invite so I can try it on my M2 Pro.
> date: Tue Sep 22 08:27:01 +0000 2026
> url: https://x.com/sugardruid/status/2102313708697661862
> ──────────────────────────────────────────────────
>
> @JonnyD (Jonny D):
> @0xSigil this looks very interesting!
> date: Wed Sep 23 00:14:39 +0000 2026
> url: https://x.com/JonnyD/status/2102552185305239583
> ──────────────────────────────────────────────────
>
> @gamado (gamado):
> @0xSigil Hey, how would I get an invite?!
> date: Tue Sep 22 00:09:54 +0000 2026
> url: https://x.com/gamado/status/2102188604223074792
> ──────────────────────────────────────────────────
>
> @kidgdzilla (James Futhey):
> @0xSigil Ahhh looks so good but I need an invite @underdogdotai #🐶🐶
> date: Tue Sep 22 06:16:46 +0000 2026
> url: https://x.com/kidgdzilla/status/2102280927749783725
> ──────────────────────────────────────────────────
>
> @altryne (Alex Volkov):
> @0xSigil Daaaamn sigil! Let's GO! This is 🔥
> date: Mon Sep 21 23:47:58 +0000 2026
> url: https://x.com/altryne/status/2102183082308911572
> ──────────────────────────────────────────────────
>
> @badhanganesh (Badhan Ganesh 💿):
> @0xSigil Would like to try it out.
> date: Wed Sep 23 02:58:47 +0000 2026
> url: https://x.com/badhanganesh/status/2102593492409266301
> ──────────────────────────────────────────────────
>
> @MgkMshrmBrkfst (SirJaɱzAlot):
> @0xSigil not open-source?
> date: Tue Sep 22 00:37:50 +0000 2026
> url: https://x.com/MgkMshrmBrkfst/status/2102195634912846250
> ──────────────────────────────────────────────────
>
> @indesjyo (花椰菜):
> @0xSigil 你如果能讓Prefill x10倍 而不是decode
> date: Tue Sep 22 22:28:07 +0000 2026
> url: https://x.com/indesjyo/status/2102525376601956487
> ──────────────────────────────────────────────────
>
> @bowtiedkokabura (Kookaburra):
> @0xSigil Can I get an invite to try?
> date: Wed Sep 23 01:25:18 +0000 2026
> url: https://x.com/bowtiedkokabura/status/2102569965455024244
> ──────────────────────────────────────────────────
>
> @aretaidos (Tiger):
> @0xSigil @pmarca Absolutely killing it Sigil damn
> date: Tue Sep 22 09:14:47 +0000 2026
> url: https://x.com/aretaidos/status/2102325729849712832
> ──────────────────────────────────────────────────
>
> @techfezter (techfez):
> @0xSigil Can I get an invite @0xSigil please
> date: Wed Sep 23 01:03:57 +0000 2026
> url: https://x.com/techfezter/status/2102564595076321418
> ──────────────────────────────────────────────────
>
> @fire (🔥 fire):
> @0xSigil can I have an invite?
> date: Tue Sep 22 03:20:26 +0000 2026
> url: https://x.com/fire/status/2102236551971262744
> ──────────────────────────────────────────────────
>
> @ProstateRelaxer (Johnny Bongwater):
> @0xSigil Hopefully I can get an invite for this. Looks insane. I got an M4 Max MacBook Pro
> date: Tue Sep 22 23:38:05 +0000 2026
> url: https://x.com/ProstateRelaxer/status/2102542984554361216
> ──────────────────────────────────────────────────
>
> @RenaudGuerin (Renaud Guérin):
> @0xSigil Need invite !
> date: Tue Sep 22 03:02:25 +0000 2026
> url: https://x.com/RenaudGuerin/status/2102232019774177316
> ──────────────────────────────────────────────────
>
> @AndreaShuyuWang (Andrea Wang):
> @0xSigil !! Exciting!
> date: Tue Sep 22 00:39:17 +0000 2026
> url: https://x.com/AndreaShuyuWang/status/2102195998630248465
> ──────────────────────────────────────────────────
>
> @EsusDev (Esus 💫 🪂):
> @0xSigil can i grab an invite? m2 macbook air
> date: Tue Sep 22 07:52:19 +0000 2026
> url: https://x.com/EsusDev/status/2102304972767641933
> ──────────────────────────────────────────────────
>
> @jeremyrogers82 (Jeremy Rogers):
> @0xSigil Would  love to try it
> date: Wed Sep 23 02:59:58 +0000 2026
> url: https://x.com/jeremyrogers82/status/2102593789655482834
> ──────────────────────────────────────────────────
>
> @s_vidyat (raj):
> @0xSigil Access? Looks great
> date: Tue Sep 22 17:20:57 +0000 2026
> url: https://x.com/s_vidyat/status/2102448074656535000
> ──────────────────────────────────────────────────
>
> @rcx86 (Mr. Rc):
> @0xSigil lfg
> date: Tue Sep 22 01:59:15 +0000 2026
> url: https://x.com/rcx86/status/2102216121193799815
> ──────────────────────────────────────────────────
>
> @zeeshaan_khan (zeeshan):
> @0xSigil Works on m1 ...??
> date: Tue Sep 22 07:16:18 +0000 2026
> url: https://x.com/zeeshaan_khan/status/2102295909984035208
> ──────────────────────────────────────────────────
>
> @liminalsunset_ (limina):
> @0xSigil 4B params, 4-bit, to save the reading.
> date: Wed Sep 23 00:49:38 +0000 2026
> url: https://x.com/liminalsunset_/status/2102560991712252229
> ──────────────────────────────────────────────────
>
> @ian_90211 (Ian ☀️🌴🎥):
> @0xSigil 🤔 &lt;-- Dogs reading this
> date: Tue Sep 22 02:55:10 +0000 2026
> url: https://x.com/ian_90211/status/2102230194534875615
> ──────────────────────────────────────────────────
>
> @sapochat (santi pochat):
> @0xSigil man, everything about this is https://t.co/8O8rNUQ7Ej
> GIF: https://pbs.twimg.com/tweet_video_thumb/HS3l0ZvbkAA3kEu.jpg
> date: Wed Sep 23 02:42:07 +0000 2026
> url: https://x.com/sapochat/status/2102589296830194007
> ──────────────────────────────────────────────────
>
> @tensorquay (TensorQuay):
> @0xSigil Can a Woof fine-tune reuse Husky's kernels if tensor shapes and the 4-bit layout stay the same? That would make local apps easier to maintain: ship new weights without retuning the engine each time.
> date: Tue Sep 22 00:52:04 +0000 2026
> url: https://x.com/tensorquay/status/2102199216311566522
> ──────────────────────────────────────────────────
>
> @Shreyashgg (Shreyash):
> @0xSigil 730 tokens/sec on a MacBook is ABSURD!! Model-shaped Metal megakernels is the cheat code, fuse everything for ONE model instead of running a general engine. Specialize and fly!!
> date: Tue Sep 22 11:02:02 +0000 2026
> url: https://x.com/Shreyashgg/status/2102352717398311152
> ──────────────────────────────────────────────────
>
> @GuidetoMars (🇦🇺Mars 马修 | Markets & Risk):
> 730 tokens per second on a MacBook sounds great, but the benchmark needs a bit more context. Which model, what prompt length, what quantisation, and how much quality drops under a real workload?
> Local inference is getting much better. I’m still more interested in whether people can run useful agents for hours without the machine turning into a small heater.
> date: Tue Sep 22 12:15:11 +0000 2026
> url: https://x.com/GuidetoMars/status/2102371125015769423
> ──────────────────────────────────────────────────
>
> @R2R_Capital (Relax_to_Rich):
> @0xSigil Big gains in single‑machine local inference speed make offline private AI far more practical.
> date: Tue Sep 22 07:38:27 +0000 2026
> url: https://x.com/R2R_Capital/status/2102301486365724684
> ──────────────────────────────────────────────────
>
> @dralcymarjunior (Dr. Alcymar Monteiro Júnior):
> @0xSigil Can I get an invitation? 👀 https://t.co/3s4Lf0CNIo
> GIF: https://pbs.twimg.com/tweet_video_thumb/HSx3BQmWYAI2guo.jpg
> date: Mon Sep 21 23:59:33 +0000 2026
> url: https://x.com/dralcymarjunior/status/2102185999669305628
> ──────────────────────────────────────────────────
>
> @m_awawdi (mo):
> @0xSigil Looks incredible! Can I get an invite? I'm on an M1 Pro 16GB.
> date: Tue Sep 22 22:51:43 +0000 2026
> url: https://x.com/m_awawdi/status/2102531314641711599
> ──────────────────────────────────────────────────
>
> @N_Rikhil (Remiscus):
> @0xSigil 1.9k bookmarks tells you what you need to know haha, i am one of them
> date: Tue Sep 22 23:26:31 +0000 2026
> url: https://x.com/N_Rikhil/status/2102540074886008971
> ──────────────────────────────────────────────────
>
> @boyang_xie (Boyang & YUP):
> @0xSigil that's crazy fast... 😑 https://t.co/PRZB8jo6ZG
> PHOTO: https://pbs.twimg.com/media/HSx86HjawAAjtD8.png
> date: Tue Sep 22 00:25:26 +0000 2026
> url: https://x.com/boyang_xie/status/2102192512446394714
> ──────────────────────────────────────────────────
>
> @mckaox (MK):
> @0xSigil Very exciting! Can you give out more invites? Thank you
> date: Tue Sep 22 23:05:49 +0000 2026
> url: https://x.com/mckaox/status/2102534864725778705
> ──────────────────────────────────────────────────
>
> @SeahScy (Shaun Seah):
> @0xSigil Yooo how can I get in? Am bullish on personal AI. What a crazy life story though @0xSigil
> date: Wed Sep 23 02:38:36 +0000 2026
> url: https://x.com/SeahScy/status/2102588412209586246
> ──────────────────────────────────────────────────
>
> @siddythingsx (siddy):
> @0xSigil 730 tok/s on a MacBook is actually fucking cracked 😭 local AI is moving DIFFERENT
> date: Tue Sep 22 05:45:03 +0000 2026
> url: https://x.com/siddythingsx/status/2102272946333200766
> ──────────────────────────────────────────────────
>
> @haritn (Harit Nanavati):
> @0xSigil Need an invite please!!
> date: Tue Sep 22 06:44:59 +0000 2026
> url: https://x.com/haritn/status/2102288030166089730
> ──────────────────────────────────────────────────
>
> @MrBrjan (Brjan | AI Builder):
> @0xSigil speed is great, but usability across different hardware still needs focus
> date: Tue Sep 22 04:10:19 +0000 2026
> url: https://x.com/MrBrjan/status/2102249107243119063
> ──────────────────────────────────────────────────
>
> @zeekzok (ZeekZok):
> @0xSigil @jundotkim
> date: Wed Sep 23 02:13:35 +0000 2026
> url: https://x.com/zeekzok/status/2102582118668734464
> ──────────────────────────────────────────────────
>
> @Tooniiiibm (Foluwatooni 🐂):
> @0xSigil @iruletrenches a loyal Nigerian is pitching this to you early
> date: Tue Sep 22 00:51:31 +0000 2026
> url: https://x.com/Tooniiiibm/status/2102199077765017629
> ──────────────────────────────────────────────────
>
> @jaredyu999 (Jared Yu 启正):
> @0xSigil Hi can I get an invite to test on an M2 MBP? Awesome work btw, looking to see local LLMs really take off, woof woof!
> date: Tue Sep 22 22:57:29 +0000 2026
> url: https://x.com/jaredyu999/status/2102532767720657194
> ──────────────────────────────────────────────────
>
> @zacforristall (Zac Forristall):
> @0xSigil 🥵 invite requested!
> date: Wed Sep 23 00:45:43 +0000 2026
> url: https://x.com/zacforristall/status/2102560004075401640
> ──────────────────────────────────────────────────
>
> @matt__makes (Matt):
> @0xSigil ok beating MLX with per-model kernels is impressive
> date: Tue Sep 22 10:53:43 +0000 2026
> url: https://x.com/matt__makes/status/2102350626105520420
> ──────────────────────────────────────────────────
>
> @kdpisda (Kuldeep Pisda):
> @0xSigil The speedup is bought per model, which is the whole question. If a new release takes weeks of hand tuning to reach the same curve, 4.5x is a property of Woof rather than of the engine.
> date: Tue Sep 22 09:04:26 +0000 2026
> url: https://x.com/kdpisda/status/2102323121579827503
> ──────────────────────────────────────────────────
>
> @zkevinbai (Kevin Bai):
> @0xSigil Very interesting!
> date: Mon Sep 21 22:47:39 +0000 2026
> url: https://x.com/zkevinbai/status/2102167903626052010
> ──────────────────────────────────────────────────
>
> @vijaykodam (Vijay Kodam):
> @0xSigil Looks too good to be true. I tried Splash, an open-source inference engine from Inco AI and I was disappointed when I ran it in my Mac Mini M4 Pro with 64 GB. I hope your claims hold true in real world. Can I get an invite?
> date: Tue Sep 22 05:01:14 +0000 2026
> url: https://x.com/vijaykodam/status/2102261921353249001
> ──────────────────────────────────────────────────
>
> @ericzeng_builds (Eric Zeng):
> @0xSigil so how does this work? we download a desktop app and it runs models locally on your device? 
>
> Can I run this on an M2?
> date: Tue Sep 22 01:31:42 +0000 2026
> url: https://x.com/ericzeng_builds/status/2102209187879309312
> ──────────────────────────────────────────────────
>
> @VeytharX (Veythar):
> @0xSigil bro the real number isn't 4.5x, it's that speculative decoding on your own weights just became a checkbox feature. every local model ships this in 6 months
> date: Mon Sep 21 23:22:14 +0000 2026
> url: https://x.com/VeytharX/status/2102176607607693583
> ──────────────────────────────────────────────────
>
> @ASIHubHQ (ASI Hub):
> @0xSigil debugging distributed tensor parallelism at 3am vibes ✨🐾 https://t.co/koN9Oik1ez
> VIDEO: https://pbs.twimg.com/amplify_video_thumb/2102402624356052992/img/tuBEK6AayJGdFusc.jpg
> date: Tue Sep 22 14:20:30 +0000 2026
> url: https://x.com/ASIHubHQ/status/2102402663283667267
> ──────────────────────────────────────────────────
>
> @Tooniiiibm (Foluwatooni 🐂):
> @0xSigil @skrootimburg good morning Ogo Agbaye
> date: Tue Sep 22 00:51:55 +0000 2026
> url: https://x.com/Tooniiiibm/status/2102199175219687927
> ──────────────────────────────────────────────────
>
> @jaddsoo (Heyoo (Building @cohands_ai)):
> @0xSigil i am running 60token/s under MLX, will this be 3x faster?
> date: Wed Sep 23 01:43:47 +0000 2026
> url: https://x.com/jaddsoo/status/2102574619064725931
> ──────────────────────────────────────────────────
>
> @dhaneshpurohit (Dhanesh Purohit):
> @0xSigil Would love an invite
> date: Tue Sep 22 17:17:32 +0000 2026
> url: https://x.com/dhaneshpurohit/status/2102447214186611185
> ──────────────────────────────────────────────────
>
> @dcsan (˗ˏˋ DC ˎˊ˗):
> @0xSigil Impressive jump on device. Seeing the kernel consolidation pay off big time
> date: Tue Sep 22 12:09:20 +0000 2026
> url: https://x.com/dcsan/status/2102369652806648067
> ──────────────────────────────────────────────────
>
> @ipriyanshu12 (Priyanshu Sharma):
> @0xSigil This looks amazing! Loved the website and can't wait to give it a try!!
> date: Tue Sep 22 02:38:47 +0000 2026
> url: https://x.com/ipriyanshu12/status/2102226071018226025
> ──────────────────────────────────────────────────
>
> @akasharora777 (akash arora):
> @0xSigil Woof woof, looking for an invite please!!
> date: Tue Sep 22 02:23:01 +0000 2026
> url: https://x.com/akasharora777/status/2102222105287012770
> ──────────────────────────────────────────────────
>
> @joshimanoj1 (manoj joshi):
> @0xSigil @pmarca Would love an invite
> date: Mon Sep 21 23:45:48 +0000 2026
> url: https://x.com/joshimanoj1/status/2102182538680951101
> ──────────────────────────────────────────────────
>
> @pengjianqing (pengjianqing):
> @0xSigil Want to try on MacBook Pro M5
> date: Wed Sep 23 01:15:40 +0000 2026
> url: https://x.com/pengjianqing/status/2102567542892245418
> ──────────────────────────────────────────────────
>
> @AdityaDtwt (Aditya 🍻):
> @0xSigil Does the model-specific Metal kernel need to be regenerated for every new architecture, or can most of it be reused?
> date: Tue Sep 22 11:21:35 +0000 2026
> url: https://x.com/AdityaDtwt/status/2102357637664800912
> ──────────────────────────────────────────────────
>
> @Levi_Researcher (Levi):
> @0xSigil Hardcoding for specific shapes is the only way to squeeze real utility out of local metal. How much overhead does this add for new models?
> date: Mon Sep 21 22:57:37 +0000 2026
> url: https://x.com/Levi_Researcher/status/2102170414344777862
> ──────────────────────────────────────────────────
>
> @Jeffvr3n (Jeff):
> @0xSigil https://t.co/BA0sJY2c6v
> date: Tue Sep 22 00:04:13 +0000 2026
> url: https://x.com/Jeffvr3n/status/2102187172707139630
> ──────────────────────────────────────────────────
>
> @ndilipkumar_ (Dilip):
> @0xSigil That looks blazing fast. 
> Would love to try this out.
> date: Tue Sep 22 04:40:02 +0000 2026
> url: https://x.com/ndilipkumar_/status/2102256582692340121
> ──────────────────────────────────────────────────
>
> @himanshustwts (himanshu):
> @0xSigil this is super cool! now i am on the hunt for an underdog invite @underdogdotai
> date: Tue Sep 22 22:56:40 +0000 2026
> url: https://x.com/himanshustwts/status/2102532560354205771
> ──────────────────────────────────────────────────
>
> @Aureum128 (Aureum):
> @0xSigil @earnyourmac
> date: Wed Sep 23 00:22:24 +0000 2026
> url: https://x.com/Aureum128/status/2102554138156683299
> ──────────────────────────────────────────────────
>
> @AaronNewmanReal (Aaron Newman):
> @0xSigil I would love to try this! may I please have an invite 🙏
> date: Tue Sep 22 21:14:47 +0000 2026
> url: https://x.com/AaronNewmanReal/status/2102506922242892138
> ──────────────────────────────────────────────────
>
> @proxy_vector (Rohan):
> @0xSigil What precision is Husky running at by default to hit 730 tokens per second on a MacBook?
> date: Mon Sep 21 23:15:37 +0000 2026
> url: https://x.com/proxy_vector/status/2102174943983345900
> ──────────────────────────────────────────────────
>
> @GEVS94 (Gabriel Vasquez):
> @0xSigil Nice!
> date: Mon Sep 21 22:49:39 +0000 2026
> url: https://x.com/GEVS94/status/2102168408984838364
> ──────────────────────────────────────────────────
>
> @Kautukkundan (Kautuk | Conscious Engines):
> @0xSigil @pmarca Amazing! Had been working on similar stuff, this blows my mind.
> date: Mon Sep 21 23:14:48 +0000 2026
> url: https://x.com/Kautukkundan/status/2102174738659594348
> ──────────────────────────────────────────────────
>
> @alber70g (Albertoo):
> @0xSigil Can someone do this on top of MTPLX for Qwen3.8 Flash Next? Maybe @Youssofal_ @MTPLX
> date: Tue Sep 22 07:28:47 +0000 2026
> url: https://x.com/alber70g/status/2102299050066239964
> ──────────────────────────────────────────────────
>
> @OlDirty56 (Jay🌎):
> @0xSigil Check your x money sir
> date: Tue Sep 22 00:12:55 +0000 2026
> url: https://x.com/OlDirty56/status/2102189361588732254
> ──────────────────────────────────────────────────
>
> @walderfugue (Walder):
> @0xSigil @pmarca Would love to get an invite!
> date: Tue Sep 22 00:19:59 +0000 2026
> url: https://x.com/walderfugue/status/2102191140715831316
> ──────────────────────────────────────────────────
>
> @magdouss (tacoshi):
> @0xSigil chaton fat got competition
> date: Tue Sep 22 03:02:53 +0000 2026
> url: https://x.com/magdouss/status/2102232137164546329
> ──────────────────────────────────────────────────
>
> @Hahabumlol (llllllll):
> @0xSigil @pmarca  look at ur xmoney
> date: Mon Sep 21 23:04:14 +0000 2026
> url: https://x.com/Hahabumlol/status/2102172078837277156
> ──────────────────────────────────────────────────
>
> @jehovahscript (jacob ۞):
> @0xSigil this is sick
> date: Mon Sep 21 23:06:16 +0000 2026
> url: https://x.com/jehovahscript/status/2102172590848811332
> ──────────────────────────────────────────────────
>
> @238 (238):
> @0xSigil @pmarca call @3i please.
> date: Mon Sep 21 22:45:06 +0000 2026
> url: https://x.com/238/status/2102167260945060216
> ──────────────────────────────────────────────────
>
> @SmartestVicky (Vigneswaran ):
> @0xSigil Unable to DM you, I need an invite to get access to this
> date: Tue Sep 22 04:13:10 +0000 2026
> url: https://x.com/SmartestVicky/status/2102249824133534162
> ──────────────────────────────────────────────────
>
> @_alphashark_ (_alphashark_):
> @0xSigil model-specific speed doesn’t make local models equally capable. unsupported ops can hit slower fallbacks on newer architectures.
> date: Tue Sep 22 00:57:13 +0000 2026
> url: https://x.com/_alphashark_/status/2102200512028590355
> ──────────────────────────────────────────────────
>
> @Jeffvr3n (Jeff):
> @0xSigil @pmarca Will make an X com for this
> date: Mon Sep 21 23:51:45 +0000 2026
> url: https://x.com/Jeffvr3n/status/2102184033782202636
> ──────────────────────────────────────────────────
>
> @yasoobkhalid (Yasoob Khalid 💡):
> @0xSigil So is the model custom as well or just the inference layer? Also, would love an invite!
> date: Tue Sep 22 00:28:19 +0000 2026
> url: https://x.com/yasoobkhalid/status/2102193237335359922
> ──────────────────────────────────────────────────
>
> @withdhyan (dhyān):
> @0xSigil love this! can I get an invite?
> date: Tue Sep 22 05:02:13 +0000 2026
> url: https://x.com/withdhyan/status/2102262168909725700
> ──────────────────────────────────────────────────
>
> @de__gods (de gods):
> @0xSigil frank has too much motion u guys are drones
> date: Mon Sep 21 23:06:43 +0000 2026
> url: https://x.com/de__gods/status/2102172703687885173
> ──────────────────────────────────────────────────
>
> @Pol_Lanski (Pol Lanski 🥩,🤖):
> @0xSigil Can I has invite?
> date: Tue Sep 22 03:37:17 +0000 2026
> url: https://x.com/Pol_Lanski/status/2102240791477506546
> ──────────────────────────────────────────────────
>
> @genericgoodguy (ObedientSon):
> @0xSigil git repo or forget it
> date: Tue Sep 22 13:42:48 +0000 2026
> url: https://x.com/genericgoodguy/status/2102393174862016987
> ──────────────────────────────────────────────────
>
> @katiekirsch (Katie Kirsch):
> @0xSigil lfg!
> date: Tue Sep 22 06:29:46 +0000 2026
> url: https://x.com/katiekirsch/status/2102284199650869474
> ──────────────────────────────────────────────────
>
> @marodq (Mario A. Rodríguez):
> @0xSigil Hi! This looks awesome. Can I please get an invite?
> date: Mon Sep 21 23:58:25 +0000 2026
> url: https://x.com/marodq/status/2102185713705922990
> ──────────────────────────────────────────────────
>
> @arXivBangers (arXiv Bangers):
> @0xSigil @pmarca Banger
> date: Tue Sep 22 03:37:37 +0000 2026
> url: https://x.com/arXivBangers/status/2102240877964136660
> ──────────────────────────────────────────────────
>
> @conjibz (ⓙⓘⓑⓞⓢⓢ):
> @0xSigil please give me an invite!!!
> date: Tue Sep 22 23:22:28 +0000 2026
> url: https://x.com/conjibz/status/2102539055690907956
> ──────────────────────────────────────────────────
>
> @Concerned_Cit25 (Chris):
> @0xSigil would anyone be up for inviting me to underdog? @underdogdotai
> date: Tue Sep 22 01:23:51 +0000 2026
> url: https://x.com/Concerned_Cit25/status/2102207215201567078
> ──────────────────────────────────────────────────
>
> @nivek133144 (Nivek):
> @0xSigil You cannot sell the Robinhood one. Do not buy
> date: Mon Sep 21 23:46:30 +0000 2026
> url: https://x.com/nivek133144/status/2102182716061974575
> ──────────────────────────────────────────────────
>
> @biff_buster (Biff Buster):
> @0xSigil @pmarca Roaring twenties &amp; thirties
> date: Mon Sep 21 23:14:00 +0000 2026
> url: https://x.com/biff_buster/status/2102174537215545484
> ──────────────────────────────────────────────────
>
> @HiCagr (high cagr):
> @0xSigil Wow
> date: Mon Sep 21 22:44:19 +0000 2026
> url: https://x.com/HiCagr/status/2102167064425455869
> ──────────────────────────────────────────────────
>
> @Sergizzzz4 (Sergizz):
> @0xSigil Does is supports macbook M1/M2 ser asking for a friend
> date: Tue Sep 22 08:46:58 +0000 2026
> url: https://x.com/Sergizzzz4/status/2102318729501852153
> ──────────────────────────────────────────────────
>
> @muzi93040929 (mu zi):
> @0xSigil m3 ultra want a invite
> date: Tue Sep 22 08:58:31 +0000 2026
> url: https://x.com/muzi93040929/status/2102321635370189272
> ──────────────────────────────────────────────────
>
> @3i (3):
> @0xSigil @pmarca call me
> date: Mon Sep 21 22:40:46 +0000 2026
> url: https://x.com/3i/status/2102166172972048402
> ──────────────────────────────────────────────────
>
> @FiFiFetTSaCk (🍩🍩🍩 Fieser Fettsack):
> @0xSigil Waitlist…
> date: Wed Sep 23 02:28:08 +0000 2026
> url: https://x.com/FiFiFetTSaCk/status/2102585779977441367
> ──────────────────────────────────────────────────
>
> @jevidon (Jevi):
> @0xSigil @pmarca Someone DM me an invite pls.
> date: Tue Sep 22 02:06:45 +0000 2026
> url: https://x.com/jevidon/status/2102218010044043446
> ──────────────────────────────────────────────────
>
> @plutoemas (ikan laut):
> @0xSigil this is very interesting
> date: Tue Sep 22 02:41:18 +0000 2026
> url: https://x.com/plutoemas/status/2102226703863136549
> ──────────────────────────────────────────────────
>
> @samuelekpe (Samuel Ekpe):
> @0xSigil @AndreaShuyuWang Nice
> date: Tue Sep 22 00:25:56 +0000 2026
> url: https://x.com/samuelekpe/status/2102192638548144430
> ──────────────────────────────────────────────────
>
> @verma_mle (Verma):
> @0xSigil Cool stuff 👌
> date: Tue Sep 22 22:04:16 +0000 2026
> url: https://x.com/verma_mle/status/2102519373730570558
> ──────────────────────────────────────────────────
>
> @arceliik (arçelik):
> @0xSigil @pmarca check ur x money ma nig
> date: Mon Sep 21 23:09:20 +0000 2026
> url: https://x.com/arceliik/status/2102173359354028213
> ──────────────────────────────────────────────────
>
> @sukiwr (s):
> @0xSigil 🔥
> date: Mon Sep 21 22:41:11 +0000 2026
> url: https://x.com/sukiwr/status/2102166276453835168
> ──────────────────────────────────────────────────
>
> @TimOnSol_ (timonsol 🐂🀄️):
> @0xSigil this is gonna be so fcking huge
>
> I think the community is loving it
> date: Mon Sep 21 23:10:31 +0000 2026
> url: https://x.com/TimOnSol_/status/2102173661012607125
> ──────────────────────────────────────────────────
>
> @pixeL_laugh (JessePinkman 🦇🔊):
> @0xSigil send invite
> date: Tue Sep 22 02:55:09 +0000 2026
> url: https://x.com/pixeL_laugh/status/2102230188054499395
> ──────────────────────────────────────────────────
>
> @jimmycooked888 (Jimmy):
> @0xSigil Ayo invite?
> date: Wed Sep 23 00:42:17 +0000 2026
> url: https://x.com/jimmycooked888/status/2102559142204559437
> ──────────────────────────────────────────────────
>
> @watchereth_ (Watcher):
> @0xSigil Yes please
> date: Tue Sep 22 15:32:34 +0000 2026
> url: https://x.com/watchereth_/status/2102420798225195485
> ──────────────────────────────────────────────────
>
> @FlippingProfits (profit | eca.eth):
> @0xSigil call me right now
> date: Tue Sep 22 00:22:21 +0000 2026
> url: https://x.com/FlippingProfits/status/2102191734755148236
> ──────────────────────────────────────────────────
>
> @TheCyberverse (Celestine):
> @0xSigil Wowowow. coool
> date: Tue Sep 22 07:23:26 +0000 2026
> url: https://x.com/TheCyberverse/status/2102297707612352746
> ──────────────────────────────────────────────────
>
> @villainmonkey (sahil):
> @0xSigil LFG
> date: Tue Sep 22 00:31:45 +0000 2026
> url: https://x.com/villainmonkey/status/2102194103924695216
> ──────────────────────────────────────────────────
>
> @kushagraladdha3 (kl):
> @0xSigil https://t.co/rI9wMUPM4g
> GIF: https://pbs.twimg.com/tweet_video_thumb/HSxl6aVaoAAG8-J.jpg
> date: Mon Sep 21 22:44:48 +0000 2026
> url: https://x.com/kushagraladdha3/status/2102167187133997282
> ──────────────────────────────────────────────────

