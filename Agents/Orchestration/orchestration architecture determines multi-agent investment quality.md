---
created: 2026-02-19
description: A multi-agent investment committee using five orchestration patterns and three-layer knowledge shows how architecture choice shapes output quality more than agent count.
source: https://x.com/ashpreetbedi/status/2024293702001135648
type: framework
---

## Key Takeaways

The core thesis is that **orchestration pattern selection matters more than agent sophistication**. The same seven agents produce vastly different output quality depending on whether they're routed, broadcast, coordinated, tasked, or pipelined — a principle directly applicable to how [[plutus|Plutus]] could evolve beyond single-agent analysis.

**Five architecture patterns map to different question types:**
- **Route** — quick expert lookup ("What's AAPL's P/E?"), lowest cost
- **Broadcast** — independent parallel votes then synthesis, best for consensus decisions
- **Coordinate** — chair-led discussion, best for exploratory analysis
- **Task Mode** — PM decomposes into parallel workstreams with dependencies, best for complex portfolio construction
- **Workflow** — deterministic five-step pipeline, best for auditable repeatable reviews

**Three-layer knowledge architecture** prevents the classic "everything in a vector store" failure:
1. **Static context** (system prompt) — risk limits, mandate rules. Never searched, always present. Critical constraints must be unavoidable, not discoverable.
2. **Research library** (PgVector RAG) — company profiles, sector analysis. Large corpus where semantic search works well.
3. **Memo archive** (filesystem, read whole files) — past investment memos. Structured documents lose meaning when chunked; find the right one and read all of it.

**Institutional learning** is the differentiator between "agents" and "an institution." Agents save patterns, corrections, and insights to a shared knowledge base after each session. Session 2 starts further ahead than Session 1 because it retrieves past learnings before pulling fresh data. This maps closely to the [[plutus-plan|Plutus plan]]'s vision of persistent analytical memory.

The **model allocation strategy** is practical: Sonnet for specialist analysts (fast, cheap, focused), Opus for the Chair (better reasoning for synthesizing conflicting perspectives). Cost-effective tiering rather than max-model everywhere.

The system uses **Agno** (Python framework) with YFinance for market data and Exa MCP for web search. All seven agents share committee context via system prompt injection and a shared learning namespace.

## External Resources

