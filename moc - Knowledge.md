---
created: 2026-01-31
description: Navigation hub for cross-cutting knowledge that spans projects — best practices, frameworks, research
source: internal
type: moc
---

# Knowledge

Cross-cutting knowledge that spans projects. Best practices, frameworks, research.

## Business Ideas

Frameworks and playbooks for finding and building profitable products.

- [[domain-specific agents beat general-purpose ones by owning verification in boring industries]] — indie builder playbook: pick boring industries with expensive document workflows, compress domain learning with agents, build verification-first automation pipelines
- [[model-market fit is the prerequisite layer beneath product-market fit for AI startups]] — MMF framework: the model must do the core job before the market can pull the product. Legal AI exploded post-GPT-4; finance stuck at 56% accuracy. The 80/99 gap is infinite in regulated verticals

## Business Ideas

Frameworks and playbooks for finding and building profitable products.

- [[domain-specific agents beat general-purpose ones by owning verification in boring industries]] — indie builder playbook: pick boring industries with expensive document workflows, compress domain learning with agents, build verification-first automation pipelines
- [[model-market fit is the prerequisite layer beneath product-market fit for AI startups]] — MMF framework: the model must do the core job before the market can pull the product. Legal AI exploded post-GPT-4; finance stuck at 56% accuracy. The 80/99 gap is infinite in regulated verticals

## Agents

Agent architecture, memory systems, background agents, and tooling.

### AI Agents

Financial and investment-focused multi-agent systems.

- [[orchestration architecture determines multi-agent investment quality]] — architecture choice shapes output quality more than agent count in multi-agent investment committees
- [[simple financial agents outperform complex ones when tool routing is tight]] — reducing decision space via subagent encapsulation beats monolithic tool exposure for financial research
- [[over 40 percent of agentic AI projects fail due to poor architecture not model limitations]] — ten engineering principles for production agents: threat modeling, typed contracts, RBAC, context compression, deterministic orchestration, memory separation, reliability mechanics, OpenTelemetry observability

### Agentic Memory

Vault philosophy and agent integration patterns.

- [[Obsidian as Agentic Memory]] — architectural pillars for building agent knowledge systems (synthesizes vibe note-taking patterns and tools-for-thought lineage)
- [[four memory layers serve different knowledge types]] — CASS, CM, ms, and the vault as a unified memory system
- [[progressive disclosure filters force agent selectivity over what enters context]] — progressive disclosure for agent context curation
- [[inline annotations beat copy-paste editing by keeping instructions where they belong]] — spatial editing with inline annotations
- [[transcript mining turns meetings into captured decisions and extracted knowledge]] — transcript mining as knowledge capture
- [[git hooks as thinking journal let you time-travel through note evolution]] — git as thinking journal via async hooks
- [[obsidian vaults become memory graphs when agents traverse wikilinked notes with claim-based titles and layered orientation]] — arscontexta's comprehensive guide: vault philosophy, 3-layer orientation (tree/index/MOCs), composable claim-titled notes, agent breadcrumbs, CLAUDE.md as system philosophy
- [[PARA and atomic facts give AI agents durable structured memory]] — three-layer memory architecture with PARA directories, atomic facts, memory decay, and QMD search

### Background Agents

Agents that run continuously in the background — monitoring, alerting, proactive discovery.

- [[background agents shift alerting from reactive keyword matching to proactive semantic discovery]] — Fintool's architecture separating trigger filtering from LLM semantic analysis

### Data Agents

AI agents for data analysis, SQL generation, and enterprise analytics.

- [[OpenAI internal data agent succeeds through six layers of context not model capability alone]] — six-layer context architecture (metadata, queries, code definitions, docs, memory, runtime) for reasoning over 600PB

### Orchestration

How multiple agents coordinate: sessions, routing, scheduling, task systems, and shared infrastructure.

- [[2 to 5 worker agents per lead is the sweet spot for multi agent orchestration]] — lead/worker ratios, role staffing by CLI, specs + review layers
- [[multi-agent squads work when independent sessions share a mission control system]] — multi-session orchestration with heartbeats and a shared Mission Control substrate
- [[Athena is a vault librarian agent that maintains structure links and capture workflows]] — dedicated vault maintenance agent scope, standards, and cadence
- [[codex custom multi-agent roles unlock repeatable subagent specialization]] — Codex 0.102.0 custom roles with configurable models, reasoning, permissions, system prompts, and hidden thread limits

