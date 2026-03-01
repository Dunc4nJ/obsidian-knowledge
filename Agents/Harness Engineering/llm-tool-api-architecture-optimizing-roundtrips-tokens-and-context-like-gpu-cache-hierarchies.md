---
created: 2026-03-01
description: Sebastian Aaltonen's comprehensive framework for LLM tool API optimization — covering closed-loop self-critique workflows, stateless architecture implications, cache/batch analogies from GPU programming, system prompt alternatives via on-demand documentation tools, and sub-task context compression.
source:
  - https://x.com/SebAaltonen/status/2027775877384139200
  - https://x.com/SebAaltonen/status/2027847942527127556
  - https://x.com/SebAaltonen/status/2027848417607577748
  - https://x.com/SebAaltonen/status/2027850519864295903
  - https://x.com/SebAaltonen/status/2027851234267349443
  - https://x.com/SebAaltonen/status/2028028908432400423
  - https://x.com/SebAaltonen/status/2028030214484210135
  - https://x.com/SebAaltonen/status/2028031908420989374
  - https://x.com/SebAaltonen/status/2028034389452505457
  - https://x.com/SebAaltonen/status/2028047974945693707
  - https://x.com/SebAaltonen/status/2028049518055268594
  - https://x.com/SebAaltonen/status/2028052589539975389
  - https://x.com/SebAaltonen/status/2028053828629606587
  - https://x.com/SebAaltonen/status/2028054464221872306
  - https://x.com/SebAaltonen/status/2028059270156091438
type: learning
---

## Key Takeaways

### Closed-Loop Tool Optimization

The core pattern is a closed-loop tool optimization cycle: instead of manually reviewing LLM-to-tool logs and guessing why the model made suboptimal calls, Sebastian added a dedicated feedback tool that lets the model report what went wrong directly. The model knows *why* it called a tool, so it can flag performance warnings, syntax misunderstandings, and awkward workarounds far more accurately than a human reading raw logs. This is the concrete mechanism for what [[designing agent tools is an iterative art shaped by model capabilities not fixed engineering rules]] describes abstractly — the feedback tool makes the iteration loop tight and data-driven. The meta-move of feeding LLM-tool logs back to the same AI for analysis is powerful because the model that made the calls has the best intuition for the tool APIs it used and why it used them suboptimally. The 10x improvement came from compounding several simple optimizations across all the dimensions described below — fewer roundtrips, fewer tokens per roundtrip, and letting the LLM generate its own context rather than hacking prompts with grep.

### LLM-Tool Architecture Fundamentals

Everything in Sebastian's framework flows from one architectural reality that most LLM tool builders underestimate: the server connection is stateless. Every single request to the LLM must include the full system prompt, the complete conversation history, and every prior tool call plus its response. The LLM remembers nothing between calls. This means the context grows monotonically with each roundtrip, and every roundtrip retransmits *all* prior tokens. Sebastian frames this as a "massive amplification of data and network traffic and tokenization" — a naive implementation compounds cost quadratically as the conversation lengthens. This gives you exactly two optimization targets: minimize the number of roundtrips (since each one retransmits everything), and minimize the tokens added per roundtrip (since those tokens get retransmitted in every subsequent call). Roundtrips are the more important target because they multiply *all* accumulated tokens, but the two interact multiplicatively — reducing both compounds the gains. This framing is what connects the cache optimization, batch processing, and system prompt themes below: they're all specific strategies for attacking one or both of these targets.

### Cache & Batch Optimization

Sebastian's most distinctive contribution is applying GPU and CPU cache optimization mental models to LLM tool design. Bringing needless data into L1 cache is expensive because it evicts useful data and wastes bandwidth — bringing needless information into the LLM context is *exactly* the same problem. Irrelevant tokens waste money, add latency, and degrade reasoning quality by forcing the model to attend to noise. The SQL analogy deepens this: imagine accessing a remote database without SQL, downloading full tables to the client, processing locally, and uploading back. That's what naive tool APIs do — they dump full results into the LLM context and let the model parse through them. Instead, tool APIs should let the LLM express operations that execute *inside* the system, like SQL queries execute inside the database server. The system does the heavy processing with native code; only the final, compact result crosses the LLM boundary. Sebastian's concrete implementation uses opaque result handles — tool calls return handles rather than full data, and the LLM can chain handles from one tool to another without ever inspecting the intermediate results. This works like Linux pipes: data flows through the pipeline without materializing at each stage. When the LLM finally needs to see results, it calls a print command with filtering support, typically as the last step in a chain. This "filter-on-print" pattern means an entire multi-step operation can happen in a single roundtrip, with only the relevant final output entering the context. The connection to the architecture fundamentals is direct: opaque handles minimize tokens per roundtrip, while chaining operations within a single tool call minimizes the number of roundtrips — attacking both optimization targets simultaneously.