- [Investment Committee repo](https://github.com/agno-agi/investment-committee) — full open-source implementation
- [Agno framework](https://github.com/agno-agi/agno) — Python multi-agent framework powering the system
- [Agno docs: Teams & Modes](https://docs.agno.com/teams) — orchestration patterns documentation
- [Agno docs: Learning Machines](https://docs.agno.com/learning) — institutional learning feature

## Original Content

> [!quote]- Source Material

> @ashpreetbedi (Ashpreet Bedi):
> Article: Investment Committee: 5 Multi-Agent Architectures in Action
>
> Most multi-agent tutorials show you one orchestration pattern applied to a toy problem. Four agents chat about the weather, agree with each other, and produce an answer that one agent could have written alone. The agents don't specialize. They don't disagree. They definitely don't learn.
>
> This post is different. We'll build an investment committee with seven specialist agents orchestrated across five distinct architectures, and show how the choice of architecture changes the quality of the outcome.
>
> > Here's the [code](https://github.com/agno-agi/investment-committee) if you want to dive in without the commentary.
>
> # Why an Investment Committee
>
> An investment committee is one of the oldest multi-agent systems in the world. A group of specialists, each with different expertise, different tools, different blind spots, evaluating opportunities and making capital allocation decisions together.
>
> It maps naturally to what multi-agent systems should demonstrate:
>
> - Specialization matters. A single analyst covering macro, fundamentals, technicals, and risk produces shallow work in every dimension. Separate agents with separate tools go deeper.
>
> - Orchestration matters. Should the chair call on analysts one by one? Should everyone speak simultaneously? Should we run a fixed process? The answer depends on the question.
>
> - Memory matters. A committee that starts from scratch every meeting is useless. A committee that remembers what it decided last quarter, what mistakes it made, what patterns it discovered: that's an institution.
>
> The system manages a $10M vehicle investing in US public equities. Every analysis runs against live market data. Every recommendation must comply with a real investment mandate with position limits, sector caps, and risk constraints. Nothing is simulated (except for the investments, of course).
>
> # The Setup: 7 Agents, Real Data, Live Markets
>
> The committee runs against live financial data via YFinance (free) and Exa web search (their MCP is free). Every agent is a specialist:
>
> - Market Analyst (Sonnet 4.6): Macro trends, sector analysis, breaking news. Tools: Exa MCP + YFinance.
>
> - Financial Analyst (Sonnet 4.6): Fundamentals, valuation, balance sheets. Tools: YFinance.
>
> - Technical Analyst (Sonnet 4.6): Price action, momentum, support/resistance levels. Tools: YFinance.
>
> - Risk Officer (Sonnet 4.6): Downside scenarios, position sizing, mandate compliance. Tools: YFinance.
>
> - Knowledge Agent (Sonnet 4.6): Memo archive + research library. Tools: FileTools / Vector Search.
>
> - Memo Writer (Sonnet 4.6): Synthesizes analysis into formal investment memos. Tools: FileTools.
>
> - Committee Chair (Opus 4.6): Final decisions, capital allocation.
>
> > I'm using Yfinance and Exa via MCP because they're free.  
> Real Gs should use paid options.
>
> Specialist analysts use Sonnet: fast, capable, cost-effective for focused analysis. The Chair uses Opus: better reasoning for synthesizing conflicting perspectives and making final calls.
>
> Every analyst shares two things. First, the committee's static context (mandate, risk policy, process rules) injected directly into their system prompt. Second, a shared learning base where they save and retrieve patterns across sessions.
>
> Here's the common structure:
>
> ```python
> from agno.agent import Agent
> from agno.models.anthropic import Claude
> from agno.learn import LearningMachine, LearnedKnowledgeConfig, LearningMode
>
> from context import COMMITTEE_CONTEXT
> from agents.settings import committee_knowledge, committee_learnings
>
> instructions = f"""\
> You are the Risk Officer for a $10M investment committee.
>
> ## Committee Rules (ALWAYS FOLLOW)
>
> {COMMITTEE_CONTEXT}
>
> ## Your Role
> ...
> """
>
> risk_officer = Agent(
>     id="risk-officer",
>     model=Claude(id="claude-sonnet-4-6"),
>     instructions=instructions,
>     tools=[YFinanceTools()],
>     knowledge=committee_knowledge,     # Layer 2: research library (RAG)
>     search_knowledge=True,
>     learning=LearningMachine(
>         knowledge=committee_learnings, # shared across all agents
>         learned_knowledge=LearnedKnowledgeConfig(
>             mode=LearningMode.AGENTIC,
>             namespace="global",
>         ),
>     ),
> )
> ```
>
> That {COMMITTEE_CONTEXT} is doing more work than it looks. We'll come back to it.
>
> ## The 5 Architectures
>
> Here's the central insight: the same seven agents produce different results depending on how you orchestrate them.
>
> ## Route: Call the Right Department
>
> ```python
> route_team = Team(
>     mode=TeamMode.route,
>     model=Claude(id="claude-opus-4-6"),
>     members=[market_analyst, financial_analyst, technical_analyst,
>              risk_officer, knowledge_agent, memo_writer, committee_chair],
> )
> ```
>
> The simplest architecture. Every question goes to exactly one specialist.
>
> - "What's AAPL's P/E ratio?" goes to the Financial Analyst.
>
> - "What did we decide about TSLA?" goes to the Knowledge Agent.
>
> - "Write a memo on NVIDIA" goes to the Memo Writer.
>
> One question. One expert. No committee meeting required.
>
> Best for: Quick, targeted questions. When you know what you need.
>
> ## Broadcast: Everyone Votes
>
> ```python
> broadcast_team = Team(
>     mode=TeamMode.broadcast,
>     model=Claude(id="claude-opus-4-6"),
>     members=[market_analyst, financial_analyst,
>              technical_analyst, risk_officer],
> )
> ```
>
> Now instead of one expert, the same question goes to all four analysts simultaneously. Each responds independently. They can't see each other's work. No anchoring bias. No groupthink. The Financial Analyst can't be swayed by the Market Analyst's optimism. The Risk Officer can't soften their concerns because everyone else is bullish.
>
> Then the Chair synthesizes the independent perspectives, notes where analysts agree and disagree, and makes a final call.
>
> Best for: High-stakes allocation decisions. When you want the equivalent of a secret ballot before the chair decides.
>
> ## Coordinate: The Chair Runs the Meeting
>
> ```python
> coordinate_team = Team(
>     mode=TeamMode.coordinate,
>     model=Claude(id="claude-opus-4-6"),
>     members=[market_analyst, financial_analyst, technical_analyst,
>              risk_officer, knowledge_agent, memo_writer],
> )
> ```
>
> Route sends questions to one expert. Broadcast sends questions to all of them. Coordinate is the middle ground: the Chair dynamically decides which analysts to consult, in what order, based on what it learns as the conversation unfolds.
>
> Ask "Should we increase our exposure to NVIDIA?" and the Chair might start with the Financial Analyst, follow up with the Market Analyst after seeing strong fundamentals, consult the Risk Officer before making a sizing decision, and finally ask the Memo Writer to document everything.
>
> The chair adapts. If the Financial Analyst surfaces a red flag, the Chair might skip the Technical Analyst entirely and go straight to Risk. This is how a real committee chair runs a meeting: reading the room, following the thread, not mechanically working through an agenda.
>
> Best for: Open-ended investment questions. "Should we invest?" "What do you think of this stock?"
>
> > Important: Not financial advice. This took 7 minutes to decide whether it should jam 20% of the fund into microsoft (denied -- but still).
>
> ## Task Mode: The PM Assigns Work
>
> ```python
> task_team = Team(
>     mode=TeamMode.tasks,
>     model=Claude(id="claude-opus-4-6"),
>     members=[market_analyst, financial_analyst, technical_analyst,
>              risk_officer, knowledge_agent, memo_writer],
> )
> ```
>
> Ask "Deploy $1M across the top 5 AI stocks, no single position over 30%" and the Chair autonomously decomposes this into sub-tasks with dependencies:
>
> ```plaintext
> Task 1: Market Analyst    → Identify top 5 AI stocks
> Task 2: Financial Analyst → Deep dive fundamentals       (depends on 1)
> Task 3: Technical Analyst → Entry timing analysis        (depends on 1)
> Task 4: Risk Officer      → Portfolio risk assessment    (depends on 2, 3)
> Task 5: Memo Writer       → Allocation memo              (depends on 4)
> ```
>
> Tasks 2 and 3 run in parallel after Task 1 completes. Task 4 waits for both. Task 5 produces the final output.
>
> Best for: Complex, multi-step problems that a human PM would break into a project plan.
>
> > Note: streaming is not yet supported on task mode, so I don't have a video for you. It's an SDK only feature at the moment.
>
> ## Deterministic Workflow: The Assembly Line
>
> ```python
> investment_workflow = Workflow(
>     steps=[
>         Step(name="Market Assessment", agent=market_analyst),
>         Parallel(
>             Step(name="Fundamental Analysis", agent=financial_analyst),
>             Step(name="Technical Analysis", agent=technical_analyst),
>         ),
>         Step(name="Risk Assessment", agent=risk_officer),
>         Step(name="Investment Memo", agent=memo_writer),
>         Step(name="Committee Decision", agent=committee_chair),
>     ],
> )
> ```
>
> A fixed, repeatable pipeline. Market context first. Then fundamentals and technicals in parallel. Then risk. Then the memo. Then the final decision. Every stock goes through the exact same process.
>
> ```plaintext
> Market → ┌─ Financial ─┐ → Risk → Memo → Chair
>          └─ Technical ─┘
> ```
>
> No dynamic routing. No autonomous decomposition. The same rigorous process every time. Output from each step feeds into the next.
>
> Best for: Standardized, auditable reviews. When consistency and traceability matter more than flexibility.
>
> # Why Five Architectures
>
> Most multi-agent tutorials present one architecture as the way to build multi-agent systems. Real problems demand flexibility:
>
> - "Quick question for an expert" → Route. Call the right department.
>
> - "Major allocation decision" → Broadcast. Independent votes, then synthesis.
>
> - "Investigate this stock" → Coordinate. The chair runs a meeting.
>
> - "Build me a portfolio" → Task Mode. PM assigns work with dependencies.
>
> - "Standard investment review" → Workflow. The assembly line.
>
> A real investment team uses all of these patterns in the same day. Multi-agent systems should be equally flexible. All five architectures share the same seven agents. The agents don't change, only the orchestration does.
>
> # Three-Layer Knowledge (or: Stop Putting Everything in a vector store)
>
> Here's a mistake almost every multi-agent demo makes: dump all knowledge into a single vector database and hope that semantic search surfaces the right thing at the right time.
>
> This doesn't work for an investment committee. Consider three types of knowledge:
>
> The investment mandate says "maximum single position: 30% of fund." If the Risk Officer misses this because the vector search returned a different chunk, the committee approves a $5M position and violates its own rules. Risk limits should not be searchable. They should be unavoidable.
>
> The research library contains profiles on 50+ companies. When the Financial Analyst asks about NVIDIA's competitive moat, semantic search across the corpus is exactly the right tool. You don't want every company profile in the system prompt.
>
> Past investment memos are 2,000-word structured documents: thesis, analysis, risk assessment, committee decision. Chunk one into 512-token vector fragments and you lose the structure. You lose the connection between the thesis and the decision. You want to find the right memo and read all of it.
>
> Three types of knowledge. Three storage strategies:
>
> ```plaintext
> ┌──────────────────────────────────────────────────────┐
> │  LAYER 1: STATIC CONTEXT                             │
> │  Always in the system prompt. Never searched.        │
> │                                                      │
> │  Investment mandate, risk policy, process rules.     │
> │  Loaded from context/*.md at initialization.         │
> │  Every agent sees these. Every time.                 │
> │                                                      │
> │  WHY: Risk limits must never be "missed" by search.  │
> └──────────────────────────────────────────────────────┘
>
> ┌──────────────────────────────────────────────────────┐
> │  LAYER 2: RESEARCH LIBRARY                           │
> │  PgVector with hybrid search. Searched via RAG.      │
> │                                                      │
> │  Company profiles, sector analysis.                  │
> │  Grows over time. Could be hundreds of documents.    │
> │                                                      │
> │  WHY: Large corpus where semantic search shines.     │
> └──────────────────────────────────────────────────────┘
>
> ┌──────────────────────────────────────────────────────┐
> │  LAYER 3: MEMO ARCHIVE                               │
> │  Filesystem. Browsed via FileTools. Read in full.    │
> │                                                      │
> │  Past investment memos. Structured documents.        │
> │  Knowledge Agent discovers what exists, reads whole  │
> │  files. Memo Writer saves new ones after decisions.  │
> │                                                      │
> │  WHY: Structured docs lose meaning when chunked.     │
> │  Find the right one and read all of it.              │
> └──────────────────────────────────────────────────────┘
> ```
>
> The implementation is straightforward. Layer 1 is a Python f-string:
>
> ```python
> # context/loader.py
> COMMITTEE_CONTEXT = load_context()  # reads mandate.md, risk_policy.md, process.md
>
> # Every agent's instructions
> instructions = f"""
> ## Committee Rules (ALWAYS FOLLOW)
>
> {COMMITTEE_CONTEXT}
>
> ## Your Role
> ...
> """
> ```
>
> Layer 2 is PgVector with hybrid search. Research documents are loaded once at startup:
>
> ```python
> # app/main.py
> for subdir in ["companies", "sectors"]:
>     path = research_dir / subdir
>     if path.exists():
>         committee_knowledge.insert(path=str(path), skip_if_exists=True)
> ```
>
> Layer 3 is FileTools. The Knowledge Agent lists, searches, and reads memos as whole files.
>
> ```python
> # Knowledge Agent: read-only access to memo archive
> FileTools(base_dir=MEMOS_DIR, enable_read_file=True,
>           enable_list_files=True, enable_search_files=True)
>
> # Memo Writer: also has write access to save new memos
> FileTools(base_dir=MEMOS_DIR, enable_save_file=True, ...)
> ```
>
> > Just like Claude Code greps codebases, the Knowledge Agent greps memos.
>
> Ask the Knowledge Agent "What did we decide about NVIDIA?" and it calls list_files(), finds nvda_2025_q3_buy.md, calls read_file(), and synthesizes: "Our last NVIDIA memo recommended BUY at $1.5M. The thesis centered on AI training demand. The position was sized below $2M due to high beta triggering the $1.5M limit."
>
> The full memo, in context. Not vector fragments reassembled into something that sounds right but misses the connections.
>
> The principle: Where knowledge lives determines how reliably agents use it. Critical rules go in the prompt. Large corpora go in RAG. Structured documents get browsed as files.
>
> # Institutional Learning
>
> Knowledge tells agents what they know. Learning tells them what they've discovered.
>
> Every analyst agent (Market, Financial, Technical, Risk) has a LearningMachine configured with LearningMode.AGENTIC. Before analysis, they search for relevant past learnings. After analysis, they save new patterns, corrections, and insights. All learnings go to a shared knowledge base with namespace="global", so every agent benefits.
>
> What gets learned:
>
> - Committee reduces NVDA position due to high beta → saves "NVDA allocation constrained by both high-beta limit ($1.5M) and tech sector cap (40%)." Next time NVDA comes up, the Risk Officer references this immediately.
>
> - User corrects a revenue breakdown → saves "NVDA's AI revenue is primarily data center, not consumer GPU." The Financial Analyst emphasizes the right segment going forward.
>
> - Two stocks moved in lockstep → saves "NVDA and AMD are highly correlated. Holding both creates concentration risk." The Risk Officer flags this during portfolio construction.
>
> - YFinance data was misleading → saves "YFinance trailing P/E for high-growth stocks can be misleading. Always check forward P/E." The Financial Analyst adjusts its methodology.
>
> The difference in practice:
>
> Session 1: "Analyze NVIDIA." The committee produces a thorough analysis and recommends BUY at $1.5M, constrained by high-beta policy. The Risk Officer saves a learning about the beta constraint. The Financial Analyst saves a learning about data center revenue concentration.
>
> Session 2: "Analyze NVIDIA." Before pulling YFinance data, the agents search learnings and find: the beta constraint, the revenue segment insight, the sector cap interaction. The analysis starts further ahead. It doesn't repeat the same discovery process. It builds on what the committee already knows.
>
> This is what turns a collection of agents into an institution: an organization that accumulates wisdom over time.
>
> Not every agent needs learning. The Memo Writer synthesizes; it doesn't discover patterns. The Knowledge Agent retrieves; it doesn't analyze. Only the four active analysts have LearningMachine configured.
>
> # Try It
>
> The full implementation is open source. Here is the [repo](https://github.com/agno-agi/investment-committee).
>
> Seven agents, four teams, one workflow, three-layer knowledge, institutional learning, all built with [Agno](https://github.com/agno-agi/agno).
>
> ```shell
> # Clone repo and add env vars
> > git clone https://github.com/agno-agi/investment-committee.git investment-committee
> > cd investment-committee
>
> > cp example.env .env
> # Edit .env and add your API keys
> # ANTHROPIC_API_KEY=sk-ant-***
> # OPENAI_API_KEY=sk-***
> # EXA_API_KEY=*** # Optional -- Exa MCP is free (thank you!)
>
> # Start services
> > docker compose up -d --build
>
> # Load research into the knowledge base
> > docker exec -it aic-api python -m app.load_knowledge
>
> ```
>
> Prompts to try:
>
> - "What's AAPL's P/E ratio?" → Route sends it to the Financial Analyst.
>
> - "Full committee review: evaluate TSLA for $2M" → Broadcast. Four independent analyses, then synthesis.
>
> - "Should we invest in NVIDIA?" → Coordinate. The Chair orchestrates a multi-analyst discussion.
>
> - "Deploy $10M across the top 5 AI stocks" → Task Mode. Autonomous decomposition into parallel workstreams.
>
> - "Run full investment review on NVIDIA" → Workflow. The five-step deterministic pipeline.
>
> - "What past memos do we have?" → Route sends it to the Knowledge Agent for file navigation.
>
> The patterns here extend well beyond finance. Any domain where you need specialized agents, structured knowledge, and institutional memory can use these same building blocks: route for efficiency, broadcast for consensus, coordinate for exploration, task mode for complex problems, and workflows for repeatable processes.
>
> The architecture you choose shapes the intelligence. Choose wisely.
>
> References
>
> - [Agno Github](https://github.com/agno-agi/agno)
>
> - [Agno Docs](https://docs.agno.com/)
>
> - [Teams & Modes](https://docs.agno.com/teams)
>
> - [Workflows](https://docs.agno.com/workflows)
>
> - [Learning Machines](https://docs.agno.com/learning)
>
> ---
>
> This is a technical demonstration, not financial advice. Don't make investment decisions based on an AI agent's recommendations.
> date: Thu Feb 19 01:23:22 +0000 2026
> url: https://x.com/ashpreetbedi/status/2024293702001135648
> likes: 467  retweets: 40  replies: 8