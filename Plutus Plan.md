---
created: 2026-01-22
description: Full implementation plan for Plutus, a financial research platform for Claude Code with ToolResult contract enforcement
source: internal
type: spec
---

# Plutus: Financial Research Platform for Claude Code

> Auto-generated: 2026-01-22
> Status: Ready for Implementation (contract-enforced examples ONLY)
> Contract: ToolResult v1.0 REQUIRED on *all* surfaces (MCP, HTTP API, scripts)
> NOTE: See "Correct, Copy/Paste-Safe Example" section for the ONLY pattern to copy. Phase section examples show WHAT to build, not HOW.

## Plan Consistency Guarantee

**This document is contract-authoritative.** Any snippet in this plan that:
- calls `server.tool(...)` directly in `src/tools/**`
- returns `{ content: [...] }` from a tool handler
- uses `ok()/fail()` inside a tool handler (instead of returning domain data)

is considered a **SPEC BUG**. Do not implement those patterns. The only correct implementation follows the `registerTool` wrapper which handles all envelope concerns.

## Critical Invariant: Ledger Is The Only Source Of Truth

**Non-negotiable invariant (enforced in code + tests):**
- SQLite `portfolio_events` is the sole source of truth for:
  - holdings, lots, cost basis, realized/unrealized P&L, cash
  - corporate action adjustments and symbol changes
- YAML stores **settings only** (name, base currency, benchmark, tax lot method, risk limits).

Any tool that computes portfolio state MUST derive it from the event stream, never from YAML holdings.

## Ledger Hardening (Required)
Event-sourcing succeeds only if the ledger is *self-validating*.
Add DB-level constraints + explicit event versioning:
- `schema_version` on events (e.g., 1)
- `idempotency_key` REQUIRED for imports (optional for manual)
- CHECK constraints for required fields by type (BUY/SELL require ticker, shares, price)
- Strict ticker normalization (uppercased, trimmed) at write boundary

## Corporate Actions: Required Implementation (Not Optional)

Portfolio state derivation MUST apply corporate actions consistently:
- **SPLIT**: adjust share counts and per-share cost basis for all open lots prior to valuation.
- **SYMBOL_CHANGE**: map events/positions from old_ticker → new_ticker for as-of views.
- **DIVIDEND**: represent as explicit ledger cash event (cash_delta) and (optionally) DRIP BUY.
- **SPINOFF / MERGER**: create explicit adjustment events with cost-basis allocation rules.
- **FRACTIONAL SHARES**: record cash-in-lieu as CASH event when applicable.

### Corporate Action Idempotency + Ordering (Required)
Add a lightweight job/state table so nightly sync/apply can be retried safely:
- `corporate_action_jobs(ticker, as_of, provider, status, last_run_at, last_action_id_seen)`

Apply ordering:
1) by `effective_date` ascending
2) then by `provider_sequence` if available (else deterministic hash)
3) priority: SYMBOL_CHANGE → SPLIT → SPINOFF/MERGER → DIVIDEND

Spinoff rules:
- store allocation method in `meta_json` (ratio or cost-basis allocation percentage)
- emit ledger NOTE + adjustment events so derived state is reproducible

**Required tools:**
- `corporate_actions_sync` - fetch + persist actions for held/watchlist tickers (via data provider)
- `corporate_actions_apply` - apply pending actions to ledger events, create adjustment records

**Required functions:**
- `adjustLotsForSplit(ticker, ratio, effectiveDate)` - recalculate share counts and cost basis
- `remapSymbol(oldTicker, newTicker, effectiveDate)` - update position lookups for symbol changes
- `processedDividend(ticker, perShareAmount, exDate)` - create DIVIDEND cash event if applicable

**Scheduler integration:**
- Nightly job fetches corporate actions for held tickers + watchlist
- Applies any pending actions before morning summary generation

## Output Contract (Mandatory - Enforced Everywhere)

All surfaces MUST return a consistent envelope for deterministic parsing, validation, testing, and stable integration:
- **MCP tools** - primary interface
- **Dashboard HTTP API** - all endpoints return same envelope
- **Scheduler/script/hook outputs** - JSON ToolResult to stdout when structured output expected

## Runtime Topology (Non-Negotiable)
**MCP over stdio requires a pristine stdout channel.**
If *anything* besides MCP frames is written to stdout, Claude Code can mis-parse tool responses.

Therefore Plutus MUST ship two entrypoints:
1) `mcp-server/src/entrypoints/stdio.ts` — MCP server only (stdio transport), **no Express**, **no cron**, and **no stdout logging**.
2) `mcp-server/src/entrypoints/daemon.ts` — Dashboard API + scheduler + background jobs.

**Logging rule:** stdio entrypoint logs to `stderr` only (or uses a logger configured for stderr).

```ts
type ToolResult<T> =
  | { ok: true; data: T; meta: ToolMeta }
  | { ok: false; error: { code: string; message: string; details?: any }; meta: ToolMeta };

interface ToolMeta {
  schema_version: string;  // e.g., "1.0"
  tool: string;            // tool name
  request_id: string;      // uuid for tracing
  duration_ms: number;     // execution time
  cached: boolean;         // whether data came from cache
  [key: string]: any;      // additional metadata (source, etc.)
}
```

### IMPORTANT: Tool handlers return DATA, not MCP "content"

All MCP tool handlers MUST return the typed output `O` (plain JS object).
The `registerTool(...)` wrapper is responsible for:
- validating `O` with Zod
- wrapping it in `ToolResult`
- serializing it into MCP `{ content: [{ type: "text", text: JSON.stringify(ToolResult) }] }`

**Handlers must NOT:**
- Return `{ content: [...] }` directly
- Call `JSON.stringify(ok(...))` themselves
- Mix MCP envelope concerns with business logic

### IMPORTANT: All code examples in this plan MUST follow the contract

Any snippet that shows `server.tool(...)` usage or returns `{ content: [...] }` from a handler is considered **NON-COMPLIANT**. Treat it as a bug in the plan and do not copy such patterns into implementation.

### Pattern: "registerTool" + "handler returns domain data"

All tools must follow this structure:
1. Define input Zod schema (`In`)
2. Define output Zod schema (`Out`)
3. Implement handler returning plain object `O` (domain data only)
4. Register via `registerTool(server, name, desc, In, Out, handler)`

**Non-compliant patterns are banned in CI:**
- `server.tool(...)` in tool files
- returning MCP content objects in tool files
- `JSON.stringify(ok/fail)` in tool files

### REQUIRED: Tool Module Export Convention

Tool modules must export `registerXTools(server)` functions that ONLY use `registerTool(...)`.
Tool modules must NOT import `McpServer.tool` directly. Tool modules must:
- `import { registerTool } from '../utils/tool-wrapper'`
- define In/Out Zod schemas
- implement handler returning domain data only
- call `registerTool(server, name, desc, In, Out, handler)`

### CI Enforcement Strengthened (Required)

Add ESLint rule or custom lint to prohibit:
- Identifier `server.tool` usage outside `tool-wrapper.ts`
- Any return shape containing `{ content: ... }` in `src/tools/**`
- Any `JSON.stringify(ok` / `JSON.stringify(fail` in `src/tools/**`
- Imports from `src/tools/**` in other tool files (tools must not call tools)

### Contract Requirements (Enforced)
All tool responses MUST include:
1. `meta.schema_version` (e.g., "1.0")
2. `meta.tool` (tool name)
3. `meta.request_id` (uuid)
4. `meta.duration_ms`
5. `meta.cached` (boolean)

Tools MUST:
- Validate inputs with Zod (already planned)
- Validate outputs with Zod before returning
- Use shared helpers (`ok()`, `fail()`)

### Standard Helpers (Required)
All tools use response factories from `mcp-server/src/utils/response.ts`:

```ts
import { v4 as uuidv4 } from 'uuid';

export function ok<T>(tool: string, data: T, meta?: Record<string, any>): ToolResult<T> {
  return {
    ok: true,
    data,
    meta: { schema_version: "1.0", tool, request_id: uuidv4(), duration_ms: 0, cached: false, ...meta }
  };
}

export function fail(tool: string, code: string, message: string, details?: any, meta?: Record<string, any>): ToolResult<never> {
  return {
    ok: false,
    error: { code, message, details },
    meta: { schema_version: "1.0", tool, request_id: uuidv4(), duration_ms: 0, cached: false, ...meta }
  };
}
```

### Output Schema Validation (Required)
Each tool must define and validate its output schema:

```ts
const PriceSnapshotOut = z.object({
  ticker: z.string(),
  price: z.number(),
  change: z.number(),
  change_percent: z.number()
});

// In tool handler:
const startTime = Date.now();
const rawData = await fetchPrice(ticker);
const parsed = PriceSnapshotOut.safeParse(rawData);
if (!parsed.success) {
  return fail("get_price_snapshot", "BAD_OUTPUT", "Output schema mismatch", parsed.error);
}
return ok("get_price_snapshot", parsed.data, { duration_ms: Date.now() - startTime, source: 'financialdatasets' });
```

**Example compliant handler return (domain data only):**
```ts
// Handler returns plain domain object (NOT ToolResult, NOT MCP content)
// The registerTool wrapper handles validation + ToolResult wrapping + MCP serialization
return { ticker: 'NVDA', price: 142.30, change: 2.15, change_percent: 1.53, as_of: '2026-01-22T12:00:00Z' };
```

**Wrapper output (generated automatically by registerTool):**
```ts
// Only the tool-wrapper.ts produces this MCP envelope - tool handlers NEVER do
{ content: [{ type: 'text', text: JSON.stringify({ ok: true, data: {...}, meta: {...} }) }] }
```

### Tool Registration Wrapper (Enforcement Mechanism)

All tools MUST use this wrapper for registration to enforce the contract automatically:

**File:** `mcp-server/src/utils/tool-wrapper.ts`
```ts
import { z } from 'zod';
import type { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { ok, fail } from './response.js';

export const ToolResultSchema = z.union([
  z.object({
    ok: z.literal(true),
    data: z.any(),
    meta: z.object({
      schema_version: z.string(),
      tool: z.string(),
      request_id: z.string(),
      duration_ms: z.number(),
      cached: z.boolean()
    }).passthrough()
  }),
  z.object({
    ok: z.literal(false),
    error: z.object({ code: z.string(), message: z.string(), details: z.any().optional() }),
    meta: z.object({
      schema_version: z.string(),
      tool: z.string(),
      request_id: z.string(),
      duration_ms: z.number(),
      cached: z.boolean()
    }).passthrough()
  })
]);

export function registerTool<I, O>(
  server: McpServer,
  name: string,
  description: string,
  inSchema: any,
  outSchema: z.ZodType<O>,
  handler: (input: I) => Promise<O & { __meta?: Partial<ToolMeta> }>
) {
  server.tool(name, description, inSchema, async (input: I) => {
    const start = Date.now();
    try {
      const raw = await handler(input);
      // Allow handlers/services to optionally attach ToolMeta via reserved __meta
      const { __meta, ...domain } = (raw as any) || {};
      const parsed = outSchema.safeParse(domain);
      if (!parsed.success) {
        return { content: [{ type: 'text', text: JSON.stringify(
          fail(name, 'BAD_OUTPUT', 'Output schema mismatch', parsed.error, { duration_ms: Date.now() - start, ...(__meta || {}) })
        ) }] };
      }
      return { content: [{ type: 'text', text: JSON.stringify(
        ok(name, parsed.data, { duration_ms: Date.now() - start, ...(__meta || {}) })
      ) }] };
    } catch (e: any) {
      return { content: [{ type: 'text', text: JSON.stringify(fail(name, 'UNHANDLED', e?.message || 'Unhandled error', e, { duration_ms: Date.now() - start })) }] };
    }
  });
}
```

This wrapper:
1. Automatically measures `duration_ms`
2. Ensures `ok()/fail()` usage
3. Validates output against provided schema
4. Catches unhandled exceptions

### Correct, Copy/Paste-Safe Example: Tool File

**This is THE canonical example to copy when creating new tools.**

**File:** `mcp-server/src/tools/finance/prices.ts`
```ts
import { z } from 'zod';
import type { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { registerTool } from '../../utils/tool-wrapper.js';
import { MarketDataService } from '../../services/market-data-service.js';

// 1. Define input schema
const In = z.object({ ticker: z.string() });

// 2. Define output schema (domain data shape)
const Out = z.object({
  ticker: z.string(),
  price: z.number(),
  change: z.number(),
  change_percent: z.number(),
  as_of: z.string()
});

// 3. Export registration function
export function registerPriceTools(server: McpServer) {
  // 4. Use registerTool (NOT server.tool)
  registerTool(server, 'get_price_snapshot', 'Get current price snapshot for a stock ticker', In, Out,
    // 5. Handler returns domain data ONLY (1-3 lines)
    async ({ ticker }) => {
      return await MarketDataService.getPriceSnapshot(ticker);
    }
  );
}
```

**What this example demonstrates:**
- Imports `registerTool` from wrapper (NOT `server.tool`)
- Handler returns plain domain object (NOT ToolResult, NOT MCP content)
- Handler is thin: calls service, returns result
- All serialization/envelope/meta handled by wrapper

### Non-Negotiable Rules (CI Enforced)

**Tool Registration:**
- No MCP tool may call `server.tool(...)` directly. All tools MUST be registered via `registerTool(...)`.
- CI lint checks enforce this: `grep -r "server\.tool(" --include="*.ts" | grep -v registerTool | grep -v tool-wrapper.ts` must be empty.

**HTTP API:**
- No HTTP handler may return a raw object; it must return `ToolResult<T>` with the same meta fields.
- Dashboard API routes MUST use equivalent `apiOk()`/`apiFail()` helpers.

**Scripts/Hooks:**
- No script/hook prints ad-hoc text when structured output is expected; it prints ToolResult JSON.
- Example: `console.log(JSON.stringify(ok("script_name", { result }, { duration_ms })));`

**CI Lint Checks (Automated):**
In addition to grepping for `server.tool(`, CI MUST also enforce:
- No tool returns `{ content: ... }` directly (only the wrapper does)
- No tool calls `JSON.stringify(ok(...))` itself
- No tool prints ad-hoc text to stdout when structured output expected

Suggested checks (add to CI pipeline):
```bash
# No direct server.tool calls in tool files
grep -R "server\.tool\(" mcp-server/src/tools -n | grep -v tool-wrapper.ts && exit 1 || true

# No direct MCP content returns in tool files
grep -R "return.*{ *content:" mcp-server/src/tools -n && exit 1 || true

# No manual JSON.stringify of ToolResult in tool files
grep -R "JSON.stringify(ok\|JSON.stringify(fail" mcp-server/src/tools -n && exit 1 || true
```

## Data Access Layer (DAL) for Market Data

**Problem:** Repeated per-tool API calls cause latency, rate-limit failures, and inconsistent meta/caching.

**Solution:** All market/fundamental/news access MUST go through a shared DAL that provides:
- **TTL caching** (per endpoint, default 30s for prices, 5min for fundamentals)
- **Inflight request coalescing** (single-flight: duplicate concurrent requests share one API call)
- **Concurrency limits** (p-limit style, max 5-10 concurrent API requests)
- **Retries** with exponential backoff + jitter on transient failures (429/5xx/timeouts)
- **Consistent ToolMeta** enrichment: `source`, `cached`, `cache_age_ms`, `provider_request_id`

**Files:**
- `mcp-server/src/data/market-data-client.ts` (DAL facade: caching, retries, concurrency)
- `mcp-server/src/data/providers/financialdatasets/*` (provider implementation)
- `mcp-server/src/data/providers/tavily/*` (optional search/news provider)

**Exports:**
- `getPriceSnapshot(ticker): Promise<PriceSnapshot>`
- `getPrices(ticker, opts): Promise<PriceBar[]>`
- `getNews(ticker, limit): Promise<NewsItem[]>`
- `getFinancials(ticker, type): Promise<Financial[]>`

**Rule:** Tools MUST NOT call provider adapters directly. All data access goes through the DAL.
Provider code MUST NOT live under `src/tools/**`.

### Rule: Tools MUST NOT Import Other Tools

Tools must not import from `src/tools/**` except their own module index.
Cross-cutting operations must live in:
- `src/services/**` (orchestration + domain composition)
- `src/data/**` (DAL: caching/retries/rate limiting)
- `src/domain/**` (pure computation)

**Directory convention (strict - enforced by lint):**
- `src/tools/**` = *registration only* (Zod In/Out schemas + registerTool + call service)
  - NO direct DB access, NO direct API calls, NO domain logic
  - Handlers must be 1-3 lines: call service, return result
- `src/services/**` = orchestration (DAL + domain + storage), returns domain objects
  - Testable without MCP scaffolding
  - Reusable by HTTP API and scripts
