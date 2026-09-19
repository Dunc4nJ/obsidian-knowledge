---
created: 2026-09-20
source: https://x.com/sydneyrunkle/status/2100754364545761643
author: Sydney Runkle (LangChain)
published: 2026-09-18
type: knowledge
tags: [jev, langchain, harness-engineering, middleware, model-routing, guardrails, system-one-models, typesafe]
description: LangChain shipped langchain-typesafe two days after Jev's launch, exposing it as TypeSafeClassifier plus two experimental middlewares - a model router that picks the model from the latest user message and keeps it for the whole run, and an auto-mode guardrail that classifies tool calls as risky before they execute.
---

# LangChain's Sydney Runkle puts Jev inside the agent loop as classifier middleware - ModelRouterMiddleware picks the model from the latest user message and AutoModeMiddleware reproduces closed harnesses' dangerous-action gate

## Key Takeaways

- **The article's real argument is not speed, it is that the dangerous-action classifier can leave the closed harness.** Runkle's framing: claude, codex, and cursor all ship some way to classify dangerous actions before they are taken, and "up until now, this classifier step has been locked away in the closed source parts of the harness." A cheap classifier model makes that gate reproducible for any agent, which is the same capability the vault has catalogued in closed harnesses as [[claude-code_findings]], [[codex_findings]], [[letta-code_findings]], and [[hermes-agent_findings]]. `AutoModeMiddleware(tools=["bash"])` is eleven characters of configuration where those harnesses have thousands of lines of policy engine.

