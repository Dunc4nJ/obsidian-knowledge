---
created: 2026-09-20
source: https://x.com/trycua/status/2101437979180904640
author: Cua (@trycua)
published: 2026-09-19
type: knowledge
tags: [jev, computer-use, gui-agents, cua, system-one-models, typesafe, form-filling, agent-loops]
description: Cua (Dillon, @ddupont808, and Francesco, @francedot) describes a computer-use loop where application code builds a menu of allowed actions with IDs, a text-only decision model picks one, and Cua Driver executes it - plus CUA-S1-FORMS, a 706,048-parameter form specialist adapted from jevlike that hands control back to the general agent on an unexpected dialog or a failed check rather than on a confidence threshold.
---

# Cua keeps the candidate menu in application code so Jev only picks an ID - CUA-S1-FORMS is a 706K-parameter form specialist at 99.7 percent against hosted Jev's 83.6, and neither model sees pixels

## Key Takeaways

- **The article's real contribution is a boundary, not a model: the candidate menu lives in application code, and the model returns an ID.** In an LLM-driven loop the model generates a tool call and its arguments; in Cua's `jev-use` recipe "those actions and arguments already exist in application code; Jev selects an ID," so it "can't invent tools, coordinates or arguments." That is a validatable surface, and Cua is honest that it buys less than it looks like: it "doesn't remove the hard work of building good candidates or noticing when the page has changed underneath you." This is the same loop [[LangChain's Sydney Runkle puts Jev inside the agent loop as classifier middleware - ModelRouterMiddleware picks the model from the latest user message and AutoModeMiddleware reproduces closed harnesses' dangerous-action gate|Kyle Jeong's Browserbase build]] ran a week earlier at $0.001 per task - observe the page, send the accessibility tree as state and the available actions as questions, model picks, Stagehand executes - with Cua Driver swapped in for Stagehand. Cua's addition is the fallback for interfaces with no accessibility tree at all.

- **Neither model sees pixels, and the perception step Cua would need to fix that is the one part it has not built.** "Jev and our current CUA-S1-FORMS model are text-only. Neither looks at pixels." Where a browser exposes DOM or accessibility information the app feeds that structured state straight through, which is the easy case. For a bare screenshot Cua sketches Microsoft's OmniParser as the missing perception step - text recognition, UI region detection, icon descriptions, out come bounding boxes with interactivity flags - and then withdraws: "This is an architecture we want to explore, not an OmniParser integration we're shipping here." So the headline promise of the section title, screenshots becoming choices, is a diagram and not a running system. It also relocates the bottleneck, as Cua concedes: parsing "adds its own latency," and "a missed control or a bad label can spoil the decision before scoring even starts." If a parser or a VLM has to find the elements first, the decision model is only the selector and the front half owns the cost. The vault's prior art on the state representation this replaces is [[Stagehand's six-layer browser harness—security, caching, identity, credential brokering, skills, and filesystem—is what separates production browser agents from raw-CDP demos]] and [[Browserbase's bb agent generalizes knowledge work through four building blocks - sandbox, credential-brokering proxy, loadable skills, and Slack]].

- **CUA-S1-FORMS dodges Jev's 255-option cap by never asking an N-way question.** The model is 706,048 trainable parameters, about 2.8 MB, and it scores each form element *independently* in a batch across four outcomes - use this supplied value, check, click, or skip - with code deciding execution order. That is one 4-way decision per element rather than one choice over every control on the page, so the cardinality ceiling [[Annabell frames TypeSafe's Jev as a savant for eval verdicts and routing - three question types, 255 choices, 10 score levels, and a Noul with no confidence field|Annabell documents at 255 options]] never binds. The article never mentions that cap, never says how long a `jev-use` candidate list may get, and never addresses context rot on a page with hundreds of clickable elements. Architecture derived from [[jevlike]], which Dillon "adapted ideas and code from" - and it inherits jevlike's open gap, stated outright: "it doesn't reproduce TypeSafe's calibration work."

- **The hand-back trigger is an event, not a confidence number, and Cua says so deliberately.** Control returns to the LLM-driven planner on "an unexpected dialog or a failed check" - things that happen after execution, observed by application code. Cua then closes the loop on the obvious objection: "Knowing when a specialist is out of its depth is itself a hard problem, and a high score alone isn't an answer to it." Read against [[Daniel Ch's How to master Jev prescribes a 0.85 and 0.55 confidence-gate ladder under an LLM that still writes - the decision-layer architecture is additive but every number and all three charts are TypeSafe's own|Daniel Ch's 0.85 and 0.55 confidence-gate ladder]] this is the more defensible design, because nothing has ever calibrated the numbers those gates would read: [[Sutro's jev-align uses GEPA to rewrite Jev's decision criteria from five labeled examples - the demo moves labeled-set ambiguity 49.6 points but full-pool certainty only 0.5|jev-align moves pool certainty, not calibration]], [[Featherless's Simple Jev reproduces Jev's API on stock open models by remapping every answer to a single-token letter and softmaxing only those logits - no classifier head, and the code stamps every answer calibrated False|Simple Jev stamps every answer calibrated False]], and [[LangChain's Jev-as-a-Judge bench puts Jev's quality-score variance 92 to 913x below three LLM judges at $0.34 against Claude's $28.17 - five weather traces, one human oracle, provider-default sampling|the Jev-as-a-Judge bench never measured calibration either]]. The cost of Cua's choice is that the system only learns it was wrong after it has already clicked. [[BARGAIN routes classification to a small model via a confidence threshold calibrated on 500 oracle labels, cutting costs up to 86 percent more than competing cascades]] is the version that earns a threshold with 500 oracle labels and a distribution-free guarantee.