- `src/domain/**` = pure deterministic math (ledger folding, lot matching, indicator calc)
  - NO I/O, NO side effects, easily unit tested
- `src/data/**` = data access with caching/retries (the DAL)

## Layering Contract (Enforced)

**Goal:** Keep MCP/HTTP/scheduler thin, keep logic testable, prevent architectural drift.

### Allowed Imports (Hard Rules)

| Layer | May Import |
|-------|------------|
| `src/tools/**` | `src/utils/tool-wrapper.ts`, `src/services/**`, `zod`, types only |
| `src/services/**` | `src/data/**`, `src/domain/**`, `src/storage/**`, `src/utils/**` |
| `src/domain/**` | ONLY other `src/domain/**` + small math helpers (NO I/O) |
| `src/data/**` | Provider adapters, caching utilities, rate limiting |

### Forbidden Imports (CI Enforced)

- `src/tools/**` importing `src/storage/**`, `src/data/**`, or provider adapters directly
- `src/domain/**` importing anything outside `src/domain/**`
- Any file outside `src/tools/**` calling MCP SDK directly

### CI Layer Enforcement Checks

```bash
# Tools cannot touch storage/data/providers directly
grep -R "from '../../storage" mcp-server/src/tools -n && exit 1 || true
grep -R "from '../../data" mcp-server/src/tools -n && exit 1 || true
grep -R "from '../providers" mcp-server/src/tools -n && exit 1 || true

# Domain must be pure (no I/O imports)
grep -R "from '../storage\|from '../data\|fetch\(" mcp-server/src/domain -n && exit 1 || true

# Only tool-wrapper.ts may use MCP SDK server.tool
grep -R "server\.tool\(" mcp-server/src -n | grep -v tool-wrapper.ts && exit 1 || true
```

### Mechanical Enforcement (Recommended)

In addition to grep checks, enforce layer boundaries with TypeScript project references + ESLint boundaries:

**TypeScript Project References:**
- `mcp-server/tsconfig.tools.json` - references services only
- `mcp-server/tsconfig.services.json` - references domain, data, storage
- `mcp-server/tsconfig.domain.json` - standalone, no references
- `mcp-server/tsconfig.data.json` - references providers
- `mcp-server/tsconfig.storage.json` - standalone

**ESLint Boundaries Plugin:**
```js
// .eslintrc.js
module.exports = {
  plugins: ['boundaries'],
  rules: {
    'boundaries/element-types': ['error', {
      default: 'disallow',
      rules: [
        { from: 'tools', allow: ['services', 'utils'] },
        { from: 'services', allow: ['domain', 'data', 'storage', 'utils'] },
        { from: 'domain', allow: ['domain'] },
        { from: 'data', allow: ['providers', 'utils'] }
      ]
    }]
  }
};
```

## Overview

Plutus is a comprehensive migration and enhancement of Dexter's financial research capabilities into a native Claude Code integration. It combines an MCP server (exposing 18+ financial tools) with a Claude Code plugin (providing skills, subagents, and commands) to deliver portfolio monitoring, stock evaluation, and intelligent financial analysis directly within Claude Code's terminal interface, complemented by an external React-based web dashboard for real-time visualization.

## Claude Code Extension Mechanisms

This section maps each Plutus capability to the appropriate Claude Code extension mechanism.

### Extension Types Used

| Mechanism | Purpose in Plutus | When Triggered |
|-----------|------------------|----------------|
| **MCP Server** | Core financial tools, data fetching, storage | Tool calls from Claude |
| **Skills** | Domain expertise, auto-activated guidance | Context-based (auto) |
| **Subagents** | Specialized parallel analysis | Task tool spawning |
| **Commands** | User-initiated workflows | Slash commands (manual) |
| **Hooks** | Automation, validation, notifications | Event-driven (auto) |
| **Scripts** | Utilities, data processing, CLI tools | Called by other components |

---

### MCP Server Tools (24+ tools)

The MCP server exposes tools that Claude can call directly. These are the "primitives" that other mechanisms build upon.

**Financial Data Tools (migrated from Dexter):**
| Tool | Purpose |
|------|---------|
| `get_price_snapshot` | Current stock price |
| `get_prices` | Historical prices |
| `get_income_statements` | Revenue, earnings data |
| `get_balance_sheets` | Assets, liabilities, equity |
| `get_cash_flow_statements` | Cash flow data |
| `get_financial_metrics_snapshot` | P/E, market cap, etc. |
| `get_analyst_estimates` | Price targets, ratings |
| `get_news` | Company news |
| `get_filings` | SEC filings |
| `get_insider_trades` | Insider activity |
| `financial_search` | Intelligent meta-router |

**Portfolio Tools (new):**
| Tool | Purpose |
|------|---------|
| `portfolio_add_event` | Append immutable ledger event (BUY/SELL/DIVIDEND/SPLIT/CASH) |
| `portfolio_get_events` | Query ledger events with filters |
| `portfolio_get_holdings` | Derived view: current positions with P&L from ledger |
| `portfolio_summary` | Portfolio overview (computed from ledger) |
| `portfolio_import_yaml` | One-time import of YAML holdings as BUY events |
| `watchlist_add` | Add to watchlist |
| `watchlist_remove` | Remove from watchlist |
| `watchlist_get` | Get watchlist |

**Thesis Tools (new):**
| Tool | Purpose |
|------|---------|
| `thesis_create` | Create/update investment thesis |
| `thesis_get` | Retrieve thesis |
| `thesis_search` | Semantic search over theses |
| `thesis_validate` | Check thesis vs current data |

**Analysis Tools (new):**
| Tool | Purpose |
|------|---------|
| `technical_analysis` | RSI, MACD, MAs, Bollinger |
| `risk_analysis` | Beta, concentration, exposure |
| `generate_stock_report` | Full equity research report |
| `score_ticker` | Custom rubric scoring |
| `compare_tickers` | Multi-ticker comparison |

**Alert Tools (new):**
| Tool | Purpose |
|------|---------|
| `alert_create` | Create price/news alert |
| `alert_list` | List all alerts |
| `alert_delete` | Remove alert |
| `alert_check_now` | Manual alert check |

---

### Skills (Auto-Activating Expertise)

Skills provide domain knowledge that Claude automatically uses when relevant. They don't require user invocation.

| Skill | Auto-Triggers On | What It Provides |
|-------|------------------|------------------|
| `portfolio-analysis` | "portfolio", "holdings", "P&L", "rebalance" | Framework for analyzing portfolio health |
| `stock-research` | "research", "analyze", "evaluate" + ticker | Research methodology and output format |
| `risk-assessment` | "risk", "exposure", "concentration", "beta" | Risk analysis framework |
| `ticker-comparison` | "compare", "which is better", "best buy" | Comparison methodology |
| `multi-agent-analysis` | "deep analysis", "comprehensive", "full report" | Orchestration of parallel agents |
| `thesis-management` | "thesis", "investment case", "bull case" | Thesis creation/validation guidance |
| `technical-signals` | "chart", "technical", "RSI", "MACD" | Technical analysis interpretation |
| `alert-configuration` | "alert", "notify", "watch for" | Alert setup guidance |

**Example Skill File:** `skills/portfolio-analysis/SKILL.md`
```markdown
---
name: portfolio-analysis
description: Use when discussing portfolio performance, rebalancing, allocation, or P&L. Provides systematic framework for portfolio health assessment.
---

# Portfolio Analysis Skill

[Guidance on how to analyze portfolios using Plutus tools...]
```

---

### Subagents (Specialized Parallel Workers)

Subagents are spawned via the Task tool for specialized, parallelizable work.

| Agent | Specialization | Model | Tools Access |
|-------|---------------|-------|--------------|
| `plutus-fundamental-analyst` | Financial statement analysis, valuation | sonnet | Finance tools, metrics |
| `plutus-technical-analyst` | Price action, indicators, chart patterns | sonnet | Price tools, TA tools |
| `plutus-sentiment-analyst` | News analysis, market sentiment | sonnet | News tools, search |
| `plutus-risk-analyst` | Risk factors, downside scenarios | sonnet | Risk tools, metrics |
| `plutus-synthesis-coordinator` | Integrate multi-agent outputs | opus | Read, thesis tools |

**Parallel Analysis Pattern:**
```
User: "Deep analysis on NVDA"

Claude spawns 4 agents in PARALLEL:
├─ Task(plutus-fundamental-analyst, "Analyze NVDA fundamentals")
├─ Task(plutus-technical-analyst, "Analyze NVDA technicals")
├─ Task(plutus-sentiment-analyst, "Analyze NVDA sentiment")
└─ Task(plutus-risk-analyst, "Assess NVDA risks")

Results collected, then:
└─ Task(plutus-synthesis-coordinator, "Synthesize NVDA analysis from: [outputs]")

Final synthesized report returned to user
```

**Example Agent File:** `agents/fundamental-analyst.md`
```markdown
---
name: plutus-fundamental-analyst
description: Analyzes company fundamentals including financials, valuation, and competitive position.
model: sonnet
tools:
  - mcp__plutus__get_income_statements
  - mcp__plutus__get_balance_sheets
  - mcp__plutus__get_financial_metrics_snapshot
  - mcp__plutus__get_analyst_estimates
---

# Fundamental Analyst Agent

[Detailed instructions for fundamental analysis...]
```

---

### Commands (User-Invoked Workflows)

Slash commands are explicit user actions that orchestrate complex workflows.

| Command | Usage | What It Does |
|---------|-------|--------------|
| `/portfolio` | `/portfolio` | Show portfolio overview with holdings, P&L |
| `/analyze` | `/analyze AAPL` | Quick fundamental + technical analysis |
| `/research` | `/research NVDA` | Full research report with scoring |
| `/research NVDA --deep` | Deep analysis | Spawns multi-agent analysis |
| `/compare` | `/compare AAPL,MSFT,GOOGL` | Compare tickers, find best buy |
| `/thesis` | `/thesis AAPL` | View/create investment thesis |
| `/alerts` | `/alerts` | List and manage alerts |
| `/dashboard` | `/dashboard` | Launch web dashboard |
| `/watchlist` | `/watchlist` | View/manage watchlist |
| `/risk` | `/risk` | Portfolio risk analysis |

**Example Command File:** `commands/research.md`
```markdown
---
name: research
description: Generate comprehensive research report with scoring
args:
  - name: ticker
    required: true
  - name: deep
    required: false
    default: false
---

# Research Report: {{ticker}}

[Workflow instructions...]
```

---

### Hooks (Event-Driven Automation)

Hooks trigger automatically on Claude Code events.

| Hook Event | Plutus Usage |
|------------|--------------|
| `SessionStart` | Check inbox for alerts triggered since last session |
| `PostToolUse` (on portfolio tools) | Auto-snapshot portfolio after changes |
| `Stop` | Remind about unacknowledged alerts |
| `PreToolUse` (on thesis_create) | Validate thesis format |

**Example Hook Config:** `hooks/hooks.json`
```json
{
  "SessionStart": [{
    "hooks": [{
      "type": "command",
      "command": "bun ${CLAUDE_PLUGIN_ROOT}/scripts/check-alerts.ts",
      "timeout": 10
    }]
  }],
  "PostToolUse": [{
    "matcher": "portfolio_add_holding|portfolio_remove_holding",
    "hooks": [{
      "type": "command",
      "command": "bun ${CLAUDE_PLUGIN_ROOT}/scripts/snapshot-portfolio.ts"
    }]
  }]
}
```

---

### Scripts (Utility Functions)

Scripts are standalone utilities called by other components.

| Script | Purpose | Called By |
|--------|---------|-----------|
| `scripts/check-alerts.ts` | Check and report triggered alerts | SessionStart hook, cron |
| `scripts/snapshot-portfolio.ts` | Save portfolio state to SQLite | PostToolUse hook |
| `scripts/morning-brief.ts` | Generate morning market brief | Cron scheduler |
| `scripts/eod-summary.ts` | End-of-day portfolio summary | Cron scheduler |
| `scripts/setup-db.ts` | Initialize SQLite schema | Manual setup |
| `scripts/export-report.ts` | Export analysis to PDF/HTML | Commands |
| `scripts/backtest-scoring.ts` | Backtest scoring rubric | Development |

**Example Script:** `scripts/check-alerts.ts` (contract-compliant)
```typescript
#!/usr/bin/env bun
import { AlertsService } from '../mcp-server/src/services/alerts-service.js';
import { ok, fail } from '../mcp-server/src/utils/response.js';

const start = Date.now();
try {
  const triggered = await AlertsService.checkNow();
  // Output ToolResult JSON for structured parsing by hooks/dashboard
  console.log(JSON.stringify(ok("script_check_alerts", { triggered, count: triggered.length }, { duration_ms: Date.now() - start })));
} catch (e: any) {
  console.log(JSON.stringify(fail("script_check_alerts", "CHECK_FAILED", e.message, e, { duration_ms: Date.now() - start })));
  process.exit(1);
}
```

---

### Required Service Surface Area (New)
To keep tools thin and keep non-MCP surfaces decoupled from MCP, define services as the single orchestration entrypoints:
- `services/portfolio-service.ts` (ledger append/query, derived holdings, snapshots)
- `services/alerts-service.ts` (CRUD + evaluation + dedupe/state)
- `services/research-service.ts` (report generation, scoring, comparison)
- `services/thesis-service.ts` (CRUD + embedding + search)

---

### Component Interaction Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                         USER INTERACTION                            │
│                                                                     │
│   /research NVDA --deep          "What's the risk on my portfolio?" │
│         │                                    │                      │
│         ▼                                    ▼                      │
│   ┌─────────────┐                    ┌─────────────┐               │
│   │  COMMAND    │                    │   SKILL     │ (auto-detect) │
│   │ research.md │                    │risk-assessment│              │
│   └──────┬──────┘                    └──────┬──────┘               │
│          │                                  │                       │
│          │ spawns                           │ guides                │
│          ▼                                  ▼                       │
│   ┌─────────────────────────────────────────────────┐              │
│   │                  SUBAGENTS                       │              │
│   │  ┌────────────┐ ┌────────────┐ ┌────────────┐  │              │
│   │  │Fundamental │ │ Technical  │ │   Risk     │  │ (parallel)   │
│   │  │  Analyst   │ │  Analyst   │ │  Analyst   │  │              │
│   │  └─────┬──────┘ └─────┬──────┘ └─────┬──────┘  │              │
│   └────────┼──────────────┼──────────────┼─────────┘              │
│            │              │              │                         │
│            │ call         │ call         │ call                    │
│            ▼              ▼              ▼                         │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │                     MCP SERVER TOOLS                         │ │
│   │  get_income_statements | technical_analysis | risk_analysis  │ │
│   │  get_balance_sheets    | get_prices         | portfolio_*    │ │
│   │  score_ticker          | compare_tickers    | thesis_*       │ │
│   └────────────────────────────┬────────────────────────────────┘ │
│                                │                                   │
│                                ▼                                   │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │                      STORAGE LAYER                           │ │
│   │         YAML Configs          │        SQLite DB             │ │
│   │   portfolio.yaml              │   price_history              │ │
│   │   watchlist.yaml              │   thesis_embeddings          │ │
│   │   alerts.yaml                 │   portfolio_snapshots        │ │
│   │   scoring-rubric.yaml         │   alert_history              │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │                         HOOKS                                │ │
│   │   SessionStart → check-alerts.ts                             │ │
│   │   PostToolUse  → snapshot-portfolio.ts                       │ │
│   └─────────────────────────────────────────────────────────────┘ │
│                                                                     │
│   ┌─────────────────────────────────────────────────────────────┐ │
│   │                      SCHEDULER (cron)                        │ │
│   │   */5 9-16 * * 1-5 → checkAlerts()                          │ │
│   │   30 8 * * 1-5     → morningBrief()                         │ │
│   │   15 16 * * 1-5    → eodSummary()                           │ │
│   └─────────────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Context

### Background

Dexter is an autonomous financial research agent built with TypeScript/Bun that excels at breaking down complex queries, fetching real-time financial data, and performing step-by-step analysis. The goal is to extend these capabilities to serve as a portfolio monitoring and stock evaluation assistant for institutional-grade investment workflows, while making it natively accessible from Claude Code.

### Current State (Dexter)

**Architecture:**
- TypeScript with Bun runtime
- React/Ink for Terminal UI
- LangChain for LLM orchestration (OpenAI, Anthropic, Google, Ollama)
- Financial Datasets API (financialdatasets.ai) for market data
- Tavily for web search

