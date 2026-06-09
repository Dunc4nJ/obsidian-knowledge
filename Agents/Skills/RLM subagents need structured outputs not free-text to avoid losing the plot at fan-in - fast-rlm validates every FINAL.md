---
created: 2026-06-09
description: AVB shows a max-depth=1 RLM fail on a NarrativeQA long-context question when 62 subagents return free-text summaries, then succeed at the same token budget when subagents are forced to return JSON-Schema-validated booleans — fast-rlm treats schema validation on every FINAL() as a first-class harness primitive that converts subagent fan-out into an attention mask over the parent's REPL context.
source: https://x.com/neural_avb/status/2063907440509571354
type: pattern
---

# RLM subagents need structured outputs not free-text to avoid losing the plot at fan-in - fast-rlm validates every FINAL

![[neural_avb-571354-001.jpg]]

## Key Takeaways

- **The free-text fan-out failure mode is the textbook RLM antipattern.** AVB hits a classic [[RLMs inline intelligence into data pipelines by giving LLMs symbolic access to DataFrames in a persistent REPL|RLM]] pattern on a NarrativeQA sample (107K-char *Coxon Fund*, "What is Saltram's living situation?"): the root chunks the context, fans out 62 free-text sub-agents, then asks a reducer to aggregate prose summaries. The reducer drowns in 62 variations of "this excerpt does not describe Saltram's home", the root can't cleanly read the return values (they keep printing into context), and the model eventually *hand-writes* a wrong answer claiming Saltram lives "alone in a set of chambers in shabby-genteel London" — when the correct answer (he's the Mulvilles' permanent house-guest at Wimbledon) was never extractable by keyword search in the first place. Same total tokens (~$0.04 Minimax-M3), wrong answer.

- **Replace prose with a JSON-Schema-constrained boolean and the same fan-out succeeds.** Second run on the identical context uses `schema={"type": "boolean"}` on each per-chunk subagent ("does this chunk contain info about Saltram's living situation, T/F?") and the root just reads `relevant_chunks = [chunks[i] for i, r in enumerate(results) if r]`. AVB's framing: *"the booleans acted as a direct attention mask to the original context — external sparsification of the input prompt."* This is the operational core of the post: structured outputs aren't an ergonomics nicety, they convert subagent traffic from English-to-be-parsed into a discriminator over the parent's working set, which is what an RLM was supposed to do all along.