### Infrastructure

Agent runtime, scaling, persistence, and production deployment.

- [[seven runtime failures emerge when demo agents meet production distributed systems]] — seven sins of agentic software: stateful distributed systems, broken request-response, persistence, multi-tenancy, governance as execution model, scaling conflicts, trust vs observability
- [[agents need a database because stateless reasoning cores require stateful storage]] — own the database for context control, self-learning loops, evaluation datasets, and zero vendor dependency
- [[the Codex App Server turns a CLI agent harness into a stable bidirectional JSON-RPC protocol for any client]] — OpenAI's JSON-RPC protocol over stdio enabling IDE, web, and third-party integrations with the same agent harness
- [[isolating the entire agent in a sandbox is more secure than isolating just the tool]] — Browser Use's move from tool-level sandboxing to full agent isolation in Unikraft micro-VMs with a stateless control plane

### Harness Engineering

Agent harness design — system prompts, tools, middleware, and execution flow that shape model behavior.

- [[harness engineering improved a coding agent 13 points by changing only system prompts tools and middleware]] — LangChain's deepagents-cli: self-verification middleware, trace-based improvement loops, reasoning budget sandwiches, loop detection

### Tooling

Agent tooling patterns, CLI design, and infrastructure.

- [[capturing internal APIs can replace most agent browser automation]] — capture internal endpoints once, then switch agents from UI clicking to API-speed actions
- [[skill workflows]] — skills as folder-based modules (scripts + templates + nested skills) with progressive disclosure for repeatable automation
- [[agentic image generation loop]] — generate→annotate→refine workflows for producing and iterating visual assets in Claude Code
- [[skill graphs outperform single skill files by letting agents traverse linked domain knowledge on demand]] — wikilinked markdown skill networks with progressive disclosure, YAML descriptions, and MOCs for deep domain traversal
- [[context tax compounds through cache misses bloated tools and unbudgeted output tokens]] — thirteen techniques for reducing LLM token costs: KV cache stability, append-only context, filesystem tool outputs, subagent delegation, output budgeting
- [[agentic search with grep and full-file loading replaces RAG when context windows are large enough]] — RAG was a context-poor workaround; agents using grep, glob, and full-file loading outperform chunking-embedding-reranking pipelines
- [[agent-first engineering replaces coding with environment design scaffolding and feedback loops]] — OpenAI's zero-human-code experiment: 1M lines via Codex, AGENTS.md as table of contents, enforced architecture, garbage collection for AI slop
- [[prompt caching is the foundational constraint for building long-running agents]] — Claude Code's engineering lessons: prefix ordering, cache-safe plan mode, defer_loading for tools, cache-safe compaction
- [[top AI papers week of Feb 16-22 2026 reveal that agents consume skills better than they create them]] — ten papers: SkillsBench (curated skills +16pp, self-generated 0pp), LCM beats Claude Code, MemoryArena exposes recall-vs-action gap, delegation frameworks
- [[CLIs are the agent-native interface because legacy tooling is already machine-readable]] — Karpathy: CLIs are the ideal agent surface because agents natively compose terminal tools into pipelines; product builders must offer CLI/MCP/markdown docs
- [[rewriting tool descriptions with curriculum learning improves agent tool use without execution traces]] — Trace-Free+ curriculum learning trains LLMs to rewrite tool descriptions for better selection and execution, generalizing to unseen tools at scale
### MCP

Model Context Protocol — servers, best practices, and efficient tool integration patterns.

- [[MCP Best Practices]] — collected best practices from 50+ sources on building and consuming MCP servers
- [[tool search lets Claude Code lazy-load MCP tools when definitions exceed 10 percent of context]] — dynamic tool loading triggered at 10% context threshold, resolving 67K+ token bloat from multiple MCP servers
- [[mem0-knowledge-graph|MCP knowledge graphs give AI relationship-aware memory that vector databases cannot]] — Mem0's guide: entity relationships vs isolated embeddings, enterprise governance, phased rollout, MCP security specs
- [[code execution with MCP cuts tool token overhead 98 percent by presenting servers as filesystem APIs instead of upfront definitions]] — wrapping MCP tools as TypeScript files on a filesystem for on-demand discovery, in-code data filtering, PII tokenization, and emergent skill persistence

### Continual Learning

How agents learn and improve over time — memory-first architectures, persistent context, and cross-session learning.