**Existing Financial Tools (18+):**
| Category | Tools |
|----------|-------|
| Price Data | getPriceSnapshot, getPrices, getCryptoPriceSnapshot, getCryptoPrices, getCryptoTickers |
| Fundamentals | getIncomeStatements, getBalanceSheets, getCashFlowStatements, getAllFinancialStatements |
| Metrics | getFinancialMetricsSnapshot, getFinancialMetrics, getAnalystEstimates |
| SEC Filings | getFilings, get10KFilingItems, get10QFilingItems, get8KFilingItems |
| Other | getNews, getInsiderTrades, getSegmentedRevenues |
| Meta | createFinancialSearch (intelligent router) |

**Key Files:**
- `dexter/src/agent/agent.ts` - Core agent loop with scratchpad
- `dexter/src/tools/finance/` - All financial tool implementations
- `dexter/src/tools/finance/api.ts` - Financial Datasets API client
- `dexter/src/model/llm.ts` - Multi-provider LLM integration
- `dexter/src/agent/prompts.ts` - System and user prompts

### Goals

- [ ] Migrate all existing Dexter financial tools to an MCP server
- [ ] Create Claude Code plugin with skills, agents, and commands
- [ ] Implement 10 new features for portfolio monitoring and analysis
- [ ] Build external React web dashboard with polling updates
- [ ] Support local embeddings via Xenova/transformers for thesis tracking
- [ ] Enable scheduled monitoring and alerts via node-cron
- [ ] Maintain pluggable data source architecture

### Non-Goals (Out of Scope)

- Real-time WebSocket streaming (using polling instead)
- Multiple portfolio support (single portfolio per project)
- Options/derivatives analysis
- Automated trade execution (analysis only)
- Mobile app or native desktop app
- Cloud deployment (local-first architecture)

## Design Decisions

### Decision 1: Integration Architecture

**Options Considered:**
1. MCP Server Only - Standalone server, works with any MCP client
2. Plugin Only - Native Claude Code integration, simpler setup
3. Hybrid - MCP server for tools + Plugin for skills/agents/commands

**Chosen:** Hybrid

**Rationale:** Maximizes flexibility by exposing financial tools via MCP (usable from Claude Desktop, Cursor, etc.) while leveraging Claude Code's plugin system for skills, specialized subagents, and slash commands. The plugin provides Claude Code-specific enhancements while the MCP server ensures broad compatibility.

### Decision 2: Data Storage

**Options Considered:**
1. SQLite Only - Single source of truth, good for queries
2. Files Only - Human-readable, git-friendly
3. Hybrid - JSON/YAML configs + SQLite for time-series

**Chosen:** Hybrid (JSON/YAML + SQLite) with Event Sourcing for Portfolio

**Rationale:** Configuration data (portfolio settings, watchlists, alert rules, scoring rubrics) stored in human-readable YAML files for easy editing and version control. SQLite database handles time-series data (historical prices, embeddings) and the **immutable portfolio event ledger**.

**Critical: Portfolio Source of Truth**
The `portfolio_events` ledger (SQLite) is the *only* source of truth for:
- Current positions (including lots for FIFO/LIFO cost basis)
- Cost basis and realized/unrealized P&L
- Cash balance
- Full audit trail (who bought what, when, at what price)

YAML portfolio config stores *settings only*:
- Portfolio name and base currency
- Benchmark ticker
- Tax lot method preference (FIFO, LIFO, specific ID)
- Alert and reporting preferences

**Migration Path:** Use `portfolio_import_yaml` tool to convert legacy YAML holdings into BUY events in the ledger.

### Decision 3: Investment Thesis Memory

**Options Considered:**
1. Plain Markdown files
2. External vector database (ChromaDB, Qdrant)
3. Xenova/transformers with local embeddings

**Chosen:** Xenova/transformers for local embeddings

**Rationale:** Runs entirely locally in Node.js without external API dependencies. Embeddings stored in SQLite alongside thesis content. Enables semantic search over investment theses while keeping the system self-contained.

### Operational Requirements (New)
- Embedding generation MUST run off the MCP main thread (worker thread or daemon job).
- Add `thesis_reindex_embeddings` tool to rebuild embeddings when model changes.
- Add `PLUTUS_EMBEDDINGS=off` to disable embeddings entirely (fallback to keyword search).

### Decision 4: Dashboard Rendering

**Options Considered:**
1. Rich ASCII tables in terminal
2. Minimal text output
3. External web UI

**Chosen:** External Web UI (React + Vite)

**Rationale:** A web dashboard provides richer visualization capabilities (charts, graphs, color-coded metrics) that aren't possible in terminal output. React + Vite offers fast development, modern tooling, and familiarity with existing codebase patterns.

### Decision 5: Multi-Agent Collaboration

**Options Considered:**
1. Sequential pipeline
2. Single orchestrator
3. Parallel specialists

**Chosen:** Parallel Specialists

**Rationale:** Spawning specialized subagents (Fundamental Analyst, Technical Analyst, Sentiment Analyst, Risk Analyst) in parallel maximizes throughput and mimics how a real investment team operates. Results are synthesized by a coordinator agent.

### Decision 6: Scheduling Mechanism

**Options Considered:**
1. System cron/launchd
2. Claude Code hooks only
3. Node.js cron library (node-cron)

**Chosen:** Node.js cron library

**Rationale:** Self-contained within the MCP server process, no external system configuration required. Market-hours awareness built-in. Triggers can be configured via YAML files.

### Decision 7: Technical Analysis Indicators

**Options Considered:**
1. Minimal (MA, RSI only)
2. Core Set (RSI, MACD, MAs, Bollinger, Volume)
3. Comprehensive (add Fibonacci, Ichimoku, etc.)

**Chosen:** Core Set

**Rationale:** Covers 90% of use cases for growth equity evaluation. RSI for momentum, MACD for trend confirmation, Moving Averages for support/resistance, Bollinger Bands for volatility, Volume for confirmation. Can be extended later.

### Decision 8: Dashboard Update Mechanism

**Options Considered:**
1. WebSocket real-time streaming
2. Polling
3. Manual refresh

**Chosen:** Polling

**Rationale:** Simpler implementation, sufficient for most use cases since market data doesn't change sub-second. Configurable poll interval (default: 30 seconds during market hours).

## Implementation

> ⚠️ **IMPLEMENTATION WARNING: Legacy Examples Below**
>
> The code examples in Phase 1-4 sections below contain **legacy patterns** that predate the contract enforcement rules. Many snippets show `server.tool(...)` calls and `return ok(...)` patterns which are NOW considered **SPEC BUGS** per the "Plan Consistency Guarantee" section.
>
> **When implementing, ALWAYS use the canonical pattern from "Correct, Copy/Paste-Safe Example" section:**
> - Import `registerTool` from `utils/tool-wrapper.js` (never use `server.tool()` directly)
> - Handler returns plain domain data (never `ok()`, `fail()`, or `{ content: [...] }`)
> - Tool calls a service (never direct DB/API access)
>
> The examples below show **what functionality to build**, not **how to structure the code**.

### Phase 1: Foundation - MCP Server Core

**Duration Estimate:** Foundation layer

#### Step 1.1: Project Structure Setup

**Description:** Initialize the Plutus project with proper structure for hybrid MCP server + Plugin architecture.

**Files to create:**
```
Plutus/
├── .claude-plugin/
│   └── plugin.json              # Plugin manifest
├── mcp-server/
│   ├── package.json
│   ├── tsconfig.json
│   ├── src/
│   │   ├── entrypoints/
│   │   │   ├── stdio.ts          # MCP stdio entry point (MCP only)
│   │   │   └── daemon.ts         # Long-running daemon (HTTP + scheduler)
│   │   ├── server.ts            # McpServer setup
│   │   ├── tools/               # MCP tool adapters (thin wrappers)
│   │   │   ├── index.ts
│   │   │   ├── finance/         # Migrated from Dexter
│   │   │   ├── portfolio/       # Portfolio tools
│   │   │   ├── analysis/        # Analysis tools
│   │   │   └── alerts/          # Alert tools
│   │   ├── domain/              # Pure business logic (no I/O)
│   │   │   ├── portfolio/       # Ledger computations, P&L, lots
│   │   │   ├── indicators/      # Technical indicator calculations
│   │   │   └── risk/            # Risk metrics (beta, HHI, etc.)
│   │   ├── services/            # Use domain + DAL, no MCP concerns
│   │   │   ├── portfolio.ts     # Portfolio state derivation
│   │   │   ├── valuation.ts     # DCF, peer comparison
│   │   │   └── alerts.ts        # Alert evaluation
│   │   ├── data/                # Data Access Layer (DAL)
│   │   │   ├── market-data-client.ts  # Cached, rate-limited data access
│   │   │   └── providers/             # Provider implementations
│   │   ├── storage/
│   │   │   ├── sqlite.ts        # SQLite connection
│   │   │   ├── config.ts        # YAML config loader
│   │   │   └── embeddings.ts    # Xenova/transformers
│   │   ├── scheduler/
│   │   │   └── cron.ts          # node-cron setup
│   │   └── types/
│   │       └── index.ts
│   └── scripts/
│       └── setup-db.ts          # Database initialization
├── dashboard/
│   ├── package.json
│   ├── vite.config.ts
│   ├── src/
│   │   ├── App.tsx
│   │   ├── components/
│   │   ├── hooks/
│   │   └── api/
│   └── index.html
├── commands/                     # Claude Code slash commands
├── agents/                       # Claude Code subagents
├── skills/                       # Claude Code skills
├── hooks/
│   └── hooks.json
├── .mcp.json                     # MCP server config for plugin
├── config/
│   ├── portfolio.yaml           # SETTINGS ONLY (holdings live in SQLite ledger)
│   ├── watchlist.yaml           # Watchlist stocks
│   ├── alerts.yaml              # Alert rules
│   └── theses/                  # Investment theses (markdown)
└── data/
    └── plutus.db                # SQLite database
```

**Implementation details:**
```json
// .claude-plugin/plugin.json
{
  "name": "plutus",
  "version": "1.0.0",
  "description": "Financial research platform for portfolio monitoring and stock evaluation",
  "author": {
    "name": "Plutus Team"
  },
  "keywords": ["finance", "portfolio", "stocks", "analysis"]
}
```

```json
// .mcp.json
{
  "mcpServers": {
    "plutus": {
      "command": "bun",
      "args": ["run", "${CLAUDE_PLUGIN_ROOT}/mcp-server/src/entrypoints/stdio.ts"],
      "env": {
        "FINANCIAL_DATASETS_API_KEY": "${FINANCIAL_DATASETS_API_KEY}",
        "TAVILY_API_KEY": "${TAVILY_API_KEY}",
        "PLUTUS_DATA_DIR": "${CLAUDE_PLUGIN_ROOT}/data",
        "PLUTUS_CONFIG_DIR": "${CLAUDE_PLUGIN_ROOT}/config"
      }
    }
  }
}
```

**Daemon start (HTTP + cron):**
- Started by `/dashboard` command (and optionally by a SessionStart hook).
- Runs independently from MCP stdio process.

**Dependencies:** None

---

#### Step 1.2: Migrate Financial Tools to MCP (→ Canonical Pattern Only)

**Description:** Port all 18 existing Dexter financial tools to MCP format using @modelcontextprotocol/sdk.

Replace legacy `server.tool(...)` snippets in this document with the canonical `registerTool(...)` pattern
to prevent accidental copy/paste of non-compliant code.

**Files to create:**
- `mcp-server/src/tools/finance/api.ts` - API client (from Dexter)
- `mcp-server/src/tools/finance/prices.ts` - Price tools
- `mcp-server/src/tools/finance/fundamentals.ts` - Financial statements
- `mcp-server/src/tools/finance/metrics.ts` - Financial metrics
- `mcp-server/src/tools/finance/filings.ts` - SEC filings
- `mcp-server/src/tools/finance/news.ts` - News tool
- `mcp-server/src/tools/finance/estimates.ts` - Analyst estimates
- `mcp-server/src/tools/finance/insider-trades.ts` - Insider trades
- `mcp-server/src/tools/finance/segments.ts` - Revenue segments
- `mcp-server/src/tools/finance/crypto.ts` - Crypto tools
- `mcp-server/src/tools/finance/financial-search.ts` - Meta router tool

**Implementation details:**
```typescript
// mcp-server/src/server.ts
import { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import { z } from 'zod';
import { registerFinanceTools } from './tools/finance/index.js';
import { registerPortfolioTools } from './tools/portfolio/index.js';
import { registerAnalysisTools } from './tools/analysis/index.js';
import { registerAlertTools } from './tools/alerts/index.js';

const server = new McpServer({
  name: 'plutus',
  version: '1.0.0',
});

// Register all tool categories
registerFinanceTools(server);
registerPortfolioTools(server);
registerAnalysisTools(server);
registerAlertTools(server);

// Start server
const transport = new StdioServerTransport();
await server.connect(transport);
```

```typescript
// mcp-server/src/tools/finance/prices.ts (example tool migration)
import { z } from 'zod';
import type { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { callApi } from './api.js';

export function registerPriceTools(server: McpServer) {
  server.tool(
    'get_price_snapshot',
    'Get current price snapshot for a stock ticker',
    {
      ticker: z.string().describe('Stock ticker symbol (e.g., AAPL, MSFT)'),
    },
    async ({ ticker }) => {
      const response = await callApi('/prices/snapshot', { ticker });
      return {
        content: [{ type: 'text', text: JSON.stringify(response.data, null, 2) }],
      };
    }
  );

  server.tool(
    'get_prices',
    'Get historical price data for a stock ticker',
    {
      ticker: z.string().describe('Stock ticker symbol'),
      start_date: z.string().optional().describe('Start date (YYYY-MM-DD)'),
      end_date: z.string().optional().describe('End date (YYYY-MM-DD)'),
      interval: z.enum(['day', 'week', 'month']).optional().describe('Price interval'),
    },
    async ({ ticker, start_date, end_date, interval }) => {
      const response = await callApi('/prices', { ticker, start_date, end_date, interval });
      return {
        content: [{ type: 'text', text: JSON.stringify(response.data, null, 2) }],
      };
    }
  );
}
```

**Dependencies:** Step 1.1

---

#### Step 1.3: Storage Layer Setup

**Description:** Implement hybrid storage with YAML config files and SQLite database.

**Files to create:**
- `mcp-server/src/storage/sqlite.ts` - SQLite connection and schema
- `mcp-server/src/storage/config.ts` - YAML config loader/writer
- `mcp-server/src/storage/migrations/001-initial.sql` - Initial schema
- `mcp-server/scripts/setup-db.ts` - Database initialization script

