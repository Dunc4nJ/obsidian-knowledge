---
created: 2026-02-27
description: Browser Use moved from isolating code execution tools to isolating entire agents in Unikraft micro-VMs, with a stateless control plane holding all credentials and proxying every external call.
source: https://x.com/larsencc/status/2027225210412470668
type: framework
---

## Key Takeaways

There are two patterns for sandboxing agents that execute arbitrary code. Pattern 1 isolates the dangerous tool (code execution runs in a sandbox, the agent stays on your backend). Pattern 2 isolates the entire agent — it runs in a sandbox with zero secrets and communicates with the outside world through a control plane that holds all credentials. Browser Use started with Pattern 1 and moved to Pattern 2 because it makes the agent disposable: nothing worth stealing, nothing worth preserving. This aligns with the broader principle that [[agents need a database because stateless reasoning cores require stateful storage]] — the control plane and database hold the truth, while the agent itself is ephemeral.

The concrete implementation uses Unikraft micro-VMs in production (booting in under a second) and Docker containers in development, with a single config switch between them. The sandbox receives only three environment variables: a session token, a control plane URL, and a session ID. Additional hardening includes compiling Python to bytecode and deleting source files, dropping privileges after startup, and stripping environment variables from the process after reading them into memory.

The control plane acts as a stateless proxy for everything: LLM calls (where it reconstructs full conversation history from the database on each request), file sync via presigned S3 URLs, billing enforcement, and cost caps. This statelessness means [[seven runtime failures emerge when demo agents meet production distributed systems]] are mitigated by design — you can kill a sandbox and spin up a new one, and the conversation picks up where it left off.

The Gateway protocol abstracts the backend: in production a `ControlPlaneGateway` sends HTTP requests to the control plane; in local dev a `DirectGateway` calls LLMs directly. The agent code is identical in both environments. Scaling is independent per layer — more sandboxes via Unikraft, more control plane instances behind a load balancer.

The tradeoff is an extra network hop on every operation and three services instead of one, but in practice the latency is noise compared to LLM response times.

## External Resources

- [Unikraft Cloud](https://unikraft.cloud/) — micro-VM platform used for production sandboxing with scale-to-zero
- [Browser Use](https://browseruse.com/) — the agent platform described in this post

## Original Content

> @larsencc (Larsen Cundric) — Feb 27, 2026 — 29 likes, 6 retweets
>
> **How We Built Secure, Scalable Agent Sandbox Infrastructure**
>
> From AWS Lambda to Unikraft micro-VMs with a control plane architecture.
>
> We run millions of web agents at Browser Use. We started with browser-only agents on AWS Lambda, where each invocation is isolated, scaling is instant, and there are no secrets to worry about.
>
> Then we added code execution. Agents could write and run Python, execute shell commands, create files. We built this as an isolated sandbox the agent called as a tool. Security was fine: the code ran in the sandbox, not on the backend.
>
> But the agent loop still ran on the same backend as our REST API. Redeploy? All running agents die. Memory-hungry agent? The API slows down. Two fundamentally different workloads sharing the same process.
>
> **The two patterns:** Pattern 1 isolates the tool (sandbox for code execution, agent on your backend). Pattern 2 isolates the agent (entire agent in a sandbox, talks to outside world through a control plane with all credentials).
>
> **The sandbox:** Same container image everywhere. Unikraft micro-VM in production (boots in under a second), Docker container in dev/evals. Three env variables only: SESSION_TOKEN, CONTROL_PLANE_URL, SESSION_ID. Scale-to-zero built in. Hardening: bytecode-only execution, privilege drop, environment stripping.
>
> **Control plane:** Stateless FastAPI service. Every sandbox request carries a bearer token. Proxies LLM calls (reconstructs full conversation history from DB), file sync via presigned S3 URLs, billing/cost caps. Gateway protocol abstracts production vs local backends.
>
> **Key takeaway:** Your agent should have nothing worth stealing and nothing worth preserving.

[Original post](https://x.com/larsencc/status/2027225210412470668)
