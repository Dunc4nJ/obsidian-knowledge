---
created: 2026-03-02
description: Factory's droid-action GitHub Action exposes a full agent runtime as a CI contract, routing @droid commands to fill, review, and security workflows with configurable models, STRIDE-based security skills, and MCP tool access.
source: https://github.com/Factory-AI/droid-action
---

## Key Takeaways

The droid-action repo is the harness that turns [[Factory Code Droid combines multi-model sampling and codebase-aware retrieval to achieve state-of-the-art SWE-bench performance|Factory's Droid agent]] into a GitHub-native CI primitive. Rather than running as an external service, the agent executes entirely within GitHub Actions, meaning the trust boundary is the repository's own permissions model — `contents: read`, `pull-requests: write`, `issues: write`, `id-token: write`, `actions: read`.

The command surface is minimal and verb-oriented: `@droid fill`, `@droid review`, `@droid security`, and `@droid security --full`. This mirrors the pattern seen in [[harness engineering improved a coding agent 13 points by changing only system prompts tools and middleware|harness engineering]] where constraining the agent's action space to a few well-defined operations yields better results than open-ended instructions. Each command triggers a different prompt pipeline internally.

The security workflow is notably sophisticated — it installs specialized Factory skills (`threat-model-generation`, `commit-security-scan`, `vulnerability-validation`, `security-review`) from a public skills repository, uses STRIDE methodology, and supports severity thresholds, blocking reviews on critical/high findings, team notifications, and scheduled full-repo scans. This is a composable skill architecture layered on top of the base agent.

The action exposes model selection as configuration inputs (`review_model` defaults to `gpt-5.2`, `fill_model` and `security_model` are overridable), which aligns with [[Factory Droid achieves state-of-the-art on Terminal-Bench through agent design not model choice|Factory's thesis that harness design matters more than model choice]] — the harness is model-agnostic by design.

MCP tools are "pre-registered" so the agent can call GitHub APIs safely during execution. The action handles context gathering (PR metadata, changed files, existing comments, PR templates) before composing the prompt, demonstrating the context-engineering pattern of front-loading relevant information.

## External Resources

- [Factory API Keys](https://app.factory.ai/settings/api-keys) — where to generate the `FACTORY_API_KEY` secret
- [Factory-AI/skills](https://github.com/Factory-AI/skills) — public skills repository used for security review capabilities
- [Setup Guide](https://github.com/Factory-AI/droid-action/blob/dev/docs/setup.md) — detailed installation docs
- [FAQ](https://github.com/Factory-AI/droid-action/blob/dev/docs/faq.md) — troubleshooting

## Original Content

> [!quote]- Source Material
> 
> This GitHub Action powers the Factory Droid app. It watches your pull requests for supported commands and runs a full Droid Exec session to help you ship faster:
> 
> - @droid fill — turns a bare pull request into a polished description that matches your template or our opinionated fallback.
> 
> - @droid review — performs an automated code review, surfaces potential bugs, and leaves inline comments directly on the diff.
> 
> - @droid security — performs an automated security review using STRIDE methodology, identifying vulnerabilities and suggesting fixes.
> 
> - @droid security --full — performs a full repository security scan and creates a PR with the report.
> 
> Everything runs inside GitHub Actions using your Factory API key, so the bot never leaves your repository and operates with the permissions you grant.
> 
> ## What Happens When You Tag @droid
> 
> - Trigger detection – The action scans issue comments, PR descriptions, and review comments for @droid commands.
> 
> - Context gathering – Droid collects the PR metadata, existing comments, changed files, and any PR description template in your repository.
> 
> - Prompt generation – We compose a precise prompt instructing Droid what to do and which GitHub MCP tools it may use.
> 
> - Execution – The action runs droid exec with full repository context. MCP tools are pre-registered so Droid can call the GitHub APIs safely.
> 
> - Results – For fill, Droid updates the PR body. For review/security, it posts inline feedback and a summary comment.
> 
> ## Installation
> 
> - Install the Droid GitHub App
> 
> Install from the Factory dashboard and grant it access to the repositories where you want Droid to operate.
> 
> - Create a Factory API Key
> 
> Generate a token at [https://app.factory.ai/settings/api-keys](https://app.factory.ai/settings/api-keys) and save it as FACTORY_API_KEY in your repository or organization secrets.
> 
> - Add the Action Workflows
> 
> Create two workflow files under .github/workflows/ to separate on-demand tagging from automatic PR reviews, based on your needs.
> 
> ### Setup
> 
> droid.yml (responds to explicit @droid mentions):
> 
> ```yaml
> name: Droid Tag
> 
> on:
>   issue_comment:
>     types: [created]
>   pull_request_review_comment:
>     types: [created]
>   issues:
>     types: [opened, assigned]
>   pull_request_review:
>     types: [submitted]
>   pull_request:
>     types: [opened, edited]
> 
> jobs:
>   droid:
>     if: |
>       (github.event_name == 'issue_comment' && contains(github.event.comment.body, '@droid')) ||
>       (github.event_name == 'pull_request_review_comment' && contains(github.event.comment.body, '@droid')) ||
>       (github.event_name == 'pull_request_review' && contains(github.event.review.body, '@droid')) ||
>       (github.event_name == 'issues' && (contains(github.event.issue.body, '@droid') || contains(github.event.issue.title, '@droid'))) ||
>       (github.event_name == 'pull_request' && (contains(github.event.pull_request.body, '@droid') || contains(github.event.pull_request.title, '@droid')))
>     runs-on: ubuntu-latest
>     permissions:
>       contents: read
>       pull-requests: write
>       issues: write
>       id-token: write
>       actions: read
>     steps:
>       - name: Checkout repository
>         uses: actions/checkout@v5
>         with:
>           fetch-depth: 1
> 
>       - name: Run Droid Exec
>         uses: Factory-AI/droid-action@v3
>         with:
>           factory_api_key: ${{ secrets.FACTORY_API_KEY }}
> ```
> 
> Once committed, tagging @droid fill, @droid review, or @droid security on an open PR will trigger the bot automatically.
> 
> droid-review.yml (automatic reviews on PRs):
> 
> ```yaml
> name: Droid Auto Review
> 
> on:
>   pull_request:
>     types: [opened, ready_for_review, reopened]
> 
> concurrency:
>   group: ${{ github.workflow }}-${{ github.event.pull_request.number || github.ref }}
>   cancel-in-progress: true
> 
> jobs:
>   droid-review:
>     if: github.event.pull_request.draft == false
>     runs-on: ubuntu-latest
>     permissions:
>       contents: write
>       pull-requests: write
>       issues: write
>       id-token: write
>       actions: read
>     steps:
>       - name: Checkout repository
>         uses: actions/checkout@v5
>         with:
>           fetch-depth: 1
> 
>       - name: Run Droid Auto Review
>         uses: Factory-AI/droid-action@v3
>         with:
>           factory_api_key: ${{ secrets.FACTORY_API_KEY }}
>           automatic_review: true
> ```
> 
> Set automatic_review: true to run code reviews automatically on non-draft PRs.
> 
> ## Using the Commands
> 
> ### @droid fill
> 
> - Place the command in the PR description or in a top-level comment.
> 
> - Droid searches for common PR template locations (.github/pull_request_template.md, etc.). When a template exists, it fills the sections; otherwise it writes a structured summary (overview, changes, testing, rollout).
> 
> - The original request is replaced with the generated description so reviewers can merge immediately.
> 
> ### @droid review
> 
> - Mention @droid review in a PR comment.
> 
> - Droid inspects the diff, prioritizes potential bugs or high-impact issues, and leaves inline comments directly on the changed lines.
> 
> - A short summary comment is posted in the original thread highlighting the findings and linking to any inline feedback.
> 
> ### @droid security
> 
> - Mention @droid security in a PR comment.
> 
> - Droid performs a security-focused review using STRIDE methodology (Spoofing, Tampering, Repudiation, Information Disclosure, Denial of Service, Elevation of Privilege).
> 
> - Findings include severity levels, CWE references, and suggested fixes.
> 
> ### @droid security --full
> 
> - Performs a full repository security scan (not just PR changes).
> 
> - Creates a new branch with a security report at .factory/security/reports/security-report-{date}.md.
> 
> - Opens a PR with findings and auto-generated patches where possible.
> 
> - Useful for scheduled security audits.
> 
> ## Configuration
> 
> ### Core Inputs
> 
> | Input | Purpose |
> |-------|---------|
> | factory_api_key | Required. Grants Droid Exec permission to run via Factory. |
> | github_token | Optional override if you prefer a custom GitHub App/token. By default the installed app token is used. |
> 
> ### Review Configuration
> 
> | Input | Default | Purpose |
> |-------|---------|---------|
> | automatic_review | false | Automatically run code review on PRs without requiring @droid review. |
> | review_model | gpt-5.2 | Override the model used for code review. |
> | fill_model | "" | Override the model used for PR description fill. |
> 
> ### Security Configuration
> 
> | Input | Default | Purpose |
> |-------|---------|---------|
> | automatic_security_review | false | Automatically run security review on PRs without requiring @droid security. |
> | security_model | "" | Override the model used for security review. Falls back to review_model if not set. |
> | security_severity_threshold | medium | Minimum severity to report (critical, high, medium, low). Findings below this threshold are filtered out. |
> | security_block_on_critical | true | Submit REQUEST_CHANGES review when critical severity findings are detected. |
> | security_block_on_high | false | Submit REQUEST_CHANGES review when high severity findings are detected. |
> | security_notify_team | "" | GitHub team to @mention on critical findings (e.g., @org/security-team). |
> | security_scan_schedule | false | Configuration for scheduled security scans (when invoked from scheduled workflows). |
> | security_scan_days | 7 | Number of days of commits to scan for scheduled security scans. |
> 
> ## Security Skills
> 
> The security review uses specialized Factory skills installed from the public Factory-AI/skills repository:
> 
> - threat-model-generation – Generates STRIDE-based threat models for repositories
> 
> - commit-security-scan – Scans code changes for security vulnerabilities
> 
> - vulnerability-validation – Validates findings and filters false positives
> 
> - security-review – Comprehensive security review and patch generation
> 
> These skills are automatically installed when running security reviews.
> 
> ## Troubleshooting & Support
> 
> - Check the workflow run linked from the Droid tracking comment for execution logs.
> 
> - Verify that the workflow file and repository allow the GitHub App to run (branch protections can block bots).
> 
> - Automatic security reviews are deduplicated per PR to reduce duplicate scans; use @droid security explicitly if you need to re-run.
> 
> - Need more detail? Start with the [Setup Guide](https://github.com/Factory-AI/droid-action/blob/dev/docs/setup.md) or [FAQ](https://github.com/Factory-AI/droid-action/blob/dev/docs/faq.md).

[Source](https://github.com/Factory-AI/droid-action)