### System Prompt Alternatives

The stateless architecture insight from above makes massive system prompts particularly costly: those thousands of lines aren't sent once, they're resent on *every single tool call roundtrip*. Sebastian identifies the temptation clearly — stuff everything into the system prompt so the LLM never needs an extra roundtrip to find information — and then dismantles it. The naive alternative of regex-matching the user prompt for keywords to select a specialized system prompt fails because there are too many ways to express the same task, and the LLM often internally decomposes tasks into subtasks that the regex can't anticipate. The better approach is to give the LLM tool APIs to fetch documentation on demand, letting it build its own context. This is [[putting yourself in the agents shoes is the unifying framework for agentic system design|thinking from the agent's perspective]] — the LLM understands what it's doing and can request exactly the documentation it needs for a particular subtask, which both reduces token waste and makes the system more reliable and extensible. Sebastian applies the cache optimization lens here too via a tree-depth analogy: deep hierarchies (like binary trees) require many hops to find information, each hop being an expensive roundtrip. Wide, shallow structures (like a 64-tree, where two levels cover 4096 elements versus 12 levels for a binary tree) minimize hops. You might even embed the shallowest level — say, 10 top-level documentation categories — directly in the system prompt to avoid one extra roundtrip, as long as it stays compact. The key balance is that slight extra context around a topic can help the model understand better, but unrelated noise degrades focus and wastes tokens — the same L1 cache eviction principle applied to documentation retrieval.

### Sub-Task Splitting