- **The skeptic's read: two numbers in the prose, both Cua's own and both disclaimed, and the only end-to-end comparisons are burned into video overlays.** Dillon's head-to-head reports 99.7% decision accuracy for the specialist against 83.6% for hosted Jev - on a task the specialist was trained for, "including the convention of skipping already-filled fields," against a Jev that "was not fine-tuned for it." Timing is 7-9 ms local against 260-280 ms hosted, which Cua immediately concedes measures a forward pass against a network round trip. There is no OSWorld run, no VLM-agent baseline, no end-to-end task success rate and no cost per task anywhere in the text. What does exist is locked inside two silent demo videos: a 2048 side-by-side at Jev 44.9 s and ~$0.00108 API-equivalent against Astra 294.9 s and ~$1.45, and a forms race where the specialist finishes the target form, completes a whole second form and submits it inside 11.2 seconds while the LLM agent, credited with 23 tool turns over 39.6 s total, has not yet filled one field. Those are the article's most striking figures and not one of them appears in a sentence, a table, or a caption - they are burned into video overlays, unqualified by any narration, which is exactly where a vendor's least-defensible comparisons tend to end up. Compare the honesty of the framing to [[TypeSafe's Jev trades string generation for parallel-sampled typed decisions with calibrated probabilities at $0.042 per MTok - the 193x and 444x claims come from four self-built workflow evals|TypeSafe's own launch post]]: Cua is a vendor announcing its own model, and it still spends more words on what the result is not than on what it is.

## How a Screenshot Becomes a Choice Set

The section title oversells what is built. Cua describes three cases, and only the first is shipped.

**Case 1, structured state exists.** "If a browser or app exposes useful DOM or accessibility information (AX), the application can use that structured state directly." Nothing perceptual is needed. This is the path `jev-use` actually runs, and it is the same state representation Kyle Jeong used at Browserbase.