**Implementation details:**
```typescript
// mcp-server/src/storage/sqlite.ts
import Database from 'better-sqlite3';
import path from 'path';

const DB_PATH = process.env.PLUTUS_DATA_DIR
  ? path.join(process.env.PLUTUS_DATA_DIR, 'plutus.db')
  : './data/plutus.db';

export const db = new Database(DB_PATH);

// Initialize schema
db.exec(`
  -- Price history cache
  CREATE TABLE IF NOT EXISTS price_history (
    id INTEGER PRIMARY KEY,
    ticker TEXT NOT NULL,
    date TEXT NOT NULL,
    open REAL,
    high REAL,
    low REAL,
    close REAL,
    volume INTEGER,
    UNIQUE(ticker, date)
  );

  -- Corporate actions for correctness (splits, symbol changes, etc.)
  CREATE TABLE IF NOT EXISTS corporate_actions (
    id INTEGER PRIMARY KEY,
    ticker TEXT NOT NULL,
    action_type TEXT NOT NULL,     -- SPLIT | SYMBOL_CHANGE | DIVIDEND | SPINOFF
    effective_date TEXT NOT NULL,
    ratio REAL,                    -- e.g., 10-for-1 => 10.0
    old_ticker TEXT,
    new_ticker TEXT,
    meta_json TEXT
  );

  CREATE INDEX IF NOT EXISTS idx_corp_actions_ticker_date ON corporate_actions(ticker, effective_date);

  -- Corporate action job/state tracking for idempotent apply
  CREATE TABLE IF NOT EXISTS corporate_action_jobs (
    id INTEGER PRIMARY KEY,
    ticker TEXT NOT NULL,
    as_of TEXT NOT NULL,
    provider TEXT NOT NULL,
    status TEXT NOT NULL,
    last_run_at TEXT,
    last_action_id_seen TEXT,
    UNIQUE(ticker, as_of, provider)
  );

  -- Portfolio ledger (immutable events) - source of truth for holdings
  CREATE TABLE IF NOT EXISTS portfolio_events (
    id INTEGER PRIMARY KEY,
    event_id TEXT NOT NULL UNIQUE,          -- UUID for stable references
    idempotency_key TEXT UNIQUE,            -- optional, for safe repeated imports
    event_version INTEGER NOT NULL DEFAULT 1,
    source TEXT NOT NULL DEFAULT 'manual',  -- manual | broker_csv | corporate_actions | system
    external_ref TEXT,                      -- broker trade id / row hash / etc.
    timestamp TEXT NOT NULL,
    type TEXT NOT NULL,                     -- BUY | SELL | DIVIDEND | SPLIT | CASH_ADJUST | FEES | TRANSFER | NOTE
    ticker TEXT,
    shares REAL,
    price REAL,
    fees REAL DEFAULT 0,
    cash_delta REAL DEFAULT 0,
    currency TEXT DEFAULT 'USD',
    meta_json TEXT NOT NULL DEFAULT '{}'
  );

  CREATE INDEX IF NOT EXISTS idx_portfolio_events_time ON portfolio_events(timestamp);
  CREATE INDEX IF NOT EXISTS idx_portfolio_events_ticker ON portfolio_events(ticker);
  CREATE INDEX IF NOT EXISTS idx_portfolio_events_source ON portfolio_events(source);
  CREATE INDEX IF NOT EXISTS idx_portfolio_events_idempotency ON portfolio_events(idempotency_key);

  -- Minimal invariants (SQLite CHECK via trigger)
  -- Note: keep logic simple; complex validation still in domain layer.
  CREATE TRIGGER IF NOT EXISTS trg_portfolio_events_validate
  BEFORE INSERT ON portfolio_events
  BEGIN
    SELECT
      CASE
        WHEN NEW.type IN ('BUY','SELL') AND (NEW.ticker IS NULL OR NEW.shares IS NULL OR NEW.price IS NULL) THEN
          RAISE(ABORT, 'BUY/SELL require ticker, shares, price')
        WHEN NEW.type IN ('SPLIT') AND (NEW.ticker IS NULL OR NEW.shares IS NULL) THEN
          RAISE(ABORT, 'SPLIT requires ticker and shares (ratio encoded in meta)')
        WHEN NEW.type IN ('DIVIDEND') AND (NEW.ticker IS NULL OR NEW.cash_delta IS NULL) THEN
          RAISE(ABORT, 'DIVIDEND requires ticker and cash_delta')
        ELSE NULL
      END;
  END;

  -- Ledger Invariants (enforced in code + unit tests):
  -- - For BUY/SELL/DIVIDEND/SPLIT: ticker required
  -- - For BUY/SELL/SPLIT: shares required
  -- - For BUY/SELL: price required
  -- - Disallow negative shares except via SPLIT ratio or explicit adjustments

  -- Portfolio snapshots for performance tracking
  CREATE TABLE IF NOT EXISTS portfolio_snapshots (
    id INTEGER PRIMARY KEY,
    timestamp TEXT NOT NULL,
    total_value REAL NOT NULL,
    cash REAL NOT NULL,
    holdings_json TEXT NOT NULL
  );

  -- Investment thesis embeddings (with model versioning for safe comparisons)
  CREATE TABLE IF NOT EXISTS thesis_embeddings (
    id INTEGER PRIMARY KEY,
    ticker TEXT NOT NULL,
    thesis_hash TEXT NOT NULL,
    embedding BLOB NOT NULL,           -- exactly embedding.byteLength bytes
    model_id TEXT NOT NULL DEFAULT 'all-MiniLM-L6-v2',  -- model identifier
    dims INTEGER NOT NULL DEFAULT 384, -- embedding dimensions (for validation)
    normalized INTEGER NOT NULL DEFAULT 1, -- 1 if L2-normalized
    created_at TEXT NOT NULL,
    UNIQUE(ticker, thesis_hash, model_id)
  );

  -- Only compare embeddings with same model_id/dims
  CREATE INDEX IF NOT EXISTS idx_thesis_model ON thesis_embeddings(model_id, dims);

  -- Alert history
  CREATE TABLE IF NOT EXISTS alert_history (
    id INTEGER PRIMARY KEY,
    alert_id TEXT NOT NULL,
    ticker TEXT,
    triggered_at TEXT NOT NULL,
    condition TEXT NOT NULL,
    value REAL,
    message TEXT,
    dedupe_key TEXT,                 -- e.g., news_id or hash(title+date)
    UNIQUE(alert_id, dedupe_key)     -- prevents repeat triggers
  );

  -- Alert evaluation state (incremental checks)
  CREATE TABLE IF NOT EXISTS alert_state (
    alert_id TEXT PRIMARY KEY,
    last_checked_at TEXT,
    last_triggered_at TEXT,
    acknowledged_at TEXT
  );

  -- Technical indicator cache
  CREATE TABLE IF NOT EXISTS indicator_cache (
    id INTEGER PRIMARY KEY,
    ticker TEXT NOT NULL,
    indicator TEXT NOT NULL,
    date TEXT NOT NULL,
    value REAL,
    params_json TEXT,
    UNIQUE(ticker, indicator, date, params_json)
  );

  -- Scoring runs (reproducibility)
  CREATE TABLE IF NOT EXISTS score_runs (
    id INTEGER PRIMARY KEY,
    ticker TEXT NOT NULL,
    as_of TEXT NOT NULL,
    rubric_name TEXT NOT NULL,
    rubric_hash TEXT NOT NULL,
    total_score REAL NOT NULL,
    breakdown_json TEXT NOT NULL,
    inputs_json TEXT NOT NULL,         -- minimally: key metrics used + provider as_of
    created_at TEXT NOT NULL,
    UNIQUE(ticker, as_of, rubric_hash)
  );

  CREATE INDEX IF NOT EXISTS idx_price_ticker_date ON price_history(ticker, date);
  CREATE INDEX IF NOT EXISTS idx_thesis_ticker ON thesis_embeddings(ticker);
  CREATE INDEX IF NOT EXISTS idx_snapshot_timestamp ON portfolio_snapshots(timestamp);
`);
```

```typescript
// mcp-server/src/storage/config.ts
import fs from 'fs';
import path from 'path';
import yaml from 'js-yaml';

const CONFIG_DIR = process.env.PLUTUS_CONFIG_DIR || './config';

// SETTINGS ONLY - holdings/cash are derived from portfolio_events ledger
export interface PortfolioConfig {
  name: string;
  base_currency: string;        // e.g., 'USD'
  benchmark: string;            // e.g., 'SPY'
  tax_lot_method: 'FIFO' | 'LIFO' | 'SPECIFIC_ID';
  risk_limits?: {
    max_position_weight_pct?: number;
    max_sector_weight_pct?: number;
    max_portfolio_beta?: number;
    max_drawdown_alert_pct?: number;
  };
  // Legacy: for one-time import via portfolio_import_yaml
  initial_holdings?: Array<{
    ticker: string;
    shares: number;
    cost_basis: number;
    purchase_date: string;
  }>;
}

export interface WatchlistConfig {
  stocks: Array<{
    ticker: string;
    notes?: string;
    target_price?: number;
    added_date: string;
  }>;
}

export interface AlertConfig {
  alerts: Array<{
    id: string;
    ticker: string;
    type: 'price_above' | 'price_below' | 'pct_change' | 'news_keyword';
    value: number | string;
    enabled: boolean;
    cooldown_minutes?: number;
    dedupe?: 'by_news_id' | 'by_title_hash';
  }>;
}

export function loadConfig<T>(filename: string): T {
  const filepath = path.join(CONFIG_DIR, filename);
  if (!fs.existsSync(filepath)) {
    return {} as T;
  }
  const content = fs.readFileSync(filepath, 'utf-8');
  return yaml.load(content) as T;
}

export function saveConfig<T>(filename: string, data: T): void {
  const filepath = path.join(CONFIG_DIR, filename);
  fs.mkdirSync(path.dirname(filepath), { recursive: true });
  fs.writeFileSync(filepath, yaml.dump(data, { indent: 2 }));
}

export const portfolio = {
  load: () => loadConfig<PortfolioConfig>('portfolio.yaml'),
  save: (data: PortfolioConfig) => saveConfig('portfolio.yaml', data),
};

export const watchlist = {
  load: () => loadConfig<WatchlistConfig>('watchlist.yaml'),
  save: (data: WatchlistConfig) => saveConfig('watchlist.yaml', data),
};

export const alerts = {
  load: () => loadConfig<AlertConfig>('alerts.yaml'),
  save: (data: AlertConfig) => saveConfig('alerts.yaml', data),
};
```

**Dependencies:** Step 1.1

---

### Phase 2: Portfolio Management Tools

#### Step 2.1: Portfolio Ledger Tools (Event-Sourced → Use Canonical Pattern)

**Description:** MCP tools for appending immutable portfolio events and deriving holdings/lot views.

**Non-negotiable:** YAML does NOT store holdings. YAML stores settings only. The SQLite `portfolio_events` table is the sole source of truth.

**Files to create:**
- `mcp-server/src/tools/portfolio/ledger.ts` - append/query immutable events
- `mcp-server/src/tools/portfolio/holdings.ts` - derived holdings + P&L
- `mcp-server/src/tools/portfolio/lots.ts` - tax lots (FIFO/LIFO/SPECIFIC_ID)
- `mcp-server/src/tools/portfolio/reconcile.ts` - broker/import reconciliation
- `mcp-server/src/tools/portfolio/watchlist.ts` - Watchlist management
- `mcp-server/src/tools/portfolio/value.ts` - Portfolio valuation

**Implementation details:**
```typescript
// mcp-server/src/tools/portfolio/ledger.ts
import { z } from 'zod';
import type { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { db } from '../../storage/sqlite.js';
import { ok, fail } from '../../utils/response.js';

const EventType = z.enum(['BUY', 'SELL', 'DIVIDEND', 'SPLIT', 'CASH_ADJUST', 'FEES', 'TRANSFER', 'NOTE']);

export function registerLedgerTools(server: McpServer) {
  server.tool(
    'portfolio_add_event',
    'Append an immutable portfolio ledger event (BUY/SELL/DIVIDEND/SPLIT/CASH/FEES/NOTE)',
    {
      type: EventType.describe('Event type'),
      ticker: z.string().optional().describe('Stock ticker (required for BUY/SELL/DIVIDEND/SPLIT)'),
      shares: z.number().optional().describe('Number of shares'),
      price: z.number().optional().describe('Price per share'),
      fees: z.number().optional().describe('Transaction fees'),
      cash_delta: z.number().optional().describe('Cash change (for CASH_ADJUST)'),
      note: z.string().optional().describe('Optional note or memo'),
      timestamp: z.string().optional().describe('ISO timestamp (defaults to now)'),
    },
    async (input) => {
      const startTime = Date.now();
      const ts = input.timestamp || new Date().toISOString();

      db.prepare(`
        INSERT INTO portfolio_events (timestamp, type, ticker, shares, price, fees, cash_delta, meta_json)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?)
      `).run(ts, input.type, input.ticker?.toUpperCase(), input.shares, input.price, input.fees, input.cash_delta, JSON.stringify({ note: input.note }));

      return ok('portfolio_add_event', { message: `Recorded ${input.type} event`, timestamp: ts }, { duration_ms: Date.now() - startTime });
    }
  );

// mcp-server/src/tools/portfolio/holdings.ts
// Derived view from ledger - NEVER mutates holdings directly
import { db } from '../../storage/sqlite.js';
import { getPriceSnapshot } from '../finance/prices.js';
import { ok, fail } from '../../utils/response.js';

export function registerHoldingsTools(server: McpServer) {
  server.tool(
    'portfolio_get_holdings',
    'Derived view of current positions computed from the event ledger',
    {
      as_of: z.string().optional().describe('Point-in-time view (ISO date, default: now)'),
      include_lots: z.boolean().optional().describe('Include individual tax lots'),
    },
    async ({ as_of, include_lots }) => {
      const startTime = Date.now();
      const cutoff = as_of || new Date().toISOString();

      // Aggregate events into positions (respecting corporate actions)
      const events = db.prepare(`
        SELECT * FROM portfolio_events
        WHERE timestamp <= ?
        ORDER BY timestamp ASC
      `).all(cutoff);

      // Compute holdings from event stream
      const positions = computePositionsFromEvents(events);

      // Enrich with current prices
      const enriched = await Promise.all(
        Object.values(positions).map(async (pos: any) => {
          try {
            const price = await getPriceSnapshot(pos.ticker);
            const current_value = pos.shares * price.close;
            const gain_loss = current_value - pos.cost_basis;
            return {
              ...pos,
              current_price: price.close,
              current_value,
              unrealized_gain_loss: gain_loss,
              unrealized_gain_loss_pct: ((gain_loss / pos.cost_basis) * 100).toFixed(2) + '%',
              lots: include_lots ? pos.lots : undefined,
            };
          } catch {
            return { ...pos, error: 'Failed to fetch price' };
          }
        })
      );

      return ok('portfolio_get_holdings', { holdings: enriched, as_of: cutoff }, { duration_ms: Date.now() - startTime });
    }
  );

  server.tool(
    'portfolio_get_lots',
    'Get tax lots for a ticker (for FIFO/LIFO/SPECIFIC_ID cost basis)',
    {
      ticker: z.string().describe('Stock ticker symbol'),
    },
    async ({ ticker }) => {
      const startTime = Date.now();
      const events = db.prepare(`
        SELECT * FROM portfolio_events
        WHERE ticker = ? AND type IN ('BUY', 'SELL', 'SPLIT')
        ORDER BY timestamp ASC
      `).all(ticker.toUpperCase());

      const lots = computeLotsFromEvents(events);
      return ok('portfolio_get_lots', { ticker, lots }, { duration_ms: Date.now() - startTime });
    }
  );

  server.tool(
    'portfolio_summary',
    'Get portfolio summary with total value, P&L, and allocation breakdown',
    { as_of: z.string().optional().describe('Point-in-time view (ISO date)') },
    async ({ as_of }) => {
      const startTime = Date.now();
      const cutoff = as_of || new Date().toISOString();

      // CRITICAL: Derive holdings + cash from ledger, NEVER from YAML
      const { holdings, cash, totalCost } = computePortfolioStateFromLedger(cutoff);

      let totalValue = cash;
      const positions = [];

      for (const h of holdings) {
        try {
          const price = await getPriceSnapshot(h.ticker);
          const value = h.shares * price.close;
          totalValue += value;
          positions.push({
            ticker: h.ticker,
            shares: h.shares,
            cost_basis: h.cost_basis,
            current_price: price.close,
            value,
            weight: 0, // Will calculate after total
          });
        } catch {
          // Skip failed tickers
        }
      }

      // Calculate weights
      for (const p of positions) {
        p.weight = ((p.value / totalValue) * 100).toFixed(2) + '%';
      }

      const summary = {
        as_of: cutoff,
        total_value: totalValue.toFixed(2),
        total_cost: totalCost.toFixed(2),
        total_gain_loss: (totalValue - totalCost).toFixed(2),
        total_return_pct: (((totalValue - totalCost) / totalCost) * 100).toFixed(2) + '%',
        cash: cash.toFixed(2),
        positions: positions.sort((a, b) => b.value - a.value),
      };

      return ok('portfolio_summary', summary, { duration_ms: Date.now() - startTime });
    }
  );
}
```

**Dependencies:** Step 1.2, Step 1.3

---

#### Step 2.2: Investment Thesis Tools with Embeddings

**Description:** Tools for creating, storing, and semantically searching investment theses.

**Files to create:**
- `mcp-server/src/storage/embeddings.ts` - Xenova/transformers integration
- `mcp-server/src/tools/portfolio/thesis.ts` - Thesis CRUD and search

