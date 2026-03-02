---
created: 2026-03-02
description: Factory's open-source droid-code-review GitHub Action shows how an AI code review harness translates LLM analysis into GitHub pull request review comments using diff-position anchoring, confidence-gated tone, deduplication against prior bot comments, and supersession of stale no-issues summaries.
source: https://github.com/Factory-AI/droid-code-review
---

## Key Takeaways

The droid-code-review repo is Factory's open-source GitHub Action for automated pull request review, and it exposes the full prompt engineering and harness plumbing that turns a general-purpose coding agent into a code reviewer. Unlike the broader [[Factory droid-action wraps agent execution into a GitHub Actions contract with structured inputs MCP tools and STRIDE security skills|droid-action]] which is a generic agent executor, this action is purpose-built for the review use case with a tightly scoped prompt and comment submission pipeline.

The most revealing design choice is **prompt-as-harness**: the entire review logic — what to look for, how to comment, when to stay silent — lives in a single prompt template embedded in `action.yml`. There is no application code for parsing diffs, computing positions, or posting comments. The agent (via `droid exec`) is expected to call `gh` CLI commands directly to fetch PR data, compute diff positions, and submit reviews via the GitHub REST API. This means the LLM is responsible for correctly computing diff position integers from patch hunks — a non-trivial mapping that most code review tools implement in deterministic code.

**Deduplication is stateful and prompt-enforced.** The prompt instructs the agent to fetch existing comments, never re-raise previously reported issues regardless of resolution state, and handle supersession of prior "no issues" comments by attempting deletion, then minimization via GraphQL, then editing, then replying — a four-level fallback chain. This is a fragile but pragmatic approach: it works because `droid exec` has full tool access including `gh api`, but depends entirely on the LLM faithfully following the deduplication instructions.

**Confidence-gated tone** is another notable pattern. The prompt defines three confidence tiers (High/Medium/Low) with different output formats: low-confidence issues become questions ("Did you mean to...?"), while high-confidence issues are stated directly. The prompt explicitly says "false positives are very undesirable" and caps output at 10 inline comments. This is a [[Factory Code Droid combines multi-model sampling and codebase-aware retrieval to achieve state-of-the-art SWE-bench performance|precision-over-recall]] design philosophy applied to the review domain.

The action also includes a secondary capability: **auto-generating PR descriptions** when the PR body contains `@droid fill`. This uses a separate prompt that detects PR templates in `.github/PULL_REQUEST_TEMPLATE.md`, fills them from the diff, and updates the PR body via `gh pr edit`. The template-awareness is a nice touch — it means the agent respects existing team workflows rather than imposing its own format.

