---
created: 2026-03-16
description: As AI agents bypass application layers and operate directly on data through tight read-reason-write loops, the database evolves from passive storage into the execution substrate, memory layer, and coordination layer for intelligent systems.
source: https://x.com/siddontang/status/2033391893883818470
---

# Databases are becoming the runtime layer for AI agents as application logic collapses into the data layer

## Key Takeaways

The core argument is that the traditional Human → Application → Database stack is collapsing into Human → AI Agent → Database, because [[agents need a database because stateless reasoning cores require stateful storage]] — agents operate directly on data in tight read-reason-write loops at machine speed, bypassing the application layer entirely. Workflows are generated on the fly rather than hardcoded, and interfaces become conversational rather than screen-based.

This has architectural consequences that echo the themes in [[agentic software engineering requires six pillars beyond the agent itself to survive production]]: databases must now handle high-frequency reasoning loops (thousands of queries per task), mixed OLTP/OLAP workloads in the same session, long-lived versioned memory across sessions, and isolation for millions of concurrent agent contexts. The database becomes memory layer, coordination layer, and execution environment — closer to an OS than a filing cabinet.

The economics shift matters too. SaaS pricing (seats, subscriptions, provisioned capacity) assumed predictable human traffic patterns. Agent workloads are bursty, unpredictable, and concurrent in ways that break fixed-capacity models. The author argues for elastic compute on object storage with usage-based pricing (RU economics), pointing to TiDB X as an example. This parallels the broader pattern where [[seven runtime failures emerge when demo agents meet production distributed systems]] — infrastructure designed for human usage patterns fails under agent-scale load.

The historical analogy is compelling: mainframes → PCs (desktop OS wins), desktop → cloud (cloud platform wins), cloud → AI (data substrate wins). If applications become disposable because AI makes building them near-free, the moat shifts to whoever owns the data layer.

## External Resources

