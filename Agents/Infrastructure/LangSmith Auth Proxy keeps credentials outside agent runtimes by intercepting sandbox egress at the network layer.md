---
created: 2026-05-25
description: LangSmith's Auth Proxy sits on the outbound network path of agent sandboxes, injecting credentials at the network layer so agents get the effect of a key without ever possessing it — shrinking blast radius from O(fleet size) to O(1).
source: https://x.com/hwchase17/status/2057506580447510889
type: framework
---

## Key Takeaways

- **Agents need the effect of credentials, not possession of them.** Every env var, `.env` file, or mounted secret in a sandbox is a latent exposure path — tool calls, package installs, log lines, and file writes are all exfiltration vectors. A proxy that injects `Authorization` headers at the network layer means the sandbox code makes a normal HTTP request and the key never touches the runtime. As @neosphere_inc observed and Chase confirmed: credential-in-env scales O(fleet size); proxy layer holds constant. This is the same architecture [[Browserbase's bb agent generalizes knowledge work through four building blocks - sandbox, credential-brokering proxy, loadable skills, and Slack]] uses with its serverless integration proxy enforcing scoped RBAC.

- **TLS MITM + iptables is the only reliable enforcement mechanism.** Hoping every language, package manager, SDK, and subprocess respects `HTTP_PROXY` is a fantasy — agents execute arbitrary code paths you didn't write. Chase confirmed: the implementation forces all sandbox traffic through the proxy via iptables, then the proxy does TLS interception. This is why [[Opencomputer reframes harness-vs-sandbox debate as git branches for VMs via hibernation egress proxies and checkpoints]] characterizes egress-proxy credential tokenization as a "15-year-old solved primitive" — the hard part isn't the proxy, it's making the egress constraint watertight.

- **Egress policy is as important as credential injection — `pip install` is a code-fetch attack surface.** Network allowlists encode which destinations are expected (model provider, GitHub API paths, internal package mirror) and block everything else. A coding agent that can reach arbitrary package registries can fetch and execute malicious code. The auth proxy becomes the single control point for both credential injection and destination enforcement, which is why [[Harrison Chase frames agent development as a Build-Test-Deploy-Monitor lifecycle wrapped by iteration and governance]] lists network policy as a governance primitive alongside cost and tool access.

- **Dynamic callbacks handle OAuth and per-user token delegation without long-lived secrets.** Static workspace secrets cover most cases, but short-lived OAuth tokens, per-user-scoped access, and credentials minted by internal auth services require a callback pattern: the proxy calls your endpoint when it lacks a cached credential, caches the returned headers for a TTL, and fails closed if the callback errors. The proxy participates in auth flows without the sandbox ever seeing a refresh token. Chase acknowledged the open-ended agent problem (whitelists either become bottlenecks or too permissive) and flagged audit logging and dynamic policies as the likely long-term answer.

- **The proxy is the natural home for the agent control plane.** Once you own the egress path, DNS remapping (pointing `pip` at an internal Artifactory mirror), network logging (audit trail of which services each agent fleet member called), and request transformation (PII redaction, org metadata injection, payload policy enforcement) are natural extensions. This mirrors the [[Claude Code's source reveals agent systems need infrastructure as a fourth layer beyond weights context and harness]] argument: production agent systems need an infrastructure layer that lives outside the runtime and is invisible to agent instructions.

## External Resources

- [LangSmith Sandboxes](https://www.langchain.com/langsmith/sandboxes) — isolated environments for agent code execution
- [Sandbox Auth Proxy docs](https://docs.langchain.com/langsmith/sandbox-auth-proxy) — configuration reference for rules, header types, and dynamic callbacks
- [Dynamic credentials with callbacks](https://docs.langchain.com/langsmith/sandbox-auth-proxy#dynamic-credentials-with-callbacks) — callback endpoint contract for OAuth and per-user token flows
- [LangSmith Sandboxes docs](https://docs.langchain.com/langsmith/sandboxes) — sandbox templates, warm pools, and lifecycle management

## Original Content

> [!quote]- Source Material
> **@hwchase17 (Harrison Chase) — Thu May 21 16:59:30 UTC 2026**
> **Article: How Auth Proxy secures network access for LangSmith agent sandboxes**
>
> If you've ever worked at a large enterprise, you have probably seen the standard corporate laptop setup.
>
> There's endpoint protection, browser filtering, device management, network controls, certificate stores, secret scanners… a long list of tools whose job is to stop an otherwise trusted employee from accidentally leaking credentials, installing a malicious package, or visiting the wrong page.
>
> That tooling exists because developers have broad access. They run code, install dependencies, and copy data between systems. They authenticate to internal and external services. A lot of enterprise security is built around making that powerful, open-ended environment safer.
>
> Agents change the scale and shape of this problem. You're not just giving one developer a laptop. You may be spawning thousands, or eventually millions, of "untrusted developers" that can write code, run commands, install packages, and make network requests on your behalf.
>
> For human developers, the environment often needs to stay open by default. Developers need to explore, debug, install tools, and reach new services as their work changes. For agents, the default can be different. If the task is known, the network can be narrower. If the agent only needs GitHub and an LLM provider, it should not be able to talk to every random host on the internet. If it needs a credential, that credential should not have to exist inside the runtime at all.
>
> This is where sandbox networking becomes a first-class part of the agent harness.
>
> ### Introducing the sandbox Auth Proxy
>
> [LangSmith Sandboxes](https://www.langchain.com/langsmith/sandboxes) give agents isolated environments for running code and interacting with filesystems without affecting your main infrastructure. But isolation is only one part of the story. Agents still need to call external APIs like model providers, GitHub, package registries, internal services, data APIs, and more.
>
> The [sandbox auth proxy](https://docs.langchain.com/langsmith/sandbox-auth-proxy) is a way to control the boundary between agent-generated behavior and the rest of the world.
>
> Instead of putting API keys into the sandbox as environment variables or files, the proxy sits on the outbound network path and controls how sandboxed code interacts with external services. It can enforce policy for which destinations are allowed, what authentication is applied, and how requests are shaped before they leave the sandbox. Sandbox code makes a normal request to an external API, while credentials and access rules are handled outside the sandbox at the network layer.
>
> Three things become much easier with this model:
>
> 1. Credentials stay out of the runtime. The agent can use an API without being able to read the API key, which reduces the damage from prompt injection, malicious dependencies, accidental logging, and model mistakes.
>
> 2. Network access becomes explicit. If an agent should only talk to OpenAI, Anthropic, GitHub, or an internal API, that should be encoded as infrastructure policy rather than left to the agent's judgment.
>
> 3. Teams get a cleaner separation of concerns: the agent focuses on the task, the sandbox provides isolation, the proxy handles network authorization and credential injection, and the application or auth service handles user-scoped access and token refresh.
>
> This separation is important because agents are untrusted and you can't review every branch they will take ahead of time. The safer pattern is to give them constrained environments where the possible actions are bounded by infrastructure, so the auth proxy keeps credentials out of the sandbox entirely.
>
> ### How it works
>
> At a high level, the auth proxy is a controlled intermediary for sandbox egress, which looks like this:
>
> 1. The agent or sandboxed code makes an outbound request.
>
> 2. The request passes through Auth Proxy.
>
> 3. Auth Proxy checks the configured policy for that destination.
>
> 4. The proxy can block the request, allow it, or attach headers.
>
> 5. The request continues to the destination without exposing credentials to the runtime.
>
> A simple rule might say: when the sandbox calls api.openai.com, inject an `Authorization` header whose value comes from a LangSmith workspace secret. Another rule might say: when the sandbox calls api.github.com on `/repos/*` or `/user`, inject a GitHub token.
>
> Because we control the network for the sandbox, this is completely transparent. This is not implemented by hoping every language, package manager, SDK, or subprocess respects `HTTP_PROXY`. Not all runtimes behave the same way, and agents often execute arbitrary code paths you didn't write.
>
> *Architecture: agent code execution routes outbound requests through Auth Proxy, which pulls credentials from workspace secrets or a callback endpoint*
> ![[hwchase17-510889-001.jpg]]
>
> ### Authenticate without handing credentials to your agent
>
> The proxy supports many different policy configurations. One powerful one is the ability to inject headers into requests that match certain characteristics.
>
> Headers can be configured with different types:
>
> - `workspace_secret`: references a secret stored in LangSmith workspace settings
>
> - `plaintext`: stored and returned as-is, for non-sensitive headers
>
> - `opaque`: write-only, encrypted at rest, and never returned by the API
>
> For example, in the example of the OpenAI rule, we can inject:
>
> ```
> {
>   "name": "Authorization",
>   "type": "workspace_secret",
>   "value": "Bearer {OPENAI_API_KEY}"
> }
> ```
>
> The sandbox code does not need to know the API key. It does not need an `.env` file. It does not need a secret mounted into its filesystem. It just calls the API, and the proxy adds the right header when the destination matches the configured rule.
>
> This is a better default for agent systems. A human developer may need direct access to a credential to debug a new integration. An agent usually does not. The agent needs the effect of the credential — the ability to call a specific API — not possession of the credential itself.
>
> That distinction becomes more important as the number of agent runs grows. With a single sandbox, a leaked key is bad, but for a fleet of sandboxes, putting credentials directly into runtimes is a significant risk. Every tool call, package install, log line, and file write is a possible credential exposure path. Header injection moves the credential out of that blast radius.
>
> *LangSmith UI: proxy rule matching api.openai.com with Authorization header injection (header values stored securely, never returned)*
> ![[hwchase17-510889-002.jpg]]
>
> ### Locking down the network
>
> Credentials are only half the network problem; agents also need egress policy because they can install dependencies, fetch scripts, call APIs, and follow instructions from untrusted content. If every sandbox has open internet access, a compromised or confused agent can reach places it shouldn't.
>
> The same proxy boundary that injects headers can also become the place where teams define which destinations are expected, like:
>
> - allowing the model provider API and blocking everything else
>
> - allowing GitHub API paths the agent needs, but not arbitrary GitHub-adjacent domains
>
> - allowing a package registry, but only the internal mirror
>
> - blocking known malicious or untrusted package registries
>
> - preventing accidental calls to unauthorized third-party services
>
> This is especially important for package management. If a coding agent can run `pip install`, `npm install`, or `curl | bash`, it can fetch and execute code. The security question is not just whether the sandbox can contain execution, but whether you can control where that code comes from and where it can send data.
>
> ### Dynamic credentials for real production auth
>
> While integrating sandboxes with LangSmith Fleet, we realized that for advanced use cases, static configuration may not be sufficient. Fleet agents may need delegated access and OAuth token refreshes while still keeping the actual credential handling outside the agent runtime.
>
> Other examples of advanced use cases include:
>
> - short-lived OAuth access tokens
>
> - per-user-scoped tokens
>
> - credentials minted by an internal auth service
>
> - tokens that need to be refreshed based on the destination or current user context
>
> For these cases, the auth proxy supports [dynamic credentials with callbacks](https://docs.langchain.com/langsmith/sandbox-auth-proxy#dynamic-credentials-with-callbacks).
>
> Instead of putting all credential material into static rules, you configure a callback under `proxy_config`. When the sandbox makes a request to a matching host and the proxy does not have a cached credential, the proxy calls your callback endpoint with the target host and port. Your endpoint returns the headers to inject, and the proxy caches the result for a configured TTL.
>
> The contract is simple: the callback returns a JSON object like:
>
> ```
> {
>   "headers": {
>     "Authorization": "Bearer <token>",
>     "X-Org-Id": "..."
>   }
> }
> ```
>
> The proxy injects those headers into the outbound request. If the callback fails, returns malformed JSON, or responds with a non-2xx status, the proxy fails closed and rejects the sandbox request rather than sending it without credentials. This is the pattern lets the sandbox network layer participate in auth flows without exposing refresh tokens or long-lived credentials to the sandbox.
>
> *Dynamic credential flow: proxy POSTs to callback endpoint when no cached credential exists; fails closed on callback errors*
> ![[hwchase17-510889-003.jpg]]
>
> ### What this unlocks next
>
> Once you control the sandbox network path, the proxy can become more than a credential injector, and there are a few natural extensions.
>
> 1. DNS remapping: a team may want requests to public package registries to resolve to an internal Artifactory or package mirror instead. You may want to point LLM API requests towards an internal gateway. The agent still runs normal install commands, but the network layer points those requests at approved infrastructure.
>
> 2. Network logging: if agents are doing meaningful work over long horizons, teams will want to know which services they called, which packages they fetched, and which domains they attempted to reach. Network logs become part of the audit trail for agent behavior.
>
> 3. Request transformation: since the proxy sees outbound requests, it can eventually become a place to apply deterministic transformations, such as redacting PII, adding organization metadata, enforcing request shape, or blocking payloads that violate policy.
>
> The broader point is that agent infrastructure needs control planes that live outside the runtime and aren't exposed to agent instructions and decisions.
>
> ### The new default for agent egress
>
> Agents need credentials and network access to do useful work, but those capabilities should not require putting long-lived secrets or unrestricted internet access inside the runtime. Auth Proxy gives sandboxed agents a safer default by keeping credentials outside the environment, routing outbound traffic through a controlled layer, and applying policy consistently across languages, SDKs, package managers, and CLIs.
>
> The result is a sandbox model that gives agents access to the systems they need, while keeping credentials and network policy under platform control.
>
> Try LangSmith Sandboxes: https://www.langchain.com/langsmith/sandboxes
> Read the docs: https://docs.langchain.com/langsmith/sandboxes
>
> Engagement: 171 likes | 21 retweets | 11 replies
> [Original post](https://x.com/hwchase17/status/2057506580447510889)
>
> ---
>
> **Thread replies (author self-replies):**
>
> > @hwchase17 — 2026-05-21 18:04 UTC (reply to @ptr asking "Does this involve TLS MITM?")
> > TLS MITM + ip tables configuration to force all traffic through proxy
>
> > @hwchase17 — 2026-05-21 18:11 UTC (reply to @centennialarts on open-ended agent policy maintenance)
> > Great question and something we are still thinking about. I suspect more interesting patterns will evolve over time but generally some sort of centralized least privilege model has worked well. This is also where stuff like audit logging / more dynamic policies may be interesting rather than explicit whitelists
>
> **Notable community replies:**
>
> > @neosphere_inc (d6n) — 2026-05-21 17:11 UTC
> > On systems I worked on, the credential-in-env pattern scaled badly. At 1000 sandboxes, one leaked var is 1000 exposure points. Proxy layer breaks the multiplication: blast radius stays constant regardless of fleet size. Took us longer than it should have to figure that out.
> > *(hwchase17 reply: "exactly")*
>
> > @agentxagi (Agent X AGI) — 2026-05-21 19:30 UTC
> > credentials outside the runtime, policy at the network layer. correct model. but the proxy becomes the new trust boundary. compromise the proxy config and every sandbox is open. is the proxy config immutable at deploy or mutable per-session?
>
> > @maverickintech (Arpit Nigam) — 2026-05-21 17:10 UTC
> > This is great for prototyping, but how are you guys handling vector poisoning in production? We just had to rip out a similar open IAM structure for a Series-B client because unvetted client uploads were corrupting the embeddings. Hard sandboxing the execution pods is the only way we found to stop it from leaking env variables.
>
> > @centennialarts (Centennial Arts) — 2026-05-21 17:11 UTC
> > What's the policy maintenance plan for truly open-ended agents? The whitelist either becomes a bottleneck, or you make it permissive enough that it stops being real security.
>
> > @SquidCorp_ink (Jeremy) — 2026-05-21 18:11 UTC
> > That's actually my take! Why would you provide full access to your agent when you restrict access to your staff?
>
> > @sauvast (Saurabh) — 2026-05-21 22:25 UTC
> > This is exactly what security and compliance teams need to see before letting engineering teams spin up millions of autonomous agent sandboxes. Separating the agent's task from credential possession removes massive enterprise friction.
>
> > @georgeorch (George) — 2026-05-24 19:14 UTC
> > The observability layer is where most agent builders cut corners and pay for it 3 months later. Ran production agents without proper logging for the first 6 months. Debugging was pain. Added tracing and suddenly I could fix issues in minutes instead of hours.
>
> > @Gsdata5566 (AI Professor) — 2026-05-25 00:45 UTC
> > That debugging gap is the production cliff for agents. Raw logs help, but structured traces turn incidents into something a team can replay, compare, and actually fix.