**Implementation details:**
```typescript
// mcp-server/src/storage/embeddings.ts
import { pipeline, env } from '@xenova/transformers';
import { db } from './sqlite.js';
import crypto from 'crypto';

// Configure Xenova for local model caching
env.cacheDir = process.env.PLUTUS_DATA_DIR || './data';
env.localModelPath = env.cacheDir + '/models';

let embedder: any = null;

async function getEmbedder() {
  if (!embedder) {
    embedder = await pipeline('feature-extraction', 'Xenova/all-MiniLM-L6-v2');
  }
  return embedder;
}

export async function generateEmbedding(text: string): Promise<Float32Array> {
  const embed = await getEmbedder();
  const output = await embed(text, { pooling: 'mean', normalize: true });
  return output.data as Float32Array;
}

const EMBEDDING_MODEL_ID = 'all-MiniLM-L6-v2';
const EMBEDDING_DIMS = 384;

export async function storeThesisEmbedding(
  ticker: string,
  thesisContent: string
): Promise<void> {
  const hash = crypto.createHash('md5').update(thesisContent).digest('hex');
  const embedding = await generateEmbedding(thesisContent);

  // CORRECT: handle Float32Array view offset properly
  const buffer = Buffer.from(
    embedding.buffer,
    embedding.byteOffset,
    embedding.byteLength
  );

  db.prepare(`
    INSERT OR REPLACE INTO thesis_embeddings
    (ticker, thesis_hash, embedding, model_id, dims, normalized, created_at)
    VALUES (?, ?, ?, ?, ?, ?, ?)
  `).run(ticker, hash, buffer, EMBEDDING_MODEL_ID, EMBEDDING_DIMS, 1, new Date().toISOString());
}

export async function searchTheses(
  query: string,
  limit: number = 5
): Promise<Array<{ ticker: string; similarity: number }>> {
  const queryEmbedding = await generateEmbedding(query);

  // Only compare embeddings from same model/dimensions
  const rows = db.prepare(`
    SELECT ticker, embedding, dims FROM thesis_embeddings
    WHERE model_id = ? AND dims = ?
  `).all(EMBEDDING_MODEL_ID, EMBEDDING_DIMS) as Array<{ ticker: string; embedding: Buffer; dims: number }>;

  const results = rows.map((row) => {
    // CORRECT: create Float32Array from Buffer with proper byte handling
    const storedEmbedding = new Float32Array(
      row.embedding.buffer.slice(
        row.embedding.byteOffset,
        row.embedding.byteOffset + row.embedding.byteLength
      )
    );
    const similarity = cosineSimilarity(queryEmbedding, storedEmbedding);
    return { ticker: row.ticker, similarity };
  });

  return results
    .sort((a, b) => b.similarity - a.similarity)
    .slice(0, limit);
}

function cosineSimilarity(a: Float32Array, b: Float32Array): number {
  let dot = 0, normA = 0, normB = 0;
  for (let i = 0; i < a.length; i++) {
    dot += a[i] * b[i];
    normA += a[i] * a[i];
    normB += b[i] * b[i];
  }
  return dot / (Math.sqrt(normA) * Math.sqrt(normB));
}
```

```typescript
// mcp-server/src/tools/portfolio/thesis.ts
import { z } from 'zod';
import type { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import fs from 'fs';
import path from 'path';
import { storeThesisEmbedding, searchTheses } from '../../storage/embeddings.js';

const THESIS_DIR = path.join(process.env.PLUTUS_CONFIG_DIR || './config', 'theses');

export function registerThesisTools(server: McpServer) {
  server.tool(
    'thesis_create',
    'Create or update an investment thesis for a stock',
    {
      ticker: z.string().describe('Stock ticker symbol'),
      thesis: z.string().describe('Full investment thesis in markdown format'),
      bull_case: z.string().optional().describe('Bull case scenario'),
      bear_case: z.string().optional().describe('Bear case scenario'),
      target_price: z.number().optional().describe('Target price'),
      stop_loss: z.number().optional().describe('Stop loss price'),
      catalysts: z.array(z.string()).optional().describe('Expected catalysts'),
    },
    async ({ ticker, thesis, bull_case, bear_case, target_price, stop_loss, catalysts }) => {
      fs.mkdirSync(THESIS_DIR, { recursive: true });

      const content = `# Investment Thesis: ${ticker.toUpperCase()}

> Last Updated: ${new Date().toISOString()}

## Summary

${thesis}

${bull_case ? `## Bull Case\n\n${bull_case}\n` : ''}
${bear_case ? `## Bear Case\n\n${bear_case}\n` : ''}
${target_price ? `## Target Price: $${target_price}\n` : ''}
${stop_loss ? `## Stop Loss: $${stop_loss}\n` : ''}
${catalysts?.length ? `## Catalysts\n\n${catalysts.map(c => `- ${c}`).join('\n')}\n` : ''}
`;

      const filepath = path.join(THESIS_DIR, `${ticker.toUpperCase()}.md`);
      fs.writeFileSync(filepath, content);

      // Generate and store embedding
      await storeThesisEmbedding(ticker.toUpperCase(), thesis);

      return { content: [{ type: 'text', text: `Thesis saved for ${ticker.toUpperCase()}` }] };
    }
  );

  server.tool(
    'thesis_get',
    'Retrieve the investment thesis for a stock',
    {
      ticker: z.string().describe('Stock ticker symbol'),
    },
    async ({ ticker }) => {
      const filepath = path.join(THESIS_DIR, `${ticker.toUpperCase()}.md`);
      if (!fs.existsSync(filepath)) {
        return { content: [{ type: 'text', text: `No thesis found for ${ticker}` }] };
      }
      const content = fs.readFileSync(filepath, 'utf-8');
      return { content: [{ type: 'text', text: content }] };
    }
  );

  server.tool(
    'thesis_search',
    'Semantically search investment theses',
    {
      query: z.string().describe('Search query (natural language)'),
      limit: z.number().optional().describe('Max results (default: 5)'),
    },
    async ({ query, limit }) => {
      const results = await searchTheses(query, limit || 5);
      return { content: [{ type: 'text', text: JSON.stringify(results, null, 2) }] };
    }
  );

  server.tool(
    'thesis_validate',
    'Check if current data supports or contradicts the investment thesis',
    {
      ticker: z.string().describe('Stock ticker to validate thesis against current data'),
    },
    async ({ ticker }) => {
      // This would fetch current financials and compare against thesis expectations
      // Implementation depends on thesis structure
      return { content: [{ type: 'text', text: `Thesis validation for ${ticker} - implementation pending` }] };
    }
  );
}
```

**Dependencies:** Step 1.3, Step 2.1

---

### Phase 3: Analysis Tools

#### Step 3.1: Technical Analysis Tools

**Description:** Implement core technical indicators (RSI, MACD, Moving Averages, Bollinger Bands, Volume Analysis).

**Files to create:**
- `mcp-server/src/tools/analysis/technical.ts` - Technical indicator calculations
- `mcp-server/src/tools/analysis/indicators/` - Individual indicator implementations

**Implementation details:**
```typescript
// mcp-server/src/tools/analysis/technical.ts
import { z } from 'zod';
import type { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { getPrices } from '../finance/prices.js';

// RSI calculation (Wilder's smoothed RSI)
// NOTE: Expects prices in chronological order (oldest first)
function calculateRSI(prices: number[], period: number = 14): number {
  if (prices.length < period + 1) return NaN;

  // Calculate initial average gain/loss from the most recent 'period' changes
  let avgGain = 0, avgLoss = 0;
  const startIdx = prices.length - period - 1;

  for (let i = startIdx + 1; i <= startIdx + period; i++) {
    const change = prices[i] - prices[i - 1];
    if (change > 0) avgGain += change;
    else avgLoss -= change;
  }
  avgGain /= period;
  avgLoss /= period;

  // Apply Wilder's smoothing for remaining prices
  for (let i = startIdx + period + 1; i < prices.length; i++) {
    const change = prices[i] - prices[i - 1];
    const gain = change > 0 ? change : 0;
    const loss = change < 0 ? -change : 0;
    avgGain = (avgGain * (period - 1) + gain) / period;
    avgLoss = (avgLoss * (period - 1) + loss) / period;
  }

  if (avgLoss === 0) return 100;
  const rs = avgGain / avgLoss;
  return 100 - (100 / (1 + rs));
}

// SMA calculation (most recent `period` values; prices are chronological - oldest first)
function calculateSMA(prices: number[], period: number): number {
  if (prices.length < period) return NaN;
  const slice = prices.slice(-period);  // Use LAST N elements, not first N
  return slice.reduce((a, b) => a + b, 0) / period;
}

// EMA calculation
// EMA calculation - MUST iterate forward in time (prices are chronological: oldest first)
function calculateEMA(prices: number[], period: number): number {
  if (prices.length < period) return NaN;
  const multiplier = 2 / (period + 1);
  // Initial EMA is SMA of first `period` values
  let ema = prices.slice(0, period).reduce((a, b) => a + b, 0) / period;
  // Iterate forward from period to end, applying EMA formula
  for (let i = period; i < prices.length; i++) {
    ema = (prices[i] - ema) * multiplier + ema;
  }
  return ema;
}

// MACD calculation with proper signal line (9-period EMA of MACD)
// NOTE: Expects prices in chronological order (oldest first)
function calculateMACD(prices: number[]): { macd: number; signal: number; histogram: number } {
  if (prices.length < 35) { // Need enough data for 26-EMA + 9-signal
    return { macd: NaN, signal: NaN, histogram: NaN };
  }

  // Calculate MACD line for all points to build signal EMA
  const macdHistory: number[] = [];
  for (let i = 25; i < prices.length; i++) {
    const slice = prices.slice(0, i + 1);
    const ema12 = calculateEMA(slice, 12);
    const ema26 = calculateEMA(slice, 26);
    macdHistory.push(ema12 - ema26);
  }

  const macd = macdHistory[macdHistory.length - 1];

  // Signal line is 9-period EMA of MACD values
  let signal: number;
  if (macdHistory.length >= 9) {
    const signalMultiplier = 2 / (9 + 1);
    signal = macdHistory.slice(0, 9).reduce((a, b) => a + b, 0) / 9; // Initial SMA
    for (let i = 9; i < macdHistory.length; i++) {
      signal = (macdHistory[i] - signal) * signalMultiplier + signal;
    }
  } else {
    signal = macd; // Fallback if insufficient history
  }

  return { macd, signal, histogram: macd - signal };
}

// Bollinger Bands (uses most recent `period` values)
function calculateBollingerBands(prices: number[], period: number = 20, stdDev: number = 2):
  { upper: number; middle: number; lower: number } {
  const sma = calculateSMA(prices, period);
  const slice = prices.slice(-period);  // Use LAST N elements, not first N
  const variance = slice.reduce((sum, p) => sum + Math.pow(p - sma, 2), 0) / period;
  const std = Math.sqrt(variance);
  return {
    upper: sma + stdDev * std,
    middle: sma,
    lower: sma - stdDev * std,
  };
}

export function registerTechnicalTools(server: McpServer) {
  server.tool(
    'technical_analysis',
    'Get comprehensive technical analysis for a stock',
    {
      ticker: z.string().describe('Stock ticker symbol'),
      period_days: z.number().optional().describe('Lookback period in days (default: 90)'),
    },
    async ({ ticker, period_days }) => {
      const days = period_days || 90;
      const endDate = new Date().toISOString().split('T')[0];
      const startDate = new Date(Date.now() - days * 24 * 60 * 60 * 1000).toISOString().split('T')[0];

      const priceData = await getPrices(ticker, startDate, endDate);
      // Keep chronological order (oldest first) for indicator calculations
      const closes = priceData.map((p: any) => p.close);
      const volumes = priceData.map((p: any) => p.volume);

      // Current price is the most recent (last element in chronological order)
      const currentPrice = closes[closes.length - 1];
      const rsi = calculateRSI(closes);
      const sma20 = calculateSMA(closes, 20);
      const sma50 = calculateSMA(closes, 50);
      const ema12 = calculateEMA(closes, 12);
      const ema26 = calculateEMA(closes, 26);
      const macd = calculateMACD(closes);
      const bollinger = calculateBollingerBands(closes);
      // Use most recent 20 days for average volume (chronological, so slice from end)
      const recentVolumes = volumes.slice(-20);
      const avgVolume = recentVolumes.reduce((a: number, b: number) => a + b, 0) / recentVolumes.length;
      const currentVolume = volumes[volumes.length - 1];

      const analysis = {
        ticker: ticker.toUpperCase(),
        current_price: currentPrice,
        indicators: {
          rsi: { value: rsi.toFixed(2), signal: rsi > 70 ? 'OVERBOUGHT' : rsi < 30 ? 'OVERSOLD' : 'NEUTRAL' },
          macd: {
            value: macd.macd.toFixed(4),
            signal: macd.signal.toFixed(4),
            histogram: macd.histogram.toFixed(4),
            trend: macd.histogram > 0 ? 'BULLISH' : 'BEARISH'
          },
          moving_averages: {
            sma20: sma20.toFixed(2),
            sma50: sma50.toFixed(2),
            ema12: ema12.toFixed(2),
            ema26: ema26.toFixed(2),
            price_vs_sma20: currentPrice > sma20 ? 'ABOVE' : 'BELOW',
            price_vs_sma50: currentPrice > sma50 ? 'ABOVE' : 'BELOW',
          },
          bollinger_bands: {
            upper: bollinger.upper.toFixed(2),
            middle: bollinger.middle.toFixed(2),
            lower: bollinger.lower.toFixed(2),
            position: currentPrice > bollinger.upper ? 'ABOVE_UPPER' :
                      currentPrice < bollinger.lower ? 'BELOW_LOWER' : 'WITHIN_BANDS',
          },
          volume: {
            current: currentVolume,
            avg_20day: avgVolume.toFixed(0),
            volume_ratio: (currentVolume / avgVolume).toFixed(2),
          },
        },
        summary: generateTASummary(rsi, macd, currentPrice, sma20, sma50, bollinger),
      };

      return { content: [{ type: 'text', text: JSON.stringify(analysis, null, 2) }] };
    }
  );
}

function generateTASummary(
  rsi: number,
  macd: { macd: number; histogram: number },
  price: number,
  sma20: number,
  sma50: number,
  bollinger: { upper: number; lower: number }
): string {
  const signals = [];

  if (rsi > 70) signals.push('RSI indicates overbought conditions');
  else if (rsi < 30) signals.push('RSI indicates oversold conditions');

  if (macd.histogram > 0) signals.push('MACD histogram positive (bullish momentum)');
  else signals.push('MACD histogram negative (bearish momentum)');

  if (price > sma20 && price > sma50) signals.push('Price above key moving averages (bullish)');
  else if (price < sma20 && price < sma50) signals.push('Price below key moving averages (bearish)');

  if (price > bollinger.upper) signals.push('Price above upper Bollinger Band (potential reversal)');
  else if (price < bollinger.lower) signals.push('Price below lower Bollinger Band (potential bounce)');

  return signals.join('. ') + '.';
}
```

**Required: Indicator Correctness Tests**
Add `mcp-server/tests/technical.indicators.test.ts` with:
- SMA/EMA correctness on small known sequences (e.g., [1,2,3,4,5] with period 3)
- Bollinger bands on constant series (verify upper === middle === lower)
- MACD known-value regression (golden test against reference implementation)
- RSI boundary conditions (all gains → 100, all losses → 0)

These tests are **mandatory** before technical_analysis tool is considered production-ready.

**Dependencies:** Step 1.2

---

#### Step 3.2: Risk Management Tools

**Description:** Portfolio-level risk analytics (beta, sector exposure, concentration, volatility, drawdown).

**Files to create:**
- `mcp-server/src/tools/analysis/risk.ts` - Risk metrics calculations

**Implementation details:**
```typescript
// mcp-server/src/tools/analysis/risk.ts
import { z } from 'zod';
import type { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { getPrices, getPriceSnapshot } from '../finance/prices.js';
import { getFinancialMetricsSnapshot } from '../finance/metrics.js';
import { computePortfolioStateFromLedger } from '../portfolio/state.js';
import { ok, fail } from '../../utils/response.js';

export function registerRiskTools(server: McpServer) {
  server.tool(
    'risk_analysis',
    'Get comprehensive risk analysis for the portfolio',
    { as_of: z.string().optional() },
    async ({ as_of }) => {
      const startTime = Date.now();

      // CRITICAL: Derive from ledger only (invariant)
      const { holdings, cash } = computePortfolioStateFromLedger(as_of || new Date().toISOString());

      if (!holdings.length) {
        return fail('risk_analysis', 'EMPTY_PORTFOLIO', 'No holdings in portfolio', null, { duration_ms: Date.now() - startTime });
      }

      // Calculate portfolio value and weights
      let totalValue = cash;
      const positionData = [];

      for (const h of holdings) {
        try {
          const price = await getPriceSnapshot(h.ticker);
          const metrics = await getFinancialMetricsSnapshot(h.ticker);
          const value = h.shares * price.close;
          totalValue += value;
          positionData.push({
            ticker: h.ticker,
            value,
            beta: metrics.beta || 1,
            sector: metrics.sector || 'Unknown',
          });
        } catch {
          // Skip failed tickers
        }
      }

      // Calculate weights and portfolio beta
      let portfolioBeta = 0;
      const sectorExposure: Record<string, number> = {};
      const positions = [];

      for (const p of positionData) {
        const weight = p.value / totalValue;
        portfolioBeta += weight * p.beta;
        sectorExposure[p.sector] = (sectorExposure[p.sector] || 0) + weight;
        positions.push({
          ticker: p.ticker,
          weight: (weight * 100).toFixed(2) + '%',
          beta: p.beta,
          sector: p.sector,
        });
      }

      // Concentration risk (HHI)
      const weights = positions.map(p => parseFloat(p.weight) / 100);
      const hhi = weights.reduce((sum, w) => sum + w * w, 0);

      // Top position concentration
      const sortedByWeight = [...positions].sort((a, b) =>
        parseFloat(b.weight) - parseFloat(a.weight)
      );
      const top3Weight = sortedByWeight.slice(0, 3)
        .reduce((sum, p) => sum + parseFloat(p.weight), 0);

      const riskAnalysis = {
        portfolio_beta: portfolioBeta.toFixed(2),
        beta_interpretation: portfolioBeta > 1.2 ? 'HIGH_RISK' :
                           portfolioBeta < 0.8 ? 'DEFENSIVE' : 'MARKET_NEUTRAL',
        concentration: {
          hhi: hhi.toFixed(4),
          hhi_interpretation: hhi > 0.25 ? 'HIGHLY_CONCENTRATED' :
                             hhi > 0.15 ? 'MODERATELY_CONCENTRATED' : 'DIVERSIFIED',
          top_3_weight: top3Weight.toFixed(2) + '%',
        },
        sector_exposure: Object.entries(sectorExposure)
          .map(([sector, weight]) => ({ sector, weight: (weight * 100).toFixed(2) + '%' }))
          .sort((a, b) => parseFloat(b.weight) - parseFloat(a.weight)),
        positions: sortedByWeight,
        warnings: generateRiskWarnings(portfolioBeta, hhi, top3Weight, sectorExposure),
      };

      return { content: [{ type: 'text', text: JSON.stringify(riskAnalysis, null, 2) }] };
    }
  );

  server.tool(
    'max_drawdown',
    'Calculate maximum drawdown for the portfolio over a period',
    {
      days: z.number().optional().describe('Lookback period in days (default: 252 = 1 year)'),
    },
    async ({ days }) => {
      // Implementation would track portfolio value over time
      // and calculate max peak-to-trough decline
      return { content: [{ type: 'text', text: 'Max drawdown calculation - requires historical portfolio snapshots' }] };
    }
  );
}

function generateRiskWarnings(
  beta: number,
  hhi: number,
  top3: number,
  sectors: Record<string, number>
): string[] {
  const warnings = [];

  if (beta > 1.3) warnings.push('Portfolio has high market sensitivity (beta > 1.3)');
  if (hhi > 0.25) warnings.push('Portfolio is highly concentrated');
  if (top3 > 50) warnings.push('Top 3 positions represent over 50% of portfolio');

  for (const [sector, weight] of Object.entries(sectors)) {
    if (weight > 0.4) warnings.push(`Heavy exposure to ${sector} sector (${(weight * 100).toFixed(0)}%)`);
  }

  return warnings;
}
```