- [[letta-code-blog|Letta Code is a memory-first coding agent that topped TerminalBench by treating sessions as persistent agents]] — persistent long-lived agents with memory-first architecture beat independent sessions on TerminalBench
- [[agent-continual-learning-impl|Continual learning implementations across letta-code, scout, and serena reveal what's real vs aspirational]] — deep implementation analysis: what letta-code, scout, and serena actually implement for continual learning vs what is partial or aspirational
- [[learning machines turn agents from stateless tools into systems that compound knowledge across users and sessions]] — extensible Learning Stores protocol: cross-user knowledge continuity, custom domain stores, roadmap from learning to decision logging to self-improvement
- [[async RL from real conversations lets agents continuously improve without blocking inference]] — OpenClaw-RL: fully async RL framework turning real conversations into training signals via PRM judging and on-policy distillation, self-hosted and open source

### Search

Agent code search, semantic retrieval, and the bottleneck between code generation and code retrieval.

- [[Knowledge/Agents/codebase_search_agents/index|Semantic Code Search — Morph Documentation]] — two approaches to AI-powered code search via the Morph MCP server
- [[Knowledge/Agents/codebase_search_agents/code-search-bottleneck/blog|Coding agents are bottlenecked by search not coding ability]] — survey of recent research on why AI coding agents fail at retrieval, not generation

### Learnings

Hard-won operational insights from running agents.

- [[learning - structured state files beat append-only logs for agent task persistence across compaction]] — JSON state files let agents reconstruct task context instantly after compaction
- [[learning - soul files written as earned beliefs outperform rule-based instructions]] — belief-narrative SOUL.md makes LLMs internalize values rather than comply with checklists
- [[social media platform login automation varies dramatically by platform]] — IG allows automated login, FB blocks all automated auth, TK rate-limits after 2-3 attempts; daily engagement works headless once authenticated

## Ecommerce

Marketing, creative testing, and automation learnings that apply across brands.

- [[advertising angles are testable hypotheses not copywriting]] — angles are experiments you can test and iterate, not inspiration-only copywriting
- [[recursive skill loops improve marketing outputs by generating scoring diagnosing and iterating until thresholds are met]] — generate→evaluate→improve loops with explicit scoring criteria for consistent copy/creative
- [[advertising works when a content farm feeds modular assets into an agent-driven assembly line]] — modular assets + agent assembly lines make creative output scalable
- [[content systems beat content calendars when assets are modular tagged and agent-operable]] — modular, tagged asset libraries outperform fixed calendars for iteration
- [[seo briefs beat seo tools when you separate serp gaps structure and differentiation]] — prompt-driven brief workflow (SERP gaps → structure → differentiation) as a repeatable system
- [[copy strategy converts when a messaging hierarchy voice chart and channel matrix anchor every asset to one promise]] — messaging systems outperform one-off copy
- [[meta ad library research finds winners through longevity signals creative families and angle extraction]] — use longevity + creative families to reverse-engineer winners
- [[ai longform ai videos look real when the starting frame and audio are high quality]] — upstream asset quality (starting frame + audio) is the realism bottleneck
- [[meta ads strategy]] — campaign architecture, creative strategy, audience targeting, measurement, and 2026 platform shifts
- [[sora 2 prompting improves video consistency when prompts read like cinematographer briefs]] — video prompting patterns for consistent shots (shot briefs, lighting continuity, image input anchoring)
- [[ads become searchable and remixable when structured as concept-module-asset-variant objects with enum tags]] — four-entity object model with enum tags for querying, mechanical variant generation, and concept-level learning
- [[shadcn component libraries let you ship ecommerce sites faster]] — component kits that speed storefront builds and iteration
- [[skill architecture beats skill writing when memory contracts and learning loops connect the system]] — five architectural patterns that turn isolated AI marketing skills into a compounding system
- [[nine prompts turn Claude plus Higgsfield into a product video factory]] — nine-prompt pipeline from angle generation through retargeting sequences

## Prediction Markets

Prediction market arbitrage, quantitative trading, and market microstructure.

- [[mathematical infrastructure not luck extracted 40 million from Polymarket]] — integer programming, Bregman projections, and Frank-Wolfe algorithms for systematic prediction market arbitrage
- [[polymarket arbitrage trading requires barrier frank-wolfe initialization and adaptive contraction]] — implementation roadmap: feasible initialization, barrier stability for LMSR, and profit-guaranteed stopping rules
- [[polymarket research papers]] — reading list: inefficiency/price misalignment, volatility modeling, and prediction market mechanism design
- [[attention markets shift arbitrage from binary constraints to latency correlation and manipulation volatility]] — attention-market microstructure shifts edge to oracle latency, correlation dislocations, and manipulation-linked volatility
- [[polymarket alpha compounds when traders specialize in one repeatable execution edge]] — edge comes from strategy specialization, procedural discipline, and execution speed rather than broad prediction generalism
- [[hedge funds use prediction market data for risk calibration not outcome prediction]] — empirical Kelly sizing, calibration surfaces, and maker-taker order flow decomposition using 400M+ open-source trade dataset
- [[kelly criterion determines optimal prediction market bet size from three inputs]] — the Kelly-Thorp criterion calculates optimal bankroll fraction from win probability, loss probability, and payout odds
- [[polymarket 5-minute market bot latency depends on server region with ireland and stockholm 294ms faster than seoul]] — Ireland/Stockholm achieve 250-280ms CLOB latency vs Seoul 550ms+, making region selection a core edge
- [[polymarket US retail API launches with 23 REST and 2 WebSocket endpoints for regulated trading]] — official US-regulated retail API with Ed25519 auth and Python/TypeScript SDKs
- [[synth volatility forecasts find 10 percent edge on polymarket crypto hourly contracts]] — 24h crypto volatility forecasts identify 10%+ mispricings on hourly up/down contracts
- [[weather markets on polymarket print money because most traders ignore NOAA forecasts]] — systematic mispricing from retail traders ignoring freely available 94%-accurate NOAA forecasts
- [[professional weather models give polymarket traders forecast edges across five time horizons]] — practical toolkit: ECMWF/ICON/GFS/AROME/HRRR matched to time horizons, plus Windy/Meteoblue/Pivotal/WeatherBell platforms
- [[prediction markets are the purest test of quantitative finance because every position resolves to truth]] — 28-paper synthesis: backtest overfitting, Deflated Sharpe Ratio, Black-Litterman for prediction portfolios, LMSR = softmax, and the institutional convergence on Polymarket
- [[becoming a prediction market quant requires five phases from bayesian thinking through live deployment]] — complete roadmap: Bayesian probability, microstructure, Avellaneda-Stoikov, empirical Kelly, VPIN, and production infrastructure
- [[prediction market calibration bias transfers wealth from takers to makers at 80 of 99 price levels]] — calibration function C(p,t) reveals systematic mispricing: 1-cent contracts resolve at 0.43% not 1%, takers lose at 80/99 price levels
- [[prediction market calibration error is a structured surface not a scalar and its flattening signals lost price discovery]] — 2D calibration surface C(K,τ) with price skew / temporal drift decomposition, Market Coherence Index, and delta-neutral portfolio construction
- [[polymarket market making requires avellaneda-stoikov reservation pricing adapted for binary settlement]] — Avellaneda-Stoikov reservation pricing, GLFT inventory bounds, Glosten-Milgrom adverse selection, and VPIN kill switches for Polymarket order books
- [[polymarket feb 18 rule change killed taker bots and made market making the new meta]] — removal of 500ms taker delay + dynamic taker fees up to 1.56% killed arb bots, making maker-side LP the only profitable strategy
- [[quantitative trading requires six math domains from statistics through risk management]] — roadmap of math for systematic trading: statistics, linear algebra, time series, stochastic calculus, optimization, and risk management
- [[polymarket copy trading exploits on-chain transparency to follow proven whale wallets]] — complete copy trading system: whale wallet scoring, topic-based baskets, Kelly sizing, and 1.2s latency pipeline
- [[fractional kelly turns 5-minute polymarket bitcoin markets from gambling into a system]] — fractional Kelly (k=0.25) applied to 5-minute BTC markets: discipline over emotion, practical sizing, and drawdown control
- [[quant desk simulation requires eight layers from Monte Carlo through copulas and agent-based models]] — complete simulation stack: Monte Carlo, importance sampling, particle filters, variance reduction, copula dependency modeling, agent-based simulation, and a five-layer production architecture

## LLMs

Foundational architecture, training, scaling, and interpretability of large language models.

- [[twenty-six papers capture ninety percent of the alpha behind modern LLMs from attention through reasoning and mixture of experts]] — curated reading order from Transformers through scaling laws, alignment, reasoning, and MoE architectures

## Thinking

- [[genius thinking is the ability to keep thinking past threat reactions]]