The scope is deliberately narrow: only bugs, security vulnerabilities, and correctness issues. Style, architecture, performance (unless evidence-based), and test coverage are explicitly excluded. The review never approves or requests changes — it only posts `COMMENT` events — avoiding any merge-blocking behavior. This maps to [[Factory droid exec uses tiered autonomy levels to gate agent permissions from read-only to full system access|Factory's tiered autonomy philosophy]] where agents default to advisory rather than authoritative roles.

Full repo checkout with `fetch-depth: 0` gives the agent access to the entire codebase for context, not just the diff. Combined with concurrency groups that cancel previous runs on the same PR, this creates a review loop where each push gets a fresh, full-context review that is aware of its own prior comments.

## External Resources

- [Factory API Keys](https://app.factory.ai/settings/api-keys) — where to get the `FACTORY_API_KEY` needed for the action
- [Factory Documentation](https://docs.factory.ai) — official docs for the Droid platform
- [Droid CLI installer](https://app.factory.ai/cli) — the CLI binary that powers the review execution

## Original Content

> [!quote]- README.md — Factory-AI/droid-code-review
>
> ## Factory Droid Review
>
> An AI-powered code review GitHub Action using Factory's Droid to analyze code changes and identify critical issues. This action automatically reviews pull requests, focusing on bugs, security vulnerabilities, and critical code problems.
>
> ## Features
>
> - AI-Powered Analysis: Uses Factory's Droid CLI to analyze code changes and identify critical issues
> - Full Repository Context: Checks out the PR head branch so Droid can analyze any relevant file in the repository (not just the diff) before leaving review comments
> - Inline Code Comments: Posts targeted review comments directly on specific lines with optional fix suggestions
> - Duplicate Prevention: Checks existing comments to avoid redundant feedback
> - Focused Review Scope: Prioritizes critical bugs and security issues over style concerns
> - Debug Artifacts: Uploads diagnostic logs on failure for troubleshooting
>
> ## Quick Start
>
> Add this to your repository's `.github/workflows/review-droid.yml`:
>
> ```yaml
> name: Droid Review
>
> permissions:
>   pull-requests: write # Needed for leaving PR comments
>   contents: read
>   issues: write
>
> on:
>   pull_request:
>     types: [opened, synchronize, reopened, ready_for_review, edited]
>
> # Cancel previous runs for the same PR
> concurrency:
>   group: review-droid-${{ github.event.pull_request.number }}
>   cancel-in-progress: true
>
> jobs:
>   code-review:
>     runs-on: ubuntu-latest
>     timeout-minutes: 15
>     # Skip draft PRs
>     if: github.event.pull_request.draft == false
>
>     steps:
>       - uses: Factory-AI/droid-code-review@latest
>         with:
>           factory-api-key: ${{ secrets.FACTORY_API_KEY }}
>           pr-number: ${{ github.event.pull_request.number }}
>           pr-head-sha: ${{ github.event.pull_request.head.sha }}
> ```
>
> ## Configuration Options
>
> ### Action Inputs
>
> | Input | Description | Default | Required |
> |-------|-------------|---------|----------|
> | factory-api-key | The API key to run Droid Exec which powers the Review Droid. | None | Yes |
> | pr-number | The Pull Request number being reviewed | None | Yes |
> | pr-head-sha | The commit SHA of the PR head branch for correct checkout | None | Yes |
>
> ## Code Review Capabilities
>
> ### Issues Actively Detected
>
> - Dead/Unreachable Code: Code after return/throw/break, if(false) blocks
> - Control Flow Bugs: Missing break statements, switch fallthrough issues
> - Async/Await Errors: Missing await, unhandled promise rejections, incorrect promise handling
> - React-Specific Issues: State mutations, useEffect dependency problems
> - Operator Mistakes: Wrong equality operators (== vs ===), assignment in conditions
> - Array/Loop Errors: Off-by-one errors, incorrect indexing
> - Type Coercion Issues: Problematic type conversions affecting behavior
> - Null/Undefined Errors: Potential null dereferences, missing checks
> - Resource Management: Unclosed files/connections, memory leaks
> - Security Vulnerabilities: SQL/XSS injection risks, unvalidated environment variables
> - Concurrency Problems: Race conditions, synchronization issues
> - Error Handling: Missing error handling for critical operations
> - Recursion Issues: Missing base cases, stack overflow risks
> - Regex Problems: Catastrophic backtracking vulnerabilities
>
> ### What's NOT Reviewed
>
> The action intentionally skips:
>
> - Code style, formatting, or naming conventions
> - Minor performance optimizations
> - Architectural decisions or design patterns
> - Feature completeness or functionality (unless broken)
> - Test coverage (unless tests are clearly broken)
>
> ## Installation & Setup
>
> ### GitHub Actions
>
> Follow the Quick Start guide above. The action will:
>
> - Install Factory's Droid CLI using the official installer
> - Configure the CLI with your API key
> - Execute the code review analysis
>
> ### Creating the Secret
>
> 1. Go to your repository Settings → Secrets and variables → Actions
> 2. Create a new repository secret named `FACTORY_API_KEY`
> 3. Paste your Factory API key (get one at [factory.ai](https://app.factory.ai/settings/api-keys))
>
> ## Technical Implementation
>
> ### How It Works
>
> 1. Checkout: Action checks out the repository at the PR head commit with full history
> 2. CLI Installation: Downloads and installs Droid CLI from https://app.factory.ai/cli
> 3. PR Analysis: Fetches complete PR data from GitHub URL (diff, comments, metadata)
> 4. Code Review: Runs `droid exec --skip-permissions-unsafe` with the review prompt
> 5. Comment Submission: Posts inline comments via GitHub REST API using curl
> 6. Error Handling: Uploads debug artifacts if the review fails
>
> ### Review Limits
>
> - Maximum of 10 inline comments per review (prioritizing most critical issues)
> - Comments only on modified lines in the PR
> - Suggestions provided only when fixes are certain
> - No PR approval/rejection to avoid blocking merge workflows
>
> ### Debug Information
>
> On failure, the action uploads:
>
> - The review prompt used
> - Droid execution logs
> - Console output logs
>
> These artifacts are retained for 7 days to help diagnose issues.
>
> ## Support
>
> For issues or questions:
>
> - Open an issue in this repository
> - Visit [Factory Documentation](https://docs.factory.ai) for API details
>
> ## License
>
> MIT License - see LICENSE file for details

> [!quote]- action.yml — Full composite action source
>
> ```yaml
> name: Factory Droid Review
> description: Automated Code Review for GitHub Pull Requests.
> author: Factory
>
> inputs:
>   factory-api-key:
>     description: "The API key to run Droid Exec which powers the Review Droid (required)."
>     required: true
>   pr-number:
>     description: "The Pull Request number being reviewed."
>     required: true
>   pr-head-sha:
>     description: "The commit SHA of the Pull Request head branch for correct checkout."
>     required: true
>
> runs:
>   using: "composite"
>   steps:
>     - name: Checkout repository
>       uses: actions/checkout@v4
>       with:
>         fetch-depth: 0
>         ref: ${{ inputs.pr-head-sha }}
>         token: ${{ github.token }}
>
>     - name: Install Droid CLI
>       shell: bash
>       run: |
>         curl -fsSL https://app.factory.ai/cli | sh
>         echo "$HOME/.local/bin" >> $GITHUB_PATH
>         "$HOME/.local/bin/droid" --version
>
>     - name: Auto-generate PR description on '@droid fill'
>       shell: bash
>       env:
>         FACTORY_API_KEY: ${{ inputs.factory-api-key }}
>         GH_TOKEN: ${{ github.token }}
>       run: |
>         set -euo pipefail
>
>         echo "Checking PR description for @droid fill command..."
>
>         # Fetch current PR description
>         PR_BODY=$(gh pr view ${{ inputs.pr-number }} --repo ${{ github.repository }} --json body -q .body || echo "")
>
>         if ! echo "$PR_BODY" | grep -q "@droid fill"; then
>           echo "No '@droid fill' found in PR description. Skipping description generation."
>           exit 0
>         fi
>
>         echo "Found '@droid fill' in PR description. Generating detailed description..."
>
>         # Check for PR template in common locations
>         PR_TEMPLATE=""
>         for template_path in ".github/PULL_REQUEST_TEMPLATE.md" ".github/pull_request_template.md"; do
>           if [ -f "$template_path" ]; then
>             PR_TEMPLATE=$(cat "$template_path")
>             echo "Found PR template at $template_path"
>             break
>           fi
>         done
>
>         # Create the entire prompt in a single heredoc with inline variables
>         cat > pr_description_prompt.txt << EOF
>         Generate a comprehensive pull request description for PR #${{ inputs.pr-number }}.
>
>         Procedure:
>         - Get PR metadata (title & description): gh pr view ${{ inputs.pr-number }} --repo ${{ github.repository }} --json title,body
>         - Get existing comments: gh pr view --json comments
>         - Get diff: gh pr diff
>         - Get changed files with patches to compute inline positions: gh api repos/${{ github.repository }}/pulls/${{ github.event.pull_request.number }}/files --paginate --jq '.[] | {filename,patch}'
>
>         Use the PR metadata (title/body) as additional context:
>         - If the existing description includes notes/context, use it to inform your writeup
>         - Do not copy any placeholder tokens (e.g., "@droid fill") into the final output
>
>         This will help you understand the code changes in detail.
>
>         $(if [ -n "$PR_TEMPLATE" ]; then
>           echo "YOUR TASK: Fill out the following PR template based on the code changes."
>           echo ""
>           echo "--- PR TEMPLATE TO FILL ---"
>           echo "$PR_TEMPLATE"
>           echo "--- END OF TEMPLATE ---"
>           echo ""
>           echo "TEMPLATE INSTRUCTIONS:"
>           echo "- Fill sections you can verify from the code diff"
>           echo "- For checklists: only check items verifiable from the code"
>           echo "- For unverifiable sections: use '[To be filled by author]'"
>         else
>           echo "Generate a description with this structure:"
>           echo ""
>           echo "## Summary"
>           echo "A clear 2-3 sentence overview of what this PR accomplishes."
>           echo ""
>           echo "## Changes"
>           echo "- List the main changes made in this PR"
>           echo "- Group related changes together"
>           echo "- Reference specific files when relevant"
>           echo ""
>           echo "## Implementation Details"
>           echo "Describe key technical decisions or patterns used (if non-obvious)."
>           echo ""
>           echo "## Testing"
>           echo "- Note any test files added or modified (visible in the diff)"
>           echo "- Remind that tests should be run locally"
>           echo ""
>           echo "## Breaking Changes"
>           echo "Only include if there are actual breaking changes."
>           echo ""
>           echo "## Related Issues"
>           echo "Link any issues mentioned in the PR or commits (e.g., Fixes #123)."
>         fi)
>
>         IMPORTANT RULES:
>         1. Fill out the sections based *only* on the actual code diff.
>         2. Do not make up information. If a section isn't relevant, state that.
>         3. Be concise and factual.
>         4. DO NOT include "@droid fill" in the final generated description.
>
>         After generating the description, update the PR using:
>         gh pr edit ${{ inputs.pr-number }} --repo ${{ github.repository }} --body "[YOUR GENERATED DESCRIPTION]"
>
>         Make sure to properly escape the description for shell usage.
>         EOF
>
>         echo "Generating PR description..."
>         droid exec --skip-permissions-unsafe -f pr_description_prompt.txt
>
>         echo "PR description updated successfully."
>
>     - name: Perform automated code review
>       shell: bash
>       env:
>         FACTORY_API_KEY: ${{ inputs.factory-api-key }}
>         GH_TOKEN: ${{ github.token }}
>       run: |
>         set -euo pipefail
>
>         cat > prompt.txt << 'EOF'
>         You are running automated code review in a GitHub Actions runner. The gh CLI is available and authenticated via GH_TOKEN.
>
>         Context:
>           - Repo: ${{ github.repository }}
>           - PR Number: ${{ github.event.pull_request.number }}
>           - PR Head SHA: ${{ github.event.pull_request.head.sha }}
>           - PR Base SHA: ${{ github.event.pull_request.base.sha }}
>
>         Objectives:
>           1) Re-check existing review comments and reply resolved when addressed.
>           2) Review the current PR diff and flag only clear, high-severity issues.
>           3) Leave very short inline comments (1-2 sentences) on changed lines only and a brief summary at the end.
>
>         Procedure:
>           - Get existing comments: gh pr view --json comments
>           - Get diff: gh pr diff
>           - Get changed files with patches to compute inline positions: gh api repos/${{ github.repository }}/pulls/${{ github.event.pull_request.number }}/files --paginate --jq '.[] | {filename,patch}'
>           - Compute exact inline anchors for each issue (file path + diff position). Comments MUST be placed inline on the changed line in the diff, not as top-level comments.
>           - Detect prior top-level "no issues" style comments authored by this bot (match bodies like: "no issues", "No issues found", "LGTM"; include earlier emoji-prefixed variants if present).
>           - If CURRENT run finds issues and any prior "no issues" comments exist:
>             - Prefer to remove them to avoid confusion:
>               - Try deleting top-level issue comments via: gh api -X DELETE repos/${{ github.repository }}/issues/comments/<comment_id>
>               - If deletion isn't possible, minimize them via GraphQL (minimizeComment) or edit to prefix "[Superseded by new findings]".
>             - If neither delete nor minimize is possible, reply to that comment: "Superseded: issues were found in newer commits".
>           - If a previously reported issue appears fixed by nearby changes, reply: This issue appears to be resolved by the recent changes
>
>         - Analysis scope (broad but precise):
>             - Correctness: boundary/off-by-one error.
>             - Robustness & validation: missing input validation.
>             - API/contract misuse: wrong parameter order.
>             - Concurrency & async: race condition due to shared mutable state.
>             - Performance (evidence-based): N+1 queries.
>             - Resource management: unclosed file handle.
>             - Dead/unreachable code that affects behavior.
>             - Regression risks: breaking existing behavior or tests.
>         - Accuracy gates:
>             - Base findings on the current diff and minimal repo context available via gh; avoid speculation.
>             - Prioritize high-severity/high-confidence; cap at 10 comments.
>             - If confidence is low, ask a clarifying question rather than asserting an issue.
>             - Do not flag purely stylistic or preference-only concerns.
>         - Deduplication policy:
>             - Never repeat or re-raise an issue previously highlighted by this bot on this PR, regardless of whether the thread is marked resolved or unresolved.
>             - Do not create a new comment for a previously reported issue; if needed, reply in the existing thread with a brief status update (e.g., "Resolved ...") or skip.
>
>         Commenting rules:
>           - Max 10 inline comments total; prioritize the most critical issues
>           - One issue per comment; place on the exact changed line
>           - All issue comments MUST be inline (anchored to a file and line/position in the PR diff)
>           - Natural tone, specific and actionable; do not mention automated or high-confidence
>           - Tone: write like a junior developer who defers to the PR author; be polite and tentative, avoid authoritative language, and prefer concise, respectful phrasing.
>           - Confidence: for each potential issue, internally assess confidence as High/Medium/Low.
>               - Low confidence: phrase the comment as a question (e.g., "I noticed the code does X — did you mean to Y?") and keep it brief.
>               - Medium/High confidence: state the issue directly and concretely.
>           - False positives are very undesirable: only surface an issue when you are fairly confident it is valid; when uncertain, prefer a single clarifying question over a definitive claim.
>           - Only propose an exact code change (e.g., a concrete patch/suggestion) when you are absolutely certain the change is correct and safe; otherwise do not suggest a code change—only describe the issue succinctly.
>           - No speculative or stylistic suggestions; focus strictly on definitive fixes to high-severity issues.
>
>         Submission:
>           - If there are NO issues to report and an existing top-level comment indicating "no issues" already exists (e.g., "no issues", "No issues found", "LGTM"), do NOT submit another comment. Skip submission to avoid redundancy.
>           - If there are NO issues to report and NO prior "no issues" comment exists, submit one brief summary comment noting no issues.
>           - If there ARE issues to report and a prior "no issues" comment exists, ensure that prior comment is deleted/minimized/marked as superseded before submitting the new review.
>           - If there ARE issues to report, submit ONE review containing ONLY inline comments plus an optional concise summary body. Use the GitHub Reviews API to ensure comments are inline:
>             - Build a JSON array of comments like: [{ "path": "<file>", "position": <diff_position>, "body": "..." }]
>             - Submit via: gh api repos/${{ github.repository }}/pulls/${{ github.event.pull_request.number }}/reviews -f event=COMMENT -f body="$SUMMARY" -f comments='[$COMMENTS_JSON]'
>           - Do NOT use: gh pr review --approve or --request-changes
>         EOF
>
>         echo "Running code review analysis..."
>         droid exec --skip-permissions-unsafe -f prompt.txt
>
>     - name: Upload debug artifacts
>       uses: actions/upload-artifact@v4
>       with:
>         name: droid-review-debug-${{ github.run_id }}
>         path: |
>           prompt.txt
>           ~/.factory/logs/droid-log-single.log
>           ~/.factory/logs/console.log
>           ~/.factory/sessions/*
>         if-no-files-found: ignore
>         retention-days: 7
> ```

[Source: GitHub — Factory-AI/droid-code-review](https://github.com/Factory-AI/droid-code-review)