**Dependencies:** Step 1.2, Step 2.1

---

#### Step 3.3: Automated Report Generation

**Description:** Deep dive stock analysis reports.

**Files to create:**
- `mcp-server/src/tools/analysis/reports.ts` - Report generation

**Implementation details:**
```typescript
// mcp-server/src/tools/analysis/reports.ts
import { z } from 'zod';
import type { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { getAllFinancialStatements } from '../finance/fundamentals.js';
import { getFinancialMetricsSnapshot } from '../finance/metrics.js';
import { getNews } from '../finance/news.js';
import { getAnalystEstimates } from '../finance/estimates.js';

export function registerReportTools(server: McpServer) {
  server.tool(
    'generate_stock_report',
    'Generate a comprehensive equity research report for a stock',
    {
      ticker: z.string().describe('Stock ticker symbol'),
      include_technicals: z.boolean().optional().describe('Include technical analysis (default: true)'),
    },
    async ({ ticker, include_technicals }) => {
      const tickerUpper = ticker.toUpperCase();

      // Gather all data in parallel
      const [financials, metrics, news, estimates] = await Promise.all([
        getAllFinancialStatements(tickerUpper).catch(() => null),
        getFinancialMetricsSnapshot(tickerUpper).catch(() => null),
        getNews(tickerUpper, 5).catch(() => []),
        getAnalystEstimates(tickerUpper).catch(() => null),
      ]);

      const report = {
        ticker: tickerUpper,
        generated_at: new Date().toISOString(),

        // Company Overview
        overview: {
          name: metrics?.company_name || tickerUpper,
          sector: metrics?.sector,
          industry: metrics?.industry,
          market_cap: metrics?.market_cap,
          employees: metrics?.employees,
        },

        // Valuation Metrics
        valuation: {
          pe_ratio: metrics?.pe_ratio,
          forward_pe: metrics?.forward_pe,
          peg_ratio: metrics?.peg_ratio,
          price_to_book: metrics?.price_to_book,
          price_to_sales: metrics?.price_to_sales,
          ev_to_ebitda: metrics?.ev_to_ebitda,
        },

        // Financial Performance (from income statement)
        financials: financials ? {
          revenue: financials.income_statement?.revenue,
          revenue_growth: financials.income_statement?.revenue_growth,
          gross_margin: financials.income_statement?.gross_margin,
          operating_margin: financials.income_statement?.operating_margin,
          net_margin: financials.income_statement?.net_margin,
          eps: financials.income_statement?.eps,
          eps_growth: financials.income_statement?.eps_growth,
        } : null,

        // Balance Sheet Health
        balance_sheet: financials ? {
          total_assets: financials.balance_sheet?.total_assets,
          total_debt: financials.balance_sheet?.total_debt,
          cash: financials.balance_sheet?.cash,
          debt_to_equity: financials.balance_sheet?.debt_to_equity,
          current_ratio: financials.balance_sheet?.current_ratio,
        } : null,

        // Cash Flow
        cash_flow: financials ? {
          operating_cash_flow: financials.cash_flow?.operating_cash_flow,
          free_cash_flow: financials.cash_flow?.free_cash_flow,
          capex: financials.cash_flow?.capex,
        } : null,

        // Analyst Estimates
        analyst_estimates: estimates ? {
          target_price: estimates.target_price,
          recommendation: estimates.recommendation,
          num_analysts: estimates.num_analysts,
          eps_estimates: estimates.eps_estimates,
        } : null,

        // Recent News
        recent_news: news?.slice(0, 5).map((n: any) => ({
          title: n.title,
          date: n.published_date,
          sentiment: n.sentiment,
        })),

        // Investment Considerations
        bull_case: generateBullCase(metrics, financials),
        bear_case: generateBearCase(metrics, financials),
        risks: identifyRisks(metrics, financials),
      };

      return { content: [{ type: 'text', text: JSON.stringify(report, null, 2) }] };
    }
  );
}

function generateBullCase(metrics: any, financials: any): string[] {
  const points = [];
  if (metrics?.revenue_growth > 15) points.push('Strong revenue growth');
  if (metrics?.gross_margin > 40) points.push('High gross margins');
  if (metrics?.pe_ratio < 20 && metrics?.eps_growth > 10) points.push('Attractive valuation relative to growth');
  if (financials?.cash_flow?.free_cash_flow > 0) points.push('Positive free cash flow generation');
  return points.length > 0 ? points : ['Requires deeper analysis'];
}

function generateBearCase(metrics: any, financials: any): string[] {
  const points = [];
  if (metrics?.pe_ratio > 40) points.push('High valuation multiple');
  if (metrics?.debt_to_equity > 2) points.push('Elevated debt levels');
  if (metrics?.revenue_growth < 0) points.push('Declining revenues');
  if (financials?.cash_flow?.free_cash_flow < 0) points.push('Negative free cash flow');
  return points.length > 0 ? points : ['Requires deeper analysis'];
}

function identifyRisks(metrics: any, financials: any): string[] {
  const risks = [];
  if (metrics?.beta > 1.5) risks.push('High market sensitivity');
  if (metrics?.short_interest > 10) risks.push('Elevated short interest');
  if (financials?.balance_sheet?.current_ratio < 1) risks.push('Potential liquidity concerns');
  return risks.length > 0 ? risks : ['Standard market risks apply'];
}
```

**Dependencies:** Step 1.2

---

### Phase 4: Alerts & Monitoring

#### Step 4.1: Alert System

**Description:** Configurable price and news alerts with node-cron scheduling.

**Files to create:**
- `mcp-server/src/scheduler/cron.ts` - Cron job setup
- `mcp-server/src/scheduler/market-calendar.ts` - Market hours, holidays, half-days
- `mcp-server/src/tools/alerts/alerts.ts` - Alert CRUD and checking
- `mcp-server/src/tools/alerts/notifications.ts` - Notification dispatch

**Implementation details:**
```typescript
// mcp-server/src/scheduler/market-calendar.ts
// NYSE market calendar with holidays and half-days
export function isMarketOpenNow(): boolean {
  const now = new Date();
  const et = new Intl.DateTimeFormat('en-US', { timeZone: 'America/New_York', hour: 'numeric', minute: 'numeric', hour12: false }).format(now);
  const [hours, minutes] = et.split(':').map(Number);
  const time = hours * 60 + minutes;

  // Market open 9:30 AM (570 min) to 4:00 PM (960 min) ET
  if (time < 570 || time >= 960) return false;

  // Check if trading day (not weekend, not holiday)
  return isTradingDay(now);
}

export function isTradingDay(date: Date): boolean {
  const dayOfWeek = date.getDay();
  if (dayOfWeek === 0 || dayOfWeek === 6) return false; // Weekend

  // Do NOT hardcode holidays. Use one of:
  // (A) dependency-backed calendar (preferred)
  // (B) `config/market-calendar.yaml` shipped/updated yearly (local-first)
  // Must support early closes (e.g., day after Thanksgiving).
  return isTradingDayFromCalendar(date);
}

// mcp-server/src/scheduler/cron.ts
import cron from 'node-cron';
import { checkAlerts } from '../tools/alerts/alerts.js';
import { generateMorningSummary, generateEODSummary } from '../tools/alerts/summaries.js';
import { isMarketOpenNow, isTradingDay } from './market-calendar.js';

// Run every 2 min, but skip if market closed - more accurate than cron expression
const HEARTBEAT_CRON = '*/2 * * * *';
const MORNING_BRIEF_CRON = '30 8 * * 1-5'; // 8:30 AM ET weekdays
const EOD_SUMMARY_CRON = '15 16 * * 1-5'; // 4:15 PM ET weekdays

export function initializeScheduler() {
  // Check alerts during market hours (calendar-aware)
  cron.schedule(HEARTBEAT_CRON, async () => {
    if (!isMarketOpenNow()) return; // Skip if market closed
    console.log('[Scheduler] Checking alerts...');
    await checkAlerts();
  }, {
    timezone: 'America/New_York'
  });

  // Morning brief
  cron.schedule(MORNING_BRIEF_CRON, async () => {
    console.log('[Scheduler] Generating morning brief...');
    await generateMorningSummary();
  }, {
    timezone: 'America/New_York'
  });

  // EOD summary
  cron.schedule(EOD_SUMMARY_CRON, async () => {
    console.log('[Scheduler] Generating EOD summary...');
    await generateEODSummary();
  }, {
    timezone: 'America/New_York'
  });

  console.log('[Scheduler] Initialized with market hours monitoring');
}
```

```typescript
// mcp-server/src/tools/alerts/alerts.ts
import { z } from 'zod';
import type { McpServer } from '@modelcontextprotocol/sdk/server/mcp.js';
import { alerts as alertConfig } from '../../storage/config.js';
import { db } from '../../storage/sqlite.js';
import { getPriceSnapshot } from '../finance/prices.js';
import { getNews } from '../finance/news.js';
import { v4 as uuid } from 'uuid';

export function registerAlertTools(server: McpServer) {
  server.tool(
    'alert_create',
    'Create a new price or news alert',
    {
      ticker: z.string().describe('Stock ticker symbol'),
      type: z.enum(['price_above', 'price_below', 'pct_change', 'news_keyword']).describe('Alert type'),
      value: z.union([z.number(), z.string()]).describe('Trigger value (price for price alerts, keyword for news)'),
    },
    async ({ ticker, type, value }) => {
      const config = alertConfig.load();
      config.alerts = config.alerts || [];

      const alert = {
        id: uuid(),
        ticker: ticker.toUpperCase(),
        type,
        value,
        enabled: true,
        created_at: new Date().toISOString(),
      };

      config.alerts.push(alert);
      alertConfig.save(config);

      return { content: [{ type: 'text', text: `Alert created: ${alert.id}` }] };
    }
  );

  server.tool(
    'alert_list',
    'List all configured alerts',
    {},
    async () => {
      const config = alertConfig.load();
      return { content: [{ type: 'text', text: JSON.stringify(config.alerts || [], null, 2) }] };
    }
  );

  server.tool(
    'alert_delete',
    'Delete an alert by ID',
    {
      alert_id: z.string().describe('Alert ID to delete'),
    },
    async ({ alert_id }) => {
      const config = alertConfig.load();
      config.alerts = (config.alerts || []).filter(a => a.id !== alert_id);
      alertConfig.save(config);
      return { content: [{ type: 'text', text: `Alert ${alert_id} deleted` }] };
    }
  );

  server.tool(
    'alert_check_now',
    'Manually trigger alert checking',
    {},
    async () => {
      const triggered = await checkAlerts();
      return { content: [{ type: 'text', text: JSON.stringify(triggered, null, 2) }] };
    }
  );
}

export async function checkAlerts(): Promise<any[]> {
  const config = alertConfig.load();
  const triggered = [];

  for (const alert of (config.alerts || []).filter(a => a.enabled)) {
    try {
      let isTriggered = false;
      let currentValue: number | string = 0;

      switch (alert.type) {
        case 'price_above': {
          const price = await getPriceSnapshot(alert.ticker);
          currentValue = price.close;
          isTriggered = price.close > (alert.value as number);
          break;
        }
        case 'price_below': {
          const price = await getPriceSnapshot(alert.ticker);
          currentValue = price.close;
          isTriggered = price.close < (alert.value as number);
          break;
        }
        case 'pct_change': {
          const price = await getPriceSnapshot(alert.ticker);
          currentValue = price.change_pct;
          isTriggered = Math.abs(price.change_pct) > Math.abs(alert.value as number);
          break;
        }
        case 'news_keyword': {
          // Required behavior:
          // - treat alert.value as regex OR pipe-delimited keywords
          // - only evaluate unseen items since last_checked_at
          // - dedupe by provider news_id (preferred) else hash(title+published_at)
          // - enforce cooldown_minutes
          break;
        }
      }

      if (isTriggered) {
        // Log to database
        db.prepare(`
          INSERT INTO alert_history (alert_id, ticker, triggered_at, condition, value, message)
          VALUES (?, ?, ?, ?, ?, ?)
        `).run(
          alert.id,
          alert.ticker,
          new Date().toISOString(),
          `${alert.type}: ${alert.value}`,
          typeof currentValue === 'number' ? currentValue : null,
          `Alert triggered for ${alert.ticker}: ${alert.type} = ${currentValue}`
        );

        triggered.push({
          alert,
          current_value: currentValue,
          triggered_at: new Date().toISOString(),
        });
      }
    } catch (error) {
      console.error(`Error checking alert ${alert.id}:`, error);
    }
  }

  return triggered;
}
```

**Dependencies:** Step 1.2, Step 1.3

---

### Phase 5: Web Dashboard

#### Step 5.1: Dashboard Backend API

**Description:** HTTP API for dashboard to fetch portfolio data.

**Files to create:**
- `mcp-server/src/api/server.ts` - Express HTTP server for dashboard
- `mcp-server/src/api/routes/portfolio.ts` - Portfolio endpoints
- `mcp-server/src/api/routes/alerts.ts` - Alert endpoints

**Implementation details:**
```typescript
// mcp-server/src/api/server.ts
import express from 'express';
import cors from 'cors';
import { portfolioRouter } from './routes/portfolio.js';
import { alertsRouter } from './routes/alerts.js';
import { analysisRouter } from './routes/analysis.js';

const app = express();
app.use(cors({ origin: [/^http:\/\/localhost:\d+$/] }));
app.use(express.json());

// Optional local auth (recommended)
// If PLUTUS_DASHBOARD_TOKEN is set, require `x-plutus-token` header on all routes.

app.use('/api/v1/portfolio', portfolioRouter);
app.use('/api/v1/alerts', alertsRouter);
app.use('/api/v1/analysis', analysisRouter);

const PORT = process.env.PLUTUS_DASHBOARD_PORT || 3001;

export function startDashboardServer() {
  app.listen(PORT, () => {
    console.log(`[Dashboard API] Running on http://localhost:${PORT}`);
  });
}
```

**HTTP API:**
- No HTTP handler may return a raw object; it must return `ToolResult<T>` with the same meta fields.
- Dashboard API routes MUST use equivalent `apiOk()`/`apiFail()` helpers.

### Required: apiOk/apiFail parity with MCP
Implement `mcp-server/src/api/utils/api-response.ts` mirroring `ok/fail` meta requirements.

**Dependencies:** Phase 2, Phase 3

---

#### Step 5.2: React Dashboard Frontend

**Description:** React + Vite frontend with polling updates.

**Files to create:**
- `dashboard/package.json`
- `dashboard/vite.config.ts`
- `dashboard/src/App.tsx`
- `dashboard/src/components/PortfolioOverview.tsx`
- `dashboard/src/components/HoldingsTable.tsx`
- `dashboard/src/components/AlertsList.tsx`
- `dashboard/src/components/PerformanceChart.tsx`
- `dashboard/src/hooks/usePolling.ts`
- `dashboard/src/api/client.ts`

**Implementation details:**
```typescript
// dashboard/src/hooks/usePolling.ts
import { useState, useEffect, useCallback } from 'react';