The final piece of Sebastian's framework addresses what happens when tasks grow too large for a single LLM context to handle efficiently. Multiple levels of LLMs can decompose tasks into subtasks, but the critical insight is what happens at task boundaries: if you send the full history to every subtask, you're shipping massive amounts of irrelevant context that gets retransmitted on every tool call within that subtask — the stateless amplification problem compounded across task levels. Instead, context should be compressed and distilled at task boundaries, passing only what's relevant to the subtask. This connects back to every prior theme: it's the cache optimization principle (don't bring irrelevant data into the working set), applied at the task decomposition level rather than the individual tool call level. As [[harness engineering improved a coding agent 13 points by changing only system prompts tools and middleware|harness engineering research shows]], these architectural decisions about context management can dramatically improve agent performance without touching the underlying model.

## External Resources

- [Lessons from Building Claude Code: Seeing like an Agent (trq212)](https://x.com/trq212/status/2027463795355095314) — the article Sebastian was responding to, covering Claude Code's tool design philosophy
- [Sebastian Aaltonen's Twitter](https://x.com/SebAaltonen) — author, known for GPU/rendering optimization work, applying those mental models to LLM tooling

## Original Content

### Thread 1: Optimization Workflow

> @SebAaltonen — 2026-02-28 16:00 UTC
>
> I have been optimizing our custom LLM runner tool APIs recently. Easy to get 2x gains by rather simple improvements. I'd say our tool is over 10x faster now than it was a week ago and does a better job. Less LLM<->tools roundtrips, significantly less tokens.
>
> Lean on the LLM to generate the context with tool API calls. Don't try to hack the prompt yourself (by grepping the prompt for example). LLM knows best what info it needs and how it operates.
>
> There's of course a lot of manual work to go through the logs and the LLM<->tool API inputs/outputs. So I started feeding these logs back to the same AI to analyze them, and since it's the same AI that is doing those tool calls, it also has pretty good intuition for the tool APIs it needs and why it used them in unoptimal way. Then I improve the APIs accordingly and run the same prompts again to see whether the problems are gone.
>
> I also recently automated our LLM tool API improvements even further. I added a new tool API for the LLM to directly give us feedback log. Performance warnings, invalid API calls (syntax misunderstanding), etc. The LLM knows why it called some tool, so it knows the reasoning and can dump extra warning logs easily. This works surprisingly well.
>
> LLM tooling is yet another example where deep understanding and optimization matters. You have to analyze what is happening and why and fix the issues. Then validate and benchmark the results.
>
> [Original post](https://x.com/SebAaltonen/status/2027775877384139200)

### Thread 2: Main Architecture Thread

> @SebAaltonen — 2026-02-28 20:46 UTC
>
> A thread about my LLM tool API design. The retweeted post is about my optimization workflow, but I didn't talk about my architecture.
>
> Let's talk about the tool interface my LLM runner provides to the LLM. It's all about optimizing the accesses and roundtrips. Familiar to me :)
>
> [Original post](https://x.com/SebAaltonen/status/2027847942527127556)

> @SebAaltonen — 2026-02-28 20:48 UTC
>
> The first thing you need to understand: LLM runs in server. The server connection is stateless. Every request is fully separate. Server doesn't remember any history. You need to provide the history manually on every request. History can be 90%+ of the whole communication...
>
> [Original post](https://x.com/SebAaltonen/status/2027848417607577748)

> @SebAaltonen — 2026-02-28 20:56 UTC
>
> Runner sends the initial prompt to LLM and then LLM responds with a tool call (json). Runner runs the requested tool. Now it calls the LLM again, providing the prompt again and the LLMs previous response (includes the tool call + parameters) followed by the tool call response. The LLM then responds with the next tool call, etc, etc. The history (context) grows all the time. Finally the LLM has enough information in the context to do the actual thing it wanted to do -> it calls tools again, possible multiple iterations, each of them sending the history back so that the LLM knows what it has been doing and what it should do next. This is a massive amplification of data and network traffic and tokenization and LLM work if done naively.
>
> [Original post](https://x.com/SebAaltonen/status/2027850519864295903)

> @SebAaltonen — 2026-02-28 20:59 UTC
>
> We have to optimization targets: minimize the amount of tokens we dump to the LLM and minimize the amount of roundtrips, since each roundtrip sends all tokens again. Roundtrips also add latency as you need to send data to server and wait for the LLM again. Thus roundtrips are the most important thing to optimize. But since each roundtrip sends all the tokens again, optimizing the number of tokens each tool call adds is massively important too. Both must be optimized.
>
> [Original post](https://x.com/SebAaltonen/status/2027851234267349443)

> @SebAaltonen — 2026-03-01 09:07 UTC
>
> Decided to post different topics as different threads. I will keep this thread as a collection thread. To be continued...
>
> [Original post](https://x.com/SebAaltonen/status/2028034389452505457)

> @SebAaltonen — 2026-03-01 10:46 UTC
>
> *(Collection link — quotes the system prompt sub-thread)*
>
> [Original post](https://x.com/SebAaltonen/status/2028059270156091438)

### Thread 3: Cache/Batch Optimization

> @SebAaltonen — 2026-03-01 08:45 UTC
>
> LLM tooling optimization resembles CPU cache optimization and data structure optimization (how many hops/misses to find the important thing). Bringing needless data to L1$ is expensive and trashes other data. Bringing needless info to LLM context is similar.
>
> LLM tooling optimization also resembles batch processing and database query optimization and distributed processing. Data is inside your system, LLM runs commands to modify it. If you do lots of tool calls modifying small pieces of data, you end up with massive amount of roundtrips. If you instead run tool calls that expand to efficient batch processing code running inside your system, you send much less data between the system<->LLM and you end up with much fewer LLM roundtrips.
>
> [Original post](https://x.com/SebAaltonen/status/2028028908432400423)

> @SebAaltonen — 2026-03-01 08:50 UTC
>
> Imagine not having SQL and accessing a database remotely. You download full tables from the server and implement the query logic in your client. Then the client sends the modified table back (single blob). Massive amount of needless data sent between server and client.
>
> Instead, SQL allows the client to express the operations remotely, and the database server runs it locally. In the best case the database is fully loaded to server memory, so all of these operations run between the CPU<->cache<->RAM of the server. That's super fast compared to sending all table rows over the internet. Finally, the server sends the final row set back to the client. This is significantly less data.
>
> The same optimization applies to LLM<->tools communication. Your tool APIs should be batchable and they must express the operation in a compact way that doesn't require sub-step results to be sent to the LLM for parsing. LLM is not great at parsing huge amount of structured data. It can do it, but it's slow and can make mistakes. Instead do this inside your system/tool side, using efficient native code.
>
> [Original post](https://x.com/SebAaltonen/status/2028030214484210135)

> @SebAaltonen — 2026-03-01 08:57 UTC
>
> Our tool APIs return opaque result handles. LLM can pass the opaque handle directly from one tool to another, and chain operations inside one tool call to avoid multiple tools<->LLM roundtrips (which must resend the whole history due to stateless LLM server design). Works a bit like Linux pipes.
>
> If the LLM needs to know what's inside a handle, it can ask to print it. Printing supports filtering. Often the print command is the last command in the chain (inside the same tool call = all in 1 roundtrip), allowing the creation of chained operations in similar way to SQL and letting the LLM only know the final results, instead of bloating the context with tokens of all sub-results.
>
> [Original post](https://x.com/SebAaltonen/status/2028031908420989374)

### Thread 4: System Prompt Alternatives

> @SebAaltonen — 2026-03-01 10:01 UTC
>
> It's tempting to give the LLM a MASSIVE system prompt with all the information it needs to perform all the potential task API calls. This way you don't need to think about it and you ensure there's no extra roundtrips for the LLM to find the information/APIs it needs. The problem is that this bloats the token count significantly.
>
> LLM calls (to server) are stateless, you need to send the system prompt (and history) again for every tool call, so that the LLM knows what it was doing and why. If the system prompt is thousands of lines, those lines are resent for every tool call.
>
> Let's discuss the alternatives for a massive system prompt...
>
> [Original post](https://x.com/SebAaltonen/status/2028047974945693707)

> @SebAaltonen — 2026-03-01 10:07 UTC
>
> I already discussed flexible/batchable tool interfaces in this post: https://x.com/SebAaltonen/status/2028028908432400423
>
> There's basically no limit to tool flexiblity. You can go as far as offering tool APIs to run python or terminal commands in the system. Search tools are common. Instead of the LLM going through your project, it can find the info faster. Flexibility and batchability are of course crucial for cutting down the number of roundtrips and the extra data that needs to be transmitted between the system and the LLM. Similar idea as SQL-queries. Do the heavy work locally, minimize external communication.
>
> [Original post](https://x.com/SebAaltonen/status/2028049518055268594)

> @SebAaltonen — 2026-03-01 10:19 UTC
>
> Tree data structures are common in programming. We all know that deep tree structures (such as binary tree) results in lots of cache misses, since search goes through many hops. Trees with wider nodes are significantly flatter. We are using a two level sparse bitmap for our index joins for example. It's a 64-tree. two level accesses = 4096 elements. Binary tree requires 12 levels for that.
>
> Similarly when LLM is searching for documentation or information, you don't want super deep hierarchy. You could even embed the top level to the system prompt if it's super small to avoid one extra hop (listing ~10 top level categories of documentation for example inside the API spec instead of having to call API that lists them). Folder structures and .md files are a bit similar. If you have a super deep structure with lots of info, it takes the LLM a lot more effort to dig through that.
>
> But, it's important to avoid extra waste of tokens too. If you print out something to the LLM context, you want to use that. It's fine to have slight bit of extra info related to the topic in it, maybe that even helps the AI to understand it better, but lots of extra info (tokens) adds costs, adds latency and makes reasoning worse. AI needs to be able to focus too. Unrelated noise is bad.
>
> [Original post](https://x.com/SebAaltonen/status/2028052589539975389)

> @SebAaltonen — 2026-03-01 10:24 UTC
>
> It's tempting to regexp the user prompt to find keywords and give the LLM a specialized system prompt. But there's so many different ways to ask for the same task and the LLM often internally splits the task to many subtasks.
>
> It's much better approach to provide the LLM a tool API for asking the information it needs. The LLM understands what it is doing and is able to ask for documentation when it needs it. This greatly cuts down the token costs and makes the system more reliable and easier to extend. You don't need to hard code different system prompts. Give LLM access to all the tools and documentation and let it build the context itself. It knows better what it needs for that particular (sub)task.
>
> [Original post](https://x.com/SebAaltonen/status/2028053828629606587)

> @SebAaltonen — 2026-03-01 10:27 UTC
>
> Multiple levels of LLMs connected to each other can be used to split tasks to sub-tasks and LLMs can distill/compress relevant data. If you send whole history to every sub-task, it's going to bloat the context massively with completely irrelevant data. And context is resent per tool API call. There are many other ways to compact/compress the history. But task boundaries are the easiest way to do it.
>
> [Original post](https://x.com/SebAaltonen/status/2028054464221872306)

### Notable Replies

> @clwdbot — 2026-02-28
>
> the feedback tool API is the most underrated part of this. you're essentially letting the LLM design its own debugging interface.
>
> most teams optimize tool APIs by guessing what the model needs. you're closing the loop by asking the model directly. that's a fundamentally different approach — and it explains the 10x, because human intuition about what an LLM "should" need is wrong more often than we admit.
>
> [Reply](https://x.com/clwdbot/status/2027836802590298577)

## Sources

- [Sebastian Aaltonen's Twitter](https://x.com/SebAaltonen) — author, GPU/rendering optimization engineer applying hardware performance mental models to LLM tooling
- [Lessons from Building Claude Code: Seeing like an Agent (trq212)](https://x.com/trq212/status/2027463795355095314) — the article that prompted the original post