- **Tool calling and structured outputs made LLMs integrable, but left every in-loop decision costing a full model call.** Jev attacks the leftover: it generates no text, answers typed questions about a state with probabilities, and evaluates every question in a request in parallel, so adding questions barely moves latency. That makes classification cheap enough to do at every step, which is the same economic move as [[LangChain's Paid Media Agent got 40x cheaper and 13x faster by moving calculations out of the model into code]] and [[BARGAIN routes classification to a small model via a confidence threshold calibrated on 500 oracle labels, cutting costs up to 86 percent more than competing cascades]] - pull the decision out of the expensive sequential model.

- **The integration is middleware, not a new runtime, which is why it landed two days after launch.** `TypeSafeClassifier.invoke(state=..., questions={...})` accepts text, structured data, or LangChain messages, so it drops into any lifecycle hook the framework already exposes - the insertion points documented in [[agent middleware hooks decouple business logic from the core agent loop enabling composable customization]] and exercised in [[harness engineering improved a coding agent 13 points by changing only system prompts tools and middleware]].

- **`ModelRouterMiddleware` routes on the latest user message and then locks that model for the entire run.** Runkle states this plainly and does not treat it as a limitation. A reply from Bernhard Götzendorfer names the failure directly: "the first prompt says quick bugfix, three tool calls later you're doing repo archaeology." Another reply asks whether swapping models destroys prompt caching. Compare [[Cursor strips guardrails and adds dynamic context as models improve, inverting the harness's job]], which argues the harness should be removing this kind of scaffolding, not adding it.

- **Both middlewares consume Jev's probabilities as if they were calibrated, and nothing in the vault yet shows that they are.** The sibling note on [[jev-align]] records that GEPA tunes Jev's *prompt criteria* rather than calibrating its probabilities - it moved labeled-set ambiguity 49.6 points while full-pool certainty moved 0.5. A router thresholding on confidence and a guardrail thresholding on risk both need calibration, not just separation. A reply builder shipped `jevcal` for exactly this reason: "Everyone picks Jev confidence thresholds by vibes. 0.95? 0.5?"

- **The numbers in this article are the vendor's, repeated.** "The company reports up to 200x faster inference and 400x lower cost" is the only performance claim, sourced to TypeSafe's own launch post; [[TypeSafe's Jev trades string generation for parallel-sampled typed decisions with calibrated probabilities at $0.042 per MTok - the 193x and 444x claims come from four self-built workflow evals]] records where those came from. There is no independent benchmark here, no false-positive or false-negative rate for the risk classifier, and no statement of what "risky" criteria `AutoModeMiddleware` ships with. The author is a LangChain engineer promoting a LangChain integration, and both middlewares are imported from `langchain_typesafe.experimental.middleware`.

- **A probabilistic classifier inside the loop is the weakest place to put a safety check.** [[Anthropic sandboxes Claude across three products with gVisor containers, OS syscall filters, and VMs because model-layer defenses cannot stand alone against injection attacks]] reports Claude exfiltrating secrets 24 out of 25 times under injection with model-layer defenses in place; [[over 40 percent of agentic AI projects fail due to poor architecture not model limitations]] argues real security must live outside the reasoning loop entirely; [[terminal-native coding agents need scaffolding-harness separation and context engineering as first-class concerns]] makes the case that schema-level tool gating beats runtime approval checks. A reply makes the sharpest version: "'safe to run' and 'the user asked for this'" are different questions, and "a risk classifier shouldn't be the only permission check."

## How Jev Fits the Agent Loop

Runkle opens with the loop as given: an LLM decides, a tool executes, a model evaluates, repeat until done. Two primitives made LLMs integrable with software that needs structured data - tool calling for structured requests, structured outputs for structured returns. Neither fixes the cost of the loop itself, because every decision inside it is another model call.

Jev is positioned as the thing that absorbs those decisions. It is not an LLM. TypeSafe calls it a **System One model**: a class of model "built to make fast, structured decisions that software can use directly," trained with reinforcement learning for calibrated decisions (RLCD). You send it a **state** (the context) and **questions** about that state; it returns typed answers with probabilities. Your code uses those to decide what happens next, with no chat call in between.

Three question types:

| Type | Question | Returns |
| --- | --- | --- |
| Choice | Pick from a set of options | Probability per option, plus an overall confidence score |
| Score | Rate against ordered levels (low, medium, high) | A continuous score, the underlying distribution, and a confidence value |
| Noul | Answer yes or no | The probability that the statement is true |

The parallelism is the load-bearing property. Runkle quotes the docs: "System One models evaluate every question in a request in parallel. Adding questions barely changes the response time and costs only the tokens for the extra questions, which are cheap." That is what makes it viable to ask ten questions at every step of a loop rather than one, and it is the structural difference from [[RLM subagents need structured outputs not free-text to avoid losing the plot at fan-in - fast-rlm validates every FINAL]], where the schema discipline is enforced on a normal LLM's output rather than baked into the sampler.

The quickstart request, verbatim from the article:

```json
{
  "model": "jev-latest",
  "state": "Hi, I've been trying to connect my Stripe account for 3 days and it keeps failing. I'm losing sales. Please help ASAP.",
  "questions": {
    "is_urgent": {
      "type": "noul",
      "instructions": "The message conveys urgency or time-sensitivity"
    }
  }
}
```

And the urgency answer:

```json
{
  "is_urgent": {
    "type": "noul",
    "noul": 0.999
  }
}
```

A 99.9 percent probability that the message is urgent, which the application uses to prioritize the ticket.

## The LangChain Integration

The package is `langchain-typesafe`, the environment variable is `TYPESAFE_API_KEY`, and the class is `TypeSafeClassifier`. You pass state and questions to `.invoke()` and get classification results rather than a chat response.

```python
from langchain_typesafe import Noul, TypeSafeClassifier

classifier = TypeSafeClassifier()

response = classifier.invoke(
    state=(
        "The deploy failed twice and customers are seeing 500s. "
        "Can someone look now?"
    ),
    questions={
        "urgent": Noul(
            instructions="Does this need attention right now?"
        ),
    },
)

urgency = response.nouls["urgent"].noul
```

State can be text, structured data, or LangChain messages, which is what makes it callable from a node or middleware hook using the context the agent already holds. Docs anchor: [`providers/typesafe#quickstart`](https://docs.langchain.com/oss/python/integrations/providers/typesafe#quickstart).

## Use Cases

### Model routing

```python
from langchain.agents import create_agent
from langchain_typesafe.experimental.middleware import (
    ModelChoice,
    ModelRouterMiddleware,
)

router = ModelRouterMiddleware(
    choices={
        "fast": ModelChoice(
            model="openai:luna",
            criteria="Direct lookups, extraction, and localized changes.",
        ),
        "powerful": ModelChoice(
            model="openai:sol",
            criteria="Architecture and high-stakes decisions.",
        ),
    },
    instructions="Choose the least costly model that can complete the task.",
)

agent = create_agent("openai:gpt-5.6-luna", middleware=[router])
```

Each `ModelChoice` carries a model id and free-text `criteria`; the middleware-level `instructions` set the objective ("Choose the least costly model that can complete the task"). Runkle is explicit about the scope: "The router selects a model from the latest user message and uses it throughout the run. The probabilities and confidence remain available in agent state, too."

Two consequences the article does not draw. A run that starts as a lookup and turns into a debugging session stays on the cheap model, because the routing decision is made once against the first message and never revisited. And the criteria are free text handed to a classifier whose probabilities are not shown to be calibrated, so the threshold between "fast" and "powerful" is whatever the model happens to output. Docs anchor: [`#model-routing`](https://docs.langchain.com/oss/python/integrations/providers/typesafe#model-routing).

### Auto mode

```python
from langchain.agents import create_agent
from langchain_typesafe.experimental.middleware import (
    AutoModeMiddleware,
)

guardrail = AutoModeMiddleware(tools=["bash"])

agent = create_agent("openai:gpt-5.6-luna", middleware=[guardrail])
```

The setup: agents are "inherently untrustworthy" and can be talked into actions nobody wanted, "either naturally or from a motivated enough attacker." Coding harnesses shipped dangerous-action classifiers to build trust, and those classifiers lived in closed source. `AutoModeMiddleware` uses Jev to check tool calls for risky decisions and block them before the tool executes.

What the article does not supply: the criteria the middleware ships with, the threshold at which a call is blocked, any false-positive or false-negative measurement, and whether the classification sees the command string alone or the surrounding environment. That last one matters - [[hermes-agent_findings]] records that `rm -rf /` is harmless inside a read-only container, so a command-string classifier and an environment-aware policy give different answers. [[Factory droid exec uses tiered autonomy levels to gate agent permissions from read-only to full system access]] and [[LangChain Deep Agents runtime builds ten production capabilities on one primitive - durable super-step checkpointing to PostgreSQL]] show the discrete-tier and interrupt-based alternatives. Docs anchor: [`#tool-risk-gating`](https://docs.langchain.com/oss/python/integrations/providers/typesafe#tool-risk-gating).

## Community Examples

The "Get Started!" section points at three builds, all of which are video demos rather than written benchmarks.

- **Kyle Jeong (Browserbase), [tweet](https://x.com/kylejeong/status/2100622054945095934)** - browser and computer use built on Jev plus Stagehand, running in a remote browser. The loop: observe the page, send the accessibility tree as state and the available actions as questions, Jev picks the next action, Stagehand executes it. He reports the demo task cost **$0.001** and ran at "near instant speed." 745 likes.

- **Jarrod Watts, [tweet](https://x.com/jarrodwatts/status/2100356151468585346)** - a live trading bot where Jev decides buy or sell from an asset pair's price feed and executes real trades. Orders go onto Kuru's on-chain order book via Monad, in **every 300 ms block**, which is the latency budget that makes a System One model necessary rather than convenient. 4,933 likes.

- **Ryan Vogel, [tweet](https://x.com/ryanvogel/status/2100042788851101842)** - email classification tested against **1,500 of his own emails**. He calls the result "insane" and says he is "blown away," but publishes no accuracy figure, confusion matrix, or cost number in the tweet text. 3,540 likes.

## Replies

82 of the reported 101 replies were retrievable (`bird replies --all`). Roughly half are congratulations or emoji and are skipped. Neither Harrison Chase (@hwchase / @hwchase17) nor TypeSafe (@typesafeai / @CompleteSkeptic) replied in the retrieved set, despite Chase being tagged in the acknowledgements and in one reply.

**On the router locking the model** - Bernhard Götzendorfer wants "a mid-run escalation path for that router. the first prompt says quick bugfix, three tool calls later you're doing repo archaeology lol." Petey asks whether "swapping models like that might destroy your cache."

**On trusting the classifier** - Dave Thackeray, tagging Chase: "On what does this model base its classification? ... how can we trust the value of its output? Is it more accurate than a human?" Joseph Chin draws the distinction the middleware does not: "'safe to run' and 'the user asked for this'. publishing a perfectly harmless tweet can still be the wrong action ... A risk classifier shouldn't be the only permission check." EKOS notes that a fast confident classifier over stale state means "you just get the wrong decision faster."

**On the speed claims** - shahx is the sharpest: "Everyone's quoting the speedup like the loop around the model is free. Same weights in two published agent loops moved solve rate 14 points, and I'd want that gap measured on my own tasks before swapping anything out." Tarik Koparan: "It looks like a multimodal ML model with a good transformer based encoder, certainly great tool but i dont get the hype, like never heard of ML before." Sankalp: "so now we are building harness for bert."

**Latency and cost numbers from users** - Dan Willoughby put Jev in a commit hook as a prose judge: "the general model drafts, Jev answers **ten yes/no questions per paragraph in 182 ms**, and only the flagged lines need a human." MINZU reports spending "around 2B per week in fable 5.1" on a custom harness and still hitting limits.

**Calibration** - Abhishek Kothari shipped `jevcal` because "Everyone picks Jev confidence thresholds by vibes. 0.95? 0.5? ... Give it your data and say 'I need 99% accuracy'. You get the exact threshold, how much Jev can handle, and how much still needs an LLM." This is the gap [[jev-align]] also circles.

**Reimplementations and extensions** - Alok Ranjan claims OpenJev, an open-source version running on a GTX 1650 with 4 GB of VRAM. yingchao built a pi extension recreating Codex's "approve for me" behavior with Jev. TypeAR argues typesafe generation can go past classification to integers and floats. Alex built a desktop coding harness using Jev for code retrieval and compared it against a minimal harness on the same model, tasks, and verification tests. Matt Holt asks who gets to a self-hosted open-source Jev first.

**Feature requests** - `ToolSelectorMiddleware` compatibility (Maximilien Roberti, with what reads like a maintainer reply saying it is on the roadmap), a JS package (O.K), LangSmith tracing for the middleware (David Chen), and "make it work for tool calls" (Justin Barias).

**Dismissals** - "Very « basic » article, a happy meal" (Nanda). "I think Jev will fade into irrelevance like TOON" (Matt). "Does langchain still exist?? haven't heard of them in like two years" (Surf). "like to see the harness promised in the title" (Siva Tests).

## Related

Jev in this vault: [[moc - Jev]], [[TypeSafe's Jev trades string generation for parallel-sampled typed decisions with calibrated probabilities at $0.042 per MTok - the 193x and 444x claims come from four self-built workflow evals]], [[Sutro's jev-align uses GEPA to rewrite Jev's decision criteria from five labeled examples - the demo moves labeled-set ambiguity 49.6 points but full-pool certainty only 0.5]], [[jev-align]], [[pg-jev]], [[jevlike]].

Same author on LangChain internals: [[Deep Agents v0.6 splits the agent harness into five composable primitives - code interpreter, per-model profiles, typed streaming, delta channels, and ContextHub backend]].

## External Resources

- [TypeSafe: Introducing System One models and Jev](https://typesafe.ai/blog/introducing-system-one-models-and-jev) - the launch post the 200x/400x figures come from, and the RLCD reference
- [TypeSafe docs: quickstart](https://docs.typesafe.ai/introduction/quickstart) - the support-ticket example the article trims to one question; the [request body](https://docs.typesafe.ai/introduction/quickstart#request-body) section shows the multi-question form
- [TypeSafe docs: state](https://docs.typesafe.ai/concepts/state) - what a System One model evaluates
- [LangChain docs: TypeSafe provider](https://docs.langchain.com/oss/python/integrations/providers/typesafe#quickstart) - the integration reference, with [model routing](https://docs.langchain.com/oss/python/integrations/providers/typesafe#model-routing) and [tool risk gating](https://docs.langchain.com/oss/python/integrations/providers/typesafe#tool-risk-gating) anchors
- [OpenAI: function calling and other API updates](https://openai.com/index/function-calling-and-other-api-updates/) - the tool-calling primitive
- [Structured outputs (video)](https://www.youtube.com/watch?v=yj-wSRJwrrc) - the second primitive
- [Jev question types (video, from 3:36)](https://www.youtube.com/watch?si=L1qd4LT9W-W67mar&t=216&v=2Bs0Ink_-Uo&feature=youtu.be) - Choice, Score, Noul explained
- [LangChain forum](https://forum.langchain.com/) and [langchain issues](https://github.com/langchain-ai/langchain) - where Runkle asks for feedback

## Original Content

> [!quote]- Building a Harness with Jev - Sydney Runkle (@sydneyrunkle), 2026-09-18, 4,775 likes / 481 retweets / 101 replies
>
> **Article: Building a Harness with Jev**
>
> Agents run in a loop: an LLM decides what to do, a tool executes, a model evaluates the results, and then continues in that loop until the task is complete.
>
> Agents and LLMs were initially difficult to integrate into software applications, which depend on structured data and predictable interfaces. Two primitives emerged that made this much easier:
>
> - [Tool calling](https://openai.com/index/function-calling-and-other-api-updates/) let models make structured requests and receive structured results.
>
> - [Structured outputs](https://www.youtube.com/watch?v=yj-wSRJwrrc) let models return structured results.
>
> But even with those in place, the agent loop is still slow and costly: every decision requires another model call.
>
> Enter, Jev. Jev is a new model [released from TypeSafe AI](https://typesafe.ai/blog/introducing-system-one-models-and-jev). The company reports up to 200x faster inference and 400x lower cost than comparable LLMs on classification tasks.
>
> ---
>
> **[Embedded tweet at this position in the article]**
>
> > **@CompleteSkeptic (Diogo Almeida)** - 2026-09-15 - 72,235 likes / 7,782 retweets / 3,828 replies - https://x.com/CompleteSkeptic/status/2099925682726002904
> >
> > After co-inventing ChatGPT, I kept asking myself: why have superhuman chat models not led to AGI?
> >
> > I've spent the last 2 years in stealth building a new way to train models (RLCD), and a new type of frontier AI model that we are releasing today: Jev
> >
> > • 20-200x faster
> > • 40-400x cheaper (w/ output tokens free)
> > • Frontier composable intelligence optimized for decisions
> >
> > AFAICT the shortest path to AI-based economic revolution
> >
> > VIDEO: https://pbs.twimg.com/amplify_video_thumb/2099925575637057536/img/l4J_ZhkaxAe8FJXv.jpg
>
> **Transcript of the embedded launch video** (2:56, faster-whisper `small` via subtitles track):
>
> > I'm Diego Almeida, founder of TypeSafe AI and at OpenAI, I co-created ChatGPT and RLHF the post-training algorithm behind most frontier AI Our team trained the first models to be superhuman at instruction following what we now call chat and we asked ourselves are models that are superhuman at chat AGI? The answer was obviously not but the trillion-dollar question is why not? RLHF has led to LMs that are optimized for human preferences and include issues such as mode dropping overconfidence, and an overall lack of reliability These flaws mean that LMs require humans in the loop and almost no true automation can be done At TypeSafe, we've spent two years building in stealth and we're finally ready to share our new type of foundation model that's optimized for automation System 1 models, with a new architecture new sampler, and new training algorithm reinforcement learning for calibrated decisions The improvements are clear if you see them side by side. Ask a System 1 model a ton of structured questions just like you would an LM Get the answers back near instantly Meanwhile LMs take hundreds of times longer to finish responding. Look at how the LM generates sequentially which is great for a natural conversation but totally useless for computers LMs extract intelligence from the tiny straw of auto-regression and similar to the jump that transformers made over RNNs we are replacing sequential computation with parallel because that is obviously the future Our System 1 models output decisions with probabilities and confidence instead of words and they can't hallucinate.
> >
> > They're a lot more like code reliable, fast, self-consistent, and type-safe This opens up a whole new world of possibilities and applications. Today we're releasing JEV the first public System 1 model It's a hundred times faster so real-time AI is finally possible A hundred times cheaper with input tokens priced at forty-two dollars per billion tokens and output tokens are free because they're finally too fucking cheap to meter Jev is super smart and its intelligence per dollar is literally off the charts. This is just the beginning We're excited to see what you build with Jev. As we say at TypeSafe we're building prod, not god Do not use Jev if you enjoy waiting seconds for responses or paying for words you never asked for. Side effects may include fewer retries fewer parsers, fewer broken schemas and intelligence running inside every software loop Your software may begin moderating every message routing every ticket, reviewing every document and making millions of background decisions that were previously too slow or expensive to automate Entire software categories may be rewritten in the process.
> >
> > As costs fall usage may increase dramatically. Ask your developer if your industry is ready
>
> ---
>
> This post covers how Jev works, where it fits into the agent loop, and how to use it with LangChain.
>
> # All about Jev
>
> Jev is actually not a traditional LLM, it doesn't generate text. It's what the TypeSafe AI team calls a System One model:
>
> > 📖 System One models are a class of AI models built to make fast, structured decisions that software can use directly. A System One model evaluates a[ stat](https://docs.typesafe.ai/concepts/state)e and returns typed answers and probabilities.
>
> It's trained using [reinforcement learning for calibrated decisions (RLCD)](https://typesafe.ai/blog/introducing-system-one-models-and-jev). Your code uses those results to guide what an agent does next, without a full chat LLM call for each decision.
>
> To invoke a Jev model, you send it a state (the context) and questions about that state. Here's a single-question version of the support-ticket example in [their docs](https://docs.typesafe.ai/introduction/quickstart):
>
> ```json
> {
>   "model": "jev-latest",
>   "state": "Hi, I've been trying to connect my Stripe account for 3 days and it keeps failing. I'm losing sales. Please help ASAP.",
>   "questions": {
>     "is_urgent": {
>       "type": "noul",
>       "instructions": "The message conveys urgency or time-sensitivity"
>     }
>   }
> }
> ```
>
> The docs' example gives this urgency answer, shown here without the rest of the response:
>
> ```json
> {
>   "is_urgent": {
>     "type": "noul",
>     "noul": 0.999
>   }
> }
> ```
>
> That's a 99.9% probability that the message is urgent, which your application can use to prioritize the ticket.
>
> There are three types of supported [questions](https://www.youtube.com/watch?si=L1qd4LT9W-W67mar&t=216&v=2Bs0Ink_-Uo&feature=youtu.be):
>
> *The article's only image, at this position in the body: the three question types run against the same Stripe support-ticket state. Choice ("Which team should handle this") returns billing 0.84, technical 0.159, sales 0.001 with 0.596 confidence. Score ("How frustrated the customer appears") places the ticket at 1.035 on a Calm / Frustrated / Very angry scale with 0.842 confidence. Noul ("The message conveys urgency or time-sensitivity") returns 0.999.*
>
> ![[sydneyrunkle-761643-001.jpg]]
>
> - Choice: Pick from a set of options. Returns a probability for each option and an overall confidence score.
>
> - Score: Rate an input against ordered levels, such as low, medium, and high. Returns a continuous score, the underlying distribution, and a confidence value.
>
> - Noul: Answer a yes-or-no question. Returns the probability that a statement is true.
>
> One key feature here is that you can ask multiple questions about the same state in one request.
>
> > 💡 System One models evaluate every question in a request in parallel. Adding questions barely changes the response time and costs only the tokens for the extra questions, which are cheap.
>
> For an example of asking multiple questions about a support ticket, see the [TypeSafe Quickstart](https://docs.typesafe.ai/introduction/quickstart#request-body).
>
> In sum, unlike traditional LLMs, Jev is neither constrained by text generation or sequential decision making!
>
> # How to Use Jev with LangChain
>
> LangChain's provider agnostic model is well suited for supporting Jev alongside thousands of other integrations and model providers.
>
> The [LangChain integration](https://docs.langchain.com/oss/python/integrations/providers/typesafe#quickstart) exposes Jev through TypeSafeClassifier. You pass your state and questions to .invoke(), and get classification results rather than a chat response.
>
> Install langchain-typesafe and set your TYPESAFE_API_KEY, then make a call:
>
> ```python
> from langchain_typesafe import Noul, TypeSafeClassifier
>
> classifier = TypeSafeClassifier()
>
> response = classifier.invoke(
>     state=(
>         "The deploy failed twice and customers are seeing 500s. "
>         "Can someone look now?"
>     ),
>     questions={
>         "urgent": Noul(
>             instructions="Does this need attention right now?"
>         ),
>     },
> )
>
> urgency = response.nouls["urgent"].noul
> ```
>
> The state can be text, structured data, or LangChain messages. That makes it straightforward to call Jev from a node or middleware hook using the context your agent already has.
>
> You can build this into custom middleware or tools!
>
> # Use Cases
>
> Jev isn't a drop-in replacement for an LLM. It doesn't generate text, but it can handle classification tasks we often use LLMs for today, without the same latency and cost. That makes it a promising complement to the model driving your agent: use an LLM for open-ended reasoning and generation, and Jev for fast, structured decisions along the way.
>
> ## Model routing
>
> A simple lookup doesn't need the same model as a difficult debugging task. [Model-routing middleware](https://docs.langchain.com/oss/python/integrations/providers/typesafe#model-routing) lets Jev assess the request and choose a model based on criteria you define, so fast and inexpensive for straightforward tasks, more capable for complex ones.
>
> ```python
> from langchain.agents import create_agent
> from langchain_typesafe.experimental.middleware import (
>     ModelChoice,
>     ModelRouterMiddleware,
> )
>
> router = ModelRouterMiddleware(
>     choices={
>         "fast": ModelChoice(
>             model="openai:luna",
>             criteria="Direct lookups, extraction, and localized changes.",
>         ),
>         "powerful": ModelChoice(
>             model="openai:sol",
>             criteria="Architecture and high-stakes decisions.",
>         ),
>     },
>     instructions="Choose the least costly model that can complete the task.",
> )
>
> agent = create_agent("openai:gpt-5.6-luna", middleware=[router])
> ```
>
> The router selects a model from the latest user message and uses it throughout the run. The probabilities and confidence remain available in agent state, too.
>
> ## Auto Mode
>
> Agents are still inherently untrustworthy. An agent can receive bad instructions (either naturally or from a motivated enough attacker) which can persuade it into taking actions we didn't want it to.
>
> Coding harnesses like claude, codex, cursor have shipped some kind of way to classify dangerous actions before they're taken which has slowly helped to build trust in agents. Up until now, this classifier step has been locked away in the closed source parts of the harness.
>
> Now that a cheap and performant classifier model exists, we can take the same pattern and adopt it to all agents!
>
> ```python
> from langchain.agents import create_agent
> from langchain_typesafe.experimental.middleware import (
>     AutoModeMiddleware,
> )
>
> guardrail = AutoModeMiddleware(tools=["bash"])
>
> agent = create_agent("openai:gpt-5.6-luna", middleware=[guardrail])
> ```
>
> [AutoModeMiddleware](https://docs.langchain.com/oss/python/integrations/providers/typesafe#tool-risk-gating) uses Jev to check tool calls for risky decisions it may take, and block calls before the tool executes.
>
> # Get Started!
>
> We're pretty thrilled about Jev and the possibilities that come with it. A few cool projects that we've seen already: [Kyle Jeong](https://x.com/kylejeong/status/2100622054945095934) from Browserbase is powering browser use agents for fractions of a cent, [Jarrod Watts](https://x.com/jarrodwatts/status/2100356151468585346) built a live trading agent, and [Ryan Vogel](https://x.com/ryanvogel/status/2100042788851101842) is doing email triage at scale.
>
> **The three linked community examples, verbatim:**
>
> > **@kylejeong (Kyle Jeong)** - 2026-09-17 - 745 likes / 43 retweets / 28 replies - https://x.com/kylejeong/status/2100622054945095934
> >
> > we built blazing fast computer/browser use with Jev + @Stagehanddev.
> >
> > this task cost $0.001 and executed at near instant speed (in a remote browser btw)
> >
> > the loop: observe the page, send a11y tree as state + actions as questions, Jev decides the next action, then Stagehand executes it.
> >
> > VIDEO: https://pbs.twimg.com/amplify_video_thumb/2100495119065722880/img/7A1mijkU3Z_Zj7PM.jpg
> >
> > (quote-tweeting @CompleteSkeptic's Jev launch post)
>
> > **@jarrodwatts (Jarrod Watts)** - 2026-09-16 - 4,933 likes / 218 retweets / 290 replies - https://x.com/jarrodwatts/status/2100356151468585346
> >
> > I built a trading bot with Jev!
> >
> > Jev decides if it should "buy" or "sell", given the price feed of an asset pair, and executes real trades.
> >
> > It uses Monad to place the orders on Kuru's on-chain order book in every 300ms block.
> >
> > Demo link → https://t.co/vwl2SUu4jm https://t.co/Sda1G5tXKI
> >
> > VIDEO: https://pbs.twimg.com/amplify_video_thumb/2100355999064379392/img/BiAbeDjN57avf2VK.jpg
>
> > **@ryanvogel (vogel)** - 2026-09-16 - 3,540 likes / 106 retweets / 69 replies - https://x.com/ryanvogel/status/2100042788851101842
> >
> > this model is actually insane at email classification
> >
> > i tested it on 1500 of my own emails to see how well it works and I am blown away https://t.co/pzTqhZ1Luh
> >
> > VIDEO: https://pbs.twimg.com/amplify_video_thumb/2100042377339588608/img/2O56_xRC0r54ugfr.jpg
> >
> > (quote-tweeting @CompleteSkeptic's Jev launch post)
>
> New models drop every week at this point, but this one had a pretty outsized response. We're excited to see what you build with LangChain and Jev.
>
> Let us know what you think on the [forum](https://forum.langchain.com/), tag us on [X](https://x.com/LangChain?lang=en) and share what you're building, or engage with [LangChain issues](https://github.com/langchain-ai/langchain)!
>
> ## Acknowledgements
>
> Thanks @huntlovell, @hwchase, @ccurme, @veryboldbagel, and Nathan Drenzer for their thoughtful review and contributions.
>
> date: Fri Sep 18 01:10:45 +0000 2026
> url: https://x.com/sydneyrunkle/status/2100754364545761643
> likes: 4775  retweets: 481  replies: 101
>
> ---
>
> ### Replies (verbatim, 82 of 101 retrievable; pure congratulations and emoji omitted)
>
> > **@agentspanel (Alok Ranjan)** - 2026-09-19
> > @sydneyrunkle I made the open source version of Jev that runs on consumer grade GPU that runs locally.
> > https://t.co/NmZo1NkR4h
> > (QT @agentspanel: @typesafeai I rebuilt the idea in the open: OpenJev. Ran it on a GTX 1650. 4GB VRAM. No A100. No datacenter. - https://x.com/agentspanel/status/2100982446221373644)
>
> > **@JustinBarias (Justin Barias)** - 2026-09-19
> > @sydneyrunkle too lightweight.
> > make it work for tool calls.
>
> > **@MRoberti (Maximilien Roberti)** - 2026-09-18
> > @sydneyrunkle If you could make Jev compatible with the ToolSelectorMiddleware, it would be Amazing!
>
> > **@abhiomkar (Abhinay Omkar)** - 2026-09-18
> > Unrelated, I've been wondering if we can use Jev like model for graph building. It would help create orchestration based on the given task. LangGraph but dynamically created per task.
> >
> > For context, I use LangGraph for one of my real-world projects where LLM SDKs (harness) are called in nodes. There are a few use-cases where I want to dynamically construct the graph.
>
> > **@DaveThackeray (Thack)** - 2026-09-18
> > @sydneyrunkle @hwchase17 On what does this model base its classification? Sure, I get that you can include considered criteria but how can we trust the value of its output? Is it more accurate than a human? Would it solve the Trolley Problem?
>
> > **@SurfingPigment (Surf)** - 2026-09-18
> > @sydneyrunkle Does langchain still exist?? haven't heard of them in like two years
>
> > **@Nokia0421 (fuckopenai)** - 2026-09-18
> > @sydneyrunkle model routing 写进 harness 了，说明单模型不够用。
>
> > **@abaddon_gtz (Rafael Gutiérrez)** - 2026-09-18
> > @sydneyrunkle 2 days and now everyone talks about using Jev for everything
>
> > **@kenykore (O.K)** - 2026-09-18
> > @sydneyrunkle Is package available on the JS side ?
>
> > **@Biaus_ (Agustin)** - 2026-09-19
> > @sydneyrunkle Only for choosing the model?
> > Any other suggestion for the harness?
>
> > **@JasonC_Dev (JasonC)** - 2026-09-19
> > @sydneyrunkle 循环停不住的时候，是评测模型喊停，还是外层硬切步数？
>
> > **@jisifu (Matt)** - 2026-09-19
> > @sydneyrunkle I think Jev will fade into irrelevance like TOON, but both are magnificent
>
> > **@thepeekpoker (Nanda)** - 2026-09-19
> > @sydneyrunkle Very « basic » article,  a happy meal.
>
> > **@TypeAR_ai (TypeAR)** - 2026-09-19
> > @sydneyrunkle Typesafe generation can go beyond classification — it can support integers and floats.
> > Open-source: https://t.co/eDQZoS8skr https://t.co/lNbwBS2OAY
> > PHOTO: https://pbs.twimg.com/media/HSjzCaLaYAApFMs.jpg
>
> > **@_Kanevry (Bernhard Götzendorfer)** - 2026-09-18
> > @sydneyrunkle would love a mid-run escalation path for that router. the first prompt says quick bugfix, three tool calls later you're doing repo archaeology lol
>
> > **@TawfekSraj (Tawfek Sraj)** - 2026-09-18
> > @sydneyrunkle currently building one and benchmarking it..
> > early results are kinda promising..
> > will share soon…
>
> > **@anantinvent (Anant Agarwal)** - 2026-09-18
> > @sydneyrunkle Tool selection, determining if the main loop needs to run again - can also be helpful use cases of @typesafeai Jev.
>
> > **@DanRWilloughby (Dan Willoughby)** - 2026-09-18
> > @sydneyrunkle same pattern, different loop. I put Jev in the commit hook as the prose judge: the general model drafts, Jev answers ten yes/no questions per paragraph in 182 ms, and only the flagged lines need a human. the tool never rewrites, it just points.
>
> > **@baggiiiie (yingchao)** - 2026-09-19
> > @sydneyrunkle made an pi extension for auto mode! approve for me without burning astra usage
> > https://t.co/M5j3Wcai7s
> > (QT @baggiiiie: made a @pidotdev extensions that uses @typesafeai jev to recreate codex's "approve for me" behavior, which reads context and decides if a bash cmd is related to current task and safe - https://x.com/baggiiiie/status/2100588992572055693)
>
> > **@DeMindsXYZ (DeMinds)** - 2026-09-18
> > @sydneyrunkle Really like this framing, Sydney. The interesting part for me isn't just Jev being fast — it's seeing routing and tool-risk checks pulled out of the main LLM loop. And LangChain moving this quickly to middleware makes it feel immediately practical.
> > https://t.co/brU1wcxqOS https://t.co/3Stij7n0Pv
> > PHOTO: https://pbs.twimg.com/media/HSesZ7_aoAAhOsM.jpg
>
> > **@MightyPants0 (MaKon)** - 2026-09-19
> > @sydneyrunkle The harness is the product. The model is a dependency.
>
> > **@shuizhuyu (Crio Songo)** - 2026-09-19
> > @sydneyrunkle That's a really good point. We've had that compatibility on our roadmap, will speed it up.
>
> > **@diousk00 (David Chen)** - 2026-09-18
> > @sydneyrunkle Thanks for the quick support of typesafe. I'm curious about the observability, is the typesafe midleware can be traced and view in Lang Smith?
>
> > **@huh_go (Hugo Carvalho | Attribution Systems)** - 2026-09-19
> > @sydneyrunkle I built something between the harness
>
> > **@Devatune (MINZU)** - 2026-09-19
> > @sydneyrunkle I've been spending around 2B per week in fable 5.1 and even a simple app that I'm working on with my custom harness, the limit still hits. Curious how this goes, Im going to try this out soon.
>
> > **@shax1347 (shahx)** - 2026-09-18
> > @sydneyrunkle Everyone's quoting the speedup like the loop around the model is free. Same weights in two published agent loops moved solve rate 14 points, and I'd want that gap measured on my own tasks before swapping anything out.
>
> > **@moefarag1 (Mahmoud Farag)** - 2026-09-19
> > @sydneyrunkle Use an LLM for open-ended reasoning and generation, and Jev for fast, structured decisions along the way.
> > This line nails it, a really clean way to think about where Jev fits alongside LLMs.
>
> > **@Bstretweetz (itzdifferent)** - 2026-09-18
> > @sydneyrunkle The explicit loop is the right abstraction. In practice, the hard part is state: preserving tool outputs, bounding retries, and making termination criteria observable so "continues until complete" doesn't become an opaque cost spiral.
>
> > **@_DMontgomery40 (Dmonty)** - 2026-09-18
> > Great article, just wanted to include the skill.md link..  it gets installed automatically if you use the agent prompt to set up, but not every env allows for that so don't miss: https://t.co/CAf04nvAsa
> >
> > It is wild how deep and complex these schemas can go, when frontier models are building the request.  The docs really only touch the very tip of the iceberg, understandably.  So many possibilities...
>
> > **@cikociscore (Cikocisco)** - 2026-09-18
> > @sydneyrunkle Eval model same as planner? Loop burns tokens fast — how you cap cost per task?
>
> > **@aplam96 (Alex)** - 2026-09-19
> > @sydneyrunkle https://t.co/DlVCay0pgr
> > (QT @aplam96: I've been building a desktop coding harness that uses @typesafeai's Jev for code retrieval. I compared it against a minimal harness using the same coding model, the same tasks, and the same verification tests. - https://x.com/aplam96/status/2101093145362501784)
>
> > **@K_aditya25 (Aditya Kharbanda)** - 2026-09-19
> > @sydneyrunkle Great read this one. Daniel Kahneman described System 1 thinking as associative thinking, where our brain uses first impressions, draws from our biases and our world view to reach conclusions and make instant decisions and reactions. Good fit with deterministic software!
>
> > **@chin_jlyc (Joseph Chin)** - 2026-09-19
> > @sydneyrunkle one distinction is: 'safe to run' and 'the user asked for this'. publishing a perfectly harmless tweet can still be the wrong action if that makes sense.
> >
> > A risk classifier shouldn't be the only permission check.
>
> > **@caseycollins (Casey Collins)** - 2026-09-18
> > @sydneyrunkle I'm excited about harnesses built around Jev as well. I think they'll allow for a lot more fine grained control. We can have tool level evaluations of when to use a tool and whether or not its safe. We can also use Jev to verify agent success.
>
> > **@thenightshipper (Abhishek kothari)** - 2026-09-18
> > @sydneyrunkle https://t.co/kNY5hxZUdZ
> > (QT @thenightshipper: Everyone picks Jev confidence thresholds by vibes. 0.95? 0.5? I built jevcal. Give it your data and say "I need 99% accuracy". You get the exact threshold, how much Jev can handle, and how much still needs an LLM. - https://x.com/thenightshipper/status/2100850610962919551)
>
> > **@OMID_0909 (EKOS _ AGI)** - 2026-09-18
> > @sydneyrunkle Jev solves a real bottleneck in the agent loop. But it also makes the knowledge behind each decision more important. If the classifier is fast, cheap and highly confident, but the state it receives is stale or wrong, you just get the wrong decision faster.
>
> > **@OMID_0909 (EKOS _ AGI)** - 2026-09-18
> > @sydneyrunkle How are you thinking about the knowledge layer behind that state?
>
> > **@RolfStreefkerk (Rolf Streefkerk)** - 2026-09-19
> > @sydneyrunkle now we need to get service providers such as openai and anthropic to commit to model output quality SLA's.
> >
> > Nobody can build on models when their reasoning and capabilty changes week after week
>
> > **@procisionful (Tarik Koparan)** - 2026-09-19
> > @sydneyrunkle It looks like a multimodal ML model with a good transformer based encoder, certainly great tool but i dont get the hype, like never heard of ML before
>
> > **@paperplaneflyr (Paperplaneflyr)** - 2026-09-18
> > @sydneyrunkle This implies we can set apart logic for structured decisions to be picked by Jev and then use LLM for other text generation logic.
>
> > **@BuddyIterate (Buddy Williams)** - 2026-09-19
> > @sydneyrunkle Excellent write up, especially the three categories: classification, score, and yes/no. I already have ideas for how to use this in our enterprise projects.
>
> > **@mitansh_j07 (Mitansh)** - 2026-09-18
> > @sydneyrunkle harness work on jev agents is sharp. which piece was hardest?
>
> > **@SivaTests (Siva Tests)** - 2026-09-19
> > @sydneyrunkle great way to build on the momentum of @typesafeai - but like to see the harness promised in the title.
>
> > **@3sankalpsingh (Sankalp)** - 2026-09-18
> > @sydneyrunkle so now we are building harness for bert
>
> > **@mholt6 (Matt Holt)** - 2026-09-18
> > @sydneyrunkle Who will be first to an open source self hosted Jev model?
>
> > **@AnandButani (Anand Butani)** - 2026-09-19
> > @sydneyrunkle a lot of agent step don't need language generation at all. Jev is a great example of how specialized models can handle routing, filtering, deciding etc. while handing off the expensive LLM tasks only when needed
>
> > **@peteyburn (petey)** - 2026-09-19
> > @sydneyrunkle Swapping models like that might destroy your cache though right
>
> > **@ShankarDS (Shanks)** - 2026-09-18
> > @sydneyrunkle the ModelRouterMiddleware abstraction is beautiful

## Links

- Original article: https://x.com/sydneyrunkle/status/2100754364545761643
- Jev launch tweet (embedded in the article): https://x.com/CompleteSkeptic/status/2099925682726002904
- Kyle Jeong, Browserbase + Stagehand: https://x.com/kylejeong/status/2100622054945095934
- Jarrod Watts, on-chain trading agent: https://x.com/jarrodwatts/status/2100356151468585346
- Ryan Vogel, email classification: https://x.com/ryanvogel/status/2100042788851101842
