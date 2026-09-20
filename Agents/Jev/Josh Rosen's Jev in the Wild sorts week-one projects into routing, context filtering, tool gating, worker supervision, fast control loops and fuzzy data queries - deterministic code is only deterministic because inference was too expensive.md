---
created: 2026-09-20
description: Josh Rosen's X Article surveys the first week of Jev projects and sorts them into six architecture patterns - routing, context filtering, tool gating, worker supervision, fast control loops and fuzzy data queries - around one through-line, that Jev is inserted at a specific decision point in otherwise conventional software and hands control straight back rather than owning the loop. His own quote-tweet supplies the thesis, that we are "dramatically underestimating how many decisions in normal software are only deterministic because inference used to be too expensive." The survey names 25 projects and reports not one measurement, and five of the six categories reduce to the same primitive - a cheap classifier reading a bounded candidate set that deterministic code minted and a deterministic policy acts on.
source: https://x.com/josharosen/status/2101645894818857272
via: https://x.com/josharosen/status/2101646268032307475
author: Josh Rosen (@JoshARosen)
published: 2026-09-20
type: knowledge
tags: [jev, system-one-models, architecture-patterns, routing, tool-gating, worker-supervision, control-loops, fuzzy-queries, typesafe]
---

# Josh Rosen's Jev in the Wild sorts week-one projects into routing, context filtering, tool gating, worker supervision, fast control loops and fuzzy data queries - deterministic code is only deterministic because inference was too expensive

## Key Takeaways

- **The thesis is in the quote-tweet, not the article, and it is the most load-bearing sentence Rosen has written on Jev.** Posted 89 seconds after the article itself: "I think we're dramatically underestimating how many decisions in normal software are only deterministic because inference used to be too expensive." This is his [[Snowflake, Databricks and ClickHouse preview AI architecture by turning inference into a database operator, the semantic layer into agent infrastructure, and agents into a new database workload|inference-as-a-database-operator thesis]] restated one layer down. There, inference became an operator with a cost model the query optimizer reasons about; here, the claim is that the cost model changed enough that the *default* flips, and the boundary between code-decided and model-decided stops being a deliberate architectural choice. The article is the evidence table for that sentence, and the sentence is the part worth keeping.

- **The actual architectural claim is the inversion of the agentic loop, and it is stated cleanly.** "Unlike Jev's LLM counterparts, which have been at the center of the agentic loop, the common pattern with Jev isn't giving it control. It's inserting Jev at a specific decision point in otherwise conventional software." The result he names is "a much more granular line between deterministic software and probabilistic decisions" - Jev makes one decision and hands control right back. Every pattern below is a different answer to *where* you cut that line, which is why the vault's first-hand notes keep independently arriving at the same shape: the application mints the candidate set, the model returns an index, deterministic code executes. [[Cua keeps the candidate menu in application code so Jev only picks an ID - CUA-S1-FORMS is a 706K-parameter form specialist at 99.7 percent against hosted Jev's 83.6, and neither model sees pixels|Cua states that boundary most explicitly]], and Rosen's survey is the first thing in the vault to show it is a convergent pattern rather than one team's taste.

- **Five of the six categories collapse into one primitive, and Rosen very nearly says so himself.** Writing about semantic HTTP routing he notes "the same decision primitive works whether the things behind it are models, tools, agents, or ordinary software." That sentence dissolves his own taxonomy. Routing, context filtering, tool gating and worker supervision differ only in *what sits behind the candidate set* - models, context chunks, actions, verdicts - not in what the model does, which is score a bounded set that deterministic code built. Fast control loops are the same primitive called repeatedly; fuzzy data queries are the same primitive with a query planner as the caller. The taxonomy is a useful index of where people are putting the cut, not six distinct architectures, and reading it as six things will make you build four routers.

- **Context filtering is the one pattern with a genuinely new idea in it: meaning becomes a read-time decision.** "That makes context selection a read-time decision. The system doesn't have to completely decide what a piece of information means when it stores it." This is the same argument as his [[Josh Rosen argues context infrastructure should decide later - CortexDB and Statewave preserve raw history because the write path cannot know what will matter|decide-later thesis for context infrastructure]], and Jev is what makes it affordable rather than merely correct: if classification is cheap enough to run per request, the write path no longer has to guess. The embedded 18 September post spells out the mechanism - a harness-level "classify context" tool whose semantics change per request, "way better than conventional embeddings/RAG." The vault already holds a shipped, priced instance in [[Can Bölük's jegrep turns Jev into a semantic grep by scoring grep-ranked candidates with one Noul per file and a Choice for the line range - $0.004 a query, and the Gemini-lite comparison is nowhere in the repo|jegrep's three-stage cascade]], where relevance is literally a Noul probability at about $0.004 a query.

- **Twenty-five named projects and not a single measurement.** There is no accuracy figure, no latency number, no cost, no benchmark, and no comparison anywhere in the article. The only quantities in 1,480 words are "less than a week" and "thousands of tiny decisions." That is a defensible choice for a one-week field survey, but it means the piece is a map of what people are *attempting*, not evidence that any of it works, and it should not be cited as if it were. Every number the vault has on these patterns comes from elsewhere: [[LangChain's Jev-as-a-Judge bench puts Jev's quality-score variance 92 to 913x below three LLM judges at $0.34 against Claude's $28.17 - five weather traces, one human oracle, provider-default sampling|LangChain's five-trace judge bench]], [[TypeSafe's Jev trades string generation for parallel-sampled typed decisions with calibrated probabilities at $0.042 per MTok - the 193x and 444x claims come from four self-built workflow evals|TypeSafe's own self-built evals]], Cua's 99.7 against 83.6. Rosen also selects on survivors - these are the projects that shipped inside a week and got posted - and nothing here records what people tried and abandoned.