- **The harness developer's job is to make life easy for models inside the REPL — until labs train models inside RLM harnesses natively.** AVB calls out the current asymmetry explicitly: today, models work inside RLM REPLs *purely through in-context learning of RLM patterns and raw programming skill*, so harness-level affordances (schema validation, retry-don't-restart, contract display at REPL startup) are load-bearing scaffolding. This mirrors [[Quarq Labs frames GEPA and RLM as complementary context layers - GEPA optimizes static prompts before inference while RLM decomposes context at runtime|Quarq's framing]] of context management as the new product surface and [[predict-RLM uses GEPA to recursively optimize agent skills reaching SpreadsheetBench top-5 as open source|predict-RLM's recursive GEPA loop]] — both treat the *harness* as the optimizable unit while waiting for labs to internalize the patterns. Same intuition behind [[HALO uses an RLM to mine harness-shaped failures from agent execution traces and lift benchmarks 10-16 percentage points|HALO's harness-shaped failure mining]].

- **fast-rlm's validation primitive is four steps: normalize, contract-display, validate-on-FINAL, retry-don't-restart.** (1) Schema normalization accepts Pydantic models, primitives (`int`), generics (`list[Model]`), or raw JSON Schema dicts — all converted via `model_json_schema()` / `TypeAdapter` / lookup. (2) At step 0 the agent sees the JSON Schema before writing any code. (3) Every `FINAL(answer)` call validates the value against the schema *before* returning to the calling agent; the TypeScript snippet shows the feedback contract: full schema + per-error path/message + "fix the value and call FINAL again." (4) On failure the REPL state is preserved — the agent only re-calls FINAL, it doesn't lose the work it already did. This last property — *retry-don't-restart* — is what makes structured outputs cheap enough to demand them by default. Direct ancestor of the [[DSPy is a framework for programming—not prompting—language models through typed signatures and metric-driven optimizers|DSPy Signatures]] approach the author explicitly credits in-thread.

- **The contract is enforced only at the root by default, but the model can demand schemas from its own subagents at runtime.** AVB's reply to @AkramShehadi clarifies the autonomy story: the user can pin an output contract on the root agent, but the *subagent* schemas in the Saltram example were chosen by the RLM itself — boolean schema, prose schema, list[Model] — *the RLM decides at runtime what shape its children should return*. The system prompt encourages schemas wherever possible, but the library exposes schema-specifying-power to the model as a first-class capability. This is the runtime-decomposition layer that [[Quarq Labs frames GEPA and RLM as complementary context layers - GEPA optimizes static prompts before inference while RLM decomposes context at runtime|Quarq frames]] as complementary to static prompt optimization — every fan-out is a typed contract the model negotiates with itself.

## External Resources

- [fast-rlm on GitHub](https://github.com/avbiswas/fast-rlm) — AVB's TypeScript RLM library with the schema-validated FINAL primitive
- [Original RLM blog by Alex Zhang](https://alexzhang13.github.io/blog/2025/rlm/) — the foundational primer the article links as background reading
- [LongBench / NarrativeQA](https://github.com/THUDM/LongBench) — long-context benchmark the Saltram sample comes from; "What is Saltram's living situation?" is one of the harder lookup-resistant samples
- [Henry James, *The Coxon Fund*](https://en.wikipedia.org/wiki/The_Coxon_Fund) — 1894 novella, ~107K characters, the test corpus

## Original Content

> @neural_avb (AVB) — 2026-06-08 08:54 UTC
> https://x.com/neural_avb/status/2063907440509571354
>
> *Cover image*
> ![[neural_avb-571354-001.jpg]]
>
> 📰 RLM Agents live healthier when they talk via Structured Outputs
>
> We got one goal today: understand one of the common failure modes of Recursive Language Models, and a simple cool way to reduce it.
>
> Recursive Language Models (RLMs) let a model answer questions over a context far larger than its window by treating the prompt as a variable inside a Python REPL.
>
> If you are unfamiliar with RLMs, I'll encourage to read this article first that covers how RLM works and how it differs from other beloved techniques, like ReAct, CodeAct, and vanilla subagents.
>
> *[Embedded tweet: https://x.com/i/status/2035040781074145412]*
>
> The agent writes code to search, slice, and chunk the text, and can recursively spawn sub-agents over the pieces. The subagent answers come back inside the REPL values, i.e. the responses are never auto-dumped into the parent's context directly.
>
> > Spawning swarms of subagents to divide and conquer a task is super cool! But RLM traces make or break depending on its capability of prompting subagents correctly about:
>
> (a) what it should do,
> (b) what it should return back, and
> (c) how the main agent aggregates the subagent responses into a final response.
>
> As the big labs begin to train their models inside RLM harnesses, I am sure we will see language models naturally evolve to do these tasks inside an REPL in an efficient way. But currently, models work inside an REPL purely thorough in-context learning of RLM patterns and raw programming skill.
>
> In other words, its the harness developer's job to make life as easy as possible for language models inside an RLM.
>
> ## We hit all those problems on one LongBench / NarrativeQA sample:
>
> Context: the full ~107K-character text of Henry James's The Coxon Fund. Basically its a story book.
>
> Question: "What is Saltram's living situation?" (Saltram is a character in this story)
>
> Correct answer: "He is a guest in the home of the Mulvilles."
>
> The truth is never said outright. Across the novel, the character Frank Saltram is the permanent house-guest ("inmate") of the Mulvilles at their Wimbledon home.
>
> Why is this a skill-check task for long-context models?
>
> > This fact you only actually get by reading and connecting. Not by keyword lookup.
>
> > The literal token "Saltram" often appears nowhere near the passages that actually describe where he lives.
>
> ## How a RLM could solve such long-context tasks
>
> When the RLM is presented a problem, one of it's first goal is to decide whether to attack the problem head-on, or deploy subagents.
>
> > Attacking head-on would mean the model would try to slice and dice various sections of the input context itself, print out these sections in its own REPL and figure out the answer.
>
> > Deploying subagents would mean it will create shorter slices of the original context, get them to solve partial problems, and then aggregate their findings into one coherent response. Divide and Conquer
>
> One way that an RLM can solve the Saltram problem is actually attacking it head on and do it inside a depth-0 REPL.
>
> ```python
> # step 1: locate Saltram, read windows
>
> for m in re.finditer(r'Saltram', context):
>     print(context[max(0, m.start()-500): m.end()+500])
> # the print statement loads these chunks into the LM's context
>
> ...
>
> # step 3: the windows mention the Mulvilles -> follow that thread
> for m in re.finditer(r'Mulville', context):
>     print(context[max(0, m.start()-200): m.end()+800])
>
> # steps 5–10
> for term in ['lodging', 'lived', 'house', 'guest', 'stayed', 'winter', 'slippers', 'inmate']:
>     ... # chase every living-situation term the text actually uses
> ...
>
> summary = """Frank Saltram has no home of his own.
> He lives as a long-term,
> semi-permanent house-guest
> — explicitly described as an "inmate" —
> of the Mulvilles at their home in Wimbledon"""
> FINAL(summary)
> ```
>
> That is the correct answer, it costs ~$0.04 with Minimax M3. And it would work. The model will search and slice contexts around key data points and just read those relevant sections!
>
> But what if the RLM went for a subagent approach?
>
> # Subagents v1: Free-text fan-out (the failure)
>
> In this first instance, the agent's instinct was a textbook RLM move: chunk the context and map a sub-agent over each chunk, then reduce. This is one of the common patterns that almost every RLM system prompt has, so its not at all an invalid option.
>
> It split the ~107K characters into fixed-size chunks and fanned out **free-text** sub-agents in parallel, then asked one more to aggregate the responses! Very cool, but there is an issue you will soon see:
>
> ```python
> summaries = await batch_llm_query(*[
>     llm_query(
>         {
>          "task": "From this excerpt of Henry James's 'The Coxon Fund'"
>                  "extract facts about Saltram's living situation "
>                  "Reply with 2-4 concise bullet points only."
>          "excerpt": c
>         }
>     )
>     for c in chunks
> ])
> ```
>
> Then it delegated a second LM to resolve the answer:
>
> ```python
> final_response = await llm_query(
>     {"task": "Aggregate these per-excerpt observations"
>              "about Saltram's living  situation into one coherent"
>              "summary. Keep it under 300 words.",
>      "summaries": summaries},
> )
> ```
>
> Pretty simple technique. Spawn a swarm (of 62 subagents) to analyze multiple regions of the context and then get another agent to summarize it. But something bad happened:
>
> Here are some of the responses it got back from those 62 subagents:
>
> - sub2: "The passage does NOT contain direct verbatim quotes describing Saltram's living situation."
>
> - sub4: "The text does not contain any sentences describing where Saltram lives. Mrs. Saltram is mentioned only in passing…"
>
> - sub5: "The provided text excerpt does not contain any passages about Saltram's home, her 'set of chambers', or where she lives."
>
> - sub0, sub1, sub3: ...
>
> The result?
>
> > The second subagent got confused because it had 62 responses to classify, and all of them were text-based. I ran a max-depth=1 RLM, so at the second level, the subagents aren't allowed to spawn newer agents.
>
> What followed was a long flail — the root couldn't cleanly read the sub-agent's return (it kept printing), and eventually it just **hand-wrote** an answer:
>
> ```python
> final_answer_text = """In Henry James's "The Coxon Fund,"
> Saltram lives alone in "a set of chambers"
> in a shabby-genteel part of London ...
> attended only by a single servant ... a once-promising
> man of letters now living in genteel poverty."""
>
> FINAL(final_answer_text)
> ```
>
> > It did a bunch of things but none of it worked. This is not the correct answer. It got overwhelmed with the 62 subagents' short answers.
>
> If only instead of free-form text, subagents were forced to return a structured response.
>
> # Subagents v2: Structured outputs routing (success)
>
> The second run did fan out, but used structured output to do it cleanly.
>
> Instead of asking sub-agents for prose ("describe his living situation"), it asked each one a True/False question with a JSON-Schema-constrained answer, then read the chunks that said True.
>
> ```python
> # step 1: chunk the whole context
>
> chunk_size = 5000 #Arbitrary chunk size
> chunks = [
>     context[i:i+chunk_size]
>     for i in range(0, len(context), chunk_size)
> ]
>
> # step 2: ONE boolean sub-agent per chunk, in parallel, with a schema
> tasks = [
>     llm_query(
>         {"task": "Does this chunk contain information about Saltram's living "
>                  "situation (where he lives, his home, residence, household)? "
>                  "Answer True or False for relevance."
>          "chunk_id": i, "context": chunk},
>         schema={"type": "boolean"}
>     )
>     for i, chunk in enumerate(chunks)
> ]
>
> results = await batch_llm_query(*tasks)  # parallel; one batch
> relevant_chunks = [chunks[i] for i, r in
>     enumerate(results) if r
> ]
>
> answer = await llm_query({
>    "Aggregate these per-excerpt observations about Saltram's living "
>      "situation into one coherent summary "
>      "Chunks are present chronologically"
>      "Keep it under 300 words.",
>      "summaries": relevant_chunks},
> }
> )
>
> print(relevant_chunks)
> ```
>
> This may look very similar, but if you squint, there is one MAJOR MAJOR thing that happened here:
>
> ```python
> tasks = [
>     llm_query(
>         {"task": ...
>          "chunk_id": i, "context": chunk},
>         schema={"type": "boolean"} # <--- this
>     )
>     ....
> ]
> ```
>
> In the `fast-rlm` library, the structured I/O works in a simple way. When a subagent (or main agent) receives a schema request, we validate that the response it is sending back to the main agent perfectly adheres to the schema. No exceptions.
>
> *[Embedded tweet: https://x.com/i/status/2057046821709721945]*
>
> > You can do more complex schema as well containing nested lists and objects (anything you can define in zod or pydantic), and the library puts a validation to ensure that the schema is always satisfied.
>
> So now, instead of the model trying to parse a 40 variations of: No mention of Saltram's living condition in this paragraph, it can just directly look at this one boolean flag and make everything stick!
>
> Lower chances of hallucination because the model never had to read way too much of the story into it's context at once!
>
> ```python
> final_answer = (
>     "Saltram was a resident 'inmate' of the Mulvilles — "
>     "a married couple, Adelaide and Mr. Mulville — "
>     "whose comfortable home served "
>     "as a kind of 'temple of talk' ... "
> )
> FINAL(final_answer)
> ```
>
> Verdict: correct!
>
> ![[neural_avb-571354-002.jpg]]
>
> > In the first no-subagent depth-0 approach and this depth-1 approach, we effectively used an equivalent amount of tokens. In fact both cost around ~0.04$ with Minimax-M3
>
> > But the scope of hallucination is much reduced in the subagent approach since you are not looking at large bodies of unrelated confounding text! Low powered reasoning models are totally capable of losing the plot when they read too many tokens all at once.
>
> > The booleans acted as a direct attention mask to the original context! External sparsification of the input prompt!
>
> Note: boolean schema is just an example that the RLM picked here. In theory, an agent can pick any schema requirements. They all get validated and ensured before passing back!
>
> # Validating structured output inside RLMs
>
> To wrap up, I'll mention how the structured output stuff is implemented inside RLMs.
>
> ![[neural_avb-571354-003.jpg]]
>
> *Caption: Structured Out mode is not just for main agents to call their subagents! The user can also enforce this contract with the root agent.*
>
> 1. Schema normalization (Python)
>
> You/agents can pass the desired output schema: Pydantic model, a primitive type like `int`, a `list[Model]` generic, or a raw JSON Schema dict. We convert all that to a plain JSON Schema (`model_json_schema()` for Pydantic, a `TypeAdapter` for generics, a lookup for primitives).
>
> 2. The agent is shown the contract at REPL startup
>
> At step 0, before any of the agent's work begins we display the desired JSON schema to the agent. So the model knows the exact shape it must return before it writes any code.
>
> 3. Validate on every `FINAL`
>
> When an LLM calls FINAL(answer) inside the REPL, we take the content of answer and return it from the subagents back to its calling agent. But juuuuust before we return the answer, we do a schema validation check!
>
> ```typescript
> if (validate && !validate(result)) {
>     const feedback =
>         `FINAL value failed schema validation. ...\n` +
>         `Required JSON Schema:\n${schemaStr}\n\n` +
>         `Validation errors:\n${formatValidationErrors(validate)}\n\n` +   // path + message per error
>         `Fix the value and call FINAL again. "
> }
> ```
>
> If the validation passes, we return the result to the main agent as expected. But if it fails, we send a feedback to the current agent telling the exact format validation errors, and the expected format it must enforce.
>
> 4. Retry, don't restart
>
> On failure the agent receives the schema *and* the specific errors (e.g. `(root): must be boolean`). The REPL work is untouched, so the model just needs to fix the value and re-calls `FINAL`
>
> We validate again and approve if schema matches!
>
> Just by this simple validation mechanism, RLMs can unlock a whole new dimension to operate. Passing exact contract requirements to subagents which can be used directly inside the REPL.
>
> Check out the fast-rlm repo here: https://github.com/avbiswas/fast-rlm

---

> @LeopolisDream (Alex Yanko 🇺🇦) — 2026-06-08 10:29 UTC
> https://x.com/LeopolisDream/status/2063931370175426893
>
> @neural_avb This was also implemented in Agentica framework from Semantica

---

> @neural_avb (AVB) — 2026-06-08 10:33 UTC *(author self-reply)*
> https://x.com/neural_avb/status/2063932479480975807
>
> @LeopolisDream Nice! I'd also credit DSPy for most ideas I have had on Signatures. Its an actual school of thought.

---

> @AkramShehadi (Akram Shehadi) — 2026-06-08 13:45 UTC
> https://x.com/AkramShehadi/status/2063980862622802029
>
> This is really interesting.
>
> But I am not sure I understood, do you have to tell the RLM what structure to use as output contract? Or is that something it decided somehow?
>
> I.e. did you tell it to use true/false statements to evaluate living situations, so that the fan out would use that?

---

> @neural_avb (AVB) — 2026-06-08 14:08 UTC *(author self-reply)*
> https://x.com/neural_avb/status/2063986518876958895
>
> In this specific case, I did not ask anything specifically. This behavior is explained in the sys prompt and the models are encouraged to use schemas wherever possible. It decided on its own to do this.
>
> But a bunch of things at play here:
> 1. You can tell the RLM an output contract. This contract is however ONLY enforced for the root agent (not its subagents)
>
> 2. You can write additional instructions in the task description that nudges the root agents to use structured outs when it deploys subagents
>
> 3. In general, the RLM decides with its own intelligence what the best course of action is. Whether you mention it or not. The library gives it the power to call subagents and specify target schema.

---

> @0xQuantCat (Quant Cat) — 2026-06-08 15:44 UTC
> https://x.com/0xQuantCat/status/2064010589723034068
>
> Really interesting direction. One thing I'd love to see quantified, when does this child-agent routing become cost-effective vs normal retrieval/long-context?
>
> Especially for full token + latency breakdown, break-even by doc size chunk count, whether children can run on cheaper models, the schema retry rate or whether outputs include source spans, not just summaries?
>
> My hunch is that the win is less "child text" and more "typed child outputs as evidence routers"

---

> @neural_avb (AVB) — 2026-06-08 15:51 UTC *(author self-reply)*
> https://x.com/neural_avb/status/2064012370821918888
>
> @0xQuantCat This is what I am curious about too.
>
> Sadly, in most cases the answer seems to be model dependent as well as task dependent. Making the ablation quite expensive to run.
>
> Every model needs its own RLM prompt if I am being honest coz it is heavily doing ICL when it runs.