**Case 2, only a screenshot exists.** A text-only decision model cannot read it, so a perception step has to come first. Cua's worked example is [Microsoft's OmniParser](https://github.com/microsoft/OmniParser), which "combines text recognition, UI region detection and icon descriptions to turn a screenshot into structured elements: bounding boxes, recognized text or icon descriptions, and an indication of interactivity." Cua is explicit that this is illustrative: "This is an architecture we want to explore, not an OmniParser integration we're shipping here. Our form specialist would still need an adapter to its expected inputs and evaluation on the parsed output." The figure itself carries the disclaimer in its footer: *Illustrative UI and boxes, not an OmniParser inference result.*

**Case 3, vision-capable general model.** "A vision-capable general-purpose model can take a screenshot directly" - noted as the alternative, not pursued.

The step Cua stresses is the one between perception and decision, and it belongs to application code, not to either model:

> The boxes aren't the decision space on their own. The application still has to decide which actions are allowed, attach any supplied values and give each candidate an ID. A text-only model can then score those choices. If it selects the Save candidate, the application resolves that ID back to the current target, validates it, clicks, and checks the new state. The model doesn't need the screenshot to make that particular choice; it needs a useful description of what's on it.

Two independent failure modes follow, and Cua names both: perception can miss a control or mislabel one, spoiling the decision before scoring starts, and parsing adds latency to every step of the loop. The upside Cua claims is that "perception and decision-making can improve independently."

On whether the model sees pixels, the article is unambiguous twice over. From the primitives section: Jev "doesn't take screenshots today, so anything visual has to become text before it reaches the model." From this section: "Jev and our current CUA-S1-FORMS model are text-only. Neither looks at pixels." That matches what the vault already recorded about the [[TypeSafe's Jev trades string generation for parallel-sampled typed decisions with calibrated probabilities at $0.042 per MTok - the 193x and 444x claims come from four self-built workflow evals|Doom demo running on structured text state rather than images]], and it is the line [[Featherless's Simple Jev reproduces Jev's API on stock open models by remapping every answer to a single-token letter and softmaxing only those logits - no classifier head, and the code stamps every answer calibrated False|Simple Jev crosses only on hosted Gemma and Qwen]], not in its open reference server.

## The Cua Driver Loop

**There is no code in this article.** No fenced block, no snippet, no configuration, no API signature, no model version string. The loop is described in prose and drawn in one figure. Everything below is that description.

The five-step loop, as the figure numbers it:

1. **The app's state and choices.** The application observes state and builds a short list of allowed candidates, each with an ID. The figure's worked example is three: `A Fill the name field`, `B Click Continue`, `C Open country list`.
2. **Model scores each choice.** The candidate list goes to the model, which returns a score per option. The figure shows A highest.
3. **App validates.** `A allowed here?` - the application resolves the ID back to the action it predefined and checks the selection is legal at this point.
4. **Cua Driver executes** one real action.
5. **Observe and check.** `landed?` - fresh state comes back and feeds step 1 again.

The footer of that figure states the constraint the whole design rests on: *A score is not proof of success.* The prose puts it the same way: "Calibration describes how predictions behave across many examples, not whether this particular click was right, so the application still has to look."

**`jev-use`** is the artifact. It is "a public-preview integration recipe with examples connecting hosted TypeSafe Jev to Cua Driver," living at [`trycua/cua/tree/main/libs/cua-driver/examples/jev-use`](https://github.com/trycua/cua/tree/main/libs/cua-driver/examples/jev-use). It ships two paths: a deterministic mock, and a live path taking your own TypeSafe API key. Cua is careful about what the mock demonstrates - "The mock proves the loop wiring, not live model behavior" - and about what `jev-use` is not: "It isn't a new model living inside Driver." Driver executes actions in either setup and is not the decision-maker.

No latency or cost per step is stated for this loop. The only numbers attached to it live in the 30-second demo video, which races two 2048 boards at 9.90x playback under the captions `Jev · 44.9s · ~$0.00108 API-equiv.` and `Astra · 294.9s · ~$1.45 API-equiv.` - roughly 1,300x on cost and 6.6x on wall-clock, for a game rather than a browser workflow, with no methodology given for what "API-equiv." prices. Sampling the clip makes the gap concrete: by 7.5 seconds Jev's board is already marked done and stops changing, and it is still pixel-identical at 22.5 seconds while Astra is only then reaching a 32 tile. The video is silent, so there is no narration qualifying any of it. Treat it as a demo artifact, not a measurement. The baseline named there is the same [[GPT-6 Astra swaps Codex compaction for notes across context windows plus searchable earlier windows including tool outputs|GPT-6 Astra]] the vault already tracks.

## CUA-S1-FORMS

**What it is.** CUA-S1 is Cua's "research family of small, independent specialist models," and CUA-S1-FORMS is the first member. Dillon "adapted ideas and code from [jevlike](https://github.com/vinnylarouge/jevlike) and trained an independent form specialist." Two negations are stated outright: "It's not a fine-tune of Jev, and it doesn't reproduce TypeSafe's calibration work." So the scores it emits are an uncalibrated softmax over a small option-attention head, exactly the gap [[jevlike]] leaves open.

| Property | Value |
| --- | --- |
| Trainable parameters | 706,048 |
| Original checkpoint | about 2.8 MB |
| Inputs | structured form elements plus values already extracted from a document |
| Outputs | per element: use this supplied value, check, click, or skip |
| Scoring | elements scored independently in a batch; code decides execution order |
| Licence | MIT - source, weights and synthetic dataset all public |
| Scope | "English-centric forms research prototype" |

**What it cannot do**, in Cua's words: "It can't invent values, read screenshots or navigate an unfamiliar app." And it does not do the front half of the work - "The specialist starts with the form elements and supplied values; it doesn't do the work of interpreting the original request or extracting those values." A general LLM would do that as a separate part of the system.

**The two measured claims, with Cua's own qualifications attached.**

| Measure | Specialist | Hosted Jev | Cua's qualification |
| --- | --- | --- | --- |
| Overall decision accuracy on the form task | 99.7% | 83.6% | Specialist "trained for exactly this task, including the convention of skipping already-filled fields," hosted Jev "was not fine-tuned for it." "A decision-level result from a narrow experiment, not a general computer-use benchmark." |
| Per-decision timing | 7-9 ms local form scoring | 260-280 ms per hosted call including network | "Those measure different boundaries... They aren't a controlled model-speed comparison, and they aren't end-to-end form completion times." |

Both are described as Dillon's "initial" numbers. Neither is independently replicated, and the 83.6% figure is a comparison against a general model on a task with a convention it was never told about, which is closer to a demonstration that fine-tuning helps than to a model-quality result.

The 15-second demo video carries the only end-to-end contrast, and it is worth watching rather than glancing at. A split screen puts `Jev-like model + cua-driver (one pass, 50 ms cursor glide)` against `LLM agent + cua-driver only (23 tool turns, 39.6 s total)`, both starting on the same Northwind Clinic new-patient registration form. At 3.7 seconds the two panes are indistinguishable, every field still empty. At 11.2 seconds the right pane has not filled a single field, while the left has completed Northwind Clinic, moved to a second form, an Acme Robotics job application, filled every field, checked both attestation boxes, left the optional referral code blank, clicked Submit, and logged `SUBMITTED 11:31:31.838`.

That frame is also the clearest illustration in the whole article of what the four-way decision actually looks like in practice: type the supplied value, check, click, and - visibly, on the optional referral field - skip. The caption still disclaims the comparison, and it should: *This shows one form workflow, not a controlled benchmark.* The video is silent, with no audio track, so nothing in it qualifies the numbers burned into the window titles.

## Hand-Back Rules

This is the article's most reusable content. The full policy, verbatim:

> Faster decisions don't fix missing perception, stale state, a bad candidate menu or long-horizon planning. A computer-use agent needs a usable representation of the interface, a way to notice the page has moved on, and a way to confirm an action landed.

> The handoff we'd like to explore goes like this. A general-purpose LLM interprets the request and plans the unfamiliar parts: getting to the form, working out what information is needed, recovering when something unexpected appears. It could also extract values from a document or generate text when the task calls for it. Once the decisions become familiar and narrow, the agent delegates to a specialist. Application code enforces constraints, executes, and checks. An unexpected dialog or a failed check returns control to the LLM-driven planner.

> This is a direction, not a unified system we've shipped. Knowing when a specialist is out of its depth is itself a hard problem, and a high score alone isn't an answer to it.

Reduced to rules:

- **The general LLM owns** request interpretation, planning the unfamiliar parts, getting to the form, working out what information is needed, recovery from the unexpected, value extraction from documents, and any text generation.
- **Delegate to the specialist** only "once the decisions become familiar and narrow."
- **Application code, not either model, owns** constraint enforcement, execution, and checking the result.
- **Hand back on either of two events**: an unexpected dialog, or a failed check. The figure labels the two edges `EXPECTED · next familiar choice` (stay with the specialist) and `UNEXPECTED · back to the general agent`.
- **Do not hand back on a score.** Stated explicitly: a high score alone is not an answer to whether the specialist is out of its depth.

The last rule is the one worth carrying elsewhere. Jev [[Annabell frames TypeSafe's Jev as a savant for eval verdicts and routing - three question types, 255 choices, 10 score levels, and a Noul with no confidence field|cannot abstain and emits no rationale]], so a threshold on its output is a threshold on a number that carries no "I don't know" and that nobody has validated against outcomes. Cua's answer is to detect the failure downstream in application code instead. The cost is latency to detection: the click happens first.

## What Cua Wants Next

Cua asks for workflows rather than listing them:

> Forms gave us a bounded task to test. We'd like to hear where else this approach would be worth trying.

The selection criterion is stated precisely, and it is the useful part: "a repetitive computer or browser workflow where the context changes every run but the choices stay narrow." Cua bounds it on both sides - "Sometimes the right answer is still a script: if a rule is stable and explicit, write the rule. The interesting middle is where context varies from run to run but the choices stay narrow enough to score." Submissions go to hello@trycua.com and feed "future CUA-S1 specialists."

On the System One framing, Cua declines to adopt TypeSafe's marketing. It grants the Kahneman analogy as "useful for framing the engineering question" and then stops: "it isn't a taxonomy of models. An LLM isn't automatically System Two, and a small model can make a snap decision that's wrong. Classifiers, rankers and learned policies have made bounded decisions for decades, and Jev didn't invent any of them. What it adds is an accessible decision interface." That is a more sober reading than any of the other Jev writeups in this folder, [[pg-jev|the launch post included]].

## Replies

Four replies retrieved against a reply count of seven on the host tweet. Two are substantive, and no one from TypeSafe responded. Nobody challenged the 99.7 against 83.6 number, the 706,048-parameter figure, or the claim that neither model reads pixels.

- **Vlad Terin ([@VladTerin](https://x.com/VladTerin/status/2101452007429017870))** is the only reply engaging the methodology, and he endorses precisely the disclaimer Cua attached to its timings: "Glad you separated model timing from end-to-end completion. Warm-up and planner handoffs still matter a lot in my Jev/Codex adapter." He is building a Jev adapter for Codex and links a demo, saying current computer and browser use is "a tad slow" with improvement available in "cutting the subagent handoff time to warm up time and improving the loop itself." That is independent corroboration from a second implementer that the handoff, not the decision, is where the wall-clock goes - which is the same conclusion the OmniParser caveat points at from the perception side.

- **Hekmon ([@hhkkmon](https://x.com/hhkkmon/status/2101475211426283709))** draws the inference Cua leaves implicit: "for computer use, i can totally see tiny local models doing Jev-like decisions — maybe just tens or hundreds of MB." CUA-S1-FORMS is already an order of magnitude below that guess at about 2.8 MB, which is the strongest available argument that this class of specialist runs on the same machine as the browser and pays no network round trip at all.

The other two replies are non-substantive: a generic agreement and a promotional quote-tweet.

## Related

- [[TypeSafe's Jev trades string generation for parallel-sampled typed decisions with calibrated probabilities at $0.042 per MTok - the 193x and 444x claims come from four self-built workflow evals]] - the launch post Cua is responding to, and the source of the 255-option and pricing numbers
- [[LangChain's Sydney Runkle puts Jev inside the agent loop as classifier middleware - ModelRouterMiddleware picks the model from the latest user message and AutoModeMiddleware reproduces closed harnesses' dangerous-action gate]] - its Community Examples section carries Kyle Jeong's Browserbase plus Stagehand build, the closest prior art to this loop
- [[Annabell frames TypeSafe's Jev as a savant for eval verdicts and routing - three question types, 255 choices, 10 score levels, and a Noul with no confidence field]] - the 255-option cap, the no-abstain limitation, and context rot
- [[Daniel Ch's How to master Jev prescribes a 0.85 and 0.55 confidence-gate ladder under an LLM that still writes - the decision-layer architecture is additive but every number and all three charts are TypeSafe's own]] - the confidence-threshold hand-back Cua declines to use
- [[Sutro's jev-align uses GEPA to rewrite Jev's decision criteria from five labeled examples - the demo moves labeled-set ambiguity 49.6 points but full-pool certainty only 0.5]] - prompt optimization against a decision boundary, and the calibration question it sidesteps
- [[LangChain's Jev-as-a-Judge bench puts Jev's quality-score variance 92 to 913x below three LLM judges at $0.34 against Claude's $28.17 - five weather traces, one human oracle, provider-default sampling]] - the benchmark that measured variance and cost but never calibration
- [[Featherless's Simple Jev reproduces Jev's API on stock open models by remapping every answer to a single-token letter and softmaxing only those logits - no classifier head, and the code stamps every answer calibrated False]] - the hosted-only vision path, and calibration declared absent in the return value
- [[moc - Jev]] - map of this folder
- [[jevlike]] - the option-attention starter model CUA-S1-FORMS adapted its ideas and code from
- [[jev-align]], [[pg-jev]], [[simple-jev]] - resource notes for the surrounding ecosystem
- [[Stagehand's six-layer browser harness—security, caching, identity, credential brokering, skills, and filesystem—is what separates production browser agents from raw-CDP demos]] - what a production browser harness needs beyond the decision step
- [[Browserbase's bb agent generalizes knowledge work through four building blocks - sandbox, credential-brokering proxy, loadable skills, and Slack]] - Kyle Jeong's architecture writeup for the same class of agent
- [[E2B Desktop Sandbox]] - the adjacent computer-use sandbox, which names cua
- [[BARGAIN routes classification to a small model via a confidence threshold calibrated on 500 oracle labels, cutting costs up to 86 percent more than competing cascades]] - a confidence threshold with an actual statistical guarantee behind it
- [[GPT-6 Astra swaps Codex compaction for notes across context windows plus searchable earlier windows including tool outputs]] - the baseline named in the 2048 demo overlay
- [[Open models now match closed frontier models on core agent harness tasks at a fraction of the cost]] - the broader small-model-substitution case
- [[separating cognitive blueprints from runtime engines enables portable auditable agent systems]] - the same split between a deciding layer and a deterministic executing layer

## Original Content

> [!quote]- Jev, System One models, and the future of computer use - Cua (@trycua), 2026-09-19
>
> **Host tweet**: [x.com/trycua/status/2101437979180904640](https://x.com/trycua/status/2101437979180904640) - 2026-09-19 22:27 UTC - 163 likes / 12 retweets / 7 replies / 162 bookmarks / 4 quotes / 18,477 views
> **Article id**: 2101428314472849408
>
> # Jev, System One models, and the future of computer use
>
> *What we've been building with decision models at Cua - by* @ddupont808 and @francedot
>
> Over the last few days we've deprioritized some other shiny objects because we've all been *Jev-crazy*. TypeSafe released [Jev](https://typesafe.ai/blog/introducing-system-one-models-and-jev), which they call a [System One model](https://docs.typesafe.ai/concepts/system-one). We were wondering how many decisions inside a computer-use agent actually need a general-purpose LLM.
>
> *Title slide of the embedded three-slide deck: "Jev / System One / Computer use", byline "Dillon & Francesco / Cua"*
> ![[trycua-904640-001.jpg]]
>
> In a typical LLM-driven agent, a general-purpose model, such as one from the GPT or Claude families, interprets the user's request and decides what to do next. It can make a plan, generate text or code, and produce tool calls for the surrounding software to execute. When something unexpected happens, the agent can give it the new state and ask it to reconsider. That flexibility is useful when the task isn't fully specified in advance.
>
> Think about what happens once that agent reaches a form. Getting there can involve planning, exploration, and recovery when a page doesn't behave. The decisions on the form itself are much more local. Does this value from the document belong in this field? Is that checkbox already checked? Should this element be left alone? One way to answer them is to ask the LLM to generate another tool call. We wanted to see what changes when a model only has to score choices the application already defined.
>
> **The question for us is how much of the workflow needs that general-purpose flexibility.** A specialist won't write a missing explanation, figure out an unfamiliar process or recover from every failure. But it might handle a recurring decision without another full LLM call.
>
> ## What Jev returns
>
> Jev takes text as input, including structured text such as JSON describing the current state, and returns a typed decision rather than generated prose or code. TypeSafe's [primitives](https://docs.typesafe.ai/primitives) come in three shapes:
>
> - [Choice](https://docs.typesafe.ai/primitives/choice) picks one of the options you supply.
> - [Score](https://docs.typesafe.ai/primitives/score) rates something against descriptive levels you define.
> - [Noul](https://docs.typesafe.ai/primitives/noul) estimates a probability for a yes/no question.
>
> General-purpose LLMs can also choose from a list and return structured outputs or tool calls. The difference isn't simply JSON versus prose. Jev exposes a decision interface rather than an open-ended text-generation interface: you supply the context and the decision to make, and receive a typed result.
>
> It's tempting to read that as action selection for agents, but the interface is more general. Routing a request, ranking candidates, deciding whether a condition holds: those are all decisions over bounded choices, and none of them requires controlling a computer. Jev can sit inside a coding workflow and pick the next tool to call, though it won't write the patch. It also doesn't take screenshots today, so anything visual has to become text before it reaches the model.
>
> The loop we care about looks like this. The application observes state and builds a short list of allowed candidates. The model scores them. The application validates the selection, executes it through [Cua Driver](https://github.com/trycua/cua/tree/main/libs/cua-driver), and then observes fresh state to check what actually happened.
>
> *Slide 01/03, "A decision inside a loop": APPLICATION builds state and choices (A Fill the name field, B Click Continue, C Open country list); MODEL scores each choice with A highest; app validates "A allowed here?"; Cua Driver executes one real action; observe and check "landed?"; new state returns to step 1. Footer: "A score is not proof of success."*
> ![[trycua-904640-002.jpg]]
>
> **A score is not proof the action worked.** Calibration describes how predictions behave across many examples, not whether this particular click was right, so the application still has to look.
>
> ## How a screenshot becomes a set of choices
>
> **Jev and our current CUA-S1-FORMS model are text-only.** Neither looks at pixels. A vision-capable general-purpose model can take a screenshot directly, but a text-only decision model needs a representation it can read. If a browser or app exposes useful DOM or accessibility information (AX), the application can use that structured state directly. But what about an interface where all you have is a screenshot?
>
> [Microsoft's OmniParser](https://github.com/microsoft/OmniParser) is a useful example of the missing perception step. It combines text recognition, UI region detection and icon descriptions to turn a screenshot into structured elements: bounding boxes, recognized text or icon descriptions, and an indication of interactivity. Application code can use that output to identify possible controls and build candidates. It still has to work out, for example, whether the word "Save" belongs to a clickable button.
>
> *"VISUAL PARSING - From screenshots to choices": a screenshot of example.com/settings with an Email field, an Email updates checkbox and a Save button numbered 1-3, mapped through "Parser: regions + labels" to APP-DEFINED CANDIDATES (1 Email field / type supplied value, 2 Email updates / leave unchecked, 3 Save / click when ready). Pipeline strip: Screenshot to Parser to App builds choices to Text-only model. Footer: "Illustrative UI and boxes, not an OmniParser inference result."*
> ![[trycua-904640-003.jpg]]
>
> The boxes aren't the decision space on their own. The application still has to decide which actions are allowed, attach any supplied values and give each candidate an ID. A text-only model can then score those choices. If it selects the Save candidate, the application resolves that ID back to the current target, validates it, clicks, and checks the new state. The model doesn't need the screenshot to make that particular choice; it needs a useful description of what's on it.
>
> This separation is interesting to us because perception and decision-making can improve independently. It also gives us another place to be wrong: a missed control or a bad label can spoil the decision before scoring even starts, and parsing adds its own latency. This is an architecture we want to explore, not an OmniParser integration we're shipping here. Our form specialist would still need an adapter to its expected inputs and evaluation on the parsed output.
>
> ## About the System One name
>
> TypeSafe's framing nods to the distinction Daniel Kahneman popularized between fast, intuitive thinking and slower, deliberate thinking. We find the analogy useful for framing the engineering question, but we'd stop there: *it isn't a taxonomy of models*. An LLM isn't automatically System Two, and a small model can make a snap decision that's wrong. Classifiers, rankers and learned policies have made bounded decisions for decades, and Jev didn't invent any of them. What it adds is an accessible decision interface: hand over context and choices, get back a decision the application can use directly.
>
> ## Why agent loops raise the question now
>
> When a model is called once, latency and cost are a line item. When it's called at every step of a browser workflow, a person watching the agent feels every pause, and you start noticing how much of the work is generation and how much is choosing among things the application could already do.
>
> Sometimes the right answer is still a script: if a rule is stable and explicit, write the rule. The interesting middle is where context varies from run to run but the choices stay narrow enough to score. We spent the last few days on two experiments in that middle.
>
> *Slide 02/03, "jev-use and CUA-S1": JEV-USE is an Integration recipe on Hosted TypeSafe Jev - decides "Next action from candidates", acts via "Cua Driver observes and acts", model "Hosted, called by the recipe". CUA-S1 is Specialist models, first model CUA-S1-FORMS - decides "Structured form decisions", acts via "The app orders the actions", model "Independent, trained by Cua".*
> ![[trycua-904640-004.jpg]]
>
> ## Using Jev with Cua Driver
>
> [jev-use](https://github.com/trycua/cua/tree/main/libs/cua-driver/examples/jev-use) is a **public-preview integration recipe** with examples connecting hosted TypeSafe Jev to Cua Driver. The application builds concrete candidate actions from the current browser state, each with an ID. Jev chooses an ID. The application resolves it back to the action it predefined, validates it, and asks Driver to execute. Then it observes the page again and verifies.
>
> *jev-use in action: the app builds candidate actions, Jev selects one, and Cua Driver executes it. The app then checks the updated page.*
>
> *Video 1, 30 s, 1920x1080, silent - the file carries a single H.264 video stream and no audio track at all, so there is no narration to transcribe. Two 4x4 2048 boards run side by side at 9.90x playback under the standing captions `Jev · 44.9s · ~$0.00108 API-equiv.` and `Astra · 294.9s · ~$1.45 API-equiv.` Neither number appears anywhere in the article text. Source: [1920x1080 mp4](https://video.twimg.com/amplify_video/2101433474888380416/vid/avc1/1920x1080/HeES_ziPdbVYMw8O.mp4?tag=29)*
>
> *Frame at 7.5 s (25%): Jev's board already reads `Jev · done · 44.9s · ~$0.00108 API-equiv.` and holds 16/8/4, 8/2/4, 16/4, 8/2. Astra's board is still sparse at 16, 4, 2, 2/2 and carries no done marker.*
> ![[trycua-904640-005.jpg]]
>
> *Frame at 22.5 s (75%): Jev's board is pixel-identical to the 7.5 s frame, frozen since it finished. Astra is still playing, having reached a 32 tile alongside 2/2/32/16 on the top row. At 9.90x playback the specialist's entire run is over inside the first quarter of the clip while the general agent grinds on for the remaining three.*
> ![[trycua-904640-006.jpg]]
>
> In an LLM-driven loop, the model might generate a tool call and its arguments. In this recipe, those actions and arguments already exist in application code; Jev selects an ID. It can't invent tools, coordinates or arguments. Keeping the candidate menu in code gives us a boundary we can validate, though it doesn't remove the hard work of building good candidates or noticing when the page has changed underneath you. Driver executes the actions in either setup; it isn't the model making the decision.
>
> The examples include a deterministic mock path and a live path that uses your own TypeSafe API key. The mock proves the loop wiring, not live model behavior. It isn't a new model living inside Driver.
>
> ## CUA-S1-FORMS, our form specialist
>
> [CUA-S1](https://github.com/trycua/cua/tree/main/libs/cua-s1) is our research family of small, independent specialist models, and CUA-S1-FORMS is the first one. Dillon adapted ideas and code from [jevlike](https://github.com/vinnylarouge/jevlike) and trained an independent form specialist. *It's not a fine-tune of Jev*, and it doesn't reproduce TypeSafe's calibration work.
>
> The model has **706,048 trainable parameters** and the original checkpoint is about 2.8 MB. Given structured form elements plus values already extracted from a document, it scores each element in a batch: use this supplied value, check, click, or skip. Elements are scored independently, and code decides the execution order. It can't invent values, read screenshots or navigate an unfamiliar app. The current release is an English-centric forms research prototype, not something you should expect to work reliably on arbitrary forms.
>
> *CUA-S1-FORMS alongside an LLM agent using Cua Driver. This shows one form workflow, not a controlled benchmark.*
>
> *Video 2, 15 s, 1520x1340, silent - again a single H.264 video stream with no audio track, so there is nothing to transcribe. A split screen races `Jev-like model + cua-driver (one pass, 50 ms cursor glide)` on the left against `LLM agent + cua-driver only (23 tool turns, 39.6 s total)` on the right, with a shared elapsed-time counter in the top right of each pane. Source: [1520x1340 mp4](https://video.twimg.com/amplify_video/2101436834551046145/vid/avc1/1520x1340/DR5hjmUC4FQtQM3k.mp4?tag=29)*
>
> *Frame at 3.7 s (25%): both panes sit on the same "Northwind Clinic - New Patient Registration" page with every field empty and the status bar reading "Loaded patient-registration". The run has effectively not diverged yet.*
> ![[trycua-904640-007.jpg]]
>
> *Frame at 11.2 s (75%): the divergence is total. The right pane is still on Northwind Clinic with every field blank. The left pane has finished that form, navigated to a second one, "Acme Robotics - Job Application", filled it and submitted it - Mateo Delgado, mateo.delgado@proton.me, 512-555-0177, linkedin.com/in/mateo-delgado, Initech, Robotics Technician, 7 years, $92,000, start 2026-11-02, plus a one-line cover letter. All four of the specialist's actions are visible at once: supplied values typed into the text fields, both attestation checkboxes checked, Submit clicked, and "Referral code (optional)" deliberately left blank. A green log reads `SUBMITTED 11:31:31.838` over the submitted key-value pairs and the status bar reads "Submitted".*
> ![[trycua-904640-008.jpg]]
>
> That distinction matters when comparing it with an LLM agent. The specialist starts with the form elements and supplied values; it doesn't do the work of interpreting the original request or extracting those values. A general-purpose LLM could handle those steps in a larger workflow, but that would be a separate part of the system, not a capability of CUA-S1-FORMS.
>
> Dillon's initial head-to-head on the form task reported 99.7% overall decision accuracy for the specialist against 83.6% for hosted Jev. The specialist was trained for exactly this task, including the convention of skipping already-filled fields, and hosted Jev was not fine-tuned for it. *It's a decision-level result from a narrow experiment, not a general computer-use benchmark.*
>
> His initial timing numbers were 7-9 ms for local form scoring against 260-280 ms per hosted Jev call including network. Those measure different boundaries, a local forward pass on one side and a round trip to a hosted service on the other. *They aren't a controlled model-speed comparison, and they aren't end-to-end form completion times.*
>
> The [source](https://github.com/trycua/cua/tree/main/libs/cua-s1), [weights](https://huggingface.co/cua-ai/cua-s1-forms) and [synthetic dataset](https://huggingface.co/datasets/cua-ai/cua-s1-forms) are public under MIT. The [model card](https://huggingface.co/cua-ai/cua-s1-forms#architecture) covers architecture, evaluation and limitations.
>
> ## When to hand work back to the general agent
>
> Faster decisions don't fix missing perception, stale state, a bad candidate menu or long-horizon planning. A computer-use agent needs a usable representation of the interface, a way to notice the page has moved on, and a way to confirm an action landed.
>
> The handoff we'd like to explore goes like this. A general-purpose LLM interprets the request and plans the unfamiliar parts: getting to the form, working out what information is needed, recovering when something unexpected appears. It could also extract values from a document or generate text when the task calls for it. Once the decisions become familiar and narrow, the agent delegates to a specialist. Application code enforces constraints, executes, and checks. An unexpected dialog or a failed check returns control to the LLM-driven planner.
>
> *Slide 03/03, "DIRECTION TO EXPLORE - Where a specialist could fit.": GENERAL AGENT (plans the task, handles unfamiliar state) passes "familiar state" to SPECIALIST (scores familiar choices, e.g. CUA-S1-FORMS), which passes "chosen action" to APPLICATION (validates, executes, checks the result). A solid return edge labelled "EXPECTED · next familiar choice" loops back to the specialist; a dashed edge labelled "UNEXPECTED · back to the general agent" loops back to the general agent. Footer: "Proposed architecture, not a released unified system."*
> ![[trycua-904640-009.jpg]]
>
> This is **a direction, not a unified system we've shipped**. Knowing when a specialist is out of its depth is itself a hard problem, and a high score alone isn't an answer to it.
>
> ## Workflows we'd like to look at next
>
> Forms gave us a bounded task to test. We'd like to hear where else this approach would be worth trying.
>
> If your company has a repetitive computer or browser workflow where the context changes every run but the choices stay narrow, tell us about it at [hello@trycua.com](mailto:hello@trycua.com). Those are the tasks we want to look at for future CUA-S1 specialists. Both projects live in [trycua/cua](https://github.com/trycua/cua).
>
> ---
>
> ### Replies
>
> Four retrieved against a reply count of seven, in reply order as returned.
>
> > **@hhkkmon (Hekmon)** - 2026-09-20 00:55 UTC - https://x.com/hhkkmon/status/2101475211426283709
> >
> > @trycua Jev feels like a really good precedent, we've suffered enough from LLM latency lol
> >
> > for computer use, i can totally see tiny local models doing Jev-like decisions — maybe just tens or hundreds of MB
> >
> > pretty excited to see where CUA goes from here
>
> > **@aiseomastery (AI Mastery Guide)** - 2026-09-20 02:16 UTC - https://x.com/aiseomastery/status/2101495697547968559
> >
> > @trycua Decision models for computer use, makes sense
>
> > **@VladTerin (Vlad Terin)** - 2026-09-19 23:22 UTC - https://x.com/VladTerin/status/2101452007429017870
> >
> > @trycua Glad you separated model timing from end-to-end completion. Warm-up and planner handoffs still matter a lot in my Jev/Codex adapter. Current demo, with plenty left to improve: https://t.co/hRsCkpfYsy
> >
> > *Quote-tweeting his own post, https://x.com/VladTerin/status/2101446890071974173, which carries a video:*
> >
> > > Playing with Jev adapter for Codex @CompleteSkeptic @sama @elonmusk - this should be the default. Current computer / browser use is a tad slow.
> > >
> > > Lots of improvement here - from cutting the subagent handoff time to warm up time and improving the loop itself - but i think i got it...
>
> > **@OMID_0909 (EKOS _ AGI)** - 2026-09-19 22:46 UTC - https://x.com/OMID_0909/status/2101442723848872216
> >
> > @trycua Jev 🫂 EKOS
> >
> > *Quote-tweeting his own post, https://x.com/OMID_0909/status/2101437950386921704:*
> >
> > > Jev is making AI decisions cheaper.
> > >
> > > But there's another cost sitting upstream of every decision: the cost of getting the right knowledge and context into the decision layer.

## Links

Every URL in the article, in order of appearance:

- [typesafe.ai/blog/introducing-system-one-models-and-jev](https://typesafe.ai/blog/introducing-system-one-models-and-jev) - TypeSafe's Jev launch post
- [docs.typesafe.ai/concepts/system-one](https://docs.typesafe.ai/concepts/system-one) - the System One model concept page
- [docs.typesafe.ai/primitives](https://docs.typesafe.ai/primitives) - the three primitive shapes
- [docs.typesafe.ai/primitives/choice](https://docs.typesafe.ai/primitives/choice) - Choice: pick one supplied option
- [docs.typesafe.ai/primitives/score](https://docs.typesafe.ai/primitives/score) - Score: rate against descriptive levels
- [docs.typesafe.ai/primitives/noul](https://docs.typesafe.ai/primitives/noul) - Noul: probability for a yes/no question
- [github.com/trycua/cua/tree/main/libs/cua-driver](https://github.com/trycua/cua/tree/main/libs/cua-driver) - Cua Driver
- [github.com/microsoft/OmniParser](https://github.com/microsoft/OmniParser) - Microsoft's screenshot-to-structured-elements parser
- [github.com/trycua/cua/tree/main/libs/cua-driver/examples/jev-use](https://github.com/trycua/cua/tree/main/libs/cua-driver/examples/jev-use) - the jev-use public-preview integration recipe
- [github.com/trycua/cua/tree/main/libs/cua-s1](https://github.com/trycua/cua/tree/main/libs/cua-s1) - CUA-S1 source, linked twice in the article
- [github.com/vinnylarouge/jevlike](https://github.com/vinnylarouge/jevlike) - the starter model CUA-S1-FORMS adapted ideas and code from
- [huggingface.co/cua-ai/cua-s1-forms](https://huggingface.co/cua-ai/cua-s1-forms) - CUA-S1-FORMS weights, MIT
- [huggingface.co/cua-ai/cua-s1-forms#architecture](https://huggingface.co/cua-ai/cua-s1-forms#architecture) - the model card's architecture, evaluation and limitations
- [huggingface.co/datasets/cua-ai/cua-s1-forms](https://huggingface.co/datasets/cua-ai/cua-s1-forms) - the synthetic training dataset
- [github.com/trycua/cua](https://github.com/trycua/cua) - the Cua monorepo holding both projects
- hello@trycua.com - where Cua asks for candidate workflows

The two embedded videos, whose direct mp4 URLs the article body does not expose. Both are silent screen recordings: each file carries one H.264 video stream and no audio track, so neither has a transcript.

- [Video 1, 30 s, 1920x1080 mp4](https://video.twimg.com/amplify_video/2101433474888380416/vid/avc1/1920x1080/HeES_ziPdbVYMw8O.mp4?tag=29) - the jev-use 2048 demo, sampled here at 7.5 s and 22.5 s
- [Video 2, 15 s, 1520x1340 mp4](https://video.twimg.com/amplify_video/2101436834551046145/vid/avc1/1520x1340/DR5hjmUC4FQtQM3k.mp4?tag=29) - the CUA-S1-FORMS demo, sampled here at 3.7 s and 11.2 s

Authors:

- [@ddupont808](https://x.com/ddupont808) - Dillon, who trained CUA-S1-FORMS
- [@francedot](https://x.com/francedot) - Francesco
- [@trycua](https://x.com/trycua) - Cua
