---
created: 2026-03-21
source: https://github.com/microsoft/agent-governance-toolkit
type: resource
tags: [governance, policy-enforcement, zero-trust, sandboxing, owasp, sre]
status: unread
---

## What it is

Microsoft's Agent Governance Toolkit is a runtime governance framework for AI agents covering all 10 OWASP Agentic Top 10 risks with 6,100+ tests. It provides deterministic policy enforcement, zero-trust agent identity (Ed25519/SPIFFE), execution sandboxing, and SRE tooling across Python, TypeScript, and .NET SDKs.

## Why it's interesting

It's one of the first comprehensive, multi-language governance frameworks that focuses on what agents *do* rather than what they *say* — enforcing policies at the action level with sub-millisecond latency. Works with any stack (AWS Bedrock, Google ADK, Azure AI, LangChain, CrewAI, AutoGen, OpenAI Agents, LlamaIndex) with zero vendor lock-in, making it a practical drop-in for existing agent deployments.

## How it works

The toolkit is composed of several modular packages: **agent-os-kernel** handles the policy engine that evaluates every agent action against defined policies before execution. **agentmesh-platform** provides a trust mesh with cryptographic identity (Ed25519 credentials, SPIFFE/SVID support) and trust scoring on a 0-1000 scale. **agent-runtime** acts as a runtime supervisor for execution sandboxing. **agent-sre** provides SRE/reliability engineering tooling. **agent-governance-toolkit** handles compliance and attestation. The architecture is designed so each component can be installed independently or together via `pip install agent-governance-toolkit[full]`.

## Key links

- [GitHub](https://github.com/microsoft/agent-governance-toolkit)
- [Quick Start](https://github.com/microsoft/agent-governance-toolkit/blob/main/QUICKSTART.md)
- [OWASP Compliance Mapping](https://github.com/microsoft/agent-governance-toolkit/blob/main/docs/OWASP-COMPLIANCE.md)
- [Architecture](https://github.com/microsoft/agent-governance-toolkit/blob/main/docs/ARCHITECTURE.md)
- [NIST RFI Mapping](https://github.com/microsoft/agent-governance-toolkit/blob/main/docs/nist-rfi-mapping.md)

## Notes

- Community preview only — not official Microsoft-signed releases yet
- Covers NIST AI Agent Security RFI (2026-00206) mapping
- Has NVIDIA OpenShell integration for sandbox isolation + governance