export function usePolling<T>(
  fetchFn: () => Promise<T>,
  intervalMs: number = 30000,
  enabled: boolean = true
) {
  const [data, setData] = useState<T | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<Error | null>(null);

  const fetchData = useCallback(async () => {
    try {
      const result = await fetchFn();
      setData(result);
      setError(null);
    } catch (err) {
      setError(err as Error);
    } finally {
      setLoading(false);
    }
  }, [fetchFn]);

  useEffect(() => {
    if (!enabled) return;

    fetchData();
    const interval = setInterval(fetchData, intervalMs);
    return () => clearInterval(interval);
  }, [fetchData, intervalMs, enabled]);

  return { data, loading, error, refetch: fetchData };
}
```

```tsx
// dashboard/src/App.tsx
import { PortfolioOverview } from './components/PortfolioOverview';
import { HoldingsTable } from './components/HoldingsTable';
import { AlertsList } from './components/AlertsList';
import { PerformanceChart } from './components/PerformanceChart';

export function App() {
  return (
    <div className="min-h-screen bg-gray-900 text-white p-6">
      <header className="mb-8">
        <h1 className="text-3xl font-bold">Plutus Dashboard</h1>
        <p className="text-gray-400">Portfolio Monitoring & Analysis</p>
      </header>

      <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
        <div className="lg:col-span-2">
          <PortfolioOverview />
          <PerformanceChart className="mt-6" />
        </div>
        <div>
          <AlertsList />
        </div>
      </div>

      <div className="mt-6">
        <HoldingsTable />
      </div>
    </div>
  );
}
```

**Dependencies:** Step 5.1

---

### Phase 6: Claude Code Plugin Components

#### Step 6.1: Slash Commands

**Description:** User-facing commands for common operations.

**Files to create:**
- `commands/portfolio.md` - Portfolio overview command
- `commands/analyze.md` - Stock analysis command
- `commands/thesis.md` - Thesis management command
- `commands/alerts.md` - Alert management command
- `commands/dashboard.md` - Launch dashboard command

**Implementation details:**
```markdown
<!-- commands/portfolio.md -->
---
name: portfolio
description: Show portfolio overview with current holdings and P&L
---

# Portfolio Overview

Use the Plutus MCP tools to display the current portfolio status.

1. Call `portfolio_summary` to get the overall portfolio metrics
2. Call `portfolio_get_holdings` for detailed position breakdown
3. Format the output in a clean, readable table

Display:
- Total portfolio value
- Daily and total P&L
- Position breakdown with weights
- Cash balance
```

```markdown
<!-- commands/analyze.md -->
---
name: analyze
description: Run comprehensive analysis on a stock
args:
  - name: ticker
    description: Stock ticker to analyze
    required: true
---

# Stock Analysis: {{ticker}}

Perform comprehensive analysis using Plutus tools:

1. Call `generate_stock_report` for fundamental analysis
2. Call `technical_analysis` for technical indicators
3. Call `thesis_get` to check if we have an existing thesis
4. Synthesize findings into actionable insights

Focus on:
- Valuation relative to peers and history
- Growth trajectory and sustainability
- Technical setup and entry/exit points
- Risk factors and thesis validation
```

```markdown
<!-- commands/dashboard.md -->
---
name: dashboard
description: Launch the Plutus web dashboard
---

# Launch Dashboard

Start the Plutus dashboard server and open in browser.

```bash
cd ${CLAUDE_PLUGIN_ROOT}/dashboard && bun run dev
```

The dashboard will be available at http://localhost:5173
```

**Dependencies:** Phase 1

---

#### Step 6.2: Specialized Subagents

**Description:** Multi-agent analysis system with parallel specialists.

**Files to create:**
- `agents/fundamental-analyst.md`
- `agents/technical-analyst.md`
- `agents/sentiment-analyst.md`
- `agents/risk-analyst.md`
- `agents/synthesis-coordinator.md`

**Implementation details:**
```markdown
<!-- agents/fundamental-analyst.md -->
---
name: plutus-fundamental-analyst
description: Analyzes company fundamentals including financials, valuation, and competitive position. Use for deep-dive financial analysis.
model: sonnet
tools:
  - Read
  - Grep
  - mcp__plutus__get_income_statements
  - mcp__plutus__get_balance_sheets
  - mcp__plutus__get_cash_flow_statements
  - mcp__plutus__get_financial_metrics_snapshot
  - mcp__plutus__get_analyst_estimates
---

# Fundamental Analyst Agent

You are a fundamental equity analyst specializing in growth stocks.

## Your Expertise
- Financial statement analysis
- Valuation methodologies (DCF, comparables, sum-of-parts)
- Growth sustainability assessment
- Competitive moat analysis

## Analysis Framework

1. **Revenue Quality**
   - Growth rate and consistency
   - Revenue concentration
   - Recurring vs one-time

2. **Profitability**
   - Margin expansion/contraction
   - Operating leverage
   - Path to profitability (if unprofitable)

3. **Balance Sheet**
   - Debt levels and coverage
   - Working capital efficiency
   - Cash generation

4. **Valuation**
   - Multiple analysis (P/E, EV/EBITDA, P/S)
   - Relative to history and peers
   - Growth-adjusted metrics (PEG)

## Output Format
Provide structured analysis with:
- Key metrics summary
- Strengths and weaknesses
- Valuation assessment
- Recommendation (Attractive/Fair/Expensive)
```

```markdown
<!-- agents/technical-analyst.md -->
---
name: plutus-technical-analyst
description: Analyzes price action, trends, and technical indicators. Use for timing analysis and chart patterns.
model: sonnet
tools:
  - Read
  - mcp__plutus__technical_analysis
  - mcp__plutus__get_prices
---

# Technical Analyst Agent

You are a technical analyst focused on price action and momentum.

## Your Expertise
- Trend identification
- Support/resistance levels
- Momentum indicators (RSI, MACD)
- Volume analysis
- Chart patterns

## Analysis Framework

1. **Trend Analysis**
   - Primary trend (up/down/sideways)
   - Position relative to key MAs (20, 50, 200)
   - Trend strength

2. **Momentum**
   - RSI reading and divergences
   - MACD signal and histogram
   - Rate of change

3. **Volume**
   - Volume trends
   - Accumulation/distribution
   - Volume on breakouts

4. **Key Levels**
   - Support zones
   - Resistance zones
   - Breakout targets

## Output Format
Provide:
- Current technical setup
- Key levels to watch
- Momentum assessment
- Short-term outlook (Bullish/Neutral/Bearish)
```

```markdown
<!-- agents/synthesis-coordinator.md -->
---
name: plutus-synthesis-coordinator
description: Synthesizes analysis from multiple specialist agents into a cohesive investment recommendation. Use as the final step in multi-agent analysis.
model: opus
tools:
  - Read
  - mcp__plutus__thesis_get
  - mcp__plutus__thesis_create
---

# Synthesis Coordinator Agent

You coordinate and synthesize analysis from specialist agents.

## Your Role
- Integrate fundamental, technical, sentiment, and risk perspectives
- Identify areas of agreement and conflict
- Weight different factors appropriately
- Produce actionable recommendations

## Synthesis Framework

1. **Collect Inputs**
   - Fundamental analyst assessment
   - Technical analyst assessment
   - Sentiment analyst assessment
   - Risk analyst assessment

2. **Identify Consensus**
   - Where do analysts agree?
   - Where do they disagree?
   - What explains differences?

3. **Weight Factors**
   - For growth stocks: fundamentals > technicals
   - For turnarounds: catalysts > valuation
   - Always consider risk assessment

4. **Formulate Recommendation**
   - Overall rating: Strong Buy / Buy / Hold / Sell
   - Confidence level
   - Key factors driving recommendation
   - What would change the thesis

## Output Format
```
## Investment Recommendation: [TICKER]

**Rating:** [Strong Buy / Buy / Hold / Sell]
**Confidence:** [High / Medium / Low]

### Summary
[2-3 sentence synthesis]

### Key Factors
1. [Most important factor]
2. [Second factor]
3. [Third factor]

### Risks
- [Primary risk]
- [Secondary risk]

### What to Watch
- [Catalyst or metric that could change thesis]
```
```

**Dependencies:** Phase 1, Phase 3

---

#### Step 6.3: Skills

**Description:** Auto-activating skills for context-aware assistance.

**Files to create:**
- `skills/portfolio-analysis/SKILL.md`
- `skills/stock-research/SKILL.md`
- `skills/risk-assessment/SKILL.md`

**Implementation details:**
```markdown
<!-- skills/portfolio-analysis/SKILL.md -->
---
name: portfolio-analysis
description: Use when discussing portfolio performance, rebalancing, or allocation. Automatically activates for portfolio-related queries.
---

# Portfolio Analysis Skill

When analyzing portfolios, use Plutus tools systematically:

## Available Tools
- `portfolio_summary` - Overall metrics
- `portfolio_get_holdings` - Position details
- `risk_analysis` - Risk metrics
- `thesis_validate` - Check thesis alignment

## Analysis Checklist

1. **Performance Review**
   - Total return vs benchmark
   - Attribution by position
   - Winners and losers

2. **Risk Assessment**
   - Portfolio beta
   - Sector concentration
   - Position sizing

3. **Thesis Alignment**
   - Are positions still aligned with original thesis?
   - Any thesis violations?

4. **Rebalancing Needs**
   - Positions drifted from targets?
   - Risk limits breached?
   - Tax-loss harvesting opportunities?
```

**Dependencies:** Phase 1

---

### Phase 7: Multi-Agent Orchestration

#### Step 7.1: Parallel Analysis Workflow

**Description:** Implement the parallel specialist pattern for comprehensive stock analysis.

**Files to create:**
- `skills/multi-agent-analysis/SKILL.md`
- Scripts for orchestration

**Implementation details:**
```markdown
<!-- skills/multi-agent-analysis/SKILL.md -->
---
name: multi-agent-analysis
description: Use when performing comprehensive stock analysis. Spawns parallel specialist agents for deep analysis.
---

# Multi-Agent Analysis Skill

For comprehensive stock analysis, spawn parallel specialist subagents:

## Workflow

1. **Spawn Specialists in Parallel**
   Use the Task tool to launch these agents concurrently:

   - `plutus-fundamental-analyst`: Deep-dive on financials
   - `plutus-technical-analyst`: Chart and momentum analysis
   - `plutus-sentiment-analyst`: News and market sentiment
   - `plutus-risk-analyst`: Risk factor assessment

2. **Collect Results**
   Wait for all agents to complete their analysis.

3. **Synthesize**
   Use `plutus-synthesis-coordinator` to integrate findings.

## Example Invocation

```
For ticker NVDA, launch parallel analysis:

Task 1: subagent_type="plutus-fundamental-analyst"
        prompt="Analyze NVDA fundamentals"

Task 2: subagent_type="plutus-technical-analyst"
        prompt="Analyze NVDA technical setup"

Task 3: subagent_type="plutus-sentiment-analyst"
        prompt="Analyze NVDA sentiment"

Task 4: subagent_type="plutus-risk-analyst"
        prompt="Assess NVDA risks"

After all complete:

Task 5: subagent_type="plutus-synthesis-coordinator"
        prompt="Synthesize analysis for NVDA from: [agent outputs]"
```