- [SaaS is Dead — The Rise of Result as a Service](https://x.com/siddontang/status/2032696118988189742) — the author's prior essay arguing AI collapses software-building costs to near zero

## Original Content

> @siddontang (siddontang) — Mon Mar 16 2026 — 22 likes, 5 retweets, 2 replies
>
> **When Databases Start Eating Software — The Paradigm Shift in the AI Era**
>
> **Software Once Ate the World**
>
> In 2011, Marc Andreessen wrote a famous essay:
>
> > Software is eating the world.
>
> He was right. For fifteen years, applications defined everything:
>
> - Business logic lived in application code.
> - Workflows were hardcoded into software layers.
> - User interfaces shaped how humans interacted with data.
> - Value creation meant building better applications.
>
> In that world, databases were infrastructure. Important, yes — like plumbing is important. But secondary. The application was the brain. The database was the filing cabinet.
>
> Applications owned the intelligence.
>
> Databases only stored state.
>
> That was the model. And it worked — for a world where humans were the only users.
>
> **AI Is Moving Logic Downward**
>
> AI didn't just add features to applications.
>
> It changed where logic lives.
>
> Think about what a traditional application does: a developer writes rules. Those rules are compiled. Users trigger them through clicks, forms, and API calls. The application mediates every interaction between the human and the data.
>
> Now watch what AI agents actually do:
>
> - They read data — sometimes millions of rows, across multiple tables, in a single reasoning step.
> - They reason — forming hypotheses, evaluating options, making decisions.
> - They write new data — updating state, creating records, modifying schemas.
> - They trigger actions — calling APIs, sending messages, spawning other agents.
>
> Notice what's missing?
>
> The application layer.
>
> Agents don't navigate menus. They don't fill out forms. They don't follow pre-defined workflows. They operate directly on data — reading, reasoning, writing, in tight loops.
>
> And those loops are fast. An agent might execute hundreds of read-reason-write cycles in the time it takes a human to fill out a single form.
>
> Which means:
>
> > The center of execution is shifting — from application logic to the data layer itself.
>
> This isn't a small change. It's a tectonic shift in how computing works.
>
> **The Collapse of the Application Layer**
>
> For decades, we built software in layers:
>
> > Human → Application → Database
>
> The application sat in the middle, doing the heavy lifting. It encoded business rules. It enforced workflows. It provided guardrails. It rendered interfaces. Without the application, the database was just a pile of tables.
>
> Now look at the emerging architecture:
>
> > Human → AI Agent → Database → Result
>
> The application layer is collapsing. Not disappearing entirely — but becoming dramatically thinner. Because:
>
> - Workflows are generated, not coded. An agent doesn't follow a fixed flowchart. It observes the data, reasons about the goal, and constructs the workflow on the fly.
> - Interfaces are conversational. Instead of navigating a 47-screen enterprise UI, you describe what you want. The agent figures out how to get it.
> - Business logic is adaptive. Rules aren't hardcoded — they emerge from the agent's understanding of context, constraints, and objectives.
>
> In my previous article, "SaaS is Dead — The Rise of Result as a Service," I argued that AI collapses the cost of building software to near zero. When anyone can generate an application in minutes, the application layer loses its moat.
>
> Here's the next domino:
>
> If applications become disposable, what remains?
>
> The data layer. Your data is the one thing that can't be regenerated. It's the substrate that every agent, every workflow, every decision depends on.
>
> The application was king because building it was hard. Now that building is easy, the crown passes to the layer underneath.
>
> **Why Databases Start Absorbing Software**
>
> Applications historically did three things:
>
> 1. Managed state — tracking what happened, what's happening, what should happen next.
> 2. Enforced consistency — making sure data stayed valid across operations.
> 3. Executed logic — running the rules that turned inputs into outputs.
>
> AI agents are absorbing all three.
>
> They manage context dynamically — maintaining conversation history, task state, and world models across sessions.
>
> They make decisions autonomously — evaluating trade-offs, handling exceptions, adapting to new information.
>
> They branch workflows on the fly — no pre-defined paths, no static decision trees.
>
> But here's the catch: to do all of this well, agents need a data layer that's far more capable than a traditional database.
>
> The database must now handle:
>
> - High-frequency reasoning loops. An agent might query the database thousands of times in a single task. Latency matters at a scale it never did for human users.
> - Mixed transactional and analytical workloads. Agents don't distinguish between "write this record" and "analyze this trend." They do both, constantly, in the same session.
> - Long-lived memory with versioning. An agent's context isn't a single session — it's an evolving knowledge base that persists across days, weeks, months. The database must support memory that grows, branches, and merges.
> - Isolation for millions of logical contexts. When ten million agents are running simultaneously, each needs its own consistent view of the world. That's not a scaling challenge — it's an architectural one.
>
> The database stops being passive storage.
>
> It becomes the execution substrate — the foundation on which intelligent systems run.
>
> **The Economics Shift**
>
> There's another shift happening underneath, and it's just as important.
>
> In the SaaS era, pricing was built for humans:
>
> - Seats — because humans are countable.
> - Subscriptions — because human usage is predictable.
> - Provisioned capacity — because you can forecast how many humans will click buttons next Tuesday.
>
> None of this works for AI agents.
>
> Agent workloads are inherently unpredictable. An agent might be dormant for hours, then spike to thousands of queries per second when triggered. It might spin up ten sub-agents, each making concurrent requests, then disappear entirely. Another agent might run a background task for three days straight.
>
> You cannot provision infrastructure for this. Fixed capacity means you're either paying for idle resources or hitting limits at the worst possible time.
>
> What you need instead:
>
> - Elastic compute — scaling from zero to massive and back, automatically.
> - Object-storage durability — data that persists reliably without expensive always-on storage engines.
> - Usage-based pricing — pay for what you actually consume, not what you might consume.
>
> This is why architectures like TiDB X matter.
>
> - Built on object storage — durable, low-cost, infinite capacity.
> - Compute and storage fully separated — scale them independently.
> - Charged by query volume (RU-based economics) — not by provisioned servers sitting idle at 3 AM.
>
> Designed for unpredictable, bursty, agent-driven workloads. Not for the steady, plannable traffic of human users clicking through web apps.
>
> The economics of AI workloads demand a fundamentally different infrastructure model.
>
> **AI Workloads Are Not Human Workloads**
>
> This point deserves emphasis, because most database architectures were designed for a world that no longer exists.
>
> Human-generated traffic has comfortable properties: it follows business hours, it grows linearly with headcount, it has predictable read/write ratios, and schema changes happen quarterly (if you're lucky).
>
> Machine-generated traffic breaks all of these assumptions:
>
> - Concurrency explodes. One user might spawn a hundred agents, each making independent requests.
> - Frequency is orders of magnitude higher. An agent processes data at machine speed, not human speed.
> - Patterns are unpredictable. Today's query pattern might look nothing like tomorrow's, because the agent is learning and adapting.
> - Schema evolution is continuous. Agents create new data structures on the fly — new tables, new columns, new relationships — as they discover what they need.
>
> To serve these workloads, databases must support:
>
> - Instant branching — create isolated environments in milliseconds, not minutes.
> - Workload isolation — one runaway agent can't starve others of resources.
> - Multi-tenant isolation — millions of logical databases sharing physical infrastructure safely.
> - Elastic scaling — not "scale up in 15 minutes" but "scale up now."
>
> Without manual planning. Without capacity reservations. Without a DBA making decisions at 2 AM.
>
> The database must be as autonomous as the agents it serves.
>
> **Database as a Runtime**
>
> If we zoom out, something profound emerges.
>
> The database is no longer just a place to store rows and run queries. It's evolving into something much larger:
>
> - The memory layer — where agents persist context, knowledge, and learned patterns across sessions. Not just data storage, but cognitive continuity.
> - The coordination layer — where multi-agent systems synchronize state, negotiate resources, and maintain consistency. The database becomes the shared nervous system.
> - The execution environment — where data-driven logic runs natively, close to the data, without the overhead of moving bytes through application layers.
>
> Here's the key insight:
>
> Agents don't run inside applications.
>
> They run through data.
>
> Every reasoning step reads data. Every decision writes data. Every action updates state. The data layer isn't something agents interact with — it's the medium they exist in.
>
> > The database becomes the runtime layer for intelligence.
>
> This is a fundamentally different role than "storage backend." It's closer to what an operating system is for traditional software — the environment in which everything else executes.
>
> **The Bigger Pattern**
>
> This is not about one product or one company. It's about a structural shift in computing.
>
> In the SaaS era, applications were the center of gravity. You built applications, and databases served them. The application was the product. The database was a dependency.
>
> In the AI era, data becomes the center of gravity. You deploy agents, and they orbit the data layer. The data is the product. Applications are generated as needed.
>
> When the center of gravity moves, the power layer moves with it.
>
> We've seen this pattern before:
>
> - Mainframes → PCs: power moved from centralized machines to distributed desktops. Whoever owned the desktop OS won.
> - Desktop → Cloud: power moved from local machines to networked services. Whoever owned the cloud platform won.
> - Cloud → AI: power is moving from the application layer to the data layer. Whoever owns the data substrate will win.
>
> Each shift looked incremental at the beginning. None of them were.
>
> The companies that recognized these shifts early — Microsoft with Windows, Amazon with AWS, Google with search — defined their respective eras. The companies that dismissed them as "just infrastructure" or "just a feature" got left behind.
>
> **Final Thought**
>
> Software once ate the world.
>
> Now something quieter is happening.
>
> Databases are starting to eat software.
>
> Not because applications disappear — but because the execution of logic is moving downward, into the data layer. The agent doesn't need the application. It needs the data. And the system that holds, serves, and understands that data becomes the new platform.
>
> The filing cabinet is becoming the brain.
>
> And the systems that own that layer will define the next decade.

[Original post](https://x.com/siddontang/status/2033391893883818470)