- **The thesis is strongest on fuzzy data queries and weakest on tool gating, and the gap matters.** For "rank products by how luxurious they seem," the deterministic version was never written - the predicate was *absent*, not deterministic, so Jev adds a capability rather than replacing rules, and the same holds for routing HTTP requests by meaning. Tool gating is the opposite case and Rosen concedes the structure himself: "None of these systems need Jev to enforce the policy. That's done in deterministic code." The candidate set is deterministic, the policy is deterministic, and what Jev supplies is a fuzzy input. The vault's first-hand notes push harder than he does - [[LangChain's Sydney Runkle puts Jev inside the agent loop as classifier middleware - ModelRouterMiddleware picks the model from the latest user message and AutoModeMiddleware reproduces closed harnesses' dangerous-action gate|the AutoModeMiddleware note]] records the standing objection that a probabilistic classifier inside the loop is the weakest place to put a safety check, and no note in the vault has yet verified that Jev's probabilities are calibrated, which is exactly what a threshold-based gate assumes.

- **Worker supervision is the pattern he has skin in, and the disclosure is clean.** Foreman is his own project and he writes "I built Foreman around this pattern" rather than presenting it as a third-party sighting. The architectural point survives the conflict of interest: separating *doing the work* from *judging the work* is normally impossible because you would pay a second frontier model to watch the first, and a fast decision model makes that arithmetic work. The two properties that decide whether it holds up are ones the vault has already flagged and Rosen does not mention - [[Annabell frames TypeSafe's Jev as a savant for eval verdicts and routing - three question types, 255 choices, 10 score levels, and a Noul with no confidence field|Jev cannot abstain and returns no rationale]], so a supervisor built on it will always emit a verdict and can never explain one.

## The Six Patterns

### All Sorts of Routing

**His definition.** Give Jev a request and a candidate set and it picks which thing should handle the work. He is explicit that this is bigger than model routing: Jev "can sit in front of a set of agent capabilities and decide which one should handle the work, based on semantics that would otherwise be difficult to encode in rules."

**His examples.** JevRouter puts models, subagents, skills, MCP tools and CLIs into one candidate set. agent-router chooses between coding agents as well as model and effort level. jev-codex-router makes the call per individual Codex turn. hono-jev-router leaves AI infrastructure entirely and routes HTTP requests by meaning instead of URL pattern.

**In the vault:** [[LangChain's Sydney Runkle puts Jev inside the agent loop as classifier middleware - ModelRouterMiddleware picks the model from the latest user message and AutoModeMiddleware reproduces closed harnesses' dangerous-action gate|LangChain's `ModelRouterMiddleware`]] is the shipped version of exactly this, and it carries a limitation Rosen's framing hides: it routes on the latest user message and then locks that model for the entire run, which is not "a decision at a decision point" so much as one decision per session. [[Daniel Ch's How to master Jev prescribes a 0.85 and 0.55 confidence-gate ladder under an LLM that still writes - the decision-layer architecture is additive but every number and all three charts are TypeSafe's own|Daniel Ch's guide]] names "model router" as one of five workflow archetypes and is the only source in the vault that attaches thresholds to it - act above 0.85, escalate 0.55 to 0.85 to a stronger model, queue below 0.55 for a human - while conceding the numbers are TypeSafe's. [[BARGAIN routes classification to a small model via a confidence threshold calibrated on 500 oracle labels, cutting costs up to 86 percent more than competing cascades|BARGAIN]] is the pre-Jev form of the same idea and the reason to be uneasy: it needed 500 oracle labels to *calibrate* the threshold before the cascade saved anything, and none of the routers Rosen lists calibrate anything. [[Annabell frames TypeSafe's Jev as a savant for eval verdicts and routing - three question types, 255 choices, 10 score levels, and a Noul with no confidence field|Annabell]] argues routing is one of the two use cases Jev's savant shape actually fits.

### Context Filtering

**His definition.** Jev decides what information survives to the next stage. The payoff is epistemic rather than economic: "Jev decides what matters for the agentic decision being made right now," which makes context selection a read-time decision and relieves the write path of having to fix meaning at storage time.

**His examples.** Winnow judges tool results before they enter a coding agent's context. jev-sift scores files, URLs and snippets so an agent only opens what matters. fast-jev-compaction decides what survives Claude Code compaction while keeping selected content verbatim. On the retrieval side, joelhooks' reranker assigns each candidate document a relevance probability and blink applies the same idea to code search. He embeds his own 18 September post predicting Jev "revolutionizes context management" via a harness-provided "classify context" tool, closing with "Meaning can be derived on read, not write."

**In the vault:** [[Josh Rosen argues context infrastructure should decide later - CortexDB and Statewave preserve raw history because the write path cannot know what will matter|his own decide-later note]] is the full argument this pattern compresses, and the pairing is the interesting part - that note said the write path *cannot know*, this one says read-time classification is now cheap enough to act on it. [[Can Bölük's jegrep turns Jev into a semantic grep by scoring grep-ranked candidates with one Noul per file and a Choice for the line range - $0.004 a query, and the Gemini-lite comparison is nowhere in the repo|jegrep]] and its [[jegrep|resource note]] are the vault's worked instance of the reranker idea: a real ripgrep prior, then one Noul per filename, one per 384-byte sketch, then a Noul plus line-range Choice on at most 40 passages, thresholded at 0.45 and 0.2 - and its own note records that nothing calibrates the probabilities those thresholds compare against. [[Annabell frames TypeSafe's Jev as a savant for eval verdicts and routing - three question types, 255 choices, 10 score levels, and a Noul with no confidence field|Annabell's note]] supplies the constraint Rosen omits: TypeSafe documents that Jev suffers from context rot, which is an awkward property for the model you have chosen as your context filter. [[agentic search with grep and full-file loading replaces RAG when context windows are large enough|The grep-over-RAG finding]] is the competing answer to the same problem.

### Tool Gating

**His definition.** Jev at the moment an agent is about to act. The important sentence is the disclaimer: "None of these systems need Jev to enforce the policy. That's done in deterministic code. Conventional software can still own permissions and execution. Jev just provides the semantic judgment that the policy uses." The benefit he claims is narrow and honest - the policy gets "a way to act on fuzzy conditions without giving the model control over the action itself."

**His examples.** jev-guard turns tool calls from coding agents into allow, ask or deny decisions and also inspects tool *results* for prompt injection before they return. pi-warden puts the same layer inside the Pi coding agent, checking actions against project rules and feeding guidance back to the worker. Jev Shield pushes it down to MCP, where calls, results and descriptions all pass semantic checks.

**In the vault:** [[LangChain's Sydney Runkle puts Jev inside the agent loop as classifier middleware - ModelRouterMiddleware picks the model from the latest user message and AutoModeMiddleware reproduces closed harnesses' dangerous-action gate|`AutoModeMiddleware`]] is the shipped open-source version of the closed harnesses' dangerous-action gate, and that note carries the vault's sharpest counter to this whole pattern - a probabilistic classifier is the weakest place to put a safety check, and both middlewares consume Jev's probabilities as if calibrated when nothing has shown they are. [[Cua keeps the candidate menu in application code so Jev only picks an ID - CUA-S1-FORMS is a 706K-parameter form specialist at 99.7 percent against hosted Jev's 83.6, and neither model sees pixels|Cua]] is the constructive answer: keep the menu of permitted actions in application code so the model can only pick an ID, and trigger hand-back to a general agent on an *event* - an unexpected dialog, a failed check - rather than on a confidence number. [[coding agents should be personal canvases not uniform tools|The Pi note]] covers badlogic's agent that pi-warden plugs into. [[Cursor strips guardrails and adds dynamic context as models improve, inverting the harness's job|Cursor's inverse trajectory]] is the counter-trend worth holding alongside this one.

### Worker Supervision

**His definition.** Jev above the worker, which he thinks "could give System One models a pretty important role in software factories." In Foreman, a Codex worker does the engineering while Foreman independently watches, and Jev "continuously assesses the evidence coming off the factory floor, including worker output, Git changes, tests, previous assessments, and the original job" - asking whether the worker is stuck or drifting. Control stays outside: "Jev doesn't do the coding and it doesn't control the coding-agent loop," while deterministic policy decides whether to continue, steer, stop, retry, verify, finish or escalate.

**His examples.** Foreman, which is his own. The embedded 19 September post gives the concrete mechanism: fold live Codex output, Git changes and AGENTS.md into one observation, have Jev score the probability the worker is drifting from AGENTS.md, steer the active turn when drift crosses a threshold and stop it if drift continues.

**In the vault:** [[LangChain's Jev-as-a-Judge bench puts Jev's quality-score variance 92 to 913x below three LLM judges at $0.34 against Claude's $28.17 - five weather traces, one human oracle, provider-default sampling|LangChain's Jev-as-a-Judge bench]] is the only measurement the vault has on Jev-as-supervisor and it cuts both ways - it matched a human oracle on all 500 binary decisions at $0.34 against Claude's $28.17, but on five traces, with the LLM judges left on provider-default sampling. [[Annabell frames TypeSafe's Jev as a savant for eval verdicts and routing - three question types, 255 choices, 10 score levels, and a Noul with no confidence field|Annabell's note]] names the two properties that should worry anyone building Foreman: Jev cannot abstain, so a forced binary picks the least-wrong answer rather than saying "unclear," and it returns no rationale, so when the supervisor stops a worker nobody can see why. [[Daniel Ch's How to master Jev prescribes a 0.85 and 0.55 confidence-gate ladder under an LLM that still writes - the decision-layer architecture is additive but every number and all three charts are TypeSafe's own|Daniel Ch]] calls the same shape a "universal verifier" wrapped around every expensive LLM call.

### Fast Control Loops

**His definition.** Browser and computer use put Jev in a role that is "less agent-like and more gamer-like" - observe state, decide fast, repeat. He is careful that this is the one pattern where Jev genuinely sits inside a loop, and equally careful that it still owns very little: "the surrounding program defines what the model is allowed to do."

**His examples.** Browser Use's Jev Ultrafast builds a set of possible browser operations and DOM targets and has Jev pick one, needing a small language model only when text must actually be generated. jev-browser uses the same architecture per step. typesafe-computer-use reads the screen, constructs possible actions and has Jev choose where to move the mouse or what to click. Games make the shape obvious - Jev playing Pokémon Red, driving cars, running simulations.

**In the vault:** [[Cua keeps the candidate menu in application code so Jev only picks an ID - CUA-S1-FORMS is a 706K-parameter form specialist at 99.7 percent against hosted Jev's 83.6, and neither model sees pixels|Cua]] is the fullest first-hand account of this loop, down to a split-screen demo of "one pass, 50 ms cursor glide" against an LLM agent's 23 tool turns and 39.6 seconds - and it names the hole Rosen's survey does not, that neither model sees pixels and the perception step is the part nobody has built. [[TypeSafe's Jev trades string generation for parallel-sampled typed decisions with calibrated probabilities at $0.042 per MTok - the 193x and 444x claims come from four self-built workflow evals|TypeSafe's own launch]] supplies the only price the vault has for running this pattern hot: a Doom demo at roughly 10 queries per second for about $7 an hour. Kyle Jeong's Browserbase build, cited inside [[LangChain's Sydney Runkle puts Jev inside the agent loop as classifier middleware - ModelRouterMiddleware picks the model from the latest user message and AutoModeMiddleware reproduces closed harnesses' dangerous-action gate|Sydney Runkle's note]], runs browser-use agents for fractions of a cent on the same architecture. [[The bitter lesson of agent harnesses is your helpers are abstractions too - Browser-Use ships a 600-line CDP + SKILL.md harness|Browser Use's own harness note]] and [[Stagehand's six-layer browser harness—security, caching, identity, credential brokering, skills, and filesystem—is what separates production browser agents from raw-CDP demos|Stagehand's six layers]] describe what the "surrounding program" has to be for this to survive production.

### Fuzzy Data Queries

**His definition.** Jev inside the data layer, "where a lot of decisions have traditionally been limited to what we can express in queries and rules." The concrete framing is the best in the article: instead of only writing deterministic predicates like `country = 'US'` or `revenue > 100000`, you add conditions whose answers depend on the *meaning* of the data, with the rest of the query staying ordinary SQL.

**His examples.** pg-jev puts Jev inside Postgres so a query can filter on whether a customer sounds angry, rank products by how luxurious they seem, or classify a ticket by owning team. duckdb-jev does it for DuckDB; neo4jev brings it to graphs by having Jev choose which relationship to follow. He extrapolates to warehouses "full of classifications, rankings, filters, and business rules that are easy to describe in English but hard to turn into SQL."

**In the vault:** [[pg-jev]] is the vault's resource note on the Postgres extension he leads with, the one project in the entire survey the vault had already captured first-hand. [[Snowflake, Databricks and ClickHouse preview AI architecture by turning inference into a database operator, the semantic layer into agent infrastructure, and agents into a new database workload|His own warehouse note]] is where this pattern comes from and is considerably more rigorous about it - there, inference becomes a database operator with a cost model the query optimizer has to reason about, which is precisely the machinery pg-jev and duckdb-jev do not yet have. [[Daniel Ch's How to master Jev prescribes a 0.85 and 0.55 confidence-gate ladder under an LLM that still writes - the decision-layer architecture is additive but every number and all three charts are TypeSafe's own|Daniel Ch's]] "giant dataset job" is the batch version of the same archetype. This is the pattern where the quote-tweet thesis is least arguable: nobody wrote a deterministic `sounds_angry` predicate and then replaced it, because the predicate never existed.

## Everything Else and Where Jev Goes

The miscellany section is where Rosen is most candid that this is a field survey rather than an argument. A Magic Jev Ball looks at a GitHub PR and decides whether you should approve it; an ad blocker asks Jev whether something looks like an ad; Unclutter decides which parts of a webpage are unnecessary; awesome-jev asks a semantic question against every function in a codebase. He also lists autonomous cars, mobile phone control, semantic code search, sponsor detection in YouTube videos, and scoring every sentence in a video to flag when someone dodges a question. The embedded Stefan clip - "when a designer gets access to Jev" - is by a wide margin the most-engaged artifact anywhere in the article at 6,204 likes, against 26 for the article's own host tweet, which is its own comment on where the week's attention actually went. His read is deliberately unserious: "A lot of these aren't serious applications, and that's kind of the point. People are playing with a new primitive and figuring out where it works."

"Where Does Jev Go?" is three sentences of prediction with the hedges intact, and they should be kept intact. The answer is "almost everywhere," which he immediately attributes rather than asserts - "And I think that's basically TypeSafe's bet. Jev is cheap and fast enough that we start rewriting applications to send thousands of tiny decisions to a model." The prediction proper is conditional and self-flagged: "If that happens, and I think it will, applications start to look very different. The line between what's decided in code and what's decided by a model gets harder to draw because Jev calls are just mixed into the normal application logic." Note what is and is not being predicted. He predicts *diffusion* - that Jev calls become ambient in ordinary application logic - not that any particular pattern wins, and not that the decisions will be good. The closing line is evidential rather than confident: "Judging by what people are building, that's already starting to happen." Read against the quote-tweet, the two halves fit: if deterministic code was only deterministic because inference was expensive, then cheap inference does not improve those decisions, it just relocates them, and the thing that gets harder is knowing where in your system a probability now sits.

## Not Yet Captured

Of the 25 projects and people named in the article, the vault has a first-hand note on exactly one - pg-jev. Everything below is named by Rosen and absent from the vault, listed for dispatch. The routers, the gates and Foreman are the highest-value gaps, because they are the three patterns where the vault's existing notes raise objections that only the projects themselves can answer.

**Routing**
- JevRouter (Vincent Koc) - models, subagents, skills, MCP tools and CLIs in one candidate set: https://github.com/vincentkoc/jev-router
- agent-router (partme-ai) - chooses coding agent, model and effort level: https://github.com/partme-ai/agent-router
- jev-codex-router (tom-doerr) - per-Codex-turn routing: https://github.com/tom-doerr/jev-codex-router
- hono-jev-router (Marc Bouchenoire) - semantic HTTP routing in Hono: https://github.com/marcbouchenoire/hono-jev-router

**Context filtering**
- Winnow (nicobailon) - judges tool results before they enter a coding agent's context: https://github.com/nicobailon/winnow
- jev-sift (jkudish) - scores files, URLs and snippets before an agent opens them: https://github.com/jkudish/jev-sift
- fast-jev-compaction (tamaratran) - decides what survives Claude Code compaction, verbatim: https://github.com/tamaratran/fast-jev-compaction
- jev-reranker (Joel Hooks) - relevance probability per candidate document: https://github.com/joelhooks/jev-reranker
- blink (Marcel Corso) - the reranker idea applied to code search: https://github.com/marcelcorso/blink

**Tool gating**
- jev-guard (andrewgcodes) - allow/ask/deny on tool calls plus prompt-injection inspection of results: https://github.com/andrewgcodes/jev-guard
- pi-warden (badlogic / Mario Zechner) - decision layer inside the Pi coding agent: https://github.com/badlogic/pi-warden
- Jev Shield (Aviv Sinai) - semantic checks on MCP calls, results and descriptions: https://github.com/avivsinai/jev-shield

**Worker supervision**
- Foreman (ThruWire, Rosen's own) - Jev supervising a Codex worker on the factory floor: https://github.com/thruwire/foreman
- The Foreman AGENTS.md drift post (19 September, 218 likes): https://x.com/JoshARosen/status/2101346654406217965

**Fast control loops**
- Jev Ultrafast (Browser Use) - browser operations and DOM targets as a candidate set: https://github.com/browser-use/jev-ultrafast
- jev-browser (jkudish) - per-step action choice: https://github.com/jkudish/jev-browser
- typesafe-computer-use (TypeSafe AI) - screen to candidate actions to a Jev pick: https://github.com/TypeSafeAI/typesafe-computer-use
- jev-plays-pokemon-red - the clearest illustration of bounded repeated choice: https://github.com/pokemonredexperiments/jev-plays-pokemon-red

**Fuzzy data queries**
- duckdb-jev (colliber): https://github.com/colliber/duckdb-jev
- neo4jev (tom-doerr) - Jev picks which graph relationship to traverse: https://github.com/tom-doerr/neo4jev

**Everything else**
- Magic Jev Ball - decides whether to approve a GitHub PR: https://jevable.com/project/2101129105676861621
- typesafe-adblock (realZachi) - asks Jev whether something looks like an ad: https://github.com/realZachi/typesafe-adblock
- Unclutter (Kitze) - decides which parts of a webpage are unnecessary: https://github.com/kitze/unclutter
- awesome-jev (AnotiaWang) - semantic question against every function in a codebase: https://github.com/AnotiaWang/awesome-jev
- Stefan's designer demo (6,204 likes, the article's most-engaged embed): https://x.com/heystefan_/status/2101369117496521042
- Rosen's own context-management prediction post (18 September, 520 likes), the seed of the context-filtering pattern: https://x.com/JoshARosen/status/2100896143764836460

## Replies

The host tweet had zero replies at capture. The quote-tweet showed one reply in its metadata, but the single `bird replies --all` call permitted for this capture returned empty output after a 120-second timeout, so the reply text was not retrieved. No rate-limit error was reported. Nothing is being withheld here - the reply is simply uncaptured.

## Related

- [[moc - Jev]] - the hub for everything below
- [[Josh Rosen argues context infrastructure should decide later - CortexDB and Statewave preserve raw history because the write path cannot know what will matter]] - the same author's decide-later argument, which the context-filtering pattern operationalizes
- [[Snowflake, Databricks and ClickHouse preview AI architecture by turning inference into a database operator, the semantic layer into agent infrastructure, and agents into a new database workload]] - the same author's inference-as-an-operator thesis, of which the quote-tweet is the general case
- [[TypeSafe's Jev trades string generation for parallel-sampled typed decisions with calibrated probabilities at $0.042 per MTok - the 193x and 444x claims come from four self-built workflow evals]] - what Jev is and what its self-reported numbers rest on
- [[LangChain's Sydney Runkle puts Jev inside the agent loop as classifier middleware - ModelRouterMiddleware picks the model from the latest user message and AutoModeMiddleware reproduces closed harnesses' dangerous-action gate]] - shipped instances of the routing and tool-gating patterns
- [[Cua keeps the candidate menu in application code so Jev only picks an ID - CUA-S1-FORMS is a 706K-parameter form specialist at 99.7 percent against hosted Jev's 83.6, and neither model sees pixels]] - the candidate-menu boundary and the fast control loop, first-hand
- [[Daniel Ch's How to master Jev prescribes a 0.85 and 0.55 confidence-gate ladder under an LLM that still writes - the decision-layer architecture is additive but every number and all three charts are TypeSafe's own]] - the threshold ladder and five workflow archetypes that overlap four of these six patterns
- [[Annabell frames TypeSafe's Jev as a savant for eval verdicts and routing - three question types, 255 choices, 10 score levels, and a Noul with no confidence field]] - cannot abstain, no rationale, context rot
- [[LangChain's Jev-as-a-Judge bench puts Jev's quality-score variance 92 to 913x below three LLM judges at $0.34 against Claude's $28.17 - five weather traces, one human oracle, provider-default sampling]] - the only human-oracle measurement behind worker supervision
- [[Can Bölük's jegrep turns Jev into a semantic grep by scoring grep-ranked candidates with one Noul per file and a Choice for the line range - $0.004 a query, and the Gemini-lite comparison is nowhere in the repo]] and [[jegrep]] - a priced instance of the reranker and context-filtering patterns
- [[pg-jev]] - the fuzzy-data-query project Rosen leads with, captured first-hand
- [[Sutro's jev-align uses GEPA to rewrite Jev's decision criteria from five labeled examples - the demo moves labeled-set ambiguity 49.6 points but full-pool certainty only 0.5]] and [[jev-align]] - the only attempt in the vault to adapt Jev's criteria to your own data, which is what every threshold in this survey silently assumes
- [[Featherless's Simple Jev reproduces Jev's API on stock open models by remapping every answer to a single-token letter and softmaxing only those logits - no classifier head, and the code stamps every answer calibrated False]] and [[simple-jev]] and [[jevlike]] - open reimplementations, one of which stamps every answer `calibrated: False`
- [[BARGAIN routes classification to a small model via a confidence threshold calibrated on 500 oracle labels, cutting costs up to 86 percent more than competing cascades]] - the pre-Jev cascade that shows what calibrating a routing threshold actually costs
- [[LangChain's Paid Media Agent got 40x cheaper and 13x faster by moving calculations out of the model into code]] - the movement in the opposite direction, decisions leaving the model for code
- [[coding agents should be personal canvases not uniform tools]] - badlogic's Pi, the agent pi-warden gates
- [[Cursor strips guardrails and adds dynamic context as models improve, inverting the harness's job]] - the counter-trend to tool gating
- [[agentic search with grep and full-file loading replaces RAG when context windows are large enough]] - the competing answer to context filtering
- [[The bitter lesson of agent harnesses is your helpers are abstractions too - Browser-Use ships a 600-line CDP + SKILL.md harness]] and [[Stagehand's six-layer browser harness—security, caching, identity, credential brokering, skills, and filesystem—is what separates production browser agents from raw-CDP demos]] - what the program surrounding a fast control loop has to provide

## Original Content

> [!quote]- Josh Rosen's quote-tweet - the framing thesis (@JoshARosen, 2026-09-20 12:14:51 UTC, 19 likes / 2 reposts / 1 reply / 2,179 views)
> I think we're dramatically underestimating how many decisions in normal software are only deterministic because inference used to be too expensive.
>
> *Quoting his own host tweet, https://x.com/JoshARosen/status/2101645894818857272 (2026-09-20 12:13:22 UTC, 26 likes / 5 reposts / 0 replies / 1 quote / 53 bookmarks / 3,864 views), whose entire body is the article link:*
>
> > https://x.com/i/article/2101623630488641536

> [!quote]- Full article - "Jev in the Wild: Early Architecture Patterns for System One Models" (Josh Rosen, @JoshARosen, created 2026-09-20 12:13:22 UTC, article id 2101623630488641536, 1,480 words)
> # Jev in the Wild: Early Architecture Patterns for System One Models
>
> *By Josh Rosen (@JoshARosen), article created 2026-09-20T12:13:22.000Z, host tweet https://x.com/josharosen/status/2101645894818857272, article id 2101623630488641536*
>
> Jev has been out for less than a week, but we’re already starting to see patterns in how people are building with it. And they are all over the place.
>
> There are browser agents and coding agent supervisors. People are putting Jev into databases, model routers, security layers, context systems, games, and computer-use loops.
>
> Unlike Jev’s LLM counterparts, which have been at the center of the agentic loop, the common pattern with Jev isn’t giving it control. It’s inserting Jev at a specific decision point in otherwise conventional software.
>
> The result is a much more granular line between deterministic software and probabilistic decisions. Instead of moving the entire workflow into the model, Jev can make a decision and hand control right back to the software.
>
> Here are some of the early architecture patterns showing up across Jev projects.
>
> ## **All Sorts of Routing**
>
> Model routing was one of the most obvious Jev use cases from the start. If you give Jev the request and a set of models, it can decide which model should handle the work.
>
> Projects are already taking this even further. [JevRouter](https://github.com/vincentkoc/jev-router) puts models, subagents, skills, MCP tools, and CLIs into the same candidate set. [agent-router](https://github.com/partme-ai/agent-router) chooses between coding agents as well as the model and effort level. [jev-codex-router](https://github.com/tom-doerr/jev-codex-router) makes that decision for individual Codex turns.
>
> The overall pattern is bigger than model routing, though. Jev can sit in front of a set of agent capabilities and decide which one should handle the work, based on semantics that would otherwise be difficult to encode in rules.
>
> This is already showing up outside AI infrastructure too. [hono-jev-router](https://github.com/marcbouchenoire/hono-jev-router) routes HTTP requests by meaning instead of just URL patterns. The same decision primitive works whether the things behind it are models, tools, agents, or ordinary software.
>
> ## **Context Filtering**
>
> Another group of projects uses Jev to decide what information should make it through to the next stage.
>
> [Winnow](https://github.com/nicobailon/winnow) judges tool results before they enter a coding agent’s context. [jev-sift](https://github.com/jkudish/jev-sift) scores files, URLs, and snippets so an agent only opens the ones that matter. [fast-jev-compaction](https://github.com/tamaratran/fast-jev-compaction) uses Jev to decide what survives Claude Code context compaction while keeping the selected content verbatim.
>
> There are similar experiments around search and RAG. [reranker](https://github.com/joelhooks/jev-reranker) gives each candidate document a relevance probability, while [blink](https://github.com/marcelcorso/blink) applies the same idea to code search.
>
>
> > **Embedded tweet** - Josh Rosen (@JoshARosen), Fri Sep 18 10:34:08 +0000 2026 - 520 likes / 37 reposts / 49 replies - https://x.com/JoshARosen/status/2100896143764836460
> >
> > I predict Jev revolutionizes context management.
> >
> > Picture a big pile of context, memory, markdown files, too much to fit in the context window.
> >
> > Now imagine a just-in-time classifier of that context using Jev.
> >
> > The harness around the LLM provides a built-in “classify context” tool that takes classification instructions from the LLM and returns a subset of context.
> >
> > Way better than conventional embeddings/RAG because you can change the classification semantics per request.
> >
> > Meaning can be derived on read, not write.
>
>
> This is a different approach to context than generating another summary or relying entirely on embeddings. Jev decides what matters for the agentic decision being made right now.
>
> That makes context selection a read-time decision. The system doesn’t have to completely decide what a piece of information means when it stores it.
>
> ## **Tool Gating**
>
> Some of the clearest Jev use cases are showing up at the point where an agent is about to take an action or call a tool.
>
> [jev-guard](https://github.com/andrewgcodes/jev-guard) evaluates tool calls from coding agents and turns the result into allow, ask, or deny decisions. It can also inspect tool results for prompt injection before they return to the agent. [pi-warden](https://github.com/badlogic/pi-warden) puts a similar decision layer directly into the Pi coding agent, checking actions against project rules and feeding the resulting guidance back into the worker.
>
> [Jev Shield](https://github.com/avivsinai/jev-shield) pushes the pattern down to MCP. Tool calls, results, and descriptions can all pass through semantic checks before the system acts on them.
>
> None of these systems need Jev to enforce the policy. That’s done in deterministic code. Conventional software can still own permissions and execution. Jev just provides the semantic judgment that the policy uses.
>
> That gives the policy a way to act on fuzzy conditions without giving the model control over the action itself.
>
> ## **Worker Supervision**
>
> Another place Jev is showing up is above the worker itself. This could give System One models a pretty important role in software factories.
>
> I built [Foreman](https://github.com/thruwire/foreman) around this pattern. A Codex worker does the software engineering while Foreman independently watches the work. Jev continuously assesses the evidence coming off the factory floor, including worker output, Git changes, tests, previous assessments, and the original job.
>
> It looks at questions such as whether the worker is stuck or drifting from its instructions.
>
>
> > **Embedded tweet** - Josh Rosen (@JoshARosen), Sat Sep 19 16:24:18 +0000 2026 - 218 likes / 11 reposts / 20 replies - https://x.com/JoshARosen/status/2101346654406217965
> >
> > Using Jev to catch Codex workers ignoring AGENTS.md.
> >
> > Combine live Codex output, Git changes, and AGENTS.md into one observation
> >
> > Use Jev to score the probability that the worker is drifting from AGENTS.md
> >
> > Steer the active Codex turn when drift crosses a threshold, stopping it if the drift continues
> >
> > Added to Foreman, which automatically watches and steers workers on the software factory floor.
> >
> > https://github.com/thruwire/foreman
>
>
> Jev doesn’t do the coding and it doesn’t control the coding-agent loop. It makes assessments of the work while deterministic policy decides whether Foreman should continue, steer the active worker, stop it, retry, start verification, finish, or escalate.
>
> This creates a clean separation between doing the work and judging the work. We normally ask the same frontier model to do both. A fast decision model makes it practical to move some of those judgments outside the worker.
>
> ## **Fast Control Loops**
>
> Browser and computer use push Jev into a new type of role. It’s less agent-like and more gamer-like. Its job is to observe the current state, make a fast decision, then do it again.
>
> [Browser Use’s Jev Ultrafast](https://github.com/browser-use/jev-ultrafast) constructs a set of possible browser operations and DOM targets, then has Jev pick one. A small language model is only needed when the browser actually has to generate text. [jev-browser](https://github.com/jkudish/jev-browser) uses a similar architecture and uses Jev to choose an action on each step.
>
> The same architecture is showing up in computer use. [typesafe-computer-use](https://github.com/TypeSafeAI/typesafe-computer-use) reads the screen, constructs possible actions, and uses Jev to decide what to do, such as where to move the mouse or what to click on.
>
> Game applications of Jev are the easiest way to see this pattern. Projects have Jev playing [Pokémon](https://github.com/pokemonredexperiments/jev-plays-pokemon-red), driving cars, and controlling other simulations. The surrounding program defines what the model is allowed to do. Jev repeatedly chooses among those bounded actions.
>
> This is one of the places where Jev does sit directly inside a loop, but it still doesn’t own all that much of the system around it. Code controls the environment and execution, and the model only makes the fuzzy decisions at key times.
>
> ## **Fuzzy Data Queries**
>
> Jev is also starting to show up directly in the data layer, where a lot of decisions have traditionally been limited to what we can express in queries and rules. And it’s very cool!
>
> [pg-jev](https://github.com/realZachi/pg-jev) puts Jev directly inside Postgres. A SQL query can filter rows based on whether a customer sounds angry, rank products by how luxurious they seem, or classify a ticket by which team should handle it.
>
> The rest of the query stays ordinary SQL. Instead of only writing deterministic predicates like country = 'US' or revenue > 100000, you can add conditions whose answers depend on the meaning of the data.
>
> And Postgres isn’t the only experiment. There are already Jev extensions for [DuckDB](https://github.com/colliber/duckdb-jev), while [neo4jev](https://github.com/tom-doerr/neo4jev) brings the same idea to graphs by using Jev to decide which relationship to follow through Neo4j.
>
> This opens up a pretty large category of data use cases. Warehouses are full of classifications, rankings, filters, and business rules that are easy to describe in English but hard to turn into SQL. Jev lets those decisions happen at query time, directly against the data that’s already there.
>
> ## **And Then There’s Everything Else**
>
> Some of the most fun Jev projects are people finding completely new places to put a probabilistic decision.
>
> There’s a [Magic Jev Ball](https://jevable.com/project/2101129105676861621) that looks at a GitHub PR and decides whether you should approve it. There’s an [ad blocker](https://github.com/realZachi/typesafe-adblock) that asks Jev whether something actually looks like an ad, [Unclutter](https://github.com/kitze/unclutter) deciding what parts of a webpage are unnecessary, and [Every](https://github.com/AnotiaWang/awesome-jev) asking a semantic question against every function in a codebase.
>
> People are also using Jev for autonomous cars, mobile phone control, semantic code search, sponsor detection in YouTube videos, and even scoring every sentence in a video to flag when someone dodges a question.
>
> And then there are experiments like [Stefan’s](https://x.com/heystefan_/status/2101369117496521042), which are mostly about seeing what happens when you put Jev somewhere nobody would have thought to put a model before.
>
>
> > **Embedded tweet** - Stefan (@heystefan_), Sat Sep 19 17:53:33 +0000 2026 - 6204 likes / 290 reposts / 130 replies - https://x.com/heystefan_/status/2101369117496521042
> >
> > when a designer gets access to Jev
> >
> > *(video attached: https://video.twimg.com/amplify_video/2101367981486051328/vid/avc1/3620x2160/s2ygWn-SPWBDHupm.mp4?tag=29)*
>
>
> Even the TypeSafe's own Jev playgrounds lean into this. One example asks whether putting Luke Skywalker between two pieces of toast makes a “Jedi sandwich” a sandwich.
>
> A lot of these aren’t serious applications, and that’s kind of the point. People are playing with a new primitive and figuring out where it works. We’re less than a week in, and I expect the weird stuff to keep getting weirder.
>
> ## **Where Does Jev Go?**
>
> After looking through all these projects, the answer to where Jev fits seems to be almost everywhere.
>
> And I think that’s basically TypeSafe’s bet. Jev is cheap and fast enough that we start rewriting applications to send thousands of tiny decisions to a model.
>
> If that happens, and I think it will, applications start to look very different. The line between what’s decided in code and what’s decided by a model gets harder to draw because Jev calls are just mixed into the normal application logic.
>
> Judging by what people are building, that’s already starting to happen.

## Links

**The source**
- [Jev in the Wild: Early Architecture Patterns for System One Models](https://x.com/i/article/2101623630488641536) - the article itself (id 2101623630488641536, created 2026-09-20 12:13:22 UTC)
- [Host tweet](https://x.com/JoshARosen/status/2101645894818857272) - 26 likes / 5 reposts / 0 replies / 53 bookmarks / 3,864 views
- [Rosen's quote-tweet with the thesis](https://x.com/JoshARosen/status/2101646268032307475) - 19 likes / 2 reposts / 1 reply / 2,179 views

**Embedded tweets, in article order**
- [Josh Rosen on Jev and context management](https://x.com/JoshARosen/status/2100896143764836460) - 18 September, 520 likes, "Meaning can be derived on read, not write"
- [Josh Rosen on Foreman catching AGENTS.md drift](https://x.com/JoshARosen/status/2101346654406217965) - 19 September, 218 likes
- [Stefan, "when a designer gets access to Jev"](https://x.com/heystefan_/status/2101369117496521042) - 19 September, 6,204 likes, video

**Routing**
- [JevRouter](https://github.com/vincentkoc/jev-router) - models, subagents, skills, MCP tools and CLIs in one candidate set
- [agent-router](https://github.com/partme-ai/agent-router) - picks coding agent, model and effort level
- [jev-codex-router](https://github.com/tom-doerr/jev-codex-router) - routes individual Codex turns
- [hono-jev-router](https://github.com/marcbouchenoire/hono-jev-router) - routes HTTP requests by meaning rather than URL pattern

**Context filtering**
- [Winnow](https://github.com/nicobailon/winnow) - judges tool results before they enter a coding agent's context
- [jev-sift](https://github.com/jkudish/jev-sift) - scores files, URLs and snippets so an agent opens only what matters
- [fast-jev-compaction](https://github.com/tamaratran/fast-jev-compaction) - decides what survives Claude Code compaction, kept verbatim
- [jev-reranker](https://github.com/joelhooks/jev-reranker) - relevance probability per candidate document
- [blink](https://github.com/marcelcorso/blink) - the same reranking idea for code search

**Tool gating**
- [jev-guard](https://github.com/andrewgcodes/jev-guard) - allow, ask or deny on tool calls, plus prompt-injection inspection of results
- [pi-warden](https://github.com/badlogic/pi-warden) - decision layer inside the Pi coding agent
- [Jev Shield](https://github.com/avivsinai/jev-shield) - semantic checks on MCP calls, results and descriptions

**Worker supervision**
- [Foreman](https://github.com/thruwire/foreman) - Rosen's own supervisor watching a Codex worker

**Fast control loops**
- [Browser Use's Jev Ultrafast](https://github.com/browser-use/jev-ultrafast) - browser operations and DOM targets as the candidate set
- [jev-browser](https://github.com/jkudish/jev-browser) - one Jev action choice per step
- [typesafe-computer-use](https://github.com/TypeSafeAI/typesafe-computer-use) - screen to candidate actions to a Jev pick
- [jev-plays-pokemon-red](https://github.com/pokemonredexperiments/jev-plays-pokemon-red) - bounded repeated choice, made visible

**Fuzzy data queries**
- [pg-jev](https://github.com/realZachi/pg-jev) - Jev inside Postgres, callable from SQL
- [duckdb-jev](https://github.com/colliber/duckdb-jev) - the DuckDB extension
- [neo4jev](https://github.com/tom-doerr/neo4jev) - Jev picks which Neo4j relationship to follow

**Everything else**
- [Magic Jev Ball](https://jevable.com/project/2101129105676861621) - decides whether you should approve a GitHub PR
- [typesafe-adblock](https://github.com/realZachi/typesafe-adblock) - asks Jev whether something looks like an ad
- [Unclutter](https://github.com/kitze/unclutter) - decides which parts of a webpage are unnecessary
- [awesome-jev](https://github.com/AnotiaWang/awesome-jev) - asks a semantic question against every function in a codebase
- [Stefan's experiment](https://x.com/heystefan_/status/2101369117496521042) - the article's link to the designer demo
