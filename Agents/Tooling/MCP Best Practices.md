---
created: 2026-02-22
description: Comprehensive guide to designing, building, and scaling MCP servers synthesized from 50+ sources
source: multiple (50+ published sources 2025-2026)
type: framework
---

# MCP Best Practices

Comprehensive guide to designing, building, and scaling Model Context Protocol servers. Synthesized from 50+ sources published between 2025-2026.

---

## 1. Architecture Fundamentals

MCP follows a client-server architecture built on JSON-RPC 2.0 with three layers:

- **Host**: The application users interact with (Claude Desktop, IDE, custom app)
- **Client**: Maintains a 1:1 connection to a specific server, handles protocol negotiation
- **Server**: Exposes capabilities (tools, resources, prompts) to clients

Each MCP server should have **one clear, well-defined purpose**. The guiding principle: "one server, one job" with 5-15 tools per server. MCP servers are fundamentally different from REST APIs -- "an API built for a human will poison your AI agent." You are building for the agent that acts on behalf of the user, not for the end user directly. ([Cloudflare Code Mode](https://blog.cloudflare.com/code-mode/), [Anthropic MCP Announcement](https://www.anthropic.com/news/model-context-protocol))

### Three Architecture Patterns (IBM)

1. **Reusable AI Agents**: Each MCP server embeds its own LLM -- modular but tighter coupling
2. **Strict MCP Purity**: LLM lives only in the client; servers are stateless tool providers (canonical design, best for dynamic orchestration and data privacy)
3. **Hybrid**: Server-side specialized agents + client-side orchestration (best for enterprise systems balancing reusability with flexibility)

([IBM: MCP Architecture Patterns](https://developer.ibm.com/articles/mcp-architecture-patterns-ai-systems/))

---

## 2. Transport Types and Evolution

### Current Official Transports

| Transport | Use Case | Latency | Concurrency | Status |
|-----------|----------|---------|-------------|--------|
| **stdio** | Local tools, CLI, IDE plugins | <1ms | Single client | Stable |
| **Streamable HTTP** | Remote, production, multi-user | 10-50ms | Unlimited | Stable (since March 2025) |
| **HTTP+SSE** | Legacy remote | 10-50ms | Limited | **Deprecated** |

### stdio

The client spawns the server as a child process and communicates via stdin/stdout. Newline-delimited JSON-RPC. ~10MB memory per connection, 10,000+ ops/sec. Best for local development, IDE plugins, CLI tools, and scenarios requiring lowest latency.

### Streamable HTTP

Replaced SSE in the March 2025 spec. Uses a **single endpoint** (typically `/mcp`) for everything:

- **POST** for client-to-server messages (can return JSON or upgrade to SSE stream for long-running operations)
- **GET** for server-initiated SSE notifications
- Optional `Mcp-Session-Id` header for stateful sessions
- Supports resumability via `Last-Event-ID`
- Clients must include `MCP-Protocol-Version` header on all requests

### Why SSE Was Deprecated

Five critical problems: dual-endpoint complexity, scalability constraints from persistent connections, no resumability, unidirectional design, and HTTP/2+3 incompatibility. Streamable HTTP delivers 290-300 RPS at high concurrency versus SSE's 29-36 RPS limit.

### Emerging: gRPC Transport

Google Cloud announced (Feb 2026) a pluggable gRPC transport package for MCP SDKs. Benefits: Protocol Buffers serialization (lower bandwidth), static typing, alignment with enterprise microservices. A WebSocket transport SEP is also under review.

### Protocol Timeline

| Date | Event |
|------|-------|
| Nov 2024 | MCP launched with stdio + HTTP+SSE |
| Mar 2025 | Streamable HTTP replaces SSE |
| Jun 2025 | Spec 2025-06-18: elicitation, structured outputs, OAuth 2.1 |
| Nov 2025 | Spec 2025-11-25: async tasks, improved OAuth, extensions |
| Dec 2025 | Transport Working Group roadmap: stateless protocol vision |
| Feb 2026 | Google announces gRPC transport contribution |
| Jun 2026 (target) | Next spec: stateless protocol, Server Cards, subscriptions |

([MCP Spec - Transports](https://modelcontextprotocol.io/specification/2025-06-18/basic/transports), [Why MCP Deprecated SSE](https://blog.fka.dev/blog/2025-06-06-why-mcp-deprecated-sse-and-go-with-streamable-http/), [Future of MCP Transports](http://blog.modelcontextprotocol.io/posts/2025-12-19-mcp-transport-future/), [Google gRPC for MCP](https://www.infoq.com/news/2026/02/google-grpc-mcp-transport/))

---

## 3. The Six MCP Primitives

MCP provides six core primitives across a control axis:

| Primitive | Controlled By | Purpose |
|-----------|--------------|---------|
| **Tools** | Model-driven | Execute actions with typed I/O |
| **Resources** | Application-driven | Expose read-only data via URIs |
| **Prompts** | User-driven | Reusable instruction templates |
| **Sampling** | Server-initiated | Request LLM completions through client |
| **Roots** | Client-provided | Define filesystem access boundaries |
| **Elicitation** | Server-initiated | Ask users follow-up questions |

### When to Use Each

| Need | Use | Reason |
|------|-----|--------|
| Execute an action | **Tool** | User approval required; transactional |
| Reference existing data | **Resource** | Read-only; no operations triggered |
| Standardize instructions | **Prompt** | Reusable, version-controlled templates |
| Server needs AI reasoning | **Sampling** | Delegates to client's LLM connection |
| Restrict file access | **Roots** | File URIs defining workspace directories |
| Missing user context | **Elicitation** | Structured follow-up questions |

### Combining Primitives

The real power emerges from combining features. A **Prompt** initializes the workflow, **Resources** provide contextual data (calendars, policies, preferences), **Tools** execute actions (book venue, arrange catering), **Sampling** offloads reasoning, and **Elicitation** fills in gaps -- creating a coordinated, end-to-end experience where users retain full control.

([WorkOS MCP Features Guide](https://workos.com/blog/mcp-features-guide), [Beyond Tool Calling - Upsun](https://devcenter.upsun.com/posts/mcp-interaction-types-article/), [MCP Architecture Deep Dive - Knit](https://www.getknit.dev/blog/mcp-architecture-deep-dive-tools-resources-and-prompts-explained))

---

## 4. Tool Design

### Naming Conventions

- **Tool names**: Use `snake_case` (90%+ production adoption). Begin with imperative verbs: `get_`, `list_`, `create_`, `update_`, `delete_`. Keep under 32 characters. Pattern: `[service]_[action]_[resource]`
- **Package names**: Use `kebab-case` with `mcp` in the name. Most common: `<name>-mcp` (40% adoption)
- Namespace related tools under common prefixes: `asana_search`, `asana_projects_search`
- Tool versions follow **SemVer 2.0.0**

([MCP Server Naming Conventions](https://zazencodes.com/blog/mcp-server-naming-conventions), [SEP-986](https://github.com/modelcontextprotocol/modelcontextprotocol/issues/986))

### Descriptions

- 1-2 sentences, verb + resource structure ("Create a new channel")
- "Think of how you would describe your tool to a new hire on your team" -- make implicit knowledge explicit
- Front-load critical details; state primary action first, then constraints
- Separate schema metadata (auth requirements, pagination, rate limits) from descriptions
- Test descriptions through tool call evaluations; measure hit rate and refine
- Avoid "not found" response text -- it causes LLMs to ignore subsequent data

([5 Best Practices - Snyk](https://snyk.io/articles/5-best-practices-for-building-mcp-servers/), [Anthropic: Writing Tools for Agents](https://www.anthropic.com/engineering/writing-tools-for-agents))

### Parameters

- Name parameters unambiguously: `user_id` not `user`
- Use enums for constrained values instead of free-text
- Apply `additionalProperties: false` to prevent hallucinated fields
- Use `minLength`, `maximum`, and `format` validators (email, uri, date-time)
- Mark required fields explicitly -- well-trained models will ask users rather than guessing
- Flatten inputs into a single `inputSchema` regardless of HTTP origin
- Support flexible response modes via a `response_format` enum (`concise` vs `detailed`)
- Return high-signal information: prefer `name`, `file_type` over `uuid`, `mime_type`

### Granularity

**Too few tools**: LLM lacks granularity. **Too many**: token budget blown, model confused selecting between similar options. One analysis found 50+ MCP tools consuming ~72K tokens just for definitions, leaving minimal room for reasoning in a 200K context window.

**Core principle**: Tools represent capabilities, not REST endpoints. Don't mirror every API route.

- Design tools as **actions/outcomes, not CRUD**: `publish_report`, `transfer_ownership` rather than `create`, `update`, `delete`
- Consolidate narrow list endpoints into a **single search tool** with natural-language queries + structured filters
- Start broad, then split based on observed agent behavior
- High retry rates indicate tools need better descriptions; repeated tool sequences signal it's time to bundle

([54 Patterns for Better MCP Tools](https://arcade.dev/blog/mcp-tool-patterns), [MCP Spec - Tools](https://modelcontextprotocol.io/specification/2025-06-18/server/tools))

### Tool Annotations (Spec 2025-06-18)

| Annotation | Type | Purpose | Default |
|------------|------|---------|---------|
| `title` | string | Human-readable display name | - |
| `readOnlyHint` | bool | No mutations | false |
| `destructiveHint` | bool | Destructive changes | true |
| `idempotentHint` | bool | Safe to retry | false |
| `openWorldHint` | bool | External system interaction | true |

These are **hints, not guarantees**. Clients use them to decide confirmation prompts but must not make security-critical decisions based solely on annotations.

### Structured Output (Spec 2025-06-18)

Tools may provide an `outputSchema` for validation of structured results. Design complementary outputs: `content` provides a human/model-oriented representation, while `structuredContent` provides a machine-oriented representation with strict schema validation. Return stable identifiers and pagination cursors (`next_cursor`, `has_more`).

---

## 5. Scaling for High Throughput

### Performance Benchmarks by Language

Tested across 3.9 million requests ([TM Dev Lab](https://www.tmdevlab.com/mcp-server-performance-benchmark.html)):

| Language | Throughput (RPS) | Avg Latency | p95 Latency | CPU | Memory | Efficiency (RPS/MB) |
|----------|-----------------|-------------|-------------|-----|--------|---------------------|
| **Rust** | 4,700+ | - | - | - | - | - |
| **Java** | 1,624 | 0.835ms | 10.19ms | 28.8% | 226 MB | 7.2 |
| **Go** | 1,624 | 0.855ms | 10.03ms | 31.8% | 18 MB | **92.6** |
| **Node.js** | 559 | 10.66ms | 53.24ms | 98.7% | 110 MB | 5.1 |
| **Python** | 292 | 26.45ms | 73.23ms | 93.9% | 98 MB | 3.0 |

**Key findings**:
- Go provides the optimal balance for cloud-native production -- 12.8x more memory efficient than Java with equivalent throughput
- Rust (`rmcp` SDK) achieves 4,700+ QPS native, nearly 3x Go/Java
- Python is unsuitable for anything above low-traffic scenarios

([Shuttle: Rust MCP Comparison](https://www.shuttle.dev/blog/2025/09/15/mcp-servers-rust-comparison))

### Stateless vs Stateful Architecture

**Build stateless whenever possible.** "Any server instance can handle any request."

| Approach | Pros | Cons | Best For |
|----------|------|------|----------|
| **Stateless** | Unlimited horizontal scaling, serverless-compatible | Must externalize all state | Lambda, auto-scaling |
| **Stateful + Redis** | Richer sessions, lower per-request overhead | Requires Redis infrastructure | Container-based (ECS, K8s) |
| **Stateful + Sticky** | Simplest implementation | Limited scaling, SPOF per session | Development only |

**The biggest scaling bottleneck today**: The official MCP SDKs (TypeScript, Python) store session state in-process memory only with no native support for Redis/DynamoDB externalization. You must build your own Redis pub/sub layer or accept sticky sessions.

([AWS Serverless MCP Architecture](https://deepwiki.com/aws-samples/sample-serverless-mcp-servers/1.1-stateful-vs.-stateless-architecture), [Python SDK Issue #880](https://github.com/modelcontextprotocol/python-sdk/issues/880))

### Connection Management

- Set **10-15 connections per CPU core** (4-core server handles 40-60 connections)
- Session isolation is critical: each session needs its own memory space
- Use Redis for distributed session storage
- Connection pooling for downstream resources (max 20 connections, health checks every 30s)

### Load Balancing (4 strategies ranked)

1. **Round-Robin**: Simple, equal traffic, ignores node performance
2. **Weighted Response Time**: Routes more to faster nodes (best general-purpose)
3. **Content-Aware Routing**: Analyzes request content for specialized routing
4. **Session-Affinity (Sticky)**: Required when state can't be externalized

**Microsoft MCP Gateway** is the most mature session-aware routing solution for Kubernetes.

([The New Stack: Load Balancing Streamable MCP](https://thenewstack.io/scaling-ai-interactions-how-to-load-balance-streamable-mcp/), [Microsoft MCP Gateway](https://microsoft.github.io/mcp-gateway/))

### Multi-Tenant Design

| Pattern | Isolation | Cost | Best For |
|---------|-----------|------|----------|
| **Dedicated Instance** | Maximum | High | Healthcare, finance, strict compliance |
| **Pooled Multi-Tenant** | Shared + RBAC + RLS | Low | Cost-efficient deployments |
| **Hybrid** | Per-customer + per-user RBAC | Balanced | B2B SaaS |

Data isolation safeguards: row-level security with tenantId/userId filters, namespaced vector indexes per tenant, document ACLs, prompt-time parameter validation, output filtering to redact PII.

([Bix Tech: Multi-User MCP Agents](https://bix-tech.com/building-multi-user-ai-agents-with-an-mcp-server-architecture-security-and-a-practical-blueprint/))

### Concurrency Models for MCP Servers

MCP servers are fundamentally I/O-bound -- waiting on database queries, external API calls, and LLM responses. The concurrency model you choose determines how many simultaneous users your server can handle.

#### Model Comparison

| Model | Memory Per Task | CPU Utilization | Best For | Used By |
|-------|-----------------|-----------------|----------|---------|
| **Async/Await (Event Loop)** | KB per task | Single core (typical) | I/O-heavy, high connection count | Python (asyncio), Node.js (libuv) |
| **Goroutines (CSP)** | ~2 KB per goroutine | All cores | Balanced I/O + CPU, simplest scaling | Go (mcp-go) |
| **Work-Stealing Async** | ~64 bytes per task | All cores | Maximum throughput, zero-cost abstractions | Rust (Tokio + rmcp) |
| **Virtual Threads** | ~1 KB per thread | All cores | Legacy codebases, I/O-bound Java | Java 21+ (Project Loom) |
| **Thread Pool** | ~2 MB per thread | All cores | CPU-intensive work alongside I/O | Java (traditional), .NET |
| **Actor Model** | KB per actor | All cores | Distributed, fault-tolerant systems | Elixir/Erlang, Akka |

For JSON-RPC/MCP servers, **async/await or goroutines provide the optimal balance** between simplicity, memory efficiency, and throughput. Thread-per-request models waste memory on I/O waits. Actor models add complexity rarely needed for tool-serving. ([Hakia Concurrency Models](https://www.hakia.com/engineering/concurrency-models/))

#### Language-Specific Concurrency Patterns

**Python (asyncio + FastMCP)**

Python MCP servers run on asyncio with a single event loop per process. The GIL prevents true parallel CPU execution, but async/await enables I/O concurrency -- while one tool handler awaits a database response, the event loop processes other requests.

```python
@mcp.tool(task=True)  # task=True enables background execution
async def process_files(files: list[str], progress: Progress = Progress()) -> str:
    await progress.set_total(len(files))
    for file in files:
        await progress.set_message(f"Processing {file}")
        # event loop handles other requests during await
        result = await fetch_data(file)
        await progress.increment()
    return f"Processed {len(files)} files"
```

Production scaling requires **multi-process deployment** to use multiple CPU cores:

```bash
uvicorn server:app --workers 4 --loop uvloop --http httptools
```

Worker sizing formula: `(2 * CPU_cores) + 1` for I/O-bound workloads. Each worker loads the full application into memory -- 4 workers at 150 MB each = 600 MB baseline. Modern async workloads often need fewer workers than traditional WSGI; fewer workers plus async concurrency often outperforms many synchronous workers. ([FastMCP Background Tasks](https://gofastmcp.com/servers/tasks), [Uvicorn Deployment](https://www.uvicorn.org/deployment/), [FastMCP Deep Dive](https://blog.devgenius.io/fastmcp-deep-dive-building-high-performance-ai-tooling-servers-with-model-context-protocol-36f724576bc0))

**Node.js (TypeScript SDK + libuv)**

The TypeScript MCP SDK leverages Node.js's single-threaded event loop. libuv handles async I/O through OS-level mechanisms (epoll on Linux, kqueue on macOS) and maintains a thread pool (default 4 threads) for operations that can't be made async at the OS level (DNS lookups, filesystem I/O).

While a tool handler awaits a database query or external API response, the event loop switches to processing another tool request. This is ideal for I/O-intensive operations. Node.js can handle 10,000+ concurrent connections on a single thread this way.

For CPU-intensive work, use `worker_threads` to avoid blocking the event loop. Scale horizontally with Node.js cluster module or multiple container instances. ([Node.js Event Loop](https://nodejs.org/en/learn/asynchronous-work/event-loop-timers-and-nexttick), [MCP TypeScript SDK](https://github.com/modelcontextprotocol/typescript-sdk))

**Go (mcp-go + goroutines)**

Go's goroutines are the most natural fit for MCP servers. Each incoming connection spawns a goroutine (~2 KB stack, dynamically growing), and Go's runtime multiplexes thousands of goroutines onto a small number of OS threads. No explicit thread pool configuration is needed.

```go
// Thread-safe session state with read-write locks
type UserSession struct {
    mu   sync.RWMutex
    data map[string]interface{}
}
```

mcp-go supports `WithMaxConcurrentTasks` to limit concurrent running tasks. If not specified or set to 0, there is no limit. Long-running requests should be handled in separate goroutines to keep the server responsive.

Go delivers 1,624 RPS with only 18 MB memory -- **92.6 RPS/MB**, the best efficiency ratio of any runtime. ([mcp-go](https://github.com/mark3labs/mcp-go), [Go MCP Guide](https://mcpcat.io/guides/building-mcp-server-go/), [TM Dev Lab Benchmark](https://www.tmdevlab.com/mcp-server-performance-benchmark.html))

**Rust (rmcp + Tokio)**

RMCP integrates with Tokio's work-stealing async runtime. Tokio tasks are ~64 bytes each (vs. 2 KB for goroutines, 2 MB for OS threads). The runtime automatically distributes work across CPU cores.

```rust
// Tokio full features: scheduler, I/O driver, timer, net
// tokio = { version = "1.35", features = ["full"] }

// Arc<Mutex<>> for shared state across async tasks
cache: Arc<Mutex<std::collections::HashMap<String, WeatherData>>>

// Proper async locking -- yields to runtime while waiting
let mut cache = self.cache.lock().await;
// Drop lock before long operations to avoid holding it
drop(cache);
```

Tokio's I/O driver uses epoll/kqueue/IOCP underneath. Rust's ownership system prevents data races at compile time. Default worker thread count = CPU core count. Achieves 4,700+ QPS -- nearly 3x Go/Java. ([rmcp](https://docs.rs/rmcp/latest/rmcp/), [Rust MCP Guide](https://mcpcat.io/guides/building-mcp-server-rust/), [Tokio Runtime](https://docs.rs/tokio/latest/tokio/runtime/index.html))

**Java (Virtual Threads + Spring Boot)**

Java 21's Project Loom virtual threads are managed by the JVM, not the OS. Applications can create millions of virtual threads without significant overhead. Virtual threads map multiple concurrent I/O operations to a single OS thread without blocking.

Thread pool configuration for MCP servers:

| Parameter | Value | Rationale |
|-----------|-------|-----------|
| Core threads | CPU count | Baseline for CPU-bound work |
| Max threads | 2x CPU count | I/O-bound operations benefit from higher concurrency |
| Queue size | 1,000 requests | Bounded queue prevents memory exhaustion |
| Request timeout | 5,000 ms | Prevents indefinite resource holding |
| Backpressure policy | CallerRunsPolicy | Throttles producers when queue is full |

Virtual threads excel in I/O-bound, high-concurrency environments (MCP's primary workload) but offer minimal benefit for CPU-intensive work. ([Java Virtual Threads](https://medium.com/@gangoladeepa/java-virtual-threads-project-loom-structured-concurrency-the-future-of-high-performance-7af16c553e1e), [Microsoft MCP Scaling](https://deepwiki.com/microsoft/mcp-for-beginners/6.4-scaling-and-load-balancing))

#### Session Isolation Under Concurrency

When many users connect simultaneously, each session must be fully isolated:

- **State isolation**: Each session gets its own memory space for conversation history, tool permissions, and intermediate results
- **Session manager pattern**: Maps unique session IDs to isolated state containers, preventing data leakage between users
- **Never use global variables**: "Your tools will be called by different users" -- treat session objects like stateful infrastructure
- **Context preservation**: Sessions survive between requests without mixing data between clients

FastMCP manages this automatically -- each client gets its own isolated session with independent authentication state, logging levels, and client capabilities.

**Real-world failure**: When Asana launched their MCP integration in June 2025, cached responses failed to re-verify tenant context on subsequent requests, causing Customer A's cached data to become visible to Customer B. Session isolation is NOT guaranteed by the MCP protocol -- it is an implementation responsibility.

**Semaphore-based concurrency limiting**: The MCP SDK has no built-in backpressure. Cap concurrent tool executions yourself:

```python
semaphore = asyncio.Semaphore(max_concurrent_tools)

async def handle_tool_call(request):
    async with semaphore:
        return await execute_tool(request)
```

([NearForm MCP Tips](https://nearform.com/digital-community/implementing-model-context-protocol-mcp-tips-tricks-and-pitfalls/), [FastMCP Sessions](https://deepwiki.com/punkpeye/fastmcp/6-sessions-and-client-interaction), [StackOne: MCP What's Broken](https://www.stackone.com/blog/mcp-where-its-been-where-its-going))

#### Connection Multiplexing (Streamable HTTP)

Streamable HTTP implements multiplexing at the **application layer** using session identifiers. The server acts as a multiplexer -- taking concurrent session requests and serializing access to underlying resources while maintaining the illusion of dedicated access for each client.

Key architecture:
- **Single endpoint** (`/mcp`): All traffic routes through one URL, differentiated by HTTP method (POST, GET, DELETE) and `Mcp-Session-Id` header
- **Persistent connections**: One socket, many messages. Eliminates handshake overhead and TCP slow-start for each operation
- **SSE upgrade**: POST requests can upgrade to Server-Sent Events for long-running operations. GET opens dedicated notification streams
- **Resumability**: Clients reconnect using `Last-Event-ID` header to recover missed messages
- **Performance**: 290-300 RPS at high concurrency vs SSE's 29-36 RPS limit. Response times of 1-7 ms under normal loads with 100% completion rates

Unlike HTTP/2 which multiplexes at the protocol level, MCP multiplexes at the application layer by tagging each message with a session identifier.

**Envoy AI Gateway** (v0.4.0+) implements MCP-aware proxying with stateless session encoding -- upstream session information is encrypted into the client session ID so any gateway replica can handle requests without shared state. It merges SSE streams from multiple MCP backends into a single client stream, with ~1-2 ms latency overhead per session. Full Envoy networking stack: connection management, load balancing, circuit breaking, rate-limiting, and observability built in.

([Streamable HTTP Architecture](https://thenewstack.io/how-mcp-uses-streamable-http-for-real-time-ai-tool-interaction/), [MCP Framework HTTP Stream](https://mcp-framework.com/docs/Transports/http-stream-transport/), [MCP Connection Options](https://harrylaou.com/llm/understanding-mcp-connection-options-technical-deep-dive/), [Envoy AI Gateway MCP](https://aigateway.envoyproxy.io/blog/mcp-implementation/))

#### Backpressure and Rate Limiting

When downstream components (databases, external APIs) can't keep up with incoming requests:

**Bounded queues**: Fixed-capacity buffers with overflow policies (drop, queue, or reject). Prevents unbounded memory growth. Java MCP servers use `CallerRunsPolicy` -- when the queue is full, the caller's thread executes the task, naturally throttling the producer.

**Exponential backoff with jitter**: Start at 1,000 ms, double on each failure, cap at 60 seconds. Reset after success. Essential for retrying failed external API calls without overwhelming the target.

**Rate limiting per client**: Enforce per-client request limits (e.g., 100 requests/minute baseline). FastMCP 2.9 introduced middleware for intercepting and controlling server operations including rate limiting.

**Circuit breaker**: Track error rates per downstream dependency. Open the circuit (reject fast) when errors exceed threshold. Half-open periodically to test recovery. Prevents cascading failures.

**Temporal workflows**: For complex multi-step operations, Temporal provides durable execution with built-in retry policies, backpressure management, and observability. MCP tool calls wrapped as Temporal Activities get automatic retries, timeout handling, and failure recovery. ([Backpressure in Async AI](https://dasroot.net/posts/2026/02/managing-backpressure-async-ai-services/), [FastMCP Middleware](https://gofastmcp.com/updates))

#### MCP Tasks: Native Async Operations (Spec 2025-11-25)

The Tasks primitive transforms MCP from synchronous tool calls into a **call-now, fetch-later protocol**. This is the MCP-native way to handle concurrency without inventing side channels.

**Task lifecycle**: `working` -> `input_required` | `completed` | `failed` | `cancelled`

**Two fetch mechanisms**:
- `tasks/get`: Returns current metadata and status (non-blocking poll)
- `tasks/result`: Blocking call that waits until the task finishes

**Parallel execution**: Fire off multiple tasks, keep their `taskId`s, and poll each independently. The requestor decides when to create tasks and how to orchestrate them; the receiver decides which requests are task-augmentable.

**FastMCP's distributed task scheduler** (powered by Docket, which processes millions of concurrent tasks daily in Prefect Cloud):

```python
# In-memory backend (single process, development)
mcp = FastMCP("server", task_backend="memory://")

# Redis backend (distributed, production)
mcp = FastMCP("server", task_backend="redis://localhost:6379/0")

# Scale workers horizontally
# fastmcp tasks worker server.py
# FASTMCP_DOCKET_CONCURRENCY=20
```

Multiple workers pull from the same queue, distributing load across processes or machines. Security: task IDs are capability handles bound to authorization contexts -- only the original caller can retrieve, cancel, or list their tasks. ([WorkOS MCP Async Tasks](https://workos.com/blog/mcp-async-tasks-ai-agent-workflows), [FastMCP Tasks](https://gofastmcp.com/servers/tasks), [MCP Async Discussion #491](https://github.com/modelcontextprotocol/modelcontextprotocol/discussions/491))

#### Kernel-Level I/O for Maximum Performance

The OS-level I/O mechanism determines the ceiling for concurrent connection handling:

| Mechanism | Model | Throughput | Used By |
|-----------|-------|------------|---------|
| **epoll** (Linux) | Readiness-based | High | Node.js (libuv), Go runtime, Tokio (default) |
| **kqueue** (macOS/BSD) | Readiness-based | High | Same runtimes on macOS |
| **io_uring** (Linux 5.1+) | Completion-based | Higher for batched I/O | Tokio (optional), custom Rust/C servers |
| **IOCP** (Windows) | Completion-based | High | .NET, Tokio on Windows |

**epoll** notifies when a file descriptor is ready for I/O. The application then performs the actual read/write. Multiple syscalls per operation.

**io_uring** uses shared ring buffers between userspace and kernel, allowing thousands of I/O operations with a single `io_uring_enter()` call or none at all in polling mode. Benefits are most pronounced with batched operations (e.g., 16+ operations reduce CPU cycles per operation by ~5-6%). io_uring outperforms epoll for request/response (ping-pong) workloads but can be slower for streaming workloads.

For most MCP servers, the runtime's default (epoll/kqueue) is sufficient. io_uring is worth exploring only for extreme throughput requirements (10,000+ concurrent connections with batched downstream I/O). ([epoll vs io_uring](https://www.alibabacloud.com/blog/io-uring-vs--epoll-which-is-better-in-network-programming_599544), [io_uring Notes](https://iafisher.com/notes/2025-10-epoll-io-uring), [io_uring for DBMSs](https://arxiv.org/html/2512.04859v2))

#### Horizontal Scaling Architecture

For production MCP deployments handling thousands of concurrent users:

```
                    ┌─────────────────┐
                    │  Load Balancer  │
                    │ (weighted resp) │
                    └────────┬────────┘
                             │
              ┌──────────────┼──────────────┐
              │              │              │
        ┌─────┴─────┐ ┌─────┴─────┐ ┌─────┴─────┐
        │ MCP Node 1│ │ MCP Node 2│ │ MCP Node N│
        │ (stateless)│ │ (stateless)│ │ (stateless)│
        └─────┬─────┘ └─────┬─────┘ └─────┬─────┘
              │              │              │
              └──────────────┼──────────────┘
                             │
                    ┌────────┴────────┐
                    │  Redis Cluster  │
                    │ (sessions +     │
                    │  task queue)    │
                    └─────────────────┘
```

**Node registration**: Each instance generates a UUID, registers in Redis (`mcp:nodes` set), creates a hash entry with metadata, and starts a heartbeat task (every 5 seconds reporting `active_requests`, `max_concurrent_requests`).

**Health-aware routing**: Nodes exceeding response time thresholds are marked degraded. High error rates trigger removal. Stale heartbeats indicate failure. Overloaded nodes receive reduced traffic.

**Minimum 3 instances** for high availability. Enable connection pooling for Redis and downstream databases. Implement graceful shutdown handlers so in-flight requests complete before termination. Recycle long-running instances every ~24 hours to prevent memory leaks. ([Microsoft MCP Scaling](https://deepwiki.com/microsoft/mcp-for-beginners/6.4-scaling-and-load-balancing), [MCPcat Multiple Connections](https://mcpcat.io/guides/configuring-mcp-servers-multiple-simultaneous-connections/))

### Production Performance Targets

| Metric | Target |
|--------|--------|
| Throughput | >1,000 RPS per instance |
| P50 latency | <100ms (simple operations) |
| P99 latency | <500ms (complex operations) |
| Error rate | <0.1% under normal conditions |
| Availability | >99.9% uptime |

---

## 6. Security

### Authentication and Authorization

- **OAuth 2.1 with PKCE** is mandatory for all remote HTTP-based MCP servers (since March 2025)
- Servers are classified as **OAuth 2.0 Resource Servers** and must serve `/.well-known/oauth-protected-resource` metadata
- **Resource Indicators** (RFC 8707): Tokens scoped tightly to the specific MCP server
- **CIMD** (Nov 2025): Replaces Dynamic Client Registration. Client IDs are URLs pointing to self-hosted metadata documents. Trust anchored in DNS/HTTPS -- eliminates registration friction at scale
- **Machine-to-Machine OAuth** (SEP-1046): `client_credentials` flow for headless automation
- **Cross App Access (XAA)** (SEP-990): Enterprise IdP as central policy enforcement point

### Current Ecosystem Reality

- 88% of servers require credentials
- **53% rely on insecure static secrets** (API keys, PATs)
- Only **8.5% use OAuth**

([Auth0 MCP Spec Updates](https://auth0.com/blog/mcp-specs-update-all-about-auth/), [Astrix State of MCP Security 2025](https://astrix.security/learn/blog/state-of-mcp-server-security-2025/), [Aaron Parecki: MCP Auth Update](https://aaronparecki.com/2025/11/25/1/mcp-authorization-spec-update))

### Input Validation

- Enforce strict JSON Schema validation for all tool inputs
- Reject unknown fields and malformed requests
- Apply `additionalProperties: false` in schemas
- Implement context-based sanitization and semantic validation

### Key Attack Vectors

1. **Confused Deputy**: MCP proxy servers must implement per-client consent before forwarding to third-party auth
2. **Token Passthrough**: Explicitly forbidden -- servers must not accept tokens not issued for them
3. **SSRF**: Block private IP ranges, enforce HTTPS, validate redirect targets, use egress proxies (e.g., [Stripe Smokescreen](https://github.com/stripe/smokescreen))
4. **Session Hijacking**: Use secure non-deterministic session IDs, bind to user-specific info
5. **Local Server Compromise**: Show exact commands before execution, require explicit consent, sandbox with least privilege
6. **Scope Inflation**: Implement progressive, least-privilege scope model with minimal initial scopes and incremental elevation

([MCP Security Best Practices - Official Spec](https://modelcontextprotocol.io/specification/draft/basic/security_best_practices), [Akto MCP Security 2026](https://www.akto.io/blog/mcp-security-best-practices))

### Containerization

Run MCP servers in **Docker containers** with CPU/memory caps, read-only filesystems, and least-privilege. Docker's MCP Toolkit provides container isolation, signed image verification, SBOMs, and an intelligent gateway for blocking malicious requests. Containerized MCP servers saw a **60% reduction in deployment-related support tickets**.

([Docker MCP Security](https://www.docker.com/blog/mcp-security-explained/), [Docker MCP Toolkit](https://www.docker.com/blog/mcp-toolkit-mcp-servers-that-just-work/))

---

## 7. Error Handling and Resilience

### Three-Tier Error Model

1. **Transport-Level**: Network timeouts, broken pipes (handled by transport layer)
2. **Protocol-Level**: JSON-RPC 2.0 violations (-32700 Parse Error, -32601 Method Not Found, -32602 Invalid Params, -32800 to -32802 MCP-specific)
3. **Application-Level**: Business logic failures -- your primary responsibility

### The `isError` Flag Pattern

Tool errors go in the **result object**, not as protocol errors. This lets the LLM see and handle the error:

```python
return CallToolResult(
    isError=True,
    content=[TextContent(text="Rate limited. Retry after 30 seconds.")]
)
```

The agent, not the user, receives your error messages. There is no guarantee the error will be passed back to the user. Error messages must help the agent decide what to do next.

### Error Message Design

- Be specific and actionable: "Invalid date format. Use YYYY-MM-DD." not "Bad input"
- Provide **error-guided recovery**: tell the agent what it can do next
- Include machine-readable `code`, user-safe `message`, and recovery `hints`
- Never expose system internals, credentials, or PII
- Validate early, catch specific exceptions first, log internally

### Resilience Patterns

1. **Retry with exponential backoff + jitter**: Only for idempotent operations, 3-5 max attempts
2. **Circuit breaker**: Closed -> Open (reject) -> Half-Open (test recovery)
3. **Graceful degradation**: Return cached data with freshness warnings
4. **Idempotency keys**: For create/update operations, store results keyed by client-provided IDs

### Logging

- Log to **stderr** (not stdout) when using stdio transport -- stdout is reserved for JSON-RPC
- Use structured JSON logging with correlation IDs
- Never log passwords, tokens, API keys, PII, or full payloads
- Separate debug mode: development gets stack traces, production gets safe messages

([MCPcat Error Handling Guide](https://mcpcat.io/guides/error-handling-custom-mcp-servers/), [BytePlus MCP Idempotency](https://www.byteplus.com/en/topic/542207))

---

## 8. Token Optimization

Every tool definition consumes context window tokens on every LLM reasoning cycle. 50+ MCP tools can consume ~72K tokens just for definitions.

### Three Major Approaches

#### Dynamic Toolsets (Speakeasy)

Expose just three meta-tools: `search_tools`, `describe_tools`, `execute_tool`. The agent discovers and loads schemas on demand.

- **96-97% input token reduction** for simple tasks
- 100% success rate across 40-400 tool sets
- Trade-off: 2-3x more tool calls (50% more execution time)

([Speakeasy: 100x Token Reduction](https://www.speakeasy.com/blog/how-we-reduced-token-usage-by-100x-dynamic-toolsets-v2))

#### Code Mode (Cloudflare)

Convert MCP tools into a TypeScript API. The LLM writes code that calls the API, executing in a sandboxed isolate.

- **99.9% token reduction** (1,000 tokens for entire Cloudflare API vs 1.17M)
- Agent chains multiple calls in code, reading only final results
- No client modifications needed for server-side Code Mode
- "LLMs have seen a lot of code. They have not seen a lot of tool calls."

([Cloudflare Code Mode](https://blog.cloudflare.com/code-mode/))

#### Schema Optimization

- Strip descriptions to essentials, use shorthand notations
- JSON `$ref` references for schema deduplication (SEP-1576)
- Adaptive optional schema fields
- Embedding-based similarity matching for tool retrieval

([The New Stack: 10 Strategies for Token Bloat](https://thenewstack.io/how-to-reduce-mcp-token-bloat/), [SEP-1576](https://github.com/modelcontextprotocol/modelcontextprotocol/issues/1576))

---

## 9. Observability and Monitoring

MCP servers are "black boxes" without observability. OpenTelemetry is the natural fit. FastMCP includes native OTel instrumentation.

### Three-Pillar Approach

**Distributed Tracing**: W3C Trace Context propagation. Trace structure: Agent prompt handling -> Tool invocation -> External API call. Attach attributes: `tool.name`, `input_size`, `output_size`, `http.status_code`, `error.type`.

**Metrics**: Tool invocation duration (histogram for p50/p95/p99), invocation count (hotspot identification), error rates per tool, token usage (cost optimization), active sessions and resource utilization.

**Structured Logging**: JSON-formatted with correlation IDs. GZip compression reduces logging bandwidth 60-80%.

### Production Monitoring

- Separate liveness vs readiness health probes
- Error rate alerts with anomaly detection
- Per-tenant metrics: active sessions, request rates, error rates
- Capacity planning from utilization trends

| Metric | Target |
|--------|--------|
| P95 latency | < 500ms |
| Error rate | < 1% |
| CPU utilization | < 70% |
| Memory usage | < 80% |
| Cache hit rate | > 80% |
| Queue depth | < 100 |

([SigNoz: MCP Observability with OTel](https://signoz.io/blog/mcp-observability-with-otel/), [MCPcat: Monitor MCP with OpenTelemetry](https://mcpcat.io/guides/monitor-mcp-performance-opentelemetry/), [FastMCP OpenTelemetry](https://gofastmcp.com/servers/telemetry))

---

## 10. Production Deployment Patterns

### Containerized (Recommended Default)

Docker containers with CPU/memory caps, read-only filesystems, signed image verification, and SBOMs. Horizontal pod autoscaling and rolling updates.

### Serverless Options

| Platform | Strengths | Limitations |
|----------|-----------|-------------|
| **AWS Lambda** | Auto-scale, pay-per-use | Cold starts, limited observability |
| **Google Cloud Run** | Container-based auto-scaling | - |
| **Cloudflare Workers** | Edge deployment, near-zero cold starts | 50ms CPU limit, no native binaries |

### Reference Architectures

**AWS**: ECS Fargate (multi-AZ) + ALB + CloudFront + Cognito (OAuth) + WAF + DynamoDB for sessions. ([AWS Guidance](https://aws.amazon.com/solutions/guidance/deploying-model-context-protocol-servers-on-aws/))

**Kubernetes**: Microsoft MCP Gateway reverse proxy + AKS StatefulSets + Azure Entra ID + HPA on CPU/memory. ([Microsoft MCP Gateway](https://microsoft.github.io/mcp-gateway/))

**Fly.io**: Per-user VMs that auto-stop when idle, `fly-replay` header for session routing. ([Fly.io Remote MCP](https://fly.io/docs/blueprints/remote-mcp-servers/))

### MCP Gateways

An MCP gateway is a session-aware reverse proxy that fronts many MCP servers behind one endpoint, adding routing, centralized auth, policy enforcement, and observability. Gartner identifies three patterns:

1. **Aggregator**: Clients see a unified tool set from multiple servers
2. **Proxy**: One-to-one mapping with cross-cutting concerns (SSL, auth, logging)
3. **Composite**: Mix of aggregator and proxy for geo-distributed environments

([Best MCP Gateways 2025](https://www.lunar.dev/post/best-mcp-gateways-of-2025-why-lunar-dev-leads-the-pack), [MCP Server vs Gateway](https://skywork.ai/blog/mcp-server-vs-mcp-gateway-comparison-2025/))

### Production Checklist

1. Containerize with Docker (CPU/memory limits, read-only FS)
2. Implement health checks (liveness + readiness separation)
3. Set up structured logging with correlation IDs
4. Add OpenTelemetry tracing
5. Configure OAuth 2.1 for remote access
6. Implement rate limiting per client
7. Validate all inputs against JSON Schema
8. Use connection pooling for downstream resources
9. Set up CI/CD pipeline with automated testing
10. Deploy behind a gateway for multi-server setups

---

## 11. Testing and Evaluation

### MCP Inspector

Launch with `npx @modelcontextprotocol/inspector`. Opens at `http://localhost:6274`. Visual interface for testing tools, resources, and prompts with real-time request/response logging and protocol compliance checking. ([MCP Inspector](https://modelcontextprotocol.io/docs/tools/inspector))

### Evaluation-Driven Development (Anthropic)

1. **Build prototype** quickly, test manually to find rough edges
2. **Create evaluation suite** with realistic multi-step tasks (potentially dozens of tool calls)
3. **Pair prompts with verifiable outcomes** using flexible verifiers (Claude can judge responses, not just exact string matching)
4. **Run evaluations programmatically** -- track runtime, tool call count, token consumption, error rates
5. **Collaborate with agents**: concatenate evaluation transcripts and have Claude analyze them for contradictory descriptions and confusing schemas
6. **Use held-out test sets** to prevent overfitting

([Anthropic Engineering: Writing Tools for Agents](https://www.anthropic.com/engineering/writing-tools-for-agents))

### Multi-Layer Testing

- **Unit tests**: Individual component validation
- **Integration tests**: Component interaction verification
- **Contract tests**: MCP protocol compliance
- **Load tests**: Concurrent request handling (99%+ success targets)
- **End-to-end tests**: Complete workflow validation
- **Chaos engineering**: Database failure recovery, network partitions, memory pressure

---

## 12. Common Anti-Patterns

1. **Wrapping REST APIs directly as MCP tools**: REST APIs are for human developers who excel at selective discovery. Agents must process every tool definition simultaneously, inflating context costs.
2. **Tool proliferation**: More tools does not mean better outcomes. Agent performance degrades with more tools.
3. **Context pollution**: Bloated tool catalogs create hallucinations. Agents confuse similar endpoints or invent endpoints by pattern matching.
4. **Returning raw technical data**: UUIDs, internal identifiers, and technical metadata rather than semantically meaningful information.
5. **Returning "not found" text**: Causes LLMs to ignore subsequent data in the response.
6. **Overlapping tool functionality**: Tools with unclear boundaries cause suboptimal selection.
7. **Monolithic servers**: A single server handling databases, files, APIs, and email simultaneously.
8. **Human-oriented error messages**: The agent needs actionable recovery guidance, not friendly prose.
9. **Loading all tool schemas upfront**: Token-inefficient. Use progressive disclosure or dynamic toolsets.
10. **Ignoring the token budget**: Every tool definition consumes context window space. Treat it as a first-class resource.

([Stop Converting REST APIs to MCP](https://www.jlowin.dev/blog/stop-converting-rest-apis-to-mcp), [Klavis: Less is More](https://www.klavis.ai/blog/less-is-more-mcp-design-patterns-for-ai-agents))

---

## 13. Enterprise Features (Spec 2025-11-25)

The November 2025 specification closes the production gap with:

- **Async Tasks**: "call-now, fetch-later" for long-running operations (15-minute reports, 2-hour compliance scans)
- **CIMD**: Replaces Dynamic Client Registration with decentralized trust model
- **Machine-to-Machine OAuth**: Headless automation without human users
- **Cross App Access (XAA)**: Enterprise IdP as central policy enforcement
- **Sampling with Tools (SEP-1577)**: MCP servers can act as agentic systems with their own reasoning
- **Formal Extensions Framework**: Community-driven innovation via SEPs without vendor lock-in

([MCP Enterprise Readiness](https://subramanya.ai/2025/12/01/mcp-enterprise-readiness-how-the-2025-11-25-spec-closes-the-production-gap/), [WorkOS MCP 2025-11-25 Update](https://workos.com/blog/mcp-2025-11-25-spec-update))

---

## 14. Future Roadmap (June 2026 Spec Target)

The Transport Working Group's vision: "Agentic applications are stateful, but the protocol itself doesn't need to be."

- **Stateless protocol**: Per-request capabilities instead of initialize handshake
- **Explicit sessions**: Cookie-like mechanism at data model layer (not transport)
- **Server Cards**: `/.well-known/mcp.json` for pre-connection discovery
- **HTTP-native routing**: Method/tool names in HTTP paths/headers (no JSON-RPC parsing for load balancers)
- **Subscription-based notifications**: Clients open dedicated streams with TTL caching and ETags
- **Elicitation redesign**: Return requests instead of suspending execution
- **gRPC as official transport option**

([Future of MCP Transports](http://blog.modelcontextprotocol.io/posts/2025-12-19-mcp-transport-future/))

---

## Decision Matrices

### Language Selection

| Language | Best For | Avoid When |
|----------|----------|------------|
| **Go** | Cloud-native production, cost-optimized K8s | - |
| **Rust** | Maximum throughput (4,700+ QPS) | Development velocity matters most |
| **Java** | Lowest latency in resource-rich environments | Memory-constrained deployments |
| **Node.js** | <500 RPS with JavaScript teams | High-throughput production |
| **Python** | Development, testing, prototyping | Any production load >low traffic |

### Deployment Topology

| Scenario | Transport | Deployment | State |
|----------|-----------|------------|-------|
| Local CLI tool | stdio | Workstation | Stateful (in-process) |
| IDE plugin | stdio | Workstation | Stateful |
| SaaS integration | Streamable HTTP | Remote/Cloud | Stateless |
| Team-shared database | Streamable HTTP | Managed-Shared | Stateless |
| Browser automation | Streamable HTTP | Managed-Dedicated | Stateful |
| Enterprise internal | Streamable HTTP | On-premises + Tunnel | Either |
| Multi-server orchestration | Streamable HTTP | Gateway/Aggregator | Stateless |
| High-throughput production | Streamable HTTP | Cloud Run / ECS | Stateless |

---

## Source Index

### Official Documentation
- [MCP Architecture Overview](https://modelcontextprotocol.io/docs/learn/architecture)
- [MCP Specification 2025-11-25](https://modelcontextprotocol.io/specification/2025-11-25)
- [MCP Security Best Practices](https://modelcontextprotocol.io/specification/draft/basic/security_best_practices)
- [MCP Tools Specification](https://modelcontextprotocol.io/specification/2025-06-18/server/tools)
- [MCP Transports Specification](https://modelcontextprotocol.io/specification/2025-06-18/basic/transports)
- [MCP Inspector](https://modelcontextprotocol.io/docs/tools/inspector)

### Anthropic Engineering
- [Introducing MCP](https://www.anthropic.com/news/model-context-protocol)
- [Writing Effective Tools for Agents](https://www.anthropic.com/engineering/writing-tools-for-agents)
- [Code Execution with MCP](https://www.anthropic.com/engineering/code-execution-with-mcp)

### Transport and Protocol Evolution
- [Future of MCP Transports (Dec 2025)](http://blog.modelcontextprotocol.io/posts/2025-12-19-mcp-transport-future/)
- [Why MCP Deprecated SSE](https://blog.fka.dev/blog/2025-06-06-why-mcp-deprecated-sse-and-go-with-streamable-http/)
- [Google gRPC for MCP (Feb 2026)](https://www.infoq.com/news/2026/02/google-grpc-mcp-transport/)
- [Aaron Parecki: MCP Auth Update (Nov 2025)](https://aaronparecki.com/2025/11/25/1/mcp-authorization-spec-update)

### Best Practice Guides
- [15 Best Practices for Production (The New Stack)](https://thenewstack.io/15-best-practices-for-building-mcp-servers-in-production/)
- [7 Best Practices for Scalable MCP (MarkTechPost, Jul 2025)](https://www.marktechpost.com/2025/07/23/7-mcp-server-best-practices-for-scalable-ai-integrations-in-2025/)
- [5 Best Practices (Snyk)](https://snyk.io/articles/5-best-practices-for-building-mcp-servers/)
- [MCP Best Practices 2026 (CData)](https://www.cdata.com/blog/mcp-server-best-practices-2026)
- [MCP Best Practices Architecture Guide](https://modelcontextprotocol.info/docs/best-practices/)

### Design Patterns
- [54 Patterns for Better MCP Tools (Arcade)](https://arcade.dev/blog/mcp-tool-patterns)
- [MCP Server Naming Conventions (Zazen Codes)](https://zazencodes.com/blog/mcp-server-naming-conventions)
- [Stop Converting REST APIs to MCP (Jeremiah Lowin)](https://www.jlowin.dev/blog/stop-converting-rest-apis-to-mcp)
- [Less is More: MCP Design Patterns (Klavis)](https://www.klavis.ai/blog/less-is-more-mcp-design-patterns-for-ai-agents)
- [IBM: MCP Architecture Patterns](https://developer.ibm.com/articles/mcp-architecture-patterns-ai-systems/)

### Performance, Scaling, and Concurrency
- [Multi-Language Performance Benchmark (TM Dev Lab)](https://www.tmdevlab.com/mcp-server-performance-benchmark.html)
- [Rust MCP Comparison (Shuttle, Sep 2025)](https://www.shuttle.dev/blog/2025/09/15/mcp-servers-rust-comparison)
- [Load Balancing Streamable MCP (The New Stack)](https://thenewstack.io/scaling-ai-interactions-how-to-load-balance-streamable-mcp/)
- [Microsoft MCP Gateway](https://microsoft.github.io/mcp-gateway/)
- [Configuring Multiple Connections (MCPcat)](https://mcpcat.io/guides/configuring-mcp-servers-multiple-simultaneous-connections/)
- [AWS Serverless MCP Architecture](https://deepwiki.com/aws-samples/sample-serverless-mcp-servers/1.1-stateful-vs.-stateless-architecture)
- [Python SDK Horizontal Scaling Issue #880](https://github.com/modelcontextprotocol/python-sdk/issues/880)
- [MCP Async Tasks (WorkOS)](https://workos.com/blog/mcp-async-tasks-ai-agent-workflows)
- [FastMCP Background Tasks](https://gofastmcp.com/servers/tasks)
- [FastMCP Deep Dive (Dev Genius)](https://blog.devgenius.io/fastmcp-deep-dive-building-high-performance-ai-tooling-servers-with-model-context-protocol-36f724576bc0)
- [FastMCP Sessions and Client Interaction](https://deepwiki.com/punkpeye/fastmcp/6-sessions-and-client-interaction)
- [FastMCP Middleware and Updates](https://gofastmcp.com/updates)
- [MCP Async Operations Discussion #491](https://github.com/modelcontextprotocol/modelcontextprotocol/discussions/491)
- [Streamable HTTP Real-Time Interaction (The New Stack)](https://thenewstack.io/how-mcp-uses-streamable-http-for-real-time-ai-tool-interaction/)
- [MCP Framework HTTP Stream Transport](https://mcp-framework.com/docs/Transports/http-stream-transport/)
- [MCP Connection Options Deep Dive (Harry Laou)](https://harrylaou.com/llm/understanding-mcp-connection-options-technical-deep-dive/)
- [MCP Implementation Tips (NearForm)](https://nearform.com/digital-community/implementing-model-context-protocol-mcp-tips-tricks-and-pitfalls/)
- [MCP Scaling and Load Balancing (Microsoft)](https://deepwiki.com/microsoft/mcp-for-beginners/6.4-scaling-and-load-balancing)
- [Backpressure in Async AI Services](https://dasroot.net/posts/2026/02/managing-backpressure-async-ai-services/)
- [Building MCP Servers in Rust (MCPcat)](https://mcpcat.io/guides/building-mcp-server-rust/)
- [Building MCP Servers in Go (MCPcat)](https://mcpcat.io/guides/building-mcp-server-go/)
- [mcp-go SDK](https://github.com/mark3labs/mcp-go)
- [Official Go SDK](https://github.com/modelcontextprotocol/go-sdk)
- [rmcp Rust SDK](https://docs.rs/rmcp/latest/rmcp/)
- [Tokio Async Runtime](https://docs.rs/tokio/latest/tokio/runtime/index.html)
- [MCP TypeScript SDK](https://github.com/modelcontextprotocol/typescript-sdk)
- [Uvicorn Production Deployment](https://www.uvicorn.org/deployment/)
- [Java Virtual Threads / Project Loom](https://medium.com/@gangoladeepa/java-virtual-threads-project-loom-structured-concurrency-the-future-of-high-performance-7af16c553e1e)
- [epoll vs io_uring (Alibaba Cloud)](https://www.alibabacloud.com/blog/io-uring-vs--epoll-which-is-better-in-network-programming_599544)
- [io_uring for High-Performance DBMSs](https://arxiv.org/html/2512.04859v2)
- [Concurrency Models Comparison (Hakia)](https://www.hakia.com/engineering/concurrency-models/)

### Token Optimization
- [100x Token Reduction (Speakeasy)](https://www.speakeasy.com/blog/how-we-reduced-token-usage-by-100x-dynamic-toolsets-v2)
- [Code Mode (Cloudflare)](https://blog.cloudflare.com/code-mode/)
- [10 Strategies for Token Bloat (The New Stack)](https://thenewstack.io/how-to-reduce-mcp-token-bloat/)
- [SEP-1576: Token Bloat Mitigation](https://github.com/modelcontextprotocol/modelcontextprotocol/issues/1576)

### Security
- [Auth0: MCP Spec Auth Updates (Jun 2025)](https://auth0.com/blog/mcp-specs-update-all-about-auth/)
- [State of MCP Security 2025 (Astrix)](https://astrix.security/learn/blog/state-of-mcp-server-security-2025/)
- [MCP Security Explained (Docker)](https://www.docker.com/blog/mcp-security-explained/)
- [Top MCP Security Best Practices (Akto)](https://www.akto.io/blog/mcp-security-best-practices)
- [Docker MCP Toolkit](https://www.docker.com/blog/mcp-toolkit-mcp-servers-that-just-work/)

### Features and Concepts
- [WorkOS MCP Features Guide](https://workos.com/blog/mcp-features-guide)
- [Beyond Tool Calling (Upsun)](https://devcenter.upsun.com/posts/mcp-interaction-types-article/)
- [MCP Architecture Deep Dive (Knit)](https://www.getknit.dev/blog/mcp-architecture-deep-dive-tools-resources-and-prompts-explained)

### Observability
- [MCP Observability with OTel (SigNoz)](https://signoz.io/blog/mcp-observability-with-otel/)
- [Monitor MCP with OpenTelemetry (MCPcat)](https://mcpcat.io/guides/monitor-mcp-performance-opentelemetry/)
- [FastMCP OpenTelemetry](https://gofastmcp.com/servers/telemetry)

### Enterprise and Deployment
- [MCP Enterprise Readiness (Subramanya, Dec 2025)](https://subramanya.ai/2025/12/01/mcp-enterprise-readiness-how-the-2025-11-25-spec-closes-the-production-gap/)
- [AWS Guidance for MCP Servers](https://aws.amazon.com/solutions/guidance/deploying-model-context-protocol-servers-on-aws/)
- [Remote MCP Servers (Fly.io)](https://fly.io/docs/blueprints/remote-mcp-servers/)
- [Deploying MCP Servers (Speakeasy)](https://www.speakeasy.com/mcp/deploying-mcp-servers)
- [Multi-User MCP Agents (Bix Tech)](https://bix-tech.com/building-multi-user-ai-agents-with-an-mcp-server-architecture-security-and-a-practical-blueprint/)
- [MCP Enterprise Governance (Tetrate)](https://tetrate.io/learn/ai/mcp/mcp-enterprise-deployment)
- [Error Handling Guide (MCPcat)](https://mcpcat.io/guides/error-handling-custom-mcp-servers/)
- [MCP Server vs Gateway (Skywork)](https://skywork.ai/blog/mcp-server-vs-mcp-gateway-comparison-2025/)
- [Best MCP Gateways 2025 (Lunar.dev)](https://www.lunar.dev/post/best-mcp-gateways-of-2025-why-lunar-dev-leads-the-pack)
- [Top MCP Servers 2026 (Intuz)](https://www.intuz.com/blog/best-mcp-servers)
- [How Microsoft Built the Learn MCP Server](https://devblogs.microsoft.com/engineering-at-microsoft/how-we-built-the-microsoft-learn-mcp-server/)

---

*Research conducted February 2026. 80+ sources from 2025-2026. All sources verified as active at time of research.*