## When to Use
- New position evaluation
- Quarterly reviews
- Major news events
- Thesis validation
```

**Dependencies:** Step 6.2

---

## Files Summary

### Files to Create

| File | Purpose |
|------|---------|
| `.claude-plugin/plugin.json` | Plugin manifest |
| `.mcp.json` | MCP server configuration |
| `mcp-server/package.json` | MCP server dependencies |
| `mcp-server/src/entrypoints/stdio.ts` | MCP stdio entry point |
| `mcp-server/src/entrypoints/daemon.ts` | HTTP + scheduler daemon |
| `mcp-server/src/server.ts` | McpServer setup |
| `mcp-server/src/tools/finance/*.ts` | Migrated financial tools |
| `mcp-server/src/tools/portfolio/*.ts` | Portfolio management tools |
| `mcp-server/src/tools/analysis/*.ts` | Analysis tools |
| `mcp-server/src/tools/alerts/*.ts` | Alert tools |
| `mcp-server/src/storage/sqlite.ts` | SQLite integration |
| `mcp-server/src/storage/config.ts` | YAML config loader |
| `mcp-server/src/storage/embeddings.ts` | Xenova/transformers |
| `mcp-server/src/scheduler/cron.ts` | Node-cron scheduler |
| `mcp-server/src/api/server.ts` | Dashboard API server |
| `dashboard/package.json` | Dashboard dependencies |
| `dashboard/src/App.tsx` | Dashboard main component |
| `dashboard/src/components/*.tsx` | Dashboard components |
| `commands/*.md` | Slash commands |
| `agents/*.md` | Specialist subagents |
| `skills/*/SKILL.md` | Auto-activating skills |
| `config/portfolio.yaml` | Portfolio config |
| `config/watchlist.yaml` | Watchlist config |
| `config/alerts.yaml` | Alerts config |

### Files to Modify

| File | Changes |
|------|---------|
| None | This is a greenfield implementation |

### Files from Dexter to Migrate

| Source | Destination | Changes |
|--------|-------------|---------|
| `dexter/src/tools/finance/api.ts` | `mcp-server/src/tools/finance/api.ts` | Minimal (env var paths) |
| `dexter/src/tools/finance/*.ts` | `mcp-server/src/tools/finance/*.ts` | Convert to MCP tool format |

## Verification

### Acceptance Criteria

- [ ] MCP server starts and registers all financial tools
- [ ] Portfolio CRUD operations work (add, remove, list holdings)
- [ ] Investment thesis can be created and semantically searched
- [ ] Technical analysis returns correct indicators
- [ ] Risk analysis calculates portfolio metrics
- [ ] Alerts can be configured and trigger correctly
- [ ] Scheduler runs during market hours
- [ ] Web dashboard displays portfolio data with polling
- [ ] Multi-agent analysis spawns parallel specialists
- [ ] All slash commands function correctly

### Test Commands

```bash
# Start MCP server (for testing)
cd Plutus/mcp-server && bun run src/entrypoints/stdio.ts

# Run unit tests
cd Plutus/mcp-server && bun test

# Start dashboard
cd Plutus/dashboard && bun run dev

# Test MCP tools via Claude Code
claude
> /portfolio
> /analyze AAPL
```

### Test Cases to Add

| Test | Description | File |
|------|-------------|------|
| `test_portfolio_crud` | Add, list, remove holdings | `mcp-server/tests/portfolio.test.ts` |
| `test_thesis_embeddings` | Create thesis and semantic search | `mcp-server/tests/thesis.test.ts` |
| `test_technical_indicators` | Verify RSI, MACD, etc. | `mcp-server/tests/technical.test.ts` |
| `test_alert_triggers` | Price and news alert logic | `mcp-server/tests/alerts.test.ts` |
| `test_risk_metrics` | Portfolio beta, HHI | `mcp-server/tests/risk.test.ts` |

## Resources

### External Documentation
- [MCP TypeScript SDK](https://github.com/modelcontextprotocol/typescript-sdk)
- [Claude Code Plugin Development](https://code.claude.com/docs/en/plugins)
- [Xenova/transformers](https://github.com/xenova/transformers.js)
- [Financial Datasets API](https://financialdatasets.ai/docs)

### Research Findings

**From Perplexity Research:**
> MCP servers use JSON-RPC 2.0 over stdio transport. The @modelcontextprotocol/sdk provides McpServer class with tool() method for registering tools using Zod schemas. Claude Code acts as both MCP client and server simultaneously.

> For financial tools, the pattern is: define Zod schema for input, implement async handler, return content array with type 'text'. Use parallel Promise.all for multi-ticker operations.

> Plugin structure: .claude-plugin/plugin.json manifest, commands/ for slash commands, agents/ for subagents, skills/ for auto-activating capabilities, .mcp.json for MCP server configs.

### Related Code
- `dexter/src/agent/agent.ts` - Reference for agent loop pattern
- `dexter/src/tools/finance/financial-search.ts` - Reference for meta-routing tool
- `dexter/src/agent/prompts.ts` - Reference for prompt engineering

## Open Questions

None remaining - all questions resolved during clarification.

## Appendix

### Feature Mapping to Implementation

| Feature | Implementation Location |
|---------|------------------------|
| 1. Real-Time Portfolio Dashboard | Phase 5 (Web Dashboard) |
| 2. Intelligent Alerting System | Phase 4 (Alert System) |
| 3. Investment Thesis Tracking | Step 2.2 (Thesis Tools) |
| 4. Automated Stock Reports | Step 3.3 (Report Generation) |
| 5. Valuation & Peer Comparison | Step 3.3 (in generate_stock_report) |
| 6. Technical Analysis | Step 3.1 (Technical Tools) |
| 7. Risk Management | Step 3.2 (Risk Tools) |
| 8. Multi-Agent Analysis | Phase 7 (Multi-Agent Orchestration) |
| 9. Performance Attribution | Step 2.1 (portfolio_summary) |
| 10. Scheduled Summaries | Phase 4 (Scheduler) |

### Architecture Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        Claude Code                              │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                    Plutus Plugin                          │  │
│  │  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────┐     │  │
│  │  │Commands │  │ Agents  │  │ Skills  │  │  Hooks  │     │  │
│  │  └────┬────┘  └────┬────┘  └────┬────┘  └────┬────┘     │  │
│  └───────┼────────────┼────────────┼────────────┼──────────┘  │
└──────────┼────────────┼────────────┼────────────┼─────────────┘
           │            │            │            │
           ▼            ▼            ▼            ▼
┌─────────────────────────────────────────────────────────────────┐
│                      Plutus MCP Server                          │
│  ┌─────────────────────────────────────────────────────────┐   │
│  │                      Tools                               │   │
│  │  ┌─────────┐  ┌──────────┐  ┌──────────┐  ┌─────────┐  │   │
│  │  │Finance  │  │Portfolio │  │ Analysis │  │ Alerts  │  │   │
│  │  │(18 tools)│  │  Tools   │  │  Tools   │  │ Tools   │  │   │
│  │  └────┬────┘  └────┬─────┘  └────┬─────┘  └────┬────┘  │   │
│  └───────┼────────────┼─────────────┼─────────────┼────────┘   │
│          │            │             │             │             │
│  ┌───────┴────────────┴─────────────┴─────────────┴────────┐   │
│  │                    Storage Layer                         │   │
│  │  ┌──────────────┐        ┌──────────────────┐           │   │
│  │  │ YAML Configs │        │ SQLite Database  │           │   │
│  │  │ - portfolio  │        │ - price history  │           │   │
│  │  │ - watchlist  │        │ - embeddings     │           │   │
│  │  │ - alerts     │        │ - alert history  │           │   │
│  │  │ - theses/    │        │ - snapshots      │           │   │
│  │  └──────────────┘        └──────────────────┘           │   │
│  └─────────────────────────────────────────────────────────┘   │
│          │                                                      │
│  ┌───────┴──────────────────────────────────────────────────┐  │
│  │                    Scheduler (node-cron)                  │  │
│  │  - Market hours alert checking                            │  │
│  │  - Morning/EOD summaries                                  │  │
│  └───────────────────────────────────────────────────────────┘  │
│          │                                                      │
│  ┌───────┴──────────────────────────────────────────────────┐  │
│  │                    Dashboard API (Express)                │  │
│  └──────────────────────────────┬───────────────────────────┘  │
└─────────────────────────────────┼───────────────────────────────┘
                                  │
                                  ▼
┌─────────────────────────────────────────────────────────────────┐
│                    Web Dashboard (React + Vite)                 │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │  Portfolio  │  │   Charts    │  │   Alerts    │             │
│  │  Overview   │  │             │  │    List     │             │
│  └─────────────┘  └─────────────┘  └─────────────┘             │
│                     (Polling @ 30s)                             │
└─────────────────────────────────────────────────────────────────┘
```

---

## Addendum: Ticker Research & Comparison Use Cases

### Use Case 1: Single Ticker Deep Research with Custom Scoring

**User Story:** Pass in a ticker and receive a comprehensive research report with a custom scoring rubric.

#### Implementation

**New Config File:** `config/scoring-rubric.yaml`
```yaml
# User-defined scoring rubric
name: "Growth Equity Scorecard"
max_score: 100

categories:
  - name: "Growth"
    weight: 30
    metrics:
      - name: "Revenue Growth (3yr CAGR)"
        thresholds: { "20+": 10, "15-20": 8, "10-15": 6, "5-10": 4, "<5": 2 }
      - name: "EPS Growth (3yr CAGR)"
        thresholds: { "25+": 10, "15-25": 8, "10-15": 6, "0-10": 4, "<0": 0 }
      - name: "TAM Expansion Potential"
        type: "qualitative"  # LLM assessed

  - name: "Profitability"
    weight: 25
    metrics:
      - name: "Gross Margin"
        thresholds: { "70+": 10, "50-70": 8, "40-50": 6, "30-40": 4, "<30": 2 }
      - name: "Operating Margin"
        thresholds: { "20+": 10, "10-20": 7, "0-10": 4, "<0": 2 }
      - name: "FCF Margin"
        thresholds: { "15+": 5, "5-15": 3, "0-5": 2, "<0": 0 }

  - name: "Valuation"
    weight: 20
    metrics:
      - name: "P/E vs Growth (PEG)"
        thresholds: { "<1": 10, "1-1.5": 7, "1.5-2": 5, "2-3": 3, ">3": 1 }
      - name: "EV/Revenue vs Peers"
        type: "relative"
      - name: "Upside to Target"
        thresholds: { "30+": 10, "20-30": 7, "10-20": 5, "0-10": 3, "<0": 0 }

  - name: "Quality"
    weight: 15
    metrics:
      - name: "ROIC"
        thresholds: { "25+": 10, "15-25": 7, "10-15": 5, "0-10": 3, "<0": 0 }
      - name: "Debt/Equity"
        thresholds: { "<0.3": 10, "0.3-0.5": 8, "0.5-1": 5, "1-2": 3, ">2": 1 }

  - name: "Momentum"
    weight: 10
    metrics:
      - name: "Price vs 52-week High"
        thresholds: { "within 5%": 10, "5-15%": 7, "15-30%": 5, ">30%": 3 }
      - name: "RSI Signal"
        type: "technical"

interpretation:
  "85-100": "Strong Buy - Exceptional opportunity"
  "70-84": "Buy - Attractive risk/reward"
  "55-69": "Hold - Fair value, monitor for entry"
  "40-54": "Weak - Concerns outweigh positives"
  "0-39": "Avoid - Significant red flags"
```

**New MCP Tool:** `score_ticker`
```typescript
// mcp-server/src/tools/analysis/scoring.ts
server.tool(
  'score_ticker',
  'Score a stock using the custom scoring rubric',
  {
    ticker: z.string().describe('Stock ticker to score'),
    rubric_name: z.string().optional().describe('Rubric to use (default: primary rubric)'),
  },
  async ({ ticker, rubric_name }) => {
    // Load rubric from config/scoring-rubric.yaml
    const rubric = loadScoringRubric(rubric_name);

    // Gather all required data
    const [financials, metrics, prices, technicals] = await Promise.all([
      getAllFinancialStatements(ticker),
      getFinancialMetricsSnapshot(ticker),
      getPrices(ticker, '3y'),
      calculateTechnicalIndicators(ticker),
    ]);

    // Calculate scores for each category
    const scores = await calculateScores(rubric, {
      financials,
      metrics,
      prices,
      technicals,
    });

    // Generate report
    return {
      content: [{
        type: 'text',
        text: JSON.stringify({
          ticker,
          total_score: scores.total,
          max_score: rubric.max_score,
          rating: getRating(scores.total, rubric.interpretation),
          category_breakdown: scores.categories,
          strengths: scores.strengths,
          weaknesses: scores.weaknesses,
          key_metrics: scores.key_metrics,
        }, null, 2),
      }],
    };
  }
);
```

**New Slash Command:** `commands/research.md`
```markdown
---
name: research
description: Generate comprehensive research report with scoring for a ticker
args:
  - name: ticker
    description: Stock ticker to research
    required: true
  - name: deep
    description: Include multi-agent deep analysis
    required: false
    default: false
---

# Research Report: {{ticker}}

Generate a comprehensive research report with custom scoring.

## Workflow

1. **Gather Data**
   - Call `generate_stock_report` for fundamental analysis
   - Call `technical_analysis` for technical setup
   - Call `score_ticker` to apply custom scoring rubric

2. **If deep=true, spawn parallel agents:**
   - Launch `plutus-fundamental-analyst`
   - Launch `plutus-technical-analyst`
   - Launch `plutus-sentiment-analyst`
   - Synthesize with `plutus-synthesis-coordinator`

3. **Compile Report**
   Format output as:
   ```
   ═══════════════════════════════════════════════════
   RESEARCH REPORT: {{ticker}}
   ═══════════════════════════════════════════════════

   SCORE: XX/100 (Rating)

   ┌─────────────────────────────────────────────────┐
   │ Category Scores                                 │
   ├─────────────────────────────────────────────────┤
   │ Growth        █████████░ 27/30                  │
   │ Profitability ███████░░░ 18/25                  │
   │ Valuation     ██████░░░░ 12/20                  │
   │ Quality       ████████░░ 12/15                  │
   │ Momentum      ███████░░░ 7/10                   │
   └─────────────────────────────────────────────────┘

   STRENGTHS:
   - [Key strength 1]
   - [Key strength 2]

   WEAKNESSES:
   - [Key weakness 1]
   - [Key weakness 2]

   [Full analysis sections...]
   ```

4. **Check for existing thesis**
   - Call `thesis_get` to see if we have an investment thesis
   - If exists, note alignment/divergence with current analysis
```

---

### Use Case 2: Multi-Ticker Comparison ("Best Buy" Analysis)

**User Story:** Pass in 2+ tickers, get a comparison showing which is the best buy and why.

**New MCP Tool:** `compare_tickers`
```typescript
// mcp-server/src/tools/analysis/comparison.ts
server.tool(
  'compare_tickers',
  'Compare multiple stocks and determine the best buy',
  {
    tickers: z.array(z.string()).min(2).max(10).describe('List of tickers to compare'),
    criteria: z.enum(['overall', 'value', 'growth', 'momentum', 'quality']).optional()
      .describe('Primary comparison criteria (default: overall)'),
  },
  async ({ tickers, criteria }) => {
    // Score each ticker
    const scores = await Promise.all(
      tickers.map(async (ticker) => {
        const score = await scoreTicker(ticker);
        return { ticker, ...score };
      })
    );

    // Rank by total score (or specific criteria)
    const ranked = scores.sort((a, b) => b.total_score - a.total_score);

    // Generate comparison matrix
    const comparison = {
      best_buy: {
        ticker: ranked[0].ticker,
        score: ranked[0].total_score,
        rating: ranked[0].rating,
        why: generateBestBuyRationale(ranked[0], ranked.slice(1)),
      },
      rankings: ranked.map((s, i) => ({
        rank: i + 1,
        ticker: s.ticker,
        score: s.total_score,
        rating: s.rating,
        strengths: s.strengths.slice(0, 2),
        weaknesses: s.weaknesses.slice(0, 2),
      })),
      head_to_head: generateHeadToHead(ranked),
      valuation_comparison: await getValuationComparison(tickers),
      growth_comparison: await getGrowthComparison(tickers),
    };

    return { content: [{ type: 'text', text: JSON.stringify(comparison, null, 2) }] };
  }
);

function generateBestBuyRationale(winner: any, others: any[]): string[] {
  const reasons = [];

  // Score advantage
  const avgOtherScore = others.reduce((s, o) => s + o.total_score, 0) / others.length;
  reasons.push(`Scores ${(winner.total_score - avgOtherScore).toFixed(1)} points above average`);

  // Category advantages
  for (const [category, score] of Object.entries(winner.category_scores)) {
    const avgOther = others.reduce((s, o) => s + o.category_scores[category], 0) / others.length;
    if (score > avgOther * 1.2) {
      reasons.push(`Superior ${category} metrics`);
    }
  }

  // Specific metric callouts
  if (winner.key_metrics.peg < 1.5) reasons.push('Attractive growth-adjusted valuation');
  if (winner.key_metrics.revenue_growth > 20) reasons.push('Strong revenue growth trajectory');

  return reasons;
}
```

**New Slash Command:** `commands/compare.md`
```markdown
---
name: compare
description: Compare multiple stocks and find the best buy
args:
  - name: tickers
    description: Comma-separated list of tickers (e.g., AAPL,MSFT,GOOGL)
    required: true
  - name: criteria
    description: Focus criteria (overall, value, growth, momentum, quality)
    required: false
    default: overall
---

# Stock Comparison: {{tickers}}

Compare the provided tickers and determine the best buy.

## Workflow

1. **Parse tickers** from comma-separated input
2. **Score each ticker** using `score_ticker`
3. **Run comparison** using `compare_tickers`
4. **Generate comparison report**

## Output Format

```
═══════════════════════════════════════════════════════════════════
STOCK COMPARISON
═══════════════════════════════════════════════════════════════════

🏆 BEST BUY: [TICKER] (Score: XX/100)

Why [TICKER] wins:
• [Reason 1]
• [Reason 2]
• [Reason 3]

┌────────────────────────────────────────────────────────────────┐
│ RANKINGS                                                       │
├──────┬────────┬───────┬────────────┬───────────────────────────┤
│ Rank │ Ticker │ Score │ Rating     │ Key Differentiator        │
├──────┼────────┼───────┼────────────┼───────────────────────────┤
│ 1    │ NVDA   │ 82    │ Buy        │ Best growth profile       │
│ 2    │ AMD    │ 71    │ Buy        │ Value play on semis       │
│ 3    │ INTC   │ 54    │ Hold       │ Turnaround risk           │
└──────┴────────┴───────┴────────────┴───────────────────────────┘

HEAD-TO-HEAD COMPARISON
┌────────────────────┬────────┬────────┬────────┐
│ Metric             │ NVDA   │ AMD    │ INTC   │
├────────────────────┼────────┼────────┼────────┤
│ Revenue Growth     │ 122%   │ 10%    │ -14%   │
│ Gross Margin       │ 72%    │ 47%    │ 41%    │
│ P/E Ratio          │ 45x    │ 38x    │ N/A    │
│ PEG Ratio          │ 0.8    │ 1.2    │ N/A    │
│ FCF Yield          │ 2.1%   │ 3.4%   │ -1.2%  │
│ Technical Setup    │ Bullish│ Neutral│ Bearish│
└────────────────────┴────────┴────────┴────────┘

DETAILED ANALYSIS
[Per-ticker breakdown...]
```
```

**New Skill:** `skills/ticker-comparison/SKILL.md`
```markdown
---
name: ticker-comparison
description: Use when comparing stocks, evaluating relative value, or deciding between investment options. Automatically activates for "which is better", "compare", "best buy" queries.
---

# Ticker Comparison Skill

When comparing stocks, use this systematic approach:

## Available Tools
- `score_ticker` - Score individual stocks
- `compare_tickers` - Compare multiple stocks
- `generate_stock_report` - Deep dive on specific ticker

## Comparison Framework

1. **Quantitative Comparison**
   - Score each ticker using the same rubric
   - Compare key metrics side-by-side
   - Calculate relative valuation

2. **Qualitative Assessment**
   - Competitive positioning
   - Management quality
   - Moat durability
   - Industry tailwinds/headwinds

3. **Risk-Adjusted View**
   - Upside potential
   - Downside risk
   - Volatility comparison

## Decision Framework

The "best buy" is determined by:
1. Highest overall score (primary)
2. Best risk/reward ratio
3. Strongest category scores in user-specified criteria

Always explain WHY the winner is the best choice with specific, data-backed reasons.
```

---

### Updated Files Summary

| New File | Purpose |
|----------|---------|
| `config/scoring-rubric.yaml` | User-defined scoring rubric |
| `mcp-server/src/tools/analysis/scoring.ts` | Ticker scoring implementation |
| `mcp-server/src/tools/analysis/comparison.ts` | Multi-ticker comparison |
| `commands/research.md` | Deep research command |
| `commands/compare.md` | Comparison command |
| `skills/ticker-comparison/SKILL.md` | Comparison skill |

### Updated Acceptance Criteria

- [ ] `score_ticker` tool calculates scores using custom rubric
- [ ] `score_ticker` persists a reproducible `score_runs` record (rubric_hash + inputs_json)
- [ ] Scoring rubric is configurable via YAML file
- [ ] `/research AAPL` generates scored research report
- [ ] `/compare AAPL,MSFT,GOOGL` ranks and identifies best buy
- [ ] Comparison explains WHY the winner is best with specific metrics
- [ ] Supports 2-10 tickers in comparison

---

## Checklist Before Implementation

- [x] All design decisions documented with rationale
- [x] All files to modify/create identified
- [x] Acceptance criteria are specific and testable
- [x] Test commands provided
- [x] No unresolved blockers in Open Questions
- [x] Plan is self-contained (another dev could execute without context)
