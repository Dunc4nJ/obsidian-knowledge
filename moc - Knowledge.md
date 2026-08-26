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

- [[a16z argues AI systems of intelligence will eat the CRM by turning go-to-market databases into infrastructure consumed at the API layer]] — a16z thesis: just as the algorithmic newsfeed turned the friend graph into one input among many, the AI orchestration layer turns the CRM into a database consumed at the API layer; gravity shifts from data accumulation to multi-system orchestration, and the next decade of GTM enterprise value lives in the reasoning layer above the SoR
- [[domain-specific agents beat general-purpose ones by owning verification in boring industries]] — indie builder playbook: pick boring industries with expensive document workflows, compress domain learning with agents, build verification-first automation pipelines
- [[model-market fit is the prerequisite layer beneath product-market fit for AI startups]] — MMF framework: the model must do the core job before the market can pull the product. Legal AI exploded post-GPT-4; finance stuck at 56% accuracy. The 80/99 gap is infinite in regulated verticals
- [[data is a great place to start an AI company and a dangerous place to stop - Etna Labs maps the training-signal supplier market]] — Etna Labs' investment map of the AI training-data ecosystem: suppliers compounding at lab speed (Mercor $500M→$2B, Fleet ~$1M→$63M+ in six months) against concentrated buyers and 1-2-year format churn; China's research-native vendors (UniPat, Humanlaya) as an organizational unbundling of the model lab; Sean Cai's Type 1 recorded vs Type 2 performed data taxonomy + Etna's Type 1.5; four businesses inside "AI data" (human data, RL environments, RLaaS, real-world data rights) with per-category investment views; thesis: data is a flow business — expert networks, renewable rights, verifiers, simulators, and production feedback loops compound, datasets don't; 6 graphics

## AI Consulting

Theses and playbooks for AI transformation and services businesses.

- [[Varick Agents - AI's biggest winners are low-margin businesses where sub-1 percent cost cuts drive 25 percent profit gains]] — Daniel Kornum (Varick Agents): the largest addressable AI opportunity is low-margin, labor-heavy firms (logistics, manufacturing, staffing) where a <1% cost cut yields a >25% profit gain; win by attacking hidden coordination costs and selling AI as infrastructure embedded in existing workflows rather than software that requires employee adoption

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
- [[deerflow stores memory as local JSON with async middleware and confidence-scored prompts]] — DeerFlow’s JSON-based, confidence-gated, token-budgeted memory middleware pattern for practical agent memory
- [[four memory layers serve different knowledge types]] — CASS, CM, ms, and the vault as a unified memory system
- [[progressive disclosure filters force agent selectivity over what enters context]] — progressive disclosure for agent context curation
- [[inline annotations beat copy-paste editing by keeping instructions where they belong]] — spatial editing with inline annotations
- [[transcript mining turns meetings into captured decisions and extracted knowledge]] — transcript mining as knowledge capture
- [[git hooks as thinking journal let you time-travel through note evolution]] — git as thinking journal via async hooks
- [[obsidian vaults become memory graphs when agents traverse wikilinked notes with claim-based titles and layered orientation]] — arscontexta's comprehensive guide: vault philosophy, 3-layer orientation (tree/index/MOCs), composable claim-titled notes, agent breadcrumbs, CLAUDE.md as system philosophy
- [[PARA and atomic facts give AI agents durable structured memory]] — three-layer memory architecture with PARA directories, atomic facts, memory decay, and QMD search
- [[The Price of Meaning prescribes coupling semantic retrieval with exact episodic grounding as the only escape from interference]] — Sentra's formal no-escape theorem: any semantic memory system must forget because natural language has only ~10–50 effective dimensions; only principled exit is semantic retrieval coupled to an external episodic verification layer

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
- [[LangChain Deep Agents adds per-model harness profiles because each provider's prompting guide demands different tools and middleware]] — Viv Trivedi: HarnessProfile becomes a registerable declarative override (system prompt, tools/aliases, middleware, subagents, skills); ships defaults for OpenAI/Anthropic/Google yielding 10-20 point tau2-bench gains; generalizes the prior Terminal-Bench harness-engineering result into a permanent primitive
- [[Memory ownership follows harness ownership - Harrison Chase argues picking a closed harness is picking a permanent owner for your agent's data flywheel]] — Chase's strategic manifesto formalizing three tiers of memory lock-in (stateful APIs, closed harnesses, closed harnesses + server-side long-term memory), paired with the [[LangChain Deep Agents Deploy offers open harness to avoid Claude Managed Agents memory lock-in|Deep Agents Deploy launch]]
- [[The Mismanaged Geniuses Hypothesis argues the next AI leap comes from training LMs to decompose not from scaling]] — Alex Zhang, Zhening Li, Omar Khattab: scaffolds are the bottleneck, not model size; define the space of decompositions first, then train the compose-operator — RLM(Qwen3-4B) trained on 32k/1-needle jumps from ~0% to 100% on MRCRv2 1M/8-needle, beating Gemini 3 Pro and Opus 4.6
- [[HALO uses an RLM to mine harness-shaped failures from agent execution traces and lift benchmarks 10-16 percentage points]] — Sam Hogan (Context Labs): trace-driven harness optimizer powered by an RLM analyzing hundreds of thousands of agent executions; harness-only fixes lifted Sonnet 4.6 AppWorld 73.7→89.5%, Opus 4.7 Finance-Agent 56→72%, Gemini 3 Flash Terminal-Bench 46→57.14% and SWE-Bench Verified 65→74%; also triages harness slack vs missing-model-capability (tau3-Bench banking_knowledge stayed capped near 10% under every harness variant)
- [[Recursive Language Models pass context by reference through a Python REPL so subagent outputs return as variables instead of autoregressively regenerated tokens]] — Avishek Biswas's TDS deep dive: the pedagogical companion to the RLM paper; walks Direct Generation → ReAct → CodeAct → CodeAct+Subagents → +Filesystem → RLM on a fruit-counting case study, framing pass-by-reference (prompt as a Python `context` variable, subagent results as REPL symbols via `llm_query`/`FINAL`) as the missing primitive; ships open-source `fast-rlm` with TUI trace viewer and the full author-recommended system prompt
- [[Joseph Viviano frames agentic research workflows as a continuum of markdown files at different mutation rates from paper.tex to notes.md]] — Mila researcher's 15-month workflow synthesis: research codebases differ from production code (no users, just developers and post-paper static-artifact consumers); stabilized via a continuum of markdown files at different mutation rates (paper.tex/design_doc.md/plan.md/TODO.md/notes.md/handoff.md), short AGENT.md with universal rules, per-TODO context, git commits as savegames, independent test/code agents, and periodic paper-to-code reconciliation
- [[Basis built an agent-native monorepo by separating canonical from non-canonical context across a six-layer instruction architecture]] — Basis Atlas team: explicit canon (AGENTS.md, skills, docs/, comments) vs non-canon (.specs/, Linear, .notes/) Authority Map, six-layer architecture (root + 100 nested AGENTS.md, skills, sub-agent roles like verifier/standards-enforcer, unified MCP, tests), five principles (canonicality, localization, verifiability, interoperability, default-no), daily scanner+worker agents maintaining the instruction layer; 5x token usage per developer and 2.5x weekly commit velocity over three months

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
- [[NIA Docs turns web documentation into a filesystem that agents can grep, cat, and code against]] — agent-first docs access via mounted API/web documentation filesystem, trading RAG fragmentation for Unix-like commands and fresher API context
- [[Harness engineering widens the expert-novice gap instead of closing it — Junghwan NA's OMX + Ouroboros pipeline merged PRs at 100+ OSS repos before GitHub suspended him]] — 13-stage tmux + OMX + Ouroboros pipeline, 500+ commits across 100+ repos in 72 hours; local reproduction and merge-pattern matching did 80% of the work; attestation (CLA, merge approvals) is the new scarce OSS resource
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
- [[on-policy distillation plus conditional log-penalty RL cuts search agent latency 44 percent while boosting accuracy]] — Contextual AI: two-axis search agent optimization (retrieval tool + planner training via distillation + CLP reward), 44% latency reduction, proposes CER-C efficiency metric
- [[Grey Haven autocontext runs five-role recursive improvement loops with persistent playbooks and traces that next runs inherit]] — autocontext 0.5.0: Competitor/Analyst/Coach/Architect/Curator pipeline with tournament gating and SQLite-indexed playbook snapshots inherited by scenario name; Pi/Hermes/MCP integration paths
- [[The weakest hypothesis generalizes best - Bennett proves compression is neither necessary nor sufficient and weakness-maximization beats MDL by 1.1-5x]] — Bennett (ANU, arXiv 2301.12987, via Erik Meijer): within an enactive-cognition lattice formalism under uniform task distributions, the hypothesis most likely to generalize is the *weakest* consistent one (largest extension), not the shortest — compression/MDL is neither necessary nor sufficient, and weakness beat MDL 1.1-5x on binary-arithmetic experiments. The theory behind lesson-induction in self-improvement loops: "write the weakest rule consistent with all observed failures" — the selection principle that prevents the over-specific induced rules behind CLAUDE.md noise, repo-context-file regressions, and silent skill rot. Caveats: uniform-task-prior does the heavy lifting; extension size is intractable beyond toy worlds

### Local Inference and Hardware

Running frontier-class models on hardware you own — builds, quantization/pruning to fit VRAM, throughput vs concurrency, and buy-vs-rent economics. Folder MOC: [[moc - Local Inference and Hardware]].

- [[at 15-20K with 512GB the real gap is bandwidth not compute - Mac Studio M5 Ultra vs 4x DGX Spark vs 4x Ryzen AI Halo]] — @tomgreenwald: matched-price/matched-memory comparison — Mac's 1.2 TB/s vs ~273/256 GB/s for the clusters; multi-box splits mean 4 boxes still generate at 1 box's speed, so bandwidth (not pooled memory or aggregate TFLOPS) sets interactive speed
- [[two DGX Sparks run a 304B model at 40 TPS - install Tailscale first and every other non-obvious gotcha]] — @vectal_labs' first-setup field notes: Tailscale-first so you finish over SSH, wired peripherals + USB-C hub, plug order, the cx7-hotplug file that fakes dead hardware after reboot, and use the MiaAI-Lab/Anemll recipes rather than building from scratch
- [[EXL3 3-bit plus an 18.5 percent expert prune runs DeepSeek-V4-Flash 284B at 47 tok-s on 4.7K of hardware]] — @0xSero: stack quantization *and* MoE expert pruning (orthogonal levers) to fit 284B in 128GB VRAM at 47 tok/s, 400K context
- [[a 100K DGX Station pays back in 19 months at 30 percent duty - but only if you can keep 64 requests concurrent]] — @digitalix: $2,778/mo amortized, $0.16-$1.59 per 1M output tokens by duty cycle, 19-month payback at 30% — all contingent on 64-way concurrency; at 8 concurrent it's ~4x the payback
- [[LMCache offloads paged KV to system RAM and NVMe, cutting 128K-context time-to-first-token from 68 seconds to 1.4 on 4x DGX Spark]] — @0xSero: page KV out to host RAM/NVMe so long contexts reload rather than recompute — TTFT 68.1s → 1.4s at 128K context on 4x DGX Spark; the local fix for the fixed-prefix tax agents pay on every turn

### Search

Agent code search, semantic retrieval, and the bottleneck between code generation and code retrieval.

- [[Knowledge/Agents/codebase_search_agents/index|Semantic Code Search — Morph Documentation]] — two approaches to AI-powered code search via the Morph MCP server
- [[coding agents are bottlenecked by search not coding ability]] — survey of recent research on why AI coding agents fail at retrieval, not generation
- [[Neo4j's Stephen Chin on agentic graph RAG - vector search finds entry points and graph traversal supplies grounded context]] — Stephen Chin's AI Engineer talk: vector-then-graph beats text-to-Cypher and beats baseline vector RAG; embeddings live as properties on graph nodes; CLA uses this for 250k internal queries
- [[BrowseComp-Plus isolates the search-agent ceiling - GPT-4.1 scores 14.6 percent finding documents with BM25 vs 93.5 percent when handed them]] — Hamel/Nandan Thakur: the retriever, not the model, is the ceiling (controlled BrowseComp variant); ORBIT synthetic eval pipeline (inverted question generation, triple verification, 20k free questions); Hawkeye trajectory analytics (correct runs need far fewer search rounds — sets your max-rounds threshold)
- [[Toast 1 takes over the search loop as a specialized subagent - 3.5x fewer tokens at identical Harvey-bench scores and OfficeQA SOTA at 1.15 dollars per task]] — Mixedbread's specialized search agent (sibling of SID-1 and Chroma Context-1): fully owns decompose→gather→inspect→curate and returns token-efficient evidence packages so the frontier model spends context on reasoning. OfficeQA Pro V2 SOTA (GPT-5.6 Sol + Toast 1 = 70% at ~$1.15/task vs Fable 5 on Genie at 60%/~$4; same model without Toast 1: 33%); Harvey bench tokens 80.6M→47M→23M at identical scores with turns halved; standalone ~$0.016-0.023/query at 8s median, 7-11x cheaper than frontier retrieval agents; backend-agnostic; 3 chart screenshots

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

## X

Growth, marketing, and distribution on the X (Twitter) platform — how its ranking promotes content and how to launch, go viral, and coordinate creators. See [[moc - X]].

- [[Making a launch trend on X is a four-stage system - swipe-file research, a claim-and-comment-gate hook, tiered-creator breadth, and spike conversion]] — @0xfJuan's launch playbook: X promotes posts circle-by-circle and "trending" is when breadth reclassifies a post as a *subject*; three levers (speed, expensive signals over likes, conversation breadth) manufactured across four stages — Claude-built swipe file → video + claim-not-description hook + first-reply comment gate → tiered creators on a timed schedule (200+ posts in 4h) → convert the spike and stay visible

## Website

Designing and generating websites with AI — immersive/animated sites, recreation-grade design specs, asset-first pipelines. See [[moc - Website]].

- [[Immersive AI-built websites follow a four-phase pipeline - asset-first direction, a recreation-grade spec, iterative Fable 5 builds, and a compounding prompt library]] — the motionsites designer's full process, transcribed and frame-analyzed: Pinterest motif → Higgsfield hero video → four-block spec (assets/fonts/layer-structure/scroll-scrub) → Cursor + Fable 5 iterative build → convert every finished page back into an "exact recreation prompt" that compounds into a template library

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
- [[MIT quantitative finance maps directly onto prediction market trading through eight mathematical phases]] — MIT Financial Mathematics course decoded for Polymarket: linear algebra, probability, stochastic processes, regression, VaR, GARCH, portfolio theory, and factor models

## Embeddings

Embedding models, retrieval architectures, and vector search.

- [[scaling embedding models requires LLM-labeled deduplication to fix the fake negative problem]] — LLM-labeled deduplication fixes false negatives that poison contrastive training at scale
- [[ColBERT MaxSim is a submodular facility location objective and that is why it generalizes]] — MaxSim scoring is a facility location objective with diminishing returns, explaining ColBERT's cross-domain generalization over single-vector models
- [[late interaction lets a 150M ColBERT model outperform 7B dense retrievers on reasoning-intensive retrieval]] — Reason-ModernColBERT (150M) beats all dense models up to 7B on BRIGHT benchmark, with controlled experiments showing late interaction doubles performance over single-vector on identical data
- [[OBLIQ-Bench shows that scalable retrievers fail to surface oblique queries that reasoning LLMs can verify]]
- [[SMVE makes billion-doc multivector retrieval practical - sparse random projections gate exact MaxSim to survivors at p99 under 100ms]] — Hamel/Marek Galovic: MaxSim costs ~2,000x a dot product and 10-100x storage; SMVE's sparse top-8 random-projection pre-filter runs exact MaxSim only on inverted-index survivors — p99 <100ms at 1B docs; plus Iso-ModernColBERT (~3x faster at bf16)
- [[embedding model selection is a cost-quality tradeoff MTEB cannot see - and fine-tuning the embedder is the overlooked high-impact lever]] — Hamel/Radu Gheorghe: INT8 ≈3x CPU speedup, binary vectors = 32x storage cut, bfloat16 = 2x free, Matryoshka truncation, test-on-your-domain; VespaEmbed for no-code embedder fine-tuning — MIT benchmark of five oblique IR tasks (descriptive, analogue, tip-of-tongue) where every dense, lexical, late-interaction, and agentic retriever scores near-zero NDCG@10 while a GPT-5.2 tournament reranker reaches 0.43–0.91

## Inference

Model serving and runtime — engines, KV cache, speculative decoding, quantization, and serving economics. Folder MOC: [[moc - Inference]] (13 notes).

- [[NVIDIA's hardware-friendly LLM design guide - near-square tile-aligned dimensions, width over depth, NVFP4, and wide expert parallelism]] — NVIDIA's model-hardware co-design guidelines: near-square/tile-aligned linear layers, width over depth, NVFP4 quantization, and wide expert / chunked-pipeline / Helix parallelism on Blackwell
- [[paged attention applies OS virtual memory paging to KV cache and unlocks 2-4x LLM serving throughput]] — PagedAttention KV paging; the canonical serving-throughput result
- [[Modal argues speculative decoding is the only inference optimization that matters, and custom DFlash speculators turn acceptance length into 2-3x speedups]] — speculative decoding as the dominant serving-engine optimization (DFlash speculators)
- [[Philip Kiely details how Baseten built the world's fastest GLM-5.2 API by stacking NVFP4 quantization, KV-aware routing, prefill-decode disaggregation, and MTP speculation]] — production serving stack for SOTA TPS/TTFT
- [[vLLM throughput benchmarking on H100 — tensor-parallel sizing, speculative decoding, and FP8 KV-cache economics]] — 18-model serving-parameter sweep + the $/H100-hour math
- …+6 more in [[moc - Inference]] (Superlinked SIE multi-model serving, Joe Barrow's *Inference Engineering* review, Amit Shekhar vLLM, Rachel Rapp Baseten draft models, Ramp Labs KV-cache compaction, Chandra-OCR batch economics)

## LLMs

Foundational architecture, training, scaling, and interpretability of large language models.

- [[twenty-six papers capture ninety percent of the alpha behind modern LLMs from attention through reasoning and mixture of experts]] — curated reading order from Transformers through scaling laws, alignment, reasoning, and MoE architectures
- [[distributed research swarms close the feedback loop that single-agent autoresearch leaves open]] — PoC extending Karpathy's autoresearch into a coordinator-guided swarm with ShinkaEvolve-inspired guidance pipeline
- [[autoresearch loops cheat when guardrails are loose but converge on real findings when tightly scoped]] — 71 experiments across training and model compression showing proposal quality and environment design trump model intelligence
- [[MARS - Modular Agent with Reflective Search sets open-source SOTA on MLE-Bench via budget-aware MCTS, modular decomposition, and comparative reflective memory]] — Google Cloud AI Research: three pillars for automated MLE — cost-constrained MCTS (efficiency-guided reward penalizing slow runs), a modular Design-Decompose-Implement pipeline (2.3x larger multi-file repos), and comparative reflective memory that distills causal lessons from solution deltas (88% causal accuracy, 63% cross-branch "Aha" transfer); open-source SOTA on MLE-Bench with a 4h-vs-24h Pareto win proving gains are architectural not just budget
- [[Sara puts an LLM agent at the center of the Bayesian optimization loop - agentic BO keeps the probabilistic surrogate while letting the agent reconfigure the search mid-run]] — Brunzema, Tiao et al. (RWTH/Meta, arXiv 2608.00316): "agentic Bayesian optimization" — the LLM agent is the decision maker in the BO loop while a Bayesian backend supplies uncertainty, resolving the adaptivity-vs-uncertainty either/or (LLM-as-optimizer discards the surrogate; LLM-as-component freezes the policy). Instantiated as **Sara** (agent) + **lenz** (modular BoTorch backend, single CLI, raw trial log as single source of truth so reconfiguration never invalidates data). Two control levels (point + policy) as a metalevel MDP; matches SOTA BO with no priors, beats LLM baselines (LLAMBO, Centaur), natural-language priors improve beyond standard BO, and it reconfigures the whole problem mid-run as requirements change. Extends the autoresearch loop to zero-order optimization; 19 figures
- [[CEDAR runs LLM-driven MCTS with a Judge as fitness function and an Editor as variation operator to design complex systems from natural-language goals]] — Yingtao Tian (Sakana AI, arXiv 2608.06871): goal-directed design of complex systems (system dynamics / ALife — Lotka-Volterra to Forrester's World Dynamics) as LLM-driven MCTS over a restricted runnable-Python representation with stock/flow primitives. The LLM Judge scores emergent behavior against a natural-language goal (fitness + textual analysis per node); the LLM Editor mutates system structure (variation operator); formally an MCTS variant with LLM-parameterized transition kernel and value function generalizing UCT. Optimizes vague NL goals, fits records without a system skeleton (beats Optuna even when Optuna gets the full formulae), preserves solution diversity (tree = structured population), interpretable step-by-step. The methodological complement to Sara: LLM-as-fitness for unformalizable goals vs GP-surrogate-as-fitness for calibrated uncertainty; different LLMs carry different implicit objective priors (Claude favored population, GPT-5.1 resources). No code release as of 2026-08-11; 14 figures
- [[Model Discovery Agent couples an LLM proposer with SMC, SBI, and value-of-information to discover mechanistic world models from few experiments]] — Kevin Murphy (sole author, arXiv 2608.09696; captured with his own 12-tweet takeaway thread + full 66pp paper in one note): interventional what-if forecasting needs a mechanistic model, mechanisms need experiments, so data efficiency is the game. LLM as *proposer* + Bayesian machinery (SMC posteriors, SBI for intractable likelihoods, VoI experiment design); M-open extension (predictive check fails → LLM proposes new hypotheses); SOTA on DiscoverPhysics (74% exact form vs 31%, ~5x fewer experiments) and AutoSciLab (~8 experiments to beat the 60-experiment prior SOTA, interpretable vs PySR's unphysical fits); NeuronBench (partially-observed stochastic HH neurons where textbook probes are silent — repo: murphyk/neuronbench); collapse-free supervised learned summary stats ~10⁴x faster than particle filtering. Includes the Biderman mechanism-necessity exchange. The narrow-proposer complement to Sara (LLM-as-driver) and CEDAR (LLM-as-fitness); 48 figures. **Updated 2026-08-26** with Murphy's new arXiv version, U Toronto talk video, and the polyglot workflow diagram (Claude Code → MDA on Modal → OpenRouter proposal LLM → numpyro/diffrax models → SMC³ in jax → VoI in numpy → Python/Julia env)/images
- [[rl environment creation is becoming a distributed marketplace that could 10x cost efficiency over contracting firms]] — the hidden RL environment contracting industry, verifier design challenges, and a distributed bounty model with LLM-adversarial verification
- [[Harvey's Tenet post-trains Kimi K3 with GSPO in rubric-graded legal environments, doubling LAB hold-out completions while co-optimizing cost via reward shaping]] — Harvey + Fireworks: async GSPO RL (rank-64 LoRA over ~500k expert tensors, ~150 B300s × 2 months, ~1,750 partner-request environments with ~50-criteria expert rubrics, Kimi 2.6 judge, >1,000-turn rollouts) nearly doubles LAB hold-out completions with zero-shot transfer to APEX Agents/RedlineBench and no parametric-knowledge regression; reward-shaped token efficiency keeps cost flat. Plus RLM harness post-training for 80M-token M&A diligence (43.8%→60.1%), Review Table extraction at one-tenth cost/cell, and Engram parametric firm memory (-58% tokens, -90% cost, 3x intelligence-per-token). Exemplary benchmark-divergence appendix; 6 figures
- [[automating AI skill improvement fails without manual comprehension of outputs]] — Three Gulfs framework: autoresearch optimizes against wrong criteria when you skip manual error analysis and jump straight to automated evals

## AI Hardware Infrastructure

Physical compute layer enabling AI accelerators — semiconductor packaging, substrates, laser tools, and advanced chiplet integration.

- [[Crux Capital's Gaetano maps Physical AI as a ten-layer supply chain from training to deployment claiming it rivals the optics super-cycle in investment magnitude]] — Gaetano (Crux Capital) frames Physical AI as the next investment supercycle: an eleven-layer stack from model training to end markets where "the robot is the headline but the stack is the opportunity"; he is launching it as a second coverage pillar alongside optics/photonics with the same early-cycle positioning thesis
- [[LPKF LIDE holds 80% qualification share in glass via drilling, a quasi-monopolist hidden behind non-core segment losses on a $20B TAM ramp]] — LPKF's LIDE laser process dominates through-glass via drilling at Intel/Samsung/TSMC, hiding a quasi-monopoly position behind non-core Solar losses at 3x EV/Sales
- [[DELL earnings reveal memory supply crisis driving enterprises from buying more RAM to CXL pooling efficiency, creating tailwinds for Penguin Solutions]] — DELL Q1 2026 earnings quotes confirm memory uncertainty and component inflation are forcing enterprises toward CXL memory pooling efficiency over raw procurement; Penguin Solutions (5,000+ customers across neoclouds, sovereigns, enterprises) positioned as pre-engineered architecture provider

## Graph Theory

Network structure and graph algorithms — small-world/decentralized search, random graphs and expanders, diffusion/cascades, spectral methods, random walks, and link analysis.

- [[Jon Kleinberg's CS 6850 The Structure of Information Networks (Cornell Fall 2024) - syllabus and reading list]] — Kleinberg's Cornell grad course + curated reading list, organized around three pillars: small-world properties & decentralized search (Milgram, navigable small-world), cascading behavior/diffusion (Granovetter thresholds, epidemic/gossip algorithms, influence maximization), and spectral analysis & random walks (graph partitioning, PageRank-style link analysis); anchored on the free *Networks, Crowds, and Markets* textbook

## Learning Resources

Study guides, interview prep, and curated course material.

- [[Claude Certified Architect exam covers five domains from agentic loops to context management]] — comprehensive self-study breakdown of all five exam domains with tutor prompts and build exercises
- [[LLM optimization interview prep maps Flash Attention, ZeRO, speculative decoding, and MoE across training and inference]] — Gauri Gupta's AI lab interview notes spanning memory, compute, inference, and distributed-training optimization
- [[Hamel's AI Product Engineering series - 13 sessions on evals, context, and systems, indexed]] — index of Hamel Husain's 13-session series and his improvement ladder (evals → retrieval/context → systems/harness → post-training last); 11 sessions captured as vault notes across Data Agent, Eval & Monitoring, Embeddings, Agentic Search, Inference, and Harness Engineering, 2 indexed-only (inference-latency basics, open-model economics incl. the Params×N×0.5 memory rule)

## Thinking

- [[genius thinking is the ability to keep thinking past threat reactions]]
